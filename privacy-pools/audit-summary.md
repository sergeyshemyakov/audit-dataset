# Audit source summary: privacy-pools

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Privacy Pools Smart Contracts Security Audit Report (Privacy Pools v1)

- Report: [oxorio-privacy-pools-v1-audit-2024-05.md](<reports/oxorio-privacy-pools-v1-audit-2024-05.md>)
- Auditor: Oxorio
- Date: 2024-05-24
- Description: Security audit by Oxorio of the Privacy Pools v1 onchain contracts and the proof-of-innocence membership circuit. Covers the ETH and ERC20 pools, the Merkle tree with history, and the circuit&#x27;s constraint soundness.

### Repository: <a href="https://github.com/ProofOfInnocence/privacy-pools-v1"><code>ProofOfInnocence/privacy-pools-v1</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ProofOfInnocence/privacy-pools-v1/blob/e221f0b88e52fb5c214726e765997ef4067793a9/contracts/PrivacyPool.sol"><code>e221f0b88e52fb5c214726e765997ef4067793a9</code></a> | February 5, 2024 | <code>contracts/PrivacyPool.sol</code><br><code>contracts/ERC20PrivacyPool.sol</code><br><code>contracts/ETHPrivacyPool.sol</code><br><code>contracts/MerkleTreeWithHistory.sol</code><br><code>membership-proof/circuits/proofOfInnocence.circom</code> |
| <a href="https://github.com/ProofOfInnocence/privacy-pools-v1/blob/8ab7132877325e27b22053e974b3310d70b860b5/contracts/PrivacyPool.sol"><code>8ab7132877325e27b22053e974b3310d70b860b5</code></a> | April 13, 2024 | <code>contracts/PrivacyPool.sol</code><br><code>contracts/ERC20PrivacyPool.sol</code><br><code>contracts/ETHPrivacyPool.sol</code><br><code>contracts/MerkleTreeWithHistory.sol</code><br><code>membership-proof/circuits/proofOfInnocence.circom</code> |

## Privacy Pools circuits audit report

- Report: [oxorio-privacy-pools-circuits-audit-2025-02.md](<reports/oxorio-privacy-pools-circuits-audit-2025-02.md>)
- Auditor: Oxorio
- Date: 2025-02-21
- Description: Express security audit by Oxorio of the three Privacy Pools Circom circuits: commitment, merkleTree and withdraw. Assesses constraint soundness and correctness of the withdrawal proof system.

### Repository: <a href="https://github.com/0xbow-io/privacy-pools-core"><code>0xbow-io/privacy-pools-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/56d5d48c21e9493954e2660d0cc252ce537edc25/packages/circuits/circuits/commitment.circom"><code>56d5d48c21e9493954e2660d0cc252ce537edc25</code></a> | January 20, 2025 | <code>packages/circuits/circuits/commitment.circom</code><br><code>packages/circuits/circuits/merkleTree.circom</code><br><code>packages/circuits/circuits/withdraw.circom</code> |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/8da36d5e2150ab3c567d85ca8a6b2eb6b51740cb/packages/circuits/circuits/commitment.circom"><code>8da36d5e2150ab3c567d85ca8a6b2eb6b51740cb</code></a> | February 19, 2025 | <code>packages/circuits/circuits/commitment.circom</code><br><code>packages/circuits/circuits/merkleTree.circom</code><br><code>packages/circuits/circuits/withdraw.circom</code> |

## Privacy Pools Core Audit Report

- Report: [auditware-privacy-pools-core-audit.md](<reports/auditware-privacy-pools-core-audit.md>)
- Auditor: Auditware
- Description: Security review by Auditware of the Privacy Pools core contracts that provide public deposits and private partial withdrawals gated by ASP membership proofs. Covers Entrypoint, PrivacyPool, State, the simple and complex pool implementations, and the shared libraries.

### Repository: <a href="https://github.com/0xbow-io/privacy-pools-core"><code>0xbow-io/privacy-pools-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/f0b8fe5e7b91b942523e8af671c59c3a4c75f612/packages/contracts/src/contracts/Entrypoint.sol"><code>f0b8fe5e7b91b942523e8af671c59c3a4c75f612</code></a> | February 14, 2025 | <code>packages/contracts/src/contracts/Entrypoint.sol</code><br><code>packages/contracts/src/contracts/PrivacyPool.sol</code><br><code>packages/contracts/src/contracts/State.sol</code><br><code>packages/contracts/src/contracts/implementations/PrivacyPoolComplex.sol</code><br><code>packages/contracts/src/contracts/implementations/PrivacyPoolSimple.sol</code><br><code>packages/contracts/src/contracts/lib/Constants.sol</code><br><code>packages/contracts/src/contracts/lib/ProofLib.sol</code> |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/6cdeeaf0e44b98d5563c9d2f340f5825bec117f2/packages/contracts/src/contracts/Entrypoint.sol"><code>6cdeeaf0e44b98d5563c9d2f340f5825bec117f2</code></a> | March 5, 2025 | <code>packages/contracts/src/contracts/Entrypoint.sol</code> |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/ac36feba8ba26f3485acd0d87a9d5c373ab3967d/packages/contracts/src/contracts/Entrypoint.sol"><code>ac36feba8ba26f3485acd0d87a9d5c373ab3967d</code></a> | March 10, 2025 | <code>packages/contracts/src/contracts/Entrypoint.sol</code><br><code>packages/contracts/src/contracts/State.sol</code> |

## Privacy Pools Smart Contracts Audit Report

- Report: [oxorio-privacy-pools-core-contracts-audit-2025-03.md](<reports/oxorio-privacy-pools-core-contracts-audit-2025-03.md>)
- Auditor: Oxorio
- Date: 2025-03-18
- Description: Smart contract security audit by Oxorio of the seven Privacy Pools core contracts. Covers the Entrypoint, PrivacyPool and State logic plus the pool implementations and libraries, including a fix review of the final commit.

### Repository: <a href="https://github.com/0xbow-io/privacy-pools-core"><code>0xbow-io/privacy-pools-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/2d4627ba55743d17ff62a2856d93ef7cc926fc64/packages/contracts/src/contracts/Entrypoint.sol"><code>2d4627ba55743d17ff62a2856d93ef7cc926fc64</code></a> | February 24, 2025 | <code>packages/contracts/src/contracts/Entrypoint.sol</code><br><code>packages/contracts/src/contracts/PrivacyPool.sol</code><br><code>packages/contracts/src/contracts/State.sol</code><br><code>packages/contracts/src/contracts/implementations/PrivacyPoolComplex.sol</code><br><code>packages/contracts/src/contracts/implementations/PrivacyPoolSimple.sol</code><br><code>packages/contracts/src/contracts/lib/Constants.sol</code><br><code>packages/contracts/src/contracts/lib/ProofLib.sol</code> |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/016a949f53f0493388a6877529f28774ef054a8e/packages/contracts/src/contracts/Entrypoint.sol"><code>016a949f53f0493388a6877529f28774ef054a8e</code></a> | March 5, 2025 | <code>packages/contracts/src/contracts/Entrypoint.sol</code> |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/532eaa8ed151f06697249d400926d17adf442d8e/packages/contracts/src/contracts/Entrypoint.sol"><code>532eaa8ed151f06697249d400926d17adf442d8e</code></a> | March 14, 2025 | <code>packages/contracts/src/contracts/Entrypoint.sol</code><br><code>packages/contracts/src/contracts/PrivacyPool.sol</code><br><code>packages/contracts/src/contracts/State.sol</code><br><code>packages/contracts/src/contracts/implementations/PrivacyPoolComplex.sol</code><br><code>packages/contracts/src/contracts/implementations/PrivacyPoolSimple.sol</code><br><code>packages/contracts/src/contracts/lib/Constants.sol</code><br><code>packages/contracts/src/contracts/lib/ProofLib.sol</code> |

## Privacy Pools Smart Contracts Audit Report (Entrypoint precommitment upgrade)

- Report: [oxorio-privacy-pools-precommitment-pr-audit-2025-05.md](<reports/oxorio-privacy-pools-precommitment-pr-audit-2025-05.md>)
- Auditor: Oxorio
- Date: 2025-05-20
- Description: Oxorio audit of the precommitment pull request changes to the Privacy Pools Entrypoint contract and its interface. Scoped to the two modified contracts rather than the whole protocol.

### Repository: <a href="https://github.com/0xbow-io/privacy-pools-core"><code>0xbow-io/privacy-pools-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/238e3594053becde68aa40e1e4cef6c0c46e68da/packages/contracts/src/contracts/Entrypoint.sol"><code>238e3594053becde68aa40e1e4cef6c0c46e68da</code></a> | May 19, 2025 | <code>packages/contracts/src/contracts/Entrypoint.sol</code><br><code>packages/contracts/src/interfaces/IEntrypoint.sol</code> |

## Privacy Pools Batch Relayer Audit Report

- Report: [auditware-privacy-pools-batch-relayer-audit.md](<reports/auditware-privacy-pools-batch-relayer-audit.md>)
- Auditor: Auditware
- Description: Auditware security review of the Privacy Pools BatchRelayer contract, which enables atomic batch withdrawals from privacy pools. Covers the implementation, its interface and the deployment script.

### Repository: <a href="https://github.com/0xbow-io/privacy-pools-core"><code>0xbow-io/privacy-pools-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xbow-io/privacy-pools-core/blob/2f6a650b4cbc7872e163a70c56cdc977fe7839b4/packages/contracts/src/contracts/BatchRelayer.sol"><code>2f6a650b4cbc7872e163a70c56cdc977fe7839b4</code></a> | August 11, 2025 | <code>packages/contracts/src/contracts/BatchRelayer.sol</code><br><code>packages/contracts/src/interfaces/IBatchRelayer.sol</code><br><code>packages/contracts/script/BatchRelayer.s.sol</code> |

## Irrelevant reports

### Privacy Pools Seed Phrase Generation Audit Report

- Report: [irrelevant/auditware-privacy-pools-seed-phrase-generation-audit.md](<reports/irrelevant/auditware-privacy-pools-seed-phrase-generation-audit.md>)
- Auditor: Auditware
- Description: Auditware review of the Privacy Pools website&#x27;s deterministic BIP39 seed-phrase derivation from Ethereum wallet signatures. Scope is limited to offchain frontend wallet key-derivation code in the privacy-pools-website repository.
