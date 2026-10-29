# Audit source summary: safe

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Gnosis Safe Audit Report

- Report: [safe-core__docs__Gnosis_Safe_Audit_Report.md](<reports/safe-core__docs__Gnosis_Safe_Audit_Report.md>)
- Auditor: Alexey Akhunov
- Description: Reviews the original Gnosis Safe contracts and a substantially refactored second iteration, covering wallet execution, proxies, extensions, and libraries.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/b1a80f23b99c4983229dbb678c9f77895c9d2b70"><code>b1a80f23b99c4983229dbb678c9f77895c9d2b70</code></a> | January 28, 2018 | <code>contracts</code> (recursive directory)<br><code>contracts/libraries/MultiSendStruct.sol</code> (explicitly not audited) |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/942968d66a4fa200fe9757d02b377dbfc3c88636"><code>942968d66a4fa200fe9757d02b377dbfc3c88636</code></a> | June 14, 2018 | <code>contracts</code> (recursive directory) |

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
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/4bfc0c8519f1893015d7edfd2c2780fca163c364"><code>4bfc0c8519f1893015d7edfd2c2780fca163c364</code></a> | March 29, 2021 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/9b305a0f80da7f1107d1181f52c844f089557d05"><code>9b305a0f80da7f1107d1181f52c844f089557d05</code></a> | April 12, 2021 | <code>contracts</code> (recursive directory) |

## Security Review of Gnosis Safe 1.3.0 (Final)

- Report: [safe-core__docs__Gnosis_Safe_Audit_Report_1_3_0_Final.md](<reports/safe-core__docs__Gnosis_Safe_Audit_Report_1_3_0_Final.md>)
- Auditor: G0 Group
- Date: 2021-05-01
- Description: Reviews all Solidity sources in the final Safe 1.3.0 audit revision.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/ad6c7355d5bdf4f7fa348fbfcb9f07431769a3c9"><code>ad6c7355d5bdf4f7fa348fbfcb9f07431769a3c9</code></a> | May 3, 2021 | <code>contracts</code> (recursive directory) |

## Safe Smart Account v1.3.0 Security Assessment

- Report: [safe-core__docs__Safe_Audit_Report_1_3_0_Certora.md](<reports/safe-core__docs__Safe_Audit_Report_1_3_0_Certora.md>)
- Auditor: Certora
- Date: 2026-07-29
- Description: Manually reviews the full listed Safe v1.3.0 contract set and assesses known security-relevant behaviors, with a follow-up finding fix.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/767ef36bba88bdbc0c9fe3708a4290cabef4c376"><code>767ef36bba88bdbc0c9fe3708a4290cabef4c376</code></a> | November 17, 2021 | <code>contracts/GnosisSafe.sol</code><br><code>contracts/GnosisSafeL2.sol</code><br><code>contracts/accessors/SimulateTxAccessor.sol</code><br><code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/GuardManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/common/Singleton.sol</code><br><code>contracts/common/StorageAccessible.sol</code><br><code>contracts/external/GnosisSafeMath.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/handler/HandlerContext.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/IERC165.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/interfaces/ViewStorageAccessible.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/GnosisSafeStorage.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code><br><code>contracts/proxies/GnosisSafeProxy.sol</code><br><code>contracts/proxies/GnosisSafeProxyFactory.sol</code><br><code>contracts/proxies/IProxyCreationCallback.sol</code> |

## Safe Smart Account v1.3.0 Security Review

- Report: [safe-core__docs__Safe_Audit_Report_1_3_0_Nethermind.md](<reports/safe-core__docs__Safe_Audit_Report_1_3_0_Nethermind.md>)
- Auditor: Nethermind Security
- Date: 2026-08-17
- Description: Reviews the listed Safe v1.3.0 contracts and records remediation of the identified issues in the v1.4.0 release.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/767ef36bba88bdbc0c9fe3708a4290cabef4c376"><code>767ef36bba88bdbc0c9fe3708a4290cabef4c376</code></a> | November 17, 2021 | <code>contracts/GnosisSafe.sol</code><br><code>contracts/GnosisSafeL2.sol</code><br><code>contracts/accessors/SimulateTxAccessor.sol</code><br><code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/GuardManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/EtherPaymentFallback.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/common/Singleton.sol</code><br><code>contracts/common/StorageAccessible.sol</code><br><code>contracts/external/GnosisSafeMath.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/handler/DefaultCallbackHandler.sol</code><br><code>contracts/handler/HandlerContext.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/GnosisSafeStorage.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code><br><code>contracts/proxies/GnosisSafeProxy.sol</code><br><code>contracts/proxies/GnosisSafeProxyFactory.sol</code><br><code>contracts/proxies/IProxyCreationCallback.sol</code> |

## Safe Contracts 1.4.0 Security Review

- Report: [safe-core__docs__Safe_Audit_Report_1_4_0.md](<reports/safe-core__docs__Safe_Audit_Report_1_4_0.md>)
- Auditor: Ackee Blockchain
- Date: 2023-03-28
- Description: Reviews five Safe 1.4.0 entry-point contracts together with all of their recursively imported dependencies, followed by a remediation review.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/eb93dbb0f62e2dc1b308ac4c110038062df0a8c9"><code>eb93dbb0f62e2dc1b308ac4c110038062df0a8c9</code></a> | March 7, 2023 | <code>contracts/Safe.sol</code><br><code>contracts/SafeL2.sol</code><br><code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/GuardManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/NativeCurrencyPaymentFallback.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/common/Singleton.sol</code><br><code>contracts/common/StorageAccessible.sol</code><br><code>contracts/external/SafeMath.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/handler/TokenCallbackHandler.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/IERC165.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SafeStorage.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code><br><code>contracts/proxies/IProxyCreationCallback.sol</code><br><code>contracts/proxies/SafeProxy.sol</code><br><code>contracts/proxies/SafeProxyFactory.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/cb4b2b19b3e336b8defd3b8c9e0e6a2ae130598c"><code>cb4b2b19b3e336b8defd3b8c9e0e6a2ae130598c</code></a> | March 28, 2023 | <code>contracts/Safe.sol</code><br><code>contracts/SafeL2.sol</code><br><code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/GuardManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/Enum.sol</code><br><code>contracts/common/NativeCurrencyPaymentFallback.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/common/Singleton.sol</code><br><code>contracts/common/StorageAccessible.sol</code><br><code>contracts/external/SafeMath.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/handler/TokenCallbackHandler.sol</code><br><code>contracts/interfaces/ERC1155TokenReceiver.sol</code><br><code>contracts/interfaces/ERC721TokenReceiver.sol</code><br><code>contracts/interfaces/ERC777TokensRecipient.sol</code><br><code>contracts/interfaces/IERC165.sol</code><br><code>contracts/interfaces/ISignatureValidator.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SafeStorage.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code><br><code>contracts/proxies/IProxyCreationCallback.sol</code><br><code>contracts/proxies/SafeProxy.sol</code><br><code>contracts/proxies/SafeProxyFactory.sol</code> |

## Safe Smart Account Security Review

- Report: [safe-core__docs__Safe_Audit_Report_1_5_0_Ackee.md](<reports/safe-core__docs__Safe_Audit_Report_1_5_0_Ackee.md>)
- Auditor: Ackee Blockchain Security
- Date: 2025-05-28
- Description: Reviews every Solidity file under the Safe smart-account contracts directory except examples and tests, then verifies implemented fixes.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/b115c4c5fe23dca6aefeeccc73d312ddd23322c2"><code>b115c4c5fe23dca6aefeeccc73d312ddd23322c2</code></a> | April 29, 2025 | <code>contracts</code> (recursive directory)<br><code>contracts/examples</code> (recursive directory) (explicitly not audited)<br><code>contracts/test</code> (recursive directory) (explicitly not audited) |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/5d26505388e9ee014ad9ac497aa48e3a13426eb1"><code>5d26505388e9ee014ad9ac497aa48e3a13426eb1</code></a> | May 27, 2025 | <code>contracts</code> (recursive directory)<br><code>contracts/examples</code> (recursive directory) (explicitly not audited)<br><code>contracts/test</code> (recursive directory) (explicitly not audited) |

## Gnosis Safe Audit Results

- Report: [safe-early__docs__alexey_audit.md](<reports/safe-early__docs__alexey_audit.md>)
- Auditor: Alexey Akhunov
- Description: Identifies the source revision used by the attached Safe audit and the later revision checked with symbolic execution.

### Repository: <a href="https://github.com/safe-fndn/safe-smart-account"><code>safe-fndn/safe-smart-account</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/942968d66a4fa200fe9757d02b377dbfc3c88636"><code>942968d66a4fa200fe9757d02b377dbfc3c88636</code></a> | June 14, 2018 | <code>contracts</code> (recursive directory) |
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
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/834e798aa51291cccaf0594921194928716e9892"><code>834e798aa51291cccaf0594921194928716e9892</code></a> | December 14, 2024 | <code>contracts/Safe.sol</code><br><code>contracts/SafeL2.sol</code><br><code>contracts/accessors/SimulateTxAccessor.sol</code><br><code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/GuardManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/NativeCurrencyPaymentFallback.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/common/Singleton.sol</code><br><code>contracts/common/StorageAccessible.sol</code><br><code>contracts/external/SafeMath.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/handler/ExtensibleFallbackHandler.sol</code><br><code>contracts/handler/HandlerContext.sol</code><br><code>contracts/handler/TokenCallbackHandler.sol</code><br><code>contracts/handler/extensible/ERC165Handler.sol</code><br><code>contracts/handler/extensible/ExtensibleBase.sol</code><br><code>contracts/handler/extensible/FallbackHandler.sol</code><br><code>contracts/handler/extensible/MarshalLib.sol</code><br><code>contracts/handler/extensible/SignatureVerifierMuxer.sol</code><br><code>contracts/handler/extensible/TokenCallbacks.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/Enum.sol</code><br><code>contracts/libraries/ErrorMessage.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SafeMigration.sol</code><br><code>contracts/libraries/SafeStorage.sol</code><br><code>contracts/libraries/SafeToL2Migration.sol</code><br><code>contracts/libraries/SafeToL2Setup.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code><br><code>contracts/proxies/SafeProxy.sol</code><br><code>contracts/proxies/SafeProxyFactory.sol</code> |
| <a href="https://github.com/safe-fndn/safe-smart-account/commit/1c8b24a0a438e8c2cd089a9d830d1688a47a28d5"><code>1c8b24a0a438e8c2cd089a9d830d1688a47a28d5</code></a> | January 23, 2025 | <code>contracts/Safe.sol</code><br><code>contracts/SafeL2.sol</code><br><code>contracts/accessors/SimulateTxAccessor.sol</code><br><code>contracts/base/Executor.sol</code><br><code>contracts/base/FallbackManager.sol</code><br><code>contracts/base/GuardManager.sol</code><br><code>contracts/base/ModuleManager.sol</code><br><code>contracts/base/OwnerManager.sol</code><br><code>contracts/common/NativeCurrencyPaymentFallback.sol</code><br><code>contracts/common/SecuredTokenTransfer.sol</code><br><code>contracts/common/SelfAuthorized.sol</code><br><code>contracts/common/SignatureDecoder.sol</code><br><code>contracts/common/Singleton.sol</code><br><code>contracts/common/StorageAccessible.sol</code><br><code>contracts/external/SafeMath.sol</code><br><code>contracts/handler/CompatibilityFallbackHandler.sol</code><br><code>contracts/handler/ExtensibleFallbackHandler.sol</code><br><code>contracts/handler/HandlerContext.sol</code><br><code>contracts/handler/TokenCallbackHandler.sol</code><br><code>contracts/handler/extensible/ERC165Handler.sol</code><br><code>contracts/handler/extensible/ExtensibleBase.sol</code><br><code>contracts/handler/extensible/FallbackHandler.sol</code><br><code>contracts/handler/extensible/MarshalLib.sol</code><br><code>contracts/handler/extensible/SignatureVerifierMuxer.sol</code><br><code>contracts/handler/extensible/TokenCallbacks.sol</code><br><code>contracts/libraries/CreateCall.sol</code><br><code>contracts/libraries/Enum.sol</code><br><code>contracts/libraries/ErrorMessage.sol</code><br><code>contracts/libraries/MultiSend.sol</code><br><code>contracts/libraries/MultiSendCallOnly.sol</code><br><code>contracts/libraries/SafeMigration.sol</code><br><code>contracts/libraries/SafeStorage.sol</code><br><code>contracts/libraries/SafeToL2Migration.sol</code><br><code>contracts/libraries/SafeToL2Setup.sol</code><br><code>contracts/libraries/SignMessageLib.sol</code><br><code>contracts/proxies/SafeProxy.sol</code><br><code>contracts/proxies/SafeProxyFactory.sol</code> |

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
