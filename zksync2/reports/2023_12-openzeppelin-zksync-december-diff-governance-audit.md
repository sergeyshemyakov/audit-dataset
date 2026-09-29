# December Diff and Governance Audit

Source: [https://www.openzeppelin.com/news/december-diff-and-governance-audit](https://www.openzeppelin.com/news/december-diff-and-governance-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [Governance Contract](#governance-contract)
  - [Upgrade Contracts](#upgrade-contracts)
  - [Era Contracts Changes](#era-contracts-changes)
  - [Era System Contracts Changes](#era-system-contracts-changes)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
  - [Privileged Roles](#privileged-roles)
- [Medium Severity](#medium-severity)
  - [Overwriting ERC-20 Metadata Can Cause Unexpected Behaviors](#overwriting-erc-20-metadata-can-cause-unexpected-behaviors)
  - [Critical and High Vulnerabilities in Yarn Module Dependencies](#critical-and-high-vulnerabilities-in-yarn-module-dependencies)
- [Low Severity](#low-severity)
  - [minDelay Set to Zero Undermines Security Council Purpose](#mindelay-set-to-zero-undermines-security-council-purpose)
  - [Undisclosed Functionality Mismatch in L1 and L2 Token Functions Post-Bridging](#undisclosed-functionality-mismatch-in-l1-and-l2-token-functions-post-bridging)
  - [Inaccurate Attribution in LibMap.sol](#inaccurate-attribution-in-libmapsol)
  - [Documentation Mismatch](#documentation-mismatch)
  - [Upgrade Validation and Execution Is Not Strict](#upgrade-validation-and-execution-is-not-strict)
- [Notes & Additional Information](#notes-additional-information)
  - [Misleading Contract Name](#misleading-contract-name)
  - [Multiple Instances of Missing Named Parameters in Mappings](#multiple-instances-of-missing-named-parameters-in-mappings)
  - [Incomplete Documentation of Differences Between WETH9 and L2Weth Contracts](#incomplete-documentation-of-differences-between-weth9-and-l2weth-contracts)
  - [Unnecessary Cast](#unnecessary-cast)
  - [State Variable Visibility Not Explicitly Declared](#state-variable-visibility-not-explicitly-declared)
  - [Lack of Security Contact](#lack-of-security-contact)
  - [Lack of Indexed Event Parameters](#lack-of-indexed-event-parameters)
  - [Unused Constants](#unused-constants)
  - [Non-Explicit Imports Are Used](#non-explicit-imports-are-used)
  - [Literal Number With Many Digits](#literal-number-with-many-digits)
  - [Unused Import](#unused-import)
  - [Typographical Errors](#typographical-errors)
  - [Missing and Incomplete Docstrings](#missing-and-incomplete-docstrings)
  - [Function Is Updating the State Without Event Emissions](#function-is-updating-the-state-without-event-emissions)
- [Conclusion](#conclusion)

## Summary

Type
:   ZK Rollup

Timeline
:   From 2023-12-04
:   To 2023-12-22

Languages
:   Solidity

Total Issues
:   21 (16 resolved, 1 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   2 (1 resolved, 1 partially resolved)

Low Severity Issues
:   5 (4 resolved)

Notes & Additional Information
:   14 (11 resolved)

## Scope

We audited the diff of the [matter-labs/era-contracts](https://github.com/matter-labs/era-contracts) repository from the base at commit [c44852f](https://github.com/matter-labs/era-contracts/tree/c44852f89f443bbe8120a7c6abcc6984b394eb29) and the head at commit [2e0734b](https://github.com/matter-labs/era-contracts/tree/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33), as well as the diff of the [matter-labs/era-system-contracts](https://github.com/matter-labs/era-system-contracts) repository from the base at commit [4dca36d](https://github.com/matter-labs/era-system-contracts/tree/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2) and the head at commit [0b238cd](https://github.com/matter-labs/era-system-contracts/tree/0b238cdf831f809584fec3131904d77987b7368d). New and marked contracts were audited in full while the rest of the in-scope codebase was audited only for the diffs.

In scope were the following contracts:

```
 era-contracts/
├─ ethereum/
│  └─ contracts/
│     ├─ bridge/
│     │  ├─ L1ERC20Bridge.sol
│     │  ├─ L1WethBridge.sol
│     │  └─ interfaces/
│     │     └─ IL1Bridge.sol
│     ├─ common/
│     │  ├─ L2ContractAddresses.sol
│     │  ├─ ReentrancyGuard.sol
│     │  └─ libraries/
│     │     ├─ L2ContractHelper.sol
│     │     ├─ UncheckedMath.sol
│     │     └─ UnsafeBytes.sol
│     ├─ governance/
│     │  ├─ Governance.sol
│     │  └─ IGovernance.sol
│     ├─ upgrades/
│     │  ├─ BaseZkSyncUpgrade.sol
│     │  └─ DefaultUpgrade.sol
│     └─ zksync/
│        ├─ Config.sol
│        ├─ DiamondInit.sol
│        ├─ DiamondProxy.sol
│        ├─ Storage.sol
│        ├─ ValidatorTimelock.sol (full audit)
│        └─ libraries/
│           ├─ Diamond.sol
│           ├─ LibMap.sol
│           ├─ Merkle.sol
│           └─ PriorityQueue.sol
└─ zksync/
   └─ contracts/
      ├─ L2ContractHelper.sol
      └─ bridge/
         ├─ L2ERC20Bridge.sol
         ├─ L2StandardERC20.sol
         ├─ L2Weth.sol
         └─ L2WethBridge.sol
```

```
 era-system-contracts/
└─ contracts/
   ├─ BootloaderUtilities.sol
   ├─ ComplexUpgrader.sol
   ├─ Constants.sol
   ├─ ImmutableSimulator.sol
   ├─ KnownCodesStorage.sol
   ├─ L2EthToken.sol
   ├─ MsgValueSimulator.sol
   ├─ NonceHolder.sol
   ├─ SystemContext.sol
   ├─ interfaces/
   │  ├─ IComplexUpgrader.sol
   │  ├─ ICompressor.sol
   │  ├─ IKnownCodesStorage.sol
   │  ├─ IL1Messenger.sol
   │  ├─ ISystemContext.sol
   │  ├─ ISystemContextDeprecated.sol
   │  └─ ISystemContract.sol
   └─ libraries/
      ├─ RLPEncoder.sol
      ├─ SystemContractHelper.sol
      └─ UnsafeBytesCalldata.sol
```

## System Overview

This system upgrade refactors existing code while also adding new contracts to the protocol. Most prominent is the introduction of the new `Governance` contract which has been implemented to slow down the execution of protocol changes. In addition, future upgrades will be based on the new `DefaultUpgrade` contract. These contracts will be explained in detail below, followed by an outline of changes for the existing contracts.

### Governance Contract

The new Governance contract is inspired by OpenZeppelin's `TimelockController` and the in-house Diamond Proxy upgrade mechanism. This contract is fundamental to managing and coordinating upgrades and changes across Matter Labs' governed zkSync Era contracts. The Governance contract's functionalities include the following:

1. **Operational Management:** The `Governance` contract's owner can schedule, execute, and cancel operations, while ensuring that each step occurs with the appropriate permissions and after the set delay.
2. **Transparent and Shadow Upgrades:** The `Governance` contract supports two types of upgrades: transparent upgrades with on-chain data exposure, and shadow upgrades where the operation data is not published on-chain before the execution. This dual approach balances transparency with security needs.
3. **Security Council:** A unique feature of the `Governance` contract is the integration of a security council, presumably a multisig contract. This council plays a crucial role in overseeing operations and is capable of executing scheduled proposals instantly. This adds a layer of flexibility and rapid response capabilities to the governance process.
4. **Timelock Mechanism:** The contract enforces a timelock mechanism, ensuring that operations are subject to a delay before they can be executed. This feature prevents abrupt changes and gives the community time to review and respond to proposed updates or actions. The security council is able to skip the delay for instant execution of scheduled operations.

### Upgrade Contracts

The `BaseZkSyncUpgrade` contract provides a foundation for upgrading the zkSync protocol. It introduces a `ProposedUpgrade` struct to represent an upgrade proposal. It enforces the upgrade to happen at a given time and provides functions to do the following:

- Set the L2 bootloader bytecode hash.
- Set the default account bytecode hash.
- Set the new verifier address and its parameters.
- Set the L2 transaction hash that can perform more L2 contract changes. This hash is checked against during batch finalization in the `Executor`.
- Set a new protocol version.

The `DefaultUpgrade` contract extends `BaseZkSyncUpgrade` and serves as a default implementation for upgrading the zkSync protocol. It defines placeholder functions for custom logic which is used to upgrade L1 contracts and perform post-upgrade actions. The upgrade function orchestrates the entire upgrade process, invoking functions from the base contract.

### Era Contracts Changes

Further era-contracts-related changes involve the following:

- The `ValidatorTimelock` contract now stores batch timestamps as 32-bit values instead of 256-bit values to use less storage. A modified version of [`vectorized/solady`](https://github.com/vectorized/solady)'s [`LibMap`](https://github.com/Vectorized/solady/blob/5eff720c27746987dc95e5e2b720615d3d96f7ee/src/utils/LibMap.sol) is used to pack eight 32-bit values into one storage slot.
- The `ValidatorTimelock::executeBatches` function now allows for committing, proving, and executing a batch within the same block. Previously, it was not possible to commit, prove, and execute a batch in the same block.
- With the removal of the `AllowList` contract, the `senderCanCallFunction` modifier was also removed from the affected functions.
- The deposit limit check as part of the `AllowList` functionality was also taken out of the `L1ERC20Bridge`.
- The `L2StandardERC20` contract was extended with a reinitialization function to overwrite the token metadata.
- Several constants were added to some in-scope contracts.
- Formatting, documentation, and code-style changes were made in some in-scope contracts.
- The Solidity version was upgraded to 0.8.20 for all in-scope contracts.

### Era System Contracts Changes

The era-system-contracts changes are as follows:

- The `SystemContractHelper::unsafePrecompileCall` internal function no longer ensures that there is enough gas for burning.
- The `SystemContractHelper::precompileCall` internal function was removed.
- The `SystemContractHelper::getZkSyncMeta` internal function now assigns values to the `ZkSyncMeta::heapSize` and `ZkSyncMeta::auxHeapSize` return parameters.
- The `UnsafeBytesCalldata::readUint256` internal function was added.
- The `NonceHolder::incrementDeploymentNonce` function no longer has the `ISystemContract::onlySystemCall` modifier but still requires the message sender to be `DEPLOYER_SYSTEM_CONTRACT`.
- The `KnownCodesStorage::_burnGas` internal function was removed.
- `SystemLogKey::NEW_TIMESTAMP_KEY` was renamed to `SystemLogKey::PACKED_BATCH_AND_L2_BLOCK_TIMESTAMP_KEY` and now contains both the 128-bit batch timestamp and the 128-bit L2 block timestamp in 256 bits.
- Several constants were added to some in-scope contracts.
- Formatting, documentation, and code-style changes were made in some in-scope contracts.
- The Solidity version was upgraded to 0.8.20 for all in-scope contracts.

## Security Model and Trust Assumptions

This new upgrade introduces trust assumptions that are mostly related to the new governance contract:

- The owner of the `Governance` and `TimelockValidator` contracts is anticipated to be a multisig setup conforming to industry standards and incorporating the use of cold wallets.
- The security council is envisioned to be a multisig entity characterized by diversity, substantial size, and a high decision-making threshold. As of the time of this audit, the exact design and composition of the security council are still under development.
- In an event where both the owner and the security council are compromised, they still have the capability to execute immediate actions. The expectation is that these entities always act with the userbase's best interests in mind.
- The protocol is supposed to set a delay that provides users with enough time to withdraw their funds in case of any suspicious activities.

### Privileged Roles

- **`Governance` Contract Owner:** Possesses the authority to implement significant changes within the protocol, albeit with a built-in delay to allow for community reaction and response.
- **Security Council:** The only actor that can bypass the delay in case of emergencies or immediate threats.
- **`ValidatorTimelock` Contract Owner:** Possesses the authority to implement significant changes by updating the verifier EOA address and the minimum delay required between committing and executing batches.

The design of these roles shows a balance between centralized control and distributed trust, aiming to safeguard the protocol while enabling effective governance and rapid response to any arising challenges or threats.

## Medium Severity

### Overwriting ERC-20 Metadata Can Cause Unexpected Behaviors

The `L2StandardERC20` contract is the default contract that is deployed when any ERC-20 token is bridged for the first time. This contract has been extended with a [`reinitializeToken` function](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2StandardERC20.sol#L104) that allows the Beacon owner to overwrite the `symbol`, `name`, and `decimals` state variables. This feature is particularly beneficial when token developers aim to deploy an official custom contract on the L2, enabling differentiation between the official and default token by altering the symbol and the name. While the rationale for updating the token symbol and name is valid, modifying the decimal value could result in unpredictable behavior and thus introduce significant risk. Furthermore, note that by [setting a new name](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2StandardERC20.sol#L117) in the `EIP712Upgradeable` contract through the `ERC20PermitUpgradeable` contract, previously signed permits will become invalid.

To mitigate these risks, consider removing the option of overwriting the `decimals` value in the `reinitializeToken` function. Moreover, consider issuing clear warnings regarding any changes in the token's name in order to ensure that users are fully aware of the potential invalidation of their previously signed permits.

***Update:** Resolved in [pull request #139](https://github.com/matter-labs/era-contracts/pull/139) at commit [a6ceba0](https://github.com/matter-labs/era-contracts/pull/139/commits/a6ceba003ae6db85d5bea097b286763864bf4263). The `decimals` overwrite was removed from the function.*

### Critical and High Vulnerabilities in Yarn Module Dependencies

The project's current dependencies include versions of yarn modules that are known to have critical and high vulnerabilities. The following dependencies are not imported directly but are nonetheless included as part of other project dependencies:

In the [`era-contracts` repository](https://github.com/matter-labs/era-contracts/tree/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33):

- [`lodash` (4.17.20)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L7163)
- [`json5` (0.5.1)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L6714)
- [`get-func-name` (2.0.0)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L5387)
- [`underscore` (1.9.1)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L10602)
- [`minimatch` (3.0.4)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L7529)
- [`crypto-js` (3.3.0)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L3400)
- [`browserify-sign` (4.0.0)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L2646)
- [`http-cache-semantics` (4.0.0)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L5967)
- [`flat` (4.1.0)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L5122)
- [`node-fetch` (1.7.3)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L7908)
- [`async` (2.6.3)](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/yarn.lock#L1829-L1839)

In the [`era-system-contracts` repository](https://github.com/matter-labs/era-system-contracts/tree/0b238cdf831f809584fec3131904d77987b7368d):

- [`get-func-name` (2.0.0)](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/yarn.lock#L2767)

To mitigate the risks associated with these vulnerabilities, consider upgrading these modules to versions that have resolved those issues. This may involve updating the primary dependencies that include these modules. If the vulnerable modules are part of unmaintained projects, consider seeking alternative modules that offer similar functionality without the security risks. In cases where immediate replacement or upgrading is not feasible, it is crucial to document these issues clearly and address the potential risks in the project's documentation and security protocols. This proactive approach ensures awareness and readiness to handle any security challenges that might arise from these vulnerabilities.

***Update:** Partially resolved in [pull request #98](https://github.com/matter-labs/era-system-contracts/pull/98) at commit [ada1bac](https://github.com/matter-labs/era-system-contracts/pull/98/commits/ada1bace3556398a1b0529bbb6aab5c96d83c145), and in [pull request #153](https://github.com/matter-labs/era-contracts/pull/153) at commit [e9246e3](https://github.com/matter-labs/era-contracts/pull/153/commits/e9246e3bf31fac9b306082c3cc5ddb78fe9a2909). The Matter Labs team stated:*

> *We upgraded most of the listed dependencies, except for `flat` and `minimatch`. These dependencies belong to the Hardhat gas reporter which is still in use in our repo today. Since the main product of the repo is smart contracts, the corresponding JavaScript vulnerabilities cannot be exploited.*

*Furthermore, it was recommended to set up Dependabot to monitor vulnerable dependencies and keep them up to date more automatically.*

## Low Severity

### `minDelay` Set to Zero Undermines Security Council Purpose

The `Governance` contract is a timelock that allows scheduling operations that make critical changes to the protocol. These scheduled operations can be executed after waiting for a [`minDelay`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol#L35) period in seconds. During construction or through a scheduled operation, this `minDelay` can be set to zero (or a low value).

This option of a zero `minDelay` has the following implications:

- A compromised owner can perform malicious actions immediately.
- Hence, the role of the security council to skip the delay is obsolete.
- Users do not have enough time to withdraw their funds.

To mitigate these risks, consider defining a constant minimum limit for `minDelay` (e.g., by facilitating the [`UPGRADE_NOTICE_PERIOD` constant](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Config.sol#L50)), thereby allowing adequate time for stakeholders to respond to any proposed modifications.

***Update:** Acknowledged, not resolved. While the team intends to have a non-zero `minDelay` after the initial stage, a minimal `minDelay` has not been hard coded. The Matter Labs team stated:*

> *At the initial stage of the protocol, the `minDelay` is 0. It is part of the initial training wheels of the protocol to allow for swift reaction in case of a needed emergency upgrade. While the alternative to achieve the same effect is to leverage the security council (basically set the security council to be the same entity as the owner of the Governance), having it as zero is more explicit and easier to maintain.*

### Undisclosed Functionality Mismatch in L1 and L2 Token Functions Post-Bridging

When bridging tokens from L1 to L2, by default, the [`L2StandardERC20` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2StandardERC20.sol) will be deployed initially. However, this default implementation can introduce a gap in functionalities when compared to their L1 counterparts, such as rebase methods or voting capabilities. This discrepancy can cause confusion for users or developers trying to interact with these tokens like they would on L1.

To enhance transparency, consider adding a disclaimer to the existing note [in the documentation](https://era.zksync.io/docs/reference/concepts/bridging-asset.html) as well as to the ERC-20 bridge contracts documentation [[1](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1ERC20Bridge.sol#L23-L25), [2](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2ERC20Bridge.sol#L19)]. In addition, the user interface of the bridge, which is controlled by Matter Labs, should inform users of the potential limitations in token functionality post-bridging.

***Update:** Resolved in [pull request #140](https://github.com/matter-labs/era-contracts/pull/140) at commit [5cbf05b](https://github.com/matter-labs/era-contracts/pull/140/commits/5cbf05ba8cdfc4c74646299088559b75de3c94c4), and in [pull request #845](https://github.com/matter-labs/zksync-web-era-docs/pull/845) at commit [82232bc](https://github.com/matter-labs/zksync-web-era-docs/pull/845/commits/82232bc136f27adea62a173448390ea3adeeffbf).*

### Inaccurate Attribution in `LibMap.sol`

In the `LibMap.sol` contract, specifically at [line 5](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/LibMap.sol#L5), the authorship is attributed to Solady. However, upon examination, it is clear that the code is not directly sourced from Solady but rather draws inspiration from their work. This misattribution could lead to confusion regarding the origins and the licensing of the code.

To maintain clarity and proper intellectual property acknowledgment, consider revising the comment to accurately reflect the nature of Solady's influence, perhaps indicating that the implementation is inspired by Solady's work rather than directly copied from there.

***Update:** Resolved in [pull request #141](https://github.com/matter-labs/era-contracts/pull/141) at commit [9712419](https://github.com/matter-labs/era-contracts/pull/141/commits/97124192ecfa6d234c281d1f1d3d99e51830c773).*

### Documentation Mismatch

Throughout the codebase, there are several documentation mismatches:

1. In the `Governance.sol` contract, specifically within the [`cancel` method](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol#L154), the documentation indicates that both the owner and the `securityCouncil` have the ability to cancel. However, the implementation restricts this action solely to the owner through the `onlyOwner` modifier. This means in the event of the owner account getting compromised, the `securityCouncil` cannot intervene.
2. In the `L2ContractHelper` contract, the `IL2Messenger` interface is described for sending arbitrary-length messages from L2 to L1. It describes the four parameters `senderAddress`, `isService`, `key`, and `value` of the underlying operation, but then [refers to `isService` as `marker`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/L2ContractHelper.sol#L14). Consider sticking to one word for consistency.
3. In `LibMap.sol`, the [`_index` parameter](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/LibMap.sol#L34) of the `set` function is inaccurately described. The documentation states "The index of the uint32 value to retrieve", whereas it is used for setting the value.
4. [The documentation](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L22) of the `verifierParams` element of the `ProposedUpgrade` struct says that "If either of its fields is 0, the params will not be updated". However, in the [`_setVerifierParams` function](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L122), the action of setting new parameters is only skipped when *all* parameters are zero. Consider correcting the documentation to match the implementation.

***Update:** Resolved in [pull request #142](https://github.com/matter-labs/era-contracts/pull/142) at commit [a320b9b](https://github.com/matter-labs/era-contracts/pull/142/commits/a320b9b4e55b6f58e74dc79a4bd9cd39e44b174f).*

### Upgrade Validation and Execution Is Not Strict

The [`BaseZkSyncUpgrade` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol) is an abstract contract used to perform standardized upgrades on the rollup. To ensure stricter execution and validation in this process, consider the following suggestions.

The `DefaultUpgrade` contract extends the `BaseZkSyncUpgrade` contract to invoke its functions from the overridden [`upgrade` function](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/DefaultUpgrade.sol#L25) using the values passed in through the `ProposedUpgrade` struct. In order to enforce that the new values will be set through this struct, and given that the `BaseZkSyncUpgrade` functions will only execute on non-zero inputs (otherwise it will be a no-op), consider moving the invoked functions from `DefaultUpgrade.upgrade` to `BaseZkSyncUpgrade.upgrade` to provide a stricter execution through the parent contract.

In addition, the [`_setVerifier` function](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L106) is used to set the verifier contract that will be used on L1 to verify the ZK proofs of the L2 rollup. As the documentation explains, batches that have been committed but not verified with the old verifier cannot be verified afterwards.

To prevent this mistake on a smart contract level, consider checking that the number of batches verified matches the number of the batches committed [in the storage](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Storage.sol#L117-L121).

***Update:** Resolved in [pull request #158](https://github.com/matter-labs/era-contracts/pull/158/commits/b34ca08fc6a38a25223f0e19ebe0ff11622e07b6) at commit [b34ca08](https://github.com/matter-labs/era-contracts/pull/158/commits/b34ca08fc6a38a25223f0e19ebe0ff11622e07b6). The Matter Labs team stated:*

> *We decided to not check that all the batches are verified, due to the following reasons:*
>
> 1. *Firstly, it is not the only thing that needs to be checked. For instance, we need to ensure that all the batches with the old version have been committed prior to executing the upgrade. This cannot be done on-chain.*
> 2. *The following scenario is possible:*
>    - *We may start an upgrade (that fixes some theoretical issue with the verifier, i.e., the system does not change its logic but there is an edge case whereby a batch may become unprovable and we are trying to fix it).*
>    - *Let's assume that we introduced a delay in upgrades (i.e., they are not instant). During the waiting period, the issue has been triggered. Meaning, we cannot achieve the "all committed blocks must be verified" requirement without the upgrade itself.*
>    - *Now, in order to turn off the "all committed blocks must be verified" requirement, we will have to restart the waiting period (or do an emergency upgrade) to use the upgrade implementation that does not enforce it.*
>
> *While the benefits are clear, it introduces edge cases that are rather easier to avoid by just always double-checking the requirements off-chain before triggering the upgrade.*

## Notes & Additional Information

### Misleading Contract Name

The [`Governance` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol), while descriptive of its operational role, can cause confusion given its name. The term "Governance" could be perceived as encompassing all governance aspects, such as voting, proposal submissions, and community decision-making. However, as [the documentation](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol#L10) suggests, the purpose of this contract is to act as a timelock for operations that change critical properties and functionalities of the protocol.

For clarity, consider naming the contract in a way that relates to its implementation (e.g., "TimelockedGovernor" or "UpgradeScheduler").

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *The current name was used because this contract is intended to serve as the `governor` of the main `DiamondProxy`. While it is true that switching to a name that better represents the functionality of the contract could be considered, the `Governance` contract has already been deployed. To avoid the risk-prone process of migrating the governance, and the discrepancies between the open-source repository and the deployed code, it is better to avoid renaming the contract at this point.*

### Multiple Instances of Missing Named Parameters in Mappings

Since [Solidity 0.8.18](https://github.com/ethereum/solidity/releases/tag/v0.8.18), developers can utilize named parameters in mappings. This means mappings can take the form of `mapping(KeyType keyName => ValueType valueName)`. This updated syntax provides a more transparent representation of a mapping's purpose.

Throughout the codebase, there are multiple mappings without named parameters:

- The [`selectorToFacet`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/Diamond.sol#L50) and [`facetToSelectors`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/Diamond.sol#L51) state variable in the [`Diamond` library](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/Diamond.sol)
- The [`map`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/LibMap.sol#L9) state variable in the [`LibMap` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/LibMap.sol)
- The [`data`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L28) state variable in the [`PriorityQueue` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/PriorityQueue.sol)
- The [`immutableDataStorage`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/ImmutableSimulator.sol#L21) state variable in the [`ImmutableSimulator` contract](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/ImmutableSimulator.sol)
- The [`balance`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/L2EthToken.sol#L20) state variable in the [`L2EthToken` contract](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/L2EthToken.sol)
- The [`rawNonces`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol#L36) and [`nonceValues`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol#L41) state variables in the [`NonceHolder` contract](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol)
- The [`batchHash`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/SystemContext.sol#L55) state variable in the [`SystemContext` contract](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/SystemContext.sol)
- The [`timestamps`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol#L32) state variable in the [`Governance` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol)
- The [`isWithdrawalFinalized`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1ERC20Bridge.sol#L34), [`depositAmount`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1ERC20Bridge.sol#L38), and [`totalDepositedAmountPerUser`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1ERC20Bridge.sol#L56) state variables in the [`L1ERC20Bridge` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1ERC20Bridge.sol)
- The [`isWithdrawalFinalized`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1WethBridge.sol#L55) state variable in the [`L1WethBridge` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1WethBridge.sol)
- The [`l1TokenAddress`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2ERC20Bridge.sol#L32) state variable in the [`L2ERC20Bridge` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2ERC20Bridge.sol)

Consider adding named parameters to the mappings in order to improve the readability and maintainability of the codebase.

***Update:** Resolved in [pull request #143](https://github.com/matter-labs/era-contracts/pull/143) at commit [647a798](https://github.com/matter-labs/era-contracts/pull/143/commits/647a798e5257b3d113da265b69e369b756bf2789), and in [pull request #96](https://github.com/matter-labs/era-system-contracts/pull/96) at commit [8b19ffc](https://github.com/matter-labs/era-system-contracts/pull/96/commits/8b19ffc3ae126ff146dbffb5ede12ff59fc86a78).*

### Incomplete Documentation of Differences Between `WETH9` and `L2Weth` Contracts

The documentation for the [`L2Weth` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2Weth.sol#L13-L17) outlines its differences from the `WETH9` contract. However, this list is not exhaustive. Key functionalities like the added `depositTo` and `withdrawTo` methods, along with the bridge functions, are missing.

To enhance clarity and accuracy, consider expanding the list of differences to include these additional features or rephrasing the documentation to indicate that the listed differences are not exhaustive.

***Update:** Resolved in [pull request #144](https://github.com/matter-labs/era-contracts/pull/144) at commit [0f5d29d](https://github.com/matter-labs/era-contracts/pull/144/commits/0f5d29d39bb4a7409da0ebb032b01abbeffee7f7). The `depositTo` and `withdrawTo` functions were added to the documentation as WETH9 differences. The bridge-related differences were not specifically mentioned, but these functions are not callable by users.*

### Unnecessary Cast

At [line 328](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1ERC20Bridge.sol#L328) of `L1ERC20Bridge`, the `l2TokenBeacon` variable is already an `address` type, but is unnecessarily cast explicitly as an `address`.

To improve the overall clarity, intent, and readability of the codebase, consider removing unnecessary casts.

***Update:** Resolved in [pull request #145](https://github.com/matter-labs/era-contracts/pull/145) at commit [7759538](https://github.com/matter-labs/era-contracts/pull/145/commits/7759538d6de1bd3cc14d9120822bb174fac9987b).*

### State Variable Visibility Not Explicitly Declared

Throughout both codebases, there are state variables that lack an explicitly declared visibility.

In the [`era-contracts` repository](https://github.com/matter-labs/era-contracts/tree/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33):

- The state variables [`DIAMOND_INIT_SUCCESS_RETURN_VALUE`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/Diamond.sol#L17-L18) and [`DIAMOND_STORAGE_POSITION`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/Diamond.sol#L21) in [`Diamond.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/Diamond.sol)
- The state variable [`CREATE2_PREFIX`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/common/libraries/L2ContractHelper.sol#L12) in [`L2ContractHelper.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/common/libraries/L2ContractHelper.sol)
- The state variable [`availableGetters`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2StandardERC20.sol#L25) in [`L2StandardERC20.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2StandardERC20.sol)

In the [`era-system-contracts` repository](https://github.com/matter-labs/era-system-contracts/tree/0b238cdf831f809584fec3131904d77987b7368d):

- the state variables [`DEPLOY_NONCE_MULTIPLIER`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol#L28) and [`MAXIMAL_MIN_NONCE_INCREMENT`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol#L31) in [`NonceHolder.sol`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol)

For clarity, consider always explicitly declaring the visibility of variables, even when the default visibility matches the intended visibility.

***Update:** Resolved in [pull request #97](https://github.com/matter-labs/era-system-contracts/pull/97) at commit [20a8fb7](https://github.com/matter-labs/era-system-contracts/pull/97/commits/20a8fb7ac7335c476963926975d4284e9eb5a0af), and in [pull request #146](https://github.com/matter-labs/era-contracts/pull/146/commits/a0363c97daa569f73c805535bc6535b5320f1d1b) at commit [93c019d](https://github.com/matter-labs/era-contracts/pull/146/commits/93c019dc183f9b99aafc5ac562f46df44e458ad7).*

### Lack of Security Contact

Providing a specific security contact (such as an email or ENS name) within a smart contract significantly simplifies the process for individuals to communicate if they identify a vulnerability in the code. This practice is quite beneficial as it permits the code owners to dictate the communication channel for vulnerability disclosure, eliminating the risk of miscommunication or failure to report due to a lack of knowledge on how to do so. Even interfaces and libraries, which may not be deployed in and of themselves, may be used by another protocol, which would need a security contact when coming across a vulnerability in the integration.

Throughout both codebases, the following libraries and interfaces do not have a security contact.

In the [`era-contracts` repository](https://github.com/matter-labs/era-contracts/tree/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33):

- The [`IGovernance`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/IGovernance.sol) interface
- The [`IL1Bridge`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/interfaces/IL1Bridge.sol) interface
- The [`LibMap`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/LibMap.sol) library

In the [`era-system-contracts` repository](https://github.com/matter-labs/era-system-contracts/tree/0b238cdf831f809584fec3131904d77987b7368d):

- The [`IComplexUpgrader`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/interfaces/IComplexUpgrader.sol) interface
- The [`ICompressor`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/interfaces/ICompressor.sol) interface
- The [`IKnownCodesStorage`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/interfaces/IKnownCodesStorage.sol) interface
- The [`IL1Messenger`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/interfaces/IL1Messenger.sol) interface
- The [`ISystemContext`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/interfaces/ISystemContext.sol) interface
- The [`ISystemContextDeprecated`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/interfaces/ISystemContextDeprecated.sol) interface
- The [`ISystemContract`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/interfaces/ISystemContract.sol) abstract contract

Consider placing a NatSpec comment containing a security contact above the contract, library, or interface definitions. Using the `@custom:security-contact` convention is recommended as it has been adopted by the [OpenZeppelin Wizard](https://wizard.openzeppelin.com/) and the [ethereum-lists](https://github.com/ethereum-lists/contracts#tracking-new-deployments).

***Update:** Resolved in [pull request #149](https://github.com/matter-labs/era-contracts/pull/149) at commit [c6ed3fa](https://github.com/matter-labs/era-contracts/pull/149/commits/c6ed3fa163b7378fe39b08883e4f00e343cf0221), and in [pull request #99](https://github.com/matter-labs/era-system-contracts/pull/99) at commit [f4a906e](https://github.com/matter-labs/era-system-contracts/pull/99/commits/f4a906eb5b2de7e35a547d236d727d916641af29).*

### Lack of Indexed Event Parameters

Throughout the codebase, two events do not have their parameters indexed:

- The [`ChangeSecurityCouncil`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/IGovernance.sol#L74) event in [`IGovernance.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/IGovernance.sol)
- The [`NewValidator`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/ValidatorTimelock.sol#L30) event in [`ValidatorTimelock.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/ValidatorTimelock.sol)

Consider [indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events) to improve the ability of off-chain services to search and filter for specific events.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *Using Indexed parameters could indeed be preferred. However, at this point, it is better not to add them due to the following considerations:*
>
> - *These contracts are not upgradable. To upgrade `ValidatorTimelock`, we need to deploy a new one, introducing additional risks during the process of migrations as the commitment times between batches will not be migrated. The migration of governance is even more risk-prone and time-consuming.*
> - *These changes might be breaking for those who already track these events.*

### Unused Constants

The following constants were identified as being unused:

- [`L2_BYTECODE_COMPRESSOR_SYSTEM_CONTRACT_ADDR`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/common/L2ContractAddresses.sol#L33)
- [`INITIAL_STORAGE_CHANGE_SERIALIZE_SIZE`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Config.sol#L23)
- [`REPEATED_STORAGE_CHANGE_SERIALIZE_SIZE`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Config.sol#L27)
- [`UPGRADE_NOTICE_PERIOD`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Config.sol#L50)
- [`MAX_PUBDATA_PER_BATCH`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Config.sol#L66)
- [`PRIORITY_TX_MAX_PUBDATA`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Config.sol#L71)

Consider clarifying whether these constants are necessary. Otherwise, consider removing them.

***Update:** Resolved in [pull request #154](https://github.com/matter-labs/era-contracts/pull/154) at commit [23a7381](https://github.com/matter-labs/era-contracts/pull/154/commits/23a7381f2edf4a3b78fe40335bbd1b2d1e1844ef).*

### Non-Explicit Imports Are Used

The use of non-explicit imports in the codebase can decrease the code clarity, and may create naming conflicts between locally defined and imported variables. This is particularly relevant when multiple contracts exist within the same Solidity files or when inheritance chains are long.

Throughout the codebases, global imports are being used. For instance:

- All imports in [`BootloaderUtilities.sol`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/BootloaderUtilities.sol)
- 1 import in [`ImmutableSimulator.sol`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/ImmutableSimulator.sol)
- 3 imports in [`MsgValueSimulator.sol`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/MsgValueSimulator.sol)
- 2 imports in [`NonceHolder.sol`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol)
- 5 imports in [`BaseZkSyncUpgrade.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol)
- All imports in [`DefaultUpgrade.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/DefaultUpgrade.sol)
- All imports in [`Diamond.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/Diamond.sol)
- All imports in [`Merkle.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/libraries/Merkle.sol)
- All imports in [`Storage.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Storage.sol)
- All imports in [`ValidatorTimelock.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/ValidatorTimelock.sol)
- All imports in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1ERC20Bridge.sol)
- 11 imports in [`L1WethBridge.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1WethBridge.sol)
- 7 imports in [`L2ERC20Bridge.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2ERC20Bridge.sol)
- All imports in [`L2StandardERC20.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2StandardERC20.sol)
- All imports in [`L2Weth.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2Weth.sol)
- 5 imports in [`L2WethBridge.sol`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2WethBridge.sol)

Following the principle that clearer code is better code, consider using named import syntax `import {A, B, C} from "X";` to explicitly declare which contracts are being imported.

***Update:** Resolved in [pull request #100](https://github.com/matter-labs/era-system-contracts/pull/100) at commit [9926470](https://github.com/matter-labs/era-system-contracts/pull/100/commits/99264704c9b04eec34ae76fe3c2c06bb189b2fe3), and in [pull request #155](https://github.com/matter-labs/era-contracts/pull/155/) at commit [df43911](https://github.com/matter-labs/era-contracts/pull/155/commits/df439112970dd8376502feab53b28a80f3b7d9e8).*

### Literal Number With Many Digits

In the [`SystemContext`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/SystemContext.sol) contract, the [block difficulty](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/SystemContext.sol#L44) is defined as `2500000000000000`. Literal numbers with many digits are hard to parse and harm the readability of the code.

Consider using the [scientific notation](https://docs.soliditylang.org/en/latest/types.html#rational-and-integer-literals) instead.

***Update:** Resolved in [pull request #101](https://github.com/matter-labs/era-system-contracts/pull/101) at commit [0666f02](https://github.com/matter-labs/era-system-contracts/pull/101/commits/0666f02ba5545ff75d0119f7b565ba1fbd4f7d15).*

### Unused Import

The import of [`SystemContractHelper`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/KnownCodesStorage.sol#L8) is not used throughout the [`KnownCodesStorage`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/KnownCodesStorage.sol) contract.

Consider removing this import to improve the overall clarity and readability of the codebase.

***Update:** Resolved in [pull request #102](https://github.com/matter-labs/era-system-contracts/pull/102) at commit [8152d5c](https://github.com/matter-labs/era-system-contracts/pull/102/commits/8152d5c862922f9998eb81fab66e3559e1d19e67).*

### Typographical Errors

The following typographical errors were identified throughout the codebases:

- ["Propage"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol#L228C16-L228C55) should be "Propagate"
- ["where"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol#L28) should be "when"
- The following revert strings should say "is allowed":
  - ["Only security council allowed to call this function"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol#L65)
  - ["Only governance contract itself allowed to call this function"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/governance/Governance.sol#L59)
- The following comments should say "[...] the L2 bridge [...]":
  - ["[...] the L1 -> L2 transaction for deploying L2 bridge implementation"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1WethBridge.sol#L71-L72)
  - ["[...] the L1 -> L2 transaction for deploying L2 bridge proxy"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1WethBridge.sol#L73-L74)
  - ["No factory deps are needed for L2 bridge proxy, [...]"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/bridge/L1WethBridge.sol#L125)
- ["Structure used to represent zkSync transaction"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/L2ContractHelper.sol#L116) should be "a zkSync transaction" or "zkSync transactions"
- The [list of parameters](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/L2ContractHelper.sol#L10) in an L2 to L1 message is missing a comma
- ["The struct that describes for the users will be charged for pubdata for L1->L2 transactions"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/Storage.sol#L73) should be "The struct that describes whether users [...]"
- ["occured"](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L64) should be "occurred"

***Update:** Resolved in [pull request #156](https://github.com/matter-labs/era-contracts/pull/156) at commit [3d7cc8e](https://github.com/matter-labs/era-contracts/pull/156/commits/3d7cc8e0cc5a5ac2705d757bb855795222dd57c3), and in [pull request #103](https://github.com/matter-labs/era-system-contracts/pull/103) at commit [508f6e8](https://github.com/matter-labs/era-system-contracts/pull/103/commits/508f6e802365971a05e18afc672532b5d11d673f).*

### Missing and Incomplete Docstrings

Throughout the codebases, some parts are missing docstrings while some docstrings are incomplete:

- The [`fallback`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/MsgValueSimulator.sol#L35-L58) function of the [`MsgValueSimulator` contract](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/MsgValueSimulator.sol) does not have any docstrings.
- The [`isNonceUsed`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol#L150-L153) function of the [`NonceHolder` contract](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/contracts/NonceHolder.sol) does not have any docstrings.
- In the [`upgrade`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L62-L68) function of the [`BaseZkSyncUpgrade` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol), the `_proposedUpgrade` parameter is not documented.
- The [`initialize`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2ERC20Bridge.sol#L40-L51) function of the [`L2ERC20Bridge` contracts](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2ERC20Bridge.sol) does not have any docstrings.
- The [`reinitializeToken`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2StandardERC20.sol#L104-L122) function of the [`L2StandardERC20` contract](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/zksync/contracts/bridge/L2StandardERC20.sol) does not use proper NatSpec comments and none of its parameters are documented.

Consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #157](https://github.com/matter-labs/era-contracts/pull/157) at commit [efab770](https://github.com/matter-labs/era-contracts/pull/157/commits/efab7708ef2e69f0980b6336d7b49bac95ce0cab), and in [pull request #104](https://github.com/matter-labs/era-system-contracts/pull/104) at commit [16bfe51](https://github.com/matter-labs/era-system-contracts/pull/104/commits/16bfe51d5c394fc72258cf7d2e36303071af1244).*

### Function Is Updating the State Without Event Emissions

In the [`constructor`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/ValidatorTimelock.sol#L44) of the `ValidatorTimelock` contract, the initial values for the `executionDelay` and `validator` state variables are set. However, the corresponding events, [`NewExecutionDelay`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/ValidatorTimelock.sol#L27) and [`NewValidator`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/ValidatorTimelock.sol#L30), are not emitted at this point. While these state variables can optionally be changed later, and such changes are communicated through the events, the absence of initial values means that the complete history is not accurately reflected in the emitted events.

Consider emitting events in the `constructor` in order to enable off-chain indexers to track the complete history for these particular values.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *The addition of these events is preferred. However, to upgrade `ValidatorTimelock`, we need to deploy a new one, introducing additional risks during the process of migrations as the commitment times between batches will not be migrated. So, to avoid additional risks with redeployment, or discrepancies between the open-source repo and the deployed code, it is better not to introduce these events at this point.*

## Conclusion

This system upgrade introduces important measures aimed at improving the safety of the protocol. Delaying the protocol changes through the `Governance` contract and the finalization of L2 batches through the `ValidatorTimelock` contract allows the stakeholders to act on any suspicious activity in time. Of course, such measures are only as safe as the implementation of privileged roles and security properties, which is still under exploration for the security council.

The risk of vulnerabilities in yarn dependencies and the overwriting of token metadata have been presented as medium-severity issues. Other than that, we found the code quality to be good and only reported low-severity issues and improvement recommendations. Throughout the audit period, the Matter Labs team was helpful and responsive in answering our questions.
