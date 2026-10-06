# Linea Gas Optimizations Audit

Source: [https://www.openzeppelin.com/news/linea-gas-optimizations-audit](https://www.openzeppelin.com/news/linea-gas-optimizations-audit)

- May 17, 2024

OpenZeppelin Security

OpenZeppelin Security

Security Audits

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
- [Trust Assumptions](#trust-assumptions)
- [High Severity](#high-severity)
  - [Inconsistent State Root Hash](#inconsistent-state-root-hash)
- [Low Severity](#low-severity)
  - [Incomplete Deprecation](#incomplete-deprecation)
  - [Magic Numbers](#magic-numbers)
  - [Mutable Submission Record](#mutable-submission-record)
- [Notes & Additional Information](#notes-additional-information)
  - [Non-Standard Storage Locations](#non-standard-storage-locations)
  - [Unused Parameters](#unused-parameters)
  - [Unnecessary Computation](#unnecessary-computation)
  - [Grammatical Error](#grammatical-error)
  - [Redundant Check](#redundant-check)
- [Client Reported](#client-reported)
  - [Token Bridge Updates](#token-bridge-updates)
  - [Reinitializer Synchronization](#reinitializer-synchronization)
  - [Event processing incompatibility](#event-processing-incompatibility)
- [Conclusion](#conclusion)

## Summary

Type
:   ZK Rollup

Timeline
:   From 2024-04-29
:   To 2024-05-08

Languages
:   Solidity

Total Issues
:   12 (12 resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   1 (1 resolved)

Medium Severity Issues
:   0 (0 resolved)

Low Severity Issues
:   3 (3 resolved)

Notes & Additional Information
:   5 (5 resolved)

Client Reported Issues
:   3 (3 resolved)

## Scope

We audited the [Consensys/zkevm-monorepo](https://github.com/Consensys/zkevm-monorepo) repository at commit [7f3614e](https://github.com/Consensys/zkevm-monorepo/tree/7f3614e59901402c804e72396afedb15263dcbe4). The in-scope contracts were diffed against commit [9a847b8](https://github.com/Consensys/zkevm-monorepo/tree/9a847b8a5e46779fd103ee0154907aa2c8f8f168). We also audited the changes made in [PR #36](https://github.com/Consensys/linea-contracts-fix/pull/36/files) of the [Consensys/linea-contracts-fix](https://github.com/Consensys/linea-contracts-fix) repository at commit [a6a26dd](https://github.com/Consensys/linea-contracts-fix/pull/36/commits/a6a26dd3521b7b4d90c166f71c54dba52f3c9356). All the resolutions mentioned in this report are contained at commit [bbf9091](https://github.com/Consensys/zkevm-monorepo/commit/bbf9091a37fbfbecef61361a6ebd498decc58d3e), making it the final version reviewed during this audit. This corresponds to commit [b17e7c7](https://github.com/Consensys/linea-contracts/tree/b17e7c79b5647e47c175c6367dea30c3f1c66738) in the [Consensys/linea-contracts](https://github.com/Consensys/linea-contracts/) repository.

In scope were the following files:

```
 contracts
└── contracts
    ├── LineaRollup.sol
    ├── ZkEvmV2.sol
    ├── interfaces/l1/ILineaRollup.sol
    ├── messageService
    │   ├── l1
    │   │   ├── L1MessageService.sol
    │   │   ├── TransientStorageReentrancyGuardUpgradeable.sol
    │   │   └── v1/L1MessageServiceV1.sol
    │   ├── l2/v1/L2MessageService.sol
    │   └── lib/TransientStorageHelpers.sol
    └── tokenBridge
        ├── TokenBridge.sol
        └── interfaces/ITokenBridge.sol
```

## System Overview

This diff audit is centered around changes made to the protocol related to gas optimizations. The first major change is the use of transient storage in two different contexts. The `TransientStorageReentrancyGuardUpgradeable` abstract contract and the associated `TransientStorageHelpers` library have been introduced. This replaces OpenZeppelin's `ReentrancyGuardUpgradeable` contract and takes advantage of the new `TSTORE` and `TLOAD` instructions introduced in the Dencun fork in order to save gas. In addition, the L1 message service contract (which is inherited from by the L1 rollup contract) now saves the message sender in transient storage while the message is being executed.

Another major change is the deprecation of many storage variables in the L1 rollup contract. These storage variables were previously used in order to ensure consistency when submitting and finalizing new data from L2. Instead, summary variables are saved so previously submitted data can be recognized when they are passed as calldata in future submissions. This pattern requires fewer `SSTORE` and `SLOAD` operations, again saving gas. This update also comes with the added functionality that multiple blobs can be submitted together.

## Trust Assumptions

This upgrade does not introduce new roles to the system. Since there is already an existing system with values stored in the proxy contract, the changes are introduced by upgrading to a new implementation contract at a predetermined time. As such, there is an initialization function that will be called to initialize the new variables. Because there is no access control on this function, it is assumed that the upgrader will atomically deploy and call this initialization function, and pass in the correct values to maintain consistency within the protocol.

## High Severity

### Inconsistent State Root Hash

During finalization, the operator provides the [previous](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L113) and [new](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L41) shnarfs, as well as the [previous](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L112) and [new](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L38) state root hashes. However, the shnarfs and state roots are not validated to match each other. In particular, the parent state root hash [must match the correct record](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L464) in the `stateRootHashes` mapping, which is then updated to include [the final state root hash](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L557-L559). It should be noted that this chain of state root hashes does not have to correspond to the actual L2 state root hashes that are validated through the shnarfs. Moreover, incorrect state root hashes would also cause invalid [`BlocksVerificationDone`](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/ZkEvmV2.sol#L63) events.

Consider validating that the final state root hash is consistent with the finalized shnarf.

***Update:** Resolved in [pull request #3183](https://github.com/Consensys/zkevm-monorepo/pull/3183/).*

## Low Severity

### Incomplete Deprecation

The [`_messageSender` contract variable](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/messageService/l1/v1/L1MessageServiceV1.sol#L28) has been deprecated but it is [still being used](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/messageService/l1/v1/L1MessageServiceV1.sol#L122) in the old `claimMessage` function, and after [this call](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/messageService/l1/v1/L1MessageServiceV1.sol#L124), it is set to the [`DEFAULT_SENDER_ADDRESS`](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/messageService/l1/v1/L1MessageServiceV1.sol#L136).

Consider completing the deprecation as well as removing `DEFAULT_SENDER_ADDRESS` in favor of [`DEFAULT_MESSAGE_SENDER_TRANSIENT_VALUE`](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/messageService/l1/L1MessageService.sol#L28).

***Update:** Resolved in [pull request #3174](https://github.com/Consensys/zkevm-monorepo/pull/3174).*

### Magic Numbers

The [`_computePublicInput` function](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L666) extracts several fields from a [`FinalizationDataV2` struct](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L111) using hard-coded numeric offsets.

For code clarity, consider defining named offset constants next to the struct so they can be validated directly.

***Update:** Resolved. This is not an issue. The Linea team stated:*

> *As the interface does not support constants, additional comments with expected struct parameter offsets were added to the public input computation function.*

### Mutable Submission Record

In the `submitDataAsCalldata` function, [duplicate submissions are prevented](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L311-L313). However, a caller can reuse previous data corresponding to a known shnarf, but provide a different final block number in order to [overwrite a previous submission](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L315).

Instead of strictly preventing duplicates, consider updating the check to prevent overwriting any non-zero record, [such as in `submitBlobs`](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L246-L248), to ensure the immutability of submitted data.

***Update:** Resolved in [pull request #3175](https://github.com/Consensys/zkevm-monorepo/pull/3175).*

## Notes & Additional Information

### Non-Standard Storage Locations

The codebase includes two pseudorandom storage locations ([1](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/messageService/l1/TransientStorageReentrancyGuardUpgradeable.sol#L14), [2](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/messageService/l1/L1MessageService.sol#L27)) specified as direct `keccak256` outputs. Although these are used for transient storage and cannot overwrite existing storage records, address collisions could still cause unnecessary confusion.

Consider using the [ERC-1967 mechanism](https://eips.ethereum.org/EIPS/eip-1967) to choose these locations.

***Update:** Resolved in [pull request #3174](https://github.com/Consensys/zkevm-monorepo/pull/3174).*

### Unused Parameters

Consider removing the following unused parameters to improve code clarity and save gas:

- The [`dataParentHash` parameter](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L21) in the `SubmissionData` struct
- The [`dataParentHash` parameter](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L54) in the `SupportingSubmissionData` struct
- The [`firstBlockInData` parameter](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L39) in the `StoredSubmissionData` struct
- The [`finalDataHash` parameter](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L114) in the `FinalizationDataV2` struct

***Update:** Resolved in [pull request #3177](https://github.com/Consensys/zkevm-monorepo/pull/3177) and [pull request #3183](https://github.com/Consensys/zkevm-monorepo/pull/3183/).*

### Unnecessary Computation

In the `LineaRollup` contract, an operator can submit data by either calling the [`submitBlobs` function](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L182) or the [`submitDataAsCalldata` function](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L262). In both functions, the caller is required to pass in a `ParentShnarfData` struct. The data in this struct is used [here](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L199-L205) and [here](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L270-L276) to compute the claimed parent shnarf. However, as the parent information is user-provided, and the user already provides the `parentShnarf` through the [`SubmissionData`](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L27) and [`SupportingSubmissionData`](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/interfaces/l1/ILineaRollup.sol#L59) structs, this computation is unnecessary and provides no additional security guarantees.

Consider removing the `ParentShnarfData` as a parameter to the `submitBlobs` and `submitDataAsCalldata` functions and using the `parentShnarf` field instead.

***Update:** Resolved in [pull request #3177](https://github.com/Consensys/zkevm-monorepo/pull/3177).*

### Grammatical Error

The `submitBlobs` function has a grammatically incorrect clause, stating ["the intermediate are not stored"](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L245).

Consider correcting the above incorrect comment to improve the readability of the codebase.

***Update:** Resolved in [pull request #3176](https://github.com/Consensys/zkevm-monorepo/pull/3176).*

### Redundant Check

In the `submitDataAsCalldata` function, there are multiple checks to ensure the consistency of the passed-in data, which is essential for the protocol. However, [this validation](https://github.com/Consensys/zkevm-monorepo/blob/7f3614e59901402c804e72396afedb15263dcbe4/contracts/contracts/LineaRollup.sol#L295-L300) is redundant as it has already been checked inside the `_validateSubmissionData` function.

Consider removing this redundant check to avoid code duplication and to reduce gas costs.

***Update:** Resolved in [pull request #3177](https://github.com/Consensys/zkevm-monorepo/pull/3177).*

## Client Reported

### Token Bridge Updates

After the audit was completed, the Linea team shared the following issues and optimizations reported by [Cyfrin](https://www.cyfrin.io/) relating to the `TokenBridge` contract.

- The `_safeDecimal` function [defaults to 18](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L435) if the decimals cannot be retrieved. However, this could lead to an inconsistency between the L1 and L2 tokens. Moreover, ERC-721 tokens can only be bridged in one direction. The function should revert instead.
- The `setCustomContract` function can [override an existing `nativeToBridgedToken` record](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L388).
- The [`removeReserved` function](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L366) should emit an event to facilitate off-chain processing.
- The [`bridgeTokenWithPermit` function modifiers](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L217) are redundant because they are already included in the [`bridgeToken`](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L221) invocation.
- The [`nativeToken` variable](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L303) is assigned but not used.
- The `sourceChainId` record in the [`bridgeToken`](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L148) and [`removeReserved`](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L366) functions could be assigned to a local variable to avoid multiple storage reads of the same value.
- [This validation](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L68) could reverse the two conditions so the more common case fails first.
- Instead of [assigning](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L160) to the `bridgedMappingValue` variable and then optionally [copying the result](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L168) to the `nativeToken` variable, the `nativeToken` could be used in both case (and [possibly overwritten](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/tokenBridge/TokenBridge.sol#L179)).

***Update:** Resolved in [pull request #3249](https://github.com/Consensys/zkevm-monorepo/pull/3249).*

### Reinitializer Synchronization

The `initializeParentShnarfsAndFinalizedState` function uses [reinitializer version 4](https://github.com/Consensys/zkevm-monorepo/blob/54c467056b0a95d411f1060f77a9940652b1554c/contracts/contracts/LineaRollup.sol#L132), which is consistent with the current mainnet version 3. However, the Sepolia deployment already uses version 4. For simplicity, the codebase should set it to version 5 so that the same deployment is valid on both chains.

***Update:** Resolved in [pull request #3249](https://github.com/Consensys/zkevm-monorepo/pull/3249).*

### Event processing incompatibility

[Pull Request #36](https://github.com/Consensys/linea-contracts-fix/pull/36/files) updated the `BridgingInitiated` and `BridgingFinalized` events to index the `recipient` parameter instead of the `amount` parameter. However, this is not a backwards-compatible change with existing off-chain event processing functionality. Instead, the original interface should be restored and the new interface can be implemented with a new event.

***Update:** Resolved in [pull request #3288](https://github.com/Consensys/zkevm-monorepo/pull/3288).*

## Conclusion

The audited codebase adds gas optimizations and support for submitting multiple blobs together. One high-severity issue was found along with a few lower-severity issues. The codebase was found to be well-written and well-documented. We appreciated the Linea team's cooperation throughout the engagement.
