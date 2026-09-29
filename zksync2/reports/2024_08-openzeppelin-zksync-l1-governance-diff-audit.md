# ZKsync L1 Governance Diff Audit

Source: [https://www.openzeppelin.com/news/zksync-l1-governance-diff-audit](https://www.openzeppelin.com/news/zksync-l1-governance-diff-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Security Model](#security-model)
  - [Privileged Roles](#privileged-roles)
  - [Trust Assumptions](#trust-assumptions)
- [High Severity](#high-severity)
  - [Incorrect Hash in Proposal ID Prevents Guardians From Canceling Proposals](#incorrect-hash-in-proposal-id-prevents-guardians-from-canceling-proposals)
- [Medium Severity](#medium-severity)
  - [Security Council Can Keep Protocol in Frozen State](#security-council-can-keep-protocol-in-frozen-state)
- [Low Severity](#low-severity)
  - [Incorrect and Missing Documentation](#incorrect-and-missing-documentation)
  - [Naming Suggestions](#naming-suggestions)
  - [Lack of Hyperchain-ID-Specific (Un)freeze Reinforcement](#lack-of-hyperchain-id-specific-unfreeze-reinforcement)
- [Notes & Additional Information](#notes-additional-information)
  - [File and Contract Names Mismatch](#file-and-contract-names-mismatch)
  - [Typographical Errors](#typographical-errors)
  - [Incomplete Interfaces](#incomplete-interfaces)
  - [Inconsistent Use of Constants](#inconsistent-use-of-constants)
  - [Lack of Indexed Event Parameters](#lack-of-indexed-event-parameters)
  - [Gas Optimizations](#gas-optimizations)
  - [Standard Legal Veto Period Can Exceed Extended Legal Veto Period](#standard-legal-veto-period-can-exceed-extended-legal-veto-period)
- [Conclusion](#conclusion)

## Summary

Type
:   Governance

Timeline
:   From 2024-06-05
:   To 2024-06-12

Languages
:   Solidity

Total Issues
:   12 (11 resolved, 1 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   1 (1 resolved)

Medium Severity Issues
:   1 (1 resolved)

Low Severity Issue
:   3 (3 resolved)

Notes & Additional Information
:   7 (6 resolved, 1 partially resolved)

## Scope

We diff-audited the [zksync-association/zk-governance](https://github.com/zksync-association/zk-governance) repository at HEAD commit [b2e0143](https://github.com/zksync-association/zk-governance/tree/b2e01439937325ceb3d059d0f07c9d73339977a7) against BASE commit [8456ffb](https://github.com/zksync-association/zk-governance/tree/8456ffbf079746349e5513a88cabe4c87919dfc3). All the resolutions mentioned in this report are contained at commit [29f0d0e](https://github.com/zksync-association/zk-governance/commit/29f0d0eec996b41df4e655f603ef1598dd79c0c3).

The following files were in scope:

```
 l1-contracts/
└─ src/
   ├─ EmergencyUpgradeBoard.sol
   ├─ Guardians.sol
   ├─ Multisig.sol
   ├─ ProtocolUpgradeHandler.sol
   ├─ SecurityCouncil.sol
   └─ interfaces/
      ├─ IGuardians.sol
      ├─ IL2Governor.sol
      ├─ IPausable.sol
      ├─ IProtocolUpgradeHandler.sol
      ├─ ISecurityCouncil.sol
      ├─ IStateTransitionManager.sol
      └─ IZkSyncEra.sol
```

***Update:***

*On 2024-08-02 we diff-audited the following two changes:*

- *commit [25fcd9c](https://github.com/zksync-association/zk-governance/commit/25fcd9c06e83089d5d8226f603f9620e8d1f89c8#diff-c5427b9f305f2fd9d0af2784e8542e213f19ea8c3f2302c19dd739e008090df1).*
- *[pull request #3](https://github.com/ZKsync-Association/zk-governance/pull/3) at commit [aa51e3c](https://github.com/ZKsync-Association/zk-governance/pull/3/commits/aa51e3c14c9888bf896eaa47ccd6b181fdee3993).*

*The updated contracts introduced a change to handle an incorrect edge case scenario. Prior to these pull requests, the Security Council could have approved a proposal but it would be evaluated as expired after 30 days have passed if the Guardians did not approve. The changes introduced here reflect the desired expectations, i.e., if the Security Council approves, the proposal will enter either the `PendingExecution` or the `Ready` state, regardless of Guardians approval.*

*Furthermore, on 2024-08-08 we diff-audited the [pull request #4](https://github.com/ZKsync-Association/zk-governance/pull/4) at commit [e8206ed](https://github.com/zksync-association/zk-governance/pull/4/commits/e8206ed42756daa402892a9b58d459b4ee8d2e4c) within the [ZKsync-Association/zk-governance](https://github.com/ZKsync-Association/zk-governance) repository. Prior to this change, an upgrade proposal's execution unfroze all ZKsync contracts, including bridges, state transition managers and all hyperchains before executing the actual proposal. This behavior did not align with the documentation, however. This pull request was introduced to align the effects that the proposal's execution has on the protocol with the documentation, by removing the unfreeze functionality prior to executing the proposed upgrade.*

## System Overview

This upgrade made some adjustments to upgrade the proposal life cycle as well as the L1 governing process. The following are the main changes:

- It removes the `veto` and `refrainFromVeto` functions from the Guardians and, instead, introduces a `LegalVetoPeriod`. This legal veto period is entered into when the upgrade is started on L1 and can be extended by the Guardians from 3 days to 7 days, during which a trusted legal entity can veto the upgrade proposal off-chain. The legal veto is entirely off-chain and incentivizes the Security Council to not approve the upgrade on-chain.
- It allows the Guardians to `propose` and `cancel` L2 proposals to any of the Governors on L2. On some L2 Governors, special roles are assigned to the L1 `Guardian` multisig contract that allow it to propose without having to reach token threshold and/or cancel an active proposal.
- It removes the cool-down period between protocol freezes and automatically unfreezes the protocol upon proposal execution. In addition, the unfreeze action can be performed by the Security Council at any time, or by anyone else if the freeze period has passed.
- The waiting period after which the proposal expires without either the Guardian's or Security Council's approval has been shortened from 90 days to 30 days.
- It streamlined the upgrade state logic that computes the proposal state based on its approval status and block timestamp. This greatly improves code clarity.

The above changes culminate in the following upgrade proposal flow:

1. The upgrade is started on L1, thereby entering the `LegalVetoPeriod`.
2. During the `LegalVetoPeriod`, the Guardians can extend this time from 3 days to 7 days.
3. After the `LegalVetoPeriod`, the state is `Waiting`.
   - If the Security Council approves, the proposal moves to `ExecutionPending`.
   - If the Guardians approve, the proposal remains in `Waiting` and proceeds to `ExecutionPending` after 30 days in `Waiting`.
   - If no one approves, the proposal expires to `Canceled` after 30 days in `Waiting`.
4. From `ExecutionPending`, the proposal processes to `Ready` after 1 day.
5. In `Ready` state, the proposal can be executed and will be `Done`.

## Security Model

### Privileged Roles

As mostly outlined above, the following three are the primary roles in the codebase.

**Guardians:** An 8-member multisig that has the following capabilities:

- The legal entity of the Guardians can perform an off-chain legal veto with the expectation that the proposal will expire. The period allowing to veto can be extended on-chain with a threshold of 2.
- Upgrades can be approved, which then become pending for execution once the 30-day `Waiting` has window passed. The approval requires a threshold of 5.
- Proposals in the L2 Governor contracts can be proposed and canceled with a threshold of 5. This depends on the L2 Governor contract having the Guardians as a privileged role.

**Security Council:** A 12-member multisig that has the following capabilities:

- The Council can approve upgrade proposals that immediately move to the pending stage with a threshold of 6.
- As an incident response measure, the council can soft-freeze the protocol for up to 12 hours with a customizable threshold between 1 and 9 (inclusive). A hard freeze pauses the protocol for up to 7 days with a threshold of 9. The council can unfreeze everything at any time with a threshold of 9.

**Emergency Upgrade Board:** The Board consists of the Guardians, the Security Council, and the ZK Foundation. It has the power to perform an emergency upgrade at any time. All three parties have to sign the upgrade, where the Guardians and the Security Council have to meet a threshold of 5 and 9, respectively.

### Trust Assumptions

During the audit, the auditors identified the following considerations:

- When the legal entity vetoes a proposal off-chain, the proposal is expected to reach a `Canceled` state after 30 days. Thus, it is assumed that the Security Council will not move it forward during the `Waiting` period to the `ExecutionPending` state.
- It is assumed that the upgrade proposal has been through the voting process in the L2 Protocol Governor.
- The `Multisig` contracts do not implement a replayability measure themselves (despite having one for the (un)freezing and the L2 Governor proposing/canceling). Instead, they are dependent on the `ProtocolUpgradeHandler` implementation they interact with, which prevents replayability. However, if these interactions get extended in the future, the replayability countermeasure needs to be re-evaluated.
- When executing an upgrade proposal, arbitrary data can be called on arbitrary targets without any restriction. Thus, it is assumed that the Guardians and Security Council carry the responsibility of validating each call based on up-to-date on-chain conditions.
- Proposals can define a non-zero address that restricts the upgrade execution to that message sender only. Therefore, this address holds the power of not going through with the execution of an approved upgrade proposal, thereby potentially undermining the opinion of the Security Council or the Guardians. Hence, it is assumed that this address is trusted by both parties.
- Proposals can be processed at different speeds so that there may be multiple proposals in the `Ready` state, while their order of execution is not enforced. Thus, it is expected by the Guardians and the Security Council that the order of execution is as intended.
- The incident response measures are expected to be used with the right intention by all of the trusted parties.
- All trusted parties are expected to follow industry standards for securing their private keys and to act responsibly if compromised.
- Users should be aware that there is only 1 day of minimum delay when a regular upgrade is approved by the Guardians or Security Council before it is ready for execution. Emergency upgrades can be executed instantly.

## High Severity

### Incorrect Hash in Proposal ID Prevents Guardians From Canceling Proposals

The `Guardians` multisig on L1 has the privilege to cancel proposals of the Token and GovOps Governor contracts on L2. This is performed by encoding a call to the `cancel` function and sending it through the Mailbox facet. The [function signature](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/governance/Governor.sol#L349-L352) of the `cancel` function takes, besides the targets, values, and calldata, the proposal description as a hash.

According to the [`Governor`'s `propose` function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/governance/Governor.sol#L283), the description string is hashed as `keccak256(bytes(description))`. The `Guardians` contract, however, [hashes the description](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L119) as `keccak256(abi.encode(description))`, which is a different hash and therefore leads to a different proposal ID. Hence, instead of canceling the intended proposal, the call reverts by trying to cancel a non-existent proposal.

Note that this hash mismatch is also present in the [`hashL2Proposal` function](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L182) used to compute the proposal ID that goes into the [cancel](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L102) and [propose](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L148) message digest. Thus, the members are also signing the message for a proposal ID that does not exist in the L2 Governor.

Consider updating the description hash using `bytes`.

***Update:** Resolved at commit [09f72cb](https://github.com/zksync-association/zk-governance/commit/09f72cb56a6563b02cadb1887010e366608d1f8f) and commit [6d8d9aa](https://github.com/zksync-association/zk-governance/commit/6d8d9aadd0c3bf1d6894ab18d9c68b6b984ebcf0).*

## Medium Severity

### Security Council Can Keep Protocol in Frozen State

The `ProtocolUpgradeHandler` enables the Security Council to freeze the protocol as an emergency response measure. This will pause the functionality of all hyperchains and the bridge. The intention with this power is to allow the Security Council to use it only once per upgrade cycle. Hence, if the council has frozen the protocol, but no upgrade has been executed, another freeze must not be allowed. However, this is not enforced. In fact, a malicious or hijacked council can keep the protocol in a frozen state by repeatedly calling [`softFreeze`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/ProtocolUpgradeHandler.sol#L343), or [`hardFreeze`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/ProtocolUpgradeHandler.sol#L352) and [`unfreeze`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/ProtocolUpgradeHandler.sol#L382).

Consider adding a [`FreezeStatus`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L64) `UnfrozenUntilUpgrade` which is set when `unfreeze` is called. As before, whenever an upgrade is executed, the freeze status is reset to `None`. To call `softFreeze`, the status has to be `None`, whereas for `hardFreeze`, the status has to be either `None` or `Soft`.

***Update:** Resolved at commit [40e457b](https://github.com/zksync-association/zk-governance/commit/40e457bb23bc35cbbe4c6c3378a0004f76968a87) and commit [eb723f7](https://github.com/zksync-association/zk-governance/commit/eb723f7331107ed3400a70aff916667dd28b33de).*

## Low Severity

### Incorrect and Missing Documentation

Throughout the codebase, the following instances of incorrect documentation were identified:

- The [`softFreezeThreshold`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/SecurityCouncil.sol#L62) variable is said to reset "after each freeze". It should be after each *soft* freeze.
- A protocol [`hardFreeze`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/SecurityCouncil.sol#L106) can only be initiated by a fixed threshold of 9/12 members. This is not "a small threshold".
- An [array of signatures](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/SecurityCouncil.sol#L122) from council members is approving the *unfreeze* instead of "approving the freeze".
- The `_l2Proposal` parameter of the `proposeL2Governor` function is documented to be [canceled](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L134) instead of being proposed.
- The [`_guardiansSignatures` and `_securityCouncilSignatures`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/EmergencyUpgradeBoard.sol#L59-L60) should include the signers in order to be [decoded correctly](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Multisig.sol#L74) instead of just the signatures.
- The `Guardians` contract is enabled to propose and cancel L2 proposals as well as approve or extend the legal veto period of L1 upgrade proposals through the `ProtocolUpgradeHandler`. However, it cannot veto such an upgrade proposal. It is ambiguous that the Guardians can veto ["the changes proposed by the Token Assembly"](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L15) as it does not clarify the status of the proposal in question. Consider clarifying the veto power of the Guardians more explicitly.

There are also cases of missing documentation:

- Consider documenting the functions of the [`IStateTransitionManger` interface](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IStateTransitionManager.sol).
- Consider documenting the [`TxRequest` struct](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IGuardians.sol#L20).

Consider correcting the documentation and filling in the missing pieces to improve the clarity of the codebase.

***Update:** Resolved at commit [1143fd8](https://github.com/zksync-association/zk-governance/commit/1143fd86d691804ecee1c5cefc7a71ab19efc090). The ZKsync Association team stated:*

> *Fixed. Decided not to document `IStateTransitionManger` interface. It is also consistent with the other interface files.*

### Naming Suggestions

The following instances could benefit from better naming:

- In [`SecurityCouncil.sol`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/SecurityCouncil.sol#L35), the `UNFREEZE_THRESHOLD_TYPEHASH` can be renamed to `UNFREEZE_TYPEHASH` as it is used to form [the digest](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/SecurityCouncil.sol#L126) for the `unfreeze` function and not to set the signature threshold for the `unfreeze` function.
- The function names [`cancelL2Proposal`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L92) and [`proposeL2Governor`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L138) are inconsistent for interacting with the same contract. Consider naming them along their typehash as `cancelL2GovernorProposal` and `proposeL2GovernorProposal`.
- The [`Canceled`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L22) stage of a proposal can only be reached if it expires, being approved neither by the Security Council nor by the Guardians. Hence, consider naming it `Expired`.

Consider implementing the above renaming suggestions to improve the clarity and readability of the codebase.

***Update:** Resolved at commit [d7a2262](https://github.com/zksync-association/zk-governance/commit/d7a2262d6524d47c5725cb7a60eb93376058eddc).*

### Lack of Hyperchain-ID-Specific (Un)freeze Reinforcement

The [`reinforceFreeze`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/ProtocolUpgradeHandler.sol#L363) and [`reinforceUnfreeze`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/ProtocolUpgradeHandler.sol#L392) functions loop over all hyperchain IDs to perform their respective actions. In the rare case where the execution could get stuck at a particular ID for some unforeseen reason, it would be helpful to have reinforcement functions that can target a particular hyperchain ID.

Consider adding reinforcement functions that target a particular hyperchain ID instead of looping over all the hyperchain IDs. This will help save gas and improve the execution flow of the reinforced (un)freezing process.

***Update:** Resolved at commit [3196750](https://github.com/zksync-association/zk-governance/commit/319675052c0824a8dd5e9eaeaed969425c32d1dd) and commit [6148bcd](https://github.com/zksync-association/zk-governance/commit/6148bcdbb68a36cffdf482514ce9a36d6e34c6ef).*

## Notes & Additional Information

### File and Contract Names Mismatch

The [`IZkSyncEra.sol`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IZkSyncEra.sol) file name does not match the `IZKsyncEra` contract name.

To make the codebase easier to understand for developers and reviewers, consider renaming the files to match the contract names.

***Update:** Resolved at commit [187a3db](https://github.com/zksync-association/zk-governance/pull/21/commits/187a3db1ed26c45e8a2edd8b2032644ace7bfde2).*

### Typographical Errors

The following typographical errors were identified:

- ["Concil"](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L11) should be "Council".
- ["FEEZABILITY"](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/ProtocolUpgradeHandler.sol#L339) should be "FREEZABILITY".
- ["Cancel ZKsync proposal on one the L2 governors"](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L87) should be "Cancel ZKsync proposal in one of the L2 governors".

Consider correcting the above typographical errors to improve the readability of the codebase.

***Update:** Resolved at commit [db8a2d7](https://github.com/zksync-association/zk-governance/commit/db8a2d7f29c5bf573f731cef20020e652f689feb).*

### Incomplete Interfaces

The following interfaces were identified as being incomplete:

- The [`IGuardians` interface](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IGuardians.sol) is missing the `cancelL2Proposal`, `proposeL2Governor`, and `hashL2Proposal` functions.
- The [`IProtocolUpgradeHandler` interface](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol) is missing the `upgradeState`, `updateSecurityCouncil`, `updateGuardians`, and `updateEmergencyUpgradeBoard` functions.

For completeness, consider adding the missing functions to the interfaces.

***Update:** Resolved at commit [5b67b04](https://github.com/zksync-association/zk-governance/commit/5b67b0402953275138ecaa6c706722d82c5ad7fd).*

### Inconsistent Use of Constants

Throughout the `Guardians` and `SecurityCouncil` contracts, constants are used to declare descriptive names for the various thresholds. However, the following integers were not specifically declared as constants:

- The [EIP-1271 threshold of 5](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L59) in `Guardians.sol`
- The [EIP-1271 threshold of 9](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/SecurityCouncil.sol#L71) in `SecurityCouncil.sol`
- The [approval threshold of 6](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/SecurityCouncil.sol#L87) in `SecurityCouncil.sol`
- The [unfreeze threshold of 9](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/SecurityCouncil.sol#L127) in `SecurityCouncil.sol`

Consider defining and using `constant` variables instead of using literals to improve the readability of the codebase.

***Update:** Partially resolved at commit [85343ef](https://github.com/zksync-association/zk-governance/commit/85343ef5214e81f47d36a5c9a5f48f5192f6b511). The ZKsync Association team stated:*

> *Partially fixed. We decided not to introduce an additional constant for the EIP1271 signature threshold, as it already has a public immutable variable in the inherited `Multisig.sol` contract.*

### Lack of Indexed Event Parameters

Within `IProtocolUpgradeHandler.sol`, the following events do not have indexed parameters:

- The [`ChangeSecurityCouncil` event](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L99)
- The [`ChangeGuardians` event](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L102)
- The [`ChangeEmergencyUpgradeBoard` event](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/interfaces/IProtocolUpgradeHandler.sol#L105)

To improve the ability of off-chain services to search and filter for specific events, consider [indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events).

***Update:** Resolved at commit [4f98280](https://github.com/zksync-association/zk-governance/commit/4f982807b16a708b637387df6873483c51b4120b).*

### Gas Optimizations

The [`cancelL2Proposal`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L92), [`proposeL2Governor`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L138), and [`hashL2Proposal`](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/Guardians.sol#L175) functions of the `Guardians` contract take the `L2GovernorProposal` and `TxRequest` struct arguments from `memory`. However, the structs could all be handled from `calldata` to save on gas.

Consider using `calldata` instead of `memory` for the struct arguments in the above mentioned functions.

***Update:** Resolved at commit [b816cfc](https://github.com/zksync-association/zk-governance/commits/b816cfce45e0cb8ca27e117a8cb61a65042b29d1).*

### Standard Legal Veto Period Can Exceed Extended Legal Veto Period

The overridable [`STANDARD_LEGAL_VETO_PERIOD()` function](https://github.com/zksync-association/zk-governance/pull/25/commits/25fcd9c06e83089d5d8226f603f9620e8d1f89c8#diff-be245b4be2cdf4a707b2729d0fba97b15566e8ab75b48540a070a5da34b28fe4R34-R36) returns a constant value of 3 days, can be overriden to return an arbitrary `uint256` value, allowing it to return a value that exceeds the [`EXTENDED_LEGAL_VETO_PERIOD` constant](https://github.com/zksync-association/zk-governance/blob/b2e01439937325ceb3d059d0f07c9d73339977a7/l1-contracts/src/ProtocolUpgradeHandler.sol#L37) value of 7 days.

Consider adding a comment as well as an enforced check to ensure that the value returned by the `STANDARD_LEGAL_VETO_PERIOD` function does not exceed the `EXTENDED_LEGAL_VETO_PERIOD`.

***Update:** Resolved in [pull request #3](https://github.com/ZKsync-Association/zk-governance/pull/3) at commit [aa51e3c](https://github.com/ZKsync-Association/zk-governance/pull/3/commits/aa51e3c14c9888bf896eaa47ccd6b181fdee3993).*

## Conclusion

This update makes several adjustments to the Guardians' responsibility in the L1 governance process along with exposing the Guardians to proposals on L2 governors. In addition, changes have been made to the freezing behavior in the protocol upgrade cycle. Particularly, the freeze cool-down period has been removed.

The audit uncovered one high-severity issue pertaining to proposal ID inconsistency with L2 governors, and one medium-severity issue pertaining to reaching an undesirable freeze state was also discovered. Various recommendations to enhance the quality and documentation of the codebase were also made.

We greatly appreciate ZKsync Association team for providing us with thorough documentation and engaging in insightful discussions with the audit team.

[![Request Audit](https://no-cache.hubspot.com/cta/default/7795250/7809b604-3f30-4cd5-be58-36982828e327.png)](https://cta-redirect.hubspot.com/cta/redirect/7795250/7809b604-3f30-4cd5-be58-36982828e327)
