"""Collections: one directory per project, or per vendor under ``_libs/``."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from . import DatasetError

LIBRARIES_DIR = "_libs"
SUMMARY_NAME = "audit-summary.json"
RENDERED_SUMMARY_NAME = "audit-summary.md"
REPORTS_DIR = "reports"
SOURCES_DIR = "audited-sources"
MANIFEST_NAME = "manifest.json"


@dataclass(frozen=True, order=True)
class Collection:
    root: Path
    directory: Path

    @property
    def name(self) -> str:
        """``scroll`` or ``_libs/safe``: the path relative to the dataset root."""
        return self.directory.relative_to(self.root).as_posix()

    @property
    def kind(self) -> str:
        return "library" if self.directory.parent.name == LIBRARIES_DIR else "project"

    @property
    def summary_path(self) -> Path:
        return self.directory / SUMMARY_NAME

    @property
    def rendered_summary_path(self) -> Path:
        return self.directory / RENDERED_SUMMARY_NAME

    @property
    def reports_dir(self) -> Path:
        return self.directory / REPORTS_DIR

    @property
    def sources_dir(self) -> Path:
        return self.directory / SOURCES_DIR

    @property
    def manifest_path(self) -> Path:
        return self.sources_dir / MANIFEST_NAME


def discover(root: Path) -> list[Collection]:
    """Every directory with an ``audit-summary.json``: projects and ``_libs/<vendor>``."""
    found: list[Collection] = []
    for child in sorted(root.iterdir()):
        if not child.is_dir() or child.name.startswith((".", "_")):
            continue
        if (child / SUMMARY_NAME).is_file():
            found.append(Collection(root, child))
    libraries = root / LIBRARIES_DIR
    if libraries.is_dir():
        for vendor in sorted(libraries.iterdir()):
            if vendor.is_dir() and (vendor / SUMMARY_NAME).is_file():
                found.append(Collection(root, vendor))
    return found


def resolve(root: Path, name: str) -> Collection:
    """A collection by name: ``scroll``, ``safe`` or ``_libs/safe``."""
    for candidate in (root / name, root / LIBRARIES_DIR / name):
        if (candidate / SUMMARY_NAME).is_file():
            return Collection(root, candidate.resolve())
    raise DatasetError(f"no collection named {name!r} in {root}")


def select(root: Path, names: list[str], select_all: bool) -> list[Collection]:
    """The collections a command was asked to work on."""
    if select_all and names:
        raise DatasetError("pass either --all or collection names, not both")
    if select_all:
        collections = discover(root)
        if not collections:
            raise DatasetError(f"no collections in {root}")
        return collections
    if not names:
        raise DatasetError("pass collection names or --all")
    return [resolve(root, name) for name in dict.fromkeys(names)]
