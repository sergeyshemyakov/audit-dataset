# zkSync Bootloader Audit Report

Source: [https://www.openzeppelin.com/news/zksync-bootloader-audit-report](https://www.openzeppelin.com/news/zksync-bootloader-audit-report)

This security assessment was prepared by **OpenZeppelin**.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [Bootloader](#bootloader)
  - [MsgValueSimulator](#msgvaluesimulator)
  - [L2EthToken](#l2ethtoken)
- [Privileged Roles and Security Assumptions](#privileged-roles-and-security-assumptions)
- [Critical Severity](#critical-severity)
  - [Useless Assertion Check](#useless-assertion-check)
- [High Severity](#high-severity)
  - [Non-Standard Transaction Hash](#non-standard-transaction-hash)
  - [Unbound RLP Length Encoding](#unbound-rlp-length-encoding)
- [Medium Severity](#medium-severity)
  - [Overshadowing and Uncaptured Returns](#overshadowing-and-uncaptured-returns)
  - [String Literal Exceeds 32 Bytes Limit](#string-literal-exceeds-32-bytes-limit)
  - [Unprotected Initialization Function](#unprotected-initialization-function)
- [Low Severity](#low-severity)
  - [Documentation and Code Mismatch](#documentation-and-code-mismatch)
  - [Incompatible Function Syntax](#incompatible-function-syntax)
  - [Inexplicit Fail in Bridge Burn](#inexplicit-fail-in-bridge-burn)
  - [Inexplicit Imports](#inexplicit-imports)
  - [Lack of Revert Messages](#lack-of-revert-messages)
  - [Mismatch Between Interface and Implementation](#mismatch-between-interface-and-implementation)
  - [Missing Interface for L2EthToken](#missing-interface-for-l2ethtoken)
  - [Imprecise Naming of Transaction Struct Elements](#imprecise-naming-of-transaction-struct-elements)
  - [TypeScript Constant Names Are Inconsistent](#typescript-constant-names-are-inconsistent)
  - [Unused Functions](#unused-functions)
  - [Wrong EIP-712 Transaction Type Check](#wrong-eip-712-transaction-type-check)
- [Notes & Additional Information](#notes-additional-information)
  - [Code Redundancy](#code-redundancy)
  - [Commented-out Code](#commented-out-code)
  - [Extra Code](#extra-code)
  - [Inconsistent Declaration of Constants](#inconsistent-declaration-of-constants)
  - [Inconsistent Declaration of Integers](#inconsistent-declaration-of-integers)
  - [Performance Optimization](#performance-optimization)
  - [TODOs Are Present in the Codebase](#todos-are-present-in-the-codebase)
  - [Typographical Errors](#typographical-errors)
  - [Unexpected Negation in Inclusion Logic](#unexpected-negation-in-inclusion-logic)
  - [Unintuitive Naming](#unintuitive-naming)
  - [Unused Imports](#unused-imports)
  - [Unused Variable](#unused-variable)
- [Conclusions](#conclusions)
- [Appendix](#appendix)
  - [Monitoring Recommendations](#monitoring-recommendations)

## Summary

Type

Rollup

Timeline

From 2022-11-28 to 2022-12-23

Languages

Solidity

Total Issues

29 (25 resolved, 1 partially resolved)

Critical Severity Issues

1 (1 resolved)

High Severity Issues

2 (2 resolved)

Medium Severity Issues

3 (2 resolved)

Low Severity Issues

11 (11 resolved)

Notes & Additional Information

12 (9 resolved, 1 partially resolved)

## Scope

We audited the [matter-labs/system-contracts repository](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts) at the `4ad1f26ae205d5a973216d141833e0ac37d72ec8` commit.

In scope were the following contracts:

```
├── bootloader
|   └── bootloader.yul
└── contracts
    ├── BootloaderUtilities.sol
    ├── L2EthToken.sol
    ├── MsgValueSimulator.sol
    ├── interfaces
    |   ├── IBootloaderUtilities.sol
    |   ├── IL2StandardToken.sol
    |   └── IEthToken.sol
    └── libraries
        └── RLPEncoder.sol
```

## System Overview

zkSync is a layer 2 scaling solution for Ethereum based on zero-knowledge rollup technology. The protocol aims to provide low transaction fees and high throughput while maintaining a large degree of EVM compatibility.

The scope of this audit included the `bootloader` which bundles transactions and executes them by delegating core functionality to system-contracts deployed on layer 2. The execution environment is the zkEVM, which uses distinct opcodes from the Ethereum-VM and different precompiles, but maintains a large degree of compatibility on the source code level.

To read the audit report of the layer 1 contracts: [See our blog](https://blog.openzeppelin.com/zksync-layer-1-audit/).

### Bootloader

The bootloader is a key component of the system that manages the execution of layer 2 transactions. It is a specialized software that is not deployed like a regular contract, but rather runs within a node as part of the execution environment. The validator modifies transactions and stores them in an array, which is then written to the bootloader memory and executed. In order to avoid the possibility of the entire process rolling back due to a failure in a single transaction, the bootloader uses a softer fail condition known as a `near call panic`. The bootloader’s functionality is divided between a large Yul file and the `BootLoaderUtilities` contract.

### MsgValueSimulator

The `MsgValueSimulator` contract is responsible for simulating transactions with a positive `msg.value` inside of the zkEVM by delegating the balance accounting to the `L2EthToken` contract.

### L2EthToken

The `L2EthToken` contract is a token that wraps the native ETH asset. Unlike ERC-20 tokens, it does not support direct user interaction, but is instead meant to be used by `MsgValueSimulator` to support the usage of `msg.value` within zkEVM.

## Privileged Roles and Security Assumptions

In its current form, all validators for zkSync are operated by zkSync. However, the plan is to eventually decentralize this process.

The integrity of the bootloader is protected through a hash commitment on layer 1, which can be upgraded by Matter Labs.

Further, Matter Labs currently has the ability to force-redeploy system contracts on layer 2 in order to ensure their updateability.

## Critical Severity

### Useless Assertion Check

The [`assertEq` function](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1644-L1653) in the bootloader compares two values. If they are not equal, it throws an error. There are two issues with this implementation:

- The function compares the value of the `value1` parameter to itself, which means the comparison will always be true and the function serves no purpose.
- The function header includes the `value1` parameter twice, which causes a compile-time error when using a Solidity compiler such as `solc`.

Consider correcting the comparison by checking two distinct variables. Additionally, ensure that the custom zkEVM compiler throws an error when declaring two variables with the same name in the same scope.

***Update:** Resolved in [pull request #133](https://github.com/matter-labs/system-contracts/pull/133/) at commit [6e3c054](https://github.com/matter-labs/system-contracts/pull/133/commits/6e3c054a9c8cf6da52b5721a0dd1ef48bec7d6c1).*

## High Severity

### Non-Standard Transaction Hash

The [`BootloaderUtilities` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol) generates transaction hashes for different types based on the transaction data, including the signature. The signature includes a `v` value that encodes a parity bit `y` for address recovery purposes. The way that the parity bit is encoded into `v` depends on the type of transaction:

- For legacy transaction hashes, `v` can be either `27 + y`, or `35 + chainid * 2 + y` when the `chainid` is included ([Ethereum Yellowpaper, page 5](https://ethereum.github.io/yellowpaper/paper.pdf)).
- For [EIP2930](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-2930.md) and [EIP1559](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1559.md) transactions, `v` is simply encoded as `y` (either 0 or 1).

However, the `DefaultAccount` contract enforces that [`v` must be either 27 or 28](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/DefaultAccount.sol#L179). This causes problems in the legacy transaction hash function because, when the `chainid` is included in the encoding, the value of [`35 + block.chainid * 2` is added to `v`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L98). But, since `v` is already set to either 27 or 28, as enforced by the `DefaultAccount` contract, the resulting `v` value does not comply with the standard described above, thereby giving a non-standard transaction hash.

Additionally, in the [EIP-2930](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L190) and [EIP-1559](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L282) transaction hash functions, the `v` value is again fetched as either 27 or 28 and encoded as such, even though it should be `0` or `1` as defined by the standard. Hence, the transaction hashes generated by these functions are also non-standard.

Consider fixing this by deriving the correct value from the `v` value that is given or changing the way the `v` value is enforced in the first place.

***Update:** Resolved in [pull request #157](https://github.com/matter-labs/system-contracts/pull/157/) at commits [3472d28](https://github.com/matter-labs/system-contracts/pull/157/commits/3472d28f547275d2c6a70d7d36cfe5c15b6d1807) and [471a450](https://github.com/matter-labs/system-contracts/pull/157/commits/471a4501c36e7277cbdd98e247fc6ad127b1ea9a).*

### Unbound RLP Length Encoding

The [`RLPEncoder` library](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/libraries/RLPEncoder.sol) allows the encoding of bytes and list-type values. These dynamic types need to be prefixed to indicate the type and length of the data. The type is indicated through an offset:

- `0x80` for bytes
- `0xc0` for a list

The length encoding depends on the length itself:

1. Length < 56: The length is added onto the offset.
   - Bytes 1st byte range: `[0x80, 0xb7]`
   - List 1st byte range: `[0xc0, 0xf7]`
2. Length ≥ 56: The length of the data is encoded between offset and data. The length of the length in bytes is added onto the offset.
   - Bytes 1st byte range: `[0xb8, 0xbf]`
   - List 1st byte range: `[0xf8, 0xff]`

Visualization of 2.:

```
offset + length_of_data_length || data_length || data
```

In the (2.) case, we can see that the encoding of the length can at most be 8 bytes long. However, in the RLP library a [length of up to 32 bytes is taken as input](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/libraries/RLPEncoder.sol#L41-L51) to encode the length. Hence, when encoding a length equal or greater than `2**64`, the length encoding requires 9 or more bytes. This [bound violation](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/libraries/RLPEncoder.sol#L62) ends up in a corrupted encoding. For instance, a byte encoding could thereby end up as a list encoding.

This issue was not identified as a problem for the codebase in scope, as the length to encode is based on transaction data, which is unlikely to be of size `2**64` or greater. However, as this library finds adoptions across other projects, the current implementation could lead to severe issues or introduction of vulnerabilities if not used properly.

Consider checking that the length to encode is bound to `2**64 - 1`.

***Update:** Resolved in pull requests [#134](https://github.com/matter-labs/system-contracts/pull/134/) and [#160](https://github.com/matter-labs/system-contracts/pull/160/) at commits [61b8138](https://github.com/matter-labs/system-contracts/pull/134/commits/61b8138f8726536e120aa05b734839574b2097bf) and [6e45486](https://github.com/matter-labs/system-contracts/pull/160/commits/6e4548689e91ab6b5595d5af15faba426315a49a).*

## Medium Severity

### Overshadowing and Uncaptured Returns

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), the function `setTxOrigin` has a return value `success`, which is overshadowed by a [local variable](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1478) of the same name within the function scope. In the `solc` Solidity compiler this triggers a compiler error.

Additionally, the `setTxOrigin` function is called from the [top level without capturing its return value](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L333), which causes another compiler error in `solc` and might lead to unexpected outcomes when using other compilers.

The same issue applies to the `precompileCall` function, which has a return value that is not captured when it is called inside the `nearCallPanic` function.

To address these issues, consider removing all unused return values.

***Update:** Resolved in [pull request #135](https://github.com/matter-labs/system-contracts/pull/135/) at commit [45c04f9](https://github.com/matter-labs/system-contracts/pull/135/commits/45c04f9f774f0cdc46ef3e3f1f8380b5673ebb04).*

### String Literal Exceeds 32 Bytes Limit

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), the string literal “[Tx data offset is not in correct place](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L288)” is used as an input to the `assertionError` function. It exceeds the 32-byte limit for string literals in Yul, which leads to a compile error with the `solc` Solidity compiler. The usage of another compiler might lead to a similar error or silently discard parts of the string.

To avoid any possible compiler and runtime issues, consider making the string shorter by removing or abbreviating some of the words.

***Update:** Resolved in [pull request #136](https://github.com/matter-labs/system-contracts/pull/136/) at commit [d506790](https://github.com/matter-labs/system-contracts/pull/136/commits/d5067909c0cf86add5a1183117ab355914910aa5).*

### Unprotected Initialization Function

In the `L2EthToken` contract, an [unresolved comment](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol#L35) acknowledges the fact that the `initialization` function is unprotected and anyone could set the `l2Bridge` address if they call the function before the legitimate operator. The comment describes the problem without presenting a solution.

Consider using the TypeScript-based templating system that is already present in the codebase to inject a constant address that limits the `initialization` call to one specific `msg.sender`.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *We plan to rethink the approach of bridging ether in the new upgrade, the issue will be resolved there.*

## Low Severity

### Documentation and Code Mismatch

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul) a few instances of a mismatch between the contract and documentation were identified:

- The [`MAX_POSTOP_SLOT` constant](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L87) is documented to account for 4 slots which are required for the encoding of the [`callPostOp` call](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1145). However, the implementation accounts for 7 slots.
- The [`MAX_MEM_SIZE` constant](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L166) is of size `2**24`, while it is described as `2**16`.
- In the `callPostOp` function, the `txResult` parameter is [described as `0` if successful and `1` otherwise](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1141). However, the `txResult` value is coming from low-level `call` that returns `1` if being successful and `0` otherwise. Proceeding forward, this result is correctly handled through the [`ExecutionResult` enum](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/interfaces/IPaymaster.sol#L7-L10), thereby affecting the documentation only.
- The [`setErgsPrice` function](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1486) is incorrectly documented as “Set the new value for the **tx origin** context value”.
- The [`lengthToWords` function](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L357) is implemented differently from what the name and documentation are indicating. From the description it suggest to return the number of words needed for a specified length of bytes. However, the implementation returns the next bigger bytes length of words that are needed. The implementation is also inefficient and can be simplified.

In the [`RLPEncoder` library](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/libraries/RLPEncoder.sol), the [comment on line 7](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/libraries/RLPEncoder.sol#L7) describes the size as equal to “14” bytes (dec), while “0x14” bytes (hex) is the correct size.

In the [`BootloaderUtilities` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L21), the [comment on line 21](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L21) refers to “signedHash” while “signedTxHash” is the correct identifier name.

In the [`L2EthToken` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.so), the `transferFromTo` function claims to “[rely on SameMath](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol#L60)” which is probably referring to a `SafeMath` library which is also not used in that function.

Consider correcting the above mismatches to be precise about the implementation and its documentation to ease code review.

***Update:** Resolved in pull requests [#137](https://github.com/matter-labs/system-contracts/pull/137/) and [#161](https://github.com/matter-labs/system-contracts/pull/161/) at commits [68f99cb](https://github.com/matter-labs/system-contracts/pull/137/commits/68f99cbedffb9588d1848f9059d510b78b566ae9), [7b66b8a](https://github.com/matter-labs/system-contracts/pull/137/commits/7b66b8a916e48edea552256256ebb6b2b614b417), and [e09b067](https://github.com/matter-labs/system-contracts/pull/161/commits/e09b067c4703eec45c1caa4734f69c8afbcf6f66).*

### Incompatible Function Syntax

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), the function [`getFarCallABI`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1396) is declared with a list of parameters ending with a trailing comma.

However, the Solidity compiler `solc` does not support the declaration of Yul functions with a parameter list containing a trailing comma.

Consider removing the trailing comma and ensure that your codebase maintains as much compatibility with the Solidity compiler whenever possible.

***Update:** Resolved in [pull request #138](https://github.com/matter-labs/system-contracts/pull/138/) at commit [5e1cf33](https://github.com/matter-labs/system-contracts/pull/138/commits/5e1cf33497fbd4ab7f2a7454f6b63a5f06a8e3ee).*

### Inexplicit Fail in Bridge Burn

The [`bridgeBurn` function](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol#L84) in the `L2EthToken` contract adjusts a user’s balance without checking their current balance first. This could result in an underflow error, which is providing insufficient information to the user.

To prevent this issue, consider adding a `require` statement to explicitly fail with a descriptive error string if the user’s balance is exceeded.

***Update:** Resolved in [pull request #139](https://github.com/matter-labs/system-contracts/pull/139/) at commit [2053757](https://github.com/matter-labs/system-contracts/pull/139/commits/2053757dd98fc5ccbe5029e013377b3dffc00635).*

### Inexplicit Imports

In the [`BootloaderUtilities`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L9) and [`MsgValueSimulator`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/MsgValueSimulator.sol#L6) contract, the `Constants.sol` file inexplicitly imports all constants. This hinders the visibility of what other components are actually used within the contract.

Consider changing the imports to explicitly import specific constants for better code clarity.

***Update:** Resolved in [pull request #156](https://github.com/matter-labs/system-contracts/pull/156/) at commit [94c79a5](https://github.com/matter-labs/system-contracts/pull/156/commits/94c79a510a01d0d4baaca4eef24d240c6cb53417).*

### Lack of Revert Messages

In the [`L2EthToken` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol), the `require` statements in line [36-37](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol#L36-L37), [42](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol#L42), and [54-58](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol#L54-L58) lack an error message.

Consider adding the error message to fail more explicitly and ease debugging.

***Update:** Resolved in [pull request #140](https://github.com/matter-labs/system-contracts/pull/140/) at commit [be287c9](https://github.com/matter-labs/system-contracts/pull/140/commits/be287c987be6c2d72a0adbc778938b1248d0f932).*

### Mismatch Between Interface and Implementation

The [`BootloaderUtilities` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol) imports the [`IBootloaderUtilities` interface](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L5), but the contract does not inherit from this interface. It appears that the intent may have been to inherit from the interface, but due to this oversight, there is a mismatch between the function names and return types in the interface and the contract.

In the interface, the function is defined as:

```
function getTransactionHash(Transaction calldata _transaction) external view returns (bytes32)
```

But in the contract, it is defined as:

```
function getTransactionHashes(Transaction calldata _transaction) external view returns (bytes32 txHash, bytes32 signedTxHash)
```

This inconsistency may result in errors or unexpected behavior.

Consider inheriting from the `IBootloaderUtilities` interface in the `BootloaderUtilities` contract to ensure that the function names and return types are consistent and match the intended functionality. This will improve the reliability and maintainability of the codebase.

***Update:** Resolved in [pull request #141](https://github.com/matter-labs/system-contracts/pull/141/) at commit [827aad6](https://github.com/matter-labs/system-contracts/pull/141/commits/827aad6188e80d0f38e4e82ff5c756dcbcf17238).*

### Missing Interface for `L2EthToken`

The [`L2EthToken` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol) implements two interfaces to enforce compliance with their respective functions. However, the contract also implements the standard ERC-20 functions `name`, `symbol`, `decimals`, and `totalSupply`.

Currently, nothing prevents misspellings and there is no convenient way to call these functions through address to interface conversion.

Consider either integrating them into one of the existing interfaces or defining an additional interface `PartialERC20`.

***Update:** Resolved in pull requests [#142](https://github.com/matter-labs/system-contracts/pull/142/) and [#162](https://github.com/matter-labs/system-contracts/pull/162/) at commits [f6fbaa9](https://github.com/matter-labs/system-contracts/pull/142/commits/f6fbaa93322474e05c2558c73d27a8a374dcf096) and [5082111](https://github.com/matter-labs/system-contracts/pull/162/commits/50821112f611d92cb99c3490f954ac3cc940dcc5).*

### Imprecise Naming of Transaction Struct Elements

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), inside of the `validateTypedTxStructure` function, [it is stated](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1666-L1668) that the first and second reserved slots of the transaction struct are used to store the `nonce` and `value`, respectively. These values are common to all types of transactions and could also be stored as explicit elements of the transaction struct.

To improve the code clarity, consider adding dedicated entries to the transaction struct for these common elements.

***Update:** Resolved in [pull request #143](https://github.com/matter-labs/system-contracts/pull/143/) at commits [af4c5b9](https://github.com/matter-labs/system-contracts/pull/143/commits/af4c5b9eb9f8bee6b93dc8e1c218f275763124c9) and [cd55ab2](https://github.com/matter-labs/system-contracts/pull/143/commits/cd55ab2524a945a3ed303d9eabdeff03c050b8f3).*

### TypeScript Constant Names Are Inconsistent

The `bootloader` contract includes constants that [are defined in TypeScript code](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/scripts/process.ts#L38-L60) with the format , and are replaced with their actual values during compilation. These constants, which are often used for selectors, may or may not be padded with zeros. However, the names of these constants do not consistently indicate whether they have been padded or not, which is important for determining the memory layout in the bootloader.

To improve the clarity and consistency of the codebase, consider using consistent naming conventions for constants that indicate whether they have been padded or not.

***Update:** Resolved in [pull request #144](https://github.com/matter-labs/system-contracts/pull/144/) at commit [8ca44a7](https://github.com/matter-labs/system-contracts/pull/144/commits/8ca44a7abf2f87eec3132c193d1b638fa5afc10a).*

### Unused Functions

The following internal functions are defined in the [`bootloader`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yu) contract, but appear to be unused:

- [`ETH_L2_TOKEN_ADDR`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L217)
- [`min`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L971)
- [`ETH_CALL_ERR_CODE`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1994)
- [`UNACCEPTABLE_ERGS_PRICE_ERR_CODE`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L2014)
- [`TX_VALIDATION_FAILED_ERR_CODE`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L2042)

To improve the codebase, consider either using these functions or removing them. Removing unused functions can help to reduce clutter and make the code easier to understand.

***Update:** Resolved in [pull request #145](https://github.com/matter-labs/system-contracts/pull/145/) at commit [316c54a](https://github.com/matter-labs/system-contracts/pull/145/commits/316c54ad34934a2a7685c99aec6e4d67fc368cf4). The Matter Labs team stated:*

> *We removed all unused constants except `_ERR_CODES`, which are used in the server. We want to avoid any confusion when starting to use such error codes in bootloader.*

### Wrong EIP-712 Transaction Type Check

In the `validateTypedTxStructure` function of the bootloader, the EIP-712 `txType` is [checked against 112](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1704), while it is [supposed to be 113](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/libraries/TransactionHelper.sol#L14).

Following the execution flow, it can be seen in the [`getTransactionHashes` function](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L24) that a call reverts if the transaction type does not match one of 0, 1, 2, or 113. So for a transaction of type 113, the foreseen checks in the bootloader are skipped. This means the reserved slots can be arbitrary. However, no negative consequences were identified.

Consider correcting the transaction type check from 112 to 113. Further, consider implementing a default case and using the unused `valid` return variable to fail early if the transaction type does not match.

***Update:** Resolved in [pull request #146](https://github.com/matter-labs/system-contracts/pull/146/) at commit [c343256](https://github.com/matter-labs/system-contracts/pull/146/commits/c34325654a3892d5825653d22acf733efbe2d4c6).*

## Notes & Additional Information

### Code Redundancy

In the [`BootloaderUtilities` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol), different types of transactions are encoded and hashed. These transaction types share similarities in their encoding which leads to redundancy of code. For instance, both the legacy and EIP-2930 type transaction have the consecutively encoded fields `nonce`, `gas price`, `gas limit`, `to`, and `value`.

Consider moving some parts of the encoding into a function to reuse the code for both transaction types.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *Specifically in the specified places, we choose readability over performance.*

### Commented-out Code

In the `bootloader.yul` file, the two constants in Solidity code format [`dummyAddress` and `BOOTLOADER_ADDRESS`](https://github.com/OpenZeppelin/audit-matterlabs/blob/4dfec5710c8d9b19e503ef0f274c60e5a3df84c0/sideproducts/felix/bootloader-breakdown/original/bootloader.yul#L248-L249) are commented out and seem obsolete.

Consider removing the commented-out code as well as the comments describing them.

***Update:** Resolved in [pull request #147](https://github.com/matter-labs/system-contracts/pull/147/) at commit [7c344be](https://github.com/matter-labs/system-contracts/pull/147/commits/7c344becacf9b93f5923172d0c6411201736f218).*

### Extra Code

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), the computation of a [`switch` statement condition](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L383-L390) in the transaction processing includes unnecessary code that makes the code harder to read. The variables `txType` and `isL1Tx` are not used elsewhere in the function. Additionally, the `FROM_L1_TX_TYPE` variable appears to be a constant, but it is not declared as such.

To improve the clarity and readability of the code, consider simplifying the switch statement computation and properly declaring variables as constants if they are intended to be constant.

***Update:** Resolved in pull requests [#148](https://github.com/matter-labs/system-contracts/pull/148/) and [#158](https://github.com/matter-labs/system-contracts/pull/158/) at commits [613636f](https://github.com/matter-labs/system-contracts/pull/148/commits/613636fb6e8ae733124c549dee71503687bf0648) and [cdc301f](https://github.com/matter-labs/system-contracts/pull/158/commits/cdc301fa877fe273d13d049325b21597978c63e6).*

### Inconsistent Declaration of Constants

There is an inconsistency in the way constants are declared in the code, with some being declared as functions and others being declared as variables. This deviation from a consistent pattern can be confusing and make it difficult to understand the purpose and usage of these constants. The following constants are declared as variables:

- [`TX_DESCRIPTION_SIZE`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L156)
- [`TXS_IN_BLOCK_LAST_PTR`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L159)

Consider using a consistent method for declaring constants throughout the code as functions. This will improve the readability and understandability of the code and make it easier for others to work with it.

***Update:** Resolved in [pull request #149](https://github.com/matter-labs/system-contracts/pull/149/) at commits [c7042cd](https://github.com/matter-labs/system-contracts/pull/149/commits/c7042cd1beb683642fa669e7d3fce305c81a2f52) and [fee4b5b](https://github.com/matter-labs/system-contracts/pull/149/commits/fee4b5b9805377b93adac587ff888f3cede2d07d).*

### Inconsistent Declaration of Integers

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), there is an inconsistency in the way memory offsets are declared in the codebase, with some being expressed in decimal and others being expressed in hexadecimal. This deviation from a consistent notation can be confusing and make it difficult to understand the purpose and usage of these sizes. For instance:

- [`add(0x20, txDataOffset)` in line 291](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L291)
- [`add(0x20, txDataOffset)` in line 300](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L300)
- [`mstore(txDataOffset, 0x20)` in line 431](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L431)
- [`add(txDataOffset, 0x20)` in line 797](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L797)
- [`add(txDataOffset, 0x20)` in line 1170](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1170)
- [`add(dataPtr, 0x20)` in line 1400](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1400)

Consider using a consistent notation for expressing memory offsets throughout the codebase.

***Update:** Resolved in [pull request #150](https://github.com/matter-labs/system-contracts/pull/150/) at commit [ecdbebd](https://github.com/matter-labs/system-contracts/pull/150/commits/ecdbebd1768bd6e022b8405f40194e24a5823d5d).*

### Performance Optimization

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), we have identified several opportunities for performance optimization:

- In the `validateTypedTxStructure` function, when checking if the [`reservedDynamicLength` value is not zero](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1660-L1663), consider loading the length from the `getReservedDynamicPtr` pointer directly to skip the `lengthToWords` computation.
- In the `callAccountMethod` function, consider using the existing `txDataOffset` pointer instead of [advancing the `txDataWithHashesOffset`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1079) a second time to save an `add`.
- In the [function call to `executeL1Tx`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L817), consider propagating the given `innerTxDataOffset` instead of [recalculating it](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1339) in the function itself.
- In the `getFarCallAbi` function, [`dataOffset` and `memoryPage`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1403-L1404) are zero and could be skipped. Consider starting with the shifted `dataStart` value instead.
- The `executeL2Tx` function is only called within the `ZKSYNC_NEAR_CALL_executeL2Tx()` function where the `from` transaction value is present. Consider [propagating that `from` value](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L739) to the `executeL2Tx` call instead of [recomputing it](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1366-L1367).

***Update:** Partially resolved in [pull request #151](https://github.com/matter-labs/system-contracts/pull/151/) at commit [fe92113](https://github.com/matter-labs/system-contracts/pull/151/commits/fe921138183a3745b6aef3ab0d6c76fbd677a830). The Matter Labs team stated:*

> *Partially fixed, we decided to keep better readability over performance in a place where optimization is hard to implement or may confuse the reader. Also, please note that the compiler could do such an optimization, because we have an LLVM backend.*

### TODOs Are Present in the Codebase

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), there are incomplete implementations and missing functionality in the codebase, as indicated by the presence of “TODO” comments. This can make it difficult to understand the intended functionality and behavior of the code, and may also make it difficult to properly test and maintain the codebase. For instance:

- [“make user pay for sending back the L1 message”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L603)
- [“(SMA-1220): refunds are not supported as of now”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L767-L768)
- [“(SMA-1220): support refunds […]”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L772-L786)

Consider completing the implementations and addressing the missing functionality. This will improve the overall quality and reliability of the codebase and make it easier for others to work with it.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *The issue will be resolved in upcoming upgrades.*

### Typographical Errors

In the codebase the following typographical errors were identified:

- [“shoud”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L618) → “should”
- [“Firsly”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L474) → “Firstly”
- [“succedes”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L762) → “succeeds”
- [“Reseting”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L331) → “Resetting”
- [“mainntet”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/L2EthToken.sol#L34) → “mainnet”
- [“only one higher”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L49) → “only the first one above”
- [“again”](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1249) → “against”

Consider correcting these and any further issues.

***Update:** Resolved in [pull request #152](https://github.com/matter-labs/system-contracts/pull/152/) at commits [9dd29e3](https://github.com/matter-labs/system-contracts/pull/152/commits/9dd29e30d294e2594516872374fbebd578848ab1) and [630625f](https://github.com/matter-labs/system-contracts/pull/152/commits/630625fecc742c6e2a0fc9be618d4f0df06a800e).*

### Unexpected Negation in Inclusion Logic

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), the constant `BOOTLOADER_TYPE` is either equal to the value `proved_block` or `playground_block`. On [line 1523](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L1523), the inclusion of a block is determined by negating the value of `BOOTLOADER_TYPE`. While this may be semantically correct, it can be confusing to readers and might introduce errors or misunderstandings among developers.

To improve readability, consider using the non-negated form exclusively to specify which code should be included. For example, using

```
if BOOTLOADER_TYPE == 'proved_block'
```

to include the block when `BOOTLOADER_TYPE` is set to `proved_block`, and

```
if BOOTLOADER_TYPE == 'playground_block'
```

to include the block when `BOOTLOADER_TYPE` is set to `playground_block`.

***Update:** Resolved in [pull request #153](https://github.com/matter-labs/system-contracts/pull/153/) at commit [9b9d534](https://github.com/matter-labs/system-contracts/pull/153/commits/9b9d5341988308ff093f495a30472efa10981c67).*

### Unintuitive Naming

In the [`bootloader` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul), two occurrences of unintuitive variable naming were identified:

- The naming of [`RESERVED_FREE_SLOTS`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L131) is somewhat confusing, as it suggests that the slots are both reserved and free at the same time. In reality, the reserved slots may be free, but most of the slots will be pre-filled.
- The terms `txInnerDataOffset` and `innerTxDataOffset` are both used for semantically similar parameters. This inconsistency in naming can be confusing and limit the ability to easily search for all occurrences.

Consider using more consistent and intuitive naming conventions for variables and terms in the codebase.

***Update:** Resolved in [pull request #163](https://github.com/matter-labs/system-contracts/pull/163/) at commit [83931d4](https://github.com/matter-labs/system-contracts/pull/163/commits/83931d435241c4f2a389e775e328f773a9ee95da).*

### Unused Imports

In the [`BootloaderUtilities` contract](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol) the

- `IBootloaderUtilities` interface,
- `SystemContractHelper` library, and
- `Constants` file

[are imported](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L5-L9) but never used.

Consider using or removing them.

***Update:** Resolved in [pull request #154](https://github.com/matter-labs/system-contracts/pull/154/) at commit [26523a2](https://github.com/matter-labs/system-contracts/pull/154/commits/26523a2cd93ecfa0ad6ca1245019313d667c7712). The `IBootloaderUtilities` interface is now used as part of the L-06 fix.*

### Unused Variable

The [`encodedChainId` variable](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/contracts/BootloaderUtilities.sol#L79-L82) in the `BootloaderUtilities` contract is unused.

Similarly, in the `bootloader` contract the variables [`from` and `ergsLimit`](https://github.com/matter-labs/system-contracts/blob/4ad1f26ae205d5a973216d141833e0ac37d72ec8/bootloader/bootloader.yul#L726-727) remain unused within the `ZKSYNC_NEAR_CALL_validateTx` function.

Consider removing these unused variables.

***Update:** Resolved in [pull request #155](https://github.com/matter-labs/system-contracts/pull/155/) at commit [bca9d68](https://github.com/matter-labs/system-contracts/pull/155/commits/bca9d6815e9c6f8573a3a333b51c815ff00dab7a).*

## Conclusions

This is the third report of the engagement. The audit lasted for 4 weeks, during which we had the opportunity to work closely with the Matter Labs team. They were very responsive in answering our questions and provided us with extensive and dedicated documentation that was extremely useful.

The scope of the audit included the `bootloader` as well as three more layer 2 system contracts with corresponding interfaces and one library. The `bootloader` is a complex component that orchestrates various system contracts in order to execute layer 2 transactions and log them to layer 1. It is a unique piece of software and therefore very interesting to audit.

During the audit, we identified several issues, including one critical and two high severity issue, as well as a number of medium and lower severity issues. Overall, the audit was successful in identifying issues and providing recommendations for improvement.

## Appendix

### Monitoring Recommendations

While audits help in identifying code-level issues in the current implementation and potentially the code deployed in production, we encourage the Matter Labs team to consider incorporating monitoring activities in the production environment. To ensure the security of the project, we use both on-chain and node monitoring to identify potential threats and issues. With the goal of providing a comprehensive security assessment, we recommend the following measures:

#### On-Chain Monitoring

**Critical:** Monitor which addresses act as an EOA and trigger a warning when code is deployed on that address. In case this happens unwillingly, the incident could mean loss of power for that EOA by having a malicious contract acting on behalf of that user.

**High:** The implemented account abstraction allows the creation of custom accounts. Custom accounts may implement calls with the `isSystem` call flag set. This is a sensitive functionality which enables impersonation of the message sender through mimic calls. Unintentional usage of this flag could mean loss of funds through impersonation by a malicious party.

#### Node Monitoring

**Low:** The `vmHook` memory data of the `bootloader` can be leveraged by the node operator to check whether execution flow of the bootloader is as intended. Any violation to the control flow integrity could mean a compromise of the system.

**Low:** The bootloader is responsible for collecting transaction fees for the operator address. The operator can verify that the fees received on-chain match the fees defined in the raw transaction data received by the node. If there is a discrepancy, it could indicate a problem with the implementation of fee management.
