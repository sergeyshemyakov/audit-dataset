Ackee Blockchain Security


# **Safe**

### Allowance module

##### 9.9.2024


## **Contents**

1. Document Revisions. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3


2. Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


2.1. Ackee Blockchain Security . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


2.2. Audit Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


2.3. Finding classification. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


2.4. Review team . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7


2.5. Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7


3. Executive Summary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


Revision 1.0. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


Revision 1.1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


4. Summary of Findings. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10


Report revision 1.0 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


Revision team . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


System Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


Trust Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


L1: Possible division by zero in modulo operation . . . . . . . . . . . . . . . . . . . . . . . . 12


Appendix A: How to cite . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14


Ackee Blockchain Security 2 of 15


## **1. Document Revisions**

<u>1.0</u> Final Report 05.09.2024


<u>1.1</u> Fix Review 09.09.2024


Ackee Blockchain Security 3 of 15


## **2. Overview**

This document presents our findings in reviewed contracts.

#### **2.1. Ackee Blockchain Security**


<u>[Ackee Blockchain Security](https://github.com/ackee-blockchain)</u> is an auditing company based in Prague, Czech

Republic, specializing in audits and security assessments. Our mission is to

build a stronger blockchain community by sharing knowledge – we run free

[certification courses School of Solana, Summer School of Solidity](https://ackeeblockchain.com/school-of-solana) and teach

at the Czech Technical University in Prague. Ackee Blockchain Security is

backed by the largest VC fund focused on blockchain and DeFi in Europe,

<u>[RockawayX.](https://rockawayx.com/)</u>

#### **2.2. Audit Methodology**


1. **Technical specification/documentation** - a brief overview of the system is

requested from the client and the scope of the audit is defined.


2. **Tool-based analysis** - deep check with automated Solidity analysis tools

and <u>[Wake](https://getwake.io)</u> is performed.


3. **Manual code review** - the code is checked line by line for common

vulnerabilities, code duplication, best practices and the code architecture

is reviewed.


4. **Local deployment + hacking** - the contracts are deployed locally and we

try to attack the system and break it.


5. **Unit and fuzz testing** - run unit tests to ensure that the system works as

expected, potentially write missing unit or fuzz tests.


Ackee Blockchain Security 4 of 15


#### **2.3. Finding classification**

A _`Severity`_ rating of each finding is determined as a synthesis of two sub
ratings: _`Impact`_ and _`Likelihood`_ . It ranges from _`Informational`_ to _`Critical`_ .


If we have found a scenario in which an issue is exploitable, it will be assigned

an impact rating of _`High`_, _`Medium`_, or _`Low`_, based on the direness of the

consequences it has on the system. If we haven’t found a way, or the issue is

only exploitable given a change in configuration (such as deployment scripts,

compiler configuration, use of multi-signature wallets for owners, etc.) or

given a change in the codebase, then it will be assigned an impact rating of

_`Warning`_ or _`Info`_ .


_`Low`_ to _`High`_ impact issues also have a _`Likelihood`_, which measures the

probability of exploitability during runtime.


The full definitions are as follows:

###### **Severity**

```
                      Likelihood

```

**High** **Medium** **Low** **N/A**


**High** Critical High Medium       

**Medium** High Medium Low      

```
Impact

```


**Low** Medium Low Low 

**Warning** - - - Warning


**Info** - - - Info

```
     Table 1. Severity of findings

```


Ackee Blockchain Security 5 of 15


###### **Impact**


 - **High**  - Code that activates the issue will lead to undefined or catastrophic

consequences for the system.


 - **Medium**  - Code that activates the issue will result in consequences of

serious substance.


 - **Low**  - Code that activates the issue will have outcomes on the system that

are either recoverable or don’t jeopardize its regular functioning.


 - **Warning**  - The issue cannot be exploited given the current code and/or

configuration (such as deployment scripts, compiler configuration, use of

multi-signature wallets for owners, etc.), but could be a security

vulnerability if these were to change slightly. If we haven’t found a way to

exploit the issue given the time constraints, it might be marked as a

"Warning" or higher, based on our best estimate of whether it is currently

exploitable.


 - **Info**  - The issue is on the borderline between code quality and security.

Examples include insufficient logging for critical operations. Another

example is that the issue would be security-related if code or

configuration (see above) was to change.

###### **Likelihood**


 - **High**  - The issue is exploitable by virtually anyone under virtually any

circumstance.


 - **Medium**  - Exploiting the issue currently requires non-trivial preconditions.


 - **Low**  - Exploiting the issue requires strict preconditions.


Ackee Blockchain Security 6 of 15


#### **2.4. Review team**

The following table lists all contributors to this report. For authors of the

specific revision, see the “Revision team” section in the respective “Report

revision” chapter.


**Member’s Name** **Position**


Jan Kalivoda Lead Auditor


Josef Gattermayer, Ph.D. Audit Supervisor

#### **2.5. Disclaimer**


We’ve put our best effort to find all vulnerabilities in the system, however our

findings shouldn’t be considered as a complete list of all existing issues. The

statements made in this document should not be interpreted as investment

or legal advice, nor should its authors be held accountable for decisions made

based on them.


Ackee Blockchain Security 7 of 15


## **3. Executive Summary**

Safe is a smart account that allows to enable various modules. The Allowance

module manages transfer allowances for any tokens.

#### **Revision 1.0**


Safe engaged Ackee Blockchain Security to perform a security review of the

changes to the Allowance module with a total time donation of 1 engineering

day in a period between September 4 and September 5, 2024, with Jan

Kalivoda as the lead auditor.



The incremental audit was performed on the commit `bc76ff`

was the changed `ALLOWANCE_TRANSFER_TYPEHASH` .


During the review, we paid special attention to:




[1] and the scope




 - change of the typehash doesn’t affect negatively the module’s

functionality and security,


 - past audit report for the fork of the module to find applicable issues to

the current scope.


Our review resulted in 1 findings.


Ackee Blockchain Security recommends Safe:


 - address all reported issues.


See Report revision 1.0 for the system overview and trust model.

#### **Revision 1.1**



The fix review was done on the given commit `549ea1`

the previous revision were fixed.




[2]. All of the findings from



Ackee Blockchain Security 8 of 15


[1] full commit hash: `bc76ffd27a8a0c15c255ffcb61707bf7a30085eb`


[2] full commit hash: `549ea1605538a4aa0571fa8e4d44e0e762e60720`


Ackee Blockchain Security 9 of 15


## **4. Summary of Findings**

The following table summarizes the findings we identified during our review.

Unless overridden for purposes of readability, each finding contains:


 - a _`Description`_,


 - an _`Exploit scenario`_,


 - a _`Recommendation`_ and if applicable


 - a _`Fix`_ .


There might often be multiple ways to solve or alleviate the issue, with

varying requirements regarding the necessary changes to the codebase. In

that case, we will try to enumerate them all, clarifying which solves the

underlying issue better (albeit possibly only with architectural changes) than

others.


**Critical** **High** **Medium** **Low** **Warning** **Info** **Total**


0 0 0 1 0 0 1

```
           Table 2. Findings Count by Severity

```

**Finding title** **Severity** **Reported** **Status**



<u>L1: Possible division by zero</u>

<u>in modulo operation</u>



Low <u>1.0</u> Fixed


```
              Table 3. Table of Findings

```

Ackee Blockchain Security 10 of 15


## **Report revision 1.0**

#### **Revision team**

**Member’s Name** **Position**


Jan Kalivoda Lead Auditor


Josef Gattermayer, Ph.D. Audit Supervisor

#### **System Overview**


The contract is a Safe module that manages transfer allowances for any

tokens.

#### **Trust Model**


The contract can be considered trustless.


Ackee Blockchain Security 11 of 15


#### **L1: Possible division by zero in modulo operation**

```
Low severity issue

```

Impact: Low Likelihood: Low


Target: AllowanceModule.sol Type: Arithmetics

###### **Description**


It is possible to set the `resetTimeMin` to 0. When the `resetBaseMin` is bigger

than 0 and the `resetTimeMin` is 0, then the branch with modulo operation is

triggered and it will cause a division by zero. Since it is also in Solidity version

<0.8.0, it consumes all gas.

```
Listing 1. Excerpt from AllowanceModule

 75 function setAllowance( address delegate, address token, uint96
   allowanceAmount, uint16 resetTimeMin, uint32 resetBaseMin) public {
 76 require (delegate != address ( 0 ), "delegate != address(0)") ;
 77 require (
 78 delegates[ msg.sender ][ uint48 (delegate)].delegate == delegate,
 79 "delegates[msg.sender][uint48(delegate)].delegate == delegate"
 80 );
 81 Allowance memory allowance = getAllowance( msg.sender, delegate, token);
 82 if (allowance.nonce == 0 ) {
 83 // New token
 84 // Nonce should never be 0 once allowance has been activated
 85 allowance.nonce = 1 ;
 86 tokens[ msg.sender ][delegate].push(token);
 87 }
 88 // Divide by 60 to get current time in minutes
 89 // solium-disable-next-line security/no-block-members
 90 uint32 currentMin = uint32 ( block.timestamp / 60 );
 91 if (resetBaseMin > 0 ) {
 92 require (resetBaseMin <= currentMin, "resetBaseMin <= currentMin") ;
 93 allowance.lastResetMin = currentMin - ((currentMin - resetBaseMin) %
   resetTimeMin);
 94 } else if (allowance.lastResetMin == 0 ) {

```

Ackee Blockchain Security 12 of 15


###### **Exploit scenario**

The The `setAllowance` function is called wit the following parameters and

unexpectedly reverts.

```
 module.setAllowance(
    delegate=delegate_address,
    token=token_address,
    allowanceAmount= 10,
    resetTimeMin= 0,
    resetBaseMin= 1,
 )

###### **Recommendation**

```

Add check for `resetTimeMin` to be bigger than 0.

###### **Fix 1.1**


The issue is fixed by adding the data validation.


<u>Go back to Findings Summary</u>


Ackee Blockchain Security 13 of 15


## **Appendix A: How to cite**

Please cite this document as:


<u>[Ackee Blockchain Security, Safe: Allowance module, 9.9.2024.](https://github.com/ackee-blockchain)</u>


Ackee Blockchain Security 14 of 15


# **Thank You**
### Ackee Blockchain a.s.

Rohanske nabrezi 717/4
186 00 Prague
Czech Republic

hello@ackee.xyz


