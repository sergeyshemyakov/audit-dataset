# Linea V2 Audit

Source: [https://www.openzeppelin.com/news/linea-v2-audit](https://www.openzeppelin.com/news/linea-v2-audit)

- February 14, 2024

OpenZeppelin Security

OpenZeppelin Security

Security Audits

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [Layer 1](#layer-1)
  - [Layer 2](#layer-2)
- [Privileged Roles](#privileged-roles)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
- [High Severity](#high-severity)
  - [Complex Design of Submission and Finalization Flows Causes Risks](#complex-design-of-submission-and-finalization-flows-causes-risks)
- [Medium Severity](#medium-severity)
  - [Insufficient Validation of Loaded Data Allows Out-of-Order Submission, Preventing Finalization](#insufficient-validation-of-loaded-data-allows-out-of-order-submission-preventing-finalization)
  - [Incorrectly Submitted Tree Depth Prevents Claiming and May Increase the Odds of Forged Messages](#incorrectly-submitted-tree-depth-prevents-claiming-and-may-increase-the-odds-of-forged-messages)
  - [Censorable Claiming of L2 → L1 Messages Due to Required Operator Cooperation with Users](#censorable-claiming-of-l2-l1-messages-due-to-required-operator-cooperation-with-users)
  - [V1 addL1L2MessageHashes Allows L1 → L2 Messages to Be Censored and May Prevent Finalization](#v1-addl1l2messagehashes-allows-l1-l2-messages-to-be-censored-and-may-prevent-finalization)
  - [Message Setter Can Anchor Arbitrary Messages on L2](#message-setter-can-anchor-arbitrary-messages-on-l2)
  - [Incorrectly Submitted Data Prevents Finalization](#incorrectly-submitted-data-prevents-finalization)
  - [Non-Unique compressedData Can Prevent Submission](#non-unique-compresseddata-can-prevent-submission)
  - [Insufficient Validation of Block Numbers During Submission and Finalization](#insufficient-validation-of-block-numbers-during-submission-and-finalization)
  - [Relayer Claiming a Message to a Contract Destination Does Not Refund the User](#relayer-claiming-a-message-to-a-contract-destination-does-not-refund-the-user)
  - [Third-Party Message Claiming for EOAs Is Uneconomical](#third-party-message-claiming-for-eoas-is-uneconomical)
- [Low Severity](#low-severity)
  - [Loaded Shnarf Is Not Checked to Be Non-Empty](#loaded-shnarf-is-not-checked-to-be-non-empty)
  - [Submission Data Can Be Overwritten in Certain Circumstances](#submission-data-can-be-overwritten-in-certain-circumstances)
  - [Insufficient Validations in Polynomial Openings](#insufficient-validations-in-polynomial-openings)
  - [Message Anchoring on L2 Is Not Pausable](#message-anchoring-on-l2-is-not-pausable)
  - [sendMessage Reentrancy on L2 Could Result in Unordered MessageSent Events](#sendmessage-reentrancy-on-l2-could-result-in-unordered-messagesent-events)
  - [Unproven Upgrade State Transition May Reduce Trust in State Validity](#unproven-upgrade-state-transition-may-reduce-trust-in-state-validity)
  - [Sequencer Censorship Issues](#sequencer-censorship-issues)
  - [Code Quality and Readability Suggestions](#code-quality-and-readability-suggestions)
  - [Insufficient Validation of Parent State Root Hashes When Finalizing Without Proof](#insufficient-validation-of-parent-state-root-hashes-when-finalizing-without-proof)
  - [False Sense of Security Due to Validation of Unused Data Fields](#false-sense-of-security-due-to-validation-of-unused-data-fields)
  - [Reliance on Application-Level Logic in Chain State Transition Proof](#reliance-on-application-level-logic-in-chain-state-transition-proof)
  - [Data Chain Integrity Can Be Broken](#data-chain-integrity-can-be-broken)
  - [Intermediary Blocks Are Not Validated](#intermediary-blocks-are-not-validated)
- [Notes & Additional Information](#notes-additional-information)
  - [Typographical Errors](#typographical-errors)
  - [Pause Types Should be Cast to uint8](#pause-types-should-be-cast-to-uint8)
  - [Refund Failure Using send in distributeFees Is Not Addressed](#refund-failure-using-send-in-distributefees-is-not-addressed)
  - [Arbitrary Calls Can Exploit Accidental Token Approvals](#arbitrary-calls-can-exploit-accidental-token-approvals)
  - [Unnecessary receive and fallback Methods](#unnecessary-receive-and-fallback-methods)
  - [claimMessage* Functions Susceptible to Relayer Griefing](#claimmessage-functions-susceptible-to-relayer-griefing)
  - [Compiler EVM Version for L2 Contracts Is paris Instead of london](#compiler-evm-version-for-l2-contracts-is-paris-instead-of-london)
  - [Testing Coverage Issues](#testing-coverage-issues)
  - [Gas Optimizations](#gas-optimizations)
  - [Missing or Misleading Documentation](#missing-or-misleading-documentation)
  - [Multiple Instances of Missing Named Parameters in Mappings](#multiple-instances-of-missing-named-parameters-in-mappings)
  - [Lack of Event Emission](#lack-of-event-emission)
- [Client Reported](#client-reported)
  - [Submission and Finalization Fails for the First Batch of Data Submitted After Migration to the Updated Contract](#submission-and-finalization-fails-for-the-first-batch-of-data-submitted-after-migration-to-the-updated-contract)
  - [Prover Can Censor L2 → L1 Messages](#prover-can-censor-l2-l1-messages)
  - [Malicious Operator Might Finalize Data From a Forked Linea Chain](#malicious-operator-might-finalize-data-from-a-forked-linea-chain)
  - [The Compressed Block Data Is Not Verified Against Data in the Prover During Data Submission](#the-compressed-block-data-is-not-verified-against-data-in-the-prover-during-data-submission)
  - [Empty Compressed Data Allowed in Data Submission](#empty-compressed-data-allowed-in-data-submission)
- [Recommendations](#recommendations)
  - [General Recommendations](#general-recommendations)
- [Conclusion](#conclusion)

## Summary

Type
:   L2

Timeline
:   From 2023-12-11
:   To 2024-01-19

Languages
:   Solidity + Yul

Total Issues
:   41 (20 resolved, 7 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   1 (0 resolved, 1 partially resolved)

Medium Severity Issues
:   10 (5 resolved, 1 partially resolved)

Low Severity Issues
:   13 (5 resolved, 3 partially resolved)

Notes & Additional Information
:   12 (8 resolved, 2 partially resolved)

Client Reported Issues
:   5 (2 resolved)

## Scope

We audited the [Consensys/linea-contracts-audit](https://github.com/Consensys/linea-contracts-audit/tree/) repository at commit [bb6eb72](https://github.com/Consensys/linea-contracts-audit/tree/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a). All the resolutions mentioned in this report are contained at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81), making it the final version reviewed during this audit.

In scope were the following files:

```
 contracts
    ├── LineaRollup.sol
    ├── LineaRollupInit.sol
    ├── ZkEvmV2.sol
    ├── interfaces
    │   ├── IGenericErrors.sol
    │   ├── IMessageService.sol
    │   ├── IPauseManager.sol
    │   ├── IRateLimiter.sol
    │   ├── l1
    │   │   ├── IL1MessageManager.sol
    │   │   ├── IL1MessageManagerV1.sol
    │   │   ├── IL1MessageService.sol
    │   │   ├── ILineaRollup.sol
    │   │   └── IZkEvmV2.sol
    │   └── l2
    │       ├── IL2MessageManager.sol
    │       └── IL2MessageManagerV1.sol
    ├── lib
    │   └── Utils.sol
    └── messageService
        ├── MessageServiceBase.sol
        ├── l1
        │   ├── L1MessageManager.sol
        │   ├── L1MessageService.sol
        │   └── v1
        │       ├── L1MessageManagerV1.sol
        │       └── L1MessageServiceV1.sol
        ├── l2
        │   ├── L2MessageManager.sol
        │   ├── L2MessageService.sol
        │   └── v1
        │       ├── L2MessageManagerV1.sol
        │       └── L2MessageServiceV1.sol
        └── lib
            ├── PauseManager.sol
            ├── RateLimiter.sol
            ├── SparseMerkleTreeVerifier.sol
            └── TimeLock.sol
```

## System Overview

Linea is a Zero-Knowledge (ZK) rollup and an Ethereum Layer Two (L2). It executes L2 transactions, publishes the associated data, and then proves the correctness of the state transition on Ethereum. This correctness is ensured by verifying validity proofs. These are proofs that a ZK circuit reproducing the Ethereum Virtual Machine (EVM) executed the transactions successfully and reached the proposed state. Importantly, validity proofs are succinct, meaning that they are cheaper to verify than re-executing L2 transactions. This allows the execution of transactions to be cheaper, providing users with lower transaction fees on Linea than on L1.

The audited codebase represents the second version (V2) of the Linea rollup contracts which differs from the first version (V1) in a few aspects:

- The data submission and verification logic were reworked in anticipation of EIP-4844.
- An L1→L2 rolling hash mechanism is validated when finalizing on L1. This is to ensure that no L1→L2 messages were maliciously forged or censored by the coordinator on L2.
- Cross-chain L2→L1 messages are now batched and anchored on L1 as the roots of sparse Merkle trees instead of anchoring all the message hashes separately.

Similar to V1, the contracts on both layers are constrained by a `RateLimiter` contract, which limits the amount of ETH that can be sent from L2 and claimed from messages on L1. The codebase is composed of two main contracts to which the Linea contract implementations will be upgraded as part of the version upgrade.

### Layer 1

The `LineaRollup` contract will be upgraded on L1 and is responsible for three main tasks.

The first is to ensure the availability of the data associated with L2 transactions on Ethereum. To do so, a Linea operator batches L2 transaction data, compresses it, and stores it in `calldata` on Ethereum by calling the `submitData` function. The availability of this data is important for rollup users to ensure that the L2 state can be rebuilt without relying on anything else other than the data posted to Ethereum. In the future, this data will be posted to Ethereum as blobs (see EIP-4844).

The second responsibility of the `LineaRollup` contract is to query a PLONK verifier to verify proofs, and thus the validity of state transitions. This ensures that the data submitted to Ethereum matches signed L2 transactions, that these transactions resulted in the proposed state transition, and that the transition is valid. This verification is done by the operator calling the `finalizeCompressedBlocksWithProof` function which finalizes the state transition and stores the new state root.

The third main responsibility of the contract is to send and receive cross-chain messages to and from L2. L1→L2 messages are sent by the users calling the `sendMessage` function which emits a `MessageSent` event. This event is then detected by the coordinator and relayed to L2. Messages sent after the V2 migration will be added to a rolling hash that is reproduced on L2. These rolling hashes are verified to be consistent across the two layers during finalization. During finalization, L2→L1 messages are anchored on L1 in the form of the root of a sparse Merkle tree. Users can then call `claimMessageWithProof` with a Merkle proof against this root to execute their transaction on L1.

### Layer 2

The `L2MessageService` contract will be deployed on L2, and is responsible for sending and receiving messages to and from L1. Similar to the contract on L1, users can call the `sendMessage` function on L2 to have the coordinator relay the cross-chain message and anchor it on L1. In addition, L1→L2 messages are anchored on L2 by the coordinator calling the `anchorL1L2MessageHashes` function, making the message claimable by users and adding it to the L2 rolling hash.

## Privileged Roles

There are multiple privileged roles in the system:

- `OPERATOR_ROLE`: Operators can call `submitData` and `finalizeCompressedBlocksWithProof` on `LineaRollup` to submit data, as well as finalize a rollup state transition (and thus anchor L2→L1 messages).
- `DEFAULT_ADMIN_ROLE`: Addresses with this role can grant any other role to another address, as well as call `finalizeCompressedBlocksWithoutProof` to finalize a state transition without having to provide a valid proof. This function is only intended to be used in case of an emergency and during the V1 to V2 migration. This role has been granted to the Linea security council.
- `VERIFIER_SETTER_ROLE`: This role can call `setVerifierAddress` to set a new address which can verify validity proofs. This role is part of the V2 changes and will be granted to the `Timelock` address as part of the migration.
- `RATE_LIMIT_SETTER_ROLE`: The rate limit setter can call the `resetRateLimitAmount` and `resetAmountUsedInPeriod` functions on the two contracts to change the rate limit or reset the amount in the internal accounting.
- `PAUSE_MANAGER_ROLE`: The pause manager can prevent different sets of functions from being called by pausing the contracts with four different pause types.
- `L1_L2_MESSAGE_SETTER_ROLE`: This role is given to the coordinator who can call the `addL1L2MessageHashes` and `anchorL1L2MessageHashes` functions to anchor L1→L2 messages for V1/V2 respectively.
- `MINIMUM_FEE_SETTER_ROLE`: The fee setter can set the fee collected by the Linea node operator (`block.coinbase`) on L2→L1 messages by calling `setMinimumFee`.

## Security Model and Trust Assumptions

There are several trust assumptions for users of the audited codebase:

- All of the addresses with the roles mentioned above can impact users in different ways, and if compromised, could freeze or steal users' funds depending on the roles granted to them.
- As Linea is a ZK rollup without an open-source circuit, users trust that the circuit faithfully reproduces the EVM execution environment and is implemented in a way that does not allow a malicious prover to supply inputs that may prove an invalid state transition.
- As underlined in one of the issues below, there is currently no software available to rebuild the L2 state from L1-posted data. Users thus trust the Linea operator to send them the data they need to build inclusion proofs or to resume the operation of the chain if the operator and L2 data become unavailable.
- Similar to most rollups today, the sequencer can censor L2 transactions.
- There is currently no way for users to force the inclusion of a cross-chain transaction in neither the L1→L2 nor the L2→L1 direction. This is because Linea's messaging system is purely ticket-based. While messages can be proven to be claimable when finalizing, the L2 sequencer can still censor claiming and L2→L1 transactions.
- As mentioned in one of the issues, the sequencer is assumed to filter uneconomical transactions due to the gas pricing model used by Linea. Users thus have to account for this when submitting, for example, calldata-heavy transactions.

The above assumptions are inherent to the current structure of the audited system. During our audit, we made the assumption that the L1 contracts would be compiled using Solidity 0.8.22, with the EVM version London. Similarly, the L2 contracts should be compiled using Solidity 0.8.19 on London. Following communication with the Linea team, it is also assumed in the following report that the migration to V2 will happen in four transactions executed in the following order:

1. An L1 transaction calling `upgradeAndCall` on the proxy, targeting the `initializeSystemMigrationBlock` function.
2. An L1 transaction granting the `VERIFIER_SETTER_ROLE` to the `Timelock` address.
3. An L2 transaction upgrading the proxy implementation.
4. Later, an L1 transaction from the security council calling `finalizeCompressedBlocksWithoutProof` to migrate the verification to V2 after reaching the target L1 migration block and after anchoring the first V2 message on L2.

**Client-Reported Issues**:

Some issues were reported to us by Linea as part of another audit. They have been included as-is at the end of this report under the [Client-Reported section](#client-reported). As those issues are included as-is, they may include findings that overlap with some of our findings, are out of scope, or are not valid.

## High Severity

### Complex Design of Submission and Finalization Flows Causes Risks

The current design of the submission data and finalization data flows exhibits significant structural and logical complexities.

#### Causes

1. The flow varies based on the combination and nature of the data submitted. For instance, whether submission data and finalization data are submitted separately or together, the finalization data `dataHashes` array length, and the submission `compressedData` length.
2. Data is duplicated between the submission data and the finalization data, resulting in the need for a lot of consistency checks.
3. Data hashes are used as cardinality. Utilizing data hashes as the main key for various data structures poses several challenges:

   - Complex validation and difficulty in tracking parent/child relationships.
   - Unconventional and error-prone approach.
   - Ambiguity about the order and nature of the data which, for example, results in the absence of support for resubmission.
   - Potential for non-uniqueness.
   - Difficulty in reviewing.

#### Impact

The combination of these causes results in a complex and brittle system. Even with thorough reviews and bug fixes, this increases the chances of new bugs being introduced in future code changes.

In the current report, a high number of issues has the above design choices either as a direct cause, or as a significant contributing factor:

- M-01: [Insufficient Validation of Loaded Data Allows Out-of-Order Submission, Preventing Finalization](#m01)
- M-06: [Incorrectly Submitted Data Prevents Finalization](#m06)
- M-07: [Non-Unique `compressedData` Can Prevent Submission](#m07)
- M-08: [Insufficient Validation of Block Numbers During Submission and Finalization](#m08)
- L-01: [Loaded Shnarf Is Not Checked to Be Non-Empty](#l01)
- L-02: [Submission Data Can Be Overwritten in Certain Circumstances](#l02)
- L-10: [False Sense of Security Due to Validation of Unused Data Fields](#l10)
- L-12: [Data Chain Integrity Can Be Broken](#l12)
- L-13: [Intermediary Blocks Are Not Validated](#l13)

Due to the high number of complex and severe issues found, the current design can result in two kinds of high severity scenarios:

- High likelihood of a future medium impact issue.
- Medium likelihood of a future high impact issue. This possibility is further exacerbated by the eventual gradual removal of the heavy usage of access control and "training wheels" which currently make the likelihood of most issues low.

#### Recommendation

To address these issues, a restructuring and simplification of the data structures and transaction flow is recommended:

1. **Data Structure**

   - Utilize L2 batch indices (or block numbers) as the primary key (cardinality) for all data structures to ensure clarity and consistency.
2. **Process Flow**

   - Segregate the data storage writes (in `submitData`) from the storage reads and validation checks (in `finalize`) into separate concerns. This should also help remove most of the data duplication between submission data and finalization data.
   - Allow submission to be reversible and idempotent (for non-finalized batches/blocks), serving strictly as a gas cost-splitting measure. In practice, this would mean that the information required to compute the `shnarf` would be stored (e.g., as a hash) at submission, and the `shnarf` would be computed during finalization.
   - Restrict finalization to not accept submission data, thereby separating concerns and reducing complexity. Alternatively, ensure that `finalize`, if called with the submission data, submits the data as the first step, exactly as if `submitData` were called separately.
   - Perform all checks in the `finalize` step. Since the storage write costs were already paid in `submit`, `finalize` will incur mostly storage read costs, and so should read all necessary data and perform all checks.
   - Crucially, implement only one, unavoidable codepath which checks for all required invariants, and in which the conditional flow does not depend on the contents of the data such as array sizes.

***Update:** Partially resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The submission and finalization flows are now separate, and there is largely a single main flow with some temporary branches to allow an upgrade from an unproven previous state starting from empty data. However, data structures' cardinality remains unchanged, allowing multiple submission chains to co-exist and requiring a large amount of consistency checks.*

## Medium Severity

### Insufficient Validation of Loaded Data Allows Out-of-Order Submission, Preventing Finalization

Data loaded from storage during the initialization in [`_submitData`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L132-L134) lacks sufficient validation, enabling out-of-order data submission (i.e., submitting later data before earlier data). Since previously submitted data cannot be resubmitted, this out-of-order submission irrevocably corrupts the stored data, preventing subsequent finalization. Specifically, `submissionData.dataParentHash` is used to load data that initializes the `shnarf` value.

If submission occurs out of order, either mistakenly or maliciously, the `shnarf` is initialized incorrectly from an empty value, leading to an incorrect `shnarf` being written for the submitted data hash. This differs from the correct data that would result from in-order submission, where the initial `shnarf` would not be empty. The corrupted `shnarf` then becomes unprovable, preventing finalization.

Consider:

- Implementing robust validation to ensure that the data loaded from storage is not empty.
- Exploring additional mechanisms to enforce in-order submission, such as tracking the expected parent hash's submitted block numbers.
- Permitting the correction of incorrectly submitted data by allowing for the resubmission of unfinalized data.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The Linea team stated:*

> *We have implemented additional functionality to validate that various fields are not empty as suggested. These include shnarfs as well as compressed data and finalRootHashes. We have also included the start and end blocks we expect in the data, which will reduce the risk of error. The design choice we have taken is to allow resubmission only in the case of submitting different compressed data for blocks that have not been finalized already.*

### Incorrectly Submitted Tree Depth Prevents Claiming and May Increase the Odds of Forged Messages

The tree depth submitted in [`l2MerkleTreesDepth`](https://github.com/Consensys/linea-contracts-audit/blob/0154676f95a510a855622f8ac9b07816f94edf08/contracts/LineaRollup.sol#L358C74-L358C92) is not validated or sufficiently constrained. Specifically, it is not included in the public input to the proof, so it can be any arbitrary value. This creates several issues:

1. If submitted incorrectly, finalization will succeed. However, it would prevent any messages belonging to the affected message trees from being claimed on L1, since no proof can be provided for the incorrect depth stored. This would allow the operator to censor users even though their cross-chain messages were properly included in the L2 state.
2. A tree depth exceeding the provable depth can be submitted since `l2MerkleTreesDepth` is of size `uint256`, but the proof's `leafIndex` is a `uint32` which would correspond to a maximum depth of 32. Even if the `leafIndex` variable were changed to be of type `uint256`, the maximum depth would still only be `256` and not `type(uint256).max` as allowed now.
3. A maliciously submitted tree depth that is too small allows proving intermediate nodes. While finding collisions with intermediate nodes is not significantly easier than with the leaves, this should not be allowed. In addition, if the submitted depth is too large, this adds an infinite number of "phantom leaves" that do not belong to the actual tree. Finding a proof for these would start from a non-existent "phantom extension" of the tree, hashing the phantom leaf and the supplied proof to try to find a collision with an existing leaf. While not significantly easier than finding second preimages for true leaves, proving phantom leaves should not be possible.

Consider including the depth of the trees in the proof, as well as validating it to be below the maximum possible depth.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The Linea team stated:*

> *As part of the public input, we have now included the Tree Depth. It is now the responsibility of the circuit and prover to enforce the accuracy of this.*

### Censorable Claiming of L2 → L1 Messages Due to Required Operator Cooperation with Users

`l2MessagingBlocksOffsets` is used during [finalization](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L315) of the `LineaRollup` to [emit `L2MessagingBlockAnchored` events on L1](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageManager.sol#L88). These are used to build the proofs required to claim L2→L1 messages. However, the data passed in `l2MessagingBlocksOffsets` is not verified or proven, and so can be arbitrary. Moreover, even if correct data is provided and extracted from these fields, the offsets emitted are not by themselves sufficient to allow reconstructing the proof needed for claiming.

The offsets allow for narrowing the L2 blocks down to only the ones that contain messages. However, the user must rely on the L2 node operator to provide additional information, mainly all the other messages in the blocks that are grouped in the range of finalized blocks along with the block containing their message. The user then must construct the trees for the range by grouping the messages according to the tree depths emitted. Only after reconstructing all the groupings, and subsequently the tree, in full, can they construct the proof for their message. Consequently, if the operator only provided partial information to the L2 network (e.g., an event or block's body is missing), claiming specific messages would not be possible.

While partial transaction data is made available on L1 in the form of compressed calldata, using just the compressed data to reconstruct the events may not be possible. This is because parts of the flow are not currently open-source and verifiably runnable by users. For example, the calldata is transformed in an opaque way to the users by the execution and proving flows. There is, to the best of our knowledge, no public documentation or codebase related to what the L1-posted data exactly contains, and how to rebuild the full L2 state from it to reach the same state as the circuit. As such, lacking verifiable knowledge of the execution being proven and software to reverse engineer the data into state, the user cannot reconstruct all the events in range.

Importantly, while it is theoretically possible to rebuild this state, if working software to reconstruct it is not public, in practice, the state is not trustlessly available from the perspective of an average user. We do note, however, that steps have been taken in this direction, such as open-sourcing the [decompression algorithm](https://github.com/Consensys/compress). Thus, because active cooperation of the operator of the L2 network is required to allow claiming messages on L1, if this cooperation is incomplete or is intentionally used for censorship, some messages may not be claimable.

Consider the following recommendations:

- Rethink the message-passing mechanism to reduce the dependence of users on L2 data provided by the operator. For example, the requirement to have perfect knowledge of all L2 events in a range may need simplification.
- Validate the `l2MessagingBlocksOffsets` as part of the finalization proof to prevent malicious or incorrect values from being used.
- Provide software that users can run to independently reconstruct the L2 state and log history from L1 data without relying on L2 network data that is not verifiably publicly available.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *It is possible to construct the required data range by inferring block ranges from finalization events and the L2 Block number of the sent message. So, it is not critical at this point. We will either be providing the offsets in the circuit and public input in upcoming releases, or alternatively an SDK (software as suggested) that will simplify this process for users/partners etc.*

### V1 `addL1L2MessageHashes` Allows L1 → L2 Messages to Be Censored and May Prevent Finalization

Due to the V1 method for processing L1 messages (`addL1L2MessageHashes`) still existing on L2 and being callable by the operator after the upgrade, two issues arise:

1. The rolling hash mechanism can be circumvented and messages can be added while skipping (censoring) others by calling `addL1L2MessageHashes`. Finalization on [L1 can continue](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L273) without updating the rolling hash (by maintaining the previous one) and the added messages can be claimed on L2 to allow for the continued operation of the uncensored protocols or users.
2. If this V1 method is called mistakenly or maliciously by the operator with a message that was included in the rolling hash on L1 already, finalization on L1 will no longer be possible. This is because a message status can [be set to "received" only once](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L95), and so will be skipped and not included in the rolling hash.

Consider the following recommendations:

- Prevent `addL1L2MessageHashes` from being callable on L2 if `lastAnchoredL1MessageNumber` is not 0. This would mitigate the risk of finalization issues caused by accidental or malicious use of the V1 method.
- Alternatively, ensure that the rolling hash is advanced on L1 by some minimal amount of messages if any unreceived messages exist on L1. This would help ensure that message passing continues without operator censorship or delay.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The Linea team stated:*

> *We have now added an additional check to prevent anchoring with the old method once migration has occurred. This will also negate many of the issues mentioned in M-05.*

### Message Setter Can Anchor Arbitrary Messages on L2

Addresses with the `L1_L2_MESSAGE_SETTER_ROLE` role can anchor messages on L2 to make them claimable. The codebase currently exposes two versions of the L1→L2 messaging flow which are designed to be run independently depending on the the block number:

- V1:
  - [`sendMessage`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageService.sol#L90C12-L90C23) is called on L1. Since `block.number < migrationBlock`, the message hash is added to the outbox.
  - An address with `L1_L2_MESSAGE_SETTER_ROLE` calls [`addL1L2MessageHashes`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L31C12-L31C32), which sets the message hash's status to "received" in the L2 inbox.
  - During finalization, the rollup operator calls [`finalizeBlocks`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/ZkEvmV2.sol#L53C12-L53C26) on L1 which validates the calls to `addL1L2MessageHashes` on L2 by having the circuit verify `batchReceptionIndices`.
- V2:
  - [`sendMessage`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageService.sol#L90C12-L90C23) is called on L1. Since `block.number >= migrationBlock`, the message hash is added to the `rollingHashes` mapping.
  - An address with `L1_L2_MESSAGE_SETTER_ROLE` calls [`anchorL1L2MessageHashes`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L63C12-L63C35). If this call is made for the first time, the message number on L2 [starts from the given message number](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L82). The rolling hash is updated on L2 and the message hash's status is set to "received" in the inbox.
  - During finalization, the rollup operator calls [`finalizeCompressedBlocksWithProof`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L184C12-L184C45) on L1 which validates the L2 rolling hash by verifying that it matches with the L1 and checks the rolling hash message number in the circuit.

However, this currently lets the message setter anchor arbitrary messages in two different ways:

1. The message setter can call `addL1L2MessageHashes` with arbitrary message hashes after the migration and the rollup can finalize using `finalizeCompressedBlocksWithProof`. This is possible as the `batchReceptionIndices` are no longer validated and calls to `addL1L2MessageHashes` do not change the rolling hash nor the message number on L2.
2. During migration, when the [`lastAnchoredL1MessageNumber`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L79C38-L79C65) is still equal to zero, it is possible for the message setter to set [`_startingMessageNumber`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L65C13-L65C35) to `type(uint256).max` and anchor two arbitrary messages. This is due to the [message number being iterated in an `unchecked` block](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L99-L101) which would cause it to overflow back to 0. Since `currentL1MessageNumber == 0 == lastAnchoredL1MessageNumber` at the end of the function, neither [`lastAnchoredL1MessageNumber` nor the rolling hash would be updated](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L117C5-L123). The rollup would thus be able to finalize with these arbitrary anchored messages and this can be repeated before updating the rolling hash. This would also result in several emissions of the `ServiceVersionMigrated` event.

The message setter role is permissioned which greatly reduces the likelihood of this issue occurring. However, by anchoring arbitrary messages while still passing finalization, it would be possible for the message setter to drain assets from the rollup or to silently anchor messages to do so at a later date.

If the circuit does not already verify this, consider validating in the V2 circuit that no calls to `addL1L2MessageHashes` were made. This could be achieved by verifying that all `L1L2MessageHashesAddedToInbox` events emitted were followed by a `RollingHashUpdated` event. Additionally, consider removing the [`unchecked` block](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L99-L101) when incrementing `currentL1MessageNumber`, as well as reverting if [`currentL1MessageNumber == lastAnchoredL1MessageNumber`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L117) or [`inboxL1L2MessageStatus[messageHash] != INBOX_STATUS_UNKNOWN`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L95).

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). While scenario #1 is still possible, it is only possible immediately following the migration while no messages were anchored using the V2 mechanism, which reduces the risk. The `unchecked` block was also removed. The Linea team stated:*

> *With the change in M-04, we can no longer anchor with the old method, negating the first portion of the finding. It is worth noting that scenario 1 has not played out and the contracts have successfully been migrated without issue. We have also removed the `unchecked` block to prevent overflow concerns.*

### Incorrectly Submitted Data Prevents Finalization

If [`submitData` is called](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L115) with incorrect data, the data cannot be overwritten or reverted and must be finalized. Since the data is not verified or fully proven during submission, this would cause finalization using this data to be impossible.

Examples of potential operator/node implementation mistakes include:

- Incorrect setting of the `finalStateRootHash`
- Incorrect linking of the `dataParentHash`
- Other incorrect inputs included in the `shnarf`, such as the `snarkHash` (and thus the polynomial openings)

Crucially, the emergency function `finalizeCompressedBlocksWithoutProof` also uses the data submitted during previous submissions (e.g., `dataParents` and `dataFinalStateRootHashes`). Therefore, this might also make it impossible to finalize using this method without resubmitting the data in a different form or upgrading the implementation.

Consider the following recommendations:

- Allow overwriting submitted data prior to finalization.
- If the separate data submission flow is required for cost splitting/gas savings, or to separate the submission from finalization in preparation for EIP-4844, consider moving all validation checks into the finalization method.
- Alternatively, if possible, remove the submission method and validate all data during the finalization method.

***Update:** Acknowledged, not resolved. While a workaround for submitting alternate data does exist to fork the submission chain, it relies on both the different provable data existing and the design choice of allowing multiple data-chains to co-exist. The Linea team stated:*

> *With the addition of the block range checks, risk or issue with continuity is reduced. In addition, if all the blocks and compressed data submissions are linked, it is more likely, if anything, that the last data item in a finalization has the potential for being wrong if the expected final state is wrong. We have the option of submitting alternate compressed data to rectify this, and the likelihood of this scenario is small. As part of pre-execution checks, we can simulate the expected shnarf and validate that the outcome is correct, thereby further reducing risk.*

### Non-Unique `compressedData` Can Prevent Submission

The [hash of the compressed data](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L149) is used as a key in [several mappings](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L19-L21). As this data omits some transaction data and is not clearly constrained to be unique for each block, it is possible that two blocks will have the same compressed data. Specifically, if the data omitted from transactions (such as nonce and signature) allows the data to be repeated, the transaction data can be non-unique. If the global parts of `compressedData` for such blocks are not guaranteed to be unique (e.g., there's no block number or timestamps can repeat), this will [prevent submission](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L152) as if this data had already been submitted.

In practice, timestamps are included in the compressed data but are not validated to be strictly unique (only non-decreasing). As a consequence, submission can be blocked, either separately or during finalization. This would require the data to be altered to ensure that it hashes to a previously unused hash.

Consider ensuring that the compressed data is constrained such that it must include a per-block unique component to prevent collisions. Furthermore, consider avoiding the use of the data hash as the main cardinality for the stored and validated data. Instead, use the L2 batch number for the cardinality.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *Our design choice is to use the `dataHash` as cardinality so that if we do need to resubmit batches for whatever reason, we can do so with a different set of data. We opted for immutable data items so that if we need to resubmit data, we could so consciously and transparently.*

### Insufficient Validation of Block Numbers During Submission and Finalization

The rollup operator is tasked with finalizing L2 blocks on the L1 `LineaRollup` contract. To do so, two functions are used in normal operations:

1. [`_submitData`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L131C12-L131C23) can be called to submit data that will be used later during finalization
2. [`finalizeCompressedBlocksWithProof`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L184C12-L184C45) can be called to finalize blocks by using a mix of previously submitted data and newly submitted data

However, the consistency of block numbers is not sufficiently checked, notably:

- When submitting data, the first block number is [checked](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L137-L139) to be strictly superior to the `currentL2BlockNumber`. However, by the time this data is used in finalization, the first block number may not be equal to `currentL2BlockNumber + 1`. In the worst case, the first finalizing block may even end up being inferior to the (updated since submission) `currentL2BlockNumber`. This could result in block numbers being skipped, or two finalized blocks having the same block numbers.
- When submitting data, there is no validation that the `firstBlockInData` matches the `finalBlockInData` of the [parent data](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L137-L147). Only the [`finalBlockInData` of the last newly submitted data is validated during finalization](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L300-L302). This could result in finalized data with unordered or nonconsecutive block numbers.
- When finalizing without submitting new data, there is no check to ensure that the last `finalBlockInData` of the previously submitted data matches `_finalizationData.finalBlockNumber`. Such a [check](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L342-L346) is only present when submitting new data as part of finalization. This could result in a finalized block number not matching the submitted data.

Consider validating that submitted blocks numbers are consecutive at submission time. In addition, consider validating that the first block in the submitted data is equal to `currentL2BlockNumber + 1` during finalization. This can be done by either adding a check or having the block numbers be part of the `shnarf`. Moreover, consider validating that the `finalBlockNumber` matches across the finalization and submission data when finalizing without submitting new data.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). Additional validations were added to prevent the mentioned scenarios. The Linea team stated:*

> *We have added block ranges to data submission as well as a check on finalization to validate order. Note that the first submission is expected to allow zeros as it does not exist in the mainnet contract.*

### Relayer Claiming a Message to a Contract Destination Does Not Refund the User

A relayer claiming a message on [L2 to a contract destination does not refund the user](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L232), resulting in the fee always being fully taken by the relayer. During submission, when specifying the fee on L1, the fee will always either be overestimated or underestimated due to unknown gas conditions on L2 during claiming. Consequently, if underpaid, it will be uneconomical to relay, or if overpaid, it will unnecessarily leak value from users.

In contrast, for EOAs, the refund mechanism mitigates this issue by refunding overpayments, thus allowing sustained operation by the subsidized relayers. The absence of similar functionality for contract destinations limits the usefulness and reliability of cross-chain applications built on this messaging system, raising their maintenance costs since cross-chain applications will need to run and subsidize their own relay bots or force users to overpay for the gas fees. Since anything other than bridging ETH to an EOA requires calling contracts, this approach significantly impairs cross-chain functionality. Specifically, in times of rising gas prices, a backlog of unrelayed transactions will accumulate, causing unreliable user experiences for cross-chain applications relying on this mechanism.

In practice, the impact of this will likely be complexity and additional costs for cross-chain protocols, which will probably be passed on to their users as higher costs and risks. Alternatively, users will be directly forced to overpay for gas fees for cross-chain messaging. Both scenarios result in a low impact but highly likely value leakage from users.

Consider redesigning the gas metering system for cross-chain messages so that a refund mechanism for contract destinations is viable. For example, the cross-chain payload may [specify `maxFeePerGas`, `gasLimit`, and `refundRecipient`](https://docs.arbitrum.io/arbos/l1-to-l2-messaging) instead of a total amount and unlimited gas. Such a mechanism can limit overpayment by users by refunding any oversupplied fees to the refund recipient while providing a predictable incentive for relayers.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *We are considering options for this already and there are no changes for this audit.*

### Third-Party Message Claiming for EOAs Is Uneconomical

Users on L1 and L2 can send cross-chain messages which are anchored on the other layer by the coordinator. These anchored messages can then be [claimed](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L145C12-L145C24) by anyone to execute the underlying transaction. Claiming a message gives the potential fee associated with it as reward to the claimant.

When the target of a cross-chain transaction [does not have runtime bytecode](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L228) (e.g., EOAs), the fee received by claiming the message is capped and the difference is refunded to the target EOA. This difference is computed as the amount of gas which was available at the start of the function minus what is available at the end, plus a constant called [`REFUND_OVERHEAD_IN_GAS`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L40C29-L40C51). `REFUND_OVERHEAD_IN_GAS` captures other fixed costs which are not accounted for by the gas difference such as the transaction costs and the gas costs of refunding the EOA. This mechanism ensures that users bridging in or out of the rollup with their EOAs do not get overcharged.

On L1, users can claim messages by calling [`claimMessage`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/v1/L1MessageServiceV1.sol#L102C12-L102C24) if the rollup finalized using [`finalizeBlocks`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/ZkEvmV2.sol#L53C12-L53C26) (V1) or [`claimMessageWithProof`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageService.sol#L123C12-L123C33) if the rollup finalized using [`finalizeCompressedBlocksWithProof`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L184C12-L184C45) (V2). On L2, the function to claim messages is the same for V1 and V2 and is called [`claimMessage`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L145C12-L145C24). The table below summarizes the gas costs associated with transactions claiming messages through the V1 and V2 version of each contract.

The L1 contracts were compiled with Solidity 0.8.22, EVM version London, and 100,000 optimization runs. The L2 contracts were compiled with Solidity 0.8.19, EVM version London, and 100,000 optimization runs. The value sent per message was set to 0.05 ETH, the message numbers start from 1, and the leaves of the Merkle trees were randomized to be non-zero. This follows discussions with the Linea team to try to match their deployment configuration and real-world transactions. The gas costs given were averaged over 1000 simulated transactions.

| Name | Actual gas cost | Current refund |
| --- | --- | --- |
| L1 V1 | 39961 | 47947 |
| L1 V2 with 4 leaves | 46874 | 47947 |
| L1 V2 with 32 leaves | 48411 | 47947 |
| L1 V2 with 1024 leaves | 51005 | 47947 |
| L2 V1 | 44761 | 44596 |
| L2 V2 | 44761 | 44596 |

As seen in the table, the refund to claim messages on L1 using `claimMessageWithProof` is currently underestimated when the Merkle tree contains 32 or more leaves. The same is true for claiming messages on L2. This would make it uneconomical for anyone to claim these messages. Besides, the gas costs to claim a message on L1 V2 strictly increase with the depth of the Merkle tree as the proof is given as argument in [calldata](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageService.sol#L124). This means that the appropriate refund value should be adaptive based on the depth of the tree. We also note that with the gas costs having increased for L1 users of the V1 version, they would currently be overcharged by around 20%.

When the refund is higher than the gas cost, claiming messages containing transactions targeting EOAs is profitable for third parties (called postmen). However, when the refund is below the gas cost, claiming such messages incurs ETH costs for the postmen. Thus, to make it economical to relay without relying on altrustic subsidy, the refund should always be slightly higher than the gas costs to incentivize third-party postmen to claim messages without incurring losses or overcharging users. If the refunds are too low compared to the transaction costs, actors deciding to subsidize these costs will perpetually lose money and would expose themselves to potential griefing attacks.

As this incentive margin comes from users, it should be carefully considered to balance overcharging and incentivizing relayers. The current target margin of 0% most likely undershoots the right balance. Thus, to allow for a decentralized and incentive-compatible relaying mechanism, the refund overhead should at least cover the gas and additional costs (maintenance, RPC and automation infrastructure, monitoring) of relayers.

Consider the following recommendations:

- Overall, a non-zero incentive margin should be added over the estimated cost and potentially altered (or made configurable) with time. To arrive at the right margin percentage, consider using the data from present-day relayer deployments. Alternatively, depending on your objectives, consider starting it at 5% and either increasing it if no third-party relayers participate or decreasing it if too many do.
- The refund overhead for L1 V1 should be separate from L1 V2.
- If the depth of the tree is expected to change, the L1 V2 refund should be variable, based on the size of `ClaimMessageWithProofParams.proof`.
- The refund overhead for L2 V2 should be increased.

***Update:** Partially resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The gas refund for L1 V2 was increased. The Linea team stated:*

> *We have recomputed our values and made adjustments that increase the L1 claiming to `48252`. We are looking into other options and adjustments in the area of the `distributeFees` and claiming mechanics as part of future releases. Furthermore, as we expect the common case post migration to be that of claiming with proof, having the switch and additional code will not be added at this point. We will monitor and make appropriate changes where needed when the mechanism is reworked.*

## Low Severity

### Loaded Shnarf Is Not Checked to Be Non-Empty

During calls to the [`finalizeCompressedBlocksWithProof`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L205-L209) function, if the shnarf returned from `_finalizeCompressedBlocks` is empty (due to a lack of submission data), it will be loaded from `dataShnarfHashes`. However, the loaded shnarf is not explicitly validated to be non-empty.

It is possible to establish that it cannot be empty because [this codepath](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L304-L312), which is taken if `SubmissionData` is empty, involves loading the `finalBlockState` from `dataFinalStateRootHashes`. This `finalBlockState` is [written simultaneously with `dataShnarfHashes`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L156-L170), from which the shnarf is loaded. Since the loaded `finalBlockState` is checked to be non-empty, the stored shnarf hash is also presumed to be non-empty. However, this reliance on the coupling of several different conditional flows and data states is brittle. Direct validation and revert would ensure that only correctly initialized data can be used in current and future code.

Consider explicitly validating that the loaded shnarf is non-empty. Additionally, consider moving the [loading of the shnarf](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L205-L209) fully into `_finalizeCompressedBlocks`. This code could be moved to where [the shnarf return value is set](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L329-L343) when `_submitData` has not been called. If the code is moved, care should be taken to continue supporting finalization without proof from an empty shnarf as it will be needed during migration.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The Linea team stated:*

> *We have added an additional empty check for when the shnarf is not expected to be a zero hash. We have left the additional shnarf checks/loading on the outside as it is only needed when we are finalizing with proof.*

### Submission Data Can Be Overwritten in Certain Circumstances

[`_submitData` ensures that data cannot be resubmitted](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L151-L152). It does this by checking that the loaded `dataFinalStateRootHashes` hash is not empty. However, when [storing the hash](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L156), no validation is performed to ensure that a zero hash is not stored. Therefore, if `submissionData.finalStateRootHash` is passed as zero, the storage of `dataParents` and `dataShnarfHashes` can be written to in a way that will allow them to later be overwritten. This is because the check for a zero hash in `dataFinalStateRootHashes` will pass on subsequent calls to `submitData` with the same compressed data hash.

This lack of validation allows the shnarf used in the proof to be updated after submission as long as the compressed data used is the same. For example, a resubmission with different `snarkHash`, `compressedDataComputedX`, or `finalStateRootHash` becomes possible. While the shnarf is used in the proof and is likely constrained by the circuit to only valid state transitions, overwriting submission data should either be explicitly allowed or disallowed to prevent hidden updates.

Consider validating that all semantically overloaded data (assuming empty to mean "uninitialized") cannot be written to with empty data. Specifically, ensure `finalStateRootHash` cannot be passed as zero.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). A check was added in the `_submitData` function to ensure that the final state root is not empty.*

### Insufficient Validations in Polynomial Openings

Similarly to what will be implemented for EIP-4844, submitted data is represented by a [polynomial](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L384-L413) and opened at a random point to validate that it matches with the data given as witness to the circuit. This point is computed in practice as a hash derived from the submitted data and a commitment to the witness (represented as a SNARK-friendly hash of the witness data, `snarkHash`) following the Fiat-Shamir heuristic.

However, we found that the following validations are missing:

- `compressedDataComputedX` is not checked to be an element of the scalar field.
- There is no explicit validation on the size of the submitted data and thus the degree of the polynomial (which will be limited to 4096 in EIP-4844). While there is an implicit constraint through the block size limit, we would recommend either adding an explicit check or documenting this decision.

We do not, at the time of this report, have access to the circuit. Thus, we cannot confirm nor deny that the lack of these validations could cause concrete issues. However, we do recommend adding them for good practice.

Consider adding the mentioned validations/documentation.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). Documentation has been added for both of the mentioned points.*

### Message Anchoring on L2 Is Not Pausable

Messages can be anchored on L2 by addresses having the `L1_L2_MESSAGE_SETTER_ROLE` role. This is done by calling the `addL1L2MessageHashes` or the `anchorL1L2MessageHashes` function. However, these functions are not currently pausable. Making them pausable could prove helpful in the future (e.g., if a message setter address is compromised).

Consider making these functions pausable (e.g., under `GENERAL_PAUSE_TYPE`).

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The mentioned functions were made pausable for the general pause type.*

### `sendMessage` Reentrancy on L2 Could Result in Unordered `MessageSent` Events

The `sendMessage` function can be called on L2 to send a cross-chain message to L1. When doing so, `coinbaseFee` is collected from the value sent and transferred to the `block.coinbase` through a low-level [call](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L125).

However, this makes it possible for `block.coinbase` to reenter `sendMessage` before the [`MessageSent`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L130) event is emitted. This could result in events being emitted in decreasing order of message numbers, with the message number from the subcall getting emitted before the message number from the main function call. With the `block.coinbase` on L2 being the sequencer currently run by Linea, the likelihood of this issue is low. However, the impact is unknown as it depends on how the coordinator and the circuit process these events and the associated messages.

Consider emitting the `MessageSent` event before transferring the `coinbaseFee` to `block.coinbase`.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81).*

### Unproven Upgrade State Transition May Reduce Trust in State Validity

The planned transition from the V1 to the V2 finalization flow is set to utilize [`finalizeCompressedBlocksWithoutProof`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L240). This approach has been chosen because the prover does not support establishing the initial conditions required for the V2 flow.

However, employing `finalizeCompressedBlocksWithoutProof` permits arbitrary state changes, including potentially undetectable ones that could be exploited in the future. For example, an account's ETH or token balance could be set to a high number, eventually allowing the L1 bridge to be drained. While having the `finalizeCompressedBlocksWithoutProof` function is a reasonable risk mitigation mechanism in case of an emergency, using it diminishes users' trust in the integrity of the updated L2 state.

Consider substantiating that the state transition conducted during `finalizeCompressedBlocksWithoutProof` is a valid state transition. This verification could, for example, be demonstrated off-chain by providing a V1 or V2 proof for the same state transition that can be run on a mainnet fork.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *The fact that the validation of the parent state root was done only when finalizing with a proof was intentional and is consistent with the previous version. We will look to update documentation and transparency around these executions if they occur.*

### Sequencer Censorship Issues

The design of the system exposes multiple points at which the sequencer can apply censorship. While the documentation mentions building towards ["enabling Censorship Resistant Withdrawals"](https://docs.linea.build/decentralization-roadmap#phase-2), the current implementation of the contracts and the sequencer has broader censorship implications than withdrawals (L2→L1 transactions):

#### L1→L2 Messages

While L1 messages sent via `sendMessage` after the migration have to be anchored on L2 for the rollup to finalize and continue processing messages, the L1 contract only validates anchoring and does not ensure that they have been claimed. Consequently, if the sequencer chooses to censor the mandatory L2 `claimMessage` transaction for a message, it may never be included, trapping the users' funds inside the L1 contract.

#### Opaque Censorship Due to Uneconomical Content

Gas costs incurred by L2s for including user transactions typically differ in their pricing structure from those of similar L1 transactions. For instance, L1 calldata is significantly more expensive than L2 execution costs, often dominating transaction inclusion costs. This discrepancy usually necessitates a distinct gas pricing model for users compared to the L1 gas pricing model, whereby L1 calldata costs are explicitly calculated and borne directly by the users.

However, Linea's gas pricing model [mimics L1 gas pricing](https://docs.linea.build/use-mainnet/gas-import) and scales the average gas price by a factor of ~15x, without accounting for factors such as L1 calldata costs. Consequently, users posting large calldata transactions, which are relatively more expensive to include, end up paying much less than their actual share of the costs. This shortfall is partially covered by other users, who subsidize calldata-heavy users through higher payments for execution, and partially by the operators if an aggregate shortfall is realized. Moreover, proving costs are also mispriced, with some opcodes/operations being significantly more expensive to prove than others.

Crucially, due to these limitations, the Linea's sequencer's [undocumented role](https://docs.linea.build/architecture/sequencer#what-does-it-do) involves censoring uneconomical transactions. It is tasked with selectively excluding transactions that are economically unviable, deviating from the transparent gas pricing model presented to its users.

This is in contrast to a typical sequencer's role of ordering transactions and including all the correctly submitted ones. Certain design choices allow a documented possibility of censorship, such as the sequencer's ability to censor both L1→L2 and L2→L1 transactions (without the ability to enforce a transaction inclusion from L1). However, such censorship would be detected and considered malicious. In contrast, censorship related to gas pricing is undocumented and likely to occur in practice if needed (e.g., if prompted by a calldata-heavy surge, such as the numerous instances of [inscriptions-related outages and surges](https://www.dlnews.com/articles/defi/arbitrum-blames-hour-long-outage-on-surge-in-network-traffic/)). Relying on censorship as a design decision contradicts the system's intention to be an L2 inheriting the safety and liveness of L1, as censorship represents a liveness failure.

Consider, in the short term, documenting the expected censorship functionality and its implementation in the sequencer so that expected censorship can be distinguished by third-party observers from malicious censorship. In the long term, consider incorporating transaction inclusion rules into the protocol or revising the gas pricing model.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *The gas pricing model is being revised and a pricing API will be available in the near term. We will add additional documentation explaining how transactions are processed to sustain a working system.*

### Code Quality and Readability Suggestions

Consider implementing the following recommendations to improve the quality and readability of the codebase:

- Avoid using `unchecked` blocks in L2 code as the gas savings are negligible but overflows can be catastrophic. In the current audit, an overflow issue stemmed from an `unchecked` gas optimization on L2. Also, starting from Solidity 0.8.22 (thus specifically for L1 contracts), [there's no need to use `unchecked` increments in loops](https://github.com/ethereum/solidity/releases/tag/v0.8.22). Consider removing all L2 `unchecked` blocks, removing all `unchecked` loop increments blocks for L1 contracts, and documenting the reasoning for the impossibility of overflows/underflows for any remaining `unchecked` blocks.
- Rename [`pauseTypeStatuses`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/lib/PauseManager.sol#L21) to `__DEPRECATED_pauseTypeStatuses`.
- [`OFFSET_CONTAINS_MESSAGE`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageManager.sol#L18) is unused and can be removed.
- Rename [`l2MerkleRoot`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageManager.sol#L22C38-L22C51) to `l2MerkleRootDepths` for clarity.
- Rename [`_shouldProve`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L256C10-L256C22) to [`withProof`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/interfaces/l1/ILineaRollup.sol#L78C10-L78C19) (or vice versa) for consistency.
- Rename [`l1RollingHash`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/interfaces/l1/ILineaRollup.sol#L49C13-L49C26) to `l2RollingHash`.
- Make the `L2MessageServiceV1` contract `abstract` for consistency with [`L1MessageServiceV1`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/v1/L1MessageServiceV1.sol#L16).
- The import of [`IMessageService`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageService.sol#L7) in `L1MessageService.sol` is unnecessary and can be removed.
- The `LineaRollup` contract should call `__ReentrancyGuard_init()` during initialization for completeness.
- The functions [`initialize`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L56-L84) of `L2MessageServiceV1`, [`initialize`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L43-L81) of `LineaRollup`, and [`initializeSystemMigrationBlock`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L89-L91) have `public` visibility and can be made `external` for clarity of the intended external-only usage.
- Refactor the condition flow in `distributeFees` for improved readability. The full fee is always paid to `feeReceiver` unless three conditions are true: `calldata` is empty, `to` is an EOA, and the calculated result is not higher than the total fee. Early returns can replace nested `if` blocks for improved code clarity:

```
 modifier distributeFees(
     ...
  ) {
    uint256 startingGas = gasleft();
    _;
    _sendFees(...); // use internal method to avoid inlining
}

function _sendFees(...) internal {
    if (fee==0) return;

    uint deliveryFee = _calcDeliveryFee(...);
    if (fee > deliveryFee) {
       // send refund
    }

    // send deliveryFee
}

function _calcDeliveryFee(...) internal returns (uint) {
   if (_calldata.length !=0) return fee;

   uint codeSize;
   assembly { codeSize := extcodesize(_to) }
   if (codeSize != 0) return fee;

   uint deliveryFee = ... // calculation

   return deliveryFee > fee ? fee : deliveryFee;
}
```

***Update:** Partially resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). Most of the mentioned points have been addressed, regarding the others the Linea team stated:*

> *1. The `distributeFees` will form part of a later rethink/refactor.* *2. The `__DEPRECATED_pauseTypeStatuses` is not compatible with the OpenZeppelin upgrade plugin/library and we have opted for a @dev comment instead to indicate deprecation.* *3. The one unchecked loop where we do a `i += 2` does not automatically get optimized as per the Solidity docs because we are doing more than just a simple increment in their view.* *4. The `l1Rollinghash` naming remains as it indicates it is L1 related.*

### Insufficient Validation of Parent State Root Hashes When Finalizing Without Proof

When finalizing with a proof, the parent state root hash of the finalization data is [checked](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L199-L201) to be equal to the last finalized state root. Combined with the validation of the shnarf by the circuit, another [submission check](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L145-L147), and a [check](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L292-L294) when finalizing using previously submitted data, this ensures that `LineaRollup.stateRootHashes[currentL2BlockNumber] == SubmissionData.parentStateRootHash == parentSubmissionData.finalStateRootHash == FinalizationData.parentStateRootHash`.

However, three out of these four checks are absent when finalizing without a proof and submitting data at the same time. This could result in finalized data not having as parent state root hash the last finalized state root, an incorrect parent state root hash being emitted in the [`DataFinalized` event](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L351), and the submitted data having a different parent state root hash than the finalization data.

If this check had not been removed intentionally (e.g., to be able to finalize a state transition from a state that is not the latest finalized one), consider moving the [check](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L199-L201) that the parent state root hash of the finalization data matches the last finalized state root hash of the rollup, to the `_finalizeCompressedBlocks` function. Furthermore, consider validating that the submission data and the finalization data have the same parent state root hash when submitting new data during a finalization without proof.

***Update:** Partially resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The mechanism to submit new data during finalization has been removed. The fact that the validation of the parent state root was done only when finalizing with a proof was intentional and is consistent with the previous version.*

### False Sense of Security Due to Validation of Unused Data Fields

There are some data fields that are validated but are not utilized in a manner that adds constraints to the proof. Thus, they essentially only act as duplicated data fields between the submission data and the finalization data.

- The [finalization data's `dataParentHash` field is checked to match a specific value](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L286C37-L286C69), but is not subsequently used in any way that influences the proof. As a result, this value is always set according to this validation check.
- In a similar vein, [`submissionData.parentStateRootHash` undergoes a validation check but is not utilized](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L145C9-L145C44) in the proof or to influence other logic. It will thus also just be set to fulfill the required validation.

The implementation of these checks and data fields leads to some issues:

- They increase the likelihood of errors in code changes and reviews due to the added complexity.
- They foster a false sense of security by giving the impression of thorough validation checks and constraints.

Consider removing these data fields and checks if they are not essential to the rollup and the circuit's operations. Alternatively, if there is an unaddressed purpose for this data, consider integrating it into the proof process.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *Acknowledged. We have adjusted the code to use the dataHashes for more than just continuity checks on `dataParentHash` and have included start and end blocks for the proof. The following two mappings now contain block range data which is validated to be correct before using it in the public input:* *`mapping(bytes32 dataHash => uint256 startingBlock) public dataStartingBlock; mapping(bytes32 dataHash => uint256 endingBlock) public dataEndingBlock;`*  
> *Note: The continuity checks do provide a way to prevent wasting gas on verifying the proof if the data is out of order.*

### Reliance on Application-Level Logic in Chain State Transition Proof

The public input to the proof includes [`finalizationData.l1RollingHash`, `finalizationData.l1RollingHashMessageNumber`, and `finalizationData.l2MerkleRoots`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L219C11-L221C70). This data, relating to the `L2MessageService` contract state on L2, indicates that the proof checks the validity of the state transition by relying on specific application-level data. The Linea team confirmed that the rolling hash and rolling hash message number are utilized to verify that the [last `RollingHashUpdated`](https://github.com/Consensys/linea-contracts-audit/blob/0154676f95a510a855622f8ac9b07816f94edf08/contracts/messageService/l2/L2MessageManager.sol#L122) event was emitted with these values.

However, basing the proof of a chain's state transition on specific events emitted from particular user-space contracts is problematic. It creates brittleness, introduces circular dependencies, and conflates data from different abstraction levels. Here is an analogy to illustrate this issue: envisioning the circuit as an execution client, this approach is akin to hard-coding specific, user-controlled contract addresses and ABIs directly into a client like Geth to execute Ethereum state transitions. Another analogy could be of an operating system's kernel-level logic being implemented in a password-protected user space script. While message passing validity is a crucial part of the L2 system, it is usually implemented at the level of a system-contract or precompile without user space access control controlling upgrades or access to its methods.

Several specific risks arise from this approach:

1. Since the contract is upgradeable, the actual implementation might be altered by a proxy admin on L2, changing the logic governing event emission without updating the verification on L1.
2. Similarly, since the contract is upgradeable, logic errors in contract implementations, such as the overflow issue identified in the audit, are more likely. Such logic errors could undermine the assumptions of the circuits regarding the validity of emitted events.
3. The contract's methods are access-controlled to hot wallets such as `L1_L2_MESSAGE_SETTER_ROLE` holders, and these privileges are granted as part of the application-level logic. Thus, a hot wallet on L2 could potentially influence the validity of the state transition proven on L1 by manipulating these events.

Consider redesigning the validity proof mechanism to ensure that it is independent of specific user space logic whose execution it is validating.

***Update:** Partially resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). Comments were added, notably around the `RollingHashUpdated` event to document its use in the circuit. The Linea team stated:*

> *Acknowledged. We have included a proper state transition from previous finalization's rolling hash and message number to the newly finalized ones in the public input, which will be validated in the circuit. We will resolve the hot wallet concerns when we decentralize and have data consensus before submitting these transactions. Moreover, the state is updated on L2 with the rolling hash and the message number computed at the time which the circuit/prover is responsible for proving.*

### Data Chain Integrity Can Be Broken

When submitting data, checks are made to validate that the first block in the data is [stricly higher than the last finalized one](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L137-L139), and that the parent state root hash [matches with the parent data](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L145-L147). When data is finalized, an additional check is made to validate that the state root hash of the parent [matches with the last finalized one](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L199-L201).

However, these checks do not prevent finalized data from having a data parent which is non-finalized and invalid. Indeed, it is possible to submit data with the final state root being the last finalized state root hash, and the final block number being the last finalized block number. This data can carry invalid compressed data, in which case it can not be finalized, which is expected. However, valid data submitted as a child of it can itself be finalized. Here is an illustration of such a situation:

This makes it possible for finalized data to have a parent carrying invalid compressed data, which is counterintuitive and could be a source of additional issues.

Consider following the design recommendations made in H-01, as this issue would for example naturally be resolved by indexing data by a batch index. Alternatively, consider including the last finalized shnarf in the public input.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *Acknowledged. As this is more a decentralization concern and there is currently one operator, we will do this in the next audit where we will validate that the last finalized shnarf matches that of the data parent.*

### Intermediary Blocks Are Not Validated

When submitting data, checks are made to validate that the first block is [strictly higher than the last finalized one](https://github.com/Consensys/linea-contracts-audit/blob/ffc399a73af535b2fca3de40038056790a36ad2f/contracts/LineaRollup.sol#L162-L164), and [equal to the last block of its data parent plus one](https://github.com/Consensys/linea-contracts-audit/blob/ffc399a73af535b2fca3de40038056790a36ad2f/contracts/LineaRollup.sol#L152-L155). When a sequence of data is finalized, the first and last blocks of the sequence are [included in the public input](https://github.com/Consensys/linea-contracts-audit/blob/ffc399a73af535b2fca3de40038056790a36ad2f/contracts/LineaRollup.sol#L246-L247) and validated by the circuit. Additionally, the first block is again [validated to be equal to the last finalized block plus one](https://github.com/Consensys/linea-contracts-audit/blob/ffc399a73af535b2fca3de40038056790a36ad2f/contracts/LineaRollup.sol#L360-L362).

However, intermediary block numbers in the sequence of data are not validated by the circuit. The `LineaRollup` contract only ensures that they are consecutive, but they are not constrained to match with the `compressedData`. Here is an illustration of this issue where two sequences of data could be finalized, but carry different intermediary block numbers:

This makes it possible for a finalized sequence of data to have a mismatch between the associated compressed data and the block numbers submitted to the `LineaRollup` contract. Depending on how those block numbers are used, this may be a source of issues.

Consider including the first and final block numbers - and more generally any submitted data that is not explicitly part of the public inputs - in the shnarf during submission.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *We will investigate the shnarf and other approaches for an upcoming release to validate that each blob lines up correctly to block numbers which it is said to be for. It is important to note that the state transitions themselves are still valid and uncompressing all the data used in finalization will still yield the correct data from L2 as finalized.*

## Notes & Additional Information

### Typographical Errors

The following typographical errors were identified in the codebase:

- The [NatSpec](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageManager.sol#L52-L56) around `_addL2MerkleRoots` should be plural as there are several Merkle roots taken as arguments
- ["has"](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/v1/L1MessageManagerV1.sol#L72C77-L72C80) should be "have"
- ["achoring"](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/ZkEvmV2.sol#L178C89-L178C97) should be "anchoring"
- ["Thrown current Data was already submitted"](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/interfaces/l1/ILineaRollup.sol#L82) should be "Thrown when the current data was already submitted"
- ["concatonation"](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/interfaces/l1/IZkEvmV2.sol#L15C30-L15C43) should be "concatenation"
- ["compatability"](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L28C43-L28C56) should be "compatibility"
- "Add a cross-chain L1->L2 message hashes in storage" [[1]](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L24) [[2]](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L53) should be "Add cross-chain L1→L2 message hashes in storage"

To improve the overall readability of the codebase, consider correcting the identified errors.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81).*

### Pause Types Should be Cast to `uint8`

The `PauseManager` contract allows pausing a contract with different pause types. These pause types are stored in a [`uint256` variable](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/lib/PauseManager.sol#L23) treated as a bitmap. The bitmap is fetched and updated by using the bit shift operator.

However, while the pause types are of type `uint256`, `pauseTypeStatuses` cannot contain more than 256 bits. In addition, the bit-shifting operation in Solidity does not [overflow](https://docs.soliditylang.org/en/v0.8.20/types.html#shifts). Thus, passing a `_pauseType` argument over 255 by accident would not revert and would instead emit an event for a pause that cannot exist, which could be error-prone and confusing. Besides, the current casting of pause types to `uint256` is unnecessary as `_pauseType` is already a `uint256`.

Consider having `_pauseType` be a `uint8` or safe casting it in the `pauseByType`, `unPauseByType`, and `isPaused` functions. Alternatively, consider removing the unnecessary casting to `uint256`.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81).*

### Refund Failure Using `send` in `distributeFees` Is Not Addressed

On both [L2](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L237) and [L1](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/v1/L1MessageServiceV1.sol#L73), the `send` transaction failure case is not checked. It is unclear whether the intent is to allow failures or not. If failures are allowed, ETH could become stuck in the contract if gas costs are changed and transactions fail. On the other hand, if the intention is to revert, it currently does not revert as it should and `transfer` should be used instead. While it is very unlikely that `send` to an EOA would fail, the `send` failure case should be explicitly addressed or documented.

Consider either using `transfer`, which will revert on failure, or documenting the intent to allow failures.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *This is intentional. The reason is that the refund is set up as an incentive and by forcing the transaction to fail once the relayer/postman has already paid for all the previous opcodes would be a waste of funds. We are looking into reworking the whole mechanism in a future audit along with refactoring the modifier.*

### Arbitrary Calls Can Exploit Accidental Token Approvals

Both L1 and L2 contracts can be made to execute arbitrary calls when claiming a message. As a result, any tokens sent to these contracts, or any token approvals granted to them, can be easily exploited. Despite the fact that users should not grant approvals or send tokens to these contracts, there have been instances where users mistakenly sent significant amounts, such as [10K USDT to the L1 contract, which was subsequently taken](https://etherscan.io/address/0xd19d4B5d358258f05D7B411E21A1460D11B0876F#tokentxns).

Consider implementing a monitoring system for substantial transfers or approvals granted to these contracts. If such transactions are detected, promptly rescue these assets.

***Update:** Resolved. The Linea team stated:*

> *Acknowledged. We have account monitoring and also offer the ability to contact our support to recover funds.*

### Unnecessary `receive` and `fallback` Methods

Multiple `receive` and `fallback` methods are defined in the contracts. In child contracts, these methods [revert with an `EthSendingDisabled` error](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L415-L421) to prevent any ETH from being received. However, the practice of [defining base methods that pass](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageService.sol#L188) and overriding them with methods that revert is confusing, error-prone, and results in unnecessary deployment gas costs. Instead, removing all instances of these methods from the hierarchy would be equally effective in preventing the contract from receiving ETH or executing a `fallback`.

Consider removing all `receive` and `fallback` methods from the contracts.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The `receive` and `fallback` functions were removed.*

### `claimMessage*` Functions Susceptible to Relayer Griefing

The call to the destination in `claimMessage*` functions ([example](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageService.sol#L160)) can conditionally revert or consume an arbitrary amount of gas. Relayers rely on off-chain simulation to estimate the required gas and decide if the fee justifies the transaction, thereby exposing themselves to potential griefing attacks.

In a griefing attack, a large fee could be passed to entice relayers to complete the transaction. The off-chain simulation might suggest non-reversion, but the on-chain transaction could revert due to conditional factors or running out of gas. To bypass off-chain simulation, a destination contract could be designed to consume excessive gas or revert only when called on-chain (e.g., by inspecting `gasleft()`, `tx.gasprice`, `block.coinbase`, `block.gaslimit`, or other state variables that are often set differently during off-chain simulations). The attacker, having control over the destination contract, could then complete the transaction themselves to recover the fee. This vulnerability may limit the third-party relaying mechanism to only EOAs or trusted contracts.

Consider documenting this vulnerability and advising relayer software developers to simulate transactions with the exact transaction and global values that will be used on-chain.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *We are investigating and will produce content based on the investigations.*

### Compiler EVM Version for L2 Contracts Is `paris` Instead of `london`

Compiler configuration in `hardhat.config` specifies the EVM version for L1 contracts' 0.8.22 compiler as [`london`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/hardhat.config.ts#L38-L55), but does not specify it for L2 contracts' 0.8.19. As a result, L2 contracts will be compiled for EVM version `paris` which is the default [version for solc 0.8.18 and 0.8.19](https://github.com/ethereum/solidity/releases/tag/v0.8.18). Hardhat by default [uses the default solc version](https://hardhat.org/hardhat-runner/docs/config#default-evm-version). This is inconsistent with Linea's provided documentation of being on the London EVM version for L2.

Consider specifying the EVM version explicitly for all used compiler versions.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The `london` version of the EVM was set in the Hardhat config. The Linea team stated:*

> *Note that the changes in the `paris` version do not affect the behavior of the contracts on L2 that we have seen.*

### Testing Coverage Issues

It appears that no fork tests are used in the audited repository. Fork tests are of crucial importance in a system such as this owing to the usage of proxies, the need for a migration, and possible compiler configuration compatibility issues.

Some unit test coverage is also missing:

- Usage of `nonReentrant` on `claimMessageWithProof` and `claimMessage` appears to not be tested.
- `RLP.sol` only has 86% branch coverage with several untested execution branches.

Consider maintaining full unit test branch coverage, as well as running fork tests for the migration and automatically running them for any code change.

***Update:** Partially resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). Reentrancy tests on the `claimMessage` and `claimMessageWithProof` functions are present but were overlooked during our review. The Linea team stated:*

> *1. The RLP code will be removed in the upcoming versions and audits as it will no longer be used post migration. In addition, the branches not covered are not used in our code.*  
> *2. We have tested the old versions and new with explicit bytecode and upgrade tests in the repository tests as well as simulations on Tenderly.* *3. There are reentrancy tests that may have been overlooked when reviewing.*

### Gas Optimizations

The following opportunities for gas optimizations were found:

- `claimMessage*` functions should only copy returndata if it is needed for the revert case. Otherwise, they pay for `returdatacopy` (and memory expansion costs) for data that will not be used. An assembly call should be used instead (since a Solidity low level call always copies the full returndata), and `returndatasize` should be checked in the reverting condition to determine if copying is needed.
- In `distributeFees` modifiers, most of the code should be refactored into an internal method called from the modifier to prevent bytecode bloat due to inlining.
- `PauseManager`: `whenTypePaused` and `_requireTypePaused`can be removed since they are not used by the inheriting contracts.
- `GENERAL_PAUSE_TYPE` is always checked with any other specific pause, so it could instead be moved into the internal pause checking logic. This would enable loading the bitmap only once from storage and reduce the contract size (by removing a modifier). The `whenTypeNotPaused` modifier would have to be renamed (e.g., to `whenTypeOrGeneralNotPaused`) to keep the clarity of the current implementation.
- An `L2MessagingBlockAnchored` event is emitted [for each bit of each offset](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageManager.sol#L83-L91), thus potentially emitting many tens of expensive events (each one having an overhead of 750 gas). A very large saving is possible by just emitting the array of offsets.
- Upon a `RollingHashUpdated` event emission, the [`lastAnchoredL1MessageNumber`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L122C31-L122C58) storage variable is read and included in the event. Consider replacing it with `currentL1MessageNumber` to read from memory and save gas.

Consider updating these to save gas during the operation/deployment of the protocol.

***Update:** Partially resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). All the mentioned instances have been updated except for the first, second, and fifth points. The Linea team stated:*

> *The offsets are by design and there is an explicit need for the individual blocks to emit index block numbered events. The claim and `distributeFees` form part of future work.*

### Missing or Misleading Documentation

The following instances were found where the documentation could be made clearer:

- The `claimMessage` function is documented as being ["called automatically by the Postman, dApp, or end user"](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/interfaces/IMessageService.sol#L61C24-L61C37). Consider removing the word "automatically".
- The NatSpec around the [`SubmissionData` struct](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/interfaces/l1/ILineaRollup.sol#L10-L18) would benefit from additional details, notably regarding what `snarkHash` is and what is contained in the `compressedData`.
- The NatSpec around the `SubmissionData` struct incorrectly states that ["compressedData is a hash of the transaction data"](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/interfaces/l1/ILineaRollup.sol#L17).
- `l1RollingHashMessageNumber` is incorrectly documented as being ["the calculated block number on L2"](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/interfaces/l1/ILineaRollup.sol#L37C41-L37C74). Consider explicitly stating that it is a message number and not a block number.
- The NatSpec around [`_l2MessagingBlocksOffsets`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageManager.sol#L75) should explain that it is a sequence of `uint16` representing the L2 blocks numbers which contain L2→L1 messages as offsets from the current block.

Consider updating the above instances to improve the clarity of the codebase.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81).*

### Multiple Instances of Missing Named Parameters in Mappings

Since [Solidity 0.8.18](https://github.com/ethereum/solidity/releases/tag/v0.8.18), developers can utilize named parameters in mappings. This means that mappings can take the form of `mapping(KeyType KeyName? => ValueType ValueName?)`. This updated syntax provides a more transparent representation of a mapping's purpose.

Throughout the codebase, there are multiple mappings which could benefit from having named parameters:

- The [`rollingHashes`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageManager.sol#L20) and [`l2MerkleRoots`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageManager.sol#L22) state variables in the `L1MessageManager` contract
- The [`outboxL1L2MessageStatus`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/v1/L1MessageManagerV1.sol#L21) and [`inboxL2L1MessageStatus`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/v1/L1MessageManagerV1.sol#L25) state variables in the `L1MessageManagerV1` contract
- The [`l1RollingHashes`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/L2MessageManager.sol#L18) state variable in the `L2MessageManager` contract
- The [`inboxL1L2MessageStatus`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageManagerV1.sol#L24) state variable in the `L2MessageManagerV1` contract
- The [`dataFinalStateRootHashes`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L19), [`dataShnarfHashes`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L21), and [`dataParents`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/LineaRollup.sol#L20) state variables in the `LineaRollup` contract
- The [`stateRootHashes`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/ZkEvmV2.sol#L27) and [`verifiers`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/ZkEvmV2.sol#L28) state variables in the `ZkEvmV2` contract

Consider adding named parameters to these mappings to improve the readability and maintainability of the codebase.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81).*

### Lack of Event Emission

Throughout the codebase, some functions could benefit from an added event emission:

- The [`__SystemMigrationBlock_init`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l1/L1MessageService.sol#L74-L80) function could emit an event to indicate the block at which it was migrated.
- The [`setMinimumFee`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L184-L186) function could emit an event to indicate that the fee was changed.
- [`__RateLimiter_init`](https://github.com/Consensys/linea-contracts-audit/blob/bb6eb7284d1ac9574dc69e654abe5ccb8d8ded1a/contracts/messageService/lib/RateLimiter.sol#L35-L47) could emit an event to indicate the initial values set for `periodInSeconds`, `limitInWei`, and `currentPeriodEnd`.

Consider emitting events whenever there are state changes to help off-chain services accurately follow the state of the contracts.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). The mentioned events have been added.*

## Client Reported

### Submission and Finalization Fails for the First Batch of Data Submitted After Migration to the Updated Contract

When submitting the initial batch of compressed block data after the contract update, submission and finalization will fail.

In the `_submitData` function, `_submissionData.dataParentHash` will be empty since it has no parent. Therefore, `parentFinalStateRootHash = dataFinalStateRootHashes[_submissionData.dataParentHash]` will be empty. Hence, the condition `submissionData.parentStateRootHash != parentFinalStateRootHash` will be true, as `submissionData.parentStateRootHash should be _initialStateRootHash`, and `_submitData` will revert with a `StateRootHashInvalid` error.

In `_finalizeCompressedBlocks` , `startingDataParentHash = dataParents[_finalizationData.dataHashes[0]]` will be empty and, therefore, `startingParentFinalStateRootHash = dataFinalStateRootHashes[startingDataParentHash]` will be empty too. The check `_finalizationData.parentStateRootHash == stateRootHashes[currentL2BlockNumber]` requires `_finalizationData.parentStateRootHash == _initialStateRootHash`, which is not empty, so the condition `startingParentFinalStateRootHash != _finalizationData.parentStateRootHash` is true, and we revert with the `FinalStateRootHashDoesNotMatch` error.

**Recommendation**

Set the correct initial value for `dataFinalStateRootHashes` for the initial batch of the compressed block data.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). Some exceptions were added to allow the parent of a submitted data to be empty, in which case finalization will not check the final state root of this empty parent.*

### Prover Can Censor L2 → L1 Messages

In L2→L1 messaging, messages are grouped and added to a Merkle tree by the prover. During finalization, the operator (coordinator) submits the Merkle root to L1 and the user SDK rebuilds the tree to which the message is added and generates a Merkle proof to claim against the root finalized on L1.

However, the prover can skip messages when building the tree. Consequently, the user cannot claim the skipped message, which might result in frozen funds. Currently, the prover is a single entity owned by Linea. Hence, this would require malice or negligence on Linea’s part.

**Recommendation**

Decentralize the prover so that messages can be included by different provers.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *This will be enforced in the circuit and will be the same circuit that all decentralized parties use.*

### Malicious Operator Might Finalize Data From a Forked Linea Chain

A malicious operator (prover) can add and finalize block data from a forked Linea chain. Thus, transactions on the forked chain can be finalized, causing a loss of funds from the L1.

For example, a malicious operator forks the canonical chain after which the attacker sends the forked chain ETH to L1 with `sendMessage` from the forked L2. The operator then submits the block data to L1 and finalizes it with `finalizeCompressedBlocksWithProof`, using the finalization data and proof from the forked chain. (Note that the malicious prover sets the forked chain's `chainId` in its circuit as a constant). The L1 contract (`LineaRollup`) does not know whether the data and the proof are from the canonical L2 or the forked one. The finalization succeeds and the attacker can claim the bridged forked chain ETH and steal funds from L1.

As there is currently only one operator and it is owned by the Linea team, this kind of attack is unlikely to happen. However, when the operator and the coordinator are decentralized, the likelihood of this attack increases.

**Recommendation**

Add `chainId` in the `FinalizationData` as a public input of the verifier function `_verifyProof`. This is so that the proof from the forked Linea chain will not pass the verification because the `chainId` will not match.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *This will be enforced in the circuit and will be the same circuit that all decentralized parties use. `ChainId` is hardcoded in the circuit.*

### The Compressed Block Data Is Not Verified Against Data in the Prover During Data Submission

When the sequencer submits the batched block data with the `submitData` function, it is expected to check that the submitted commitment of the compressed block data `keccak(_submissionData.compressedData)` and the commitment of the block data used in the prover (`snarkHash`) commit to the same data. This is done by proof of equivalence.

The `x` is calculated by hashing `keccak(_submissionData.compressedData)` and `snarkHash` , and `y` is provided by the prover. Then, it is verified that `P(x) = y`, where `P` is a polynomial that encodes the compressed data (`_submissionData.compressedData`). However, in the `submitData` function, `y` is evaluated by `_calculateY` but it is not checked against the `y` provided by the prover. In fact, the prover does not provide `y` to the function. Instead, `x` and `y` are provided to the prover who would evaluate `y'` and compare it with `y` from the contract. Afterwards, `x` and `y` are included in the public input for the proof verification in the finalization.

The only difference is that if the two commitments do not commit to the same block data (meaning the data submitted doesn’t match the data used in the prover), `submitData` would fail. Whereas in the current implementation, it would fail in the proof verification during the finalization. As a result, if the data submitted does not match the data in the prover in the finalization, the operator has to submit the correct data again in order to finalize it. Linea has stated that they will verify it in the data submission once EIP-4844 is implemented.

**Recommendation**

Add the compressed block data verification in the `submitData` function.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *The values will be verified in the proof/verifier and will be addressed with the 4844 changes.*

### Empty Compressed Data Allowed in Data Submission

In `submitData`, the coordinator can submit data with empty `compressedData` in `_submissionData`. However, this is not a desired purpose of this function and may cause undefined system behavior.

**Recommendation**

Add a check to disallow data submission with empty `compressedData`.

***Update:** Resolved at commit [99039eb](https://github.com/Consensys/linea-contracts-audit/tree/99039ebc8d6cb3009cf46286d5de4c484e03bc81). A check was added to revert if the submitted data is empty.*

## Recommendations

### General Recommendations

We recommend the following to the Linea team:

- During the migration, consider waiting for Ethereum's consensus finality of L1 transactions calling the `sendMessage` function around the migration block. Since L1→L2 messages are sent differently depending on the `block.number`, reorgs happening during the migration could be problematic. The operator should query for finalization directly and not simply rely on block delays. This is because Ethereum's finality gadget has had liveness issues in the past.
- Consider finding a way to deprecate the V1 version of the message transmission and finalization functions to reduce the attack surface after the migration.

## Conclusion

The audited codebase is an upgrade of the Linea rollup contracts which lays the groundwork for EIP-4844 by updating the data submission mechanism and improves the existing cross-chain messaging system.

Overall, we found the codebase to be well-written. However, as underlined above, we recommend restructuring the logic of the submission and finalization functions in the `LineaRollup` contract. We also recommend finding a way to deprecate the V1 version of the codebase after the migration to reduce the attack surface. Throughout the audit period, the Linea team provided quick and detailed replies to our questions.
