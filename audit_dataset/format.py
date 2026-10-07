"""Format audited Solidity sources with one shared forge fmt config.

The config is also written to ``foundry.toml`` at the dataset root so that
consumers format deployed sources with identical rules. Every key is pinned so
that the result does not depend on the installed forge version's defaults, on a
``foundry.toml`` vendored inside an audited repository, or on the machine.
"""

from __future__ import annotations

import hashlib
import re
import subprocess
import tempfile
from pathlib import Path

from . import DatasetError
from .collections import Collection

EXPORTED_CONFIG_NAME = "foundry.toml"

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


def export_config(root: Path) -> bool:
    """Write the shared config to ``<root>/foundry.toml``; True when it changed."""
    target = root / EXPORTED_CONFIG_NAME
    if target.is_file() and target.read_text(encoding="utf-8") == FMT_CONFIG:
        return False
    target.write_text(FMT_CONFIG, encoding="utf-8")
    return True


def solidity_files(collection: Collection) -> list[Path]:
    if not collection.sources_dir.is_dir():
        return []
    return sorted(
        path for path in collection.sources_dir.rglob("*.sol")
        if path.is_file() and not path.is_symlink()
    )


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_forge_fmt(forge: str, root: Path, paths: list[Path], check: bool) -> str:
    command = [forge, "fmt", "--root", str(root), "--color", "never"]
    if check:
        command.append("--check")
    command.extend(str(path) for path in paths)
    try:
        result = subprocess.run(command, capture_output=True, text=True)
    except FileNotFoundError as error:
        raise DatasetError(f"{forge} not found; install Foundry or pass --forge PATH") from error
    return ANSI_RE.sub("", f"{result.stdout}\n{result.stderr}")


def format_collection(
    collection: Collection, forge_root: Path, forge: str, check: bool
) -> tuple[int, list[Path], list[Path]]:
    """Format one collection; returns file count, changed paths and parse failures."""
    sources = solidity_files(collection)
    changed: list[Path] = []
    failed: list[Path] = []
    for start in range(0, len(sources), CHUNK_SIZE):
        chunk = sources[start:start + CHUNK_SIZE]
        # forge fmt exits non-zero both for unformatted input in --check mode and
        # for parse errors, so failures are read out of its output instead.
        before = {} if check else {path: digest(path) for path in chunk}
        output = run_forge_fmt(forge, forge_root, chunk, check)
        failed.extend(Path(reported.strip()) for reported in PARSE_FAILURE_RE.findall(output))
        if check:
            changed.extend(Path(reported.strip()) for reported in CHECK_DIFF_RE.findall(output))
        else:
            changed.extend(path for path in chunk if digest(path) != before[path])
    return len(sources), sorted(changed), sorted(failed)


def format_collections(
    root: Path, collections: list[Collection], forge: str, check: bool
) -> tuple[int, int, int]:
    """Format every collection; returns totals of files, changed and failed."""
    if not check and export_config(root):
        print(f"exported fmt config to {root / EXPORTED_CONFIG_NAME}")
    totals = [0, 0, 0]
    # forge is pointed at a throwaway root so that it never picks up a
    # foundry.toml vendored inside an audited repository.
    with tempfile.TemporaryDirectory(prefix="audit-dataset-fmt-") as temporary:
        forge_root = Path(temporary)
        (forge_root / EXPORTED_CONFIG_NAME).write_text(FMT_CONFIG, encoding="utf-8")
        for collection in collections:
            count, changed, failed = format_collection(collection, forge_root, forge, check)
            verb = "need formatting" if check else "reformatted"
            print(f"{collection.name}: {count} files, {len(changed)} {verb}, {len(failed)} failed")
            for path in failed:
                print(f"  failed to parse: {path}")
            totals[0] += count
            totals[1] += len(changed)
            totals[2] += len(failed)
    return totals[0], totals[1], totals[2]
