### | security

# **OpenZeppelin** **Contracts** **Release v5.1 Audit**

#### **October 3, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5

Phase 1 5

Phase 2 6


Overview - Phase 1 ________________________________________________________________  7


Overview - Phase 2 ________________________________________________________________  8

Adding Cliff to the Vesting Wallet 8

Support for Fractional Voting 8

Support for ERC-1363 and ERC-7674 9

Code Refactor 9

Addition of New Utilities 9


Security Model and Trust Assumptions _____________________________________________ 10


Medium Severity _________________________________________________________________ 11

M-01 AccessManager's schedule Function Misses minGas and minValue - Phase 1 11

M-02 Proving Empty Set Inclusion May Lead to Issues for Integrators in MerkleProof.multiProofVerify - Phase 1 12

M-03 Dirty Bytes Can Manipulate Derived Mapping Slot - Phase 2 13


Low Severity ____________________________________________________________________ 13

L-01 Royalty Calculation May Result in Zero Token Transfers Between Buyer and Seller of NFT - Phase 1 13

L-02 Missing Docstrings - Phase 1 14

L-03 Custom Functions Might Modify Memory - Phase 1 14

L-04 Incorrect or Misleading Docstrings - Phase 1 15

L-05 Different Pragma Directives Are Used - Phase 2 15

L-06 Vesting Can Start Before Cliff Ends - Phase 2 16

L-07 Over-Engineered Heap - Phase 2 16

L-08 Small Public Exponents in RSA - Phase 2 17

L-09 Incorrect Addition With Point at Infinity - Phase 2 19


Notes & Additional Information ____________________________________________________ 20

N-01 Lack of Indexed Event Parameters - Phase 1 20

N-02 Privileged User with Zero Execution Delay Can Re-Execute Operations - Phase 1 21

N-03 Padding Ignored in Base64URL Encoding - Phase 1 21

N-04 Inconsistent Annotation for Documentation - Phase 1 22

N-05 Inconsistent Use of Named Returns - Phase 1 22

N-06 Redundant Function Call in Checkpoints._insert - Phase 1 23


OpenZeppelin Contracts Release v5.1 Audit − Table of Contents − 2


N-07 Incorrect Panic Error in modExp Functions - Phase 1 23

N-08 Poor Documentation in SafeERC20 - Phase 1 24

N-09 Non-Standardized Declaration of memory-safe Assembly - Phase 1 24

N-10 Unused Import - Phase 1 25

N-11 Inconsistent Order Within Contracts - Phase 1 25

N-12 Typographical Errors - Phase 1 25

N-13 Inconsistent Declaration of memory-safe Assembly - Phase 2 26

N-14 Inconsistent Order Within Contracts - Phase 2 27

N-15 Missing Named Parameters in Mappings - Phase 2 27

N-16 Typographical Errors - Phase 2 28

N-17 Potential Licensing Conflict - Phase 2 28

N-18 Incorrect and Misleading Documentation - Phase 2 29

N-19 Redundant Code - Phase 2 30

N-20 Inconsistent Integer Base Within a Contract - Phase 2 30

N-21 Inconsistent _jAdd Function Interface - Phase 2 31

N-22 Arbitrary RSA Modulus Size - Phase 2 31

N-23 Custom Functions Might Modify Memory - Phase 2 32

N-24 Lack of Input Validation - Phase 2 32

N-25 Unintialized Variable - Phase 2 32

N-26 Applicability of Padding Oracle Attacks to RSA.sol - Phase 2 33

N-27 Inconsistent Documentation - Phase 2 34

N-28 Naming Suggestions - Phase 2 34


Client Reported __________________________________________________________________ 35

CR-01 Incorrect Internal Call - Phase 1 35

CR-02 Incorrect _jAdd Result When a Point Is Added to Itself - Phase 2 35


Recommendations _______________________________________________________________ 36

Protection Against Postquantum Adversaries in RSA Signatures 36


Conclusion ______________________________________________________________________ 38


OpenZeppelin Contracts Release v5.1 Audit − Table of Contents − 3


## **Summary**

**Type** Library


**Phase 1** From 2024-07-29
To 2024-08-14


**Phase 2** From 2024-08-19
To 2024-09-06


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



Timeline


**Total Issues** 42 (31 resolved)



**Low Severity Issues** 9 (8 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



28 (19 resolved)


2 (2 resolved)



OpenZeppelin Contracts Release v5.1 Audit − Summary − 4


## **Scope**

We audited the <u>[OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/)</u> repository at commit <u>[aba9ff6. The audit](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3)</u>

consisted of two phases.

### **Phase 1**


The scope of this audit was limited to the changes introduced in some contracts that were

<u>[previously audited](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/audits/2023-10-v5.0.pdf)</u> for the <u>[v5.0.0](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v5.0.0)</u> release.


In scope were the following files:

```
contracts
├── access
│  ├── extensions
│  │  └── AccessControlEnumerable.sol
│  └── manager
│    └── AccessManager.sol
├── governance
│  ├── Governor.sol
│  ├── extensions
│  │  └── GovernorCountingSimple.sol
│  └── utils
│    └── Votes.sol
├── metatx
│   └── ERC2771Forwarder.sol
├── proxy
│  ├── Clones.sol
│  ├── ERC1967
│  │  └── ERC1967Utils.sol
│  └── transparent
│    └── TransparentUpgradeableProxy.sol
├── token
│  ├── ERC1155
│  │  ├── ERC1155.sol
│  │  └── extensions
│  │    └── ERC1155Supply.sol
│  ├── ERC20
│  │  └── utils
│  │    └── SafeERC20.sol
│  ├── ERC721
│  │  ├── ERC721.sol
│  │  └── extensions
│  │    └── ERC721Enumerable.sol
│  └── common
│    └── ERC2981.sol

```

OpenZeppelin Contracts Release v5.1 Audit − Scope − 5


```
└── utils
├── Address.sol
├── Arrays.sol
├── Base64.sol
├── Create2.sol
├── StorageSlot.sol
├── Strings.sol
├── cryptography
│  ├── MerkleProof.sol
│  └── SignatureChecker.sol
├── math
│  ├── Math.sol
│  ├── SafeCast.sol
│  └── SignedMath.sol
└── structs
├── Checkpoints.sol
├── DoubleEndedQueue.sol
└── EnumerableMap.sol

### **Phase 2**

```

In scope were the following files:

```
contracts
├── finance
│  └── VestingWalletCliff.sol
├── governance
│  └── extensions
│    └── GovernorCountingFractional.sol
├── token
│  ├── ERC20
│  │  └── extensions
│  │    ├── draft-ERC20TemporaryApproval.sol
│  │    └── ERC1363.sol
│  ├── ERC721
│  │  └── utils
│  │    └── ERC721Utils.sol
│  └── ERC1155
│    └── utils
│      └── ERC1155Utils.sol
└── utils
├── Errors.sol
├── Packing.sol
├── Panic.sol
├── ReentrancyGuardTransient.sol
├── SlotDerivation.sol
├── cryptography
│  ├── Hashes.sol
│  ├── P256.sol
│  └── RSA.sol
└── structs
├── CircularBuffer.sol

```

OpenZeppelin Contracts Release v5.1 Audit − Scope − 6


```
├── Heap.sol
└── MerkleTree.sol

## **Overview - Phase 1**

```

Version 5.1 of the OpenZeppelin Contracts library introduces minor changes to previously

existing contracts. The following modifications were made across the majority of the in-scope

contracts:


    - **Improved documentation** : Many contracts have had their docstrings reworked. They

have either been <u>[improved](https://github.com/OpenZeppelin/openzeppelin-contracts/compare/v5.0.0...aba9ff6#diff-3240ab56e67b434cb937eba06924a054ead3444cf7a28bafdf0ee8b4bab3e01fR47)</u> or have been <u>[adapted](https://github.com/OpenZeppelin/openzeppelin-contracts/compare/v5.0.0...aba9ff6#diff-d33289f3eb8b3043d73cb1803745e64ae1338991933016a3230321df1045d38bR500)</u> to describe the new functionalities.

    - **Improved handling of common errors** : Common errors have now been isolated into a

separate <u><mark>`[Panic](https://github.com/OpenZeppelin/openzeppelin-contracts/compare/v5.0.0...aba9ff6#diff-ffa332ee53bcddd238be67717a329a9c17b1adab1b63d65a72fba86bb54a8a8cR43)`</mark></u> or <u><mark>`[Errors](https://github.com/OpenZeppelin/openzeppelin-contracts/compare/v5.0.0...aba9ff6#diff-df5f42736a1ae53c5ebcac557dce01c0e3c1bcb1ce4388f1e77b5dd796fdbe4fR136)`</mark></u> library.

    - **Improved return parameters** : Many functions have been <u>[changed](https://github.com/OpenZeppelin/openzeppelin-contracts/compare/v5.0.0...aba9ff6#diff-d33289f3eb8b3043d73cb1803745e64ae1338991933016a3230321df1045d38bR193)</u> to have their return

parameters named.


For a complete list of specific changes made in individual files, one can refer to the <u>[changelog](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/CHANGELOG.md)</u>

from version 5.0.0 to the latest one.


During the course of the audit, some behaviors were observed in the system that were

considered worth mentioning to the community.




- **<mark>`AccessManager.execute`</mark>** **Reverts on Failed External Calls**


The <mark>`AccessManager`</mark> contract provides a mechanism for role-based access control,

allowing certain operations to be scheduled and executed with specified delays. This

system ensures that only authorized users can perform certain actions. Once a call is

<mark>`scheduled`</mark> <mark>,</mark> depending on the role, the <mark>`caller`</mark> needs to wait until the end of an

execution delay period before they can <mark>`execute`</mark> the scheduled call. If a scheduled call

is malicious, an address with the <mark>`admin`</mark> or <mark>`guardian`</mark> role can cancel the schedule

before it is executed.


Once the delay period has passed (if it is applicable for a given role and caller), the

<mark>`execute`</mark> function within this contract is responsible for carrying out these operations. It

achieves this by invoking the target contract’s function through a low-level call, with the

option to send value along with the call.


The <u><mark>`[execute](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L484)`</mark></u> <u>function</u> utilizes the <u><mark>`[Address.functionCallWithValue](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Address.sol#L75)`</mark></u> <u>function</u> to

perform the external call to the target contract. This function reverts if the external call


OpenZeppelin Contracts Release v5.1 Audit − Overview - Phase 1 − 7


fails. While this ensures that failed operations do not proceed, it also means that if the

external call fails, the operation is not marked as executed. This allows the caller to retry

the same operation without needing to reschedule it, as long as the operation has not

expired. In certain situations, depending on the <mark>`target`</mark> and the reason of the failed

execution, retrying the execution can result unsuccessful attempts thereby causing

wastage of gas.

## **Overview - Phase 2**


Version 5.1 of the OpenZeppelin Contracts library introduces several new features, including

the following:

### **Adding Cliff to the Vesting Wallet**


To address the _Lack of Inclusion of a "Vesting Cliff" Feature_ issue from the <u>[audit](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/audits/2023-10-v5.0.pdf)</u> of the <mark>`v5.0.0`</mark>

release, the Contracts team has created a <u><mark>`[VestingWalletCliff](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/finance/VestingWalletCliff.sol)`</mark></u> contract, which adds a cliff

period to the vesting schedule.

### **Support for Fractional Voting**


The <u><mark>`[GovernorCountingFractional](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol)`</mark></u> contract allows delegates to decide how they want to

use their voting power. The delegates can either fractionally split their voting weight into

<mark>`Against`</mark> <mark>,</mark> <mark>`For`</mark> <mark>,</mark> and <mark>`Abstain`</mark> votes (called _fractional voting_ ), or cast their entire voting

weight into one of the three options (called _nominal voting_ ).


To identify if the voting is nominal or fraction, the <u><mark>`[_countVote](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L133)`</mark></u> function of the

<mark>`GovernorCountingFractional`</mark> contract utilizes the <mark>`support`</mark> and <mark>`bytes memory`</mark>

<mark>`params`</mark> parameters in the function signature. If <mark>`support`</mark> is <mark>`255`</mark> and <mark>`params`</mark> has <u>[exactly](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L124)</u>

<u>[48 bytes, the vote is considered fractional.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L124)</u>


While traditional voting mechanisms allow an account to participate in a voting process only

once, the <mark>`GovernorCountingFractional`</mark> contract allows for rolling voting, whereby one

account can vote for a proposal with a portion of its total weight and then subsequently vote

again with the remaining portion of its weight.


OpenZeppelin Contracts Release v5.1 Audit − Overview - Phase 2 − 8


Given that fractional voting restricts the number of casted votes (in each category) to 128 bits,

depending on the decimals of the underlying token, a voter may have to split their vote into

multiple vote operations. This has been <u>[properly documented](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L126C14-L130)</u> in the contract.

### **Support for ERC-1363 and ERC-7674**


The <mark>`ERC1363`</mark> contract extends the functionality of ERC-20 tokens by atomically allowing

code execution on the target contract after a transfer or approval. The <mark>`transferAndCall`</mark>

and <mark>`transferFromAndCall`</mark> functions call the <u><mark>`[_checkOnTransferReceived](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC20/extensions/ERC1363.sol#L156)`</mark></u> hook which

calls <mark>`IERC1363Receiver-onTransferReceived`</mark> on the recipient address. Similarly, the

<mark>`approveAndCall`</mark> functions call the <u><mark>`[_checkOnApprovalReceived](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC20/extensions/ERC1363.sol#L186)`</mark></u> hook which calls

<mark>`IERC1363Spender-onApprovalReceived`</mark> on the spender address.


The <u><mark>`[draft-ERC20TemporaryApproval](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC20/extensions/draft-ERC20TemporaryApproval.sol)`</mark></u> <u>contract</u> implements the ERC-7674 standard which

introduces temporary approval extensions for ERC-20 tokens. By using transient storage, the

<mark>`owner`</mark> can approve an allowance for the <mark>`spender`</mark> which is only valid for the current

transaction.

### **Code Refactor**


In the v5.1 release, the <mark>`checkOnERC721Received`</mark> function which is used to verify if a

recipient contract implements the <mark>`IERC721Receiver-onERC721Received`</mark> hook, has been

moved to a new <mark>`ERC721Utils`</mark> library. Similarly, the <mark>`checkOnERC1155Received`</mark> and

<mark>`checkOnERC1155BatchReceived`</mark> functions have been moved to the <u><mark>`[ERC1155Utils](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC1155/utils/ERC1155Utils.sol)`</mark></u>

<u>[library.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC1155/utils/ERC1155Utils.sol)</u>

### **Addition of New Utilities**


A set of new contracts has been added to the <mark>`utils`</mark> suite. These contracts provide

implementations for cryptographic libraries such as <mark>`RSA`</mark> and <mark>`P256`</mark> <mark>,</mark> and new data structures

such as <mark>`CircularBuffer`</mark> <mark>,</mark> <mark>`Heap`</mark> <mark>,</mark> and <mark>`MerkleTree`</mark> <mark>.</mark> The <mark>`ReentrancyGuardTransient`</mark>

library implements the <mark>`ReentrancyGuard`</mark> using transient storage.


A comprehensive list of changes made in the v5.1 release can be found in the <u>[changelog.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/CHANGELOG.md)</u>


OpenZeppelin Contracts Release v5.1 Audit − Overview - Phase 2 − 9


## **Security Model and Trust** **Assumptions**

Auditing libraries requires a shift in focus due to their composability within blockchain

protocols. While the scope of an audit is typically limited to the code itself, this expands when

it comes to libraries because of their potential internal and external integrations. Libraries act

as foundational components for many protocols. This means that their security is influenced

not just by their internal robustness, but also by how they are utilized by integrators. Therefore,

ensuring a library’s security involves not only reviewing the code but also anticipating its

various use cases and integration scenarios.


In addition, the complexity grows because while a library must cover a wide range of potential

use cases, the responsibility for secure implementation often lies with the developers who

integrate it into their projects. A library's security risks can multiply depending on how well

developers understand and utilize its contracts. This necessitates extra care to ensure that all

potential threats, both direct and indirect, are either identified and addressed, or documented

so that the developers are aware of the security risks.


OpenZeppelin Contracts Release v5.1 Audit − Security Model and Trust

Assumptions − 10


## **Medium Severity**

### **M-01 AccessManager ' s schedule Function Misses** **minGas and minValue - Phase 1**

The <mark>`schedule`</mark> <u>[function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L432)</u> of the <mark>`AccessManager`</mark> contract allows users to schedule some

calls to <mark>`target`</mark> <mark>.</mark> This operation generates an <mark>`operationId`</mark> by hashing the provided

<mark>`caller`</mark> address, <mark>`target`</mark> address, and <mark>`data`</mark> <mark>.</mark>


However, when <u>[calling](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L484)</u> <mark>`execute`</mark> on a scheduled operation, the call is performed using

<mark>`msg.value`</mark> as the attached value. This <mark>`msg.value`</mark> can be anything and is not meant to be

a part of <mark>`operationId`</mark> <mark>.</mark> As a result, there can be different execution outcomes for the same

<mark>`operationId`</mark> if the <mark>`target`</mark> contract implements a logic that depends on <mark>`msg.value`</mark> . To

some extent, the same argument can be made for the provided gas in the <mark>`execute`</mark> function,

given that the <mark>`target`</mark> might have custom logic based on that as well.


Consider adding minimum committed <mark>`minValue`</mark> and <mark>`minGas`</mark> parameters to the <mark>`schedule`</mark>

function and check those in the <mark>`execute`</mark> function implementation. Alternatively, consider

making them exact values instead of minimal ones.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Both gas and value were left out of the_ _<mark>`operationId`</mark>_ _considering that the operation_

_can only be executed by its original scheduler. For this reason, the proposer has full_

_control of how the proposal is executed and can evaluate the execution requirements of_

_the target at that moment._


_The team considers that specifying exact_ _<mark>`gas`</mark>_ _and_ _<mark>`value`</mark>_ _allows to DoS an operation_

_by manipulating the target requirements. Similarly, specifying minimum values does not_

_eliminate the possibility of different execution outcomes._


_For these reasons, and considering that this change would be breaking, we have_

_decided not to include_ _<mark>`gas`</mark>_ _and_ _<mark>`value`</mark>_ _parameters as part of an operation._


OpenZeppelin Contracts Release v5.1 Audit − Medium Severity − 11


### **M-02 Proving Empty Set Inclusion May Lead to** **Issues for Integrators in** **MerkleProof.multiProofVerify - Phase 1**

The <mark>`multiProofVerify`</mark> <u>[function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/MerkleProof.sol#L172)</u> of the <mark>`MerkleProof`</mark> library allows for proving the

inclusion of an empty set of leaves in the root of a tree. While this logic may be valid in

isolation, it poses a significant risk during integration into other codebases. Particularly when

the integrator accepts arrays of arguments from users and relies on this function to validate the

inclusion of a leaf in the tree.


The issue occurs when the <mark>`proof`</mark> array only contains the Merkle root, and both the

<mark>`proofFlags`</mark> and <mark>`leaves`</mark> arrays are empty. Despite the absence of a complete proof, the

function still computes the Merkle root and considers the proof as valid. This can lead to a

scenario where a user can bypass proper validation by submitting an incomplete proof that the

function accepts as valid and returns <mark>`true`</mark> <mark>.</mark> A <u>[secret gist](https://gist.github.com/KumaCrypto/1acd43eb941316f91472fbdec9d3af54)</u> has been created with PoC

demonstrating the potential problem.


To ensure the safety of integrators, consider adding an additional argument such as

<mark>`treeHeight`</mark> to the function and validate that the arguments provided are indeed for that

height. This would prevent situations where, for example, an integrator assumes a tree height

of 5 but the user can pass a set of arguments corresponding to the proof of an empty set at

the root and the function still returns <mark>`true`</mark> <mark>.</mark> Alternatively, consider adding a warning for

integrators which could help mitigate this risk.


**_Update:_** _Resolved in_ _<u>[pull request #5144](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5144)</u>_ _at commit_ _<u>[c304b67](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/c304b6710b4b5fcf2a319ad28c36c49df6caef14)</u>_ _and in_ _<u>[pull request #5142](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5142)</u>_ _at_

_commit_ _<u>[bcd4beb. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/bcd4beb5e7fd8bd8edf160fbffb5d5b03804efdb)</u>_


_The empty set validity is a property we expect in the_ _<mark>`multiProofVerify`</mark>_ _function_

_according to a consistent no-op policy that we have followed throughout the library. As_

_such, we consider this inclusion proof a complete one and acknowledge the risks of_

_using the_ _<mark>`multiProofVerify`</mark>_ _function without validating the content of its leaves._

_However, we did not find any meaningful use case where the leaves are used only for_

_proof validation without further validation or usage. Considering this, we think the_

_<mark>`treeHeight`</mark>_ _argument might increase the algorithm's complexity and undermine_

_developer experience while not preventing a concrete impact. We added a note to make_

_the validity of the empty set proof explicit but decided against changing the function_

_semantics to preserve backward compatibility._


OpenZeppelin Contracts Release v5.1 Audit − Medium Severity − 12


### **M-03 Dirty Bytes Can Manipulate Derived** **Mapping Slot - Phase 2**

The <u><mark>`[SlotDerivation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/SlotDerivation.sol)`</mark></u> library allows developers to derive a value slot given the slot of a

mapping and a key. There are several functions depending on various key types. Two of these

supported key types are <u><mark>`[address](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/SlotDerivation.sol#L83-L105)`</mark></u> <u>and</u> <u><mark>`[bool](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/SlotDerivation.sol#L83-L105)`</mark></u> <mark>.</mark> These two types allocate 20 bytes and 1 byte,

respectively. However, if these input keys have previously been manipulated or assigned with

assembly, it is possible that the upper bytes are dirty (non-zero). These dirty bytes would lead

to a different hash and therefore different storage location. The impact of this flaw is very

context-dependent with the caveat of assembly manipulation, but can escalate to severe

issues.


Consider cleaning the upper bytes of the <mark>`address`</mark> and <mark>`bool`</mark> type key before hashing these

values.


**_Update:_** _Resolved in_ _<u>[pull request #5195](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5195)</u>_ _at commit_ _<u>[9f0960d.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5195/commits/9f0960d1a3c7d5c645dc3d4fc90e801fb4c3ae9c)</u>_

## **Low Severity**

### **L-01 Royalty Calculation May Result in Zero** **Token Transfers Between Buyer and Seller of NFT** **- Phase 1**


In <mark>`ERC2981.sol`</mark> <mark>,</mark> the <mark>`_setTokenRoyalty`</mark> function <u>[checks and reverts](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/common/ERC2981.sol#L123-L126)</u> if <mark>`feeNumerator`</mark>

is greater than <mark>`_feeDenominator()`</mark> to ensure that <mark>`royaltyAmount`</mark> is always less than

the <mark>`salePrice`</mark> <mark>.</mark> However, the function accepts <mark>`feeNumerator`</mark> to be equal to

<mark>`_feeDenominator()`</mark> <mark>.</mark> In the <mark>`royaltyInfo`</mark> function, if <mark>`feeNumerator`</mark> is equal to

<mark>`_feeDenominator()`</mark> <mark>,</mark> the <mark>`royaltyAmount`</mark> becomes equal to <mark>`salePrice`</mark>, which could

translate to the total price of the NFT sale being paid as royalty and no transfer of ERC-20

tokens between the buyer and the seller.


It is essential to note that most NFT marketplaces that support royalty payments have distinct

addresses, one for transfer of sale price, and another for paying royalty. In general, the royalty

is paid to the creator of the NFT and the sale price is transferred from the buyer to the seller (or

owner) of the NFT. The <u>[ERC](https://eips.ethereum.org/EIPS/eip-2981#specification)</u> states that royalty should be a percentage of the sale price.

Therefore, the royalty being equal to 100% of the sale price is a valid scenario. However, a


OpenZeppelin Contracts Release v5.1 Audit − Low Severity − 13


transfer of zero amount of tokens between the buyer and the seller of the NFT could be

incompatible with protocols that use ERC-20 tokens which do not allow zero-token transfers.


Consider documenting the aforementioned behavior so that the protocols integrating with this

contract are aware of potential zero-amount transfers.


**_Update:_** _Resolved in_ _<u>[pull request #5173. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5173)</u>_


_The team agreed with the risks of paying the_ _<mark>`royaltyAmount`</mark>_ _using an ERC-20 token_

_that reverts on 0-value transfers. We are documenting this issue with a note for_

_integrators to consider._

### **L-02 Missing Docstrings - Phase 1**


Throughout the codebase, multiple instances of missing docstrings were identified:


   - The <u><mark>`[ADMIN_ROLE](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L100)`</mark></u> <u>state variable</u> in <mark>`AccessManager.sol`</mark>

   - The <u><mark>`[PUBLIC_ROLE](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L101)`</mark></u> <u>state variable</u> in <mark>`AccessManager.sol`</mark>

   - The <u><mark>`[upgradeToAndCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L18)`</mark></u> <u>function</u> in <mark>`TransparentUpgradeableProxy.sol`</mark>


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not public, should

be clearly documented as well. When writing docstrings, consider following the <u>[Ethereum](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u>

<u>[Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #5168.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5168)</u>_

### **L-03 Custom Functions Might Modify Memory -** **Phase 1**


The custom <mark>`hasher`</mark> <u>[function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/MerkleProof.sol#L74)</u> of the <mark>`MerkleProof`</mark> library and the <mark>`comp`</mark> <u>[comparator](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Arrays.sol#L32)</u>

function of the <mark>`Array`</mark> library are arbitrary functions passed as input parameters by

integrators. There are no restrictions on these functions apart from the list of input and output

parameters. As such, integrators might maliciously or accidentally code these functions in a

way that modifies the memory state whenever they are executed. Depending on the logic of

these functions, modifications done to memory can result in unexpected behavior.


While balancing the trade-offs between providing flexible library code and the risk of side

effects like memory manipulation, consider adding this edge case as a warning in the

documentation.


OpenZeppelin Contracts Release v5.1 Audit − Low Severity − 14


**_Update:_** _Resolved in_ _<u>[pull request #5174. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5174)</u>_


_We acknowledge the risks of custom hashing functions so we are documenting that_

_memory side effects should be considered when using function pointers_

### **L-04 Incorrect or Misleading Docstrings - Phase 1**


Throughout the codebase, multiple instances of incorrect or misleading docstrings were

identified:


   - This <u>[docstring](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/proxy/ERC1967/ERC1967Utils.sol#L12)</u> in the <mark>`ERC1967Utils.sol`</mark> incorrectly mentions that the library is an

"abstract contract".


   - This <u>[docstrings](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Base64.sol#L48-L49)</u> within the <mark>`_encode`</mark> function in <mark>`Base64.sol`</mark> states that, if padding is

absent, the <mark>`data.length`</mark> is rounded up and then multiplied by 4. However, in the <u>[code](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Base64.sol#L51)</u>

<u>[implementation,](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Base64.sol#L51)</u> <mark>`data.length`</mark> is first multiplied by 4 and then rounded up.


Consider updating the aforementioned instances of misleading docstrings for improved code

clarity and readability.


**_Update:_** _Resolved in_ _<u>[pull request #5168.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5168)</u>_

### **L-05 Different Pragma Directives Are Used -** **Phase 2**


In order to clearly identify the Solidity version with which the contracts will be compiled,

pragma directives should be consistent across file imports.


<mark>`MerkleTree.sol`</mark> has the pragma directive <u><mark>`[pragma solidity ^0.8.0;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/MerkleTree.sol#L4)`</mark></u> and imports the

file <mark>`Panic.sol`</mark> <mark>,</mark> which has a different pragma directive <u><mark>`[pragma solidity ^0.8.20;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Panic.sol#L4)`</mark></u> <mark>.</mark> In

addition, <mark>`Hashes.sol`</mark> is the only other file in the entire codebase that uses <u><mark>`[pragma](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/Hashes.sol#L4)`</mark></u>

<u><mark>`[solidity ^0.8.0;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/Hashes.sol#L4)`</mark></u> directive.


Consider using the same floating pragma version in all files.


**_Update:_** _Resolved in_ _<u>[pull request #5198. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5198)</u>_


_We are increasing the pragma version to 0.8.20. This is consistent with the rest of the_

_library._


OpenZeppelin Contracts Release v5.1 Audit − Low Severity − 15


### **L-06 Vesting Can Start Before Cliff Ends - Phase** **2**

A cliff is a specific period during which the tokens are locked and the holder cannot claim the

allocated tokens. However, the <mark>`_vestingSchedule`</mark> function in the <mark>`VestingWalletCliff`</mark>

contract <u>allows the vesting to begin when the</u> <u><mark>`[timestamp](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/finance/VestingWalletCliff.sol#L50)`</mark></u> <u>becomes equal to the</u> <u><mark>`[cliff()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/finance/VestingWalletCliff.sol#L50)`</mark></u> <mark>.</mark>


Consider starting the vesting period after the cliff has ended.


**_Update:_** _Acknowledged, not resolved. The understanding of the cliff point in time is subjective_

_and the OpenZeppelin Contracts team prefers that the cliff timestamp marks the beginning of_

_the vesting. The OpenZeppelin Contracts team stated:_


_The interpretation of the cliff from_ _<mark>`VestingWallerCliff`</mark>_ _matches the one we_

_[observed in other similar contracts, such as this one from ThirdWeb.](https://thirdweb.com/arbitrum/0x6f73a287611526d57112ad26ec396d86be65e104/sources)_


_In any case, this difference of interpretation (< vs <=) only changes the outcome for one_

_particular second. This is insignificant over the common duration of cliffs (months) and_

_vestings (years). For this difference to even be visible, you would need a block to be_

_produced at the exact second the cliff ends (there is an 8% chance that this block even_

_exists, considering 12s between blocks), and you would have to release the asset in that_

_exact block. Even if that were to happen, re-submitting the same transaction in the next_

_block would "resolve" things._


_Here we value lower gas cost (of < over <=) and, more importantly, consistency with_

_existing vesting wallets._

### **L-07 Over-Engineered Heap - Phase 2**


A heap is a binary-tree-based data structure that satisfies the <u>[heap property, which is that the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L29)</u>

value of a parent node is always less than the values of its children. <mark>`Heap.sol`</mark> uses an <u>[array](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L51-L53)</u>

<u>of</u> <u><mark>`[Node](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L51-L53)`</mark></u> <u>objects</u> to implement a heap, where each <u><mark>`[Node](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L51-L53)`</mark></u> <u>consists of a</u> <u><mark>`[value](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L51-L53)`</mark></u> <u>, an</u> <u><mark>`[index](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L51-L53)`</mark></u> <u><mark>,</mark></u>

<u>and a</u> <u><mark>`[lookup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L51-L53)`</mark></u> <mark>.</mark> Currently, the <u>[insertion](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L140)</u> of a new element is done by <u>[pushing a new node](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L158)</u> at the

end of the array, <u>[comparing](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L296)</u> the value of this node to the value of the parent node, and

<u>[swapping](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L297)</u> the indexes and lookups if the value of the new element is less than the value of the

parent node. This process is repeated till the heap property is met.


The root element is <u>[removed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L345)</u> by reading the root and the last elements of the heap. If the

<mark>`rootNode`</mark> is not the last element of the array, <u>[the value of the root is replaced with the value](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L378)</u>

<u>[of the last element, and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L378)</u> <u>[the respective indexes and lookups are exchanged. Once copied to](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L379-L390)</u>


OpenZeppelin Contracts Release v5.1 Audit − Low Severity − 16


the root node, the last element is popped out of the array. The heap then <u>[rebalances](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L394)</u> (or

_heapifies_ ) its nodes by comparing the root value to its children's values until the heap property

is met, thereby swapping the indexes and lookups wherever necessary. Similarly, a

<u>[replacement](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L436)</u> of the root element is done by <u>[replacing the value of the root element with the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L462)</u>

<u>[new value, and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L462)</u> <u>[heapifying](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L465)</u> until the heap property is met.


The current implementations of the <mark>`insert`</mark> <mark>,</mark> <mark>`pop`</mark> <mark>,</mark> and <mark>`replace`</mark> functionalities are difficult

to follow due to the necessary reading and writing of the <mark>`indexes`</mark> and <mark>`lookups`</mark> <mark>.</mark>

Additionally, the <u><mark>`[_swap](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L492-L503)`</mark></u> function along with the <u><mark>`[_siftUp](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L553-L568)`</mark></u> or <u><mark>`[_siftDown](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L513-L543)`</mark></u> functions costs

more gas to swap the <mark>`indexes`</mark> and <mark>`lookups`</mark> of two nodes as compared to simply

swapping the <mark>`values`</mark> <mark>.</mark>


To reduce the complexity of the codebase, consider simplifying the heap structure by using a

linear <mark>`uint256`</mark> array that stores the values of each node. The array is created such that the

root is always at index 0 (i.e., the first element of the array). For each node at index `i`, the

value of the left child is found at index <mark>`i * 2 + 1`</mark> and the right child is at <mark>`i * 2 + 2`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #5190](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5190)</u>_ _at commit_ _<u>[71fb803](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5190/commits/71fb8035ebe8b32ff9a681b3a1266b91c1f5a50b)</u>_ _and in_ _<u>[pull request #5215](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5215)</u>_ _at_

_commit_ _<u>[2843690. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5215/commits/2843690dc69ec04a49012668a1eeeb1960c552fb)</u>_


_As suggested, the Heap is updated to remove the dependency on_ _<mark>`index`</mark>_ _and_ _<mark>`lookup`</mark>_

_since it is redundant to store them. This way, we simplify the implementation and_

_improve readability while keeping the core array-based implementation that will leverage_

_cheaper adjacent storage accesses after the Verkle EVM upgrade._

### **L-08 Small Public Exponents in RSA - Phase 2**


##### function of RSA.sol allows small values of the public exponent (e.g., e e = 3 Small values of have been known to be vulnerable to attacks such as e Coppersmith's attack


##### The pkcs1 function of RSA.sol allows small values of the public exponent (e.g., e e = 3).


##### Small values of have been known to be vulnerable to attacks such as e Coppersmith's attack,



which the <mark>`RSA`</mark> implementation seems to be vulnerable to.

##### In cases where the public key is small (e.g., e = 3), Coppersmith's attack on the RSA


##### signature scheme allows an attacker to forge a signature S for an arbitrary message m without


##### S for an arbitrary message m knowledge of the private key . This is achieved by solving the following equation using the d


##### knowledge of the private key . This is achieved by solving the following equation using the d



[Coppersmith's method [1, 2]:](https://en.wikipedia.org/wiki/Coppersmith_method)


##### S 3 = M mod n


##### The above is equivalent to computing the third root of the padded message M modulo, n


##### The above is equivalent to computing the third root of the padded message M modulo, n e = 3, when the structure of M is partially known as in the case of the PKCS#1 v1.5 padding scheme and the solution S is smaller than the modulus . Specifically, n


##### which is feasible for e = 3, when the structure of M is partially known as in the case of the


##### PKCS#1 v1.5 padding scheme and the solution S is smaller than the modulus . Specifically, n



OpenZeppelin Contracts Release v5.1 Audit − Low Severity − 17


##### Coppersmith's theorem states that for the attack to be successful, the length of S should be at


##### Coppersmith's theorem states that for the attack to be successful, the length of S n 1 e − ϵ for 1 > ϵ > 0, where is the small public exponent (e.g., e e = 3

_d_

<u>1</u>
##### S should not be larger than n 3 or ≈341 bits for of around n 1024 bits.


##### most n e − ϵ for 1 > ϵ > 0, where is the small public exponent (e.g., e e = 3). Roughly, the



<u>1</u>
##### 3 or ≈341 bits for of around n 1024


##### length of S should not be larger than n 3 or ≈341 bits for of around n 1024 bits.



The implementation seems to be vulnerable to Coppersmith's attack, where the attacker will


##### solve the above equation for the part of the padded message M that corresponds to the


##### solve the above equation for the part of the padded message M that corresponds to the h ( m ). Since the hash is of size 256 bits, which is less than the limit 341


##### message hash h ( m ). Since the hash is of size 256 bits, which is less than the limit 341, the



attack is likely to succeed. The attack steps are listed below:


**Signature Forgery Attack Steps Using Coppersmith's Method**

##### 1. Choose an arbitrary m the attacker wants to forge a signature for. 2. Compute the hash h ( m ). 3. Compute the padded message M according to the PKCS#1 v.1.5 padding scheme: M = (0x00∥0x01∥0xFF … 0xFF∥0x00∥ASN.1 structure∥ h ( m ))


##### 4. Break the solution S into a known part Δ, composed of the padding prefix up to (and excluding) the hash h ( m ) and an unknown part, of size x ∣ x ∣= ∣ h ( m )∣, that we want to solve for: S = (0x00∥0x01∥0xFF … 0xFF∥0x00∥ASN.1 structure∥ x ) =

∣ _x_ ∣
##### Δ∥ x = 2 Δ + x


##### Break the solution S into a known part Δ, composed of the padding prefix up to (and


##### excluding) the hash h ( m ) and an unknown part, of size x ∣ x ∣= ∣ h ( m )∣, that we want



to solve for:


##### 5. Apply Coppersmith's method to find a root of the following polynomial: P ( x ) = (2∣ x ∣Δ + x ) e − M ≡0 mod n This is equivalent to solving for the equation x (2∣ x ∣Δ + x ) e = M mod n, where e = 3.



Apply <u>[Coppersmith's method](https://en.wikipedia.org/wiki/Coppersmith_method)</u> to find a root of the following polynomial:


##### This is equivalent to solving for the equation x


#####, where e = 3.


##### 6. If a solution is found, then x S = Δ∥ x is a valid forged signature produced without


##### knowledge of the private key that would be validated correctly since d Se = (2∣ x ∣Δ +


##### x ) e = M mod n . Stop.


##### 7. If a solution is not found, repeat from step (1.) with a new message m .



An immediate and easy fix would be to enforce the use of large public exponents, such as
##### 65537. This would make the attack less feasible, but still theoretically possible. Therefore, as a

long-term solution, consider switching to the <mark>`EMSA-PSS`</mark> padding scheme. The latter

effectively mitigates the attack due to its randomized padding which makes the structure of the
##### padded message M unpredictable. In particular, it is not possible to break M into a known

and unknown part.


**_Update:_** _Resolved in_ _<u>[pull request #5234](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5234)</u>_ _at commit_ _<u>[c9243c4. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5234/commits/c9243c4bf1bbf5e939219001e07673a21b1337c6)</u>_

_prefers to keep the implementation flexible by verifying any exponent with a valid signature. A_

_warning was added to the documentation that exponent 65537 is recommended by the_ _<u>[NIST](https://csrc.nist.gov/pubs/sp/800/78/5/final)</u>_

_and that lower exponents raise security concerns._


OpenZeppelin Contracts Release v5.1 Audit − Low Severity − 18


### **L-09 Incorrect Addition With Point at Infinity -** **Phase 2**

In the <mark>`P256`</mark> library, the <u><mark>`[_jAdd](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L185)`</mark></u> <u>function</u> adds two points in Jacobian coordinates. This

addition operation is used in the <u><mark>`[_preComputeJacobianPoints](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L289)`</mark></u> and <u><mark>`[_jMultShamir](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L250)`</mark></u>


##### G ⋅ u 1 + P ⋅ u 2, which is the main step for signature G is the curve's generator and P


##### functions to perform the computation of G ⋅ u 1 + P ⋅ u 2, which is the main step for signature


##### verification and public key recovery. Note that G is the curve's generator and P the public key.



However, this <mark>`_jAdd`</mark> function does not properly handle the addition of a point with the point


##### O (the identity element). For any point Q, the addition of Q + O should be Q

<mark>`_jAdd`</mark> returns the incorrect point (0, 0, 0). This prevents a valid signature from


##### at infinity O (the identity element). For any point Q, the addition of Q + O should be Q,



whereas <mark>`_jAdd`</mark> returns the incorrect point (0, 0, 0). This prevents a valid signature from



being correctly verified.


##### For instance, if a message was signed with the private key N −1, where N is the order of the group, then P is equal to − G . Thus, the pre-computed point points[0x05] is P + G = − G + G = O. When this point is looked up during _jMultShamir to be added to the


##### For instance, if a message was signed with the private key N −1, where N is the order of the


##### group, then P is equal to − G . Thus, the pre-computed point points[0x05] is



. When this point is looked up during <mark>`_jMultShamir`</mark> to be <u>[added to the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L266)</u>


##### rolling coordinates x, y, z x, y, z to (0, 0, 0)


##### rolling coordinates x, y, z, the loop cycle should basically do a no-op, but instead resets



to (0, 0, 0). The following table contains all private keys that lead to a pre-computed



point at infinity.


**Private Key** **Lookup Point at Infinity**

##### N −1 P + G, 2 P + 2 G, 3 P + 3 G N −2 P + 2 G N −3 P + 3 G ( N −1)/2 2 P + G ( N −3)/2 2 P + 3 G ( N −1)/3 3 P + G


Two approaches can be taken to address this issue:


1. Perform a no-op by skipping the <mark>`_jAdd`</mark> operation in <mark>`_jMultShamir`</mark> when the pre
computed point is the point at infinity.

2. In the <mark>`_jAdd`</mark> function, check if one of the points is the point at infinity and return the

other.


It is important to note that approach (1.) would leave the <mark>`_jAdd`</mark> function with this particular

bug, but would resolve the issue in the context of this implementation. This is the case


OpenZeppelin Contracts Release v5.1 Audit − Low Severity − 19


because no addition with the point at infinity would be performed since the addition operation
##### is skipped in _jMultShamir . Within _preComputeJacobianPoints only 2 P and 3 P are used as points for further calculations (2 P + G, 3 P + G, etc.), however, since P is an elliptic


##### _jMultShamir . Within _preComputeJacobianPoints only 2 P and 3 P used as points for further calculations (2 P + G, 3 P + G, etc.), however, since P is an elliptic curve point part of a group of order N where N ≡1 mod 2 and N ≡1 mod 3, it means 2 P nor 3 P can ever be equal to the point at infinity. Hence, the pre-computed


##### curve point part of a group of order N where N ≡1 mod 2 and N ≡1 mod 3, it means


##### that neither 2 P nor 3 P can ever be equal to the point at infinity. Hence, the pre-computed



points are safe against the bug described above. Approach (2.) would fix the problem at its root

but is therefore more gas intense.


Carefully consider the two approaches mentioned above and adopt one. While doing so,

thoroughly document any accepted risks or incorrect behaviors. In addition, consider writing a

thorough test suite that validates a correct signature verification for previously affected private

keys over random messages.


**_Update:_** _Resolved in_ _<u>[pull request #5218](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5218)</u>_ _at commit_ _<u>[427d074. The OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5218/commits/427d074115955a989face5ce299ed3647ed3bed7)</u>_

_team chose to implement the first approach._

## **Notes & Additional** **Information**

### **N-01 Lack of Indexed Event Parameters - Phase 1**


To improve the ability of off-chain services to search and filter for specific addresses creating

proposals, indexing the <mark>`proposer`</mark> address in the <u><mark>`[ProposalCreated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/IGovernor.sol#L115-L125)`</mark></u> <u>event</u> of

<mark>`IGovernor.sol`</mark> could be useful. Similarly, indexing <mark>`proposalId`</mark> in the

<mark>`ProposalCreated`</mark> <mark>,</mark> <mark>`ProposalQueued`</mark> <mark>,</mark> <mark>`ProposalExecuted`</mark> <mark>,</mark> <mark>`ProposalCanceled`</mark> <mark>,</mark>

<mark>`VoteCast`</mark> <mark>,</mark> and <mark>`VoteCastWithParams`</mark> events could be beneficial for filtering specific

proposals. However, discussion on <u><mark>`[issue 3826](https://github.com/OpenZeppelin/openzeppelin-contracts/issues/3826)`</mark></u> of <mark>`openzeppelin-contracts`</mark> repository

revealed that making changes to any of the events in the <mark>`IGovernor.sol`</mark> interface could be

a breaking change for the integrators decoding these events.


Consider documenting this reasoning in <mark>`IGovernor.sol`</mark> so that integrators are aware of this

limitation.


**_Update:_** _Resolved in_ _<u>[pull request #5175. Proper documentation has been added to the](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5175)</u>_

_<mark>`IGovernor.sol`</mark>_ _interface._


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 20


### **N-02 Privileged User with Zero Execution Delay** **Can Re-Execute Operations - Phase 1**

In the <mark>`AccessManager`</mark> contract, a user with zero execution delay can re-execute a

scheduled and executed operation, a cancelled operation, or an expired operation. Assigning a

role with no execution delay comes with a trust assumption that the user is trusted and will not

make any malicious or undesirable changes to the protocol, allowing them to execute any

operation regardless of the schedule. However, this is in contrast with the <u>[comment](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L482)</u> above the

<mark>`execute`</mark> function in the <mark>`AccessManager`</mark> contract which states that

<mark>`_consumeScheduledOp`</mark> guarantees that a scheduled operation is only executed once. If a

role has zero execution delay, the role takes <u>[precedence](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L500-L502)</u> over the schedule, allowing the role to

execute a scheduled operation more than once.


Consider documenting the precedence of the role over the schedule to correctly reflect this

scenario.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_The current behavior of the_ _<mark>`AccessManager`</mark>_ _<mark>'</mark>_ _s_ _<mark>`execute`</mark>_ _function is expected as it_

_allows any account with a privileged role to execute a function regardless of any_

_previously scheduled operation. We acknowledge this behavior but do not think_

_documentation is required since it does not change how developers should interact with_

_this contract._

### **N-03 Padding Ignored in Base64URL Encoding -** **Phase 1**


The <u><mark>`[encodeURL](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Base64.sol#L27-L29)`</mark></u> <u>function</u> of the <mark>`Base64`</mark> contract purposefully <u>[ignores any padding. This](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Base64.sol#L28)</u>

implementation is based on <u>[RFC-4648](https://datatracker.ietf.org/doc/html/rfc4648#section-5)</u> which allows the padding to be skipped for URL/URI

encoding since the pad character "=" is typically <u>[percent-encoded. As highlighted in](https://en.wikipedia.org/wiki/Percent-encoding)</u> <u>[this](https://eprint.iacr.org/2022/361.pdf)</u>

research, depending on the behavior of the decoder, the optionality of padding can introduce

malleable outputs when decoding this string.


Consider documenting explicitly that the padding is ignored while encoding the <mark>`Base64URL`</mark>

so that integrating projects are aware and able to modify the decoding functionality wherever

necessary.


**_Update:_** _Resolved in_ _<u>[pull request #5176. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5176)</u>_


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 21


_The team agrees that it is an issue that mostly depends on the decoder implementation._

_For this reason, we would like to document it on the decoding side once a Base64URL_

_decoder is implemented in OpenZeppelin Contracts. We are adding a small note to_

_clarify its behavior but have decided not to document it extensively._

### **N-04 Inconsistent Annotation for Documentation** **- Phase 1**


Throughout the codebase, inconsistent uses of annotations for referencing documentation

from the base contracts were identified. For instance, within <mark>`Governor.sol`</mark> <mark>,</mark> in <u>[line 99, the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/Governor.sol#L99)</u>

<mark>`@dev See {IGovernor-name}.`</mark> annotation is used, whereas in <u>[line 839, the docstrings are](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/Governor.sol#L839)</u>

inherited via the <mark>`@inheritdoc IGovernor`</mark> annotation.


The use of <mark>`@inheritdoc`</mark> annotation is also inconsistent between certain contracts. For

instance, in <mark>`AccessManager.sol`</mark> <mark>,</mark> the annotation is a <u>[single-line comment, whereas in](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L130)</u>

<mark>`Governor.sol`</mark> <mark>,</mark> the annotation is in a multi-line comment <u><mark>`[/** ... */](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/Governor.sol#L827-L829)`</mark></u> <u>format.</u>


To improve code readability, consider using a consistent standard for inheriting documentation

throughout the codebase.


**_Update:_** _Acknowledged, will resolve. The OpenZeppelin Contracts team stated:_


_[This inconsistency has been discussed in issue 3502. Particularly, this comment details](https://github.com/OpenZeppelin/openzeppelin-contracts/issues/3502)_

_the limitations of using_ _<mark>`@inheritdoc`</mark>_ _for extending documentation. For these cases,_

_we leverage our documentation engine and use the_ _<mark>`@dev See {...}`</mark>_ _syntax to point_

_users in the right direction while also writing additional documentation. We acknowledge_

_the inconsistency between single-line comments and_ _<mark>`/** ... */`</mark>_ _comments and will_

_consider making them consistent in the future._

### **N-05 Inconsistent Use of Named Returns - Phase** **1**


Throughout the codebase, multiple instances of functions having inconsistent usage of named

returns were identified:


   - In the <u><mark>`[AccessManager](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol)`</mark></u> contract, multiple functions such as <u><mark>`[canCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L131)`</mark></u> <mark>,</mark> <u><mark>`[getAccess](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L190)`</mark></u>,

and <u><mark>`[hasRole](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L203)`</mark></u> <mark>,</mark> utilize named return variables, whereas others like <u><mark>`[expiration](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L150)`</mark></u> do not.


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 22


   - In the <u><mark>`[ERC2771Forwarder](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/metatx/ERC2771Forwarder.sol)`</mark></u> contract, the <u><mark>`[_validate](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/metatx/ERC2771Forwarder.sol#L200)`</mark></u> and <u><mark>`[_execute](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/metatx/ERC2771Forwarder.sol#L255)`</mark></u> functions use

named return variables, whereas the <mark>`verify`</mark> <mark>,</mark> <mark>`_recoverForwardRequestSigner`</mark> <mark>,</mark>

and <mark>`_isTrustedByTarget`</mark> functions do not.


To improve code readability, consider using the same return style across all of a contract's

functions.


**_Update:_** _Resolved in_ _<u>[pull request #5178](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5178)</u>_ _and in_ _<u>[pull request #5177. The OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5177)</u>_

_Contracts team stated:_


_Previously, the team agreed to name the returned values when there is more than one._

_We are documenting this clearly in our guidelines and adding missing names where_

_needed according to this policy._

### **N-06 Redundant Function Call in** **Checkpoints._insert - Phase 1**


In the <mark>`_insert`</mark> function of the <mark>`Checkpoints`</mark> library, the <u><mark>`[_unsafeAccess](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Checkpoints.sol#L145)`</mark></u> function is used

to retrieve a storage pointer to the struct. However, this retrieval has already been performed at

an earlier point <u>[in the code.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Checkpoints.sol#L134)</u>


Consider directly using the previously retrieved storage pointer instead of calling

<mark>`_unsafeAccess`</mark> again.


**_Update:_** _Resolved in_ _<u>[pull request #5169](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5169)</u>_ _at commit_ _<u>[951b97e.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/951b97ec17df37c74c42468c848944b53dc4fb16)</u>_

### **N-07 Incorrect Panic Error in modExp Functions -** **Phase 1**


The <u><mark>`[modExp](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/math/Math.sol#L367)`</mark></u> function in the <mark>`Math`</mark> library will revert with an invalid panic error if the

<mark>`staticcall`</mark> to the precompile <mark>`modexp`</mark> reverts due to running out of gas. The call to the

precompile may fail if the operation costs more gas than was provided, resulting in <u><mark>`[success](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/math/Math.sol#L368)`</mark></u>

being <mark>`false`</mark> <mark>.</mark> This causes a revert with the <u><mark>`[DIVISION_BY_ZERO](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/math/Math.sol#L370)`</mark></u> <u>panic error</u> which misleads

library users.


Consider reverting with distinct errors for the case where <u><mark>`[m == 0](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/math/Math.sol#L383)`</mark></u> and when the

<mark>`staticcall`</mark> fails due to an out-of-gas error. The above also applies to the analogous

<u>[modExp function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/math/Math.sol#L319)</u> for fixed-length arguments, though this is less likely to occur.


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 23


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Detecting an out-of-gas error is already a difficult task. Although we acknowledge that_

_there is a mismatched panic if the function runs out of gas, there is no other side effect._

_Future community efforts involve EOF, which removes gas observability. For this reason,_

_we would prefer not to make changes that limit our compatibility with it._

### **N-08 Poor Documentation in SafeERC20 - Phase 1**


In <u><mark>`[_callOptionalReturn](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC20/utils/SafeERC20.sol#L146)`</mark></u> and <u><mark>`[_callOptionalReturnBool](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC20/utils/SafeERC20.sol#L174)`</mark></u> functions of the

<mark>`SafeERC20`</mark> library, there is a check that if some data is returned then the first word must be

true (1). However, there is no check that the length of the returned data is exactly one word.

This can lead to a scenario in which the target contract does not implement a token interface,

but at the same time, has a fallback function which returns some data with 1 in the first

returned word. In this case, the library will process the output and not revert.


Consider adding a warning to the code so that integrators are aware of this scenario.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_The referenced functions are currently_ _<mark>`private`</mark>_ _so they are not available for_

_developers to use. We consider the current documentation to be satisfactory since it_

_already describes that non-reverting calls are assumed to be successful in the_

_corresponding entry points (i.e.,_ _<mark>`safeTransfer`</mark>_ _<mark>,</mark>_ _<mark>`safeTransferFrom`</mark>_ _<mark>,</mark>_ _and_

_<mark>`forceApprove`</mark>_ _<mark>)</mark>_ _. We will consider documenting this if those functions ever become_

_<mark>`internal`</mark>_ _<mark>.</mark>_

### **N-09 Non-Standardized Declaration of memory-** **safe Assembly - Phase 1**


There are two types of memory-safe assembly declarations:







```
assembly ("memory-safe")
/// @solidity memory-safe-assembly

```


Both types are used in the codebase, leading to inconsistencies. For example, the

<u><mark>`[SafeERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC20/utils/SafeERC20.sol#L149)`</mark></u> <u>contract</u> uses the former, whereas the <u><mark>`[ERC2771Forwarder](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/metatx/ERC2771Forwarder.sol#L312)`</mark></u> <u>contract</u> uses the

latter. Moreover, according to Solidity <u>[documentation, the latter is likely to be deprecated.](https://docs.soliditylang.org/en/latest/assembly.html#memory-safety)</u>


Consider standardizing the use of the <mark>`memory-safe`</mark> declaration.


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 24


**_Update:_** _Resolved in_ _<u>[pull request #5172](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5172)</u>_ _at commit_ _<u>[04e0df3.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/04e0df30aaf341bed5398012e3a8740bddeb6e04)</u>_

### **N-10 Unused Import - Phase 1**


Having unused imports negatively affect code quality.


In <mark>`IAccessManager.sol`</mark> <mark>,</mark> the <u><mark>`[IAccessManaged](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/IAccessManager.sol#L6)`</mark></u> interface is imported but never used.


Consider removing the unused import statement to improve code clarity and readability.


**_Update:_** _Resolved in_ _<u>[pull request #5170](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5170)</u>_ _at commit_ _<u>[05f7a22.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/05f7a22360645f1feee81366eb2a4b10007941d2)</u>_

### **N-11 Inconsistent Order Within Contracts - Phase** **1**


Throughout the codebase, multiple instances of contracts deviating from the Solidity Style

Guide due to having inconsistent ordering of functions were identified. The following is a non
exhaustive list of such instances:








<mark>`AccessManager`</mark> <u>[has](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol)</u> mixed orders of <mark>`public`</mark> and <mark>`internal`</mark> functions.

<mark>`Checkpoints`</mark> <u>[has](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Checkpoints.sol)</u> mixed orders of <mark>`internal`</mark> and <mark>`private`</mark> functions.



To improve the project's overall legibility, consider standardizing ordering throughout the

codebase as recommended by the <u>[Solidity Style Guide (Order of Functions).](https://docs.soliditylang.org/en/latest/style-guide.html#order-of-layout)</u>


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_A negative aspect of reordering functions is that it may change the compiler output,_

_leading to unexpected results (e.g., suddenly hitting stack-too-deep errors). Also,_

_changing the order is difficult to review and audit as it produces a big diff that may not_

_be substantial. For these reasons, we decided not to make changes to function_

_ordering._

### **N-12 Typographical Errors - Phase 1**


Throughout the codebase, multiple instances of typographical errors were identified:


   - In <u>[line 690](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/access/manager/AccessManager.sol#L690)</u> of <mark>`AccessManager.sol`</mark> <mark>,</mark> the variable name <mark>`isTragetClosed`</mark> should be

<mark>`isTargetClosed`</mark> <mark>.</mark>

   - In <u>[line 235](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/math/Math.sol#L235)</u> of <mark>`Math.sol`</mark> <mark>,</mark> <mark>`expect`</mark> should be <mark>`except`</mark> <mark>.</mark>


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 25


   - In <u>[line 61](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/math/SignedMath.sol#L61)</u> of <mark>`SignedMath.sol`</mark> <mark>,</mark> <mark>`bytes(0)`</mark> should be <mark>`bytes32(0)`</mark> <mark>.</mark>

   - In <u>[line 92](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/StorageSlot.sol#L92)</u> of <mark>`StorageSlot.sol`</mark> <mark>,</mark> <mark>`an BooleanSlot`</mark> should be <mark>`a BooleanSlot`</mark> .

   - In <u>[line 102](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/StorageSlot.sol#L102)</u> of <mark>`StorageSlot.sol`</mark> <mark>,</mark> <mark>`an Bytes32Slot`</mark> should be <mark>`a Bytes32Slot`</mark> .

   - In <u>[line 112](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/StorageSlot.sol#L112)</u> of <mark>`StorageSlot.sol`</mark> <mark>,</mark> <mark>`an Uint256Slot`</mark> should be <mark>`a Uint256Slot`</mark> .

   - In <u>[line 132](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/StorageSlot.sol#L132)</u> and <u>[line 142](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/StorageSlot.sol#L142)</u> of <mark>`StorageSlot.sol`</mark> <mark>,</mark> <mark>`an StringSlot`</mark> should be `a`

<mark>`StringSlot`</mark> <mark>.</mark>

   - In <u>[line 152](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/StorageSlot.sol#L152)</u> and <u>[line 162](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/StorageSlot.sol#L162)</u> of <mark>`StorageSlot.sol`</mark> <mark>,</mark> <mark>`an BytesSlot`</mark> should be `a`

<mark>`BytesSlot`</mark> <mark>.</mark>


To improve code readability, consider fixing the above along with any other instances of

typographical errors in the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5171](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5171)</u>_ _at commit_ _<u>[3e44eed.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/3e44eede9ab88e732b5f68be664ccc2d536febae)</u>_

### **N-13 Inconsistent Declaration of memory-safe** **Assembly - Phase 2**


There are two types of memory-safe assembly declarations:







```
assembly ("memory-safe")
/// @solidity memory-safe-assembly

```


Both types are being used in the codebase, leading to inconsistencies. For example, the

<u><mark>`[Packing](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Packing.sol#L38)`</mark></u> <u>contract</u> uses the former, whereas the <u><mark>`[Panic](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Panic.sol#L49)`</mark></u> <u>[contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/Panic.sol#L49)</u> uses the latter. Moreover,

according to Solidity <u>[documentation, the latter is likely to be deprecated.](https://docs.soliditylang.org/en/latest/assembly.html#memory-safety)</u>


Consider standardizing the use of the memory-safe declaration.


**_Update:_** _Resolved in_ _<u>[pull request #5172. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5172)</u>_


_Issue N-09 was resolved by migrating the memory-safe declarations to the newer_

_<mark>`assembly ("memory-safe")`</mark>_ _syntax._


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 26


### **N-14 Inconsistent Order Within Contracts -** **Phase 2**

Throughout the codebase, multiple instances of inconsistent ordering of functions were

identified:


   - In the <u><mark>`[GovernorCountingFractional](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol)`</mark></u> <u>contract,</u> <mark>`view`</mark> functions should come before

<mark>`pure`</mark> functions and <mark>`internal`</mark> functions should come before <mark>`internal view`</mark>

functions.

   - In the <u><mark>`[Heap](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol)`</mark></u> <u>library,</u> <mark>`internal`</mark> functions should come before <mark>`internal view`</mark>

functions.

   - In the <u><mark>`[P256](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol)`</mark></u> <u>library,</u> <mark>`internal`</mark> functions should come before <mark>`private`</mark> functions.

   - In the <u><mark>`[ReentrancyGuardTransient](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/ReentrancyGuardTransient.sol)`</mark></u> <u>contract,</u> <mark>`internal`</mark> functions should come

before <mark>`private`</mark> functions.

   - In the <u><mark>`[ERC20TemporaryApproval](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC20/extensions/draft-ERC20TemporaryApproval.sol)`</mark></u> <u>contract,</u> <mark>`public`</mark> functions should come before

<mark>`internal`</mark> functions.


To improve the project's overall legibility, consider standardizing ordering throughout the

codebase as recommended by the <u>[Solidity Style Guide (Order of Functions).](https://docs.soliditylang.org/en/latest/style-guide.html#order-of-layout)</u>


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_We generally adhere to the Solidity style guide on function ordering. However, in the_

_presented cases, changing the order of the functions makes it difficult to review and_

_audit parts of the contracts. For this reason, we decided not to change the function_

_ordering in these cases._

### **N-15 Missing Named Parameters in Mappings -** **Phase 2**


Since <u>[Solidity 0.8.18, developers can utilize named parameters in mappings. This means](https://github.com/ethereum/solidity/releases/tag/v0.8.18)</u>

mappings can take the form of

<mark>`mapping(KeyType keyName => ValueType valueName)`</mark> <mark>.</mark> This updated syntax provides

a more transparent representation of a mapping's purpose.


Within <mark>`GovernorCountingFractional.sol`</mark> <mark>,</mark> the <u><mark>`[_proposalVotes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L47)`</mark></u> <u>state variable</u> can

benefit from a named parameter.


Consider adding named parameters to mappings in order to improve the readability and

maintainability of the codebase.


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 27


**_Update:_** _Resolved in_ _<u>[pull request #5204. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5204)</u>_


_We agree that named parameters in mappings improve readability when the mapping_

_<mark>`key`</mark>_ _specifies a name. In the case of the mapping's_ _<mark>`value`</mark>_ _<mark>,</mark>_ _its name is already that of_

_the mapping itself (e.g.,_ _<mark>`_proposalVotes`</mark>_ _<mark>)</mark>_ _. For this reason, we are updating_

_<mark>`GovernorCountingFractional`</mark>_ _to name the_ _<mark>`_proposalVotes`</mark>_ _parameter, but we_

_decided not to name its value as we have consistently not done so across the library._

### **N-16 Typographical Errors - Phase 2**


Throughout the codebase, multiple instances of typographical errors were identified:


   - In <u>[line 21](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/interfaces/IERC1363Receiver.sol#L21)</u> of <mark>`IERC1363Receiver.sol`</mark> <mark>,</mark> "The address which are tokens transferred

from" should be "The address which the tokens are transferred from".

   - In <u>[line 19](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/token/ERC1155/utils/ERC1155Utils.sol#L19)</u> of <mark>`ERC1155Utils.sol`</mark> <mark>,</mark> "if the target address is doesn't contain code"

should be "if the target address doesn't contain code".

   - In <u>[line 47](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L47)</u> and <u>[line 314](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L314)</u> of <mark>`Heap.sol`</mark> <mark>,</mark> "Binary heap that support values" should be

"Binary heap that supports values".

   - In <u>[line 240](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L240)</u> and <u>[line 507](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L507)</u> of <mark>`Heap.sol`</mark> <mark>,</mark> "leafs" should be "leaves".

   - In <u>[line 12](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L12)</u> of <mark>`RSA.sol`</mark> <mark>,</mark> "semanticaly" should be "semantically".

   - In <u>[line 30](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L30)</u> of <mark>`RSA.sol`</mark> <mark>,</mark> "according the verification" should be "according to the

verification".

   - In <u>[line 140](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L140)</u> of <mark>`RSA.sol`</mark> <mark>,</mark> "safetiness" should be "safeness".

   - In <u>[line 95](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/CircularBuffer.sol#L95)</u> of <mark>`CircularBuffer.sol`</mark> <mark>,</mark> "elements kepts in" should be "elements kept in".


**_Update:_** _Resolved in_ _<u>[pull request #5194. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5194)</u>_


_The indicated typographical errors have been addressed as per the recommendations._

### **N-17 Potential Licensing Conflict - Phase 2**


The following two cryptography libraries might face licensing conflicts:


   - The <mark>`RSA`</mark> library is <u>[said to be inspired](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L14)</u> by the <u><mark>`[adria0/SolRsaVerify](https://github.com/adria0/SolRsaVerify)`</mark></u> repository, which

is licensed under GPL version 3.

   - The <mark>`P256`</mark> library is <u>[said to be based](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L15)</u> on the <u><mark>`[itsobvioustech/aa-passkeys-](https://github.com/itsobvioustech/aa-passkeys-wallet/blob/main/src/Secp256r1.sol)`</mark></u>

<u><mark>`[wallet](https://github.com/itsobvioustech/aa-passkeys-wallet/blob/main/src/Secp256r1.sol)`</mark></u> repository, also licensed under GPL version 3.


As the OpenZeppelin contracts library is released under the MIT license, consider clarifying

that inspired and copied code under GPL v3 can be released under MIT.


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 28


**_Update:_** _Resolved in_ _<u>[pull request #5205. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5205)</u>_


_The team recognizes the potential licensing conflicts and we are clarifying that the code_

_that inspired our implementation is under a GPL v3 license._

### **N-18 Incorrect and Misleading Documentation -** **Phase 2**


Throughout the codebase, multiple instances of incorrect or misleading documentation were

identified:


   - The <u>[documentation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/finance/VestingWalletCliff.sol#L24)</u> of the <mark>`VestingWalletCliff`</mark> <mark>`constructor`</mark> does not match the

implementation. There is just the <mark>`cliffSeconds`</mark> parameter to be described. Note that

the inherited <mark>`VestingWallet`</mark> contract also sets up the beneficiary as the owner using

the <mark>`Ownable`</mark> contract instead of using the <mark>`Ownable2Step`</mark> contract as indirectly

described.

   - The <u>title of the</u> <u><mark>`[IERC1363Spender](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/interfaces/IERC1363Spender.sol#L7)`</mark></u> is incorrect as it is missing the "I" prefix.


##### • In P256.sol, the comment for isValidPublicKey states x ≤ P, y ≤ P, whereas it should be x < P, y < P . Note that x, y are coordinates of an EC point and P is the

modulus of the base field they are elements of. So, all values of the coordinates are

strictly less than the modulus.


##### • In P256.sol, the comment for _jMultShamir says Pu 1 + Qu 2 be Gu 1 + Qu 2.

- The <mark>`_preComputeJacobianPoints`</mark> function has some comments on the end-result


##### In P256.sol, the comment for _jMultShamir says Pu 1 + Qu 2, whereas it should


##### be Gu 1 + Qu 2.



The <mark>`_preComputeJacobianPoints`</mark> function has some comments on the end-result

of each table entry. For consistency, the <mark>`0x0c`</mark> array entry should be commented as

<mark>`(3g)`</mark> instead of <u><mark>`[(g+2g)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L302)`</mark></u> <mark>.</mark> Also note that one index is <u><mark>`[0x0C](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L305)`</mark></u> <u>[with a capital "C"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L305)</u> instead

of the otherwise lowercase hex characters.




- In RSA signature schemes, the <mark>`DigestInfo`</mark> allows having some <u>[optional parameters.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L82)</u>

However, these are <u>[not checked](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L133)</u> in the <mark>`RSA`</mark> implementation. In principle, this may create

a malleability issue. Although, the way the <mark>`buffer`</mark> is <u>[parsed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L98-L113)</u> suggests that the

implementation does not support optional parameters. Consider clarifying this in the

documentation.

- In <mark>`RSA.sol`</mark> <mark>,</mark> the verification has the <u>[sha-256 OID](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L101)</u> hard-coded in it, which is the only

hash function supported at the moment. Since there is a wrapper <mark>(</mark> <u><mark>`[pkcs1Sha256](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L20)`</mark></u> <mark>)</mark> for

SHA256, it suggests the possibility of adding wrappers for other hash functions (e.g.,

Keccak) as well. If another hash function is used with the verification procedure,

verification will fail due to the hard-coded OID. Consider clarifying in the documentation

that the implementation currently only supports SHA256.


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                             - 29


##### • In the pkcs1 function of RSA, the length of the RSA modulus is n compared to the

<u>[constant](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L49)</u> <u><mark>`[0x40](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L49)`</mark></u> <mark>.</mark> However, it is not clear how this constant is computed. Consider

clarifying this in the documentation.

   - The <u>[index description](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/CircularBuffer.sol#L48)</u> of the <mark>`CircularBuffer`</mark> library describing "The last item is at [...]

and the last item is at [...]" is unclear.


Consider applying the above suggestions for a clearer documentation that helps reason about

the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5206](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5206)</u>_ _at commit_ _<u>[0a0d44d](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5206/commits/0a0d44d338fc52adc8b38c0402ba6daa1982dabe)</u>_ _and in_ _<u>[pull request #5229](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5229)</u>_ _at_

_commit_ _<u>[9c986c5. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5229/commits/9c986c52bc4eb8f072326f74530f4556e8cf202f)</u>_


_The recommendations were implemented with a few differences. In the case of_

_<mark>`P256.sol`</mark>_ _<mark>,</mark>_ _it was renamed to_ _<mark>`G·u1 + P·u2`</mark>_ _instead of_ _<mark>`G·u1 + Q·u2`</mark>_ _<mark>,</mark>_ _which is_

_consistent with the arguments of_ _<mark>`_preComputeJacobianPoints`</mark>_ _<mark>.</mark>_ _For_ _<mark>`RSA.sol`</mark>_ _<mark>,</mark>_

_the_ _<mark>`pkcs1`</mark>_ _function was renamed to_ _<mark>`pkcs1Sha256`</mark>_ _to be consistent with the hard-_

_coded OID. Also, the RSA modulus is now enforced to be at least_ _<mark>`0x100`</mark>_ _following the_

_recommendation from N-22._

### **N-19 Redundant Code - Phase 2**


Within the <mark>`recovery`</mark> function of the <mark>`P256`</mark> library, the <u><mark>`[v % 2](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L133)`</mark></u> <u>[operation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L133)</u> is unnecessary given

that the value of <u>`[v](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L125-L127)`</u> <u>[can only be 0 or 1.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L125-L127)</u>


Consider removing any redundant code to improve the readability and maintainability of the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5200.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5200)</u>_

### **N-20 Inconsistent Integer Base Within a Contract** **- Phase 2**


In <mark>`RSA.sol`</mark> <mark>,</mark> integer constants are represented using both decimal (in <u>[line 98](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L98)</u> and <u>[line 104)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L104)</u>

and hexadecimal (in <u>[line 49, line 56, line 63, line 98, line 104, and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L49)</u> <u>[line 134).](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L134)</u>


To avoid confusion and improve the readability of the codebase, consider using a consistent

notation.


**_Update:_** _Resolved in_ _<u>[pull request #5206.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5206)</u>_


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 30


### **N-21 Inconsistent _jAdd Function Interface -** **Phase 2**

In the <u><mark>`[_jAdd](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L186-L189)`</mark></u> <u>function</u> of the <mark>`P256`</mark> library, the first point is passed as a <u><mark>`[JPoint](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L20-L24)`</mark></u> <u>struct, while</u>

the second point is passed with the explicit coordinates. In the assembly block, this leads to
##### fetching the,, and coordinates from the first point using the x y z mload and add opcodes,

thereby making the code additionally complex.


Consider changing the function interface by passing both points' coordinates explicitly.

Alternatively, consider documenting why this interface is required as is.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Using_ _<mark>`JPoint`</mark>_ _for both points would be significantly more gas-expensive in the context_

_of how_ _<mark>`_jAdd`</mark>_ _is used within other functions, particularly_ _<mark>`_jMultShamir`</mark>_ _<mark>.</mark>_ _The current_

_design minimizes unnecessary memory operations. The_ _<mark>`_jAdd`</mark>_ _function is primarily_

_called from contexts where one point is already in_ _<mark>`JPoint`</mark>_ _format (often a running_

_calculation result), while the other is a new point being added, for which we have direct_

_coordinate access (such as in_ _<mark>`_jAddPoint`</mark>_ _<mark>)</mark>_ _._


_Note that_ _<mark>`_jAdd`</mark>_ _using mixed input (point in memory + coordinates on the stack) is_

_necessary to circumvent stack-too-deep errors. The mloads for point 1 are done at the_

_very last moment. Doing the mload only once and caching the value on the stack would_

_possibly save gas, but it also blocks compilation without via-ir._

### **N-22 Arbitrary RSA Modulus Size - Phase 2**


The <u>[comment](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L33-L34)</u> for <mark>`pkcs1`</mark> correctly states that using an RSA modulus of <mark>`1024`</mark> bits is unsafe

and encourages the use of at least <mark>`2048`</mark> bits.


Consider enforcing this requirement in the code so that the signatures produced under moduli

of size less than <mark>`2048`</mark> are not supported. This is in accordance with the minimum key sizes

<u>[recommended by NIST](https://csrc.nist.gov/pubs/sp/800/78/5/final)</u> throughout the year 2030.


**_Update:_** _Resolved in_ _<u>[pull request #5206. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5206)</u>_


_We acknowledge the risks of using a modulus of less than_ _<mark>`2048`</mark>_ _bits according to the_

_documentation so we are enforcing it._


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 31


### **N-23 Custom Functions Might Modify Memory -** **Phase 2**

The custom <mark>`fnHash`</mark> <u>[function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/MerkleTree.sol#L80)</u> of the <mark>`MerkleTree`</mark> library and the <mark>`comp`</mark> <u>[comparator](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L90)</u> function

of the <mark>`Heap`</mark> library are arbitrary functions passed as input parameters by integrators. There

are no restrictions on these functions apart from the list of input and output parameters. As

such, integrators might maliciously or accidentally code these functions in a way that modifies

the memory state whenever they are executed. Depending on the logic of these functions,

modifications done to memory can result in unexpected behavior.


While balancing the trade-offs between providing flexible library code and the risk of side

effects like memory manipulation, consider adding the aforementioned edge case as a warning

in the documentation.


**_Update:_** _Resolved in_ _<u>[pull request #5213](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5213)</u>_ _and in_ _<u>[pull request #5190.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5190)</u>_

### **N-24 Lack of Input Validation - Phase 2**


The <u><mark>`[setup](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/CircularBuffer.sol#L64)`</mark></u> <u>function</u> of <mark>`CircularBuffer.sol`</mark> does not verify if the <mark>`size`</mark> of the buffer is

zero. In addition, the <u><mark>`[push](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/CircularBuffer.sol#L80)`</mark></u> <u>[function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/CircularBuffer.sol#L80)</u> of <mark>`CircularBuffer.sol`</mark> does not verify if the buffer

<mark>`self`</mark> was set up. This could potentially lead to the <mark>`modulus`</mark> being zero and revert due to

modulo by zero.


Consider checking the inputs explicitly to reduce the attack surface of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5214. A check was added to the](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5214)</u>_ _<mark>`setup`</mark>_ _function to ensure_

_that the buffer size is not zero. In the_ _<mark>`push`</mark>_ _function, the panic of modulus by zero has been_

_kept as it is._

### **N-25 Unintialized Variable - Phase 2**


Initializing some variables and leaving out others can impact code readability. In the

<u><mark>`[_countVote](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L133)`</mark></u> function of the <mark>`GovernorCountingFractional`</mark> contract, the <u><mark>`[usedWeight](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L149)`</mark></u>

<u>[variable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L149)</u> has not been initialized whereas <u>[others](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L146-L148)</u> have been.


To improve code clarity and readability, consider initializing the <u><mark>`[usedWeight](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/governance/extensions/GovernorCountingFractional.sol#L149)`</mark></u> <u>variable</u> as well.


**_Update:_** _Resolved in_ _<u>[pull request #5206.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5206)</u>_


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 32


### **N-26 Applicability of Padding Oracle Attacks to** **RSA.sol - Phase 2**

The <mark>`EMSA-PKCS1-v1_5`</mark> padding scheme has been shown to be susceptible to

[implementation errors that allow signature forgeries [1, 2] using variants of the padding oracle](https://mailarchive.ietf.org/arch/msg/openpgp/5rnE9ZRN1AokBVj3VqblGlP63QE/)

attack by <u>[Bleichenbacher (1998), originally proposed for RSA encryption. In a padding oracle](https://link.springer.com/chapter/10.1007/BFb0055716)</u>

attack on signatures, the attacker submits carefully chosen malformed signatures, modifying

parts of the padding. From the responses it gets from the signing algorithm, the attacker is able

to produce a forgery with high probability.


As a mitigation, the RFC8017 standard proposes the <u>[EMSA-PSS](https://datatracker.ietf.org/doc/html/rfc8017#section-9.1)</u> padding scheme. This

scheme is probabilistic, meaning that the same message can have different paddings each

time it is signed. The added randomness effectively mitigates padding oracle attacks. In

addition to having oracle access to the verification algorithm, the Bleichenbacher attack on

signatures leverages the following weaknesses:


1. Faulty implementations that only check the first bytes of the decrypted signature <mark>(</mark> <mark>`0x00`</mark> <mark>,</mark>

<mark>`0x02`</mark> <mark>,</mark> and the <mark>`0xFF`</mark> padding) and omit to check the rest of the formatting. In particular,

they fail to check if the hash data matches the hash of the supplied message.


##### 2. Use of small values for the public exponent e = 3 possible for large values of (e.g., e 65537


##### Use of small values for the public exponent e = 3. Although the attack is theoretically


##### possible for large values of (e.g., e 65537), it is much less efficient in that case.



3. Malleability of the RSA scheme, i.e., small changes to the ciphertext or signature result in



predictable changes in the plaintext.


Point (1.) is not applicable to the <mark>`RSA.sol`</mark> implementation due to the thorough <u>[check being](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L98-L113)</u>

<u>[performed on the full decrypted signature. On the other hand, points (2.) and (3.) are](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/RSA.sol#L98-L113)</u>

applicable. As a result of the mitigation of point (1.), the padding oracle attack in its original

form is deemed as inapplicable to the specific implementation in <mark>`RSA.sol`</mark> <mark>.</mark>


The above being said, the <mark>`EMSA-PSS`</mark> padding scheme enforces a full check of the format of

the decrypted signature (point 1.). It also binds the hash, the randomness, and the padding

together, which makes any manipulation of the signature easily detectable. Moreover, it fixes

the inherent malleability property of RSA (point 3.), making the scheme non-malleable.

Therefore, in the interest of long-term security, consider switching to the <mark>`EMSA-PSS`</mark> padding

scheme.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_Indeed, EMSA-PSS looks like a better, more modern scheme than EMSA-PKCS1-V1_5_

_which we currently support. We will consider adding support for EMSA-PSS in future_

_releases to improve the coverage of our library. That being said, it is going to take time_


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 33


_to implement, test, and audit. In the meantime, EMSA-PKCS1-V1_5 is what we will_

_support._

### **N-27 Inconsistent Documentation - Phase 2**


The <u>[docstring](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/MerkleTree.sol#L27)</u> above the <mark>`MerkleTree`</mark> library states that the library has been _available since_

_v5.1._ However, this statement is missing from other contracts that are introduced in this version

release.


For consistency, consider either adding this statement to all the contracts or removing it from

the <mark>`MerkleTree`</mark> library.


**_Update:_** _Acknowledged, not resolved. The OpenZeppelin Contracts team stated:_


_These release notes have been added to previous versions since we found them to be_

_relevant in some cases. While the addition of the release notes has not been automated,_

_we decided to leave this note and make it more consistent in future documentation_

_updates._

### **N-28 Naming Suggestions - Phase 2**


Throughout the codebase, multiple instances of inconsistent or unclear naming were identified:


   - The <mark>`MerkleTree`</mark> [library refers to the height of the binary tree both as "depth" [1, 2, 3]](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/MerkleTree.sol#L33)

[and "levels" [4, 5, 6, 7]. Consider sticking to one word for consistency.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/MerkleTree.sol#L53)

   - In the <mark>`Heap`</mark> library documentation, node `i` is <u>[referred to as](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L18)</u> _<u>[father](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L18)</u>_ for the nodes at

index <mark>`2*i+1`</mark> and <mark>`2*i+2`</mark> <mark>.</mark> Consider referring to `i` as the _parent_ node for a more neutral

wording.

   - In the <u><mark>`[pop](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L99-L103)`</mark></u> <u>[function](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/structs/Heap.sol#L99-L103)</u> of <mark>`Heap`</mark> <mark>,</mark> the first node of the data array is saved in the <mark>`rootNode`</mark>

variable, while the actual root node is saved as <mark>`rootData`</mark> <mark>.</mark> Consider renaming

<mark>`rootNode`</mark> <mark>`firstDataNode`</mark> <mark>,</mark> <mark>`rootData`</mark> <mark>`rootNode`</mark> <mark>,</mark> and <mark>`lastNode`</mark> to

<mark>`lastDataNode`</mark> for a more descriptive name.


Consider implementing the above-mentioned naming suggestions to improve the readability

and maintainability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #5215. The third point was resolved with L-07.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5215)</u>_


OpenZeppelin Contracts Release v5.1 Audit − Notes & Additional Information

                                                - 34


## **Client Reported**

### **CR-01 Incorrect Internal Call - Phase 1**

During the audit, the OpenZeppelin Contracts team detected that the <u><mark>`[verifyCallData](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/MerkleProof.sol#L107)`</mark></u> and

<u><mark>`[multiProoVerifyCalldata](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/MerkleProof.sol#L330)`</mark></u> functions of the <mark>`MerkleProof`</mark> library incorrectly call

<mark>`processProof`</mark> and <mark>`processMultiProof`</mark> internally instead of calling the corresponding

calldata variants <u><mark>`[processProofCalldata](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/MerkleProof.sol#L152)`</mark></u> and <u><mark>`[processMultiProofCalldata](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/MerkleProof.sol#L351)`</mark></u> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #5140](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5140)</u>_ _at commit_ _<u>[24a641d.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/24a641d9c9e0137093592a466c5496315626d98d)</u>_

### **CR-02 Incorrect _jAdd Result When a Point Is** **Added to Itself - Phase 2**


This bug was brought to our attention by <u>[Zellic. When the two points input to the](https://reports.zellic.io/publications/biconomy-secp256r1/findings/high-secp256r1-function--jadd-returns-an-incorrect-result-if-the-summands-are-equal)</u> <mark>`_jAdd`</mark>

function in <mark>`P256.sol`</mark> are equal, the function returns the incorrect result (0, 0, 0).


The bug can be triggered along two paths:



1.

2.



<u><mark>`[verifySolidity](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L100)`</mark></u> calls <u><mark>`[_preComputeJacobianPoints](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L289)`</mark></u> calls <u><mark>`[_jAdd](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L185)`</mark></u>

<u><mark>`[verifySolidity](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L100)`</mark></u> calls <u><mark>`[_jMultShamir](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L250)`</mark></u> calls <u><mark>`[_jAdd](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/aba9ff61ac6d610eab12b1528c6f22f98dbb4dd3/contracts/utils/cryptography/P256.sol#L185)`</mark></u>


##### The analysis along path 1 identifies $7$ distinct valid weak private keys that would trigger the d


##### The analysis along path 1 identifies $7$ distinct valid weak private keys that would trigger the d d ∈{1, 2, 3, 2−1, 3−1, 2 3−1, 3 2−1}. Assuming that is chosen uniformly at random d n −1 values, where is a n 256 bit prime, the probability to choose any one of the weak keys is negligible: 256 7 ≈ 0.

<u>2</u> <u>−1</u>


##### bug: d ∈{1, 2, 3, 2−1, 3−1, 2 3−1, 3 2−1}. Assuming that is chosen uniformly at random d


##### among n −1 values, where is a n 256 bit prime, the probability to choose any one of the


##### weak keys is negligible: 256 7 ≈ 0.

<u>2</u> <u>−1</u>


##### 2048 d

While significantly larger than the path 1 case (7
##### 2 256


##### Along path 2, at most 2048 valid weak private keys are estimated that would trigger the bug. d



While significantly larger than the path 1 case (7), the size of this set is still negligible w.r.t. the



size of the whole space 2 <sup>256</sup> . Specifically, the probability of randomly drawing one of the weak



<u>2048</u>
##### keys is at most: 2256−1 ≈ 0.


This analysis is in accordance with Zellic's security reduction argument which states:

##### If an attacker A chooses a (weak) public key and "manages" to compute σ = ( r, s, h )

that passes verification, then he'll also be able to efficiently compute the corresponding
##### (weak) private key from the public key, which will invalidate the hardness of ECDLP d

assumption.


OpenZeppelin Contracts Release v5.1 Audit − Client Reported − 35


In terms of attack scenarios in which the bug can be exploited, we analyzed the following

scenarios (including the two scenarios reported by Zellic):


1. Zellic scenario 1: A holds a private key and valid signatures. However, these get



<mark>.</mark> In detail, A
##### σ = ( r, s, h )



erroneously rejected by <mark>`verifySolidity`</mark> <mark>.</mark> In detail, A chooses a weak public/private


##### key pair and produces a valid signature σ = ( r, s, h ). The signature $\sigma$ will be



rejected due to the bug.

2. Zellic scenario 2: A holds a private key with invalid signatures. However, these get

erroneously accepted by <mark>`verifySolidity`</mark> <mark>.</mark>



3. A



holds a private key with a valid signature. However, it gets erroneously accepted by



<mark>`verifySolidity`</mark> with a public key that does not match the private key by triggering

the bug.


In summary, the reported bug looks highly unlikely to be triggered by chance. It also seems

that the possibilities to exploit it maliciously are very limited and do not have critical

consequences. That being said, it should be noted that if there are other attack scenarios apart

from the ones listed above, they would require further investigation. In addition, the above

analysis assumes that the bug can only be triggered from the <mark>`verifySolidity`</mark> function as

an entry point. Last but not least, the bug clearly identifies an error in the computation,

regardless of any security implications. Therefore, it is recommended to change the <mark>`_jAdd`</mark>

implementation to cover the case where a point is added to itself, as outlined in the Zellic

write-up.


**_Update:_** _Resolved in_ _<u>[pull request #5218](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5218)</u>_ _at commit_ _<u>[d3b67ce.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5218/commits/d3b67ce34111f0d346e33b753e7b8f2943cf5f19)</u>_

## **Recommendations**

### **Protection Against Postquantum Adversaries in** **RSA Signatures**


In view of the fact that blockchain data is public and persists forever, attention can be drawn to

the possibility of adding perfect forward secrecy (PFS) to RSA signatures. This would be done

to prevent the recovery of the private key of a signature from the public key at a point in the

future when computational capabilities are more advanced (e.g., in a post-quantum setting).


PFS is typically associated with key exchange protocols (e.g., DH/ECDH) where session data is

encrypted with a temporary (ephemeral) session key which is discarded at the end of the


OpenZeppelin Contracts Release v5.1 Audit − Recommendations − 36


session. In case the master private key that was used to derive the session key (e.g., using a

hash function) is compromised, the encrypted data that was transmitted in the past cannot be

decrypted in the future.


Adding PFS to signatures is uncommon and, to the best of our knowledge, no signature

schemes exist with this property. Indeed, such functionality would invalidate one of the core

properties of digital signatures, namely non-repudiation, which ensures that a signer is not able

to deny signing a piece of data after the fact. On the other hand, the relatively recent

emergence of blockchains presents new use cases that may, to some extent, justify the

suggested modification.


Specifically, the fact that blockchain data is public and persists forever may allow post
quantum adversaries to recover the private key of a signature from the public key using

quantum computers. With PFS, the negative consequences from the latter will be prevented by

having an analogous notion of temporary private keys for signing that would be valid for a long,

but fixed, period of time (say, 10-20 years).


We suspect that adding PFS to digital signatures may require some non-trivial changes to the

signing and verification process. Yet, the changes would probably be more on the signer's

side, while the verifier would just need to discard signatures produced under invalid (i.e.,

expired) keys.


OpenZeppelin Contracts Release v5.1 Audit − Recommendations − 37


## **Conclusion**

The v5.1 release of OpenZeppelin Contracts introduces several significant enhancements,

including the addition of a cliff period to the vesting wallet, support for fractional voting in

governance, implementations of the ERC-1363 and ERC-7674 standards, as well as new

implementations of data structures and cryptographic libraries. We commend the Solidity

Contracts team for addressing user needs and their efforts to improve existing features while

introducing new utilities.


Throughout the six-week engagement, three medium-severity vulnerability were identified.

Furthermore, several recommendations were provided to adhere to best practices and

minimize the attack surface. Special attention was given to documenting edge cases to ensure

that integrators are aware of potential risks when interacting with these contracts. These efforts

are intended to foster the development of a more resilient codebase keeping in mind the

library’s significance as a foundational element in the blockchain ecosystem. We are again very

grateful for the opportunity to collaborate with the Contracts team on this next milestone.


OpenZeppelin Contracts Release v5.1 Audit − Conclusion − 38


