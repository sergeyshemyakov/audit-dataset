# Linea Blob Submission Audit

Source: [https://www.openzeppelin.com/news/linea-blob-submission-audit](https://www.openzeppelin.com/news/linea-blob-submission-audit)

- March 21, 2024

OpenZeppelin Security

OpenZeppelin Security

Security Audits

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Summary](#summary)
- [Scope](#scope)
- [System Overview](#system-overview)
  - [Blob Submissions](#blob-submissions)
- [Security Model and Trust Assumptions](#security-model-and-trust-assumptions)
- [Low Severity](#low-severity)
  - [Incorrect Error](#incorrect-error)
  - [Incomplete Docstrings](#incomplete-docstrings)
  - [Inconsistent Polynomial Encoding](#inconsistent-polynomial-encoding)
  - [Missing or Misleading Documentation](#missing-or-misleading-documentation)
- [Notes & Additional Information](#notes-additional-information)
  - [Unused Errors and Events](#unused-errors-and-events)
  - [Non-Standard Storage Gaps](#non-standard-storage-gaps)
- [Conclusion](#conclusion)

## Summary

Type
:   L2

Timeline
:   From 2024-03-04
:   To 2024-03-08

Languages
:   Solidity

Total Issues
:   6 (3 resolved, 1 partially resolved)

Critical Severity Issues
:   0 (0 resolved)

High Severity Issues
:   0 (0 resolved)

Medium Severity Issues
:   0 (0 resolved)

Low Severity Issues
:   4 (2 resolved)

Notes & Additional Information
:   2 (1 resolved, 1 partially resolved)

## Scope

We audited the [Consensys/linea-contracts-audit](https://github.com/Consensys/linea-contracts-audit/) repository at commit [29e6798](https://github.com/Consensys/linea-contracts-audit/tree/29e6798eb85074253145c4688acfa540f37a220f). All the resolutions mentioned in this report are contained at commit [2816a34](https://github.com/Consensys/linea-contracts-audit/tree/2816a341e5121a02ba0a55c15346a6133dfd8550), making it the final version reviewed during this audit. The commit [be602ab](https://github.com/Consensys/linea-contracts/tree/be602ab6785c28e5f29a9953bb09c10d32584260) on `linea-contracts` includes an exact copy/replica of the audited code at commit [2816a34](https://github.com/Consensys/linea-contracts-audit/tree/2816a341e5121a02ba0a55c15346a6133dfd8550).

In scope were the changes made to the following files in that commit:

```
 contracts
├── LineaRollup.sol
├── ZkEvmV2.sol
├── interfaces
│   ├── l1
│   │   ├── IL1MessageService.sol
│   │   ├── ILineaRollup.sol
│   │   └── IZkEvmV2.sol
│   └── l2
│       └── IL2MessageManager.sol
└── messageService
    ├── l1
    │   ├── L1MessageService.sol
    │   └── v1
    │       └── L1MessageManagerV1.sol
    └── l2
        └── L2MessageManager.sol
```

## System Overview

The system is described in [our previous audit report](https://blog.openzeppelin.com/linea-v2-audit), which also outlines:

- Modifications made to the codebase in preparation for [EIP-4844](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-4844.md).
- New functionality introduced in version 2 (V2).

The code under review completes this transition by removing obsolete version 1 (V1) code and introducing a new function to submit compressed layer 2 (L2) transactions using data blobs. The original submission function can still be used if desired.

### Blob Submissions

When EIP-4844 is activated, all Ethereum users will have the ability to publish arbitrary blobs of data to the blockchain. These blobs cannot be referenced from inside the EVM and will expire in approximately 18 days. They will be priced at their own blob gas rate and are expected to be cheaper than using the `calldata` of an EVM function call. This makes them ideal for rollup transactions which need to be published but not processed on Layer 1 (L1).

To ensure that the published transactions are faithfully reproduced in the L2 circuit:

- The blob data is interpreted as a polynomial.
- A corresponding polynomial commitment is derived on L1.
- A snark-friendly commitment is published with the data.
- The two commitments are compared using the [proof-of-equivalence protocol](https://notes.ethereum.org/@vbuterin/proto_danksharding_faq#Moderate-approach-works-with-any-ZK-SNARK).
- The snark-friendly commitment can now be used by the circuit to validate the provided transactions.

In the original submission function, the commitment is a hash of the provided data buffer and the polynomial evaluation in the proof-of-equivalence protocol is computed directly. The new mechanism utilizes the native EIP-4844 opcodes and precompiles to construct the commitment and to validate a claimed point evaluation. This makes it simpler but otherwise does not change any of the existing functionality.

## Security Model and Trust Assumptions

The code under review does not meaningfully change the security model. Previously, addresses with the `OPERATOR_ROLE` were able to call the `submitData` function (while the proving system was not paused) to publish compressed L2 transaction data. Now, they can also call the `submitBlobData` function to publish the data in EIP-4844 blobs.

The operator can choose which function to use for each submission. It is expected that the operator will always choose the cheaper option.

## Low Severity

### Incorrect Error

The [`StateRootHashInvalid` error message](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/LineaRollup.sol#L243-L244) does not match the error that it is describing.

For instance, it is possible for both parameters to be empty. Even if the `_submissionData.parentStateRootHash` is non-empty, it would be more natural to treat it as the `expected` value. However, in practice, this is actually checking the validity of the submitted `dataParentHash` parameter.

Consider updating the error accordingly.

***Update:** Acknowledged, not resolved. The Linea team stated:*

> *This is going to be removed with the next gas optimization.*

### Incomplete Docstrings

Throughout the [codebase](https://github.com/Consensys/linea-contracts-audit/tree/29e6798eb85074253145c4688acfa540f37a220f/), the event parameters are not documented.

Consider thoroughly documenting all events and their parameters. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #39](https://github.com/Consensys/linea-contracts-audit/pull/39). The Linea team stated:*

> *All events now have better NatSpec. Note that in two of the files, the order has been shuffled to be: Structs, Events, Errors, and then Functions to be consistent with the rest of the codebase.*

### Inconsistent Polynomial Encoding

The [`submitData` function](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/LineaRollup.sol#L161) interprets the compressed data as polynomial coefficients. On the other hand, the [`submitBlobData` function](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/LineaRollup.sol#L128) uses EIP-4844 blobs which implicitly [interpret the data](https://github.com/ethereum/consensus-specs/blob/86fb82b221474cc89387fa6436806507b3849d88/specs/deneb/polynomial-commitments.md#evaluate_polynomial_in_evaluation_form) as polynomial evaluations. The Linea team have indicated that the circuit includes an `Eip4844Enabled` flag to handle this difference.

However, this flag is not included in the [shnarf](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/linea-contracts-audit/contracts/LineaRollup.sol#L346), which is used to derive the public input, due to which the prover can select the opposite value. By itself, this would cause the circuit to derive an incorrect polynomial from the provided data. However, if the prover modified the provided L2 transaction data so the correct polynomial was derived, it would successfully pass the proof-of-equivalence check with incorrect transactions.

In practice, these transactions will likely be malformed and will not have valid signatures. Whether the proof will succeed depends on the details of the circuit. If the proof does succeed, the prover can use this mechanism to discard valid transactions that were correctly published.

In either case, in the interest of simplicity and reducing the attack surface, consider including the `Eip4844Enabled` flag in the shnarf and modifying the circuit to retrieve it from the public input.

***Update:** Acknowledged, will resolve. The Linea team stated:*

> *Acknowledged: Currently being resolved outside of the contract with the circuit, prover, and other components that will be enforced in decentralized scenarios.*

### Missing or Misleading Documentation

The following code instances are misleading or would benefit from additional documentation:

- The [`systemMigrationBlock`](https://github.com/Consensys/linea-contracts-audit/blob/5c39b1a34777a0c9e3574ff3f608268a4a14d589/contracts/messageService/l1/L1MessageService.sol#L25C18-L25C38) state variable in the `L1MessageService` contract could be documented or renamed to explain that it is now deprecated.
- The `_currentDataHash` parameter is incorrectly [described](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/LineaRollup.sol#L271) as an aggregated proof.
- The finalization data hashes list [is described as optional](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/interfaces/l1/ILineaRollup.sol#L51) but [it must be non-empty](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/LineaRollup.sol#L406)

Consider updating these instances to improve the clarity of the codebase.

***Update:** Resolved in [pull request #36](https://github.com/Consensys/linea-contracts-audit/pull/36). The Linea team stated:*

> *The `_currentDataHash` has been corrected, the `systemMigrationBlock` has had comments added around future use, and `dataHashes` has been marked as required.*

## Notes & Additional Information

### Unused Errors and Events

Following the deprecation of V1, the following issues and events are now unused and could be removed:

- The [`SystemMigrationBlockInitialized`](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/interfaces/l1/IL1MessageService.sol#L14) event in `IL1MessageService.sol`.
- The [`BlockFinalized`](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/interfaces/l1/IZkEvmV2.sol#L13C9-L13C23) event and [`BlockTimestampError`](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/interfaces/l1/IZkEvmV2.sol#L22C9-L22C28) error in `IZkEvmV2.sol`.
- The [`ServiceHasMigratedToRollingHashes`](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/interfaces/l2/IL2MessageManager.sol#L35C9-L35C42) error and [`ServiceVersionMigrated`](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/interfaces/l2/IL2MessageManager.sol#L40C9-L40C31) event in `IL2MessageManager.sol`.

Consider removing these instances to improve the clarity of the codebase.

***Update:** Partially resolved in [pull request #38](https://github.com/Consensys/linea-contracts-audit/pull/38). The Linea team stated:*

> *Errors were removed along with the initialized event. The two other events (`BlockFinalized`) and (`ServiceVersionMigrated`) were left with comments regarding their usage. They were left primarily for existing consumer usage for past events.*

### Non-Standard Storage Gaps

When using the proxy pattern for upgrades, it is a common practice to include storage gaps in parent contracts to reserve space for potential future variables. The size is typically chosen so that all contracts have the same number of variables (usually 50). In this way, the expected layout can be deduced without knowing the full contract history. However, the codebase uses inconsistent sizes given that all of them declare a gap storage of 50 positions, regardless of how many variables were declared in the contracts. In addition, the code under review does not reduce the `LineaRollup` contract's [gap size](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/LineaRollup.sol#L36) despite introducing a [new variable](https://github.com/Consensys/linea-contracts-audit/blob/29e6798eb85074253145c4688acfa540f37a220f/contracts/LineaRollup.sol#L34). This does not cause inconsistencies because the `LineaRollup` contract is the last one in the inheritance chain, making the gap unnecessary.

Consider documenting the existing gap sizes in deployed parent contracts to avoid confusion when updating them. Furthermore, consider removing the unnecessary gap in the `LineaRollup` contract, which can be reintroduced if future upgrades inherit from this contract. Alternatively, consider reducing the gap size so the whole contract uses 50 storage slots.

***Update:** Resolved in [pull request #37](https://github.com/Consensys/linea-contracts-audit/pull/37). The Linea team stated:*

> *We removed the gap in `LineaRollup.sol` and documented the specific numbers of the gaps at each location. Some additional gap comments were made for previous ones that we could not alter.*

## Conclusion

The audited codebase adds support for blob submissions introduced in EIP-4844 and removes obsolete code from V1. We found the codebase to be well-written and well-documented, and we appreciate the Linea team's cooperation throughout the engagement.
