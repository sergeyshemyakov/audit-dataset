# ​ **Security Assessment &** **Formal Verification** **Report Safe v1.5.0 ​**

## `January 2025`

_Prepared for_
**Safe Ecosystem Foundation**


### **Table of content**

**Project Summary.................................................................................................................................................4**

Project Scope..................................................................................................................................................4
Project Overview............................................................................................................................................. 4
Findings Summary.......................................................................................................................................... 6
Severity Matrix.................................................................................................................................................6
**Detailed Findings................................................................................................................................................ 7**

Medium Severity Issues.................................................................................................................................. 9
M-01 ERC-777 compatibility isn't implemented correctly................................................................................ 9
Low Severity Issues.......................................................................................................................................11
L-01 SafeProxy.fallback(): The dirty bits aren't correctly cleared..................................................................11
L-02 Wrong signature description................................................................................................................ 12
L-03 Possible mismatch between safeMethods and safeInterfaces............................................................ 13
L-04 Possible dirty bits in getTransactionHash()..........................................................................................14
L-05 FallbackManager should staticcall instead of call the Fallback Handler.............................................. 15
**Informational Severity Issues.................................................................................................................... 16**
I-01. Events lacking indexed fields................................................................................................................16
I-02. Some comments say keccak instead of keccak256..............................................................................17
I-03. Inconsistency in formula for performCreate and performCreate2.........................................................18
**Gas Optimization.........................................................................................................................................19**
G-01. OwnerManager.removeOwner(): 1 SLOAD can be saved in the normal path.................................... 19
G-02. OwnerManager.changeThreshold(): 1 SLOAD can be saved by emitting an existing memory variable
instead of reading from storage.....................................................................................................................20
G-03. ERC165Handler.setSupportedInterface(): Logic and storage access optimization.............................21
G-04. ExtensibleBase._setSafeMethod(): storage access optimization........................................................22
G-05. Use iszero instead of eq(*, 0)..............................................................................................................23
G-06. ExtensibleFallbackHandler._supportsInterface(): save gas via short-circuit evaluation......................24
G-07. Use a mask instead of shifting left and right........................................................................................25
G-08. Use shift right/left instead of division/multiplication if possible............................................................ 26
G-09. Cache array length outside of loop......................................................................................................28
G-10. ++i costs less gas compared to i++ or i += 1 (same for --i vs i-- or i -= 1)...........................................29
**Formal Verification............................................................................................................................................32**

Verification Notations.....................................................................................................................................32
Formal Verification Properties....................................................................................................................... 33
**Safe.sol.........................................................................................................................................................33**
P-01. Integrity of the Transaction Guard methods.........................................................................................33
P-02. Integrity of the Module Guard methods............................................................................................... 34
P-03. Integrity of Execute Transaction and Execute Transaction from Module.............................................35
P-04. Integrity of approveHash and approvedHashVal................................................................................. 36
P-05. Integrity of Setup..................................................................................................................................37

​ 2


**ExtensibleFallbackHandler.sol...................................................................................................................38**
P-01. Integrity of the Extensible Fallback Handler........................................................................................ 38
**Disclaimer.......................................................................................................................................................... 39**
**About Certora.................................................................................................................................................... 39**


​ 3


# **Project Summary**

##### **Project Scope**

Audited
Project Name Repository (link) Platform
Commits



Safe Smart
Account v1.5.0



<u>[https://github.com/safe-global/safe](https://github.com/safe-global/safe-smart-account)</u>
<u>[-smart-account](https://github.com/safe-global/safe-smart-account)</u>



<u>[834e798 - initial](https://github.com/safe-global/safe-smart-account/tree/834e798aa51291cccaf0594921194928716e9892)</u> ​
<u>[1c8b24a](https://github.com/safe-global/safe-smart-account/tree/1c8b24a0a438e8c2cd089a9d830d1688a47a28d5)</u> - latest
including fixes



EVM/Solidity


###### **Project Overview**

This document describes the specification and verification of **Safe’s Smart Account v1.5.0 Contracts** using
the Certora Prover and manual code review findings. The work was undertaken from **Dec 10, 2024** to **Jan 14,**
**2025** .


The following contract list is included in our scope:


●​ `contracts/` `​​` `​` `Safe.sol`
●​ `contracts/` `​​` `​` `SafeL2.sol`
●​ `contracts/accessors` `​` `SimulateTxAccessor.sol`
●​ `contracts/base` `​` `​` `Executor.sol`
●​ `contracts/base` `​` `​` `FallbackManager.sol`
●​ `contracts/base` `​` `​` `GuardManager.sol`
●​ `contracts/base` `​` `​` `ModuleManager.sol`
●​ `contracts/base` `​` `​` `OwnerManager.sol`
●​ `contracts/common` `​​` `NativeCurrencyPaymentFallback.sol`
●​ `contracts/common` `​​` `SecuredTokenTransfer.sol`
●​ `contracts/common` `​​` `SelfAuthorized.sol`
●​ `contracts/common` `​​` `SignatureDecoder.sol`
●​ `contracts/common` `​​` `Singleton.sol`
●​ `contracts/common` `​​` `StorageAccessible.sol`
●​ `contracts/external` `​` `SafeMath`
●​ `contracts/handler/extensible` `​` `ERC165Handler`
●​ `contracts/handler/extensible` `​` `ExtensibleBase`
●​ `contracts/handler/extensible` `​` `FallbackHandler`
●​ `contracts/handler/extensible` `​` `MarshalLib`

​ 4


●​ `contracts/handler/extensible` `​` `SignatureVerifierMuxer`
●​ `contracts/handler/extensible` `​` `TokenCallbacks`
●​ `contracts/handler` `​` `CompatibilityFallbackHandler`
●​ `contracts/handler` `​` `ExtensibleFallbackHandler`
●​ `contracts/handler` `​` `HandlerContext`
●​ `contracts/handler` `​` `TokenCallbackHandler`
●​ `contracts/libraries` `​` `CreateCall`
●​ `contracts/libraries` `​` `Enum`
●​ `contracts/libraries` `​` `ErrorMessage`
●​ `contracts/libraries` `​` `MultiSend`
●​ `contracts/libraries` `​` `MultiSendCallOnly`
●​ `contracts/libraries` `​` `SafeMigration`
●​ `contracts/libraries` `​` `SafeStorage`
●​ `contracts/libraries` `​` `SafeToL2Migration`
●​ `contracts/libraries` `​` `SafeToL2Setup`
●​ `contracts/libraries` `​` `SignMessageLib`
●​ `contracts/proxies` `​` `SafeProxy`
●​ `contracts/proxies` `​` `SafeProxyFactory`


The Certora Prover demonstrated that the implementation of the **Solidity** contracts above is correct with
respect to the formal rules written by the Certora team. In addition, the team performed a manual audit of all
the Solidity contracts **.** During the verification process and the manual audit, the Certora team discovered bugs
in the Solidity contracts code, as listed on the following page.


​ 5


##### **Findings Summary**

The table below summarizes the findings of the review, including type and severity details.


**Severity** **Discovered** **Confirmed** **Fixed**


Critical 0 0 0


High 0 0 0


Medium 1 1 1


Low 5 5 4


Informational 3 3 2


Gas Optimization 10 10 10


**Total** **19** **19** **17**

##### **Severity Matrix**


High Medium High Critical



**Impact**



Medium Low Medium High


Low Low Low Medium


Low Medium High


**Likelihood**



​ 6


# **Detailed Findings**

**ID** **Title** **Severity** **Status**



<u>M-01</u> ERC-777 compatibility isn't implemented
correctly


<u>L-01</u> SafeProxy.fallback(): The dirty bits aren't
correctly cleared



Medium Fixed


Low Fixed



<u>L-02</u> Wrong signature description Low Fixed



<u>L-03</u> Possible mismatch between safeMethods
and safeInterfaces



Low Won’t Fix



<u>L-04</u> Possible dirty bits in getTransactionHash() Low Fixed



<u>L-05</u> FallbackManager should staticcall instead of
call the Fallback Handler



Low Fixed



<u>I-01</u> Events lacking indexed fields Info Won’t Fix



<u>I-02</u> Some comments say keccak instead of
keccak256


<u>I-03</u> Inconsistency in formula for performCreate
and performCreate2


<u>G-01</u> OwnerManager.removeOwner(): 1 SLOAD can
be saved in the normal path


<u>G-02</u> OwnerManager.changeThreshold(): 1 SLOAD
can be saved by emitting an existing memory
variable instead of reading from storage



Info Fixed


Info Fixed


Gas Fixed


Gas Fixed



​ 7


<u>G-03</u> ERC165Handler.setSupportedInterface():
Logic and storage access optimization


<u>G-04</u> ExtensibleBase._setSafeMethod(): storage
access optimization



Gas Fixed


Gas Fixed



<u>G-05</u> Use iszero instead of eq(*, 0) Gas Fixed



<u>G-06</u> ExtensibleFallbackHandler._supportsInterfac
e(): save gas via short-circuit evaluation



Gas Fixed



<u>G-07</u> Use a mask instead of shifting left and right Gas Fixed



<u>G-08</u> Use shift right/left instead of
division/multiplication if possible



Gas Fixed



<u>G-09</u> Cache array length outside of loop Gas Fixed



<u>G-10</u> ++i costs less gas compared to i++ or i += 1
(same for --i vs i-- or i -= 1)



Gas Fixed



​ 8


#### **Medium Severity Issues**

**M-01 ERC-777 compatibility isn't implemented correctly**


Severity: **Medium** Impact: **Medium** Likelihood: **Medium**



Files:

●​ <u>[CompatibilityFallbackHandler.sol](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/handler/CompatibilityFallbackHandler.sol)</u>
●​ <u>[TokenCallbackHandler.sol](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/handler/TokenCallbackHandler.sol)</u>



Status: Fixed



**Description:** If we analyze how the compatibility with ERC-777 is implemented:


​ <mark>`contract CompatibilityFallbackHandler is TokenCallbackHandler`</mark> and <mark>`contract`</mark>
```
   TokenCallbackHandler is ... ERC777TokensRecipient
```

​ <mark>`function tokensReceived`</mark> is implemented

​ <mark>`TokenCallbackHandler.supportsInterface()`</mark> doesn't declare
<mark>`type(ERC777TokensRecipient).interfaceId`</mark> because the standard from ERC-777
doesn't need it: they use the ERC-1820 Registry

​ Only the contract itself can register itself as a <mark>`ERC777TokensRecipient`</mark> on the ERC1820

Registry otherwise the calls to <mark>`ERC77.send()`</mark> or <mark>`ERC777.mint()`</mark> will revert.

Currently, ERC777 tokens will not recognize the contract as a recipient, although it's expected to
be one. According to the ERC-777 standard, calls to the ERC777 token's <mark>`send()`</mark> or <mark>`mint()`</mark>
functions with this contract as a recipient will revert.


​ 9


#### **​**



**Existing workaround:** Depending on what's inheriting from <mark>`CompatibilityFallbackHandler`</mark>
(which isn't an abstract contract but a contract), there could exist a workaround requiring users
to manually call <mark>`ERC1820Registry.setInterfaceImplementer()`</mark> <mark>,</mark> so a fix on the frontend could
exist for older contracts.


**Recommendations:** **​**
A call similar to <mark>`ERC1820Registry(registry).setInterfaceImplementer(address(this),`</mark>
<mark>`keccak256("ERC777TokensRecipient"), address(this))`</mark> is missing for a real ERC-777
compatibility.


**Safe's response:** <u>[PR 885: This PR adds a detailed comment in the TokenCallbackHandler](https://github.com/safe-global/safe-smart-account/pull/885)</u>
contract, clarifying the requirement for accounts to register the implementer via the ERC-1820
interface registry to receive ERC777 tokens. This update aims to improve clarity and
understanding of the token reception process. No functional changes were made to the contract
logic.


​ 10


#### **Low Severity Issues**

**L-01** **<mark>SafeProxy.fallback():</mark>** **The dirty bits aren't correctly cleared**


Severity: **Low** Impact: **Low** Likelihood: **Low**


[Files: SafeProxy.sol](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/proxies/SafeProxy.sol#L43) Status: Fixed


**Description** : At <u>[SafeProxy.sol#L43, the](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/proxies/SafeProxy.sol#L43)</u> <mark>`shr(12, shl(12, _singleton))`</mark> operation is used
because an <mark>`address`</mark> is 20 bytes long on the small-endian.

```
      assembly {
         let _singleton := sload (0)
         // 0xa619486e == keccak("masterCopy()"). The value is right padded
  to 32-bytes with 0s
  if eq ( calldataload (0),
  0xa619486e00000000000000000000000000000000000000000000000000000000) {
           mstore (0, shr(12, shl(12, _singleton)))
           return (0, 0x20)
  }

```

As <mark>`let _singleton := sload(0)`</mark> operation loads a 32 bytes word, the aim is to clear the
potential dirty 12 bytes. However, <mark>`shr`</mark> and <mark>`shl`</mark> operate in bits, not bytes. Therefore, the correct
operation would instead be <mark>`shr(96, shl(96, _singleton))`</mark>

**Safe's response:** [Fixed in PR 868](https://github.com/safe-global/safe-smart-account/pull/868)


​ 11


**L-02 Wrong signature description**


Severity: **Low** Impact: **Low** Likelihood: **Low**



Files:
<u>[SignatureVerifierMuxer.](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/handler/extensible/SignatureVerifierMuxer.sol#L124)</u>
<u>[sol](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/handler/extensible/SignatureVerifierMuxer.sol#L124)</u>



Status: Fixed



**Description** : The comment <mark>`// 0x68 - 0x6C: encodeData length`</mark> at
<u>[SignatureVerifierMuxer.sol#L124](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/handler/extensible/SignatureVerifierMuxer.sol#L124)</u> is describing the length as being described 4 bytes.


However, a length is `0x20` (32 bytes).

Therefore the comment should be <mark>`// 0x68 - 0x88: encodeData length`</mark> (and the next few
comments should reflect this change)
A user taking this as documentation would produce a wrong signature.

**Safe's response:** [Fixed in PR 873](https://github.com/safe-global/safe-smart-account/pull/873)


​ 12


**L-03 Possible mismatch between** **<mark>safeMethods</mark>** **and** **<mark>safeInterfaces</mark>**


Severity: **Low** Impact: **Low** Likelihood: **Low**



Files: ​
<u>[ERC165Handler.sol](https://github.com/safe-global/safe-smart-account/blob/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/handler/extensible/ERC165Handler.sol#L53-L68)</u>


**Description** :



Status: Won’t fix



Duplicates in the <mark>`handlerWithSelectors`</mark> array can lead to a mismatch between the
<mark>`interfaceId`</mark> and the actual selectors added to <mark>`safeMethods`</mark> due to the XOR and <mark>`A ^ A = 0`</mark> (at
<u>[ERC165Handler.sol#L53-L68).](https://github.com/safe-global/safe-smart-account/blob/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/handler/extensible/ERC165Handler.sol#L53-L68)</u>
Example:

●​ <mark>`handlerWithSelectors`</mark> is <mark>`[0x12345678, 0xabcdef01, 0x12345678]`</mark>
●​ Computed <mark>`interfaceId`</mark> is <mark>`0x12345678 ^ 0xabcdef01 ^ 0x12345678 = 0xabcdef01`</mark>
●​ Intended <mark>`interfaceId`</mark> is <mark>`0x12345678 ^ 0xabcdef01 = 0xbc99f579`</mark>

=> <mark>`safeMethods`</mark> will correctly store all the selectors, but the <mark>`interfaceId`</mark> won't represent the
actual set of selectors due to the duplicate canceling out in the XOR computation.

This issue would be self-inflicted and easily cleaned with a call to
<mark>`removeSupportedInterfaceBatch`</mark> <mark>.</mark>

A remediation could be to force an order (e.g. <mark>`handlerWithSelectors[i - 1] <`</mark>
<mark>`handlerWithSelectors[i]`</mark> <mark>)</mark> but this would increase gas usage.

**Safe's response:** **​**
Acknowledged but won’t fix (self-inflicted and costs more gas)


​ 13


**L-04 Possible dirty bits in** **<mark>getTransactionHash()</mark>**


Severity: **Low** Impact: **Low** Likelihood: **Low**


[Files: Safe.sol](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/Safe.sol#L419-L442) Status: Fixed


**Description** :


The solidity assembly types that are smaller than 256 bit can have dirty high bits according to
the spec (see the Warning in <u>[the solidity docs). We have seen instances of these in practice.](https://docs.soliditylang.org/en/latest/assembly.html#access-to-external-variables-functions-and-libraries)</u>
This means that technically the <mark>`getTransactionHash()`</mark> <mark>f</mark> unction is not correct as the high bits in
the three <mark>`address`</mark> fields and the <mark>`enum`</mark> field ( <mark>`enum`</mark> is an <mark>`uint8`</mark> <mark>)</mark> could be non-zero in some future
compiler version.

Consider using a bitmask <mark>`and`</mark> operation to clean the higher bits out in the assembly block itself
as the solidity docs suggest.

**Safe's response:**
[Documented in PR 872. The current implementation is not affected as it reads these fields from](https://github.com/safe-global/safe-smart-account/pull/872)
calldata where the solidity compiler checks that the unused bits are cleared.


​ 14


**L-05 FallbackManager should** **<mark>staticcall</mark>** **instead of** **<mark>call</mark>** **the Fallback Handler**


Severity: **Low** Impact: **Low** Likelihood: **Low**



Files:

●​ <u>[Safe.sol](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/Safe.sol#L31)</u>
●​ <u>[FallbackManager.sol](https://github.com/safe-global/safe-smart-account/blob/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/base/FallbackManager.sol#L80)</u>



Status: Fixed



**Description** : There's a mismatch between the description here:

```
 File : Safe.sol
 31 : * - Fallback : Fallback handler is a contract that can provide
 additional read - only functionality for Safe. Managed in `FallbackManager`.

```

And the actual implementation here:

```
 File : FallbackManager.sol
 80 : let success := call(gas(), handler, 0, ptr,
 add(calldatasize(), 20), 0, 0)

```

Instead of a <mark>`call`</mark> which could induce a state change, this here should be a <mark>`staticcall`</mark> <mark>.</mark>
This gives a better protection against state changes (e.g. backdoor creation) and saves gas.

**Safe's response:**
<u>[PR 879: Updating the documentation.](https://github.com/safe-global/safe-smart-account/pull/879)</u>
The reasoning is pretty simple: we need to have a “CALL” opcode here to future-proof ourselves
if a new standard requires a new method to be defined precisely at the deployed contract’s
address.
One recent example would be ERC-4337, which required an account to define the
`validateUserOp` method, which also changes the blockchain’s state (sending the pre-fund to the
bundler) - with a static call that’d be impossible.


​ 15


#### **Informational Severity Issues**

##### **I-01. Events lacking indexed fields**

**Description:**


The events at <u>[SafeL2.sol#L16-L32 are lacking indexed fields.](https://github.com/safe-global/safe-smart-account/blob/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5/contracts/SafeL2.sol#L16-L32)</u>
It would be relevant for <mark>`event SafeModuleTransaction(address module, address to,`</mark>
<mark>`uint256 value, bytes data, Enum.Operation operation)`</mark> to have <mark>`address indexed module`</mark>
and <mark>`address indexed to`</mark> <mark>.</mark>
It would also be relevant for <mark>`event SafeMultiSigTransaction`</mark> to have <mark>`address indexed to`</mark>


**Safe’s response:** **​**
We don’t see any immediate benefit. Usually, the requirements for a field to be indexed come
from our backend team that develops the indexer; they have never brought this up.


When we want to fetch the transactions, we need to fetch all of them first and then build
whatever index is needed off-chain


​ 16


##### **I-02. Some comments say keccak instead of keccak256**

**Description:**


Comments across the codebase always say <mark>`keccak256`</mark> instead of <mark>`keccak`</mark> <mark>:</mark>

```
 contracts / interfaces / ISignatureValidator.sol :
  6 : // bytes4(keccak256("isValidSignature(bytes32,bytes)")

 contracts / libraries / SafeToL2Migration.sol :
  115 : // 0xef2624ae - bytes4(keccak256("migrateToL2(address)"))
  145 : // 0xd9a20812  bytes4(keccak256("migrateFromV111(address,address)"))

```

However, the following are an exception. For consistency and ease of copy-pasting for auditors
and developers to test the signatures, we recommend this fix:

```
 contracts/common/SecuredTokenTransfer.sol:
 - 19:     // 0xa9059cbb - keccak("transfer(address,uint256)")
 + 19:     // 0xa9059cbb - bytes4(keccak256("transfer(address,uint256)"))

 contracts/proxies/SafeProxy.sol:
 - 41:       // 0xa619486e == keccak("masterCopy()"). The value is right
 padded to 32-bytes with 0s
 + 41:       // 0xa619486e == bytes4(keccak256("masterCopy()")). The
 value is right padded to 32-bytes with 0s

```

**Safe’s response:** Fixed in <u>[PR 886](https://github.com/safe-global/safe-smart-account/pull/886)</u>


​ 17


##### **I-03. Inconsistency in formula for performCreate and performCreate2**

**Description:** **​**
<mark>`performCreate2`</mark> has the following line:

```
  File : CreateCall.sol
  25 :       newContract := create2(value, add(0x20, deploymentData),
  mload(deploymentData), salt)

```

<mark>`performCreate`</mark> has the following line:

```
  File : CreateCall.sol
  42 :       newContract := create(value, add(deploymentData, 0x20),
  mload(deploymentData))

```

Commutativity makes the two additions being equivalent but we recommend the fix below for
readability and to follow the standard given that:

●​ <mark>`deploymentData`</mark> gives a pointer to the start of the array (length position).
●​ Adding <mark>`0x20`</mark> skips the first 32 bytes (length field) to point directly to the start of the
payload.

**Recommendations:**

```
  File: CreateCall.sol
  21:   function performCreate2(uint256 value, bytes memory deploymentData,
  bytes32 salt) public returns (address newContract) {
  22:     /* solhint-disable no-inline-assembly */
  23:     /// @solidity memory-safe-assembly
  24:     assembly {
  - 25:       newContract := create2(value, add(0x20, deploymentData),
  mload(deploymentData), salt)
  + 25:       newContract := create2(value, add(deploymentData, 0x20),
  mload(deploymentData), salt)
  26:     }
  27:     /* solhint-enable no-inline-assembly */
  28:     require(newContract != address(0), "Could not deploy contract");
  29:     emit ContractCreation(newContract);
  30:   }

```

**Safe’s response:** Fixed in <u>[PR 887](https://github.com/safe-global/safe-smart-account/pull/887)</u>


​ 18


#### **Gas Optimization**

##### **G-01. OwnerManager.removeOwner(): 1 SLOAD can be saved in the** **normal path**

**Description:**


The current code reads from storage twice with the <mark>`ownerCount`</mark> variable:

```
  File : OwnerManager.sol
  74 : if (ownerCount - 1 < _threshold) revertWithError("GS201");
  //@audit ownerCount SLOAD 1
  75 : // Validate owner address and check that it corresponds to owner
  index.
  76 : if (owner == address (0) || owner == SENTINEL_OWNERS)
  revertWithError("GS203");
  77 : if (owners[prevOwner] != owner) revertWithError("GS205");
  78 :     owners[prevOwner] = owners[owner];
  79 :     owners[owner] = address (0);
  80 :     ownerCount -- ;  //@audit ownerCount SLOAD 2 + SSTORE 1

```

However this is unfair to the normal and expected functioning scenario where the transaction is
successful (doesn't revert with <mark>`"GS201"`</mark> <mark>)</mark> .

The following would save gas under the usual and most probable scenario:

```
  - 74:     if (ownerCount - 1 < _threshold) revertWithError("GS201");
  //@audit ownerCount SLOAD 1
  + 74:     if (--ownerCount < _threshold) revertWithError("GS201");
  //@audit ownerCount SLOAD 1 + SSTORE 1
  75:     // Validate owner address and check that it corresponds to owner
  index.
  76:     if (owner == address(0) || owner == SENTINEL_OWNERS)
  revertWithError("GS203");
  77:     if (owners[prevOwner] != owner) revertWithError("GS205");
  78:     owners[prevOwner] = owners[owner];
  79:     owners[owner] = address(0);
  - 80:     ownerCount--; //@audit ownerCount SLOAD 2 + SSTORE 1

```

​ 19


**Safe’s response:** Fixed in <u>[PR 888](https://github.com/safe-global/safe-smart-account/pull/888)</u>

##### **G-02. OwnerManager.changeThreshold(): 1 SLOAD can be saved by** **emitting an existing memory variable instead of reading from** **storage**


**Description:**

```
 File: OwnerManager.sol
 107:   function changeThreshold(uint256 _threshold) public override
 authorized {
 108:     // Validate that threshold is smaller than number of owners.
 109:     if (_threshold > ownerCount) revertWithError("GS201");
 110:     // There has to be at least one Safe owner.
 111:     if (_threshold == 0) revertWithError("GS202");
 112:     threshold = _threshold;
 - 113:     emit ChangedThreshold(threshold);
 + 113:     emit ChangedThreshold(_threshold);
 114:   }

```

**Safe’s response:** Fixed in <u>[PR 889](https://github.com/safe-global/safe-smart-account/pull/889)</u>


​ 20


##### **G-03. ERC165Handler.setSupportedInterface(): Logic and storage** **access optimization**

**Description:**


When accessing a nested struct or mapping several times in storage, it's possible to save on gas
by locally saving the reference using the <mark>`storage`</mark> keyword.
The following optimizes the logic and minimizes storage accesses:

```
 File: ERC165Handler.sol
 function setSupportedInterface(bytes4 interfaceId, bool supported) public
 override onlySelf {
 ISafe safe = ISafe(payable(_manager()));
 // invalid interface id per ERC165 spec
 require(interfaceId != 0xffffffff, "invalid interface id");
 -     bool current = safeInterfaces[safe][interfaceId];
 +     mapping(bytes4 => bool) storage safeInterface =
 safeInterfaces[safe];
 +     bool current = safeInterface[interfaceId];
 -    if (supported && !current) {
 -      safeInterfaces[safe][interfaceId] = true;
 -      emit AddedInterface(safe, interfaceId);
 -    } else if (!supported && current) {
 -      delete safeInterfaces[safe][interfaceId];
 -      emit RemovedInterface(safe, interfaceId);
 -    }
 +    if (supported != current) {
 +      safeInterface[interfaceId] = supported;
 +      if (supported) {
 +        emit AddedInterface(safe, interfaceId);
 +      } else {
 +        emit RemovedInterface(safe, interfaceId);
 +      }
 +    }
 }

```

**Safe’s response:** Fixed in <u>[PR 890](https://github.com/safe-global/safe-smart-account/pull/890)</u>


​ 21


##### **G-04. ExtensibleBase._setSafeMethod(): storage access** **optimization**

**Description:**


Same as previously, locally saving the storage reference will save gas:

```
 File: ExtensibleBase.sol
 47:   function _setSafeMethod(ISafe safe, bytes4 selector, bytes32
 newMethod) internal {
 48:     (, address newHandler) = MarshalLib.decode(newMethod);
 - 49:     bytes32 oldMethod = safeMethods[safe][selector];
 + 49:     mapping(bytes4 => bytes32) storage safeMethod =
 safeMethods[safe];
 + 50:     bytes32 oldMethod = safeMethod[selector];
 50:     (, address oldHandler) = MarshalLib.decode(oldMethod);
 51:
 52:     if (address(newHandler) == address(0) && address(oldHandler) !=
 address(0)) {
 - 53:       delete safeMethods[safe][selector];
 + 53:       delete safeMethod[selector];
 54:       emit RemovedSafeMethod(safe, selector);
 55:     } else {
 - 56:       safeMethods[safe][selector] = newMethod;
 + 56:       safeMethod[selector] = newMethod;
 57:       if (address(oldHandler) == address(0)) {
 58:         emit AddedSafeMethod(safe, selector, newMethod);
 59:       } else {
 60:         emit ChangedSafeMethod(safe, selector, oldMethod,
 newMethod);
 61:       }
 62:     }
 63:   }

```

**Safe’s response:** Fixed in <u>[PR 891](https://github.com/safe-global/safe-smart-account/pull/891)</u>


​ 22


##### **G-05. Use iszero instead of eq(*, 0)**

**Description:**


This follows the steps of the following past fix:
<u>[https://github.com/safe-global/safe-smart-account/commit/7f79aaf05c33df71d9cb687f0bc8a7](https://github.com/safe-global/safe-smart-account/commit/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5)</u>
<u>[3fa39d25d5](https://github.com/safe-global/safe-smart-account/commit/7f79aaf05c33df71d9cb687f0bc8a73fa39d25d5)</u>


Lastly, I noticed that there were some <mark>`eq(..., 0)`</mark> assembly calls which can be written as
<mark>`iszero(...)`</mark> to save some gas and code...

```
 File: SafeProxyFactory.sol
 - 43:         if eq(call(gas(), proxy, 0, add(initializer, 0x20),
 mload(initializer), 0, 0), 0) {
 + 43:         if iszero(call(gas(), proxy, 0, add(initializer, 0x20),
 mload(initializer), 0, 0)) {

```

**Safe’s response:** Fixed in <u>[PR 892](https://github.com/safe-global/safe-smart-account/pull/892)</u>


​ 23


##### **G-06. ExtensibleFallbackHandler._supportsInterface(): save gas via** **short-circuit evaluation**

**Description:**


If it's expected, like the comment seems to explain, that <mark>`_supportsInterface`</mark> will most often be
called for <mark>`ERC721 + ERC1155`</mark> tokens: consider reordering the `||` conditions to take advantage of
the short-circuit evaluation:

```
 File: ExtensibleFallbackHandler.sol
 14: contract ExtensibleFallbackHandler is FallbackHandler,
 SignatureVerifierMuxer, TokenCallbacks, ERC165Handler {
 15:   /**
 16:   * Specify specific interfaces (ERC721 + ERC1155) that this contract
 supports.
 17:   * @param interfaceId The interface ID to check for support
 18:   */
 19:   function _supportsInterface(bytes4 interfaceId) internal pure override
 returns (bool) {
 20:     return
 + 21:       interfaceId == type(ERC721TokenReceiver).interfaceId ||
 + 21:       interfaceId == type(ERC1155TokenReceiver).interfaceId ||
 21:       interfaceId == type(ERC1271).interfaceId ||
 22:       interfaceId == type(ISignatureVerifierMuxer).interfaceId ||
 23:       interfaceId == type(ERC165Handler).interfaceId ||
 - 24:       interfaceId == type(IFallbackHandler).interfaceId ||
 + 24:       interfaceId == type(IFallbackHandler).interfaceId
 - 25:       interfaceId == type(ERC721TokenReceiver).interfaceId ||
 - 26:       interfaceId == type(ERC1155TokenReceiver).interfaceId;
 27:   }
 28: }

```

**Safe’s response:** Fixed in <u>[PR 893](https://github.com/safe-global/safe-smart-account/pull/893)</u>


​ 24


##### **G-07. Use a mask instead of shifting left and right**

**Description:**


A direct bitmask ( <mark>`and`</mark> <mark>)</mark> operation is cheaper than using <mark>`shl`</mark> followed by <mark>`shr`</mark> (saving 3 gas due to 1
less opcode):

```
 File: MarshalLib.sol
 - 41:       handler := shr(96, shl(96, data))
 + 41:       handler := and(data,
 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

 File: MarshalLib.sol
 - 59:       handler := shr(96, shl(96, data))
 + 59:       handler := and(data,
 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)

 File: SignatureVerifierMuxer.sol
 - 113:         sigSelector := shl(224, shr(224,
 calldataload(signature.offset)))
 + 113:         sigSelector := and(calldataload(signature.offset),
 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)

```

**Safe’s response:** Can the conversion be omitted here at all?


**Certora’s response:** The bits should be cleaned for the addresses as only a reuse in Solidity
itself would clean them. If another assembly blocks uses it, the dirty bits will remain. Given that
this is a lib, how it's used isn't guaranteed, so it's better to manually clean. See also the warning
from the Solidity language documentation. However for bytes4 sigSelector, we're back to
solidity after the assembly block (and the value isn't reused later), so it can indeed be removed.


​ 25


**Safe’s response:** <u>[PR 894: Kept the handler cleaning, and removed the sigSelector one.](https://github.com/safe-global/safe-smart-account/pull/894)</u>

##### **G-08. Use shift right/left instead of division/multiplication if** **possible**


**Description:**


While the <mark>`DIV`</mark> / <mark>`MUL`</mark> opcode uses 5 gas, the <mark>`SHR`</mark> / <mark>`SHL`</mark> opcode only uses 3 gas. Furthermore,
beware that Solidity's division operation also includes a division-by-0 prevention which is
bypassed using shifting. Eventually, overflow checks are never performed for shift operations as
they are done for arithmetic operations. Instead, the result is always truncated, so the calculation
can be unchecked in Solidity version <mark>`0.8+`</mark>

●​ Use <mark>`>> 1`</mark> instead of <mark>`/ 2`</mark>
●​ Use <mark>`>> 2`</mark> instead of <mark>`/ 4`</mark>
●​ Use <mark>`<< 3`</mark> instead of <mark>`* 8`</mark>
●​ ...
●​ Use <mark>`>> 5`</mark> instead of <mark>`/ 2^5 == / 32`</mark>
●​ Use <mark>`<< 6`</mark> instead of <mark>`* 2^6 == * 64`</mark>

TL;DR:

●​ Shifting left by N is like multiplying by 2^N (Each bits to the left is an increased power of 2)
●​ Shifting right by N is like dividing by 2^N (Each bits to the right is a decreased power of 2)

_Saves around 2 gas + 20 for unchecked per instance_

Affected code:

●​ <u>[contracts/Safe.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/Safe.sol)</u>

```
 # File: contracts/Safe.sol

 - Safe.sol:168:     if (gasleft() < ((safeTxGas * 64) / 63).max(safeTxGas
 + 2500) + 500) revertWithError("GS010");
 + Safe.sol:168:     if (gasleft() < ((safeTxGas << 6) / 63).max(safeTxGas

```

​ 26


```
 + 2500) + 500) revertWithError("GS010");

```

●​ <u>[contracts/common/StorageAccessible.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/common/StorageAccessible.sol)</u>

```
 # File: contracts/common/StorageAccessible.sol

 - StorageAccessible.sol:18:     bytes memory result = new bytes(length *
 32);
 + StorageAccessible.sol:18:     bytes memory result = new bytes(length <<
 5);

```

**Safe’s response:** Fixed in <u>[PR 895](https://github.com/safe-global/safe-smart-account/pull/895)</u>


​ 27


##### **G-09. Cache array length outside of loop**

**Description:**


If not cached, the solidity compiler will always read the length of the array during each iteration.
That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each
iteration except for the first) and if it is a memory array, this is an extra mload operation (3
additional gas for each iteration except for the first).

Affected code:

●​ <u>[contracts/base/OwnerManager.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/base/OwnerManager.sol)</u>

```
 # File : contracts / base / OwnerManager.sol

 OwnerManager.sol : 38 : for ( uint256 i = 0; i < _owners.length; i ++ ) {

```

●​ <u>[contracts/handler/extensible/ERC165Handler.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/handler/extensible/ERC165Handler.sol)</u>

```
 # File : contracts / handler / extensible / ERC165Handler.sol

 ERC165Handler.sol : 56 : for ( uint256 i = 0; i <
 handlerWithSelectors.length; i ++ ) {

 ERC165Handler.sol : 78 : for ( uint256 i = 0; i < selectors.length; i ++ ) {

```

**Safe’s response:** Fixed in <u>[PR 896](https://github.com/safe-global/safe-smart-account/pull/896)</u>


​ 28


##### **G-10. ++i costs less gas compared to i++ or i += 1 (same for --i vs i-- or i -=** **1)**

**Description:**


Pre-increments and pre-decrements are cheaper.

For a <mark>`uint256 i`</mark> variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

●​ <mark>`i += 1`</mark> is the most expensive form
●​ <mark>`i++`</mark> costs 6 gas less than <mark>`i += 1`</mark>
●​ <mark>`++i`</mark> costs 5 gas less than <mark>`i++`</mark> (11 gas less than <mark>`i += 1`</mark> <mark>)</mark>

**Decrement:**

●​ <mark>`i -= 1`</mark> is the most expensive form
●​ <mark>`i--`</mark> costs 11 gas less than <mark>`i -= 1`</mark>
●​ <mark>`--i`</mark> costs 5 gas less than <mark>`i--`</mark> (16 gas less than <mark>`i -= 1`</mark> <mark>)</mark>

Note that post-increments (or post-decrements) return the old value before incrementing or
decrementing, hence the name _post-increment_ :

```
 uint i = 1;
 uint j = 2;
 require(j == i ++, "This will be false as i is incremented after the
 comparison");

```

However, pre-increments (or pre-decrements) return the new value:

```
 uint i = 1;
 uint j = 2;
 require(j == ++ i, "This will be true as i is incremented before the
 comparison");

```

In the pre-increment case, the compiler has to create a temporary variable (when used) for
returning `1` instead of `2` .


​ 29


Consider using pre-increments and pre-decrements where they are relevant (meaning: not
where post-increments/decrements logic are relevant).

_Saves 5 gas per instance_

Affected code:

●​ <u>[contracts/Safe.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/Safe.sol)</u>

```
 # File : contracts / Safe.sol

 Safe.sol : 296 : for (i = 0; i < requiredSignatures; i ++ ) {

```

●​ <u>[contracts/base/ModuleManager.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/base/ModuleManager.sol)</u>

```
 # File : contracts / base / ModuleManager.sol

 ModuleManager.sol : 215 :       moduleCount ++ ;

```

●​ <u>[contracts/base/OwnerManager.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/base/OwnerManager.sol)</u>

```
 # File : contracts / base / OwnerManager.sol

 OwnerManager.sol : 38 : for ( uint256 i = 0; i < _owners.length; i ++ ) {

 OwnerManager.sol : 63 :     ownerCount ++ ;

 OwnerManager.sol : 142 :       index ++ ;

```

●​ <u>[contracts/common/StorageAccessible.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/common/StorageAccessible.sol)</u>

```
 # File : contracts / common / StorageAccessible.sol

 StorageAccessible.sol : 19 : for ( uint256 index = 0; index < length;
 index ++ ) {

```

​ 30


●​ <u>[contracts/handler/extensible/ERC165Handler.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/handler/extensible/ERC165Handler.sol)</u>

```
 # File : contracts / handler / extensible / ERC165Handler.sol

 ERC165Handler.sol : 56 : for ( uint256 i = 0; i <
 handlerWithSelectors.length; i ++ ) {

 ERC165Handler.sol : 78 : for ( uint256 i = 0; i < selectors.length; i ++ ) {

```

●​ <u>[contracts/libraries/SafeToL2Migration.sol](https://github.com/safe-global/safe-smart-account/tree/43097762c2833aabc7c881c069b7cf92d08af7a0/contracts/libraries/SafeToL2Migration.sol)</u>

```
 # File : contracts / libraries / SafeToL2Migration.sol

 SafeToL2Migration.sol : 188 :       index ++ ;

```

**Note** : _<u>Do not change the following line</u>_ as this would break the logic:

```
 # File : contracts / Safe.sol

 Safe.sol : 140 :         nonce ++

```

**Safe’s response:** Fixed in <u>[PR 897](https://github.com/safe-global/safe-smart-account/pull/897)</u>


​ 31


# **Formal Verification**

##### **Verification Notations**



Formally Verified


Formally Verified After Fix



The rule is verified for every state of the
contract(s), under the assumptions of the
scope/requirements in the rule.


The rule was violated due to an issue in the
code and was successfully verified after
fixing the issue



A counter-example exists that violates one
Violated
of the assertions of the rule.



​ 32


#### **Formal Verification Properties**

**Safe.sol**


<u>Module General Assumptions</u>

-​ Loop iterations: Any loop was unrolled at most 3 times (iterations)


<u>Contract Properties</u>


**P-01. Integrity of the Transaction Guard methods.**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/39601/cf9c0bafb4a742e6b8dab73ddb709e47?anonymousKey=273f436c6f7529b3678b3615b34d99c83e636fff)</u>


<u>[Report](https://prover.certora.com/output/39601/5e35072a6ce149ce8374698f9d24cf68?anonymousKey=bcce6dcb98da37922c853f492452da6cbc0253d1)</u>



**<mark>guardAddressC</mark>**
**<mark>hange</mark>**


**<mark>setGetCorrespo</mark>**
**<mark>ndenceGuard</mark>**


**<mark>setGuardReentr</mark>**
**<mark>ant</mark>**



Verified The only method that can change the transaction

guard is setGuard.


Verified Making sure that set and get work as expected for

the transaction guard.



Verified setGuard can only be called by contract itself. <u>[Report](https://prover.certora.com/output/39601/be8f3a2419c549aaaf704ee3eb5bcd72?anonymousKey=d46dfe642afa7eff4d0cbb72074d6111df012074)</u>



**<mark>txnGuardCalled</mark>** Verified The transaction guard gets called both pre- and

post- any execTransaction.



<u>[Report](https://prover.certora.com/output/39601/a9a8eaeba7994e10bf29dbe8813798b9?anonymousKey=fbddda2f78b44a7df3dff4707715b90b2d08ab63)</u>



​ 33


**P-02.** **Integrity of the Module Guard methods.**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/39601/e935d11bc7684d7eba966e7972d03175?anonymousKey=050ec802a24d492f84f361b630075dc2ea27e57c)</u>


<u>[Report](https://prover.certora.com/output/39601/61b504ff0f544907a9b6705fbccde2e8?anonymousKey=9845e55bbd23322cb344427eb26c450e6a302a74)</u>


<u>[Report](https://prover.certora.com/output/39601/8147e74eda404e61bcb6fc8e8849c5f3?anonymousKey=5c1e77468b6f5bff22c376894dca846f5ea83aab)</u>


<u>[Report](https://prover.certora.com/output/39601/7591e8c61e6d407b847e38bbe8238e13?anonymousKey=5d99429f5046e77825a4ed015af0a6a0d088538d)</u>


<u>[Report](https://prover.certora.com/output/39601/2de5a471d628464e8aaf4b9022e515de?anonymousKey=c4997fd77ba3808cf9bdc6a432f9b20eea551c95)</u>



**<mark>moduleGuardA</mark>**
**<mark>ddressChange</mark>**


**<mark>setGetCorrespo</mark>**
**<mark>ndenceModule</mark>**
**<mark>Guard</mark>**


**<mark>setModuleGuar</mark>**
**<mark>dReentrant</mark>**


**<mark>moduleGuardC</mark>**
**<mark>alled</mark>**


**<mark>moduleGuardC</mark>**
**<mark>alledReturn</mark>**



Verified The only method that can change the module guard

is setModuleGuard.


Verified Making sure that set and get work as expected for

the module guard.


Verified setModuleGuard can only be called by contract

itself.


Verified The module guard gets called both pre- and post
any execTransactionFromModule.


Verified The module guard gets called both pre- and post
any execTransactionFromModuleReturnData.



​ 34


**P-03.** **Integrity of Execute Transaction and Execute Transaction from Module**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/39601/dcc09acbeead4df9868519a4ac0e3ee5?anonymousKey=327efa3ac9dde7907db389b3a2688ce42094ef41)</u>


<u>[Report](http://exectxnmodulereturndatapermissions)</u>


<u>[Report](https://prover.certora.com/output/39601/9b60b63b5aa84428b9fca530f870c4b6?anonymousKey=4b731a650337bea416faf81e806d96a7b040f8e8)</u>


<u>[Report](https://prover.certora.com/output/39601/9f364fac5e8c43e0acc2d93cea3f5560?anonymousKey=d37fb383bff8fa2fe0dacf60b61130e1aadf2ad4)</u>



**<mark>execTxnModule</mark>**
**<mark>Permissions</mark>**


**<mark>execTxnModule</mark>**
**<mark>ReturnDataPer</mark>**
**<mark>missions</mark>**


**<mark>executePermis</mark>**
**<mark>sions</mark>**


**<mark>executeThresh</mark>**
**<mark>oldMet</mark>**



Verified A successful call to execTransactionFromModule

must be from an enabled module.


Verified A call to execTransactionFromModuleReturnData

that succeeds must be from an enabled module.


Verified Execute can only be called by execTransaction or

execTransactionFromModule.


Verified The number of signatures provided for any

executing transaction meets the correct threshold.



​ 35


**P-04.** **Integrity of approveHash and approvedHashVal.**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/39601/5f0f9128bc6b48198910430198a512dd?anonymousKey=bf7e0e14eb39ea891521b6fcd0e048c7759eda1a)</u>



**<mark>approvedHashe</mark>**
**<mark>sUpdate</mark>**


**<mark>approvedHashe</mark>**
**<mark>sSet</mark>**


**<mark>transactionHas</mark>**
**<mark>hCantCollide</mark>**



Verified approvedHashes[user][hash] can only be changed

by msg.sender==user.



Verified The hash of two distinct transactions cannot be the

same. Requires some munging of Safe.sol at line

456. Although the original assembly code is correct,

it accesses the memory unaligned which breaks the

Certora prover. The munging removes the unaligned

access for verification. Note that this munged code

must not be used in production, as it computes a

slightly different hash.



Verified approvedHashes is set when calling approveHash <u>[Report](https://prover.certora.com/output/39601/5c2d9df8cf874c2c9653fc1814f87e09?anonymousKey=79e74a676efa255550e902ad6519bfe11aba4f2e)</u>



<u>[Report](https://prover.certora.com/output/39601/c63d4b37c7374cad81daf623737a2ef9?anonymousKey=24c75ae3e39b39935b0658e40deb1ddb9f5be041)</u>



​ 36


**P-05.** **Integrity of Setup**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/39601/7849e9a464e042ea89bfe68fc226edbc?anonymousKey=5c1387afecb8bc86f23df3be5eb886a5cd82787f)</u>



**<mark>setupThreshold</mark>**
**<mark>ZeroAndSetsPo</mark>**
**<mark>sitiveThreshold</mark>**



Verified setup can only be called if threshold = 0 and setup

sets threshold > 0



​ 37


**ExtensibleFallbackHandler.sol**


<u>Module General Assumptions</u>

-​ Loop iterations: Any loop was unrolled at most 3 times (iterations).


<u>Contract Properties</u>


**P-01. Integrity of the Extensible Fallback Handler**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/39601/ab995049df0b454b888f3cd6a27331d5?anonymousKey=1a710fa917c8c60a9a420e026d6570d91e1e923b)</u>


<u>[Report](https://prover.certora.com/output/39601/edb75f86f23445cdbc7cd7b5c4c420b6?anonymousKey=62191f4f70404bcbce784f5172e3ed7ab323d416)</u>



**<mark>setFallbackInte</mark>**
**<mark>grity</mark>**


**<mark>fallbackHandler</mark>**
**<mark>NeverSelf</mark>**


**<mark>simulateAndRe</mark>**
**<mark>vertReverts</mark>**


**<mark>setSafeMethod</mark>**
**<mark>Sets</mark>**


**<mark>setSafeMethod</mark>**
**<mark>Removes</mark>**


**<mark>setSafeMethod</mark>**
**<mark>Changes</mark>**


**<mark>handlerCallable</mark>**
**<mark>IfSet</mark>**


**<mark>handlerCalledIf</mark>**
**<mark>Set</mark>**



Verified The fallback handler gets set by setFallbackHandler.


Verified The address for the fallback handler slot is never set

to the Safe contract.



Verified A handler, once set via setSafeMethod, is possible to

call.


Verified A handler, once set visa setSafeMethod, gets called

under the expected conditions.



Verified simulateAndRevert always reverts. <u>[Report](https://prover.certora.com/output/39601/38653935d0db460994d1a8c5bfdf57bb?anonymousKey=988218ca4f784fd27ea96fd2f14644719e2e9468)</u>


Verified setSafeMethod sets the handler. <u>[Report](https://prover.certora.com/output/39601/bab9860cdfc44a83bed82e79d8c06218?anonymousKey=b4c5dbef050bb201ad78b3dd5af5cdca8ffa9f92)</u>


Verified setSafeMethod removes the handler. <u>[Report](https://prover.certora.com/output/39601/8591535c4a434f3e826af00b95ea1ca8?anonymousKey=a7b6743a3161a3289883f99014619a9d6e7196e1)</u>


Verified setSafeMethod changes the handler. <u>[Report](https://prover.certora.com/output/39601/b44efe9ef3bd4ff5a1af710a7d3d7ee4?anonymousKey=7fd15cc355164c803123c27b41660fed34548647)</u>



<u>[Report](https://prover.certora.com/output/39601/9fcde04ecd434963b9ce788f7ddea8c1?anonymousKey=a7efde58b28ef7c99264424b66984a8d39b78518)</u>


<u>[Report](https://prover.certora.com/output/39601/a5bab5a7af8b4fd2819dedbc6e3221b9?anonymousKey=e4505515d8d69b3b1697c97fc3cc8f994802e46d)</u>



​ 38


# **Disclaimer**

The Certora Prover takes a contract and a specification as input and formally proves that the
contract satisfies the specification in all scenarios. Notably, the guarantees of the Certora Prover
are scoped to the provided specification and the Certora Prover does not check any cases not
covered by the specification.

Even though we hope this information is helpful, we provide no warranty of any kind, explicit or
implied. The contents of this report should not be construed as a complete guarantee that the
contract is secure in all dimensions. In no event shall Certora or any of its employees be liable for
any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising
from, out of, or in connection with the results reported here.

# **About Certora**


Certora is a Web3 security company that provides industry-leading formal verification tools and
smart contract audits. Certora’s flagship security product, Certora Prover, is a unique SaaS
product that automatically locates even the most rare & hard-to-find bugs on your smart
contracts or mathematically proves their absence. The Certora Prover plugs into your standard
deployment pipeline. It is helpful for smart contract developers and security researchers during
auditing and bug bounties.

Certora also provides services such as auditing, formal verification projects, and incident
response.


​ 39


