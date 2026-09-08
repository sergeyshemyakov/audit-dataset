# Audit source summary: Solady

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Solady: Tokens &amp; Utils Selection

- Report: [solady__audits__ackee-blockchain-solady-report.md](<reports/solady__audits__ackee-blockchain-solady-report.md>)
- Auditor: Ackee Blockchain
- Date: 2023-06-02
- Description: Security review by Ackee Blockchain, funded by RockawayX, of a selection of Solady token contracts (ERC20, ERC721, ERC1155) and utility libraries (SafeTransferLib, ERC1967Factory, SignatureCheckerLib, MerkleProofLib, EIP712) using manual review and differential fuzzing. Revision 1.1 is a fix review of the reported findings.

### Repository: <a href="https://github.com/Vectorized/solady"><code>solady</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Vectorized/solady/commit/e158762ba98db40a06411db7f80a54b93e951818"><code>e158762ba98db40a06411db7f80a54b93e951818</code></a> | May 19, 2023 | <code>src/tokens/ERC20.sol</code><br><code>src/tokens/ERC721.sol</code><br><code>src/tokens/ERC1155.sol</code><br><code>src/utils/SafeTransferLib.sol</code><br><code>src/utils/ERC1967Factory.sol</code><br><code>src/utils/SignatureCheckerLib.sol</code><br><code>src/utils/MerkleProofLib.sol</code><br><code>src/utils/EIP712.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/37a79cebb0f12472cc339a726d6f385ec534d056"><code>37a79cebb0f12472cc339a726d6f385ec534d056</code></a> | May 30, 2023 | <code>src/tokens/ERC20.sol</code><br><code>src/tokens/ERC721.sol</code><br><code>src/tokens/ERC1155.sol</code><br><code>src/utils/SafeTransferLib.sol</code><br><code>src/utils/SignatureCheckerLib.sol</code><br><code>src/utils/MerkleProofLib.sol</code><br><code>src/utils/EIP712.sol</code> |

## Solady ERC721 Security Review

- Report: [solady__audits__shung-solady-erc721-audit.md](<reports/solady__audits__shung-solady-erc721-audit.md>)
- Auditor: shung (OpenSense Solwaifu initiative)
- Date: 2023-07-08
- Description: Independent security review of the Solady ERC721 token contract by shung as part of the OpenSense Operation Solwaifu community audit initiative, covering the custom storage layout, manual memory operations, and inline assembly. No significant issues were found; the reported Low and Informational items were addressed with documentation.

### Repository: <a href="https://github.com/Vectorized/solady"><code>solady</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Vectorized/solady/commit/7175c21f95255dc7711ce84cc32080a41864abd6"><code>7175c21f95255dc7711ce84cc32080a41864abd6</code></a> | June 22, 2023 | <code>src/tokens/ERC721.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/e8d36d039bbf2c8742bc7d463131ed381c2e867b"><code>e8d36d039bbf2c8742bc7d463131ed381c2e867b</code></a> | July 8, 2023 | <code>src/tokens/ERC721.sol</code> |

## Solady Security Review (Cantina Public Goods)

- Report: [solady__audits__cantina-solady-report.md](<reports/solady__audits__cantina-solady-report.md>)
- Auditor: Cantina
- Date: 2023-09-14
- Description: Crowdfunded Cantina public goods security review of Solady targeting ERC1967Factory, ERC20, ERC721, ERC1155, LibClone, MerkleProofLib, SignatureCheckerLib and ECDSA. Fixes were applied in follow-up pull requests and confirmed by the reviewers.

### Repository: <a href="https://github.com/Vectorized/solady"><code>solady</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Vectorized/solady/commit/89101d53b7c8784cca935c1f2f6403639cee48b2"><code>89101d53b7c8784cca935c1f2f6403639cee48b2</code></a> | August 5, 2023 | <code>src/utils/ERC1967Factory.sol</code><br><code>src/tokens/ERC20.sol</code><br><code>src/tokens/ERC721.sol</code><br><code>src/tokens/ERC1155.sol</code><br><code>src/utils/LibClone.sol</code><br><code>src/utils/MerkleProofLib.sol</code><br><code>src/utils/SignatureCheckerLib.sol</code><br><code>src/utils/ECDSA.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/22385ac7b31c27f95b25ee73b3618251386d8fd2"><code>22385ac7b31c27f95b25ee73b3618251386d8fd2</code></a> | August 9, 2023 | <code>src/utils/SignatureCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/7a0613faa362c4bd072779fe9725a7e4f8c45a83"><code>7a0613faa362c4bd072779fe9725a7e4f8c45a83</code></a> | August 9, 2023 | <code>src/utils/ECDSA.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/c97ba5887c4eeab6c23db803a6f15a5125a27f2d"><code>c97ba5887c4eeab6c23db803a6f15a5125a27f2d</code></a> | September 10, 2023 | <code>src/utils/ERC1967Factory.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/83e4650283a477bb9b5fd04e982e7f9d1bf76fdc"><code>83e4650283a477bb9b5fd04e982e7f9d1bf76fdc</code></a> | September 10, 2023 | <code>src/tokens/ERC20.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/7b5e4316240fdbe0c45df8e66a3c2f4639c22a8a"><code>7b5e4316240fdbe0c45df8e66a3c2f4639c22a8a</code></a> | September 10, 2023 | <code>src/tokens/ERC721.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/9ac02f7c4d39036419281b639154ee7908edf136"><code>9ac02f7c4d39036419281b639154ee7908edf136</code></a> | September 10, 2023 | <code>src/tokens/ERC1155.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/1f023f7a8d61d82c002d19feeb530a87ec84c97c"><code>1f023f7a8d61d82c002d19feeb530a87ec84c97c</code></a> | September 10, 2023 | <code>src/utils/LibClone.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/3598aa3e280c36f607e35d5b2ccd601ae7bafc55"><code>3598aa3e280c36f607e35d5b2ccd601ae7bafc55</code></a> | September 10, 2023 | <code>src/utils/MerkleProofLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/fb7ede6ab5667929e48d08ca20d4551cce49a556"><code>fb7ede6ab5667929e48d08ca20d4551cce49a556</code></a> | September 10, 2023 | <code>src/utils/SignatureCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/96af34cd3dca7ac3b9d337939dcfe61c88f7c24c"><code>96af34cd3dca7ac3b9d337939dcfe61c88f7c24c</code></a> | September 10, 2023 | <code>src/utils/ECDSA.sol</code> |

## Solady cbrt &amp; cbrtWad Audit Report

- Report: [cbrt-proof__audits__xuwinnie-solady-cbrt-proof.md](<reports/cbrt-proof__audits__xuwinnie-solady-cbrt-proof.md>)
- Auditor: xuwinnie
- Date: 2024-07-31
- Description: Mathematical correctness proof by xuwinnie of the cbrt and cbrtWad functions in FixedPointMathLib, showing that the initial guess and iterative refinement return the exact integer cube root. No findings are reported.

### Repository: <a href="https://github.com/Vectorized/solady"><code>solady</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Vectorized/solady/commit/43f9d49815c8126d92771b26bd9bdbe2dbea87a5"><code>43f9d49815c8126d92771b26bd9bdbe2dbea87a5</code></a> | August 1, 2024 | <code>src/utils/FixedPointMathLib.sol</code> |

## Coinbase Solady Security Review

- Report: [solady__audits__cantina-spearbit-coinbase-solady-report.md](<reports/solady__audits__cantina-spearbit-coinbase-solady-report.md>)
- Auditor: Spearbit (via Cantina)
- Date: 2025-01-22
- Description: Spearbit security review of the Solady library commissioned by Coinbase, conducted over 40 days on a single repository commit and reporting 55 issues across the accounts, tokens and utils modules. Fixes were applied in follow-up pull requests and verified by Spearbit.

### Repository: <a href="https://github.com/Vectorized/solady"><code>solady</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Vectorized/solady/commit/4c895b961d45c53a49ed500cfc76868b7ee1328b"><code>4c895b961d45c53a49ed500cfc76868b7ee1328b</code></a> | December 2, 2024 | <code>src/accounts/ERC4337.sol</code><br><code>src/accounts/ERC4337Factory.sol</code><br><code>src/accounts/ERC7821.sol</code><br><code>src/accounts/LibERC7579.sol</code><br><code>src/accounts/Receiver.sol</code><br><code>src/accounts/Timelock.sol</code><br><code>src/auth/EnumerableRoles.sol</code><br><code>src/tokens/ERC1155.sol</code><br><code>src/tokens/ERC20.sol</code><br><code>src/tokens/ERC20Votes.sol</code><br><code>src/tokens/ERC721.sol</code><br><code>src/utils/DynamicArrayLib.sol</code><br><code>src/utils/EIP712.sol</code><br><code>src/utils/EnumerableSetLib.sol</code><br><code>src/utils/Initializable.sol</code><br><code>src/utils/LibClone.sol</code><br><code>src/utils/LibTransient.sol</code><br><code>src/utils/Lifebuoy.sol</code><br><code>src/utils/MinHeapLib.sol</code><br><code>src/utils/Multicallable.sol</code><br><code>src/utils/P256.sol</code><br><code>src/utils/RedBlackTreeLib.sol</code><br><code>src/utils/SafeTransferLib.sol</code><br><code>src/utils/SignatureCheckerLib.sol</code><br><code>src/utils/UUPSUpgradeable.sol</code><br><code>src/utils/WebAuthn.sol</code><br><code>src/utils/ext/delegatexyz/DelegateCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/cca555c569588b7244bfffcb99b3e4d093fd80aa"><code>cca555c569588b7244bfffcb99b3e4d093fd80aa</code></a> | December 9, 2024 | <code>src/utils/SignatureCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/8451becd826a92a63cd702ea68d04b0ef19ea624"><code>8451becd826a92a63cd702ea68d04b0ef19ea624</code></a> | December 9, 2024 | <code>src/utils/WebAuthn.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/66bf970c10aa529402620d3e6a2de12138e84558"><code>66bf970c10aa529402620d3e6a2de12138e84558</code></a> | December 11, 2024 | <code>src/utils/Lifebuoy.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/2781e800f8f7f723618c2a6ce279292eef23a827"><code>2781e800f8f7f723618c2a6ce279292eef23a827</code></a> | December 17, 2024 | <code>src/accounts/ERC4337.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/55e4501c920ce9068513e573429e1f8e3ab3849e"><code>55e4501c920ce9068513e573429e1f8e3ab3849e</code></a> | December 17, 2024 | <code>src/accounts/Timelock.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/3dedb8fc8c4e9b96ff11caba9ae72c2d2aea488c"><code>3dedb8fc8c4e9b96ff11caba9ae72c2d2aea488c</code></a> | December 17, 2024 | <code>src/utils/DynamicArrayLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/e11b6f31fe853dc56d43557fd167cfba5b51d3fb"><code>e11b6f31fe853dc56d43557fd167cfba5b51d3fb</code></a> | December 17, 2024 | <code>src/tokens/ERC1155.sol</code><br><code>src/utils/LibTransient.sol</code><br><code>src/utils/Lifebuoy.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/21b9371d592e61ca8d5af3cd1a0186eaf4de1989"><code>21b9371d592e61ca8d5af3cd1a0186eaf4de1989</code></a> | December 18, 2024 | <code>src/accounts/LibERC7579.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/580419f2b8513323f79a44e62cf85092f581ecca"><code>580419f2b8513323f79a44e62cf85092f581ecca</code></a> | December 18, 2024 | <code>src/accounts/LibERC7579.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/c1f772792fff569a0e69a6ceedfc48abf49b04ea"><code>c1f772792fff569a0e69a6ceedfc48abf49b04ea</code></a> | December 19, 2024 | <code>src/tokens/ERC721.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/22bcb1df823b329eb15eef7871d63042dd246489"><code>22bcb1df823b329eb15eef7871d63042dd246489</code></a> | December 30, 2024 | <code>src/utils/Initializable.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/f9ae9781a6b19c918c1acb190b0516684af0d6c7"><code>f9ae9781a6b19c918c1acb190b0516684af0d6c7</code></a> | January 4, 2025 | <code>src/utils/SignatureCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/835b0a27bec99d889cee6dec97b395d3df0e1d11"><code>835b0a27bec99d889cee6dec97b395d3df0e1d11</code></a> | January 9, 2025 | <code>src/utils/SignatureCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/d323836cf9029659619122010c74f242ffca4b7b"><code>d323836cf9029659619122010c74f242ffca4b7b</code></a> | January 10, 2025 | <code>src/utils/LibTransient.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/e4ba18e26bca7390a1bb709db15be4cee4143eaf"><code>e4ba18e26bca7390a1bb709db15be4cee4143eaf</code></a> | January 10, 2025 | <code>src/utils/P256.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/17cba0487dd4e8781153bbbaf7a48cc3bcdc67a2"><code>17cba0487dd4e8781153bbbaf7a48cc3bcdc67a2</code></a> | January 10, 2025 | <code>src/utils/SignatureCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/c48bd20f26e57efdbaf8925389d3e392555e2020"><code>c48bd20f26e57efdbaf8925389d3e392555e2020</code></a> | January 10, 2025 | <code>src/utils/SignatureCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/90bc5366025c12497dd02a02a067a2fdee515e20"><code>90bc5366025c12497dd02a02a067a2fdee515e20</code></a> | January 13, 2025 | <code>src/accounts/ERC4337Factory.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/e3ebb452c4d5854c51bc0e44be416cba9ff6c6ed"><code>e3ebb452c4d5854c51bc0e44be416cba9ff6c6ed</code></a> | January 13, 2025 | <code>src/accounts/ERC7821.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/159696cbc2341b20c9d1063f942bd450b1f82b2a"><code>159696cbc2341b20c9d1063f942bd450b1f82b2a</code></a> | January 13, 2025 | <code>src/accounts/ERC7821.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/23df112333dc707fab92557a12c2e377d3e53ae4"><code>23df112333dc707fab92557a12c2e377d3e53ae4</code></a> | January 13, 2025 | <code>src/accounts/LibERC7579.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/175e4e71a7622836a127377dec0b28c92fb4789a"><code>175e4e71a7622836a127377dec0b28c92fb4789a</code></a> | January 13, 2025 | <code>src/accounts/Receiver.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/12f35e0e06352c3ef2f4be2e4e73513673151b6f"><code>12f35e0e06352c3ef2f4be2e4e73513673151b6f</code></a> | January 13, 2025 | <code>src/accounts/Timelock.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/120a9cdcaf3d944d4f396502ef8ab370ba3eba4c"><code>120a9cdcaf3d944d4f396502ef8ab370ba3eba4c</code></a> | January 13, 2025 | <code>src/tokens/ERC20Votes.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/ae1332ebdec5870b25451c5ce91c05a35c58af4d"><code>ae1332ebdec5870b25451c5ce91c05a35c58af4d</code></a> | January 13, 2025 | <code>src/utils/EnumerableSetLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/eb36cf4817e8dd81349895f1ed5c922299343ffc"><code>eb36cf4817e8dd81349895f1ed5c922299343ffc</code></a> | January 13, 2025 | <code>src/utils/EnumerableSetLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/8a08a70b2e116fae44e09e1d650b2f27b009cfd3"><code>8a08a70b2e116fae44e09e1d650b2f27b009cfd3</code></a> | January 13, 2025 | <code>src/utils/Initializable.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/75727e9fa861fe7313c1fb0e5fba76c87d501b3e"><code>75727e9fa861fe7313c1fb0e5fba76c87d501b3e</code></a> | January 13, 2025 | <code>src/utils/LibClone.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/b14e130bd5210a9273f7d49a872fe683c69d6a80"><code>b14e130bd5210a9273f7d49a872fe683c69d6a80</code></a> | January 13, 2025 | <code>src/utils/MinHeapLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/a00a06951f5f7c9765fb018663b3414c33909a25"><code>a00a06951f5f7c9765fb018663b3414c33909a25</code></a> | January 13, 2025 | <code>src/utils/Multicallable.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/582e0cc30970720f5cd8c8e7669e4ffa82c9ec43"><code>582e0cc30970720f5cd8c8e7669e4ffa82c9ec43</code></a> | January 13, 2025 | <code>src/utils/RedBlackTreeLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/c77954196f602ebd68161e01b6ba376874b019c6"><code>c77954196f602ebd68161e01b6ba376874b019c6</code></a> | January 13, 2025 | <code>src/utils/SignatureCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/2442629add9689ddef2076e96cf190dcabb94d87"><code>2442629add9689ddef2076e96cf190dcabb94d87</code></a> | January 13, 2025 | <code>src/utils/UUPSUpgradeable.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/131f6118068ab638dacebea9ec44d59b7e0f2c42"><code>131f6118068ab638dacebea9ec44d59b7e0f2c42</code></a> | January 13, 2025 | <code>src/utils/UUPSUpgradeable.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/b8380d6b1e3ba4af190f50545bdf7c0d14008188"><code>b8380d6b1e3ba4af190f50545bdf7c0d14008188</code></a> | January 14, 2025 | <code>src/accounts/ERC4337.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/494a6cbe4eb077b1332bcc2c17b7a8ad5b3e082f"><code>494a6cbe4eb077b1332bcc2c17b7a8ad5b3e082f</code></a> | January 14, 2025 | <code>src/utils/P256.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/5da5bd872349f97ac9b197fd9402da2e8f2c98b2"><code>5da5bd872349f97ac9b197fd9402da2e8f2c98b2</code></a> | January 14, 2025 | <code>src/utils/SafeTransferLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/19009cfa459b9cde0665c6fb017de8fd702ed2c8"><code>19009cfa459b9cde0665c6fb017de8fd702ed2c8</code></a> | January 14, 2025 | <code>src/utils/ext/delegatexyz/DelegateCheckerLib.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/96a374d388ee17aa007867e196d547d19c2e8bb7"><code>96a374d388ee17aa007867e196d547d19c2e8bb7</code></a> | January 15, 2025 | <code>src/accounts/Timelock.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/d4f6dbcefe3ddce628c7404c2ac8145609071a75"><code>d4f6dbcefe3ddce628c7404c2ac8145609071a75</code></a> | January 15, 2025 | <code>src/utils/LibClone.sol</code> |
| <a href="https://github.com/Vectorized/solady/commit/d3488dcd0826479d7872b518286ae09bd8cefae6"><code>d3488dcd0826479d7872b518286ae09bd8cefae6</code></a> | January 17, 2025 | <code>src/tokens/ERC20Votes.sol</code> |
