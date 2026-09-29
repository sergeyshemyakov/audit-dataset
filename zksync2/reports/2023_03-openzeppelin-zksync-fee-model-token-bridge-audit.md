# zkSync Fee Model and Token Bridge Audit

Source: [https://www.openzeppelin.com/news/zksync-fee-model-and-token-bridge-audit](https://www.openzeppelin.com/news/zksync-fee-model-and-token-bridge-audit)

March 9, 2023

This security assessment was prepared by **OpenZeppelin**.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [Summary of Changes to the Bootloader](#summary-of-changes-to-the-bootloader)
  - [L1/L2 Bridges](#l1l2-bridges)
  - [System Contracts](#system-contracts)
- [Security Model and Privileged Roles](#security-model-and-privileged-roles)
- [EVM Differences](#evm-differences)
- [Testing Coverage Recommendations](#testing-coverage-recommendations)
- [High Severity](#high-severity)
  - [Malicious Operator Can Dodge Refund](#malicious-operator-can-dodge-refund)
- [Medium Severity](#medium-severity)
  - [Users Can Lose Funds in L1ERC20Bridge Implementation Contract](#users-can-lose-funds-in-l1erc20bridge-implementation-contract)
  - [Lack of \_\_gap Variable](#lack-of-__gap-variable)
  - [ceilDiv Function Can Overflow](#ceildiv-function-can-overflow)
  - [Overflows in Fee Computation](#overflows-in-fee-computation)
  - [Missing Factory Dependencies](#missing-factory-dependencies)
- [Low Severity](#low-severity)
  - [Missing Error Messages in require and revert Statements](#missing-error-messages-in-require-and-revert-statements)
  - [L2ERC20Bridge Is Not Upgradeable](#l2erc20bridge-is-not-upgradeable)
  - [Potential EIP-1052 Deviation](#potential-eip-1052-deviation)
  - [Lack of Events](#lack-of-events)
  - [setValueUnderNonce Value Is Mutable](#setvalueundernonce-value-is-mutable)
  - [Implicit Zero Cost Assumption](#implicit-zero-cost-assumption)
  - [Floating Pragma Solidity Version](#floating-pragma-solidity-version)
  - [Unnecessarily Delayed Error Handling](#unnecessarily-delayed-error-handling)
- [Notes & Additional Information](#notes-additional-information)
  - [Interface Mismatch](#interface-mismatch)
  - [Variable Visibility Not Explicitly Declared](#variable-visibility-not-explicitly-declared)
  - [Code Redundancy](#code-redundancy)
  - [Inexplicit Fail](#inexplicit-fail)
  - [Indecisive License](#indecisive-license)
  - [Misplaced Event](#misplaced-event)
  - [Gas Optimizations](#gas-optimizations)
  - [Inexplicit Disable of Initialization](#inexplicit-disable-of-initialization)
  - [Inconsistent Usage of Named Return Variables](#inconsistent-usage-of-named-return-variables)
  - [Inconsistent Declaration of Integers](#inconsistent-declaration-of-integers)
  - [Naming Suggestions](#naming-suggestions)
  - [Unused Imports](#unused-imports)
  - [Theoretical Aggregate ETH Inconsistency](#theoretical-aggregate-eth-inconsistency)
  - [Checks-Effects-Interactions Recommendation](#checks-effects-interactions-recommendation)
  - [Complex Nonce Packing](#complex-nonce-packing)
  - [Typographical Errors](#typographical-errors)
  - [Unclean Code](#unclean-code)
  - [Missing and Misleading Documentation](#missing-and-misleading-documentation)
- [Conclusions](#conclusions)
- [Appendix](#appendix)
  - [Monitoring Recommendations](#monitoring-recommendations)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-01-23
:   To 2023-02-17

Languages
:   Solidity

Total Issues
:   32 (22 resolved, 2 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   1 (1 resolved)

Medium Severity Issues
:   5 (2 resolved)

Low Severity Issues
:   8 (7 resolved)

Notes & Additional Information
:   18 (12 resolved, 2 partially resolved)

## Scope

We audited the `matter-labs/zksync-2-contracts` repository at the [`9f3c6944e6320166edd96ef6586a9dd4548a27f2`](https://github.com/matter-labs/zksync-2-contracts/tree/9f3c6944e6320166edd96ef6586a9dd4548a27f2) commit. In scope were the following contracts:

```
├── ethereum
│   └── contracts
│       └── bridge
│           ├── L1ERC20Bridge.sol
│           └── interfaces
│               ├── IL1Bridge.sol
│               └── IL2Bridge.sol
└── zksync
    └── contracts
        └── bridge
            ├── L2ERC20Bridge.sol
            ├── L2StandardERC20.sol
            └── interfaces
                ├── IL1Bridge.sol
                ├── IL2Bridge.sol
                └── IL2StandardToken.sol
```

In addition, we audited the `matter-labs/system-contracts` repository at the [`191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f`](https://github.com/matter-labs/system-contracts/pull/170/files/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f) commit of pull request [#170](https://github.com/matter-labs/system-contracts/pull/170). The contracts marked as diff were previously audited and hence only the latest changes were reviewed. All other contracts were fully audited. In scope were the following contracts:

```
├── bootloader
│   └── bootloader.yul (diff)
└── contracts
    ├── AccountCodeStorage.sol
    ├── ContractDeployer.sol
    ├── ImmutableSimulator.sol
    ├── KnownCodesStorage.sol
    ├── L2EthToken.sol (diff)
    ├── MsgValueSimulator.sol (diff)
    ├── NonceHolder.sol
    └── interfaces
        ├── IAccountCodeStorage.sol
        ├── IContractDeployer.sol
        ├── IEthToken.sol (diff)
        ├── IImmutableSimulator.sol
        ├── IKnownCodesStorage.sol
        ├── IL2StandardToken.sol
        └── INonceHolder.sol
```

## System Overview

This audit focuses on the latest changes to the bootloader, described in our [previous audit](https://blog.openzeppelin.com/zksync-bootloader-audit-report/), the functionality of the L1/L2 (Layer 1 / Layer 2) Bridges, and changes to the system contracts. We found the system to be modular and well-documented.

### Summary of Changes to the Bootloader

The bootloader now supports the fee model, which is the main change over the previous version. For a given L1 gas price, the bootloader calculates the `basefee` for the zkSync L2. Users are generally required to make significant upfront payments when conducting zkSync transactions, and are later refunded for the unused ergs, the zkSync-equivalent gas unit. The fee includes an overhead amount of ergs, which compensates for the calculation of the proof as well as committing and verifying the block on L1. The bootloader is ensuring that users are not overcharged for their transactions by making these calculations itself and checking against the operator inputs. As such, the bootloader plays a crucial role in the fair processing of transactions. However, the operator can provide a higher refund to the user than what was calculated by the bootloader. In short, the bootloader calculates how much of the block’s overhead should be covered by each transaction. It also acts as an ETH bridge now, which was previously done through dedicated bridge contracts.

We identified one high-severity issue which allows a malicious operator to minimize the refund for the user, thereby effectively stealing funds. Further, we raised a medium-severity issue about instances of overflows and underflows as part of the fee calculation, one of which allows users to pay no fees.

### L1/L2 Bridges

The new token bridge exclusively handles transfers of ERC-20 tokens between the two domains. It is worth noting that although it does not support ETH transfers, it is possible to send an arbitrary amount of ETH along with any token deposit.

All ERC-20 tokens are supported, as long as they are defined on L1. For every token deposited in the L1 bridge, a new token is minted on L2. The L2 token will copy the L1 token’s optional metadata (i.e. the name, symbol and decimals values) but it is otherwise a standard ERC-20 token. Any non-standard functionality (e.g., rebasing or transfer restrictions) is not replicated on the L2 token. When the token is returned to the L2 bridge, it is then burned and the corresponding L1 tokens are released.

### System Contracts

The codebase defines some system contracts on L2 that help replicate (and extend) the EVM’s behavior in the zkEVM. Below is a summary of the system contracts that have been audited, with an overview of their respective functionality.

#### NonceHolder

The zkEVM supports native account abstraction, which means it recognizes some contracts as “accounts” that can originate transactions. To prevent replay attacks, the bootloader ensures that every transaction originating from an account has a unique nonce. It also ensures that account nonces are consumed sequentially (so all transactions have a well-defined order), although each account can optionally relax this restriction.

In addition, all contracts (including accounts) use a sequential deployment nonce to ensure every contract they deploy with the `CREATE` opcode has a unique address. If they use the `CREATE2` opcode, the salt parameter should provide uniqueness, although the deployment nonce is incremented anyway so it still tracks the number of contracts that have been deployed.

The `NonceHolder` contract manages these nonces for all contracts and provides utility functions to ensure uniqueness.

#### KnownCodeStorage

To guarantee data availability, all L2 transactions are published on L1. In addition, the bytecode of all L2 contracts should also be published on L1. This ensures that the entire state of the zkEVM can always be reconstructed from publicly available information.

The `KnownCodeStorage` contract simply tracks which L2 contracts (technically, which bytecode hashes) have been published. To achieve this, L2 transactions can include optional bytecode hashes to signal to the bootloader that the preimages should be published. Any new values are marked off in the `KnownCodeStorage` contract once it guarantees that the preimage is known (either because the transaction originated on L1 or because the `KnownCodeStorage` explicitly sends a message to L1 that can only be resolved by publishing the preimage). It also ensures that any new bytecode conforms to the zkEVM length requirements.

#### AccountCodeStorage

The `AccountCodeStorage` contract stores the code hashes associated with all L2 contracts (not just accounts). This facilitates querying the code hash and code size of all contracts. In contrast to the EVM, L2 contracts don’t have separate initialization code, and instead include the constructor as part of their run-time bytecode. The `AccountCodeStorage` contract also manages the `isConstructing` flag associated with each contract to help recreate the expected constructor behavior (ie. it is called exactly once during deployment and never again).

#### ImmutableSimulator

Since the zkEVM does not distinguish between initialization code and run-time code, the contract’s code needs to be registered before the constructor is executed. This means that in contrast to the EVM, the constructor cannot modify the run-time code to include any immutable values.

Instead, the constructor code simply returns all of the immutable values, which are saved in the `ImmutableSimulator` contract for whenever they are needed.

#### ContractDeployer

Instead of using the `CREATE` and `CREATE2` opcodes, contracts on the zkEVM are deployed using the `ContractDeployer` system contract. This contract manages the deployment nonces and ensures all new bytecode is known (see the `KnownCodeStorage` section).

It also distinguishes between “accounts” and regular contracts to ensure accounts can choose their account abstraction implementation (only version 1 is currently supported) and can manage their transaction nonce ordering.

## Security Model and Privileged Roles

The security of the system in scope depends on the individual governors of the respective contracts, which are analyzed for the bridge and the system contracts.

The L1 ERC-20 bridge as well as the L2 ERC-20 token implementation are both upgradeable. Any ERC-20 token that is bridged into zkSync will be locked into this L1 bridge contract, and a malicious upgrade to this contract would let an attacker steal the locked funds. The L2 token implementation could be similarly affected (by stealing the tokens through a malicious version on L2 and then bridging them back to L1).

The L1 ERC-20 bridge implements the `AllowList` access control. This mechanism enables restriction for functions and callers. Hence, a function can be fully inaccessible, or only accessible to specific addresses. The `finalizeWithdrawal` function is affected by this mechanism, which is a necessary step to withdraw ERC-20 tokens from L2 to L1. Thus, users could be prevented from bridging their assets back to L1.

The system contracts in scope play an integral role in the system’s operations. These contracts can be upgraded through a force-deploy through a requested L2 transaction from L1. This upgrade mechanism is tied to proposals made to the `DiamondCut` facet and managed by this respective governor and the security council.

It is strongly advised that the governors and owners of these contracts be extensively secured through cold wallets and multisigs. Further, it is assumed that these actors will act in the best interest of the users.

The zkSync system requires a dedicated *operator* role to coordinate and bundle all L2 transactions. Currently, the operator will be centralized through Matter Labs with the goal to decentralize it in the medium-term future. The operator has the privilege to include or exclude any transaction they choose. The [priority mode](https://era.zksync.io/docs/dev/developer-guides/bridging/l1-l2-interop.html#priority-mode) censoring protection mechanism is still to be implemented. Furthermore, as part of the fee model at the current stage of the protocol, the operator is trusted to pick a fair L1 gas price, which influences the L2 fees paid by the user.

## EVM Differences

It is worth noting that due to the current system design, some interactions work differently from the EVM. For instance, to deploy a contract or custom account, a user must call the respective system contract along with specific parameters, which is not the case for an EVM deployment transaction. Prior to that, the bytecodes (factory dependencies) need to be explicitly shared with the operator and published on L1. The [zkSync documentation](https://era.zksync.io/docs/dev/building-on-zksync/contracts/contract-deployment.html#ethereum-zksync-differences) provides additional context.

In addition, as seen in the *Potential EIP-1052 Deviation* issue, it is possible that opcodes deviate from EVM behavior, which still needs to be explored for other opcodes. For more differences – including unsupported opcodes – visit the [EVM compatibility](https://era.zksync.io/docs/dev/building-on-zksync/contracts/contracts.html#evm-compatibility) section of the zkSync documentation.

## Testing Coverage Recommendations

Due to the complex nature of the system and several subtle deviations from the EVM, we believe this audit would have benefitted from more complete testing coverage, particularly around the bridge messages and new fee mechanics.

While insufficient testing is not necessarily a vulnerability, it implies a high probability of additional hidden vulnerabilities and bugs. Given the complexity of this codebase and the numerous interrelated risk factors, this probability is further increased. Testing provides a full implicit specification along with the exact expected behaviors of the codebase, which is especially important when adding novel functionalities. A lack thereof increases the chances that correctness issues will be missed. It also results in more effort to establish basic correctness and reduces the effort spent exploring edge cases, thereby increasing the chances of missing complex issues.

Moreover, the lack of repeated automated testing of the full specification increases the chances of introducing breaking changes and new vulnerabilities. This applies to both previously audited code and future changes to current code. This is particularly true in this project due to the pace, extent, and complexity of ongoing and planned changes across all parts of the stack (L1, L2, bootloader and system contracts, compiler and zkEVM). Underspecified interfaces and assumptions increase the risk of subtle integration issues, which testing could reduce by enforcing an exhaustive specification.

To address these issues, we recommend implementing a comprehensive multi-level test suite before the next expected audits. Such a test suite should comprise contract-level tests with >90% coverage, per-layer deployment and integration tests that test the deployment scripts as well as the system as a whole, per-layer fork tests for planned upgrades, and cross-chain full integration tests of the entire system. Crucially, the test suite should be documented in a way so that a reviewer can set up and run all these test layers independently of the development team. Some existing examples of such setups can be suggested for use as reference in a follow-up conversation. Implementing such a test suite should be a very high priority to ensure the system’s robustness and reduce the risk of vulnerabilities and bugs.

## High Severity

### Malicious Operator Can Dodge Refund

In the [`refundCurrentL2Transaction` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1154), the user gets refunded for overpaying in ergs for their L2 transaction. The ETH amount to refund is dependent on the ergs amount and the ergs price. The ergs amount is the maximum value of the operator-provided value and the one calculated by the bootloader. The ergs amount multiplied by the ergs price determines the refund in ETH.

A malicious operator can provide a very large amount of ergs that should be refunded, which will therefore be the chosen [`refundInErgs` value](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1204). However, when multiplied by the ergs price, `ethToRefund` can overflow and lead to a very low refund, effectively stealing funds from the user.

Consider calculating the refund based on the bootloader and operator values individually and then picking the higher amount to protect the fee model against a malicious operator.

***Update:** Resolved in [pull request #208](https://github.com/matter-labs/system-contracts/pull/208) at commit [57ba2b1](https://github.com/matter-labs/system-contracts/pull/208/commits/57ba2b120026ab6373505f362eebe6f640adb8b6).*

## Medium Severity

### Users Can Lose Funds in `L1ERC20Bridge` Implementation Contract

The `L1ERC20Bridge` is the implementation contract that is intended to be used with a proxy, so it is good practice to restrict how it can be invoked directly. When the contract is constructed, the `reentrancyGuardInitializer` modifier is executed and the immutable [`_mailbox` address is written](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L58) to the bytecode that is deployed. During this invocation of `reentrancyGuardInitializer`, the reentrancy status is set to `_NOT_ENTERED`, which locks the `initialize` function from being called, but simultaneously allows functions with the `nonReentrant` modifier to be called.

Specifically, the `deposit` function of the implementation contract is callable. However, in the implementation contract itself, many variables are not initialized, such as the [`l2Bridge` variable](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L126), so it holds the zero-address. Therefore, the `deposit` function would request an L2 transaction that attempts to finalize the withdrawal by calling the zero-address, thereby triggering the non-reverting fallback function of the [`EmptyContract`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/EmptyContract.sol). Since this L2 call does not fail, the deposited tokens are locked and irrecoverable, as a call to [`claimFailedDeposit`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L185) cannot be proven.

Consider implementing a stricter mechanism that prohibits direct calls to the contract if all or some of its variables were not properly initialized. In addition, consider preventing the initialization of the implementation contract more directly, rather than relying on the implicit behavior of `reentrancyGuardInitializer`, which lacks visibility.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *While we appreciate your insights and suggestions, we do not believe the issue carries a significant security risk. As the contract is intended to be used through a proxy, direct calls to the implementation contract are not recommended. Users could also call any other scam contract.*

### Lack of `__gap` Variable

The [`L1ERC20Bridge`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol) and [`L2StandardERC20`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol) contract are intended to be used as logic contracts with a proxy, but do not have a `__gap` variable. This would become problematic if a subsequent version was to inherit one of these contracts. If the derived version were to have storage variables itself and additional storage variables were subsequently added to the inherited contract, a storage collision would occur.

Consider appending a [`__gap` variable](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps) as the last storage variable to these upgradeable contracts, such that the storage slots sum up to a fixed amount (e.g. 50). This will proof any future storage layout changes to the base contract. Note that the `__gap` variable space will need to be adjusted accordingly as subsequent versions include more storage variables, in order to maintain the fixed amount of slots (e.g. 50).

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *While we appreciate your insights and suggestions, we do not believe the issue has a significant security risk. Specified contracts are not expected to be inherited, since they are complete logical contracts.*

### `ceilDiv` Function Can Overflow

The [`ceilDiv` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L548) of the bootloader is used throughout the fee model formulas. This function can overflow as the numerator and denominator are added together before they are divided. Although this was not identified as a threat in the current codebase, an issue could be introduced by using this function with unvalidated inputs.

Consider adapting the formula to be safe from overflows.

***Update:** Resolved in [pull request #236](https://github.com/matter-labs/system-contracts/pull/236) at commit [56b3231](https://github.com/matter-labs/system-contracts/pull/236/commits/56b323195d4dd1f23c434d60d66b84e4e1b4ec98).*

### Overflows in Fee Computation

The bootloader changes in scope involve a few formulas as part of the fee model, and there were a few instances where calculations were performed on user or operator-provided inputs. Unchecked arithmetic (without overflow protection) using these values is generally dangerous and prone to exploits.

One example is the calculated ergs price. If the `maxPriorityFeePerErg` is sufficiently large and the `maxFeePerErg` value is [increased to match](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L930), the [`maxFeeThatOperatorCouldTake`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L944) calculation could overflow, resulting in a zero ergs price. The transaction will still be executed but the [amount the user pays](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L642) would be zero. A savvy operator could recognize this scenario and discard the operation, but it does make the system unnecessarily fragile.

We also identified the following cases where potential overflows with user-provided values appear to be unmitigated, although the consequences are limited:

- The [`intrinsicOverhead`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1024) calculation in the `getErgsLimitForTx` function
- The [return value](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1457) of the `getBlockOverheadErgs` function
- The numerators of the `overheadForCircuits`, `overheadForLength`, and `overheadForPubdata` calculations in the [`getTransactionUpfrontOverhead`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1478) function

Lastly, the following functions appear to allow overflows, but they are protected by validations in other parts of the codebase:

- In [`getBaseFee`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L90), a large `l1GasPrice` could cause `pubdataBytePriceETH` to overflow but the [`validateOperatorProvidedPrices` checks](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L34) prevent this.
- In [`processL1Tx`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L813), `toRefundRecipient` would negative overflow if the value was too large, but the check on [line 1306](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1306) prevents this.
- In [`getErgsLimitForTx`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1003), `ergsLimitForTx` would negative overflow if the `operatorOverheadForTransaction` was too large, but the check on [line 1253](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1253) prevents this.

Consider applying additional checks to these operations, explicitly documenting where the checks are or why they would not be necessary. Whenever a potential overflow is not mitigated in the same function, consider documenting where the relevant validation can be found. It is advised to check the rest of the bootloader for more potential overflows and underflows. Lastly, it is recommended to validate all changes with proper dynamic testing.

***Update:** Resolved in [pull request #211](https://github.com/matter-labs/system-contracts/pull/211) at commit [448932e](https://github.com/matter-labs/system-contracts/pull/211/commits/448932ec7d8797961919d74bbfbc1b074bec4efd).*

### Missing Factory Dependencies

When the `L1ERC20Bridge` is initialized, the bytecode of the L2 bridge and token proxy [are both provided](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L72) as factory dependencies. This ensures the code [is known](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/KnownCodesStorage.sol#L96) when the L2 Bridge is deployed, or a new token is created. However, the L2 bridge initialization also [deploys the token implementation and proxy beacon](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L43-L44). Since neither contract was listed as a factory dependency, they may not be marked as known. Unless they were previously mentioned in an unrelated transaction, the bridge initialization will fail.

Consider including the `L2StandardERC20` and the `UpgradeableBeacon` contracts in the factory dependencies of the bridge initialization transaction.

***Update:** Acknowledged, will resolve. The Matter Labs team stated:*

> *Acknowledged. The problem can only be encountered at the initialization stage, so we prefer not to change the deployment scripts at the moment. This has been included in the backlog as a refactoring task.*

## Low Severity

### Missing Error Messages in `require` and `revert` Statements

Throughout the [bridge](https://github.com/matter-labs/zksync-2-contracts/tree/9f3c6944e6320166edd96ef6586a9dd4548a27f2) and [system contracts codebases](https://github.com/matter-labs/system-contracts/tree/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f) there are `require` and `revert` statements that lack error messages:

- The `require` statement on [line 96](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L96) of [`L2StandardERC20.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol)
- The `revert` statement on [line 116](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L116) of [`L2StandardERC20.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol)
- The `revert` statement on [line 122](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L122) of [`L2StandardERC20.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol)
- The `revert` statement on [line 128](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L128) of [`L2StandardERC20.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol)
- The `require` statement on [line 25](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L25) of [`AccountCodeStorage.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol)
- The `require` statement on [line 36](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L36) of [`AccountCodeStorage.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol)
- The `require` statement on [line 50](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L50) of [`AccountCodeStorage.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol)
- The `require` statement on [line 39](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L39) of [`ContractDeployer.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol)
- The `require` statement on [line 34](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ImmutableSimulator.sol#L34) of [`ImmutableSimulator.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ImmutableSimulator.sol)

Consider including specific, informative error messages in `require` and `revert` statements to improve overall code clarity and facilitate troubleshooting whenever a requirement is not satisfied. In addition, for statements that do contain a message, consider using longer strings instead of a few characters to describe the error.

***Update:** Resolved in [pull request #212](https://github.com/matter-labs/system-contracts/pull/212) at commit [cb93637](https://github.com/matter-labs/system-contracts/pull/212/commits/cb936372ba8e97e8e17e9f231ab8630d45c223e1) and [pull request #63](https://github.com/matter-labs/zksync-2-contracts/pull/63) at commit [77e64b5](https://github.com/matter-labs/zksync-2-contracts/pull/63/commits/77e64b59b00cc34c4af424b81c6c8889a686d171). The Matter Labs team stated:*

> *We did not add error messages to reverts from name/symbol/decimals functions because if the token does not implement that method it should behave exactly the same way as if the function was not declared.*

### `L2ERC20Bridge` Is Not Upgradeable

The `L1ERC20Bridge` and `L2ERC20Bridge` contracts manage the ERC-20 token bridge for the Layer 1 and Layer 2 sides respectively. These two bridge contracts are intertwined, as L1 tokens are locked into the `L1ERC20Bridge` in order to mint the corresponding L2 tokens. Currently, these L1 tokens can only be unlocked in the event of a withdrawal that is initialized through `L2ERC20Bridge`. In the event of an undiscovered bug in the L2 bridge, the only way to upgrade it would be to redeploy a new L1 bridge (since it is not upgradeable).

The new `L1ERC20Bridge` contract would then be intertwined with a new `L2ERC20Bridge`. One drawback of this approach is the inconvenience of re-deploying a new L1 contract every time there is a desire to change the L2 contract. In addition, each ERC-20 token minted on a different L2 bridge would generate a new L2 address, creating multiple copies of the same L1 token in L2. Consider making the `L2ERC20Bridge` upgradable by making it an implementation contract behind a proxy. However, note that even without this upgradeability of the L2 bridge, the upgradeability of the L1 bridge would still prevent L1 tokens from being locked forever.

***Update:** Resolved at commit [b51d4c3](https://github.com/matter-labs/zksync-2-contracts/commit/b51d4c30b05b8cd91356280c1e7a33e6150fd430).*

### Potential EIP-1052 Deviation

On zkSync, the `EXTCODEHASH` opcode is realized by using the [`getCodeHash` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L74) of the `AccountCodeStorage` contract. This returns the registered bytecode hashes for deployed contracts. The [EIP-1052](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1052.md#test-cases) standard dictates that the return of precompile contracts should be either `0` or `c5d246...` (the hash of the empty string). However, precompile code hashes can differ from those values by [setting them](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L34) to their real code hash or to an arbitrary value during a [forced deployment](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L249), thereby causing an inconsistency with EIP-1052.

Consider conforming to EIP-1052 by adding additional checks to ensure that the precompile contracts return either of the values defined in the specification.

***Update:** Resolved in [pull request #213](https://github.com/matter-labs/system-contracts/pull/213) at commit [98cb968](https://github.com/matter-labs/system-contracts/pull/213/commits/98cb9687ca3f2ad1fe8b350ebd8ef942d5bc5bdb). The Matter Labs team stated:*

> *We also added the correct codehash/codesize for the zero-address.*

### Lack of Events

In [`ContractDeployer.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol), there is no event emitted when an [`AccountAbstractionVersion`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L75) or an [`AccountNonceOrdering`] (<https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L81>) are updated, which makes it challenging to monitor whether an account has updated either of these values.

In addition, the [`DepositInitiated` event](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L137) should emit the L2 transaction hash, because it may be [needed](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L188) to claim a failed deposit.

Consider emitting and updating these events to facilitate monitoring.

***Update:** Resolved in [pull request #214](https://github.com/matter-labs/system-contracts/pull/214) at commit [d398cce](https://github.com/matter-labs/system-contracts/pull/214/commits/d398cce18c93e6ff6710a12463ed388fd8a65db2) and [pull request #63](https://github.com/matter-labs/zksync-2-contracts/pull/64) at commit [d0ce4d4](https://github.com/matter-labs/zksync-2-contracts/pull/64/commits/d0ce4d435786cce34b131549f9e5fa3d810caf0d).*

### `setValueUnderNonce` Value Is Mutable

In the `NonceHolder` contract, the `setValueUnderNonce` function [sets a specific `_value`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L85) associated with a particular `_key` (nonce). While setting it to `1` would be enough to simply convey if a specific nonce has already been used, it is actually a `uint256` value. According to the internal documentation shared with us, it “could be used to store some valuable information.” This could correspond to details about the particular transaction that consumed this nonce (e.g., the amount of wei that was sent in the transaction).

While a user cannot reset the `_value` to 0, they can change it to any other non-zero quantity. This can be misleading for external entities that may be relying on it for particular information about the transaction. More importantly, since no event is emitted, an external party may not know that it has been changed.

Consider requiring that the `_value` for a particular `_key` is settable only once. Alternatively, if it is intended to be mutable, consider emitting an event every time it is set.

***Update:** Resolved in [pull request #215](https://github.com/matter-labs/system-contracts/pull/215) at commit [d6fd17d](https://github.com/matter-labs/system-contracts/pull/215/commits/d6fd17d16101075de2929e1d08c418134ea5803a). The Matter Labs team stated:*

> *It is mutable in case users want to store some valuable data under the respective nonce. For example, a user might want to store a mapping such as `(uniqueNonce => someInternalConstant)`.*

### Implicit Zero Cost Assumption

The `L1ERC20Bridge` contract will deploy the Layer 2 token bridge by [passing a request](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L98) to the Mailbox. However, it will not send any ETH. This is acceptable while the [stub fee calculation](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/zksync/facets/Mailbox.sol#L141-L156) uses a zero fee, but when the calculation is updated, messages that do not pay fees [will be rejected](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/zksync/facets/Mailbox.sol#L262).

In the interest of predictability, consider allowing ETH to be sent with the L2 bridge deployment request.

***Update:** Resolved in [pull request #65](https://github.com/matter-labs/zksync-2-contracts/pull/65) at commit [15b3433](https://github.com/matter-labs/zksync-2-contracts/pull/65/commits/15b343399b43ebdfc6b4211fa05e3347b36e7bc3).*

### Floating Pragma Solidity Version

Throughout the [bridge](https://github.com/matter-labs/zksync-2-contracts/tree/9f3c6944e6320166edd96ef6586a9dd4548a27f2) and the [system contracts](https://github.com/matter-labs/system-contracts/tree/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f) codebases, the version of Solidity used is `^0.8.0`. This version indicates that any compiler version after `0.8.0` can be used to compile the source code. However, the code will not compile when using version `0.8.7` or earlier since there are functions which override interface functions without using the keyword `override`. This is only permitted in [Solidity `0.8.8` and above](https://blog.soliditylang.org/2021/09/27/solidity-0.8.8-release-announcement/). In addition, there is the usage of `abi.encodeCall`, which was not introduced until Solidity `0.8.11`. However, it is recommended to use Solidity `0.8.13` or above since there was a [bug detected](https://blog.soliditylang.org/2022/03/16/encodecall-bug/) regarding fixed-length bytes literals. While this bug does not currently affect the codebase, using an updated version will remove the possibility of future errors.

Consider upgrading all contracts to Solidity version `0.8.13` at a minimum, but ideally to the latest version.

***Update:** Resolved in [pull request #66](https://github.com/matter-labs/zksync-2-contracts/pull/66) at commit [e422c7f](https://github.com/matter-labs/zksync-2-contracts/pull/66/commits/e422c7f81dca0e07f4d3ede0e5d7994edcf05a8f). Regarding the floating point Solidity version, the Matter Labs team stated:*

> *System contracts are exposing the System API to smart contract developers, so the code they write will have to adhere to the same compiler version’s limitations. Similarly to OpenZeppelin Smart Contracts libraries, our System Contracts enforce the minimum Solidity version to ensure that they can be properly built, but do not pin a specific version, so we do not prevent the developers from using newer features.*

### Unnecessarily Delayed Error Handling

When depositing ERC-20 tokens, the `L1ERC20Bridge` contract [queries the token’s metadata](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L170-L175), and [sends the results](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L163-L166) to the `L2ERC20Bridge` contract. Any errors are still encoded on L1 and [discarded](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L69-L90) on the L2 bridge. This pattern seems unnecessarily complex, and couples the processing on both sides. Consider detecting errors on L1 and only sending the relevant values over the bridge.

***Update:** Acknowledged, will resolve. The Matter Labs team stated:*

> *We will take this change into account when further refactoring is done.*

## Notes & Additional Information

### Interface Mismatch

The `isNonceUsed` function is defined in the [`NonceHolder` contract](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L145), but it is missing in the [`INonceHolder` interface](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/interfaces/INonceHolder.sol).

Consider aligning the interface with the contract to fully represent its features.

***Update:** Resolved in [pull request #216](https://github.com/matter-labs/system-contracts/pull/216) at commit [c9f1e3c](https://github.com/matter-labs/system-contracts/pull/216/commits/c9f1e3c2df8f19e168093330d0c9c4eecd3257ff).*

### Variable Visibility Not Explicitly Declared

Throughout the [bridge](https://github.com/matter-labs/zksync-2-contracts/tree/9f3c6944e6320166edd96ef6586a9dd4548a27f2) and [system contracts](https://github.com/matter-labs/system-contracts/tree/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f) codebases, there are state variables, constants, and immutables that lack an explicitly declared visibility:

- The immutable [`allowList`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L26) in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol)
- The immutable [`zkSyncMailbox`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L29) in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol)
- The constant [`DEPLOY_L2_BRIDGE_COUNTERPART_ERGS_LIMIT`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L33) in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol)
- The constant [`DEFAULT_ERGS_PRICE_PER_PUBDATA`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L36) in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol)
- The state variable [`l2TokenProxyBytecodeHash`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L26) in [`L2ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol)
- The state variable [`availableGetters`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L24) in [`L2StandardERC20.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol)
- The constant [`EMPTY_STRING_KECCAK`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L22) in [`AccountCodeStorage.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol)
- The state variable [`__DEPRECATED_l2Bridge`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/L2EthToken.sol#L26) in [`L2EthToken.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/L2EthToken.sol)
- The constant [`DEPLOY_NONCE_MULTIPLIER`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L28) in [`NonceHolder.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol)
- The constant [`MAXIMAL_MIN_NONCE_INCREMENT`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L31) in [`NonceHolder.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol)

For clarity, consider always explicitly declaring the visibility of variables, even when the default visibility matches the intended visibility.

***Update:** Acknowledged, will resolve. The Matter Labs team stated:*

> *We will take this change into account when further refactoring is done.*

### Code Redundancy

There are two instances in the codebase where redundant computations are performed:

- In the `ContractDeployer` contract, there is some redundancy in the logic of the [`create{2}{Account}` functions](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L133-L207). Consider highlighting their differences and reusing existing logic by having one function call the other.
- In the `getErgsLimitForTx` function of the bootloader, the [`ergsLimitForTx`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1022) value is computed a second time after being computed as part of the [`getVerifiedOperatorOverheadForTx` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1256). This particularly hinders the visibility of the underflow check.

Consider applying the above changes to improve the code’s clarity.

***Update:** Resolved in [pull request #218](https://github.com/matter-labs/system-contracts/pull/218) at commit [5828dc1](https://github.com/matter-labs/system-contracts/pull/218/commits/5828dc115d6963089b470d40929139c9a3906139).*

### Inexplicit Fail

In the `L2EthToken` contract, if the user attempts to [transfer more funds than owned](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/L2EthToken.sol#L49), the function reverts with a Solidity underflow error. This can result in a confusing user experience. Consider explicitly checking this condition and giving the user a proper revert reason if the transfer fails.

***Update:** Resolved in [pull request #217](https://github.com/matter-labs/system-contracts/pull/217) at commit [d4e019f](https://github.com/matter-labs/system-contracts/pull/217/commits/d4e019f62a9067526bdf2624e5877e8a513bb215).*

### Indecisive License

Throughout the [codebase](https://github.com/matter-labs/system-contracts/tree/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts) there are several files that state an SPDX license identifier of “MIT OR Apache-2.0”.

Consider agreeing on one license per file to prevent confusion on how these files can be used.

***Update:** Resolved in [pull request #226](https://github.com/matter-labs/system-contracts/pull/226) at commit [d7c89a5](https://github.com/matter-labs/system-contracts/pull/226/commits/d7c89a539a824c5ab92a2fc6c1db68b31f20b488).*

### Misplaced Event

The `L2StandardERC20` contract has the [`BridgeInitialization` event](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L12) defined in the contract, while its other events `BridgeMint` and `BridgeBurn` are defined [in the `IL2StandardToken` interface](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/interfaces/IL2StandardToken.sol#L6-L8).

Consider defining events in the same place for better visibility.

***Update:** Resolved in [pull request #67](https://github.com/matter-labs/zksync-2-contracts/pull/67) at commit [1de79d9](https://github.com/matter-labs/zksync-2-contracts/pull/67/commits/1de79d94d9b34243ecbaea52f827049e6dcbcf5e).*

### Gas Optimizations

The following opportunities for gas optimizations were identified:

- In the `L2StandardERC20` contract, the `bridgeInitialize` function checks that the [`l1Address` is not the zero address](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L44). This is to guarantee that the contract has not been initialized before. However, the contract already has the `initializer` modifier, so the `require` statement is redundant.
- The [`l2TokenProxyBytecodeHash`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L26) variable can be made `immutable` since it is only set once in the constructor and there is no functionality to change it. The purpose of this variable is solely to determine the address of the L2 Token.
- In the [`_splitRawNonce` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L171) a division by a power of two is made. Instead, a right shift by the exponent would be cheaper.

Consider making the above changes to reduce gas consumption.

***Update:** Partially resolved in [pull request #68](https://github.com/matter-labs/zksync-2-contracts/pull/68) at commit [b37a19a](https://github.com/matter-labs/zksync-2-contracts/pull/68/commits/b37a19a67d8a7a553f169d40c88a4ce53e253728). The Matter Labs team stated:*

> *We did not implement the second and third suggestions, since `immutable` is more expensive in L2 contracts (see `ImmutableSimulator` contract) and the arithmetic operations are well-optimized by our compiler (LLVM backend!).*

### Inexplicit Disable of Initialization

The `L2StandardERC20` contract is used as the token logic contract for the bridge. Hence, each token is a beacon proxy instance which refers to the logic of the `L2StandardERC20` contract, which is initializable. The actual logic contract [is initialized](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L39) by having the `initializer` modifier on the constructor, to prevent an attacker from initializing it maliciously.

Instead of using the modifier, consider calling the [`_disableInitializers` function](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.8/contracts/proxy/utils/Initializable.sol#L144) of the `Initializable` contract explicitly in favor of readability and clarity.

***Update:** Resolved in [pull request #69](https://github.com/matter-labs/zksync-2-contracts/pull/69) at commit [5db383b](https://github.com/matter-labs/zksync-2-contracts/pull/69/commits/5db383bcb4987074220047c41c0c80a73fc520eb).*

### Inconsistent Usage of Named Return Variables

In the `L1ERC20Bridge` contract, while most functions use named return variables, the [`_depositFunds`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L151) and [`l2TokenAddress`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L281) functions have a return statement instead. On the other hand, the `L2ERC20Bridge` contract mostly uses unnamed return statements, except for the [`_getCreate2Salt`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L129) function. In the `NonceHolder` contract, there are both a named return variable and a return statement in the [`getDeploymentNonce` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L127).

Consider applying one return style for better readability.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *It makes sense to follow one style standard, but in practice, we see that different return methods are convenient in different cases, so for now we will stay with what we have. However, we will rethink this when we begin refactoring the codebase.*

### Inconsistent Declaration of Integers

In the `bootloader` contract, there is an inconsistency in the way memory offsets are declared, with some being expressed in decimals and most others being expressed in hexadecimals. This deviation from a consistent notation can be confusing and make it difficult to understand the purpose and usage of these sizes. For instance:

- [`add(txPtr, 32)` in line 470](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L470)
- [`lt(returnlen, 96)` in line 759](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L759)
- [`sub(returnlen, 0x40)` in line 785](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L785)
- [`returndatacopy(PAYMASTER_CONTEXT_BEGIN_BYTE(), 64, effectiveContextLen)` in line 796](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L796)

Consider using a consistent notation for expressing memory offsets throughout the codebase.

***Update:** Partially resolved in [pull request #219](https://github.com/matter-labs/system-contracts/pull/219) at commit [c022f89](https://github.com/matter-labs/system-contracts/pull/219/commits/c022f89bf7d6178fc2559a05588b59ad20ab8032). There are more instances similar to the examples mentioned above that can be changed with further refactoring.*

### Naming Suggestions

To favor explicitness and readability, there are several locations in the contracts that may benefit from better naming:

- In [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol):
  - The [`txHash`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L125) name is inconsistent with [`_l2TxHash`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L204). Consider renaming it to `l2TxHash` for consistency.
  - The [`l2TokenFactory`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L50) is not the factory, but rather the beacon. In fact, the factory is `L2ERC20Bridge`. Consider renaming it to `l2TokenBeacon`.
  - The [`l2ProxyTokenBytecodeHash`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L53) name is inconsistent with [`l2TokenProxyBytecodeHash`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L26). Consider renaming it to `l2TokenProxyBytecodeHash` for consistency.
- In [`L2ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol):
  - The [`l2TokenFactory`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L23) is not the factory, but rather the beacon. In fact, the factory is `L2ERC20Bridge`. Consider renaming it to `l2TokenBeacon`.
- In [`L2StandardERC20.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol):
  - The [`BridgeInitialization` event](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L12)  is inconsistent with the other events named `BridgeMint` and `BridgeBurn`. Consider renaming it to `BridgeInitialize`.
- In [`AccountCodeStorage.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol):
  - The function [`Utils.isContractConsructing`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L36) is spelled incorrectly. Consider renaming it to `isContractConstructing`.

***Update:** Resolved in [pull request #220](https://github.com/matter-labs/system-contracts/pull/220) at commit [d5bf7da](https://github.com/matter-labs/system-contracts/pull/220/commits/d5bf7da2b782750a22f3ba6677510ce1310d12fc) and [pull request #70](https://github.com/matter-labs/zksync-2-contracts/pull/70/commits/0cb750bef7460a60451ef56258dba9b104c92231) at commit [0cb750b](https://github.com/matter-labs/zksync-2-contracts/pull/70/commits/0cb750bef7460a60451ef56258dba9b104c92231).*

### Unused Imports

Throughout the codebase imports on the following lines are unused and could be removed:

- Import [`IAccountCodeStorage`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L5) of [`ContractDeployer.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol)
- Import [`IKnownCodesStorage`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L6) of [`ContractDeployer.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol)
- Import [`INonceHolder`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L8) of [`ContractDeployer.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol)
- Import [`IL2StandardToken`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/L2EthToken.sol#L5) of [`L2EthToken.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/L2EthToken.sol)
- Import [`IMailbox`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/interfaces/IL1Bridge.sol#L5), [`L2Log`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/interfaces/IL1Bridge.sol#L5), and [`L2Message`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/interfaces/IL1Bridge.sol#L5) of [`IL1Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/interfaces/IL1Bridge.sol)

Consider removing unused imports to avoid confusion that could reduce the overall clarity and readability of the codebase.

***Update:** Resolved in [pull request #221](https://github.com/matter-labs/system-contracts/pull/221) at commit [49dbcf5](https://github.com/matter-labs/system-contracts/pull/221/commits/49dbcf50daef2f38aed2815c81bf4f6321699b5f) and [pull request #71](https://github.com/matter-labs/zksync-2-contracts/pull/71) at commit [53beb18](https://github.com/matter-labs/zksync-2-contracts/pull/71/commits/53beb185ed0e7ac4bcb91fd6d4f517268f410d2e).*

### Theoretical Aggregate ETH Inconsistency

The `forceDeployOnAddresses` function attempts to send [the specified amount of L2 ETH](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L266) with each deployment, after collecting the [aggregate amount](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L263). However, the value sent with each call is [implicitly truncated](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/MsgValueSimulator.sol#L24) to the least significant 128 bits (henceforth, “lower half”). This means the most significant 128 bits (“upper half”) of every `value` parameter is ignored, which has two implications:

- Any deployment that attempts to send more than 2128 Wei will only send the lower half of the amount, leaving the rest in the `ContractDeployer` contract.
- The `FORCE_DEPLOYER` address can manipulate the upper half of the aggregate amount by setting large values that will be truncated. It can also cause the result to overflow, since the summation [occurs inside an `unchecked` block](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L256-L268). If the actual aggregated amount exceeds 2128 Wei and the `FORCE_DEPLOYER` address manipulates the summation to clear the upper half, they will [only need to pay for the lower half](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L263) of the amount. The rest will come out of the `ContractDeployer` contract’s own balance.

In practice, the total supply will be less than 2128 for the foreseeable future, so neither scenario should be possible. In addition, the `FORCE_DEPLOYER` is a trusted address that would not be expected to manipulate the deployment configurations. Nevertheless, all assumptions should be enforced wherever possible. In the interest of predictability and local reasoning, consider restricting the [`ForceDeployment.value` parameter](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L218) to 128 bits. Alternatively, consider requiring the `msg.value` to be less than 2128 Wei instead of truncating it, which would remove the possible inconsistency for all use cases.

***Update:** Resolved in [pull request #222](https://github.com/matter-labs/system-contracts/pull/222) at commit [9600e74](https://github.com/matter-labs/system-contracts/pull/222/commits/9600e748577e4efb4f021e22fea229bb8056efd6). The Matter Labs team stated:*

> *The `msg.value` is not implicitly truncated (if so we would have a larger issue). The compiler checks if the value is less than 2^128, and panics otherwise. The `sumOfValues` overflow was resolved.*

### Checks-Effects-Interactions Recommendation

The `deposit` function of the `L1ERC20Bridge` contract [interacts with an untrusted token](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L121) before updating its own state. Although it is protected by the `nonReentrant` modifier and there are no reentrancy possibilities in the current codebase, as a matter of good practice, consider moving the token transfer to the end of the function to follow the [checks-effects-interactions pattern](https://docs.soliditylang.org/en/v0.8.18/security-considerations.html#use-the-checks-effects-interactions-pattern).

***Update:** Acknowledge, not resolved. The Matter Labs team stated:*

> *We agree that in general it is more appropriate to use patterns wherever possible. However, in our case, to follow the checks-effects-interactions we would need to remove the calculation of the amount of deposited money, as the balance differs before and after. On other hand, it is difficult for us to imagine a reentrancy attack on this contract and we are already defending against this possibility with a `nonReentrant` modifier. As a result, we decided not to implement the fix.*

### Complex Nonce Packing

The `NonceHolder` contract uses a [single storage slot](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L36) to pack each account’s deployment nonce and minimum transaction nonce.

Instead of manually [splitting](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L170) and [recombining](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L139) them, consider defining a struct that holds them both. That struct can then be saved in the `rawNonces` mapping and the individual nonces can be accessed and updated more easily.

***Update:** Acknowledged, will resolve. The Matter Labs team stated:*

> *We will take this change into account when further refactoring is done.*

### Typographical Errors

Throughout the codebase we identified the following typographical errors:

- `that used` → `that is used` in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L28)
- `the transferring funds` → `the transferring of funds` in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L141)
- `which do not` → `which it does not` in [`L2StandardERC20.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol#L15)
- `store` → `stores` in [`L2ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L21)
- `initiate` → `initiated` in [`L2ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L49)
- `Deploys` → `Deploy` in [`L2ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L79)
- `eiher` → `either` in [`NonceHolder.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L17)
- `value value` → `value` in [`NonceHolder.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L19)
- `server` → `serve` in [`NonceHolder.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L24)
- `rather rather` → `rather` in [`NonceHolder.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L24-L25)
- `msg.sneder` → `msg.sender` in [`NonceHolder.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L63)
- `methodd` → `method` in [`NonceHolder.sol`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/NonceHolder.sol#L156)
- `That is means` → `That means` in [`bootloader.yul`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L92)
- `we need to the ability to` → `we need the ability to` in [`bootloader.yul`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L415)
- `transfered` → `transferred` in [`bootloader.yul`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L864)
- `that` → `than` in [`bootloader.yul`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L846-L847)
- `provides provides` → `provides` in [`bootloader.yul`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L2632-L2633)
- [`No colission is not possible`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L106) and [`No colission is possible`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L124) → `No collision is possible` in `ContractDeployer.sol`

Consider correcting these typographical errors.

***Update:** Resolved in [pull request #223](https://github.com/matter-labs/system-contracts/pull/223) at commit [7042d1f](https://github.com/matter-labs/system-contracts/pull/223/commits/7042d1f23cf07baea087feaafa516174e6334239), [pull request #228](https://github.com/matter-labs/system-contracts/pull/228) at commit [5398a91](https://github.com/matter-labs/system-contracts/pull/228/commits/5398a912bfea085fe9eeca3b623c7ca255983156), and [pull request #72](https://github.com/matter-labs/zksync-2-contracts/pull/72) at commit [f0c0544](https://github.com/matter-labs/zksync-2-contracts/pull/72/commits/f0c0544b5c1b266153f7f17e4cb0b57dc3c8f770).*

### Unclean Code

[The line](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/MsgValueSimulator.sol#L25) that extracts the `isSystemCall` flag has two sets of redundant brackets that do not clarify the order of operations.

Consider grouping the bit `AND` operation before the logical `!=` operation, or removing the brackets entirely.

***Update:** Resolved in [pull request #224](https://github.com/matter-labs/system-contracts/pull/224) at commit [ad13199](https://github.com/matter-labs/system-contracts/pull/224/commits/ad13199412a2a9eb9efd99224b42484a0d649ce2).*

### Missing and Misleading Documentation

The following parts of the codebase are lacking documentation:

- The [`_l2TxErgsLimit` parameter](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L118) of the `deposit` function is undocumented.
- The following codes are missing `@param` statements:
  - All parameters of the [`L2StandardERC20` contract](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2StandardERC20.sol).
  - The [`resultPtr` parameter](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L815) of the `processL1Tx` function.
  - The `_aaVersion` parameter of the [`createAccount`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L199) and [`create2Account`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L160) functions.
  - The [`_sender` parameter](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L300) of the `_performDeployOnAddress` function.
- The following functions of the bootloader are undocumented:
  - [`l2TxExecution`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1082)
  - [`l2TxValidation`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1035)
  - [`getErgsLimitForTx`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1003)
  - [`getOperatorRefundForTx`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1236)
  - [`getOperatorOverheadForTx`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1241)
  - [`getVerifiedOperatorOverheadForTx`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L1246)
  - [`l1TxPreparation`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L901)
  - [`SCRATCH_SPACE_BEGIN_BYTE`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L174)

The following documentation is misleading:

- The comment on the [`_l1Token` address](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/zksync/contracts/bridge/L2ERC20Bridge.sol#L51) says “Always should be equal to zero”, which does not make sense.
- The comment on the [`_l2TokenFactory` address](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/bridge/L1ERC20Bridge.sol#L67) says “Pre-calculated address of L2 token beacon proxy”. However, the address is actually that of the `UpgradeableBeacon` contract.
- The comment on the [`L2EthToken` contract](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/L2EthToken.sol#L14) is missing that the bootloader also interacts with it.
- The comment on the [`_hash` parameter](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L31) should state that the account is “constructing” and is not “constructed”.
- The comment on the [`KnownCodeStorage` contract](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/KnownCodesStorage.sol#L13-L14) is wrong since the implementation of the bytecode hash matches [this comment](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/AccountCodeStorage.sol#L12-L13).
- The comment on the [`mint` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/L2EthToken.sol#L56) states to be only callable by the ETH bridge. This is obsolete and should refer to the bootloader now.
- The comment on the [`withdraw` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/L2EthToken.sol#L65) states that funds are claimable through `finalizeWithdrawal`, but the function is actually called [`finalizeEthWithdrawal`](https://github.com/matter-labs/zksync-2-contracts/blob/9f3c6944e6320166edd96ef6586a9dd4548a27f2/ethereum/contracts/zksync/facets/Mailbox.sol#L179).
- The comment on the [`updateNonceOrdering` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L79) ignores the fact that the ordering can only be changed from sequential to arbitrary.
- The comment on the [`createAccount` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L192) claims to accept a “nonce as one of its parameters”, however, salt is meant.
- The comment on the [`MSG_VALUE_SIMULATOR_IS_SYSTEM_BIT` constant](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/Constants.sol#L57) addresses the second `extraAbi` parameter, while it is actually the first.
- The comment mentioning [`NEW_CODE_HASHES_START_PTR` and `MAX_NEW_CODE_HASHES`](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/bootloader/bootloader.yul#L437) does not match any code.
- The comment within the [`getNewAddressCreate` function](https://github.com/matter-labs/system-contracts/blob/191246a878f1493a5ed5f0fa6d79af4ce3e7eb8f/contracts/ContractDeployer.sol#L124) refers to collision resistance with “Ethereum’s CREATE2” but it should be “Ethereum’s CREATE”.

Consider adding more documentation to the codebase to enhance its clarity. In addition, consider rephrasing misleading comments to match the intention of the code.

***Update:** Resolved in [pull request #225](https://github.com/matter-labs/system-contracts/pull/225) at commit [3a28b44](https://github.com/matter-labs/system-contracts/pull/225/commits/3a28b44b0b54d472b5b40eb6db05d4c5ae4f9471), [pull request #218](https://github.com/matter-labs/system-contracts/pull/218) at commit [5828dc1](https://github.com/matter-labs/system-contracts/pull/218/commits/5828dc115d6963089b470d40929139c9a3906139), and [pull request #73](https://github.com/matter-labs/zksync-2-contracts/pull/73) at commit [275d73e](https://github.com/matter-labs/zksync-2-contracts/pull/73/commits/275d73ed41287fcba174ec2f4405b767378fd1a8).*

## Conclusions

This audit was conducted over the course of 4 weeks. Through an in-depth review of the new fee model, we uncovered a high-severity issue and additional attack surfaces. We also identified several medium and lower-severity issues in the system and the bridging contracts. The Matter Labs team provided us with dedicated documentation again, which was very helpful to understand this complex system.

## Appendix

### Monitoring Recommendations

While audits help in identifying code-level issues in the current implementation and potentially the code deployed in production, we encourage the Matter Labs team to consider incorporating monitoring activities in the production environment. Ongoing monitoring of deployed contracts helps in identifying potential threats and issues affecting the production environment. Hence, with the goal of providing a complete security assessment, we want to raise several actions addressing trust assumptions and out-of-scope components that can benefit from on-chain monitoring.

#### Governance

**Critical:** There are multiple privileged actions with serious security implications:

- The owner of the `AllowList` contract controls access to the token bridge functionality, and has the ability to disable withdrawals.
- The various bridge contracts can be upgraded arbitrarily, which implies the power to steal all funds on layer 2.
- The `FORCE_DEPLOYER` address can upgrade any of the system contracts to radically change the behavior of the zkEVM.

Consider monitoring triggers of these administrator functions to ensure all changes are expected.

#### Financial

**Medium:** Consider monitoring the size, cadence and token type of bridge transfers during normal operations to establish a baseline of healthy properties. Any large deviation, such as an unexpectedly large withdrawal, may indicate unusual behavior of the contracts or an ongoing attack.

#### Technical

**High:** All L1 deposits should correspond to tokens minted on L2. Similarly, all tokens burned on L2 should correspond to released tokens on L1. This means every L1 token’s bridge balance should match the corresponding L2 token’s total supply, with some tolerance to account for the time delay of bridge transfers. Consider monitoring that these two values remain acceptably close to each other (for example, within 5%).

#### Suspicious Activity

**Low:** Withdrawals on L1 are not triggered automatically, and must instead be initiated by L1 users. Any withdrawal that takes too long to finalize may indicate a problem with the withdrawal proof. Consider monitoring for withdrawals that remain in transit for significantly longer than the median withdrawal duration.
