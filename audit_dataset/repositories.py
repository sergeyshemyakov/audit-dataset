"""Canonical repository ids and the ``repositories.json`` registry.

A repository id is derived from its URL by one rule so that every collection
names the same repository the same way:

- GitHub repositories: ``owner/repo`` (``.git`` suffix and trailing slash stripped).
- GitHub gists: ``gist/<owner>/<id>``.
- Other hosts: ``<host>/<path>`` such as ``gitlab.com/owner/repo``.

The registry lists every repository referenced by any collection with its URL
and, when GitHub reports it as a fork, the canonical id of its parent under
``fork_of``. Lineage is a property of a repository, not of a report, which is why
it lives here and not in the summaries. Parents appear in the registry even when
no collection references them. Entries marked ``"manual": true`` are preserved
across regenerations; use them for copies that are forks in substance but not on
GitHub.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit

from . import DatasetError
from .collections import Collection

REGISTRY_NAME = "repositories.json"
REGISTRY_SCHEMA_VERSION = "1.0.0"


def canonical_repository_id(url: str) -> str:
    if not isinstance(url, str) or not url.strip():
        raise DatasetError("repository url must be a non-empty string")
    value = url.strip()
    if "://" not in value:
        value = "https://" + value
    parts = urlsplit(value)
    host = (parts.hostname or "").lower()
    if host.startswith("www."):
        host = host[4:]
    segments = [segment for segment in parts.path.split("/") if segment]
    if not segments:
        raise DatasetError(f"repository url has no path: {url!r}")
    if segments[-1].endswith(".git"):
        segments[-1] = segments[-1][: -len(".git")]
    if host == "github.com":
        if len(segments) < 2:
            raise DatasetError(f"github url must name owner and repository: {url!r}")
        return f"{segments[0]}/{segments[1]}"
    if host == "gist.github.com":
        if len(segments) < 2:
            raise DatasetError(f"gist url must name owner and id: {url!r}")
        return f"gist/{segments[0]}/{segments[1]}"
    if not host:
        raise DatasetError(f"repository url has no host: {url!r}")
    return "/".join([host, *segments])


def is_github(repository_id: str) -> bool:
    return repository_id.count("/") == 1 and not repository_id.startswith("gist/")


def github_url(repository_id: str) -> str:
    return f"https://github.com/{repository_id}"


# --- Registry -----------------------------------------------------------------


def load_registry(path: Path) -> dict[str, dict[str, Any]]:
    if not path.is_file():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    repositories = data.get("repositories", {})
    return repositories if isinstance(repositories, dict) else {}


def github_parent(repository_id: str) -> tuple[str | None, str | None]:
    """``(parent id, error)`` for a GitHub repository, via the authenticated gh CLI."""
    try:
        result = subprocess.run(
            ["gh", "api", f"repos/{repository_id}", "--jq",
             '{fork: .fork, parent: (.parent.html_url // "")}'],
            capture_output=True, text=True, check=False,
        )
    except FileNotFoundError:
        return None, "gh not found"
    if result.returncode != 0:
        lines = result.stderr.strip().splitlines()
        return None, lines[-1] if lines else "gh api failed"
    payload = json.loads(result.stdout)
    if payload.get("fork") and payload.get("parent"):
        return canonical_repository_id(payload["parent"]), None
    return None, None


def referenced_repositories(collections: list[Collection]) -> dict[str, str]:
    """``{id: url}`` over every report of every collection."""
    from .summary import read_summary

    referenced: dict[str, str] = {}
    for collection in collections:
        summary = read_summary(collection)
        for report in summary["reports"]:
            for repository in report["repositories"]:
                referenced.setdefault(repository["id"], repository["url"].strip())
    return referenced


def build_registry(
    referenced: dict[str, str], previous: dict[str, dict[str, Any]], lookup: bool,
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
    for repository_id, old in previous.items():
        if old.get("manual") and repository_id not in registry:
            registry[repository_id] = dict(old)
    return dict(sorted(registry.items())), warnings


def update_registry(
    root: Path, collections: list[Collection], lookup: bool
) -> tuple[Path, int, int, list[str]]:
    """Rebuild ``repositories.json``; returns path, repository count, fork count, warnings."""
    path = root / REGISTRY_NAME
    registry, warnings = build_registry(
        referenced_repositories(collections), load_registry(path), lookup
    )
    path.write_text(
        json.dumps({"schema_version": REGISTRY_SCHEMA_VERSION, "repositories": registry}, indent=2)
        + "\n",
        encoding="utf-8",
    )
    forks = sum(1 for entry in registry.values() if entry.get("fork_of"))
    return path, len(registry), forks, warnings
