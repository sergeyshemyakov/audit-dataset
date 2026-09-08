#!/usr/bin/env python3
"""Render relevant audit sources and descriptions of all audit reports."""

from __future__ import annotations

import argparse
import heapq
import html
import json
import sys
from collections import defaultdict
from datetime import date, datetime
from pathlib import Path, PurePosixPath
from typing import Any


class SummaryError(RuntimeError):
    """The input cannot be rendered as an audit summary."""


RevisionKey = tuple[str, ...]
CommitDateKey = tuple[str, str]

MONTHS = (
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Generate audit-summary.md from audit-summary.json, using the commit "
            "timestamps stored in the summary."
        )
    )
    parser.add_argument("summary", type=Path, help="path to audit-summary.json")
    parser.add_argument(
        "--output",
        type=Path,
        help="output path (default: audit-summary.md beside the input file)",
    )
    return parser.parse_args()


def read_summary(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise SummaryError(f"could not read {path}: {error}") from error
    if not isinstance(value, dict) or not isinstance(value.get("reports"), list):
        raise SummaryError("summary must be an object containing a reports array")
    return value


def warn(message: str) -> None:
    print(f"warning: {message}", file=sys.stderr)


def report_is_relevant(report: dict[str, Any]) -> bool:
    """Return report relevance, treating pre-1.1 summaries as relevant."""
    value = report.get("isRelevant", True)
    if not isinstance(value, bool):
        raise SummaryError("report isRelevant must be a boolean")
    return value


def revision_commits(revision: dict[str, Any]) -> list[str]:
    return [commit for commit, _ in revision_timestamps(revision)]


def revision_timestamps(revision: dict[str, Any]) -> list[tuple[str, Any]]:
    """Return ``(commit, timestamp)`` pairs stored in a revision.

    Since schema 1.2.0 every revision carries the committer timestamp of its
    commit(s): ``timestamp`` beside ``commit``, or ``start_timestamp`` and
    ``end_timestamp`` beside the commits of a ``commit_range``.
    """
    if revision.get("kind") == "commit_range":
        pairs = (("start_commit", "start_timestamp"), ("end_commit", "end_timestamp"))
    else:
        pairs = (("commit", "timestamp"),)
    return [
        (value, revision.get(timestamp_key))
        for commit_key, timestamp_key in pairs
        if isinstance((value := revision.get(commit_key)), str) and value
    ]


def parse_timestamp(commit: str, timestamp: Any) -> date:
    if not isinstance(timestamp, str):
        raise SummaryError(f"timestamp for {commit} must be a string")
    try:
        return datetime.fromisoformat(timestamp.replace("Z", "+00:00")).date()
    except ValueError as error:
        raise SummaryError(f"invalid timestamp for {commit}: {timestamp!r}") from error


def resolve_commit_dates(
    summary: dict[str, Any],
) -> tuple[dict[CommitDateKey, date], dict[str, str]]:
    """Collect committer dates from the timestamps stored in the summary.

    Returns the dates and, for repositories with commits that have no
    timestamp, a mapping from repository id to the reason. Missing timestamps
    are reported with a warning instead of aborting.
    """
    result: dict[CommitDateKey, date] = {}
    missing: dict[str, set[str]] = defaultdict(set)
    for report in summary["reports"]:
        if not isinstance(report, dict):
            raise SummaryError("each report must be an object")
        if not report_is_relevant(report):
            continue
        for scope in report.get("scopes", []):
            repository_id = scope["repository"]
            for path_data in scope.get("paths", {}).values():
                for version in path_data.get("versions", []):
                    for commit, timestamp in revision_timestamps(version["revision"]):
                        if timestamp is None:
                            missing[repository_id].add(commit)
                            continue
                        parsed = parse_timestamp(commit, timestamp)
                        key = (repository_id, commit)
                        if result.setdefault(key, parsed) != parsed:
                            raise SummaryError(
                                f"conflicting timestamps for {repository_id}@{commit}"
                            )
    unresolved = {
        repository_id: f"{len(commits)} commit(s) have no timestamp"
        for repository_id, commits in missing.items()
    }
    for repository_id, reason in unresolved.items():
        warn(f"{reason} in {repository_id!r}; their commit dates will be omitted")
    return result, unresolved


def revision_key(revision: dict[str, Any]) -> RevisionKey:
    commit = revision.get("commit")
    if isinstance(commit, str) and commit:
        return ("commit", commit)

    kind = revision.get("kind")
    if kind == "commit_range":
        return (
            kind,
            str(revision.get("start_commit", "")),
            str(revision.get("end_commit", "")),
        )
    if kind == "branch":
        return (kind, str(revision.get("ref", "")))
    if kind == "tag":
        return (kind, str(revision.get("tag", "")))
    if kind == "pull_request":
        return (kind, str(revision.get("value", "")))
    return (str(kind or "unknown"), json.dumps(revision, sort_keys=True))


def code(value: Any) -> str:
    return f"<code>{html.escape(str(value))}</code>"


def link(label: str, url: Any) -> str:
    if not isinstance(url, str) or not url:
        return code(label)
    return f'<a href="{html.escape(url, quote=True)}">{code(label)}</a>'


def revision_label(revision: dict[str, Any]) -> str:
    kind = revision.get("kind")
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
        mutable = "mutable " if revision.get("immutable") is False else ""
        return f"{link(str(revision.get('ref', '')), url)} ({mutable}branch)"
    if kind == "tag":
        return f"{link(str(revision.get('tag', '')), url)} (unresolved tag)"
    if kind == "pull_request":
        return f"{link(str(revision.get('value', '')), url)} (unresolved pull request)"
    return code(json.dumps(revision, sort_keys=True))


def human_date(value: date) -> str:
    return f"{MONTHS[value.month - 1]} {value.day}, {value.year}"


def revision_date(
    repository_id: str,
    revision: dict[str, Any],
    commit_dates: dict[CommitDateKey, date],
) -> str:
    commits = revision_commits(revision)
    dates = [
        commit_dates[(repository_id, commit)]
        for commit in commits
        if (repository_id, commit) in commit_dates
    ]
    if not dates:
        return "—"
    if len(dates) == 1 or dates[0] == dates[-1]:
        return human_date(dates[0])
    return f"{human_date(dates[0])} – {human_date(dates[-1])}"


def revision_sort_key(
    repository_id: str,
    revision: dict[str, Any],
    commit_dates: dict[CommitDateKey, date],
) -> tuple[int, date, date]:
    """Chronological sort key; undated revisions sort after every dated one."""
    dates = sorted(
        commit_dates[(repository_id, commit)]
        for commit in revision_commits(revision)
        if (repository_id, commit) in commit_dates
    )
    if not dates:
        return (1, date.min, date.min)
    return (0, dates[0], dates[-1])


def ordered_revisions(
    paths: list[tuple[str, dict[str, Any]]],
) -> tuple[list[RevisionKey], dict[RevisionKey, dict[str, Any]]]:
    first_seen: dict[RevisionKey, int] = {}
    revisions: dict[RevisionKey, dict[str, Any]] = {}
    edges: dict[RevisionKey, set[RevisionKey]] = defaultdict(set)
    indegree: dict[RevisionKey, int] = defaultdict(int)

    for _, path_data in paths:
        versions = path_data.get("versions", [])
        if not isinstance(versions, list):
            raise SummaryError("path versions must be an array")
        previous: RevisionKey | None = None
        for version in versions:
            if not isinstance(version, dict) or not isinstance(
                version.get("revision"), dict
            ):
                raise SummaryError("each path version must contain a revision object")
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


def render_repository(
    repository: dict[str, Any],
    scopes: list[dict[str, Any]],
    commit_dates: dict[CommitDateKey, date],
    unresolved: dict[str, str],
) -> list[str]:
    repository_id = repository.get("id")
    if not isinstance(repository_id, str) or not repository_id:
        raise SummaryError("each repository must have a non-empty id")

    paths: list[tuple[str, dict[str, Any]]] = []
    for scope in scopes:
        scope_paths = scope.get("paths")
        if not isinstance(scope_paths, dict):
            raise SummaryError(f"scope paths for {repository_id!r} must be an object")
        for path, path_data in scope_paths.items():
            if not isinstance(path, str) or not isinstance(path_data, dict):
                raise SummaryError(f"invalid path entry in {repository_id!r}")
            paths.append((path, path_data))

    order, revisions = ordered_revisions(paths)
    # The topological order above only reflects how versions are listed in the
    # JSON; re-sort so rows are always chronological by committer date. The sort
    # is stable, so revisions without a commit date keep their relative order at
    # the end of the table.
    order.sort(
        key=lambda key: revision_sort_key(
            repository_id, revisions[key], commit_dates
        )
    )
    sources: dict[RevisionKey, list[str]] = defaultdict(list)
    for path, path_data in paths:
        path_kind = path_data.get("path_kind")
        for version in path_data.get("versions", []):
            key = revision_key(version["revision"])
            item = code(path)
            if path_kind == "directory_recursive":
                item += " (recursive directory)"
            if version.get("status") == "not_audited":
                item += " (explicitly not audited)"
            if item not in sources[key]:
                sources[key].append(item)

    lines = [
        f"### Repository: {link(repository_id, repository.get('url'))}",
        "",
    ]
    if repository_id in unresolved:
        lines.extend(
            [
                f"_Commit dates unavailable: {html.escape(unresolved[repository_id])}._",
                "",
            ]
        )
    lines += [
        "| Revision | Commit date | Audited files or directories |",
        "| --- | --- | --- |",
    ]
    if not order:
        lines.append("| _None recorded_ | — | _None recorded_ |")
    for key in order:
        revision = revisions[key]
        lines.append(
            f"| {revision_label(revision)} | "
            f"{revision_date(repository_id, revision, commit_dates)} | "
            f"{'<br>'.join(sources[key])} |"
        )
    lines.append("")
    return lines


def report_link_path(report_file: str) -> str:
    if "\\" in report_file:
        raise SummaryError("report_file must use '/' separators")
    path = PurePosixPath(report_file)
    if path.is_absolute() or any(part in {"", ".", ".."} for part in path.parts):
        raise SummaryError(f"unsafe report_file: {report_file!r}")
    return (PurePosixPath("reports") / path).as_posix()


def render_report(
    report: dict[str, Any],
    heading_level: int,
    include_source_tables: bool,
    commit_dates: dict[CommitDateKey, date],
    unresolved: dict[str, str],
) -> list[str]:
    report_title = report.get("title") or report.get("id") or "Untitled report"
    lines = [f"{'#' * heading_level} {html.escape(str(report_title))}", ""]
    details = []
    report_file = report.get("report_file")
    if isinstance(report_file, str) and report_file:
        report_path = report_link_path(report_file)
        escaped_file = html.escape(report_file)
        escaped_path = html.escape(report_path)
        details.append(f"Report: [{escaped_file}](<{escaped_path}>)")
    if report.get("auditor"):
        details.append(f"Auditor: {html.escape(str(report['auditor']))}")
    if report.get("report_date"):
        details.append(f"Date: {html.escape(str(report['report_date']))}")
    description = report.get("description")
    if description is not None:
        if not isinstance(description, str) or not description.strip():
            raise SummaryError("report description must be a non-empty string")
        details.append(f"Description: {html.escape(description.strip())}")
    lines.extend([f"- {detail}" for detail in details])
    if details:
        lines.append("")

    repositories = report.get("repositories")
    scopes = report.get("scopes")
    if not isinstance(repositories, list) or not isinstance(scopes, list):
        raise SummaryError("each report must contain repositories and scopes arrays")
    if not include_source_tables:
        return lines

    scopes_by_repository: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for scope in scopes:
        if not isinstance(scope, dict) or not isinstance(scope.get("repository"), str):
            raise SummaryError("each scope must identify a repository")
        scopes_by_repository[scope["repository"]].append(scope)
    known_repositories = {
        repository.get("id")
        for repository in repositories
        if isinstance(repository, dict)
    }
    unknown = set(scopes_by_repository) - known_repositories
    if unknown:
        raise SummaryError(f"scopes reference unknown repositories: {sorted(unknown)}")
    for repository in repositories:
        if not isinstance(repository, dict):
            raise SummaryError("each repository must be an object")
        lines.extend(
            render_repository(
                repository,
                scopes_by_repository.get(repository.get("id"), []),
                commit_dates,
                unresolved,
            )
        )
    return lines


def render_summary(summary: dict[str, Any]) -> str:
    relevant_reports: list[dict[str, Any]] = []
    irrelevant_reports: list[dict[str, Any]] = []
    for report in summary["reports"]:
        if not isinstance(report, dict):
            raise SummaryError("each report must be an object")
        target = (
            relevant_reports if report_is_relevant(report) else irrelevant_reports
        )
        target.append(report)

    commit_dates, unresolved = resolve_commit_dates(summary)
    project = summary.get("project")
    title = f"Audit source summary: {project}" if project else "Audit source summary"
    lines = [
        f"# {html.escape(str(title))}",
        "",
        "Generated from [audit-summary.json](audit-summary.json). Do not edit manually.",
        "Commit dates use Git committer timestamps (UTC).",
        "",
    ]

    for report in relevant_reports:
        lines.extend(render_report(report, 2, True, commit_dates, unresolved))

    if irrelevant_reports:
        lines.extend(["## Irrelevant reports", ""])
        for report in irrelevant_reports:
            lines.extend(render_report(report, 3, False, commit_dates, unresolved))

    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    args = parse_args()
    output = args.output or args.summary.with_suffix(".md")
    try:
        summary = read_summary(args.summary)
        output.write_text(render_summary(summary), encoding="utf-8")
    except (OSError, SummaryError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    print(f"wrote {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
