# zkSync Layer 1 Audit

Source: [https://www.openzeppelin.com/news/zksync-layer-1-audit](https://www.openzeppelin.com/news/zksync-layer-1-audit)

This first security assessment for zkSync 2.0 was prepared by OpenZeppelin, as part of an ongoing security partnership with Matter Labs.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [Executor](#executor)
  - [Mailbox](#mailbox)
  - [DiamondCut](#diamondcut)
  - [Governance](#governance)
  - [Operation Modes](#operation-modes)
  - [Privileged Roles and Security Assumptions](#privileged-roles-and-security-assumptions)
- [Medium Severity](#medium-severity)
  - [Corruption of facets array on selector replacement](#corruption-of-facets-array-on-selector-replacement)
  - [Freezable property applies to individual selectors instead of facets](#freezable-property-applies-to-individual-selectors-instead-of-facets)
  - [Merkle library verifies intermediate inputs](#merkle-library-verifies-intermediate-inputs)
  - [Proof replayability](#proof-replayability)
- [Low Severity](#low-severity)
  - [\_proveBlock while loop could run out of gas](#_proveblock-while-loop-could-run-out-of-gas)
  - [DiamondInit can be initialized itself](#diamondinit-can-be-initialized-itself)
  - [lastDiamondFreezeTimestamp is unused](#lastdiamondfreezetimestamp-is-unused)
  - [Freezability differences between logical components](#freezability-differences-between-logical-components)
  - [Gas optimizations](#gas-optimizations)
  - [Interface and contract function parameter mismatch](#interface-and-contract-function-parameter-mismatch)
  - [Getter returns misleading value](#getter-returns-misleading-value)
  - [Lack of Documentation](#lack-of-documentation)
  - [Lack of event information](#lack-of-event-information)
  - [Lack of l2Logs validation](#lack-of-l2logs-validation)
  - [Preimage hash collision protection for storage pointers](#preimage-hash-collision-protection-for-storage-pointers)
  - [Require statements with multiple conditions](#require-statements-with-multiple-conditions)
  - [Confusing event emission when executing diamond cut proposals](#confusing-event-emission-when-executing-diamond-cut-proposals)
  - [Unused input to commit blocks](#unused-input-to-commit-blocks)
  - [Unused L2Messages can be committed to L1](#unused-l2messages-can-be-committed-to-l1)
  - [Unverified inputs during block commitment](#unverified-inputs-during-block-commitment)
- [Notes & Additional Information](#notes-additional-information)
  - [AppStorage partially lacks getter functions](#appstorage-partially-lacks-getter-functions)
  - [Block info structs have redundant parameters](#block-info-structs-have-redundant-parameters)
  - [Confusing identifier names](#confusing-identifier-names)
  - [Direct usage of library struct fields](#direct-usage-of-library-struct-fields)
  - [Lack of ERC-165 support](#lack-of-erc-165-support)
  - [File and contract name mismatch](#file-and-contract-name-mismatch)
  - [Inconsistent NatSpec tags](#inconsistent-natspec-tags)
  - [Misleading documentation](#misleading-documentation)
  - [Uninformative reason strings](#uninformative-reason-strings)
  - [Solidity compiler version is not pinned](#solidity-compiler-version-is-not-pinned)
  - [TODO comments in the code base](#todo-comments-in-the-code-base)
  - [Typographical errors](#typographical-errors)
  - [Unorganized file layout](#unorganized-file-layout)
  - [Unused named return variable](#unused-named-return-variable)
  - [Write array length to stack to save gas](#write-array-length-to-stack-to-save-gas)
- [Conclusions](#conclusions)
- [Appendix](#appendix)
  - [Monitoring Recommendations](#monitoring-recommendations)

## Summary

Type
:   Rollup

Timeline
:   From 2022-09-05
:   To 2022-09-30

Languages
:   Solidity

Total Issues
:   35 (25 resolved, 1 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   4 (4 resolved)

Low Severity Issues
:   16 (14 resolved)

Notes & Additional Information
:   15 (7 resolved, 1 partially resolved)

## Scope

We audited the [matter-labs/zksync-2-dev](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/) repository at the `c05b49d7e303996f60a0e35f18ef224e45ee19f5` commit.

In scope were the following contracts:

```
contracts/ethereum/contracts
├── zksync
│  ├── Storage.sol
│  ├── DiamondInit.sol
│  ├── DiamondProxy.sol
│  ├── Config.sol
│  ├── facets
│  │  ├── Executor.sol
│  │  ├── Mailbox.sol
│  │  ├── DiamondCut.sol
│  │  ├── Getters.sol
│  │  ├── Governance.sol
│  │  └── Base.sol
│  ├── libraries
│  │  ├── Diamond.sol
│  │  ├── PriorityQueue.sol
│  │  └── Merkle.sol
│  └── interfaces
│     ├── Mailbox.sol
│     ├── IExecutor.sol
│     ├── IGetters.sol
│     ├── IDiamondCut.sol
│     ├── IGovernance.sol
│     └── IZkSync.sol
└── common
   ├── ReentrancyGuard.sol
   ├── Dependencies.sol
   └── libraries/UnsafeBytes.sol
```

## System Overview

zkSync is a layer 2 scaling solution for Ethereum based on zero-knowledge rollup technology. The protocol aims to provide low transaction fees and high throughput while maintaining full EVM compatibility.

In zkSync users sign and send transactions to validators who process them, include them into blocks, and create a cryptographic commitment of the updated state. This commitment (root hash) is then transferred to a smart contract on layer 1 along with a cryptographic proof (SNARK) proving that this new state was correctly calculated based on applying transactions to a previous state. A compressed state update is also sent to layer 1, allowing anyone to reconstruct the state at any moment. The layer 1 contract validates both the state update and the cryptographic proof, assuring the validity of the transactions included in the block and the data availability.

zkSync protocol implements the Diamond Proxy [EIP-2535](https://eips.ethereum.org/EIPS/eip-2535) as an upgrade mechanism, thereby splitting its functionality into four different facets:

- *Executor*: Processing rollups of layer 2 blocks
- *Mailbox*: Bidirectional communication between layer 1 and layer 2
- *DiamondCut*: Contract administration
- *Governance*: Role management

*Note that while the aforementioned EIP does not contain any known issues, it is not yet considered finalized.*

### Executor

The Executor component allows validators to commit, prove, and execute blocks. All blocks are tentative before execution and can be removed by any validator. This component is central in extending the security guarantees of layer 1 to transactions on layer 2 through rollups.

### Mailbox

The Mailbox component handles bi-directional communications between layer 1 (L1) and layer 2 (L2). To request an L2 transaction from L1, the transaction data is appended to a queue and removed from it upon final inclusion of the L2-rollup into the L1 contract.

In contrast, communication from L2 to L1 is divided in two parts: Sending a transaction on L2 and reading it from L1. To send information from L2, a special opcode `sendToL1` is implemented. Using this opcode, users can send logs or messages. Logs provide a key-value tuple of 32 bytes each to encode data while messages can be of arbitrary length. The transfer of messages is possible via a special system contract converting it into a log containing a hash-commitment. All logs are individually hashed to form the leaf nodes of a block’s fixed-size Merkle tree. The proof of inclusion is made available on L1 by checking against the Merkle tree root. Upon committing a block, verifications are performed to ensure data availability, enabling anyone to prove message inclusion without additional help from the operator.

### DiamondCut

*Note: For a comprehensive explanation of the diamond update mechanism please refer to [EIP-2535](https://eips.ethereum.org/EIPS/eip-2535).*

This component manages upgrade-related operations and freezing/unfreezing of facets. The upgrade mechanism is comprised of three stages:

1. Upgrade proposal – In this stage, the governor commits both a sequence of changes (add/replace/remove) to the supported facet functions and the fixed address of an initializer contract.
2. Upgrade notice period – zkSync users are given a constant timeframe to withdraw their funds if they are against the proposed upgrade, unless the [Security Council](https://blog.matter-labs.io/keeping-funds-safe-a-3-factor-approach-to-security-in-zksync-2-0-a70b0f53f360) approves an immediate emergency upgrade, thereby skipping the execution delay.
3. Upgrade execution – The governor can execute the upgrade and provide additional calldata to the initializer contract.

#### Freezing Mechanism

Matter Labs team has implemented a freezing feature. When defining the facet through diamond cuts, each facet can be set as freezable or not. The governor can freeze the diamond as a whole which affects all freezable facets. Therefore, it is possible to designate parts that shall remain operational in an emergency situation. It is crucial for the DiamondCut facet to remain operational in order to enable the governor to unfreeze the Diamond Proxy after resolving the emergency situation.

### Governance

The Governance component allows the governor to assign and remove the valdiator role from addresses. It further enables the transition of contract administration to a new governor by designating a pending governor who needs to accept his role in an additional step thereby removing the old governor.

### Operation Modes

#### Regular Operation

This operation mode allows only registered validators to commit and execute blocks with rolled-up layer 2 transaction information. Thus, users are dependent on the validators to not censor their transactions. To protect against malfunction and malice a second operation mode exists.

#### Priority Mode

Under specific conditions the system can enter a special operation mode called [Priority Mode](https://v2-docs.zksync.io/dev/zksync-v2/l1-l2-interop.html#priority-mode). This mechanism is intended as an escape hatch to allow users to withdraw their funds from zkSync protocol in the case an operator becomes malicious or unavailable. **During the course of this audit this feature was out of scope due to the fact that it was not yet implemented**.

### Privileged Roles and Security Assumptions

The *governor* is a single address that can perform critical administrative actions such as proposing, canceling, and executing upgrades of the Diamond Proxy, as well as freezing and unfreezing the proxy. The governor is restricted by a time-delay between proposal and execution of any upgrade. However, no other entity can veto, postpone, or restrict the governor’s actions. Further, the governor can set and unset addresses as validators. The governor is considered a trusted entity.

The *security council* is a set of addresses that can skip the time-delay within the approval process of upgrades proposed by the governor to allow immediate incidence response actions. The security council has no power to propose, delay, or veto actions. The exact size of the security council, its members, or the threshold of security council votes to allow immediate execution of a proposal has not been determined at the time of the audit.

The *Verifier* is a smart contract on layer 1 in charge of verifying zk-proofs. It exposes a function that returns a Boolean value indicating whether a given proof is valid. During the course of this audit this feature was out of scope due to the fact that it was not yet implemented.

The *validators* are a set of layer 1 addresses in charge of bundling transactions into blocks, executing them on layer 2, committing their compressed information to layer 1, requesting their zk-proof, and finalizing them on layer 1. Additionally, they are in charge of forwarding messages between layer 1 and layer 2. The validators are partially trusted – at the time of the audit no escape hatch was implemented, hence it is necessary to trust the validators not to censor transactions and refuse/abandon operation. However, the verification of transactions via zk-proofs mathematically prevents validators from spoofing transactions or relaying false information. At the time of the audit, the validators are a centralized entity, while future decentralization is planned.

A set of four *system contracts* on layer 2 has privileged roles and performs special operations:

- The *Contract Deployer* is in charge of deploying contracts on layer 2 via a hash-commitment to the contract’s bytecode.
- The *IL1Messenger* is a contract that allows the transfer of arbitrary-length messages from layer 2 to layer 1 by using a hash commitment within the fixed-size data exchange struct `L2Log`.
- The *INonceHolder* stores transaction and deployment nonces for accounts and exposes them via view functions.
- The *Bootloader* acknowledges received requests which have been passed from layer 1 to layer 2 via the priority queue mechanism.

## Medium Severity

### Corruption of facets array on selector replacement

The [`Diamond` library](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol) allows replacing a selector’s facet with itself which is non-compliant with [EIP-2535](https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions).

Moreover, an edge-case in which a facet only has one selector and this selector’s facet is replaced with itself leads to corruption of the `DiamondStorage.facets` array. Consider the following scenario:

1. A facet has an array of selectors containing only one element `[s1]`. Through the function `diamondCut` a call to `_replaceFunctions` is initiated.
2. Inside of [`_replaceFunctions`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L119), the call to [`_saveFacetIfNew`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L129) does not add any facet, because the facet is already registered.
3. [Inside of the loop](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L131) iterating through the selector array `[s1]`, the call to [`_removeOneFunction`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L136) triggers a call to `_removeFacet` due to the last selector being removed. This in turn removes the facet from the `ds.facets` array.
4. The subsequent call to [`_addOneFunction`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L137) adds selector `s1` back to the facet, while the facet remains deleted from the `ds.facets` array, thereby corrupting it.

To be fully compliant with the EIP-2535 spec and mitigate the edge-case leading to a corruption of the facets array, consider adding the requirement that `_facet` and `oldFacet.facetAddress` are distinct from each other.

**Update:** *Fixed in commit [`f6cde78`](https://github.com/matter-labs/zksync-2-dev/commit/f6cde78d6dbe49aaac4aebefa103b348f1e8b795). The team mitigated this edge-case by rearranging the code. However, with the missing distinction check, the implementation is not fully EIP-2535 compliant.*

### Freezable property applies to individual selectors instead of facets

In the [`DiamondProxy`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/DiamondProxy.sol) contract, a selector is mapped to a facet via the mapping [`diamondStorage.selectorToFacet`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/DiamondProxy.sol#L23) upon executing the `fallback` function. The received datastructure of type `Diamond.SelectorToFacet` contains the information

```
address facetAddress, uint16 selectorPosition, bool isFreezable
```

The flag `isFreezable` is [used to](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/DiamondProxy.sol#L27) determine whether the `delegatecall` of the given selector to the respective facet should be executed.

At the same time, it is the stated intent of the system to allow freezability on the granularity level of facets: While the Diamond shall have a global flag to determine whether it is frozen or not. Each facet shall be marked as either freezable or not.

An issue arises, because the `selectorToFacet` mapping allows different values for the flag `isFreezable` for different selectors of *the same facet*. Which would allow for freezability on the granularity of selectors instead of facets. Consider the following example of two different selectors, one freezable, one not, belonging to the same facet:

```
selectorToFacet[selector1] = SelectorToFacet(facet1, 0, true)
selectorToFacet[selector2] = SelectorToFacet(facet1, 1, false)
```

Moreover, the initialization of the `selectorToFacet` mapping within the `Diamond` library in function [`diamondCut`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L65) actually allows the assignment of different values for `isFreezable`. Consider the following example for the `facetCuts` array:

```
[ (facet1, Add, true, [selector1]), (facet1, Add, false, [selector2]) ]
```

which will lead to an initialization of the `selectorToFacet` mapping given in the example above.

To prevent selector-level granularity of the freezabilitiy property, consider removing the `isFreezable` property from the `Diamond.SelectorToFacet` datatype and add it to a datatype describing only the facet thereby establishing a 1:1 mapping between facet and freezability.

**Update:** *Fixed in commit [`e39eb07`](https://github.com/matter-labs/zksync-2-dev/commit/e39eb07b936cb176b106bd31402b60c330d8bc00).*

### Merkle library verifies intermediate inputs

The [`Merkle` library](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Merkle.sol) enables verification of a Merkle proof by performing an inclusion check of an input against a binary tree. This works by consecutively hashing concatenated sibling nodes until a root hash is generated. The input is one of the leaf hash values, while the proof is a path through the tree containing the missing hash information to regenerate the root.

An issue arises in this library, due to the arbitrary length of the proof. This allows shorter paths to resolve to the same root. Hence, the known hash of an intermediate node is a valid input as well. To visualize, considering the leaf nodes `h0` and `h1`, the hashed concatenation `hash(h0 || h1)` of those hashes would be a valid input along a shorter path. An attacker could utilize the known pre-image to prove its inclusion in the tree. For the standalone library this is a critical problem.

In this particular codebase the `Merkle` library is solely used in the [`MailboxFacet` contact](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol) to [prove the inclusion of a transaction](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L35) within a set of layer 2 logs. Thus, only inputs of type `L2Log` with a length of 88 bytes are legitimate, while the pre-images of size 64 bytes contained within the Merkle tree are not. However, any future usage on 64 bytes input would lead to a critical vulnerability.

It was also stated that the incomplete tree of fixed size is filled with the default hash `hash("")`. This allows an attacker to prove the inclusion of empty bytes by default. Although, no threat was identified for the contracts in scope.

Consider strictly checking the path length of the proof against the desired Merkle tree depth to mitigate the first issue. Further, consider using a default leaf hash with unknown pre-image as countermeasure to the second attack. With respect to documentation, consider sticking to the “leaf” wording for variable naming.

**Update**: *Fixed in commit [`7eb51d9`](https://github.com/matter-labs/zksync-2-dev/commit/7eb51d9de839644b6c1aa8907111ce2f00ddc2ad). Additional checks have been applied outside of the Merkle library to filter malicious inputs. The library itself remains vulnerable to the attack if used in a different context. A note about this problem was added to the function documentation with commit [`5f02309`](https://github.com/matter-labs/zksync-2-dev/commit/5f02309bcb63e7ca96f2b0fdd5595005191cf248).*

### Proof replayability

In the [`proveBlocks` function](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L194) of the `ExecutorFacet` contract, there is no linkage between the committed blocks and the proof. The respective check is commented out in [line 213](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L213). However, as it is commented out, the following is applicable.

The provided proof data is self-contained. Hence, the validator verifies that the given proof is valid in itself. Seeing the validator as a black box, it is assumed that there is no back checking against the committed blocks provided during the call. Therefore, the independence between the committed blocks and proof suggests a replay attack. By providing any formerly valid proof the previously committed blocks would be validated. Thus, all users could verify committed blocks, whether valid or not.

As documented in the code, the necessary check is there but commented out, which is based on the argument that the [`Verifier` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/Verifier.sol) is not yet implemented. However, the commitment check between the blocks and proof has nothing to do with the `Verifier`. Therefore, consider incorporating this crucial check as part of the finalized codebase.

**Update**: *Fixed in commit [`64d6aec`](https://github.com/matter-labs/zksync-2-dev/commit/64d6aec72d7f91eabd730aa39db23e9f7b40d931).*

## Low Severity

### `_proveBlock` while loop could run out of gas

In the [`ExecutorFacet` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol) within the [`proveBlocks` function](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L194), there is a while loop to skip already verified blocks. The loop condition is defined as:

```
while (_hashStoredBlockInfo(_committedBlocks[i]) != firstUnverifiedBlockHash)
```

Therefore, if the committed blocks do no contain the first unverified block, this loop will eventually run out of gas and revert.

Consider limiting the number of loop iterations to the length of the `_committedBlocks` array and reverting with an expressive error message in case the block was not found.

**Update:** *Fixed in commit [`df107f0`](https://github.com/matter-labs/zksync-2-dev/commit/df107f0ae33b66598da74526380ad73c0506fe0c).*

### `DiamondInit` can be initialized itself

The [`DiamondInit` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/DiamondInit.sol) is designed to initialize the `DiamondProxy` or any new facet via a `delegatecall` from the proxy contract. Therefore, the `DiamondInit` contract is deployed on its own with an unprotected [`initialize` function](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/DiamondInit.sol#L19).

Hence, anyone could initialize the deployed instance of the `DiamondInit` contract itself. While this isn’t identified as a threat, it is good practice to prevent arbitrary callers from initializing contracts.

Consider initializing the `DiamondInit` contract via the `constructor` or adding a security mechanism to the `initialize` function.

**Update:** *Fixed in commit [`c9089a5`](https://github.com/matter-labs/zksync-2-dev/commit/c9089a5d3c7a8d03fc911a2b0e09bcd6e0e63fde).*

### `lastDiamondFreezeTimestamp` is unused

In the `DiamondCutFacet` contract, the diamond can be frozen to allow inspection of the protocol’s security. Currently, as part of the [`emergencyFreezeDiamond` function](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L73), [`s.diamondCutStorage.lastDiamondFreezeTimestamp`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L79) is set but not used elsewhere in the code.

Consider either implementing a use-case for this variable or removing it.

**Update**: *Acknowledged, not fixed. The Matter Labs team states:*

> While this feature was not included into this release we prefer to keep the variable to facilitate the rollout of the feature once it is ready.

### Freezability differences between logical components

The usage of the Diamond Proxy pattern allows very modular changes to the system. The standard foresees moving individual selectors from facet to facet. Hence, one logical component (e.g. the `ExecutorFacet`) could be split into two facets, due to patching a single function and migrating the selector to the new facet, while the rest of the logic is kept in the old facet. As the first selector to the new facet defines the freezability, this could result in two different freeze capabilities for one high-level logical component (`ExecutorFacet`).

Implementing checks to cover the joint freezability for the logical facet would introduce additional overhead. Instead, consider extensively documenting this behavior in the [`DiamondCutFacet` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol).

**Update:** *Acknowledged, not fixed. The Matter Labs team states:*

> We acknowledge that this issue raises a valid concern and we are aware that overall documentation improvement is due. This has been in our backlog already and we have now adjusted the priority accordingly.

### Gas optimizations

Throughout the [codebase](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts) there are multiple instances where gas costs can be optimized:

- In [line 162](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L162) of the [`Diamond` library](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol) the `uint16` cast is unnecessary and can be removed.
- Using the `delete` keyword instead of overwriting with the default value saves gas in these instances:
  - [line 33](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Governance.sol#L33) of Governance facet.
  - [line 119-121](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L119-L121) of `DiamondCutFacet` contract.
- In the `approveEmergencyDiamondCutAsSecurityCouncilMember` function, the [`s.diamondCutStorage.currentProposalId` variable](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L100) can be written to stack and reused.
- In the [`ExecutorFacet` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol) on line [113](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L113) and [155](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L155) two `bytes32` values are encoded and hashed. Consider using the `abi.encode` function for the encoding to be more gas efficient.
- In the [`ExecutorFacet` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol), consider writing the [`_maxU256` return value](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L240) to stack to save on the following `s.totalBlocksCommitted` storage reads.

Consider applying the above changes to be more gas efficient.

**Update:** *Fixed in commit [`5a4e81a`](https://github.com/matter-labs/zksync-2-dev/commit/5a4e81aa437eb914ff0b308c3a4336d00260e224). However, the fix introduced a redundant check of conditions within the function `approveEmergencyDiamondCutAsSecurityCouncilMember`.*

### Interface and contract function parameter mismatch

The `revertBlocks` function has a different parameter name in [`IExecutor`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L70) compared to [`ExecutorFacet`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L238). While in the interface the `_blocksToRevert` parameter suggests reverting a relative amount of blocks, the logic sets an absolute `_newLastBlock` which is confusing.

Further, in the `requestL2Transaction` function two parameters have a mismatch between the [`MailboxFacet`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L74) and the [`IMailbox` interface](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IMailbox.sol#L50).

Consider correcting the above mismatches in favor of consistency and clarity.

**Update:** *Fixed in commit [`c0600e0`](https://github.com/matter-labs/zksync-2-dev/commit/c0600e08cdbb7aa21643e63edfa2198f628471fd).*

### Getter returns misleading value

In the [`GettersFacet` contract](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Getters.sol), the function [`isFunctionFreezable`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Getters.sol#L53) returns a Boolean value indicating whether a given selector is freezable or not. This value is taken from storage without any prior validation. At the same time, any uninitialized storage in Solidity contains the default value zero/false.

Querying the function `isFunctionFreezable` for an unknown selector will return `false`, thereby misleading the user to believe that the selector is used within the Diamond and is not freezable.

Consider validating the existence of the selector by requiring that the facet address of the selector is registered.

**Update:** *Fixed in commit [`cfe6f54`](https://github.com/matter-labs/zksync-2-dev/commit/cfe6f54fe65759e43b407fb759704f3b7fc4cfed).*

### Lack of Documentation

Docstrings improve readability and ease maintenance. They should explicitly explain the purpose or intention of the functions, the scenarios under which they can fail, the roles allowed to call them, the values returned, and the events emitted. In the case of structs, docstrings should explain the overall purpose of the struct, each field contained in it, and clarify whether the struct is supposed to be persisted in storage or limited to memory and calldata. If the codebase does not have proper docstrings, it hinders reviewers’ understanding of the code’s intention and increases the maintenance effort for contributors.

Throughout the [zksync-2-dev codebase](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/) there are several parts that do not have docstrings. For instance:

In the [`Storage.sol`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/Storage.sol) contract the following identifiers lack sufficient documentation:

- The [`DiamondCutStorage`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/Storage.sol#L8) struct including all fields
- The [`L2Log`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/Storage.sol#L19) struct including all fields
- The storage information of the [`L2Message`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/Storage.sol#L32) struct as well as its `txNumberInBlock` field

In the [`IMailbox.sol`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IMailbox.sol) interface the following constructs lack sufficient documentation:

- The [`L2CanonicalTransaction`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IMailbox.sol#L9) struct including all fields
- The [`NewPriorityRequest`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IMailbox.sol#L65) event including all fields

In the [`Mailbox.sol`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol) contract the following functions lack sufficient documentation:

- The [`proveL2MessageInclusion`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L17) function
- The [`proveL2LogInclusion`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L26) function
- The [`l2TransactionBaseCost`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L65) function
- The [`requestL2Transaction`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L74) function
- The [`serializeL2Transaction`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L145) function

In the [`IExecutor.sol`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol) interface the following structs lack sufficient documentation:

- The [`StoredBlockInfo`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L14) struct, especially fields `blockHash`, `indexRepeatedStorageChanges`, `stateRoot`
- The [`CommitBlockInfo`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L38) struct, especially field `indexRepeatedStorageChanges`
- The [`ProofInput`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L55) struct including all fields

In the [`DiamondCut.sol`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol) contract the following functions lack sufficient documentation:

- The [`emergencyFreezeDiamond`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L73) function
- The [`unfreezeDiamond`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L84) function
- The [`approveEmergencyDiamondCutAsSecurityCouncilMember`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L96) function

In the [`IGetters.sol`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IGetters.sol) interface the following structs lack sufficient documentation:

- The [`Facet`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IGetters.sol#L26) struct including all fields
- [`SelectorExtended`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IGetters.sol#L31) struct including all fields
- [`FacetExtended`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IGetters.sol#L36) struct including all fields

In the [`Diamond.sol`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol) library the following identifiers lack sufficient documentation:

- The [`DiamondStorage`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L32) struct and all of its fields
- The [`FacetCut`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L52) struct and all of its fields
- The [`DiamondCutData`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L59) struct and all of its fields
- The [`diamondCut`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L65) function
- The [`getDiamondStorage`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L39) function

In the [`PriorityQueue.sol`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol) library the following identifiers lack sufficient documentation:

- The [`Queue`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L19) struct and all its fields
- The [`getLastProcessedPriorityTx`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L25) function
- The [`getTotalPriorityTxs`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L29) function
- The [`getSize`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L33) function
- The [`isEmpty`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L37) function
- The [`pushBack`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L41) function
- The [`front`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L49) function
- The [`popFront`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L55) function

Consider thoroughly documenting all structs and functions (and their parameters) that are part of the contracts’ public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html) (NatSpec). While applying the NatSpec tags, make sure to be consistent with the usage of the respective tag. For instance, use `@notice` for a general description and `@dev` for technical aspects.

**Update:** *Fixed in commit [`8abb05c`](https://github.com/matter-labs/zksync-2-dev/commit/8abb05ca6998f1d576e9eb6ed7ec96f357a408f0).*

### Lack of event information

Throughout the [codebase](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts) we found the following occurrences of state changes without event emission and event emissions with insufficient or incorrect information:

- In the [`ExecutorFacet` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#)
  - the [`proveBlocks` function](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L194) does not emit an event after altering the storage variable `s.totalBlocksVerified`. Consider creating a new event that can emit both the old and new value of this variable.
  - the [`BlocksRevert` event](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L79) is used as `BlocksRevert(s.totalBlocksExecuted, s.totalBlocksCommitted)` which differs from its definition `BlocksRevert(uint256 totalBlocksVerified, uint256 totalBlocksCommitted)` within the [`IExecutor` interface](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol). Consider replacing `s.totalBlocksExecuted` with `s.totalBlocksVerified`.
- In the [`IExecutor` interface](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol)
  - the [`BlockCommit` event](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L73) only contains the `blockNumber`, which might not be unique due to block reversion. Consider adding indexed fields for `blockHash` and `commitment`.
  - the [`BlockExecution` event](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L76) only contains the `blockNumber`. Consider adding indexed fields for `blockHash` and `commitment`.
- In the [`IGovernance` interface](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IGovernance.sol) the [`NewGovernor` event](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IGovernance.sol#L20) emits the new governor. To ease tracking the responsibility of this important role, consider emitting both – the old and new governor – as *indexed* addresses.
- In the [`IDiamondCut` interface](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IDiamondCut.sol)
  - the [`EmergencyDiamondCutApproved` event](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IDiamondCut.sol#L32) only emits the address of the approver, but no information about the diamondcut proposal. Consider indexing the `address` field and adding the fields `currentProposalId`, `securityCouncilEmergencyApprovals` and the indexed field `proposedDiamondCutHash`.
  - the [`Unfreeze` event](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IDiamondCut.sol#L30) does not emit additional information. Consider adding the `lastDiamondFreezeTimestamp` as an event field.
  - the [`DiamondCutProposalCancelation` event](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IDiamondCut.sol#L24) does not emit additional information. Consider adding a `currentProposalId` field and the indexed field `proposedDiamondCutHash`.

Consider emitting events for all state changes and include all relevant state transition information in them to allow precise monitoring via off-chain systems. Consider indexing event fields to facilitate their usage as a search key.

**Update:** *Fixed in commit [`79fd845`](https://github.com/matter-labs/zksync-2-dev/commit/79fd8459fa77c3f70b175a8739338c578250a601).*

### Lack of `l2Logs` validation

In the [`ExecutorFacet` contract](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol) within the `commitBlocks` function, the array `_newBlock.l2Logs` is processed in the helper function [`_processL2Logs`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L75). While any L2 user can be the sender of `l2Logs`, three special senders can determine information influencing the hash commitment of the block. Most notably, the sender `L2_SYSTEM_CONTEXT_ADDRESS` can set the `previousBlockHash` and `blockTimestamp` information. Moreover, multiple `L2Logs` of this sender within one block would override each other.

While the system implicitly assumes that exactly one `L2Log` of sender `L2_SYSTEM_CONTEXT_ADDRESS` is present in each block, this assumption is not enforced during block commitment.

Consider enforcing that only one `L2Log` with sender `L2_SYSTEM_CONTEXT_ADDRESS` is present in each block.

**Update:** *Fixed in commit [`dfc6fe1`](https://github.com/matter-labs/zksync-2-dev/commit/dfc6fe1e700dbad7776844f224e153a2bdbe455b).*

### Preimage hash collision protection for storage pointers

The Diamond Proxy makes use of the diamond storage pattern to track the facets and selectors in use. This is achieved through a [`DiamondStorage` struct](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L32) that contains the relevant facet and selector information. Because of the proxy setup, this struct is placed in an unstructured-storage-manner at a pseudo random storage slot calculated by [hashing a hardcoded string](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L12).

In the event of introducing a dynamic slot calculation using hashing, the `DiamondStorage` storage slot could be specifically addressed to force a collision using the known input bytes from above.

To prevent this pre-image hash collision, consider applying a `-1` offset to the hash.

**Update:** *Fixed in commit [`60b74e0`](https://github.com/matter-labs/zksync-2-dev/commit/60b74e054f9a885bca7a3fd94fbf8376b9a6816b).*

### Require statements with multiple conditions

Throughout the [codebase](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/) there are `require` statements that require multiple conditions to be satisfied. For instance:

- The `require` statement on [line 37](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L37) of [`Executor.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol)
- The `require` statement on [line 251](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L251) of [`Diamond.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol)
- The `require` statement on [line 17](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Merkle.sol#L17) of [`Merkle.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Merkle.sol)

To simplify the codebase and to raise the most helpful error messages for failing `require` statements, consider having a single require statement per condition.

**Update:** *Fixed in commit [`b87267c`](https://github.com/matter-labs/zksync-2-dev/commit/b87267cbb0bbeccb7899d8f29b61b777d295f255).*

### Confusing event emission when executing diamond cut proposals

In the [`DiamondCutFacet` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol), the [`executeDiamondCutProposal`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L42) function is used to execute a previously proposed upgrade.

This function [resets the scheduled diamond cut proposal](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L61), thereby re-purposing the [`_resetProposal`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L114) function. When this function is successfully executed it triggers a `DiamondCutProposalCancelation` event. Afterwards, `DiamondCutProposalExecution` event is triggered by `executeDiamondCutProposal` function.

This dual event emission of cancellation followed by execution could lead to confusion in off-chain systems.

To prevent emitting a cancellation event during the execution of a diamond cut proposal, consider moving the emission of the `DiamondCutProposalCancelation` event from the [`_resetProposal`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L114) function to the [`cancelDiamondCutProposal`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol#L35) function.

**Update:** *Fixed in commit [`fad57c5`](https://github.com/matter-labs/zksync-2-dev/commit/fad57c5ee21e0a848d856c6a3547a746cfaf87cf).*

### Unused input to commit blocks

In the `ExecutorFacet` contract, the [`_commitOneBlock` function](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L19) does not make use of the input `_newBlock.priorityOperationsHash`. Instead, [a local variable `priorityOperationsHash` is calculated from the `_newBlock.l2Logs`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L28) and included in the block commitment.

Consider validating both values against each other.

**Update:** *Fixed in commit [`615b6a5`](https://github.com/matter-labs/zksync-2-dev/commit/615b6a5c86508e6547dd5f6b03b8a7a79ca31137).*

### Unused L2Messages can be committed to L1

In the [`ExecutorFacet` contract](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol) the validator provides multiple blocks of type [`CommitBlockInfo`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L38) to the [`commitBlocks`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L130) function, which are validated in several steps including [`_processL2Logs`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L75). In this function, the preimages contained in the `_newBlock.l2ArbitraryLengthMessages` array are checked against the hashes contained in `L2Logs` with sender `L2_TO_L1_MESSENGER`.

However, the counter [`currentMessage`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L109) is incremented only based on the `L2Log` information, without taking the length of the `_newBlock.l2ArbitraryLengthMessages` into account. In effect, the `_newBlock.l2ArbitraryLengthMessages` array can be longer than the number of relevant `L2Log`s contained in the `_newBlock.l2Logs` parameter which might be confusing to the validator and to off-chain receivers of the respective call data.

Consider the addition of a final check of `currentMessage` against the length of the `_newBlock.l2ArbitraryLengthMessages` array at the end of the `_processL2Logs` function to ensure that only relevant preimages have been included in the calldata.

**Update:** *Fixed in commit [`25913e7`](https://github.com/matter-labs/zksync-2-dev/commit/25913e75ed28dfcd99f36dc9f8bc1d158085f5b0).*

### Unverified inputs during block commitment

In the [`ExecutorFacet` contract](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol) the [`_commitOneBlock` function](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L19) takes the `_newBlock` parameter to validate, extract, and transform block information into a `StoredBlockInfo` struct, which is hashed and stored on chain as a commitment. With a valid zero-knowledge proof this data can later be verified and executed.

However, several fields of the `_newBlock` input parameter are not validated. This could lead to successful commitments of blocks that eventually will not be executable.

Consider preventing the commitment of unexecutable blocks by:

- Validating the field `numberOfLayer1Txs` against the number of `L2Log`s with sender `L2_BOOTLOADER_ADDRESS`.
- Validating the field `l2LogsTreeRoot` against a reconstruction of the Merkle tree from the `l2Logs` array.
- Validating the field `timestamp` against the local variable `blockTimestamp`.

**Update:** *Fixed in commit [`230f400`](https://github.com/matter-labs/zksync-2-dev/commit/230f4007225bc013f9cc15f853af55d4d3588f2b). The Matter Labs team states:*

> We have applied the recommendations #1 and #3. The recommendation #2 is redundant as it is already covered by zero knowledge proofs. Verifying this on Layer 1 would be too expensive so by design this is entrusted to zero knowledge cryptography.

## Notes & Additional Information

### AppStorage partially lacks getter functions

The [`GettersFacet` contract](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Getters.sol) does not expose the entire `AppStorage` via `view` functions. The following storage parts remain inconvenient to read for an outside actor:

- Every aspect of `diamondCutStorage`
- The `pendingGovernor` address
- The `storedBlockHashes` mapping
- The functions `getSize` and `front` of `priorityQueue` as well as a function to determine the position of elements within the queue

Additionally, there is an input size mismatch between the [`l2LogsRootHashes`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/Storage.sol#L62) mapping, which takes an `uint256` key, and the [`l2LogsRootHash`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Getters.sol#L47) getter function, which takes a `uint32` parameter.

Consider exposing all relevant information via getter functions and ensure that function parameters and mapping keys are type-identical.

**Update:** *Fixed in commit [`6b99055`](https://github.com/matter-labs/zksync-2-dev/commit/6b99055413b6ac92d85839543e53ede0fe98078e).*

### Block info structs have redundant parameters

The structs [`StoredBlockInfo`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L14) and [`CommitBlockInfo`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L38) of the [`IExecutor` interface](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol) have the following parameters in common:

- `blockNumber`
- `indexRepeatedStorageChanges`
- `numberOfLayer1Txs`
- `priorityOperationsHash`
- `l2LogsTreeRoot`
- `timestamp`

Consider moving these parameters to a separate `BaseBlockInfo` struct which is then included into `StoredBlockInfo` and `CommitBlockInfo` respectively. Note, this will affect the way the variables are accessed.

**Update:** *Acknowledged, not fixed. The Matter Labs team states:*

> We acknowledge that this issue raises a valid concern. It does not pose a security risk, so we have added it to our development backlog.

### Confusing identifier names

Throughout the [codebase](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts) we found multiple occurrences of identifier names creating confusion:

- In the [`IExecutor` interface](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol) the parameter name used in the signature of the [`revertBlocks` function](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IExecutor.sol#L70) is `_blocksToRevert`. However, the implementation of [said function](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L238) within `ExecutorFacet` calls the same parameter `_newLastBlock` which is consistent with its usage.
- In the [`PriorityQueue` library](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol) the variables `head` and `tail` account for where to add and remove items from the list. Unintuitively, the `head` points to the end of the queue and `tail` points to the front of the queue.

Consider renaming confusing identifiers to prevent misunderstandings and incorrect usage.

**Update:** *Fixed in commit [`03e04cb`](https://github.com/matter-labs/zksync-2-dev/commit/03e04cb082b5f4d3ed0fc74d530c48421a5a26d3) and [`c0600e0`](https://github.com/matter-labs/zksync-2-dev/commit/c0600e08cdbb7aa21643e63edfa2198f628471fd).*

### Direct usage of library struct fields

In the [`MailboxFacet` contract](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol), the function [`_requestL2Transaction`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L84) reads the `head` of the priority queue via [direct access](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L93) to the respective field.

However, it is best practice to decouple the internal structure of a library from the functionality it exposes to other contracts through its functions.

Consider replacing the direct access of struct field `head` with a call to the getter function [`getTotalPriorityTxs`](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L29) that exposes the same information.

**Update:** *Fixed in commit [`8b97af`](https://github.com/matter-labs/zksync-2-dev/commit/8b97af71f42f5ff5d3cf0f03613f972904d2c5c1).*

### Lack of ERC-165 support

External contracts and third-party integrations have no means to discover interfaces supported by the [codebase](https://github.com/matter-labs/zksync-2-dev//blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/).

Consider implementing the `supportsInterface` function of the `ERC-165` standard to expose information about implemented interfaces.

**Update:** *Acknowledged, not fixed. The Matter Labs team states:*

> We acknowledge that this issue raises a valid concern. It does not pose a security risk and comes with additional maintenance overhead if the system is expected to change in the future. We have added it to our development backlog to be addressed once we are out of alpha version.

### File and contract name mismatch

There is a general mismatch between the facet contract names and their file names. While the contracts have a “Facet” suffix, the files have not. The following contracts are affected:

- [`DiamondCutFacet`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/DiamondCut.sol)
- [`ExecutorFacet`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol)
- [`GettersFacet`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Getters.sol)
- [`GovernanceFacet`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Governance.sol)
- [`MailboxFacet`](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol)

Regarding the [interfaces](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces), the individual interface names are based on the filename, e.g. “IDiamondCut”, but instead should align with the contract name.

Consider following the best practice of having identical file and contract names as well as adjusting the interface naming.

**Update:** *Acknowledged, not fixed. The Matter Labs team states:*

> We acknowledge that this issue raises a valid concern. It does not pose a security risk, so we have added it to our development backlog.

### Inconsistent NatSpec tags

Throughout the [codebase](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/) the NatSpec docstring tags `@notice` and `@dev` are used interchangeably. The [Solidity NatSpec documentation](https://docs.soliditylang.org/en/v0.8.17/natspec-format.html) describes the tags as the following:

- `@notice` – Explain to an end user what this does
- `@dev` – Explain to a developer any extra details

Consider applying the respective descriptions across the documentation to be consistent.

**Update:** *Acknoledged, not fixed. The Matter Labs team states:*

> We acknowledge that this issue raises a valid concerns and we are aware that overall documentation improvement is due. This has been in our backlog already and we have now adjusted the priority accordingly.

### Misleading documentation

The [docstring documentation](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L160) of the `_executeOneBlock` function is misleading by stating the following:

> Processes all pending operations (**Send Exits**, Complete priority requests)

However, sending exits is not part of the implementation. Consider revising the comments to accurately reflect the logic.

**Update:** *Fixed in commit [`ce78828`](https://github.com/matter-labs/zksync-2-dev/commit/ce7882843a95de14880c9faf3a5dcc9bfe977625).*

### Uninformative reason strings

The [codebase](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts) uses short alphanumeric codes instead of understandable reason strings in require statements.

Additionally, within [`ReentrancyGuard.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/common/ReentrancyGuard.sol) there is a `require` statement on [line 72](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/common/ReentrancyGuard.sol#L72) that lacks an error message completely.

Consider including specific, informative error messages in `require` statements to improve overall code clarity and to facilitate troubleshooting whenever a requirement is not satisfied.

**Update:** *Partially fixed in commit [`79f6a36`](https://github.com/matter-labs/zksync-2-dev/commit/79f6a36b85e203f262587342ada23120e1089864) by adding the missing error message. In addition, the Matter Labs team states:*

> Improving the error messaging is a large effort that we have added to the backlog for now.

### Solidity compiler version is not pinned

Throughout the [codebase](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/) there are `pragma` statements that allow multiple versions of the Solidity compiler, including outdated versions.

Consider taking advantage of the [latest Solidity version](https://github.com/ethereum/solidity/releases) to improve the overall readability and security of the codebase. Regardless of which version of Solidity is used, consider pinning the version consistently throughout the codebase to prevent bugs due to incompatible future releases and take into account the [list of known compiler bugs](https://solidity.readthedocs.io/en/latest/bugs.html).

**Update:** *Acknowledged, not fixed. The Matter Labs team states:*

> The version is pinned, but not directly in the source files to speed up the development: <https://github.com/matter-labs/zksync-2-dev/blob/openzeppelin-audit/contracts/ethereum/hardhat.config.ts#L82>. It is in the backlog to pin it in the source files after the release.

### TODO comments in the code base

We found the following instances of TODO comments in the [codebase](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/) that should be tracked in the project’s issues backlog and resolved before the system is deployed:

- [Line 17](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/Config.sol#L17) of `Config.sol`
- [Line 50](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/Storage.sol#L50) of `Storage.sol`
- [Line 212](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L212) of `Executor.sol`
- [Lines 70](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L70), [94](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L94) and [136](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L136) of `Mailbox.sol`
- [Line 20](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/interfaces/IDiamondCut.sol#L20) of `IDiamondCut.sol`

During development, having well described TODO comments will make the process of tracking and solving them easier. Without that information these comments might age and important information for the security of the system might be forgotten by the time it is released to production.

Consider tracking all instances of TODO comments in the issues backlog and linking each inline TODO to the corresponding backlog entry. Resolve all TODOs before deploying to a production environment.

**Update:** *Acknowledged, not fixed. The Matter Labs team states:*

> We acknowledge that this issue raises a valid concern. It does not pose a security risk, so we have added it to our development backlog.

### Typographical errors

Throughout the codebase there were a few typographical errors. For instance:

- [line 105](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L105) of the `Diamond` library: “Add facet to the list of facets if the facet address is ***a*** new one”
- [line 192](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L192) of the `Diamond` library: “It is expected but NOT enforced that `_facet` is ***a*** NON-ZERO address”
- [line 295](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L295) of the `ExecutorFacet` contract: “\_blockAuxilaryOutput” should be “\_blockAuxiliaryOutput”

Consider correcting the above and any other typos in favor of correctness and readability.

**Update:** *Acknowledged, not fixed. The Matter Labs team states:*

> We acknowledge that this issue raises a valid concerns and we are aware that overall documentation improvement is due. This has been in our backlog already and we have now adjusted the priority accordingly.

### Unorganized file layout

The [`Diamond` library](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol) has an unorganized layout of code contents, which mixes functions, structs, enums, and events in no particular order. More specifically, we found the following code order in the file:

> constants -> structs -> function -> enum -> structs -> function -> event -> functions

For readability, consider bundling these categories of content into separate code areas in the file.

**Update:** *Fixed in commit [`89953d2`](https://github.com/matter-labs/zksync-2-dev/commit/89953d26ee596b8a4ae6088d85e72b4a8890c7af).*

### Unused named return variable

The [`requestL2Transaction` function](https://github.com/matter-labs/zksync-2-dev/blob/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Mailbox.sol#L74) declares a named return variable `bytes32 canonicalTxHash` in its signature, but uses an explicit `return` statement in its body.

Consider either using or removing the named return as well as applying a consistent style of returning variables.

**Update:** *Fixed in commit [`923b3c3`](https://github.com/matter-labs/zksync-2-dev/commit/923b3c322ac8fafda6b7245c84fb661ed48496eb).*

### Write array length to stack to save gas

In the EVM it is more gas-efficient to read values from stack than from memory or storage. As values are read repeatedly within for loops, it makes sense to write the length of an array to the stack and reuse the stack-variable.

Throughout the [codebase](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/) we found multiple instances to which this optimization could be applied:

- On [line 100](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol#L100) of [file `Executor.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/facets/Executor.sol)
- On [line 69](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L69) of [file `Diamond.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol)
- On [line 108](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L108) of [file `Diamond.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol)
- On [line 131](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L131) of [file `Diamond.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol)
- On [line 148](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol#L148) of [file `Diamond.sol`](https://github.com/matter-labs/zksync-2-dev/tree/c05b49d7e303996f60a0e35f18ef224e45ee19f5/contracts/ethereum/contracts/zksync/libraries/Diamond.sol)

Consider writing the array length to stack by assigning it to a local variable and then using the variable to reduce gas consumption.

**Update:** *Fixed in commit [`2987c69`](https://github.com/matter-labs/zksync-2-dev/commit/2987c69609fcf0e46a43700308d7c1175db6dff5).*

## Conclusions

Over the course of four weeks we audited this layer 1 building block of the zkSync 2.0 project. We’re excited to see Matter Labs making this step and developing the first EVM-equivalent zero-knowledge-based rollup. It goes without saying that this protocol is highly complex, but Matter Labs was really responsive and helpful clarifying any doubts we had and provided dedicated documentation. The design is sound and the code is in a good spot overall, just lacking some documentation. Hence, no high or critical severity issues were identified.

## Appendix

### Monitoring Recommendations

While audits help in identifying code-level issues in the current implementation and potentially the code deployed in production; we encourage Matter Labs team to consider incorporating monitoring activities in the production environment. Ongoing monitoring of deployed contracts helps in identifying potential threats and issues affecting production environment. Hence, with the goal of providing a complete security assessment we want to raise several actions addressing trust assumptions and out-of-scope components that can benefit from on-chain monitoring.

**Upgrades** – The Diamond pattern that defines the code structure allows upgrading the logic of this protocol. Any upgrade must be initiated by the governor via a diamond cut proposal and a subsequent execution. This process must undergo a time delay or requires the security council’s approval for a quicker upgrade. In this context, consider monitoring these events:

- `DiamondCutProposal`
- `DiamondCutProposalCancelation`
- `DiamondCutProposalExecution`
- `EmergencyDiamondCutApproved`

This would allow the detection of the following suspicious activities:

- The introduction of malicious code either as part of a facet or as part of the initializer contract.
- Any diamond cut proposal including an initializer address at which no contract has been deployed so far.
- The init calldata on proposal execution is malicious.
- An unrealistically short time delay between council members’ approvals.

**Freezability** – Further, a governor controlled mechanism was implemented to freeze all freezable facets. In that case the `EmergencyFreeze` and `Unfreeze` events are emitted. An unplanned emergency freeze outside of incident response measures could indicate that the governor role is compromised and performing a DoS attack, therefore consider monitoring the respective events.

**Governance** – The governor and validator roles allow for the execution of crucial operations. The system implements a mechanism to upgrade these addresses. When a new address is proposed for the governor role a `NewPendingGovernor` event will be emitted. Once the proposed address accepts the administrative rights, a `NewGovernor` event will be emitted. Finally, whether a new address is set as a validator or an existing validator changes its state, a `ValidatorStatusUpdate` event will be emitted. Consider monitoring these events to detect unexpected changes to the governor or validators, both of which could signal a compromised governor role.

**Executor** – Blocks submitted to the layer 1 contract typically undergo a three stage process: commit, prove, and execute. Consider monitoring any deviation from this process as it might indicate the following malicious activities performed by rogue validators (censoring or DoS attacks):

- A transaction reverts due to wrong data while aiming to prove or execute a block.
- Any usage of the block reversion function firing the `BlocksRevert` event.

**Mailbox** – To ensure the correct and timely operation of layer 1 (L1) to layer 2 (L2) communication, consider monitoring each invocation of the `requestL2Transaction` function via the `NewPriorityRequest` event, as well as the calldata of each `Executor.commitBlocks` and `Executor.executeBlocks` invocation. This will allow the computation of time deltas between request and inclusion for each L1->L2 transaction. Furthermore, the detection of censorship through dropped transactions will be possible.
