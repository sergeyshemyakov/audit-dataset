# November Diff Audit

Source: [https://www.openzeppelin.com/news/november-diff-audit](https://www.openzeppelin.com/news/november-diff-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
- [Low Severity](#low-severity)
  - [Missing Docstrings](#missing-docstrings)
  - [The getFirstUnprocessedPriorityTx Function Does Not Revert When There Are No Unprocessed Transactions](#the-getfirstunprocessedprioritytx-function-does-not-revert-when-there-are-no-unprocessed-transactions)
  - [The Refund Recipient Might Be Aliased to an Unexpected Address](#the-refund-recipient-might-be-aliased-to-an-unexpected-address)
- [Notes & Additional Information](#notes-additional-information)
  - [Todo Comments in the Code](#todo-comments-in-the-code)
  - [Inconsistent Use of Named Returns](#inconsistent-use-of-named-returns)
  - [Non-Explicit Imports Are Used](#non-explicit-imports-are-used)
  - [Unused Function With Internal Visibility](#unused-function-with-internal-visibility)
  - [Typographical Errors](#typographical-errors)
  - [The isFacetFreezable function Returns Value for Non-Existent Facets](#the-isfacetfreezable-function-returns-value-for-non-existent-facets)
  - [Lack of Consistency in Error Messages](#lack-of-consistency-in-error-messages)
  - [Lack of Security Contact](#lack-of-security-contact)
  - [Unused Imports](#unused-imports)
  - [Incorrect or Misleading Docstrings](#incorrect-or-misleading-docstrings)
  - [Inconsistent Use of override Keyword](#inconsistent-use-of-override-keyword)
- [Conclusion](#conclusion)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-11-27
:   To 2023-12-05

Languages
:   Solidity, Yul

Total Issues
:   14 (9 resolved, 1 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   0 (0 resolved)

Low Severity Issues
:   3 (2 resolved)

Notes & Additional Information
:   11 (7 resolved, 1 partially resolved)

## Scope

Most of the contracts in scope have been audited at a past commit. In addition, the Matter Labs codebase has moved from private to public repositories. For this reason, we audited code from 4 different repositories and between several commits.

Specifically, we audited select files from the [`era-system-contracts`](https://github.com/matter-labs/era-system-contracts) repository, in the [`v1.4.1-integration`](https://github.com/matter-labs/era-system-contracts/tree/v1-4-1-integration) branch, at commit [`ef0eb0c`](https://github.com/matter-labs/era-system-contracts/commit/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c), and from the [`era-contracts`](https://github.com/matter-labs/era-contracts) repository, in the [`v1.4.1-integration`](https://github.com/matter-labs/era-contracts/tree/v1-4-1-integration) branch, at commit [`518bfff`](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8).

The exact scope is as follows:

| **Last Audit Repo** | **New Repo** | **File** | **last audit commit** | **audited commit** |
| --- | --- | --- | --- | --- |
| system-contracts | era-system-contracts | /contracts/Compressor.sol | [4dca36d](https://github.com/matter-labs/system-contracts/tree/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2) | [ef0eb0c](https://github.com/matter-labs/era-system-contracts/commit/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c) |
| system-contracts | era-system-contracts | /bootloader/bootloader.yul | [4dca36d](https://github.com/matter-labs/system-contracts/tree/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2) | [ef0eb0c](https://github.com/matter-labs/era-system-contracts/commit/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c) |
| system-contracts | era-system-contracts | /contracts/L1Messenger.sol | [4dca36d](https://github.com/matter-labs/system-contracts/tree/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2) | [ef0eb0c](https://github.com/matter-labs/era-system-contracts/commit/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c) |
| system-contracts | era-system-contracts | /contracts/interfaces/IMailbox.sol | N/A | [ef0eb0c](https://github.com/matter-labs/era-system-contracts/commit/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/facets/Mailbox.sol | [098bc7e](https://github.com/matter-labs/zksync-2-contracts/tree/098bc7ee2d13f78d365c386a8d27c1ae09b31164) | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/facets/Getters.sol | [0ea93984](https://github.com/matter-labs/zksync-2-contracts/tree/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts) | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/facets/Executor.sol | [098bc7e](https://github.com/matter-labs/zksync-2-contracts/tree/098bc7ee2d13f78d365c386a8d27c1ae09b31164) | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/facets/Base.sol | N/A | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/facets/Admin.sol | N/A | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/libraries/TransactionValidator.sol | N/A | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/interfaces/IExecutor.sol | [098bc7e](https://github.com/matter-labs/zksync-2-contracts/tree/098bc7ee2d13f78d365c386a8d27c1ae09b31164) | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/interfaces/IGetters.sol | [3f345ce](https://github.com/matter-labs/zksync-2-contracts/tree/3f345ce52bc378c4b5d710c80d817db170775049) | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/interfaces/IMailbox.sol | [3f345ce](https://github.com/matter-labs/zksync-2-contracts/tree/3f345ce52bc378c4b5d710c80d817db170775049) | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/interfaces/IZkSync.sol | N/A | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/interfaces/IAdmin.sol | N/A | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/interfaces/ILegacyGetters.sol | N/A | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |
| zksync-2-contracts | era-contracts | /ethereum/contracts/zksync/interfaces/IVerifier.sol | N/A | [518bfff](https://github.com/matter-labs/era-contracts/commit/518bfff51085743dc85d2824d823aaf4bb3e82d8) |

## System Overview

No major system changes were included in this audit's scope. Most of the contracts have been inspected for code diffs compared to a previously audited version. The changes include fixes from past audits and some issues reported during the Code4rena contest. Also, note that the private [`zksync-2-contracts`](https://github.com/matter-labs/zksync-2-contracts) repository has been moved to the public [`era-contracts`](https://github.com/matter-labs/era-contracts) repository, while the private [`system-contracts`](https://github.com/matter-labs/system-contracts) repository has been moved to the public [`era-system-contracts`](https://github.com/matter-labs/era-system-contracts) repository.

The most notable changes, per contract, are as follows:

- `zksync-2-contracts`/`era-contracts`:
  - `Mailbox.sol`: Fixed wording issues, removed user access restrictions and deposit limit, and introduced formatting changes.
  - `Executor.sol`: Fixed wording issues, introduced extra sanity checks on the L2 batch and block timestamp (which are now included within each batch), moved batch proof verification code to the verifier contract, and made formatting changes.
  - `Getters.sol`: Made formatting changes, performed code organization, and removed dead code.

The `Base.sol`, `Admin.sol` and `TransactionValidator.sol` contracts were audited as a whole.

- `system-contracts`/`era-system-contracts`:
  - `Compressor.sol`: Implemented a new format for the state diffs compression encoding and enhanced the verification of data compression correctness.
  - `bootloader.yul`: Made formatting and code organization changes, added additional temporary code needed for the keccak256 precompile upgrade procedure, implemented more sanity checks, and introduced extra functionality to publish L2 batch and block timestamp data to L1.
  - `L1Messenger.sol`: Updated state diffs verification to follow the new compression format and made gas charges more accurate.

## Security Model and Trust Assumptions

No further trust assumptions were introduced in the audited contracts. The `allowList` has been removed from the `Mailbox` contract, allowing any user to request an L2 transaction.

## Low Severity

### Missing Docstrings

Throughout the [codebase](https://github.com/matter-labs/era-contracts/tree/518bfff51085743dc85d2824d823aaf4bb3e82d8/), there are several parts that do not have docstrings:

- The [`Admin.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Admin.sol#L14), [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol#L21), [`Getters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol#L19), and [`Mailbox.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L27) contracts are missing docstrings for the `getName` constant.
- The [`IAdmin.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IAdmin.sol), [`IExecutor.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IExecutor.sol), [`IGetters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IGetters.sol), [`ILegacyGetters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/ILegacyGetters.sol), [`IMailbox.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IMailbox.sol), [`IVerifier.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IVerifier.sol), and [`IZkSync.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IZkSync.sol) interfaces are missing docstrings for multiple function declarations.

Consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #127](https://github.com/matter-labs/era-contracts/pull/127) at commit [d4bd820](https://github.com/matter-labs/era-contracts/pull/127/commits/d4bd820cae13b43fd04869226055fdff5c9ea8e5).*

### The `getFirstUnprocessedPriorityTx` Function Does Not Revert When There Are No Unprocessed Transactions

The [`getFirstUnprocessedPriorityTx`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol#L63-L65) function of the `Getters` contract is expected to return the first unprocessed priority transaction. In case there are no unprocessed priority transactions, the function should revert, as indicated in the [NatSpec comment](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol#L61) comment. The issue is that the function uses the `PriorityQueue` library, which simply returns [the head of the queue](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/libraries/PriorityQueue.sol#L35-L37) and does not revert when there are no unprocessed priority transactions.

Consider reverting when there are no unprocessed priority transactions.

***Update:** Resolved in [pull request #137](https://github.com/matter-labs/era-contracts/pull/137) at commit [ff8a9cd](https://github.com/matter-labs/era-contracts/pull/137/commits/ff8a9cd30112d484684a9b45e3a6f526e0c2b732). The Matter Labs team stated:*

> *We decide to keep the current behavior for the simplicity of the function. However, it does make sense to update the comment.*

### The Refund Recipient Might Be Aliased to an Unexpected Address

The [`Mailbox`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol) contract implements the [`requestL2Transaction`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L222-L256) function that allows communication from L1 to L2. It allows to specify a [`_refundRecipient`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L229) address on L2 that will receive the refund after the transaction's completion. The function handles the following scenarios:

- if `_refundRecipient` is a contract on L1, the refund will be sent to the aliased `_refundRecipient`.
- If `_refundRecipient` is set to `address(0)` and the sender has not deployed bytecode on L1, the refund will be sent to the `msg.sender` address.
- If `_refundRecipient` is set to `address(0)` and the sender has deployed bytecode on L1, the refund will be sent to the aliased `msg.sender` address.

The internally triggered `_requestL2Transaction` function [checks if `refundRecipient` is a contract](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L287-L289) by comparing its code size with `0` and [applying L1 to L2 alias](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L288) only in case it is a contract. In addition, at the beginning of the function, [`msg.sender` address is aliased](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L234-L235) in case it is a contract. This means that in case the sender is a smart contract and `_refundRecipient` is set to `address(0)`, the address aliasing will be applied twice on `msg.sender`.

Consider fixing the code so that the address aliasing is applied exactly once when needed. Even if the aliased addresses are not currently immediately used for claiming refunds, the current implementation returns unexpected results and could lead to serious bugs in future upgrades.

***Update:** Acknowledged, not resolved. We concluded that the problematic scenario is probabilistically impossible, so the issue is dismissed. The Matter Labs team stated:*

> *In case the sender is a smart contract and the recipient is `address(0)`, [then](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L235) we apply the alias to the sender. Additionally, in case the the `refundRecipient` is `address(0)`, [then](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L285) the refund recipient would become equal to the aliased sender. Note that we will never get into [the next `if`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L287) since the aliased sender can not contain any code because of collision resistance.*

## Notes & Additional Information

### Todo Comments in the Code

During development, having well-described TODO/Fixme comments will make the process of tracking and solving them easier. Without such information, these comments might age and important information for the security of the system might be forgotten by the time it is released to production. These comments should be tracked in the project's issue backlog and resolved before the system deployment.

The identified instance of TODO/Fixme comments:

- The `TODO` comment on [line 151](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/libraries/TransactionValidator.sol#L151) in [`TransactionValidator.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/libraries/TransactionValidator.sol).

Consider removing all instances of TODO/Fixme comments and instead tracking them in the issues backlog. Alternatively, consider linking each inline TODO/Fixme comment to the corresponding issues backlog entry.

***Update:** Acknowledged, will resolve. The Matter Labs team stated:*

> *This comment will be resolved in the future release.*

### Inconsistent Use of Named Returns

Throughout the [codebase](https://github.com/matter-labs/era-contracts/tree/518bfff51085743dc85d2824d823aaf4bb3e82d8/), there are multiple contracts that have inconsistent usage of named returns in their functions:

- In [`ExecutorFacet` contract](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol#L17-L485) of [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol)
- In [`GettersFacet` contract](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol#L15-L242) of [`Getters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol)
- In [`MailboxFacet` contract](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L23-L400) of [`Mailbox.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol)
- In [`IGetters` interface](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IGetters.sol#L9-L81) of [`IGetters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IGetters.sol)
- In [`IMailbox` interface](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IMailbox.sol#L16-L155) of [`IMailbox`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IMailbox.sol)

To improve the readability and consistency of a contract, use the same return style in all of its functions. As such, consider naming the return variables of all functions.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *Especially for smaller functions, always using named returned variables will unnecessarily increase the amount of code so it is better to keep things as they are for readability.*

### Non-Explicit Imports Are Used

The use of non-explicit imports in the codebase can decrease the clarity of the code, and may create naming conflicts between locally defined and imported variables. This is particularly relevant when multiple contracts exist within the same Solidity files or when inheritance chains are long.

Throughout the [codebase](https://github.com/matter-labs/era-contracts/tree/518bfff51085743dc85d2824d823aaf4bb3e82d8/), global imports are being used:

- [Lines 5-6](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Admin.sol#L5-L6) and [line 8](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Admin.sol#L8) in [`Admin.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Admin.sol).
- [Lines 5-6](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Base.sol#L5-L6) in [`Base.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Base.sol)
- [Lines 5-10](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol#L5-L10) in [`Getters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol).
- [Line 5](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IAdmin.sol#L5) in [`IAdmin.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IAdmin.sol)
- [Line 5](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IGetters.sol#L5) and [line 7](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IGetters.sol#L7) in [`IGetters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IGetters.sol)
- [Line 5](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/ILegacyGetters.sol#L5) in [`ILegacyGetters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/ILegacyGetters.sol)
- [Line 6](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IMailbox.sol#L6) in [`IMailbox.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IMailbox.sol)
- [Lines 5-8](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IZkSync.sol#L5-L8) in [`IZkSync.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IZkSync.sol)
- [Lines 5-8](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/libraries/TransactionValidator.sol#L5-L8) in [`TransactionValidator.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/libraries/TransactionValidator.sol)

Following the principle that clearer code is better code, consider using named import syntax *(`import {A, B, C} from "X"`)* to explicitly declare which contracts are being imported.

***Update:** Resolved in [pull request #126](https://github.com/matter-labs/era-contracts/pull/126) at commit [5ae779e](https://github.com/matter-labs/era-contracts/pull/126/commits/5ae779e4353355c4af99ad055da17dd90606ca5c). The Matter Labs team stated:*

> *This PR additionally creates some new implicit imports in other files, but those will be fixed in subsequent PRs (i.e. those files are in scope of other audits).*

### Unused Function With Internal Visibility

The [`_maxU256`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol#L419-L421) internal function of [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol) contract is not used.

To improve the overall clarity, intentionality, and readability of the codebase, consider using or removing any currently unused functions.

***Update:** Resolved in [pull request #125](https://github.com/matter-labs/era-contracts/pull/125) at commit [7e24b66](https://github.com/matter-labs/era-contracts/pull/125/commits/7e24b66df3acf743064502912ffe9dc51b8aabab).*

### Typographical Errors

The following typographical errors were identified in the codebase:

- The comment in [`TransactionValidator.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/libraries/TransactionValidator.sol#L87) should be `dependencies` not `dependenies`.
- The comment in [`TransactionValidator.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/libraries/TransactionValidator.sol#L96) should be `auxiliary` not `auxilary`.
- The comment in [`TransactionValidator.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/libraries/TransactionValidator.sol#L99) should be `dependencies` not `dependenies`.
- The comment in [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol#L235) should be `noticeable` not `noticable`.
- The comment in [`Bootloader.yul`](https://github.com/matter-labs/era-system-contracts/blob/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c/bootloader/bootloader.yul#L68) should be `maintenance` not `maintainance`.
- The comment in [`Bootloader.yul`](https://github.com/matter-labs/era-system-contracts/blob/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c/bootloader/bootloader.yul#L111) should be `Scratch` not `Scatch`
- The comment in [`Bootloader.yul`](https://github.com/matter-labs/era-system-contracts/blob/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c/bootloader/bootloader.yul#L346) should be `accommodate` not `accomodate`
- The comment in [`Bootloader.yul`](https://github.com/matter-labs/era-system-contracts/blob/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c/bootloader/bootloader.yul#L2767) should be `trigger` not `triger`
- The comment in [`Bootloader.yul`](https://github.com/matter-labs/era-system-contracts/blob/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c/bootloader/bootloader.yul#L3884) should be `Transferring` not `Transfering`
- The comment in [`Bootloader.yul`](https://github.com/matter-labs/era-system-contracts/blob/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c/bootloader/bootloader.yul#L3897) should be `exhausted` not `exhaused`
- The comment in [`ILegacyGetters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/ILegacyGetters.sol#L9) should be `kept` not `keot`.
- The comment in [`Getters.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol#L12) should be `blockchain` not `batchchain`.

Consider fixing the aforementioned typographical errors to improve the readability and clarity of the codebase.

***Update:** Resolved in [pull request #120](https://github.com/matter-labs/era-contracts/pull/120) at commit [fdd9006](https://github.com/matter-labs/era-contracts/pull/120/commits/fdd90063a3c41303292cee24b44b307314d41b15) and [pull request #91](https://github.com/matter-labs/era-system-contracts/pull/91) at commit [cf955cc](https://github.com/matter-labs/era-system-contracts/pull/91/commits/cf955cc4106bc135b541a24a49fc214c1c75645e).*

### The `isFacetFreezable` function Returns Value for Non-Existent Facets

The [`isFacetFreezable`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Getters.sol#L134-L145) function of the `Getters` contract returns a boolean value (`true` or `false`) depending on whether the given facet is freezable or not. However, the current implementation logic defaults to returning false even for non-existent facets.

Instead of returning false, consider reverting in case the facet does not exist.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *The current interface subjectively looks easier to use and maintain. Besides, the function is generally rarely used. If someone is not sure whether a facet is a valid one, they could also request the `facetFunctionSelectors()` function.*

### Lack of Consistency in Error Messages

The [`Base`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Base.sol) contract, inherited by the facets, implements modifiers to handle access control for specific functions. The error messages in the `require` statements use codes, but for the [`onlyGovernorOrAdmin`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Base.sol#L20-L24) modifier, the [full error message](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Base.sol#L22) is used.

For the sake of clarity and consistency, consider using the error code for validation in the `onlyGovernorOrAdmin` modifier.

***Update:** Resolved in [pull request #121](https://github.com/matter-labs/era-contracts/pull/121) at commit [4051533](https://github.com/matter-labs/era-contracts/pull/121/commits/4051533bc4a1c16dc5c0553b432dbbf080867430).*

### Lack of Security Contact

Providing a specific security contact (such as an email or ENS name) within a smart contract significantly simplifies the process for individuals to communicate if they identify a vulnerability in the code. This practice proves beneficial as it permits the code owners to dictate the communication channel for vulnerability disclosure, eliminating the risk of miscommunication or failure to report due to a lack of knowledge on how to do so. Additionally, if the contract incorporates third-party libraries and a bug surfaces in them, it becomes easier for the maintainers of those libraries to make contact with the appropriate person about the problem and provide mitigation instructions.

Throughout the [codebase](https://github.com/matter-labs/era-contracts/tree/518bfff51085743dc85d2824d823aaf4bb3e82d8/), there are contracts that do not have a security contact:

- The [`IAdmin`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IAdmin.sol) contract
- The [`IExecutor`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IExecutor.sol) contract
- The [`IGetters`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IGetters.sol) contract
- The [`ILegacyGetters`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/ILegacyGetters.sol) contract
- The [`IMailbox`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IMailbox.sol) contract
- The [`IVerifier`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IVerifier.sol) contract
- The [`IZkSync`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/interfaces/IZkSync.sol) contract

Consider adding a NatSpec comment containing a security contact above the contract definition. Using the `@custom:security-contact` convention is recommended as it has been adopted by the [OpenZeppelin Wizard](https://wizard.openzeppelin.com/) and the [ethereum-lists](https://github.com/ethereum-lists/contracts#tracking-new-deployments).

***Update:** Resolved in [pull request #122](https://github.com/matter-labs/era-contracts/pull/122) at commit [c969649](https://github.com/matter-labs/era-contracts/pull/122/commits/c96964903fb8685540e7abec5580f5198ec83aad).*

### Unused Imports

The following unused imports were identified throughout the codebase:

- In [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol), the constants [`MAX_INITIAL_STORAGE_CHANGES_COMMITMENT_BYTES` and `MAX_REPEATED_STORAGE_CHANGES_COMMITMENT_BYTES`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol#L6C125-L6C216) imported from `Config.sol` are unused.
- In [`Executor.sol`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol), the constant [`L2_KNOWN_CODE_STORAGE_SYSTEM_CONTRACT_ADDR`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol#L12C113-L12C155) imported from `L2ContractAddresses.sol` is unused.

Consider removing unused imports to improve the overall clarity and readability of the codebase.

***Update:** Resolved in [pull request #123](https://github.com/matter-labs/era-contracts/pull/123) at commit [3f2f947](https://github.com/matter-labs/era-contracts/pull/123/commits/3f2f9478ba2bed7758e25b24cfb8e257de269885).*

### Incorrect or Misleading Docstrings

The following instances of incorrect or misleading docstrings were identified throughout the codebase:

- In the `publishPubdataAndClearState` function of the [`L1Messenger`](https://github.com/matter-labs/era-system-contracts/blob/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c/contracts/L1Messenger.sol) contract, [the docstring](https://github.com/matter-labs/era-system-contracts/blob/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c/contracts/L1Messenger.sol#L275) explaining the expected encoding of the state diffs in the `_totalL2ToL1PubdataAndStateDiffs` parameter is partially incorrect. The docstring describes the encoding as:

```
 header (1 byte version, 3 bytes total len of compressed, 1 byte enumeration index size, 2 bytes number of initial writes)
body (N bytes of initial writes [32 byte derived key || compressed value], M bytes repeated writes [enumeration index || compressed value])
```

whereas, in fact, it is:

```
 header (1 byte version, 3 bytes total len of compressed, 1 byte enumeration index size)
body (`compressedStateDiffSize` bytes,  4 bytes number of state diffs, `numberOfStateDiffs` * `STATE_DIFF_ENTRY_SIZE` the state diffs)
```

- At [Line 81](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L81) of [Mailbox.sol](https://github.com/matter-labs/era-contracts/blob/v1-4-1-integration/ethereum/contracts/zksync/facets/Mailbox.sol), `key` is documented as being the hash of `L1ToL2Transaction` whereas it is the hash of the L2 transaction.

Consider fixing all instances of incorrect or misleading documentation to enhance the overall clarity and readability of the codebase.

***Update:** Partially resolved in [pull request #92](https://github.com/matter-labs/era-system-contracts/pull/92) at commit [66481dd](https://github.com/matter-labs/era-system-contracts/pull/92/commits/66481ddc07d34da3a94fba85520bde5f8efa0540). The Matter Labs team stated:*

> *The first issue is acknowledged, but the second one is disagreed with, since this function is intended to be used specifically for L1->L2 transaction and not just any L2 transaction.*

### Inconsistent Use of `override` Keyword

Throughout the codebase, several functions have the `override` keyword in their signature as they are being implemented from an interface. However, in the most current versions of the Solidity compiler, the `override` keyword is not necessary for interface implementation.

Specifically:

- The [`commitBatches`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Executor.sol#L179) function of the `Executor` contract
- The [`proveL1ToL2TransactionStatus`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L68) and [`finalizeEthWithdrawal`](https://github.com/matter-labs/era-contracts/blob/518bfff51085743dc85d2824d823aaf4bb3e82d8/ethereum/contracts/zksync/facets/Mailbox.sol#L178) functions of the `Mailbox` contract

Consider removing the redundant `override` keywords to simplify and be consistent with the rest of the codebase.

***Update:** Resolved in [pull request #124](https://github.com/matter-labs/era-contracts/pull/124) at commit [03c579f](https://github.com/matter-labs/era-contracts/pull/124/commits/03c579ff99d22bc5054883ae0f9e758a587070d5).*

## Conclusion

The audit scope did not include any major system changes. Most of the contracts have been audited for code diffs compared to a previously audited version. The changes include fixes from past audits and some issues reported during the Code4rena bug bounty contest.

Only a few low-severity issues were reported during the audit. In addition, several fixes were recommended to improve the readability of the codebase, and facilitate future audits and development for additional functionality. The Matter Labs team has been responsive and eager to provide additional insights and documentation whenever asked.
