---
name: audit-extract
description: Classify project audit reports for L2BEAT relevance and extract a strict audit-summary.json for relevant reports, preserving exact repository paths, revisions, statuses and the identifiers of open major findings.
---

# Audit Summary Extraction

Create `<collection>/audit-summary.json` from every Markdown audit report found recursively under `<collection>/reports`, including reports already in `<collection>/reports/irrelevant`. First describe and classify every report. Extract source coverage only from relevant reports so that later comparisons with production do not use irrelevant audit evidence.

A relevant audit covers onchain protocol logic or the project's zk circuits or prover sources. An audit is irrelevant only when its entire scope is limited to one or more of the following:

- Private repositories that cannot be accessed without specific permissions.
- Offchain logic, including frontends, UIs, wallets, and node software.
- One-time executable code such as migration logic.
- External cryptographic dependencies. Audits of the project's own zk circuits remain relevant.

If a report has any relevant scope, classify the report as relevant. If relevance is uncertain, classify it as relevant.

For relevant reports, the unit of coverage is `(repository, path, revision)`, not a protocol component described only in prose. Keep reports separate and keep successive versions of the same path in chronological order.

## Fixed schema

Do not add fields not defined below; the validator rejects unknown keys. Explanations of ordering, revisions, statuses, and finding semantics belong in this skill, not in `audit-summary.json`.

However if you feel that the structure or content of some audit reports could not be correctly described with this fixed schema, raise an alarm to the user. It is possible that the schema must be modified / tailored for some audit reports.

```ts
type Status =
  | "audited_with_no_major_findings"
  | "audited_with_major_findings"
  | "not_audited"
  | "partially_audited_without_major_findings"
  | "partially_audited_with_major_findings";

type Timestamp = string; // committer date of the commit, ISO 8601 UTC, e.g. "2023-05-12T14:03:22Z"

type Revision =
  | { kind: "commit"; commit: string; timestamp: Timestamp | null; url: string }
  | { kind: "tag"; tag: string; commit: string | null; timestamp: Timestamp | null; url: string }
  | {
      kind: "commit_range";
      start_commit: string;
      start_timestamp: Timestamp | null;
      end_commit: string;
      end_timestamp: Timestamp | null;
      url?: string;
    }
  | { kind: "pull_request"; value: string; commit: string | null; timestamp: Timestamp | null; url: string }
  | { kind: "branch"; ref: string; commit: null; timestamp: null; immutable: false; url: string };

type Version = {
  revision: Revision;
  status: Status;
  major_finding_ids?: string[]; // required iff status is *_with_major_findings, see "Major finding identifiers"
};

type PathEntry = {
  path_kind: "file" | "directory_recursive";
  versions: Version[]; // earlier to later
};

type Report = {
  id: string;
  report_file: string; // POSIX path of the Markdown report relative to <collection>/reports
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
  schema_version: "1.5.0";
  project: string;
  reports: Report[];
};
```

Repository ids are canonical and derived from the repository URL: GitHub repositories are `owner/repo` exactly as GitHub spells them (no `.git` suffix), GitHub gists are `gist/<owner>/<id>`, other hosts are `<host>/<path>`. Run `python3 -m audit_dataset repository-id <url>` to print the id for a URL. Every `scopes[].repository` must equal one of the report's `repositories[].id`. Do not record repository lineage (forks) in the summary; the `repositories` command derives it into the root `repositories.json`.

For a project that forks another codebase (for example an OP stack fork), scope only what the report scopes. Never expand a fork's audit to upstream files: the consumer resolves upstream coverage through the repository registry.

Every report must have `description` and `isRelevant`. An irrelevant report must have `scopes: []`; do not extract its repository paths, revisions, or findings. `repositories` may contain repositories that are directly identified while classifying the report, including an inaccessible private repository, but do not investigate the report further merely to populate that array.

## Major finding identifiers

A version has major findings when the report leaves findings labeled **Major or Critical** (or equivalent, such as High/Critical) open in that revision of that path. Do not count Medium/Moderate, Low, Informational, or optimization findings. A vulnerable version has them; a verified remediated version has none unless it has another open Major/Critical finding. Attribute per path: a finding belongs to a path only when the report locates it in that file or directory (through its location/target field, code references, or description). Never copy a report-wide finding list onto every scoped path, and do not attribute a finding to test files, interfaces, or sibling contracts that the report does not name for it.

Every version with major findings has status `audited_with_major_findings` or `partially_audited_with_major_findings` and carries `major_finding_ids`: the identifiers of exactly those Major/Critical findings that are open in that revision of that path. Downstream consumers use them to name a specific finding when the vulnerable revision turns out to be deployed onchain. The array is omitted entirely (never empty) for every other status.

Write each identifier exactly as the report prints it, so that searching the report for the string locates the finding:

1. If the report assigns explicit identifiers (`H-01`, `C01`, `TOB-SCROLL-13`, `CLAB-21`, `V-KLA-VUL-006`, `CVF-7`, `#00`, `GLOBAL-01`, an Immunefi submission number such as `37251`), copy the identifier verbatim. Drop only surrounding markdown, brackets (`[H01]` becomes `H01`), and trailing punctuation.
2. If findings have no explicit identifier but are numbered through their headings or the summary table (for example `### 3.1.1 Missing access control` or `## 7. [High] ...`), use that number (`3.1.1`, `7`).
3. If the report gives findings neither an identifier nor a number, or numbering restarts per section so that numbers are not unique within the report, use the finding title verbatim as printed in its heading.
4. A finding that remains open across several versions of a path (for example a High carried into a fix-review revision, or one marked only "partially resolved") repeats its identifier in every version where it is still open and disappears from the version that remediates it. A finding that the report locates in several paths is listed under every one of those paths.

Order identifiers as they appear in the report. `major_finding_ids` holds identifiers only: no titles (unless the title is the identifier), severities, statuses, or descriptions.

Derive status mechanically: full coverage of the file or directory gives `audited_with_no_major_findings` or `audited_with_major_findings`; limited coverage (selected functions, properties, diffs, formal models, cryptographic aspects, or other partial review) gives the corresponding `partially_audited_*` status. Use `not_audited` only when the report explicitly excludes or leaves that version unreviewed; a `not_audited` version never carries `major_finding_ids`.

## Extraction rules

1. Discover every `.md` audit report recursively under the collection's `reports` directory, including `reports/irrelevant`. Read enough of every report to describe its audit scope and purpose in no more than two sentences and decide `isRelevant`. Do not extract paths, revisions, or findings until this decision is made.
2. For each irrelevant report, create one `reports[]` entry with its identifying metadata, `description`, `isRelevant: false`, and `scopes: []`. Do not perform the detailed extraction rules below for it.
3. For each relevant report, set `isRelevant: true` and extract each explicitly scoped repository and file path. Use `directory_recursive` only when the report scopes the directory or all files beneath it; never expand generic protocol prose into inferred files. Write every path relative to the repository root with `/` separators and no leading or trailing `/` (`contracts`, not `contracts/`), spelled exactly as the repository spells it at that revision, including letter case: `contracts/L1/Foo.sol` and `contracts/l1/Foo.sol` are different paths.
4. Record the most precise revision stated by the report. Expand abbreviated commit hashes when unambiguous. Never infer a historical commit from a report date or today's value of `master`. Preserve unresolved branches or tags with `commit: null`.
5. Give every revision the committer timestamp of its commit, fetched from GitHub (never from the report text, the report date, or a guess). Use the authenticated GitHub CLI: `gh api repos/<owner>/<repo>/commits/<commit> --jq .commit.committer.date` for a repository commit, or `gh api gists/<gist_id>/commits --jq '.[] | select(.version == "<commit>") | .committed_at'` for a gist revision. Store the returned value verbatim as `timestamp` (or `start_timestamp`/`end_timestamp` for a `commit_range`). Set the timestamp to `null` whenever `commit` is `null` or GitHub no longer serves the commit; do not substitute another commit's date. If possible, write a script that fetches all timestamps for `audit-summary.json` instead of fetching it for each individual revision.
6. Add every report-mentioned initial version, modification, fix review, and re-audit to the affected path's `versions[]`, earlier to later. Do not add unrelated intermediate repository commits.
7. Use a full-audit status only when the whole file/directory was reviewed. Use a partial status for selected functions, properties, diffs, formal models, cryptographic aspects, or other limited coverage.
8. Put a file explicitly excluded or explicitly left unaudited in `paths` with status `not_audited`; do not create a separate exclusion array. Always make sure to mention explicitly unaudited files. Do not mark unmentioned repository files as unaudited.
9. Resolve every pull-request reference through the repository host or Git refs. Unless the report identifies a specific PR commit, use the PR's final head/tip commit after all PR changes, not the merge commit, and store its full hash as a normal `kind: "commit"` version for each path to which the report associates the PR. Confirm that the PR changes that path. Use the merge commit only when the report explicitly covers the merged snapshot. Insert the resolved commit at the correct point in each version chain. Retain `kind: "pull_request"` with `commit: null` only when the PR cannot be resolved; never create a separate PR/change collection.
10. Create `<collection>/reports/irrelevant` if necessary. Move each newly classified irrelevant Markdown report and its corresponding raw report file, such as a same-stem PDF or HTML file, into that directory. Do not move an already nested report again, overwrite an existing file, or move a file whose association with the report is uncertain.
11. After all moves, store `report_file` relative to `<collection>/reports` using `/` separators: for example, `Relevant.md` or `irrelevant/Wallet Audit.md`. Create exactly one `reports[]` entry for every recursively discovered Markdown report, whether it was already irrelevant or was moved during this run.

## Do not extract

- Finding titles, descriptions, recommendations, proofs of concept, or per-finding details, beyond the identifiers required in `major_finding_ids`.
- Counts or details for findings below Major/Critical severity, or counts of any findings.
- Coverage prose, review phases, finding severities, remediation lineage between versions, report evidence, line citations, version notes, scope notes, or scope-precision fields.
- Team biographies, methodology boilerplate, person-days, disclaimers, severity explanations, or general protocol descriptions.
- Files merely referenced as dependencies, examples, or context unless the report explicitly audits them.
- Deployment addresses, production bytecode, or guesses about which audited version is deployed.

`python3 -m audit_dataset render <collection>` validates the summary and fails on: unknown keys, non-canonical repository ids, scopes naming unknown repositories, malformed paths, unknown statuses or path kinds, `major_finding_ids` missing for a `*_with_major_findings` status or present for any other, missing or malformed `description`, `isRelevant`, `report_date` or `report_file`, non-empty scopes on an irrelevant report, timestamps that are not ISO 8601 UTC whole seconds, and two versions disagreeing on one commit's timestamp. Confirm before running it: full-length commit hashes where known, timestamps that are `null` only when the commit is `null` or unavailable on GitHub, and chronological version order.

# After writing the final audit-summary.json

Run `python3 -m audit_dataset pipeline <collection>`. It executes, in order:

1. `render`: validates the schema and the canonical repository ids and renders `audit-summary.md`. Confirm that every report has a description, only relevant reports have source tables, irrelevant reports appear at the bottom, the commit dates are populated, and all report links resolve after the moves.
2. `fetch`: fetches every pinned, audited source of relevant reports into `<collection>/audited-sources`.
3. `format`: formats the fetched Solidity files with the shared forge fmt config.
4. `index`: verifies the stored files against `manifest.json` and records their post-format hashes.
5. `repositories`: refreshes the root `repositories.json` registry (requires the authenticated GitHub CLI; pass `--no-lookup` to skip the GitHub lineage lookups).
6. `export`: regenerates `audit-index.json` and `audit-objects.json.zst` from every collection. It fails on any summary that breaks the rules above; fix the summary rather than the export. Commit both files together with the summary.
