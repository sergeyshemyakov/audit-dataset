# Audit source summary: agglayer

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Security Review Report for Polygon zkEVM

- Report: [2023_02-hexens-polygon-zkevm-security-review.md](<reports/2023_02-hexens-polygon-zkevm-security-review.md>)
- Auditor: Hexens
- Date: 2023-02-27
- Description: Hexens security review (Dec 2022 to Feb 2023) of Polygon zkEVM covering the L1/L2 bridge and PoE smart contracts, the zkASM main ROM, the storage ROM and the PIL constraints of the prover. Four Critical and one High issue were found (ERC777 re-entrancy in the bridge, missing PIL constraints, zkASM context and memory bugs), all reported as fixed at the listed remediation commits.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/ec421a4499f07b65d2242f39bb039476ec1cf5e1/contracts"><code>ec421a4499f07b65d2242f39bb039476ec1cf5e1</code></a> | March 2, 2023 | <code>contracts</code> (recursive directory) |

### Repository: <a href="https://github.com/0xPolygon/zkevm-proverjs"><code>0xPolygon/zkevm-proverjs</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xPolygon/zkevm-proverjs/tree/ab3dbf24172b828e3ff4bbb0238f866199f0c834/pil"><code>ab3dbf24172b828e3ff4bbb0238f866199f0c834</code></a> | March 9, 2023 | <code>pil</code> (recursive directory) |

### Repository: <a href="https://github.com/0xPolygon/zkevm-rom"><code>0xPolygon/zkevm-rom</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xPolygon/zkevm-rom/tree/2ddeffbed7c022e04032e6d56ed6c6fb14cc38dc/main"><code>2ddeffbed7c022e04032e6d56ed6c6fb14cc38dc</code></a> | March 2, 2023 | <code>main</code> (recursive directory) |

### Repository: <a href="https://github.com/0xPolygon/zkevm-storage-rom"><code>0xPolygon/zkevm-storage-rom</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xPolygon/zkevm-storage-rom/tree/97af71cd372ae6715e818795266d02a5a854cfa6/zkasm"><code>97af71cd372ae6715e818795266d02a5a854cfa6</code></a> | February 17, 2023 | <code>zkasm</code> (recursive directory) |

## Polygon zkEVM Contracts Security Review

- Report: [2023_03-spearbit-polygon-zkevm-contracts-bridge.md](<reports/2023_03-spearbit-polygon-zkevm-contracts-bridge.md>)
- Auditor: Spearbit
- Date: 2023-03-27
- Description: Spearbit review of the Polygon zkEVM L1/L2 contracts (PolygonZkEVM, PolygonZkEVMBridge, global exit root managers, timelock, deposit tree) at 5de59e1, followed by a fix period and a March 2023 deployment review at cddde28. No Critical or High issues were found.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/5de59e18690e877a10e3f1ed679969166313f899/contracts"><code>5de59e18690e877a10e3f1ed679969166313f899</code></a> | December 22, 2022 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/1b3e6d97c222f080b4c38523dfac933b6744e0cf/contracts"><code>1b3e6d97c222f080b4c38523dfac933b6744e0cf</code></a> | January 24, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/f9e9dcdf612951ed4ef2eb8716fb99c81a3a9ad7/contracts"><code>f9e9dcdf612951ed4ef2eb8716fb99c81a3a9ad7</code></a> | January 24, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/2448b6e5b9c12bdd150643d89abfc1f6fb1303df/contracts"><code>2448b6e5b9c12bdd150643d89abfc1f6fb1303df</code></a> | January 25, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/53538406bcebf2b59066634fcaa47379b286787f/contracts"><code>53538406bcebf2b59066634fcaa47379b286787f</code></a> | January 26, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/5b185c4588fae1f1d85658beeb120e175bc5e2cf/contracts"><code>5b185c4588fae1f1d85658beeb120e175bc5e2cf</code></a> | January 27, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/f5bb381ccf07d68cf4a17a427d42beda5f71c527/contracts"><code>f5bb381ccf07d68cf4a17a427d42beda5f71c527</code></a> | February 3, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/a243dc0d88a9ceb065892b1fcdbb9600a2c600c2/contracts"><code>a243dc0d88a9ceb065892b1fcdbb9600a2c600c2</code></a> | February 6, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/cddde284bebd7421a72343090b0566c1342e3ffc/contracts"><code>cddde284bebd7421a72343090b0566c1342e3ffc</code></a> | March 20, 2023 | <code>contracts</code> (recursive directory) |

## Security Review Report for Polygon (LxLy Bridge and Call)

- Report: [2024_05-hexens-polygon-lxly-bridge-and-call.md](<reports/2024_05-hexens-polygon-lxly-bridge-and-call.md>)
- Auditor: Hexens
- Date: 2024-05-30
- Description: Hexens review of the lxly-bridge-and-call extension (BridgeExtension, JumpPoint) built on top of PolygonZkEVMBridgeV2. One Critical and one High issue (fund loss in bridgeAndCall, non-compliant ERC20 transfers in JumpPoint) were reported as fixed at fed2b23.

### Repository: <a href="https://github.com/agglayer/lxly-bridge-and-call"><code>agglayer/lxly-bridge-and-call</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/lxly-bridge-and-call/blob/31593c5ec31b6669f9a015aa6f7edc8497420969/src/BridgeExtension.sol"><code>31593c5ec31b6669f9a015aa6f7edc8497420969</code></a> | May 15, 2024 | <code>src/BridgeExtension.sol</code><br><code>src/BridgeExtensionProxy.sol</code><br><code>src/IBridgeAndCall.sol</code><br><code>src/JumpPoint.sol</code> |
| <a href="https://github.com/agglayer/lxly-bridge-and-call/blob/fed2b23e557d2a5fca040993d10b18590351b608/src/BridgeExtension.sol"><code>fed2b23e557d2a5fca040993d10b18590351b608</code></a> | June 4, 2024 | <code>src/BridgeExtension.sol</code><br><code>src/BridgeExtensionProxy.sol</code><br><code>src/IBridgeAndCall.sol</code><br><code>src/JumpPoint.sol</code> |

## Polygon Pessimistic Proofs Security Assessment (Summary Report)

- Report: [2024_08-trailofbits-polygon-pessimistic-proofs-summary-report.md](<reports/2024_08-trailofbits-polygon-pessimistic-proofs-summary-report.md>)
- Auditor: Trail of Bits
- Date: 2024-08-26
- Description: Trail of Bits one engineer-week review of the pessimistic-proof Rust crate (sparse/append-only Merkle trees, transfer and balance validation, signature and data commitments) proven in SP1. Only the summary report is public; it reports one Medium, two Low and several informational issues.

### Repository: <a href="https://github.com/agglayer/agglayer"><code>agglayer/agglayer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer/tree/d9d33885b6a396a69f57054d7b549edc6ca1ef51/crates/pessimistic-proof"><code>d9d33885b6a396a69f57054d7b549edc6ca1ef51</code></a> | August 16, 2024 | <code>crates/pessimistic-proof</code> (recursive directory) |

## Polygon Agg Security Review

- Report: [2025_09-spearbit-polygon-agglayer-v0.3.0.md](<reports/2025_09-spearbit-polygon-agglayer-v0.3.0.md>)
- Auditor: Spearbit
- Date: 2025-09-17
- Description: Spearbit review of the full Agglayer v0.3.0 stack: agglayer v0.3.0-rc.17 (node and pessimistic proof crates), provers v0.1.0-rc.23, aggkit v0.3.0-beta3 and agglayer-contracts v10.1.0-rc.4, with fix verification on later pull requests. The review found 7 High, 2 Medium, 16 Low and 23 Informational issues; the High findings concern aggkit, the agglayer node and the bridge contracts&#x27; global index and claim hash chain handling.

### Repository: <a href="https://github.com/agglayer/agglayer"><code>agglayer/agglayer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer/releases/tag/v0.3.0-rc.17"><code>93375323132762ccbdcce57f90466a838b3bb4f1</code></a> (tag <code>v0.3.0-rc.17</code>) | April 28, 2025 | <code>crates/agglayer-aggregator-notifier</code> (recursive directory)<br><code>crates/agglayer-certificate-orchestrator</code> (recursive directory)<br><code>crates/agglayer-clock</code> (recursive directory)<br><code>crates/agglayer-config</code> (recursive directory)<br><code>crates/agglayer-contracts</code> (recursive directory)<br><code>crates/agglayer-gcp-kms</code> (recursive directory)<br><code>crates/agglayer-grpc-api</code> (recursive directory)<br><code>crates/agglayer-grpc-client</code> (recursive directory)<br><code>crates/agglayer-grpc-server</code> (recursive directory)<br><code>crates/agglayer-grpc-types</code> (recursive directory)<br><code>crates/agglayer-jsonrpc-api</code> (recursive directory)<br><code>crates/agglayer-node</code> (recursive directory)<br><code>crates/agglayer-rate-limiting</code> (recursive directory)<br><code>crates/agglayer-rpc</code> (recursive directory)<br><code>crates/agglayer-signer</code> (recursive directory)<br><code>crates/agglayer-storage</code> (recursive directory)<br><code>crates/agglayer-telemetry</code> (recursive directory)<br><code>crates/agglayer-types</code> (recursive directory)<br><code>crates/agglayer-utils</code> (recursive directory)<br><code>crates/agglayer</code> (recursive directory)<br><code>crates/pessimistic-proof-core</code> (recursive directory)<br><code>crates/pessimistic-proof-program</code> (recursive directory)<br><code>crates/pessimistic-proof</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/ecb5d5e50c73a3a7d0974008070b1aac97d3b4ad"><code>ecb5d5e50c73a3a7d0974008070b1aac97d3b4ad</code></a> | April 29, 2025 | <code>crates/agglayer-aggregator-notifier</code> (recursive directory)<br><code>crates/agglayer-certificate-orchestrator</code> (recursive directory)<br><code>crates/agglayer-types</code> (recursive directory)<br><code>crates/pessimistic-proof-core</code> (recursive directory)<br><code>crates/pessimistic-proof-program</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/e4ff39396a27ae013c28f4f4099600b9acb0efee"><code>e4ff39396a27ae013c28f4f4099600b9acb0efee</code></a> | May 20, 2025 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory)<br><code>crates/agglayer-rpc</code> (recursive directory)<br><code>crates/agglayer-storage</code> (recursive directory)<br><code>crates/agglayer-types</code> (recursive directory)<br><code>crates/pessimistic-proof-core</code> (recursive directory)<br><code>crates/pessimistic-proof-program</code> (recursive directory)<br><code>crates/pessimistic-proof</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/14af9ee36562fee8ca5546fc16a997f58e73d743"><code>14af9ee36562fee8ca5546fc16a997f58e73d743</code></a> | May 21, 2025 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/b71e137e6ee75dd5ac0ab47e7d9c7422289872db"><code>b71e137e6ee75dd5ac0ab47e7d9c7422289872db</code></a> | June 16, 2025 | <code>crates/agglayer-types</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/dda24ddc914b360a44887da72373d57802e70c8e"><code>dda24ddc914b360a44887da72373d57802e70c8e</code></a> | June 25, 2025 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory)<br><code>crates/agglayer-storage</code> (recursive directory)<br><code>crates/agglayer-types</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/e2e76c0588ab0a2193d7f65893ead66a5ae4e3b7"><code>e2e76c0588ab0a2193d7f65893ead66a5ae4e3b7</code></a> | July 18, 2025 | <code>crates/agglayer-rpc</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/ed366010058d65b76cc008f9dbcac5d63c110171"><code>ed366010058d65b76cc008f9dbcac5d63c110171</code></a> | July 25, 2025 | <code>crates/agglayer-jsonrpc-api</code> (recursive directory)<br><code>crates/agglayer-rpc</code> (recursive directory)<br><code>crates/agglayer-storage</code> (recursive directory)<br><code>crates/agglayer-types</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/eb2a077e1c74c4a033674fdba5457f5e3bce6fdb"><code>eb2a077e1c74c4a033674fdba5457f5e3bce6fdb</code></a> | July 29, 2025 | <code>crates/agglayer-contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/90f429c5a15f71a4066bb103fb66c22603d3ee3d"><code>90f429c5a15f71a4066bb103fb66c22603d3ee3d</code></a> | August 8, 2025 | <code>crates/agglayer-jsonrpc-api</code> (recursive directory) |

### Repository: <a href="https://github.com/agglayer/provers"><code>agglayer/provers</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/provers/releases/tag/v0.1.0-rc.23"><code>cf8661a5cddd91d3b0229bfb38e4011cbf0c0b76</code></a> (tag <code>v0.1.0-rc.23</code>) | May 13, 2025 | <code>crates/aggchain-proof-builder</code> (recursive directory)<br><code>crates/aggchain-proof-contracts</code> (recursive directory)<br><code>crates/aggchain-proof-core</code> (recursive directory)<br><code>crates/aggchain-proof-program</code> (recursive directory)<br><code>crates/aggchain-proof-service</code> (recursive directory)<br><code>crates/aggchain-proof-types</code> (recursive directory)<br><code>crates/aggkit-prover-config</code> (recursive directory)<br><code>crates/aggkit-prover-types</code> (recursive directory)<br><code>crates/aggkit-prover</code> (recursive directory)<br><code>crates/agglayer-prover-config</code> (recursive directory)<br><code>crates/agglayer-prover-types</code> (recursive directory)<br><code>crates/agglayer-prover</code> (recursive directory)<br><code>crates/proposer-client</code> (recursive directory)<br><code>crates/proposer-elfs</code> (recursive directory)<br><code>crates/proposer-service</code> (recursive directory)<br><code>crates/prover-alloy</code> (recursive directory)<br><code>crates/prover-config</code> (recursive directory)<br><code>crates/prover-dummy-program</code> (recursive directory)<br><code>crates/prover-elf-utils</code> (recursive directory)<br><code>crates/prover-engine</code> (recursive directory)<br><code>crates/prover-executor</code> (recursive directory)<br><code>crates/prover-logger</code> (recursive directory)<br><code>crates/prover-utils</code> (recursive directory) |

### Repository: <a href="https://github.com/agglayer/aggkit"><code>agglayer/aggkit</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/aggkit/releases/tag/v0.3.0-beta3"><code>2d68cb6a3453cf458bb2da92fc24caf569c7f917</code></a> (tag <code>v0.3.0-beta3</code>) | May 16, 2025 | <code>agglayer</code> (recursive directory)<br><code>aggoracle</code> (recursive directory)<br><code>aggsender</code> (recursive directory)<br><code>bridgesync</code> (recursive directory)<br><code>claimsponsor</code> (recursive directory)<br><code>cmd</code> (recursive directory)<br><code>common</code> (recursive directory)<br><code>config</code> (recursive directory)<br><code>db</code> (recursive directory)<br><code>etherman</code> (recursive directory)<br><code>healthcheck</code> (recursive directory)<br><code>hex</code> (recursive directory)<br><code>l1infotree</code> (recursive directory)<br><code>l1infotreesync</code> (recursive directory)<br><code>lastgersync</code> (recursive directory)<br><code>log</code> (recursive directory)<br><code>merkletree</code> (recursive directory)<br><code>opnode</code> (recursive directory)<br><code>pprof</code> (recursive directory)<br><code>prometheus</code> (recursive directory)<br><code>reorgdetector</code> (recursive directory)<br><code>rpc</code> (recursive directory)<br><code>state</code> (recursive directory)<br><code>sync</code> (recursive directory)<br><code>tools</code> (recursive directory)<br><code>translator</code> (recursive directory)<br><code>tree</code> (recursive directory)<br><code>version.go</code> |
| <a href="https://github.com/agglayer/aggkit/commit/9c62351e2f50b0b87bf3555d1829e1deffb866a0"><code>9c62351e2f50b0b87bf3555d1829e1deffb866a0</code></a> | May 29, 2025 | <code>aggsender</code> (recursive directory)<br><code>bridgesync</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/198615a2d00c79375e7a325904d8bc157fdaa715"><code>198615a2d00c79375e7a325904d8bc157fdaa715</code></a> | June 2, 2025 | <code>agglayer</code> (recursive directory)<br><code>aggsender</code> (recursive directory)<br><code>common</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/8b59248ea9ed806bf92739603501e6ca465b12f5"><code>8b59248ea9ed806bf92739603501e6ca465b12f5</code></a> | June 9, 2025 | <code>db</code> (recursive directory)<br><code>lastgersync</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/2364b97d3186c5bd3b8ea618863219c58c0e49bb"><code>2364b97d3186c5bd3b8ea618863219c58c0e49bb</code></a> | June 11, 2025 | <code>agglayer</code> (recursive directory)<br><code>aggoracle</code> (recursive directory)<br><code>aggsender</code> (recursive directory)<br><code>bridgesync</code> (recursive directory)<br><code>cmd</code> (recursive directory)<br><code>common</code> (recursive directory)<br><code>config</code> (recursive directory)<br><code>etherman</code> (recursive directory)<br><code>l1infotreesync</code> (recursive directory)<br><code>lastgersync</code> (recursive directory)<br><code>reorgdetector</code> (recursive directory)<br><code>sync</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/81259a23ae668995340897d21a8acd58bc228482"><code>81259a23ae668995340897d21a8acd58bc228482</code></a> | June 11, 2025 | <code>aggsender</code> (recursive directory)<br><code>config</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/adc16482c0cc6f23fdbc0911b9bb85daae9eda58"><code>adc16482c0cc6f23fdbc0911b9bb85daae9eda58</code></a> | June 17, 2025 | <code>bridgesync</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/690e2b164d1828114ce1dbfcf0e7331f8c15cc61"><code>690e2b164d1828114ce1dbfcf0e7331f8c15cc61</code></a> | June 24, 2025 | <code>sync</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/8f07326d5d7bb75c50114cfddfc86fef85a35dff"><code>8f07326d5d7bb75c50114cfddfc86fef85a35dff</code></a> | June 25, 2025 | <code>aggsender</code> (recursive directory)<br><code>bridgesync</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/3e519454de199cc5b7834bcc471d997c529cc6c6"><code>3e519454de199cc5b7834bcc471d997c529cc6c6</code></a> | June 27, 2025 | <code>aggsender</code> (recursive directory)<br><code>bridgesync</code> (recursive directory)<br><code>lastgersync</code> (recursive directory)<br><code>reorgdetector</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/8836248064085d2d8da01c1cafaebafa74d673d1"><code>8836248064085d2d8da01c1cafaebafa74d673d1</code></a> | July 2, 2025 | <code>l1infotreesync</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/2fa8a6c9383612999ddbcd6bcf82232c7c76758a"><code>2fa8a6c9383612999ddbcd6bcf82232c7c76758a</code></a> | July 14, 2025 | <code>aggoracle</code> (recursive directory)<br><code>aggsender</code> (recursive directory)<br><code>cmd</code> (recursive directory)<br><code>config</code> (recursive directory)<br><code>l1infotreesync</code> (recursive directory)<br><code>sync</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/commit/5f02c228414f6b40460fd072c742b4d2eca02251"><code>5f02c228414f6b40460fd072c742b4d2eca02251</code></a> | July 14, 2025 | <code>aggoracle</code> (recursive directory)<br><code>aggsender</code> (recursive directory)<br><code>cmd</code> (recursive directory) |
| <a href="https://github.com/agglayer/aggkit/blob/develop/agglayer/types/types.go#L258"><code>develop</code></a> (mutable branch) | — | <code>agglayer</code> (recursive directory) |

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/releases/tag/v10.1.0-rc.4"><code>07b40c26ae748c47a2a51f8159990ad4163c4d43</code></a> (tag <code>v10.1.0-rc.4</code>) | May 16, 2025 | <code>contracts/PolygonZkEVM.sol</code><br><code>contracts/PolygonZkEVMBridge.sol</code><br><code>contracts/PolygonZkEVMGlobalExitRoot.sol</code><br><code>contracts/PolygonZkEVMGlobalExitRootL2.sol</code><br><code>contracts/PolygonZkEVMTimelock.sol</code><br><code>contracts/deployment/PolygonZkEVMDeployer.sol</code><br><code>contracts/interfaces/IBasePolygonZkEVMGlobalExitRoot.sol</code><br><code>contracts/interfaces/IBridgeMessageReceiver.sol</code><br><code>contracts/interfaces/IPolygonZkEVMBridge.sol</code><br><code>contracts/interfaces/IPolygonZkEVMErrors.sol</code><br><code>contracts/interfaces/IPolygonZkEVMGlobalExitRoot.sol</code><br><code>contracts/interfaces/IVerifierRollup.sol</code><br><code>contracts/lib/DepositContract.sol</code><br><code>contracts/lib/EmergencyManager.sol</code><br><code>contracts/lib/GlobalExitRootLib.sol</code><br><code>contracts/lib/TokenWrapped.sol</code><br><code>contracts/mainnetUpgraded/PolygonZkEVMUpgraded.sol</code><br><code>contracts/testnet/PolygonZkEVMTestnetClearStorage.sol</code><br><code>contracts/testnet/PolygonZkEVMTestnetV2.sol</code><br><code>contracts/token-wrapped-bridge-compiled/TokenWrappedBridge.sol</code><br><code>contracts/v2/AggLayerGateway.sol</code><br><code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/aggchains/AggchainECDSA.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/consensus/pessimistic/PolygonPessimisticConsensus.sol</code><br><code>contracts/v2/consensus/validium/PolygonDataCommittee.sol</code><br><code>contracts/v2/consensus/validium/PolygonValidiumEtrog.sol</code><br><code>contracts/v2/consensus/zkEVM/PolygonZkEVMEtrog.sol</code><br><code>contracts/v2/consensus/zkEVM/PolygonZkEVMExistentEtrog.sol</code><br><code>contracts/v2/interfaces/IAggLayerGateway.sol</code><br><code>contracts/v2/interfaces/IAggchainBase.sol</code><br><code>contracts/v2/interfaces/IBridgeL2SovereignChains.sol</code><br><code>contracts/v2/interfaces/IBytecodeStorer.sol</code><br><code>contracts/v2/interfaces/IDataAvailabilityProtocol.sol</code><br><code>contracts/v2/interfaces/IGlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/v2/interfaces/IPolygonConsensusBase.sol</code><br><code>contracts/v2/interfaces/IPolygonDataCommitteeErrors.sol</code><br><code>contracts/v2/interfaces/IPolygonPessimisticConsensus.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupBase.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupManager.sol</code><br><code>contracts/v2/interfaces/IPolygonValidium.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMEtrogErrors.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/interfaces/ISP1Verifier.sol</code><br><code>contracts/v2/interfaces/ITokenWrappedBridgeUpgradeable.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code><br><code>contracts/v2/lib/BytecodeStorer.sol</code><br><code>contracts/v2/lib/DepositContractBase.sol</code><br><code>contracts/v2/lib/DepositContractV2.sol</code><br><code>contracts/v2/lib/Hashes.sol</code><br><code>contracts/v2/lib/LegacyZKEVMStateVariables.sol</code><br><code>contracts/v2/lib/PolygonAccessControlUpgradeable.sol</code><br><code>contracts/v2/lib/PolygonConsensusBase.sol</code><br><code>contracts/v2/lib/PolygonConstantsBase.sol</code><br><code>contracts/v2/lib/PolygonRollupBaseEtrog.sol</code><br><code>contracts/v2/lib/PolygonTransparentProxy.sol</code><br><code>contracts/v2/lib/PolygonZkEVMGlobalExitRootBaseStorage.sol</code><br><code>contracts/v2/lib/TokenWrappedBridgeUpgradeable.sol</code><br><code>contracts/v2/lib/TokenWrappedTransparentProxy.sol</code><br><code>contracts/v2/newDeployments/PolygonRollupManagerNotUpgraded.sol</code><br><code>contracts/v2/periphery/BatchL2DataCreatedRollup.sol</code><br><code>contracts/v2/periphery/ClaimCompressor.sol</code><br><code>contracts/v2/previousVersions/IPolygonRollupBasePrevious.sol</code><br><code>contracts/v2/previousVersions/IPolygonRollupManagerPrevious.sol</code><br><code>contracts/v2/previousVersions/PolygonRollupBaseEtrogPrevious.sol</code><br><code>contracts/v2/previousVersions/PolygonRollupManagerPrevious.sol</code><br><code>contracts/v2/previousVersions/PolygonRollupManagerPreviousV1toV2.sol</code><br><code>contracts/v2/previousVersions/PolygonValidiumEtrogPrevious.sol</code><br><code>contracts/v2/previousVersions/PolygonZkEVMEtrogPrevious.sol</code><br><code>contracts/v2/previousVersions/pessimistic/BridgeL2SovereignChainPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/DepositContractBasePessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/GlobalExitRootLibPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/GlobalExitRootManagerL2SovereignChainPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/IBasePolygonZkEVMGlobalExitRootPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/IBridgeL2SovereignChainsPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/IPolygonRollupManagerPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/IPolygonZkEVMBridgeV2Pessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonConsensusBasePessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonRollupBaseEtrogPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonRollupManagerPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonZkEVMBridgeV2Pessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonZkEVMExistentEtrogPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonZkEVMGlobalExitRootL2Pessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonZkEVMGlobalExitRootV2Pessimistic.sol</code><br><code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/verifiers/FflonkVerifier_10.sol</code><br><code>contracts/verifiers/FflonkVerifier_11.sol</code><br><code>contracts/verifiers/FflonkVerifier_12.sol</code><br><code>contracts/verifiers/FflonkVerifier_13.sol</code><br><code>contracts/verifiers/previousVerifiers/FflonkVerifierEtrog.sol</code><br><code>contracts/verifiers/previousVerifiers/FflonkVerifierIncaberry.sol</code><br><code>contracts/verifiers/v4.0.0-rc.3/PlonkVerifier.sol</code><br><code>contracts/verifiers/v4.0.0-rc.3/SP1VerifierPlonk.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/bf76c0d785f84b7a3d006aaa604a986a416c4a1e"><code>bf76c0d785f84b7a3d006aaa604a986a416c4a1e</code></a> | June 27, 2025 | <code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/92d6b5eda4e77fa3b98c3920d21ae41afe5b7535"><code>92d6b5eda4e77fa3b98c3920d21ae41afe5b7535</code></a> | July 30, 2025 | <code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/aggchains/AggchainECDSA.sol</code> |

### Repository: <a href="https://github.com/agglayer/interop"><code>agglayer/interop</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/interop/commit/42cf948bf7ec9dfc4064da1a98a39d129737671b"><code>42cf948bf7ec9dfc4064da1a98a39d129737671b</code></a> | August 20, 2025 | <code>crates/agglayer-tries</code> (recursive directory)<br><code>crates/unified-bridge</code> (recursive directory) |

## Polygon LXLY Bridge Smart Contract Security Assessment

- Report: [2024_02-sigmaprime-polygon-lxly-bridge.md](<reports/2024_02-sigmaprime-polygon-lxly-bridge.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime review of the zkevm-contracts repository for the LxLy (v2) upgrade: PolygonZkEVMBridgeV2, PolygonRollupManager, global exit root V2, etrog rollup/validium consensus and data committee contracts. No Critical or High issues were found (7 Medium); fixes were retested at 7677b8c.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/1403e2b2bb6b731844aa9048424262fb00c30e89/contracts"><code>1403e2b2bb6b731844aa9048424262fb00c30e89</code></a> | November 18, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/0f57a1098748a53776867d07a5346ecb58f38a1d/contracts"><code>0f57a1098748a53776867d07a5346ecb58f38a1d</code></a> | December 13, 2023 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/7677b8ccf10abc13903d0aceb66daa9a8a5fb0b0/contracts"><code>7677b8ccf10abc13903d0aceb66daa9a8a5fb0b0</code></a> | January 21, 2024 | <code>contracts</code> (recursive directory) |

## LX/LY Bridge - Banana Upgrade Security Assessment

- Report: [2024_06-sigmaprime-polygon-lxly-bridge-banana-upgrade.md](<reports/2024_06-sigmaprime-polygon-lxly-bridge-banana-upgrade.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of the Banana upgrade changes in zkevm-contracts (rollbackBatches and related PolygonRollupManager, etrog consensus and global exit root changes). One High issue (rollbackBatches ignoring pending state) was resolved by the retest commit 5184e5b.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/0ab3f10a1d8bf753bdf33d9488a57345d28425f8/contracts/v2/PolygonRollupManager.sol"><code>0ab3f10a1d8bf753bdf33d9488a57345d28425f8</code></a> | June 10, 2024 | <code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/consensus/validium/PolygonValidiumEtrog.sol</code><br><code>contracts/v2/lib/PolygonRollupBaseEtrog.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupBase.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupManager.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMVEtrogErrors.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/57f3184b2d305994611ee0e64df76d6febee3b58/contracts/v2/PolygonRollupManager.sol"><code>57f3184b2d305994611ee0e64df76d6febee3b58</code></a> | June 17, 2024 | <code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/lib/PolygonRollupBaseEtrog.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupBase.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/5184e5b8f01b04d9a7fbb9f7bb7c2ced31389fc5/contracts/v2/PolygonRollupManager.sol"><code>5184e5b8f01b04d9a7fbb9f7bb7c2ced31389fc5</code></a> | June 18, 2024 | <code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/consensus/validium/PolygonValidiumEtrog.sol</code><br><code>contracts/v2/lib/PolygonRollupBaseEtrog.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupBase.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupManager.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMVEtrogErrors.sol</code> |

## Polygon Aggregation Layer Security Assessment Report

- Report: [2024_12-sigmaprime-polygon-aggregation-layer.md](<reports/2024_12-sigmaprime-polygon-aggregation-layer.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime review of the AggLayer v0.2 Rust code (agglayer node crates and the pessimistic-proof crate/program at d9d3388) and of the pessimistic-proof contract changes in zkevm-contracts (c4eda49..2de7a151: PolygonRollupManager, PolygonPessimisticConsensus, PolygonConsensusBase, global exit root). One Critical and three High issues were found, all in the Rust code.

### Repository: <a href="https://github.com/agglayer/agglayer"><code>agglayer/agglayer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer/tree/d9d33885b6a396a69f57054d7b549edc6ca1ef51/crates/agglayer"><code>d9d33885b6a396a69f57054d7b549edc6ca1ef51</code></a> | August 16, 2024 | <code>crates/agglayer</code> (recursive directory)<br><code>crates/agglayer-aggregator-notifier</code> (recursive directory)<br><code>crates/agglayer-certificate-orchestrator</code> (recursive directory)<br><code>crates/agglayer-clock</code> (recursive directory)<br><code>crates/agglayer-config</code> (recursive directory)<br><code>crates/agglayer-gcp-kms</code> (recursive directory)<br><code>crates/agglayer-node</code> (recursive directory)<br><code>crates/agglayer-signer</code> (recursive directory)<br><code>crates/agglayer-telemetry</code> (recursive directory)<br><code>crates/pessimistic-proof</code> (recursive directory)<br><code>crates/pessimistic-proof-program</code> (recursive directory)<br><code>crates/pessimistic-proof-test-suite</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/tree/a8a968b0d80eb27f8d361b525a2aac52ca16d032/crates/pessimistic-proof"><code>a8a968b0d80eb27f8d361b525a2aac52ca16d032</code></a> | September 27, 2024 | <code>crates/pessimistic-proof</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/tree/bd70d4bb332edfea2ed5ee00e1d975cc0c495638/crates/agglayer-certificate-orchestrator"><code>bd70d4bb332edfea2ed5ee00e1d975cc0c495638</code></a> | September 30, 2024 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/tree/b32d2465943b5fe4c4884cc8b73294692153252f/crates/pessimistic-proof"><code>b32d2465943b5fe4c4884cc8b73294692153252f</code></a> | October 28, 2024 | <code>crates/pessimistic-proof</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/tree/7daca4bc1519d5dc091c19dc44fce68e17565d78/crates/agglayer-aggregator-notifier"><code>7daca4bc1519d5dc091c19dc44fce68e17565d78</code></a> | November 4, 2024 | <code>crates/agglayer-aggregator-notifier</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/tree/6e17c8e583f7808fb45fd1321b59792940cdc723/crates/agglayer-certificate-orchestrator"><code>6e17c8e583f7808fb45fd1321b59792940cdc723</code></a> | November 14, 2024 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/tree/ce2cadb8b219cf71d2aa7e0c1707613b3dc18e48/crates/agglayer-clock"><code>ce2cadb8b219cf71d2aa7e0c1707613b3dc18e48</code></a> | November 18, 2024 | <code>crates/agglayer-clock</code> (recursive directory)<br><code>crates/agglayer-node</code> (recursive directory) |

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/compare/c4eda494efe58727a8a3e04208b4d0f1921605dc...2de7a151ba86bf60930b0ee1b6461fb87cb16e25"><code>c4eda494efe58727a8a3e04208b4d0f1921605dc…2de7a151ba86bf60930b0ee1b6461fb87cb16e25</code></a> (commit range) | June 11, 2024 – August 18, 2024 | <code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/consensus/pessimistic/PolygonPessimisticConsensus.sol</code><br><code>contracts/v2/lib/PolygonConsensusBase.sol</code><br><code>contracts/v2/lib/PolygonRollupBaseEtrog.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/f0ba99b2987135830a75f1e24b3528432ad20f25/contracts/v2/PolygonRollupManager.sol"><code>f0ba99b2987135830a75f1e24b3528432ad20f25</code></a> | September 15, 2024 | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/d05367ea31d5cae4240785cef9497c94b67f2fa5/contracts/v2/PolygonRollupManager.sol"><code>d05367ea31d5cae4240785cef9497c94b67f2fa5</code></a> | October 3, 2024 | <code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code> |

## LX/LY Bridge - Sovereign Chains Security Assessment

- Report: [2025_01-sigmaprime-polygon-lxly-bridge-sovereign-chains.md](<reports/2025_01-sigmaprime-polygon-lxly-bridge-sovereign-chains.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime review of zkevm-contracts PR #330 adding the sovereign-chain bridge (BridgeL2SovereignChain, GlobalExitRootManagerL2SovereignChain) and related bridge/global exit root changes, plus the updateVanillaGenesis.ts script. No Critical or High issues were found; fixes were assessed at f448f90.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/ddfd159beeb13b871d901b14c95e9b7ae972a3b1/contracts/v2/sovereignChains/BridgeL2SovereignChain.sol"><code>ddfd159beeb13b871d901b14c95e9b7ae972a3b1</code></a> | November 5, 2024 | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/v2/interfaces/IBridgeL2SovereignChains.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/PolygonZkEVMGlobalExitRootL2.sol</code><br><code>contracts/interfaces/IBasePolygonZkEVMGlobalExitRoot.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/a4b0c9361f12d2a9a5c23e9951e998e98380ea27/deployment/v2/utils/updateVanillaGenesis.ts"><code>a4b0c9361f12d2a9a5c23e9951e998e98380ea27</code></a> | November 18, 2024 | <code>deployment/v2/utils/updateVanillaGenesis.ts</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/8b4d221dc0ce47564506e5187f684affa5dccc75/contracts/v2/sovereignChains/BridgeL2SovereignChain.sol"><code>8b4d221dc0ce47564506e5187f684affa5dccc75</code></a> | December 24, 2024 | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/v2/interfaces/IBridgeL2SovereignChains.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/interfaces/IBasePolygonZkEVMGlobalExitRoot.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/817effc293fc33acd613052d1a508c1275a2857b/contracts/v2/sovereignChains/BridgeL2SovereignChain.sol"><code>817effc293fc33acd613052d1a508c1275a2857b</code></a> | January 14, 2025 | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/blob/f448f906de02986a520ce6fc7e52c1e9fbaac89a/contracts/v2/sovereignChains/BridgeL2SovereignChain.sol"><code>f448f906de02986a520ce6fc7e52c1e9fbaac89a</code></a> | January 14, 2025 | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/v2/interfaces/IBridgeL2SovereignChains.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/PolygonZkEVMGlobalExitRootL2.sol</code><br><code>contracts/interfaces/IBasePolygonZkEVMGlobalExitRoot.sol</code> |

## AggLayer v0.3.0 - Smart Contract Updates Security Assessment Report (v2.1)

- Report: [2025_04-sigmaprime-polygon-agglayer-v0.3.0-smart-contract-updates.md](<reports/2025_04-sigmaprime-polygon-agglayer-v0.3.0-smart-contract-updates.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of the AggLayer v0.3.0 contracts at tag v10.0.0-rc.2 (AggchainECDSA, AggchainFEP, AggLayerGateway in full, plus the PolygonRollupManager, BridgeL2SovereignChain and GlobalExitRootManagerL2SovereignChain changes since v9.0.0-rc.5-pp), with a retest of fixes and of 15 follow-up pull requests. The review found 4 Medium, 7 Low and 16 Informational issues.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/compare/v9.0.0-rc.5-pp...v10.0.0-rc.2"><code>d49361a32af713d8c30c43ea8edc53ad42b804bd…0df1db5860130f51d4adf670e98c913699fc25c6</code></a> (commit range) | January 17, 2025 – March 2, 2025 | <code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/releases/tag/v10.0.0-rc.2"><code>0df1db5860130f51d4adf670e98c913699fc25c6</code></a> (tag <code>v10.0.0-rc.2</code>) | March 2, 2025 | <code>contracts/v2/aggchains/AggchainECDSA.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/AggLayerGateway.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/b43f031dead5e2a5cf51dc14f44a2bd67f8d3640"><code>b43f031dead5e2a5cf51dc14f44a2bd67f8d3640</code></a> | March 3, 2025 | <code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/99c41e07136344d1bb033d8ca9b1ad94d14d6bef"><code>99c41e07136344d1bb033d8ca9b1ad94d14d6bef</code></a> | March 5, 2025 | <code>contracts/v2/aggchains/AggchainECDSA.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/AggLayerGateway.sol</code><br><code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/39d9323556e6d5c638508a205c2561d7377d5987"><code>39d9323556e6d5c638508a205c2561d7377d5987</code></a> | March 9, 2025 | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/c5ab20877290e580e0fff15e29c1a52f69ddde4c"><code>c5ab20877290e580e0fff15e29c1a52f69ddde4c</code></a> | March 11, 2025 | <code>contracts/v2/AggLayerGateway.sol</code><br><code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/d10b728a8c72c3faf84490f6fd98fe27cdbe5010"><code>d10b728a8c72c3faf84490f6fd98fe27cdbe5010</code></a> | March 11, 2025 | <code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/a90f60b59dbe2a87b06245c129e3d422d6bbece7"><code>a90f60b59dbe2a87b06245c129e3d422d6bbece7</code></a> | March 11, 2025 | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/bb41ae3903cafe89a9ee6b9bfa229bbe19e87129"><code>bb41ae3903cafe89a9ee6b9bfa229bbe19e87129</code></a> | March 11, 2025 | <code>contracts/v2/PolygonZkEVMBridgeV2.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/632ba4849661c1c8969172e405ab78183897b2a4"><code>632ba4849661c1c8969172e405ab78183897b2a4</code></a> | March 12, 2025 | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/d67a9d0fb16775b716f38d722263c8bc929969e2"><code>d67a9d0fb16775b716f38d722263c8bc929969e2</code></a> | March 18, 2025 | <code>contracts/v2/AggLayerGateway.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/1c90133dc92edc484224a54eecd3f84c489c5fe9"><code>1c90133dc92edc484224a54eecd3f84c489c5fe9</code></a> | March 24, 2025 | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/d6b59256c2195e4d4f7e51bc96aff6b7863de5ac"><code>d6b59256c2195e4d4f7e51bc96aff6b7863de5ac</code></a> | March 31, 2025 | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/lib/TokenWrappedBridgeInitCode.sol</code><br><code>deployment/v2/utils/updateVanillaGenesis.ts</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/f93abf34188a652b6c0b9fb6b0e7ab082a14d884"><code>f93abf34188a652b6c0b9fb6b0e7ab082a14d884</code></a> | April 8, 2025 | <code>contracts/v2/aggchains/AggchainECDSA.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/1eec8830e196d5d0a683cbe938f3ee727c29c318"><code>1eec8830e196d5d0a683cbe938f3ee727c29c318</code></a> | April 8, 2025 | <code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>deployment/v2/utils/updateVanillaGenesis.ts</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/64d75de92d24b9c8ce02db7244c505e8845c1dfe"><code>64d75de92d24b9c8ce02db7244c505e8845c1dfe</code></a> | April 8, 2025 | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>deployment/v2/utils/updateVanillaGenesis.ts</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/74682ad92f450f3f0d0e69b72d560a7323a02239"><code>74682ad92f450f3f0d0e69b72d560a7323a02239</code></a> | April 8, 2025 | <code>contracts/v2/newDeployments/PolygonRollupManagerNotUpgraded.sol</code> |

### Repository: <a href="https://github.com/agglayer/agg-contracts-internal"><code>agglayer/agg-contracts-internal</code></a>

_Commit dates unavailable: 16 revision(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/2938b39048f3f8072a6fc0dc5fa35ece2e3507ea"><code>2938b39048f3f8072a6fc0dc5fa35ece2e3507ea</code></a> | — | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/3643c5818ab218c480d7b57a2566bf9a909bc6fa"><code>3643c5818ab218c480d7b57a2566bf9a909bc6fa</code></a> | — | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/eb96842edbe85578f8a1a761fddabf9b9d73dc28"><code>eb96842edbe85578f8a1a761fddabf9b9d73dc28</code></a> | — | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/f9825c6dd95467ba1df160d20b350cae223ca180"><code>f9825c6dd95467ba1df160d20b350cae223ca180</code></a> | — | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/5053e61c7ff791e85edbeb31dfc4b4bbe78a92e3"><code>5053e61c7ff791e85edbeb31dfc4b4bbe78a92e3</code></a> | — | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/07f71369107880eb575a74d94140eb7eda148adc"><code>07f71369107880eb575a74d94140eb7eda148adc</code></a> | — | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/443b4934563efffa9288ecfe26319d52c73d0683"><code>443b4934563efffa9288ecfe26319d52c73d0683</code></a> | — | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/03aceb4902aeeceb46a08976443fc56dd0efa348"><code>03aceb4902aeeceb46a08976443fc56dd0efa348</code></a> | — | <code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/AggLayerGateway.sol</code><br><code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/252f3b27e8477743247c0c529ee3782a97a70d7b"><code>252f3b27e8477743247c0c529ee3782a97a70d7b</code></a> | — | <code>contracts/v2/aggchains/AggchainECDSA.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/952a73eb8f76bbc226b01cde00e390abbc871f02"><code>952a73eb8f76bbc226b01cde00e390abbc871f02</code></a> | — | <code>contracts/v2/aggchains/AggchainFEP.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/990743bf558b0be94d42f4cb59f1aacfb12285ff"><code>990743bf558b0be94d42f4cb59f1aacfb12285ff</code></a> | — | <code>contracts/v2/aggchains/AggchainECDSA.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/a3db27d9dd90b61affe4fe60eac995e0518ed516"><code>a3db27d9dd90b61affe4fe60eac995e0518ed516</code></a> | — | <code>contracts/v2/AggLayerGateway.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/859550430b7a1d691fa3084e90fa5ec160bb56d1"><code>859550430b7a1d691fa3084e90fa5ec160bb56d1</code></a> | — | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/9a4441f9b6538cccf8b3876e46db7765c5bb8751"><code>9a4441f9b6538cccf8b3876e46db7765c5bb8751</code></a> | — | <code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/ffaecf7722aeb3fb182786799a9604c28f2e70ca"><code>ffaecf7722aeb3fb182786799a9604c28f2e70ca</code></a> | — | <code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code> |
| <a href="https://github.com/agglayer/agg-contracts-internal/commit/b7a3c8b213298248294abfbe3eab150cd76fe02d"><code>b7a3c8b213298248294abfbe3eab150cd76fe02d</code></a> | — | <code>contracts/v2/aggchains/AggchainECDSA.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code> |

## LXLY Upgradeable Wrapped Tokens Security Assessment Report (v2.0)

- Report: [2025_05-sigmaprime-polygon-lxly-upgradeable-wrapped-tokens.md](<reports/2025_05-sigmaprime-polygon-lxly-upgradeable-wrapped-tokens.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of the Solidity and updateVanillaGenesis.ts changes in agglayer-contracts v10.0.0-rc.6...v10.1.0-rc.1 introducing upgradeable wrapped tokens in the LxLy bridge, with fixes assessed at tag v10.1.0-rc.4. The review found 1 Medium and 5 Informational issues.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/compare/v10.0.0-rc.6...v10.1.0-rc.1"><code>267fe7722d45117982924fe74172f0f759a3191c…2fa3db7365d6f6580d507c4e5cb1a9a79ee2cd7a</code></a> (commit range) | April 15, 2025 – May 2, 2025 | <code>contracts/PolygonZkEVM.sol</code><br><code>contracts/PolygonZkEVMBridge.sol</code><br><code>contracts/PolygonZkEVMGlobalExitRootL2.sol</code><br><code>contracts/PolygonZkEVMTimelock.sol</code><br><code>contracts/deployment/PolygonZkEVMDeployer.sol</code><br><code>contracts/lib/DepositContract.sol</code><br><code>contracts/lib/EmergencyManager.sol</code><br><code>contracts/lib/TokenWrapped.sol</code><br><code>contracts/lib/TokenWrappedBridge.sol</code><br><code>contracts/v2/AggLayerGateway.sol</code><br><code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/aggchains/AggchainECDSA.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/consensus/validium/PolygonDataCommittee.sol</code><br><code>contracts/v2/interfaces/IAggchainBase.sol</code><br><code>contracts/v2/interfaces/IBridgeL2SovereignChains.sol</code><br><code>contracts/v2/interfaces/IBytecodeStorer.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code><br><code>contracts/v2/lib/DepositContractBase.sol</code><br><code>contracts/v2/lib/DepositContractV2.sol</code><br><code>contracts/v2/lib/PolygonAccessControlUpgradeable.sol</code><br><code>contracts/v2/lib/PolygonConsensusBase.sol</code><br><code>contracts/v2/lib/PolygonRollupBaseEtrog.sol</code><br><code>contracts/v2/previousVersions/PolygonRollupBaseEtrogPrevious.sol</code><br><code>contracts/v2/previousVersions/PolygonRollupManagerPrevious.sol</code><br><code>contracts/v2/previousVersions/PolygonRollupManagerPreviousV1toV2.sol</code><br><code>contracts/v2/previousVersions/pessimistic/BridgeL2SovereignChainPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/DepositContractBasePessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/GlobalExitRootManagerL2SovereignChainPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/IBridgeL2SovereignChainsPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonConsensusBasePessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonRollupBaseEtrogPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonRollupManagerPessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonZkEVMBridgeV2Pessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonZkEVMGlobalExitRootL2Pessimistic.sol</code><br><code>contracts/v2/previousVersions/pessimistic/PolygonZkEVMGlobalExitRootV2Pessimistic.sol</code><br><code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code><br><code>deployment/v2/utils/updateVanillaGenesis.ts</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/releases/tag/v10.1.0-rc.1"><code>2fa3db7365d6f6580d507c4e5cb1a9a79ee2cd7a</code></a> (tag <code>v10.1.0-rc.1</code>) | May 2, 2025 | <code>contracts/v2/interfaces/ITokenWrappedBridgeUpgradeable.sol</code><br><code>contracts/v2/lib/BytecodeStorer.sol</code><br><code>contracts/v2/lib/TokenWrappedBridgeUpgradeable.sol</code><br><code>contracts/v2/lib/TokenWrappedTransparentProxy.sol</code><br><code>contracts/v2/previousVersions/pessimistic/IPolygonZkEVMBridgeV2Pessimistic.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/v10.1.0-rc.4"><code>07b40c26ae748c47a2a51f8159990ad4163c4d43</code></a> (tag <code>v10.1.0-rc.4</code>) | May 16, 2025 | <code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/lib/BytecodeStorer.sol</code><br><code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>deployment/v2/utils/updateVanillaGenesis.ts</code> |

## AggLayer v0.3.0 - Offchain Updates Security Assessment Report, Part 1 (v2.0)

- Report: [2025_07-sigmaprime-polygon-agglayer-v0.3.0-offchain-updates-part-1.md](<reports/2025_07-sigmaprime-polygon-agglayer-v0.3.0-offchain-updates-part-1.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of the AggLayer v0.3.0 Rust code: the pessimistic proof crates at agglayer v0.3.0-rc.6, the node crates at v0.3.0-rc.7 and the aggchain-proof-program, prover-engine and prover-executor crates of provers v0.1.0-rc.4; this part reports the pessimistic proof findings. The review found 2 Medium, 3 Low and 3 Informational issues, with fixes in agglayer, provers and interop pull requests.

### Repository: <a href="https://github.com/agglayer/agglayer"><code>agglayer/agglayer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer/releases/tag/v0.3.0-rc.6"><code>d7b3dd1c283d5e1744a6d8124c85a9e10e313f15</code></a> (tag <code>v0.3.0-rc.6</code>) | March 12, 2025 | <code>crates/pessimistic-proof-program</code> (recursive directory)<br><code>crates/pessimistic-proof-core</code> (recursive directory)<br><code>crates/pessimistic-proof</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/4d471b6fcb3d77f743b3037415eb0eac17d9eef8"><code>4d471b6fcb3d77f743b3037415eb0eac17d9eef8</code></a> | March 21, 2025 | <code>crates/pessimistic-proof-core</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/releases/tag/v0.3.0-rc.7"><code>f084ad78b67afa4eca3f00cac6662c956990ecb4</code></a> (tag <code>v0.3.0-rc.7</code>) | March 27, 2025 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory)<br><code>crates/agglayer-storage</code> (recursive directory)<br><code>crates/agglayer-grpc-api</code> (recursive directory)<br><code>crates/agglayer-node</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/a1f6bf2fe01e01f82b29a79fec677d4eb79ff592"><code>a1f6bf2fe01e01f82b29a79fec677d4eb79ff592</code></a> | May 15, 2025 | <code>crates/pessimistic-proof-program</code> (recursive directory) |

### Repository: <a href="https://github.com/agglayer/provers"><code>agglayer/provers</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/provers/tree/d7c432072e3f04441dba8036e4f916a6f6062021"><code>d7c432072e3f04441dba8036e4f916a6f6062021</code></a> (tag <code>v0.1.0-rc.4</code>) | March 27, 2025 | <code>crates/aggchain-proof-program</code> (recursive directory)<br><code>crates/prover-engine</code> (recursive directory)<br><code>crates/prover-executor</code> (recursive directory) |
| <a href="https://github.com/agglayer/provers/commit/ce9b6f715298c7813c4f19f9e5c2c12d1b3746ac"><code>ce9b6f715298c7813c4f19f9e5c2c12d1b3746ac</code></a> | May 15, 2025 | <code>crates/aggchain-proof-program</code> (recursive directory) |

### Repository: <a href="https://github.com/agglayer/interop"><code>agglayer/interop</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/interop/commit/c2f29f221e7500fc7ad132c72ba9a8f6adb0a8f0"><code>c2f29f221e7500fc7ad132c72ba9a8f6adb0a8f0</code></a> | May 19, 2025 | <code>crates/unified-bridge</code> (recursive directory) |
| <a href="https://github.com/agglayer/interop/commit/e2d55a320d984671b21a771f94abf5f4a18b9c42"><code>e2d55a320d984671b21a771f94abf5f4a18b9c42</code></a> | May 23, 2025 | <code>crates/unified-bridge</code> (recursive directory) |

## AggLayer v0.3.0 - Offchain Updates Security Assessment Report, Part 2 (v2.0)

- Report: [2025_07-sigmaprime-polygon-agglayer-v0.3.0-offchain-updates-part-2.md](<reports/2025_07-sigmaprime-polygon-agglayer-v0.3.0-offchain-updates-part-2.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of the agglayer node crates (certificate orchestrator, storage, gRPC API, node) at v0.3.0-rc.7 and of the aggchain-proof-program, prover-engine and prover-executor crates of provers v0.1.0-rc.4. The review found 2 Medium, 12 Low and 8 Informational issues, all located in the node and prover service crates.

### Repository: <a href="https://github.com/agglayer/agglayer"><code>agglayer/agglayer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer/releases/tag/v0.3.0-rc.7"><code>f084ad78b67afa4eca3f00cac6662c956990ecb4</code></a> (tag <code>v0.3.0-rc.7</code>) | March 27, 2025 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory)<br><code>crates/agglayer-storage</code> (recursive directory)<br><code>crates/agglayer-grpc-api</code> (recursive directory)<br><code>crates/agglayer-node</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/14af9ee36562fee8ca5546fc16a997f58e73d743"><code>14af9ee36562fee8ca5546fc16a997f58e73d743</code></a> | May 21, 2025 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory) |
| <a href="https://github.com/agglayer/agglayer/commit/dda24ddc914b360a44887da72373d57802e70c8e"><code>dda24ddc914b360a44887da72373d57802e70c8e</code></a> | June 25, 2025 | <code>crates/agglayer-certificate-orchestrator</code> (recursive directory) |

### Repository: <a href="https://github.com/agglayer/provers"><code>agglayer/provers</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/provers/tree/d7c432072e3f04441dba8036e4f916a6f6062021"><code>d7c432072e3f04441dba8036e4f916a6f6062021</code></a> (tag <code>v0.1.0-rc.4</code>) | March 27, 2025 | <code>crates/aggchain-proof-program</code> (recursive directory)<br><code>crates/prover-engine</code> (recursive directory)<br><code>crates/prover-executor</code> (recursive directory) |
| <a href="https://github.com/agglayer/provers/commit/60bf8d44ee76a4bb57275a58ad200ccc98d24267"><code>60bf8d44ee76a4bb57275a58ad200ccc98d24267</code></a> | May 23, 2025 | <code>crates/prover-engine</code> (recursive directory) |
| <a href="https://github.com/agglayer/provers/commit/6265af9fc44867c20116d73c303fe9cdc2cbfd90"><code>6265af9fc44867c20116d73c303fe9cdc2cbfd90</code></a> | May 23, 2025 | <code>crates/prover-executor</code> (recursive directory) |
| <a href="https://github.com/agglayer/provers/commit/4b10f3216861bb0a3b02bb0e4f132009e9af1ba0"><code>4b10f3216861bb0a3b02bb0e4f132009e9af1ba0</code></a> | May 23, 2025 | <code>crates/prover-executor</code> (recursive directory) |
| <a href="https://github.com/agglayer/provers/commit/9065b501266e831172253c853206823eb3e44a0c"><code>9065b501266e831172253c853206823eb3e44a0c</code></a> | May 26, 2025 | <code>crates/prover-engine</code> (recursive directory) |
| <a href="https://github.com/agglayer/provers/commit/6d7b12f4b29fc95063ae908b98ea6d0505c96b4a"><code>6d7b12f4b29fc95063ae908b98ea6d0505c96b4a</code></a> | May 27, 2025 | <code>crates/prover-engine</code> (recursive directory) |
| <a href="https://github.com/agglayer/provers/pull/235"><code>#235</code></a> (unresolved pull request) | — | <code>crates/prover-engine</code> (recursive directory) |

## PR 478 Changes Review Security Assessment Report (v2.0)

- Report: [2025_07-sigmaprime-polygon-pr-478-changes-zkevm-to-pp-migration.md](<reports/2025_07-sigmaprime-polygon-pr-478-changes-zkevm-to-pp-migration.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of the Solidity changes in agglayer-contracts PR #478, which lets PolygonRollupManager migrate state-transition (zkEVM) rollups to pessimistic-proof rollups, with fixes assessed at tag v11.0.0-rc.2. The review found 3 Informational issues.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/tree/v11.0.0-rc.2"><code>fcb5121b1170f4237992abc1a9f0d92b3e285996</code></a> (tag <code>v11.0.0-rc.2</code>) | July 3, 2025 | <code>contracts/v2/PolygonRollupManager.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/pull/478"><code>#478</code></a> (unresolved pull request) | — | <code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/consensus/pessimistic/PolygonPessimisticConsensus.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupManager.sol</code><br><code>contracts/v2/newDeployments/PolygonRollupManagerNotUpgraded.sol</code> |

## AggOracleCommittee Contract Security Assessment Report (v2.0)

- Report: [2025_08-sigmaprime-polygon-aggoraclecommittee.md](<reports/2025_08-sigmaprime-polygon-aggoraclecommittee.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of the AggOracleCommittee sovereign-chain contract and its genesis/deployment scripts in agglayer-contracts at commit dc5bb8c. The review found 2 Medium and 1 Low issues, all closed without code changes.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/commit/dc5bb8cc083f1e47b78ba3da836cd06384c0bc64"><code>dc5bb8cc083f1e47b78ba3da836cd06384c0bc64</code></a> | August 1, 2025 | <code>contracts/v2/sovereignChains/AggOracleCommittee.sol</code><br><code>deployment/v2/utils/updateVanillaGenesis.ts</code><br><code>tools/createSovereignGenesis/create-sovereign-genesis.ts</code><br><code>tools/deployAggOracleCommittee/deployAggOracleCommittee.ts</code> |

## Agglayer Contracts v0.3.5 Security Assessment Report (v2.0)

- Report: [2025_09-sigmaprime-polygon-agglayer-contracts-v0.3.5.md](<reports/2025_09-sigmaprime-polygon-agglayer-contracts-v0.3.5.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of the agglayer-contracts smart contract changes between v11.0.0-rc.3 and v12.1.0-rc.3 (outpost chains, ECDSA multisig aggchain, AggOracleCommittee, BridgeLib, backwardLET) and the deployOutpostChain.ts script, with fixes assessed at v12.1.0-rc.4. The review found 1 Medium, 2 Low and 5 Informational issues.

### Repository: <a href="https://github.com/agglayer/agglayer-contracts"><code>agglayer/agglayer-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/agglayer-contracts/compare/v11.0.0-rc.3...v12.1.0-rc.3"><code>4e1e07dd83f822b9a05d1cf45bc15d0341e3a2b3…e2a68464f2f34a759731089ed26d2769fce1c2d3</code></a> (commit range) | July 14, 2025 – September 5, 2025 | <code>contracts/v2/AggLayerGateway.sol</code><br><code>contracts/v2/PolygonRollupManager.sol</code><br><code>contracts/v2/PolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/PolygonZkEVMGlobalExitRootV2.sol</code><br><code>contracts/v2/aggchains/AggchainFEP.sol</code><br><code>contracts/v2/interfaces/IAggLayerGateway.sol</code><br><code>contracts/v2/interfaces/IAggchainBase.sol</code><br><code>contracts/v2/interfaces/IBridgeL2SovereignChains.sol</code><br><code>contracts/v2/interfaces/IGlobalExitRootManagerL2SovereignChain.sol</code><br><code>contracts/v2/interfaces/IPolygonConsensusBase.sol</code><br><code>contracts/v2/interfaces/IPolygonRollupManager.sol</code><br><code>contracts/v2/interfaces/IPolygonZkEVMBridgeV2.sol</code><br><code>contracts/v2/lib/AggchainBase.sol</code><br><code>contracts/v2/lib/DepositContractBase.sol</code><br><code>contracts/v2/lib/PolygonConsensusBase.sol</code><br><code>contracts/v2/previousVersions/10.1.0/BridgeL2SovereignChainV1010.sol</code><br><code>contracts/v2/sovereignChains/BridgeL2SovereignChain.sol</code><br><code>contracts/v2/sovereignChains/GlobalExitRootManagerL2SovereignChain.sol</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/releases/tag/v12.1.0-rc.3"><code>e2a68464f2f34a759731089ed26d2769fce1c2d3</code></a> (tag <code>v12.1.0-rc.3</code>) | September 5, 2025 | <code>contracts/v2/aggchains/AggchainECDSAMultisig.sol</code><br><code>contracts/v2/interfaces/IAggOracleCommittee.sol</code><br><code>contracts/v2/interfaces/IAggchainSigners.sol</code><br><code>contracts/v2/interfaces/IVersion.sol</code><br><code>contracts/v2/lib/BridgeLib.sol</code><br><code>contracts/v2/previousVersions/10.1.0/IBridgeL2SovereignChainsV1010.sol</code><br><code>contracts/v2/previousVersions/10.1.0/IPolygonZkEVMBridgeV2V1010.sol</code><br><code>contracts/v2/previousVersions/10.1.0/PolygonZkEVMBridgeV2V1010.sol</code><br><code>contracts/v2/previousVersions/aggchain/AggchainBasePrevious.sol</code><br><code>contracts/v2/previousVersions/aggchain/AggchainFEPPrevious.sol</code><br><code>contracts/v2/previousVersions/aggchain/AgglayerGatewayPrevious.sol</code><br><code>contracts/v2/previousVersions/aggchain/IAggLayerGatewayPrevious.sol</code><br><code>contracts/v2/previousVersions/aggchain/IAggchainBasePrevious.sol</code><br><code>contracts/v2/sovereignChains/AggOracleCommittee.sol</code><br><code>tools/deployOutpostChain/deployOutpostChain.ts</code> |
| <a href="https://github.com/agglayer/agglayer-contracts/releases/tag/v12.1.0-rc.4"><code>26c2d38fcd30e1afc289c3927a816873e809ca6b</code></a> (tag <code>v12.1.0-rc.4</code>) | September 24, 2025 | <code>tools/deployOutpostChain/deployOutpostChain.ts</code><br><code>contracts/AgglayerBridge.sol</code><br><code>contracts/AgglayerGateway.sol</code><br><code>contracts/lib/BridgeLib.sol</code> |

## Irrelevant reports

### Agglayer Exit Tool Security Assessment Report (v2.1)

- Report: [irrelevant/2026_07-sigmaprime-polygon-agglayer-exit-tool.md](<reports/irrelevant/2026_07-sigmaprime-polygon-agglayer-exit-tool.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime review of the offchain Go exit-certificate tool in aggkit (tools/exit_certificate, its bridgesyncerlite and cmd) at commit 3cb76fb with fixes at 30470c1, a standalone CLI that scans L2 state and builds, signs and submits an Agglayer certificate letting a chain exit the Agglayer. The scope is offchain, one-time tooling only.
