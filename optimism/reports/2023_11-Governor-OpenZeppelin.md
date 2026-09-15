### | security

# **Agora Optimism** **Governance** **Audit**

#### **November 22, 2023**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  6


Security Model & Trust Assumptions _________________________________________________  6

Privileged Roles 6

Trust Assumptions 7


Medium Severity ___________________________________________________________________  8

M-01 Incorrect Implementation of EIP-712 8


Low Severity ______________________________________________________________________  8

L-01 Floating Pragma 8

L-02 Missing Docstrings 9

L-03 Missing Signature Validation Checks 9

L-04 Lack of Safety Check for _voteSucceeded Function 10

L-05 Missing quorum Parameter Validation 10


Notes & Additional Information ____________________________________________________ 10

N-01 Missing Zero-Address Checks 10

N-02 Inconsistent Use of Named Returns 11

N-03 Lack of Indexed Event Parameters 11

N-04 Lack of Security Contact 11

N-05 Unused Error 12

N-06 Unused Event 12

N-07 Unused Named Return Variables 13

N-08 Use of Modified OpenZeppelin Contracts 13

N-09 Use Custom Errors 13

N-10 Constants Not Using UPPER_CASE Format 14

N-11 TODO Comments 14

N-12 State Variable Visibility Not Explicitly Declared 15

N-13 Usage of Magic Numbers 15

N-14 Use of Deprecated OpenZeppelin's Timers Library 15

N-15 Missing Named Parameters in Mapping 16

N-16 Code Is Not Consistent With Solidity Style Guide 16

N-17 Unused State Variable 17

N-18 Lack of gap storage variables for upgradable contracts 17

N-19 Function could fail early 17


Agora Optimism Governance Audit − Table of Contents − 2


N-20 Missing Initialization of Base Contracts 18

N-21 Confusing Use of VotableSupplyUpdated Event 18


Conclusion  ______________________________________________________________________ 19


Agora Optimism Governance Audit − Table of Contents − 3


## **Summary**

Type DeFi


Timeline From 2023-10-16
To 2023-10-23


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



Total Issues 27 (17 resolved, 1 partially resolved)



Low Severity Issues 5 (4 resolved)



Notes & Additional
Information



21 (12 resolved, 1 partially resolved)



Agora Optimism Governance Audit − Summary − 4


## **Scope**

We audited the <u>Agora Optimism Governance V6</u> repository at the <u>a22052d</u> commit.


In scope were the following contracts:

```
src
├── OptimismGovernorV6.sol
├── ProposalTypesConfigurator.sol
├── VotableSupplyOracle.sol
└── alligator
└── AlligatorOP_V5.sol

```

Agora Optimism Governance Audit − Scope − 5


## **System Overview**

The Agora Optimism Governance V6 protocol has undergone a series of significant updates,

broadening its capabilities and enhancing its utility. Among these developments, it has

incorporated support for external voting modules and partial voting through Alligator.

Additionally, a votable supply oracle has been added, offering valuable insights into supply

dynamics for more informed governance decisions. The protocol now accommodates various

proposal types, ensuring adaptability to a wide range of scenarios. The integration of the liquid

delegation protocol, `Alligator V5`, enhances delegation capabilities. The

`ProposalTypesConfigurator` empowers the `OptimismGovernorV6` manager to

customize proposal types, and the `VotableSupplyOracle` allows the contract owner to

efficiently manage the votable supply used by the `OptimismGovernorV6` .

## **Security Model & Trust** **Assumptions**

### **Privileged Roles**


The protocol implements multiple privileged roles. The following list has been limited only to

the roles and actions that can be executed within the contracts in scope.


The `manager` role of `OptimismGovernorV6` can:


   - Create proposals.

   - Edit proposal type.

   - Set proposal type via `ProposalTypesConfigurator` contract.


The `owner` of `Alligator_V5` contract can:


   - Upgrade the implementation contract.

   - Pause the contract.


Agora Optimism Governance Audit − System Overview − 6


The `owner` of `VotableSupplyOracle` contract can:


   - Update votable supply at any block

### **Trust Assumptions**


   - The logic of `OptimismGovernorV6` relies on the out-of-scope

`OptimismGovernorV5` contract and a set of modified OpenZeppelin contracts. Thus,

it is assumed that the mentioned contracts are secure and behave according to their

specifications.

   - The holders of the privileged roles `manager` and `owner` are expected to be non
malicious, and act in the protocol's best interest.


Agora Optimism Governance Audit − Security Model & Trust Assumptions −

7


## **Medium Severity**

### **M-01 Incorrect Implementation of EIP-712**

The <u>`AlligatorOP_V5`</u> contract incorrectly implements EIP-712. The <u>`BALLOT_TYPEHASH`</u>

does not include parameters that are used in the hashing of multiple parameters in

<u>`castVoteBySig`</u>, <u>`castVoteWithReasonAndParamsBySig`</u> and

<u>`limitedCastVoteWithReasonAndParamsBatchedBySig`</u> .


This can lead to an exploitation path by reusing the same signature for

`castVoteWithReasonAndParamsBySig` and passing parameters that concatenated

together will result in the same bytes data that is expected to be hashed. The

`MAX_VOTING_POWER` value of `0x5` will be interpreted in

`castVoteWithReasonAndParamsBySig` as a length of the `authority` array.


Since there are three completely different methods to cast a vote there should be three

different typehashes used, which include the relevant parameters that are being used for

creating a hash.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>4229289.</u>_

## **Low Severity**

### **L-01 Floating Pragma**


Pragma directives should be fixed to clearly identify the Solidity version with which the

contracts will be compiled.


Throughout the <u>codebase, there are multiple floating pragma directives. For instance:</u>


   - The <u>`AlligatorOP_V5.sol`</u> file has the <u>`solidity ^0.8.19`</u> floating pragma

directive.

   - The <u>`OptimismGovernorV6.sol`</u> file has the <u>`solidity ^0.8.19`</u> floating pragma

directive.


Agora Optimism Governance Audit − Medium Severity − 8


   - The <u>`ProposalTypesConfigurator.sol`</u> file has the <u>`solidity ^0.8.19`</u> floating

pragma directive.

   - The <u>`VotableSupplyOracle.sol`</u> file has the <u>`solidity ^0.8.19`</u> floating pragma

directive.


Consider using a fixed pragma version throughout the codebase.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>0b40e39.</u>_

### **L-02 Missing Docstrings**


Throughout the <u>codebase, there are several parts that do not have docstrings. For instance:</u>


   - <u>Events, constant values</u> and the <u>`initialize`</u> function in the <u>`AlligatorOP_V5`</u>

contract

   - <u>Events, constant values</u> and the <u>`propose`</u>, <u>`proposeWithModule`</u>, and <u>`hasVoted`</u>,

<u>`COUNTING_MODE`</u> functions in the <u>`OptimismGovernorV6`</u> contract

   - The <u>`proposalTypes`</u> function in the <u>`ProposalTypesConfigurator`</u> contract

   - The <u>`_updateVotableSupply`</u> and <u>`_updateVotableSupplyAt`</u> functions in the

<u>`VotableSupplyOracle`</u> contract


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not public, should

be clearly documented as well. When writing docstrings, consider following the <u>Ethereum</u>

<u>Natural Specification Format</u> (NatSpec).


**_Update:_** _Acknowledged, will resolve. The Agora team stated:_


_Docstrings will be updated in the future before deployment._

### **L-03 Missing Signature Validation Checks**


The <u>`AlligatorOP_V5`</u> contract allows casting votes by using signatures. The signatures are

validated using the `ecrecover` function but are missing essential security checks such as

those against signature malleability.


Consider using <u>OpenZeppelin's ECDSA library</u> to validate signatures.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>383292a.</u>_


Agora Optimism Governance Audit − Low Severity − 9


### **L-04 Lack of Safety Check for _voteSucceeded** **Function**

Within the `OptimismGovernorV6.sol` contract, the `_voteSucceeded()` function does

not check `totalVotes != 0` before <u>using it as a denominator. This edge case could</u>

happen if a proposal only has `abstainVotes` .


Consider adding this check to the `_voteSucceeded()` function.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>acba358.</u>_

### **L-05 Missing quorum Parameter Validation**


The <u>`ProposalTypesConfigurator`</u> contract allows setting proposal types through the

<u>`setProposalType`</u> function. The <u>value of</u> <u>`quorum`</u> <u>is validated</u> to not exceed `10000`, which

is considered `100%` .


However, this process does not check for non-zero values. The `OptimismGovernorV6`

contract relies on the fact that the correct proposal type has the value of `quorum` not equal to

`0` . This is checked in the <u>`propose`</u>, <u>`proposeWithModule`</u> and <u>`editProposalType`</u>

functions.


Consider adding a non-zero check to the value of `quorum` .


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commits_ _<u>1507cf3</u>_ _and_ _<u>bd69f93.</u>_

## **Notes & Additional** **Information**

### **N-01 Missing Zero-Address Checks**


Multiple contracts are missing zero-address checks for setting storage variables. Accidentally

setting storage variable to address zero result in an incorrect configuration of the protocol.


   - Missing check in the <u>`constructor`</u> of the <u>`ProposalTypesConfigurator`</u> contract

for `governor.manager()` to ensure the <u>`onlyManager`</u> modifier works correctly.


Agora Optimism Governance Audit − Notes & Additional Information − 10


   - Missing check in <u>`initialize`</u> within the <u>`AlligatorOPV5`</u> contract for the

`_initOwner` address parameter.

   - Missing check in the <u>`constructor`</u> of the <u>`VotableSupplyOracle`</u> contract for the

`_initOwner` address parameter.


Consider adding zero-address checks to the listed parameters.


**_Update:_** _Acknowledged, not resolved. The Agora team stated:_


_We will not be adding zero-address checks to constructors and initializers._

### **N-02 Inconsistent Use of Named Returns**


To improve the readability of the contract, use the same return style in all of its functions. The

<u>`AlligatorOPV5`</u> contract has an inconsistent usage of named returns within its functions.


Consider naming all return values of all functions.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>b137b4d.</u>_

### **N-03 Lack of Indexed Event Parameters**


Throughout the <u>codebase, several events do not have their parameters indexed. For instance:</u>


   - The <u>`ProposalCreated`</u> event of <u>`OptimismGovernorV6.sol`</u>

   - The <u>`ProposalCreated`</u> event of <u>`OptimismGovernorV6.sol`</u>

   - The <u>`ProposalTypeUpdated`</u> event of <u>`OptimismGovernorV6.sol`</u>


Consider <u>indexing event parameters</u> to improve the ability of off-chain services to search and

filter for specific events.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>bb82801.</u>_

### **N-04 Lack of Security Contact**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability

in the code. This practice proves beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so. Additionally, if the contract


Agora Optimism Governance Audit − Notes & Additional Information − 11


incorporates third-party libraries and a bug surfaces in these, it becomes easier for the

maintainers of those libraries to make contact with the appropriate person about the problem

and provide mitigation instructions.


Throughout the <u>codebase, there are several contracts that do not have a security contact. For</u>

instance:


   - The <u>`AlligatorOPV5`</u> contract

   - The <u>`OptimismGovernorV6`</u> contract

   - The <u>`ProposalTypesConfigurator`</u> contract

   - The <u>`VotableSupplyOracle`</u> contract


Consider adding a NatSpec comment containing a security contact on top of the contracts

definition. Using the `@custom:security-contact` convention is recommended as it has

been adopted by the <u>OpenZeppelin Wizard</u> and the <u>ethereum-lists.</u>


**_Update:_** _Acknowledged, not resolved. The Agora team stated:_


_We may consider adding this in the future._

### **N-05 Unused Error**


In <u>`AlligatorOP_V5.sol`</u>, the <u>`ProxyNotExistent`</u> error is unused.


To improve the overall clarity, intentionality, and readability of the codebase, consider either

using or removing any currently unused errors.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>bc48b7e.</u>_

### **N-06 Unused Event**


In <u>`AlligatorOP_V5.sol`</u>, the <u>`ProxyDeployed`</u> event is unused.


To improve the overall clarity, intentionality, and readability of the codebase, consider emitting

or removing any currently unused events.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>bc48b7e.</u>_


Agora Optimism Governance Audit − Notes & Additional Information − 12


### **N-07 Unused Named Return Variables**

Named return variables are a way to declare variables that are meant to be used within a

function's body for the purpose of being returned as the function's output. They are an

alternative to explicit in-line `return` statements.


Throughout the <u>`AlligatorOP_V5`</u> contract, there are multiple instances of unused named

return variables. For instance:


   - The <u>`endBlock`</u> return variable in the `_proposalEndBlock` function.

   - The <u>`snapshotBlock`</u> return variable in the `_proposalSnapshot` function.

   - The <u>`weightCast`</u> return variable in the `_weightCast` function.


Consider either using or removing any unused named return variables.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>b137b4d.</u>_

### **N-08 Use of Modified OpenZeppelin Contracts**


The protocol currently utilizes a modified version of OpenZeppelin's governance contracts,

which is considered an anti-pattern and not the intended way of using OpenZeppelin's

contracts.


It is advisable to import the original OpenZeppelin contracts and override the necessary

functions to align them with the protocol's specific requirements.


**_Update:_** _Acknowledged, not resolved. The Agora team stated:_


_We had to use a modified version to edit the storage layout._

### **N-09 Use Custom Errors**


Since solidity version `0.8.4`, custom errors provide a cleaner and more cost-efficient way to

explain to users why an operation failed.


There were instances of `require` and/or `revert` with error messages rather than custom

errors in these files:







```
OptimismGovernorV6.sol
ProposalTypesConfigurator.sol

```

Agora Optimism Governance Audit − Notes & Additional Information − 13


For conciseness and gas savings, consider replacing `require` and `revert` messages with

custom errors.


**_Update:_** _Partially resolved. The Agora team stated:_


_Left the_ _`require`_ _statements in_ _`OptimismGovernorV6`_ _for now to minimize changes_

_from the inherited governor._

### **N-10 Constants Not Using UPPER_CASE Format**


Throughout the <u>codebase, there are constants not using</u> `UPPER_CASE` format. For instance:


   - The `governor` constant declared on <u>line 62</u> in <u>`AlligatorOP_V5.sol`</u>

   - The `op` constant declared on <u>line 64</u> in <u>`AlligatorOP_V5.sol`</u>

   - The `alligator` constant declared on <u>line 74</u> in <u>`OptimismGovernorV6.sol`</u>

   - The `votableSupplyOracle` constant declared on <u>line 77</u> in
```
   OptimismGovernorV6.sol
```

   - The `proposalTypesConfigurator` constant declared on <u>line 81</u> in
```
   OptimismGovernorV6.sol
```

   - The `governor` constant declared on <u>line 15</u> in <u>`ProposalTypesConfigurator.sol`</u>


According to the <u>Solidity Style Guide, constants should be named with all capital letters with</u>

underscores separating words. For better readability, consider following this convention.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>d3b7230.</u>_

### **N-11 TODO Comments**


During development, having well described TODO/Fixme comments will make the process of

tracking and solving them easier. Without this information these comments might age and

important information for the security of the system might be forgotten by the time it is

released to production. These comments should be tracked in the project's issue backlog and

resolved before the system's deployment.


Multiplies instances of TODO/Fixme comments were identified in the <u>codebase. For instance:</u>


   - The `TODO` comment on <u>line 73</u> in <u>`OptimismGovernorV6.sol`</u> .

   - The `TODO` comment on <u>line 76</u> in <u>`OptimismGovernorV6.sol`</u> .

   - The `TODO` comment on <u>line 80</u> in <u>`OptimismGovernorV6.sol`</u> .


Agora Optimism Governance Audit − Notes & Additional Information − 14


Consider removing all instances of TODO/Fixme comments and tracking them in the issues

backlog instead. Alternatively, consider linking each inline TODO/Fixme comment to the

corresponding issues backlog entry.


**_Update:_** _Acknowledged, not resolved. The Agora team stated:_


_We will not fix these for now._

### **N-12 State Variable Visibility Not Explicitly** **Declared**


Within <u>`ProposalTypesConfigurator.sol`</u>, the state variable <u>`governor`</u> lacks an

explicitly declared visibility.


For clarity, consider always explicitly declaring the visibility of variables, even when the default

visibility matches the intended visibility.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>f07004c.</u>_

### **N-13 Usage of Magic Numbers**


Throughout the <u>codebase, there are occurrences of literal values with unexplained meaning.</u>


   - Consider adding `PERCENT_DIVISOR = 10_000;` constant instead of <u>using number</u>

<u>`10000`</u> in <u>`ProposalTypesConfigurator`</u> contract.

   - Consider adding `PERCENT_DIVISOR = 10_000;` constant and use it in <u>`quorum`</u> and

<u>`_voteSucceeded`</u> functions in <u>`OptimismGovernorV6`</u> contract.


To improve the code’s readability and facilitate refactoring, consider defining a constant for

every magic number, giving it a clear and self-explanatory name. For complex values, consider

adding an inline comment explaining how they were calculated or why they were chosen.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>9b58c4c.</u>_

### **N-14 Use of Deprecated OpenZeppelin's Timers** **Library**


The `OptimismGovernorV6` contract uses OpenZeppelin's `Timers` library which has been

<u>deprecated as of OpenZeppelin version</u> <u>`4.9.0`</u> and has been removed in `5.0.0` .


Agora Optimism Governance Audit − Notes & Additional Information − 15


Consider switching to another solution.


**_Update:_** _Acknowledged, will resolve. The Agora team stated:_


_We will change it once we upgrade the OpenZeppelin versions to v5, in the future._

### **N-15 Missing Named Parameters in Mapping**


Since <u>Solidity 0.8.18, developers can utilize named parameters in mappings. This means</u>

mappings can take the form of `mapping(KeyType KeyName? => ValueType`

`ValueName?)` . This updated syntax provides a more transparent representation of the

mapping's purpose.


Following mappings have been identified that would benefit from named parameters:








<u>`_proposalTypes`</u> in the <u>`ProposalTypesConfigurator.sol`</u> contract.

<u>`weightCast`</u> in the <u>`OptimismGovernorV6.sol`</u> contract.




   - Final value of <u>`votesCast`</u> in the <u>`AlligatorOP_V5.sol`</u> contract.


Consider adding named parameters to the listed mappings to improve readability and

maintainability of the code.


**_Update:_** _Acknowledged, not resolved. The Agora team stated:_


_`weightCast`_ _already has all named parameters. The other two mentioned functions_

_only have the last parameter missing, which is intended here._

### **N-16 Code Is Not Consistent With Solidity Style** **Guide**


There are several occurrences where the <u>Solidity style guide</u> is not followed, which makes the

code more error-prone and difficult to read.


   - Function <u>`_updateVotableSupply`</u> of <u>`VotableSupplyOracle`</u> contract is external

and its name should not start with an underscore.

   - Function <u>`_updateVotableSupplyAt`</u> of <u>`VotableSupplyOracle`</u> contract is

external and its name should not start with an underscore.

   - Function <u>`_togglePause`</u> of <u>`AlligatorOP_V5`</u> contract is external and its name

should not start with an underscore.


Agora Optimism Governance Audit − Notes & Additional Information − 16


To increase overall code readability, it is recommended to follow Solidity style guide across the

entire codebase.


**_Update:_** _Acknowledged, not resolved. The Agora team stated:_


_Will not fix, the underscore here is used to signal that only the manager can call the_

_methods._

### **N-17 Unused State Variable**


Within the <u>`OptimismGovernorV6`</u> <u>contract, the</u> `MAX_VOTE_TYPE` state variable is unused.


To improve the overall clarity, intentionality, and readability of the codebase, consider removing

any unused state variable.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>698f5f6.</u>_

### **N-18 Lack of gap storage variables for** **upgradable contracts**


The upgradeable <u>`AlligatorOPV5`</u> <u>contract</u> do not have a `__gap` variable. The `__gap`

storage variable is used to allow for additional storage variables to be safely added when using

inheritance, without it could cause future storage collision when new storage variables are

introduced.


Similar issue is also identified in the <u>`OptimismGovernorV5`</u> <u>contract</u> and

<u>`OptimismGovernorV6`</u> <u>contract</u>


Note current implementation will work fine as a versioned upgrade solution. If this is the

intended behavior, consider documenting it in the codebase to avoid accidental storage

collision in the future. Otherwise consider adding storage gaps to these contracts.


**_Update:_** _Acknowledged, not resolved. The Agora team stated:_


_This is an intended behavior._

### **N-19 Function could fail early**


Function `propose` in contract `OptimismGovernorV6.sol` validates input parameters from

<u>line184</u> after <u>hashing the</u> <u>`proposalId`</u> <u>in line 182.</u>


Agora Optimism Governance Audit − Notes & Additional Information − 17


In order to fail early and save gas, consider validating input parameters first.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>03ce194.</u>_

### **N-20 Missing Initialization of Base Contracts**


The <u>AlligatorOP_V5</u> contract is an upgradeable contract that inherits OpenZeppelin's

`UUPSUpgradeable`, `OwnableUpgradeable` and `PausableUpgradeable` contracts. The

issue is that within the <u>`initialize`</u> only `PausableUpgradeable` contract is initialized

while `UUPSUpgradeable` and `OwnableUpgradeable` are not.


Consider initializing all the inherited upgradeable contracts `UPPSUpgradeable` and

`OwnableUpgradeable` to enhance readability and clarity of the code.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>4ea0462.</u>_

### **N-21 Confusing Use of VotableSupplyUpdated** **Event**


The <u>`VotableSupplyOracle`</u> contract emits `VotableSupplyUpdated` in case the votable

supply has changed. The parameters of <u>`VotableSupplyUpdated`</u> are `blockNumber`,

`oldVotableSupply`, `newVotableSupply` .


The issue is that in case a new checkpoint is being added either in <u>`constructor`</u> or via

<u>`_updateVotableSupply`</u> the `oldVotableSupply` represents the `votableSupply` of the

last checkpoint but for <u>`_updateVotableSupplyAt`</u> it represents the supply of the updated

checkpoint. This might lead to confusion for off-chain application since its difficult to

distinguish what `oldVotableSupply` parameter represents in given time.


Consider adding new event and emit it in `_updateVotableSupplyAt` function.


**_Update:_** _Resolved in_ _<u>pull request #16</u>_ _at commit_ _<u>7bd01b6.</u>_


Agora Optimism Governance Audit − Notes & Additional Information − 18


## **Conclusion**

The codebase is quite complex due to multiple inheritances and upgrades of the protocol. It

will benefit from incorporating our informational notes and lower-severity recommendations in

order to improve its readability and robustness. It is recommended to generate more technical

documentation about the Governance V6 and Alligator V5 contracts' integration.


Agora Optimism Governance Audit − Conclusion − 19


