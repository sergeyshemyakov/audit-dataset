# Audit source summary: _libs/zk-kit

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Semaphore PSE audit

- Report: [PSE - Semaphore 4.0.0 Audit.md](<reports/PSE - Semaphore 4.0.0 Audit.md>)
- Auditor: PSE (Privacy &amp; Scaling Explorations)
- Description: In-house audit performed by PSE (Privacy &amp; Scaling Explorations) in March 2024 of Semaphore v4.0.0-beta.1 (smart contracts, Circom circuits and TypeScript) and of the zk-kit packages it depends on (InternalLeanIMT.sol, binary-merkle-root.circom and related TypeScript libraries) at tag imt.sol-v2.0.0-beta.8. It reports three Critical and three High findings, each with an implemented fix PR.

### Repository: <a href="https://github.com/semaphore-protocol/semaphore"><code>semaphore-protocol/semaphore</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/semaphore-protocol/semaphore/commit/8eb19e83fda62644872b2fcfbd85011d3b2c21e2"><code>8eb19e83fda62644872b2fcfbd85011d3b2c21e2</code></a> | February 28, 2024 | <code>packages/contracts</code> (recursive directory)<br><code>packages/circuits</code> (recursive directory) (zk) |
| <a href="https://github.com/semaphore-protocol/semaphore/commit/f06ddd32e49e41973178f2500911d5d26cb16779"><code>f06ddd32e49e41973178f2500911d5d26cb16779</code></a> | March 12, 2024 | <code>packages/contracts</code> (recursive directory) |
| <a href="https://github.com/semaphore-protocol/semaphore/commit/baa18c885eea73932edfce570840bf2284e6bcd9"><code>baa18c885eea73932edfce570840bf2284e6bcd9</code></a> | March 13, 2024 | <code>packages/contracts</code> (recursive directory) |
| <a href="https://github.com/semaphore-protocol/semaphore/commit/b12dd0fd984fa3d5de9f2c2bd17f1e470cd6f4d1"><code>b12dd0fd984fa3d5de9f2c2bd17f1e470cd6f4d1</code></a> | March 14, 2024 | <code>packages/contracts</code> (recursive directory) |
| <a href="https://github.com/semaphore-protocol/semaphore/commit/c3b9b98370598b78bc1d6d9d7e91546773f37631"><code>c3b9b98370598b78bc1d6d9d7e91546773f37631</code></a> | March 15, 2024 | <code>packages/contracts</code> (recursive directory) |
| <a href="https://github.com/semaphore-protocol/semaphore/commit/255bccf2ebc7a1ebfe06ebc7bb1bff2f8141fa83"><code>255bccf2ebc7a1ebfe06ebc7bb1bff2f8141fa83</code></a> | March 21, 2024 | <code>packages/contracts</code> (recursive directory) |
| <a href="https://github.com/semaphore-protocol/semaphore/commit/7c99c74fac080fbf66d9b1de1ee8245debcf476d"><code>7c99c74fac080fbf66d9b1de1ee8245debcf476d</code></a> | April 8, 2024 | <code>packages/contracts</code> (recursive directory) |
| <a href="https://github.com/semaphore-protocol/semaphore/commit/ba8132561a115cfc2c097bf0a8f3550914b757bf"><code>ba8132561a115cfc2c097bf0a8f3550914b757bf</code></a> | April 17, 2024 | <code>packages/circuits</code> (recursive directory) (zk) |

### Repository: <a href="https://github.com/privacy-scaling-explorations/zk-kit"><code>privacy-scaling-explorations/zk-kit</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/749de51d8372881239242528319312b4dfd7bafb"><code>749de51d8372881239242528319312b4dfd7bafb</code></a> | March 17, 2024 | <code>packages/circuits/circom/binary-merkle-root.circom</code> (zk) |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/215dfb30ba548918181419df5598d0a652901b7c"><code>215dfb30ba548918181419df5598d0a652901b7c</code></a> | March 18, 2024 | <code>packages/imt.sol/contracts/internal/InternalLeanIMT.sol</code><br><code>packages/circuits/circom/binary-merkle-root.circom</code> (zk)<br><code>packages/utils/src/f1-field.ts</code> (other)<br><code>packages/eddsa-poseidon/src/eddsa-poseidon.ts</code> (other) |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/21df170d6d969d8dcfa763bc1aeb1390c320a627"><code>21df170d6d969d8dcfa763bc1aeb1390c320a627</code></a> | March 20, 2024 | <code>packages/imt.sol/contracts/internal/InternalLeanIMT.sol</code> |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/18b8ed9fe2fc089af9ff8ac67a05b096fe7cc470"><code>18b8ed9fe2fc089af9ff8ac67a05b096fe7cc470</code></a> | March 20, 2024 | <code>packages/imt.sol/contracts/internal/InternalLeanIMT.sol</code> |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/f9f409f190e8de427e67d9270bad3a3e07403783"><code>f9f409f190e8de427e67d9270bad3a3e07403783</code></a> | March 20, 2024 | <code>packages/imt.sol/contracts/internal/InternalLeanIMT.sol</code> |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/c8173a4e668ba68e7d560555bf9da11c8120a7c2"><code>c8173a4e668ba68e7d560555bf9da11c8120a7c2</code></a> | March 21, 2024 | <code>packages/imt.sol/contracts/internal/InternalLeanIMT.sol</code> |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/4c5ceca07673e89b112e849c2689ea0b1c3bf4d9"><code>4c5ceca07673e89b112e849c2689ea0b1c3bf4d9</code></a> | March 26, 2024 | <code>packages/imt.sol/contracts/internal/InternalLeanIMT.sol</code> |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/a79dfc496ec7f76ac31b9b779b75a7d5f1ba192e"><code>a79dfc496ec7f76ac31b9b779b75a7d5f1ba192e</code></a> | April 17, 2024 | <code>packages/utils/src/f1-field.ts</code> (other) |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/41b4fb8ae929b52ff4d1b84c751d0a93dcdc9156"><code>41b4fb8ae929b52ff4d1b84c751d0a93dcdc9156</code></a> | April 18, 2024 | <code>packages/utils/src/f1-field.ts</code> (other) |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/dbc7c70a54dcbd6c83b71621b7da1e66644d4559"><code>dbc7c70a54dcbd6c83b71621b7da1e66644d4559</code></a> | April 22, 2024 | <code>packages/utils/src/f1-field.ts</code> (other) |
| <a href="https://github.com/privacy-scaling-explorations/zk-kit/commit/a8c6d3d6f41f680200cae90618944485009cbd87"><code>a8c6d3d6f41f680200cae90618944485009cbd87</code></a> | April 23, 2024 | <code>packages/eddsa-poseidon/src/eddsa-poseidon.ts</code> (other) |
