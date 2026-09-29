# ZKsync State Transition Diff Audit

Source: [https://www.openzeppelin.com/news/zksync-state-transition-diff-audit](https://www.openzeppelin.com/news/zksync-state-transition-diff-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Privileged Roles and Trust Assumptions](#privileged-roles-and-trust-assumptions)
- [Medium Severity](#medium-severity)
  - [StateTransitionManager Cannot Unfreeze Chains](#statetransitionmanager-cannot-unfreeze-chains)
  - [Ambiguous PubdataPricingMode Configuration](#ambiguous-pubdatapricingmode-configuration)
- [Low Severity](#low-severity)
  - [Emitting Deleted Value](#emitting-deleted-value)
  - [Lack of Events](#lack-of-events)
  - [StateTransitionManager Role-Specific Functions Cannot Be Reached in Admin Facet](#statetransitionmanager-role-specific-functions-cannot-be-reached-in-admin-facet)
  - [Lack of Validation](#lack-of-validation)
  - [PubdataSource Does Not Account for Validium Mode](#pubdatasource-does-not-account-for-validium-mode)
  - [Missing and Incomplete Documentation](#missing-and-incomplete-documentation)
- [Notes & Additional Information](#notes-additional-information)
  - [Unused Imports](#unused-imports)
  - [Incorrect Documentation](#incorrect-documentation)
  - [Inexplicit Struct Declaration](#inexplicit-struct-declaration)
  - [Redundant Code](#redundant-code)
  - [Typographical Errors](#typographical-errors)
  - [Missing Named Parameters in Mappings](#missing-named-parameters-in-mappings)
  - [Using int/uint Instead of int256/uint256](#using-intuint-instead-of-int256uint256)
  - [Lack of Indexed Event Parameters](#lack-of-indexed-event-parameters)
  - [Naming Suggestions](#naming-suggestions)
  - [Function Is Unnecessarily payable](#function-is-unnecessarily-payable)
  - [Use of Non-Upgradeable Library in Upgradeable Contract](#use-of-non-upgradeable-library-in-upgradeable-contract)
- [Conclusion](#conclusion)

## Summary

Type
:   Layer 2

Timeline
:   From 2024-03-18
:   To 2024-03-27

Languages
:   Solidity

Total Issues
:   19 (18 resolved, 1 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   2 (2 resolved)

Low Severity Issues
:   6 (5 resolved, 1 partially resolved)

Notes & Additional Information
:   11 (11 resolved)

## Scope

We diff audited the [matter-labs/era-contracts](https://github.com/matter-labs/era-contracts) repository at BASE commit [f29f2b7](https://github.com/matter-labs/era-contracts/commit/f29f2b72f999d6b91785accfb84eafb371620214) and HEAD commit [d5c5d7a](https://github.com/matter-labs/era-contracts/commit/d5c5d7a7c3a458f131e5de72c6c134a172e6763d).

In scope were the following files:

```
 l1-contracts/
└─ contracts/
   └─ state-transition/
      ├─ IStateTransitionManager.sol
      ├─ StateTransitionManager.sol
      ├─ ValidatorTimelock.sol
      ├─ chain-deps/
      │  ├─ DiamondInit.sol
      │  ├─ DiamondProxy.sol
      │  ├─ ZkSyncStateTransitionStorage.sol
      │  └─ facets/
      │     ├─ Admin.sol
      │     ├─ Executor.sol
      │     ├─ Getters.sol
      │     ├─ Mailbox.sol
      │     └─ ZkSyncStateTransitionBase.sol
      ├─ l2-deps/
      │  └─ ISystemContext.sol
      └─ libraries/
         └─ TransactionValidator.sol
```

## System Overview

This upgrade introduces Matter Labs' latest development efforts of implementing the ZK Stack. More specifically, this architectural overhaul requires abstractions to the Layer 1 (L1) contracts to enable deploying so-called ZK Chains, which are ZK rollup instances just like the Era chain.

The following is a summary of the changes.

#### `StateTransitionManager`

This new contract is responsible for deploying and managing ZK Chains. It has two roles: the owner who is fully in charge and the admin who is in charge of a subset of the functions. ZK Chains can be created by the `BridgeHub` address. This deploys a `DiamondProxy` contract and initializes it with a diamond cut. It also upgrades the chain through the `Admin` facet right away to set the given chain ID in the `SystemContext` contract on the L2 side.

Regarding managing features, the owner is capable of defining how the ZK Chains are initialized and upgraded. Upgrades are also defined through diamond cuts. These can be set for any protocol version while also maintaining the protocol version state variable of the contract as a source of truth for its ZK Chains. This means for an upgrade from version X to Y, the diamond cut to set the chain's version to Y is defined for version X. This allows flexibility for consecutive upgrades but also laggard ZK Chains to skip versions. Other capabilities involve freezing and unfreezing a specific chain, reverting a chain's batches, and setting the `ValidatorTimelock` address.

#### `ValidatorTimelock`

The `ValidatorTimelock` is a contract set as a validator for a ZK Chain. It supports the interface of the `Executor`'s state-transition functions (commit, prove, revert, execute) and forwards the call to the ZK Chain, while making sure that a delay between committing and executing has passed. This upgrade has generalized the contract to be suitable for all ZK Chains of a `StateTransitionManager`. Hence, given the chain ID, the call is forwarded to the respective ZK Chain (i.e., `DiamondProxy`). Validators that can call the state-transition functions of the `ValidatorTimelock` can be set per chain ID by their admin. For backwards compatibility, there is a redundancy in the interface to be chain-ID-specific for the new ZK Chains, and non-chain-ID-specific for the existing Era chain. This change in interface is reflected in the `Executor` facet as well.

#### Facet Changes

**`Admin`:** Most of the changes accommodate the role change from the deprecated `Governor` to the `StateTransitionManager`. New features of the facet include:

- Setting the Pubdata pricing mode between `Rollup` and `Validium` mode. In `Validium` mode, no pubdata is committed to the `Executor`. More about it in the [ZKsync documentation](https://docs.zksync.io/zk-stack/concepts/validiums.html).
- Setting the token multiplier. ZK Chains can have one of the allowlisted base tokens as their native currency. To calculate the L2 gas costs for L1 to L2 transactions in the `Mailbox`, the ETH price needs to be converted into the base token currency given the defined nominator and denominator.
- Perform upgrades from a version. The admin or `StateTransitionManger` may execute the predefined diamond cut as an upgrade from the current version of the chain, as outlined above. The `StateTransitionManager` contract is additionally entitled to perform any diamond cuts, as done for the chain ID upgrade after initialization.

**`Executor`:** The `Executor` now supports the aforementioned `Validium` mode that does require empty Pubdata as part of the committed batch data. Furthermore, it extends the interface of the state-finalization functions (commit, prove, revert, execute) to accommodate the `ValidatorTimelock` usage.

**`Getters`:** This facet was simply extended with functions to query the new storage variables that are part of the other facets' changes.

**`Mailbox`:** The `Mailbox` was changed to support the interactions with the `BridgeHub` and shared bridge. For backwards compatibility with the Era chain specifically, the `Mailbox` still supports being called directly to finalize a withdrawal, although it is just forwarding the call to the shared bridge. Also, the `BridgeHub` may directly request L2 transactions. Lastly, the L2 gas price calculations take into account the aforementioned nominator and denominator to convert the ETH price into the base token.

## Privileged Roles and Trust Assumptions

This upgrade has shifted some roles. Below, we list each role's capabilities per contract:

**`StateTransitionManager`**:

- `setPendingAdmin` (owner, admin): Setting the pending admin who can accept the role by calling `acceptAdmin`
- `setValidatorTimelock` (owner, admin): The `ValidatorTimelock` contract address that will be set up as the only validator during ZK Chain initialization
- `setInitialCutHash` (owner): Setting the hash of the diamond cut that needs to be provided during ZK Chain initialization
- `setNewVersionUpgrade` (owner): Setting a diamond cut to be upgraded from a version while also updating the state's protocol version
- `setUpgradeDiamondCut` (owner): Setting a diamond cut to be upgraded from a version
- `freezeChain` (owner): Freezing a specific chain
- `unfreezeChain` (owner): Unfreezing a specific chain
- `revertBatches` (owner, admin): Reverting batches for a specific chain
- `registerAlreadyDeployedStateTransition` (owner): Adding an arbitrary address to the mapping of chain IDs and their respective `DiamondProxy` address
- `createNewChain` (BridgeHub): Creating a new ZK Chain that is managed by the `StateTransitionManager`

Note that the `StateTransitionManager`'s owner is in charge of defining all upgrades for its ZK Chains. This role is said to be held by the `Governance` contract which is operated by a multisig wallet and security council. During the audit, we raised concerns to the Matter Labs team about potential pitfalls with respect to the protocol version that could be introduced during the upgrade process. However, as more flexibility is desired, it is expected that the Governance role does its due diligence for the upgrade's correctness in the best interest of the user base.

**`ValidatorTimelock`**:

- `setStateTransitionManager` (owner): Setting the `StateTransitionManager` to be used to query the admin and address of a ZK Chain by chain ID
- `addValidator`, `removeValidator` (chain admin): Add/remove validators that may interact with their chain ID's `Executor`
- `setExecutionDelay` (owner): Define the minimum delay that must be waited between committing and executing batches
- State-transition functions (validator per chain ID): Forwarding the calls to the respective ZK Chain contract of the specified chain ID.

The **`Admin`** facet of a ZK Chain:

- `setPendingAdmin` (admin): Setting the pending admin who can accept the role by calling `acceptAdmin`
- `setValidator` (StateTransitionManager): Setting the validator status of the ZK Chain
- `setPorterAvailability`(StateTransitionManager): Setting the [zkPorter](https://blog.matter-labs.io/zkporter-composable-scalability-in-l2-beyond-zkrollup-2a30c4d69a75) availability
- `setPriorityTxMaxGasLimit` (StateTransitionManager): Setting the maximum L2 gas limit for L1 to L2 transactions
- `changeFeeParams` (admin, StateTransitionManager): Setting the fee parameters for L1 to L2 transactions for the ZK Chain, including `PubdataPricingMode`, `batchOverheadL1Gas`, `maxPubdataPerBatch`, `maxL2GasPerBatch`, `priorityTxMaxPubdata`, and `minimalL2GasPrice`
- `setTokenMultiplier` (admin, StateTransitionManager): Setting the token multipliers that convert the L1 base token (ETH for Ethereum mainnet) into the L2 base token
- `setValidiumMode` (admin): Setting the `PubdataPricingMode` in the fee parameters to be either `Validium` or `Rollup`
- `upgradeChainFromVersion` (admin, StateTransitionManager): Upgrading the diamond cut from a specific version as defined in the `StateTransitionManager`
- `executeUpgrade` (StateTransitionManager): Executing an arbitrary upgrade by the `StateTransitionManager`
- `freezeDiamond` (admin, StateTransitionManager): Instantly pausing the functionality of all freezable facets and their selectors
- `unfreezeDiamond` (admin, StateTransitionManager): Unpausing the functionality of all freezable facets and their selectors

For all roles and capabilities, it is expected that the parties in charge always act in the best interest of the user base and the ecosystem.

## Medium Severity

### `StateTransitionManager` Cannot Unfreeze Chains

The `StateTransitionManager` is privileged to [freeze and unfreeze](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L164-L172) the chains it manages. This is intended by calling the [respective function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L132-L150) in the `Admin` facet. The problem is that the `unfreezeChain` function of the `StateTransitionManager` mistakenly also calls the `freezeDiamond` function, thereby [leading to a revert](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L136). To recover from this frozen state, the `StateTransitionManager` is dependent upon the chain admin who may also call the `unfreezeDiamond` function.

Consider correcting the `unfreezeChain` function to allow the `StateTransitionManager` to unfreeze any frozen ZK Chain instead of reaching out to the ZK Chain admin to do the unfreezing. Also, consider implementing a unit test for this functionality.

***Update:** Resolved in [pull request #293](https://github.com/matter-labs/era-contracts/pull/293).*

### Ambiguous `PubdataPricingMode` Configuration

The [`setValidiumMode` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L89) of the `Admin` facet allows the admin role to toggle the pubdata pricing mode between `Rollup` and `Validium` as long as no batches are committed. While the function name only suggests that the mode can be changed from `Rollup` to `Validium`, the mode can freely be set (e.g., from `Rollup` to `Validium` and back to `Rollup`). Furthermore, the comment *"Validium mode can be set only before the first batch is committed"* is wrong for two reasons:

1. Batches can be committed but then [reverted](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L472) again to the initial state to set the mode differently.
2. The `PubdataPricingMode` can be set through the [`changeFeeParams` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L67) at any time.

Thus, when users request an L2 transaction through the `Mailbox` facet, they sometimes [could get charged for L1 PubData](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L162), and sometimes not. Moreover, if the `Validium` mode is motivated by [enterprise or privacy reasons](https://docs.zksync.io/zk-stack/concepts/validiums.html#potential-use-cases), a mode change to `Rollup` would entail leaking sensitive data.

Consider clarifying the intention of when and how the `PubdataPricingMode` may be changed. For example, ensure that the `PubdataPricingMode` can only be changed until the first batch is written to [`storedBatchHashes`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/ZkSyncStateTransitionStorage.sol#L86), which is not deleted during a batch revert. In addition, consider checking that the mode is not changed during `changeFeeParams`.

***Update:** Resolved in [pull request #292](https://github.com/matter-labs/era-contracts/pull/292) and [pull request #298](https://github.com/matter-labs/era-contracts/pull/298/files#diff-092566068f0ff90bac8444b21b086d15fbd1507d052fd62f4b141a03b1c87796). The Matter Labs team stated:*

> *`PubdataPricingMode` can be changed only before the first batch is processed, this is also reflected in the comment and in the doc-comments introduced with the fix in L-06.*

## Low Severity

### Emitting Deleted Value

In the `StateTransitionManager`, the `acceptAdmin` function allows the pending admin to become the admin of the contract. This finally leads to the emission of the [`NewAdmin` event](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L128). However, this event emits the old admin through the `previousAdmin` stack variable and the just-deleted `pendingAdmin` (`address(0)`) as the new admin. This makes it significantly more difficult for off-chain clients to track the admin role.

Consider emitting the `currentPendingAdmin` stack variable as the new admin instead.

***Update:** Resolved in [pull request #294](https://github.com/matter-labs/era-contracts/pull/294).*

### Lack of Events

In the `StateTransitionManager`, the following functions change the storage of the contract but do not emit an event:

- [`setValidatorTimelock`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L132)
- [`setInitialCutHash`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L137)
- [`setNewVersionUpgrade`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L142)
- [`setUpgradeDiamondCut`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L152)

This updated information includes sensitive configuration such as how the chains are upgraded for a new version. Therefore, consider emitting an event for more transparency and better monitoring capabilities.

***Update:** Resolved in [pull request #295](https://github.com/matter-labs/era-contracts/pull/295).*

### `StateTransitionManager` Role-Specific Functions Cannot Be Reached in `Admin` Facet

In the `Admin` facet, some functions are limited only to be called by the `StateTransitionManager`. For instance:

- [`setValidator`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L45)
- [`setPorterAvailability`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L51)
- [`setPriorityTxMaxGasLimit`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L58)

These functions will not be accessible as there are no such function calls from the `StateTransitionManager` contract. Furthermore, the following functions are callable by both the `admin` and the `StateTransitionManager` role, but currently not callable through the `StateTransitionManager` contract:

- [`changeFeeParams`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L67)
- [`setTokenMultiplier`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L79)
- [`upgradeChainFromVersion`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L100)

Consider adding these function calls to the `StateTransitionManager` contract to facilitate the `StateTransitionManager` role in changing the configuration of registered ZK Chains.

***Update:** Resolved in [pull request #296](https://github.com/matter-labs/era-contracts/pull/296) at commit [6c0c01c](https://github.com/matter-labs/era-contracts/pull/296/commits/6c0c01c3391336fa1272c308e3e335bbedb075e1).*

### Lack of Validation

Throughout the codebase, the following instances were identified where stronger validation can be applied:

- In the `Admin` facet, the [`setTokenMultiplier` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L79) allows the admin or `StateTransitionManager` to set the nominator and denominator which is [used by the `Mailbox`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L159-L160) to scale the L1 gas price. While the denominator can be freely set, the value 0 would [lead to a revert](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L158) in the `Mailbox` for any requested L2 transaction. Consider applying the same check when setting the value.
- In the `StateTransitionManager`, the [`setNewVersionUpgrade` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L142) allows the owner to set a diamond cut for an old protocol version. Simultaneously, the new protocol version argument overwrites the `protocolVersion` of the `StateTransitionManager` and thereby determines which version the diamond cut upgrades to. The problem is that the diamond cut also contains a `protocolVersion` in the encoded [`ProposedUpgrade` struct](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L38) as the [`initCalldata`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/libraries/Diamond.sol#L76) that then sets the ZK Chain's [`s.protocolVersion`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L255). It is possible that the encoded `protocolVersion` is not consistent with the new protocol version from the function argument. This mismatch would lead to all ZK Chains of the `StateTransitionManager` not being able to commit more batches to their `Executor` facet due to a [version check](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L227). Consider decoding the diamond cut argument to validate that the protocol versions of the upgrade align.
- The [`DiamondInit` contract initializes](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/DiamondInit.sol#L24) the storage of a ZK Chain. This includes the addresses of the `verifier`, `admin`, and `validatorTimelock` that are checked to not be zero. However, with the recent upgrade, more addresses were introduced: `bridgehub`, `stateTransitionManager`, `baseToken`, `baseTokenBridge`, and `blobVersionedHashRetriever`. These addresses are not checked to not be zero. While some of these addresses originate from trusted sources like the `BridgeHub` or the `StateTransitionManager`, consider double checking them for consistency with the existing addresses and guaranteeing the functional correctness of the chain.
- The `StateTransitionManager` can [set arbitrary addresses](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L230) as registered ZK Chain contracts per chain ID. This may include overwriting a chain ID with the zero address. By the logic of this contract, this could allow creating a new chain for this ID by passing the [zero address check](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L246-L249). Although, this it not allowed by the `BridgeHub` in charge, consider checking that upon registration of already deployed ZK Chains, the address cannot be set to zero.

***Update:** Partially resolved in [pull request #297](https://github.com/matter-labs/era-contracts/pull/297). The Matter Labs team stated:*

> *Partially fixed. We decided not to apply the suggestion for `setNewVersionUpgrade` to avoid additional complexity.*

### `PubdataSource` Does Not Account for `Validium` Mode

The `Executor` facet can handle two sources of public data inputs when committing batch information from L2: calldata and EIP-4844 blobs. This data is expected to be present when the chain operates in `Rollup` mode. However in `Validium` mode, no public data [must be present](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L50-L51). Despite operating in `Validium` mode, the first byte of `pubdataCommitments`, which indicates the [public data input source](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L40C1-L40C117), is required to be either 0 or 1 for calldata and blob source respectively. This is not accurate as the commitment data is supposed to be stored elsewhere off-chain.

For explicitness, consider extending the [`PubdataSource` enum](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-interfaces/IExecutor.sol#L22) with `None` or `Validium` and checking the first `pubdataCommitments` byte against it when the chain operates in `Validium` mode. In addition, be sure to provide a meaningful revert message when `pubdataCommitments` [does not meet a length of 1](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L51).

***Update:** Resolved in [pull request #299](https://github.com/matter-labs/era-contracts/pull/299). The Matter Labs team stated:*

> *We added the third option (validium) case to the require statement.*
>
> *We did not want to add the Validium/None case to the PubdataSource options, since the PubdataSource is a different concept from DA mode. DA mode refers to the fact that DA needs to be published or not, while PubdataSource is just the form of publishing it (if needed). This is shown by the fact that we have to read ValidiumMode from storage (since that depends on the chain permanently), while Pubdata source can be read from the function input, since it can change batch to batch.*
>
> *We also updated the error message.*

### Missing and Incomplete Documentation

Throughout the codebase, there are multiple code instances that do not have docstrings.

- The [`upgradeChainFromVersion`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L100-L120) and [`setValidiumMode`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L89-L93) functions in `Admin.sol`
- The [`registerAlreadyDeployedStateTransition`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L230-L236) and [`createNewChain`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L239) (`_diamondCut` parameter especially) functions in `StateTransitionManager.sol`

Consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec). Furthermore, the comment [*"new fields"*](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/ZkSyncStateTransitionStorage.sol#L138) in `ZkSyncStateTransitionStorage.sol` could be more meaningful (e.g., by specifying a version).

***Update:** Resolved in [pull request #298](https://github.com/matter-labs/era-contracts/pull/298).*

## Notes & Additional Information

### Unused Imports

The following imports are unused:

- [`ERA_DIAMOND_PROXY`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L19) and [`ERA_CHAIN_ID`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L19) in `StateTransitionManager.sol`
- [`UnsafeBytes`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L14), [`L2_BASE_TOKEN_SYSTEM_CONTRACT_ADDR`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L19), and [`IBridgehub`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L21) in `Mailbox.sol`
- [`FeeParams`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/DiamondInit.sol#L7) and [`ISystemContext.sol`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/DiamondInit.sol#L12) in `DiamondInit`

Consider removing unused imports for improved code clarity.

***Update:** Resolved in [pull request #300](https://github.com/matter-labs/era-contracts/pull/300).*

### Incorrect Documentation

Throughout the codebase, there are several instances of incorrect documentation:

- In the `StateTransitionManager`, the `onlyOwnerOrAdmin` modifier reverts with the message [*"Bridgehub: not owner or admin"*](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L70) on failed authorization, thus indicating the wrong contract.
- The three revert strings of the [`upgradeChainFromVersion` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L100) indicate the main (Diamond) contract *"StateTransition: ..."* as the error source, whereas other facets usually indicate the facet as a source. Thus, consider changing the message to *"Admin: ..."*.
- The revert string in the `requestL2Transaction` function says [*"legacy interface only available for era token"*](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L206), while probably *"era chain"* is meant.
- The revert string of the [`onlyBaseTokenBridge` modifier](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/ZkSyncStateTransitionBase.sol#L52) does not specify the contract, whereas the other revert strings in `ZkSyncStateTransitionBase` do.
- In the `_requestL2Transaction` function, the new scope as described in the comment [*"Using a new scope to prevent 'stack too deep' error"*](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L268) is not present anymore.
- The docstrings of the [`_deriveL2GasPrice` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L156) refer to ETH, although the price is calculated in the base token.
- The comment about the `nonce` for the `L2CanonicalTransaction` when creating a new chain says that the nonce is [*"the priority operation id"*](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L191) whereas it is the `protocolVersion`.
- The Natspec of the [`StateTransitionManagerInitializeData`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/IStateTransitionManager.sol#L15) struct parameters have leading underscores whereas the fields have no underscores.

Consider applying the above changes for a more correct documentation of the codebase.

***Update:** Resolved in [pull request #304](https://github.com/matter-labs/era-contracts/pull/304).*

### Inexplicit Struct Declaration

When the `StateTransitionManager` is initialized, a [`StoredBatchInfo` struct](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L90) is declared and hashed for later use.

For better readability, consider declaring the struct with the more explicit `key: value` syntax as seen in the [`_setChainIdUpgrade` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L177).

***Update:** Resolved in [pull request #306](https://github.com/matter-labs/era-contracts/pull/306).*

### Redundant Code

Throughout the codebase, the following instances of redundant code were identified:

- When requesting an L2 transaction through the `Mailbox` facet, two structs are handled: [`BridgehubL2TransactionRequest`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/common/Messaging.sol#L127) and [`WritePriorityOpParams`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/common/Messaging.sol#L55). The former reflects the user input of the transaction, while the latter handles the additional fields `txId`, `expirationTimestamp`, and `l2GasPrice` that are derived during scheduling of the priority operation.
- Despite the overlap of data, the fields are defined redundantly, thereby introducing an overhead in data handling and function arguments. Instead, the `WritePriorityOpParams` could simply be extended by a `BridgehubL2TransactionRequest request` field. Throughout the usage of the `WritePriorityOpParams` struct, its values are always read explicitly so that this change should not introduce any repercussions (e.g., from hashing the whole struct). Furthermore, the interface of the `internal` functions [`_requestL2Transaction`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L258), [`_serializeL2Transaction`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L289), and [`_writePriorityOp`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L316) can be simplified as all arguments are given in the `WritePriorityOpParams` struct.
- The [`onlyValidator` modifier](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L68) of the `ValidatorTimelock` has a slight redundancy of checking the mapping entry against `true` as it could also be evaluated directly.
- The `ValidatorTimelock` functions [`commitBatches`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L108) and [`commitBatchesSharedBridge`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L126) as well as [`executeBatches`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L182) and [`executeBatchesSharedBridge`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L203) implement the same function body with the only difference of the `_chainId`. Instead, consider making the `[...]SharedBridge` functions' body an `internal` function that is called by their respective external functions by forwarding the `_chainId` argument or specifying the `ERA_CHAIN_ID`. This would ease maintenance, be less error-prone, and clarify the functional difference of the interfaces.
- Some getter functions unnecessarily cast addresses, for instance the [`getBridgehub`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Getters.sol#L48), [`getStateTransitionManager`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Getters.sol#L53), [`getBaseToken`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Getters.sol#L58) and [`getBaseTokenBridge`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Getters.sol#L63) functions.

***Update:** Resolved in [pull request #308](https://github.com/matter-labs/era-contracts/pull/308).*

### Typographical Errors

Throughout the codebase, the following typographical errors were identified:

- In `Executor.sol`, a comment says [*"With the protocol upgrade we expect 8 logs: 2^10 - 1 = 1023"*](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L190), meaning 10 logs instead of 8.
- In `StateTransitionManager`, the comment [*"Cannot do it an initialization"*](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L131) should say *"during initialization"*.

***Update:** Resolved in [pull request #303](https://github.com/matter-labs/era-contracts/pull/303).*

### Missing Named Parameters in Mappings

Since [Solidity 0.8.18](https://github.com/ethereum/solidity/releases/tag/v0.8.18), developers can utilize named parameters in mappings. This means mappings can take the form of `mapping(KeyType keyName => ValueType valueName)`. This updated syntax provides a more transparent representation of a mapping's purpose.

Throughout the codebase, there are multiple mappings without named parameters:

- The [`stateTransition` state variable](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L30) in the `StateTransitionManager` contract.
- The [`upgradeCutHash` state variable](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L48) in the `StateTransitionManager` contract.
- The [`committedBatchTimestamp` state variable](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L47) in the `ValidatorTimelock` contract.

Consider adding named parameters to the mappings to improve the readability and maintainability of the code.

***Update:** Resolved in [pull request #305](https://github.com/matter-labs/era-contracts/pull/305).*

### Using `int/uint` Instead of `int256/uint256`

Within `Executor.sol`, [`int/uint`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L580) is being used instead of `int256/uint256`.

In favor of explicitness, consider replacing all instances of `int/uint` with `int256/uint256`.

***Update:** Resolved in [pull request #290](https://github.com/matter-labs/era-contracts/pull/290/files) at commit [8d771cc](https://github.com/matter-labs/era-contracts/pull/290/commits/8d771cc6b34e0b24d1e9998afa93c78c60592e79).*

### Lack of Indexed Event Parameters

Within `ValidatorTimelock.sol`, two events do not have indexed parameters:

- The [`ValidatorAdded` event](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L32)
- The [`ValidatorRemoved` event](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L35)

To improve the ability of off-chain services to search and filter for specific events, consider [indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events).

***Update:** Resolved in [pull request #309](https://github.com/matter-labs/era-contracts/pull/309). The Matter Labs team stated:*

> *We only added indexes to first params, which are "chainId".*

### Naming Suggestions

Throughout the codebase, the following naming suggestions are seen as more accurate:

- In the code, the term "StateTransition" [refers to](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L30) `DiamondProxy` contracts that have access to facets just like the Era chain. However, the term seems to be closer to the `Executor` facet's functionality of handling the L2 state, which is just one aspect of the chain. Therefore, the more general term "ZK Chain" appears to be more fitting to refer to the `DiamondProxy` contract. Consider replacing "StateTransition" with "ZK Chain" in identifiers that use it.
- The [`setValidiumMode` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L89) suggests that the mode can only be changed from `Rollup` to `Validium`, although it can be freely set. Therefore, consider naming the function `setPubdataPricingMode`.
- The [`StateTransitionManagerInitializeData` struct](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/IStateTransitionManager.sol#L15) is used to initialize the `StateTransitionManager`. However, the `governor` address is [used to set up](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L83) the `owner` role of the contract, which can be confusing. For clarity, consider calling this field `owner` instead.
- The `s.baseTokenBridge` is sometimes referred to as `sharedBridge` (e.g., [in the `Mailbox` facet](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L42) as well as in [the error message in `ZkSyncStateTransitionBase`](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/ZkSyncStateTransitionBase.sol#L53)). To avoid confusion, consider using a consistent name for the same bridge.

***Update:** Resolved in [pull request #307](https://github.com/matter-labs/era-contracts/pull/307) and [pull request #310](https://github.com/matter-labs/era-contracts/pull/310). Most of the naming suggestions were applied, while the `StateTransitionManager` contract name and its references were left unchanged. The Matter Labs team stated:*

> *In the future when there are multiple STMs each one will manage a single zone of ZK Chains, and what each zone will have in common is their State Transition function. The STMs do manage everything about the chains (I agree on this fact), but in the bigger picture the different zones will be zones of State Transitions, while every chain under the Bridgehub will be a ZK Chain. To me calling them ZK ChainManager would imply that they manage all ZK Chains, which is not true.*

### Function Is Unnecessarily `payable`

The [`bridgehubRequestL2Transaction` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L47) of the `Mailbox` facet is callable by the `BridgeHub` to forward a user's L2 transaction request. The calls to this function are done without forwarding any value since the shared bridge is intended to hold all assets. As such, there is no reason for this function to be payable.

Consider removing the `payable` keyword from the function selector in order to reduce the chances of getting ETH locked in the ZK Chains.

***Update:** Resolved in [pull request #301](https://github.com/matter-labs/era-contracts/pull/301).*

### Use of Non-Upgradeable Library in Upgradeable Contract

The `StateTransitionManager` is an upgradeable contract to be used behind a proxy. It extends the `Ownable2Step` contract for the owner role management.

Despite the `StateTransitionManager` being upgradeable, [`Ownable2Step` is imported](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L16) from `@openzeppelin/contracts`, not `@openzeppelin/contracts-upgradeable`. The difference is that the contract has no storage gap and would usually be set up through the constructor. This is not a problem as the initial owner is set up in the [`initialize` function](https://github.com/matter-labs/era-contracts/blob/d5c5d7a7c3a458f131e5de72c6c134a172e6763d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L83) and as long as the storage layout of the extended contracts do not shift, which is unlikely for the `Ownable2Step` and `Ownable` contract.

However, to be safe and to adhere to the best practice of using storage gaps, consider using the contracts-upgradeable version of `Ownable2Step`.

***Update:** Resolved at commit [4befd8a](https://github.com/matter-labs/era-contracts/commit/4befd8a2880a2bc2e5f257a24b540f0f2472e014).*

## Conclusion

This system upgrade has introduced various abstractions to the L1 contracts that will enable Ethereum scalability through ZKsync ZK Chains. The new `StateTransitionManager` is the central piece used to spawn and manage these ZK Chains. Further changes to the existing facets were made to accommodate the overall architectural change of bridging assets.

The audit yielded two medium-severity issues. One simple mistake causes the `StateTransitionManager` to not be able to unfreeze chains, while the other problem lies in the ambiguity of the Pubdata pricing mode configuration. Among these, multiple lower-severity issues have been raised and recommendations made. We appreciate Matter Labs' helpful input to our questions throughout this engagement.

[![Request Audit](https://no-cache.hubspot.com/cta/default/7795250/7809b604-3f30-4cd5-be58-36982828e327.png)](https://cta-redirect.hubspot.com/cta/redirect/7795250/7809b604-3f30-4cd5-be58-36982828e327)
