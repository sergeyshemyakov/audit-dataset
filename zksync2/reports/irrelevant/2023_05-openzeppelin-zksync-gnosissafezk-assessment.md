# zkSync GnosisSafeZk Assessment

Source: [https://www.openzeppelin.com/news/zksync-gnosissafezk-assessment-1](https://www.openzeppelin.com/news/zksync-gnosissafezk-assessment-1)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Medium Severity](#medium-severity)
  - [Unexpected Refund Recipient](#unexpected-refund-recipient)
- [Low Severity](#low-severity)
  - [Discouraged Solidity Version](#discouraged-solidity-version)
  - [Misleading Documentation](#misleading-documentation)
- [Notes & Additional Information](#notes-additional-information)
  - [Hardcoded Gas Constants](#hardcoded-gas-constants)
  - [Unexpected Backrun Incentive](#unexpected-backrun-incentive)
  - [Unused Variable](#unused-variable)
- [Recommendations](#recommendations)
  - [System Contract Is Used as Placeholder Value](#system-contract-is-used-as-placeholder-value)
  - [Code Style Inconsistencies](#code-style-inconsistencies)
  - [Inconsistent Pagination](#inconsistent-pagination)
  - [Event Discrepancies](#event-discrepancies)
  - [Missing or Incorrect Docstrings](#missing-or-incorrect-docstrings)
  - [require Statement With Multiple Conditions](#require-statement-with-multiple-conditions)
  - [Singleton Contract Should Be First in the Inheritance Chain](#singleton-contract-should-be-first-in-the-inheritance-chain)
  - [Outdated EIP-1271 Interface](#outdated-eip-1271-interface)
  - [Unused signedMessages Mapping](#unused-signedmessages-mapping)
  - [Gas Inefficiency](#gas-inefficiency)
- [Conclusion](#conclusion)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-05-22
:   To 2023-05-26

Languages
:   Solidity

Total Issues
:   6 (1 resolved, 1 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   1 (0 resolved)

Low Severity Issues
:   2 (0 resolved, 1 partially resolved)

Notes & Additional Information
:   3 (1 resolved)

## Scope

We reviewed the `protofire/safe-contracts` repository at the [17d9fd5491f7e63543f51082e733220adb17a832](https://github.com/protofire/safe-contracts/tree/17d9fd5491f7e63543f51082e733220adb17a832) commit.

In scope were the following contracts:

```
 contracts
├── GnosisSafeZk.sol
└── GnosisSafeL2Zk.sol
```

However, the code under review is a minor modification to the established `GnosisSafe` and `GnosisSafeL2` contracts. We did not review the code in audit-level detail and we didn't audit the Gnosis Safe v1.3.0 code itself, rather we focussed on identifying edge cases or potential unexpected behavior that might arise when deploying the contract to the new zkSync Era Layer 2 blockchain. Throughout the assessment we relied on the provided [documentation](https://era.zksync.io/docs/dev/building-on-zksync/contracts/differences-with-ethereum.html) about known differences between zkSync Era zkEVM and a canonical Ethereum EVM.

## System Overview

The `GnosisSafe` contract is an N-of-M multisignature account with several extensible features, introduced by "modules". It allows (N of) the owners to:

- Invoke arbitrary transactions on behalf of the account, including administering the account itself.
- Manage the set of owner addresses.
- Introduce a Guard Manager contract to programmatically prevent some transactions.
- Introduce or remove additional functionality whenever desired.
- Decide how to handle unrecognized function calls.

The zkSync Era Layer 2 blockchain is designed to provide an EVM-compatible (but not equivalent) environment so that Layer 1 solidity contracts can be run on Layer 2 with a [few minor differences](https://era.zksync.io/docs/dev/building-on-zksync/contracts/differences-with-ethereum.html).

The `GnosisSafeZk` contract incorporates a minor change to address [one of the differences](https://era.zksync.io/docs/dev/building-on-zksync/contracts/differences-with-ethereum.html#using-call-over-send-or-transfer). Specifically the [`send` instruction](https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/GnosisSafe.sol#L208) in the `handlePayment` function has been changed to a [`call` instruction](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L208) instead. The `GnosisSafeL2Zk` contract is just an extension of `GnosisSafeZk` that adds two event emissions on top of `GnosisSafeZk` `execTransaction` and `execTransactionFromModule` functions.

The goal of this review was to assess whether this adapted contract can be expected to have the same behavior within the zkSync ecosystem that the `GnosisSafe` contract has on the Ethereum mainnet.

## Medium Severity

### Unexpected Refund Recipient

Any address [is able](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L122) to invoke a transaction on behalf of the `GnosisSafeZk` contract, provided the transaction has been [authorized by enough owners](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L145) and the relayer accepts the corresponding [gas refund parameters](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L117-L119). However, if no `refundRecipient` is specified, the `tx.origin` address [will receive the refund](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L204).

This makes sense on the EVM but on the zkEVM there is an important subtlety. If the initiator is an EOA (the default account), then it is set as the `tx.origin` value, so it will correctly receive the refund. However, if the initiator is another smart contract account, [the bootloader will be set as `tx.origin`](https://github.com/matter-labs/era-system-contracts/blob/main/bootloader/bootloader.yul#L1364) and it will incorrectly receive the refund.

To avoid loss of funds, consider enforcing that the `refundRecipient` is specified whenever `tx.origin` is the bootloader address.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *We agree that this complicates the usage of custom accounts with multisig wallet. However, the cost of supporting different codebases is also very high and the issue affects only custom zkSync functionality.*

## Low Severity

### Discouraged Solidity Version

The zkSync Era documentation [strongly recommends](https://era.zksync.io/docs/api/compiler-toolchain/solidity.html#limitations) using the latest `0.8.x` version of Solidity. However, the code under review [allows all versions from 0.7.0](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L2) and the project [is configured](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/hardhat.config.ts#L47) to use version `0.7.6`. To comply with best practices, consider compiling with the latest Solidity version.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *While it is always better to use the latest version of the compiler, there are no known issues that affect the codebase.*

### Misleading Documentation

Here are some suggestions for improving the clarity and accuracy of the documentation:

- The [claim](https://era.zksync.io/docs/dev/building-on-zksync/contracts/contract-development.html#unsupported-functions) that `creationCode` is not supported should instead say that it translates to the bytecode hash.
- As a matter of good practice, the [example `.send` or `.transfer` replacement](https://era.zksync.io/docs/dev/building-on-zksync/contracts/differences-with-ethereum.html#using-call-over-send-or-transfer) should check the success flag after the `call`.
- The [claim](https://era.zksync.io/docs/dev/fundamentals/interacting.html#why-are-metamask-native-contract-interactions-not-working) that zkSync Era does not support EIP-1559 transactions is contradicted by the [listed transaction types](https://era.zksync.io/docs/dev/developer-guides/transactions/transactions.html#transaction-types).
- The [`SystemContractsCaller` explanation](https://era.zksync.io/docs/dev/developer-guides/aa.html#using-the-systemcontractscaller-library) contains a broken link to the contract implementation.

Consider updating the documentation accordingly.

***Update:** Partially resolved in [pull request #591](https://github.com/matter-labs/zksync-web-era-docs/pull/591) at commits [6d77af8](https://github.com/matter-labs/zksync-web-era-docs/pull/591/commits/6d77af85e3b266135a6931621c95bdd42643a3d9) and [d446f94](https://github.com/matter-labs/zksync-web-era-docs/pull/591/commits/d446f94743c47ffbcca9e41f415110710bae2d35), with second suggestion not being addressed.*

## Notes & Additional Information

### Hardcoded Gas Constants

The existing codebase uses hardcoded constants to determine the [transaction execution overhead](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L170) and the [token transfer overhead](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/common/SecuredTokenTransfer.sol#L22), which contradicts the [recommended best practice](https://era.zksync.io/docs/dev/building-on-zksync/contracts/differences-with-ethereum.html#do-not-rely-on-evm-gas-logic). Consider whether these constants are still valid under the zkSync Era fee model, and whether it would be appropriate to remove the constants altogether.

***Update:** Acknowledged, not resolved. The Matter Labs team acknolwedged this issue.*

### Unexpected Backrun Incentive

During the audit we incidentally identified a minor undesirable incentive. As noted in the [documentation](https://era.zksync.io/docs/dev/developer-guides/transactions/fee-model.html), only state diffs are stored on Ethereum mainnet. The transaction cost for a storage change is only charged once to the first user in the block that made the change. This creates an incentive for users to backrun other transactions that modify the same storage slots, since subsequent changes will not be charged.

The incentive is capped at the cost of all storage changes in the transaction, and is partially mitigated by the fact that currently all transactions are sent directly to the sequencer. Consider whether it's worth socializing the cost to every user interacting with the same storage slot.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *We will take this into account with updating the fee model mechanism.*

### Unused Variable

When refunding the gas costs, the [returned `data` variable](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L208) is unused.

Consider leaving it undeclared.

***Update:** Resolved. The Matter Labs team stated:*

> *Fixed with using original GnosisSafe/GnosisSafeL2 contract codes.*

## Recommendations

#### Recommended Changes to Safe Functionality

Although not required for zkSync compatibility, we identified several recommendations to improve the original Gnosis functionality.

### System Contract Is Used as Placeholder Value

The code uses a hardcoded sentinel address of `0x1` to define the [owner linked list](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/base/OwnerManager.sol#L13) and the [module linked list](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/base/ModuleManager.sol#L16). This is intended to be a placeholder address, but it corresponds to the [`Ecrecover` system contract](https://github.com/matter-labs/era-system-contracts/blob/main/contracts/Constants.sol#L25) on the zkEVM (and the `ecrecover` precompile on the EVM).

This introduces the possibility that the `Ecrecover` system contract could incorrectly invoke [the `approveHash` function](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L335). This will not be an issue in practice, but in the interest of predictability, consider choosing a pseudorandom address that is not being used by a system contract.

### Code Style Inconsistencies

The `GnosisSafeZk` [contract](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol) uses different styles of docstrings simultaneously. For example, compare the docstrings of the [`approveHash` function](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L331-L334) with the [`requiredTxGas` function](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L308-L316). Consider unifying the style.

### Inconsistent Pagination

The [`start` parameter](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/base/ModuleManager.sol#L110) of the `getModulesPaginated` function is supposed to be at the start of the page. However, the first returned value is the module [immediately after the `start` module](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/base/ModuleManager.sol#L120). This means that neither the `start` module nor the [returned `next` module](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/base/ModuleManager.sol#L113) are contained in the page. If the whole list is enumerated by passing the `next` module as the `start` of the next page, subsequent pages will have a missing module between them.

Consider updating the code to return the `start` module as the first element on the page.

### Event Discrepancies

The `GnosisSafeL2Zk` contract emits [SafeMultiSigTransaction](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeL2Zk.sol#L56) and [SafeModuleTransaction](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeL2Zk.sol#L83) events whether or not the actual operation succeeds, so they need to be correlated with the [success or failure events](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/base/ModuleManager.sol#L71-L72) for accurate tracking. Consider including the transaction result in the event message.

Moreover, these events (as well as several events in the `GnosisSafeZk` contract) do not index their parameters. Our recommendation is to consider [indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events) to improve the ability of off-chain services to search and filter for specific events.

### Missing or Incorrect Docstrings

Some parts of the codebase do not have docstrings. For instance:

- [Line 195](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L195-L196) in `GnosisSafeZk.sol`
- [Line 351](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L350-L351) in `GnosisSafeZk.sol`

Some parts of the code have misleading docstrings. For instance:

- [Line 181](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L181) in `GnosisSafeZk.sol` says funds are being sent to the tx.origin, while that's not necessarily true.
- [Line 25](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/base/GuardManager.sol#L25) in `GuardManager.sol` incorrectly describes the `FallbackManager` contract.

Consider adding docstrings where needed and fixing incorrect ones to improve the overall readability of the codebase. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html) (NatSpec).

### `require` Statement With Multiple Conditions

Within [GnosisSafeZk.sol](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol) there is a `require` statement on [line 303](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L303) that requires multiple conditions to be satisfied.

To simplify the codebase and raise the most helpful error messages for failing `require` statements, consider having a single `require` statement per condition.

### `Singleton` Contract Should Be First in the Inheritance Chain

The [comment](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/common/Singleton.sol#L4) on the `Singleton` contract explicitly states that it should be positioned in the inheritance chain to align the `singleton` variable. However, it is [positioned](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L21) as second instead. In this case, the `singleton` variable is still positioned correctly, but this cannot be ascertained by local reasoning. To increase robustness, consider moving it to the top of the inheritance list.

### Outdated EIP-1271 Interface

The `GnosisSafeZk` contract uses [`0x20c13b0b`](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/interfaces/ISignatureValidator.sol#L6) as the EIP-1271 magic constant, corresponding to the old `isValidSignature` function interface. However, the latest version of the EIP uses a [new interface](https://eips.ethereum.org/EIPS/eip-1271) and a corresponding new constant. Consider complying with the latest definition of the EIP.

### Unused `signedMessages` Mapping

The [`signedMessages`](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L54) mapping and [`SignMsg`](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L47) event are not used in the deployed code. They are referenced in the [`SignMessageLib`](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/libraries/SignMessageLib.sol#L9) contract (which redefines [the event](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/libraries/SignMessageLib.sol#L15)) and appear to offer similar functionality to the [`approvedHashes` mapping](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L56).

Consider whether it should be updated in the [`approveHash`](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L335) function (to update the number of people who accept the transaction), or in [`execTransaction`](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/GnosisSafeZk.sol#L111) after it's been executed, or if it should be removed entirely.

### Gas Inefficiency

The `add(result, 0x20)` operation in [the `getStorageAt` function](https://github.com/protofire/safe-contracts/blob/17d9fd5491f7e63543f51082e733220adb17a832/contracts/common/StorageAccessible.sol#L19) of `StorageAccessible` contract can be moved outside the loop. This would also be an opportunity to introduce a comment explaining why the `0x20` offset is used (to account for the length field), which would improve the readability of the code.

## Conclusion

This assessment was conducted over the course of a week, and we uncovered a handful of medium and lower-severity issues as well as a number of general recommendations related to Safe functionality.
