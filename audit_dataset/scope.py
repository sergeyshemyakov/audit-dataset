"""Which files a scoped path covers."""

from __future__ import annotations

from pathlib import PurePosixPath

# Files a directory scope sweeps in that are not audit evidence of deployed code:
# tests, mocks and deployment scripts, told apart by a path segment below the
# scoped directory or by the Foundry test and script suffixes. A file scope
# stores its file whatever its name.
EXCLUDED_SEGMENTS = frozenset({"test", "tests", "mock", "mocks", "script", "scripts"})
EXCLUDED_SUFFIXES = (".t.sol", ".s.sol")


def is_under(path: str, scoped_path: str) -> bool:
    """A scoped path covers itself and, as a directory, everything below it."""
    return path == scoped_path or path.startswith(f"{scoped_path}/")


def is_test_or_mock(path: str, scoped_path: str) -> bool:
    """Whether a file below a directory scope is a test, mock or script."""
    relative = path[len(scoped_path) + 1:] if scoped_path else path
    parts = PurePosixPath(relative).parts
    return (
        any(part.lower() in EXCLUDED_SEGMENTS for part in parts[:-1])
        or relative.lower().endswith(EXCLUDED_SUFFIXES)
    )
