# Audit source summary: facet

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Facet ZK Fault Proof Rollup Security Review

- Report: [Cantina_Facet_ZK_Fault_Proofs_Report.md](<reports/Cantina_Facet_ZK_Fault_Proofs_Report.md>)
- Auditor: Cantina (Slowfi, solo review)
- Date: 2025-08-05
- Description: Cantina solo security review (July 28-29, 2025) of the Facet ZK fault-proof rollup contract contracts/src/Rollup.sol in 0xFacet/zk-fault-proofs at commit e85de243, covering proposal submission, challenge and canonical-resolution logic together with the fixes landed in PR 23. Ten issues were reported, all Gas Optimization or Informational, and L1Bridge.sol was explicitly treated as out of scope.

### Repository: <a href="https://github.com/0xFacet/zk-fault-proofs"><code>0xFacet/zk-fault-proofs</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xFacet/zk-fault-proofs/blob/e85de24364443e62d3d630c6da11783a8cf01af9/contracts/src/Rollup.sol"><code>e85de24364443e62d3d630c6da11783a8cf01af9</code></a> | July 24, 2025 | <code>contracts/src/Rollup.sol</code><br><code>contracts/src/L1Bridge.sol</code> (explicitly not audited) |
| <a href="https://github.com/0xFacet/zk-fault-proofs/blob/7bdb8b1413347bdd5701153859029e1b5dece6ff/contracts/src/Rollup.sol"><code>7bdb8b1413347bdd5701153859029e1b5dece6ff</code></a> | July 30, 2025 | <code>contracts/src/Rollup.sol</code> |
| <a href="https://github.com/0xFacet/zk-fault-proofs/blob/55daecb973e04f330c77bbba7eab3df2f3a9df2c/contracts/src/Rollup.sol"><code>55daecb973e04f330c77bbba7eab3df2f3a9df2c</code></a> | July 30, 2025 | <code>contracts/src/Rollup.sol</code> |
| <a href="https://github.com/0xFacet/zk-fault-proofs/blob/c6e01504e11f325c423ceffdb024e1735d37c6c8/contracts/src/Rollup.sol"><code>c6e01504e11f325c423ceffdb024e1735d37c6c8</code></a> | July 31, 2025 | <code>contracts/src/Rollup.sol</code> |
| <a href="https://github.com/0xFacet/zk-fault-proofs/blob/5bdd9147ee9a11cc81b74a38fc0d1497a47a8852/contracts/src/Rollup.sol"><code>5bdd9147ee9a11cc81b74a38fc0d1497a47a8852</code></a> | July 31, 2025 | <code>contracts/src/Rollup.sol</code> |

## Facet Bridge Smart Contract Security Assessment

- Report: [Zellic_Facet_Bridge_Audit_Report.md](<reports/Zellic_Facet_Bridge_Audit_Report.md>)
- Auditor: Zellic
- Date: 2024-11-04
- Description: Zellic assessment (October 17-23, 2024) of the Facet bridge in 0xFacet/facet-optimism at commit 331bb685, covering the L1 and L2 standard bridge, cross-domain messenger, OptimismPortal and supporting libraries plus the op-node driver, status and sync files that deviate from Optimism. No Critical, High, Medium or Low findings were reported; the single informational finding concerned a deploy script.

### Repository: <a href="https://github.com/0xFacet/facet-optimism"><code>0xFacet/facet-optimism</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xFacet/facet-optimism/blob/331bb685d91447e76b79aee34fea5d668a77e925/op-node/rollup/driver/state.go"><code>331bb685d91447e76b79aee34fea5d668a77e925</code></a> | October 2, 2024 | <code>op-node/rollup/driver/state.go</code><br><code>op-node/rollup/engine/events.go</code><br><code>op-node/rollup/status/status.go</code><br><code>op-node/rollup/sync/start.go</code><br><code>op-node/service.go</code><br><code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/src/L2/L2StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L2/L2ToL1MessagePasser.sol</code><br><code>packages/contracts-bedrock/src/libraries/Constants.sol</code><br><code>packages/contracts-bedrock/src/libraries/GasPayingToken.sol</code><br><code>packages/contracts-bedrock/src/libraries/LibFacet.sol</code><br><code>packages/contracts-bedrock/src/universal/StandardBridge.sol</code><br><code>packages/contracts-bedrock/scripts/getting-started/config.sh</code> |
| <a href="https://github.com/0xFacet/facet-optimism/blob/10d1a7971af7c066969038d20661a10474c05d72/packages/contracts-bedrock/src/L1/L1StandardBridge.sol"><code>10d1a7971af7c066969038d20661a10474c05d72</code></a> | October 17, 2024 | <code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/universal/StandardBridge.sol</code> |
| <a href="https://github.com/0xFacet/facet-optimism/blob/89ebb6e63fbf246ea2ff967edb4e3970810de74a/packages/contracts-bedrock/scripts/getting-started/config.sh"><code>89ebb6e63fbf246ea2ff967edb4e3970810de74a</code></a> | November 7, 2024 | <code>packages/contracts-bedrock/scripts/getting-started/config.sh</code> |

### Repository: <a href="https://github.com/0xFacet/facet-node"><code>0xFacet/facet-node</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xFacet/facet-node/blob/f7c6ea669522efd437c92a3f36fae057c73e4bbf/contracts/src/libraries/FacetERC20.sol"><code>f7c6ea669522efd437c92a3f36fae057c73e4bbf</code></a> | October 28, 2024 | <code>contracts/src/libraries/FacetERC20.sol</code> (explicitly not audited) |

## Facet Geth Blockchain Security Assessment

- Report: [Zellic_Facet_Geth_Audit_Report.md](<reports/Zellic_Facet_Geth_Audit_Report.md>)
- Auditor: Zellic
- Date: 2024-09-22
- Description: Zellic assessment (September 5-9, 2024) of the Facet Geth execution client (0xFacet/facet-geth) at commit 06b5f6e0, focusing on the deviations from op-geth that could freeze or leak L2 assets or halt the chain. One Critical finding, a panic in the newly added sqrtWithFloatPrecision precompile in core/vm/contracts.go, was reported and later remediated by removing the precompile.

### Repository: <a href="https://github.com/0xFacet/facet-geth"><code>0xFacet/facet-geth</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xFacet/facet-geth/blob/06b5f6e039ccd79c34c3fb01333d3ccbc8b952db/core/vm/contracts.go"><code>06b5f6e039ccd79c34c3fb01333d3ccbc8b952db</code></a> | August 27, 2024 | <code>core/vm/contracts.go</code> |
| <a href="https://github.com/0xFacet/facet-geth/blob/bf0753a1f66c7c32f8a819e2e7e27187a3db28b1/core/vm/contracts.go"><code>bf0753a1f66c7c32f8a819e2e7e27187a3db28b1</code></a> | September 9, 2024 | <code>core/vm/contracts.go</code> |
| <a href="https://github.com/0xFacet/facet-geth/blob/c82cc6e60833cf1ba2040d0bd6145e6586f3e08e/core/vm/contracts.go"><code>c82cc6e60833cf1ba2040d0bd6145e6586f3e08e</code></a> | October 15, 2024 | <code>core/vm/contracts.go</code> |

## Facet Node Comprehensive Security Assessment

- Report: [Zellic_Facet_Node_Audit_Report.md](<reports/Zellic_Facet_Node_Audit_Report.md>)
- Auditor: Zellic
- Date: 2024-11-05
- Description: Zellic assessment (September 30 - October 7, 2024) of the Facet node in 0xFacet/facet-node at commit 75877a54, covering L1 block import, Facet transaction derivation, the L1 attributes transaction and the FCT gas-token mint calculator. Two Medium findings in RLP decoding of Facet transactions were reported, and a scope extension reviewed the revised FCT mint mechanism together with L1Block.sol and op-node&#x27;s l1_block_info.go.

### Repository: <a href="https://github.com/0xFacet/facet-node"><code>0xFacet/facet-node</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xFacet/facet-node/blob/75877a548c3b515cb8d08e8920016dcfa2523bee/app/models/eth_block.rb"><code>75877a548c3b515cb8d08e8920016dcfa2523bee</code></a> | October 1, 2024 | <code>app/models/eth_block.rb</code><br><code>app/models/eth_call_struct.rb</code><br><code>app/models/eth_transaction.rb</code><br><code>app/models/facet_block.rb</code><br><code>app/models/facet_transaction.rb</code><br><code>app/models/predeploy_manager.rb</code><br><code>lib/eth_block_importer.rb</code><br><code>lib/geth_client.rb</code><br><code>lib/geth_driver.rb</code><br><code>lib/l1_attributes_tx_calldata.rb</code><br><code>lib/transaction_helper.rb</code><br><code>lib/sys_config.rb</code><br><code>lib/chain_id_manager.rb</code><br><code>lib/address_alias_helper.rb</code><br><code>lib/fct_mint_calculator.rb</code> |
| <a href="https://github.com/0xFacet/facet-node/blob/65287c618ca2896019350a239d0ad3c2e79199d0/app/models/facet_transaction.rb"><code>65287c618ca2896019350a239d0ad3c2e79199d0</code></a> | October 15, 2024 | <code>app/models/facet_transaction.rb</code> |
| <a href="https://github.com/0xFacet/facet-node/blob/e7f7fe8682396e695a55c3ce02cd4201d71ab27b/app/models/facet_transaction.rb"><code>e7f7fe8682396e695a55c3ce02cd4201d71ab27b</code></a> | October 21, 2024 | <code>app/models/facet_transaction.rb</code> |
| <a href="https://github.com/0xFacet/facet-node/blob/a18f6f78e981732d24a6a0b1881646bde6cd964f/lib/l1_attributes_tx_calldata.rb"><code>a18f6f78e981732d24a6a0b1881646bde6cd964f</code></a> | October 24, 2024 | <code>lib/l1_attributes_tx_calldata.rb</code><br><code>lib/fct_mint_calculator.rb</code> |
| <a href="https://github.com/0xFacet/facet-node/blob/bbe541291f20f2605c777040e09a4cea0bfe68f5/lib/l1_attributes_tx_calldata.rb"><code>bbe541291f20f2605c777040e09a4cea0bfe68f5</code></a> | October 28, 2024 | <code>lib/l1_attributes_tx_calldata.rb</code><br><code>lib/fct_mint_calculator.rb</code> |
| <a href="https://github.com/0xFacet/facet-node/blob/fa791b625c33fbf38331fe7b660cbcb75e40269b/lib/fct_mint_calculator.rb"><code>fa791b625c33fbf38331fe7b660cbcb75e40269b</code></a> | November 4, 2024 | <code>lib/fct_mint_calculator.rb</code> |
| <a href="https://github.com/0xFacet/facet-node/blob/64bc9f90d75da180bb32f7cf71881e1da917fcb6/lib/l1_attributes_tx_calldata.rb"><code>64bc9f90d75da180bb32f7cf71881e1da917fcb6</code></a> | November 6, 2024 | <code>lib/l1_attributes_tx_calldata.rb</code><br><code>lib/fct_mint_calculator.rb</code> |

### Repository: <a href="https://github.com/0xFacet/facet-geth"><code>0xFacet/facet-geth</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xFacet/facet-geth/blob/ca19563e0560a68b5c2a9e9de56cc22e8dee14d8/core/types/rollup_cost.go"><code>ca19563e0560a68b5c2a9e9de56cc22e8dee14d8</code></a> | October 28, 2024 | <code>core/types/rollup_cost.go</code> |

### Repository: <a href="https://github.com/0xFacet/facet-optimism"><code>0xFacet/facet-optimism</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xFacet/facet-optimism/blob/3bb8307d68ae130c21a2274f8178b5f502b307d2/packages/contracts-bedrock/src/L2/L1Block.sol"><code>3bb8307d68ae130c21a2274f8178b5f502b307d2</code></a> | October 28, 2024 | <code>packages/contracts-bedrock/src/L2/L1Block.sol</code> |
| <a href="https://github.com/0xFacet/facet-optimism/blob/7bd9331b24e23879ebe5f6ebcb85447aaea7baac/packages/contracts-bedrock/src/L2/L1Block.sol"><code>7bd9331b24e23879ebe5f6ebcb85447aaea7baac</code></a> | October 30, 2024 | <code>packages/contracts-bedrock/src/L2/L1Block.sol</code><br><code>op-node/rollup/derive/l1_block_info.go</code> |

## Irrelevant reports

### Facet Migrations Smart Contract Security Assessment

- Report: [irrelevant/Zellic_Facet_Migrations_Audit_Report.md](<reports/irrelevant/Zellic_Facet_Migrations_Audit_Report.md>)
- Auditor: Zellic
- Date: 2024-10-21
- Description: Zellic assessment (October 14-15, 2024, extended November 4-7, 2024) of the legacy FacetSwap pair, factory and router contracts in 0xFacet/facet-node and of the final Facet v0 to v1 migration stage executed once by the MigrationManager predeploy to emit events for offchain indexers. The entire scope is one-time migration logic and the migrated legacy FacetSwap application contracts, so no rollup protocol, bridge or proof code is covered.
