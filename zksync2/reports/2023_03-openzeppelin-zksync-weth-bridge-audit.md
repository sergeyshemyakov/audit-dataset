# zkSync WETH Bridge Audit

Source: [https://www.openzeppelin.com/news/zksync-weth-bridge-audit](https://www.openzeppelin.com/news/zksync-weth-bridge-audit)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Security Model and Privileged Roles](#security-model-and-privileged-roles)
- [Medium Severity](#medium-severity)
  - [ETH Can Be Locked Through Address Aliasing](#eth-can-be-locked-through-address-aliasing)
- [Low Severity](#low-severity)
  - [Entanglement of Initialization and ReentrancyGuard](#entanglement-of-initialization-and-reentrancyguard)
  - [Funds Can Get Lost in WETH Bridge](#funds-can-get-lost-in-weth-bridge)
  - [Interface Mismatch](#interface-mismatch)
  - [Missing Docstrings](#missing-docstrings)
- [Notes & Additional Information](#notes-additional-information)
  - [Unused Imports](#unused-imports)
  - [Non-Explicit Imports Are Used](#non-explicit-imports-are-used)
  - [Misleading Documentation](#misleading-documentation)
  - [Keyword payable Is Missing in Interface](#keyword-payable-is-missing-in-interface)
  - [Naming Suggestions](#naming-suggestions)
- [Monitoring Recommendations](#monitoring-recommendations)
  - [Governance](#governance)
  - [Technical](#technical)
  - [Financial](#financial)
  - [Suspicious Activity](#suspicious-activity)
- [Conclusions](#conclusions)

## Summary

Type
:   Layer 2

Timeline
:   From 2023-03-27
:   To 2023-03-31

Languages
:   Solidity

Total Issues
:   10 (6 resolved, 2 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   1 (0 resolved)

Low Severity Issues
:   4 (2 resolved, 1 partially resolved)

Notes & Additional Information
:   5 (4 resolved, 1 partially resolved)

Client Reported Issues
:   0 (0 resolved)

## Scope

We audited the `matter-labs/zksync-2-contracts` repository at the [4346dfc55a3c56817934a1231b64d6ef246074a7](https://github.com/matter-labs/zksync-2-contracts/tree/4346dfc55a3c56817934a1231b64d6ef246074a7) commit.

In scope were the following contracts:

```
 ├── ethereum
│   └── contracts
│       └── bridge
│           ├── L1WethBridge.sol
│           └── interfaces
│               ├── IL2Bridge.sol
│               └── IL2WethBridge.sol
└── zksync
    └── contracts
        └── bridge
            ├── L2WethBridge.sol
            └── interfaces
                └── IL2Bridge.sol
```

## System Overview

This audit focuses on the functionality of the L1/L2 (Layer 1 / Layer 2) WETH Bridges. We found the system to be modular and well-documented.

   

The new WETH bridge exclusively handles transfers of WETH tokens between the two domains. It is worth noting that although it does not support ETH transfers, it is possible to send an arbitrary amount of ETH along with any token deposit.

The following process describes bridging WETH from L1 to L2:

1. A WETH token is deposited into `L1WethBridge`.
2. The `L1WethBridge` unwraps this WETH to ETH.
3. The `L1WethBridge` transmits the ETH to `L2WethBridge` through the `Mailbox`.
4. The `L2WethBridge` wraps the ETH back to WETH to the user-specific recipient address. This is done by depositing the value into the L2 WETH contract and minting the token.

The process of withdrawing WETH from L2 to L1 is the following:

1. The `L2WethBridge` unwraps the L2 WETH to ETH by burning the token and receiving the L2 ETH.
2. The L2 ETH is withdrawn through the `L2EthToken`, thereby burning the ETH and emitting a log to L1.
3. When the withdrawal is finalized through the `L1WethBridge`, the previously deposited L1 ETH is wrapped and sent to the user-specified address.

## Security Model and Privileged Roles

The security of the system in scope depends on the governor of the respective contracts.

The L1 WETH token is expected to be trusted and immutable. The L1/L2 WETH bridge as well as the L2 WETH token are upgradeable. This is managed by a governor. A malicious upgrade to any of these contracts would allow an attacker to steal funds. For example, a malicious upgrade of `L1WethBridge` could change the WETH destination from the user's address to the attacker's address. A malicious `L2WethBridge` upgrade could unwrap someone's L2 WETH to L2 ETH for the attacker to then legitimately withdraw the ETH to L1. Finally, a malicious `L2Weth` token could transfer its deposited L2 ETH and bridge it back to L1.

The L1 WETH bridge implements the `AllowList` access control. This mechanism enables restriction for functions and callers. Hence, a function can be fully inaccessible, or only accessible to specific addresses.

It is strongly advised that the governors and owners of these contracts are extensively secured through cold wallets and multisigs. Further, it is assumed that these actors will act in the best interest of the users.

The zkSync system requires a dedicated operator role to coordinate and bundle all L2 transactions. Currently, the operator will be centralized through Matter Labs with the goal of decentralizing it in the medium-term future. The operator has the privilege to include or exclude any transaction they choose. The [priority mode](https://era.zksync.io/docs/dev/developer-guides/bridging/l1-l2-interop.html#priority-mode) censoring protection mechanism is still to be implemented. Furthermore, as part of the fee model at the current stage of the protocol, the operator is trusted to pick a fair L1 gas price, which influences the L2 fees paid by the user.

## Medium Severity

### ETH Can Be Locked Through Address Aliasing

Whenever interacting with L2 from L1, either through the `Mailbox.requestL2Transaction` or the `L1WethBridge.deposit` function, the user can specify a refund recipient address. This address receives a refund (on L2) of any excessive ETH provided, up to a full refund in the case of a reverting transaction.

When calling one of the above functions, which refund recipient is chosen and whether that address is aliased depends on the provided `_refundRecipient` parameter, as well as `msg.sender`. The checks that differentiate these conditions can be seen in the `Mailbox` facet [[1]](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/zksync/facets/Mailbox.sol#L216-L219) [[2]](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/zksync/facets/Mailbox.sol#L278-L279), [`L1WethBridge` contract](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L170-L172), and [`_requestL2Transaction` function](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/zksync/facets/Mailbox.sol#L280-L283). The outcome of the used refund recipient is condensed into the following table:

| `msg.sender` | `_refundRecipient` | | |
| --- | --- | --- | --- |
|  | **Is Zero** | **Is L1 Contract** | **Is L1 EOA** |
| **Is L1 Contract** | aliased `msg.sender` (\*) | aliased `_refundRecipient` (\*) | `_refundRecipient` |
| **Is L1 EOA** | `msg.sender` | aliased `_refundRecipient` (\*) | `_refundRecipient` |

Firstly, the cases (\*) where the refund will be sent to an aliased address on L2 are confusing and error-prone, especially since the docstring states that the `_refundRecipient` is ["The address on L2 that will receive the refund for the transaction"](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L144-L145). Secondly, it is possible that the caller has no control over that address, thereby locking the ETH. An exception to this occurs if the L1 contract is able to initiate arbitrary L2 transaction requests, such that the caller can act as the aliased address through the `Mailbox` to transfer or withdraw the ETH.

It is noted that in a previous report, this issue was presented and a fix was attempted at commit `201c99c`. While OpenZeppelin's previous review had deemed this fixed, upon further review, it has now been identified that this issue persists.

As of March 30th, 2023, the [`Mailbox` contract](https://etherscan.io/address/0x2ea0cfb9c942058ee5a84411ef2e37c6de5bfe5c#code#F11#L247) on mainnet appears to be affected by this issue. Thus, under the conditions above, users are currently at risk of having their ETH locked in a L2 address that they do not control. While the [developer documentation](https://era.zksync.io/docs/dev/developer-guides/bridging/l1-l2.html#interface) provides warnings regarding aliasing, it is still possible for users (particularly those less familiar with the inner workings of the system) to have their ETH locked.

The reasoning for the address aliasing of the refund recipient is unclear at the moment. It is understood that applying address aliasing to the `msg.sender` can help prevent cross-chain attacks. However, consider removing address aliasing for the refund recipient. In addition, consider requiring that a refund recipient is always provided.

***Update:** Acknowledged, not resolved. The Matter Labs team stated:*

> *Users can specify the needed refund receiver to eliminate the risk of a smart contract refund recipient that is not able to get the funds back. That being said, we agree that mandatory parameter is a cleaner option, but whether it is the better foolproof approach is debatable. As an example, one of our partners that are building a bridge asked us to implement this. Also, users seem to be used to this approach on Arbitrum, and since it is battle-tested, the risk is rather small. Lastly, the ERC-20 bridge was deployed on production and it is highly undesirable to change its behavior without an important reason. Thank you for highlighting the issue, we will keep eye on it.*

## Low Severity

### Entanglement of Initialization and `ReentrancyGuard`

The [`L1WethBridge`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol) is the implementation contract that is intended to be used with a proxy. As such, it is a good practice to restrict how it can be invoked directly. The `reentrancyGuardInitializer` modifier is used for the `constructor` and `initialize` functions as a means to prevent an attacker from (re-)initialization of the implementation and proxy contracts. This is realized by updating the value of the pseudo-random storage location [`LOCK_FLAG_ADDRESS`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/common/ReentrancyGuard.sol#L27).

Two functions in `L1WethBridge`, [`deposit`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L154) and [`finalizeWithdrawal`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L225), use the `nonReentrant` modifier for protection against reentrancy. This modifier works by also updating the value at the same `LOCK_FLAG_ADDRESS` storage location. While there is currently no identifiable vulnerability with this methodology, using one storage slot to serve these two purposes entangles the two attack surfaces and goes against the general programming principles of modularization. By separating these two concerns, the codebase can be easier to comprehend, especially when adding future functionality and complexity.

Consider splitting up the functionality of the `ReentrancyGuard` contract as described above. This can be realized by adding a dedicated `Initializable` contract to prevent initialization attacks through an `initializer` modifier and `_disableInitializers` function, while keeping the `ReentrancyGuard` contract to prevent reentrancy attacks. It is highly advised to thoroughly test this code change for the `L1WethBridge`, but also for any other contracts that rely on the current `ReentrancyGuard`.

***Update:** Acknowledged, will resolve. The Matter Labs team stated:*

> *This is planned for the refactoring. The proposed approach seems much cleaner, but we will not implement it in the current upgrade due to the complexity of the migration and its associated risk.*

### Funds Can Get Lost in WETH Bridge

The WETH bridging involves multiple steps of handling and transferring funds. One of these steps is swapping the WETH token to ETH that is sent from the WETH contract to the L1 or L2 bridge. Hence, the [`L1WethBridge`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L293) and [`L2WethBridge`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L116) contracts have a `receive` function that logs the ETH that is received. If a user or a contract sends ETH directly to either the L1 or the L2 bridge, it will be irrecoverable.

Since the bridge contracts are only expected to receive ETH from the WETH contracts, consider adding a check that restricts any other addresses from sending ETH to the bridge.

***Update:** Resolved in [pull request #113](https://github.com/matter-labs/zksync-2-contracts/pull/113) at commit [5dc8067](https://github.com/matter-labs/zksync-2-contracts/pull/113/commits/5dc80679654e6d6fa59ac664f0e2646a25605df0).*

### Interface Mismatch

The `L2WethBridge` utilizes the `L2EthToken` contract to bridge ETH from L2 to L1. The WETH bridge passes along additional data that encodes the recipient of the wrapped ETH on L1. Following the latest code change before this audited commit, this is realized through the [`withdrawWithMessage`](https://github.com/matter-labs/system-contracts/pull/255/commits/e4fac9ef78633c1e99bf8b6fd72c4bccc3b0325a#diff-7c33f838e1fa17c209769263848cb442562f50dbd89946ef2621ae0202d591f4R89-L86) function, which was renamed from `withdraw`. However, the `L2WethBridge` still calls the outdated [`withdraw` function](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L75) with the respective parameters.

Consider updating the interface to match the latest implementation and guarantee the functionality of the bridge.

***Update:** Resolved in [pull request #114](https://github.com/matter-labs/zksync-2-contracts/pull/114) at commit [664a2df](https://github.com/matter-labs/zksync-2-contracts/pull/114/commits/664a2df0a905c19a10c3ba860406c4cad8983b4c).*

### Missing Docstrings

Throughout the [codebase](https://github.com/matter-labs/zksync-2-contracts/tree/4346dfc55a3c56817934a1231b64d6ef246074a7/), there are several parts that do not have docstrings:

- [`ethereum/contracts/bridge/interfaces/IL2Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/interfaces/IL2Bridge.sol)
- [`ethereum/contracts/bridge/interfaces/IL2WethBridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/interfaces/IL2WethBridge.sol)
- [`zksync/contracts/bridge/interfaces/IL2Bridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/interfaces/IL2Bridge.sol)
- [Line 46](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L41-L46) in [`L2WethBridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol)

Consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html) (NatSpec).

***Update:** Partially resolved in [pull request #115](https://github.com/matter-labs/zksync-2-contracts/pull/115) at commit [dd9533b](https://github.com/matter-labs/zksync-2-contracts/pull/115/commits/dd9533b5ffde3e1aeaf76cb36bf525e18e9ca948). The Matter Labs team stated:*

> *We don't usually write documentation for interfaces, since it ends up with duplicated doc-comments.*

## Notes & Additional Information

### Unused Imports

Throughout the [codebase](https://github.com/matter-labs/zksync-2-contracts/tree/4346dfc55a3c56817934a1231b64d6ef246074a7/), the following imports are unused and could be removed:

- Import [`IL2ContractDeployer`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L13) of [`L1WethBridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol)
- Import [`TransparentUpgradeableProxy`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L5) of [`L2WethBridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol)
- Import [`IL1Bridge`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L8) of [`L2WethBridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol)
- Import [`L2Weth`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L15) of [`L2WethBridge.sol`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol)

Consider removing unused imports to improve the overall clarity and readability of the codebase.

***Update:** Resolved in [pull request #116](https://github.com/matter-labs/zksync-2-contracts/pull/116) at commit [e577cae](https://github.com/matter-labs/zksync-2-contracts/pull/116/commits/e577caeb1230debeb53b0833b60ccd20264a3775).*

### Non-Explicit Imports Are Used

The use of non-explicit imports in the codebase can decrease the clarity of the code. This is particularly relevant when multiple constructs exist within the same Solidity file. For instance, the following two imports provide constants to the contract, but this is not obvious from just reading the import statements of `L2ContractAddresses` and `L2ContractHelper`:

- [`L2ContractAddresses`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L21) in `L1WethBridge.sol`
- [`L2ContractHelper`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L13) in `L2WethBridge.sol`

Consider applying an explicit import format to specify which constants are imported.

***Update:** Resolved in [pull request #117](https://github.com/matter-labs/zksync-2-contracts/pull/117) at commit [802fd24](https://github.com/matter-labs/zksync-2-contracts/pull/117/commits/802fd2471bd4d09d93820c189d184d7ecb47b949).*

### Misleading Documentation

The following documentation is misleading:

- The comment on the [`refundRecipient` address](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L168) says "Please note, if the recipient is a contract (the only exception is a contracting contract, but it is shooting in the leg)", which does not make sense.
- The comment on the [`claimFailedDeposit` function](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L200) says "Refund is performed by sending an equivalent amount of ETH to the refund recipient address on L2." However, the refund is actually obtained by directly calling the [`withdraw`](https://github.com/matter-labs/system-contracts/blob/e4fac9ef78633c1e99bf8b6fd72c4bccc3b0325a/contracts/L2EthToken.sol) or [`withdrawWithMessage`](https://github.com/matter-labs/system-contracts/blob/e4fac9ef78633c1e99bf8b6fd72c4bccc3b0325a/contracts/L2EthToken.sol#L89) methods in `L2EthToken`.
- This [`revert` message](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L210) says that "ETH refund is handled by the zkSync contract." It should be more explicit and state that the ETH refund is handled by the `L2EthToken` contract.
- This [comment](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L263-L264) should say `additionalData` instead of `additonalData`.

Consider rephrasing misleading comments to match the intention of the code.

***Update:** Resolved in [pull request #118](https://github.com/matter-labs/zksync-2-contracts/pull/118) at commit [fbc9c01](https://github.com/matter-labs/zksync-2-contracts/pull/118/commits/fbc9c01c0580404e6b50a4f809d5da60dde03550). The Matter Labs team stated:*

> *Regarding the `claimFailedDeposit` comments, it is correct. If the deposit transaction fails, the associated ETH will be sent to the deposit refund recipient's address.*

### Keyword `payable` Is Missing in Interface

The [`IL2Bridge` interface](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/interfaces/IL2Bridge.sol#L6) within the `ethereum` folder structure is primarily used for [encoding `calldata`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L194) that is sent to L2. One of these functions is `finalizeDeposit`, which must be payable. Whenever a non-payable function is overridden with a payable function, a compiler error is thrown. Because this interface is not being inherited and overridden, this is currently not a problem.

However, consider adding the `payable` keyword in the interface to ensure correctness and alignment in the future.

***Update:** Resolved in [pull request #119](https://github.com/matter-labs/zksync-2-contracts/pull/119) at commit [b4c8e1b](https://github.com/matter-labs/zksync-2-contracts/pull/119/commits/b4c8e1b229a85d60bdb21b09fa94718e78e469bc).*

### Naming Suggestions

To favor explicitness and readability, there are two locations in the contracts that may benefit from better naming:

- The [`l2ProxyWethAddress`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L56) name is inconsistent with [`l2WethAddress`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L34). Consider renaming both variables to `l2WethProxyAddress` for consistency with each other and with the naming convention of the [ERC20 Bridges](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1ERC20Bridge.sol#L53).
- The [`L2_ETH_TOKEN_SYSTEM_CONTRACT_ADDR`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/ethereum/contracts/bridge/L1WethBridge.sol#L234) name is inconsistent with [`L2_ETH_ADDRESS`](https://github.com/matter-labs/zksync-2-contracts/blob/4346dfc55a3c56817934a1231b64d6ef246074a7/zksync/contracts/bridge/L2WethBridge.sol#L75) and [`ETH_TOKEN_SYSTEM_CONTRACT`](https://github.com/matter-labs/system-contracts/blob/e4fac9ef78633c1e99bf8b6fd72c4bccc3b0325a/contracts/MsgValueSimulator.sol#L40).

Consider renaming these variables to be more consistent.

***Update:** Partially resolved in [pull request #120](https://github.com/matter-labs/zksync-2-contracts/pull/120) and commit [d549055](https://github.com/matter-labs/zksync-2-contracts/pull/120/commits/d549055f84c17ee40953e08d8735757816a250a1). Regarding the first bullet point, the Matter Labs team applied consistency by renaming `l2ProxyWethAddress` to `l2WethAddress` in the `L1WethBridge` contract. Regarding the second bullet point they stated:*

> *The second comment requires changing the naming across the repos and careful refactoring, so we will postpone it.*

## Monitoring Recommendations

While audits help in identifying potential security risks, the Matter Labs team is encouraged to also incorporate automated monitoring of on-chain contract activity into their operations. Ongoing monitoring of deployed contracts helps in identifying potential threats and issues affecting the production environment. Note that the following recommendations are partly similar to the ones of the prior `ERC20Bridge` audit.

### Governance

**Critical:** The `L1WethBridge` and `L2WethBridge` contracts are both upgradeable. The `L1WethBridge` could be upgraded to maliciously re-route the wrapping of ETH to WETH and the `L2WethBridge` has the power to mint WETH on L2. Hence, any malicious upgrades to these contracts pose a huge risk, which should be closely monitored. Furthermore, consider monitoring the upgradeable `L2Weth` dependency for any code changes, as this can also be maliciously used to drain the deposited funds on L1.

**Critical:** Another dependency is the `AllowList` contract that can restrict the `finalizeWithdrawal` function of the `L1WethBridge` and the `finalizeEthWithdrawal` function of the `Mailbox`, to specific users or even disallow all users from calling these functions. In these cases, funds would be locked within the Diamond Proxy (Mailbox). Consider monitoring the `AllowList` contract for any unexpected changes.

### Technical

**High:** Monitor that the WETH amount deposited on L1 equals the minted amount on L2. Also, monitor that the burnt amount on L2 matches the withdrawn amount on L1. Any mismatch could mean a loss for the user or an attack on the protocol. Note that this will happen with a time delay, but these events can be seen in context through the recipient parameter.

**High:** Monitor that the Diamond Proxy (Mailbox) ETH balance is roughly equal to `L2EthToken.totalSupply` + `L2Weth.totalSupply`, with some tolerance (for example, within a 5% difference) to account for the time delay of bridge transfers.

### Financial

**Medium:** Consider monitoring the size and cadence of WETH bridge transfers during normal operations to establish a baseline of healthy properties. Any large deviation, such as an unexpectedly large L1 withdrawal or L2 mint, may indicate unusual behavior of the contracts or an ongoing attack.

### Suspicious Activity

**Low:** Withdrawals on L1 are not triggered automatically, and must instead be initiated by L1 users. Any withdrawal that takes too long to finalize may indicate a problem with the withdrawal proof. Consider monitoring for withdrawals that remain in transit for significantly longer than the median withdrawal duration.

## Conclusions

This was the second monthly Matter Labs audit done by the OpenZeppelin team this year. In the report, we uncovered a few issues in the new WETH bridge over the course of a week. The medium severity issue of locked-up ETH through address aliasing was particularly interesting. Overall, the code health was good and it was easy to reason about the individual contracts. It was especially good to see the smooth integration between previously audited contracts, such as the Mailbox, and this WETH bridge.
