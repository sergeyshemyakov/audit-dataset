"""Fetch the audited sources of a collection into ``audited-sources/``.

Only versions of relevant reports that pin a full commit, are not
``not_audited`` and belong to a path of a fetched kind (``evm`` unless
``--kinds`` says otherwise) are fetched; every other version is recorded in
the manifest as skipped, with the reason. A directory scope stores only the
source files of its kind (``.sol``, ``.yul`` and ``.vy`` for ``evm``); a file
scope stores its file whatever the extension. Files are read straight from a bare clone's objects, never from a
checkout, and stored at ``<repository>/<commit>/<path>`` (see ``manifest``).

For reports read for what they say about unlisted code (see ``imports``), the
files their fully audited Solidity files import are fetched as file sources too,
also from the submodules the audited commit pins, and the resolved imports are
recorded in the manifest with what is known about the dependencies.
"""

from __future__ import annotations

import hashlib
import shutil
import stat
import tempfile
from collections import defaultdict
from dataclasses import dataclass, field, replace
from pathlib import Path, PurePosixPath
from typing import Any

from . import DatasetError
from . import git
from . import imports
from .collections import Collection
from .manifest import GIT_METADATA_FILES, SCHEMA_VERSION, stored_path, write_manifest
from .repositories import canonical_repository_id, github_name, github_url, is_github
from .scope import is_under
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
GITMODULES_NAME = ".gitmodules"


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


# --- Repositories of a run ----------------------------------------------------


@dataclass
class RepositoryTree:
    """The files of one repository at one commit and what resolves imports there."""

    repository: str  # canonical id
    url: str
    commit: str
    directory: Path  # the bare clone
    files: dict[str, tuple[str, str]]  # path -> (mode, object id) of every blob or symlink
    gitlinks: dict[str, str]  # submodule path -> the commit it is pinned to
    submodule_urls: dict[str, str]  # submodule path -> URL, from .gitmodules
    projects: dict[str, imports.Project]  # by root
    packages: dict[str, str] | None = None  # package directory -> name, once read
    solidity_fetched: bool = False

    def fetch_solidity(self) -> None:
        """Bring every Solidity file of the commit in one request.

        Following imports reads files level by level; asking for each level on
        its own costs one round trip per level, repository and audited commit.
        """
        if not self.solidity_fetched:
            fetch_blobs(self.directory, sorted({
                object_id for path, (_, object_id) in self.files.items() if path.endswith(".sol")
            }))
            self.solidity_fetched = True


class Repositories:
    """The bare clones of one fetch run, by canonical repository id."""

    def __init__(self, temporary: Path) -> None:
        self.temporary = temporary
        self.directories: dict[str, Path | None] = {}  # None when the URL is not reachable
        self.urls: dict[str, str] = {}
        self.fetched: dict[str, set[str]] = defaultdict(set)
        self.trees: dict[tuple[str, str], RepositoryTree] = {}
        self.unreadable: dict[tuple[str, str], str] = {}
        self.submodules: dict[str, tuple[str, str]] = {}  # URL in a .gitmodules -> (id, URL)
        self.warnings: list[str] = []

    def submodule(self, url: str) -> tuple[str, str]:
        """The canonical id and URL of a submodule's repository.

        GitHub is asked for the name it gives the repository today, so that a
        URL in another letter case or with a former name yields the id the rest
        of the dataset uses. Without an answer the URL is taken as written.
        """
        if url not in self.submodules:
            repository_id, canonical_url = canonical_repository_id(url), url
            if is_github(repository_id):
                name, error = github_name(repository_id)
                if name is None:
                    self.warnings.append(
                        f"could not ask GitHub for the name of {repository_id} ({error}); "
                        f"using it as written"
                    )
                else:
                    repository_id, canonical_url = name, github_url(name)
            self.submodules[url] = (repository_id, canonical_url)
        return self.submodules[url]

    def open(self, repository_id: str, url: str, object_format: str) -> Path | None:
        """The clone of a repository, created empty on first use; None when unreachable."""
        if repository_id not in self.directories:
            self.urls[repository_id] = url
            if repository_reachable(url):
                directory = self.temporary / f"repository-{len(self.directories)}.git"
                initialize_repository(directory, url, object_format)
                self.directories[repository_id] = directory
            else:
                self.directories[repository_id] = None
        return self.directories[repository_id]

    def tree(self, repository_id: str, url: str, commit: str) -> RepositoryTree:
        """The tree of a commit, fetched without file contents when the run has not
        fetched it yet. Raises ``FetchError`` when it cannot be read."""
        key = (repository_id, commit)
        if key in self.unreadable:
            raise FetchError(self.unreadable[key])
        if key not in self.trees:
            try:
                self.trees[key] = self.read_tree(repository_id, url, commit)
            except (FetchError, git.GitError) as error:
                self.unreadable[key] = str(error)
                raise FetchError(str(error)) from error
        return self.trees[key]

    def read_tree(self, repository_id: str, url: str, commit: str) -> RepositoryTree:
        if not git.FULL_COMMIT_RE.fullmatch(commit):
            raise FetchError(f"{commit!r} is not a full commit id")
        directory = self.open(repository_id, url, git.hash_algorithm(len(commit)))
        if directory is None:
            raise FetchError(f"repository {self.urls[repository_id]} is not reachable")
        if commit not in self.fetched[repository_id]:
            warnings: list[str] = []
            if fetch_commits(directory, [commit], set(), warnings):
                raise FetchError(warnings[-1] if warnings else f"commit {commit} could not be fetched")
            self.fetched[repository_id].add(commit)
        return read_repository_tree(directory, repository_id, self.urls[repository_id], commit)

    def package_names(self, tree: RepositoryTree) -> dict[str, str]:
        """The npm packages of a repository: the directory of each named ``package.json``."""
        if tree.packages is None:
            configs = {
                parent_directory(path): object_id
                for path, (mode, object_id) in tree.files.items()
                if PurePosixPath(path).name == imports.PACKAGE_CONFIG_NAME and mode in BLOB_MODES
            }
            contents = read_blobs(tree.directory, sorted(set(configs.values())))
            names = {
                directory: imports.package_name(contents[object_id])
                for directory, object_id in configs.items()
            }
            tree.packages = {directory: name for directory, name in sorted(names.items()) if name}
        return tree.packages

    def timestamp(self, repository_id: str, commit: str) -> int:
        """The committer date of a fetched commit, in unix seconds."""
        directory = self.directories[repository_id]
        assert directory is not None, repository_id
        return int(git.run_text(directory, "show", "-s", "--format=%ct", commit).strip())


def read_repository_tree(directory: Path, repository_id: str, url: str, commit: str) -> RepositoryTree:
    files: dict[str, tuple[str, str]] = {}
    gitlinks: dict[str, str] = {}
    for mode, object_type, object_id, name in git.ls_tree(directory, commit, ".", recursive=True):
        if object_type == "commit":
            assert mode == SUBMODULE_MODE, (mode, name)
            gitlinks[name] = object_id
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
    wanted = set(configs.values())
    gitmodules = files.get(GITMODULES_NAME) if gitlinks else None
    if gitmodules is not None:
        wanted.add(gitmodules[1])
    contents = read_blobs(directory, sorted(wanted))
    projects = {
        root: imports.load_project(root, {
            name: contents[object_id]
            for (config_root, name), object_id in configs.items()
            if config_root == root
        })
        for root in roots
    }
    submodule_urls = (
        {} if gitmodules is None
        else parse_gitmodules(contents[gitmodules[1]].decode("utf-8", errors="replace"), url)
    )
    return RepositoryTree(repository_id, url, commit, directory, files, gitlinks, submodule_urls, projects)


def parse_gitmodules(content: str, parent_url: str) -> dict[str, str]:
    """Submodule path to URL, with a relative URL resolved against the parent's."""
    urls: dict[str, str] = {}
    path: str | None = None
    url: str | None = None
    for line in [*content.splitlines(), "["]:
        line = line.strip()
        if line.startswith("["):
            if path is not None and url is not None:
                urls[path.strip("/")] = submodule_url(url, parent_url)
            path = url = None
            continue
        key, separator, value = line.partition("=")
        if separator and key.strip() == "path":
            path = value.strip()
        elif separator and key.strip() == "url":
            url = value.strip()
    return urls


def submodule_url(url: str, parent_url: str) -> str:
    if url.startswith(("./", "../")):
        parts = parent_url.rstrip("/").split("/")
        for part in url.split("/"):
            if part == "..":
                parts.pop()
            elif part not in {"", "."}:
                parts.append(part)
        url = "/".join(parts)
    if url.startswith("git@") and ":" in url:
        host, _, path = url[len("git@"):].partition(":")
        url = f"https://{host}/{path}"
    for scheme in ("git://", "ssh://git@", "http://"):
        if url.startswith(scheme):
            url = "https://" + url[len(scheme):]
    return url.rstrip("/").removesuffix(".git")


def parent_directory(path: str) -> str:
    """The repository path of a file's directory, "" for the repository root."""
    return imports.parent_directory(path)


# --- Import expansion ---------------------------------------------------------


class LiveTree(imports.SnapshotTree):
    """An audited repository at a commit, with every submodule an import leads into
    mounted at the commit the tree pins, fetched on first use."""

    def __init__(self, repositories: Repositories, root: RepositoryTree, warnings: list[str]) -> None:
        self.repositories = repositories
        self.warnings = warnings
        self.mounts: dict[str, RepositoryTree] = {"": root}
        self.unreadable: dict[str, str] = {}
        self.projects: dict[str, imports.Project] = dict(root.projects)
        self.packages = repositories.package_names(root)
        self.graph: dict[str, list[imports.Edge]] = {}

    @property
    def root(self) -> RepositoryTree:
        return self.mounts[""]

    def locate(self, path: str) -> tuple[RepositoryTree, str] | None:
        """The repository that holds a path and the path there; None below a
        submodule that cannot be read."""
        prefix, tree, relative = "", self.root, path
        while True:
            parts = relative.split("/")
            gitlink = next(
                (candidate for end in range(1, len(parts))
                 if (candidate := "/".join(parts[:end])) in tree.gitlinks),
                None,
            )
            if gitlink is None:
                return tree, relative
            prefix = imports.join_path(prefix, gitlink)
            mounted = self.mount(tree, gitlink, prefix)
            if mounted is None:
                return None
            tree, relative = mounted, relative[len(gitlink) + 1:]

    def mount(self, parent: RepositoryTree, gitlink: str, prefix: str) -> RepositoryTree | None:
        if prefix in self.mounts:
            return self.mounts[prefix]
        if prefix in self.unreadable:
            return None
        try:
            url = parent.submodule_urls.get(gitlink)
            if url is None:
                raise FetchError(f"no URL in {GITMODULES_NAME}")
            repository_id, url = self.repositories.submodule(url)
            tree = self.repositories.tree(repository_id, url, parent.gitlinks[gitlink])
        except DatasetError as error:
            self.unreadable[prefix] = str(error)
            self.warnings.append(
                f"{self.root.repository}@{self.root.commit}: submodule {prefix} is unreadable: {error}"
            )
            return None
        self.mounts[prefix] = tree
        for root, project in tree.projects.items():
            mounted_root = imports.join_path(prefix, root)
            self.projects[mounted_root] = replace(project, root=mounted_root)
        return tree

    def has(self, path: str) -> bool:
        located = self.locate(path)
        return located is not None and located[1] in located[0].files

    def mount_of(self, path: str) -> str:
        return max(
            (prefix for prefix in self.mounts if prefix and is_under(path, prefix)),
            key=len, default="",
        )

    def facts(self) -> imports.TreeFacts:
        targets = {edge.path for edges in self.graph.values() for edge in edges if edge.path is not None}
        return imports.TreeFacts(
            mounts={
                prefix: (tree.repository, tree.commit)
                for prefix, tree in self.mounts.items() if prefix
            },
            vendored=frozenset(
                path for path in targets
                if not self.mount_of(path) and imports.vendored_reason(path, self.projects) is not None
            ),
            packages=self.packages,
        )


@dataclass
class ScopeExpansion:
    """What expanding the scopes of a collection found."""

    graph: dict[tuple[str, str], dict[str, list[imports.Edge]]] = field(default_factory=dict)
    facts: dict[tuple[str, str], imports.TreeFacts] = field(default_factory=dict)
    sources: set[Source] = field(default_factory=set)  # one file source per reached file


def collect_import_scopes(summary: dict[str, Any]) -> dict[tuple[str, str], list[imports.ScopePaths]]:
    """The scopes whose imports are expanded, by ``(repository, commit)``."""
    scopes: dict[tuple[str, str], list[imports.ScopePaths]] = defaultdict(list)
    for report in summary["reports"]:
        for key, scope in imports.report_scope_paths(report).items():
            scopes[key].append(scope)
    return scopes


def expand_scopes(
    repositories: Repositories,
    pinned: dict[str, dict[str, list[Source]]],
    import_scopes: dict[tuple[str, str], list[imports.ScopePaths]],
    warnings: list[str],
) -> ScopeExpansion:
    """Resolve the imports of every expanded scope whose commit was fetched, and name
    the files to store for them."""
    result = ScopeExpansion()
    for (repository_id, commit), scopes in sorted(import_scopes.items()):
        if commit not in pinned.get(repository_id, {}):
            continue
        root = repositories.tree(repository_id, repositories.urls[repository_id], commit)
        tree = LiveTree(repositories, root, warnings)
        reached = expand_tree(tree, scopes)
        result.graph[(repository_id, commit)] = tree.graph
        result.facts[(repository_id, commit)] = tree.facts()
        blobs: dict[Path, set[str]] = defaultdict(set)
        for path in sorted(reached):
            located = tree.locate(path)
            assert located is not None, path
            origin, relative = located
            result.sources.add(Source(origin.repository, relative, "file", origin.commit, "evm"))
            blobs[origin.directory].add(file_object_id(origin, relative))
        # One request per repository for the files that are stored without having been read.
        for directory, object_ids in blobs.items():
            read_blobs(directory, sorted(object_ids - {""}))
    return result


def expand_tree(tree: LiveTree, scopes: list[imports.ScopePaths]) -> set[str]:
    """Resolve imports level by level until every expansion is complete.

    Returns every file some expansion reached that is in its scope only through
    imports. Each round reads the newly reached files of each repository in one
    request.
    """
    def directory_files(directory: str) -> list[str]:
        return [path for path in tree.root.files if is_under(path, directory)]

    while True:
        # Reading a file may mount a submodule or meet a dependency directory, which
        # changes what counts as a dependency, so the facts are taken anew each round.
        facts = tree.facts()
        expansions = [
            imports.expand(imports.scope_roots(scope, directory_files), scope, tree.graph, facts)
            for scope in scopes
        ]
        missing = {path for expansion in expansions for path in expansion.missing | expansion.unread}
        if not missing:
            return {
                path
                for expansion in expansions
                for path, reached in expansion.reached.items()
                if reached.state in imports.REACHED_STATES
            }
        resolved = len(tree.graph)
        resolve_files(tree, missing)
        assert len(tree.graph) > resolved, "every round resolves at least one file"


def resolve_files(tree: LiveTree, missing: set[str]) -> None:
    """Record the resolved imports of the given files, reading each repository's in one request."""
    object_ids: dict[str, tuple[Path, str]] = {}
    for path in sorted(missing):
        located = tree.locate(path)
        if located is None or located[1] not in located[0].files:
            raise FetchError(f"audited file {path!r} is not in commit {tree.root.commit}")
        located[0].fetch_solidity()
        object_ids[path] = (located[0].directory, file_object_id(*located))
    contents: dict[tuple[Path, str], bytes] = {}
    for directory in sorted({directory for directory, _ in object_ids.values()}):
        wanted = sorted({oid for other, oid in object_ids.values() if other == directory and oid})
        for object_id, content in read_blobs(directory, wanted).items():
            contents[(directory, object_id)] = content
    for path, (directory, object_id) in object_ids.items():
        source = contents[(directory, object_id)].decode("utf-8", errors="replace") if object_id else ""
        tree.graph[path] = [
            imports.resolve_import(path, import_path, tree)
            for import_path in imports.parse_imports(source)
        ]


def file_object_id(tree: RepositoryTree, path: str) -> str:
    """The blob holding a file's contents, following symlinks; "" when a target is missing."""
    mode, object_id = tree.files[path]
    seen: set[str] = set()
    while mode == SYMLINK_MODE:
        if path in seen:
            raise FetchError(f"symlink cycle detected at {path!r}")
        seen.add(path)
        _, path = resolve_symlink_target(path, read_blobs(tree.directory, [object_id])[object_id])
        if path not in tree.files:
            return ""
        mode, object_id = tree.files[path]
    return object_id


def read_blobs(repository: Path, object_ids: list[str]) -> dict[str, bytes]:
    """Contents of the given blobs, fetching the absent ones in one request."""
    if not object_ids:
        return {}
    request = fetch_blobs(repository, object_ids)
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


def fetch_blobs(repository: Path, object_ids: list[str]) -> bytes:
    """Fetch the absent ones of the given objects in one request; returns the
    ids as ``git cat-file --batch`` reads them."""
    request = "".join(f"{object_id}\n" for object_id in object_ids).encode("ascii")
    if not object_ids:
        return request
    listing = git.run(repository, "cat-file", "--batch-check=%(objectname) %(objecttype)",
                      input=request, lazy_fetch=False)
    absent = [line.split(b" ")[0] for line in listing.splitlines() if line.endswith(b" missing")]
    if absent:
        git.run(repository, "fetch", "--quiet", "--no-tags", "--filter=blob:none", "--stdin", "origin",
                input=b"".join(object_id + b"\n" for object_id in absent))
    return request


# --- Driver -------------------------------------------------------------------


def fetch_collection(collection: Collection, kinds: frozenset[str] = FETCHED_KINDS) -> FetchResult:
    summary = read_summary(collection)
    urls = repository_urls(summary)
    sources, skipped = collect_sources(summary, kinds)
    import_scopes = collect_import_scopes(summary) if "evm" in kinds else {}
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
            repositories = Repositories(Path(temporary))
            # The sources of every fetched commit, by repository.
            pinned: dict[str, dict[str, list[Source]]] = {}
            for repository_id, repository_sources in sorted(by_repository.items()):
                url = urls[repository_id]
                lengths = {len(source.commit) for source in repository_sources}
                if len(lengths) != 1:
                    raise FetchError(f"repository {repository_id!r} mixes Git object formats")
                directory = repositories.open(repository_id, url, "sha256" if lengths == {64} else "sha1")
                if directory is None:
                    result.warnings.append(
                        f"repository {url} is not reachable; skipping {len(repository_sources)} source(s)"
                    )
                    unavailable.extend(
                        unavailable_record(source, "repository is not reachable") for source in repository_sources
                    )
                    continue
                by_commit: dict[str, list[Source]] = defaultdict(list)
                for source in repository_sources:
                    by_commit[source.commit].append(source)
                full_commits = {s.commit for s in repository_sources if s.path_kind == "directory_recursive"}
                missing = fetch_commits(directory, sorted(by_commit), full_commits, result.warnings)
                repositories.fetched[repository_id].update(by_commit.keys() - missing)
                pinned[repository_id] = {}
                for commit, commit_sources in sorted(by_commit.items()):
                    if commit in missing:
                        unavailable.extend(
                            unavailable_record(source, "commit could not be fetched") for source in commit_sources
                        )
                    else:
                        pinned[repository_id][commit] = commit_sources
            expansion = expand_scopes(repositories, pinned, import_scopes, result.warnings)
            result.warnings.extend(repositories.warnings)
            for source in sorted(expansion.sources):
                commit_sources = pinned.setdefault(source.repository, {}).setdefault(source.commit, [])
                for other in commit_sources:
                    if (other.path, other.path_kind) == (source.path, "directory_recursive"):
                        raise FetchError(
                            f"imported file {source.path!r} is also a directory scope at {source.commit}"
                        )
                if source not in commit_sources:
                    commit_sources.append(source)
            for repository_id, by_commit in sorted(pinned.items()):
                directory = repositories.directories[repository_id]
                assert directory is not None, repository_id
                for commit, commit_sources in sorted(by_commit.items()):
                    for source in sorted(commit_sources):
                        files, omitted = export_source(directory, source, store)
                        entry: dict[str, Any] = {
                            "repository": source.repository,
                            "repository_url": repositories.urls[repository_id],
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
            dependencies = dependency_commits(repositories, expansion)
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
        if expansion.graph:
            manifest["imports"] = imports.graph_to_manifest(expansion.graph)
            manifest["trees"] = imports.facts_to_manifest(expansion.facts)
            manifest["dependencies"] = dependencies
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


def dependency_commits(repositories: Repositories, expansion: ScopeExpansion) -> dict[str, Any]:
    """The submodule commits the expansions read, with their URL and committer date.

    No summary pins them, so their timestamps come from the commits themselves.
    """
    commits = sorted({
        mounted for facts in expansion.facts.values() for mounted in facts.mounts.values()
    })
    result: dict[str, Any] = {}
    for repository_id, commit in commits:
        entry = result.setdefault(repository_id, {"url": repositories.urls[repository_id], "commits": {}})
        entry["commits"][commit] = repositories.timestamp(repository_id, commit)
    return result


def unavailable_record(source: Source, reason: str) -> dict[str, str]:
    return {
        "repository": source.repository,
        "source_path": source.path,
        "path_kind": source.path_kind,
        "commit": source.commit,
        "reason": reason,
    }
