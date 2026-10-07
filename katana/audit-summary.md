# Audit source summary: katana

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Code Assessment of the Vault Bridge Token Smart Contracts

- Report: [2025_05-chainsecurity-vault-bridge-token-code-assessment.md](<reports/2025_05-chainsecurity-vault-bridge-token-code-assessment.md>)
- Auditor: ChainSecurity
- Date: 2025-05-08
- Description: ChainSecurity code assessment of the Vault Bridge Token contracts (VaultBridgeToken, MigrationManager, CustomToken, NativeConverter, WETH variants and transfer-fee helpers) that extend the Unified Bridge with ERC-4626 yield vault deposits. Three versions were reviewed; the LxLy bridge, yield vaults, deployment scripts, tests and configuration were out of scope.

### Repository: <a href="https://github.com/agglayer/vault-bridge"><code>agglayer/vault-bridge</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/vault-bridge/commit/634716469cc2d84346683ab3c39d45834581fa69"><code>634716469cc2d84346683ab3c39d45834581fa69</code></a> | March 27, 2025 | <code>src/CustomToken.sol</code><br><code>src/NativeConverter.sol</code><br><code>src/TransferFeeUtils.sol</code><br><code>src/VaultBridgeToken.sol</code><br><code>src/VaultBridgeTokenInitializer.sol</code><br><code>src/custom-tokens/GenericCustomToken.sol</code><br><code>src/custom-tokens/GenericNativeConverter.sol</code><br><code>src/custom-tokens/WETH/WETH.sol</code><br><code>src/custom-tokens/WETH/WETHNativeConverter.sol</code><br><code>src/etc/ERC20PermitUser.sol</code><br><code>src/vault-bridge-tokens/GenericVbToken.sol</code><br><code>src/vault-bridge-tokens/vbETH/VbETH.sol</code><br><code>src/vault-bridge-tokens/vbUSDT/TransferFeeUtilsVbUSDT.sol</code> |
| <a href="https://github.com/agglayer/vault-bridge/commit/c3b307ffd354002140f3db110ffebc0e6739bbf6"><code>c3b307ffd354002140f3db110ffebc0e6739bbf6</code></a> | April 28, 2025 | <code>src/CustomToken.sol</code><br><code>src/NativeConverter.sol</code><br><code>src/VaultBridgeToken.sol</code><br><code>src/VaultBridgeTokenInitializer.sol</code><br><code>src/custom-tokens/GenericCustomToken.sol</code><br><code>src/custom-tokens/GenericNativeConverter.sol</code><br><code>src/custom-tokens/WETH/WETH.sol</code><br><code>src/custom-tokens/WETH/WETHNativeConverter.sol</code><br><code>src/etc/ERC20PermitUser.sol</code><br><code>src/vault-bridge-tokens/vbETH/VbETH.sol</code><br><code>src/MigrationManager.sol</code><br><code>src/ITransferFeeCalculator.sol</code><br><code>src/vault-bridge-tokens/GenericVaultBridgeToken.sol</code><br><code>src/vault-bridge-tokens/vbUSDT/USDTTransferFeeCalculator.sol</code> |
| <a href="https://github.com/agglayer/vault-bridge/commit/8751f1a592470e95c4a78aa1c1808ba048eef581"><code>8751f1a592470e95c4a78aa1c1808ba048eef581</code></a> | May 8, 2025 | <code>src/CustomToken.sol</code><br><code>src/NativeConverter.sol</code><br><code>src/VaultBridgeToken.sol</code><br><code>src/VaultBridgeTokenInitializer.sol</code><br><code>src/custom-tokens/GenericCustomToken.sol</code><br><code>src/custom-tokens/GenericNativeConverter.sol</code><br><code>src/custom-tokens/WETH/WETH.sol</code><br><code>src/custom-tokens/WETH/WETHNativeConverter.sol</code><br><code>src/etc/ERC20PermitUser.sol</code><br><code>src/vault-bridge-tokens/vbETH/VbETH.sol</code><br><code>src/MigrationManager.sol</code><br><code>src/ITransferFeeCalculator.sol</code><br><code>src/vault-bridge-tokens/GenericVaultBridgeToken.sol</code><br><code>src/vault-bridge-tokens/vbUSDT/USDTTransferFeeCalculator.sol</code> |

## Aragon Katana Security Review

- Report: [2025_11-cantina-aragon-katana-governance-review.md](<reports/2025_11-cantina-aragon-katana-governance-review.md>)
- Auditor: Cantina
- Date: 2025-11-04
- Description: Cantina Managed review of the katana-governance repository, Aragon&#x27;s Katana-specific vKAT governance extensions (AvKATVault, Swapper, VKatMetadata, Factory and the auto-compound and default strategies). Fixes were verified in pull requests #20, #21 and #25.

### Repository: <a href="https://github.com/aragon/katana-governance"><code>aragon/katana-governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/aragon/katana-governance/commit/5048116bf754c5d2efa8b8dbcfe5666cdba3abbc"><code>5048116bf754c5d2efa8b8dbcfe5666cdba3abbc</code></a> | October 10, 2025 | <code>src</code> (recursive directory) |
| <a href="https://github.com/aragon/katana-governance/commit/3cd640002eafb9f01b45bdff69e7ffee2325f5bc"><code>3cd640002eafb9f01b45bdff69e7ffee2325f5bc</code></a> | October 27, 2025 | <code>src</code> (recursive directory) |
| <a href="https://github.com/aragon/katana-governance/commit/98f40015f8ab3647df18052a7d275d70986bd6fe"><code>98f40015f8ab3647df18052a7d275d70986bd6fe</code></a> | October 27, 2025 | <code>src</code> (recursive directory) |
| <a href="https://github.com/aragon/katana-governance/commit/64fd6bbe7b7801015cabc3c31282b219c7b35f98"><code>64fd6bbe7b7801015cabc3c31282b219c7b35f98</code></a> | October 28, 2025 | <code>src</code> (recursive directory) |

## Security Review Report for Katana (KAT Vault and LayerZero OFT)

- Report: [2026_01-hexens-katana-kat-vault-layerzero-oft-review.md](<reports/2026_01-hexens-katana-kat-vault-layerzero-oft-review.md>)
- Auditor: Hexens
- Date: 2026-02-02
- Description: Hexens full review of the new KAT Vault and the upgradeable LayerZero OFT and OFT adapter contracts used to bridge the KAT token between Katana and BSC. All issues were reported fixed and validated at the listed fix commits.

### Repository: <a href="https://github.com/katana-network/kat-vault-lz"><code>katana-network/kat-vault-lz</code></a>

_Commit dates unavailable: 2 revision(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/katana-network/kat-vault-lz/commit/416a2993d9524406732fc29fb27442db4fcee28c"><code>416a2993d9524406732fc29fb27442db4fcee28c</code></a> | — | <code>src</code> (recursive directory) |
| <a href="https://github.com/katana-network/kat-vault-lz/commit/5af6fff31bddc76e205f15227081a7ef45c06cce"><code>5af6fff31bddc76e205f15227081a7ef45c06cce</code></a> | — | <code>src</code> (recursive directory) |

### Repository: <a href="https://github.com/katana-network/lz-kat-upgradeable"><code>katana-network/lz-kat-upgradeable</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/katana-network/lz-kat-upgradeable/commit/e88b7151420bae54d7ea7074abd6064ddcadba48"><code>e88b7151420bae54d7ea7074abd6064ddcadba48</code></a> | January 12, 2026 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/katana-network/lz-kat-upgradeable/commit/f1ea9138884e849d71ad9c1be9bdabd49da7bdfd"><code>f1ea9138884e849d71ad9c1be9bdabd49da7bdfd</code></a> | February 2, 2026 | <code>contracts</code> (recursive directory) |

## Kat Token Security Assessment (Manual Audit and Formal Verification)

- Report: [2025_03-certora-kat-token-audit-and-formal-verification.md](<reports/2025_03-certora-kat-token-audit-and-formal-verification.md>)
- Auditor: Certora
- Description: Certora manual review and formal verification of the KAT token contracts (KatToken, MerkleMinter, PowUtil), the Katana network&#x27;s native ERC-20 with Merkle-based initial minting and capped inflation. An appendix covers a late-stage review of pull request #5, which removed MerkleMinter and reworked KatToken roles and locking.

### Repository: <a href="https://github.com/katana-network/kat-token"><code>katana-network/kat-token</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/katana-network/kat-token/commit/21644ffdb2f00d3b8ba5f2fc84e9e3d0888faeed"><code>21644ffdb2f00d3b8ba5f2fc84e9e3d0888faeed</code></a> | March 11, 2025 | <code>src/KatToken.sol</code><br><code>src/MerkleMinter.sol</code><br><code>src/Powutil.sol</code> |
| <a href="https://github.com/katana-network/kat-token/commit/aa2932f57f4da85268aa2974d6f1cfb395624cd5"><code>aa2932f57f4da85268aa2974d6f1cfb395624cd5</code></a> | March 25, 2025 | <code>src/KatToken.sol</code><br><code>src/MerkleMinter.sol</code> |
| <a href="https://github.com/katana-network/kat-token/commit/494205cc0e5d302b4c6d96c16e63fa99912631d6"><code>494205cc0e5d302b4c6d96c16e63fa99912631d6</code></a> | May 7, 2025 | <code>src/KatToken.sol</code> |
| <a href="https://github.com/katana-network/kat-token/commit/eea36ab61f4ba1022dd2d3b53f5c43eb925b238e"><code>eea36ab61f4ba1022dd2d3b53f5c43eb925b238e</code></a> | May 14, 2025 | <code>src/KatToken.sol</code> |

## Yield Exposed Token Security Assessment Report (v2.0)

- Report: [2025_04-sigmaprime-vault-bridge-yield-exposed-token-security-assessment.md](<reports/2025_04-sigmaprime-vault-bridge-yield-exposed-token-security-assessment.md>)
- Auditor: Sigma Prime
- Description: Sigma Prime time-boxed review of all Solidity files of the Yield Exposed Token repository (the predecessor of Vault Bridge), covering yeTokens on layer X, custom tokens and native converters on layer Y and cross-chain migration through the LxLy bridge. Third-party libraries and dependencies were excluded.

### Repository: <a href="https://github.com/agglayer/vault-bridge"><code>agglayer/vault-bridge</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/vault-bridge/commit/d282975946fe638e4b9b7d0e99e40413418c577d"><code>d282975946fe638e4b9b7d0e99e40413418c577d</code></a> | February 9, 2025 | <code>src</code> (recursive directory) |
| <a href="https://github.com/agglayer/vault-bridge/commit/cd60520534c85195704646d1949068fe4ef224a9"><code>cd60520534c85195704646d1949068fe4ef224a9</code></a> | March 17, 2025 | <code>src</code> (recursive directory) |

## Vault Bridge Security Assessment (Manual Audit)

- Report: [2025_05-certora-vault-bridge-manual-audit.md](<reports/2025_05-certora-vault-bridge-manual-audit.md>)
- Auditor: Certora
- Description: Certora manual code review of the Vault Bridge v0.5.0 contracts: VaultBridgeToken and MigrationManager on Layer X, CustomToken and NativeConverter on Layer Y, WETH variants, interfaces and token templates. The review covered an initial and an updated commit, followed by a fix review of the final commit.

### Repository: <a href="https://github.com/agglayer/vault-bridge"><code>agglayer/vault-bridge</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/vault-bridge/commit/76081f6fcb655c487a5c4d9173615208b2a19914"><code>76081f6fcb655c487a5c4d9173615208b2a19914</code></a> | April 30, 2025 | <code>src/CustomToken.sol</code><br><code>src/ITransferFeeCalculator.sol</code><br><code>src/VaultBridgeTokenInitializer.sol</code><br><code>src/VaultBridgeToken.sol</code><br><code>src/MigrationManager.sol</code><br><code>src/NativeConverter.sol</code><br><code>src/custom-tokens/GenericCustomToken.sol</code><br><code>src/custom-tokens/GenericNativeConverter.sol</code><br><code>src/custom-tokens/vbUSDC/VbUSDC.sol.generic</code><br><code>src/custom-tokens/vbUSDC/vbUSDCNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbUSDS/VbUSDS.sol.generic</code><br><code>src/custom-tokens/vbUSDS/VbUSDSNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbUSDT/VbUSDT.sol.generic</code><br><code>src/custom-tokens/vbUSDT/VbUSDTNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbWBTC/VbWBTC.sol.generic</code><br><code>src/custom-tokens/vbWBTC/VbWBTCNativeConverter.sol.generic</code><br><code>src/custom-tokens/WETH/WETH.sol</code><br><code>src/custom-tokens/WETH/WETHNativeConverter.sol</code><br><code>src/etc/ERC20PermitUser.sol</code><br><code>src/etc/ILxLyBridge.sol</code><br><code>src/etc/IUSDT.sol</code><br><code>src/etc/IVaultBridgeTokenInitializer.sol</code><br><code>src/etc/IVersioned.sol</code><br><code>src/etc/IWETH9.sol</code><br><code>src/vault-bridge-tokens/GenericVaultBridgeToken.sol</code><br><code>src/vault-bridge-tokens/vbETH/VbETH.sol</code><br><code>src/vault-bridge-tokens/vbUSDC/VbUSDC.sol.generic</code><br><code>src/vault-bridge-tokens/vbUSDS/VbUSDS.sol.generic</code><br><code>src/vault-bridge-tokens/vbUSDT/USDTTransferFeeCalculator.sol</code><br><code>src/vault-bridge-tokens/vbUSDT/VbUSDT.sol.generic</code><br><code>src/vault-bridge-tokens/vbWBTC/VbWBTC.sol.generic</code> |
| <a href="https://github.com/agglayer/vault-bridge/commit/47f5a8cf28d0488cae3907dc089a9d77545aef17"><code>47f5a8cf28d0488cae3907dc089a9d77545aef17</code></a> | April 30, 2025 | <code>src/CustomToken.sol</code><br><code>src/ITransferFeeCalculator.sol</code><br><code>src/VaultBridgeTokenInitializer.sol</code><br><code>src/VaultBridgeToken.sol</code><br><code>src/MigrationManager.sol</code><br><code>src/NativeConverter.sol</code><br><code>src/custom-tokens/GenericCustomToken.sol</code><br><code>src/custom-tokens/GenericNativeConverter.sol</code><br><code>src/custom-tokens/vbUSDC/VbUSDC.sol.generic</code><br><code>src/custom-tokens/vbUSDC/vbUSDCNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbUSDS/VbUSDS.sol.generic</code><br><code>src/custom-tokens/vbUSDS/VbUSDSNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbUSDT/VbUSDT.sol.generic</code><br><code>src/custom-tokens/vbUSDT/VbUSDTNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbWBTC/VbWBTC.sol.generic</code><br><code>src/custom-tokens/vbWBTC/VbWBTCNativeConverter.sol.generic</code><br><code>src/custom-tokens/WETH/WETH.sol</code><br><code>src/custom-tokens/WETH/WETHNativeConverter.sol</code><br><code>src/etc/ERC20PermitUser.sol</code><br><code>src/etc/IBridgeMessageReceiver.sol</code><br><code>src/etc/ILxLyBridge.sol</code><br><code>src/etc/IUSDT.sol</code><br><code>src/etc/IVaultBridgeTokenInitializer.sol</code><br><code>src/etc/IVersioned.sol</code><br><code>src/etc/IWETH9.sol</code><br><code>src/vault-bridge-tokens/GenericVaultBridgeToken.sol</code><br><code>src/vault-bridge-tokens/vbETH/VbETH.sol</code><br><code>src/vault-bridge-tokens/vbUSDC/VbUSDC.sol.generic</code><br><code>src/vault-bridge-tokens/vbUSDS/VbUSDS.sol.generic</code><br><code>src/vault-bridge-tokens/vbUSDT/USDTTransferFeeCalculator.sol</code><br><code>src/vault-bridge-tokens/vbUSDT/VbUSDT.sol.generic</code><br><code>src/vault-bridge-tokens/vbWBTC/VbWBTC.sol.generic</code> |
| <a href="https://github.com/agglayer/vault-bridge/commit/a40ed0f1fb30ac0faec7a6777c3c3e1efce443f4"><code>a40ed0f1fb30ac0faec7a6777c3c3e1efce443f4</code></a> | May 14, 2025 | <code>src/CustomToken.sol</code><br><code>src/VaultBridgeTokenInitializer.sol</code><br><code>src/VaultBridgeToken.sol</code><br><code>src/MigrationManager.sol</code><br><code>src/NativeConverter.sol</code><br><code>src/custom-tokens/GenericCustomToken.sol</code><br><code>src/custom-tokens/GenericNativeConverter.sol</code><br><code>src/custom-tokens/vbUSDC/VbUSDC.sol.generic</code><br><code>src/custom-tokens/vbUSDS/VbUSDS.sol.generic</code><br><code>src/custom-tokens/vbUSDS/VbUSDSNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbUSDT/VbUSDT.sol.generic</code><br><code>src/custom-tokens/vbUSDT/VbUSDTNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbWBTC/VbWBTC.sol.generic</code><br><code>src/custom-tokens/vbWBTC/VbWBTCNativeConverter.sol.generic</code><br><code>src/custom-tokens/WETH/WETH.sol</code><br><code>src/custom-tokens/WETH/WETHNativeConverter.sol</code><br><code>src/etc/ERC20PermitUser.sol</code><br><code>src/etc/IBridgeMessageReceiver.sol</code><br><code>src/etc/ILxLyBridge.sol</code><br><code>src/etc/IUSDT.sol</code><br><code>src/etc/IVaultBridgeTokenInitializer.sol</code><br><code>src/etc/IVersioned.sol</code><br><code>src/etc/IWETH9.sol</code><br><code>src/vault-bridge-tokens/GenericVaultBridgeToken.sol</code><br><code>src/vault-bridge-tokens/vbETH/VbETH.sol</code><br><code>src/vault-bridge-tokens/vbUSDC/VbUSDC.sol.generic</code><br><code>src/vault-bridge-tokens/vbUSDS/VbUSDS.sol.generic</code><br><code>src/vault-bridge-tokens/vbUSDT/VbUSDT.sol.generic</code><br><code>src/vault-bridge-tokens/vbWBTC/VbWBTC.sol.generic</code><br><code>src/custom-tokens/vbUSDC/VbUSDCNativeConverter.sol.generic</code> |

## Vault Bridge Security Assessment (Formal Verification)

- Report: [2025_06-certora-vault-bridge-formal-verification.md](<reports/2025_06-certora-vault-bridge-formal-verification.md>)
- Auditor: Certora
- Description: Certora formal verification of the Vault Bridge v0.5.0 contracts, proving solvency, valid-state, integrity and risk-assessment properties for GenericVaultBridgeToken, GenericNativeConverter and MigrationManager. Two informational rounding issues were found and their fixes reviewed.

### Repository: <a href="https://github.com/agglayer/vault-bridge"><code>agglayer/vault-bridge</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/vault-bridge/commit/3a7d02576d5ecd1c9f4d22143983839f69d5f135"><code>3a7d02576d5ecd1c9f4d22143983839f69d5f135</code></a> | June 2, 2025 | <code>src/CustomToken.sol</code><br><code>src/VaultBridgeTokenInitializer.sol</code><br><code>src/VaultBridgeToken.sol</code><br><code>src/MigrationManager.sol</code><br><code>src/NativeConverter.sol</code><br><code>src/custom-tokens/GenericCustomToken.sol</code><br><code>src/custom-tokens/GenericNativeConverter.sol</code><br><code>src/custom-tokens/vbUSDC/VbUSDC.sol.generic</code><br><code>src/custom-tokens/vbUSDC/VbUSDCNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbUSDS/VbUSDS.sol.generic</code><br><code>src/custom-tokens/vbUSDS/VbUSDSNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbUSDT/VbUSDT.sol.generic</code><br><code>src/custom-tokens/vbUSDT/VbUSDTNativeConverter.sol.generic</code><br><code>src/custom-tokens/vbWBTC/VbWBTC.sol.generic</code><br><code>src/custom-tokens/vbWBTC/VbWBTCNativeConverter.sol.generic</code><br><code>src/custom-tokens/WETH/WETH.sol</code><br><code>src/custom-tokens/WETH/WETHNativeConverter.sol</code><br><code>src/etc/ERC20PermitUser.sol</code><br><code>src/etc/IBridgeMessageReceiver.sol</code><br><code>src/etc/ILxLyBridge.sol</code><br><code>src/etc/IVaultBridgeTokenInitializer.sol</code><br><code>src/etc/IVersioned.sol</code><br><code>src/etc/IWETH9.sol</code><br><code>src/vault-bridge-tokens/GenericVaultBridgeToken.sol</code><br><code>src/vault-bridge-tokens/vbETH/VbETH.sol</code><br><code>src/vault-bridge-tokens/vbUSDC/VbUSDC.sol.generic</code><br><code>src/vault-bridge-tokens/vbUSDS/VbUSDS.sol.generic</code><br><code>src/vault-bridge-tokens/vbUSDT/VbUSDT.sol.generic</code><br><code>src/vault-bridge-tokens/vbWBTC/VbWBTC.sol.generic</code> |
| <a href="https://github.com/agglayer/vault-bridge/commit/e4243e06d63f71f4a42e2c5fc8d10c42e93a5e73"><code>e4243e06d63f71f4a42e2c5fc8d10c42e93a5e73</code></a> | July 4, 2025 | <code>src/VaultBridgeToken.sol</code><br><code>src/NativeConverter.sol</code> |

## Polygon Vault Bridge V1 Security Assessment

- Report: [2025_10-certora-vault-bridge-v1-audit.md](<reports/2025_10-certora-vault-bridge-v1-audit.md>)
- Auditor: Certora
- Description: Certora manual review of Vault Bridge V1 (pull request #36), which restructures the protocol into primary-chain contracts (VaultBridgeToken, MigrationManager) and secondary-chain custom tokens and native converters for Agglayer, Polygon and Wormhole transports. Fixes were reviewed at a final commit.

### Repository: <a href="https://github.com/agglayer/vault-bridge"><code>agglayer/vault-bridge</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/vault-bridge/commit/3c9d819baf2f7071e196b15567562f8edb4d9922"><code>3c9d819baf2f7071e196b15567562f8edb4d9922</code></a> | September 19, 2025 | <code>src/etc/InitializationCounterUpgradeable.sol</code><br><code>src/etc/Versioned.sol</code><br><code>src/primary-chain/MigrationManager.sol</code><br><code>src/primary-chain/VaultBridgeToken.sol</code><br><code>src/primary-chain/VaultBridgeTokenInitializer.sol</code><br><code>src/primary-chain/VaultBridgeTokenPart2.sol</code><br><code>src/primary-chain/ethereum/GenericVaultBridgeToken.sol</code><br><code>src/primary-chain/ethereum/vbETH/VbETH.sol</code><br><code>src/secondary-chain/CustomToken.sol</code><br><code>src/secondary-chain/CustomTokenWethExtension.sol</code><br><code>src/secondary-chain/NativeConverter.sol</code><br><code>src/secondary-chain/agglayer/CustomTokenAgglayer.sol</code><br><code>src/secondary-chain/agglayer/GenericCustomTokenAgglayer.sol</code><br><code>src/secondary-chain/agglayer/GenericNativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/NativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbETH/WethAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbETH/WethNativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbUSDC/bridged-usdc-standard/VbUsdcNativeConverterAgglayerBridgedUsdcStandard.sol</code><br><code>src/secondary-chain/polygon/CustomTokenPolygon.sol</code><br><code>src/secondary-chain/polygon/GenericCustomTokenPolygon.sol</code><br><code>src/secondary-chain/wormhole/CustomTokenWormhole.sol</code><br><code>src/secondary-chain/wormhole/GenericCustomTokenWormhole.sol</code><br><code>src/secondary-chain/wormhole/vbETH/WethWormhole.sol</code> |
| <a href="https://github.com/agglayer/vault-bridge/commit/f98ff4c0a1ce3c5eb173db9ec20934002ea07be6"><code>f98ff4c0a1ce3c5eb173db9ec20934002ea07be6</code></a> | October 24, 2025 | <code>src/etc/InitializationCounterUpgradeable.sol</code><br><code>src/etc/Versioned.sol</code><br><code>src/primary-chain/MigrationManager.sol</code><br><code>src/primary-chain/VaultBridgeToken.sol</code><br><code>src/primary-chain/VaultBridgeTokenInitializer.sol</code><br><code>src/primary-chain/VaultBridgeTokenPart2.sol</code><br><code>src/primary-chain/ethereum/GenericVaultBridgeToken.sol</code><br><code>src/primary-chain/ethereum/vbETH/VbETH.sol</code><br><code>src/secondary-chain/CustomToken.sol</code><br><code>src/secondary-chain/CustomTokenWethExtension.sol</code><br><code>src/secondary-chain/NativeConverter.sol</code><br><code>src/secondary-chain/agglayer/CustomTokenAgglayer.sol</code><br><code>src/secondary-chain/agglayer/GenericCustomTokenAgglayer.sol</code><br><code>src/secondary-chain/agglayer/GenericNativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/NativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbETH/WethAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbETH/WethNativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbUSDC/bridged-usdc-standard/VbUsdcNativeConverterAgglayerBridgedUsdcStandard.sol</code><br><code>src/secondary-chain/polygon/CustomTokenPolygon.sol</code><br><code>src/secondary-chain/polygon/GenericCustomTokenPolygon.sol</code><br><code>src/secondary-chain/wormhole/CustomTokenWormhole.sol</code><br><code>src/secondary-chain/wormhole/GenericCustomTokenWormhole.sol</code><br><code>src/secondary-chain/wormhole/vbETH/WethWormhole.sol</code> |

## Polygon Vault Bridge V1.1 Security Assessment

- Report: [2025_11-certora-vault-bridge-v1.1-audit.md](<reports/2025_11-certora-vault-bridge-v1.1-audit.md>)
- Auditor: Certora
- Description: Certora manual re-audit of the full Vault Bridge V1.1 scope with a focus on the new LayerZero OFT adapter integration on primary and secondary chains. Fixes were reviewed at a final commit.

### Repository: <a href="https://github.com/agglayer/vault-bridge"><code>agglayer/vault-bridge</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/agglayer/vault-bridge/commit/7289ca32a9dfddbd7a6d2b6e5af4dd3384c665d5"><code>7289ca32a9dfddbd7a6d2b6e5af4dd3384c665d5</code></a> | October 31, 2025 | <code>src/etc/ERC20PermitUser.sol</code><br><code>src/etc/IAgglayerBridge.sol</code><br><code>src/etc/IBridgeMessageReceiver.sol</code><br><code>src/etc/IFiatTokenV2_2.sol</code><br><code>src/etc/IWETH9.sol</code><br><code>src/etc/IVaultBridgeTokenInitializer.sol</code><br><code>src/etc/InitializationCounterUpgradeable.sol</code><br><code>src/etc/Versioned.sol</code><br><code>src/primary-chain/MigrationManager.sol</code><br><code>src/primary-chain/VaultBridgeToken.sol</code><br><code>src/primary-chain/VaultBridgeTokenInitializer.sol</code><br><code>src/primary-chain/VaultBridgeTokenPart2.sol</code><br><code>src/primary-chain/ethereum/GenericVaultBridgeToken.sol</code><br><code>src/primary-chain/ethereum/vbETH/VbETH.sol</code><br><code>src/primary-chain/layerzero/NonDefaultOftAdapter.sol</code><br><code>src/secondary-chain/CustomToken.sol</code><br><code>src/secondary-chain/CustomTokenWethExtension.sol</code><br><code>src/secondary-chain/NativeConverter.sol</code><br><code>src/secondary-chain/agglayer/CustomTokenAgglayer.sol</code><br><code>src/secondary-chain/agglayer/GenericCustomTokenAgglayer.sol</code><br><code>src/secondary-chain/agglayer/GenericNativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/NativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbETH/WethAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbETH/WethNativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbUSDC/bridged-usdc-standard/VbUsdcNativeConverterAgglayerBridgedUsdcStandard.sol</code><br><code>src/secondary-chain/layerzero/CustomTokenLayerZero.sol</code><br><code>src/secondary-chain/layerzero/GenericCustomTokenLayerZero.sol</code><br><code>src/secondary-chain/layerzero/NonDefaultMintBurnOftAdapter.sol</code><br><code>src/secondary-chain/layerzero/vbETH/WethLayerZero.sol</code><br><code>src/secondary-chain/polygon/CustomTokenPolygon.sol</code><br><code>src/secondary-chain/polygon/GenericCustomTokenPolygon.sol</code><br><code>src/secondary-chain/wormhole/CustomTokenWormhole.sol</code><br><code>src/secondary-chain/wormhole/GenericCustomTokenWormhole.sol</code><br><code>src/secondary-chain/wormhole/vbETH/WethWormhole.sol</code> |
| <a href="https://github.com/agglayer/vault-bridge/commit/950e64d4ead51a8ef911829ab8775a18533a8cca"><code>950e64d4ead51a8ef911829ab8775a18533a8cca</code></a> | November 25, 2025 | <code>src/etc/ERC20PermitUser.sol</code><br><code>src/etc/IAgglayerBridge.sol</code><br><code>src/etc/IBridgeMessageReceiver.sol</code><br><code>src/etc/IFiatTokenV2_2.sol</code><br><code>src/etc/IWETH9.sol</code><br><code>src/etc/IVaultBridgeTokenInitializer.sol</code><br><code>src/etc/InitializationCounterUpgradeable.sol</code><br><code>src/etc/Versioned.sol</code><br><code>src/primary-chain/MigrationManager.sol</code><br><code>src/primary-chain/VaultBridgeToken.sol</code><br><code>src/primary-chain/VaultBridgeTokenInitializer.sol</code><br><code>src/primary-chain/VaultBridgeTokenPart2.sol</code><br><code>src/primary-chain/ethereum/GenericVaultBridgeToken.sol</code><br><code>src/primary-chain/ethereum/vbETH/VbETH.sol</code><br><code>src/primary-chain/layerzero/NonDefaultOftAdapter.sol</code><br><code>src/secondary-chain/CustomToken.sol</code><br><code>src/secondary-chain/CustomTokenWethExtension.sol</code><br><code>src/secondary-chain/NativeConverter.sol</code><br><code>src/secondary-chain/agglayer/CustomTokenAgglayer.sol</code><br><code>src/secondary-chain/agglayer/GenericCustomTokenAgglayer.sol</code><br><code>src/secondary-chain/agglayer/GenericNativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/NativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbETH/WethAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbETH/WethNativeConverterAgglayer.sol</code><br><code>src/secondary-chain/agglayer/vbUSDC/bridged-usdc-standard/VbUsdcNativeConverterAgglayerBridgedUsdcStandard.sol</code><br><code>src/secondary-chain/layerzero/CustomTokenLayerZero.sol</code><br><code>src/secondary-chain/layerzero/GenericCustomTokenLayerZero.sol</code><br><code>src/secondary-chain/layerzero/NonDefaultMintBurnOftAdapter.sol</code><br><code>src/secondary-chain/layerzero/vbETH/WethLayerZero.sol</code><br><code>src/secondary-chain/polygon/CustomTokenPolygon.sol</code><br><code>src/secondary-chain/polygon/GenericCustomTokenPolygon.sol</code><br><code>src/secondary-chain/wormhole/CustomTokenWormhole.sol</code><br><code>src/secondary-chain/wormhole/GenericCustomTokenWormhole.sol</code><br><code>src/secondary-chain/wormhole/vbETH/WethWormhole.sol</code> |

## Katana SushiStaker Audit Report

- Report: [2026_02-bailsec-katana-sushistaker-audit.md](<reports/2026_02-bailsec-katana-sushistaker-audit.md>)
- Auditor: Bailsec
- Description: Bailsec manual review of the SushiStaker contract, which stakes SushiSwap V3 NonfungiblePositionManager LP positions and redirects their fees to a fee collector while KAT rewards are computed offchain via Merkl. The offchain reward accounting was out of scope.

### Repository: <a href="https://github.com/katana-network/sushi-v3-lp-staking-offchainAccounting"><code>katana-network/sushi-v3-lp-staking-offchainAccounting</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/katana-network/sushi-v3-lp-staking-offchainAccounting/commit/1790d736438d773c4f6963ef6baf24040025fd08"><code>1790d736438d773c4f6963ef6baf24040025fd08</code></a> | February 14, 2026 | <code>src/SushiStaker.sol</code> |
| <a href="https://github.com/katana-network/sushi-v3-lp-staking-offchainAccounting/commit/591e63878c626a20d2e97e3fd8947667f29431d2"><code>591e63878c626a20d2e97e3fd8947667f29431d2</code></a> | February 26, 2026 | <code>src/SushiStaker.sol</code> |
