### | security

# **OpenZeppelin** **Contracts** **Release v5.3 Diff** **Audit**

#### **April 3, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  6

ERC-6909 6

Governance 6

Utilities 6


Security Model and Trust Assumptions _______________________________________________  7

Privileged Roles 7


Low Severity ______________________________________________________________________  8

L-01 canCallWithDelay Change Not Functionally Equal 8

L-02 ERC-6909 Total Supply Assumption Can Be Overridden 8

L-03 Missing and Misleading Documentation 9


Notes & Additional Information ____________________________________________________ 10

N-01 Typography Errors 10

N-02 escapeJSON Escapes All Unicode Characters 10


Conclusion ______________________________________________________________________ 12


OpenZeppelin Contracts Release v5.3 Diff Audit − Table of Contents − 2


## **Summary**

**Type** Library


**Timeline** From 2025-03-03
To 2025-03-12


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


0 (0 resolved)



**Total Issues** 5 (3 resolved, 1 partially resolved)



**Low Severity Issues** 3 (1 resolved, 1 partially resolved)



**Notes & Additional**
**Information**



2 (2 resolved)



OpenZeppelin Contracts Release v5.3 Diff Audit − Summary − 3


## **Scope**

We audited the <u>[OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/)</u> repository at commit <u>[d4b2e98. This](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/d4b2e98c737f54a21961b39d6bba13b839f3b6f4)</u>

commit was diffed against commit <u>[acd4ff7](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/acd4ff74de833399287ed6b31b4debf6b2b35527)</u> and all new files were fully audited. In scope were

the following files:

```
contracts
├── access/manager/AuthorityUtils.sol
├── account/utils/draft-ERC4337Utils.sol
├── governance
│  ├── Governor.sol
│  ├── IGovernor.sol
│  └── extensions
│    ├── GovernorProposalGuardian.sol
│    ├── GovernorSequentialProposalId.sol
│    ├── GovernorSuperQuorum.sol
│    ├── GovernorVotesQuorumFraction.sol
│    └── GovernorVotesSuperQuorumFraction.sol
├── interfaces/draft-IERC6909.sol
├── metatx/ERC2771Forwarder.sol
├── proxy/utils/Initializable.sol
├── token
│  ├── ERC20/extensions/ERC4626.sol
│  ├── ERC20/utils/SafeERC20.sol
│  └── ERC6909
│    ├── draft-ERC6909.sol
│    └── extensions
│      ├── draft-ERC6909ContentURI.sol
│      ├── draft-ERC6909Metadata.sol
│      └── draft-ERC6909TokenSupply.sol
└── utils
├── Calldata.sol
├── Pausable.sol
├── Strings.sol
├── cryptography
│  ├── Hashes.sol
│  └── MessageHashUtils.sol
├── math/Math.sol
└── structs
├── EnumerableMap.sol
├── EnumerableSet.sol
└── MerkleTree.sol

```

OpenZeppelin Contracts Release v5.3 Diff Audit − Scope − 4


**_Update:_** _All resolutions and the final state of the audited codebase mentioned in this report are_

_[contained at commit f3f0a64](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/f3f0a6466f2be4f8b2d73c97cec0fa6e37763ec0)_ _[on branch release-v5.3. In addition to the fixes identified in this](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v5.3)_

_report, this commit also includes the following changes:_









_Fix to signature verification in_ _<u>[P256.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/P256.sol)</u>_ _introduced at version_ _<u>[5.1.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.1.0)</u>_ _due to RIP-7212_

_specifications for non-existent precompiles._


_Minor codebase changes introduced via_ _<u>[PR5605](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5605)</u>_ _related to addition of Entrypoint v0.8._



_Please note that changes introduced to contracts not in-scope for this audit were not part of_

_the additional reviews._


OpenZeppelin Contracts Release v5.3 Diff Audit − Scope − 5


## **System Overview**

Version 5.3 of the OpenZeppelin Contracts library introduces new features, including support

for ERC-6909, optional enhancements for governance, and updated functionality for certain

utilities.

### **ERC-6909**


[The ERC-6909](https://eips.ethereum.org/EIPS/eip-6909) standard strives to create a minimal specification for multi-token contracts,

which removes some of the features of ERC-1155. Specifically, callbacks and batching have

been removed from the interface. This new release follows the ERC specification to provide

developers with the fundamental smart contracts necessary for this standard, as an alternative

to the more complex ERC-1155.

### **Governance**


This release introduces new governance features, including the ability to add guardians, track

proposal IDs sequentially, and implement a super quorum. The first feature allows for the

addition of a guardian, which is a privileged entity that can cancel proposals at any time. The

second feature is the introduction of a sequential proposal ID system, which includes a new

helper function that assists with the transition from a hash-based proposal identification

system to a sequential one. Lastly, the super quorum feature allows proposals with sufficient

"for" votes to bypass the waiting period and move directly to the "succeeded" state. These

features have been implemented in new contracts that inherit from the existing governance

ones.

### **Utilities**


In this release, changes have been made to three libraries: <mark>`EnumerableMap`</mark> <mark>,</mark>

<mark>`EnumerableSet`</mark> <mark>,</mark> and <mark>`MerkleTree`</mark> <mark>.</mark> For the first two, functionality to clear the existing data

structure was added. Furthermore, a new struct named <mark>`Bytes32x2Set`</mark> was added in order

to store tuples of values. For the Merkle tree, update functionality was added so that the caller

can update a leaf of the Merkle tree.


OpenZeppelin Contracts Release v5.3 Diff Audit − System Overview − 6


## **Security Model and Trust** **Assumptions**

Auditing libraries requires a shift in focus due to their composability within blockchain

protocols. While the scope of an audit is typically limited to the code itself, the scope expands

when it comes to libraries because of their potential internal and external integrations. Libraries

act as foundational components for many protocols. This means that their security is

influenced not just by their internal robustness, but also by how they are utilized by integrators.

As a result, ensuring a library's security involves reviewing the code as well as anticipating its

various use cases and integration scenarios.


In addition to the above, the complexity grows because, while a library must accommodate a

wide range of potential use cases, the responsibility for secure implementation often falls on

developers who integrate it into their projects. These developers must carefully review the

<u>[security considerations](https://docs.openzeppelin.com/contracts/5.x/extending-contracts#security)</u> when extending contracts from the library. A library's security risks can

multiply depending on how well developers understand and utilize its contracts. Therefore,

extra care is necessary to identify and address all potential threats, both direct and indirect, or

to document them so that developers are fully aware of the associated security risks.

### **Privileged Roles**


With the introduction of the <mark>`GovernorProposalGuardian`</mark> governance extension, a new

guardian role has been added. As outlined in the System Overview section, this role can cancel

a proposal in any state if it has not been executed, expired, or canceled already. However, if

the guardian is not set, this privilege is passed to the person who made the proposal that is

being canceled. Note that without this extension, the proposer can only cancel their proposal

during the "pending" state.


OpenZeppelin Contracts Release v5.3 Diff Audit − Security Model and Trust

Assumptions − 7


## **Low Severity**

### **L-01 canCallWithDelay Change Not Functionally** **Equal**

The <u><mark>`[canCallWithDelay](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/access/manager/AuthorityUtils.sol#L14)`</mark></u> <u>function</u> of the <mark>`AuthorityUtils`</mark> library helps call <mark>`canCall`</mark> on

an <mark>`authority`</mark> address, and can handle both a <mark>`(bool)`</mark> and <mark>`(bool, uint32)`</mark> response.

The 5.3 release introduced a code change in how the response is decoded. Previously, the

call's return data was <mark>`abi.decode`</mark> <mark>d</mark> depending on the data length. This causes reverts if the

second value exceeds the <mark>`uint32`</mark> size.


In the new version, the return values are simply cast to their expected type. This means that a

value exceeding the <mark>`uint32`</mark> size would wrap around to a value modulo 2 <sup>32</sup> and not revert.

This wrapped <mark>`uint32`</mark> value, which represents the delay of a call, could then cause

unintended behavior in <mark>`AccessManaged`</mark> contracts.


Consider checking the return size of the <mark>`uint32`</mark> value before casting to enforce the expected

interface and to be consistent with the behavior of the previous version.


**_Update:_** _[Resolved in pull request #5584](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5584)_ _[at commit d1efb23. The Solidity Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5584/commits/d1efb2372c069dadd33b8b53c606ad38cf3935c2)_

_stated:_


_The fix is not going back to the previous behavior (that reverted) but instead making sure_

_that the modulo cannot cause a high delay to be interpreted as a small delay. We_

_changed it so that if the value does not fit in a uint32, then we use a 0 delay. This as the_

_effect of disabling any delay that is not a uint32._

### **L-02 ERC-6909 Total Supply Assumption Can Be** **Overridden**


[The ERC-6909 total supply extension assumes the following](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/extensions/draft-ERC6909TokenSupply.sol#L29) to perform an <mark>`unchecked`</mark> total

supply decrement when burning a token:

```
  amount <= _balances[id][from] <= _totalSupplies[id]

```

OpenZeppelin Contracts Release v5.3 Diff Audit − Low Severity − 8


This assumption is enforced <u>[in the base contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/draft-ERC6909.sol#L141-L144)</u> by reverting with the

<mark>`ERC6909InsufficientBalance`</mark> error if the amount exceeds the <mark>`from`</mark> address balance.

Furthermore, the total supply per ID is incremented on each mint such that the total supply

must be at least equal or larger than any of the users' balances. However, a custom token can

potentially override the <mark>`_update`</mark> logic such that this assumption no longer holds. This could

lead to the total supply underflowing upon a burn.


Consider removing the <mark>`unchecked`</mark> block around the total supply decrement on burn.


**_Update:_** _Acknowledged, not resolved. The Solidity Contracts team stated:_


_This behavior is simmilar to the one we have in_ _<mark>`ERC1155`</mark>_ _and_ _<mark>`ERC1155Supply`</mark>_ _<mark>.</mark>_


_While an overriden version of_ _<mark>`_update`</mark>_ _could selectivelly execute_ _<mark>`ERC6909._update`</mark>_

_and_ _<mark>`ERC6909TokenSupply._update`</mark>_ _to try to create an inconsistency, we beleive_

_this is unlikelly to happen in real usage of the contract._


_In this case we prefer optimizing gas usage of the huge majority of "clean" inheritance_

_(including overrides that simply call_ _<mark>`super._update`</mark>_ _as we recomand in our good_

_practices). Complex (and malicious) overrides fall under the responsability of the_

_developper._

### **L-03 Missing and Misleading Documentation**


Throughout the codebase, multiple instances of misleading comments were identified:













Both the <u><mark>`[approve](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/draft-ERC6909.sol#L47-L51)`</mark></u> <u>function in</u> <u><mark>`[draft-ERC6909.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/draft-ERC6909.sol#L47-L51)`</mark></u> [and the corresponding interface](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/interfaces/draft-IERC6909.sol#L51-L56)

lack documentation on how to make infinite approvals, which is to set the allowance to

<mark>`type(uint256).max`</mark> <mark>.</mark>

[The docstring](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/draft-ERC6909.sol#L98-L103) on the <mark>`_transfer`</mark> function in <mark>`draft-ERC6909.sol`</mark> is contradictory as

it <u>[first suggests an override, but later states that](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/draft-ERC6909.sol#L98-L99)</u> <u><mark>`[_update](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/draft-ERC6909.sol#L103)`</mark></u> <u>[should be overridden](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/draft-ERC6909.sol#L103)</u> for

custom functionality instead.

[The ERC-6909 spec](https://eips.ethereum.org/EIPS/eip-6909#approvals-and-operators) does not specify whether allowance should be consumed despite

the operator status. The implementation is opinionated by _not_ consuming the allowance

[for operators, which could be documented.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/interfaces/draft-IERC6909.sol#L72-L77)

In <u><mark>`[GovernorVotesSuperQuorumFraction.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/governance/extensions/GovernorVotesSuperQuorumFraction.sol)`</mark></u> <mark>,</mark> it is not explicitly mentioned that

only "for" votes count towards the super quorum. While this is mentioned in the

<u><mark>`[GovernorSuperQuorum](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/governance/extensions/GovernorSuperQuorum.sol#L15-L17)`</mark></u> <u>parent contract, consider explicitly mentioning this in</u>

<mark>`GovernorVotesSuperQuorumFraction`</mark> as well for clarity.


OpenZeppelin Contracts Release v5.3 Diff Audit − Low Severity − 9


The comment in line 29 of <u><mark>`[draft-ERC6909TokenSupply.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/token/ERC6909/extensions/draft-ERC6909TokenSupply.sol#L29)`</mark></u> states "_balances[id]

[from]", but it should be changed to state "_balances[from][id]".



Consider adding comments and revising the aforementioned ones to improve consistency and

more accurately reflect the implemented logic, making it easier for auditors and other parties

examining the code to understand what each section of code is designed to do.


**_Update:_** _Partially resolved in_ _<u>[pull request #5584](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5584)</u>_ _[at commit 803dff6. Bullet point 3 regarding](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5584/commits/803dff6a8f8d4e3d283087144702109ae6b0665e)_

_additional ERC-6909 allowance documentation was not addressed._

## **Notes & Additional** **Information**

### **N-01 Typography Errors**


Throughout the codebase, multiple instances of typography errors were identified:









The documentation of the <mark>`Bytes32x2Set`</mark> struct and functions refers to itself as "in the

[self" [1, 2, 3],](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/utils/structs/EnumerableSet.sol#L428) <u>["to a self", "from a self", and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/utils/structs/EnumerableSet.sol#L433)</u> <u>["on the self". Consider removing "a" or "the",](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/utils/structs/EnumerableSet.sol#L517)</u>

or changing "self" to "set".

[The comment in line 181](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/utils/structs/MerkleTree.sol#L181) of <mark>`MerkleTree.sol`</mark> states "for the leaf being update".

Consider changing it to "for the leaf being updated".



Consider correcting the above typographical errors to improve the clarity and readability of the

codebase.


**_Update:_** _[Resolved in pull request #5584](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5584)_ _[at commit 24ee8a6](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5584/commits/24ee8a68468e26124aca2ba1dc29c0d5ef7a8ee0)_ _as well as commit_ _<u>[bfdbb67. The](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/bfdbb67ebcf1447d6e4c31644511c8af2b4ac188)</u>_

_Solidity Contracts team stated:_


_<mark>`Bytes32x2Set`</mark>_ _[was removed in commit bfdbb67.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/bfdbb67ebcf1447d6e4c31644511c8af2b4ac188)_

### **N-02 escapeJSON Escapes All Unicode** **Characters**


In order to prevent JSON injection, the <u><mark>`[escapeJSON](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/utils/Strings.sol#L442)`</mark></u> <u>function</u> of the <mark>`Strings`</mark> library takes a

JSON string as the input to then escape certain characters (e.g., in NFT metadata). Thus,


OpenZeppelin Contracts Release v5.3 Diff Audit − Notes & Additional

Information − 10


<u>[control characters, backslashes, and quotation marks](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d4b2e98c737f54a21961b39d6bba13b839f3b6f4/contracts/utils/Strings.sol#L18-L25)</u> are escaped by prepending a backslash.

This prevents breaking out of the value's string context and adding additional key-value pairs

of the JSON object.


Regarding Unicode characters specifically, defined as <mark>`\uXXXX`</mark> (where <mark>`XXXX`</mark> is a 2-byte

[hexadecimal value), section 2.5 of RFC-4627](https://www.ietf.org/rfc/rfc4627.txt) requires escaping for specific ranges:









Control Characters: U+0000 to U+001F

Quotation Marks: U+0022

Backslash ("reverse solidus"): U+005C



The <mark>`escapeJSON`</mark> function does not handle these cases separately but instead escapes all

backslashes and, therefore, also **all** Unicode characters. This behavior, while compliant with

the spec, can be inconvenient for front-end applications that rely on native Unicode

representations. Extra escaping forces these systems to perform additional decoding steps,

which can lead to rendering inconsistencies or increased processing overhead. In contexts

where precise handling and display of Unicode characters are critical - such as in languages

that require specific symbols - the automatic doubling of backslashes may introduce

challenges for correct interpretation and localization.


While the existing approach is secure, consider relaxing the escape rule by not escaping

Unicode characters for the allowed ranges. Alternatively, consider documenting this escape

rule in the codebase for improved clarity.


**_Update:_** _[Resolved in pull request #5584](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5584)_ _[at commit 02a6c25. The Solidity Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5584/commits/02a6c257155752c657c38b99c39e58b15d01ff19)_

_decided to add a comment about this behavior._


OpenZeppelin Contracts Release v5.3 Diff Audit − Notes & Additional

Information − 11


## **Conclusion**

The v5.3 release of OpenZeppelin Contracts introduces support for ERC-6909, optional

enhancements for governance, and updated functionality for certain utilities. We commend the

Solidity Contracts team for addressing user needs by incorporating new standards, enhancing

existing features, and adding new utilities.


During the audit, particular care was taken to document edge cases, ensuring that integrators

are informed of potential risks when interacting with these contracts. Such efforts aim to create

a more resilient codebase, recognizing the library’s critical role as a foundational component

within the blockchain ecosystem. The Contracts team has demonstrated a strong commitment

to maximizing the library's security, and we are glad to have collaborated with them on this

milestone.


OpenZeppelin Contracts Release v5.3 Diff Audit − Conclusion − 12


