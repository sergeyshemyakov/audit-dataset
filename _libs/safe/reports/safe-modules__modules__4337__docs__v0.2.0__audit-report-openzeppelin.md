### | security

# **Safe 4337** **Module Audit**

#### **February 7, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5

AddModulesLib 5


Security Model ____________________________________________________________________  6

Privileged Roles 6


Medium Severity ___________________________________________________________________  7

M-01 Potential Obsolescence for Safe4337Module 7


Low Severity ______________________________________________________________________  8

L-01 Floating Pragma 8

L-02 Misleading Documentation in Safe4337Module Contract 8

L-03 Missing Docstrings 9


Notes & Additional Information ______________________________________________________  9

N-01 Inefficiency in enableModules Function Due to Reverse Loop Operation 9

N-02 Misleading Contract Name 10

N-03 Inefficient Modifier Usage Leading to Increased Bytecode Size 10

N-04 Lack of Security Contact 10

N-05 Use Custom Errors 11

N-06 Inconsistent Use of Named Returns 12


Conclusion ______________________________________________________________________ 13


Safe 4337 Module Audit − Table of Contents − 2


## **Summary**

Type Account Abstraction


Timeline From 2024-01-16
To 2024-01-23


Languages Solidity



Critical Severity
Issues


High Severity
Issues


Medium Severity
Issues



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



Total Issues 10 (8 resolved)



Low Severity Issues 3 (3 resolved)



Notes & Additional
Information



6 (4 resolved)



Safe 4337 Module Audit − Summary − 3


## **Scope**

We audited the <u>[safe-global/safe-modules](https://github.com/safe-global/safe-modules)</u> repository at commit <u>[3853f34.](https://github.com/safe-global/safe-modules/tree/3853f34f31837e0a0aee47a4452564278f8c62ba)</u>


In scope were the following files:

```
modules
└── 4337
└── contracts
├── AddModulesLib.sol
└── Safe4337Module.sol

```

Safe 4337 Module Audit − Scope − 4


## **System Overview**

The <mark>`Safe4337Module`</mark> contract serves as an important extension to the existing Safe

contracts. Specifically, it introduces compatibility with the ERC-4337 standard for account

abstraction.


**Key Features of** **<mark>`Safe4337Module`</mark>**


1. ERC-4337 Compliance: The module ensures that Safe contracts can interact with the

EVM chains following the ERC-4337 account abstraction model. This includes validating

user operations and interacting with the entry point as defined in the ERC-4337

specification.


2. Seamless Integration with Safe: The module is designed to integrate smoothly with the

existing Safe contracts without disrupting their core functionalities. It extends the

capabilities of these contracts to support new transaction types and user operation

models as introduced in ERC-4337.


3. Enhanced User Experience: By adopting the ERC-4337 standard, Safe users benefit

from an improved transaction experience. This includes features like sponsored

transactions, where transaction fees can be paid in tokens other than ETH, and more

flexible transaction structures.

### **`AddModulesLib`**


The primary function of this utility contract is to facilitate the deployment of safes with

integrated ERC-4337 support. When the <mark>`EntryPoint`</mark> contract interacts with an account that

has not yet been deployed, it is necessary to provide the required initialization data for its

deployment. The <mark>`AddModulesLib`</mark> contract plays a vital role in this context. This is because a

safe must execute a self-call to enable a module.


However, prior to executing the setup method, the safe's address remains unknown as it

depends on the setup parameters. Therefore, methods like <mark>`MultiSend`</mark> are ineffective for

establishing the correct <mark>`msg.sender`</mark> for a self-call. To address this, the initialization data

includes a call to the <mark>`enableModules`</mark> function from the <mark>`AddModulesLib`</mark> contract. This is


Safe 4337 Module Audit − System Overview − 5


executed as a post-deployment action through a delegate call, which activates the module in

the same transaction that creates the safe.

## **Security Model**


The security model of the <mark>`Safe4337Module`</mark> contract revolves around several key aspects:


1. Account Abstraction Compliance: Ensuring that the <mark>`EntryPoint`</mark> contract adheres to

the specifications and security standards of ERC-4337. Not only is it dependent on the

API of this contract, but the security of the safe module also depends on the entry point

to perform certain validation checks such as nonce replay protection. One important

thing to note is that the entry point address that the module points to is specified in the

constructor and cannot be changed later on.

2. Interaction with Safe Contracts: Verifying the security and integrity of the interactions

between the <mark>`Safe4337Module`</mark> and Safe contracts, especially in terms of permissions,

transaction execution, and state changes.

3. Module Isolation and Access Control: Ensuring that the module operates within its

designated boundaries, with strict access controls to prevent unauthorized interactions.

### **Privileged Roles**


   - Safe Owner: Each safe has an owner who has administrative privileges over it. This

owner can enable or disable modules, guards, or the fallback. Furthermore, they can

change important parameters within the safe which affects the validity of the associated

signatures. If the signatures extracted from the user operation are invalid, user

operations will not be successful.

   - Entry Point: The only entity that can trigger both the validation and execution of user

operations.


Safe 4337 Module Audit − Security Model − 6


## **Medium Severity**

### **M-01 Potential Obsolescence for** **`Safe4337Module`**

The <u><mark>`[Safe4337Module](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol)`</mark></u> contract is currently aligned with version 0.6.0 of the <u>[account](https://github.com/eth-infinitism/account-abstraction/tree/ver0.6.0)</u>

<u>[abstraction repository. However, the imminent release of version 0.7.0 could render the module](https://github.com/eth-infinitism/account-abstraction/tree/ver0.6.0)</u>

outdated upon market entry. This misalignment poses a risk of obsolescence and may impact

the module's relevance and compatibility with newer systems.


To mitigate this, it is advisable to actively monitor updates in the account abstraction

repository. In addition, establishing a communication channel with the repository developers

could facilitate timely updates to the <mark>`Safe4337Module`</mark> contract. This proactive approach

ensures synchronization with the latest developments, enhancing the module's longevity and

utility in the evolving market.


Furthermore, all the current end-to-end tests performed in the repository use a bundler from

<u>[version 0.6.1](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/docker/bundler/Dockerfile#L5)</u> along with the smart contract from version 0.6.0. Therefore, the passing of these

tests does not guarantee compatibility and correctness when using version 0.7.0 of account

abstraction, which may present breaking changes.


As such, Consider implementing end-to-end testing with the latest versions of the account

abstraction components.


**_Update:_** _Resolved in_ _<u>[pull request #245](https://github.com/safe-global/safe-modules/pull/245)</u>_ _at commit_ _<u>[2759608. The Safe team stated:](https://github.com/safe-global/safe-modules/pull/245/commits/27596088e8be0e2f37352b1fcfe6aac298dfca10)</u>_


_Implemented by adding an E2E test against the bundler from the_ _<mark>`main`</mark>_ _branch. This_

_should give a heads-up once a new version of the 4337 implementations is pushed out_

_as the reference bundler includes and deploys the_ _<mark>`EntryPoint`</mark>_ _contract it supports,_

_and the new CI test will fail if there are compatibility changes._


Safe 4337 Module Audit − Medium Severity − 7


## **Low Severity**

### **L-01 Floating Pragma**

A floating pragma (>=0.8.0 <0.9.0, which is equivalent to ^0.8.0) is being used for all the

contracts within the scope of this audit. Floating pragmas are typically suitable for public

contract libraries or contracts intended for inheritance by various projects. Its application in

other contexts might inadvertently introduce risks associated with compiling contracts against

different minor versions of the Solidity compiler, each potentially having distinct features, bug

fixes, and deprecated elements.


To mitigate these risks, consider adopting fixed pragma versions specific to the Solidity

compiler version that has been thoroughly tested and vetted for use with the ERC-4337 safe

module contracts. By pinning down the Solidity version, the codebase will benefit from

enhanced predictability and stability which is crucial for maintaining robust smart contracts.


**_Update:_** _Resolved in_ _<u>[pull request #239](https://github.com/safe-global/safe-modules/pull/239)</u>_ _at commit_ _<u>[df64c63.](https://github.com/safe-global/safe-modules/pull/239/commits/df64c63de3cb9417cb02b4ec290f01f1a40a246e)</u>_

### **L-02 Misleading Documentation in** **Safe4337Module Contract**


The <mark>`Safe4337Module`</mark> contract contains instances of misleading documentation that could

potentially lead to confusion about the code's functionality and intent. Primarily, the immutable

variable <u><mark>`[SUPPORTED_ENTRYPOINT](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L74)`</mark></u> is currently <u>[described inaccurately in its docstring](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L71-L73)</u> as an

EIP-712 type-hash, whereas it actually represents the address of the <mark>`EntryPoint`</mark> contract.


In addition, similar discrepancies are present elsewhere in the codebase. For instance, <u>[line 99](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L99)</u>

<u>of</u> <u><mark>`[Safe4337Module](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L99)`</mark></u> erroneously states that the entry point address is appended to the

calldata within the <mark>`HandlerContext`</mark> contract. The correct implementation, however, is

observed in the <u><mark>`[FallbackManager](https://github.com/safe-global/safe-contracts/blob/main/contracts/base/FallbackManager.sol#L75)`</mark></u> where this operation actually occurs.


Consider fixing the identified documentation issues and conducting a thorough review of the

entire codebase to rectify any other documentation inaccuracies.


**_Update:_** _Resolved in_ _<u>[pull request #240](https://github.com/safe-global/safe-modules/pull/240)</u>_ _at commit_ _<u>[cd14438.](https://github.com/safe-global/safe-modules/pull/240/commits/cd14438178484e51b4637216d5e1dc5836ec1a61)</u>_


Safe 4337 Module Audit − Low Severity − 8


### **L-03 Missing Docstrings**

The <u><mark>`[AddModulesLib.sol](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/AddModulesLib.sol)`</mark></u> contract lacks essential docstrings for the <mark>`enableModules`</mark>

function on <u>[line 8.](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/AddModulesLib.sol#L8)</u>


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not <mark>`public`</mark>,

should be clearly documented as well. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #241](https://github.com/safe-global/safe-modules/pull/241)</u>_ _at commit_ _<u>[dd4a6b7.](https://github.com/safe-global/safe-modules/pull/241/commits/dd4a6b734c63895c2c2fabb3b1199efe4d1b08e5)</u>_

## **Notes & Additional** **Information**

### **N-01 Inefficiency in enableModules Function Due** **to Reverse Loop Operation**


The <mark>`AddModulesLib`</mark> contract's <u><mark>`[enableModules](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/AddModulesLib.sol#L8)`</mark></u> function implements a reverse loop for

iterating over an array of module addresses. Using a reverse loop, especially with large arrays,

could lead to higher gas costs as it involves more operations, as `i` is decremented in each

iteration. The current implementation lacks clarity regarding the choice of reverse iteration as

no justification is provided in the code or its documentation.


To enhance code clarity and efficiency, it is recommended to document the rationale behind

opting for reverse iteration. If the choice of reverse iteration is arbitrary, refactoring the loop to a

forward iteration is advisable to optimize gas usage, particularly in cases where numerous

modules are going to be enabled. In this scenario, it would be advised to store

<mark>`modules.length`</mark> in a temporary variable outside of the loop to prevent redundant

calculation.


**_Update:_** _Resolved in_ _<u>[pull request #241](https://github.com/safe-global/safe-modules/pull/241)</u>_ _at commit_ _<u>[9ea1a34.](https://github.com/safe-global/safe-modules/pull/241/commits/9ea1a34c3671092403c0d5880019139e50b986af)</u>_


Safe 4337 Module Audit − Notes & Additional Information − 9


### **N-02 Misleading Contract Name**

The <u><mark>`[AddModuleLib](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/AddModulesLib.sol)`</mark></u> contract has a misleading name as it is a contract and not a library.

Furthermore, the name gives a reader the impression that it is through this contract that all

modules are enabled within the Safe system. However, this is not the typical flow as to how

modules are generally enabled, but rather only for a specific scenario when the account that

the <mark>`EntryPoint`</mark> should interact with is not deployed yet.


To provide clarity, consider renaming both the file and the contract to names that are more

descriptive of the scenario in which this contract is used.


**_Update:_** _Resolved in_ _<u>[pull request #241](https://github.com/safe-global/safe-modules/pull/241)</u>_ _at commit_ _<u>[942f2aa.](https://github.com/safe-global/safe-modules/pull/241/commits/942f2aad4451d7bbdfd094944ed90f03da28d309)</u>_

### **N-03 Inefficient Modifier Usage Leading to** **Increased Bytecode Size**


The <u><mark>`[onlySupportedEntryPoint](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L84)`</mark></u> modifier includes a <mark>`require`</mark> statement that verifies

whether the value returned by <mark>`_msgSender()`</mark> matches <mark>`SUPPORTED_ENTRYPOINT`</mark> <mark>.</mark> This

approach, while functionally correct, has an unintended consequence on the contract's

bytecode size. During the compilation, modifiers are replicated wherever they are used. Given

that <mark>`onlySupportedEntryPoint`</mark> is utilized in three distinct instances within the contract,

this replication results in a noticeable increase in the overall bytecode size.


To optimize bytecode size and enhance contract efficiency, it is advisable to encapsulate the

<mark>`require`</mark> statement in an internal function, and then invoke that function inside the modifier.

This modification ensures that, instead of being duplicated, the logic for entry point validation

is defined once and called multiple times.


**_Update:_** _Acknowledged, not resolved. The Safe team is expecting thousands of calls to this_

_module which would actually make the suggestion cost more gas. The Safe team stated:_


_Seeing as this module is to be shared across all Safes, we believe that an increase in the_

_one-time deployment cost is the correct trade-off to allow for gas savings in the_

_commonly used functions._

### **N-04 Lack of Security Contact**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability


Safe 4337 Module Audit − Notes & Additional Information − 10


in the code. This practice is quite beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so.


In addition, if the contract incorporates third-party libraries and a bug surfaces in those, it

becomes easier for the maintainers of those libraries to contact the appropriate person about

the problem and provide mitigation instructions. Throughout the <u>[codebase, there are contracts](https://github.com/safe-global/safe-modules/tree/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts)</u>

that do not have a security contact:


   - The <u><mark>`[AddModulesLib](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/AddModulesLib.sol)`</mark></u> contract

   - The <u><mark>`[Safe4337Module](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol)`</mark></u> contract


Consider adding a NatSpec comment containing a security contact above the contract

definitions. Using the <mark>`@custom:security-contact`</mark> convention is recommended as it has

been adopted by the <u>[OpenZeppelin Wizard](https://wizard.openzeppelin.com/)</u> and the <u>[ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)</u>


**_Update:_** _Resolved in_ _<u>[pull request #244](https://github.com/safe-global/safe-modules/pull/244)</u>_ _at commit_ _<u>[d6d057f](https://github.com/safe-global/safe-modules/pull/244/commits/d6d057f3e4283ecaf61281c2738b963844ec156f)</u>_ _and in_ _<u>[pull request #241](https://github.com/safe-global/safe-modules/pull/241)</u>_ _at commit_

_<u>[dd4a6b7.](https://github.com/safe-global/safe-modules/pull/241/commits/dd4a6b734c63895c2c2fabb3b1199efe4d1b08e5)</u>_

### **N-05 Use Custom Errors**


Since Solidity version 0.8.4, custom errors provide a cleaner and more cost-efficient way to

explain to users why an operation failed. Multiple instances of <mark>`require`</mark> statements were

found within <u><mark>`[Safe4337Module.sol](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol)`</mark></u> <mark>:</mark>


   - The <u><mark>`[require](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L77)`</mark></u> statement with the message "Invalid entry point"

   - The <u><mark>`[require](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L85)`</mark></u> statement with the message "Unsupported entry point"

   - The <u><mark>`[require](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L102)`</mark></u> statement with the message "Invalid caller"

   - The <u><mark>`[require](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L106-L109)`</mark></u> statement with the message "Unsupported execution function id"

   - The <u><mark>`[require](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L131)`</mark></u> statement with the message "Execution failed"


For conciseness and gas savings, consider replacing <mark>`require`</mark> statements with custom

errors.


**_Update:_** _Acknowledged, not resolved. The Safe team stated:_


_The suggestion to use custom error codes instead of revert messages was implemented_

_for the Safe 4337 module contract. This had a positive impact on the code size of the_

_[contracts. However, the 4337 entry point contract v0.6.0 has special support for revert](https://github.com/eth-infinitism/account-abstraction/blob/abff2aca61a8f0934e533d0d352978055fddbd96/contracts/core/EntryPoint.sol#L410-L417)_

_strings. As such, we do not believe this to be a positive change in the context that the_

_4337 module is designed to work for the v0.6.0 contracts. In particular, we believe that_


Safe 4337 Module Audit − Notes & Additional Information − 11


_prioritizing debuggability is more important than contract code size improvements or_

_potential gas savings in the error paths. With that in mind, we have decided to not_

_include this change for the module supporting the v0.6.0 version of the entry point_

_contract. We acknowledge the issue and will implement the change once the contracts_

_are upgraded to support the v0.7.0 module which no longer has special support for_

_handling revert strings._

### **N-06 Inconsistent Use of Named Returns**


The <mark>`Safe4337Module`</mark> contract exhibits inconsistent return styles: while most functions use

named returns, the <u><mark>`[domainSeparator()](https://github.com/safe-global/safe-modules/blob/3853f34f31837e0a0aee47a4452564278f8c62ba/modules/4337/contracts/Safe4337Module.sol#L155)`</mark></u> function does not.


Consider using named returns for all functions in a contract for consistency.


**_Update:_** _Resolved in_ _<u>[pull request #242](https://github.com/safe-global/safe-modules/pull/242)</u>_ _at commit_ _<u>[b2ff724.](https://github.com/safe-global/safe-modules/pull/242/commits/b2ff7241b2806d827e73f9922ffa56247ad5d5e2)</u>_


Safe 4337 Module Audit − Notes & Additional Information − 12


## **Conclusion**

This new module for the Safe contract acts as an extension that implements the ERC-4337

interface for an account and complies with the standard. It validates the user operation,

executes a module transaction to pay the required prefund, and executes another module

transaction to complete the user operation.


Only one medium severity issue was found during the audit and we found the code quality to

be good. While the test suite present was robust with 100% coverage, end-to-end testing, and

even formal verification through Certora, all tests were run with respect to account abstraction

version 0.6.0. As such, we recommend extending this approach to test against the most recent

version of account abstraction in order to remain compliant with any possible breaking

changes. Throughout the audit period, the Safe team was helpful and responsive in answering

our questions.


Safe 4337 Module Audit − Conclusion − 13


