"""Convert every PDF report of a collection to Markdown for the extraction agent."""

from __future__ import annotations

from pathlib import Path

from . import DatasetError
from .collections import Collection


def convert_collection(collection: Collection) -> tuple[int, int, list[str]]:
    """Write ``<report>.md`` beside every PDF under ``reports/`` that has none.

    Returns the counts of converted and already converted PDFs and the failures.
    """
    try:
        import pymupdf4llm
    except ImportError as error:
        raise DatasetError(
            "pymupdf4llm is not installed; see the README for the virtual environment"
        ) from error
    # The layout converter detects link annotations but does not emit them; the
    # legacy converter resolves them to Markdown links.
    pymupdf4llm.use_layout(False)

    converted = 0
    existing = 0
    failures: list[str] = []
    for pdf in sorted(collection.reports_dir.rglob("*.[pP][dD][fF]")):
        if not pdf.is_file():
            continue
        markdown = pdf.with_suffix(".md")
        if markdown.is_file():
            existing += 1
            continue
        try:
            text = pymupdf4llm.to_markdown(
                str(pdf), write_images=False, ignore_graphics=True, ignore_images=True
            )
            markdown.write_text(text, encoding="utf-8")
        except Exception as error:  # the library raises many types; any failure is reported
            failures.append(f"{relative(pdf, collection)}: {error}")
            continue
        converted += 1
        print(f"  {relative(markdown, collection)}")
    return converted, existing, failures


def relative(path: Path, collection: Collection) -> str:
    return path.relative_to(collection.directory).as_posix()
