# Audit source summary: arbitrum

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Arbitrum Smart Contracts (ConsenSys Diligence, November 2021)

- Report: [2021_11_05_consensys_diligence_security_audit_core_contracts_token_bridge.md](<reports/2021_11_05_consensys_diligence_security_audit_core_contracts_token_bridge.md>)
- Auditor: ConsenSys Diligence
- Date: 2021-11-05
- Description: Four-week ConsenSys Diligence review of the Arbitrum classic L1 and L2 smart contracts in the arb-bridge-eth and arb-bridge-peripherals packages (rollup, nodes, challenges, inbox/outbox and the token bridge routers and gateways) at one commit. The arch folder and offchain components were out of scope.

### Repository: <a href="https://github.com/OffchainLabs/arbitrum-classic"><code>OffchainLabs/arbitrum-classic</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/arbitrum-classic/commit/d730bc40932c24e239577d16b1737455ab75ee26"><code>d730bc40932c24e239577d16b1737455ab75ee26</code></a> | October 3, 2021 | <code>packages/arb-bridge-eth/contracts/bridge/Bridge.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/BridgeUtils.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/Inbox.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/interfaces/IBridge.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/interfaces/IInbox.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/interfaces/IMessageProvider.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/interfaces/IOutbox.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/interfaces/ISequencerInbox.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/Messages.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/Old_Outbox/OldOutbox.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/Old_Outbox/OutboxEntry.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/Outbox.sol</code><br><code>packages/arb-bridge-eth/contracts/bridge/SequencerInbox.sol</code><br><code>packages/arb-bridge-eth/contracts/challenge/Challenge.sol</code><br><code>packages/arb-bridge-eth/contracts/challenge/ChallengeFactory.sol</code><br><code>packages/arb-bridge-eth/contracts/challenge/ChallengeLib.sol</code><br><code>packages/arb-bridge-eth/contracts/challenge/IChallenge.sol</code><br><code>packages/arb-bridge-eth/contracts/challenge/IChallengeFactory.sol</code><br><code>packages/arb-bridge-eth/contracts/interfaces/IERC20.sol</code><br><code>packages/arb-bridge-eth/contracts/interfaces/IERC721.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/AddressAliasHelper.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/BytesLib.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/Cloneable.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/DebugPrint.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/ICloneable.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/MerkleLib.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/Precompiles.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/ProxyUtil.sol</code><br><code>packages/arb-bridge-eth/contracts/libraries/Whitelist.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/BridgeCreator.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/facets/IRollupFacets.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/facets/RollupAdmin.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/facets/RollupUser.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/INode.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/INodeFactory.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/IRollupCore.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/Node.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/NodeFactory.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/Rollup.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/RollupCore.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/RollupCreator.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/RollupEventBridge.sol</code><br><code>packages/arb-bridge-eth/contracts/rollup/RollupLib.sol</code><br><code>packages/arb-bridge-eth/contracts/validator/GasRefunder.sol</code><br><code>packages/arb-bridge-eth/contracts/validator/IGasRefunder.sol</code><br><code>packages/arb-bridge-eth/contracts/validator/Validator.sol</code><br><code>packages/arb-bridge-eth/contracts/validator/ValidatorUtils.sol</code><br><code>packages/arb-bridge-eth/contracts/validator/ValidatorWalletCreator.sol</code><br><code>packages/arb-bridge-peripherals/contracts/rpc-utils/NodeInterface.sol</code><br><code>packages/arb-bridge-peripherals/contracts/rpc-utils/RetryableTicketCreator.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/arbitrum/gateway/L2ArbitrumGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/arbitrum/gateway/L2CustomGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/arbitrum/gateway/L2ERC20Gateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/arbitrum/gateway/L2GatewayRouter.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/arbitrum/gateway/L2WethGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/arbitrum/IArbToken.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/arbitrum/L2ArbitrumMessenger.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/arbitrum/StandardArbERC20.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/ethereum/gateway/L1ArbitrumExtendedGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/ethereum/gateway/L1ArbitrumGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/ethereum/gateway/L1CustomGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/ethereum/gateway/L1ERC20Gateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/ethereum/gateway/L1GatewayRouter.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/ethereum/gateway/L1WethGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/ethereum/ICustomToken.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/ethereum/L1ArbitrumMessenger.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/aeERC20.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/aeWETH.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/BytesParser.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/ClonableBeaconProxy.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/gateway/GatewayMessageHandler.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/gateway/GatewayRouter.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/gateway/ICustomGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/gateway/ITokenGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/gateway/TokenGateway.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/ITransferAndCall.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/IWETH9.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/L2GatewayToken.sol</code><br><code>packages/arb-bridge-peripherals/contracts/tokenbridge/libraries/TransferAndCallToken.sol</code><br><code>packages/arb-bridge-eth/contracts/arch</code> (recursive directory) (explicitly not audited) |

## Offchain Nitro Security Assessment (Trail of Bits, first Nitro review, 2022)

- Report: [2022_03_14_trail_of_bits_security_audit_nitro_1_of_2.md](<reports/2022_03_14_trail_of_bits_security_audit_nitro_1_of_2.md>)
- Auditor: Trail of Bits
- Date: 2022-05-25
- Description: Sixteen person-week Trail of Bits review of the Arbitrum Nitro repository covering the Rust arbitrator and WAVM, the Go ArbOS (including its go-ethereum modifications), the L1 Solidity contracts in solgen and a partial look at ArbNode, at several commits reviewed during the engagement. External libraries, most node directories and the system economics were out of scope.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/c41f610b86317386d3aaf3ba6093d421f8bfe8c2"><code>c41f610b86317386d3aaf3ba6093d421f8bfe8c2</code></a> | January 10, 2022 | <code>arbitrator</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/5366994adb2f35e6cab5caba44d667823c22fb9f"><code>5366994adb2f35e6cab5caba44d667823c22fb9f</code></a> | January 25, 2022 | <code>arbos</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/d8ab8da84c40f6ef65d5fbf1eb240fec400202b0"><code>d8ab8da84c40f6ef65d5fbf1eb240fec400202b0</code></a> | February 15, 2022 | <code>arbos</code> (recursive directory) (other)<br><code>arbnode</code> (recursive directory) (other)<br><code>arbstate</code> (recursive directory) (other)<br><code>blsSignatures</code> (recursive directory) (other) (explicitly not audited)<br><code>broadcastclient</code> (recursive directory) (other) (explicitly not audited)<br><code>cmd</code> (recursive directory) (other) (explicitly not audited)<br><code>reproducible-wasm</code> (recursive directory) (other) (explicitly not audited)<br><code>statetransfer</code> (recursive directory) (other) (explicitly not audited)<br><code>system_tests</code> (recursive directory) (other) (explicitly not audited)<br><code>util</code> (recursive directory) (other) (explicitly not audited)<br><code>validator</code> (recursive directory) (other) (explicitly not audited)<br><code>wavmio</code> (recursive directory) (other) (explicitly not audited)<br><code>wsbroadcastserver</code> (recursive directory) (other) (explicitly not audited) |
| <a href="https://github.com/OffchainLabs/nitro/commit/77a0422b8ccb8c4406cbccc4c2336d3362f0113f"><code>77a0422b8ccb8c4406cbccc4c2336d3362f0113f</code></a> | February 23, 2022 | <code>solgen</code> (recursive directory) |

## Arbitrum Nitro Smart Contracts (ConsenSys Diligence, June 2022)

- Report: [2022_06_24_consensys_diligence_security_audit_nitro_contracts.md](<reports/2022_06_24_consensys_diligence_security_audit_nitro_contracts.md>)
- Auditor: ConsenSys Diligence
- Date: 2022-06-24
- Description: Seven-week ConsenSys Diligence review of the Nitro L1 contracts in contracts/src (bridge, challenge, osp, state, rollup, libraries) at one commit; offchain Rust/Go components were out of scope, although incidental findings in the validator, arbnode and DAS code are reported separately in Section 6. Two Major findings were reported in the rollup and bridge contracts.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/ae5c3ba600e6bd41b0e3a5090179f5f63cae6bb0"><code>ae5c3ba600e6bd41b0e3a5090179f5f63cae6bb0</code></a> | April 22, 2022 | <code>contracts/src/bridge</code> (recursive directory)<br><code>contracts/src/rollup</code> (recursive directory)<br><code>contracts/src/challenge</code> (recursive directory)<br><code>contracts/src/osp</code> (recursive directory)<br><code>contracts/src/state</code> (recursive directory)<br><code>contracts/src/libraries</code> (recursive directory)<br><code>contracts/src/mocks</code> (recursive directory) (explicitly not audited)<br><code>contracts/src/test-helpers</code> (recursive directory) (explicitly not audited)<br><code>contracts/src/node-interface</code> (recursive directory) (explicitly not audited)<br><code>contracts/src/precompiles</code> (recursive directory) (explicitly not audited) |
| <a href="https://github.com/OffchainLabs/nitro/commit/2f2fb30d49568003a114110a45bc1cbcd3addc52"><code>2f2fb30d49568003a114110a45bc1cbcd3addc52</code></a> | May 2, 2022 | <code>contracts/src/libraries</code> (recursive directory) |

## Arbitrum Nitro Security Assessment (Trail of Bits, second Nitro review, 2022)

- Report: [2022_10_22_trail_of_bits_security_audit_nitro_2_of_2.md](<reports/2022_10_22_trail_of_bits_security_audit_nitro_2_of_2.md>)
- Auditor: Trail of Bits
- Date: 2022-10-10
- Description: Sixteen person-week Trail of Bits review of Arbitrum Nitro before mainnet migration, covering the Go ArbOS (pricing, gas, migration and AnyTrust DAS validation), the bridge contracts and HashProofHelper in nitro/contracts, and the NitroMigrator contract in the classic repository. Validator, arbitrator/prover, DAS server and cryptographic code were out of scope.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/861ba3ca52b112eb545d23a4c3332c8df7d192ee"><code>861ba3ca52b112eb545d23a4c3332c8df7d192ee</code></a> | June 29, 2022 | <code>arbos</code> (recursive directory) (other)<br><code>arbstate/inbox.go</code> (other)<br><code>validator</code> (recursive directory) (other) (explicitly not audited)<br><code>arbitrator/.gitignore</code> (other) (explicitly not audited)<br><code>arbitrator/Cargo.lock</code> (other) (explicitly not audited)<br><code>arbitrator/Cargo.toml</code> (other) (explicitly not audited)<br><code>arbitrator/cbindgen.toml</code> (other) (explicitly not audited)<br><code>arbitrator/prover</code> (recursive directory) (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/Cargo.lock</code> (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/Cargo.toml</code> (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/brotli</code> (recursive directory) (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/go-abi</code> (recursive directory) (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/go-stub</code> (recursive directory) (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/host-io</code> (recursive directory) (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/soft-float/bindings32.c</code> (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/soft-float/bindings64.c</code> (other) (explicitly not audited)<br><code>arbitrator/wasm-libraries/wasi-stub</code> (recursive directory) (other) (explicitly not audited)<br><code>arbitrator/wasm-testsuite/.gitignore</code> (other) (explicitly not audited)<br><code>arbitrator/wasm-testsuite/Cargo.lock</code> (other) (explicitly not audited)<br><code>arbitrator/wasm-testsuite/Cargo.toml</code> (other) (explicitly not audited)<br><code>arbitrator/wasm-testsuite/check.sh</code> (other) (explicitly not audited)<br><code>arbitrator/wasm-testsuite/src</code> (recursive directory) (other) (explicitly not audited) |
| <a href="https://github.com/OffchainLabs/nitro/commit/cc7bd52a5ba27087a86161073f272d1f79fefa0b"><code>cc7bd52a5ba27087a86161073f272d1f79fefa0b</code></a> | July 4, 2022 | <code>contracts/src/bridge</code> (recursive directory)<br><code>contracts/src/osp/HashProofHelper.sol</code> |

### Repository: <a href="https://github.com/OffchainLabs/arbitrum-classic"><code>OffchainLabs/arbitrum-classic</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/arbitrum-classic/commit/9b0b581a97c15daa51fe6b3587c216dedc99d406"><code>9b0b581a97c15daa51fe6b3587c216dedc99d406</code></a> | August 2, 2022 | <code>packages/arb-bridge-eth/contracts/bridge/NitroMigrator.sol</code> |

## Arbitrum Governance Security Assessment (Trail of Bits, governance and token bridge, 2022)

- Report: [2023_06_23_trail_of_bits_security_audit_governance_report_governance_token_bridge.md](<reports/2023_06_23_trail_of_bits_security_audit_governance_report_governance_token_bridge.md>)
- Auditor: Trail of Bits
- Date: 2023-01-06
- Description: Twenty-two person-week Trail of Bits review (October to December 2022) of the Arbitrum DAO governance contracts (token, distributor, timelocks, governor, vesting wallets, upgrade executor and factories) at three commits and of the token bridge contracts with focus on the new reverse custom gateways. Nitro core contracts were out of scope; the single High finding is in the L2ArbitrumGateway.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/e4562df1fd165042f6fc5400063dd4a23d10e855"><code>e4562df1fd165042f6fc5400063dd4a23d10e855</code></a> | November 7, 2022 | <code>src</code> (recursive directory) |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/6bd1a880df96b36508b55a10c8f29327711f3750"><code>6bd1a880df96b36508b55a10c8f29327711f3750</code></a> | November 14, 2022 | <code>src</code> (recursive directory) |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/cf6762d45678847cd901544f90989d852dfdd6ea"><code>cf6762d45678847cd901544f90989d852dfdd6ea</code></a> | December 5, 2022 | <code>src</code> (recursive directory) |

### Repository: <a href="https://github.com/OffchainLabs/token-bridge-contracts"><code>OffchainLabs/token-bridge-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/token-bridge-contracts/commit/b30dfcda019a5756061638677dae9b28384c7275"><code>b30dfcda019a5756061638677dae9b28384c7275</code></a> | November 13, 2022 | <code>contracts/tokenbridge/arbitrum</code> (recursive directory)<br><code>contracts/tokenbridge/ethereum</code> (recursive directory)<br><code>contracts/tokenbridge/libraries</code> (recursive directory) |

## Offchain Labs AIP 1.1 and 1.2 Security Assessment Summary Report (Trail of Bits, May 2023)

- Report: [2023_05_02_trail_of_bits_aips_1.1_and_1.2.md](<reports/2023_05_02_trail_of_bits_aips_1.1_and_1.2.md>)
- Auditor: Trail of Bits
- Date: 2023-05-04
- Description: One-week Trail of Bits review of the governance contracts implementing AIP 1.1 and 1.2: the ArbitrumFoundationVestingWallet, the L2AddressRegistry and the AIP1Point2Action action contract, with a fix review appendix. Only one Low and two Informational findings were reported.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/a2a9c8d01024a9888036eac167116a92a2d595f2"><code>a2a9c8d01024a9888036eac167116a92a2d595f2</code></a> | April 20, 2023 | <code>src/ArbitrumFoundationVestingWallet.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/07d3e88c71c3fde922721837f947cef2868e6d67"><code>07d3e88c71c3fde922721837f947cef2868e6d67</code></a> | April 20, 2023 | <code>src/gov-action-contracts/address-registries/L2AddressRegistry.sol</code><br><code>src/gov-action-contracts/AIPs/AIP1Point2Action.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/9fd2c0b05ad09e8a87523b4acc14bf86d1167f76"><code>9fd2c0b05ad09e8a87523b4acc14bf86d1167f76</code></a> | May 3, 2023 | <code>src/ArbitrumFoundationVestingWallet.sol</code> |

## Arbitrum Chains Challenge Protocol v2 Security Assessment (Trail of Bits, 2023)

- Report: [2023-8-offchain-challenge-protocol-V2-securityreview.md](<reports/2023-8-offchain-challenge-protocol-V2-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2023-08-02
- Description: Twenty engineer-week Trail of Bits review of the in-development challenge protocol v2 (BoLD) repository, covering the Solidity challenge edge and assertion chain contracts, the Go prefix/inclusion proof utilities and the offchain validator edge tracker and challenge watcher, with a fix review appendix. All High findings are in the Go validator and proof utility code; the Solidity contracts received only Low and Informational findings.

### Repository: <a href="https://github.com/OffchainLabs/bold"><code>OffchainLabs/bold</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/bold/compare/a55f3547f3ef7ebe051b4ed5881f9928a8b4fb73...c2cc7813cdc3b8d6be73d3dbc32f9afc9ed536e6"><code>a55f3547f3ef7ebe051b4ed5881f9928a8b4fb73…c2cc7813cdc3b8d6be73d3dbc32f9afc9ed536e6</code></a> (commit range) | March 27, 2023 – June 12, 2023 | <code>contracts/src/challengeV2</code> (recursive directory)<br><code>contracts/src/rollup</code> (recursive directory) |
| <a href="https://github.com/OffchainLabs/bold/commit/0735b4d08ef0ad8fcdc085bdc9f7f3e2adacde00"><code>0735b4d08ef0ad8fcdc085bdc9f7f3e2adacde00</code></a> | June 13, 2023 | <code>contracts/src/rollup</code> (recursive directory) |
| <a href="https://github.com/OffchainLabs/bold/commit/e422f9cbd5986dd05ecccbcaaa6d5ddb0a3d3973"><code>e422f9cbd5986dd05ecccbcaaa6d5ddb0a3d3973</code></a> | June 27, 2023 | <code>contracts/src/rollup</code> (recursive directory) |

## Offchain Labs Security Council Elections Security Assessment Summary Report (Trail of Bits, August 2023)

- Report: [2023_08_09_trail_of_bits_security_council_elections.md](<reports/2023_08_09_trail_of_bits_security_council_elections.md>)
- Auditor: Trail of Bits
- Date: 2023-08-09
- Description: One-week Trail of Bits review of the Security Council election contracts (nominee and member election governors, member removal governor and SecurityCouncilManager) in the governance repository at two commits plus the PR #150 ordering changes. One Medium, one Low and three Informational findings were reported.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/a2b308f241991c71940672c71277429c79af47ee"><code>a2b308f241991c71940672c71277429c79af47ee</code></a> | July 22, 2023 | <code>src/security-council-mgmt</code> (recursive directory) |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/27e66586af4e56d9ced3d7f06c3bbeb2bb2e89ce"><code>27e66586af4e56d9ced3d7f06c3bbeb2bb2e89ce</code></a> | July 24, 2023 | <code>src/security-council-mgmt</code> (recursive directory) |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/f34fac19f4ca3b8813111ecce2a688a30d3a0e7f"><code>f34fac19f4ca3b8813111ecce2a688a30d3a0e7f</code></a> | July 27, 2023 | <code>src/security-council-mgmt</code> (recursive directory) |

## Offchain Labs Governance Actions Security Assessment Summary Report (Trail of Bits, August 2023)

- Report: [2023_08_21_trail_of_bits_governance_actions_summary_report.md](<reports/2023_08_21_trail_of_bits_governance_actions_summary_report.md>)
- Auditor: Trail of Bits
- Date: 2023-08-21
- Description: One-week Trail of Bits review of miscellaneous governance action contracts (L1 pricing fix, sweep receiver, L1 timelock fix), small changes to the Security Council election contracts and their activation actions, the ArbOS upgrade action contracts, and the Nitro contract changes between v1.0.2 and v1.0.3-beta.0. Only one Low and two Informational findings were reported.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/29358c27b0f58e26700dc99a9ae9ae8b206cdd51"><code>29358c27b0f58e26700dc99a9ae9ae8b206cdd51</code></a> | July 31, 2023 | <code>src/gov-action-contracts/AIPs/MiscAIP</code> (recursive directory)<br><code>src/L1ArbitrumTimelock.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/cc36c78f95beeb5d4a7de1500e812f2831c31452"><code>cc36c78f95beeb5d4a7de1500e812f2831c31452</code></a> | August 1, 2023 | <code>src/gov-action-contracts/AIPs/UpgradeArbOS</code> (recursive directory) |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/05acd8c80c4232cee70de8784754e51102d2e170"><code>05acd8c80c4232cee70de8784754e51102d2e170</code></a> | August 10, 2023 | <code>src/security-council-mgmt</code> (recursive directory)<br><code>src/gov-action-contracts/AIPs/SecurityCouncilMgmt</code> (recursive directory) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/2ba206505edd15ad1e177392c454e89479959ca5"><code>2ba206505edd15ad1e177392c454e89479959ca5</code></a> | June 22, 2023 | <code>src</code> (recursive directory) |

## Arbitrum Security Council Election System (Code4rena, August 2023)

- Report: [2023_09_20_code4rena_security_council_election_system.md](<reports/2023_09_20_code4rena_security_council_election_system.md>)
- Auditor: Code4rena
- Date: 2023-09-20
- Description: Code4rena contest (3 to 10 August 2023) on the 20 Security Council election contracts of the governance repository frozen at one commit, including the governors, manager, factory, route builder, activation actions and execution record. One High (signature replay in vote-by-signature) and five Medium findings were reported; the sponsor named a fix commit for the High.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/c18de53820c505fc459f766c1b224810eaeaabc5"><code>c18de53820c505fc459f766c1b224810eaeaabc5</code></a> | August 1, 2023 | <code>src/security-council-mgmt/SecurityCouncilManager.sol</code><br><code>src/security-council-mgmt/governors/SecurityCouncilNomineeElectionGovernor.sol</code><br><code>src/security-council-mgmt/governors/modules/SecurityCouncilNomineeElectionGovernorCountingUpgradeable.sol</code><br><code>src/security-council-mgmt/governors/modules/SecurityCouncilNomineeElectionGovernorTiming.sol</code><br><code>src/security-council-mgmt/governors/SecurityCouncilMemberElectionGovernor.sol</code><br><code>src/security-council-mgmt/governors/modules/SecurityCouncilMemberElectionGovernorCountingUpgradeable.sol</code><br><code>src/security-council-mgmt/governors/SecurityCouncilMemberRemovalGovernor.sol</code><br><code>src/security-council-mgmt/governors/modules/ArbitrumGovernorVotesQuorumFractionUpgradeable.sol</code><br><code>src/security-council-mgmt/governors/modules/ElectionGovernor.sol</code><br><code>src/UpgradeExecRouteBuilder.sol</code><br><code>src/security-council-mgmt/SecurityCouncilMemberSyncAction.sol</code><br><code>src/security-council-mgmt/SecurityCouncilMgmtUtils.sol</code><br><code>src/security-council-mgmt/Common.sol</code><br><code>src/security-council-mgmt/factories/L2SecurityCouncilMgmtFactory.sol</code><br><code>src/gov-action-contracts/AIPs/SecurityCouncilMgmt/GovernanceChainSCMgmtActivationAction.sol</code><br><code>src/gov-action-contracts/AIPs/SecurityCouncilMgmt/L1SCMgmtActivationAction.sol</code><br><code>src/gov-action-contracts/AIPs/SecurityCouncilMgmt/NonGovernanceChainSCMgmtActivationAction.sol</code><br><code>src/gov-action-contracts/AIPs/SecurityCouncilMgmt/SecurityCouncilMgmtUpgradeLib.sol</code><br><code>src/gov-action-contracts/execution-record/KeyValueStore.sol</code><br><code>src/gov-action-contracts/execution-record/ActionExecutionRecord.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/40c7d528a35dd5e23883fd9d997c32e3ff34db79"><code>40c7d528a35dd5e23883fd9d997c32e3ff34db79</code></a> | August 14, 2023 | <code>src/security-council-mgmt/governors/SecurityCouncilNomineeElectionGovernor.sol</code> (explicitly not audited)<br><code>src/security-council-mgmt/governors/SecurityCouncilMemberElectionGovernor.sol</code> (explicitly not audited)<br><code>src/security-council-mgmt/governors/modules/ElectionGovernor.sol</code> (explicitly not audited) |

## Offchain Labs Security Council Elections Upgrade and Sequencer Settings Review (Trail of Bits, January 2024)

- Report: [2024-01-offchainarbitrum-securityreview.md](<reports/2024-01-offchainarbitrum-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-01-16
- Description: One-week Trail of Bits review of two governance pull requests: the Security Council nominee election governor upgrade (PR #231) and the action contracts updating the sequencer inbox maximum time variation (PR #233). Only three Informational findings were reported.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/5be7268ebb1d4553775f1407969486442aa31c62"><code>5be7268ebb1d4553775f1407969486442aa31c62</code></a> | December 29, 2023 | <code>src/gov-action-contracts/AIPs/NomineeGovernorV2UpgradeAction.sol</code><br><code>src/security-council-mgmt/governors/SecurityCouncilNomineeElectionGovernor.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/242bc721cdacaee5affb008e3e1300c6143ba89e"><code>242bc721cdacaee5affb008e3e1300c6143ba89e</code></a> | January 2, 2024 | <code>src/gov-action-contracts/AIPs/SetSeqMaxTimeVariation/AIPSetSequencerInboxMaxTimeVariationArbOneAction.sol</code><br><code>src/gov-action-contracts/AIPs/SetSeqMaxTimeVariation/AIPSetSequencerInboxMaxTimeVariationNovaAction.sol</code><br><code>src/gov-action-contracts/sequencer/SetSequencerInboxMaxTimeVariationAction.sol</code> |

## Offchain Labs ArbOS 20 Security Assessment Summary Report (Trail of Bits, February 2024)

- Report: [2024-02-offchainlabsarbos-securityreview.md](<reports/2024-02-offchainlabsarbos-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-02-13
- Description: Two-week Trail of Bits review of the ArbOS 20 (EIP-4844) upgrade covering the Nitro node changes since consensus-v11, the nitro-contracts changes from six pull requests, and the three AIP-4844 governance action contracts. One High consensus finding (TOB-ARBOS20-2, a missing ArbOS 20 gate in the precompiles) was found in week 1 and its fix was reviewed in week 2.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/ab13ede45ce77cc7a08ef958ee7bfe0f2602590c"><code>ab13ede45ce77cc7a08ef958ee7bfe0f2602590c</code></a> | January 30, 2024 | <code>precompiles</code> (recursive directory) (other)<br><code>arbos</code> (recursive directory) (other)<br><code>arbstate</code> (recursive directory) (other)<br><code>arbitrator/prover</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/cf2eadfcc1039eca9594c4f71477a50f550d7749"><code>cf2eadfcc1039eca9594c4f71477a50f550d7749</code></a> | February 2, 2024 | <code>precompiles</code> (recursive directory) (other)<br><code>arbos</code> (recursive directory) (other)<br><code>arbstate</code> (recursive directory) (other)<br><code>arbitrator/prover</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/5ebb128a8fe6053d618ab2081d7c7ccfc68a35c4"><code>5ebb128a8fe6053d618ab2081d7c7ccfc68a35c4</code></a> | February 9, 2024 | <code>src/bridge/IBridge.sol</code><br><code>src/bridge/ISequencerInbox.sol</code><br><code>src/bridge/SequencerInbox.sol</code><br><code>src/challenge/ChallengeManager.sol</code><br><code>src/libraries/Error.sol</code><br><code>src/libraries/GasRefundEnabled.sol</code><br><code>src/libraries/IGasRefunder.sol</code><br><code>src/libraries/IReader4844.sol</code><br><code>src/osp/OneStepProverHostIo.sol</code><br><code>src/rollup/BridgeCreator.sol</code><br><code>src/rollup/RollupCreator.sol</code><br><code>src/rollup/ValidatorWallet.sol</code><br><code>yul/Reader4844.yul</code> |

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/50027863bb14f20b39686329a2d1d7c40df9f10b"><code>50027863bb14f20b39686329a2d1d7c40df9f10b</code></a> | January 25, 2024 | <code>src/gov-action-contracts/AIPs/AIP4844/AIP4844Action.sol</code><br><code>src/gov-action-contracts/AIPs/AIP4844/SetArbOS20VersionAction.sol</code><br><code>src/gov-action-contracts/AIPs/AIP4844/SetBatchPosterManager.sol</code> |

## Offchain Labs L1-L3 Teleporter Security Assessment Summary Report (Trail of Bits, March 2024)

- Report: [2024-04-offchain-l1-l3-teleporter-securityreview.md](<reports/2024-04-offchain-l1-l3-teleporter-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-03-18
- Description: One-week Trail of Bits review of the L1-L3 Teleporter contracts that move ERC20 tokens from Ethereum to Orbit chains through Arbitrum, focused on theft or trapping of funds and incorrect fees. Only five Informational findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/l1-l3-teleport-contracts"><code>OffchainLabs/l1-l3-teleport-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/l1-l3-teleport-contracts/commit/6a764526843965ace519c6e066fc8d90e9d43fbe"><code>6a764526843965ace519c6e066fc8d90e9d43fbe</code></a> | February 9, 2024 | <code>contracts</code> (recursive directory) |

## Code Assessment of the Fund Distribution Smart Contracts (ChainSecurity, March 2024)

- Report: [2024_03_20_chainsecurity_offchain_fund_distribution_nova_fee_router.md](<reports/2024_03_20_chainsecurity_offchain_fund_distribution_nova_fee_router.md>)
- Auditor: ChainSecurity
- Date: 2024-03-20
- Description: ChainSecurity assessment of the Offchain Labs fee router contracts (ChildToParentRewardRouter, ParentToChildRewardRouter, DistributionInterval) that route funds from Nova and Orbit chains to the Arbitrum DAO treasury, at an initial and a final version. Only two Informational findings were reported and both were corrected.

### Repository: <a href="https://github.com/OffchainLabs/fund-distribution-contracts"><code>OffchainLabs/fund-distribution-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/fund-distribution-contracts/commit/5d945cf8d2d100928117e1b523257ebd7146fef1"><code>5d945cf8d2d100928117e1b523257ebd7146fef1</code></a> | March 1, 2024 | <code>src/FeeRouter/ChildToParentRewardRouter.sol</code><br><code>src/FeeRouter/DistributionInterval.sol</code><br><code>src/FeeRouter/ParentToChildRewardRouter.sol</code> |
| <a href="https://github.com/OffchainLabs/fund-distribution-contracts/commit/61f4f60384e2ecba8250287dfb2778ce30bd82b0"><code>61f4f60384e2ecba8250287dfb2778ce30bd82b0</code></a> | March 19, 2024 | <code>src/FeeRouter/ChildToParentRewardRouter.sol</code><br><code>src/FeeRouter/DistributionInterval.sol</code><br><code>src/FeeRouter/ParentToChildRewardRouter.sol</code> |

## Offchain Labs BOLD Challenge Protocol Updates Security Assessment Summary Report (Trail of Bits, April 2024)

- Report: [2024-04-offchainbold-securityreview.md](<reports/2024-04-offchainbold-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-05-02
- Description: Five engineer-week Trail of Bits review of the BOLD challenge protocol updates (multi-level big steps, mini stakes, bottom-up timers), the new assertion staking pool, and the sequencer inbox delay buffer feature in nitro-contracts PR #160. One Low and five Informational findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/bold"><code>OffchainLabs/bold</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/bold/commit/c4e068b568ff662f49ed191c5c3188ea7b6138b2"><code>c4e068b568ff662f49ed191c5c3188ea7b6138b2</code></a> | April 5, 2024 | <code>contracts/src/challengeV2</code> (recursive directory)<br><code>contracts/src/rollup</code> (recursive directory)<br><code>contracts/src/assertionStakingPool</code> (recursive directory) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/7ed6725230c18cb8056bade423643bd5714b0a86"><code>7ed6725230c18cb8056bade423643bd5714b0a86</code></a> | May 6, 2024 | <code>src/bridge/AbsInbox.sol</code><br><code>src/bridge/DelayBuffer.sol</code><br><code>src/bridge/DelayBufferTypes.sol</code><br><code>src/bridge/IInboxBase.sol</code><br><code>src/bridge/ISequencerInbox.sol</code><br><code>src/bridge/Messages.sol</code><br><code>src/bridge/SequencerInbox.sol</code><br><code>src/libraries/Error.sol</code><br><code>src/rollup/BridgeCreator.sol</code><br><code>src/rollup/Config.sol</code><br><code>src/rollup/RollupCreator.sol</code> |

## Arbitrum Stylus Security Assessment (Trail of Bits, 2024)

- Report: [2024-05-offchain-arbitrumstylus-securityreview.md](<reports/2024-05-offchain-arbitrumstylus-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-06-10
- Description: Eleven-week Trail of Bits review of Stylus: the WASM virtual machine, program activation, native/JIT/prover execution modes, host I/O, memory model and co-threads in the arbitrator and ArbOS, the Stylus OSP and machine-state contracts, the Wasmer fork modifications and the Stylus go-ethereum changes. Two High findings (storage cache desynchronization and an incorrect data pricer update) and several Medium findings were reported; the Stylus SDK was out of scope.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/compare/fc0a69d9a9e9fecfa7ae7ed028d16fc84b4ee62a...4d47f3cfb3feb257c503b87a30ec583aa23fa6d0"><code>fc0a69d9a9e9fecfa7ae7ed028d16fc84b4ee62a…4d47f3cfb3feb257c503b87a30ec583aa23fa6d0</code></a> (commit range) | September 14, 2023 – March 8, 2024 | <code>arbos/programs</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other)<br><code>arbitrator/.gitignore</code> (other)<br><code>arbitrator/Cargo.lock</code> (other)<br><code>arbitrator/Cargo.toml</code> (other)<br><code>arbitrator/arbutil</code> (recursive directory) (other)<br><code>arbitrator/jit</code> (recursive directory) (other)<br><code>arbitrator/prover</code> (recursive directory) (other)<br><code>arbitrator/stylus</code> (recursive directory) (other)<br><code>arbitrator/tools/module_roots</code> (recursive directory) (other)<br><code>arbitrator/wasm-libraries/Cargo.lock</code> (other)<br><code>arbitrator/wasm-libraries/Cargo.toml</code> (other)<br><code>arbitrator/wasm-libraries/brotli</code> (recursive directory) (other)<br><code>arbitrator/wasm-libraries/host-io</code> (recursive directory) (other)<br><code>arbitrator/wasm-libraries/soft-float/bindings32.c</code> (other)<br><code>arbitrator/wasm-libraries/soft-float/bindings64.c</code> (other)<br><code>arbitrator/wasm-libraries/user-host</code> (recursive directory) (other)<br><code>arbitrator/wasm-libraries/user-test</code> (recursive directory) (other)<br><code>arbitrator/wasm-libraries/wasi-stub</code> (recursive directory) (other)<br><code>arbitrator/wasm-testsuite/.gitignore</code> (other)<br><code>arbitrator/wasm-testsuite/Cargo.lock</code> (other)<br><code>arbitrator/wasm-testsuite/Cargo.toml</code> (other)<br><code>arbitrator/wasm-testsuite/check.sh</code> (other)<br><code>arbitrator/wasm-testsuite/src</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/4d47f3cfb3feb257c503b87a30ec583aa23fa6d0"><code>4d47f3cfb3feb257c503b87a30ec583aa23fa6d0</code></a> | March 8, 2024 | <code>arbitrator/caller-env</code> (recursive directory) (other)<br><code>arbitrator/wasm-libraries/forward</code> (recursive directory) (other)<br><code>arbitrator/wasm-libraries/program-exec</code> (recursive directory) (other)<br><code>arbitrator/wasm-libraries/user-host-trait</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/bb98714f2deb1ea3d20b898531fef0de28ecd622"><code>bb98714f2deb1ea3d20b898531fef0de28ecd622</code></a> | December 13, 2023 | <code>src/osp</code> (recursive directory)<br><code>src/state</code> (recursive directory) |

### Repository: <a href="https://github.com/OffchainLabs/wasmer"><code>OffchainLabs/wasmer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/wasmer/commit/80125b5627040db0b0ec4b94ba687e1f7a491f0c"><code>80125b5627040db0b0ec4b94ba687e1f7a491f0c</code></a> | August 14, 2023 | <code>lib/vm</code> (recursive directory) (other)<br><code>lib/types</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/go-ethereum"><code>OffchainLabs/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/go-ethereum/compare/27113b8c17690a445e8d66b5988d5e34b42a574f...991e082187b708436123cd46cef846e6cb08d8a2"><code>27113b8c17690a445e8d66b5988d5e34b42a574f…991e082187b708436123cd46cef846e6cb08d8a2</code></a> (commit range) | September 14, 2023 – October 16, 2023 | <code>core/vm</code> (recursive directory) (other) |

## Arbitrum BoLD Findings and Analysis Report (Code4rena, May 2024)

- Report: [2024_06_17_code4rena_security_audit_bold.md](<reports/2024_06_17_code4rena_security_audit_bold.md>)
- Auditor: Code4rena
- Date: 2024-06-17
- Description: Code4rena contest on the BoLD dispute protocol contracts (challenge manager and libraries, rollup logic, BOLD upgrade action, staking pools, sequencer inbox delay buffer) frozen at one commit of the contest repository. Two High findings (stake insolvency after a base stake decrease, and timer inheritance from a dishonest edge tree) and two Medium findings were reported, with sponsor-named fix pull requests in the bold repository.

### Repository: <a href="https://github.com/code-423n4/2024-05-arbitrum-foundation"><code>code-423n4/2024-05-arbitrum-foundation</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/code-423n4/2024-05-arbitrum-foundation/commit/6f861c85b281a29f04daacfe17a2099d7dad5f8f"><code>6f861c85b281a29f04daacfe17a2099d7dad5f8f</code></a> | May 11, 2024 | <code>src/libraries/Error.sol</code><br><code>src/challengeV2/IAssertionChain.sol</code><br><code>src/challengeV2/EdgeChallengeManager.sol</code><br><code>src/bridge/SequencerInbox.sol</code><br><code>src/bridge/ISequencerInbox.sol</code><br><code>src/bridge/DelayBufferTypes.sol</code><br><code>src/bridge/DelayBuffer.sol</code><br><code>src/assertionStakingPool/StakingPoolCreatorUtils.sol</code><br><code>src/assertionStakingPool/EdgeStakingPoolCreator.sol</code><br><code>src/assertionStakingPool/EdgeStakingPool.sol</code><br><code>src/assertionStakingPool/AssertionStakingPoolCreator.sol</code><br><code>src/assertionStakingPool/AssertionStakingPool.sol</code><br><code>src/assertionStakingPool/AbsBoldStakingPool.sol</code><br><code>src/rollup/RollupUserLogic.sol</code><br><code>src/rollup/RollupProxy.sol</code><br><code>src/rollup/RollupLib.sol</code><br><code>src/rollup/RollupCreator.sol</code><br><code>src/rollup/RollupCore.sol</code><br><code>src/rollup/RollupAdminLogic.sol</code><br><code>src/rollup/IRollupLogic.sol</code><br><code>src/rollup/IRollupCore.sol</code><br><code>src/rollup/IRollupAdmin.sol</code><br><code>src/rollup/Config.sol</code><br><code>src/rollup/BridgeCreator.sol</code><br><code>src/rollup/BOLDUpgradeAction.sol</code><br><code>src/rollup/AssertionState.sol</code><br><code>src/rollup/Assertion.sol</code><br><code>src/challengeV2/libraries/UintUtilsLib.sol</code><br><code>src/challengeV2/libraries/MerkleTreeLib.sol</code><br><code>src/challengeV2/libraries/Enums.sol</code><br><code>src/challengeV2/libraries/EdgeChallengeManagerLib.sol</code><br><code>src/challengeV2/libraries/ChallengeErrors.sol</code><br><code>src/challengeV2/libraries/ChallengeEdgeLib.sol</code><br><code>src/challengeV2/libraries/ArrayUtilsLib.sol</code><br><code>src/assertionStakingPool/interfaces/IEdgeStakingPoolCreator.sol</code><br><code>src/assertionStakingPool/interfaces/IEdgeStakingPool.sol</code><br><code>src/assertionStakingPool/interfaces/IAssertionStakingPoolCreator.sol</code><br><code>src/assertionStakingPool/interfaces/IAssertionStakingPool.sol</code><br><code>src/assertionStakingPool/interfaces/IAbsBoldStakingPool.sol</code> |

### Repository: <a href="https://github.com/OffchainLabs/bold"><code>OffchainLabs/bold</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/bold/commit/c50a27e9943e5e6fe074e2d88ac553ed219c5b13"><code>c50a27e9943e5e6fe074e2d88ac553ed219c5b13</code></a> | June 3, 2024 | <code>contracts/src/rollup/RollupAdminLogic.sol</code> (explicitly not audited) |
| <a href="https://github.com/OffchainLabs/bold/commit/50cf6de1697def69e8b78bdff219fc80661d358d"><code>50cf6de1697def69e8b78bdff219fc80661d358d</code></a> | June 4, 2024 | <code>contracts/src/challengeV2/libraries/EdgeChallengeManagerLib.sol</code> (explicitly not audited) |

## Offchain Labs ArbOS 30 Nitro Upgrade Security Assessment (Trail of Bits, May 2024)

- Report: [2024-04-offchain-arbos-30-nitro-upgrade-securityreview.md](<reports/2024-04-offchain-arbos-30-nitro-upgrade-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-07-26
- Description: Six engineer-week Trail of Bits review of the ArbOS 30 upgrade: the diff of 20 state-transition files in nitro between consensus-v20 and the ArbOS 30 commit, the go-ethereum fork upgrade diff, the ArbOS 30 and Nova fee routing governance actions, and three nitro-contracts pull requests (conditional OSP, machine hash refactor, initial pricePerUnit). Stylus itself was not audited; one Medium and four Informational findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/compare/cf2eadfcc1039eca9594c4f71477a50f550d7749...b8a9479f77aa358d53e10e2944257a8483ff64a8"><code>cf2eadfcc1039eca9594c4f71477a50f550d7749…b8a9479f77aa358d53e10e2944257a8483ff64a8</code></a> (commit range) | February 2, 2024 – May 7, 2024 | <code>arbos/arbosState/arbosstate.go</code> (other)<br><code>arbos/arbosState/initialize.go</code> (other)<br><code>arbos/block_processor.go</code> (other)<br><code>arbos/l1pricing/l1PricingOldVersions.go</code> (other)<br><code>arbos/l1pricing/l1pricing.go</code> (other)<br><code>arbos/retryables/retryable.go</code> (other)<br><code>arbos/tx_processor.go</code> (other)<br><code>arbos/util/tracing.go</code> (other)<br><code>arbos/util/transfer.go</code> (other)<br><code>arbstate/das_reader.go</code> (other)<br><code>arbstate/inbox.go</code> (other)<br><code>arbutil/wait_for_l1.go</code> (other)<br><code>cmd/replay/main.go</code> (other)<br><code>gethhook/geth-hook.go</code> (other)<br><code>precompiles/ArbGasInfo.go</code> (other)<br><code>precompiles/ArbInfo.go</code> (other)<br><code>precompiles/ArbOwner.go</code> (other)<br><code>precompiles/precompile.go</code> (other)<br><code>util/arbmath/bips.go</code> (other)<br><code>util/blobs/blobs.go</code> (other) |

### Repository: <a href="https://github.com/OffchainLabs/go-ethereum"><code>OffchainLabs/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/1acd9c64ac5804729475ef60aa578b4ec52fa0e6"><code>1acd9c64ac5804729475ef60aa578b4ec52fa0e6</code></a> | January 28, 2024 | <code>core/rawdb/databases_64bit.go</code> (other)<br><code>crypto/blake2b/blake2b_f_fuzz.go</code> (other)<br><code>log/doc.go</code> (other)<br><code>log/syslog.go</code> (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/compare/1acd9c64ac5804729475ef60aa578b4ec52fa0e6...92b91d3fac58e7aed688f685aa8d27665f4cd47c"><code>1acd9c64ac5804729475ef60aa578b4ec52fa0e6…92b91d3fac58e7aed688f685aa8d27665f4cd47c</code></a> (commit range) | January 28, 2024 – May 2, 2024 | <code>accounts/abi/abi.go</code> (other)<br><code>accounts/abi/argument.go</code> (other)<br><code>accounts/abi/bind/auth.go</code> (other)<br><code>accounts/abi/bind/backend.go</code> (other)<br><code>accounts/abi/bind/base.go</code> (other)<br><code>accounts/abi/bind/bind.go</code> (other)<br><code>accounts/abi/error.go</code> (other)<br><code>accounts/abi/method.go</code> (other)<br><code>accounts/abi/pack.go</code> (other)<br><code>accounts/abi/reflect.go</code> (other)<br><code>accounts/abi/topics.go</code> (other)<br><code>accounts/keystore/passphrase.go</code> (other)<br><code>accounts/keystore/watch.go</code> (other)<br><code>accounts/manager.go</code> (other)<br><code>common/big.go</code> (other)<br><code>common/hexutil/json.go</code> (other)<br><code>common/types.go</code> (other)<br><code>consensus/misc/dao.go</code> (other)<br><code>core/arbitrum_hooks.go</code> (other)<br><code>core/blockchain.go</code> (other)<br><code>core/blockchain_arbitrum.go</code> (other)<br><code>core/blockchain_reader.go</code> (other)<br><code>core/chain_makers.go</code> (other)<br><code>core/error.go</code> (other)<br><code>core/evm.go</code> (other)<br><code>core/genesis.go</code> (other)<br><code>core/rawdb/accessors_chain.go</code> (other)<br><code>core/rawdb/accessors_trie.go</code> (other)<br><code>core/rawdb/ancient_scheme.go</code> (other)<br><code>core/rawdb/ancient_utils.go</code> (other)<br><code>core/rawdb/chain_freezer.go</code> (other)<br><code>core/rawdb/chain_iterator.go</code> (other)<br><code>core/rawdb/database.go</code> (other)<br><code>core/rawdb/freezer_batch.go</code> (other)<br><code>core/rawdb/freezer_resettable.go</code> (other)<br><code>core/rawdb/freezer_table.go</code> (other)<br><code>core/rawdb/freezer_utils.go</code> (other)<br><code>core/rawdb/schema.go</code> (other)<br><code>core/state/database.go</code> (other)<br><code>core/state/dump.go</code> (other)<br><code>core/state/iterator.go</code> (other)<br><code>core/state/journal.go</code> (other)<br><code>core/state/snapshot/conversion.go</code> (other)<br><code>core/state/snapshot/difflayer.go</code> (other)<br><code>core/state/snapshot/disklayer.go</code> (other)<br><code>core/state/snapshot/generate.go</code> (other)<br><code>core/state/snapshot/snapshot.go</code> (other)<br><code>core/state/state_object.go</code> (other)<br><code>core/state/statedb.go</code> (other)<br><code>core/state/statedb_arbitrum.go</code> (other)<br><code>core/state/trie_prefetcher.go</code> (other)<br><code>core/state_processor.go</code> (other)<br><code>core/state_transition.go</code> (other)<br><code>core/types/arbitrum_legacy_tx.go</code> (other)<br><code>core/types/gen_account_rlp.go</code> (other)<br><code>core/types/hashes.go</code> (other)<br><code>core/types/state_account.go</code> (other)<br><code>core/types/transaction.go</code> (other)<br><code>core/types/transaction_marshalling.go</code> (other)<br><code>core/types/tx_blob.go</code> (other)<br><code>core/vm/contract.go</code> (other)<br><code>core/vm/contracts.go</code> (other)<br><code>core/vm/contracts_arbitrum.go</code> (other)<br><code>core/vm/eips.go</code> (other)<br><code>core/vm/evm.go</code> (other)<br><code>core/vm/instructions.go</code> (other)<br><code>core/vm/interface.go</code> (other)<br><code>core/vm/jump_table.go</code> (other)<br><code>core/vm/opcodes.go</code> (other)<br><code>core/vm/operations_acl.go</code> (other)<br><code>crypto/kzg4844/kzg4844.go</code> (other)<br><code>ethdb/memorydb/memorydb.go</code> (other)<br><code>ethdb/pebble/pebble.go</code> (other)<br><code>event/subscription.go</code> (other)<br><code>log/format.go</code> (other)<br><code>log/handler.go</code> (other)<br><code>log/handler_glog.go</code> (other)<br><code>log/logger.go</code> (other)<br><code>log/root.go</code> (other)<br><code>metrics/disk_nop.go</code> (other)<br><code>metrics/timer.go</code> (other)<br><code>params/bootnodes.go</code> (other)<br><code>params/config.go</code> (other)<br><code>params/protocol_params.go</code> (other)<br><code>params/version.go</code> (other)<br><code>rpc/json.go</code> (other)<br><code>rpc/metrics.go</code> (other)<br><code>rpc/service.go</code> (other)<br><code>rpc/subscription.go</code> (other)<br><code>rpc/types.go</code> (other)<br><code>signer/core/apitypes/types.go</code> (other)<br><code>trie/database.go</code> (other)<br><code>trie/hasher.go</code> (other)<br><code>trie/iterator.go</code> (other)<br><code>trie/proof.go</code> (other)<br><code>trie/stacktrie.go</code> (other)<br><code>trie/sync.go</code> (other)<br><code>trie/triedb/hashdb/database.go</code> (other)<br><code>trie/triedb/pathdb/database.go</code> (other)<br><code>trie/triedb/pathdb/disklayer.go</code> (other)<br><code>trie/triedb/pathdb/history.go</code> (other)<br><code>trie/trienode/node.go</code> (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/92b91d3fac58e7aed688f685aa8d27665f4cd47c"><code>92b91d3fac58e7aed688f685aa8d27665f4cd47c</code></a> | May 2, 2024 | <code>core/txindexer.go</code> (other)<br><code>crypto/secp256r1/pubkey.go</code> (other)<br><code>crypto/secp256r1/verifier.go</code> (other)<br><code>ethdb/pebble/pebble_non64bit.go</code> (other)<br><code>params/forks/forks.go</code> (other)<br><code>trie/utils/verkle.go</code> (other)<br><code>trie/verkle.go</code> (other) |

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/be8a171dfd6e342de99e4f5394dc4c901eec4ad0"><code>be8a171dfd6e342de99e4f5394dc4c901eec4ad0</code></a> | May 3, 2024 | <code>src/gov-action-contracts/AIPs/AIPNovaFeeRoutingAction.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/2ccc8394190f57112448bc5e8ad4d1ebe6f3bcf2"><code>2ccc8394190f57112448bc5e8ad4d1ebe6f3bcf2</code></a> | June 17, 2024 | <code>src/gov-action-contracts/AIPs/AIPArbOS30/ArbOneAIPArbOS30AddWasmCacheManagerAction.sol</code><br><code>src/gov-action-contracts/AIPs/AIPArbOS30/ArbOneAIPArbOS30UpgradeChallengeManagerAction.sol</code><br><code>src/gov-action-contracts/AIPs/AIPArbOS30/NovaAIPArbOS30AddWasmCacheManagerAction.sol</code><br><code>src/gov-action-contracts/AIPs/AIPArbOS30/NovaAIPArbOS30UpgradeChallengeManagerAction.sol</code><br><code>src/gov-action-contracts/AIPs/AIPArbOS30/SetArbOS30VersionAction.sol</code><br><code>src/gov-action-contracts/AIPs/AIPArbOS30/parent_contracts/AIPArbOS30AddWasmCacheManagerAction.sol</code><br><code>src/gov-action-contracts/AIPs/AIPArbOS30/parent_contracts/AIPArbOS30UpgradeChallengeManagerAction.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/78da6ad8dca593aaa7267a4b6521b95c629d4704"><code>78da6ad8dca593aaa7267a4b6521b95c629d4704</code></a> | July 9, 2024 | <code>src/gov-action-contracts/AIPs/AIPNovaFeeRoutingAction.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/163d7fa771ce2f7cf383ac43eaf11b23b23eb6d2"><code>163d7fa771ce2f7cf383ac43eaf11b23b23eb6d2</code></a> | July 12, 2024 | <code>src/gov-action-contracts/arbos-upgrade/UpgradeArbOSVersionAtTimestampAction.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/9e5c54bbf7dce36eee89410139be1b94f4352db6"><code>9e5c54bbf7dce36eee89410139be1b94f4352db6</code></a> | July 24, 2024 | <code>src/gov-action-contracts/AIPs/AIPNovaFeeRoutingAction.sol</code> |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/026578eab8c2dc92b0e90efc48bf9242a12f20f4"><code>026578eab8c2dc92b0e90efc48bf9242a12f20f4</code></a> | April 26, 2024 | <code>src/challenge/ChallengeLib.sol</code><br><code>src/challenge/ChallengeManager.sol</code><br><code>src/osp/IOneStepProofEntry.sol</code><br><code>src/osp/OneStepProofEntry.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/09ff1db5fee0023eef2935bd236518f338cdd09c"><code>09ff1db5fee0023eef2935bd236518f338cdd09c</code></a> | April 30, 2024 | <code>src/challenge/ChallengeManager.sol</code><br><code>src/challenge/IChallengeManager.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/de1852c9a825cfed87aae581db318637a2b8fb8c"><code>de1852c9a825cfed87aae581db318637a2b8fb8c</code></a> | July 3, 2024 | <code>src/rollup/AbsRollupEventInbox.sol</code><br><code>src/rollup/ERC20RollupEventInbox.sol</code><br><code>src/rollup/RollupEventInbox.sol</code> |

## Offchain Labs ArbOS 31 Stylus and BoLD Pull Requests Review (Trail of Bits, June 2024)

- Report: [2024-04-offchain-arbos-31-securityreview.md](<reports/2024-04-offchain-arbos-31-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-07-26
- Description: One-week Trail of Bits review of Nitro pull requests for ArbOS 31 (Stylus cache costs, Stylus v2, return-data pricing) and of nitro-contracts pull requests adding AnyTrust fast confirmation and Sepolia deployment configuration. One Medium (fast confirmer must be a validator) and one Low finding were reported and their fixes reviewed.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/dd8cf656831ecb25c9e9001fc65148c362cb5c5d"><code>dd8cf656831ecb25c9e9001fc65148c362cb5c5d</code></a> | June 26, 2024 | <code>arbitrator/prover/src/binary.rs</code> (other)<br><code>arbitrator/prover/src/programs/config.rs</code> (other)<br><code>arbos/arbosState/arbosstate.go</code> (other)<br><code>arbos/programs/params.go</code> (other)<br><code>arbos/programs/programs.go</code> (other)<br><code>arbos/tx_processor.go</code> (other)<br><code>precompiles/ArbWasmCache.go</code> (other)<br><code>precompiles/precompile.go</code> (other) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/7142dd860341edb3b25f1cf8bbd082ce226e31b3"><code>7142dd860341edb3b25f1cf8bbd082ce226e31b3</code></a> | July 1, 2024 | <code>src/chain/CacheManager.sol</code><br><code>src/precompiles/ArbWasmCache.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/5cf93d20ebffade9ba6de90b998e4b181bcf58ac"><code>5cf93d20ebffade9ba6de90b998e4b181bcf58ac</code></a> | July 3, 2024 | <code>src/rollup/IRollupLogic.sol</code><br><code>src/rollup/RollupAdminLogic.sol</code><br><code>src/rollup/RollupCore.sol</code><br><code>src/rollup/RollupUserLogic.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/e586d8e1fe146aaf2daced8aa88be582552d7456"><code>e586d8e1fe146aaf2daced8aa88be582552d7456</code></a> | July 29, 2024 | <code>src/rollup/IRollupLogic.sol</code><br><code>src/rollup/RollupUserLogic.sol</code> |

## Offchain Labs Arbitrum Token Bridge Creator Security Assessment Summary Report (Trail of Bits, December 2023)

- Report: [2024-07-offchain-labs-arbitrum-token-bridge-creator-securityreview.md](<reports/2024-07-offchain-labs-arbitrum-token-bridge-creator-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-07-29
- Description: Two-week Trail of Bits review of the atomic Token Bridge Creator contracts in the private token-bridge-contracts repository (PRs #16 and #21) and of nitro-contracts PR #100 (native token decimals), with a fix review. The one High finding (TOB-ARB-TBC-002, griefing of L2 token bridge deployment) is located in the private repository and was resolved during the fix review.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/645e51d17509eaa9294d4b42fdcdf0527f954d42"><code>645e51d17509eaa9294d4b42fdcdf0527f954d42</code></a> | December 13, 2023 | <code>src/bridge/AbsInbox.sol</code><br><code>src/bridge/AbsOutbox.sol</code><br><code>src/bridge/ERC20Bridge.sol</code><br><code>src/bridge/ERC20Inbox.sol</code><br><code>src/bridge/ERC20Outbox.sol</code><br><code>src/bridge/IERC20Bridge.sol</code><br><code>src/bridge/IERC20Inbox.sol</code><br><code>src/bridge/IInbox.sol</code><br><code>src/bridge/Inbox.sol</code><br><code>src/bridge/Outbox.sol</code><br><code>src/libraries/Constants.sol</code><br><code>src/libraries/DecimalsConverterHelper.sol</code><br><code>src/libraries/Error.sol</code><br><code>src/rollup/DeployHelper.sol</code><br><code>src/rollup/RollupCreator.sol</code> |

### Repository: <a href="https://github.com/OffchainLabs/token-bridge-contracts-private"><code>OffchainLabs/token-bridge-contracts-private</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Offchain Labs Custom Fee Token Security Assessment Summary Report (Trail of Bits, 2023)

- Report: [2024-08-offchain-labs-custom-fee-token-securityreview.md](<reports/2024-08-offchain-labs-custom-fee-token-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-08-01
- Description: Three engineer-week Trail of Bits review of the pull requests adding ERC20 custom fee token rollups to nitro-contracts (PR #19) and to the token bridge (PRs #33 and #34), focused on the changes rather than the full repositories. Two High findings were reported: unsafe ERC20 assumptions in ERC20Bridge and ether becoming locked in the L1OrbitERC20Gateway.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/7dc1aa43829d9f4afe7251ad28d96a5d0e1d48c7"><code>7dc1aa43829d9f4afe7251ad28d96a5d0e1d48c7</code></a> | September 14, 2023 | <code>src/bridge/AbsBridge.sol</code><br><code>src/bridge/AbsInbox.sol</code><br><code>src/bridge/AbsOutbox.sol</code><br><code>src/bridge/Bridge.sol</code><br><code>src/bridge/ERC20Bridge.sol</code><br><code>src/bridge/ERC20Inbox.sol</code><br><code>src/bridge/ERC20Outbox.sol</code><br><code>src/bridge/IBridge.sol</code><br><code>src/bridge/IERC20Bridge.sol</code><br><code>src/bridge/IERC20Inbox.sol</code><br><code>src/bridge/IEthBridge.sol</code><br><code>src/bridge/IInbox.sol</code><br><code>src/bridge/IInboxBase.sol</code><br><code>src/bridge/IOutbox.sol</code><br><code>src/bridge/Inbox.sol</code><br><code>src/bridge/Outbox.sol</code><br><code>src/bridge/SequencerInbox.sol</code><br><code>src/libraries/Error.sol</code><br><code>src/rollup/AbsRollupEventInbox.sol</code><br><code>src/rollup/BridgeCreator.sol</code><br><code>src/rollup/Config.sol</code><br><code>src/rollup/DeployHelper.sol</code><br><code>src/rollup/ERC20RollupEventInbox.sol</code><br><code>src/rollup/IRollupCore.sol</code><br><code>src/rollup/RollupAdminLogic.sol</code><br><code>src/rollup/RollupCore.sol</code><br><code>src/rollup/RollupCreator.sol</code><br><code>src/rollup/RollupEventInbox.sol</code><br><code>src/rollup/RollupLib.sol</code> |

### Repository: <a href="https://github.com/OffchainLabs/token-bridge-contracts"><code>OffchainLabs/token-bridge-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/token-bridge-contracts/commit/6396a178e001da2b86509bb21c775488530fd541"><code>6396a178e001da2b86509bb21c775488530fd541</code></a> | September 7, 2023 | <code>contracts/rpc-utils/NodeInterface.sol</code><br><code>contracts/rpc-utils/RetryableTicketCreator.sol</code><br><code>contracts/tokenbridge/arbitrum/L2ArbitrumMessenger.sol</code><br><code>contracts/tokenbridge/arbitrum/StandardArbERC20.sol</code><br><code>contracts/tokenbridge/arbitrum/gateway/L2ArbitrumGateway.sol</code><br><code>contracts/tokenbridge/arbitrum/gateway/L2CustomGateway.sol</code><br><code>contracts/tokenbridge/arbitrum/gateway/L2ERC20Gateway.sol</code><br><code>contracts/tokenbridge/arbitrum/gateway/L2GatewayRouter.sol</code><br><code>contracts/tokenbridge/arbitrum/gateway/L2ReverseCustomGateway.sol</code><br><code>contracts/tokenbridge/arbitrum/gateway/L2WethGateway.sol</code><br><code>contracts/tokenbridge/ethereum/ICustomToken.sol</code><br><code>contracts/tokenbridge/ethereum/L1ArbitrumMessenger.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ArbitrumExtendedGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ArbitrumGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1CustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ERC20Gateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ForceOnlyReverseCustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1GatewayRouter.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ReverseCustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1WethGateway.sol</code><br><code>contracts/tokenbridge/libraries/AddressAliasHelper.sol</code><br><code>contracts/tokenbridge/libraries/BytesLib.sol</code><br><code>contracts/tokenbridge/libraries/BytesParser.sol</code><br><code>contracts/tokenbridge/libraries/ClonableBeaconProxy.sol</code><br><code>contracts/tokenbridge/libraries/Cloneable.sol</code><br><code>contracts/tokenbridge/libraries/ERC165.sol</code><br><code>contracts/tokenbridge/libraries/ERC20Upgradeable.sol</code><br><code>contracts/tokenbridge/libraries/ITransferAndCall.sol</code><br><code>contracts/tokenbridge/libraries/L2CustomGatewayToken.sol</code><br><code>contracts/tokenbridge/libraries/L2GatewayToken.sol</code><br><code>contracts/tokenbridge/libraries/ProxyUtil.sol</code><br><code>contracts/tokenbridge/libraries/TransferAndCallToken.sol</code><br><code>contracts/tokenbridge/libraries/Whitelist.sol</code><br><code>contracts/tokenbridge/libraries/aeERC20.sol</code><br><code>contracts/tokenbridge/libraries/aeWETH.sol</code><br><code>contracts/tokenbridge/libraries/draft-ERC20PermitUpgradeable.sol</code><br><code>contracts/tokenbridge/libraries/gateway/GatewayMessageHandler.sol</code><br><code>contracts/tokenbridge/libraries/gateway/GatewayRouter.sol</code><br><code>contracts/tokenbridge/libraries/gateway/IGatewayRouter.sol</code><br><code>contracts/tokenbridge/libraries/gateway/TokenGateway.sol</code> |
| <a href="https://github.com/OffchainLabs/token-bridge-contracts/commit/9503d3c0ce2d724648602af02e8275c2e2b5959d"><code>9503d3c0ce2d724648602af02e8275c2e2b5959d</code></a> | September 12, 2023 | <code>contracts/tokenbridge/arbitrum/L2AtomicTokenBridgeFactory.sol</code><br><code>contracts/tokenbridge/ethereum/L1ArbitrumMessenger.sol</code><br><code>contracts/tokenbridge/ethereum/L1AtomicTokenBridgeCreator.sol</code><br><code>contracts/tokenbridge/ethereum/L1TokenBridgeRetryableSender.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ArbitrumGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1CustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ERC20Gateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1GatewayRouter.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitCustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitERC20Gateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitGatewayRouter.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitReverseCustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1WethGateway.sol</code><br><code>contracts/tokenbridge/libraries/ERC20Upgradeable.sol</code><br><code>contracts/tokenbridge/libraries/IERC20Bridge.sol</code> |

## Offchain Labs BoLD and DAC Rewards Updates Security Assessment (Trail of Bits, June 2024)

- Report: [2024-06-offchain-labs-bold-dac-rewards-updates-securityreview.md](<reports/2024-06-offchain-labs-bold-dac-rewards-updates-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-08-05
- Description: Three engineer-week Trail of Bits review of a list of BoLD contract pull requests (fixes from earlier audits and the Code4rena contest, staking flow changes, delay buffer merge, upgrade action changes) and of the DAC rewards fee router change supporting Optimism chains. One Medium finding in the fee router was reported.

### Repository: <a href="https://github.com/OffchainLabs/bold"><code>OffchainLabs/bold</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/bold/commit/6b42a38fc28f9b6a7864001fe797b9f07dad6357"><code>6b42a38fc28f9b6a7864001fe797b9f07dad6357</code></a> | June 6, 2024 | <code>contracts/src/challengeV2</code> (recursive directory)<br><code>contracts/src/rollup</code> (recursive directory)<br><code>contracts/src/assertionStakingPool</code> (recursive directory)<br><code>contracts/src/bridge</code> (recursive directory) |

### Repository: <a href="https://github.com/OffchainLabs/fund-distribution-contracts"><code>OffchainLabs/fund-distribution-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/fund-distribution-contracts/commit/b390734d934e6d8b05b78e5ef38739c4b8e668b6"><code>b390734d934e6d8b05b78e5ef38739c4b8e668b6</code></a> | April 2, 2024 | <code>src/FeeRouter</code> (recursive directory) |

## Offchain Labs Bridged USDC Custom Gateway Security Assessment Summary Report (Trail of Bits, August 2024)

- Report: [2024-08-offchainlabs-usdc-custom-gateway-securityreview.md](<reports/2024-08-offchainlabs-usdc-custom-gateway-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-08-29
- Description: One-week Trail of Bits manual review of the bridged USDC custom gateway contracts in token-bridge-contracts PR #87 and of the UpgradeArbOSVersionAtTimestampAction governance action. Three Low findings about deployment scripts, corner cases and in-flight operations were reported.

### Repository: <a href="https://github.com/OffchainLabs/token-bridge-contracts"><code>OffchainLabs/token-bridge-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/token-bridge-contracts/commit/d2c09d2083d929d86022b30d1e625e69ca75e77c"><code>d2c09d2083d929d86022b30d1e625e69ca75e77c</code></a> | July 11, 2024 | <code>contracts/tokenbridge/ethereum/gateway/L1USDCGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitUSDCGateway.sol</code><br><code>contracts/tokenbridge/arbitrum/gateway/L2USDCGateway.sol</code><br><code>contracts/tokenbridge/libraries/IFiatToken.sol</code><br><code>contracts/tokenbridge/arbitrum/gateway/L2ArbitrumGateway.sol</code> |

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/163d7fa771ce2f7cf383ac43eaf11b23b23eb6d2"><code>163d7fa771ce2f7cf383ac43eaf11b23b23eb6d2</code></a> | July 12, 2024 | <code>src/gov-action-contracts/arbos-upgrade/UpgradeArbOSVersionAtTimestampAction.sol</code> |

## Offchain Labs Timeboost Auction Contracts Security Assessment (Trail of Bits, August 2024)

- Report: [2024-08-offchainlabs-timeboost-auction-contracts-securityreview.md](<reports/2024-08-offchainlabs-timeboost-auction-contracts-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-09-25
- Description: Trail of Bits review of the on-chain Timeboost express lane auction contracts in nitro-contracts PR #214 against the timeboost-design specification, with a fixes commit. One Medium and two Informational findings were reported; off-chain Timeboost components and economics were out of scope.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/9dc19d21c0ba0df89529cc0085915fa9565ecafd"><code>9dc19d21c0ba0df89529cc0085915fa9565ecafd</code></a> | August 20, 2024 | <code>src/express-lane-auction</code> (recursive directory) |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/84ade5042533fb35c3f30ae7bfec85580eba461d"><code>84ade5042533fb35c3f30ae7bfec85580eba461d</code></a> | August 27, 2024 | <code>src/express-lane-auction</code> (recursive directory) |

### Repository: <a href="https://github.com/OffchainLabs/timeboost-design"><code>OffchainLabs/timeboost-design</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Offchain Labs Nitro Contracts with BoLD Security Assessment Summary Report (Trail of Bits, October 2024)

- Report: [2024-10-30-Offchain-NitroContractswithBoLD-securityreview.md](<reports/2024-10-30-Offchain-NitroContractswithBoLD-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-10-30
- Description: One-week Trail of Bits review of the changes to the BoLD contracts in nitro-contracts between the previously audited commit and acb2fd2, focused on EIP-7702 edge cases around address aliasing and retryable tickets. Two Informational findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/acb2fd2703b8bda7c1dc15090d4b09052db4766f"><code>acb2fd2703b8bda7c1dc15090d4b09052db4766f</code></a> | October 9, 2024 | <code>src</code> (recursive directory) |

## Offchain Labs BoLD Fixes Security Assessment Summary Report (Trail of Bits, December 2024)

- Report: [2024-12-offchain-boldfixes-securityreview.md](<reports/2024-12-offchain-boldfixes-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-12-26
- Description: Trail of Bits review of the BoLD upgrade instructions and ten nitro-contracts pull requests (BOLDUpgradeAction simplification, express lane auction, interface refactors, zero-transfer handling, CREATE2 bridge creation, delay proof disabling) ahead of the BoLD mainnet proposal. One Low and two Informational findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/d42f786e03058093e2658e8f93ff580fa3ba8466"><code>d42f786e03058093e2658e8f93ff580fa3ba8466</code></a> | November 5, 2024 | <code>src/assertionStakingPool/EdgeStakingPool.sol</code><br><code>src/assertionStakingPool/interfaces/IEdgeStakingPool.sol</code><br><code>src/challengeV2/EdgeChallengeManager.sol</code><br><code>src/challengeV2/IAssertionChain.sol</code><br><code>src/challengeV2/IEdgeChallengeManager.sol</code><br><code>src/challengeV2/libraries/ChallengeEdgeLib.sol</code><br><code>src/challengeV2/libraries/EdgeChallengeManagerLib.sol</code><br><code>src/challengeV2/libraries/Structs.sol</code><br><code>src/rollup/Config.sol</code><br><code>src/rollup/IRollupCore.sol</code><br><code>src/rollup/RollupCore.sol</code><br><code>src/rollup/RollupLib.sol</code><br><code>src/rollup/RollupUserLogic.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/c7eaad69808df25576d8de93ddb00c2055777e1a"><code>c7eaad69808df25576d8de93ddb00c2055777e1a</code></a> | November 21, 2024 | <code>src/rollup/BOLDUpgradeAction.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/625ad646cd2f9595d6412cea4af2325b60d6a7ac"><code>625ad646cd2f9595d6412cea4af2325b60d6a7ac</code></a> | November 25, 2024 | <code>src/express-lane-auction/Balance.sol</code><br><code>src/express-lane-auction/Burner.sol</code><br><code>src/express-lane-auction/ELCRound.sol</code><br><code>src/express-lane-auction/Errors.sol</code><br><code>src/express-lane-auction/ExpressLaneAuction.sol</code><br><code>src/express-lane-auction/IExpressLaneAuction.sol</code><br><code>src/express-lane-auction/RoundTimingInfo.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/08c000ca8e5e6daae3db5502326d7197d83741ab"><code>08c000ca8e5e6daae3db5502326d7197d83741ab</code></a> | December 9, 2024 | <code>src/bridge/ERC20Bridge.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/1e15b78a6e8fc0dd5005392390fa6a79f9d23328"><code>1e15b78a6e8fc0dd5005392390fa6a79f9d23328</code></a> | December 9, 2024 | <code>src/bridge/AbsBridge.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/37826963b0eebe24850fedcb041dc6dfb31fca1a"><code>37826963b0eebe24850fedcb041dc6dfb31fca1a</code></a> | December 10, 2024 | <code>src/rollup/Config.sol</code><br><code>src/rollup/BOLDUpgradeAction.sol</code><br><code>src/rollup/RollupAdminLogic.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/81109885247715dc8a792aaab46a26cb7ca03bf9"><code>81109885247715dc8a792aaab46a26cb7ca03bf9</code></a> | December 10, 2024 | <code>src/rollup/BridgeCreator.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/pull/325"><code>#325</code></a> (unresolved pull request) | — | <code>src/bridge/SequencerInbox.sol</code> |

## Offchain Labs Custom Fee Token Exchange Rate Summary Report (Trail of Bits, March 2025)

- Report: [2025-03-offchain-custom-fee-token-exchange-rate-securityreview.md](<reports/2025-03-offchain-custom-fee-token-exchange-rate-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-03-12
- Description: Five engineer-day Trail of Bits review of the nitro-contracts changes adding an exchange rate for custom fee token chains so that batch posters are reimbursed correctly (PR #252 at c4ee8b8, PR #281 at 13f2cac), excluding testing and example pricer code. No findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/c4ee8b8b0bb4ffe1b93069988f29f836a1ea1f0b"><code>c4ee8b8b0bb4ffe1b93069988f29f836a1ea1f0b</code></a> | February 11, 2025 | <code>src/bridge/ISequencerInbox.sol</code><br><code>src/bridge/SequencerInbox.sol</code><br><code>src/libraries/Error.sol</code><br><code>src/rollup/BridgeCreator.sol</code><br><code>src/rollup/ERC20RollupEventInbox.sol</code><br><code>src/rollup/RollupAdminLogic.sol</code><br><code>src/rollup/RollupCreator.sol</code><br><code>src/stylus/StylusDeployer.sol</code> |

## Offchain Labs Security Council Rotation Summary Report (Trail of Bits, March 2025)

- Report: [2025-03-offchain-security-council-rotation-securityreview.md](<reports/2025-03-offchain-security-council-rotation-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-03-12
- Description: Eight engineer-day Trail of Bits review of the governance changes allowing Security Council members to rotate their own keys without a proposal (PR #322 at 57f495c), including rotation of upcoming members at cohort replacement. One Low finding about removal of an upcoming member was reported.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/57f495c1e8546675f7596ae28431961fd0f84c95"><code>57f495c1e8546675f7596ae28431961fd0f84c95</code></a> | February 13, 2025 | <code>src/security-council-mgmt/SecurityCouncilManager.sol</code><br><code>src/security-council-mgmt/governors/modules/SecurityCouncilNomineeElectionGovernorCountingUpgradeable.sol</code><br><code>src/security-council-mgmt/interfaces/ISecurityCouncilManager.sol</code><br><code>src/security-council-mgmt/interfaces/ISecurityCouncilNomineeElectionGovernor.sol</code> |

## Offchain Labs Geth 14.4 Summary Report (Trail of Bits, March 2025)

- Report: [irrelevant/2025-03-offchain-geth-14.4-securityreview.md](<reports/irrelevant/2025-03-offchain-geth-14.4-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-03-12
- Description: Four engineer-day Trail of Bits review of the consensus-related changes adding Geth 1.14.4 support to the ArbOS go-ethereum fork (nitro 53f5c56, go-ethereum b6f989a), bounded by client-provided diffs of changes impacting the replay executable. No findings were reported; the report names no file paths, so no coverage can be pinned.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

### Repository: <a href="https://github.com/OffchainLabs/go-ethereum"><code>OffchainLabs/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Offchain Labs Custom Fee ERC-20 Bridge Upgrade and EIP-7702 Fixes Summary Report (Trail of Bits, March 2025)

- Report: [2025-03-offchain-custom-fee-erc20-bridge-securityreview.md](<reports/2025-03-offchain-custom-fee-erc20-bridge-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-03-31
- Description: One-week Trail of Bits review of the patched ERC20Bridge decimals fix for custom fee token chains, the Orbit chain-actions contracts upgrading ERC20Bridge to 2.1.2 and 2.1.3, and the pre-BoLD EIP-7702 fixes in nitro-contracts. One Informational finding about an invalid downgrade path was reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/275ba6cc4af028e67beea29b77df32807f5aefa2"><code>275ba6cc4af028e67beea29b77df32807f5aefa2</code></a> | January 15, 2025 | <code>src/bridge/ERC20Bridge.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/961a498b3ae3e218535a2a9fd28c306aaa04f3ee"><code>961a498b3ae3e218535a2a9fd28c306aaa04f3ee</code></a> | January 25, 2025 | <code>src</code> (recursive directory) |

### Repository: <a href="https://github.com/OffchainLabs/arbitrum-chain-actions"><code>OffchainLabs/arbitrum-chain-actions</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/arbitrum-chain-actions/commit/d7a8f01c3fddd0c684d38a0df8eb3db4dd02ef3e"><code>d7a8f01c3fddd0c684d38a0df8eb3db4dd02ef3e</code></a> | January 17, 2025 | <code>contracts/parent-chain/contract-upgrades/NitroContracts2Point1Point2UpgradeAction.sol</code> |
| <a href="https://github.com/OffchainLabs/arbitrum-chain-actions/commit/f4f878e101e54170080532ad3ba6e70dab56a2b9"><code>f4f878e101e54170080532ad3ba6e70dab56a2b9</code></a> | January 28, 2025 | <code>contracts/parent-chain/contract-upgrades/NitroContracts2Point1Point3UpgradeAction.sol</code> |

## Offchain Labs Reward Distributor Fixes Summary Report (Trail of Bits, April 2025)

- Report: [2025-04-offchainlabs-reward-distributor-fixes-securityreview.md](<reports/2025-04-offchainlabs-reward-distributor-fixes-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-04-18
- Description: Four engineer-day Trail of Bits review of the reward distributor changes supporting an ERC-20 token specified at deployment for reimbursing data availability committee members (fund-distribution PR #44 at fafc251). No findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/fund-distribution-contracts"><code>OffchainLabs/fund-distribution-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/fund-distribution-contracts/commit/fafc2512f2754221a789fa9e22120c2f37b91575"><code>fafc2512f2754221a789fa9e22120c2f37b91575</code></a> | March 21, 2025 | <code>src/RewardDistributor.sol</code> |

## Offchain Labs ArbOS 40 Nitro Security Assessment Summary Report (Trail of Bits, May 2025)

- Report: [irrelevant/2025-05-offchainlabs-arbos40nitro-securityreview.md](<reports/irrelevant/2025-05-offchainlabs-arbos40nitro-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-05-06
- Description: Eleven engineer-week Trail of Bits review of ArbOS 40 (Pectra hard fork support and go-ethereum merges) at two nitro and two go-ethereum fork commits plus PRs #444, #3129, #3132 and sys-asm PR #6, focused on EIP implementations, precompiles and the state transition function. One High finding (EIP-2935 block hash history update not called) and five Informational findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/df1fe5636bb0ec4ddae6b8a0eddf8e84a91c3491"><code>df1fe5636bb0ec4ddae6b8a0eddf8e84a91c3491</code></a> | April 5, 2025 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/b3dd9797a306636ee106797e16b60310d6d3ccb3"><code>b3dd9797a306636ee106797e16b60310d6d3ccb3</code></a> | April 16, 2025 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/go-ethereum"><code>OffchainLabs/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/084f63827520569955a905596878d90d42b734a7"><code>084f63827520569955a905596878d90d42b734a7</code></a> | April 3, 2025 | <code>core</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/2a0b8b6f146f62e609fc240b99a9f65df8f2eace"><code>2a0b8b6f146f62e609fc240b99a9f65df8f2eace</code></a> | April 15, 2025 | <code>core</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/sys-asm"><code>OffchainLabs/sys-asm</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Arbitrum Block Hash Pusher Security Assessment Summary Report (Trail of Bits, June 2025)

- Report: [2025-06-offchain-arbitrum-block-hash-pusher-securityreview.md](<reports/2025-06-offchain-arbitrum-block-hash-pusher-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-06-02
- Description: Nine engineer-day Trail of Bits review of the Block Hash Pusher contracts (parent chain Pusher and child chain ring-buffer Buffer) at two commits. No findings were reported, only code quality recommendations.

### Repository: <a href="https://github.com/OffchainLabs/block-hash-pusher"><code>OffchainLabs/block-hash-pusher</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/block-hash-pusher/commit/f7c2973a59b513729f54b03b42e3a9029085b61f"><code>f7c2973a59b513729f54b03b42e3a9029085b61f</code></a> | May 6, 2025 | <code>contracts</code> (recursive directory) |
| <a href="https://github.com/OffchainLabs/block-hash-pusher/commit/697ace304f720f90fb4730891635c49cd8327827"><code>697ace304f720f90fb4730891635c49cd8327827</code></a> | May 13, 2025 | <code>contracts</code> (recursive directory) |

## Arbitrum Mint/Burn Precompile and ERC20MigrationOutbox Security Assessment Summary Report (Trail of Bits, June 2025)

- Report: [2025-06-offchain-arbitrum-mint-burn-precompile-securityreview.md](<reports/2025-06-offchain-arbitrum-mint-burn-precompile-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-06-02
- Description: Nine engineer-day Trail of Bits review of the native token mint/burn feature (nitro PR #3186, go-ethereum PR #447, nitro-contracts PR #335) and the ERC20MigrationOutbox (nitro-contracts PR #339), plus blockscout and nitro-testnode tooling changes, with a fix review of three follow-up nitro PRs. One Low and two Informational findings were reported and left unresolved as intended behavior.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/e7a442ff33f52812c59795d69e4518c1da9ce919"><code>e7a442ff33f52812c59795d69e4518c1da9ce919</code></a> | May 15, 2025 | <code>arbos/arbosState/arbosstate.go</code> (other)<br><code>arbos/arbosState/initialize.go</code> (other)<br><code>precompiles/ArbNativeTokenManager.go</code> (other)<br><code>precompiles/ArbOwner.go</code> (other)<br><code>precompiles/precompile.go</code> (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/fa3a7b282c48391b8231ba76307e26eb70c720e2"><code>fa3a7b282c48391b8231ba76307e26eb70c720e2</code></a> | May 22, 2025 | <code>precompiles/ArbSys.go</code> (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/af31c44c0169497a54aeed276deb6cd8c05dea78"><code>af31c44c0169497a54aeed276deb6cd8c05dea78</code></a> | May 23, 2025 | <code>arbos/arbosState/arbosstate.go</code> (other)<br><code>precompiles/ArbOwner.go</code> (other)<br><code>precompiles/precompile.go</code> (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/d11020b86061b1597f0967f02623e307ce34c2fa"><code>d11020b86061b1597f0967f02623e307ce34c2fa</code></a> | May 23, 2025 | <code>precompiles/ArbNativeTokenManager.go</code> (other)<br><code>precompiles/precompile.go</code> (other)<br><code>precompiles/ArbOwnerPublic.go</code> (other) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/95b6300650267bb283884c7f6d075cc698cd3402"><code>95b6300650267bb283884c7f6d075cc698cd3402</code></a> | May 13, 2025 | <code>src/precompiles/ArbNativeTokenManager.sol</code><br><code>src/precompiles/ArbOwner.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/fb7e526fff17f9499a791013ff50aefa0b03c90d"><code>fb7e526fff17f9499a791013ff50aefa0b03c90d</code></a> | June 13, 2025 | <code>src/bridge/extra/ERC20MigrationOutbox.sol</code><br><code>src/bridge/extra/IERC20MigrationOutbox.sol</code> |

### Repository: <a href="https://github.com/OffchainLabs/go-ethereum"><code>OffchainLabs/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/c517c5ecfb37a822cc56c736ae93b2d75cdc4d80"><code>c517c5ecfb37a822cc56c736ae93b2d75cdc4d80</code></a> | May 14, 2025 | <code>core/genesis.go</code> (other)<br><code>core/state/statedb.go</code> (other)<br><code>core/state/statedb_hooked.go</code> (other)<br><code>core/tracing/gen_balance_change_reason_stringer.go</code> (other)<br><code>core/tracing/hooks.go</code> (other)<br><code>core/types/arbitrum_signer.go</code> (other)<br><code>core/vm/interface.go</code> (other)<br><code>params/config.go</code> (other)<br><code>params/config_arbitrum.go</code> (other) |

## Offchain Labs Upgrade Executor Summary Report (Trail of Bits, July 2025)

- Report: [2025-07-offchain-upgrade-executor-securityreview.md](<reports/2025-07-offchain-upgrade-executor-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-07-30
- Description: One engineer-day Trail of Bits review of the Upgrade Executor commit adding an executeCall function for direct calls, checking correctness against the DAO proposal and side effects. No security findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/upgrade-executor"><code>OffchainLabs/upgrade-executor</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/upgrade-executor/commit/eaa9d607464abb8683a3fe526acbf6d877f924e0"><code>eaa9d607464abb8683a3fe526acbf6d877f924e0</code></a> | October 17, 2024 | <code>src/UpgradeExecutor.sol</code> |

## Offchain Labs Security Council Update Code Review Summary Report with Fix Review (Trail of Bits, September 2025)

- Report: [2025_09_15_trail_of_bits_security_council_update_code_review_summary_report_with_fix_review.md](<reports/2025_09_15_trail_of_bits_security_council_update_code_review_summary_report_with_fix_review.md>)
- Auditor: Trail of Bits
- Date: 2025-09-15
- Description: One engineer-week Trail of Bits review of the Security Council contract changes implementing the election process improvements proposal (longer cohort durations, adjusted thresholds, nominee rotation) at governance commit d89b171, with a fix review. One Medium (duplicate nominees can make cohort replacement fail) and one Informational finding were reported and resolved in PR #361.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/d89b171429e3c4e6c1b7e5ef559a93aef5d35d8a"><code>d89b171429e3c4e6c1b7e5ef559a93aef5d35d8a</code></a> | August 14, 2025 | <code>src/security-council-mgmt</code> (recursive directory) |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/3e4b387dba94f6f3c7d6ae8b30f631fe0e5f3c4f"><code>3e4b387dba94f6f3c7d6ae8b30f631fe0e5f3c4f</code></a> | July 21, 2026 | <code>src/security-council-mgmt</code> (recursive directory) |

## Arbitrum Governor Cancel Upgrade Review (Offbeat Security, October 2025)

- Report: [2025_10_19_offbeat_security_governor_cancel_upgrade_review.md](<reports/2025_10_19_offbeat_security_governor_cancel_upgrade_review.md>)
- Auditor: Offbeat Security
- Date: 2025-10-19
- Description: Offbeat Security review of the ScopeLift arbitrum-governance upgrade adding proposal cancellation to the Core and Treasury governors: the L2ArbitrumGovernorV2 implementation, the MultiProxyUpgradeAction and the forge deployment and proposal scripts at commit df184f2, including calldata formation and address validation. One Informational finding was reported.

### Repository: <a href="https://github.com/ScopeLift/arbitrum-governance"><code>ScopeLift/arbitrum-governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ScopeLift/arbitrum-governance/commit/df184f2cfb903cf2c3b72a12ce36e2b949cb3489"><code>df184f2cfb903cf2c3b72a12ce36e2b949cb3489</code></a> | October 10, 2025 | <code>src/L2ArbitrumGovernorV2.sol</code><br><code>src/gov-action-contracts/gov-upgrade-contracts/upgrade-proxy/MultiProxyUpgradeAction.sol</code><br><code>scripts/forge-scripts/DeployConstants.sol</code><br><code>scripts/forge-scripts/DeployImplementation.s.sol</code><br><code>scripts/forge-scripts/DeployMultiProxyUpgradeAction.s.sol</code><br><code>scripts/forge-scripts/SubmitUpgradeProposalScript.s.sol</code><br><code>scripts/forge-scripts/utils/EncodeL2ArbSysProposal.sol</code> |

## Arbitrum ArbOS 50 and 51 Security Assessment Summary Report (Trail of Bits, 2025)

- Report: [2025-12-offchain-arbos50-and-51-securityreview.md](<reports/2025-12-offchain-arbos50-and-51-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-12-01
- Description: Ten-week Trail of Bits review of the ArbOS 50 upgrade diffs of Nitro and its go-ethereum fork (Fusaka support, constraint-based pricing foundation, native token minting), the ArbOS 50 action contract and payload, the ResourceConstraintManager contract, and the ArbOS 51 retryable gas fixes. One Medium, one Low and four Informational findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/cb86fcaa6972ce2a9680762721ca489bcd8068c5"><code>cb86fcaa6972ce2a9680762721ca489bcd8068c5</code></a> | September 5, 2025 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/22f4bff08ad916355b7e71c87b7f5102551a8399"><code>22f4bff08ad916355b7e71c87b7f5102551a8399</code></a> | September 15, 2025 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/475b033d9f57cac5653979d62c5e981df68e7f91"><code>475b033d9f57cac5653979d62c5e981df68e7f91</code></a> | October 24, 2025 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/81b4585ba4f015565ba6696dd641b16fdd7f6b15"><code>81b4585ba4f015565ba6696dd641b16fdd7f6b15</code></a> | November 25, 2025 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/go-ethereum"><code>OffchainLabs/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/860bd9d17daa3f1fdd9ce691fce3f7cddf4ed460"><code>860bd9d17daa3f1fdd9ce691fce3f7cddf4ed460</code></a> | September 4, 2025 | <code>core</code> (recursive directory) (other)<br><code>params</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/ba8d8fa2d7366b2725224f82693caa3072fbd558"><code>ba8d8fa2d7366b2725224f82693caa3072fbd558</code></a> | September 12, 2025 | <code>core</code> (recursive directory) (other)<br><code>params</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/57fe4b732d4e640e696da40773f2dacba97e722b"><code>57fe4b732d4e640e696da40773f2dacba97e722b</code></a> | October 22, 2025 | <code>core</code> (recursive directory) (other)<br><code>params</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/4e7047ef0da0e03874ba2afd58f0a1cd84e2d13c"><code>4e7047ef0da0e03874ba2afd58f0a1cd84e2d13c</code></a> | November 25, 2025 | <code>core</code> (recursive directory) (other)<br><code>params</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/5882897088883eb22afbab02e0c79c9f0437e1c5"><code>5882897088883eb22afbab02e0c79c9f0437e1c5</code></a> | November 11, 2025 | <code>src/chain/ResourceConstraintManager.sol</code> |

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/32adeba02be1a85975ee410ac783e2bfdafcdcb5"><code>32adeba02be1a85975ee410ac783e2bfdafcdcb5</code></a> | November 12, 2025 | <code>src/gov-action-contracts/AIPs/ArbOS50/ArbOS50SettingsAction.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/4f05a6cd6b5b1795a3701d49a966e1213961010b"><code>4f05a6cd6b5b1795a3701d49a966e1213961010b</code></a> | November 13, 2025 | <code>src/gov-action-contracts/AIPs/ArbOS50/ArbOS50SettingsAction.sol</code> |

## Offchain Labs Nitro External DA Security Assessment Summary Report (Trail of Bits, December 2025)

- Report: [2026-01-offchain-nitro-external-da-securityreview.md](<reports/2026-01-offchain-nitro-external-da-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-01-12
- Description: Four engineer-week Trail of Bits review of the Nitro external Data Availability extension in the node prover, inbox parsing and DA provider reader plus the one-step prover contract, with a January 2026 fix review. One Undetermined (prover/contract divergence), two Low and one Informational finding were reported and all were resolved.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/3f226a0ecf91ceed3688a2fc41969fae1f32d03d"><code>3f226a0ecf91ceed3688a2fc41969fae1f32d03d</code></a> | December 12, 2025 | <code>arbitrator/prover</code> (recursive directory) (other)<br><code>arbstate</code> (recursive directory) (other)<br><code>daprovider</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/2fa24850b9d8dfc2b3e671b87959313e32d7d42c"><code>2fa24850b9d8dfc2b3e671b87959313e32d7d42c</code></a> | December 16, 2025 | <code>arbstate</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/594bd587c3e7c8dc6c667c19f30cbffbb3ce6ce4"><code>594bd587c3e7c8dc6c667c19f30cbffbb3ce6ce4</code></a> | December 30, 2025 | <code>arbstate</code> (recursive directory) (other)<br><code>daprovider</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/de26c5f2599064924c03de38e87657ea5ab33120"><code>de26c5f2599064924c03de38e87657ea5ab33120</code></a> | January 9, 2026 | <code>daprovider</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/decedd984d387b9afd6ad1b268e5f49e3cd4e2d8"><code>decedd984d387b9afd6ad1b268e5f49e3cd4e2d8</code></a> | January 14, 2026 | <code>crates/prover/src/machine.rs</code> (other) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/940373b68d0e9cffa006eb9e6d0b4376138d531c"><code>940373b68d0e9cffa006eb9e6d0b4376138d531c</code></a> | December 5, 2025 | <code>src/osp</code> (recursive directory) |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/ae9b093a3fd7e8864dd14c60a5ff49e3ecfa84b6"><code>ae9b093a3fd7e8864dd14c60a5ff49e3ecfa84b6</code></a> | January 7, 2026 | <code>src/osp</code> (recursive directory) |

## Offchain Labs Arbitrum Quorum Changes Security Assessment Summary Report (Trail of Bits, February 2026)

- Report: [2026-02-offchain-arbitrum-quorum-changes-securityreview.md](<reports/2026-02-offchain-arbitrum-quorum-changes-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-02-18
- Description: Trail of Bits review of the governance proposal changing the Arbitrum DAO quorum to a delegated-voting-power basis (PR #364), the L2 governor cancellation and quorum checkpointing follow-ups (PRs #365 and #371), and the corresponding action contract deployments and payload. Two Informational findings were reported.

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/74e32d4c2baf07918b3367eecb70c1f8786bb79a"><code>74e32d4c2baf07918b3367eecb70c1f8786bb79a</code></a> | October 17, 2025 | <code>src/L2ArbitrumGovernor.sol</code><br><code>src/L2ArbitrumToken.sol</code><br><code>src/gov-action-contracts/AIPs/ActivateDvpQuorumAction.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/a2f690adb9df17f89a810273d3d83a798daca9fb"><code>a2f690adb9df17f89a810273d3d83a798daca9fb</code></a> | November 27, 2025 | <code>src/L2ArbitrumGovernor.sol</code><br><code>src/L2ArbitrumToken.sol</code><br><code>src/gov-action-contracts/AIPs/ActivateDvpQuorumAction.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/1ee03ed990a1b3c06e6b4e91503c4d245bb42a8f"><code>1ee03ed990a1b3c06e6b4e91503c4d245bb42a8f</code></a> | January 26, 2026 | <code>src/L2ArbitrumGovernor.sol</code><br><code>src/L2ArbitrumToken.sol</code><br><code>src/gov-action-contracts/AIPs/ActivateDvpQuorumAction.sol</code> |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/69cd418c1f34f955abbc1cec3c5a01dde220d7f5"><code>69cd418c1f34f955abbc1cec3c5a01dde220d7f5</code></a> | February 17, 2026 | <code>src/L2ArbitrumGovernor.sol</code><br><code>src/L2ArbitrumToken.sol</code><br><code>src/gov-action-contracts/AIPs/ActivateDvpQuorumAction.sol</code> |

## Offchain Labs Stylus SDK Security Assessment (Trail of Bits, 2025)

- Report: [2026-04-offchain-stylus-sdk-securityreview.md](<reports/2026-04-offchain-stylus-sdk-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-04-08
- Description: Nine engineer-week Trail of Bits review of the stylus-sdk-rs library, the cargo-stylus deployment and verification tool, and the StylusDeployer and CacheManager contracts in nitro-contracts. The one High and three Medium findings are in cargo-stylus verification and deployment tooling; only Low and Informational findings touch the contracts, which are the only relevant scope recorded here.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/0b8c04e8f5f66fe6678a4f53aa15f23da417260e"><code>0b8c04e8f5f66fe6678a4f53aa15f23da417260e</code></a> | June 17, 2025 | <code>src/stylus/StylusDeployer.sol</code><br><code>src/chain/CacheManager.sol</code> |

### Repository: <a href="https://github.com/OffchainLabs/stylus-sdk-rs"><code>OffchainLabs/stylus-sdk-rs</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

### Repository: <a href="https://github.com/OffchainLabs/cargo-stylus"><code>OffchainLabs/cargo-stylus</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Offchain Labs Reward Distributor Fixes Extended Summary Report (Trail of Bits, June 2026)

- Report: [2026.06-offchainlabs-rewarddistributorfixes-securityreview.md](<reports/2026.06-offchainlabs-rewarddistributorfixes-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-06-16
- Description: Extension of the April 2025 Trail of Bits review of the ERC-20 reward distributor changes (fund-distribution PR #44 at fafc251), adding a June 2026 review of PR #1 in the private fund-distribution repository that resets allowances before distributions to the Arbitrum and Optimism gateways. One Informational finding about tokens rejecting zero approvals was reported.

### Repository: <a href="https://github.com/OffchainLabs/fund-distribution-contracts"><code>OffchainLabs/fund-distribution-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/fund-distribution-contracts/commit/fafc2512f2754221a789fa9e22120c2f37b91575"><code>fafc2512f2754221a789fa9e22120c2f37b91575</code></a> | March 21, 2025 | <code>src/RewardDistributor.sol</code> |

### Repository: <a href="https://github.com/OffchainLabs/fund-distribution-contracts-private"><code>OffchainLabs/fund-distribution-contracts-private</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Arbitrum ArbOS 60 and 61 Security Assessment (Trail of Bits, 2026)

- Report: [2026-07-offchainlabs-arbitrumarbos6061-securityreview.md](<reports/2026-07-offchainlabs-arbitrumarbos6061-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-07-10
- Description: Twenty-four engineer-week Trail of Bits review of the ArbOS 60 and 61 upgrades in Nitro and its go-ethereum fork (Stylus program fragments, multi-dimensional constraint gas pricing, bug fixes), the ResourceConstraintManager v2 and BaseFeeManager contracts, and the ArbOS 61 action contract and payload. One High finding (non-deterministic Go map iteration in the multi-gas precompiles) and eight Informational findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro"><code>OffchainLabs/nitro</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro/commit/746bda2febea6b160f56267f0727cf0bc21e9eb7"><code>746bda2febea6b160f56267f0727cf0bc21e9eb7</code></a> | February 11, 2026 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/26d4dc21f9597fcc345c5ff1eb3355eb7444cae4"><code>26d4dc21f9597fcc345c5ff1eb3355eb7444cae4</code></a> | February 22, 2026 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/fd2a5b01b24c18c21c6d6f3748f7fd887859bc44"><code>fd2a5b01b24c18c21c6d6f3748f7fd887859bc44</code></a> | March 27, 2026 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/ec997e665e5851a0e0976eb1e169b39fae532fff"><code>ec997e665e5851a0e0976eb1e169b39fae532fff</code></a> | April 30, 2026 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/3569036ece4dc0a95f3f1926165cdf33ca3456dc"><code>3569036ece4dc0a95f3f1926165cdf33ca3456dc</code></a> | May 6, 2026 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/d162cc12e8c30db9248b41e55e40450d2b4da9b8"><code>d162cc12e8c30db9248b41e55e40450d2b4da9b8</code></a> | June 2, 2026 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/nitro/commit/c9fbd05597ad51258612039dca9348ab7d03d4ee"><code>c9fbd05597ad51258612039dca9348ab7d03d4ee</code></a> | June 5, 2026 | <code>arbos</code> (recursive directory) (other)<br><code>precompiles</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/go-ethereum"><code>OffchainLabs/go-ethereum</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/c59dcce8b117bcee69a792f278fd9412f0586048"><code>c59dcce8b117bcee69a792f278fd9412f0586048</code></a> | February 10, 2026 | <code>core</code> (recursive directory) (other)<br><code>params</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/fa29c9c651a28a8f91d698a9b45e7da86ec585c9"><code>fa29c9c651a28a8f91d698a9b45e7da86ec585c9</code></a> | March 26, 2026 | <code>core</code> (recursive directory) (other)<br><code>params</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/9c369aa02836740d2844d037721e2fba6d573328"><code>9c369aa02836740d2844d037721e2fba6d573328</code></a> | May 6, 2026 | <code>core</code> (recursive directory) (other)<br><code>params</code> (recursive directory) (other) |
| <a href="https://github.com/OffchainLabs/go-ethereum/commit/f1c5f02b29e7c499232ecbd17bc0e32801f8181c"><code>f1c5f02b29e7c499232ecbd17bc0e32801f8181c</code></a> | June 2, 2026 | <code>core</code> (recursive directory) (other)<br><code>params</code> (recursive directory) (other) |

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/57e5b37a6cb704ed80150e6aa6938d5375a0d7dc"><code>57e5b37a6cb704ed80150e6aa6938d5375a0d7dc</code></a> | March 19, 2026 | <code>src/chain/BaseFeeManager.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/e266f6fd3d942bf09f0a63bd8f739ee8459aef56"><code>e266f6fd3d942bf09f0a63bd8f739ee8459aef56</code></a> | March 20, 2026 | <code>src/chain/ResourceConstraintManager.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/3284dbd3ccf7b9fe3938e09d3490aeea78452322"><code>3284dbd3ccf7b9fe3938e09d3490aeea78452322</code></a> | March 26, 2026 | <code>src/chain/ResourceConstraintManager.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/2fe5abe17dbfad31a81efc25d405b50466182aa4"><code>2fe5abe17dbfad31a81efc25d405b50466182aa4</code></a> | April 1, 2026 | <code>src/chain/ResourceConstraintManager.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/18728ceabb9040bfbdba8a2680ac9f35d90660df"><code>18728ceabb9040bfbdba8a2680ac9f35d90660df</code></a> | April 22, 2026 | <code>src/chain/ResourceConstraintManager.sol</code> |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/53635bdd519387b5de604ad2e45ae89eda2980a7"><code>53635bdd519387b5de604ad2e45ae89eda2980a7</code></a> | April 23, 2026 | <code>src/chain/ResourceConstraintManager.sol</code> |

### Repository: <a href="https://github.com/ArbitrumFoundation/governance"><code>ArbitrumFoundation/governance</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ArbitrumFoundation/governance/commit/730faa2ecd0c551f21b5f9d522f360247a2589f4"><code>730faa2ecd0c551f21b5f9d522f360247a2589f4</code></a> | July 7, 2026 | <code>src/gov-action-contracts/AIPs/ArbOS61/ArbOS61SettingsAction.sol</code> |

## Offchain Labs Sequencer Feed Ticketing Summary Report (Trail of Bits, July 2026)

- Report: [2026-07-offchainlabs-sequencerfeedticketing-securityreview.md](<reports/2026-07-offchainlabs-sequencerfeedticketing-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-07-31
- Description: Nine engineer-day Trail of Bits review of the sequencer feed ticketing contracts that let users buy tickets for a premium sequencer feed. No security findings were reported, only code quality items.

### Repository: <a href="https://github.com/OffchainLabs/feed-ticket-contracts"><code>OffchainLabs/feed-ticket-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/feed-ticket-contracts/commit/9d04eb0be29733b9f302a56976a0f3148f10866e"><code>9d04eb0be29733b9f302a56976a0f3148f10866e</code></a> | June 17, 2026 | <code>src</code> (recursive directory) |

## Offchain Labs Yield-Bearing Bridge Security Assessment Summary Report (Trail of Bits, 2026)

- Report: [2026-08-offchain-yield-bearing-bridge-securityreview.md](<reports/2026-08-offchain-yield-bearing-bridge-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-08-07
- Description: Four engineer-week Trail of Bits review of the yield-bearing bridge feature of the token bridge (ERC-4626 master vault and yield-bearing ERC-20 and custom gateways) at an initial and a fix-review commit. One High finding (Orbit yield-bearing gateway breaking previous assumptions) and four Informational findings were reported; all but one accepted risk were resolved.

### Repository: <a href="https://github.com/OffchainLabs/token-bridge-contracts"><code>OffchainLabs/token-bridge-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/token-bridge-contracts/commit/cdbd23820e0d746e1b505cc8a4463d282a5f36d3"><code>cdbd23820e0d746e1b505cc8a4463d282a5f36d3</code></a> | April 28, 2026 | <code>contracts/tokenbridge/ethereum/gateway/AbsYbbERC20Gateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/AbsYbbGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/IYbbGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitYbbCustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitYbbERC20Gateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1YbbCustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1YbbERC20Gateway.sol</code><br><code>contracts/tokenbridge/libraries/vault/IMasterVault.sol</code><br><code>contracts/tokenbridge/libraries/vault/IMasterVaultFactory.sol</code><br><code>contracts/tokenbridge/libraries/vault/MasterVault.sol</code><br><code>contracts/tokenbridge/libraries/vault/MasterVaultFactory.sol</code><br><code>contracts/tokenbridge/libraries/vault/MasterVaultRoles.sol</code><br><code>test-foundry/L1OrbitYbbCustomGateway.t.sol</code><br><code>test-foundry/L1OrbitYbbERC20Gateway.t.sol</code><br><code>test-foundry/L1YbbERC20Gateway.t.sol</code><br><code>test-foundry/YbbDoubleInit.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultAttack.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultCore.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultDepositRedeem.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultFactory.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultFirstDeposit.t.sol</code><br><code>test-foundry/libraries/vault/invariant/MasterVaultHandler.sol</code><br><code>test-foundry/libraries/vault/invariant/MasterVaultInvariant.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultAccessControl.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultDefaultSubVault.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultFees.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultInit.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultPause.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultRebalance.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultRebalanceCooldown.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultRedeem.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultRoles.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultSetSubVault.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultSetters.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario01.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario02.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario03.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario04.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario05.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario06.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario07.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario08.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario09.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario10.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario11.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenarioCore.t.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ArbitrumGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitERC20Gateway.sol</code> |
| <a href="https://github.com/OffchainLabs/token-bridge-contracts/commit/6813a97a66c54c16a3d1a5692b45569ffae5fa22"><code>6813a97a66c54c16a3d1a5692b45569ffae5fa22</code></a> | June 26, 2026 | <code>contracts/tokenbridge/ethereum/gateway/AbsYbbERC20Gateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/AbsYbbGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/IYbbGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitYbbCustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitYbbERC20Gateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1YbbCustomGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1YbbERC20Gateway.sol</code><br><code>contracts/tokenbridge/libraries/vault/IMasterVault.sol</code><br><code>contracts/tokenbridge/libraries/vault/IMasterVaultFactory.sol</code><br><code>contracts/tokenbridge/libraries/vault/MasterVault.sol</code><br><code>contracts/tokenbridge/libraries/vault/MasterVaultFactory.sol</code><br><code>contracts/tokenbridge/libraries/vault/MasterVaultRoles.sol</code><br><code>test-foundry/L1OrbitYbbCustomGateway.t.sol</code><br><code>test-foundry/L1OrbitYbbERC20Gateway.t.sol</code><br><code>test-foundry/L1YbbERC20Gateway.t.sol</code><br><code>test-foundry/YbbDoubleInit.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultAttack.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultCore.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultDepositRedeem.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultFactory.t.sol</code><br><code>test-foundry/libraries/vault/MasterVaultFirstDeposit.t.sol</code><br><code>test-foundry/libraries/vault/invariant/MasterVaultHandler.sol</code><br><code>test-foundry/libraries/vault/invariant/MasterVaultInvariant.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultAccessControl.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultDefaultSubVault.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultFees.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultInit.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultPause.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultRebalance.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultRebalanceCooldown.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultRedeem.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultRoles.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultSetSubVault.t.sol</code><br><code>test-foundry/libraries/vault/mutation/MasterVaultSetters.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario01.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario02.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario03.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario04.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario05.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario06.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario07.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario08.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario09.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario10.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenario11.t.sol</code><br><code>test-foundry/libraries/vault/scenarios/MasterVaultScenarioCore.t.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1ArbitrumGateway.sol</code><br><code>contracts/tokenbridge/ethereum/gateway/L1OrbitERC20Gateway.sol</code> |

## Offchain Labs TipCollectionToggler Summary Report (Trail of Bits, August 2026)

- Report: [2026-08-offchainlabs-tipcollectiontoggler-securityreview.md](<reports/2026-08-offchainlabs-tipcollectiontoggler-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-08-14
- Description: Two engineer-day Trail of Bits review of the TipCollectionToggler contract (nitro-contracts PR #439), which lets a trusted party toggle priority fee collection through the ArbOwner precompile for a limited duration. No findings were reported.

### Repository: <a href="https://github.com/OffchainLabs/nitro-contracts"><code>OffchainLabs/nitro-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/OffchainLabs/nitro-contracts/commit/87a9c8d55c6737f711396289cedec674671f523d"><code>87a9c8d55c6737f711396289cedec674671f523d</code></a> | July 15, 2026 | <code>src/chain/TipCollectionToggler.sol</code> |

## Irrelevant reports

### Code Assessment of the Security Council AIP Smart Contracts (ChainSecurity, March 2024)

- Report: [irrelevant/2024_03_18_chainsecurity_security_council_aip.md](<reports/irrelevant/2024_03_18_chainsecurity_security_council_aip.md>)
- Auditor: ChainSecurity
- Date: 2024-03-18
- Description: ChainSecurity assessment of the governance action contracts raising the non-emergency Security Council threshold from 7 to 9 and the constitution update library (AIPIncreaseNonEmergencySCThresholdAction, ConstitutionActionLib, SetSCThresholdAndUpdateConstitutionAction). Irrelevant one-time governance action code; only one Informational typo finding was reported.

### Offchain Labs Orbit Actions Security Assessment (Trail of Bits, August 2024)

- Report: [irrelevant/2024-08-offchainlabs-orbit-actions-securityreview.md](<reports/irrelevant/2024-08-offchainlabs-orbit-actions-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-08-29
- Description: Trail of Bits review of Orbit chain upgrade and fast-confirmation enablement actions (orbit-actions PRs #16, #19, #20), governance actions for permissioned fast confirmation and an eight-day timelock delay (governance PRs #305, #306), and the anyTrustFastConfirmer migration action (nitro-contracts PR #233). Irrelevant one-time upgrade action code; one Medium and one Informational finding were reported.

### Stylus Rust SDK Audit (OpenZeppelin, 2024)

- Report: [irrelevant/2024_09_05_open_zeppelin_security_audit_stylus_rust_sdk.md](<reports/irrelevant/2024_09_05_open_zeppelin_security_audit_stylus_rust_sdk.md>)
- Auditor: OpenZeppelin
- Date: 2024-09-05
- Description: OpenZeppelin audit of the OffchainLabs/stylus-sdk-rs repository at commit 62bd831, covering the procedural macros, core modules (abi, call, deploy, storage, hostio), mini allocator and examples used by developers writing Stylus contracts. Classified irrelevant because the SDK is a developer library compiled into user programs rather than Arbitrum protocol or prover logic; two Critical and two High findings were reported.

### Offchain Labs RegisterAndSetArbCustomGateway Governance Action Review (Trail of Bits, 2024)

- Report: [irrelevant/2024-08-offchainlabs-register-and-set-arb-custom-gateway-action-governance-action-securityreview.md](<reports/irrelevant/2024-08-offchainlabs-register-and-set-arb-custom-gateway-action-governance-action-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-09-26
- Description: Trail of Bits review of the RegisterAndSetArbCustomGateway governance action (governance PR #308) migrating the RARI token to a custom gateway. Irrelevant one-time governance action code; no findings were reported.

### Offchain Labs Office Hours Governance Action Review (Trail of Bits, 2024)

- Report: [irrelevant/2024-08-offchainlabs-office-hours-governance-action-securityreview.md](<reports/irrelevant/2024-08-offchainlabs-office-hours-governance-action-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-10-01
- Description: Trail of Bits review of the Office Hours governance action (governance PR #311) that executes a batch of actions only during certain hours of the day, focused on timezone and time edge cases. Irrelevant one-time governance action code; no findings were reported.

### Contracts for Stylus Audit (OpenZeppelin, October 2024)

- Report: [irrelevant/2024_10_17_openzeppelin_contracts_for_stylus_v0.1.0_audit.md](<reports/irrelevant/2024_10_17_openzeppelin_contracts_for_stylus_v0.1.0_audit.md>)
- Auditor: OpenZeppelin
- Date: 2024-10-17
- Description: OpenZeppelin audit of its own OpenZeppelin/rust-contracts-stylus library (v0.1.0, commit 42c859f) providing ERC-20, ERC-721 and utility modules for Stylus developers. Classified irrelevant because it is an external contract library rather than Arbitrum protocol logic; one Medium and six Low findings were reported.

### Stylus Emergency Fixes Review (Trail of Bits, September 2024)

- Report: [irrelevant/2024-10-offchain-stylus-emergency-fixes-securityreview.md](<reports/irrelevant/2024-10-offchain-stylus-emergency-fixes-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-10-23
- Description: Trail of Bits review of fixes for high-severity Stylus issues found after deployment (nitro-private consensus-v31 to minimal-consensus-v32) and of the ArbOS 32 and Stylus emergency governance actions in governance-private. Irrelevant because both repositories are private and inaccessible; one High finding (TOB-STYLUS-FIX-1) was reported.

### Offchain Labs BoLD Optimized History Commitment Security Assessment Summary Report (Trail of Bits, October 2024)

- Report: [irrelevant/2024-10-offchain-bold-optimized-history-commit-securityreview.md](<reports/irrelevant/2024-10-offchain-bold-optimized-history-commit-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2024-11-08
- Description: One-week Trail of Bits review of the optimized history commitment computation (Go code in bold PRs #681 and #691) used by BoLD validators off-chain, including differential testing against the unoptimized implementation. Classified irrelevant because the scope is limited to off-chain validator software; one Medium floating-point finding was reported.

### Offchain Labs Disable Gateway Action Summary Report (Trail of Bits, March 2025)

- Report: [irrelevant/2025-03-offchain-disablegateway-action-securityreview.md](<reports/irrelevant/2025-03-offchain-disablegateway-action-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-03-12
- Description: Two engineer-day Trail of Bits review of the governance action disabling the USDT standard gateway for deposits in preparation for USDT0 (governance PR #334 at 873c0e9). Irrelevant one-time governance action code; no findings were reported.

### Offchain Labs Sequencer Liveness Summary Report (Trail of Bits, March 2025)

- Report: [irrelevant/2025-03-offchain-sequencer-liveness-securityreview.md](<reports/irrelevant/2025-03-offchain-sequencer-liveness-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-03-31
- Description: Three engineer-week Trail of Bits review of the core Arbitrum Sequencer code (transaction validation and feeding loop) at commit fcb4018 of a private audit repository, focused on correctness and liveness. Irrelevant off-chain node software; one Low denial-of-service finding was reported.

### Offchain Labs SetCoreGovernorQuorumAction Summary Report (Trail of Bits, June 2025)

- Report: [irrelevant/2025-06-offchain-setcoregovernorquorumaction-securityreview.md](<reports/irrelevant/2025-06-offchain-setcoregovernorquorumaction-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-06-16
- Description: Six engineer-day Trail of Bits manual review of the SetCoreGovernorQuorumAction and SetConstitutionHashAction governance proposals (governance PRs #341 and #346). Irrelevant one-time governance action code; no findings were reported.

### Stylus Contracts Library v0.2.0 Audit (OpenZeppelin, June 2025)

- Report: [irrelevant/2025_06_17_openzeppelin_stylus_contracts_library_v0.2.0_audit.md](<reports/irrelevant/2025_06_17_openzeppelin_stylus_contracts_library_v0.2.0_audit.md>)
- Auditor: OpenZeppelin
- Date: 2025-06-17
- Description: OpenZeppelin audit of its rust-contracts-stylus library (crypto library at a67ab70 and 2350766, contracts library at 5ed33dd). Classified irrelevant because it is an external Stylus contract library rather than Arbitrum protocol logic; one High, two Medium and nine Low findings were reported.

### Stylus Contracts Library v0.3.0 Audit (OpenZeppelin, September 2025)

- Report: [irrelevant/2025_09_08_openzeppelin_stylus_contracts_library_v0.3.0_audit.md](<reports/irrelevant/2025_09_08_openzeppelin_stylus_contracts_library_v0.3.0_audit.md>)
- Auditor: OpenZeppelin
- Date: 2025-09-08
- Description: OpenZeppelin audit of the rust-contracts-stylus library changes at commit 231d4f1 (v0.3.0). Classified irrelevant because it is an external Stylus contract library rather than Arbitrum protocol logic; one High, four Medium and five Low findings were reported and resolved.

### Arbitrum Chains Genesis File Generator Summary Report (Trail of Bits, December 2025)

- Report: [irrelevant/2025-12-offchain-arbitrum-chains-genesis-generator-securityreview.md](<reports/irrelevant/2025-12-offchain-arbitrum-chains-genesis-generator-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2025-12-01
- Description: Eight engineer-day Trail of Bits review of the genesis file generator tool that lets Arbitrum chains start with a predefined state (commit 59f69a9). Irrelevant off-chain tooling; one Undetermined finding was reported.

### Stylus SDK v0.10 Audit (OpenZeppelin, December 2025)

- Report: [irrelevant/2025_12_10_open_zeppelin_stylus_sdk_v0_10_audit.md](<reports/irrelevant/2025_12_10_open_zeppelin_stylus_sdk_v0_10_audit.md>)
- Auditor: OpenZeppelin
- Date: 2025-12-10
- Description: OpenZeppelin audit of the OffchainLabs/stylus-sdk-rs library at commit 4003c3f (v0.10-rc.1), covering the SDK, cargo-stylus tooling, verification and reproducible builds. Classified irrelevant because the SDK is a developer library compiled into user programs; one Critical, three High, nineteen Medium and seventeen Low findings were reported.

### Arbitrum Stylus SDK Pull Request #370 Audit (OpenZeppelin, December 2025)

- Report: [irrelevant/2025_12_19_open_zeppelin_stylus_sdk_pull_request_370_audit.md](<reports/irrelevant/2025_12_19_open_zeppelin_stylus_sdk_pull_request_370_audit.md>)
- Auditor: OpenZeppelin
- Date: 2025-12-19
- Description: OpenZeppelin audit of the changes in stylus-sdk-rs pull request #370 at commit 8e2202c. Classified irrelevant because the SDK is a developer library compiled into user programs; one High and one Low finding were reported.

### Offchain Labs 3.2.0 Upgrade Action Contract Summary Report (Trail of Bits, July 2026)

- Report: [irrelevant/2026-07-offchainlabs-3.2.0-upgradeactioncontract-securityreview.md](<reports/irrelevant/2026-07-offchainlabs-3.2.0-upgradeactioncontract-securityreview.md>)
- Auditor: Trail of Bits
- Date: 2026-07-31
- Description: Four engineer-day Trail of Bits review of the arbitrum-chain-actions contract upgrading a rollup from nitro-contracts v3.1.0 to v3.2.0 (commit fdab5b8), checking correct proxy upgrades and expected addresses. Irrelevant one-time upgrade action code; no findings were reported.
