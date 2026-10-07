"""``python3 -m audit_dataset <command>``: the dataset's command line."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from . import DatasetError
from .collections import discover, resolve, select

DEFAULT_ROOT = Path(__file__).resolve().parent.parent


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    root = args.dataset_root.resolve()
    try:
        return args.handler(root, args)
    except DatasetError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python3 -m audit_dataset",
        description="Maintain the audit dataset. Run the commands in this order for a "
                    "collection, or `pipeline` to run them all.",
    )
    parser.add_argument("--dataset-root", type=Path, default=DEFAULT_ROOT,
                        help="dataset checkout (default: the one containing this package)")
    commands = parser.add_subparsers(dest="command", required=True, metavar="COMMAND")

    def collections_argument(sub: argparse.ArgumentParser) -> None:
        sub.add_argument("collections", nargs="*", metavar="COLLECTION",
                         help="collection name, e.g. scroll or safe")
        sub.add_argument("--all", action="store_true", help="every collection")

    sub = commands.add_parser("pdf-to-md", help="convert PDF reports to Markdown for the extraction agent")
    collections_argument(sub)
    sub.set_defaults(handler=command_pdf_to_md)

    sub = commands.add_parser("render", help="validate audit-summary.json and render audit-summary.md")
    collections_argument(sub)
    sub.set_defaults(handler=command_render)

    sub = commands.add_parser("fetch", help="fetch the audited sources pinned by audit-summary.json")
    collections_argument(sub)
    sub.set_defaults(handler=command_fetch)

    sub = commands.add_parser("format", help="format audited Solidity with the shared forge fmt config")
    collections_argument(sub)
    sub.add_argument("--check", action="store_true", help="report unformatted files, change nothing")
    sub.add_argument("--forge", default="forge", help="forge executable (default: forge)")
    sub.set_defaults(handler=command_format)

    sub = commands.add_parser("index", help="verify stored sources against the manifest and record their hashes")
    collections_argument(sub)
    sub.set_defaults(handler=command_index)

    sub = commands.add_parser("repositories", help="rebuild repositories.json from every collection")
    sub.add_argument("--no-lookup", action="store_true", help="do not query GitHub for fork lineage")
    sub.set_defaults(handler=command_repositories)

    sub = commands.add_parser("export", help="regenerate audit-index.json and audit-objects.json.zst")
    sub.add_argument("--check", action="store_true", help="verify the committed export, write nothing")
    sub.set_defaults(handler=command_export)

    sub = commands.add_parser("pipeline", help="render, fetch, format, index, repositories and export")
    sub.add_argument("collection", metavar="COLLECTION")
    sub.add_argument("--no-lookup", action="store_true", help="do not query GitHub for fork lineage")
    sub.add_argument("--forge", default="forge")
    sub.set_defaults(handler=command_pipeline)

    sub = commands.add_parser("repository-id", help="print the canonical repository id of a URL")
    sub.add_argument("url")
    sub.set_defaults(handler=command_repository_id)
    return parser


def command_pdf_to_md(root: Path, args: argparse.Namespace) -> int:
    from .pdf import convert_collection

    status = 0
    for collection in select(root, args.collections, args.all):
        converted, existing, failures = convert_collection(collection)
        print(f"{collection.name}: {converted} converted, {existing} already converted, {len(failures)} failed")
        for failure in failures:
            print(f"  {failure}", file=sys.stderr)
            status = 1
    return status


def command_render(root: Path, args: argparse.Namespace) -> int:
    from .render import render_collection

    for collection in select(root, args.collections, args.all):
        render_collection(collection)
        print(f"wrote {collection.rendered_summary_path.relative_to(root)}")
    return 0


def command_fetch(root: Path, args: argparse.Namespace) -> int:
    from .fetch import fetch_collection

    for collection in select(root, args.collections, args.all):
        result = fetch_collection(collection)
        for warning in result.warnings:
            print(f"warning: {warning}", file=sys.stderr)
        print(
            f"{collection.name}: {result.sources} sources, {result.files} files; "
            f"skipped {result.skipped} unpinned revisions, {result.unavailable} unavailable, "
            f"{result.omitted} files omitted"
        )
    return 0


def command_format(root: Path, args: argparse.Namespace) -> int:
    from .format import format_collections

    collections = select(root, args.collections, args.all)
    files, changed, failed = format_collections(root, collections, args.forge, args.check)
    if len(collections) > 1:
        verb = "need formatting" if args.check else "reformatted"
        print(f"total: {files} files, {changed} {verb}, {failed} failed")
    return 1 if failed or (args.check and changed) else 0


def command_index(root: Path, args: argparse.Namespace) -> int:
    from .index import index_collection

    status = 0
    for collection in select(root, args.collections, args.all):
        count, problems = index_collection(collection)
        print(f"{collection.name}: {count} files indexed, {len(problems)} problems")
        for problem in problems:
            print(f"  {problem}", file=sys.stderr)
            status = 1
    return status


def command_repositories(root: Path, args: argparse.Namespace) -> int:
    from .repositories import update_registry

    path, repositories, forks, warnings = update_registry(root, discover(root), not args.no_lookup)
    print(f"wrote {path.name}: {repositories} repositories, {forks} with fork_of")
    for warning in warnings:
        print(f"warning: {warning}", file=sys.stderr)
    return 0


def command_export(root: Path, args: argparse.Namespace) -> int:
    from .export import export_dataset

    return export_dataset(root, check=args.check)


def command_pipeline(root: Path, args: argparse.Namespace) -> int:
    from .pipeline import run_pipeline

    run_pipeline(root, resolve(root, args.collection), not args.no_lookup, args.forge)
    return 0


def command_repository_id(root: Path, args: argparse.Namespace) -> int:
    from .repositories import canonical_repository_id

    print(canonical_repository_id(args.url))
    return 0
