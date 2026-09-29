# Matterlabs EIP-4844 Support Audit

Source: [https://www.openzeppelin.com/news/eip-4844-support-audit](https://www.openzeppelin.com/news/eip-4844-support-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [PubdataChunkPublisher Contract](#pubdatachunkpublisher-contract)
  - [BlobVersionedHash Contract](#blobversionedhash-contract)
  - [Bootloader Contract](#bootloader-contract)
  - [Executor Contract](#executor-contract)
- [Trust Assumptions](#trust-assumptions)
- [Medium Severity](#medium-severity)
  - [Bootloader Uses Incorrect Value for System Contract Upgrade Log Key](#bootloader-uses-incorrect-value-for-system-contract-upgrade-log-key)
- [Low Severity](#low-severity)
  - [require Statement With Multiple Conditions](#require-statement-with-multiple-conditions)
  - [Missing Tests](#missing-tests)
- [Notes & Additional Information](#notes-additional-information)
  - [Misleading Documentation](#misleading-documentation)
  - [Todo Comments in the Code](#todo-comments-in-the-code)
  - [Lack of Security Contact](#lack-of-security-contact)
  - [Uninitialized Local Variable](#uninitialized-local-variable)
  - [Addresses Are Not Ordered Correctly](#addresses-are-not-ordered-correctly)
  - [Typographical Errors](#typographical-errors)
  - [Unused Code](#unused-code)
  - [Chunks Are Published Before Data Is Validated](#chunks-are-published-before-data-is-validated)
  - [Missing Docstrings](#missing-docstrings)
- [Conclusion](#conclusion)

## Summary

Type
:   Layer 2

Timeline
:   From 2024-01-15
:   To 2024-01-19

Languages
:   Solidity, Yul

Total Issues
:   12 (10 resolved, 2 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   1 (1 resolved)

Low Severity Issues
:   2 (1 resolved, 1 partially resolved)

Notes & Additional Information
:   9 (8 resolved, 1 partially resolved)

## Scope

We audited specific files in the [zk-4844](https://github.com/matter-labs/era-contracts/tree/zk-4844) branch of the [matter-labs/era-contracts](https://github.com/matter-labs/era-contracts) repository, at commit [abcbaf3](https://github.com/matter-labs/era-contracts/tree/abcbaf390a30c09eb53ae83d84bebab95a8003f7). New contracts were audited in full, whereas the rest of the in-scope codebase was audited only for the diffs.

In scope were the following files:

```
 l1-contracts
├── contracts
│   ├── common
│   │   └── L2ContractAddresses.sol
│   └── zksync
│       ├── Config.sol
│       ├── facets
│       │   └── Executor.sol
│       ├── interfaces
│       │   └── IExecutor.sol
│       └── utils
│           └── BlobVersioniedHash.yul
system-contracts
├── Constants.sol
├── L1Messenger.sol
├── PubdataChunkPublisher.sol
├── interfaces
│   └── IPubdataChunkPublisher.sol
└── bootloader
   └── bootloader.yul
```

## System Overview

   

This system upgrade has been executed to support proto-danksharding and the utilization of blob-carrying transactions defined in [EIP-4844](https://eips.ethereum.org/EIPS/eip-4844). With proto-danksharding, the protocol can now make use of cheaper storage for pubdata on L1. This allows for packing more transactions per batch, resulting in cheaper transactions. At a contract level, the protocol now supports processing pubdata via blobs, in addition to supporting the processing of pubdata via calldata. This will also set the stage for future changes aimed at separating pubdata publishing from batch commitment, thereby enabling the handling of different data availability solutions.

The changes in this upgrade span across both L2 system contracts and L1 zkSync contracts, namely `Executor.sol`. Two new contracts were also included to support the additional changes. The `PubdataChunkPublisher` contract was added on the L2 system contracts side, whereas the `BlobVersionedHash` contract was added to the L1 zkSync contracts. The added contracts will be explained in detail below, followed by an outline of changes for the existing contracts.

### `PubdataChunkPublisher` Contract

The new `PubdataChunkPublisher` system contract takes the full pubdata, creates chunks, and commits them in the form of two system logs. The primary purpose of this is to commit to blobs and have those commitments travel to L1 via system logs.

### `BlobVersionedHash` Contract

The EIP-4844 introduces a new opcode called `BLOBHASH`. Since Solidity does not yet natively support calling the `BLOBHASH` opcode, the temporary `BlobVersionedHash.yul` contract had to be added, which acts in place of the eventual `BLOBHASH` opcode. Once support for `BLOBHASH` is added to Solidity, all calls to the `BlobVersionedHash` contract will be substituted for calls to the `BLOBHASH` opcode.

### `Bootloader` Contract

With the increase in the amount of pubdata due to blobs, changes have been made to the bootloader memory to facilitate more L2-to-L1 logs, compressed bytecodes, and pubdata.

### `Executor` Contract

While the function signature for `commitBatches` and the structure of `CommitBatchInfo` stays the same, the format of `CommitBatchInfo::pubdataCommitments` changes. Prior to EIP-4844, this field held a byte array of pubdata. Now, it can either hold the total pubdata as before or a list of concatenated information for KZG blob commitments.

In order to distinguish between the two, a header byte is added to the byte array. This header byte indicates the source of pubdata, with 0 representing calldata and 1 representing blobs. Any other values in the first byte are rejected. The list of supported values for the header byte can be expanded in the future.

## Trust Assumptions

This upgrade does not introduce new roles to the system. The implementation depends on the temporary `BlobVersionedHash.yul` contract serving as a placeholder for the upcoming `BLOBHASH` opcode. It is assumed that once support for the `BLOBHASH` opcode is implemented, calls to the `BlobVersionedHash` contract will be replaced with the utilization of the `BLOBHASH` opcode.

## Medium Severity

### Bootloader Uses Incorrect Value for System Contract Upgrade Log Key

The [`SystemLogKey` enum](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol#L8-L19) is employed by the L2 system contracts to distinguish between logs. As per its definition, the value assigned to [`EXPECTED_SYSTEM_CONTRACT_UPGRADE_TX_HASH_KEY`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol#L18) is `9`. However, in the [`bootloader.yul` file](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/bootloader/bootloader.yul), the [`protocolUpgradeTxHashKey` function](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/bootloader/bootloader.yul#L3657) associated with `EXPECTED_SYSTEM_CONTRACT_UPGRADE_TX_HASH_KEY` returns the value `7`. This inconsistency may lead to unexpected behavior during the processing of L2-to-L1 logs.

Consider changing the return value of the `protocolUpgradeTxHashKey` function to the correct value matching `EXPECTED_SYSTEM_CONTRACT_UPGRADE_TX_HASH_KEY`, which is `9`.

***Update:** Resolved in [pull request #178](https://github.com/matter-labs/era-contracts/pull/178) at commit [88d22b5](https://github.com/matter-labs/era-contracts/commit/88d22b52b50d13cb2b21fa68afc85b3807595e9b).*

## Low Severity

### `require` Statement With Multiple Conditions

In [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol), there is a [`require`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L523-L527) statement that checks multiple conditions to be satisfied.

To simplify the codebase and show the most helpful error messages for failing `require` statements, consider having a single `require` statement per condition.

***Update:** Resolved in [pull request #179](https://github.com/matter-labs/era-contracts/pull/179) at commit [cf63da3](https://github.com/matter-labs/era-contracts/commit/cf63da3b34fd0e0fef36c894e16822168fc21adf).*

### Missing Tests

The proposed changes to the system contracts lack tests that could confirm the correctness of the implementation. For instance, the [`chunkAndPublishPubdata`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/PubdataChunkPublisher.sol#L21-L57) function of the [`PubdataChunkPublisher`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/PubdataChunkPublisher.sol) contract requires additional testing.

Consider adding tests to enhance the quality and health of the codebase.

***Update:** Partially resolved in [pull request #188](https://github.com/matter-labs/era-contracts/pull/188) at commit [43e3ecd](https://github.com/matter-labs/era-contracts/commit/43e3ecdbd888a615c488e7beb18089f6de70549c). The Matter Labs team stated:*

> *We added tests for failure scenarios with relevant revert checks. For success cases, we couldn't check whether the correct system log was published within the test, but have verified it manually.*

## Notes & Additional Information

### Misleading Documentation

Documentation is misleading at some places in the [codebase](https://github.com/matter-labs/era-contracts/tree/abcbaf390a30c09eb53ae83d84bebab95a8003f7/). For instance, the NatSpec [comment](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/bootloader/bootloader.yul#L402) describing [`MAX_MEM_SIZE`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/bootloader/bootloader.yul#L406-L408) suggests that the memory page consists of `24000000 / 32` VM words. However, the value returned is `30000000`.

Consider rephrasing misleading comments to match the intention of the code.

***Update:** Resolved in [pull request #180](https://github.com/matter-labs/era-contracts/pull/180), at commit [84fbcfd](https://github.com/matter-labs/era-contracts/commit/84fbcfde445be46fc8dc3017f94c6afec18f7717).*

### Todo Comments in the Code

During development, having well-described TODO/Fixme comments will make the process of tracking and solving them easier. Without this information, these comments might age and important information for the security of the system might be forgotten by the time the system is released to production. These comments should be tracked in the project's issue backlog and resolved before the system deploys.

Multiplies instances of TODO/Fixme comments were found in the [codebase](https://github.com/matter-labs/era-contracts/tree/zk-4844/):

- The `TODO` comment at [line 44](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L44) of [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol)
- The `TODO` comment at [line 23](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/PubdataChunkPublisher.sol#L23) of [`PubdataChunkPublisher.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/PubdataChunkPublisher.sol)

Consider removing all instances of TODO/Fixme comments and instead tracking them in the issues backlog. Alternatively, consider linking each inline TODO/Fixme comment to the corresponding issues backlog entry.

***Update:** Resolved in [pull request #181](https://github.com/matter-labs/era-contracts/pull/181), at commit [d23d5c3](https://github.com/matter-labs/era-contracts/commit/d23d5c3462053ffcb4f395fe36303306b15e09a5).*

### Lack of Security Contact

Providing a specific security contact (such as an email or ENS name) within a smart contract significantly simplifies the process for individuals to communicate if they identify a vulnerability in the code. This practice is quite beneficial as it permits the code owners to dictate the communication channel for vulnerability disclosure, eliminating the risk of miscommunication or failure to report due to a lack of knowledge on how to do so. In addition, if the contract incorporates third-party libraries and a bug surfaces in those, it becomes easier for the maintainers of those libraries to contact the appropriate person about the problem and provide mitigation instructions. The [`IPubdataChunkPublisher`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/interfaces/IPubdataChunkPublisher.sol) interface does not appear to have a security contact.

Consider adding a NatSpec comment containing a security contact above the contract definitions. Using the `@custom:security-contact` convention is recommended as it has been adopted by the [OpenZeppelin Wizard](https://wizard.openzeppelin.com/) and the [ethereum-lists](https://github.com/ethereum-lists/contracts#tracking-new-deployments).

***Update:** Resolved in [pull request #182](https://github.com/matter-labs/era-contracts/pull/182) at commit [54e982e](https://github.com/matter-labs/era-contracts/pull/182/commits/54e982ecb23e6fd5c1f6461d6c2efa87741c203a).*

### Uninitialized Local Variable

The local variable [`blobVersionedHash`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L531-L532) in [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol) is declared and subsequently initialized with the return value of `_getBlobVersionedHash` function later in the code.

To enhance the overall clarity, intent, and readability of the codebase, consider declaring and initializing the `blobVersionedHash` variable in a single line.

***Update:** Resolved in [pull request #183](https://github.com/matter-labs/era-contracts/pull/183) at commit [0edd4ed](https://github.com/matter-labs/era-contracts/commit/0edd4ed3bc70b7964fa0fbf23212eb6267a01348).*

### Addresses Are Not Ordered Correctly

The constant values of the addresses in the [`L2ContractAddresses`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/common/L2ContractAddresses.sol) contract are not ordered incrementally which is error-prone.

Consider ordering all addresses incrementally.

***Update:** Resolved in [pull request #184](https://github.com/matter-labs/era-contracts/pull/184) at commit [4da7ca8](https://github.com/matter-labs/era-contracts/commit/4da7ca84918f1d39968ed535643edcabeca8c5d5).*

### Typographical Errors

The following typographical errors were identified throughout the [codebase](https://github.com/matter-labs/era-contracts/tree/abcbaf390a30c09eb53ae83d84bebab95a8003f7/):

- Instead of using "`4844`" [[1]](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/Config.sol#L84) [[2]](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/Config.sol#L87) [[3]](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/Constants.sol#L138) [[4]](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/Constants.sol#L139) [[6]](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L188) [[7]](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/utils/BlobVersionedHash.yul#L4) [[8]](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/PubdataChunkPublisher.sol#L14), consider using "`EIP-4844`".
- Instead of ["`EIP 4844`"](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/Config.sol#L87), consider using "`EIP-4844`".
- ["failer"](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/bootloader/bootloader.yul#L690-L691) should be "failure"
- ["doesnt"](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/PubdataChunkPublisher.sol#L27) should be "doesn't"
- ["isnt"](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/PubdataChunkPublisher.sol#L39-L40) should be "isn't"
- ["arent"](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L555) should be "aren't"
- ["blobHah"](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L560) should be "blobHash"

Consider fixing the above errors for improved clarity and readability.

***Update:** Resolved in [pull request #185](https://github.com/matter-labs/era-contracts/pull/185) at commit [e9479f2](https://github.com/matter-labs/era-contracts/commit/e9479f2fb2109f8bc87b72812eaa5d8f7832e0e8).*

### Unused Code

In the [`Executor` contract](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol), the check on [line 189](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L189) implies that the number of `_newBatchesData` is equal to 1. This check makes the following parts of the code irrelevant in subsequent executions:

1. The check on [line 192](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L192) is obsolete because `_newBatchesData.length` is equal to 1 (i.e., greater than 0).
2. Both `for`-loops on lines [216](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L216) and [248](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L248) can be refactored. If the length of the `_newBatchesData` array is known to be 1, there is no value in iterating over it.

Moreover, consider restructuring the [`commitBatches` function](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/facets/Executor.sol#L184-L187) to only accept data from a single new batch instead of a `CommitBatchInfo` array. Furthermore, consider assessing further interdependent functions within the `Executor` contract to accommodate this modification.

***Update:** Partially resolved in [pull request #186](https://github.com/matter-labs/era-contracts/pull/186) at commit [2aeb40a](https://github.com/matter-labs/era-contracts/commit/2aeb40a23e0b5466ec845633a6a09fcf07851f22). The Matter Labs team stated:*

> *We chose to remove the require on length being greater than 0 as the only change. Supporting 1 batch per commitment is a temporary change so leaving the code minimizes unnecessary work.*

### Chunks Are Published Before Data Is Validated

The [`publishPubdataAndClearState`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol#L193-L332) function of [`L1Messenger`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol) contract [calls the pubdata chunk publisher contract](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol#L313) in order to chunk and publish data. The issue lies in the fact that the call occurs before the [check](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol#L316) that ensures that the calldata does not contain extra data.

Consider swapping the checks to ensure that the data is in the correct format before calling the pubdata chunk publisher contract.

***Update:** Resolved in [pull request #187](https://github.com/matter-labs/era-contracts/pull/187) at commit [c53456f](https://github.com/matter-labs/era-contracts/commit/c53456fb38fa107972de4b51e363b34dd214988c).*

### Missing Docstrings

Throughout the [codebase](https://github.com/matter-labs/era-contracts/tree/abcbaf390a30c09eb53ae83d84bebab95a8003f7/), there are several parts that have an incomplete docstring:

- The [`IPubdataChunkPublisher` interface](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/interfaces/IPubdataChunkPublisher.sol#L4) is missing docstrings.
- The [`BlockCommit` event](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol#L159) in [`IExecutor.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol) is missing docstrings for the `batchNumber`, `batchHash`, and `commitment` parameters.
- The [`BlocksVerification` event](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol#L163) in [`IExecutor.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol) is missing docstrings for the `previousLastVerifiedBatch` and `currentLastVerifiedBatch` parameters.
- The [`BlockExecution` event](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol#L167) in [`IExecutor.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol) is missing docstrings for `batchNumber`, `batchHash`, and `commitment` parameters.
- The [`BlocksRevert` event](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol#L171) in [`IExecutor.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/l1-contracts/contracts/zksync/interfaces/IExecutor.sol) is missing documentation for the `totalBatchesCommitted`, `totalBatchesVerified`, and `totalBatchesExecuted` parameters.
- The [`sendL2ToL1Log` function](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol#L67-L88) in [`L1Messenger.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol) is missing docstrings for the `_isService`, `_key` and `_value` parameters.
- The [`sendToL1` function](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol#L112-L156) in [`L1Messenger.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol) is missing docstrings for the `_message` parameter.
- The [`requestBytecodeL1Publication` function](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol#L159-L181) in [`L1Messenger.sol`](https://github.com/matter-labs/era-contracts/blob/abcbaf390a30c09eb53ae83d84bebab95a8003f7/system-contracts/contracts/L1Messenger.sol) is missing docstrings for the `_bytecodeHash` parameter.

Consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not `public`, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #189](https://github.com/matter-labs/era-contracts/pull/189) at commit [f244ede](https://github.com/matter-labs/era-contracts/pull/189/commits/f244ede599ccdac2160b27061d586041b9c45e77).*

## Conclusion

The system upgrade introduces proto-danksharding and implements blob-carrying transactions as per EIP-4844, resulting in cheaper transactions on L1. The upgrade affects L2 system contracts, such as the addition of `PubdataChunkPublisher` for committing pubdata to blobs and `BlobVersionedHash` for handling the new `BLOBHASH` opcode. The `Bootloader` contract is adjusted to accommodate increased pubdata, while the `Executor` contract undergoes changes in the format of pubdata commitments to support both calldata and blob commitments, distinguished by a header byte. The added contracts and modifications set the foundation for future data availability solutions.

The audit uncovered one issue of medium severity in addition to several other issues of low severity. Various recommendations have also been made to enhance the quality and documentation of the codebase. We found the dedicated documentation provided by Matter Labs team to be very helpful in understanding the audited code changes. Throughout the audit period, the Matter Labs team was very supportive and answered all questions we had in a timely manner.
