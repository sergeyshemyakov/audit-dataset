# Audit source summary: tornado-cash

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Tornado Circuit Audit. Final version

- Report: [TornadoCash_circuit_audit_ABDK.md](<reports/TornadoCash_circuit_audit_ABDK.md>)
- Auditor: ABDK Consulting
- Date: 2019-11-25
- Description: Review of the Tornado Cash circom circuit set (Withdraw, MerkleTree/MerkleTreeChecker, Selector and supporting templates) against the circom documentation and the Tornado spec. No major issues were found, only mostly non-optimal template patterns.

### Repository: <a href="https://github.com/peppersec/tornado-mixer"><code>peppersec/tornado-mixer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/circuits/merkleTree.circom"><code>0484408e82e8f1eebd081186cb11189aa0e9b57f</code></a> | October 17, 2019 | <code>circuits/merkleTree.circom</code><br><code>circuits/withdraw.circom</code> |
| <a href="https://github.com/peppersec/tornado-mixer/commit/9efab84e"><code>9efab84e65d923410ce4418794a5ca2ddcd74f37</code></a> | November 2, 2019 | <code>circuits/withdraw.circom</code> |
| <a href="https://github.com/peppersec/tornado-mixer/commit/7193655e"><code>7193655e4940476269426b80da40bc9a099598e4</code></a> | November 2, 2019 | <code>circuits/merkleTree.circom</code><br><code>circuits/withdraw.circom</code> |
| <a href="https://github.com/peppersec/tornado-mixer/commit/07168f98"><code>07168f9816a6a78767f53aab25624bd1d739a66d</code></a> | November 2, 2019 | <code>circuits/merkleTree.circom</code> |
| <a href="https://github.com/peppersec/tornado-mixer/commit/f8cd3fea"><code>f8cd3fea1eb5664dd0f8b3e4b83ac6e0c0ba3371</code></a> | November 3, 2019 | <code>circuits/merkleTree.circom</code><br><code>circuits/withdraw.circom</code> |

## Tornado Cash Smart Contracts Audit. Final Version

- Report: [TornadoCash_contract_audit_ABDK.md](<reports/TornadoCash_contract_audit_ABDK.md>)
- Auditor: ABDK Consulting
- Date: 2019-11-19
- Description: Audit of the Tornado Cash on-chain Solidity contract set in the peppersec/tornado-mixer repository, including ERC20Mixer, the mixer core, Merkle tree and hasher contracts. No critical issues were found and all other significant issues were fixed.

### Repository: <a href="https://github.com/peppersec/tornado-mixer"><code>peppersec/tornado-mixer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/ERC20Mixer.sol"><code>0484408e82e8f1eebd081186cb11189aa0e9b57f</code></a> | October 17, 2019 | <code>contracts/ERC20Mixer.sol</code><br><code>contracts/ETHMixer.sol</code><br><code>contracts/Mixer.sol</code><br><code>contracts/MerkleTreeWithHistory.sol</code> |
| <a href="https://github.com/peppersec/tornado-mixer/commit/c00e5532"><code>c00e5532994f03f8bc61f147259bc5d353a0d2c9</code></a> | November 3, 2019 | <code>contracts/ERC20Mixer.sol</code> |
| <a href="https://github.com/peppersec/tornado-mixer/commit/83c9ba72969ff3dfd6b66acec5134666f8fdf283"><code>83c9ba72969ff3dfd6b66acec5134666f8fdf283</code></a> | November 11, 2019 | <code>contracts/ERC20Mixer.sol</code> |
| <a href="https://github.com/peppersec/tornado-mixer/blob/d0e312eb808797a4f20a81fda2224185a3f914b4/contracts/ERC20Mixer.sol"><code>d0e312eb808797a4f20a81fda2224185a3f914b4</code></a> | November 18, 2019 | <code>contracts/ERC20Mixer.sol</code><br><code>contracts/ETHMixer.sol</code><br><code>contracts/Mixer.sol</code><br><code>contracts/MerkleTreeWithHistory.sol</code> |

## Tornado Privacy Solution Cryptographic Review Version 1.1

- Report: [TornadoCash_cryptographic_review_ABDK.md](<reports/TornadoCash_cryptographic_review_ABDK.md>)
- Auditor: ABDK Consulting
- Date: 2019-11-29
- Description: Cryptographic review of the Tornado Cash zero-knowledge mixer protocol and its implementation: the deposit/withdraw scheme, Pedersen and MiMC hashing, the Merkle tree construction, and the zkSNARK statement, together with the circomlib primitives they rely on.

### Repository: <a href="https://github.com/peppersec/tornado-mixer"><code>peppersec/tornado-mixer</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/peppersec/tornado-mixer/tree/master/contracts"><code>master</code></a> (mutable branch) | — | <code>contracts/</code> (recursive directory)<br><code>cli.js</code> |

### Repository: <a href="https://github.com/iden3/circomlib"><code>iden3/circomlib</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/iden3/circomlib/tree/master/circuits"><code>master</code></a> (mutable branch) | — | <code>circuits/</code> (recursive directory)<br><code>src/mimcsponge_gencontract.js</code> |

## Tornado Farm Smart Contracts and Circuits. Audit

- Report: [ABDK - Tornado Cash Anonymity Mining First Audit.md](<reports/ABDK - Tornado Cash Anonymity Mining First Audit.md>)
- Auditor: ABDK Consulting
- Date: 2020-09-01
- Description: First ABDK audit of the Tornado Cash anonymity mining (Farm) smart contract and its Reward circuit, delivered as private files with Farm.sol published as a gist. A critical circuit issue permitting a reward-value underflow was found, together with moderate and minor contract issues.

### Repository: <a href="https://gist.github.com/AleksandraZv/ea0d4d3e4c00c5ab5e06499bf34356c6"><code>gist/AleksandraZv/ea0d4d3e4c00c5ab5e06499bf34356c6</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://gist.github.com/AleksandraZv/ea0d4d3e4c00c5ab5e06499bf34356c6/051df72c9b1203e7ab7308a4452105036ad46bfb"><code>051df72c9b1203e7ab7308a4452105036ad46bfb</code></a> | August 29, 2020 | <code>Farm.sol</code> |

### Repository: <a href="https://github.com/tornadocash/tornado-anonymity-mining"><code>tornadocash/tornado-anonymity-mining</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/releases/tag/audit"><code>audit</code></a> (unresolved tag) | — | <code>circuits/Reward.circom</code> |

## Tornado Farm Smart Contracts and Circuits. Final Audit

- Report: [ABDK - Tornado Cash Anonymity Mining Final Audit.md](<reports/ABDK - Tornado Cash Anonymity Mining Final Audit.md>)
- Auditor: ABDK Consulting
- Date: 2020-09-15
- Description: Final ABDK audit of the Tornado Cash anonymity mining Farm contract and Reward circuit, comparing the audited release tag with the fixed version. The major circuit underflow issue was resolved by explicit range checks, and the remaining issues were judged to have no security impact.

### Repository: <a href="https://github.com/tornadocash/tornado-anonymity-mining"><code>tornadocash/tornado-anonymity-mining</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/releases/tag/audit"><code>audit</code></a> (unresolved tag) | — | <code>contracts/Farm.sol</code><br><code>circuits/Reward.circom</code> |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/tree/audit-fixed"><code>audit-fixed</code></a> (mutable branch) | — | <code>contracts/Farm.sol</code><br><code>circuits/Reward.circom</code> |

## Tornado Cash Anonymity Mining Audit

- Report: [Zeropool - Tornado Cash Anonymity Mining.md](<reports/Zeropool - Tornado Cash Anonymity Mining.md>)
- Auditor: Igor Gulamov (ZeroPool)
- Date: 2020-10-15
- Description: Independent ZeroPool audit of the Tornado Cash anonymity mining smart contracts and zkSNARK circuits at commit 820bd83, excluding the generated verifiers and MerkleTree.circom. No critical issues were found; two major issues were reported, one fixed and one accepted as governance-controlled.

### Repository: <a href="https://github.com/tornadocash/tornado-anonymity-mining"><code>tornadocash/tornado-anonymity-mining</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/tree/820bd83254f3264cebaf255869641ebc33288dc3/circuits"><code>820bd83254f3264cebaf255869641ebc33288dc3</code></a> | September 21, 2020 | <code>circuits/</code> (recursive directory)<br><code>circuits/MerkleTree.circom</code> (explicitly not audited)<br><code>circuits/MerkleTreeUpdater.circom</code><br><code>circuits/Withdraw.circom</code><br><code>contracts/</code> (recursive directory)<br><code>contracts/IVerifier.sol</code> (explicitly not audited)<br><code>contracts/RewardVerifier.sol</code> (explicitly not audited)<br><code>contracts/TreeUpdateVerifier.sol</code> (explicitly not audited)<br><code>contracts/WithdrawVerifier.sol</code> (explicitly not audited)<br><code>contracts/Miner.sol</code><br><code>contracts/RewardSwap.sol</code> |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/blob/7487ac8b09dcfc78ecc166cff5208435010cec8e/circuits/MerkleTreeUpdater.circom"><code>7487ac8b09dcfc78ecc166cff5208435010cec8e</code></a> | October 12, 2020 | <code>circuits/MerkleTreeUpdater.circom</code> |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/blob/c8865315c50f3a0cabdd4110a6c45ceba4d4b809/contracts/Miner.sol"><code>c8865315c50f3a0cabdd4110a6c45ceba4d4b809</code></a> | October 12, 2020 | <code>contracts/Miner.sol</code> |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/blob/e0008b3ed46dbf127b452d1d086235f0fe2dfcb8/contracts/Miner.sol"><code>e0008b3ed46dbf127b452d1d086235f0fe2dfcb8</code></a> | October 12, 2020 | <code>contracts/Miner.sol</code> |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/blob/49ce4e9375509c3bc866d32fbf6345361a85b9a0/contracts/Miner.sol"><code>49ce4e9375509c3bc866d32fbf6345361a85b9a0</code></a> | October 13, 2020 | <code>contracts/Miner.sol</code> |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/blob/459fa79321b1b48eefc3cb85f82733528d5e56d3/circuits/Withdraw.circom"><code>459fa79321b1b48eefc3cb85f82733528d5e56d3</code></a> | October 14, 2020 | <code>circuits/Withdraw.circom</code> |

## Tornado Smart Contract Audit Conclusion

- Report: [ABDK - Tornado Cash Anonymity Mining Recheck.md](<reports/ABDK - Tornado Cash Anonymity Mining Recheck.md>)
- Auditor: ABDK Consulting
- Date: 2020-12-22
- Description: ABDK re-review of the changed Tornado Cash anonymity mining Solidity contracts at commit 9ec05a6, covering the miner, tornado trees, reward swap, proxy, Merkle tree utilities and interfaces. Three major issues were reported, in IHasher.sol and TornadoTrees.sol.

### Repository: <a href="https://github.com/tornadocash/tornado-anonymity-mining"><code>tornadocash/tornado-anonymity-mining</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/tornadocash/tornado-anonymity-mining/blob/9ec05a681d9699a11733b3163dd44a1e90abc345/contracts/interfaces/IHasher.sol"><code>9ec05a681d9699a11733b3163dd44a1e90abc345</code></a> | November 2, 2020 | <code>contracts/interfaces/IHasher.sol</code><br><code>contracts/interfaces/IRewardSwap.sol</code><br><code>contracts/interfaces/IVerifier.sol</code><br><code>contracts/interfaces/ITornado.sol</code><br><code>contracts/Miner.sol</code><br><code>contracts/TornadoTrees.sol</code><br><code>contracts/utils/MerkleTreeWithHistory.sol</code><br><code>contracts/TornadoProxy.sol</code><br><code>contracts/RewardSwap.sol</code><br><code>contracts/utils/OwnableMerkleTree.sol</code> |

## Irrelevant reports

### Tornado pool audit

- Report: [Zeropool-Tornado.pool-audit.md](<reports/Zeropool-Tornado.pool-audit.md>)
- Auditor: Igor Gulamov (Zeropool)
- Date: 2021-08-01
- Description: Independent audit of the tornado-pool zkSNARK circuits (merkleTree.circom, transaction.circom) and Solidity contracts, including the pull request adding OVM support. No critical or major issues were found.

### Frontend Security Audit Report: Tornado Cash

- Report: [irrelevant/Decurity - Tornado Cash Classic dApp.md](<reports/irrelevant/Decurity - Tornado Cash Classic dApp.md>)
- Auditor: Decurity
- Description: Frontend security audit of the Tornado Cash Classic UI dApp hosted on IPFS, covering client-side hijacking, CSP and header configuration, and related web weaknesses. No onchain contract or circuit code was in scope.
