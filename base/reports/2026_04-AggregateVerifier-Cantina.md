## **Coinbase:** **AggregateVerifier**

### **Security Review**

#### Cantina Managed review by: 0xIcingdeath, Lead Security Researcher Rvierdiiev, Security Researcher April 16, 2026


##### **Contents**

**1** **Introduction** **2**
1.1 About Cantina . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.2 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3 Risk assessment . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3.1 Severity Classification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2


**2** **Security Review Summary** **3**
2.1 Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3


**3** **Findings** **4**
3.1 Informational . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
3.1.1 Document offsets, size, and expected structs . . . . . . . . . . . . . . . . . . . . . . . . 4


1


##### **1 Introduction**

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


##### **2 Security Review Summary**

Base is a secure, low-cost, builder-friendly Ethereum L2 built to bring the next billion users onchain.


[From Apr 10th to Apr 13th the Cantina team conducted a review of contracts on commit hash ffe2af8c.](https://github.com/base/contracts)
The team identified a total of **1** issues:


**Issues Found**


**<u>Severity</u>** **<u>Count</u>** **<u>Fixed</u>** **<u>Acknowledged</u>**
<u>Critical Risk</u> <u>0</u> <u>0</u> <u>0</u>
<u>High Risk</u> <u>0</u> <u>0</u> <u>0</u>
<u>Medium Risk</u> <u>0</u> <u>0</u> <u>0</u>
<u>Low Risk</u> <u>0</u> <u>0</u> <u>0</u>
<u>Gas Optimizations</u> <u>0</u> <u>0</u> <u>0</u>
<u>Informational</u> <u>1</u> <u>1</u> <u>0</u>
**<u>Total</u>** **<u>1</u>** **<u>1</u>** **<u>0</u>**


**2.1** **Scope**


[The security review had the following components in scope for contracts on commit hash ffe2af8c:](https://github.com/base/contracts)


src/multiproof/AggregateVerifier.sol


3


##### **3 Findings**

**3.1** **Informational**


**3.1.1** **Document offsets, size, and expected structs**


**Severity:** Informational


**Context:** [AggregateVerifier.sol#L29](https://cantina.xyz/code/0f7e9834-fd3b-4108-a21e-6d82bf4084d7/src/multiproof/AggregateVerifier.sol#L29)


**Description:** The initializeWithData function highlights the expected proof values, including selector,
creator, root claim, extradata, intermediate roots, and cwia bytes. In practice, the contract stores all the
above, without the selector, hence all offsets are shifted 4 bytes to the left.


For documentation purposes, we would recommend adding a section in the contract that highlights the
data offset, size, and item being stored. This helps with double checking that the getters are retrieving the
correct bytes of correct size.


**Recommendation:** Consider adding the above as in-code documentation (e.g., in a comment) or in
external documentation.


**Coinbase:** CWIA data offset added as per recommendations in attached PR.


**Cantina Managed:** Fix verified.


4


