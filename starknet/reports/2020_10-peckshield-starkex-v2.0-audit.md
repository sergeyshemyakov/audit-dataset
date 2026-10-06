# **Smart Contract Audit Report**

### Conducted by PeckShield

As part of our due process, we retained PeckShield to audit our smart contracts prior to
launching StarkEx 2.0, the next version of our scalability engine, on Ethereum Mainnet.


PeckShield has recently conducted their audit over a period of several weeks. Their audit has
revealed some minor issues, and the relevant issues were resolved to their satisfaction.


We are happy to share the key findings below, followed by the full report.

##### **Vulnerability Severity Classification**



High


Medium


Low

##### **Summary**



**Critical**


**High**


**Medium**


High



Medium


**Likelihood**



**High**


**Medium**



**Medium**


**Low**



**Low** **Low** **Informational**



Low



**Severity** **# of Findings**



**Critical**


**High**


**Medium**


**Low**


**Informational**


**Total**



**0**


**0**


**1**


**1**


**8**


**10**


##### **Key Findings**

**ID** **Severity** **Title** **Status**



**PVE-001**


**PVE-002**


**PVE-003**


**PVE-004**


**PVE-005**


**PVE-006**


**PVE-007**


**PVE-008**


**PVE-009**


**PVE-010**


**PVE-011**



**Low**


**Info.**


**Info.**


**Info.**


**Info.**


**Info.**


**Info.**


**Info.**


**Info.**


**Medium**


**Info.**



**CONFIRMED**


**CONFIRMED**


**FIXED**


**FIXED**


**FIXED**


**FIXED**


**FIXED**


**FIXED**


**FIXED**


**FIXED**


**FIXED**



**Incompatibility with Deflationary/Rebasing Tokens**


**Unnecessary Zero Amount Transfers**


**Improved Gas Consumption by Removing Unused Storage**


**Unused Internal Functions**


**Unused Interfaces**


**Missed Sanity Checks While Calling Token Contracts**


**Redundant Sanity Checks**


**Redundant Timestamp Checks**


**Improved Ether Transfers**


**Denial-of-Service Risks in depositCancel()**


**Typos in Comments**


**<u>Public</u>**

#### **SMART CONTRACT AUDIT REPORT**

##### **for**

#### **STARKWARE INDUSTRIES LTD.**


**Prepared** **By:** **<u>Shuxiao</u>** **<u>Wang</u>**


**Hangzhou,** **China**

**Oct.** **26,** **2020**


1/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**

##### **Document Properties**


**<u><mark>Client</mark></u>** <u>StarkWare</u> <u>Industries</u> <u>Ltd.</u>
**<u><mark>Title</mark></u>** <u>Smart</u> <u>Contract</u> <u>Audit</u> <u>Report</u>
**<u><mark>Target</mark></u>** <u>StarkEx</u> <u>V2</u>
**<u><mark>Version</mark></u>** <u>1.0</u>
**<u><mark>Author</mark></u>** <u>Chiachih</u> <u>Wu</u>
**<u><mark>Auditors</mark></u>** <u>Chiachih</u> <u>Wu,</u> <u>Huaguo</u> <u>Shi,</u> <u>Jeff</u> <u>Liu</u>
**<u><mark>Reviewed</mark></u>** **<u><mark>by</mark></u>** <u>Jeff</u> <u>Liu</u>
**<u><mark>Approved</mark></u>** **<u><mark>by</mark></u>** <u>Xuxian</u> <u>Jiang</u>
**<u><mark>Classifcation</mark></u>** **i** <u>Public</u>

##### **Version Info**


**<u><mark>Version</mark></u>** **<u><mark>Date</mark></u>** **<u><mark>Author(s)</mark></u>** **<u><mark>Description</mark></u>**
<u>1.0</u> <u>Oct.</u> <u>26,</u> <u>2020</u> <u>Chiachih</u> <u>Wu</u> <u>Final</u> <u>Release</u>
<u>1.0-rc</u> <u>Oct.</u> <u>19,</u> <u>2020</u> <u>Chiachih</u> <u>Wu</u> <u>Release</u> <u>Candidate</u>

##### **Contact**


For more information about this document and its contents, please contact PeckShield Inc.


**<u><mark>Name</mark></u>** <u>Shuxiao</u> <u>Wang</u>
**<u><mark>Phone</mark></u>** <u>+86</u> <u>173</u> <u>6454</u> <u>5338</u>
**<u><mark>Email</mark></u>** <u>contact@peckshield.com</u>


2/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**

##### **Contents**


**1** **Introduction** **5**

1.1 About StarkEx V2 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5

1.2 About PeckShield . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6

1.3 Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6

1.4 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


**2** **Findings** **10**

2.1 Summary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10

2.2 Key Findings . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


**3** **Detailed** **Results** **12**

3.1 Incompatibility with Deflationary/Rebasing Tokens . . . . . . . . . . . . . . . . . . . 12

3.2 Unnecessary Zero Amount Transfers . . . . . . . . . . . . . . . . . . . . . . . . . . 14

3.3 Improved Gas Consumption by Removing Unused Storage . . . . . . . . . . . . . . . 15

3.4 Unused Internal Functions . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 17

3.5 Unused Interfaces . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 18

3.6 Missed Sanity Checks While Calling Token Contracts . . . . . . . . . . . . . . . . . 18

3.7 Redundant Sanity Checks . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 19

3.8 Improved Ether Transfers . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20

3.9 Denial-of-Service Risks in depositCancel() . . . . . . . . . . . . . . . . . . . . . . . 21

3.10 Typos in Comments . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 23


**4** **Conclusion** **26**


**5** **Appendix** **27**

5.1 Basic Coding Bugs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 27

5.1.1 Constructor Mismatch . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 27

5.1.2 Ownership Takeover . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 27

5.1.3 Redundant Fallback Function . . . . . . . . . . . . . . . . . . . . . . . . . . 27

5.1.4 Overflows & Underflows . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 27


3/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


5.1.5 Reentrancy . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 28

5.1.6 Money-Giving Bug . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 28

5.1.7 Blackhole . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 28

5.1.8 Unauthorized Self-Destruct . . . . . . . . . . . . . . . . . . . . . . . . . . . 28

5.1.9 Revert DoS . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 28

5.1.10 Unchecked External `Call` . . . . . . . . . . . . . . . . . . . . . . . . . . . . 29

5.1.11 Gasless `Send` . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 29

5.1.12 `Send` Instead Of `Transfer` . . . . . . . . . . . . . . . . . . . . . . . . . . . 29

5.1.13 Costly Loop . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 29

5.1.14 (Unsafe) Use Of Untrusted Libraries . . . . . . . . . . . . . . . . . . . . . . 29

5.1.15 (Unsafe) Use Of Predictable Variables . . . . . . . . . . . . . . . . . . . . . 30

5.1.16 Transaction Ordering Dependence . . . . . . . . . . . . . . . . . . . . . . . 30

5.1.17 Deprecated Uses . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30

5.2 Semantic Consistency Checks . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30

5.3 Additional Recommendations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30

5.3.1 Avoid Use of Variadic Byte Array . . . . . . . . . . . . . . . . . . . . . . . . 30

5.3.2 Make Visibility Level Explicit . . . . . . . . . . . . . . . . . . . . . . . . . . 31

5.3.3 Make Type Inference Explicit . . . . . . . . . . . . . . . . . . . . . . . . . . 31

5.3.4 Adhere To Function Declaration Strictly . . . . . . . . . . . . . . . . . . . . 31


**References** **32**


4/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**

## **1 | Introduction**


Given the opportunity to review the design document and related source code of the **StarkEx** **V2**

contracts, we in the report outline our systematic approach to evaluate potential security issues in

the smart contract implementation, expose possible semantic inconsistencies between smart contract

code and design document, and provide additional suggestions or recommendations for improvement.

Our results show that the given version of smart contracts can be further improved due to the presence

of several issues related to either security or performance. This document outlines our audit results.

##### **1.1 About StarkEx V2**


StarkEx is StarkWare’s Layer-2 scalability engine. StarkEx leverages STARK technology to power

scalable self-custodial transactions (trading & payments) for applications such as DeFi and gaming.

StarkEx allows an application to significantly scale and improve its offering and to bring in new

business. StarkEx V2 runs over Cairo, StarkWare’s Turing-complete framework for STARKs, and

includes new features such as Fast Withdrawals: withdraw funds from L2 to any L1 address in

blockchain-time, ERC-721 support and more.

The basic information of StarkEx V2 is as follows:


Table 1.1: Basic Information of StarkEx V2


**<u><mark>Item</mark></u>** **<u><mark>Description</mark></u>**
<u>Issuer</u> <u>StarkWare</u> <u>Industries</u> <u>Ltd.</u>
<u>Website</u> <u>https://starkware.co/</u>
<u>Type</u> <u>Ethereum</u> <u>Smart</u> <u>Contract</u>
<u>Platform</u> <u>Solidity</u>
<u>Audit</u> <u>Method</u> <u>Whitebox</u>
<u>Latest</u> <u>Audit</u> <u>Report</u> <u>Oct.</u> <u>26,</u> <u>2020</u>


In the following, we show the Git repositories of reviewed files and the commit hash values used

in this audit:


5/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


  - <u>https://github.com/starkware-libs/starkex-contracts</u> (8d596dd)


  - <u>https://github.com/starkware-libs/starkex-contracts</u> (e4c1faa)


  - <u>https://github.com/starkware-libs/starkex-contracts</u> (2799231)

##### **1.2 About PeckShield**


PeckShield Inc. [13] is a leading blockchain security company with the goal of elevating the secu
rity, privacy, and usability of current blockchain ecosystems by offering top-notch, industry-leading

services and products (including the service of smart contract auditing). We are reachable at Telegram

<u>[(https://t.me/peckshield), Twitter (http://twitter.com/peckshield), or Email (contact@peckshield.com).](https://t.me/peckshield)</u>


Table 1.2: Vulnerability Severity Classification


_High_ Critical High Medium


_Medium_ <u>High</u> <u>Medium</u> <u>Low</u>


_Low_ <u>Medium</u> <u>Low</u> <u>Low</u>


_<u>High</u>_ _<u>Medium</u>_ _<u>Low</u>_


**Likelihood**

##### **1.3 Methodology**


To standardize the evaluation, we define the following terminology based on OWASP Risk Rating

Methodology [8]:


  - <u>Likelihood</u> represents how likely a particular vulnerability is to be uncovered and exploited in

the wild;


  - <u>Impact</u> measures the technical loss and business damage of a successful attack;


  - <u>Severity</u> demonstrates the overall criticality of the risk.


Likelihood and impact are categorized into three ratings: _H_, _M_ and _L_, i.e., _high_, _medium_ and

_low_ respectively. Severity is determined by likelihood and impact and can be classified into four

categories accordingly, i.e., _Critical_, _High_, _Medium_, _Low_ shown in Table 1.2.


6/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**



Table 1.3: The Full List of Check Items


**<u><mark>Category</mark></u>** **<u><mark>Check</mark></u>** **<u><mark>Item</mark></u>**

<u>Constructor</u> <u>Mismatch</u>

<u>Ownership</u> <u>Takeover</u>
<u>Redundant</u> <u>Fallback</u> <u>Function</u>

<u>Overflows</u> <u>&</u> <u>Underflows</u>

<u>Reentrancy</u>
<u>Money-Giving</u> <u>Bug</u>

<u>Blackhole</u>
<u>Unauthorized</u> <u>Self-Destruct</u>



**Basic** **Coding** **Bugs**



<u>Revert</u> <u>DoS</u>
<u>Unchecked</u> <u>External</u> <u>Call</u>

<u>Gasless</u> <u>Send</u>
<u>Send</u> <u>Instead</u> <u>Of</u> <u>Transfer</u>

<u>Costly</u> <u>Loop</u>
<u>(Unsafe)</u> <u>Use</u> <u>Of</u> <u>Untrusted</u> <u>Libraries</u>
<u>(Unsafe)</u> <u>Use</u> <u>Of</u> <u>Predictable</u> <u>Variables</u>

<u>Transaction</u> <u>Ordering</u> <u>Dependence</u>



<u>Deprecated</u> <u>Uses</u>
**<u>Semantic</u>** **<u>Consistency</u>** **<u>Checks</u>** <u>Semantic</u> <u>Consistency</u> <u>Checks</u>

<u>Business</u> <u>Logics</u> <u>Review</u>

<u>Functionality</u> <u>Checks</u>
<u>Authentication</u> <u>Management</u>
<u>Access</u> <u>Control</u> <u>&</u> <u>Authorization</u>



**Advanced** **DeFi** **Scrutiny**


**Additional** **Recommendations**



<u>Oracle</u> <u>Security</u>
<u>Digital</u> <u>Asset</u> <u>Escrow</u>
<u>Kill-Switch</u> <u>Mechanism</u>
<u>Operation</u> <u>Trails</u> <u>&</u> <u>Event</u> <u>Generation</u>

<u>ERC20</u> <u>Idiosyncrasies</u> <u>Handling</u>

<u>Frontend-Contract</u> <u>Integration</u>

<u>Deployment</u> <u>Consistency</u>
<u>Holistic</u> <u>Risk</u> <u>Management</u>

<u>Avoiding</u> <u>Use</u> <u>of</u> <u>Variadic</u> <u>Byte</u> <u>Array</u>

<u>Using</u> <u>Fixed</u> <u>Compiler</u> <u>Version</u>
<u>Making</u> <u>Visibility</u> <u>Level</u> <u>Explicit</u>
<u>Making</u> <u>Type</u> <u>Inference</u> <u>Explicit</u>
<u>Adhering</u> <u>To</u> <u>Function</u> <u>Declaration</u> <u>Strictly</u>

<u>Following</u> <u>Other</u> <u>Best</u> <u>Practices</u>



7/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


To evaluate the risk, we go through a list of check items and each would be labeled with

a severity category. For one check item, if our tool or analysis does not identify any issue, the

contract is considered safe regarding the check item. For any discovered issue, we might further

deploy contracts on our private testnet and run tests to confirm the findings. If necessary, we would

additionally build a PoC to demonstrate the possibility of exploitation. The concrete list of check

items is shown in Table 1.3.

In particular, we perform the audit according to the following procedure:


  - <u>Basic Coding Bugs:</u> We first statically analyze given smart contracts with our proprietary static

code analyzer for known coding bugs, and then manually verify (reject or confirm) all the issues

found by our tool.


  - <u>Semantic</u> <u>Consistency</u> <u>Checks:</u> We then manually check the logic of implemented smart con
tracts and compare with the description in the white paper.


  - <u>Advanced</u> <u>DeFi</u> <u>Scrutiny:</u> We further review business logics, examine system operations, and

place DeFi-related aspects under scrutiny to uncover possible pitfalls and/or bugs.


  - <u>Additional Recommendations:</u> We also provide additional suggestions regarding the coding and

development of smart contracts from the perspective of proven programming practices.


To better describe each issue we identified, we categorize the findings with Common Weakness

Enumeration (CWE-699) [7], which is a community-developed list of software weakness types to

better delineate and organize weaknesses around concepts frequently encountered in software devel
opment. Though some categories used in CWE-699 may not be relevant in smart contracts, we use

the CWE categories in Table 1.4 to classify our findings.

##### **1.4 Disclaimer**


Note that this audit does not give any warranties on finding all possible security issues of the given

smart contract(s), i.e., the evaluation result does not guarantee the nonexistence of any further

findings of security issues. As one audit-based assessment cannot be considered comprehensive, we

always recommend proceeding with several independent audits and a public bug bounty program to

ensure the security of smart contract(s). Last but not least, this security audit should not be used

as investment advice.


8/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


Table 1.4: Common Weakness Enumeration (CWE) Classifications Used in This Audit


**<u><mark>Category</mark></u>** **<u><mark>Summary</mark></u>**
**<u>Configuration</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>are</u> <u>typically</u> <u>introduced</u> <u>during</u>
<u>the</u> <u>configuration</u> <u>of</u> <u>the</u> <u>software.</u>
**<u>Data</u>** **<u>Processing</u>** **<u>Issues</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>are</u> <u>typically</u> <u>found</u> <u>in</u> <u>functional-</u>
<u>ity</u> <u>that</u> <u>processes</u> <u>data.</u>
**<u>Numeric</u>** **<u>Errors</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>are</u> <u>related</u> <u>to</u> <u>improper</u> <u>calcula-</u>
<u>tion</u> <u>or</u> <u>conversion</u> <u>of</u> <u>numbers.</u>
**<u>Security</u>** **<u>Features</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>are</u> <u>concerned</u> <u>with</u> <u>topics</u> <u>like</u>
authentication, access control, confidentiality, cryptography,
and privilege management. (Software security is not security
<u>software.)</u>
**<u>Time</u>** **<u>and</u>** **<u>State</u>** <u>Weaknesses in this category are related to the improper man-</u>
agement of time and state in an environment that supports
simultaneous or near-simultaneous computation by multiple
<u>systems,</u> <u>processes,</u> <u>or</u> <u>threads.</u>
**<u>Error</u>** **<u>Conditions,</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>include</u> <u>weaknesses</u> <u>that</u> <u>occur</u> <u>if</u>
**Return** **Values,** a function does not generate the correct return/status code,
**Status** **Codes** or if the application does not handle all possible return/status

<u>codes</u> <u>that</u> <u>could</u> <u>be</u> <u>generated</u> <u>by</u> <u>a</u> <u>function.</u>
**<u>Resource</u>** **<u>Management</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>are</u> <u>related</u> <u>to</u> <u>improper</u> <u>manage-</u>
<u>ment</u> <u>of</u> <u>system</u> <u>resources.</u>
**<u>Behavioral</u>** **<u>Issues</u>** <u>Weaknesses in this category are related to unexpected behav-</u>
<u>iors</u> <u>from</u> <u>code</u> <u>that</u> <u>an</u> <u>application</u> <u>uses.</u>
**<u>Business</u>** **<u>Logics</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>identify</u> <u>some</u> <u>of</u> <u>the</u> <u>underlying</u>
problems that commonly allow attackers to manipulate the
business logic of an application. Errors in business logic can
<u>be</u> <u>devastating</u> <u>to</u> <u>an</u> <u>entire</u> <u>application.</u>
**<u>Initialization</u>** **<u>and</u>** **<u>Cleanup</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>occur</u> <u>in</u> <u>behaviors</u> <u>that</u> <u>are</u> <u>used</u>
<u>for</u> <u>initialization</u> <u>and</u> <u>breakdown.</u>
**<u>Arguments</u>** **<u>and</u>** **<u>Parameters</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>are</u> <u>related</u> <u>to</u> <u>improper</u> <u>use</u> <u>of</u>
<u>arguments</u> <u>or</u> <u>parameters</u> <u>within</u> <u>function</u> <u>calls.</u>
**<u>Expression</u>** **<u>Issues</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>are</u> <u>related</u> <u>to</u> <u>incorrectly</u> <u>written</u>
<u>expressions</u> <u>within</u> <u>code.</u>
**<u>Coding</u>** **<u>Practices</u>** <u>Weaknesses</u> <u>in</u> <u>this</u> <u>category</u> <u>are</u> <u>related</u> <u>to</u> <u>coding</u> <u>practices</u>
that are deemed unsafe and increase the chances that an exploitable vulnerability will be present in the application. They
may not directly introduce a vulnerability, but indicate the
<u>product</u> <u>has</u> <u>not</u> <u>been</u> <u>carefully</u> <u>developed</u> <u>or</u> <u>maintained.</u>


9/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**

## **2 | Findings**

##### **2.1 Summary**


Here is a summary of our findings after analyzing the StarkEx V2 implementation. During the

first phase of our audit, we study the smart contract source code and run our in-house static code

analyzer through the codebase. The purpose here is to statically identify known coding bugs, and

then manually verify (reject or confirm) issues reported by our tool. We further manually review

business logics, examine system operations, and place DeFi-related aspects under scrutiny to uncover

possible pitfalls and/or bugs.


**<u>Severity</u>** **<u>#</u>** **<u>of</u>** **<u>Findings</u>**

<u>Critical</u> <u>0</u>

<u>High</u> <u>0</u>

<u>Medium</u> <u>1</u>

<u>Low</u> <u>1</u>

<u>Informational</u> <u>8</u>

<u>Total</u> <u>10</u>


We have so far identified a list of potential issues: some of them involve subtle corner cases

that might not be previously thought of, while others refer to unusual interactions among multiple

contracts. For each uncovered issue, we have therefore developed test cases for reasoning, reproduc
tion, and/or verification. After further analysis and internal discussion, we determined a few issues

of varying severities that need to be brought up and paid more attention to, which are categorized in

the above table. More information can be found in the next subsection, and the detailed discussions

of each of them are in Section 3.


10/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**

##### **2.2 Key Findings**


Overall, these smart contracts are well-designed and engineered, though the implementation can

be improved by resolving the identified issues (shown in Table 2.1), including 1 medium-severity

vulnerability, 1 low-severity vulnerability, 8 informational recommendations.


Table 2.1: Key Audit Findings of StarkEx V2 Protocol


**<u><mark>ID</mark></u>** **<u><mark>Severity</mark></u>** **<u><mark>Title</mark></u>** **<u><mark>Category</mark></u>** **<u><mark>Status</mark></u>**
<u>PVE-001</u> <u>Low</u> <u>Incompatibility</u> <u>with</u> <u>Deflationary/Rebasing</u> <u>Tokens</u> <u>Business</u> <u>Logics</u> <u>Fixed</u>
<u>PVE-002</u> <u>Info.</u> <u>Unnecessary</u> <u>Zero</u> <u>Amount</u> <u>Transfers</u> <u>Business</u> <u>Logics</u> <u>Confirmed</u>
<u>PVE-003</u> <u>Info.</u> <u>Improved</u> <u>Gas</u> <u>Consumption</u> <u>by</u> <u>Removing</u> <u>Unused</u> <u>Business</u> <u>Logics</u> <u>Fixed</u>
<u>Storage</u>

<u>PVE-004</u> <u>Info.</u> <u>Unused</u> <u>Internal</u> <u>Functions</u> <u>Coding</u> <u>Practices</u> <u>Fixed</u>
<u>PVE-005</u> <u>Info.</u> <u>Unused</u> <u>Interfaces</u> <u>Coding</u> <u>Practices</u> <u>Fixed</u>
<u>PVE-006</u> <u>Info.</u> <u>Missed</u> <u>Sanity</u> <u>Checks</u> <u>While</u> <u>Calling</u> <u>Token</u> <u>Contracts</u> <u>Business</u> <u>Logics</u> <u>Fixed</u>
<u>PVE-007</u> <u>Info.</u> <u>Redundant</u> <u>Sanity</u> <u>Checks</u> <u>Business</u> <u>Logics</u> <u>Fixed</u>
<u>PVE-008</u> <u>Info.</u> <u>Improved</u> <u>Ether</u> <u>Transfers</u> <u>Business</u> <u>Logics</u> <u>Fixed</u>
<u>PVE-009</u> <u>Medium</u> <u>Denial-of-Service</u> <u>Risks</u> <u>in</u> <u>depositCancel()</u> <u>Business</u> <u>Logics</u> <u>Fixed</u>
<u>PVE-010</u> <u>Info.</u> <u>Typos</u> <u>in</u> <u>Comments</u> <u>Coding</u> <u>Practices</u> <u>Fixed</u>


Besides recommending specific countermeasures to mitigate these issues, we also emphasize that

it is always important to develop necessary risk-control mechanisms and make contingency plans,

which may need to be exercised before the mainnet deployment. The risk-control mechanisms need

to kick in at the very moment when the contracts are being deployed in mainnet. Please refer to

Section 3 for details.


11/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


## **3 | Detailed Results**

##### **3.1 Incompatibility with Defationary/Rebasingl Tokens**




  - ID: PVE-001

  - Severity: Informational

  - Likelihood: N/A

  - Impact: N/A


**Description**




- Target: `LendingPool`

- Category: Business Logics [6]

- CWE subcategory: CWE-841 [4]



In StarkEx V2, the `Deposits` and `Withdrawals` contracts are designed to be the main entries for

interacting with users. In particular, one entry routine, i.e., `deposit()`, accepts user deposits of

supported assets. Naturally, the `Tokens` contract implements a number of low-level helper routines to

transfer assets into the `Deposits` contract. These asset-transferring routines work as expected with

standard ERC20 tokens: namely the vault’s internal asset balances are always consistent with actual

token balances maintained in individual ERC20 token contracts.


141 **<mark>function</mark>** <mark>d e p o s i t (</mark>
142 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark>
143 **<mark>uint256</mark>** <mark>assetType</mark> <mark>,</mark>
144 **<mark>uint256</mark>** <mark>v a u l t I d</mark> <mark>,</mark>
145 **<mark>uint256</mark>** <mark>quantizedAmount</mark>
146 <mark>)</mark> **<mark>p u b l i c</mark>** <mark>notFrozen ()</mark>
147 <mark>{</mark>
148 <mark>`//`</mark> <mark>`No`</mark> <mark>`need`</mark> <mark>`to`</mark> <mark>`verify`</mark> <mark>`amount`</mark> <mark>`>`</mark> <mark>`0,`</mark> <mark>`a`</mark> <mark>`deposit`</mark> <mark>`with`</mark> <mark>`amount`</mark> <mark>`=`</mark> <mark>`0`</mark> <mark>`can`</mark> <mark>`be`</mark> <mark>`used`</mark> <mark>`to`</mark> <mark>`undo`</mark>
```
        cancellation .
```

149 **<mark>r e q u i r e</mark>** <mark>( v a u l t I d</mark> <mark><=</mark> <mark>MAX_VAULT_ID,</mark> <mark>`" OUT_OF_RANGE_VAULT_ID "`</mark> <mark>) ;</mark>
150 <mark>`//`</mark> <mark>`starkKey`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`registered.`</mark>
151 **<mark>r e q u i r e</mark>** <mark>( ethKeys [ starkKey ]</mark> <mark>!=</mark> <mark>ZERO_ADDRESS,</mark> <mark>`" INVALID_STARK_KEY "`</mark> <mark>) ;</mark>
152 **<mark>r e q u i r e</mark>** <mark>( !</mark> <mark>isMintableAssetType ( assetType )</mark> <mark>,</mark> <mark>`" MINTABLE_ASSET_TYPE "`</mark> <mark>) ;</mark>
153 **<mark>uint256</mark>** <mark>a s s e t I d</mark> <mark>=</mark> <mark>assetType</mark> <mark>;</mark>


155 <mark>`//`</mark> <mark>`Update`</mark> <mark>`the`</mark> <mark>`balance.`</mark>
156 <mark>pendingDeposits</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>+=</mark> <mark>quantizedAmount ;</mark>
157 **<mark>r e q u i r e</mark>** <mark>(</mark>


12/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


158 <mark>pendingDeposits</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>>=</mark> <mark>quantizedAmount</mark> <mark>,</mark>
159 <mark>`" DEPOSIT_OVERFLOW "`</mark>
160 <mark>) ;</mark>


162 <mark>`//`</mark> <mark>`Disable`</mark> <mark>`the`</mark> <mark>`timeout.`</mark>
163 **<mark>delete</mark>** <mark>c a n c e l l a t i o n R e q u e s t s</mark> <mark>[ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>] ;</mark>


165 <mark>`//`</mark> <mark>`Transfer`</mark> <mark>`the`</mark> <mark>`tokens`</mark> <mark>`to`</mark> <mark>`the`</mark> <mark>`Deposit`</mark> <mark>`contract.`</mark>
166 <mark>t r a n s f e r I n</mark> <mark>( assetType</mark> <mark>,</mark> <mark>quantizedAmount ) ;</mark>

Listing 3.1: interactions /Deposits. sol


However, there exist other ERC20 tokens that may make certain customizations to their ERC20

contracts. One type of these tokens is deflationary tokens that charge certain fee for every `transfer()`

or `transferFrom()` . (Another type is rebasing tokens such as `YAM` .) As a result, this may not meet the

assumption behind these low-level asset-transferring routines. In other words, the above operations,

such as `deposit()`, may introduce unexpected balance inconsistencies when comparing internal asset

records with external ERC20 token contracts. Apparently, these balance inconsistencies are damaging

to accurate and precise portfolio management of StarkEx V2 and affects protocol-wide operation and

maintenance.

One possible mitigation is to measure the asset change right before and after the asset-transferring

routines. In other words, instead of bluntly assuming the amount parameter in `transfer()` or

`transferFrom()` will always result in full transfer, we need to ensure the increased or decreased amount

in the `Deposits` before and after the `transfer()` or `transferFrom()` is expected and aligned well with our

operation. Though these additional checks cost additional gas usage, we consider they are necessary

to deal with deflationary tokens or other customized ones if their support is deemed necessary.

Another mitigation is to regulate the set of ERC20 tokens that are permitted into StarkEx V2.

In StarkEx V2, it is indeed possible to effectively regulate the set of tokens that can be supported.

Keep in mind that there exist certain assets (e.g., `USDT` ) that may have control switches that can be

dynamically exercised to suddenly become one.

We emphasize that the current deployment of `Deposits` is safe as it uses whitelisted `assetType` for

deposits and withdrawals. However, the current code implementation is generic in supporting various

tokens and there is a need to highlight the possible pitfall from the audit perspective.


**Recommendation** If current codebase needs to support possible deflationary tokens, it is better

to check the balance before and after the `transferIn()` call to ensure the book-keeping amount is

accurate. This support may bring additional gas cost. Also, keep in mind that certain tokens may not

be deflationary for the time being. However, they could have a control switch that can be exercised

to turn them into deflationary tokens. One example is the widely-adopted `USDT` .


**Status** This issue has been addressed by checking the balance before and after within the

`TransferIn()` function in commit 2799231.


13/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


##### **3.2 Unnecessary Zero Amount Transfers**




  - ID: PVE-002

  - Severity: Informational

  - Likelihood: N/A

  - Impact: N/A


**Description**




- Target: `Withdrawals.sol`

- Category: Business Logics [6]

- CWE subcategory: CWE-841 [4]



In the `Withdrawals` contract, the `withdrawTo()` function allows users to withdraw assets by claiming the

`pendingWithdrawals[starkKey][assetId]` with a valid `startKey` associated with the `msg.sender` . While

reviewing the implementation, we identify that certain corner cases may lead to zero amount transfers

with `LogWithdrawalPerformed()` events emitted, which is not necessary.


93 **<mark>function</mark>** <mark>withdrawTo (</mark> **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>assetType</mark> <mark>,</mark> **<mark>address</mark>** **<mark>payable</mark>** <mark>r e c i p i e n t</mark> <mark>)</mark>
94 **<mark>p u b l i c</mark>**
95 <mark>isSenderStarkKey ( starkKey )</mark>
96 <mark>`//`</mark> <mark>`No`</mark> <mark>`notFrozen`</mark> <mark>`modifier:`</mark> <mark>`This`</mark> <mark>`function`</mark> <mark>`can`</mark> <mark>`always`</mark> <mark>`be`</mark> <mark>`used,`</mark> <mark>`even`</mark> <mark>`when`</mark> <mark>`frozen.`</mark>
97 <mark>{</mark>
98 **<mark>r e q u i r e</mark>** <mark>( !</mark> <mark>isMintableAssetType ( assetType )</mark> <mark>,</mark> <mark>`" MINTABLE_ASSET_TYPE "`</mark> <mark>) ;</mark>
99 **<mark>uint256</mark>** <mark>a s s e t I d</mark> <mark>=</mark> <mark>assetType</mark> <mark>;</mark>
100 <mark>`//`</mark> <mark>`Fetch`</mark> <mark>`and`</mark> <mark>`clear`</mark> <mark>`quantized`</mark> <mark>`amount.`</mark>
101 **<mark>uint256</mark>** <mark>quantizedAmount</mark> <mark>=</mark> <mark>pendingWithdrawals [ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] ;</mark>
102 <mark>pendingWithdrawals [ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>]</mark> <mark>=</mark> <mark>0 ;</mark>


104 <mark>`//`</mark> <mark>`Transfer`</mark> <mark>`funds.`</mark>
105 <mark>t r a n s f e r O u t ( r e c i p i e n t</mark> <mark>,</mark> <mark>assetType</mark> <mark>,</mark> <mark>quantizedAmount ) ;</mark>
106 **<mark>emit</mark>** <mark>LogWithdrawalPerformed (</mark>
107 <mark>starkKey</mark> <mark>,</mark>
108 <mark>assetType</mark> <mark>,</mark>
109 <mark>fromQuantized ( assetType</mark> <mark>,</mark> <mark>quantizedAmount )</mark> <mark>,</mark>
110 <mark>quantizedAmount</mark> <mark>,</mark>
111 <mark>r e c i p i e n t</mark>
112 <mark>) ;</mark>
113 <mark>}</mark>

Listing 3.2: interactions /Withdrawals.sol


Specifically, when `pendingWithdrawals[starkKey][assetId]` `==` `0`, the `transferOut()` call in line 105

results in a zero transfer since `quantizedAmount` is 0. In addition, line 106 emits the `LogWithdrawalPerformed`

event with the zero `quantizedAmount`, which is a waste of gas.


**Recommendation** Add `pendingWithdrawals[starkKey][assetId]` `>` `0` sanity check into `withdrawTo`

`()` .


93 **<mark>function</mark>** <mark>withdrawTo (</mark> **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>assetType</mark> <mark>,</mark> **<mark>address</mark>** **<mark>payable</mark>** <mark>r e c i p i e n t</mark> <mark>)</mark>
94 **<mark>p u b l i c</mark>**


14/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


95 <mark>isSenderStarkKey ( starkKey )</mark>
96 <mark>`//`</mark> <mark>`No`</mark> <mark>`notFrozen`</mark> <mark>`modifier:`</mark> <mark>`This`</mark> <mark>`function`</mark> <mark>`can`</mark> <mark>`always`</mark> <mark>`be`</mark> <mark>`used,`</mark> <mark>`even`</mark> <mark>`when`</mark> <mark>`frozen.`</mark>
97 <mark>{</mark>
98 **<mark>r e q u i r e</mark>** <mark>( !</mark> <mark>isMintableAssetType ( assetType )</mark> <mark>,</mark> <mark>`" MINTABLE_ASSET_TYPE "`</mark> <mark>) ;</mark>
99 **<mark>uint256</mark>** <mark>a s s e t I d</mark> <mark>=</mark> <mark>assetType</mark> <mark>;</mark>
100 **<mark>r e q u i r e</mark>** <mark>( pendingWithdrawals [</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>]</mark> <mark>></mark> <mark>0,</mark> <mark>`" ZERO_AMOUNT_WITHDRAW "`</mark> <mark>) ;</mark>
101 <mark>`//`</mark> <mark>`Fetch`</mark> <mark>`and`</mark> <mark>`clear`</mark> <mark>`quantized`</mark> <mark>`amount.`</mark>
102 **<mark>uint256</mark>** <mark>quantizedAmount</mark> <mark>=</mark> <mark>pendingWithdrawals [ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] ;</mark>
103 <mark>pendingWithdrawals [ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>]</mark> <mark>=</mark> <mark>0 ;</mark>


105 <mark>`//`</mark> <mark>`Transfer`</mark> <mark>`funds.`</mark>
106 <mark>t r a n s f e r O u t ( r e c i p i e n t</mark> <mark>,</mark> <mark>assetType</mark> <mark>,</mark> <mark>quantizedAmount ) ;</mark>
107 **<mark>emit</mark>** <mark>LogWithdrawalPerformed (</mark>
108 <mark>starkKey</mark> <mark>,</mark>
109 <mark>assetType</mark> <mark>,</mark>
110 <mark>fromQuantized ( assetType</mark> <mark>,</mark> <mark>quantizedAmount )</mark> <mark>,</mark>
111 <mark>quantizedAmount</mark> <mark>,</mark>
112 <mark>r e c i p i e n t</mark>
113 <mark>) ;</mark>
114 <mark>}</mark>


Listing 3.3: interactions /Withdrawals.sol


**Status** This issue has been confirmed. Considering this is an unlikely case, the team decides

to leave it as is for the time being.

##### **3.3 Improved Gas Consumption by Removing Unused Storage**




  - ID: PVE-003

  - Severity: Informational

  - Likelihood: N/A

  - Impact: N/A


**Description**




- Target: `ApprovalChain`

- Category: Business Logics [6]

- CWE subcategory: CWE-841 [4]



In the `ApprovalChain` contract, when a `governor` tends to remove an entry from the `ApprovalChain`, she

needs to invoke the `announceRemovalIntent()` first to set the `chain.unlockedForRemovalTime[entry]` . It

means the `governor` cannot literally remove the entry until `now` reaches `now` `+` `removalDelay` .


65 **<mark>function</mark>** <mark>announceRemovalIntent (</mark>
66 <mark>StarkExTypes . ApprovalChainData</mark> **<mark>storage</mark>** <mark>chain</mark> <mark>,</mark> **<mark>address</mark>** <mark>entry</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>removalDelay )</mark>
67 **<mark>i n t e r n a l</mark>**
68 <mark>onlyGovernance ( )</mark>
69 <mark>notFrozen ()</mark>
70 <mark>{</mark>
71 <mark>s a f e F i n d E n t r y ( chain</mark> <mark>.</mark> <mark>l i s t</mark> <mark>,</mark> <mark>e n t r y ) ;</mark>


15/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


72 **<mark>r e q u i r e</mark>** <mark>(</mark> **<mark>now</mark>** <mark>+</mark> <mark>removalDelay</mark> <mark>></mark> **<mark>now</mark>** <mark>,</mark> <mark>`" INVALID_REMOVAL_DELAY "`</mark> <mark>) ;</mark> <mark>`//`</mark> <mark>`NOLINT:`</mark> <mark>`timestamp.`</mark>
73 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
74 <mark>chain</mark> <mark>. unlockedForRemovalTime [</mark> <mark>e n t r y</mark> <mark>]</mark> <mark>=</mark> **<mark>now</mark>** <mark>+</mark> <mark>removalDelay</mark> <mark>;</mark>
75 <mark>}</mark>


Listing 3.4: components/ApprovalChain.sol


To achieve that, the `removeEntry()` function checks the `chain.unlockedForRemovalTime[entry]` when

the `governor` removes the entry for real. However, in the case that the `governor` successfully remove

the specific entry from `chain.list`, the no longer needed `chain.unlockedForRemovalTime[entry]` is not

cleared. Fortunately, the uncleared removal time could not be re-used since `safeFindEntry()` would

revert in the beginning of `removeEntry()` . But it’s worth to remove the unused storage to refund some

gas.


77 **<mark>function</mark>** <mark>removeEntry ( StarkExTypes . ApprovalChainData</mark> **<mark>storage</mark>** <mark>chain</mark> <mark>,</mark> **<mark>address</mark>** <mark>e n t r y )</mark>
78 **<mark>i n t e r n a l</mark>**
79 <mark>onlyGovernance ( )</mark>
80 <mark>notFrozen ()</mark>
81 <mark>{</mark>
82 **<mark>address</mark>** <mark>[ ]</mark> **<mark>storage</mark>** <mark>l i s t</mark> <mark>=</mark> <mark>chain</mark> <mark>.</mark> <mark>l i s t</mark> <mark>;</mark>
83 <mark>`//`</mark> <mark>`Make`</mark> <mark>`sure`</mark> <mark>`entry`</mark> <mark>`exists.`</mark>
84 **<mark>uint256</mark>** <mark>i d x</mark> <mark>=</mark> <mark>s a f e F i n d E n t r y (</mark> <mark>l i s t</mark> <mark>,</mark> <mark>e n t r y ) ;</mark>
85 **<mark>uint256</mark>** <mark>unlockedForRemovalTime</mark> <mark>=</mark> <mark>chain</mark> <mark>. unlockedForRemovalTime [</mark> <mark>e n t r y</mark> <mark>] ;</mark>


87 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
88 **<mark>r e q u i r e</mark>** <mark>( unlockedForRemovalTime</mark> <mark>></mark> <mark>0,</mark> <mark>`" REMOVAL_NOT_ANNOUNCED "`</mark> <mark>) ;</mark>
89 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
90 **<mark>r e q u i r e</mark>** <mark>(</mark> **<mark>now</mark>** <mark>>=</mark> <mark>unlockedForRemovalTime</mark> <mark>,</mark> <mark>`" REMOVAL_NOT_ENABLED_YET "`</mark> <mark>) ;</mark> <mark>`//`</mark> <mark>`NOLINT:`</mark>
```
        timestamp.

```

92 **<mark>uint256</mark>** <mark>n_entries</mark> <mark>=</mark> <mark>l i s t</mark> <mark>.</mark> **<mark>length</mark>** <mark>;</mark>


94 <mark>`//`</mark> <mark>`Removal`</mark> <mark>`of`</mark> <mark>`last`</mark> <mark>`entry`</mark> <mark>`is`</mark> <mark>`forbidden.`</mark>
95 **<mark>r e q u i r e</mark>** <mark>( n_entries</mark> <mark>></mark> <mark>1,</mark> <mark>`" LAST_ENTRY_MAY_NOT_BE_REMOVED "`</mark> <mark>) ;</mark>


97 **<mark>i f</mark>** <mark>( i d x</mark> <mark>!=</mark> <mark>n_entries</mark> <mark>*</mark> <mark>1)</mark> <mark>{</mark>
98 <mark>l i s t</mark> <mark>[</mark> <mark>i d x</mark> <mark>]</mark> <mark>=</mark> <mark>l i s t</mark> <mark>[</mark> <mark>n_entries</mark> <mark>*</mark> <mark>1 ] ;</mark>
99 <mark>}</mark>
100 <mark>l i s t</mark> <mark>. pop ( )</mark> <mark>;</mark>
101 <mark>}</mark>


Listing 3.5: components/ApprovalChain.sol


**Recommendation** Remove `chain.unlockedForRemovalTime[entry]` in `removeEntry()` .


**Status** This issue has been addressed by deleting `chain.unlockedForRemovalTime[entry]` in com
mit 2799231.


16/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


##### **3.4 Unused Internal Functions**


  - ID: PVE-004

  - Severity: Informational

  - Likelihood: N/A

  - Impact: N/A


**Description**




- Target: `Deposits`

- Category: Coding Practices [5]

- CWE subcategory: CWE-1116 [3]



In StarkEx V2, after users deposit assets into the on-chain deposit area, the `UpdateState` contract

is in charge to transfer funds to the off-chain deposit area by invoking the `acceptDeposit()` function

which is implemented in the `AcceptModifications` contract. However, we notice that there is another

`acceptDeposit()` internal function in the `Deposits` contract which is not used anywhere.


283 **<mark>function</mark>** <mark>acceptDeposit (</mark>
284 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark>
285 **<mark>uint256</mark>** <mark>v a u l t I d</mark> <mark>,</mark>
286 **<mark>uint256</mark>** <mark>a s s e t I d</mark> <mark>,</mark>
287 **<mark>uint256</mark>** <mark>quantizedAmount</mark>
288 <mark>)</mark>
289 **<mark>i n t e r n a l</mark>**
290 <mark>{</mark>
291 <mark>`//`</mark> <mark>`Fetch`</mark> <mark>`deposit.`</mark>
292 **<mark>r e q u i r e</mark>** <mark>(</mark>
293 <mark>pendingDeposits</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>>=</mark> <mark>quantizedAmount</mark> <mark>,</mark>
294 <mark>`" DEPOSIT_INSUFFICIENT "`</mark>
295 <mark>) ;</mark>


297 <mark>`//`</mark> <mark>`Subtract`</mark> <mark>`accepted`</mark> <mark>`quantized`</mark> <mark>`amount.`</mark>
298 <mark>pendingDeposits</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>*=</mark> <mark>quantizedAmount ;</mark>
299 <mark>}</mark>


Listing 3.6: interactions /Deposits. sol


**Recommendation** Remove the unused `acceptDeposit()` function from the `Deposits` contract.


**Status** This issue has been addressed by removing `acceptDeposit()` function from the `Deposits`

contract in commit 2799231.


17/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


##### **3.5 Unused Interfaces**


  - ID: PVE-005

  - Severity: Informational

  - Likelihood: N/A

  - Impact: N/A


**Description**




- Target: `MWithdrawal`

- Category: Coding Practices [5]

- CWE subcategory: CWE-1116 [3]



In StarkEx V2, after users issue the withdrawal requests, the `UpdateState` contract is in charge to trans
fer funds from the off-chain area to the on-chain withdrawal area by invoking the `acceptWithdrawal()`

function which is implemented in the `AcceptModifications` contract. The underlying function of

`acceptWithdrawal()` is the internal function `allowWithdrawal()` implemented in `AcceptModifications`

contract as well. However, we notice that there is another `allowWithdrawal()` interface declared in

the `MWithdrawal` contract which is not used anywhere. In addition, the `MWithdrawal` contract seems

to be a obsolete contract left in the code base as no other contract imports it.

4 **<mark>function</mark>** <mark>allowWithdrawal (</mark>
5 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark>
6 **<mark>uint256</mark>** <mark>a s s e t I d</mark> <mark>,</mark>
7 **<mark>uint256</mark>** <mark>quantizedAmount</mark>
8 <mark>)</mark>
9 **<mark>i n t e r n a l</mark>** <mark>;</mark>

Listing 3.7: interfaces /MWithdrawal.sol


**Recommendation** Remove the unused `MWithdrawal` contract.


**Status** This issue has been addressed by removing the `MWithdrawal` contract in commit 2799231.

##### **3.6 Missed Sanity Checks While Calling Token Contracts**




  - ID: PVE-006

  - Severity: Informational

  - Likelihood: N/A

  - Impact: N/A


**Description**




- Target: `Tokens`

- Category: Business Logics [6]

- CWE subcategory: CWE-841 [4]



In StarkEx V2, assets are transfer in/out with helper functions such as `transferIn()` and `transferOut`

`()` . While dealing with ERC20s, the `safeTokenContractCall()` helper function is used to deal with


18/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


non-standard ERC20 implementations. However, the `safeTokenContractCall()` function fails to check

if the `tokenAddress` is a contract or not. When the `tokenAddress` happens to be an EOA address, the

`call()` returns 0 as well. This leads to a buggy implementation of token transfers.


87 **<mark>function</mark>** <mark>s a fe T o k e n Co n tr a c t Ca l l (</mark> **<mark>address</mark>** <mark>tokenAddress</mark> <mark>,</mark> **<mark>bytes</mark>** **<mark>memory</mark>** <mark>c a l l D a t a )</mark> **<mark>i n t e r n a l</mark>** <mark>{</mark>
88 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -low -level -calls`</mark>
89 <mark>`//`</mark> <mark>`NOLINTNEXTLINE :`</mark> <mark>`low -level -calls.`</mark>
90 <mark>(</mark> **<mark>bool</mark>** <mark>success</mark> <mark>,</mark> **<mark>bytes</mark>** **<mark>memory</mark>** <mark>r e t u r n d a t a )</mark> <mark>=</mark> **<mark>address</mark>** <mark>( tokenAddress ) .</mark> **<mark>c a l l</mark>** <mark>( c a l l D a t a ) ;</mark>
91 **<mark>r e q u i r e</mark>** <mark>( success</mark> <mark>,</mark> **<mark>s t r i n g</mark>** <mark>( r e t u r n d a t a ) ) ;</mark>


93 **<mark>i f</mark>** <mark>( r e t u r n d a t a</mark> <mark>.</mark> **<mark>length</mark>** <mark>></mark> <mark>0)</mark> <mark>{</mark>
94 **<mark>r e q u i r e</mark>** <mark>( a b i</mark> <mark>. decode ( returndata</mark> <mark>,</mark> <mark>(</mark> **<mark>bool</mark>** <mark>) )</mark> <mark>,</mark> <mark>`" TOKEN_OPERATION_FAILED "`</mark> <mark>) ;</mark>
95 <mark>}</mark>
96 <mark>}</mark>


Listing 3.8: components/Tokens.sol


Fortunately, the `tokenAddress` is checked while an asset is registered into the system. There’s no

plausible way to exploit this issue.


**Recommendation** Ensure `tokenAddress` is a contract before `call()` it.


**Status** This issue has been fixed by checking `tokenAddress` with `isContract()` in commit

2799231.

##### **3.7 Redundant Sanity Checks**




  - ID: PVE-007

  - Severity: Informational

  - Likelihood: N/A

  - Impact: N/A


**Description**




- Target: `gps/GpsStatementVerifier.sol`

- Category: Business Logics [6]

- CWE subcategory: CWE-841 [4]



While reviewing the EVM Verifier of StarkEx V2, we identify a redundant sanity check in the

`GpsStatementVerifie` contract. Specifically, in the `verifyProofAndRegister()` function, the `offset` is

set as `OFFSET_PUBLIC_MEMORY` in line 72. However, in line 77, the `require()` call checks the `offset`

immediately, which is redundant. The `offset` `==` `OFFSET_PUBLIC_MEMORY` here should always be true.


72 **<mark>uint256</mark>** <mark>o f f s e t</mark> <mark>=</mark> <mark>OFFSET_PUBLIC_MEMORY;</mark>


74 <mark>`//`</mark> <mark>`Write`</mark> <mark>`public`</mark> <mark>`memory,`</mark> <mark>`which`</mark> <mark>`is`</mark> <mark>`a`</mark> <mark>`list`</mark> <mark>`of`</mark> <mark>`pairs`</mark> <mark>`(address,`</mark> <mark>`value).`</mark>
75 <mark>{</mark>
76 <mark>`//`</mark> <mark>`Program`</mark> <mark>`segment.`</mark>
77 **<mark>r e q u i r e</mark>** <mark>(</mark> <mark>o f f s e t</mark> <mark>==</mark> <mark>OFFSET_PUBLIC_MEMORY,</mark> <mark>`"Wrong`</mark> <mark>`value`</mark> <mark>`of`</mark> <mark>`offset."`</mark> <mark>) ;</mark>


19/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


78 **<mark>uint256</mark>** <mark>[PROGRAM_SIZE]</mark> **<mark>memory</mark>** <mark>bootloaderProgram</mark> <mark>=</mark>
79 <mark>bootloaderProgramContractAddress</mark> <mark>. getCompiledProgram ( )</mark> <mark>;</mark>
80 **<mark>f o r</mark>** <mark>(</mark> **<mark>uint256</mark>** <mark>i</mark> <mark>=</mark> <mark>0 ;</mark> <mark>i</mark> <mark><</mark> <mark>bootloaderProgram .</mark> **<mark>length</mark>** <mark>;</mark> <mark>i ++)</mark> <mark>{</mark>
81 <mark>c a i r o P u b l i c I n p u t</mark> <mark>[</mark> <mark>o f f s e t</mark> <mark>]</mark> <mark>=</mark> <mark>i</mark> <mark>;</mark>
82 <mark>c a i r o P u b l i c I n p u t</mark> <mark>[</mark> <mark>o f f s e t</mark> <mark>+</mark> <mark>1]</mark> <mark>=</mark> <mark>bootloaderProgram [</mark> <mark>i</mark> <mark>] ;</mark>
83 <mark>o f f s e t</mark> <mark>+=</mark> <mark>2 ;</mark>
84 <mark>}</mark>
85 <mark>}</mark>


Listing 3.9: GpsStatementVerifier :: verifyProofAndRegister ()


**Recommendation** Remove the redundant sanity check against `offset` .

**Status** This issue has been fixed by refactoring the `verifyProofAndRegister()` function in commit

e4c1faa.

##### **3.8 Improved Ether Transfers**




  - ID: PVE-008

  - Severity: Informational

  - Likelihood: N/A

  - Impact: N/A


**Description**




- Target: `TransferRegistry,` `Tokens`

- Category: Business Logics [6]

- CWE subcategory: CWE-841 [4]



As described in Section 3.6, assets are transfer in/out with helper functions such as `transferIn()` and

`transferOut()` . While dealing with ERC20s, the `safeTokenContractCall()` helper function is used to

deal with non-standard ERC20 implementations. As for the case of transferring ether, the Solidity

function, `transfer()`, is used (line 213 in the code snippet below). However, as described in [2],

when the `recipient` happens to be a contract which implements a callback function containing EVM

instructions such as `SLOAD`, the 2300 gas supplied with `transfer()` might be insufficient, leading to an

out-of-gas error.


200 **<mark>function</mark>** <mark>t r a n s f e r O u t (</mark> **<mark>address</mark>** **<mark>payable</mark>** <mark>r e c i p i e n t</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>assetType</mark> <mark>,</mark> **<mark>uint256</mark>**
<mark>quantizedAmount )</mark>
201 **<mark>i n t e r n a l</mark>** <mark>{</mark>
202 **<mark>bytes</mark>** **<mark>memory</mark>** <mark>a s s e t I n f o</mark> <mark>=</mark> <mark>g e t A s s e t I n f o ( assetType ) ;</mark>
203 **<mark>uint256</mark>** <mark>amount</mark> <mark>=</mark> <mark>fromQuantized ( assetType</mark> <mark>,</mark> <mark>quantizedAmount ) ;</mark>


205 **<mark>bytes4</mark>** <mark>t o k e n S e l e c t o r</mark> <mark>=</mark> <mark>e x t r a c t T o k e n S e l e c t o r ( a s s e t I n f o ) ;</mark>
206 **<mark>i f</mark>** <mark>( t o k e n S e l e c t o r</mark> <mark>==</mark> <mark>ERC20_SELECTOR)</mark> <mark>{</mark>
207 **<mark>address</mark>** <mark>tokenAddress</mark> <mark>=</mark> <mark>e x t r a c t C o n t r a c t A d d r e s s ( a s s e t I n f o ) ;</mark>
208 <mark>s a fe T o k e n Co n tr a c t Ca l l (</mark>
209 <mark>tokenAddress</mark> <mark>,</mark>
210 <mark>a b i</mark> <mark>.</mark> <mark>encodeWithSelector ( IERC20 (0)</mark> <mark>.</mark> **<mark>t r a n s f e r</mark>** <mark>.</mark> <mark>s e l e c t o r</mark> <mark>,</mark> <mark>r e c i p i e n t</mark> <mark>,</mark> <mark>amount )</mark>


20/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


211 <mark>) ;</mark>
212 <mark>}</mark> **<mark>e l s e</mark>** **<mark>i f</mark>** <mark>( t o k e n S e l e c t o r</mark> <mark>==</mark> <mark>ETH_SELECTOR)</mark> <mark>{</mark>
213 <mark>r e c i p i e n t</mark> <mark>.</mark> **<mark>t r a n s f e r</mark>** <mark>( amount ) ;</mark> <mark>`//`</mark> <mark>`NOLINT:`</mark> <mark>`arbitrary -send.`</mark>
214 <mark>}</mark> **<mark>e l s e</mark>** <mark>{</mark>
215 **<mark>r e v e r t</mark>** <mark>(</mark> <mark>`" UNSUPPORTED_TOKEN_TYPE "`</mark> <mark>) ;</mark>
216 <mark>}</mark>
217 <mark>}</mark>


Listing 3.10: components/Tokens.sol


As suggested in [2], we suggest to stop using Solidity’s `transfer()` as well. Note that the use of

`call()` leads to side effects such as reentrancy attacks and gas token vulnerabilities.


**Recommendation** Replace `transfer()` with `call()` .


**Status** This issue has been fixed by introducing the `performEthTransfer()` helper function which

uses `call()` for ether transfers in commit 2799231.

##### **3.9 Denial-of-Service Risks in depositCancel()**




- ID: PVE-009

- Severity: Medium

- Likelihood: Medium

- Impact: Medium


**Description**




- Target: `Deposits`

- Category: Business Logics [6]

- CWE subcategory: CWE-841 [4]



As described in Section 3.1, `deposit()` is the entry routine which accepts user deposits. To handle

the case that users tend to undo the `deposit()` operations, the `depositCancel()` allows users to issue

the cancellation with the current timestamp (i.e., `now` ) stored in the `cancellationRequests` (line 201

in the code snippet below).


188 **<mark>function</mark>** <mark>d e p o s i t C a n c e l (</mark>
189 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark>
190 **<mark>uint256</mark>** <mark>a s s e t I d</mark> <mark>,</mark>
191 **<mark>uint256</mark>** <mark>v a u l t I d</mark>
192 <mark>)</mark>
193 **<mark>external</mark>**
194 <mark>isSenderStarkKey ( starkKey )</mark>
195 <mark>`//`</mark> <mark>`No`</mark> <mark>`notFrozen`</mark> <mark>`modifier:`</mark> <mark>`This`</mark> <mark>`function`</mark> <mark>`can`</mark> <mark>`always`</mark> <mark>`be`</mark> <mark>`used,`</mark> <mark>`even`</mark> <mark>`when`</mark> <mark>`frozen.`</mark>
196 <mark>{</mark>
197 **<mark>r e q u i r e</mark>** <mark>( v a u l t I d</mark> <mark><=</mark> <mark>MAX_VAULT_ID,</mark> <mark>`" OUT_OF_RANGE_VAULT_ID "`</mark> <mark>) ;</mark>
198
199 <mark>`//`</mark> <mark>`Start`</mark> <mark>`the`</mark> <mark>`timeout.`</mark>
200 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>


21/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


201 <mark>c a n c e l l a t i o n R e q u e s t s</mark> <mark>[ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>=</mark> **<mark>now</mark>** <mark>;</mark>


Listing 3.11: interactions /Deposits. sol


The user cannot `depositReclaim()` the deposit until `DEPOSIT_CANCEL_DELAY` (i.e., 24 hours) after

the previously stored timestamp. As shown in the code snippet below, the book-keeping record,

`cancellationRequests[starkKey][assetId][vaultId]` is retrieved into `requestTime` in line 220. Later on,

the `freetime` is derived by _requestT ime_ + 24 _hours_ in line 222. If `now` is greater or equal to `freetime`,

the `transferOut()` is invoked to transfer assets to `msg.sender` (line 233). So far, the business logic

seems solid.


207 **<mark>function</mark>** <mark>d e p o s i t R e c l a i m (</mark>
208 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark>
209 **<mark>uint256</mark>** <mark>assetType</mark> <mark>,</mark>
210 **<mark>uint256</mark>** <mark>v a u l t I d</mark>
211 <mark>)</mark>
212 **<mark>external</mark>**
213 <mark>isSenderStarkKey ( starkKey )</mark>
214 <mark>`//`</mark> <mark>`No`</mark> <mark>`notFrozen`</mark> <mark>`modifier:`</mark> <mark>`This`</mark> <mark>`function`</mark> <mark>`can`</mark> <mark>`always`</mark> <mark>`be`</mark> <mark>`used,`</mark> <mark>`even`</mark> <mark>`when`</mark> <mark>`frozen.`</mark>
215 <mark>{</mark>
216 **<mark>r e q u i r e</mark>** <mark>( v a u l t I d</mark> <mark><=</mark> <mark>MAX_VAULT_ID,</mark> <mark>`" OUT_OF_RANGE_VAULT_ID "`</mark> <mark>) ;</mark>
217 **<mark>uint256</mark>** <mark>a s s e t I d</mark> <mark>=</mark> <mark>assetType</mark> <mark>;</mark>
218
219 <mark>`//`</mark> <mark>`Make`</mark> <mark>`sure`</mark> <mark>`enough`</mark> <mark>`time`</mark> <mark>`has`</mark> <mark>`passed.`</mark>
220 **<mark>uint256</mark>** <mark>requestTime</mark> <mark>=</mark> <mark>c a n c e l l a t i o n R e q u e s t s</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>] ;</mark>
221 **<mark>r e q u i r e</mark>** <mark>( requestTime</mark> <mark>!=</mark> <mark>0,</mark> <mark>`" DEPOSIT_NOT_CANCELED "`</mark> <mark>) ;</mark>
222 **<mark>uint256</mark>** <mark>freeTime</mark> <mark>=</mark> <mark>requestTime</mark> <mark>+</mark> <mark>DEPOSIT_CANCEL_DELAY;</mark>
223 **<mark>a s s e r t</mark>** <mark>( freeTime</mark> <mark>>=</mark> <mark>DEPOSIT_CANCEL_DELAY) ;</mark>
224 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
225 **<mark>r e q u i r e</mark>** <mark>(</mark> **<mark>now</mark>** <mark>>=</mark> <mark>freeTime</mark> <mark>,</mark> <mark>`" DEPOSIT_LOCKED "`</mark> <mark>) ;</mark> <mark>`//`</mark> <mark>`NOLINT:`</mark> <mark>`timestamp.`</mark>
226
227 <mark>`//`</mark> <mark>`Clear`</mark> <mark>`deposit.`</mark>
228 **<mark>uint256</mark>** <mark>quantizedAmount</mark> <mark>=</mark> <mark>pendingDeposits</mark> <mark>[ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>] ;</mark>
229 **<mark>delete</mark>** <mark>pendingDeposits</mark> <mark>[ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>] ;</mark>
230 **<mark>delete</mark>** <mark>c a n c e l l a t i o n R e q u e s t s</mark> <mark>[ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>] ;</mark>
231
232 <mark>`//`</mark> <mark>`Refund`</mark> <mark>`deposit.`</mark>
233 <mark>t r a n s f e r O u t (</mark> **<mark>msg</mark>** <mark>.</mark> **<mark>sender</mark>** <mark>,</mark> <mark>assetType</mark> <mark>,</mark> <mark>quantizedAmount ) ;</mark>


Listing 3.12: interactions /Deposits. sol


But here comes the flawed business logic. In the `deposit()` function, we notice that the book
keeping record is cleared when the user re-deposit some assets. It is reasonable to <u>cancel</u> a previous

cancellation if the user tend to deposit assets again. However, any user could `deposit()` to an

arbitrary `(starkKey,` `assetType,` `vaultId)` tuple with zero amount as the comment suggested in line

148. Therefore, a bad actor could maliciously cancel a victim’s deposit cancellation by front-running

the `depositReclaim()` calls. This leads to a denial-of-service vulnerability targeting the `depositCancel()`

and `depositReclaim()` mechanism.


22/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


141 **<mark>function</mark>** <mark>d e p o s i t (</mark>
142 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark>
143 **<mark>uint256</mark>** <mark>assetType</mark> <mark>,</mark>
144 **<mark>uint256</mark>** <mark>v a u l t I d</mark> <mark>,</mark>
145 **<mark>uint256</mark>** <mark>quantizedAmount</mark>
146 <mark>)</mark> **<mark>p u b l i c</mark>** <mark>notFrozen ()</mark>
147 <mark>{</mark>
148 <mark>`//`</mark> <mark>`No`</mark> <mark>`need`</mark> <mark>`to`</mark> <mark>`verify`</mark> <mark>`amount`</mark> <mark>`>`</mark> <mark>`0,`</mark> <mark>`a`</mark> <mark>`deposit`</mark> <mark>`with`</mark> <mark>`amount`</mark> <mark>`=`</mark> <mark>`0`</mark> <mark>`can`</mark> <mark>`be`</mark> <mark>`used`</mark> <mark>`to`</mark> <mark>`undo`</mark>
```
        cancellation .
```

149 **<mark>r e q u i r e</mark>** <mark>( v a u l t I d</mark> <mark><=</mark> <mark>MAX_VAULT_ID,</mark> <mark>`" OUT_OF_RANGE_VAULT_ID "`</mark> <mark>) ;</mark>
150 <mark>`//`</mark> <mark>`starkKey`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`registered.`</mark>
151 **<mark>r e q u i r e</mark>** <mark>( ethKeys [ starkKey ]</mark> <mark>!=</mark> <mark>ZERO_ADDRESS,</mark> <mark>`" INVALID_STARK_KEY "`</mark> <mark>) ;</mark>
152 **<mark>r e q u i r e</mark>** <mark>( !</mark> <mark>isMintableAssetType ( assetType )</mark> <mark>,</mark> <mark>`" MINTABLE_ASSET_TYPE "`</mark> <mark>) ;</mark>
153 **<mark>uint256</mark>** <mark>a s s e t I d</mark> <mark>=</mark> <mark>assetType</mark> <mark>;</mark>
154
155 <mark>`//`</mark> <mark>`Update`</mark> <mark>`the`</mark> <mark>`balance.`</mark>
156 <mark>pendingDeposits</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>+=</mark> <mark>quantizedAmount ;</mark>
157 **<mark>r e q u i r e</mark>** <mark>(</mark>
158 <mark>pendingDeposits</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>>=</mark> <mark>quantizedAmount</mark> <mark>,</mark>
159 <mark>`" DEPOSIT_OVERFLOW "`</mark>
160 <mark>) ;</mark>
161
162 <mark>`//`</mark> <mark>`Disable`</mark> <mark>`the`</mark> <mark>`timeout.`</mark>
163 **<mark>delete</mark>** <mark>c a n c e l l a t i o n R e q u e s t s</mark> <mark>[ starkKey</mark> <mark>] [</mark> <mark>a s s e t I d</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>] ;</mark>
164 <mark>}</mark>

Listing 3.13: interactions /Deposits. sol


**Recommendation** Ensure `isSenderStarkKey(starkKey)` before entering `Deposit()` . However, this

breaks the business logic of <u>depositing</u> <u>to</u> <u>an</u> <u>arbitrary</u> <u>`(starkKey,`</u> <u>`assetType,`</u> <u>`vaultId)`</u> <u>tuple.</u>


**Status** This issue has been fixed by checking the `msg.sender` in `Deposit()` before removing

the `cancellationRequests` entry in commit 2799231, which preserves the `deposit()` business logic

mentioned above.

##### **3.10 Typos in Comments**




- ID: PVE-010

- Severity: Informational

- Likelihood: N/A

- Impact: N/A


**Description**




- Target:

- Category: Coding Practices [5]

- CWE subcategory: CWE-1116 [3]



While reviewing the StarkEx V2 codebase, we occasionally identify typos in the comments around

the Solidity code. Here we list some cases only. The complete list of typos has been sent to the


23/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


team in a separate file.


**Case** **I** The comments in line 36 of the `ApprovalChain` contract: “in <u>te</u> chain”

20 **<mark>function</mark>** <mark>addEntry (</mark>
21 <mark>StarkExTypes . ApprovalChainData</mark> **<mark>storage</mark>** <mark>chain</mark> <mark>,</mark>
22 **<mark>address</mark>** <mark>entry</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>maxLength</mark> <mark>,</mark> **<mark>s t r i n g</mark>** **<mark>memory</mark>** <mark>i d e n t i f i e r</mark> <mark>)</mark>
23 **<mark>i n t e r n a l</mark>**
24 <mark>onlyGovernance ( )</mark>
25 <mark>notFrozen ()</mark>
26 <mark>{</mark>
27 **<mark>address</mark>** <mark>[ ]</mark> **<mark>storage</mark>** <mark>l i s t</mark> <mark>=</mark> <mark>chain</mark> <mark>.</mark> <mark>l i s t</mark> <mark>;</mark>
28 **<mark>r e q u i r e</mark>** <mark>( e n t r y</mark> <mark>.</mark> <mark>i s C o n t r a c t</mark> <mark>( )</mark> <mark>,</mark> <mark>`" ADDRESS_NOT_CONTRACT "`</mark> <mark>) ;</mark>
29 **<mark>bytes32</mark>** <mark>hash_real</mark> <mark>=</mark> **<mark>keccak256</mark>** <mark>( a b i</mark> <mark>. encodePacked (</mark> <mark>I d e n t i t y</mark> <mark>( e n t r y ) .</mark> <mark>i d e n t i f y</mark> <mark>() ) ) ;</mark>
30 **<mark>bytes32</mark>** <mark>h a s h _ i d e n t i f i e r</mark> <mark>=</mark> **<mark>keccak256</mark>** <mark>( a b i</mark> <mark>. encodePacked (</mark> <mark>i d e n t i f i e r</mark> <mark>) ) ;</mark>
31 **<mark>r e q u i r e</mark>** <mark>( hash_real</mark> <mark>==</mark> <mark>h a s h _ i d e n t i f i e r</mark> <mark>,</mark> <mark>`" UNEXPECTED_CONTRACT_IDENTIFIER "`</mark> <mark>) ;</mark>
32 **<mark>r e q u i r e</mark>** <mark>(</mark> <mark>l i s t</mark> <mark>.</mark> **<mark>length</mark>** <mark><</mark> <mark>maxLength</mark> <mark>,</mark> <mark>`" CHAIN_AT_MAX_CAPACITY "`</mark> <mark>) ;</mark>
33 **<mark>r e q u i r e</mark>** <mark>( f i n d E n t r y (</mark> <mark>l i s t</mark> <mark>,</mark> <mark>e n t r y )</mark> <mark>==</mark> <mark>ENTRY_NOT_FOUND,</mark> <mark>`" ENTRY_ALREADY_EXISTS "`</mark> <mark>) ;</mark>
34
35 <mark>`//`</mark> <mark>`Verifier`</mark> <mark>`must`</mark> <mark>`have`</mark> <mark>`at`</mark> <mark>`least`</mark> <mark>`one`</mark> <mark>`fact`</mark> <mark>`registered`</mark> <mark>`before`</mark> <mark>`adding`</mark> <mark>`to`</mark> <mark>`chain,`</mark>
36 <mark>`//`</mark> <mark>`unless`</mark> <mark>`it’s`</mark> <mark>`the`</mark> <mark>`first`</mark> <mark>`verifier`</mark> <mark>`in`</mark> <mark>`te`</mark> <mark>`chain.`</mark>

Listing 3.14: components/ApprovalChain.sol


**Case** **II** The comments in line 26 of the `FactRegistry` contract: “But the check is against the

local fact <u>registry,”</u>

23 <mark>`/*`</mark>
24 <mark>`This`</mark> <mark>`is`</mark> <mark>`an`</mark> <mark>`internal`</mark> <mark>`method`</mark> <mark>`to`</mark> <mark>`check`</mark> <mark>`if`</mark> <mark>`the`</mark> <mark>`fact`</mark> <mark>`is`</mark> <mark>`already`</mark> <mark>`registered .`</mark>
25 <mark>`In`</mark> <mark>`current`</mark> <mark>`implementation`</mark> <mark>`of`</mark> <mark>`FactRegistry`</mark> <mark>`it’s`</mark> <mark>`identical`</mark> <mark>`to`</mark> <mark>`isValid ().`</mark>
26 <mark>`But`</mark> <mark>`the`</mark> <mark>`check`</mark> <mark>`is`</mark> <mark>`against`</mark> <mark>`the`</mark> <mark>`local`</mark> <mark>`fact`</mark> <mark>`registry,`</mark>
27 <mark>`So`</mark> <mark>`for`</mark> <mark>`a`</mark> <mark>`derived`</mark> <mark>`referral`</mark> <mark>`fact`</mark> <mark>`registry,`</mark> <mark>`it’s`</mark> <mark>`not`</mark> <mark>`the`</mark> <mark>`same.`</mark>
28 <mark>`*/`</mark>
29 **<mark>function</mark>** <mark>_factCheck (</mark> **<mark>bytes32</mark>** <mark>f a c t )</mark>
30 **<mark>i n t e r n a l</mark>** **<mark>view</mark>**
31 **<mark>returns</mark>** <mark>(</mark> **<mark>bool</mark>** <mark>)</mark>
32 <mark>{</mark>
33 **<mark>return</mark>** <mark>v e r i f i e d F a c t</mark> <mark>[</mark> <mark>f a c t</mark> <mark>] ;</mark>
34 <mark>}</mark>

Listing 3.15: FactRegistry . sol


**Case** **III** The comments in line 7 * 8 of the `GpsFactRegistryAdapter` contract: “The GpsFac
tRegistryAdapter contract is used as an <u>adpater</u> between a Dapp contact and a GPS fact registry.

An isValid(fact) query is answered by <u>querying</u> the GPS contract about”

614 <mark>`/*`</mark>
615 <mark>`The`</mark> <mark>`GpsFactRegistryAdapter`</mark> <mark>`contract`</mark> <mark>`is`</mark> <mark>`used`</mark> <mark>`as`</mark> <mark>`an`</mark> <mark>`adpater`</mark> <mark>`between`</mark> <mark>`a`</mark> <mark>`Dapp`</mark> <mark>`contact`</mark> <mark>`and`</mark> <mark>`a`</mark>
```
       GPS fact
```

616 <mark>`registry.`</mark> <mark>`An`</mark> <mark>`isValid(fact)`</mark> <mark>`query`</mark> <mark>`is`</mark> <mark>`answered`</mark> <mark>`by`</mark> <mark>`querying`</mark> <mark>`the`</mark> <mark>`GPS`</mark> <mark>`contract`</mark> <mark>`about`</mark>
617 <mark>`new_fact`</mark> <mark>`:=`</mark> <mark>`keccak256(programHash,`</mark> <mark>`fact).`</mark>
618


24/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


619 <mark>`The`</mark> <mark>`goal`</mark> <mark>`of`</mark> <mark>`this`</mark> <mark>`contract`</mark> <mark>`is`</mark> <mark>`to`</mark> <mark>`simplify`</mark> <mark>`the`</mark> <mark>`verifier`</mark> <mark>`upgradeability`</mark> <mark>`logic`</mark> <mark>`in`</mark> <mark>`the`</mark> <mark>`Dapp`</mark>
```
       contract
```

620 <mark>`by`</mark> <mark>`making`</mark> <mark>`the`</mark> <mark>`upgrade`</mark> <mark>`flow`</mark> <mark>`the`</mark> <mark>`same`</mark> <mark>`regardless`</mark> <mark>`of`</mark> <mark>`whether`</mark> <mark>`the`</mark> <mark>`update`</mark> <mark>`is`</mark> <mark>`to`</mark> <mark>`the`</mark> <mark>`program`</mark>
```
       hash or
```

621 <mark>`the`</mark> <mark>`gpsContractAddress .`</mark>
622 <mark>`*/`</mark>
623 **<mark>contract</mark>** <mark>GpsFactRegistryAdapter</mark> **<mark>i s</mark>** <mark>I Q u e r y a b l e F a c t R e g i s t r y</mark> <mark>,</mark> <mark>I d e n t i t y</mark> <mark>{</mark>


Listing 3.16: GpsFactRegistryAdapter.sol


**Recommendation** Perform spell check on the comments.


**Status** This issue has been addressed in commit 2799231.


25/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**

## **4 | Conclusion**


In this audit, we have analyzed the design and implementation of the StarkEx V2 protocol, which

utilizes zkSTARK-based cryptographic proofs to scale up Ethereum on-chain transaction throughputs.

The system presents a clean and consistent design that makes it distinctive and valuable when

compared with current decentralized exchange protocols. During the audit, we notice that the

current code base is well organized and those identified issues are promptly confirmed and fixed.

Meanwhile, we need to emphasize that smart contracts as a whole are still in an early, but exciting

stage of development. To improve this report, we greatly appreciate any constructive feedbacks or

suggestions, on our methodology, audit findings, or potential gaps in scope/coverage.


26/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**

## **5 | Appendix**

##### **5.1 Basic Coding Bugs**


**5.1.1** **Constructor** **Mismatch**


  - <u>Description:</u> Whether the contract name and its constructor are not identical to each other.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Critical


**5.1.2** **Ownership** **Takeover**


  - <u>Description:</u> Whether the set owner function is not protected.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Critical


**5.1.3** **Redundant** **Fallback** **Function**


  - <u>Description:</u> Whether the contract has a redundant fallback function.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Critical


**5.1.4** **Overflows** **&** **Underflows**


  - <u>Description:</u> Whether the contract has general overflow or underflow vulnerabilities [9, 10, 11,

12, 14].


  - <u>Result:</u> Not found


  - <u>Severity:</u> Critical


27/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


**5.1.5** **Reentrancy**


  - <u>Description:</u> Reentrancy [15] is an issue when code can call back into your contract and change

state, such as withdrawing ETHs.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Critical


**5.1.6** **Money-Giving** **Bug**


  - <u>Description:</u> Whether the contract returns funds to an arbitrary address.


  - <u>Result:</u> Not found


  - <u>Severity:</u> High


**5.1.7** **Blackhole**


  - <u>Description:</u> Whether the contract locks ETH indefinitely: merely in without out.


  - <u>Result:</u> Not found


  - <u>Severity:</u> High


**5.1.8** **Unauthorized** **Self-Destruct**


  - <u>Description:</u> Whether the contract can be killed by any arbitrary address.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


**5.1.9** **Revert** **DoS**


  - <u>Description:</u> Whether the contract is vulnerable to DoS attack because of unexpected `revert` .


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


28/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


**5.1.10** **Unchecked** **External** `Call`


  - <u>Description:</u> Whether the contract has any external `call` without checking the return value.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


**5.1.11** **Gasless** `Send`


  - <u>Description:</u> Whether the contract is vulnerable to gasless `send` .


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


**5.1.12** `Send` **Instead** **Of** `Transfer`


  - <u>Description:</u> Whether the contract uses `send` instead of `transfer` .


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


**5.1.13** **Costly** **Loop**


  - <u>Description:</u> Whether the contract has any costly loop which may lead to `Out-Of-Gas` excep
tion.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


**5.1.14** **(Unsafe)** **Use** **Of** **Untrusted** **Libraries**


  - <u>Description:</u> Whether the contract use any suspicious libraries.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


29/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


**5.1.15** **(Unsafe)** **Use** **Of** **Predictable** **Variables**


  - <u>Description:</u> Whether the contract contains any randomness variable, but its value can be

predicated.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


**5.1.16** **Transaction** **Ordering** **Dependence**


  - <u>Description:</u> Whether the final state of the contract depends on the order of the transactions.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium


**5.1.17** **Deprecated** **Uses**


  - <u>Description:</u> Whether the contract use the deprecated `tx.origin` to perform the authorization.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Medium

##### **5.2 Semantic Consistency Checks**


  - <u>Description:</u> Whether the semantic of the white paper is different from the implementation of

the contract.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Critical

##### **5.3 Additional Recommendations**


**5.3.1** **Avoid** **Use** **of** **Variadic** **Byte** **Array**


  - <u>Description:</u> Use fixed-size byte array is better than that of `byte[]`, as the latter is a waste of

space.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Low


30/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


**5.3.2** **Make** **Visibility** **Level** **Explicit**


  - <u>Description:</u> Assign explicit visibility specifiers for functions and state variables.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Low


**5.3.3** **Make** **Type** **Inference** **Explicit**


  - <u>Description:</u> Do not use keyword `var` to specify the type, i.e., it asks the compiler to deduce

the type, which is not safe especially in a loop.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Low


**5.3.4** **Adhere** **To** **Function** **Declaration** **Strictly**


  - <u>Description:</u> Solidity compiler (version 0 _._ 4 _._ 23) enforces strict ABI length checks for return data

from `calls()` [1], which may break the the execution if the function implementation does NOT

follow its declaration (e.g., no return in implementing `transfer()` of ERC20 tokens).


  - <u>Result:</u> Not found


  - <u>Severity:</u> Low


31/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**

## **References**


[1] axic. Enforcing ABI length checks for return data from calls can be breaking. [https://github.](https://github.com/ethereum/solidity/issues/4116)


[com/ethereum/solidity/issues/4116.](https://github.com/ethereum/solidity/issues/4116)


[2] Steve Marx. Stop Using Solidity’s transfer() Now. [https://diligence.consensys.net/blog/2019/](https://diligence.consensys.net/blog/2019/09/stop-using-soliditys-transfer-now/)


[09/stop-using-soliditys-transfer-now/.](https://diligence.consensys.net/blog/2019/09/stop-using-soliditys-transfer-now/)


[3] MITRE. CWE-1116: Inaccurate Comments. [https://cwe.mitre.org/data/definitions/1116.html.](https://cwe.mitre.org/data/definitions/1116.html)


[4] MITRE. CWE-841: Improper Enforcement of Behavioral Workflow. [https://cwe.mitre.org/](https://cwe.mitre.org/data/definitions/841.html)


[data/definitions/841.html.](https://cwe.mitre.org/data/definitions/841.html)


[5] MITRE. CWE CATEGORY: Bad Coding Practices. [https://cwe.mitre.org/data/definitions/](https://cwe.mitre.org/data/definitions/1006.html)


[1006.html.](https://cwe.mitre.org/data/definitions/1006.html)


[6] MITRE. CWE CATEGORY: Business Logic Errors. [https://cwe.mitre.org/data/definitions/](https://cwe.mitre.org/data/definitions/840.html)


[840.html.](https://cwe.mitre.org/data/definitions/840.html)


[7] MITRE. CWE VIEW: Development Concepts. [https://cwe.mitre.org/data/definitions/699.](https://cwe.mitre.org/data/definitions/699.html)


[html.](https://cwe.mitre.org/data/definitions/699.html)


[8] OWASP. Risk Rating Methodology. [https://www.owasp.org/index.php/OWASP_Risk_](https://www.owasp.org/index.php/OWASP_Risk_Rating_Methodology)


[Rating_Methodology.](https://www.owasp.org/index.php/OWASP_Risk_Rating_Methodology)


[9] PeckShield. ALERT: New batchOverflow Bug in Multiple ERC20 Smart Contracts (CVE-2018

10299). [https://www.peckshield.com/2018/04/22/batchOverflow/.](https://www.peckshield.com/2018/04/22/batchOverflow/)


32/33 PeckShield Audit Report #: 2020-44


**<u>Public</u>**


[10] PeckShield. New burnOverflow Bug Identified in Multiple ERC20 Smart Contracts (CVE-2018

11239). [https://www.peckshield.com/2018/05/18/burnOverflow/.](https://www.peckshield.com/2018/05/18/burnOverflow/)


[11] PeckShield. New multiOverflow Bug Identified in Multiple ERC20 Smart Contracts (CVE-2018

10706). [https://www.peckshield.com/2018/05/10/multiOverflow/.](https://www.peckshield.com/2018/05/10/multiOverflow/)


[12] PeckShield. New proxyOverflow Bug in Multiple ERC20 Smart Contracts (CVE-2018-10376).


[https://www.peckshield.com/2018/04/25/proxyOverflow/.](https://www.peckshield.com/2018/04/25/proxyOverflow/)


[13] PeckShield. PeckShield Inc. [https://www.peckshield.com.](https://www.peckshield.com)


[14] PeckShield. Your Tokens Are Mine: A Suspicious Scam Token in A Top Exchange. [https:](https://www.peckshield.com/2018/04/28/transferFlaw/)


[//www.peckshield.com/2018/04/28/transferFlaw/.](https://www.peckshield.com/2018/04/28/transferFlaw/)


[15] Solidity. Warnings of Expressions and Control Structures. [http://solidity.readthedocs.io/en/](http://solidity.readthedocs.io/en/develop/control-structures.html)


[develop/control-structures.html.](http://solidity.readthedocs.io/en/develop/control-structures.html)


33/33 PeckShield Audit Report #: 2020-44


