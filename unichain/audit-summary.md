# Audit source summary: unichain

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps.

## Unichain contracts Security Review (Cantina Managed, Oct 3-7 2024)

- Report: [Cantina - Unichain contracts Security Review 2024-10-16.md](<reports/Cantina - Unichain contracts Security Review 2024-10-16.md>)
- Auditor: Cantina
- Date: 2024-10-16
- Description: Cantina Managed security review of the Unichain onchain fee-splitting and staking contracts (FeeSplitter, NetFeeSplitter, L1Splitter, L2StakeManager, RewardDistributor). Initial review of the unichain-contracts repository.

### Repository: <a href="https://github.com/Uniswap/unichain-contracts"><code>Uniswap/unichain-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/unichain-contracts/tree/b7d5bbb0ea0ea2a90d21ce3368b773b8015d1607/src"><code>b7d5bbb0ea0ea2a90d21ce3368b773b8015d1607</code></a> | October 3, 2024 | <code>src</code> (recursive directory) |

## Unichain contracts Security Review (Cantina Managed, Oct 31-Nov 2 2024)

- Report: [Cantina - Unichain contracts Security Review 2024-11-05.md](<reports/Cantina - Unichain contracts Security Review 2024-11-05.md>)
- Auditor: Cantina
- Date: 2024-11-05
- Description: Follow-up Cantina Managed security review of the same Unichain fee-splitting and staking contracts at a later revision of the unichain-contracts repository. Re-checks the code after the changes that followed the October 2024 review.

### Repository: <a href="https://github.com/Uniswap/unichain-contracts"><code>Uniswap/unichain-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/unichain-contracts/tree/935f521c0710d5e6055bb046355cd99fab301f26/src"><code>935f521c0710d5e6055bb046355cd99fab301f26</code></a> | October 30, 2024 | <code>src</code> (recursive directory) |

## Uniswap Flashtestations Audit

- Report: [OpenZeppelin - Uniswap Flashtestations Audit.md](<reports/OpenZeppelin - Uniswap Flashtestations Audit.md>)
- Auditor: OpenZeppelin
- Date: 2026-06-26
- Description: Two-phase OpenZeppelin audit of the onchain Flashtestations TEE attestation contracts (FlashtestationRegistry, BlockBuilderPolicy, QuoteParser and interfaces) together with their deployment and interaction scripts. These contracts verify Intel TDX attestations used for Unichain block building.

### Repository: <a href="https://github.com/flashbots/flashtestations"><code>flashbots/flashtestations</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/flashbots/flashtestations/blob/9ce1371d0a079396d49c1aa7876cf9b0075629e8/src/BlockBuilderPolicy.sol"><code>9ce1371d0a079396d49c1aa7876cf9b0075629e8</code></a> | July 31, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code><br><code>src/utils/QuoteParser.sol</code><br><code>src/interfaces/IAttestation.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code><br><code>script/BlockBuilderPolicy.s.sol</code><br><code>script/FlashtestationRegistry.s.sol</code><br><code>script/Interactions.s.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/blob/0140167c80d8a93ac025e25e59e9e3518c82e939/src/BlockBuilderPolicy.sol"><code>0140167c80d8a93ac025e25e59e9e3518c82e939</code></a> | August 15, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code><br><code>src/utils/QuoteParser.sol</code><br><code>src/interfaces/IAttestation.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code><br><code>script/BlockBuilderPolicy.s.sol</code><br><code>script/FlashtestationRegistry.s.sol</code><br><code>script/Interactions.s.sol</code> |

## Irrelevant reports

### Security Review Report NM-0411-0491 Rollup Boost

- Report: [irrelevant/Nethermind - NM-0411-0491 Security Review Rollup Boost.md](<reports/irrelevant/Nethermind - NM-0411-0491 Security Review Rollup Boost.md>)
- Auditor: Nethermind Security
- Date: 2025-06-09
- Description: Security review of Rollup Boost, the Rust sidecar service that lets external block builders construct blocks for OP Stack sequencers. The entire scope is the offchain rollup-boost node software; no onchain contracts or circuits are covered.
