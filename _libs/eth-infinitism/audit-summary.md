# Audit source summary: eth-infinitism

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## EIP-4337 – Ethereum Account Abstraction Audit

- Report: [openzeppelin-2022-04-19-account-abstraction.md](<reports/openzeppelin-2022-04-19-account-abstraction.md>)
- Auditor: OpenZeppelin
- Date: 2022-04-19
- Description: OpenZeppelin&#x27;s first audit, commissioned by the Ethereum Foundation, of the EIP-4337 reference implementation: the EntryPoint/StakeManager core singleton and the sample wallets and paymasters in the account-abstraction repository. The EIP and architectural design were also reviewed, and the fixes were verified in a final commit.

### Repository: <a href="https://github.com/eth-infinitism/account-abstraction"><code>eth-infinitism/account-abstraction</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/8832d6e04b9f4f706f612261c6e46b3f1745d61a/contracts/BasePaymaster.sol"><code>8832d6e04b9f4f706f612261c6e46b3f1745d61a</code></a> | January 25, 2022 | <code>contracts/BasePaymaster.sol</code><br><code>contracts/EntryPoint.sol</code><br><code>contracts/IPaymaster.sol</code><br><code>contracts/IWallet.sol</code><br><code>contracts/StakeManager.sol</code><br><code>contracts/UserOperation.sol</code><br><code>contracts/samples/DepositPaymaster.sol</code><br><code>contracts/samples/ECDSA.sol</code><br><code>contracts/samples/IOracle.sol</code><br><code>contracts/samples/SimpleWallet.sol</code><br><code>contracts/samples/TokenPaymaster.sol</code><br><code>contracts/samples/VerifyingPaymaster.sol</code><br><code>contracts/samples/SimpleWalletForTokens.sol</code> (explicitly not audited)<br><code>contracts/test</code> (recursive directory) (explicitly not audited) |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/a2f4b7be4d9996095e08d7102bacc9f13ea99ff6/contracts/BasePaymaster.sol"><code>a2f4b7be4d9996095e08d7102bacc9f13ea99ff6</code></a> | April 12, 2022 | <code>contracts/BasePaymaster.sol</code><br><code>contracts/EntryPoint.sol</code><br><code>contracts/IPaymaster.sol</code><br><code>contracts/IWallet.sol</code><br><code>contracts/StakeManager.sol</code><br><code>contracts/UserOperation.sol</code><br><code>contracts/samples/DepositPaymaster.sol</code><br><code>contracts/samples/IOracle.sol</code><br><code>contracts/samples/SimpleWallet.sol</code><br><code>contracts/samples/TokenPaymaster.sol</code><br><code>contracts/samples/VerifyingPaymaster.sol</code><br><code>contracts/BaseWallet.sol</code> |

## EIP-4337 – Ethereum Account Abstraction Incremental Audit

- Report: [account-abstraction__audits__EIP_4337_–_Ethereum_Account_Abstraction_Incremental_Audit_Feb_2023.md](<reports/account-abstraction__audits__EIP_4337_–_Ethereum_Account_Abstraction_Incremental_Audit_Feb_2023.md>)
- Auditor: OpenZeppelin
- Date: 2023-02-23
- Description: OpenZeppelin&#x27;s incremental audit for the Ethereum Foundation of the revised EIP-4337 reference implementation (v0.4 era), covering the EntryPoint core, interfaces, BLS aggregation, Gnosis Safe integration, and sample accounts and paymasters. Fix pull requests were reviewed up to a final commit.

### Repository: <a href="https://github.com/eth-infinitism/account-abstraction"><code>eth-infinitism/account-abstraction</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/6dea6d8752f64914dd95d932f673ba0f9ff8e144/contracts/bls/BLSAccount.sol"><code>6dea6d8752f64914dd95d932f673ba0f9ff8e144</code></a> | January 2, 2023 | <code>contracts/bls/BLSAccount.sol</code><br><code>contracts/bls/BLSAccountFactory.sol</code><br><code>contracts/bls/BLSSignatureAggregator.sol</code><br><code>contracts/bls/IBLSAccount.sol</code><br><code>contracts/core/BaseAccount.sol</code><br><code>contracts/core/BasePaymaster.sol</code><br><code>contracts/core/EntryPoint.sol</code><br><code>contracts/core/SenderCreator.sol</code><br><code>contracts/core/StakeManager.sol</code><br><code>contracts/gnosis/EIP4337Fallback.sol</code><br><code>contracts/gnosis/EIP4337Manager.sol</code><br><code>contracts/gnosis/GnosisAccountFactory.sol</code><br><code>contracts/interfaces/IAccount.sol</code><br><code>contracts/interfaces/IAggregatedAccount.sol</code><br><code>contracts/interfaces/IAggregator.sol</code><br><code>contracts/interfaces/ICreate2Deployer.sol</code><br><code>contracts/interfaces/IEntryPoint.sol</code><br><code>contracts/interfaces/IPaymaster.sol</code><br><code>contracts/interfaces/IStakeManager.sol</code><br><code>contracts/interfaces/UserOperation.sol</code><br><code>contracts/samples/DepositPaymaster.sol</code><br><code>contracts/samples/IOracle.sol</code><br><code>contracts/samples/SimpleAccount.sol</code><br><code>contracts/samples/SimpleAccountFactory.sol</code><br><code>contracts/samples/TestAggregatedAccount.sol</code><br><code>contracts/samples/TestAggregatedAccountFactory.sol</code><br><code>contracts/samples/TestSignatureAggregator.sol</code><br><code>contracts/samples/TokenPaymaster.sol</code><br><code>contracts/samples/VerifyingPaymaster.sol</code><br><code>contracts/utils/Exec.sol</code><br><code>contracts/bls/BLSHelper.sol</code> (explicitly not audited) |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/1cc1c97a00131a7922d1ccebd823e81e823b5d9f/contracts/bls/BLSSignatureAggregator.sol"><code>1cc1c97a00131a7922d1ccebd823e81e823b5d9f</code></a> | February 8, 2023 | <code>contracts/bls/BLSSignatureAggregator.sol</code> |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/1f505c5889b04a115b1bf09386c0b84cecdad5c4/contracts/samples/bls/BLSSignatureAggregator.sol"><code>1f505c5889b04a115b1bf09386c0b84cecdad5c4</code></a> | February 13, 2023 | <code>contracts/samples/bls/BLSSignatureAggregator.sol</code> |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/f3b5f795515ad8a7a7bf447575d6554854b820da/contracts/samples/bls/BLSAccount.sol"><code>f3b5f795515ad8a7a7bf447575d6554854b820da</code></a> | February 16, 2023 | <code>contracts/samples/bls/BLSAccount.sol</code><br><code>contracts/samples/bls/BLSAccountFactory.sol</code><br><code>contracts/samples/bls/BLSSignatureAggregator.sol</code><br><code>contracts/samples/bls/IBLSAccount.sol</code><br><code>contracts/core/BaseAccount.sol</code><br><code>contracts/core/BasePaymaster.sol</code><br><code>contracts/core/EntryPoint.sol</code><br><code>contracts/core/SenderCreator.sol</code><br><code>contracts/core/StakeManager.sol</code><br><code>contracts/samples/gnosis/EIP4337Fallback.sol</code><br><code>contracts/samples/gnosis/EIP4337Manager.sol</code><br><code>contracts/samples/gnosis/GnosisAccountFactory.sol</code><br><code>contracts/interfaces/IAccount.sol</code><br><code>contracts/interfaces/IAggregator.sol</code><br><code>contracts/interfaces/IEntryPoint.sol</code><br><code>contracts/interfaces/IPaymaster.sol</code><br><code>contracts/interfaces/IStakeManager.sol</code><br><code>contracts/interfaces/UserOperation.sol</code><br><code>contracts/samples/DepositPaymaster.sol</code><br><code>contracts/samples/IOracle.sol</code><br><code>contracts/samples/SimpleAccount.sol</code><br><code>contracts/samples/SimpleAccountFactory.sol</code><br><code>contracts/test/TestAggregatedAccount.sol</code><br><code>contracts/test/TestAggregatedAccountFactory.sol</code><br><code>contracts/test/TestSignatureAggregator.sol</code><br><code>contracts/samples/TokenPaymaster.sol</code><br><code>contracts/samples/VerifyingPaymaster.sol</code><br><code>contracts/utils/Exec.sol</code> |

## Account Abstraction Audit (ERC-4337 Incremental Audit, February 2024)

- Report: [account-abstraction__audits__ERC-4337 Account Abstraction Incremental Audit Report Feb 20 2024.md](<reports/account-abstraction__audits__ERC-4337 Account Abstraction Incremental Audit Report Feb 20 2024.md>)
- Auditor: OpenZeppelin
- Date: 2024-02-20
- Description: OpenZeppelin&#x27;s third review for the Ethereum Foundation of the account-abstraction repository, covering every non-test Solidity file changed since the previous review (the v0.7 EntryPoint, gas accounting, simulation and TokenPaymaster changes), the ERC specifications, and two pull requests. Fix pull requests were reviewed up to a final commit.

### Repository: <a href="https://github.com/eth-infinitism/account-abstraction"><code>eth-infinitism/account-abstraction</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/c3dbc2ddf7ca769a1111a277ef908898e45bfbfa/contracts/core/EntryPoint.sol"><code>c3dbc2ddf7ca769a1111a277ef908898e45bfbfa</code></a> | January 12, 2024 | <code>contracts/core/EntryPoint.sol</code><br><code>contracts/core/EntryPointSimulations.sol</code><br><code>contracts/core/Helpers.sol</code><br><code>contracts/core/SenderCreator.sol</code><br><code>contracts/utils/Exec.sol</code> |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BaseAccount.sol"><code>9879c931ce92f0bee1bca1d1b1352eeb98b9a120</code></a> | January 14, 2024 | <code>contracts/core/BaseAccount.sol</code><br><code>contracts/core/BasePaymaster.sol</code><br><code>contracts/core/EntryPoint.sol</code><br><code>contracts/core/EntryPointSimulations.sol</code><br><code>contracts/core/Helpers.sol</code><br><code>contracts/core/NonceManager.sol</code><br><code>contracts/core/SenderCreator.sol</code><br><code>contracts/core/StakeManager.sol</code><br><code>contracts/core/UserOperationLib.sol</code><br><code>contracts/interfaces/IAccount.sol</code><br><code>contracts/interfaces/IAccountExecute.sol</code><br><code>contracts/interfaces/IAggregator.sol</code><br><code>contracts/interfaces/IEntryPoint.sol</code><br><code>contracts/interfaces/IEntryPointSimulations.sol</code><br><code>contracts/interfaces/INonceManager.sol</code><br><code>contracts/interfaces/IPaymaster.sol</code><br><code>contracts/interfaces/IStakeManager.sol</code><br><code>contracts/interfaces/PackedUserOperation.sol</code><br><code>contracts/samples/SimpleAccount.sol</code><br><code>contracts/samples/TokenPaymaster.sol</code><br><code>contracts/samples/VerifyingPaymaster.sol</code><br><code>contracts/samples/bls/BLSAccount.sol</code><br><code>contracts/samples/bls/BLSSignatureAggregator.sol</code><br><code>contracts/samples/callback/TokenCallbackHandler.sol</code><br><code>contracts/samples/utils/IOracle.sol</code><br><code>contracts/samples/utils/OracleHelper.sol</code><br><code>contracts/samples/utils/UniswapHelper.sol</code><br><code>contracts/samples/LegacyTokenPaymaster.sol</code> (explicitly not audited)<br><code>erc/ERCS</code> (recursive directory) |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/4126ec572d72820984e875250ae57e413dc6b66f/contracts/core/EntryPoint.sol"><code>4126ec572d72820984e875250ae57e413dc6b66f</code></a> | February 11, 2024 | <code>contracts/core/EntryPoint.sol</code> |
| <a href="https://github.com/eth-infinitism/account-abstraction/blob/8086e7ba0d80e6f7e5d36306b73793cbcaa4ced6/contracts/core/BaseAccount.sol"><code>8086e7ba0d80e6f7e5d36306b73793cbcaa4ced6</code></a> | February 19, 2024 | <code>contracts/core/BaseAccount.sol</code><br><code>contracts/core/BasePaymaster.sol</code><br><code>contracts/core/EntryPoint.sol</code><br><code>contracts/core/EntryPointSimulations.sol</code><br><code>contracts/core/Helpers.sol</code><br><code>contracts/core/NonceManager.sol</code><br><code>contracts/core/SenderCreator.sol</code><br><code>contracts/core/StakeManager.sol</code><br><code>contracts/core/UserOperationLib.sol</code><br><code>contracts/interfaces/IAccount.sol</code><br><code>contracts/interfaces/IAccountExecute.sol</code><br><code>contracts/interfaces/IAggregator.sol</code><br><code>contracts/interfaces/IEntryPoint.sol</code><br><code>contracts/interfaces/IEntryPointSimulations.sol</code><br><code>contracts/interfaces/INonceManager.sol</code><br><code>contracts/interfaces/IPaymaster.sol</code><br><code>contracts/interfaces/IStakeManager.sol</code><br><code>contracts/interfaces/PackedUserOperation.sol</code><br><code>contracts/samples/SimpleAccount.sol</code><br><code>contracts/samples/TokenPaymaster.sol</code><br><code>contracts/samples/VerifyingPaymaster.sol</code><br><code>contracts/samples/bls/BLSAccount.sol</code><br><code>contracts/samples/bls/BLSSignatureAggregator.sol</code><br><code>contracts/samples/callback/TokenCallbackHandler.sol</code><br><code>contracts/samples/utils/IOracle.sol</code><br><code>contracts/samples/utils/OracleHelper.sol</code><br><code>contracts/samples/utils/UniswapHelper.sol</code><br><code>erc/ERCS</code> (recursive directory) |

## Account Abstraction Security Review

- Report: [account-abstraction__audits__SpearBit Account Abstraction Security Review - Mar 2025.md](<reports/account-abstraction__audits__SpearBit Account Abstraction Security Review - Mar 2025.md>)
- Auditor: Spearbit (Cantina Managed)
- Date: 2025-03-25
- Description: Spearbit (Cantina Managed) security review for the Ethereum Foundation of the account-abstraction repository (ERC-4337 v0.8 EntryPoint, EIP-7702 support, accounts and paymasters) together with the ERC-4337 and ERC-7562 specifications. Fixes were verified at later commits of both repositories.

### Repository: <a href="https://github.com/eth-infinitism/account-abstraction"><code>eth-infinitism/account-abstraction</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/eth-infinitism/account-abstraction/tree/ed8a5c79b50361b2f1742ee9efecd45f494df597/contracts"><code>ed8a5c79b50361b2f1742ee9efecd45f494df597</code></a> | February 17, 2025 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/eth-infinitism/account-abstraction/tree/57f9a8d7b352d9e18d217513ad4592d36ee9ce11/contracts"><code>57f9a8d7b352d9e18d217513ad4592d36ee9ce11</code></a> | March 25, 2025 | <code>contracts</code> (recursive directory) |

### Repository: <a href="https://github.com/ethereum/ERCs"><code>ethereum/ERCs</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum/ERCs/blob/62a7f8b36843c803d935fc04f0c74f61dcbbbd71/ERCS/erc-7562.md"><code>62a7f8b36843c803d935fc04f0c74f61dcbbbd71</code></a> | January 13, 2025 | <code>ERCS/erc-7562.md</code> |
| <a href="https://github.com/ethereum/ERCs/blob/0b01810450dbc171c909e74a0fa5fc2bc60a1a8a/ERCS/erc-4337.md"><code>0b01810450dbc171c909e74a0fa5fc2bc60a1a8a</code></a> | February 19, 2025 | <code>ERCS/erc-4337.md</code> |
| <a href="https://github.com/ethereum/ERCs/blob/25f2b66769fe17cf002da2c0413144acf03c2308/ERCS/erc-4337.md"><code>25f2b66769fe17cf002da2c0413144acf03c2308</code></a> | March 12, 2025 | <code>ERCS/erc-4337.md</code> |
| <a href="https://github.com/ethereum/ERCs/blob/609c02dc1d8cfb22ff4b4ab5fe731b620d64055c/ERCS/erc-7562.md"><code>609c02dc1d8cfb22ff4b4ab5fe731b620d64055c</code></a> | March 12, 2025 | <code>ERCS/erc-7562.md</code> |

## Ethereum Foundation: Account Abstraction Infrastructure Security Review (ERC-4337 v0.9)

- Report: [account-abstraction__audits__ERC-4337 Account Abstraction v0.9 Security Review - Cantina.md](<reports/account-abstraction__audits__ERC-4337 Account Abstraction v0.9 Security Review - Cantina.md>)
- Auditor: Cantina Managed
- Date: 2025-11-16
- Description: Cantina Managed security review for the Ethereum Foundation of the account-abstraction repository at the ERC-4337 v0.9 release candidate, covering the EntryPoint, paymaster base, EIP-7702 support and sample accounts. All findings were re-verified at a later commit.

### Repository: <a href="https://github.com/eth-infinitism/account-abstraction"><code>eth-infinitism/account-abstraction</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/eth-infinitism/account-abstraction/tree/86fcd84cf7263fe384d61d078ee747b16e69a496/contracts"><code>86fcd84cf7263fe384d61d078ee747b16e69a496</code></a> | October 30, 2025 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/eth-infinitism/account-abstraction/tree/f54584edd4c627e084d04c315dcabda48a6b9ea9/contracts"><code>f54584edd4c627e084d04c315dcabda48a6b9ea9</code></a> | November 12, 2025 | <code>contracts</code> (recursive directory) |
