# **Security Review Report** **NM-0561 Celo Custom Gas Token**

(June 30, 2025)


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**

## **Contents**


**1** **Executive Summary** **2**


**2** **Audited Files** **3**
2.1 Celo 2.0 Modified Files . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
2.2 Celo 3.0 Modified Files . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3


**3** **Summary of Issues** **3**


**4** **Risk Rating Methodology** **4**


**5** **Documentation Evaluation** **5**


**6** **Test Suite Evaluation** **6**
6.1 Compilation Output . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
6.2 Tests Output . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
6.3 Automated Tools . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
6.3.1 AuditAgent . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10


**7** **About Nethermind** **11**


1


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**

## **1 Executive Summary**


This document presents the results of the security review conducted by [Nethermind](https://www.nethermind.io/smart-contract-audits) Security on the [CELO](https://github.com/celo-org/optimism/tree/celo-contracts/v3.0.0--1) fork of the Optimism V2 and
V3 contracts, which implements the Custom Gas Token (CGT) feature for the Celo L2 chain. The audit focused on the changes made to
add support for the Celo token as the native gas-paying token for Celo’s chain.


This review covers two branches: [Celo V2 and Celo V3.](https://github.com/celo-org/optimism/tree/celo-contracts/v2.0.0-1) The Celo network is currently running on V1.8, and both branches are required to
upgrade from V1.8 to V2, and then from V2 to V3, while still supporting the CGT feature. The changes in both branches are regressions
to already-audited Optimism code. The purpose of this review is to ensure that reintroducing the CGT feature does not conflict with any
other features introduced in later versions.


As part of this review, the changes in the Celo branches related to CGT were compared against the Optimism branches. An end-to-end
flow-based analysis of CGT deposits from L1 → OpNode → L2 was conducted, CGT deprecation risks were assessed, and the Optimism
CGT token specifications were checked to ensure they are upheld in the Celo CGT fork.


**The** **audit** **comprises** 35 files of solidity code, excluding interface files. **The** **audit** **was** **performed** **using** (a) manual analysis of the
codebase, (b) automated analysis tools, and (c) creation of test cases.


**Along this document, we report** no points of attention. The issues are summarized in Fig. 1.


**This document is organized as follows.** Section 2 presents the files in the scope. Section 3 summarizes the issues. Section 4 discusses
the risk rating methodology. Section 5 discusses the documentation provided by the client for this audit. Section 6 presents the compilation,
tests, and automated tests. Section 7 concludes the document.



Severity


(a)



None
100.0%



Status


(b)



None
100.0%



**Fig. 1:** **Distribution of issues:** **Critical** (0), **High** (0), **Medium** (0), **Low** (0), **Undetermined** (0), **Informational** (0), **Best Practices** (0).

**Distribution of status:** **Fixed** (0), **Acknowledged** (0), **Mitigated** (0), **Unresolved** (0)


**Summary of the Audit**


**Audit Type** Security Review
**Initial Report** June 30, 2025
**Final Report** July 1, 2025
**Repositories** [celo-org/optimism](https://github.com/celo-org/optimism)
**Initial Commit (V2)** [celo-contracts/v2.0.0-1](https://github.com/celo-org/optimism/tree/celo-contracts/v2.0.0-1)
[cdba802eb5e374fa3aa387deaa3243f219f821a1](https://github.com/celo-org/optimism/commit/cdba802eb5e374fa3aa387deaa3243f219f821a1)
**Initial Commit (V3)** [celo-contracts/v3.0.0–1](https://github.com/celo-org/optimism/tree/celo-contracts/v3.0.0--1)
[dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33](https://github.com/celo-org/optimism/commit/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33)
**Final Commit** N/A
**Documentation** [Custom Gas Token Depreciation](https://docs.optimism.io/notices/custom-gas-tokens-deprecation)
[Custom Gas Token Specification](https://specs.optimism.io/experimental/custom-gas-token.html)
[Deposit Flow](https://docs.optimism.io/stack/transactions/deposit-flow)
**Documentation Assessment** High
**<u>Test Suite Assessment</u>** <u>High</u>


2


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**

## **2 Audited Files**


The scope for this audit focuses on the diffs between Celo and Optimisms V2 and V3 releases, specifically the custom gas token feature.
The diff comparisons for V2 and V3 are listed below, this audit focuses on the re-integration of the custom gas token feature and the diffs
rather than an entire audit of each file.


Optimism V2 vs Celo V2:
https://github.com/ethereum-optimism/optimism/compare/op-contracts/v2.0.0...celo-org:optimism:celo-contracts/v2.0.0-1


Optimism V3 vs Celo V3:
[https://github.com/ethereum-optimism/optimism/compare/op-contracts/v3.0.0...celo-org:optimism:celo-contracts/v3.0.0–1](https://github.com/ethereum-optimism/optimism/compare/op-contracts/v3.0.0...celo-org:optimism:celo-contracts/v3.0.0--1)


**2.1** **Celo 2.0 Modified Files**


**<u>Contract</u>** **<u>LoC</u>** **<u>Comments</u>** **<u>Ratio</u>** **<u>Blank</u>** **<u>Total</u>**
<u>1</u> <u>[packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol)</u> <u>157</u> <u>203</u> <u>129.3%</u> <u>59</u> <u>419</u>
<u>2</u> <u>[packages/contracts-bedrock/src/universal/StandardBridge.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/universal/StandardBridge.sol)</u> <u>264</u> <u>189</u> <u>71.6%</u> <u>48</u> <u>501</u>
<u>3</u> <u>[packages/contracts-bedrock/src/L2/L1Block.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L2/L1Block.sol)</u> <u>83</u> <u>74</u> <u>89.2%</u> <u>27</u> <u>184</u>
<u>4</u> <u>[packages/contracts-bedrock/src/L2/SuperchainWETH.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L2/SuperchainWETH.sol)</u> <u>84</u> <u>55</u> <u>65.5%</u> <u>32</u> <u>171</u>
<u>5</u> <u>[packages/contracts-bedrock/src/L2/ETHLiquidity.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L2/ETHLiquidity.sol)</u> <u>22</u> <u>16</u> <u>72.7%</u> <u>8</u> <u>46</u>
<u>6</u> <u>[packages/contracts-bedrock/src/L2/L2CrossDomainMessenger.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L2/L2CrossDomainMessenger.sol)</u> <u>33</u> <u>22</u> <u>66.7%</u> <u>11</u> <u>66</u>
<u>7</u> <u>[packages/contracts-bedrock/src/L2/L1BlockInterop.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L2/L1BlockInterop.sol)</u> <u>80</u> <u>43</u> <u>53.8%</u> <u>29</u> <u>152</u>
<u>8</u> <u>[packages/contracts-bedrock/src/L2/WETH.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L2/WETH.sol)</u> <u>14</u> <u>11</u> <u>78.6%</u> <u>6</u> <u>31</u>
<u>9</u> <u>[packages/contracts-bedrock/src/L2/L2StandardBridge.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L2/L2StandardBridge.sol)</u> <u>145</u> <u>82</u> <u>56.6%</u> <u>18</u> <u>245</u>
<u>10</u> <u>[packages/contracts-bedrock/src/libraries/PortalErrors.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/libraries/PortalErrors.sol)</u> <u>20</u> <u>21</u> <u>105.0%</u> <u>1</u> <u>42</u>
<u>11</u> <u>[packages/contracts-bedrock/src/libraries/errors/CommonErrors.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/libraries/errors/CommonErrors.sol)</u> <u>6</u> <u>6</u> <u>100.0%</u> <u>5</u> <u>17</u>
<u>12</u> <u>[packages/contracts-bedrock/src/L1/SystemConfigInterop.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L1/SystemConfigInterop.sol)</u> <u>78</u> <u>38</u> <u>48.7%</u> <u>12</u> <u>128</u>
<u>13</u> <u>[packages/contracts-bedrock/src/L1/SystemConfig.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L1/SystemConfig.sol)</u> <u>243</u> <u>164</u> <u>67.5%</u> <u>77</u> <u>484</u>
<u>14</u> <u>[packages/contracts-bedrock/src/L1/OPContractsManager.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L1/OPContractsManager.sol)</u> <u>862</u> <u>201</u> <u>23.3%</u> <u>147</u> <u>1210</u>
<u>15</u> <u>[packages/contracts-bedrock/src/L1/L1StandardBridge.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L1/L1StandardBridge.sol)</u> <u>183</u> <u>131</u> <u>71.6%</u> <u>28</u> <u>342</u>
<u>16</u> <u>[packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol)</u> <u>53</u> <u>29</u> <u>54.7%</u> <u>15</u> <u>97</u>
<u>17</u> <u>[packages/contracts-bedrock/src/L1/OptimismPortal2.sol](https://github.com/celo-org/optimism//blob/cdba802eb5e374fa3aa387deaa3243f219f821a1/packages/contracts-bedrock/src/L1/OptimismPortal2.sol)</u> <u>361</u> <u>284</u> <u>78.7%</u> <u>113</u> <u>758</u>
**<u>Total</u>** **<u>2688</u>** **<u>1569</u>** **<u>58.4%</u>** **<u>636</u>** **<u>4893</u>**


**2.2** **Celo 3.0 Modified Files**


**<u>Contract</u>** **<u>LoC</u>** **<u>Comments</u>** **<u>Ratio</u>** **<u>Blank</u>** **<u>Total</u>**
<u>1</u> <u>[packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/universal/CrossDomainMessenger.sol)</u> <u>169</u> <u>221</u> <u>130.8%</u> <u>65</u> <u>455</u>
<u>2</u> <u>[packages/contracts-bedrock/src/universal/StandardBridge.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/universal/StandardBridge.sol)</u> <u>264</u> <u>189</u> <u>71.6%</u> <u>48</u> <u>501</u>
<u>3</u> <u>[packages/contracts-bedrock/src/universal/OptimismMintableERC20.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/universal/OptimismMintableERC20.sol)</u> <u>73</u> <u>60</u> <u>82.2%</u> <u>21</u> <u>154</u>
<u>4</u> <u>[packages/contracts-bedrock/src/L2/L1Block.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L2/L1Block.sol)</u> <u>94</u> <u>105</u> <u>111.7%</u> <u>31</u> <u>230</u>
<u>5</u> <u>[packages/contracts-bedrock/src/L2/SuperchainWETH.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L2/SuperchainWETH.sol)</u> <u>84</u> <u>55</u> <u>65.5%</u> <u>32</u> <u>171</u>
<u>6</u> <u>[packages/contracts-bedrock/src/L2/ETHLiquidity.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L2/ETHLiquidity.sol)</u> <u>22</u> <u>16</u> <u>72.7%</u> <u>8</u> <u>46</u>
<u>7</u> <u>[packages/contracts-bedrock/src/L2/L2CrossDomainMessenger.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L2/L2CrossDomainMessenger.sol)</u> <u>33</u> <u>22</u> <u>66.7%</u> <u>11</u> <u>66</u>
<u>8</u> <u>[packages/contracts-bedrock/src/L2/L1BlockInterop.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L2/L1BlockInterop.sol)</u> <u>80</u> <u>43</u> <u>53.8%</u> <u>29</u> <u>152</u>
<u>9</u> <u>[packages/contracts-bedrock/src/L2/WETH.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L2/WETH.sol)</u> <u>14</u> <u>11</u> <u>78.6%</u> <u>6</u> <u>31</u>
<u>10</u> <u>[packages/contracts-bedrock/src/L2/L2StandardBridge.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L2/L2StandardBridge.sol)</u> <u>145</u> <u>82</u> <u>56.6%</u> <u>18</u> <u>245</u>
<u>11</u> <u>[packages/contracts-bedrock/src/libraries/PortalErrors.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/libraries/PortalErrors.sol)</u> <u>20</u> <u>21</u> <u>105.0%</u> <u>1</u> <u>42</u>
<u>12</u> <u>[packages/contracts-bedrock/src/libraries/errors/CommonErrors.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/libraries/errors/CommonErrors.sol)</u> <u>6</u> <u>6</u> <u>100.0%</u> <u>5</u> <u>17</u>
<u>13</u> <u>[packages/contracts-bedrock/src/L1/SystemConfigInterop.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L1/SystemConfigInterop.sol)</u> <u>78</u> <u>38</u> <u>48.7%</u> <u>12</u> <u>128</u>
<u>14</u> <u>[packages/contracts-bedrock/src/L1/SystemConfig.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L1/SystemConfig.sol)</u> <u>255</u> <u>170</u> <u>66.7%</u> <u>81</u> <u>506</u>
<u>15</u> <u>[packages/contracts-bedrock/src/L1/OPContractsManager.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L1/OPContractsManager.sol)</u> <u>1026</u> <u>229</u> <u>22.3%</u> <u>180</u> <u>1435</u>
<u>16</u> <u>[packages/contracts-bedrock/src/L1/L1StandardBridge.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L1/L1StandardBridge.sol)</u> <u>183</u> <u>131</u> <u>71.6%</u> <u>28</u> <u>342</u>
<u>17</u> <u>[packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L1/L1CrossDomainMessenger.sol)</u> <u>53</u> <u>29</u> <u>54.7%</u> <u>15</u> <u>97</u>
<u>18</u> <u>[packages/contracts-bedrock/src/L1/OptimismPortal2.sol](https://github.com/celo-org/optimism//blob/dcfd0f3dc47669d16e97bbbd5ed6f5b57b8dba33/packages/contracts-bedrock/src/L1/OptimismPortal2.sol)</u> <u>361</u> <u>284</u> <u>78.7%</u> <u>109</u> <u>754</u>
**<u>Total</u>** **<u>2960</u>** **<u>1712</u>** **<u>57.8%</u>** **<u>700</u>** **<u>5372</u>**

## **3 Summary of Issues**


After careful review of the proposed branch diffs for both V2 and V3, no security risks have been identified


3


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**

## **4 Risk Rating Methodology**


The risk rating methodology used by [Nethermind](https://www.nethermind.io/smart-contract-audits) Security follows the principles established by the OWASP [Foundation.](https://owasp.org) The severity of
each finding is determined by two factors: **Likelihood** and **Impact** .


**Likelihood** measures how likely the finding is to be uncovered and exploited by an attacker. This factor will be one of the following values:


a) **High** : The issue is trivial to exploit and has no specific conditions that need to be met;


b) **Medium** : The issue is moderately complex and may have some conditions that need to be met;


c) **Low** : The issue is very complex and requires very specific conditions to be met.


When defining the likelihood of a finding, other factors are also considered. These can include but are not limited to motive, opportunity,
exploit accessibility, ease of discovery, and ease of exploit.


**Impact** is a measure of the damage that may be caused if an attacker exploits the finding. This factor will be one of the following values:


a) **High** : The issue can cause significant damage, such as loss of funds or the protocol entering an unrecoverable state;


b) **Medium** : The issue can cause moderate damage, such as impacts that only affect a small group of users or only a particular part

of the protocol;


c) **Low** : The issue can cause little to no damage, such as bugs that are easily recoverable or cause unexpected interactions that

cause minor inconveniences.


When defining the impact of a finding, other factors are also considered. These can include but are not limited to Data/state integrity, loss
of availability, financial loss, and reputation damage. After defining the likelihood and impact of an issue, the severity can be determined
according to the table below.


**<u>Severity Risk</u>**



**Impact**



**<u>High</u>** <u>Medium</u> <u>High</u> <u>Critical</u>
**<u>Medium</u>** <u>Low</u> <u>Medium</u> <u>High</u>
**<u>Low</u>** <u>Info/Best Practices</u> <u>Low</u> <u>Medium</u>
**<u>Undetermined</u>** <u>Undetermined</u> <u>Undetermined</u> <u>Undetermined</u>
**<u>Low</u>** **<u>Medium</u>** **<u>High</u>**
**<u>Likelihood</u>**



[To address issues that do not fit a High/Medium/Low severity, Nethermind Security also uses three more finding severities:](https://www.nethermind.io/smart-contract-audits) **Informational**,
**Best Practices**, and **Undetermined** .


a) **Informational** findings do not pose any risk to the application, but they carry some information that the audit team intends to pass

to the client formally;


b) **Best Practice** findings are used when some piece of code does not conform with smart contract development best practices;


c) **Undetermined** findings are used when we cannot predict the impact or likelihood of the issue.


4


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**

## **5 Documentation Evaluation**


Software documentation refers to the written or visual information that describes the functionality, architecture, design, and implementation
of software. It provides a comprehensive overview of the software system and helps users, developers, and stakeholders understand how
the software works, how to use it, and how to maintain it. Software documentation can take different forms, such as user manuals, system
manuals, technical specifications, requirements documents, design documents, and code comments. Software documentation is critical
in software development, enabling effective communication between developers, testers, users, and other stakeholders. It helps to ensure
that everyone involved in the development process has a shared understanding of the software system and its functionality. Moreover,
software documentation can improve software maintenance by providing a clear and complete understanding of the software system,
making it easier for developers to maintain, modify, and update the software over time. Smart contracts can use various types of software
documentation. Some of the most common types include:


  - Technical whitepaper: A technical whitepaper is a comprehensive document describing the smart contract’s design and technical

details. It includes information about the purpose of the contract, its architecture, its components, and how they interact with each
other;


  - User manual: A user manual is a document that provides information about how to use the smart contract. It includes step-by-step

instructions on how to perform various tasks and explains the different features and functionalities of the contract;


  - Code documentation: Code documentation is a document that provides details about the code of the smart contract. It includes

information about the functions, variables, and classes used in the code, as well as explanations of how they work;


  - API documentation: API documentation is a document that provides information about the API (Application Programming Interface)

of the smart contract. It includes details about the methods, parameters, and responses that can be used to interact with the
contract;


  - Testing documentation: Testing documentation is a document that provides information about how the smart contract was tested.

It includes details about the test cases that were used, the results of the tests, and any issues that were identified during testing;


  - Audit documentation: Audit documentation includes reports, notes, and other materials related to the security audit of the smart

contract. This type of documentation is critical in ensuring that the smart contract is secure and free from vulnerabilities.


These types of documentation are essential for smart contract development and maintenance. They help ensure that the contract is
properly designed, implemented, and tested, and they provide a reference for developers who need to modify or maintain the contract in
the future.


Remarks about Celo documentation


Given the nature of this audit where already-reviewed code from Optimism V1.8 is being re-integrated into Celo V3.0, the majority
of the documentation used during this engagement was sourced from Optimism documentation. This documentation includes:


[Custom Gas Token Deprecation Details:](https://docs.optimism.io/notices/custom-gas-tokens-deprecation)
Documentation detailing feature removal, and security concerns with chains that continue to support CGT.


[Custom Gas Token Specification:](https://specs.optimism.io/experimental/custom-gas-token.html)
The specification of the custom gas token feature, including smart contract and node expected behaviors.


[Deposit Flow Documentation:](https://docs.optimism.io/stack/transactions/deposit-flow)
Documentation describing the deposit flow from L1 -> OpNode -> L2 and how data and assets are transferred.


Throughout the audit engagement, there have been calls with the Celo team which have helped provide comprehensive insight
and clarify any questions to assist with the understanding of the presented changes.


5


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**

## **6 Test Suite Evaluation**


**6.1** **Compilation Output**


 - forge build


Compiling...
Compiling 15 files with Solc 0.8.15
Compiling 89 files with Solc 0.8.15
Compiling 2 files with Solc 0.8.28
Solc 0.8.28 finished **in** 534.01ms
Solc 0.8.15 finished **in** 15.33s
Solc 0.8.15 finished **in** 113.08s
Compiler run successful!


**6.2** **Tests Output**


 - forge test


2 pass; 0 fail; 0 skip; test/opcm/DeployPreimageOracle.t.sol:DeployPreimageOracle_Test
1 pass; 0 fail; 0 skip; test/opcm/DeploySuperchain.t.sol:DeploySuperchainInput_Test
3 pass; 0 fail; 0 skip; test/periphery/faucet/authmodules/AdminFaucetAuthModule.t.sol:AdminFaucetAuthModuleTest
3 pass; 0 fail; 0 skip; test/opcm/DeploySuperchain.t.sol:DeploySuperchainOutput_Test
3 pass; 0 fail; 0 skip; test/opcm/DeploySuperchain.t.sol:DeploySuperchain_Test
2 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_IsGameBlacklisted_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_BridgeETH_Test
3 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_GetAnchorRoot_Test
2 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_IsGameRespected_Test
2 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_IsGameRegistered_Test
11 pass; 0 fail; 0 skip; test/dispute/lib/LibPosition.t.sol:LibPosition_Test
1 pass; 0 fail; 0 skip; test/L2/BaseFeeVault.t.sol:FeeVault_Test
1 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_Anchors_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_CheckAfterExecution_TestFails
1 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_Initialize_TestFail
1 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_CheckTx_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_CheckTx_TestFails
5 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_IsGameProper_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_Constructor_Test
3 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_IsGameFinalized_Test
5 pass; 0 fail; 0 skip; test/opcm/DeployAltDA.t.sol:DeployAltDAOutput_Test
2 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_IsGameRetired_Test
1 pass; 0 fail; 0 skip; test/universal/CrossDomainMessenger.t.sol:CrossDomainMessenger_RelayMessage_Test
4 pass; 0 fail; 0 skip; test/opcm/DeployAltDA.t.sol:DeployAltDA_Test
2 pass; 0 fail; 0 skip; test/opcm/DeployAuthSystem.t.sol:DeployAuthSystemInput_Test
3 pass; 0 fail; 0 skip; test/opcm/DeployAuthSystem.t.sol:DeployAuthSystemOutput_Test
2 pass; 0 fail; 0 skip; test/opcm/DeployAuthSystem.t.sol:DeployAuthSystem_Test
1 pass; 0 fail; 0 skip; test/opcm/DeployImplementations.t.sol:DeployImplementationsInput_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_BridgeETH_TestFail
1 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_Initialize_Test
1 pass; 0 fail; 0 skip; test/universal/BenchmarkTest.t.sol:GasBenchMark_L1BlockInterop_DepositsComplete
1 pass; 0 fail; 0 skip; test/safe/SafeSigners.t.sol:SafeSigners_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_Receive_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_FinalizeBridgeETH_Test
1 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_SetAnchorState_Test
7 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_IsGameClaimValid_Test
3 pass; 0 fail; 0 skip; test/periphery/drippie/dripchecks/CheckBalanceLow.t.sol:CheckBalanceLowTest
10 pass; 0 fail; 0 skip; test/periphery/drippie/dripchecks/CheckSecrets.t.sol:CheckSecretsTest
2 pass; 0 fail; 0 skip; test/periphery/drippie/dripchecks/CheckTrue.t.sol:CheckTrueTest
1 pass; 0 fail; 0 skip; test/libraries/Constants.t.sol:Constants_Test
1 pass; 0 fail; 0 skip; test/invariants/AddressAliasHelper.t.sol:AddressAliasHelper_AddressAliasing_Invariant
1 pass; 0 fail; 0 skip; test/vendor/AddressAliasHelper.t.sol:AddressAliasHelper_applyAndUndo_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_DepositERC20To_Test
1 pass; 0 fail; 0 skip; test/universal/BenchmarkTest.t.sol:GasBenchMark_L1BlockInterop_DepositsComplete_Warm
2 pass; 0 fail; 0 skip; test/L2/SequencerFeeVault.t.sol:SequencerFeeVault_L2Withdrawal_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_DepositERC20_TestFail
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_Receive_TestFail
4 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_FinalizeBridgeETH_TestFail
6 pass; 0 fail; 0 skip; test/universal/CrossDomainMessenger.t.sol:CrossDomainMessenger_BaseGas_Test
1 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_Version_Test
12 pass; 0 fail; 0 skip; test/periphery/AssetReceiver.t.sol:AssetReceiverTest
4 pass; 0 fail; 0 skip; test/L2/SequencerFeeVault.t.sol:SequencerFeeVault_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_DepositERC20_Test
4 pass; 0 fail; 0 skip; test/opcm/SetDisputeGameImpl.t.sol:SetDisputeGameImplInput_Test
3 pass; 0 fail; 0 skip; test/opcm/SetDisputeGameImpl.t.sol:SetDisputeGameImpl_Test
1 pass; 0 fail; 0 skip; test/universal/BenchmarkTest.t.sol:GasBenchMark_L1BlockInterop_SetValuesInterop
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_DepositETHTo_Test
17 pass; 0 fail; 0 skip; test/cannon/PreimageOracle.t.sol:PreimageOracle_Test



6


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**


19 pass; 0 fail; 0 skip; test/L2/L2CrossDomainMessenger.t.sol:L2CrossDomainMessenger_Test
7 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_SetAnchorState_TestFail
2 pass; 0 fail; 0 skip; test/opcm/DeployOPChain.t.sol:DeployOPChainInput_Test
3 pass; 0 fail; 0 skip; test/opcm/DeployOPChain.t.sol:DeployOPChainOutput_Test.dispute
3 pass; 0 fail; 0 skip; test/opcm/DeployOPChain.t.sol:DeployOPChainOutput_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_FinalizeERC20Withdrawal_Test
18 pass; 0 fail; 0 skip; test/L2/L2StandardBridge.t.sol:L2StandardBridge_Test
0 pass; 0 fail; 1 skip; test/L2/L2StandardBridgeInterop.t.sol:L2StandardBridgeInterop_Getters_Test
0 pass; 0 fail; 1 skip; test/L2/L2StandardBridgeInterop.t.sol:L2StandardBridgeInterop_LegacyToSuper_Test
0 pass; 0 fail; 1 skip; test/L2/L2StandardBridgeInterop.t.sol:L2StandardBridgeInterop_SuperToLegacy_Test
2 pass; 0 fail; 0 skip; test/L2/L2StandardBridge.t.sol:L2StandardBridge_BridgeERC20To_Test
1 pass; 0 fail; 0 skip; test/universal/BenchmarkTest.t.sol:GasBenchMark_L1BlockInterop_SetValuesInterop_Warm
19 pass; 0 fail; 0 skip; test/L2/Preinstalls.t.sol:PreinstallsTest
18 pass; 0 fail; 0 skip; test/L2/L2ERC721Bridge.t.sol:L2ERC721Bridge_Test
2 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_FinalizeERC20Withdrawal_TestFail
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_DepositETHTo_TestFail
6 pass; 0 fail; 0 skip; test/L2/L2StandardBridge.t.sol:L2StandardBridge_BridgeERC20_Test
1 pass; 0 fail; 0 skip; test/universal/BenchmarkTest.t.sol:GasBenchMark_L1Block_SetValuesEcotone
2 pass; 0 fail; 0 skip; test/L1/ProtocolVersions.t.sol:ProtocolVersions_Initialize_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_FinalizeETHWithdrawal_Test
4 pass; 0 fail; 0 skip; test/L2/L2ToL1MessagePasser.t.sol:L2ToL1MessagePasserTest
3 pass; 0 fail; 0 skip; test/opcm/DeployOPChain.t.sol:DeployOPChain_Test.dispute
2 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_DepositETH_Test
23 pass; 0 fail; 0 skip; test/L2/L2ToL2CrossDomainMessenger.t.sol:L2ToL2CrossDomainMessengerTest
1 pass; 0 fail; 0 skip; test/universal/BenchmarkTest.t.sol:GasBenchMark_L1Block_SetValuesEcotone_Warm
6 pass; 0 fail; 0 skip; test/L2/L2StandardBridge.t.sol:L2StandardBridge_Bridge_Test
2 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_DepositETH_TestFail
2 pass; 0 fail; 0 skip; test/L1/ProtocolVersions.t.sol:ProtocolVersions_Setters_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_FinalizeETHWithdrawal_TestFail
13 pass; 0 fail; 0 skip; test/libraries/Blueprint.t.sol:Blueprint_Test
1 pass; 0 fail; 0 skip; test/legacy/LegacyMessagePasser.t.sol:LegacyMessagePasser_Test
1 pass; 0 fail; 0 skip; test/universal/BenchmarkTest.t.sol:SetPrevBaseFee_Test
3 pass; 0 fail; 0 skip; test/opcm/DeployOPChain.t.sol:DeployOPChain_Test
5 pass; 0 fail; 0 skip; test/opcm/DeployImplementations.t.sol:DeployImplementationsInterop_Test
3 pass; 0 fail; 0 skip; test/opcm/DeployImplementations.t.sol:DeployImplementationsOutput_Test
2 pass; 0 fail; 0 skip; test/L1/ProtocolVersions.t.sol:ProtocolVersions_Setters_TestFail
11 pass; 0 fail; 0 skip; test/universal/Proxy.t.sol:Proxy_Test
23 pass; 0 fail; 0 skip; test/universal/ProxyAdmin.t.sol:ProxyAdmin_Test
8 pass; 0 fail; 0 skip; test/libraries/rlp/RLPReader.t.sol:RLPReader_readBytes_Test
2 pass; 0 fail; 0 skip; test/L2/L2StandardBridge.t.sol:L2StandardBridge_FinalizeBridgeERC20_Test
28 pass; 0 fail; 0 skip; test/libraries/rlp/RLPReader.t.sol:RLPReader_readList_Test
9 pass; 0 fail; 0 skip; test/libraries/rlp/RLPWriter.t.sol:RLPWriter_writeList_Test
8 pass; 0 fail; 0 skip; test/libraries/rlp/RLPWriter.t.sol:RLPWriter_writeString_Test
8 pass; 0 fail; 0 skip; test/libraries/rlp/RLPWriter.t.sol:RLPWriter_writeUint_Test
3 pass; 0 fail; 0 skip; test/legacy/ResolvedDelegateProxy.t.sol:ResolvedDelegateProxy_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_Getter_Test
0 pass; 0 fail; 1 skip; test/L1/ResourceMetering.t.sol:ArtifactResourceMetering_Test
6 pass; 0 fail; 0 skip; test/legacy/LegacyMintableERC20.t.sol:LegacyMintableERC20_Test
2 pass; 0 fail; 0 skip; test/dispute/lib/LibClock.t.sol:LibClock_Test
1 pass; 0 fail; 0 skip; test/dispute/lib/LibGameId.t.sol:LibGameId_Test
2 pass; 0 fail; 0 skip; test/L2/L2StandardBridge.t.sol:L2StandardBridge_FinalizeBridgeETH_Test
5 pass; 0 fail; 0 skip; test/libraries/Bytes.t.sol:Bytes_slice_Test
3 pass; 0 fail; 0 skip; test/libraries/Bytes.t.sol:Bytes_slice_TestFail
4 pass; 0 fail; 0 skip; test/libraries/Bytes.t.sol:Bytes_toNibbles_Test
2 pass; 0 fail; 0 skip; test/opcm/DeployOPChain.t.sol:DeployOPChainInput_Test.dispute
3 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_Pause_Test
2 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_Initialize_Test
6 pass; 0 fail; 0 skip; test/L2/SuperchainERC20.t.sol:SuperchainERC20Test
6 pass; 0 fail; 0 skip; test/L2/SuperchainTokenBridge.t.sol:SuperchainTokenBridgeTest
1 pass; 0 fail; 0 skip; test/L1/OPContractsManager.t.sol:OPContractsManager_InternalMethods_Test
3 pass; 0 fail; 0 skip; test/opcm/DeployOPChain.t.sol:DeployOPChain_Test_Interop.dispute
4 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_Pause_TestFail
2 pass; 0 fail; 0 skip; test/universal/Specs.t.sol:Specification_Test
6 pass; 0 fail; 0 skip; test/L1/OptimismPortalInterop.t.sol:OptimismPortalInterop_Test
0 pass; 0 fail; 1 skip; test/L1/OPContractsManager.t.sol:OPContractsManager_SetRC_Test
4 pass; 0 fail; 0 skip; test/L1/OPContractsManager.t.sol:OPContractsManager_UpdatePrestate_Test
1 pass; 0 fail; 0 skip; test/L2/OperatorFeeVault.t.sol:FeeVault_Test
3 pass; 0 fail; 0 skip; test/universal/StandardBridge.t.sol:StandardBridge_Stateless_Test
11 pass; 0 fail; 0 skip; test/L1/SystemConfig.t.sol:SystemConfig_Setters_TestFail
14 pass; 0 fail; 0 skip; test/L1/StandardValidator.t.sol:StandardValidatorV180_Test
13 pass; 0 fail; 0 skip; test/L1/StandardValidator.t.sol:StandardValidatorV200_Test
0 pass; 0 fail; 1 skip; test/L1/OPContractsManager.t.sol:OPContractsManager_Upgrade_Test
3 pass; 0 fail; 0 skip; test/opcm/DeployOPChain.t.sol:DeployOPChain_Test_Interop
3 pass; 0 fail; 0 skip; test/safe/DeployOwnership.t.sol:DeployOwnershipTest
3 pass; 0 fail; 0 skip; test/opcm/DeployPreimageOracle.t.sol:DeployPreimageOracleInput_Test
4 pass; 0 fail; 0 skip; test/opcm/DeployPreimageOracle.t.sol:DeployPreimageOracleOutput_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_ShowLiveness_TestFail
1 pass; 0 fail; 0 skip; test/safe/LivenessModule.t.sol:LivenessModule_CanRemove_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessModule.t.sol:LivenessModule_CanRemove_TestFail
1 pass; 0 fail; 0 skip; test/safe/LivenessModule.t.sol:LivenessModule_Constructor_TestFail
12 pass; 0 fail; 0 skip; test/universal/OptimismMintableERC20.t.sol:OptimismMintableERC20_Test
3 pass; 0 fail; 0 skip; test/safe/LivenessModule.t.sol:LivenessModule_GetRequiredThreshold_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessModule.t.sol:LivenessModule_Getters_Test
0 pass; 0 fail; 1 skip; test/L1/OPContractsManager.t.sol:OPContractsManager_Upgrade_TestFails
6 pass; 0 fail; 0 skip; test/L1/SystemConfigInterop.t.sol:SystemConfigInterop_Test



7


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**


5 pass; 0 fail; 0 skip; test/periphery/Transactor.t.sol:TransactorTest
2 pass; 0 fail; 0 skip; test/periphery/TransferOnion.t.sol:TransferOnionTest
5 pass; 0 fail; 0 skip; test/libraries/Storage.t.sol:Storage_Roundtrip_Test
8 pass; 0 fail; 0 skip; test/libraries/TransientContext.t.sol:TransientContextTest
10 pass; 0 fail; 0 skip; test/libraries/TransientContext.t.sol:TransientReentrancyAwareTest
6 pass; 0 fail; 0 skip; test/opcm/UpgradeOPChain.t.sol:UpgradeOPChainInput_Test
1 pass; 0 fail; 0 skip; test/opcm/UpgradeOPChain.t.sol:UpgradeOPChain_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessModule.t.sol:LivenessModule_RemoveOwnersFuzz_Test
2 pass; 0 fail; 0 skip; test/safe/LivenessModule.t.sol:LivenessModule_RemoveOwners_Test
9 pass; 0 fail; 0 skip; test/universal/OptimismMintableERC20Factory.t.sol:OptimismMintableTokenFactory_Test
9 pass; 0 fail; 0 skip; test/safe/LivenessModule.t.sol:LivenessModule_RemoveOwners_TestFail
4 pass; 0 fail; 0 skip; test/L2/WETH.t.sol:WETH_Test
13 pass; 0 fail; 0 skip; test/dispute/WETH98.t.sol:WETH98_Test
10 pass; 0 fail; 0 skip; test/L2/OptimismMintableERC721.t.sol:OptimismMintableERC721_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_FuzzOwnerManagement_Test
5 pass; 0 fail; 0 skip; test/opcm/DeployImplementations.t.sol:DeployImplementations_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_Getters_Test
3 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_OwnerManagement_Test
1 pass; 0 fail; 0 skip; test/safe/LivenessGuard.t.sol:LivenessGuard_ShowLiveness_Test
8 pass; 0 fail; 0 skip; test/L1/SystemConfig.t.sol:SystemConfig_Init_CustomGasToken
4 pass; 0 fail; 0 skip; test/L2/OptimismMintableERC721Factory.t.sol:OptimismMintableERC721Factory_Test
4 pass; 0 fail; 0 skip; test/opcm/ManageDependencies.t.sol:ManageDependenciesInput_Test
2 pass; 0 fail; 0 skip; test/opcm/ManageDependencies.t.sol:ManageDependencies_Test
12 pass; 0 fail; 0 skip; test/L1/ResourceMetering.t.sol:ResourceMetering_Test
1 pass; 0 fail; 0 skip; test/governance/MintManager.t.sol:MintManager_constructor_Test
6 pass; 0 fail; 0 skip; test/libraries/StaticConfig.t.sol:StaticConfig_Test
101 pass; 0 fail; 0 skip; test/cannon/MIPS2.t.sol:MIPS2_Test
5 pass; 0 fail; 0 skip; test/L1/SystemConfig.t.sol:SystemConfig_Init_ResourceConfig
55 pass; 0 fail; 0 skip; test/L1/OptimismPortal2.t.sol:OptimismPortal2WithMockERC20_Test
5 pass; 0 fail; 0 skip; test/governance/MintManager.t.sol:MintManager_mint_Test
12 pass; 0 fail; 0 skip; test/cannon/MIPS64Memory.t.sol:MIPS64Memory_Test
2 pass; 0 fail; 0 skip; test/L1/SystemConfig.t.sol:SystemConfig_Initialize_Test
3 pass; 0 fail; 0 skip; test/governance/MintManager.t.sol:MintManager_upgrade_Test
84 pass; 0 fail; 0 skip; test/cannon/MIPS.t.sol:MIPS_Test
7 pass; 0 fail; 0 skip; test/L1/OPContractsManager.t.sol:OPContractsManager_AddGameType_Test
3 pass; 0 fail; 0 skip; test/L1/OPContractsManager.t.sol:OPContractsManager_Deploy_Test
5 pass; 0 fail; 0 skip; test/L1/SystemConfig.t.sol:SystemConfig_Initialize_TestFail
1 pass; 0 fail; 0 skip; test/invariants/Burn.Eth.t.sol:Burn_BurnEth_Invariant
2 pass; 0 fail; 0 skip; test/L1/SuperchainConfig.t.sol:SuperchainConfig_Init_Test
28 pass; 0 fail; 0 skip; test/L2/SuperchainWETH.t.sol:SuperchainWETH_Test
1 pass; 0 fail; 0 skip; test/L1/SuperchainConfig.t.sol:SuperchainConfig_Pause_Test
1 pass; 0 fail; 0 skip; test/invariants/SystemConfig.t.sol:SystemConfig_GasLimitBoundaries_Invariant
1 pass; 0 fail; 0 skip; test/L1/SuperchainConfig.t.sol:SuperchainConfig_Pause_TestFail
6 pass; 0 fail; 0 skip; test/L1/SystemConfig.t.sol:SystemConfig_Setters_Test
1 pass; 0 fail; 0 skip; test/L1/SuperchainConfig.t.sol:SuperchainConfig_Unpause_Test
8 pass; 0 fail; 0 skip; test/dispute/SuperFaultDisputeGame.t.sol:SuperFaultDispute_1v1_Actors_Test
1 pass; 0 fail; 0 skip; test/L1/SuperchainConfig.t.sol:SuperchainConfig_Unpause_TestFail
1 pass; 0 fail; 0 skip; test/invariants/OptimismPortal2.t.sol:OptimismPortal2_CannotFinalizeTwice
7 pass; 0 fail; 0 skip; test/dispute/PermissionedDisputeGame.t.sol:PermissionedDisputeGame_Test
7 pass; 0 fail; 0 skip; test/dispute/SuperPermissionedDisputeGame.t.sol:SuperPermissionedDisputeGame_Test
33 pass; 0 fail; 0 skip; test/libraries/trie/MerkleTrie.t.sol:MerkleTrie_get_Test
1 pass; 0 fail; 0 skip; test/L2/Predeploys.t.sol:PredeploysBaseTest
6 pass; 0 fail; 0 skip; test/libraries/Encoding.t.sol:Encoding_Test
3 pass; 0 fail; 0 skip; test/integration/EventLogger.t.sol:EventLoggerTest
1 pass; 0 fail; 0 skip; test/invariants/SuperFaultDisputeGame.t.sol:SuperFaultDisputeGame_Solvency_Invariant
5 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_Constructor_TestFail
2 pass; 0 fail; 0 skip; test/universal/ExtendedPause.t.sol:ExtendedPause_Test
15 pass; 0 fail; 0 skip; test/periphery/faucet/Faucet.t.sol:FaucetTest
1 pass; 0 fail; 0 skip; test/invariants/SafeCall.t.sol:SafeCall_Fails_Invariants
43 pass; 0 fail; 0 skip; test/L1/OptimismPortal2.t.sol:OptimismPortal2_FinalizeWithdrawal_Test
1 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_Getters_Test
1 pass; 0 fail; 0 skip; test/invariants/OptimismPortal2.t.sol:OptimismPortal2_CannotTimeTravel
2 pass; 0 fail; 0 skip; test/L2/Predeploys.t.sol:PredeploysInteropTest
3 pass; 0 fail; 0 skip; test/dispute/DelayedWETH.t.sol:DelayedWETH_Hold_Test
1 pass; 0 fail; 0 skip; test/invariants/SuperchainWETH.t.sol:SuperchainWETH_SendSucceeds_Invariant
1 pass; 0 fail; 0 skip; test/L1/OptimismPortal2.t.sol:OptimismPortal2_ResourceFuzz_Test
4 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_Pause_Test
1 pass; 0 fail; 0 skip; test/dispute/DelayedWETH.t.sol:DelayedWETH_Initialize_Test
2 pass; 0 fail; 0 skip; test/L1/OptimismPortal2.t.sol:OptimismPortal2_Upgradeable_Test
5 pass; 0 fail; 0 skip; test/dispute/DelayedWETH.t.sol:DelayedWETH_Withdraw_Test
4 pass; 0 fail; 0 skip; test/opcm/DeployAlphabetVM.t.sol:DeployAlphabetVMInput_Test
4 pass; 0 fail; 0 skip; test/opcm/DeployAlphabetVM.t.sol:DeployAlphabetVMOutput_Test
1 pass; 0 fail; 0 skip; test/opcm/DeployAlphabetVM.t.sol:DeployAlphabetVM_Test
4 pass; 0 fail; 0 skip; test/opcm/DeployAltDA.t.sol:DeployAltDAInput_Test
8 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_Pause_TestFail
2 pass; 0 fail; 0 skip; test/L2/Predeploys.t.sol:PredeploysTest
1 pass; 0 fail; 0 skip; test/invariants/SafeCall.t.sol:SafeCall_Succeeds_Invariants
1 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_SetDeputyGuardianModule_Test
1 pass; 0 fail; 0 skip; test/invariants/FaultDisputeGame.t.sol:FaultDisputeGame_Solvency_Invariant
1 pass; 0 fail; 0 skip; test/invariants/OptimismPortal2.t.sol:OptimismPortal_CanAlwaysFinalizeAfterWindow
17 pass; 0 fail; 0 skip; test/L2/OptimismSuperchainERC20.t.sol:OptimismSuperchainERC20Test



8


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**


0 pass; 0 fail; 1 skip; test/L2/OptimismSuperchainERC20Beacon.t.sol:OptimismSuperchainERC20BeaconTest
0 pass; 0 fail; 1 skip; test/L2/OptimismSuperchainERC20Factory.t.sol:OptimismSuperchainERC20FactoryTest
3 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_SetDeputyGuardianModule_TestFail
4 pass; 0 fail; 0 skip; test/dispute/DelayedWETH.t.sol:DelayedWETH_Recover_Test
2 pass; 0 fail; 0 skip; test/universal/SafeSend.t.sol:SafeSendTest
1 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_SetDeputy_Test
2 pass; 0 fail; 0 skip; test/dispute/DelayedWETH.t.sol:DelayedWETH_Unlock_Test
1 pass; 0 fail; 0 skip; test/dispute/DisputeGameFactory.t.sol:DisputeGameFactory_GetGameUUID_Test
1 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_SetDeputy_TestFail
1 pass; 0 fail; 0 skip; test/dispute/DisputeGameFactory.t.sol:DisputeGameFactory_Owner_Test
5 pass; 0 fail; 0 skip; test/dispute/DelayedWETH.t.sol:DelayedWETH_WithdrawFrom_Test
3 pass; 0 fail; 0 skip; test/invariants/OptimismSuperchainERC20/OptimismSuperchainERC20.t.sol:OpSprchnERC20Properties
21 pass; 0 fail; 0 skip; test/periphery/drippie/Drippie.t.sol:Drippie_Test
83 pass; 0 fail; 0 skip; test/dispute/FaultDisputeGame.t.sol:FaultDisputeGame_Test
4 pass; 0 fail; 0 skip; test/libraries/EOA.t.sol:EOA_isEOA_Test
4 pass; 0 fail; 0 skip; test/dispute/DisputeGameFactory.t.sol:DisputeGameFactory_Create_Test
2 pass; 0 fail; 0 skip; test/dispute/DisputeGameFactory.t.sol:DisputeGameFactory_SetImplementation_Test
2 pass; 0 fail; 0 skip; test/dispute/DisputeGameFactory.t.sol:DisputeGameFactory_SetInitBond_Test
11 pass; 0 fail; 0 skip; test/dispute/FaultDisputeGame.t.sol:FaultDispute_1v1_Actors_Test
7 pass; 0 fail; 0 skip; test/libraries/GasPayingToken.t.sol:GasPayingToken_Roundtrip_Test
4 pass; 0 fail; 0 skip; test/dispute/DisputeGameFactory.t.sol:DisputeGameFactory_FindLatestGames_Test
2 pass; 0 fail; 0 skip; test/dispute/DisputeGameFactory.t.sol:DisputeGameFactory_TransferOwnership_Test
11 pass; 0 fail; 0 skip; test/L2/GasPriceOracle.t.sol:GasPriceOracleBedrock_Test
12 pass; 0 fail; 0 skip; test/L2/GasPriceOracle.t.sol:GasPriceOracleEcotone_Test
8 pass; 0 fail; 0 skip; test/L2/ETHLiquidity.t.sol:ETHLiquidity_Test
13 pass; 0 fail; 0 skip; test/L2/GasPriceOracle.t.sol:GasPriceOracleFjordActive_Test
1 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_Unpause_Test
2 pass; 0 fail; 0 skip; test/L2/GasPriceOracle.t.sol:GasPriceOracleIsthmus_Test
2 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_Pause_TestFail
3 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_Unpause_TestFail
10 pass; 0 fail; 0 skip; test/governance/GovernanceToken.t.sol:GovernanceToken_Test
1 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_SetAnchorState_Test
2 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_SetAnchorState_TestFail
1 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_setRespectedGameType_Test
1 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_Pause_Test
2 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_setRespectedGameType_TestFail
1 pass; 0 fail; 0 skip; test/invariants/OptimismPortal2.t.sol:OptimismPortal2_Deposit_Invariant
1 pass; 0 fail; 0 skip; test/invariants/ETHLiquidity.t.sol:ETHLiquidity_MintBurn_Invariant
22 pass; 0 fail; 0 skip; test/L1/OptimismPortal2.t.sol:OptimismPortal2_Test
1 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_NoPortalCollisions_Test
3 pass; 0 fail; 0 skip; test/legacy/L1BlockNumber.t.sol:L1BlockNumberTest
14 pass; 0 fail; 0 skip; test/legacy/L1ChugSplashProxy.t.sol:L1ChugSplashProxy_Test
1 pass; 0 fail; 0 skip; test/safe/DeputyPauseModule.t.sol:DeputyPauseModule_Constructor_Test
6 pass; 0 fail; 0 skip; test/libraries/SafeCall.t.sol:SafeCall_Test
2 pass; 0 fail; 0 skip; test/libraries/Bytes.t.sol:Bytes_equal_Test
1 pass; 0 fail; 0 skip; test/libraries/Hashing.t.sol:Hashing_hashDepositSource_Test
2 pass; 0 fail; 0 skip; test/L2/CrossDomainOwnable.t.sol:CrossDomainOwnable_Test
2 pass; 0 fail; 0 skip; test/libraries/Hashing.t.sol:Hashing_hashCrossDomainMessage_Test
2 pass; 0 fail; 0 skip; test/invariants/Encoding.t.sol:Encoding_Invariant
1 pass; 0 fail; 0 skip; test/libraries/Hashing.t.sol:Hashing_hashOutputRootProof_Test
1 pass; 0 fail; 0 skip; test/L1/L1CrossDomainMessenger.t.sol:L1CrossDomainMessenger_ReinitReentryTest
1 pass; 0 fail; 0 skip; test/libraries/Hashing.t.sol:Hashing_hashDepositTransaction_Test
4 pass; 0 fail; 0 skip; test/L2/CrossDomainOwnable2.t.sol:CrossDomainOwnable2_Test
3 pass; 0 fail; 0 skip; test/L2/L1Block.t.sol:L1BlockIsthmus_Test
15 pass; 0 fail; 0 skip; test/L2/CrossL2Inbox.t.sol:CrossL2InboxTest
3 pass; 0 fail; 0 skip; test/L2/L1Block.t.sol:L1BlockBedrock_Test
12 pass; 0 fail; 0 skip; test/L2/CrossDomainOwnable3.t.sol:CrossDomainOwnable3_Test
1 pass; 0 fail; 0 skip; test/L1/L1ERC721Bridge.t.sol:L1ERC721Bridge_Pause_TestFail
3 pass; 0 fail; 0 skip; test/L1/L1ERC721Bridge.t.sol:L1ERC721Bridge_Pause_Test
2 pass; 0 fail; 0 skip; test/L2/L1Block.t.sol:L1BlockCustomGasToken_Test
19 pass; 0 fail; 0 skip; test/L2/L1BlockInterop.t.sol:L1BlockInteropIsDeposit_Test
30 pass; 0 fail; 0 skip; test/L1/L1CrossDomainMessenger.t.sol:L1CrossDomainMessenger_Test
26 pass; 0 fail; 0 skip; test/L1/DataAvailabilityChallenge.t.sol:DataAvailabilityChallengeTest
1 pass; 0 fail; 0 skip; test/vendor/InitializableOZv5.t.sol:InitializerOZv5_Test
18 pass; 0 fail; 0 skip; test/L1/L1ERC721Bridge.t.sol:L1ERC721Bridge_Test
3 pass; 0 fail; 0 skip; test/L2/L1Block.t.sol:L1BlockEcotone_Test
77 pass; 0 fail; 0 skip; test/dispute/SuperFaultDisputeGame.t.sol:SuperFaultDisputeGame_Test
1 pass; 0 fail; 0 skip; test/L2/CrossDomainOwnable.t.sol:CrossDomainOwnableThroughPortal_Test
1 pass; 0 fail; 0 skip; test/libraries/Hashing.t.sol:Hashing_hashWithdrawal_Test
1 pass; 0 fail; 0 skip; test/L2/L1FeeVault.t.sol:FeeVault_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_BridgeETHTo_Test
1 pass; 0 fail; 0 skip; test/L1/L1StandardBridge.t.sol:L1StandardBridge_BridgeETHTo_TestFail
1 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_BlacklistDisputeGame_Test
8 pass; 0 fail; 0 skip; test/legacy/DeployerWhitelist.t.sol:DeployerWhitelist_Test
1 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_Getters_Test



9


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**


7 pass; 0 fail; 0 skip; test/invariants/ResourceMetering.t.sol:ResourceMetering_Invariant
2 pass; 0 fail; 0 skip; test/safe/DeputyGuardianModule.t.sol:DeputyGuardianModule_BlacklistDisputeGame_TestFail
1 pass; 0 fail; 0 skip; test/vendor/Initializable.t.sol:Initializer_Test
3 pass; 0 fail; 0 skip; test/invariants/Hashing.t.sol:Hashing_Invariant
26 pass; 0 fail; 0 skip; test/cannon/PreimageOracle.t.sol:PreimageOracle_LargePreimageProposals_Test
2 pass; 0 fail; 0 skip; test/setup/DeployVariations.t.sol:DeployVariations_Test
19 pass; 0 fail; 0 skip; test/L2/L1BlockInterop.t.sol:L1BlockInteropSetL1BlockValuesInterop_Test
17 pass; 0 fail; 0 skip; test/L2/L1BlockInterop.t.sol:L1BlockInteropTest
19 pass; 0 fail; 0 skip; test/L2/L1BlockInterop.t.sol:L1BlockDepositsComplete_Test
1 pass; 0 fail; 0 skip; test/invariants/Burn.Gas.t.sol:Burn_BurnGas_Invariant
1 pass; 0 fail; 0 skip; test/invariants/CrossDomainMessenger.t.sol:XDM_MinGasLimits_Succeeds
3 pass; 0 fail; 0 skip; test/L2/L2Genesis.t.sol:L2GenesisTest
3 pass; 0 fail; 0 skip; test/dispute/AnchorStateRegistry.t.sol:AnchorStateRegistry_IsGameResolved_Test
1 pass; 0 fail; 0 skip; test/invariants/CrossDomainMessenger.t.sol:XDM_MinGasLimits_Reverts


**6.3** **Automated Tools**


**6.3.1** **AuditAgent**


All the relevant issues raised by the AuditAgent have been incorporated into this report. The AuditAgent is an AI-powered smart contract auditing tool that analyses code, detects vulnerabilities, and provides actionable fixes. It accelerates the security analysis process,
complementing human expertise with advanced AI models to deliver efficient and comprehensive smart contract audits. Available at
[https://app.auditagent.nethermind.io.](https://app.auditagent.nethermind.io)


10


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**

## **7 About Nethermind**


Nethermind is a Blockchain Research and Software Engineering company. Our work touches every part of the web3 ecosystem - from
layer 1 and layer 2 engineering, cryptography research, and security to application-layer protocol development. We offer strategic support
to our institutional and enterprise partners across the blockchain, digital assets, and DeFi sectors, guiding them through all stages of the
research and development process, from initial concepts to successful implementation.


We offer security audits of projects built on EVM-compatible chains and Starknet. We are active builders of the Starknet ecosystem,
delivering a node implementation, a block explorer, a Solidity-to-Cairo transpiler, and formal verification tooling. Nethermind also provides
strategic support to our institutional and enterprise partners in blockchain, digital assets, and decentralized finance (DeFi). In the next
paragraphs, we introduce the company in more detail.


**Blockchain** **Security:** At Nethermind, we believe security is vital to the health and longevity of the entire Web3 ecosystem. We provide security services related to Smart Contract Audits, Formal Verification, and Real-Time Monitoring. Our Security Team comprises
blockchain security experts in each field, often collaborating to produce comprehensive and robust security solutions. The team has a
strong academic background, can apply state-of-the-art techniques, and is experienced in analyzing cutting-edge Solidity and Cairo smart
contracts, such as ArgentX and StarkGate (the bridge connecting Ethereum and StarkNet). Most team members hold a Ph.D. degree and
actively participate in the research community, accounting for 240+ articles published and 1,450+ citations in Google Scholar. The security
team adopts customer-oriented and interactive processes where clients are involved in all stages of the work.


**Blockchain** **Core** **Development:** Our core engineering team, consisting of over 20 developers, maintains, improves, and upgrades our
flagship product - the Nethermind Ethereum Execution Client. The client has been successfully operating for several years, supporting both
the Ethereum Mainnet and its testnets, and now accounts for nearly a quarter of all synced Mainnet nodes. Our unwavering commitment
to Ethereum’s growth and stability extends to sidechains and layer 2 solutions. Notably, we were the sole execution layer client to facilitate
Gnosis Chain’s Merge, transitioning from Aura to Proof of Stake (PoS), and we are actively developing a full-node client to bolster Starknet’s
decentralization efforts. Our core team equips partners with tools for seamless node set-up, using generated docker-compose scripts
tailored to their chosen execution client and preferred configurations for various network types.


**DevOps** **and** **Infrastructure** **Management:** Our infrastructure team ensures our partners’ systems operate securely, reliably, and efficiently. We provide infrastructure design, deployment, monitoring, maintenance, and troubleshooting support, allowing you to focus on
your core business operations. Boasting extensive expertise in Blockchain as a Service, private blockchain implementations, and node
management, our infrastructure and DevOps engineers are proficient with major cloud solution providers and can host applications inhouse or on clients’ premises. Our global in-house SRE teams offer 24/7 monitoring and alerts for both infrastructure and application
levels. We manage over 5,000 public and private validators and maintain nodes on major public blockchains such as Polygon, Gnosis,
Solana, Cosmos, Near, Avalanche, Polkadot, Aptos, and StarkWare L2. Sedge is an open-source tool developed by our infrastructure
experts, designed to simplify the complex process of setting up a proof-of-stake (PoS) network or chain validator. Sedge generates dockercompose scripts for the entire validator set-up based on the chosen client, making the process easier and quicker while following best
practices to avoid downtime and being slashed.


**Cryptography** **Research:** At Nethermind, our Cryptography Research team is dedicated to continuous internal research while fostering
close collaboration with external partners. The team has expertise across a wide range of domains, including cryptography protocols,
consensus design, decentralized identity, verifiable credentials, Sybil resistance, oracles, and credentials, distributed validator technology
(DVT), and Zero-knowledge proofs. This diverse skill set, combined with strong collaboration between our engineering teams, enables us
to deliver cutting-edge solutions to our partners and clients.


**Smart** **Contract** **Development** **&** **DeFi** **Research:** Our smart contract development and DeFi research team comprises 40+ world-class
engineers who collaborate closely with partners to identify needs and work on value-adding projects. The team specializes in Solidity
and Cairo development, architecture design, and DeFi solutions, including DEXs, AMMs, structured products, derivatives, and money
market protocols, as well as ERC20, 721, and 1155 token design. Our research and data analytics focuses on three key areas: technical
due diligence, market research, and DeFi research. Utilizing a data-driven approach, we offer in-depth insights and outlooks on various
industry themes.


**Our** **suite** **of** **L2** **tooling:** Warp is Starknet’s approach to EVM compatibility. It allows developers to take their Solidity smart contracts
and transpile them to Cairo, Starknet’s smart contract language. In the short time since its inception, the project has accomplished many
achievements, including successfully transpiling Uniswap v3 onto Starknet using Warp.


  - **Voyager** is a user-friendly Starknet block explorer that offers comprehensive insights into the Starknet network. With its intuitive

interface and powerful features, Voyager allows users to easily search for and examine transactions, addresses, and contract
details. As an essential tool for navigating the Starknet ecosystem, Voyager is the go-to solution for users seeking in-depth
information and analysis;


  - **Horus** is an open-source formal verification tool for StarkNet smart contracts. It simplifies the process of formally verifying Starknet

smart contracts, allowing developers to express various assertions about the behavior of their code using a simple assertion
language;


  - **Juno** is a full-node client implementation for Starknet, drawing on the expertise gained from developing the Nethermind Client.

Written in Golang and open-sourced from the outset, Juno verifies the validity of the data received from Starknet by comparing it to
proofs retrieved from Ethereum, thus maintaining the integrity and security of the entire ecosystem.


**Learn more about us at nethermind.io** .


11


**<u>NM-0561 - CELO CUSTOM GAS TOKEN - SECURITY REVIEW</u>**


**General Advisory to Clients**


As auditors, we recommend that any changes or updates made to the audited codebase undergo a re-audit or security review to address
potential vulnerabilities or risks introduced by the modifications. By conducting a re-audit or security review of the modified codebase,
you can significantly enhance the overall security of your system and reduce the likelihood of exploitation. However, we do not possess
the authority or right to impose obligations or restrictions on our clients regarding codebase updates, modifications, or subsequent audits.
Accordingly, the decision to seek a re-audit or security review lies solely with you.


**Disclaimer**


[This report is based on the scope of materials and documentation provided by you to Nethermind in order that Nethermind could conduct](https://nethermind.io)
the security review outlined in **1.** **Executive** **Summary** and **2.** **Audited** **Files** . The results set out in this report may not be complete nor
inclusive of all vulnerabilities. [Nethermind has provided the review and this report on an as-is, where-is, and as-available basis.](https://nethermind.io) You agree
that your access and/or use, including but not limited to any associated services, products, protocols, platforms, content, and materials,
will be at your sole risk. Blockchain technology remains under development and is subject to unknown risks and flaws. The review does
not extend to the compiler layer, or any other areas beyond the programming language, or other programming aspects that could present
security risks. This report does not indicate the endorsement of any particular project or team, nor guarantee its security. No third party
should rely on this report in any way, including for the purpose of making any decisions to buy or sell a product, service or any other asset.
[To the fullest extent permitted by law, Nethermind disclaims any liability in connection with this report, its content, and any related services](https://nethermind.io)
and products and your use thereof, including, without limitation, the implied warranties of merchantability, fitness for a particular purpose,
and non-infringement. [Nethermind](https://nethermind.io) does not warrant, endorse, guarantee, or assume responsibility for any product or service advertised
or offered by a third party through the product, any open source or third-party software, code, libraries, materials, or information linked to,
called by, referenced by or accessible through the report, its content, and the related services and products, any hyperlinked websites,
any websites or mobile applications appearing on any advertising, [and Nethermind will not be a party to or in any way be responsible for](https://nethermind.io)
monitoring any transaction between you and any third-party providers of products or services. As with the purchase or use of a product
or service through any medium or in any environment, you should use your best judgment and exercise caution where appropriate.
FOR AVOIDANCE OF DOUBT, THE REPORT, ITS CONTENT, ACCESS, AND/OR USAGE THEREOF, INCLUDING ANY ASSOCIATED
SERVICES OR MATERIALS, SHALL NOT BE CONSIDERED OR RELIED UPON AS ANY FORM OF FINANCIAL, INVESTMENT, TAX,
LEGAL, REGULATORY, OR OTHER ADVICE.


12


