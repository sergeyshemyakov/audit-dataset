Source: https://www.openzeppelin.com/news/uniswap-flashtestations-audit-1

[Research](https://www.openzeppelin.com/research) /
[Security Audits](https://www.openzeppelin.com/research#security-audits)
/

Uniswap Flashtestations Audit

[Security Audits](https://www.openzeppelin.com/research#security-audits)

# Uniswap Flashtestations Audit

Table of Content

- June 26, 2026

OpenZeppelin Security

OpenZeppelin Security

Security Audits

**Summary**

**Type:** DeFi  
**Timeline:** August 6, 2025 → August 11, 2025  
**Languages:** Solidity

**Findings**  
Total issues: 24 (20 resolved, 1 partially resolved)  
Critical: 0 (0 resolved) · High: 0 (0 resolved) · Medium: 2 (2 resolved) · Low: 6 (5 resolved, 1 partially resolved)

**Notes & Additional Information**  
16 notes raised (13 resolved)

## Scope

OpenZeppelin audited the [flashbots/flashtestations](https://github.com/flashbots/flashtestations) repository in two phases. Phase 1 was the main audit which targeted [commit `9ce1371`](https://github.com/flashbots/flashtestations/tree/9ce1371d0a079396d49c1aa7876cf9b0075629e8) and Phase 2 consisted of some gas optimization additions and was reviewed at [commit `0140167`](https://github.com/flashbots/flashtestations/pull/24/commits/0140167c80d8a93ac025e25e59e9e3518c82e939) of PR #24. In addition to the smart contracts, the audit also covered the associated deployment and interaction scripts.

In scope of both the phases were the following files:

```
 ├── src
│   ├── BlockBuilderPolicy.sol
│   ├── FlashtestationRegistry.sol
│   ├── utils
│   │   └── QuoteParser.sol
│   └── interfaces
│       ├── IAttestation.sol
│       └── IFlashtestationRegistry.sol
└── script
    ├── BlockBuilderPolicy.s.sol
    ├── FlashtestationRegistry.s.sol
    └── Interactions.s.sol
```

## System Overview

Flashtestations is a transparent, on-chain protocol for Trusted Execution Environment (TEE) verification and Intel DCAP attestation. It enables any TDX (Intel Trust Domain Extensions) device to verifiably prove its outputs on-chain. The primary use case is to demonstrate that blocks on the Unichain network have been constructed using fair and transparent ordering rules.

By integrating verifiable TEE attestations into block production, the protocol enhances transparency, enforces priority ordering, mitigates Maximal Extractable Value (MEV), and enables features such as revert protection. These improvements contribute to Unichain’s ongoing efforts to build a faster, fairer, and more decentralized blockchain infrastructure.

### Core Components

The system comprises two primary smart contracts:

* `FlashtestationRegistry`: Manages TEE identities and configuration data through Automata’s Intel DCAP attestation. It allows anyone to register or invalidate TEE services and to query their attestation status. This contract is upgradeable and designed to be largely permissionless, except for the upgrade process itself.
* `BlockBuilderPolicy`: Defines and manages sets of workload IDs that determine valid configurations for specific remote block-building use cases. A workload ID uniquely identifies a TEE workload, which represents a specific version of an application’s code, derived from the TEE's measurement registers. These registers capture cryptographic hashes of the code, data, and configuration loaded into the TEE, ensuring that the workload is reproducible from source. The policy is upgradeable and tightly governed, requiring permissions to modify workloads. Proof verification is available to any user, but trust assumptions are made on `blockContentHash` due to EVM limitations (no retrospection).

## Security Model and Trust Assumptions

The following trust assumptions and security risks were identified during the audit:

### `FlashtestationRegistry`

* This contract is upgradeable and largely permissionless. Any participant can register TEE services, invalidate existing attestations, or query the status of TEEs.
* The only permissioned action is contract upgrading, which results in a central point of control.
* The security of the system relies heavily on the correctness of the attestation contract (maintained by Automata Network), particularly in its ability to accurately verify raw quotes.
* There is implicit trust in external actors to proactively call the `invalidateAttestation` function when an attestation becomes invalid. While the function is publicly accessible, failure to act promptly can result in incorrect TEE states being stored and trusted within the registry.

### `BlockBuilderPolicy`

* This contract is upgradeable and mostly permissioned. Only governance can modify workload IDs or upgrade the contract.
* The only permissionless function is the verification of block builder proofs.
* A critical trust assumption is placed on the user-provided inputs, particularly `version` and `blockContentHash`, which are not validated on-chain due to EVM limitations.
* The Flashtestations protocol [specifications](https://github.com/flashbots/rollup-boost/blob/6d49ea6cb3de33cf385199aa9f6b81a5c0640abb/specs/flashtestations.md) are secure.

## Medium Severity

### Fee Incompatibility With Attestation Contract

> Found in Phase 1

When the `FlashtestationRegistry` contract needs to [verify a quote against the attestation contract](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/FlashtestationRegistry.sol#L156), it does so without taking into account any fees. This is not fully compatible with the actual [attestation contract implementation](https://github.com/automata-network/automata-dcap-attestation/blob/c66b1e313f8b3dc63880ddecc1bf1c271331dcbd/evm/contracts/AutomataDcapAttestationFee.sol) because there is a [fee involved with the verification](https://github.com/automata-network/automata-dcap-attestation/blob/c66b1e313f8b3dc63880ddecc1bf1c271331dcbd/evm/contracts/bases/FeeManagerBase.sol#L36-L48). If a fee percentage is set, then any call to `verifyAndAttestOnChain` will fail, and the protocol will neither be able to [register TEE services](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/FlashtestationRegistry.sol#L156) nor [invalidate attestations](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/FlashtestationRegistry.sol#L274).

Consider making the [`verifyAndAttestOnChain`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/interfaces/IAttestation.sol#L5) function from the `IAttestation` interface `payable` and handling the fee payment accordingly when the fee percentage is set.

***Update:** Resolved in [pull request #25](https://github.com/flashbots/flashtestations/pull/25) at [commit 5b0370d](https://github.com/flashbots/flashtestations/pull/25/commits/5b0370dda239b5fd88ff7fa7940915f092e5530b).*

### Version Check Can Be Arbitrarily Bypassed When Verifying Block Builder Proofs

> Found in Phase 1

In order to verify a block builder proof, the version of the flashtestation protocol used to generate the block builder proof and the hash of the block content must be provided. The only constraint for the version is that [it needs to be in the `SUPPORTED_VERSIONS` array](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/BlockBuilderPolicy.sol#L188). However, there are no checks to ensure that the version provided is indeed the version used for generating the `blockContentHash`. That allows any user to arbitrarily provide a version that is supported in order to bypass the supported version check.

Consider adding measures to ensure that the version provided by the user is the one that is used for generating the `blockContentHash`.

***Update:** Resolved in [pull request #26](https://github.com/flashbots/flashtestations/pull/26) at [commit 38e19c2](https://github.com/flashbots/flashtestations/pull/26/commits/38e19c2432171e445a54acc4f2bd72db233ccd1e).*

## Low Severity

### Missing Zero-Address Checks

> Found in Phase 1

When operations with `address` parameters are performed, it is crucial to ensure that the address is not set to zero. Setting an address to zero is problematic because it has special burn/renounce semantics. This action should be handled by a separate function to prevent accidental loss of access during value or ownership transfers.

Throughout the codebase, multiple instances of missing zero-address checks were identified:

* The [`_registry`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L126) function in the `BlockBuilderPolicy` contract
* The [`_attestationContract`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L68) function in the `FlashtestationRegistry` contract

Consider always performing a zero-address check before assigning a state variable.

***Update:** Resolved in [pull request #27](https://github.com/flashbots/flashtestations/pull/27) at [commit aab77b2](https://github.com/flashbots/flashtestations/pull/27/commits/aab77b266824fef2cf7b72a2cea8507027e02e12).*

### Missing Deadline Protection for EIP-712 Signatures

> Found in Phase 1

When constraining permit signatures, it is highly recommended to have a deadline protection in case a signature is not executed within a specific time window set by the signer.

Throughout the codebase, multiple instances of missing deadline protection for signatures were identified:

* In `FlashtestationRegistry.sol`, the [`permitRegisterTEEService`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/FlashtestationRegistry.sol#L120-L141) function
* In `BlockBuilderPolicy.sol`, the [`permitVerifyBlockBuilderProof`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/BlockBuilderPolicy.sol#L160-L179) function

Consider checking that the provided deadline is not expired and is part of the EIP-712 digest hash.

***Update:** Partially resolved in [pull request #30](https://github.com/flashbots/flashtestations/pull/30) at [commit 5dd4305](https://github.com/flashbots/flashtestations/pull/30/commits/5dd4305ef8741a3db5174a93ad9ecac2c2a8c9e5). The team stated:*

> We do not add a deadline for BlockBuilderPolicy's permitVerifyBlockBuilderProof, because the high frequency with which we'll be broadcasting new calls to permitVerifyBlockBuilderProof which invalidate the old calls makes a deadline not very useful for it. We intend to broadcast 1 such call every 200ms, for each flashblock. In fact, we can't even correctly implement a deadline for permitVerifyBlockBuilderProof, because the smallest granularity we could use for the deadline is 1 second, and that is not enough time to specify multiple flashblocks (which we'll need to do).

### Missing Nonce Signature Invalidation

> Found in Phase 1

When a user signs a permit digest with a specific nonce but later wants to invalidate previous signatures, the most used implementations are either a function to increment the nonce or executing a no-op operation. In the case of `FlashtestationRegistry`, neither of these two options is available. [No-op permit executions are reverted in order to avoid gas costs](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/FlashtestationRegistry.sol#L200-L217). Thus, the only way to increment the nonce is by executing a valid signature with a different valid `rawQuote` value.

Consider adding a function to increment the nonce of the caller in order to invalidate previous signatures not yet executed.

***Update:** Resolved in [pull request #31](https://github.com/flashbots/flashtestations/pull/31) at [commit 6b7e14f](https://github.com/flashbots/flashtestations/pull/31/commits/6b7e14fb0d25c3d1eddba9a0c6a4235af56ed063) and optimized in [pull request #42](https://github.com/flashbots/flashtestations/pull/42) at [commit 18fc01d](https://github.com/flashbots/flashtestations/pull/42/commits/18fc01d102bbd76096e5edfef4040b596570bf99).*

### Missing Reentrancy Guard in `invalidateAttestation`

> Found in Phase 1

Functions that register new TEE services have a reentrancy guard modifier because they do not follow the CEI pattern and rely on the external call `verifyAndAttestOnChain` from the attestation contract. While this call can be trusted because the attestation contract should not be malicious and is not upgradeable, there are situations where the [execution is forwarded to the `tx.origin`](https://github.com/automata-network/automata-dcap-attestation/blob/main/evm/contracts/bases/FeeManagerBase.sol#L50-L59).

Hence, with the recent introduction of [EIP-7702](https://eips.ethereum.org/EIPS/eip-7702), it is possible for a malicious user to reenter the `FlashtestationRegistry` with an outdated state. For this reason, the reentrancy guard is completely necessary. However, while the `invalidateAttestation` function relies on this external call, it does not have the reentrancy guard protection. Hence, it is vulnerable to being reentered.

Consider adding the `nonReentrant` modifier to the `invalidateAttestation` function.

***Update:** Resolved in [pull request #28](https://github.com/flashbots/flashtestations/pull/28) at [commit c719a4e](https://github.com/flashbots/flashtestations/pull/28/commits/c719a4e13c1bda118830f445dd6825b702964ebe).*

### No Checks on `sourceLocators` Array When Adding Workloads

> Found in Phase 1

When a new workload is added to a policy, the governance has to provide the `commitHash` and `sourceLocators` to save the metadata for the workload. The `commitHash` is the commit hash of the git repository whose source code is used to build the TEE image identified by the `workloadId`, and the `sourceLocators` is an array of URIs pointing to that source code. The `commitHash` cannot be empty because the [length must be greater than 0](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/BlockBuilderPolicy.sol#L299), but `sourceLocators` has no checks. This array should have at least one element to fetch the source code.

Consider ensuring that the `sourceLocators` array has at least one element.

***Update:** Resolved in [pull request #29](https://github.com/flashbots/flashtestations/pull/29) at [commit f95ce2c](https://github.com/flashbots/flashtestations/pull/29/commits/f95ce2cbfcdcf53137eaea3c2a93d04cab4b08cc).*

### Domain Separator Not Public

> Found in Phase 1

The domain separator, as defined in [EIP-712](https://eips.ethereum.org/EIPS/eip-712), is used for obtaining the final message hash signed by the user. The `BlockBuilderPolicy` and `FlashtestationRegistry` contracts use EIP-712 typed data but do not expose their domain separator via a `public` `view` function. As such, off-chain signers and integrators must reconstruct the domain, which can be error-prone.

Consider exposing the domain separator via a `public` function to allow for the easy fetching of the domain separator.

***Update:** Resolved in [pull request #32](https://github.com/flashbots/flashtestations/pull/32) at [commit c78ac25](https://github.com/flashbots/flashtestations/pull/32/commits/c78ac251e81d845c502f89c6c246cd6d10e41da2).*

## Notes & Additional Information

### Incomplete Docstring

> Found in Phase 1

In the [`initialize`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L65-L69) function of the `FlashtestationRegistry` contract, the `owner` parameter is not documented.

Consider thoroughly documenting all functions/events (and their parameters or return values) that are part of a contract's public API. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #33](https://github.com/flashbots/flashtestations/pull/33) at [commit fdfef22](https://github.com/flashbots/flashtestations/pull/33/commits/fdfef228f0434a5fe99e17af99e0f607dbd6979c).*

### Missing Docstrings

> Found in Phase 1

Throughout the codebase, multiple instances of missing docstrings (or comments not classified as docstrings) were identified:

* In `BlockBuilderPolicy.sol`, the [`VERIFY_BLOCK_BUILDER_PROOF_TYPEHASH` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L45-L46)
* In `BlockBuilderPolicy.sol`, the [`WorkloadAddedToPolicy` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L99)
* In `BlockBuilderPolicy.sol`, the [`WorkloadRemovedFromPolicy` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L100)
* In `BlockBuilderPolicy.sol`, the [`RegistrySet` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L101)
* In `IAttestation.sol`, the [`IAttestation` interface](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/interfaces/IAttestation.sol#L4-L6)
* In `IAttestation.sol`, the [`verifyAndAttestOnChain` function](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/interfaces/IAttestation.sol#L5)
* In `IFlashtestationRegistry.sol`, the [`TEEServiceRegistered` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/interfaces/IFlashtestationRegistry.sol#L21)
* In `IFlashtestationRegistry.sol`, the [`TEEServiceInvalidated` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/interfaces/IFlashtestationRegistry.sol#L22)
* In `QuoteParser.sol`, the [`ACCEPTED_TDX_VERSION` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/utils/QuoteParser.sol#L18)
* In `QuoteParser.sol`, the [`SERIALIZED_OUTPUT_OFFSET` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/utils/QuoteParser.sol#L24)

Consider thoroughly documenting all functions (and their parameters) that are part of any contract's public API. Functions implementing sensitive functionality, even if not public, should be clearly documented as well. When writing docstrings, consider following the [Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html) (NatSpec).

***Update:** Resolved in [pull request #34](https://github.com/flashbots/flashtestations/pull/34) at [commit 210a861](https://github.com/flashbots/flashtestations/pull/34/commits/210a86170ecfa67ad093c57ec7ffa072db446ba5).*

### Custom Errors in `require` Statements

> Found in Phase 1

Since Solidity [version `0.8.26`](https://soliditylang.org/blog/2024/05/21/solidity-0.8.26-release-announcement/), custom error support has been added to `require` statements. Initially, this feature was only available through the IR pipeline. However, Solidity [`0.8.27`](https://soliditylang.org/blog/2024/09/04/solidity-0.8.27-release-announcement/) extended support for this feature to the legacy pipeline as well.

Throughout the codebase, multiple instances where `if-revert` statements could be replaced with `require` statements were identified:

* The [`if (!success) {
  revert InvalidQuote(output);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L157-L159) statement in `FlashtestationRegistry.sol`
* The [`if (td10ReportBody.reportData.length < TD_REPORTDATA_LENGTH) {
  revert InvalidReportDataLength(td10ReportBody.reportData.length);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L166-L168) statement in `FlashtestationRegistry.sol`
* The [`if (caller != teeAddress) {
  revert SenderMustMatchTEEAddress(caller, teeAddress);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L174-L176) statement in `FlashtestationRegistry.sol`
* The [`if (extendedRegistrationDataHash != extendedDataReportHash) {
  revert InvalidRegistrationDataHash(extendedDataReportHash, extendedRegistrationDataHash);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L182-L184) statement in `FlashtestationRegistry.sol`
* The [`if (keccak256(quote) == keccak256(registeredTEEs[teeAddress].rawQuote)) {
  revert TEEServiceAlreadyRegistered(teeAddress);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L215-L217) statement in `FlashtestationRegistry.sol`
* The [`if (registeredTEE.rawQuote.length == 0) {
  revert TEEServiceNotRegistered(teeAddress);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L263-L265) statement in `FlashtestationRegistry.sol`
* The [`if (!registeredTEE.isValid) {
  revert TEEServiceAlreadyInvalid(teeAddress);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L267-L269) statement in `FlashtestationRegistry.sol`
* The [`if (version != ACCEPTED_TDX_VERSION) {
  revert InvalidTEEVersion(version);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/utils/QuoteParser.sol#L110-L112) statement in `QuoteParser.sol`
* The [`if (teeType != TDX_TEE) {
  revert InvalidTEEType(teeType);
  }`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/utils/QuoteParser.sol#L122-L124) statement in `QuoteParser.sol`

For conciseness and gas savings, consider replacing `if-revert` statements with `require` statements.

***Update:** Resolved in [pull request #40](https://github.com/flashbots/flashtestations/pull/40) at [commit 2e33699](https://github.com/flashbots/flashtestations/pull/40/commits/2e33699dd1dfff29239c4769b653417eb47219fc).*

### `_disableInitializers()` Not Being Called From Initializable Contract Constructors

> Found in Phase 1

In a proxy pattern, an implementation contract allows anyone to call its `initialize` function. While not a direct security concern, preventing the implementation contract from being initialized by an unintended party is important, as this could allow an attacker to take over the contract.

Throughout the codebase, multiple instances of initializable contracts where `_disableInitializers()` is not called in the constructor were identified:

* The initializable contract [`BlockBuilderPolicy`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L41-L348) within `BlockBuilderPolicy.sol`
* The initializable contract [`FlashtestationRegistry`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L20-L314) within `FlashtestationRegistry.sol`

Consider calling `_disableInitializers()` in initializable contract constructors to prevent malicious actors from front-running initialization.

***Update:** Acknowledged, not resolved. The team stated:*

> *We don't see a possible way this would impact the implementation contracts, and it adds more complexity to the contract interface than we think is worth it.*

### Lack of Indexed Event Parameters

> Found in Phase 1

Throughout the codebase, several events do not have indexed parameters:

* The [`WorkloadAddedToPolicy` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L99) of `BlockBuilderPolicy.sol`.
* The [`WorkloadRemovedFromPolicy` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L100) of `BlockBuilderPolicy.sol`.
* The [`RegistrySet` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L101) of `BlockBuilderPolicy.sol`.
* The [`BlockBuilderProofVerified` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L109-L116) of `BlockBuilderPolicy.sol`.
* The [`TEEServiceRegistered` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/interfaces/IFlashtestationRegistry.sol#L21) of `IFlashtestationRegistry.sol`.
* The [`TEEServiceInvalidated` event](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/interfaces/IFlashtestationRegistry.sol#L22) of `IFlashtestationRegistry.sol`.

To improve the ability of off-chain services to search and filter for specific events, consider [indexing event parameters](https://solidity.readthedocs.io/en/latest/contracts.html#events).

***Update:** Resolved. Resolved in [pull request #41](https://github.com/flashbots/flashtestations/pull/41) at [commit b921c24](https://github.com/flashbots/flashtestations/pull/41/commits/b921c243f374f04d326885dfffc6c7569428042e). The team stated:*

> *We didn't get to this one*

### Missing Named Parameters in Mappings

> Found in both phases. First 4 instances in Phase 1 and last one in Phase 2.

Since [Solidity 0.8.18](https://github.com/ethereum/solidity/releases/tag/v0.8.18), mappings can include named parameters to provide more clarity about their purpose. Named parameters allow mappings to be declared in the form `mapping(KeyType KeyName? => ValueType ValueName?)`. This feature enhances code readability and maintainability.

Throughout the codebase, multiple instances of mappings without named parameters were identified:

* The [`approvedWorkloads` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L69) in the `BlockBuilderPolicy` contract.
* The [`nonces` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L82) in the `BlockBuilderPolicy` contract.
* The [`registeredTEEs` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L52) in the `FlashtestationRegistry` contract.
* The [`nonces` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/FlashtestationRegistry.sol#L55) in the `FlashtestationRegistry` contract.
* The [`cachedWorkloads` state variable](https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/BlockBuilderPolicy.sol#L97) in the `BlockBuilderPolicy` contract.

Consider adding named parameters to mappings in order to improve the readability and maintainability of the codebase.

***Update:** Resolved in [pull request #35](https://github.com/flashbots/flashtestations/pull/35) at [commit 4cd4603](https://github.com/flashbots/flashtestations/pull/35/commits/4cd46034d6d7dde62ad00013a18e61dfad34cbac).*

### Redundant Getter Function

> Found in Phase 1

When state variables use `public` visibility in a contract, a getter method for the variable is automatically generated.

Within the `BlockBuilderPolicy` contract in `BlockBuilderPolicy.sol`, the [`getWorkloadMetadata`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L329-L331) function is redundant because the `approvedWorkloads` state variable, being `public`, already has a getter.

To improve the overall clarity, intent, and readability of the codebase, consider removing the redundant getter functions.

***Update:** Resolved in [pull request #34](https://github.com/flashbots/flashtestations/pull/34/) at [commit 210a861](https://github.com/flashbots/flashtestations/pull/34/commits/210a86170ecfa67ad093c57ec7ffa072db446ba5).*

### State Variable Visibility Not Explicitly Declared

> Found in Phase 1

Within [`BlockBuilderPolicy.sol`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol), multiple instances of state variables lacking an explicitly declared visibility were identified:

* The [`TD_XFAM_FPU` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L52)
* The [`TD_XFAM_SSE` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L54)
* The [`TD_TDATTRS_VE_DISABLED` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L58)
* The [`TD_TDATTRS_PKS` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L60)
* The [`TD_TDATTRS_KL` state variable](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L62)

For improved code clarity, consider always explicitly declaring the visibility of state variables, even when the default visibility matches the intended visibility.

***Update:** Acknowledged, not resolved. The team stated:*

> *We didn't get to this one*

### Unnecessary Data Field in Event Emission

> Found in Phase 1

In `BlockBuilderPolicy.sol`, the [`emit BlockBuilderProofVerified(teeAddress, workloadId, block.number, version, blockContentHash, commitHash);`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/./src/BlockBuilderPolicy.sol#L203) event emission includes unnecessary data fields such as `block.number`.

To improve the efficiency of the contract, consider removing unnecessary data fields from the event emission such as `block.number` or `block.timestamp` since they are already included in the block information.

***Update:** Resolved in [pull request #38](https://github.com/flashbots/flashtestations/pull/38) at [commit ad43c90](https://github.com/flashbots/flashtestations/pull/38/commits/ad43c904c81e4d44c524ea9c76f4e7cfaa026395).*

### Unnecessary Gaps

> Found in Phase 1

Gaps are necessary storage areas reserved for upgradeable contracts with inherited modules that do not implement [namespaced storage layouts](https://eips.ethereum.org/EIPS/eip-7201). However, both `FlashtestationRegistry` and `BlockBuilderPolicy` import OpenZeppelin upgradeable contracts with a version that already supports this feature. Thus, there is no need to add gap arrays at the end of the implementation storage as long as the order of variables remains the same with future upgrades.

Consider removing the gaps and using namespaced storage for the contracts.

***Update:** Acknowledged, not resolved. The team stated:*

> *We're not confident at changing to use EIP-7201 at this point.*

### Misleading Comment

> Found in Phase 1

The docstring in [line 141](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/BlockBuilderPolicy.sol#L141) of the `BlockBuilderPolicy` contract points to an old version of the documentation and can, therefore, be misleading to the readers.

Consider updating the documentation link to the latest version.

***Update:** Resolved in [pull request #39](https://github.com/flashbots/flashtestations/pull/39) at [commit 8277c53](https://github.com/flashbots/flashtestations/pull/39/commits/8277c5301bdf1b23657eb9133915287762cf53f8).*

### Use `ReentrancyGuardTransientUpgradeable` Module

> Found in Phase 1

The [`ReentrancyGuardTransientUpgradeable`](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/utils/ReentrancyGuardTransientUpgradeable.sol) module should be used instead of `ReentrancyGuardTransient`, as it ensures that all modules remain upgradeable. Although both versions function identically, transitioning to the upgradeable version aligns with best practices for upgradeable contract architectures.

Consider using the `ReentrancyGuardTransientUpgradeable` module instead of the `ReentrancyGuardTransient` module and ensuring that all inherited upgradeable module initializers are called within the `initialize` function, such as `__UUPSUpgradeable_init()` for UUPS support and `__ReentrancyGuardTransient_init()` for the reentrancy guard. Doing so will help improve the maintainability and upgradeability of the contract.

***Update:** Resolved in [pull request #36](https://github.com/flashbots/flashtestations/pull/36) at [commit 6dace7a](https://github.com/flashbots/flashtestations/pull/36/commits/6dace7ae3b7e6a994b3096ad92398d1bda0d78f6) and [pull request #43](https://github.com/flashbots/flashtestations/pull/43) at [commit a2371ba](https://github.com/flashbots/flashtestations/pull/43/commits/a2371bae9faf5fafceeac8091785a7f86e0ac8f7).*

### Naming Suggestion

> Found in Phase 1

In the [`doRegister` function](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/FlashtestationRegistry.sol#L151-L198) of the `FlashtestationRegistry` contract, the first parameter is named `caller`. This is misleading as the registering TEE is not always the address that sends the transaction. A third party can relay a signed message via [`permitRegisterTEEService`](https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/FlashtestationRegistry.sol#L120-L141). As such, `msg.sender` is not always the TEE being registered.

Consider changing the name of the argument to something more unambiguous like `teeAddress`.

***Update:** Resolved in [pull request #37](https://github.com/flashbots/flashtestations/pull/37) at [commit 3ad9547](https://github.com/flashbots/flashtestations/pull/37/commits/3ad9547634d1792fe6276d8a9796568798456389).*

### Use Stored `quoteHash` Instead of Rehashing in `checkPreviousRegistration`

> Found in Phase 2

When registering a new TEE service in `FlashtestationRegistry`, the implementation checks whether `rawQuote` has already been registered for the same TEE address and [reverts if necessary](https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/FlashtestationRegistry.sol#L216-L218). To do this, it hashes the new quote and compares it against the hash of the stored `rawQuote`. However, since the hash of the quote is already [stored in the registry](https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/interfaces/IFlashtestationRegistry.sol#L18), it allows the new quote’s hash to be compared directly against the stored hash, saving gas by requiring only a single `SLOAD` instead of up to `20 * 1024 / 32 = 640 SLOAD` operations, and avoids recomputing the hash.

Consider comparing the hash of the new quote with the `quoteHash` stored in `registeredTEEs` to optimize gas usage.

***Update:** Resolved in [pull request #24](https://github.com/flashbots/flashtestations/pull/24) at [commit 5a7fb4a](https://github.com/flashbots/flashtestations/pull/24/commits/5a7fb4aab06c4a5f3bc14cda75139ca19cc4d858).*

### Avoid Variable Shadowing

> Found in Phase 2

In the `_cachedIsAllowedPolicy` function, the [returned named variable `allowed`](https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/BlockBuilderPolicy.sol#L271) is [shadowed](https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/BlockBuilderPolicy.sol#L292). While this doesn't cause any functional issues, we recommend removing the named return variable to improve code clarity.

Consider removing the named return for the boolean `allowed` in order to prevent variable shadowing.

***Update:** Resolved in [pull request #24](https://github.com/flashbots/flashtestations/pull/24) at [commit b389e66](https://github.com/flashbots/flashtestations/pull/24/commits/b389e66e49285152b7f3627ca493ef8faee6bfce).*

### Redundant Unwrapping of `workloadId` Increases Gas Usage

> Found in Phase 2

When processing the [happy path](https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/BlockBuilderPolicy.sol#L278-L285) in `_cachedIsAllowedPolicy` function, the implementation repeatedly unwraps workloadId in multiple places ([1](https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/BlockBuilderPolicy.sol#L282), [2](https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/BlockBuilderPolicy.sol#L284)), rather than caching the unwrapped value. This results in redundant operations and unnecessary gas usage. Based on gas reports, caching `workloadId` leads to a median gas reduction of 3 units.

Consider unwrapping `workloadId` once and reusing the cached value to optimize for gas efficiency.

***Update:** Resolved in [pull request #24](https://github.com/flashbots/flashtestations/pull/24) at [commit 1e25376](https://github.com/flashbots/flashtestations/pull/24/commits/1e253768a12490a8b9fb8491c03de2fbb82e9f70).*

## Conclusion

Flashtestations is an on-chain protocol for verifiable TEE attestations (Intel TDX/DCAP), enabling TDX devices to prove outputs and making Unichain’s block construction transparent. The codebase was found to be well-written and secure. The audit identified minor issues and provided recommendations to enhance code clarity and maintainability. The Uniswap Labs team is appreciated for being highly cooperative and providing clear explanations throughout the audit.

Ready to secure your code?

[Request an Audit →](https://www.openzeppelin.com/request?utm_campaign=Audit%20Reports%202024&utm_source=mybloglog&utm_medium=social&utm_term=CTARequestAudit&utm_content=AuditBlogPost)