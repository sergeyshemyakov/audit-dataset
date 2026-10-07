"""Tools that maintain the audit dataset: validate summaries, fetch audited
sources, format and index them, and build the public export.

Run ``python3 -m audit_dataset --help`` for the commands.
"""


class DatasetError(Exception):
    """A dataset invariant is broken; the message says which."""
