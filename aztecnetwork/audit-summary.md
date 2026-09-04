# Audit source summary: aztecnetwork

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps.

## AZTEC Protocol Audit

- Report: [ConsenSys Diligence - Aztec Protocol v1.md](<reports/ConsenSys Diligence - Aztec Protocol v1.md>)
- Auditor: ConsenSys Diligence
- Date: 2019-04-08
- Description: Smart contract security audit of the AZTEC v1 confidential-asset protocol (ACE, NoteRegistry, JoinSplit validator, ZkAsset variants, ERC20Mintable, LibEIP712) in packages/protocol of AztecProtocol/AZTEC at commit 7a020f4c, with tool-based analysis and a threat model. Zero-knowledge proof algorithms, trusted setup and the underlying mathematics were out of scope.

### Repository: <a href="https://github.com/AztecProtocol/AZTEC"><code>AztecProtocol/AZTEC</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/AZTEC/blob/7a020f4ced9680f6e4a452fe570671aac0802471/packages/protocol/contracts/ZkAsset/ZkAsset.sol"><code>7a020f4ced9680f6e4a452fe570671aac0802471</code></a> | April 8, 2019 | <code>packages/protocol/contracts/ZkAsset/ZkAsset.sol</code><br><code>packages/protocol/contracts/ZkAsset/ZkAssetBurnable.sol</code><br><code>packages/protocol/contracts/ZkAsset/ZkAssetDetailed.sol</code><br><code>packages/protocol/contracts/ZkAsset/ZkAssetMintable.sol</code><br><code>packages/protocol/contracts/ZkAsset/ZkAssetOwnable.sol</code><br><code>packages/protocol/contracts/ZkAsset/ZkAssetOwnableTest.sol</code><br><code>packages/protocol/contracts/ACE/validators/joinSplit/JoinSplit.sol</code><br><code>packages/protocol/contracts/ACE/NoteRegistry.sol</code><br><code>packages/protocol/contracts/ACE/ACE.sol</code><br><code>packages/protocol/contracts/ERC20/ERC20Mintable.sol</code><br><code>packages/protocol/contracts/libs/LibEIP712.sol</code> |
| <a href="https://github.com/AztecProtocol/AZTEC/blob/develop/packages/protocol/contracts/ERC1724/base/ZkAssetMintableBase.sol"><code>develop</code></a> (mutable branch) | — | <code>packages/protocol/contracts/ERC1724/base/ZkAssetMintableBase.sol</code><br><code>packages/protocol/contracts/ERC1724/base/ZkAssetOwnableBase.sol</code> |

## Spilsbury Holdings Ltd Audit Results (AUD461) - Barretenberg

- Report: [Sentnl - Barretenberg.md](<reports/Sentnl - Barretenberg.md>)
- Auditor: Sentnl
- Date: 2022-03-26
- Description: Sentnl differential-fuzzing audit of the Barretenberg C++ cryptographic library (native uint256/uintx arithmetic, BN254/secp256k1/secp256r1 curve operations, ECDSA verification) compared against Botan, libff and libsecp256k1. It reports memory bugs, incorrect arithmetic results and invalid-point handling issues without assigning per-finding severities.

### Repository: <a href="https://github.com/AztecProtocol/barretenberg"><code>AztecProtocol/barretenberg</code></a>

_Commit dates unavailable: 1 commit(s) could not be fetched from https://github.com/AztecProtocol/barretenberg._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/barretenberg/tree/38c8b72e633f58f4e394990da1936ed5fa2ab1ee/barretenberg/src/aztec"><code>38c8b72e633f58f4e394990da1936ed5fa2ab1ee</code></a> | — | <code>barretenberg/src/aztec</code> (recursive directory) |

### Repository: <a href="https://github.com/AztecProtocol/aztec2-internal"><code>AztecProtocol/aztec2-internal</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Aztec Lido Bridge Audit

- Report: [Solidified - Aztec Lido Bridge.md](<reports/Solidified - Aztec Lido Bridge.md>)
- Auditor: Solidified
- Date: 2022-04-12
- Description: Audit of the Aztec Connect Lido bridge (LidoBridge.sol and its Foundry test Lido.t.sol) that wraps ETH into wstETH via Lido or Curve and unwraps back through Curve. One Major issue (unchecked stETH output from Lido) and two Minor issues were reported, all marked Resolved without a fix commit being identified.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/d5aca13d4d0a17b21eeddf77f49f4c6613461fb0/src/bridges/lido/LidoBridge.sol"><code>d5aca13d4d0a17b21eeddf77f49f4c6613461fb0</code></a> | April 7, 2022 | <code>src/bridges/lido/LidoBridge.sol</code><br><code>src/test/lido/Lido.t.sol</code> |

## Aztec Element Bridge Audit

- Report: [Solidified - Aztec Element Bridge.md](<reports/Solidified - Aztec Element Bridge.md>)
- Auditor: Solidified
- Date: 2022-05-11
- Description: Audit of the Aztec Connect Element Finance bridge (ElementBridge.sol, MinHeap.sol and interfaces) that buys fixed-yield tranches via Balancer and redeems them by expiry using a min-heap. One Minor issue was reported and fixed in a follow-up commit; no Critical or Major issues.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/ac2e7194b5887ea11a607b4cf8de0547b3d7fdd0/src/bridges/element/ElementBridge.sol"><code>ac2e7194b5887ea11a607b4cf8de0547b3d7fdd0</code></a> | April 7, 2022 | <code>src/bridges/element/ElementBridge.sol</code><br><code>src/bridges/element/MinHeap.sol</code><br><code>src/bridges/element/interfaces</code> (recursive directory) |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/commit/9aee254f8232c0d4010352871b7819dca3c4dbca"><code>9aee254f8232c0d4010352871b7819dca3c4dbca</code></a> | May 5, 2022 | <code>src/bridges/element/ElementBridge.sol</code> |

## Aztec Set Bridge Audit

- Report: [Solidified - Aztec Set Bridge.md](<reports/Solidified - Aztec Set Bridge.md>)
- Auditor: Solidified
- Date: 2022-05-11
- Description: Audit of the Aztec Connect Set Protocol bridge (IssuanceBridge.sol and interfaces) that issues and redeems Set tokens through ExchangeIssuance. Two Minor issues (zero minimum output and unchecked received amount) were reported; no Critical or Major issues.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/6c295e8e8eb4f1647de4ed8d3fdef7142fb555b7/src/bridges/set/IssuanceBridge.sol"><code>6c295e8e8eb4f1647de4ed8d3fdef7142fb555b7</code></a> | April 14, 2022 | <code>src/bridges/set/IssuanceBridge.sol</code><br><code>src/bridges/set/interfaces</code> (recursive directory) |

## Aztec Aave Bridge Audit

- Report: [Solidified - Aztec Aave Bridge.md](<reports/Solidified - Aztec Aave Bridge.md>)
- Auditor: Solidified
- Date: 2022-05-18
- Description: Audit of the Aztec Connect Aave lending bridge (AaveLendingBridge, configurator, accounting token, Aave imports and interfaces) that deposits into and redeems from Aave via an internal accounting token. Covers src/bridges/aave at a single commit; no Critical or Major issues were found.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/4a377651457e9ecf8c811e28b6a2570ef202f146/src/bridges/aave/AccountingToken.sol"><code>4a377651457e9ecf8c811e28b6a2570ef202f146</code></a> | May 17, 2022 | <code>src/bridges/aave/AccountingToken.sol</code><br><code>src/bridges/aave/imports</code> (recursive directory)<br><code>src/bridges/aave/interfaces</code> (recursive directory)<br><code>src/bridges/aave/lending</code> (recursive directory) |

## Aztec Liquity Bridge Audit

- Report: [Solidified - Aztec Liquity Bridge.md](<reports/Solidified - Aztec Liquity Bridge.md>)
- Auditor: Solidified
- Date: 2022-06-14
- Description: Audit of the Aztec Connect Liquity bridges (TroveBridge, StabilityPoolBridge, StakingBridge and interfaces) that open a shared Trove, deposit to the Stability Pool and stake LQTY on behalf of rollup users. Three Critical issues in the Trove accounting (partial redemption, redistribution, recovery-mode liquidation surplus) were reported and left Pending.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/5a3766115b55dd3471ca981a26c8b8381f12fae7/src/bridges/liquity/interfaces"><code>5a3766115b55dd3471ca981a26c8b8381f12fae7</code></a> | May 31, 2022 | <code>src/bridges/liquity/interfaces</code> (recursive directory)<br><code>src/bridges/liquity/StakingBridge.sol</code><br><code>src/bridges/liquity/TroveBridge.sol</code><br><code>src/bridges/liquity/StabilityPoolBridge.sol</code> |

## Aztec Compound Bridge Audit

- Report: [Solidified - Aztec Compound Bridge.md](<reports/Solidified - Aztec Compound Bridge.md>)
- Auditor: Solidified
- Date: 2022-06-17
- Description: Audit of the Aztec Connect Compound bridge (CompoundBridge.sol and its cToken interfaces) that mints and redeems Compound cTokens for rollup users. One Minor and one Note-level issue were reported; no Critical or Major issues.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/ad5d8d5fa83ae0e1c519e1bdb79adb4caa5aa8c1/src/bridges/compound/CompoundBridge.sol"><code>ad5d8d5fa83ae0e1c519e1bdb79adb4caa5aa8c1</code></a> | June 15, 2022 | <code>src/bridges/compound/CompoundBridge.sol</code><br><code>src/bridges/compound/interfaces</code> (recursive directory) |

## Aztec Curve Bridge Audit

- Report: [Solidified - Aztec Curve Bridge.md](<reports/Solidified - Aztec Curve Bridge.md>)
- Auditor: Solidified
- Date: 2022-07-05
- Description: Audit of the Aztec Connect Curve stETH bridge (CurveStEthBridge.sol) that swaps ETH and stETH/wstETH through the Curve pool. One Minor issue (missing minimum output amount) was reported; no Critical or Major issues.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/3b5edf619ef4d316d4430988b99f6cb0aac6a2b2/src/bridges/curve/CurveStEthBridge.sol"><code>3b5edf619ef4d316d4430988b99f6cb0aac6a2b2</code></a> | July 1, 2022 | <code>src/bridges/curve/CurveStEthBridge.sol</code> |

## Aztec Subsidy Contract Audit

- Report: [Solidified - Aztec Subsidy Contract.md](<reports/Solidified - Aztec Subsidy Contract.md>)
- Auditor: Solidified
- Date: 2022-08-10
- Description: Audit of the Aztec Connect Subsidy.sol contract that lets third parties fund ETH subsidies for bridge interactions, accrued per criteria at a gas-per-minute rate. Three Minor issues and several Notes were reported; no Critical or Major issues.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/80a8b3dbf1b2c5e302fc2613ec7588108269da34/src/aztec/Subsidy.sol"><code>80a8b3dbf1b2c5e302fc2613ec7588108269da34</code></a> | August 8, 2022 | <code>src/aztec/Subsidy.sol</code> |

## Aztec DCA Bridge Audit

- Report: [Solidified - Aztec DCA Bridge.md](<reports/Solidified - Aztec DCA Bridge.md>)
- Auditor: Solidified
- Date: 2022-09-21
- Description: Audit of the Aztec Connect dollar-cost-averaging bridge (BiDCABridge, UniswapDCABridge, SafeCastLib) that matches user orders internally over time ticks and sources remaining liquidity from Uniswap. Two Minor issues were reported and resolved in follow-up commits; no Critical or Major issues.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/f9f2554d63519c1b3288325f5edc50acaac2bbc5/src/bridges/dca/BiDCABridge.sol"><code>f9f2554d63519c1b3288325f5edc50acaac2bbc5</code></a> | September 15, 2022 | <code>src/bridges/dca/BiDCABridge.sol</code><br><code>src/bridges/dca/SafeCastLib.sol</code><br><code>src/bridges/dca/UniswapDCABridge.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/commit/2df45ffd5cd09dc37fd183bf093ad32771660243"><code>2df45ffd5cd09dc37fd183bf093ad32771660243</code></a> | September 15, 2022 | <code>src/bridges/dca/UniswapDCABridge.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/commit/b0b4a19437569bb7b3e1b5fab5fb3cbb86f88bde"><code>b0b4a19437569bb7b3e1b5fab5fb3cbb86f88bde</code></a> | September 15, 2022 | <code>src/bridges/dca/BiDCABridge.sol</code><br><code>src/bridges/dca/UniswapDCABridge.sol</code> |

## Aztec Liquity Trove Bridge Re-Audit

- Report: [Solidified - Aztec Liquity Trove Bridge II.md](<reports/Solidified - Aztec Liquity Trove Bridge II.md>)
- Auditor: Solidified
- Date: 2022-11-21
- Description: Re-audit of the Aztec Connect Liquity TroveBridge.sol after the team reworked the repayment logic following the first Liquity bridge audit. One Critical issue (ETH-deposit attack causing an underflow revert in _repayWithCollateral) was reported and resolved in a follow-up commit.

### Repository: <a href="https://github.com/AztecProtocol/aztec-connect-bridges"><code>AztecProtocol/aztec-connect-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/blob/46af4186f21cd1925d41fd0275883be18755d212/src/bridges/liquity/TroveBridge.sol"><code>46af4186f21cd1925d41fd0275883be18755d212</code></a> | November 12, 2022 | <code>src/bridges/liquity/TroveBridge.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-connect-bridges/commit/89129e99529b0095310d52396a68edf251043a9b"><code>89129e99529b0095310d52396a68edf251043a9b</code></a> | November 18, 2022 | <code>src/bridges/liquity/TroveBridge.sol</code> |

## Audit of Aztec Foreign Field Arithmetic (Bigfield)

- Report: [ZKSecurity - Barretenberg Bigfield.md](<reports/ZKSecurity - Barretenberg Bigfield.md>)
- Auditor: zkSecurity
- Date: 2024-07-01
- Description: zkSecurity line-by-line review (June 10-28, 2024) of the Barretenberg bigfield and field stdlib modules in aztec-packages, using symbolic simplification of custom gate expressions to check non-native field arithmetic soundness. Found 4 High, 4 Medium, 4 Low and 7 Informational issues; developer responses indicate fixes but no fix commits are cited.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/4ba553ba3170838de3b6c4cf47b609b0198443d0"><code>4ba553ba3170838de3b6c4cf47b609b0198443d0</code></a> | June 9, 2024 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield</code> (recursive directory)<br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/field</code> (recursive directory)<br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/ultra_circuit_builder.cpp</code> |

## Barretenberg Bigfield Proof Circuit Security Assessment

- Report: [Zellic - Barretenberg Bigfield.md](<reports/Zellic - Barretenberg Bigfield.md>)
- Auditor: Zellic
- Date: 2024-07-25
- Description: Zellic assessment (June 20 - July 9, 2024) of the Barretenberg bigfield circuits in aztec-packages (bigfield_impl.hpp, bigfield.hpp, constants.hpp), checking that constructors and arithmetic are properly constrained and complete. Found 5 Critical, 2 High, 8 Low and 2 Informational findings; time did not suffice to review all of bigfield_impl.hpp thoroughly and a re-audit was recommended.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/4ba553ba3170838de3b6c4cf47b609b0198443d0"><code>4ba553ba3170838de3b6c4cf47b609b0198443d0</code></a> | June 9, 2024 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/constants.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/ultra_circuit_builder.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.cpp</code> |

## Aztec Packages Security Review (Barretenberg bigfield)

- Report: [Cantina - Barretenberg Bigfield.md](<reports/Cantina - Barretenberg Bigfield.md>)
- Auditor: Cantina
- Date: 2024-10-04
- Description: Cantina Managed review (Sep 4-25, 2024) of the Barretenberg bigfield stdlib primitive in aztec-packages, covering non-native field arithmetic soundness (limb bounds, CRT reasoning, pow, constructors). Found 2 Critical, 1 High, 2 Medium, 2 Low and 10 Informational issues; no fix commits are recorded in the report.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/4ba553ba3170838de3b6c4cf47b609b0198443d0"><code>4ba553ba3170838de3b6c4cf47b609b0198443d0</code></a> | June 9, 2024 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code> |

## Formal Verification Report: Aztec Governance Contracts

- Report: [Igor Konnov, Thomas Pani - Governance Formal Verification.md](<reports/Igor Konnov, Thomas Pani - Governance Formal Verification.md>)
- Auditor: Igor Konnov, Thomas Pani (blltprf.xyz / konnov.phd)
- Date: 2025-09-15
- Description: Formal verification engagement by Igor Konnov and Thomas Pani (final report Sep 15, 2025) of the Aztec Governance protocol contracts in AztecProtocol/aztec-packages (l1-contracts, commit range ffc8af0c to 8b10b2b2), specifying and model-checking Governance, GovernanceProposer, GSE, Registry, RewardDistributor, Slasher and SlashingProposer with Quint and Apalache. The work produced 14 findings including five medium-severity issues alongside verified invariants.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/tree/8b10b2b220de38c9e2e2e2b7d05d7383701ba070/l1-contracts"><code>ffc8af0c47dad3be6fb4bfb9f3f5af6cd3a05a67…8b10b2b220de38c9e2e2e2b7d05d7383701ba070</code></a> (commit range) | June 23, 2025 – August 18, 2025 | <code>l1-contracts/src/governance/CoinIssuer.sol</code><br><code>l1-contracts/src/governance/GSE.sol</code><br><code>l1-contracts/src/governance/Registry.sol</code><br><code>l1-contracts/src/governance/Governance.sol</code><br><code>l1-contracts/src/governance/GSEPayload.sol</code><br><code>l1-contracts/src/governance/RewardDistributor.sol</code><br><code>l1-contracts/src/governance/proposer/EmpireBase.sol</code><br><code>l1-contracts/src/governance/proposer/GovernanceProposer.sol</code><br><code>l1-contracts/src/governance/interfaces/ICoinIssuer.sol</code><br><code>l1-contracts/src/governance/interfaces/IGovernance.sol</code><br><code>l1-contracts/src/governance/interfaces/IPayload.sol</code><br><code>l1-contracts/src/governance/interfaces/IRegistry.sol</code><br><code>l1-contracts/src/governance/interfaces/IEmpire.sol</code><br><code>l1-contracts/src/governance/interfaces/IGovernanceProposer.sol</code><br><code>l1-contracts/src/governance/interfaces/IProposerPayload.sol</code><br><code>l1-contracts/src/governance/interfaces/IRewardDistributor.sol</code><br><code>l1-contracts/src/governance/libraries/AddressSnapshotLib.sol</code><br><code>l1-contracts/src/governance/libraries/ConfigurationLib.sol</code><br><code>l1-contracts/src/governance/libraries/Errors.sol</code><br><code>l1-contracts/src/governance/libraries/CheckpointedUintLib.sol</code><br><code>l1-contracts/src/governance/libraries/DepositDelegationLib.sol</code><br><code>l1-contracts/src/governance/libraries/ProposalLib.sol</code><br><code>l1-contracts/src/core/slashing/Slasher.sol</code><br><code>l1-contracts/src/core/slashing/SlashingProposer.sol</code><br><code>l1-contracts/src/shared/interfaces/IMintableERC20.sol</code><br><code>l1-contracts/src/shared/libraries/BN254Lib.sol</code><br><code>l1-contracts/src/shared/libraries/CompressedTimeMath.sol</code><br><code>l1-contracts/src/shared/libraries/SignatureLib.sol</code><br><code>l1-contracts/src/shared/libraries/TimeMath.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/eb8ca7ab0fa319ed6071370c74d50c5815526f0e"><code>eb8ca7ab0fa319ed6071370c74d50c5815526f0e</code></a> | August 20, 2025 | <code>l1-contracts/src/governance/Governance.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/95c296fb05387e2845065cb46ebffc8ce651f69b"><code>95c296fb05387e2845065cb46ebffc8ce651f69b</code></a> | September 12, 2025 | <code>l1-contracts/src/governance/Governance.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/93976d6357c3a2446387225e92fb2e6546386f0a"><code>93976d6357c3a2446387225e92fb2e6546386f0a</code></a> | September 12, 2025 | <code>l1-contracts/src/governance/proposer/EmpireBase.sol</code> |

## Veridise Auditing Report: Barretenberg Bigfield

- Report: [Veridise - Barretenberg Bigfield.md](<reports/Veridise - Barretenberg Bigfield.md>)
- Auditor: Veridise
- Date: 2025-09-18
- Description: Veridise assessment (July 14 - Aug 1, 2025; V2 Sep 18, 2025 incorporating fixes) of the Barretenberg bigfield library in aztec-packages (bigfield.hpp, bigfield_impl.hpp, bigfield.test.cpp) at commit 480f49d, using manual review, Z3 encoding and Semgrep. Found 3 Low, 3 Warning and 3 Informational issues (no Critical/High) and validated the developers&#x27; fix commits.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/480f49dad314ea4e753ff1e5180992a16926d2b3"><code>480f49dad314ea4e753ff1e5180992a16926d2b3</code></a> | July 14, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/README.md</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/d67c99bafd7d80678bdb3bb64aeb3711d835d7fb"><code>d67c99bafd7d80678bdb3bb64aeb3711d835d7fb</code></a> | September 8, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.test.cpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/a51b732b09ac4d03df6da1af8eee4d11ffbe6aab"><code>a51b732b09ac4d03df6da1af8eee4d11ffbe6aab</code></a> | September 8, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/2953d499808807b8bdf9ab1a60adeb476f5a575a"><code>2953d499808807b8bdf9ab1a60adeb476f5a575a</code></a> | September 8, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/fc80c59a0c9cccfe91fc6c742d23277108d87843"><code>fc80c59a0c9cccfe91fc6c742d23277108d87843</code></a> | September 8, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/0fb812d4fa341b5ec7696da15d208ca60a4c50f1"><code>0fb812d4fa341b5ec7696da15d208ca60a4c50f1</code></a> | September 8, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/ce539cb8498b954598d32a9325b0c636d9357075"><code>ce539cb8498b954598d32a9325b0c636d9357075</code></a> | September 8, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/2d5ea7ee12188d066ca5f24d473cabf96359d4a8"><code>2d5ea7ee12188d066ca5f24d473cabf96359d4a8</code></a> | September 8, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/README.md</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/bb3a089116ae74a7a7682626a41463501400d0a5"><code>bb3a089116ae74a7a7682626a41463501400d0a5</code></a> | September 12, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/0b17711ab060d9bc7060c17416741427af1615f2"><code>0b17711ab060d9bc7060c17416741427af1615f2</code></a> | September 12, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/d8f4dd0079ac1d34d3d6fc1c7986a4ca12a29b85"><code>d8f4dd0079ac1d34d3d6fc1c7986a4ca12a29b85</code></a> | September 17, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/2a8524538ae01cff1e5c8b0e1d318b90f8a132c9"><code>2a8524538ae01cff1e5c8b0e1d318b90f8a132c9</code></a> | September 22, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield_impl.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/bigfield.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bigfield/README.md</code> |

## Veridise Auditing Report: Aztec Governance

- Report: [Veridise - Governance.md](<reports/Veridise - Governance.md>)
- Auditor: Veridise
- Date: 2025-10-13
- Description: Veridise security assessment (Aug 25 - Sep 4, 2025, 27 person-days) of the Aztec Governance Solidity contracts in AztecProtocol/aztec-packages at commit a6eebac, covering Governance, GSE, GSEPayload, CoinIssuer, Registry, RewardDistributor, the EmpireBase/GovernanceProposer proposers and the governance and shared libraries under l1-contracts. Manual and tool-assisted review identified one medium, two low and seven warning-severity issues.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/a6eebac31276e7a08525a872d8d364da6d535f86/l1-contracts/src/governance/CoinIssuer.sol"><code>a6eebac31276e7a08525a872d8d364da6d535f86</code></a> | August 23, 2025 | <code>l1-contracts/src/governance/CoinIssuer.sol</code><br><code>l1-contracts/src/governance/Governance.sol</code><br><code>l1-contracts/src/governance/GSEPayload.sol</code><br><code>l1-contracts/src/governance/GSE.sol</code><br><code>l1-contracts/src/governance/interfaces/ICoinIssuer.sol</code><br><code>l1-contracts/src/governance/interfaces/IEmpire.sol</code><br><code>l1-contracts/src/governance/interfaces/IGovernanceProposer.sol</code><br><code>l1-contracts/src/governance/interfaces/IGovernance.sol</code><br><code>l1-contracts/src/governance/interfaces/IPayload.sol</code><br><code>l1-contracts/src/governance/interfaces/IProposerPayload.sol</code><br><code>l1-contracts/src/governance/interfaces/IRegistry.sol</code><br><code>l1-contracts/src/governance/interfaces/IRewardDistributor.sol</code><br><code>l1-contracts/src/governance/libraries/AddressSnapshotLib.sol</code><br><code>l1-contracts/src/governance/libraries/CheckpointedUintLib.sol</code><br><code>l1-contracts/src/governance/libraries/ConfigurationLib.sol</code><br><code>l1-contracts/src/governance/libraries/DepositDelegationLib.sol</code><br><code>l1-contracts/src/governance/libraries/Errors.sol</code><br><code>l1-contracts/src/governance/libraries/ProposalLib.sol</code><br><code>l1-contracts/src/governance/proposer/EmpireBase.sol</code><br><code>l1-contracts/src/governance/proposer/GovernanceProposer.sol</code><br><code>l1-contracts/src/governance/Registry.sol</code><br><code>l1-contracts/src/governance/RewardDistributor.sol</code><br><code>l1-contracts/src/shared/interfaces/IMintableERC20.sol</code><br><code>l1-contracts/src/shared/libraries/BN254Lib.sol</code><br><code>l1-contracts/src/shared/libraries/CompressedTimeMath.sol</code><br><code>l1-contracts/src/shared/libraries/SignatureLib.sol</code><br><code>l1-contracts/src/shared/libraries/TimeMath.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/95c296fb05387e2845065cb46ebffc8ce651f69b"><code>95c296fb05387e2845065cb46ebffc8ce651f69b</code></a> | September 12, 2025 | <code>l1-contracts/src/governance/Governance.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/cab5a54630639751fa471385508cc4a5a8a85d10"><code>cab5a54630639751fa471385508cc4a5a8a85d10</code></a> | September 23, 2025 | <code>l1-contracts/src/governance/GSE.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/7a12a9650196d3c1292674052009913d3b9cd695"><code>7a12a9650196d3c1292674052009913d3b9cd695</code></a> | September 23, 2025 | <code>l1-contracts/src/governance/GSE.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/46e3dd7517ddfcff60b172a3bf2cbd09d62bfef2"><code>46e3dd7517ddfcff60b172a3bf2cbd09d62bfef2</code></a> | September 25, 2025 | <code>l1-contracts/src/governance/GSE.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/a310dd929fc136669fd84baa5024d437ac1c9603"><code>a310dd929fc136669fd84baa5024d437ac1c9603</code></a> | September 25, 2025 | <code>l1-contracts/src/governance/Governance.sol</code><br><code>l1-contracts/src/governance/GSE.sol</code><br><code>l1-contracts/src/governance/interfaces/IGovernance.sol</code><br><code>l1-contracts/src/governance/libraries/AddressSnapshotLib.sol</code><br><code>l1-contracts/src/governance/libraries/ConfigurationLib.sol</code><br><code>l1-contracts/src/governance/libraries/Errors.sol</code><br><code>l1-contracts/src/governance/libraries/ProposalLib.sol</code><br><code>l1-contracts/src/shared/libraries/BN254Lib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/5cd8f416a6b4e0f0084bdfaed672b4cb42230e2f"><code>5cd8f416a6b4e0f0084bdfaed672b4cb42230e2f</code></a> | September 25, 2025 | <code>l1-contracts/src/shared/libraries/BN254Lib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/1856c6133d4f5f5d8e465722be5d752dff3864bb"><code>1856c6133d4f5f5d8e465722be5d752dff3864bb</code></a> | September 30, 2025 | <code>l1-contracts/src/shared/libraries/BN254Lib.sol</code> |

## Aztec Barretenberg Proof System Security Review

- Report: [Cantina - Barretenberg Bool and Bytearray.md](<reports/Cantina - Barretenberg Bool and Bytearray.md>)
- Auditor: Cantina
- Date: 2025-11-10
- Description: Cantina Managed review of the Barretenberg stdlib bool and byte_array circuit primitives in aztec-packages (Sep 28 - Oct 4, 2025). Two Critical underconstrained byte_array constructor issues were found and fixed in PR 17838.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/72f52e7bad0fc1e36da575fbc2e6bfa1b1104aec/barretenberg/cpp/src/barretenberg/stdlib/primitives/bool/bool.cpp"><code>72f52e7bad0fc1e36da575fbc2e6bfa1b1104aec</code></a> | September 24, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bool/bool.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bool/bool.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bool/bool.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/byte_array/byte_array.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/byte_array/byte_array.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/byte_array/byte_array.test.cpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/8c1f77d5d7afc37419d8942e8dbd871710887c1e/barretenberg/cpp/src/barretenberg/stdlib/primitives/bool/bool.cpp"><code>8c1f77d5d7afc37419d8942e8dbd871710887c1e</code></a> | November 7, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/bool/bool.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/byte_array/byte_array.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/byte_array/byte_array.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/byte_array/byte_array.test.cpp</code> |

## Aztec Coinissuer Security Review

- Report: [Cantina - Coinissuer.md](<reports/Cantina - Coinissuer.md>)
- Auditor: Cantina
- Date: 2025-11-12
- Description: Cantina solo security review (Nov 2-3, 2025) of the CoinIssuer.sol governance contract in AztecProtocol/aztec-packages (l1-contracts/src/governance) at commit bd31f776, covering the capped annual minting logic for the Aztec token. The review yielded only gas and informational findings.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/bd31f776c3ed5ed9fd5c16d1fd86ad1b9fadb116/l1-contracts/src/governance/CoinIssuer.sol"><code>bd31f776c3ed5ed9fd5c16d1fd86ad1b9fadb116</code></a> | November 3, 2025 | <code>l1-contracts/src/governance/CoinIssuer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/bcc710cc4f8733e6808413b8daf82c8f3d72310f"><code>bcc710cc4f8733e6808413b8daf82c8f3d72310f</code></a> | November 4, 2025 | <code>l1-contracts/src/governance/CoinIssuer.sol</code> |

## Aztec: Governance Contracts Security Review

- Report: [Cantina - Governance.md](<reports/Cantina - Governance.md>)
- Auditor: Cantina
- Date: 2025-11-12
- Description: Cantina security review (Aug 5-12, 2025) of the Aztec governance contracts in AztecProtocol/aztec-packages at commit 6496e59d, focusing on Governance.sol, GSE.sol, GSEPayload.sol, EmpireBase and governance libraries under l1-contracts/src/governance. The team identified 20 issues, including four medium-severity findings.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/6496e59db3406cfb1ffbeab3e68be53872ec4735/l1-contracts/src/governance/proposer/EmpireBase.sol"><code>6496e59db3406cfb1ffbeab3e68be53872ec4735</code></a> | August 5, 2025 | <code>l1-contracts/src/governance/proposer/EmpireBase.sol</code><br><code>l1-contracts/src/governance/GSEPayload.sol</code><br><code>l1-contracts/src/governance/proposer/GovernanceProposer.sol</code><br><code>l1-contracts/src/governance/RewardDistributor.sol</code><br><code>l1-contracts/src/governance/interfaces/IRewardDistributor.sol</code><br><code>l1-contracts/src/shared/libraries/SignatureLib.sol</code><br><code>l1-contracts/src/governance/libraries/AddressSnapshotLib.sol</code><br><code>l1-contracts/src/governance/GSE.sol</code><br><code>l1-contracts/src/governance/Governance.sol</code><br><code>l1-contracts/src/governance/libraries/ProposalLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/StakingLib.sol</code><br><code>l1-contracts/src/governance/CoinIssuer.sol</code><br><code>l1-contracts/src/governance/Registry.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/2e192712333ec2b8c38e45c13923f465e8c18a6f"><code>2e192712333ec2b8c38e45c13923f465e8c18a6f</code></a> | August 20, 2025 | <code>l1-contracts/src/governance/proposer/EmpireBase.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/7d1ec0d01f58430f6c19ebc89f4db236a9e759ef"><code>7d1ec0d01f58430f6c19ebc89f4db236a9e759ef</code></a> | August 20, 2025 | <code>l1-contracts/src/core/libraries/rollup/AttestationLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/07650da19b2aa843cfab8d88f48e13fd5600a3ab"><code>07650da19b2aa843cfab8d88f48e13fd5600a3ab</code></a> | August 20, 2025 | <code>l1-contracts/src/governance/libraries/AddressSnapshotLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/1cec310430f7281676b8067d5e33ed984e9726b7"><code>1cec310430f7281676b8067d5e33ed984e9726b7</code></a> | August 20, 2025 | <code>l1-contracts/src/governance/libraries/AddressSnapshotLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/efd6a3ecd43f42a3bc90c94ea1ef272d18f6ef91"><code>efd6a3ecd43f42a3bc90c94ea1ef272d18f6ef91</code></a> | August 20, 2025 | <code>l1-contracts/src/governance/GSE.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/262591f9044cd3ed868a2b3a13d15a0bc0f9f73b"><code>262591f9044cd3ed868a2b3a13d15a0bc0f9f73b</code></a> | August 20, 2025 | <code>l1-contracts/src/governance/GSE.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/07b9496c954c6e690cd145df17c3e2c67b00305a"><code>07b9496c954c6e690cd145df17c3e2c67b00305a</code></a> | August 21, 2025 | <code>l1-contracts/src/governance/GSEPayload.sol</code><br><code>l1-contracts/src/governance/proposer/GovernanceProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/77fedd0c031cfae32ab6fdb4e6683df6aeb7ff3d"><code>77fedd0c031cfae32ab6fdb4e6683df6aeb7ff3d</code></a> | August 22, 2025 | <code>l1-contracts/src/governance/RewardDistributor.sol</code><br><code>l1-contracts/src/governance/interfaces/IRewardDistributor.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/83353d39aa402ccf23a14030329150096dddf763"><code>83353d39aa402ccf23a14030329150096dddf763</code></a> | August 22, 2025 | <code>l1-contracts/src/core/libraries/rollup/AttestationLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/9a9266660dd05114e6b921fbef6ad0df9ac765c7"><code>9a9266660dd05114e6b921fbef6ad0df9ac765c7</code></a> | August 22, 2025 | <code>l1-contracts/src/governance/GSE.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/744fcf65b0a55c2534d68fe70d1a1f4f69f2c710"><code>744fcf65b0a55c2534d68fe70d1a1f4f69f2c710</code></a> | August 22, 2025 | <code>l1-contracts/src/governance/libraries/ProposalLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/a3da5c9acb07cd3c4359e024fc9e0e678f25abc5"><code>a3da5c9acb07cd3c4359e024fc9e0e678f25abc5</code></a> | August 23, 2025 | <code>l1-contracts/src/governance/GSEPayload.sol</code><br><code>l1-contracts/src/governance/proposer/GovernanceProposer.sol</code><br><code>l1-contracts/src/core/libraries/rollup/AttestationLib.sol</code><br><code>l1-contracts/src/governance/Governance.sol</code><br><code>l1-contracts/src/core/libraries/rollup/StakingLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/884cd9b0b2841eef1ec50b1c3e0d5a56f3cdd2ca"><code>884cd9b0b2841eef1ec50b1c3e0d5a56f3cdd2ca</code></a> | August 23, 2025 | <code>l1-contracts/src/governance/Governance.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/83c6572a395b7f7b71ba1683cda303869005f9dd"><code>83c6572a395b7f7b71ba1683cda303869005f9dd</code></a> | August 27, 2025 | <code>l1-contracts/src/governance/Governance.sol</code> |

## Aztec Rollup Contracts Security Review

- Report: [Cantina - Rollup Contracts.md](<reports/Cantina - Rollup Contracts.md>)
- Auditor: Cantina
- Date: 2025-11-12
- Description: Cantina security review (Aug 14 - Sep 11) of the Aztec L1 rollup contracts in AztecProtocol/aztec-packages at commit 270e2a58 plus the EmpireSlashingProposer PR 16357, covering RollupCore and its libraries (StakingLib, RewardLib, ProposeLib, BlobLib, STFLib, InvalidateLib, ValidatorSelectionLib), the message bridge Inbox/Outbox and crypto libraries. 23 issues were found including one critical and two high severity findings.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/270e2a58ae2a378472f9be791900bbd4342c7881/l1-contracts/src/core/messagebridge/Outbox.sol"><code>270e2a58ae2a378472f9be791900bbd4342c7881</code></a> | August 15, 2025 | <code>l1-contracts/src/core/messagebridge/Outbox.sol</code><br><code>l1-contracts/src/core/libraries/crypto/MerkleLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/StakingLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/ProposeLib.sol</code><br><code>l1-contracts/src/core/messagebridge/Inbox.sol</code><br><code>l1-contracts/src/core/RollupCore.sol</code><br><code>l1-contracts/src/core/libraries/rollup/ValidatorSelectionLib.sol</code><br><code>l1-contracts/src/core/messagebridge/FeeJuicePortal.sol</code><br><code>l1-contracts/src/core/libraries/rollup/STFLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/RewardLib.sol</code><br><code>l1-contracts/src/core/libraries/crypto/SampleLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/BlobLib.sol</code><br><code>l1-contracts/src/core/libraries/compressed-data/Tips.sol</code><br><code>l1-contracts/src/core/libraries/rollup/InvalidateLib.sol</code><br><code>l1-contracts/src/core/libraries/StakingQueue.sol</code><br><code>l1-contracts/src/core/libraries/rollup/EpochProofLib.sol</code><br><code>l1-contracts/src/core/libraries/compressed-data/fees/FeeStructs.sol</code><br><code>l1-contracts/src/core/libraries/compressed-data/fees/FeeConfig.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/474754f58e7ce6a6e0350306f4c144d0a9ee8d14"><code>474754f58e7ce6a6e0350306f4c144d0a9ee8d14</code></a> | August 22, 2025 | <code>l1-contracts/src/core/slashing/EmpireSlashingProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/6eb1316b86eca5aa7b6c0b5b2a308a4a2282cbd9"><code>6eb1316b86eca5aa7b6c0b5b2a308a4a2282cbd9</code></a> | August 26, 2025 | <code>l1-contracts/src/core/libraries/crypto/MerkleLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/ca8c97c2d87444e81c640557a8bb1f9e26da600d"><code>ca8c97c2d87444e81c640557a8bb1f9e26da600d</code></a> | August 28, 2025 | <code>l1-contracts/src/core/messagebridge/Inbox.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/2f71e44c573b9a7b1b4698247b71ffb549c8ac74"><code>2f71e44c573b9a7b1b4698247b71ffb549c8ac74</code></a> | September 8, 2025 | <code>l1-contracts/src/core/libraries/rollup/ProposeLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/9193dfb37055add64013ed3fe1b901351eb08003"><code>9193dfb37055add64013ed3fe1b901351eb08003</code></a> | September 9, 2025 | <code>l1-contracts/src/core/messagebridge/Outbox.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/e87438b3d3f29beef92ac3bb148597236944d032"><code>e87438b3d3f29beef92ac3bb148597236944d032</code></a> | September 12, 2025 | <code>l1-contracts/src/core/libraries/crypto/MerkleLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/BlobLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/3887ea20a027890a3c807c41895d74fd756f6447"><code>3887ea20a027890a3c807c41895d74fd756f6447</code></a> | September 19, 2025 | <code>l1-contracts/src/core/libraries/rollup/StakingLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/70f004dc2ad19d1c0b80f8a481424dd23542f191"><code>70f004dc2ad19d1c0b80f8a481424dd23542f191</code></a> | September 26, 2025 | <code>l1-contracts/src/core/messagebridge/Outbox.sol</code><br><code>l1-contracts/src/core/libraries/rollup/STFLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/RewardLib.sol</code><br><code>l1-contracts/src/core/libraries/crypto/SampleLib.sol</code><br><code>l1-contracts/src/core/libraries/compressed-data/Tips.sol</code><br><code>l1-contracts/src/core/libraries/rollup/InvalidateLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/44e3f64839b6f60aa4f3443f60fb45fcf744e586"><code>44e3f64839b6f60aa4f3443f60fb45fcf744e586</code></a> | September 26, 2025 | <code>l1-contracts/src/core/libraries/rollup/ValidatorSelectionLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/RewardLib.sol</code><br><code>l1-contracts/src/core/libraries/StakingQueue.sol</code><br><code>l1-contracts/src/core/libraries/rollup/EpochProofLib.sol</code><br><code>l1-contracts/src/core/libraries/compressed-data/fees/FeeStructs.sol</code><br><code>l1-contracts/src/core/libraries/compressed-data/fees/FeeConfig.sol</code> |

## Aztec stdlib field Security Review

- Report: [Cantina - Barretenberg Field.md](<reports/Cantina - Barretenberg Field.md>)
- Auditor: Cantina
- Date: 2025-12-16
- Description: Cantina Managed review of the Barretenberg stdlib field_t primitive (field.hpp/field.cpp and its tests) in aztec-packages, conducted Jul 8-22, 2025. Only Low and Informational issues were found, all fixed in commit 4433c06a.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/458fb330efa8c470567ab4b84a8a92a58b00586a/barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.cpp"><code>458fb330efa8c470567ab4b84a8a92a58b00586a</code></a> | July 9, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.test.cpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/4433c06ae693451c6f69a2f63b7da6628078d872/barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.cpp"><code>4433c06ae693451c6f69a2f63b7da6628078d872</code></a> | August 13, 2025 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/field/field.test.cpp</code> |

## Security Review For Aztec Network (cycle_group and ROM/RAM memory modules)

- Report: [Sherlock - Barretenberg RAM ROM.md](<reports/Sherlock - Barretenberg RAM ROM.md>)
- Auditor: Sherlock
- Date: 2026-01-28
- Description: Sherlock collaborative audit (Jan 14-28, 2026) of Barretenberg&#x27;s cycle_group in-circuit Grumpkin elliptic curve module and the ROM/RAM memory module in aztec-packages, including the elliptic and memory relations, circuit builder logic and ACIR bridges. One High soundness issue (unconstrained scalar limbs in batch_mul) was found and resolved at the final commit.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/c58cd76497e68c2236d875e7eac424f4b2d7bbd5/barretenberg/cpp/src/barretenberg/circuit_checker/ultra_circuit_builder_elliptic.test.cpp"><code>c58cd76497e68c2236d875e7eac424f4b2d7bbd5</code></a> | January 13, 2026 | <code>barretenberg/cpp/src/barretenberg/circuit_checker/ultra_circuit_builder_elliptic.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/circuit_checker/ultra_circuit_builder_memory.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/block_constraint.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/block_constraint.hpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/block_constraint.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/ec_operations.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/ec_operations.hpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/ec_operations.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/multi_scalar_mul.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/multi_scalar_mul.hpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/multi_scalar_mul.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/relations/elliptic_relation.hpp</code><br><code>barretenberg/cpp/src/barretenberg/relations/memory_relation.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/fixed_base/fixed_base.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/fixed_base/fixed_base.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/fixed_base/fixed_base_params.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/fixed_base/fixed_base.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/rom_ram_logic.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/rom_ram_logic.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/ultra_circuit_builder.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/ultra_circuit_builder.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_group.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_group.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_group.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_scalar.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_scalar.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_scalar.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_lookup_table.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_lookup_table.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_lookup_table.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_scalar_slice.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_scalar_slice.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_scalar_slice.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/test_utils.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/ram_table.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/ram_table.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/ram_table.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/rom_table.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/rom_table.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/rom_table.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/twin_rom_table.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/twin_rom_table.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/twin_rom_table.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/ultra_honk/rom_ram.test.cpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/6b858739756e0f56803e5d6a995f1308303a7f16/barretenberg/cpp/src/barretenberg/circuit_checker/ultra_circuit_builder_elliptic.test.cpp"><code>6b858739756e0f56803e5d6a995f1308303a7f16</code></a> | February 13, 2026 | <code>barretenberg/cpp/src/barretenberg/circuit_checker/ultra_circuit_builder_elliptic.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/circuit_checker/ultra_circuit_builder_memory.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/block_constraint.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/block_constraint.hpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/block_constraint.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/ec_operations.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/ec_operations.hpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/ec_operations.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/multi_scalar_mul.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/multi_scalar_mul.hpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/multi_scalar_mul.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/relations/elliptic_relation.hpp</code><br><code>barretenberg/cpp/src/barretenberg/relations/memory_relation.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/fixed_base/fixed_base.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/fixed_base/fixed_base.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/fixed_base/fixed_base_params.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/fixed_base/fixed_base.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/rom_ram_logic.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/rom_ram_logic.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/ultra_circuit_builder.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/ultra_circuit_builder.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_group.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_group.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_group.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_scalar.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_scalar.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/cycle_scalar.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_lookup_table.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_lookup_table.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_lookup_table.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_scalar_slice.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_scalar_slice.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/straus_scalar_slice.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/group/test_utils.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/ram_table.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/ram_table.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/ram_table.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/rom_table.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/rom_table.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/rom_table.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/twin_rom_table.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/twin_rom_table.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/memory/twin_rom_table.test.cpp</code><br><code>barretenberg/cpp/src/barretenberg/ultra_honk/rom_ram.test.cpp</code> |

### Repository: <a href="https://github.com/sherlock-audit/2026-01-aztec-network-jan-14th"><code>sherlock-audit/2026-01-aztec-network-jan-14th</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Aztec: Hatch Security Review

- Report: [Cantina - Escape Hatch.md](<reports/Cantina - Escape Hatch.md>)
- Auditor: Cantina
- Date: 2026-02-24
- Description: Cantina security review (Jan 25-27) of the escape hatch functionality in the Aztec L1 rollup contracts in AztecProtocol/aztec-packages at commit 0092f9f0, covering EscapeHatch.sol, Rollup.sol, RollupCore.sol, rollup libraries (EpochProofLib, FeeLib, InvalidateLib, ProposeLib, RewardLib, ValidatorSelectionLib, HatchMath), the Inbox and TallySlashingProposer. 31 issues were identified including one high and six medium severity findings.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/0092f9f01ed88cc3626270e62716d7b722ea1944/l1-contracts/src/core/EscapeHatch.sol"><code>0092f9f01ed88cc3626270e62716d7b722ea1944</code></a> | January 6, 2026 | <code>l1-contracts/src/core/EscapeHatch.sol</code><br><code>l1-contracts/src/core/Rollup.sol</code><br><code>l1-contracts/src/core/RollupCore.sol</code><br><code>l1-contracts/src/core/interfaces/IEscapeHatch.sol</code><br><code>l1-contracts/src/core/interfaces/IRollup.sol</code><br><code>l1-contracts/src/core/interfaces/IValidatorSelection.sol</code><br><code>l1-contracts/src/core/libraries/Errors.sol</code><br><code>l1-contracts/src/core/libraries/HatchMath.sol</code><br><code>l1-contracts/src/core/libraries/compressed-data/fees/FeeConfig.sol</code><br><code>l1-contracts/src/core/libraries/rollup/EpochProofLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/FeeLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/InvalidateLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/ProposedHeaderLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/ProposeLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/RewardLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/ValidatorOperationsExtLib.sol</code><br><code>l1-contracts/src/core/libraries/rollup/ValidatorSelectionLib.sol</code><br><code>l1-contracts/src/core/messagebridge/Inbox.sol</code><br><code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code><br><code>l1-contracts/src/core/messagebridge/Outbox.sol</code><br><code>l1-contracts/src/core/libraries/rollup/STFLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/93be4fe8cc65c3e2dc938e1bae45ccc37926eb1a"><code>93be4fe8cc65c3e2dc938e1bae45ccc37926eb1a</code></a> | February 13, 2026 | <code>l1-contracts/src/core/libraries/rollup/FeeLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/b7605403131acbe86dbbc97be1e741f733c61f5e"><code>b7605403131acbe86dbbc97be1e741f733c61f5e</code></a> | February 13, 2026 | <code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/e3b9467385bbb1eaa4eb096e6e1a18b06d45bba9"><code>e3b9467385bbb1eaa4eb096e6e1a18b06d45bba9</code></a> | February 16, 2026 | <code>l1-contracts/src/core/EscapeHatch.sol</code><br><code>l1-contracts/src/core/libraries/rollup/EpochProofLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/4230665af7c983edc3b44cc25ef4a2f1e8cf660e"><code>4230665af7c983edc3b44cc25ef4a2f1e8cf660e</code></a> | February 16, 2026 | <code>l1-contracts/src/core/EscapeHatch.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/495fc284073d909b54946fbd3f473723f80e5548"><code>495fc284073d909b54946fbd3f473723f80e5548</code></a> | February 16, 2026 | <code>l1-contracts/src/core/EscapeHatch.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/c9cd1b9deb54ca43d3b4762eb73fd0dcf983e473"><code>c9cd1b9deb54ca43d3b4762eb73fd0dcf983e473</code></a> | February 16, 2026 | <code>l1-contracts/src/core/libraries/compressed-data/fees/FeeConfig.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/9f8ff7e337e12bd798fff868524a14788099ed21"><code>9f8ff7e337e12bd798fff868524a14788099ed21</code></a> | February 16, 2026 | <code>l1-contracts/src/core/libraries/rollup/FeeLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/fd98ab2827138ace06840a2375f2783e9f459674"><code>fd98ab2827138ace06840a2375f2783e9f459674</code></a> | February 16, 2026 | <code>l1-contracts/src/core/libraries/rollup/ValidatorSelectionLib.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/217996f9428e222c94d7567b1c81a8d190b79327"><code>217996f9428e222c94d7567b1c81a8d190b79327</code></a> | February 16, 2026 | <code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/1929135b11cefff7384005d021041a058fa5c44f"><code>1929135b11cefff7384005d021041a058fa5c44f</code></a> | February 16, 2026 | <code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/5f4e35de036ab89a34b968e38fb2735c6b6f6994"><code>5f4e35de036ab89a34b968e38fb2735c6b6f6994</code></a> | February 16, 2026 | <code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/f68b1a9183ce407f89bec0175615de0e478bbd48"><code>f68b1a9183ce407f89bec0175615de0e478bbd48</code></a> | February 23, 2026 | <code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code> |

## Aztec PR 20865 Security Review (Alpha Upgrade Payload)

- Report: [Cantina - Payload 2025.03.05.md](<reports/Cantina - Payload 2025.03.05.md>)
- Auditor: Cantina
- Date: 2026-03-05
- Description: Cantina security review (Feb 27-28) of the Alpha upgrade payload in AztecProtocol/aztec-packages at commit ed3f61d6, covering the onchain AlphaPayload.sol and AlphaVerifier.sol contracts together with the DeployAlpha.s.sol deployment script and run_alpha_upgrade.sh, plus the follow-up VK-tree-root constant change in PR 21066. The review found one high-severity issue and four informational notes.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/b7605403131acbe86dbbc97be1e741f733c61f5e"><code>b7605403131acbe86dbbc97be1e741f733c61f5e</code></a> | February 13, 2026 | <code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/ed3f61d61745bcd895056ee49e4c6a849928d19e/l1-contracts/script/deploy/DeployAlpha.s.sol"><code>ed3f61d61745bcd895056ee49e4c6a849928d19e</code></a> | February 27, 2026 | <code>l1-contracts/script/deploy/DeployAlpha.s.sol</code><br><code>l1-contracts/scripts/run_alpha_upgrade.sh</code><br><code>l1-contracts/src/alpha/AlphaPayload.sol</code><br><code>l1-contracts/src/alpha/AlphaVerifier.sol</code><br><code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/b2742ee480de17eb6683413811251123c54c1d43"><code>b2742ee480de17eb6683413811251123c54c1d43</code></a> | March 1, 2026 | <code>l1-contracts/src/core/slashing/TallySlashingProposer.sol</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/commit/96eca77fe31dd030545b16012ffd587f6decda7c"><code>96eca77fe31dd030545b16012ffd587f6decda7c</code></a> | March 3, 2026 | <code>l1-contracts/script/deploy/DeployAlpha.s.sol</code><br><code>yarn-project/aztec/src/mainnet_compatibility.test.ts</code><br><code>yarn-project/aztec/src/testnet_compatibility.test.ts</code> |

## Aztec Logic Module Audit Report

- Report: [Cyfrin - Barretenberg Logic.md](<reports/Cyfrin - Barretenberg Logic.md>)
- Auditor: Cyfrin
- Date: 2026-04-06
- Description: Cyfrin manual review (Mar 16-19, 2026) of the Barretenberg stdlib logic module (plookup-based bitwise AND/XOR constraints) and its ACIR DSL bridge in aztec-packages. Only Low and Informational issues were found; three were fixed in follow-up commits.

### Repository: <a href="https://github.com/AztecProtocol/aztec-packages"><code>AztecProtocol/aztec-packages</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/e4712cda8def49d75fbba2d361625fc5e21945f5/barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/uint.hpp"><code>e4712cda8def49d75fbba2d361625fc5e21945f5</code></a> | February 16, 2026 | <code>barretenberg/cpp/src/barretenberg/stdlib_circuit_builders/plookup_tables/uint.hpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/logic/logic.cpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/logic_constraint.cpp</code><br><code>barretenberg/cpp/src/barretenberg/stdlib/primitives/logic/logic.hpp</code><br><code>barretenberg/cpp/src/barretenberg/dsl/acir_format/logic_constraint.hpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/0f3ca1c6a84ef6ed14d4b29564ffcf4d37645619/barretenberg/cpp/src/barretenberg/stdlib/primitives/logic/logic.cpp"><code>0f3ca1c6a84ef6ed14d4b29564ffcf4d37645619</code></a> | April 3, 2026 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/logic/logic.cpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/249bfdc76053f41455e048f182605a871f970cce/barretenberg/cpp/src/barretenberg/stdlib/primitives/logic/logic.cpp"><code>249bfdc76053f41455e048f182605a871f970cce</code></a> | April 3, 2026 | <code>barretenberg/cpp/src/barretenberg/stdlib/primitives/logic/logic.cpp</code> |
| <a href="https://github.com/AztecProtocol/aztec-packages/blob/a4837fef0294826c391125686cce671199d055f6/barretenberg/cpp/src/barretenberg/dsl/acir_format/logic_constraint.cpp"><code>a4837fef0294826c391125686cce671199d055f6</code></a> | April 6, 2026 | <code>barretenberg/cpp/src/barretenberg/dsl/acir_format/logic_constraint.cpp</code> |

## Irrelevant reports

### AZTEC Security Assessment (Trusted Setup Protocol)

- Report: [irrelevant/Trail of Bits - AZTEC Setup Protocol.md](<reports/irrelevant/Trail of Bits - AZTEC Setup Protocol.md>)
- Auditor: Trail of Bits
- Date: 2019-10-09
- Description: Cryptographic and security review of the AZTEC trusted-setup MPC ceremony protocol and its implementation (setup-tools C++ and setup-mpc-server TypeScript, plus Terraform/AWS infrastructure) in AztecProtocol/Setup at commit 230a1d8a, including DeepState fuzz-test integration and a fix log. No onchain contracts were in scope.

### Audit Report for Aztec

- Report: [irrelevant/Solidified - Aztec Protocol.md](<reports/irrelevant/Solidified - Aztec Protocol.md>)
- Auditor: Solidified
- Date: 2022-04-10
- Description: Solidified audit of the Aztec Connect Ethereum base contracts (RollupProcessor, Decoder, DefiBridgeProxy, UniswapBridge, AztecTypes, libraries and interfaces) at commit 25c02619 of the private AztecProtocol/aztec2-internal repository. Cryptographic libraries, proof verification and the fee distributor contract were explicitly excluded.

### Aztec Security Assessment (Aztec Connect)

- Report: [irrelevant/Arbitrary Execution - Aztec Connect.md](<reports/irrelevant/Arbitrary Execution - Aztec Connect.md>)
- Auditor: Arbitrary Execution
- Date: 2022-10-14
- Description: Manual review and Slither analysis of the Aztec Connect L1 rollup contracts (RollupProcessorV2, Decoder, DefiBridgeProxy, RollupProcessorLibrary, TokenTransfers, PermitHelper) at commit 9558b626 of the private AztecProtocol/aztec2-internal repository, followed by a fix review of the resulting pull requests. The engagement looked for proof-data manipulation, unauthorized fund extraction, contract bricking and privilege escalation.

### Audit of Aztec&#x27;s TGE Contract

- Report: [irrelevant/ZKSecurity - TGE.md](<reports/irrelevant/ZKSecurity - TGE.md>)
- Auditor: zkSecurity
- Date: 2025-02-24
- Description: Three-day zkSecurity review of the AZTEC ERC20 token, Aztec Token Position (ATP) vesting contracts, staker, ATPFactory and Registry contracts for the Token Generation Event, held in the private repository AztecProtocol/teegeeee at commit 8432c82584731813a2197dd3b715ba2db0dbe3f9. The repository is private and cannot be accessed, so no source coverage is extracted.

### Aztec teegeee Security Review

- Report: [irrelevant/Spearbit - TGE.md](<reports/irrelevant/Spearbit - TGE.md>)
- Auditor: Spearbit
- Date: 2025-03-17
- Description: Spearbit review (Feb 25-28, 2025) of the Aztec TGE token contracts (aztec-teegeee): the Aztec token, ATP (Aztec Token Position) LATP/MATP vesting-and-staking contracts, Staker upgrade mechanism and Registry at commit 8062e3a6. The audited repository (cantina-forks/aztec-teegee, upstream AztecProtocol/teegeeee) is private and inaccessible, so the scope cannot be extracted.

### Aztec Ignition Security Review (Staking Registry)

- Report: [irrelevant/Cantina - Staking Registry.md](<reports/irrelevant/Cantina - Staking Registry.md>)
- Auditor: Cantina
- Date: 2025-09-10
- Description: Cantina security review (Aug 22-29, 2025) of the staking registry contracts (e.g. contracts/src/staking/ATPWithdrawableStaker.sol) in AztecProtocol/ignition-monorepo at commit c9efabac. The entire scope lives in the ignition-monorepo repository, which is private and cannot be accessed.

### Aztec Uniswap TWAP Security Review

- Report: [irrelevant/Cantina - Uniswap TWAP.md](<reports/irrelevant/Cantina - Uniswap TWAP.md>)
- Auditor: Cantina
- Date: 2025-12-09
- Description: Cantina Managed review (Oct 20 - Nov 5, 2025) of the Genesis Sequencer Sale, Ignition participant soulbound token and providers, ATP staker contracts, staking registry and Uniswap V4 periphery (AuctionHook, VirtualAztecToken) in ignition-monorepo, the AZTEC token / ATP contracts in teegeeee, and the LBP distribution strategies in uniswap-token-launcher. All three repositories (and the cantina-forks aggregate monorepo) are private and inaccessible, so the scope cannot be extracted.

### Aztec Soulbound Security Review

- Report: [irrelevant/Cantina - Soulbound.md](<reports/irrelevant/Cantina - Soulbound.md>)
- Auditor: Cantina
- Date: 2025-12-15
- Description: Cantina security review (Aug 14-16, 2025) of the Ignition participant soulbound token and Genesis sequencer sale contracts (IgnitionParticipantSoulbound, GenesisSequencerSale and the Attestation/Predicate/ZKPassport whitelist providers) in AztecProtocol/ignition-monorepo at commit abfbcc19. The entire scope lives in the ignition-monorepo repository, which is private and cannot be accessed.

### Aztec PR 599 Security Review (ProtocolTreasury)

- Report: [irrelevant/Cantina - Protocol Treasury.md](<reports/irrelevant/Cantina - Protocol Treasury.md>)
- Auditor: Cantina
- Date: 2025-12-17
- Description: Cantina security review (Nov 10-11, 2025) of contracts/src/ProtocolTreasury.sol in AztecProtocol/ignition-monorepo at commit 2a2c7909 (files changed in PR 599). The entire scope lives in the ignition-monorepo repository, which is private and cannot be accessed.
