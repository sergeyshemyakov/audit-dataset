#!/usr/bin/env python3
"""Run the post-extraction pipeline for one collection.

After ``audit-summary.json`` exists (see AUDIT_EXTRACT_SKILL.md) this runs, in
order: ``generate_audit_summary.py`` (validation and the Markdown rendering),
``fetch_audited_sources.py``, ``format_sources.py``, ``index_sources.py`` and
``update_repositories.py``.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from normalize import NormalizeError, resolve_collection


def run(step: list[str]) -> int:
    print(f"$ {' '.join(step)}")
    return subprocess.run(step).returncode


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("collection", help="project directory name, e.g. tornado-cash")
    parser.add_argument("--dataset-root", type=Path,
                        default=Path(__file__).resolve().parent)
    parser.add_argument("--no-lookup", action="store_true",
                        help="skip GitHub lineage lookups in update_repositories.py")
    args = parser.parse_args()
    root = args.dataset_root.resolve()
    try:
        collection = resolve_collection(root, args.collection)
    except NormalizeError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    rel = collection.relative_to(root).as_posix()
    python = sys.executable
    steps = [
        [python, str(root / "generate_audit_summary.py"), str(collection / "audit-summary.json")],
        [python, str(root / "fetch_audited_sources.py"), str(collection / "audit-summary.json")],
        [python, str(root / "format_sources.py"), rel],
        [python, str(root / "index_sources.py"), rel],
        [python, str(root / "update_repositories.py")]
        + (["--no-lookup"] if args.no_lookup else []),
    ]
    for step in steps:
        code = run(step)
        if code != 0:
            print(f"error: step failed with exit code {code}", file=sys.stderr)
            return code
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
