# Decentralized Governance Audit

Source: [https://www.openzeppelin.com/news/decentralized-governance-audit](https://www.openzeppelin.com/news/decentralized-governance-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scopes](#scopes)
  - [Scope 1](#scope-1)
  - [Scope 2](#scope-2)
  - [Scope 3](#scope-3)
- [System Overview](#system-overview)
  - [ProtocolUpgradeHandler](#protocolupgradehandler)
  - [Incident Response Measures](#incident-response-measures)
  - [Bridges](#bridges)
  - [Era-Contract Changes](#era-contract-changes)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
- [Critical Severity](#critical-severity)
  - [Scope 1 - Immutable Variable Not Set in Constructor](#scope-1-immutable-variable-not-set-in-constructor)
- [Medium Severity](#medium-severity)
  - [Scope 1 - Multisig Is Incompatible with ERC-4337](#scope-1-multisig-is-incompatible-with-erc-4337)
  - [Scope 1 - ProtocolUpgradeHandler Design Flaws](#scope-1-protocolupgradehandler-design-flaws)
  - [Scope 2 - Incorrect Usage of EnumerableMap](#scope-2-incorrect-usage-of-enumerablemap)
- [Low Severity](#low-severity)
  - [Scope 3 - Missing Docstrings](#scope-3-missing-docstrings)
  - [Scope 3 - Incomplete Docstrings](#scope-3-incomplete-docstrings)
  - [Scope 1 - Lack of Tests](#scope-1-lack-of-tests)
  - [Scope 1 - Incorrect and Incomplete Documentation](#scope-1-incorrect-and-incomplete-documentation)
  - [Scope 1 - Misleading Revert Message](#scope-1-misleading-revert-message)
  - [Scope 1 - Risk of Silent Call Failures](#scope-1-risk-of-silent-call-failures)
  - [Scope 2 - Two Paths To Unfreeze By Anyone After Expiration](#scope-2-two-paths-to-unfreeze-by-anyone-after-expiration)
  - [Scope 2 - Unset Minimum softFreeze Threshold](#scope-2-unset-minimum-softfreeze-threshold)
  - [Scope 2 - EIP-1271 Threshold Could Be Larger Than Available Members In Multisig](#scope-2-eip-1271-threshold-could-be-larger-than-available-members-in-multisig)
  - [Scope 2 - Invoked Unfreeze Call Does Not Emit an Event](#scope-2-invoked-unfreeze-call-does-not-emit-an-event)
  - [Scope 2 - initialCutHash May Go out of Sync With protocolVersion](#scope-2-initialcuthash-may-go-out-of-sync-with-protocolversion)
- [Notes & Additional Information](#notes-additional-information)
  - [Scope 3 - State Variable Visibility Not Explicitly Declared](#scope-3-state-variable-visibility-not-explicitly-declared)
  - [Scope 3 - Lack of Security Contact](#scope-3-lack-of-security-contact)
  - [Scope 3 - Function Visibility Overly Permissive](#scope-3-function-visibility-overly-permissive)
  - [Scope 1 - Circular Instantiation](#scope-1-circular-instantiation)
  - [Scope 1 - State Variable Visibility Not Explicitly Declared](#scope-1-state-variable-visibility-not-explicitly-declared)
  - [Scope 1 - Typographical Errors](#scope-1-typographical-errors)
  - [Scope 1 - Incomplete Interface](#scope-1-incomplete-interface)
  - [Scope 2 - Incomplete Interface](#scope-2-incomplete-interface)
  - [Scope 2 - Gas Optimization](#scope-2-gas-optimization)
  - [Scope 2 - Typographical Errors](#scope-2-typographical-errors)
  - [Scope 2 - State Variable Visibility Not Explicitly Declared](#scope-2-state-variable-visibility-not-explicitly-declared)
  - [Scope 2 - Lack Of Hyperchain ID Specific (Un)freeze Reinforcement](#scope-2-lack-of-hyperchain-id-specific-unfreeze-reinforcement)
- [Conclusion](#conclusion)

## Summary

 ​

Type
:   Layer 2

Timeline
:   **(Scope 1)** From 2024-04-05
:   To 2024-04-10
:   **(Scope 2)** From 2024-04-22
:   To 2024-04-26
:   **(Scope 3)** From 2024-04-22
:   To 2024-04-24

Languages
:   Solidity

Total Issues
:   27 (18 resolved, 2 partially resolved)

Critical Severity Issues
:   1 (1 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   3 (1 resolved, 1 partially resolved)

Low Severity Issues
:   11 (7 resolved, 1 partially resolved)

Notes & Additional Information
:   12 (9 resolved)

Client Reported Issues
:   0 (0 resolved)

## Scopes

### Scope 1

For **Scope 1**, we audited the [ZKsync-Association/zk-governance](https://github.com/ZKsync-Association/zk-governance) repository at commit [a3e361d](https://github.com/ZKsync-Association/zk-governance/tree/a3e361d00d8100ed1724b079ea7509f7f13e3d94). The following files were in scope:

```
 zk-governance/l1-contracts/src
├─ Guardians.sol
├─ Multisig.sol
├─ ProtocolUpgradeHandler.sol
├─ SecurityCouncil.sol
└─ interfaces
   ├─ IGuardians.sol
   ├─ IProtocolUpgradeHandler.sol
   ├─ ISecurityCouncil.sol
   └─ IZkSyncEra.sol
```

​

### Scope 2

As for **Scope 2**, following the scope above, another diff audit of the [ZKsync-Association/zk-governance](https://github.com/ZKsync-Association/zk-governance) repository at HEAD commit [c66fc0b](https://github.com/ZKsync-Association/zk-governance/commit/c66fc0b27ef7452188d349dafd8e170095bbd1f0) and BASE commit [3e20e0c](https://github.com/ZKsync-Association/zk-governance/commit/3e20e0cb9228ff2bcc2405e4e079f2c974481b64) was performed. The following files were in scope:

```
 zk-governance/l1-contracts/src
├─ EmergencyUpgradeBoard.sol
├─ Guardians.sol
├─ Multisig.sol
├─ ProtocolUpgradeHandler.sol
├─ SecurityCouncil.sol
└─ interfaces
   ├─ IPausable.sol
   ├─ IProtocolUpgradeHandler.sol
   └─ IStateTransitionManager.sol
```

​

Further, in **Scope 2**, we diff audited the [matter-labs/era-contracts](https://github.com/matter-labs/era-contracts) repository at HEAD commit [189a7fe](https://github.com/matter-labs/era-contracts/commit/189a7feeb7490597d64971052e26b7c6e918af0d/) and BASE commit [a86cf76](https://github.com/matter-labs/era-contracts/commit/a86cf766f91bf30c2974bc6c983bd0d1d0186a0e) regarding relevant changes to the governance process

```
 era-contracts/l1-contracts/contracts/
└─ state-transition
   ├─ IStateTransitionManager.sol
   ├─ StateTransitionManager.sol
   ├─ ValidatorTimelock.sol
   └─ chain-deps/facets/
      ├─ Admin.sol
      └─ Mailbox.sol
```

​

### Scope 3

Lastly, in **Scope 3**, we diff audited the following files with the same commits as in **Scope 2** above:

```
 era-contracts/l1-contracts/contracts
├── bridge
│   ├── L1ERC20Bridge.sol
│   ├── L1SharedBridge.sol
│   └── interfaces
│       ├── IL1ERC20Bridge.sol
│       └── IL1SharedBridge.sol
└── bridgehub
    └── Bridgehub.sol
```

​

**Update:** All the resolutions mentioned in this report are contained at commit [d2acc8f](https://github.com/zksync-association/zk-governance/commit/d2acc8f547f2e2833cd79a22eb3985e8451e1938) of [ZKsync-Association/zk-governance](https://github.com/ZKsync-Association/zk-governance) repository.

## System Overview

This upgrade aims to decentralize the protocol upgrades of zkSync Era and introduce incident response measures. The details of the new contracts and changes are outlined in the following sections.

### `ProtocolUpgradeHandler`

The proposal life-cycle starts with a Governance token vote on L2. On successful vote, the proposal is carried over to the `ProtocolUpgradeHander` on L1. Here, the upgrade proposal needs to be initialized by checking whether the proposal was indeed successful on L2. This is performed through a log inclusion check in the `Mailbox` facet. After initializing the proposal to the `Waiting` state, the proposal is now progressing under the influence of the trusted parties Security Council (SC) and Guardians (G). The following state transitions can happen:

- In `Waiting` state
  - SC approve: move to `VetoPeriod`
  - G approve: remain in `Waiting` and after 90 days the proposal moves to `ExecutionPending`
  - Nothing: after 90 days the proposal expires as `Canceled`
- In `VetoPeriod` state
  - G veto: move to `Canceled`
  - G refrain from veto: move to `ExecutionPending` immediately
  - Nothing: after 3 days the proposal moves to `ExecutionPending`
- In `ExecutionPending` state
  - Nothing: after 1 day the proposal moves to `Ready`
- In `Ready` state
  - The executor address set in the proposal can execute the proposal. If the the address is zero, then anyone can perform the execution. The proposal moves to `Done`

The Security Council is a 6/12 multisig and the Guardians is a 5/8 multisig.

### Incident Response Measures

In the event of suspicious activity, the security council can perform a soft or hard freeze through the `ProtocolUpgradeHandler`. Either freeze will pause the `BridgeHub`, shared bridge, and all hyperchains of the `StateTransitionManager` (which is owned by the `ProtocolUpgradeHandler`). The freeze modes differentiate by pause duration and cooldown time:

- Soft: Pause for 12 hours maximum. Can be called again after three days.
- Hard: Pause for 7 days maximum. Can be called again after two weeks.

The security council can unfreeze everything anytime. Alternatively, anyone can unfreeze once the freeze period ends.

In case of a critical security issue which needs to be addressed promptly, an emergency upgrade can be executed. This upgrade follows the usual proposal structure, but bypasses the whole proposal process outlined above for direct execution. It can only be executed by the Emergency Upgrade Board, which requires approval of the 9/12 security council, 5/8 Guardians, and ZK Association multisig. An emergency upgrade can be executed at all times (frozen or not), unfreezes the contracts right away, and resets the freeze timers. Thus, a hard freeze and emergency upgrade could be followed by another hard freeze.

### Bridges

Parts of the bridge architecture are described in our [Fee Model and Token Bridge](https://blog.openzeppelin.com/zkSync-Fee-Model-and-Token-Bridge-Audit) audit report. The following is a summarized overview of the contracts:

#### `L1ERC20Bridge`

Previously, the `L1ERC20Bridge` did not support ETH transfers. However, it was possible to send an arbitrary amount of ETH along with any `ERC20` token deposit. This contract was deprecated in favor of the `L1SharedBridge`. The `L1ERC20Bridge` is still needed, for backward compatibility with already integrated projects.

#### `L1SharedBridge`

The `L1SharedBridge` is an upgradeable contract that helps bridging assets between L1 and hyperchains, supporting both ETH and `ERC20` tokens.

#### `BridgeHub`

The `BridgeHub` acts as a hub for bridges and hyperchains, allowing them to communicate with all hyperchain contracts from a single point and gathering all L1 assets to the `L1SharedBridge`.

### Era-Contract Changes

The following changes were introduced within the era-contracts scopes:

- A pause feature was added to both the `L1SharedBridge` and `Bridgehub` contracts.
- The access control of the `{un}freezeDiamond` functions were set to be for the `StateTransitionManager` only.
- Immutable variables were renamed into a screaming snake case format.
- The `StateTransitionManager` admin may now also set validators. Only the owner was previously allowed to do so.
- The `StateTransitionManager` was changed to internally handle the mapping of chain-ID to addresses using OpenZeppelin's `EnumerableMap` library. This includes extending the interface with functions to query the IDs and addresses.

## Security Model and Trust Assumptions

During the audit, the auditors have identified the following considerations:

- The `Multisig` contracts do not implement a replayability measure themselves (despite for the (un)freezing). Instead, they are dependent on the `ProtocolUpgradeHandler` implementation they interact with, which prevents replayability. However, if these interactions get extended in the future the replayability counter-measure needs to be re-evaluated.
- When executing an upgrade proposal, arbitrary data can be called on arbitrary targets without any restriction. Thus, it is assumed that the Guardian and Security Council carry the responsibility on the validation of each call based on up-to-date on-chain conditions.
- Proposals can define a non-zero address that restricts the upgrade execution to that message sender. Therefore, this address holds the power of not going through with the execution of an approved upgrade proposal, thereby potentially undermining the opinion of the council or guardians. Hence, it is assumed that this address is trusted by both parties.
- Proposals can be processed at different speeds so that there may be multiple proposals in `Ready` state, while their order of execution is not enforced. Thus, it is expected by the Guardians and Security Council that the order of execution is as intended. Note that the feature of a predecessor upgrade was removed compared to the previous Governance implementation.
- The pause feature of the `L1SharedBridge` and `Bridgehub` is callable by the owner of those contracts, which is set as the `ProtocolUpgradeHandler` contract. Upon a soft or a hard freeze, the `ProtocolUpgradeHandler` would pause the `L1SharedBridge`, `Bridgehub`, and all the hyperchains.
- In the `L1SharedBridge`, the owner can pause bridging/depositing, claiming, and withdrawing functions. While pausing was not added to the `L1ERC20Bridge`, the functions `deposit`, `claimFailedDeposit`, and `finalizeWithdrawal` rely on their respective counterparts from the `L1SharedBridge`. This means that when `L1SharedBridge` is paused, the `L1ERC20Bridge` contract is also paused.
- In `Bridgehub`, the functions `createNewChain`, `requestL2TransactionDirect`, and `requestL2TransactionTwoBridges` are now pausable. This means no new chains can be added, and no cross-chain communication can happen through the `BridgeHub`.
- The incident response measures are expected to be used with the right intention by all of the trusted parties.
- All trusted parties are expected to follow industry standards for securing their private keys and act responsibly if compromised.
- Hyperchains can be frozen/unfrozen through the (emergency) proposal execution process. This may introduce mismatches between the freeze status of the `ProtocolUpgradeHander`, the hyperchains, and bridges.

**Update:** Please note that the term 'hyperchain' has been updated in later releases to 'ZKchain'.

## Critical Severity

### Scope 1 - Immutable Variable Not Set in Constructor

As of Solidity [0.8.21](https://github.com/ethereum/solidity/releases/tag/v0.8.21), immutable variables do not need to be explicitly assigned a value in the constructor of the contract. This could lead to cases where contracts are deployed with immutable variables unintentionally set to their default values.

Within the [`ProtocolUpgradeHandler` contract](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/ProtocolUpgradeHandler.sol), the immutable state variable [`ZKSYNC_ERA`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L53) was not initialized in the constructor. This basically makes the whole contract inoperable as no protocol upgrades can be processed through the [`startUpgrade` function](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L111), which is dependent on this address.

Consider setting the correct address during contract construction.

***Update:** Resolved at commit [348a26a](https://github.com/ZKsync-Association/zk-governance/commits/348a26a243babd4d51ae9547b69b6da9037c613a).*

## Medium Severity

### Scope 1 - `Multisig` Is Incompatible with ERC-4337

EIP-4337 is a standard that allows smart contracts to behave like user accounts, thereby extending the user account landscape of Externally Owned Accounts (EOA) with smart contract accounts.

To verify the signatures, the `Multisig` contract [uses the OpenZeppelin `ECDSA` library](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Multisig.sol#L45) that makes a call to the `ecrecover` precompile contract, which is incompatible with smart contract accounts.

Hence, to enable [EIP-1271](https://eips.ethereum.org/EIPS/eip-1271) smart contract account signature checks, consider using the [`SignatureChecker` library](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/cryptography/SignatureChecker.sol) instead.

***Update:** Resolved at commit [fef52f6](https://github.com/ZKsync-Association/zk-governance/commits/fef52f6ccf952dbf97eab5a2ccce2c3d3e0aad5c). Consider using an [`EnumerableSet`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/structs/EnumerableSet.sol#L231) for the multisig members, to check the signers against the members and give a meaningful revert message otherwise. The ZKsync Association team stated:*

> *The proposal makes sense to me, but I am in favour of keeping dependency list as small as possible, especially when there is no strong reasons to add new one. I will acknowledge this issue for now.*

### Scope 1 - `ProtocolUpgradeHandler` Design Flaws

The `ProtocolUpgradeHandler` is the state machine of processing the Security Council's and Guardian's say on a protocol upgrade proposal. The Council can approve an upgrade and the Guardians can approve as well as veto an upgrade. These calls are dependent on different states that an upgrade can process through.

The following was identified as design flaws when it comes to handling the state of an upgrade:

- [`approveUpgradeGuardians`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L161) and [`refrainFromVeto`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L199) indicate the same intention of the Guardians approving the upgrade. However, `approveUpgradeGuardians` can only be called in `Waiting` state and `refrainFromVeto` only in `VetoPeriod` state, thereby making the multisig operations more complex to handle.
- The Guardians could first approve an upgrade (staying in `Waiting` state), but then with the Security Council's approval the `VetoPeriod` state is entered which allows the Guardians to veto the previously approved upgrade, hence, making the upgrade process ambiguous.
- There is a problem of the Security Council approval getting in the way of the Guardians. If the Guardians intend to call `approveUpgradeGuardians`, but the Security Council calls [`approveUpgradeSecurityCouncil`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L141) just before them, then the state changes from `Waiting` to `VetoPeriod`, thus, making the Guardians' call fail that requires the state to be `Waiting`.
- Guardians have the last say on an upgrade, so despite the Security Council's approval, a [`veto`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L181) overrules them. They can only veto in the `VetoPeriod` state however, which is only entered after the Council's approval. This dependency does not make sense given the prior statement of the Guardians' last say, i.e., the Guardians' should be able to cancel (veto) an upgrade in `Waiting` state.

Consider re-evaluating the design choices of this contract. For example, instead of setting the state directly in the `UpgradeStatus`, set the party's choices that the state will be evaluated from. This could make the state evaluation more streamline and remove the redundancy outlined above.

***Update:** Acknowledged, will resolve. The ZKsync Association team stated:*

> *Acknowledged. The current design was chosen to eliminate additional complexity related to the proposed approach. We may reevaluate the decision if the flow will change.*

### Scope 2 - Incorrect Usage of `EnumerableMap`

The `StateTransitionManager` was refactored to handle the chain ID to contract address mapping of the hyperchains using OpenZeppelin's `EnumerableMap` library.

This has introduced an issue in the [`getAllHyperchains` function](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L92), where the chain IDs are saved in the `keys` array to query the addresses from the `EnumerableMap` using the `get` function. However, the `get` function expects the input `key[i]` instead of the given index `i`, which effectively leads to a revert and renders the function unusable. Consider using either the [`at` function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.5/contracts/utils/structs/EnumerableMap.sol#L324) to query the addresses by index, or using the proper key from the array with `get`.

Furthermore, while not posing an issue, the library usage around the [`getHyperchain` function](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L102) might not fully comply with the libraries intention. To query a hyperchain address by ID, `tryGet` is used. While ignoring the success value, this means that a chain ID outside of the mapping will return the zero address. This leads to two considerations:

1. Other parts of the codebase (e.g., [`ValidatorTimelock`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L213) and [`BridgeHub`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridgehub/Bridgehub.sol#L163)) make use of the `getHyperchain` function to perform calls to the chain ID's address. For a non-existent ID a call to the zero-address would lead to an inexplicit revert. Consider using the [`get` function with a custom error message](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.5/contracts/utils/structs/EnumerableMap.sol#L355) within `getHyperchain` to fail more explicitly in these cases.
2. The [`createNewChain` function](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L353) execution is skipped when a chain ID is already registered. This is done by checking that the `getHyperchain` function output is not zero. Following the previous suggestion, a revert would not be desired here. Hence, consider using the [`contains` function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.5/contracts/utils/structs/EnumerableMap.sol#L412) to see whether a chain ID is part of the map.

When applying above suggestions it is crucial to have an extensive test suite in place that confirms the functional correctness of these changes. Most importantly, evaluate other instances where a call to `getHyperchain` must not revert.

***Update:** Partially resolved in [pull request #403](https://github.com/matter-labs/era-contracts/pull/403) at commit [1995a97](https://github.com/matter-labs/era-contracts/pull/403/commits/1995a9740312997edeac0fa1db1aa81aebf07b29). The ZKsync Association team stated:*

> *Partially fixed. We fixed the issue with `getAllHyperchains`, but decided to keep `getHyperchain` the same as a convention we use across all other zkSync contracts.*

## Low Severity

### Scope 3 - Missing Docstrings

Throughout the codebase, there are multiple code instances that do not have docstrings:

- The [`Bridgehub` contract](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridgehub/Bridgehub.sol#L17-L340) in `Bridgehub.sol`.
- The [`receiveEth` function](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L185-L187) in `L1SharedBridge.sol`.

Consider thoroughly documenting all contracts and functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #432](https://github.com/matter-labs/era-contracts/pull/432) at commit [ca5f7e1](https://github.com/matter-labs/era-contracts/pull/432/commits/ca5f7e153376a44d93b099a69de8ac2dfc7cc6ad).*

### Scope 3 - Incomplete Docstrings

Throughout the codebase, there are several parameters which are not self-explanatory and could benefit from additional docstrings. For instance:

- The `_batchNumber`, `_index`, `_message`, and `_proof` parameters of the [`proveL2MessageInclusion`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridgehub/Bridgehub.sol#L156-L165) function in `Bridgehub.sol`.
- The `_batchNumber`, `_index`, `_log`, and `_proof` parameters of the [`proveL2LogInclusion`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridgehub/Bridgehub.sol#L168-L177) function in `Bridgehub.sol`.
- The `_l2TxHash`, `_l2BatchNumber`, `_l2MessageIndex`, `_l2TxNumberInBatch`, `_merkleProof`, and `_status` parameters of the [`proveL1ToL2TransactionStatus`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridgehub/Bridgehub.sol#L180-L199) function in `Bridgehub.sol`.
- The `_target` and `_targetChainId` parameters of the [`transferFundsFromLegacy`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L164-L183) function in `L1SharedBridge.sol`.
- The `_prevMsgSender`, `_l1Token` and `_amount` parameters of the [`bridgehubDepositBaseToken`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L196-L217) function in `L1SharedBridge.sol`.
- The `_prevMsgSender`, `_l2Value` and `_data` parameters of the [`bridgehubDeposit`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L231-L292) function in `L1SharedBridge.sol`.
- The `_txDataHash` and `_txHash` parameters of the [`bridgehubConfirmL2Transaction`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L296-L304) function in `L1SharedBridge.sol`.
- The `_prevMsgSender` parameter of the [`depositLegacyErc20Bridge`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L666-L717) function in `L1SharedBridge.sol`.

Consider documenting to help with legibility and understanding of the code.

***Update:** Resolved in [pull request #433](https://github.com/matter-labs/era-contracts/pull/433) at commit [f1d23df](https://github.com/matter-labs/era-contracts/pull/433/commits/f1d23df1006f92202fc8d0140e00872da6328185).*

### Scope 1 - Lack of Tests

The codebase under review has no tests. Insufficient testing, while not a specific vulnerability, implies the high probability of additional hidden vulnerabilities and bugs. Testing provides a full implicit specification along with the exact expected behaviors of the codebase, especially important when adding in novel functionality. A lack thereof increases the chances that correctness issues will be missed (like [*Immutable Variable Not Set In Constructor*](#immutable-critical-link)). It also results in more effort to establish basic correctness and reduces effort spent exploring edge cases, thereby increasing the chances of missing complex issues.

Consider implementing unit and invariant tests for the codebase to extend the security guarantees of the protocol.

***Update:** Acknowledged, will resolve. The ZKsync Association team stated:*

> *Acknowledged. The code in scope wasn't finalized fully and expect another iteration. We would deliver the complete coverage for the next audit stage.*

### Scope 1 - Incorrect and Incomplete Documentation

The following instances of incorrect documentation were identified:

- The `Guardians` contract has the Natspec title of ["Security Council"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Guardians.sol#L10), thereby indicating the wrong contract.
- The `ProtocolUpgradeHandler` code is sectioned with comments. One of these sections says ["FALLBACK"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L345), although the following function is the `receive` function.

The following instances of incomplete documentation were identified:

- The [NatSpec dev comment](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Guardians.sol#L13) on the `Guardians` contract could be mentioning the veto aspect.
- The [`guardiansApproval`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L33) field of the `UpgradeStatus` struct is not documented.
- The [`proveL2MessageInclusion`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/interfaces/IZkSyncEra.sol#L19-L24) function of the `IZkSyncEra` interface could be documented.

Consider addressing above issues to improve code clarity.

***Update:** Resolved at commit [d701a29](https://github.com/ZKsync-Association/zk-governance/commits/d701a29eb16c06a3c933f75d668bb8154f65784f). The ZKsync Association team stated:*

> *Fixed. The "fallback" section in the code is intentional, even though the only `receive` function is implemented. The section provided the overall description of functions under the common name.*

### Scope 1 - Misleading Revert Message

When [checking signatures](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Multisig.sol#L46) in `Multisig.sol`, a `while` loop is used to efficiently match a `member` to a recovered signer, otherwise, the counter `currentMember` increases until one is found. Since the address array [`members`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Multisig.sol#L27) is sorted and has a fixed length ([8 for guardian members](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Guardians.sol#L36) and [12 for security council members](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/SecurityCouncil.sol#L31)), an `array out-of-bounds` error will occur in the following scenarios:

- a recovered signer is not a member
- the order of signatures is not sorted appropriately
- there exists a non-unique signature

Consider expressing more meaningful error message for each above scenario for better revert diagnosis.

***Update:** Acknowledged, not resolved. The ZKsync Association team stated:*

> *Acknowledged. The proposed change requires adding complexity to the small but very error-prone logic.*

### Scope 1 - Risk of Silent Call Failures

When [executing an upgrade proposal](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L316), a low-level call is performed on an arbitrary target with arbitrary data. If the call is not successful, it intends to revert with an error message. However, when the target is an account without code, the [`success`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L316) variable returned by the call is `true`, thus resulting in risks of silent failures.

Consider checking if the target has code when the data is non-empty.

***Update:** Resolved at commit [5341815](https://github.com/ZKsync-Association/zk-governance/commits/53418158133c79b756969207176c03baf78f39c9).*

### Scope 2 - Two Paths To Unfreeze By Anyone After Expiration

There are two functions, namely [`unfreeze()`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L484-L488) and [`reinforceUnfreeze()`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L484), that anyone can call to unfreeze all hyperchains after the block timestamp passes the `protocolFrozenUntil` value.

However, depending on which of these two functions are called, there could be confusion in `freezeStatus` as well as events emitted.

- When `unfreeze()` is called, the `freezeStatus` is reset to `None`, the `protocolFrozenUntil` is reset to `0`, and an `Unfreeze()` event is emitted.
- When `reinforceUnfreeze()` is called, the `freezeStatus` remains as it is, which could be `Soft` or `Hard` despite it has been unfrozen, and `protocolFrozenUntil` remains as it is with a `ReinforceFreeze()` event emitted.

Thus there are two paths for performing the same functionality, but with different state variable updates and event emissions. Consider only allowing one path for anyone to unfreeze after the expiration timestamp for operational clarity and consistency.

***Update:** Partially resolved at commit [15831c6](https://github.com/ZKsync-Association/zk-governance/commits/15831c60e25f6375eeb99b0c75d13cfec29cedf7). The ZKsync Association team stated:*

> *Fixed. We decided to keep two functions but restrict unfreeze to happen only once.*

### Scope 2 - Unset Minimum softFreeze Threshold

When initiating a `softFreeze` from `SecurityCouncil.sol`, the number of signatures required is specified by the [`softFreezeThreshold`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L90) variable that can be set to 0 through the [`setSoftFreezeThreshold`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L134) function. In such a scenario, no signature is required to initiate a `softFreeze` on all hyperchains, thereby exposing this privilege to everyone.

Consider setting a non-zero minimum number of signatures to initiate a `softFreeze` or explicitly documenting the intention of allowing no signatures.

***Update:** Resolved at commit [da33bf6](https://github.com/ZKsync-Association/zk-governance/commits/da33bf6d1c79e3c2329fc81374e641d202cd5759).*

### Scope 2 - EIP-1271 Threshold Could Be Larger Than Available Members In `Multisig`

The [`constructor`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/Multisig.sol#L27-L38) of `Multisig.sol` does not check if the `_members.length` is greater than or equal to the `_eip1271Threshold`. Thus it is possible to instantiate a `Multisig` that sets a higher threshold for `EIP1271_THRESHOLD` than available members. This would render the [`isValidSignature`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/Multisig.sol#L64) function unusable, thus its external integration would also revert.

Although both [`SecurityCouncil`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L64-L71) and [`Guardians`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/Guardians.sol#L31-L38) have instantiated `Multisig` correctly, consider checking that the EIP-1271 threshold is not greater than the member count to avoid any potential mis-instantiation in the future.

***Update:** Resolved at commit [fd86a0d](https://github.com/ZKsync-Association/zk-governance/commits/fd86a0d45d00a0e09545cbe95d9e13d39010fe61).*

### Scope 2 - Invoked Unfreeze Call Does Not Emit an Event

The emergency upgrade process unfreezes the bridges and hyperchains through the `ProtocolUpgradeHandler` once the upgrade is executed. This is performed by invoking the internal [`_unfreeze` function](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L331) which does not fire either of the `{Reinforce}Unfreeze` events. Thus, the contracts would resume to be operable without having emitted the respective event, besides emitting `EmergencyUpgradeExecuted`.

Consider emitting the `Unfreeze` event by adding it to the emergency upgrade function. Alternatively, consider making the code more self-contained by having the emergency board calling the [`unfreeze` function](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L474) separately after the upgrade execution.

***Update:** Resolved at commit [8b62b1c](https://github.com/ZKsync-Association/zk-governance/commits/8b62b1c527fabad105d6b634a1415198bd388f6c).*

### Scope 2 - `initialCutHash` May Go out of Sync With `protocolVersion`

When creating a new chain through the `StateTransitionManager`, its [protocol version](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L374) is initialized as the `StateTransitionManager`'s latest [`protocolVersion`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L51). Further, the [`DiamondCutData`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L363) to initialize all facets is determined by checking its hash against the [`initialCutHash`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L45), which can be updated by the owner. Over the course of protocol upgrades, various facets might get added and removed. Thus, it is important that `initialCutHash` is in sync with the initialized protocol version to ensure that a new chain is initialized appropriately.

However, this requires the owner to update the `initialCutHash` separately at each upgrade. This creates an opportunity to introduce errors that lead to a mismatch between a chain's version and implementation. Consider having a way to automatically update and validate the `initialCutHash` with each upgrade so that the `initialCutHash` is always consistent with the `protocolVersion`. Alternatively, consider adding the protocol version to the [`InitializeDataNewChain` struct](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/chain-interfaces/IDiamondInit.sol#L50) such that the version will be provided through the [`_diamondCut` input](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L351) and hence checked to match the initialize diamond cut according to the `initialCutHash`. Note that this would mean to reorder the [`InitializeData` struct](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/chain-interfaces/IDiamondInit.sol#L24).

Also consider changing the name of `initialCutHash` to, for example, `cumulativeCutHash` to explicitly emphasize that this is an accumulative quantity that takes into account of all the [`upgradeCutHash`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L60) (which represents diffs) up to the current version.

***Update:** Acknowledged, will resolve. The ZKsync Association team stated:*

> *Acknowledged. This is a good finding we would address in one of the next protocol upgrades.*

## Notes & Additional Information

### Scope 3 - State Variable Visibility Not Explicitly Declared

Within [`L1SharedBridge.sol`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol), there are state variables that lack an explicitly declared visibility. For instance:

- The [`ERA_CHAIN_ID` state variable](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L40).
- The [`ERA_DIAMOND_PROXY` state variable](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L43).

For clarity, consider always explicitly declaring the visibility of variables, even when the default visibility matches the intended visibility.

***Update:** Resolved in [pull request #430](https://github.com/matter-labs/era-contracts/pull/430) at commit [d0e46f2](https://github.com/matter-labs/era-contracts/pull/430/commits/d0e46f213ad3ecd29472a3634051f9bc2aae6323). Consider making the non-constant variables public for easier querying of the values, while also extending the interface accordingly.*

### Scope 3 - Lack of Security Contact

Providing a specific security contact (such as an email or ENS name) within a smart contract significantly simplifies the process for individuals to communicate if they identify a vulnerability in the code. This practice is quite beneficial as it permits the code owners to dictate the communication channel for vulnerability disclosure, eliminating the risk of miscommunication or failure to report due to a lack of knowledge on how to do so. In addition, if the contract incorporates third-party libraries and a bug surfaces in those, it becomes easier for their maintainers to contact the appropriate person about the problem and provide mitigation instructions.

The [`Bridgehub` contract](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridgehub/Bridgehub.sol) does not have a security contact.

Consider adding a NatSpec comment containing a security contact above each contract definition. Using the `@custom:security-contact` convention is recommended as it has been adopted by the [OpenZeppelin Wizard](https://wizard.openzeppelin.com/) and the [ethereum-lists](https://github.com/ethereum-lists/contracts#tracking-new-deployments).

***Update:** Resolved in [pull request #431](https://github.com/matter-labs/era-contracts/pull/431) at commit [5458700](https://github.com/matter-labs/era-contracts/pull/431/commits/5458700e6e1dfb5105b1a0c224e3f49961f18cfe).*

### Scope 3 - Function Visibility Overly Permissive

Throughout the codebase, there are various functions with unnecessarily permissive visibility. For instance:

- Within the `L1ERC20Bridge` contract, the [`_depositFundsToSharedBridge`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L171-L177) function with `internal` visibility could be limited to `private`.
- Within the `L1SharedBridge` contract, the [`_depositFunds`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L221-L228), [`_getDepositL2Calldata`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L314-L322), [`_getERC20Getters`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L325-L337) , [`_claimFailedDeposit`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L374-L439), [`_isEraLegacyEthWithdrawal`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L445-L448), [`_isEraLegacyTokenWithdrawal`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L454-L460), [`_isEraLegacyDeposit`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L467-L481), [`_finalizeWithdrawal`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L521-L567), [`_checkWithdrawal`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L570-L597) and [`_parseL2WithdrawalMessage`](https://github.com/matter-labs/era-contracts/blob/189a7feeb7490597d64971052e26b7c6e918af0d/l1-contracts/contracts/bridge/L1SharedBridge.sol#L599-L636) functions with `internal` visibility could be limited to `private`.

To better convey the intended use of functions and to potentially realize some additional gas savings, consider changing a function's visibility to be only as permissive as required.

***Update:** Acknowledged, not resolved. The ZKsync Association team stated:*

> *Acknowledged. The contract is not designed to be inherited.*

### Scope 1 - Circular Instantiation

To deploy the [`ProtocolUpgradeHandler` contract](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L68), it requires the addresses of the `SecurityCouncil` and `Guardians` contracts. However, to instantiate the [`SecurityCouncil`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/SecurityCouncil.sol#L26) and [`Guardians`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Guardians.sol#L31) contract, it requires an instance of the `ProtocolUpgradeHandler`. This circular instantiation causes inconvenience during deployment and testing.

Consider adding documentation for a deployment plan with deterministic addresses.

***Update:** Acknowledged, will resolve. The ZKsync Association team stated:*

> *Acknowledged. The address for each contract will be precalculated. Documentation and scripts planned for the next audit.*

### Scope 1 - State Variable Visibility Not Explicitly Declared

Within [`ProtocolUpgradeHandler.sol`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol), there are state variables that lack an explicitly declared visibility. For instance:

- The [`GUARDIANS_VETO_PERIOD` state variable](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L35).
- The [`UPGRADE_DELAY_PERIOD` state variable](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L40).
- The [`UPGRADE_WAIT_OR_EXPIRE_PERIOD` state variable](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L45).
- The [`L2_PROTOCOL_GOVERNOR` state variable](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L50).
- The [`ZKSYNC_ERA` state variable](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L53).

For clarity, consider always explicitly declaring the visibility of variables, even when the default visibility matches the intended visibility.

***Update:** Resolved at commit [3ed956a](https://github.com/ZKsync-Association/zk-governance/commit/3ed956af36aec8b4dbead4a103000201996ac61f) and at commit [481dcf4](https://github.com/ZKsync-Association/zk-governance/commit/481dcf458452fe34d97bb5f7cfc5b774403ef48f).*

### Scope 1 - Typographical Errors

Throughout the codebase, the following typographical errors were identified:

- ["Vetoes"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Guardians.sol#L48) should be "Vetos"
- ["Approves the changes to the changes proposed by the Token Assembly"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/Guardians.sol#L13) should be "Approves the changes proposed by the Token Assembly"
- ["The proposed changes are executed by the authorized in the proposal address"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L26) should be "The proposed changes are executed by the authorized address in the proposal".
- ["Upgrade can't be vetoed in not the veto period"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L183) should be "Upgrade can't be vetoed outside of the veto period".
- ["Guardians can't refrain from veto in not the veto period"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L201) should be "Guardians can't refrain from veto outside of the veto period".
- There is a mixed usage of American English (e.g., ["canceled"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L15)) and British English (e.g. ["authorised"](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L222)). Consider sticking to one.

Consider addressing the issues above to ease the readability of the codebase.

***Update:** Resolved at commit [4fe0ac7](https://github.com/ZKsync-Association/zk-governance/commits/4fe0ac70c7620c4fb3e8f8f00b4ad34a014d2ceb).*

### Scope 1 - Incomplete Interface

The `ProtocolUpgradeHander` implements the unrestricted public functions [`getUpgradeStatusNow`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L249) and [`updateUpgradeStatus`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/ProtocolUpgradeHandler.sol#L303), which are not given in the [`IProtocolUpgradeHandler`](https://github.com/ZKsync-Association/zk-governance/blob/a3e361d00d8100ed1724b079ea7509f7f13e3d94/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol) interface.

For completeness, consider adding these functions to the interface.

***Update:** Resolved at commit [02d88c3](https://github.com/ZKsync-Association/zk-governance/commit/02d88c3470762c78763f735987a5c75061b47151).*

### Scope 2 - Incomplete Interface

The [`reinforceUnfreeze` function](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L484) is missing from the interface [`IProtocolUpgradeHandler`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L8). Consider adding it for code completeness.

***Update:** Resolved at commit [02d88c3](https://github.com/ZKsync-Association/zk-governance/commit/02d88c3470762c78763f735987a5c75061b47151).*

### Scope 2 - Gas Optimization

In for-loops it is more gas efficient to increment the index with `++i` rather than `i++`. Consider applying this change in the for-loop in the [`_freeze`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L465) and [`_unfreeze`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L494) function.

***Update:** Resolved at commit [60f2af5](https://github.com/ZKsync-Association/zk-governance/commit/60f2af54aaf6da89d12b560700d7650a69a4d71d).*

### Scope 2 - Typographical Errors

Throughout the codebase, the following typographical errors were identified:

- ["Default state, indicating the freeze has not been happen"](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L57) should be "Default state, indicating the freeze has not been happening"
- ["SOFT\_FREEZE\_CONSERATIVE\_THRESHOLD"](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L38) should be spelled as "CONSERVATIVE"
- ["executes by"](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L46) should be "is executed by"
- ["make an attempt"](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L135) should be "makes an attempt"
- ["in a unfrozen state"](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L482) should be "in an unfrozen state"
- ["automaically"](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L56) should be "automatically"

Consider correcting the above mistakes to improve the code readability.

***Update:** Resolved at commit [41a7df1](https://github.com/ZKsync-Association/zk-governance/commit/41a7df166fe9cacbfd04b804fd2f743b189d8ed6).*

### Scope 2 - State Variable Visibility Not Explicitly Declared

Throughout the codebase, there are state variables that lack an explicitly declared visibility. For instance:

- The [`EIP1271_THRESHOLD` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/Multisig.sol#L19) in `Multisig.sol`.
- The [`SOFT_FREEZE_PERIOD` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L52) in `ProtocolUpgradeHandler.sol`.
- The [`HARD_FREEZE_PERIOD` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L56) in `ProtocolUpgradeHandler.sol`.
- The [`SOFT_FREEZE_COOLDOWN_PERIOD` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L59) in `ProtocolUpgradeHandler.sol`.
- The [`HARD_FREEZE_COOLDOWN_PERIOD` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L62) in `ProtocolUpgradeHandler.sol`.
- The [`STATE_TRANSITION_MANAGER` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L73) in `ProtocolUpgradeHandler.sol`.
- The [`BRIDGE_HUB` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L76) in `ProtocolUpgradeHandler.sol`.
- The [`SHARED_BRIDGE` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L79) in `ProtocolUpgradeHandler.sol`.
- The [`protocolFrozenUntil` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L96) in `ProtocolUpgradeHandler.sol`.
- The [`softFreezeCooldownUntil` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L99) in `ProtocolUpgradeHandler.sol`.
- The [`hardFreezeCooldownUntil` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L102) in `ProtocolUpgradeHandler.sol`.
- The [`softFreezeNonce` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L42) in `SecurityCouncil.sol`.
- The [`hardFreezeNonce` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L46) in `SecurityCouncil.sol`.
- The [`softFreezeThresholdSettingNonce` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L50) in `SecurityCouncil.sol`.
- The [`unfreezeNonce` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L53) in `SecurityCouncil.sol`.
- The [`softFreezeThreshold` state variable](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/SecurityCouncil.sol#L58) in `SecurityCouncil.sol`.

For clarity, consider always explicitly declaring the visibility of variables, even when the default visibility matches the intended visibility.

***Update:** Resolved at commit [3ed956a](https://github.com/ZKsync-Association/zk-governance/commit/3ed956af36aec8b4dbead4a103000201996ac61f) and at commit [481dcf4](https://github.com/ZKsync-Association/zk-governance/commit/481dcf458452fe34d97bb5f7cfc5b774403ef48f).*

### Scope 2 - Lack Of Hyperchain ID Specific (Un)freeze Reinforcement

The [`reinforceFreeze`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L455-L459) and [`reinforceUnfreeze`](https://github.com/ZKsync-Association/zk-governance/blob/c66fc0b27ef7452188d349dafd8e170095bbd1f0/l1-contracts/src/ProtocolUpgradeHandler.sol#L484-L488) functions have a loop over all hyperchain IDs to perform their respective action. In the rare case where the execution would get stuck at a particular ID for some unforeseen reason, it would be helpful to have reinforcement functions that can target a particular hyperchain ID.

***Update:** Acknowledged, will resolve. The ZKsync Association team stated:*

> *Acknowledged. This will be resolved with the next audit together with using manual call error handling instead of try/catch.*

[![Request Audit](https://no-cache.hubspot.com/cta/default/7795250/7809b604-3f30-4cd5-be58-36982828e327.png)](https://cta-redirect.hubspot.com/cta/redirect/7795250/7809b604-3f30-4cd5-be58-36982828e327)

​​  ​​
