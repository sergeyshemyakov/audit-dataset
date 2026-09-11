### | security

# **Contracts 4.9** **Release Audit**

#### **May 9, 2023**

This security assessment was prepared by
**OpenZeppelin** .


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  7

Governance contracts 7

Access control contracts 8


Security Model and Trust Assumptions _______________________________________________  9


Client-Reported Issues _____________________________________________________________  9


Medium Severity _________________________________________________________________ 11

M-01 Calldata Is Lost Without Signatures 11

M-02 Potential Selector Collision When Restricting the receive Function 11

M-03 Potentially Incorrect Accounting of Voting Units When Overriding ERC721Votes' _getVotingUnits Function's

Formula 12


Low Severity ____________________________________________________________________ 14

L-01 Incomplete Documentation 14

L-02 Non-existent Groups Can Be Granted Access to Permissioned Functions 14

L-03 Missing Error Messages in require Statements 15


Contracts 4.9 Release Audit − Table of Contents − 2


Notes & Additional Information ____________________________________________________ 15

N-01 Misleading Comments 15

N-02 Unused Function 16

N-03 Function Visibility Can Be Restricted 16

N-04 Unclear Code 16

N-05 State Variable Visibility Not Explicitly Declared 17

N-06 Function Visibility Can Be Public 17

N-07 Inconsistent SafeCast Usage 17

N-08 Interface and Implementation Mismatch 18

N-09 "Last updated" and "Available since" Comments Unchanged or Missing 18

N-10 Latest Governance Interface Is Unsupported 19

N-11 Missing Event Parameters 19

N-12 Naming Issues Hinder Code Understanding and Readability 20

N-13 Impossible to Get an Account's Latest Votes Through the GovernorVotes Contract 20

N-14 Overlapping TimelockController Statuses 21

N-15 Require Statements With Multiple Conditions 21

N-16 Typographical Errors 22

N-17 Unclear Proposal State 22

N-18 Lack of Indexed Parameter in Event 22

N-19 Unused Imports 23

N-20 Unused Named Return Variables 23


Conclusions  _____________________________________________________________________ 25


Contracts 4.9 Release Audit − Table of Contents − 3


## **Summary**

**Type** Library


**Timeline** From 2023-03-10
To 2023-05-03


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


3 (2 resolved)



**Total Issues** 26 (18 resolved, 1 partially resolved)



**Low Severity Issues** 3 (3 resolved)



**Notes & Additional**
**Information**



20 (13 resolved, 1 partially resolved)



Contracts 4.9 Release Audit − Summary − 4


## **Scope**

We audited the OpenZeppelin/openzeppelin-contracts repository at two commits: 
<u>`[fa112be6826debe8848223888b3d23746a6ede8f](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/fa112be6826debe8848223888b3d23746a6ede8f)`</u> commit for the contracts under the

`access` subfolder - <u>`[ca822213f2275a14c26167bd387ac3522da67fe9](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/ca822213f2275a14c26167bd387ac3522da67fe9)`</u> commit for all of

the other contracts


The <u>`[7f5e91062e10fe7f715eab7e46154e5d445add78](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/7f5e91062e10fe7f715eab7e46154e5d445add78)`</u> commit, featured in this report, is a

merge of the two commits mentioned above.


In scope were the following contracts:

```
contracts
├── utils
│  └── StorageSlot.sol
├── governance
│  ├── compatibility
│  │  ├── GovernorCompatibilityBravo.sol
│  │  └── IGovernorCompatibilityBravo.sol
│  ├── extensions
│  │  ├── GovernorPreventLateQuorum.sol!
│  │  ├── GovernorTimelockCompound.sol
│  │  ├── GovernorVotesComp.sol
│  │  ├── GovernorVotesQuorumFraction.sol
│  │  └── GovernorVotes.sol
│  ├── Governor.sol
│  ├── IGovernor.sol
│  ├── TimelockController.sol
│  └── utils
│    ├── IVotes.sol
│    └── Votes.sol
├── token
│  ├── ERC20
│  │  ├── extensions
│  │  │  ├── ERC20Votes.sol
│  │  │  ├── ERC4626.sol
│  └── ERC721
│    └── extensions
│     └─── ERC721Votes.sol
└── access
├── AccessControlDefaultAdminRules.sol
├── IAccessControlDefaultAdminRules.sol
└── manager
├── AccessManaged.sol
├── AccessManagerAdapter.sol
├── AccessManager.sol
└── IAuthority.sol

```

Contracts 4.9 Release Audit − Scope − 5


Additionally, the following contracts were audited at the

<u>[91df66c4a9dfd0425ff923cbeb3a20155f1355ea](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/91df66c4a9dfd0425ff923cbeb3a20155f1355ea)</u> commit:

```
contracts
├── proxy
│  └── transparent
│    └── TransparentUpgradeableProxy.sol
├── token
│  └── ERC721
│    └── extensions
│      └── ERC721Wrapper.sol
└── utils
├── ShortStrings.sol
├── Strings.sol
└── cryptography
└── EIP712.sol

```

and the following contracts were audited at the <u>[91df66c4a9dfd0425ff923cbeb3a20155f1355ea](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/91df66c4a9dfd0425ff923cbeb3a20155f1355ea)</u>

commit but only the changes between the versions 4.8 and 4.9 were in-scope:

```
contracts
├── token
│  ├── ERC20
│  │  └── utils
│  │    └── SafeERC20.sol
│  └── ERC721
│    └── extensions
│      └── ERC721URIStorage.sol
└── utils
├── Checkpoints.sol
└── cryptography
├── ECDSA.sol
└── SignatureChecker.sol

```

Contracts 4.9 Release Audit − Scope − 6


## **System Overview**

The OpenZeppelin contracts team asked us to review two different parts of their libraries, the

governance and access contracts.

### **Governance contracts**


These contracts are designed to manage the decision-making processes of organizations such

as DAOs. These contracts allow token holders to propose and vote on changes to the system,

such as modifying the protocol, changing the governance rules, or allocating funds.


    - _GovernorCompatibilityBravo:_ designed to be used as a governance contract that can be

used to replace an existing governance contract with minimal disruption to the existing

system. It is designed to be compatible with the Bravo protocol, and it allows token

holders to propose and vote on changes to the system.

    - _GovernorPreventLateQuorum:_ designed to prevent proposals from being passed too

shortly before the voting period ends, even if they have achieved a quorum.

    - _GovernorVotesQuorumFraction:_ designed to add flexibility to the quorum by expressing it

as a fraction of the total number of tokens, rather than a fixed number, which helps to

adjust the quorum requirement if the size of the token holder community changes.

    - _GovernorVotes:_ basic governance contract that allows token holders (e.g., ERC721 and

ERC20) to propose and vote changes in the system. Includes a voting mechanism that

requires a minimum quorum and a majority vote to pass proposals. It is meant to be

used with the _ERC721Votes_ and _ERC20Votes_ contracts.

    - _GovernorVotesComp:_ designed specifically for COMP token holders, this contract works

similar to _GovernorVotes_ .

    - _ERC721Votes_ and _ERC20Votes_ : designed to allow ERC721 and ERC20 token holders to

use the voting power of their tokens in voting systems.

    - _TimelockController:_ designed to provide time-based control over proposals. Allows

proposals to be submitted, but they cannot be executed until a specified amount of time

passed.


Most of these contracts implement a delegation functionality, which allows a token holder to

delegate their voting power to other accounts to vote on their behalf.


Contracts 4.9 Release Audit − System Overview − 7


### **Access control contracts**

Contracts that provide a way to manage access control in smart contracts. These contracts

allow users to define different roles within a system, assign, revoke and renounce permissions

to these roles, and control who has access to certain functions or resources within the system.

The OpenZeppelin contracts team is planning to introduce the `manager` contracts, which are

meant to be used to better manage permissions in complex systems, and the

`AccessControlDefaultAdminRules` contract, which specifies certain rules to manage the

holder of the default `admin` role of a system.


**Manager contracts**


If a contract is meant to have permissioned functions, it should inherit from the

`AccessManaged` contract, which provides the `restricted` modifier. Functions decorated

with this modifier are permissioned according to an authority, represented by the

`IAuthority` interface, which should at least define the `canCall` function. OpenZeppelin

contracts provide an authority contract, the `AccessManager` contract, which inherits from

`AccessControl` and implements the `canCall` function, and defines a set of at most 255

groups. Users can be added into one or more groups, and each group has access to none, one

or more contracts, and to one or more functions of those contracts. By default, all users have

access to a `public` group, set in the constructor of the `AccessManager` contract


The `AccessManager` contract defines three different contract modes:


    - _Open_ : Anyone can call any function of any contract that implements the `restricted`

modifier

    - _Closed_ : No one can call any function of any contract that implements the `restricted`

modifier

    - _Custom_ : Only users that are part of a group can call a certain function of a given target

contract.


**`AccessControlDefaultAdminRules`** **contract**


The `AccessControl` contract provides basic access control management by defining roles

and assigning permissions. However, managing the `DEFAULT_ADMIN_ROLE` is a critical task

as it grants special permissions to control other roles, which may potentially have privileged

access within the system. To mitigate this risk, OpenZeppelin's access control library provides

the `AccessControlDefaultAdminRules` contract.


Contracts 4.9 Release Audit − System Overview − 8


This contract extends the `AccessControl` contract and adds the ability to specify special

rules for managing the `DEFAULT_ADMIN_ROLE` . If a specific role does not have an `admin`

role assigned, the holder of the DEFAULT_ADMIN_ROLE can grant or revoke it.


This contract implements several risk mitigations:


   - Only one account can hold the `DEFAULT_ADMIN_ROLE` from deployment until it is

potentially renounced.

   - A 2-step process is enforced to transfer the `DEFAULT_ADMIN_ROLE` to another

account.

   - A configurable delay is enforced between the two steps, allowing the transfer to be

cancelled before it is accepted.

   - The delay can be changed by scheduling a call to the `changeDefaultAdminDelay`

function.

   - It is not possible to use another role to manage the `DEFAULT_ADMIN_ROLE` .


The `AccessControlDefaultAdminRules` contract provides a more secure way to manage

the `DEFAULT_ADMIN_ROLE` and prevents potential security risks in the system.

## **Security Model and Trust** **Assumptions**


The following trust assumptions were part of this audit:


   - The contracts audited use several other libraries of the repository. We assume all

dependencies that are out of scope work as intended.

   - The OpenZeppelin contracts library is meant to be as flexible as possible. To accomplish

this, most of the functions defined in the contracts can be overridden by the user, which

could potentially introduce vulnerabilities.

## **Client-Reported Issues**


During the course of this audit, the client reported an issue that they found in one of the

audited contracts.


Contracts 4.9 Release Audit − Security Model and Trust Assumptions − 9


The current `AccessControlDefaultAdminRules` implementation inherits from the

`AccessControl` behavior, which allows any account to renounce any role even if it has not

been granted.


However, if a user renounces the `DEFAULT_ADMIN_ROLE` without holding it, the action resets

the `defaultAdmin()` and `owner()` variables.


Consider a scenario where Alice, who is the current default `admin`, initiates a transfer to the

zero address by calling the <u>`[beginDefaultAdminTransfer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/AccessControlDefaultAdminRules.sol#L201)`</u> <u>function, so her role can be</u>

renounced after a schedule has passed. Once the schedule has passed, Bob, who does not

hold the `DEFAULT_ADMIN_ROLE`, calls the <u>`[renounceRole](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/AccessControlDefaultAdminRules.sol#L107)`</u> <u>function, which in turn calls the</u>

<u>`[_revokeRole](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/AccessControlDefaultAdminRules.sol#L138)`</u> <u>function</u> and deletes the `_currentDefaultAdmin` .


Hence, any contract that relies on the `defaultAdmin()` function would incorrectly assume

that the `admin` is the zero address, when in reality, the `DEFAULT_ADMIN_ROLE` is still held by

Alice, who has not completed the renouncing.


**_Update:_** _Resolved in_ _<u>[pull request #4177.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4177)</u>_


Contracts 4.9 Release Audit − Client-Reported Issues − 10


## **Medium Severity**

### **M-01 Calldata Is Lost Without Signatures**

In the `GovernorCompatibilityBravo` contract, the `propose` function allows providing

function signatures as a string array and data as a bytes array to be encoded through the

`_encodeCalldata` function, which combines those two arrays into proper calldata. The

function description of `_encodeCalldata` states that the function signature is optional.


However, if the `signatures` array is of size 0, then the <u>[calldata is lost in the loop. This would](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L151-L157)</u>

result in a successful proposal without the intended calldata.


Consider checking that the size of the arrays is equal to ensure the proposal is made as

intended.


**_Update:_** _Resolved in_ _<u>[pull request #1. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts-ghsa-93hq-5wgc-jc82/pull/1)</u>_


_We will publish a version 4.8.3 with a patch for this issue as well as a security advisory._

### **M-02 Potential Selector Collision When** **Restricting the receive Function**


The [ `AccessManager` ] contract keeps track of all restricted functions of the contracts of a

system, and who can call them in the [ `_allowedGroups` ] mapping. To differentiate between

functions in a contract, <u>[function selectors are used.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManaged.sol#L35)</u>


However, if a contract has a function with function selector `0x00000000` that is restricted,

and also has a restricted receive function, the groups that can access these two will be the

same, since `msg.sig` returns `0x00000000` in the receive function.


A user may want to define a function with selector `0x00000000` for gas efficiency reasons,

since:


   - They are cheaper to look up when someone calls them because they are first in a

contract's bytecode.

   - They are cheaper to call, since users pay gas for the number of bytes of data sent, and

the more zeros, the cheaper.


Contracts 4.9 Release Audit − Medium Severity − 11


There are some <u>[real case scenarios](https://etherscan.io/tx/0xca7d3edc40e43dd74bce650a3896153eb4c798184fbaf08ab1637548386abbd8)</u> where this pattern is followed.


Note that the same can happen when a restricted fallback function is defined, and no calldata

is sent in the transaction.


Consider including the calldata length to differentiate between a restricted function with 0

bytes selector and restricted receive functions. Otherwise, consider thoroughly documenting

this behavior, so users are aware of this edge-case and its possible impact.


**_Update:_** _Resolved in_ _<u>[pull request #4178. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4178)</u>_


_Addressed by improving documentation._

### **M-03 Potentially Incorrect Accounting of Voting** **Units When Overriding ERC721Votes '** **_getVotingUnits Function's Formula**


The [ `ERC721Votes` contract] is an extension of the [ `ERC721` contract] that supports voting

and delegation as implemented by the [ `Votes` contract], where, in the base implementation,

each individual <u>[NFT counts as 1 vote unit. The](https://github.com/OpenZeppelin/openzeppelin-contracts/blob//contracts/token/ERC721/extensions/ERC721Votes.sol#L10)</u> `Votes.sol` contract defines, among others,

two functions:


   - The [ `_transferVotingUnits` function], which transfers the voting power from one

account to another on transfers (if the sender was already delegating)

   - The <u>[delegate functions, which delegate the voting power of the caller to the specified](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/Votes.sol#L120-L145)</u>

address


Additionally, the `ERC721Votes` contract defines the [ `_getVotingUnits` function]. This

function is defined but not implemented in the `Votes.sol` contract, and, in the

`ERC721Votes` implementation, it returns the balance of tokens of the account sent as a

parameter. Users can override this function to modify the method of accounting voting units.


However, if the `_getVotingUnits` function is overridden to define a different voting unit

(which is likely given that it is the only function that can be overridden in the contract and it is

feasible that the user would want to use other voting power systems), such as quadratic

voting, this change would break the accounting of voting power when delegating it. This

happens because when transferring, minting, or burning tokens, the

[ `_afterTokenTransfer` function] transfers the voting power by granularity of `batchSize`,

instead of accounting for the real voting power defined by the potentially overridden

`_getVotingUnits` function, as the [ `_delegate` function] does.


Contracts 4.9 Release Audit − Medium Severity − 12


**Example:**


Let's say that the `_getVotingUnits` function is declared as a quadratic function:

```
  function _getVotingUnits(address account) internal view virtual override returns
(uint256) {
     return balanceOf(account) * balanceOf(account);
  }

```

Alice is transferred 5 tokens and the `_transferVotingUnits` function is called by the

`_afterTokenTransfer` hook, registering a total of 5 token units in the

[ `_totalCheckpoints` ] data structure and in <u>[Alice's delegatee's voting power, Bob.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob//contracts/governance/utils/Votes.sol#L171)</u>


The following scenarios are then possible:


   - If Bob is only Alice's delegatee, their voting power would be of 5 units. If Alice

redelegates their voting power to Charlie by calling the `delegate` function, this will

revert since it uses the [ `_getVotingUnits` function to move delegated votes]. Since it

would try to move `5 * 5 = 25` voting units, <u>[the transaction will revert.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/Votes.sol#L182)</u>

   - If Bob has more than 25 voting units because they are the delegatee of multiple

accounts, then, if Alice delegates their voting power to Charlie, more voting power than

expected will be subtracted from Bob (votes that corresponded to other delegators).


Even though OpenZeppelin contracts' documentation mentions that custom overrides may

break some important assumptions and introduce vulnerabilities in otherwise secure code, we

found this particular override to be highly likely, very prone to error, and of a very high impact

given that almost any change in the formula of the `_getVotingUnits` would break the

accountability system of the voting power.


Consider modifying the `_transferVotingUnits` function in the `Votes` contract to account

accounts' voting power properly by using the `_getVotingUnits` function.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin contracts team added a comment to_

_the code informing that overriding the_ _`_getVotingUnits`_ _function would likely result in_

_incorrect vote tracking. The team stated:_


_We agree that if a developer overrides_ _`ERC721Votes._getVotingUnits`_ _, this might_

_lead to errors. However, we see this as a broader issue with overrides in general. This is_

_[something we caveat and warn about in our documentation, and it is also documented](https://docs.openzeppelin.com/contracts/4.x/extending-contracts#security)_

_in the Security Model section of the audit report: "Most of the functions defined in the_

_contracts can be overridden by the user, which could potentially introduce_

_vulnerabilities"._


Contracts 4.9 Release Audit − Medium Severity − 13


## **Low Severity**

### **L-01 Incomplete Documentation**

In the `TimelockController` contract, the <u>`[scheduleBatch](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L239)`</u> <u>[function description](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L239)</u> suggests

always emitting a `CallSalt` event. However, this is only the case when the salt is not `0` .

Consider modifying the documentation to respect this scenario.


The `GovernorPreventLateQuorum` documentation still states that the time extension is

<u>[based on a number of blocks](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/extensions/GovernorPreventLateQuorum.sol#L15)</u> and thereby does not follow the clock() change. Consider

adapting the documentation to the code changes.


**_Update:_** _Resolved in_ _<u>[pull request #4176. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_


_Improved documentation as suggested._

### **L-02 Non-existent Groups Can Be Granted** **Access to Permissioned Functions**


The <u>`[setFunctionAllowedGroup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManager.sol#L198)`</u> <u>function</u> in the `AccessManager` contract enables the

admin to add and remove a target contract and a list of selectors from a specific group.


However, this function does not check whether the specified group already exists in the

<u>`[_createdGroups](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManager.sol#L83)`</u> <u>variable. Consequently, it is possible to add a target and a list of selectors</u>

to a non-existent group. This could be confusing and error-prone since future added groups

may already have access to a function that they should not have access to.


Consider adding a check that ensures the specified group exists before granting access to a

function. This check will help ensure that only the intended groups have access to the target

contract and selectors. Otherwise, consider properly documenting this behavior and the

rationale behind it.


**_Update:_** _Resolved in_ _<u>[pull request #4178.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4178)</u>_


Contracts 4.9 Release Audit − Low Severity − 14


### **L-03 Missing Error Messages in require** **Statements**

Throughout the codebase, there are `require` statements that lack error messages. For

instance:


   - The `require` statement on <u>[line 93](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol#L93)</u> of <u>`[Governor.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol)`</u>

   - The `require` statement on <u>[line 62](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/Votes.sol#L62)</u> of <u>`[Votes.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/Votes.sol)`</u>

   - The `require` statement on <u>[line 53](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/token/ERC20/extensions/ERC20Votes.sol#L53)</u> of <u>`[ERC20Votes.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/token/ERC20/extensions/ERC20Votes.sol)`</u>


Consider including specific, informative error messages in `require` statements to improve

overall code clarity and facilitate troubleshooting whenever a requirement is not satisfied.


**_Update:_** _Resolved in_ _<u>[pull request #4176.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_

## **Notes & Additional** **Information**

### **N-01 Misleading Comments**


There are several places where docstrings could be improved:


   - The <u>`[_upperBinaryLookup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/91df66c4a9dfd0425ff923cbeb3a20155f1355ea/contracts/utils/Checkpoints.sol#L326-L347)`</u> function is called by the <u>`[upperLookup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/91df66c4a9dfd0425ff923cbeb3a20155f1355ea/contracts/utils/Checkpoints.sol#L236-L243)`</u> and

<u>`[upperLookupRecent](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/91df66c4a9dfd0425ff923cbeb3a20155f1355ea/contracts/utils/Checkpoints.sol#L245-L268)`</u> functions. However, docstrings of these functions state the

opposite things. `upperLookup` and `upperLookupRecent` state that the return key is

lower or equal to the search key but `_upperBinaryLookup` states that the return key

is greater than the search key.

   - The `upperLookup` and `upperLookupRecent` functions do not specify how

`Trace224` structs of length 0 are handled.

   - There are no docstring on how `ShortStrings` is stored in memory.


Consider modifying the docstrings to reflect these items.


**_Update:_** _Resolved in pull requests_ _<u>[#4218](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4218)</u>_ _and_ _<u>[#4224.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4224)</u>_


Contracts 4.9 Release Audit − Notes & Additional Information − 15


### **N-02 Unused Function**

The <u>`[_admin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/91df66c4a9dfd0425ff923cbeb3a20155f1355ea/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L175-L180)`</u> function of the `TransparentUpgradeableProxy` contract is not used.


Consider removing it or alternatively, documenting the purpose of the function using

docstrings.


**_Update:_** _Resolved in_ _<u>[pull request #4224.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4224)</u>_

### **N-03 Function Visibility Can Be Restricted**


The <u>`[_dispatchImplementation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/91df66c4a9dfd0425ff923cbeb3a20155f1355ea/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L123-L135)`</u> and <u>`[_dispatchAdmin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/91df66c4a9dfd0425ff923cbeb3a20155f1355ea/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L109-L121)`</u> functions are read-only but not

marked as `view` .


Consider marking these functions as `view` .


**_Update:_** _Resolved, this is not an issue. The OpenZeppelin contracts team stated:_


_The_ _`_dispatch*`_ _functions accesses_ _`msg.value`_ _, so the recommendation doesn't_

_compile._

### **N-04 Unclear Code**


The <u>`[toString](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/91df66c4a9dfd0425ff923cbeb3a20155f1355ea/contracts/utils/Strings.sol#L41-L46)`</u> function of the `Strings` library uses `abi.encodePacked` to concatenate

two strings.


For clarity and gas savings consider using `string.concat(...)` instead of

`string(abi.encodePacked(...))` .


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin contracts team stated:_


_This is something we have planed for 5.0 but that we decided not to do so far for a_

_simple reason:_


_bytes.concat was introduced in 0.8.4, and string.concat was properly introduced in_

_0.8.12. If we make this change, we should change the pragma for this file from ^0.8.0 to_

_^0.8.12, which is a breaking change._


Contracts 4.9 Release Audit − Notes & Additional Information − 16


### **N-05 State Variable Visibility Not Explicitly** **Declared**

Within <u>`[AccessManager.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManager.sol)`</u>, the state variable <u>`[_createdGroups](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManager.sol#L83)`</u> lacks an explicitly

declared visibility.


For clarity, consider always explicitly declaring the visibility of variables, even when the default

visibility matches the intended visibility.


**_Update:_** _Resolved in_ _<u>[pull request #4178.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4178)</u>_

### **N-06 Function Visibility Can Be Public**


The <u>`[Governor](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/governance/Governor.sol)`</u> <u>contract</u> provides certain functions that can be called from the contract itself,

its children, and the outside world to query some of the proposal's variables, such as

<u>`[proposalDeadline](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/governance/Governor.sol#L208)`</u> and <u>`[proposalSnapshot](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/governance/Governor.sol#L201)`</u> (to get the `voteStart` and `voteEnd`

variables). It also defines the <u>`[_proposalProposer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/governance/Governor.sol#L215)`</u> <u>function, which is internal, and therefore</u>

not accessible by other contracts or the outside world. For consistency, and to let users get

the proposer's address of a particular proposal, consider changing the visibility to `public`,

and renaming the function to `proposalProposer`, or consider creating a new function

named `proposalProposer` that returns what the `_proposalProposer` function returns.


**_Update:_** _Resolved in_ _<u>[pull request #4176.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_

### **N-07 Inconsistent SafeCast Usage**


The usage of the <u>`[SafeCast](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/utils/math/SafeCast.sol#L22)`</u> <u>library</u> varies between contracts. Some contracts declare `using`

`SafeCast for uint256` at the top (e.g., `Governor.sol` ) while others do

`SafeCast.toUint32(number)` (e.g., `Votes.sol` ). Consider applying a consistent style

throughout the codebase to improve its readability.


**_Update:_** _Resolved in_ _<u>[pull request #4176. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_


_Changed to make it consistent (removed "using for" syntax)._


Contracts 4.9 Release Audit − Notes & Additional Information − 17


### **N-08 Interface and Implementation Mismatch**

The diff under review introduced a change to the `IGovernanceCompatibilityBravo`

interface. Since the `cancel` function is now natively supported by the underlying `Governor`

contract, the `cancel` function also moved to the `IGovernor` interface.


However, the function signature varies from the <u>`[IGovernor](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/IGovernor.sol#L243-L248)`</u> <u>interface</u> to the

<u>`[IGovernanceCompatibilityBravo](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.8/contracts/governance/compatibility/IGovernorCompatibilityBravo.sol#L94)`</u> <u>interface, as seen below:</u>


_`IGovernor`_ _interface_

```
function cancel(
  address[] memory targets,
  uint256[] memory values,
  bytes[] memory calldatas,
  bytes32 descriptionHash
) public virtual returns (uint256 proposalId);

```

_`IGovernanceCompatibilityBravo`_ _interface_

```
function cancel(uint256 proposalId) public virtual;

```

This currently leaves one of the <u>implemented</u> <u>`[cancel](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78s/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L109-L121)`</u> <u>functions</u> without its interface

counterpart. Consider adding it back to the interface for completeness.


**_Update:_** _Resolved in_ _<u>[pull request #4176. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_


_The function had been removed from the interface previously but it shouldn't have._

_Added it back._

### **N-09 "Last updated" and "Available since"** **Comments Unchanged or Missing**


The files of the contracts library all have a comment on top of the file indicating in which

release it was last changed. For the diffs in scope, this is yet unchanged. Consider updating

these comments before the actual release, and consider adding the version from which new

contracts are available.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin contracts team stated:_


_The "last updated" heading is automatically changed by our release scripts. Unclear_

_which of the "available since" are missing._


Contracts 4.9 Release Audit − Notes & Additional Information − 18


### **N-10 Latest Governance Interface Is** **Unsupported**

The [ `Governor` contract] implements the ERC-165 standard and thereby the

`supportsInterface` function. Within that function, different versions of the `Governance`

interface are supported for backwards compatibility. However, the latest version is not

respected in the set of supported interfaces.


Consider adding support for the current interface for the sake of completeness.


**_Update:_** _Resolved in_ _<u>[pull request #4176. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_


_An updated interface id had been deliberately omitted because we are concerned about_

_the sustainability of that approach as the contract evolves. We realize now that ERC-165_

_is not a good fit, but we also realize that as-is the contract is missing a method for the_

_detection of the new features._


_We've added an interface id for the 2 new functions in this release._

### **N-11 Missing Event Parameters**


Some events should be modified to emit information that could be helpful for users:


   - The <u>`[ProposalExecuted](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol#L327)`</u> and <u>`[ProposalCanceled](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol#L426)`</u> events in the `Governor` contract

could emit the block/timestamp (i.e., clock()) in which the proposal was executed/

canceled.

   - The <u>`[AccessModeUpdated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManager.sol#L293)`</u> event could emit the old contract mode.

   - The <u>`[AuthorityUpdated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManaged.sol#L66)`</u> event in the `AccessManaged` contract could emit the old

authority address.


**_Update:_** _Resolved in_ _<u>[pull request #4178. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4178)</u>_


_`ProposalExecuted`_ _and_ _`ProposalCanceled`_ _are locked by backwards_

_compatibility._


_`AuthorityUpdated`_ _in fact already includes the old authority address as used in_

_`AccessManaged`_ _. Note that we used the same event as supported by Solmate._


_In_ _`AccessModeUpdated`_ _we have now added a parameter for the old mode._


Contracts 4.9 Release Audit − Notes & Additional Information − 19


### **N-12 Naming Issues Hinder Code Understanding** **and Readability**

To favor explicitness and readability, several parts of the contracts may benefit from better

naming. Our suggestions are:


  - Renaming the <u>`[Checkpoint.fromBlock](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/token/ERC20/extensions/ERC20Votes.sol#L29)`</u> <u>parameter</u> to `Checkpoint.timepoint` in

the `ERC20Votes` contract, to adhere to the `clock()` changes throughout the diff.

   - The <u>`[status](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f8e3c375d19bd12f54222109dd0801c0e0b60dd2/contracts/governance/Governor.sol#L320)`</u> <u>variable</u> in the `execute` function should be named `proposalState` .

The concept of `status` is never introduced until that function, and the word "state" and

"status" have different meanings.

   - The <u>`[_push](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/Votes.sol#L198)`</u> function in the <u>`[Votes.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/Votes.sol)`</u> contract should be renamed to `_upsert` or

`_pushOrUpdate` . If the last time an item was pushed to the <u>`Checkpoints`</u> <u>array</u> is

equal to the current time ( `clock()` ), the function will not actually push a new item but

instead, update the latest one.

   - The <u>`[AccessManaged](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManaged.sol#L16)`</u> <u>contract</u> could be renamed to `AccessManageable`, to follow

the same naming convention used throughout the library ( `Initializable`,

`Enumerable`, `Ownable`, `Pausable`, `Mintable`, `Burnable`, etc).


**_Update:_** _Resolved in_ _<u>[pull request #4176. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_


_Most of the suggestions can't be applied for v4.9 due to backwards compatibility_

_constraints, but will be considered for v5.0._


_The name_ _`AccessManageable`_ _does not sound good to us, so we're leaving this for_

_consideration later._


_`status`_ _was renamed to_ _`currentState`_ _._

### **N-13 Impossible to Get an Account's Latest** **Votes Through the GovernorVotes Contract**


The <u>`[_getVotes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/extensions/GovernorVotes.sol#L48)`</u> function in the `GovernorVotes` contract overrides the same function from

the `Governor` contract so that the <u>`[getVotes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol#L434)`</u> <u>function</u> from the Governor contract returns

the votes of a given account at a given point in time.


However, the `_getVotes` function in the `GovernorVotes` contract calls the

<u>`[getPastVotes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/extensions/GovernorVotes.sol#L53)`</u> <u>function</u> from the token contract (which, in the context of this library, could be

either of the `ERC721Votes` or `ERC20Votes` contracts), making it impossible to get the latest

vote of a given account through the Governor contract.


Contracts 4.9 Release Audit − Notes & Additional Information − 20


Since this behavior is intentional to avoid double-voting issues, consider adding an external

`getLatestVotes` function in the Governor contract that users can call to get the latest state

of an account.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin contracts team stated:_


_We will not add this getter to avoid adding more surface to the Governor contracts. The_

_information can be queried on the token if needed._

### **N-14 Overlapping TimelockController Statuses**


In the `TimelockController` contract, the status of operations can be queried (e.g., with

<u>`[isOperationPending](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L147)`</u> or <u>`[isOperationReady](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L154)`</u> ). The checks that lead to either status

partly overlap, such that a ready operation is also always pending as well. While this makes

sense, this behavior could confuse developers, who may expect the statuses to be exclusive.


Consider explicitly documenting this behavior in the functions' NatSpec.


**_Update:_** _Resolved in_ _<u>[pull request #4176. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_


_We have added documentation to clarify._

### **N-15 Require Statements With Multiple** **Conditions**


Within the codebase, there are multiple `require` statements that require multiple conditions

to be satisfied. For instance:


   - The `require` statement on <u>[line 110](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/AccessControlDefaultAdminRules.sol#L110-L113)</u> of `AccessControlDefaultAdminRules.sol`

   - The `require` statement on <u>[line 248](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/AccessControlDefaultAdminRules.sol#L248)</u> of `AccessControlDefaultAdminRules.sol`

   - The `require` statement on <u>[line 420](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol#L420-L423)</u> of `Governor.sol`


To simplify the codebase and raise the most helpful error messages for failing `require`

statements, consider having a single require statement per condition.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin contracts team stated:_


_We will not apply this suggestion because we are more concerned about code size bloat_

_from additional revert reasons than about the specificity of the revert reasons._


Contracts 4.9 Release Audit − Notes & Additional Information − 21


### **N-16 Typographical Errors**

To improve readability, consider correcting the following typographical errors:


   - on <u>line 11</u> of `AccessManaged.sol`, "allows certain callers access to certain functions"

should be "allows certain callers to access certain functions"

   - on <u>[line 77](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManager.sol#L77)</u> of `AccessManager.sol`, "succintly" should be "succinctly"

   - on <u>[line 20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol#L20)</u> of `Governor.sol`, "several function" should be "several functions"

   - on <u>[line 76](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L76)</u> of `GovernorCompatibilityBravo.sol`, "their" should be "there"

   - on <u>[line 167](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/IGovernor.sol#L167)</u> of `IGovernor.sol`, "vote ends" should be "vote end"

   - on <u>[line 28](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/IVotes.sol#L28)</u> and <u>[line 34](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/IVotes.sol#L34)</u> of `IVotes.sol` as well as <u>[line 75](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/Votes.sol#L75)</u> and <u>[line 88](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/utils/Votes.sol#L88)</u> of `Votes.sol`,

"the value the end" should be "the value at the end"


**_Update:_** _Resolved in_ _<u>[pull request #4178](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4178)</u>_ _and_ _<u>[pull request #4176.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_

### **N-17 Unclear Proposal State**


When a proposal is not canceled, executed or active, it may succeed or be defeated. For a

proposal to succeed, two conditions must be met: the voting must succeed and the quorum

must be reached. These two conditions are defined by the developer because the default

functions <u>`[_quorumReached](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol#L222)`</u> and <u>`[_voteSucceeded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/Governor.sol#L227)`</u> are not implemented.


Since the criteria for a proposal to succeed depends on two user-defined functions, it may be

unclear why a proposal was defeated. To provide more specific information about why a

proposal was defeated, consider modularizing the proposal state `Defeated` into two

categories: `DefeatedQuorum` and `DefeatedVoting` .


**_Update:_** _Acknowledged, will resolve. The OpenZeppelin contracts team stated:_


_We cannot change the state enum due to backwards compatibility, but will consider a_

_getter such as_ _`defeatReason`_ _for future versions._

### **N-18 Lack of Indexed Parameter in Event**


The <u>`[ProposalCreated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/IGovernor.sol#L29-L39)`</u> <u>event</u> of the `IGovernor` interface is fired whenever a new proposal

is made. Among its parameters are the proposer's address and the proposal ID. Consider

making these parameters `indexed` to leverage the filtering of events.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin contracts team stated:_


Contracts 4.9 Release Audit − Notes & Additional Information − 22


_Cannot change due to backwards compatibility, in particular with_ _`GovernorBravo`_ _._

### **N-19 Unused Imports**


Consider removing the following unused imports to improve the overall clarity and readability of

the codebase.


   - In <u>`[TimelockController.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol)`</u>, the import <u>`[Address](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L9)`</u> is unused and could be

removed.

   - In <u>`[AccessManager.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManager.sol)`</u>, the import <u>`[AccessControl](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/manager/AccessManager.sol#L5)`</u> is unused and could be

removed.


**_Update:_** _Resolved in_ _<u>[pull request #4176](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_ _and_ _<u>[pull request #4178.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4178)</u>_

### **N-20 Unused Named Return Variables**


Named return variables are a way to declare variables that are meant to be used within a

function body for the purpose of being returned as the function's output. They are an

alternative to explicit in-line `return` statements.


Within the codebase, there are multiple instances of unused named return variables:


   - The <u>`[newAdmin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/AccessControlDefaultAdminRules.sol#L167)`</u> return variable in the `pendingDefaultAdmin` function in

`AccessControlDefaultAdminRules.sol` .

   - The <u>`[schedule](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/AccessControlDefaultAdminRules.sol#L167)`</u> return variable in the `pendingDefaultAdmin` function in

`AccessControlDefaultAdminRules.sol` .


   - The <u>`[newDelay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/access/AccessControlDefaultAdminRules.sol#L182)`</u> return variable in the `pendingDefaultAdminDelay` function in

`AccessControlDefaultAdminRules.sol` .


   - The <u>`[registered](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L140)`</u> return variable in the `isOperation` function in

`TimelockController.sol` .


   - The <u>`[pending](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L147)`</u> return variable in the `isOperationPending` function in

`TimelockController.sol` .

   - The <u>`[ready](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L154)`</u> return variable in the `isOperationReady` function in

`TimelockController.sol` .

   - The <u>`[done](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L162)`</u> return variable in the `isOperationDone` function in

`TimelockController.sol` .


Contracts 4.9 Release Audit − Notes & Additional Information − 23


   - The <u>`[timestamp](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L170)`</u> return variable in the `getTimestamp` function in

`TimelockController.sol` .

   - The <u>`[duration](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L179)`</u> return variable in the `getMinDelay` function in

`TimelockController.sol` .

   - The <u>`[hash](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L193)`</u> return variable in the `hashOperation` function in

`TimelockController.sol` .

   - The <u>`[hash](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/TimelockController.sol#L207)`</u> return variable in the `hashOperationBatch` function in

`TimelockController.sol` .

   - The <u>`[targets](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L170)`</u> return variable in the `_getProposalParameters` function in

`GovernorCompatibilityBravo.sol` .

   - The <u>`[values](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L170)`</u> return variable in the `_getProposalParameters` function in

`GovernorCompatibilityBravo.sol` .

   - The <u>`[calldatas](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L170)`</u> return variable in the `_getProposalParameters` function in

`GovernorCompatibilityBravo.sol` .

   - The <u>`[descriptionHash](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L170)`</u> return variable in the `_getProposalParameters` function in

`GovernorCompatibilityBravo.sol` .

   - The <u>`[targets](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L256-L257)`</u> return variable in the `getActions` function in

`GovernorCompatibilityBravo.sol` .

   - The <u>`[values](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L257-L258)`</u> return variable in the `getActions` function in

`GovernorCompatibilityBravo.sol` .

   - The <u>`[signatures](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L258-L259)`</u> return variable in the `getActions` function in

`GovernorCompatibilityBravo.sol` .

   - The <u>`[calldatas](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L259-L261)`</u> return variable in the `getActions` function in

`GovernorCompatibilityBravo.sol` .

   - The <u>`[timepoint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/extensions/GovernorVotes.sol#L26)`</u> return variable in the `clock` function in `GovernorVotes.sol` .

   - The <u>`[clockmode](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/extensions/GovernorVotes.sol#L38)`</u> return variable in the `CLOCK_MODE` function in

`GovernorVotes.sol` .

   - The <u>`[timepoint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/extensions/GovernorVotesComp.sol#L26)`</u> return variable in the `clock` function in `GovernorVotesComp.sol` .

   - The <u>`[clockmode](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f5e91062e10fe7f715eab7e46154e5d445add78/contracts/governance/extensions/GovernorVotesComp.sol#L38)`</u> return variable in the `CLOCK_MODE` function in

`GovernorVotesComp.sol` .


Consider either using or removing any unused named return variables.


**_Update:_** _Partially resolved in_ _<u>[pull request #4176. The OpenZeppelin contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/4176)</u>_


_Removed some but not all. In particular, we want to have named return variables when_

_there are multiple return values, as a form of documentation._


Contracts 4.9 Release Audit − Notes & Additional Information − 24


## **Conclusions**

Three medium-severity issues were found. Several changes were proposed to improve the

code’s overall quality and reduce the attack surface.


Contracts 4.9 Release Audit − Conclusions − 25


