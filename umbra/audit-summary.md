# Audit source summary: umbra

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps.

## Umbra Smart Contracts

- Report: [umbra-audit-2021-03.md](<reports/umbra-audit-2021-03.md>)
- Auditor: Nicholas Ward (Consensys Diligence)
- Description: Review of the Umbra Protocol on-chain smart contracts (Umbra.sol and IUmbraHookReceiver.sol), plus a cursory review of the ENS StealthKeyResolver contract. Off-chain libraries, cryptography, and Gas Station Network integrations were explicitly excluded.

### Repository: <a href="https://github.com/ScopeLift/umbra-protocol"><code>ScopeLift/umbra-protocol</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ScopeLift/umbra-protocol/blob/fa2e17367d66a85f20c77299ded5942d9ab64fe0/contracts/contracts/Umbra.sol"><code>fa2e17367d66a85f20c77299ded5942d9ab64fe0</code></a> | March 19, 2021 | <code>contracts/contracts/Umbra.sol</code><br><code>contracts/contracts/IUmbraHookReceiver.sol</code> |
| <a href="https://github.com/ScopeLift/umbra-protocol/blob/7cfdc81be65bb81e14ad152a0b344d598a3dd512/contracts/contracts/Umbra.sol"><code>7cfdc81be65bb81e14ad152a0b344d598a3dd512</code></a> | April 7, 2021 | <code>contracts/contracts/Umbra.sol</code> |
| <a href="https://github.com/ScopeLift/umbra-protocol/blob/d6e4235fc143c0ac53c054aec7de4c4cdc01846c/contracts/contracts/Umbra.sol"><code>d6e4235fc143c0ac53c054aec7de4c4cdc01846c</code></a> | April 7, 2021 | <code>contracts/contracts/Umbra.sol</code> |

### Repository: <a href="https://github.com/ScopeLift/ens-resolvers"><code>ScopeLift/ens-resolvers</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/ScopeLift/ens-resolvers/blob/2d7795082308d303eb23c66490579a5b21a1bac9/contracts/profiles/StealthKeyResolver.sol"><code>2d7795082308d303eb23c66490579a5b21a1bac9</code></a> | March 19, 2021 | <code>contracts/profiles/StealthKeyResolver.sol</code> |

## Irrelevant reports

### Umbra-js Security Audit Report

- Report: [irrelevant/LeastAuthority_ScopeLift_Umbra-js_Final_Audit_Report.md](<reports/irrelevant/LeastAuthority_ScopeLift_Umbra-js_Final_Audit_Report.md>)
- Auditor: Least Authority TFA GmbH
- Date: 2021-05-25
- Description: Cryptographic review of umbra-js, the off-chain JavaScript/TypeScript client library implementing the Umbra stealth-address scheme for Node.js and browser Web3 applications. No on-chain smart contracts or zk circuits were in scope.
