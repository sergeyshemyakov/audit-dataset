"""Export ``audit-index.json`` and ``audit-objects.json.zst``: the public interface.

The index names every collection, with the display name the hand-maintained
``collections.json`` gives it, lists every relevant report with the dataset
path of its original document and what it says about code it does not list,
and says, for every repository commit pinned by an audit, which Solidity files
each report lists there, which major findings it left open in each listed path,
and which files it only reaches through the imports of what it audited: implied,
excluded in words, or included by a statement about dependencies. The bundle maps
every file's object id (the first 12 hex characters of the git blob id of its
contents) to the file as stored in ``audited-sources/``, i.e. formatted by
``format``. Consumers pin both files to a dataset commit; everything else in
the dataset is internal. See the README section "Audit export" for the format
and its rules.

``--check`` rebuilds the export in memory and verifies that the committed files
satisfy every rule and are byte-identical to it, without writing anything. It
also verifies, against the git index, that every report document and every
file a manifest names is committed with exactly that letter case, and that
every object is the committed blob of a stored file, which GitHub's blob API
serves by the SHA-1 blob id of the object's contents. A normal run performs the
same validation before writing and refuses to write an invalid export.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Any

if sys.version_info < (3, 14):
    sys.exit("the export requires Python 3.14 or newer for compression.zstd")

from compression import zstd

from . import DatasetError
from . import imports
from .collections import LIBRARIES_DIR, REPORTS_DIR, Collection, discover
from .git import GitError, blob_id, full_commit, hash_algorithm, run
from .manifest import (
    LEGACY_SCHEMA_VERSION as LEGACY_MANIFEST,
    read_manifest,
    sources_by_key,
    stored_path,
    unavailable_keys,
)
from .repositories import canonical_repository_id, repository_url
from .scope import is_under
from .summary import (
    SCHEMA_VERSION as SUMMARY_SCHEMA,
    DEPENDENCIES_VALUES,
    UNLISTED_VALUES,
    commit_timestamps,
    path_problem,
    read_summary,
    scope_statements,
    valid_date,
)

SCHEMA_VERSION = "2.0.0"
# How far a report's review of EVM code is pinned down, in increasing order.
EVM_SCOPES = ("none", "unpinned", "partial", "full")
REPORT_KEYS = ["collections", "title", "auditor", "date", "document", "evm_scope", "unlisted", "dependencies"]
# Keys of one report's audit in a snapshot after ``listed``, each a sorted list of paths.
AUDIT_LIST_KEYS = ("partial", "excluded", "implied", "included", "visible", "external")
REACHED_KEYS = imports.REACHED_STATES
INDEX_NAME = "audit-index.json"
OBJECTS_NAME = "audit-objects.json.zst"
COLLECTIONS_NAME = "collections.json"
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
# What a report's Markdown was converted from, in the order its exported document
# is chosen; a report published as Markdown has none and links the Markdown.
ORIGINAL_SUFFIXES = (".pdf", ".html", ".csv", ".js")
DOCUMENT_SUFFIXES = (*ORIGINAL_SUFFIXES, ".md")


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
    partial: bool  # reviewed in part only: a diff, selected functions
    files: tuple[AuditedFile, ...]
    origin: str  # which summary version produced it, for error messages


@dataclass
class ReportRecord:
    title: str
    auditor: str
    date: str | None
    relevant: bool
    fingerprint: tuple[tuple[str, str], ...]  # (suffix, sha256) of each of its documents
    documents: dict[str, str]  # collection -> dataset path of the report's document there
    evm_scope: str
    unlisted: str | None
    dependencies: str | None


@dataclass
class ScopeExpansion:
    """What one report reaches through imports from one audited commit.

    Paths are as the audited repository sees them, also below a submodule.
    """

    collection: str
    legacy: bool  # from a manifest fetched before dependencies were followed
    reached: dict[str, tuple[str, bool]]  # exported reached file -> (state, dependency)
    files: dict[str, tuple[str, str, AuditedFile]]  # the same files -> (repository, commit, file there)
    imports: dict[str, dict[str, str | None]]  # read file -> import string -> exported file, if any
    mounts: dict[str, tuple[str, str]]  # submodule mount path -> (repository, commit), where used
    origin: str

    def content(self) -> tuple[Any, ...]:
        """What it exports, independent of which collection stored the copies."""
        files = {
            path: (repository, commit, file.path, file.blob_id)
            for path, (repository, commit, file) in self.files.items()
        }
        return self.reached, files, self.imports, self.mounts


@dataclass
class Build:
    """What the collections contribute, before it is assembled into the index."""

    reports: dict[str, ReportRecord]
    audits: dict[tuple[str, str, str, str], Audit]
    exclusions: dict[tuple[str, str], tuple[str, ...]]  # (report id, repository) -> not_audited paths
    expansions: dict[tuple[str, str, str], ScopeExpansion]  # by (repository, commit, report id)
    timestamps: dict[tuple[str, str], int | None]
    manifest_paths: set[str]
    stale: set[str]  # collections whose manifest must be fetched again to export every expansion


@dataclass
class Export:
    index: dict[str, Any]
    objects: dict[str, str]
    manifest_paths: set[str]  # dataset path of every file a manifest names, Solidity or not
    stale: list[str]
    outdated: list[tuple[str, str]]  # (collection, summary schema) of the collections left out
    unread: list[tuple[str, int, int]]  # (collection, relevant reports without ``unlisted``, relevant reports)


def export_dataset(root: Path, check: bool, output: Path | None = None) -> int:
    """Write the export (to ``output``, the dataset root by default), or with ``check``
    verify the committed one; 0 on success."""
    if check and output is not None:
        raise ExportError("check verifies the committed export and writes nothing; drop the output")
    export = build_export(root)
    index_text = serialize_index(export.index)
    objects_text = serialize_objects(export.objects)
    problems = validate_export(export.index, export.objects, index_text, objects_text)
    if not problems and check:
        problems = check_committed(root, export, index_text, objects_text)
    if problems:
        shown = "\n  ".join(problems[:50])
        more = f"\n  ... and {len(problems) - 50} more problems" if len(problems) > 50 else ""
        raise ExportError(f"invalid export:\n  {shown}{more}")
    for warning in export_warnings(export):
        print(f"warning: {warning}", file=sys.stderr)
    if check:
        print(f"{INDEX_NAME} and {OBJECTS_NAME} are valid and up to date")
    else:
        target = root if output is None else output.resolve()
        target.mkdir(parents=True, exist_ok=True)
        write_export(target, index_text, objects_text)
    print_statistics(export, index_text, objects_text)
    return 0


def export_warnings(export: Export) -> list[str]:
    """What keeps the export from covering the whole dataset; none of it fails the export."""
    warnings = [
        f"{collection}: summary is on schema {version} (latest {SUMMARY_SCHEMA}); not exported"
        for collection, version in export.outdated
    ]
    warnings += [
        f"{collection}: {unread} of {relevant} relevant reports not read for scope statements"
        for collection, unread, relevant in export.unread
    ]
    warnings += [
        f"{collection}: sources fetched before dependencies were followed; run fetch"
        for collection in export.stale
    ]
    return warnings


# --- Building -----------------------------------------------------------------


def build_export(root: Path) -> Export:
    collections = discover(root)
    if not collections:
        raise ExportError(f"no collections in {root}")
    names = read_collection_names(root / COLLECTIONS_NAME, {collection.name for collection in collections})
    build = Build({}, {}, {}, {}, {}, set(), set())
    loaded = []
    outdated: list[tuple[str, str]] = []
    unread: list[tuple[str, int, int]] = []
    for collection in collections:
        summary = read_summary(collection)
        # Only summaries on the latest schema are exported: an older one was not
        # read for everything the export says about a report.
        if summary["schema_version"] != SUMMARY_SCHEMA:
            outdated.append((collection.name, summary["schema_version"]))
            del names[collection.name]
            continue
        relevant = [report for report in summary["reports"] if report["isRelevant"]]
        missing = sum(1 for report in relevant if "unlisted" not in report)
        if missing:
            unread.append((collection.name, missing, len(relevant)))
        record_reports(build.reports, root, collection, summary)
        for key, timestamp in commit_timestamps(summary).items():
            if build.timestamps.setdefault(key, timestamp) != timestamp:
                raise ExportError(f"{collection.name}: conflicting timestamps for {key[0]}@{key[1]}")
        loaded.append((collection, summary, read_manifest(collection)))
    # A submodule commit is dated by its manifest unless a summary pins it too.
    for collection, _, manifest in loaded:
        for repository, entry in manifest.get("dependencies", {}).items():
            for commit, timestamp in entry["commits"].items():
                known = build.timestamps.get((repository, commit))
                if known is None:
                    build.timestamps[(repository, commit)] = timestamp
                elif known != timestamp:
                    raise ExportError(f"{collection.name}: conflicting timestamps for {repository}@{commit}")
    for collection, summary, manifest in loaded:
        build.manifest_paths.update(
            stored_path(collection.sources_dir, source["repository"], source["commit"], record["path"])
            .relative_to(root).as_posix()
            for source in manifest["sources"]
            for record in source["files"]
        )
        stored = StoredFiles(collection, manifest)
        record_exclusions(build.exclusions, collection, summary)
        for audit in collection_audits(collection, summary, manifest, build.timestamps, stored):
            add_audit(build.audits, audit)
        for key, expansion in collection_expansions(collection, summary, manifest, stored, build.stale):
            add_expansion(build.expansions, key, expansion)
    if not loaded:
        raise ExportError(f"no collection is on summary schema {SUMMARY_SCHEMA}")
    export = assemble_export(names, build)
    export.outdated, export.unread = outdated, unread
    return export


def read_collection_names(path: Path, collections: set[str]) -> dict[str, str]:
    """Display names from the hand-maintained registry, which names exactly the collections."""
    try:
        names = parse_json(path.read_bytes())
    except (OSError, ExportError, ValueError) as error:
        raise ExportError(f"cannot read {COLLECTIONS_NAME}: {error}") from error
    if not isinstance(names, dict) or not all(isinstance(name, str) for name in names.values()):
        raise ExportError(f"{COLLECTIONS_NAME} must map collection ids to display names")
    if list(names) != sorted(names):
        raise ExportError(f"{COLLECTIONS_NAME} must be sorted by collection id")
    if names.keys() != collections:
        raise ExportError(
            f"{COLLECTIONS_NAME} must name exactly the collections: missing "
            f"{sorted(collections - names.keys())}, unknown {sorted(names.keys() - collections)}"
        )
    return names


def record_reports(
    reports: dict[str, ReportRecord], root: Path, collection: Collection, summary: dict[str, Any]
) -> None:
    """Merge one collection's report metadata, rejecting an id shared by two documents."""
    for report in summary["reports"]:
        documents = report_documents(root, collection, report["report_file"])
        unlisted, dependencies = scope_statements(report)
        record = ReportRecord(
            title=report["title"],
            auditor=report["auditor"],
            date=report["report_date"],
            relevant=report["isRelevant"],
            fingerprint=document_fingerprint(root, documents),
            documents={collection.name: documents[0]},
            evm_scope=evm_scope(report),
            unlisted=unlisted,
            dependencies=dependencies,
        )
        previous = reports.setdefault(report["id"], record)
        if previous is record:
            continue
        if collection.name in previous.documents:
            raise ExportError(f"{collection.name}: report id {report['id']!r} is used twice")
        if previous.fingerprint != record.fingerprint:
            raise ExportError(
                f"report id {report['id']!r} names different documents in "
                f"{sorted(previous.documents)} and {collection.name!r}"
            )
        if (previous.title, previous.auditor, previous.date, previous.relevant) != (
            record.title, record.auditor, record.date, record.relevant
        ):
            raise ExportError(
                f"report {report['id']!r} has different metadata in "
                f"{sorted(previous.documents)} and {collection.name!r}"
            )
        # A collection that has not read the report for its scope statements yet
        # takes them from the one that has; two that have must agree.
        for key in ("unlisted", "dependencies"):
            ours, theirs = getattr(previous, key), getattr(record, key)
            if ours is not None and theirs is not None and ours != theirs:
                raise ExportError(
                    f"report {report['id']!r} has {key} {ours!r} in {sorted(previous.documents)} "
                    f"and {theirs!r} in {collection.name!r}"
                )
            setattr(previous, key, ours if ours is not None else theirs)
        previous.evm_scope = max(previous.evm_scope, record.evm_scope, key=EVM_SCOPES.index)
        previous.documents[collection.name] = documents[0]


def evm_scope(report: dict[str, Any]) -> str:
    """How far a report's review of EVM code is pinned down.

    ``none``: it scopes no ``evm`` path. ``unpinned``: none it audited is pinned to
    a full commit. ``partial``: pinned, but reviewed in part only (fix reviews,
    diffs). ``full``: it audited at least one ``evm`` path in full at a full commit.
    """
    level = "none"
    for scope in report["scopes"]:
        for path_data in scope["paths"].values():
            if path_data["kind"] != "evm":
                continue
            level = max(level, "unpinned", key=EVM_SCOPES.index)
            for version in path_data["versions"]:
                if version["status"] == "not_audited" or full_commit(version["revision"]) is None:
                    continue
                reviewed = "full" if version["status"] in imports.FULL_AUDIT_STATUSES else "partial"
                level = max(level, reviewed, key=EVM_SCOPES.index)
    return level


def report_documents(root: Path, collection: Collection, report_file: str) -> list[str]:
    """Dataset paths of the report's originals in ORIGINAL_SUFFIXES order, else of its Markdown."""
    markdown = PurePosixPath(collection.name, REPORTS_DIR, report_file)
    if markdown.suffix != ".md":
        raise ExportError(f"{collection.name}: report_file {report_file!r} is not Markdown")
    originals = [
        markdown.with_suffix(suffix).as_posix()
        for suffix in ORIGINAL_SUFFIXES
        if root.joinpath(*markdown.with_suffix(suffix).parts).is_file()
    ]
    return originals or [markdown.as_posix()]


def document_fingerprint(root: Path, documents: list[str]) -> tuple[tuple[str, str], ...]:
    """sha256 of each document, which tells two reports sharing an id apart."""
    fingerprint: list[tuple[str, str]] = []
    for document in documents:
        path = PurePosixPath(document)
        try:
            data = root.joinpath(*path.parts).read_bytes()
        except OSError as error:
            raise ExportError(f"cannot read report document {document}: {error}") from error
        fingerprint.append((path.suffix, hashlib.sha256(data).hexdigest()))
    return tuple(fingerprint)


def record_exclusions(
    exclusions: dict[tuple[str, str], tuple[str, ...]], collection: Collection, summary: dict[str, Any]
) -> None:
    """Paths a report says it did not review, by (report id, repository).

    They apply to the report at every commit of that repository: a report
    scoping ``src`` and excluding ``src/vendor`` covers no file under
    ``src/vendor``, and nothing is implied from one.
    """
    for report in summary["reports"]:
        if not report["isRelevant"]:
            continue
        for repository, excluded in report_exclusions(report).items():
            if exclusions.setdefault((report["id"], repository), excluded) != excluded:
                raise ExportError(
                    f"{collection.name}: report {report['id']!r} excludes other paths of "
                    f"{repository} than in another collection"
                )


def report_exclusions(report: dict[str, Any]) -> dict[str, tuple[str, ...]]:
    """The ``not_audited`` paths of a report, by repository."""
    by_repository: dict[str, set[str]] = defaultdict(set)
    for scope in report["scopes"]:
        by_repository[scope["repository"]].update(imports.excluded_paths(scope))
    return {repository: tuple(sorted(paths)) for repository, paths in by_repository.items()}


class StoredFiles:
    """The ``.sol`` files a collection stores, by ``(repository, commit, path)``."""

    def __init__(self, collection: Collection, manifest: dict[str, Any]) -> None:
        self.sources_dir = collection.sources_dir
        self.records: dict[tuple[str, str, str], dict[str, Any]] = {}
        self.files: dict[tuple[str, str, str], AuditedFile] = {}
        for source in manifest["sources"]:
            for record in source["files"]:
                if record["path"].endswith(".sol"):
                    self.records[(source["repository"], source["commit"], record["path"])] = record

    def __contains__(self, key: tuple[str, str, str]) -> bool:
        return key in self.records

    def get(self, repository: str, commit: str, path: str) -> AuditedFile | None:
        """The stored file, as an object: ``git_object`` in the manifest is the
        upstream provenance, but stored Solidity is reformatted, so the blob id is
        computed from the stored bytes, which must still be the bytes ``sha256``
        was recorded for."""
        key = (repository, commit, path)
        if key not in self.records:
            return None
        if key not in self.files:
            stored = stored_path(self.sources_dir, repository, commit, path)
            blob = stored_blob_id(stored, self.records[key]["sha256"], len(commit))
            self.files[key] = AuditedFile(path=path, blob_id=blob, stored=stored)
        return self.files[key]


def collection_audits(
    collection: Collection,
    summary: dict[str, Any],
    manifest: dict[str, Any],
    timestamps: dict[tuple[str, str], int | None],
    stored: StoredFiles,
) -> list[Audit]:
    """Audits of one collection: ``evm`` paths, fetched, full-commit, audited, with Solidity files."""
    fetched = sources_by_key(manifest)
    unavailable = unavailable_keys(manifest)
    if unavailable & fetched.keys():
        raise ExportError(f"{collection.name}: manifest lists a source as both fetched and unavailable")
    audits: list[Audit] = []
    for report in summary["reports"]:
        if not report["isRelevant"]:
            continue
        excluded = report_exclusions(report)
        for scope in report["scopes"]:
            repository = scope["repository"]
            # Only its exclusions matter here: which listed directory covers which file.
            exclusions = imports.ScopePaths((), (), excluded[repository], "", None)
            for path, path_data in scope["paths"].items():
                for version_index, version in enumerate(path_data["versions"]):
                    commit = full_commit(version["revision"])
                    if commit is None or version["status"] == "not_audited" or path_data["kind"] != "evm":
                        continue
                    path_kind = path_data["path_kind"]
                    key = (repository, path, commit)
                    if key in unavailable:
                        continue
                    source = fetched.get(key)
                    origin = (f"{collection.name}: report {report['id']!r}, "
                              f"{repository}:{path} version {version_index}")
                    if source is None:
                        raise ExportError(f"{origin} is not in the manifest; rerun fetch")
                    if source["path_kind"] != path_kind:
                        raise ExportError(f"{origin}: manifest path_kind is {source['path_kind']!r}")
                    files = tuple(
                        file
                        for record in source["files"]
                        if imports.covers(((path, path_kind),), record["path"], exclusions)
                        and (file := stored.get(repository, commit, record["path"])) is not None
                    )
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
                        partial=version["status"] not in imports.FULL_AUDIT_STATUSES,
                        files=files,
                        origin=origin,
                    ))
    return audits


def collection_expansions(
    collection: Collection,
    summary: dict[str, Any],
    manifest: dict[str, Any],
    stored: StoredFiles,
    stale: set[str],
) -> list[tuple[tuple[str, str, str], ScopeExpansion]]:
    """What the reports of one collection reach through the imports of what they
    audited in full, see ``imports``; by (repository, commit, report id).

    A manifest fetched before dependencies were followed exports what it has: an
    expansion it cannot complete is left out, and so are a reached file it does
    not store and the imports of files it did not read. The collection is then
    reported as stale.
    """
    fetched = sources_by_key(manifest)
    unavailable = unavailable_keys(manifest)
    graph = imports.graph_from_manifest(manifest)
    facts = imports.facts_from_manifest(manifest)
    legacy = manifest["schema_version"] == LEGACY_MANIFEST
    expansions: list[tuple[tuple[str, str, str], ScopeExpansion]] = []
    for report in summary["reports"]:
        for (repository, commit), scope in sorted(imports.report_scope_paths(report).items()):
            if any((repository, path, commit) in unavailable for path, _ in scope.audited):
                continue
            where = f"{collection.name}: report {report['id']!r}, {repository}@{commit}"
            files = graph.get((repository, commit))
            tree = facts.get((repository, commit), imports.NO_FACTS)

            def directory_files(directory: str) -> list[str]:
                return [record["path"] for record in fetched[(repository, directory, commit)]["files"]]

            roots = imports.scope_roots(scope, directory_files)
            expansion = imports.expand(roots, scope, files or {}, tree)
            if files is None or expansion.missing:
                if roots and not legacy:
                    missing = sorted(expansion.missing)[0] if files is not None else roots[0]
                    raise ExportError(f"{where}: imports of {missing} are not in the manifest; rerun fetch")
                stale.update([collection.name] if roots else [])
                continue
            if expansion.unread:
                if not legacy:
                    raise ExportError(f"{where}: imports of {sorted(expansion.unread)[0]} "
                                      f"are not in the manifest; rerun fetch")
                stale.add(collection.name)
            result = ScopeExpansion(collection.name, legacy, {}, {}, {}, {}, where)

            def exported(path: str) -> tuple[str, str, AuditedFile] | None:
                """Where a path of the tree is stored, when it is an exported file."""
                origin = tree.origin(path) or (repository, commit, path)
                file = stored.get(*origin)
                return None if file is None else (origin[0], origin[1], file)

            for path, reached in expansion.reached.items():
                if reached.state not in imports.REACHED_STATES or not path.endswith(".sol"):
                    continue
                located = exported(path)
                if located is None:
                    if not legacy:
                        raise ExportError(f"{where}: {path} imported by {reached.importer} "
                                          f"is not fetched; rerun fetch")
                    stale.add(collection.name)
                    continue
                result.reached[path] = (reached.state, reached.dependency)
                result.files[path] = located
            used: set[str] = set(result.reached)
            for importer in [*roots, *expansion.reached]:
                if importer not in files or exported(importer) is None:
                    continue
                result.imports[importer] = {
                    edge.import_path: (
                        edge.path if edge.path is not None and exported(edge.path) is not None else None
                    )
                    for edge in files[importer]
                }
                used.update(target for target in result.imports[importer].values() if target is not None)
            result.mounts = {
                mount: tree.mounts[mount]
                for mount in sorted({tree.mount_of(path) for path in used} - {""})
            }
            if legacy and any(edge.skipped for edges in files.values() for edge in edges):
                stale.add(collection.name)
            expansions.append(((repository, commit, report["id"]), result))
    return expansions


def add_expansion(
    expansions: dict[tuple[str, str, str], ScopeExpansion],
    key: tuple[str, str, str],
    expansion: ScopeExpansion,
) -> None:
    """A report in two collections is expanded once; a collection fetched before
    dependencies were followed yields to one fetched after."""
    previous = expansions.setdefault(key, expansion)
    if previous is expansion:
        return
    if previous.legacy != expansion.legacy:
        if previous.legacy:
            expansions[key] = expansion
        return
    if previous.collection == expansion.collection or previous.content() != expansion.content():
        raise ExportError(
            f"two collections expand report {key[2]!r} at {key[0]}@{key[1]} differently: "
            f"{previous.origin} and {expansion.origin}"
        )


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
        or previous.partial != audit.partial
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


def assemble_export(names: dict[str, str], build: Build) -> Export:
    reports = build.reports
    snapshots: dict[str, dict[str, dict[str, Any]]] = defaultdict(dict)

    def add_file(repository: str, commit: str, file: AuditedFile, where: str) -> None:
        timestamp = build.timestamps.get((repository, commit))
        if timestamp is None:
            raise ExportError(f"{where}: commit {repository}@{commit} has no timestamp")
        snapshot = snapshots[repository].setdefault(
            commit, {"timestamp": timestamp, "files": {}, "audits": {}, "mounts": {}, "imports": {}}
        )
        previous = snapshot["files"].setdefault(file.path, file)
        if previous.blob_id != file.blob_id:
            raise ExportError(f"{repository}@{commit}:{file.path} has two blob ids")

    for (repository, commit, report_id, scoped_path), audit in sorted(build.audits.items()):
        if not reports[report_id].relevant:
            raise ExportError(f"irrelevant report {report_id!r} has audits")
        for file in audit.files:
            add_file(repository, commit, file, audit.origin)
        snapshot = snapshots[repository][commit]
        if snapshot["timestamp"] != audit.timestamp:
            raise ExportError(f"{repository}@{commit} has two timestamps")
        entry = snapshot["audits"].setdefault(
            report_id, {"listed": {}, **{key: set() for key in AUDIT_LIST_KEYS}}
        )
        entry["listed"][scoped_path] = list(audit.finding_ids)
        if audit.partial:
            entry["partial"].add(scoped_path)
    for repository, commits in snapshots.items():
        for snapshot in commits.values():
            for report_id, entry in snapshot["audits"].items():
                entry["excluded"].update(
                    path for path in build.exclusions.get((report_id, repository), ())
                    if path not in entry["listed"]
                )
    for (repository, commit, report_id), expansion in sorted(build.expansions.items()):
        snapshot = snapshots.get(repository, {}).get(commit)
        entry = None if snapshot is None else snapshot["audits"].get(report_id)
        if snapshot is None or entry is None:
            continue  # none of the files it audited there is exported
        excluded_paths = sorted(entry["excluded"])
        for path, (state, dependency) in expansion.reached.items():
            # A file below a path the report excludes is excluded by that path.
            if state != imports.EXCLUDED or not any(is_under(path, other) for other in excluded_paths):
                entry[state].add(path)
            if dependency:
                entry["external"].add(path)
            add_file(*expansion.files[path], expansion.origin)
        for importer, edges in expansion.imports.items():
            merged = snapshot["imports"].setdefault(importer, {})
            for import_path, target in edges.items():
                # Two collections fetched at different times: the one that could read on wins.
                known = merged.setdefault(import_path, target)
                if known is None:
                    merged[import_path] = target
                elif target is not None and target != known:
                    raise ExportError(f"{expansion.origin}: {importer} imports {import_path!r} "
                                      f"as {target} and as {known}")
        for mount, target in expansion.mounts.items():
            if snapshot["mounts"].setdefault(mount, target) != target:
                raise ExportError(f"{expansion.origin}: {mount} is mounted at two commits")
    objects = read_objects({
        file.blob_id: file.stored
        for repository in snapshots.values()
        for snapshot in repository.values()
        for file in snapshot["files"].values()
    })
    index = {
        "schema_version": SCHEMA_VERSION,
        "collections": {
            collection: {"name": names[collection], "kind": collection_kind(collection)}
            for collection in sorted(names)
        },
        "reports": {
            report_id: {
                "collections": sorted(record.documents),
                "title": record.title,
                "auditor": record.auditor,
                "date": record.date,
                "document": record.documents[min(record.documents)],
                "evm_scope": record.evm_scope,
                "unlisted": record.unlisted,
                "dependencies": record.dependencies,
            }
            for report_id, record in sorted(reports.items())
            if record.relevant
        },
        "repositories": {
            repository: ordered_snapshots(snapshots[repository])
            for repository in sorted(snapshots)
        },
    }
    return Export(index=index, objects=objects, manifest_paths=build.manifest_paths,
                  stale=sorted(build.stale), outdated=[], unread=[])


def collection_kind(collection: str) -> str:
    """Collections under ``_libs/`` hold code reused across projects; the others are projects."""
    return "library" if collection.startswith(f"{LIBRARIES_DIR}/") else "project"


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
                    "listed": dict(sorted(entry["listed"].items())),
                    **{key: sorted(entry[key]) for key in AUDIT_LIST_KEYS if entry[key]},
                }
                for report_id, entry in sorted(snapshot["audits"].items())
            },
        }
        if snapshot["mounts"]:
            ordered[commit]["mounts"] = {
                mount: {"repository": repository, "commit": mounted}
                for mount, (repository, mounted) in sorted(snapshot["mounts"].items())
            }
        if snapshot["imports"]:
            ordered[commit]["imports"] = {
                path: dict(sorted(edges.items()))
                for path, edges in sorted(snapshot["imports"].items())
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
    problems = check_written(root, index_text, objects_text)
    if problems:
        raise ExportError("the written export does not verify: " + "; ".join(problems))


def check_committed(root: Path, export: Export, index_text: bytes, objects_text: bytes) -> list[str]:
    """The export on disk must be up to date, every report document and file a manifest
    names committed, and every object the committed blob of a stored file.

    Opening a path succeeds on a case-insensitive filesystem whatever its letter
    case, so paths are compared with the git index, which keeps their exact case.
    """
    problems = check_written(root, index_text, objects_text)
    try:
        committed = committed_blob_ids(root)
    except ExportError as error:
        return problems + [str(error)]
    documents = {report["document"] for report in export.index["reports"].values()}
    problems += uncommitted_problems(committed, documents, "a report document")
    problems += uncommitted_problems(committed, export.manifest_paths, "named by its manifest")
    problems += uncommitted_object_problems(committed, export)
    return problems


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
        problems.append(f"{INDEX_NAME} is out of date; run export")
    if written_objects != objects_text:
        problems.append(f"{OBJECTS_NAME} is out of date; run export")
    return problems


def committed_blob_ids(root: Path) -> dict[str, str]:
    """The staged blob id of every file in the git index below the dataset root, by exact path."""
    try:
        listing = run(root, "ls-files", "--stage", "-z")
    except GitError as error:
        raise ExportError(f"cannot list the committed files: {error}") from error
    try:
        entries = listing.decode("utf-8", errors="strict").split("\0")
    except UnicodeDecodeError as error:
        raise ExportError(f"git ls-files listed a path that is not UTF-8: {error}") from error
    blob_ids: dict[str, str] = {}
    for entry in entries:
        if not entry:
            continue
        info, path = entry.split("\t", 1)  # "<mode> <blob id> <stage>\t<path>"
        _, staged_blob_id, stage = info.split(" ")
        if stage != "0":
            raise ExportError(f"{path} has an unresolved merge conflict")
        blob_ids[path] = staged_blob_id
    return blob_ids


def uncommitted_object_problems(committed: dict[str, str], export: Export) -> list[str]:
    """Every object must be the committed blob of a stored file, so that GitHub's blob API
    serves it by the SHA-1 blob id of its contents.

    A stored copy committed with converted line endings, or changed on disk
    without being committed, is another blob; one matching copy is enough.
    """
    stored_blob_ids = {committed[path] for path in export.manifest_paths if path in committed}
    problems: list[str] = []
    for object_id, text in sorted(export.objects.items()):
        full_id = blob_id(text.encode("utf-8"), 40)  # SHA-1, whatever the source repository
        if full_id not in stored_blob_ids:
            problems.append(f"object {object_id}: blob {full_id} is not the committed blob "
                            f"of any stored file")
    return problems


def uncommitted_problems(committed: dict[str, str], paths: set[str], role: str) -> list[str]:
    """Paths that are not committed with exactly their letter case."""
    missing = sorted(paths - committed.keys())
    if not missing:
        return []
    committed_by_folded_case = {path.casefold(): path for path in committed}
    problems: list[str] = []
    for path in missing:
        committed_as = committed_by_folded_case.get(path.casefold())
        if committed_as is None:
            problems.append(f"{path} ({role}) is not committed")
        else:
            problems.append(f"{path} ({role}) is committed in another letter case, as {committed_as}")
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
    collections = export.index["collections"].values()
    reports = export.index["reports"]
    snapshots = [s for commits in export.index["repositories"].values() for s in commits.values()]
    audits = [audit for s in snapshots for audit in s["audits"].values()]
    audited_reports = {report_id for s in snapshots for report_id in s["audits"]}
    reached = {key: sum(len(audit.get(key, ())) for audit in audits) for key in REACHED_KEYS}
    print(
        f"{len(collections)} collections "
        f"({sum(1 for c in collections if c['kind'] == 'library')} libraries), "
        f"{len(reports)} reports ({len(audited_reports)} with audits, "
        f"{len(reports) - len(audited_reports)} without, "
        f"{sum(1 for r in reports.values() if r['unlisted'] is not None)} read for unlisted code), "
        f"{len(export.index['repositories'])} repositories, "
        f"{len(snapshots)} snapshots ({sum(1 for s in snapshots if not s['audits'])} of dependencies only), "
        f"{sum(len(s['files']) for s in snapshots)} files, "
        f"{sum(len(audit['listed']) for audit in audits)} listed paths in {len(audits)} report audits, "
        f"{sum(1 for audit in audits for ids in audit['listed'].values() if ids)} paths with open findings, "
        f"{reached['implied']} implied, {reached['excluded']} excluded, "
        f"{reached['included']} included and {reached['visible']} visible paths, "
        f"{sum(len(edges) for s in snapshots for edges in s.get('imports', {}).values())} imports, "
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
    problems += validate_collections(index["collections"])
    problems += validate_reports(index["reports"], index["collections"])
    algorithms: dict[str, set[str]] = defaultdict(set)
    referenced: set[tuple[str, str, str]] = set()
    for repository, commits in index["repositories"].items():
        problems += validate_repository(
            repository, commits, index["reports"], objects, algorithms, index["repositories"], referenced
        )
    if not problems:
        problems += unreferenced_files(index["repositories"], referenced)
    problems += validate_objects(objects, algorithms)
    return problems


def unreferenced_files(repositories: dict[str, Any], referenced: set[tuple[str, str, str]]) -> list[str]:
    """Every file must be listed by a report, reached by one, or imported by a file one read."""
    problems: list[str] = []
    for repository, commits in repositories.items():
        for commit, snapshot in commits.items():
            listed = {path for audit in snapshot["audits"].values() for path in audit["listed"]}
            for path in snapshot["files"]:
                if listed.isdisjoint(path_and_ancestors(path)) and (repository, commit, path) not in referenced:
                    problems.append(f"{repository}@{commit}: file {path} is in no report's scope")
    return problems


def resolve_path(
    repositories: dict[str, Any], repository: str, commit: str, path: str
) -> tuple[str, str, str] | None:
    """The ``(repository, commit, path)`` holding a path of a snapshot, through the
    snapshot's mounts; None when no file is exported there."""
    mounts = repositories[repository][commit].get("mounts", {})
    mount = max((mount for mount in mounts if is_under(path, mount) and path != mount), key=len, default=None)
    if mount is not None:
        target = mounts[mount]
        if not isinstance(target, dict):
            return None
        repository, commit, path = target.get("repository"), target.get("commit"), path[len(mount) + 1:]
    snapshot = repositories.get(repository, {}).get(commit)
    if not isinstance(snapshot, dict) or path not in snapshot.get("files", {}):
        return None
    return repository, commit, path


def validate_top_level(index: dict[str, Any]) -> list[str]:
    maps = ["collections", "reports", "repositories"]
    if list(index) != ["schema_version", *maps]:
        return [f"index keys must be schema_version, {', '.join(maps)}; got {list(index)}"]
    if index["schema_version"] != SCHEMA_VERSION:
        return [f"schema_version must be {SCHEMA_VERSION!r}"]
    if not all(isinstance(index[key], dict) for key in maps):
        return [f"{', '.join(maps)} must be objects"]
    return [f"{key} are not sorted by id" for key in maps if list(index[key]) != sorted(index[key])]


def validate_collections(collections: dict[str, Any]) -> list[str]:
    problems: list[str] = []
    collection_by_name: dict[str, str] = {}
    for collection, entry in collections.items():
        where = f"collection {collection!r}"
        problem = collection_id_problem(collection)
        if problem is not None:
            problems.append(f"{where}: id {problem}")
            continue
        if not isinstance(entry, dict) or list(entry) != ["name", "kind"]:
            problems.append(f"{where} keys must be name, kind")
            continue
        name = entry["name"]
        if not isinstance(name, str) or not name or name != name.strip():
            problems.append(f"{where}: name must be a non-empty string without surrounding spaces")
        elif collection_by_name.setdefault(name, collection) != collection:
            problems.append(f"{where}: name {name!r} is also the name of {collection_by_name[name]!r}")
        if entry["kind"] != collection_kind(collection):
            problems.append(f"{where}: kind must be {collection_kind(collection)!r}")
    return problems


def collection_id_problem(collection: str) -> str | None:
    """A collection id is its directory: ``<project>`` or ``_libs/<vendor>``."""
    problem = path_problem(collection)
    if problem is not None:
        return problem
    segments = collection.split("/")
    if segments[0] == LIBRARIES_DIR:
        if len(segments) != 2:
            return f"must be {LIBRARIES_DIR}/<vendor>"
    elif len(segments) != 1:
        return f"must be a project directory or {LIBRARIES_DIR}/<vendor>"
    return None


def validate_reports(reports: dict[str, Any], collections: dict[str, Any]) -> list[str]:
    problems: list[str] = []
    for report_id, report in reports.items():
        where = f"report {report_id!r}"
        if not report_id or not isinstance(report, dict):
            problems.append(f"{where} must be a non-empty id with an object")
            continue
        if list(report) != REPORT_KEYS:
            problems.append(f"{where} keys must be {', '.join(REPORT_KEYS)}")
            continue
        if report["evm_scope"] not in EVM_SCOPES:
            problems.append(f"{where}: evm_scope must be one of {', '.join(EVM_SCOPES)}")
        if report["unlisted"] is not None and report["unlisted"] not in UNLISTED_VALUES:
            problems.append(f"{where}: unlisted must be null or one of {sorted(UNLISTED_VALUES)}")
        if report["dependencies"] is not None and report["dependencies"] not in DEPENDENCIES_VALUES:
            problems.append(f"{where}: dependencies must be null or one of {sorted(DEPENDENCIES_VALUES)}")
        report_collections = report["collections"]
        if (
            not isinstance(report_collections, list)
            or not report_collections
            or not all(isinstance(name, str) and name for name in report_collections)
            or report_collections != sorted(set(report_collections))
        ):
            problems.append(f"{where}: collections must be a sorted, unique, non-empty list")
        else:
            problems += [f"{where}: collection {name!r} is not listed in collections"
                         for name in report_collections if name not in collections]
            problem = document_problem(report["document"], report_collections[0])
            if problem is not None:
                problems.append(f"{where}: document {problem}")
        for key in ("title", "auditor"):
            if not isinstance(report[key], str) or not report[key].strip():
                problems.append(f"{where}: {key} must be a non-empty string")
        if report["date"] is not None and not valid_date(report["date"]):
            problems.append(f"{where}: date must be null or YYYY-MM-DD, got {report['date']!r}")
    return problems


def document_problem(document: Any, collection: str) -> str | None:
    """A report links its document in the first of its collections."""
    problem = path_problem(document)
    if problem is not None:
        return problem
    if not document.startswith(f"{collection}/{REPORTS_DIR}/"):
        return f"must be under {collection}/{REPORTS_DIR}/"
    if PurePosixPath(document).suffix not in DOCUMENT_SUFFIXES:
        return f"must end with one of {', '.join(DOCUMENT_SUFFIXES)}"
    return None


def validate_repository(
    repository: str,
    commits: Any,
    reports: dict[str, Any],
    objects: dict[str, Any],
    algorithms: dict[str, set[str]],
    repositories: dict[str, Any],
    referenced: set[tuple[str, str, str]],
) -> list[str]:
    problems: list[str] = []
    problem = repository_id_problem(repository)
    if problem is not None:
        problems.append(f"repository id {repository!r} is not a canonical id: {problem}")
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
        if not isinstance(snapshot, dict) or not snapshot_keys_valid(list(snapshot)):
            problems.append(f"{where}: snapshot keys must be timestamp, files, audits "
                            f"and then, when not empty, mounts, imports")
            continue
        timestamp = snapshot["timestamp"]
        if type(timestamp) is not int or timestamp <= 0:
            problems.append(f"{where}: timestamp must be positive unix seconds")
            continue
        order.append((timestamp, commit))
        problems += validate_snapshot(where, repository, commit, snapshot, reports, objects,
                                      repositories, referenced)
        if isinstance(snapshot["files"], dict):
            for object_id in snapshot["files"].values():
                if isinstance(object_id, str):
                    algorithms[object_id].add(hash_algorithm(len(commit)))
    if [commit for _, commit in sorted(order)] != [commit for _, commit in order]:
        problems.append(f"{repository}: commits are not ordered by timestamp, then commit id")
    return problems


def snapshot_keys_valid(keys: list[str]) -> bool:
    required = ["timestamp", "files", "audits"]
    return keys[:3] == required and keys[3:] in (
        [], ["mounts"], ["imports"], ["mounts", "imports"]
    )


def repository_id_problem(repository: str) -> str | None:
    """Consumers derive a repository's URL from its id, so the id must survive the round trip."""
    problem = path_problem(repository)
    if problem is not None:
        return problem
    url = repository_url(repository)
    try:
        canonical = canonical_repository_id(url)
    except DatasetError as error:
        return str(error)
    if canonical != repository:
        return f"its URL {url} has the canonical id {canonical!r}"
    return None


def validate_snapshot(
    where: str,
    repository: str,
    commit: str,
    snapshot: dict[str, Any],
    reports: dict[str, Any],
    objects: dict[str, Any],
    repositories: dict[str, Any],
    referenced: set[tuple[str, str, str]],
) -> list[str]:
    problems: list[str] = []
    files, audits = snapshot["files"], snapshot["audits"]
    if not isinstance(files, dict) or not files or not isinstance(audits, dict):
        return [f"{where}: files must be a non-empty object and audits an object"]
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
    problems += validate_mounts(where, snapshot.get("mounts"), repositories, "mounts" in snapshot)
    if problems:
        return problems

    def resolves(path: Any) -> bool:
        """Whether a path of this snapshot names an exported file; remembers that it is used."""
        if path_problem(path) is not None:
            return False
        target = resolve_path(repositories, repository, commit, path)
        if target is not None:
            referenced.add(target)
        return target is not None

    for report_id, audit in audits.items():
        if report_id not in reports:
            problems.append(f"{where}: audit by unknown report {report_id!r}")
            continue
        problems += validate_audit(f"{where} {report_id}", audit, covered_prefixes, reports[report_id], resolves)
    problems += validate_imports(where, snapshot.get("imports"), "imports" in snapshot, resolves)
    return problems


def validate_mounts(where: str, mounts: Any, repositories: dict[str, Any], present: bool) -> list[str]:
    if not present:
        return []
    if not isinstance(mounts, dict) or not mounts:
        return [f"{where}: mounts must be a non-empty object"]
    problems: list[str] = []
    if list(mounts) != sorted(mounts):
        problems.append(f"{where}: mounts must be sorted by path")
    for mount, target in mounts.items():
        problem = path_problem(mount)
        if problem is not None:
            problems.append(f"{where}: mount path {mount!r} {problem}")
        if not isinstance(target, dict) or list(target) != ["repository", "commit"]:
            problems.append(f"{where}: mount {mount!r} keys must be repository, commit")
        elif not isinstance(repositories.get(target["repository"], {}).get(target["commit"]), dict):
            problems.append(f"{where}: mount {mount!r} names no exported snapshot")
    return problems


def validate_audit(
    where: str, audit: Any, covered_prefixes: set[str], report: dict[str, Any], resolves: Any
) -> list[str]:
    keys = list(audit) if isinstance(audit, dict) else []
    if keys[:1] != ["listed"] or keys[1:] != [key for key in AUDIT_LIST_KEYS if key in keys[1:]]:
        return [f"{where}: keys must be listed and then, when not empty, {', '.join(AUDIT_LIST_KEYS)}"]
    listed = audit["listed"]
    if not isinstance(listed, dict) or not listed:
        return [f"{where}: must map at least one listed path to its findings"]
    problems: list[str] = []
    if list(listed) != sorted(listed):
        problems.append(f"{where}: listed paths must be sorted")
    for path, finding_ids in listed.items():
        problem = path_problem(path)
        if problem is not None:
            problems.append(f"{where}: listed path {path!r} {problem}")
        elif path not in covered_prefixes:
            problems.append(f"{where}: listed path {path!r} covers no file")
        if (
            not isinstance(finding_ids, list)
            or not all(isinstance(finding_id, str) and finding_id for finding_id in finding_ids)
            or len(set(finding_ids)) != len(finding_ids)
        ):
            problems.append(f"{where}: findings of {path!r} must be unique non-empty strings")
    for key in keys[1:]:
        paths = audit[key]
        if (
            not isinstance(paths, list) or not paths
            or paths != sorted(set(path for path in paths if isinstance(path, str)))
        ):
            return problems + [f"{where}: {key} must be a sorted, unique, non-empty list of paths"]
        problems += [
            f"{where}: {key} path {path!r} {problem}"
            for path in paths if (problem := path_problem(path)) is not None
        ]
    if problems:
        return problems
    problems += [f"{where}: partial path {path!r} is not listed"
                 for path in audit.get("partial", []) if path not in listed]
    problems += [f"{where}: excluded path {path!r} is also listed"
                 for path in audit.get("excluded", []) if path in listed]
    reached = [path for key in REACHED_KEYS for path in audit.get(key, [])]
    if len(set(reached)) != len(reached):
        problems.append(f"{where}: a path is in two of {', '.join(REACHED_KEYS)}")
    # An excluded path may be a directory, or a file the dataset does not store.
    for key in ("implied", "included", "visible", "external"):
        problems += [f"{where}: {key} path {path!r} names no exported file"
                     for path in audit.get(key, []) if not resolves(path)]
    for path in audit.get("excluded", []):
        resolves(path)
    if ("implied" in audit or "visible" in audit) and report["unlisted"] != "not_mentioned":
        problems.append(f"{where}: implied and visible paths need a report that does not mention unlisted code")
    if "included" in audit and report["dependencies"] != "included":
        problems.append(f"{where}: included paths need a report that includes its dependencies")
    if any(key in audit for key in ("implied", "included", "visible", "external")) and report["unlisted"] is None:
        problems.append(f"{where}: reached paths need a report read for unlisted code")
    return problems


def validate_imports(where: str, imports_by_file: Any, present: bool, resolves: Any) -> list[str]:
    if not present:
        return []
    if not isinstance(imports_by_file, dict) or not imports_by_file:
        return [f"{where}: imports must be a non-empty object"]
    problems: list[str] = []
    if list(imports_by_file) != sorted(imports_by_file):
        problems.append(f"{where}: imports must be sorted by file")
    for path, edges in imports_by_file.items():
        if not resolves(path):
            problems.append(f"{where}: imports of {path!r}, which names no exported file")
        if not isinstance(edges, dict) or list(edges) != sorted(edges):
            problems.append(f"{where}: imports of {path!r} must be an object sorted by import")
            continue
        for import_path, target in edges.items():
            if not import_path:
                problems.append(f"{where}: {path} has an empty import")
            if target is not None and not resolves(target):
                problems.append(f"{where}: {path} imports {import_path!r} as {target!r}, "
                                f"which names no exported file")
    return problems


def path_and_ancestors(path: str) -> list[str]:
    """``a/b/c.sol`` -> ``a``, ``a/b``, ``a/b/c.sol``: the scoped paths covering it."""
    parts = path.split("/")
    return ["/".join(parts[:count]) for count in range(1, len(parts) + 1)]


def validate_objects(objects: dict[str, Any], algorithms: dict[str, set[str]]) -> list[str]:
    problems = [f"object {object_id} is used by no file"
                for object_id in sorted(objects.keys() - algorithms.keys())]
    for object_id in sorted(objects.keys() & algorithms.keys()):
        text = objects[object_id]
        if not OBJECT_ID_RE.fullmatch(object_id) or not isinstance(text, str):
            problems.append(f"object {object_id!r} must map a 12-hex id to a string")
            continue
        try:
            data = text.encode("utf-8", errors="strict")
        except UnicodeEncodeError:
            problems.append(f"object {object_id} is not valid UTF-8")
            continue
        for algorithm in sorted(algorithms[object_id]):
            length = 40 if algorithm == "sha1" else 64
            if not blob_id(data, length).startswith(object_id):
                problems.append(f"object {object_id} does not hash to its id ({algorithm})")
    return problems
