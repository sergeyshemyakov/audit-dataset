#!/usr/bin/env python3
"""Export ``audit-index.json`` and ``audit-objects.json.zst``: the public interface.

The index says, for every repository commit pinned by an audit, which Solidity
files were audited there, by which reports, and which major findings those
reports left open in each scoped path. The bundle maps every file's object id
(the first 12 hex characters of the git blob id of its contents) to the file as
stored in ``audited-sources/``, i.e. formatted by format_sources.py.
Consumers pin both files to a dataset commit; everything else in the dataset is
internal. See the README section "Audit export" for the format and its rules.

``--check`` rebuilds the export in memory and verifies that the committed files
satisfy every rule and are byte-identical to it, without writing anything. It
also verifies, against the git index, that every file a manifest names is
committed with exactly that letter case. A normal run performs the same
validation before writing and refuses to write an invalid export.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path, PurePosixPath
from typing import Any

if sys.version_info < (3, 14):
    sys.exit("export_audit_index.py requires Python 3.14 or newer for compression.zstd")

from compression import zstd

from generate_audit_summary import SummaryError, read_summary
from normalize import discover_collections

SCHEMA_VERSION = "1.0.0"
INDEX_NAME = "audit-index.json"
OBJECTS_NAME = "audit-objects.json.zst"
OBJECT_ID_LENGTH = 12
ZSTD_LEVEL = 19
# As `zstd --long=27`: long-distance matching over a 128 MiB window, the largest
# window decoders accept without raising their limit, so `zstd -d` needs no flag.
ZSTD_WINDOW_LOG = 27
ZSTD_MAGIC = b"\x28\xb5\x2f\xfd"
# Frame_Header_Descriptor bit 2 is Content_Checksum_flag (RFC 8878, 3.1.1.1.1).
ZSTD_CHECKSUM_FLAG_BIT = 0b100

FULL_COMMIT_RE = re.compile(r"(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})\Z")
COMMIT_RE = re.compile(r"(?:[0-9a-f]{40}|[0-9a-f]{64})\Z")
OBJECT_ID_RE = re.compile(r"[0-9a-f]{12}\Z")
DATE_RE = re.compile(r"\d{4}-\d{2}-\d{2}\Z")
# Report documents are compared by their originals; native Markdown reports have none.
ORIGINAL_SUFFIXES = (".pdf", ".html", ".csv", ".js")


class ExportError(RuntimeError):
    """The dataset cannot be exported without violating a rule."""


@dataclass(frozen=True)
class AuditedFile:
    path: str  # relative to the repository root
    blob_id: str  # git blob id of the contents as stored (a symlink is stored as its target)
    stored: Path  # copy under audited-sources/


@dataclass(frozen=True)
class Audit:
    """One report's audit of one scoped path at one commit."""

    collection: str
    report_id: str
    repository: str
    commit: str
    timestamp: int
    scoped_path: str
    finding_ids: tuple[str, ...]
    files: tuple[AuditedFile, ...]
    origin: str  # which summary version produced it, for error messages


@dataclass
class ReportRecord:
    title: str
    auditor: str
    date: str | None
    relevant: bool
    document: tuple[tuple[str, str], ...]
    collections: set[str]


@dataclass
class Export:
    index: dict[str, Any]
    objects: dict[str, str]
    manifest_paths: set[str]  # dataset path of every file a manifest names, Solidity or not


def main() -> int:
    args = parse_args()
    root = args.dataset_root.resolve()
    try:
        export = build_export(root)
    except (ExportError, OSError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    index_text = serialize_index(export.index)
    objects_text = serialize_objects(export.objects)
    problems = validate_export(export.index, export.objects, index_text, objects_text)
    if not problems and args.check:
        problems = check_committed(root, export, index_text, objects_text)
    if problems:
        for problem in problems[:50]:
            print(f"error: {problem}", file=sys.stderr)
        if len(problems) > 50:
            print(f"error: ... and {len(problems) - 50} more problems", file=sys.stderr)
        return 1
    if args.check:
        print(f"{INDEX_NAME} and {OBJECTS_NAME} are valid and up to date")
    else:
        write_export(root, index_text, objects_text)
    print_statistics(export, index_text, objects_text)
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--check", action="store_true",
                        help="verify the committed files without rewriting them")
    parser.add_argument("--dataset-root", type=Path,
                        default=Path(__file__).resolve().parent)
    return parser.parse_args()


# --- Building -----------------------------------------------------------------


def build_export(root: Path) -> Export:
    collections = discover_collections(root)
    if not collections:
        raise ExportError(f"no collections in {root}")
    reports: dict[str, ReportRecord] = {}
    timestamps: dict[tuple[str, str], int | None] = {}
    audits: dict[tuple[str, str, str, str], Audit] = {}
    manifest_paths: set[str] = set()
    for collection_dir in collections:
        collection = collection_dir.relative_to(root).as_posix()
        try:
            summary = read_summary(collection_dir / "audit-summary.json")
        except SummaryError as error:
            raise ExportError(f"{collection}/audit-summary.json: {error}") from error
        record_reports(reports, collection, collection_dir / "reports", summary)
        record_timestamps(timestamps, summary)
        fetched, unavailable = read_manifest(collection_dir / "audited-sources" / "manifest.json")
        manifest_paths.update(
            f"{collection}/audited-sources/{record['file']}"
            for source in fetched.values()
            for record in source["files"]
        )
        for audit in collection_audits(
            collection, collection_dir, summary, fetched, unavailable, timestamps
        ):
            add_audit(audits, audit)
    return assemble_export(reports, audits, manifest_paths)


def record_reports(
    reports: dict[str, ReportRecord], collection: str, reports_dir: Path, summary: dict[str, Any]
) -> None:
    """Merge one collection's report metadata, rejecting an id shared by two documents."""
    for report in summary["reports"]:
        record = ReportRecord(
            title=report["title"],
            auditor=report["auditor"],
            date=report["report_date"],
            relevant=report["isRelevant"],
            document=document_fingerprint(reports_dir, report["report_file"]),
            collections={collection},
        )
        previous = reports.setdefault(report["id"], record)
        if previous is record:
            continue
        if previous.document != record.document:
            raise ExportError(
                f"report id {report['id']!r} names different documents in "
                f"{sorted(previous.collections)} and {collection!r}"
            )
        if (previous.title, previous.auditor, previous.date, previous.relevant) != (
            record.title, record.auditor, record.date, record.relevant
        ):
            raise ExportError(
                f"report {report['id']!r} has different metadata in "
                f"{sorted(previous.collections)} and {collection!r}"
            )
        previous.collections.add(collection)


def document_fingerprint(reports_dir: Path, report_file: str) -> tuple[tuple[str, str], ...]:
    """sha256 of the report's original files, or of its Markdown when it has none."""
    markdown = reports_dir.joinpath(*PurePosixPath(report_file).parts)
    assert markdown.suffix == ".md", report_file
    originals = [
        markdown.with_suffix(suffix)
        for suffix in ORIGINAL_SUFFIXES
        if markdown.with_suffix(suffix).is_file()
    ]
    documents = originals or [markdown]
    return tuple(
        (document.suffix, hashlib.sha256(document.read_bytes()).hexdigest())
        for document in documents
    )


def full_commit(revision: dict[str, Any]) -> str | None:
    """The revision's commit when it pins one full commit; ranges never do."""
    if revision.get("kind") == "commit_range":
        return None
    commit = revision.get("commit")
    if isinstance(commit, str) and FULL_COMMIT_RE.fullmatch(commit):
        return commit.lower()
    return None


def relevant_versions(summary: dict[str, Any]):
    """Yield ``(report, repository, path, path_kind, version_index, version)``."""
    for report in summary["reports"]:
        if not report["isRelevant"]:
            continue
        for scope in report["scopes"]:
            for path, path_data in scope["paths"].items():
                for version_index, version in enumerate(path_data["versions"]):
                    yield (report, scope["repository"], path, path_data["path_kind"],
                           version_index, version)


def record_timestamps(timestamps: dict[tuple[str, str], int | None], summary: dict[str, Any]) -> None:
    """Every version naming a commit must agree on its committer date."""
    for report, repository, path, _, _, version in relevant_versions(summary):
        commit = full_commit(version["revision"])
        if commit is None:
            continue
        timestamp = parse_timestamp(version["revision"].get("timestamp"), repository, commit)
        key = (repository, commit)
        if key in timestamps and timestamps[key] != timestamp:
            raise ExportError(
                f"conflicting timestamps for {repository}@{commit} "
                f"(report {report['id']!r}, path {path!r})"
            )
        timestamps[key] = timestamp


def parse_timestamp(value: Any, repository: str, commit: str) -> int | None:
    """ISO 8601 UTC committer date to unix seconds; ``None`` stays unknown."""
    if value is None:
        return None
    where = f"{repository}@{commit}"
    if not isinstance(value, str):
        raise ExportError(f"timestamp of {where} must be a string, got {value!r}")
    try:
        parsed = datetime.fromisoformat(value)
    except ValueError as error:
        raise ExportError(f"invalid timestamp of {where}: {value!r}") from error
    if parsed.utcoffset() != timedelta(0):
        raise ExportError(f"timestamp of {where} is not UTC: {value!r}")
    if parsed.microsecond != 0:
        raise ExportError(f"timestamp of {where} is not a whole second: {value!r}")
    seconds = int(parsed.timestamp())
    assert seconds > 0, value
    return seconds


def collection_audits(
    collection: str,
    collection_dir: Path,
    summary: dict[str, Any],
    fetched: dict[tuple[str, str, str], dict[str, Any]],
    unavailable: set[tuple[str, str, str]],
    timestamps: dict[tuple[str, str], int | None],
) -> list[Audit]:
    """Audits of one collection: fetched, full-commit, audited, with Solidity files."""
    sources_dir = collection_dir / "audited-sources"
    blob_ids: dict[Path, str] = {}
    audits: list[Audit] = []
    for report, repository, path, path_kind, version_index, version in relevant_versions(summary):
        commit = full_commit(version["revision"])
        if commit is None or version["status"] == "not_audited":
            continue
        key = (repository, path, commit)
        if key in unavailable:
            continue
        source = fetched.get(key)
        origin = f"{collection}: report {report['id']!r}, {repository}:{path} version {version_index}"
        if source is None:
            raise ExportError(f"{origin} is not in the manifest; rerun fetch_audited_sources.py")
        if source["path_kind"] != path_kind:
            raise ExportError(f"{origin}: manifest path_kind is {source['path_kind']!r}")
        files = solidity_files(sources_dir, source, blob_ids)
        if not files:
            continue
        timestamp = timestamps[(repository, commit)]
        if timestamp is None:
            raise ExportError(f"{origin}: fetched commit {commit} has no timestamp")
        audits.append(Audit(
            collection=collection,
            report_id=report["id"],
            repository=repository,
            commit=commit,
            timestamp=timestamp,
            scoped_path=path,
            finding_ids=tuple(version.get("finding_ids", ())),
            files=files,
            origin=origin,
        ))
    return audits


def read_manifest(
    manifest_path: Path,
) -> tuple[dict[tuple[str, str, str], dict[str, Any]], set[tuple[str, str, str]]]:
    """Fetched sources and unavailable ones, keyed by ``(repository, path, commit)``."""
    if not manifest_path.is_file():
        raise ExportError(f"{manifest_path} is missing; run fetch_audited_sources.py")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    fetched: dict[tuple[str, str, str], dict[str, Any]] = {}
    for source in manifest["sources"]:
        key = (source["repository"], source["source_path"], source["commit"])
        assert key not in fetched, key
        fetched[key] = source
    unavailable = {
        (item["repository"], item["source_path"], item["commit"])
        for item in manifest["unavailable"]
    }
    assert not unavailable & fetched.keys()
    return fetched, unavailable


def solidity_files(
    sources_dir: Path, source: dict[str, Any], blob_ids: dict[Path, str]
) -> tuple[AuditedFile, ...]:
    """The fetched ``.sol`` files of one manifest source, by repository path.

    Objects are the files as stored: ``git_object`` in the manifest is the
    upstream provenance, but stored Solidity is reformatted by format_sources.py,
    so the blob id is computed from the stored bytes, which must still be the
    bytes ``sha256`` was recorded for.
    """
    prefix = f"{source['repository']}/{source['source_path']}/{source['commit']}/"
    files: list[AuditedFile] = []
    for record in source["files"]:
        stored = record["file"]
        assert stored.startswith(prefix), stored
        relative = stored[len(prefix):]
        if source["path_kind"] == "file":
            assert relative == PurePosixPath(source["source_path"]).name, stored
            path = source["source_path"]
        else:
            path = f"{source['source_path']}/{relative}"
        if not path.endswith(".sol"):
            continue
        stored_path = sources_dir.joinpath(*PurePosixPath(stored).parts)
        if stored_path not in blob_ids:
            blob_ids[stored_path] = stored_blob_id(stored_path, record["sha256"], len(source["commit"]))
        files.append(AuditedFile(path=path, blob_id=blob_ids[stored_path], stored=stored_path))
    return tuple(files)


def stored_blob_id(stored: Path, sha256: str, commit_length: int) -> str:
    data = stored.read_bytes()
    if hashlib.sha256(data).hexdigest() != sha256:
        raise ExportError(f"{stored} does not match its manifest sha256; run index_sources.py")
    return git_blob_id(data, commit_length)


def add_audit(audits: dict[tuple[str, str, str, str], Audit], audit: Audit) -> None:
    """A path is audited once per report and commit; a shared report may repeat it."""
    key = (audit.repository, audit.commit, audit.report_id, audit.scoped_path)
    previous = audits.setdefault(key, audit)
    if previous is audit:
        return
    if (
        previous.collection == audit.collection
        or previous.finding_ids != audit.finding_ids
        or blob_ids_by_path(previous) != blob_ids_by_path(audit)
    ):
        raise ExportError(
            f"two versions scope {audit.scoped_path!r} at {audit.repository}@{audit.commit} "
            f"for report {audit.report_id!r}: {previous.origin} and {audit.origin}"
        )


def blob_ids_by_path(audit: Audit) -> dict[str, str]:
    """What an audit covers, independent of which collection stored the copy."""
    return {file.path: file.blob_id for file in audit.files}


# --- Assembling ---------------------------------------------------------------


def assemble_export(
    reports: dict[str, ReportRecord],
    audits: dict[tuple[str, str, str, str], Audit],
    manifest_paths: set[str],
) -> Export:
    snapshots: dict[str, dict[str, dict[str, Any]]] = defaultdict(dict)
    for (repository, commit, report_id, scoped_path), audit in sorted(audits.items()):
        assert reports[report_id].relevant, report_id
        snapshot = snapshots[repository].setdefault(
            commit, {"timestamp": audit.timestamp, "files": {}, "audits": {}}
        )
        assert snapshot["timestamp"] == audit.timestamp
        snapshot["audits"].setdefault(report_id, {})[scoped_path] = list(audit.finding_ids)
        for file in audit.files:
            previous = snapshot["files"].setdefault(file.path, file)
            if previous.blob_id != file.blob_id:
                raise ExportError(f"{repository}@{commit}:{file.path} has two blob ids")
    objects = read_objects(
        {file.blob_id: file.stored for repository in snapshots.values()
         for snapshot in repository.values() for file in snapshot["files"].values()}
    )
    used_reports = sorted({report_id for _, _, report_id, _ in audits})
    index = {
        "schema_version": SCHEMA_VERSION,
        "reports": {
            report_id: {
                "collections": sorted(reports[report_id].collections),
                "title": reports[report_id].title,
                "auditor": reports[report_id].auditor,
                "date": reports[report_id].date,
            }
            for report_id in used_reports
        },
        "repositories": {
            repository: ordered_snapshots(snapshots[repository])
            for repository in sorted(snapshots)
        },
    }
    return Export(index=index, objects=objects, manifest_paths=manifest_paths)


def ordered_snapshots(snapshots: dict[str, dict[str, Any]]) -> dict[str, Any]:
    """Commits by timestamp then id; every other key sorted."""
    ordered: dict[str, Any] = {}
    for commit in sorted(snapshots, key=lambda commit: (snapshots[commit]["timestamp"], commit)):
        snapshot = snapshots[commit]
        ordered[commit] = {
            "timestamp": snapshot["timestamp"],
            "files": {
                path: snapshot["files"][path].blob_id[:OBJECT_ID_LENGTH]
                for path in sorted(snapshot["files"])
            },
            "audits": {
                report_id: {
                    path: snapshot["audits"][report_id][path]
                    for path in sorted(snapshot["audits"][report_id])
                }
                for report_id in sorted(snapshot["audits"])
            },
        }
    return ordered


def read_objects(stored_by_blob: dict[str, Path]) -> dict[str, str]:
    """Read every blob once, verifying its bytes and that its short id is unique."""
    objects: dict[str, str] = {}
    blob_by_object: dict[str, str] = {}
    for blob_id in sorted(stored_by_blob):
        stored = stored_by_blob[blob_id]
        data = stored.read_bytes()
        if git_blob_id(data, len(blob_id)) != blob_id:
            raise ExportError(f"{stored} does not hash to its git object {blob_id}")
        try:
            text = data.decode("utf-8", errors="strict")
        except UnicodeDecodeError as error:
            raise ExportError(f"{stored} (blob {blob_id}) is not valid UTF-8: {error}") from error
        object_id = blob_id[:OBJECT_ID_LENGTH]
        previous = blob_by_object.setdefault(object_id, blob_id)
        if previous != blob_id:
            raise ExportError(f"blobs {previous} and {blob_id} share object id {object_id}")
        objects[object_id] = text
    return objects


def git_blob_id(data: bytes, length: int) -> str:
    """Git object id of a blob: sha1, or sha256 in a SHA-256 repository."""
    algorithm = hashlib.new(hash_algorithm(length))
    algorithm.update(b"blob %d\0" % len(data))
    algorithm.update(data)
    return algorithm.hexdigest()


def hash_algorithm(object_id_length: int) -> str:
    assert object_id_length in (40, 64), object_id_length
    return "sha1" if object_id_length == 40 else "sha256"


# --- Serializing and writing --------------------------------------------------


def serialize_index(index: dict[str, Any]) -> bytes:
    return (json.dumps(index, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


def serialize_objects(objects: dict[str, str]) -> bytes:
    text = json.dumps(objects, ensure_ascii=False, separators=(",", ":"), sort_keys=True)
    return text.encode("utf-8")


def compress_objects(objects_text: bytes) -> bytes:
    """One frame at a fixed level; every option that changes the frame is explicit."""
    options = {
        zstd.CompressionParameter.compression_level: ZSTD_LEVEL,
        zstd.CompressionParameter.enable_long_distance_matching: 1,
        zstd.CompressionParameter.window_log: ZSTD_WINDOW_LOG,
        zstd.CompressionParameter.checksum_flag: 1,
        zstd.CompressionParameter.content_size_flag: 1,
        zstd.CompressionParameter.dict_id_flag: 0,
        zstd.CompressionParameter.nb_workers: 0,
    }
    compressor = zstd.ZstdCompressor(options=options)
    compressed = compressor.compress(objects_text, mode=zstd.ZstdCompressor.FLUSH_FRAME)
    assert compressed.startswith(ZSTD_MAGIC)
    return compressed


def write_export(root: Path, index_text: bytes, objects_text: bytes) -> None:
    """Write both files atomically, then read them back and verify them."""
    compressed = compress_objects(objects_text)
    for name, data in ((OBJECTS_NAME, compressed), (INDEX_NAME, index_text)):
        temporary = root / f".{name}.tmp"
        temporary.write_bytes(data)
        os.replace(temporary, root / name)
    problems = check_written(root, index_text, objects_text)
    assert not problems, problems


def check_committed(
    root: Path, export: Export, index_text: bytes, objects_text: bytes
) -> list[str]:
    """The export on disk must be up to date, and every file a manifest names committed.

    Opening a path succeeds on a case-insensitive filesystem whatever its letter
    case, so paths are compared with the git index, which keeps their exact case.
    """
    problems = check_written(root, index_text, objects_text)
    try:
        committed = committed_paths(root)
    except ExportError as error:
        return problems + [str(error)]
    return problems + uncommitted_problems(committed, export.manifest_paths, "named by its manifest")


def check_written(root: Path, index_text: bytes, objects_text: bytes) -> list[str]:
    """The files on disk must be valid and byte-identical to the fresh export."""
    try:
        written_index = (root / INDEX_NAME).read_bytes()
        written_objects = decompress_frame((root / OBJECTS_NAME).read_bytes())
        index = parse_json(written_index)
        objects = parse_json(written_objects)
    except (OSError, ExportError, ValueError) as error:
        return [f"cannot read the written export: {error}"]
    problems = validate_export(index, objects, written_index, written_objects)
    if written_index != index_text:
        problems.append(f"{INDEX_NAME} is out of date; run export_audit_index.py")
    if written_objects != objects_text:
        problems.append(f"{OBJECTS_NAME} is out of date; run export_audit_index.py")
    return problems


def committed_paths(root: Path) -> set[str]:
    """Every file in the git index below the dataset root, by its exact path."""
    try:
        listing = subprocess.run(
            ["git", "-C", str(root), "ls-files", "-z"], capture_output=True, check=False
        )
    except OSError as error:
        raise ExportError(f"cannot run git to list the committed files: {error}") from error
    if listing.returncode != 0:
        stderr = listing.stderr.decode("utf-8", errors="replace").strip()
        raise ExportError(f"git ls-files failed in {root}: {stderr}")
    try:
        paths = listing.stdout.decode("utf-8", errors="strict").split("\0")
    except UnicodeDecodeError as error:
        raise ExportError(f"git ls-files listed a path that is not UTF-8: {error}") from error
    return {path for path in paths if path}


def uncommitted_problems(committed: set[str], paths: set[str], role: str) -> list[str]:
    """Paths that are not committed with exactly their letter case."""
    missing = sorted(paths - committed)
    if not missing:
        return []
    committed_by_folded_case = {path.casefold(): path for path in committed}
    problems: list[str] = []
    for path in missing:
        committed_as = committed_by_folded_case.get(path.casefold())
        if committed_as is None:
            problems.append(f"{path} ({role}) is not committed; a fetched .gitignore "
                            f"may hide it from git add without -f")
        else:
            problems.append(f"{path} ({role}) is committed as {committed_as}; "
                            f"git mv -f it to this spelling")
    return problems


def decompress_frame(data: bytes) -> bytes:
    """Contents of exactly one zstd frame that carries a content checksum."""
    if not data.startswith(ZSTD_MAGIC) or len(data) < 5:
        raise ExportError(f"{OBJECTS_NAME} is not a zstd frame")
    if not data[4] & ZSTD_CHECKSUM_FLAG_BIT:
        raise ExportError(f"{OBJECTS_NAME} frame has no content checksum")
    decompressor = zstd.ZstdDecompressor(
        options={zstd.DecompressionParameter.window_log_max: ZSTD_WINDOW_LOG}
    )
    try:
        contents = decompressor.decompress(data)
    except zstd.ZstdError as error:
        raise ExportError(f"{OBJECTS_NAME}: {error}") from error
    if not decompressor.eof or decompressor.unused_data:
        raise ExportError(f"{OBJECTS_NAME} must hold exactly one complete frame")
    return contents


def parse_json(data: bytes) -> Any:
    def reject_duplicates(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
        result = dict(pairs)
        if len(result) != len(pairs):
            raise ExportError("duplicate JSON object key")
        return result

    return json.loads(data.decode("utf-8"), object_pairs_hook=reject_duplicates)


def print_statistics(export: Export, index_text: bytes, objects_text: bytes) -> None:
    snapshots = [s for commits in export.index["repositories"].values() for s in commits.values()]
    audits = [paths for s in snapshots for paths in s["audits"].values()]
    print(
        f"{len(export.index['reports'])} reports, {len(export.index['repositories'])} repositories, "
        f"{len(snapshots)} snapshots, {sum(len(s['files']) for s in snapshots)} files, "
        f"{sum(len(paths) for paths in audits)} audited paths in {len(audits)} report audits, "
        f"{sum(1 for paths in audits for ids in paths.values() if ids)} paths with open findings, "
        f"{len(export.objects)} objects ({len(objects_text):,} bytes raw); "
        f"{INDEX_NAME} {len(index_text):,} bytes"
    )


# --- Validating ---------------------------------------------------------------


def validate_export(index: Any, objects: Any, index_text: bytes, objects_text: bytes) -> list[str]:
    """Every rule of the export that can be checked from the two files alone."""
    if not isinstance(index, dict) or not isinstance(objects, dict):
        return ["index and objects must be JSON objects"]
    problems = validate_top_level(index)
    if problems:
        return problems
    if serialize_index(index) != index_text:
        problems.append(f"{INDEX_NAME} is not sorted 2-space JSON with a trailing newline")
    if serialize_objects(objects) != objects_text:
        problems.append(f"{OBJECTS_NAME} does not hold compact JSON with sorted keys")
    problems += validate_reports(index["reports"])
    algorithms: dict[str, set[str]] = defaultdict(set)
    used_reports: set[str] = set()
    for repository, commits in index["repositories"].items():
        problems += validate_repository(repository, commits, index["reports"], objects,
                                        algorithms, used_reports)
    problems += [f"report {report_id!r} is used by no audit"
                 for report_id in sorted(index["reports"].keys() - used_reports)]
    problems += validate_objects(objects, algorithms)
    return problems


def validate_top_level(index: dict[str, Any]) -> list[str]:
    if list(index) != ["schema_version", "reports", "repositories"]:
        return [f"index keys must be schema_version, reports, repositories; got {list(index)}"]
    if index["schema_version"] != SCHEMA_VERSION:
        return [f"schema_version must be {SCHEMA_VERSION!r}"]
    if not isinstance(index["reports"], dict) or not isinstance(index["repositories"], dict):
        return ["reports and repositories must be objects"]
    problems = []
    if list(index["reports"]) != sorted(index["reports"]):
        problems.append("reports are not sorted by id")
    if list(index["repositories"]) != sorted(index["repositories"]):
        problems.append("repositories are not sorted by id")
    return problems


def validate_reports(reports: dict[str, Any]) -> list[str]:
    problems: list[str] = []
    for report_id, report in reports.items():
        where = f"report {report_id!r}"
        if not report_id or not isinstance(report, dict):
            problems.append(f"{where} must be a non-empty id with an object")
            continue
        if list(report) != ["collections", "title", "auditor", "date"]:
            problems.append(f"{where} keys must be collections, title, auditor, date")
            continue
        collections = report["collections"]
        if (
            not isinstance(collections, list)
            or not collections
            or not all(isinstance(name, str) and name for name in collections)
            or collections != sorted(set(collections))
        ):
            problems.append(f"{where}: collections must be a sorted, unique, non-empty list")
        for key in ("title", "auditor"):
            if not isinstance(report[key], str) or not report[key].strip():
                problems.append(f"{where}: {key} must be a non-empty string")
        if report["date"] is not None and not valid_date(report["date"]):
            problems.append(f"{where}: date must be null or YYYY-MM-DD, got {report['date']!r}")
    return problems


def valid_date(value: Any) -> bool:
    if not isinstance(value, str) or not DATE_RE.fullmatch(value):
        return False
    try:
        datetime.strptime(value, "%Y-%m-%d")
    except ValueError:
        return False
    return True


def path_problem(path: Any) -> str | None:
    if not isinstance(path, str) or not path:
        return "must be a non-empty string"
    if "\\" in path or path.startswith("/") or path.endswith("/"):
        return "must be POSIX without a leading or trailing '/'"
    if any(part in {"", ".", ".."} for part in path.split("/")):
        return "must not contain empty, '.' or '..' segments"
    return None


def validate_repository(
    repository: str,
    commits: Any,
    reports: dict[str, Any],
    objects: dict[str, Any],
    algorithms: dict[str, set[str]],
    used_reports: set[str],
) -> list[str]:
    problems: list[str] = []
    if path_problem(repository) is not None or "/" not in repository:
        problems.append(f"repository id {repository!r} is not a canonical id")
    if not isinstance(commits, dict) or not commits:
        return problems + [f"{repository}: must map at least one commit to its snapshot"]
    if len({len(commit) for commit in commits}) != 1:
        problems.append(f"{repository}: mixes SHA-1 and SHA-256 commit ids")
    order: list[tuple[int, str]] = []
    for commit, snapshot in commits.items():
        where = f"{repository}@{commit}"
        if not COMMIT_RE.fullmatch(commit):
            problems.append(f"{where}: commit must be full lowercase hex")
            continue
        if not isinstance(snapshot, dict) or list(snapshot) != ["timestamp", "files", "audits"]:
            problems.append(f"{where}: snapshot keys must be timestamp, files, audits")
            continue
        timestamp = snapshot["timestamp"]
        if type(timestamp) is not int or timestamp <= 0:
            problems.append(f"{where}: timestamp must be positive unix seconds")
            continue
        order.append((timestamp, commit))
        problems += validate_snapshot(where, snapshot, reports, objects, used_reports)
        for object_id in snapshot["files"].values():
            algorithms[object_id].add(hash_algorithm(len(commit)))
    if [commit for _, commit in sorted(order)] != [commit for _, commit in order]:
        problems.append(f"{repository}: commits are not ordered by timestamp, then commit id")
    return problems


def validate_snapshot(
    where: str, snapshot: dict[str, Any], reports: dict[str, Any], objects: dict[str, Any],
    used_reports: set[str],
) -> list[str]:
    problems: list[str] = []
    files, audits = snapshot["files"], snapshot["audits"]
    if not isinstance(files, dict) or not files or not isinstance(audits, dict) or not audits:
        return [f"{where}: files and audits must be non-empty objects"]
    if list(files) != sorted(files) or list(audits) != sorted(audits):
        problems.append(f"{where}: files and audits must be sorted")
    covered_prefixes: set[str] = set()
    for path, object_id in files.items():
        problem = path_problem(path)
        if problem is not None or not path.endswith(".sol"):
            problems.append(f"{where}: file {path!r} {problem or 'is not Solidity'}")
            continue
        if not isinstance(object_id, str) or not OBJECT_ID_RE.fullmatch(object_id):
            problems.append(f"{where}: {path} has invalid object id {object_id!r}")
        elif object_id not in objects:
            problems.append(f"{where}: {path} references missing object {object_id}")
        covered_prefixes.update(path_and_ancestors(path))
    scoped_paths: set[str] = set()
    for report_id, paths in audits.items():
        used_reports.add(report_id)
        if report_id not in reports:
            problems.append(f"{where}: audit by unknown report {report_id!r}")
        problems += validate_audit(f"{where} {report_id}", paths, covered_prefixes)
        if isinstance(paths, dict):
            scoped_paths.update(paths)
    for path in files:
        if scoped_paths.isdisjoint(path_and_ancestors(path)):
            problems.append(f"{where}: file {path} is covered by no audit")
    return problems


def validate_audit(where: str, paths: Any, covered_prefixes: set[str]) -> list[str]:
    if not isinstance(paths, dict) or not paths:
        return [f"{where}: must map at least one scoped path to its findings"]
    problems: list[str] = []
    if list(paths) != sorted(paths):
        problems.append(f"{where}: scoped paths must be sorted")
    for path, finding_ids in paths.items():
        problem = path_problem(path)
        if problem is not None:
            problems.append(f"{where}: scoped path {path!r} {problem}")
        elif path not in covered_prefixes:
            problems.append(f"{where}: scoped path {path!r} covers no file")
        if (
            not isinstance(finding_ids, list)
            or not all(isinstance(finding_id, str) and finding_id for finding_id in finding_ids)
            or len(set(finding_ids)) != len(finding_ids)
        ):
            problems.append(f"{where}: findings of {path!r} must be unique non-empty strings")
    return problems


def path_and_ancestors(path: str) -> list[str]:
    """``a/b/c.sol`` -> ``a``, ``a/b``, ``a/b/c.sol``: the scoped paths covering it."""
    parts = path.split("/")
    return ["/".join(parts[: count]) for count in range(1, len(parts) + 1)]


def validate_objects(objects: dict[str, Any], algorithms: dict[str, set[str]]) -> list[str]:
    problems = [f"object {object_id} is used by no file"
                for object_id in sorted(objects.keys() - algorithms.keys())]
    for object_id in sorted(objects.keys() & algorithms.keys()):
        text = objects[object_id]
        if not isinstance(text, str):
            problems.append(f"object {object_id} must be a string")
            continue
        try:
            data = text.encode("utf-8", errors="strict")
        except UnicodeEncodeError:
            problems.append(f"object {object_id} is not valid UTF-8")
            continue
        for algorithm in sorted(algorithms[object_id]):
            length = 40 if algorithm == "sha1" else 64
            if not git_blob_id(data, length).startswith(object_id):
                problems.append(f"object {object_id} does not hash to its id ({algorithm})")
    return problems


if __name__ == "__main__":
    raise SystemExit(main())
