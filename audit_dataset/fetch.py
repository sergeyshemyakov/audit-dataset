"""Fetch the audited sources of a collection into ``audited-sources/``.

Only versions of relevant reports that pin a full commit, are not
``not_audited`` and belong to a path of a fetched kind (``evm`` unless
``--kinds`` says otherwise) are fetched; every other version is recorded in
the manifest as skipped, with the reason. A directory scope stores only the
source files of its kind (``.sol``, ``.yul`` and ``.vy`` for ``evm``); a file
scope stores its file whatever the extension. Files are read straight from a bare clone's objects, never from a
checkout, and stored at ``<repository>/<commit>/<path>`` (see ``manifest``).

For reports that opted in to import expansion (see ``imports``), the files their
fully audited Solidity files import are fetched as file sources too, and the
resolved imports are recorded in the manifest.
"""

from __future__ import annotations

import hashlib
import shutil
import stat
import tempfile
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path, PurePosixPath
from typing import Any

from . import DatasetError
from . import git
from . import imports
from .collections import Collection
from .manifest import GIT_METADATA_FILES, SCHEMA_VERSION, stored_path, write_manifest
from .summary import path_problem, read_summary, relevant_versions

# Path kinds whose sources are fetched by default; see summary.KINDS for all of them.
FETCHED_KINDS = frozenset({"evm"})
# Files stored from a directory scope of each kind; a file scope stores its file whatever
# the extension. Other files (build artifacts, fixtures, bindings, docs) are not audit
# evidence of that kind and are left out without a manifest record.
SOURCE_EXTENSIONS: dict[str, frozenset[str]] = {
    "evm": frozenset({".sol", ".yul", ".vy"}),
}
BLOB_MODES = frozenset({"100644", "100755"})
SYMLINK_MODE = "120000"
SUBMODULE_MODE = "160000"


class FetchError(DatasetError):
    """A source could not be fetched safely or exactly."""


class MissingSymlinkTarget(FetchError):
    """A repository-internal symlink points to no entry in the pinned commit."""


@dataclass(frozen=True, order=True)
class Source:
    repository: str
    path: str
    path_kind: str
    commit: str
    kind: str

    def stores(self, path: str) -> bool:
        """Whether a file under this source is stored."""
        if self.path_kind == "file":
            return True
        extensions = SOURCE_EXTENSIONS.get(self.kind)
        return extensions is None or PurePosixPath(path).suffix.lower() in extensions


@dataclass(frozen=True, order=True)
class SkippedSource:
    repository: str
    path: str
    revision_kind: str
    revision: str
    reason: str


@dataclass(frozen=True)
class ResolvedBlob:
    path: str
    mode: str
    object_id: str
    symlink_chain: tuple[tuple[str, str, str], ...]


@dataclass
class FetchResult:
    sources: int = 0
    files: int = 0
    skipped: int = 0
    unavailable: int = 0
    omitted: int = 0
    manifest_path: Path | None = None
    warnings: list[str] = field(default_factory=list)


# --- What to fetch ------------------------------------------------------------


def repository_urls(summary: dict[str, Any]) -> dict[str, str]:
    """One URL per repository id over the relevant reports."""
    urls: dict[str, str] = {}
    for report in summary["reports"]:
        if not report["isRelevant"]:
            continue
        for repository in report["repositories"]:
            url = repository["url"].strip()
            if url.startswith("-"):
                raise FetchError(f"invalid URL for repository {repository['id']!r}")
            previous = urls.setdefault(repository["id"], url)
            if previous != url:
                raise FetchError(
                    f"repository {repository['id']!r} has conflicting URLs: {previous!r} and {url!r}"
                )
    return urls


def revision_label(revision: dict[str, Any]) -> str:
    for key in ("commit", "tag", "ref", "url"):
        value = revision.get(key)
        if isinstance(value, str) and value:
            return value
    return ""


def collect_sources(
    summary: dict[str, Any], kinds: frozenset[str] = FETCHED_KINDS
) -> tuple[list[Source], list[SkippedSource]]:
    """What to fetch and what to record as skipped.

    A version is skipped when its revision pins no full commit, or when its
    path's kind is not fetched (only ``evm`` by default). ``not_audited``
    versions are neither fetched nor recorded.
    """
    sources: set[Source] = set()
    skipped: set[SkippedSource] = set()
    path_kinds: dict[tuple[str, str, str], str] = {}
    for _, repository, path, path_data, _, version in relevant_versions(summary):
        revision = version["revision"]
        commit = git.full_commit(revision)
        if commit is None:
            reason = (
                "revision is not a commit" if revision["kind"] != "commit"
                else "commit is not a full 40- or 64-hex object id"
            )
            skipped.add(SkippedSource(repository, path, revision["kind"], revision_label(revision), reason))
            continue
        if version["status"] == "not_audited":
            continue
        if path_data["kind"] not in kinds:
            skipped.add(SkippedSource(
                repository, path, revision["kind"], commit, f"path kind {path_data['kind']} is not fetched"
            ))
            continue
        key = (repository, path, commit)
        path_kind = path_data["path_kind"]
        if path_kinds.setdefault(key, path_kind) != path_kind:
            raise FetchError(f"conflicting path kinds for {repository}:{path}@{commit}")
        sources.add(Source(repository, path, path_kind, commit, path_data["kind"]))
    return sorted(sources), sorted(skipped)


# --- Git access ---------------------------------------------------------------


def repository_reachable(url: str) -> bool:
    try:
        git.run(None, "ls-remote", "--exit-code", url, "HEAD")
    except git.GitError:
        return False
    return True


def initialize_repository(directory: Path, url: str, object_format: str) -> None:
    args = ["init", "--bare", "--quiet"]
    if object_format == "sha256":
        args.append("--object-format=sha256")
    git.run(None, *args, str(directory))
    git.run(directory, "remote", "add", "origin", url)


def verify_exact_commit(repository: Path, commit: str) -> None:
    resolved = git.run_text(repository, "rev-parse", "--verify", "--quiet", f"{commit}^{{commit}}").strip()
    if resolved.lower() != commit:
        raise FetchError(f"fetched object resolved to {resolved}, expected exact commit {commit}")


def fetch_commits(
    repository: Path, commits: list[str], full_commits: set[str], warnings: list[str]
) -> set[str]:
    """Fetch the commits; return those that could not be fetched.

    Everything is first requested in one ``--filter=blob:none`` fetch, which
    brings commits and trees but no file contents; blobs of file sources are
    then read lazily. Commits with directory sources are fetched again with all
    their blobs, since lazy per-file reads would be slow there.
    """
    partial = ["fetch", "--quiet", "--no-tags", "--depth=1", "--filter=blob:none", "origin"]
    full = ["fetch", "--quiet", "--no-tags", "--depth=1", "origin"]
    missing: set[str] = set()
    try:
        git.run(repository, *partial, *commits)
    except git.GitError:
        for commit in commits:
            try:
                git.run(repository, *partial, commit)
            except git.GitError as error:
                warnings.append(str(error))
                missing.add(commit)
    wanted = [commit for commit in commits if commit in full_commits and commit not in missing]
    if wanted:
        try:
            git.run(repository, *full, *wanted)
        except git.GitError:
            for commit in wanted:
                try:
                    git.run(repository, *full, commit)
                except git.GitError as error:
                    warnings.append(str(error))
                    missing.add(commit)
    for commit in commits:
        if commit not in missing:
            verify_exact_commit(repository, commit)
    return missing


def resolve_symlink_target(link_path: str, raw_target: bytes) -> tuple[str, str]:
    try:
        target = raw_target.decode("utf-8")
    except UnicodeDecodeError as error:
        raise FetchError(f"symlink at {link_path!r} has a non-UTF-8 target") from error
    if not target or "\\" in target:
        raise FetchError(f"symlink at {link_path!r} has an unsupported target: {target!r}")
    target_path = PurePosixPath(target)
    if target_path.is_absolute():
        raise FetchError(f"symlink at {link_path!r} has an absolute target: {target!r}")
    resolved_parts = list(PurePosixPath(link_path).parent.parts)
    for part in target_path.parts:
        if part in {"", "."}:
            continue
        if part == "..":
            if not resolved_parts:
                raise FetchError(f"symlink at {link_path!r} escapes the repository: {target!r}")
            resolved_parts.pop()
        else:
            resolved_parts.append(part)
    if not resolved_parts:
        raise FetchError(f"symlink at {link_path!r} does not resolve to a file: {target!r}")
    return target, PurePosixPath(*resolved_parts).as_posix()


def exact_tree_entry(repository: Path, commit: str, path: str) -> tuple[str, str, str, str]:
    entries = git.ls_tree(repository, commit, path, recursive=False)
    if len(entries) != 1 or entries[0][3] != path:
        raise MissingSymlinkTarget(f"symlink target is missing at {path!r} in commit {commit}")
    return entries[0]


def resolve_blob(repository: Path, commit: str, path: str, mode: str, object_id: str) -> ResolvedBlob:
    """Follow repository-internal symlinks to the blob they finally name."""
    chain: list[tuple[str, str, str]] = []
    seen: set[str] = set()
    while mode == SYMLINK_MODE:
        if path in seen:
            raise FetchError(f"symlink cycle detected at {path!r}")
        seen.add(path)
        target, resolved_path = resolve_symlink_target(path, git.read_blob(repository, object_id))
        chain.append((path, target, object_id))
        mode, object_type, object_id, _ = exact_tree_entry(repository, commit, resolved_path)
        if object_type != "blob":
            raise MissingSymlinkTarget(f"symlink at {path!r} resolves to non-file {resolved_path!r}")
        path = resolved_path
    if mode not in BLOB_MODES:
        raise FetchError(f"unsupported Git mode {mode} at {path!r}")
    return ResolvedBlob(path, mode, object_id, tuple(chain))


def write_blob(repository: Path, object_id: str, target: Path, mode: str) -> str:
    content = git.read_blob(repository, object_id)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(content)
    permissions = stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH
    if mode == "100755":
        permissions |= stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
    target.chmod(permissions)
    return hashlib.sha256(content).hexdigest()


# --- Storing ------------------------------------------------------------------


class Store:
    """The staged ``audited-sources`` tree of one fetch run.

    A file is written once however many sources cover it, and two stored paths
    that differ only by case are rejected: the dataset must look the same on
    case-insensitive and case-sensitive filesystems.
    """

    def __init__(self, staging: Path) -> None:
        self.staging = staging
        self.written: dict[str, tuple[str, str]] = {}  # stored path -> (object id, sha256)
        self.by_folded_path: dict[str, str] = {}

    def store(self, repository: Path, source: Source, path: str, resolved: ResolvedBlob) -> str:
        target = stored_path(self.staging, source.repository, source.commit, path)
        key = target.relative_to(self.staging).as_posix()
        previous = self.written.get(key)
        if previous is not None:
            if previous[0] != resolved.object_id:
                raise FetchError(f"{key} is stored with two different contents")
            return previous[1]
        folded = key.lower()
        other = self.by_folded_path.get(folded)
        if other is not None:
            raise FetchError(f"stored paths differ only by case: {other!r} and {key!r}")
        digest = write_blob(repository, resolved.object_id, target, resolved.mode)
        self.written[key] = (resolved.object_id, digest)
        self.by_folded_path[folded] = key
        return digest


def file_record(path: str, object_id: str, mode: str, resolved: ResolvedBlob, digest: str) -> dict[str, Any]:
    record: dict[str, Any] = {"path": path, "git_object": object_id, "git_mode": mode, "sha256": digest}
    if resolved.symlink_chain:
        record["symlink_chain"] = [
            {"path": link_path, "target": link_target, "git_object": link_object}
            for link_path, link_target, link_object in resolved.symlink_chain
        ]
        record["resolved_path"] = resolved.path
        record["resolved_git_object"] = resolved.object_id
        record["resolved_git_mode"] = resolved.mode
    return record


def omitted_record(path: str, object_id: str, mode: str, reason: str) -> dict[str, str]:
    return {"path": path, "git_object": object_id, "git_mode": mode, "reason": reason}


def tree_entries(repository: Path, source: Source) -> list[tuple[str, str, str, str]]:
    """The entries a source covers, as ``(mode, type, object id, path)``."""
    entries = git.ls_tree(repository, source.commit, source.path, source.path_kind == "directory_recursive")
    if source.path_kind == "file":
        if len(entries) != 1 or entries[0][3] != source.path or entries[0][1] not in {"blob", "commit"}:
            raise FetchError(f"expected a file at {source.repository}:{source.path}@{source.commit}")
        return entries
    if not entries:
        raise FetchError(f"expected a non-empty directory at {source.repository}:{source.path}@{source.commit}")
    prefix = source.path + "/"
    for _, object_type, _, name in entries:
        if not name.startswith(prefix) or object_type not in {"blob", "commit"}:
            raise FetchError(f"unexpected Git tree entry {name!r} in {source.path!r}")
        problem = path_problem(name)
        if problem is not None:
            raise FetchError(f"tree entry {name!r} {problem}")
    return entries


def export_source(repository: Path, source: Source, store: Store) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    files: list[dict[str, Any]] = []
    omitted: list[dict[str, str]] = []
    for mode, object_type, object_id, path in tree_entries(repository, source):
        if not source.stores(path):
            continue
        if object_type == "commit" or mode == SUBMODULE_MODE:
            omitted.append(omitted_record(path, object_id, mode, "submodule"))
            continue
        if PurePosixPath(path).name in GIT_METADATA_FILES:
            omitted.append(omitted_record(path, object_id, mode, "git metadata file"))
            continue
        try:
            resolved = resolve_blob(repository, source.commit, path, mode, object_id)
        except MissingSymlinkTarget as error:
            omitted.append(omitted_record(path, object_id, mode, str(error)))
            continue
        digest = store.store(repository, source, path, resolved)
        files.append(file_record(path, object_id, mode, resolved, digest))
    return files, omitted


# --- Import expansion ---------------------------------------------------------


@dataclass
class CommitTree:
    """The files of one commit and what is known about their imports."""

    files: dict[str, tuple[str, str]]  # path -> (mode, object id) of every blob or symlink
    gitlinks: frozenset[str]
    projects: dict[str, imports.Project]
    graph: dict[str, list[imports.Edge]]


def collect_import_scopes(summary: dict[str, Any]) -> dict[tuple[str, str], list[imports.ScopePaths]]:
    """The scopes whose imports are expanded, by ``(repository, commit)``."""
    scopes: dict[tuple[str, str], list[imports.ScopePaths]] = defaultdict(list)
    for report in summary["reports"]:
        for key, scope in imports.report_scope_paths(report).items():
            scopes[key].append(scope)
    return scopes


def add_imported_sources(
    repository: Path,
    repository_id: str,
    by_commit: dict[str, list[Source]],
    missing: set[str],
    import_scopes: dict[tuple[str, str], list[imports.ScopePaths]],
    import_graph: dict[tuple[str, str], dict[str, list[imports.Edge]]],
) -> None:
    """Add a file source for every file an expansion adds, and record the resolved imports."""
    scopes_by_commit = {
        commit: import_scopes[(repository_id, commit)]
        for commit in by_commit
        if commit not in missing and (repository_id, commit) in import_scopes
    }
    if not scopes_by_commit:
        return
    graph, imported = expand_imports(repository, scopes_by_commit)
    for commit, files in graph.items():
        import_graph[(repository_id, commit)] = files
    for commit, path in sorted(imported):
        source = Source(repository_id, path, "file", commit, "evm")
        for other in by_commit[commit]:
            if (other.path, other.path_kind) == (path, "directory_recursive"):
                raise FetchError(f"imported file {path!r} is also a directory scope at {commit}")
        if source not in by_commit[commit]:
            by_commit[commit].append(source)


def expand_imports(
    repository: Path, scopes_by_commit: dict[str, list[imports.ScopePaths]]
) -> tuple[dict[str, dict[str, list[imports.Edge]]], set[tuple[str, str]]]:
    """Resolve imports level by level until every expansion is complete.

    Returns the resolved imports of every reached file, by commit, and the
    ``(commit, path)`` of every file some expansion adds. Each round fetches the
    blobs of all newly reached files of the repository in one request.
    """
    trees = {commit: read_commit_tree(repository, commit) for commit in sorted(scopes_by_commit)}
    file_count = sum(len(tree.files) for tree in trees.values())
    for _ in range(file_count + 1):
        expansions = [
            (commit, commit_expansion(trees[commit], scope))
            for commit, scopes in sorted(scopes_by_commit.items())
            for scope in scopes
        ]
        missing = {(commit, path) for commit, expansion in expansions for path in expansion.missing}
        if not missing:
            added = {(commit, path) for commit, expansion in expansions for path in expansion.added}
            return {commit: tree.graph for commit, tree in trees.items()}, added
        resolve_files(repository, trees, missing)
    raise AssertionError("every round resolves at least one file")


def commit_expansion(tree: CommitTree, scope: imports.ScopePaths) -> imports.Expansion:
    def directory_files(directory: str) -> list[str]:
        return [path for path in tree.files if imports.is_under(path, directory)]

    roots = imports.scope_roots(scope, directory_files)
    return imports.expand(roots, scope, tree.graph)


def read_commit_tree(repository: Path, commit: str) -> CommitTree:
    files: dict[str, tuple[str, str]] = {}
    gitlinks: set[str] = set()
    for mode, object_type, object_id, name in git.ls_tree(repository, commit, ".", recursive=True):
        if object_type == "commit":
            assert mode == SUBMODULE_MODE, (mode, name)
            gitlinks.add(name)
        elif object_type == "blob":
            files[name] = (mode, object_id)
    roots = sorted({
        parent_directory(path) for path in files
        if PurePosixPath(path).name in imports.PROJECT_CONFIG_NAMES
    })
    configs = {
        (root, name): files[imports.join_path(root, name)][1]
        for root in roots
        for name in imports.RESOLUTION_CONFIG_NAMES
        if imports.join_path(root, name) in files
    }
    contents = read_blobs(repository, sorted(set(configs.values())))
    projects = {
        root: imports.load_project(root, {
            name: contents[object_id]
            for (config_root, name), object_id in configs.items()
            if config_root == root
        })
        for root in roots
    }
    return CommitTree(files, frozenset(gitlinks), projects, {})


def parent_directory(path: str) -> str:
    """The repository path of a file's directory, "" for the repository root."""
    parent = str(PurePosixPath(path).parent)
    return "" if parent == "." else parent


def resolve_files(repository: Path, trees: dict[str, CommitTree], missing: set[tuple[str, str]]) -> None:
    """Record the resolved imports of the given files, fetching their blobs in one request."""
    object_ids: dict[tuple[str, str], str] = {}
    for commit, path in sorted(missing):
        tree = trees[commit]
        if path not in tree.files:
            raise FetchError(f"audited file {path!r} is not in commit {commit}")
        object_ids[(commit, path)] = file_object_id(repository, tree, path)
    contents = read_blobs(repository, sorted({oid for oid in object_ids.values() if oid}))
    for (commit, path), object_id in object_ids.items():
        tree = trees[commit]
        source = contents[object_id].decode("utf-8", errors="replace") if object_id else ""
        tree.graph[path] = [
            imports.resolve_import(path, import_path, tree.files, tree.gitlinks, tree.projects)
            for import_path in imports.parse_imports(source)
        ]


def file_object_id(repository: Path, tree: CommitTree, path: str) -> str:
    """The blob holding a file's contents, following symlinks; "" when a target is missing."""
    mode, object_id = tree.files[path]
    seen: set[str] = set()
    while mode == SYMLINK_MODE:
        if path in seen:
            raise FetchError(f"symlink cycle detected at {path!r}")
        seen.add(path)
        _, path = resolve_symlink_target(path, read_blobs(repository, [object_id])[object_id])
        if path not in tree.files:
            return ""
        mode, object_id = tree.files[path]
    return object_id


def read_blobs(repository: Path, object_ids: list[str]) -> dict[str, bytes]:
    """Contents of the given blobs, fetching the absent ones in one request."""
    if not object_ids:
        return {}
    request = "".join(f"{object_id}\n" for object_id in object_ids).encode("ascii")
    listing = git.run(repository, "cat-file", "--batch-check=%(objectname) %(objecttype)",
                      input=request, lazy_fetch=False)
    absent = [line.split(b" ")[0] for line in listing.splitlines() if line.endswith(b" missing")]
    if absent:
        git.run(repository, "fetch", "--quiet", "--no-tags", "--filter=blob:none", "--stdin", "origin",
                input=b"".join(object_id + b"\n" for object_id in absent))
    output = git.run(repository, "cat-file", "--batch", input=request, lazy_fetch=False)
    contents: dict[str, bytes] = {}
    offset = 0
    for object_id in object_ids:
        header_end = output.index(b"\n", offset)
        name, object_type, size = output[offset:header_end].decode("ascii").split(" ")
        if name != object_id or object_type != "blob":
            raise FetchError(f"expected blob {object_id}, got {name} {object_type}")
        start = header_end + 1
        contents[object_id] = output[start:start + int(size)]
        offset = start + int(size) + 1
    assert offset == len(output), (offset, len(output))
    return contents


# --- Driver -------------------------------------------------------------------


def fetch_collection(collection: Collection, kinds: frozenset[str] = FETCHED_KINDS) -> FetchResult:
    summary = read_summary(collection)
    urls = repository_urls(summary)
    sources, skipped = collect_sources(summary, kinds)
    import_scopes = collect_import_scopes(summary) if "evm" in kinds else {}
    import_graph: dict[tuple[str, str], dict[str, list[imports.Edge]]] = {}
    for source in sources:
        if source.repository not in urls:
            raise FetchError(f"scope references repository {source.repository!r} without a URL")
    destination = collection.sources_dir
    destination.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=f".{destination.name}.", dir=destination.parent))
    result = FetchResult(skipped=len(skipped))
    by_repository: dict[str, list[Source]] = defaultdict(list)
    for source in sources:
        by_repository[source.repository].append(source)

    exported: list[dict[str, Any]] = []
    unavailable: list[dict[str, str]] = []
    try:
        store = Store(staging)
        with tempfile.TemporaryDirectory(prefix="audit-dataset-fetch-") as temporary:
            for index, (repository_id, repository_sources) in enumerate(sorted(by_repository.items())):
                url = urls[repository_id]
                lengths = {len(source.commit) for source in repository_sources}
                if len(lengths) != 1:
                    raise FetchError(f"repository {repository_id!r} mixes Git object formats")
                if not repository_reachable(url):
                    result.warnings.append(
                        f"repository {url} is not reachable; skipping {len(repository_sources)} source(s)"
                    )
                    unavailable.extend(
                        unavailable_record(source, "repository is not reachable") for source in repository_sources
                    )
                    continue
                git_directory = Path(temporary) / f"repository-{index}.git"
                initialize_repository(git_directory, url, "sha256" if lengths == {64} else "sha1")
                by_commit: dict[str, list[Source]] = defaultdict(list)
                for source in repository_sources:
                    by_commit[source.commit].append(source)
                full_commits = {s.commit for s in repository_sources if s.path_kind == "directory_recursive"}
                missing = fetch_commits(git_directory, sorted(by_commit), full_commits, result.warnings)
                add_imported_sources(
                    git_directory, repository_id, by_commit, missing, import_scopes, import_graph
                )
                for commit, commit_sources in sorted(by_commit.items()):
                    if commit in missing:
                        unavailable.extend(
                            unavailable_record(source, "commit could not be fetched") for source in commit_sources
                        )
                        continue
                    for source in sorted(commit_sources):
                        files, omitted = export_source(git_directory, source, store)
                        entry: dict[str, Any] = {
                            "repository": source.repository,
                            "repository_url": url,
                            "source_path": source.path,
                            "path_kind": source.path_kind,
                            "commit": source.commit,
                            "files": files,
                        }
                        if omitted:
                            entry["omitted_files"] = omitted
                        exported.append(entry)
                        result.files += len(files)
                        result.omitted += len(omitted)
        manifest = {
            "schema_version": SCHEMA_VERSION,
            "collection": collection.name,
            "sources": exported,
            "skipped": [
                {
                    "repository": item.repository,
                    "source_path": item.path,
                    "revision_kind": item.revision_kind,
                    "revision": item.revision,
                    "reason": item.reason,
                }
                for item in skipped
            ],
            "unavailable": unavailable,
        }
        if import_graph:
            manifest["imports"] = imports.graph_to_manifest(import_graph)
        write_manifest(staging / collection.manifest_path.name, manifest)
        if destination.exists():
            shutil.rmtree(destination)
        staging.replace(destination)
    except BaseException:
        shutil.rmtree(staging, ignore_errors=True)
        raise
    result.sources = len(exported)
    result.unavailable = len(unavailable)
    result.manifest_path = collection.manifest_path
    return result


def unavailable_record(source: Source, reason: str) -> dict[str, str]:
    return {
        "repository": source.repository,
        "source_path": source.path,
        "path_kind": source.path_kind,
        "commit": source.commit,
        "reason": reason,
    }
