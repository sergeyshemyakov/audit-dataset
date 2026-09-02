---
name: audit-extract
description: Extract a strict audit-summary.json from every Markdown audit report for one project, preserving exact repository paths, revisions, coverage, major findings, and remediation lineage.
---

# Audit Summary Extraction

Create `<project>/audit-summary.json` from the Markdown audit reports in `<project>/reports`. Its purpose is to identify exactly which repository file versions an audit covers so those sources can later be compared with production. The unit of coverage is `(repository, path, revision)`, not a protocol component described only in prose. Keep reports separate and keep successive versions of the same path in chronological order.

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
  report_file: string;
  title: string;
  auditor: string;
  report_date: string | null; // YYYY-MM-DD when known
  repositories: { id: string; url: string }[];
  scopes: {
    repository: string; // must match repositories[].id
    paths: Record<string, PathEntry>;
  }[];
};

type AuditSummary = {
  schema_version: "1.0.0";
  project: string;
  reports: Report[];
};
```

`major_findings` counts findings labeled **Major or Critical** (or equivalent) by the report. Do not count Medium/Moderate, Low, Informational, or optimization findings. A vulnerable version gets the count; a verified remediated version gets zero unless it has another Major/Critical finding.

Derive status mechanically: full coverage plus zero/nonzero `major_findings` gives `audited_with_no_major_findings`/`audited_with_major_findings`; limited coverage gives the corresponding `partially_audited_*` status. Use `not_audited` only when the report explicitly excludes or leaves that version unreviewed, and set its `major_findings` to `0` because no audit finding is established.

## Extraction rules

1. Read every `.md` audit report in the project's `reports` directory and create exactly one `reports[]` entry per report.
2. Extract each explicitly scoped repository and file path. Use `directory_recursive` only when the report scopes the directory or all files beneath it; never expand generic protocol prose into inferred files.
3. Record the most precise revision stated by the report. Expand abbreviated commit hashes when unambiguous. Never infer a historical commit from a report date or today's value of `master`. Preserve unresolved branches or tags with `commit: null`.
4. Add every report-mentioned initial version, modification, fix review, and re-audit to the affected path's `versions[]`. Later array entries must be descendants or otherwise clearly later, and `follows` must point to the preceding listed version. Do not add unrelated intermediate repository commits.
5. Use a full-audit status only when the whole file/directory was reviewed. Use a partial status for selected functions, properties, diffs, formal models, cryptographic aspects, or other limited coverage. Describe that boundary concisely in `coverage`.
6. Put a file explicitly excluded or explicitly left unaudited in `paths` with status `not_audited`; do not create a separate exclusion array. Always make sure to mention explicitly unaudited files. Do not mark unmentioned repository files as unaudited.
7. Resolve every pull-request reference through the repository host or Git refs. Unless the report identifies a specific PR commit, use the PR's final head/tip commit after all PR changes—not the merge commit—and store its full hash as a normal `kind: "commit"` version for each path to which the report associates the PR. Confirm that the PR changes that path. Use the merge commit only when the report explicitly covers the merged snapshot. Insert the resolved commit at the correct point in each version chain. Retain `kind: "pull_request"` with `commit: null` only when the PR cannot be resolved; never create a separate PR/change collection.

## Do not extract

- Finding titles, descriptions, recommendations, proofs of concept, or per-finding details.
- Counts or details for findings below Major/Critical severity.
- Report evidence, line citations, version notes, relationship prose inside versions, scope notes, or scope-precision fields.
- Team biographies, methodology boilerplate, person-days, disclaimers, severity explanations, or general protocol descriptions.
- Files merely referenced as dependencies, examples, or context unless the report explicitly audits them.
- Deployment addresses, production bytecode, or guesses about which audited version is deployed.

Validate JSON syntax, allowed fields/statuses, integer `major_findings`, one entry per Markdown report, full-length commit hashes where known, and chronological version ancestry.

# After writing the final audit-summary.json

1. Generate user-readable overview of the audited files using `generate_audit_summary.py` script: `python3 generate_audit_summary.py <project>/audit-summary.json`. It is intended to be used by a researcher to verify that all sources mentioned in the audit report were extracted correctly.
2. Fetch audited sources: `python3 fetch_audited_sources.py <project>/audit-summary.json`. Do not pass on any `--circuit-path` or `--program-path`, leave it to the reesarchers.