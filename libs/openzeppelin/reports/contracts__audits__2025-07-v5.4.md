### | security

# **OpenZeppelin** **Contracts** **Release v5.4 Diff** **Audit**

#### **July 17, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  7

ERC-7913 (Signatures by Address-Less Keys) 7

ERC-7821 (Batch Executor Interface) 8

EIP-2935 (Access to Historical Block Hashes) 8

Keyed Nonces 8

Enhancements to EnumerableMap and EnumerableSet 8

Ports from Community Contracts 9

Trivial Modifications 9


Security Model and Trust Assumptions _______________________________________________  9


Low Severity ____________________________________________________________________ 10

L-01 Possible Overflow when Computing the Total Weight of ERC-7913 Multisigners 10

L-02 _setSignerWeights Does Not Check if the Weight Has Changed 11

L-03 Name for Elements in Set Struct is Potentially Confusing 11

L-04 Missing External Call Failure Check 12

L-05 Variable Names Too Similar 13

L-06 Incomplete Docstrings 13

L-07 Possible Duplicate Event Emission 15

L-08 Different Pragma Directives 15


Notes & Additional Information ____________________________________________________ 16

N-01 Minor Inconsistencies in the Implementations of Map and Set 16

N-02 Inner Mapping Only Has One Named Parameter 17

N-03 Functions Updating State Without Event Emissions 18

N-04 Redundant return Statements 18

N-05 Missing Security Contact 19

N-06 Lack of Indexed Event Parameter 20

N-07 File and Contract Names Mismatch 20

N-08 Custom Errors in require Statements 21

N-09 Documentation Improvements 22

N-10 Typographical Errors 24

N-11 Missing immediate Parameter in canCall Function 25


Client Reported __________________________________________________________________ 25

CR-01 Allowing Zero Threshold in ERC-7913 Multisigner 25


OpenZeppelin Contracts Release v5.4 Diff Audit − Table of Contents − 2


CR-02 Out-of-bound Memory Read in Bytes.lastIndexOf 26


Conclusion ______________________________________________________________________ 27


OpenZeppelin Contracts Release v5.4 Diff Audit − Table of Contents − 3


## **Summary**

**Type** Library


**Timeline** From 2025-06-16
To 2025-07-02


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



**Total Issues** 21 (6 resolved, 2 partially resolved)



**Low Severity Issues** 8 (2 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



11 (2 resolved, 2 partially resolved)


2 (2 resolved)



OpenZeppelin Contracts Release v5.4 Diff Audit − Summary − 4


## **Scope**

[OpenZeppelin audited the OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/) repository at commit

<u>[f6fea857](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/f6fea85717b1a09300c7a783554696a0d6f3df12)</u> (release v5.4). This commit was compared with commit <u>[e4f7021](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/e4f70216d759d8e6a64144a9e1f7bbeed78e7079)</u> (release v5.3) and all

new files were fully audited.


In scope were the following files:

```
contracts
├── access
│  ├── extensions
│  |  ├── AccessControlDefaultAdminRules.sol
│  |  └── AccessControlEnumerable.sol
│  ├── manager
|  |  ├── AccessManaged.sol
|  |  └── IAccessManager.sol
│  └── AccessControl.sol
├── account
|  ├── extensions
|  |  ├── draft-AccountERC7579.sol
|  |  ├── draft-AccountERC7579Hooked.sol
|  |  └── ERC7821.sol
|  ├── interfaces
|  |  └── IERC7913.sol
|  ├── utils
|  |  └── draft-ERC7579utils.sol
|  └── Account.sol
├── governance
|  ├── extensions
|  |  ├── GovernorCountingFractional.sol
|  |  ├── GovernorCountingOverridable.sol
|  |  ├── GovernorCountingSimple.sol
|  |  ├── GovernorNoncesKeyed.sol
|  |  ├── GovernorSequentialProposalId.sol
|  |  ├── GovernorSettings.sol
|  |  ├── GovernorSuperQuorum.sol
|  |  ├── GovernorTimelockAccess.sol
|  |  ├── GovernorTimelockCompound.sol
|  |  ├── GovernorTimelockControl.sol
|  |  └── GovernorVotes.sol
|  ├── Governor.sol
|  └── TimeLockController.sol
├── interfaces
|  └── draft-ERC7821.sol
├── token
|  ├── common
|  |  └── ERC2981.sol
|  ├── ERC20

```

OpenZeppelin Contracts Release v5.4 Diff Audit − Scope − 5


```
|  |  ├── extensions
|  |  |  ├── ERC20capped.sol
|  |  |  ├── ERC20Permit.sol
|  |  |  ├── ERC20Wrapper.sol
|  |  |  ├── ERC1363.sol
|  |  |  └── ERC4626.sol
|  |  ├── utils
|  |  |  └── ERC1363Utils.sol
|  |  └── ERC20.sol
|  ├── ERC721
|  |  ├── extensions
|  |  |  ├── ERC721Enumerable.sol
|  |  |  ├── ERC721Royalty.sol
|  |  |  └── ERC721URIStorage.sol
|  |  ├── utils
|  |  |  └── ERC721Utils.sol
|  |  └── ERC721.sol
|  └── ERC1155
|    ├── extensions
|    |  └── ERC1155Supply.sol
|    ├── utils
|    |  ├── ERC1155Holder.sol
|    |  └── ERC1155Utils.sol
|    └── ERC1155.sol
└── utils
├── cryptography
|  ├── signers
|  |  └── draft-ERC7739.sol
|  ├── AbstractSigner.sol
|  ├── draft-ERC7739.sol
|  ├── EIP712.sol
|  ├── MultiSignerERC7913.sol
|  ├── MultiSignerERC7913Weighted.sol
|  ├── SignatureChecker.sol
|  ├── SignerECDSA.sol
|  ├── SignerERC7702.sol
|  ├── SignerERC7913.sol
|  ├── SignerP256.sol
|  └── SignerRSA.sol
├── introspection
|  └── ERC165.sol
├── structs
|  ├── EnumerableMap.sol
|  └── EnumerableSet.sol
├── Address.sol
├── Arrays.sol
├── Base64.sol
├── Blockhash.sol
├── Bytes.sol
└── Strings.sol

```

OpenZeppelin Contracts Release v5.4 Diff Audit − Scope − 6


## **System Overview**

Version 5.4 of the OpenZeppelin Contracts library introduces new features, including support

for ERC-7913, ERC-7821, EIP-2935, a keyed-nonces extension to the governance module,

enhancements to the enumerable map and set libraries, and porting of several contracts from

[the OpenZeppelin/openzeppelin-community-contracts](https://github.com/OpenZeppelin/openzeppelin-community-contracts) repository. In addition, multiple files

were updated with trivial modifications, such as improved documentation, imports, and minor

refactoring.

### **ERC-7913 (Signatures by Address-Less Keys)**


The <mark>`SignerERC7913`</mark> contract inherits <mark>`AbstractSigner`</mark> and implements signature

verification for address-less keys following the <u>[ERC-7913](https://eips.ethereum.org/EIPS/eip-7913)</u> standard. A multi-signature signer

system using multiple <u>[ERC-7913](https://eips.ethereum.org/EIPS/eip-7913)</u> signers is implemented in the <mark>`MultiSignerERC7913`</mark>

contract, providing the following functionality:









Manage a dynamic set of signers (e.g., EOA or smart contract signers).

Require a threshold number of valid signatures for authorizing operations.

Be compatible with both ECDSA (EOA) signatures and <u>[ERC-1271](https://eips.ethereum.org/EIPS/eip-1271)</u> smart contract

signatures.



The new functionality allows clients to build accounts or wallets where actions must be jointly

authorized by multiple parties.


The <mark>`MultiSignerERC7913`</mark> contract is further extended by

<mark>`MultiSignerERC7913Weighted`</mark> <mark>,</mark> which adds support for weighted signatures. Specifically,

it assigns different positive weights to each signer, enabling more flexible governance

schemes. For example, some signers could have a higher weight than others, allowing for

weighted voting or prioritized authorization. The threshold for validation is reached when the

sum of the weights of the unique signers of a message crosses the threshold value.


Another relevant new contract is <mark>`SignatureChecker`</mark> <mark>,</mark> which is a helper for streamlining the

verification of ECDSA, ERC-1271, and ERC-7913 signatures.


OpenZeppelin Contracts Release v5.4 Diff Audit − System Overview − 7


### **ERC-7821 (Batch Executor Interface)**

The <mark>`ERC7821`</mark> contract (and its associated interface <mark>`IERC7821`</mark> <mark>)</mark> [implements the ERC-7821](https://eips.ethereum.org/EIPS/eip-7821)

standard for batch execution. The latter defines a standardized interface for executing one or

more function calls atomically and is intended for use by smart contract wallets, <u>[EIP-7702](https://eips.ethereum.org/EIPS/eip-7702)</u>

EOAs, and <u>[ERC-4337](https://eips.ethereum.org/EIPS/eip-4337)</u> smart accounts.

### **EIP-2935 (Access to Historical Block Hashes)**


The <mark>`Blockhash`</mark> contract implements block hash access beyond the 256-block limit following

[the EIP-2935](https://eips.ethereum.org/EIPS/eip-2935) standard. It preserves support for the native <mark>`BLOCKHASH`</mark> opcode as a fallback.

Specifically, the ability to retrieve block hashes is extended to 8191 blocks in the past. In case

the block is within the last 256 blocks, the native <mark>`BLOCKHASH`</mark> EVM opcode is used. In case

the block is between 256 and 8191 blocks ago, an EVM-reserved history storage contract at a

hard-coded address is called, which keeps a record of the last 8191 block hashes in its state.

For all other blocks (including future blocks), the return value is zero.

### **Keyed Nonces**


The <mark>`GovernorNoncesKeyed`</mark> contract inherits <mark>`Governor`</mark> and <mark>`NoncesKeyed`</mark> and

implements the _keyed nonce_ abstraction when voting by signature. Traditional, un-keyed

nonces prevent the replaying of votes on proposals. On the other hand, keyed nonces provide

a kind of domain separation by proposal ID, so that many nonces can be incremented in

parallel for different proposals. In the <mark>`GovernorNoncesKeyed`</mark> contract, this is achieved by

using the first 192 bits of the <mark>`proposalID`</mark> as the key.

### **Enhancements to EnumerableMap and** **`EnumerableSet`**


Enhancements were made to the <mark>`EnumerableMap`</mark> and <mark>`EnumerableSet`</mark> libraries. These

implement an enumerable version of Solidity's native mapping and an enumerable set data

structure, respectively. Specifically, in <mark>`EnumerableMap`</mark> <mark>,</mark> for all supported maps, a new <mark>`keys`</mark>

function has been added that returns a slice of the keys stored in the map, as opposed to the

full list of keys. In addition, a new map, <mark>`BytesToBytesMap`</mark> <mark>,</mark> along with all associated

methods supported by the other maps, has been implemented. In <mark>`EnumerableSet`</mark> <mark>,</mark> to all

supported sets, a new <mark>`values`</mark> function has been added for sliced access to the values in the

set, along with two new sets, <mark>`Bytes`</mark> and <mark>`StringSet`</mark> <mark>,</mark> and their associated methods.


OpenZeppelin Contracts Release v5.4 Diff Audit − System Overview − 8


### **Ports from Community Contracts**

Multiple contracts were moved from the <u>[OpenZeppelin/openzeppelin-community-contracts](https://github.com/OpenZeppelin/openzeppelin-community-contracts)</u>

repository after minor modifications. These include verification of ECDSA, RSA, and P-256

signatures, libraries providing utility functions for <u>[ERC-7739](https://ercs.ethereum.org/ERCS/erc-7739)</u> [and ERC-7579, and a contract](https://eips.ethereum.org/EIPS/eip-7579)

[implementing EIP-712.](https://eips.ethereum.org/EIPS/eip-712)

### **Trivial Modifications**


All files in scope that are not related to any of the new functionalities mentioned in the

preceding sections contain only trivial modifications such as documentation updates, imports,

and minor refactoring.

## **Security Model and Trust** **Assumptions**


During the audit, a trust assumption was made that the <mark>`HISTORY_STORAGE_ADDRESS`</mark>

<u>[hardcoded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/Blockhash.sol#L18C31-L18C54)</u> value in the <mark>`Blockhash`</mark> library points to the correct EVM precompile.


OpenZeppelin Contracts Release v5.4 Diff Audit − Security Model and Trust

Assumptions − 9


## **Low Severity**

### **L-01 Possible Overflow when Computing the** **Total Weight of ERC-7913 Multisigners**

The <u><mark>`[totalWeight](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L79)`</mark></u> function returns a <mark>`uint64`</mark> value by <u>[casting](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L80)</u> <mark>`getSignerCount() +`</mark>

<mark>`_totalExtraWeight`</mark> to <mark>`uint64`</mark> <mark>.</mark> However, <mark>`getSignerCount`</mark> <u>[returns](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L86)</u> a <mark>`uint256`</mark> value.

Therefore, theoretically, an overflow may occur before the cast operation. This will happen if

the number of signers or their total weight <u><mark>`[_totalExtraWeight](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L51)`</mark></u> (or both) is close to or larger

than <mark>`2^64-1`</mark> <mark>,</mark> which is not likely to occur in practice.


Regardless of the low risk, consider reverting in case of an overflow.


**_Update:_** _[Resolved in pull request #5790. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5790/files)_


_The totalWeight() does the addition of :_


_-_ _<mark>`getSignerCount()`</mark>_ _(an uint256)_


_-_ _<mark>`_totalExtraWeight`</mark>_ _(an uint64)_


_This add operation is done on the "uint256 space". If_ _<mark>`getSignerCount()`</mark>_ _is close to_

_<mark>`2^256-1`</mark>_ _<mark>,</mark>_ _and if_ _<mark>`_totalExtraWeight`</mark>_ _makes up for the difference, then that_

_addition could technically overflow._


_However, we are using solidity ^0.8.27 for this file. Since solidity 0.8.0 all arithmetic_

_operations are "checked" by default. Here there is no_ _<mark>`unchecked`</mark>_ _block, so any_

_overflow (prior to the casting) will revert. Solidity takes care of that._


_Said otherwise: the compiler already performs overflow detection here. Doing it_

_ourselves would just duplicate the verification cost with no upside._


_The only way we see having_ _<mark>`totalWeight()`</mark>_ _overflow though is by first setting the_

_signer weights so that_ _<mark>`totalWeight()`</mark>_ _is almost_ _<mark>`2^64`</mark>_ _and then add new signers_

_(with a default weight of 1). We address this scenario with the fix in the provided pull_

_request._


OpenZeppelin Contracts Release v5.4 Diff Audit − Low Severity − 10


### **L-02 _setSignerWeights Does Not Check if the** **Weight Has Changed**

When calling the <u><mark>`[_setSignerWeights](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L95)`</mark></u> function in <u><mark>`[MultiSignerERC7913Weighted.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol)`</mark></u> <mark>,</mark>

it is possible to pass in a list of signers and weights where one or more entries are equal to the

current signer and weight. For example, suppose <mark>`signer1`</mark> is a <mark>`bytes`</mark> object and

<mark>`_extraWeights[signer1] == 1`</mark> so that <mark>`signer1`</mark> has a weight of 2, and we call

<mark>`_setSignerWeights([signer1], [2])`</mark> <mark>.</mark> Then, the following happens:



1.

2.

3.

4.

5.



<u><mark>`[extraWeightRemoved](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L109)`</mark></u> is incremented by 1.

<u><mark>`[extraWeightAdded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L110)`</mark></u> is incremented by 1.

<u><mark>`[ERC7913SignerWeightChanged(signer1, 2)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L113)`</mark></u> is emitted.

<u><mark>`[_totalExtraWeight](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L118)`</mark></u> is updated to the same value it was before.

<u><mark>`[_validateReachableThreshold()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L120)`</mark></u> is called.



In the above scenario, unnecessary computations are performed and events are emitted

without a state change.


To save gas and avoid unnecessary event emissions, consider validating that for each <mark>`i <`</mark>

<mark>`signers.length`</mark> <mark>,</mark> the weight to be set for the signer is equal to the signer's current weight.


**_Update:_** _[Resolved in pull request #5775.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5775)_

### **L-03 Name for Elements in Set Struct is** **Potentially Confusing**


Within the <mark>`Set`</mark> struct of the <u><mark>`[EnumerableSet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol)`</mark></u> library, the elements of the set are stored as a

<mark>`bytes32[]`</mark> array named <u><mark>`[_values](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L62)`</mark></u> <mark>.</mark> The corresponding <mark>`private`</mark> getter functions

<u><mark>`[_values(set)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L176)`</mark></u> and <u><mark>`[values(set, start, end)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L188)`</mark></u> <mark>,</mark> along with the <mark>`internal`</mark> getter

functions <u><mark>`[values(set)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L274)`</mark></u> and <u><mark>`[values(set, start, end)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L293)`</mark></u> for structs that wrap the <mark>`Set`</mark>

struct (e.g., <mark>`Bytes32Set`</mark> <mark>)</mark>, are also named similarly.


While this hews closely to the terminology of mappings, it has the unfortunate consequence

[that, in the keys](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L191) function for the <mark>`Bytes32ToBytes32Map`</mark> map in <u><mark>`[EnumerableMap.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol)`</mark></u> and

throughout the file, there is phrasing such as <mark>`return map._keys.values(start, end);`</mark> <mark>.</mark>

However, this does not relate to the values of the enumerable map. Instead, it returns a slice of

the set of keys. This is likely to cause some confusion between the values of the outer

enumerable map with the "values" of the inner enumerable set.


OpenZeppelin Contracts Release v5.4 Diff Audit − Low Severity − 11


Since "element" is the standard mathematical term for a member of a set, adopting this

terminology will help emphasize the abstraction of the <mark>`Set`</mark> data structure. In addition, this can

help differentiate between <mark>`Set`</mark> <mark>s</mark> from Solidity mappings and each of the enumerable map

structs given in <mark>`EnumerableMap.sol`</mark> <mark>.</mark> As such, consider renaming the <mark>`_values`</mark> field of the

<mark>`Set`</mark> struct, as well as the associated getter functions of <mark>`Set`</mark> and other structs that wrap it, to

<mark>`elements`</mark> <mark>.</mark>


**_Update:_** _Acknowledged, not resolved. The team stated:_


_Changing from_ _<mark>`values()`</mark>_ _to_ _<mark>`elements()`</mark>_ _would be a breaking API change affecting_

_all EnumerableSet types, requiring ecosystem-wide updates._


_However, the current naming is already reasonably clear,_ _<mark>`map._keys.values()`</mark>_

_indicates we're accessing values from the keys collection. Since users shouldn't directly_

_access internal structures like_ _<mark>`_keys`</mark>_ _anyway, optimizing clarity for discouraged usage_

_patterns isn't a priority._


_The change would also require upgradeable plugin configuration and impose significant_

_migration costs for minimal practical benefit. We'll keep the current naming for now,_

_since the theoretical improvement doesn't justify the breaking change impact._

### **L-04 Missing External Call Failure Check**


To satisfy <u>[EEA EthTrust Security Level [S], code that makes external calls using the low-level](https://entethalliance.github.io/eta-registry/security-levels-spec.html#sec-levels-one)</u>

call functions (i.e., <mark>`call`</mark> <mark>,</mark> <mark>`delegatecall`</mark> <mark>,</mark> <mark>`staticcall`</mark> <mark>,</mark> <mark>`send`</mark> <mark>,</mark> and <mark>`transfer`</mark> <mark>)</mark> MUST

check the returned value from each usage to determine whether the call failed. Normally,

exceptions in subcalls 'bubble up', unless they are handled in a <mark>`try-catch`</mark> block. However,

Solidity defines a set of low-level call functions that do not have built-in safety checks: <mark>`call`</mark> <mark>,</mark>

<mark>`delegatecall`</mark> <mark>,</mark> <mark>`staticcall`</mark> <mark>,</mark> <mark>`send`</mark> <mark>,</mark> and <mark>`transfer`</mark> <mark>.</mark> Calls made using these functions

behave differently. Specifically, they return a boolean indicating whether the call completed

successfully. As such, not explicitly testing the return values of these calls for failure may lead

to unexpected behavior in the caller contract.


The <u><mark>`[staticcall(gas(), HISTORY_STORAGE_ADDRESS, 0x00, 0x20, 0x20, 0x20)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/Blockhash.sol#L46)`</mark></u>

call within the <mark>`_historyStorageCall`</mark> contract in <mark>`Blockhash.sol`</mark> is missing a failure

check.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_The_ _<mark>`staticcall`</mark>_ _to_ _<mark>`HISTORY_STORAGE_ADDRESS`</mark>_ _has guaranteed success_

_semantics by design:_


OpenZeppelin Contracts Release v5.4 Diff Audit − Low Severity − 12


_- If EIP-2935 code exists at the address, it follows the specification and never reverts_


_- If no code exists, the call succeeds with empty return data_


_In both cases, the success boolean is always_ _<mark>`true`</mark>_ _<mark>.</mark>_ _Adding a redundant check would_

_consume gas without providing any safety benefit. This is an acceptable exception to_

_the general rule given the well-defined behavior of EIP-2935._

### **L-05 Variable Names Too Similar**


Similar variable names make the code challenging to read and maintain, and can introduce

confusion during the auditing process. Within <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> <u><mark>`[signature](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L203)`</mark></u> is

similar to <u><mark>`[signatures](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L206)`</mark></u> <mark>.</mark> Other than the similarity, another argument in favor of renaming is that

the <mark>`signature`</mark> array does not contain only signatures. In fact it encodes two arrays - a

<mark>`signatures`</mark> and a <mark>`signers`</mark> array.


Consider renaming the variables using clear and descriptive variable names and adhering to a

naming convention.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_We're keeping the naming, since the team agrees that its distinction is semantically_

_meaningful:_ _<mark>`signature`</mark>_ _represents the composite multisig signature inspired by_

_ERC-1271, while_ _<mark>`signatures`</mark>_ _are the individual signatures that compose it._


_This naming conveys the conceptual relationship between the aggregated signature and_

_its parts. The variables serve distinctly different purposes in the multisig verification_

_process, making the current naming both logical and maintainable._

### **L-06 Incomplete Docstrings**


Throughout the codebase, multiple instances of incomplete docstrings were identified:











In <mark>`draft-ERC7821.sol`</mark> <mark>,</mark> in the <u><mark>`[execute](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol#L29-L34)`</mark></u> function, the <mark>`mode`</mark> and <mark>`executionData`</mark>

parameters are not documented.

In <mark>`IERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[verify](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/interfaces/IERC7913.sol#L16)`</mark></u> function:

  - the <mark>`key`</mark> <mark>,</mark> <mark>`hash`</mark> <mark>,</mark> <mark>`signature`</mark> parameters are not documented

  - not all return values are documented

In <mark>`draft-IERC7821.sol`</mark> <mark>,</mark> in the <u><mark>`[execute](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/interfaces/draft-IERC7821.sol#L34)`</mark></u> function, the <mark>`mode`</mark> and <mark>`executionData`</mark>

parameters are not documented.


OpenZeppelin Contracts Release v5.4 Diff Audit − Low Severity − 13


In <mark>`draft-IERC7821.sol`</mark> <mark>,</mark> in the <u><mark>`[supportsExecutionMode](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/interfaces/draft-IERC7821.sol#L42)`</mark></u> function:

  - the <mark>`mode`</mark> parameter is not documented

  - not all return values are documented

In <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[ERC7913SignerAdded](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L52)`</mark></u> event, the <mark>`signers`</mark>

parameter is not documented.

In <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[ERC7913SignerRemoved](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L55)`</mark></u> event, the

<mark>`signers`</mark> parameter is not documented.

In <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[ERC7913ThresholdSet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L58)`</mark></u> event, the

<mark>`threshold`</mark> parameter is not documented.

In <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[getSigners](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L86-L88)`</mark></u> function:

  - the <mark>`start`</mark> and <mark>`end`</mark> parameters are not documented

  - not all return values are documented

In <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[getSignerCount](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L86-L88)`</mark></u> function, not all return

values are documented.

In <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[isSigner](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L91-L93)`</mark></u> function:

  - the <mark>`signer`</mark> parameter is not documented

  - not all return values are documented

In <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[threshold](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L96-L98)`</mark></u> function, not all return values are

documented.

In <mark>`MultiSignerERC7913Weighted.sol`</mark> <mark>,</mark> in the <u><mark>`[ERC7913SignerWeightChanged](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L62)`</mark></u>

event, the <mark>`signer`</mark> and <mark>`weight`</mark> parameters are not documented.

In <mark>`MultiSignerERC7913Weighted.sol`</mark> <mark>,</mark> in the <u><mark>`[signerWeight](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L77-L81)`</mark></u> function:

  - the <mark>`signer`</mark> parameter is not documented

  - not all return values are documented

In <mark>`MultiSignerERC7913Weighted.sol`</mark> <mark>,</mark> in the <u><mark>`[totalWeight](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L79-L81)`</mark></u> function, not all

return values are documented.

In <mark>`SignerERC7913.sol`</mark> <mark>,</mark> in the <u><mark>`[signer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/SignerERC7913.sol#L40-L42)`</mark></u> function, not all return values are

documented.



Consider thoroughly documenting all functions/events (and their parameters or return values)

that are part of a contract's public API. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Acknowledged, not resolved. The team stated:_


_The documentation pattern is intentionally consistent across the entire OpenZeppelin_

_library. Parameter and return value documentation is omitted because our_

_documentation engine doesn't render these NatSpec elements._


OpenZeppelin Contracts Release v5.4 Diff Audit − Low Severity − 14


_Adding parameter/return documentation would create inconsistency with the_

_established codebase style without providing user-facing benefits. The current approach_

_prioritizes meaningful function descriptions over unused documentation elements._

### **L-07 Possible Duplicate Event Emission**


When a setter function does not check if the incoming value is different from the existing one, it

opens up the possibility of spamming events that indicate a change even when no actual

change has occurred. Spamming identical values may confuse off-chain clients that rely on

event data to track state changes.


Within <u><mark>`[MultiSignerERC7913.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol)`</mark></u> <mark>,</mark> the <u><mark>`[_setThreshold](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L143-L147)`</mark></u> function sets the <mark>`_threshold`</mark>

value and emits an event without checking if the value has changed.


Consider adding a check statement to revert the transaction if the incoming value is identical to

the existing one.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_OpenZeppelin contracts consistently allow no-ops that emit events (e.g., zero-value_

_transfers, unchanged approvals). Adding threshold-specific checks would break this_

_design pattern._


_The current behavior maintains consistency across the codebase._

### **L-08 Different Pragma Directives**


In order to clearly identify the Solidity version with which the contracts will be compiled,

pragma directives should be fixed and consistent across file imports.


Throughout the codebase, multiple instances of different pragma directives were identified:











<mark>`draft-ERC7821.sol`</mark> has the pragma directive <u><mark>`[pragma solidity ^0.8.20;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol#L3)`</mark></u> and

imports the file <u><mark>`[draft-IERC7821.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/account/extensions/draft-ERC7821.sol#L6)`</mark></u> <mark>,</mark> which has a different pragma directive.

<mark>`GovernorNoncesKeyed.sol`</mark> has the pragma directive <u><mark>`[pragma solidity](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/governance/extensions/GovernorNoncesKeyed.sol#L3)`</mark></u>

<u><mark>`[^0.8.24;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/governance/extensions/GovernorNoncesKeyed.sol#L3)`</mark></u> and imports the file <u><mark>`[NoncesKeyed.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L7)`</mark></u> <mark>,</mark> which has a different pragma

directive.

<mark>`MultiSignerERC7913Weighted.sol`</mark> has the pragma directive <u><mark>`[pragma solidity](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L3)`</mark></u>

<u><mark>`[^0.8.27;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L3)`</mark></u> and imports the file <u><mark>`[MultiSignerERC7913.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol#L6)`</mark></u> <mark>,</mark> which has a different

pragma directive.


OpenZeppelin Contracts Release v5.4 Diff Audit − Low Severity − 15


Consider using the same fixed pragma version across all the files.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_We try to minimise the pragma each file uses. If a contract only doesn't need any feature_

_introduced after 0.8.20, we have no reason to not mark it ^0.8.20. We use 0.8.20 as our_

_minimum (for non-interface files), because it introduced push0 that we believe to be a_

_great optimisation._


_Some files will depend on a file that uses ^0.8.20 but wil also use additional feature that_

_were added to the language later. In that case we use a pragma that reflect this_

_requirement._


_We have test in place to ensure that: all contract can be compile with the pragma being_

_used (for example not contract that uses ^0.8.20 will be compilable with 0.8.20, and_

_won't use any feature introduced after that)_


_A consequence of this test, is that if B imports A, B's pragma will be equal or more_

_restrictive than A's pragma._

## **Notes & Additional** **Information**

### **N-01 Minor Inconsistencies in the** **Implementations of Map and Set**


Multiple instances of minor inconsistencies in the implementation of the methods for

<mark>`BytesToBytesMap`</mark> and other maps (e.g., <mark>`Bytes32ToBytes32Map`</mark> <mark>)</mark> were identified:











[The at](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1253) function for <mark>`BytesToBytesMap`</mark> differs from the <u>[at](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L133)</u> function for

<mark>`Bytes32ToBytes32Map`</mark> in that it has an implicit <mark>`return`</mark> <mark>.</mark>

The <u><mark>`[tryGet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1265)`</mark></u> function for <mark>`BytesToBytesMap`</mark> differs from the <u><mark>`[tryGet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L142)`</mark></u> for

<mark>`Bytes32ToBytes32Map`</mark> in that it avoids the explicit <mark>`if-else`</mark> branches.

[The get](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1280) function for <mark>`BytesToBytesMap`</mark> uses <u><mark>`[tryGet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1282)`</mark></u> while the <u><mark>`[get](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L158)`</mark></u> function for

<mark>`Bytes32ToBytes32Map`</mark> duplicates the logic of the corresponding <mark>`tryGet`</mark> for the

type.


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 16


Similarly, in <u><mark>`[EnumerableSet.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol)`</mark></u> <mark>,</mark> the different methods for the <mark>`StringSet`</mark> and <mark>`ByteSet`</mark>

types name the input set variable either as <mark>`set`</mark> or <mark>`self`</mark> (e.g., <u>[self](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L522)</u> vs. <u>[set](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L580)</u> [and self](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L664) vs. <u>[set). In](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L722)</u>

contrast, the methods for the other types consistently use <mark>`set`</mark> <mark>.</mark>


Consider making the implementations consistent across the different map and set types.


**_Update:_** _Partially resolved in_ _<u>[pull request #5776. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5776)</u>_


_We partially addressed the issue by standardizing parameter naming_ _<mark>(</mark>_ _<mark>`self`</mark>_ **_→_** _<mark>`set`</mark>_ _<mark>)</mark>_ _but_

_kept other inconsistencies._


_BytesToBytesMap handles memory types differently than value-type maps, requiring_

_distinct patterns like implicit returns and specialized memory handling. These_

_differences are functional requirements, not stylistic inconsistencies that need_

_correction._

### **N-02 Inner Mapping Only Has One Named** **Parameter**


In the <u><mark>`[Bytes32ToBytes32Map](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L70)`</mark></u> and <u><mark>`[BytesToBytesMap](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1190)`</mark></u> structs, the "key" parameter of the

inner mapping is named <mark>`key`</mark> <mark>,</mark> but the "value" parameter is unnamed. Similarly, in the <u><mark>`[Set](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L65)`</mark></u> <mark>,</mark>

<u><mark>`[StringSet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L513)`</mark></u> <mark>,</mark> and <u><mark>`[BytesSet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L650)`</mark></u> structs, the "key" parameter of the <mark>`_positions`</mark> mapping is

named <mark>`value`</mark> <mark>,</mark> but the "value" parameter is unnamed.


For consistency, consider naming both parameters in each mapping.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_Acknowledged. The naming convention is intentional and follows established patterns_

_across OpenZeppelin contracts (e.g., ERC20's_ _<mark>`_balances`</mark>_ _<mark>,</mark>_ _<mark>`_allowances`</mark>_ _<mark>)</mark>_ _._


_Key parameters are named for clarity since they're often non-obvious. Value parameters_

_remain unnamed when the mapping name itself clearly indicates the stored type (e.g.,_

_<mark>`_values`</mark>_ _mapping obviously stores values). Adding redundant naming like_

_<mark>`mapping(bytes32 key => bytes32 value) _values`</mark>_ _would be unnecessarily_

_verbose._


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 17


### **N-03 Functions Updating State Without Event** **Emissions**

The <u><mark>`[_setSigner](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/SignerERC7913.sol#L40-L42)`</mark></u> <u>function</u> in <mark>`SignerERC7913.sol`</mark> updates the state without an event

emission.


Consider emitting events whenever there are state changes to improve the clarity of the

codebase and make it less error-prone.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_This is true for all_ _<mark>`Signer*.sol`</mark>_ _contracts (_ _<mark>`SignerECDSA`</mark>_ _<mark>,</mark>_ _<mark>`SignerP256`</mark>_ _,_

_<mark>`SignerRSA`</mark>_ _<mark>)</mark>_ _. All have a function_ _<mark>`_setSigner`</mark>_ _to update the key that doesn't emit an_

_event._


_These are low level abstractions, that should interfere as little as possible with the_

_contracts that inherit from, them. In many cases, the key will be set at construction and_

_never updated._


_If a user decides to expose the internal_ _<mark>`_setSigner`</mark>_ _function, they should emit an_

_event themselves._

### **N-04 Redundant return Statements**


Functions that have named returns do not require explicit <mark>`return`</mark> statements.


Throughout the codebase, multiple instances of redundant <mark>`return`</mark> statements were

identified:










The <u><mark>`[return callType == ERC7579Utils.CALLTYPE_BATCH && execType ==](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol#L39-L42)`</mark></u>
```
ERC7579Utils.EXECTYPE_DEFAULT && modeSelector ==
```

<u><mark>`[ModeSelector.wrap(0x00000000);](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol#L39-L42)`</mark></u> statement in <mark>`draft-ERC7821.sol`</mark>

The <u><mark>`[return false;](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L228)`</mark></u> statement in <mark>`MultiSignerERC7913.sol`</mark>

The <u><mark>`[return hash.areValidSignaturesNow(signers, signatures);](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L231)`</mark></u>

statement in <mark>`MultiSignerERC7913.sol`</mark>



To improve code clarity, consider removing <mark>`return`</mark> statements from functions that have

named returns.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_Not going to fix._


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 18


_Note that in the case of_ _<mark>`MultiSignerERC7913.sol`</mark>_ _<mark>,</mark>_ _the_ _<mark>`return false`</mark>_ _is used to_

_break the execution of the loop and force an early return. Writing false to the return_

_variable and continuing the execution would just not work._

### **N-05 Missing Security Contact**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability

in the code. This practice is quite beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so. In addition, if the contract

incorporates third-party libraries and a bug surfaces in those, it becomes easier for their

maintainers to contact the appropriate person about the problem and provide mitigation

instructions.


Throughout the codebase, multiple instances of contracts missing a security contact were

identified:














The <u><mark>`[ERC7821](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol)`</mark></u> <u>[abstract contract](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol)</u>

The <u><mark>`[GovernorNoncesKeyed](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/governance/extensions/GovernorNoncesKeyed.sol)`</mark></u> <u>abstract contract</u>

The <u><mark>`[IERC7913SignatureVerifier](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/interfaces/IERC7913.sol)`</mark></u> <u>interface</u>

The <u><mark>`[IERC7821](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/interfaces/draft-IERC7821.sol)`</mark></u> <u>interface</u>

The <u><mark>`[Blockhash](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/Blockhash.sol)`</mark></u> <u>library</u>

The <u><mark>`[MultiSignerERC7913](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol)`</mark></u> <u>abstract contract</u>

The <u><mark>`[MultiSignerERC7913Weighted](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913Weighted.sol)`</mark></u> <u>abstract contract</u>

The <u><mark>`[SignerERC7913](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/SignerERC7913.sol)`</mark></u> <u>abstract contract</u>



Consider adding a NatSpec comment containing a security contact above each contract

definition. Using the <mark>`@custom:security-contact`</mark> convention is recommended as it has

[been adopted by the OpenZeppelin Wizard](https://wizard.openzeppelin.com/) [and the ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)


**_Update:_** _Acknowledged, not resolved. The team stated:_


_This is not what the security contact comment is designed for._


_The security contact is something deployers / and users add to there code so that we_

_(OZ) know how to contact them in case we ever identify their contract as vulnerable._

_When we identify issues with our code, we scan the chain for affected instances. For_

_each instance, we want to be able to notify the admin (to tell them to pause/upgrade/...)_


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 19


_of these apps. It's a way for people that import our code to get notification from us if_

_there is an issue._


_In those circumstances, we don't want to end up with "contact openzeppelin"._

### **N-06 Lack of Indexed Event Parameter**


Within <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> the <u><mark>`[ERC7913ThresholdSet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L58)`</mark></u> event does not have

indexed parameters.


To improve the ability of off-chain services to search and filter for specific events, consider

<u>[indexing event parameters.](https://solidity.readthedocs.io/en/latest/contracts.html#events)</u>


**_Update:_** _Acknowledged, not resolved. The team stated:_


_Indexing a parameter is expensive, and is useful only in specific circumstances._


_For example, in ERC20 transfer, indexing the from and to address is great for someone_

_to easily filter through a large number of event, figuring the transfers that affect a_

_particular account he/she is interested in. On the other hand, the value is not indexed,_

_because there the cost is not really worth it as we don't expect anyone to say "I want all_

_events that have this exact amount transfered, regardless of the sender and receiver"._


_In the case of MultiSignerERC7913, we imagine that someone may want to listen to all_

_the threshold updates, but we don't imagine that person would really want to filter these_

_by value. It would mean "I want to know about threshold updates that set the value to X,_

_but I don't care about threshold updates to any other values"_

### **N-07 File and Contract Names Mismatch**


The <u><mark>`[IERC7913.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/interfaces/IERC7913.sol)`</mark></u> <u>file name</u> does not match the <mark>`IERC7913SignatureVerifier`</mark>

contract name.


To make the codebase easier to understand for developers and reviewers, consider renaming

files to match the contract names.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_With a few historical exceptions (that we keep for backward compatibility), the files in_

_the interface folder usually refer to the ERC that standardize the interfaces. For example,_


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 20


_IERC4337 is only one file even though it defines many interfaces (none of which are_

_names IERC4337). The same is true of IERC7579.sol._


_Similarly IERC6909.sol defines multiple interfaces that fall in the scope or ERC-6909._


_For ERC-7913, we feel that, just like for ERC-7579:_


_- the name of the file should only reflect the ERC name (like most other files in the_

_folder)_


_- the name of the contract has to be a bit more explicit as to what it does._

### **N-08 Custom Errors in require Statements**


Since Solidity <u>version</u> <u><mark>`[0.8.26](https://soliditylang.org/blog/2024/05/21/solidity-0.8.26-release-announcement/)`</mark></u> <mark>,</mark> custom error support has been added to <mark>`require`</mark>

statements. Initially, this feature was only available through the IR pipeline. However, Solidity

<u><mark>`[0.8.27](https://soliditylang.org/blog/2024/09/04/solidity-0.8.27-release-announcement/)`</mark></u> extended support to the legacy pipeline as well.


The <mark>`draft-ERC7821.sol`</mark> contains multiple instances of <mark>`if-revert`</mark> statements that could

be replaced with <mark>`require`</mark> statements:









The <u><mark>`[if (!_erc7821AuthorizedExecutor(msg.sender, mode,](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol#L30-L31)`</mark></u>
```
executionData)) revert Account.AccountUnauthorized(msg.sender)
```

statement

The <u><mark>`[if (!supportsExecutionMode(mode)) revert](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol#L32)`</mark></u>

<u><mark>`[UnsupportedExecutionMode()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/./contracts/account/extensions/draft-ERC7821.sol#L32)`</mark></u> statement



For conciseness and gas savings, consider replacing <mark>`if-revert`</mark> statements with <mark>`require`</mark>

statements.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_using_ _<mark>`require(consition, customError(args));`</mark>_ _may be more readable than_

_<mark>`if(!condition) revert customError(args);`</mark>_ _but it is actually more expensive._


_The reason is that in the case of the if, the custom error code (with the argument) is only_

_encoded if the condition is not met. Using the require forces the custom error to always_

_be encoded, even if its not going to be emitted._


_While we sometimes do use the new require format, it is not a requirement of our_

_guidelines. We also feel it's sometimes better to leave more room to the user and have a_

_more relaxed pragma._


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 21


_I don't think the arguments in favor of require are strong enough to justify this change as_

_a fix._

### **N-09 Documentation Improvements**


Throughout the codebase, multiple opportunities for improving the documentation were

identified:



1.


2.


3.



The name of the <u><mark>`[_validateThreshold](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L238)`</mark></u> function suggests that the value of the

multisig <u><mark>`[_threshold](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L49)`</mark></u> is validated. However, what is being validated is whether the

number of collected signatures <u>[meets](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L239)</u> the threshold. Consider renaming the function to

better reflect its purpose. Some suggestions would be

<mark>`_validateNumberOfSignatures`</mark> or <mark>`_validateSufficientSignatures`</mark> <mark>.</mark>


In the <u><mark>`[_validateVoteSig](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L27)`</mark></u> function, an invalid keyed nonce signature will be <u>[validated](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L33-L48)</u>

a second time as well in the standard nonce scenario, which may seem redundant.

However, this redundancy is well-motivated though due to the following reasons:


  - On the one hand, the library must support both standard and keyed nonce

signatures, while on the other, it has no way of knowing which of the two is

supported by the client. Therefore, both scenarios must be checked.

[◦ In the case of keyed nonces, the nonce is explicitly incremented](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L44) only for valid

signatures. In contrast, standard nonces are <u>[always incremented, regardless of](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/Governor.sol#L572)</u>

whether the signature is valid or not. Therefore, by falling back to the standard

nonce scenario for invalid keyed nonce signatures, an implicit increase of the

nonce is forced even for invalid keyed nonce signatures. This is also a reason why

the order in which standard vs. keyed nonce signatures are checked is important

and should not be switched.


Consider documenting the specifics of the above-discussed behavior.


In the ERC-7913 multisig setting, there may be cases in which a <u><mark>`[_removeSigners](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L126)`</mark></u>

operation must be preceded by a respective threshold readjustment via

<u><mark>`[_setThreshold](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L143)`</mark></u> <mark>.</mark> Indeed, consider a scenario of 10 signers with a threshold of 5 and a

need to remove 6 signers. If the threshold is not readjusted first (to a value at most 4), the

call to <mark>`_removeSigners`</mark> will <u>[revert](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L129)</u> due to the original threshold (5) being unreachable

for 4 signers.


However, the threshold must be lowered and the signers removed in the _same_

transaction. Otherwise, a group of to-be-removed signers could take advantage of the


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 22


4.


5.


6.


7.



lowered threshold to approve a transaction before they are removed. Not having a

combined "lower threshold and remove signers" function is a very reasonable design

choice and improves modularity of the code. Yet, extra care should be exercised so that

whoever imports the library does not make mistakes in using it. Consider documenting

the fact that the threshold must be lowered, then the signers removed, in that order, in

the same transaction.


In <mark>`MultiSignerERC7913.sol`</mark> <mark>,</mark> the documentation for <u><mark>`[_validateSignatures](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L219)`</mark></u>

states that _"The signatures arrays must be at least as large as the signers arrays. Panics_

_otherwise."_ However, <mark>`_validateSignatures`</mark> calls

<mark>`areValidSignaturesNow(signers, signatures)`</mark> <mark>,</mark> which returns <mark>`false`</mark> if

<mark>`signers.length != signatures.length`</mark> <mark>.</mark> Consider amending this comment to

state that the two arrays must be equal in length.


In <mark>`EnumerableSet.sol`</mark> and <mark>`EnumerableMap.sol`</mark> <mark>,</mark> new structs <mark>(</mark> <mark>`StringSet`</mark>,

<mark>`BytesSet`</mark> <mark>,</mark> and <mark>`BytesToBytesMap`</mark> <mark>)</mark> have been added that represent sets and

mappings of elements of variable length. The documentation for the <u><mark>`[add](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L522)`</mark></u>, <u><mark>`[remove](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L540)`</mark></u> <mark>,</mark>

<u><mark>`[contains](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L591)`</mark></u> <mark>,</mark> and <u><mark>`[at](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L612)`</mark></u> methods for <mark>`StringSet`</mark> and <mark>`BytesSet`</mark> <mark>,</mark> and the documentation

for the <u><mark>`[set](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1200)`</mark></u> <mark>,</mark> <u><mark>`[remove](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1210)`</mark></u> <mark>,</mark> <u><mark>`[contains](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1232)`</mark></u> <mark>,</mark> <u><mark>`[at](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1253)`</mark></u> <mark>,</mark> <u><mark>`[tryGet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1265)`</mark></u> <mark>,</mark> and <u><mark>`[get](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1280)`</mark></u> methods of

<mark>`BytesToBytesMap`</mark> <mark>,</mark> describe these as O(1) operations. This is correct when there is a

uniform upper bound on the length of the elements in the set.


If the element lengths grow asymptotically with the size of the set, the time bound is

O(m), where m is the length of the element being added, removed, or queried. This is

true for queries and removals instead of just additions, because the input element must

be read and hashed to find its position in the <mark>`_positions`</mark> mapping. Similarly, the time

bound on previously O(n) operations <u><mark>`[values](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L624)`</mark></u> and <u><mark>`[clear](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L580)`</mark></u> of <mark>`StringSet`</mark>, <mark>`BytesSet`</mark> <mark>,</mark>

and <mark>`BytesToBytesMap`</mark> is O(mn) instead of O(n). Consider checking the time bounds

and updating the documentation for enumerable sets and mappings with variable length

elements.


In <mark>`EnumerableSet.sol`</mark> <mark>,</mark> [the warning](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableSet.sol#L129-L130) is a run-on sentence. For clarity, consider

breaking this into multiple sentences and updating each instance of this warning

accordingly.


[In the _validateVoteSig](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L27) [and _validateExtendedVoteSig](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L57) functions, the key for the nonce is

derived by <u>[casting](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L44)</u> (resp. <u>[here) the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L84)</u> <mark>`proposalId`</mark> to a <mark>`uint192`</mark> using

<mark>`uint192(proposalId)`</mark> <mark>.</mark> In Solidity, this operation retains the lower 192 bits.

According to the <u>[documentation, the key corresponds to the "first 192 bits" of the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/governance/extensions/GovernorNoncesKeyed.sol#L11)</u>

<mark>`proposalId`</mark> <mark>,</mark> which may be ambiguous and may potentially be interpreted as the


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 23


higher-order bits rather than the lower-order bits. The ambiguity could lead to nonce

collisions or unintended replay vulnerabilities if the <mark>`proposalId`</mark> exceeds 192 bits,

because the intended high-order bits (which carry different significance) are ignored.

Consider editing the documentation to state "low-order" bits and preferably giving an

example.


Consider improving the documentation as per the aforementioned recommendations.


**_Update:_** _Partially resolved in_ _<u>[pull request #5779. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5779)</u>_


_Some of the recommendations are addressed in the linked PR. We however decided to_

_not address everything raise here._


_On_ _<mark>`_validateThreshold`</mark>_ _naming: Generic function names are appropriate in_

_abstract library contexts where the validation logic is meant to be overridden. The name_

_describes the contract (threshold validation) rather than the implementation detail_

_(signature counting). I'd suggest keeping it as is._


_On_ _<mark>`_validateVoteSig`</mark>_ _redundancy: The "redundant" validation is intentional_

_architectural design. It enables graceful degradation from keyed nonces to standard_

_nonces, allowing incremental adoption without breaking existing integrations. This_

_provides better UX than requiring explicit mode selection. I'd say we keep it as is._


_On Internal API documentation level: Internal functions like_ _<mark>`_setThreshold`</mark>_ _and_

_<mark>`_removeSigners`</mark>_ _are building blocks for smart contract developers extending_

_OpenZeppelin contracts, not end-user APIs. These developers create public wrapper_

_functions that combine internal calls correctly and will undergo security audits_

_regardless of documentation completeness. I'd say adding implementation guidance to_

_internal functions doesn't add much value and is not an immediate security concern._


_On Time complexity as O(1): I would argue that the noted complexity still describes the_

_correct relationship between the set size and the operation cost. In short, assuming_

_constant size of the data inserted, then then it's correct to indicate O(1)._

### **N-10 Typographical Errors**


Throughout the codebase, multiple instances of typographical errors were identified:








<u>[Here, "Returns whether whether" should be "Returns whether".](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L212)</u>

<u>[Here, "Return the an array containing a slice of the keys" should be "Returns an array](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L298)</u>

[containing a slice of the keys". Also here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/a60baa22c69aa2d77c760fd9ad77d997df516847/contracts/utils/structs/EnumerableMap.sol#L1160) and possibly at other places.


OpenZeppelin Contracts Release v5.4 Diff Audit − Notes & Additional

Information − 24


<u>[Here, "Tries to returns the value associated with](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L1262)</u> <mark>`key`</mark> <mark>.</mark> " should be "Tries to return the

value associated with <mark>`key`</mark> <mark>"</mark> . Also <u>[here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/structs/EnumerableMap.sol#L139)</u> and possibly at other places.



Consider fixing all occurrences of typographical errors to improve code clarity and avoid

misinterpretation.


**_Update:_** _[Resolved in pull request #5777](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5777)_ _[at commit e1277f7.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/e1277f7ad295b5042849ad09169329663511e230)_

### **N-11 Missing immediate Parameter in canCall** **Function**


In <mark>`IAccessManager.sol`</mark> <mark>,</mark> [in the comment](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/access/manager/IAccessManager.sol#L100) to the <u><mark>`[canCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/access/manager/IAccessManager.sol#L110)`</mark></u> function, the documentation

refers to an <mark>`immediate`</mark> parameter that should allow bypassing the delay when set to true.

However, the function signature only includes the parameters <mark>`caller`</mark> <mark>,</mark> <mark>`target`</mark> and

<mark>`selector`</mark> <mark>.</mark> This discrepancy between the documentation and the actual function signature

could lead to confusion about how the function is expected to behave and indicates a potential

logical inconsistency.


Consider fixing the documentation or the implementation, so the two are consistent.


**_Update:_** _[Resolved in pull request #5795.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5795)_

## **Client Reported**

### **CR-01 Allowing Zero Threshold in ERC-7913** **Multisigner**


The <u><mark>`[_setThreshold](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L143)`</mark></u> function sets the value for the signature <u><mark>`[_threshold](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L49)`</mark></u> <mark>.</mark> However, there

is no check enforcing the threshold to be non-zero. With a threshold of zero,

<mark>`_validateThreshold`</mark> will <u>[always return](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L239)</u> <mark>`true`</mark> regardless of the number of signers. The risk

is mitigated during signature verification in <u><mark>`[_rawSignatureValidation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L201)`</mark></u> [which forces](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L205) the

number of signatures to be non-zero and consequently <u>[calls](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L207)</u> <mark>`_validateSignatures`</mark> on at

least one signature. In addition, the risk is further minimized by the fact that the value of

threshold can only be set during through the internal function <u><mark>`[_setThreshold](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/cryptography/signers/MultiSignerERC7913.sol#L143)`</mark></u> <mark>.</mark>


As a result of the aforementioned mitigating factors, there is little risk of any practical attack.

However, having a zero threshold effectively defeats the purpose of any multisig scheme.


OpenZeppelin Contracts Release v5.4 Diff Audit − Client Reported − 25


Therefore, consider enforcing the value of the threshold to be strictly larger than zero.

Alternatively, consider documenting this behavior.


**_Update:_** _[Resolved in pull request #5772](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5772)_ _[at commit d7930da.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/d7930daa4839eef439c92e247cf2fd3cc7261b21)_

### **CR-02 Out-of-bound Memory Read in** **`Bytes.lastIndexOf`**


[In Bytes.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/Bytes.sol) [the lastIndexOf](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/Bytes.sol#L58) function on input a buffer <mark>`buffer`</mark> <mark>,</mark> byte value `s` and position

<mark>`pos`</mark> searches for the first occurrence of `s` in <mark>`buffer`</mark> <mark>,</mark> starting from index <mark>`pos`</mark> (inclusive)

and proceeding backwards down to index `0` . If the byte `s` is found, its index is returned or

<mark>`type(uint256).max`</mark> <mark>,</mark> otherwise.


However the function blindly accepts empty buffer as input <mark>(</mark> <mark>`buffer.length == 0`</mark> <mark>)</mark> without

any boundary checks. If an empty buffer is passed and if <mark>`pos`</mark> is not <mark>`type(uint256).max =`</mark>

<mark>`2^256 - 1`</mark> <mark>,</mark> during the computation of <u><mark>`[Math.min(pos, length - 1) + 1](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/Bytes.sol#L62)`</mark></u> in the for
loop, <mark>`length - 1`</mark> overflows and returns <mark>`length - 1 = 0 - 1 = -1 = 2^256 - 1`</mark> <mark>.</mark>

Taking the minimum between <mark>`pos`</mark> and <mark>`2^256-1`</mark> in the <mark>`min`</mark> function of the same expression

returns a value less than <mark>`2^256 - 1`</mark> <mark>.</mark> Adding `1` to it next returns a non-zero value.

Consequently, the <u>[loop](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f6fea85717b1a09300c7a783554696a0d6f3df12/contracts/utils/Bytes.sol#L62)</u> starts at a non-zero index `i` and tries to access data out of bounds

(since the buffer is empty).


The above results in unpredictable behavior. For example, if the memory before <mark>`pos`</mark> is clean

(initialized to zero) a call to <mark>`lastIndexOf('0x', '0x00', 17)`</mark> will return <mark>`17`</mark> instead of

the expected <mark>`type(uint256).max`</mark> <mark>.</mark> Indeed since the buffer is empty and the memory

contains zeros (by assumption), the first encountered zero will be at position <mark>`17`</mark>, which is also

equal to the target value <mark>`s=0x00`</mark> <mark>.</mark>


Consider adding a check for the case in which <mark>`buffer.length == 0`</mark> and <mark>`pos !=`</mark>

<mark>`type(uint256).max`</mark> and return <mark>`type(uint256).max`</mark> (symbol not found) if both

conditions hold.


**_Update:_** _[Resolved in pull request #5797.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5797)_


OpenZeppelin Contracts Release v5.4 Diff Audit − Client Reported − 26


## **Conclusion**

The v5.4 release of OpenZeppelin Contracts library introduces support for ERC-7913,

ERC-7821, and EIP-2935, a keyed-nonces extension to the governance module,

enhancements to the enumerable map and set libraries, and porting of several contracts from

the Community Contracts repository, among other minor updates. This improves the versatility

of the library and addresses user needs dictated by the latest standards.


The code quality is of a high standard, with multiple safety mechanisms in place to prevent

malicious use, unintentional or otherwise. It is also accompanied by detailed documentation

and usage instructions. Several low-severity issues were reported, along with multiple notes

recommending various improvements.


The OpenZeppelin Contracts team is commended for the high quality of their work and is

appreciated for their active engagement throughout the audit in addressing all the questions

posed by the audit team promptly and in great detail.


OpenZeppelin Contracts Release v5.4 Diff Audit − Conclusion − 27


