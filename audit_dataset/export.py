"""Export ``audit-index.json`` and ``audit-objects.json.zst``: the public interface.

The index says, for every repository commit pinned by an audit, which Solidity
files were audited there, by which reports, and which major findings those
reports left open in each scoped path. The bundle maps every file's object id
(the first 12 hex characters of the git blob id of its contents) to the file as
stored in ``audited-sources/``, i.e. formatted by ``format``. Consumers pin both
files to a dataset commit; everything else in the dataset is internal. See the
README section "Audit export" for the format and its rules.

``check`` rebuilds the export in memory and verifies that the committed files
satisfy every rule and are byte-identical to it, without writing anything. A
normal run performs the same validation before writing and refuses to write an
invalid export.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path, PurePosixPath
from typing import Any

if sys.version_info < (3, 14):
    sys.exit("the export requires Python 3.14 or newer for compression.zstd")

from compression import zstd

from . import DatasetError
from .collections import Collection, discover
from .git import blob_id, full_commit, hash_algorithm
from .manifest import read_manifest, sources_by_key, stored_path, unavailable_keys
from .summary import commit_timestamps, path_problem, read_summary, relevant_versions

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

COMMIT_RE = re.compile(r"(?:[0-9a-f]{40}|[0-9a-f]{64})\Z")
OBJECT_ID_RE = re.compile(r"[0-9a-f]{12}\Z")
DATE_RE = re.compile(r"\d{4}-\d{2}-\d{2}\Z")
# Report documents are compared by their originals; native Markdown reports have none.
ORIGINAL_SUFFIXES = (".pdf", ".html", ".csv", ".js")


class ExportError(DatasetError):
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


def export_dataset(root: Path, check: bool) -> int:
    """Write the export, or with ``check`` verify the committed one; 0 on success."""
    export = build_export(root)
    index_text = serialize_index(export.index)
    objects_text = serialize_objects(export.objects)
    problems = validate_export(export.index, export.objects, index_text, objects_text)
    if not problems and check:
        problems = check_committed(root, index_text, objects_text)
    if problems:
        shown = "\n  ".join(problems[:50])
        more = f"\n  ... and {len(problems) - 50} more problems" if len(problems) > 50 else ""
        raise ExportError(f"invalid export:\n  {shown}{more}")
    if check:
        print(f"{INDEX_NAME} and {OBJECTS_NAME} are valid and up to date")
    else:
        write_export(root, index_text, objects_text)
    print_statistics(export, index_text, objects_text)
    return 0


# --- Building -----------------------------------------------------------------


def build_export(root: Path) -> Export:
    collections = discover(root)
    if not collections:
        raise ExportError(f"no collections in {root}")
    reports: dict[str, ReportRecord] = {}
    audits: dict[tuple[str, str, str, str], Audit] = {}
    timestamps: dict[tuple[str, str], int | None] = {}
    for collection in collections:
        summary = read_summary(collection)
        record_reports(reports, collection, summary)
        for key, timestamp in commit_timestamps(summary).items():
            if timestamps.setdefault(key, timestamp) != timestamp:
                raise ExportError(f"{collection.name}: conflicting timestamps for {key[0]}@{key[1]}")
        for audit in collection_audits(collection, summary, timestamps):
            add_audit(audits, audit)
    return assemble_export(reports, audits)


def record_reports(reports: dict[str, ReportRecord], collection: Collection, summary: dict[str, Any]) -> None:
    """Merge one collection's report metadata, rejecting an id shared by two documents."""
    for report in summary["reports"]:
        record = ReportRecord(
            title=report["title"],
            auditor=report["auditor"],
            date=report["report_date"],
            relevant=report["isRelevant"],
            document=document_fingerprint(collection.reports_dir, report["report_file"]),
            collections={collection.name},
        )
        previous = reports.setdefault(report["id"], record)
        if previous is record:
            continue
        if previous.document != record.document:
            raise ExportError(
                f"report id {report['id']!r} names different documents in "
                f"{sorted(previous.collections)} and {collection.name!r}"
            )
        if (previous.title, previous.auditor, previous.date, previous.relevant) != (
            record.title, record.auditor, record.date, record.relevant
        ):
            raise ExportError(
                f"report {report['id']!r} has different metadata in "
                f"{sorted(previous.collections)} and {collection.name!r}"
            )
        previous.collections.add(collection.name)


def document_fingerprint(reports_dir: Path, report_file: str) -> tuple[tuple[str, str], ...]:
    """sha256 of the report's original files, or of its Markdown when it has none."""
    markdown = reports_dir.joinpath(*PurePosixPath(report_file).parts)
    originals = [
        markdown.with_suffix(suffix)
        for suffix in ORIGINAL_SUFFIXES
        if markdown.with_suffix(suffix).is_file()
    ]
    return tuple(
        (document.suffix, hashlib.sha256(document.read_bytes()).hexdigest())
        for document in (originals or [markdown])
    )


def collection_audits(
    collection: Collection, summary: dict[str, Any], timestamps: dict[tuple[str, str], int | None]
) -> list[Audit]:
    """Audits of one collection: ``evm`` paths, fetched, full-commit, audited, with Solidity files."""
    manifest = read_manifest(collection)
    fetched = sources_by_key(manifest)
    unavailable = unavailable_keys(manifest)
    if unavailable & fetched.keys():
        raise ExportError(f"{collection.name}: manifest lists a source as both fetched and unavailable")
    blob_ids: dict[Path, str] = {}
    audits: list[Audit] = []
    for report, repository, path, path_data, version_index, version in relevant_versions(summary):
        commit = full_commit(version["revision"])
        if commit is None or version["status"] == "not_audited" or path_data["kind"] != "evm":
            continue
        path_kind = path_data["path_kind"]
        key = (repository, path, commit)
        if key in unavailable:
            continue
        source = fetched.get(key)
        origin = f"{collection.name}: report {report['id']!r}, {repository}:{path} version {version_index}"
        if source is None:
            raise ExportError(f"{origin} is not in the manifest; rerun fetch")
        if source["path_kind"] != path_kind:
            raise ExportError(f"{origin}: manifest path_kind is {source['path_kind']!r}")
        files = solidity_files(collection.sources_dir, source, blob_ids)
        if not files:
            continue
        timestamp = timestamps[(repository, commit)]
        if timestamp is None:
            raise ExportError(f"{origin}: fetched commit {commit} has no timestamp")
        audits.append(Audit(
            collection=collection.name,
            report_id=report["id"],
            repository=repository,
            commit=commit,
            timestamp=timestamp,
            scoped_path=path,
            finding_ids=tuple(version.get("major_finding_ids", ())),
            files=files,
            origin=origin,
        ))
    return audits


def solidity_files(
    sources_dir: Path, source: dict[str, Any], blob_ids: dict[Path, str]
) -> tuple[AuditedFile, ...]:
    """The stored ``.sol`` files of one manifest source.

    Objects are the files as stored: ``git_object`` in the manifest is the
    upstream provenance, but stored Solidity is reformatted, so the blob id is
    computed from the stored bytes, which must still be the bytes ``sha256``
    was recorded for.
    """
    files: list[AuditedFile] = []
    for record in source["files"]:
        path = record["path"]
        if not path.endswith(".sol"):
            continue
        stored = stored_path(sources_dir, source["repository"], source["commit"], path)
        if stored not in blob_ids:
            blob_ids[stored] = stored_blob_id(stored, record["sha256"], len(source["commit"]))
        files.append(AuditedFile(path=path, blob_id=blob_ids[stored], stored=stored))
    return tuple(files)


def stored_blob_id(stored: Path, sha256: str, commit_length: int) -> str:
    try:
        data = stored.read_bytes()
    except OSError as error:
        raise ExportError(f"cannot read {stored}: {error}") from error
    if hashlib.sha256(data).hexdigest() != sha256:
        raise ExportError(f"{stored} does not match its manifest sha256; run index")
    return blob_id(data, commit_length)


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


def assemble_export(reports: dict[str, ReportRecord], audits: dict[tuple[str, str, str, str], Audit]) -> Export:
    snapshots: dict[str, dict[str, dict[str, Any]]] = defaultdict(dict)
    for (repository, commit, report_id, scoped_path), audit in sorted(audits.items()):
        if not reports[report_id].relevant:
            raise ExportError(f"irrelevant report {report_id!r} has audits")
        snapshot = snapshots[repository].setdefault(
            commit, {"timestamp": audit.timestamp, "files": {}, "audits": {}}
        )
        if snapshot["timestamp"] != audit.timestamp:
            raise ExportError(f"{repository}@{commit} has two timestamps")
        snapshot["audits"].setdefault(report_id, {})[scoped_path] = list(audit.finding_ids)
        for file in audit.files:
            previous = snapshot["files"].setdefault(file.path, file)
            if previous.blob_id != file.blob_id:
                raise ExportError(f"{repository}@{commit}:{file.path} has two blob ids")
    objects = read_objects({
        file.blob_id: file.stored
        for repository in snapshots.values()
        for snapshot in repository.values()
        for file in snapshot["files"].values()
    })
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
    return Export(index=index, objects=objects)


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
    for full_id in sorted(stored_by_blob):
        stored = stored_by_blob[full_id]
        data = stored.read_bytes()
        if blob_id(data, len(full_id)) != full_id:
            raise ExportError(f"{stored} does not hash to its git object {full_id}")
        try:
            text = data.decode("utf-8", errors="strict")
        except UnicodeDecodeError as error:
            raise ExportError(f"{stored} (blob {full_id}) is not valid UTF-8: {error}") from error
        object_id = full_id[:OBJECT_ID_LENGTH]
        previous = blob_by_object.setdefault(object_id, full_id)
        if previous != full_id:
            raise ExportError(f"blobs {previous} and {full_id} share object id {object_id}")
        objects[object_id] = text
    return objects


# --- Serializing and writing --------------------------------------------------


def serialize_index(index: dict[str, Any]) -> bytes:
    return (json.dumps(index, indent=2, ensure_ascii=False) + "\n").encode("utf-8")


def serialize_objects(objects: dict[str, str]) -> bytes:
    return json.dumps(objects, ensure_ascii=False, separators=(",", ":"), sort_keys=True).encode("utf-8")


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
    if not compressed.startswith(ZSTD_MAGIC):
        raise ExportError("zstd produced no frame")
    return compressed


def write_export(root: Path, index_text: bytes, objects_text: bytes) -> None:
    """Write both files atomically, then read them back and verify them."""
    compressed = compress_objects(objects_text)
    for name, data in ((OBJECTS_NAME, compressed), (INDEX_NAME, index_text)):
        temporary = root / f".{name}.tmp"
        temporary.write_bytes(data)
        os.replace(temporary, root / name)
    problems = check_committed(root, index_text, objects_text)
    if problems:
        raise ExportError("the written export does not verify: " + "; ".join(problems))


def check_committed(root: Path, index_text: bytes, objects_text: bytes) -> list[str]:
    """The files on disk must be valid and byte-identical to the fresh export."""
    try:
        committed_index = (root / INDEX_NAME).read_bytes()
        committed_objects = decompress_frame((root / OBJECTS_NAME).read_bytes())
        index = parse_json(committed_index)
        objects = parse_json(committed_objects)
    except (OSError, ExportError, ValueError) as error:
        return [f"cannot read the committed export: {error}"]
    problems = validate_export(index, objects, committed_index, committed_objects)
    if committed_index != index_text:
        problems.append(f"{INDEX_NAME} is out of date; run export")
    if committed_objects != objects_text:
        problems.append(f"{OBJECTS_NAME} is out of date; run export")
    return problems


def decompress_frame(data: bytes) -> bytes:
    """Contents of exactly one zstd frame that carries a content checksum."""
    if not data.startswith(ZSTD_MAGIC) or len(data) < 5:
        raise ExportError(f"{OBJECTS_NAME} is not a zstd frame")
    if not data[4] & ZSTD_CHECKSUM_FLAG_BIT:
        raise ExportError(f"{OBJECTS_NAME} frame has no content checksum")
    decompressor = zstd.ZstdDecompressor(options={zstd.DecompressionParameter.window_log_max: ZSTD_WINDOW_LOG})
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
        problems += validate_repository(repository, commits, index["reports"], objects, algorithms, used_reports)
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
    parts = path.split("/")
    return ["/".join(parts[:count]) for count in range(1, len(parts) + 1)]


def validate_objects(objects: dict[str, Any], algorithms: dict[str, set[str]]) -> list[str]:
    problems: list[str] = []
    if list(objects) != sorted(objects):
        problems.append("objects are not sorted by id")
    for object_id, text in objects.items():
        if not OBJECT_ID_RE.fullmatch(object_id) or not isinstance(text, str):
            problems.append(f"object {object_id!r} must map a 12-hex id to a string")
            continue
        used = algorithms.get(object_id)
        if not used:
            problems.append(f"object {object_id} is used by no file")
            continue
        if len(used) != 1:
            problems.append(f"object {object_id} is used by both SHA-1 and SHA-256 repositories")
            continue
        data = text.encode("utf-8")
        algorithm = hashlib.new(next(iter(used)))
        algorithm.update(b"blob %d\0" % len(data))
        algorithm.update(data)
        if not algorithm.hexdigest().startswith(object_id):
            problems.append(f"object {object_id} does not hash to its id")
    return problems
