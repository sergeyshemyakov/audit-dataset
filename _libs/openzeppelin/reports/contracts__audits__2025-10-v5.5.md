### | security

# **OpenZeppelin** **Contracts v5.5** **Diff Audit**

#### **October 17, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Security Model and Trust Assumptions _______________________________________________  5


Low Severity ______________________________________________________________________  7

L-01 Inconsistent v Normalization Between Signatures 7

L-02 Incorrect Value in isValidERC1271SignatureNow 8


Notes & Additional Information ______________________________________________________  8

N-01 Incorrect Comments in isValidERC1271SignatureNow 8


Conclusion ________________________________________________________________________  9


OpenZeppelin Contracts v5.5 Diff Audit − Table of Contents − 2


## **Summary**

**Type** Infrastructure


**Timeline** From 2025-10-06
To 2025-10-09


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



**Total Issues** 3 (3 resolved)



**Low Severity Issues** 2 (2 resolved)



**Notes & Additional**
**Information**



1 (1 resolved)



OpenZeppelin Contracts v5.5 Diff Audit − Summary − 3


## **Scope**

OpenZeppelin performed a diff audit of the <u>[OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)</u> repository,

between base commit <u>[c64a1ed](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/c64a1edb67b6e3f4a15cca8909c9482ad33a02b0)</u> and target commit <u>[f5edfc0. This](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2)</u> diff highlights all the changes

made between the two commits.


In scope were the following files:

```
contracts
├──token/ERC20/utils/SafeERC20.sol
└──utils/cryptography
├──ECDSA.sol
└──SignatureChecker.sol

```

OpenZeppelin Contracts v5.5 Diff Audit − Scope − 4


## **System Overview**

The scope only included the changes made to the <u><mark>`[SafeERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/token/ERC20/utils/SafeERC20.sol)`</mark></u> <mark>,</mark> <u><mark>`[ECDSA](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/ECDSA.sol)`</mark></u> <mark>,</mark> and

<u><mark>`[SignatureChecker](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/SignatureChecker.sol)`</mark></u> libraries:











**<mark>`SafeERC20`</mark>** <mark>:</mark> The <mark>`_callOptionalReturn`</mark> function has been removed, and many of

the functions that relied on it have been refactored. These refactors are intended to

achieve the same functionality, but via the internal <mark>`_safeTransfer`</mark> <mark>,</mark>

<mark>`_safeTransferFrom`</mark> <mark>,</mark> and <mark>`_safeApprove`</mark> functions, which are mostly implemented

in assembly.


**<mark>`ECDSA`</mark>** <mark>:</mark> Four new functions have been added: <mark>`tryRecoverCalldata`</mark> <mark>,</mark>

<mark>`recoverCalldata`</mark> <mark>,</mark> <mark>`parse`</mark> <mark>,</mark> and <mark>`parseCalldata`</mark> <mark>.</mark> <mark>`tryRecoverCalldata`</mark> and

<mark>`recoverCalldata`</mark> both mimic the already existing <mark>`memory`</mark> versions of themselves,

called <mark>`tryRecover`</mark> and <mark>`recover`</mark> <mark>.</mark> The only difference is where the signature is stored

(either <mark>`memory`</mark> or <mark>`calldata`</mark> <mark>)</mark> . The <mark>`parse`</mark> and <mark>`parseCalldata`</mark> functions both take

a dynamic-length signature as input and return the `v`, `r`, and `s` parameters for the

signature.


**<mark>`SignatureChecker`</mark>** <mark>:</mark> A new function, <mark>`isValidSignatureNowCalldata`</mark> <mark>,</mark> has been

implemented. This function is a version of <mark>`isValidSignatureNow`</mark> that uses a

<mark>`calldata signature`</mark> parameter. It also refactors the

<mark>`isValidERC1271SignatureNow`</mark> function so that it is fully implemented in assembly.


## **Security Model and Trust** **Assumptions**

During the audit, the following trust assumptions were made:







The libraries are intended to be integrated as dependencies for other top-level contracts.

It is assumed that they are used correctly as per the documentation within the contracts

and the official OpenZeppelin docs.


OpenZeppelin Contracts v5.5 Diff Audit − System Overview − 5


For the <mark>`ECDSA`</mark> and <mark>`SignatureChecker`</mark> libraries, it is assumed that users understand

the risks of signature malleability, signature re-use, and the difference between 65-byte

and 64-byte signatures.

For the <mark>`SafeERC20`</mark> library, it is assumed that users understand ERC-20 compliance

and have checked the tokens that are intended to be used with <mark>`SafeERC20`</mark> for

compatibility. This is because <mark>`SafeERC20`</mark> implements extra restrictions on the allowed

behavior.


OpenZeppelin Contracts v5.5 Diff Audit − Security Model and Trust

Assumptions − 6


## **Low Severity**

### **L-01 Inconsistent v Normalization Between** **Signatures**

The <u><mark>`[parse](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/ECDSA.sol#L212-L235)`</mark></u> and <u><mark>`[parseCalldata](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/ECDSA.sol#L240-L263)`</mark></u> helper functions split ECDSA signatures into the `v`, `r`, and

`s` [components for both 65-byte and EIP-2098](https://eips.ethereum.org/EIPS/eip-2098) 64-byte encodings. In the 64-byte path, `v` is

derived from <mark>`vs`</mark> [and normalized to](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/ECDSA.sol#L227) <u><mark>`[27](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/ECDSA.sol#L227)`</mark></u> <u>or</u> <u><mark>`[28](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/ECDSA.sol#L227)`</mark></u> <mark>.</mark> In the 65-byte path, `v` is <u>[taken as-is. This](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/ECDSA.sol#L220)</u>

yields inconsistent outputs for equivalent signatures: 65-byte inputs may return `v` which is `0`

or `1`, while 64-byte inputs return <mark>`27`</mark> or <mark>`28`</mark> <mark>.</mark> Downstream code that expects canonical `v` can

misbehave, and calls to <mark>`ecrecover`</mark> with `v` equal to `0` or `1` will return the zero address,

potentially causing silent failures.


Consider normalizing `v` in the 65-byte branch to <mark>`27`</mark> or <mark>`28`</mark> <mark>,</mark> or removing the normalization

from the 64-byte branch to be consistent with each other. In addition, consider updating the

documentation to state that both helpers return the canonical `v`, `r` and `s` values that are

suitable for <mark>`ecrecover`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #5990. The OpenZeppelin Contracts team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5990)_


_Although the difference in the_ _`v`_ _value depending on whether the signature is 64-bytes_

_or 65-bytes long may come across as an inconsistency, it’s intentional:_


_1. For 64-byte signatures: We must normalize because there’s only 1 bit available (0 or_

_1), and ecrecover requires 27 or 28_


_2. For 65-byte signatures: It should already be normalized by the signer. If v is 0 or 1, the_

_signature is malformed and should fail cleanly when passed in to_ _<mark>`tryRecover`</mark>_


_The OpenZeppelin Contracts team included an improved NatSpec on the_ _<mark>`parse`</mark>_

_function to make the process clear._


OpenZeppelin Contracts v5.5 Diff Audit − Low Severity − 7


### **L-02 Incorrect Value in** **`isValidERC1271SignatureNow`**

In the <mark>`SignatureChecker`</mark> library, within the <mark>`isValidERC1271SignatureNow`</mark> function,

there is an incorrect hardcoded value. The <u>comparison against</u> <u><mark>`[returndatasize()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/SignatureChecker.sol#L86)`</mark></u> checks if

the return data is greater than <mark>`0x19`</mark> (or 25) bytes long, whereas it should ensure that the

return data is greater than <mark>`0x1f`</mark> [(or 31) bytes long. This check existed in the prior version.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/c64a1edb67b6e3f4a15cca8909c9482ad33a02b0/contracts/utils/cryptography/SignatureChecker.sol#L90)


In line 86 of the <mark>`SignatureChecker`</mark> library, consider changing <mark>`0x19`</mark> to <mark>`0x1f`</mark> .


**_Update:_** _Resolved in pull request_ _<u>[#5973.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5973)</u>_

## **Notes & Additional** **Information**

### **N-01 Incorrect Comments in** **`isValidERC1271SignatureNow`**


[The inline comments](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f5edfc0f53ba5fe9d71855d855e0fab9d2ac5aa2/contracts/utils/cryptography/SignatureChecker.sol#L73-L78) documenting the calldata layout of the

<mark>`isValidERC1271SignatureNow`</mark> function in memory misstate the 32-byte slot boundaries

for the dynamic bytes argument. The comments show <mark>`[0x24 - 0x44]`</mark> for the signature

offset and <mark>`[0x44 - 0x64]`</mark> for the signature length, implying 33-byte spans. However, the

correct inclusive ranges should be <mark>`[0x24 - 0x43]`</mark> and <mark>`[0x44 - 0x63]`</mark> as both the

signature offset and length are 32 bytes. While the code writes to the correct locations,

inaccurate documentation can mislead maintainers and downstream implementations.


Consider correcting the comments to the exact ranges mentioned above and clarifying the fact

that the ranges are inclusive.


**_Update:_** _[Resolved in pull request #5959](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/5959)_ _[at commit 7a4a7fe. The OpenZeppelin Contracts team](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/7a4a7fe6623adff3025a57f846812ecbf788c610)_

_stated:_


_We fixed it by specifying the correct ranges._


OpenZeppelin Contracts v5.5 Diff Audit − Notes & Additional Information − 8


## **Conclusion**

The audited scope included minimal changes, but they were made more complicated due to

the extensive use of assembly. Many of the changes were re-implementations of already

existing functions to leverage <mark>`calldata`</mark> for cheaper execution. Overall, the issues found in

the codebase pertained to edge cases, but they should still be corrected given the wide
ranging use of OpenZeppelin Contracts libraries as dependencies. The changes were found to

be well-thought-out and intentional, and did not break any existing functionality of the prior

version of OpenZeppelin Contracts. The OpenZeppelin Contracts team is appreciated for their

responsiveness and honesty when responding to questions about the audited codebase.


OpenZeppelin Contracts v5.5 Diff Audit − Conclusion − 9


