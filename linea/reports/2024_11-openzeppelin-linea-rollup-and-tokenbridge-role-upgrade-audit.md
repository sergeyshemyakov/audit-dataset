# Linea Rollup and TokenBridge Role Upgrade

Source: [https://www.openzeppelin.com/news/linearollup-and-tokenbridge-role-upgrade](https://www.openzeppelin.com/news/linearollup-and-tokenbridge-role-upgrade)

- November 28, 2024

OpenZeppelin Security

OpenZeppelin Security

Security Audits

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
  - [Privileged Roles](#privileged-roles)
- [Medium Severity](#medium-severity)
  - [Denial of Service in Finalization Blocks Due to Fallback Operator Role Renunciation](#denial-of-service-in-finalization-blocks-due-to-fallback-operator-role-renunciation)
- [Low Severity](#low-severity)
  - [Missing Zero-Address Checks](#missing-zero-address-checks)
  - [Incorrect Docstrings](#incorrect-docstrings)
  - [Missing Docstrings](#missing-docstrings)
- [Notes & Additional Information](#notes-additional-information)
  - [Lack of Security Contact](#lack-of-security-contact)
  - [Lack of Indexed Event Parameters](#lack-of-indexed-event-parameters)
  - [Inconsistent Integer Base](#inconsistent-integer-base)
  - [Magic Numbers in the Code](#magic-numbers-in-the-code)
  - [Calls Can Be Front-Run](#calls-can-be-front-run)
  - [Function Visibility Overly Permissive](#function-visibility-overly-permissive)
  - [Inconsistent Use of whenTypeAndGeneralNotPaused Modifier](#inconsistent-use-of-whentypeandgeneralnotpaused-modifier)
- [Conclusion](#conclusion)
- [Appendix A](#appendix-a)

## Summary

Type
:   DeFi

Timeline
:   From 2024-11-04
:   To 2024-11-15

Languages
:   Solidity

Total Issues
:   11 (11 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   1 (1 resolved)

Low Severity Issues
:   3 (3 resolved)

Notes & Additional Information
:   7 (7 resolved)

## Scope

We performed a diff audit of the [Consensys/linea-monorepo repository](https://github.com/Consensys/linea-monorepo), comparing the commit tagged [contract-freeze-2024-11-01](https://github.com/Consensys/linea-monorepo/tree/contract-freeze-2024-11-01) with the commit tagged [contract-audit-2024-05-24](https://github.com/Consensys/linea-monorepo/tree/contract-audit-2024-05-24).

***Update**: We have completed the review of all submissions and finalized the audit report. The final commit reviewed is [a83412e](https://github.com/Consensys/linea-monorepo/commit/a83412e247b7d352b905c906271138e97c1ee5a4). We note that the additional changes to in-scope files since [adb097a](https://github.com/Consensys/linea-monorepo/commit/adb097aff4d7d32da843b16c9e1c1b21eecbf955) are related to fixes from audit engagements conducted concurrently with ours.*

*In addition, we have verified the deployed bytecode matches the code at [commit df30415](https://github.com/Consensys/linea-monorepo/commit/df304158985a85b9f80980475fbd74d7d3802034).*

In scope were the following files:

```
 contracts
├── LineaRollup.sol
├── ZkEvmV2.sol
├── interfaces
│   ├── IGenericErrors.sol
│   ├── IMessageService.sol
│   ├── IPauseManager.sol
│   ├── IPermissionsManager.sol
│   ├── IRateLimiter.sol
│   ├── l1
│   │   ├── IL1MessageManager.sol
│   │   ├── IL1MessageManagerV1.sol
│   │   ├── IL1MessageService.sol
│   │   ├── ILineaRollup.sol
│   │   ├── IPlonkVerifier.sol
│   │   └── IZkEvmV2.sol
│   └── l2
│       ├── IL2MessageManager.sol
│       └── IL2MessageServiceV1.sol
├── lib
│   ├── L2MessageServicePauseManager.sol
│   ├── LineaRollupPauseManager.sol
│   ├── PauseManager.sol
│   ├── PermissionsManager.sol
│   ├── TokenBridgePauseManager.sol
│   └── Utils.sol
└── messageService
│   ├── MessageServiceBase.sol
│   ├── l1
│   │   ├── L1MessageManager.sol
│   │   ├── L1MessageService.sol
│   │   ├── TransientStorageReentrancyGuardUpgradeable.sol
│   │   └── v1
│   │       ├── L1MessageManagerV1.sol
│   │       └── L1MessageServiceV1.sol
│   ├── l2
│   │   ├── L2MessageManager.sol
│   │   ├── L2MessageService.sol
│   │   └── v1
│   │       ├── L2MessageManagerV1.sol
│   │       └── L2MessageServiceV1.sol
│   └── lib
│       ├── MessageHashing.sol
│       ├── RateLimiter.sol
│       ├── SparseMerkleTreeVerifier.sol
│       ├── TimeLock.sol
│       └── TransientStorageHelpers.sol
└── tokenBridge
    ├── TokenBridge.sol
    ├── interfaces
    │   └── ITokenBridge.sol
    └── lib
        └── StorageFiller39.sol
```

## System Overview

The system under review has already been described in [our previous audit report](https://blog.openzeppelin.com/linea-blob-submission-audit). In this diff audit, we reviewed several significant changes made to the codebase, with the most notable ones being the following:

- **Removal of Block Numbers from Blob Submissions**: Block numbers were removed from blob submissions, events, and checks. Block numbers, which only become valid after verification, were eliminated to reduce gas and calldata costs and prevent confusion. The `shnarf` process now handles checks like empty `parentShnarf` and `finalStateRootHash`.
- **State Reconstruction-Compatible Events**: Events related to blob submission and finalization were modified to support L2 state reconstruction, removing the need for block numbers. This change simplifies data retrieval for state reconstruction.
- **Granular Role Reconfiguration and Updated `TokenBridge` Roles and Permissions**: Permissions across contracts were reworked to a more granular level to allow for finer control of access roles. These permissions will be set/reset as part of the upgrade transaction for `LineaRollup`, `L2MessageService`, and `TokenBridge`. In the `TokenBridge V2`, roles and permissions were further refined. The storage layout was adjusted to avoid data misalignment after the upgrade and slot data cleanup was performed.
- **Removal of Finalization without Proof**: The `finalizeBlocksWithoutProof` function was removed. Now, all finalizations must include a proof.
- **Permissionless Operator Role Grant**: A new permissionless function was added. This function grants the `OPERATOR_ROLE` to a pre-designated fallback operator address if no finalization has occurred in the last six months. If the current block time is greater than or equal to the last finalized timestamp plus six months, any address can call this function to assign the `OPERATOR_ROLE` to the fallback operator. Once assigned, anyone can finalize blocks through the fallback operator address. If regular finalizations resume, the security council can revoke the `OPERATOR_ROLE` from the fallback operator to reset the counter.

Other changes made to the codebase include changing the Solidity pragma to 0.8.26, code optimizations, improvements to errors, NatSpec additions, and the implementation of recommendations made in previous audits.

## Security Model and Trust Assumptions

The updates made to the contracts introduce role-based permissions for controlling access to business-critical functions. These changes have been implemented across the codebase, with particular focus on their application to the `TokenBridge` contract, as the update involves modifications to the storage layout of the `TokenBridge` proxy contract. Crucially, it is assumed that a pending owner has not been set in the `TokenBridge` contract and that the bridge will not be paused at the time of the upgrade.

Given that the audited codebase is an existing system, newly added initialization and reinitialization functions have been included in the `LineaRollup` and `TokenBridge` contracts. It is assumed that the deployments and initializations are done atomically to prevent the front-running of the initialization process. In addition, it is assumed that the correct values are passed during the upgrade in order to maintain consistency throughout the protocol and ensure correct initialization of the role-based access controls.

### Privileged Roles

As described above, extensive role-based permissions for access control have been introduced in the update. These affect multiple functions throughout the codebase. A comprehensive list of these privileged roles can be found in Appendix A of this report.

## Medium Severity

### Denial of Service in Finalization Blocks Due to Fallback Operator Role Renunciation

In the rollup contract, the [`setFallbackOperator` function](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L176) allows the [`fallbackOperator`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L82) to assume the `OPERATOR_ROLE` if six months have passed since the last finalization. The fallback operator is designed to be assigned to a publicly accessible address, such as a multicall address or well-known public key, allowing any user to initiate a finalization. Crucially, the `setFallbackOperator` function is only meant to be called in the worst-case scenario when the Linea team is unable to maintain the finalization of blocks. It, is in essence, a fallback of last resort.

However, this setup introduces a vulnerability: any user can call [`finalizeBlocks`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L430), which updates the [`currentFinalizedState`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L78) and advances the last finalized L2 block timestamp. The user can then [renounce](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/51e11611c40ec1ad772e2a075cdc8487bbadf8ad/contracts/access/AccessControlUpgradeable.sol#L179) the `OPERATOR_ROLE`, rendering the fallback address unable to regain the `OPERATOR_ROLE` for another six months. This renunciation-reset cycle can be repeated indefinitely, effectively preventing the fallback operator from maintaining a stable role and causing significant delays in the finalizations, up to six months each time. In the context of this worst-case scenario, it is unlikely that the Linea team would be able to intervene and set a new operator, making this a permanent issue.

Consider preventing the fallback operator address from being able to call `renounceRole`.

***Update:** Resolved in [pull request #298](https://github.com/Consensys/linea-monorepo/pull/298). The Linea team stated:*

> *Acknowledged. We have overridden the `renounceRole` function and the transaction now reverts if the account being reverted is the `fallbackOperator`.*

## Low Severity

### Missing Zero-Address Checks

When assigning an address from a user-provided parameter, it is crucial to ensure that the provided address is not zero. Setting an address to zero is problematic because it has special burn/renounce connotations. This action should be handled by a separate function to prevent accidental loss of access during value or ownership transfers.

Throughout the codebase, multiple instances of assignment operations missing zero-address checks were identified:

- The [`_defaultAdmin`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/l2/L2MessageService.sol#L56) assignment operation within the contract `L2MessageService` in `L2MessageService.sol`
- The [`_fallbackOperator`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L146) assignment operation within the contract `LineaRollup` in `LineaRollup.sol`
- The [`_tokens`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L356) assignment operation within the contract `TokenBridge` in `TokenBridge.sol`
- The [`_nativeTokens`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L373) assignment operation within the contract `TokenBridge` in `TokenBridge.sol`

Consider performing a zero-address check before assigning a state variable.

***Update:** Resolved in [pull request #305](https://github.com/Consensys/linea-monorepo/pull/305). The Linea team stated:*

> *Partially acknowledged:*
>
> 1. *`_defaultAdmin` and `_fallbackOperator` do not have checks.*
> 2. *`_tokens` and `_nativeTokens` will never encounter the scenario of an empty address because the transaction would revert upon token deployment checks.*
> 3. *`setCustomContract` and `setReserved` already have default checks.*
> 4. *We noticed that `_tokens` did not have an empty list check which we have now fixed as well.*

### Incorrect Docstrings

Throughout the codebase, multiple instances of incorrect or incomplete docstrings were identified:

- In the `IPlonkVerifier.sol` interface, the [`Verify`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/interfaces/l1/IPlonkVerifier.sol#L15) function has an incomplete docstring where the named return value is not documented.
- In the `LineaRollup` contract, the `shnarfFinalBlockNumbers` variable has been replaced with `blobShnarfExists`. The [newly added comment](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L73) for this variable repeats the `NB: NB:` characters.

Consider completing the return variable docstring for the `Verify` function of the `IPlonkVerifier` interface and correcting the additional comment on `blobShnarfExists`.

***Update:** Resolved in [pull request #304](https://github.com/Consensys/linea-monorepo/pull/304).*

### Missing Docstrings

Throughout the codebase, multiple instances of missing docstrings were identified:

- In `L1MessageManager.sol`, the [`rollingHashes` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/l1/L1MessageManager.sol#L18)
- In `L1MessageManager.sol`, the [`l2MerkleRootsDepths` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/l1/L1MessageManager.sol#L20)
- In `L2MessageManager.sol`, the [`lastAnchoredL1MessageNumber` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/l2/L2MessageManager.sol#L19)
- In `LineaRollup.sol`, the [`currentFinalizedShnarf` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L69)
- In `MessageServiceBase.sol`, the [`messageService` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/MessageServiceBase.sol#L14)
- In `MessageServiceBase.sol`, the [`remoteSender` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/MessageServiceBase.sol#L15)
- In `TokenBridge.sol`, the [`tokenBeacon` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L71)
- In `TokenBridge.sol`, the [`nativeToBridgedToken` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L73)
- In `ZkEvmV2.sol`, the [`currentL2BlockNumber` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/ZkEvmV2.sol#L21)
- In `ZkEvmV2.sol`, the [`stateRootHashes` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/ZkEvmV2.sol#L23)
- In `ZkEvmV2.sol`, the [`verifiers` state variable](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/ZkEvmV2.sol#L24)

Consider adding docstrings for the above-listed state variables, and also for the newly added role-related constants. In addition, consider adding a comment to the `SIX_MONTHS_IN_SECONDS` [constant](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L51) in the `LineaRollup` contract to note that the approximation of 6 months is intentional.

Overall, consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #307](https://github.com/Consensys/linea-monorepo/pull/307/files). The Linea team stated:*

> *Acknowledged. We adjusted the suggested contracts and additional areas as recommended.*

## Notes & Additional Information

### Lack of Security Contact

Providing a specific security contact (such as an email or ENS name) within a smart contract significantly simplifies the process for individuals to communicate if they identify a vulnerability in the code. This practice is quite beneficial as it permits the code owners to dictate the communication channel for vulnerability disclosure, eliminating the risk of miscommunication or failure to report due to a lack of knowledge on how to do so. In addition, if the contract incorporates third-party libraries and a bug surfaces in those, it becomes easier for their maintainers to contact the appropriate person about the problem and provide mitigation instructions.

Throughout the codebase, all contracts except the [`Utils` library](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/Utils.sol) have a security contact.

Consider adding a NatSpec comment containing a security contact above the library definition which conforms to the style used throughout the codebase: `@custom:security-contact security-report@linea.build`

***Update:** Resolved in [pull request #301](https://github.com/Consensys/linea-monorepo/pull/301). The Linea team stated:*

> *Acknowledged. We have added the NatSpec for the library title and the security contact.*

### Lack of Indexed Event Parameters

In the `IPauseManager.sol` interface, some of the events do not have indexed parameters:

- The [`PauseTypeRoleSet` event](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/interfaces/IPauseManager.sol#L58)
- The [`UnPauseTypeRoleSet` event](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/interfaces/IPauseManager.sol#L65)

To improve the ability of off-chain services to search and filter for specific events, consider [indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events).

***Update:** Resolved in [pull request #302](https://github.com/Consensys/linea-monorepo/pull/302). The Linea team stated:*

> *Acknowledged. The events are now indexed.*

### Inconsistent Integer Base

In assembly, memory offsets can be declared using decimals or hexadecimals. However, it is important to use a consistent notation to avoid confusion and to make it easy to understand the purpose and usage of these sizes.

In the [`LineaRollup`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L17-L694) contract, memory offsets have been declared inconsistently. [One memory offset has been declared](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L415) using decimals, while the rest have been declared using hexadecimals.

Consider using a consistent notation for expressing memory offsets throughout the codebase.

***Update:** Resolved in [pull request #300](https://github.com/Consensys/linea-monorepo/pull/300). The Linea team stated:*

> *Acknowledged. We are now using `0x20` instead of the 32 value.*

### Magic Numbers in the Code

Throughout the `TokenBridge` contract, multiple instances of literal values with unexplained meanings were identified:

- The [`32`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L513) literal number in `TokenBridge.sol`
- The [`64`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L526) literal number in `TokenBridge.sol`
- The [`32`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L528) literal number in `TokenBridge.sol`
- The [`32`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L535) literal number in `TokenBridge.sol`

Consider defining and using `constant` variables instead of using literals, or adding code comments (where appropriate) to improve the readability of the codebase.

***Update:** Resolved in [pull request #303](https://github.com/Consensys/linea-monorepo/pull/303). The Linea team stated:*

> *Acknowledged. This has been fixed with 3 constant values.*

### Calls Can Be Front-Run

Calls to EIP-2612's `permit()` or OpenZeppelin Governance's `delegateBySig()` functions can be front-run by a malicious actor. As a result, the user whose call has been front-run will not be able to perform any action once the call ends since their transaction will revert. The [`IERC20PermitUpgradeable(_token).permit(msg.sender, address(this), amount, deadline, v, r, s)`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L579) call in [`TokenBridge.sol`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol) is vulnerable to such a DoS attack.

Consider properly wrapping vulnerable calls within `try-catch` blocks to avoid DoS attacks.

***Update:** Resolved in [pull request #306](https://github.com/Consensys/linea-monorepo/pull/306). The Linea team stated:*

> *Acknowledged. We have fixed this with an alternate approach of only using the permit if there is not enough allowance. In the case of front-running, the token bridge would have an allowance and the permit call would not be used.*

### Function Visibility Overly Permissive

Throughout the codebase, multiple instances of functions with unnecessarily permissive visibility were identified:

- The [`setMessageService`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L330-L336) function in `TokenBridge.sol` with `public` visibility could be limited to `external`.
- The [`setReserved`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L424-L429) function in `TokenBridge.sol` with `public` visibility could be limited to `external`.

To better convey the intended use of functions and to potentially realize some additional gas savings, consider changing a function's visibility to be only as permissive as required.

***Update:** Resolved in [pull request #299](https://github.com/Consensys/linea-monorepo/pull/299).*

### Inconsistent Use of `whenTypeAndGeneralNotPaused` Modifier

In the `TokenBridge` contract, the check for `whenTypeAndGeneralNotPaused` is performed manually on the [`bridgeToken` function](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L213) instead of using the [`whenTypeAndGeneralNotPaused` modifier](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/PauseManager.sol#L36). This introduces inconsistency in the codebase, as the modifier is used in other parts of the contract to enforce the same check.

Consider using the `whenTypeAndGeneralNotPaused` modifier consistently for improved code clarity and readability.

***Update:** Resolved. The Linea team stated:*

> *Due to `nonZeroAddress(_token) nonZeroAddress(_recipient) nonZeroAmount(_amount) nonReentrant` and the 3 function parameters, the stack gets too deep and this does not work.*

## Conclusion

This audit covered the diff between the commits tagged as `contract-audit-05-24` and `contract-freeze-2024-11-01`. The changes related to multiple additions and optimizations across the codebase, most notably regarding blob submissions, role-based access controls, and the setting of a fallback operator.

The audit uncovered several issues and made recommendations aimed at improving code consistency, readability, and gas efficiency. We would like to thank the Linea team for providing comprehensive documentation regarding the changes made, as well as for their prompt responses to the questions posed by the audit team.

## Appendix A

The updates to the codebase have introduced multiple privileged roles to the codebase. The list includes, but is not limited to:

- [`L1_L2_MESSAGE_SETTER_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/l2/L2MessageManager.sol#L17): access to `anchorL1L2MessageHashes`.
- [`PAUSE_L1_L2_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/L2MessageServicePauseManager.sol#L12): pausing of L1 to L2 messaging.
- [`UNPAUSE_L1_L2_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/L2MessageServicePauseManager.sol#L13): unpausing of L1 to L2 messaging.
- [`PAUSE_L2_L1_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/L2MessageServicePauseManager.sol#L14): pausing of L2 to L1 messaging.
- [`UNPAUSE_L2_L1_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/L2MessageServicePauseManager.sol#L15): unpausing of L2 to L1 messaging.
- [`MINIMUM_FEE_SETTER_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/l2/v1/L2MessageServiceV1.sol#L36): setting of the `minimumFeeInWei`.
- [`VERIFIER_UNSETTER_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/LineaRollup.sol#L31): unset trusted verifier.
- [`PAUSE_BLOB_SUBMISSION_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/LineaRollupPauseManager.sol#L16): pause blob submissions.
- [`UNPAUSE_BLOB_SUBMISSION_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/LineaRollupPauseManager.sol#L17): unpause blob submissions.
- [`PAUSE_FINALIZATION_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/LineaRollupPauseManager.sol#L18): pause finalization of blocks.
- [`UNPAUSE_FINALIZATION_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/LineaRollupPauseManager.sol#L19): unpause finalization of blocks.
- [`PAUSE_ALL_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/PauseManager.sol#L14): general system pause.
- [`UNPAUSE_ALL_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/PauseManager.sol#L15): general system unpause.
- [`RATE_LIMIT_SETTER_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/lib/RateLimiter.sol#L15): reset rate limit.
- [`USED_RATE_LIMIT_RESETTER_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/messageService/lib/RateLimiter.sol#L16): reset amount used in period.
- [`SET_MESSAGE_SERVICE_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L47): set the message service.
- [`SET_REMOTE_TOKENBRIDGE_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L48): set the remote token bridge.
- [`SET_RESERVED_TOKEN_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L49): set a token as reserved.
- [`REMOVE_RESERVED_TOKEN_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L50): remove reserved status for a token.
- [`SET_CUSTOM_CONTRACT_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/tokenBridge/TokenBridge.sol#L51): set a token to use a custom contract.
- [`PAUSE_INITIATE_TOKEN_BRIDGING_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/TokenBridgePauseManager.sol#L12): pauses token bridging initiation.
- [`UNPAUSE_INITIATE_TOKEN_BRIDGING_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/TokenBridgePauseManager.sol#L13): unpause token bridging initiation.
- [`PAUSE_COMPLETE_TOKEN_BRIDGING_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/TokenBridgePauseManager.sol#L14): pause bridging completion.
- [`UNPAUSE_COMPLETE_TOKEN_BRIDGING_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/lib/TokenBridgePauseManager.sol#L15): unpause bridging completion.
- [`OPERATOR_ROLE`](https://github.com/Consensys/linea-monorepo/blob/660f849d1757700df369ebf33964ed03862b8a8c/contracts/contracts/ZkEvmV2.sol#L16): allows data submission as blobs and/or calldata, as well as finalization of blocks.
