#!/usr/bin/env python3
"""Export a project's deployed L2BEAT contracts and related program sources."""

from __future__ import annotations

import argparse
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
from urllib.parse import unquote, urlsplit


# Replace with your path to the L2BEAT repository or use --l2beat-root.
DEFAULT_L2BEAT_ROOT = Path.home() / "Documents" / "l2beat"
GITHUB_COMPONENT_RE = re.compile(r"[A-Za-z0-9_.-]+\Z")


@dataclass(frozen=True, order=True)
class GitHubSource:
    url: str
    owner: str
    repository: str
    revision: str
    path: str
    path_kind: str

    @property
    def repository_url(self) -> str:
        return f"https://github.com/{self.owner}/{self.repository}.git"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Write deployed.json and copy flattened sources for every contract in "
            "one L2BEAT discovery project."
        )
    )
    parser.add_argument("project", help="L2BEAT discovery project name")
    parser.add_argument(
        "--l2beat-root",
        type=Path,
        default=DEFAULT_L2BEAT_ROOT,
        help=f"L2BEAT checkout (default: {DEFAULT_L2BEAT_ROOT})",
    )
    parser.add_argument(
        "--dataset-root",
        type=Path,
        default=Path(__file__).resolve().parent,
        help="audit-dataset checkout (default: directory containing this script)",
    )
    parser.add_argument(
        "--program-path",
        "--program-paths",
        "--circuit-path",
        "--circuit-paths",
        dest="program_paths",
        action="extend",
        nargs="+",
        default=[],
        metavar="GITHUB_URL",
        help=(
            "GitHub blob or tree URL for source code compiled into the deployment; "
            "may be repeated and may receive multiple URLs"
        ),
    )
    return parser.parse_args()


def strip_jsonc(text: str) -> str:
    """Remove JSONC comments and trailing commas without altering strings."""
    without_comments: list[str] = []
    index = 0
    in_string = False
    escaped = False

    while index < len(text):
        char = text[index]
        following = text[index + 1] if index + 1 < len(text) else ""

        if in_string:
            without_comments.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue

        if char == '"':
            in_string = True
            without_comments.append(char)
            index += 1
        elif char == "/" and following == "/":
            index += 2
            while index < len(text) and text[index] not in "\r\n":
                index += 1
        elif char == "/" and following == "*":
            index += 2
            while index + 1 < len(text) and text[index : index + 2] != "*/":
                if text[index] in "\r\n":
                    without_comments.append(text[index])
                index += 1
            if index + 1 >= len(text):
                raise ValueError("Unterminated block comment in JSONC file")
            index += 2
        else:
            without_comments.append(char)
            index += 1

    cleaned = "".join(without_comments)
    without_trailing_commas: list[str] = []
    index = 0
    in_string = False
    escaped = False
    while index < len(cleaned):
        char = cleaned[index]
        if in_string:
            without_trailing_commas.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue

        if char == '"':
            in_string = True
        if char == ",":
            lookahead = index + 1
            while lookahead < len(cleaned) and cleaned[lookahead].isspace():
                lookahead += 1
            if lookahead < len(cleaned) and cleaned[lookahead] in "}]":
                index += 1
                continue
        without_trailing_commas.append(char)
        index += 1

    return "".join(without_trailing_commas)


def read_jsonc(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(strip_jsonc(path.read_text(encoding="utf-8")))
    except (OSError, json.JSONDecodeError, ValueError) as error:
        raise RuntimeError(f"Could not read {path}: {error}") from error
    if not isinstance(value, dict):
        raise RuntimeError(f"Expected a JSON object in {path}")
    return value


def source_paths(flat_dir: Path, name: str, chain_address: str) -> list[Path]:
    """Find paths emitted by L2BEAT's flattenDiscoveredSources()."""
    direct_file = flat_dir / f"{name}.sol"
    direct_directory = flat_dir / name
    if direct_file.is_file():
        return [direct_file]
    if direct_directory.is_dir():
        return sorted(path for path in direct_directory.rglob("*") if path.is_file())

    # Duplicate discovered names receive an address suffix. Older outputs used
    # either the chain-specific or bare address, so accept both exact variants.
    bare_address = chain_address.split(":", 1)[-1]
    alternatives = {
        f"{name}-{chain_address}",
        f"{name}-{bare_address}",
    }
    for alternative in alternatives:
        candidate_file = flat_dir / f"{alternative}.sol"
        candidate_directory = flat_dir / alternative
        if candidate_file.is_file():
            return [candidate_file]
        if candidate_directory.is_dir():
            return sorted(
                path for path in candidate_directory.rglob("*") if path.is_file()
            )
    return []


def safe_path_components(value: str, label: str) -> tuple[str, ...]:
    if not value or "\\" in value:
        raise RuntimeError(f"Invalid {label}: {value!r}")
    components = tuple(PurePosixPath(value).parts)
    if (
        not components
        or PurePosixPath(value).is_absolute()
        or any(component in {"", ".", ".."} for component in components)
    ):
        raise RuntimeError(f"Invalid {label}: {value!r}")
    return components


def parse_github_source(url: str) -> GitHubSource:
    """Parse a github.com blob/tree URL with an explicit revision and path."""
    parsed = urlsplit(url)
    if parsed.scheme != "https" or parsed.hostname not in {
        "github.com",
        "www.github.com",
    }:
        raise RuntimeError(f"Program path must be an https://github.com URL: {url!r}")
    if (
        parsed.username is not None
        or parsed.password is not None
        or parsed.port is not None
    ):
        raise RuntimeError(f"Invalid GitHub URL authority: {url!r}")

    raw_parts = parsed.path.strip("/").split("/")
    if len(raw_parts) < 5:
        raise RuntimeError(
            "GitHub program path must include owner, repository, blob/tree, "
            f"revision, and path: {url!r}"
        )
    owner, repository, marker = (unquote(part) for part in raw_parts[:3])
    repository = repository.removesuffix(".git")
    if (
        owner in {".", ".."}
        or repository in {".", ".."}
        or not GITHUB_COMPONENT_RE.fullmatch(owner)
        or not GITHUB_COMPONENT_RE.fullmatch(repository)
    ):
        raise RuntimeError(f"Invalid GitHub owner or repository in {url!r}")
    if marker not in {"blob", "tree"}:
        raise RuntimeError(f"GitHub program path must use /blob/ or /tree/: {url!r}")

    revision = unquote(raw_parts[3])
    revision_components = safe_path_components(revision, "GitHub revision")
    if revision.startswith("-") or any(ord(char) < 32 for char in revision):
        raise RuntimeError(f"Invalid GitHub revision: {revision!r}")

    decoded_path_parts = tuple(unquote(part) for part in raw_parts[4:])
    if any("/" in part or "\\" in part for part in decoded_path_parts):
        raise RuntimeError(f"Invalid GitHub source path in {url!r}")
    path = PurePosixPath(*decoded_path_parts).as_posix()
    safe_path_components(path, "GitHub source path")

    safe_path_components("/".join(revision_components), "GitHub revision")
    return GitHubSource(
        url=url,
        owner=owner,
        repository=repository,
        revision=revision,
        path=path,
        path_kind="file" if marker == "blob" else "directory",
    )


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
        raise RuntimeError("git executable was not found") from error
    except subprocess.CalledProcessError as error:
        stderr = (
            error.stderr.strip()
            if isinstance(error.stderr, str)
            else error.stderr.decode(errors="replace").strip()
        )
        raise RuntimeError(f"{' '.join(command)} failed: {stderr}") from error
    return completed.stdout


def initialize_repository(directory: Path, url: str) -> None:
    try:
        subprocess.run(
            ["git", "init", "--bare", "--quiet", os.fspath(directory)],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except FileNotFoundError as error:
        raise RuntimeError("git executable was not found") from error
    except subprocess.CalledProcessError as error:
        stderr = error.stderr.decode(errors="replace").strip()
        raise RuntimeError(
            f"Could not initialize temporary Git repository: {stderr}"
        ) from error
    run_git(directory, "remote", "add", "origin", url)


def fetch_revision(repository: Path, revision: str) -> str:
    run_git(repository, "fetch", "--quiet", "--depth=1", "origin", revision)
    commit = run_git(repository, "rev-parse", "--verify", "FETCH_HEAD^{commit}")
    assert isinstance(commit, str)
    return commit.strip()


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
            raise RuntimeError(f"Could not parse Git tree entry for {path!r}")
        try:
            mode, object_type, object_id = metadata.decode("ascii").split(" ")
            name = raw_name.decode("utf-8", errors="surrogateescape")
        except ValueError as error:
            raise RuntimeError(
                f"Could not parse Git tree entry for {path!r}"
            ) from error
        entries.append((mode, object_type, object_id, name))
    return entries


def copy_git_blob(repository: Path, object_id: str, mode: str, target: Path) -> None:
    if mode not in {"100644", "100755"}:
        kind = (
            "symlink"
            if mode == "120000"
            else "submodule"
            if mode == "160000"
            else mode
        )
        raise RuntimeError(f"Unsupported Git entry {kind} at {target}")
    content = run_git(repository, "cat-file", "blob", object_id, text=False)
    assert isinstance(content, bytes)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(content)
    permissions = stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH
    if mode == "100755":
        permissions |= stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
    target.chmod(permissions)


def export_github_source(
    repository: Path,
    commit: str,
    source: GitHubSource,
    deployed_dir: Path,
) -> list[str]:
    recursive = source.path_kind == "directory"
    entries = ls_tree(repository, commit, source.path, recursive=recursive)
    if not entries:
        raise RuntimeError(
            f"GitHub path does not exist at revision {source.revision!r}: {source.url}"
        )

    if source.path_kind == "file":
        if (
            len(entries) != 1
            or entries[0][3] != source.path
            or entries[0][1] != "blob"
        ):
            raise RuntimeError(
                f"GitHub blob URL does not point to a file: {source.url}"
            )
    else:
        prefix = source.path.rstrip("/") + "/"
        if any(
            entry[1] != "blob" or not entry[3].startswith(prefix)
            for entry in entries
        ):
            raise RuntimeError(
                f"GitHub tree URL does not point to a directory: {source.url}"
            )

    root = (
        Path("github")
        / source.owner
        / source.repository
        / Path(*safe_path_components(source.revision, "GitHub revision"))
    )
    copied: list[str] = []
    for mode, _, object_id, name in entries:
        name_parts = safe_path_components(name, "Git tree path")
        relative_target = root.joinpath(*name_parts)
        copy_git_blob(repository, object_id, mode, deployed_dir / relative_target)
        copied.append((Path("deployed-contracts") / relative_target).as_posix())
    return copied


def fetch_program_sources(
    urls: list[str], deployed_dir: Path
) -> tuple[list[dict[str, Any]], int]:
    sources = sorted({parse_github_source(url) for url in urls})
    grouped: dict[tuple[str, str, str], list[GitHubSource]] = defaultdict(list)
    for source in sources:
        grouped[(source.owner, source.repository, source.revision)].append(source)

    records: list[dict[str, Any]] = []
    with tempfile.TemporaryDirectory(prefix="deployed-program-fetch-") as temporary:
        temporary_root = Path(temporary)
        for index, ((owner, repository_name, revision), revision_sources) in enumerate(
            sorted(grouped.items())
        ):
            repository = temporary_root / f"repository-{index}.git"
            initialize_repository(repository, revision_sources[0].repository_url)
            commit = fetch_revision(repository, revision)
            for source in sorted(revision_sources):
                copied = export_github_source(repository, commit, source, deployed_dir)
                records.append(
                    {
                        "url": source.url,
                        "repository": f"{owner}/{repository_name}",
                        "revision": revision,
                        "resolvedCommit": commit,
                        "path": source.path,
                        "pathKind": source.path_kind,
                        "sourceFiles": copied,
                    }
                )
    return records, sum(len(record["sourceFiles"]) for record in records)


def export_project(
    project: str,
    l2beat_root: Path,
    dataset_root: Path,
    program_paths: list[str] | None = None,
) -> tuple[int, int, int]:
    projects_dir = l2beat_root.resolve() / "packages" / "config" / "src" / "projects"
    project_dir = projects_dir / project
    destination = dataset_root.resolve() / project

    if project in {"", ".", ".."} or Path(project).name != project:
        raise RuntimeError("Project name must be a single directory name")
    if not project_dir.is_dir():
        raise RuntimeError(f"L2BEAT project does not exist: {project_dir}")
    if not destination.is_dir():
        raise RuntimeError(f"Dataset project does not exist: {destination}")

    discovered_path = project_dir / "discovered.json"
    flat_dir = project_dir / ".flat"
    for required in (discovered_path, flat_dir):
        if not required.exists():
            raise RuntimeError(
                f"Required L2BEAT discovery path does not exist: {required}"
            )

    discovered = read_jsonc(discovered_path)
    entries = discovered.get("entries")
    if not isinstance(entries, list):
        raise RuntimeError(f"Expected an entries array in {discovered_path}")

    contracts: list[dict[str, Any]] = []
    missing_sources: list[str] = []
    deployed_dir = destination / "deployed-contracts"
    staging_dir = Path(
        tempfile.mkdtemp(prefix=".deployed-contracts.", dir=destination)
    )

    try:
        for entry in entries:
            if not isinstance(entry, dict) or entry.get("type") != "Contract":
                continue

            name = entry.get("name")
            chain_address = entry.get("address")
            if not isinstance(name, str) or not isinstance(chain_address, str):
                raise RuntimeError(
                    "Deployed contract entry lacks a string name or address"
                )

            copied: list[str] = []
            for source in source_paths(flat_dir, name, chain_address):
                relative_source = source.relative_to(flat_dir)
                target = staging_dir / relative_source
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, target)
                copied.append((Path("deployed-contracts") / relative_source).as_posix())
            if not copied:
                missing_sources.append(name)

            chain, separator, address = chain_address.partition(":")
            contract: dict[str, Any] = {
                "name": name,
                "address": address if separator else chain_address,
                "chain": chain if separator else None,
                "chainSpecificAddress": chain_address,
                "sourceFiles": copied,
            }
            if isinstance(entry.get("template"), str):
                contract["template"] = entry["template"]
            contracts.append(contract)

        program_sources, program_file_count = fetch_program_sources(
            program_paths or [], staging_dir
        )
        contracts.sort(
            key=lambda item: (item["chainSpecificAddress"].lower(), item["name"])
        )
        output = {
            "project": project,
            "discoveryTimestamp": discovered.get("timestamp"),
            "contracts": contracts,
            "programSources": program_sources,
        }
        output_text = json.dumps(output, indent=2) + "\n"

        if deployed_dir.exists():
            shutil.rmtree(deployed_dir)
        staging_dir.replace(deployed_dir)
        (destination / "deployed.json").write_text(output_text, encoding="utf-8")
    except BaseException:
        shutil.rmtree(staging_dir, ignore_errors=True)
        raise

    for name in missing_sources:
        print(
            f"warning: no flattened source found for deployed contract {name}",
            file=sys.stderr,
        )
    contract_file_count = sum(len(contract["sourceFiles"]) for contract in contracts)
    return len(contracts), contract_file_count, program_file_count


def main() -> int:
    args = parse_args()
    try:
        contract_count, contract_source_count, program_source_count = export_project(
            args.project,
            args.l2beat_root,
            args.dataset_root,
            args.program_paths,
        )
    except (RuntimeError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print(
        f"Exported {contract_count} deployed contracts, {contract_source_count} "
        f"contract source files, and {program_source_count} program source files "
        f"to {args.dataset_root.resolve() / args.project}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
