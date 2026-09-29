# zkSync L2 Block Refactor Audit

Source: [https://www.openzeppelin.com/news/zksync-l2-block-refactor-audit](https://www.openzeppelin.com/news/zksync-l2-block-refactor-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Trust Assumptions](#trust-assumptions)
- [Medium Severity](#medium-severity)
  - [Constant Block Difficulty Breaks EVM Equivalence](#constant-block-difficulty-breaks-evm-equivalence)
- [Low Severity](#low-severity)
  - [Misleading Documentation](#misleading-documentation)
  - [Missing Docstrings](#missing-docstrings)
  - [Missing Error Message in require Statement](#missing-error-message-in-require-statement)
  - [Misleading Variable Naming](#misleading-variable-naming)
- [Notes & Additional Information](#notes-additional-information)
  - [Non-Explicit Imports Are Used](#non-explicit-imports-are-used)
  - [Typographical Errors](#typographical-errors)
  - [Gas Optimizations](#gas-optimizations)
- [Recommendations](#recommendations)
  - [Usage of Block Number and Difficulty](#usage-of-block-number-and-difficulty)
- [Conclusions](#conclusions)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-07-25
:   To 2023-07-31

Languages
:   Solidity, Yul

Total Issues
:   8 (7 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   1 (0 resolved)

Low Severity Issues
:   4 (4 resolved)

Notes & Additional Information
:   3 (3 resolved)

Client Reported Issues
:   0 (0 resolved)

## Scope

We audited the `matter-labs/system-contracts` repository for [pull request #285](https://github.com/matter-labs/system-contracts/pull/285/) at commit [44c4f98](https://github.com/matter-labs/system-contracts/pull/285/files/44c4f989a305c0f1511e6ebf83da08adb8979325). The following files were in scope:

```
 ├── bootloader
│   └── bootloader.yul
└── contracts
    ├── ContractDeployer.sol
    ├── SystemContext.sol
    └── interfaces
        ├── ISystemContext.sol
        └── ISystemContextDeprecated.sol
```

Additionally, we audited the `matter-labs/zksync-2-contracts` repository for [pull request #169](https://github.com/matter-labs/zksync-2-contracts/pull/169/) at commit [661a11c](https://github.com/matter-labs/zksync-2-contracts/pull/169/files/661a11ca86e56fa6f7e237511fb5adfe456aa00b). The following file was in scope:

```
 ethereum
└── contracts
    └── zksync
        └── facets
            └── Executor.sol
```

## System Overview

The system upgrade introduces changes to provide more accurate and efficient information about L2 blocks for faster soft confirmations on wallets and block explorers. The naming conventions have been revised, distinguishing between batches (now referred to as "batch" as opposed to "block") and individual L2 blocks, which are now denoted as "L2 blocks". The compiler functions `getBlockNumber`, `getBlockTimestamp`, and `getBlockHashEVM` have been adapted to return values specific to L2 blocks.

To process and ensure consistency within L2 blocks, the system implements the `setL2Block` method before each transaction to provide data about the L2 block to which the transaction belongs. The hash of an L2 block is derived based on its properties, including block number, timestamp, previous L2 block hash, and transaction rolling hash. Timing invariants are maintained to ensure that each L2 block's timestamp is greater than the previous L2 block's timestamp and the timestamp of the batch it belongs to. Additionally, batches must start with a new L2 block, and the timestamp of the last miniblock in a batch must not be too far into the future. The system also accommodates an empty, fictive L2 block at the end of each batch to allow for technical requirements within the node. These upgrades aim to improve the user experience and provide more accurate and timely information for L2 block confirmations.

## Trust Assumptions

This upgrade does not introduce new roles to the system. As before, the operator role is in control of the batches, in addition to controlling the block frequency within them. Currently, the operator will be centralized through Matter Labs with the goal of decentralizing it in the medium-term future. The operator has the privilege to include or exclude any transaction they choose.

## Medium Severity

### Constant Block Difficulty Breaks EVM Equivalence

The `SystemContext` system contract is used to maintain context information that can be accessed from contract code. One of these values is the [block difficulty](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L40), which is hard-coded to 25 \* 1015.

This breaks EVM equivalence where `block.difficulty` is defined as the previous RANDAO value of the consensus layer as per the [EIP-4399](https://eips.ethereum.org/EIPS/eip-4399) specification. This can result in unexpected contract misbehavior which utilizes block difficulty as a weak source of randomness. For instance, in a naïve casino dApp this could lead to one-sided odds and hence a loss of funds.

Note that since [Solidity version 0.8.18](https://soliditylang.org/blog/2023/02/01/solidity-0.8.18-release-announcement/), `block.difficulty` is considered deprecated in favor of `block.prevrandao`.

Consider conforming to the EIP-4399 properties of `block.difficulty` / `block.prevrandao` to match the EVM's behavior.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *Due to the difficulty of the implementation of the fix, it was postponed to one of the future milestones. Note that the discrepancy is common among L2s and has been documented on the [Differences from Ethereum](https://era.zksync.io/docs/reference/architecture/differences-with-ethereum.html#difficulty) page.*

## Low Severity

### Misleading Documentation

Some of the comments communicate incorrect or misleading information. For instance:

- In the bootloader, the [`TX_OPERATOR_L2_BLOCK_INFO_SLOTS` constant](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L336-L342) description says "Note, that an additional slot is required for the fictive block at the end of the block" while it should say "[...] fictive block at the end of the batch".
- The reasoning for the fictive block to exist on [lines 638-639](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L638-L639) can be more detailed.
- The comment on [lines 1923-1924](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L1923-L1924) is wrong considering the [respective code](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L1966-L1974) is commented-out.
- The condition in `SystemContext` on [line 294](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L294) mismatches the message string and [comment](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L288): The condition checks "greater than or equal to" while the message string and comment say "greater than".
- The [`publicBatchDataToL1` function](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L2681-L2699) debug logs state that *block* data is published to L1, although it is referring to *batch* data.
- The comment and variables of the [`getBatchNumberAndTimestamp` function](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L102-L107) refer to *block* data, although *batch* is meant.
- The docstrings on [lines 297-304](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L297-L304) mention `block` in several places, but it should be `batch`.

Consider changing the comments to reflect the intention of the code.

***Update:** Resolved in [pull request #304](https://github.com/matter-labs/system-contracts/pull/304) at commit [3d9a4fa](https://github.com/matter-labs/system-contracts/pull/304/commits/3d9a4fa36b574f52ea50babae97f1370b7f99a36).*

### Missing Docstrings

Within the scope, there are two instances where docstrings are missing:

- The `_previousBlockTimestamp` parameter is not documented for the [`_verifyBlockTimestamp` function](https://github.com/matter-labs/zksync-2-contracts/blob/661a11ca86e56fa6f7e237511fb5adfe456aa00b/ethereum/contracts/zksync/facets/Executor.sol#L78-L80).
- The `_baseFee` parameter is not documented for the [`setNewBatch` function](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L297-L304).

Consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #305](https://github.com/matter-labs/system-contracts/pull/305) at commit [19c5200](https://github.com/matter-labs/system-contracts/pull/305/commits/19c52006cc7871dcbf73ffb15e1f7b745e7c2866) and [pull request #197](https://github.com/matter-labs/zksync-2-contracts/pull/197) at commit [dc82a21](https://github.com/matter-labs/zksync-2-contracts/pull/197/commits/dc82a21a468f2649d6db1ca549ffb0e0efc44e89).*

### Missing Error Message in `require` Statement

Within `SystemContext.sol`, there is a `require` statement on [line 17](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L17) that lacks an error message.

Consider including specific, informative error messages in `require` statements to improve overall code clarity and facilitate troubleshooting whenever a requirement is not satisfied.

***Update:** Resolved in [pull request #306](https://github.com/matter-labs/system-contracts/pull/306) at commit [d44a675](https://github.com/matter-labs/system-contracts/pull/306/commits/d44a67502db6c66127c8f342ed0166900f578969).*

### Misleading Variable Naming

Throughout the codebase, variable naming related to "batch" and "block" terminology is mixed together. For instance:

- In `SystemContext` on [lines 103-107](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L103-L107)
- In `Executor` on [line 84](https://github.com/matter-labs/zksync-2-contracts/blob/661a11ca86e56fa6f7e237511fb5adfe456aa00b/ethereum/contracts/zksync/facets/Executor.sol#L84)
- In `Bootloader` on [line 141](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L141), [line 166](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L166), [line 409](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L409), [line 3334](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L3334), and [line 3414](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L3414)

Consider consolidating terminology in all instances where "block" refers to "batch".

***Update:** Resolved in [pull request #307](https://github.com/matter-labs/system-contracts/pull/307) at commit [daa4020](https://github.com/matter-labs/system-contracts/pull/307/commits/daa4020b636b2f68868c37bb3356c256628729c5) and [pull request #198](https://github.com/matter-labs/zksync-2-contracts/pull/198) at commit [c4efbe7](https://github.com/matter-labs/zksync-2-contracts/pull/198/commits/c4efbe7450a37a4a6a305318dd0e830e5ee6673d).*

## Notes & Additional Information

### Non-Explicit Imports Are Used

Within [`Executor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/661a11ca86e56fa6f7e237511fb5adfe456aa00b/ethereum/contracts/zksync/facets/Executor.sol), global imports are being used. The use of non-explicit imports in the codebase can decrease the clarity of the code and may create naming conflicts between locally defined and imported variables. This is particularly relevant when multiple contracts exist within the same Solidity files or when inheritance chains are long.

Following the principle that clearer code is better code, consider using named import syntax *(`import {A, B, C} from "X"`)* to explicitly declare which contracts are being imported.

***Update:** Resolved in [pull request #199](https://github.com/matter-labs/zksync-2-contracts/pull/199) at commit [154ce74](https://github.com/matter-labs/zksync-2-contracts/pull/199/commits/154ce74ad95a5305d5187462b1eb9ca307c60680).*

### Typographical Errors

Throughout the scope, the following typographical errors were found:

- ["Transfering"](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/bootloader/bootloader.yul#L629) should be "Transferring"
- ["For the support of coinbase, we will the bootloader formal address for now"](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L36) should be "[...] we will use [...]".
- ["Just like the blockhash in the EVM, it returns bytes32(0), when when queried about hashes that are older than 256 blocks ago."](https://github.com/matter-labs/system-contracts/blob/44c4f989a305c0f1511e6ebf83da08adb8979325/contracts/SystemContext.sol#L79-L80) should have one less "when".
- ["timestampts"](https://github.com/matter-labs/zksync-2-contracts/blob/661a11ca86e56fa6f7e237511fb5adfe456aa00b/ethereum/contracts/zksync/facets/Executor.sol#L78) should be "timestamps".

Consider fixing the above errors to improve the clarity and readability of the codebase.

***Update:** Resolved in [pull request #308](https://github.com/matter-labs/system-contracts/pull/308) at commit [e0f6798](https://github.com/matter-labs/system-contracts/pull/308/commits/e0f679801e53b2af676bcaf2a02b626857143ed9) and [pull request #200](https://github.com/matter-labs/zksync-2-contracts/pull/200) at commit [7f7b6c6](https://github.com/matter-labs/zksync-2-contracts/pull/200/commits/7f7b6c69da6d4d62f3baabd106aba5cbd3b31c08).*

### Gas Optimizations

In the `Executor` facet, the following instances of gas optimization were identified:

- A bitwise "right-shift" operation (`>>`) is cheaper than a [division with a power of two](https://github.com/matter-labs/zksync-2-contracts/blob/661a11ca86e56fa6f7e237511fb5adfe456aa00b/ethereum/contracts/zksync/facets/Executor.sol#L87).
- A bitwise "and" operation (`&`) is cheaper than a [modulo with a power of two](https://github.com/matter-labs/zksync-2-contracts/blob/661a11ca86e56fa6f7e237511fb5adfe456aa00b/ethereum/contracts/zksync/facets/Executor.sol#L94).

Consider changing to these bitwise operations to save gas.

***Update:** Resolved in [pull request #201](https://github.com/matter-labs/zksync-2-contracts/pull/201) at commit [bbaa2f0](https://github.com/matter-labs/zksync-2-contracts/pull/201/commits/bbaa2f077d9ac345d44ad9147246681fa33cd64d).*

## Recommendations

### Usage of Block Number and Difficulty

The `NUMBER` or `0x43` opcode returns the current block number on Ethereum and zkSync Era. While on Ethereum blocks are produced every 12 seconds, on zkSync Era L2 blocks are produced every 1-2 seconds. However, on zkSync Era the operator controls the frequency of L2 blocks and, hence, can manipulate the block timestamp and block number. Thus, smart contracts that rely on the block number for calculations (e.g., interest rate) are exposed to unexpected behavior considering the Ethereum difference and influence through the operator.

Another peculiarity is related to the `PREVRANDAO`, `DIFFICULTY`, or `0x44` opcode which is set to a constant value on zkSync Era but on Ethereum, it gives a pseudo-random value. This might influence applications that rely on this opcode to behave unexpectedly.

Consider adding compile-time warnings or errors when the `NUMBER` and `PREVRANDAO` opcodes are used and thoroughly outlining their peculiarities in the documentation to help smart contract developers understand the differences and avoid making false assumptions.

## Conclusions

This audit was conducted over the course of a week. One medium-severity issue as well as a few low-severity and noteworthy issues were identified. Some changes were proposed to improve code readability and ensure smart contract security best practices are being followed. We found the dedicated documentation provided by the Matter Labs team to be helpful to understand the audited code changes. The team was also supportive in answering questions in a timely manner.
