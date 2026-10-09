# Audit source summary: _libs/agora

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Smart Contract Audit: Agora Governance (Trust Security)

- Report: [Trust Security - Agora Governor v1.0.md](<reports/Trust Security - Agora Governor v1.0.md>)
- Auditor: Trust Security
- Date: 2024-08-02
- Description: Trust Security manual audit of eight Agora Governor v1.0 contracts (AgoraGovernor, AgoraTimelock, ProxyAdmin, TokenDistributor, ProposalTypesConfigurator and the VotingModule, ApprovalVotingModule and OptimisticModule voting modules) at a pre-publication commit, followed by a mitigation review and a final review of the fixes. One High finding (TRST-H-1) whose first fix was insufficient and which was verified fixed at the final review hash.

### Repository: <a href="https://github.com/voteagora/agora-governor"><code>voteagora/agora-governor</code></a>

_Commit dates unavailable: 8 revision(s) have no timestamp._

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/voteagora/agora-governor/commit/286b6425bfcb76553170f2cac320f42f4ad67eda"><code>286b6425bfcb76553170f2cac320f42f4ad67eda</code></a> | — | <code>src/AgoraGovernor.sol</code><br><code>src/ProxyAdmin.sol</code><br><code>src/TokenDistributor.sol</code><br><code>src/AgoraTimelock.sol</code><br><code>src/ProposalTypesConfigurator.sol</code><br><code>src/modules/VotingModule.sol</code><br><code>src/modules/ApprovalVotingModule.sol</code><br><code>src/modules/OptimisticModule.sol</code> |
| <a href="https://github.com/voteagora/agora-governor/commit/29bb9c77ceb9ad5d9833c9e75154703d3d1fd908"><code>29bb9c77ceb9ad5d9833c9e75154703d3d1fd908</code></a> | — | <code>src/modules/ApprovalVotingModule.sol</code> |
| <a href="https://github.com/voteagora/agora-governor/commit/f46ff4924638a31683c14234a7b9b23383346984"><code>f46ff4924638a31683c14234a7b9b23383346984</code></a> | — | <code>src/modules/ApprovalVotingModule.sol</code> |
| <a href="https://github.com/voteagora/agora-governor/commit/2b0fa5bc2dc92b8583ccd6ccec080b1423f695b3"><code>2b0fa5bc2dc92b8583ccd6ccec080b1423f695b3</code></a> | — | <code>src/modules/ApprovalVotingModule.sol</code> |
| <a href="https://github.com/voteagora/agora-governor/commit/7146c62b5026291f668dc108fe954da297c4234b"><code>7146c62b5026291f668dc108fe954da297c4234b</code></a> | — | <code>src/modules/ApprovalVotingModule.sol</code> |
| <a href="https://github.com/voteagora/agora-governor/commit/e702019f259f236062855f37abf12b95b310746e"><code>e702019f259f236062855f37abf12b95b310746e</code></a> | — | <code>src/AgoraGovernor.sol</code><br><code>src/ProxyAdmin.sol</code><br><code>src/TokenDistributor.sol</code><br><code>src/AgoraTimelock.sol</code><br><code>src/ProposalTypesConfigurator.sol</code><br><code>src/modules/VotingModule.sol</code><br><code>src/modules/ApprovalVotingModule.sol</code><br><code>src/modules/OptimisticModule.sol</code> |
| <a href="https://github.com/voteagora/agora-governor/commit/71e0404569ce976c2dad5322ca2ad82ed702bfd5"><code>71e0404569ce976c2dad5322ca2ad82ed702bfd5</code></a> | — | <code>src/modules/ApprovalVotingModule.sol</code> |
| <a href="https://github.com/voteagora/agora-governor/commit/2c3d4a6c11a45d43d1e489fc00406e38df67ee0a"><code>2c3d4a6c11a45d43d1e489fc00406e38df67ee0a</code></a> | — | <code>src/AgoraGovernor.sol</code><br><code>src/ProxyAdmin.sol</code><br><code>src/TokenDistributor.sol</code><br><code>src/AgoraTimelock.sol</code><br><code>src/ProposalTypesConfigurator.sol</code><br><code>src/modules/VotingModule.sol</code><br><code>src/modules/ApprovalVotingModule.sol</code><br><code>src/modules/OptimisticModule.sol</code> |

## Agora Partial Delegation Audit (OpenZeppelin)

- Report: [OpenZeppelin - Agora Partial Delegation v1.0.0.md](<reports/OpenZeppelin - Agora Partial Delegation v1.0.0.md>)
- Auditor: OpenZeppelin
- Date: 2024-06-24
- Description: OpenZeppelin audit of Agora&#x27;s partial-delegation governance token contracts (ERC20VotesPartialDelegationUpgradeable, VotesPartialDelegationUpgradeable, L2GovToken and the IERC5805Modified and IVotesPartialDelegation interfaces) in the voteagora/ERC20VotesPartialDelegationUpgradeable repository, with per-finding fix commits from pull requests 57-67. No Critical, High or Medium issues were found.

### Repository: <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable"><code>voteagora/ERC20VotesPartialDelegationUpgradeable</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/92ffae9959d7cabe3ebe0378d24701aed31d9dd3"><code>92ffae9959d7cabe3ebe0378d24701aed31d9dd3</code></a> | June 10, 2024 | <code>src/ERC20VotesPartialDelegationUpgradeable.sol</code><br><code>src/IERC5805Modified.sol</code><br><code>src/IVotesPartialDelegation.sol</code><br><code>src/L2GovToken.sol</code><br><code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/ac5f5e5f6861f097620562eda2cd662407b6ccea"><code>ac5f5e5f6861f097620562eda2cd662407b6ccea</code></a> | July 1, 2024 | <code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/526d4ca8fa82e6b786ac871bef10660ab8a33995"><code>526d4ca8fa82e6b786ac871bef10660ab8a33995</code></a> | July 1, 2024 | <code>src/ERC20VotesPartialDelegationUpgradeable.sol</code><br><code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/1bd4d23d0e9a7852470858425c3d2d6124dde1a9"><code>1bd4d23d0e9a7852470858425c3d2d6124dde1a9</code></a> | July 1, 2024 | <code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/d3edd01109fe4c2619f3b274d2d9004920732ec1"><code>d3edd01109fe4c2619f3b274d2d9004920732ec1</code></a> | July 1, 2024 | <code>src/IVotesPartialDelegation.sol</code><br><code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/e5c64c9e17918bd13fc514c47276d6e9fa220c74"><code>e5c64c9e17918bd13fc514c47276d6e9fa220c74</code></a> | July 1, 2024 | <code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/ed615536a90197a48fd16d4ce81d812032278472"><code>ed615536a90197a48fd16d4ce81d812032278472</code></a> | July 1, 2024 | <code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/b61759119f898bdab33d2a24f9cc6f7107009057"><code>b61759119f898bdab33d2a24f9cc6f7107009057</code></a> | July 1, 2024 | <code>src/IVotesPartialDelegation.sol</code><br><code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/6676441c333e5c6f050ac04fdb6be4149eb69da8"><code>6676441c333e5c6f050ac04fdb6be4149eb69da8</code></a> | July 1, 2024 | <code>src/ERC20VotesPartialDelegationUpgradeable.sol</code><br><code>src/IVotesPartialDelegation.sol</code><br><code>src/L2GovToken.sol</code><br><code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/826e0d4255959f4184583f19d492acf170ec5890"><code>826e0d4255959f4184583f19d492acf170ec5890</code></a> | July 1, 2024 | <code>src/ERC20VotesPartialDelegationUpgradeable.sol</code><br><code>src/IVotesPartialDelegation.sol</code><br><code>src/L2GovToken.sol</code><br><code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/f21bc397498225a4777ef497a873c239c22c7889"><code>f21bc397498225a4777ef497a873c239c22c7889</code></a> | July 1, 2024 | <code>src/VotesPartialDelegationUpgradeable.sol</code> |
| <a href="https://github.com/voteagora/ERC20VotesPartialDelegationUpgradeable/commit/c88170013fed385076def23a005b768de59cbad2"><code>c88170013fed385076def23a005b768de59cbad2</code></a> | July 7, 2024 | <code>src/VotesPartialDelegationUpgradeable.sol</code> |
