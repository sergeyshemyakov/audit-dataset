# **Coinbase: base contracts**
## **Security Review**

### Cantina Managed review by: Red Swan, Lead Security Researcher MostafaYassin, Security Researcher September 2, 2026


#### **Contents**

**1** **Introduction** **2**
1.1 About Cantina . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.2 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3 Risk assessment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3.1 Severity Classification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2


**2** **Security Review Summary** **3**
2.1 Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3


**3** **Overview** **3**


**4** **Additional Comments** **3**


1


#### **1 Introduction**

**1.1** **About Cantina**


Cantina is a security services marketplace that connects top security researchers and solutions with clients.
[Learn more at cantina.xyz](https://cantina.xyz)


**1.2** **Disclaimer**


Cantina Managed provides a detailed evaluation of the security posture of the code at a particular moment
based on the information available at the time of the review. While Cantina Managed endeavors to identify
and disclose all potential security issues, it cannot guarantee that every vulnerability will be detected or
that the code will be entirely secure against all possible attacks. The assessment is conducted based on
the specific commit and version of the code provided. Any subsequent modifications to the code may
introduce new vulnerabilities that were absent during the initial review. Therefore, any changes made
to the code require a new security review to ensure that the code remains secure. Please be advised
that the Cantina Managed security review is not a replacement for continuous security measures such as
penetration testing, vulnerability scanning, and regular code reviews.


**1.3** **Risk assessment**


**<u>Severity level</u>** **<u>Impact:</u>** **<u>High</u>** **<u>Impact:</u>** **<u>Medium</u>** **<u>Impact:</u>** **<u>Low</u>**
**<u>Likelihood:</u>** **<u>high</u>** <u>Critical</u> <u>High</u> <u>Medium</u>
**<u>Likelihood:</u>** **<u>medium</u>** <u>High</u> <u>Medium</u> <u>Low</u>
**<u>Likelihood:</u>** **<u>low</u>** <u>Medium</u> <u>Low</u> <u>Low</u>


**1.3.1** **Severity Classification**


The severity of security issues found during the security review is categorized based on the above table.
Critical findings have a high likelihood of being exploited and must be addressed immediately. High
findings are almost certain to occur, easy to perform, or not easy but highly incentivized thus must be
fixed as soon as possible.


Medium findings are conditionally possible or incentivized but are still relatively likely to occur and should
be addressed. Low findings are a rare combination of circumstances to exploit, or offer little to no incentive
to exploit but are recommended to be addressed.


Lastly, some findings might represent objective improvements that should be addressed but do not impact
the project’s overall security (Gas and Informational findings).


2


#### **2 Security Review Summary**

Base is a secure, low-cost, builder-friendly Ethereum L2 built to bring the next billion users onchain.


From Aug 28th to Aug 31st the Cantina team conducted a review of [contracts.](https://github.com/base/contracts) The review covered
the changes in four pull requests: [#250, #378, #399, and #405.](https://github.com/base/contracts/pull/250) During the review the team raised no issues.


**2.1** **Scope**


The following files were affected by the above referenced PRs and were included in the scope of this
security review::


src
├──L1
│ ├──ETHLockbox.sol (Deleted)
│ ├──OptimismPortal2.sol
│ ├──SystemConfig.sol
│ └──proofs
│ ├──DisputeGameFactory.sol
│ └──tee
│ └──TEEProverRegistry.sol
└──libraries

└──Features.sol

#### **3 Overview**


The PRs of this codebase included three big ideas:


1. To update the DisputeGameFactory to deploy games using CREATE2 instead of CREATE


2. To remove the ETHLockbox from the ETH bridging process in the OptimismPortal2 contracts


3. Allow the on-chain NitroValidator to validate AWS Nitro attestations for Nitro signer registration


These are some big changes in theory, however the existing processes and infrastructure were designed
to allow these changes to be made simply and atomically with very few complications. Simple execution
branches were removed or an external call added to make these larger changes.

#### **4 Additional Comments**


Overall we were impressed with the codebase. Design decisions made well in advance made the changes
here simple and smooth to effect and review. We commend Coinbase for their high code quality and thank
them for being respondent during the engagement.


3


