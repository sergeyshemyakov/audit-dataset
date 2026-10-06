## `Customer : Right To Privacy` `Date :   November 2 nd, 2021`


## `This document may contain confidential information about IT` `systems and the intellectual property of the Customer as well as` `information about potential vulnerabilities and methods of their` `exploitation.` `The report containing confidential information can be used` `internally by the Customer, or it can be disclosed publicly after` `all vulnerabilities are fixed — upon a decision of the Customer.`

# **`Document`**

```
Name Smart Contract Code Review and Security Analysis Report for
          Right to Privacy.
Approved by Andrew Matiukhin | CTO Hacken OU
Type Privacy System Platform
Platform Ethereum / Solidity
Methods Architecture Review, Functional Testing, Computer-Aided
          Verification, Manual Review
Repository https://github.com/Railgun-Privacy/contract
Commit d2c63577ddd8310c87dced0d549cf9505b372111
Technical NO
Documentation

JS tests YES
Website righttoprivacy.foundation
Timeline 25 OCTOBER 2021 – 02 NOVEMBER 2021
Changelog  02 NOVEMBER 2021 – INITIAL AUDIT

                www.hacken.io

```

# **`Table of contents`**

`Introduction` 4


`Scope` 4


`Executive Summary` 5


`Severity Definitions` 7


`Audit overview` 8


`Conclusion` 11


`Disclaimers` 12

```
                www.hacken.io

```

# **`Introduction`**

```
Hacken OÜ (Consultant) was contracted by Right to Privacy (Customer) to
conduct a Smart Contract Code Review and Security Analysis. This report
presents the findings of the security assessment of the Customer's smart
contract and its code review conducted between October 25 th, 2021 November 2 nd, 2021.

# **`Scope`**

```

```
The scope of the project is smart contracts in the repository:
Repository:

```

```
   https://github.com/Railgun-Privacy/contract
Commit:

```

```
   d2c63577ddd8310c87dced0d549cf9505b372111
Technical Documentation: No
JS tests: Yes (included: “/test/”)
Contracts:

```

```
governance/Delegator.sol
governance/Deployer.sol
governance/Staking.sol
governance/Voting.sol
logic/Commitments.sol
logic/Globals.sol
logic/Poseidon.sol
logic/RailgunLogic.sol
logic/Snark.sol
logic/TokenWhitelist.sol
logic/Verifier.sol
proxy/Proxy.sol
proxy/ProxyAdmin.sol
teststubs/governance/Getter.sol
teststubs/governance/GovernanceTarget.sol
teststubs/governance/StakingStub.sol
teststubs/logic/CommitmentsStub.sol
teststubs/logic/TokenWhitelistStub.sol
teststubs/proxy/ProxyTarget.sol
teststubs/TokenStubs.sol
token/Distributor.sol
token/Multisend.sol
token/VestLock.sol
treasury/Treasury.sol

             www.hacken.io

```

```
We have scanned this smart contract for commonly known and more specific
vulnerabilities. Here are some of the commonly known vulnerabilities that
are considered:

  Category Check Item
 Code review
## ▪ Reentrancy ▪ Ownership Takeover ▪ Timestamp Dependence ▪ Gas Limit and Loops ▪ DoS with (Unexpected) Throw ▪ DoS with Block Gas Limit ▪ Transaction-Ordering Dependence ▪ Style guide violation ▪ Costly Loop ▪ ERC20 API violation ▪ Unchecked external call ▪ Unchecked math ▪ Unsafe type inference ▪ Implicit visibility level ▪ Deployment Consistency ▪ Repository Consistency ▪ Data Consistency

 Functional review
## ▪ Business Logics Review ▪ Functionality Checks ▪ Access Control & Authorization ▪ Escrow manipulation ▪ Token Supply manipulation ▪ Assets integrity ▪ User Balances manipulation ▪ Data Consistency manipulation ▪ Kill-Switch Mechanism ▪ Operation Trails & Event Generation

# **`Executive Summary`**

According to the assessment, the Customer's smart contracts are secured but
some functions could run out of gas.

 Insecure    Poor secured         Secured        Well-secured

             You are here

                www.hacken.io

```

```
Our team performed an analysis of code functionality, manual audit, and
automated checks with Mythril and Slither. All issues found during automated
analysis were manually reviewed, and important vulnerabilities are presented
in the Audit overview section. All found issues can be found in the Audit
overview section.

As a result of the audit, security engineers found 2 medium and 2 low severity
issues.

     Graph 1. The distribution of vulnerabilities after the audit.

                www.hacken.io

```

# **`Severity Definitions`**

```
  Risk Level Description

```

```
Critical

 High

 Medium

 Low

```

```
Critical vulnerabilities are usually straightforward to
exploit and can lead to assets loss or data
manipulations.
High-level vulnerabilities are difficult to exploit;
however, they also have a significant impact on smart
contract execution, e.g., public access to crucial
functions
Medium-level vulnerabilities are important to fix;
however, they can't lead to assets loss or data
manipulations.
Low-level vulnerabilities are mostly related to
outdated, unused, etc. code snippets that can't have
a significant impact on execution

      www.hacken.io

```

# **`Audit overview`**

## **`Critical`**

```
   No critical issues were found.

## **`High`**

   No high severity issues were found.

## **`Medium`**

   1. One test failed

   While 41 tests are passing but 1 is failing. It fails with the “Out of
   Gas” message which means your logic could be too complicated and
   overloaded with loops, maths, and external calls.

   ....

   Contracts : RailgunLogic.sol

   Recommendation : Please check the functionality of the RailgunLogic and
   make sure you’re not running out of gas and all tests are passing.

   2. Too low test coverage

   Global test coverage is about 68% for code branches, while the main
   RailgunLogic contract is covered only for 57.89% of logic branches.

   The recommended coverage is minimum 95% for branches, while it should
   be definitely 100% for the main logic contracts.

                www.hacken.io

```

```
  Contracts : Commitments.sol, RailgunLogic.sol, Snark.sol,
  TokenWhitelist.sol, Verifier.sol, Delegator.sol

  Recommendation : Please make sure you have at least 95% of overall code
  branches covered by tests and to have 100% branches coverage for the
  main business logic code.

## **`Low`**
               www.hacken.io

```

```
1. Missing zero address validation

Accidentally setting “_vestLockImplementation” to zero-address could
lead to contract out of work because it doesn’t have the ability to
update it in any way.

Contracts : Distributor.sol

Function : constructor

Recommendation : Please check “_vestLockImplementation” for being zero
address.

2. A public function that could be declared external

public functions that are never called by the contract should be
declared external to save gas.

Contracts : Multisend.sol

Function : multisend

Recommendation : Use the external attribute for functions never called
from the contract.

             www.hacken.io

```

# **`Conclusion`**

```
Smart contracts within the scope were manually reviewed and analyzed with
static analysis tools.

The audit report contains all found security vulnerabilities and other issues
in the reviewed code.

As a result of the audit, security engineers found 2 medium and 2 low severity
issues.

                www.hacken.io

```

# **`Disclaimers`**

## **`Hacken Disclaimer`**

```
The smart contracts given for audit have been analyzed in accordance with
the best industry practices at the date of this report, in relation to
cybersecurity vulnerabilities and issues in smart contract source code, the
details of which are disclosed in this report (Source Code); the Source Code
compilation, deployment, and functionality (performing the intended
functions).

The audit makes no statements or warranties on the security of the code. It
also cannot be considered as a sufficient assessment regarding the utility
and safety of the code, bug-free status, or any other statements of the
contract. While we have done our best in conducting the analysis and producing
this report, it is important to note that you should not rely on this report
only — we recommend proceeding with several independent audits and a public
bug bounty program to ensure the security of smart contracts.

## **`Technical Disclaimer`**

Smart contracts are deployed and executed on a blockchain platform. The
platform, its programming language, and other software related to the smart
contract can have vulnerabilities that can lead to hacks. Thus, the audit
can't guarantee the explicit security of the audited smart contracts.

                www.hacken.io

```

