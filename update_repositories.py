#!/usr/bin/env python3
"""Build ``repositories.json``: every repository referenced by any collection.

For each repository the registry stores its URL and, when GitHub reports the
repository as a fork, the canonical id of its parent under ``fork_of``. Lineage is
a property of a repository, not of a report, which is why it lives here and not in
the per-collection summaries. Parents appear in the registry even when no
collection references them, so a consumer can warn about a missing upstream
collection.

Entries marked ``"manual": true`` are preserved across regenerations. Use them for
copies that are forks in substance but not on GitHub.

Requires the authenticated GitHub CLI (``gh``) for GitHub repositories.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

from normalize import (
    NormalizeError,
    canonical_repository_id,
    discover_collections,
    repository_ids,
)

REGISTRY_SCHEMA_VERSION = "1.0.0"


def load_registry(path: Path) -> dict[str, dict[str, Any]]:
    if not path.is_file():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    repositories = data.get("repositories", {})
    return repositories if isinstance(repositories, dict) else {}


def github_parent(repository_id: str) -> tuple[str | None, str | None]:
    """Return ``(parent id, error)`` for a GitHub repository id ``owner/repo``."""
    try:
        result = subprocess.run(
            ["gh", "api", f"repos/{repository_id}", "--jq",
             '{fork: .fork, parent: (.parent.html_url // "")}'],
            capture_output=True, text=True, check=False,
        )
    except FileNotFoundError:
        return None, "gh not found"
    if result.returncode != 0:
        return None, result.stderr.strip().splitlines()[-1] if result.stderr.strip() else "gh api failed"
    payload = json.loads(result.stdout)
    if payload.get("fork") and payload.get("parent"):
        return canonical_repository_id(payload["parent"]), None
    return None, None


def is_github(repository_id: str) -> bool:
    return repository_id.count("/") == 1 and not repository_id.startswith("gist/")


def collect_referenced(dataset_root: Path) -> dict[str, str]:
    referenced: dict[str, str] = {}
    for collection in discover_collections(dataset_root):
        summary = json.loads((collection / "audit-summary.json").read_text(encoding="utf-8"))
        for repository_id, url in repository_ids(summary).items():
            canonical = canonical_repository_id(url)
            if canonical != repository_id:
                raise NormalizeError(
                    f"{collection.name}: repository id {repository_id!r} is not canonical "
                    f"({canonical!r}); run normalize.py --migrate first"
                )
            referenced.setdefault(canonical, url.strip())
    return referenced


def build_registry(
    referenced: dict[str, str],
    previous: dict[str, dict[str, Any]],
    lookup: bool,
) -> tuple[dict[str, dict[str, Any]], list[str]]:
    registry: dict[str, dict[str, Any]] = {}
    warnings: list[str] = []
    queue = sorted(referenced)
    seen: set[str] = set()
    while queue:
        repository_id = queue.pop(0)
        if repository_id in seen:
            continue
        seen.add(repository_id)
        old = previous.get(repository_id, {})
        url = referenced.get(repository_id) or old.get("url") or github_url(repository_id)
        entry: dict[str, Any] = {"url": url}
        if old.get("manual"):
            entry = dict(old)
        elif lookup and is_github(repository_id):
            parent, error = github_parent(repository_id)
            if error:
                warnings.append(f"{repository_id}: {error}")
                if "fork_of" in old:
                    entry["fork_of"] = old["fork_of"]
            elif parent:
                entry["fork_of"] = parent
        elif "fork_of" in old:
            entry["fork_of"] = old["fork_of"]
        registry[repository_id] = entry
        parent = entry.get("fork_of")
        if parent and parent not in seen:
            queue.append(parent)
    # Manual entries that are no longer referenced are kept as well.
    for repository_id, old in previous.items():
        if old.get("manual") and repository_id not in registry:
            registry[repository_id] = dict(old)
    return dict(sorted(registry.items())), warnings


def github_url(repository_id: str) -> str:
    return f"https://github.com/{repository_id}"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--dataset-root", type=Path,
                        default=Path(__file__).resolve().parent)
    parser.add_argument("--no-lookup", action="store_true",
                        help="do not query GitHub; keep previously known lineage")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = args.dataset_root.resolve()
    path = root / "repositories.json"
    try:
        referenced = collect_referenced(root)
    except NormalizeError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    registry, warnings = build_registry(referenced, load_registry(path), not args.no_lookup)
    path.write_text(
        json.dumps({"schema_version": REGISTRY_SCHEMA_VERSION, "repositories": registry},
                   indent=2) + "\n",
        encoding="utf-8",
    )
    forks = sum(1 for entry in registry.values() if entry.get("fork_of"))
    print(f"wrote {path}: {len(registry)} repositories, {forks} with fork_of")
    for warning in warnings:
        print(f"warning: {warning}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
