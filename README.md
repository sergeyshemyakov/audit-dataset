Some demo dashboards:

- https://claude.ai/code/artifact/10a4a235-29f8-4660-8e96-88c341a7319d
- https://claude.ai/code/artifact/f930bd58-7c59-4f4d-ae6c-2104ca698ee1

# Audit dataset tools

- `python3 -m venv .venv` and `.venv/bin/pip3 install pymupdf4llm==1.28.2`: set up the local virtual environment and install the PDF extraction dependency.
- `.venv/bin/python3 pdf_to_md.py`: extract every PDF under the project directories to Markdown.
- `python3 fetch_deployed.py <project-name>`: write `<project-name>/deployed.json` and replace `<project-name>/deployed-contracts` with flattened sources for every contract in the project's L2BEAT discovery output. The L2BEAT checkout defaults to `~/Documents/l2beat`; override it with `--l2beat-root PATH`. The dataset root defaults to the directory containing the script; override it with `--dataset-root PATH`.
- Run an agent on `AUDIT_EXTRACT_SKILL.md` for a project to classify all Markdown reports found recursively under `<project>/reports` and extract `<project>/audit-summary.json`. Irrelevant reports are moved to `<project>/reports/irrelevant`, retained in the summary with a short description, and excluded from detailed source extraction.
- `python3 generate_audit_summary.py <project>/audit-summary.json`: deterministically generate the human-readable `<project>/audit-summary.md`, resolving commit dates from the source Git repositories. It renders source tables only for relevant reports and lists irrelevant reports with descriptions at the bottom. Human review of `audit-summary.md` is recommended to confirm that all relevant report sources were parsed correctly.
- `python3 fetch_audited_sources.py <project>/audit-summary.json`: fetch every source path from relevant reports that is pinned to a full Git commit into `<project>/audited-sources`. Mutable revisions such as branches and abbreviated commits are recorded as skipped in `manifest.json`. Relative symlinks that stay within the repository are resolved from that same pinned commit and copied as regular files. Dangling repository-internal links are omitted and recorded; unsafe links are rejected.
- `python3 format_sources.py <project>` or `python3 format_sources.py --all`: reformat every Solidity file under `<project>/deployed-contracts` and `<project>/audited-sources` in place with one shared `forge fmt` config, so that deployed-vs-audited diffs show code changes instead of style differences. Requires Foundry. 

## Deployed program and circuit sources

`fetch_deployed.py` can also fetch source files for zk circuits or other programs compiled into an onchain deployment. Pass one or more GitHub URLs with `--program-path` (or its `--circuit-path` alias). A URL must use GitHub's `/tree/<revision>/<path>` form for a directory or `/blob/<revision>/<path>` form for one file. The revision may be a commit, tag, or branch; the script fetches it as supplied.

For example:

```sh
python3 fetch_deployed.py tornado-cash \
  --program-path \
  https://github.com/tornadocash/tornado-core/tree/v2.1/circuits \
  https://github.com/example/project/blob/v1.0/program/main.nr
```

The option may also be repeated. Directory URLs are copied recursively. Program files are stored alongside contract sources under `deployed-contracts/github/<owner>/<repository>/<revision>/...`. Each input and its resolved commit and copied files are recorded in the `programSources` array in `deployed.json`.

If a branch name contains `/`, percent-encode the slash in the URL (for example, `feature%2Fnew-circuit`) so the script can distinguish the revision from the repository path.
