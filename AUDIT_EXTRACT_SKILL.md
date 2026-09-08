---
name: audit-extract
description: Classify project audit reports for L2BEAT relevance and extract a strict audit-summary.json for relevant reports, preserving exact repository paths, revisions, coverage, major findings, and remediation lineage.
---

# Audit Summary Extraction

Create `<project>/audit-summary.json` from every Markdown audit report found recursively under `<project>/reports`, including reports already in `<project>/reports/irrelevant`. First describe and classify every report. Extract source coverage only from relevant reports so that later comparisons with production do not use irrelevant audit evidence.

A relevant audit covers onchain protocol logic or the project's zk circuits or prover sources. An audit is irrelevant only when its entire scope is limited to one or more of the following:

- Private repositories that cannot be accessed without specific permissions.
- Offchain logic, including frontends, UIs, wallets, and node software.
- One-time executable code such as migration logic.
- External cryptographic dependencies. Audits of the project's own zk circuits remain relevant.

If a report has any relevant scope, classify the report as relevant. If relevance is uncertain, classify it as relevant.

For relevant reports, the unit of coverage is `(repository, path, revision)`, not a protocol component described only in prose. Keep reports separate and keep successive versions of the same path in chronological order.

## Fixed schema

Do not add fields not defined below. Explanations of ordering, revisions, statuses, and finding semantics belong in this skill, not in `audit-summary.json`.

However if you feel that the structure or content of some audit reports could not be correctly described with this fixed schema, raise an alarm to the user. It is possible that the schema must be modified / tailored for some audit reports.

```ts
type Status =
  | "audited_with_no_major_findings"
  | "audited_with_major_findings"
  | "not_audited"
  | "partially_audited_without_major_findings"
  | "partially_audited_with_major_findings";

type Revision =
  | { kind: "commit"; commit: string; url: string }
  | { kind: "tag"; tag: string; commit: string | null; url: string }
  | { kind: "commit_range"; start_commit: string; end_commit: string; url?: string }
  | { kind: "pull_request"; value: string; commit: string | null; url: string }
  | { kind: "branch"; ref: string; commit: null; immutable: false; url: string };

type Version = {
  revision: Revision;
  status: Status;
  review_phase: string;
  coverage: string;
  follows?: string; // identifier of the preceding listed revision
  major_findings: number; // non-negative integer
  highest_reported_finding_severity?: string;
};

type PathEntry = {
  path_kind: "file" | "directory_recursive";
  versions: Version[]; // earlier to later
};

type Report = {
  id: string;
  report_file: string; // POSIX path relative to <project>/reports
  title: string;
  description: string; // audit scope and purpose in no more than 2 sentences
  isRelevant: boolean;
  auditor: string;
  report_date: string | null; // YYYY-MM-DD when known
  repositories: { id: string; url: string }[];
  scopes: {
    repository: string; // must match repositories[].id
    paths: Record<string, PathEntry>;
  }[];
};

type AuditSummary = {
  schema_version: "1.1.0";
  project: string;
  reports: Report[];
};
```

Every report must have `description` and `isRelevant`. An irrelevant report must have `scopes: []`; do not extract its repository paths, revisions, coverage, or findings. `repositories` may contain repositories that are directly identified while classifying the report, including an inaccessible private repository, but do not investigate the report further merely to populate that array.

`major_findings` counts findings labeled **Major or Critical** (or equivalent) by the report. Do not count Medium/Moderate, Low, Informational, or optimization findings. A vulnerable version gets the count; a verified remediated version gets zero unless it has another Major/Critical finding.

Derive status mechanically: full coverage plus zero/nonzero `major_findings` gives `audited_with_no_major_findings`/`audited_with_major_findings`; limited coverage gives the corresponding `partially_audited_*` status. Use `not_audited` only when the report explicitly excludes or leaves that version unreviewed, and set its `major_findings` to `0` because no audit finding is established.

## Extraction rules

1. Discover every `.md` audit report recursively under the project's `reports` directory, including `reports/irrelevant`. Read enough of every report to describe its audit scope and purpose in no more than two sentences and decide `isRelevant`. Do not extract paths, revisions, coverage, or findings until this decision is made.
2. For each irrelevant report, create one `reports[]` entry with its identifying metadata, `description`, `isRelevant: false`, and `scopes: []`. Do not perform the detailed extraction rules below for it.
3. For each relevant report, set `isRelevant: true` and extract each explicitly scoped repository and file path. Use `directory_recursive` only when the report scopes the directory or all files beneath it; never expand generic protocol prose into inferred files.
4. Record the most precise revision stated by the report. Expand abbreviated commit hashes when unambiguous. Never infer a historical commit from a report date or today's value of `master`. Preserve unresolved branches or tags with `commit: null`.
5. Add every report-mentioned initial version, modification, fix review, and re-audit to the affected path's `versions[]`. Later array entries must be descendants or otherwise clearly later, and `follows` must point to the preceding listed version. Do not add unrelated intermediate repository commits.
6. Use a full-audit status only when the whole file/directory was reviewed. Use a partial status for selected functions, properties, diffs, formal models, cryptographic aspects, or other limited coverage. Describe that boundary concisely in `coverage`.
7. Put a file explicitly excluded or explicitly left unaudited in `paths` with status `not_audited`; do not create a separate exclusion array. Always make sure to mention explicitly unaudited files. Do not mark unmentioned repository files as unaudited.
8. Resolve every pull-request reference through the repository host or Git refs. Unless the report identifies a specific PR commit, use the PR's final head/tip commit after all PR changes—not the merge commit—and store its full hash as a normal `kind: "commit"` version for each path to which the report associates the PR. Confirm that the PR changes that path. Use the merge commit only when the report explicitly covers the merged snapshot. Insert the resolved commit at the correct point in each version chain. Retain `kind: "pull_request"` with `commit: null` only when the PR cannot be resolved; never create a separate PR/change collection.
9. Create `<project>/reports/irrelevant` if necessary. Move each newly classified irrelevant Markdown report and its corresponding raw report file, such as a same-stem PDF or HTML file, into that directory. Do not move an already nested report again, overwrite an existing file, or move a file whose association with the report is uncertain.
10. After all moves, store `report_file` relative to `<project>/reports` using `/` separators: for example, `Relevant.md` or `irrelevant/Wallet Audit.md`. Create exactly one `reports[]` entry for every recursively discovered Markdown report, whether it was already irrelevant or was moved during this run.

## Do not extract

- Finding titles, descriptions, recommendations, proofs of concept, or per-finding details.
- Counts or details for findings below Major/Critical severity.
- Report evidence, line citations, version notes, relationship prose inside versions, scope notes, or scope-precision fields.
- Team biographies, methodology boilerplate, person-days, disclaimers, severity explanations, or general protocol descriptions.
- Files merely referenced as dependencies, examples, or context unless the report explicitly audits them.
- Deployment addresses, production bytecode, or guesses about which audited version is deployed.

Validate JSON syntax, allowed fields/statuses, non-empty descriptions of at most two sentences, boolean `isRelevant`, empty scopes for every irrelevant report, integer `major_findings`, one entry per recursively discovered Markdown report, report paths that match their final locations, full-length commit hashes where known, and chronological version ancestry.

# After writing the final audit-summary.json

1. Generate a user-readable overview using `python3 generate_audit_summary.py <project>/audit-summary.json`. Confirm that every report has a description, only relevant reports have source tables, irrelevant reports appear at the bottom, and all report links resolve after the moves.
2. Fetch audited sources with `python3 fetch_audited_sources.py <project>/audit-summary.json`. The script ignores irrelevant reports. Do not pass `--circuit-path` or `--program-path`; leave those options to the researchers.
3. Format all fetched .sol sources with `python3 format_sources.py <project>`.