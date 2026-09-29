# zkSync Upgrade System Audit

Source: [https://www.openzeppelin.com/news/zksync-upgrade-system-audit](https://www.openzeppelin.com/news/zksync-upgrade-system-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
  - [Privileged Roles](#privileged-roles)
  - [Testing Coverage Recommendations](#testing-coverage-recommendations)
- [High Severity](#high-severity)
  - [Not Setting L2 Upgrade Block Number Prevents Future Upgrades](#not-setting-l2-upgrade-block-number-prevents-future-upgrades)
- [Medium Severity](#medium-severity)
  - [Insufficient Validation of L2 Upgrade Transaction](#insufficient-validation-of-l2-upgrade-transaction)
  - [L2 Upgrade Timing Will Precede L1 Upgrade](#l2-upgrade-timing-will-precede-l1-upgrade)
  - [Reverted L2 Upgrade Block Forces Recommitment of Preceding Blocks with Incorrect Values](#reverted-l2-upgrade-block-forces-recommitment-of-preceding-blocks-with-incorrect-values)
  - [Inadequate Test Coverage](#inadequate-test-coverage)
- [Low Severity](#low-severity)
  - [Lack of Handling for Unrecognized L2 Logs Senders](#lack-of-handling-for-unrecognized-l2-logs-senders)
  - [ComplexUpgrader Does Not Revert on delegatecall to an EOA](#complexupgrader-does-not-revert-on-delegatecall-to-an-eoa)
  - [Missing Docstrings](#missing-docstrings)
  - [Inconsistent Verifier](#inconsistent-verifier)
  - [Missing or Misleading Documentation](#missing-or-misleading-documentation)
  - [Missing Post-update Hook](#missing-post-update-hook)
- [Notes & Additional Information](#notes-additional-information)
  - [Typographical Errors](#typographical-errors)
  - [Duplicate Import](#duplicate-import)
  - [Multiple Contracts With Same Name](#multiple-contracts-with-same-name)
  - [Unused Imports](#unused-imports)
  - [Magic Numbers](#magic-numbers)
  - [Misleading Error Message](#misleading-error-message)
  - [Missing Interface](#missing-interface)
  - [Missing Validation](#missing-validation)
  - [Previously Reported Issues](#previously-reported-issues)
- [Recommendations](#recommendations)
  - [Monitoring Recommendations](#monitoring-recommendations)
- [Conclusions](#conclusions)

## Summary

Type
:   Rollup

Timeline
:   From 2023-06-26
:   To 2023-06-30

Languages
:   Solidity

Total Issues
:   20 (0 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   1 (0 resolved)

Medium Severity Issues
:   4 (0 resolved)

Low Severity Issues
:   6 (0 resolved)

Notes & Additional Information
:   9 (0 resolved)

Client Reported Issues
:   0 (0 resolved)

## Scope

We audited:

- [Pull request #272](https://github.com/matter-labs/system-contracts/pull/272) of the `matter-labs/system-contracts` repository up to the [548a958e02f71a350e288c70e5523fbfb4ae0832](https://github.com/matter-labs/system-contracts/tree/548a958e02f71a350e288c70e5523fbfb4ae0832) commit.
- [Pull request #143](https://github.com/matter-labs/zksync-2-contracts/pull/143) of the `matter-labs/zksync-2-contracts` repository up to the [0ea939847569a02ae9c3b2d096aef5cb6238eb9d](https://github.com/matter-labs/zksync-2-contracts/tree/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts) commit.

In scope were changes to the following contracts:

```
 system-contracts
├── bootloader
│   └── bootloader.yul
└── contracts
    ├── BytecodeCompressor.sol
    ├── ComplexUpgrader.sol
    ├── Constants.sol
    ├── ContractDeployer.sol
    └── interfaces
        └── IComplexUpgrader.sol

zksync-2-contracts
├── ethereum
│   └── contracts
│       ├── common
│       │   └── libraries
│       │       └── L2ContractHelper.sol
│       ├── upgrades
│       │   ├── BaseZkSyncUpgrade.sol
│       │   └── DefaultUpgrade.sol
│       └── zksync
│           ├── Config.sol
│           ├── Storage.sol
│           ├── facets
│           │   ├── Executor.sol
│           │   ├── Getters.sol
│           │   └── Governance.sol
│           ├── interfaces
│           │   └── IGovernance.sol
│           └── libraries
│               └── Diamond.sol
└── zksync
    └── contracts
        ├── DefaultUpgrade.sol
        └── L2ContractHelper.sol
```

## System Overview

The code under review introduces a new L2 transaction type to support upgrade transactions initiated on L1. These are equivalent to the existing L1 (ie. priority) transactions with two important differences.

Firstly, the L2 transaction must be included as soon as the upgrade is processed on L1, and it must be the first transaction in the block. There are some technicalities around handling block reversions but conceptually, it should be viewed as an immediate, forcing transaction.

Secondly, the mechanism that can be used to include an upgrade transaction in L2 is less restrictive than the `Mailbox` (which is used to include priority transactions). In particular, there is no restriction on the sender address or amount of ETH to mint, so it can be used to make arbitrary changes to the L2 contract code. Naturally, this should only be used for breaking changes to the system.

## Security Model and Trust Assumptions

### Privileged Roles

The main change to the security architecture is that the governor can no longer directly set the bootloader and default bytecode hashes, the allowlist address and the verifier configuration. Instead, these changes are mediated through the `DefaultUpgrade` contract, which enforces a time delay. This is part of the Matterlab team's progressive decentralization policy.

However, the upgrade also includes the ability to execute an arbitrary L2 transaction from any address, and this can be used to replace the code of any contract including system contracts. Although this is not meaningfully different than the existing administrator privileges (after all, replacing the bootloader is as powerful), it is worth noting the difference between making irregular transactions within the L2 and making changes to the L2 state transition function itself.

### Testing Coverage Recommendations

Several concerns regarding the testing of the current system were identified during the audit. While one of the findings contains a description of these concerns for the specific contracts within the scope of this audit, it is important to note the overall systematic risks here.

Insufficient testing, while not a specific vulnerability, implies the high probability of additional unfound vulnerabilities and bugs. It also exacerbates multiple interrelated risk factors in a complex codebase with novel functionality. This includes a lack of full implicit specification of the functionality and the expected behaviors that tests normally provide, which increases the chances that issues will be missed. It also requires more effort to establish basic correctness and reduces the effort spent exploring edge cases, thereby increasing the chances of missing complex issues.

Moreover, the lack of repeated automated testing of the full specification increases the chances of introducing breaking changes and new vulnerabilities. This applies to both previously audited code and future changes to currently audited code. This is particularly true in this project due to the pace, extent, and complexity of ongoing and planned changes across all parts of the stack (L1, L2, bootloader and system contracts, compiler and VM). Underspecified interfaces and assumptions increase the risk of subtle integration issues, which testing could reduce by enforcing an exhaustive specification.

To address these issues, we recommend implementing a comprehensive multi-level test suite before the next expected audits. Such a test suite should be comprised of contract-level tests with 95%-100% coverage, per-layer deployment and integration tests that test the deployment scripts as well as the system as a whole, per-layer fork tests for planned upgrades, and cross-chain full integration tests of the entire system. Crucially, the test suite should be documented in a way that a reviewer can set up and run all these test layers independently of the development team. Some existing examples of such setups can be used as references in a follow-up conversation. Implementing such a test suite should be a very high priority to ensure the system's robustness and reduce the risk of vulnerabilities and bugs.

## High Severity

### Not Setting L2 Upgrade Block Number Prevents Future Upgrades

The L2 block at which the L2 update occurs is not properly recorded in `l2SystemContractsUpgradeBlockNumber`. Consequently, [when it is validated](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L196) during subsequent upgrades, it fails, causing the upgrade to revert. Moreover, [this code section](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L215), intended to handle blocks that have been previously reverted, becomes unreachable. Lastly, since `l2SystemContractsUpgradeTxHash` is never reset, the [optimized code path](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L166-L168) for the case when there is no active upgrade also becomes unreachable after any upgrade.

Consider setting `l2SystemContractsUpgradeBlockNumber` during the processing of the upgrade block in `_commitBlocksWithSystemContractsUpgrade`. Subsequently, reset both `l2SystemContractsUpgradeBlockNumber` and `l2SystemContractsUpgradeTxHash` to default values when the upgrade is finalized during `executeBlocks`. Lastly, ensure that the upgrade transaction was reset before the next upgrade in [`_setL2SystemContractUpgrade`](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L143). This process will ensure that only one upgrade is active at a time and that these values are reset when an upgrade is finalized.

We also recommend enforcing proper test coverage. For this case, consider adding tests that exercise all possible control flow branches (e.g., `if` statements, and `require` checks), and validate relevant views and events. Specifically, add scenarios involving multiple subsequent upgrades, their finalization scenarios including possible reverted blocks, and variation in the upgraded functionality (e.g., with or without an L2 update, with or without a verifier update, etc.). Generally, consider enabling the generation of test coverage reports and implementing a policy to flag pull requests with a branch test coverage of less than 95%.

## Medium Severity

### Insufficient Validation of L2 Upgrade Transaction

While standard L1->L2 transactions undergo comprehensive validation logic ([1](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Mailbox.sol#L219-L310), [2](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Mailbox.sol#L355-L368)) in the Mailbox facet, L2 upgrade transactions — though similarly executed — are subject to minimal validation during the upgrade process. Although such transactions are assumed to be vetted off-chain by governor owners, the absence of thorough on-chain validation is error-prone and could have severe consequences on L2. Furthermore, remediation complexity is exacerbated as upgrade transactions cannot be overridden - they [must be finalized](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L194-L200).

Potential issues include minting of L2 ETH not provided in the L1 transaction, which could result in mismatched L1 and L2 ETH balances and potential L2 ETH devaluation. Another potential issue is the submission of a transaction that would be unprovable on L1 or unexecutable on L2.

Existing checks on standard L1-to-L2 transactions include:

- Sender assignment to `msg.sender`, with aliasing if it's a contract.
- Ensuring `l2Value` does not exceed `msg.value` or provided transaction gas costs.
- Confirmation that `valueToMint` matches `msg.value`.
- Setting the refund recipient.
- Verifying expected gas costs to be within acceptable thresholds, ensuring the ability to prove and process.

Consider adding validation checks to confine upgrade transactions within a narrowly defined set of intended actions. Specifically, consider limiting the addresses the upgrade can impersonate (e.g., only the forced deployer system contract), prohibiting ETH minting or value transfers, and enforcing sensible gas limits and costs.

### L2 Upgrade Timing Will Precede L1 Upgrade

The L2 upgrade is enforced on L1 during the block commitment phase in the first committed block [when the transaction is set](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L165). However, due to block commitment delays, the L2 upgrade can have a retroactive effect preceding the L1 upgrade, as recorded by the block timestamps.

One of the primary objectives of the upgrade mechanism is to enforce delayed upgrades, as [validated for the L1 part of the upgrade](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L59). Therefore, it's reasonable to expect the L2 upgrade not to be implemented earlier than the scheduled `upgradeTimestamp`.

Moreover, a malicious operator has the ability to postpone new block postings on L1 within the [permitted commit delays](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L53). This capacity enables the operator to retroactively apply an L2 upgrade considerably earlier than the L1 upgrade and provides them with the power to select the L2 transactions to include before and after the L2 upgrade.

Enforcing a strict lack of "back-dating" may be complex due to the need to avoid committing to blocks [created with a previous bootloader or account code](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L445) if these parameters were changed. However, enforcing a minimal tolerance of, for instance, several minutes, should balance complexity with safety.

Consider enforcing that the L2 upgrade block should have an L2 timestamp not preceding the planned `upgradeTimestamp` by more than a few minutes. Choosing the block based on the L2 timestamp will not only address the timing issue but will also simplify block selection in cases where an operator has reverted any blocks.

### Reverted L2 Upgrade Block Forces Recommitment of Preceding Blocks with Incorrect Values

An L2 upgrade block that has been reverted may prompt the recommitment of the blocks preceding the upgrade. Given that the block height is [enforced based on the previously recorded `l2SystemContractsUpgradeBlockNumber` (prior to being reverted)](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L208-L216), a problem arises if the L1 upgrade updates either the `l2BootloaderBytecodeHash` or `l2DefaultAccountBytecodeHash`. In this case, the blocks preceding the L2 upgrade will be recommitted [with the updated values (from contract storage)](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L445), effectively placing the L2 upgrade before the block in which the L2 upgrade transaction is included.

This situation implies that the L2 upgrade won't be atomic, with the bootloader or default account code being updated an arbitrary number of blocks before the L2 upgrade transaction. Furthermore, this could result in an unprovable or inconsistent state if the upgrade transaction is the one that updates the default account contract code.

Consider avoiding the "replay" of the upgrade at the previously recorded block height, and instead ensure that the `l2SystemContractsUpgradeBlockNumber` is reset if that block is reverted during `revertBlocks`. Also, ensure that `l2SystemContractsUpgradeBlockNumber` is always zero at the start of `_commitBlocksWithSystemContractsUpgrade` to prevent concurrent upgrades or inconsistent upgrade states.

### Inadequate Test Coverage

There are significant gaps in the testing for the current changes. As generating a coverage report is not currently supported, the process of finding these coverage gaps has been manual and potentially error-prone. Consequently, the following list of gaps may not be exhaustive.

Within the scope of L1 contracts:

- Some `require` statements (e.g., [1](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L120), [2](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L173), [3](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L174), [4](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L198)) are not tested.
- Some `view` functions and the corresponding state variables (e.g., [1](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Getters.sol#L137), [2](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Getters.sol#L141)) are not tested.
- Some scenarios, such as reverting blocks and sequential upgrades, are not tested.
- Some events, including most of the [upgrade events](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L36-L55) are not tested.

Within the scope of `system-contracts`, there are very few tests in the repository and no test files updated for this code change.

Within the scope of L2 contracts, there are no tests (and no test updates).

Consider implementing automated measurement of test coverage to ensure 95%-100% branch coverage for all repositories. Crucially, consider ensuring that all code changes that are in the scope of an audit have full branch coverage.

## Low Severity

### Lack of Handling for Unrecognized L2 Logs Senders

Logs within the L2 system are processed based on [their sender's address in the Executor](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L111-L140). However, a potential issue arises if an unrecognized sender requires action or should be rejected. There is also a future risk that the code may need to be updated for new sender scenarios, but without a final `else` block, the necessary action may be overlooked.

Consider including an `else` block that automatically reverts transactions to ensure comprehensive handling both now and in future scenarios. If you anticipate adding more senders that should default to a no action (no-op), consider including in the explicit `else` block detailed comments explaining the expected behavior.

### `ComplexUpgrader` Does Not Revert on `delegatecall` to an EOA

If the `delegatecall` target is not a contract, [the `delegatecall`](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/contracts/ComplexUpgrader.sol#L19-L24) will not revert due to the default account possessing a non-reverting, empty fallback function. The upgrade transaction would not have the intended effect, but it will still appear to have been successfully executed.

Consider reverting whenever the [code size of the target](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/contracts/AccountCodeStorage.sol#L116) is zero. This is consistent with the [existing diamond behavior](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/libraries/Diamond.sol#L286) on layer 1 and standard practice in the ecosystem.

### Missing Docstrings

There are several functions that do not have docstrings. Here is a non-exhaustive list:

- The [`upgrade`](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/contracts/ComplexUpgrader.sol#L13) function of `ComplexUpgrader`
- The [`create2`](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/zksync/contracts/L2ContractHelper.sol#L40) function of `L2ContractHelper`
- The [`getL2SystemContractsUpgradeTxHash`](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Getters.sol#L137) and [`getL2SystemContractsUpgradeBlockNumber`](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Getters.sol#L141) functions of the `Getters` contract

Consider thoroughly documenting all functions as well as their parameters.

### Inconsistent Verifier

If the [verifier is upgraded](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L127), it will immediately be used to [prove all committed blocks](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Executor.sol#L292), including ones that were committed before the upgrade. This could lead to an inconsistency where the blocks cannot be proven. To minimize disruption, the verifier should only be changed when all committed blocks are finalized.

Consider enforcing this property [at upgrade time](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L127). Additionally, consider documenting this requirement in the function comments and any relevant upgrade infrastructure.

### Missing or Misleading Documentation

There are several instances of missing or misleading documentation:

- The [`customUpgradeCalldata` comment](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L21) uses the wrong parameter name.
- The [`executeUpgradeTx` comment](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L16) references a non-existent parameter, which is also referenced by the [`l2ProtocolUpgradeTx` comment](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L14).
- The [`AppStorage` comment](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/Storage.sol#L74) only mentions one of three deprecated parameters.
- The [`NewVerifierParams` comment](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L48) incorrectly references the verifier address.
- The [`_setL2SystemContractUpgrade` function](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L143) is missing its `@return` parameter.

Consider updating the parameters accordingly.

### Missing Post-update Hook

The `DefaultUpgrade` contract [contains a hook](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/DefaultUpgrade.sol#L12) that can be used to perform arbitrary operations during the upgrade. However, it [is executed](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/DefaultUpgrade.sol#L20) after setting the protocol and before all other updates. This limits its ability to perform any post-update configuration, which is the typical use case. Consider executing the function after the rest of the updates, or introducing a new post-update hook.

## Notes & Additional Information

### Typographical Errors

Consider addressing the following typographical errors:

- "[mosst](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/BaseZkSyncUpgrade.sol#L174)" → "most"
- "[the only difference are](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/bootloader/bootloader.yul#L649)" → "the only differences are"
- "[a mapping from facet address to its selector](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/libraries/Diamond.sol#L45)" → "a mapping from facet address to its selectors"

### Duplicate Import

There is a duplicated import of [`Storage`](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/interfaces/IGetters.sol#L5) in the `IGetters.sol` contract.

Consider removing it and updating the explicit import to include all necessary structures.

### Multiple Contracts With Same Name

There are two different contracts that have the same name, yet different responsibilities:

- The [DefaultUpgrader](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/upgrades/DefaultUpgrade.sol#L8) which serves as a template for L1 Diamond upgrades.
- The [DefaultUpgrader](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/zksync/contracts/DefaultUpgrade.sol#L8) which implements force deployment of L2 system contracts.

Consider renaming them to avoid unexpected behavior and improve the overall clarity and readability of the codebase.

### Unused Imports

There are imports that are unused:

- [Lines 5-7](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/interfaces/IGovernance.sol#L5C1-L7C1) of `IGovernance.sol`
- [Line 6](https://github.com/matter-labs/zksync-2-contracts/blob/0ea939847569a02ae9c3b2d096aef5cb6238eb9d/ethereum/contracts/zksync/facets/Governance.sol#L6) of `Governance.sol`

Consider removing unused imports to improve the overall clarity and readability of the codebase.

### Magic Numbers

The bootloader no longer uses the [`L1_TX_TYPE` function](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/bootloader/bootloader.yul#L494) and instead hardcodes the priority and upgrade transaction types when [validating transaction structures](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/bootloader/bootloader.yul#L2765-L2770) and [processing transactions](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/bootloader/bootloader.yul#L647-L661). To improve readability, consider using a named function for both L1 transaction types.

### Misleading Error Message

The `forceDeployOnAddresses` access control [error message](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/contracts/ContractDeployer.sol#L240) is now incorrect, since it can be called by the [`ComplexUpgrader` contract](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/contracts/ComplexUpgrader.sol#L12). Consider updating the error message accordingly.

### Missing Interface

In the interest of readability and consistency, consider updating the [`ComplexUpgrader` contract](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/contracts/ComplexUpgrader.sol#L12) to inherit from [its interface](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/contracts/interfaces/IComplexUpgrader.sol#L5).

### Missing Validation

The `_commitBlockWithSystemContractsUpgrade` function [assumes there is at least one new block](https://github.com/matter-labs/system-contracts/blob/548a958e02f71a350e288c70e5523fbfb4ae0832/contracts/ComplexUpgrader.sol#L12), but this is not enforced. Consider validating this property so it can fail with a descriptive error message.

### Previously Reported Issues

The code under review includes issues that are similar to ones we have previously reported and the Matterlabs team is aware of. Nevertheless, we briefly list them here to raise awareness and to recommend fixing them again:

- Many of the revert messages are not informative.
- Mailbox refund recipient should not be aliased.
- Facet contract names and filenames do not match.
- Custom errors are not used.

## Recommendations

### Monitoring Recommendations

While audits help in identifying code-level issues in the current implementation and potentially the code deployed in production, the Matter Labs team is encouraged to consider incorporating monitoring activities in the production environment. Ongoing monitoring of deployed contracts helps in identifying potential threats and issues affecting the production environment. Here are new recommendations to augment the ones provided in previous audits.

#### Governance

**Critical:** Some administrator privileges have been moved from the `GovernanceFacet` to the `DefaultUpgrade` contract. Consider updating any monitoring of these powers accordingly.

**Critical:** The upgrade function includes the ability to execute an arbitrary transaction on L2 from any sender address, including minting additional ETH. Consider monitoring all upgrade proposals to ensure the changes are expected. In addition, consider monitoring the execution of the L2 upgrade transaction to ensure it succeeds and has the desired effect.

#### Technical

**High:** The new L2 upgrade transaction is intended to occur simultaneously with the L1 updates at a predictable timestamp. Since there are several interacting components, consider monitoring the transaction through its lifecycle to identify any unexpected inconsistencies. In particular, we recommend reviewing:

- Any difference between the L1 and L2 timestamps when the upgrade occurs.
- Any reverted blocks that occur between the L1 upgrade and the finalization of the L2 upgrade transaction, particularly any reverted block that contains the upgrade transaction.

## Conclusions

One high-severity and several medium-severity issues were identified. A comprehensive multi-level test suite with high coverage is strongly recommended before the next audits, to ensure robustness and reduce the risk of further vulnerabilities. The Matter Labs team has been very diligent, as usual, in helping our auditors navigate this codebase.
