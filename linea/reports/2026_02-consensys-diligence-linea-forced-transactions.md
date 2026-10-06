# Linea Forced Transactions

Source: [https://diligence.security/audits/2026/02/linea-forced-transactions/](https://diligence.security/audits/2026/02/linea-forced-transactions/)

|  |  |
| --- | --- |
| Date | February 2026 |
| Auditors | George Kobakhidze, François Legué |
| Download | JSON  CSV |

## 1 Executive Summary

This report presents the results of our engagement with **Linea** to review **Linea Forced Transactions**.

The review was conducted from **February 2, 2026** to **February 11, 2026** by George Kobakhidze and François Legué.

The Forced Transactions mechanism enables users to submit transactions from Ethereum L1 that must be included in L2 blocks by a specified deadline, providing censorship resistance and liveness guarantees when the L2 sequencer is unavailable or actively censoring transactions.

Overall, the implementation introduces a sophisticated forced transaction submission system with cryptographic integrity guarantees through MIMC-based rolling hash chains, EIP-1559 transaction format support via RLP encoding, and integration with Linea’s finalization state mechanism. The architecture demonstrates careful consideration of censorship resistance, economic security through mandatory fees, and state commitment integrity.

The audit did not uncover any major issues, but several edge cases and medium-severity concerns were identified. Specifically, these include the direct use of `ecrecover` without a supporting library, a time-of-check-to-time-of-use (TOCTOU) inconsistency in the address filter that could prevent state finalization, and the potential for address filter bypass via off-chain permit signatures (Permit2/ERC-2612), which may allow filtered addresses to move tokens indirectly.

**Update February 23rd 2026**: Upon the completion of the audit, we verified that the commit [`70dde763052985302cfaf4ea8e98010d11278ea1`](https://github.com/Consensys/linea-monorepo/pull/897/changes/70dde763052985302cfaf4ea8e98010d11278ea1) includes the deployment bytecode in `linea-monorepo/contracts/deployments/bytecode/2026-02-20/*`. The bytecode we built locally matches the bytecode in the deployment artifacts. Specifically, we verified the following files:

- AddressFilter.sol
- ForcedTransactionGateway.sol
- LineaRollup.sol
- Validium.sol

**Update May 6th 2026**: We verified that the commit [`4ddbeba806f1a31719539cd507d7bde29e4b481d`](https://github.com/Consensys/linea-monorepo/commit/4ddbeba806f1a31719539cd507d7bde29e4b481d) includes the deployment bytecode in `linea-monorepo/contracts/deployments/bytecode/2026-02-20/*`. The bytecodes we built locally match the bytecodes in the deployment artifacts. Specifically, we verified the following files:

- AddressFilter.sol
- ForcedTransactionGateway.sol
- LineaRollup.sol
- Validium.sol

**Update May 19th 2026**: We verified that the commit [`6d0c5d481a7b0e2a1e5ad829890f4cab8032cb66`](https://github.com/Consensys/linea-monorepo/commit/6d0c5d481a7b0e2a1e5ad829890f4cab8032cb66) includes the deployment bytecode in `linea-monorepo/contracts/deployments/bytecode/2026-02-20/*`. The bytecodes we built locally match the bytecodes in the deployment artifacts. Specifically, we verified the following files:

- AddressFilter.sol
- ForcedTransactionGateway.sol
- LineaRollup.sol
- Validium.sol

**Update June 23rd 2026**: The repository moved to <https://github.com/LFDT-Lineth/lineth-monorepo/> but kept the same commit history. We verified that the bytecodes deployed at the following addresses match the bytecodes in directory `lineth-monorepo/tree/main/contracts/deployments/bytecode/2026-02-20/` at commit [`6d0c5d481a7b0e2a1e5ad829890f4cab8032cb66`](https://github.com/LFDT-Lineth/lineth-monorepo/commit/6d0c5d481a7b0e2a1e5ad829890f4cab8032cb66)

- Ethereum:
  - Address Filter: [`0x526AE78F0103Ae73F05449ae30eb626C1003784E`](https://etherscan.io/address/0x526AE78F0103Ae73F05449ae30eb626C1003784E)
  - Linea Rollup: [`0x59290394dDC1cF84e671701A929710643c343530`](https://etherscan.io/address/0x59290394dDC1cF84e671701A929710643c343530)

## 2 Scope

This review focused on the following repository and code revision:

- <https://github.com/Consensys/linea-monorepo/tree/990f688e957632d27b3d9a86aec932a419041484>

Additionally, only some parts of the files were in scope for this engagement as can be seen in [PR 897](https://github.com/Consensys/linea-monorepo/pull/897).

The detailed list of files in scope can be found in the [Appendix](#appendix---files-in-scope).

### 2.1 Objectives

Together with **Linea**, we identified the following priorities for this review:

1. Correctness of the implementation, consistent with the intended functionality and without unintended edge cases.
2. Identify known vulnerabilities particular to smart contract systems, as outlined in our [Smart Contract Best Practices](https://consensysdiligence.github.io/smart-contract-best-practices/), and the [Smart Contract Weakness Classification Registry](https://swcregistry.io/).

## 3 Security Specification

This section describes, **from a security perspective**, the expected behavior of the system under review. It is not a substitute for documentation. The purpose of this section is to identify specific security properties that were validated by the review team.

### 3.1 Actors

The relevant actors are listed below with their respective abilities:

- **Users**: Submit forced transactions via `submitForcedTransaction()` on the ForcedTransactionGateway by providing EIP-1559 transaction parameters, signatures, and paying mandatory fees.
- **Gateway Contract (ForcedTransactionGateway)**: Validates forced transaction submissions, recovers transaction signers using `ecrecover`, RLP-encodes transaction payloads, computes MIMC rolling hashes, and calls `storeForcedTransaction()` on LineaRollupBase.
- **Address Filter Admin**: Holds `DEFAULT_ADMIN_ROLE` and can add/remove addresses from the filter list, toggle filter enforcement via `useAddressFilter`, but cannot retroactively modify already-submitted forced transactions.
- **Forced Transaction Fee Admin**: Can set the forced transaction fee via `setForcedTransactionFee()` but cannot withdraw fees.
- **Linea Rollup Operators**: Submit finalization proofs via `finalizeBlocks()` that include forced transaction state (rolling hash, transaction number). Operators must include forced transactions whose deadlines fall within the finalized range or finalization reverts.
- **Off-chain Coordinator**: Monitors `ForcedTransactionAdded` events on L1, extracts RLP-encoded transactions, and submits them to L2 sequencer via `lineaSendForcedRawTransaction` RPC.

### 3.2 Trust Model

In any system, it’s important to identify what trust assumptions are required for security properties to hold. For this review, we established the following trust model:

- **MIMC Cryptographic Primitives**: The system assumes the MIMC hash function provides adequate collision resistance and pre-image resistance for the rolling hash chain. The security of transaction ordering and tamper-evidence depends on MIMC’s cryptographic properties. The implementation must compute MIMC consistently on both L1 (Solidity) and within Linea’s zkSNARK circuits.
- **zkSNARK Proof System**: The system assumes the zkSNARK proof system correctly verifies that L2 execution matches the committed public inputs, including forced transaction number and rolling hash. Invalid proofs cannot be generated for incorrect execution, and the proof system enforces that forced transactions are processed according to protocol rules.
- **RLP Encoding Correctness**: The system relies on Solady’s LibRLP library to correctly encode EIP-1559 transactions according to Ethereum standards. The RLP-encoded payload on L1 must be byte-for-byte identical to what L2 decodes and executes. Encoding mismatches would cause transaction invalidity on L2.
- **Fee Configuration**: The system trusts the fee admin to set forced transaction fees at reasonable levels that balance spam prevention with accessibility. Excessively high fees could make the system unusable, but cannot prevent previously submitted forced transactions from executing.

## 4 Findings

Each issue has an assigned severity:

- Critical issues are directly exploitable security vulnerabilities that need to be fixed.
- Major issues are security vulnerabilities that may not be directly exploitable or may require certain conditions in order to be exploited. All major issues should be addressed.
- Medium issues are objective in nature but are not security vulnerabilities. These should be addressed unless there is a clear reason not to.
- Minor issues are subjective in nature. They are typically suggestions around best practices or readability. Code maintainers should use their own judgment as to whether to address such issues.
- Issues without a severity are general recommendations or optional improvements. They are not related to security or correctness and may be addressed at the discretion of the maintainer.

[### 4.1 Direct Usage of `ecrecover` Instead of Using a Library Medium ✓ Fixed](#direct-usage-of-ecrecover-instead-of-using-a-library)

#### Resolution

Fixed in [PR 897](https://github.com/Consensys/linea-monorepo/pull/897).

#### Description

In order to execute the transaction on behalf of a specific address, the Linea Forced Transactions require that a signature is passed along with the transaction data. As part of signature checks, the contract retrieves the `signer`:

**contracts/src/rollup/forcedTransactions/ForcedTransactionGateway.sol:L147-L155**

```
address signer;
unchecked {
  signer = ecrecover(
    hashedPayload,
    _forcedTransaction.yParity + 27,
    bytes32(_forcedTransaction.r),
    bytes32(_forcedTransaction.s)
  );
}
```

This is then checked against the address filter that ensures no blocked addresses get their transactions through the forced transaction feature, if such a filter is enabled:

**contracts/src/rollup/forcedTransactions/ForcedTransactionGateway.sol:L159-L162**

```
if (useAddressFilter) {
  require(!ADDRESS_FILTER.addressIsFiltered(signer), AddressIsFiltered());
  require(!ADDRESS_FILTER.addressIsFiltered(_forcedTransaction.to), AddressIsFiltered());
}
```

However, the code utilizes `ecrecover` directly, which is prone to edge cases and issues. One of such issues is returning the `0` address upon an invalid signature, which is indeed checked in the below line:

**contracts/src/rollup/forcedTransactions/ForcedTransactionGateway.sol:L157**

```
require(signer != address(0), SignerAddressZero());
```

Another, however, is the malleability of signature data when allowing users to provide `r` and `s` values themselves. Namely, two different signatures with parameters `(r,s)` and `(r,n-s)`, where `n` is the curve order, are both valid for the same hash. This is known as ECDSA signature malleability and is commonly mitigated by enforcing a low-s canonicality rule. Similarly, there are issues with compact signatures that also allow for malleability, as discussed in this [PR by OZ](https://github.com/OpenZeppelin/openzeppelin-contracts/security/advisories/GHSA-4h98-2769-gh6h), though in our case we don’t accept compact signatures.

While this isn’t critical in this case, as another valid signature would typically fail downstream checks (e.g. nonce validation), depending on the surrounding replay-protection logic, it is still best practice to use libraries when interacting with cryptographic primitives available in the EVM.

#### Recommendation

Consider using a library instead of using `ecrecover` directly, such as the `ECDSA` library by OZ.

[### 4.2 Address Filter State Change Between Forced Transaction Submission and Finalization Can Block Finalization Medium  Won't Fix](#address-filter-state-change-between-forced-transaction-submission-and-finalization-can-block-finalization)

#### Resolution

The Linea team confirmed that this is expected behavior and that they plan to document it.

#### Description

The L1 `AddressFilter` contract is checked at two points in the forced transaction lifecycle:

1. At submission via `submitForcedTransaction()` function in the `ForcedTransactionGateway` contract, where `ADDRESS_FILTER.addressIsFiltered()` is called on the signer and to address.

**contracts/src/rollup/forcedTransactions/ForcedTransactionGateway.sol:L159-L162**

```
if (useAddressFilter) {
  require(!ADDRESS_FILTER.addressIsFiltered(signer), AddressIsFiltered());
  require(!ADDRESS_FILTER.addressIsFiltered(_forcedTransaction.to), AddressIsFiltered());
}
```

2. At finalization via `_validateFilteredAddresses()` function in the `LineaRollupBase` contract, where the operator-supplied `filteredAddresses` array is validated against the current on-chain `addressFilter`.

**contracts/src/rollup/LineaRollupBase.sol:L530-L541**

```
function _validateFilteredAddresses(address[] calldata _filteredAddresses) internal view {
  if (_filteredAddresses.length > 0) {
    IAddressFilter addressFilterCached = addressFilter;

    for (uint256 i = 0; i < _filteredAddresses.length; i++) {
      require(
        addressFilterCached.addressIsFiltered(_filteredAddresses[i]),
        AddressIsNotFiltered(_filteredAddresses[i])
      );
    }
  }
}
```

Because the filter is mutable between these checkpoints (through `setAddressFilter()`, `setFilteredStatus()`, or `toggleUseAddressFilter()` functions) a time-of-check-to-time-of-use (TOCTOU) inconsistency can occur.

As an example, a forced transaction passes gateway and sequencer checks, but a newly-filtered address is added before finalization. The operator-supplied `filteredAddresses` array now includes an address present in the forced tx, causing `_validateFilteredAddresses` to revert finalization. The forced transaction becomes un-finalizable even though it was legitimately accepted.

#### Recommendation

The TOCTOU risk between forced transaction submission and finalization should be explicitly documented and, ideally, mitigated at the contract level. That could be implemented by snapshoting the address filter state relevant to a forced transaction at submission time so that finalization validates against the same filter state.

[### 4.3 Address Filter Bypass via Permit2/Erc-2612 Off-Chain Signatures Medium  Acknowledged](#address-filter-bypass-via-permit2erc-2612-off-chain-signatures)

#### Resolution

The Linea team acknowledges this finding and plans to document it.

#### Description

The `ForcedTransactionGateway` implements an address filter mechanism to prevent specific addresses from submitting forced transactions or being the recipient of such transactions:

**contracts/src/rollup/forcedTransactions/ForcedTransactionGateway.sol:L159-L162**

```
if (useAddressFilter) {
  require(!ADDRESS_FILTER.addressIsFiltered(signer), AddressIsFiltered());
  require(!ADDRESS_FILTER.addressIsFiltered(_forcedTransaction.to), AddressIsFiltered());
}
```

However, this filter can be bypassed for ERC-20 tokens that support **Permit2** (Uniswap’s universal approval standard) or **ERC-2612** (native permit). These standards allow token holders to authorize transfers via off-chain signatures rather than on-chain transactions.

Off-chain permit signature bypass:

1. Address A is added to the address filter (sanctioned address, malicious actor)
2. A holds ERC-20 tokens on L2 that are compatible with Permit2
3. A generates an off-chain Permit2 signature authorizing address B to spend their tokens
4. B (not filtered) submits a forced transaction (or a regular transaction) with:
   - `signer`: B
   - `to`: Permit2 contract or target DEX (not filtered)
   - `input`: Calls `permitTransferFrom()` using A’s signature
5. The forced transaction is accepted and executed on L2, moving A’s tokens despite the filter

#### Recommendation

Consider documenting and acknowledging the address filter feature’s limitation.

[### 4.4 Missing Rolling Hash Validation for Forced Transactions Allows Invalid State Submission Minor ✓ Fixed](#missing-rolling-hash-validation-for-forced-transactions-allows-invalid-state-submission)

#### Resolution

Fixed in [PR 897](https://github.com/Consensys/linea-monorepo/pull/897).

#### Description

The contract validates L1 message rolling hashes via `_validateL2ComputedRollingHash` to ensure non-zero message numbers have non-zero hashes, preventing operators from claiming invalid state. However, forced transaction rolling hashes lack equivalent validation.

When an operator finalizing blocks claims `finalForcedTransactionNumber = N` where `N` doesn’t exist (i.e. is above the actual number of submitted forced transactions), the mapping lookup returns `0x00` (empty slot):

**contracts/src/rollup/LineaRollupBase.sol:L391-L393**

```
bytes32 finalForcedTransactionRollingHash = forcedTransactionRollingHashes[
  _finalizationData.finalForcedTransactionNumber
];
```

The censorship check for transaction `N+1` also returns `0` (doesn’t exist), allowing the submission to proceed:

**contracts/src/rollup/LineaRollupBase.sol:L465-L477**

```
/// @dev Check the next forced transaction is outside the scope of our finalization for censorship resistance checking.
unchecked {
  uint256 nextFinalizationStartingForcedTxNumber = forcedTransactionL2BlockNumbers[
    _finalizationData.finalForcedTransactionNumber + 1
  ];

  if (
    nextFinalizationStartingForcedTxNumber > 0 &&
    nextFinalizationStartingForcedTxNumber <= _finalizationData.endBlockNumber
  ) {
    revert FinalizationDataMissingForcedTransaction(_finalizationData.finalForcedTransactionNumber + 1);
  }
}
```

As per the Linea team, the ZK proof system should reject such invalid states during circuit verification. In particular, during proof generation the intent is to take values from the contract and validate the proof accordingly. If the current submitted forced transaction number is `0`, the circuits expect `0x` for the forced transaction rolling hash. If the forced transaction number is non-zero, the hash is presumably expected to be non-zero, and would fail otherwise. However, the ZK circuits and proving system are out of scope of this engagement, though we understand that they’re supposed to fail during the generation of such proofs.

While the ZK circuits provide the ultimate security guarantee, the contract layer lacks the defensive validation check that exists for L1 message rolling hashes:

**contracts/src/rollup/LineaRollupBase.sol:L543-L561**

```
/**
 * @notice Internal function to validate l1 rolling hash.
 * @param _rollingHashMessageNumber Message number associated with the rolling hash as computed on L2.
 * @param _rollingHash L1 rolling hash as computed on L2.
 */
function _validateL2ComputedRollingHash(uint256 _rollingHashMessageNumber, bytes32 _rollingHash) internal view {
  if (_rollingHashMessageNumber == 0) {
    if (_rollingHash != EMPTY_HASH) {
      revert MissingMessageNumberForRollingHash(_rollingHash);
    }
  } else {
    if (_rollingHash == EMPTY_HASH) {
      revert MissingRollingHashForMessageNumber(_rollingHashMessageNumber);
    }
    if (rollingHashes[_rollingHashMessageNumber] != _rollingHash) {
      revert L1RollingHashDoesNotExistOnL1(_rollingHashMessageNumber, _rollingHash);
    }
  }
}
```

#### Recommendation

Consider adding a symmetric check to the forced transaction rolling hash which would disallow `0x` hashes for any submitted forced transaction number. This provides defense-in-depth alongside cryptographic verification.

[### 4.5 DOS of Forced Transaction Submission When `forcedTransactionFeeAmount` Is Sufficiently Low Minor  Acknowledged](#dos-of-forced-transaction-submission-when-forcedtransactionfeeamount-is-sufficiently-low)

#### Resolution

The Linea team acknowledges this finding and has confirmed they will carefully determine the forced transaction fee to effectively deter potential attackers while ensuring legitimate users can still submit forced transactions as needed.

#### Description

When a user submits a forced transaction for processing, the Linea coordinator service picks up the transaction data and submits it to the sequencer for proving. As a design decision, only one forced transaction is allowed to be submitted per L1 block. This is ensured by evaluating two consecutive forced transactions’ block deadlines with a check that enforces that the latest forced transaction has a deadline that’s strictly greater:

**contracts/src/rollup/LineaRollupBase.sol:L270-L275**

```
uint256 forcedTransactionNumber = nextForcedTransactionNumber++;

require(
  forcedTransactionL2BlockNumbers[forcedTransactionNumber - 1] < _blockNumberDeadline,
  ForcedTransactionExistsForBlockOrIsTooLow(_blockNumberDeadline)
);
```

This presents challenges for DOS where a malicious user could try spamming the forced transaction submission function, preventing any legitimate users from using it. Specifically, since the transaction data does not necessarily need to succeed, an attacker could simply reuse a single valid transaction signature, fully expecting that it will revert on every execution after the first due to a bad nonce.

To prevent that, there is a fee associated with forced transaction submissions:

**contracts/src/rollup/forcedTransactions/ForcedTransactionGateway.sol:L104**

```
require(msg.value == forcedTransactionFeeAmount, ForcedTransactionFeeNotMet(forcedTransactionFeeAmount, msg.value));
```

As a result, for every transaction the attacker would have to pay 1) the forced transaction fee, 2) the gas fee for processing the submission, and 3) the priority fee in every block to be the first user to submit a transaction in that block. Depending on gas fees and the value of the submission fee, this could be relatively affordable for a well funded malicious and determined actor. For example, with current gas fees and a $1 submission fee, it would be around $10k daily to block access to the forced transaction functionality for other users. However, it is important to note that legitimate users only need to succeed once in their transaction going through, and the attacker isn’t guaranteed to have their transaction picked up at all times.

#### Recommendation

Consider carefully setting the fee amount to significantly deter any attackers but still allow users to submit forced transactions on a per-need basis.

[### 4.6 Liveness Recovery Only Supports 5-Field Finalization State  Acknowledged](#liveness-recovery-only-supports-5-field-finalization-state)

#### Resolution

The Linea team acknowledges this finding and considers the liveness operator scenario highly unlikely (the finalization state will already have migrated to the 5-field format).

#### Description

The `LivenessRecovery.setLivenessRecoveryOperator()` function only validates the 5-field finalization state format (`messageNumber`, `rollingHash`, `forcedTransactionNumber`, `forcedTransactionRollingHash`, `timestamp`) and does not provide backward compatibility with the legacy 3-field format (`messageNumber`, `rollingHash`, `timestamp`):

**contracts/src/rollup/LivenessRecovery.sol:L48-L58**

```
if (
  currentFinalizedState !=
  FinalizedStateHashing._computeLastFinalizedState(
    _messageNumber,
    _rollingHash,
    _lastFinalizedForcedTransactionNumber,
    _lastFinalizedForcedTransactionRollingHash,
    _lastFinalizedTimestamp
  )
) {
  revert FinalizationStateIncorrect(
```

This differs from the functionality during block finalization in `LineaRollupBase`, which implements dual validation to support both formats during the migration period:

**contracts/src/rollup/LineaRollupBase.sol:L427-L446**

```
/// @dev Post upgrade the most common case will be the 5 fields post first finalization.
if (
  FinalizedStateHashing._computeLastFinalizedState(
    _finalizationData.lastFinalizedL1RollingHashMessageNumber,
    _finalizationData.lastFinalizedL1RollingHash,
    _finalizationData.lastFinalizedForcedTransactionNumber,
    _finalizationData.lastFinalizedForcedTransactionRollingHash,
    _finalizationData.lastFinalizedTimestamp
  ) != lastFinalizedState
) {
  /// @dev This is temporary and will be removed in the next upgrade and exists here for an initial zero-downtime migration.
  /// @dev Note: if this clause fails after first finalization post upgrade, the 5 fields are actually what is expected in the lastFinalizedState.
  if (
    FinalizedStateHashing._computeLastFinalizedState(
      _finalizationData.lastFinalizedL1RollingHashMessageNumber,
      _finalizationData.lastFinalizedL1RollingHash,
      _finalizationData.lastFinalizedTimestamp
    ) != lastFinalizedState
  ) {
    revert FinalizationStateIncorrect(
```

While the current implementation may be acceptable given that liveness recovery events are expected to occur far in the future when the protocol would have fully migrated to 5-field finalization, this is inconsistent and could cause a liveness recovery failure in edge case scenarios.

This situation is known to the Linea team and the assumed risk is deemed acceptable.

#### Recommendation

Consider implementing dual format validation in `setLivenessRecoveryOperator` similar to `_finalizeBlocks`, or explicitly document the assumption that liveness recovery will only be invoked after complete migration to the 5-field format. If the latter approach is chosen, consider initiating a few forced transactions in order to migrate finalization to the 5-field format as soon as it would be feasible.

## Appendix 1 - Files in Scope

This review covered the following files:

| File | SHA-1 hash |
| --- | --- |
| ./rollup/LineaRollupBase.sol | 5f68961a1599969fcbe70ae5eca2ab39860e63af |
| ./rollup/LineaRollup.sol | b0af899116c335c090cd693bf1f53471dcb3ff5b |
| ./rollup/LivenessRecovery.sol | 87883ad9953c81ad16b2c26da6533e52a8c3b28d |
| ./rollup/forcedTransactions/AddressFilter.sol | 2c7a1df32eebd85786232f92892b90805cdb0828 |
| ./rollup/forcedTransactions/ForcedTransactionGateway.sol | 02ae3892737f8db44f8d81fd2591118c90d0ad5e |
| ./rollup/forcedTransactions/interfaces/IAcceptForcedTransactions.sol | c3c1259e7e332e872e0673bfbe4092e67a1c3a7e |
| ./rollup/forcedTransactions/interfaces/IAddressFilter.sol | 815f0d7efbab5996a2ad6008a8ad3c364dc593e7 |
| ./rollup/forcedTransactions/interfaces/IForcedTransactionGateway.sol | 749ec6ea03fb9bcecbd3459a71c4c78534d3e2e6 |
| ./libraries/FinalizedStateHashing.sol | 8b6fe11d93c740a785333834c1b3b7334398af19 |

Please note that the following files were reviewed only partially and only insofar as the Forced Transactions mechanisms were concerned as guided by [PR 897](https://github.com/Consensys/linea-monorepo/pull/897):

- LineaRollupBase
- LineaRollup
- LivenessRecovery

## Appendix 2 - Disclosure

Consensys Diligence (“CD”) typically receives compensation from one or more clients (the “Clients”) for performing the analysis contained in these reports (the “Reports”). The Reports may be distributed through other means, including via Consensys publications and other distributions.

The Reports are not an endorsement or indictment of any particular project or team, and the Reports do not guarantee the security of any particular project. This Report does not consider, and should not be interpreted as considering or having any bearing on, the potential economics of a token, token sale or any other product, service or other asset. Cryptographic tokens are emergent technologies and carry with them high levels of technical risk and uncertainty. No Report provides any warranty or representation to any third party in any respect, including regarding the bug-free nature of code, the business model or proprietors of any such business model, and the legal compliance of any such business. No third party should rely on the Reports in any way, including for the purpose of making any decisions to buy or sell any token, product, service or other asset. Specifically, for the avoidance of doubt, this Report does not constitute investment advice, is not intended to be relied upon as investment advice, is not an endorsement of this project or team, and it is not a guarantee as to the absolute security of the project. CD owes no duty to any third party by virtue of publishing these Reports.

### A.2.1 Purpose of Reports

The Reports and the analysis described therein are created solely for Clients and published with their consent. The scope of our review is limited to a review of code and only the code we note as being within the scope of our review within this report. Any Solidity code itself presents unique and unquantifiable risks as the Solidity language itself remains under development and is subject to unknown risks and flaws. The review does not extend to the compiler layer, or any other areas beyond specified code that could present security risks. Cryptographic tokens are emergent technologies and carry with them high levels of technical risk and uncertainty. In some instances, we may perform penetration testing or infrastructure assessments depending on the scope of the particular engagement.

CD makes the Reports available to parties other than the Clients (i.e., “third parties”) on its website. CD hopes that by making these analyses publicly available, it can help the blockchain ecosystem develop technical best practices in this rapidly evolving area of innovation.

### A.2.2 Links to Other Web Sites from This Web Site

You may, through hypertext or other computer links, gain access to web sites operated by persons other than Consensys and CD. Such hyperlinks are provided for your reference and convenience only, and are the exclusive responsibility of such web sites’ owners. You agree that Consensys and CD are not responsible for the content or operation of such Web sites, and that Consensys and CD shall have no liability to you or any other person or entity for the use of third party Web sites. Except as described below, a hyperlink from this web Site to another web site does not imply or mean that Consensys and CD endorses the content on that Web site or the operator or operations of that site. You are solely responsible for determining the extent to which you may use any content at any other web sites to which you link from the Reports. Consensys and CD assumes no responsibility for the use of third-party software on the Web Site and shall have no liability whatsoever to any person or entity for the accuracy or completeness of any outcome generated by such software.

### A.2.3 Timeliness of Content

The content contained in the Reports is current as of the date appearing on the Report and is subject to change without notice unless indicated otherwise, by Consensys and CD.
