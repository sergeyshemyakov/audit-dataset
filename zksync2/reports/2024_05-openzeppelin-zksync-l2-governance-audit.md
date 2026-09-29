# ZKsync L2 Governance Audit

Source: [https://www.openzeppelin.com/news/zksync-l2-governance-audit](https://www.openzeppelin.com/news/zksync-l2-governance-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [ZkProtocolGovernor Contract](#zkprotocolgovernor-contract)
  - [ZkTokenGovernor Contract](#zktokengovernor-contract)
  - [ZkGovOpsGovernor Contract](#zkgovopsgovernor-contract)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
  - [Privileged Roles](#privileged-roles)
- [Low Severity](#low-severity)
  - [castVoteWithReasonAndParamsBySig Is Incompatible With ERC-4337](#castvotewithreasonandparamsbysig-is-incompatible-with-erc-4337)
  - [Inconsistent Counting Mode](#inconsistent-counting-mode)
  - [Inconsistent Use of msg.sender and \_msgSender()](#inconsistent-use-of-msgsender-and-_msgsender)
  - [Possible Duplicate Event Emission](#possible-duplicate-event-emission)
- [Notes & Additional Information](#notes-additional-information)
  - [Lack of Security Contact](#lack-of-security-contact)
  - [Missing Named Parameters in Mappings](#missing-named-parameters-in-mappings)
  - [Use Custom Errors](#use-custom-errors)
  - [Unused Named Return Variables](#unused-named-return-variables)
  - [Insufficient Documentation](#insufficient-documentation)
- [Conclusion](#conclusion)

## Summary

Type
:   Governance

Timeline
:   From 2024-05-13
:   To 2024-05-21

Languages
:   Solidity

Total Issues
:   9 (4 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   0 (0 resolved)

Low Severity Issues
:   4 (2 resolved)

Notes & Additional Information
:   5 (2 resolved)

## Scope

We audited the [ZKsync-Association/zk-governance](https://github.com/ZKsync-Association/zk-governance) repository at commit [2479575](https://github.com/ZKsync-Association/zk-governance/tree/2479575f7f9fce16792f57d55b9fa986e5e3882f). All the resolutions mentioned in this report are contained at commit [29f0d0e](https://github.com/zksync-association/zk-governance/commit/29f0d0eec996b41df4e655f603ef1598dd79c0c3).

In scope were the following files:

```
 src
├── ZkGovOpsGovernor.sol
├── ZkProtocolGovernor.sol
├── ZkTokenGovernor.sol
├── extensions
│   ├── GovernorGuardianVeto.sol
│   └── GovernorSettableFixedQuorum.sol
└── lib
    └── GovernorCountingFractional.sol
```

​

## System Overview

This audit covers a new L2 governance system intended to be deployed on the zkSync Era chain to govern several different aspects of the ecosystem. The scope mainly consists of three separate top-level governor contracts, namely `ZkProtocolGovernor`, `ZkTokenGovernor`, and `ZkGovOpsGovernor`. All three governors are built on top of the [OpenZeppelin `Governor` module](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/governance/Governor.sol), utilizing pre-built extensions such as `GovernorSettings`, `GovernorVotes`, `GovernorTimelockControl`, and `GovernorPreventLateQuorum`.

In addition, the governors use a fractional vote counting mechanism via the custom `GovernorCountingFractional` extension, allowing voters to split their vote weight among "Against"/"For"/"Abstain". There is an additional custom extension called `GovernorSettableFixedQuorum` which allows the resetting of quorum via governance proposals. All governors are connected to a standard `TimelockController` as the executor. Special proposer and canceller roles are introduced for some governors. These will be discussed in detail below.

### `ZkProtocolGovernor` Contract

This governor is intended to manage proposals related to protocol upgrades. Anyone with enough voting weight in the integrated token can propose a new proposal. A proposal can be canceled by the proposer before voting starts.

### `ZkTokenGovernor` Contract

This governor is intended to manage proposals related to the ZK token used for voting. It has a custom proposing and canceling mechanism:

- Creating a proposal in this governor is guarded. However, an immutable `PROPOSE_GUARDIAN` can propose with 0 threshold at any time. When the proposal guard is turned off, the usual proposing mechanism with the preset `proposalThreshold` can be restored. This flag can be toggled on and off only via a governance proposal.
- Cancellation of a proposal can only be triggered by an immutable `VETO_GUARDIAN` address during either the `active` or `pending` state.

### `ZkGovOpsGovernor` Contract

This governor is intended to manage proposals that are not covered by either `ZkProtocolGovernor` or `ZkTokenGovernor`. This governor has the usual proposing flow with a custom cancellation flow similar to that of `ZkTokenGovernor`, that is, canceling a proposal can only be triggered by an immutable `VETO_GUARDIAN` address during either the `active` or `pending` state.

## Security Model and Trust Assumptions

### Privileged Roles

#### Voters

Each governor allows proposals to change its own governor settings. These are the `onlyGovernance` functions that can be executed via a successful governance proposal. In addition, all governors allow proposals with arbitrary data on arbitrary targets without any restriction. Thus, it is assumed that voters of each governor, as well as `VETO_GUARDIAN`, carry the responsibility for the validation of each call for each governor based on up-to-date on-chain conditions.

#### `PROPOSE_GUARDIAN` and `VETO_GUARDIAN`

The `PROPOSE_GUARDIAN` can propose in the `ZkTokenGovernor` with 0 threshold at any time and the `VETO_GUARDIAN` can cancel a proposal during either the `active` or `pending` state.

#### `TimelockController` as Executor

All governor contracts intend to integrate with a separate standard [`TimelockController`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/governance/TimelockController.sol) to be the [`_executor`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/dc44c9f1a4c3b10af99492eed84f83ed244203f6/contracts/governance/extensions/GovernorTimelockControl.sol#L149). This allows the privileged roles in their respective `TimelockController` to influence the governance process via the timelock. For instance:

- The `PROPOSAL_ROLE` can schedule any proposal.
- The `CANCELLER_ROLE` can cancel any proposal, even successful proposals.
- The `EXECUTOR_ROLE`, if assigned to a non-zero account, can execute any proposal in a ready state.
- The `TIMELOCK_ADMIN_ROLE` can grant or revoke any of the above roles if assigned to a non-zero account.

If self-administrating, additional accounts can be assigned to these roles upon successful proposals via the governance process. We assume that the accounts in charge of the above roles and actions always act in the intended way. Hence, any attacks or vulnerabilities targeting this part of the system were not considered throughout this audit.

## Low Severity

### `castVoteWithReasonAndParamsBySig` Is Incompatible With ERC-4337

ERC-4337 is a standard that allows smart contracts to behave like user accounts. Under this ERC, there will be ERC-4337-compliant smart contract accounts in addition to Externally Owned Accounts (EOAs). To verify the signature when casting a vote with reason and parameters, the `GovernorCountingFractional.sol` contract [uses the OpenZeppelin `ECDSA` library](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L270). However, this library makes a call to the `ecrecover` precompile contract which is incompatible with smart contract accounts.

Hence, to enable [ERC-1271](https://eips.ethereum.org/EIPS/eip-1271) smart contract account signature checks, consider using the [`SignatureChecker` library](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/cryptography/SignatureChecker.sol) instead.

***Update:** Acknowledged, not resolved. The ScopeLift team stated:*

> *An ERC-4337 wallet can use the non-signature methods to vote.*

### Inconsistent Counting Mode

In `GovernorCountingFractional`, the [`COUNTING_MODE`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L56) returns a string that specifies the key-value pair `quorum=for,abstain`. This suggests that both `For` and `Abstain` votes should be counted towards quorum. However, when counting votes to decide whether quorum is reached, [only the `forVotes` are counted](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L94). An inconsistency between the results interpretation of the `COUNTING_MODE` and the `_quorumReached` functions could potentially lead to an incorrect UI representation that causes confusion about the proposal state.

Consider updating the counting mode to be consistent with the actual counting method.

***Update:** Resolved at commit [a694730](https://github.com/ZKsync-Association/zk-governance/commit/a6947305613c9c590c9135ca5ff63868d4fbb3a6).*

### Inconsistent Use of `msg.sender` and `_msgSender()`

A contract may use the `_msgSender()` function in certain cases where it allows meta transactions by overriding the method to extract the original message sender. Consistent use of `_msgSender()/msg.sender` within a contract is important to avoid any unintended consequence for executing meta transactions.

In the following instances, both `msg.sender` and `_msgSender()` are used in the same contract:

- `msg.sender` in [`GovernorGuardianVeto`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/extensions/GovernorGuardianVeto.sol#L33)
- `msg.sender` in [`ZkTokenGovernor`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/ZkTokenGovernor.sol#L125)

Consider manually checking for the consistent usage of `msg.sender`, ensuring that any inconsistency is intentional and heavily documented.

***Update:** Resolved at commit [6afb121](https://github.com/ZKsync-Association/zk-governance/commit/6afb12160cce3ef894211406c7b44d4ce97fd552).*

### Possible Duplicate Event Emission

When a setter function does not check if the value has changed, it opens up the possibility of spamming events signalling that the value has changed whereas it has not. Spamming the same values can potentially confuse off-chain clients.

Within [`ZkTokenGovernor.sol`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/ZkTokenGovernor.sol), the [`_setIsProposeGuarded`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/ZkTokenGovernor.sol#L208-L211) sets `isProposeGuarded` and emits an event without checking whether the value has changed or not.

Although such event emission can only be triggered via a successful governance proposal, consider adding a check to emit an event only when the updated value differs from the current state.

***Update:** Acknowledged, not resolved. The ScopeLift team stated:*

> *We are not implementing this fix. It is unlikely governance will pass a proposal with the same values and if they do it is not clear that clients or integrators should not be made aware.*

## Notes & Additional Information

### Lack of Security Contact

Providing a specific security contact (such as an email or ENS name) within a smart contract significantly simplifies the process for individuals to communicate if they identify a vulnerability in the code. This practice is quite beneficial as it permits the code owners to dictate the communication channel for vulnerability disclosure, eliminating the risk of miscommunication or failure to report due to a lack of knowledge on how to do so. In addition, if the contract incorporates third-party libraries and a bug surfaces in those, it becomes easier for their maintainers to contact the appropriate person about the problem and provide mitigation instructions.

Throughout the codebase, there are contracts that do not have a security contact:

- The [`GovernorCountingFractional` abstract contract](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol).
- The [`GovernorGuardianVeto` abstract contract](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/extensions/GovernorGuardianVeto.sol).
- The [`GovernorSettableFixedQuorum` abstract contract](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/extensions/GovernorSettableFixedQuorum.sol).
- The [`ZkGovOpsGovernor` contract](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/ZkGovOpsGovernor.sol).
- The [`ZkProtocolGovernor` contract](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/ZkProtocolGovernor.sol).
- The [`ZkTokenGovernor` contract](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/ZkTokenGovernor.sol).

Consider adding a NatSpec comment containing a security contact above each contract definition. Using the `@custom:security-contact` convention is recommended as it has been adopted by the [OpenZeppelin Wizard](https://wizard.openzeppelin.com/) and the [ethereum-lists](https://github.com/ethereum-lists/contracts#tracking-new-deployments).

***Update:** Resolved at commit [89af3fe](https://github.com/ZKsync-Association/zk-governance/commit/89af3fe3c4fc9881b4117107aad3b2fc9f37f7a5) and commit [a8f1974](https://github.com/ZKsync-Association/zk-governance/commit/a8f1974be6852b19285db4b7d02ec0ee17325d3d).*

### Missing Named Parameters in Mappings

Since [Solidity 0.8.18](https://github.com/ethereum/solidity/releases/tag/v0.8.18), developers can utilize named parameters in mappings. This means mappings can take the form of `mapping(KeyType KeyName? => ValueType ValueName?)`. This updated syntax provides a more transparent representation of a mapping's purpose.

Throughout the codebase, there are multiple mappings without named parameters:

- The [`_proposalVotes` state variable](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L34) in the `GovernorCountingFractional` contract
- The [`_proposalVotersWeightCast` state variable](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L41) in the `GovernorCountingFractional` contract
- The [`fractionalVoteNonce` state variable](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L49) in the `GovernorCountingFractional` contract

Consider adding named parameters to mappings in order to improve the readability and maintainability of the codebase.

***Update:** Acknowledged, not resolved. The ScopeLift team stated:*

> *This Note is related to the `GovernorCountingFractional.sol` contract, which was audited in the [past](https://flexiblevoting.com/docs/faqs#has-flexible-voting-been-audited). As such, we do not wish to modify or update this codebase.*

### Use Custom Errors

Since Solidity version 0.8.4, custom errors provide a cleaner and more cost-efficient way to explain to users why an operation failed.

Multiple instances of `revert` and/or `require` statements were found within `GovernorCountingFractional.sol`:

- The [`require`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L131) statement with the message "GovernorCountingFractional: no weight"
- The [`revert`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L133) statement with the message "GovernorCountingFractional: all weight cast"
- The [`require`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L153) statement with the message "GovernorCountingFractional: vote would exceed weight"
- The [`revert`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L164) statement with the message "GovernorCountingFractional: invalid support value, must be included in VoteType enum"
- The [`require`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L192) statement with the message "GovernorCountingFractional: invalid voteData"
- The [`require`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L199) statement with the message "GovernorCountingFractional: vote would exceed weight"
- The [`require`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L266-L268) statement with the message "GovernorCountingFractional: invalid params for signature-based vote"
- The [`require`](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L304) statement with the message "GovernorCountingFractional: signature has already been used"

For conciseness and gas savings, consider replacing `require` and `revert` statements with custom errors.

***Update:** Acknowledged, not resolved. The ScopeLift team stated:*

> *This Note is related to the `GovernorCountingFractional.sol` contract, which was audited in the [past](https://flexiblevoting.com/docs/faqs#has-flexible-voting-been-audited). As such, we do not wish to modify or update this codebase.*

### Unused Named Return Variables

Named return variables are a way to declare variables that are meant to be used within a function's body for the purpose of being returned as that function's output. They are an alternative to explicit in-line `return` statements.

Within `GovernorCountingFractional.sol`, there are unused named return variables:

- The [`againstVotes` return variable](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L82) in the `proposalVotes` function
- The [`forVotes` return variable](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L82) in the `proposalVotes` function
- The [`abstainVotes` return variable](https://github.com/ZKsync-Association/zk-governance/blob/2479575f7f9fce16792f57d55b9fa986e5e3882f/src/lib/GovernorCountingFractional.sol#L82) in the `proposalVotes` function

Consider either using or removing any unused named return variables.

***Update:** Acknowledged, not resolved. The ScopeLift team stated:*

> *This Note is related to the `GovernorCountingFractional.sol` contract, which was audited in the [past](https://flexiblevoting.com/docs/faqs#has-flexible-voting-been-audited). As such, we do not wish to modify or update this codebase.*

### Insufficient Documentation

Most of the codebase is very well-documented. However, the following aspect could benefit from clearer documentation.

There are three top-level governor contracts, namely `ZkProtocolGovernor.sol`, `ZkTokenGovernor.sol`, and `ZkGovOpsGovernor.sol`, which are dedicated to processing non-overlapping categories of proposals. However, there is a lack of clear instructions or example proposals to inform proposers about which governor should one send a particular proposal to. In the current setup, if a proposal is sent to the wrong governor, it is through the voting or the cancelling process that the proposal can be stopped. As such, more instructive documentation could help minimize unnecessary voting and cancelling.

Consider expanding and improving the documentation pertaining to sending proposals to governors.

***Update:** Resolved at commits [6d62af4](https://github.com/ZKsync-Association/zk-governance/commit/6d62af472daf6b1064d77042ec088191d57379c4), [021e028](https://github.com/ZKsync-Association/zk-governance/commit/021e028ac8445fb9079cc7afec78814f58594e75), [e1003cf1](https://github.com/ZKsync-Association/zk-governance/commit/e1003cf1ff555739b081283f5c5fec0dd5df8a42) and [4537681](https://github.com/ZKsync-Association/zk-governance/commit/453768164a32a7e776cb4b505e9e70b751537eec).*

## Conclusion

The L2 governance contracts provide ways to manage proposals that affect various aspects of the zkSync Era ecosystem, such as protocol upgrades, token minting and allocation, and other governance activities. This decentralized governance system lays down the infrastructure required to engage the community in protocol governance.

The audit yielded four low-severity issues along with a few recommendations for code improvement. The ScopeLift team, who developed the codebase, provided a detailed specification of the system. We also appreciate ScopeLift's team's valuable input in addressing our questions throughout this engagement.

[![Request Audit](https://no-cache.hubspot.com/cta/default/7795250/7809b604-3f30-4cd5-be58-36982828e327.png)](https://cta-redirect.hubspot.com/cta/redirect/7795250/7809b604-3f30-4cd5-be58-36982828e327)
