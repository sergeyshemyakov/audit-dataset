"""Follow the imports of a report's audited Solidity files.

A report that was read for what it says about unlisted code (``unlisted`` in
its summary) gets, at every commit where it fully audited an ``evm`` file or
directory, the files those files import, transitively. Each reached file has
one state, decided by what the report says:

- ``listed``: a path the report audited in full covers it. Its imports are followed.
- ``partial``: only a partially audited path covers it. Nothing is implied from it.
- ``excluded``: it is, or lies below, a ``not_audited`` path of the report in that
  repository, at any commit; or it is dependency code and the report's general
  statement about dependencies excludes them; or the report excludes everything
  it does not list. The expansion stops there.
- ``included``: dependency code the report's general statement says was reviewed.
- ``implied``: the report is silent about it. Its imports are followed.

Solidity makes everything a file imports nameable in the files that import it,
so audited code can use a contract that only an excluded or partially audited
file imports. The expansion therefore reads on from those files as well, but
says less about what it finds there: a file the report is silent about is then
``visible``, not ``implied``. Whether audited code names anything in it is for
the consumer to tell, which parses the files.

Imports are followed wherever they lead: into submodules at the commit the
audited tree pins, into a Foundry project's library directories, ``vendor``-like
directories, ``node_modules`` when committed, and other packages of the same
repository. A path below a submodule is written as the audited repository sees
it (``lib/solady/src/utils/LibClone.sol``); a ``SnapshotTree`` maps it back to
the repository that holds it. An import that leads to nothing readable (an npm
package that is not committed, a submodule that cannot be fetched) is recorded
as skipped.

``fetch`` resolves the imports of every file an expansion reads and stores them
in the manifest under ``imports``, with what the tree knows about dependencies
under ``trees``; ``export`` expands the same way from that, and ``imports``
(the command) explains the expansion.
"""

from __future__ import annotations

import json
import tomllib
from collections import deque
from dataclasses import dataclass
from pathlib import PurePosixPath
from typing import Any, Callable, Iterable, Mapping, Sequence

from .git import full_commit
from .scope import is_test_or_mock, is_under
from .summary import (
    DEPENDENCIES_EXCLUDED,
    DEPENDENCIES_INCLUDED,
    UNLISTED_NOT_MENTIONED,
    scope_statements,
)

LISTED = "listed"
PARTIAL = "partial"
EXCLUDED = "excluded"
INCLUDED = "included"
IMPLIED = "implied"
VISIBLE = "visible"
# States from which a file's imports count as imports of the audited code.
FOLLOWED_STATES = frozenset({LISTED, INCLUDED, IMPLIED})
# States of files that are in a report's scope only because audited files import them.
REACHED_STATES = (IMPLIED, EXCLUDED, INCLUDED, VISIBLE)
FULL_AUDIT_STATUSES = {"audited_with_no_major_findings", "audited_with_major_findings"}
PROJECT_CONFIG_NAMES = (
    "foundry.toml", "remappings.txt", "hardhat.config.js", "hardhat.config.ts",
    "truffle-config.js", "truffle.js",
)
# Files a project's imports are resolved with: remappings, and Foundry's library directories.
RESOLUTION_CONFIG_NAMES = ("foundry.toml", "remappings.txt")
FOUNDRY_DEFAULT_LIBRARIES = ("lib",)
# Where a library keeps its sources, for the remapping forge derives for `lib/<name>`.
LIBRARY_SOURCE_DIRECTORIES = ("src", "contracts", "")
PACKAGE_CONFIG_NAME = "package.json"
DEPENDENCY_SEGMENTS = {"node_modules", ".deps"}
VENDORED_SEGMENTS = {
    "vendor", "vendored", "thirdparty", "third_party", "dependencies",
    # copies of libraries that have their own collections under _libs/
    "openzeppelin", "@openzeppelin", "openzeppelin-contracts", "openzeppelin-upgradeable", "solady", "solmate",
}


@dataclass(frozen=True)
class Edge:
    """One import statement: the file it resolves to, or why it leads to nothing readable."""

    import_path: str  # as written in the source
    path: str | None = None  # as the audited repository sees it, also below a submodule
    skipped: str | None = None

    def __post_init__(self) -> None:
        assert self.import_path
        assert (self.path is None) != (self.skipped is None), self

    def to_json(self) -> dict[str, str]:
        if self.path is not None:
            return {"import": self.import_path, "path": self.path}
        assert self.skipped is not None
        return {"import": self.import_path, "skipped": self.skipped}

    @staticmethod
    def from_json(value: dict[str, str]) -> Edge:
        assert set(value) in ({"import", "path"}, {"import", "skipped"}), value
        return Edge(value["import"], value.get("path"), value.get("skipped"))


@dataclass(frozen=True)
class Remapping:
    context: str
    prefix: str
    target: str


@dataclass(frozen=True)
class Project:
    """A directory with a Solidity build configuration; imports resolve against it."""

    root: str  # repository path, "" for the repository root
    remappings: tuple[Remapping, ...]
    libraries: tuple[str, ...]  # dependency directories, relative to root
    problem: str | None  # why direct imports cannot be resolved here


@dataclass(frozen=True)
class ScopePaths:
    """One report's scope in one repository at one commit."""

    audited: tuple[tuple[str, str], ...]  # (path, path_kind) of fully audited versions
    partial: tuple[tuple[str, str], ...]  # (path, path_kind) of partially audited versions
    excluded: tuple[str, ...]  # the report's not_audited paths in the repository
    unlisted: str  # what the report says about code it does not list
    dependencies: str | None  # its general statement about dependencies, if any


@dataclass(frozen=True)
class Reached:
    """A file an expansion reached through imports, as one report sees it."""

    state: str
    importer: str  # the file that first imported it
    dependency: bool  # third-party code for this report
    reason: str  # for an excluded file: the excluding path, or which statement


@dataclass
class Expansion:
    roots: list[str]
    reached: dict[str, Reached]  # every reached file that is not a root
    skipped: list[tuple[str, Edge]]  # (importer, edge) leading to nothing readable
    missing: set[str]  # followed files without resolved imports in the graph
    unread: set[str]  # other reached files without resolved imports in the graph

    def in_state(self, state: str) -> list[str]:
        return sorted(path for path, reached in self.reached.items() if reached.state == state)


class SnapshotTree:
    """What import resolution asks about a repository at a commit, submodules mounted."""

    projects: Mapping[str, "Project"]  # by root, also those of mounted submodules
    packages: Mapping[str, str]  # package directory -> name, of the audited repository

    def has(self, path: str) -> bool:
        """Whether a file exists at the path; may mount the submodule it lies in."""
        raise NotImplementedError

    def mount_of(self, path: str) -> str:
        """Where the submodule holding the path is mounted, "" for the audited repository."""
        raise NotImplementedError


@dataclass(frozen=True)
class TreeFacts:
    """What deciding ``dependency`` needs to know about a tree, as the manifest keeps it."""

    mounts: Mapping[str, tuple[str, str]]  # submodule mount path -> (repository, commit)
    vendored: frozenset[str]  # reached files of the audited repository that are dependency code
    packages: Mapping[str, str]  # package directory -> name, of the audited repository

    def mount_of(self, path: str) -> str:
        return max((mount for mount in self.mounts if is_under(path, mount)), key=len, default="")

    def origin(self, path: str) -> tuple[str, str, str] | None:
        """``(repository, commit, path there)`` of a path below a submodule."""
        mount = self.mount_of(path)
        if not mount:
            return None
        repository, commit = self.mounts[mount]
        return repository, commit, path[len(mount) + 1:]

    def package_of(self, path: str) -> str | None:
        """The directory of the package holding a file of the audited repository."""
        return max(
            (directory for directory in self.packages if not directory or is_under(path, directory)),
            key=len, default=None,
        )

    def own_packages(self, roots: Iterable[str]) -> frozenset[str]:
        return frozenset(self.package_of(root) or "" for root in roots)

    def is_dependency(self, path: str, own_packages: frozenset[str]) -> bool:
        """Third-party code: in a submodule or a dependency directory, or in a package
        of the repository that holds none of the audited files."""
        if self.mount_of(path) or path in self.vendored:
            return True
        package = self.package_of(path)
        return bool(package) and not any(is_under(own, package) for own in own_packages)

    def to_json(self) -> dict[str, Any]:
        return {
            "mounts": {
                mount: {"repository": repository, "commit": commit}
                for mount, (repository, commit) in sorted(self.mounts.items())
            },
            "vendored": sorted(self.vendored),
            "packages": dict(sorted(self.packages.items())),
        }

    @staticmethod
    def from_json(value: dict[str, Any]) -> TreeFacts:
        return TreeFacts(
            {mount: (entry["repository"], entry["commit"]) for mount, entry in value["mounts"].items()},
            frozenset(value["vendored"]),
            dict(value["packages"]),
        )


NO_FACTS = TreeFacts({}, frozenset(), {})


# --- Parsing ------------------------------------------------------------------


def parse_imports(source: str) -> list[str]:
    """Import paths of a Solidity source in order, ignoring comments and other strings."""
    imports: list[str] = []
    in_import = False
    import_path: str | None = None
    index = 0
    length = len(source)
    while index < length:
        character = source[index]
        if source.startswith("//", index):
            index = skip_until(source, index, "\n")
        elif source.startswith("/*", index):
            index = skip_until(source, index + 2, "*/")
        elif character in "\"'":
            end = string_end(source, index)
            if in_import and import_path is None:
                import_path = source[index + 1:end]
            index = end + 1
        elif character.isalpha() or character in "_$":
            end = index
            while end < length and (source[end].isalnum() or source[end] in "_$"):
                end += 1
            if source[index:end] == "import" and not in_import:
                in_import = True
                import_path = None
            index = end
        else:
            if character == ";" and in_import:
                if import_path:
                    imports.append(import_path)
                in_import = False
            index += 1
    return imports


def skip_until(source: str, index: int, terminator: str) -> int:
    end = source.find(terminator, index)
    return len(source) if end < 0 else end + len(terminator)


def string_end(source: str, start: int) -> int:
    """Index of the quote closing the string literal opened at ``start``."""
    quote = source[start]
    index = start + 1
    while index < len(source) and source[index] != quote and source[index] != "\n":
        index += 2 if source[index] == "\\" else 1
    return min(index, len(source) - 1)


def parse_remappings(lines: Iterable[str]) -> list[Remapping]:
    remappings: list[Remapping] = []
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        left, separator, target = line.partition("=")
        if not separator or not left:
            raise ValueError(f"invalid remapping {line!r}")
        context, colon, prefix = left.rpartition(":")
        # forge hands solc every remapping with a trailing "/" on the target.
        remappings.append(Remapping(context if colon else "", prefix, target.rstrip("/") + "/"))
    return remappings


def load_project(root: str, configs: Mapping[str, bytes]) -> Project:
    """A project from the contents of its configuration files, by file name."""
    remappings: list[Remapping] = []
    libraries: tuple[str, ...] = ()
    try:
        if "remappings.txt" in configs:
            remappings += parse_remappings(configs["remappings.txt"].decode("utf-8").splitlines())
        if "foundry.toml" in configs:
            profile = tomllib.loads(configs["foundry.toml"].decode("utf-8"))
            profile = profile.get("profile", {}).get("default", {})
            remappings += parse_remappings(profile.get("remappings", []))
            libraries = tuple(
                normalize_path(library) or library
                for library in profile.get("libs", FOUNDRY_DEFAULT_LIBRARIES)
            )
    except (UnicodeDecodeError, ValueError, tomllib.TOMLDecodeError, AttributeError, TypeError) as error:
        return Project(root, (), libraries, f"invalid configuration: {error}")
    return Project(root, tuple(remappings), libraries, None)


def package_name(config: bytes) -> str | None:
    """The name a ``package.json`` gives its directory, by which other packages import it."""
    try:
        value = json.loads(config.decode("utf-8"))
    except (UnicodeDecodeError, ValueError):
        return None
    name = value.get("name") if isinstance(value, dict) else None
    return name if isinstance(name, str) and name else None


# --- Resolving ----------------------------------------------------------------


def normalize_path(path: str) -> str | None:
    """Collapse "." and ".." segments; None when the path leaves the repository."""
    parts: list[str] = []
    for part in path.split("/"):
        if part in {"", "."}:
            continue
        if part == "..":
            if not parts:
                return None
            parts.pop()
        else:
            parts.append(part)
    return "/".join(parts) if parts else None


def join_path(*parts: str) -> str:
    return "/".join(part for part in parts if part)


def parent_directory(path: str) -> str:
    """The directory of a path, "" for the repository root."""
    parent = str(PurePosixPath(path).parent)
    return "" if parent == "." else parent


def projects_of(path: str, tree: SnapshotTree) -> list[Project]:
    """The projects whose settings apply to a file, nearest first.

    The root of the audited repository and of every submodule is a project even
    without configuration: imports resolve against it.
    """
    result: list[Project] = []
    directory = parent_directory(path)
    while True:
        project = tree.projects.get(directory)
        if project is None and tree.mount_of(join_path(directory, "_")) == directory:
            project = Project(directory, (), (), None)
        if project is not None:
            result.append(project)
        if not directory:
            return result
        directory = parent_directory(directory)


def select_remapping(project: Project, importer: str, import_path: str) -> Remapping | None:
    """solc's rule: the longest matching context, then the longest prefix, then the last."""
    source_unit = importer[len(project.root) + 1:] if project.root else importer
    best: Remapping | None = None
    for remapping in project.remappings:
        if not source_unit.startswith(remapping.context):
            continue
        if not import_path.startswith(remapping.prefix):
            continue
        if best is None or (len(remapping.context), len(remapping.prefix)) >= (
            len(best.context), len(best.prefix)
        ):
            best = remapping
    return best


def resolve_import(importer: str, import_path: str, tree: SnapshotTree) -> Edge:
    """Resolve one import of ``importer``, the way the audited project's toolchain would.

    A relative import is resolved against the importing file. Any other import
    is tried, in the projects that apply to the file from the nearest one up,
    as a remapped path or else as a path below the project root; then as a path
    in one of their library directories (the remapping forge derives for
    ``lib/<name>``) or in ``node_modules``; then as a package of the repository.
    """
    if import_path.startswith(("./", "../")):
        candidate = normalize_path(join_path(parent_directory(importer), import_path))
        if candidate is None:
            return Edge(import_path, skipped="resolves outside the repository")
        return found(import_path, candidate, tree)
    projects = projects_of(importer, tree)
    hits: list[tuple[str, str]] = []  # ("remapped" | "direct", existing path), nearest project first
    misses: list[str] = []
    for project in projects:
        if project.problem is not None:
            misses.append(f"{project.root or '.'}: {project.problem}")
            continue
        remapping = select_remapping(project, importer, import_path)
        target = import_path if remapping is None else remapping.target + import_path[len(remapping.prefix):]
        candidate = normalize_path(join_path(project.root, target))
        if candidate is None:
            misses.append("resolves outside the repository")
        elif not tree.has(candidate):
            misses.append(f"not in the repository: {candidate}")
        else:
            hits.append(("direct" if remapping is None else "remapped", candidate))
    if hits:
        kind, path = hits[0]
        # Two project roots of one repository both holding the path: solc would
        # need the base path to choose, which the repository does not record.
        others = sorted({
            other for other_kind, other in hits[1:]
            if kind == other_kind == "direct" and other != path
            and tree.mount_of(other) == tree.mount_of(path)
        })
        if others:
            return Edge(import_path, skipped=f"ambiguous: {' or '.join(sorted([path, *others]))}")
        return Edge(import_path, path=path)
    for project in projects:
        for candidate in library_candidates(project, import_path):
            if tree.has(candidate):
                return Edge(import_path, path=candidate)
    if not tree.mount_of(importer):
        candidate = package_candidate(import_path, tree.packages)
        if candidate is not None and tree.has(candidate):
            return Edge(import_path, path=candidate)
    return Edge(import_path, skipped=misses[0] if misses else f"not in the repository: {import_path}")


def found(import_path: str, candidate: str, tree: SnapshotTree) -> Edge:
    if not tree.has(candidate):
        return Edge(import_path, skipped=f"not in the repository: {candidate}")
    return Edge(import_path, path=candidate)


def library_candidates(project: Project, import_path: str) -> list[str]:
    """Where a project's dependency directories may hold an import that names a library."""
    name, _, rest = import_path.partition("/")
    candidates: list[str | None] = []
    for library in project.libraries:
        for sources in LIBRARY_SOURCE_DIRECTORIES:
            candidates.append(normalize_path(join_path(project.root, library, name, sources, rest)))
        candidates.append(normalize_path(join_path(project.root, library, import_path)))
    candidates.append(normalize_path(join_path(project.root, "node_modules", import_path)))
    return [candidate for candidate in candidates if candidate is not None]


def package_candidate(import_path: str, packages: Mapping[str, str]) -> str | None:
    """``@scope/name/x.sol`` as a file of the repository's package named ``@scope/name``."""
    matches = [
        (name, directory) for directory, name in sorted(packages.items())
        if import_path.startswith(f"{name}/")
    ]
    if not matches:
        return None
    name, directory = max(matches, key=lambda match: len(match[0]))
    return normalize_path(join_path(directory, import_path[len(name) + 1:]))


def vendored_reason(path: str, projects: Mapping[str, Project]) -> str | None:
    """Why a file of the audited repository itself is dependency code, by its path."""
    parts = path.split("/")
    if DEPENDENCY_SEGMENTS & set(parts[:-1]):
        return "package dependency"
    if VENDORED_SEGMENTS & set(parts[:-1]):
        return "vendored dependency"
    for project in projects.values():
        for library in project.libraries:
            if is_under(path, join_path(project.root, library)):
                return "library dependency"
    return None


# --- Expanding ----------------------------------------------------------------


def report_scope_paths(report: dict[str, Any]) -> dict[tuple[str, str], ScopePaths]:
    """The scopes of a report that are expanded, by ``(repository, commit)``: none
    unless the report was read for what it says about unlisted code."""
    unlisted, dependencies = scope_statements(report)
    if not report["isRelevant"] or unlisted is None:
        return {}
    result: dict[tuple[str, str], ScopePaths] = {}
    for scope in report["scopes"]:
        repository = scope["repository"]
        excluded = excluded_paths(scope)
        audited: dict[str, set[tuple[str, str]]] = {}
        partial: dict[str, set[tuple[str, str]]] = {}
        for path, path_data in scope["paths"].items():
            for version in path_data["versions"]:
                commit = full_commit(version["revision"])
                if commit is None or version["status"] == "not_audited" or path_data["kind"] != "evm":
                    continue
                paths = audited if version["status"] in FULL_AUDIT_STATUSES else partial
                paths.setdefault(commit, set()).add((path, path_data["path_kind"]))
        for commit, paths in audited.items():
            assert (repository, commit) not in result, (report["id"], repository, commit)
            result[(repository, commit)] = ScopePaths(
                tuple(sorted(paths)), tuple(sorted(partial.get(commit, ()))), excluded,
                unlisted, dependencies,
            )
    return result


def excluded_paths(scope: dict[str, Any]) -> tuple[str, ...]:
    """The paths a report says it did not review in one repository, at any commit."""
    return tuple(sorted(
        path for path, path_data in scope["paths"].items()
        if any(version["status"] == "not_audited" for version in path_data["versions"])
    ))


def covers(scoped: Sequence[tuple[str, str]], path: str, scope: ScopePaths) -> bool:
    """Whether one of the scoped paths covers a file: as the file itself, or as a
    directory above it, which covers no test, mock, script or excluded file."""
    for scoped_path, path_kind in scoped:
        if path_kind == "file":
            if path == scoped_path:
                return True
            continue
        assert path_kind == "directory_recursive", path_kind
        if (
            path != scoped_path and is_under(path, scoped_path)
            and not is_test_or_mock(path, scoped_path)
            and excluding_path(path, scope) is None
        ):
            return True
    return False


def scope_roots(scope: ScopePaths, directory_files: Callable[[str], Iterable[str]]) -> list[str]:
    """Solidity files the expansion starts from: listed files, and the files of listed
    directories that are neither excluded nor tests, mocks or scripts (as in ``export``)."""
    roots: set[str] = set()
    for path, path_kind in scope.audited:
        if path_kind == "file":
            if path.endswith(".sol"):
                roots.add(path)
            continue
        roots.update(
            file for file in directory_files(path)
            if file.endswith(".sol") and covers(((path, path_kind),), file, scope)
        )
    return sorted(roots)


def excluding_path(path: str, scope: ScopePaths) -> str | None:
    for excluded in scope.excluded:
        if is_under(path, excluded):
            return excluded
    return None


def state_of(path: str, scope: ScopePaths, dependency: bool, mounted: bool) -> tuple[str, str]:
    """The state of a reached file and, when it is excluded, what excludes it.

    A scoped directory covers the files of the audited repository below it, not
    those of a submodule mounted there.
    """
    if not mounted and covers(scope.audited, path, scope):
        return LISTED, ""
    if not mounted and covers(scope.partial, path, scope):
        return PARTIAL, ""
    excluded = excluding_path(path, scope)
    if excluded is not None:
        return EXCLUDED, excluded
    if dependency and scope.dependencies == DEPENDENCIES_INCLUDED:
        return INCLUDED, ""
    if dependency and scope.dependencies == DEPENDENCIES_EXCLUDED:
        return EXCLUDED, "the report's statement about dependencies"
    if scope.unlisted == UNLISTED_NOT_MENTIONED:
        return IMPLIED, ""
    return EXCLUDED, "the report's statement about unlisted code"


def expand(
    roots: Sequence[str],
    scope: ScopePaths,
    graph: Mapping[str, Sequence[Edge]],
    facts: TreeFacts = NO_FACTS,
) -> Expansion:
    """Breadth-first from the roots over the imports, in two passes.

    The first reads on only from files the report audited in full, includes by
    its statement about dependencies, or is silent about: what it reaches is
    imported by audited code, through code the report does not rule out. The
    second reads on from everything else that was reached, so that every file
    whose declarations the audited code can name is known; a file it finds that
    the report is silent about is ``visible`` rather than ``implied``.
    """
    expansion = Expansion(list(roots), {}, [], set(), set())
    own_packages = facts.own_packages(roots)
    seen = set(roots)

    def walk(queue: deque[str], follow_all: bool, without_imports: set[str]) -> None:
        while queue:
            importer = queue.popleft()
            edges = graph.get(importer)
            if edges is None:
                without_imports.add(importer)
                continue
            for edge in edges:
                if edge.path is None:
                    expansion.skipped.append((importer, edge))
                    continue
                if edge.path in seen:
                    continue
                seen.add(edge.path)
                dependency = facts.is_dependency(edge.path, own_packages)
                state, reason = state_of(edge.path, scope, dependency, bool(facts.mount_of(edge.path)))
                if follow_all and state == IMPLIED:
                    state = VISIBLE
                expansion.reached[edge.path] = Reached(state, importer, dependency, reason)
                if follow_all or state in FOLLOWED_STATES:
                    queue.append(edge.path)

    walk(deque(roots), False, expansion.missing)
    stopped_at = [path for path, reached in expansion.reached.items() if reached.state not in FOLLOWED_STATES]
    walk(deque(stopped_at), True, expansion.unread)
    return expansion


def graph_from_manifest(manifest: dict[str, Any]) -> dict[tuple[str, str], dict[str, list[Edge]]]:
    """The resolved imports a manifest stores, by ``(repository, commit)``."""
    graph: dict[tuple[str, str], dict[str, list[Edge]]] = {}
    for repository, commits in manifest.get("imports", {}).items():
        for commit, files in commits.items():
            graph[(repository, commit)] = {
                path: [Edge.from_json(edge) for edge in edges] for path, edges in files.items()
            }
    return graph


def graph_to_manifest(
    graph: Mapping[tuple[str, str], Mapping[str, Sequence[Edge]]],
) -> dict[str, dict[str, dict[str, list[dict[str, str]]]]]:
    result: dict[str, dict[str, dict[str, list[dict[str, str]]]]] = {}
    for (repository, commit), files in sorted(graph.items()):
        result.setdefault(repository, {})[commit] = {
            path: [edge.to_json() for edge in files[path]] for path in sorted(files)
        }
    return result


def facts_from_manifest(manifest: dict[str, Any]) -> dict[tuple[str, str], TreeFacts]:
    """What a manifest knows about the dependencies of each tree, by ``(repository, commit)``."""
    return {
        (repository, commit): TreeFacts.from_json(tree)
        for repository, commits in manifest.get("trees", {}).items()
        for commit, tree in commits.items()
    }


def facts_to_manifest(facts: Mapping[tuple[str, str], TreeFacts]) -> dict[str, dict[str, Any]]:
    result: dict[str, dict[str, Any]] = {}
    for (repository, commit), tree in sorted(facts.items()):
        result.setdefault(repository, {})[commit] = tree.to_json()
    return result


# --- Explaining ---------------------------------------------------------------

STATE_MARKS = {LISTED: "=", PARTIAL: "~", EXCLUDED: "-", INCLUDED: "*", IMPLIED: "+", VISIBLE: "?"}


def explain(
    summary: dict[str, Any],
    graph: Mapping[tuple[str, str], Mapping[str, Sequence[Edge]]],
    facts: Mapping[tuple[str, str], TreeFacts],
    report_id: str | None,
) -> list[str]:
    """Human-readable expansion of every expanded report, or of one."""
    lines: list[str] = []
    for report in summary["reports"]:
        if report_id is not None and report["id"] != report_id:
            continue
        for (repository, commit), scope in sorted(report_scope_paths(report).items()):
            files = graph.get((repository, commit), {})
            tree = facts.get((repository, commit), NO_FACTS)
            roots = scope_roots(scope, lambda directory: [
                path for path in files if is_under(path, directory) and not tree.mount_of(path)
            ])
            expansion = expand(roots, scope, files, tree)
            lines.extend(explain_expansion(report["id"], repository, commit, expansion))
    return lines


def explain_expansion(report_id: str, repository: str, commit: str, expansion: Expansion) -> list[str]:
    counts = ", ".join(f"{len(expansion.in_state(state))} {state}" for state in REACHED_STATES)
    lines = [f"{report_id} {repository}@{commit[:8]}: {len(expansion.roots)} roots, {counts}"]
    for path, reached in sorted(expansion.reached.items()):
        notes = [f"imported by {reached.importer}"]
        if reached.dependency:
            notes.append("dependency")
        if reached.reason:
            notes.append(f"excluded by {reached.reason}")
        lines.append(f"  {STATE_MARKS[reached.state]} {path}  ({reached.state}, {', '.join(notes)})")
    for importer, edge in expansion.skipped:
        lines.append(f"  . {edge.import_path}  ({importer}: {edge.skipped})")
    for path in sorted(expansion.missing | expansion.unread):
        lines.append(f"  ! {path}  has no resolved imports; rerun fetch")
    return lines
