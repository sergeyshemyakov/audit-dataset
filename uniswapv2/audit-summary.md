# Audit source summary: uniswapv2

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC). Paths are EVM contracts unless marked zk, cairo or other.

## Uniswap V2 Audit Report

- Report: [dapp.org - Uniswap V2 Audit Report.md](<reports/dapp.org - Uniswap V2 Audit Report.md>)
- Auditor: dapp.org
- Date: 2020-05-06
- Description: dapp.org code review, numerical error analysis and K-framework formal verification (act specifications of UniswapV2Pair and UniswapV2Factory) of the Uniswap V2 core contracts in uniswap-v2-core at commit 8160750, where all core issues found during the January-April 2020 engagement were addressed, plus a cursory best-effort review of the uniswap-v2-periphery contracts (UniswapV2Router01) while they were still under development on master. Two Medium-severity bugs (a liquidity-deflation race condition in the Pair, whose fix the findings table attributes to core commit cbe801b5, and the Router&#x27;s incompatibility with fee-on-transfer tokens) and one Low bug were found; no Major/Critical findings.

### Repository: <a href="https://github.com/Uniswap/v2-core"><code>Uniswap/v2-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/v2-core/tree/816075049f811f1b061bca81d5d040b96f4c07eb/contracts"><code>816075049f811f1b061bca81d5d040b96f4c07eb</code></a> | April 22, 2020 | <code>contracts</code> (recursive directory) |

### Repository: <a href="https://github.com/Uniswap/v2-periphery"><code>Uniswap/v2-periphery</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/v2-periphery/tree/master/contracts"><code>master</code></a> (mutable branch) | — | <code>contracts</code> (recursive directory) |
