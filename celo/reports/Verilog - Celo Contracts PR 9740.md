> Copyright © 2022 by Verilog Solutions. All rights reserved.
>
> Sept 20, 2022
>
> by **Verilog Solutions**

This report presents our engineering engagement with the Celo dev team on the Celo contracts audit for [PR#9740](https://github.com/celo-org/celo-monorepo/pull/9740).

|  |  |
| --- | --- |
| Project Name | Celo Contracts Audit - PR#9740 |
| Repository Link | <https://github.com/celo-org/celo-monorepo> |
| Commit | [PR#9740](https://github.com/celo-org/celo-monorepo/pull/9740) up to commit [4bf959b](https://github.com/celo-org/celo-monorepo/commit/4bf959b1fde04aa953ffdb54d17c9b915e08bada) |
| Language | Solidity |
| Chain | Celo |

## About Verilog Solutions

Founded by a group of cryptography researchers and smart contract engineers in North America, Verilog Solutions elevates the security standards for Web3 ecosystems by being a full-stack Web3 security firm covering smart contract security, consensus security, and operational security for Web3 projects.

Verilog Solutions team works closely with major ecosystems and Web3 projects and applies a quality above quantity approach with a continuous security model. Verilog Solutions onboards the best and most innovative projects and provides the best-in-class advisory services on security needs, including on-chain and off-chain components.

## Table of Contents

## Audit Scope

| File |
| --- |
| packages/protocol/contracts/identity/interfaces/IOdisPayments.sol |
| packages/protocol/contracts/identity/OdisPayments.sol |
| packages/protocol/contracts/identity/proxies/OdisPaymentsProxy.sol |

## ****Findings & Improvement Suggestions****

|  |  |  |  |
| --- | --- | --- | --- |
| Severity | **Total** | **Acknowledged** | **Resolved** |
| **High** | 0 | 0 | 0 |
| **Medium** | 1 | 1 | 0 |
| **Low** | 0 | 0 | 0 |
| **Informational** | 1 | 1 | 1 |

### High

None ; )

### Medium

1. **Locked funds**

   |  |  |
   | --- | --- |
   | **Severity** | **Medium** |
   | **Source** | packages/protocol/contracts/identity/OdisPayments.sol#L63; |
   | Commit | [PR #9740](https://github.com/celo-org/celo-monorepo/commit/1452cccf55a506454f6fec72d268b78121c027cd); |
   | **Status** | **Acknowledged;** |

   * **Description**

     Function `OdisPayments.payInCUSD()` allows users to transfer tokens to the contract but there are no other functions to withdraw them out of the contract. This causes tokens to get locked in the contract.

     The function `OdisPayments.payInCUSD()` let users send `cUSD` to the contract to pay for ODIS quota. Anyone can call this function to transfer `cUSD` to this contract and the mapping that tracks each address paid amount will be updated. However, there is no function in this contract that allows people to retrieve the tokens that are sent to the contract. `cUSD` will be locked in the contract.
   * **Exploit Scenario**
     1. Alice calls the `payInCUSD()` function to pay for her ODIS quota;
     2. She sends 3 `cUSD` to the contract;
     3. Now, no one is able to retrieve those tokens.
   * **Recommendations**

     Add a function that can retrieve tokens.
   * **Results**

     **Acknowledged.**

     Response from the ODIS team:

     > “*The goal of this contract is to track all-time payments made from anyone, which will then be used to calculate quota by the ODIS service off-chain. We may upgrade the contract in the future to allow for transferring funds elsewhere, but for our purposes now, we want to essentially not allow any funds to flow out.”*

### Low

None ; )

### Informational

1. **Magic Numbers**

   |  |  |
   | --- | --- |
   | **Severity** | **Informational** |
   | **Source** | packages/protocol/contracts/identity/OdisPayments.sol#L46; |
   | Commit | [PR #9740](https://github.com/celo-org/celo-monorepo/commit/1452cccf55a506454f6fec72d268b78121c027cd); |
   | **Status** | **Resolved** in commit [4bf959b](https://github.com/celo-org/celo-monorepo/commit/4bf959b1fde04aa953ffdb54d17c9b915e08bada); |

   * **Description**

     Function `getVersionNumber()` returns some magic numbers. Those magic numbers can be replaced by constants for better understanding.
   * **Exploit Scenario**

     N/A.
   * **Recommendations**

     Define those magic numbers using the `constant` keyword.
   * **Results**

     **Resolved** in commit [4bf959b](https://github.com/celo-org/celo-monorepo/commit/4bf959b1fde04aa953ffdb54d17c9b915e08bada), the`getVersionNumber()` function is deprecated.

## Appendix I: Severity Categories

| **Severity** | **Description** |
| --- | --- |
| **High** | Issues that are highly exploitable security vulnerabilities. It may cause direct loss of funds / permanent freezing of funds. All high severity issues should be resolved. |
| **Medium** | Issues that are only exploitable under some conditions or with some privileged access to the system. Users’ yields/rewards/information is at risk. All medium severity issues should be resolved unless there is a clear reason not to. |
| **Low** | Issues that are low risk. Not fixing those issues will not result in the failure of the system. A fix on low severity issues is recommended but subject to the clients’ decisions. |
| **Informational** | Issues that pose no risk to the system and are related to the security best practices. Not fixing those issues will not result in the failure of the system. A fix on informational issues or adoption of those security best practices-related suggestions is recommended but subject to clients’ decision. |

## Appendix II: Status Categories

| **Status** | **Description** |
| --- | --- |
| **Unresolved** | The issue is not acknowledged and not resolved. |
| **Partially Resolved** | The issue has been partially resolved. |
| **Acknowledged** | The Finding / Suggestion is acknowledged but not fixed / not implemented. |
| **Resolved** | The issue has been sufficiently resolved. |

## Disclaimer

Verilog Solutions receives compensation from one or more clients for performing the smart contract and auditing analysis contained in these reports. The report created is solely for Clients and published with their consent. As such, the scope of our audit is limited to a review of code, and only the code we note as being within the scope of our audit is detailed in this report. It is important to note that the Solidity code itself presents unique and unquantifiable risks since the Solidity language itself remains under current development and is subject to unknown risks and flaws. Our sole goal is to help reduce the attack vectors and the high level of variance associated with utilizing new and consistently changing technologies. Thus, Verilog Solutions in no way claims any guarantee of security or functionality of the technology we agree to analyze.

In addition, Verilog Solutions reports do not provide any indication of the technologies proprietors, business, business model, or legal compliance. As such, reports do not provide investment advice and should not be used to make decisions about investment or involvement with any particular project. Verilog Solutions has the right to distribute the Report through other means, including via Verilog Solutions publications and other distributions. Verilog Solutions makes the reports available to parties other than the Clients (*i.e.*, "third parties") – on its website in hopes that it can help the blockchain ecosystem develop technical best practices in this rapidly evolving area of innovation.