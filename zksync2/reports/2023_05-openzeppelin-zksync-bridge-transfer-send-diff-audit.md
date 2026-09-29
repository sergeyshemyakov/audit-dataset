# zkSync Bridge and .transfer & .send Diff Audit

Source: [https://www.openzeppelin.com/news/zksync-bridge-and-.transfer-.send-diff-audit](https://www.openzeppelin.com/news/zksync-bridge-and-.transfer-.send-diff-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Security Model and Privileged Roles](#security-model-and-privileged-roles)
- [Medium Severity](#medium-severity)
  - [Fragile Deposit Limit](#fragile-deposit-limit)
- [Low Severity](#low-severity)
  - [Unsafe ABI Encoding](#unsafe-abi-encoding)
  - [Missing Error Messages in require Statements](#missing-error-messages-in-require-statements)
  - [Unreplenishable Deposit Limit](#unreplenishable-deposit-limit)
  - [Bridge Cannot Recover Funds](#bridge-cannot-recover-funds)
  - [Missing and Misleading Documentation](#missing-and-misleading-documentation)
- [Notes & Additional Information](#notes-additional-information)
  - [State Variable Visibility Not Explicitly Declared](#state-variable-visibility-not-explicitly-declared)
  - [Unused Imports](#unused-imports)
  - [Multiple Declarations per File](#multiple-declarations-per-file)
  - [Typographical Errors](#typographical-errors)
  - [Naming Suggestions](#naming-suggestions)
  - [Use assert for Inviolable Conditions](#use-assert-for-inviolable-conditions)
  - [Unexpected Address Aliasing](#unexpected-address-aliasing)
- [Conclusions](#conclusions)
- [Appendix](#appendix)
  - [Monitoring Recommendations](#monitoring-recommendations)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-04-24
:   To 2023-05-01

Languages
:   Solidity

Total Issues
:   13 (9 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   1 (0 resolved)

Low Severity Issues
:   5 (4 resolved)

Notes & Additional Information
:   7 (5 resolved)

Client Reported Issues
:   0 (0 resolved)

## Scope

We audited [pull request #258](https://github.com/matter-labs/system-contracts/pull/258/files) of the `matterlabs/system-contracts` repository up to the `ce6c3458f0f16d20ac335071de161a986a4ecb0d` commit.

In scope were the following contracts:

```
 contracts
├── KnownCodesStorage.sol
├── L1Messenger.sol
├── MsgValueSimulator.sol
└── libraries
    └── SystemContractHelper.sol
```

We also audited the `matter-labs/zksync-2-contracts` repository at the `c44852f89f443bbe8120a7c6abcc6984b394eb29` commit.

```
 contracts
├── ethereum
│   └── contracts
│       ├── bridge
│       │   ├── L1ERC20Bridge.sol
│       │   ├── interfaces
│       │   │   └── IL2ERC20Bridge.sol
│       │   └── libraries
│       │       └── BridgeInitializationHelper.sol
│       └── zksync
│           └── facets
│               └── Mailbox.sol
└── zksync
    └── contracts
        ├── L2ContractHelper.sol
        └── bridge
            ├── L2ERC20Bridge.sol
            └── L2Weth.sol
```

## System Overview

The first scope introduces changes to the way gas is handled in Layer 2 (L2) calls. Most importantly, whenever the `MsgValueSimulator` is invoked, the contract now explicitly withholds the gas reserved for decommitting the called contract as well as any gas that was reserved for the ETH transfer operations but was not consumed. In this way, the gas provided to the called contract can be closely (but not perfectly) controlled. This is needed to ensure `.transfer` and `.send` operations receive a predictable gas stipend.

It's worth noting that while the smart contract updates were reviewed, the code that assigns the gas limit to the `MsgValueSimulator` call is contained in the VM and was not in scope. The Matter Labs team is encouraged to introduce tests for the possible use cases to ensure they behave as expected. These should include the `.transfer` and `.send` operations as well as regular value-bearing calls.

The pull request also introduces a minor optimization where precompiles that are only used to burn gas do not validate that there is sufficient gas, since no actual work will be completed anyway.

The second scope introduces a new `L2Weth` contract, which functions like the Layer 1 (L1) version except:

- It follows the `IL2StandardToken` interface.
- It does not have a silent fallback function that implements [risky "phantom" functions](https://media.dedaub.com/phantom-functions-and-the-billion-dollar-no-op-c56f062ae49f), although it can still receive L2 ETH directly.
- It includes native [permit functionality](https://eips.ethereum.org/EIPS/eip-2612).
- It is upgradeable for now.

It also makes some incremental improvements to the token bridge:

- It allows users to specify an L2 refund recipient address to receive the funds if the deposit fails.
- There is an administrator-controlled limit on the total deposit amount per L1 token per user that can cross the bridge.

   

## Security Model and Privileged Roles

The basic trust assumptions of the system have not been changed by these modifications. In particular:

- The governor address is able to upgrade the bridge contracts, and the L2 token contracts.
- The governor can also upgrade the new `Weth` contract.
- The governor also controls the AllowList that determines:
  - Which addresses can use the bridge.
  - The deposit limit per L1 token per user.

In addition to configuring and managing the system, these powers imply that the governor currently has access to all the funds in the system.

## Medium Severity

### Fragile Deposit Limit

The `L1ERC20Bridge` contract [prevents deposits over a configurable limit](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L178) for some tokens. This is achieved by [recording deposits](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L352) for deposit-limited tokens, [rewinding the update](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L349) if the deposit failed, and [ignoring](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L346) tokens that are not limited. This introduces an edge case that could lead to loss of funds:

- A user initiates a deposit that will fail to execute on L2 using a token with no deposit limit. Therefore, the deposit is not recorded.
- A deposit limit is [introduced](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/common/AllowList.sol#L135) for the token.
- The user will be unable to [claim the failed deposit](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L249), because the [attempt to rewind](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L349) the (non-existent) deposit update will fail.

Consider simply clearing the deposit record if the amount to claim exceeds the recorded value. Alternatively, consider [recording deposits](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L352) for all tokens, whether or not they have a deposit limit.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *The deposit limiting feature is currently turned off in the network. We will revisit this issue if we decide to turn on the feature.*

## Low Severity

### Unsafe ABI Encoding

It is not an uncommon practice to use `abi.encodeWithSignature` or `abi.encodeWithSelector` to generate calldata for a low-level call. However, the first option is not typo-safe and the second option is not type-safe. The result is that both of these methods are error-prone and should be considered unsafe.

On [line 151](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2ERC20Bridge.sol#L151) of [`L2ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2ERC20Bridge.sol) an unsafe ABI encoding is used.

Consider replacing this occurrence with `abi.encodeCall`, which checks whether the supplied values actually match the types expected by the called function and also avoids errors caused by typos. Note that this will require a version greater than `Solidity 0.8.11`. However, it is recommended to use Solidity `0.8.13` or above since there was a [bug detected](https://blog.soliditylang.org/2022/03/16/encodecall-bug/) regarding fixed-length bytes literals. While this bug does not currently affect the codebase, using an updated version will remove the possibility of future errors.

***Update:** Resolved in [pull request #132](https://github.com/matter-labs/zksync-2-contracts/pull/132) at commit [fb2ab16](https://github.com/matter-labs/zksync-2-contracts/pull/132/commits/fb2ab1648591e1f6f55636bd0e8bdc773e6ee162).*

### Missing Error Messages in `require` Statements

Throughout the [codebase](https://github.com/matter-labs/system-contracts/tree/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/) there are `require` statements that lack error messages:

- The `require` statement on [line 46](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/L1Messenger.sol#L46) of [`L1Messenger.sol`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/L1Messenger.sol)
- The `require` statement on [line 168](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/libraries/SystemContractHelper.sol#L168) of [`SystemContractHelper.sol`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/libraries/SystemContractHelper.sol)

Consider including specific, informative error messages in `require` statements to improve overall code clarity and facilitate troubleshooting whenever a requirement is not satisfied.

***Update:** Resolved in [pull request #265](https://github.com/matter-labs/system-contracts/pull/265) at commit [589d582](https://github.com/matter-labs/system-contracts/pull/265/commits/589d5822c4216bddbbae79032060a3cb55a9f09d).*

### Unreplenishable Deposit Limit

When users transfer ERC-20 tokens over the bridge, they [consume part of their deposit limit](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L352), which is never replaced. This introduces the possibility that an address can reach the limit and be unable to use the bridge until the limit is increased or removed for everybody. It is likely that the limits will be configured to exceed most legitimate use cases.

Nevertheless, in the interest of flexibility, consider introducing a mechanism for the administrator to reset or replenish a user's allowance.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *The deposit limiting feature is currently turned off in the network. We will revisit this issue if we decide to turn on the feature.*

### Bridge Cannot Recover Funds

The `BridgeInitializationHelper` contract [sets the message sender](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/libraries/BridgeInitializationHelper.sol#L46) as the refund recipient for its cross-domain messages. This pattern assumes that the message sender will independently recover the funds if necessary. However, in this case, the message sender is the [`L1ERC20Bridge` contract](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol), which has no mechanism to initiate the withdrawal. Therefore, if either the implementation or proxy deployment transaction fails, the deployment fee will be trapped on Layer 2.

Consider using [the governor address](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L82) as the refund recipient instead.

***Update:** Resolved in [pull request #136](https://github.com/matter-labs/zksync-2-contracts/pull/136) at commit [0437f63](https://github.com/matter-labs/zksync-2-contracts/pull/136/commits/0437f63751fd4bca6f39309cd0d8e93b8e7fe0f7).*

### Missing and Misleading Documentation

The following parts of the codebase are lacking documentation:

- In the `BridgeInitializationHelper` contract:
  - The `requestDeployTransaction` function is missing the `@param` statement for the [`_zkSync` parameter](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/libraries/BridgeInitializationHelper.sol#L29).
- In the `L1ERC20Bridge` contract:
  - The `initialize` function is missing the `@param` statements for the [fee parameters](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L83-L84).
- In the `Mailbox` contract:
  - The [`l2TransactionBaseCost` function](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/zksync/facets/Mailbox.sol#L144) is missing all `@param` statements.
  - The [`_deriveL2GasPrice` function](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/zksync/facets/Mailbox.sol#L156) is missing the `@return` statement.
  - The `_getOverheadForTransaction` function is missing the `@param` statements for [two parameters](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/zksync/facets/Mailbox.sol#L452-L453).
- In the [`L2ContractHelper.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/L2ContractHelper.sol#L4-L5) file:
  - The library functions, interfaces, and struct are missing documentation.

The following documentation is misleading:

- In the `L2Weth` contract:
  - The `initialize` function's documentation [claims](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2Weth.sol#L34) it stores the L1 address of the bridge, but it does not.
  - The `bridgeMint` function's documentation [references](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2Weth.sol#L63) the `StandardToken` interface instead of the `IL2StandardToken` interface. It should also indicate that the function always reverts.
  - The [first](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2Weth.sol#L66) `bridgeMint` function parameter is annotated with `"_to"` but the parameter is [named `_account`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/interfaces/IL2StandardToken.sol#L12).
  - The `bridgeBurn` function [claims](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2Weth.sol#L77) to burn tokens from `"_from" WETH contract` instead of the `"_from" address`.
- In the `L1ERC20Bridge` contract:
  - The `l2TokenBeacon` variable is [described](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L47) as a factory, but it is actually a beacon.

Consider including thorough and correct docstrings and inline explanations with references to relevant source files or documentation, allowing readers or maintainers to verify the implementations and their correct usage.

***Update:** Resolved in [pull request #135](https://github.com/matter-labs/zksync-2-contracts/pull/135) at commit [c415ce5](https://github.com/matter-labs/zksync-2-contracts/pull/135/commits/c415ce5c7ed1daf8a7a2624ae8da4370d667457c).*

## Notes & Additional Information

### State Variable Visibility Not Explicitly Declared

Throughout the [codebase](https://github.com/matter-labs/zksync-2-contracts/tree/c44852f89f443bbe8120a7c6abcc6984b394eb29/) there are state variables that lack an explicitly declared visibility:

- The state variable [`allowList`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L31) in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol)
- The state variable [`zkSync`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L34) in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol)
- The state variable [`l2TokenProxyBytecodeHash`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2ERC20Bridge.sol#L28) in [`L2ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2ERC20Bridge.sol)

For clarity, consider always explicitly declaring the visibility of variables, even when the default visibility matches the intended visibility.

***Update:** Resolved in [pull request #140](https://github.com/matter-labs/zksync-2-contracts/pull/140) at commit [459918a](https://github.com/matter-labs/zksync-2-contracts/pull/140/commits/459918a37f0e8564045fd14691c271b99b8f3362).*

### Unused Imports

Throughout the [codebase](https://github.com/matter-labs/system-contracts/tree/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/) there are imports that are unused and could be removed:

- Import [`MAX_MSG_VALUE`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/MsgValueSimulator.sol#L8) of [`MsgValueSimulator.sol`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/MsgValueSimulator.sol)
- Import [`MSG_VALUE_SYSTEM_CONTRACT`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/libraries/SystemContractHelper.sol#L5) of [`SystemContractHelper.sol`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/libraries/SystemContractHelper.sol)
- Import [`Utils`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/libraries/SystemContractHelper.sol#L8) of [`SystemContractHelper.sol`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/libraries/SystemContractHelper.sol)

Consider removing unused imports to improve the overall clarity and readability of the codebase.

***Update:** Resolved in [pull request #269](https://github.com/matter-labs/system-contracts/pull/269) at commit [b868f4a](https://github.com/matter-labs/system-contracts/pull/269/commits/b868f4a71c17ee59ab57f1436c0d44eb21e04873).*

### Multiple Declarations per File

Within [`SystemContractHelper.sol`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/libraries/SystemContractHelper.sol), both the `SystemContractHelper` library and the abstract contract `ISystemContract` are declared.

Consider separating the contracts into their own files to make the codebase easier to understand for developers and reviewers.

***Update:** Resolved in [pull request #270](https://github.com/matter-labs/system-contracts/pull/270) at commit [5a48644](https://github.com/matter-labs/system-contracts/pull/270/commits/5a486442cb1309545655a44e61c281ebafc3f7ce).*

### Typographical Errors

Throughout the codebase we identified the following typographical errors:

- `zkSync v2.0` → `zkSync Era` in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L24)
- `do` → `does` in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L137)
- `finalisation` → `finalization` in [`L1ERC20Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/L1ERC20Bridge.sol#L156) and in [`Mailbox.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/zksync/facets/Mailbox.sol#L203) for consistency
- `can not` → `cannot` in [`L2Weth.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2Weth.sol#L52-L53)

Consider correcting these typographical errors.

***Update:** Resolved in [pull request #138](https://github.com/matter-labs/zksync-2-contracts/pull/138) at commit [4f984e6](https://github.com/matter-labs/zksync-2-contracts/pull/138/commits/4f984e6c81492d81f662f1d034b931ac924fdaf9).*

### Naming Suggestions

To favor explicitness and readability, there are two locations in the contracts that may benefit from better naming:

- The function [`requestDeployTransaction`](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/bridge/libraries/BridgeInitializationHelper.sol#L28) is `internal` and thus could be prepended with an underscore. Consider renaming the function to `_requestDeployTransaction`.
- The variable [`unspendGas`](https://github.com/matter-labs/system-contracts/blob/ce6c3458f0f16d20ac335071de161a986a4ecb0d/contracts/MsgValueSimulator.sol#L84) could be renamed to `unspentGas`.

Consider renaming these variables to be more consistent.

***Update:** Resolved in [pull request #267](https://github.com/matter-labs/system-contracts/pull/267) at commit [2382fa2](https://github.com/matter-labs/system-contracts/pull/267/commits/2382fa23dc69dd946374897d6c4683527f839de0). The Matter Labs team stated:*

> *Our convention is not to prefix internal methods with an underscore in libraries, so we will not change the naming of `requestDeployTransaction`.*

### Use `assert` for Inviolable Conditions

When finalizing deposits on Layer 2, the `L2ERC20Bridge` contract checks [one of two consistency conditions](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/zksync/contracts/bridge/L2ERC20Bridge.sol#L78-L81). Since these should never fail for any user input, consider [using `assert` statements](https://docs.soliditylang.org/en/v0.8.19/control-structures.html#panic-via-assert-and-error-via-require) instead of `require` statements. This indicates that the conditions should be inviolable, and is better suited for analysis tools that attempt to prove this claim or identify counterexamples.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *Although `assert` might logically seem like a better option, `require` is easier to debug. We will leave the `require` statement in place for now.*

### Unexpected Address Aliasing

When constructing Layer 1 (L1) to Layer 2 (L2) messages, the `Mailbox` contract [aliases the refund recipient](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/zksync/facets/Mailbox.sol#L290) if it corresponds to a deployed L1 smart contract. This makes sense when the address is known to be associated with that smart contract, such as when it is [initialized to the message sender](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/zksync/facets/Mailbox.sol#L286). However, if it is [chosen by the user](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/zksync/facets/Mailbox.sol#L220) to be an L2 address, applying the alias could bypass the user's intention.

In particular, users will be unable to choose an L2 refund recipient that has the same address as an existing L1 smart contract. If a user inputs this address as the refund recipient, it will be aliased and the intended L2 contract will be unable to control the funds. Instead, the funds would be controlled by the L1 smart contract, which the user may not even control.

In the current deployment, this scenario should be impossible because L1 and L2 addresses are derived differently, but [this decision is not settled](https://github.com/matter-labs/zksync-2-contracts/blob/c44852f89f443bbe8120a7c6abcc6984b394eb29/ethereum/contracts/zksync/facets/Mailbox.sol#L223). In the interest of predictability, consider leaving the refund recipient unaliased if it is explicitly chosen by the user to be an L2 address.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *We will take this into account when and if we change the address derivation rule.*

## Conclusions

This audit was conducted over the course of a week, and we uncovered a handful of medium and lower-severity issues.

## Appendix

### Monitoring Recommendations

While audits help in identifying code-level issues in the current implementation and potentially the code deployed in production, the Matter Labs team is encouraged to consider incorporating monitoring activities in the production environment. Ongoing monitoring of deployed contracts helps in identifying potential threats and issues affecting the production environment. Below is a new recommendation to augment the ones provided in previous audits.

#### Financial

**Medium:** It was previously recommended to monitor the size, cadence and token type of bridge transfers during normal operations to establish a baseline of healthy properties. Any large deviation, such as an unexpectedly large withdrawal, may indicate unusual behavior of the contracts or an ongoing attack. In addition, consider identifying whenever a user approaches or reaches the new deposit limit for any token. This could also indicate unusual behavior or an ongoing attack, or it could imply that the token deposit limit is too restrictive.
