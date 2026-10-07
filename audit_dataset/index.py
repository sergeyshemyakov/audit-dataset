"""Check the stored sources against the manifest and record their hashes.

``sha256`` in the manifest is the hash of every file as stored, i.e. after
formatting, so it is recorded here, after ``format``. The check also catches
what git on a case-insensitive filesystem would hide: a manifest path whose
spelling differs from the file on disk, two stored names differing only by
case, and files on disk that no manifest entry explains.
"""

from __future__ import annotations

import hashlib
import os
from pathlib import PurePosixPath

from .collections import Collection
from .manifest import read_manifest, stored_path, write_manifest


def index_collection(collection: Collection) -> tuple[int, list[str]]:
    """Rewrite the manifest hashes; returns the file count and the problems found."""
    manifest = read_manifest(collection)
    sources_dir = collection.sources_dir
    on_disk, problems = walk(sources_dir)
    listed: set[str] = set()
    count = 0
    for source in manifest["sources"]:
        for record in source["files"]:
            path = stored_path(sources_dir, source["repository"], source["commit"], record["path"])
            relative = path.relative_to(sources_dir).as_posix()
            listed.add(relative)
            if relative not in on_disk:
                problems.append(f"missing or differently spelled on disk: {relative}")
                continue
            record["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
            record.pop("units", None)
            count += 1
    for relative in sorted(on_disk - listed):
        if relative != collection.manifest_path.name:
            problems.append(f"stored but not in the manifest: {relative}")
    write_manifest(collection.manifest_path, manifest)
    return count, problems


def walk(sources_dir: Collection | os.PathLike[str]) -> tuple[set[str], list[str]]:
    """Every file under the tree with its exact on-disk spelling, plus case collisions."""
    files: set[str] = set()
    problems: list[str] = []
    for directory, dirnames, filenames in os.walk(sources_dir):
        dirnames.sort()
        names = sorted(dirnames + filenames)
        folded: dict[str, str] = {}
        for name in names:
            other = folded.setdefault(name.lower(), name)
            if other != name:
                relative = PurePosixPath(os.path.relpath(directory, sources_dir))
                problems.append(f"names differ only by case in {relative}: {other!r} and {name!r}")
        for name in filenames:
            files.add(PurePosixPath(os.path.relpath(os.path.join(directory, name), sources_dir)).as_posix())
    return files, problems
