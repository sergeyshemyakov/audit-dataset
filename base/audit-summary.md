# Audit source summary: base

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Nitro Validator Security Review

- Report: [2024_12-Nitro_Validator-Cantina.md](<reports/2024_12-Nitro_Validator-Cantina.md>)
- Auditor: Cantina
- Date: 2025-01-29
- Description: Cantina Managed review (December 13-25, 2024) of the nitro-validator Solidity contracts that verify AWS Nitro Enclave attestations onchain (CBOR/ASN.1 decoding, certificate chain management, SHA-384 and P-384 signature verification). Fixes for all findings except one acknowledged informational were verified in follow-up pull requests.

### Repository: <a href="https://github.com/base/nitro-validator"><code>base/nitro-validator</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/nitro-validator/commit/7879d9b667e576e39edc9803e1660b4ddb89d934"><code>7879d9b667e576e39edc9803e1660b4ddb89d934</code></a> | December 11, 2024 | <code>src/Asn1Decode.sol</code><br><code>src/CborDecode.sol</code><br><code>src/CertManager.sol</code><br><code>src/ECDSA384Curve.sol</code><br><code>src/ICertManager.sol</code><br><code>src/LibBytes.sol</code><br><code>src/NitroValidator.sol</code><br><code>src/Sha2Ext.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/6516f1976bbde723f3783ec204d38c9b666d286e"><code>6516f1976bbde723f3783ec204d38c9b666d286e</code></a> | January 10, 2025 | <code>src/CborDecode.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/c7ba4451cbf814c6fee3e9a05eb13b35499262ff"><code>c7ba4451cbf814c6fee3e9a05eb13b35499262ff</code></a> | January 10, 2025 | <code>src/CertManager.sol</code><br><code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/7dd8c275b743783546a003a36a452ab65495b1fd"><code>7dd8c275b743783546a003a36a452ab65495b1fd</code></a> | January 10, 2025 | <code>src/ICertManager.sol</code><br><code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/43a3c100cf6d42a4bcf23e1b39a7569dd5268b5b"><code>43a3c100cf6d42a4bcf23e1b39a7569dd5268b5b</code></a> | January 11, 2025 | <code>src/Asn1Decode.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/b146321dc081e61198268902269ccdf73c7e2d16"><code>b146321dc081e61198268902269ccdf73c7e2d16</code></a> | January 11, 2025 | <code>src/Asn1Decode.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/eb0702b22e44dd301e2437118fac45b987ccea3f"><code>eb0702b22e44dd301e2437118fac45b987ccea3f</code></a> | January 11, 2025 | <code>src/Asn1Decode.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/7ad540b7a2b89abf6f00534103e9334ffb79f640"><code>7ad540b7a2b89abf6f00534103e9334ffb79f640</code></a> | January 11, 2025 | <code>src/Asn1Decode.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/309bd7ce730c3377ad9cc2ff4f70a964c0c3bd55"><code>309bd7ce730c3377ad9cc2ff4f70a964c0c3bd55</code></a> | January 11, 2025 | <code>src/CertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/16f39f9c734cbc3fc38bf7a63b7b30883a251ede"><code>16f39f9c734cbc3fc38bf7a63b7b30883a251ede</code></a> | January 11, 2025 | <code>src/LibBytes.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/5a9d2b177fc825bd2d4e47b60aabf7ee136610f1"><code>5a9d2b177fc825bd2d4e47b60aabf7ee136610f1</code></a> | January 11, 2025 | <code>src/Sha2Ext.sol</code> |

## Op Enclave Security Review (January 2025)

- Report: [2025_01-OP_Enclave-Spearbit.md](<reports/2025_01-OP_Enclave-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-01-24
- Description: Spearbit review of Base&#x27;s op-enclave L3 stack, covering the onchain contracts (DeployChain, OutputOracle, Portal, ResolvingProxy) and the offchain enclave, batcher, proposer and withdrawer Go code at a single commit. Review ran December 23, 2024 to January 10, 2025 and includes fix verification of the reported issues via follow-up PRs.

### Repository: <a href="https://github.com/base/op-enclave"><code>base/op-enclave</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/op-enclave/commit/98d346dd0e1cdbde75fba01efd36a07e7cf24391"><code>98d346dd0e1cdbde75fba01efd36a07e7cf24391</code></a> | December 20, 2024 | <code>contracts/src</code> (recursive directory)<br><code>op-enclave</code> (recursive directory) (other)<br><code>op-batcher</code> (recursive directory) (other)<br><code>op-proposer</code> (recursive directory) (other)<br><code>op-withdrawer</code> (recursive directory) (other) |
| <a href="https://github.com/base/op-enclave/commit/8f28fbb6a30f4bcae8057a61e72120423554baca"><code>8f28fbb6a30f4bcae8057a61e72120423554baca</code></a> | December 25, 2024 | <code>op-batcher</code> (recursive directory) (other) |
| <a href="https://github.com/base/op-enclave/commit/4a7e36a0860ba408f2f5538ea7a9a117987d08d6"><code>4a7e36a0860ba408f2f5538ea7a9a117987d08d6</code></a> | January 1, 2025 | <code>contracts/src</code> (recursive directory)<br><code>op-enclave</code> (recursive directory) (other) |
| <a href="https://github.com/base/op-enclave/commit/156d495b8a2841a2990aa790dc97a934429bbc3f"><code>156d495b8a2841a2990aa790dc97a934429bbc3f</code></a> | January 3, 2025 | <code>contracts/src</code> (recursive directory) |
| <a href="https://github.com/base/op-enclave/commit/6e37ce2036c58f6d555001d5f02d81627f5a0428"><code>6e37ce2036c58f6d555001d5f02d81627f5a0428</code></a> | January 3, 2025 | <code>contracts/src</code> (recursive directory) |
| <a href="https://github.com/base/op-enclave/commit/c6fe9fbd38074a6463eea57003f5f646e6e8f982"><code>c6fe9fbd38074a6463eea57003f5f646e6e8f982</code></a> | January 3, 2025 | <code>contracts/src</code> (recursive directory) |
| <a href="https://github.com/base/op-enclave/commit/69990879c401bf3d859e9665772c90f93517dbeb"><code>69990879c401bf3d859e9665772c90f93517dbeb</code></a> | January 3, 2025 | <code>contracts/src</code> (recursive directory) |
| <a href="https://github.com/base/op-enclave/commit/de236915c001d6a1d05ae22b1e369564cad5e44a"><code>de236915c001d6a1d05ae22b1e369564cad5e44a</code></a> | January 3, 2025 | <code>op-enclave</code> (recursive directory) (other) |
| <a href="https://github.com/base/op-enclave/commit/ab2d40808ad61afe26e423285e650c723e877570"><code>ab2d40808ad61afe26e423285e650c723e877570</code></a> | January 3, 2025 | <code>op-proposer</code> (recursive directory) (other) |
| <a href="https://github.com/base/op-enclave/commit/bfd6dbd91c5b06eb4c539e3c1bab25211d54137e"><code>bfd6dbd91c5b06eb4c539e3c1bab25211d54137e</code></a> | January 3, 2025 | <code>op-withdrawer</code> (recursive directory) (other) |
| <a href="https://github.com/base/op-enclave/commit/628aa61032c428a3e8f28e3f2925a758a545fc54"><code>628aa61032c428a3e8f28e3f2925a758a545fc54</code></a> | January 9, 2025 | <code>op-enclave</code> (recursive directory) (other) |
| <a href="https://github.com/base/op-enclave/commit/e1f2146f8fe8fe9604fc51b938d24c7865cf7dc4"><code>e1f2146f8fe8fe9604fc51b938d24c7865cf7dc4</code></a> | January 9, 2025 | <code>op-withdrawer</code> (recursive directory) (other) |

## Coinbase Multiproof Security Review (March 2026)

- Report: [2026_03-Multiproof-Cantina.md](<reports/2026_03-Multiproof-Cantina.md>)
- Auditor: Cantina
- Date: 2026-03-31
- Description: Cantina Managed review of the Base multiproof contracts (AggregateVerifier, Verifier, and the TEE verification contracts NitroEnclaveVerifier, TEEProverRegistry, TEEVerifier) in base/contracts at commit b6c4689b. The review ran March 17-23, 2026, found four Informational issues, and verified their fixes.

### Repository: <a href="https://github.com/base/contracts"><code>base/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/contracts/commit/b6c4689b8f814bf23fb915ac1d68a537d707ae4e"><code>b6c4689b8f814bf23fb915ac1d68a537d707ae4e</code></a> | March 14, 2026 | <code>src/multiproof/AggregateVerifier.sol</code><br><code>src/multiproof/Verifier.sol</code><br><code>src/multiproof/tee/NitroEnclaveVerifier.sol</code><br><code>src/multiproof/tee/TEEProverRegistry.sol</code><br><code>src/multiproof/tee/TEEVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/dd587c9adc84a768eb540a88ef479275c5db97e9"><code>dd587c9adc84a768eb540a88ef479275c5db97e9</code></a> | March 25, 2026 | <code>src/multiproof/AggregateVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/488feae7e25a6f869dff2e1174987a68f992f941"><code>488feae7e25a6f869dff2e1174987a68f992f941</code></a> | March 25, 2026 | <code>src/multiproof/AggregateVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/2007b3126c2e8b6bb8ff607ecfeac8b8f5a53129"><code>2007b3126c2e8b6bb8ff607ecfeac8b8f5a53129</code></a> | March 25, 2026 | <code>src/multiproof/AggregateVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/e86119a9a748696564ff3f49b8425a7084d0a862"><code>e86119a9a748696564ff3f49b8425a7084d0a862</code></a> | March 25, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/eb82db789553e32566b6653ece48508c3ef5a2ea"><code>eb82db789553e32566b6653ece48508c3ef5a2ea</code></a> | March 25, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |

## Coinbase: Nitro Enclave TEE Security Review

- Report: [2026_03-Nitro_Enclave_TEE-Cantina.md](<reports/2026_03-Nitro_Enclave_TEE-Cantina.md>)
- Auditor: Cantina
- Date: 2026-03-30
- Description: Cantina Managed review of Base&#x27;s multiproof TEE contracts (NitroEnclaveVerifier, TEEProverRegistry, TEEVerifier) in base/contracts, conducted March 19-23, 2026. It covers AWS Nitro Enclave attestation verification, TEE signer registration and TEE proof verification, with fix review of the reported issues.

### Repository: <a href="https://github.com/base/contracts"><code>base/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/contracts/commit/2421afdd332a98e9b45c6caf0a2e26b896b17e0d"><code>2421afdd332a98e9b45c6caf0a2e26b896b17e0d</code></a> | March 17, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code><br><code>src/multiproof/tee/TEEProverRegistry.sol</code><br><code>src/multiproof/tee/TEEVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/7ee57f61f2e4d7866a337e3e897d6eea1587a6d8"><code>7ee57f61f2e4d7866a337e3e897d6eea1587a6d8</code></a> | March 25, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/567a3a06f3454b801d4e4ad5d47ce7bcff699429"><code>567a3a06f3454b801d4e4ad5d47ce7bcff699429</code></a> | March 25, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/4719a373330c45c5cc9ad458f876c11f963ddea9"><code>4719a373330c45c5cc9ad458f876c11f963ddea9</code></a> | March 25, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/37edf9219d7c18dd1df9fa4a8c17dc6f08048636"><code>37edf9219d7c18dd1df9fa4a8c17dc6f08048636</code></a> | March 25, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/a94f57ac648e546fc3ce03789f541975817066f4"><code>a94f57ac648e546fc3ce03789f541975817066f4</code></a> | March 25, 2026 | <code>src/multiproof/tee/TEEProverRegistry.sol</code><br><code>src/multiproof/tee/TEEVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/f88f8d0e7aa7ddb8629464d19ed6d72ec8345d3e"><code>f88f8d0e7aa7ddb8629464d19ed6d72ec8345d3e</code></a> | March 25, 2026 | <code>src/multiproof/tee/TEEProverRegistry.sol</code> |
| <a href="https://github.com/base/contracts/commit/7acbf62ec2c0c5c167e747e885c069cf2dbf049a"><code>7acbf62ec2c0c5c167e747e885c069cf2dbf049a</code></a> | March 25, 2026 | <code>src/multiproof/tee/TEEProverRegistry.sol</code> |
| <a href="https://github.com/base/contracts/commit/365dc57bf2467fe13c939031f0a461c0f26c5348"><code>365dc57bf2467fe13c939031f0a461c0f26c5348</code></a> | March 26, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |

## Coinbase: AggregateVerifier Security Review

- Report: [2026_04-AggregateVerifier-Cantina.md](<reports/2026_04-AggregateVerifier-Cantina.md>)
- Auditor: Cantina
- Date: 2026-04-16
- Description: Cantina Managed review of the multiproof AggregateVerifier contract in base/contracts at commit ffe2af8c, conducted April 10-13, 2026. One informational documentation finding was reported and its fix verified.

### Repository: <a href="https://github.com/base/contracts"><code>base/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/contracts/commit/ffe2af8cbffefa44bbb1a3917507f8bd8ebec7a2"><code>ffe2af8cbffefa44bbb1a3917507f8bd8ebec7a2</code></a> | April 9, 2026 | <code>src/multiproof/AggregateVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/8e1fa6c4cef744edb1025440f7020e27d25519ab"><code>8e1fa6c4cef744edb1025440f7020e27d25519ab</code></a> | April 14, 2026 | <code>src/multiproof/AggregateVerifier.sol</code> |

## Coinbase NitroEnclaveVerifier Security Review

- Report: [2026_04-NitroEnclaveVerifier-Cantina.md](<reports/2026_04-NitroEnclaveVerifier-Cantina.md>)
- Auditor: Cantina
- Date: 2026-04-16
- Description: Cantina Managed review of the multiproof TEE NitroEnclaveVerifier contract in base/contracts at commit ffe2af8c, conducted from April 10, 2026. Five informational findings were reported, three fixed in PR 251 and two acknowledged.

### Repository: <a href="https://github.com/base/contracts"><code>base/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/contracts/commit/ffe2af8cbffefa44bbb1a3917507f8bd8ebec7a2"><code>ffe2af8cbffefa44bbb1a3917507f8bd8ebec7a2</code></a> | April 9, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/34a0a33f7ea45b7a7629442acb9bb37e1e8ef5ff"><code>34a0a33f7ea45b7a7629442acb9bb37e1e8ef5ff</code></a> | April 13, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/2726c7986dc610a310a389b26b81ed9134d5d524"><code>2726c7986dc610a310a389b26b81ed9134d5d524</code></a> | April 13, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/e0bc512193da3714f40611efb47e19ea4b38d43c"><code>e0bc512193da3714f40611efb47e19ea4b38d43c</code></a> | April 13, 2026 | <code>src/multiproof/tee/NitroEnclaveVerifier.sol</code> |

## Coinbase: Proof Contracts Update Security Review

- Report: [2026_06-Proof_Contracts_Update-Cantina.md](<reports/2026_06-Proof_Contracts_Update-Cantina.md>)
- Auditor: Cantina
- Date: 2026-06-10
- Description: Cantina Managed review of the L1 TEE proof contracts NitroEnclaveVerifier and TEEProverRegistry in base/contracts at commit e225648a, conducted June 3-4, 2026. One medium-severity finding on certificate revocation was reported and fixed in PR 329.

### Repository: <a href="https://github.com/base/contracts"><code>base/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/contracts/commit/e225648a7ed538e7e28c041d44f3b7a606ba7743"><code>e225648a7ed538e7e28c041d44f3b7a606ba7743</code></a> | June 2, 2026 | <code>src/L1/proofs/tee/NitroEnclaveVerifier.sol</code><br><code>src/L1/proofs/tee/TEEProverRegistry.sol</code> |
| <a href="https://github.com/base/contracts/commit/18f8939e8915b924608267453d71e1dee38d0edc"><code>18f8939e8915b924608267453d71e1dee38d0edc</code></a> | June 8, 2026 | <code>src/L1/proofs/tee/NitroEnclaveVerifier.sol</code> |

## Base Azul Audit Competition

- Report: [2026_07-Base_Azul-Immunefi.md](<reports/2026_07-Base_Azul-Immunefi.md>)
- Auditor: Immunefi
- Description: Immunefi index of the reports submitted in the Base Azul audit competition, covering Base&#x27;s smart contracts and ZK proof programs (Smart Contract category) as well as its node, consensus, batcher and proposer software (Blockchain/DLT category). The page lists report titles by severity only and names no repositories, paths or revisions, so no source coverage can be extracted.

## nitro-validator [05294ec0] Security Review

- Report: [2026_07-Nitro_Validator-Cantina.md](<reports/2026_07-Nitro_Validator-Cantina.md>)
- Auditor: Cantina
- Date: 2026-08-03
- Description: Cantina Managed review (July 15-24, 2026) of the base/nitro-validator AWS Nitro attestation verification contracts (NitroValidator, CertManager, ASN.1/CBOR decoders and P-384 verifier) at commit 05294ec0, focused on changes introduced by PRs 28 through 54. Fixes for the reported Medium, Low and Informational issues were verified in follow-up PRs 56-78.

### Repository: <a href="https://github.com/base/nitro-validator"><code>base/nitro-validator</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/nitro-validator/commit/05294ec098f7f38ef33b2d2470cfbbd08186b943"><code>05294ec098f7f38ef33b2d2470cfbbd08186b943</code></a> | July 7, 2026 | <code>src/NitroValidator.sol</code><br><code>src/CertManager.sol</code><br><code>src/ICertManager.sol</code><br><code>src/Asn1Decode.sol</code><br><code>src/CborDecode.sol</code><br><code>src/ECDSA384Curve.sol</code><br><code>src/IP384Verifier.sol</code><br><code>src/P384Verifier.sol</code><br><code>src/vendor/ECDSA384.sol</code><br><code>src/vendor/MemoryUtils.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/4083124dc04c8020ea16876b750d6fcbc72330d4"><code>4083124dc04c8020ea16876b750d6fcbc72330d4</code></a> | July 24, 2026 | <code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/02eaa7beca194fafcd0fe9394476fa7260266309"><code>02eaa7beca194fafcd0fe9394476fa7260266309</code></a> | July 24, 2026 | <code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/f8120158957072a2a96f386d91aa34749a48037f"><code>f8120158957072a2a96f386d91aa34749a48037f</code></a> | July 24, 2026 | <code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/988f5f56cb3a77d8e68477fb64143ea0ea372081"><code>988f5f56cb3a77d8e68477fb64143ea0ea372081</code></a> | July 24, 2026 | <code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/b893ee0d63375c486538faf58e0110f4d868dbf8"><code>b893ee0d63375c486538faf58e0110f4d868dbf8</code></a> | July 24, 2026 | <code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/6f3ea135539b33eb19bd42b53432f190969e741c"><code>6f3ea135539b33eb19bd42b53432f190969e741c</code></a> | July 24, 2026 | <code>src/CertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/41884e693873d2af0eb676794b243861452d2185"><code>41884e693873d2af0eb676794b243861452d2185</code></a> | July 24, 2026 | <code>src/vendor/ECDSA384.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/f020b6308a741806e2a07b8bba50ad921ba61b8e"><code>f020b6308a741806e2a07b8bba50ad921ba61b8e</code></a> | July 29, 2026 | <code>src/CertManager.sol</code><br><code>src/ICertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/beea09924af75564c6e6dd91fc4b4cf9cf5ed203"><code>beea09924af75564c6e6dd91fc4b4cf9cf5ed203</code></a> | July 30, 2026 | <code>src/CertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/c5c7298d04bf41ed4af1118d0b9bc628c2d5d8cd"><code>c5c7298d04bf41ed4af1118d0b9bc628c2d5d8cd</code></a> | July 30, 2026 | <code>src/CertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/d7e7cd77a473dfbf03306ae9dd5558e1b6e16a78"><code>d7e7cd77a473dfbf03306ae9dd5558e1b6e16a78</code></a> | July 30, 2026 | <code>src/CertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/889ef791c6cdbf5aa5353f73a8573d0522309cd0"><code>889ef791c6cdbf5aa5353f73a8573d0522309cd0</code></a> | July 30, 2026 | <code>src/CertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/7f3fcebfcff61a767d0fff34a009a0d738ea09b2"><code>7f3fcebfcff61a767d0fff34a009a0d738ea09b2</code></a> | July 30, 2026 | <code>src/CertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/4fb64d279abe3233d713683c091cfee0563a4939"><code>4fb64d279abe3233d713683c091cfee0563a4939</code></a> | July 30, 2026 | <code>src/Asn1Decode.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/228f461a8d5c8e94e48c701f8a4ee7cce0f81b6a"><code>228f461a8d5c8e94e48c701f8a4ee7cce0f81b6a</code></a> | July 30, 2026 | <code>src/Asn1Decode.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/a5468062012ec3a9409fb01a3caae16182ae6bec"><code>a5468062012ec3a9409fb01a3caae16182ae6bec</code></a> | July 31, 2026 | <code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/d5443c18e67258e0108b5a1e34c5e5b054f33604"><code>d5443c18e67258e0108b5a1e34c5e5b054f33604</code></a> | July 31, 2026 | <code>src/NitroValidator.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/926e574de773f88f0dab5f3890ef6e4e8dcdaadb"><code>926e574de773f88f0dab5f3890ef6e4e8dcdaadb</code></a> | July 31, 2026 | <code>src/CertManager.sol</code> |
| <a href="https://github.com/base/nitro-validator/commit/c17a2f192b5824eb4dd7aeea5da475d537527b4d"><code>c17a2f192b5824eb4dd7aeea5da475d537527b4d</code></a> | July 31, 2026 | <code>src/CertManager.sol</code> |

## Coinbase: base contracts Security Review (September 2026)

- Report: [2026_09-Cobalt_Contracts-Cantina.md](<reports/2026_09-Cobalt_Contracts-Cantina.md>)
- Auditor: Cantina
- Date: 2026-09-02
- Description: Cantina Managed review of the changes in base/contracts PRs #250, #378, #399 and #405: CREATE2 game deployment in DisputeGameFactory, removal of ETHLockbox from OptimismPortal2 ETH bridging, and onchain Nitro attestation validation in TEEProverRegistry. No issues were raised.

### Repository: <a href="https://github.com/base/contracts"><code>base/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/contracts/commit/180fa2c099b096ecb93e433709653236ac7c17af"><code>180fa2c099b096ecb93e433709653236ac7c17af</code></a> | June 2, 2026 | <code>src/L1/proofs/DisputeGameFactory.sol</code> |
| <a href="https://github.com/base/contracts/commit/63547f76fbbc23ca81e8eef80ad6486d339c73f7"><code>63547f76fbbc23ca81e8eef80ad6486d339c73f7</code></a> | July 20, 2026 | <code>src/L1/OptimismPortal2.sol</code><br><code>src/L1/SystemConfig.sol</code><br><code>src/libraries/Features.sol</code> |
| <a href="https://github.com/base/contracts/commit/f9a515350c91e2915088b2fb5ef41ff2b32dad01"><code>f9a515350c91e2915088b2fb5ef41ff2b32dad01</code></a> | August 12, 2026 | <code>src/L1/proofs/tee/TEEProverRegistry.sol</code> |
| <a href="https://github.com/base/contracts/commit/5b64d918a5943e670e406f64e500507066576313"><code>5b64d918a5943e670e406f64e500507066576313</code></a> | August 18, 2026 | <code>src/L1/proofs/tee/TEEProverRegistry.sol</code> |

## Coinbase: Contracts Dynamic Upgrades Security Review (September 2026)

- Report: [2026_09-Dynamic_Upgrades-Cantina.md](<reports/2026_09-Dynamic_Upgrades-Cantina.md>)
- Auditor: Cantina
- Date: 2026-09-19
- Description: Cantina Managed review of the dynamic upgrade scheduling in base/contracts: the ProtocolVersions upgrade schedule registry and its schedule-id pinning in AggregateVerifier. Initial review at commit 4f7acda5 with fix verification of the reported issues via follow-up PRs.

### Repository: <a href="https://github.com/base/contracts"><code>base/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/base/contracts/commit/4f7acda51dba4165361b292ae08c119f5bfa1f0d"><code>4f7acda51dba4165361b292ae08c119f5bfa1f0d</code></a> | August 20, 2026 | <code>src/L1/ProtocolVersions.sol</code><br><code>src/L1/proofs/AggregateVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/1ad3bf22a7c67df143b5b9697e9c5de8f7d705af"><code>1ad3bf22a7c67df143b5b9697e9c5de8f7d705af</code></a> | August 24, 2026 | <code>src/L1/ProtocolVersions.sol</code> |
| <a href="https://github.com/base/contracts/commit/794d2198e2a9caac0592c0d67079676b73f321e6"><code>794d2198e2a9caac0592c0d67079676b73f321e6</code></a> | August 24, 2026 | <code>src/L1/ProtocolVersions.sol</code> |
| <a href="https://github.com/base/contracts/commit/c3f30fb234c82694ab524808a3da709be6cad3d7"><code>c3f30fb234c82694ab524808a3da709be6cad3d7</code></a> | August 24, 2026 | <code>src/L1/ProtocolVersions.sol</code> |
| <a href="https://github.com/base/contracts/commit/bb0e64b8c194f71b711302433aad1c4a09e66b8d"><code>bb0e64b8c194f71b711302433aad1c4a09e66b8d</code></a> | August 24, 2026 | <code>src/L1/proofs/AggregateVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/1901048ff08f344b8371cf7f20a43f28896b3c48"><code>1901048ff08f344b8371cf7f20a43f28896b3c48</code></a> | August 24, 2026 | <code>src/L1/proofs/AggregateVerifier.sol</code> |
| <a href="https://github.com/base/contracts/commit/620122010f3344cb61bfcb249cdeebb8138d29bf"><code>620122010f3344cb61bfcb249cdeebb8138d29bf</code></a> | August 25, 2026 | <code>src/L1/ProtocolVersions.sol</code> |
| <a href="https://github.com/base/contracts/commit/1237b5fdba49f16f6a40129c8b0713e85c943bf2"><code>1237b5fdba49f16f6a40129c8b0713e85c943bf2</code></a> | August 26, 2026 | <code>src/L1/ProtocolVersions.sol</code> |
| <a href="https://github.com/base/contracts/commit/f7d447e2fe146a095677a123cbf8763c6e9c9546"><code>f7d447e2fe146a095677a123cbf8763c6e9c9546</code></a> | August 27, 2026 | <code>src/L1/ProtocolVersions.sol</code> |
| <a href="https://github.com/base/contracts/commit/6f078c3b6ce51773c8fe1584b22b7c295cbbbdb8"><code>6f078c3b6ce51773c8fe1584b22b7c295cbbbdb8</code></a> | September 11, 2026 | <code>src/L1/ProtocolVersions.sol</code> |

## Irrelevant reports

### Solidity Review of secp256r1

- Report: [irrelevant/2024_03-FreshCryptoLib_secp256r1_ECDSA_Review-Coinbase.md](<reports/irrelevant/2024_03-FreshCryptoLib_secp256r1_ECDSA_Review-Coinbase.md>)
- Auditor: Coinbase
- Date: 2024-02-06
- Description: Coinbase cryptography team review of the FreshCryptoLib secp256r1 ECDSA verification paper and its Solidity implementation (FCL.sol). The scope is limited to an external cryptographic dependency.

### secp256r1 review – test plan

- Report: [irrelevant/2024_03-FreshCryptoLib_secp256r1_ECDSA_Testing_Plan-Coinbase.md](<reports/irrelevant/2024_03-FreshCryptoLib_secp256r1_ECDSA_Testing_Plan-Coinbase.md>)
- Auditor: Coinbase
- Date: 2024-02-14
- Description: Coinbase test plan for validating the FreshCryptoLib secp256r1 ECDSA Solidity implementation (FCL.sol) against the reviewed paper. The scope is limited to an external cryptographic dependency.

### Coinbase: Base Precompile Macros &amp; Storage Security Review

- Report: [irrelevant/2026_06-Base_Precompile_Macros_Storage-Cantina.md](<reports/irrelevant/2026_06-Base_Precompile_Macros_Storage-Cantina.md>)
- Auditor: Cantina
- Date: 2026-08-14
- Description: Cantina review of the Rust precompile macro and storage framework in the base/base node repository at commit 6ee3da63. The scope is limited to node software (execution client precompile implementation).

### Coinbase: Precompiles Src Security Review

- Report: [irrelevant/2026_06-Precompiles_Src-Cantina.md](<reports/irrelevant/2026_06-Precompiles_Src-Cantina.md>)
- Auditor: Cantina
- Date: 2026-08-14
- Description: Cantina review of the Rust precompile sources (crypto, B20 factory, policy registry and activation precompiles) in the base/base node repository at commit 6ee3da63. The scope is limited to node software (execution client precompile implementation).
