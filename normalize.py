#!/usr/bin/env python3
"""Canonical repository ids shared by every dataset script.

A repository id is derived from its URL by one rule so that every collection in
the dataset names the same repository the same way:

- GitHub repositories: ``owner/repo`` (``.git`` suffix and trailing slash stripped).
- GitHub gists: ``gist/<owner>/<id>``.
- Other hosts: ``<host>/<path>`` such as ``gitlab.com/owner/repo``.

Run ``python3 normalize.py --migrate <project> | --all`` to rewrite the ids in
existing ``audit-summary.json`` and ``audited-sources/manifest.json`` files and
to move the fetched sources to the directories named after the new ids.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path, PurePosixPath
from typing import Any
from urllib.parse import urlsplit

SUMMARY_SCHEMA_VERSION = "1.4.0"


class NormalizeError(Exception):
    """A repository URL cannot be turned into a canonical id."""


def canonical_repository_id(url: str) -> str:
    """Return the canonical repository id for ``url``."""
    if not isinstance(url, str) or not url.strip():
        raise NormalizeError("repository url must be a non-empty string")
    value = url.strip()
    if "://" not in value:
        value = "https://" + value
    parts = urlsplit(value)
    host = parts.hostname or ""
    host = host.lower()
    if host.startswith("www."):
        host = host[4:]
    segments = [segment for segment in parts.path.split("/") if segment]
    if not segments:
        raise NormalizeError(f"repository url has no path: {url!r}")
    if segments[-1].endswith(".git"):
        segments[-1] = segments[-1][: -len(".git")]
    if host == "github.com":
        if len(segments) < 2:
            raise NormalizeError(f"github url must name owner and repository: {url!r}")
        return f"{segments[0]}/{segments[1]}"
    if host == "gist.github.com":
        if len(segments) < 2:
            raise NormalizeError(f"gist url must name owner and id: {url!r}")
        return f"gist/{segments[0]}/{segments[1]}"
    if not host:
        raise NormalizeError(f"repository url has no host: {url!r}")
    return "/".join([host, *segments])


def repository_ids(summary: dict[str, Any]) -> dict[str, str]:
    """Return ``{current id: url}`` for every repository named by a summary."""
    result: dict[str, str] = {}
    for report in summary.get("reports", []):
        for repository in report.get("repositories", []) or []:
            repository_id = repository.get("id")
            url = repository.get("url")
            if isinstance(repository_id, str) and isinstance(url, str):
                result.setdefault(repository_id, url)
    return result


def id_mapping(summary: dict[str, Any]) -> dict[str, str]:
    """Return ``{current id: canonical id}`` for ids that are not canonical yet."""
    mapping: dict[str, str] = {}
    for repository_id, url in repository_ids(summary).items():
        canonical = canonical_repository_id(url)
        if canonical != repository_id:
            mapping[repository_id] = canonical
    return mapping


def validate_summary_ids(summary: dict[str, Any]) -> list[str]:
    """Return human readable problems with the repository ids of a summary."""
    problems: list[str] = []
    for report in summary.get("reports", []):
        known: set[str] = set()
        for repository in report.get("repositories", []) or []:
            repository_id = repository.get("id")
            url = repository.get("url")
            if not isinstance(repository_id, str) or not isinstance(url, str):
                problems.append(
                    f"report {report.get('id')!r}: repository entries need id and url"
                )
                continue
            known.add(repository_id)
            try:
                canonical = canonical_repository_id(url)
            except NormalizeError as error:
                problems.append(f"report {report.get('id')!r}: {error}")
                continue
            if canonical != repository_id:
                problems.append(
                    f"report {report.get('id')!r}: repository id {repository_id!r} "
                    f"must be {canonical!r} (derived from {url})"
                )
        for scope in report.get("scopes", []) or []:
            repository = scope.get("repository")
            if repository not in known:
                problems.append(
                    f"report {report.get('id')!r}: scope references unknown "
                    f"repository {repository!r}"
                )
    return problems


def rewrite_summary(summary: dict[str, Any], mapping: dict[str, str]) -> bool:
    changed = False
    for report in summary.get("reports", []):
        for repository in report.get("repositories", []) or []:
            new = mapping.get(repository.get("id"))
            if new:
                repository["id"] = new
                changed = True
        for scope in report.get("scopes", []) or []:
            new = mapping.get(scope.get("repository"))
            if new:
                scope["repository"] = new
                changed = True
    if summary.get("schema_version") != SUMMARY_SCHEMA_VERSION:
        summary["schema_version"] = SUMMARY_SCHEMA_VERSION
        changed = True
    return changed


def rewrite_file_path(file: str, old: str, new: str) -> str:
    prefix = old + "/"
    if file.startswith(prefix):
        return new + "/" + file[len(prefix) :]
    return file


def rewrite_manifest(manifest: dict[str, Any], mapping: dict[str, str]) -> bool:
    changed = False
    for source in manifest.get("sources", []):
        old = source.get("repository")
        new = mapping.get(old)
        if not new:
            continue
        source["repository"] = new
        for record in source.get("files", []) + source.get("omitted_files", []):
            record["file"] = rewrite_file_path(record["file"], old, new)
        changed = True
    for key in ("skipped", "unavailable"):
        for item in manifest.get(key, []):
            new = mapping.get(item.get("repository"))
            if new:
                item["repository"] = new
                changed = True
    return changed


def move_source_directories(sources_dir: Path, mapping: dict[str, str]) -> list[str]:
    """Move ``audited-sources/<old id>`` trees to their canonical location."""
    moved: list[str] = []
    for old, new in mapping.items():
        old_dir = sources_dir.joinpath(*PurePosixPath(old).parts)
        if not old_dir.is_dir():
            continue
        new_dir = sources_dir.joinpath(*PurePosixPath(new).parts)
        if new_dir.exists():
            # Merge: the canonical directory may already hold other paths.
            for child in sorted(old_dir.iterdir()):
                target = new_dir / child.name
                if target.exists():
                    raise NormalizeError(
                        f"cannot merge {child} into existing {target}"
                    )
                shutil.move(str(child), str(target))
            old_dir.rmdir()
        else:
            new_dir.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(old_dir), str(new_dir))
        moved.append(f"{old} -> {new}")
        # Remove now-empty parents of the old location (e.g. an owner dir).
        parent = old_dir.parent
        while parent != sources_dir and parent.is_dir() and not any(parent.iterdir()):
            parent.rmdir()
            parent = parent.parent
    return moved


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def migrate_collection(collection_dir: Path) -> list[str]:
    """Canonicalize one collection in place; returns a log of what changed."""
    log: list[str] = []
    summary_path = collection_dir / "audit-summary.json"
    if not summary_path.is_file():
        return log
    summary = json.loads(summary_path.read_text(encoding="utf-8"))
    mapping = id_mapping(summary)
    if rewrite_summary(summary, mapping):
        write_json(summary_path, summary)
        log.append(f"{summary_path}: {len(mapping)} id(s) rewritten")

    manifest_path = collection_dir / "audited-sources" / "manifest.json"
    if manifest_path.is_file() and mapping:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        moved = move_source_directories(manifest_path.parent, mapping)
        if rewrite_manifest(manifest, mapping):
            write_json(manifest_path, manifest)
            log.append(f"{manifest_path}: rewritten")
        log.extend(f"  moved {entry}" for entry in moved)
    return log


def discover_collections(dataset_root: Path) -> list[Path]:
    """Every directory with an audit-summary.json: projects and _libs/<vendor>."""
    found: list[Path] = []
    for child in sorted(dataset_root.iterdir()):
        if not child.is_dir() or child.name.startswith("."):
            continue
        if (child / "audit-summary.json").is_file():
            found.append(child)
        elif child.name == "_libs":
            for vendor in sorted(child.iterdir()):
                if vendor.is_dir() and (vendor / "audit-summary.json").is_file():
                    found.append(vendor)
    return found


def resolve_collection(dataset_root: Path, name: str) -> Path:
    for candidate in (dataset_root / name, dataset_root / "_libs" / name):
        if (candidate / "audit-summary.json").is_file():
            return candidate
    raise NormalizeError(f"no collection named {name!r} in {dataset_root}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--migrate", nargs="*", metavar="COLLECTION",
                        help="collections to canonicalize in place")
    parser.add_argument("--all", action="store_true", help="migrate every collection")
    parser.add_argument("--check", action="store_true",
                        help="report non-canonical ids without changing anything")
    parser.add_argument("--dataset-root", type=Path,
                        default=Path(__file__).resolve().parent)
    parser.add_argument("url", nargs="?", help="print the canonical id of one URL")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = args.dataset_root.resolve()
    if args.url:
        print(canonical_repository_id(args.url))
        return 0
    if args.all:
        collections = discover_collections(root)
    elif args.migrate:
        collections = [resolve_collection(root, name) for name in args.migrate]
    else:
        print("error: pass a URL, --migrate COLLECTION..., or --all", file=sys.stderr)
        return 2
    status = 0
    for collection in collections:
        if args.check:
            summary = json.loads((collection / "audit-summary.json").read_text())
            for problem in validate_summary_ids(summary):
                print(f"{collection.name}: {problem}")
                status = 1
            continue
        try:
            for line in migrate_collection(collection):
                print(line)
        except NormalizeError as error:
            print(f"error: {collection.name}: {error}", file=sys.stderr)
            return 1
    return status


if __name__ == "__main__":
    raise SystemExit(main())
