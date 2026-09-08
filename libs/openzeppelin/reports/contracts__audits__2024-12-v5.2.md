### | security

# **OpenZeppelin** **Contracts** **Release v5.2** **Audit**

#### **December 4, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  6

Account Abstraction 6

Cross-Chain Messaging 6

Governance 7

Clones 7

Utils 7


Security Model and Trust Assumptions _______________________________________________  8


Medium Severity ___________________________________________________________________  9

M-01 Improper Input Validation Leads to Incorrect Parsing Results 9

M-02 Unbounded Memory Access Within Memory-Safe Assembly 10


Low Severity ____________________________________________________________________ 10

L-01 Inconsistent Use of MCOPY Opcode 10

L-02 Possible Incorrect Updates to Voting Units Balance Checkpoints 11

L-03 Different Pragma Directives 12

L-04 Override Votes Do Not Count As Having Voted 12

L-05 Potentially Incorrect Hashing of User Operations 13

L-06 Nonce Key Not Included in InvalidAccountNonce 14

L-07 Inconsistent Format in Returned Nonces 14

L-08 Misleading and Incomplete Documentation 15

L-09 Missing Docstrings 15

L-10 Incomplete Docstrings 16


Notes & Additional Information ____________________________________________________ 18

N-01 Incomplete Account Utility Libraries 18

N-02 Duplicated Logic 18

N-03 Constant Visibility Not Explicitly Declared 19

N-04 Unused Imports 19

N-05 Typographical Errors 19

N-06 Redundant Code 20

N-07 Code Clarity 20


Client Reported __________________________________________________________________ 21

CR-01 Case-Sensitivity in CAIP-10 Identifiers 21


OpenZeppelin Contracts Release v5.2 Audit − Table of Contents − 2


Conclusion ______________________________________________________________________ 22


OpenZeppelin Contracts Release v5.2 Audit − Table of Contents − 3


## **Summary**

**Type** Library


**Timeline** From 2024-10-21
To 2024-11-06


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


2 (2 resolved)



**Total Issues** 20 (19 resolved)



**Low Severity Issues** 10 (9 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



7 (7 resolved)


1 (1 resolved)



OpenZeppelin Contracts Release v5.2 Audit − Summary − 4


## **Scope**

We audited the <u>[OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/)</u> repository at commit <u>[98d28f9. The](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5)</u>

following files were in scope:

```
contracts/
├── account
│  └── utils
│    ├── draft-ERC4337Utils.sol
│    └── draft-ERC7579Utils.sol
├── governance
│  ├── Governor.sol
│  ├── extensions
│  │  ├── GovernorCountingOverridable.sol
│  │  └── GovernorPreventLateQuorum.sol
│  └── utils
│    └── VotesExtended.sol
├── interfaces
│  ├── draft-IERC4337.sol
│  └── draft-IERC7579.sol
├── proxy
│  └── Clones.sol
├── token
│  └── ERC20
│    ├── extensions
│    │  └── ERC1363.sol
│    └── utils
│      └── ERC1363Utils.sol
└── utils
├── Bytes.sol
├── CAIP10.sol
├── CAIP2.sol
├── NoncesKeyed.sol
└── Strings.sol

```

OpenZeppelin Contracts Release v5.2 Audit − Scope − 5


## **System Overview**

Version 5.2 of the OpenZeppelin Contracts library introduces new utilities designed to facilitate

account abstraction and cross-chain messaging, along with a new counting module in the

governance contracts.

### **Account Abstraction**


This release includes utility functions for <u>[ERC-4337](https://eips.ethereum.org/EIPS/eip-4337)</u> - the most widely adopted standard for

account abstraction — as well as <u>[ERC-7579, a newer standard for minimal, modular smart](https://eips.ethereum.org/EIPS/eip-7579)</u>

accounts. The <u><mark>`[ERC4337Utils](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol)`</mark></u> library offers functionality for handling the validation data

returned by accounts during signature validation, for hashing user operations, and for

unpacking specific values from the <mark>`PackedUserOperation`</mark> struct defined in ERC-4337.


In contrast, the <u><mark>`[ERC7579Utils](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol)`</mark></u> library provides functionality for encoding, decoding, and

executing various call types defined in the standard, including single, batch, and delegate calls.

It also includes constants and custom types that simplify working with the packed execution

mode specified in ERC-7579. Additionally, this release includes all interfaces necessary to

integrate with these standards.

### **Cross-Chain Messaging**


[Chain Agnostic Improvement Proposals (CAIPs) describe standards for blockchain projects](https://github.com/ChainAgnostic/CAIPs)

that are not specific to a single chain. In particular, CAIP-2 defines a way to uniquely identify a

blockchain (e.g., Ethereum, Bitcoin, Cosmos Hub) in a human-readable, developer-friendly and

transaction-friendly way, while CAIP-10 defines a way to identify an account in any blockchain

specified by a CAIP-2 blockchain ID. This is useful for both decentralized applications and

wallets to communicate user accounts or smart contracts across multiple chains using string

identifiers specific to each chain. To parse and format identifiers as defined by these CAIPs,

the <u><mark>`[CAIP2](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/CAIP2.sol)`</mark></u> and <u><mark>`[CAIP10](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/CAIP10.sol)`</mark></u> libraries were introduced in this release.


OpenZeppelin Contracts Release v5.2 Audit − System Overview − 6


### **Governance**

The governance framework has been enhanced with the introduction of the <u><mark>`[_tallyUpdated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/Governor.sol#L268)`</mark></u>

<mark>`internal`</mark> <mark>`virtual`</mark> hook. This hook is designed to be called whenever a proposal's vote

tally is updated, providing a customizable point for executing additional logic in response to

changes in vote counts. The <u><mark>`[GovernorPreventLateQuorum](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorPreventLateQuorum.sol)`</mark></u> contract was slightly

refactored to leverage the <mark>`_tallyUpdated`</mark> hook to address scenarios where the quorum is

reached late in the voting period. By detecting when the tally update results in a quorum being

achieved, it can extend the voting deadline, ensuring that all stakeholders have ample

opportunity to participate. This logic was previously placed in a <mark>`_castVote`</mark> override.


Motivated by the need to accommodate more complex voting scenarios, the

<u><mark>`[GovernorCountingOverridable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol)`</mark></u> module introduces functionality that allows delegators to

override the votes of their delegates. This module, which necessitated the introduction of the

<mark>`_tallyUpdated`</mark> hook, supports two <mark>`internal`</mark> count functions to manage both standard

and override votes. To support the override counting module, the <u><mark>`[VotesExtended](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol)`</mark></u> contract

extends the <u><mark>`[Votes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/Votes.sol)`</mark></u> contract by adding checkpoints for delegations and voting units over time.

This feature is essential for the <mark>`GovernorCountingOverridable`</mark> module, as it relies on

historical data to accurately process vote overrides and ensure the governance system's

integrity.

### **Clones**


The <u><mark>`[Clones](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/proxy/Clones.sol)`</mark></u> library has been enhanced to support the deployment of minimal proxies with

immutable arguments. These arguments are provided through a bytes array and appended to

the bytecode before deployment through <mark>`CREATE`</mark> or <mark>`CREATE2`</mark> <mark>.</mark> The arguments can be

fetched in the implementation contract using the <mark>`fetchCloneArgs`</mark> function, which is a

cheaper alternative to using storage for instance-specific data that can or must be immutable.

### **Utils**


In the <u><mark>`[Strings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol)`</mark></u> library, new functions have been added to parse both signed and unsigned

integers, hex strings, as well as Ethereum addresses. In addition, a <u><mark>`[Bytes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Bytes.sol)`</mark></u> library was created

to support byte-specific operations, such as finding the index of a specific byte within a buffer

or creating slices from a buffer. These byte operations are designed to mimic the behavior of

their JavaScript counterparts, providing developers with a familiar interface.


OpenZeppelin Contracts Release v5.2 Audit − System Overview − 7


The <u><mark>`[NoncesKeyed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol)`</mark></u> contract is an abstract extension of the <u><mark>`[Nonces](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Nonces.sol)`</mark></u> contract, designed to

support keyed nonces in accordance with the <u>[ERC-4337 semi-abstracted nonce](https://eips.ethereum.org/EIPS/eip-4337#semi-abstracted-nonce-support)</u> system. It

implements a mapping structure to manage nonces on a per-key basis for each address,

offering functions to retrieve and increment nonces. This contract allows for differentiated

nonce management, accommodating scenarios where transactions might require distinct

nonce spaces identified by keys.


Lastly, the <u><mark>`[ERC1363](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/token/ERC20/extensions/ERC1363.sol)`</mark></u> contract has been refactored by moving its post-transfer and post
approval callback logic into a new <u><mark>`[ERC1363Utils](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/token/ERC20/utils/ERC1363Utils.sol)`</mark></u> library.

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


OpenZeppelin Contracts Release v5.2 Audit − Security Model and Trust

Assumptions − 8


## **Medium Severity**

### **M-01 Improper Input Validation Leads to** **Incorrect Parsing Results**

The <u><mark>`[Strings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L13)`</mark></u> library includes functions to parse integers and addresses from their string

representation. However, some of these functions may produce valid results even when given

invalid inputs. Specifically:


   - The <u><mark>`[tryParseAddress](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L352)`</mark></u> function validates the input length <u>[using only](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L361)</u> the <mark>`begin`</mark> and

<mark>`end`</mark> parameters, without actually checking the length of the <mark>`input`</mark> parameter itself.

Combined with the fact that <u><mark>`[tryParseHexUint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L292)`</mark></u> succeeds even when the <mark>`end`</mark>

parameter is greater than the input length, this might cause addresses shorter than the

expected length to parse successfully, which contradicts the <u>[function's intended](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L349C67-L350C25)</u>

<u>[specification.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L349C67-L350C25)</u>

   - The <u><mark>`[tryParseUint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L170)`</mark></u> and <u><mark>`[tryParseHexUint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L292)`</mark></u> functions return a success status with a

`0` value if the <mark>`begin`</mark> parameter is greater than or equal to the <mark>`end`</mark> parameter. For

example, empty strings (or <mark>`0x`</mark> hex strings) are successfully parsed as `0`, which

contrasts with the expected behavior in other languages like JavaScript, where

<u><mark>`[parseInt("")](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/parseInt)`</mark></u> returns <mark>`NaN`</mark> <mark>.</mark>


To prevent the parsing of invalid inputs, consider enforcing stricter validation checks on input

lengths and parsing bounds.


**_Update:_** _Resolved in_ _<u>[pull request #5304](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5304)</u>_ _at commit_ _<u>[d5e388e](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5304/commits/d5e388e975427e65feb603cb8a87ff3f8cd30257)</u>_ _and_ _<u>[pull request #5324](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5324)</u>_ _at commit_

_<u>[3fcb9da. The Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5324/commits/3fcb9dafe0df4bdb99ee2b4b1f8b22723cf0be31)</u>_


_The team decided to fix the_ _<mark>`tryParseAddress`</mark>_ _together with M-02 by abstracting the_

_implementation of the_ _<mark>`tryParseUint`</mark>_ _<mark>,</mark>_ _<mark>`tryParseInt`</mark>_ _<mark>,</mark>_ _and_ _<mark>`tryParseHexUint`</mark>_ _into_

_a private function that does not check for bounds. This way, bounds are checked only_

_when necessary in other functions._


_Regarding the inconsistency with the_ _<mark>`tryParseUint`</mark>_ _and_ _<mark>`tryParseHexUint`</mark>_

_functions. We think this behavior is consistent with the way the EVM defaults to 0 when_

_there is no data, and there is no other representation of a_ _<mark>`NaN`</mark>_ _in this context, so we are_

_keeping this behavior._


OpenZeppelin Contracts Release v5.2 Audit − Medium Severity − 9


### **M-02 Unbounded Memory Access Within** **Memory-Safe Assembly**

The <u><mark>`[_unsafeReadBytesOffset](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L394)`</mark></u> function in the <mark>`Strings`</mark> library reads a <mark>`bytes32`</mark> value

from a <mark>`bytes`</mark> array. Since it delegates the bound checking to the caller, it does so within a

memory-safe assembly block and without checking bounds. However, none of the other

functions in the library that call <mark>`_unsafeReadBytesOffset`</mark> <u>[perform any validation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L171-L179)</u> of the

offset that is used to read from the bytes array. Specifically, none of the functions validate that

the offset falls inside the length of the array, which <u>[can lead](https://docs.soliditylang.org/en/v0.8.28/assembly.html#memory-safety:~:text=this%20will%20lead%20to%20incorrect%20and%20undefined%20behavior%20that%20cannot%20easily%20be%20discovered%20by%20testing)</u> to incorrect and undefined

behavior that cannot easily be discovered by testing. Note that some functions use

<mark>`_unsafeReadBytesOffset`</mark> to <u>[read more than one byte](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol#L300)</u> from the array, so that has to be

accounted for as well when validating the offset.


Consider ensuring that <mark>`_unsafeReadBytesOffset`</mark> is only called with offsets that fall within

the allocated memory of the <mark>`buffer`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #5304](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5304)</u>_ _at commit_ _<u>[d5e388e](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5304/commits/d5e388e975427e65feb603cb8a87ff3f8cd30257)</u>_ _and_ _<u>[pull request #5324](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5324)</u>_ _at commit_

_<u>[3fcb9da. The Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5324/commits/3fcb9dafe0df4bdb99ee2b4b1f8b22723cf0be31)</u>_


_The functions using_ _<mark>`_unsafeReadBytesOffset`</mark>_ _<mark>(</mark>_ _<mark>`tryParseUint`</mark>_ _<mark>,</mark>_ _<mark>`tryParseInt`</mark>_

_and_ _<mark>`tryParseHexUint`</mark>_ _<mark>)</mark>_ _were split into a private version that does not check for_

_bounds, so that it is used when these can be assumed safe._

## **Low Severity**

### **L-01 Inconsistent Use of MCOPY Opcode**


The <mark>`MCOPY`</mark> opcode was introduced with the Cancun chain upgrade, enabling the copying of

one memory space to another. However, since the opcode is still relatively new and may not be

supported across all chains, the <u><mark>`[_cloneCodeWithImmutableArgs](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/proxy/Clones.sol#L247)`</mark></u> <u>function</u> of the <mark>`Clones`</mark>

library has been implemented using <mark>`abi.encodePacked`</mark> <mark>.</mark> Yet, despite this effort for

compatibility, the <u><mark>`[slice](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Bytes.sol#L88)`</mark></u> <u>function</u> of the <mark>`Bytes`</mark> library still utilizes this opcode.


Consider clarifying whether the 5.2 release should use the <mark>`MCOPY`</mark> opcode.


**_Update:_** _Acknowledged, not resolved. The Contracts team stated:_


OpenZeppelin Contracts Release v5.2 Audit − Low Severity − 10


_In_ _<mark>`_cloneCodeWithImmutableArgs`</mark>_ _<mark>,</mark>_ _we are building a bytes object. We decided to_

_use a more "natural" solidity version that the compiler is free to compile to whatever it_

_wants. The compiler may decide to use mcopy is the targeted EVM version supports it._


_<mark>`Bytes.slice`</mark>_ _is a bit different because solidity does not provide a high level version of_

_it. The few choices we have are:_


       - _writting a for loop in solidity_

       - _writting a for loop in assembly_

       - _using the identity precompile_

       - _using mcopy_


_We believe that the first two options are are not optimal. Also, because using the identity_

_precompile is more expensive than using mcopy, we decided to use mcopy. This indeed_

_prevents using this code with a target older than Cancun. Having a second version of_

_the function (that uses the precompile) is not really a possibility because:_


       - _a compiler would refuse to compile Bytes.sol with a version before Cancun, even_

_if_ _<mark>`slice`</mark>_ _is not used and only_ _<mark>`slicePrecompile`</mark>_ _is called by the user._

       - _we would have to duplicate all implementation that call that function directly or_

_indirectly._


_We believe the impact of this issue is limited. Only the new code uses Bytes.sol, so this_

_implementation is not breaking anything older. The pragma requires using of the recent_

_version of the compiler (as referenced in our "documentation"), and the compiler throws_

_very clear errors if a user tries to compile this code with an older EVM target. Ultimately,_

_using an unsupported target should be identified by any serious testing done by the_

_user._

### **L-02 Possible Incorrect Updates to Voting Units** **Balance Checkpoints**


The <u><mark>`[_transferVotingUnits](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/Votes.sol#L180)`</mark></u> function of the <mark>`Votes`</mark> contract is in charge of transferring,

minting, and burning voting units. It can be used by contracts extending <mark>`Votes`</mark> to track

changes in the distribution of these units. For example, <mark>`_transferVotingUnits`</mark> is <u>[called](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/token/ERC20/extensions/ERC20Votes.sol#L57)</u>

within <mark>`ERC20Votes`</mark> immediately after a transfer. However, in <mark>`VotesExtended`</mark> <mark>,</mark>

<mark>`_transferVotingUnits`</mark> is <u>[overridden](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L59)</u> to update the <mark>`_balanceOfCheckpoints`</mark> mapping

using the <u><mark>`[_getVotingUnits](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/Votes.sol#L250)`</mark></u> function to create a new checkpoint. This introduces a key

difference in how <mark>`_transferVotingUnits`</mark> should be used in derived contracts compared

to <mark>`Votes`</mark> <mark>.</mark> For instance, if an ERC-20 contract extends <mark>`VotesExtended`</mark> <mark>,</mark>


OpenZeppelin Contracts Release v5.2 Audit − Low Severity − 11


<mark>`_getVotingUnits`</mark> will produce different values depending on whether it is called before or

after the ERC-20 balance update. Thus, in <mark>`VotesExtended`</mark> <mark>,</mark> <mark>`_transferVotingUnits`</mark>

must be called after the balance changes to ensure accurate checkpoint updates, while in

<mark>`Votes`</mark> <mark>,</mark> it can be used before or after without any issue.


To prevent misuse, consider comprehensively documenting the aforementioned distinction,

emphasizing the order of execution of the internal functionalities.


**_Update:_** _Resolved in_ _<u>[pull request #5306](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5306)</u>_ _at commit_ _<u>[334b617.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5306/commits/334b617fa35604aab3a0a6c8623423c3da1949ef)</u>_

### **L-03 Different Pragma Directives**


In order to clearly identify the Solidity version with which the contracts will be compiled,

pragma directives should be consistent across file imports. Throughout the codebase, multiple

instances of varying pragma directives being used were identified:











<mark>`CAIP10.sol`</mark> has the <u><mark>`[pragma solidity ^0.8.24;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/CAIP10.sol#L3)`</mark></u> pragma directive and imports

<u><mark>`[Strings.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol)`</mark></u> <mark>,</mark> which has a different pragma directive.

<mark>`CAIP2.sol`</mark> has the <u><mark>`[pragma solidity ^0.8.24;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/CAIP2.sol#L3)`</mark></u> pragma directive and imports

<u><mark>`[Strings.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol)`</mark></u> <mark>,</mark> which has a different pragma directive.

<mark>`Bytes.sol`</mark> has the <u><mark>`[pragma solidity ^0.8.24;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Bytes.sol#L3)`</mark></u> pragma directive and imports

<u><mark>`[Math.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/math/Math.sol)`</mark></u> <mark>,</mark> which has a different pragma directive.



Consider using the same pragma version in all files.


**_Update:_** _Resolved. The Contracts team stated:_


_<mark>`Bytes.sol`</mark>_ _uses_ _<mark>`mcopy`</mark>_ _which is only supported since 0.8.24. This is why_

_<mark>`Bytes.sol`</mark>_ _(and_ _<mark>`CAIP2.sol`</mark>_ _and_ _<mark>`CAIP10.sol`</mark>_ _that depends on_ _<mark>`Bytes.sol`</mark>_ _<mark>)</mark>_ _all_

_require ^0.8.24 when other files are less restrictives._


_Note that_ _<mark>`ReentrancyGuardTransient.sol`</mark>_ _<mark>,</mark>_ _<mark>`draft-`</mark>_

_<mark>`ERC20TemporaryApproval.sol`</mark>_ _and_ _<mark>`TransientSlot.sol`</mark>_ _have a similar_

_requirement because of tstore/tload being introduced in 0.8.24_

### **L-04 Override Votes Do Not Count As Having** **Voted**


The <u><mark>`[GovernorCountingOverridable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L14)`</mark></u> governance module enables users (delegators) who

have delegated their voting units to another account (delegate) to override that account's


OpenZeppelin Contracts Release v5.2 Audit − Low Severity − 12


decision. This is achieved by <u>[tracking voting units and delegates](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L16-L17)</u> over time for each account.

As a result, the delegator can override the delegate's decision by reallocating their voting

weight, effectively reducing the delegate's voting power based on the proposal's snapshot.


However, when a user <u>[casts an override vote, their support is not tracked in the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L124)</u> <mark>`casted`</mark> field

of the <mark>`VoteReceipt`</mark> struct. Hence, when evaluating <mark>`casted`</mark> to determine whether the user

<u>[has voted, the returned value will be](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L57)</u> <mark>`false`</mark> <mark>.</mark> This is misleading and can be misinterpreted by

extending contract logic. Furthermore, it is worth noting that the <mark>`overridenWeight`</mark> field in

the receipt is not tracked <u>[if a delegate has already voted, although this is not a problem as long](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L145-L147)</u>

as there is no getter and the <u>[mapping remains private.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L43)</u>


Consider moving the logic of the <mark>`hasVoted`</mark> function into a new <mark>`hasVotedDelegated`</mark>

function and redefining <mark>`hasVoted`</mark> to return the boolean <mark>`OR`</mark> of <mark>`hasVotedDelegated`</mark> and

<mark>`hasVotedOverride`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #5309](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5309)</u>_ _at commit_ _<u>[1c762d8. The](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5309/commits/1c762d8199f90043a0022f69138e50413ac8224d)</u>_ _<mark>`hasVoted`</mark>_ _logic remains,_

_while documentation was added. The Contracts team stated:_


_The design of_ _<mark>`GovernorCountingOverridable`</mark>_ _purposely separates regular votes_

_from overridden votes. The rationale is that both workflows are parallel._


_For example, Alice may be a delegate for Bob and Charles while Alice herself could_

_delegate to Daniel. In this scenario, Alice can override Daniel's delegation (Alice own_

_tokens) regardless of Daniel's vote, whereas Alice could vote with the delegated power_

_of Bob and Charles._


_We are documenting this behavior more thoroughly. However, we consider merging both_

_delegation votes and overridden votes in the_ _<mark>`hasVote`</mark>_ _function may be an issue for off-_

_chain integrations that may assume that the user already voted after an override, when_

_they can still cast their vote as in the case of Alice._

### **L-05 Potentially Incorrect Hashing of User** **Operations**


The <u><mark>`[hash](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L80)`</mark></u> function of the <mark>`ERC4337Utils`</mark> library is intended to compute the hash of a user

operation using the ERC-4337 entrypoint's address and the chain ID. However, the <u>[variant](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L75)</u> of

this function that only takes the user operation as input <u>uses</u> <u><mark>`[address(this)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L76C27-L76C40)`</mark></u> for the

entrypoint's address, although the library is not designed to be used only by entrypoint

implementations. As a result, hashes generated by this function will be invalid if generated by

non-entrypoint contracts, leading to accounts rejecting signatures based on such hashes.


OpenZeppelin Contracts Release v5.2 Audit − Low Severity − 13


Consider having the entrypoint's address as a parameter in both variants of the <mark>`hash`</mark>

function.


**_Update:_** _Resolved in_ _<u>[pull request #5308](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308)</u>_ _at commit_ _<u>[1816bb2. The](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308/commits/1816bb2db07dcf8148912163e07f037b1e3061ad)</u>_ _<mark>`hash`</mark>_ _function specifying_

_<mark>`address(this)`</mark>_ _as the entrypoint was removed._

### **L-06 Nonce Key Not Included in** **`InvalidAccountNonce`**


The <u><mark>`[NoncesKeyed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L11)`</mark></u> contract extends <mark>`Nonces`</mark> to add support for keyed nonces, where each

nonce is composed of a "key" and a "sequence". In the <u><mark>`[_useCheckedNonce](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L50)`</mark></u> function,

<mark>`NoncesKeyed`</mark> reuses the inherited <u><mark>`[InvalidAccountNonce](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L56)`</mark></u> <u>error. However, this error does</u>

not include details about the specific key causing the revert, thereby hindering code

auditability.


Consider implementing a new <mark>`InvalidAccountNonce`</mark> error that includes information about

the key that was responsible for the failure.


**_Update:_** _Resolved in_ _<u>[pull request #5312](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5312)</u>_ _at commit_ _<u>[d977260. The key is now prepended to the](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5312/commits/d97726064665db93f52ab58a0ec66230df9816d9)</u>_

_sequential nonce when reverting with the existing_ _<mark>`InvalidAccountNonce`</mark>_ _error._

### **L-07 Inconsistent Format in Returned Nonces**


In the <u><mark>`[NoncesKeyed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L11)`</mark></u> contract, both the <u><mark>`[nonces](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L15)`</mark></u> and <u><mark>`[_useNonce](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L25)`</mark></u> functions return the next

unused nonce for a given address and key. However, the <mark>`nonces`</mark> function <u>[prepends](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L16)</u> the key

to the sequential nonce, while <mark>`_useNonce`</mark> <u>[does not. The](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L30)</u> <mark>`_useNonce`</mark> function is also

commonly used in EIP-712 type hashes (e.g., <u><mark>`[ERC20Permit](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/token/ERC20/extensions/ERC20Permit.sol#L57)`</mark></u> <mark>)</mark> . Using the nonce without

prepending the key would be less intuitive in this context and even raises replayability

concerns.


To improve consistency, consider always returning the nonce with the prepended key.


**_Update:_** _Resolved in_ _<u>[pull request #5312](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5312)</u>_ _at commit_ _<u>[d977260.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5312/commits/d97726064665db93f52ab58a0ec66230df9816d9)</u>_


OpenZeppelin Contracts Release v5.2 Audit − Low Severity − 14


### **L-08 Misleading and Incomplete Documentation**

Throughout the codebase, multiple instances of misleading documentation were identified:


   - The documentation for the <u><mark>`[_useCheckedNonce](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L41)`</mark></u> function states that it accepts a nonce

as a single <mark>`uint256`</mark> parameter, with the first 8 bytes representing the key and the

remaining 24 bytes representing the nonce. However, the key is actually 24 bytes long,

while the nonce is 8 bytes.

   - The <u>[documentation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/proxy/Clones.sol#L165-L167)</u> for the <mark>`cloneDeterministicWithImmutableArgs`</mark> function

states that multiple clones under the same implementation address and salt will revert.

This must not be true because the immutable arguments become part of the bytecode

and thereby influence the deployed address. Thus, it is possible to reuse the same

implementation address and salt provided that the immutable arguments are changed.

   - Within the <mark>`PackedUserOperation`</mark> struct, the <u><mark>`[maxPriorityFeePerGas](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L16)`</mark></u> is referred

to as <u><mark>`[maxPriorityFee](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L41)`</mark></u> <mark>.</mark>

   - The <u><mark>`[paymasterAndData](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L42)`</mark></u> <u>feldi</u> of the <mark>`PackedUserOperation`</mark> struct does not

indicate the size of the <mark>`paymasterVerificationGasLimit`</mark> and

<mark>`paymasterPostOpGasLimit`</mark> data, while the <u>[getter functions](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L141-L149)</u> suggest that they are

encoded with 16 bytes each.

   - The term "delegatee" should be replaced with "delegator" when referring to users who

delegate their voting power. This is because "delegatee" actually means the recipient (or

delegate) rather than the initiator of delegation. This adjustment should be made in the

docstring for <u><mark>`[GovernorCountingOverridable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L11C47-L11C57)`</mark></u> and in the

<u><mark>`[_delegateCheckpoints](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L16)`</mark></u> mapping.


Consider correcting the aforementioned comments to improve the overall clarity and readability

of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5310](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5310)</u>_ _at commit_ _<u>[ff30cd4](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5310/commits/ff30cd42fcb791d62e9a94341495eb82b28f140f)</u>_ _and_ _<u>[pull request #5324](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5324)</u>_ _at commit_

_<u>[737d0e1.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5324/commits/737d0e14e54008ebf05c40775421f588dade933a)</u>_

### **L-09 Missing Docstrings**


Throughout the codebase, multiple instances of missing docstrings were identified:


   - In <mark>`GovernorCountingOverridable.sol`</mark> <mark>:</mark>

     - The <u><mark>`[OVERRIDE_BALLOT_TYPEHASH](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L15-L16)`</mark></u> <u>state variable</u>

     - The <u><mark>`[VoteReduced](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L38)`</mark></u> <u>event</u>

     - The <u><mark>`[OverrideVoteCast](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L39)`</mark></u> <u>event</u>

     - The <u><mark>`[GovernorAlreadyOverridenVote](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L41)`</mark></u> <u>error</u>


OpenZeppelin Contracts Release v5.2 Audit − Low Severity − 15


   - In <mark>`draft-IERC7579.sol`</mark> <mark>:</mark>

     - The <u><mark>`[IERC7579Module](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L13-L37)`</mark></u> <u>interface</u>

     - The <u><mark>`[IERC7579Validator](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L39-L64)`</mark></u> <u>interface</u>

     - The <u><mark>`[IERC7579Hook](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L66-L88)`</mark></u> <u>interface</u>

     - The <u><mark>`[IERC7579Execution](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L96-L120)`</mark></u> <u>interface</u>

     - The <u><mark>`[IERC7579AccountConfig](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L122-L149)`</mark></u> <u>interface</u>

     - The <u><mark>`[IERC7579ModuleConfig](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L151-L196)`</mark></u> <u>interface</u>

     - The <u><mark>`[ModuleInstalled](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L152)`</mark></u> <u>event</u>

     - The <u><mark>`[ModuleUninstalled](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L153)`</mark></u> <u>event</u>


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not public, should

be clearly documented as well. When writing docstrings, consider following the <u>[Ethereum](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u>

<u>[Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #5311](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5311)</u>_ _at commit_ _<u>[fa9a059. The Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5311/commits/fa9a059d60c713f8eddfade56f70fd5cca37b15f)</u>_


_We are not adding documentation for_ _<mark>`OVERRIDE_BALLOT_TYPEHASH`</mark>_ _<mark>,</mark>_ _which is_

_consistent with other typehashes across the library. Similarly, we are not documenting_

_the_ _<mark>`GovernorAlreadyOverriddenVote`</mark>_ _error given its clarity._

### **L-10 Incomplete Docstrings**


Throughout the codebase, multiple instances of incomplete docstrings were identified:


   - In <mark>`ERC1363.sol`</mark> <mark>:</mark>

      - In the <u><mark>`[transferAndCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/token/ERC20/extensions/ERC1363.sol#L60-L62)`</mark></u> function, the return value is not documented.

      - In the <u><mark>`[transferFromAndCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/token/ERC20/extensions/ERC1363.sol#L87-L89)`</mark></u> function, the return value is not documented.

      - In the <u><mark>`[approveAndCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/token/ERC20/extensions/ERC1363.sol#L119-L121)`</mark></u> function, the return value is not documented.




- In <mark>`GovernorCountingOverridable.sol`</mark> <mark>:</mark>




- In the <u><mark>`[proposalVotes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L70-L75)`</mark></u> function, the <mark>`proposalId`</mark> parameter and the return

value are not documented.

- In the <u><mark>`[castOverrideVote](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L172-L179)`</mark></u> function, the <mark>`proposalId`</mark> <mark>,</mark> <mark>`support`</mark>, and

<mark>`reason`</mark> parameters and the return value are not documented.

- In the <u><mark>`[castOverrideVoteBySig](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L182-L211)`</mark></u> function, the <mark>`proposalId`</mark> <mark>,</mark> <mark>`support`</mark>,

<mark>`voter`</mark> <mark>,</mark> <mark>`reason`</mark> <mark>,</mark> and <mark>`signature`</mark> parameters and the return value are not

documented.


OpenZeppelin Contracts Release v5.2 Audit − Low Severity − 16


- In <mark>`draft-ERC7579Utils.sol`</mark> <mark>:</mark>

   - In the <u><mark>`[ERC7579TryExecuteFail](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol#L40)`</mark></u> event, the <mark>`batchExecutionIndex`</mark> and

<mark>`result`</mark> parameters are not documented.




- In <mark>`draft-IERC7579.sol`</mark> <mark>:</mark>




- In the <u><mark>`[validateUserOp](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L48)`</mark></u> function, the return value is not documented.




- In the <u><mark>`[executeFromExecutor](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC7579.sol#L116-L119)`</mark></u> function, the return value is not documented.




- In <mark>`draft-IERC4337.sol`</mark> <mark>:</mark>




- In the <u><mark>`[validateUserOpSignature](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L53-L55)`</mark></u> function, the return value is not



documented.

      - In the <u><mark>`[handleOps](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L147)`</mark></u> function, the <mark>`beneficiary`</mark> parameter is not documented.

      - In the <u><mark>`[handleAggregatedOps](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L152-L155)`</mark></u> function, the <mark>`beneficiary`</mark> parameter is not

documented.

      - In the <u><mark>`[validateUserOp](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L165-L169)`</mark></u> function, the <mark>`userOp`</mark> <mark>,</mark> <mark>`userOpHash`</mark> <mark>,</mark> and

<mark>`missingAccountFunds`</mark> parameters and the return value are not documented.

      - In the <u><mark>`[validatePaymasterUserOp](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L200-L204)`</mark></u> function, the <mark>`userOp`</mark> <mark>,</mark> <mark>`userOpHash`</mark>, and

<mark>`maxCost`</mark> parameters and the return values are not documented.

      - In the <u><mark>`[postOp](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L209-L214)`</mark></u> function, the <mark>`mode`</mark> <mark>,</mark> <mark>`context`</mark> <mark>,</mark> <mark>`actualGasCost`</mark> <mark>,</mark> and

<mark>`actualUserOpFeePerGas`</mark> parameters are not documented.


Consider thoroughly documenting all functions/events (and their parameters or return values)

that are part of a contract's public API. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #5315](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5315)</u>_ _at commit_ _<u>[2eb856e](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5315/commits/2eb856e34e7dea32e94070fd82b7bb62597f7f8f)</u>_ _and_ _<u>[pull request #5324](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5324)</u>_ _at commit_

_<u>[10c7594.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5324/commits/10c7594721c8e2dfd19a89cf143e6508602c831d)</u>_


OpenZeppelin Contracts Release v5.2 Audit − Low Severity − 17


## **Notes & Additional** **Information**

### **N-01 Incomplete Account Utility Libraries**

The <mark>`ERC7579Utils`</mark> and <mark>`ERC4337Utils`</mark> libraries appear to be incomplete. The following

opportunities for completion were identified:


  - The ERC-7579 standard expects <u>[call types](https://eips.ethereum.org/EIPS/eip-7579#:~:text=callType%20%0x281%20byte%0x29%3A%200x00%20for%20a%20single%20call%2C%200x01%20for%20a%20batch%20call%2C%200xfe%20for%20staticcall%20and%200xff%20for%20delegatecall)</u> to execute a call, batch call, static call, or

delegatecall. However, the static call type <mark>(</mark> <mark>`0xFE`</mark> <mark>)</mark> is not listed among the <u>[other call type](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol#L24-L31)</u>

<u>[constants.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol#L24-L31)</u>

   - The <mark>`ERC4337Utils`</mark> library provides <u>[getter functions](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L106-L149)</u> to extract packed information from

the <u><mark>`[PackedUserOperation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L34)`</mark></u> <u>struct. However, there are no functions to extract the</u>

<mark>`factory`</mark> address and <mark>`factoryData`</mark> from the <mark>`initCode`</mark> field, or <mark>`paymasterData`</mark>

from the <mark>`paymasterAndData`</mark> field.


To improve developer utility, consider adding the aforementioned missing functionality to the

utility libraries.


**_Update:_** _Resolved in_ _<u>[pull request #5313](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5313)</u>_ _at commit_ _<u>[2eb1be1. The Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5313/commits/2eb1be16af7ca713b86f81b6d4894756894b10a0)</u>_


_The use case for the 0xFE call type in ERC-7579 is unclear. This may come in a further_

_version but we did not want to commit to this in 5.2 version._


_[The additional ERC4337Utils features were implemented in pull request #5313. This also](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5313)_

_included improving the existing paymaster getters in case the_ _<mark>`paymasterAndData`</mark>_

_field is empty._

### **N-02 Duplicated Logic**


In the <mark>`Votes`</mark> and <mark>`VotesExtended`</mark> contracts, the logic to validate a given timepoint against

the current timepoint is repeated across four functions: <u><mark>`[getPastVotes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/Votes.sol#L90-L93)`</mark></u> <mark>,</mark>

<u><mark>`[getPastTotalSupply](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L28-L31)`</mark></u> <mark>,</mark> <u><mark>`[getPastDelegate](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L28-L31)`</mark></u> <mark>,</mark> and <u><mark>`[getPastBalanceOf](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L44-L47)`</mark></u> <mark>.</mark>


Consider consolidating this duplicated logic into a reusable function to improve consistency

and readability.


**_Update:_** _Resolved in_ _<u>[pull request #5314](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5314)</u>_ _at commit_ _<u>[eb51fbc.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5314/commits/eb51fbc6624c7dda9335f97820e28684ab012f11)</u>_


OpenZeppelin Contracts Release v5.2 Audit − Notes & Additional Information

                                                - 18


### **N-03 Constant Visibility Not Explicitly Declared**

Within <u><mark>`[draft-ERC7579Utils.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol)`</mark></u> <mark>,</mark> multiple instances of constants lacking an explicitly

declared visibility were identified:


   - The <u><mark>`[CALLTYPE_SINGLE](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol#L25)`</mark></u> <u>state variable</u>

   - The <u><mark>`[CALLTYPE_BATCH](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol#L28)`</mark></u> <u>state variable</u>

   - The <u><mark>`[CALLTYPE_DELEGATECALL](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol#L31)`</mark></u> <u>state variable</u>

   - The <u><mark>`[EXECTYPE_DEFAULT](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol#L34)`</mark></u> <u>state variable</u>

   - The <u><mark>`[EXECTYPE_TRY](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC7579Utils.sol#L37)`</mark></u> <u>state variable</u>


For improved code clarity, consider always explicitly declaring the visibility of constants, even

when the default visibility matches the intended visibility.


**_Update:_** _Resolved in_ _<u>[pull request #5308](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308)</u>_ _at commit_ _<u>[fa30a20.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308/commits/fa30a20c52c42b7fdf5b5a1b55f41cbb869b5fef)</u>_

### **N-04 Unused Imports**


Throughout the codebase, multiple instances of unused imports were identified:


   - In <mark>`draft-ERC4337Utils.sol`</mark> <mark>,</mark> the <u><mark>`[IEntryPoint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L5C9-L5C20)`</mark></u> <u>import</u> is unused.

   - In the <u><mark>`[CAIP2](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/CAIP2.sol#L18)`</mark></u> and <u><mark>`[CAIP10](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/CAIP10.sol#L19)`</mark></u> libraries, the <mark>`SafeCast`</mark> library is unnecesarily imported

and used for the <mark>`uint256`</mark> type.


Consider removing unused imports to improve the overall clarity and readability of the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5308](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308)</u>_ _at commit_ _<u>[4c5935a.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308/commits/4c5935a2ceb93389e8c9b73664222ad7034603e9)</u>_

### **N-05 Typographical Errors**


Throughout the codebase, multiple instances of typographical errors were identified:


   - In <u>[line 79](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L79C14-L79C19)</u> of <mark>`ERC4337Utils.sol`</mark> <mark>,</mark> "Sames" should be "Same".

   - In <u>[line 7](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L7C39-L7C46)</u> of <mark>`NoncesKeyed.sol`</mark> <mark>,</mark> "support" should be "supports".

   - In <u>[line 22](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L22)</u> of <mark>`NoncesKeyed.sol`</mark> <mark>,</mark> "this functions" should be "this function".

   - In <u>[line 60](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/proxy/Clones.sol#L60)</u> and <u>[line 166](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/proxy/Clones.sol#L166)</u> of <mark>`Clones.sol`</mark> <mark>,</mark> "multiple time" should be "multiple times".

   - In <u>[line 14](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/interfaces/draft-IERC4337.sol#L14)</u> of <mark>`draft-IERC4337.sol`</mark> <mark>,</mark> "bunder" should be "bundler".

   - In <u>[line 9](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L9)</u> of <mark>`VotesExtended.sol`</mark> <mark>,</mark> either "adds" or "exposes" should be removed.

   - In <u>[line 12](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/extensions/GovernorCountingOverridable.sol#L12)</u> of <mark>`GovernorCountingOverridable.sol`</mark> <mark>,</mark> one "token" should be removed.


OpenZeppelin Contracts Release v5.2 Audit − Notes & Additional Information

                                                - 19


Consider fixing the typographical errors to improve the readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5308](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308)</u>_ _at commit_ _<u>[1fa2532.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308/commits/1fa253262d6bdd541a978d077dc8101b4f17bd38)</u>_

### **N-06 Redundant Code**


Throughout the codebase, multiple instances of redundant code were identified:


   - The <u><mark>`[unchecked](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Bytes.sol#L30-L38)`</mark></u> <u>keyword</u> in the <mark>`indexOf`</mark> function is redundant. This is because since

<u>[Solidity version 0.8.22, the compiler itself optimizes the loop increment.](https://docs.soliditylang.org/en/v0.8.28/internals/optimizer.html#unchecked-loop-increment)</u>

   - The <u><mark>`[Math.ternary](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L132)`</mark></u> <u>operation</u> in the <mark>`gasPrice`</mark> function is redundant. This is because

if <mark>`maxFee`</mark> and <mark>`maxPriorityFee`</mark> are equal, <mark>`maxFee`</mark> will be returned by the

<mark>`Math.min`</mark> operation anyway.


Consider removing redundant code to enhance the clarity and efficiency of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5308](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308)</u>_ _at commit_ _<u>[15a00f5.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5308/commits/15a00f50cd43c30fedc2d3320e04c66eda16bd32)</u>_

### **N-07 Code Clarity**


Throughout the codebase, multiple opportunities for improving code quality were identified:


   - Using decimal notation instead of hexadecimal would improve the readability and ease

of validation for byte amounts and offsets. For instance:

      - In the <mark>`ERC4337Utils`</mark> library, lines <u>[29, 113, and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L29)</u> <u>[123.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L123)</u>

      - In the <mark>`Clones`</mark> library, lines <u>[230, 232, and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/proxy/Clones.sol#L230C64-L230C68)</u> <u>[251. Furthermore, in](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/proxy/Clones.sol#L251C27-L251C33)</u> <u>[line 232, the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/proxy/Clones.sol#L232C47-L232C51)</u> <mark>`0x20`</mark>

constant could be replaced with <mark>`32`</mark> for consistency.




- The <mark>`SIG_VALIDATION_SUCCESS`</mark> constant can replace the magic number `0` for

<u>[checking validation data.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/account/utils/draft-ERC4337Utils.sol#L62)</u>

- There is a <mark>`_delegateCheckpoints`</mark> mapping in the <u><mark>`[VotesExtended](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L16)`</mark></u> contract and in

the <u><mark>`[Votes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/Votes.sol#L40)`</mark></u> contracts that is extended. However, this mapping serves two different

purposes: in <mark>`Votes`</mark> <mark>,</mark> it tracks the amount of delegated votes per address over time,

whereas in <mark>`VotesExtended`</mark> <mark>,</mark> it tracks which address delegated to whom over time.

Consider renaming these mappings to <mark>`_delegateVotesCheckpoints`</mark> and

<mark>`_chosenDelegateCheckpoints`</mark> or similar, respectively, to clarify their distinct roles.

- The <u><mark>`[_balanceOfCheckpoints](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L17)`</mark></u> mapping in <mark>`VotesExtended`</mark> is misleading as it does

not track token balances per account. Instead, it tracks the <u>[voting units](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/governance/utils/VotesExtended.sol#L63-L66)</u> defined by

<mark>`_getVotingUnits`</mark> <mark>.</mark> Since balance and voting units do not necessarily have a 1:1


OpenZeppelin Contracts Release v5.2 Audit − Notes & Additional Information

                                             - 20


relationship, consider renaming the mapping to <mark>`_votingUnitsCheckpoints`</mark> or a

similar term.

   - The rationale for deriving <u><mark>`[NoncesKeyed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/NoncesKeyed.sol#L11)`</mark></u> from <mark>`Nonces`</mark> and using the inherited

functionality to handle key `0` should be clarified.


Consider incorporating the above-listed changes into the codebase to enhance code clarity

and readability.


**_Update:_** _Resolved in_ _<u>[pull request #5317](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5317)</u>_ _at commit_ _<u>[7a3707f.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5317/commits/7a3707f0f1cc7dbf4b1ed0d9411642739cd0638f)</u>_

## **Client Reported**

### **CR-01 Case-Sensitivity in CAIP-10 Identifiers**


During the audit, the contracts team raised concerns about the ambiguity in <u>[CAIP-10 identifiers](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-10.md)</u>

when it comes to the case sensitivity of Ethereum addresses, as introduced in <u>[EIP-55. The](https://eips.ethereum.org/EIPS/eip-55)</u>

<u>[Canonicalization section](https://github.com/ChainAgnostic/CAIPs/blob/main/CAIPs/caip-10.md#canonicalization)</u> of the standard states that, to date, this canonicalization is not

required and remains at the developers' discretion. However, case sensitivity in CAIP-10

strings can create issues in contexts like hashing, where they may serve as mapping keys. In

such cases, lowercase and checksummed addresses are semantically equivalent but produce

different slot values.


Consider documenting a warning about the implications of case sensitivity in the <u><mark>`[CAIP2](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/CAIP2.sol)`</mark></u> and

<u><mark>`[CAIP10](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/CAIP10.sol)`</mark></u> libraries. In addition, consider adding a <mark>`toLowercase`</mark> function to the <u><mark>`[Strings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol)`</mark></u>

<u>[library](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/98d28f926121b2d7cfa4b375fd859b44c8d9a6d5/contracts/utils/Strings.sol)</u> to provide developers with a tool to manage this ambiguity.


**_Update:_** _Resolved in_ _<u>[pull request #5319](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5319)</u>_ _at commit_ _<u>[133adf8. The Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5319/commits/133adf8fbdb5c37525165f5b1e9502a11f5f0283)</u>_


_We are documenting the issues that may arise from the lack of canonicalization of the_

_identifiers. For a consistent representation, we recommend using the_

_<mark>`toChecksumHexString`</mark>_ _function._


OpenZeppelin Contracts Release v5.2 Audit − Client Reported − 21


## **Conclusion**

The v5.2 release of OpenZeppelin Contracts introduces several utility libraries, primarily

focused on supporting account abstraction and cross-chain messaging. In addition, a new

governance module has been developed, empowering users to override the voting power of

their delegates. We commend the Solidity Contracts team for addressing user needs and

enhancing existing features while introducing valuable new utilities.


During the audit, particular care was taken to document edge cases, ensuring that integrators

are informed of potential risks when interacting with these contracts. Such efforts aim to create

a more resilient codebase, recognizing the library’s critical role as a foundational component

within the blockchain ecosystem. The Contracts team has demonstrated a strong commitment

to maximizing the library's security and we are glad to have collaborated with the Contracts

team on this milestone.


OpenZeppelin Contracts Release v5.2 Audit − Conclusion − 22


