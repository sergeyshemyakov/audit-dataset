#!/usr/bin/env python3
"""Format audited Solidity sources with one shared forge fmt config.

The config is also exported as ``foundry.toml`` at the dataset root so that
consumers (l2beat audit-diff) format deployed sources with identical rules.
"""

from __future__ import annotations

import argparse
import hashlib
import re
import subprocess
import sys
import tempfile
from pathlib import Path


# Directories inside a collection whose Solidity sources are formatted in place.
SOURCE_DIRS = ("audited-sources",)

# The shared config is exported here for consumers that format deployed sources.
EXPORTED_CONFIG_NAME = "foundry.toml"

# Every forge fmt key is pinned so that the result does not depend on the
# installed forge version's defaults, on any foundry.toml vendored inside an
# audited repository, or on the machine the script runs on. Both sides of a
# deployed-vs-audited comparison must be formatted with exactly this config,
# otherwise the diff reports style instead of code.
FMT_CONFIG = """\
[fmt]
line_length = 120
tab_width = 4
bracket_spacing = false
int_types = "long"
multiline_func_header = "attributes_first"
quote_style = "double"
number_underscore = "preserve"
hex_underscore = "remove"
single_line_statement_blocks = "multi"
override_spacing = false
wrap_comments = false
contract_new_lines = false
sort_imports = true
ignore = []
"""

# forge fmt reports unparsable input as `Failed to parse Solidity code for <path>.`
PARSE_FAILURE_RE = re.compile(r"Failed to parse Solidity code for (.+?)\.\s*$", re.M)
# In --check mode each file that is not already formatted is reported as `Diff in <path>:`.
CHECK_DIFF_RE = re.compile(r"^Diff in (.+):$", re.M)
ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")

# Keep argument lists well below the OS limit while still amortising process startup.
CHUNK_SIZE = 200


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Reformat every Solidity file under a collection's audited-sources "
            "directory with a single shared forge fmt config, exported to "
            "foundry.toml at the dataset root so that deployed sources can be "
            "formatted identically by consumers."
        )
    )
    parser.add_argument(
        "projects",
        nargs="*",
        metavar="PROJECT",
        help="collection name, e.g. tornado-cash or _libs/safe; may be repeated",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="format every project in the dataset instead of named ones",
    )
    parser.add_argument(
        "--dataset-root",
        type=Path,
        default=Path(__file__).resolve().parent,
        help="audit-dataset checkout (default: directory containing this script)",
    )
    parser.add_argument(
        "--config",
        type=Path,
        help=(
            "foundry.toml to use instead of the config embedded in this script; "
            "its [fmt] section must be complete because forge fills in missing "
            "keys from its own defaults"
        ),
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="report files that are not formatted and exit non-zero, changing nothing",
    )
    parser.add_argument(
        "--forge",
        default="forge",
        help="forge executable (default: forge)",
    )
    return parser.parse_args()


def discover_projects(dataset_root: Path) -> list[str]:
    """Collections with audited sources: top-level projects and ``_libs/<vendor>``."""
    projects: list[str] = []
    for path in sorted(dataset_root.iterdir()):
        if not path.is_dir() or path.name.startswith("."):
            continue
        if any((path / name).is_dir() for name in SOURCE_DIRS):
            projects.append(path.name)
        elif path.name == "_libs":
            for vendor in sorted(path.iterdir()):
                if vendor.is_dir() and any((vendor / name).is_dir() for name in SOURCE_DIRS):
                    projects.append(f"_libs/{vendor.name}")
    return projects


def export_config(dataset_root: Path, config: str) -> bool:
    """Write the shared config to ``<root>/foundry.toml``; True when it changed."""
    target = dataset_root / EXPORTED_CONFIG_NAME
    if target.is_file() and target.read_text() == config:
        return False
    target.write_text(config)
    return True


def collect_sources(project_dir: Path) -> list[Path]:
    """Return every Solidity file under the project's source directories.

    Audited sources pin some paths as `Foo.sol/<commit>/Foo.sol`, so a `*.sol`
    glob also matches directories; only regular files are returned, and each
    file is passed to forge explicitly rather than letting it walk a directory.
    """
    sources: list[Path] = []
    for name in SOURCE_DIRS:
        source_dir = project_dir / name
        if not source_dir.is_dir():
            continue
        sources.extend(
            path
            for path in source_dir.rglob("*.sol")
            if path.is_file() and not path.is_symlink()
        )
    return sorted(sources)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def chunked(items: list[Path], size: int) -> list[list[Path]]:
    return [items[start : start + size] for start in range(0, len(items), size)]


def run_forge_fmt(
    forge: str, root: Path, paths: list[Path], check: bool
) -> tuple[str, str]:
    command = [forge, "fmt", "--root", str(root), "--color", "never"]
    if check:
        command.append("--check")
    command.extend(str(path) for path in paths)
    try:
        result = subprocess.run(command, capture_output=True, text=True)
    except FileNotFoundError as error:
        raise RuntimeError(
            f"{forge} not found; install Foundry or pass --forge PATH"
        ) from error
    return ANSI_RE.sub("", result.stdout), ANSI_RE.sub("", result.stderr)


def resolve_reported(dataset_root: Path, reported: str) -> Path:
    """Map a path reported by forge back onto the dataset."""
    path = Path(reported)
    if not path.is_absolute():
        path = (dataset_root / path).resolve()
    return path


def format_project(
    project: str,
    dataset_root: Path,
    root: Path,
    forge: str,
    check: bool,
) -> tuple[int, list[Path], list[Path]]:
    """Format one project, returning the file count plus changed and failed paths."""
    project_dir = dataset_root / project
    if not project_dir.is_dir() and (dataset_root / "_libs" / project).is_dir():
        project_dir = dataset_root / "_libs" / project
    if not project_dir.is_dir():
        raise RuntimeError(f"project directory not found: {project_dir}")

    sources = collect_sources(project_dir)
    if not sources:
        raise RuntimeError(
            f"no Solidity sources under {project}/"
            f"{{{','.join(SOURCE_DIRS)}}}"
        )

    changed: list[Path] = []
    failed: list[Path] = []
    for chunk in chunked(sources, CHUNK_SIZE):
        # forge fmt exits non-zero both for unformatted input in --check mode and
        # for parse errors, so failures are read out of its output instead.
        before = {} if check else {path: digest(path) for path in chunk}
        stdout, stderr = run_forge_fmt(forge, root, chunk, check)
        output = f"{stdout}\n{stderr}"

        for reported in PARSE_FAILURE_RE.findall(output):
            failed.append(resolve_reported(dataset_root, reported.strip()))
        if check:
            for reported in CHECK_DIFF_RE.findall(output):
                changed.append(resolve_reported(dataset_root, reported.strip()))
        else:
            changed.extend(
                path for path in chunk if digest(path) != before[path]
            )

    return len(sources), sorted(changed), sorted(failed)


def report(project: str, total: int, changed: list[Path], failed: list[Path], check: bool) -> None:
    verb = "need formatting" if check else "reformatted"
    print(f"{project}: {total} files, {len(changed)} {verb}, {len(failed)} failed")
    for path in failed:
        print(f"  failed to parse: {path}", file=sys.stderr)


def main() -> int:
    args = parse_args()
    dataset_root = args.dataset_root.resolve()

    if args.all and args.projects:
        print("error: pass either --all or project names, not both", file=sys.stderr)
        return 2
    if not dataset_root.is_dir():
        print(f"error: dataset root not found: {dataset_root}", file=sys.stderr)
        return 2

    if args.all:
        projects = discover_projects(dataset_root)
        if not projects:
            print(f"error: no projects found in {dataset_root}", file=sys.stderr)
            return 1
    elif args.projects:
        projects = list(dict.fromkeys(args.projects))
    else:
        print("error: pass at least one project name or --all", file=sys.stderr)
        return 2

    config = FMT_CONFIG
    if args.config is not None:
        try:
            config = args.config.read_text()
        except OSError as error:
            print(f"error: {error}", file=sys.stderr)
            return 1

    if args.config is None and export_config(dataset_root, config):
        print(f"exported fmt config to {dataset_root / EXPORTED_CONFIG_NAME}")

    # forge is pointed at a throwaway root so that it never picks up a
    # foundry.toml vendored inside an audited repository.
    with tempfile.TemporaryDirectory(prefix="audit-dataset-fmt-") as temp_dir:
        root = Path(temp_dir)
        (root / "foundry.toml").write_text(config)

        total_files = 0
        total_changed = 0
        total_failed = 0
        for project in projects:
            try:
                count, changed, failed = format_project(
                    project, dataset_root, root, args.forge, args.check
                )
            except (RuntimeError, OSError) as error:
                print(f"error: {error}", file=sys.stderr)
                return 1
            report(project, count, changed, failed, args.check)
            total_files += count
            total_changed += len(changed)
            total_failed += len(failed)

    if len(projects) > 1:
        verb = "need formatting" if args.check else "reformatted"
        print(
            f"total: {total_files} files across {len(projects)} projects, "
            f"{total_changed} {verb}, {total_failed} failed"
        )

    if total_failed:
        return 1
    if args.check and total_changed:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
