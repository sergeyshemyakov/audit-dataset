# ZK Stack VM1.5 Diff Audit

Source: [https://www.openzeppelin.com/news/zk-stack-vm1.5-diff-audit](https://www.openzeppelin.com/news/zk-stack-vm1.5-diff-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Critical Severity](#critical-severity)
  - [Invalid Gas Accounting](#invalid-gas-accounting)
  - [Skipped Transaction Processing](#skipped-transaction-processing)
- [Low Severity](#low-severity)
  - [Misleading Comments](#misleading-comments)
  - [Missing Docstrings](#missing-docstrings)
- [Notes & Additional Information](#notes-additional-information)
  - [Typographical errors](#typographical-errors)
  - [Naming suggestions](#naming-suggestions)
  - [Code simplifications](#code-simplifications)
- [Conclusion](#conclusion)

## Summary

Type
:   Layer 2

Timeline
:   From 2024-03-25
:   To 2024-04-08

Languages
:   Solidity, Yul

Total Issues
:   7 (7 resolved)

Critical Severity Issues
:   2 (2 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   0 (0 resolved)

Low Severity Issues
:   2 (2 resolved)

Notes & Additional Information
:   3 (3 resolved)

Client Reported Issues
:   0 (0 resolved)

## Scope

We audited the change to the [matter-labs/era-contracts](https://github.com/matter-labs/era-contracts) repository between base commit [f29f2b7](https://github.com/matter-labs/era-contracts/tree/f29f2b72f999d6b91785accfb84eafb371620214) and head commit [705a4c8](https://github.com/matter-labs/era-contracts/tree/705a4c8946c1ddbd50dbc637010e6223b3865dab).

In scope were the following files:

```
 era-contracts
├── l1-contracts
│   └── contracts
│       ├── common
│       │   └── libraries
│       │       └── L2ContractHelper.sol
│       └── state-transition
│           └── chain-deps
│               └── facets
│                   └── Executor.sol
└── system-contracts
    ├── bootloader
    │   └── bootloader.yul
    └── contracts
        ├── Constants.sol
        ├── ContractDeployer.sol
        ├── GasBoundCaller.sol
        ├── L1Messenger.sol
        ├── MsgValueSimulator.sol
        ├── PubdataChunkPublisher.sol
        ├── SystemContext.sol
        ├── libraries
        │   └── SystemContractHelper.sol
        └── precompiles
            ├── CodeOracle.yul
            └── P256Verify.yul
```

## System Overview

This update includes several incremental changes to the codebase. Most importantly, the gas accounting for data published to L1 (pubdata) has been redesigned. This is used for all state changes and contracts deployed to ZKsync Era. Since the operator cost of publishing to L1 depends on the current L1 gas price, operations that necessitate pubdata incur a variable cost. Previously, this was deducted from the call frame's gas limit, like all other opcode gas charges. Under the new scheme, messages sent to L1 are charged a fixed gas cost during execution, but the variable amount is only charged at the end of the transaction.

This removes the variability in gas charges during regular execution, reduces overhead for transactions that change and later restore storage values, and also decouples the pubdata gas from the execution gas. However, this means that excess pubdata would not be detected until after it is used. In this scenario, the corresponding call frame is reverted, so the data no longer needs to be published.

The new mechanic means that only computation is limited by a call frame's gas limit. The new `GasBoundCaller` system contract has been introduced to support the previous behavior. To achieve this, it wraps the target call, measures the pubdata consumed, and ensures both computation and pubdata costs fit within the limit.

Two new precompiles were introduced: `CodeOracle` and `P256Verify`. `CodeOracle` retrieves the code associated with a specified code hash, if it is known. Since it is already possible to retrieve the code hash at a specified address, this introduces behavior similar to the EVM's `extcodecopy` instruction. `P256Verify` implements the [RIP-7212](https://github.com/ethereum/RIPs/blob/master/RIPS/rip-7212.md) precompile.

All value-bearing calls are directed through the `MsgValueSimulator` system contract. Since this contract is the one that invokes the actual target contract, it is also charged the gas costs associated with loading the target code into memory (decommitting it). The `MsgValueSimulator` now automatically receives a gas stipend for this purpose. It also forwards an extra 2300 gas to the target, recreating the corresponding EVM behavior.

Lastly, the codebase has been updated to accept 6 (instead of 2) data blobs per batch of L2 transactions.

It is worth noting that the codebase has independently been generalized to support the hyperchain use case. The code under review contains some associated incidental changes, such as moving administrator privileges to a `StateTransitionManager` contract and renaming "ETH" to "BASE\_TOKEN" where relevant. These changes are explored in a [parallel audit.](/zksync-state-transition-diff-audit)

## Critical Severity

### Invalid Gas Accounting

The bootloader reverses the [last two parameters](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1599-L1600) when calling `ZKSYNC_NEAR_CALL_callPostOp`. This causes the [pubdata allowance check](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L2340) to significantly overestimate the pubdata cost and underestimate the gas limit. Consequently, transactions that specify a paymaster and consume pubdata would likely fail this check, incorrectly reverting the `postTransaction` changes.

Consider correcting the parameter order.

***Update:** Resolved in [pull request #316](https://github.com/matter-labs/era-contracts/pull/316).*

### Skipped Transaction Processing

The audit commit inadvertently removed [the `processL2Tx` function invocation](https://github.com/matter-labs/era-contracts/blob/f29f2b72f999d6b91785accfb84eafb371620214/system-contracts/bootloader/bootloader.yul#L619-L621). If deployed, the bootloader would not process any L2 transactions. Consider restoring the invocation.

***Update:** Resolved in [pull request #316](https://github.com/matter-labs/era-contracts/pull/316).*

## Low Severity

### Misleading Comments

We have identified the following examples of misleading comments:

- The `gasBoundCall` function description mentions a [`BOUND_CALL_OVERHEAD` constant](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/GasBoundCaller.sol#L27), which does not exist in the codebase.
- The `sendToL1` function contains an [inline comment](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/L1Messenger.sol#L136) that refers to removed code.
- The `_processL2Logs` function contains an [outdated comment](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L196) describing the wrong number of logs.
- The [`computeGas` parameter](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L2753) to the `isNotEnoughGasForPubdata` function is described as "The amount of gas spent on the computation", but it is actually the amount of execution gas remaining that can still be spent on future computation.
- The `askOperatorForRefund` [function comment](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L3558) no longer describes the correct inputs.
- The `getPubdataPublishedFromMeta` [function comment](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/libraries/SystemContractHelper.sol#L223-L227) has correctly renamed the return value but still describes the old value. Similarly, the [offset constant](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/libraries/SystemContractHelper.sol#L229) it uses also refers to the old value.

Consider correcting or clarifying these comments.

***Update:** Resolved in [pull request #344](https://github.com/matter-labs/era-contracts/pull/344).*

### Missing Docstrings

Throughout the codebase, there are several values that do not have docstrings:

- The new `_pubdataToSpend` parameter ([1](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/libraries/SystemContractHelper.sol#L152), [2](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/libraries/SystemContractHelper.sol#L345)).
- Both parameters for the [`setPubdataInfo`](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/SystemContext.sol#L112) function. The description also only covers the first parameter.
- The new gas parameters ([1](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1060-L1064), [2](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1288-L1290), [3](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1352-L1354), [4](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1444-L1446), [5](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1480-L1484), [6](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1560-L1567), [7](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1801-L1802), [8](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L2252-L2254), [9](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L2797-L2798), [10](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L3568-L3570)).

Consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #346](https://github.com/matter-labs/era-contracts/pull/346).*

## Notes & Additional Information

### Typographical errors

We identified the following typographical errors. Consider correcting them.

- ["wouldbn't"](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/GasBoundCaller.sol#L75) should be "wouldn't".
- both instances ([1](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/precompiles/CodeOracle.yul#L69), [2](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/precompiles/CodeOracle.yul#L99)) of "a most" should be "at most".
- ["decomit"](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/precompiles/CodeOracle.yul#L105) should be "decommit".
- ["not"](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L2795) should be "no".
- ["baseSepnt"](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1162) should be "baseSpent".

***Update:** Resolved in [pull request #347](https://github.com/matter-labs/era-contracts/pull/347).*

### Naming suggestions

The [`pubdataPrice` and `pubdataCost` variables](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/GasBoundCaller.sol#L73-L77) are measured in gas, not ETH. For clarity, consider renaming them to `pubdataGasRate` and `pubdataGas` respectively.

***Update:** Resolved in [pull request #348](https://github.com/matter-labs/era-contracts/pull/348).*

### Code simplifications

Here are some suggestions for code simplifications:

- Instead of [copying values individually](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/contracts/precompiles/P256Verify.yul#L57-L70) from calldata, a single `calldatacopy` instruction could be used.
- Instead of using an [exclusive upper bound](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L178) to identify blob hash keys, using the [last relevant key](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/l1-contracts/contracts/state-transition/chain-interfaces/IExecutor.sol#L21) as the upper bound would be clearer.
- There are multiple places ([1](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1199-L1202), [2](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L1325-L1328), [3](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L2738-L2741)) where the new [`saturatingSub` function](https://github.com/matter-labs/era-contracts/blob/705a4c8946c1ddbd50dbc637010e6223b3865dab/system-contracts/bootloader/bootloader.yul#L3509) could be used.

***Update:** Resolved in [pull request #349](https://github.com/matter-labs/era-contracts/pull/349).*

## Conclusion

Despite the two simple oversights leading to serious issues, we found the changes to be well-motivated and implemented clearly. We appreciate the thorough documentation and Matter Labs' prompt responses to our questions throughout this engagement.

[![Request Audit](https://no-cache.hubspot.com/cta/default/7795250/7809b604-3f30-4cd5-be58-36982828e327.png)](https://cta-redirect.hubspot.com/cta/redirect/7795250/7809b604-3f30-4cd5-be58-36982828e327)
