"""Run every post-extraction step for one collection, in order."""

from __future__ import annotations

from pathlib import Path

from .collections import Collection, discover
from .export import export_dataset
from .fetch import fetch_collection
from .format import format_collections
from .index import index_collection
from .render import render_collection
from .repositories import update_registry
from . import DatasetError


def run_pipeline(root: Path, collection: Collection, lookup: bool, forge: str) -> None:
    print(f"== render {collection.name}")
    render_collection(collection)
    print(f"== fetch {collection.name}")
    result = fetch_collection(collection)
    for warning in result.warnings:
        print(f"warning: {warning}")
    print(f"{result.sources} sources, {result.files} files; skipped {result.skipped}, "
          f"unavailable {result.unavailable}, omitted files {result.omitted}")
    print(f"== format {collection.name}")
    _, _, failed = format_collections(root, [collection], forge, check=False)
    if failed:
        raise DatasetError(f"{failed} Solidity file(s) could not be parsed by forge fmt")
    print(f"== index {collection.name}")
    count, problems = index_collection(collection)
    if problems:
        raise DatasetError("index problems:\n  " + "\n  ".join(problems))
    print(f"{count} files indexed")
    print("== repositories")
    path, repositories, forks, warnings = update_registry(root, discover(root), lookup)
    for warning in warnings:
        print(f"warning: {warning}")
    print(f"wrote {path.name}: {repositories} repositories, {forks} with fork_of")
    print("== export")
    export_dataset(root, check=False)
