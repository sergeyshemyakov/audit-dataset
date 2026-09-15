# Audit source summary: Safe

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Gnosis Safe Audit Report

- Report: [safe-core__docs__Gnosis_Safe_Audit_Report.md](<reports/safe-core__docs__Gnosis_Safe_Audit_Report.md>)
- Auditor: Alexey Akhunov
- Description: Reviews the original Gnosis Safe contracts and a substantially refactored second iteration, covering wallet execution, proxies, extensions, and libraries.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/b1a80f23b99c4983229dbb678c9f77895c9d2b70"><code>b1a80f23b99c4983229dbb678c9f77895c9d2b70</code></a> | January 28, 2018 | <code>contracts/</code> (recursive directory)<br><code>contracts/libraries/MultiSendStruct.sol</code> (explicitly not audited) |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/942968d66a4fa200fe9757d02b377dbfc3c88636"><code>942968d66a4fa200fe9757d02b377dbfc3c88636</code></a> | June 14, 2018 | <code>contracts/</code> (recursive directory) |

## Security Review of Gnosis Safe v1.1.0

- Report: [safe-core__docs__Gnosis_Safe_Audit_Report_1_1_0.md](<reports/safe-core__docs__Gnosis_Safe_Audit_Report_1_1_0.md>)
- Auditor: G0 Group
- Date: 2019-11-11
- Description: Reviews the listed Gnosis Safe core, module, handler, library, and proxy contracts and follows their remediation into v1.1.0.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/1a9e5ce768e134c556770ea50e114fd83666b8a8"><code>1a9e5ce768e134c556770ea50e114fd83666b8a8</code></a> | September 2, 2019 | <code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/Module.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/MasterCopy.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/libraries/CreateAndAddModules.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/modules/DailyLimitModule.sol</code><br><code>contracts/modules/SocialRecoveryModule.sol</code><br><code>contracts/modules/StateChannelModule.sol</code><br><code>contracts/modules/WhitelistModule.sol</code><br><code>contracts/proxies/DelegateConstructorProxy.sol</code><br><code>contracts/proxies/PayingProxy.sol</code><br><code>contracts/proxies/Proxy.sol</code><br><code>contracts/proxies/ProxyFactory.sol</code><br><code>contracts/GnosisSafe.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/78494bcdbc61b3db52308a25f0556c42cf656ab1"><code>78494bcdbc61b3db52308a25f0556c42cf656ab1</code></a> | November 11, 2019 | <code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/Module.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/MasterCopy.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/libraries/CreateAndAddModules.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/modules/DailyLimitModule.sol</code><br><code>contracts/modules/SocialRecoveryModule.sol</code><br><code>contracts/modules/StateChannelModule.sol</code><br><code>contracts/modules/WhitelistModule.sol</code><br><code>contracts/proxies/DelegateConstructorProxy.sol</code><br><code>contracts/proxies/PayingProxy.sol</code><br><code>contracts/proxies/Proxy.sol</code><br><code>contracts/proxies/ProxyFactory.sol</code><br><code>contracts/GnosisSafe.sol</code> |

## Security Review of Gnosis Safe v1.1.0 and v1.1.1

- Report: [safe-core__docs__Gnosis_Safe_Audit_Report_1_1_1.md](<reports/safe-core__docs__Gnosis_Safe_Audit_Report_1_1_1.md>)
- Auditor: G0 Group
- Date: 2019-11-11
- Description: Reviews the listed Safe contracts across the original, v1.1.0, and v1.1.1 revisions, including the additional v1.1.1 appendix checks.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/1a9e5ce768e134c556770ea50e114fd83666b8a8"><code>1a9e5ce768e134c556770ea50e114fd83666b8a8</code></a> | September 2, 2019 | <code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/Module.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/MasterCopy.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/libraries/CreateAndAddModules.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/modules/DailyLimitModule.sol</code><br><code>contracts/modules/SocialRecoveryModule.sol</code><br><code>contracts/modules/StateChannelModule.sol</code><br><code>contracts/modules/WhitelistModule.sol</code><br><code>contracts/proxies/DelegateConstructorProxy.sol</code><br><code>contracts/proxies/PayingProxy.sol</code><br><code>contracts/proxies/Proxy.sol</code><br><code>contracts/proxies/ProxyFactory.sol</code><br><code>contracts/GnosisSafe.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/78494bcdbc61b3db52308a25f0556c42cf656ab1"><code>78494bcdbc61b3db52308a25f0556c42cf656ab1</code></a> | November 11, 2019 | <code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/Module.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/MasterCopy.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/libraries/CreateAndAddModules.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/modules/DailyLimitModule.sol</code><br><code>contracts/modules/SocialRecoveryModule.sol</code><br><code>contracts/modules/StateChannelModule.sol</code><br><code>contracts/modules/WhitelistModule.sol</code><br><code>contracts/proxies/DelegateConstructorProxy.sol</code><br><code>contracts/proxies/PayingProxy.sol</code><br><code>contracts/proxies/Proxy.sol</code><br><code>contracts/proxies/ProxyFactory.sol</code><br><code>contracts/GnosisSafe.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/2df0b2e0ad5d0f7ab5423e7f5baa72b2456d32ae"><code>2df0b2e0ad5d0f7ab5423e7f5baa72b2456d32ae</code></a> | December 9, 2019 | <code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/Module.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/MasterCopy.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/libraries/CreateAndAddModules.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/modules/DailyLimitModule.sol</code><br><code>contracts/modules/SocialRecoveryModule.sol</code><br><code>contracts/modules/StateChannelModule.sol</code><br><code>contracts/modules/WhitelistModule.sol</code><br><code>contracts/proxies/DelegateConstructorProxy.sol</code><br><code>contracts/proxies/PayingProxy.sol</code><br><code>contracts/proxies/Proxy.sol</code><br><code>contracts/proxies/ProxyFactory.sol</code><br><code>contracts/GnosisSafe.sol</code> |

## Gnosis Safe Gas Validation Adjustment

- Report: [safe-core__docs__Gnosis_Safe_Audit_Report_1_2_0.md](<reports/safe-core__docs__Gnosis_Safe_Audit_Report_1_2_0.md>)
- Auditor: G0 Group
- Date: 2020-05-04
- Description: Reviews the EIP-150 gas-validation adjustment in GnosisSafe and ModuleManager and verifies its correction.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/271921f4b37613b3d49bf33452dbcd81be219247"><code>271921f4b37613b3d49bf33452dbcd81be219247</code></a> | April 24, 2020 | <code>contracts/GnosisSafe.sol</code><br><code>contracts/base/ModuleManager.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/62d4bd39925db65083b035115d6987772b2d2dca"><code>62d4bd39925db65083b035115d6987772b2d2dca</code></a> | May 4, 2020 | <code>contracts/GnosisSafe.sol</code><br><code>contracts/base/ModuleManager.sol</code> |

## Security Review of Gnosis Safe 1.3.0 (Initial)

- Report: [safe-core__docs__Gnosis_Safe_Audit_Report_1_3_0_Initial.md](<reports/safe-core__docs__Gnosis_Safe_Audit_Report_1_3_0_Initial.md>)
- Auditor: G0 Group
- Date: 2021-04-01
- Description: Reviews all Solidity sources for the initial Safe 1.3.0 candidate and records follow-up changes implementing two optimization notes.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/4bfc0c8519f1893015d7edfd2c2780fca163c364"><code>4bfc0c8519f1893015d7edfd2c2780fca163c364</code></a> | March 29, 2021 | <code>contracts/</code> (recursive directory) |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/9b305a0f80da7f1107d1181f52c844f089557d05"><code>9b305a0f80da7f1107d1181f52c844f089557d05</code></a> | April 12, 2021 | <code>contracts/</code> (recursive directory) |

## Security Review of Gnosis Safe 1.3.0 (Final)

- Report: [safe-core__docs__Gnosis_Safe_Audit_Report_1_3_0_Final.md](<reports/safe-core__docs__Gnosis_Safe_Audit_Report_1_3_0_Final.md>)
- Auditor: G0 Group
- Date: 2021-05-01
- Description: Reviews all Solidity sources in the final Safe 1.3.0 audit revision.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/ad6c7355d5bdf4f7fa348fbfcb9f07431769a3c9"><code>ad6c7355d5bdf4f7fa348fbfcb9f07431769a3c9</code></a> | May 3, 2021 | <code>contracts/</code> (recursive directory) |

## Safe Smart Account v1.3.0 Security Assessment

- Report: [safe-core__docs__Safe_Audit_Report_1_3_0_Certora.md](<reports/safe-core__docs__Safe_Audit_Report_1_3_0_Certora.md>)
- Auditor: Certora
- Date: 2026-07-29
- Description: Manually reviews the full listed Safe v1.3.0 contract set and assesses known security-relevant behaviors, with a follow-up finding fix.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/767ef36bba88bdbc0c9fe3708a4290cabef4c376"><code>767ef36bba88bdbc0c9fe3708a4290cabef4c376</code></a> | November 17, 2021 | <code>contracts/GnosisSafe.sol</code><br><code>contracts/GnosisSafeL2.sol</code><br><code>contracts/accessors/SimulateTxAccessor.sol</code><br><code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/GuardManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/common/Singleton.sol</code><br><code>contracts/common/StorageAccessible.sol</code><br><code>contracts/external/GnosisSafeMath.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/handler/HandlerContext.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/IERC165.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/interfaces/ViewStorageAccessible.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/GnosisSafeStorage.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code><br><code>contracts/proxies/GnosisSafeProxy.sol</code><br><code>contracts/proxies/GnosisSafeProxyFactory.sol</code><br><code>contracts/proxies/IProxyCreationCallback.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/77901a5a1ad835b74ad3b72f73a8412cfe491c57"><code>77901a5a1ad835b74ad3b72f73a8412cfe491c57</code></a> | June 5, 2026 | <code>contracts/Safe.sol</code> |

## Safe Smart Account v1.3.0 Security Review

- Report: [safe-core__docs__Safe_Audit_Report_1_3_0_Nethermind.md](<reports/safe-core__docs__Safe_Audit_Report_1_3_0_Nethermind.md>)
- Auditor: Nethermind Security
- Date: 2026-08-17
- Description: Reviews the listed Safe v1.3.0 contracts and records remediation of the identified issues in the v1.4.0 release.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/767ef36bba88bdbc0c9fe3708a4290cabef4c376"><code>767ef36bba88bdbc0c9fe3708a4290cabef4c376</code></a> | November 17, 2021 | <code>contracts/GnosisSafe.sol</code><br><code>contracts/GnosisSafeL2.sol</code><br><code>contracts/accessors/SimulateTxAccessor.sol</code><br><code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/GuardManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/common/Singleton.sol</code><br><code>contracts/common/StorageAccessible.sol</code><br><code>contracts/external/GnosisSafeMath.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/handler/HandlerContext.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/GnosisSafeStorage.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code><br><code>contracts/proxies/GnosisSafeProxy.sol</code><br><code>contracts/proxies/GnosisSafeProxyFactory.sol</code><br><code>contracts/proxies/IProxyCreationCallback.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/tree/v1.4.0"><code>e870f514ad34cd9654c72174d6d4a839e3c6639f</code></a> (tag <code>v1.4.0</code>) | April 26, 2023 | <code>contracts/base/ModuleManager.sol</code><br><code>contracts/Safe.sol</code> |

## Safe Contracts 1.4.0 Security Review

- Report: [safe-core__docs__Safe_Audit_Report_1_4_0.md](<reports/safe-core__docs__Safe_Audit_Report_1_4_0.md>)
- Auditor: Ackee Blockchain
- Date: 2023-03-28
- Description: Reviews five Safe 1.4.0 entry-point contracts together with all of their recursively imported dependencies, followed by a remediation review.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/eb93dbb0f62e2dc1b308ac4c110038062df0a8c9"><code>eb93dbb0f62e2dc1b308ac4c110038062df0a8c9</code></a> | March 7, 2023 | <code>contracts/SafeL2.sol</code><br><code>contracts/proxies/SafeProxyFactory.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/cb4b2b19b3e336b8defd3b8c9e0e6a2ae130598c"><code>cb4b2b19b3e336b8defd3b8c9e0e6a2ae130598c</code></a> | March 28, 2023 | <code>contracts/SafeL2.sol</code><br><code>contracts/proxies/SafeProxyFactory.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code> |

## Safe Smart Account Security Review

- Report: [safe-core__docs__Safe_Audit_Report_1_5_0_Ackee.md](<reports/safe-core__docs__Safe_Audit_Report_1_5_0_Ackee.md>)
- Auditor: Ackee Blockchain Security
- Date: 2025-05-28
- Description: Reviews every Solidity file under the Safe smart-account contracts directory except examples and tests, then verifies implemented fixes.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/b115c4c5fe23dca6aefeeccc73d312ddd23322c2"><code>b115c4c5fe23dca6aefeeccc73d312ddd23322c2</code></a> | April 29, 2025 | <code>contracts/</code> (recursive directory)<br><code>contracts/examples/</code> (recursive directory) (explicitly not audited)<br><code>contracts/test/</code> (recursive directory) (explicitly not audited) |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/5d26505388e9ee014ad9ac497aa48e3a13426eb1"><code>5d26505388e9ee014ad9ac497aa48e3a13426eb1</code></a> | May 27, 2025 | <code>contracts/</code> (recursive directory) |

## Gnosis Safe Audit Results

- Report: [safe-early__docs__alexey_audit.md](<reports/safe-early__docs__alexey_audit.md>)
- Auditor: Alexey Akhunov
- Description: Identifies the source revision used by the attached Safe audit and the later revision checked with symbolic execution.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/942968d66a4fa200fe9757d02b377dbfc3c88636"><code>942968d66a4fa200fe9757d02b377dbfc3c88636</code></a> | June 14, 2018 | <code>contracts/</code> (recursive directory) |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/898cc8969736bc190db1b7c446e050f49177f898"><code>898cc8969736bc190db1b7c446e050f49177f898</code></a> | June 26, 2018 | <code>contracts/SecuredTokenTransfer.sol</code> |

## Formal Verification Report: GnosisSafe Contract

- Report: [safe-verification__docs__Gnosis_Safe_Formal_Verification_Report_1_0_0.md](<reports/safe-verification__docs__Gnosis_Safe_Formal_Verification_Report_1_0_0.md>)
- Auditor: Runtime Verification
- Date: 2019-02-27
- Description: Audits and formally verifies selected security-critical GnosisSafe, owner, module, master-copy, and signature-decoding behavior at the EVM bytecode level.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/427d6f7e779431333c54bcb4d4cde31e4d57ce96"><code>427d6f7e779431333c54bcb4d4cde31e4d57ce96</code></a> | November 25, 2018 | <code>contracts/GnosisSafe.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/common/MasterCopy.sol</code><br><code>contracts/common/SignatureDecoder.sol</code> |

## Safe Smart Account v1.5.0 Formal Verification and Audit

- Report: [safe-verification__docs__Safe_Audit_Report_1_5_0_Certora.md](<reports/safe-verification__docs__Safe_Audit_Report_1_5_0_Certora.md>)
- Auditor: Certora
- Date: 2025-01-14
- Description: Formally verifies and manually reviews the listed Safe v1.5.0 contracts, then checks the revision containing fixes.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/834e798aa51291cccaf0594921194928716e9892"><code>834e798aa51291cccaf0594921194928716e9892</code></a> | December 14, 2024 | <code>contracts/</code> (recursive directory) |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/1c8b24a0a438e8c2cd089a9d830d1688a47a28d5"><code>1c8b24a0a438e8c2cd089a9d830d1688a47a28d5</code></a> | January 23, 2025 | <code>contracts/</code> (recursive directory) |

## Safe Library Contracts Security Assessment and Formal Verification

- Report: [safe-core__docs__Safe_Library_Contracts_Audit_Report_1_4_1.md](<reports/safe-core__docs__Safe_Library_Contracts_Audit_Report_1_4_1.md>)
- Auditor: Certora
- Date: 2024-08-23
- Description: Manually reviews and formally verifies Safe migration and L2 setup library contracts, followed by a fix review.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/07d4fc7b298a69226bfdfd260bed7d92557cfd26"><code>07d4fc7b298a69226bfdfd260bed7d92557cfd26</code></a> | July 24, 2024 | <code>contracts/libraries/SafeMigration.sol</code><br><code>contracts/libraries/SafeToL2Setup.sol</code><br><code>contracts/libraries/SafeToL2Migration.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/b541cd7e5d745b223644024b930b19a2a3836d1e"><code>b541cd7e5d745b223644024b930b19a2a3836d1e</code></a> | August 28, 2024 | <code>contracts/libraries/SafeMigration.sol</code><br><code>contracts/libraries/SafeToL2Setup.sol</code><br><code>contracts/libraries/SafeToL2Migration.sol</code> |

## Safe ERC-4337 Module Audit

- Report: [safe-modules__modules__4337__docs__v0.1.0__audit-report-v1.1.md](<reports/safe-modules__modules__4337__docs__v0.1.0__audit-report-v1.1.md>)
- Auditor: Ackee Blockchain
- Date: 2023-11-08
- Description: Reviews the Safe ERC-4337 module and module-enabling library, then checks the initial remediation revision.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/53211cc3dc12a0f5ffadb2bdce9089403fdc8bdd"><code>53211cc3dc12a0f5ffadb2bdce9089403fdc8bdd</code></a> | October 27, 2023 | <code>4337/contracts/EIP4337Module.sol</code><br><code>4337/contracts/AddModulesLib.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/1981fbc63e3850d626074d81d22a198afe64ac03"><code>1981fbc63e3850d626074d81d22a198afe64ac03</code></a> | November 8, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |

## Safe ERC-4337 Module Audit v2.0

- Report: [safe-modules__modules__4337__docs__v0.2.0__audit-report-ackee-v2.0.md](<reports/safe-modules__modules__4337__docs__v0.2.0__audit-report-ackee-v2.0.md>)
- Auditor: Ackee Blockchain
- Date: 2023-12-05
- Description: Reviews the Safe ERC-4337 module across its original, compatibility-fix, v0.2.0, and immediate-fix revisions.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/53211cc3dc12a0f5ffadb2bdce9089403fdc8bdd"><code>53211cc3dc12a0f5ffadb2bdce9089403fdc8bdd</code></a> | October 27, 2023 | <code>4337/contracts/EIP4337Module.sol</code><br><code>4337/contracts/AddModulesLib.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/1981fbc63e3850d626074d81d22a198afe64ac03"><code>1981fbc63e3850d626074d81d22a198afe64ac03</code></a> | November 8, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/0371f5ac81da1a5275e5c5643fb95c1c4dda2121"><code>0371f5ac81da1a5275e5c5643fb95c1c4dda2121</code></a> | November 24, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/c366d822c42c656df3988624897a5b88fa83b2d7"><code>c366d822c42c656df3988624897a5b88fa83b2d7</code></a> | November 30, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/25779b5a5077e109a585993a02c4dad2209ab084"><code>25779b5a5077e109a585993a02c4dad2209ab084</code></a> | December 6, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |

## Safe 4337 Module Audit

- Report: [safe-modules__modules__4337__docs__v0.2.0__audit-report-openzeppelin.md](<reports/safe-modules__modules__4337__docs__v0.2.0__audit-report-openzeppelin.md>)
- Auditor: OpenZeppelin
- Date: 2024-02-07
- Description: Reviews the Safe4337Module and AddModulesLib implementation at the pinned repository revision.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/3853f34f31837e0a0aee47a4452564278f8c62ba"><code>3853f34f31837e0a0aee47a4452564278f8c62ba</code></a> | January 15, 2024 | <code>modules/4337/contracts/AddModulesLib.sol</code><br><code>modules/4337/contracts/Safe4337Module.sol</code> |

## Safe ERC-4337 Module Audit v3.0

- Report: [safe-modules__modules__4337__docs__v0.3.0__audit-report-ackee-v3.0.md](<reports/safe-modules__modules__4337__docs__v0.3.0__audit-report-ackee-v3.0.md>)
- Auditor: Ackee Blockchain
- Date: 2024-03-14
- Description: Consolidates the earlier ERC-4337 module reviews and adds an incremental v0.3.0 review of Safe4337Module.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/53211cc3dc12a0f5ffadb2bdce9089403fdc8bdd"><code>53211cc3dc12a0f5ffadb2bdce9089403fdc8bdd</code></a> | October 27, 2023 | <code>4337/contracts/EIP4337Module.sol</code><br><code>4337/contracts/AddModulesLib.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/1981fbc63e3850d626074d81d22a198afe64ac03"><code>1981fbc63e3850d626074d81d22a198afe64ac03</code></a> | November 8, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/0371f5ac81da1a5275e5c5643fb95c1c4dda2121"><code>0371f5ac81da1a5275e5c5643fb95c1c4dda2121</code></a> | November 24, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/c366d822c42c656df3988624897a5b88fa83b2d7"><code>c366d822c42c656df3988624897a5b88fa83b2d7</code></a> | November 30, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/25779b5a5077e109a585993a02c4dad2209ab084"><code>25779b5a5077e109a585993a02c4dad2209ab084</code></a> | December 6, 2023 | <code>4337/contracts/AddModulesLib.sol</code><br><code>4337/contracts/Safe4337Module.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/7b3ea24cf06dca2bc88405fd1c991b2338f565f8"><code>7b3ea24cf06dca2bc88405fd1c991b2338f565f8</code></a> | March 12, 2024 | <code>modules/4337/contracts/Safe4337Module.sol</code> |

## Safe 4337 Module Security Assessment

- Report: [safe-modules__modules__4337__docs__v0.3.0__audit-report-certora-v3.0.md](<reports/safe-modules__modules__4337__docs__v0.3.0__audit-report-certora-v3.0.md>)
- Auditor: Certora
- Date: 2026-08-11
- Description: Manually reviews the Safe ERC-4337 v0.3.0 module and setup helper and verifies the finding-remediation revision.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/5931a275c9f8638cb8c62b366744f4c9fd72533d"><code>5931a275c9f8638cb8c62b366744f4c9fd72533d</code></a> | March 19, 2024 | <code>modules/4337/contracts/Safe4337Module.sol</code><br><code>modules/4337/contracts/SafeModuleSetup.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/f877239bedc1f5f244154a895ce7108464c372df"><code>f877239bedc1f5f244154a895ce7108464c372df</code></a> | August 13, 2026 | <code>modules/4337/contracts/Safe4337Module.sol</code><br><code>modules/4337/contracts/SafeModuleSetup.sol</code> |

## Safe ERC-4337 Module Security Review

- Report: [safe-modules__modules__4337__docs__v0.3.0__audit-report-nethermind-v3.0.md](<reports/safe-modules__modules__4337__docs__v0.3.0__audit-report-nethermind-v3.0.md>)
- Auditor: Nethermind Security
- Date: 2026-08-17
- Description: Reviews the Safe4337Module and SafeModuleSetup contracts at the pinned v0.3.0 revision.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/5931a275c9f8638cb8c62b366744f4c9fd72533d"><code>5931a275c9f8638cb8c62b366744f4c9fd72533d</code></a> | March 19, 2024 | <code>modules/4337/contracts/Safe4337Module.sol</code><br><code>modules/4337/contracts/SafeModuleSetup.sol</code> |

## Safe Allowance Module Security Review

- Report: [safe-modules__modules__allowances__docs__v0.1.0__audit-report-g0.md](<reports/safe-modules__modules__allowances__docs__v0.1.0__audit-report-g0.md>)
- Auditor: G0 Group
- Description: Reviews all Solidity sources in the then-current Safe Modules repository and verifies fixes to the reported allowance issues.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/c75f190e5d55e88e98c20f802e3e9eadedfb52f6"><code>c75f190e5d55e88e98c20f802e3e9eadedfb52f6</code></a> | October 2, 2020 | <code>allowances/contracts/AlowanceModule.sol</code><br><code>allowances/contracts/Enum.sol</code><br><code>allowances/contracts/Migrations.sol</code><br><code>allowances/contracts/SignatureDecoder.sol</code><br><code>allowances/contracts/test/TestToken.sol</code><br><code>dutchx_seller/contracts/DutchXBaseModule.sol</code><br><code>dutchx_seller/contracts/DutchXCompleteModule.sol</code><br><code>dutchx_seller/contracts/DutchXInterface.sol</code><br><code>dutchx_seller/contracts/DutchXSellerModule.sol</code><br><code>dutchx_seller/contracts/DutchXTokenInterface.sol</code><br><code>dutchx_seller/contracts/Imports.sol</code><br><code>dutchx_seller/contracts/Migrations.sol</code><br><code>recurring_transfers/contracts/Imports.sol</code><br><code>recurring_transfers/contracts/Migrations.sol</code><br><code>recurring_transfers/contracts/RecurringTransfersModule.sol</code><br><code>recurring_transfers/contracts/TokenPriceOracle.sol</code><br><code>recurring_transfers/contracts/external/DateTime.sol</code><br><code>recurring_transfers/contracts/external/DutchExchangeInterface.sol</code><br><code>recurring_transfers/contracts/external/SafeMath.sol</code><br><code>recurring_transfers/contracts/test/ExposedRecurringTransfersModule.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/b531c8db9ded1fa72c8459078ebe4e88a2501bae"><code>b531c8db9ded1fa72c8459078ebe4e88a2501bae</code></a> | October 20, 2020 | <code>allowances/contracts/AlowanceModule.sol</code><br><code>allowances/contracts/Enum.sol</code><br><code>allowances/contracts/Migrations.sol</code><br><code>allowances/contracts/SignatureDecoder.sol</code><br><code>allowances/contracts/test/TestToken.sol</code><br><code>dutchx_seller/contracts/DutchXBaseModule.sol</code><br><code>dutchx_seller/contracts/DutchXCompleteModule.sol</code><br><code>dutchx_seller/contracts/DutchXInterface.sol</code><br><code>dutchx_seller/contracts/DutchXSellerModule.sol</code><br><code>dutchx_seller/contracts/DutchXTokenInterface.sol</code><br><code>dutchx_seller/contracts/Imports.sol</code><br><code>dutchx_seller/contracts/Migrations.sol</code><br><code>recurring_transfers/contracts/Imports.sol</code><br><code>recurring_transfers/contracts/Migrations.sol</code><br><code>recurring_transfers/contracts/RecurringTransfersModule.sol</code><br><code>recurring_transfers/contracts/TokenPriceOracle.sol</code><br><code>recurring_transfers/contracts/external/DateTime.sol</code><br><code>recurring_transfers/contracts/external/DutchExchangeInterface.sol</code><br><code>recurring_transfers/contracts/external/SafeMath.sol</code><br><code>recurring_transfers/contracts/test/ExposedRecurringTransfersModule.sol</code> |

## Safe Allowance Module Incremental Audit

- Report: [safe-modules__modules__allowances__docs__v0.1.1__audit-report-ackee.md](<reports/safe-modules__modules__allowances__docs__v0.1.1__audit-report-ackee.md>)
- Auditor: Ackee Blockchain Security
- Date: 2024-09-09
- Description: Reviews the changed allowance-transfer type hash and then verifies its remediation.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/bc76ffd27a8a0c15c255ffcb61707bf7a30085eb"><code>bc76ffd27a8a0c15c255ffcb61707bf7a30085eb</code></a> | August 30, 2024 | <code>modules/allowances/contracts/AllowanceModule.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/549ea1605538a4aa0571fa8e4d44e0e762e60720"><code>549ea1605538a4aa0571fa8e4d44e0e762e60720</code></a> | September 9, 2024 | <code>modules/allowances/contracts/AllowanceModule.sol</code> |

## Safe Allowance Module Security Assessment

- Report: [safe-modules__modules__allowances__docs__v1.0.0__audit-report-certora.md](<reports/safe-modules__modules__allowances__docs__v1.0.0__audit-report-certora.md>)
- Auditor: Certora
- Date: 2026-02-16
- Description: Manually reviews the three listed Allowance Module contracts and checks the final remediation revision.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/252e864496d3a7659195ab5b4418985678887ece"><code>252e864496d3a7659195ab5b4418985678887ece</code></a> | February 5, 2026 | <code>modules/allowances/contracts/AllowanceModule.sol</code><br><code>modules/allowances/contracts/SignatureDecoder.sol</code><br><code>modules/allowances/contracts/Enum.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/2d09764371b014c295d4d0202972e197e720d776"><code>2d09764371b014c295d4d0202972e197e720d776</code></a> | February 19, 2026 | <code>modules/allowances/contracts/AllowanceModule.sol</code><br><code>modules/allowances/contracts/SignatureDecoder.sol</code><br><code>modules/allowances/contracts/Enum.sol</code> |

## Safe Allowance Module Security Review

- Report: [safe-modules__modules__allowances__docs__v1.0.0__audit-report-nethermind.md](<reports/safe-modules__modules__allowances__docs__v1.0.0__audit-report-nethermind.md>)
- Auditor: Nethermind Security
- Date: 2026-08-17
- Description: Reviews the AllowanceModule, Enum, and SignatureDecoder contracts at the pinned revision.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/c95f03900bff99be090dadb9de1c74b162365485"><code>c95f03900bff99be090dadb9de1c74b162365485</code></a> | February 24, 2026 | <code>modules/allowances/contracts/AllowanceModule.sol</code><br><code>modules/allowances/contracts/SignatureDecoder.sol</code><br><code>modules/allowances/contracts/Enum.sol</code> |

## Safe Passkey Module Formal Verification and Audit

- Report: [safe-modules__modules__passkey__docs__v0.2.0__audit-report-certora.md](<reports/safe-modules__modules__passkey__docs__v0.2.0__audit-report-certora.md>)
- Auditor: Certora
- Date: 2024-06-13
- Description: Formally verifies and manually reviews the listed Passkey Module contracts and libraries.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/8a906605010520bed5b532c9d2feb04fdf237832"><code>8a906605010520bed5b532c9d2feb04fdf237832</code></a> | May 13, 2024 | <code>modules/passkey/contracts/SafeWebAuthnSignerFactory.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerProxy.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerSingleton.sol</code><br><code>modules/passkey/contracts/base/SignatureValidator.sol</code><br><code>modules/passkey/contracts/interfaces/IP256Verifier.sol</code><br><code>modules/passkey/contracts/interfaces/ISafe.sol</code><br><code>modules/passkey/contracts/interfaces/ISafeSignerFactory.sol</code><br><code>modules/passkey/contracts/libraries/ERC1271.sol</code><br><code>modules/passkey/contracts/libraries/P256.sol</code><br><code>modules/passkey/contracts/libraries/WebAuthn.sol</code> |

## Safe Audit Competition on Hats.finance

- Report: [safe-modules__modules__passkey__docs__v0.2.1__audit-competition-report-hats.md](<reports/safe-modules__modules__passkey__docs__v0.2.1__audit-competition-report-hats.md>)
- Auditor: Hats.finance
- Date: 2024-07-03
- Description: A public audit competition reviewing the listed Safe Passkey Module sources, including the shared signer and FCL verifier.

### Repository: <a href="https://github.com/hats-finance/Safe-0x2909fdefd24a1ced675cb1444918fa766d76bdac"><code>hats-finance/Safe-0x2909fdefd24a1ced675cb1444918fa766d76bdac</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/hats-finance/Safe-0x2909fdefd24a1ced675cb1444918fa766d76bdac/commit/2c03e35cd1f93de704136ab6e54ae42971a69465"><code>2c03e35cd1f93de704136ab6e54ae42971a69465</code></a> | June 19, 2024 | <code>modules/passkey/contracts/SafeWebAuthnSignerFactory.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerProxy.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerSingleton.sol</code><br><code>modules/passkey/contracts/base/SignatureValidator.sol</code><br><code>modules/passkey/contracts/interfaces/IP256Verifier.sol</code><br><code>modules/passkey/contracts/interfaces/ISafe.sol</code><br><code>modules/passkey/contracts/interfaces/ISafeSignerFactory.sol</code><br><code>modules/passkey/contracts/libraries/ERC1271.sol</code><br><code>modules/passkey/contracts/libraries/P256.sol</code><br><code>modules/passkey/contracts/libraries/WebAuthn.sol</code><br><code>modules/passkey/contracts/4337/README.md</code><br><code>modules/passkey/contracts/4337/SafeWebAuthnSharedSigner.sol</code><br><code>modules/passkey/contracts/verifiers/FCLP256Verifier.sol</code> |

## Safe Passkey Module Second Formal Verification and Audit

- Report: [safe-modules__modules__passkey__docs__v0.2.1__audit-report-certora.md](<reports/safe-modules__modules__passkey__docs__v0.2.1__audit-report-certora.md>)
- Auditor: Certora
- Date: 2024-07-25
- Description: Reviews fixes and changes since the first Passkey audit and adds the shared ERC-4337 signer to the formally verified and manually reviewed scope.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/8a906605010520bed5b532c9d2feb04fdf237832"><code>8a906605010520bed5b532c9d2feb04fdf237832</code></a> | May 13, 2024 | <code>modules/passkey/contracts/SafeWebAuthnSignerFactory.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerProxy.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerSingleton.sol</code><br><code>modules/passkey/contracts/base/SignatureValidator.sol</code><br><code>modules/passkey/contracts/interfaces/IP256Verifier.sol</code><br><code>modules/passkey/contracts/interfaces/ISafe.sol</code><br><code>modules/passkey/contracts/interfaces/ISafeSignerFactory.sol</code><br><code>modules/passkey/contracts/libraries/ERC1271.sol</code><br><code>modules/passkey/contracts/libraries/P256.sol</code><br><code>modules/passkey/contracts/libraries/WebAuthn.sol</code> |
| <a href="https://github.com/safe-fndn/safe-modules/commit/c3a4d0671099c5e17fda7287b764b93f6b9801df"><code>c3a4d0671099c5e17fda7287b764b93f6b9801df</code></a> | July 12, 2024 | <code>modules/passkey/contracts/SafeWebAuthnSignerFactory.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerProxy.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerSingleton.sol</code><br><code>modules/passkey/contracts/base/SignatureValidator.sol</code><br><code>modules/passkey/contracts/interfaces/IP256Verifier.sol</code><br><code>modules/passkey/contracts/interfaces/ISafe.sol</code><br><code>modules/passkey/contracts/interfaces/ISafeSignerFactory.sol</code><br><code>modules/passkey/contracts/libraries/ERC1271.sol</code><br><code>modules/passkey/contracts/libraries/P256.sol</code><br><code>modules/passkey/contracts/libraries/WebAuthn.sol</code><br><code>modules/passkey/contracts/4337/SafeWebAuthnSharedSigner.sol</code> |

## Safe Passkey Module Security Review

- Report: [safe-modules__modules__passkey__docs__v0.2.1__audit-report-nethermind.md](<reports/safe-modules__modules__passkey__docs__v0.2.1__audit-report-nethermind.md>)
- Auditor: Nethermind Security
- Date: 2026-08-17
- Description: Reviews the nine listed Passkey Module implementation, signer, verifier, and library contracts.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/dfd3b05966e727dbb7a2fdeef52e4b230f63304e"><code>dfd3b05966e727dbb7a2fdeef52e4b230f63304e</code></a> | August 20, 2024 | <code>modules/passkey/contracts/SafeWebAuthnSignerFactory.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerProxy.sol</code><br><code>modules/passkey/contracts/SafeWebAuthnSignerSingleton.sol</code><br><code>modules/passkey/contracts/base/SignatureValidator.sol</code><br><code>modules/passkey/contracts/libraries/ERC1271.sol</code><br><code>modules/passkey/contracts/libraries/P256.sol</code><br><code>modules/passkey/contracts/libraries/WebAuthn.sol</code><br><code>modules/passkey/contracts/4337/SafeWebAuthnSharedSigner.sol</code><br><code>modules/passkey/contracts/verifiers/FCLP256Verifier.sol</code> |

## Safe Social Recovery Module Audit

- Report: [safe-modules__modules__recovery__docs__v0.1.0__audit-report-ackee.md](<reports/safe-modules__modules__recovery__docs__v0.1.0__audit-report-ackee.md>)
- Auditor: Ackee Blockchain
- Date: 2024-06-14
- Description: Reviews Candide&#x27;s Social Recovery Module and guardian storage implementation and verifies the reported fixes.

### Repository: <a href="https://github.com/5afe/CandideWalletContracts"><code>5afe/CandideWalletContracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/5afe/CandideWalletContracts/commit/e6d45c8ca0c07f90204408f79684c7fed737944e"><code>e6d45c8ca0c07f90204408f79684c7fed737944e</code></a> | June 5, 2024 | <code>contracts/modules/social_recovery/SocialRecoveryModule.sol</code><br><code>contracts/modules/social_recovery/storage/GuardianStorage.sol</code> |
| <a href="https://github.com/5afe/CandideWalletContracts/commit/113d3c059e039e332637e8f686d9cbd505f1e738"><code>113d3c059e039e332637e8f686d9cbd505f1e738</code></a> | June 13, 2024 | <code>contracts/modules/social_recovery/SocialRecoveryModule.sol</code><br><code>contracts/modules/social_recovery/storage/GuardianStorage.sol</code> |

## Safe Recovery Module Security Assessment

- Report: [safe-modules__modules__recovery__docs__v0.1.0__audit-report-certora.md](<reports/safe-modules__modules__recovery__docs__v0.1.0__audit-report-certora.md>)
- Auditor: Certora
- Date: 2026-08-05
- Description: Reviews the Safe Recovery integration and the SocialRecoveryModule and GuardianStorage dependency sources in the release environment.

### Repository: <a href="https://github.com/safe-fndn/safe-modules"><code>safe-fndn/safe-modules</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-modules/commit/8076191f93e88eefaae3508efa8b12a091158c68"><code>8076191f93e88eefaae3508efa8b12a091158c68</code></a> | June 17, 2024 | <code>modules/recovery/contracts/SocialRecoveryModule.sol</code> |

### Repository: <a href="https://github.com/5afe/CandideWalletContracts"><code>5afe/CandideWalletContracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/5afe/CandideWalletContracts/commit/113d3c059e039e332637e8f686d9cbd505f1e738"><code>113d3c059e039e332637e8f686d9cbd505f1e738</code></a> | June 13, 2024 | <code>contracts/modules/social_recovery/SocialRecoveryModule.sol</code><br><code>contracts/modules/social_recovery/storage/GuardianStorage.sol</code> |

## Safe Social Recovery Module Security Review

- Report: [safe-modules__modules__recovery__docs__v0.1.0__audit-report-nethermind.md](<reports/safe-modules__modules__recovery__docs__v0.1.0__audit-report-nethermind.md>)
- Auditor: Nethermind Security
- Date: 2026-08-17
- Description: Reviews the Social Recovery Module and its guardian-storage contracts as used by the Safe recovery release.

### Repository: <a href="https://github.com/5afe/CandideWalletContracts"><code>5afe/CandideWalletContracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/5afe/CandideWalletContracts/commit/113d3c059e039e332637e8f686d9cbd505f1e738"><code>113d3c059e039e332637e8f686d9cbd505f1e738</code></a> | June 13, 2024 | <code>contracts/modules/social_recovery/SocialRecoveryModule.sol</code><br><code>contracts/modules/social_recovery/storage/GuardianStorage.sol</code><br><code>contracts/modules/social_recovery/storage/IGuardianStorage.sol</code> |

## Zodiac Delay Module Security Review

- Report: [zodiac-delay__audits__ZodiacDelayModuleSep2021.md](<reports/zodiac-delay__audits__ZodiacDelayModuleSep2021.md>)
- Auditor: G0 Group
- Date: 2021-09-01
- Description: Reviews Delay.sol and verifies the fixes for its critical, major, and lower-severity issues.

### Repository: <a href="https://github.com/gnosis/zodiac-modifier-delay"><code>gnosis/zodiac-modifier-delay</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/gnosis/zodiac-modifier-delay/commit/bde282125ebbe119df4bfd6374e097007a13fb8a"><code>bde282125ebbe119df4bfd6374e097007a13fb8a</code></a> | September 3, 2021 | <code>contracts/Delay.sol</code> |
| <a href="https://github.com/gnosis/zodiac-modifier-delay/commit/808dfda6fd0ea144bbbe83e419e14045a029ca5d"><code>808dfda6fd0ea144bbbe83e419e14045a029ca5d</code></a> | September 10, 2021 | <code>contracts/Delay.sol</code> |

## Zodiac Roles Modifier v2 Security Review

- Report: [zodiac-roles__packages__evm__docs__Audit01_RolesV2_Apr2023_G0Group.md](<reports/zodiac-roles__packages__evm__docs__Audit01_RolesV2_Apr2023_G0Group.md>)
- Auditor: G0 Group
- Date: 2023-04-01
- Description: Reviews all Solidity contracts in the Zodiac Roles v2 EVM package and verifies the remediation revision.

### Repository: <a href="https://github.com/gnosis/zodiac-modifier-roles"><code>gnosis/zodiac-modifier-roles</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/5d218a4b6b6d01412abac07a2a7582d07dd35a65"><code>5d218a4b6b6d01412abac07a2a7582d07dd35a65</code></a> | March 22, 2023 | <code>packages/evm/contracts/</code> (recursive directory) |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/c824d7b2b71f3dece080686640e51754bc57a654"><code>c824d7b2b71f3dece080686640e51754bc57a654</code></a> | April 20, 2023 | <code>packages/evm/contracts/</code> (recursive directory) |

## Zodiac Modifier Roles Security Audit

- Report: [zodiac-roles__packages__evm__docs__Audit02_RolesV2_May2023_Omniscia.md](<reports/zodiac-roles__packages__evm__docs__Audit02_RolesV2_May2023_Omniscia.md>)
- Auditor: Omniscia
- Date: 2023-05-09
- Description: Reviews the 17 listed Zodiac Roles contracts and evaluates the revised commit containing finding alleviations.

### Repository: <a href="https://github.com/gnosis/zodiac-modifier-roles"><code>gnosis/zodiac-modifier-roles</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/a9f65e8f058dae654eb873bf333c223a0f3db70c"><code>a9f65e8f058dae654eb873bf333c223a0f3db70c</code></a> | April 6, 2023 | <code>packages/evm/contracts/packers/BufferPacker.sol</code><br><code>packages/evm/contracts/Core.sol</code><br><code>packages/evm/contracts/Consumptions.sol</code><br><code>packages/evm/contracts/Decoder.sol</code><br><code>packages/evm/contracts/Integrity.sol</code><br><code>packages/evm/contracts/adapters/MultiSendUnwrapper.sol</code><br><code>packages/evm/contracts/packers/Packer.sol</code><br><code>packages/evm/contracts/Periphery.sol</code><br><code>packages/evm/contracts/PermissionLoader.sol</code><br><code>packages/evm/contracts/PermissionBuilder.sol</code><br><code>packages/evm/contracts/PermissionChecker.sol</code><br><code>packages/evm/contracts/PermissionTracker.sol</code><br><code>packages/evm/contracts/Roles.sol</code><br><code>packages/evm/contracts/adapters/Types.sol</code><br><code>packages/evm/contracts/Types.sol</code><br><code>packages/evm/contracts/Topology.sol</code><br><code>packages/evm/contracts/WriteOnce.sol</code> |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/23b782f781bbda750995934f6fdc01f242faadba"><code>23b782f781bbda750995934f6fdc01f242faadba</code></a> | May 8, 2023 | <code>packages/evm/contracts/packers/BufferPacker.sol</code><br><code>packages/evm/contracts/Core.sol</code><br><code>packages/evm/contracts/Consumptions.sol</code><br><code>packages/evm/contracts/Decoder.sol</code><br><code>packages/evm/contracts/Integrity.sol</code><br><code>packages/evm/contracts/adapters/MultiSendUnwrapper.sol</code><br><code>packages/evm/contracts/packers/Packer.sol</code><br><code>packages/evm/contracts/Periphery.sol</code><br><code>packages/evm/contracts/PermissionLoader.sol</code><br><code>packages/evm/contracts/PermissionBuilder.sol</code><br><code>packages/evm/contracts/PermissionChecker.sol</code><br><code>packages/evm/contracts/Roles.sol</code><br><code>packages/evm/contracts/adapters/Types.sol</code><br><code>packages/evm/contracts/Types.sol</code><br><code>packages/evm/contracts/Topology.sol</code><br><code>packages/evm/contracts/WriteOnce.sol</code> |

## Zodiac PR206 Security Audit

- Report: [zodiac-roles__packages__evm__docs__Audit03_RolesV2_1_Nov2023_Ominiscia.md](<reports/zodiac-roles__packages__evm__docs__Audit03_RolesV2_1_Nov2023_Ominiscia.md>)
- Auditor: Omniscia
- Date: 2023-11-06
- Description: Reviews PR #206 changes to nine contracts covered by the original Zodiac Roles audit and checks two remediation revisions.

### Repository: <a href="https://github.com/gnosis/zodiac-modifier-roles"><code>gnosis/zodiac-modifier-roles</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/6a7fb909a1a5dc55d5cfbe759a624ce20c625f46"><code>6a7fb909a1a5dc55d5cfbe759a624ce20c625f46</code></a> | September 18, 2023 | <code>packages/evm/contracts/adapters/AvatarIsOwnerOfERC721.sol</code><br><code>packages/evm/contracts/Decoder.sol</code><br><code>packages/evm/contracts/Integrity.sol</code><br><code>packages/evm/contracts/packers/Packer.sol</code><br><code>packages/evm/contracts/PermissionBuilder.sol</code><br><code>packages/evm/contracts/PermissionChecker.sol</code><br><code>packages/evm/contracts/adapters/Types.sol</code><br><code>packages/evm/contracts/Types.sol</code><br><code>packages/evm/contracts/Topology.sol</code> |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/e6d315f9170dcf4c622d504bd2fb6eafbdac9b75"><code>e6d315f9170dcf4c622d504bd2fb6eafbdac9b75</code></a> | October 11, 2023 | <code>packages/evm/contracts/adapters/AvatarIsOwnerOfERC721.sol</code><br><code>packages/evm/contracts/Decoder.sol</code><br><code>packages/evm/contracts/Integrity.sol</code><br><code>packages/evm/contracts/packers/Packer.sol</code><br><code>packages/evm/contracts/PermissionBuilder.sol</code><br><code>packages/evm/contracts/PermissionChecker.sol</code><br><code>packages/evm/contracts/adapters/Types.sol</code><br><code>packages/evm/contracts/Types.sol</code><br><code>packages/evm/contracts/Topology.sol</code> |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/4d851d2a8425ee29a6f35b2561d775b52d7523ce"><code>4d851d2a8425ee29a6f35b2561d775b52d7523ce</code></a> | October 31, 2023 | <code>packages/evm/contracts/adapters/AvatarIsOwnerOfERC721.sol</code><br><code>packages/evm/contracts/Decoder.sol</code><br><code>packages/evm/contracts/Integrity.sol</code><br><code>packages/evm/contracts/packers/Packer.sol</code><br><code>packages/evm/contracts/PermissionBuilder.sol</code><br><code>packages/evm/contracts/PermissionChecker.sol</code><br><code>packages/evm/contracts/adapters/Types.sol</code><br><code>packages/evm/contracts/Types.sol</code><br><code>packages/evm/contracts/Topology.sol</code> |

## Zodiac Roles Modifier v2.1 Security Review

- Report: [zodiac-roles__packages__evm__docs__Audit04_Roles-V2_1_Nov2023_G0Group.md](<reports/zodiac-roles__packages__evm__docs__Audit04_Roles-V2_1_Nov2023_G0Group.md>)
- Auditor: G0 Group
- Date: 2023-11-01
- Description: Reviews all Solidity contracts in the Zodiac Roles v2.1 EVM package and verifies the reported fix.

### Repository: <a href="https://github.com/gnosis/zodiac-modifier-roles"><code>gnosis/zodiac-modifier-roles</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/d4b6539bdb742cf20d29425bbfdfd06acebda7d1"><code>d4b6539bdb742cf20d29425bbfdfd06acebda7d1</code></a> | November 6, 2023 | <code>packages/evm/contracts/</code> (recursive directory) |
| <a href="https://github.com/gnosis/zodiac-modifier-roles/commit/a19c0ebda97f7d645335f2c386818546641f832b"><code>a19c0ebda97f7d645335f2c386818546641f832b</code></a> | November 29, 2023 | <code>packages/evm/contracts/</code> (recursive directory) |

## Zodiac Security Review

- Report: [zodiac__audits__GnosisZodiac2021Sep.md](<reports/zodiac__audits__GnosisZodiac2021Sep.md>)
- Auditor: G0 Group
- Date: 2021-09-01
- Description: Reviews all Solidity contracts in the Zodiac repository and verifies the finding-remediation revision.

### Repository: <a href="https://github.com/gnosis/zodiac"><code>gnosis/zodiac</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/gnosis/zodiac/commit/67a0956e2bce11b5945cc79f1aff4ee3a0a4ea2a"><code>67a0956e2bce11b5945cc79f1aff4ee3a0a4ea2a</code></a> | September 7, 2021 | <code>contracts/</code> (recursive directory) |
| <a href="https://github.com/gnosis/zodiac/commit/c7aea1be89447584d7fb38911c9a8410d8b64acd"><code>c7aea1be89447584d7fb38911c9a8410d8b64acd</code></a> | September 13, 2021 | <code>contracts/</code> (recursive directory) |

## Zodiac Signature Patch Audit

- Report: [zodiac__audits__ZodiacJune2026.md](<reports/zodiac__audits__ZodiacJune2026.md>)
- Auditor: Côme du Crest
- Date: 2026-06-12
- Description: Checks that patched deployed Delay v1.1.1 and Roles v2.1.0 contracts fix the SignatureChecker vulnerability, relying on earlier audits for all other behavior.

## Zodiac Modifier Update Security Review

- Report: [zodiac__audits__ZodiacModifierUpdateFeb2023.md](<reports/zodiac__audits__ZodiacModifierUpdateFeb2023.md>)
- Auditor: G0 Group
- Date: 2023-02-01
- Description: Reviews the Modifier.sol update at the pinned repository revision.

### Repository: <a href="https://github.com/gnosis/zodiac"><code>gnosis/zodiac</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/gnosis/zodiac/commit/2ddb81b9dab11821aaef3011d83ed7acce63cff9"><code>2ddb81b9dab11821aaef3011d83ed7acce63cff9</code></a> | February 5, 2023 | <code>contracts/core/Modifier.sol</code> |
