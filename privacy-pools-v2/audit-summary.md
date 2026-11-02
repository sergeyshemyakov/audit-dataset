# Audit source summary: privacy-pools-v2

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Privacy Pools v2 — Code Security Review

- Report: [auditware-privacy-pools-v2-code-security-review-2026-08.md](<reports/auditware-privacy-pools-v2-code-security-review-2026-08.md>)
- Auditor: Auditware
- Date: 2026-08-25
- Description: Auditware re-audit of the Privacy Pools v2 contracts focused on the changes since its previous review: the Aave yield wrapper, batch transactions, proof-context binding of the relayer, cold-start relayed registration and stealth addresses. Findings are located in the core contracts, the deployment scripts, the relayer and the SDK, with a retest of the fixes.

### Repository: <a href="https://github.com/0xbow-io/v2-monorepo"><code>0xbow-io/v2-monorepo</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xbow-io/v2-monorepo/blob/71263ca8acdca0ebd66b4a428733ed90857265cc/packages/contracts/src"><code>71263ca8acdca0ebd66b4a428733ed90857265cc</code></a> | July 14, 2026 | <code>packages/contracts/src</code> (recursive directory)<br><code>packages/contracts/script/Deploy.s.sol</code><br><code>packages/contracts/script/helpers/DeploymentVerifier.sol</code><br><code>packages/contracts/script/registries/ChainConfigRegistry.sol</code><br><code>packages/relayer/relayer/src/chain.service/evm.chain.service.ts</code> (other)<br><code>packages/sdk/src/services/poolSessions/PoolSessionBatchWithdraw.ts</code> (other) |
| <a href="https://github.com/0xbow-io/v2-monorepo/blob/38c16e7b2a6417f7aad584ac0413002e4e7e80a3/packages/contracts/src"><code>38c16e7b2a6417f7aad584ac0413002e4e7e80a3</code></a> | August 19, 2026 | <code>packages/contracts/src</code> (recursive directory)<br><code>packages/contracts/script/Deploy.s.sol</code><br><code>packages/contracts/script/DeployStaging.s.sol</code><br><code>packages/contracts/script/helpers/DeploymentVerifier.sol</code><br><code>packages/contracts/script/registries/ChainConfigRegistry.sol</code><br><code>packages/relayer/relayer/src/chain.service/evm.chain.service.ts</code> (other)<br><code>packages/sdk/src/services/poolSessions/PoolSessionBatchWithdraw.ts</code> (other) |

## Privacy Pools v2 — security review findings

- Report: [consensys-diligence-privacy-pools-v2-security-review-2026-09.md](<reports/consensys-diligence-privacy-pools-v2-security-review-2026-09.md>)
- Auditor: Consensys Diligence
- Date: 2026-09-14
- Description: Consensys Diligence vulnerability-mining review of the Privacy Pools v2 monorepo at the tip of its v2.0 branch, covering the core and swap contracts, the circuits, the relayer services and the SDK. Reports 32 open findings, one of them High, in the RelaySwaps contract.

### Repository: <a href="https://github.com/0xbow-io/v2-monorepo"><code>0xbow-io/v2-monorepo</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/0xbow-io/v2-monorepo/blob/638bf8f4a0f4ef26761e439a338c8db6667dc30b/packages/contracts/src"><code>638bf8f4a0f4ef26761e439a338c8db6667dc30b</code></a> | September 8, 2026 | <code>packages/contracts/src</code> (recursive directory)<br><code>packages/swaps/contracts/src</code> (recursive directory)<br><code>packages/swaps/contracts/src/RelaySwaps.sol</code><br><code>packages/circuits/circuits</code> (recursive directory) (zk)<br><code>packages/relayer</code> (recursive directory) (other)<br><code>packages/sdk</code> (recursive directory) (other) |
