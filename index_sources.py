#!/usr/bin/env python3
"""Index fetched audited sources in ``audited-sources/manifest.json``.

For every fetched file the manifest gains ``units``: the top-level Solidity
declarations of the file (contracts, abstract contracts, interfaces, libraries),
or the file's basename for non-Solidity files. ``sha256`` is (re)defined as the
hash of the file as stored, i.e. after ``format_sources.py`` ran; ``git_object``
remains the upstream provenance. Missing files are reported and fail the run.

Consumers use ``units`` to find which collections declare a unit name without
opening thousands of files, and ``sha256`` as a cache key for parsed units.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path, PurePosixPath

from normalize import discover_collections, resolve_collection, NormalizeError

MANIFEST_SCHEMA_VERSION = "1.1.0"

# Formatted Solidity puts top-level declarations at column zero.
UNIT_RE = re.compile(
    r"^(?:abstract\s+contract|contract|interface|library)\s+([A-Za-z_$][A-Za-z0-9_$]*)",
    re.M,
)


def solidity_units(text: str) -> list[str]:
    seen: list[str] = []
    for name in UNIT_RE.findall(strip_comments(text)):
        if name not in seen:
            seen.append(name)
    return seen


def strip_comments(text: str) -> str:
    """Remove comments so commented-out declarations are not indexed."""
    out: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if ch in "\"'":
            quote = ch
            j = i + 1
            while j < n and text[j] != quote:
                j += 2 if text[j] == "\\" else 1
            out.append(text[i : j + 1])
            i = j + 1
        elif ch == "/" and nxt == "/":
            j = text.find("\n", i)
            i = n if j == -1 else j
        elif ch == "/" and nxt == "*":
            j = text.find("*/", i + 2)
            # keep newlines so the ^ anchor still works
            out.append("\n" * text.count("\n", i, n if j == -1 else j + 2))
            i = n if j == -1 else j + 2
        else:
            out.append(ch)
            i += 1
    return "".join(out)


def index_collection(collection_dir: Path) -> tuple[int, list[str]]:
    manifest_path = collection_dir / "audited-sources" / "manifest.json"
    if not manifest_path.is_file():
        return 0, []
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    sources_dir = manifest_path.parent
    problems: list[str] = []
    count = 0
    for source in manifest.get("sources", []):
        for record in source.get("files", []):
            path = sources_dir.joinpath(*PurePosixPath(record["file"]).parts)
            if not path.is_file():
                problems.append(f"missing file {record['file']}")
                continue
            data = path.read_bytes()
            record["sha256"] = hashlib.sha256(data).hexdigest()
            if path.suffix == ".sol":
                record["units"] = solidity_units(data.decode("utf-8", errors="replace"))
            else:
                record["units"] = [path.name]
            count += 1
    manifest["schema_version"] = MANIFEST_SCHEMA_VERSION
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    return count, problems


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("collections", nargs="*", metavar="COLLECTION")
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--dataset-root", type=Path,
                        default=Path(__file__).resolve().parent)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = args.dataset_root.resolve()
    try:
        if args.all:
            collections = discover_collections(root)
        elif args.collections:
            collections = [resolve_collection(root, name) for name in args.collections]
        else:
            print("error: pass collection names or --all", file=sys.stderr)
            return 2
    except NormalizeError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    status = 0
    for collection in collections:
        count, problems = index_collection(collection)
        print(f"{collection.relative_to(root)}: {count} files indexed, {len(problems)} problems")
        for problem in problems:
            print(f"  {problem}", file=sys.stderr)
            status = 1
    return status


if __name__ == "__main__":
    raise SystemExit(main())
