# zkSync L1Messenger Upgrade Audit

Source: [https://www.openzeppelin.com/news/zksync-l1messenger-upgrade-audit](https://www.openzeppelin.com/news/zksync-l1messenger-upgrade-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Trust Assumptions](#trust-assumptions)
- [High Severity](#high-severity)
  - [Lack of Data Availability of Bytecode](#lack-of-data-availability-of-bytecode)
- [Medium Severity](#medium-severity)
  - [Gas Charged Twice for Sending Message to L1](#gas-charged-twice-for-sending-message-to-l1)
  - [Naming Error](#naming-error)
- [Low Severity](#low-severity)
  - [Missing Error Messages in require Statements](#missing-error-messages-in-require-statements)
  - [Use of Magic Numbers](#use-of-magic-numbers)
  - [Misleading Comment](#misleading-comment)
  - [Improper Hash Value for Unused Leaves in Merkle Tree](#improper-hash-value-for-unused-leaves-in-merkle-tree)
- [Notes & Additional Information](#notes-additional-information)
  - [Non-Explicit Imports Are Used](#non-explicit-imports-are-used)
  - [State Variable Visibility Not Explicitly Declared](#state-variable-visibility-not-explicitly-declared)
  - [Using uint Instead of uint256](#using-uint-instead-of-uint256)
  - [Naming Suggestions](#naming-suggestions)
  - [Lack of Security Contact](#lack-of-security-contact)
  - [Inconsistency Between Decimal and Hex Representation](#inconsistency-between-decimal-and-hex-representation)
  - [Unused Imports](#unused-imports)
- [Conclusions](#conclusions)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-08-30
:   To 2023-09-14

Languages
:   Solidity

Total Issues
:   14 (14 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   1 (1 resolved)

Medium Severity Issues
:   2 (2 resolved)

Low Severity Issues
:   4 (4 resolved)

Notes & Additional Information
:   7 (7 resolved)

Client Reported Issues
:   0 (0 resolved)

## Scope

We audited the `matter-labs/system-contracts` repository in [pull request #283](https://github.com/matter-labs/system-contracts/pull/283) at commit [4dca36d](https://github.com/matter-labs/system-contracts/tree/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2). The following files were in scope:

```
 ├── bootloader
│   └── bootloader.yul
├── contracts
│   ├── ComplexUpgrader.sol
│   ├── Compressor.sol
│   ├── Constants.sol
│   ├── ContractDeployer.sol
│   ├── KnownCodesStorage.sol
│   ├── L1Messenger.sol
│   ├── L2EthToken.sol
│   └── SystemContext.sol
├── interfaces
│   ├── IComplexUpgrader.sol
│   ├── ICompressor.sol
│   ├── IKnownCodesStorage.sol
│   ├── IL1Messenger.sol
│   ├── ISystemContext.sol
│   └── ISystemContract.sol
└── libraries
    ├── SystemContractHelper.sol
    └── UnsafeBytesCalldata.sol
```

Additionally, we audited the `matter-labs/zksync-2-contracts` repository for [pull request #165](https://github.com/matter-labs/zksync-2-contracts/pull/165) at commit [098bc7e](https://github.com/matter-labs/zksync-2-contracts/tree/098bc7ee2d13f78d365c386a8d27c1ae09b31164). The following files were in scope:

```
 ethereum
└── contracts
    ├── common
    │   └── L2ContractAddresses.sol
    └── zksync
        ├── Config.sol
        ├── DiamondInit.sol
        ├── facets
        │   ├── Executor.sol
        │   └── Mailbox.sol
        └── interfaces
            └── IExecutor.sol
```

## System Overview

The system upgrade introduces two major changes to the protocol. The first major change is the handling of logs and the delineation between system and user logs. The second change is how state diffs will be handled by the system. The motivation behind these changes primarily revolves around moving certain verifications from the circuit to the smart contracts for ease of upgradeability in the future if necessary. Furthermore, these changes were made as a first step in preparation for EIP-4844, where certain types of data will be placed into the blob while others will continue being part of the calldata.

In this upgrade, the `L1Messenger` contract maintains three rolling hashes: one of the L2 to L1 logs, one of the messages, and one of the bytecode hashes. At the end of bootloader execution, these hashes are validated and then sent to L1 as system logs along with a hash of the state diff. The sequencer, when committing blocks onto L1, submits the preimages as calldata to ensure data availability.

In order to save gas, the bytecode and state diffs that are submitted as pubdata are compressed. The `Compressor` system contract validates that the compression is reflective of the original data, while the ZK proof is still tasked with verifying the correctness of execution. More specifically, with these changes, the operator would provide both full and compressed state diffs to the `Compressor` contract which would verify that the compression matches the original state diffs. Subsequently, the `L1Messenger` will send a system log to L1 with the hash of the original state diffs, as well as the hash of the logs, messages, and the bytecode hashes. When committing a block on L1, the operator would provide the full preimage of all these hashes in the calldata.

## Trust Assumptions

This upgrade does not introduce new roles to the system. As before, the operator role is in control of the inputs to the bootloader as well as the proof generation. They are bound to only generate valid proofs secured by cryptography but are trusted not to censor any transactions. Currently, the operator is centralized through Matter Labs with the goal of decentralizing it in the medium-term future.

## High Severity

### Lack of Data Availability of Bytecode

For rollups, it is crucial to have data availability on the L1 chain. In a ZK-rollup, the validity proof ensures that the L2 sequencer cannot create invalid transactions. However, if the sequencer were to go down or become malicious, having only the proof itself would be insufficient for another node to reconstruct the state on L2. In addition, data availability of bytecode is essential to ensure that not only the state on L2 is able to be reconstructed, but also that the deployed contracts will maintain integrity should the L2 sequencer go down. Furthermore, in the current design with a centralized sequencer, this plays an even more important role as there is a single point of failure.

In the design of the protocol, transactions on L2 can originate from L1 or L2. If a message starts from L1, it is not necessary to resend the bytecode back down to L1, as the bytecode is already available on that layer. However, if a transaction starts on L2 and deploys a new contract, the bytecode must be sent to L1 to ensure data availability.

Currently, a transaction on L2 gets processed by the bootloader using the [`processL2Tx` function](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L1088-L1140). Stepping into this function eventually leads to a call to [`publishCompressedBytecode` in `Compressor`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Compressor.sol#L40-L68). After verifying that the original bytecode and the compressed version of the bytecode match, the function [`markBytecodeAsPublished` is called in `KnownCodesStorage`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/KnownCodesStorage.sol#L39-L41). This makes a call to `_markBytecodeAsPublished` with the variable `_shouldSendToL1` set as false. Therefore, the step to [`requestBytecodeL1Publication` will be skipped](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/KnownCodesStorage.sol#L50-L52) and the bytecode will not be sent to L1.

For transactions that originate on L2, consider making the bytecode available on L1 to ensure data availability.

***Update:** Resolved in [pull request #332](https://github.com/matter-labs/system-contracts/pull/332) at commit [801b2a2](https://github.com/matter-labs/system-contracts/commit/801b2a2ebc540fa6c0f0b87f7525d8f94012cc2a). The raw compressed data is now sent to L1 in the `publishCompressedBytecode` function.*

## Medium Severity

### Gas Charged Twice for Sending Message to L1

The [`sendToL1`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L109-L161) function of the [`L1Messenger`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L109-L161) contract deployed on L2 facilitates the direct transmission of messages to L1. To execute this operation successfully and publish data, it requires the user to provide gas. However, the [calculated amount of gas](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L143-L148) is charged twice. Initially, gas is consumed through the [`SystemContractHelper`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L149) library, utilizing the [`burnGas`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol#L345-L351) function, and subsequently, another gas charge occurs through a direct [call to the precompile](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L152-L155) at address 0.

Consider eliminating the direct call to the precompile address and charging gas only once by using the `burnGas` function provided in the `SystemContractHelper` library.

***Update:** Resolved in [pull request #331](https://github.com/matter-labs/system-contracts/pull/331) at commit [b351f13](https://github.com/matter-labs/system-contracts/commit/b351f1386ddc738567d6ff41e02e937269f000de). The redundant precompile call was removed and the gas is charged once through the `burnGas` function of the `SystemContractHelper` library.*

### Naming Error

Within the `bootloader.yul` code, two instances referencing non-existent variables and functions were identified. Compiling the code will lead to a compilation error, as the referred variable and function names lack definitions:

- The unknown variable [`SHOULD_SET_NEW_BLOCK`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L3656) is used for the `switch` statement. The correct name of the variable is [`SHOULD_SET_NEW_BATCH`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L3654C21-L3654C41), which is defined in the statement above the `switch` block.
- The unknown function [`MAX_PUBDATA_PER_BLOCK`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L2502) is called. The correct name of the defined function is [`MAX_PUBDATA_PER_BATCH`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L80-L82).

Consider implementing these changes in the aforementioned instances to ensure that the correct variables and functions are referenced.

***Update:** Resolved in [pull request #330](https://github.com/matter-labs/system-contracts/pull/330) at commit [0027afa](https://github.com/matter-labs/system-contracts/commit/0027afa84c2928c241cf57485a0f634cabc25eff).*

## Low Severity

### Missing Error Messages in `require` Statements

The [`unsafePrecompileCall`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol#L146-L158) and [`precompileCall`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol#L166-L169) functions of the [`SystemContractHelper`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol) contract use `require` statements that lack descriptive error messages. This can make debugging difficult if the affected functions revert.

These are the dentified instances:

- The `require` statement on [line 151](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol#L151) of [`SystemContractHelper.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol)
- The `require` statement on [line 167](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol#L167) of [`SystemContractHelper.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol)

Consider including specific, informative error messages in `require` statements to improve the overall clarity of the codebase and facilitate troubleshooting whenever a requirement is not satisfied.

***Update:** Resolved in [pull request #333](https://github.com/matter-labs/system-contracts/pull/333) at commit [2deaa57](https://github.com/matter-labs/system-contracts/commit/2deaa57fb6220c5785b54413f920069655543b65). The functions that utilized `require` statements without error messages have been deleted.*

### Use of Magic Numbers

Magic numbers are used throughout the codebase. This practice is generally discouraged in software development as it can lead to issues when refactoring code, particularly if the magic value is used in more than one location. These are some examples where magic values are used in the codebase:

- In [line 93 of `Compressor.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Compressor.sol#L93), the right-hand side uses the magic numbers 4 and 64. Consider replacing 4 with `compInitialStateDiffPtr` and 64 with a constant that represents the size of the initial write, such as `SIZE_OF_INITIAL_WRITE`.
- In [line 114 of `Compressor.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Compressor.sol#L114), the same magic values of 4 and 64 are used.

Consider updating these magic numbers with a constant that represents their value and storing that constant in the `Constants.sol` file so that any updates only need to take place in one location in the codebase.

***Update:** Resolved in [pull request #334](https://github.com/matter-labs/system-contracts/pull/334) at commit [f681c23](https://github.com/matter-labs/system-contracts/commit/f681c23bef9dbbefc61803fc0e75f1f0676c3b53).*

### Misleading Comment

In [line 484 of `Executor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol#L484), it says "Returns if the bit at index {\_index} is 1". It should instead say "Returns true if the bit at index {\_index} is 1".

Consider resolving this instance of misleading documentation to improve the clarity and readability of the codebase.

***Update:** Resolved in [pull request #219](https://github.com/matter-labs/zksync-2-contracts/pull/219) at commit [59fd7f2](https://github.com/matter-labs/zksync-2-contracts/commit/59fd7f2a97d79d8c8e2c04f3ce856d1eda49f601).*

### Improper Hash Value for Unused Leaves in Merkle Tree

The leaves of the Merkle tree that are not used by the L2 logs are [set to the default value `L2_L1_LOGS_TREE_DEFAULT_LEAF_HASH`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L225), which is equal to the hash of the all-zero byte string [`keccak256(new bytes(L2_TO_L1_LOG_SERIALIZE_SIZE))`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/interfaces/IL1Messenger.sol#L29-L30). It is best practice not to set a default hash to a value where the preimage is known. While a malicious bootloader cannot prepare an array of logs each having a hash equal to `L2_L1_LOGS_TREE_DEFAULT_LEAF_HASH` (i.e., the preimage of each hash is the all-zero byte string) and have it emitted due to other safeguards in the system contracts, it is still discouraged to use this value, as future upgrades to the codebase could potentially impact these safeguards.

Instead of `L2_L1_LOGS_TREE_DEFAULT_LEAF_HASH`, consider using `L2_L1_LOGS_TREE_DEFAULT_LEAF_HASH - 1` for the value of the unused leaves. This value would most likely have an unknown preimage, which would further protect against a malicious operator should the codebase be changed.

***Update:** Resolved in [pull request #341](https://github.com/matter-labs/system-contracts/pull/341) at commit [c405437](https://github.com/matter-labs/system-contracts/commit/c405437eb8f22023f34df2b8b7d2df4e592ad031).*

## Notes & Additional Information

### Non-Explicit Imports Are Used

The use of non-explicit imports in the codebase can decrease the clarity of the code and may create naming conflicts between locally defined and imported variables. This is particularly relevant when multiple contracts exist within the same Solidity files or when inheritance chains are long. The following instances were identified:

In [`zksync-2-contracts`](https://github.com/matter-labs/zksync-2-contracts/pull/165/files):

- [Line 5 to Line 9](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/DiamondInit.sol#L5-L9) of [`DiamondInit.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/DiamondInit.sol)
- [Line 5](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/DiamondProxy.sol#L5) of [`DiamondProxy.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/DiamondProxy.sol)
- [Line 5 to Line 12](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol#L5-L12) of [`Executor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol)
- [Line 5 to Line 15](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Mailbox.sol#L7-L15) and [Line 17 to Line 18](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Mailbox.sol#L17-L18) of [`Mailbox.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Mailbox.sol)
- [Line 5](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/interfaces/IExecutor.sol#L5) of [`IExecutor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/interfaces/IExecutor.sol)

In [`system-contracts`](https://github.com/matter-labs/system-contracts/pull/283/files):

- [Line 5](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/ComplexUpgrader.sol#L5) of [`ComplexUpgrader.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/ComplexUpgrader.sol)
- [Line 5 to Line 9](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Compressor.sol#L5-L9) of [`Compressor.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Compressor.sol)
- [Line 5 to Line 15](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Constants.sol#L5-L15) of [`Constants.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Constants.sol)
- [Line 6](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/ContractDeployer.sol#L6), [Line 9 to Line 10](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/ContractDeployer.sol#L9-L10) and [Line 12](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/ContractDeployer.sol#L12) in [`ContractDeployer.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/ContractDeployer.sol)
- [Line 5 to Line 8](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/KnownCodesStorage.sol#L5-L8) of [`KnownCodesStorage.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/KnownCodesStorage.sol#L5-L8)
- [Line 5 to Line 8](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L5-L8) of [`L1Messenger.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol)
- [Line 7](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol#L7) of [`SystemContractHelper.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol)

Following the principle that clearer code is better code, consider using named import syntax *(`import {A, B, C} from "X"`)* to explicitly declare which contracts are being imported.

***Update:** Resolved in [pull request #220](https://github.com/matter-labs/zksync-2-contracts/pull/220) at commit [3db8f16](https://github.com/matter-labs/zksync-2-contracts/commit/3db8f167ec0456f4147ec7631c563cf56f036a2f) and [pull request #335](https://github.com/matter-labs/system-contracts/pull/335) at commit [b2d76b7](https://github.com/matter-labs/system-contracts/commit/b2d76b7dea9b8e58460036c936b05589ef283f43).*

### State Variable Visibility Not Explicitly Declared

Throughout the protocol, the visibility of state variables is explicitly declared, but within the [`L2EthToken.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L2EthToken.sol) contract, the state variable [`balance`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L2EthToken.sol#L20) is missing such a declaration.

For clarity, consider always explicitly declaring the visibility of variables, even when the default visibility matches the intended visibility.

***Update:** Resolved in [pull request #336](https://github.com/matter-labs/system-contracts/pull/336) at commit [032c88a](https://github.com/matter-labs/system-contracts/commit/032c88a3e5cd8f0600c52eadc48971290cdd306e).*

### Using `uint` Instead of `uint256`

Throughout the protocol, the type `uint256` is used, with the exception of the [`L1Messenger.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol) contract where [`uint`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L230) is used instead.

To improve the codebase's quality and in favor of explicitness, consider replacing all instances of `int/uint` with `int256/uint256`.

***Update:** Resolved in [pull request #337](https://github.com/matter-labs/system-contracts/pull/337) at commit [0b29a6a](https://github.com/matter-labs/system-contracts/commit/0b29a6ada8a39ba6975650adee99a4ffc4b99acd).*

### Naming Suggestions

To favor explicitness and readability, the following locations in the contracts may benefit from better naming:

- The enum `SystemLogKey` in [`IExecutor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/interfaces/IExecutor.sol#L16) and in [`Constants.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Constants.sol#L90) has a value named `EXPECTED_SYSTEM_CONTRACT_UPGRADE_TX_HASH`. Consider renaming this to `EXPECTED_SYSTEM_CONTRACT_UPGRADE_TX_HASH_KEY` to be consistent with the other values in the enum.
- The enum [`SystemLogKey` in `Constants.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/Constants.sol#L87) has a value `PREV_BATCH_HASH_KEY`. Consider renaming this to `PREV_BLOCK_HASH_KEY` to be more aligned with its intention and to be consistent with the value in [`IExecutor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/interfaces/IExecutor.sol#L13)
- The function [`_setBit` in `Executor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol#L490) takes in a parameter named `_num`, which represents a bitmap. Consider renaming this to `_bitMap` to provide more clarity on the purpose of this parameter.
- The function [`publishPubdataAndClearState`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L1Messenger.sol#L288) has a local variable named `compressedRepeatedStateDiffs`. Consider renaming this to `compressedStateDiffs`, as this variable stores both the repeated and initial state diffs.

Consider implementing these naming modifications to improve the consistency and readability of the codebase.

***Update:** Resolved in [pull request #221](https://github.com/matter-labs/zksync-2-contracts/pull/221) at commit [f9f39bc](https://github.com/matter-labs/zksync-2-contracts/commit/f9f39bc81c2d9863fa5ed55abcc6eadca6383120) and [pull request #338](https://github.com/matter-labs/system-contracts/pull/338) at commit [07647f8](https://github.com/matter-labs/system-contracts/commit/07647f8e399d615a1f85ed3c560017a13f1c26ab).*

### Lack of Security Contact

Providing a specific security contact, such as an email or ENS, within a smart contract significantly simplifies the process for individuals to communicate if they identify a vulnerability in the code. This practice proves beneficial as it permits the code owners to dictate the communication channel for vulnerability disclosure, eliminating the risk of miscommunication or failure to report due to a lack of knowledge on how to do so. Additionally, if the contract incorporates third-party libraries and a bug surfaces in these, it becomes easier for the creators of those libraries to make contact, inform the code owners about the problem, and provide mitigation instructions.

Consider adding a NatSpec comment on top of the contracts' definition with a security contact. Using the `@custom:security-contact` convention is recommended as it has been adopted by the [Openzeppelin Wizard](https://wizard.openzeppelin.com/) and the [ethereum-lists](https://github.com/ethereum-lists/contracts#tracking-new-deployments).

***Update:** Resolved in [pull request #223](https://github.com/matter-labs/zksync-2-contracts/pull/223) at commit [2fc13dd](https://github.com/matter-labs/zksync-2-contracts/commit/2fc13dd17f64a46fc17daa9de5478775e11c2c1d) and [pull request #342](https://github.com/matter-labs/system-contracts/pull/342) at commit [`a60dbae`](https://github.com/matter-labs/system-contracts/commit/a60dbae31ee351983ce7272fecb392fc130d4617).*

### Inconsistency Between Decimal and Hex Representation

In [bootloader.yul](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul), there are instances where the `add` function is called with one operand equal to `32` typed in decimal as `add(txDataOffset, 32)`, while in other places the operand is typed in hexadecimal as `add(txDataOffset, 0x20)`. Some examples of the decimal representation (`32`) are in [line 846](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L846), [line 869](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L869) and [line 1094](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L1094). Some examples of the hexadecimal representation (`0x20`) are in [line 561](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L561), [line 673](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L673) and [line 688](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/bootloader/bootloader.yul#L688).

Consider using a single representation throughout the implementation for consistency and readability.

***Update:** Resolved in [pull request #339](https://github.com/matter-labs/system-contracts/pull/339) at commit [7b97e4d](https://github.com/matter-labs/system-contracts/commit/7b97e4dd42ceaa90bd06c4cc981942ebf9f0a1d4).*

### Unused Imports

Throughout the protocol, there are imports that are unused and could be removed.

In [`zksync-2-contracts`](https://github.com/matter-labs/zksync-2-contracts/pull/165/files):

- Import [`L2ContractHelper`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol#L12) of [`Executor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol)
- Import [`L2_KNOWN_CODE_STORAGE_SYSTEM_CONTRACT_ADDR`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol#L17) of [`Executor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol)
- Import [`L2_BYTECODE_COMPRESSOR_SYSTEM_CONTRACT_ADDR`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol#L18) of [`Executor.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/098bc7ee2d13f78d365c386a8d27c1ae09b31164/ethereum/contracts/zksync/facets/Executor.sol)

In [`system-contracts`](https://github.com/matter-labs/system-contracts/pull/283/files):

- Import [`BOOTLOADER_FORMAL_ADDRESS`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/KnownCodesStorage.sol#L9) of [`KnownCodesStorage.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/KnownCodesStorage.sol)
- Import [`SystemContractHelper`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L2EthToken.sol#L8) of [`L2EthToken.sol`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/L2EthToken.sol)
- Import [`MSG_VALUE_SYSTEM_CONTRACT`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol#L5) of [`SystemContractHelper`](https://github.com/matter-labs/system-contracts/blob/4dca36d898f2fc0a7e39f0e3ef0c1a78570efaa2/contracts/libraries/SystemContractHelper.sol)

Consider removing unused imports to improve the overall clarity and readability of the codebase.

***Update:** Resolved in [pull request #222](https://github.com/matter-labs/zksync-2-contracts/pull/222) at commit [061de34](https://github.com/matter-labs/zksync-2-contracts/commit/061de342b45b4a1150b3cfb3b7302108cf6d95fb) and [pull request #340](https://github.com/matter-labs/system-contracts/pull/340) at commit [4e51af8](https://github.com/matter-labs/system-contracts/commit/4e51af808e90089ffdfa6340ac6202d45b710ed7).*

## Conclusions

This audit was conducted over the course of two weeks. One high-severity issue was identified. A few medium and low-severity issues were found alongside some notes to improve the clarity and readability of the codebase. Some changes were also proposed to ensure smart contract security best practices are followed. We found the dedicated documentation provided by the Matter Labs team to be very helpful in understanding the audited code changes. Furthermore, their team was very supportive in answering questions in a timely manner and even syncing with our team to talk through the changes.
