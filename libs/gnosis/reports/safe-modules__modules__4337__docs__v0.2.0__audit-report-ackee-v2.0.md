# **Safe**

### ERC-4337 Module

##### by Ackee Blockchain _`5.12.2023`_


## **Contents**

1. Document Revisions. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


2. Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


2.1. Ackee Blockchain . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


2.2. Audit Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


2.3. Finding classification. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6


2.4. Review team. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


2.5. Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


3. Executive Summary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9


Revision 1.0. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9


Revision 1.1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10


Revision 1.2 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10


Revision 2.0 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


4. Summary of Findings . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12


5. Report revision 1.0 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14


5.1. System Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14


5.2. Trust Model. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15


W1: Lack of data validation in the constructor. . . . . . . . . . . . . . . . . . . . . . . . . . . 16


W2: Usage of `solc` optimizer. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 17


I1: Naming convention does not follow ERC-4337 standard . . . . . . . . . . . . . . . 18


I2: Missing underscore in the internal function . . . . . . . . . . . . . . . . . . . . . . . . . . 19


I3: Contract name is not equal to file name . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20


I4: Contract does not allow to specify `validAfter` and `validUntil`


parameters . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21


I5: Incorrect documentation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 23


6. Report revision 1.1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 25


7. Report revision 1.2 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 26


2 of 38


L1: Module does not support contract signatures . . . . . . . . . . . . . . . . . . . . . . . 27


L2: Incorrect length of return bytes. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 28


8. Report revision 2.0 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 30


M1: User wallet can be forced to pay more gas than expected . . . . . . . . . . . 31


I6: Incorrect in-code comment. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 33


Appendix A: How to cite . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 34


Appendix B: Wake outputs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 35


B.1. Tests. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 35


3 of 38


## **1. Document Revisions**

<u>0.1</u> Draft report 3.11.2023


<u>1.1</u> Final report 6.11.2023


<u>1.1</u> Fix review 8.11.2023


<u>1.2</u> Fix review of internal findings 27.11.2023


<u>2.0</u> Final report version 2.0 5.12.2023



4 of 38


## **2. Overview**

This document presents our findings in reviewed contracts.

#### **2.1. Ackee Blockchain**


<u>[Ackee Blockchain](https://github.com/ackee-blockchain)</u> is an auditing company based in Prague, Czech Republic,

specializing in audits and security assessments. Our mission is to build a

stronger blockchain community by sharing knowledge – we run free

[certification courses School of Solana, Summer School of Solidity](https://ackeeblockchain.com/school-of-solana) and teach

at the Czech Technical University in Prague. Ackee Blockchain is backed by

the largest VC fund focused on blockchain and DeFi in Europe, <u>[RockawayX.](https://rockawayx.com/)</u>

#### **2.2. Audit Methodology**


1. **Technical specification/documentation** - a brief overview of the system is

requested from the client and the scope of the audit is defined.


2. **Tool-based analysis** - deep check with automated Solidity analysis tools

and <u>[Wake](https://github.com/Ackee-Blockchain/wake)</u> is performed.


3. **Manual code review** - the code is checked line by line for common

vulnerabilities, code duplication, best practices and the code architecture

is reviewed.


4. **Local deployment + hacking** - the contracts are deployed locally and we

try to attack the system and break it.


5. **Unit and fuzz testing** - run unit tests to ensure that the system works as

expected, potentially write missing unit or fuzz tests.


5 of 38


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


**Severity**

```
                      Likelihood

```

**High** **Medium** **Low** **-**


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

6 of 38


**Impact**


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


**Likelihood**


 - **High**  - The issue is exploitable by virtually anyone under virtually any

circumstance.


 - **Medium**  - Exploiting the issue currently requires non-trivial preconditions.


 - **Low**  - Exploiting the issue requires strict preconditions.


7 of 38


#### **2.4. Review team**

**Member’s Name** **Position**


Lukáš Böhm Lead Auditor


Jan Kalivoda Auditor


Josef Gattermayer, Ph.D. Audit Supervisor

#### **2.5. Disclaimer**


We’ve put our best effort to find all vulnerabilities in the system, however our

findings shouldn’t be considered as a complete list of all existing issues. The

statements made in this document should not be interpreted as investment

or legal advice, nor should its authors be held accountable for decisions made

based on them.


8 of 38


## **3. Executive Summary**

The repository provided by Safe contains two smart contracts:

`Safe4337Module` and `AddModulesLib` . The codebase extends the functionality of

the Safe account wallet with a new contract, which allows ERC-4337

compatibility.

#### **Revision 1.0**


Safe engaged Ackee Blockchain to perform a security review of the Safe

protocol with a total time donation of 3 engineering days in a period between

October 30 and November 3, 2023 and the lead auditor was Lukáš Böhm. The

audit has been performed on the commit `53211cc` [1] and the scope was the

following:


 - Safe4337Module.sol


 - AddModulesLib.sol


[We began our review by using static analysis tools, namely Wake. We then](https://github.com/Ackee-Blockchain/wake)

took a deep dive into the logic of the contracts. For testing and fuzzing, we

[have involved Wake](https://github.com/Ackee-Blockchain/wake) testing framework. We implemented tests for account

creation when first User Operation is sent. See <u>Appnedix B</u> for more

information about the test. During the review, we paid special attention to:


 - ensuring the code follows ERC-4337 standard,


 - detecting possible malicious behavior between the simulation and

execution,


 - ensuring access controls are robust enough and compatible with ERC
4337 flow,


 - looking for common issues such as data validation.


9 of 38


Our review resulted in 7 findings, ranging from Info to warning severity. The

codebase is well designed and follows the best practices and ERC-4337

standard. The complexity of the codebase is hidden in the flow described in

ERC-4337 standard. The codebase is well-documented and tested.


Ackee Blockchain recommends Safe:


 - update naming convention to achieve full ERC-4337 compatibility,


 - address all other reported issues.


See Revision 1.0 for the system overview of the codebase.

#### **Revision 1.1**


The client provided the repository with the updated codebase on the given

commit: `1981fbc` [2]. The fix review was performed on November 8, 2023. The

codebase was updated according to the recommendations from the previous

revision.


See the summary of the findings for the current status of issues.


See Revision 1.1 for the review of the updated codebase and additional

information we consider essential for the current scope.

#### **Revision 1.2**


The client discovered two low issues that caused the contract to be not 100%

compatible with current safe functionalities. The client provided the updated

repository with the updated codebase on the given commit: `0371f5ac` [3].


The fix review was performed on November 27, 2023.


See the summary of the findings for the current status of issues, including

the client’s discovered issues.


10 of 38


See Revision 1.2 for the review of the updated codebase and additional

information we consider essential for the current scope.

#### **Revision 2.0**


The client updated the codebase to version `0.2.0` as a response to the

potential issues, where a user’s wallet may pay more gas than expected (see

<u>M1) if the malicious actor changes one of the User Operation parameters. The</u>

updated codebase was delivered on the given commit: `c366d82` [4], and the

review was performed on December 4 and 5, 2023.


During the review, we emphasized the new way of handling a User Operation

structure and its signing. We also implemented tests where we checked that

the variable `operationData` is encoded as expected, and we compared the

result with other possible implementations of the same functionality

mentioned in the <u>[Pull request #177.](https://github.com/safe-global/safe-modules/pull/177)</u>


The codebase is very well documented and tested. The only problem we

discovered is one factically <u>incorrect in-code comment, which was</u>

immediately fixed by the client on the commit: `25779b5` [5].


See the summary of the findings for the current status of issues, including

the client’s discovered issues.


See Revision 2.0 for the review of the updated codebase and additional

information we consider essential for the current scope.


[1] full commit hash: 53211cc3dc12a0f5ffadb2bdce9089403fdc8bdd


[2] full commit hash: 1981fbc63e3850d626074d81d22a198afe64ac03


[3] full commit hash: 0371f5ac81da1a5275e5c5643fb95c1c4dda2121


[4] full commit hash: c366d822c42c656df3988624897a5b88fa83b2d7


[5] full commit hash: 25779b5a5077e109a585993a02c4dad2209ab084


11 of 38


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


**Severity** **Reported** **Status**



<u>W1: Lack of data validation in</u>

<u>the constructor</u>



Warning <u>1.0</u> Fixed



<u>W2: Usage of</u> <u>`solc`</u> <u>optimizer</u> Warning <u>1.0</u> Acknowledged



<u>I1: Naming convention does</u>

<u>not follow ERC-4337</u>

<u>standard</u>


<u>I2: Missing underscore in the</u>

<u>internal function</u>


<u>I3: Contract name is not</u>

<u>equal to file name</u>



Info <u>1.0</u> Fixed


Info <u>1.0</u> Fixed


Info <u>1.0</u> Fixed


12 of 38


<u>I4: Contract does not allow</u>

<u>to specify</u> <u>`validAfter`</u> <u>and</u>

<u>`validUntil`</u> <u>parameters</u>



**Severity** **Reported** **Status**


Info <u>1.0</u> Acknowledged



<u>I5: Incorrect documentation</u> Info <u>1.0</u> Fixed



<u>L1: Module does not support</u>

<u>contract signatures</u>


<u>L2: Incorrect length of</u>

<u>return bytes</u>


<u>M1: User wallet can be</u>

<u>forced to pay more gas than</u>

<u>expected</u>


<u>I6: Incorrect in-code</u>

<u>comment</u>



Low <u>1.2</u> Fixed


Low <u>1.2</u> Fixed


Medium <u>2.0</u> Fixed


Info <u>2.0</u> Fixed


```
Table 2. Table of Findings

```


13 of 38


## **5. Report revision 1.0**

#### **5.1. System Overview**

This section contains an outline of the audited contracts. Note that this is

meant for understandability purposes and does not replace project

documentation.


**Contracts**


Contracts we find important for better understanding are described in the

following section.


**Safe4337Module**


The contract is a Safe Fallback handler and Module at the same time. The

contract receives calls forwarded from the `fallback` function inside the Safe

contract, and it can call the function `executeTransactionFromModule` . These

functionalities are necessary for the contract to work correctly with ERC
4337 contracts.


The contract implements functions defined by ERC-4337 standard. The first

one is the `validateUserOp`, which is called by <u>EntryPoint</u> contract during the

simulation of User Operation. As defined, it performs several validations:


 - The address of `msg.sender` == sender of a User Operation.


 - Only two functions can be called in User Operation - `executeUserOp` or

`executeUserOpWithErrorString` .


 - Only trusted EntryPoint can call Safe (that forwards the call to this

contract by fallback).


Another two functions: `executeUserOp` and `executeUserOpWithErrorString`

perform transaction execution and are callable only by <u>EntryPoint</u> contract.


14 of 38


The rest of the functions are performing signature validation.


**AddModulesLib**


The library is used when an account makes the first User Operation, and a

wallet has to be created with `InitCode` . In this case, modules must be added

to the Safe contract to ensure a correct functionality compatible with ERC
4337.


**Actors**


This part describes actors of the system, their roles, and permissions.


**Safe wallet**


The Safe Wallet initiates the User Operation. Moreover, it implements ERC
4337 compatible functions for the User Operation simulation and execution.


**EntryPoint**


The contract is defined by the ERC-4337 standard, which is called by a

bundler of User Operations initiated by <u>account wallets.</u>

#### **5.2. Trust Model**


<u>EntryPoint</u> is a main trusted component. Setting the address to a malicious

one can cause fatal consequences.


The ERC-4337 standard defines the trust model of the account. Functions

only work correctly if they are called by <u>EntryPoint</u> contract, forwarded from

Safe contract.


15 of 38


#### **W1: Lack of data validation in the constructor**

Impact: Warning Likelihood: N/A


Target: Safe4337Module Type: Data validation


**Description**


The contract Safe4337Module does not perform any data validation inside

the constructor. Even though there is no direct threat, the data validation

should be performed to avoid unintended behavior if the mistake goes

unnoticed, or to avoid additional cost for a new deployment as there is no

setter function for a new `entryPoint` .


**Recommendation**


Perform contract existing checks, or zero address check, to avoid some

unintended mistakes during the contract creation.


**Fix 1.1**


Zero-address check was added to the constructor.


<u>Go back to Findings Summary</u>


16 of 38


#### **W2: Usage of solc optimizer**

Impact: Warning Likelihood: N/A

Target: `**/*` Type: Compiler

configuration


**Description**


The project uses `solc` optimizer. Enabling `solc` optimizer <u>[may lead to](https://docs.soliditylang.org/en/latest/bugs.html)</u>

<u>[unexpected bugs. The Solidity compiler was audited in November 2018, and](https://docs.soliditylang.org/en/latest/bugs.html)</u>

the audit <u>[concluded](https://docs.google.com/document/d/1PZBSCBWBwd6AqWCgXqLnw8FNQ4HRurP5usrXuKuU0a0/edit#heading=h.l6fakub3mvnn)</u> that the optimizer may not be safe.


**Recommendation**


Until the `solc` optimizer undergoes more stringent security analysis, opt-out

using it. This will ensure the protocol is resilient to any existing bugs in the

optimizer.


**Fix 1.1**


The team acknowledged the warning. The reasons are explained in the

documentation:


After careful consideration, we decided to enable the optimizer

for the following reasons:


  - The most critical functionality, such as signature checks and

replay protection, is handled by the Safe and Entrypoint

contracts.


  - The entrypoint contract uses the optimizer.


<u>Go back to Findings Summary</u>


17 of 38


#### **I1: Naming convention does not follow ERC-4337** **standard**

Impact: Info Likelihood: N/A


Target: Safe4337Module Type: Best practices


**Description**


The function `validateUserOp` does not follow ERC-4337 standard naming

convention in two places:


 - Input parameter `requiredPrefund` should be named `missingAcountFunds` .


 - Return parameter `validationResult` should be named `validationData` .


**Recommendation**


Change the names of the mentioned variables to follow the standard ERC
4337. It makes the code more easy to understand for users and developers.


**Fix 1.1**


Parameters names were changed as proposed.


<u>Go back to Findings Summary</u>


18 of 38


#### **I2: Missing underscore in the internal function**

Impact: Info Likelihood: N/A


Target: Safe4337Module Type: Best practices


**Description**


The function `validateSignatures` is internal, but it does not contain an

underscore in its name.


**Recommendation**


Change the names from `validateSignatures` to `_validateSignatures` . It makes

the code more easy to read and understand while auditing or debugging.


**Fix 1.1**


The name of the function was changed as proposed.


<u>Go back to Findings Summary</u>


19 of 38


#### **I3: Contract name is not equal to file name**

Impact: Info Likelihood: N/A


Target: Safe4337Module Type: Best practices


**Description**


The contract’s name is `Safe4337Module` ; however, the name of the solidity file

is `EIP4337Module.sol` . There is no rule to match the names, but it is good

practice, making the orientation in the codebase easier.


**Recommendation**


Change the name of the file to `Safe4337Module.sol`


**Fix 1.1**


The name of the file was changed to match the contract’s name.


<u>Go back to Findings Summary</u>


20 of 38


#### **I4: Contract does not allow to specify validAfter** **and validUntil parameters**

Impact: Info Likelihood: N/A


Target: Safe4337Module Type: Best practices


**Description**


The contact `Safe4337Module` automatically returns `validationResult` from a

function `validateUserOp` . Based on the standard, it should contain three

encoded parameters:


 - aggregator address


 - validAfter


 - validAfter


Two `validX` parameters are used to specify the lifetime of the User Operation.

The contract always returns `0` for both parameters. This behavior is NOT

wrong, and it follows ERC-4337, and zero value means the User Operation is

valid without any time limitation.


Adding the ability to set values `validAfter` `validAfter` will give more flexibility

to the wallet.


**Recommendation**


Consider adding the ability to change these two parameters by the wallet

owner.


**Fix 1.1**


The issue was acknowledged with the following comment:


21 of 38


We are choosing not to support this feature at the moment but

may implement it in a follow-up revision of the module


<u>Go back to Findings Summary</u>


22 of 38


#### **I5: Incorrect documentation**

Impact: Info Likelihood: N/A

Target: `**/*` Type: Documentation


**Description**


The code snippet in the README.md file in a chapter Setup Flow contains

mistakes.


 - Enable Modules **/
bytes memory initExecutor = ADD_MODULES_LIB_ADDRESS;
bytes memory initData = abi.encodeWithSignature( <mark>"enableModules",</mark> [
<mark>4337_</mark> MODULE_ADDRESS, ENTRY_POINT_ADDRESS]);


/** Setup Safe **/
// We do not want to use any payment logic therefore, this is all set to 0
bytes memory setupData = abi.encodeWithSignature( <mark>"setup",</mark> owners,
threshold, initExecutor, initData, <mark>4337_</mark> MODULE_ADDRESS, address(0), 0,
address(0));


/** Deploy Proxy **/
bytes memory deployData = abi.encodeWithSignature( <mark>"createProxyWithNonce",</mark>
SAFE_SINGLETON_ADDRESS, setupData, salt);


/** Encode for 4337 **/
bytes memory initCode = abi.encodePacked(SAFE_PROXY_FACTORY_ADDRESS,
deployData);


The problem is in `abi.encodeWithSignature` format, where the first parameter

must be a complete function signature, including argument types. Instead of

the line:


abi.encodeWithSignature( <mark>"createProxyWithNonce",</mark> SAFE_SINGLETON_ADDRESS,
setupData, salt);


23 of 38


It should be:


abi.encodeWithSignature( <mark>"createProxyWithNonce(address,bytes,uint256)",</mark>
SAFE_SINGLETON_ADDRESS, setupData, salt);


**Recommendation**


Change the documentation to the correct format, to make the Setup Flow

work correctly for users.


**Fix 1.1**


The code snippet was fixed.


<u>Go back to Findings Summary</u>


24 of 38


## **6. Report revision 1.1**

No significant changes were performed in the contracts, and no new

vulnerabilities were found. All the changes are responding to reported issues.


25 of 38


## **7. Report revision 1.2**

The function `_getOperationData` was added so the not-hashed data can be

passed to the main Safe contract to verify the signature. No new issues were

discovered.


26 of 38


#### **L1: Module does not support contract signatures**

```
Low severity issue

```

Impact: Low Likelihood: Low


Target: Safe4337Module Type: Compatibility

```
The Safe team internally discovered the issue.

```

**Description**


The contract does not support verification of contract signatures based on

**ERC-1271** . The problem is that the contract does not call a Safe core contract

with encoded operation bytes but only with a hash of data and signatures.


try ISafe(payable(userOp.sender)).checkSignatures(operationHash, <mark>"",</mark>
userOp.signature)


The encoded operation bytes are necessary for **ERC-1271** signature

verification implemented in the Safe core contract.


**Fix 1.2**


The function `_getOperationData` to get not hashed operation data was added,

so the contract can now call Safe core contract with `operationData` data, and

it is compatible with **ERC-1271** signatures.


try ISafe(payable(userOp.sender)).checkSignatures(operationHash,
operationData, userOp.signature)


<u>Go back to Findings Summary</u>


27 of 38


#### **L2: Incorrect length of return bytes**

```
Low severity issue

```

Impact: Low Likelihood: Low


Target: Safe4337Module Type: Contract logic

```
The Safe team internally discovered the issue.

```

**Description**


The function `executeUserOpWithErrorString` executes a user operation and

returns an error message if execution is not successful.


if (!success) {
// solhint-disable-next-line no-inline-assembly
assembly {
revert(add(returnData, 0x20), returnData)
}
}


The `revert` OP code works in the following way: `revert(a,b)` returns the data

from memory, of size `b` starting from slot `a` . The first parameter in the code

snippet is correct, but the second one returns memory offset `returnData`

instead of the length `mload(returnData)` .


It is not a serious issue because the offset will always be a bigger number

than the length of the data. However, it returns an unnecessary long revert

string.


**Fix 1.2**


The code was rewritten in the following way:


28 of 38


if (!success) {
// solhint-disable-next-line no-inline-assembly
assembly ( <mark>"memory-safe")</mark> {
revert(add(returnData, 0x20), mload(returnData))
}
}


<u>Go back to Findings Summary</u>



29 of 38


## **8. Report revision 2.0**

The updated codebase contains two main changes:


 - In the current codebase **all** the parameters of the User Operation are

signed by the user.


 - The parameter `signature` contains values defining the time range of

signature validity: `validUntil`, `validAfter` .


Additionally, the new structure `EncodedSafeOpStruct` was defined and it is used

internally for computing EIP-712 struct-hash.


30 of 38


#### **M1: User wallet can be forced to pay more gas** **than expected**

```
Medium severity issue

```

Impact: Medium Likelihood: Medium


Target: Safe4337Module Type: Gas griefing

```
The Safe team internally discovered the issue.

```

**Description**


The contract does not include all the User Operation parameters in its

signature mechanism. Two missing parameters are: `initCode` and

`paymasterAndData` . Because those parameters are not included in the signed

data structure, changing them in the User Operation is possible. If other

(signed) parameters are correct, the User Operation will be executed. A

malicious actor can cause a user’s wallet to pay more gas fees than

expected.


**Exploit scenario**


Bob sends his User Operation to the mempool with a variable `paymasterAndData`

pointing to a paymaster contract. Alice front-runs Bob and sends the same

User Operation to the mempool but with **empty** `paymasterAndData` variable. If

Bob’s wallet has any available Ether, the wallet will pay for the transaction

execution instead of a paymaster contract.


If `initCode` is changed by Alice, it can perform some on-chain operation

before the actual wallet initialization, which will cause Bob’s wallet to spend

more gas than expected.


31 of 38


**Fix 2.0**


The logic was rewritten, and all the User Operation parameters are now

signed.


<u>Go back to Findings Summary</u>


32 of 38


#### **I6: Incorrect in-code comment**

Impact: Info Likelihood: N/A


Target: Safe4337Module Type: Documentation


**Description**


The internal function `_validateSignatures` contains the following NatSpec in
code documentation:


/**
 - @dev Validates that the user operation is correctly signed. Reverts
if signatures are invalid.
 - @param userOp User operation struct.
 - @return validationData An integer indicating the result of the
validation.
*/


The first line claims that `revert` will happen when signatures are invalid;

however, this is incorrect. Instead of revert, when signatures are invalid, the

`validationData` variable will be returned with a first byte `0x01` representing a

signature validation fail.


**Recommendation**


Update the in-code documentation by deleting the sentence or changing it.


**Fix 2.0**


The comment was changed.


<u>Go back to Findings Summary</u>


33 of 38


## **Appendix A: How to cite**

Please cite this document as:


<u>[Ackee Blockchain, Safe: ERC-4337 Module, 5.12.2023.](https://github.com/ackee-blockchain)</u>



34 of 38


## **Appendix B: Wake outputs**

#### **B.1. Tests**

The following test simulates contract creation with initCode in the first User

Operation initiated by an account.


class Safe4337Fuzz(FuzzTest):
safes: Dict[Safe, Tuple[List[Account], int]]
safe_nonces: DefaultDict[Safe, int]
erc4337_module: Safe4337Module
add_modules_lib: AddModulesLib


def __init__(self) -> None:
self.entry_point =
IEntryPoint( <mark>"0x0576a174D229E3cFA37253523E645A78A0C91B57")</mark>
self.safe_proxy_factory =
Account( <mark>"0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67")</mark>
self.safe_singleton =
Account( <mark>"0x41675C099F32341bf84BFc5382aF534df5C7461a")</mark>


def pre_sequence(self) -> None:
self.safes = {}
self.safe_nonces = defaultdict(int)
self.erc4337_module = Safe4337Module.deploy(self.entry_point)
self.add_modules_lib = AddModulesLib.deploy()


def _random_safe_op(self) -> bytes:
return Abi.encode_call(
Safe4337Module.executeUserOp,

[random_account(), 0, random_bytes(0, 32), random.choice([0,
1])],
)


def _random_user_op(self, safe: Safe, init_code: bytes) ->
UserOperation:
op = UserOperation(
safe.address,
self.safe_nonces[safe],


35 of 38


bytearray(init_code),
bytearray(self._random_safe_op()),
1_000_000,
1_000_000,
0,
0,
0,
bytearray(b <mark>"")</mark>,
bytearray(b <mark>"")</mark>,
)
op.signature = bytearray(self._sign_user_op(safe, op))
return op


def _sign_user_op(self, safe: Safe, user_op: UserOperation) -> bytes:
accounts, threshold = self.safes[safe]
signers = sorted(random.sample(accounts, threshold))
hash = self.erc4337_module.getOperationHash(
safe,
user_op.callData,
user_op.nonce,
user_op.preVerificationGas,
user_op.verificationGasLimit,
user_op.callGasLimit,
user_op.maxFeePerGas,
user_op.maxPriorityFeePerGas,
self.entry_point,
)
signature = bytearray()
for signer in signers:
signature += signer.sign_hash(hash)
return signature


def _run_user_op(self, user_op: UserOperation):
with must_revert(IEntryPoint.ValidationResult) as e:
self.entry_point.simulateValidation(user_op)


tx = self.entry_point.handleOps([user_op], Address(1))
#print(tx.call_trace)
#breakpoint()


@flow(max_times=10)
def flow_create_safe_execute_op(self):


36 of 38


owners_count = random.randint(2, 5)
owners = random.sample(default_chain.accounts, owners_count)
threshold = random.randint(1, owners_count)


init_data = Abi.encode_call(
AddModulesLib.enableModules,

[[self.erc4337_module, self.add_modules_lib]],
)
setup_data = Abi.encode_call(
Safe.setup,

[owners, threshold, self.add_modules_lib, init_data,
self.erc4337_module, Address(0), 0, Address(0)],
)
deploy_data = Abi.encode_call(
SafeProxyFactory.createProxyWithNonce,

[self.safe_singleton, setup_data, 0],
)
init_code = Abi.encode_packed([ <mark>"address",</mark> <mark>"bytes"]</mark>,

[self.safe_proxy_factory, deploy_data])


with must_revert(IEntryPoint.SenderAddressResult) as e:
self.entry_point.getSenderAddress(init_code)
safe = Safe(e.value.sender)


self.safes[safe] = (owners, threshold)


user_op = self._random_user_op(safe, init_code)
self._run_user_op(user_op)


assert len(safe.code)     - 0


@flow()
def flow_execute_op(self):
if len(self.safes) == 0:
return


safe = random.choice(list(self.safes.keys()))
user_op = self._random_user_op(safe, b <mark>"")</mark>
self._run_user_op(user_op)



37 of 38


# **Thank You**

### Ackee Blockchain a.s.

##### Prague, Czech Republic hello@ackeeblockchain.com h�ps://twi�er.com/AckeeBlockchain


