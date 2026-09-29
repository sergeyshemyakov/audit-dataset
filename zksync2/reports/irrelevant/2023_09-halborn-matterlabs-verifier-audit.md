# **MatterLabs -** **Verifier**
## Smart Contract Security Assessment

Prepared by: **Halborn**

Date of Engagement: **July** **12th,** **2023** **-** **July** **20th,** **2023**


Visit: **[Halborn.com](https://halborn.com)**


DOCUMENT REVISION HISTORY 2


CONTACTS 2


1 EXECUTIVE OVERVIEW 3


1.1 INTRODUCTION 4


1.2 ASSESSMENT SUMMARY 4


1.3 SCOPE 5


1.4 TEST APPROACH & METHODOLOGY 6


2 RISK METHODOLOGY 7


2.1 EXPLOITABILITY 8


2.2 IMPACT 9


2.3 SEVERITY COEFFICIENT 11


3 ASSESSMENT SUMMARY & FINDINGS OVERVIEW 13


4 MANUAL TESTING 13


5 AUTOMATED TESTING 24


5.1 STATIC ANALYSIS REPORT 25


Description 25


Slither results 25


5.2 AUTOMATED SECURITY SCAN 27


Description 27


MythX results 27



1


### DOCUMENT REVISION HISTORY

VERSION MODIFICATION DATE AUTHOR


0.1 Draft Document 07/21/2023 Gabi Urrutia


1.0 Final Report 09/15/2023 Gabi Urrutia

### CONTACTS


CONTACT COMPANY EMAIL


Rob Behnke Halborn [Rob.Behnke@halborn.com](mailto:Rob.Behnke@halborn.com)


Steven Walbroehl Halborn [Steven.Walbroehl@halborn.com](mailto:Steven.Walbroehl@halborn.com)


Gabi Urrutia Halborn [Gabi.Urrutia@halborn.com](mailto:Gabi.Urrutia@halborn.com)



2


# EXECUTIVE OVERVIEW



3


### 1.1 INTRODUCTION

This assessment was entirely focused on the new version of zkSync verifier

which is a modified version of the Permutations over Lagrange-bases for

Oecumenical Noninteractive arguments of Knowledge (PLONK) to optimize the

proof system for zkSync Era circuits.


MatterLabs engaged Halborn to conduct a security assessment on their

verifier smart contract beginning on July 12th, 2023 and ending on July

20th, 2023. The security assessment was scoped to the smart contract

provided to the Halborn team.

### 1.2 ASSESSMENT SUMMARY


The team at Halborn was provided one week for the engagement and assigned

a full-time security engineer to verify the security of the smart con
tract. The security engineer is a blockchain and smart-contract security

expert with advanced penetration testing, smart-contract hacking, and

deep knowledge of multiple blockchain protocols.


The purpose of this assessment is to:

#### • Ensure that smart contract functions operate as intended • Identify potential security issues within the smart contract


In summary, Halborn did not identify any security risks within the ver
ifier smart contract.



4


### 1.3 SCOPE

**1.** **IN-SCOPE:**


The security assessment was scoped to the following smart [contract:](https://github.com/matter-labs/zksync-2-contracts/blob/f783f571e16a1b1adddb13db45db741f83b94812/ethereum/contracts/verifier/Verifier.sol)

#### • ethereum/contracts/verifier/Verifier.sol


Commit ID: [f783f571e16a1b1adddb13db45db741f83b94812](https://github.com/matter-labs/zksync-2-contracts/commit/f783f571e16a1b1adddb13db45db741f83b94812)



5


### 1.4 TEST APPROACH & METHODOLOGY

Halborn performed a combination of manual and automated security testing

to balance efficiency, timeliness, practicality, and accuracy in regard

to the scope of this assessment. While manual testing is recommended

to uncover flaws in logic, process, and implementation; automated test
ing techniques help enhance coverage of the bridge code and can quickly

identify items that do not follow security best practices. The follow
ing phases and associated tools were used throughout the term of the

assessment:

#### • Research into architecture and purpose. • Smart contract manual code review and walkthrough. • Graphing out functionality and contract logic/connectivity/func

tions. (solgraph)
#### • Manual assessment of use and safety for the critical Solidity vari
ables and functions in scope to identify any arithmetic related

vulnerability classes.
#### • Manual testing by custom scripts. • Scanning of solidity files for vulnerabilities, security hotspots

or bugs. (MythX)
#### • Static Analysis of security for scoped contract, and imported func
tions. (Slither)
#### • Testnet deployment. (Foundry)



6


### 2. RISK METHODOLOGY

Every vulnerability and issue observed by Halborn is ranked based on **two**

**sets** of **Metrics** and a **Severity** **Coefficient** . This system is inspired by

the industry standard Common Vulnerability Scoring System.


The two **Metric** **sets** are: **Exploitability** and **Impact** . **Exploitability**

captures the ease and technical means by which vulnerabilities can be

exploited and **Impact** describes the consequences of a successful exploit.


The **Severity** **Coefficients** is designed to further refine the accuracy of

the ranking with two factors: **Reversibility** and **Scope** . These capture the

impact of the vulnerability on the environment as well as the number of

users and smart contracts affected.


The final score is a value between 0-10 rounded up to 1 decimal place and

10 corresponding to the highest security risk. This provides an objective

and accurate rating of the severity of security vulnerabilities in smart

contracts.


The system is designed to assist in identifying and prioritizing vul
nerabilities based on their level of risk to address the most critical

issues in a timely manner.



7


### 2.1 EXPLOITABILITY

Attack Origin (AO):


Captures whether the attack requires compromising a specific account.


Attack Cost (AC):


Captures the cost of exploiting the vulnerability incurred by the attacker

relative to sending a single transaction on the relevant blockchain.

Includes but is not limited to financial and computational cost.


Attack Complexity (AX):


Describes the conditions beyond the attacker’s control that must exist in

order to exploit the vulnerability. Includes but is not limited to macro

situation, available third-party liquidity and regulatory challenges.


Metrics:


Exploitability Metric

Metric Value Numerical Value
( _mE_ )


Arbitrary (AO:A) 1
Attack Origin (AO)
Specific (AO:S) 0.2



Attack Cost (AC)


Attack Complexity (AX)



Low (AC:L) 1

Medium (AC:M) 0.67

High (AC:H) 0.33


Low (AX:L) 1

Medium (AX:M) 0.67

High (AX:H) 0.33



Exploitability _E_ is calculated using the following formula:



_me_



_E_ “



ź



8


### 2.2 IMPACT

Confidentiality (C):


Measures the impact to the confidentiality of the information resources

managed by the contract due to a successfully exploited vulnerability.

Confidentiality refers to limiting access to authorized users only.


Integrity (I):


Measures the impact to integrity of a successfully exploited vulnerabil
ity. Integrity refers to the trustworthiness and veracity of data stored

and/or processed on-chain. Integrity impact directly affecting Deposit

or Yield records is excluded.


Availability (A):


Measures the impact to the availability of the impacted component re
sulting from a successfully exploited vulnerability. This metric refers

to smart contract features and functionality, not state. Availability

impact directly affecting Deposit or Yield is excluded.


Deposit (D):


Measures the impact to the deposits made to the contract by either users

or owners.


Yield (Y):


Measures the impact to the yield generated by the contract for either

users or owners.



9


Metrics:


Impact Metric

Metric Value Numerical Value
( _mI_ )



Confidentiality (C)


Integrity (I)


Availability (A)


Deposit (D)


Yield (Y)



None (I:N) 0

Low (I:L) 0.25

Medium (I:M) 0.5

High (I:H) 0.75

Critical (I:C) 1


None (I:N) 0

Low (I:L) 0.25

Medium (I:M) 0.5

High (I:H) 0.75

Critical (I:C) 1


None (A:N) 0

Low (A:L) 0.25

Medium (A:M) 0.5

High (A:H) 0.75

Critical 1


None (D:N) 0

Low (D:L) 0.25

Medium (D:M) 0.5

High (D:H) 0.75

Critical (D:C) 1


None (Y:N) 0

Low (Y:L) 0.25

Medium: (Y:M) 0.5

High: (Y:H) 0.75

Critical (Y:H) 1



Impact _I_ is calculated using the following formula:



_I_ “ _max_ p _mI_ q `



ř _<u>mI</u>_ <u>´</u> _<u>max</u>_ <u>p</u> _<u>mI</u>_ <u>q</u>

4



10


### 2.3 SEVERITY COEFFICIENT

Reversibility (R):


Describes the share of the exploited vulnerability effects that can be

reversed. For upgradeable contracts, assume the contract private key is

available.


Scope (S):


Captures whether a vulnerability in one vulnerable contract impacts re
sources in other contracts.


Coefficient

Coefficient Value Numerical Value
( _C_ )



Reversibility ( _r_ )



None (R:N) 1

Partial (R:P) 0.5

Full (R:F) 0.25



Changed (S:C) 1.25
Scope ( _s_ )
Unchanged (S:U) 1


Severity Coefficient _C_ is obtained by the following product:


_C_ “ _rs_



11


The Vulnerability Severity Score _S_ is obtained by:


_S_ “ _min_ p10 _, EIC_ ˚ 10q


The score is rounded up to 1 decimal places.


Severity Score Value Range


Critical 9        - 10


High 7         - 8.9


Medium 4.5        - 6.9


Low 2         - 4.4


Informational 0      - 1.9



12


### 3. ASSESSMENT SUMMARY & FINDINGS OVERVIEW

CRITICAL HIGH MEDIUM LOW INFORMATIONAL

##### 0 0 0 0 0



13


# MANUAL TESTING



14


The main goal of the manual testing performed during this assessment

was to test that the verifier is properly working to verify the zk

proofs generated by the zkSync Era circuits, focusing on the following

points/scenarios:


**<mark>Test</mark>** **<mark>Result</mark>**



Check that using any valid proof, the verifier is able to properly

verify it and returns a true as a result



Pass



15


**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if a maliciously

forged serialized proof is sent



Pass



**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if less than 44

words for serialized proof is sent



Pass



**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if less than 4

words for recursive aggregation input is sent



Pass



16


**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier returns a true for a public input with dirty

bits over Fr mask



Pass



17


**<mark>Test</mark>** **<mark>Result</mark>**



Check that the verifier returns a true having elliptic curve points

over modulo



Pass



18


**<mark>Test</mark>** **<mark>Result</mark>**


Check that the verifier returns a true, having Fr over modulo Pass



19


**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if more than 1

public inputs is sent



Pass



**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if empty public

inputs is sent



Pass



**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if more than 44

words for serialized proof is sent



Pass



20


**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if empty

serialized proof is sent



Pass



**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if more than 4

words for recursive aggregation input is sent



Pass



**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if empty recursive

aggregation input is sent



Pass



21


**<mark>Test</mark>** **<mark>Result</mark>**



Check that verifier reverts with proof is invalid if elliptic curve

point at infinity is sent within the serialized proof



Pass



**<mark>Test</mark>** **<mark>Result</mark>**



Check that the verifier reverts with invalid quotient evaluation if

an invalid public input is used



Pass



22


**<mark>Test</mark>** **<mark>Result</mark>**



Check that the verifier reverts with pairing failure if an invalid

recursive aggregative input is used



Pass



23


# AUTOMATED TESTING



24


### 5.1 STATIC ANALYSIS REPORT

Description:


Halborn used automated testing techniques to enhance the coverage of certain

areas of the scoped contract. Among the tools used was Slither, a Solidity static

analysis framework. After Halborn verified the contract in the repository and

was able to compile it correctly into their ABI and binary formats, Slither

was run on the verifier contract. This tool can statically verify mathematical

relationships between Solidity variables to detect invalid or inconsistent usage

of the contracts’ APIs across the entire code-base.


Slither results:


ethereum/contracts/verifier/Verifier.sol



25


#### • As a result of the tests carried out with the Slither tool, some results

were obtained and reviewed by Halborn. Based on the results reviewed, the

vulnerabilities were determined to be false positives.



26


### 5.2 AUTOMATED SECURITY SCAN

Description:


Halborn used automated security scanners to assist with detection of well-known

security issues, and to identify low-hanging fruits on the targets for this

engagement. Among the tools used was MythX, a security analysis service for

Ethereum smart contracts. MythX performed a scan on the verifier contract and

sent the compiled results to the analyzers to locate any vulnerabilities.


MythX results:

#### • No major issues found by Mythx.



27


**THANK** **YOU** **FOR** **CHOOSING**


