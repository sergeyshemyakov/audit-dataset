# Short-Term Fee Model Changes Audit

Source: [https://www.openzeppelin.com/news/short-term-fee-model-changes-audit](https://www.openzeppelin.com/news/short-term-fee-model-changes-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Trust Assumptions](#trust-assumptions)
- [Low Severity](#low-severity)
  - [Issues Discovered in v1.4.1-integration Diff Audit](#issues-discovered-in-v141-integration-diff-audit)
  - [Outdated Version of OpenZeppelin Contracts Library Used](#outdated-version-of-openzeppelin-contracts-library-used)
  - [Missing Input Validation](#missing-input-validation)
  - [Missing Tests](#missing-tests)
- [Notes & Additional Information](#notes-additional-information)
  - [Base Fee Calculated Outside of Proved Batch](#base-fee-calculated-outside-of-proved-batch)
  - [Unused Code](#unused-code)
  - [Naming Suggestions](#naming-suggestions)
- [Conclusion](#conclusion)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-12-06
:   To 2023-12-13

Languages
:   Solidity, Yul

Total Issues
:   7 (7 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   0 (0 resolved)

Low Severity Issues
:   4 (4 resolved)

Notes & Additional Information
:   3 (3 resolved)

## Scope

We audited the changes made to the short-term fee model in:

- The [matter-labs/era-contracts](https://github.com/matter-labs/era-contracts) repository at commit [2e0734b](https://github.com/matter-labs/era-contracts/tree/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33)
- The [matter-labs/era-system-contracts](https://github.com/matter-labs/era-system-contracts) repository at commit [0b238cd](https://github.com/matter-labs/era-system-contracts/tree/0b238cdf831f809584fec3131904d77987b7368d)

In scope were the following contracts:

Repository `era-contracts`:

```
 ethereum
└── contracts
    └── zksync
        ├── facets
        │   ├── Admin.sol
        │   ├── Base.sol
        │   ├── Executor.sol
        │   ├── Getters.sol
        │   └── Mailbox.sol
        ├── interfaces
        │   ├── IAdmin.sol
        │   ├── IExecutor.sol
        │   ├── IGetters.sol
        │   ├── ILegacyGetters.sol
        │   ├── IMailbox.sol
        │   ├── IVerifier.sol
        │   └── IZkSync.sol
        └── libraries
            └── TransactionValidator.sol
```

Repository `era-system-contracts`:

```
 ├── bootloader
│   └── bootloader.yul
└── contracts
    ├── Compressor.sol
    ├── L1Messenger.sol
    └── interfaces
        └── IMailbox.sol
```

## System Overview

The system upgrade introduces changes to the short-term fee model. With the new implementation on Layer 2 (L2), the operator is responsible for providing two variable values: L2 gas price and pubdata price. On Layer 1 (L1), these values are calculated within the contracts. The L2 gas price is expected to include the potential contribution of the usage of a single gas unit for sealing the batch. It is calculated based on the configurable minimal calculation cost, batch overhead, and the gas needed to seal the batch.

The pubdata price is expected to include the potential contribution of the usage of a single pubdata byte for sealing the batch. It is calculated based on the gas price on L1 and the maximum number of pubdata that can be published in a single batch. This provides a high degree of flexibility to the operator and can be adjusted according to market conditions.

## Trust Assumptions

This upgrade does not introduce new roles to the system. A new administrative functionality of changing fee parameters for L1-to-L2 transactions has been added, and can only be executed by an account having the `Governor` role. Thus, any account possessing the `Governor` role is considered to be a trusted party.

## Low Severity

### Issues Discovered in `v1.4.1-integration` Diff Audit

The short-term fee model changes are derived from the code present in the `era-contract` repository, in the `v1.4.1-integration` branch, at commit [`518bfff`](https://github.com/matter-labs/era-contracts/tree/518bfff51085743dc85d2824d823aaf4bb3e82d8), and in the `era-system-contracts` repository, at commit [`ef0eb0c`](https://github.com/matter-labs/era-system-contracts/commit/ef0eb0c7b60d93e267c782b5ae9810f1bb13c05c). Consequently, all issues identified in the `v1.4.1-integration` audit must be incorporated into the short-term fee model.

Consider merging all fixes from the `v1.4.1-integration` branch audit into the `sb-short-term-fee-model` branch of the `era-contracts` and `era-system-contracts` repositories.

***Update:** Resolved in [pull request #160](https://github.com/matter-labs/era-contracts/pull/160) at commit [4e1dfc7](https://github.com/matter-labs/era-contracts/pull/160/commits/4e1dfc79faa2bbea7954d2744ea536b0e7336357) and [pull request #105](https://github.com/matter-labs/era-system-contracts/pull/105) at commit [d85d7d0](https://github.com/matter-labs/era-system-contracts/pull/105/commits/d85d7d04c78410136ce90e88ddaa6555d3e89b07).*

### Outdated Version of OpenZeppelin Contracts Library Used

The short-term fee model upgrade involves updating the OpenZeppelin Contracts library from version `4.8.0` to [`4.9.2`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/package.json#L12-L13). However, the latest version of the OpenZeppelin Contracts library is `4.9.5` which addresses several security issues.

While these security issues do not directly impact the current implementation of the contracts in scope, consider updating the library to the newest version.

***Update:** Resolved in [pull request #128](https://github.com/matter-labs/era-contracts/pull/128) at commit [bf5905d](https://github.com/matter-labs/era-contracts/pull/128/commits/bf5905d55cbe621cbbffb53fddc2e7e651882dbc).*

### Missing Input Validation

In the `Admin` contract, the [`changeFeeParams`](https://github.com/matter-labs/era-contracts/blob/20828999c1076012848304372e7270281ee158bd/ethereum/contracts/zksync/facets/Admin.sol#L92) function, callable by the Governor, modifies the [parameters](https://github.com/matter-labs/era-contracts/blob/20828999c1076012848304372e7270281ee158bd/ethereum/contracts/zksync/Storage.sol#L89) for deriving the gas price in L1-to-L2 transactions. To prevent potential system failure due to misconfiguration, it is recommended to [validate](https://github.com/matter-labs/era-contracts/blob/20828999c1076012848304372e7270281ee158bd/ethereum/contracts/zksync/Storage.sol#L84-L86) whether the provided value for `maxPubDataPerBatch` exceeds `priorityTxMaxPubdata`.

Consider validating the input values for `maxPubDataPerBatch` and `priorityTxMaxPubdata` to prevent misconfigurations.

***Update:** Resolved in [pull request #129](https://github.com/matter-labs/era-contracts/pull/129) at commit [d59b22d](https://github.com/matter-labs/era-contracts/pull/129/commits/d59b22db3991bbe88fdbab082297fd82f7c50b73).*

### Missing Tests

The proposed changes to the short-term fee model lack tests that could confirm the correctness of the implementation. The following areas require additional testing:

- The [`changeFeeParams`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/facets/Admin.sol#L92-L97) function of the [`Admin`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/facets/Admin.sol) contract
- The new short-term fee model changes added to the [`bootloader`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/bootloader/bootloader.yul)

Consider adding tests to enhance the quality and safety of the codebase.

***Update:** Resolved in [pull request #95](https://github.com/matter-labs/era-system-contracts/pull/95) at commit [80b1869](https://github.com/matter-labs/era-system-contracts/pull/95/commits/80b18692cd8fbe41e3b7af66fb1cd5ec9066a457), [pull request #131](https://github.com/matter-labs/era-contracts/pull/131) at commit [85a1b12](https://github.com/matter-labs/era-contracts/pull/131/commits/85a1b12e282bb5e421d83caddd215c7ce8ad04a9).*

## Notes & Additional Information

### Base Fee Calculated Outside of Proved Batch

The logic of calling [`getFeeParams`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/bootloader/bootloader.yul#L3718-L3723) function and calculating the `baseFee` is implemented outside of the proved batch section. This leads to a scenario whereby the `baseFee` is calculated for the playground batch as well.

Consider moving the initialization of `baseFee` and the calling of `getFeeParams` to the proved batch section.

***Update:** Resolved in [pull request #93](https://github.com/matter-labs/era-system-contracts/pull/93) at commit [2546b0a](https://github.com/matter-labs/era-system-contracts/pull/93/commits/2546b0ae3f5f349113ebc46c233dada871f54564).*

### Unused Code

Throughout the codebase, there are multiple instances of unused code:

- The [`getBatchOverheadEth`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/bootloader/bootloader.yul#L1909-L1913) function of `bootloader`
- The result of calculating [`txGasLimit`](https://github.com/matter-labs/era-system-contracts/blob/0b238cdf831f809584fec3131904d77987b7368d/bootloader/bootloader.yul#L1698)

Consider removing all unused code to improve the readability and clarity of the codebase.

***Update:** Resolved in [pull request #94](https://github.com/matter-labs/era-system-contracts/pull/94) at commit [fc9ba75](https://github.com/matter-labs/era-system-contracts/pull/94/commits/fc9ba75ed80e3e7374890f5f1bdb019703cc45f1).*

### Naming Suggestions

In the [`Mailbox`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/facets/Mailbox.sol) contract, the parameter `_gasPricePerPubdata` of the [`_deriveL2GasPrice`](https://github.com/matter-labs/era-contracts/blob/2e0734b1ff9cbf3a88aadba6a19c4c4bc8645d33/ethereum/contracts/zksync/facets/Mailbox.sol#L165) function has a misleading name. Despite its current name, it does not represent a price in wei but rather a gas value per pubdata byte. The given name is rather unintuitive and makes the code harder to read.

Consider renaming the `_gasPricePerPubdata` parameter for improved readability.

***Update:** Resolved in [pull request #130](https://github.com/matter-labs/era-contracts/pull/130) at commit [9e45fb4](https://github.com/matter-labs/era-contracts/pull/130/commits/9e45fb49bc2fd6cbb235b78133a59a4dbce32ca5).*

## Conclusion

The system upgrade alters the short-term fee model on L2, shifting responsibility to the operator for determining L2 gas price and pubdata values. Unlike L1, these values on L2 factor in sealing batch costs, providing flexibility based on market conditions.

The audit did not reveal any significant issues with the changes made to the short-term fee model. Various recommendations have been made to enhance the quality and documentation of the codebase. We found the dedicated documentation provided by Matter Labs team to be very helpful in understanding the audited code changes. Furthermore, the Matter Labs team was very responsive throughout the audit period and answered any questions we had in a timely manner.
