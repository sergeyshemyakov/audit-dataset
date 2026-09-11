# Audit source summary: lighter

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Audit of Lighter&#x27;s Block Circuits

- Report: [zkSecurity - Lighter Block Circuits.md](<reports/zkSecurity - Lighter Block Circuits.md>)
- Auditor: zkSecurity
- Date: 2025-08-04
- Description: zkSecurity review of Lighter&#x27;s Plonky2 prover circuits: all top-level circuits in circuit/src, the types and transactions modules and the unsafe_big bigint gadget, covering block pre-execution, transaction processing, matching and liquidation logic. The report states no commit; the audited revision is taken from the diff base named in the follow-up Block and Delta report.

### Repository: <a href="https://github.com/elliottech/lighter-prover"><code>elliottech/lighter-prover</code></a>

_Commit dates unavailable: 9 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/elliottech/lighter-prover/tree/4876a50/circuit/src"><code>4876a50</code></a> | — | <code>circuit/src</code> (recursive directory)<br><code>circuit/src/types</code> (recursive directory)<br><code>circuit/src/transactions</code> (recursive directory)<br><code>circuit/src/bigint/unsafe_big/mod.rs</code> |

## Audit of Lighter&#x27;s Block and Delta Layers

- Report: [zkSecurity - Lighter Block and Delta Layers.md](<reports/zkSecurity - Lighter Block and Delta Layers.md>)
- Auditor: zkSecurity
- Date: 2025-09-08
- Description: zkSecurity follow-up review of the Plonky2 prover covering the changes between commits 4876a50 and b119f03 (account delta tree feature) and the delta, recursion, bigint, hints and comparison modules of circuit/src. Fixes for the High findings were verified in commits b99c425, 6c75178 and 7f9fdc9 of the lighter-prover repository; the wrapper layer was explicitly deferred.

### Repository: <a href="https://github.com/elliottech/lighter-prover"><code>elliottech/lighter-prover</code></a>

_Commit dates unavailable: 9 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/elliottech/lighter-prover/compare/4876a50...b119f03"><code>4876a50…b119f03</code></a> (commit range) | — | <code>circuit/src</code> (recursive directory) |
| <a href="https://github.com/elliottech/lighter-prover/tree/b119f03/circuit/src/delta"><code>b119f03</code></a> | — | <code>circuit/src/delta</code> (recursive directory)<br><code>circuit/src/recursion</code> (recursive directory)<br><code>circuit/src/bigint</code> (recursive directory)<br><code>circuit/src/hints</code> (recursive directory)<br><code>circuit/src/comparison</code> (recursive directory)<br><code>circuit/src/recursion/wrapper_circuit.rs</code> (explicitly not audited)<br><code>circuit/src/blob</code> (recursive directory) (explicitly not audited) |
| <a href="https://github.com/elliottech/lighter-prover/tree/b99c425b8c0868501e65e78fd16aaf16bbe0ea2b/circuit/src"><code>b99c425b8c0868501e65e78fd16aaf16bbe0ea2b</code></a> | — | <code>circuit/src</code> (recursive directory)<br><code>circuit/src/bigint</code> (recursive directory)<br><code>circuit/src/hints</code> (recursive directory) |
| <a href="https://github.com/elliottech/lighter-prover/tree/6c75178492c6c936706d0c61d7e80b5539f43e24/circuit/src/bigint"><code>6c75178492c6c936706d0c61d7e80b5539f43e24</code></a> | — | <code>circuit/src/bigint</code> (recursive directory)<br><code>circuit/src/hints</code> (recursive directory) |
| <a href="https://github.com/elliottech/lighter-prover/tree/7f9fdc9439d47a0cb1beef6e2879e8a47b5a77e8/circuit/src/bigint"><code>7f9fdc9439d47a0cb1beef6e2879e8a47b5a77e8</code></a> | — | <code>circuit/src/bigint</code> (recursive directory)<br><code>circuit/src/hints</code> (recursive directory) |

## Audit of Lighter&#x27;s Wrapper Circuits

- Report: [zkSecurity - Lighter Wrapper Circuits.md](<reports/zkSecurity - Lighter Wrapper Circuits.md>)
- Auditor: zkSecurity
- Date: 2025-10-10
- Description: zkSecurity review of the Plonky2 wrapper layer at commit 0028b73 of lighter-prover: WrapperInnerCircuit, WrapperOuterCircuit and WrapperCircuit in recursion/wrapper_circuit.rs and the blob evaluation circuit, bitstream gate and blob polynomial in src/blob. The BLS12-381 code and the Gnark outer circuit were explicitly not covered.

### Repository: <a href="https://github.com/elliottech/lighter-prover"><code>elliottech/lighter-prover</code></a>

_Commit dates unavailable: 9 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/elliottech/lighter-prover/blob/0028b73b1e38de7e7c7e4ad33c7680a39e2c6c90/circuit/src/recursion/wrapper_circuit.rs"><code>0028b73b1e38de7e7c7e4ad33c7680a39e2c6c90</code></a> | — | <code>circuit/src/recursion/wrapper_circuit.rs</code><br><code>circuit/src/blob/blob_constraints.rs</code><br><code>circuit/src/blob/evaluate_bitstream.rs</code><br><code>circuit/src/blob/blob_polynomial.rs</code><br><code>snark</code> (recursive directory) (explicitly not audited) |

## Audit of Lighter&#x27;s Exit Hatch

- Report: [zkSecurity - Lighter Exit Hatch.md](<reports/zkSecurity - Lighter Exit Hatch.md>)
- Auditor: zkSecurity
- Date: 2025-11-05
- Description: zkSecurity review of the desert exit (escape hatch) Plonky2 circuits in desertexit/circuits at commit b99c425 of lighter-prover, together with its witness generator and minor changes to the main transaction circuits. Fixes for the High and Medium findings are stated as commit f6818da on the spot branch.

### Repository: <a href="https://github.com/elliottech/lighter-prover"><code>elliottech/lighter-prover</code></a>

_Commit dates unavailable: 9 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/elliottech/lighter-prover/blob/b99c425b8c0868501e65e78fd16aaf16bbe0ea2b/desertexit/circuits/src/inner_circuit.rs"><code>b99c425b8c0868501e65e78fd16aaf16bbe0ea2b</code></a> | — | <code>desertexit/circuits/src/inner_circuit.rs</code><br><code>desertexit/circuits/src/outer_circuit.rs</code><br><code>desertexit/circuits/src/pubdata_account.rs</code><br><code>desertexit/circuits/src/pubdata_market.rs</code><br><code>desertexit/circuits/src/deserializers.rs</code><br><code>desertexit/witness/utils.go</code><br><code>circuit/src</code> (recursive directory) |
| <a href="https://github.com/elliottech/lighter-prover/blob/f6818da/desertexit/circuits/src/inner_circuit.rs"><code>f6818da</code></a> | — | <code>desertexit/circuits/src/inner_circuit.rs</code><br><code>desertexit/circuits/src/pubdata_account.rs</code><br><code>desertexit/witness/utils.go</code> |

## Audit of Lighter&#x27;s Spot Market Circuits and Multi-Asset Support

- Report: [zkSecurity - Lighter Spot Market Circuits.md](<reports/zkSecurity - Lighter Spot Market Circuits.md>)
- Auditor: zkSecurity
- Date: 2025-11-24
- Description: zkSecurity two-phase review of the Plonky2 prover changes introducing spot markets and multi-asset support: Phase 1 at commit 11c3735 covered the delta circuit, asset management, deposit, withdraw and transfer transactions and supporting types, and Phase 2 at commit b31b173 covered the matching engine, order, market and liquidation transactions plus fixes for Phase 1 findings. Remaining fixes are stated as commit f6818da on the spot branch.

### Repository: <a href="https://github.com/elliottech/lighter-prover"><code>elliottech/lighter-prover</code></a>

_Commit dates unavailable: 9 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/elliottech/lighter-prover/blob/11c373555dd56478ddf7c9fbae27c2c2c4052665/circuit/src/delta/delta_constraints.rs"><code>11c373555dd56478ddf7c9fbae27c2c2c4052665</code></a> | — | <code>circuit/src/delta/delta_constraints.rs</code><br><code>circuit/src/delta/account_delta_full_leaf.rs</code><br><code>circuit/src/delta/utils.rs</code><br><code>circuit/src/transactions/l1_register_asset.rs</code><br><code>circuit/src/transactions/l1_update_asset.rs</code><br><code>circuit/src/transactions/l1_deposit.rs</code><br><code>circuit/src/transactions/l1_withdraw.rs</code><br><code>circuit/src/transactions/l2_withdraw.rs</code><br><code>circuit/src/transactions/l2_transfer.rs</code><br><code>circuit/src/types/account_asset.rs</code><br><code>circuit/src/types/asset.rs</code><br><code>circuit/src/types/constants.rs</code><br><code>circuit/src/tx_constraints.rs</code> |
| <a href="https://github.com/elliottech/lighter-prover/blob/b31b173ced2df143a7289b21df9020bfc664f3f6/circuit/src/delta/delta_constraints.rs"><code>b31b173ced2df143a7289b21df9020bfc664f3f6</code></a> | — | <code>circuit/src/delta/delta_constraints.rs</code><br><code>circuit/src/transactions/l1_register_asset.rs</code><br><code>circuit/src/transactions/l1_update_asset.rs</code><br><code>circuit/src/transactions/l1_deposit.rs</code><br><code>circuit/src/tx_constraints.rs</code><br><code>circuit/src/matching_engine.rs</code><br><code>circuit/src/apply_trade.rs</code><br><code>circuit/src/transactions/l1_create_order.rs</code><br><code>circuit/src/transactions/l2_create_order.rs</code><br><code>circuit/src/transactions/l2_cancel_order.rs</code><br><code>circuit/src/transactions/l2_modify_order.rs</code><br><code>circuit/src/transactions/internal_create_order.rs</code><br><code>circuit/src/transactions/internal_cancel_order.rs</code><br><code>circuit/src/transactions/internal_claim_order.rs</code><br><code>circuit/src/transactions/l1_create_market.rs</code><br><code>circuit/src/transactions/l1_update_market.rs</code><br><code>circuit/src/types/market.rs</code><br><code>circuit/src/transactions/internal_liquidate_position.rs</code><br><code>circuit/src/transactions/internal_deleverage.rs</code><br><code>circuit/src/transactions/internal_exit_position.rs</code><br><code>circuit/src/types/tx_state.rs</code><br><code>circuit/src/types/transfer.rs</code> |
| <a href="https://github.com/elliottech/lighter-prover/blob/f6818da/circuit/src/transactions/l1_deposit.rs"><code>f6818da</code></a> | — | <code>circuit/src/transactions/l1_deposit.rs</code><br><code>circuit/src/types/tx_state.rs</code> |

## NM-0560 Lighter Security Review

- Report: [Nethermind - Lighter Core.md](<reports/Nethermind - Lighter Core.md>)
- Auditor: Nethermind Security
- Date: 2025-09-21
- Description: Nethermind Security review of the zkLighter L1 rollup contracts (ZkLighter, AdditionalZkLighter, governance, proxy and upgrade gatekeeper, libraries and interfaces) in elliottech/lighter-contracts from initial commit 8144649 to final commit 0ddf2bf. One Critical finding in the desert-mode deposit cancellation and one Medium finding were reported and fixed or mitigated.

### Repository: <a href="https://github.com/elliottech/lighter-contracts"><code>elliottech/lighter-contracts</code></a>

_Commit dates unavailable: 8 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/elliottech/lighter-contracts/blob/8144649002307657bdb6d9dd5b78906aea736f00/contracts/DeployFactory.sol"><code>8144649002307657bdb6d9dd5b78906aea736f00</code></a> | — | <code>contracts/DeployFactory.sol</code><br><code>contracts/AdditionalZkLighter.sol</code><br><code>contracts/Config.sol</code><br><code>contracts/Governance.sol</code><br><code>contracts/ZkLighter.sol</code><br><code>contracts/Storage.sol</code><br><code>contracts/UpgradeableMaster.sol</code><br><code>contracts/proxy/Ownable.sol</code><br><code>contracts/proxy/IUpgradeable.sol</code><br><code>contracts/proxy/Proxy.sol</code><br><code>contracts/proxy/UpgradeGatekeeper.sol</code><br><code>contracts/proxy/IUpgradeEvents.sol</code><br><code>contracts/lib/Bytes.sol</code><br><code>contracts/lib/TxTypes.sol</code><br><code>contracts/interfaces/IEvents.sol</code><br><code>contracts/interfaces/IDesertVerifier.sol</code><br><code>contracts/interfaces/IZkLighterDesertMode.sol</code><br><code>contracts/interfaces/IGovernance.sol</code><br><code>contracts/interfaces/IZkLighterVerifier.sol</code><br><code>contracts/interfaces/IZkLighter.sol</code> |
| <a href="https://github.com/elliottech/lighter-contracts/blob/6cd7c8f66d2f719e6162f6b31f552f77c1efefeb/contracts/AdditionalZkLighter.sol"><code>6cd7c8f66d2f719e6162f6b31f552f77c1efefeb</code></a> | — | <code>contracts/AdditionalZkLighter.sol</code> |
| <a href="https://github.com/elliottech/lighter-contracts/blob/25459881a7ac452a24794a6dd3ed90bf9b953df3/contracts/AdditionalZkLighter.sol"><code>25459881a7ac452a24794a6dd3ed90bf9b953df3</code></a> | — | <code>contracts/AdditionalZkLighter.sol</code> |
| <a href="https://github.com/elliottech/lighter-contracts/blob/f4df0ed/contracts/ZkLighter.sol"><code>f4df0ed</code></a> | — | <code>contracts/ZkLighter.sol</code> |
| <a href="https://github.com/elliottech/lighter-contracts/blob/5a8745f76b3c23dbd1579f27d641c4c050b94a75/contracts/UpgradeableMaster.sol"><code>5a8745f76b3c23dbd1579f27d641c4c050b94a75</code></a> | — | <code>contracts/UpgradeableMaster.sol</code> |
| <a href="https://github.com/elliottech/lighter-contracts/blob/0ddf2bfc9ead2c2c98ca04085315304ad0865dbc/contracts/DeployFactory.sol"><code>0ddf2bfc9ead2c2c98ca04085315304ad0865dbc</code></a> | — | <code>contracts/DeployFactory.sol</code><br><code>contracts/AdditionalZkLighter.sol</code><br><code>contracts/Config.sol</code><br><code>contracts/Governance.sol</code><br><code>contracts/ZkLighter.sol</code><br><code>contracts/Storage.sol</code><br><code>contracts/UpgradeableMaster.sol</code><br><code>contracts/proxy/Ownable.sol</code><br><code>contracts/proxy/IUpgradeable.sol</code><br><code>contracts/proxy/Proxy.sol</code><br><code>contracts/proxy/UpgradeGatekeeper.sol</code><br><code>contracts/proxy/IUpgradeEvents.sol</code><br><code>contracts/lib/Bytes.sol</code><br><code>contracts/lib/TxTypes.sol</code><br><code>contracts/interfaces/IEvents.sol</code><br><code>contracts/interfaces/IDesertVerifier.sol</code><br><code>contracts/interfaces/IZkLighterDesertMode.sol</code><br><code>contracts/interfaces/IGovernance.sol</code><br><code>contracts/interfaces/IZkLighterVerifier.sol</code><br><code>contracts/interfaces/IZkLighter.sol</code> |

## Lighter (EVM) Smart Contract Security Assessment (spot markets and multi-asset)

- Report: [Zellic - Lighter EVM Spot Contract Security Assessment.md](<reports/Zellic - Lighter EVM Spot Contract Security Assessment.md>)
- Auditor: Zellic
- Date: 2026-01-21
- Description: Zellic differential review of the zkLighter L1 contracts in elliottech/lighter-contracts for the changes between commits 5cbd2d23 and e6890b14 introducing spot markets and multi-asset support, covering ZkLighter, AdditionalZkLighter, storage, config and library files. Two Medium, one Low and one Informational finding were reported and acknowledged; project-wide finding 3.2 (Medium, insufficient test coverage) is not tied to a file.

### Repository: <a href="https://github.com/elliottech/lighter-contracts"><code>elliottech/lighter-contracts</code></a>

_Commit dates unavailable: 8 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/elliottech/lighter-contracts/compare/5cbd2d23...e6890b14a340321be161fb99d980c71c348541dc"><code>5cbd2d23…e6890b14a340321be161fb99d980c71c348541dc</code></a> (commit range) | — | <code>contracts/ZkLighter.sol</code><br><code>contracts/AdditionalZkLighter.sol</code><br><code>contracts/lib/Bytes.sol</code><br><code>contracts/lib/TxTypes.sol</code><br><code>contracts/ExtendableStorage.sol</code><br><code>contracts/Config.sol</code><br><code>contracts/Storage.sol</code> |

## Lighter (EVM) Smart Contract Security Assessment (migration patch)

- Report: [Zellic - Lighter EVM Migration Security Assessment.md](<reports/Zellic - Lighter EVM Migration Security Assessment.md>)
- Auditor: Zellic
- Date: 2026-06-11
- Description: Zellic differential review of the zkLighter L1 contract refactor between commits 6edc3ff and c768c3e of the private elliottech/lighter-contracts-internal repository, which moved user-facing functions into the new L1CoreMessaging and L1InteropManager contracts and changed ZkLighter to an upgrade-only installation. Three Informational findings were reported and acknowledged; the repository is private but the contracts are the core L1 rollup contracts mirrored in the public lighter-contracts repository.

### Repository: <a href="https://github.com/elliottech/lighter-contracts-internal"><code>elliottech/lighter-contracts-internal</code></a>

_Commit dates unavailable: 2 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/elliottech/lighter-contracts-internal/compare/6edc3ff22099fc98501ebc618bbc19468c7fec07...c768c3eb49f4fc031a7d4b03b50bf37a9e4a69f3"><code>6edc3ff22099fc98501ebc618bbc19468c7fec07…c768c3eb49f4fc031a7d4b03b50bf37a9e4a69f3</code></a> (commit range) | — | <code>contracts/AdditionalZkLighter.sol</code><br><code>contracts/Config.sol</code><br><code>contracts/Constants.sol</code><br><code>contracts/DeployFactory.sol</code><br><code>contracts/DesertVerifier.sol</code><br><code>contracts/ExtendableStorage.sol</code><br><code>contracts/Governance.sol</code><br><code>contracts/interop/L1InteropManager.sol</code><br><code>contracts/interop/TokenInteropLib.sol</code><br><code>contracts/lib/Bytes.sol</code><br><code>contracts/lib/TxTypes.sol</code><br><code>contracts/messaging/L1CoreMessaging.sol</code><br><code>contracts/proxy/Ownable.sol</code><br><code>contracts/proxy/Proxy.sol</code><br><code>contracts/proxy/UpgradeGatekeeper.sol</code><br><code>contracts/Storage.sol</code><br><code>contracts/UpgradeableMaster.sol</code><br><code>contracts/ZkLighter.sol</code><br><code>contracts/ZkLighterStateRootUpgradeVerifier.sol</code><br><code>contracts/ZkLighterVerifier.sol</code><br><code>contracts/tests</code> (recursive directory) (explicitly not audited) |

## Irrelevant reports

### Audit of Lighter&#x27;s zkLighter Circuits

- Report: [irrelevant/zkSecurity - zkLighter Circuits 2024.md](<reports/irrelevant/zkSecurity - zkLighter Circuits 2024.md>)
- Auditor: zkSecurity
- Date: 2024-01-22
- Description: zkSecurity review of the original gnark-based zkLighter main and exit-hatch circuits and the GKR-based MiMC hash, performed on extracted code shared in an unnamed private repository with no commit or file paths stated. The audited gnark circuits were later replaced by the Plonky2 prover and were never published, so no accessible repository path or revision can be identified.

### NM-0620 zkLighter Bridge Security Review

- Report: [irrelevant/Nethermind - Lighter EVM Deposit Bridge.md](<reports/irrelevant/Nethermind - Lighter EVM Deposit Bridge.md>)
- Auditor: Nethermind Security
- Date: 2025-09-22
- Description: Nethermind Security review of the zkLighter CCTP-based cross-chain USDC deposit bridge contracts (TokenBurnerSystemV2, EphemeralTokenBurnerV2, FastCCTPV2) at commits 522de47 to 7d6b776 of the private elliottech/lighter-bridge-contracts repository, reporting five Informational findings. The repository is inaccessible and the deposit relayer contracts are not part of the L1 rollup contracts tracked for Lighter.
