# Audit source summary: morph

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Morph L2 Security Assessment (Comprehensive Report with Fix Review)

- Report: [2024_07-trailofbits-morph-l2-security-assessment-with-fix-review.md](<reports/2024_07-trailofbits-morph-l2-security-assessment-with-fix-review.md>)
- Auditor: Trail of Bits
- Date: 2024-07-18
- Description: Fifteen engineer-week Trail of Bits review (April 29 to June 28, 2024) of the Morph L2 stack: the L1/L2 contracts (staking, Rollup, messengers, message queue, withdrawal tree, governance) and L2 node in morph-l2/morph at 1f623e0e, the tx-submitter at 34a89218, and Morph&#x27;s go-ethereum (03fd4c3e) and tendermint (8ff3c98b) forks. A fix review (July 1 to 5, 2024) verified the fix pull requests, with TOB-MORPH-8 and TOB-MORPH-12 left unresolved.

### Repository: <a href="https://github.com/morph-l2/morph"><code>morph-l2/morph</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/morph-l2/morph/tree/1f623e0eaece566ef92a22615ab8ddff9bcee206/contracts/contracts"><code>1f623e0eaece566ef92a22615ab8ddff9bcee206</code></a> | April 29, 2024 | <code>contracts/contracts</code> (recursive directory)<br><code>contracts/contracts/L1/rollup/L1MessageQueueWithGasPriceOracle.sol</code><br><code>contracts/contracts/L1/rollup/Rollup.sol</code><br><code>contracts/contracts/L1/staking/L1Staking.sol</code><br><code>contracts/contracts/L2/staking/Distribute.sol</code><br><code>contracts/contracts/L2/staking/Gov.sol</code><br><code>contracts/contracts/L2/staking/L2Staking.sol</code><br><code>contracts/contracts/L2/system/L2TxFeeVault.sol</code><br><code>contracts/contracts/L2/system/MorphToken.sol</code><br><code>node</code> (recursive directory) (other) |
| <a href="https://github.com/morph-l2/morph/blob/737307a212af66ecd7720f72b78214d0a0184d95/contracts/contracts/l2/staking/Distribute.sol"><code>737307a212af66ecd7720f72b78214d0a0184d95</code></a> | May 13, 2024 | <code>contracts/contracts/l2/staking/Distribute.sol</code><br><code>contracts/contracts/l1/staking/L1Staking.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/e5d414db5fe43b1bdf0c2ccad4ab45cfc2186d7a/contracts/contracts/l2/staking/L2Staking.sol"><code>e5d414db5fe43b1bdf0c2ccad4ab45cfc2186d7a</code></a> | May 14, 2024 | <code>contracts/contracts/l2/staking/L2Staking.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/c9cee3c4cca9e80882b952c8c3f3c6c4fcc0f269/contracts/contracts/l2/staking/Distribute.sol"><code>c9cee3c4cca9e80882b952c8c3f3c6c4fcc0f269</code></a> | May 14, 2024 | <code>contracts/contracts/l2/staking/Distribute.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/950270a55a66d31be11acea821c0ecb9128f6f2d/contracts/contracts/l2/staking/Gov.sol"><code>950270a55a66d31be11acea821c0ecb9128f6f2d</code></a> | May 14, 2024 | <code>contracts/contracts/l2/staking/Gov.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/74276bdb7a3f3ed0a4a718361f5e473121db9e83/contracts/contracts/l1/rollup/Rollup.sol"><code>74276bdb7a3f3ed0a4a718361f5e473121db9e83</code></a> | May 14, 2024 | <code>contracts/contracts/l1/rollup/Rollup.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/49a022693ffc54415ed9085891cd2ce6b9c44619/contracts/contracts/l1/rollup/Rollup.sol"><code>49a022693ffc54415ed9085891cd2ce6b9c44619</code></a> | May 14, 2024 | <code>contracts/contracts/l1/rollup/Rollup.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/f444050c54cff3406d40cc2ddfcb247d78686984/contracts/contracts/l2/system/L2TxFeeVault.sol"><code>f444050c54cff3406d40cc2ddfcb247d78686984</code></a> | May 14, 2024 | <code>contracts/contracts/l2/system/L2TxFeeVault.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/39c368fb01febab79bac60f7c8a2fa371fe3e19b/contracts/contracts/l2/staking/L2Staking.sol"><code>39c368fb01febab79bac60f7c8a2fa371fe3e19b</code></a> | May 15, 2024 | <code>contracts/contracts/l2/staking/L2Staking.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/d33fa720878757d293c04093d978f3c237eca241/contracts/contracts/l2/staking/L2Staking.sol"><code>d33fa720878757d293c04093d978f3c237eca241</code></a> | May 15, 2024 | <code>contracts/contracts/l2/staking/L2Staking.sol</code><br><code>contracts/contracts/l2/staking/Distribute.sol</code><br><code>contracts/contracts/l2/system/MorphToken.sol</code> |
| <a href="https://github.com/morph-l2/morph/tree/34a892188644b8916907db154d9f16dc9d3912b0/tx-submitter"><code>34a892188644b8916907db154d9f16dc9d3912b0</code></a> | June 18, 2024 | <code>tx-submitter</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/morph-l2/go-ethereum"><code>morph-l2/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/morph-l2/go-ethereum/blob/03fd4c3e771de55015d913680e1cc0209cc92b10/miner/worker.go"><code>03fd4c3e771de55015d913680e1cc0209cc92b10</code></a> | April 29, 2024 | <code>miner/worker.go</code> (other) |
| <a href="https://github.com/morph-l2/go-ethereum/blob/060418ec4f28b18676cbc6926dd30d72101f7fe1/miner/morph_worker.go"><code>060418ec4f28b18676cbc6926dd30d72101f7fe1</code></a> | June 21, 2024 | <code>miner/morph_worker.go</code> (other) |

### Repository: <a href="https://github.com/morph-l2/tendermint"><code>morph-l2/tendermint</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Security Review For Morph L2 (Public Contest)

- Report: [2024_09-sherlock-morph-l2-contest.md](<reports/2024_09-sherlock-morph-l2-contest.md>)
- Auditor: Sherlock
- Date: 2024-09-23
- Description: Sherlock public contest (September 2 to 23, 2024) of the 54 Morph L1 and L2 contracts (Rollup, L1Staking, cross-domain messengers, gateways, L2 staking, governance and system contracts, and libraries) in morph-l2/morph at commit 22ca805e, with a final commit c56fb938 after fixes. It reported 2 High and 11 Medium issues, all fixed or acknowledged.

### Repository: <a href="https://github.com/morph-l2/morph"><code>morph-l2/morph</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/morph-l2/morph/blob/22ca805e2d09c9d0bddb3e8a52ddd7d3435ce769/contracts/contracts/l1/L1CrossDomainMessenger.sol"><code>22ca805e2d09c9d0bddb3e8a52ddd7d3435ce769</code></a> | August 29, 2024 | <code>contracts/contracts/l1/L1CrossDomainMessenger.sol</code><br><code>contracts/contracts/l1/gateways/EnforcedTxGateway.sol</code><br><code>contracts/contracts/l1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1ETHGateway.sol</code><br><code>contracts/contracts/l1/gateways/L1GatewayRouter.sol</code><br><code>contracts/contracts/l1/gateways/L1ReverseCustomGateway.sol</code><br><code>contracts/contracts/l1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1WETHGateway.sol</code><br><code>contracts/contracts/l1/gateways/usdc/L1USDCGateway.sol</code><br><code>contracts/contracts/l1/rollup/L1MessageQueueWithGasPriceOracle.sol</code><br><code>contracts/contracts/l1/rollup/MultipleVersionRollupVerifier.sol</code><br><code>contracts/contracts/l1/rollup/Rollup.sol</code><br><code>contracts/contracts/l1/staking/L1Staking.sol</code><br><code>contracts/contracts/l2/L2CrossDomainMessenger.sol</code><br><code>contracts/contracts/l2/gateways/L2CustomERC20Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2ERC20Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2ERC721Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2ETHGateway.sol</code><br><code>contracts/contracts/l2/gateways/L2GatewayRouter.sol</code><br><code>contracts/contracts/l2/gateways/L2ReverseCustomGateway.sol</code><br><code>contracts/contracts/l2/gateways/L2StandardERC20Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2WETHGateway.sol</code><br><code>contracts/contracts/l2/gateways/L2WithdrawLockERC20Gateway.sol</code><br><code>contracts/contracts/l2/gateways/usdc/L2USDCGateway.sol</code><br><code>contracts/contracts/l2/staking/Distribute.sol</code><br><code>contracts/contracts/l2/staking/Gov.sol</code><br><code>contracts/contracts/l2/staking/L2Staking.sol</code><br><code>contracts/contracts/l2/staking/Record.sol</code><br><code>contracts/contracts/l2/staking/Sequencer.sol</code><br><code>contracts/contracts/l2/system/GasPriceOracle.sol</code><br><code>contracts/contracts/l2/system/L2ToL1MessagePasser.sol</code><br><code>contracts/contracts/l2/system/L2TxFeeVault.sol</code><br><code>contracts/contracts/l2/system/MorphToken.sol</code><br><code>contracts/contracts/l2/system/WrappedEther.sol</code><br><code>contracts/contracts/libraries/CrossDomainMessenger.sol</code><br><code>contracts/contracts/libraries/External.sol</code><br><code>contracts/contracts/libraries/codec/BatchHeaderCodecV0.sol</code><br><code>contracts/contracts/libraries/codec/ChunkCodecV0.sol</code><br><code>contracts/contracts/libraries/common/AddressAliasHelper.sol</code><br><code>contracts/contracts/libraries/common/OwnableBase.sol</code><br><code>contracts/contracts/libraries/common/Tree.sol</code><br><code>contracts/contracts/libraries/common/Types.sol</code><br><code>contracts/contracts/libraries/common/Verify.sol</code><br><code>contracts/contracts/libraries/common/Whitelist.sol</code><br><code>contracts/contracts/libraries/gateway/GatewayBase.sol</code><br><code>contracts/contracts/libraries/staking/Staking.sol</code><br><code>contracts/contracts/libraries/token/MorphStandardERC20.sol</code><br><code>contracts/contracts/libraries/token/MorphStandardERC20Factory.sol</code><br><code>contracts/contracts/libraries/verifier/RollupVerifier.sol</code><br><code>contracts/contracts/libraries/verifier/ZkEvmVerifierV1.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/44551ef9e6caea73e0a2493a29c98d4bd8d159cf/contracts/contracts/l2/staking/Distribute.sol"><code>44551ef9e6caea73e0a2493a29c98d4bd8d159cf</code></a> | September 9, 2024 | <code>contracts/contracts/l2/staking/Distribute.sol</code><br><code>contracts/contracts/l2/staking/L2Staking.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/de5c880f37db19f25cd9ee68d996ec03cef65514/contracts/contracts/l1/rollup/Rollup.sol"><code>de5c880f37db19f25cd9ee68d996ec03cef65514</code></a> | September 29, 2024 | <code>contracts/contracts/l1/rollup/Rollup.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/a6e044a7dd326856d01887ff6583d7a202983b57/contracts/contracts/l1/gateways/L1ReverseCustomGateway.sol"><code>a6e044a7dd326856d01887ff6583d7a202983b57</code></a> | October 8, 2024 | <code>contracts/contracts/l1/gateways/L1ReverseCustomGateway.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/2d29b175034d9da9f0ca8fe320586e6114a1f4e7/contracts/contracts/l1/rollup/Rollup.sol"><code>2d29b175034d9da9f0ca8fe320586e6114a1f4e7</code></a> | October 8, 2024 | <code>contracts/contracts/l1/rollup/Rollup.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/47fb39eca6e4c39c38aaf39a57bbb7466fcd8d99/contracts/contracts/l1/rollup/Rollup.sol"><code>47fb39eca6e4c39c38aaf39a57bbb7466fcd8d99</code></a> | October 15, 2024 | <code>contracts/contracts/l1/rollup/Rollup.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/cb54ba2583f606153a46dab1d937496f1744889f/contracts/contracts/l1/rollup/Rollup.sol"><code>cb54ba2583f606153a46dab1d937496f1744889f</code></a> | October 30, 2024 | <code>contracts/contracts/l1/rollup/Rollup.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/62fa3513445528019295098307dd95e7948a6e6d/contracts/contracts/l2/staking/Gov.sol"><code>62fa3513445528019295098307dd95e7948a6e6d</code></a> | November 14, 2024 | <code>contracts/contracts/l2/staking/Gov.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/846319a83f0f4716d8ae9fa59e56bfa243b26c69/contracts/contracts/l2/staking/Distribute.sol"><code>846319a83f0f4716d8ae9fa59e56bfa243b26c69</code></a> | November 15, 2024 | <code>contracts/contracts/l2/staking/Distribute.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/c56fb938a8a3da81d1e8979b2c49a9d7b3acc7ec/contracts/contracts/l1/L1CrossDomainMessenger.sol"><code>c56fb938a8a3da81d1e8979b2c49a9d7b3acc7ec</code></a> | November 15, 2024 | <code>contracts/contracts/l1/L1CrossDomainMessenger.sol</code><br><code>contracts/contracts/l1/gateways/EnforcedTxGateway.sol</code><br><code>contracts/contracts/l1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1ETHGateway.sol</code><br><code>contracts/contracts/l1/gateways/L1GatewayRouter.sol</code><br><code>contracts/contracts/l1/gateways/L1ReverseCustomGateway.sol</code><br><code>contracts/contracts/l1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/contracts/l1/gateways/L1WETHGateway.sol</code><br><code>contracts/contracts/l1/gateways/usdc/L1USDCGateway.sol</code><br><code>contracts/contracts/l1/rollup/L1MessageQueueWithGasPriceOracle.sol</code><br><code>contracts/contracts/l1/rollup/MultipleVersionRollupVerifier.sol</code><br><code>contracts/contracts/l1/rollup/Rollup.sol</code><br><code>contracts/contracts/l1/staking/L1Staking.sol</code><br><code>contracts/contracts/l2/L2CrossDomainMessenger.sol</code><br><code>contracts/contracts/l2/gateways/L2CustomERC20Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2ERC20Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2ERC721Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2ETHGateway.sol</code><br><code>contracts/contracts/l2/gateways/L2GatewayRouter.sol</code><br><code>contracts/contracts/l2/gateways/L2ReverseCustomGateway.sol</code><br><code>contracts/contracts/l2/gateways/L2StandardERC20Gateway.sol</code><br><code>contracts/contracts/l2/gateways/L2WETHGateway.sol</code><br><code>contracts/contracts/l2/gateways/L2WithdrawLockERC20Gateway.sol</code><br><code>contracts/contracts/l2/gateways/usdc/L2USDCGateway.sol</code><br><code>contracts/contracts/l2/staking/Distribute.sol</code><br><code>contracts/contracts/l2/staking/Gov.sol</code><br><code>contracts/contracts/l2/staking/L2Staking.sol</code><br><code>contracts/contracts/l2/staking/Record.sol</code><br><code>contracts/contracts/l2/staking/Sequencer.sol</code><br><code>contracts/contracts/l2/system/GasPriceOracle.sol</code><br><code>contracts/contracts/l2/system/L2ToL1MessagePasser.sol</code><br><code>contracts/contracts/l2/system/L2TxFeeVault.sol</code><br><code>contracts/contracts/l2/system/MorphToken.sol</code><br><code>contracts/contracts/l2/system/WrappedEther.sol</code><br><code>contracts/contracts/libraries/CrossDomainMessenger.sol</code><br><code>contracts/contracts/libraries/External.sol</code><br><code>contracts/contracts/libraries/codec/BatchHeaderCodecV0.sol</code><br><code>contracts/contracts/libraries/common/AddressAliasHelper.sol</code><br><code>contracts/contracts/libraries/common/OwnableBase.sol</code><br><code>contracts/contracts/libraries/common/Tree.sol</code><br><code>contracts/contracts/libraries/common/Types.sol</code><br><code>contracts/contracts/libraries/common/Verify.sol</code><br><code>contracts/contracts/libraries/common/Whitelist.sol</code><br><code>contracts/contracts/libraries/gateway/GatewayBase.sol</code><br><code>contracts/contracts/libraries/staking/Staking.sol</code><br><code>contracts/contracts/libraries/token/MorphStandardERC20.sol</code><br><code>contracts/contracts/libraries/token/MorphStandardERC20Factory.sol</code><br><code>contracts/contracts/libraries/verifier/RollupVerifier.sol</code><br><code>contracts/contracts/libraries/verifier/ZkEvmVerifierV1.sol</code> |

## Report for Morph Emerald upgrade

- Report: [2025_12-blocksec-morph-emerald-upgrade-audit.md](<reports/2025_12-blocksec-morph-emerald-upgrade-audit.md>)
- Auditor: BlockSec
- Date: 2025-12-23
- Description: BlockSec audit of the Morph Emerald upgrade, which adds AltFeeTx transactions for paying gas in registered ERC-20 tokens through the new L2TokenRegistry contract in morph-l2/morph and the matching transaction, fee, txpool, RPC and new precompile/opcode changes in morph-l2/go-ethereum. Only the changes from baseline Version 0 to Version 1 were in scope, with fixes verified at Version 2 (morph e64256ee, go-ethereum 64e9dcd0).

### Repository: <a href="https://github.com/morph-l2/morph"><code>morph-l2/morph</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/morph-l2/morph/blob/26233deddf5c77e811a73cfcfb797a2579ed9112/contracts/contracts/l2/system/L2TokenRegistry.sol"><code>26233deddf5c77e811a73cfcfb797a2579ed9112</code></a> | November 24, 2025 | <code>contracts/contracts/l2/system/L2TokenRegistry.sol</code> |
| <a href="https://github.com/morph-l2/morph/blob/e64256ee2109d4fcd3f4c6d90aec8abc46a751e7/contracts/contracts/l2/system/L2TokenRegistry.sol"><code>e64256ee2109d4fcd3f4c6d90aec8abc46a751e7</code></a> | December 17, 2025 | <code>contracts/contracts/l2/system/L2TokenRegistry.sol</code> |

### Repository: <a href="https://github.com/morph-l2/go-ethereum"><code>morph-l2/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/morph-l2/go-ethereum/compare/62fcaab9b7a732eea298f45d97234d718b522b13...42d39732bb88bef91c1743efcf10db40ae6b990a"><code>62fcaab9b7a732eea298f45d97234d718b522b13…42d39732bb88bef91c1743efcf10db40ae6b990a</code></a> (commit range) | October 31, 2025 – November 21, 2025 | <code>accounts/abi/bind/base.go</code> (other)<br><code>accounts/external/backend.go</code> (other)<br><code>core/types/receipt.go</code> (other)<br><code>core/state_processor.go</code> (other)<br><code>core/tx_list.go</code> (other)<br><code>core/tx_pool.go</code> (other)<br><code>core/types/transaction.go</code> (other)<br><code>internal/ethapi/api.go</code> (other)<br><code>internal/ethapi/transaction_args.go</code> (other)<br><code>light/txpool.go</code> (other)<br><code>core/state_transition.go</code> (other)<br><code>rollup/fees/rollup_fee.go</code> (other)<br><code>signer/core/apitypes/types.go</code> (other)<br><code>core/vm/contracts.go</code> (other)<br><code>core/vm/eips.go</code> (other)<br><code>core/vm/jump_table.go</code> (other)<br><code>core/vm/opcodes.go</code> (other) |
| <a href="https://github.com/morph-l2/go-ethereum/blob/42d39732bb88bef91c1743efcf10db40ae6b990a/core/types/alt_fee_tx.go"><code>42d39732bb88bef91c1743efcf10db40ae6b990a</code></a> | November 21, 2025 | <code>core/types/alt_fee_tx.go</code> (other)<br><code>core/types/token_fee.go</code> (other)<br><code>core/token_gas.go</code> (other)<br><code>rollup/fees/token_info.go</code> (other)<br><code>rollup/fees/rate.go</code> (other)<br><code>rollup/fees/token_transfer.go</code> (other)<br><code>crypto/secp256r1/verifier.go</code> (other) |
| <a href="https://github.com/morph-l2/go-ethereum/blob/64e9dcd01e673d9a25efc91090b81f46150cab3c/accounts/abi/bind/base.go"><code>64e9dcd01e673d9a25efc91090b81f46150cab3c</code></a> | December 22, 2025 | <code>accounts/abi/bind/base.go</code> (other)<br><code>accounts/external/backend.go</code> (other)<br><code>core/types/receipt.go</code> (other)<br><code>core/state_processor.go</code> (other)<br><code>core/tx_list.go</code> (other)<br><code>core/tx_pool.go</code> (other)<br><code>core/types/alt_fee_tx.go</code> (other)<br><code>core/types/token_fee.go</code> (other)<br><code>core/types/transaction.go</code> (other)<br><code>internal/ethapi/api.go</code> (other)<br><code>internal/ethapi/transaction_args.go</code> (other)<br><code>light/txpool.go</code> (other)<br><code>core/state_transition.go</code> (other)<br><code>core/token_gas.go</code> (other)<br><code>rollup/fees/token_info.go</code> (other)<br><code>rollup/fees/rate.go</code> (other)<br><code>rollup/fees/rollup_fee.go</code> (other)<br><code>rollup/fees/token_transfer.go</code> (other)<br><code>signer/core/apitypes/types.go</code> (other)<br><code>core/vm/contracts.go</code> (other)<br><code>crypto/secp256r1/verifier.go</code> (other)<br><code>core/vm/eips.go</code> (other)<br><code>core/vm/jump_table.go</code> (other)<br><code>core/vm/opcodes.go</code> (other) |

## Irrelevant reports

### morph-l2/go-ethereum Blockchain Security Audit Report

- Report: [irrelevant/2024_03-slowmist-morph-go-ethereum-audit.md](<reports/irrelevant/2024_03-slowmist-morph-go-ethereum-audit.md>)
- Auditor: SlowMist
- Date: 2024-03-31
- Description: SlowMist audit (March 4 to 31, 2024) of Morph&#x27;s go-ethereum fork on the eip4844 branch (commits 523eaf60 to c7c40645), covering the L2 consensus engine, rawdb accessors, L1 message and batch types, the catalyst L2 engine API, clients and the miner. The entire scope is offchain execution-client software, with no onchain contracts or circuits reviewed.

### morph-l2/tendermint Blockchain Security Audit Report

- Report: [irrelevant/2024_03-slowmist-morph-tendermint-audit.md](<reports/irrelevant/2024_03-slowmist-morph-tendermint-audit.md>)
- Auditor: SlowMist
- Date: 2024-03-31
- Description: SlowMist audit (March 4 to 31, 2024) of Morph&#x27;s tendermint fork on the layer2 branch (commits f7cf181d to a0e8684b), covering consensus, block sync, BLS signatures, configuration and the l2node interface. The entire scope is offchain consensus/sequencer node software.

### Morphl2 LRTDepositV1 Smart Contract Security Audit Report

- Report: [irrelevant/2024_06-slowmist-morph-lrt-deposit-v1-audit.md](<reports/irrelevant/2024_06-slowmist-morph-lrt-deposit-v1-audit.md>)
- Auditor: SlowMist
- Date: 2024-06-26
- Description: SlowMist audit (June 24 to 26, 2024) of the LRTDepositV1.sol pre-deposit contract (ETH, LST and ERC20 deposits with cross-chain forwarding) at commits e2e2651c to 2d190933, which was not deployed at the time of the report. The only scoped repository, morph-l2/LRT-Deposit, is not publicly accessible, and the contract is a deposit campaign contract rather than part of the rollup system.

### Eip-7702 implement of morph-l2 Blockchain Security Audit Report

- Report: [irrelevant/2025_10-slowmist-morph-eip-7702-audit.md](<reports/irrelevant/2025_10-slowmist-morph-eip-7702-audit.md>)
- Auditor: SlowMist
- Date: 2025-10-16
- Description: SlowMist audit (October 10 to 16, 2025), commissioned by the Bitget Wallet team, of the EIP-7702 implementation in morph-l2/go-ethereum pull request #196 (state, transaction pool, transaction types and state transition). The entire scope is offchain execution-client software.

### Report for Morph Reth

- Report: [irrelevant/2026_06-blocksec-morph-reth-audit.md](<reports/irrelevant/2026_06-blocksec-morph-reth-audit.md>)
- Auditor: BlockSec
- Date: 2026-06-23
- Description: BlockSec audit of morph-reth, Morph&#x27;s Rust execution client built on Reth and Revm, limited to ten files in the revm, primitives, txpool, rpc and engine-api crates (MorphTx handling, ERC20 token fee payment, pool validation and Engine API block assembly) at versions ac2e0351 and f60c2b2b. The entire scope is offchain execution-client software.
