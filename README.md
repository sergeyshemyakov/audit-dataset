# Audit dataset

This repository records which code public security audits covered. For each project tracked by L2BEAT, and for widely reused libraries, it holds the audit reports, a summary of what each report audited, and the audited source files at the exact audited commits.

The dataset records audit evidence only. Comparing it with the code deployed onchain happens in the L2BEAT repository.

## Methodology

- **Only what the report says.** An agent reads each report and records the repositories, paths and commits it audited, whether each path was audited in full or in part, and which major findings remain open. Nothing is inferred beyond the words of the report.
- **Exact revisions.** Audited code is fetched at the commit the report names. A report that names no commit contributes no source files.
- **Code the report does not list.** Audited files import other files, and reports rarely say whether those were reviewed. The dataset does not decide this. It records what the report says about unlisted code and third-party dependencies, follows the imports of the audited files, and labels each file it reaches: implied by the report, excluded by the report, or only visible to the audited code. The consumer chooses how strictly to read a report.
- **Independent checks.** A second agent can redo an extraction from scratch and compare the two results.

The full rules are in `skills/audit-extract/SKILL.md` and `skills/double-check-extraction/SKILL.md`.

## Repository layout

- `<project>/` and `_libs/<vendor>/`: one collection per project or library, with:
  - `reports/`: the audit reports and their Markdown conversions.
  - `audit-summary.json`: the extraction, and `audit-summary.md`, its readable rendering.
  - `audited-sources/`: the audited files and a manifest describing them.
- `collections.json`: display names of the collections, maintained by hand.
- `repositories.json`: every repository the dataset refers to, with fork lineage.
- `audit-index.json` and `audit-objects.json.zst`: the export, the dataset's public interface, described in [export.md](export.md).
- `foundry.toml`: the formatting configuration applied to every stored Solidity file.
- `audit_dataset/`: the pipeline code.
- `skills/`: instructions for the extraction agents.

## Pipeline

Requirements: Python 3.14, git, Foundry's `forge`, the authenticated GitHub CLI `gh`, and `pymupdf4llm` for PDF conversion (`python3 -m venv .venv && .venv/bin/pip3 install pymupdf4llm==1.28.2`, then run `pdf-to-md` with `.venv/bin/python3`).

1. Add the reports to `<collection>/reports` and convert PDFs with `python3 -m audit_dataset pdf-to-md <collection>`.
2. Run an agent with the `audit-extract` skill to write `audit-summary.json`.
3. Run `python3 -m audit_dataset pipeline <collection>`. It runs these steps, which can also be run one by one:
   - `render`: validates the summary and writes `audit-summary.md`.
   - `fetch`: downloads the audited files and the files they import.
   - `format`: formats the stored Solidity files with the shared configuration.
   - `index`: checks the stored files against the manifest.
   - `repositories`: rebuilds `repositories.json`.
   - `export`: regenerates the export from all collections.
4. Commit the collection together with the regenerated export.

`python3 -m audit_dataset --help` lists every command. `export --check` verifies that the committed export is up to date.

Only collections whose summary is on the latest schema are exported. `export` prints a warning for every collection that is left out or not fully up to date.

## Interaction with L2BEAT

L2BEAT reads only the export, pinned to a commit of this repository:

- `audit-index.json` lists the collections, the reports, and per repository and commit the audited files with their state in each report.
- `audit-objects.json.zst` holds the contents of those files.

The format of both files is described in [export.md](export.md).

L2BEAT formats deployed sources with the same `foundry.toml` and matches them against the stored files to decide which deployed code is covered by which report. A change to the export format carries a new schema version, and L2BEAT moves its pin once its reader supports it.
