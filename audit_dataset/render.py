"""Render ``audit-summary.md``, the human-readable view of a summary."""

from __future__ import annotations

import heapq
import html
import json
from collections import defaultdict
from datetime import date, datetime, timezone
from pathlib import PurePosixPath
from typing import Any

from .collections import Collection
from .summary import SummaryError, commit_timestamps, read_summary, revision_timestamps

RevisionKey = tuple[str, ...]
CommitDates = dict[tuple[str, str], date]

MONTHS = (
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
)


def render_collection(collection: Collection) -> None:
    """Validate the summary and write ``audit-summary.md`` beside it."""
    summary = read_summary(collection)
    collection.rendered_summary_path.write_text(render(summary), encoding="utf-8")


def render(summary: dict[str, Any]) -> str:
    relevant = [report for report in summary["reports"] if report["isRelevant"]]
    irrelevant = [report for report in summary["reports"] if not report["isRelevant"]]
    commit_dates: CommitDates = {
        key: datetime.fromtimestamp(seconds, timezone.utc).date()
        for key, seconds in commit_timestamps(summary).items()
        if seconds is not None
    }
    lines = [
        f"# Audit source summary: {html.escape(summary['project'])}",
        "",
        "Generated from [audit-summary.json](audit-summary.json). Do not edit manually.",
        "Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.",
        "",
    ]
    for report in relevant:
        lines.extend(render_report(report, 2, True, commit_dates))
    if irrelevant:
        lines.extend(["## Irrelevant reports", ""])
        for report in irrelevant:
            lines.extend(render_report(report, 3, False, commit_dates))
    return "\n".join(lines).rstrip() + "\n"


def render_report(
    report: dict[str, Any], heading_level: int, include_sources: bool, commit_dates: CommitDates
) -> list[str]:
    lines = [f"{'#' * heading_level} {html.escape(report['title'])}", ""]
    report_path = (PurePosixPath("reports") / report["report_file"]).as_posix()
    details = [
        f"Report: [{html.escape(report['report_file'])}](<{html.escape(report_path)}>)",
        f"Auditor: {html.escape(report['auditor'])}",
    ]
    if report["report_date"]:
        details.append(f"Date: {html.escape(report['report_date'])}")
    details.append(f"Description: {html.escape(report['description'].strip())}")
    lines.extend(f"- {detail}" for detail in details)
    lines.append("")
    if not include_sources:
        return lines
    scopes_by_repository: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for scope in report["scopes"]:
        scopes_by_repository[scope["repository"]].append(scope)
    for repository in report["repositories"]:
        lines.extend(render_repository(repository, scopes_by_repository.get(repository["id"], []), commit_dates))
    return lines


def render_repository(
    repository: dict[str, Any], scopes: list[dict[str, Any]], commit_dates: CommitDates
) -> list[str]:
    repository_id = repository["id"]
    paths = [(path, path_data) for scope in scopes for path, path_data in scope["paths"].items()]
    order, revisions = ordered_revisions(paths)
    # The topological order reflects how versions are listed; rows are shown
    # chronologically by committer date, undated revisions last in listed order.
    order.sort(key=lambda key: revision_sort_key(repository_id, revisions[key], commit_dates))
    sources: dict[RevisionKey, list[str]] = defaultdict(list)
    for path, path_data in paths:
        for version in path_data["versions"]:
            key = revision_key(version["revision"])
            item = code(path)
            if path_data["path_kind"] == "directory_recursive":
                item += " (recursive directory)"
            if path_data["kind"] != "evm":
                item += f" ({path_data['kind']})"
            if version["status"] == "not_audited":
                item += " (explicitly not audited)"
            if item not in sources[key]:
                sources[key].append(item)
    lines = [f"### Repository: {link(repository_id, repository['url'])}", ""]
    undated = sum(
        1 for key in order
        if not any((repository_id, commit) in commit_dates for commit, _ in revision_timestamps(revisions[key]))
        and revision_timestamps(revisions[key])
    )
    if undated:
        lines.extend([f"_Commit dates unavailable: {undated} revision(s) have no timestamp._", ""])
    lines += [
        "| Revision | Commit date | Audited files or directories |",
        "| --- | --- | --- |",
    ]
    if not order:
        lines.append("| _None recorded_ | — | _None recorded_ |")
    for key in order:
        revision = revisions[key]
        lines.append(
            f"| {revision_label(revision)} | {revision_date(repository_id, revision, commit_dates)} | "
            f"{'<br>'.join(sources[key])} |"
        )
    lines.append("")
    return lines


def ordered_revisions(
    paths: list[tuple[str, dict[str, Any]]],
) -> tuple[list[RevisionKey], dict[RevisionKey, dict[str, Any]]]:
    """Revisions in the order the paths list them, respecting every path's chain."""
    first_seen: dict[RevisionKey, int] = {}
    revisions: dict[RevisionKey, dict[str, Any]] = {}
    edges: dict[RevisionKey, set[RevisionKey]] = defaultdict(set)
    indegree: dict[RevisionKey, int] = defaultdict(int)
    for _, path_data in paths:
        previous: RevisionKey | None = None
        for version in path_data["versions"]:
            revision = version["revision"]
            key = revision_key(revision)
            if key not in first_seen:
                first_seen[key] = len(first_seen)
                revisions[key] = revision
                indegree[key] += 0
            if previous is not None and previous != key and key not in edges[previous]:
                edges[previous].add(key)
                indegree[key] += 1
            previous = key
    ready = [(first_seen[key], key) for key, degree in indegree.items() if degree == 0]
    heapq.heapify(ready)
    result: list[RevisionKey] = []
    while ready:
        _, key = heapq.heappop(ready)
        result.append(key)
        for following in sorted(edges[key], key=first_seen.__getitem__):
            indegree[following] -= 1
            if indegree[following] == 0:
                heapq.heappush(ready, (first_seen[following], following))
    if len(result) != len(first_seen):
        raise SummaryError("revision order contains a cycle")
    return result, revisions


def revision_key(revision: dict[str, Any]) -> RevisionKey:
    commit = revision.get("commit")
    if isinstance(commit, str) and commit:
        return ("commit", commit.lower())
    kind = revision["kind"]
    if kind == "commit_range":
        return (kind, str(revision.get("start_commit", "")), str(revision.get("end_commit", "")))
    if kind == "branch":
        return (kind, str(revision.get("ref", "")))
    if kind == "tag":
        return (kind, str(revision.get("tag", "")))
    if kind == "pull_request":
        return (kind, str(revision.get("value", "")))
    return (kind, json.dumps(revision, sort_keys=True))


def code(value: Any) -> str:
    return f"<code>{html.escape(str(value))}</code>"


def link(label: str, url: Any) -> str:
    if not isinstance(url, str) or not url:
        return code(label)
    return f'<a href="{html.escape(url, quote=True)}">{code(label)}</a>'


def revision_label(revision: dict[str, Any]) -> str:
    kind = revision["kind"]
    commit = revision.get("commit")
    url = revision.get("url")
    if isinstance(commit, str) and commit:
        label = link(commit, url)
        if kind == "tag":
            label += f" (tag {code(revision.get('tag', ''))})"
        elif kind == "pull_request":
            label += f" (pull request {code(revision.get('value', ''))})"
        return label
    if kind == "commit_range":
        value = f"{revision.get('start_commit', '')}…{revision.get('end_commit', '')}"
        return f"{link(value, url)} (commit range)"
    if kind == "branch":
        return f"{link(str(revision.get('ref', '')), url)} (mutable branch)"
    if kind == "tag":
        return f"{link(str(revision.get('tag', '')), url)} (unresolved tag)"
    if kind == "pull_request":
        return f"{link(str(revision.get('value', '')), url)} (unresolved pull request)"
    return code(json.dumps(revision, sort_keys=True))


def human_date(value: date) -> str:
    return f"{MONTHS[value.month - 1]} {value.day}, {value.year}"


def dates_of(repository_id: str, revision: dict[str, Any], commit_dates: CommitDates) -> list[date]:
    return [
        commit_dates[(repository_id, commit.lower())]
        for commit, _ in revision_timestamps(revision)
        if (repository_id, commit.lower()) in commit_dates
    ]


def revision_date(repository_id: str, revision: dict[str, Any], commit_dates: CommitDates) -> str:
    dates = dates_of(repository_id, revision, commit_dates)
    if not dates:
        return "—"
    if len(dates) == 1 or dates[0] == dates[-1]:
        return human_date(dates[0])
    return f"{human_date(dates[0])} – {human_date(dates[-1])}"


def revision_sort_key(
    repository_id: str, revision: dict[str, Any], commit_dates: CommitDates
) -> tuple[int, date, date]:
    dates = sorted(dates_of(repository_id, revision, commit_dates))
    if not dates:
        return (1, date.min, date.min)
    return (0, dates[0], dates[-1])
