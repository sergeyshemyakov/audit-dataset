### | security

# **EVM Emulator** **and Semi-** **abstracted** **Nonces Update** **Audit**

#### **April 15, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5

EVM Emulator updates 5

Semi-Abstracted Nonces Implementation 5


Security Model and Trust Assumptions _______________________________________________  7


Critical Severity ____________________________________________________________________  8

C-01 Byte-to-Bit Mismatch in Shift Operations 8


High Severity ______________________________________________________________________  9

H-01 Inner Variable Shadowing Causes Incorrect Return in mloadPotentiallyPaddedValue 9


Low Severity ____________________________________________________________________ 10

L-01 Missing Docstrings 10

L-02 Deprecation of Arbitrary Ordering Is Not Explicit 11

L-03 Lack of Input Validation 11

L-04 Unreachable Code 12


Notes & Additional Information ____________________________________________________ 12

N-01 Inconsistent Interface Between Sibling Repositories 12

N-02 Misleading Documentation 13

N-03 Mismatch Between Interface and Implementation 14

N-04 Inconsistent Handling of Nonce Types 15

N-05 Function Visibility Overly Permissive 15

N-06 Lack of Security Contact 16

N-07 Functions Updating State Without Event Emissions 16

N-08 Unused Event 17

N-09 Redundant Return Statements 17

N-10 Implicit Casting 18

N-11 Inconsistent Variable Naming 18


Conclusion ______________________________________________________________________ 19


EVM Emulator and Semi-abstracted Nonces Update Audit − Table of

Contents − 2


## **Summary**

**Type** L2 Protocol


**Timeline** From 2025-03-20
To 2025-03-28


**Languages** Solidity + Yul



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



1 (1 resolved)


1 (1 resolved)


0 (0 resolved)



**Total Issues** 17 (15 resolved, 1 partially resolved)



**Low Severity Issues** 4 (4 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



11 (9 resolved, 1 partially resolved)


0 (0 resolved)



EVM Emulator and Semi-abstracted Nonces Update Audit − Summary − 3


## **Scope**

We audited the <u>[pull request #1359](https://github.com/matter-labs/era-contracts/pull/1359)</u> [of the matter-labs/era-contracts](https://github.com/matter-labs/era-contracts) repository at commit

<u>[cc1619c.](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/)</u>


In scope were the following files:

```
system-contracts
├── contracts
│  ├── Constants.sol
│  ├── ContractDeployer.sol
│  ├── EvmEmulator.yul
│  ├── EvmGasManager.yul
│  ├── NonceHolder.sol
│  ├── SystemContractErrors.sol
│  └── interfaces
│    ├── IContractDeployer.sol
│    └── INonceHolder.sol
└── evm-emulator
├── EvmEmulator.template.yul
├── EvmEmulatorFunctions.template.yul
├── EvmEmulatorLoop.template.yul
└── calldata-opcodes
└── RuntimeScope.template.yul

```

**Note:** Only the changes introduced in the pull request were audited. The full content of the

listed files was not reviewed in its entirety.


EVM Emulator and Semi-abstracted Nonces Update Audit − Scope − 4


## **System Overview**

The audited pull request can be split into two different projects:








Implementation of semi-abstracted nonces on the system contracts

EVM Emulator updates.


### **EVM Emulator updates**

**Enhancing Efficiency with Pointer-based Bytecode Handling**


After the changes introduced in this pull request, the <mark>`EvmEmulator`</mark> no longer copies EVM

bytecodes during calls; instead, it reads them directly by pointers. This modification leverages

pointers more actively, resulting in optimization improvements. By eliminating the need to copy

bytecodes and utilizing pointers, the emulator enhances its efficiency, reduces memory usage,

and streamlines bytecode handling.


**Support for** **<mark>`modexp`</mark>** **Precompile**


This pull request adds support for the <mark>`modexp`</mark> precompile in the EVM emulator and includes

the implementation of gas calculations based on the input values, following the specifications

[of EIP-2565.](https://eips.ethereum.org/EIPS/eip-2565)

### **Semi-Abstracted Nonces Implementation**


Requiring a single sequential nonce value is limiting the sender's ability to define their custom

logic in regards to transaction ordering. In particular, ZKsync SSO's session module requires

the ability to send multiple transactions in parallel without any of them overriding or cancelling

the other ones.


One key change introduced in this pull request is the support for <u>[EIP-4337's semi-abstracted](https://eips.ethereum.org/EIPS/eip-4337#semi-abstracted-nonce-support)</u>

<u>[nonces. Before this change, accounts across the ZKChains could opt for two modes of nonce](https://eips.ethereum.org/EIPS/eip-4337#semi-abstracted-nonce-support)</u>

ordering: sequential and arbitrary. After this pull request, the arbitrary ordering has been

deprecated and the sequencial one has been upgraded into <mark>`KeyedSequential`</mark> <mark>.</mark>


EVM Emulator and Semi-abstracted Nonces Update Audit − System

Overview − 5


This new ordering type, allows for parallel transactions to be executed without clashing among

each other, by splitting the full <mark>`uint256`</mark> nonce field into two values: a 192-bit <mark>`key`</mark> followed

by a 64-bit <mark>`sequence`</mark> <mark>.</mark> Given the same <mark>`key`</mark> <mark>,</mark> the <mark>`sequence`</mark> field follows the classical

sequential order, and <mark>`userOperation`</mark> <mark>s</mark> must be executed in strictly sequential order.

However, multiple <mark>`key`</mark> <mark>s</mark> can be used in parallel without affecting each other.


In order so support this change, the old feature to set values under nonces (via the

<mark>`setValueUnderNonce`</mark> function) has been removed. This feature allowed specific nonce

invalidation by setting a value within them in a mapping.


One thing to note is that the keyed sequential ordering is backwards compatible, so all the

sequential ordering accounts are treated as having been using the <mark>`key`</mark> with value zero up until

now. Updating the nonce ordering is not possible anymore, and <mark>`KeyedSequential`</mark> is the

default value on account creation.


**Integration Considerations**


This change introduces several considerations that integrators should keep in mind, such as:
















The nonce can be increased by an arbitrary value up to 2^64 through the

<u><mark>`[increaseMinNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L82)`</mark></u> <u>function, which means that someone could theoretically reach the</u>

max nonce by performing 2^32 calls to increase their nonce by exactly 2^32.

Before this change, the maximum theoretical nonce was 2^128, while now it is 2^64 per

key.

If an account is configured to use <mark>`Arbitrary`</mark> ordering before the update is deployed,

there will not be possible for this account to migrate to <mark>`KeyedSequential`</mark> <mark>.</mark> At the time

of the audit, the Matter Labs team confirmed there were zero accounts using such

ordering.

There are currently 3 different mappings tracking the nonce system. One of them is

deprecated, since it kept track of nonce invalidations by setting values under them, but it

is still present in the codebase. The second one keeps track of nonces with key set to

zero. The last one keeps track of the different sequences of nonces per non-zero key.

No module in the protocol is currently using the keyed nonce specific functions.

Every new account after this update, will have by default <mark>`KeyedSequential`</mark> ordering

with no way to update to any other.



Additionally, the <mark>`SsoAccount`</mark> contract currently uses the <u><mark>`[incrementMinNonceIfEquals](https://github.com/matter-labs/zksync-sso-clave-contracts/blob/c7714c0fe0a33a23acce5aa20355f088d330b4f7/src/SsoAccount.sol#L233)`</mark></u>

<u>[method](https://github.com/matter-labs/zksync-sso-clave-contracts/blob/c7714c0fe0a33a23acce5aa20355f088d330b4f7/src/SsoAccount.sol#L233)</u> to increase the nonce after each <mark>`Transaction`</mark> <mark>.</mark> [However, this method only allows](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L131-L134)

<u>[the key to be zero, which means that the](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L131-L134)</u> <mark>`SsoAccount`</mark> contract will not be able to leverage


EVM Emulator and Semi-abstracted Nonces Update Audit − System

Overview − 6


the new keyed-nonces mechanism that would allow sending multiple <mark>`Transaction`</mark> <mark>s</mark> without

them reverting due to the same nonce.


Consider updating the <mark>`SsoAccount`</mark> contract to use the new

<mark>`incrementMinNonceIfEqualsKeyed`</mark> method.

## **Security Model and Trust** **Assumptions**


During the audit, the following trust assumption was made based on the changes in this PR:







**LLVM Compiler Intrinsics** : The function calls within the <mark>`verbatim`</mark> statements, such as

<mark>`active_ptr_swap`</mark> <mark>,</mark> <mark>`active_ptr_data_load`</mark> <mark>,</mark> and

<mark>`return_data_ptr_to_active`</mark> <mark>,</mark> belong to the LLVM compiler context. It is assumed

that these intrinsics are correctly implemented and secure.


EVM Emulator and Semi-abstracted Nonces Update Audit − Security Model

and Trust Assumptions − 7


## **Critical Severity**

### **C-01 Byte-to-Bit Mismatch in Shift Operations**

In both <u><mark>`[modexpGasCost](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L985)`</mark></u> and <u><mark>`[mloadPotentiallyPaddedValue](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1052)`</mark></u> functions, the code

calculates shift amounts in bytes but uses them directly with EVM shift instructions, which

operate on bits. This results in incomplete or inaccurate shifts, as 1 byte equals 8 bits. Without

converting byte-based values into their bit equivalents, the shift operations behave incorrectly.


This mismatch has several negative effects:













**Distorted Parameter Reads** : When used to trim or isolate components like the base,

exponent, or modulus, incorrect shifts may leave behind unintended bits. This can lead

to inflated sizes, skewed gas calculations, or corrupted numerical values.

**Exploitability Risk** : Malicious users may supply inputs that trigger these incorrect shifts,

potentially manipulating gas costs or bypassing boundary checks, leading to undefined

or exploitable behavior.

**Incorrect Memory Interpretation** : Code paths intended to mask or sanitize specific bytes

may instead leave residual bits intact. This can cause logical errors when interpreting

memory content.

**Numerical Instability** : Misaligned shift results can cause values to overflow or underflow

in downstream logic. For instance, malformed bit-lengths derived from exponent parsing

may cause loops to run excessively or insufficiently.



Consider ensuring that every shift amount derived from a byte difference is multiplied by 8

before applying any shift operation. This guarantees alignment with EVM's bit-level shift

semantics and avoids the wide range of downstream issues stemming from partial shifts.


**_Update:_** _[Resolved in pull request #1383.](https://github.com/matter-labs/era-contracts/pull/1383)_


EVM Emulator and Semi-abstracted Nonces Update Audit − Critical Severity

                                                  - 8


## **High Severity**

### **H-01 Inner Variable Shadowing Causes Incorrect** **Return in mloadPotentiallyPaddedValue**

The helper function <u><mark>`[mloadPotentiallyPaddedValue](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1052)`</mark></u> is intended to read a 32-byte word

from memory and zero out any bytes that lie beyond a specified memory boundary. However,

due to improper use of a <mark>`let`</mark> declaration inside an <mark>`if`</mark> block, the adjusted value is not

actually returned.

```
function mloadPotentiallyPaddedValue(index, memoryBound) -> value {
  value := mload(index)

  if lt(memoryBound, add(index, 32)) {
     memoryBound := getMax(index, memoryBound)
     let shift := sub(add(index, 32), memoryBound)
     let value := shl(shift, shr(shift, value)) // inner `value` shadows outer
  }
}

```

In the <mark>`if`</mark> block, a new local variable named <mark>`value`</mark> is declared using <mark>`let`</mark>, which shadows

the outer <mark>`value`</mark> that is the function’s return variable. As a result, any transformation applied

within the block affects only the inner <mark>`value`</mark> and not the function’s output. This leads to the

function returning the original unmodified result of <mark>`mload(index)`</mark> <mark>,</mark> even when part of the

read spans beyond the specified memory region.


As an additional observation, while variable <u>[shadowing is disallowed in Yul, the current](https://github.com/ethereum/solidity/blob/297230ad32a4ba0ac2505fc1a0d391d1cd1c25a3/docs/yul.rst?plain=1#L608-L610)</u>

compiler does not enforce this rule and fails to emit an error. This leads to subtle logic bugs

such as this one, where the code appears correct but behaves unexpectedly due to silent

shadowing.


This issue has downstream implications for gas cost estimation in the <mark>`modexpGasCost`</mark>

function, which relies on <mark>`mloadPotentiallyPaddedValue`</mark> to extract bounded parameters.

If those values are not correctly adjusted, the computation proceeds with inaccurate inputs:









**Incorrect parameter sizes** : When memory bounds are exceeded, out-of-bound bytes

remain in the value, leading to misinterpreted sizes.

**Wrong exponent iteration count** : An incorrect <mark>`Esize`</mark> affects the bit length estimation,

skewing the iteration logic.


EVM Emulator and Semi-abstracted Nonces Update Audit − High Severity −

9


**Incorrect gas metering** : The gas cost may be significantly under- or over-estimated,

defeating the purpose of precise metering and potentially leading to exploitability or

denial of service.



Consider assigning the adjusted value directly to the return variable, avoiding the use of a

shadowing <mark>`let`</mark> declaration.


**_Update:_** _[Resolved in pull request #1384.](https://github.com/matter-labs/era-contracts/pull/1384)_

## **Low Severity**

### **L-01 Missing Docstrings**


Docstrings are essential to improve code readability and maintenance. Providing clear

descriptions of contracts, functions (including their arguments and return values), events, and

state variables helps developers and auditors better understand code functionality and

purpose.


Multiple instances of missing or incomplete docstrings were identified across several

contracts, such as:











The <u><mark>`[ContractDeployer](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol)`</mark></u> contract, where not all functions include docstrings for their

arguments and return values.


The <u><mark>`[INonceHolder](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol)`</mark></u> interface, which only describes function names without

documenting arguments and return values.


The <u><mark>`[IContractDeployer](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/IContractDeployer.sol)`</mark></u> interface, which lacks documentation for several functions,

events, arguments, and return values.



Consider thoroughly documenting all contracts, functions, events, and relevant state variables

using clear, descriptive docstrings. Documentation should adhere to the <u>[Ethereum Natural](https://docs.soliditylang.org/en/v0.8.29/natspec-format.html)</u>

<u>[Specification Format](https://docs.soliditylang.org/en/v0.8.29/natspec-format.html)</u> (NatSpec) standard to enhance readability, support auditing efforts, and

improve long-term maintainability.


**_Update:_** _[Resolved in pull request #1399](https://github.com/matter-labs/era-contracts/pull/1399)_ _[at commits 250af39](https://github.com/matter-labs/era-contracts/pull/1399/commits/250af39463102a4074f2bccb0113aa471b1c537a)_ _[and ae0a314.](https://github.com/matter-labs/era-contracts/pull/1399/commits/ae0a31412f88775799787f7b5b06c179437923bc)_


EVM Emulator and Semi-abstracted Nonces Update Audit − Low Severity −

10


### **L-02 Deprecation of Arbitrary Ordering Is Not** **Explicit**

The new implementation of the <mark>`ContractDeployer`</mark> [contract prevents](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L79-L82) accounts from

updating their nonce ordering system. Additionally, <mark>`KeyedSequential`</mark> is specified as the

<u>[default ordering, which makes the](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L437-L439)</u> <mark>`Arbitrary`</mark> ordering option fully deprecated.


However, there are still places that do not reference this deprecation of the <mark>`Arbitrary`</mark>

ordering which could cause confusion. In particular:









[The documentation and name](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/IContractDeployer.sol#L33-L39) of the element in the <mark>`enum`</mark> corresponding to the

<mark>`Arbitrary`</mark> type in the <mark>`IContractDeployer`</mark> interface.

[The broad documentation](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/docs/l2_system_contracts/system_contracts_bootloader_description.md#L227-L235) of the contract when referencing the nonce ordering.



Consider updating the documentation and <mark>`enum`</mark> value to properly reflect that this nonce

ordering system is now deprecated in order to improve code readability, avoid confusion, and

make the current design choice explicit. Additionally, even if there is not any account with

<mark>`Arbitrary`</mark> ordering configured, there is a chance that one could set it before this code is

deployed. Consider adding a function that would allow any account configured to use

<mark>`Arbitrary`</mark> ordering to strictly migrate to <mark>`KeyedSequential`</mark> <mark>.</mark> This would provide these

accounts with a way to correctly migrate in case they unknowingly update to <mark>`Arbitrary`</mark>

before the update.


**_Update:_** _[Resolved in pull request #1387](https://github.com/matter-labs/era-contracts/pull/1387)_ _[at commit 051b360. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1387/commits/051b360aa8180208d66a8ceb6fbcc49798f8c3dd)_


_Migrating from_ _<mark>`Arbitrary`</mark>_ _ordering back to_ _<mark>`KeyedSequential`</mark>_ _is forbidden due to_

_the assumptions that_ _<mark>`KeyedSequential`</mark>_ _ordering makes. Namely, if nonce value for_

_nonce key K is V, the assumption is that none of the values above V are used. This_

_assumption would break if account migrates from_ _<mark>`Arbitrary`</mark>_ _ordering._

### **L-03 Lack of Input Validation**


The <mark>`_value`</mark> argument from the <u><mark>`[increaseMinNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L82)`</mark></u> <u>function</u> in the <mark>`NonceHolder`</mark>

contract lacks input validation, and it should be strictly greater than zero when called.


Consider implementing a validation check to ensure <mark>`_value > 0`</mark> in order to prevent

unexpected behavior.


EVM Emulator and Semi-abstracted Nonces Update Audit − Low Severity −

11


**_Update:_** _[Resolved in pull request #1388](https://github.com/matter-labs/era-contracts/pull/1388)_ _[at commits aa15081](https://github.com/matter-labs/era-contracts/pull/1388/commits/aa1508190f2c10e3dacea86ec5a0ef1e04b931fb)_ _[and a44fc21. The](https://github.com/matter-labs/era-contracts/pull/1388/commits/a44fc21f93aafe089606e5ae8bbe2205300c02f3)_

_<mark>`NonceIncreaseError`</mark>_ _custom error has also been modified to inform about the minimum_

_possible value too, which is 1._

### **L-04 Unreachable Code**


The helper function <u><mark>`[MAX_MODEXP_INPUT_FIELD_SIZE](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L140)`</mark></u> restricts each input field <mark>(</mark> <mark>`Bsize`</mark> <mark>,</mark>

<mark>`Esize`</mark> <mark>,</mark> <mark>`Msize`</mark> <mark>)</mark> to a maximum of 32 bytes. If any of these exceed 32, <mark>`modexpGasCost`</mark> exits

early by returning <u><mark>`[MAX_UINT64()](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1012)`</mark></u> <mark>.</mark>


Despite this restriction, the function contains a <mark>`switch`</mark> that branches on whether <u><mark>`[Esize >](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1031)`</mark></u>

<u><mark>`[32](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1031)`</mark></u> <mark>,</mark> with logic intended to handle larger exponents. However, this branch is currently

unreachable due to the enforced limit, making it effectively dead code.


This may be intentional for future-proofing, but as it stands, the logic adds unnecessary

complexity.


Consider adding clear documentation explaining why this code path is currently unreachable,

and under what future conditions it may become relevant.


**_Update:_** _[Resolved in pull request #1385. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1385)_


_This is intentional indeed -_ _<mark>`MAX_MODEXP_INPUT_FIELD_SIZE`</mark>_ _can be arbitrary, and in_

_the current version it is 32 bytes. However, more comments have been added._

## **Notes & Additional** **Information**

### **N-01 Inconsistent Interface Between Sibling** **Repositories**


The current <u>[pull request #1359](https://github.com/matter-labs/era-contracts/pull/1359)</u> in the <mark>`era-contracts`</mark> repository is linked to <u>[pull request](https://github.com/matter-labs/zksync-era/pull/3646)</u>

<u>[#3646](https://github.com/matter-labs/zksync-era/pull/3646)</u> in the <mark>`zksync-era`</mark> repository through <u>[pull request #1299](https://github.com/matter-labs/era-contracts/pull/1299)</u> in the former. Both


EVM Emulator and Semi-abstracted Nonces Update Audit − Notes &

Additional Information − 12


repositories include changes to the <mark>`INonceHolder`</mark> interface, but the modifications are not

aligned:











[The pragma directive](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol#L3) is floating in both repositories but uses a <u>[different version](https://github.com/matter-labs/zksync-era/blob/0c07301c387a86b878bb57304f18e583d562efd4/core/tests/ts-integration/contracts/custom-account/interfaces/INonceHolder.sol#L3)</u> as the

base.

The <u><mark>`[ValueSetUnderNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol#L14)`</mark></u> <u>event</u> and the <u><mark>`[isNonceUsed](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol#L44)`</mark></u> <u>function</u> are not present in

the <u><mark>`[zksync-era](https://github.com/matter-labs/zksync-era/blob/0c07301c387a86b878bb57304f18e583d562efd4/core/tests/ts-integration/contracts/custom-account/interfaces/INonceHolder.sol)`</mark></u> <u>[version of the interface.](https://github.com/matter-labs/zksync-era/blob/0c07301c387a86b878bb57304f18e583d562efd4/core/tests/ts-integration/contracts/custom-account/interfaces/INonceHolder.sol)</u>

Conversely, the <u><mark>`[setValueUnderNonce](https://github.com/matter-labs/zksync-era/blob/0c07301c387a86b878bb57304f18e583d562efd4/core/tests/ts-integration/contracts/custom-account/interfaces/INonceHolder.sol#L25-L28)`</mark></u> <u>and</u> <u><mark>`[getValueUnderNonce](https://github.com/matter-labs/zksync-era/blob/0c07301c387a86b878bb57304f18e583d562efd4/core/tests/ts-integration/contracts/custom-account/interfaces/INonceHolder.sol#L25-L28)`</mark></u> <u>functions</u> exist

only in the <mark>`zksync-era`</mark> repository and have been removed from the <u><mark>`[era-contracts](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol)`</mark></u>

<u>[version.](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol)</u>



Although the <mark>`zksync-era`</mark> version is intended for testing purposes, maintaining consistency

across both repositories is important to ensure correctness, reduce confusion, and preserve

testing robustness.


Consider aligning the <mark>`INonceHolder`</mark> interface definitions in both repositories, or clearly

documenting their divergence if intentional.


**_Update:_** _[Resolved at commit e911061](https://github.com/matter-labs/zksync-era/pull/3646/commits/e9110610796828e3849daefd0a4ed30dfc57294c)_ _on the zksync-era repository. Now both repositories are_

_consistent on the_ _<mark>`INonceHolder`</mark>_ _interface definition._

### **N-02 Misleading Documentation**


Throughout the codebase, there are instances where existing comments may be misleading or

outdated. In particular:









The default ordering system has been updated from <mark>`Sequential`</mark> to

<mark>`KeyedSequential`</mark> <mark>,</mark> but several comments still reference the previous default. This

inconsistency appears in the <u><mark>`[ContractDeployer.sol](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol)`</mark></u> [contract on lines 312, 437, and](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L312)

<u>[465.](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L465)</u>

[On line 26](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L26) of <mark>`ContractDeployer.sol`</mark> <mark>,</mark> the comment states that the <mark>`AccountInfo`</mark>

value will be zero for EOAs and simple contracts. This could be clarified to specify that a

zero value corresponds to the default <mark>`None`</mark> account abstraction version and the

<mark>`KeyedSequential`</mark> nonce ordering.



Consider updating these inline comments to accurately reflect the current system behavior.

Doing so will improve readability and reduce the risk of confusion during future development or

review.


**_Update:_** _[Resolved in pull request #1399](https://github.com/matter-labs/era-contracts/pull/1399)_ _[at commit ffcf289.](https://github.com/matter-labs/era-contracts/pull/1399/commits/ffcf2892df66452ff65aa3d40fd5337f49465059)_


EVM Emulator and Semi-abstracted Nonces Update Audit − Notes &

Additional Information − 13


### **N-03 Mismatch Between Interface and** **Implementation**

Throughout the codebase, there are some mismatches between interfaces and their

associated implementations.


The <mark>`updateNonceOrdering`</mark> function within the <u><mark>`[IContractDeployer](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/IContractDeployer.sol#L116-L117)`</mark></u> <u>interface</u> and its

implementation in the <u><mark>`[ContractDeployer](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L77-L82)`</mark></u> <u>contract</u> present the following differences:









The interface contains a named argument, while the implementation omits it to indicate

that the function should not be used, as it will always revert.

The implementation docstring states that the nonce ordering system cannot be updated,

while the interface suggests that it can.



The <mark>`NonceHolder`</mark> contract introduces a new <u><mark>`[getKeyedNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L57-L68)`</mark></u> <u>function</u> that is not included

in the associated <u><mark>`[INonceHolder](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol)`</mark></u> <u>interface. Additionally, the function ordering in the interface</u>

does not match the implementation.


Consider applying the following consistency improvements:












Remove the parameter name from the interface version of <mark>`updateNonceOrdering`</mark> to

align with the implementation.

Update the interface docstring to reflect that the function is deprecated and will always

revert.

Add the <mark>`getKeyedNonce`</mark> function to the <mark>`INonceHolder`</mark> interface.

Align function ordering in interfaces with the corresponding implementation contracts.



These changes would help reduce confusion and avoid unexpected usage patterns across the

codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #1392](https://github.com/matter-labs/era-contracts/pull/1392)</u>_ _[at commit 58acf0c. The Matter Labs team](https://github.com/matter-labs/era-contracts/pull/1392/commits/58acf0c44518d70fde17aecba9275ec62d422189)_

_stated:_


_The bullet points 1-3 were fixed. Reordering function declarations introduces merge_

_conflicts that are not worth the minor readability gain._


EVM Emulator and Semi-abstracted Nonces Update Audit − Notes &

Additional Information − 14


### **N-04 Inconsistent Handling of Nonce Types**

Throughout the codebase, there are instances where nonce values are handled inconsistently,

leading to ambiguity in interpretation and usage. In particular:









The <u><mark>`[getKeyedNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L62)`</mark></u> <u>function</u> from the <mark>`NonceHolder`</mark> contract returns data from the

<u><mark>`[rawNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L64)`</mark></u> <u>mapping</u> [when the key is zero, but returns data from the](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L63) <u><mark>`[keyedNonces](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L67)`</mark></u>

<u>[mapping](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L67)</u> when a non-zero key is provided. However, in the <u><mark>`[isNonceUsed](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L207-L215)`</mark></u> function, this

logic is not consistently applied—passing a zero key results in querying both the

<mark>`keyedNonces`</mark> and <mark>`rawNonce`</mark> mappings, instead of only <mark>`rawNonce`</mark> .

The <mark>`incrementMinNonceIfEquals`</mark> function uses the <mark>`_expectedNonce`</mark> input as

[both a combined keyed-type nonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L131) and a <u><mark>`[minNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L140)`</mark></u> <u><mark>[-](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L140)</mark></u> <u>type nonce, resulting in dual</u>

interpretation of the same value.



Although these inconsistencies do not currently introduce security vulnerabilities, having

multiple ways to interpret or validate the same data increases the potential for future bugs,

reduces clarity, and complicates maintenance.


Consider unifying the logic for handling nonce types across functions to improve consistency

and code readability.


**_Update:_** _[Resolved in pull request #1395](https://github.com/matter-labs/era-contracts/pull/1395)_ _[at commit e04af13](https://github.com/matter-labs/era-contracts/pull/1395/commits/e04af13ea377901d610ddb8f3e3e6fe846b215ad)_ _[and in pull request #1403, at](https://github.com/matter-labs/era-contracts/pull/1403)_

_[commit 6eb1fb2.](https://github.com/matter-labs/era-contracts/pull/1403/commits/6eb1fb2bb21c7804dc989727b4be7a35ae47b391)_

### **N-05 Function Visibility Overly Permissive**


Throughout the codebase, there are various functions with visibility levels that are more

permissive than necessary:













The <u><mark>`[getKeyedNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L62-L68)`</mark></u> function in <mark>`NonceHolder.sol`</mark> is marked <mark>`public`</mark> but could be

limited to <mark>`external`</mark> <mark>.</mark>

The <u><mark>`[getRawNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L74-L77)`</mark></u> function in <mark>`NonceHolder.sol`</mark> is marked <mark>`public`</mark> but could be

limited to <mark>`external`</mark> <mark>.</mark>

The <u><mark>`[increaseMinNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L82-L101)`</mark></u> function in <mark>`NonceHolder.sol`</mark> is marked <mark>`public`</mark> but

could be limited to <mark>`external`</mark> <mark>.</mark>

The <u><mark>`[_splitRawNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L237-L240)`</mark></u> function in <mark>`NonceHolder.sol`</mark> is marked <mark>`internal`</mark> but

could be limited to <mark>`private`</mark> <mark>.</mark>



Consider restricting function visibility to the minimum necessary in order to better reflect

intended usage and potentially reduce gas costs.


EVM Emulator and Semi-abstracted Nonces Update Audit − Notes &

Additional Information − 15


**_Update:_** _[Resolved in pull request #1391.](https://github.com/matter-labs/era-contracts/pull/1391)_

### **N-06 Lack of Security Contact**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to report vulnerabilities. This practice allows

the code owners to define a preferred communication channel for responsible disclosure,

reducing the risk of miscommunication or missed reports. Additionally, in cases where third
party libraries are used, maintainers can easily reach out with mitigation guidance if needed.


Throughout the codebase, there are contracts that do not include a security contact:








The <u><mark>`[IContractDeployer](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/IContractDeployer.sol)`</mark></u> <u>interface.</u>

The <u><mark>`[INonceHolder](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol)`</mark></u> <u>interface.</u>



Consider adding a NatSpec comment containing a security contact above each contract

definition. Using the <mark>`@custom:security-contact`</mark> tag is recommended, as it has been

adopted by tools like <u>[OpenZeppelin Wizard](https://wizard.openzeppelin.com/)</u> and repositories such as <u>[ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)</u>


**_Update:_** _[Resolved in pull request #1399](https://github.com/matter-labs/era-contracts/pull/1399)_ _[at commit bfbe2a8.](https://github.com/matter-labs/era-contracts/pull/1399/commits/bfbe2a8c26c9e66f8d7591ed720a5faeb33cc713)_

### **N-07 Functions Updating State Without Event** **Emissions**


Throughout the codebase, multiple instances of functions update contract state without

emitting corresponding events. Examples include:










The <u><mark>`[increaseMinNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L82-L101)`</mark></u> <u>function</u> in <mark>`NonceHolder.sol`</mark>

The <u><mark>`[incrementMinNonceIfEquals](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L130-L153)`</mark></u> <u>function</u> in <mark>`NonceHolder.sol`</mark>

The <u><mark>`[incrementMinNonceIfEqualsKeyed](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L159-L174)`</mark></u> <u>function</u> in <mark>`NonceHolder.sol`</mark>

The <u><mark>`[incrementDeploymentNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L189-L201)`</mark></u> <u>function</u> in <mark>`NonceHolder.sol`</mark>



Consider emitting events for all state-changing operations to improve transparency, support

off-chain indexing, and reduce the risk of silent state mutations that may be difficult to track or

audit later.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


EVM Emulator and Semi-abstracted Nonces Update Audit − Notes &

Additional Information − 16


_Since EVM does not emit events for nonce increments, it was decided to not emit them_

_in_ _<mark>`NonceHolder.sol`</mark>_ _to not make developers rely on them. Custom AA accounts may_

_still decide to emit them from their own contracts, if they should need them._

### **N-08 Unused Event**


In the <mark>`INonceHolder`</mark> interface, the <u><mark>`[ValueSetUnderNonce](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/interfaces/INonceHolder.sol#L14)`</mark></u> <u>event</u> is defined but is not used

throughout the codebase.


Consider removing the unused event to improve code readability and reduce unnecessary

interface clutter.


**_Update:_** _[Resolved in pull request #1390.](https://github.com/matter-labs/era-contracts/pull/1390)_

### **N-09 Redundant Return Statements**


To improve the readability of the codebase, it is recommended to remove redundant return

statements from functions that have named returns.


Throughout the codebase, there are multiple instances of redundant return statements. Some

of them fall outside of the current audit scope; however, it is beneficial to highlight them as

well:















<u>[Line 41](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L41)</u> from the <mark>`getAccountInfo`</mark> function in <mark>`ContractDeployer.sol`</mark> should

assign to the <mark>`info`</mark> return variable.


<u>[Line 217](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L217)</u> from the <mark>`precreateEvmAccountFromEmulator`</mark> function in

<mark>`ContractDeployer.sol`</mark> is redundant.


<u>[Line 417](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L417)</u> in function <mark>`_evmDeployOnAddress`</mark> in <mark>`ContractDeployer.sol`</mark> should

assign the final value to the <mark>`constructorReturnEvmGas`</mark> return variable.


<u>[Lines 473-480](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/ContractDeployer.sol#L473-L480)</u> from the <mark>`_performDeployOnAddressEVM`</mark> function should assign the

internal function output to the <mark>`constructorReturnEvmGas`</mark> return variable in

<mark>`ContractDeployer.sol`</mark> <mark>.</mark>


<u>[Line 180](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L183)</u> from the <mark>`getDeploymentNonce`</mark> function in <mark>`NonceHolder.sol`</mark> is

redundant.



Consider removing the redundant return statement in functions with named returns to improve

the readability of the contract.


EVM Emulator and Semi-abstracted Nonces Update Audit − Notes &

Additional Information − 17


**_Update:_** _[Resolved in pull request #1394.](https://github.com/matter-labs/era-contracts/pull/1394)_

### **N-10 Implicit Casting**


The lack of explicit casting hinders code readability and makes the codebase hard to maintain

and error-prone.


The <mark>`nonceValue`</mark> parameter is implicitly <u>[cast](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/contracts/NonceHolder.sol#L119)</u> to <mark>`uint256`</mark> from <mark>`uint64`</mark> within the

<mark>`_combineKeyedNonce`</mark> function.


Consider explicitly casting all integer values to their expected type to improve readability and

reduce the risk of subtle bugs in future updates.


**_Update:_** _[Resolved in pull request #1393.](https://github.com/matter-labs/era-contracts/pull/1393)_

### **N-11 Inconsistent Variable Naming**


Throughout the codebase, all variables follow the "camelCase" naming convention. However,

when calculating the gas cost for the <mark>`Modexp`</mark> precompile, there are some instances where

this convention is violated.


[When retrieving](https://github.com/matter-labs/era-contracts/blob/cc1619cfb03cc19adb21a2071c89415cab1479e8/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L999-L1001) the base, exponent, and modulus lengths in bytes, these variables are named

<mark>`Bsize`</mark> <mark>,</mark> <mark>`Esize`</mark> <mark>,</mark> and <mark>`Msize`</mark> <mark>,</mark> respectively.


Consider enforcing consistency in the naming convention used across all variables by

renaming these to <mark>`bSize`</mark> <mark>,</mark> <mark>`eSize`</mark> <mark>,</mark> and <mark>`mSize`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #1386.](https://github.com/matter-labs/era-contracts/pull/1386)_


EVM Emulator and Semi-abstracted Nonces Update Audit − Notes &

Additional Information − 18


## **Conclusion**

This audit focused on the implementation of the <mark>`ModExp`</mark> precompile gas cost calculation, the

adjustments in the Emulator to avoid unnecessary bytecode copying via pointer usage, and the

introduction of semi-abstracted nonces in the system contracts in accordance to <u>[EIP-4337.](https://eips.ethereum.org/EIPS/eip-4337#semi-abstracted-nonce-support)</u>


During the audit, one critical and one high-severity issue were identified. In addition, several

issues related to optimization, insufficient checks, low test coverage and best practices were

identified that, while not immediately threatening to system security, could impact

performance, maintainability, and gas efficiency.


Despite these findings, communication with the team was notably fast and friendly, and the

modular nature of the code indicates an overall organized approach. That said, there is

considerable room for improvement in areas such as comprehensive documentation of recent

changes and more robust testing strategies. Addressing these concerns will better position the

project for future upgrades.


EVM Emulator and Semi-abstracted Nonces Update Audit − Conclusion − 19


