#!/usr/bin/env python3
"""Render relevant audit sources and descriptions of all audit reports."""

from __future__ import annotations

import argparse
import heapq
import html
import json
import os
import subprocess
import sys
import tempfile
from collections import defaultdict
from datetime import date
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
            "Generate audit-summary.md from audit-summary.json, resolving commit "
            "dates from the source repositories."
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


GIT_ENVIRONMENT = {**os.environ, "GIT_TERMINAL_PROMPT": "0"}


class GitCommandError(SummaryError):
    """A Git command exited unsuccessfully."""


def run_git(repository: Path | None, *args: str) -> str:
    command = ["git"]
    if repository is not None:
        command.extend(["-C", str(repository)])
    command.extend(args)
    try:
        completed = subprocess.run(
            command,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=GIT_ENVIRONMENT,
        )
    except FileNotFoundError as error:
        raise SummaryError("git executable was not found") from error
    except subprocess.CalledProcessError as error:
        raise GitCommandError(
            f"{' '.join(command)} failed: {error.stderr.strip()}"
        ) from error
    return completed.stdout.strip()


def warn(message: str) -> None:
    print(f"warning: {message}", file=sys.stderr)


def report_is_relevant(report: dict[str, Any]) -> bool:
    """Return report relevance, treating pre-1.1 summaries as relevant."""
    value = report.get("isRelevant", True)
    if not isinstance(value, bool):
        raise SummaryError("report isRelevant must be a boolean")
    return value


def repository_reachable(url: str) -> bool:
    try:
        run_git(None, "ls-remote", "--exit-code", url, "HEAD")
    except GitCommandError:
        return False
    return True


def fetch_commits(repository: Path, commits: list[str]) -> list[str]:
    """Fetch commit objects only, returning the commits that could not be fetched.

    ``--filter=tree:0`` restricts the download to the commit objects themselves,
    which is all that is needed to read committer dates. Every commit of a
    repository is requested in a single fetch; only if that fails are commits
    fetched one at a time so the missing ones can be identified.
    """
    fetch_args = ["fetch", "--quiet", "--no-tags", "--depth=1", "--filter=tree:0"]
    try:
        run_git(repository, *fetch_args, "origin", *commits)
    except GitCommandError:
        pass
    else:
        return []
    missing: list[str] = []
    for commit in commits:
        try:
            run_git(repository, *fetch_args, "origin", commit)
        except GitCommandError as error:
            warn(str(error))
            missing.append(commit)
    return missing


def committer_dates(repository: Path, commits: list[str]) -> dict[str, date]:
    output = run_git(
        repository,
        "log",
        "--no-walk=unsorted",
        "--format=%H %cI",
        *commits,
    )
    result: dict[str, date] = {}
    for line in output.splitlines():
        commit, _, committed_at = line.partition(" ")
        try:
            result[commit] = date.fromisoformat(committed_at[:10])
        except ValueError as error:
            raise SummaryError(
                f"invalid commit date for {commit}: {committed_at!r}"
            ) from error
    return result


def revision_commits(revision: dict[str, Any]) -> list[str]:
    commit = revision.get("commit")
    if isinstance(commit, str) and commit:
        return [commit]
    if revision.get("kind") == "commit_range":
        return [
            value
            for key in ("start_commit", "end_commit")
            if isinstance((value := revision.get(key)), str) and value
        ]
    return []


def resolve_commit_dates(
    summary: dict[str, Any],
) -> tuple[dict[CommitDateKey, date], dict[str, str]]:
    """Resolve committer dates for every referenced commit.

    Returns the dates and, for repositories whose dates could not be resolved,
    a mapping from repository id to the reason. Unreachable repositories (for
    example private ones) are skipped with a warning instead of aborting.
    """
    repositories: dict[str, tuple[str, set[str]]] = {}
    for report in summary["reports"]:
        if not isinstance(report, dict):
            raise SummaryError("each report must be an object")
        if not report_is_relevant(report):
            continue
        report_repositories = {
            repository["id"]: repository["url"]
            for repository in report.get("repositories", [])
        }
        for scope in report.get("scopes", []):
            repository_id = scope["repository"]
            url = report_repositories[repository_id]
            stored_url, commits = repositories.setdefault(repository_id, (url, set()))
            if stored_url != url:
                raise SummaryError(
                    f"repository {repository_id!r} has conflicting URLs"
                )
            for path_data in scope.get("paths", {}).values():
                for version in path_data.get("versions", []):
                    commits.update(revision_commits(version["revision"]))

    result: dict[CommitDateKey, date] = {}
    unresolved: dict[str, str] = {}
    with tempfile.TemporaryDirectory(prefix="audit-summary-dates-") as temporary:
        temporary_root = Path(temporary)
        for index, (repository_id, (url, commits)) in enumerate(repositories.items()):
            if not commits:
                continue
            object_id_lengths = {len(commit) for commit in commits}
            if len(object_id_lengths) != 1:
                raise SummaryError(
                    f"repository {repository_id!r} mixes Git object formats"
                )
            if not repository_reachable(url):
                reason = f"repository {url} is not reachable"
                warn(f"{reason}; commit dates for {repository_id!r} will be omitted")
                unresolved[repository_id] = reason
                continue
            repository = temporary_root / f"repository-{index}.git"
            init_args = ["init", "--bare", "--quiet"]
            if object_id_lengths == {64}:
                init_args.append("--object-format=sha256")
            init_args.append(str(repository))
            try:
                run_git(None, *init_args)
            except SummaryError as error:
                raise SummaryError(f"could not initialize Git repository: {error}") from error
            run_git(repository, "remote", "add", "origin", url)
            ordered = sorted(commits)
            missing = set(fetch_commits(repository, ordered))
            fetched = [commit for commit in ordered if commit not in missing]
            if missing:
                unresolved[repository_id] = (
                    f"{len(missing)} commit(s) could not be fetched from {url}"
                )
            if not fetched:
                continue
            dates = committer_dates(repository, fetched)
            for commit in fetched:
                if commit not in dates:
                    raise SummaryError(
                        f"no commit date returned for {repository_id}@{commit}"
                    )
                result[(repository_id, commit)] = dates[commit]
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
        "Commit dates use Git committer timestamps.",
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
