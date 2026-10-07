"""``audited-sources/manifest.json``: what was fetched, where it is stored.

Layout of ``audited-sources/``::

    <repository id>/<commit>/<path in the repository>

The commit comes before the path so that two commits never share a directory:
a repository that renamed ``L1/`` to ``l1/`` between two audited commits would
otherwise collide on a case-insensitive filesystem, and a file scoped twice at
one commit is stored once. ``manifest.json`` lists, per ``(repository,
source_path, commit)`` source of the summary, the files stored for it.

Manifest schema::

    {
      "schema_version": "2.0.0",
      "collection": "scroll",
      "sources": [{
        "repository": "scroll-tech/scroll",
        "repository_url": "https://github.com/scroll-tech/scroll",
        "source_path": "contracts/src",
        "path_kind": "file" | "directory_recursive",
        "commit": "<full lowercase hex>",
        "files": [{
          "path": "contracts/src/L1/Foo.sol",   // in the repository; stored at <repository>/<commit>/<path>
          "git_object": "<blob id upstream>",   // provenance; a symlink's own blob
          "git_mode": "100644",
          "sha256": "<of the file as stored>",  // after formatting, once indexed
          // only for symlinks, which are stored as their resolved target:
          "symlink_chain": [{"path", "target", "git_object"}],
          "resolved_path": "...", "resolved_git_object": "...", "resolved_git_mode": "..."
        }],
        "omitted_files": [{"path", "git_object", "git_mode", "reason"}]  // when any
      }],
      "skipped": [{"repository", "source_path", "revision_kind", "revision", "reason"}],
      "unavailable": [{"repository", "source_path", "path_kind", "commit", "reason"}]
    }

``git_object`` is the upstream blob; Solidity is reformatted after fetching, so
``sha256`` is the only hash of the stored bytes.
"""

from __future__ import annotations

import json
from pathlib import Path, PurePosixPath
from typing import Any

from . import DatasetError
from .collections import Collection

SCHEMA_VERSION = "2.0.0"

# Files git itself interprets. Stored next to audited sources they would hide
# siblings from the dataset's own git tree, so they are recorded but not stored.
GIT_METADATA_FILES = frozenset({".gitignore", ".gitattributes", ".gitmodules"})


def stored_path(sources_dir: Path, repository: str, commit: str, path: str) -> Path:
    """Where the file at ``path`` in ``repository`` at ``commit`` is stored."""
    return sources_dir.joinpath(*PurePosixPath(repository).parts, commit, *PurePosixPath(path).parts)


def read_manifest(collection: Collection) -> dict[str, Any]:
    path = collection.manifest_path
    if not path.is_file():
        raise DatasetError(f"{collection.name}: {path.name} is missing; run fetch")
    manifest = json.loads(path.read_text(encoding="utf-8"))
    if manifest.get("schema_version") != SCHEMA_VERSION:
        raise DatasetError(
            f"{collection.name}: manifest schema_version must be {SCHEMA_VERSION!r}, "
            f"got {manifest.get('schema_version')!r}; rerun fetch"
        )
    return manifest


def write_manifest(path: Path, manifest: dict[str, Any]) -> None:
    path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def sources_by_key(manifest: dict[str, Any]) -> dict[tuple[str, str, str], dict[str, Any]]:
    """Fetched sources keyed by ``(repository, source_path, commit)``."""
    fetched: dict[tuple[str, str, str], dict[str, Any]] = {}
    for source in manifest["sources"]:
        key = (source["repository"], source["source_path"], source["commit"])
        if key in fetched:
            raise DatasetError(f"manifest lists {key} twice")
        fetched[key] = source
    return fetched


def unavailable_keys(manifest: dict[str, Any]) -> set[tuple[str, str, str]]:
    return {
        (item["repository"], item["source_path"], item["commit"])
        for item in manifest["unavailable"]
    }
