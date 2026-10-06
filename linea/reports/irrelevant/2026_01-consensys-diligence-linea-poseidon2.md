# Linea Poseidon2

Source: [https://diligence.security/audits/2026/01/linea-poseidon2/](https://diligence.security/audits/2026/01/linea-poseidon2/)

|  |  |
| --- | --- |
| Date | January 2026 |
| Auditors | George Kobakhidze, François Legué |
| Download | JSON  CSV |

## 1 Executive Summary

This report presents the results of our engagement with **Linea** to review the integration of the **Poseidon2** hashing algorithm into Linea’s cryptographic verification layer. This layer enables trustless cross-chain ENS resolution and general L2 state queries from Ethereum L1 by verifying sparse Merkle proofs against finalized state roots.

The review was conducted from **January 19, 2026** to **January 30, 2026** with a total effort of **2 x 10** person-days.

Overall, the implementation demonstrates a high level of quality. The code performs complex mathematical operations and has been heavily gas-optimized through data packing and assembly usage, yet it adheres to the Poseidon2 algorithm specification and follows best practices.

The review identified one medium-severity issue related to proof malleability in the sparse Merkle proof verification, where unused bytes in the proof structure are not validated—potentially affecting downstream systems that rely on proof uniqueness. Additionally, one minor issue was found regarding the handling of zero-length input in the `hash()` function, along with documentation inconsistencies referencing the deprecated MiMC algorithm.

**Update February 6th 2026**: Upon the completion of the audit, we have verified that the commit [`1b0cba233c4aa03fb1f6479abc1c838f40315ab6`](https://github.com/Consensys/linea-apps-monorepo/commit/1b0cba233c4aa03fb1f6479abc1c838f40315ab6) contains the necessary fixes for issues found during the audit. This commit also contains the deployment artifacts in `linea-apps-monorepo/packages/ens-resolver/deployments/bytecode/2026-02-05/*` the bytecode within which matches the bytecode in the deployment artifacts we built locally. Specifically, we have built and verified matches of the bytecode of the following files:

- LineaSparseProofVerifier.sol
- Poseidon2.sol
- SparseMerkleProof.sol
- L1Resolver.sol

**Update February 17th 2026**: We have verified that the commit [`a87d7185e5529ac354c815b6f68a9c12f32d8a42`](https://github.com/Consensys/linea-apps-monorepo/commit/a87d7185e5529ac354c815b6f68a9c12f32d8a42) adds a leaf length check in the sparse Merkle proof contract, ensuring that the leaf data provided to the proof verification has a valid/expected length. This commit also contains the deployment artifacts in `linea-apps-monorepo/packages/ens-resolver/deployments/bytecode/2026-02-27/*` the bytecode within which matches the bytecode in the deployment artifacts we built locally. Specifically, we have built and verified matches of the bytecode of the following files:

- LineaSparseProofVerifier.sol
- Poseidon2.sol
- SparseMerkleProof.sol
- L1Resolver.sol

**Update March 3rd 2026**: We have verified that the commit [`909b320c613488ae81355d1564933c45f9d4b5f9`](https://github.com/Consensys/linea-apps-monorepo/commit/909b320c613488ae81355d1564933c45f9d4b5f9) updates the computation of `targetHash` to ensure consistency with the implementation in the gnark-crypto codebase. This commit also contains the deployment artifacts in `linea-apps-monorepo/packages/ens-resolver/deployments/bytecode/2026-03-02/*` the bytecode within which matches the bytecode in the deployment artifacts we built locally. Specifically, we have built and verified matches of the bytecode of the following files:

- LineaSparseProofVerifier.sol
- Poseidon2.sol
- SparseMerkleProof.sol
- L1Resolver.sol

Moreover, we confirm that the bytecodes of the contracts deployed at the following addresses match the bytecodes in directory `linea-apps-monorepo/packages/ens-resolver/deployments/bytecode/2026-03-02/*` at commit [`909b320c613488ae81355d1564933c45f9d4b5f9`](https://github.com/Consensys/linea-apps-monorepo/commit/909b320c613488ae81355d1564933c45f9d4b5f9).

- Ethereum:
  - ENS Linea Sparse Proof Verifier [`0x9a4b070A5A6C09C2d0f00309aC1613109A3F6b41`](https://etherscan.io/address/0x9a4b070A5A6C09C2d0f00309aC1613109A3F6b41):
  - ENS Sparse Merkle Proof [`0x3dB97Ff4c9D1A2485B1DBe9c9e843359462A1661`](https://etherscan.io/address/0x3dB97Ff4c9D1A2485B1DBe9c9e843359462A1661)
  - Poseidon2 [`0x8f65FC8C9103e35967D5E8CEb0829E4df96D2c5D`](https://etherscan.io/address/0x8f65FC8C9103e35967D5E8CEb0829E4df96D2c5D)
  - ENS L1 Resolver [`0x1507cE9421232FDBd302f5EbE4590F8D77FeBBFF`](https://etherscan.io/address/0x1507cE9421232FDBd302f5EbE4590F8D77FeBBFF)

## 2 Scope

This review focused on the following repository and code revision:

- [Consensys/linea-apps-monorepo@`dab0c2f`](https://github.com/Consensys/linea-apps-monorepo/commit/dab0c2fa947bb7d4b5fb5aafc6c2cc7aabacbe3d)

The detailed list of files in scope can be found in the [Appendix](#appendix---files-in-scope).

### 2.1 Objectives

Together with **Linea**, we identified the following priorities for this review:

1. Correctness of the implementation, consistent with the intended functionality and without unintended edge cases.
2. Identify known vulnerabilities particular to smart contract systems, as outlined in our [Smart Contract Best Practices](https://consensysdiligence.github.io/smart-contract-best-practices/), and the [Smart Contract Weakness Classification Registry](https://swcregistry.io/).
3. Implementation correctness of the Poseidon2 hashing algorithm.
4. Integration of the hashing algorithm with the currently deployed smart contracts.

## 3 System Overview

This audit focuses on the cryptographic verification layer that enables **cross-chain ENS (Ethereum Name Service) resolution** and general L2 state queries from Layer 1.

When an ENS resolution is initiated on Ethereum L1 for a name whose records are stored on the Linea L2 blockchain, the request is routed through a **CCIP (Cross-Chain Interoperability Protocol) gateway**. This off-chain gateway service generates a cryptographic proof of the requested state (e.g., an address record, text record, or content hash) from Linea’s current state. The gateway then returns this proof to L1, where the **LineaSparseProofVerifier** contract verifies it on-chain.

The **Poseidon2 hash function** is the cryptographic foundation of this entire verification system. Linea’s L2 state is organized as a **sparse Merkle tree** where every account and storage slot is hashed using Poseidon2. The state root (a single 32-byte hash computed via Poseidon2) represents the entire L2 state at a specific block and is periodically committed to the L1 rollup contract. The Poseidon2 implementation uses a feed-forward compression algorithm instead of the traditional sponge construction, operating on fixed-size inputs. When verifying a proof:

1. **Leaf Hashing**: Account data (nonce, balance, storage root, code hashes, code size) is hashed using Poseidon2 with a specific padding scheme
2. **Storage Hashing**: Individual storage values are hashed using Poseidon2
3. **Merkle Path Verification**: Each level of the 40-deep sparse Merkle tree uses Poseidon2 to hash parent nodes from their children
4. **Root Computation**: The final verification computes a state root via Poseidon2 and compares it against the trusted root stored in the rollup contract

This architecture enables **trustless cross-chain queries**: L1 smart contracts (including ENS resolvers) can verify that specific data exists in Linea’s L2 state without trusting the gateway operator, relying instead on cryptographic proofs verified against the rollup’s finalized state roots. Poseidon2 is particularly well-suited for this use case because Linea’s state tree must be provable in zero-knowledge circuits while remaining gas-efficient for L1 verification. The reviewed implementation features aggressive gas optimizations, including lazy modular reduction techniques that minimize expensive modular arithmetic operations.

## 4 Security Specification

This section describes, **from a security perspective**, the expected behavior of the system under review. It is not a substitute for documentation. The purpose of this section is to identify specific security properties that were validated by the review team.

### 4.1 Actors

The relevant actors are listed below with their respective abilities:

- **Gateway Operators**: Operate the off-chain CCIP-Read (EIP-3668) infrastructure that generates Merkle proofs for L2 state. They have access to the full L2 state database and serve proofs via HTTP endpoints. Gateway operators cannot forge proofs that verify against incorrect state roots, cannot force the verifier to accept invalid proofs, and cannot manipulate on-chain state roots.
- **Linea Rollup Operators**: Operate the Linea L2 rollup and submit finalized state roots to the L1 rollup contract. They maintain L2 state and update the current L2 block number on L1.
- **Contract Deployer**: Deploys and configures `LineaSparseProofVerifier` on L1 Ethereum, setting the gateway URLs and rollup contract address at deployment. Post-deployment, the deployer has no special privileges—configuration is immutable.

### 4.2 Trust Model

In any system, it’s important to identify what trust assumptions are required for security properties to hold. For this review, we established the following trust model:

- **Poseidon2 Cryptographic Primitives**: The system assumes the Poseidon2 hash function provides adequate collision resistance, pre-image resistance, and second pre-image resistance for the given parameters (31-bit prime field, feed-forward compression algorithm). Additionally, the security of the implementation depends on the correctness of the Poseidon2 round constants and MDS matrix parameters used in the setup, as the entire cryptographic scheme relies on these constants being generated correctly.
- **Contract Deployer**: The deployer must correctly configure the rollup contract address and gateway URLs. Misconfiguration at deployment could point to a malicious rollup or unavailable gateway. Post-deployment, no trust is required as configuration is immutable.

## 5 Findings

Each issue has an assigned severity:

- Critical issues are directly exploitable security vulnerabilities that need to be fixed.
- Major issues are security vulnerabilities that may not be directly exploitable or may require certain conditions in order to be exploited. All major issues should be addressed.
- Medium issues are objective in nature but are not security vulnerabilities. These should be addressed unless there is a clear reason not to.
- Minor issues are subjective in nature. They are typically suggestions around best practices or readability. Code maintainers should use their own judgment as to whether to address such issues.
- Issues without a severity are general recommendations or optional improvements. They are not related to security or correctness and may be addressed at the discretion of the maintainer.

[### 5.1 Unvalidated `subSMTRoot` in Sparse Merkle Proof Leads to Proof Malleability Medium ✓ Fixed](#unvalidatedsubsmtrootin-sparse-merkle-proof-leads-to-proof-malleability)

#### Resolution

Fixed in [PR 39](https://github.com/Consensys/linea-apps-monorepo/pull/39).

#### Description

The `SparseMerkleProof._formatProof` function expects `_rawProof[0]` to be 96 bytes but only uses the first 64 bytes as `nextFreeNode`. The remaining 32 bytes (which appear to represent a `subSMTRoot`) are never validated against the computed hash during verification, allowing multiple distinct proof byte sequences to pass verification for the same storage values.

**packages/state-verifier/contracts/lib/SparseMerkleProof.sol:L179**

```
bytes32[2] memory nextFreeNode = abi.decode(_rawProof[0][:64], (bytes32[2]));
```

In the SparseMerkleProof contract, the `_verify` function computes a hash by traversing from the leaf up through the tree:

**packages/state-verifier/contracts/lib/SparseMerkleProof.sol:L251-L257**

```
for (uint256 height; height < TREE_DEPTH; ++height) {
  if ((currentIndex >> height) & 1 == 1)
    computedHash = Poseidon2.hash(abi.encodePacked(_proof[height], computedHash));
  else computedHash = Poseidon2.hash(abi.encodePacked(computedHash, _proof[height]));
}

return Poseidon2.hash(abi.encodePacked(_nextFreeNode, computedHash)) == _root;
```

The `computedHash` after the loop represents the computed `subSMTRoot`, but this value is never compared against the 32 bytes provided in `rawProof[0][64:96]`. An attacker can provide arbitrary bytes in this unused portion without affecting verification outcome.

As a result, multiple distinct `proof` byte sequences can pass verification for the exact same storage values. This could cause issues for any downstream systems that rely on proof uniqueness or perform deduplication.

#### Recommendation

Update the proof verification flow by extracting `subSMTRoot` from `rawProof[0][64:96]` in `_formatProof`, passing it into `_verify`, and adding a post-loop check to ensure `computedHash == subSMTRoot` before hashing with `nextFreeNode`.

[### 5.2 `hash()` of a `0` Length Calldata Returns a 32 Byte `0x0` Hash Minor ✓ Fixed](#hash-of-a-0-length-calldata-returns-a-32-byte-0x0-hash)

#### Resolution

Fixed in [PR 41](https://github.com/Consensys/linea-apps-monorepo/pull/41).

#### Description

The `hash()` function accepts zero-length `_msg` calldata input because `_msg.length % 32 == 0` passes the below check:

**packages/state-verifier/contracts/lib/Poseidon2.sol:L65-L68**

```
let len := _msg.length
if and(len, 31) {
  error_size_data()
}
```

Then, for `len == 0` the function skips feed-forward compression and permutation loop:

**packages/state-verifier/contracts/lib/Poseidon2.sol:L70-L75**

```
let q := shr(5, len)
let ptrMsg := _msg.offset

for {
  let i := 0
} lt(i, q) {
```

As a result, it returns an uninitialized `bytes32 poseidon2Hash` which is simply `0x0000000000000000000000000000000000000000000000000000000000000000`.

Typically, hashing protocols either define a special case for 0 input, or explicitly error out on 0 as undefined length errors, such as in our case with lengths not divisible into 32 bytes. This makes the digest of empty input equal to the zero value, which can introduce ambiguity or unintended behavior for callers that treat empty input as invalid or expect a defined nontrivial digest.

#### Recommendation

Handle the 0 length case.

[### 5.3 Update Comments and Tests ✓ Fixed](#update-comments-and-tests)

#### Resolution

Fixed in [PR 42](https://github.com/Consensys/linea-apps-monorepo/pull/42).

#### Description

The codebase has migrated from MiMC to Poseidon2 as the hashing algorithm, but multiple references to the old “MiMC” algorithm remain in documentation comments and in test files. This creates confusion about which hashing algorithm is actually being used and may lead to misunderstandings during code maintenance, or integration.

**packages/state-verifier/contracts/lib/SparseMerkleProof.sol:L99**

```
* @param _encodedAccountValue Encoded account value bytes (nonce, balance, storageRoot, mimcCodeHash, keccakCodeHash, codeSize).
```

**packages/state-verifier/contracts/lib/SparseMerkleProof.sol:L108**

```
* @param _value Encoded account value bytes (nonce, balance, storageRoot, mimcCodeHash, keccakCodeHash, codeSize).
```

**packages/state-verifier/contracts/lib/SparseMerkleProof.sol:L150**

```
* @param _value Encoded account value bytes (nonce, balance, storageRoot, mimcCodeHash, keccakCodeHash, codeSize).
```

In addition, a comment specifies a Poseidon parameter `t = 2`, while the actual implementation uses `t = 16`, where `t` denotes the width of the Poseidon state. Specifically, the permutation is performed over a 16-element state that is packed into two `uint256` values. This inconsistency misrepresents the actual cryptographic parameters and may result in misunderstandings about the security properties and internal behavior of the hash function.

**packages/state-verifier/contracts/lib/Poseidon2.sol:L87**

```
* @dev Poseidon2 permutation over a 2-element state (ra, rb).
```

**packages/state-verifier/contracts/lib/Poseidon2.sol:L95**

```
* Each round follows the Poseidon2 specification for t = 2.
```

#### Recommendation

Update all comments and tests files to reflect the usage of Poseidon2 with its correct parameters.

## Appendix 1 - Files in Scope

This review covered the following files. Please note that the review of `LineaProofHelper` only concerned 1 line that performed the new call for the `SparseMerkleProof.poseidon2Hash()` function:

| File | SHA-1 hash |
| --- | --- |
| ./contracts/lib/Poseidon2.sol | be02c6ae44b5bc383a2d492201de822d8cd1d510 |
| ./contracts/lib/SparseMerkleProof.sol | 839cf4fc5514f473698cf3190636a306c3cccdfe |
| ./contracts/LineaProofHelper.sol | 6e79c23e3d5a636e4d7df055ab5fe5b1a66aa1f7 |

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
