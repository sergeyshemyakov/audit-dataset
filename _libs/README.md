# Standard Solidity libraries: audit collection

This directory collects public audit evidence for reusable Solidity components. Research and downloads were completed on **2026-09-08**. No audit-summary extraction, audited-source fetching, source matching, or coverage classification has been run.

Start with [CATALOG.md](CATALOG.md) for the library/component shortlist, [INVENTORY.md](INVENTORY.md) for observed reuse, and [REPORTS.md](REPORTS.md) for every downloaded report and its original source.

Collected **91 audit/security documents: 81 PDFs, six HTML reports, and four native Markdown reports**, plus 15 publisher index/scope-note snapshots (about 86 MB of originals). All original-file hashes and Git blob IDs were checked, and all 81 PDFs opened with extractable text. Eight PDFs are draft-labelled. See [verification.json](verification.json) for the results.

| Code vendor / family | Report documents |
| --- | ---: |
| [OpenZeppelin](openzeppelin/reports) | 16 |
| [Gnosis / Safe / Zodiac](safe/reports) | 41 |
| [Solady](solady/reports) | 5 |
| [Solmate](solmate/reports) | 1 |
| [Uniswap](uniswap/reports) | 16 |
| [Compound](compound/reports) | 3 |
| [eth-infinitism](eth-infinitism/reports) | 5 |
| [PRBMath](prb-math/reports) | 2 |
| [Chiru Labs / ERC721A](chiru-labs/reports) | 2 |

Reports are grouped by **the vendor of the code**, not the auditor: for example, OpenZeppelin's audit of Compound belongs under `compound/`. `safe/` includes Gnosis Safe, the renamed Safe project, and Gnosis Guild's Zodiac infrastructure. The directory is named `safe` rather than `gnosis` because L2BEAT uses `gnosis` for Gnosis Chain.

```text
_libs/
  <vendor>/
    reports/       Original PDF, Markdown, and HTML reports
    provenance/    Selected original publisher audit indexes and scope notes
  CATALOG.md       Components, report families, and coverage limitations
  INVENTORY.md     Observed declaration counts
  inventory.json  Counts, projects, example source paths and line numbers
  REPORTS.md       Clickable report/source index
  manifest.json   Download URLs, pinned revisions, sizes, hashes, evidence kinds
  verification.json  Acquisition checks and PDF readability results
```

The collection includes conventional audits, audit competitions, formal verification, one mathematical proof, and a bug-disclosure article. These are distinguished in the manifest and report index. Initial/final editions and reports covering the same engagement are retained; document counts are not independent-audit counts. Drafts are explicitly labelled, including cases where the PDF cover says “Draft” but its filename does not.

For the pipeline, `_libs/<vendor>` is an ordinary collection: the same layout and scripts as a project directory. The grouping is organizational only; consumers decide how library evidence is ranked. PDFs and the four originally published Markdown reports are under `reports/`. Native HTML reports need conversion to Markdown before the existing extraction step; they have been preserved as HTML rather than presented as extracted audit data. `provenance/` files are supporting indexes, not reports; their original relative links resolve in the upstream repository shown in the manifest.

## Using this evidence for coverage

Match the deployed implementation to a **scoped source file at its audited revision**, including any reviewed fixes. A package name, an interface name, a version comment, inheritance, or the existence of an audit is insufficient. Record unmodified reused code separately from project-specific modifications and integration logic.

Release-diff audits cover the stated changes; they do not independently establish coverage for every file in the release. Upgradeable and non-upgradeable contracts need separate source matching. Formal-verification reports establish specific properties under stated assumptions. Interface matches can be tracked as source provenance, but should not imply that an implementation or a caller was audited.

`report_repository_commit` in the manifest pins **the downloaded report/index**, not the Solidity revision assessed by the auditor. The latter belongs in your subsequent extraction output. `publication_status` describes a publisher label, not remediation or safety. Historical audited code may still contain known findings; retain those distinctions in the eventual coverage metric.

## Collection boundaries and known gaps

The collection covers the report files found in the selected vendors' canonical audit directories, plus original auditor publications and explicitly scoped integration reports. It is a broad public-source collection, not a claim that every downstream project audit mentioning these libraries has been found. Private/unpublished reports and future releases are outside it.

The OpenZeppelin regular and upgradeable repositories contain identical copies of the 17 audit/index/formal-verification artifacts checked; one copy is retained. This deduplication does not establish equivalent audit scope for upgradeable Solidity code. Several Uniswap reports overlap the existing `uniswapv3` dataset project and should be deduplicated by engagement/revision when aggregating coverage.

The historical Nomic Labs **ZeppelinOS Smart Contracts Audit IV** is linked by [OpenZeppelin's forum](https://forum.openzeppelin.com/t/openzeppelin-usage-in-audited-well-known-projects/2556), but both its [original publisher URL](https://medium.com/nomic-labs-blog/zeppelinos-smart-contracts-audit-iv-a52987973b88) and renamed Nomic Foundation URL returned HTTP 403. The earlier [ZeppelinOS audit](https://medium.com/nomic-foundation-blog/zeppelinos-smart-contracts-audit-dc772cfae224) was also unavailable through browsing. These are recorded gaps, not downloaded reports or coverage evidence. No separate dedicated v3.x/v4.0–v4.6 full-library OpenZeppelin audit was located in the canonical collection; later reports must not be used to assume that coverage.

Other observed or plausible candidates needing separate scope research include legacy `WETH9`, Dappsys (`DSAuth`, `DSMath`, `DSProxy`, `DSToken`), ABDK math, `Multicall3`, RLP/bytes/memory-view utilities, and diamond implementations. They are listed in the catalog without assigning audited status. Existing bridge/rollup/protocol audits may explicitly cover some of these copies; familiar names alone do not identify their vendor.

All reports retain their publishers' original content and notices. The manifest records acquisition provenance; it does not grant a new redistribution license.
