# Audit source summary: scroll

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps.

## Scroll zkEVM - ZK Circuit Security Assessment

- Report: [zellic-kalos-scroll-zkevm-circuits-part1.md](<reports/zellic-kalos-scroll-zkevm-circuits-part1.md>)
- Auditor: Zellic and KALOS
- Date: 2023-05-16
- Description: Zero-knowledge circuit security assessment by Zellic and KALOS of Scroll&#x27;s zkEVM halo2 circuits, covering the Poseidon hash circuit, the bytecode circuit and its Poseidon-hash integration, and the MulAdd, comparator and exponentiation gadgets. The report states only the remediation commits, so the initially audited revision is unknown.

### Repository: <a href="https://github.com/scroll-tech/poseidon-circuit"><code>scroll-tech/poseidon-circuit</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/poseidon-circuit/blob/912f5ed2c6cacd64a0006e868e3cb4b624acc019/src/hash.rs"><code>912f5ed2c6cacd64a0006e868e3cb4b624acc019</code></a> | June 12, 2023 | <code>src/hash.rs</code> |

### Repository: <a href="https://github.com/scroll-tech/zkevm-circuits"><code>scroll-tech/zkevm-circuits</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/e8aecb68ccd87759dc4ea46e2cec9649a0803f5b/zkevm-circuits/src/bytecode_circuit/circuit/to_poseidon_hash.rs"><code>e8aecb68ccd87759dc4ea46e2cec9649a0803f5b</code></a> | May 22, 2023 | <code>zkevm-circuits/src/bytecode_circuit/circuit/to_poseidon_hash.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/d5ca004bea423cc94b6e7712ba6b26cb65bcaa0d/gadgets/src/mul_add.rs"><code>d5ca004bea423cc94b6e7712ba6b26cb65bcaa0d</code></a> | August 9, 2023 | <code>gadgets/src/mul_add.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/9b46ddbf01393ad845e48dea77de55b9358074da/zkevm-circuits/src/exp_circuit.rs"><code>9b46ddbf01393ad845e48dea77de55b9358074da</code></a> | August 10, 2023 | <code>zkevm-circuits/src/exp_circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/267865d3cde0b7427a4996ea0598f13148944e35/zkevm-circuits/src/bytecode_circuit/circuit.rs"><code>267865d3cde0b7427a4996ea0598f13148944e35</code></a> | August 14, 2023 | <code>zkevm-circuits/src/bytecode_circuit/circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/b20bed27e0a1b1345c125a2975875be555d2dff9/gadgets/src/mul_add.rs"><code>b20bed27e0a1b1345c125a2975875be555d2dff9</code></a> | August 16, 2023 | <code>gadgets/src/mul_add.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/21f887d2ce44c4dc42c5ccae80c5ed94a6930954/gadgets/src/comparator.rs"><code>21f887d2ce44c4dc42c5ccae80c5ed94a6930954</code></a> | September 23, 2023 | <code>gadgets/src/comparator.rs</code> |

## Scroll Tech Smart Contract Security Assessment

- Report: [zellic-scroll-bridge-rollup-audit-2023-05.md](<reports/zellic-scroll-bridge-rollup-audit-2023-05.md>)
- Auditor: Zellic
- Date: 2023-05-26
- Description: Zellic smart contract security assessment (March 20 to April 3, 2023) of the Scroll L1 and L2 messenger, gateway, rollup and library contracts under contracts/src of scroll-tech/scroll. Four findings were reported, three of medium impact and none critical.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/cb6a609366e5f6b808dfd9bba01a1c7c6e07f6fa/contracts/src/External.sol"><code>cb6a609366e5f6b808dfd9bba01a1c7c6e07f6fa</code></a> | March 20, 2023 | <code>contracts/src/External.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1WETHGateway.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/L2GasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/ScrollChainCommitmentVerifier.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code><br><code>contracts/src/L2/gateways/L2CustomERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC721Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code><br><code>contracts/src/L2/gateways/L2GatewayRouter.sol</code><br><code>contracts/src/L2/gateways/L2StandardERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2WETHGateway.sol</code><br><code>contracts/src/L2/predeploys/L1BlockContainer.sol</code><br><code>contracts/src/L2/predeploys/L1GasPriceOracle.sol</code><br><code>contracts/src/L2/predeploys/L2MessageQueue.sol</code><br><code>contracts/src/L2/predeploys/WETH9.sol</code><br><code>contracts/src/libraries/ScrollMessengerBase.sol</code><br><code>contracts/src/libraries/common/AddressAliasHelper.sol</code><br><code>contracts/src/libraries/common/AppendOnlyMerkleTree.sol</code><br><code>contracts/src/libraries/common/OwnableBase.sol</code><br><code>contracts/src/libraries/constants/ScrollConstants.sol</code><br><code>contracts/src/libraries/constants/ScrollPredeploy.sol</code><br><code>contracts/src/libraries/gateway/ScrollGatewayBase.sol</code><br><code>contracts/src/libraries/oracle/SimpleGasOracle.sol</code><br><code>contracts/src/libraries/token/ScrollStandardERC20Factory.sol</code><br><code>contracts/src/libraries/token/ScrollStandardERC20.sol</code><br><code>contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol</code><br><code>contracts/src/libraries/verifier/RollupVerifier.sol</code><br><code>contracts/src/libraries/verifier/WithdrawTrieVerifier.sol</code><br><code>contracts/src/libraries/verifier/ZkTrieVerifier.sol</code><br><code>contracts/src/mocks/MockERC20.sol</code><br><code>contracts/src/mocks/MockPatriciaMerkleTrieVerifier.sol</code><br><code>contracts/src/mocks/MockZkTrieVerifier.sol</code><br><code>contracts/src/test/mocks/MockScrollChain.sol</code><br><code>contracts/src/test/mocks/MockScrollMessenger.sol</code><br><code>contracts/src/test/mocks/tokens/FeeOnTransferToken.sol</code><br><code>contracts/src/test/mocks/tokens/TransferReentrantToken.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/7fb4d1d3f6f9f8903258ca6ca3a267c77c5d4444/contracts/src/L2/gateways/L2ERC1155Gateway.sol"><code>7fb4d1d3f6f9f8903258ca6ca3a267c77c5d4444</code></a> | March 21, 2023 | <code>contracts/src/L2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC721Gateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/bfe29b41c178208092c53566ddc67c6d2fdfde23/contracts/src/L1/gateways/L1ETHGateway.sol"><code>bfe29b41c178208092c53566ddc67c6d2fdfde23</code></a> | April 20, 2023 | <code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/2728cfa9de5f403b491ef5b95700765fa2130d49/contracts/src/L1/gateways/L1ERC1155Gateway.sol"><code>2728cfa9de5f403b491ef5b95700765fa2130d49</code></a> | April 27, 2023 | <code>contracts/src/L1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC721Gateway.sol</code> |

## Scroll Layer 1 Audit

- Report: [openzeppelin-scroll-layer1-audit-2023-07.md](<reports/openzeppelin-scroll-layer1-audit-2023-07.md>)
- Auditor: OpenZeppelin
- Date: 2023-07-18
- Description: OpenZeppelin audit of Scroll&#x27;s Layer 1 contracts (L1ScrollMessenger, the L1 gateways and enforced transaction gateway, the rollup and message queue contracts and supporting libraries) in scroll-tech/scroll at commit 3bc8a3f of the develop branch.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/External.sol"><code>3bc8a3f5c6ac816ddffadca41024331dcf4d3064</code></a> | May 22, 2023 | <code>contracts/src/External.sol</code><br><code>contracts/src/L1/IL1ScrollMessenger.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L1/gateways/EnforcedTxGateway.sol</code><br><code>contracts/src/L1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1WETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/src/L1/rollup/IL1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/IL2GasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/IScrollChain.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/L2GasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/L2/gateways/IL2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/IL2ERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/IL2ERC721Gateway.sol</code><br><code>contracts/src/L2/gateways/IL2ETHGateway.sol</code><br><code>contracts/src/L2/gateways/IL2GatewayRouter.sol</code><br><code>contracts/src/interfaces/IERC20Metadata.sol</code><br><code>contracts/src/interfaces/IWETH.sol</code><br><code>contracts/src/libraries/FeeVault.sol</code><br><code>contracts/src/libraries/IScrollMessenger.sol</code><br><code>contracts/src/libraries/ScrollMessengerBase.sol</code><br><code>contracts/src/libraries/callbacks/IERC677Receiver.sol</code><br><code>contracts/src/libraries/callbacks/IScrollGatewayCallback.sol</code><br><code>contracts/src/libraries/codec/BatchHeaderV0Codec.sol</code><br><code>contracts/src/libraries/codec/ChunkCodec.sol</code><br><code>contracts/src/libraries/common/AddressAliasHelper.sol</code><br><code>contracts/src/libraries/common/IWhitelist.sol</code><br><code>contracts/src/libraries/constants/ScrollConstants.sol</code><br><code>contracts/src/libraries/gateway/IScrollGateway.sol</code><br><code>contracts/src/libraries/gateway/ScrollGatewayBase.sol</code><br><code>contracts/src/libraries/oracle/IGasOracle.sol</code><br><code>contracts/src/libraries/oracle/SimpleGasOracle.sol</code><br><code>contracts/src/libraries/token/IScrollERC1155.sol</code><br><code>contracts/src/libraries/token/IScrollERC20.sol</code><br><code>contracts/src/libraries/token/IScrollERC20Upgradeable.sol</code><br><code>contracts/src/libraries/token/IScrollERC721.sol</code><br><code>contracts/src/libraries/token/IScrollStandardERC20Factory.sol</code><br><code>contracts/src/libraries/token/ScrollStandardERC20.sol</code><br><code>contracts/src/libraries/token/ScrollStandardERC20Factory.sol</code><br><code>contracts/src/libraries/verifier/IRollupVerifier.sol</code><br><code>contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol</code><br><code>contracts/src/libraries/verifier/WithdrawTrieVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/55f5857aebf1ae0453d3f45a71fb9c4125877e93/contracts/src/L1/rollup/ScrollChain.sol"><code>55f5857aebf1ae0453d3f45a71fb9c4125877e93</code></a> | May 26, 2023 | <code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/libraries/codec/BatchHeaderV0Codec.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/9606c61f5e70d46fae9e4024b574790bc14ff671/contracts/src/L1/rollup/ScrollChain.sol"><code>9606c61f5e70d46fae9e4024b574790bc14ff671</code></a> | June 7, 2023 | <code>contracts/src/L1/rollup/ScrollChain.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/869111b04ee45976273aa5656e95eb639a9f05cf/contracts/src/L1/rollup/L1MessageQueue.sol"><code>869111b04ee45976273aa5656e95eb639a9f05cf</code></a> | June 12, 2023 | <code>contracts/src/L1/rollup/L1MessageQueue.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/b82dab5da35b863c2c95f892d9b3dc05d7cfc147/contracts/src/L1/rollup/ScrollChain.sol"><code>b82dab5da35b863c2c95f892d9b3dc05d7cfc147</code></a> | June 12, 2023 | <code>contracts/src/L1/rollup/ScrollChain.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/76d4230571da5909499ace4c7bc90ad31a721325/contracts/src/L1/L1ScrollMessenger.sol"><code>76d4230571da5909499ace4c7bc90ad31a721325</code></a> | July 4, 2023 | <code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1WETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/2f76991ddbddcf92bef5fbd0103124e6636c6f2c/contracts/src/L1/gateways/L1StandardERC20Gateway.sol"><code>2f76991ddbddcf92bef5fbd0103124e6636c6f2c</code></a> | July 6, 2023 | <code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/a8832bfb68a1e2c4a6b1b5d881cac34cb398830d/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol"><code>a8832bfb68a1e2c4a6b1b5d881cac34cb398830d</code></a> | July 6, 2023 | <code>contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/22b30bac6d6611c585d16a56bf8682c0b094cabe/contracts/src/libraries/verifier/WithdrawTrieVerifier.sol"><code>22b30bac6d6611c585d16a56bf8682c0b094cabe</code></a> | July 6, 2023 | <code>contracts/src/libraries/verifier/WithdrawTrieVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/7e8bf3a7c49c4aa355a3060c3e11020e505badc8/contracts/src/L1/rollup/IScrollChain.sol"><code>7e8bf3a7c49c4aa355a3060c3e11020e505badc8</code></a> | July 7, 2023 | <code>contracts/src/L1/rollup/IScrollChain.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/baa48b7018b2b4ca4ec39a94bbdfae82fabf74f5/contracts/src/libraries/FeeVault.sol"><code>baa48b7018b2b4ca4ec39a94bbdfae82fabf74f5</code></a> | July 7, 2023 | <code>contracts/src/libraries/FeeVault.sol</code><br><code>contracts/src/libraries/token/IScrollStandardERC20Factory.sol</code><br><code>contracts/src/libraries/token/ScrollStandardERC20Factory.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/af8a4c9ac808bf70e27c4d3ef4ede18ede565075/contracts/src/L1/gateways/EnforcedTxGateway.sol"><code>af8a4c9ac808bf70e27c4d3ef4ede18ede565075</code></a> | July 10, 2023 | <code>contracts/src/L1/gateways/EnforcedTxGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/23958838c51170ca7e680ff405f3c68dfee4e7b9/contracts/src/L1/gateways/L1ERC20Gateway.sol"><code>23958838c51170ca7e680ff405f3c68dfee4e7b9</code></a> | July 10, 2023 | <code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/c7de22d1c1f628ed742c8c53217a17a269518354/contracts/src/L1/rollup/ScrollChain.sol"><code>c7de22d1c1f628ed742c8c53217a17a269518354</code></a> | July 11, 2023 | <code>contracts/src/L1/rollup/ScrollChain.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/c89704c5713f31083ba8f709bd74053e92d71708/contracts/src/libraries/ScrollMessengerBase.sol"><code>c89704c5713f31083ba8f709bd74053e92d71708</code></a> | July 12, 2023 | <code>contracts/src/libraries/ScrollMessengerBase.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/d1b77199a9306a051569c69ff8f55a4f48cc2f1e/contracts/src/libraries/token/ScrollStandardERC20.sol"><code>d1b77199a9306a051569c69ff8f55a4f48cc2f1e</code></a> | July 12, 2023 | <code>contracts/src/libraries/token/ScrollStandardERC20.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/6d88f92931dd55cc6b9230f0f433f5686b6fce85/contracts/src/libraries/codec/BatchHeaderV0Codec.sol"><code>6d88f92931dd55cc6b9230f0f433f5686b6fce85</code></a> | July 17, 2023 | <code>contracts/src/libraries/codec/BatchHeaderV0Codec.sol</code><br><code>contracts/src/libraries/codec/ChunkCodec.sol</code> |

## Scroll Phase 2 Audit

- Report: [openzeppelin-scroll-layer2-audit-2023-07.md](<reports/openzeppelin-scroll-layer2-audit-2023-07.md>)
- Auditor: OpenZeppelin
- Date: 2023-07-21
- Description: OpenZeppelin phase 2 audit of Scroll&#x27;s Layer 2 contracts (L2 gateways, L2 messenger and predeploys) together with the L1 gateway interfaces, in scroll-tech/scroll at commit 3bc8a3f.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/IL1ERC1155Gateway.sol"><code>3bc8a3f5c6ac816ddffadca41024331dcf4d3064</code></a> | May 22, 2023 | <code>contracts/src/L1/gateways/IL1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/IL1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/IL1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/IL1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/IL1GatewayRouter.sol</code><br><code>contracts/src/L2/gateways/L2CustomERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC721Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code><br><code>contracts/src/L2/gateways/L2StandardERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2WETHGateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2GatewayRouter.sol</code><br><code>contracts/src/L2/predeploys/IL1BlockContainer.sol</code><br><code>contracts/src/L2/predeploys/IL1GasPriceOracle.sol</code><br><code>contracts/src/L2/predeploys/L1BlockContainer.sol</code><br><code>contracts/src/L2/predeploys/L1GasPriceOracle.sol</code><br><code>contracts/src/L2/predeploys/L2MessageQueue.sol</code><br><code>contracts/src/L2/predeploys/L2TxFeeVault.sol</code><br><code>contracts/src/L2/predeploys/WETH9.sol</code><br><code>contracts/src/L2/predeploys/Whitelist.sol</code><br><code>contracts/src/L2/IL2ScrollMessenger.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code><br><code>contracts/src/libraries/common/AppendOnlyMerkleTree.sol</code><br><code>contracts/src/libraries/common/OwnableBase.sol</code><br><code>contracts/src/libraries/constants/ScrollPredeploy.sol</code><br><code>contracts/src/libraries/token/IScrollERC1155.sol</code><br><code>contracts/src/libraries/token/IScrollERC721.sol</code><br><code>contracts/src/libraries/FeeVault.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/0df7531cebe208e2d3e9d5b668ef68141e80f2db/contracts/src/L2/predeploys/WETH9.sol"><code>0df7531cebe208e2d3e9d5b668ef68141e80f2db</code></a> | June 12, 2023 | <code>contracts/src/L2/predeploys/WETH9.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/94db3ab540479515203fc4d3cf467f7c542dfe25/contracts/src/L2/L2ScrollMessenger.sol"><code>94db3ab540479515203fc4d3cf467f7c542dfe25</code></a> | June 12, 2023 | <code>contracts/src/L2/L2ScrollMessenger.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/23958838c51170ca7e680ff405f3c68dfee4e7b9/contracts/src/L2/gateways/L2ERC20Gateway.sol"><code>23958838c51170ca7e680ff405f3c68dfee4e7b9</code></a> | July 10, 2023 | <code>contracts/src/L2/gateways/L2ERC20Gateway.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/89814bde4c28901839b659409ed55b57af4ade23/contracts/src/libraries/common/AppendOnlyMerkleTree.sol"><code>89814bde4c28901839b659409ed55b57af4ade23</code></a> | July 10, 2023 | <code>contracts/src/libraries/common/AppendOnlyMerkleTree.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/85850f1d977827c09911c259906ffd88e695947c/contracts/src/L2/predeploys/WrappedEther.sol"><code>85850f1d977827c09911c259906ffd88e695947c</code></a> | July 12, 2023 | <code>contracts/src/L2/predeploys/WrappedEther.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/90cf7b7af59e87134d71947034788b4c81709fbf/contracts/src/L2/gateways/L2GatewayRouter.sol"><code>90cf7b7af59e87134d71947034788b4c81709fbf</code></a> | July 17, 2023 | <code>contracts/src/L2/gateways/L2GatewayRouter.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/6959d82372df0ff48ce1bdcdbffbb55138e14639/contracts/src/L2/predeploys/L1BlockContainer.sol"><code>6959d82372df0ff48ce1bdcdbffbb55138e14639</code></a> | July 17, 2023 | <code>contracts/src/L2/predeploys/L1BlockContainer.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/dd9d880c2ae867ec2eb21f4ac3f42a902d72f929/contracts/src/L2/predeploys/L2MessageQueue.sol"><code>dd9d880c2ae867ec2eb21f4ac3f42a902d72f929</code></a> | July 17, 2023 | <code>contracts/src/L2/predeploys/L2MessageQueue.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/58ee807c3ab96bd9325d997ce9e79b86f42ca3a8/contracts/src/L2/L2ScrollMessenger.sol"><code>58ee807c3ab96bd9325d997ce9e79b86f42ca3a8</code></a> | July 17, 2023 | <code>contracts/src/L2/L2ScrollMessenger.sol</code> |

## Scroll zkEVM - Part 2 - ZK Circuit Security Assessment

- Report: [zellic-kalos-scroll-zkevm-circuits-part2.md](<reports/zellic-kalos-scroll-zkevm-circuits-part2.md>)
- Auditor: Zellic and KALOS
- Date: 2023-07-31
- Description: Second zero-knowledge circuit assessment by Zellic and KALOS of Scroll&#x27;s zkEVM circuits, focused on the RLP finite-state-machine circuit, the transaction and public-input circuits and the MPT circuit gadgets in scroll-tech/mpt-circuit. The report states only the remediation commits, so the initially audited revision is unknown.

### Repository: <a href="https://github.com/scroll-tech/zkevm-circuits"><code>scroll-tech/zkevm-circuits</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/2565e254fc7d42184aaade3d8ee144fdc79fdd10/zkevm-circuits/src/tx_circuit.rs"><code>2565e254fc7d42184aaade3d8ee144fdc79fdd10</code></a> | July 12, 2023 | <code>zkevm-circuits/src/tx_circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/d0e7a07e8af25220623564ef1c3ed101ce63220e/zkevm-circuits/src/rlp_circuit_fsm.rs"><code>d0e7a07e8af25220623564ef1c3ed101ce63220e</code></a> | August 7, 2023 | <code>zkevm-circuits/src/rlp_circuit_fsm.rs</code><br><code>zkevm-circuits/src/tx_circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/2e422878e0d78f769e08f0b1ad1275ee039362d5/zkevm-circuits/src/rlp_circuit_fsm.rs"><code>2e422878e0d78f769e08f0b1ad1275ee039362d5</code></a> | August 16, 2023 | <code>zkevm-circuits/src/rlp_circuit_fsm.rs</code><br><code>zkevm-circuits/src/tx_circuit.rs</code><br><code>zkevm-circuits/src/pi_circuit.rs</code><br><code>zkevm-circuits/src/witness/tx.rs</code> |

### Repository: <a href="https://github.com/scroll-tech/mpt-circuit"><code>scroll-tech/mpt-circuit</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/753d2f9112f82828180d49d4974495ce4cab7c33/src/types.rs"><code>753d2f9112f82828180d49d4974495ce4cab7c33</code></a> | July 26, 2023 | <code>src/types.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/9aeff02e4d86e9bbecd0e420ebd3ed13a824e094/src/gadgets/mpt_update.rs"><code>9aeff02e4d86e9bbecd0e420ebd3ed13a824e094</code></a> | August 14, 2023 | <code>src/gadgets/mpt_update.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/9bd18782c19b5f5b2a2410b80f1ace6cd9637dcb/src/gadgets/one_hot.rs"><code>9bd18782c19b5f5b2a2410b80f1ace6cd9637dcb</code></a> | August 23, 2023 | <code>src/gadgets/one_hot.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/34af759e94f4b342507778145e7ae364a6d5566e/src/constraint_builder/binary_column.rs"><code>34af759e94f4b342507778145e7ae364a6d5566e</code></a> | August 23, 2023 | <code>src/constraint_builder/binary_column.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/3ab166a4a62329ec42d44cd63fc9563ff29dea4e/src/gadgets/mpt_update.rs"><code>3ab166a4a62329ec42d44cd63fc9563ff29dea4e</code></a> | August 23, 2023 | <code>src/gadgets/mpt_update.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/004fcddb53a86a62ba94f1f7fe8c04b315f23779/src/gadgets/mpt_update.rs"><code>004fcddb53a86a62ba94f1f7fe8c04b315f23779</code></a> | August 23, 2023 | <code>src/gadgets/mpt_update.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/f9ff6bb56b45da3ad219e4e01c283bedd478ef14/src/gadgets/mpt_update.rs"><code>f9ff6bb56b45da3ad219e4e01c283bedd478ef14</code></a> | August 23, 2023 | <code>src/gadgets/mpt_update.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/f89e2d58990377299e17cca45bf1c280ff708b5f/src/gadgets/byte_representation.rs"><code>f89e2d58990377299e17cca45bf1c280ff708b5f</code></a> | August 23, 2023 | <code>src/gadgets/byte_representation.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/ef64eb52548946a0dd7f0ee83ce71ed8d460c405/src/gadgets/mpt_update.rs"><code>ef64eb52548946a0dd7f0ee83ce71ed8d460c405</code></a> | August 24, 2023 | <code>src/gadgets/mpt_update.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/c8f9c7f39d476e48b2712f5caaf3a98327ee2098/src/gadgets/byte_representation.rs"><code>c8f9c7f39d476e48b2712f5caaf3a98327ee2098</code></a> | August 24, 2023 | <code>src/gadgets/byte_representation.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/ac3f8d897c9189d3a166471153166372ac366192/src/gadgets/mpt_update.rs"><code>ac3f8d897c9189d3a166471153166372ac366192</code></a> | August 29, 2023 | <code>src/gadgets/mpt_update.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/e4f5df31e9b3005bb5977c11aa0c3b262cfe3269/src/gadgets/mpt_update.rs"><code>e4f5df31e9b3005bb5977c11aa0c3b262cfe3269</code></a> | September 11, 2023 | <code>src/gadgets/mpt_update.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/b5ea508b6100f487185fc0ae35aa5bc8e61175a0/src/gadgets/mpt_update.rs"><code>b5ea508b6100f487185fc0ae35aa5bc8e61175a0</code></a> | September 23, 2023 | <code>src/gadgets/mpt_update.rs</code> |

## Scroll GasSwap, Multiple Verifier, Wrapped Ether and Diff Audit

- Report: [openzeppelin-scroll-gasswap-multiverifier-weth-diff-audit-2023-08.md](<reports/openzeppelin-scroll-gasswap-multiverifier-weth-diff-audit-2023-08.md>)
- Auditor: OpenZeppelin
- Date: 2023-08-31
- Description: OpenZeppelin audit of the GasSwap contract, MultipleVersionRollupVerifier, the WrappedEther predeploy and the L1/L2 USDC gateways, plus a diff audit of the remaining bridge contracts, in scroll-tech/scroll at commit 2eb458c. Two high-severity issues were reported and acknowledged without a fix.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/compare/3bc8a3f5c6ac816ddffadca41024331dcf4d3064...2eb458cf4224d82fc56254e91e297a9ed261cefb"><code>3bc8a3f5c6ac816ddffadca41024331dcf4d3064…2eb458cf4224d82fc56254e91e297a9ed261cefb</code></a> (commit range) | May 22, 2023 – July 25, 2023 | <code>contracts/src/L1/gateways/EnforcedTxGateway.sol</code><br><code>contracts/src/L1/gateways/IL1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/IL1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/IL1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/IL1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/IL1GatewayRouter.sol</code><br><code>contracts/src/L1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1WETHGateway.sol</code><br><code>contracts/src/L1/rollup/IL1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/L1/IL1ScrollMessenger.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC721Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code><br><code>contracts/src/L2/predeploys/L1GasPriceOracle.sol</code><br><code>contracts/src/L2/IL2ScrollMessenger.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code><br><code>contracts/src/libraries/constants/ScrollConstants.sol</code><br><code>contracts/src/libraries/gateway/ScrollGatewayBase.sol</code><br><code>contracts/src/libraries/token/IScrollERC1155.sol</code><br><code>contracts/src/libraries/token/IScrollERC20.sol</code><br><code>contracts/src/libraries/token/IScrollERC721.sol</code><br><code>contracts/src/libraries/verifier/IRollupVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/2eb458cf4224d82fc56254e91e297a9ed261cefb/contracts/src/L1/gateways/usdc/L1USDCGateway.sol"><code>2eb458cf4224d82fc56254e91e297a9ed261cefb</code></a> | July 25, 2023 | <code>contracts/src/L1/gateways/usdc/L1USDCGateway.sol</code><br><code>contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol</code><br><code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code><br><code>contracts/src/L2/predeploys/WrappedEther.sol</code><br><code>contracts/src/gas-swap/GasSwap.sol</code><br><code>contracts/src/interfaces/IFiatToken.sol</code><br><code>contracts/src/libraries/callbacks/IMessageDropCallback.sol</code><br><code>contracts/src/libraries/token/IScrollERC1155Extension.sol</code><br><code>contracts/src/libraries/token/IScrollERC20Extension.sol</code><br><code>contracts/src/libraries/token/IScrollERC721Extension.sol</code><br><code>contracts/src/libraries/verifier/IZkEvmVerifier.sol</code><br><code>contracts/src/libraries/ScrollMessengerBase.sol</code><br><code>contracts/src/misc/Fallback.sol</code><br><code>contracts/src/External.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/b7a02fbe54cf14fb0149df520343bf0195e00c99/contracts/src/L1/gateways/IL1GatewayRouter.sol"><code>b7a02fbe54cf14fb0149df520343bf0195e00c99</code></a> | July 26, 2023 | <code>contracts/src/L1/gateways/IL1GatewayRouter.sol</code><br><code>contracts/src/L1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/L1/IL1ScrollMessenger.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC721Gateway.sol</code><br><code>contracts/src/L2/IL2ScrollMessenger.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/a798e4d52524ddc388e48f9b24d437ee0b3ad85d/contracts/src/libraries/ScrollMessengerBase.sol"><code>a798e4d52524ddc388e48f9b24d437ee0b3ad85d</code></a> | August 1, 2023 | <code>contracts/src/libraries/ScrollMessengerBase.sol</code><br><code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1WETHGateway.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code><br><code>contracts/src/libraries/gateway/ScrollGatewayBase.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/3e21edb752a57dad0c50feb1dfb8b86eda6465c8/contracts/src/L1/gateways/L1GatewayRouter.sol"><code>3e21edb752a57dad0c50feb1dfb8b86eda6465c8</code></a> | August 1, 2023 | <code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC721Gateway.sol</code><br><code>contracts/src/L2/predeploys/L1GasPriceOracle.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/7a26dbce9c0cd6b170702cd9a36ebf0d2453efc3/contracts/src/gas-swap/GasSwap.sol"><code>7a26dbce9c0cd6b170702cd9a36ebf0d2453efc3</code></a> | August 21, 2023 | <code>contracts/src/gas-swap/GasSwap.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/60de22bfea6cde7c7790b3a8914230d1ea0a70af/contracts/src/gas-swap/GasSwap.sol"><code>60de22bfea6cde7c7790b3a8914230d1ea0a70af</code></a> | August 21, 2023 | <code>contracts/src/gas-swap/GasSwap.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/8daae8f401d7806ec5910b8e6d9915bc60cc586f/contracts/src/gas-swap/GasSwap.sol"><code>8daae8f401d7806ec5910b8e6d9915bc60cc586f</code></a> | August 21, 2023 | <code>contracts/src/gas-swap/GasSwap.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/6527331f9ec01e536da328a91880dd16ce6b67e4/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol"><code>6527331f9ec01e536da328a91880dd16ce6b67e4</code></a> | August 21, 2023 | <code>contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/0d7d73ff1a6e463d58efe2073d1dbd590f5da0f1/contracts/src/L1/L1ScrollMessenger.sol"><code>0d7d73ff1a6e463d58efe2073d1dbd590f5da0f1</code></a> | August 21, 2023 | <code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/b933adb279290665c362f3d264dec52733d34348/contracts/src/L2/gateways/usdc/L2USDCGateway.sol"><code>b933adb279290665c362f3d264dec52733d34348</code></a> | August 22, 2023 | <code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/020d272bf3326e2a96c91af3f31b4200cc21c70a/contracts/src/L1/L1ScrollMessenger.sol"><code>020d272bf3326e2a96c91af3f31b4200cc21c70a</code></a> | August 22, 2023 | <code>contracts/src/L1/L1ScrollMessenger.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/51a74dd0fafcde21d7f4631d29ab625d802dc9d1/contracts/src/L2/L2ScrollMessenger.sol"><code>51a74dd0fafcde21d7f4631d29ab625d802dc9d1</code></a> | August 22, 2023 | <code>contracts/src/L2/L2ScrollMessenger.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/b73f7a9fa231f2350dcce9d07aa9030100103d06/contracts/src/gas-swap/GasSwap.sol"><code>b73f7a9fa231f2350dcce9d07aa9030100103d06</code></a> | August 25, 2023 | <code>contracts/src/gas-swap/GasSwap.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/ba98a1add3baa1c8e43238cd0c91edee7e0fa2e1/contracts/src/L1/gateways/L1ERC20Gateway.sol"><code>ba98a1add3baa1c8e43238cd0c91edee7e0fa2e1</code></a> | August 25, 2023 | <code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/f5e5de194a1311398b1121f1d7d40cedf43a45c5/contracts/src/L1/gateways/L1ETHGateway.sol"><code>f5e5de194a1311398b1121f1d7d40cedf43a45c5</code></a> | August 25, 2023 | <code>contracts/src/L1/gateways/L1ETHGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/4b8d9cef5140d3db4a7947ffa817b64f3a5719e9/contracts/src/L1/rollup/ScrollChain.sol"><code>4b8d9cef5140d3db4a7947ffa817b64f3a5719e9</code></a> | August 25, 2023 | <code>contracts/src/L1/rollup/ScrollChain.sol</code> |

## Scroll Smart Contract Security Assessment

- Report: [zellic-scroll-bridge-rollup-audit-2023-09.md](<reports/zellic-scroll-bridge-rollup-audit-2023-09.md>)
- Auditor: Zellic
- Date: 2023-09-07
- Description: Follow-up Zellic smart contract assessment of the Scroll contracts added or changed since the May 2023 review, including GasSwap, EnforcedTxGateway, MultipleVersionRollupVerifier, the L2 USDC gateway and the batch header and chunk codecs. Three findings were reported.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/2323dd0daa117bc9ce1f0e4a1c1c3bba4d661947/contracts/src/gas-swap/GasSwap.sol"><code>2323dd0daa117bc9ce1f0e4a1c1c3bba4d661947</code></a> | July 10, 2023 | <code>contracts/src/gas-swap/GasSwap.sol</code><br><code>contracts/src/L1/gateways/EnforcedTxGateway.sol</code><br><code>contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol</code><br><code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code><br><code>contracts/src/libraries/codec/BatchHeaderV0Codec.sol</code><br><code>contracts/src/libraries/codec/ChunkCodec.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1WETHGateway.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/L2GasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code><br><code>contracts/src/L2/gateways/L2StandardERC20Gateway.sol</code><br><code>contracts/src/libraries/gateway/ScrollGatewayBase.sol</code><br><code>contracts/src/libraries/verifier/RollupVerifier.sol</code><br><code>contracts/src/libraries/verifier/WithdrawTrieVerifier.sol</code><br><code>contracts/src/L1/gateways/usdc/L1USDCGateway.sol</code> (explicitly not audited) |
| <a href="https://github.com/scroll-tech/scroll/blob/1437c2678d4ba329ac99ecf24772249d16ea0580/contracts/src/L1/rollup/L2GasPriceOracle.sol"><code>1437c2678d4ba329ac99ecf24772249d16ea0580</code></a> | August 31, 2023 | <code>contracts/src/L1/rollup/L2GasPriceOracle.sol</code> |

## Scroll zkEVM Circuits, Wave 2 Security Assessment

- Report: [trailofbits-scroll-zkevm-circuits-wave2-2023-08.md](<reports/trailofbits-scroll-zkevm-circuits-wave2-2023-08.md>)
- Auditor: Trail of Bits
- Date: 2023-09-08
- Description: Trail of Bits review (July 17 to August 4, 2023) of the Merkle Patricia trie circuit, the Copy circuit and its word-addressable memory optimizations, and the Super circuit, checking soundness, completeness and fidelity to the specifications. Three high-severity soundness issues were reported.

### Repository: <a href="https://github.com/scroll-tech/mpt-circuit"><code>scroll-tech/mpt-circuit</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/2e216c2d30d35a459f933a58b8002fe817abb1b4/src/constraint_builder/binary_column.rs"><code>2e216c2d30d35a459f933a58b8002fe817abb1b4</code></a> | July 17, 2023 | <code>src/constraint_builder/binary_column.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/tree/7b56d0b323e92ac11e54213520f6e7db41941cd0/src"><code>7b56d0b323e92ac11e54213520f6e7db41941cd0</code></a> | July 17, 2023 | <code>src</code> (recursive directory)<br><code>src/gadgets/mpt_update.rs</code><br><code>src/constraint_builder/binary_column.rs</code><br><code>src/gadgets/one_hot.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/f7defcf1d7435bccfc787cdbeb3035ffa66680e1/src/constraint_builder/binary_column.rs"><code>f7defcf1d7435bccfc787cdbeb3035ffa66680e1</code></a> | August 3, 2023 | <code>src/constraint_builder/binary_column.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/13b78affcaf44a5b95933ed0a1d4db4ebbd5e489/src/gadgets/one_hot.rs"><code>13b78affcaf44a5b95933ed0a1d4db4ebbd5e489</code></a> | August 3, 2023 | <code>src/gadgets/one_hot.rs</code> |
| <a href="https://github.com/scroll-tech/mpt-circuit/blob/95e4b07b2b95bd7e097b4adcd45e4c51d3984196/src/gadgets/mpt_update.rs"><code>95e4b07b2b95bd7e097b4adcd45e4c51d3984196</code></a> | August 14, 2023 | <code>src/gadgets/mpt_update.rs</code> |

### Repository: <a href="https://github.com/scroll-tech/zkevm-circuits"><code>scroll-tech/zkevm-circuits</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkevm-circuits/tree/fc6c8a2972870e62e96cde480b3aa48c0cc1303d/zkevm-circuits/src/copy_circuit"><code>fc6c8a2972870e62e96cde480b3aa48c0cc1303d</code></a> | July 17, 2023 | <code>zkevm-circuits/src/copy_circuit</code> (recursive directory)<br><code>zkevm-circuits/src/copy_circuit.rs</code><br><code>zkevm-circuits/src/super_circuit.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_invalid_creation_code.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/0d2c915ce2f3d45d12fcd8aee8fe86ab5b7625c7/zkevm-circuits/src/evm_circuit/execution/error_invalid_creation_code.rs"><code>0d2c915ce2f3d45d12fcd8aee8fe86ab5b7625c7</code></a> | August 10, 2023 | <code>zkevm-circuits/src/evm_circuit/execution/error_invalid_creation_code.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/tree/1af87bdc5eef847da6e4ea42471e3c56d3dbeae4/zkevm-circuits/src/copy_circuit"><code>1af87bdc5eef847da6e4ea42471e3c56d3dbeae4</code></a> | August 11, 2023 | <code>zkevm-circuits/src/copy_circuit</code> (recursive directory)<br><code>zkevm-circuits/src/copy_circuit.rs</code> |

## Scroll zkTrie Security Assessment

- Report: [trailofbits-scroll-zktrie-2023-07.md](<reports/trailofbits-scroll-zktrie-2023-07.md>)
- Auditor: Trail of Bits
- Date: 2023-09-08
- Description: Trail of Bits review (June 26 to July 11, 2023) of zkTrie, Scroll&#x27;s Go implementation of the sparse Merkle Patricia tree together with its Rust bindings, focused on inclusion and non-inclusion proof verification, data-structure correctness and binding safety. Several high-severity flaws in the node hashing and domain separation scheme were reported.

### Repository: <a href="https://github.com/scroll-tech/zktrie"><code>scroll-tech/zktrie</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zktrie/tree/90179c19281670f41c54bd80ab01e4d64c860521/trie"><code>90179c19281670f41c54bd80ab01e4d64c860521</code></a> | May 25, 2023 | <code>trie</code> (recursive directory)<br><code>types</code> (recursive directory)<br><code>lib.go</code><br><code>c.go</code><br><code>src/lib.rs</code> |
| <a href="https://github.com/scroll-tech/zktrie/blob/17ca5c040fee12fb45c7dc22a9847f02dd5309d1/lib.go"><code>17ca5c040fee12fb45c7dc22a9847f02dd5309d1</code></a> | July 23, 2023 | <code>lib.go</code> |
| <a href="https://github.com/scroll-tech/zktrie/tree/83318659773604fa565e2ebeb810a6d3746f0af4/trie"><code>83318659773604fa565e2ebeb810a6d3746f0af4</code></a> | July 28, 2023 | <code>trie</code> (recursive directory)<br><code>types</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zktrie/blob/1b901da1c279017b98ffc72ba43585a1bd89b5e9/src/lib.rs"><code>1b901da1c279017b98ffc72ba43585a1bd89b5e9</code></a> | August 11, 2023 | <code>src/lib.rs</code> |
| <a href="https://github.com/scroll-tech/zktrie/blob/23b715f09faf19aa2bd3b19e9a541dd980ba4aa5/src/lib.rs"><code>23b715f09faf19aa2bd3b19e9a541dd980ba4aa5</code></a> | August 15, 2023 | <code>src/lib.rs</code> |

## Scroll USDC Gateway Audit

- Report: [openzeppelin-scroll-usdc-gateway-audit-2023-09.md](<reports/openzeppelin-scroll-usdc-gateway-audit-2023-09.md>)
- Auditor: OpenZeppelin
- Date: 2023-09-13
- Description: OpenZeppelin audit of the Scroll USDC gateway changes (L1USDCGateway, L2USDCGateway, the CCTPGatewayBase library and the Circle CCTP interfaces) in scroll-tech/scroll at commit f6894bb.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/f6894bb82f78228b349267ed814375cae2fc1483/contracts/src/L1/gateways/L1ERC20Gateway.sol"><code>f6894bb82f78228b349267ed814375cae2fc1483</code></a> | August 29, 2023 | <code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/usdc/L1USDCGateway.sol</code><br><code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code><br><code>contracts/src/interfaces/IMessageTransmitter.sol</code><br><code>contracts/src/interfaces/ITokenMessenger.sol</code><br><code>contracts/src/interfaces/IUSDCBurnableSourceBridge.sol</code><br><code>contracts/src/interfaces/IUSDCDestinationBridge.sol</code><br><code>contracts/src/libraries/gateway/CCTPGatewayBase.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/be6d4041e62817b72fffa555d83c9c0d271b291a/contracts/src/L2/gateways/usdc/L2USDCGateway.sol"><code>be6d4041e62817b72fffa555d83c9c0d271b291a</code></a> | September 6, 2023 | <code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/733d2a62d44a0037b2972d6825e6802fc6ac76f5/contracts/src/L2/gateways/usdc/L2USDCGateway.sol"><code>733d2a62d44a0037b2972d6825e6802fc6ac76f5</code></a> | September 6, 2023 | <code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/23bf84a634065df5c4db7f90e2d8b4a07160a604/contracts/src/L1/gateways/L1ERC20Gateway.sol"><code>23bf84a634065df5c4db7f90e2d8b4a07160a604</code></a> | September 6, 2023 | <code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/usdc/L1USDCGateway.sol</code><br><code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/5e61a05f5f543598f3b99ce484bba243ae664e2e/contracts/src/libraries/gateway/CCTPGatewayBase.sol"><code>5e61a05f5f543598f3b99ce484bba243ae664e2e</code></a> | September 6, 2023 | <code>contracts/src/libraries/gateway/CCTPGatewayBase.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/30fa5e65ef577acbde630baa982e1752b2095a60/contracts/src/L1/gateways/L1ERC20Gateway.sol"><code>30fa5e65ef577acbde630baa982e1752b2095a60</code></a> | September 11, 2023 | <code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code><br><code>contracts/src/interfaces/IMessageTransmitter.sol</code><br><code>contracts/src/interfaces/ITokenMessenger.sol</code><br><code>contracts/src/interfaces/IUSDCBurnableSourceBridge.sol</code><br><code>contracts/src/interfaces/IUSDCDestinationBridge.sol</code><br><code>contracts/src/libraries/gateway/CCTPGatewayBase.sol</code> |

## Scroll Diff Audit Report

- Report: [openzeppelin-scroll-diff-audit-2023-09.md](<reports/openzeppelin-scroll-diff-audit-2023-09.md>)
- Auditor: OpenZeppelin
- Date: 2023-09-21
- Description: OpenZeppelin diff audit (September 13 to 15, 2023) of pull requests 887, 912, 893 and 943 of scroll-tech/scroll, covering L1MessageQueue, ScrollChain, the L2 transaction fee vault and the FeeVault library. Only two low-severity issues and one note were reported, all resolved.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/f8b9da0fbabd9915b869f274aabc4d5dc0c28fa6/contracts/src/L1/rollup/IL1MessageQueue.sol"><code>f8b9da0fbabd9915b869f274aabc4d5dc0c28fa6</code></a> | September 1, 2023 | <code>contracts/src/L1/rollup/IL1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueue.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/02bce207cd5bb511106943e13d4d64b47d4dea13/contracts/src/L1/rollup/ScrollChain.sol"><code>02bce207cd5bb511106943e13d4d64b47d4dea13</code></a> | September 1, 2023 | <code>contracts/src/L1/rollup/ScrollChain.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/10743c26b888d62ba3b2faa9eaa8522488235bb4/contracts/src/libraries/FeeVault.sol"><code>10743c26b888d62ba3b2faa9eaa8522488235bb4</code></a> | September 2, 2023 | <code>contracts/src/libraries/FeeVault.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/3d9bfb5c2bd4b1ea2340a7a2469d7b8ca336bd8d/contracts/src/L2/predeploys/L2TxFeeVault.sol"><code>3d9bfb5c2bd4b1ea2340a7a2469d7b8ca336bd8d</code></a> | September 13, 2023 | <code>contracts/src/L2/predeploys/L2TxFeeVault.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/08b8bc93228e64453916b9bbc46e85c21de0a477/contracts/src/L2/predeploys/L2TxFeeVault.sol"><code>08b8bc93228e64453916b9bbc46e85c21de0a477</code></a> | September 20, 2023 | <code>contracts/src/L2/predeploys/L2TxFeeVault.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/e1a3f95325d672558a5b50fc49dcf34c3593b4ec/contracts/src/L1/rollup/L1MessageQueue.sol"><code>e1a3f95325d672558a5b50fc49dcf34c3593b4ec</code></a> | September 20, 2023 | <code>contracts/src/L1/rollup/L1MessageQueue.sol</code><br><code>contracts/src/L2/predeploys/L2TxFeeVault.sol</code> |

## ScrollOwner and Rate Limiter Audit

- Report: [openzeppelin-scroll-owner-rate-limiter-audit-2023-09.md](<reports/openzeppelin-scroll-owner-rate-limiter-audit-2023-09.md>)
- Auditor: OpenZeppelin
- Date: 2023-09-26
- Description: OpenZeppelin audit of the ScrollOwner access-control contract (pull request 586) and the ETH and token rate limiters (pull request 712) in scroll-tech/scroll at commit ae2e010. The rate-limiter pull request was additionally covered by a diff audit of the bridge contracts it changes.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/ae2e010324506d52f30d1aa98b98cc3e44f8c501/contracts/src/misc/ScrollOwner.sol"><code>ae2e010324506d52f30d1aa98b98cc3e44f8c501</code></a> | August 18, 2023 | <code>contracts/src/misc/ScrollOwner.sol</code><br><code>contracts/src/rate-limiter/ETHRateLimiter.sol</code><br><code>contracts/src/rate-limiter/IETHRateLimiter.sol</code><br><code>contracts/src/rate-limiter/ITokenRateLimiter.sol</code><br><code>contracts/src/rate-limiter/TokenRateLimiter.sol</code><br><code>contracts/src/L1/gateways/L1ERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L2/gateways/L2CustomERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2StandardERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2WETHGateway.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code><br><code>contracts/src/libraries/gateway/ScrollGatewayBase.sol</code><br><code>contracts/src/libraries/ScrollMessengerBase.sol</code><br><code>contracts/src/gas-swap/GasSwap.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/9a69617b8a22039bfed50b5eccd6ac726ad0c574/contracts/src/misc/ScrollOwner.sol"><code>9a69617b8a22039bfed50b5eccd6ac726ad0c574</code></a> | September 1, 2023 | <code>contracts/src/misc/ScrollOwner.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/7d2484c112ea7957e1ec33004008e0e92b34f2af/contracts/src/misc/ScrollOwner.sol"><code>7d2484c112ea7957e1ec33004008e0e92b34f2af</code></a> | September 1, 2023 | <code>contracts/src/misc/ScrollOwner.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/d0780e956a6a35d99463bd9003647f3bc0e19fc4/contracts/src/misc/ScrollOwner.sol"><code>d0780e956a6a35d99463bd9003647f3bc0e19fc4</code></a> | September 1, 2023 | <code>contracts/src/misc/ScrollOwner.sol</code><br><code>contracts/src/rate-limiter/ETHRateLimiter.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/95ed76e4536b0f7de5e8b15eb67a559015b90cc2/contracts/src/rate-limiter/ETHRateLimiter.sol"><code>95ed76e4536b0f7de5e8b15eb67a559015b90cc2</code></a> | September 1, 2023 | <code>contracts/src/rate-limiter/ETHRateLimiter.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/0bb41be065704c7a39f09ecf604458d0fca96cac/contracts/src/misc/ScrollOwner.sol"><code>0bb41be065704c7a39f09ecf604458d0fca96cac</code></a> | September 1, 2023 | <code>contracts/src/misc/ScrollOwner.sol</code><br><code>contracts/src/rate-limiter/ETHRateLimiter.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/0c5fbb7babc30a41aa5ed2fc3c700e0221cd66a4/contracts/src/misc/ScrollOwner.sol"><code>0c5fbb7babc30a41aa5ed2fc3c700e0221cd66a4</code></a> | September 1, 2023 | <code>contracts/src/misc/ScrollOwner.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/86556dd25f826ec1609089f979f7c75d192f6641/contracts/src/rate-limiter/ETHRateLimiter.sol"><code>86556dd25f826ec1609089f979f7c75d192f6641</code></a> | September 1, 2023 | <code>contracts/src/rate-limiter/ETHRateLimiter.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/daae8c438d4e246c304da9251e286668d6189bc6/contracts/src/rate-limiter/TokenRateLimiter.sol"><code>daae8c438d4e246c304da9251e286668d6189bc6</code></a> | September 1, 2023 | <code>contracts/src/rate-limiter/TokenRateLimiter.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/0fe10691947a48b1cf94fb83ff1e7cae87b57f48/contracts/scripts/foundry/InitializeL2ScrollOwner.s.sol"><code>0fe10691947a48b1cf94fb83ff1e7cae87b57f48</code></a> | September 18, 2023 | <code>contracts/scripts/foundry/InitializeL2ScrollOwner.s.sol</code> |

## Scroll zkEVM Circuits, Wave 3 - Security Assessment

- Report: [trailofbits-scroll-zkevm-circuits-wave3-2023-09.md](<reports/trailofbits-scroll-zkevm-circuits-wave3-2023-09.md>)
- Auditor: Trail of Bits
- Date: 2023-10-06
- Description: Trail of Bits review (August 14 to September 19, 2023) of the proof compression and aggregation circuit, the updated MPT hash scheme, the EVM precompile circuits and the transaction circuit, together with the parts of snark-verifier used by the aggregator. One high-severity data-hash issue in the aggregator crate was reported.

### Repository: <a href="https://github.com/scroll-tech/mpt-circuit"><code>scroll-tech/mpt-circuit</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/mpt-circuit/tree/2163a9c436ed85363c954ecf7e6e1044a1b991dc/src"><code>2163a9c436ed85363c954ecf7e6e1044a1b991dc</code></a> | August 14, 2023 | <code>src</code> (recursive directory)<br><code>spec/mpt-proof.md</code> |

### Repository: <a href="https://github.com/scroll-tech/zkevm-circuits"><code>scroll-tech/zkevm-circuits</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkevm-circuits/tree/e40ab9e8e78fd362c50fcd0277db79a1c9a98e60/aggregator"><code>e40ab9e8e78fd362c50fcd0277db79a1c9a98e60</code></a> | August 14, 2023 | <code>aggregator</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/4a884959e143ab946fe231e96f847c008a46885a/zkevm-circuits/src/sig_circuit.rs"><code>4a884959e143ab946fe231e96f847c008a46885a</code></a> | August 28, 2023 | <code>zkevm-circuits/src/sig_circuit.rs</code><br><code>zkevm-circuits/src/sig_circuit</code> (recursive directory)<br><code>zkevm-circuits/src/tx_circuit.rs</code><br><code>zkevm-circuits/src/modexp_circuit.rs</code> (explicitly not audited)<br><code>zkevm-circuits/src/ecc_circuit.rs</code> (explicitly not audited)<br><code>zkevm-circuits/src/ecc_circuit</code> (recursive directory) (explicitly not audited)<br><code>zkevm-circuits/src/evm_circuit/execution/precompiles</code> (recursive directory) (explicitly not audited) |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/9ce3ce38f55a7bd11fbe132c048787e7c96af607/zkevm-circuits/src/pi_circuit.rs"><code>9ce3ce38f55a7bd11fbe132c048787e7c96af607</code></a> | August 31, 2023 | <code>zkevm-circuits/src/pi_circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/tree/851cc37e7a9c4b3d5f9534d49b76615e57122b1f/aggregator"><code>851cc37e7a9c4b3d5f9534d49b76615e57122b1f</code></a> | September 5, 2023 | <code>aggregator</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/469cce407874329645c7c075512606db8546ec43/zkevm-circuits/src/sig_circuit.rs"><code>469cce407874329645c7c075512606db8546ec43</code></a> | September 5, 2023 | <code>zkevm-circuits/src/sig_circuit.rs</code><br><code>zkevm-circuits/src/sig_circuit</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkevm-circuits/tree/270a3b8be4d3ff76a21fae4af9ea83a7b40d4213/aggregator"><code>270a3b8be4d3ff76a21fae4af9ea83a7b40d4213</code></a> | September 23, 2023 | <code>aggregator</code> (recursive directory) |

### Repository: <a href="https://github.com/scroll-tech/snark-verifier"><code>scroll-tech/snark-verifier</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/snark-verifier/tree/bc1d39ae31f3fe520c51dd150f0fefaf9653c465/snark-verifier/src"><code>bc1d39ae31f3fe520c51dd150f0fefaf9653c465</code></a> | September 12, 2023 | <code>snark-verifier/src</code> (recursive directory)<br><code>snark-verifier-sdk/src</code> (recursive directory) |

## Scroll zkEVM halo2 Circuits Security Assessment

- Report: [trailofbits-scroll-zkevm-circuits-wave1-2023-04.md](<reports/trailofbits-scroll-zkevm-circuits-wave1-2023-04.md>)
- Auditor: Trail of Bits
- Date: 2023-10-12
- Description: Trail of Bits review (April 17 to June 23, 2023) of Scroll&#x27;s zkEVM halo2 circuits: the EVM, state, bytecode and keccak circuits and the modexp precompile circuit, plus diff reviews of halo2-lib and snark-verifier. Many high-severity soundness issues caused by incorrect, incomplete or missing constraints were reported.

### Repository: <a href="https://github.com/scroll-tech/zkevm-circuits"><code>scroll-tech/zkevm-circuits</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkevm-circuits/tree/e8bcb23e1f303bd6e0dc52924b0ed85710b8a016/zkevm-circuits/src/evm_circuit"><code>e8bcb23e1f303bd6e0dc52924b0ed85710b8a016</code></a> | April 17, 2023 | <code>zkevm-circuits/src/evm_circuit</code> (recursive directory)<br><code>zkevm-circuits/src/evm_circuit.rs</code><br><code>zkevm-circuits/src/state_circuit</code> (recursive directory)<br><code>zkevm-circuits/src/state_circuit.rs</code><br><code>zkevm-circuits/src/bytecode_circuit</code> (recursive directory)<br><code>zkevm-circuits/src/bytecode_circuit.rs</code><br><code>zkevm-circuits/src/keccak_circuit</code> (recursive directory)<br><code>zkevm-circuits/src/keccak_circuit.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/math_gadget/modulo.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/math_gadget/rlp.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/blockhash.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/callop.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/begin_tx.rs</code><br><code>zkevm-circuits/src/state_circuit/constraint_builder.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/create.rs</code><br><code>zkevm-circuits/src/evm_circuit/step.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/math_gadget/constant_division.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/math_gadget/lt.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/constraint_builder.rs</code><br><code>zkevm-circuits/src/util.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/return_revert.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_code_store.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_precompile_failed.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_invalid_creation_code.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/returndatacopy.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_return_data_oo_bound.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/common_gadget.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/exp.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/extcodecopy.rs</code><br><code>zkevm-circuits/src/bytecode_circuit/circuit.rs</code><br><code>zkevm-circuits/Cargo.toml</code><br><code>zkevm-circuits/src/tx_circuit/sign_verify.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/tree/44000e55eddaec42da958f2555d9bdeec8b865c2/zkevm-circuits/src/bytecode_circuit"><code>44000e55eddaec42da958f2555d9bdeec8b865c2</code></a> | May 29, 2023 | <code>zkevm-circuits/src/bytecode_circuit</code> (recursive directory)<br><code>zkevm-circuits/src/bytecode_circuit.rs</code><br><code>zkevm-circuits/src/bytecode_circuit/circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/4f3982b3940e8e0f6061f246b3508dd379fb1703/zkevm-circuits/src/evm_circuit/util/math_gadget/modulo.rs"><code>4f3982b3940e8e0f6061f246b3508dd379fb1703</code></a> | June 1, 2023 | <code>zkevm-circuits/src/evm_circuit/util/math_gadget/modulo.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/blockhash.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/callop.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/create.rs</code><br><code>zkevm-circuits/src/evm_circuit/step.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/math_gadget/constant_division.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/math_gadget/lt.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/6537bfe8a1dc4f65ce31e78b3b5cf3ca579fafa1/zkevm-circuits/src/evm_circuit/util/math_gadget/rlp.rs"><code>6537bfe8a1dc4f65ce31e78b3b5cf3ca579fafa1</code></a> | July 12, 2023 | <code>zkevm-circuits/src/evm_circuit/util/math_gadget/rlp.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/965cc6724fafa87e1e1736efec756a6adf13e03c/zkevm-circuits/src/evm_circuit/execution/returndatacopy.rs"><code>965cc6724fafa87e1e1736efec756a6adf13e03c</code></a> | July 25, 2023 | <code>zkevm-circuits/src/evm_circuit/execution/returndatacopy.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_return_data_oo_bound.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/common_gadget.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/f61850d2d612b2d6c506ee484cd7536e46d4ad51/zkevm-circuits/src/evm_circuit/execution/begin_tx.rs"><code>f61850d2d612b2d6c506ee484cd7536e46d4ad51</code></a> | July 27, 2023 | <code>zkevm-circuits/src/evm_circuit/execution/begin_tx.rs</code><br><code>zkevm-circuits/src/state_circuit/constraint_builder.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/38d834ff42ae207f549a384e7df17a0b534d4e35/zkevm-circuits/src/evm_circuit/util/constraint_builder.rs"><code>38d834ff42ae207f549a384e7df17a0b534d4e35</code></a> | August 2, 2023 | <code>zkevm-circuits/src/evm_circuit/util/constraint_builder.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/e28eb9681aab319a0f17e0cffedc42ac98a3db2a/zkevm-circuits/src/bytecode_circuit/circuit.rs"><code>e28eb9681aab319a0f17e0cffedc42ac98a3db2a</code></a> | August 3, 2023 | <code>zkevm-circuits/src/bytecode_circuit/circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/83595f83fa958569aed6eeef20b986d136f59c6c/zkevm-circuits/src/evm_circuit/execution/exp.rs"><code>83595f83fa958569aed6eeef20b986d136f59c6c</code></a> | August 12, 2023 | <code>zkevm-circuits/src/evm_circuit/execution/exp.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/f2e223139eb376dd6715a65950c2760af173b3e8/zkevm-circuits/src/evm_circuit/execution/return_revert.rs"><code>f2e223139eb376dd6715a65950c2760af173b3e8</code></a> | August 14, 2023 | <code>zkevm-circuits/src/evm_circuit/execution/return_revert.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_code_store.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_precompile_failed.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_invalid_creation_code.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/3dd2f25b8587d27074914a8aa58da19aa0b9d74f/zkevm-circuits/src/evm_circuit/execution/return_revert.rs"><code>3dd2f25b8587d27074914a8aa58da19aa0b9d74f</code></a> | August 14, 2023 | <code>zkevm-circuits/src/evm_circuit/execution/return_revert.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/adc298a454d98cf0792d8a548a19222060b55f52/zkevm-circuits/src/evm_circuit/execution/callop.rs"><code>adc298a454d98cf0792d8a548a19222060b55f52</code></a> | August 16, 2023 | <code>zkevm-circuits/src/evm_circuit/execution/callop.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/common_gadget.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/8b48a577f59bc2917fa3c46a70bd6b61474a79e8/zkevm-circuits/src/evm_circuit/execution/extcodecopy.rs"><code>8b48a577f59bc2917fa3c46a70bd6b61474a79e8</code></a> | August 29, 2023 | <code>zkevm-circuits/src/evm_circuit/execution/extcodecopy.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/7fe99fe4e3de14801f4d66f75bd35307de39b0a8/zkevm-circuits/Cargo.toml"><code>7fe99fe4e3de14801f4d66f75bd35307de39b0a8</code></a> | September 21, 2023 | <code>zkevm-circuits/Cargo.toml</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/ce7a7b95a8c8fef80289dbe6a36e4fffca2859fa/zkevm-circuits/src/util.rs"><code>ce7a7b95a8c8fef80289dbe6a36e4fffca2859fa</code></a> | October 12, 2023 | <code>zkevm-circuits/src/util.rs</code> |

### Repository: <a href="https://github.com/scroll-tech/snark-verifier"><code>scroll-tech/snark-verifier</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/snark-verifier/tree/a3d0a5ab48522bc533686da3ea8400282c91f536/snark-verifier/src"><code>a3d0a5ab48522bc533686da3ea8400282c91f536</code></a> | April 10, 2023 | <code>snark-verifier/src</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/snark-verifier/tree/ae6a9ef1ba0f5296f98cd6ba2a94f791278be851/snark-verifier/src"><code>ae6a9ef1ba0f5296f98cd6ba2a94f791278be851</code></a> | May 26, 2023 | <code>snark-verifier/src</code> (recursive directory)<br><code>snark-verifier/src/pcs/kzg/decider.rs</code><br><code>snark-verifier/src/pcs/ipa/decider.rs</code> |
| <a href="https://github.com/scroll-tech/snark-verifier/blob/7b4daacdf6f87f74a36985d79f4a0e23bfd32059/snark-verifier/src/pcs/kzg/decider.rs"><code>7b4daacdf6f87f74a36985d79f4a0e23bfd32059</code></a> | July 31, 2023 | <code>snark-verifier/src/pcs/kzg/decider.rs</code><br><code>snark-verifier/src/pcs/ipa/decider.rs</code> |

### Repository: <a href="https://github.com/scroll-tech/misc-precompiled-circuit"><code>scroll-tech/misc-precompiled-circuit</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/misc-precompiled-circuit/blob/05725ec61d52d29a063395b0a1130467bee0d2f1/src/circuits/modexp.rs"><code>05725ec61d52d29a063395b0a1130467bee0d2f1</code></a> | May 27, 2023 | <code>src/circuits/modexp.rs</code><br><code>src/circuits/mod.rs</code><br><code>src/utils/mod.rs</code> |
| <a href="https://github.com/scroll-tech/misc-precompiled-circuit/blob/22a1d04663e6dc4ef1e4676f785fb2bda4ff2834/src/circuits/modexp.rs"><code>22a1d04663e6dc4ef1e4676f785fb2bda4ff2834</code></a> | June 7, 2023 | <code>src/circuits/modexp.rs</code> |
| <a href="https://github.com/scroll-tech/misc-precompiled-circuit/blob/2263454314dbf70705e1a65305c294314103f449/src/circuits/modexp.rs"><code>2263454314dbf70705e1a65305c294314103f449</code></a> | August 2, 2023 | <code>src/circuits/modexp.rs</code><br><code>src/circuits/mod.rs</code> |
| <a href="https://github.com/scroll-tech/misc-precompiled-circuit/blob/4fb0848fd7fdef46a7168f76e9c391f8326a00c3/src/circuits/modexp.rs"><code>4fb0848fd7fdef46a7168f76e9c391f8326a00c3</code></a> | August 26, 2023 | <code>src/circuits/modexp.rs</code> |
| <a href="https://github.com/scroll-tech/misc-precompiled-circuit/blob/483feb2e4554fcab58878d7c8e6a6f8be792e2f2/src/circuits/mod.rs"><code>483feb2e4554fcab58878d7c8e6a6f8be792e2f2</code></a> | August 26, 2023 | <code>src/circuits/mod.rs</code> |
| <a href="https://github.com/scroll-tech/misc-precompiled-circuit/blob/2443b3ccc775bd5014fcf15f508b4bc7dc310152/src/utils/mod.rs"><code>2443b3ccc775bd5014fcf15f508b4bc7dc310152</code></a> | September 7, 2023 | <code>src/utils/mod.rs</code> |

### Repository: <a href="https://github.com/scroll-tech/halo2-lib"><code>scroll-tech/halo2-lib</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/halo2-lib/compare/a80505265f36f87a2df40edc22ea468ea2068fb5...b1d1567063eb13fd1fc868fa9ed6b438961ef9e9"><code>a80505265f36f87a2df40edc22ea468ea2068fb5…b1d1567063eb13fd1fc868fa9ed6b438961ef9e9</code></a> (commit range) | May 12, 2023 – June 20, 2023 | <code>halo2-base</code> (recursive directory)<br><code>halo2-ecc</code> (recursive directory)<br><code>hashes/zkevm-keccak/src/keccak_packed_multi.rs</code> |
| <a href="https://github.com/scroll-tech/halo2-lib/tree/v0.1.5/halo2-base"><code>70588177930400361c731659b15b2ab3f29f7784</code></a> (tag <code>v0.1.5</code>) | September 12, 2023 | <code>halo2-base</code> (recursive directory) (explicitly not audited)<br><code>halo2-ecc</code> (recursive directory) (explicitly not audited) |

## Lido Gateway Smart Contract Security Assessment

- Report: [zellic-scroll-lido-gateway-audit.md](<reports/zellic-scroll-lido-gateway-audit.md>)
- Auditor: Zellic
- Date: 2024-01-23
- Description: Zellic assessment (January 16 to 19, 2024) of the Scroll Lido gateway contracts (L1LidoGateway, L2LidoGateway, L2WstETHToken and the bridgeable-token and manager base contracts) together with the ScrollBridgeExecutor in scroll-tech/governance-crosschain-bridges. One finding was reported.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/69224ebb935d499c055c7859c1c8ade57244249c/contracts/src/lido/L1LidoGateway.sol"><code>69224ebb935d499c055c7859c1c8ade57244249c</code></a> | January 16, 2024 | <code>contracts/src/lido/L1LidoGateway.sol</code><br><code>contracts/src/lido/L2LidoGateway.sol</code><br><code>contracts/src/lido/L2WstETHToken.sol</code><br><code>contracts/src/lido/LidoBridgeableTokens.sol</code><br><code>contracts/src/lido/LidoGatewayManager.sol</code> |

### Repository: <a href="https://github.com/scroll-tech/governance-crosschain-bridges"><code>scroll-tech/governance-crosschain-bridges</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/governance-crosschain-bridges/blob/d023beed13f9b7f77c062b8fee43476788e48343/contracts/bridges/ScrollBridgeExecutor.sol"><code>d023beed13f9b7f77c062b8fee43476788e48343</code></a> | December 22, 2023 | <code>contracts/bridges/ScrollBridgeExecutor.sol</code> |

## Scroll - Bridge Gas Optimizations Audit

- Report: [openzeppelin-scroll-bridge-gas-optimizations-audit-2024-02.md](<reports/openzeppelin-scroll-bridge-gas-optimizations-audit-2024-02.md>)
- Auditor: OpenZeppelin
- Date: 2024-02-06
- Description: OpenZeppelin diff audit of pull request 1011 (bridge gas optimizations) of scroll-tech/scroll at commit 45e1305, covering the L1 and L2 gateways, the messengers, the message queue and the gas price oracles. Changes outside the pull request were out of scope.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/45e1305de5f7a1dc5aadadd7d3bb6726a5dee949/contracts/src/L1/gateways/L1CustomERC20Gateway.sol"><code>45e1305de5f7a1dc5aadadd7d3bb6726a5dee949</code></a> | January 8, 2024 | <code>contracts/src/L1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC1155Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ERC721Gateway.sol</code><br><code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1WETHGateway.sol</code><br><code>contracts/src/L1/gateways/usdc/L1USDCGateway.sol</code><br><code>contracts/src/L1/L1ScrollMessenger.sol</code><br><code>contracts/src/L1/rollup/IL1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/IL1MessageQueueWithGasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/IL2GasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/IScrollChain.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueueWithGasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/L2GasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/L2/gateways/L2CustomERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC1155Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ERC721Gateway.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code><br><code>contracts/src/L2/gateways/L2GatewayRouter.sol</code><br><code>contracts/src/L2/gateways/L2StandardERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2WETHGateway.sol</code><br><code>contracts/src/L2/gateways/usdc/L2USDCGateway.sol</code><br><code>contracts/src/L2/L2ScrollMessenger.sol</code><br><code>contracts/src/libraries/gateway/IScrollGateway.sol</code><br><code>contracts/src/libraries/gateway/ScrollGatewayBase.sol</code><br><code>contracts/src/libraries/IScrollMessenger.sol</code><br><code>contracts/src/libraries/ScrollMessengerBase.sol</code><br><code>contracts/src/misc/EmptyContract.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/fbb786210ea23bb1a11ceefcefa26c15c14992fa/contracts/src/L1/gateways/L1StandardERC20Gateway.sol"><code>fbb786210ea23bb1a11ceefcefa26c15c14992fa</code></a> | January 28, 2024 | <code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/src/L2/gateways/L2StandardERC20Gateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/71d8c78384dc769b19cd9631c212ae18d63c94a6/contracts/src/L1/rollup/L1MessageQueueWithGasPriceOracle.sol"><code>71d8c78384dc769b19cd9631c212ae18d63c94a6</code></a> | January 29, 2024 | <code>contracts/src/L1/rollup/L1MessageQueueWithGasPriceOracle.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/747f35433cc5a92fb81999d395f3d14dec071854/contracts/src/L1/rollup/IL1MessageQueue.sol"><code>747f35433cc5a92fb81999d395f3d14dec071854</code></a> | January 29, 2024 | <code>contracts/src/L1/rollup/IL1MessageQueue.sol</code><br><code>contracts/src/L1/rollup/IL1MessageQueueWithGasPriceOracle.sol</code><br><code>contracts/src/L1/rollup/L1MessageQueueWithGasPriceOracle.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/223538de478e26415fe57682254cdfb9469a5d79/contracts/src/L1/gateways/L1GatewayRouter.sol"><code>223538de478e26415fe57682254cdfb9469a5d79</code></a> | February 1, 2024 | <code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L2/gateways/L2GatewayRouter.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/a8addd896717b663bc8053744f794f721ed87cdd/contracts/src/L1/gateways/L1CustomERC20Gateway.sol"><code>a8addd896717b663bc8053744f794f721ed87cdd</code></a> | February 1, 2024 | <code>contracts/src/L1/gateways/L1CustomERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/L1StandardERC20Gateway.sol</code><br><code>contracts/src/L1/gateways/usdc/L1USDCGateway.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code><br><code>contracts/src/L2/gateways/L2StandardERC20Gateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/888c3d26b34f217877628b1208ea3473d9836600/contracts/src/L1/gateways/L1ETHGateway.sol"><code>888c3d26b34f217877628b1208ea3473d9836600</code></a> | February 6, 2024 | <code>contracts/src/L1/gateways/L1ETHGateway.sol</code><br><code>contracts/src/L1/gateways/L1GatewayRouter.sol</code><br><code>contracts/src/L2/gateways/L2ETHGateway.sol</code><br><code>contracts/src/L2/gateways/L2GatewayRouter.sol</code> |

## Scroll ZKTrieVerifier Audit

- Report: [openzeppelin-scroll-zktrieverifier-audit.md](<reports/openzeppelin-scroll-zktrieverifier-audit.md>)
- Auditor: OpenZeppelin
- Date: 2024-03-06
- Description: OpenZeppelin audit of the ZkTrieVerifier library and the ScrollChainCommitmentVerifier contract in scroll-tech/scroll at commit c68f428, which verify zkTrie storage proofs against finalized Scroll state roots.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/L1/rollup/ScrollChainCommitmentVerifier.sol"><code>c68f4283b15e9816427caedf372ed2daac7f2e66</code></a> | January 23, 2024 | <code>contracts/src/L1/rollup/ScrollChainCommitmentVerifier.sol</code><br><code>contracts/src/libraries/verifier/ZkTrieVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/bb781f17c185fce00379b332aca4a9fec6926655/contracts/src/L1/rollup/ScrollChainCommitmentVerifier.sol"><code>bb781f17c185fce00379b332aca4a9fec6926655</code></a> | February 19, 2024 | <code>contracts/src/L1/rollup/ScrollChainCommitmentVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/265800ffa4645bd3a8c606898d3147f6c545122a/contracts/src/libraries/verifier/ZkTrieVerifier.sol"><code>265800ffa4645bd3a8c606898d3147f6c545122a</code></a> | February 19, 2024 | <code>contracts/src/libraries/verifier/ZkTrieVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/daaf600a2d0ed070c9ca8c59d4cf5a2981124609/contracts/src/libraries/verifier/ZkTrieVerifier.sol"><code>daaf600a2d0ed070c9ca8c59d4cf5a2981124609</code></a> | February 19, 2024 | <code>contracts/src/libraries/verifier/ZkTrieVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/db8f65d8e06d0409f37442a3cb981204149c3e20/contracts/src/libraries/verifier/ZkTrieVerifier.sol"><code>db8f65d8e06d0409f37442a3cb981204149c3e20</code></a> | February 19, 2024 | <code>contracts/src/libraries/verifier/ZkTrieVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/d280b6cb0f29e37e0686bb4db63b86aef0dbe528/contracts/src/libraries/verifier/ZkTrieVerifier.sol"><code>d280b6cb0f29e37e0686bb4db63b86aef0dbe528</code></a> | February 19, 2024 | <code>contracts/src/libraries/verifier/ZkTrieVerifier.sol</code> |

## EIP-4844 Support Audit

- Report: [openzeppelin-scroll-eip4844-support-audit-2024-04.md](<reports/openzeppelin-scroll-eip4844-support-audit-2024-04.md>)
- Auditor: OpenZeppelin
- Date: 2024-04-15
- Description: OpenZeppelin audit of the EIP-4844 support changes of scroll-tech/scroll between base commit 02415a6 and head commit 8bd4277 (pull request 1179), covering ScrollChain, MultipleVersionRollupVerifier and the batch header and chunk codecs. Newly introduced contracts were fully audited while modified contracts were reviewed only on the diff.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/IScrollChain.sol"><code>8bd4277c13ec17670963848a24e4e1b135504f3f</code></a> | March 22, 2024 | <code>contracts/src/L1/rollup/IScrollChain.sol</code><br><code>contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/libraries/verifier/IRollupVerifier.sol</code><br><code>contracts/src/libraries/codec/BatchHeaderV0Codec.sol</code><br><code>contracts/src/libraries/codec/ChunkCodecV0.sol</code><br><code>contracts/src/libraries/codec/BatchHeaderV1Codec.sol</code><br><code>contracts/src/libraries/codec/ChunkCodecV1.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/cbb65d78da1286bddeadbb8255a8e3d990a742f2/contracts/src/L1/rollup/ScrollChain.sol"><code>cbb65d78da1286bddeadbb8255a8e3d990a742f2</code></a> | April 3, 2024 | <code>contracts/src/L1/rollup/ScrollChain.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/5425ce725cc60d154e112610ee380d05e23689e5/contracts/src/L1/rollup/IScrollChain.sol"><code>5425ce725cc60d154e112610ee380d05e23689e5</code></a> | April 9, 2024 | <code>contracts/src/L1/rollup/IScrollChain.sol</code><br><code>contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol</code><br><code>contracts/src/L1/rollup/ScrollChain.sol</code><br><code>contracts/src/libraries/verifier/IRollupVerifier.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/c03cdada92b6c4bd6087298295a047cc66c8957f/contracts/src/L1/rollup/ScrollChain.sol"><code>c03cdada92b6c4bd6087298295a047cc66c8957f</code></a> | April 12, 2024 | <code>contracts/src/L1/rollup/ScrollChain.sol</code> |

## Scroll ZkEVM EIP-4844 Blob Support - Security Assessment

- Report: [trailofbits-scroll-zkevm-eip4844-blob-2024-04.md](<reports/trailofbits-scroll-zkevm-eip4844-blob-2024-04.md>)
- Auditor: Trail of Bits
- Date: 2024-04-29
- Description: Trail of Bits review of the EIP-4844 blob support added to Scroll&#x27;s zkEVM circuits, covering the aggregator&#x27;s barycentric evaluation and blob serialization circuits and the related public-input and transaction circuit changes. One high-severity weak Fiat-Shamir issue was reported and its fix reviewed.

### Repository: <a href="https://github.com/scroll-tech/zkevm-circuits"><code>scroll-tech/zkevm-circuits</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/094450f9b89cd1d9499987dbbe39ff11a94c585f/aggregator/src/aggregation/barycentric.rs"><code>094450f9b89cd1d9499987dbbe39ff11a94c585f</code></a> | April 1, 2024 | <code>aggregator/src/aggregation/barycentric.rs</code><br><code>aggregator/src/aggregation/blob_data.rs</code><br><code>aggregator/src/blob.rs</code><br><code>zkevm-circuits/src/pi_circuit.rs</code><br><code>zkevm-circuits/src/tx_circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/25ef17b2e185a6f234e786264deb2d3567da0886/aggregator/src/blob.rs"><code>25ef17b2e185a6f234e786264deb2d3567da0886</code></a> | April 11, 2024 | <code>aggregator/src/blob.rs</code> |

## Batch Token Bridge Audit

- Report: [openzeppelin-scroll-batch-token-bridge-audit.md](<reports/openzeppelin-scroll-batch-token-bridge-audit.md>)
- Auditor: OpenZeppelin
- Date: 2024-05-17
- Description: OpenZeppelin audit of the batch token bridge contracts (BatchBridgeCodec, L1BatchBridgeGateway and L2BatchBridgeGateway) in scroll-tech/scroll at commit 84f73c7. Only note-level issues were left unresolved.

### Repository: <a href="https://github.com/scroll-tech/scroll"><code>scroll-tech/scroll</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll/blob/84f73c76d2cfd0b07640315fc85e7e43eef98498/contracts/src/batch-bridge/BatchBridgeCodec.sol"><code>84f73c76d2cfd0b07640315fc85e7e43eef98498</code></a> | April 25, 2024 | <code>contracts/src/batch-bridge/BatchBridgeCodec.sol</code><br><code>contracts/src/batch-bridge/L1BatchBridgeGateway.sol</code><br><code>contracts/src/batch-bridge/L2BatchBridgeGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/3d08e40f1e101558d4cd29cf6e07b00c4ba126f0/contracts/src/batch-bridge/L1BatchBridgeGateway.sol"><code>3d08e40f1e101558d4cd29cf6e07b00c4ba126f0</code></a> | May 14, 2024 | <code>contracts/src/batch-bridge/L1BatchBridgeGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/b7cc5c293b7984fbeb8aa7a9f105bcfe27bc77f2/contracts/src/batch-bridge/L1BatchBridgeGateway.sol"><code>b7cc5c293b7984fbeb8aa7a9f105bcfe27bc77f2</code></a> | May 14, 2024 | <code>contracts/src/batch-bridge/L1BatchBridgeGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/7a21e297cbef2ade6fe0fbc5611b1483e23afcce/contracts/src/batch-bridge/L1BatchBridgeGateway.sol"><code>7a21e297cbef2ade6fe0fbc5611b1483e23afcce</code></a> | May 14, 2024 | <code>contracts/src/batch-bridge/L1BatchBridgeGateway.sol</code> |
| <a href="https://github.com/scroll-tech/scroll/blob/900ed4f63c8712342e7c61922377fd4a5bb25b00/contracts/src/batch-bridge/L1BatchBridgeGateway.sol"><code>900ed4f63c8712342e7c61922377fd4a5bb25b00</code></a> | May 14, 2024 | <code>contracts/src/batch-bridge/L1BatchBridgeGateway.sol</code> |

## Scroll zkEVM Proof Circuit Security Assessment

- Report: [Zellic - Scroll zkEVM Proof Circuit Security Assessment.md](<reports/Zellic - Scroll zkEVM Proof Circuit Security Assessment.md>)
- Auditor: Zellic
- Date: 2024-06-05
- Description: Zellic proof-circuit assessment of the changes to Scroll&#x27;s zkEVM circuits introduced by the EIP-5656 (MCOPY) pull requests 1209 and 1255 and the EIP-1153 (transient storage) pull request 1233, asking whether the changes preserve circuit soundness and completeness. Four Critical issues were found in the copy, state and EVM circuits and fixed in follow-up commits.

### Repository: <a href="https://github.com/scroll-tech/zkevm-circuits"><code>scroll-tech/zkevm-circuits</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/53a5bd793ae508635c85599983f53ec3131e8e9b/zkevm-circuits/src/evm_circuit.rs"><code>53a5bd793ae508635c85599983f53ec3131e8e9b</code></a> | April 26, 2024 | <code>zkevm-circuits/src/evm_circuit.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution.rs</code><br><code>zkevm-circuits/src/evm_circuit/step.rs</code><br><code>zkevm-circuits/src/witness/step.rs</code><br><code>zkevm-circuits/src/table.rs</code><br><code>zkevm-circuits/src/witness/rw.rs</code><br><code>zkevm-circuits/src/evm_circuit/param.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/tload.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/tstore.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/sstore.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_write_protection.rs</code><br><code>zkevm-circuits/src/evm_circuit/util/constraint_builder.rs</code><br><code>zkevm-circuits/src/state_circuit/constraint_builder.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/7f47a75e334754d4a73b95ea57450333ef992cc7/zkevm-circuits/src/evm_circuit.rs"><code>7f47a75e334754d4a73b95ea57450333ef992cc7</code></a> | May 10, 2024 | <code>zkevm-circuits/src/evm_circuit.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution.rs</code><br><code>zkevm-circuits/src/evm_circuit/step.rs</code><br><code>zkevm-circuits/src/witness/step.rs</code><br><code>zkevm-circuits/src/copy_circuit/test.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/mcopy.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/error_oog_memory_copy.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/da67af548cf47015710461c2ec70fb46508615fd/zkevm-circuits/src/table.rs"><code>da67af548cf47015710461c2ec70fb46508615fd</code></a> | May 13, 2024 | <code>zkevm-circuits/src/table.rs</code><br><code>zkevm-circuits/src/evm_circuit/execution/mcopy.rs</code><br><code>zkevm-circuits/src/copy_circuit.rs</code><br><code>zkevm-circuits/src/copy_circuit/copy_gadgets.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/92d34c51e6a7b54aa990b23dfde6c6f642be36e0/zkevm-circuits/src/state_circuit/constraint_builder.rs"><code>92d34c51e6a7b54aa990b23dfde6c6f642be36e0</code></a> | May 16, 2024 | <code>zkevm-circuits/src/state_circuit/constraint_builder.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/0c7a5602e1a3cb139c03a169aa58602d97781ac5/zkevm-circuits/src/evm_circuit/util/constraint_builder.rs"><code>0c7a5602e1a3cb139c03a169aa58602d97781ac5</code></a> | May 23, 2024 | <code>zkevm-circuits/src/evm_circuit/util/constraint_builder.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/77f8c2ae59e5668e07cda132d15fc1a2ef858e75/zkevm-circuits/src/copy_circuit.rs"><code>77f8c2ae59e5668e07cda132d15fc1a2ef858e75</code></a> | May 26, 2024 | <code>zkevm-circuits/src/copy_circuit.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/460b2f789fdbc180a76238638237c8134a6f7da4/zkevm-circuits/src/copy_circuit/copy_gadgets.rs"><code>460b2f789fdbc180a76238638237c8134a6f7da4</code></a> | May 27, 2024 | <code>zkevm-circuits/src/copy_circuit/copy_gadgets.rs</code> |
| <a href="https://github.com/scroll-tech/zkevm-circuits/blob/929589e276473cd2937f681046be140192179084/zkevm-circuits/src/evm_circuit/execution/error_oog_memory_copy.rs"><code>929589e276473cd2937f681046be140192179084</code></a> | June 4, 2024 | <code>zkevm-circuits/src/evm_circuit/execution/error_oog_memory_copy.rs</code> |

## Scroll Euclid Upgrade Phase 1 Security Assessment

- Report: [trailofbits-scroll-euclid-phase1-2025-04.md](<reports/trailofbits-scroll-euclid-phase1-2025-04.md>)
- Auditor: Trail of Bits
- Date: 2025-04-04
- Description: Trail of Bits review (February 24 to March 5, 2025) of the Euclid upgrade phase 1: the OpenVM chunk, batch and bundle guest circuits of zkvm-prover, the ScrollChain and post-Euclid verifier contract changes, and a Go command-line state migration checker. Two high-severity soundness issues affecting the batch and bundle circuits were reported.

### Repository: <a href="https://github.com/scroll-tech/zkvm-prover"><code>scroll-tech/zkvm-prover</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/da9c824e9a0751bd5482d00910a187e86350beee/crates/circuits/chunk-circuit"><code>da9c824e9a0751bd5482d00910a187e86350beee</code></a> | February 21, 2025 | <code>crates/circuits/chunk-circuit</code> (recursive directory)<br><code>crates/circuits/batch-circuit</code> (recursive directory)<br><code>crates/circuits/bundle-circuit</code> (recursive directory)<br><code>crates/circuits/types</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/51847c908402d49e0d64005486c19e24f9819f62/crates/circuits/bundle-circuit"><code>51847c908402d49e0d64005486c19e24f9819f62</code></a> | February 27, 2025 | <code>crates/circuits/bundle-circuit</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/3f008792538a33271d116f75beab0e137a10f176/crates/circuits/batch-circuit"><code>3f008792538a33271d116f75beab0e137a10f176</code></a> | March 17, 2025 | <code>crates/circuits/batch-circuit</code> (recursive directory)<br><code>crates/circuits/bundle-circuit</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/f82801f0ab8fb65841814a29419f5e56157bb7e7/crates/circuits/types"><code>f82801f0ab8fb65841814a29419f5e56157bb7e7</code></a> | March 17, 2025 | <code>crates/circuits/types</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/dbcf42499b870c364f6fdb073599c160bdfb0a99/crates/circuits/types"><code>dbcf42499b870c364f6fdb073599c160bdfb0a99</code></a> | March 17, 2025 | <code>crates/circuits/types</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/9d9ed16b136c7f651ca73146aa1572cc30d076e6/crates/circuits/types"><code>9d9ed16b136c7f651ca73146aa1572cc30d076e6</code></a> | March 17, 2025 | <code>crates/circuits/types</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/c58cc17cc380f08d8b3c6df674cf584f817f8f03/crates/circuits/types"><code>c58cc17cc380f08d8b3c6df674cf584f817f8f03</code></a> | March 17, 2025 | <code>crates/circuits/types</code> (recursive directory) |

### Repository: <a href="https://github.com/scroll-tech/scroll-contracts"><code>scroll-tech/scroll-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll-contracts/blob/c382953479f9a919e850e56115924e5711810dfd/src/L1/rollup/ScrollChain.sol"><code>c382953479f9a919e850e56115924e5711810dfd</code></a> | February 14, 2025 | <code>src/L1/rollup/ScrollChain.sol</code><br><code>src/libraries/verifier/ZkEvmVerifierPostEuclid.sol</code><br><code>src/libraries/codec/BatchHeaderV3Codec.sol</code><br><code>.github/workflows/contracts.yml</code><br><code>.github/workflows/docker-release.yml</code> |
| <a href="https://github.com/scroll-tech/scroll-contracts/blob/a2fde3fe9a6e6133151db99cfc00e3c29986f734/.github/workflows/contracts.yml"><code>a2fde3fe9a6e6133151db99cfc00e3c29986f734</code></a> | March 7, 2025 | <code>.github/workflows/contracts.yml</code><br><code>.github/workflows/docker-release.yml</code> |
| <a href="https://github.com/scroll-tech/scroll-contracts/blob/dfbfb0138f8160b704877ae6553e6dc12a8c97b0/.github/workflows/contracts.yml"><code>dfbfb0138f8160b704877ae6553e6dc12a8c97b0</code></a> | March 14, 2025 | <code>.github/workflows/contracts.yml</code><br><code>.github/workflows/docker-release.yml</code> |
| <a href="https://github.com/scroll-tech/scroll-contracts/blob/3e6ae19493027054bc00cc02fb2b46d8e2e875ba/.github/workflows/contracts.yml"><code>3e6ae19493027054bc00cc02fb2b46d8e2e875ba</code></a> | March 14, 2025 | <code>.github/workflows/contracts.yml</code><br><code>.github/workflows/docker-release.yml</code> |

### Repository: <a href="https://github.com/scroll-tech/go-ethereum"><code>scroll-tech/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/go-ethereum/blob/642c35f9906cab9001ac77190e198d18e2a044b5/cmd/migration-checker/main.go"><code>642c35f9906cab9001ac77190e198d18e2a044b5</code></a> | February 21, 2025 | <code>cmd/migration-checker/main.go</code><br><code>.github/workflows</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/go-ethereum/tree/122d0cd256d6705196584e96686de50cf25e8d73/.github/workflows"><code>122d0cd256d6705196584e96686de50cf25e8d73</code></a> | March 14, 2025 | <code>.github/workflows</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/go-ethereum/tree/7361487d43e3e27d923e9a3ce481d332c452caf7/.github/workflows"><code>7361487d43e3e27d923e9a3ce481d332c452caf7</code></a> | March 14, 2025 | <code>.github/workflows</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/go-ethereum/tree/3f26ed18f3a55350751dd8db5b401694154e4430/.github/workflows"><code>3f26ed18f3a55350751dd8db5b401694154e4430</code></a> | March 14, 2025 | <code>.github/workflows</code> (recursive directory) |

## Scroll Euclid Upgrade Phase 2 Security Assessment

- Report: [trailofbits-scroll-euclid-phase2-2025-04.md](<reports/trailofbits-scroll-euclid-phase2-2025-04.md>)
- Auditor: Trail of Bits
- Date: 2025-04-04
- Description: Trail of Bits review (March 6 to 21, 2025) of the Euclid upgrade phase 2: enforced transactions and enforced batches, the move of block information from calldata to blobs, and the associated chunk and batch circuit changes. No soundness or completeness issues were found in the circuits.

### Repository: <a href="https://github.com/scroll-tech/zkvm-prover"><code>scroll-tech/zkvm-prover</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/c5781b608438b3dedccf468d696d99ecf27a110f/crates/circuits/chunk-circuit"><code>c5781b608438b3dedccf468d696d99ecf27a110f</code></a> | March 6, 2025 | <code>crates/circuits/chunk-circuit</code> (recursive directory)<br><code>crates/circuits/batch-circuit</code> (recursive directory)<br><code>crates/circuits/bundle-circuit</code> (recursive directory)<br><code>crates/circuits/types</code> (recursive directory)<br><code>.github/workflows</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/f616e6e9882b384aca04010025521b2689ea1657/.github/workflows"><code>f616e6e9882b384aca04010025521b2689ea1657</code></a> | March 25, 2025 | <code>.github/workflows</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/076b10c6544f22fcdd3c44c0719502fcef915c1c/.github/workflows"><code>076b10c6544f22fcdd3c44c0719502fcef915c1c</code></a> | March 25, 2025 | <code>.github/workflows</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/zkvm-prover/tree/7d18c7462d6afb16b85c92c3177f26908573bc27/.github/workflows"><code>7d18c7462d6afb16b85c92c3177f26908573bc27</code></a> | March 25, 2025 | <code>.github/workflows</code> (recursive directory) |

### Repository: <a href="https://github.com/scroll-tech/scroll-contracts"><code>scroll-tech/scroll-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll-contracts/blob/1a44cc4cd5bb29067051f59c09dd4407511f1a3a/src/L1/rollup/ScrollChain.sol"><code>1a44cc4cd5bb29067051f59c09dd4407511f1a3a</code></a> | March 12, 2025 | <code>src/L1/rollup/ScrollChain.sol</code><br><code>src/L1/rollup/L1MessageQueueV2.sol</code><br><code>src/L1/rollup/L1MessageQueueV1.sol</code><br><code>src/L1/L1ScrollMessenger.sol</code><br><code>src/L1/gateways/EnforcedTxGateway.sol</code><br><code>src/L1/system-contract/SystemConfig.sol</code> |

## Scroll Feynman Upgrade Smart Contract Changes Security Assessment (Summary Report)

- Report: [trailofbits-scroll-feynman-upgrade.md](<reports/trailofbits-scroll-feynman-upgrade.md>)
- Auditor: Trail of Bits
- Date: 2025-07-10
- Description: Trail of Bits summary report of the review (June 30 to July 4, 2025) of the Scroll rollup and bridge smart contract changes for the Feynman upgrade, including the new L2SystemConfig and PauseController contracts, the post-Feynman zkEVM verifier and the L1/L2 messenger changes. The review was performed as a diff against release v2.0.0.

### Repository: <a href="https://github.com/scroll-tech/scroll-contracts"><code>scroll-tech/scroll-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll-contracts/blob/00e2a897db429eb4bc3918d1e40b410a68fb6eac/src/L1/L1ScrollMessenger.sol"><code>00e2a897db429eb4bc3918d1e40b410a68fb6eac</code></a> | June 26, 2025 | <code>src/L1/L1ScrollMessenger.sol</code><br><code>src/L1/rollup/ScrollChain.sol</code><br><code>src/L2/L2ScrollMessenger.sol</code><br><code>src/misc/PauseController.sol</code><br><code>src/L2/L2SystemConfig.sol</code><br><code>src/L2/predeploys/L1GasPriceOracle.sol</code><br><code>src/libraries/verifier/ZkEvmVerifierPostFeynman.sol</code> |

## Scroll-revm &amp; zkVM Guest Program Changes — Security Assessment

- Report: [scroll-internal-feynman-upgrade-audit.md](<reports/scroll-internal-feynman-upgrade-audit.md>)
- Auditor: Scroll (internal)
- Date: 2025-07-21
- Description: Scroll&#x27;s internal security assessment of the two codebases implementing the Feynman upgrade: the scroll-revm crate and the zkVM guest program precompile changes in stateless-block-verifier, both at frozen commits. Nine informational code-hygiene and refactoring findings were reported.

### Repository: <a href="https://github.com/scroll-tech/scroll-revm"><code>scroll-tech/scroll-revm</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll-revm/tree/6c1942f9a8eaf7aae1807654c4ee99d771150fbd/src"><code>6c1942f9a8eaf7aae1807654c4ee99d771150fbd</code></a> | July 1, 2025 | <code>src</code> (recursive directory) |

### Repository: <a href="https://github.com/scroll-tech/stateless-block-verifier"><code>scroll-tech/stateless-block-verifier</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/stateless-block-verifier/tree/daeeb9e193bbb7e3a0438dd823b3b6c3310775ea/crates/precompile"><code>daeeb9e193bbb7e3a0438dd823b3b6c3310775ea</code></a> | June 25, 2025 | <code>crates/precompile</code> (recursive directory) |

## Galileo — Scroll-revm &amp; Stateless Block Verifier — Security Assessment

- Report: [scroll-internal-galileo-upgrade-audit.md](<reports/scroll-internal-galileo-upgrade-audit.md>)
- Auditor: Scroll (internal)
- Date: 2025-11-20
- Description: Scroll&#x27;s internal security assessment of the Galileo upgrade: the stateless-block-verifier workspace that forms the zkVM guest program and the scroll-revm crate, both at the Galileo commits. Eight informational findings were reported and no higher-severity issues.

### Repository: <a href="https://github.com/scroll-tech/stateless-block-verifier"><code>scroll-tech/stateless-block-verifier</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/stateless-block-verifier/tree/40aed436537900b49338b37325c4444e3b408ad8/crates"><code>40aed436537900b49338b37325c4444e3b408ad8</code></a> | November 10, 2025 | <code>crates</code> (recursive directory) |

### Repository: <a href="https://github.com/scroll-tech/scroll-revm"><code>scroll-tech/scroll-revm</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/scroll-revm/tree/a1ac004adf0019d9926defc4e31e6a76a7e558f7/src"><code>a1ac004adf0019d9926defc4e31e6a76a7e558f7</code></a> | November 17, 2025 | <code>src</code> (recursive directory) |

## Private Transfer With USX Smart Contract Security Assessment

- Report: [Zellic - Private Transfer With USX.md](<reports/Zellic - Private Transfer With USX.md>)
- Auditor: Zellic
- Date: 2026-03-18
- Description: Zellic assessment (March 11 to 13, 2026) of the Private Transfer With USX contracts in scroll-tech/usx-contracts, covering the encrypted-recipient private bridge gateways and the USX rebalancer under src/cloak plus the diff of the remaining src contracts. One Critical and one High impact issue were reported and fixed, while two Medium issues were acknowledged without a fix.

### Repository: <a href="https://github.com/scroll-tech/usx-contracts"><code>scroll-tech/usx-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/scroll-tech/usx-contracts/blob/d69433e75e37cab22defbf80b1fd89c4d6a526cc/src/cloak"><code>d69433e75e37cab22defbf80b1fd89c4d6a526cc</code></a> | March 5, 2026 | <code>src/cloak</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/usx-contracts/blob/bba7dcfc740f2dbf76e9021eeb1bcb316167c988/src"><code>bba7dcfc740f2dbf76e9021eeb1bcb316167c988</code></a> | March 10, 2026 | <code>src</code> (recursive directory) |
| <a href="https://github.com/scroll-tech/usx-contracts/blob/27a4597ee0d1848dd18a840079e7bad091f7029b/src/cloak"><code>27a4597ee0d1848dd18a840079e7bad091f7029b</code></a> | March 20, 2026 | <code>src/cloak</code> (recursive directory) |

## Irrelevant reports

### Scroll l2geth Security Assessment

- Report: [irrelevant/trailofbits-scroll-l2geth-initial-2023-08.md](<reports/irrelevant/trailofbits-scroll-l2geth-initial-2023-08.md>)
- Auditor: Trail of Bits
- Date: 2023-09-12
- Description: Trail of Bits review (July 10 to 21, 2023) of l2geth, Scroll&#x27;s fork of go-ethereum that sequences L2 transactions and emits the tracing information consumed by the proving circuits, focused on the diff against upstream go-ethereum. The entire scope is offchain node software, with no onchain contracts or circuits reviewed.

### Scroll l2geth Diff Review Security Assessment (Summary Report)

- Report: [irrelevant/trailofbits-scroll-l2geth-diff-2023-08.md](<reports/irrelevant/trailofbits-scroll-l2geth-diff-2023-08.md>)
- Auditor: Trail of Bits
- Date: 2023-10-06
- Description: Trail of Bits follow-up diff review (August 21 to 25, 2023) of Scroll&#x27;s l2geth at commit be1600f, focused on the newly introduced circuit capacity checker that decides whether a transaction or block is unprovable. The entire scope is offchain node software, with no onchain contracts or circuits reviewed.
