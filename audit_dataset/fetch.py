"""Fetch the audited sources of a collection into ``audited-sources/``.

Only versions of relevant reports that pin a full commit and are not
``not_audited`` are fetched; every other version is recorded in the manifest
as skipped. Files are read straight from a bare clone's objects, never from a
checkout, and stored at ``<repository>/<commit>/<path>`` (see ``manifest``).
"""

from __future__ import annotations

import hashlib
import shutil
import stat
import tempfile
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path, PurePosixPath
from typing import Any

from . import DatasetError
from . import git
from .collections import Collection
from .manifest import GIT_METADATA_FILES, SCHEMA_VERSION, stored_path, write_manifest
from .summary import path_problem, read_summary, relevant_versions

BLOB_MODES = frozenset({"100644", "100755"})
SYMLINK_MODE = "120000"
SUBMODULE_MODE = "160000"


class FetchError(DatasetError):
    """A source could not be fetched safely or exactly."""


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


@dataclass
class FetchResult:
    sources: int = 0
    files: int = 0
    skipped: int = 0
    unavailable: int = 0
    omitted: int = 0
    manifest_path: Path | None = None
    warnings: list[str] = field(default_factory=list)


# --- What to fetch ------------------------------------------------------------


def repository_urls(summary: dict[str, Any]) -> dict[str, str]:
    """One URL per repository id over the relevant reports."""
    urls: dict[str, str] = {}
    for report in summary["reports"]:
        if not report["isRelevant"]:
            continue
        for repository in report["repositories"]:
            url = repository["url"].strip()
            if url.startswith("-"):
                raise FetchError(f"invalid URL for repository {repository['id']!r}")
            previous = urls.setdefault(repository["id"], url)
            if previous != url:
                raise FetchError(
                    f"repository {repository['id']!r} has conflicting URLs: {previous!r} and {url!r}"
                )
    return urls


def revision_label(revision: dict[str, Any]) -> str:
    for key in ("commit", "tag", "ref", "url"):
        value = revision.get(key)
        if isinstance(value, str) and value:
            return value
    return ""


def collect_sources(summary: dict[str, Any]) -> tuple[list[Source], list[SkippedSource]]:
    sources: set[Source] = set()
    skipped: set[SkippedSource] = set()
    path_kinds: dict[tuple[str, str, str], str] = {}
    for _, repository, path, path_kind, _, version in relevant_versions(summary):
        revision = version["revision"]
        commit = git.full_commit(revision)
        if commit is None:
            reason = (
                "revision is not a commit" if revision["kind"] != "commit"
                else "commit is not a full 40- or 64-hex object id"
            )
            skipped.add(SkippedSource(repository, path, revision["kind"], revision_label(revision), reason))
            continue
        if version["status"] == "not_audited":
            continue
        key = (repository, path, commit)
        if path_kinds.setdefault(key, path_kind) != path_kind:
            raise FetchError(f"conflicting path kinds for {repository}:{path}@{commit}")
        sources.add(Source(repository, path, path_kind, commit))
    return sorted(sources), sorted(skipped)


# --- Git access ---------------------------------------------------------------


def repository_reachable(url: str) -> bool:
    try:
        git.run(None, "ls-remote", "--exit-code", url, "HEAD")
    except git.GitError:
        return False
    return True


def initialize_repository(directory: Path, url: str, object_format: str) -> None:
    args = ["init", "--bare", "--quiet"]
    if object_format == "sha256":
        args.append("--object-format=sha256")
    git.run(None, *args, str(directory))
    git.run(directory, "remote", "add", "origin", url)


def verify_exact_commit(repository: Path, commit: str) -> None:
    resolved = git.run_text(repository, "rev-parse", "--verify", "--quiet", f"{commit}^{{commit}}").strip()
    if resolved.lower() != commit:
        raise FetchError(f"fetched object resolved to {resolved}, expected exact commit {commit}")


def fetch_commits(
    repository: Path, commits: list[str], full_commits: set[str], warnings: list[str]
) -> set[str]:
    """Fetch the commits; return those that could not be fetched.

    Everything is first requested in one ``--filter=blob:none`` fetch, which
    brings commits and trees but no file contents; blobs of file sources are
    then read lazily. Commits with directory sources are fetched again with all
    their blobs, since lazy per-file reads would be slow there.
    """
    partial = ["fetch", "--quiet", "--no-tags", "--depth=1", "--filter=blob:none", "origin"]
    full = ["fetch", "--quiet", "--no-tags", "--depth=1", "origin"]
    missing: set[str] = set()
    try:
        git.run(repository, *partial, *commits)
    except git.GitError:
        for commit in commits:
            try:
                git.run(repository, *partial, commit)
            except git.GitError as error:
                warnings.append(str(error))
                missing.add(commit)
    wanted = [commit for commit in commits if commit in full_commits and commit not in missing]
    if wanted:
        try:
            git.run(repository, *full, *wanted)
        except git.GitError:
            for commit in wanted:
                try:
                    git.run(repository, *full, commit)
                except git.GitError as error:
                    warnings.append(str(error))
                    missing.add(commit)
    for commit in commits:
        if commit not in missing:
            verify_exact_commit(repository, commit)
    return missing


def resolve_symlink_target(link_path: str, raw_target: bytes) -> tuple[str, str]:
    try:
        target = raw_target.decode("utf-8")
    except UnicodeDecodeError as error:
        raise FetchError(f"symlink at {link_path!r} has a non-UTF-8 target") from error
    if not target or "\\" in target:
        raise FetchError(f"symlink at {link_path!r} has an unsupported target: {target!r}")
    target_path = PurePosixPath(target)
    if target_path.is_absolute():
        raise FetchError(f"symlink at {link_path!r} has an absolute target: {target!r}")
    resolved_parts = list(PurePosixPath(link_path).parent.parts)
    for part in target_path.parts:
        if part in {"", "."}:
            continue
        if part == "..":
            if not resolved_parts:
                raise FetchError(f"symlink at {link_path!r} escapes the repository: {target!r}")
            resolved_parts.pop()
        else:
            resolved_parts.append(part)
    if not resolved_parts:
        raise FetchError(f"symlink at {link_path!r} does not resolve to a file: {target!r}")
    return target, PurePosixPath(*resolved_parts).as_posix()


def exact_tree_entry(repository: Path, commit: str, path: str) -> tuple[str, str, str, str]:
    entries = git.ls_tree(repository, commit, path, recursive=False)
    if len(entries) != 1 or entries[0][3] != path:
        raise MissingSymlinkTarget(f"symlink target is missing at {path!r} in commit {commit}")
    return entries[0]


def resolve_blob(repository: Path, commit: str, path: str, mode: str, object_id: str) -> ResolvedBlob:
    """Follow repository-internal symlinks to the blob they finally name."""
    chain: list[tuple[str, str, str]] = []
    seen: set[str] = set()
    while mode == SYMLINK_MODE:
        if path in seen:
            raise FetchError(f"symlink cycle detected at {path!r}")
        seen.add(path)
        target, resolved_path = resolve_symlink_target(path, git.read_blob(repository, object_id))
        chain.append((path, target, object_id))
        mode, object_type, object_id, _ = exact_tree_entry(repository, commit, resolved_path)
        if object_type != "blob":
            raise MissingSymlinkTarget(f"symlink at {path!r} resolves to non-file {resolved_path!r}")
        path = resolved_path
    if mode not in BLOB_MODES:
        raise FetchError(f"unsupported Git mode {mode} at {path!r}")
    return ResolvedBlob(path, mode, object_id, tuple(chain))


def write_blob(repository: Path, object_id: str, target: Path, mode: str) -> str:
    content = git.read_blob(repository, object_id)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(content)
    permissions = stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH
    if mode == "100755":
        permissions |= stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
    target.chmod(permissions)
    return hashlib.sha256(content).hexdigest()


# --- Storing ------------------------------------------------------------------


class Store:
    """The staged ``audited-sources`` tree of one fetch run.

    A file is written once however many sources cover it, and two stored paths
    that differ only by case are rejected: the dataset must look the same on
    case-insensitive and case-sensitive filesystems.
    """

    def __init__(self, staging: Path) -> None:
        self.staging = staging
        self.written: dict[str, tuple[str, str]] = {}  # stored path -> (object id, sha256)
        self.by_folded_path: dict[str, str] = {}

    def store(self, repository: Path, source: Source, path: str, resolved: ResolvedBlob) -> str:
        target = stored_path(self.staging, source.repository, source.commit, path)
        key = target.relative_to(self.staging).as_posix()
        previous = self.written.get(key)
        if previous is not None:
            if previous[0] != resolved.object_id:
                raise FetchError(f"{key} is stored with two different contents")
            return previous[1]
        folded = key.lower()
        other = self.by_folded_path.get(folded)
        if other is not None:
            raise FetchError(f"stored paths differ only by case: {other!r} and {key!r}")
        digest = write_blob(repository, resolved.object_id, target, resolved.mode)
        self.written[key] = (resolved.object_id, digest)
        self.by_folded_path[folded] = key
        return digest


def file_record(path: str, object_id: str, mode: str, resolved: ResolvedBlob, digest: str) -> dict[str, Any]:
    record: dict[str, Any] = {"path": path, "git_object": object_id, "git_mode": mode, "sha256": digest}
    if resolved.symlink_chain:
        record["symlink_chain"] = [
            {"path": link_path, "target": link_target, "git_object": link_object}
            for link_path, link_target, link_object in resolved.symlink_chain
        ]
        record["resolved_path"] = resolved.path
        record["resolved_git_object"] = resolved.object_id
        record["resolved_git_mode"] = resolved.mode
    return record


def omitted_record(path: str, object_id: str, mode: str, reason: str) -> dict[str, str]:
    return {"path": path, "git_object": object_id, "git_mode": mode, "reason": reason}


def tree_entries(repository: Path, source: Source) -> list[tuple[str, str, str, str]]:
    """The entries a source covers, as ``(mode, type, object id, path)``."""
    entries = git.ls_tree(repository, source.commit, source.path, source.path_kind == "directory_recursive")
    if source.path_kind == "file":
        if len(entries) != 1 or entries[0][3] != source.path or entries[0][1] not in {"blob", "commit"}:
            raise FetchError(f"expected a file at {source.repository}:{source.path}@{source.commit}")
        return entries
    if not entries:
        raise FetchError(f"expected a non-empty directory at {source.repository}:{source.path}@{source.commit}")
    prefix = source.path + "/"
    for _, object_type, _, name in entries:
        if not name.startswith(prefix) or object_type not in {"blob", "commit"}:
            raise FetchError(f"unexpected Git tree entry {name!r} in {source.path!r}")
        problem = path_problem(name)
        if problem is not None:
            raise FetchError(f"tree entry {name!r} {problem}")
    return entries


def export_source(repository: Path, source: Source, store: Store) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    files: list[dict[str, Any]] = []
    omitted: list[dict[str, str]] = []
    for mode, object_type, object_id, path in tree_entries(repository, source):
        if object_type == "commit" or mode == SUBMODULE_MODE:
            omitted.append(omitted_record(path, object_id, mode, "submodule"))
            continue
        if PurePosixPath(path).name in GIT_METADATA_FILES:
            omitted.append(omitted_record(path, object_id, mode, "git metadata file"))
            continue
        try:
            resolved = resolve_blob(repository, source.commit, path, mode, object_id)
        except MissingSymlinkTarget as error:
            omitted.append(omitted_record(path, object_id, mode, str(error)))
            continue
        digest = store.store(repository, source, path, resolved)
        files.append(file_record(path, object_id, mode, resolved, digest))
    return files, omitted


# --- Driver -------------------------------------------------------------------


def fetch_collection(collection: Collection) -> FetchResult:
    summary = read_summary(collection)
    urls = repository_urls(summary)
    sources, skipped = collect_sources(summary)
    for source in sources:
        if source.repository not in urls:
            raise FetchError(f"scope references repository {source.repository!r} without a URL")
    destination = collection.sources_dir
    destination.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=f".{destination.name}.", dir=destination.parent))
    result = FetchResult(skipped=len(skipped))
    by_repository: dict[str, list[Source]] = defaultdict(list)
    for source in sources:
        by_repository[source.repository].append(source)

    exported: list[dict[str, Any]] = []
    unavailable: list[dict[str, str]] = []
    try:
        store = Store(staging)
        with tempfile.TemporaryDirectory(prefix="audit-dataset-fetch-") as temporary:
            for index, (repository_id, repository_sources) in enumerate(sorted(by_repository.items())):
                url = urls[repository_id]
                lengths = {len(source.commit) for source in repository_sources}
                if len(lengths) != 1:
                    raise FetchError(f"repository {repository_id!r} mixes Git object formats")
                if not repository_reachable(url):
                    result.warnings.append(
                        f"repository {url} is not reachable; skipping {len(repository_sources)} source(s)"
                    )
                    unavailable.extend(
                        unavailable_record(source, "repository is not reachable") for source in repository_sources
                    )
                    continue
                git_directory = Path(temporary) / f"repository-{index}.git"
                initialize_repository(git_directory, url, "sha256" if lengths == {64} else "sha1")
                by_commit: dict[str, list[Source]] = defaultdict(list)
                for source in repository_sources:
                    by_commit[source.commit].append(source)
                full_commits = {s.commit for s in repository_sources if s.path_kind == "directory_recursive"}
                missing = fetch_commits(git_directory, sorted(by_commit), full_commits, result.warnings)
                for commit, commit_sources in sorted(by_commit.items()):
                    if commit in missing:
                        unavailable.extend(
                            unavailable_record(source, "commit could not be fetched") for source in commit_sources
                        )
                        continue
                    for source in sorted(commit_sources):
                        files, omitted = export_source(git_directory, source, store)
                        entry: dict[str, Any] = {
                            "repository": source.repository,
                            "repository_url": url,
                            "source_path": source.path,
                            "path_kind": source.path_kind,
                            "commit": source.commit,
                            "files": files,
                        }
                        if omitted:
                            entry["omitted_files"] = omitted
                        exported.append(entry)
                        result.files += len(files)
                        result.omitted += len(omitted)
        manifest = {
            "schema_version": SCHEMA_VERSION,
            "collection": collection.name,
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
            "unavailable": unavailable,
        }
        write_manifest(staging / collection.manifest_path.name, manifest)
        if destination.exists():
            shutil.rmtree(destination)
        staging.replace(destination)
    except BaseException:
        shutil.rmtree(staging, ignore_errors=True)
        raise
    result.sources = len(exported)
    result.unavailable = len(unavailable)
    result.manifest_path = collection.manifest_path
    return result


def unavailable_record(source: Source, reason: str) -> dict[str, str]:
    return {
        "repository": source.repository,
        "source_path": source.path,
        "path_kind": source.path_kind,
        "commit": source.commit,
        "reason": reason,
    }
