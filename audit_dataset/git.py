"""Git helpers: running git, reading trees and blobs, object ids."""

from __future__ import annotations

import hashlib
import os
import re
import subprocess
from pathlib import Path
from typing import Any

from . import DatasetError

FULL_COMMIT_RE = re.compile(r"(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})\Z")
GIT_ENVIRONMENT = {**os.environ, "GIT_TERMINAL_PROMPT": "0"}


class GitError(DatasetError):
    """A git command failed."""


def full_commit(revision: dict[str, Any]) -> str | None:
    """The lowercase commit when the revision pins one full commit; ranges never do."""
    if revision.get("kind") == "commit_range":
        return None
    commit = revision.get("commit")
    if isinstance(commit, str) and FULL_COMMIT_RE.fullmatch(commit):
        return commit.lower()
    return None


def hash_algorithm(object_id_length: int) -> str:
    if object_id_length == 40:
        return "sha1"
    if object_id_length == 64:
        return "sha256"
    raise DatasetError(f"not a git object id length: {object_id_length}")


def blob_id(data: bytes, object_id_length: int) -> str:
    """Git object id of a blob: sha1, or sha256 in a SHA-256 repository."""
    algorithm = hashlib.new(hash_algorithm(object_id_length))
    algorithm.update(b"blob %d\0" % len(data))
    algorithm.update(data)
    return algorithm.hexdigest()


def run(repository: Path | None, *args: str) -> bytes:
    command = ["git"]
    if repository is not None:
        command.extend(["-C", os.fspath(repository)])
    command.extend(args)
    try:
        completed = subprocess.run(command, check=True, capture_output=True, env=GIT_ENVIRONMENT)
    except FileNotFoundError as error:
        raise GitError("git executable was not found") from error
    except subprocess.CalledProcessError as error:
        stderr = error.stderr.decode(errors="replace").strip()
        raise GitError(f"{' '.join(command)} failed: {stderr}") from error
    return completed.stdout


def run_text(repository: Path | None, *args: str) -> str:
    return run(repository, *args).decode("utf-8", errors="replace")


def ls_tree(
    repository: Path, commit: str, path: str, recursive: bool
) -> list[tuple[str, str, str, str]]:
    """``(mode, type, object id, name)`` of the entries at ``path`` in ``commit``."""
    args = ["--literal-pathspecs", "ls-tree", "-z", "--full-tree"]
    if recursive:
        args.append("-r")
    args.extend([commit, "--", path])
    entries: list[tuple[str, str, str, str]] = []
    for record in run(repository, *args).split(b"\0"):
        if not record:
            continue
        metadata, separator, raw_name = record.partition(b"\t")
        if not separator:
            raise GitError(f"could not parse git tree entry for {path!r}")
        try:
            mode, object_type, object_id = metadata.decode("ascii").split(" ")
        except ValueError as error:
            raise GitError(f"could not parse git tree entry for {path!r}") from error
        name = raw_name.decode("utf-8", errors="surrogateescape")
        entries.append((mode, object_type, object_id, name))
    return entries


def read_blob(repository: Path, object_id: str) -> bytes:
    return run(repository, "cat-file", "blob", object_id)
