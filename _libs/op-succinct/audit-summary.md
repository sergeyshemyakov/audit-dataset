# Audit source summary: _libs/op-succinct

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## OP Succinct Security Review

- Report: [Spearbit - OP Succinct.md](<reports/Spearbit - OP Succinct.md>)
- Auditor: Cantina
- Date: 2024-12-20
- Description: Cantina Managed review (Dec 3-8, 2024) of op-succinct at commit b73cc7d0, covering the OPSuccinctL2OutputOracle contract that verifies SP1 proofs of the OP Stack state transition onchain and the aggregation program that verifies the range proofs. No Critical, High or Medium issues; one Low and five Informational findings, with the reinitializer fix verified in PR 265.

### Repository: <a href="https://github.com/succinctlabs/op-succinct"><code>succinctlabs/op-succinct</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/succinctlabs/op-succinct/commit/b73cc7d008fc0a39d41b9ce384dff2d85b6eaa3e"><code>b73cc7d008fc0a39d41b9ce384dff2d85b6eaa3e</code></a> | December 2, 2024 | <code>contracts/src/OPSuccinctL2OutputOracle.sol</code><br><code>programs/aggregation</code> (recursive directory) (zk)<br><code>programs/range/src/main.rs</code> (zk) |
| <a href="https://github.com/succinctlabs/op-succinct/commit/228610944399607fbe4fe6ffeced425f9feddf6f"><code>228610944399607fbe4fe6ffeced425f9feddf6f</code></a> | December 9, 2024 | <code>contracts/src/OPSuccinctL2OutputOracle.sol</code> |

## OP Succinct Lite Security Review

- Report: [Spearbit - OP Succinct Lite.md](<reports/Spearbit - OP Succinct Lite.md>)
- Auditor: Cantina
- Date: 2025-03-08
- Description: Cantina Managed review (Feb 28 - Mar 2, 2025) of op-succinct at commit 99a540bc, covering the OP Succinct Lite fault-proof dispute game contract OPSuccinctFaultDisputeGame. No Critical or High issues; one Medium (prove front-running) and one Low finding were fixed in PRs 421 and 420 and the fixes verified.

### Repository: <a href="https://github.com/succinctlabs/op-succinct"><code>succinctlabs/op-succinct</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/succinctlabs/op-succinct/commit/99a540bcf7997902b34e2e85bc5d37012307c408"><code>99a540bcf7997902b34e2e85bc5d37012307c408</code></a> | February 27, 2025 | <code>contracts/src/fp/OPSuccinctFaultDisputeGame.sol</code> |
| <a href="https://github.com/succinctlabs/op-succinct/commit/4c682da4ad5f0d1d4f5fa2319aab15b507e87e82"><code>4c682da4ad5f0d1d4f5fa2319aab15b507e87e82</code></a> | March 5, 2025 | <code>contracts/src/fp/OPSuccinctFaultDisputeGame.sol</code> |
| <a href="https://github.com/succinctlabs/op-succinct/commit/56c1f28027d81a36d225786e5e08bfb7080627e4"><code>56c1f28027d81a36d225786e5e08bfb7080627e4</code></a> | March 11, 2025 | <code>contracts/src/fp/OPSuccinctFaultDisputeGame.sol</code> |

## OP Succinct Smart Contract Security Assessment

- Report: [Zellic - OP Succinct v3.0.0.md](<reports/Zellic - OP Succinct v3.0.0.md>)
- Auditor: Zellic
- Date: 2025-07-30
- Description: Zellic diff review (Jul 16-17, 2025) of the op-succinct validity contracts OPSuccinctDisputeGame, OPSuccinctL2OutputOracle and fp/AccessManager, limited to the changes between commits 46482d3f and 530df863 that introduced multi-configuration support and the permissionless proposer fallback. Two Medium findings were reported, with fixes implemented in PR 575. The diff-reviewed files are pinned to the end commit 530df863 of the reviewed range, which is the state the diff audit covered.

### Repository: <a href="https://github.com/succinctlabs/op-succinct"><code>succinctlabs/op-succinct</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/succinctlabs/op-succinct/blob/530df8630562292a9629303528d51307df954aec/contracts/src/validity/OPSuccinctDisputeGame.sol"><code>530df8630562292a9629303528d51307df954aec</code></a> | July 10, 2025 | <code>contracts/src/validity/OPSuccinctDisputeGame.sol</code><br><code>contracts/src/validity/OPSuccinctL2OutputOracle.sol</code><br><code>contracts/src/fp/AccessManager.sol</code> |
| <a href="https://github.com/succinctlabs/op-succinct/commit/4aacb882ce86204bdcb7c70b40f3f9ed38d37b8b"><code>4aacb882ce86204bdcb7c70b40f3f9ed38d37b8b</code></a> | August 6, 2025 | <code>contracts/src/validity/OPSuccinctDisputeGame.sol</code><br><code>contracts/src/validity/OPSuccinctL2OutputOracle.sol</code> |

## AltDA OP Succinct Integration Zero Knowledge Application Security Assessment

- Report: [Zellic - OP Succinct AltDA.md](<reports/Zellic - OP Succinct AltDA.md>)
- Auditor: Zellic
- Date: 2026-09-28
- Description: Zellic assessment (Sep 18-23, 2026) of the generic AltDA integration of op-succinct at commit 78129507: the AltDA client and host crates, the AltDA range program and range utilities, and the shared client crate files (boot, witness executor and preimage store, client driver, blob provider) that bind off-chain batch data to Keccak commitments on L1 inside the SP1 zkVM. No Critical or High issues; two Medium findings were fixed in follow-up commits and one Low was acknowledged.

### Repository: <a href="https://github.com/succinctlabs/op-succinct"><code>succinctlabs/op-succinct</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/succinctlabs/op-succinct/commit/78129507cb0a46a1983606d403eb5b487d8369f9"><code>78129507cb0a46a1983606d403eb5b487d8369f9</code></a> | September 12, 2026 | <code>utils/altda</code> (recursive directory) (zk)<br><code>programs/range/altda</code> (recursive directory) (zk)<br><code>programs/range/utils</code> (recursive directory) (zk)<br><code>utils/client/src/boot.rs</code> (zk)<br><code>utils/client/src/witness/executor.rs</code> (zk)<br><code>utils/client/src/witness/mod.rs</code> (zk)<br><code>utils/client/src/witness/preimage_store.rs</code> (zk)<br><code>utils/client/src/client.rs</code> (zk)<br><code>utils/client/src/oracle/blob_provider.rs</code> (zk) |
| <a href="https://github.com/succinctlabs/op-succinct/commit/3a1076744a273884c6b009c34e3a9dc2981d9597"><code>3a1076744a273884c6b009c34e3a9dc2981d9597</code></a> | October 1, 2026 | <code>utils/altda</code> (recursive directory) (zk) |
| <a href="https://github.com/succinctlabs/op-succinct/commit/1d2e418cbe199d42c219cec94bbf349be28bc721"><code>1d2e418cbe199d42c219cec94bbf349be28bc721</code></a> | October 1, 2026 | <code>utils/altda</code> (recursive directory) (zk) |
| <a href="https://github.com/succinctlabs/op-succinct/commit/81f09688bc1271aac86ab6fdaffbe972cf624af5"><code>81f09688bc1271aac86ab6fdaffbe972cf624af5</code></a> | October 2, 2026 | <code>utils/client/src/witness/executor.rs</code> (zk)<br><code>utils/client/src/client.rs</code> (zk) |
| <a href="https://github.com/succinctlabs/op-succinct/commit/58649923efd952bcd5c84cc17d4a81580cb93a6b"><code>58649923efd952bcd5c84cc17d4a81580cb93a6b</code></a> | October 2, 2026 | <code>utils/client/src/witness/executor.rs</code> (zk)<br><code>utils/client/src/client.rs</code> (zk) |
