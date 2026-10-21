"""Expand a report's scope to the files its audited Solidity files import.

A report whose ``imports`` is ``audited_unless_excluded`` audited, at every
commit where it fully audited an ``evm`` file or directory, also every file of
the audited repository those files import, transitively, except the files the
report excludes (its ``not_audited`` paths in that repository, at any commit).
The expansion never passes through an excluded file: a file imported only by
excluded files stays unaudited. Dependencies are never followed: imports that
resolve outside the repository, into a submodule, into a Foundry project's
library directories (``lib`` or its ``libs``), or into ``node_modules`` or
``vendor``-like directories are recorded as skipped.

``fetch`` resolves the imports of every file the expansion reaches and stores
them in the manifest under ``imports``; ``export`` expands the same way from
that graph, and ``imports`` (the command) explains the expansion.
"""

from __future__ import annotations

import tomllib
from collections import deque
from dataclasses import dataclass
from pathlib import PurePosixPath
from typing import Any, Callable, Iterable, Mapping, Sequence

from .git import full_commit
from .scope import is_test_or_mock, is_under

IMPORTS_AUDITED_UNLESS_EXCLUDED = "audited_unless_excluded"
IMPORTS_NOT_AUDITED = "not_audited"
IMPORTS_VALUES = {IMPORTS_AUDITED_UNLESS_EXCLUDED, IMPORTS_NOT_AUDITED}
FULL_AUDIT_STATUSES = {"audited_with_no_major_findings", "audited_with_major_findings"}
PROJECT_CONFIG_NAMES = (
    "foundry.toml", "remappings.txt", "hardhat.config.js", "hardhat.config.ts",
    "truffle-config.js", "truffle.js",
)
# Files a project's imports are resolved with: remappings, and Foundry's library directories.
RESOLUTION_CONFIG_NAMES = ("foundry.toml", "remappings.txt")
FOUNDRY_DEFAULT_LIBRARIES = ("lib",)
DEPENDENCY_SEGMENTS = {"node_modules", ".deps"}
VENDORED_SEGMENTS = {
    "vendor", "vendored", "thirdparty", "third_party", "dependencies",
    # copies of libraries that have their own collections under _libs/
    "openzeppelin", "@openzeppelin", "openzeppelin-contracts", "openzeppelin-upgradeable", "solady", "solmate",
}


@dataclass(frozen=True)
class Edge:
    """One import statement: the own file it resolves to, or why it is not followed."""

    import_path: str  # as written in the source
    path: str | None = None
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
    covered: tuple[str, ...]  # every audited scoped path, fully or partially
    excluded: tuple[str, ...]  # the report's not_audited paths in the repository


@dataclass
class Expansion:
    roots: list[str]
    added: dict[str, str]  # file -> the file that first imported it
    pruned: dict[str, tuple[str, str]]  # excluded file -> (importer, excluding scope path)
    skipped: list[tuple[str, Edge]]  # (importer, edge) not followed
    missing: set[str]  # reached files without resolved imports in the graph


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
    except (UnicodeDecodeError, ValueError, tomllib.TOMLDecodeError, AttributeError) as error:
        return Project(root, (), libraries, f"invalid configuration: {error}")
    return Project(root, tuple(remappings), libraries, None)


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


def project_of(path: str, projects: Mapping[str, Project]) -> Project:
    """The nearest project above a file; the repository root without configuration otherwise."""
    directory = str(PurePosixPath(path).parent)
    directory = "" if directory == "." else directory
    while True:
        if directory in projects:
            return projects[directory]
        if not directory:
            return Project("", (), (), None)
        parent = str(PurePosixPath(directory).parent)
        directory = "" if parent == "." else parent


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


def resolve_import(
    importer: str,
    import_path: str,
    files: Mapping[str, Any],
    gitlinks: frozenset[str],
    projects: Mapping[str, Project],
) -> Edge:
    """Resolve one import of ``importer`` at a commit whose files are ``files``."""
    if import_path.startswith(("./", "../")):
        directory = str(PurePosixPath(importer).parent)
        candidate = normalize_path(join_path("" if directory == "." else directory, import_path))
        if candidate is None:
            return Edge(import_path, skipped="resolves outside the repository")
        return classify(import_path, candidate, files, gitlinks, projects)
    project = project_of(importer, projects)
    if project.problem is not None:
        return Edge(import_path, skipped=f"{project.root or '.'}: {project.problem}")
    remapping = select_remapping(project, importer, import_path)
    if remapping is not None:
        target = remapping.target + import_path[len(remapping.prefix):]
        candidate = normalize_path(join_path(project.root, target))
        if candidate is None:
            return Edge(import_path, skipped="remapped outside the repository")
        return classify(import_path, candidate, files, gitlinks, projects)
    project_candidate = normalize_path(join_path(project.root, import_path))
    if project_candidate is None:
        return Edge(import_path, skipped="resolves outside the repository")
    candidates = sorted({project_candidate, normalize_path(import_path) or project_candidate})
    existing = [path for path in candidates if path in files]
    if len(existing) > 1:
        return Edge(import_path, skipped=f"ambiguous: {' or '.join(existing)}")
    return classify(import_path, existing[0] if existing else project_candidate,
                    files, gitlinks, projects)


def classify(
    import_path: str,
    candidate: str,
    files: Mapping[str, Any],
    gitlinks: frozenset[str],
    projects: Mapping[str, Project],
) -> Edge:
    """Follow a resolved path only when it is an own file of the repository."""
    reason = dependency_reason(candidate, gitlinks, projects)
    if reason is not None:
        return Edge(import_path, skipped=reason)
    if candidate not in files:
        return Edge(import_path, skipped=f"not in the repository: {candidate}")
    return Edge(import_path, path=candidate)


def dependency_reason(
    path: str, gitlinks: frozenset[str], projects: Mapping[str, Project]
) -> str | None:
    parts = path.split("/")
    for end in range(1, len(parts)):
        if "/".join(parts[:end]) in gitlinks:
            return f"submodule dependency: {path}"
    if DEPENDENCY_SEGMENTS & set(parts[:-1]):
        return f"package dependency: {path}"
    if VENDORED_SEGMENTS & set(parts[:-1]):
        return f"vendored dependency: {path}"
    for project in projects.values():
        for library in project.libraries:
            if is_under(path, join_path(project.root, library)):
                return f"library dependency: {path}"
    return None


# --- Expanding ----------------------------------------------------------------


def report_scope_paths(report: dict[str, Any]) -> dict[tuple[str, str], ScopePaths]:
    """The scopes a report expands, by ``(repository, commit)``; none unless it opted in."""
    if not report["isRelevant"] or report.get("imports") != IMPORTS_AUDITED_UNLESS_EXCLUDED:
        return {}
    result: dict[tuple[str, str], ScopePaths] = {}
    for scope in report["scopes"]:
        repository = scope["repository"]
        excluded = tuple(sorted(
            path for path, path_data in scope["paths"].items()
            if any(version["status"] == "not_audited" for version in path_data["versions"])
        ))
        audited: dict[str, set[tuple[str, str]]] = {}
        covered: dict[str, set[str]] = {}
        for path, path_data in scope["paths"].items():
            for version in path_data["versions"]:
                commit = full_commit(version["revision"])
                if commit is None or version["status"] == "not_audited" or path_data["kind"] != "evm":
                    continue
                covered.setdefault(commit, set()).add(path)
                if version["status"] in FULL_AUDIT_STATUSES:
                    audited.setdefault(commit, set()).add((path, path_data["path_kind"]))
        for commit, paths in audited.items():
            assert (repository, commit) not in result, (report["id"], repository, commit)
            result[(repository, commit)] = ScopePaths(
                tuple(sorted(paths)), tuple(sorted(covered[commit])), excluded
            )
    return result


def scope_roots(scope: ScopePaths, directory_files: Callable[[str], Iterable[str]]) -> list[str]:
    """Solidity files the expansion starts from: listed files, and the files of listed
    directories that are neither excluded nor tests, mocks or scripts (as in ``export``)."""
    roots: set[str] = set()
    for path, path_kind in scope.audited:
        if path_kind == "file":
            if path.endswith(".sol"):
                roots.add(path)
            continue
        assert path_kind == "directory_recursive", path_kind
        for file in directory_files(path):
            assert is_under(file, path), (file, path)
            if (
                file.endswith(".sol")
                and not is_test_or_mock(file, path)
                and excluding_path(file, scope) is None
            ):
                roots.add(file)
    return sorted(roots)


def excluding_path(path: str, scope: ScopePaths) -> str | None:
    for excluded in scope.excluded:
        if is_under(path, excluded):
            return excluded
    return None


def expand(
    roots: Sequence[str], scope: ScopePaths, graph: Mapping[str, Sequence[Edge]]
) -> Expansion:
    """Breadth-first from the roots over own-file imports, never entering an excluded file."""
    expansion = Expansion(list(roots), {}, {}, [], set())
    reached_from: dict[str, str | None] = {root: None for root in roots}
    queue = deque(roots)
    visits = 0
    while queue:
        visits += 1
        assert visits <= len(reached_from), "every file is enqueued once"
        importer = queue.popleft()
        edges = graph.get(importer)
        if edges is None:
            expansion.missing.add(importer)
            continue
        for edge in edges:
            if edge.path is None:
                expansion.skipped.append((importer, edge))
                continue
            if edge.path in reached_from:
                continue
            excluded = excluding_path(edge.path, scope)
            if excluded is not None:
                expansion.pruned.setdefault(edge.path, (importer, excluded))
                continue
            reached_from[edge.path] = importer
            queue.append(edge.path)
    for path, importer in reached_from.items():
        if importer is None or any(is_under(path, covered) for covered in scope.covered):
            continue
        assert excluding_path(path, scope) is None, path
        expansion.added[path] = importer
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


# --- Explaining ---------------------------------------------------------------


def explain(
    summary: dict[str, Any],
    graph: Mapping[tuple[str, str], Mapping[str, Sequence[Edge]]],
    report_id: str | None,
) -> list[str]:
    """Human-readable expansion of every opted-in report, or of one."""
    lines: list[str] = []
    for report in summary["reports"]:
        if report_id is not None and report["id"] != report_id:
            continue
        for (repository, commit), scope in sorted(report_scope_paths(report).items()):
            files = graph.get((repository, commit), {})
            roots = scope_roots(scope, lambda directory: [p for p in files if is_under(p, directory)])
            lines.extend(explain_expansion(report["id"], repository, commit, expand(roots, scope, files)))
    return lines


def explain_expansion(report_id: str, repository: str, commit: str, expansion: Expansion) -> list[str]:
    lines = [f"{report_id} {repository}@{commit[:8]}: {len(expansion.roots)} roots, "
             f"{len(expansion.added)} added, {len(expansion.pruned)} excluded"]
    for path, importer in sorted(expansion.added.items()):
        lines.append(f"  + {path}  (imported by {importer})")
    for path, (importer, excluded) in sorted(expansion.pruned.items()):
        lines.append(f"  - {path}  (imported by {importer}, excluded by {excluded})")
    for importer, edge in expansion.skipped:
        lines.append(f"  . {edge.import_path}  ({importer}: {edge.skipped})")
    for path in sorted(expansion.missing):
        lines.append(f"  ! {path}  has no resolved imports; rerun fetch")
    return lines
