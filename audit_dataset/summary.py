"""``audit-summary.json``: the schema, its validation, and shared readers.

The schema is documented for the extraction agent in ``skills/audit-extract``.
Every check that a consumer relies on lives here, once: canonical repository
ids, scope paths, path kinds, revisions, statuses, major finding ids, report
metadata, report files and commit timestamps.
"""

from __future__ import annotations

import json
from collections.abc import Iterator
from datetime import date, datetime, timedelta
from pathlib import Path, PurePosixPath
from typing import Any

from . import DatasetError
from .collections import Collection
from .git import FULL_COMMIT_RE, full_commit
from .repositories import canonical_repository_id

SCHEMA_VERSION = "1.6.0"

# What kind of code a scoped path holds. Only `evm` is fetched and exported today.
KINDS = frozenset({"evm", "zk", "cairo", "other"})

STATUSES_WITH_MAJOR_FINDINGS = frozenset({
    "audited_with_major_findings",
    "partially_audited_with_major_findings",
})
STATUSES = STATUSES_WITH_MAJOR_FINDINGS | {
    "audited_with_no_major_findings",
    "not_audited",
    "partially_audited_without_major_findings",
}
PATH_KINDS = frozenset({"file", "directory_recursive"})

REPORT_KEYS = frozenset({
    "id", "report_file", "title", "description", "isRelevant", "auditor",
    "report_date", "repositories", "scopes",
})
VERSION_KEYS = frozenset({"revision", "status", "major_finding_ids"})
# Keys of a revision by kind, with the ones that may be left out.
REVISION_KEYS: dict[str, frozenset[str]] = {
    "commit": frozenset({"kind", "commit", "timestamp", "url"}),
    "tag": frozenset({"kind", "tag", "commit", "timestamp", "url"}),
    "commit_range": frozenset({
        "kind", "start_commit", "start_timestamp", "end_commit", "end_timestamp", "url",
    }),
    "pull_request": frozenset({"kind", "value", "commit", "timestamp", "url"}),
    "branch": frozenset({"kind", "ref", "commit", "timestamp", "immutable", "url"}),
}
OPTIONAL_REVISION_KEYS = frozenset({"url"})


class SummaryError(DatasetError):
    """The summary breaks the schema."""


# --- Reading ------------------------------------------------------------------


def read_summary(collection: Collection) -> dict[str, Any]:
    """The validated summary of a collection."""
    path = collection.summary_path
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise SummaryError(f"could not read {path}: {error}") from error
    problems = validate(value, collection.reports_dir)
    if problems:
        shown = "\n  ".join(problems[:20])
        more = f"\n  ... and {len(problems) - 20} more" if len(problems) > 20 else ""
        raise SummaryError(f"{collection.name}/{path.name}:\n  {shown}{more}")
    return value


def write_summary(path: Path, summary: dict[str, Any]) -> None:
    path.write_text(json.dumps(summary, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def relevant_versions(summary: dict[str, Any]) -> Iterator[tuple[dict[str, Any], str, str, dict[str, Any], int, dict[str, Any]]]:
    """``(report, repository, path, path entry, version index, version)`` of relevant reports.

    The path entry carries ``path_kind`` and ``kind``.
    """
    for report in summary["reports"]:
        if not report["isRelevant"]:
            continue
        for scope in report["scopes"]:
            for path, path_data in scope["paths"].items():
                for index, version in enumerate(path_data["versions"]):
                    yield report, scope["repository"], path, path_data, index, version


def revision_timestamps(revision: dict[str, Any]) -> list[tuple[str, Any]]:
    """``(commit, timestamp)`` pairs a revision carries."""
    if revision.get("kind") == "commit_range":
        pairs = (("start_commit", "start_timestamp"), ("end_commit", "end_timestamp"))
    else:
        pairs = (("commit", "timestamp"),)
    return [
        (commit, revision.get(timestamp_key))
        for commit_key, timestamp_key in pairs
        if isinstance((commit := revision.get(commit_key)), str) and commit
    ]


def parse_timestamp(value: Any) -> int:
    """An ISO 8601 UTC committer date with whole seconds, as unix seconds."""
    if not isinstance(value, str):
        raise SummaryError(f"timestamp must be a string, got {value!r}")
    try:
        parsed = datetime.fromisoformat(value)
    except ValueError as error:
        raise SummaryError(f"invalid timestamp {value!r}") from error
    if parsed.utcoffset() != timedelta(0):
        raise SummaryError(f"timestamp {value!r} is not UTC")
    if parsed.microsecond != 0:
        raise SummaryError(f"timestamp {value!r} is not a whole second")
    seconds = int(parsed.timestamp())
    if seconds <= 0:
        raise SummaryError(f"timestamp {value!r} is before 1970")
    return seconds


def commit_timestamps(summary: dict[str, Any]) -> dict[tuple[str, str], int | None]:
    """``{(repository, commit): unix seconds or None}`` over the relevant versions.

    ``validate`` already rejected conflicting timestamps for one commit.
    """
    result: dict[tuple[str, str], int | None] = {}
    for _, repository, _, _, _, version in relevant_versions(summary):
        for commit, timestamp in revision_timestamps(version["revision"]):
            key = (repository, commit.lower())
            result[key] = None if timestamp is None else parse_timestamp(timestamp)
    return result


# --- Validation ---------------------------------------------------------------


def path_problem(path: Any) -> str | None:
    """Why ``path`` is not a plain POSIX path relative to a repository root."""
    if not isinstance(path, str) or not path:
        return "must be a non-empty string"
    if "\\" in path:
        return "must use '/' separators"
    if path.startswith("/") or path.endswith("/"):
        return "must not start or end with '/'"
    if any(part in {"", ".", ".."} for part in path.split("/")):
        return "must not contain empty, '.' or '..' segments"
    return None


def validate(summary: Any, reports_dir: Path) -> list[str]:
    """Every problem with a summary, as human readable strings."""
    if not isinstance(summary, dict):
        return ["summary must be a JSON object"]
    if summary.get("schema_version") != SCHEMA_VERSION:
        return [f"schema_version must be {SCHEMA_VERSION!r}, got {summary.get('schema_version')!r}"]
    if not isinstance(summary.get("project"), str) or not summary["project"].strip():
        return ["project must be a non-empty string"]
    if not isinstance(summary.get("reports"), list):
        return ["reports must be an array"]
    if set(summary) != {"schema_version", "project", "reports"}:
        return [f"summary keys must be schema_version, project, reports; got {sorted(summary)}"]
    problems: list[str] = []
    report_ids: set[str] = set()
    timestamps: dict[tuple[str, str], Any] = {}
    for index, report in enumerate(summary["reports"]):
        if not isinstance(report, dict) or not isinstance(report.get("id"), str) or not report["id"]:
            problems.append(f"reports[{index}] must be an object with a non-empty id")
            continue
        where = f"report {report['id']!r}"
        if report["id"] in report_ids:
            problems.append(f"{where}: duplicate id")
        report_ids.add(report["id"])
        problems.extend(f"{where}: {problem}" for problem in report_problems(report, reports_dir, timestamps))
    return problems


def report_problems(
    report: dict[str, Any], reports_dir: Path, timestamps: dict[tuple[str, str], Any]
) -> list[str]:
    problems: list[str] = []
    unexpected = set(report) - REPORT_KEYS
    if unexpected:
        problems.append(f"unexpected keys {sorted(unexpected)}")
    for key in ("title", "auditor", "description"):
        if not isinstance(report.get(key), str) or not report[key].strip():
            problems.append(f"{key} must be a non-empty string")
    report_date = report.get("report_date")
    if report_date is not None and not valid_date(report_date):
        problems.append(f"report_date must be null or YYYY-MM-DD, got {report_date!r}")
    if not isinstance(report.get("isRelevant"), bool):
        problems.append("isRelevant must be a boolean")
    problems.extend(report_file_problems(report.get("report_file"), reports_dir))

    repositories = report.get("repositories")
    known: set[str] = set()
    if not isinstance(repositories, list):
        problems.append("repositories must be an array")
    else:
        for repository in repositories:
            problems.extend(repository_problems(repository, known))

    scopes = report.get("scopes")
    if not isinstance(scopes, list):
        return problems + ["scopes must be an array"]
    if report.get("isRelevant") is False and scopes:
        problems.append("an irrelevant report must have empty scopes")
    for scope in scopes:
        if not isinstance(scope, dict) or set(scope) != {"repository", "paths"}:
            problems.append("each scope must be an object with repository and paths")
            continue
        repository = scope["repository"]
        if repository not in known:
            problems.append(f"scope references unknown repository {repository!r}")
        if not isinstance(scope["paths"], dict):
            problems.append(f"scope paths of {repository!r} must be an object")
            continue
        for path, path_data in scope["paths"].items():
            prefix = f"{repository}:{path}"
            problem = path_problem(path)
            if problem is not None:
                problems.append(f"{prefix}: path {problem}")
            problems.extend(
                f"{prefix}: {problem}"
                for problem in path_entry_problems(path_data, repository, timestamps)
            )
    return problems


def valid_date(value: Any) -> bool:
    if not isinstance(value, str):
        return False
    try:
        return date.fromisoformat(value).isoformat() == value
    except ValueError:
        return False


def report_file_problems(report_file: Any, reports_dir: Path) -> list[str]:
    if not isinstance(report_file, str) or not report_file:
        return ["report_file must be a non-empty string"]
    if "\\" in report_file:
        return ["report_file must use '/' separators"]
    path = PurePosixPath(report_file)
    if path.is_absolute() or any(part in {"", ".", ".."} for part in path.parts):
        return [f"unsafe report_file {report_file!r}"]
    if path.suffix != ".md":
        return [f"report_file must be the Markdown report, got {report_file!r}"]
    if not reports_dir.joinpath(*path.parts).is_file():
        return [f"report_file {report_file!r} does not exist"]
    return []


def repository_problems(repository: Any, known: set[str]) -> list[str]:
    if (
        not isinstance(repository, dict)
        or set(repository) != {"id", "url"}
        or not isinstance(repository["id"], str)
        or not isinstance(repository["url"], str)
    ):
        return ["each repository must be an object with id and url"]
    known.add(repository["id"])
    try:
        canonical = canonical_repository_id(repository["url"])
    except DatasetError as error:
        return [str(error)]
    if canonical != repository["id"]:
        return [f"repository id {repository['id']!r} must be {canonical!r} (derived from {repository['url']})"]
    return []


def path_entry_problems(
    path_data: Any, repository: str, timestamps: dict[tuple[str, str], Any]
) -> list[str]:
    if not isinstance(path_data, dict) or set(path_data) != {"path_kind", "kind", "versions"}:
        return ["path entry must be an object with path_kind, kind and versions"]
    problems: list[str] = []
    if path_data["path_kind"] not in PATH_KINDS:
        problems.append(f"path_kind must be one of {sorted(PATH_KINDS)}")
    if path_data["kind"] not in KINDS:
        problems.append(f"kind must be one of {sorted(KINDS)}, got {path_data['kind']!r}")
    versions = path_data["versions"]
    if not isinstance(versions, list) or not versions:
        return problems + ["versions must be a non-empty array"]
    for index, version in enumerate(versions):
        problems.extend(
            f"version {index}: {problem}"
            for problem in version_problems(version, repository, timestamps)
        )
    return problems


def version_problems(
    version: Any, repository: str, timestamps: dict[tuple[str, str], Any]
) -> list[str]:
    if not isinstance(version, dict) or not isinstance(version.get("revision"), dict):
        return ["must be an object with a revision object"]
    problems: list[str] = []
    unexpected = set(version) - VERSION_KEYS
    if unexpected:
        problems.append(f"unexpected keys {sorted(unexpected)}")
    status = version.get("status")
    if status not in STATUSES:
        problems.append(f"unknown status {status!r}")
    finding_ids = version.get("major_finding_ids")
    if status in STATUSES_WITH_MAJOR_FINDINGS:
        if (
            not isinstance(finding_ids, list)
            or not finding_ids
            or not all(isinstance(finding_id, str) and finding_id for finding_id in finding_ids)
            or len(set(finding_ids)) != len(finding_ids)
        ):
            problems.append(f"status {status} requires major_finding_ids: unique non-empty strings")
    elif "major_finding_ids" in version:
        problems.append(f"status {status} must not carry major_finding_ids")
    problems.extend(revision_problems(version["revision"], repository, timestamps))
    return problems


def revision_problems(
    revision: dict[str, Any], repository: str, timestamps: dict[tuple[str, str], Any]
) -> list[str]:
    kind = revision.get("kind")
    if kind not in REVISION_KEYS:
        return [f"unknown revision kind {kind!r}"]
    problems: list[str] = []
    expected = REVISION_KEYS[kind]
    missing = expected - OPTIONAL_REVISION_KEYS - set(revision)
    unexpected = set(revision) - expected
    if missing or unexpected:
        problems.append(
            f"{kind} revision keys: missing {sorted(missing)}, unexpected {sorted(unexpected)}"
        )
    if kind == "branch" and revision.get("commit") is not None:
        problems.append("a branch revision has commit null")
    if "url" in revision and (not isinstance(revision["url"], str) or not revision["url"]):
        problems.append("url must be a non-empty string")
    for commit, timestamp in revision_timestamps(revision):
        if not isinstance(commit, str) or not commit:
            problems.append("commit must be a non-empty string or null")
            continue
        if timestamp is not None:
            try:
                parsed: Any = parse_timestamp(timestamp)
            except SummaryError as error:
                problems.append(str(error))
                continue
            if FULL_COMMIT_RE.fullmatch(commit):
                key = (repository, commit.lower())
                if timestamps.setdefault(key, parsed) != parsed:
                    problems.append(f"conflicting timestamps for {repository}@{commit}")
    for key in ("commit", "start_commit", "end_commit"):
        value = revision.get(key)
        if value is not None and (not isinstance(value, str) or not value):
            problems.append(f"{key} must be a non-empty string or null")
    if kind == "commit_range" and full_commit(revision) is not None:
        problems.append("a commit_range cannot pin one commit")
    return problems
