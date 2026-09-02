#!/usr/bin/env python3
"""Fetch source paths pinned to exact commits in an audit-summary.json file."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import stat
import subprocess
import sys
import tempfile
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Any


FULL_COMMIT_RE = re.compile(r"(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})\Z")
SUPPORTED_PATH_KINDS = {"file", "directory_recursive"}


class FetchError(RuntimeError):
    """An audit-summary entry could not be fetched safely or exactly."""


class MissingSymlinkTarget(FetchError):
    """A repository-internal symlink points to no entry in the pinned commit."""


@dataclass(frozen=True, order=True)
class Source:
    repository: str
    path: str
    path_kind: str
    commit: str


@dataclass(frozen=True, order=True)
class SkippedSource:
    repository: str
    path: str
    revision_kind: str
    revision: str
    reason: str


@dataclass(frozen=True)
class ResolvedBlob:
    path: str
    mode: str
    object_id: str
    symlink_chain: tuple[tuple[str, str, str], ...]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Fetch only audit sources whose revisions are pinned to complete "
            "Git commit hashes."
        )
    )
    parser.add_argument("summary", type=Path, help="path to audit-summary.json")
    parser.add_argument(
        "--output",
        type=Path,
        help=(
            "destination directory (default: audited-sources in the project "
            "directory)"
        ),
    )
    return parser.parse_args()


def read_summary(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise FetchError(f"could not read {path}: {error}") from error
    if not isinstance(value, dict):
        raise FetchError(f"expected a JSON object in {path}")
    return value


def require_safe_posix_path(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value:
        raise FetchError(f"{label} must be a non-empty string")
    if "\\" in value:
        raise FetchError(f"{label} must use '/' separators: {value!r}")
    normalized = value.rstrip("/")
    path = PurePosixPath(normalized)
    if (
        not normalized
        or path.is_absolute()
        or any(part in {"", ".", ".."} for part in path.parts)
    ):
        raise FetchError(f"unsafe {label}: {value!r}")
    return path.as_posix()


def repository_urls(summary: dict[str, Any]) -> dict[str, str]:
    result: dict[str, str] = {}
    reports = summary.get("reports")
    if not isinstance(reports, list):
        raise FetchError("summary must contain a reports array")
    for report in reports:
        if not isinstance(report, dict):
            raise FetchError("each report must be an object")
        repositories = report.get("repositories", [])
        if not isinstance(repositories, list):
            raise FetchError("report repositories must be an array")
        for repository in repositories:
            if not isinstance(repository, dict):
                raise FetchError("each repository must be an object")
            repository_id = require_safe_posix_path(
                repository.get("id"), "repository id"
            )
            url = repository.get("url")
            if not isinstance(url, str) or not url or url.startswith("-"):
                raise FetchError(f"invalid URL for repository {repository_id!r}")
            previous = result.setdefault(repository_id, url)
            if previous != url:
                raise FetchError(
                    f"repository {repository_id!r} has conflicting URLs: "
                    f"{previous!r} and {url!r}"
                )
    return result


def revision_label(revision: dict[str, Any]) -> str:
    for key in ("commit", "tag", "branch", "ref", "url"):
        value = revision.get(key)
        if isinstance(value, str) and value:
            return value
    return ""


def collect_sources(
    summary: dict[str, Any], urls: dict[str, str]
) -> tuple[list[Source], list[SkippedSource]]:
    sources: set[Source] = set()
    skipped: set[SkippedSource] = set()
    path_kinds: dict[tuple[str, str, str], str] = {}

    for report in summary["reports"]:
        scopes = report.get("scopes", [])
        if not isinstance(scopes, list):
            raise FetchError("report scopes must be an array")
        for scope in scopes:
            if not isinstance(scope, dict):
                raise FetchError("each scope must be an object")
            repository = require_safe_posix_path(
                scope.get("repository"), "scope repository"
            )
            if repository not in urls:
                raise FetchError(f"scope references unknown repository {repository!r}")
            paths = scope.get("paths")
            if not isinstance(paths, dict):
                raise FetchError(
                    f"scope paths for {repository!r} must be an object with versions"
                )
            for raw_path, path_data in paths.items():
                path = require_safe_posix_path(raw_path, "source path")
                if not isinstance(path_data, dict):
                    raise FetchError(f"source path metadata must be an object: {path!r}")
                path_kind = path_data.get("path_kind")
                if path_kind not in SUPPORTED_PATH_KINDS:
                    raise FetchError(
                        f"unsupported path_kind {path_kind!r} for {repository}:{path}"
                    )
                versions = path_data.get("versions")
                if not isinstance(versions, list):
                    raise FetchError(f"versions must be an array for {repository}:{path}")
                for version in versions:
                    if not isinstance(version, dict) or not isinstance(
                        version.get("revision"), dict
                    ):
                        raise FetchError(
                            f"version lacks a revision object for {repository}:{path}"
                        )
                    revision = version["revision"]
                    kind = revision.get("kind")
                    kind_label = kind if isinstance(kind, str) else "unknown"
                    commit = revision.get("commit")
                    if not isinstance(commit, str) or not FULL_COMMIT_RE.fullmatch(
                        commit
                    ):
                        reason = (
                            "revision is not a commit"
                            if kind != "commit"
                            else "commit is not a full 40- or 64-hex object id"
                        )
                        skipped.add(
                            SkippedSource(
                                repository,
                                path,
                                kind_label,
                                revision_label(revision),
                                reason,
                            )
                        )
                        continue
                    commit = commit.lower()
                    key = (repository, path, commit)
                    previous_kind = path_kinds.setdefault(key, path_kind)
                    if previous_kind != path_kind:
                        raise FetchError(
                            f"conflicting path kinds for {repository}:{path}@{commit}"
                        )
                    sources.add(Source(repository, path, path_kind, commit))
    return sorted(sources), sorted(skipped)


def run_git(repository: Path, *args: str, text: bool = True) -> str | bytes:
    command = ["git", "-C", os.fspath(repository), *args]
    try:
        completed = subprocess.run(
            command,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=text,
        )
    except FileNotFoundError as error:
        raise FetchError("git executable was not found") from error
    except subprocess.CalledProcessError as error:
        stderr = (
            error.stderr.strip()
            if isinstance(error.stderr, str)
            else error.stderr.decode(errors="replace").strip()
        )
        raise FetchError(f"{' '.join(command)} failed: {stderr}") from error
    return completed.stdout


def initialize_repository(directory: Path, url: str, object_format: str) -> None:
    init_args = ["git", "init", "--bare", "--quiet"]
    if object_format == "sha256":
        init_args.append("--object-format=sha256")
    init_args.append(os.fspath(directory))
    subprocess.run(
        init_args,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    run_git(directory, "remote", "add", "origin", url)


def fetch_exact_commit(repository: Path, commit: str) -> None:
    run_git(repository, "fetch", "--quiet", "--no-tags", "--depth=1", "origin", commit)
    resolved = run_git(repository, "rev-parse", "--verify", "FETCH_HEAD^{commit}")
    assert isinstance(resolved, str)
    if resolved.strip().lower() != commit:
        raise FetchError(
            f"fetched object resolved to {resolved.strip()}, expected exact commit {commit}"
        )


def ls_tree(
    repository: Path, commit: str, path: str, recursive: bool
) -> list[tuple[str, str, str, str]]:
    args = ["--literal-pathspecs", "ls-tree", "-z", "--full-tree"]
    if recursive:
        args.append("-r")
    args.extend([commit, "--", path])
    raw = run_git(repository, *args, text=False)
    assert isinstance(raw, bytes)
    entries: list[tuple[str, str, str, str]] = []
    for record in raw.split(b"\0"):
        if not record:
            continue
        metadata, separator, raw_name = record.partition(b"\t")
        if not separator:
            raise FetchError(f"could not parse git tree entry for {path!r}")
        try:
            mode, object_type, object_id = metadata.decode("ascii").split(" ")
            name = raw_name.decode("utf-8", errors="surrogateescape")
        except ValueError as error:
            raise FetchError(f"could not parse git tree entry for {path!r}") from error
        entries.append((mode, object_type, object_id, name))
    return entries


def read_blob(repository: Path, object_id: str) -> bytes:
    content = run_git(repository, "cat-file", "blob", object_id, text=False)
    assert isinstance(content, bytes)
    return content


def resolve_symlink_target(link_path: str, raw_target: bytes) -> tuple[str, str]:
    try:
        target = raw_target.decode("utf-8")
    except UnicodeDecodeError as error:
        raise FetchError(f"symlink at {link_path!r} has a non-UTF-8 target") from error
    if not target:
        raise FetchError(f"symlink at {link_path!r} has an empty target")
    if "\\" in target:
        raise FetchError(
            f"symlink at {link_path!r} has a target with a backslash: {target!r}"
        )

    target_path = PurePosixPath(target)
    if target_path.is_absolute():
        raise FetchError(
            f"symlink at {link_path!r} has an absolute target: {target!r}"
        )

    resolved_parts = list(PurePosixPath(link_path).parent.parts)
    for part in target_path.parts:
        if part in {"", "."}:
            continue
        if part == "..":
            if not resolved_parts:
                raise FetchError(
                    f"symlink at {link_path!r} escapes the repository: {target!r}"
                )
            resolved_parts.pop()
        else:
            resolved_parts.append(part)
    if not resolved_parts:
        raise FetchError(
            f"symlink at {link_path!r} does not resolve to a file: {target!r}"
        )
    return target, PurePosixPath(*resolved_parts).as_posix()


def exact_tree_entry(
    repository: Path, commit: str, path: str
) -> tuple[str, str, str, str]:
    entries = ls_tree(repository, commit, path, recursive=False)
    if len(entries) != 1 or entries[0][3] != path:
        raise MissingSymlinkTarget(
            f"symlink target is missing at {path!r} in commit {commit}"
        )
    return entries[0]


def resolve_blob(
    repository: Path,
    commit: str,
    path: str,
    mode: str,
    object_id: str,
) -> ResolvedBlob:
    current_path = path
    current_mode = mode
    current_object_id = object_id
    symlink_chain: list[tuple[str, str, str]] = []
    seen: set[str] = set()

    while current_mode == "120000":
        if current_path in seen:
            raise FetchError(f"symlink cycle detected at {current_path!r}")
        seen.add(current_path)
        target, resolved_path = resolve_symlink_target(
            current_path, read_blob(repository, current_object_id)
        )
        symlink_chain.append((current_path, target, current_object_id))
        next_mode, object_type, next_object_id, _ = exact_tree_entry(
            repository, commit, resolved_path
        )
        if object_type != "blob":
            raise FetchError(
                f"symlink at {current_path!r} resolves to non-file {resolved_path!r}"
            )
        current_path = resolved_path
        current_mode = next_mode
        current_object_id = next_object_id

    if current_mode == "160000":
        raise FetchError(f"symlink resolves to a submodule at {current_path!r}")
    if current_mode not in {"100644", "100755"}:
        raise FetchError(
            f"symlink resolves to unsupported Git mode {current_mode} "
            f"at {current_path!r}"
        )
    return ResolvedBlob(
        current_path, current_mode, current_object_id, tuple(symlink_chain)
    )


def write_blob(repository: Path, object_id: str, target: Path, mode: str) -> str:
    if mode not in {"100644", "100755"}:
        if mode == "120000":
            raise FetchError(f"refusing to materialize symlink at {target}")
        if mode == "160000":
            raise FetchError(f"cannot fetch submodule contents at {target}")
        raise FetchError(f"unsupported Git mode {mode} at {target}")
    content = read_blob(repository, object_id)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(content)
    permissions = stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH
    if mode == "100755":
        permissions |= stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
    target.chmod(permissions)
    return hashlib.sha256(content).hexdigest()


def manifest_file_record(
    source: Source,
    relative_path: str,
    original_object_id: str,
    original_mode: str,
    resolved: ResolvedBlob,
    digest: str,
) -> dict[str, Any]:
    record: dict[str, Any] = {
        "file": (
            PurePosixPath(source.repository)
            / source.path
            / source.commit
            / relative_path
        ).as_posix(),
        "git_object": original_object_id,
        "git_mode": original_mode,
        "sha256": digest,
    }
    if resolved.symlink_chain:
        record.update(
            {
                "symlink_chain": [
                    {
                        "path": link_path,
                        "target": link_target,
                        "git_object": link_object_id,
                    }
                    for link_path, link_target, link_object_id in resolved.symlink_chain
                ],
                "resolved_path": resolved.path,
                "resolved_git_object": resolved.object_id,
                "resolved_git_mode": resolved.mode,
            }
        )
    return record


def omitted_file_record(
    source: Source,
    relative_path: str,
    object_id: str,
    mode: str,
    error: MissingSymlinkTarget,
) -> dict[str, str]:
    return {
        "file": (
            PurePosixPath(source.repository)
            / source.path
            / source.commit
            / relative_path
        ).as_posix(),
        "git_object": object_id,
        "git_mode": mode,
        "reason": str(error),
    }


def export_source(
    repository: Path, source: Source, output: Path
) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    repository_root = output.joinpath(*PurePosixPath(source.repository).parts)
    source_root = repository_root.joinpath(*PurePosixPath(source.path).parts)
    revision_root = source_root / source.commit
    source_root.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=f".{source.commit}.", dir=source_root.parent))
    records: list[dict[str, Any]] = []
    omitted: list[dict[str, str]] = []
    try:
        entries = ls_tree(
            repository, source.commit, source.path, source.path_kind == "directory_recursive"
        )
        if source.path_kind == "file":
            if (
                len(entries) != 1
                or entries[0][3] != source.path
                or entries[0][1] != "blob"
            ):
                raise FetchError(
                    f"expected a file at {source.repository}:{source.path}@{source.commit}"
                )
            mode, _, object_id, _ = entries[0]
            relative = PurePosixPath(source.path).name
            try:
                resolved = resolve_blob(
                    repository, source.commit, source.path, mode, object_id
                )
            except MissingSymlinkTarget as error:
                omitted.append(
                    omitted_file_record(source, relative, object_id, mode, error)
                )
            else:
                digest = write_blob(
                    repository,
                    resolved.object_id,
                    staging / relative,
                    resolved.mode,
                )
                records.append(
                    manifest_file_record(
                        source, relative, object_id, mode, resolved, digest
                    )
                )
        else:
            prefix = source.path.rstrip("/") + "/"
            if not entries:
                raise FetchError(
                    "expected a non-empty directory at "
                    f"{source.repository}:{source.path}@{source.commit}"
                )
            for mode, object_type, object_id, name in entries:
                if object_type != "blob" or not name.startswith(prefix):
                    raise FetchError(
                        f"unexpected Git tree entry {name!r} in {source.path!r}"
                    )
                relative_path = require_safe_posix_path(
                    name[len(prefix) :], "tree entry"
                )
                target = staging.joinpath(*PurePosixPath(relative_path).parts)
                try:
                    resolved = resolve_blob(
                        repository, source.commit, name, mode, object_id
                    )
                except MissingSymlinkTarget as error:
                    omitted.append(
                        omitted_file_record(
                            source, relative_path, object_id, mode, error
                        )
                    )
                else:
                    digest = write_blob(
                        repository, resolved.object_id, target, resolved.mode
                    )
                    records.append(
                        manifest_file_record(
                            source, relative_path, object_id, mode, resolved, digest
                        )
                    )
        revision_root.parent.mkdir(parents=True, exist_ok=True)
        if revision_root.exists():
            shutil.rmtree(revision_root)
        staging.replace(revision_root)
    except BaseException:
        shutil.rmtree(staging, ignore_errors=True)
        raise
    return records, omitted


def default_output(summary_path: Path) -> Path:
    return summary_path.resolve().parent / "audited-sources"


def fetch_sources(summary_path: Path, output: Path | None = None) -> tuple[int, int, Path]:
    summary_path = summary_path.resolve()
    summary = read_summary(summary_path)
    urls = repository_urls(summary)
    sources, skipped = collect_sources(summary, urls)
    destination = (output or default_output(summary_path)).resolve()
    destination.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(
        tempfile.mkdtemp(prefix=f".{destination.name}.", dir=destination.parent)
    )

    by_repository: dict[str, list[Source]] = defaultdict(list)
    for source in sources:
        by_repository[source.repository].append(source)

    exported: list[dict[str, Any]] = []
    try:
        with tempfile.TemporaryDirectory(prefix="audit-source-fetch-") as temporary:
            temporary_root = Path(temporary)
            for index, (repository_id, repository_sources) in enumerate(
                sorted(by_repository.items())
            ):
                git_directory = temporary_root / f"repository-{index}.git"
                object_id_lengths = {len(source.commit) for source in repository_sources}
                if len(object_id_lengths) != 1:
                    raise FetchError(
                        f"repository {repository_id!r} mixes Git object formats"
                    )
                object_format = "sha256" if object_id_lengths == {64} else "sha1"
                initialize_repository(
                    git_directory, urls[repository_id], object_format
                )
                by_commit: dict[str, list[Source]] = defaultdict(list)
                for source in repository_sources:
                    by_commit[source.commit].append(source)
                for commit, commit_sources in sorted(by_commit.items()):
                    fetch_exact_commit(git_directory, commit)
                    for source in sorted(commit_sources):
                        files, omitted_files = export_source(
                            git_directory, source, staging
                        )
                        exported_source: dict[str, Any] = {
                            "repository": source.repository,
                            "repository_url": urls[source.repository],
                            "source_path": source.path,
                            "path_kind": source.path_kind,
                            "commit": source.commit,
                            "files": files,
                        }
                        if omitted_files:
                            exported_source["omitted_files"] = omitted_files
                        exported.append(exported_source)

        manifest = {
            "schema_version": "1.0.0",
            "project": summary.get("project"),
            "audit_summary": os.path.relpath(summary_path, destination),
            "sources": exported,
            "skipped": [
                {
                    "repository": item.repository,
                    "source_path": item.path,
                    "revision_kind": item.revision_kind,
                    "revision": item.revision,
                    "reason": item.reason,
                }
                for item in skipped
            ],
        }
        (staging / "manifest.json").write_text(
            json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
        )
        if destination.exists():
            shutil.rmtree(destination)
        staging.replace(destination)
    except BaseException:
        shutil.rmtree(staging, ignore_errors=True)
        raise
    return len(exported), len(skipped), destination / "manifest.json"


def main() -> int:
    args = parse_args()
    try:
        exported, skipped, manifest = fetch_sources(args.summary, args.output)
    except (FetchError, OSError, subprocess.SubprocessError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print(
        f"exported {exported} source revisions; "
        f"skipped {skipped} mutable or ambiguous revisions"
    )
    manifest_data = read_summary(manifest)
    omitted = sum(
        len(source.get("omitted_files", []))
        for source in manifest_data.get("sources", [])
        if isinstance(source, dict)
    )
    if omitted:
        print(f"omitted {omitted} files with missing repository-internal symlink targets")
    print(f"manifest: {manifest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
