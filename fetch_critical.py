#!/usr/bin/env python3
"""Export a project's critical L2BEAT discovery contracts and flat sources."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path
from typing import Any

# replace with your path to l2beat repo
# or run with --l2beat-root
DEFAULT_L2BEAT_ROOT = Path.home() / "Documents" / "l2beat"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Write critical.json and copy flattened sources for one L2BEAT "
            "discovery project."
        )
    )
    parser.add_argument("project", help="L2BEAT discovery project name")
    parser.add_argument(
        "--l2beat-root",
        type=Path,
        default=DEFAULT_L2BEAT_ROOT,
        help=f"L2BEAT checkout (default: {DEFAULT_L2BEAT_ROOT})",
    )
    parser.add_argument(
        "--dataset-root",
        type=Path,
        default=Path(__file__).resolve().parent,
        help="audit-dataset checkout (default: directory containing this script)",
    )
    return parser.parse_args()


def strip_jsonc(text: str) -> str:
    """Remove JSONC comments and trailing commas without altering strings."""
    without_comments: list[str] = []
    index = 0
    in_string = False
    escaped = False

    while index < len(text):
        char = text[index]
        following = text[index + 1] if index + 1 < len(text) else ""

        if in_string:
            without_comments.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue

        if char == '"':
            in_string = True
            without_comments.append(char)
            index += 1
        elif char == "/" and following == "/":
            index += 2
            while index < len(text) and text[index] not in "\r\n":
                index += 1
        elif char == "/" and following == "*":
            index += 2
            while index + 1 < len(text) and text[index : index + 2] != "*/":
                # Preserve newlines so JSON errors retain useful line numbers.
                if text[index] in "\r\n":
                    without_comments.append(text[index])
                index += 1
            if index + 1 >= len(text):
                raise ValueError("Unterminated block comment in JSONC file")
            index += 2
        else:
            without_comments.append(char)
            index += 1

    cleaned = "".join(without_comments)
    without_trailing_commas: list[str] = []
    index = 0
    in_string = False
    escaped = False
    while index < len(cleaned):
        char = cleaned[index]
        if in_string:
            without_trailing_commas.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue

        if char == '"':
            in_string = True
        if char == ",":
            lookahead = index + 1
            while lookahead < len(cleaned) and cleaned[lookahead].isspace():
                lookahead += 1
            if lookahead < len(cleaned) and cleaned[lookahead] in "}]":
                index += 1
                continue
        without_trailing_commas.append(char)
        index += 1

    return "".join(without_trailing_commas)


def read_jsonc(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(strip_jsonc(path.read_text()))
    except (OSError, json.JSONDecodeError, ValueError) as error:
        raise RuntimeError(f"Could not read {path}: {error}") from error
    if not isinstance(value, dict):
        raise RuntimeError(f"Expected a JSON object in {path}")
    return value


def merge_dicts(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    """Approximate lodash.merge for the object-shaped discovery color config."""
    result = dict(base)
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = merge_dicts(result[key], value)
        else:
            result[key] = value
    return result


def read_config_with_imports(path: Path, active: set[Path] | None = None) -> dict[str, Any]:
    active = set() if active is None else active
    resolved = path.resolve()
    if resolved in active:
        raise RuntimeError(f"Circular discovery config import involving {resolved}")

    raw = read_jsonc(resolved)
    imported: dict[str, Any] = {}
    next_active = active | {resolved}
    imports = raw.get("import", [])
    if not isinstance(imports, list) or not all(isinstance(item, str) for item in imports):
        raise RuntimeError(f"Invalid import list in {resolved}")
    for import_name in imports:
        imported = merge_dicts(
            imported,
            read_config_with_imports(resolved.parent / import_name, next_active),
        )
    return merge_dicts(imported, raw)


def source_paths(flat_dir: Path, name: str, chain_address: str) -> list[Path]:
    """Find paths emitted by L2BEAT's flattenDiscoveredSources()."""
    direct_file = flat_dir / f"{name}.sol"
    direct_directory = flat_dir / name
    if direct_file.is_file():
        return [direct_file]
    if direct_directory.is_dir():
        return sorted(path for path in direct_directory.rglob("*") if path.is_file())

    # Duplicate discovered names receive an address suffix. Older outputs used
    # either the chain-specific or bare address, so accept both exact variants.
    bare_address = chain_address.split(":", 1)[-1]
    alternatives = {
        f"{name}-{chain_address}",
        f"{name}-{bare_address}",
    }
    for alternative in alternatives:
        candidate_file = flat_dir / f"{alternative}.sol"
        candidate_directory = flat_dir / alternative
        if candidate_file.is_file():
            return [candidate_file]
        if candidate_directory.is_dir():
            return sorted(path for path in candidate_directory.rglob("*") if path.is_file())
    return []


def critical_reason(
    entry: dict[str, Any], config: dict[str, Any], templates_dir: Path
) -> str | None:
    address = entry.get("address")
    overrides = config.get("overrides", {})
    override = overrides.get(address, {})
    if not override and isinstance(address, str):
        override = next(
            (
                value
                for key, value in overrides.items()
                if isinstance(key, str) and key.lower() == address.lower()
            ),
            {},
        )
    if "critical" in override:
        return "project override" if override["critical"] is True else None

    template = entry.get("template")
    if isinstance(template, str):
        template_path = templates_dir / template / "template.jsonc"
        if template_path.is_file():
            template_config = read_jsonc(template_path)
            if template_config.get("critical") is True:
                return f"template:{template}"
            if template_config.get("critical") is False:
                return None

    # This keeps the script compatible with discovery outputs produced by a
    # newer L2BEAT version whose template/config layout has subsequently moved.
    if entry.get("critical") is True:
        return "discovered output"
    return None


def export_project(project: str, l2beat_root: Path, dataset_root: Path) -> tuple[int, int]:
    projects_dir = l2beat_root.resolve() / "packages" / "config" / "src" / "projects"
    project_dir = projects_dir / project
    destination = dataset_root.resolve() / project

    if project in {"", ".", ".."} or Path(project).name != project:
        raise RuntimeError("Project name must be a single directory name")
    if not project_dir.is_dir():
        raise RuntimeError(f"L2BEAT project does not exist: {project_dir}")
    if not destination.is_dir():
        raise RuntimeError(f"Dataset project does not exist: {destination}")

    config_path = project_dir / "config.jsonc"
    discovered_path = project_dir / "discovered.json"
    flat_dir = project_dir / ".flat"
    templates_dir = projects_dir / "_templates"
    for required in (config_path, discovered_path, flat_dir, templates_dir):
        if not required.exists():
            raise RuntimeError(f"Required L2BEAT discovery path does not exist: {required}")

    config = read_config_with_imports(config_path)
    discovered = read_jsonc(discovered_path)
    entries = discovered.get("entries")
    if not isinstance(entries, list):
        raise RuntimeError(f"Expected an entries array in {discovered_path}")

    contracts: list[dict[str, Any]] = []
    missing_sources: list[str] = []
    deployed_dir = destination / "deployed-contracts"

    for entry in entries:
        if not isinstance(entry, dict) or entry.get("type") != "Contract":
            continue
        reason = critical_reason(entry, config, templates_dir)
        if reason is None:
            continue

        name = entry.get("name")
        chain_address = entry.get("address")
        if not isinstance(name, str) or not isinstance(chain_address, str):
            raise RuntimeError("Critical discovery entry lacks a string name or address")

        copied: list[str] = []
        for source in source_paths(flat_dir, name, chain_address):
            relative_source = source.relative_to(flat_dir)
            target = deployed_dir / relative_source
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            copied.append((Path("deployed-contracts") / relative_source).as_posix())
        if not copied:
            missing_sources.append(name)

        chain, separator, address = chain_address.partition(":")
        contract: dict[str, Any] = {
            "name": name,
            "address": address if separator else chain_address,
            "chain": chain if separator else None,
            "chainSpecificAddress": chain_address,
            "criticalitySource": reason,
            "sourceFiles": copied,
        }
        if isinstance(entry.get("template"), str):
            contract["template"] = entry["template"]
        contracts.append(contract)

    contracts.sort(key=lambda item: (item["chainSpecificAddress"].lower(), item["name"]))
    output = {
        "project": project,
        "discoveryTimestamp": discovered.get("timestamp"),
        "contracts": contracts,
    }
    (destination / "critical.json").write_text(json.dumps(output, indent=2) + "\n")

    for name in missing_sources:
        print(f"warning: no flattened source found for critical contract {name}", file=sys.stderr)
    return len(contracts), sum(len(contract["sourceFiles"]) for contract in contracts)


def main() -> int:
    args = parse_args()
    try:
        contract_count, source_count = export_project(
            args.project, args.l2beat_root, args.dataset_root
        )
    except RuntimeError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print(
        f"Exported {contract_count} critical contracts and {source_count} source files "
        f"to {args.dataset_root.resolve() / args.project}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
