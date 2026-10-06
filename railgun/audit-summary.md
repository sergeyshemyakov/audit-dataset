# Audit source summary: railgun

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Smart Contract Audit Railgun: Circom and Solidity

- Report: [2021_07-abdk-railgun-circom-and-solidity-audit.md](<reports/2021_07-abdk-railgun-circom-and-solidity-audit.md>)
- Auditor: ABDK Consulting
- Date: 2021-07-02
- Description: ABDK audit of the RAILGUN V1 logic contracts (Commitments, RailgunLogic, Snark, TokenWhitelist, Types, Verifier) and the JoinSplit circom circuits for fund safety and privacy. Version 2.0 of the report includes the client comments and the fix status for release v0.0.1.

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/6281cb0dac6a6e0da743e3ba56c437803657872d"><code>6281cb0dac6a6e0da743e3ba56c437803657872d</code></a> | May 26, 2021 | <code>contracts/logic/Commitments.sol</code><br><code>contracts/logic/Poseidon.sol</code> (explicitly not audited)<br><code>contracts/logic/RailgunLogic.sol</code><br><code>contracts/logic/Snark.sol</code><br><code>contracts/logic/TokenWhitelist.sol</code><br><code>contracts/logic/Types.sol</code><br><code>contracts/logic/Verifier.sol</code> |
| <a href="https://github.com/Railgun-Privacy/contract/releases/tag/v0.0.1"><code>v0.0.1</code></a> (unresolved tag) | — | <code>contracts/logic/Commitments.sol</code><br><code>contracts/logic/RailgunLogic.sol</code><br><code>contracts/logic/Snark.sol</code><br><code>contracts/logic/TokenWhitelist.sol</code><br><code>contracts/logic/Verifier.sol</code> |

### Repository: <a href="https://github.com/Railgun-Privacy/circuits"><code>Railgun-Privacy/circuits</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/circuits/commit/2c3c3144635f72d3e1b7dd8d1f9c722c8ae3ff68"><code>2c3c3144635f72d3e1b7dd8d1f9c722c8ae3ff68</code></a> | — | <code>circuits/base/HashInputs.circom</code><br><code>circuits/base/MerkleTree.circom</code><br><code>circuits/JoinSplit.circom</code><br><code>circuits/Large.circom</code><br><code>circuits/Small.circom</code> |
| <a href="https://github.com/Railgun-Privacy/circuits/releases/tag/v0.0.1"><code>v0.0.1</code></a> (unresolved tag) | — | <code>circuits/base/HashInputs.circom</code><br><code>circuits/base/MerkleTree.circom</code><br><code>circuits/JoinSplit.circom</code><br><code>circuits/Large.circom</code><br><code>circuits/Small.circom</code> |

## Smart Contract Code Review and Security Analysis Report for Right to Privacy

- Report: [2021_11-hacken-railgun-smart-contracts-audit.md](<reports/2021_11-hacken-railgun-smart-contracts-audit.md>)
- Auditor: Hacken
- Date: 2021-11-02
- Description: Hacken code review of the RAILGUN governance, logic, proxy, token, treasury and test stub contracts at a single commit. It is an initial audit only and reports two medium (failing test, low test coverage) and two low findings.

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/d2c63577ddd8310c87dced0d549cf9505b372111"><code>d2c63577ddd8310c87dced0d549cf9505b372111</code></a> | August 10, 2021 | <code>contracts/governance/Delegator.sol</code><br><code>contracts/governance/Deployer.sol</code><br><code>contracts/governance/Staking.sol</code><br><code>contracts/governance/Voting.sol</code><br><code>contracts/logic/Commitments.sol</code><br><code>contracts/logic/Globals.sol</code><br><code>contracts/logic/Poseidon.sol</code><br><code>contracts/logic/RailgunLogic.sol</code><br><code>contracts/logic/Snark.sol</code><br><code>contracts/logic/TokenWhitelist.sol</code><br><code>contracts/logic/Verifier.sol</code><br><code>contracts/proxy/Proxy.sol</code><br><code>contracts/proxy/ProxyAdmin.sol</code><br><code>contracts/teststubs/governance/Getter.sol</code><br><code>contracts/teststubs/governance/GovernanceTarget.sol</code><br><code>contracts/teststubs/governance/StakingStub.sol</code><br><code>contracts/teststubs/logic/CommitmentsStub.sol</code><br><code>contracts/teststubs/logic/TokenWhitelistStub.sol</code><br><code>contracts/teststubs/proxy/ProxyTarget.sol</code><br><code>contracts/teststubs/TokenStubs.sol</code><br><code>contracts/token/Distributor.sol</code><br><code>contracts/token/Multisend.sol</code><br><code>contracts/token/VestLock.sol</code><br><code>contracts/treasury/Treasury.sol</code> |

## RAILGUN Smart Contract Audit

- Report: [2021_11-zokyo-railgun-contracts-audit.md](<reports/2021_11-zokyo-railgun-contracts-audit.md>)
- Auditor: Zokyo
- Date: 2021-11-03
- Description: Zokyo audit of the RAILGUN V1 governance, logic, proxy, token and treasury contracts at a single commit, with additional test coverage written by the auditors. Only one low and three informational issues were found, all left unresolved because the contracts were already deployed.

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/d2c63577ddd8310c87dced0d549cf9505b372111"><code>d2c63577ddd8310c87dced0d549cf9505b372111</code></a> | August 10, 2021 | <code>contracts/governance/Delegator.sol</code><br><code>contracts/governance/Deployer.sol</code><br><code>contracts/governance/Staking.sol</code><br><code>contracts/governance/Voting.sol</code><br><code>contracts/logic/Commitments.sol</code><br><code>contracts/logic/Globals.sol</code><br><code>contracts/logic/Poseidon.sol</code><br><code>contracts/logic/RailgunLogic.sol</code><br><code>contracts/logic/Snark.sol</code><br><code>contracts/logic/TokenWhitelist.sol</code><br><code>contracts/logic/Verifier.sol</code><br><code>contracts/proxy/Proxy.sol</code><br><code>contracts/proxy/ProxyAdmin.sol</code><br><code>contracts/token/Distributor.sol</code><br><code>contracts/token/Multisend.sol</code><br><code>contracts/token/VestLock.sol</code><br><code>contracts/treasury/Treasury.sol</code> |

## RAILGUN Smart Contract Audit

- Report: [2021_11-zokyo-railgun-logic-commitments-audit.md](<reports/2021_11-zokyo-railgun-logic-commitments-audit.md>)
- Auditor: Zokyo
- Date: 2021-11-23
- Description: Zokyo audit of the RAILGUN Commitments, Globals and RailgunLogic contracts after the batch transaction upgrade, with a re-audit of the fixes at the last commit. The one low and one informational issue were resolved.

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/0418a0f1bf0e58e5b3bab8870112b7648ff20aca"><code>0418a0f1bf0e58e5b3bab8870112b7648ff20aca</code></a> | October 10, 2021 | <code>contracts/logic/Commitments.sol</code><br><code>contracts/logic/Globals.sol</code><br><code>contracts/logic/RailgunLogic.sol</code> |
| <a href="https://github.com/Railgun-Privacy/contract/commit/97af307fa1d737d4526323acc3d0ef372c703417"><code>97af307fa1d737d4526323acc3d0ef372c703417</code></a> | November 20, 2021 | <code>contracts/logic/Commitments.sol</code><br><code>contracts/logic/Globals.sol</code><br><code>contracts/logic/RailgunLogic.sol</code> |

## Railgun Smart Contract Audit

- Report: [2022_04-zokyo-railgun-logic-audit.md](<reports/2022_04-zokyo-railgun-logic-audit.md>)
- Auditor: Zokyo
- Date: 2022-04-20
- Description: Zokyo review of the RAILGUN privacy pool logic contracts (Globals, Snark, Commitments, Verifier, Poseidon, TokenBlacklist, RailgunLogic) at a single commit. Only two informational findings were reported, both left unresolved.

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/62401e1a64b9af968d85b8f5347f1a72cc56862c"><code>62401e1a64b9af968d85b8f5347f1a72cc56862c</code></a> | April 18, 2022 | <code>contracts/logic/Globals.sol</code><br><code>contracts/logic/Snark.sol</code><br><code>contracts/logic/Commitments.sol</code><br><code>contracts/logic/Verifier.sol</code><br><code>contracts/logic/Poseidon.sol</code><br><code>contracts/logic/TokenBlacklist.sol</code><br><code>contracts/logic/RailgunLogic.sol</code> |

## RAIL Token Smart Contract Audit

- Report: [2022_04-zokyo-rail-token-audit.md](<reports/2022_04-zokyo-rail-token-audit.md>)
- Auditor: Zokyo
- Date: 2022-04-21
- Description: Zokyo audit of the RAIL governance token contract (Rail.sol), with the source taken from the verified Etherscan code of the deployed token rather than from a git repository. It checks the anti-bot transfer lock and the governance-only minting up to the cap, and found one informational issue.

### Repository: <a href="https://etherscan.io/address/0xe76c6c83af64e4c60245d8c7de953df673a7a33d#code"><code>etherscan.io/address/0xe76c6c83af64e4c60245d8c7de953df673a7a33d</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

## Railgun v2 Circuits and Governance Review

- Report: [2022_08-hashcloak-railgun-v2-circuits-and-governance-review.md](<reports/2022_08-hashcloak-railgun-v2-circuits-and-governance-review.md>)
- Auditor: HashCloak
- Date: 2022-08-29
- Description: HashCloak review of the RAILGUN v2 circom circuits (March 2022) and of the GovernorRewards and Voting Solidity contracts (August 2022). It reports 3 High, 1 Low and 3 Informational findings, all stated as resolved without a fix commit.

### Repository: <a href="https://github.com/Railgun-Privacy/circuits-v2"><code>Railgun-Privacy/circuits-v2</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/circuits-v2/commit/67cd4ce7f49afd1dfae67c8e2d59ddf87ec3de43"><code>67cd4ce7f49afd1dfae67c8e2d59ddf87ec3de43</code></a> | March 18, 2022 | <code>src</code> (recursive directory) |

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/b74eeb69ca2614212c8060a3460fd05c28bb17e3"><code>b74eeb69ca2614212c8060a3460fd05c28bb17e3</code></a> | August 22, 2022 | <code>contracts/governance/Voting.sol</code><br><code>contracts/treasury/GovernorRewards.sol</code> |

## RAILGUN Smart Contract Audit (Voting)

- Report: [2022_09-zokyo-railgun-voting-audit.md](<reports/2022_09-zokyo-railgun-voting-audit.md>)
- Auditor: Zokyo
- Date: 2022-09-14
- Description: Zokyo review of the RAILGUN governance Voting contract. Only low and informational findings were reported, which were resolved or acknowledged after a fix review.

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/d73c1da62c624fe083417342ce3e64748572bde9"><code>d73c1da62c624fe083417342ce3e64748572bde9</code></a> | — | <code>contracts/governance/Voting.sol</code> |

## Railgun Smart Contract Audit (RailgunSmartWallet)

- Report: [2022_12-zokyo-railgun-smart-wallet-audit.md](<reports/2022_12-zokyo-railgun-smart-wallet-audit.md>)
- Auditor: Zokyo
- Date: 2022-12-21
- Description: Zokyo review of the RAILGUN V2 logic upgrade: Commitments, RailgunLogic and the new RailgunSmartWallet contract. Medium and informational findings were reported, with the Medium ones resolved.

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/4385ec73bf7d0da283123e8a3ac3900216cfc3f0"><code>4385ec73bf7d0da283123e8a3ac3900216cfc3f0</code></a> | November 12, 2022 | <code>contracts/logic/Commitments.sol</code><br><code>contracts/logic/RailgunLogic.sol</code><br><code>contracts/logic/RailgunSmartWallet.sol</code> |

## Railgun Smart Contract Audit (Arbitrum L1-L2 Governance)

- Report: [2023_02-zokyo-railgun-arbitrum-l1-l2-governance-audit.md](<reports/2023_02-zokyo-railgun-arbitrum-l1-l2-governance-audit.md>)
- Auditor: Zokyo
- Date: 2023-02-03
- Description: Zokyo review of the Sender (Ethereum) and Executor (Arbitrum) contracts that relay RAILGUN governance tasks from L1 to L2. Medium, low and informational findings were reported and mostly resolved.

### Repository: <a href="https://github.com/Railgun-Privacy/contract"><code>Railgun-Privacy/contract</code></a>

_Commit dates unavailable: 1 commit(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Railgun-Privacy/contract/commit/a49a82d1589426ece9f6b463c51635002f542e65"><code>a49a82d1589426ece9f6b463c51635002f542e65</code></a> | January 24, 2023 | <code>contracts/governance/arbitrum/Sender.sol</code><br><code>contracts/governance/arbitrum/Executor.sol</code> |
