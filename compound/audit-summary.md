# Audit source summary: compound

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Compound Finance - Timelock Audit

- Report: [OpenZeppelin - Compound Timelock Audit.md](<reports/OpenZeppelin - Compound Timelock Audit.md>)
- Auditor: OpenZeppelin
- Date: 2019-10-23
- Description: OpenZeppelin diff audit of the Compound patch between commits f385d71 and f244c22 that introduced the Timelock contract and the Comptroller pauseGuardian role, with a fix review at commit 681833a. Timelock is a new file in the patch and is therefore fully covered; the other scoped contracts are covered only for their changes.

### Repository: <a href="https://github.com/compound-finance/compound-protocol"><code>compound-finance/compound-protocol</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/compound-finance/compound-protocol/blob/f244c2270f905287cb731d8fd3693ac77f8404f9/contracts/CErc20.sol"><code>f244c2270f905287cb731d8fd3693ac77f8404f9</code></a> | October 7, 2019 | <code>contracts/CErc20.sol</code><br><code>contracts/CEther.sol</code><br><code>contracts/CToken.sol</code><br><code>contracts/Comptroller.sol</code><br><code>contracts/ComptrollerStorage.sol</code><br><code>contracts/ErrorReporter.sol</code><br><code>contracts/Exponential.sol</code><br><code>contracts/Timelock.sol</code><br><code>contracts/Unitroller.sol</code> |
| <a href="https://github.com/compound-finance/compound-protocol/blob/681833a557a282fba5441b7d49edb05153bb28ec/contracts/CToken.sol"><code>681833a557a282fba5441b7d49edb05153bb28ec</code></a> | October 12, 2019 | <code>contracts/CToken.sol</code><br><code>contracts/Comptroller.sol</code><br><code>contracts/Timelock.sol</code> |

## Compound Alpha Governance System Audit

- Report: [OpenZeppelin - Compound Alpha Governance System Audit.md](<reports/OpenZeppelin - Compound Alpha Governance System Audit.md>)
- Auditor: OpenZeppelin
- Date: 2020-02-25
- Description: OpenZeppelin audit of the Compound Governance Token (COMP) and Governor Alpha contracts at commit 6858417, with a follow-up review of commit f5976a8 that fixed H02; H01 (unbounded number of proposal actions) stays open. The report cites the private compound-protocol-alpha repository, but both commits are reachable in the public compound-finance/compound-protocol repository, which is where the scope is recorded.

### Repository: <a href="https://github.com/compound-finance/compound-protocol-alpha"><code>compound-finance/compound-protocol-alpha</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

### Repository: <a href="https://github.com/compound-finance/compound-protocol"><code>compound-finance/compound-protocol</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/compound-finance/compound-protocol/blob/6858417c91921208c0b3ff342b11065c09665b1b/contracts/Governance/Comp.sol"><code>6858417c91921208c0b3ff342b11065c09665b1b</code></a> | January 16, 2020 | <code>contracts/Governance/Comp.sol</code><br><code>contracts/Governance/GovernorAlpha.sol</code> |
| <a href="https://github.com/compound-finance/compound-protocol/blob/f5976a8a1dcf4e14e435e5581bade8ef6b5d38ea/contracts/Governance/Comp.sol"><code>f5976a8a1dcf4e14e435e5581bade8ef6b5d38ea</code></a> | January 23, 2020 | <code>contracts/Governance/Comp.sol</code><br><code>contracts/Governance/GovernorAlpha.sol</code> |

## Compound Governance Security Assessment

- Report: [Trail of Bits - Compound Governance.md](<reports/Trail of Bits - Compound Governance.md>)
- Auditor: Trail of Bits
- Date: 2020-02-28
- Description: Trail of Bits review of the Compound Governance Token (Comp.sol) and GovernorAlpha.sol, including their interactions with Timelock.sol, at commit 55729b3 (version 2.5-rc1) of the compound-protocol-alpha repository; three informational findings. The commit is reachable in the public compound-finance/compound-protocol repository, where the scope is recorded.

### Repository: <a href="https://github.com/compound-finance/compound-protocol-alpha"><code>compound-finance/compound-protocol-alpha</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| _None recorded_ | — | _None recorded_ |

### Repository: <a href="https://github.com/compound-finance/compound-protocol"><code>compound-finance/compound-protocol</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/compound-finance/compound-protocol/blob/55729b31b85220ab42e26d7b6db0ff6c0eb0dd23/contracts/Governance/Comp.sol"><code>55729b31b85220ab42e26d7b6db0ff6c0eb0dd23</code></a> | February 8, 2020 | <code>contracts/Governance/Comp.sol</code><br><code>contracts/Governance/GovernorAlpha.sol</code><br><code>contracts/Timelock.sol</code> |

## Compound Governor Bravo Audit

- Report: [OpenZeppelin - Compound Governor Bravo Audit.md](<reports/OpenZeppelin - Compound Governor Bravo Audit.md>)
- Auditor: OpenZeppelin
- Date: 2021-02-12
- Description: OpenZeppelin audit of Compound&#x27;s upgradeable Governor Bravo governance (GovernorBravoDelegate, GovernorBravoDelegator and GovernorBravoInterfaces) at commit f86c247 of pull request #91, with no critical or high severity findings. Fixes for the medium and lower findings were reviewed as pull requests #4 to #10 in the Arr00-Blurr/compound-protocol fork.

### Repository: <a href="https://github.com/compound-finance/compound-protocol"><code>compound-finance/compound-protocol</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/compound-finance/compound-protocol/blob/f86c247f6f81e14f8e0fd78402653a0b8371266a/contracts/Governance/GovernorBravoDelegate.sol"><code>f86c247f6f81e14f8e0fd78402653a0b8371266a</code></a> | January 26, 2021 | <code>contracts/Governance/GovernorBravoDelegate.sol</code><br><code>contracts/Governance/GovernorBravoDelegator.sol</code><br><code>contracts/Governance/GovernorBravoInterfaces.sol</code> |

### Repository: <a href="https://github.com/Arr00-Blurr/compound-protocol"><code>Arr00-Blurr/compound-protocol</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Arr00-Blurr/compound-protocol/blob/a3f69611180ee008cffd4048ce9137271bfe1a83/contracts/Governance/GovernorBravoDelegator.sol"><code>a3f69611180ee008cffd4048ce9137271bfe1a83</code></a> | February 15, 2021 | <code>contracts/Governance/GovernorBravoDelegator.sol</code> |
| <a href="https://github.com/Arr00-Blurr/compound-protocol/blob/feb7f5aa204e644fbe2dcb5cf30664acded9df09/contracts/Governance/GovernorBravoDelegate.sol"><code>feb7f5aa204e644fbe2dcb5cf30664acded9df09</code></a> | February 16, 2021 | <code>contracts/Governance/GovernorBravoDelegate.sol</code> |
| <a href="https://github.com/Arr00-Blurr/compound-protocol/blob/413fce0c4e3b97f80465000354ef8f4091c2de81/contracts/Governance/GovernorBravoInterfaces.sol"><code>413fce0c4e3b97f80465000354ef8f4091c2de81</code></a> | February 17, 2021 | <code>contracts/Governance/GovernorBravoInterfaces.sol</code> |
| <a href="https://github.com/Arr00-Blurr/compound-protocol/blob/2da44f2ef1fadf4359b2469c31af3cab95553637/contracts/Governance/GovernorBravoDelegate.sol"><code>2da44f2ef1fadf4359b2469c31af3cab95553637</code></a> | February 18, 2021 | <code>contracts/Governance/GovernorBravoDelegate.sol</code> |
| <a href="https://github.com/Arr00-Blurr/compound-protocol/blob/ac040f9f462bfc80c4b5817c062267e34285b087/contracts/Governance/GovernorBravoDelegator.sol"><code>ac040f9f462bfc80c4b5817c062267e34285b087</code></a> | February 23, 2021 | <code>contracts/Governance/GovernorBravoDelegator.sol</code><br><code>contracts/Governance/GovernorBravoDelegate.sol</code> |
| <a href="https://github.com/Arr00-Blurr/compound-protocol/blob/bd807558a01f74ade300366b4e96b6c9ce6dd3cc/contracts/Governance/GovernorBravoDelegate.sol"><code>bd807558a01f74ade300366b4e96b6c9ce6dd3cc</code></a> | February 23, 2021 | <code>contracts/Governance/GovernorBravoDelegate.sol</code> |
| <a href="https://github.com/Arr00-Blurr/compound-protocol/blob/149849ddc9528b5675ab5937a2abd4f0b8995e68/contracts/Governance/GovernorBravoDelegate.sol"><code>149849ddc9528b5675ab5937a2abd4f0b8995e68</code></a> | February 23, 2021 | <code>contracts/Governance/GovernorBravoDelegate.sol</code> |
