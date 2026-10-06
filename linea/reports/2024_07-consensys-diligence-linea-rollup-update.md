# Linea Rollup Update

Source: [https://diligence.security/audits/2024/07/linea-rollup-update/](https://diligence.security/audits/2024/07/linea-rollup-update/)

|  |  |
| --- | --- |
| Date | July 2024 |
| Auditors | Rai Yang, Vladislav Yaroshuk |
| Download | JSON  CSV |

## 1 Executive Summary

This report presents the results of our engagement with **Linea** to review **Linea Rollup Update**.

The review was conducted over two weeks, from **July 3, 2024** to **July 17, 2024**, by
**Rai Yang** and **Vlad Yaroshuk**. A total of 20 person-days were spent.

We reviewed the updates implemented between Linea Alpha v2 and Alpha v3.2. The key updates include:

- Leveraging EIP-4844 blob for blob submission (Alpha v3.0).
- Smart contract gas optimizations and message service updates (Alpha v3.2).
- Minor changes to the token bridge.

## 2 Scope

Our review focused on the commit hash [b17e7c79b5647e47c175c6367dea30c3f1c66738](https://github.com/Consensys/linea-contracts/tree/b17e7c79b5647e47c175c6367dea30c3f1c66738) and it’s has been verified to match the code in scope in the [monorepo](https://github.com/Consensys/zkevm-monorepo/releases/tag/contract-audit-2024-05-24). The list of files in scope can be found in the [Appendix](#appendix---files-in-scope).

### 2.1 Objectives

Together with the **Linea** team, we identified the following priorities for our review:

1. Correctness of the implementation, consistent with the intended functionality and without unintended edge cases.
2. Identify known vulnerabilities particular to smart contract systems, as outlined in our [Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/), and the [Smart Contract Weakness Classification Registry](https://swcregistry.io/).

## 3 Security Specification

This section describes, **from a security perspective**, the expected behavior of the system under audit. It is not a substitute for documentation. The purpose of this section is to identify specific security properties that were validated by the audit team.

The code update reviewed in this audit doesn’t change from the previous security properties.

### 3.1 Actors

The relevant actors with their respective abilities that are changed are listed below :

- Operator: Submits block data either by blobs or compressed data to L1 contract depending on the gas cost

### 3.2 Trust Model

In any system, it’s important to identify what trust is expected/required between various actors. For this audit, we established the
trust model remains unchanged from the previous versions

### 3.3 Security Properties

The following is a non-exhaustive list of security properties that were reviewed in this audit:

- EIP-4844 blob submission, validation and finalization is correct and sound
- Proof verification is sound (public input generation)
- Storage layout is not broken
- Changes to the Shnarf for data submission cardinality is correct and sound
- The replacement of the rolling hash, timestamp and message number storage variables with last finalized state is correct and sound
- Efficient hashing for data submission, public input, Shnarf and last finalized state is correct

## 4 Findings

Each issue has an assigned severity:

- Critical issues are directly exploitable security vulnerabilities that need to be fixed.
- Major issues are security vulnerabilities that may not be directly exploitable or may require certain conditions in order to be exploited. All major issues should be addressed.
- Medium issues are objective in nature but are not security vulnerabilities. These should be addressed unless there is a clear reason not to.
- Minor issues are subjective in nature. They are typically suggestions around best practices or readability. Code maintainers should use their own judgment as to whether to address such issues.
- Issues without a severity are general recommendations or optional improvements. They are not related to security or correctness and may be addressed at the discretion of the maintainer.

[### 4.1 Unremoved Executed Reinitializer Minor  Acknowledged](#unremoved-executed-reinitializer)

#### Resolution

The Linea team responded that they will fix the issue in the next version:

> We will make the recommended adjustments for the next audit round as the initializer is already coming out and the cost of the redeploy etc will far outstrip any gas savings we will get between now and the next deploy

.

#### Description

The reinitializer `initializeParentShnarfsAndFinalizedState` in the `LineaRollup` contract is executed and can not be executed anymore. It needs to be removed.

#### Examples

**contracts/contracts/LineaRollup.sol:L129-L146**

```
function initializeParentShnarfsAndFinalizedState(
  bytes32[] calldata _shnarfs,
  uint256[] calldata _finalBlockNumbers
) external reinitializer(5) {
  if (_shnarfs.length != _finalBlockNumbers.length) {
    revert ShnarfAndFinalBlockNumberLengthsMismatched(_shnarfs.length, _finalBlockNumbers.length);
  }

  for (uint256 i; i < _shnarfs.length; i++) {
    shnarfFinalBlockNumbers[_shnarfs[i]] = _finalBlockNumbers[i];
  }

  currentFinalizedState = _computeLastFinalizedState(
    currentL2StoredL1MessageNumber,
    currentL2StoredL1RollingHash,
    currentTimestamp
  );
}
```

#### Recommendation

Remove the reinitializer `initializeParentShnarfsAndFinalizedState`.

[### 4.2 Unnecessary Continuity Checks in Data Finalization Minor  Acknowledged](#unnecessary-continuity-checks-in-data-finalization)

#### Resolution

The Linea team responded that they will fix the issue in the next version:

> We will make the recommended adjustments for the next audit round as the initializer is already coming out and the cost of the redeploy etc will far outstrip any gas savings we will get between now and the next deploy

#### Description

In function `finalizeBlocksWithProof` of the `LineaRollup` contract, the continuity check between `lastFinalizedShnarf` of the finalization data (`_finalizationData`) and current finalized shnarf `currentFinalizedShnarf` is redundant. Both values are already included in the public input and are verified in the proof.
Similarly, the continuity check between the final block number in the finalization data (`_finalizationData.finalBlockInData`) and the final block number of last submitted blob (`shnarfFinalBlockNumbers[finalShnarf]`) in `_finalizeBlocks` is also redundant. These values are also included in the public input and are validated in the proof. However this check is needed for `finalizeBlocksWithoutProof`, as there is no proof validating it.

#### Examples

**contracts/contracts/LineaRollup.sol:L455-L457**

```
if (_finalizationData.lastFinalizedShnarf != lastFinalizedShnarf) {
  revert LastFinalizedShnarfWrong(lastFinalizedShnarf, _finalizationData.lastFinalizedShnarf);
}
```

**contracts/contracts/LineaRollup.sol:L543-L548**

```
if (shnarfFinalBlockNumbers[finalShnarf] != _finalizationData.finalBlockInData) {
  revert FinalBlockDoesNotMatchShnarfFinalBlock(
    _finalizationData.finalBlockInData,
    shnarfFinalBlockNumbers[finalShnarf]
  );
}
```

**contracts/contracts/LineaRollup.sol:L461-L466**

```
uint256 publicInput = _computePublicInput(
  _finalizationData,
  lastFinalizedShnarf,
  finalShnarf,
  lastFinalizedBlockNumber
);
```

#### Recommendation

Remove the redundant finalized shnarf continuity check in `finalizeBlocksWithProof` and move the final block number check to `finalizeBlocksWithoutProof`.

## Appendix 1 - Files in Scope

This audit covered the following files:

| File | SHA-1 hash |
| --- | --- |
|  |  |
| contracts/LineaRollup.sol | `bea9b8c66a02c79750e2dd62c5cfe5de20728d27` |
| contracts/LineaRollupInit.sol | `4e6a0fb424b848aa0c8e4996fa0407448be25315` |
| contracts/ZkEvmV2.sol | `a02bf1ac899ce64abf4bd3eb0ec24f936d51792a` |
| contracts/interfaces/IGenericErrors.sol | `5447de7baae9305c00d2e435cd3dacc082db1647` |
| contracts/interfaces/IMessageService.sol | `278dc26d3f4215d45a8ecf298ce545869b0e9b4d` |
| contracts/interfaces/IPauseManager.sol | `ad9e44fd44814dbde674a5ef00923eaa4721b3a9` |
| contracts/interfaces/IRateLimiter.sol | `aebe02d947650ac34922177b7abb0de694714477` |
| contracts/interfaces/l1/IL1MessageManager.sol | `709499bf667c207c62dcbf6a5c83a796b0e407c2` |
| contracts/interfaces/l1/IL1MessageManagerV1.sol | `b12380e58535c3eb38f27c81f83a25cfc5280125` |
| contracts/interfaces/l1/IL1MessageService.sol | `a5fad8bcc51fa829db7e68f92507b04b9118bf9b` |
| contracts/interfaces/l1/ILineaRollup.sol | `8f701d4bc363992e824b75c944586b9edf3ccb9c` |
| contracts/interfaces/l1/IZkEvmV2.sol | `7b8489cebb2e9de48a3f0657400441731e9bec5f` |
| contracts/interfaces/l2/IL2MessageManager.sol | `ea877bf72dca4d89be0fdcd67ecad397ac89b305` |
| contracts/interfaces/l2/IL2MessageManagerV1.sol | `437fb3c7195fb0207cd688ba5823eecac4479e76` |
| contracts/lib/Utils.sol | `a03bea999a7c8061cc24aec5882b27e946253fa3` |
| contracts/messageService/MessageServiceBase.sol | `1fc701c38f219dc2ab6425e2083bdfef018847d3` |
| contracts/messageService/l1/L1MessageManager.sol | `8a18de15b4b4973dbf29c1fe664acc81950ac56f` |
| contracts/messageService/l1/L1MessageService.sol | `6e29f1b321849c8d4e7281932e8ae2f8b23bbd7d` |
| contracts/messageService/l1/TransientStorageReentrancyGuardUpgradeable.sol | `2fddbdb54db6c3ffb8ff17cdc46e56f0a065358b` |
| contracts/messageService/l1/v1/L1MessageManagerV1.sol | `1ba06e8066ae90f3634e47eb7c3c5b2b1ecac5a4` |
| contracts/messageService/l1/v1/L1MessageServiceV1.sol | `cbda202f03c05ee2179ae1dafec3b28c29fff2a0` |
| contracts/messageService/l2/L2MessageManager.sol | `e72b20f8a18491e6658579d57567f3ab806fef22` |
| contracts/messageService/l2/L2MessageService.sol | `96d9adf92e223120b2882e4ad32c2177979a9faa` |
| contracts/messageService/l2/v1/L2MessageManagerV1.sol | `100cf8e8f9680a3997ccc39938fae469e8e3937b` |
| contracts/messageService/l2/v1/L2MessageServiceV1.sol | `87c2c49d4a846386e752ccbe25ca054ac829ea3e` |
| contracts/messageService/lib/PauseManager.sol | `799f2186ade5d4ef60cbe858f56eba78f901ec32` |
| contracts/messageService/lib/RateLimiter.sol | `5affe9baa42ab0a6901ab51d08e63e924e3231d4` |
| contracts/messageService/lib/SparseMerkleTreeVerifier.sol | `a0fbc400535754789c4dce1d14b24238cf126504` |
| contracts/messageService/lib/TransientStorageHelpers.sol | `777c20c16b487334c6c62299cae60e612e691a7a` |
| contracts/tokenBridge/TokenBridge.sol | `834e07d87c6d0e97a41f4c528d58870bbc125546` |
| contracts/tokenBridge/interfaces/ITokenBridge.sol | `faaf3489842f3321abb1c38dd7ba08cbf470d54f` |

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
