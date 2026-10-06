# **Smart Contract Audit Report**

## Conducted by PeckShield

As part of our due process, we retained PeckShield to audit our smart contracts prior to
launching StarkEx, our scalability engine, on Ethereum Mainnet. We chose to work with
PeckShield based on warm recommendations, their ongoing public analyses of vulnerabilities on
Ethereum, and our interaction with them.


PeckShield has recently conducted their audit over a period of several weeks. Their audit has
revealed some minor issues, and the relevant issues were resolved to their satisfaction.


We are happy to share the key findings below, followed by the full report.

#### **Vulnerability Severity Classification**



High


Medium


Low

#### **Summary**



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


**3**


**8**


**12**


#### **Key Findings**

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


**PVE-012**



**Info.**


**Info.**


**Info.**


**Low**


**Info.**


**Low**


**Info.**


**Info.**


**Low**


**Info.**


**Info.**


**Medium**



**Implicit Assumption of FullWithdrawalRequests**


**Inconsistent Uses of SafeMath**


**Potential Integer Overflow in ApprovalChain**


**Possible Denial-of-Service in Registration**


**Misleading Comments about MVerifiers**


**Business Logic Inconsistency in Committee**


**starkKey, vaultId, tokenId Ordering**


**Redundant Timestamp Checks**


**Upgrades Depend on States of Old Versions in Proxy**


**Optimization Suggestions to Proxy**


**Optimization Suggestions to DexStatementVerifier**


**Possible Integer Overflow in DexStatementVerifier**



**RESOLVED**


**CONFIRMED**


**RESOLVED**


**RESOLVED**


**RESOLVED**


**RESOLVED**


**RESOLVED**


**CONFIRMED**


**RESOLVED**


**RESOLVED**


**RESOLVED**


**RESOLVED**


**<u>Confidential</u>**

### **SMART CONTRACT AUDIT REPORT**

#### **for**

### **STARKWARE INDUSTRIES LTD.**


**Prepared** **By:** **<u>Shuxiao</u>** **<u>Wang</u>**


**Hangzhou,** **China**

**Feb.** **26,** **2020**


1/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

#### **Document Properties**


**<u><mark>Client</mark></u>** <u>StarkWare</u> <u>Industries</u> <u>Ltd.</u>
**<u><mark>Title</mark></u>** <u>Smart</u> <u>Contract</u> <u>Audit</u> <u>Report</u>
**<u><mark>Target</mark></u>** <u>StarkEx</u>
**<u><mark>Version</mark></u>** <u>1.0</u>
**<u><mark>Author</mark></u>** <u>Chiachih</u> <u>Wu</u>
**<u><mark>Auditors</mark></u>** <u>Chiachih</u> <u>Wu,</u> <u>Xuxian</u> <u>Jiang</u>
**<u><mark>Reviewed</mark></u>** **<u><mark>by</mark></u>** <u>Jeff</u> <u>Liu</u>
**<u><mark>Approved</mark></u>** **<u><mark>by</mark></u>** <u>Xuxian</u> <u>Jiang</u>
**<u><mark>Classifcation</mark></u>** **i** <u>Confidential</u>

#### **Version Info**


**<u><mark>Version</mark></u>** **<u><mark>Date</mark></u>** **<u><mark>Author(s)</mark></u>** **<u><mark>Description</mark></u>**
<u>1.0</u> <u>Feb.</u> <u>26,</u> <u>2020</u> <u>Chiachih</u> <u>Wu</u> <u>Final</u> <u>Release</u>
<u>1.0-rc2</u> <u>Feb.</u> <u>26,</u> <u>2020</u> <u>Chiachih</u> <u>Wu</u> <u>Minor</u> <u>Revise</u>
<u>1.0-rc1</u> <u>Feb.</u> <u>17,</u> <u>2020</u> <u>Chiachih</u> <u>Wu</u> <u>Status</u> <u>Update</u>
<u>0.4</u> <u>Jan.</u> <u>21,</u> <u>2020</u> <u>Chiachih</u> <u>Wu</u> <u>Add</u> <u>More</u> <u>Findings</u>
<u>0.3</u> <u>Jan.</u> <u>14,</u> <u>2020</u> <u>Chiachih</u> <u>Wu</u> <u>Add</u> <u>More</u> <u>Findings</u>
<u>0.2</u> <u>Jan.</u> <u>7,</u> <u>2020</u> <u>Chiachih</u> <u>Wu</u> <u>Add</u> <u>More</u> <u>Findings</u>
<u>0.1</u> <u>Dec.</u> <u>31,</u> <u>2019</u> <u>Chiachih</u> <u>Wu</u> <u>Initial</u> <u>Draft</u>

#### **Contact**


For more information about this document and its contents, please contact PeckShield Inc.


**<u><mark>Name</mark></u>** <u>Shuxiao</u> <u>Wang</u>
**<u><mark>Phone</mark></u>** <u>+86</u> <u>173</u> <u>6454</u> <u>5338</u>
**<u><mark>Email</mark></u>** <u>contact@peckshield.com</u>


2/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

#### **Contents**


**1** **Introduction** **5**

1.1 About StarkEx . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5

1.2 About PeckShield . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6

1.3 Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6

1.4 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


**2** **Findings** **10**

2.1 Summary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10

2.2 Key Findings . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


**3** **Detailed** **Results** **12**

3.1 Implicit Assumption of FullWithdrawalRequests . . . . . . . . . . . . . . . . . . . . 12

3.2 Inconsistent Uses of SafeMath . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15

3.3 Potential Integer Overflow in ApprovalChain . . . . . . . . . . . . . . . . . . . . . . 16

3.4 Possible Denial-of-Service in Registration . . . . . . . . . . . . . . . . . . . . . . . . 17

3.5 Misleading Comments about MVerifiers . . . . . . . . . . . . . . . . . . . . . . . . . 18

3.6 Business Logic Inconsistency in Committee . . . . . . . . . . . . . . . . . . . . . . . 19

3.7 starkKey, vaultId, tokenId Ordering . . . . . . . . . . . . . . . . . . . . . . . . . . . 22

3.8 Redundant Timestamp Checks . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 23

3.9 Upgrades Depend on States of Old Versions in Proxy . . . . . . . . . . . . . . . . . 24

3.10 Optimization Suggestions to Proxy . . . . . . . . . . . . . . . . . . . . . . . . . . . 26

3.11 Optimization Suggestions to DexStatementVerifier . . . . . . . . . . . . . . . . . . . 27

3.12 Possible Integer Overflow in MerkleVerifier . . . . . . . . . . . . . . . . . . . . . . . 29

3.13 Other Suggestions . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 34


**4** **Conclusion** **35**


**5** **Appendix** **36**

5.1 Basic Coding Bugs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 36

5.1.1 Constructor Mismatch . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 36


3/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


5.1.2 Ownership Takeover . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 36

5.1.3 Redundant Fallback Function . . . . . . . . . . . . . . . . . . . . . . . . . . 36

5.1.4 Overflows & Underflows . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 36

5.1.5 Reentrancy . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 37

5.1.6 Money-Giving Bug . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 37

5.1.7 Blackhole . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 37

5.1.8 Unauthorized Self-Destruct . . . . . . . . . . . . . . . . . . . . . . . . . . . 37

5.1.9 Revert DoS . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 37

5.1.10 Unchecked External `Call` . . . . . . . . . . . . . . . . . . . . . . . . . . . . 38

5.1.11 Gasless `Send` . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 38

5.1.12 `Send` Instead Of `Transfer` . . . . . . . . . . . . . . . . . . . . . . . . . . . 38

5.1.13 Costly Loop . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 38

5.1.14 (Unsafe) Use Of Untrusted Libraries . . . . . . . . . . . . . . . . . . . . . . 38

5.1.15 (Unsafe) Use Of Predictable Variables . . . . . . . . . . . . . . . . . . . . . 39

5.1.16 Transaction Ordering Dependence . . . . . . . . . . . . . . . . . . . . . . . 39

5.1.17 Deprecated Uses . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 39

5.2 Semantic Consistency Checks . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 39

5.3 Additional Recommendations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 39

5.3.1 Avoid Use of Variadic Byte Array . . . . . . . . . . . . . . . . . . . . . . . . 39

5.3.2 Make Visibility Level Explicit . . . . . . . . . . . . . . . . . . . . . . . . . . 40

5.3.3 Make Type Inference Explicit . . . . . . . . . . . . . . . . . . . . . . . . . . 40

5.3.4 Adhere To Function Declaration Strictly . . . . . . . . . . . . . . . . . . . . 40


**References** **41**


4/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

## **1 | Introduction**


Given the opportunity to review the **StarkEx** design document and related smart contract source

code, we in the report outline our systematic approach to evaluate potential security issues in the

smart contract implementation, expose possible semantic inconsistencies between smart contract code

and design document, and provide additional suggestions or recommendations for improvement. Our

results show that the given version of smart contracts can be further improved due to the presence

of several issues related to either security or performance. This document outlines our audit results.

#### **1.1 About StarkEx**


StarkEx is a `zkSTARK` -powered scalability engine, which makes essential use of cryptographic proofs to

attest to the validity of a batch of ramp and trade transactions. The attestation allows for ensuring

the state consistency between the scalable off-chain, transaction-processing exchange service and the

on-chain DEX with transaction commitment (or finality). With that, StarkEx enables next-generation

exchanges that provide non-custodial trading at an unprecedented scale with high liquidity and low

costs.

The basic information of StarkEx is as follows:


Table 1.1: Basic Information of StarkEx


**<u><mark>Item</mark></u>** **<u><mark>Description</mark></u>**
<u>Issuer</u> <u>StarkWare</u> <u>Industries</u> <u>Ltd.</u>
<u>Website</u> <u>https://starkware.co/</u>
<u>Type</u> <u>Ethereum</u> <u>Smart</u> <u>Contract</u>
<u>Platform</u> <u>Solidity</u>
<u>Audit</u> <u>Method</u> <u>Whitebox</u>
<u>Latest</u> <u>Audit</u> <u>Report</u> <u>Feb.</u> <u>26,</u> <u>2020</u>


In the following, we show the Git repository of reviewed files and the commit hash value used in

this audit:


5/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


  - <u>https://github.com/starkware-industries/starkex</u> (7a8d0da)


  - <u>https://github.com/starkware-libs/starkex-contracts</u> (d6bde00)

#### **1.2 About PeckShield**


PeckShield Inc. [24] is a leading blockchain security company with the goal of elevating the secu
rity, privacy, and usability of current blockchain ecosystems by offering top-notch, industry-leading

services and products (including the service of smart contract auditing). We are reachable at Telegram

<u>(https://t.me/peckshield), Twitter (http://twitter.com/peckshield), or Email (contact@peckshield.com).</u>


Table 1.2: Vulnerability Severity Classification


_High_ Critical High Medium


_Medium_ <u>High</u> <u>Medium</u> <u>Low</u>


_Low_ <u>Medium</u> <u>Low</u> <u>Low</u>


_<u>High</u>_ _<u>Medium</u>_ _<u>Low</u>_


**Likelihood**

#### **1.3 Methodology**


To standardize the evaluation, we define the following terminology based on OWASP Risk Rating

Methodology [19]:


  - <u>Likelihood</u> represents how likely a particular vulnerability is to be uncovered and exploited in

the wild;


  - <u>Impact</u> measures the technical loss and business damage of a successful attack;


  - <u>Severity</u> demonstrates the overall criticality of the risk.


Likelihood and impact are categorized into three ratings: _H_, _M_ and _L_, i.e., _high_, _medium_ and

_low_ respectively. Severity is determined by likelihood and impact and can be classified into four

categories accordingly, i.e., _Critical_, _High_, _Medium_, _Low_ shown in Table 1.2.

To evaluate the risk, we go through a list of check items and each would be labeled with

a severity category. For one check item, if our tool or analysis does not identify any issue, the


6/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**



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



7/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


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

Enumeration (CWE-699) [18], which is a community-developed list of software weakness types to

better delineate and organize weaknesses around concepts frequently encountered in software devel
opment. Though some categories used in CWE-699 may not be relevant in smart contracts, we use

the CWE categories in Table 1.4 to classify our findings.

#### **1.4 Disclaimer**


Note that this audit does not give any warranties on finding all possible security issues of the given

smart contract(s), i.e., the evaluation result does not guarantee the nonexistence of any further

findings of security issues. As one audit cannot be considered comprehensive, we always recommend

proceeding with several independent audits and a public bug bounty program to ensure the security

of smart contract(s). Last but not least, this security audit should not be used as an investment

advice.


8/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


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


9/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

## **2 | Findings**

#### **2.1 Summary**


Here is a summary of our findings after analyzing the StarkEx implementation. During the first

phase of our audit, we studied the smart contract source code and ran our in-house static code

analyzer through the codebase. The purpose here is to statically identify known coding bugs, and

then manually verify (reject or confirm) issues reported by our tool. We further manually review

business logics, examine system operations, and place DeFi-related aspects under scrutiny to uncover

possible pitfalls and/or bugs.


**<u>Severity</u>** **<u>#</u>** **<u>of</u>** **<u>Findings</u>**

<u>Critical</u> <u>0</u>

<u>High</u> <u>0</u>

<u>Medium</u> <u>1</u>

<u>Low</u> <u>3</u>

<u>Informational</u> <u>8</u>

<u>Total</u> <u>12</u>


We have so far identified a list of potential issues: some of them involve subtle corner cases that might

not be previously thought of, while others refer to unusual interactions among multiple contracts.

For each uncovered issue, we have therefore developed test cases for reasoning, reproduction, and/or

verification. After further analysis and internal discussion, we determined a few issues of varying

severities need to be brought up and paid more attention to, which are categorized in the above

table. <u>All</u> <u>of</u> <u>the</u> <u>issues</u> <u>have</u> <u>be</u> <u>resolved,</u> <u>except</u> <u>the</u> <u>two</u> <u>inconsequential</u> <u>ones.</u> More information can

be found in the next subsection, and the detailed discussions of each of them are in Section 3.


10/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

#### **2.2 Key Findings**


Overall, these smart contracts are well-designed and engineered, though the implementation can

be improved by resolving the identified issues (shown in Table 2.1), including 1 medium-severity

vulnerability, 3 low-severity vulnerabilities, and 8 informational recommendations.


Table 2.1: Key Audit Findings


**<u><mark>ID</mark></u>** **<u><mark>Severity</mark></u>** **<u><mark>Title</mark></u>** **<u><mark>Category</mark></u>** **<u><mark>Status</mark></u>**
<u>PVE-001</u> <u>Info.</u> <u>Implicit</u> <u>Assumption</u> <u>of</u> <u>FullWithdrawalRequests</u> <u>Arg.s</u> <u>and</u> <u>Parameters</u> <u>Resolved</u>
<u>PVE-002</u> <u>Info.</u> <u>Inconsistent</u> <u>Uses</u> <u>of</u> <u>SafeMath</u> <u>Coding</u> <u>Practices</u> <u>Confirmed</u>
<u>PVE-003</u> <u>Info.</u> <u>Potential</u> <u>Integer</u> <u>Overflow</u> <u>in</u> <u>ApprovalChain</u> <u>Numeric</u> <u>Errors</u> <u>Resolved</u>
<u>PVE-004</u> <u>Low</u> <u>Possible</u> <u>Denial-of-Service</u> <u>in</u> <u>Registration</u> <u>Business</u> <u>Logic</u> <u>Errors</u> <u>Resolved</u>
<u>PVE-005</u> <u>Info.</u> <u>Misleading</u> <u>Comments</u> <u>about</u> <u>MVerifiers</u> <u>Coding</u> <u>Practices</u> <u>Resolved</u>
<u>PVE-006</u> <u>Low</u> <u>Business</u> <u>Logic</u> <u>Inconsistency</u> <u>in</u> <u>Committee</u> <u>Behavioral</u> <u>Issues</u> <u>Resolved</u>
<u>PVE-007</u> <u>Info.</u> <u>starkKey,</u> <u>vaultId,</u> <u>tokenId</u> <u>Ordering</u> <u>Coding</u> <u>Practices</u> <u>Resolved</u>
<u>PVE-008</u> <u>Info.</u> <u>Redundant</u> <u>Timestamp</u> <u>Checks</u> <u>Coding</u> <u>Practices</u> <u>Confirmed</u>
<u>PVE-009</u> <u>Low</u> <u>Upgrades</u> <u>Depend</u> <u>on</u> <u>States</u> <u>of</u> <u>Old</u> <u>Versions</u> <u>in</u> <u>Proxy</u> <u>Data</u> <u>Integrity</u> <u>Issues</u> <u>Resolved</u>
<u>PVE-010</u> <u>Info.</u> <u>Optimization</u> <u>Suggestions</u> <u>to</u> <u>Proxy</u> <u>Coding</u> <u>Practices</u> <u>Resolved</u>
<u>PVE-011</u> <u>Info.</u> <u>Optimization</u> <u>Suggestions</u> <u>to</u> <u>DexStatementVerifier</u> <u>Coding</u> <u>Practices</u> <u>Resolved</u>
<u>PVE-012</u> <u>Medium</u> <u>Possible</u> <u>Integer</u> <u>Overflow</u> <u>in</u> <u>DexStatementVerifier</u> <u>Numeric</u> <u>Errors</u> <u>Resolved</u>


Please refer to Section 3 for details.


11/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


## **3 | Detailed Results**

#### **3.1 Implicit Assumption of FullWithdrawalRequests**




- ID: PVE-001

- Severity: Informational

- Likelihood: N/A

- Impact: N/A


**Description**




- Target: `interactions/UpdateState.sol`

- Category: Arg.s and Parameters [17]

- CWE subcategory: CWE-628 [10]



The StarkEx contract keeps track of the execution state of the off-chain exchange service by storing

Merkle roots of the vault state (off-chain account state) and the order state (including fully executed

and partially fulfilled orders). It is achieved by the operator responsibly initiating a series of state
updating operations, i.e., `updateState` . However, the implementation has an implicit assumption that

is not documented or evident from the codebase. This assumption, if non-present, could lead to to

unauthorized removal of legitimate full withdraw requests.

Specifically, when an operator performs `updateState`, this operation requires two parameters as

its input: `publicInput` and `applicationData` . Note the first parameter is properly verified by both

`Integrity` `Verifiers` and `Availability` `Verifiers` . But the second parameter is blindly trusted and

may be misused for unintended uses, if the above-mentioned assumption is not present.


92 **<mark>function</mark>** <mark>performUpdateState (</mark>
93 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>p u b l i c I n p u t</mark> <mark>,</mark>
94 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>a p p l i c a t i o n D a t a</mark>
95 <mark>)</mark>
96 **<mark>i n t e r n a l</mark>**
97 <mark>{</mark>
98 <mark>rootUpdate (</mark>
99 <mark>p u b l i c I n p u t</mark> <mark>[OFFSET_VAULT_INITIAL_ROOT]</mark> <mark>,</mark>
100 <mark>p u b l i c I n p u t</mark> <mark>[OFFSET_VAULT_FINAL_ROOT]</mark> <mark>,</mark>
101 <mark>p u b l i c I n p u t</mark> <mark>[OFFSET_ORDER_INITIAL_ROOT]</mark> <mark>,</mark>
102 <mark>p u b l i c I n p u t</mark> <mark>[OFFSET_ORDER_FINAL_ROOT]</mark> <mark>,</mark>
103 <mark>p u b l i c I n p u t</mark> <mark>[OFFSET_VAULT_TREE_HEIGHT]</mark> <mark>,</mark>


12/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


104 <mark>p u b l i c I n p u t</mark> <mark>[OFFSET_ORDER_TREE_HEIGHT]</mark>
105 <mark>) ;</mark>
106 <mark>s e n d M o d i f i c a t i o n s ( p u b l i c I n p u t</mark> <mark>,</mark> <mark>a p p l i c a t i o n D a t a ) ;</mark>
107 <mark>}</mark>


Listing 3.1: interactions /UpdateState.sol


In particular, the second parameter `applicationData` is directly passed to the `performUpdateState()`

routine, and then further dribbled down to `sendModifications()` . In the following, we list the related

code snippets.


124 **<mark>f o r</mark>** <mark>(</mark> **<mark>uint256</mark>** <mark>i</mark> <mark>=</mark> <mark>0 ;</mark> <mark>i</mark> <mark><</mark> <mark>n M o d i f i c a t i o n s</mark> <mark>;</mark> <mark>i ++)</mark> <mark>{</mark>
125 **<mark>uint256</mark>** <mark>m o d i f i c a t i o n O f f s e t</mark> <mark>=</mark> <mark>OFFSET_MODIFICATION_DATA</mark> <mark>+</mark> <mark>i</mark> <mark>∗</mark>
<mark>N_WORDS_PER_MODIFICATION;</mark>
126 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>=</mark> <mark>p u b l i c I n p u t</mark> <mark>[</mark> <mark>m o d i f i c a t i o n O f f s e t</mark> <mark>] ;</mark>
127 **<mark>uint256</mark>** <mark>requestingKey</mark> <mark>=</mark> <mark>a p p l i c a t i o n D a t a</mark> <mark>[</mark> <mark>i</mark> <mark>+</mark> <mark>1 ] ;</mark>
128 **<mark>uint256</mark>** <mark>tokenId</mark> <mark>=</mark> <mark>p u b l i c I n p u t</mark> <mark>[</mark> <mark>m o d i f i c a t i o n O f f s e t</mark> <mark>+</mark> <mark>1 ] ;</mark>
129
130 **<mark>r e q u i r e</mark>** <mark>( starkKey</mark> <mark><</mark> <mark>K_MODULUS,</mark> <mark>`"Stark`</mark> <mark>`key`</mark> <mark>`>=`</mark> <mark>`PRIME"`</mark> <mark>) ;</mark>
131 **<mark>r e q u i r e</mark>** <mark>( requestingKey</mark> <mark><</mark> <mark>K_MODULUS,</mark> <mark>`" Requesting`</mark> <mark>`key`</mark> <mark>`>=`</mark> <mark>`PRIME"`</mark> <mark>) ;</mark>
132 **<mark>r e q u i r e</mark>** <mark>( tokenId</mark> <mark><</mark> <mark>K_MODULUS,</mark> <mark>`"Token`</mark> <mark>`id`</mark> <mark>`>=`</mark> <mark>`PRIME"`</mark> <mark>) ;</mark>
133
134 **<mark>uint256</mark>** <mark>actionParams</mark> <mark>=</mark> <mark>p u b l i c I n p u t</mark> <mark>[</mark> <mark>m o d i f i c a t i o n O f f s e t</mark> <mark>+</mark> <mark>2 ] ;</mark>
135 **<mark>uint256</mark>** <mark>amountBefore</mark> <mark>=</mark> <mark>( actionParams</mark> <mark>>></mark> <mark>192)</mark> <mark>&</mark> <mark>((1</mark> <mark><<</mark> <mark>63)</mark> <mark>*</mark> <mark>1) ;</mark>
136 **<mark>uint256</mark>** <mark>amountAfter</mark> <mark>=</mark> <mark>( actionParams</mark> <mark>>></mark> <mark>128)</mark> <mark>&</mark> <mark>((1</mark> <mark><<</mark> <mark>63)</mark> <mark>*</mark> <mark>1) ;</mark>
137 **<mark>uint256</mark>** <mark>v a u l t I d</mark> <mark>=</mark> <mark>( actionParams</mark> <mark>>></mark> <mark>96)</mark> <mark>&</mark> <mark>((1</mark> <mark><<</mark> <mark>31)</mark> <mark>*</mark> <mark>1) ;</mark>
138
139 **<mark>i f</mark>** <mark>( requestingKey</mark> <mark>!=</mark> <mark>0)</mark> <mark>{</mark>
140 <mark>`//`</mark> <mark>`This`</mark> <mark>`is`</mark> <mark>`a`</mark> <mark>`false`</mark> <mark>`full`</mark> <mark>`withdrawal.`</mark>
141 **<mark>r e q u i r e</mark>** <mark>(</mark>
142 <mark>starkKey</mark> <mark>!=</mark> <mark>requestingKey</mark> <mark>,</mark>
143 <mark>`"False`</mark> <mark>`full`</mark> <mark>`withdrawal`</mark> <mark>`requesting_key`</mark> <mark>`should`</mark> <mark>`differ`</mark> <mark>`from`</mark> <mark>`the`</mark> <mark>`vault`</mark>
<mark>`owner`</mark> <mark>`key."`</mark> <mark>) ;</mark>
144 **<mark>r e q u i r e</mark>** <mark>( amountBefore</mark> <mark>==</mark> <mark>amountAfter</mark> <mark>,</mark> <mark>`"Amounts`</mark> <mark>`differ`</mark> <mark>`in`</mark> <mark>`false`</mark> <mark>`full`</mark>
<mark>`withdrawal ."`</mark> <mark>) ;</mark>
145 <mark>c l e a r F u l l W i t h d r a w a l R e q u e s t ( requestingKey</mark> <mark>,</mark> <mark>v a u l t I d ) ;</mark>
146 **<mark>continue</mark>** <mark>;</mark>
147 <mark>}</mark>


Listing 3.2: interactions /UpdateState.sol


Notice that `requestingKey` is directly derived from `applicationData` (line 127.): `requestingKey`

`=` `applicationData[i` `+` `1]` . Its validity needs to be properly checked before the sensitive function

(line 145), i.e., `clearFullWithdrawalRequest(requestingKey,` `vaultId)`, is invoked. However, current

implementation does not enforce strict verification. If a false full withdrawal might be crafted to

bear the same `vaultId` with a legitimate full withdrawal request, the legitimate request can then be

cleared. To block this, the system has an implicit assumption that at any given time there is a unique

mapping from `vaultId` to `starkKey` and that < `vaultId`, `starkKey`   - pairs in the public input always

correspond to the real mapping.


13/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


We highlight this particular assumption is essential and needs to be be explicitly documented. If

without this assumption, assuming the operator may be fully compromised, legitimate full withdrawal

requests can always be cleared. Here is a possible attack scenario:


1. A normal user `Alice` submits a legitimate `fullWithdrawalRequest`, say _Ralice_, with _vaultIdAlice_
as its `vaultId` argument. Internally, the contract records the request in the following data

structure: _fullW ithdrawalRequests_ [ _starkKeyAlice_ ][ _vaultIdAlice_ ] = _now_ .

2. The operator `Bob` observes _Ralice_ and her goal here is to clear _Ralice_ . Note that the con
tract is designed to prevent any unauthorized removal, even for a rogue operator. Other
wise, no normal user is able to perform `fullWithdrawalRequest`, and then `freezeRequest` (after

`FREEZE_GRACE_PERIOD` without fulfillment from the operator) to freeze the contract. In the con
text of our scenario, by the intended design, `Bob` should not be able to clear `Alice` ’s legitimate,

non-false, `fullWithdrawalRequest` : _Ralice_ . However, based on current implementation, we show

`Bob` is able to clear _Ralice_, i.e., _fullW ithdrawalRequests_ [ _starkKeyAlice_ ][ _vaultIdAlice_ ] = 0.

To achieve that, `Bob` asks an accomplice `Malice` to submit a false `fullWithdrawalRequest`, say

_Rmalice_, with _vaultIdmalice_ as its `vaultId` argument. Similarly, the contract internally records the

request in _fullW ithdrawalRequests_ [ _starkKeyMalice_ ][ _vaultIdMalice_ ] = _now_ . We emphasize

_Rmalice_ is a false full withdrawal request, but is intentionally crafted with the same `vaultId`

argument, i.e., _vaultIdmalice_ = _vaultIdalice_ . Note _Ralice_ and _Rmalice_ are two different requests

regarding two different vaults! These two vaults have different `starkKey` values, but share the

same `vaultId` number. (Note this is impossible in reality because of the implicit assumption.)

3. Before _Ralice_ ’s `FREEZE_GRACE_PERIOD` (7 days) expires, `Bob` prepares a malicious state update. For

the prepared `updateState`, it recognizes _Rmalice_ as the false full withdrawal, but crafted in the

`applicationData` argument with _requestingKeycraft_ occupying the corresponding modification

slot that belongs to _Rmalice_ . As the modification slot belongs to _Rmalice_, it naturally satisfies

the requirement of `require(amountBefore` `==` `amountAfter)` . Moreover, as there is no validity

check regarding `requestingKey`, _requestingKeycraft_ can be arbitrarily chosen by the operator.

In this scenario, `Bob` chooses `Alice` ’s `starkKey`, i.e., _requestingKeycraft_ = _starkKeyAlice_ .



4. After the preparation, `Bob` submits `updateState` . When encountering the _Rmalice_ ’s modification



slot, since _requestingKeycraft_ ! = 0, the contract further verifies two specific requirements:



_require_ ( _starkKey_ ! = _requestingKeycraft_ ) (Condition I) and _require_ ( _amountBefore_ == _amountAfter_ )



(Condition II). Condition I is satisfied because _starkKey_ = _starkKeymalice_, which is different

from _requestingKeycraft_ = _starkKeyAlice_ . Condition II is also satisfied because this slot be


longs to _Rmalice_ and it is a false full withdrawal request. Consequently, the contract is tricked

to execute the sensitive function    - `clearFullWithdrawalRequest(requestingKey,` `vaultId)` . No
tice the arguments here: _requestingKey_ = _requestingKeycraft_ = _starkKeyAlice_ and _vaultId_ =


14/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


_vaultIdmalice_ = _vaultIdalice_ . As a result, _fullW ithdrawalRequests_ [ _starkKeyAlice_ ][ _vaultIdAlice_ ] =

0, which means the operator `Bob` successfully clears the legitimate full withdrawal request _Ralice_
from `Alice` .


**Recommendation** Make the implicit assumption explicit. This had been addressed in the

patched `UpdateState.sol` by adding comments saying that the verified publicInput implies that the

vaultId is currently owned by the starkKey.

#### **3.2 Inconsistent Uses of SafeMath**




- ID: PVE-002

- Severity: Informational

- Likelihood: N/A

- Impact: N/A


**Description**




- Target: `components/Tokens.sol`

- Category: Coding Practices [12]

- CWE subcategory: CWE-1076 [4]



Throughout the StarkEx codebase, many of the arithmetic operations follow the best practice of

utilizing the `SafeMath` . However, there’re some functions which do not follow the coding style but

detect the overflow scenarios in their own ways, which makes the codebase slightly less consistent.

**Case** **I** Line 90-92 of `Deposits::deposit()` .


90 <mark>`//`</mark> <mark>`Update`</mark> <mark>`the`</mark> <mark>`balance.`</mark>
91 <mark>pendingDeposits</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>tokenId</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>+=</mark> <mark>quantizedAmount ;</mark>
92 **<mark>r e q u i r e</mark>** <mark>( pendingDeposits</mark> <mark>[ starkKey</mark> <mark>] [</mark> <mark>tokenId</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>]</mark> <mark>>=</mark> <mark>quantizedAmount</mark> <mark>,</mark>

<mark>DEPOSIT_OVERFLOW) ;</mark>


Listing 3.3: interactions /Deposits. sol


**Case** **II** Line 109-111 of `Withdrawals::allowWithdrawal()` .


109 <mark>`//`</mark> <mark>`Add`</mark> <mark>`accepted`</mark> <mark>`quantized`</mark> <mark>`amount.`</mark>
110 <mark>withdrawal</mark> <mark>+=</mark> <mark>quantizedAmount ;</mark>
111 **<mark>r e q u i r e</mark>** <mark>( withdrawal</mark> <mark>>=</mark> <mark>quantizedAmount</mark> <mark>,</mark> <mark>WITHDRAWAL_OVERFLOW) ;</mark>


Listing 3.4: interactions /Withdrawals.sol


**Case** **III** Line 104-106 of `FullWithdrawals::freezeRequest()` .


104 <mark>`//`</mark> <mark>`Verify`</mark> <mark>`timer`</mark> <mark>`on`</mark> <mark>`escape`</mark> <mark>`request.`</mark>
105 **<mark>uint256</mark>** <mark>freezeTime</mark> <mark>=</mark> <mark>requestTime</mark> <mark>+</mark> <mark>FREEZE_GRACE_PERIOD;</mark>
106 **<mark>a s s e r t</mark>** <mark>( freezeTime</mark> <mark>>=</mark> <mark>FREEZE_GRACE_PERIOD) ;</mark>


Listing 3.5: interactions /FullWithdrawals. sol


15/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


**Recommendation** Make consistent uses of `SafeMath` to detect and block various overflow

scenarios.

#### **3.3 Potential Integer Overfowl in ApprovalChain**




- ID: PVE-003

- Severity: Informational

- Likelihood: None

- Impact: Medium


**Description**




- Target: `components/ApprovalChain.sol`

- Category: Numeric Errors [16]

- CWE subcategory: CWE-190 [7]



The ApprovalChain uses a `unlockedForRemovalTime[]` array to store the removal time as well as the in
tention to remove an entry. However, while announcing the removal intention, the `announceRemovalIntent`

`()` fails to check if the third parameter, `removalDelay`, makes the calculation overflow in line 58.

If a caller of `announceRemovalIntent()` happens to pass in a large `removalDelay` that makes `now` `+`

`removalDelay` overflow, the `removeEntry()` could not function properly. Fortunately, all the current

callers throughout the StarkEx codebase invoke `announceRemovalIntent()` with a constant `removalDelay`

. We suggest the `announceRemovalIntent()` itself checks the overflow instead of ensuring the correct

functionality by the callers.


50 **<mark>function</mark>** <mark>announceRemovalIntent (</mark>
51 <mark>ApprovalChainData</mark> **<mark>storage</mark>** <mark>chain</mark> <mark>,</mark> **<mark>address</mark>** <mark>entry</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>removalDelay )</mark>
52 **<mark>i n t e r n a l</mark>**
53 <mark>onlyGovernance ( )</mark>
54 <mark>notFrozen ()</mark>
55 <mark>{</mark>
56 <mark>s a f e F i n d E n t r y ( chain</mark> <mark>.</mark> <mark>l i s t</mark> <mark>,</mark> <mark>e n t r y ) ;</mark>
57 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
58 <mark>chain</mark> <mark>. unlockedForRemovalTime [</mark> <mark>e n t r y</mark> <mark>]</mark> <mark>=</mark> **<mark>now</mark>** <mark>+</mark> <mark>removalDelay</mark> <mark>;</mark>
59 <mark>}</mark>


Listing 3.6: components/ApprovalChain.sol


**Recommendation** Ensure `now` `+` `removalDelay` would not overflow. This had been addressed in

the patched `components/ApprovalChain.sol` .


50 **<mark>function</mark>** <mark>announceRemovalIntent (</mark>
51 <mark>ApprovalChainData</mark> **<mark>storage</mark>** <mark>chain</mark> <mark>,</mark> **<mark>address</mark>** <mark>entry</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>removalDelay )</mark>
52 **<mark>i n t e r n a l</mark>**
53 <mark>onlyGovernance ( )</mark>
54 <mark>notFrozen ()</mark>
55 <mark>{</mark>
56 <mark>s a f e F i n d E n t r y ( chain</mark> <mark>.</mark> <mark>l i s t</mark> <mark>,</mark> <mark>e n t r y ) ;</mark>


16/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**



57 **<mark>r e q u i r e</mark>** <mark>(</mark> **<mark>now</mark>** <mark>+</mark> <mark>removalDelay</mark> <mark>></mark> **<mark>now</mark>** <mark>,</mark> <mark>`" INVALID_REMOVALDELAY "`</mark> <mark>) ;</mark>
58 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
59 <mark>chain</mark> <mark>. unlockedForRemovalTime [</mark> <mark>e n t r y</mark> <mark>]</mark> <mark>=</mark> **<mark>now</mark>** <mark>+</mark> <mark>removalDelay</mark> <mark>;</mark>
60 <mark>}</mark>


Listing 3.7: components/ApprovalChain.sol

#### **3.4 Possible Denial-of-Service in Registration**




- ID: PVE-004

- Severity: Low

- Likelihood: Low

- Impact: Low


**Description**




- Target: `components/Users.sol`

- Category: Business Logic Errors[14]

- CWE subcategory: CWE-754 [11]



Since users of Stark Exchange are identified within the exchange by their Stark Key, each user needs

to invoke `register()` with a `starkKey` generated off-chain before any other user operation can take

place. As shown in the following code snippets, when an user `register()` himself with a `starkKey`,

the availability of the `starkKey` is checked in line 70 followed by the sanity checks which validate the

`starkKey` . It means if Alice can somehow get _starkKeyBob_ before Bob `register()` himself, she can

occupy `etherKeys` [ _starkKeyBob_ ] in line 76 and make Bob’s registration fail in line 70. This could be

done by front-running.


60 **<mark>function</mark>** <mark>r e g i s t e r</mark> <mark>(</mark>
61 **<mark>uint256</mark>** <mark>starkKey</mark>
62 <mark>)</mark>
63 **<mark>external</mark>**
64 <mark>{</mark>
65 <mark>`//`</mark> <mark>`Validate`</mark> <mark>`keys`</mark> <mark>`and`</mark> <mark>`availability .`</mark>
66 **<mark>address</mark>** <mark>etherKey</mark> <mark>=</mark> **<mark>msg</mark>** <mark>.</mark> **<mark>sender</mark>** <mark>;</mark>
67 **<mark>r e q u i r e</mark>** <mark>( etherKey</mark> <mark>!=</mark> <mark>ZERO_ADDRESS,</mark> <mark>INVALID_ETHER_KEY) ;</mark>
68 **<mark>r e q u i r e</mark>** <mark>( starkKey</mark> <mark>!=</mark> <mark>0,</mark> <mark>INVALID_STARK_KEY) ;</mark>
69 **<mark>r e q u i r e</mark>** <mark>( starkKeys</mark> <mark>[ etherKey ]</mark> <mark>==</mark> <mark>0,</mark> <mark>ETHER_KEY_UNAVAILABLE) ;</mark>
70 **<mark>r e q u i r e</mark>** <mark>( etherKeys</mark> <mark>[ starkKey</mark> <mark>]</mark> <mark>==</mark> <mark>ZERO_ADDRESS,</mark> <mark>STARK_KEY_UNAVAILABLE) ;</mark>
71 **<mark>r e q u i r e</mark>** <mark>( starkKey</mark> <mark><</mark> <mark>K_MODULUS,</mark> <mark>INVALID_STARK_KEY) ;</mark>
72 **<mark>r e q u i r e</mark>** <mark>( isOnCurve ( starkKey )</mark> <mark>,</mark> <mark>INVALID_STARK_KEY) ;</mark>


74 <mark>`//`</mark> <mark>`Update`</mark> <mark>`state.`</mark>
75 <mark>starkKeys</mark> <mark>[ etherKey ]</mark> <mark>=</mark> <mark>starkKey</mark> <mark>;</mark>
76 <mark>etherKeys</mark> <mark>[ starkKey</mark> <mark>]</mark> <mark>=</mark> <mark>etherKey</mark> <mark>;</mark>


78 <mark>`//`</mark> <mark>`Log`</mark> <mark>`new`</mark> <mark>`user.`</mark>
79 **<mark>emit</mark>** <mark>LogUserRegistered ( etherKey</mark> <mark>,</mark> <mark>starkKey ) ;</mark>


17/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


80 <mark>}</mark>


Listing 3.8: components/Users.sol


Since an Ethereum transaction would stay in the mempool for a while before it is included in a

block, Alice can always get Bob’s valid starkKey before Bob’s `register()` operation being included

in a block and somehow `register()` in front of Bob (e.g., by assigning a higher gas price). In an

extreme case, Alice can monitor the mempool and `register()` every `starkKey` she identifies, leading

to denial-of-service attacks.


**Recommendation** Looks like there’s no efficient way to solve this issue. One possible solution

is raising the price of launching the attack by burning some gas in each `register()` operation. The

patched `register()` has two input parameters, `starkKey` and `signature`, while the latter is used to

validate the 3-tuple `(starkKey,etherKey,signature)` can’t be fabricated. Besides, the permissions of

the `signer` derived from the input `(starkKey,etherKey,signature)` is limited by the `userAdmins` mapping

which can only be set by the `Governor` . This essentially removes the attack surface to trigger the

DoS attack against the old implementation.

#### **3.5 Misleading Comments about MVerifersi**




- ID: PVE-005

- Severity: Informational

- Likelihood: N/A

- Impact: N/A


**Description**




- Target: `AvailabilityVerifiers`,
```
 Verifiers
```

- Category: Coding Practice [12]

- CWE subcategory: CWE-1116 [6]



In StarkEx codebase, the convention of declaring the exported interfaces of a contract `Xyz` is im
plementing another contract named `MXyz` . For example, the `MApprovalChain` contract defines the

interfaces such as `addEntry(),` `findEntry(),` `etc` and the `ApprovalChain` contract implements the real

function logic. Based on the above convention, we identified an abnormal case   - `MVerifiers` .


32 <mark>`/*`</mark>
33 <mark>`Implements`</mark> <mark>`MVerifiers .`</mark>
34 <mark>`*/`</mark>
35 **<mark>contract</mark>** <mark>A v a i l a b i l i t y V e r i f i e r s</mark> **<mark>i s</mark>** <mark>MainStorage</mark> <mark>,</mark> <mark>MApprovalChain</mark> <mark>,</mark> <mark>LibConstants</mark> <mark>{</mark>


Listing 3.9: AvailabilityVerifiers . sol


29 <mark>`/*`</mark>
30 <mark>`Implements`</mark> <mark>`MVerifiers .`</mark>
31 <mark>`*/`</mark>


18/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


32 **<mark>contract</mark>** <mark>V e r i f i e r s</mark> **<mark>i s</mark>** <mark>MainStorage</mark> <mark>,</mark> <mark>MApprovalChain</mark> <mark>,</mark> <mark>LibConstants</mark> <mark>{</mark>


Listing 3.10: Verifiers . sol


As shown in the above code snippets, `AvailabilityVerifiers` and `Verifiers` seem to implement

`MVerifiers` . However, there’s no `MVerifiers.sol` in the `interfaces` directory. Moreover, the usage

of `AvailabilityVerifiers` and `Verifiers` are implemented as directly inherit those two contracts as

follows.


20 **<mark>contract</mark>** <mark>StarkExchange</mark> **<mark>i s</mark>**
21 <mark>L i b E r r o r s</mark> <mark>,</mark>
22 <mark>I V e r i f i e r A c t i o n s</mark> <mark>,</mark>
23 <mark>MainGovernance</mark> <mark>,</mark>
24 <mark>ApprovalChain</mark> <mark>,</mark>
25 <mark>A v a i l a b i l i t y V e r i f i e r s</mark> <mark>,</mark>
26 <mark>Operator</mark> <mark>,</mark>
27 <mark>Freezable</mark> <mark>,</mark>
28 <mark>Tokens</mark> <mark>,</mark>
29 <mark>Users</mark> <mark>,</mark>
30 <mark>StateRoot</mark> <mark>,</mark>
31 <mark>Deposits</mark> <mark>,</mark>
32 <mark>V e r i f i e r s</mark> <mark>,</mark>
33 <mark>Withdrawals</mark> <mark>,</mark>
34 <mark>FullWithdrawals</mark> <mark>,</mark>
35 <mark>Escapes</mark> <mark>,</mark>
36 <mark>UpdateState</mark>
37 <mark>{</mark>


Listing 3.11: StarkExchange.sol


It seems `MVerifiers` is obsolete throughout the StarkEx codebase.


**Recommendation** Refine the comments in `AvailabilityVerifiers` and `Verifiers` contracts.

This had been addressed in the patches.

#### **3.6 Business Logic Inconsistency in Committee**




- ID: PVE-006

- Severity: Low

- Likelihood: Low

- Impact: Low


**Description**




- Target: `Committee`

- Category: Behavioral Issues [13]

- CWE subcategory: CWE-440 [8]



The `Commitee` contract is constructed with a list of `committeeMembers` and `numSignaturesRequired` which

is less than or equal to the number of `committeeMembers` . As stated in the function header comments of


19/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


`Committee::verifyAvailabilityProof()`, there should be <u>at</u> <u>least</u> `numSignaturesRequired` of valid signa
tures signed by `committeeMembers` to verify a specific `claimHash` . However, the `verifyAvailabilityProof`

`()` is not implemented as how it is designed/documented.


27 <mark>`///`</mark> <mark>`@dev`</mark> <mark>`Verifies`</mark> <mark>`the`</mark> <mark>`availability`</mark> <mark>`proof.`</mark> <mark>`Reverts`</mark> <mark>`if`</mark> <mark>`invalid.`</mark>
28 <mark>`///`</mark> <mark>`An`</mark> <mark>`availability`</mark> <mark>`proof`</mark> <mark>`should`</mark> <mark>`have`</mark> <mark>`a`</mark> <mark>`form`</mark> <mark>`of`</mark> <mark>`a`</mark> <mark>`concatenation`</mark> <mark>`of`</mark> <mark>`ec -signatures`</mark> <mark>`by`</mark>
```
       signatories .
```

29 <mark>`///`</mark> <mark>`Signatures`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`sorted`</mark> <mark>`by`</mark> <mark>`signatory`</mark> <mark>`address`</mark> <mark>`ascendingly .`</mark>
30 <mark>`///`</mark> <mark>`Signatures`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`65`</mark> <mark>`bytes`</mark> <mark>`long.`</mark> <mark>`r(32)`</mark> <mark>`+`</mark> <mark>`s(32)`</mark> <mark>`+`</mark> <mark>`v(1).`</mark>
31 <mark>`///`</mark> <mark>`There`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`at`</mark> <mark>`least`</mark> <mark>`the`</mark> <mark>`number`</mark> <mark>`of`</mark> <mark>`required`</mark> <mark>`signatures`</mark> <mark>`as`</mark> <mark>`defined`</mark> <mark>`in`</mark> <mark>`this`</mark>
```
       contract.
```

32 <mark>`///`</mark>


Listing 3.12: Committee.sol


Specifically, the sanity check in line 45-47 makes a `availabilityProofs.length` greater than

`signaturesRequired` `*` `SIGNATURE_LENGTH` always fail. For example, if there are 10 committee mem
bers who construct a committee with `numSignaturesRequired=3`, the case of 5 committee members

verifying a `claimHash` would fail.


39 **<mark>function</mark>** <mark>v e r i f y A v a i l a b i l i t y P r o o f</mark> <mark>(</mark>
40 **<mark>bytes32</mark>** <mark>claimHash</mark> <mark>,</mark>
41 **<mark>bytes</mark>** <mark>c a l l d a t a</mark> <mark>a v a i l a b i l i t y P r o o f s</mark>
42 <mark>)</mark>
43 **<mark>external</mark>**
44 <mark>{</mark>
45 **<mark>r e q u i r e</mark>** <mark>(</mark>
46 <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>.</mark> **<mark>length</mark>** <mark>==</mark> <mark>s i g n a t u r e s R e q u i r e d</mark> <mark>∗SIGNATURE_LENGTH,</mark>
47 <mark>`" INVALID_AVAILABILITY_PROOF_LENGTH "`</mark> <mark>) ;</mark>


Listing 3.13: Committee.sol


In addition, the for-loop in line 51-66 requires all signatures are signed by one of the committee

members. This violates the <u>at</u> <u>least</u> <u>the</u> <u>number</u> <u>of</u> <u>required</u> <u>signatures</u> design. Specifically, the

`require()` call in line 63 rejects all non-committee signers.


49 **<mark>uint256</mark>** <mark>o f f s e t</mark> <mark>=</mark> <mark>0 ;</mark>
50 **<mark>address</mark>** <mark>prevRecoveredAddress</mark> <mark>=</mark> **<mark>address</mark>** <mark>(0)</mark> <mark>;</mark>
51 **<mark>f o r</mark>** <mark>(</mark> **<mark>uint256</mark>** <mark>p r o o f I d x</mark> <mark>=</mark> <mark>0;</mark> <mark>p r o o f I d x</mark> <mark><</mark> <mark>s i g n a t u r e s R e q u i r e d</mark> <mark>;</mark> <mark>p r o o f I d x++)</mark> <mark>{</mark>
52 **<mark>bytes32</mark>** <mark>r</mark> <mark>=</mark> <mark>bytesToBytes32 (</mark> <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>,</mark> <mark>o f f s e t</mark> <mark>) ;</mark>
53 **<mark>bytes32</mark>** <mark>s</mark> <mark>=</mark> <mark>bytesToBytes32 (</mark> <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>,</mark> <mark>o f f s e t</mark> <mark>+</mark> <mark>32) ;</mark>
54 **<mark>uint8</mark>** <mark>v</mark> <mark>=</mark> **<mark>uint8</mark>** <mark>(</mark> <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>[</mark> <mark>o f f s e t</mark> <mark>+</mark> <mark>6 4 ] )</mark> <mark>;</mark>
55 <mark>o f f s e t</mark> <mark>+=</mark> <mark>SIGNATURE_LENGTH;</mark>
56 **<mark>address</mark>** <mark>r e c o v e r e d</mark> <mark>=</mark> **<mark>ecrecover</mark>** <mark>(</mark>
57 <mark>claimHash</mark> <mark>,</mark>
58 <mark>v,</mark>
59 <mark>r</mark> <mark>,</mark>
60 <mark>s</mark>
61 <mark>) ;</mark>
62 <mark>`//`</mark> <mark>`Signatures`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`sorted`</mark> <mark>`off -chain`</mark> <mark>`before`</mark> <mark>`submitting`</mark> <mark>`to`</mark> <mark>`enable`</mark> <mark>`cheap`</mark>
```
             uniqueness check on -chain.

```

20/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


63 **<mark>r e q u i r e</mark>** <mark>( isMember [</mark> <mark>r e c o v e r e d</mark> <mark>]</mark> <mark>,</mark> <mark>`" AVAILABILITY_PROVER_NOT_IN_COMMITTEE "`</mark> <mark>) ;</mark>


Listing 3.14: Committee.sol


**Recommendation** Ensure how `verifyAvailabilityProof()` should be implemented. If it should

verify at least the number of required signatures, the check against `availabilityProofs.length` should

be modified. Also, the `require()` in line 63 should be removed. Instead, the number of valid signatures

should be counted and checked in the end of the function.


39 **<mark>function</mark>** <mark>v e r i f y A v a i l a b i l i t y P r o o f</mark> <mark>(</mark>
40 **<mark>bytes32</mark>** <mark>claimHash</mark> <mark>,</mark>
41 **<mark>bytes</mark>** <mark>c a l l d a t a</mark> <mark>a v a i l a b i l i t y P r o o f s</mark>
42 <mark>)</mark>
43 **<mark>external</mark>**
44 <mark>{</mark>
45 **<mark>r e q u i r e</mark>** <mark>(</mark>
46 <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>.</mark> **<mark>length</mark>** <mark>>=</mark> <mark>s i g n a t u r e s R e q u i r e d</mark> <mark>∗SIGNATURE_LENGTH,</mark>
47 <mark>`" INVALID_AVAILABILITY_PROOF_LENGTH "`</mark> <mark>) ;</mark>


49 **<mark>uint256</mark>** <mark>o f f s e t</mark> <mark>=</mark> <mark>0 ;</mark>
50 **<mark>uint256</mark>** <mark>v a l i d S i g n a t u r e s</mark> <mark>=</mark> <mark>0;</mark>
51 **<mark>address</mark>** <mark>prevRecoveredAddress</mark> <mark>=</mark> **<mark>address</mark>** <mark>(0)</mark> <mark>;</mark>
52 **<mark>f o r</mark>** <mark>(</mark> **<mark>uint256</mark>** <mark>p r o o f I d x</mark> <mark>=</mark> <mark>0;</mark> <mark>p r o o f I d x</mark> <mark><</mark> <mark>(</mark> <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>.</mark> **<mark>length</mark>** <mark>/</mark>
<mark>SIGNATURE_LENGTH) ;</mark> <mark>p r o o f I d x++)</mark> <mark>{</mark>
53 **<mark>bytes32</mark>** <mark>r</mark> <mark>=</mark> <mark>bytesToBytes32 (</mark> <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>,</mark> <mark>o f f s e t</mark> <mark>) ;</mark>
54 **<mark>bytes32</mark>** <mark>s</mark> <mark>=</mark> <mark>bytesToBytes32 (</mark> <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>,</mark> <mark>o f f s e t</mark> <mark>+</mark> <mark>32) ;</mark>
55 **<mark>uint8</mark>** <mark>v</mark> <mark>=</mark> **<mark>uint8</mark>** <mark>(</mark> <mark>a v a i l a b i l i t y P r o o f s</mark> <mark>[</mark> <mark>o f f s e t</mark> <mark>+</mark> <mark>6 4 ] )</mark> <mark>;</mark>
56 <mark>o f f s e t</mark> <mark>+=</mark> <mark>SIGNATURE_LENGTH;</mark>
57 **<mark>address</mark>** <mark>r e c o v e r e d</mark> <mark>=</mark> **<mark>ecrecover</mark>** <mark>(</mark>
58 <mark>claimHash</mark> <mark>,</mark>
59 <mark>v,</mark>
60 <mark>r</mark> <mark>,</mark>
61 <mark>s</mark>
62 <mark>) ;</mark>
63 **<mark>i f</mark>** <mark>( isMember [</mark> <mark>r e c o v e r e d</mark> <mark>] )</mark> <mark>{</mark>
64 <mark>v a l i d S i g n a t u r e s</mark> <mark>+=</mark> <mark>1 ;</mark>
65 <mark>}</mark>
66 <mark>`//`</mark> <mark>`Signatures`</mark> <mark>`should`</mark> <mark>`be`</mark> <mark>`sorted`</mark> <mark>`off -chain`</mark> <mark>`before`</mark> <mark>`submitting`</mark> <mark>`to`</mark> <mark>`enable`</mark> <mark>`cheap`</mark>
```
             uniqueness check on -chain.
```

67 **<mark>r e q u i r e</mark>** <mark>( r e c o v e r e d</mark> <mark>></mark> <mark>prevRecoveredAddress</mark> <mark>,</mark> <mark>`" NON_SORTED_SIGNATURES "`</mark> <mark>) ;</mark>
68 <mark>prevRecoveredAddress</mark> <mark>=</mark> <mark>r e c o v e r e d</mark> <mark>;</mark>
69 <mark>}</mark>
70 **<mark>i f</mark>** <mark>(</mark> <mark>v a l i d S i g n a t u r e s</mark> <mark>>=</mark> <mark>s i g n a t u r e s R e q u i r e d</mark> <mark>)</mark> <mark>{</mark>
71 <mark>v e r i f i e d F a c t s</mark> <mark>[ claimHash ]</mark> <mark>=</mark> **<mark>true</mark>** <mark>;</mark>
72 <mark>}</mark>
73 <mark>}</mark>


Listing 3.15: Committee.sol


If `verifyAvailabilityProof()` should verify <u>exactly</u> `signaturesRequired` signatures, the function

header comments need to be fixed. This had been addressed in the patched `Committee.sol` by validat

21/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


ing `availabilityProofs.length` `>=` `signaturesRequired` `*` `SIGNATURE_LENGTH` instead of `availabilityProofs`

`.length` `==` `signaturesRequired` `*` `SIGNATURE_LENGTH` .

#### **3.7 starkKey, vaultId, tokenId Ordering**




- ID: PVE-007

- Severity: Informational

- Likelihood: N/A

- Impact: N/A


**Description**




- Targets: `Escapes.sol`

- Category: Coding Practices [12]

- CWE subcategory: CWE-1099 [5]



Throughout the StarkEx codebase, there are lots of use cases of the combination of `(starkKey,`

`vaultId,` `tokenId)` or any two of them. In most of the cases, the 3-tuple is passed into a function as

the first three parameters where `starkKey` is the first parameter followed by `vaultId` and/or `tokenId` .

However, we identified one case that the ordering is not consistent to others.


43 **<mark>function</mark>** <mark>escape (</mark>
44 **<mark>uint256</mark>** <mark>v a u l t I d</mark> <mark>,</mark>
45 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>,</mark>
46 **<mark>uint256</mark>** <mark>tokenId</mark> <mark>,</mark>
47 **<mark>uint256</mark>** <mark>quantizedAmount</mark>
48 <mark>)</mark>


Listing 3.16: Escapes.sol


As shown in the above code snippets, the `escape()` function uses the ordering of `(vaultId,`

`starkKey,` `tokenId)` . Since all three parameters are `uint256`, it would be better to set one of the

ordering as a convention to avoid people from passing wrong ordering of parameters.


**Recommendation** Make the parameters ordering of `escape()` same as others. As an advanced

recommendation, since the 3-tuple, `(starkKey,` `vaultId,` `tokenId)`, is used in many places, it would

be good to pack them into a `struct` to simplify the code and avoid the wrong ordering in both

maintenance and operations. This had been addressed in the patched `Escapes.sol` by making the

parameters ordering same as others (i.e., `(starkKey,` `vaultId,` `tokenId)` ).


22/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


#### **3.8 Redundant Timestamp Checks**




- ID: PVE-008

- Severity: Informational

- Likelihood: N/A

- Impact: N/A


**Description**




- Target: `Deposits.sol`, `FullWithdrawals.`
```
 sol
```

- Category: Coding Practices [12]

- CWE subcategory: CWE-1041 [2]



In solidity, the keyword `now` is used as an alias of `block.timestamp` which returns the current block times
tamp as seconds since unix epoch. As an extreme case, the timestamp at `9999-12-31T23:59:59+00:00`

would be 253402300799 or 0 _x_ 3 _afff_ 4417 _f_ . It means that the day a block is packed with a times
tamp which is approaching to the maximum value of `uint` (i.e., 2 <sup>256</sup>   - 1) is not likely to happen.

Based on that, we believe the following assertion checks against timestamp overflows are redundant.

Specifically, in line 143 of `Deposits::depositReclaim()`, `requestTime` is retrieved from `cancellationRequests`

`[starkKey][tokenId][vaultId]` which was set as `now` in `Deposits::depositCancel()` . Then, in line 145,

`requestTime` is added by `DEPOSIT_CANCEL_DELAY` which is equivalent to 86400. After that, an assertion

check takes place in line 146 to ensure the arithmetic operation in line 145 does not have an integer

overflow. As we mentioned earlier, the `assert()` call in line 146 is a redundant assertion.

132 **<mark>function</mark>** <mark>d e p o s i t R e c l a i m (</mark> **<mark>uint256</mark>** <mark>tokenId</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>v a u l t I d )</mark>
133 **<mark>external</mark>**
134 <mark>`//`</mark> <mark>`No`</mark> <mark>`modifiers:`</mark> <mark>`This`</mark> <mark>`function`</mark> <mark>`can`</mark> <mark>`always`</mark> <mark>`be`</mark> <mark>`used,`</mark> <mark>`even`</mark> <mark>`when`</mark> <mark>`frozen.`</mark>
135 <mark>{</mark>
136 **<mark>r e q u i r e</mark>** <mark>( v a u l t I d</mark> <mark><=</mark> <mark>MAX_VAULT_ID,</mark> <mark>OUT_OF_RANGE_VAULT_ID) ;</mark>


138 <mark>`//`</mark> <mark>`Fetch`</mark> <mark>`user`</mark> <mark>`and`</mark> <mark>`key.`</mark>
139 **<mark>address</mark>** <mark>u s e r</mark> <mark>=</mark> **<mark>msg</mark>** <mark>.</mark> **<mark>sender</mark>** <mark>;</mark>
140 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>=</mark> <mark>getStarkKey ( u s e r ) ;</mark>


142 <mark>`//`</mark> <mark>`Make`</mark> <mark>`sure`</mark> <mark>`enough`</mark> <mark>`time`</mark> <mark>`has`</mark> <mark>`passed.`</mark>
143 **<mark>uint256</mark>** <mark>requestTime</mark> <mark>=</mark> <mark>c a n c e l l a t i o n R e q u e s t s</mark> <mark>[</mark> <mark>starkKey</mark> <mark>] [</mark> <mark>tokenId</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>] ;</mark>
144 **<mark>r e q u i r e</mark>** <mark>( requestTime</mark> <mark>!=</mark> <mark>0,</mark> <mark>DEPOSIT_NOT_CANCELED) ;</mark>
145 **<mark>uint256</mark>** <mark>freeTime</mark> <mark>=</mark> <mark>requestTime</mark> <mark>+</mark> <mark>DEPOSIT_CANCEL_DELAY;</mark>
146 **<mark>a s s e r t</mark>** <mark>( freeTime</mark> <mark>>=</mark> <mark>DEPOSIT_CANCEL_DELAY) ;</mark>


Listing 3.17: Deposits. sol


There is another case in line 94-100 of `FullWithdrawals.sol` . In particular, the `requestTime` added

by `FREEZE_GRACE_PERIOD` (21 days) would not cause an integer overflow such that the `assert()` call in

line 100 is redundant.

81 **<mark>function</mark>** <mark>f r e e z e R e q u e s t (</mark>
82 **<mark>uint256</mark>** <mark>v a u l t I d</mark>
83 <mark>)</mark>


23/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


84 **<mark>external</mark>**
85 <mark>notFrozen ()</mark>
86 <mark>{</mark>
87 <mark>`//`</mark> <mark>`Fetch`</mark> <mark>`user`</mark> <mark>`and`</mark> <mark>`key.`</mark>
88 **<mark>address</mark>** <mark>u s e r</mark> <mark>=</mark> **<mark>msg</mark>** <mark>.</mark> **<mark>sender</mark>** <mark>;</mark>
89 **<mark>uint256</mark>** <mark>starkKey</mark> <mark>=</mark> <mark>getStarkKey ( u s e r ) ;</mark>


91 <mark>`//`</mark> <mark>`Verify`</mark> <mark>`vaultId`</mark> <mark>`in`</mark> <mark>`range.`</mark>
92 **<mark>r e q u i r e</mark>** <mark>( v a u l t I d</mark> <mark><=</mark> <mark>MAX_VAULT_ID,</mark> <mark>OUT_OF_RANGE_VAULT_ID) ;</mark>


94 <mark>`//`</mark> <mark>`Load`</mark> <mark>`request`</mark> <mark>`time.`</mark>
95 **<mark>uint256</mark>** <mark>requestTime</mark> <mark>=</mark> <mark>f u l l W i t h d r a w a l R e q u e s t s</mark> <mark>[ starkKey</mark> <mark>] [</mark> <mark>v a u l t I d</mark> <mark>] ;</mark>
96 **<mark>r e q u i r e</mark>** <mark>( requestTime</mark> <mark>!=</mark> <mark>0,</mark> <mark>FULL_WITHDRAWAL_UNREQUESTED) ;</mark>


98 <mark>`//`</mark> <mark>`Verify`</mark> <mark>`timer`</mark> <mark>`on`</mark> <mark>`escape`</mark> <mark>`request.`</mark>
99 **<mark>uint256</mark>** <mark>freezeTime</mark> <mark>=</mark> <mark>requestTime</mark> <mark>+</mark> <mark>FREEZE_GRACE_PERIOD;</mark>
100 **<mark>a s s e r t</mark>** <mark>( freezeTime</mark> <mark>>=</mark> <mark>FREEZE_GRACE_PERIOD) ;</mark>


Listing 3.18: FullWithdrawals. sol


**Recommendation** Remove redundant assertions with additional benefits of saving gas usage.

#### **3.9 Upgrades Depend on States of Old Versions in Proxy**




- ID: PVE-009

- Severity: Low

- Likelihood: Low

- Impact: Low


**Description**




- Targets: `Proxy.sol`

- Category: Data Integrity Issues [15]

- CWE subcategory: CWE-494 [9]



The `Proxy` contract delegates calls to the `implementation()` contract. Moreover, it manages the

`implementation` with a two-step approach: `addImplementation()` and `upgradeTo()` . However, we identify

that the `upgradeTo()` function depends on the state of the old version of implementation, which could

be a deadlock if the old version has some problems which need to be fixed by a replacement.


248 **<mark>function</mark>** <mark>upgradeTo (</mark> **<mark>address</mark>** <mark>newImplementation</mark> <mark>,</mark> **<mark>bytes</mark>** <mark>c a l l d a t a</mark> **<mark>data</mark>** <mark>,</mark> **<mark>bool</mark>** <mark>f i n a l i z e</mark> <mark>)</mark>
249 **<mark>external</mark>** **<mark>payable</mark>** <mark>onlyGovernance</mark> <mark>n o t F i n a l i z e d</mark> <mark>notFrozen</mark> <mark>{</mark>
250 **<mark>uint256</mark>** <mark>a c t i v a t i o n _ t i m e</mark> <mark>=</mark> <mark>enabledTime [ newImplementation</mark> <mark>] ;</mark>


252 **<mark>r e q u i r e</mark>** <mark>( a c t i v a t i o n _ t i m e</mark> <mark>></mark> <mark>0,</mark> <mark>`" ADDRESS_NOT_UPGRADE_CANDIDATE "`</mark> <mark>) ;</mark>
253 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
254 **<mark>r e q u i r e</mark>** <mark>( a c t i v a t i o n _ t i m e</mark> <mark><=</mark> **<mark>now</mark>** <mark>,</mark> <mark>`" UPGRADE_NOT_ENABLED_YET "`</mark> <mark>) ;</mark>


256 **<mark>bytes32</mark>** <mark>init_vector_hash</mark> <mark>=</mark> <mark>i n i t i a l i z a t i o n H a s h</mark> <mark>[ newImplementation</mark> <mark>] ;</mark>


24/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


257 **<mark>r e q u i r e</mark>** <mark>( init_vector_hash</mark> <mark>==</mark> **<mark>keccak256</mark>** <mark>( a b i</mark> <mark>. encode (</mark> **<mark>data</mark>** <mark>,</mark> <mark>f i n a l i z e</mark> <mark>) )</mark> <mark>,</mark> <mark>`"`</mark>
<mark>`CHANGED_INITIALIZER "`</mark> <mark>) ;</mark>
258 <mark>_setImplementation ( newImplementation ) ;</mark>
259 **<mark>i f</mark>** <mark>(</mark> <mark>f i n a l i z e</mark> <mark>==</mark> **<mark>true</mark>** <mark>)</mark> <mark>{</mark>
260 <mark>s e t F i n a l i z e d F l a g</mark> <mark>( )</mark> <mark>;</mark>
261 **<mark>emit</mark>** <mark>F i n a l i z e d I m p l e m e n t a t i o n ( newImplementation ) ;</mark>
262 <mark>}</mark>


264 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -low -level -calls`</mark>
265 <mark>(</mark> **<mark>bool</mark>** <mark>success</mark> <mark>,</mark> **<mark>bytes</mark>** **<mark>memory</mark>** <mark>r e t u r n d a t a )</mark> <mark>=</mark> <mark>newImplementation .</mark> **<mark>d e l e g a t e c a l l</mark>** <mark>(</mark>
266 <mark>a b i</mark> <mark>.</mark> <mark>encodeWithSelector (</mark> **<mark>t h i s</mark>** <mark>.</mark> <mark>i n i t i a l i z e</mark> <mark>.</mark> <mark>s e l e c t o r</mark> <mark>,</mark> **<mark>data</mark>** <mark>) ) ;</mark>
267 **<mark>r e q u i r e</mark>** <mark>( success</mark> <mark>,</mark> **<mark>s t r i n g</mark>** <mark>( r e t u r n d a t a ) ) ;</mark>


269 **<mark>emit</mark>** <mark>Upgraded ( newImplementation ) ;</mark>
270 <mark>}</mark>


Listing 3.19: Proxy.sol


Specifically, in line 249, the `upgradeTo()` can only be triggered by an effective governor ( `onlyGovernance`

) when the implementation is not finalized ( `notFinalized` and the old implementation is not frozen

`notFrozen` . Note that `notFinalized` checks a flag which is set in line 260. It means only a governor

can make the call of finalizing an implementation. But, the `notFrozen` modifier is not the case.


113 **<mark>modifier</mark>** <mark>notFrozen ()</mark>
114 <mark>{</mark>
115 **<mark>r e q u i r e</mark>** <mark>( i m p l e m e n t a t i o n I s F r o z e n</mark> <mark>()</mark> <mark>==</mark> **<mark>f a l s e</mark>** <mark>,</mark> <mark>`" STATE_IS_FROZEN "`</mark> <mark>) ;</mark>
116 <mark>_;</mark>
117 <mark>}</mark>


Listing 3.20: Proxy.sol


79 **<mark>function</mark>** <mark>i m p l e m e n t a t i o n I s F r o z e n</mark> <mark>()</mark> **<mark>p r i v a t e</mark>** **<mark>returns</mark>** <mark>(</mark> **<mark>bool</mark>** <mark>)</mark> <mark>{</mark>
80 **<mark>address</mark>** <mark>_implementation</mark> <mark>=</mark> <mark>implementation ( )</mark> <mark>;</mark>


82 <mark>`//`</mark> <mark>`We`</mark> <mark>`can ’t`</mark> <mark>`call`</mark> <mark>`low`</mark> <mark>`level`</mark> <mark>`implementation`</mark> <mark>`before`</mark> <mark>`it’s`</mark> <mark>`assigned.`</mark> <mark>`(i.e.`</mark> <mark>`ZERO).`</mark>
83 **<mark>i f</mark>** <mark>( implementation ( )</mark> <mark>==</mark> <mark>ZERO_ADDRESS)</mark> <mark>{</mark>
84 **<mark>return</mark>** **<mark>f a l s e</mark>** <mark>;</mark>
85 <mark>}</mark>
86 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -low -level -calls`</mark>
87 <mark>(</mark> **<mark>bool</mark>** <mark>success</mark> <mark>,</mark> **<mark>bytes</mark>** **<mark>memory</mark>** <mark>r e t u r n d a t a )</mark> <mark>=</mark> <mark>_implementation .</mark> **<mark>d e l e g a t e c a l l</mark>** <mark>(</mark>
88 <mark>a b i</mark> <mark>.</mark> <mark>encodeWithSignature (</mark> <mark>`"isFrozen ()"`</mark> <mark>) ) ;</mark>
89 **<mark>r e q u i r e</mark>** <mark>( success</mark> <mark>,</mark> **<mark>s t r i n g</mark>** <mark>( r e t u r n d a t a ) ) ;</mark>
90 **<mark>return</mark>** <mark>a b i</mark> <mark>. decode ( returndata</mark> <mark>,</mark> <mark>(</mark> **<mark>bool</mark>** <mark>) ) ;</mark>
91 <mark>}</mark>


Listing 3.21: Proxy.sol


As shown in the above code snippets, the `notFrozen` is decided by the results of `isFrozen()` of the

current implementation. When `isFrozen()` is not implemented correctly, the Proxy contract cannot

fix the problem by a upgrade.


25/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


**Recommendation** Remove the `notFrozen()` modifier on `upgradeTo()` . If we want to pre
vent a frozen implementation from being upgraded, a governor can update the `activation_time` by

`addImplementation()` . In the patches, a `delegatecall` to the `isFrozen()` of the new implementation is

invoked after the initialization call to it. This ensures the `isFrozen()` function is correctly implemented

and the state is `notFrozen`, which resolves this issue.

#### **3.10 Optimization Suggestions to Proxy**




- ID: PVE-010

- Severity: Informational

- Likelihood: N/A

- Impact: N/A


**Description**




- Targets: `Proxy.sol`

- Category: Coding Practices [12]

- CWE subcategory: CWE-1099 [5]



In Proxy contract, the `_setImplementation()` is used to finalize the implementation by storing the

`newImplementation` into the storage. Since a typical convention of using `_xyz()` is calling it in function

`xyz()`, the existence of `_setImplementation()` looks a little bit weird here. As an example, in `ERC20.sol`,

both `transfer()` and `transferFrom()` call `_transfer()` to do the real transferring tokens thing. We

believe the naming of `_setImplementation()` is not compatible to others.


162 **<mark>function</mark>** <mark>_setImplementation (</mark> **<mark>address</mark>** <mark>newImplementation )</mark> **<mark>p r i v a t e</mark>** <mark>{</mark>
163 **<mark>bytes32</mark>** <mark>s l o t</mark> <mark>=</mark> <mark>IMPLEMENTATION_SLOT;</mark>
164 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -inline -assembly`</mark>
165 **<mark>assembly</mark>** <mark>{</mark>
166 <mark>s s t o r e ( s l o t</mark> <mark>,</mark> <mark>newImplementation )</mark>
167 <mark>}</mark>
168 <mark>}</mark>


Listing 3.22: Proxy.sol


**Recommendation** Modify `_setImplementation()` to `setImplementation()` . This had been ad
dressed in the patched `Proxy.sol` .

There’s another suggestion related to `addImplementation()` and `removeImplementation()` . Since the

`newImplementation` and related book-keeping data (i.e., `enabledTime` and `initializationHash` ) which

are set/clear by those two functions are only used inside `upgrade()`, those two functions are useless

when the implementation is finalized. Specifically, the `notFinalized` modifier could be added to

`addImplementation()` and `removeImplementation()` to reduce gas consumption.


200 **<mark>function</mark>** <mark>addImplementation (</mark> **<mark>address</mark>** <mark>newImplementation</mark> <mark>,</mark> **<mark>bytes</mark>** <mark>c a l l d a t a</mark> **<mark>data</mark>** <mark>,</mark> **<mark>bool</mark>**
<mark>f i n a l i z e</mark> <mark>)</mark>
201 **<mark>external</mark>** <mark>onlyGovernance</mark> <mark>{</mark>


26/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


202 **<mark>r e q u i r e</mark>** <mark>( i s C o n t r a c t ( newImplementation )</mark> <mark>,</mark> <mark>`" ADDRESS_NOT_CONTRACT "`</mark> <mark>) ;</mark>


204 **<mark>bytes32</mark>** <mark>init_hash</mark> <mark>=</mark> **<mark>keccak256</mark>** <mark>( a b i</mark> <mark>. encode (</mark> **<mark>data</mark>** <mark>,</mark> <mark>f i n a l i z e</mark> <mark>) ) ;</mark>
205 <mark>i n i t i a l i z a t i o n H a s h</mark> <mark>[ newImplementation ]</mark> <mark>=</mark> <mark>init_hash</mark> <mark>;</mark>


207 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
208 **<mark>uint256</mark>** <mark>a c t i v a t i o n _ t i m e</mark> <mark>=</mark> **<mark>now</mark>** <mark>+</mark> <mark>UPGRADE_ACTIVATION_DELAY;</mark>


210 <mark>`//`</mark> <mark>`First`</mark> <mark>`implementation`</mark> <mark>`should`</mark> <mark>`not`</mark> <mark>`have`</mark> <mark>`time -lock.`</mark>
211 **<mark>i f</mark>** <mark>( implementation ( )</mark> <mark>==</mark> <mark>ZERO_ADDRESS)</mark> <mark>{</mark>
212 <mark>`//`</mark> <mark>`solium -disable -next -line`</mark> <mark>`security/no -block -members`</mark>
213 <mark>a c t i v a t i o n _ t i m e</mark> <mark>=</mark> **<mark>now</mark>** <mark>;</mark>
214 <mark>}</mark>


216 <mark>enabledTime [ newImplementation ]</mark> <mark>=</mark> <mark>a c t i v a t i o n _ t i m e</mark> <mark>;</mark>
217 **<mark>emit</mark>** <mark>ImplementationAdded ( newImplementation</mark> <mark>,</mark> **<mark>data</mark>** <mark>,</mark> <mark>f i n a l i z e</mark> <mark>) ;</mark>
218 <mark>}</mark>


Listing 3.23: Proxy.sol


225 **<mark>function</mark>** <mark>removeImplementation (</mark> **<mark>address</mark>** <mark>newImplementation )</mark>
226 **<mark>external</mark>** <mark>onlyGovernance</mark> <mark>{</mark>


228 <mark>`//`</mark> <mark>`If`</mark> <mark>`we`</mark> <mark>`have`</mark> <mark>`initializer,`</mark> <mark>`we`</mark> <mark>`set`</mark> <mark>`the`</mark> <mark>`hash`</mark> <mark>`of`</mark> <mark>`it.`</mark>
229 **<mark>uint256</mark>** <mark>a c t i v a t i o n _ t i m e</mark> <mark>=</mark> <mark>enabledTime [ newImplementation</mark> <mark>] ;</mark>


231 **<mark>r e q u i r e</mark>** <mark>( a c t i v a t i o n _ t i m e</mark> <mark>></mark> <mark>0,</mark> <mark>`" ADDRESS_NOT_UPGRADE_CANDIDATE "`</mark> <mark>) ;</mark>


233 <mark>enabledTime [ newImplementation ]</mark> <mark>=</mark> <mark>0;</mark>


235 <mark>i n i t i a l i z a t i o n H a s h</mark> <mark>[ newImplementation ]</mark> <mark>=</mark> <mark>0 ;</mark>
236 **<mark>emit</mark>** <mark>ImplementationRemoved ( newImplementation ) ;</mark>
237 <mark>}</mark>


Listing 3.24: Proxy.sol


**Recommendation** Add `notFinalized` to `addImplementation()` and `removeImplementation()` .

#### **3.11 Optimization Suggestions to DexStatementVeriferi**




- ID: PVE-011

- Severity: Informational

- Likelihood: N/A

- Impact: N/A




- Target: `FriStatementContract.sol,`
```
 MerkleStatementContract.sol
```

- Category: Coding Practices [12]

- CWE subcategory: CWE-1068 [3]



27/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


**Description**


In `FriStatementContract::verifyFRI()`, the `friQueue` is used to store the input triplets of `(query_index`

`,` `FRI_value,` `FRI_inverse_point)` such that the length of `friQueue` is checked in line 35 to ensure that

it has `3*friQueries` `+` `1` elements. However, the case `friQueries` `==` `0` is meaningless in `verifyFRI()` .

We could simply optimize the function by requiring `friQueue.length` `>=` `4` and filter out the <u>no</u> <u>query</u>

<u>to</u> <u>process</u> case.


22 **<mark>function</mark>** <mark>v e r i f y F R I (</mark>
23 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>proof</mark> <mark>,</mark>
24 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>friQueue</mark> <mark>,</mark>
25 **<mark>uint256</mark>** <mark>e v a l u a t i o n P o i n t</mark> <mark>,</mark>
26 **<mark>uint256</mark>** <mark>f r i S t e p S i z e</mark> <mark>,</mark>
27 **<mark>uint256</mark>** <mark>expectedRoot )</mark> **<mark>p u b l i c</mark>** <mark>{</mark>
28
29 **<mark>r e q u i r e</mark>** <mark>(</mark> <mark>f r i S t e p S i z e</mark> <mark><=</mark> <mark>FRI_MAX_FRI_STEP,</mark> <mark>`"FRI`</mark> <mark>`step`</mark> <mark>`size`</mark> <mark>`too`</mark> <mark>`large"`</mark> <mark>) ;</mark>
30 <mark>`/*`</mark>
31 <mark>`The`</mark> <mark>`friQueue`</mark> <mark>`should`</mark> <mark>`have`</mark> <mark>`of`</mark> <mark>`3* nQueries`</mark> <mark>`+`</mark> <mark>`1`</mark> <mark>`elements,`</mark> <mark>`beginning`</mark> <mark>`with`</mark> <mark>`nQueries`</mark>
```
           triplets
```

32 <mark>`of`</mark> <mark>`the`</mark> <mark>`form`</mark> <mark>`(query_index,`</mark> <mark>`FRI_value,`</mark> <mark>`FRI_inverse_point ),`</mark> <mark>`and`</mark> <mark>`ending`</mark> <mark>`with`</mark> <mark>`a`</mark>
```
           single buffer
```

33 <mark>`cell`</mark> <mark>`set`</mark> <mark>`to`</mark> <mark>`0,`</mark> <mark>`which`</mark> <mark>`is`</mark> <mark>`accessed`</mark> <mark>`and`</mark> <mark>`read`</mark> <mark>`during`</mark> <mark>`the`</mark> <mark>`computation`</mark> <mark>`of`</mark> <mark>`the`</mark> <mark>`FRI`</mark>
```
           layer.
```

34 <mark>`*/`</mark>
35 **<mark>r e q u i r e</mark>** <mark>(</mark>
36 <mark>friQueue</mark> <mark>.</mark> **<mark>length</mark>** <mark>%</mark> <mark>3</mark> <mark>==</mark> <mark>1,</mark>
37 <mark>`"FRI`</mark> <mark>`Queue`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`composed`</mark> <mark>`of`</mark> <mark>`triplets`</mark> <mark>`plus`</mark> <mark>`one`</mark> <mark>`delimiter`</mark> <mark>`cell"`</mark> <mark>) ;</mark>

Listing 3.25: FriStatementContract. sol


**Recommendation** Check the length of `friQueue` and ensure that there’s at least one triplet to

process. This had been addressed in the patched `FriStatementContract.sol` .


22 **<mark>function</mark>** <mark>v e r i f y F R I (</mark>
23 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>proof</mark> <mark>,</mark>
24 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>friQueue</mark> <mark>,</mark>
25 **<mark>uint256</mark>** <mark>e v a l u a t i o n P o i n t</mark> <mark>,</mark>
26 **<mark>uint256</mark>** <mark>f r i S t e p S i z e</mark> <mark>,</mark>
27 **<mark>uint256</mark>** <mark>expectedRoot )</mark> **<mark>p u b l i c</mark>** <mark>{</mark>
28
29 **<mark>r e q u i r e</mark>** <mark>(</mark> <mark>f r i S t e p S i z e</mark> <mark><=</mark> <mark>FRI_MAX_FRI_STEP,</mark> <mark>`"FRI`</mark> <mark>`step`</mark> <mark>`size`</mark> <mark>`too`</mark> <mark>`large"`</mark> <mark>) ;</mark>
30 <mark>`/*`</mark>
31 <mark>`The`</mark> <mark>`friQueue`</mark> <mark>`should`</mark> <mark>`have`</mark> <mark>`of`</mark> <mark>`3* nQueries`</mark> <mark>`+`</mark> <mark>`1`</mark> <mark>`elements,`</mark> <mark>`beginning`</mark> <mark>`with`</mark> <mark>`nQueries`</mark>
```
           triplets
```

32 <mark>`of`</mark> <mark>`the`</mark> <mark>`form`</mark> <mark>`(query_index,`</mark> <mark>`FRI_value,`</mark> <mark>`FRI_inverse_point ),`</mark> <mark>`and`</mark> <mark>`ending`</mark> <mark>`with`</mark> <mark>`a`</mark>
```
           single buffer
```

33 <mark>`cell`</mark> <mark>`set`</mark> <mark>`to`</mark> <mark>`0,`</mark> <mark>`which`</mark> <mark>`is`</mark> <mark>`accessed`</mark> <mark>`and`</mark> <mark>`read`</mark> <mark>`during`</mark> <mark>`the`</mark> <mark>`computation`</mark> <mark>`of`</mark> <mark>`the`</mark> <mark>`FRI`</mark>
```
           layer.
```

34 <mark>`*/`</mark>
35 **<mark>r e q u i r e</mark>** <mark>( friQueue</mark> <mark>.</mark> **<mark>length</mark>** <mark>>=</mark> <mark>4,</mark> <mark>`"No`</mark> <mark>`query`</mark> <mark>`to`</mark> <mark>`process"`</mark> <mark>) ;</mark>
36 **<mark>r e q u i r e</mark>** <mark>(</mark>


28/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


37 <mark>friQueue</mark> <mark>.</mark> **<mark>length</mark>** <mark>%</mark> <mark>3</mark> <mark>==</mark> <mark>1,</mark>
38 <mark>`"FRI`</mark> <mark>`Queue`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`composed`</mark> <mark>`of`</mark> <mark>`triplets`</mark> <mark>`plus`</mark> <mark>`one`</mark> <mark>`delimiter`</mark> <mark>`cell"`</mark> <mark>) ;</mark>


Listing 3.26: FriStatementContract. sol


Besides, there’s a typo in line 34 of `verifyMerkle()` where the word `function` is misspelled as

`functin` .


13 **<mark>function</mark>** <mark>v e r i f y M e r k l e (</mark>
14 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>merkleView</mark> <mark>,</mark>
15 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>i n i t i a l M e r k l e Q u e u e</mark> <mark>,</mark>
16 **<mark>uint256</mark>** <mark>height</mark> <mark>,</mark>
17 **<mark>uint256</mark>** <mark>expectedRoot</mark>
18 <mark>)</mark>
19 **<mark>p u b l i c</mark>**
20 <mark>{</mark>
21 **<mark>r e q u i r e</mark>** <mark>( h e i g h t</mark> <mark><</mark> <mark>200,</mark> <mark>`"Height`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`<`</mark> <mark>`200."`</mark> <mark>) ;</mark>
22
23 **<mark>uint256</mark>** <mark>merkleQueuePtr ;</mark>
24 **<mark>uint256</mark>** <mark>channelPtr</mark> <mark>;</mark>
25 **<mark>uint256</mark>** <mark>nQueries</mark> <mark>;</mark>
26 **<mark>uint256</mark>** <mark>dataToHashPtr ;</mark>
27 **<mark>uint256</mark>** <mark>badInput</mark> <mark>=</mark> <mark>0;</mark>
28
29 **<mark>assembly</mark>** <mark>{</mark>
30 <mark>`//`</mark> <mark>`Skip`</mark> <mark>`0x20`</mark> <mark>`bytes`</mark> <mark>`length`</mark> <mark>`at`</mark> <mark>`the`</mark> <mark>`beginning`</mark> <mark>`of`</mark> <mark>`the`</mark> <mark>`merkleView.`</mark>
31 <mark>l e t</mark> <mark>merkleViewPtr</mark> <mark>:=</mark> <mark>add ( merkleView</mark> <mark>,</mark> <mark>0x20 )</mark>
32 <mark>`//`</mark> <mark>`Let`</mark> <mark>`channelPtr`</mark> <mark>`point`</mark> <mark>`to`</mark> <mark>`a`</mark> <mark>`free`</mark> <mark>`space.`</mark>
33 <mark>channelPtr</mark> <mark>:=</mark> <mark>mload (0 x40 )</mark> <mark>`//`</mark> <mark>`freePtr.`</mark>
34 <mark>`//`</mark> <mark>`channelPtr`</mark> <mark>`will`</mark> <mark>`point`</mark> <mark>`to`</mark> <mark>`the`</mark> <mark>`merkleViewPtr`</mark> <mark>`because`</mark> <mark>`the`</mark> <mark>`functin`</mark> <mark>`’verify ’`</mark>
```
             expects

```

Listing 3.27: MerkleStatementContract.sol


**Recommendation** Modify `functin` to `function` . This had been addressed in the patched

`MerkleStatementContract.sol` .

#### **3.12 Possible Integer Overfowl in MerkleVeriferi**




- ID: PVE-012

- Severity: Medium

- Likelihood: Low

- Impact: High




- Target: `MerkleVerifier.sol`

- Category: Numeric Errors [16]

- CWE subcategory: CWE-190 [7]



29/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


**Description**


In `MerkleVerifier::verify()`, `n` slots of leaf indices and leaf values are iterated through `queuePtr` for

hash calculation. However, there’s a possible integer overflow throughout this process such that a

malicious batch of queries could has the same verification result as a legit batch of queries.

22 **<mark>function</mark>** <mark>v e r i f y</mark> <mark>(</mark>
23 **<mark>uint256</mark>** <mark>channelPtr</mark> <mark>,</mark>
24 **<mark>uint256</mark>** <mark>queuePtr</mark> <mark>,</mark>
25 **<mark>bytes32</mark>** <mark>root</mark> <mark>,</mark>
26 **<mark>uint256</mark>** <mark>n )</mark>
27 **<mark>i n t e r n a l</mark>** **<mark>view</mark>**
28 **<mark>returns</mark>** <mark>(</mark> **<mark>bytes32</mark>** <mark>hash )</mark>
29 <mark>{</mark>
30 **<mark>uint256</mark>** <mark>lhashMask</mark> <mark>=</mark> <mark>getHashMask ()</mark> <mark>;</mark>
31
32 **<mark>assembly</mark>** <mark>{</mark>
33 <mark>`//`</mark> <mark>`queuePtr`</mark> <mark>`+`</mark> <mark>`i`</mark> <mark>`*`</mark> <mark>`0x40`</mark> <mark>`gives`</mark> <mark>`the`</mark> <mark>`i’th`</mark> <mark>`index`</mark> <mark>`in`</mark> <mark>`the`</mark> <mark>`queue.`</mark>
34 <mark>`//`</mark> <mark>`hashesPtr`</mark> <mark>`+`</mark> <mark>`i`</mark> <mark>`*`</mark> <mark>`0x40`</mark> <mark>`gives`</mark> <mark>`the`</mark> <mark>`i’th`</mark> <mark>`hash`</mark> <mark>`in`</mark> <mark>`the`</mark> <mark>`queue.`</mark>
35 <mark>l e t</mark> <mark>hashesPtr</mark> <mark>:=</mark> <mark>add ( queuePtr</mark> <mark>,</mark> <mark>0x20 )</mark>
36 <mark>l e t</mark> <mark>queueSize</mark> <mark>:=</mark> <mark>mul (n,</mark> <mark>0x40 )</mark>
37 <mark>l e t</mark> <mark>s l o t S i z e</mark> <mark>:=</mark> <mark>0x40</mark>

Listing 3.28: MerkleVerifier . sol


Specifically, in line 35, `queueSize` is set as `n*0x40` . When `n` is larger or equal to `0x0400...0000`,

`n*0x40` would overflow. Say if a triplet of `(queuePtr,` `root,` `1)` is verified. An attacker could use that

fact to verify `(queuePtr,` `root,` `0x0400...0001)` with bunch of malicious queries appended right after

the first legit query due to the fact that `0x0400...0001*0x40` `=` `0x40` . Only the first legit query would

be hashed. Fortunately, `verify()` is an internal function which is invoked by `verifyMerkle()` so that

the bad actors cannot exploit this vulnerability directly.

13 **<mark>function</mark>** <mark>v e r i f y M e r k l e (</mark>
14 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>merkleView</mark> <mark>,</mark>
15 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>i n i t i a l M e r k l e Q u e u e</mark> <mark>,</mark>
16 **<mark>uint256</mark>** <mark>height</mark> <mark>,</mark>
17 **<mark>uint256</mark>** <mark>expectedRoot</mark>
18 <mark>)</mark>
19 **<mark>p u b l i c</mark>**
20 <mark>{</mark>
21 **<mark>r e q u i r e</mark>** <mark>( h e i g h t</mark> <mark><</mark> <mark>200,</mark> <mark>`"Height`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`<`</mark> <mark>`200."`</mark> <mark>) ;</mark>
22
23 **<mark>uint256</mark>** <mark>merkleQueuePtr ;</mark>
24 **<mark>uint256</mark>** <mark>channelPtr</mark> <mark>;</mark>
25 **<mark>uint256</mark>** <mark>nQueries</mark> <mark>;</mark>
26 **<mark>uint256</mark>** <mark>dataToHashPtr ;</mark>
27 **<mark>uint256</mark>** <mark>badInput</mark> <mark>=</mark> <mark>0;</mark>
28
29 **<mark>assembly</mark>** <mark>{</mark>
30 <mark>`//`</mark> <mark>`Skip`</mark> <mark>`0x20`</mark> <mark>`bytes`</mark> <mark>`length`</mark> <mark>`at`</mark> <mark>`the`</mark> <mark>`beginning`</mark> <mark>`of`</mark> <mark>`the`</mark> <mark>`merkleView.`</mark>
31 <mark>l e t</mark> <mark>merkleViewPtr</mark> <mark>:=</mark> <mark>add ( merkleView</mark> <mark>,</mark> <mark>0x20 )</mark>


30/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


32 <mark>`//`</mark> <mark>`Let`</mark> <mark>`channelPtr`</mark> <mark>`point`</mark> <mark>`to`</mark> <mark>`a`</mark> <mark>`free`</mark> <mark>`space.`</mark>
33 <mark>channelPtr</mark> <mark>:=</mark> <mark>mload (0 x40 )</mark> <mark>`//`</mark> <mark>`freePtr.`</mark>
34 <mark>`//`</mark> <mark>`channelPtr`</mark> <mark>`will`</mark> <mark>`point`</mark> <mark>`to`</mark> <mark>`the`</mark> <mark>`merkleViewPtr`</mark> <mark>`because`</mark> <mark>`the`</mark> <mark>`function`</mark> <mark>`’verify ’`</mark>
```
             expects
```

35 <mark>`//`</mark> <mark>`a`</mark> <mark>`pointer`</mark> <mark>`to`</mark> <mark>`the`</mark> <mark>`proofPtr.`</mark>
36 <mark>mstore ( channelPtr</mark> <mark>,</mark> <mark>merkleViewPtr )</mark>
37 <mark>`//`</mark> <mark>`Skip`</mark> <mark>`0x20`</mark> <mark>`bytes`</mark> <mark>`length`</mark> <mark>`at`</mark> <mark>`the`</mark> <mark>`beginning`</mark> <mark>`of`</mark> <mark>`the`</mark> <mark>`initialMerkleQueue .`</mark>
38 <mark>merkleQueuePtr</mark> <mark>:=</mark> <mark>add ( i n i t i a l M e r k l e Q u e u e</mark> <mark>,</mark> <mark>0x20 )</mark>
39 <mark>`//`</mark> <mark>`Get`</mark> <mark>`number`</mark> <mark>`of`</mark> <mark>`queries.`</mark>
40 <mark>nQueries</mark> <mark>:=</mark> <mark>d i v ( mload ( i n i t i a l M e r k l e Q u e u e )</mark> <mark>,</mark> <mark>0x2 )</mark>


Listing 3.29: MerkleStatementContract.sol


However, as we look into the public function `verifyMerkle()`, the `nQueries` is derived from the

user controllable data `initialMerkleQueue` in line 40. The attacker could craft the `initialMerkleQueue`

to make `nQueries` `>=` `0x0400...0000`, which leads to the overflow mentioned above. To sum up,

an attacker can trick the verifier by appending arbitrary nodes into an already verified merkle tree

represented by `initialMerkleQueue` .


**Recommendation** Validate the number of queries. In the patches, this issue had be resolved

by validating the number of queries with `MAX_N_MERKLE_VERIFIER_QUERIES` as shown in the following

code snippets:


22 **<mark>function</mark>** <mark>v e r i f y</mark> <mark>(</mark>
23 **<mark>uint256</mark>** <mark>channelPtr</mark> <mark>,</mark>
24 **<mark>uint256</mark>** <mark>queuePtr</mark> <mark>,</mark>
25 **<mark>bytes32</mark>** <mark>root</mark> <mark>,</mark>
26 **<mark>uint256</mark>** <mark>n )</mark>
27 **<mark>i n t e r n a l</mark>** **<mark>view</mark>**
28 **<mark>returns</mark>** <mark>(</mark> **<mark>bytes32</mark>** <mark>hash )</mark>
29 <mark>{</mark>
30 **<mark>uint256</mark>** <mark>lhashMask</mark> <mark>=</mark> <mark>getHashMask ()</mark> <mark>;</mark>
31 **<mark>r e q u i r e</mark>** <mark>( n</mark> <mark><=</mark> <mark>MAX_N_MERKLE_VERIFIER_QUERIES,</mark> <mark>`" TOO_MANY_MERKLE_QUERIES "`</mark> <mark>) ;</mark>


Listing 3.30: MerkleVerifier . sol


13 **<mark>function</mark>** <mark>v e r i f y M e r k l e (</mark>
14 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>merkleView</mark> <mark>,</mark>
15 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>i n i t i a l M e r k l e Q u e u e</mark> <mark>,</mark>
16 **<mark>uint256</mark>** <mark>height</mark> <mark>,</mark>
17 **<mark>uint256</mark>** <mark>expectedRoot</mark>
18 <mark>)</mark>
19 **<mark>p u b l i c</mark>**
20 <mark>{</mark>
21 **<mark>r e q u i r e</mark>** <mark>( h e i g h t</mark> <mark><</mark> <mark>200,</mark> <mark>`"Height`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`<`</mark> <mark>`200."`</mark> <mark>) ;</mark>
22 **<mark>r e q u i r e</mark>** <mark>(</mark>
23 <mark>i n i t i a l M e r k l e Q u e u e</mark> <mark>.</mark> **<mark>length</mark>** <mark><=</mark> <mark>MAX_N_MERKLE_VERIFIER_QUERIES</mark> <mark>∗</mark> <mark>2,</mark>
24 <mark>`" TOO_MANY_MERKLE_QUERIES "`</mark> <mark>) ;</mark>


Listing 3.31: MerkleStatementContract.sol


31/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


Some other places throughout the `evm-verifier` codebase have the potential integer overflow

issues. All possible overflow cases had been guarded by sanity checks in the patches. We list them

in the following:

`n` in line 23.


15 **<mark>function</mark>** <mark>v e r i f y</mark> <mark>(</mark> **<mark>uint256</mark>** <mark>`/* channelPtr */`</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>queuePtr</mark> <mark>,</mark> **<mark>bytes32</mark>** <mark>root</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>n )</mark>
**<mark>i n t e r n a l</mark>** **<mark>view</mark>**
16 **<mark>returns</mark>** <mark>(</mark> **<mark>bytes32</mark>** <mark>)</mark> <mark>{</mark>
17 **<mark>bytes32</mark>** <mark>statement</mark> <mark>;</mark>
18
19 **<mark>assembly</mark>** <mark>{</mark>
20 <mark>l e t</mark> <mark>dataToHashPtrStart</mark> <mark>:=</mark> <mark>mload (0 x40 )</mark> <mark>`//`</mark> <mark>`freePtr.`</mark>
21 <mark>l e t</mark> <mark>dataToHashPtrCur</mark> <mark>:=</mark> <mark>dataToHashPtrStart</mark>
22
23 <mark>l e t</mark> <mark>queEndPtr</mark> <mark>:=</mark> <mark>add ( queuePtr</mark> <mark>,</mark> <mark>mul (n,</mark> <mark>0x40 ) )</mark>


Listing 3.32: MerkleStatementVerifier . sol


`nCoefs` in line 22.


14 **<mark>function</mark>** <mark>h o r n e r E v a l (</mark> **<mark>uint256</mark>** <mark>c o e f s S t a r t</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>point</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>nCoefs )</mark>
15 **<mark>i n t e r n a l</mark>** **<mark>pure</mark>**
16 **<mark>returns</mark>** <mark>(</mark> **<mark>uint256</mark>** <mark>)</mark> <mark>{</mark>
17 **<mark>uint256</mark>** <mark>r e s u l t</mark> <mark>=</mark> <mark>0 ;</mark>
18 **<mark>uint256</mark>** <mark>prime</mark> <mark>=</mark> <mark>PrimeFieldElement0</mark> <mark>.K_MODULUS;</mark>
19
20 **<mark>r e q u i r e</mark>** <mark>( nCoefs</mark> <mark>%</mark> <mark>8</mark> <mark>==</mark> <mark>0,</mark> <mark>`"Number`</mark> <mark>`of`</mark> <mark>`polynomial`</mark> <mark>`coefficients`</mark> <mark>`must`</mark> <mark>`be`</mark> <mark>`divisible`</mark> <mark>`by`</mark>
<mark>`8"`</mark> <mark>) ;</mark>
21 **<mark>assembly</mark>** <mark>{</mark>
22 <mark>l e t</mark> <mark>c o e f s P t r</mark> <mark>:=</mark> <mark>add ( c o e f s S t a r t</mark> <mark>,</mark> <mark>mul ( nCoefs</mark> <mark>,</mark> <mark>0x20 ) )</mark>


Listing 3.33: HornerEvaluator. sol


`nElements` in line 51.


41 **<mark>function</mark>** <mark>s e n d F i e l d E l e m e n t s (</mark> **<mark>uint256</mark>** <mark>channelPtr</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>nElements</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>t a r g e t P t r )</mark>
42 **<mark>i n t e r n a l</mark>** **<mark>pure</mark>**
43 <mark>{</mark>
44 **<mark>assembly</mark>** <mark>{</mark>
45 <mark>l e t</mark> <mark>PRIME</mark> <mark>:=</mark> <mark>0</mark>
<mark>x800000000000011000000000000000000000000000000000000000000000001</mark>
46 <mark>l e t</mark> <mark>PRIME_MON_R_INV</mark> <mark>:=</mark> <mark>0</mark>

<mark>x40000000000001100000000000012100000000000000000000000000000000</mark>
47 <mark>l e t</mark> <mark>PRIME_MASK</mark> <mark>:=</mark> <mark>0</mark>

<mark>x</mark> <mark>0</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark> <mark>f</mark>
48 <mark>l e t</mark> <mark>d i g e s t P t r</mark> <mark>:=</mark> <mark>add ( channelPtr</mark> <mark>,</mark> <mark>0x20 )</mark>
49 <mark>l e t</mark> <mark>counterPtr</mark> <mark>:=</mark> <mark>add ( channelPtr</mark> <mark>,</mark> <mark>0x40 )</mark>
50
51 <mark>l e t</mark> <mark>endPtr</mark> <mark>:=</mark> <mark>add ( t a r g e t P t r</mark> <mark>,</mark> <mark>mul ( nElements</mark> <mark>,</mark> <mark>0x20 ) )</mark>


Listing 3.34: VerifierChannel . sol


`nColumns` in line 268.


32/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


260 **<mark>function</mark>** <mark>readQuriesResponsesAndDecommit (</mark>
261 **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>ctx</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>nColumns</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>proofDataPtr</mark> <mark>,</mark> **<mark>bytes32</mark>** <mark>merkleRoot</mark>
<mark>)</mark>
262 **<mark>i n t e r n a l</mark>** **<mark>view</mark>** <mark>{</mark>
263 **<mark>uint256</mark>** <mark>nUniqueQueries</mark> <mark>=</mark> <mark>ctx</mark> <mark>[MM_N_UNIQUE_QUERIES ] ;</mark>
264 **<mark>uint256</mark>** <mark>channelPtr</mark> <mark>=</mark> <mark>getPtr ( ctx</mark> <mark>,</mark> <mark>MM_CHANNEL) ;</mark>
265 **<mark>uint256</mark>** <mark>friQueue</mark> <mark>=</mark> <mark>getPtr ( ctx</mark> <mark>,</mark> <mark>MM_FRI_QUEUE) ;</mark>
266 **<mark>uint256</mark>** <mark>friQueueEnd</mark> <mark>=</mark> <mark>friQueue</mark> <mark>+</mark> <mark>nUniqueQueries</mark> <mark>∗0x60 ;</mark>
267 **<mark>uint256</mark>** <mark>merkleQueuePtr</mark> <mark>=</mark> <mark>getPtr ( ctx</mark> <mark>,</mark> <mark>MM_MERKLE_QUEUE) ;</mark>
268 **<mark>uint256</mark>** <mark>rowSize</mark> <mark>=</mark> <mark>0x20</mark> <mark>∗nColumns ;</mark>
269 **<mark>uint256</mark>** <mark>lhashMask</mark> <mark>=</mark> <mark>getHashMask ()</mark> <mark>;</mark>

Listing 3.35: StarkVerifier . sol


`offset` in line 13.

6 **<mark>function</mark>** <mark>getPtr (</mark> **<mark>uint256</mark>** <mark>[ ]</mark> **<mark>memory</mark>** <mark>ctx</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>o f f s e t</mark> <mark>)</mark>
7 **<mark>i n t e r n a l</mark>** **<mark>pure</mark>**
8 **<mark>returns</mark>** <mark>(</mark> **<mark>uint256</mark>** <mark>)</mark> <mark>{</mark>
9 **<mark>uint256</mark>** <mark>c tx P t r</mark> <mark>;</mark>
10 **<mark>assembly</mark>** <mark>{</mark>
11 <mark>c tx P t r</mark> <mark>:=</mark> <mark>add ( ctx</mark> <mark>,</mark> <mark>0x20 )</mark>
12 <mark>}</mark>
13 **<mark>return</mark>** <mark>c tx P t r</mark> <mark>+</mark> <mark>o f f s e t</mark> <mark>∗0x20 ;</mark>
14 <mark>}</mark>

Listing 3.36: MemoryAccessUtils.sol


`nModifications` in line 214.

193 **<mark>function</mark>** <mark>computeBoundaryPeriodicColumn (</mark>
194 **<mark>uint256</mark>** <mark>m o d i f i c a t i o n s P t r</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>n M o d i f i c a t i o n s</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>nTransactions</mark> <mark>,</mark> **<mark>uint256</mark>**
<mark>point</mark> <mark>,</mark>
195 **<mark>uint256</mark>** <mark>prime</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>gen</mark> <mark>,</mark> **<mark>uint256</mark>** <mark>r e s u l t A r r a y P t r )</mark>
196 **<mark>i n t e r n a l</mark>** **<mark>view</mark>** <mark>{</mark>
197 **<mark>bool</mark>** <mark>s o r t e d</mark> <mark>=</mark> **<mark>true</mark>** <mark>;</mark>
198 **<mark>assembly</mark>** <mark>{</mark>
199 **<mark>function</mark>** <mark>expmod ( base</mark> <mark>,</mark> <mark>exponent</mark> <mark>,</mark> <mark>modulus )</mark> <mark>*></mark> <mark>r e s</mark> <mark>{</mark>
200 <mark>l e t</mark> <mark>p</mark> <mark>:=</mark> <mark>mload (0 x40 )</mark>
201 <mark>mstore (p,</mark> <mark>0x20 )</mark> <mark>`//`</mark> <mark>`Length`</mark> <mark>`of`</mark> <mark>`Base.`</mark>
202 <mark>mstore ( add (p,</mark> <mark>0x20 )</mark> <mark>,</mark> <mark>0x20 )</mark> <mark>`//`</mark> <mark>`Length`</mark> <mark>`of`</mark> <mark>`Exponent.`</mark>
203 <mark>mstore ( add (p,</mark> <mark>0x40 )</mark> <mark>,</mark> <mark>0x20 )</mark> <mark>`//`</mark> <mark>`Length`</mark> <mark>`of`</mark> <mark>`Modulus.`</mark>
204 <mark>mstore ( add (p,</mark> <mark>0x60 )</mark> <mark>,</mark> <mark>base )</mark> <mark>`//`</mark> <mark>`Base.`</mark>
205 <mark>mstore ( add (p,</mark> <mark>0x80 )</mark> <mark>,</mark> <mark>exponent )</mark> <mark>`//`</mark> <mark>`Exponent.`</mark>
206 <mark>mstore ( add (p,</mark> <mark>0xa0 )</mark> <mark>,</mark> <mark>modulus )</mark> <mark>`//`</mark> <mark>`Modulus.`</mark>
207 <mark>`//`</mark> <mark>`Call`</mark> <mark>`modexp`</mark> <mark>`precompile .`</mark>
208 **<mark>i f</mark>** <mark>i s z e r o</mark> <mark>(</mark> <mark>s t a t i c c a l l</mark> <mark>( not (0)</mark> <mark>,</mark> <mark>0x05</mark> <mark>,</mark> <mark>p,</mark> <mark>0xc0</mark> <mark>,</mark> <mark>p,</mark> <mark>0x20 ) )</mark> <mark>{</mark>
209 **<mark>r e v e r t</mark>** <mark>(0,</mark> <mark>0)</mark>
210 <mark>}</mark>
211 <mark>r e s</mark> <mark>:=</mark> <mark>mload ( p )</mark>
212 <mark>}</mark>
213
214 <mark>l e t</mark> <mark>l a s t O f f s e t</mark> <mark>:=</mark> <mark>mul ( n M o d i f i c a t i o n s</mark> <mark>,</mark> <mark>0x20 )</mark>

Listing 3.37: DexVerifier . sol


33/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

#### **3.13 Other Suggestions**


Due to the fact that compiler upgrades might bring unexpected compatibility or inter-version con
sistencies, it is always suggested to use fixed compiler versions whenever possible. As an example,

we highly encourage to explicitly indicate the Solidity compiler version, e.g., `pragma` `solidity` `0.5.2;`

instead of `pragma` `solidity` `^0.5.2;` .

Moreover, we strongly suggest not to use experimental Solidity features or third-party unaudited

libraries. If necessary, refactor current code base to only use stable features or trusted libraries. In

case there is an absolute need of leveraging experimental features or integrating external libraries,

make necessary contingency plans.


34/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

## **4 | Conclusion**


In this audit, we thoroughly analyzed the StarkEx documentation and implementation. The audited

system does involve various intricacies in both design and implementation. The current code base is

well organized and those identified issues are promptly confirmed and fixed.

Meanwhile, we need to emphasize that smart contracts as a whole are still in an early, but exciting

stage of development. To improve this report, we greatly appreciate any constructive feedbacks or

suggestions, on our methodology, audit findings, or potential gaps in scope/coverage.


35/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

## **5 | Appendix**

#### **5.1 Basic Coding Bugs**


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


  - <u>Description:</u> Whether the contract has general overflow or underflow vulnerabilities [20, 21,

22, 23, 25].


  - <u>Result:</u> Not found


  - <u>Severity:</u> Critical


36/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


**5.1.5** **Reentrancy**


  - <u>Description:</u> Reentrancy [26] is an issue when code can call back into your contract and change

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


37/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


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


38/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


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

#### **5.2 Semantic Consistency Checks**


  - <u>Description:</u> Whether the semantic of the white paper is different from the implementation of

the contract.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Critical

#### **5.3 Additional Recommendations**


**5.3.1** **Avoid** **Use** **of** **Variadic** **Byte** **Array**


  - <u>Description:</u> Use fixed-size byte array is better than that of `byte[]`, as the latter is a waste of

space.


  - <u>Result:</u> Not found


  - <u>Severity:</u> Low


39/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


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


40/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**

## **References**


[1] axic. Enforcing ABI length checks for return data from calls can be breaking. https://github.


com/ethereum/solidity/issues/4116.


[2] MITRE. CWE-1041: Use of Redundant Code. https://cwe.mitre.org/data/definitions/1041.


html.


[3] MITRE. CWE-1068: Inconsistency Between Implementation and Documented Design. https:


//cwe.mitre.org/data/definitions/1068.html.


[4] MITRE. CWE-1076: Insufficient Adherence to Expected Conventions. https://cwe.mitre.org/


data/definitions/1076.html.


[5] MITRE. CWE-1099: Inconsistent Naming Conventions for Identifiers. https://cwe.mitre.org/


data/definitions/1099.html.


[6] MITRE. CWE-1116: Inaccurate Comments. https://cwe.mitre.org/data/definitions/1116.html.


[7] MITRE. CWE-190: Integer Overflow or Wraparound. https://cwe.mitre.org/data/definitions/


190.html.


[8] MITRE. CWE-440: Expected Behavior Violation. https://cwe.mitre.org/data/definitions/440.


html.


[9] MITRE. CWE-494: Download of Code Without Integrity Check. https://cwe.mitre.org/data/


definitions/494.html.


41/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


[10] MITRE. CWE-628: Function Call with Incorrectly Specified Arguments. https://cwe.mitre.org/


data/definitions/628.html.


[11] MITRE. CWE-754: Improper Check for Unusual or Exceptional Conditions. https://cwe.mitre.


org/data/definitions/754.html.


[12] MITRE. CWE CATEGORY: Bad Coding Practices. https://cwe.mitre.org/data/definitions/


1006.html.


[13] MITRE. CWE CATEGORY: Behavioral Problems. https://cwe.mitre.org/data/definitions/438.


html.


[14] MITRE. CWE CATEGORY: Business Logic Errors. https://cwe.mitre.org/data/definitions/


840.html.


[15] MITRE. CWE CATEGORY: Data Integrity Issues. https://cwe.mitre.org/data/definitions/


1214.html.


[16] MITRE. CWE CATEGORY: Numeric Errors. https://cwe.mitre.org/data/definitions/189.html.


[17] MITRE. CWE CATEGORY: Often Misused: Arguments and Parameters. https://cwe.mitre.


org/data/definitions/559.html.


[18] MITRE. CWE VIEW: Development Concepts. https://cwe.mitre.org/data/definitions/699.


html.


[19] OWASP. Risk Rating Methodology. https://www.owasp.org/index.php/OWASP_Risk_


Rating_Methodology.


[20] PeckShield. ALERT: New batchOverflow Bug in Multiple ERC20 Smart Contracts (CVE-2018

10299). https://www.peckshield.com/2018/04/22/batchOverflow/.


[21] PeckShield. New burnOverflow Bug Identified in Multiple ERC20 Smart Contracts (CVE-2018

11239). https://www.peckshield.com/2018/05/18/burnOverflow/.


42/43 PeckShield Audit Report #: 2019-29


**<u>Confidential</u>**


[22] PeckShield. New multiOverflow Bug Identified in Multiple ERC20 Smart Contracts (CVE-2018

10706). https://www.peckshield.com/2018/05/10/multiOverflow/.


[23] PeckShield. New proxyOverflow Bug in Multiple ERC20 Smart Contracts (CVE-2018-10376).


https://www.peckshield.com/2018/04/25/proxyOverflow/.


[24] PeckShield. PeckShield Inc. https://www.peckshield.com.


[25] PeckShield. Your Tokens Are Mine: A Suspicious Scam Token in A Top Exchange. https:


//www.peckshield.com/2018/04/28/transferFlaw/.


[26] Solidity. Warnings of Expressions and Control Structures. http://solidity.readthedocs.io/en/


develop/control-structures.html.


43/43 PeckShield Audit Report #: 2019-29


