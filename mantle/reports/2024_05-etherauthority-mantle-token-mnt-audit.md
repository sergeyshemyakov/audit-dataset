## Project: Mantle Token Website: mantle.xyz Platform: Ethereum Language: Solidity Date: May 14th, 2024


# **Table of contents**

Introduction ……………………………………………………………………………………… 4


Project Background ………………………………………………………………………………4


Audit Scope ……………………………………………………………………………………… 5


Claimed Smart Contract Features …………………………………………………………….. 6


Audit Summary ……………....…………………………………………………………………..7


Technical Quick Stats …..……………………………………………………………………… 8


Business Risk Analysis …..…………………………………………………………………… 9


Code Quality ……………………………………………………………………………………. 10


Documentation ………………………………………………………………………………….. 10


Use of Dependencies …………………………………………………………………………… 10


AS-IS overview ………………………………………………………………………………….. 11


Severity Definitions ……………………………………………………………………………... 14


Audit Findings …………………………………………………………………………………… 15


[Conclusion ……………………………………………………………………………………….](https://docs.google.com/document/d/128B_RiGGKxW2uaBivZPtOOkjP4DW4W9TxDvdoGMFO_M/edit#bookmark=id.1t3h5sf) 17


Our Methodology ………………………………………………………………………………... 18


Disclaimers ………………………………………………………………………………………. 20


Appendix


 - Code Flow Diagram ……………………………………………………………………... 21


  - Slither Results Log ………………………………………………………………………. 22


  - Solidity static analysis ….……………………………………………………………….. 24


 - Solhint Linter …………………………………………………………………….……….. 26


#### `


#### THIS IS SECURITY AUDIT REPORT DOCUMENT AND WHICH MAY CONTAIN INFORMATION WHICH IS CONFIDENTIAL. WHICH INCLUDES ANY POTENTIAL VULNERABILITIES AND MALICIOUS CODES WHICH CAN BE USED TO EXPLOIT THE SOFTWARE. THIS MUST BE REFERRED INTERNALLY AND ONLY SHOULD BE MADE AVAILABLE TO THE PUBLIC AFTER ISSUES ARE RESOLVED.


## **Introduction**

As part of EtherAuthority’s community smart contract audit initiatives, the smart contract of

Mantle Token from mantle.xyz was audited. The audit has been performed using manual

analysis as well as using automated software tools. This report presents all the findings

regarding the audit performed on May 14th, 2024.


**The purpose of this audit was to address the following:**


- Ensure that all claimed functions exist and function correctly.


- Identify any security vulnerabilities that may be present in the smart contract.

## **Project Background**


 - This Solidity smart contract implements an ERC20 token with additional


functionalities like minting, burning, and governance using OpenZeppelin's


upgradeable contracts. The contract, `L1MantleToken`, is designed to allow minting


with specific constraints and includes governance features such as votes. Here is a


detailed breakdown of its structure and functionality:


 - The contract imports several modules from OpenZeppelin's library:


    - ERC20Upgradeable: The basic ERC20 token functionality.


    - ERC20BurnableUpgradeable: Adds burn functionality.


    - OwnableUpgradeable: Adds ownership and access control.


    - ERC20PermitUpgradeable: Adds EIP-2612 permits for gas-less approvals.


    - ERC20VotesUpgradeable: Adds voting functionality.


    - Initializable: Support for upgradeable contracts.


 - The `L1MantleToken` contract is a comprehensive implementation of an ERC20


token with additional features for minting, burning, and governance. It ensures strict


control over minting operations to prevent inflation and includes upgradeable


features to allow future modifications.


## **Audit scope**

**Name** **Code Review and Security Analysis Report for**
**Mantle (MNT) Token Smart Contract**


**Platform** **Ethereum**


**File** L1MantleToken.sol


**Smart Contract Code** <u>[0xcd368c1d80120b0dd92447c87eb570154f8e685c](https://etherscan.io/address/0xcd368c1d80120b0dd92447c87eb570154f8e685c#code)</u>


**Audit Date** May 14th, 2024


## **Claimed Smart Contract Features**

**Claimed Feature Detail** **Our Observation**



**Tokenomics:**


_●_ Name: Mantle


_●_ Symbol: MNT


_●_ Decimals: 18


 - Min Mint Interval: 365 Days


 - Mint Cap Denominator: 10,000


 - Mint Cap Max Numerator: 200


**Ownership control:**


 - Allows the owner to mint new tokens and increase


this token's total supply.


 - The `setMintCapNumerator` function allows the


owner to set the `mintCapNumerator`. It ensures the


new numerator does not exceed the maximum


allowed value and emits a


`MintCapNumeratorChanged` event.


 - The current owner can transfer the ownership.


 - The owner can renounce ownership.



**YES, This is valid.**


**YES, This is valid.**


**We suggest**


**renouncing ownership**


**once the ownership**


**functions are not**


**needed. This is to make**


**the smart contract**


**100% decentralized.**


## **Audit Summary**

According to the standard audit assessment, the Customer`s solidity-based smart contract
is **“Secured”** . Also, this contract contains owner control, which does not make it fully
decentralized.


You are here


We used various tools like Slither, Solhint, and Remix IDE. At the same time, this finding is

based on a critical analysis of the manual audit.

All issues found during automated analysis were manually reviewed and applicable

vulnerabilities are presented in the Audit Overview section. The general overview is

presented in the AS-IS section and all identified issues can be found in the Audit overview

section.


**We found 0 critical, 0 high, 0 medium, 0 low, and 1 very low level issues.**


**Investor** **Advice:** A technical audit of the smart contract does not guarantee the ethical


nature of the project. Any owner-controlled functions should be executed by the owner with


responsibility. All investors/users are advised to do their due diligence before investing in


the project.


## **Technical Quick Stats**



**<u><mark>Main Category</mark></u>** **<u><mark>Subcategory</mark></u>** **<u><mark>Result</mark></u>**
Contract <u>The solidity version is not specified</u> <u>Passed</u>
Programming

<u>The solidity version is too old</u> <u>Passed</u>



Contract <u>The solidity version is not specified</u> <u>Passed</u>
Programming

<u>The solidity version is too old</u> <u>Passed</u>
<u>Integer overflow/underflow</u> <u>Passed</u>
<u>Function input parameters lack check</u> <u>Passed</u>
<u>Function input parameters check bypass</u> <u>Passed</u>
<u>Function access control lacks management</u> <u>Passed</u>
<u>Critical operation lacks event log</u> <u>Passed</u>
<u>Human/contract checks bypass</u> <u>Passed</u>
<u>Random number generation/use vulnerability</u> <u>N/A</u>
<u>Fallback function misuse</u> <u>Passed</u>
<u>Race condition</u> <u>Passed</u>
<u>Logical vulnerability</u> <u>Passed</u>
<u>Features claimed</u> <u>Passed</u>
<u>Other programming issues</u> <u>Moderated</u>
Code <u>Function visibility not explicitly declared</u> <u>Passed</u>
Specification

<u>Var. storage location not explicitly declared</u> <u>Passed</u>



Code <u>Function visibility not explicitly declared</u> <u>Passed</u>
Specification

<u>Var. storage location not explicitly declared</u> <u>Passed</u>
<u>Use keywords/functions to be deprecated</u> <u>Passed</u>
<u>Unused code</u> <u>Passed</u>
Gas Optimization <u>“Out of Gas” Issue</u> <u>Passed</u>
<u>High consumption ‘for/while’ loop</u> <u>Passed</u>
<u>High consumption ‘storage’ storage</u> <u>Passed</u>
<u>Assert() misuse</u> <u>Passed</u>
Business Risk <u>The maximum limit for mintage is not set</u> <u>Passed</u>
<u>“Short Address” Attack</u> <u>Passed</u>
<u>“Double Spend” Attack</u> <u>Passed</u>



**Overall Audit Result:** **PASSED**


## **Business Risk Analysis**

**<u><mark>Category</mark></u>** **<u><mark>Result</mark></u>**

0%
<u>Buy Tax</u>

0%
<u>Sell Tax</u>

No
<u>Cannot Buy</u>

No
<u>Cannot Sell</u>

0%
<u>Max Tax</u>

Not Detected
<u>Modify Tax</u>

No
<u>Fee Check</u>

Not Detected
<u>Is Honeypot</u>

Not Detected
<u>Trading Cooldown</u>

No
<u>Can Pause Trade?</u>

Not Detected
<u>Pause Transfer?</u>

No
<u>Max Tax?</u>

Not Detected
<u>Is it Anti-whale?</u>

Not Detected
<u>Is Anti-bot?</u>

Not Detected
<u>Is it a Blacklist?</u>

No
<u>Blacklist Check</u>

Yes
<u>Can Mint?</u>

Yes
<u>Is it a Proxy?</u>

Yes
<u>Can Take Ownership?</u>

No
<u>Hidden Owner?</u>

Not Detected
<u>Self Destruction?</u>

High
<u>Auditor Confidence</u>


**Overall Audit Result:** **PASSED**


## **Code Quality**

This audit scope has 1 smart contract file. Smart contracts contain Libraries, Smart


contracts, inherits, and Interfaces. This is a compact and well-written smart contract.


The libraries in Mantle Token are part of its logical algorithm. A library is a different type of


smart contract that contains reusable code. Once deployed on the blockchain (only once),


it is assigned a specific address and its properties/methods can be reused many times by


other contract in the Mantle Token.


The EtherAuthority team has no scenario and unit test scripts, which would have helped to


determine the integrity of the code in an automated way.


Code parts are well commented on in the smart contracts. Ethereum’s NatSpec


commenting style is recommended.

## **Documentation**


We were given a Mantle Token smart contract code in the form of an <u>[Etherscan](https://etherscan.io/address/0xcd368c1d80120b0dd92447c87eb570154f8e685c#code)</u> web link.


As mentioned above, code parts are well commented on. and the logic is straightforward.


So it is easy to quickly understand the programming flow as well as complex code logic.


Comments are very helpful in understanding the overall architecture of the protocol.

## **Use of Dependencies**


As per our observation, the libraries used in this smart contract infrastructure are based on


well-known industry standard open-source projects.


Apart from libraries, its functions are not used in external smart contract calls.


## **AS-IS overview**

**L1MantleToken.sol**


**Functions**


**<u>Sl.</u>** **<u>Functions</u>** **<u>Type</u>** **<u>Observation</u>** **<u>Conclusion</u>**
**<u>1</u>** <u>constructor</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**2** __ERC20Votes_init internal access only No Issue

<u>Initializing</u>



**3** __ERC20Votes_init_unchained internal access only

<u>Initializing</u>



No Issue



**<u>4</u>** <u>checkpoints</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>5</u>** <u>numCheckpoints</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>6</u>** <u>delegates</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>7</u>** <u>getVotes</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>8</u>** <u>getPastVotes</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>9</u>** <u>getPastTotalSupply</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>10</u>** <u>_checkpointsLookup</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>11</u>** <u>delegate</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>12</u>** <u>delegateBySig</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>13</u>** <u>_maxSupply</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>14</u>** <u>_mint</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>15</u>** <u>_burn</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>16</u>** <u>_afterTokenTransfer</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>17</u>** <u>_delegate</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>18</u>** <u>_moveVotingPower</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>19</u>** <u>_writeCheckpoint</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>20</u>** <u>_add</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>21</u>** <u>_subtract</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>22</u>** <u>_unsafeAccess</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>23</u>** <u>_useNonce</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>24</u>** <u>DOMAIN_SEPARATOR</u> <u>external</u> <u>Passed</u> <u>No Issue</u>
**<u>25</u>** <u>nonces</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>26</u>** <u>permit</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**27** __ERC20Permit_init_unchained internal access only No Issue

<u>Initializing</u>



**28** __ERC20Permit_init internal access only

<u>Initializing</u>

**29** __ERC20Burnable_init internal access only

<u>Initializing</u>



**30** __ERC20Burnable_init_unchain
<u>ed</u>



internal access only

<u>Initializing</u>



No Issue


No Issue


No Issue



**<u>31</u>** <u>burn</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>32</u>** <u>burnFrom</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**33** __ERC20_init internal access only No Issue

<u>Initializing</u>


**34** __ERC20_init_unchained internal access only

<u>Initializing</u>



No Issue



**<u>35</u>** <u>name</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>36</u>** <u>symbol</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>37</u>** <u>decimals</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>38</u>** <u>totalSupply</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>39</u>** <u>balanceOf</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>40</u>** <u>transfer</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>41</u>** <u>allowance</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>42</u>** <u>approve</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>43</u>** <u>transferFrom</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>44</u>** <u>increaseAllowance</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>45</u>** <u>decreaseAllowance</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>46</u>** <u>_transfer</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>47</u>** <u>_mint</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>48</u>** <u>_burn</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>49</u>** <u>_approve</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>50</u>** <u>_spendAllowance</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>51</u>** <u>_beforeTokenTransfer</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>52</u>** <u>_afterTokenTransfer</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**53** __Ownable_init internal access only No Issue

<u>Initializing</u>



**54** __Ownable_init_unchained internal access only

<u>Initializing</u>



No Issue



**<u>55</u>** <u>onlyOwner</u> <u>modifier</u> <u>Passed</u> <u>No Issue</u>
**<u>56</u>** <u>owner</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>57</u>** <u>_checkOwner</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>58</u>** <u>renounceOwnership</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>59</u>** <u>transferOwnership</u> <u>write</u> <u>Passed</u> <u>No Issue</u>
**<u>60</u>** <u>_transferOwnership</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**61** __EIP712_init internal access only No Issue

<u>Initializing</u>



**62** __EIP712_init_unchained internal access only

<u>Initializing</u>



No Issue



**<u>63</u>** <u>_domainSeparatorV4</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>64</u>** <u>_buildDomainSeparator</u> <u>read</u> <u>Passed</u> <u>No Issue</u>
**<u>65</u>** <u>_hashTypedDataV4</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>66</u>** <u>_EIP712NameHash</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>67</u>** <u>_EIP712VersionHash</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>68</u>** <u>initialize</u> <u>write</u> <u>initializer</u> <u>No Issue</u>
**69** mint write Centralized Refer Audit
Ownership and Findings



Refer Audit



Findings



Privileges
<u>Management</u>

**70** setMintCapNumerator write Centralized
Ownership and

Privileges
<u>Management</u>



Refer Audit

Findings


**<u>71</u>** <u>_afterTokenTransfer</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>72</u>** <u>_mint</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>73</u>** <u>_burn</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>74</u>** <u>initializer</u> <u>modifier</u> <u>Passed</u> <u>No Issue</u>
**<u>75</u>** <u>reinitializer</u> <u>modifier</u> <u>Passed</u> <u>No Issue</u>
**<u>76</u>** <u>onlyInitializing</u> <u>modifier</u> <u>Passed</u> <u>No Issue</u>
**<u>77</u>** <u>_disableInitializers</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>78</u>** <u>_getInitializedVersion</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>
**<u>79</u>** <u>_isInitializing</u> <u>internal</u> <u>Passed</u> <u>No Issue</u>


## **Severity Definitions**

**Risk Level** **Description**


Critical vulnerabilities are usually straightforward to exploit
**Critical**
and can lead to token loss etc.



**High**



High-level vulnerabilities are difficult to exploit; however,
they also have a significant impact on smart contract
execution, e.g. public access to crucial



Medium-level vulnerabilities are important to fix;
**Medium**
however, they can’t lead to tokens lose



**Low**


**Lowest / Code**

**Style / Best**

**Practice**



Low-level vulnerabilities are mostly related to outdated,
unused, etc. code snippets, that can’t have a significant
impact on execution


Lowest-level vulnerabilities, code style violations and info
statements can’t affect smart contract execution and can
be ignored.


## **Audit Findings**

#### **Critical Severity**

No Critical severity vulnerabilities were found.

#### **High Severity**


No high-severity vulnerabilities were found.

#### **Medium**


No Medium-severity vulnerabilities were found.

#### **Low**


No low-severity vulnerabilities were found.

#### **Very Low / Informational / Best practices:**


(1) Centralized Ownership and Privileges Management:


Some functions of this smart contract are only called by the owner.


**L1MantleToken.sol**


 - mint


 - setMintCapNumerator


**Resolution:** We suggest making your smart contract 100% decentralized.


## **Centralization**

This smart contract has some functions which can be executed by the Admin (Owner)


only. If the admin wallet's private key would be compromised, then it would create trouble.


The following are Admin functions:


**L1MantleToken.sol**


  - mint: Allows the owner to mint new tokens and increase this token's total supply.


 - setMintCapNumerator: Mint Cap Numerator value can be set by the owner.


**Ownable.sol**


 - renounceOwnership: Deleting ownership will leave the contract without an owner,


removing any owner-only functionality.


 - transferOwnership: Current owner can transfer ownership of the contract to a new


account.


To make the smart contract 100% decentralized, we suggest renouncing ownership of the


smart contract once its function is completed.


## **Conclusion**

We were given a contract code in the form of <u>[Etherscan](https://etherscan.io/address/0xcd368c1d80120b0dd92447c87eb570154f8e685c#code)</u> web links. And we have used all


possible tests based on given objects as files. We observed 1 informational issue in the


smart contract. And these issues are not critical. So, **it’s good to go for the production** .


Since possible test cases can be unlimited for such smart contracts protocol, we provide


no such guarantee of future outcomes. We have used all the latest static tools and manual


observations to cover the maximum possible test cases to scan everything.


Smart contracts within the scope were manually reviewed and analyzed with static


analysis tools. Smart Contract’s high-level description of functionality was presented in the


As-is overview section of the report.


The audit report contains all found security vulnerabilities and other issues in the reviewed


code.


The security state of the reviewed smart contract, based on standard audit procedure


scope, is **“Secured”.**


## **Our Methodology**

We like to work with a transparent process and make our reviews a collaborative effort.


The goals of our security audits are to improve the quality of systems we review and aim


for sufficient remediation to help protect users. The following is the methodology we use in


our security audit process.


**Manual Code Review:**


In manually reviewing all of the code, we look for any potential issues with code logic, error


handling, protocol and header parsing, cryptographic errors, and random number


generators. We also watch for areas where more defensive programming could reduce the


risk of future mistakes and speed up future audits. Although our primary focus is on the


in-scope code, we examine dependency code and behavior when it is relevant to a


particular line of investigation.


**Vulnerability Analysis:**


Our audit techniques included manual code analysis, user interface interaction, and


whitebox penetration testing. We look at the project's web site to get a high level


understanding of what functionality the software under review provides. We then meet with


the developers to gain an appreciation of their vision of the software. We install and use


the relevant software, exploring the user interactions and roles. While we do this, we


brainstorm threat models and attack surfaces. We read design documentation, review


other audit results, search for similar projects, examine source code dependencies, skim


open issue tickets, and generally investigate details other than the implementation.


**Documenting Results:**


We follow a conservative, transparent process for analyzing potential security


vulnerabilities and seeing them through successful remediation. Whenever a potential


issue is discovered, we immediately create an Issue entry for it in this document, even


though we have not yet verified the feasibility and impact of the issue. This process is


conservative because we document our suspicions early even if they are later shown to


not represent exploitable vulnerabilities. We generally follow a process of first documenting


the suspicion with unresolved questions, then confirming the issue through code analysis,


live experimentation, or automated tests. Code analysis is the most tentative, and we


strive to provide test code, log captures, or screenshots demonstrating our confirmation.


After this we analyze the feasibility of an attack in a live system.


**Suggested Solutions:**


We search for immediate mitigations that live deployments can take, and finally we


suggest the requirements for remediation engineering for future releases. The mitigation


and remediation recommendations should be scrutinized by the developers and


deployment engineers, and successful mitigation and remediation is an ongoing


collaborative process after we deliver our report, and before the details are made public.


## **Disclaimers**

#### **EtherAuthority.io Disclaimer**

EtherAuthority team has analyzed this smart contract in accordance with the best industry

practices at the date of this report, in relation to: cybersecurity vulnerabilities and issues in

smart contract source code, the details of which are disclosed in this report, (Source

Code); the Source Code compilation, deployment and functionality (performing the

intended functions).


Due to the fact that the total number of test cases is unlimited, the audit makes no

statements or warranties on the security of the code. It also cannot be considered as a

sufficient assessment regarding the utility and safety of the code, bug-free status or any

other statements of the contract. While we have done our best in conducting the analysis

and producing this report, it is important to note that you should not rely on this report only.

We also suggest conducting a bug bounty program to confirm the high level of security of

this smart contract.

#### **Technical Disclaimer**


Smart contracts are deployed and executed on the blockchain platform. The platform, its

programming language, and other software related to the smart contract can have their

own vulnerabilities that can lead to hacks. Thus, the audit can’t guarantee explicit security

of the audited smart contracts.


## **Appendix**


#### **Code Flow Diagram - Mantle Token** **L1Mantle Token Diagram**


### **Slither Results Log**

Slither is a Solidity static analysis framework that uses vulnerability detectors, displays


contract details, and provides an API for writing custom analyses. It helps developers


identify vulnerabilities, improve code comprehension, and prototype custom analyses


quickly. The analysis includes a report with warnings and errors, allowing developers to


quickly prototype and fix issues.


We did the analysis of the project altogether. Below are the results.


**Slither Log >> L1MantleToken.sol**


### **Solidity Static Analysis**

Static code analysis is used to identify many common coding problems before a program


is released. It involves examining the code manually or using tools to automate the


process. Static code analysis tools can automatically scan the code without executing it.


**L1MantleToken.sol**


### **Solhint Linter**

Linters are the utility tools that analyze the given source code and report programming


errors, bugs, and stylistic errors. For the Solidity language, there are some linter tools


available that a developer can use to improve the quality of their Solidity contracts.


**L1MantleToken.sol**

```
Compiler version ^0.8.1 does not satisfy the ^0.5.8 semver
requirement
Pos: 1:3
Error message for require is too long
Pos: 9:63
Function name must be in mixedCase
Pos: 5:2972
Code contains empty blocks
Pos: 70:2972
Avoid making time-based decisions in your business logic
Pos: 17:3100
Error message for require is too long
Pos: 9:3123
Avoid using inline assembly. It is acceptable only in rare cases
Pos: 9:3216
Explicitly mark visibility in function (Set ignoreConstructors to
true if using solidity >=0.7.0)
Pos: 5:3286
Avoid making time-based decisions in your business logic
Pos: 20:3309
Avoid making time-based decisions in your business logic
Pos: 13:3329
Avoid making time-based decisions in your business logic
Pos: 88:3329
Avoid making time-based decisions in your business logic
Pos: 20:3331

```

**Software analysis result:**


This software reported many false positive results and some are informational issues. So,


those issues can be safely ignored.


