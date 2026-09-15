# Audit source summary: optimism

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Optimism Security Assessment (OVM contracts, October 2020)

- Report: [2020_10-Rollup-TrailOfBits.md](<reports/2020_10-Rollup-TrailOfBits.md>)
- Auditor: Trail of Bits
- Date: 2020-10-30
- Description: Trail of Bits whitebox assessment of the OVM Solidity contracts in the contracts-v2 repository, focused on the Merkle/RLP/trie libraries, OVM_SafetyChecker, the Canonical Transaction Chain, State Commitment Chain, Fraud Verifier and State Transitioner, plus access controls and arithmetic. The execution manager, bond manager, L2 precompiles, compiler fork and offchain components were out of scope.

### Repository: <a href="https://github.com/ethereum-optimism/contracts-v2"><code>ethereum-optimism/contracts-v2</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/f6f5f3a63bc99b4e9ab26b51db7206d22213c406"><code>f6f5f3a63bc99b4e9ab26b51db7206d22213c406</code></a> | October 20, 2020 | <code>contracts/optimistic-ethereum/libraries/utils/Lib_MerkleUtils.sol</code><br><code>contracts/optimistic-ethereum/libraries/rlp/Lib_RLPReader.sol</code><br><code>contracts/optimistic-ethereum/libraries/rlp/Lib_RLPWriter.sol</code><br><code>contracts/optimistic-ethereum/libraries/trie/Lib_MerkleTrie.sol</code><br><code>contracts/optimistic-ethereum/libraries/trie/Lib_SecureMerkleTrie.sol</code><br><code>contracts/optimistic-ethereum/libraries/resolver/Lib_AddressManager.sol</code><br><code>contracts/optimistic-ethereum/libraries/utils/Lib_RingBuffer.sol</code><br><code>contracts/optimistic-ethereum/OVM/execution/OVM_SafetyChecker.sol</code><br><code>contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol</code><br><code>contracts/optimistic-ethereum/OVM/chain/OVM_StateCommitmentChain.sol</code><br><code>contracts/optimistic-ethereum/OVM/verification/OVM_FraudVerifier.sol</code><br><code>contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol</code><br><code>contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitionerFactory.sol</code><br><code>contracts/optimistic-ethereum/OVM/bridge/OVM_BaseCrossDomainMessenger.sol</code><br><code>contracts/optimistic-ethereum/OVM/bridge/OVM_L1CrossDomainMessenger.sol</code><br><code>contracts/optimistic-ethereum/OVM/bridge/OVM_L2CrossDomainMessenger.sol</code><br><code>contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/execution/OVM_StateManager.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/verification/OVM_BondManager.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/precompiles</code> (recursive directory) (explicitly not audited) |

## Optimism Audit Report: ECDSA Wallet

- Report: [2020_11-Dapphub-ECDSA_Wallet.md](<reports/2020_11-Dapphub-ECDSA_Wallet.md>)
- Auditor: dapp.org
- Date: 2021-01-12
- Description: dapp.org review of the OVM ECDSA smart-wallet contracts OVM_ECDSAContractAccount and OVM_ProxyEOA in contracts-v2, validating authentication, EOA-equivalence, upgrade-consent and non-brickability properties with a dapptools test suite. Several High findings were located in the byte/RLP utility libraries reached through the wallet code, and per-finding fix commits are listed.

### Repository: <a href="https://github.com/ethereum-optimism/contracts-v2"><code>ethereum-optimism/contracts-v2</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/bb3539bbd10c15a72a46cf4fb8d2472ef68f6322"><code>bb3539bbd10c15a72a46cf4fb8d2472ef68f6322</code></a> | November 18, 2020 | <code>contracts/optimistic-ethereum/OVM/accounts/OVM_ECDSAContractAccount.sol</code><br><code>contracts/optimistic-ethereum/OVM/accounts/OVM_ProxyEOA.sol</code><br><code>contracts/optimistic-ethereum/libraries/utils/Lib_Bytes32Utils.sol</code><br><code>contracts/optimistic-ethereum/libraries/utils/Lib_BytesUtils.sol</code><br><code>contracts/optimistic-ethereum/libraries/rlp/Lib_RLPWriter.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/0aa6e3a6380480355efe2afccc064bbd52d0be77"><code>0aa6e3a6380480355efe2afccc064bbd52d0be77</code></a> | November 30, 2020 | <code>contracts/optimistic-ethereum/OVM/accounts/OVM_ECDSAContractAccount.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/6712904754728a0bd195bc654d977bafa6ae8fbe"><code>6712904754728a0bd195bc654d977bafa6ae8fbe</code></a> | November 30, 2020 | <code>contracts/optimistic-ethereum/libraries/utils/Lib_BytesUtils.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/6a4d48ae185b7ea984bdac84e08f0b4da3e5e5cc"><code>6a4d48ae185b7ea984bdac84e08f0b4da3e5e5cc</code></a> | December 2, 2020 | <code>contracts/optimistic-ethereum/OVM/accounts/OVM_ECDSAContractAccount.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/244424f14a9d3f4023d68d01b1ed0074d05efcb4"><code>244424f14a9d3f4023d68d01b1ed0074d05efcb4</code></a> | December 2, 2020 | <code>contracts/optimistic-ethereum/libraries/utils/Lib_Bytes32Utils.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/96baeba3feabdac09c9d9dd121c31bc2d2b63e7e"><code>96baeba3feabdac09c9d9dd121c31bc2d2b63e7e</code></a> | December 3, 2020 | <code>contracts/optimistic-ethereum/libraries/rlp/Lib_RLPWriter.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/46e2f65cf6cc33fc78adf399d9ab059d4de759e3"><code>46e2f65cf6cc33fc78adf399d9ab059d4de759e3</code></a> | December 11, 2020 | <code>contracts/optimistic-ethereum/OVM/accounts/OVM_ECDSAContractAccount.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts-v2/commit/ca84d456898b1a9aa3c7330d7833794e79aa0ef5"><code>ca84d456898b1a9aa3c7330d7833794e79aa0ef5</code></a> | January 8, 2021 | <code>contracts/optimistic-ethereum/libraries/utils/Lib_BytesUtils.sol</code> |

## OpenZeppelin OVM and Rollup Audit (March-May 2021)

- Report: [2021_03-OVM_and_Rollup-OpenZeppelin.md](<reports/2021_03-OVM_and_Rollup-OpenZeppelin.md>)
- Auditor: OpenZeppelin
- Description: Seven-week OpenZeppelin audit of the OVM Solidity contracts under contracts/optimistic-ethereum/OVM and contracts/optimistic-ethereum/libraries across two commits (the archived contracts repository and a personal fork), excluding the bond manager, safety checker, ERC1820 registry and deployer whitelist. A later update section records per-finding fixes in the archived repository and the optimism monorepo.

### Repository: <a href="https://github.com/ethereum-optimism/contracts"><code>ethereum-optimism/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/contracts/commit/18e128343731b9bde23812ce932e24d81440b6b7"><code>18e128343731b9bde23812ce932e24d81440b6b7</code></a> | March 15, 2021 | <code>contracts/optimistic-ethereum/OVM</code> (recursive directory)<br><code>contracts/optimistic-ethereum/libraries</code> (recursive directory)<br><code>contracts/optimistic-ethereum/OVM/verification/OVM_BondManager.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/execution/OVM_SafetyChecker.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/precompiles/ERC1820Registry.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/precompiles/OVM_DeployerWhitelist.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/libraries/utils/Lib_RingBuffer.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts/commit/eeb9f71fe0d99cb3147a9eca135e1650c8fad6ba"><code>eeb9f71fe0d99cb3147a9eca135e1650c8fad6ba</code></a> | April 6, 2021 | <code>contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol</code> |
| <a href="https://github.com/ethereum-optimism/contracts/commit/8da1c24bb08b8a10b56747add78c414e58ebadf4"><code>8da1c24bb08b8a10b56747add78c414e58ebadf4</code></a> | April 7, 2021 | <code>contracts/optimistic-ethereum/OVM/verification/OVM_StateTransitioner.sol</code> |

### Repository: <a href="https://github.com/ben-chain/contracts-v2"><code>ben-chain/contracts-v2</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ben-chain/contracts-v2/commit/a935e276f5620b40802b52721e3474232e458f72"><code>a935e276f5620b40802b52721e3474232e458f72</code></a> | April 12, 2021 | <code>contracts/optimistic-ethereum/OVM</code> (recursive directory)<br><code>contracts/optimistic-ethereum/libraries</code> (recursive directory)<br><code>contracts/optimistic-ethereum/OVM/verification/OVM_BondManager.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/execution/OVM_SafetyChecker.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/predeploys/ERC1820Registry.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/OVM/predeploys/OVM_DeployerWhitelist.sol</code> (explicitly not audited)<br><code>contracts/optimistic-ethereum/libraries/utils/Lib_RingBuffer.sol</code> |

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ae1ac05d7032422a71caf25d16f6e548df5b8d7f"><code>ae1ac05d7032422a71caf25d16f6e548df5b8d7f</code></a> | May 4, 2021 | <code>packages/contracts/contracts/optimistic-ethereum/libraries/trie/Lib_MerkleTrie.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/293a386efb8aa574eb53767a3f09cda928a09095"><code>293a386efb8aa574eb53767a3f09cda928a09095</code></a> | May 10, 2021 | <code>packages/contracts/contracts/optimistic-ethereum/OVM/predeploys/OVM_SequencerEntrypoint.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/4a5bb28203dc6460b6e7ddaff3cd89e45a6b4d54"><code>4a5bb28203dc6460b6e7ddaff3cd89e45a6b4d54</code></a> | June 8, 2021 | <code>packages/contracts/contracts/optimistic-ethereum/OVM/accounts/OVM_ECDSAContractAccount.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ce8071bc5ead86b75d5995111597bcdc4dc34385"><code>ce8071bc5ead86b75d5995111597bcdc4dc34385</code></a> | June 11, 2021 | <code>packages/contracts/contracts/optimistic-ethereum/OVM/bridge/tokens/OVM_L1ERC20Gateway.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/aafb141bf798c657e8e0193e718068bed9211ebf"><code>aafb141bf798c657e8e0193e718068bed9211ebf</code></a> | June 24, 2021 | <code>packages/contracts/contracts/optimistic-ethereum/OVM/chain/OVM_CanonicalTransactionChain.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/a2346c291797813f99b32e1d92f26c33a6d55d2d"><code>a2346c291797813f99b32e1d92f26c33a6d55d2d</code></a> | October 12, 2021 | <code>packages/contracts/contracts/optimistic-ethereum/OVM/execution/OVM_ExecutionManager.sol</code> |

## Optimism SafetyChecker (ConsenSys Diligence)

- Report: [2021_03-SafetyChecker-ConsenSysDiligence.md](<reports/2021_03-SafetyChecker-ConsenSysDiligence.md>)
- Auditor: ConsenSys Diligence
- Description: Two-person-week differential fuzzing engagement comparing OVM_SafetyChecker.isBytecodeSafe against a custom Go reference implementation, with an informal specification of safe OVM bytecode and forward-looking recommendations. No divergences or vulnerability findings were reported.

### Repository: <a href="https://github.com/ethereum-optimism/contracts"><code>ethereum-optimism/contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/contracts/commit/606577457191973b46034602f46ddcc130a5c0ac"><code>606577457191973b46034602f46ddcc130a5c0ac</code></a> | March 12, 2021 | <code>contracts/optimistic-ethereum/OVM/execution/OVM_SafetyChecker.sol</code> |

## Optimism Bridge Audit (OpenZeppelin, May 2022)

- Report: [2022_05-Bedrock_Contracts-Zeppelin.md](<reports/2022_05-Bedrock_Contracts-Zeppelin.md>)
- Auditor: OpenZeppelin
- Date: 2022-05-16
- Description: OpenZeppelin audit of the new Bedrock L1/L2 bridge and messaging contracts (OptimismPortal, L2OutputOracle, cross-domain messengers, standard bridges, L2ToL1MessagePasser, mintable tokens) in the optimistic-specs repository, reviewed across three successive commits during a rewrite. Offchain components and L2 nodes were assumed to work as documented.

### Repository: <a href="https://github.com/ethereum-optimism/optimistic-specs"><code>ethereum-optimism/optimistic-specs</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimistic-specs/commit/0c054885a6fd2011503784464da1e94997251fe3"><code>0c054885a6fd2011503784464da1e94997251fe3</code></a> | April 30, 2022 | <code>packages/contracts/contracts</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimistic-specs/commit/e2da9e21f449f5f5868a539d67dfd23f4d913f16"><code>e2da9e21f449f5f5868a539d67dfd23f4d913f16</code></a> | May 11, 2022 | <code>packages/contracts/contracts</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimistic-specs/commit/8cbaf02ed6a7ecbad1b86e5ea1781566031ff694"><code>8cbaf02ed6a7ecbad1b86e5ea1781566031ff694</code></a> | May 16, 2022 | <code>packages/contracts/contracts</code> (recursive directory) |

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Optimism: Rollup Node and Execution Engine - Fix Review

- Report: [2022_05-OpNode-TrailOfBits.md](<reports/2022_05-OpNode-TrailOfBits.md>)
- Auditor: Trail of Bits
- Date: 2022-07-07
- Description: Trail of Bits fix review of the twelve findings from its April 2022 audit of the Bedrock rollup node (optimistic-specs, Go and Solidity) and the reference execution engine (reference-optimistic-geth). Solidity findings target the L1 deposit/withdrawal contracts and the L1Block predeploy; the remaining findings target Go code and specifications.

### Repository: <a href="https://github.com/ethereum-optimism/optimistic-specs"><code>ethereum-optimism/optimistic-specs</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimistic-specs/commit/05136a32b9828b595dde47f767218dec53f19aa4"><code>05136a32b9828b595dde47f767218dec53f19aa4</code></a> | April 11, 2022 | <code>packages/contracts/contracts</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimistic-specs/commit/e398ba7aaa1872188f371de517df9649330a03cd"><code>e398ba7aaa1872188f371de517df9649330a03cd</code></a> | April 18, 2022 | <code>packages/contracts/contracts</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimistic-specs/commit/bbefaa80b59c6b3ecd0e18d0862e859be9f92aa9"><code>bbefaa80b59c6b3ecd0e18d0862e859be9f92aa9</code></a> | April 26, 2022 | <code>packages/contracts/contracts</code> (recursive directory) |

### Repository: <a href="https://github.com/ethereum-optimism/reference-optimistic-geth"><code>ethereum-optimism/reference-optimistic-geth</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Optimism Bedrock and Periphery Audit (OpenZeppelin)

- Report: [2022_09-Bedrock_and_Periphery-Zeppelin.md](<reports/2022_09-Bedrock_and_Periphery-Zeppelin.md>)
- Auditor: OpenZeppelin
- Date: 2022-09-02
- Description: OpenZeppelin audit of nineteen listed Solidity files in the optimism monorepo covering the Bedrock L1/L2 messengers, bridges, portal, output oracle, proxies and the periphery ERC721 bridges; no Critical or High issues were found. Fixes were reviewed in the separate optimism-audit-fixes repository, which is not publicly accessible.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/93d3bd411a8ae75702539ac9c5fe00bad21d4104"><code>93d3bd411a8ae75702539ac9c5fe00bad21d4104</code></a> | July 21, 2022 | <code>packages/contracts/contracts/chugsplash/L1ChugSplashProxy.sol</code><br><code>packages/contracts/contracts/libraries/bridge/CrossDomainEnabled.sol</code><br><code>packages/contracts/contracts/libraries/constants/Lib_PredeployAddresses.sol</code><br><code>packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/contracts/L1/L2OutputOracle.sol</code><br><code>packages/contracts-bedrock/contracts/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/contracts/L1/ResourceMetering.sol</code><br><code>packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol</code><br><code>packages/contracts-bedrock/contracts/L2/L2ToL1MessagePasser.sol</code><br><code>packages/contracts-bedrock/contracts/libraries/Hashing.sol</code><br><code>packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/contracts/universal/Proxy.sol</code><br><code>packages/contracts-bedrock/contracts/universal/ProxyAdmin.sol</code><br><code>packages/contracts-bedrock/contracts/universal/Semver.sol</code><br><code>packages/contracts-bedrock/contracts/universal/StandardBridge.sol</code><br><code>packages/contracts-periphery/contracts/L1/L1ERC721Bridge.sol</code><br><code>packages/contracts-periphery/contracts/L2/L2ERC721Bridge.sol</code> |

### Repository: <a href="https://github.com/ethereum-optimism/optimism-audit-fixes"><code>ethereum-optimism/optimism-audit-fixes</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Optimism Drippie Security Review

- Report: [2022_10-Drippie-Spearbit.md](<reports/2022_10-Drippie-Spearbit.md>)
- Auditor: Spearbit
- Date: 2022-10-03
- Description: Spearbit manual review plus Mythril of the Drippie automated contract-interaction system (Drippie, drip checks, AssetReceiver, Transactor) in the optimism monorepo&#x27;s contracts-periphery package. No Critical or High issues; fixes were reviewed in pull requests 3280 and 3567.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/2a7be367634f147736f960eb2f38a77291cdfcad"><code>2a7be367634f147736f960eb2f38a77291cdfcad</code></a> | July 29, 2022 | <code>packages/contracts-periphery/contracts/universal/drippie</code> (recursive directory)<br><code>packages/contracts-periphery/contracts/universal/AssetReceiver.sol</code><br><code>packages/contracts-periphery/contracts/universal/Transactor.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/eb2c55681306c5ee495378184fb9a0e97a99fc1a"><code>eb2c55681306c5ee495378184fb9a0e97a99fc1a</code></a> | September 19, 2022 | <code>packages/contracts-periphery/contracts/universal/drippie</code> (recursive directory)<br><code>packages/contracts-periphery/contracts/universal/AssetReceiver.sol</code><br><code>packages/contracts-periphery/contracts/universal/Transactor.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/b17f3c93b6fb00827c4b87573682c499415fc8e6"><code>b17f3c93b6fb00827c4b87573682c499415fc8e6</code></a> | September 26, 2022 | <code>packages/contracts-periphery/contracts/universal/drippie</code> (recursive directory) |

## Optimism Security Assessment (testing strategy and invariants, November 2022)

- Report: [2022_11-Invariant_Testing-TrailOfBits.md](<reports/2022_11-Invariant_Testing-TrailOfBits.md>)
- Auditor: Trail of Bits
- Date: 2022-11-10
- Description: Trail of Bits review of Optimism&#x27;s testing strategy: documentation of invariants and Echidna property tests for Bedrock contracts (OptimismPortal, ResourceMetering, L2OutputOracle and libraries) plus Go fuzz/unit tests for op-node, op-e2e and op-geth. One Undetermined-severity finding; the Go components are offchain.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/b31d35b67755479645dd150e7cc8c6710f0b4a56"><code>b31d35b67755479645dd150e7cc8c6710f0b4a56</code></a> | August 17, 2022 | <code>packages/contracts-bedrock/contracts/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/contracts/L1/ResourceMetering.sol</code><br><code>packages/contracts-bedrock/contracts/L1/L2OutputOracle.sol</code><br><code>packages/contracts-bedrock/contracts/libraries/Burn.sol</code><br><code>packages/contracts-bedrock/contracts/libraries/Encoding.sol</code><br><code>packages/contracts-bedrock/contracts/libraries/Hashing.sol</code><br><code>packages/contracts-bedrock/contracts/vendor/AddressAliasHelper.sol</code> |

### Repository: <a href="https://github.com/ethereum-optimism/reference-optimistic-geth"><code>ethereum-optimism/reference-optimistic-geth</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Formal Verification Report: OptimismPortal.depositTransaction

- Report: [2022_12-DepositTransaction-RuntimeVerification.md](<reports/2022_12-DepositTransaction-RuntimeVerification.md>)
- Auditor: Runtime Verification
- Date: 2022-12-23
- Description: Runtime Verification pilot using KEVM-Foundry to prove that OptimismPortal.depositTransaction always emits the correct event except under enumerated invalid invocations, excluding the metered modifier. The report names no repository, commit or file path, so no source coverage can be pinned.

## Optimism: SystemConfig and Withdrawal Updates - Security Assessment

- Report: [2023_01-Bedrock_Updates-TrailOfBits.md](<reports/2023_01-Bedrock_Updates-TrailOfBits.md>)
- Auditor: Trail of Bits
- Date: 2023-01-18
- Description: Trail of Bits review of the L1 SystemConfig contract and the two-step withdrawal workflow of OptimismPortal, together with the related op-node config parsing and op-geth L1 cost logic. Late commits changing ResourceMetering, L2ToL1MessagePasser, L2OutputOracle, MerkleTrie and two portal pull requests were reviewed in isolation, and the single High finding was verified fixed.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/1bfe79f20b37a77c1158e7c5fdbff2ae109e0a1d"><code>1bfe79f20b37a77c1158e7c5fdbff2ae109e0a1d</code></a> | November 11, 2022 | <code>packages/contracts-bedrock/contracts/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/contracts/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/contracts/L1/ResourceMetering.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/f468e58ef9554501d0821008c98b233411e19915"><code>f468e58ef9554501d0821008c98b233411e19915</code></a> | November 22, 2022 | <code>packages/contracts-bedrock/contracts/L1/OptimismPortal.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/991120f6d2009b4a96580d7db3021694439c63f5"><code>991120f6d2009b4a96580d7db3021694439c63f5</code></a> | November 29, 2022 | <code>packages/contracts-bedrock/contracts/libraries/trie/MerkleTrie.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ee96ff8585699b054c95c6ff4a2411ee9fedcc87"><code>ee96ff8585699b054c95c6ff4a2411ee9fedcc87</code></a> | December 5, 2022 | <code>packages/contracts-bedrock/contracts/L1/ResourceMetering.sol</code><br><code>packages/contracts-bedrock/contracts/L2/L2ToL1MessagePasser.sol</code><br><code>packages/contracts-bedrock/contracts/L1/L2OutputOracle.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/5bb91e5166849f205ed045a3a1fb459b2d40cc5d"><code>5bb91e5166849f205ed045a3a1fb459b2d40cc5d</code></a> | December 8, 2022 | <code>packages/contracts-bedrock/contracts/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/2bd5143fa28d3faf7cbc7c89f9356935122f7f80"><code>2bd5143fa28d3faf7cbc7c89f9356935122f7f80</code></a> | December 9, 2022 | <code>packages/contracts-bedrock/contracts/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/contracts/universal/CrossDomainMessenger.sol</code> |

### Repository: <a href="https://github.com/ethereum-optimism/op-geth"><code>ethereum-optimism/op-geth</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Sherlock Security Review for Optimism (Bedrock)

- Report: [2023_03-Bedrock-Sherlock.md](<reports/2023_03-Bedrock-Sherlock.md>)
- Auditor: Sherlock
- Date: 2023-03-03
- Description: Public Sherlock contest on the Bedrock release covering the L1 contracts, L2 predeploys, op-node and op-geth at a fixed monorepo commit, with three High findings in OptimismPortal withdrawal finalization. No fix-review commit is given; op-node and op-geth are offchain and not recorded as source coverage.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/3f4b3c328153a8aa03611158b6984d624b17c1d9"><code>3f4b3c328153a8aa03611158b6984d624b17c1d9</code></a> | January 12, 2023 | <code>packages/contracts-bedrock/contracts/L1</code> (recursive directory)<br><code>packages/contracts-bedrock/contracts/L2</code> (recursive directory) |

### Repository: <a href="https://github.com/ethereum-optimism/op-geth"><code>ethereum-optimism/op-geth</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Agora Audit Report - Optimism Governor &amp; Approval Voting Module

- Report: [2023_05-Governor-ZachObront.md](<reports/2023_05-Governor-ZachObront.md>)
- Auditor: Zach Obront
- Date: 2023-05-12
- Description: Independent review by Zach Obront of Agora&#x27;s Optimism Governor V5 upgrade and the new Approval Voting Module in the voteagora/optimism-gov repository. Two High findings; fixes were verified per commit and pull request 10 was reviewed after completion.

### Repository: <a href="https://github.com/voteagora/optimism-gov"><code>voteagora/optimism-gov</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/voteagora/optimism-gov/commit/35f441738bd7864bd37949a40842486bc0ac51b0"><code>35f441738bd7864bd37949a40842486bc0ac51b0</code></a> | May 9, 2023 | <code>src/OptimismGovernorV5.sol</code><br><code>src/modules/ApprovalVotingModule.sol</code><br><code>src/modules/VotingModule.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/39880bd56c99a83b5df3fafbc3c6d35f104a1cda"><code>39880bd56c99a83b5df3fafbc3c6d35f104a1cda</code></a> | May 11, 2023 | <code>src/modules/ApprovalVotingModule.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/6aa306ea5df526bd49e88073daa0da27c5b56e5e"><code>6aa306ea5df526bd49e88073daa0da27c5b56e5e</code></a> | June 21, 2023 | <code>src/OptimismGovernorV5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/cf1a0ded961f6c617642bb00ed14e3ca87a7a715"><code>cf1a0ded961f6c617642bb00ed14e3ca87a7a715</code></a> | June 21, 2023 | <code>src/OptimismGovernorV5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/20e645198d10646c6923e8a9caafb05e536d8fe3"><code>20e645198d10646c6923e8a9caafb05e536d8fe3</code></a> | June 21, 2023 | <code>src/OptimismGovernorV5.sol</code><br><code>src/modules/ApprovalVotingModule.sol</code><br><code>src/modules/VotingModule.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/a89a51559f3b116c60703b2acb2c48bf51121692"><code>a89a51559f3b116c60703b2acb2c48bf51121692</code></a> | June 21, 2023 | <code>src/modules/ApprovalVotingModule.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/1152881afcb6272a29e80b0cb17914007a68cd27"><code>1152881afcb6272a29e80b0cb17914007a68cd27</code></a> | June 22, 2023 | <code>src/OptimismGovernorV5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/41d5fd3f460a9fbe3298b967c360795a67de5cfe"><code>41d5fd3f460a9fbe3298b967c360795a67de5cfe</code></a> | June 23, 2023 | <code>src/OptimismGovernorV5.sol</code><br><code>src/modules/ApprovalVotingModule.sol</code><br><code>src/modules/VotingModule.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/74b6df0e9ef73c565518535ad02aa2481e4604c4"><code>74b6df0e9ef73c565518535ad02aa2481e4604c4</code></a> | June 27, 2023 | <code>src/OptimismGovernorV5.sol</code><br><code>src/modules/ApprovalVotingModule.sol</code><br><code>src/modules/VotingModule.sol</code> |

## BASE Findings &amp; Analysis Report (Code4rena)

- Report: [2023_08-OP-Stack-Base-Code4rena.md](<reports/2023_08-OP-Stack-Base-Code4rena.md>)
- Auditor: Code4rena
- Date: 2023-08-10
- Description: Code4rena competitive audit of the BASE (OP Stack Bedrock) system: fourteen Solidity contracts plus op-node and op-geth, frozen at the optimism monorepo commit named by the contest repository. Zero High or Medium findings; only the top QA and gas reports are reproduced.

### Repository: <a href="https://github.com/code-423n4/2023-05-base"><code>code-423n4/2023-05-base</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/382d38b7d45bcbf73cb5e1e3f28cbd45d24e8a59"><code>382d38b7d45bcbf73cb5e1e3f28cbd45d24e8a59</code></a> | May 15, 2023 | <code>packages/contracts-bedrock/contracts/deployment/SystemDictator.sol</code><br><code>packages/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/contracts/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/contracts/L1/L2OutputOracle.sol</code><br><code>packages/contracts-bedrock/contracts/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/contracts/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/contracts/L2/GasPriceOracle.sol</code><br><code>packages/contracts-bedrock/contracts/L2/L1Block.sol</code><br><code>packages/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/contracts/L2/L2StandardBridge.sol</code><br><code>packages/contracts-bedrock/contracts/L2/L2ToL1MessagePasser.sol</code><br><code>packages/contracts-bedrock/contracts/L2/SequencerFeeVault.sol</code><br><code>packages/contracts-bedrock/contracts/universal/OptimismMintableERC20Factory.sol</code><br><code>packages/contracts-bedrock/contracts/universal/ProxyAdmin.sol</code> |

### Repository: <a href="https://github.com/ethereum-optimism/op-geth"><code>ethereum-optimism/op-geth</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Agora Optimism Governance Audit (OpenZeppelin)

- Report: [2023_11-Governor-OpenZeppelin.md](<reports/2023_11-Governor-OpenZeppelin.md>)
- Auditor: OpenZeppelin
- Date: 2023-11-22
- Description: OpenZeppelin audit of Agora&#x27;s Optimism Governance V6 upgrade: OptimismGovernorV6, ProposalTypesConfigurator, VotableSupplyOracle and AlligatorOP_V5, with per-finding resolutions in pull request 16. No Critical or High issues; the report prints no repository URL, so the voteagora/optimism-gov repository was identified from the matching commit and pull request.

### Repository: <a href="https://github.com/voteagora/optimism-gov"><code>voteagora/optimism-gov</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/voteagora/optimism-gov/commit/a22052d3957b4c963d57f78b52c12f9f8609a720"><code>a22052d3957b4c963d57f78b52c12f9f8609a720</code></a> | October 7, 2023 | <code>src/OptimismGovernorV6.sol</code><br><code>src/ProposalTypesConfigurator.sol</code><br><code>src/VotableSupplyOracle.sol</code><br><code>src/alligator/AlligatorOP_V5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/422928946c8df15c44cff17e3225b983b5707383"><code>422928946c8df15c44cff17e3225b983b5707383</code></a> | November 2, 2023 | <code>src/alligator/AlligatorOP_V5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/0b40e397d688cfe33d297b52ccbf89b069f65ad6"><code>0b40e397d688cfe33d297b52ccbf89b069f65ad6</code></a> | November 2, 2023 | <code>src/OptimismGovernorV6.sol</code><br><code>src/ProposalTypesConfigurator.sol</code><br><code>src/VotableSupplyOracle.sol</code><br><code>src/alligator/AlligatorOP_V5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/acba358f94ea230eb43e59580ec657b25072a917"><code>acba358f94ea230eb43e59580ec657b25072a917</code></a> | November 2, 2023 | <code>src/OptimismGovernorV6.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/1507cf306788b0c9bf727db0bb0e8e9c1b579f4f"><code>1507cf306788b0c9bf727db0bb0e8e9c1b579f4f</code></a> | November 2, 2023 | <code>src/OptimismGovernorV6.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/bb8280162b922e6db78ffeac232a94dd09da243f"><code>bb8280162b922e6db78ffeac232a94dd09da243f</code></a> | November 2, 2023 | <code>src/OptimismGovernorV6.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/f07004c64673ebcd17369a313c13499b794558cc"><code>f07004c64673ebcd17369a313c13499b794558cc</code></a> | November 2, 2023 | <code>src/ProposalTypesConfigurator.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/7bd01b6a34c698a13768b30d0f9b3da0156c7e04"><code>7bd01b6a34c698a13768b30d0f9b3da0156c7e04</code></a> | November 2, 2023 | <code>src/VotableSupplyOracle.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/383292a0b708661a398f594f05baf4ab540122b9"><code>383292a0b708661a398f594f05baf4ab540122b9</code></a> | November 2, 2023 | <code>src/alligator/AlligatorOP_V5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/bc48b7ebac6e294181ca4baf81c4848cb75063e0"><code>bc48b7ebac6e294181ca4baf81c4848cb75063e0</code></a> | November 2, 2023 | <code>src/alligator/AlligatorOP_V5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/b137b4d019cf1161e0d91f27c64da38895d99c8a"><code>b137b4d019cf1161e0d91f27c64da38895d99c8a</code></a> | November 2, 2023 | <code>src/alligator/AlligatorOP_V5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/d3b72305a6a7ffbc1851870174163a9608ff25d9"><code>d3b72305a6a7ffbc1851870174163a9608ff25d9</code></a> | November 2, 2023 | <code>src/OptimismGovernorV6.sol</code><br><code>src/alligator/AlligatorOP_V5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/9b58c4c666163538e7cc41d7d6291bcb6ec71301"><code>9b58c4c666163538e7cc41d7d6291bcb6ec71301</code></a> | November 2, 2023 | <code>src/OptimismGovernorV6.sol</code><br><code>src/ProposalTypesConfigurator.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/698f5f6d8c16efe8138535e57d8dd4410147da44"><code>698f5f6d8c16efe8138535e57d8dd4410147da44</code></a> | November 2, 2023 | <code>src/OptimismGovernorV6.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/03ce19455abdd95e7008d573207199797a6b54d8"><code>03ce19455abdd95e7008d573207199797a6b54d8</code></a> | November 2, 2023 | <code>src/OptimismGovernorV6.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/4ea04626d0cf94dbbbb81d97219777f338cdc8f7"><code>4ea04626d0cf94dbbbb81d97219777f338cdc8f7</code></a> | November 2, 2023 | <code>src/alligator/AlligatorOP_V5.sol</code> |
| <a href="https://github.com/voteagora/optimism-gov/commit/bd69f93d95e5063ab02bdf24fd40045f476b1f6f"><code>bd69f93d95e5063ab02bdf24fd40045f476b1f6f</code></a> | November 5, 2023 | <code>src/OptimismGovernorV6.sol</code> |

## Smart Contract Audit: Optimism Bedrock upgrade (Trust Security)

- Report: [2023_12_SuperchainConfigUpgrade_Trust.md](<reports/2023_12_SuperchainConfigUpgrade_Trust.md>)
- Auditor: Trust Security
- Date: 2024-01-11
- Description: Trust Security diff-based review of eight Bedrock L1 and universal bridging contracts changed since the Sherlock contest commit, chiefly the SuperchainConfig pause integration, gas-issue mitigations, storage-layout safety and reentrancy changes. One High finding, verified fixed in the mitigation review.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/d1651bb22645ebd41ac4bb2ab4786f9a56fc1003"><code>d1651bb22645ebd41ac4bb2ab4786f9a56fc1003</code></a> | December 7, 2023 | <code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/L1ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/universal/ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/universal/StandardBridge.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/4e5415107384f21d687a9aeb5ca40e9a97270250"><code>4e5415107384f21d687a9aeb5ca40e9a97270250</code></a> | December 15, 2023 | <code>packages/contracts-bedrock/src/L1/OptimismPortal.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/d03df252b3c5eb0735781f3f498cb4b102be3544"><code>d03df252b3c5eb0735781f3f498cb4b102be3544</code></a> | January 8, 2024 | <code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/81b56fee40f96c798174115c375f41c3d2ff9d40"><code>81b56fee40f96c798174115c375f41c3d2ff9d40</code></a> | January 8, 2024 | <code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/L1ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/universal/ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/universal/StandardBridge.sol</code> |

## Optimism Cycle 19 Security Review (Cantina, MCP L1)

- Report: [2024_02-MCP_L1-Cantina.md](<reports/2024_02-MCP_L1-Cantina.md>)
- Auditor: Cantina
- Date: 2024-02-15
- Description: Cantina Managed review of the MCP L1 (multi-chain prep) upgrade that moves L1 contract immutables into storage and adds initializer parameters, covering the affected contracts-bedrock Solidity contracts and the op-chain-ops upgrade tooling in Go. No Critical, High or Medium issues; the report declares no explicit file list.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/e6ef3a900c42c8722e72c2e2314027f85d12ced5"><code>e6ef3a900c42c8722e72c2e2314027f85d12ced5</code></a> | January 22, 2024 | <code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal.sol</code><br><code>packages/contracts-bedrock/src/L2/L2CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/universal/FeeVault.sol</code><br><code>packages/contracts-bedrock/src/universal/ERC721Bridge.sol</code> |

## Sherlock Security Review for Optimism (Fault Proofs)

- Report: [2024_05-FaultProofs-Sherlock.md](<reports/2024_05-FaultProofs-Sherlock.md>)
- Auditor: Sherlock
- Date: 2024-06-07
- Description: Public Sherlock contest on the fault proof system&#x27;s L1 contracts (OptimismPortal2, DisputeGameFactory, FaultDisputeGame, DelayedWETH, WETH98) at a fixed monorepo commit, with four Medium and no High findings. FaultDisputeGame resolution logic was explicitly excluded from the contest scope.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/5137f3b74c6ebcac4f0f5a118b0f4909df03aec6"><code>5137f3b74c6ebcac4f0f5a118b0f4909df03aec6</code></a> | March 26, 2024 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code><br><code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/weth/DelayedWETH.sol</code><br><code>packages/contracts-bedrock/src/dispute/weth/WETH98.sol</code> |

### Repository: <a href="https://github.com/sherlock-audit/2024-02-optimism-2024"><code>sherlock-audit/2024-02-optimism-2024</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Optimism Safe Extensions Competition (Cantina)

- Report: [2024_05_SafeLivenessExtensions-Cantina.md](<reports/2024_05_SafeLivenessExtensions-Cantina.md>)
- Auditor: Cantina
- Date: 2024-06-06
- Description: Cantina competition on the Security Council Safe extensions LivenessGuard and LivenessModule in contracts-bedrock, reporting six Medium findings out of 143 submissions and no Critical or High issues. The report prints no commit; the revision comes from the single GitHub permalink in the report.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/48393a6a1ea32efac65bb3ce6617cf101ad88225"><code>48393a6a1ea32efac65bb3ce6617cf101ad88225</code></a> | May 10, 2024 | <code>packages/contracts-bedrock/src/Safe/LivenessGuard.sol</code><br><code>packages/contracts-bedrock/src/Safe/LivenessModule.sol</code> |

## Optimism Superchain Findings &amp; Analysis Report (Code4rena)

- Report: [2024_08-Superchain-Code4rena.md](<reports/2024_08-Superchain-Code4rena.md>)
- Auditor: Code4rena
- Date: 2024-08-16
- Description: Code4rena contest on the fault proof contracts (FaultDisputeGame, DisputeGameFactory, MIPS, PreimageOracle and libraries) hosted in the contest mirror repository, yielding five High and eleven Medium findings with no fix review. The file list and pinned commit come from the contest repository, which the report names as the code under review.

### Repository: <a href="https://github.com/code-423n4/2024-07-optimism"><code>code-423n4/2024-07-optimism</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/code-423n4/2024-07-optimism/commit/70556044e5e080930f686c4e5acde420104bb2c4"><code>70556044e5e080930f686c4e5acde420104bb2c4</code></a> | July 17, 2024 | <code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS.sol</code><br><code>packages/contracts-bedrock/src/cannon/PreimageOracle.sol</code><br><code>packages/contracts-bedrock/src/cannon/PreimageKeyLib.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/CannonTypes.sol</code> |

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Base fault proofs mips Security Review (Cantina)

- Report: [2024_08_Fault-Proofs-MIPS_Cantina.md](<reports/2024_08_Fault-Proofs-MIPS_Cantina.md>)
- Auditor: Cantina
- Date: 2024-08-14
- Description: Cantina Managed review, commissioned by Base, of the Cannon onchain MIPS single-step verifier MIPS.sol and its MIPSInstructions library at a fixed optimism monorepo commit, with one Critical and one High finding in MIPS.sol. All client responses are acknowledgements and no fix commit is given.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/71b93116738ee98c9f8713b1a5dfe626ce06c1b2"><code>71b93116738ee98c9f8713b1a5dfe626ce06c1b2</code></a> | June 17, 2024 | <code>packages/contracts-bedrock/src/cannon/MIPS.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPSInstructions.sol</code> |

## Base Fault Proofs no MIPS Security Review (Spearbit)

- Report: [2024_08_Fault-Proofs-No-MIPS_Spearbit.md](<reports/2024_08_Fault-Proofs-No-MIPS_Spearbit.md>)
- Auditor: Spearbit
- Date: 2024-08-14
- Description: Spearbit review, commissioned by Base, of the Optimism fault-proof dispute contracts (FaultDisputeGame, DisputeGameFactory, AnchorStateRegistry, dispute libraries, PreimageOracle) at a fixed monorepo commit, explicitly excluding MIPS. Four Medium and no Critical or High findings; no fix review.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/1f7081798ce2d49b8643514663d10681cb853a3d"><code>1f7081798ce2d49b8643514663d10681cb853a3d</code></a> | June 3, 2024 | <code>packages/contracts-bedrock/src/dispute</code> (recursive directory)<br><code>packages/contracts-bedrock/src/cannon/PreimageOracle.sol</code><br><code>packages/contracts-bedrock/src/cannon/PreimageKeyLib.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS.sol</code> (explicitly not audited) |

## Audit Report - OP Cannon (3DOC Security, F_GETFD)

- Report: [2024_10-Cannon-FGETFD-3DocSecurity.md](<reports/2024_10-Cannon-FGETFD-3DocSecurity.md>)
- Auditor: 3DOC Security
- Date: 2024-10-03
- Description: Two-day 3DOC Security review of pull request 12050 adding F_GETFD syscall support to the Cannon MIPS VM in both the Go implementation and the onchain MIPS, MIPS2 and MIPSSyscalls contracts. No findings; the single reported item was withdrawn as a false positive.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/32a6e3d3bc56ffe2f258a706cea0175600b9aa0e"><code>32a6e3d3bc56ffe2f258a706cea0175600b9aa0e</code></a> | September 30, 2024 | <code>packages/contracts-bedrock/src/cannon/MIPS.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS2.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPSSyscalls.sol</code> |

## Optimism DeputyPauseModule (MiloTruck)

- Report: [2024_12-DPM-MiloTruck.md](<reports/2024_12-DPM-MiloTruck.md>)
- Auditor: MiloTruck
- Date: 2025-01-07
- Description: Two-day independent review by MiloTruck of the DeputyPauseModule Safe module for signature-based emergency pauses, followed by verification of the mitigation commit and pull request 13594. Three Low and two Informational findings, none Critical or High.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/2f17e6b67c61de5d8073d556272796d201bc740b"><code>2f17e6b67c61de5d8073d556272796d201bc740b</code></a> | December 16, 2024 | <code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/abda59bcdeb1c829a83e3ffdfec747a5465aecc8"><code>abda59bcdeb1c829a83e3ffdfec747a5465aecc8</code></a> | January 9, 2025 | <code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/4851c96c25e1ad251d111a4f80b3395c73d7d0b2"><code>4851c96c25e1ad251d111a4f80b3395c73d7d0b2</code></a> | — | <code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code> |

## DeputyPauseModule Security Review (Radiant Labs)

- Report: [2024_12-DPM-RadiantLabs.md](<reports/2024_12-DPM-RadiantLabs.md>)
- Auditor: Radiant Labs
- Date: 2024-12-28
- Description: Two-day Radiant Labs manual review of the DeputyPauseModule contract against its design document and specification invariants. Two Low and two Informational findings, none Critical or High; no fix review.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/2f17e6b67c61de5d8073d556272796d201bc740b"><code>2f17e6b67c61de5d8073d556272796d201bc740b</code></a> | December 16, 2024 | <code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code> |

## Optimism Incident Response Updates Review (Offbeat Security)

- Report: [2025_01-IRI-OffbeatLabs.md](<reports/2025_01-IRI-OffbeatLabs.md>)
- Auditor: Offbeat Labs
- Date: 2025-01-24
- Description: Offbeat Security review for Optimism Labs of the incident-response changes to the dispute game and portal contracts (OptimismPortal2, AnchorStateRegistry, FaultDisputeGame, DelayedWETH, OPContractsManager and libraries) at monorepo commits 984bae9 and ce2ce43, covering anchor state handling, game validation and bond distribution. One Low and three Informational findings; L-01 and I-01 fixes in PRs #14144 and #14139 were verified.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ce2ce43b35baa693de75750fc38261aed0ad0b5f"><code>ce2ce43b35baa693de75750fc38261aed0ad0b5f</code></a> | January 14, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/Errors.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/984bae9146398a2997ec13757bfe2438ca8f92eb"><code>984bae9146398a2997ec13757bfe2438ca8f92eb</code></a> | January 15, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortalInterop.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/dispute/DelayedWETH.sol</code><br><code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/Errors.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/Types.sol</code><br><code>packages/contracts-bedrock/src/libraries/PortalErrors.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/e2de1464de42e28cb1f7405e3947bed091a0393e"><code>e2de1464de42e28cb1f7405e3947bed091a0393e</code></a> | February 18, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortalInterop.sol</code><br><code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/f63d0c028d37939c999efeccb9b9377cdbdc3040"><code>f63d0c028d37939c999efeccb9b9377cdbdc3040</code></a> | February 19, 2025 | <code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code> |

## MT64Cannon Security Review (Coinbase Protocol Security)

- Report: [2025_01-MT-Cannon-Base.md](<reports/2025_01-MT-Cannon-Base.md>)
- Auditor: Base
- Date: 2025-02-06
- Description: Coinbase Protocol Security (Base) review of the six MT64Cannon Solidity contracts (MIPS64 and its libraries) at a fixed optimism monorepo commit. One Medium finding (incorrect SLL/SLLV implementation) fixed in pull request 14114 and verified; no Critical or High findings.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/b8c011f18c79d735e01168345fc1c6f02fac584f"><code>b8c011f18c79d735e01168345fc1c6f02fac584f</code></a> | January 22, 2025 | <code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Memory.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64State.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Instructions.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Arch.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ac8f53cc4a6d641d6f71879c325f705bd1257a41"><code>ac8f53cc4a6d641d6f71879c325f705bd1257a41</code></a> | February 3, 2025 | <code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Instructions.sol</code> |

## Optimism Mt Cannon Security Review (Spearbit)

- Report: [2025_01-MT-Cannon-Spearbit.md](<reports/2025_01-MT-Cannon-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-02-20
- Description: Spearbit review of the 64-bit multithreaded Cannon fault-proof VM (MIPS64 Solidity contracts and the Go mipsevm implementation) at a fixed monorepo commit. One High finding (futex value width) in MIPS64.sol, fixed in pull request 13453; a Medium SLL/SLLV finding is carried over from the parallel Base review.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/cc2715c3d6ebef374451b598f48980ad817e0a0e"><code>cc2715c3d6ebef374451b598f48980ad817e0a0e</code></a> | November 21, 2024 | <code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Instructions.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Memory.sol</code><br><code>cannon/mipsevm</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimism/commit/0318a972fee3b0b2fe7ace999a1da6c8ff2d0126"><code>0318a972fee3b0b2fe7ace999a1da6c8ff2d0126</code></a> | December 16, 2024 | <code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Instructions.sol</code><br><code>cannon/mipsevm</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimism/commit/89f623e3d9b9c9591d21750707de89d97288140b"><code>89f623e3d9b9c9591d21750707de89d97288140b</code></a> | December 18, 2024 | <code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>cannon/mipsevm</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimism/commit/5b2de446c701ac1cba436c5e1cbaf3188a0a5782"><code>5b2de446c701ac1cba436c5e1cbaf3188a0a5782</code></a> | January 22, 2025 | <code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code><br><code>cannon/mipsevm</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ac8f53cc4a6d641d6f71879c325f705bd1257a41"><code>ac8f53cc4a6d641d6f71879c325f705bd1257a41</code></a> | February 3, 2025 | <code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Instructions.sol</code><br><code>cannon/mipsevm</code> (recursive directory) |
| <a href="https://github.com/ethereum-optimism/optimism/commit/8ffd448c0eed23fe3ab7c973703a1c8731b936b5"><code>8ffd448c0eed23fe3ab7c973703a1c8731b936b5</code></a> | February 6, 2025 | <code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Instructions.sol</code><br><code>cannon/mipsevm</code> (recursive directory) |

### Repository: <a href="https://github.com/cantina-forks/optimism"><code>cantina-forks/optimism</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Optimism Security Review (Cantina, EIP-7702 / Pectra impact)

- Report: [2025_02-EIP7702-Cantina.md](<reports/2025_02-EIP7702-Cantina.md>)
- Auditor: Cantina
- Date: 2025-03-09
- Description: Cantina Managed review (Feb 27 to Mar 1, 2025) of how the Pectra upgrade (EIP-7702 delegated EOAs and EIP-7623 calldata repricing) affects the Optimism L1/L2 messaging, bridge and EOA-check contracts at a single optimism commit. No Critical or High findings; 1 Medium, 1 Low and 2 Informational issues, with fixes in PR 14608 verified.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/8d0dd96e494b2ba154587877351e87788336a4ec"><code>8d0dd96e494b2ba154587877351e87788336a4ec</code></a> | February 25, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L2/L2StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/libraries/EOA.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/88419adbf689336913a3db7d4c3691b2b0102e75"><code>88419adbf689336913a3db7d4c3691b2b0102e75</code></a> | March 5, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/libraries/EOA.sol</code> |

## Optimism Security Review (Spearbit, Upgrade 13)

- Report: [2025_02-Upgrade13-Spearbit.md](<reports/2025_02-Upgrade13-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-03-05
- Description: Spearbit review (Jan 21 to Feb 21, 2025) of the Optimism Upgrade 13 L1 contracts at a single optimism commit, covering the OPContractsManager upgrade/addGameType flows, AnchorStateRegistry, FaultDisputeGame, OptimismPortal2 and SystemConfig changes. No Critical or High findings; 2 Medium, 6 Low and 11 Informational issues with fix PRs verified.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7d6d15437b7580b022f4c8c1ea9c0cd8d2e587e1"><code>7d6d15437b7580b022f4c8c1ea9c0cd8d2e587e1</code></a> | January 28, 2025 | <code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L1/ProtocolVersions.sol</code><br><code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/dispute/DelayedWETH.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/5f045184d636cf7842c930d75abcfe5c36639f4b"><code>5f045184d636cf7842c930d75abcfe5c36639f4b</code></a> | February 13, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/6d22e0894b72eeb2e4ea0eb1c88a76ca46b2aac9"><code>6d22e0894b72eeb2e4ea0eb1c88a76ca46b2aac9</code></a> | February 13, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/5deaa70bb2404c7cba8b1e2ac746e9a0f1a58a2e"><code>5deaa70bb2404c7cba8b1e2ac746e9a0f1a58a2e</code></a> | February 15, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/e2de1464de42e28cb1f7405e3947bed091a0393e"><code>e2de1464de42e28cb1f7405e3947bed091a0393e</code></a> | February 18, 2025 | <code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/f63d0c028d37939c999efeccb9b9377cdbdc3040"><code>f63d0c028d37939c999efeccb9b9377cdbdc3040</code></a> | February 19, 2025 | <code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/6f75551f86834f4b4e95a47b1c7e50d2c4aef059"><code>6f75551f86834f4b4e95a47b1c7e50d2c4aef059</code></a> | February 19, 2025 | <code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/29ae1d993d49880a70d16da1ca6aa88e642f7ade"><code>29ae1d993d49880a70d16da1ca6aa88e642f7ade</code></a> | February 19, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |

## Optimism Interop Security Review (Spearbit)

- Report: [2025_03-Interop-Contracts-Spearbit.md](<reports/2025_03-Interop-Contracts-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-03-19
- Description: Spearbit review of the Optimism Interop L1 and L2 contracts (SharedLockbox, OptimismPortalInterop, SuperchainConfigInterop, CrossL2Inbox, L2ToL2CrossDomainMessenger, SuperchainWETH, SuperchainTokenBridge and related predeploys) in the monorepo at commit 6c80f23a. Two High findings were acknowledged; the report declares no explicit file list.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/6c80f23ab3074b5c66ff06e390ae2448bd4d2240"><code>6c80f23ab3074b5c66ff06e390ae2448bd4d2240</code></a> | February 7, 2025 | <code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L2/SuperchainTokenBridge.sol</code><br><code>packages/contracts-bedrock/src/L2/CrossL2Inbox.sol</code><br><code>packages/contracts-bedrock/src/L2/SuperchainWETH.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortalInterop.sol</code><br><code>packages/contracts-bedrock/src/L1/SuperchainConfigInterop.sol</code><br><code>packages/contracts-bedrock/src/L2/L1BlockInterop.sol</code><br><code>packages/contracts-bedrock/src/L1/SharedLockbox.sol</code><br><code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L2/ETHLiquidity.sol</code><br><code>packages/contracts-bedrock/src/L2/L2ToL2CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L2/SuperchainERC20.sol</code> |

## Optimism Interop Proofs Security Review (Cantina)

- Report: [2025_03-Interop-OpProgram-Cantina.md](<reports/2025_03-Interop-OpProgram-Cantina.md>)
- Auditor: Cantina
- Date: 2025-05-07
- Description: Cantina Managed review (Mar 18-29, 2025) of the Optimism interop fault-proof program logic: op-program super root state transition and cross-chain message consolidation, together with the shared op-supervisor cross-safety checks and super root encoding in op-service, at commit 9d86edb5. Two Critical and two High findings; the report declares no explicit file list, so paths are those where findings locate.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/9d86edb5848ec45eadf2b39e69d38b90b3a8dda9"><code>9d86edb5848ec45eadf2b39e69d38b90b3a8dda9</code></a> | March 14, 2025 | <code>op-program/client/interop/consolidate.go</code><br><code>op-program/client/interop/interop.go</code><br><code>op-program/client/interop/types/roots.go</code><br><code>op-supervisor/supervisor/backend/cross/hazard_set.go</code><br><code>op-supervisor/supervisor/backend/cross/cycle.go</code><br><code>op-supervisor/supervisor/backend/cross/unsafe_frontier.go</code><br><code>op-service/eth/super_root.go</code><br><code>packages/contracts-bedrock/test/setup/ForkLive.s.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/172cad5ce2457eb26145d53fe5a32f32238dae2a"><code>172cad5ce2457eb26145d53fe5a32f32238dae2a</code></a> | April 1, 2025 | <code>op-supervisor/supervisor/backend/cross/hazard_set.go</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/cebf0d382aeb6c000993ae9f01940a3b60cdb993"><code>cebf0d382aeb6c000993ae9f01940a3b60cdb993</code></a> | April 11, 2025 | <code>op-program/client/interop/consolidate.go</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/725a30534dd7086ffda3cffd7a6227700d13b2dd"><code>725a30534dd7086ffda3cffd7a6227700d13b2dd</code></a> | April 17, 2025 | <code>op-program/client/interop/consolidate.go</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/5a1a65639668dfa0e88a1c848d4ce76f4c207958"><code>5a1a65639668dfa0e88a1c848d4ce76f4c207958</code></a> | April 24, 2025 | <code>op-program/client/interop/consolidate.go</code><br><code>op-supervisor/supervisor/backend/cross/hazard_set.go</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/faac706ebc7a5992c8d8f72ec864c304a5a7bf48"><code>faac706ebc7a5992c8d8f72ec864c304a5a7bf48</code></a> | April 28, 2025 | <code>op-supervisor/supervisor/backend/cross/hazard_set.go</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/96575332623b5b5e282248607021b22355112ea1"><code>96575332623b5b5e282248607021b22355112ea1</code></a> | April 28, 2025 | <code>op-supervisor/supervisor/backend/cross/cycle.go</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/748d4392386b0efcc00645a20b61012752a0b541"><code>748d4392386b0efcc00645a20b61012752a0b541</code></a> | May 2, 2025 | <code>packages/contracts-bedrock/test/setup/ForkLive.s.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7c67713745f11cfd6a55962585d879c190db8511"><code>7c67713745f11cfd6a55962585d879c190db8511</code></a> | May 6, 2025 | <code>op-program/client/interop/types/roots.go</code><br><code>op-service/eth/super_root.go</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/6707100b11d57a460408e3cef675fc7c5fc5008e"><code>6707100b11d57a460408e3cef675fc7c5fc5008e</code></a> | May 6, 2025 | <code>op-program/client/interop/consolidate.go</code> |

## ETHLockbox redesign - Unified report (Wonderland)

- Report: [2025_03-Interop-Portal-Wonderland.md](<reports/2025_03-Interop-Portal-Wonderland.md>)
- Auditor: Wonderland
- Description: Wonderland review of the ETHLockbox redesign for interop (ETHLockbox, OptimismPortal2 migration to super roots and lockbox liquidity migration) in the defi-wonderland/optimism fork at commit 9df1fc15. Only Low and Informational findings; the report declares no explicit file list.

### Repository: <a href="https://github.com/defi-wonderland/optimism"><code>defi-wonderland/optimism</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/defi-wonderland/optimism/commit/9df1fc15d0bf0dc9464db249ce06424607d5f399"><code>9df1fc15d0bf0dc9464db249ce06424607d5f399</code></a> | March 12, 2025 | <code>packages/contracts-bedrock/src/L1/ETHLockbox.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/universal/SafeSend.sol</code> |

## Interop portal - Competition

- Report: [2025_04-Interop-Portal-Cantina.md](<reports/2025_04-Interop-Portal-Cantina.md>)
- Auditor: Cantina
- Date: 2025-06-04
- Description: Cantina competition (Mar 24 - Apr 7, 2025) on the OP Stack interop portal changes in ethereum-optimism/optimism: OptimismPortal2 Super Roots proving, ETHLockbox, AnchorStateRegistry, OPContractsManager and related L1 contracts, with fixes reviewed by lead researcher Phaze. 26 findings (7 Low, 19 Informational), no Critical/High.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/e4b921c9dbf8cd3a8db20ef4f15e0e2aa495fcc3"><code>e4b921c9dbf8cd3a8db20ef4f15e0e2aa495fcc3</code></a> | March 19, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/L1/ETHLockbox.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/safe/DeputyGuardianModule.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/libraries/Hashing.sol</code><br><code>packages/contracts-bedrock/src/libraries/Encoding.sol</code><br><code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperFaultDisputeGame.sol</code> (explicitly not audited)<br><code>packages/contracts-bedrock/src/dispute/SuperPermissionedDisputeGame.sol</code> (explicitly not audited) |
| <a href="https://github.com/ethereum-optimism/optimism/commit/b671b67f75f6fe2041672d91bd3a6a777cd6a367"><code>b671b67f75f6fe2041672d91bd3a6a777cd6a367</code></a> | April 30, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/L1/ETHLockbox.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/e0c47fa78d77094f053c1747a8ed315eaabbe057"><code>e0c47fa78d77094f053c1747a8ed315eaabbe057</code></a> | May 2, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code> |

## Optimism Blob Bug Fix Review (Aleph_v)

- Report: [2025_04-op-program-blob-handling-aleph_v.md](<reports/2025_04-op-program-blob-handling-aleph_v.md>)
- Auditor: Aleph_v
- Description: Targeted four-day review of the fix for the fault-proof blob-handling bug (incorrect use of roots of unity in KZG point evaluation), covering the blob commitment mathematics, the op-program/challenger Go changes and the PreimageOracle.sol blob handling. Reviewed on a PR in a temporary private repository responding to GitHub advisory GHSA-r3crh2xh-wh4qs; no findings.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Cannon U16 Security Review (Coinbase Protocol Security)

- Report: [2025_05-Cannon-Go-Updates-Coinbase.md](<reports/2025_05-Cannon-Go-Updates-Coinbase.md>)
- Auditor: Coinbase
- Date: 2025-05-30
- Description: Coinbase Protocol Security review (May 27-30, 2025) of the Cannon state version 7 changes to the onchain MIPS64 contracts: no-op mprotect and eventfd2 syscalls and the dclz/dclo opcodes, with no issues found. The report names no repository, commit, pull request or file, so no source coverage can be pinned.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Optimism Security Review

- Report: [2025_05-Interop-Portal-Spearbit.md](<reports/2025_05-Interop-Portal-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-05-20
- Description: Spearbit five-day review of the Optimism monorepo contracts-bedrock changes for the interop-ready OptimismPortal2 / Upgrade 16 (SuperchainConfig pause model, ETHLockbox migration, ReinitializableBase upgrades, OPContractsManager) at commit 7cd84fed, followed by a fix review of PR 15939. Five Low, one Gas and eight Informational findings and no Critical, High or Medium issues; the report declares no explicit file list.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7cd84fed9554193c2dcd683e1ff2d0e2605448f6"><code>7cd84fed9554193c2dcd683e1ff2d0e2605448f6</code></a> | May 6, 2025 | <code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/libraries/Encoding.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code><br><code>packages/contracts-bedrock/src/L1/ProxyAdminOwnedBase.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/L1/L1ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/1891f660ee179b14fd09341a9554f59a120e625a"><code>1891f660ee179b14fd09341a9554f59a120e625a</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7134b4c0d4dac073c4756458d008d34dc362dba2"><code>7134b4c0d4dac073c4756458d008d34dc362dba2</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/libraries/Encoding.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/3f77c1baf151091fb69aa672fc8543a2aeda261b"><code>3f77c1baf151091fb69aa672fc8543a2aeda261b</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/33695ee6adbbb29f8b49ae09af40c1aaf9989a6c"><code>33695ee6adbbb29f8b49ae09af40c1aaf9989a6c</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/c63713014bd22cd917557cf00515d7cc96d0c375"><code>c63713014bd22cd917557cf00515d7cc96d0c375</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/ProxyAdminOwnedBase.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/c7c974d1a208e7c1bf7e499bdb9530fe2954e40c"><code>c7c974d1a208e7c1bf7e499bdb9530fe2954e40c</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/3ad1915e5c0972632295b70ef63bab6c729392f9"><code>3ad1915e5c0972632295b70ef63bab6c729392f9</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/62dcc8a89693bccbd13e21b03de1595da7908f76"><code>62dcc8a89693bccbd13e21b03de1595da7908f76</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/4fc9181a73795334f0c657a79ea8177b8de1814c"><code>4fc9181a73795334f0c657a79ea8177b8de1814c</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code><br><code>packages/contracts-bedrock/src/L1/ProxyAdminOwnedBase.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code> |

## Optimism Security Review - Upgrade 16 (Spearbit)

- Report: [2025_05-Upgrade16-Spearbit.md](<reports/2025_05-Upgrade16-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-05-20
- Description: Spearbit review (May 5-12, 2025) of the OP Stack L1 contracts changed for Upgrade 16 in the ethereum-optimism monorepo: ETHLockbox, OptimismPortal2, SuperchainConfig, SystemConfig, bridges, OPContractsManager U16 changes, MIPS64, dispute contracts, Encoding/Hashing and DeputyPauseModule. Five Low findings and no Critical/High/Medium; fixes verified in PR #15939 commits.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7cd84fed9554193c2dcd683e1ff2d0e2605448f6"><code>7cd84fed9554193c2dcd683e1ff2d0e2605448f6</code></a> | May 6, 2025 | <code>packages/contracts-bedrock/src/L1/ETHLockbox.sol</code><br><code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/L1ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/ProtocolVersions.sol</code><br><code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/dispute/DelayedWETH.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperFaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperPermissionedDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/libraries/Encoding.sol</code><br><code>packages/contracts-bedrock/src/libraries/Hashing.sol</code><br><code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/62dcc8a89693bccbd13e21b03de1595da7908f76"><code>62dcc8a89693bccbd13e21b03de1595da7908f76</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/3f77c1baf151091fb69aa672fc8543a2aeda261b"><code>3f77c1baf151091fb69aa672fc8543a2aeda261b</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/33695ee6adbbb29f8b49ae09af40c1aaf9989a6c"><code>33695ee6adbbb29f8b49ae09af40c1aaf9989a6c</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/1891f660ee179b14fd09341a9554f59a120e625a"><code>1891f660ee179b14fd09341a9554f59a120e625a</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/4fc9181a73795334f0c657a79ea8177b8de1814c"><code>4fc9181a73795334f0c657a79ea8177b8de1814c</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code><br><code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/c7c974d1a208e7c1bf7e499bdb9530fe2954e40c"><code>c7c974d1a208e7c1bf7e499bdb9530fe2954e40c</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7134b4c0d4dac073c4756458d008d34dc362dba2"><code>7134b4c0d4dac073c4756458d008d34dc362dba2</code></a> | May 14, 2025 | <code>packages/contracts-bedrock/src/libraries/Encoding.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/54c19f6acb7a6d3505f884bae601733d3d54a3a6"><code>54c19f6acb7a6d3505f884bae601733d3d54a3a6</code></a> | June 11, 2025 | <code>packages/contracts-bedrock/src/L1/ETHLockbox.sol</code><br><code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/L1ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/ProtocolVersions.sol</code><br><code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/dispute/DelayedWETH.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperFaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperPermissionedDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/libraries/Encoding.sol</code><br><code>packages/contracts-bedrock/src/libraries/Hashing.sol</code><br><code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code> |

## OP Cannon Security Review (3DOC / Radiant Labs)

- Report: [2025_06-Cannon-3DOC.md](<reports/2025_06-Cannon-3DOC.md>)
- Auditor: 3DOC Security
- Date: 2025-06-06
- Description: Radiant Labs (3DOC) manual review for OP Labs of the Cannon Go 1.24 support changes in PR #15737, primarily the new getrandom syscall in the Go MIPS64 VM (cannon/mipsevm) and the onchain MIPS64.sol verifier. One Medium (LL/SC reservation not cleared, fixed in d89e0ce), one Low and one Informational finding; no High findings.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/689111fca9a10e6670ba0b5c7f1a549a212c855b"><code>689111fca9a10e6670ba0b5c7f1a549a212c855b</code></a> | May 29, 2025 | <code>cannon/mipsevm/arch/arch64.go</code><br><code>cannon/mipsevm/iface.go</code><br><code>cannon/mipsevm/versions/state.go</code><br><code>cannon/mipsevm/versions/version.go</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64State.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code><br><code>cannon/mipsevm/multithreaded/mips.go</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/d89e0ce3a345acb5b98762ee1ca44d2f8e67e2a1"><code>d89e0ce3a345acb5b98762ee1ca44d2f8e67e2a1</code></a> | June 24, 2025 | <code>cannon/mipsevm/multithreaded/mips.go</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code> |

## Optimism - Fix Review: MIPS EventFd and Syscall Error Handling (Spearbit/Cantina)

- Report: [2025_06-Spearbit-Cannon-fix-review.md](<reports/2025_06-Spearbit-Cannon-fix-review.md>)
- Auditor: Cantina
- Date: 2025-06-21
- Description: Solo Spearbit/Cantina fix review (Zigtur) of three OP Labs pull requests (#16341, #16346, #16384) on commit 7f7b9abb that add eventfd2 syscall support and correct the V0/A3 register convention for syscall errors in the Cannon Go MIPS64 VM and the onchain MIPS64 contracts, needed for the Go 1.23 runtime. Both fixes were confirmed accurate; no new findings were reported.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/4fc20663a2009f72814716f8a107bc2c39399b51"><code>4fc20663a2009f72814716f8a107bc2c39399b51</code></a> | June 10, 2025 | <code>cannon/mipsevm/exec/mips_syscalls.go</code><br><code>cannon/mipsevm/multithreaded/mips.go</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/085262837d057c3fcedc2683228879075321bf2d"><code>085262837d057c3fcedc2683228879075321bf2d</code></a> | June 10, 2025 | <code>cannon/mipsevm/exec/mips_syscalls.go</code><br><code>cannon/mipsevm/iface.go</code><br><code>cannon/mipsevm/multithreaded/mips.go</code><br><code>cannon/mipsevm/versions/state.go</code><br><code>packages/contracts-bedrock/src/L1/StandardValidator.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64State.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7f7b9abb623de253d6d4dd03fa5ddae3a6afa497"><code>7f7b9abb623de253d6d4dd03fa5ddae3a6afa497</code></a> | June 11, 2025 | <code>cannon/mipsevm/exec/mips_syscalls.go</code><br><code>cannon/mipsevm/iface.go</code><br><code>cannon/mipsevm/multithreaded/mips.go</code><br><code>cannon/mipsevm/versions/state.go</code><br><code>packages/contracts-bedrock/src/L1/StandardValidator.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64State.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/a8aefb66bdc9ba4792eca001491fe70005f68b46"><code>a8aefb66bdc9ba4792eca001491fe70005f68b46</code></a> | June 11, 2025 | <code>cannon/mipsevm/exec/mips_syscalls.go</code><br><code>cannon/mipsevm/multithreaded/mips.go</code><br><code>packages/contracts-bedrock/src/L1/StandardValidator.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code> |

## Optimism Upgrade 16 Security Review

- Report: [2025_07-VerifyOPCM-Spearbit.md](<reports/2025_07-VerifyOPCM-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-07-16
- Description: Spearbit four-day review of the VerifyOPCM.s.sol Foundry script at commit 731280c6 and of whether it correctly verifies the OPContractsManager.sol contract at commit 54c19f6a for Upgrade 16. One Medium, one Low and one Informational finding, all acknowledged; no Critical or High issues and no fix review.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/731280c6fc0ad184d252e0fb1d0ad12b5f59fd60"><code>731280c6fc0ad184d252e0fb1d0ad12b5f59fd60</code></a> | May 22, 2025 | <code>packages/contracts-bedrock/scripts/deploy/VerifyOPCM.s.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/54c19f6acb7a6d3505f884bae601733d3d54a3a6"><code>54c19f6acb7a6d3505f884bae601733d3d54a3a6</code></a> | June 11, 2025 | <code>packages/contracts-bedrock/scripts/deploy/VerifyOPCM.s.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |

## Optimism Governor Audit

- Report: [2025_08-Governor-OpenZeppelin.md](<reports/2025_08-Governor-OpenZeppelin.md>)
- Auditor: OpenZeppelin
- Date: 2025-08-04
- Description: OpenZeppelin reviewed the voteagora/optimism-governor repository at commit d585692: the authorized-proposer changes to OptimismGovernor.sol introduced in pull request #44, the entire RedeployTimelock.s.sol timelock redeployment script, and the Sepolia proposal calldata calling updateTimelock. The audit (2025-07-16 to 2025-07-18) found no Critical/High/Medium issues, only 8 Low and 4 Notes, all resolved in follow-up pull requests #47-#56.

### Repository: <a href="https://github.com/voteagora/optimism-governor"><code>voteagora/optimism-governor</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/voteagora/optimism-governor/commit/d585692582e907a69ecc066cc4196ea16630ab13"><code>d585692582e907a69ecc066cc4196ea16630ab13</code></a> | July 16, 2025 | <code>src/OptimismGovernor.sol</code><br><code>script/RedeployTimelock.s.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/ef27aaf4cf52f8666612c5f0e09274425e585dd9"><code>ef27aaf4cf52f8666612c5f0e09274425e585dd9</code></a> | July 23, 2025 | <code>src/OptimismGovernor.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/ce323b50d73cce4fcf5c4c0d73dff073b02cfecc"><code>ce323b50d73cce4fcf5c4c0d73dff073b02cfecc</code></a> | July 23, 2025 | <code>script/RedeployTimelock.s.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/01d61708e3125dba01860c8b9a02ba396b426d6f"><code>01d61708e3125dba01860c8b9a02ba396b426d6f</code></a> | July 24, 2025 | <code>src/OptimismGovernor.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/68d60ba4ed8b94f100a3943de94630d3a886c186"><code>68d60ba4ed8b94f100a3943de94630d3a886c186</code></a> | July 24, 2025 | <code>src/OptimismGovernor.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/600c183e2bdc2563de2bd00e64b6dabe232d57a5"><code>600c183e2bdc2563de2bd00e64b6dabe232d57a5</code></a> | July 24, 2025 | <code>script/RedeployTimelock.s.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/c40620ffa47d0d4097bbc4344b05d669e4bf8d22"><code>c40620ffa47d0d4097bbc4344b05d669e4bf8d22</code></a> | July 25, 2025 | <code>src/OptimismGovernor.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/072970aad9ac0f36247213b7540104caa62f2dd4"><code>072970aad9ac0f36247213b7540104caa62f2dd4</code></a> | July 28, 2025 | <code>src/OptimismGovernor.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/e35f3c7b5aa6fd26cb0bcf9650df6a097c9cfaf6"><code>e35f3c7b5aa6fd26cb0bcf9650df6a097c9cfaf6</code></a> | July 28, 2025 | <code>script/RedeployTimelock.s.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/20e632d365b69548e7a6d32cdb3f9463bb7067c3"><code>20e632d365b69548e7a6d32cdb3f9463bb7067c3</code></a> | July 28, 2025 | <code>script/RedeployTimelock.s.sol</code> |
| <a href="https://github.com/voteagora/optimism-governor/commit/7d23fbc18329ca6096e334f62ca24912775a725a"><code>7d23fbc18329ca6096e334f62ca24912775a725a</code></a> | July 29, 2025 | <code>src/OptimismGovernor.sol</code> |

## Optimism u16 Security Review - U16a (Spearbit)

- Report: [2025_09-U16a-Spearbit.md](<reports/2025_09-U16a-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-10-07
- Description: Spearbit 2-day review (Sep 9-11, 2025) of the Optimism U16a upgrade in the ethereum-optimism monorepo, covering OPContractsManager, OptimismPortal2, SystemConfig, the L1 bridges/messenger and the MIPS64 contracts. Three Low and seven Informational findings, no Critical/High/Medium; two fixes verified via PRs #17406 and #17482.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/475801690f7a451469ee4da87b5fe3c54c92f372"><code>475801690f7a451469ee4da87b5fe3c54c92f372</code></a> | September 8, 2025 | <code>packages/contracts-bedrock/src/cannon/libraries/MIPS64State.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Syscalls.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/L1ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/0326b2b4f847656d2a9a5ad5dd2598d410b18d26"><code>0326b2b4f847656d2a9a5ad5dd2598d410b18d26</code></a> | September 12, 2025 | <code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/6c20aa2b26f3d915c02cbcd49ff98523b69dd9dc"><code>6c20aa2b26f3d915c02cbcd49ff98523b69dd9dc</code></a> | September 16, 2025 | <code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code> |

## Wonderland - Optimism Fee Splitter Security Review (Cantina Managed)

- Report: [2025_10-Rev-Sharing-Spearbit.md](<reports/2025_10-Rev-Sharing-Spearbit.md>)
- Auditor: Cantina
- Date: 2025-11-04
- Description: Cantina Managed review (Oct 15-19, 2025) of the Optimism revenue-sharing / FeeSplitter feature developed by Wonderland in the optimism monorepo at commit 989afa81, covering the FeeSplitter, FeeVault, L1Withdrawer, SuperchainRevSharesCalculator and FeesDepositor contracts, their interfaces, genesis scripts and op-deployer tooling. No Critical, High or Medium issues were found; fixes were verified holistically at commit f1fcd964.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/989afa818dfee3ee1fba715584c2f7e8663268f8"><code>989afa818dfee3ee1fba715584c2f7e8663268f8</code></a> | October 13, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/src/L2/FeeVault.sol</code><br><code>packages/contracts-bedrock/src/L1/FeesDepositor.sol</code><br><code>packages/contracts-bedrock/src/L2/L1Withdrawer.sol</code><br><code>packages/contracts-bedrock/src/L2/SuperchainRevSharesCalculator.sol</code><br><code>packages/contracts-bedrock/scripts/L2Genesis.s.sol</code><br><code>packages/contracts-bedrock/scripts/Artifacts.s.sol</code><br><code>packages/contracts-bedrock/interfaces/L1/IFeesDepositor.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IFeeSplitter.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IFeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IBaseFeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IL1FeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IOperatorFeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/ISequencerFeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/ISharesCalculator.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/ISuperchainRevSharesCalculator.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ea0f449f7cdae83468bdca8f4c348ad1e0a04aa3"><code>ea0f449f7cdae83468bdca8f4c348ad1e0a04aa3</code></a> | October 22, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IFeeSplitter.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/96951ff0fc19d99148c7202938a2e1138725293e"><code>96951ff0fc19d99148c7202938a2e1138725293e</code></a> | October 22, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/ISharesCalculator.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/c407533a640d6d0e8d2e2ce60e9126e347b73888"><code>c407533a640d6d0e8d2e2ce60e9126e347b73888</code></a> | October 22, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IFeeSplitter.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/fb22bccdc52734937ac45f1a57caf4cba9d26b5c"><code>fb22bccdc52734937ac45f1a57caf4cba9d26b5c</code></a> | October 28, 2025 | <code>packages/contracts-bedrock/scripts/L2Genesis.s.sol</code><br><code>packages/contracts-bedrock/scripts/Artifacts.s.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/fa7f97c88271d0fd3c9a6df725e36a55ea43c0d0"><code>fa7f97c88271d0fd3c9a6df725e36a55ea43c0d0</code></a> | October 29, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/68b32e134eaa2ce2bb312b70604ac4147f57d2b6"><code>68b32e134eaa2ce2bb312b70604ac4147f57d2b6</code></a> | October 29, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/src/L2/FeeVault.sol</code><br><code>packages/contracts-bedrock/src/L2/SuperchainRevSharesCalculator.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/9ba262294941bae165c150f00e3b923cfe90a928"><code>9ba262294941bae165c150f00e3b923cfe90a928</code></a> | October 29, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/src/L2/FeeVault.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/14a2c14c86076192db076350642d35fa1dad665f"><code>14a2c14c86076192db076350642d35fa1dad665f</code></a> | October 29, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/scripts/L2Genesis.s.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IFeeSplitter.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/f1fcd96406d895f37c2d1a422d50ea7dbd03a491"><code>f1fcd96406d895f37c2d1a422d50ea7dbd03a491</code></a> | October 29, 2025 | <code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/src/L2/FeeVault.sol</code><br><code>packages/contracts-bedrock/src/L1/FeesDepositor.sol</code><br><code>packages/contracts-bedrock/src/L2/L1Withdrawer.sol</code><br><code>packages/contracts-bedrock/src/L2/SuperchainRevSharesCalculator.sol</code><br><code>packages/contracts-bedrock/scripts/L2Genesis.s.sol</code><br><code>packages/contracts-bedrock/scripts/Artifacts.s.sol</code><br><code>packages/contracts-bedrock/interfaces/L1/IFeesDepositor.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IFeeSplitter.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IFeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IBaseFeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IL1FeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/IOperatorFeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/ISequencerFeeVault.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/ISharesCalculator.sol</code><br><code>packages/contracts-bedrock/interfaces/L2/ISuperchainRevSharesCalculator.sol</code> |

## Optimism u17 Security Review

- Report: [2025_10-U17-Spearbit.md](<reports/2025_10-U17-Spearbit.md>)
- Auditor: Cantina
- Date: 2025-10-27
- Description: Cantina Managed review (2025-10-15 to 2025-10-21) of the ethereum-optimism/optimism u17 (op-contracts v5.0.0) contracts-bedrock release at commit aeed7033, covering 20 L1, L2, cannon MIPS64, dispute and universal contracts listed in the appendix, plus pull request 17998. The review found 3 Informational issues (all acknowledged) and no Critical/High/Medium/Low findings.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/aeed7033f7f739d8ecd4bd70a42ff09013bbc91e"><code>aeed7033f7f739d8ecd4bd70a42ff09013bbc91e</code></a> | October 16, 2025 | <code>packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L1/L1ERC721Bridge.sol</code><br><code>packages/contracts-bedrock/src/L1/L1StandardBridge.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L2/GasPriceOracle.sol</code><br><code>packages/contracts-bedrock/src/L2/L1Block.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64Instructions.sol</code><br><code>packages/contracts-bedrock/src/cannon/libraries/MIPS64State.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code><br><code>packages/contracts-bedrock/src/dispute/FaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/PermissionedDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/Types.sol</code><br><code>packages/contracts-bedrock/src/libraries/DevFeatures.sol</code><br><code>packages/contracts-bedrock/src/libraries/Encoding.sol</code><br><code>packages/contracts-bedrock/src/universal/OptimismMintableERC20.sol</code><br><code>packages/contracts-bedrock/src/universal/OptimismMintableERC20Factory.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/f6e2e482ec71b98b46ab2d97bc733eaef5e41215"><code>f6e2e482ec71b98b46ab2d97bc733eaef5e41215</code></a> | October 23, 2025 | <code>packages/contracts-bedrock/src/L2/GasPriceOracle.sol</code> |

## Optimism: Custom Gas Token Security Review (Cantina Managed)

- Report: [2025_11-Custom-Gas-Token-Spearbit.md](<reports/2025_11-Custom-Gas-Token-Spearbit.md>)
- Auditor: Cantina
- Date: 2025-11-18
- Description: Cantina Managed review of the Custom Gas Token (CGT) feature in the optimism monorepo at commit 1f888ede, covering the L1 OPContractsManager/OptimismPortal2/SystemConfig changes, the new L2 CGT predeploys (L1BlockCGT, L2ToL1MessagePasserCGT, LiquidityController, NativeAssetLiquidity) and the related deploy/genesis scripts. No Critical, High or Medium issues were found; fixes verified by Cantina concern out-of-scope Go tooling and the specs repository.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/1f888ede1940fce20f71db89fc13039fdd96757e"><code>1f888ede1940fce20f71db89fc13039fdd96757e</code></a> | October 30, 2025 | <code>packages/contracts-bedrock/scripts/deploy/DeployConfig.s.sol</code><br><code>packages/contracts-bedrock/scripts/deploy/DeployOPChain.s.sol</code><br><code>packages/contracts-bedrock/scripts/L2Genesis.s.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L2/L1BlockCGT.sol</code><br><code>packages/contracts-bedrock/src/L2/L2ToL1MessagePasserCGT.sol</code><br><code>packages/contracts-bedrock/src/L2/LiquidityController.sol</code><br><code>packages/contracts-bedrock/src/L2/NativeAssetLiquidity.sol</code> |

## Optimism SaferSafes Security Review (Spearbit)

- Report: [2025_11-SaferSafes-Spearbit.md](<reports/2025_11-SaferSafes-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-11-13
- Description: Spearbit review of the SaferSafes Safe extensions in the optimism monorepo at commit cb54822c: LivenessModule2.sol, TimelockGuard.sol and SaferSafes.sol under packages/contracts-bedrock/src/safe. No Critical or High issues; one Medium and two Low findings, with fixes landed in PRs 18147 and 18172 and verified by Spearbit.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/cb54822c5e18925498f48d8677b71992bf402631"><code>cb54822c5e18925498f48d8677b71992bf402631</code></a> | October 24, 2025 | <code>packages/contracts-bedrock/src/safe/LivenessModule2.sol</code><br><code>packages/contracts-bedrock/src/safe/TimelockGuard.sol</code><br><code>packages/contracts-bedrock/src/safe/SaferSafes.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/8f0d87c5dcf4f570d43b5defe29e0815f2673305"><code>8f0d87c5dcf4f570d43b5defe29e0815f2673305</code></a> | November 4, 2025 | <code>packages/contracts-bedrock/src/safe/LivenessModule2.sol</code><br><code>packages/contracts-bedrock/src/safe/TimelockGuard.sol</code><br><code>packages/contracts-bedrock/src/safe/SaferSafes.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ab2db708fc1d6992e35088c1c4b6df2b88508df5"><code>ab2db708fc1d6992e35088c1c4b6df2b88508df5</code></a> | November 6, 2025 | <code>packages/contracts-bedrock/src/safe/LivenessModule2.sol</code><br><code>packages/contracts-bedrock/src/safe/TimelockGuard.sol</code><br><code>packages/contracts-bedrock/src/safe/SaferSafes.sol</code> |

## Optimism PBC U18 Security Review (Cantina)

- Report: [2026_01-U18-Cantina.md](<reports/2026_01-U18-Cantina.md>)
- Auditor: Cantina
- Date: 2026-01-12
- Description: Cantina Managed review of the Optimism U18 upgrade at commit 87d406db, covering the contracts-bedrock dispute (DisputeGameFactory creator pattern, V2/Super/zk games), L1 (OPCM, portal, SystemConfig, FeesDepositor), L2 fee vault/splitter/CGT predeploys, libraries and Safe modules. No Critical, High or Medium issues were found; 4 Low, 1 Gas and 2 Informational findings, all acknowledged.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/87d406db86907833f75d5c8fb26ade3dcb85eb41"><code>87d406db86907833f75d5c8fb26ade3dcb85eb41</code></a> | November 24, 2025 | <code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/dispute/DisputeGameFactory.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/Errors.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/LibGameArgs.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/Types.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperFaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperPermissionedDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/v2/FaultDisputeGameV2.sol</code><br><code>packages/contracts-bedrock/src/dispute/v2/PermissionedDisputeGameV2.sol</code><br><code>packages/contracts-bedrock/src/dispute/zk/AccessManager.sol</code><br><code>packages/contracts-bedrock/src/dispute/zk/ISP1Verifier.sol</code><br><code>packages/contracts-bedrock/src/dispute/zk/OPSuccinctFaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/L1/FeesDepositor.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManager.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManagerStandardValidator.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L2/BaseFeeVault.sol</code><br><code>packages/contracts-bedrock/src/L2/FeeSplitter.sol</code><br><code>packages/contracts-bedrock/src/L2/FeeVault.sol</code><br><code>packages/contracts-bedrock/src/L2/L1Block.sol</code><br><code>packages/contracts-bedrock/src/L2/L1BlockCGT.sol</code><br><code>packages/contracts-bedrock/src/L2/L1FeeVault.sol</code><br><code>packages/contracts-bedrock/src/L2/L1Withdrawer.sol</code><br><code>packages/contracts-bedrock/src/L2/L2ToL1MessagePasser.sol</code><br><code>packages/contracts-bedrock/src/L2/L2ToL1MessagePasserCGT.sol</code><br><code>packages/contracts-bedrock/src/L2/LiquidityController.sol</code><br><code>packages/contracts-bedrock/src/L2/NativeAssetLiquidity.sol</code><br><code>packages/contracts-bedrock/src/L2/OperatorFeeVault.sol</code><br><code>packages/contracts-bedrock/src/L2/SequencerFeeVault.sol</code><br><code>packages/contracts-bedrock/src/L2/SuperchainRevSharesCalculator.sol</code><br><code>packages/contracts-bedrock/src/libraries/Constants.sol</code><br><code>packages/contracts-bedrock/src/libraries/DevFeatures.sol</code><br><code>packages/contracts-bedrock/src/libraries/Features.sol</code><br><code>packages/contracts-bedrock/src/libraries/Predeploys.sol</code><br><code>packages/contracts-bedrock/src/safe/DeputyPauseModule.sol</code><br><code>packages/contracts-bedrock/src/safe/LivenessGuard.sol</code><br><code>packages/contracts-bedrock/src/safe/LivenessModule.sol</code><br><code>packages/contracts-bedrock/src/safe/LivenessModule2.sol</code><br><code>packages/contracts-bedrock/src/safe/SaferSafes.sol</code><br><code>packages/contracts-bedrock/src/safe/TimelockGuard.sol</code> |

## Coinbase: Kona Security Review

- Report: [2026_03-Kona-Cantina.md](<reports/2026_03-Kona-Cantina.md>)
- Auditor: Cantina
- Date: 2026-03-28
- Description: Cantina Managed review (Jan 19 - Feb 9, 2026) of the kona Rust fault-proof program at op-rs/kona commit 86910c91, covering the derivation pipeline (kona-derive), proof crates (driver, executor, mpt, preimage, proof, proof-interop, std-fpvm) and the FPVM EVM precompiles. Found 2 Critical and 1 High issue (all fixed) plus 2 Medium, 32 Low and 18 Informational (acknowledged).

### Repository: <a href="https://github.com/op-rs/kona"><code>op-rs/kona</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/op-rs/kona/commit/86910c9112437bbb849eca28961f813c5450e103"><code>86910c9112437bbb849eca28961f813c5450e103</code></a> | December 15, 2025 | <code>bin/client/src/fpvm_evm</code> (recursive directory)<br><code>crates/proof/driver</code> (recursive directory)<br><code>crates/proof/executor</code> (recursive directory)<br><code>crates/proof/mpt</code> (recursive directory)<br><code>crates/proof/preimage</code> (recursive directory)<br><code>crates/proof/proof</code> (recursive directory)<br><code>crates/proof/proof-interop</code> (recursive directory)<br><code>crates/proof/std-fpvm</code> (recursive directory)<br><code>crates/proof/std-fpvm-proc</code> (recursive directory)<br><code>crates/protocol/derive</code> (recursive directory)<br><code>bin/client/src/single.rs</code><br><code>crates/protocol/protocol/src/batch/reader.rs</code><br><code>crates/protocol/protocol/src/brotli.rs</code> |

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/c390d771c65d783503f82fb76fb0b1d8628c605b"><code>c390d771c65d783503f82fb76fb0b1d8628c605b</code></a> | March 26, 2026 | <code>rust/kona/bin/client/src/single.rs</code><br><code>rust/kona/crates/proof/proof/src/sync.rs</code><br><code>rust/kona/crates/protocol/protocol/src/batch/reader.rs</code><br><code>rust/kona/crates/protocol/protocol/src/brotli.rs</code> |

## Optimism: PolicyEngine Staking Contract Security Review (Cantina)

- Report: [2026_03-PolicyEngineStaking-Cantina.md](<reports/2026_03-PolicyEngineStaking-Cantina.md>)
- Auditor: Cantina
- Date: 2026-03-27
- Description: Cantina Managed review of the PolicyEngineStaking contract, its interface and deployment script in contracts-bedrock at commit 60679313, followed by a holistic fix review at commit 13c74c6d. No Critical, High or Medium issues; 1 Low and 9 Informational findings, 9 fixed and 1 acknowledged.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/606793132710967158a8888d26702241f794fca1"><code>606793132710967158a8888d26702241f794fca1</code></a> | February 24, 2026 | <code>packages/contracts-bedrock/src/periphery/staking/PolicyEngineStaking.sol</code><br><code>packages/contracts-bedrock/interfaces/periphery/staking/IPolicyEngineStaking.sol</code><br><code>packages/contracts-bedrock/scripts/deploy/DeployPolicyEngineStaking.s.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/13c74c6d0855caf59b575ccf5fbf74ffe104cb4f"><code>13c74c6d0855caf59b575ccf5fbf74ffe104cb4f</code></a> | March 16, 2026 | <code>packages/contracts-bedrock/src/periphery/staking/PolicyEngineStaking.sol</code><br><code>packages/contracts-bedrock/interfaces/periphery/staking/IPolicyEngineStaking.sol</code><br><code>packages/contracts-bedrock/scripts/deploy/DeployPolicyEngineStaking.s.sol</code> |

## Optimism: Upgrade 19 Security Review (Cantina)

- Report: [2026_05-U19-Cantina.md](<reports/2026_05-U19-Cantina.md>)
- Auditor: Cantina
- Date: 2026-05-23
- Description: Cantina Managed review of the Optimism Upgrade 19 contracts-bedrock changes at commit 7cbcb58f, covering OPCMv2 / validator utilities, L2ContractsManager, FeeVault, dispute and portal contracts. No Critical or High issues; 3 Medium, 10 Low and 3 Informational findings, none reported as fixed.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7cbcb58ffb7322343f0ed6b926f65bea7630ce3e"><code>7cbcb58ffb7322343f0ed6b926f65bea7630ce3e</code></a> | May 1, 2026 | <code>packages/contracts-bedrock/src/L2/L2ContractsManager.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerUtils.sol</code><br><code>packages/contracts-bedrock/src/L2/FeeVault.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/StandardValidatorUtils.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerMigrationValidator.sol</code><br><code>packages/contracts-bedrock/src/cannon/MIPS64.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManagerStandardValidator.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerV2.sol</code><br><code>packages/contracts-bedrock/src/dispute/PermissionedDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/AnchorStateRegistry.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code> |

## Optimism L2 Interop Re-review (Cantina Managed)

- Report: [2026_06-Interop-L2-Contracts.md](<reports/2026_06-Interop-L2-Contracts.md>)
- Auditor: Cantina
- Date: 2026-06-18
- Description: Cantina Managed re-review of the OP Stack L2 interop predeploys (CrossL2Inbox, L2ToL2CrossDomainMessenger, SuperchainETHBridge, ETHLiquidity) and their supporting libraries (Hashing, TransientContext, SafeSend) at commit fa9974a2. The review found 4 Low and 25 Informational issues and no Critical, High or Medium findings; several documentation/code fixes were verified.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/fa9974a2cd38d9e7633a12f9024d52f41de55f86"><code>fa9974a2cd38d9e7633a12f9024d52f41de55f86</code></a> | May 29, 2026 | <code>packages/contracts-bedrock/src/L2/CrossL2Inbox.sol</code><br><code>packages/contracts-bedrock/src/L2/ETHLiquidity.sol</code><br><code>packages/contracts-bedrock/src/L2/L2ToL2CrossDomainMessenger.sol</code><br><code>packages/contracts-bedrock/src/L2/SuperchainETHBridge.sol</code><br><code>packages/contracts-bedrock/src/libraries/Hashing.sol</code><br><code>packages/contracts-bedrock/src/libraries/TransientContext.sol</code><br><code>packages/contracts-bedrock/src/universal/SafeSend.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/6a580e4a59272ffe4e85ad7eb7f2687253f58c73"><code>6a580e4a59272ffe4e85ad7eb7f2687253f58c73</code></a> | June 9, 2026 | <code>packages/contracts-bedrock/src/L2/ETHLiquidity.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/53d21dd996c833017824e1fdcc9da439ffe9c228"><code>53d21dd996c833017824e1fdcc9da439ffe9c228</code></a> | June 9, 2026 | <code>packages/contracts-bedrock/src/L2/L2ToL2CrossDomainMessenger.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/2c5029b3809b6b67d54b15c9f368dd29fe93122a"><code>2c5029b3809b6b67d54b15c9f368dd29fe93122a</code></a> | June 9, 2026 | <code>packages/contracts-bedrock/src/L2/L2ToL2CrossDomainMessenger.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/da3c4f4941050fa5678d137f4c2399b84ab2b7dc"><code>da3c4f4941050fa5678d137f4c2399b84ab2b7dc</code></a> | June 9, 2026 | <code>packages/contracts-bedrock/src/L2/L2ToL2CrossDomainMessenger.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/9d7f24dd7115c178652e78302d7a2bb3d6643176"><code>9d7f24dd7115c178652e78302d7a2bb3d6643176</code></a> | June 9, 2026 | <code>packages/contracts-bedrock/src/universal/SafeSend.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/3bf3026e96e8bacc154bdabcd48afc90f47a606a"><code>3bf3026e96e8bacc154bdabcd48afc90f47a606a</code></a> | June 9, 2026 | <code>packages/contracts-bedrock/src/universal/SafeSend.sol</code> |

## Optimism OPCMv2 Security Review (Cantina)

- Report: [2026_06-OPCMv2-Cantina.md](<reports/2026_06-OPCMv2-Cantina.md>)
- Auditor: Cantina
- Date: 2026-06-08
- Description: Cantina Managed review of the OPCMv2 contracts in contracts-bedrock (OPContractsManagerV2, Migrator, Utils, UtilsCaller, Container and the VerifyOPCM script) at commit a00b3972, with fix verification of PRs #19271, #19272, #19281, #19285, #20289 and #20371. No Critical or High issues; 1 Medium, 6 Low and 15 Informational findings, 21 fixed and 1 acknowledged.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/a00b39720a3f61276d2fa3991abfb672c9dd35ce"><code>a00b39720a3f61276d2fa3991abfb672c9dd35ce</code></a> | February 6, 2026 | <code>packages/contracts-bedrock/scripts/deploy/VerifyOPCM.s.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerMigrator.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerV2.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerUtils.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerUtilsCaller.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerContainer.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/8d80aac5355b80563ad2636155d593d6448f3c87"><code>8d80aac5355b80563ad2636155d593d6448f3c87</code></a> | February 22, 2026 | <code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerMigrator.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerV2.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/8083ebcb4c149e094841ae1369285158ebc643c2"><code>8083ebcb4c149e094841ae1369285158ebc643c2</code></a> | February 23, 2026 | <code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerMigrator.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/5161204097d10ff8888d4e793506b0db818c7517"><code>5161204097d10ff8888d4e793506b0db818c7517</code></a> | March 3, 2026 | <code>packages/contracts-bedrock/scripts/deploy/VerifyOPCM.s.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/f68cd8e3ca7e59b0bd0d267fcafdcd7b13cf7ec6"><code>f68cd8e3ca7e59b0bd0d267fcafdcd7b13cf7ec6</code></a> | March 5, 2026 | <code>packages/contracts-bedrock/scripts/deploy/VerifyOPCM.s.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerV2.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerUtils.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/56ee47e5f515425dfcb9e42c4f08b7b4d15e1469"><code>56ee47e5f515425dfcb9e42c4f08b7b4d15e1469</code></a> | March 5, 2026 | <code>packages/contracts-bedrock/scripts/deploy/VerifyOPCM.s.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerMigrator.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/b78ae8c48bbd721c9c28d6c97ad25346a5aa3bf0"><code>b78ae8c48bbd721c9c28d6c97ad25346a5aa3bf0</code></a> | March 5, 2026 | <code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerMigrator.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerV2.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/992bc6b06465107bee15c1e2df27836d0f2e4651"><code>992bc6b06465107bee15c1e2df27836d0f2e4651</code></a> | April 23, 2026 | <code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerUtils.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/5c28b3d432b1491267534c211286ce3483cea445"><code>5c28b3d432b1491267534c211286ce3483cea445</code></a> | April 27, 2026 | <code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerUtils.sol</code> |

## Optimism Upgrade 20 Security Review (Cantina Managed)

- Report: [2026_08-U20-Cantina.md](<reports/2026_08-U20-Cantina.md>)
- Auditor: Cantina
- Date: 2026-08-20
- Description: Cantina Managed review of the Upgrade 20 (super-roots) L1 contract changes at commit 7799a246, covering the super fault dispute games, OPContractsManagerV2 and its validator/utility contracts, OptimismPortal2, SystemConfig, SuperchainConfig and related interfaces and libraries. The review found 6 Low and 8 Informational issues and no Critical, High or Medium findings; four Low fixes were verified.

### Repository: <a href="https://github.com/ethereum-optimism/optimism"><code>ethereum-optimism/optimism</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ethereum-optimism/optimism/commit/7799a2464f23b4e19abd5e29843545f960e677be"><code>7799a2464f23b4e19abd5e29843545f960e677be</code></a> | July 31, 2026 | <code>packages/contracts-bedrock/interfaces/dispute/ISuperFaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/interfaces/dispute/ISuperPermissionedDisputeGame.sol</code><br><code>packages/contracts-bedrock/interfaces/L1/IOptimismPortal2.sol</code><br><code>packages/contracts-bedrock/interfaces/L1/ISystemConfig.sol</code><br><code>packages/contracts-bedrock/interfaces/L1/opcm/IOPContractsManagerMigrationValidator.sol</code><br><code>packages/contracts-bedrock/interfaces/L1/opcm/IOPContractsManagerMigrator.sol</code><br><code>packages/contracts-bedrock/interfaces/L1/opcm/IStandardValidatorUtils.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperFaultDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/LibGameArgs.sol</code><br><code>packages/contracts-bedrock/src/dispute/lib/Types.sol</code><br><code>packages/contracts-bedrock/src/L1/OptimismPortal2.sol</code><br><code>packages/contracts-bedrock/src/L1/SuperchainConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerContainer.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerUtils.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerUtilsCaller.sol</code><br><code>packages/contracts-bedrock/src/libraries/Constants.sol</code><br><code>packages/contracts-bedrock/src/libraries/Features.sol</code><br><code>packages/contracts-bedrock/src/universal/SafeSend.sol</code><br><code>packages/contracts-bedrock/interfaces/L1/opcm/IOPContractsManagerContainer.sol</code><br><code>packages/contracts-bedrock/src/dispute/SuperPermissionedDisputeGame.sol</code><br><code>packages/contracts-bedrock/src/L1/OPContractsManagerStandardValidator.sol</code><br><code>packages/contracts-bedrock/src/L1/SystemConfig.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/OPContractsManagerV2.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/StandardValidatorUtils.sol</code><br><code>packages/contracts-bedrock/src/libraries/DevFeatures.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/cba37e86e44a6bc4fb414da62f2bb1d5b906502a"><code>cba37e86e44a6bc4fb414da62f2bb1d5b906502a</code></a> | August 12, 2026 | <code>packages/contracts-bedrock/src/L1/OPContractsManagerStandardValidator.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/44eb9547baef1331df04b826a15ca0e05ddedc1f"><code>44eb9547baef1331df04b826a15ca0e05ddedc1f</code></a> | August 13, 2026 | <code>packages/contracts-bedrock/src/dispute/SuperPermissionedDisputeGame.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/283bb456cf5b17f407f8f72826820d3852d966fe"><code>283bb456cf5b17f407f8f72826820d3852d966fe</code></a> | August 13, 2026 | <code>packages/contracts-bedrock/src/L1/OPContractsManagerStandardValidator.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/StandardValidatorUtils.sol</code> |
| <a href="https://github.com/ethereum-optimism/optimism/commit/ef695a353f8fd71ad03220a7b9e20f05d5c1715f"><code>ef695a353f8fd71ad03220a7b9e20f05d5c1715f</code></a> | August 13, 2026 | <code>packages/contracts-bedrock/src/L1/OPContractsManagerStandardValidator.sol</code><br><code>packages/contracts-bedrock/src/L1/opcm/StandardValidatorUtils.sol</code> |

## Irrelevant reports

### Optimism Bedrock Security Assessment Report (Sigma Prime)

- Report: [irrelevant/2022_08-Bedrock_GoLang-SigmaPrime.md](<reports/irrelevant/2022_08-Bedrock_GoLang-SigmaPrime.md>)
- Auditor: Sigma Prime
- Description: Time-boxed Sigma Prime review of the Golang implementation of the Bedrock rollup node (op-node) and reference-optimistic-geth, with a retest. The scope is limited to offchain node and client software.

### Optimism Upgrade Proposal #15a Review

- Report: [irrelevant/2025_04-Upgrade15a-Spearbit.md](<reports/irrelevant/2025_04-Upgrade15a-Spearbit.md>)
- Auditor: Spearbit
- Date: 2025-05-01
- Description: Spearbit review (2025-04-29 to 2025-05-03) of the superchain-ops tasks for Upgrade Proposal #15a (absolute prestate updates for Isthmus activation and blob preimage fix) on Optimism Mainnet, INK and Unichain, validating the multisig calldata, domain/message hashes and expected state diffs. It covers one-time upgrade execution artifacts only, with no protocol source code in scope.

### Optimism Superchain Security Review (Cantina Managed, RevShareContractsUpgrader)

- Report: [irrelevant/2025_11-Rev-Sharing-Contracts-Upgrader.md](<reports/irrelevant/2025_11-Rev-Sharing-Contracts-Upgrader.md>)
- Auditor: Cantina
- Date: 2025-11-28
- Description: Cantina Managed review (Nov 20-23, 2025) of the superchain-ops RevShareContractsUpgrader and its FeeSplitterSetup, FeeVaultUpgrader and RevShareCommon libraries at commit 5a01b8c1, i.e. one-time upgrade/task scripts used to migrate chains to the FeeSplitter revenue-sharing contracts. Only two Informational findings, fixed in PR 1308 (commit 692cab0d).
