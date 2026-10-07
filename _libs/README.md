# Widely reused code: audit collections

Each `_libs/<vendor>/` directory is an ordinary collection with the same layout and commands as a project collection (see the root README). The grouping is organizational only: these are audits of reusable components (OpenZeppelin, Safe and Zodiac, Solady, Solmate, eth-infinitism's account abstraction, Succinct's SP1) that many projects deploy unchanged, so the consumer ranks their evidence differently from a project's own audits.

Reports are grouped by the vendor of the audited code, not by the auditor. `safe/` includes Gnosis Safe, the renamed Safe project, and Gnosis Guild's Zodiac infrastructure; it is named `safe` rather than `gnosis` because L2BEAT uses `gnosis` for Gnosis Chain.

A match against library evidence means the deployed implementation equals a scoped source file at its audited revision, including any reviewed fixes. A package name, an interface name, a version comment, inheritance, or the existence of an audit is not coverage. Release-diff audits cover the stated changes only, and formal-verification reports establish specific properties under stated assumptions.
