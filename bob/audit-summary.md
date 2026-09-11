# Audit source summary: bob

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Review-Report BOB modified USDC bridge library 04.2024 (BOB-02-WP1)

- Report: [Cure53 - BOB Modified USDC Bridge Library (WP1).md](<reports/Cure53 - BOB Modified USDC Bridge Library (WP1).md>)
- Auditor: Cure53
- Date: 2024-04-30
- Description: Cure53 cryptography review and source code audit of BOB&#x27;s modified USDC bridge library (L1/L2 USDC bridges, shared UsdcBridge base, UsdcManager and helpers) submitted as PR #1 to the bob-collective/optimism fork. One High front-running finding and one Low finding, both fixed during the assessment and verified by Cure53.

### Repository: <a href="https://github.com/bob-collective/optimism"><code>bob-collective/optimism</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/bob-collective/optimism/tree/a80a28610962d361cf1c8b67c3f513d0ffb1f792/packages/contracts-bedrock/src/L1/L1UsdcBridge.sol"><code>a80a28610962d361cf1c8b67c3f513d0ffb1f792</code></a> | April 11, 2024 | <code>packages/contracts-bedrock/src/L1/L1UsdcBridge.sol</code><br><code>packages/contracts-bedrock/src/L2/L2UsdcBridge.sol</code><br><code>packages/contracts-bedrock/src/universal/UsdcBridge.sol</code><br><code>packages/contracts-bedrock/src/L2/UsdcManager.sol</code><br><code>packages/contracts-bedrock/src/L1/IPartialUsdc.sol</code><br><code>packages/contracts-bedrock/src/libraries/Pausable.sol</code> |
| <a href="https://github.com/bob-collective/optimism/tree/2f7f05f827f1cd4d07ad3f8c10255077f469e79f/packages/contracts-bedrock/src/L2/UsdcManager.sol"><code>2f7f05f827f1cd4d07ad3f8c10255077f469e79f</code></a> | April 15, 2024 | <code>packages/contracts-bedrock/src/L2/UsdcManager.sol</code> |
| <a href="https://github.com/bob-collective/optimism/tree/fafad42472901497645e03953672489c2d41b3ab/packages/contracts-bedrock/src/L1/L1UsdcBridge.sol"><code>fafad42472901497645e03953672489c2d41b3ab</code></a> | April 17, 2024 | <code>packages/contracts-bedrock/src/L1/L1UsdcBridge.sol</code><br><code>packages/contracts-bedrock/src/L2/L2UsdcBridge.sol</code><br><code>packages/contracts-bedrock/src/universal/UsdcBridge.sol</code> |

## BOB USDC Bridge Security Review

- Report: [Pashov - BOB USDC Bridge (Apr 2024).md](<reports/Pashov - BOB USDC Bridge (Apr 2024).md>)
- Auditor: Pashov Audit Group
- Date: 2024-04-22
- Description: Pashov Audit Group time-boxed review of the USDC bridge contracts (IPartialUsdc, L1UsdcBridge, L2UsdcBridge, UsdcBridge, Pausable, UsdcManager) in the bob-collective/optimism fork at commit 4c27e88, with fixes reviewed at c9648be. A single Low finding on Bridged USDC Standard compliance was resolved.

### Repository: <a href="https://github.com/bob-collective/optimism"><code>bob-collective/optimism</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/bob-collective/optimism/tree/4c27e88204aaa8dc531b3ff1fdd5b4e8ec85d056/packages/contracts-bedrock/src/L1/L1UsdcBridge.sol"><code>4c27e88204aaa8dc531b3ff1fdd5b4e8ec85d056</code></a> | April 18, 2024 | <code>packages/contracts-bedrock/src/L1/L1UsdcBridge.sol</code><br><code>packages/contracts-bedrock/src/L2/L2UsdcBridge.sol</code><br><code>packages/contracts-bedrock/src/universal/UsdcBridge.sol</code><br><code>packages/contracts-bedrock/src/L2/UsdcManager.sol</code><br><code>packages/contracts-bedrock/src/L1/IPartialUsdc.sol</code><br><code>packages/contracts-bedrock/src/libraries/Pausable.sol</code> |
| <a href="https://github.com/bob-collective/optimism/tree/c9648bed367881438e782bf9e7de9dc70fa50a29/packages/contracts-bedrock/src/L1/L1UsdcBridge.sol"><code>c9648bed367881438e782bf9e7de9dc70fa50a29</code></a> | April 22, 2024 | <code>packages/contracts-bedrock/src/L1/L1UsdcBridge.sol</code> |

## BOB FusionLock Smart Contract Audit

- Report: [Common Prefix - FusionLock.md](<reports/Common Prefix - FusionLock.md>)
- Auditor: Common Prefix
- Date: 2024-03-29
- Description: Common Prefix audit of the FusionLock.sol deposit-and-bridge contract for BOB&#x27;s Fusion Season One campaign at commit afe34d5 of bob-collective/fusion-lock, including a compatibility check of the announced token list against the Optimism bridge. Two Low and four Informational findings, all resolved in the listed fix commits.

### Repository: <a href="https://github.com/bob-collective/fusion-lock"><code>bob-collective/fusion-lock</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/bob-collective/fusion-lock/tree/afe34d57ff6ad61cd9593755b36c5250e53159f5/src/FusionLock.sol"><code>afe34d57ff6ad61cd9593755b36c5250e53159f5</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/6f5489e6a443d591c0d882eb5779d260bf39ce35/src/FusionLock.sol"><code>6f5489e6a443d591c0d882eb5779d260bf39ce35</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/5dced5f0330e953314b5406b5a9828f24caf9cab/src/FusionLock.sol"><code>5dced5f0330e953314b5406b5a9828f24caf9cab</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/ba0b987cf5b5828e8ac729199d7177268d8e1fe8/src/FusionLock.sol"><code>ba0b987cf5b5828e8ac729199d7177268d8e1fe8</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/0885622b0e55d4d5000e7a13f2373366340d93e6/src/FusionLock.sol"><code>0885622b0e55d4d5000e7a13f2373366340d93e6</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/dc7a8460ba0aa687c962561d337308d4e7873093/src/FusionLock.sol"><code>dc7a8460ba0aa687c962561d337308d4e7873093</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/455416c3184585790f8bdcb66336e47fd96efed5/src/FusionLock.sol"><code>455416c3184585790f8bdcb66336e47fd96efed5</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/9af92bd48f01b1f5a8e068e1d7900be3f37674d0/src/FusionLock.sol"><code>9af92bd48f01b1f5a8e068e1d7900be3f37674d0</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |

## Bob Collective Security Assessment (fusion-lock)

- Report: [OtterSec - FusionLock.md](<reports/OtterSec - FusionLock.md>)
- Auditor: OtterSec
- Date: 2024-03-30
- Description: OtterSec assessment of the fusion-lock program (FusionLock.sol) at commit e4f25ee of bob-collective/fusion-lock, conducted March 18-22, 2024. Two informational findings (bridge-address override flexibility, gas-limit documentation) were reported and patched in da35903 and 2db42bb.

### Repository: <a href="https://github.com/bob-collective/fusion-lock"><code>bob-collective/fusion-lock</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/bob-collective/fusion-lock/tree/e4f25ee6302839deb30d5a96721a64610d36598c/src/FusionLock.sol"><code>e4f25ee6302839deb30d5a96721a64610d36598c</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/da359031f013b34f6504fc6462db9f78fd76ba57/src/FusionLock.sol"><code>da359031f013b34f6504fc6462db9f78fd76ba57</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |
| <a href="https://github.com/bob-collective/fusion-lock/tree/2db42bbe4545f8524ea7a1ad939ea38c1cc4aad7/src/FusionLock.sol"><code>2db42bbe4545f8524ea7a1ad939ea38c1cc4aad7</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |

## BOB FusionLock Security Assessment (Summary Report)

- Report: [Trail of Bits - FusionLock.md](<reports/Trail of Bits - FusionLock.md>)
- Auditor: Trail of Bits
- Date: 2024-04-03
- Description: Trail of Bits two engineer-day review of the FusionLock contract at commit f65b5c5 of bob-collective/fusion-lock, covering deposit locking, L1 withdrawal and bridging to BOB L2 with static and dynamic testing. Three data-validation findings (one Low, two Informational); bridging attack scenarios were explicitly not examined in depth.

### Repository: <a href="https://github.com/bob-collective/fusion-lock"><code>bob-collective/fusion-lock</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/bob-collective/fusion-lock/tree/f65b5c58d495a80cafceab6bfa046b0d10fd90e1/src/FusionLock.sol"><code>f65b5c58d495a80cafceab6bfa046b0d10fd90e1</code></a> | March 29, 2024 | <code>src/FusionLock.sol</code> |

## Veridise Auditing Report for Kailua Protocol (February 2025)

- Report: [Veridise - Kailua Security Audit (Feb 2025).md](<reports/Veridise - Kailua Security Audit (Feb 2025).md>)
- Auditor: Veridise
- Date: 2025-02-18
- Description: Veridise three-week assessment of RISC Zero&#x27;s Kailua fault-proof framework (smart contracts, off-chain CLI/client/host components and zkVM guest program) at commit 6e2ce8f, which BOB uses as its dispute game. Six Critical and seven High findings were reported; all but one were confirmed fixed in the stated commits and PR #21, with Kona and Zeth dependencies out of scope.

### Repository: <a href="https://github.com/boundless-xyz/kailua"><code>boundless-xyz/kailua</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/boundless-xyz/kailua/tree/6e2ce8f35bb51d4f75eddf3dab0de225d5d8a224/crates/contracts/foundry/src"><code>6e2ce8f35bb51d4f75eddf3dab0de225d5d8a224</code></a> | January 6, 2025 | <code>crates/contracts/foundry/src</code> (recursive directory)<br><code>crates/contracts/foundry/src/vendor</code> (recursive directory) (explicitly not audited)<br><code>crates/common/src</code> (recursive directory)<br><code>bin/cli</code> (recursive directory)<br><code>bin/cli/src/bench.rs</code> (explicitly not audited)<br><code>bin/cli/src/fast_track.rs</code> (explicitly not audited)<br><code>bin/cli/src/fault.rs</code> (explicitly not audited)<br><code>bin/cli/src/providers</code> (recursive directory) (explicitly not audited)<br><code>bin/client</code> (recursive directory)<br><code>bin/host</code> (recursive directory)<br><code>build/risczero/fpvm/src/main.rs</code><br><code>build/risczero/src/lib.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/5586e1dcad820ba6673c3d80a1cdb2878309d5af/crates/contracts/foundry/src"><code>5586e1dcad820ba6673c3d80a1cdb2878309d5af</code></a> | January 27, 2025 | <code>crates/contracts/foundry/src</code> (recursive directory)<br><code>crates/common/src</code> (recursive directory)<br><code>bin/cli</code> (recursive directory)<br><code>bin/client</code> (recursive directory)<br><code>bin/host</code> (recursive directory)<br><code>build/risczero/fpvm/src/main.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/27dec82b67de1051df9258b36f8366ebf308e5bf/crates/contracts/foundry/src"><code>27dec82b67de1051df9258b36f8366ebf308e5bf</code></a> | February 6, 2025 | <code>crates/contracts/foundry/src</code> (recursive directory) |
| <a href="https://github.com/boundless-xyz/kailua/tree/871eb34c508c3f3c5b52c7a2acc68e6000cf1aa8/crates/common/src"><code>871eb34c508c3f3c5b52c7a2acc68e6000cf1aa8</code></a> | February 6, 2025 | <code>crates/common/src</code> (recursive directory) |
| <a href="https://github.com/boundless-xyz/kailua/tree/bd76b761856c836736042364eca9b924235dedfa/crates/common/src"><code>bd76b761856c836736042364eca9b924235dedfa</code></a> | February 6, 2025 | <code>crates/common/src</code> (recursive directory) |
| <a href="https://github.com/boundless-xyz/kailua/tree/f1c7e4211cfe728b8390eebe748c72cf4eda152b/bin/cli"><code>f1c7e4211cfe728b8390eebe748c72cf4eda152b</code></a> | February 6, 2025 | <code>bin/cli</code> (recursive directory) |
| <a href="https://github.com/boundless-xyz/kailua/tree/00fccf3cbcd0c303df972c0986bd6d541ba2897f/crates/common/src"><code>00fccf3cbcd0c303df972c0986bd6d541ba2897f</code></a> | February 14, 2025 | <code>crates/common/src</code> (recursive directory)<br><code>bin/cli</code> (recursive directory)<br><code>bin/client</code> (recursive directory)<br><code>build/risczero/fpvm/src/main.rs</code> |

## Veridise Auditing Report for Kailua Protocol (May 2025)

- Report: [Veridise - Kailua Security Audit (May 2025).md](<reports/Veridise - Kailua Security Audit (May 2025).md>)
- Auditor: Veridise
- Date: 2025-05-22
- Description: Veridise second review of Kailua, limited to the four Solidity contracts in crates/contracts/foundry/src at commit 7eb9869 after the first-audit fixes and the new validity-proof functionality; off-chain components and vendor code were out of scope. Two Medium, one Low, two Warning and one Informational findings, all fixed in PRs #43-#46.

### Repository: <a href="https://github.com/boundless-xyz/kailua"><code>boundless-xyz/kailua</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/boundless-xyz/kailua/tree/7eb9869641f9eb957d692cc99bec8755d65fe5cc/crates/contracts/foundry/src/KailuaTournament.sol"><code>7eb9869641f9eb957d692cc99bec8755d65fe5cc</code></a> | April 30, 2025 | <code>crates/contracts/foundry/src/KailuaTournament.sol</code><br><code>crates/contracts/foundry/src/KailuaLib.sol</code><br><code>crates/contracts/foundry/src/KailuaTreasury.sol</code><br><code>crates/contracts/foundry/src/KailuaGame.sol</code><br><code>crates/contracts/foundry/src/vendor</code> (recursive directory) (explicitly not audited) |
| <a href="https://github.com/boundless-xyz/kailua/tree/c11ab5409504ea4e9ddeb120838be2c8c41a12d5/crates/contracts/foundry/src/KailuaTournament.sol"><code>c11ab5409504ea4e9ddeb120838be2c8c41a12d5</code></a> | May 15, 2025 | <code>crates/contracts/foundry/src/KailuaTournament.sol</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/dbfd8d47c12cb820ed07a67194bc541f62bdbec9/crates/contracts/foundry/src/KailuaTournament.sol"><code>dbfd8d47c12cb820ed07a67194bc541f62bdbec9</code></a> | May 19, 2025 | <code>crates/contracts/foundry/src/KailuaTournament.sol</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/d41694c43fd4a9c0095edb83161d0dbd21a318ad/crates/contracts/foundry/src/KailuaTournament.sol"><code>d41694c43fd4a9c0095edb83161d0dbd21a318ad</code></a> | May 19, 2025 | <code>crates/contracts/foundry/src/KailuaTournament.sol</code><br><code>crates/contracts/foundry/src/KailuaLib.sol</code><br><code>crates/contracts/foundry/src/KailuaTreasury.sol</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/e4b7aae99c2b9a05340de4b99fad76fba3faca29/crates/contracts/foundry/src/KailuaTreasury.sol"><code>e4b7aae99c2b9a05340de4b99fad76fba3faca29</code></a> | May 19, 2025 | <code>crates/contracts/foundry/src/KailuaTreasury.sol</code> |

## Veridise Auditing Report for Kailua Protocol (June 2025)

- Report: [Veridise - Kailua Security Audit (Jun 2025).md](<reports/Veridise - Kailua Security Audit (Jun 2025).md>)
- Auditor: Veridise
- Date: 2025-06-16
- Description: Veridise third review of Kailua, covering only the off-chain zkVM application files (derivation, execution, precondition, journal and proof stitching under crates/common/src and the RISC Zero guest program) at commit 52c5999; smart contracts and node software were excluded. One Medium, three Warning and two Informational findings, all fixed in PRs #50-#55.

### Repository: <a href="https://github.com/boundless-xyz/kailua"><code>boundless-xyz/kailua</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/boundless-xyz/kailua/tree/52c59998a0e8828747de5c724e3b8a5c7979b683/build/risczero/build.rs"><code>52c59998a0e8828747de5c724e3b8a5c7979b683</code></a> | May 27, 2025 | <code>build/risczero/build.rs</code><br><code>build/risczero/fpvm/src/main.rs</code><br><code>crates/common/src/lib.rs</code><br><code>crates/common/src/blobs.rs</code><br><code>crates/common/src/config.rs</code><br><code>crates/common/src/executor.rs</code><br><code>crates/common/src/journal.rs</code><br><code>crates/common/src/kona.rs</code><br><code>crates/common/src/precondition.rs</code><br><code>crates/common/src/client/core.rs</code><br><code>crates/common/src/client/stateless.rs</code><br><code>crates/common/src/client/stitching.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/49440bfb1368eb708236b6b88543c6e664eb71d9/crates/common/src/client/core.rs"><code>49440bfb1368eb708236b6b88543c6e664eb71d9</code></a> | June 12, 2025 | <code>crates/common/src/client/core.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/f6cee44cdab11b8e0c2ce9dd5a167d81df35dbb0/crates/common/src/blobs.rs"><code>f6cee44cdab11b8e0c2ce9dd5a167d81df35dbb0</code></a> | June 13, 2025 | <code>crates/common/src/blobs.rs</code><br><code>crates/common/src/precondition.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/eb77d326688811877fd881765e1044c24c37e354/crates/common/src/blobs.rs"><code>eb77d326688811877fd881765e1044c24c37e354</code></a> | June 13, 2025 | <code>crates/common/src/blobs.rs</code><br><code>crates/common/src/executor.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/0724bb7bebc51172e0904ed3b1a8d4ff2719a42b/crates/common/src/journal.rs"><code>0724bb7bebc51172e0904ed3b1a8d4ff2719a42b</code></a> | June 13, 2025 | <code>crates/common/src/journal.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/bfaae6a270f7ebd4b200b03cdb83800cad41ed0a/crates/common/src/client/stitching.rs"><code>bfaae6a270f7ebd4b200b03cdb83800cad41ed0a</code></a> | June 13, 2025 | <code>crates/common/src/client/stitching.rs</code> |

## Veridise Auditing Report for Kailua (October 2025)

- Report: [Veridise - Kailua Security Audit (Oct 2025).md](<reports/Veridise - Kailua Security Audit (Oct 2025).md>)
- Auditor: Veridise
- Date: 2025-11-04
- Description: Veridise fourth review of Kailua for Boundless, limited to thirteen files of the stateless Optimism client crate (crates/kona) and the zkVM guest at commit 2414297, focusing on whether the new pause/resume derivation could compose incorrect proofs. Two Medium and one Warning findings, all fixed.

### Repository: <a href="https://github.com/boundless-xyz/kailua"><code>boundless-xyz/kailua</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/boundless-xyz/kailua/tree/2414297a5f9feb98365ef6d88634bcd181a1934b/build/risczero/kona/src/main.rs"><code>2414297a5f9feb98365ef6d88634bcd181a1934b</code></a> | October 21, 2025 | <code>build/risczero/kona/src/main.rs</code><br><code>crates/kona/src/blobs.rs</code><br><code>crates/kona/src/config.rs</code><br><code>crates/kona/src/executor.rs</code><br><code>crates/kona/src/journal.rs</code><br><code>crates/kona/src/lib.rs</code><br><code>crates/kona/src/witness.rs</code><br><code>crates/kona/src/client/core.rs</code><br><code>crates/kona/src/client/stateless.rs</code><br><code>crates/kona/src/client/stitching.rs</code><br><code>crates/kona/src/oracle/local.rs</code><br><code>crates/kona/src/oracle/mod.rs</code><br><code>crates/kona/src/precondition/mod.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/a4d3d6b1852a83b61f7243df562c0eb15fedbd43/crates/kona/src/config.rs"><code>a4d3d6b1852a83b61f7243df562c0eb15fedbd43</code></a> | October 28, 2025 | <code>crates/kona/src/config.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/3f71fb4235c88bf346a26f4f9b66410f258b59ca/crates/kona/src/client/stitching.rs"><code>3f71fb4235c88bf346a26f4f9b66410f258b59ca</code></a> | October 31, 2025 | <code>crates/kona/src/client/stitching.rs</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/b0964471a3003e9172a5a081d1a5a1457a83bc9d/crates/kona/src/config.rs"><code>b0964471a3003e9172a5a081d1a5a1457a83bc9d</code></a> | November 3, 2025 | <code>crates/kona/src/config.rs</code><br><code>crates/kona/src/journal.rs</code><br><code>crates/kona/src/client/core.rs</code><br><code>crates/kona/src/client/stitching.rs</code> |

## Veridise Auditing Report for Kailua (February 2026)

- Report: [Veridise - Kailua Security Audit (Feb 2026).md](<reports/Veridise - Kailua Security Audit (Feb 2026).md>)
- Auditor: Veridise
- Date: 2026-03-06
- Description: Veridise one-week review for Boundless of the changes to five Kailua Solidity contracts since commit 7eb9869, at commit ccf2771, introducing the fault-proof permit system. Three Low findings were fixed in PRs #127-#128; three Warnings were acknowledged or partially fixed.

### Repository: <a href="https://github.com/boundless-xyz/kailua"><code>boundless-xyz/kailua</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/boundless-xyz/kailua/tree/ccf2771857721a9cda5f7943ed7ef1d236c20bbd/crates/contracts/foundry/src/KailuaVerifier.sol"><code>ccf2771857721a9cda5f7943ed7ef1d236c20bbd</code></a> | February 6, 2026 | <code>crates/contracts/foundry/src/KailuaVerifier.sol</code><br><code>crates/contracts/foundry/src/KailuaGame.sol</code><br><code>crates/contracts/foundry/src/KailuaLib.sol</code><br><code>crates/contracts/foundry/src/KailuaTournament.sol</code><br><code>crates/contracts/foundry/src/KailuaTreasury.sol</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/895939cd1acaca3e902a2e6d22d95d3416e2b474/crates/contracts/foundry/src/KailuaVerifier.sol"><code>895939cd1acaca3e902a2e6d22d95d3416e2b474</code></a> | March 4, 2026 | <code>crates/contracts/foundry/src/KailuaVerifier.sol</code> |
| <a href="https://github.com/boundless-xyz/kailua/tree/04cb174bebbe305082b8746b1542e0db3cd352fc/crates/contracts/foundry/src/KailuaGame.sol"><code>04cb174bebbe305082b8746b1542e0db3cd352fc</code></a> | March 4, 2026 | <code>crates/contracts/foundry/src/KailuaGame.sol</code><br><code>crates/contracts/foundry/src/KailuaLib.sol</code> |

## Irrelevant reports

### Review-Report BOB Onramp Smart Contracts 04.2024 (BOB-02-WP2)

- Report: [irrelevant/Cure53 - BOB Onramp Smart Contract (WP2).md](<reports/irrelevant/Cure53 - BOB Onramp Smart Contract (WP2).md>)
- Auditor: Cure53
- Date: 2024-04-30
- Description: Cure53 review of the BOB Onramp Solidity contracts (Onramp, OnrampFactory) and the associated Rust relayer/API codebase at commit 297eeb1 of the private bob-collective/bob-onramp repository; one Medium and three Low findings. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB On-ramp Smart Contracts Audit

- Report: [irrelevant/Common Prefix - BOB Onramp Smart Contract.md](<reports/irrelevant/Common Prefix - BOB Onramp Smart Contract.md>)
- Auditor: Common Prefix
- Date: 2024-04-22
- Description: Common Prefix audit of OnRamp.sol and OnRampFactory.sol at commit 297eeb1 of the private bob-collective/bob-onramp repository; one Medium and four Low findings, all resolved. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB Onramp Security Review

- Report: [irrelevant/Pashov - BOB Onramp (Apr 2024).md](<reports/irrelevant/Pashov - BOB Onramp (Apr 2024).md>)
- Auditor: Pashov Audit Group
- Date: 2024-04-22
- Description: Pashov Audit Group review of OnrampFactory and Onramp at commit 9bf1966 (fixes 403389e) of the private bob-collective/bob-onramp repository; five Medium and five Low findings. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB Security Review (Gateway V2)

- Report: [irrelevant/Pashov - BOB Gateway V2 (Aug 2024).md](<reports/irrelevant/Pashov - BOB Gateway V2 (Aug 2024).md>)
- Auditor: Pashov Audit Group
- Date: 2024-08-12
- Description: Pashov Audit Group review of the BOB Gateway V2 contracts (Gateway, GatewayRegistry, OnrampV1, swappers and interfaces) at commit 1511179 (fixes 36b5dec) of the private bob-collective/bob-gateway repository; seven Low findings. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB Gateway Security Review (V3)

- Report: [irrelevant/Pashov - BOB Gateway V3 (Sep 2024).md](<reports/irrelevant/Pashov - BOB Gateway V3 (Sep 2024).md>)
- Auditor: Pashov Audit Group
- Date: 2024-09-07
- Description: Pashov Audit Group review of Gateway, GatewayRegistry, GatewayRegistryV2 and the Bedrock, Pell, Segment, Shoebill and Solv strategies at commit c26afe6 (fixes 86c81ac) of the private bob-collective/bob-gateway repository; six Low findings. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB Gateway Security Review (Offramp Registry)

- Report: [irrelevant/Pashov - BOB Gateway Offramp Registry (Mar 2025).md](<reports/irrelevant/Pashov - BOB Gateway Offramp Registry (Mar 2025).md>)
- Auditor: Pashov Audit Group
- Date: 2025-03-20
- Description: Pashov Audit Group review of OfframpRegistry and CommonStructs at commit b668688 (fixes 5e6f457) of the private bob-collective/bob-gateway repository; one Medium and seven Low findings. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB Gateway Security Review (Offramp Solver)

- Report: [irrelevant/Pashov - BOB Gateway Offramp Solver (Aug 2025).md](<reports/irrelevant/Pashov - BOB Gateway Offramp Solver (Aug 2025).md>)
- Auditor: Pashov Audit Group
- Date: 2025-08-30
- Description: Pashov Audit Group review of the off-chain Rust offramp solver (api_client, app, error, main, models, scan_and_process_orders, utils) at commit 6ad820b (fixes 4622efb) of the private bob-collective/bob-gateway repository; one High, one Medium and two Low findings. Scope is off-chain backend code in a private repository.

### BOB Token Security Review

- Report: [irrelevant/Pashov - BOB Token (Feb 2025).md](<reports/irrelevant/Pashov - BOB Token (Feb 2025).md>)
- Auditor: Pashov Audit Group
- Date: 2025-02-06
- Description: Pashov Audit Group review of the upgradeable BobToken ERC-20 at commit 8f31e53 (fixes 8d80ac7) of the private bob-collective/bob-token repository; one Low finding. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB Token Security Review (V2)

- Report: [irrelevant/Pashov - BOB Token V2 (Oct 2025).md](<reports/irrelevant/Pashov - BOB Token V2 (Oct 2025).md>)
- Auditor: Pashov Audit Group
- Date: 2025-10-21
- Description: Pashov Audit Group review of BobTokenV2.sol and BobTokenV2Upgrade.sol at commit ba519a0 of the private bob-collective/bob-token repository; two Low findings acknowledged. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB Staking Security Review (March 2025)

- Report: [irrelevant/Pashov - BOB Staking (Mar 2025).md](<reports/irrelevant/Pashov - BOB Staking (Mar 2025).md>)
- Auditor: Pashov Audit Group
- Date: 2025-03-07
- Description: Pashov Audit Group review of BonusWrapper, UnbondableStake and helper libraries at commit ab1b12f (fixes f1d9998) of the private bob-collective/bob-staking repository; two Medium and four Low findings. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.

### BOB Staking Security Review (October 2025)

- Report: [irrelevant/Pashov - BOB Staking (Oct 2025).md](<reports/irrelevant/Pashov - BOB Staking (Oct 2025).md>)
- Auditor: Pashov Audit Group
- Date: 2025-10-21
- Description: Pashov Audit Group review of BobStaking.sol and BonusWrapper.sol at commit 73158d3 (fixes 44842c6) of the private bob-collective/bob-staking repository; two Critical, two High, three Medium and thirteen Low findings. The repository is private and none of the stated commits are reachable on GitHub, so no audited source can be fetched.
