# Audit source summary: unichain

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Unichain contracts Security Review (October 2024)

- Report: [Cantina - Unichain contracts Security Review 2024-10-16.md](<reports/Cantina - Unichain contracts Security Review 2024-10-16.md>)
- Auditor: Cantina
- Date: 2024-10-16
- Description: Cantina Managed review of the Unichain fee-splitting and staking contracts (FeeSplitter, NetFeeSplitter, L1Splitter, L2StakeManager, RewardDistributor) in the unichain-contracts repository. Initial review conducted October 3-7, 2024 with fix verification of the reported issues.

### Repository: <a href="https://github.com/Uniswap/unichain-contracts"><code>Uniswap/unichain-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/unichain-contracts/commit/b7d5bbb0ea0ea2a90d21ce3368b773b8015d1607"><code>b7d5bbb0ea0ea2a90d21ce3368b773b8015d1607</code></a> | October 3, 2024 | <code>src</code> (recursive directory) |
| <a href="https://github.com/Uniswap/unichain-contracts/commit/5992d6d32779a2daa4cad458c42d5fd4cfaafe16"><code>5992d6d32779a2daa4cad458c42d5fd4cfaafe16</code></a> | October 7, 2024 | <code>src</code> (recursive directory) |
| <a href="https://github.com/Uniswap/unichain-contracts/commit/9aec08780500f4cd5c233c76dccbb3f1be7fb9b5"><code>9aec08780500f4cd5c233c76dccbb3f1be7fb9b5</code></a> | October 7, 2024 | <code>src</code> (recursive directory) |
| <a href="https://github.com/Uniswap/unichain-contracts/commit/d9dffca7ec2e8fe0591950331ff4715153770d99"><code>d9dffca7ec2e8fe0591950331ff4715153770d99</code></a> | October 7, 2024 | <code>src</code> (recursive directory) |
| <a href="https://github.com/Uniswap/unichain-contracts/commit/4a9abf7220b56fba31ccb857c35c742ab89b0247"><code>4a9abf7220b56fba31ccb857c35c742ab89b0247</code></a> | October 10, 2024 | <code>src</code> (recursive directory) |

## Unichain contracts Security Review (November 2024)

- Report: [Cantina - Unichain contracts Security Review 2024-11-05.md](<reports/Cantina - Unichain contracts Security Review 2024-11-05.md>)
- Auditor: Cantina
- Date: 2024-11-05
- Description: Follow-up Cantina Managed review of the Unichain fee-splitting and staking contracts at a later revision of the unichain-contracts repository, conducted October 31 to November 2, 2024. Re-examines the code after the changes that followed the October 2024 review, with fix verification.

### Repository: <a href="https://github.com/Uniswap/unichain-contracts"><code>Uniswap/unichain-contracts</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/unichain-contracts/commit/935f521c0710d5e6055bb046355cd99fab301f26"><code>935f521c0710d5e6055bb046355cd99fab301f26</code></a> | October 29, 2024 | <code>src</code> (recursive directory) |
| <a href="https://github.com/Uniswap/unichain-contracts/commit/fb9024ae9d58cf7bc4a43f01cec0f0f78196a82a"><code>fb9024ae9d58cf7bc4a43f01cec0f0f78196a82a</code></a> | November 1, 2024 | <code>src</code> (recursive directory) |
| <a href="https://github.com/Uniswap/unichain-contracts/commit/d7db41e68e73bc7e58bfff9cae6f4e8f695030da"><code>d7db41e68e73bc7e58bfff9cae6f4e8f695030da</code></a> | November 1, 2024 | <code>src</code> (recursive directory) |

## Uniswap Flashtestations Audit

- Report: [OpenZeppelin - Uniswap Flashtestations Audit.md](<reports/OpenZeppelin - Uniswap Flashtestations Audit.md>)
- Auditor: OpenZeppelin
- Date: 2026-06-26
- Description: Two-phase OpenZeppelin audit (August 6-11, 2025) of the onchain Flashtestations TEE attestation contracts (FlashtestationRegistry, BlockBuilderPolicy, QuoteParser and interfaces) plus their deployment and interaction scripts. These contracts verify Intel TDX attestations of the block builders used by Unichain.

### Repository: <a href="https://github.com/flashbots/flashtestations"><code>flashbots/flashtestations</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/flashbots/flashtestations/commit/9ce1371d0a079396d49c1aa7876cf9b0075629e8"><code>9ce1371d0a079396d49c1aa7876cf9b0075629e8</code></a> | July 31, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code><br><code>src/utils/QuoteParser.sol</code><br><code>src/interfaces/IAttestation.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code><br><code>script/BlockBuilderPolicy.s.sol</code><br><code>script/FlashtestationRegistry.s.sol</code><br><code>script/Interactions.s.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/5b0370dda239b5fd88ff7fa7940915f092e5530b"><code>5b0370dda239b5fd88ff7fa7940915f092e5530b</code></a> | August 14, 2025 | <code>src/FlashtestationRegistry.sol</code><br><code>src/interfaces/IAttestation.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/38e19c2432171e445a54acc4f2bd72db233ccd1e"><code>38e19c2432171e445a54acc4f2bd72db233ccd1e</code></a> | August 15, 2025 | <code>src/BlockBuilderPolicy.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/0140167c80d8a93ac025e25e59e9e3518c82e939"><code>0140167c80d8a93ac025e25e59e9e3518c82e939</code></a> | August 15, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code><br><code>src/utils/QuoteParser.sol</code><br><code>src/interfaces/IAttestation.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code><br><code>script/BlockBuilderPolicy.s.sol</code><br><code>script/FlashtestationRegistry.s.sol</code><br><code>script/Interactions.s.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/aab77b266824fef2cf7b72a2cea8507027e02e12"><code>aab77b266824fef2cf7b72a2cea8507027e02e12</code></a> | August 18, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/f95ce2cbfcdcf53137eaea3c2a93d04cab4b08cc"><code>f95ce2cbfcdcf53137eaea3c2a93d04cab4b08cc</code></a> | August 18, 2025 | <code>src/BlockBuilderPolicy.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/c719a4e13c1bda118830f445dd6825b702964ebe"><code>c719a4e13c1bda118830f445dd6825b702964ebe</code></a> | August 18, 2025 | <code>src/FlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/5dd4305ef8741a3db5174a93ad9ecac2c2a8c9e5"><code>5dd4305ef8741a3db5174a93ad9ecac2c2a8c9e5</code></a> | August 18, 2025 | <code>src/FlashtestationRegistry.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/b389e66e49285152b7f3627ca493ef8faee6bfce"><code>b389e66e49285152b7f3627ca493ef8faee6bfce</code></a> | August 19, 2025 | <code>src/BlockBuilderPolicy.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/1e253768a12490a8b9fb8491c03de2fbb82e9f70"><code>1e253768a12490a8b9fb8491c03de2fbb82e9f70</code></a> | August 19, 2025 | <code>src/BlockBuilderPolicy.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/6b7e14fb0d25c3d1eddba9a0c6a4235af56ed063"><code>6b7e14fb0d25c3d1eddba9a0c6a4235af56ed063</code></a> | August 19, 2025 | <code>src/FlashtestationRegistry.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/5a7fb4aab06c4a5f3bc14cda75139ca19cc4d858"><code>5a7fb4aab06c4a5f3bc14cda75139ca19cc4d858</code></a> | August 19, 2025 | <code>src/FlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/c78ac251e81d845c502f89c6c246cd6d10e41da2"><code>c78ac251e81d845c502f89c6c246cd6d10e41da2</code></a> | August 19, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/fdfef228f0434a5fe99e17af99e0f607dbd6979c"><code>fdfef228f0434a5fe99e17af99e0f607dbd6979c</code></a> | August 19, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code><br><code>src/interfaces/IAttestation.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/210a86170ecfa67ad093c57ec7ffa072db446ba5"><code>210a86170ecfa67ad093c57ec7ffa072db446ba5</code></a> | August 20, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code><br><code>script/Interactions.s.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/4cd46034d6d7dde62ad00013a18e61dfad34cbac"><code>4cd46034d6d7dde62ad00013a18e61dfad34cbac</code></a> | August 20, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/ad43c904c81e4d44c524ea9c76f4e7cfaa026395"><code>ad43c904c81e4d44c524ea9c76f4e7cfaa026395</code></a> | August 20, 2025 | <code>src/BlockBuilderPolicy.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/6dace7ae3b7e6a994b3096ad92398d1bda0d78f6"><code>6dace7ae3b7e6a994b3096ad92398d1bda0d78f6</code></a> | August 20, 2025 | <code>src/FlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/3ad9547634d1792fe6276d8a9796568798456389"><code>3ad9547634d1792fe6276d8a9796568798456389</code></a> | August 20, 2025 | <code>src/FlashtestationRegistry.sol</code><br><code>src/interfaces/IFlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/2e33699dd1dfff29239c4769b653417eb47219fc"><code>2e33699dd1dfff29239c4769b653417eb47219fc</code></a> | August 20, 2025 | <code>src/FlashtestationRegistry.sol</code><br><code>src/utils/QuoteParser.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/b921c243f374f04d326885dfffc6c7569428042e"><code>b921c243f374f04d326885dfffc6c7569428042e</code></a> | August 21, 2025 | <code>src/interfaces/IFlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/18fc01d102bbd76096e5edfef4040b596570bf99"><code>18fc01d102bbd76096e5edfef4040b596570bf99</code></a> | August 22, 2025 | <code>src/FlashtestationRegistry.sol</code> |
| <a href="https://github.com/flashbots/flashtestations/commit/a2371bae9faf5fafceeac8091785a7f86e0ac8f7"><code>a2371bae9faf5fafceeac8091785a7f86e0ac8f7</code></a> | August 22, 2025 | <code>src/BlockBuilderPolicy.sol</code><br><code>src/FlashtestationRegistry.sol</code> |

## Irrelevant reports

### NM-0411-0491 Security Review Rollup Boost

- Report: [irrelevant/Nethermind - NM-0411-0491 Security Review Rollup Boost.md](<reports/irrelevant/Nethermind - NM-0411-0491 Security Review Rollup Boost.md>)
- Auditor: Nethermind
- Date: 2025-06-09
- Description: Nethermind security review of Rollup Boost, the Rust sidecar service that lets external block builders construct blocks for OP Stack sequencers. The entire scope is offchain node software (flashbots/rollup-boost); no onchain contracts or circuits are covered.
