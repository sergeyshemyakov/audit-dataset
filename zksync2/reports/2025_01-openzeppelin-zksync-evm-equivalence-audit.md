### | security

# **EVM Equivalence** **Audit**

#### **January 15, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  6

Notable Differences From the Ethereum Execution Environment 7


Security Model and Trust Assumptions _______________________________________________  8


High Severity ______________________________________________________________________  9

H-01 Wrong CALL Implementation Under Static Context 9

H-02 Possible Arbitrary Code Execution in EVM Contracts 9

H-03 Discrepancy in getCodeHash Compared to EVM extcodehash Behavior 10

H-04 Complete EVM Environment Abort for CALL with Insufficient Value 11

H-05 Incorrect Bytecode Assumption for EraVM Contract in fetchDeployedCode 11


Medium Severity _________________________________________________________________ 12

M-01 Missing Stack Overflow Check In dupStackItem 12

M-02 Incorrect Implementation of the checkMemIsAccessible Function 12

M-03 Callee Frame Charged With Address Decommitment Cost 13

M-04 Possible to Zero Out Stack, Bytecode, or Memory in an EVM Contract 14

M-05 extcodecopy Opcode Behavior Diverges From EVM 14

M-06 Calldata is Accessible During EVM Contract Construction 15

M-07 calldataload/calldatacopy Behavior Diverges From EVM 15

M-08 Underestimated Gas Cost for MCOPY 16

M-09 Nonce Not Incremented When Deploying EVM Contracts at Existing Addresses 16

M-10 EVM-to-EVM Contract Interaction Allows for Gas Griefing Attacks 17


Low Severity ____________________________________________________________________ 18

L-01 Loose Stack Overflow Check 18

L-02 Reverting with Misleading Error in EvmGasManager 18

L-03 INVALID Opcode Behavior Divergence in EraVM<>EVM Interaction 19

L-04 Absence of EVM Contract Force Deployment Logic 19

L-05 Incorrect MAX_EVM_BYTECODE_LENGTH in Utils Library 20

L-06 Incorrect Custom Error Revert in EvmGasManager 20

L-07 EVM Emulator Uses call for isSlotWarm Function 21

L-08 Behavior Divergence with EVM for Create* Opcodes 21

L-09 Unexpected Balance Increase for EVM Contracts Without Fallback/Receive Functions 22

L-10 Incorrect Gas Handling in delegatecall Implementation 22


EVM Equivalence Audit − Table of Contents − 2


Notes & Additional Information ____________________________________________________ 23

N-01 Hardcoded Memory Offsets 23

N-02 Naming Suggestions 23

N-03 Misleading Documentation 24

N-04 Gas Optimizations 24

N-05 Code Simplification 25

N-06 Unused Functions 25

N-07 Redundant Logic in _constructEVMContract 26

N-08 Repetitive Logic During EVM-to-EVM Contract Creation 26

N-09 Magic Numbers 27

N-10 Missing Documentation 27

N-11 prevrandao Opcode Implementation Inefficiency 28

N-12 Redundant Warming of EVM Account During Construction 28

N-13 Free Deployment Of Evm Contract 28

N-14 Stipend Value is Added Twice to the Call's Gas 29


Conclusion ______________________________________________________________________ 30


EVM Equivalence Audit − Table of Contents − 3


## **Summary**

**Type** Layer 2


**Timeline** From 2024-10-28
To 2024-12-13


**Languages** Yul, Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


5 (4 resolved, 1 partially resolved)


10 (9 resolved)



**Total Issues** 39 (33 resolved, 3 partially resolved)



**Low Severity Issues** 10 (8 resolved, 1 partially resolved)



**Notes & Additional**
**Information**



14 (12 resolved, 1 partially resolved)



EVM Equivalence Audit − Summary − 4


## **Scope**

We audited the <u>[matterlabs/era-contracts](https://github.com/matter-labs/era-contracts)</u> repository at commit <u>[397092d.](https://github.com/matter-labs/era-contracts/tree/397092db593baa5003ec77ad420c50104bc02fe2)</u>


In scope were the following files:

```
era-contracts/system-contracts/
├── contracts
│  ├── EvmEmulator.yul
│  └── EvmGasManager.yul
└── evm-emulator
├── EvmEmulator.template.yul
├── EvmEmulatorFunctions.template.yul
├── EvmEmulatorLoop.template.yul
└── EvmEmulatorLoopUnusedOpcodes.template.yul

```

We also diff-audited the <u>[matterlabs/era-contracts](https://github.com/matter-labs/era-contracts)</u> repository between base commit <u>[658713f](https://github.com/matter-labs/era-contracts/commit/658713f3a25847662cc997408bd4ccc461f6380a)</u>

[and head commit ed6f4d1.](https://github.com/matter-labs/era-contracts/commit/ed6f4d1f8fcde854e084cd1d237fd80698f2da19)


EVM Equivalence Audit − Scope − 5


## **System Overview**

To facilitate developers relying on EVM bytecode support, ZKsync Era has introduced an EVM

[execution mode via emulation](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmEmulator.yul) on top of EraVm.


**Core System:** The primary system remains EraVM, allowing for the deployment and execution

of native EraVM contracts. The unit of gas for all executions continues to be the native EraVM

gas (ergs).


**EVM Contract Execution:** The platform now also supports the deployment and execution of

EVM contracts. EraVm and EVM contracts are distinguished by <u>[a special marker](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/Constants.sol#L167-L170)</u> in their

bytecode hash. When EVM bytecode is invoked, the virtual machine invokes the predefined

<u><mark>`[EvmEmulator](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmEmulator.yul)`</mark></u> contract. This emulator loads, interprets, and executes the EVM bytecode in a

manner consistent with Ethereum's execution environment, with adjustments made for the

peculiarities of EraVM. This is achieved by emulating the EVM opcodes. Specifically, the

implementation adheres to the EVM specification after the Cancun upgrade fork.


**Environment Agnostic:** The EVM environment operates independently of EraVM, meaning that

EraVM contracts are unaware of the EVM emulation. When an EraVM contract calls an EVM

contract, the calldata is passed as it is, without any modifications. Similarly, when an EVM

contract returns data to an EraVM contract, the returndata is returned as it is, without any

further changes. Any modification needed is handled solely by the system contracts and the

emulator. A special system contract, <u><mark>`[EvmGasManager](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmGasManager.yul)`</mark></u> <mark>,</mark> behaves like a helper contract for the

emulator and is responsible for handling the hot/cold storage slots and accounts. It also

handles the <mark>`EvmFrame`</mark> <mark>s</mark> in cooperation with the emulator, which are needed in order to pass

the <mark>`isStatic`</mark> flag and remaining EVM gas information between the EVM call frames.


**Interaction Between EraVM and EVM:**


The following is the basic schema for the interaction between EraVm and EVM contracts:









A transaction always starts with the execution of <mark>`Bootloader`</mark> <mark>,</mark> which initiates a

subsequent call.

When an EraVM contract calls an EVM contract, the actual target contract's bytecode is

replaced with the bytecode of the EVM emulator, which loads the target contract's

bytecode and initiates the interpretation process.


EVM Equivalence Audit − System Overview − 6


When an EVM contract calls an EraVM contract, it is treated as a standard call to a native

EraVM contract.

The gas units from the EVM environment are converted to ergs using a <u>[fixed conversion](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L121)</u>

<u>[ratio](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L121)</u> and vice versa.



This approach ensures seamless interoperability between native EraVM and EVM contracts

while preserving the distinct execution contexts of each.

### **Notable Differences From the Ethereum** **Execution Environment**


**Gas Costs**


When an emulated EVM contract is executed, the gas charged is the native gas of ZKsync Era,

called ergs. In order to remain as close as possible to the EVM behavior, the emulator keeps

track of the EVM gas following the EVM opcodes' specification. When an EVM contract is

triggered for the first time by an EraVM contract, the ergs passed are converted to EVM gas

units using a specified ratio. As the bytecode execution moves forward, the emulator subtracts

the corresponding gas costs from the total gas left. If another EVM contract is called during the

execution, the EVM gas passed to the callee frame respects the EVM gas left to the current

[execution frame and other EVM rules (e.g., the 63/64th rule).](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L841)


[If an EraVM contract is called during the execution, the ergs passed for the call also respect](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L792)

<u>[the EVM gas left](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L792)</u> to the current execution (converted appropriately), even if EVM gas costs are

generally expected to differ from the actual charged ergs. This design is needed to ensure that

any potential subsequent call to an EVM contract receives a lower EVM gas amount than the

EVM gas left at the origin EVM contract. Note that, per this design, developers should be extra

cautious regarding the gas provided to the nested calls originating from their contracts. This is

to avoid out-of-gas errors or gas griefing attacks within the EraVM environment.


**EVM <-> EraVM** **<mark>`delegatecall`</mark>** **Is Not Allowed**


While calls between EVM and EraVM contracts are supported, <u><mark>`[delegatecall](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L716-L717)`</mark></u> <u><mark>s</mark></u> <u>are not. This</u>

is important to ensure the integrity of the emulator's processes and bookkeeping that follows

the EVM specification closely (e.g., the cold/warm storage slots). Developers need to be

mindful of this design, especially when it comes to certain design patterns that involve proxy

contracts.


**Subset of EVM Precompiles Is Supported**


EVM Equivalence Audit − System Overview − 7


Currently, 6 out of the 10 <u>[EVM precompiles](https://www.evm.codes/precompiled)</u> are supported. Specifically, <u>[the ones not supported](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L852-L902)</u>

are: <mark>`RIPEMD-160`</mark> <mark>,</mark> <mark>`modexp`</mark> <mark>,</mark> <mark>`blake2f`</mark> <mark>,</mark> and KZG point evaluation.

## **Security Model and Trust** **Assumptions**


The EVM emulator contract can be upgraded by privileged and trusted entities who administer

the system. This is important for providing code fixes for potential security issues. Other than

that, the EVM emulator and the diffs audited do not introduce any new security assumptions to

the system.


EVM Equivalence Audit − Security Model and Trust Assumptions − 8


## **High Severity**

### **H-01 Wrong CALL Implementation Under Static** **Context**

According to the EVM <u>[opcodes specifcationi](https://www.evm.codes/?fork=cancun#f1)</u> <u>, the</u> <mark>`CALL`</mark> opcode should revert if the execution

context is static and the <mark>`value`</mark> parameter is not zero. In the <mark>`EvmEmulatorLoop`</mark> template,

the <mark>`CALL`</mark> [opcode implementation checks](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L1426) whether the current execution context is static and

performs a <u>[normal call](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L1428)</u> or a <u>[static call](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L1431)</u> by calling the <u><mark>`[performCall](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L585)`</mark></u> and

<u><mark>`[performStaticCall](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L647)`</mark></u> functions accordingly.


In case of a static context, <mark>`value`</mark> is never checked against zero. Specifically,

<mark>`performStaticCall`</mark> extracts only 6 items out of the stack, essentially as many as expected

from a <u><mark>`[STATICCALL](https://www.evm.codes/?fork=cancun#fa)`</mark></u> <mark>.</mark> However, even in a static context, the <mark>`CALL`</mark> opcode requires 7 input

items on the stack. Consequently, the input parameters are wrongly retrieved from the stack in

this scenario, essentially loading <mark>`value`</mark> to <mark>`argsOffset`</mark> <mark>,</mark> <mark>`argsOffset`</mark> to <mark>`argsSize`</mark> <mark>,</mark> and

so on.


Consider popping the input arguments out of the <mark>`performCall`</mark> and <mark>`performStaticCall`</mark>

functions so that they are properly handled according to each opcode's specification. In

addition, in order to remain compatible with the EVM specification, consider always checking

the <mark>`value`</mark> parameter when executing the <mark>`CALL`</mark> opcode in a static context and reverting in

case of a non-zero value.


**_Update:_** _[Resolved in pull request #1091](https://github.com/matter-labs/era-contracts/pull/1091)_ _[at commit 6fe1257.](https://github.com/matter-labs/era-contracts/commit/6fe12575d598cc8e0f0b701a9319890759c6ef9d)_

### **H-02 Possible Arbitrary Code Execution in EVM** **Contracts**


A smart contract on the EVM runs a sequence of instructions known as opcodes. Execution

generally proceeds one instruction at a time, moving forward through the code. To support

loops and conditional branching, the EVM uses <mark>`JUMP`</mark> and <mark>`JUMPI`</mark> instructions, which alter the

instruction pointer to a specified position in the contract’s bytecode. Under normal conditions,

the jump targets must be valid positions within the deployed contract bytecode.


EVM Equivalence Audit − High Severity − 9


In the <mark>`EvmEmulator`</mark> contract, the <mark>`JUMP`</mark> and <mark>`JUMPI`</mark> instructions lack sufficient validation.

While there <u>[is a check](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L238-L243)</u> to ensure that the pointer does not exceed the code length, there is no

corresponding check to ensure that it does not point to a location before <u>[the](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L77)</u>

<u><mark>`[BYTECODE_OFFSET](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L77)`</mark></u> <mark>.</mark> Since the code and data structures, including the stack, are stored in the

same EraVM memory space, a <u>[carefully chosen](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L750-L751)</u> <u><mark>`[counter](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L750-L751)`</mark></u> can wrap around due to a lack of

overflow checks. This can redirect execution into memory regions before the bytecode offset,

[including the emulated stack](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L69) that is possible to control and malform. As a result, it may be

possible to execute arbitrary instructions, enabling unpredictable execution flows.


Consider implementing a strict validation check which ensures that the instruction pointer

always targets a position within the contract’s bytecode.


**_Update:_** _[Resolved in pull request #1159](https://github.com/matter-labs/era-contracts/pull/1159)_ _[at commit 0419d3e.](https://github.com/matter-labs/era-contracts/commit/0419d3e1ab3ba2715ce87eb86fa60145cd7a2de8)_

### **H-03 Discrepancy in getCodeHash Compared to** **EVM extcodehash Behavior**


The <mark>`AccountCodeStorage`</mark> contract is responsible for storing the code hashes of accounts.

There are two functions for retrieving an account's code hash: <mark>`getRawCodeHash`</mark> <mark>,</mark> which

simply reads the value stored under the account's slot, and <mark>`getCodeHash`</mark> <mark>,</mark> [which simulates](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/AccountCodeStorage.sol#L95)

the behavior of the EVM <mark>`extcodehash`</mark> opcode. However, the behavior of the <u><mark>`[getCodeHash](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/AccountCodeStorage.sol#L98-L123)`</mark></u>

<u>[function](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/AccountCodeStorage.sol#L98-L123)</u> differs from that of the EVM <mark>`extcodehash`</mark> opcode when the account has no code, a

zero nonce, and a **non-zero** balance. In the EVM, <mark>`extcodehash`</mark> should return the hash of an

empty string in this scenario. However, in the codebase, <mark>`0x00`</mark> is returned.


[Likewise, the EVM emulator includes a specifc checki](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L539-L542) for a zero address and returns zero in

that case. However, this approach can be error-prone because if the zero address has a zero

balance, the expected result should be zero, and if the zero address has a non-zero balance,

the result should be the hash of an empty string. It is also worth noting that during the

construction of an EVM contract, the construction bytecode ( <mark>`0x020100...00`</mark> <mark>)</mark> can be

retrieved for the account. This behavior deviates from the EVM’s expected <mark>`extcodehash`</mark>

behavior.


Consider standardizing the behavior of the codebase to align it with that of the EVM and have

it accurately mimic the account code hash functionality.


**_Update:_** _Partially resolved in_ _<u>[pull request #1125](https://github.com/matter-labs/era-contracts/pull/1125)</u>_ _[at commit c4c964b. The Matter Labs team](https://github.com/matter-labs/era-contracts/commit/c4c964b5704ac667f099da7361abf70cbb654689)_

_stated:_


_Fixed by reimplementing EXTCODEHASH inside the emulator._


EVM Equivalence Audit − High Severity − 10


### **H-04 Complete EVM Environment Abort for CALL** **with Insufficient Value**

The <u><mark>`[CALL](https://www.evm.codes/?fork=cancun#f1)`</mark></u> <u>[opcode](https://www.evm.codes/?fork=cancun#f1)</u> in an EVM environment invokes a target account with specified parameters,

including data, gas, and value. According to its specification, if the transferred value exceeds

the caller’s available balance, the call should fail but not revert the overall execution context.

Instead, it should return zero, produce empty returndata, and refund the appropriate gas

stipend. ZKsync's compiler <u>[adds conditional behavior](https://github.com/matter-labs/era-compiler-llvm-context/blob/564e41b4d9e0b6a3a0d2f875c6dd891477cef70c/src/eravm/evm/call.rs#L688-L749)</u> based on the call's value argument: if

the value is zero, the call is directly made to the target contract. However, if the value is non
zero, the call routes through the <mark>`MsgValueSimulator`</mark> <mark>.</mark>


[In the current EVM emulator implementation, when the caller’s balance is insufficient, the entire](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L1424-L1434)

execution chain is inadvertently aborted. This occurs because the caller’s balance <u>[is not](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L585-L645)</u>

<u>[verified](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L585-L645)</u> before initiating the EraVM's <mark>`CALL`</mark> opcode. Since the value is not zero, the call goes

through <mark>`MsgValueSimulator`</mark> <mark>,</mark> [triggering the fallback](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/MsgValueSimulator.sol#L49-L94) function of <mark>`MsgValueSimulator`</mark>

which subsequently calls <u><mark>`[transferFromTo](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/L2BaseToken.sol#L33-L54)`</mark></u> in <mark>`L2BaseToken`</mark> <mark>.</mark> If the caller lacks the required

balance, the call to <mark>`L2BaseToken`</mark> fails and <mark>`MsgValueSimulator`</mark> reverts with <u><mark>`[revert(0,](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/MsgValueSimulator.sol#L74)`</mark></u>

<u><mark>`[0)](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/MsgValueSimulator.sol#L74)`</mark></u> <mark>.</mark> As a result, <u><mark>`[_saveReturndataAfterEVMCall](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L914-L919)`</mark></u> processes empty returndata, leading to

<u><mark>`[abortEvmEnvironment](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L140-L142)`</mark></u> and halting the entire call chain instead of simply returning zero and

empty returndata.


Consider performing a balance check of the caller before executing the <mark>`CALL`</mark> opcode. This

ensures that if the requested value cannot be covered, the call correctly fails without reverting

the entire context, preserving the intended EVM behavior of returning zero success status and

empty returndata.


**_Update:_** _[Resolved in pull request #1108](https://github.com/matter-labs/era-contracts/pull/1108)_ _[at commit c74c6ec.](https://github.com/matter-labs/era-contracts/commit/c74c6ecc2db289fb33f7c88f0fa353b92cce94d9)_

### **H-05 Incorrect Bytecode Assumption for EraVM** **Contract in fetchDeployedCode**


Two types of code hashes are present in the protocol: type 1 for EraVM contract code hashes

and type 2 for EVM contract code hashes. During EVM contract deployment, the code hash is

derived from the padded bytecode containing the length prefix, the bytecode itself, and any

necessary padding to align with blockchain requirements. System flags, the code hash version,

and the code length are stored in the most significant bits.


In the EVM emulator, when the <mark>`extcodecopy`</mark> opcode executes, it calls the

<u><mark>`[fetchDeployedCode](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L335)`</mark></u> <u>function, which then invokes</u> <mark>`CodeOracle`</mark> to retrieve the contract


EVM Equivalence Audit − High Severity − 11


bytecode. Here, <u>[it is assumed](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L345)</u> that the first word represents the account length, but this only

applies to EVM-type contracts as EraVM contracts do not have this length prefix. This causes

the emulator to treat the first 32 bytes of the hash as a length value and can lead to bytecode

misalignment, incorrect behavior, and potential overflow when calculating offsets. Large values

can trigger out-of-bounds attempts at <mark>`returndatacopy`</mark> <mark>,</mark> while other values can lead to

skipping parts of the bytecode.


Consider not assuming that the first word returned by <mark>`CodeOracle`</mark> represents the contract

length. Instead, rely on the length information derived from the raw code hash. Take into

account the fact that EraVM contracts store their length in words, whereas EVM contracts

store it in bytes.


**_Update:_** _[Resolved in pull request #1157](https://github.com/matter-labs/era-contracts/pull/1157)_ _[at commit c396c03](https://github.com/matter-labs/era-contracts/commit/c396c03ec85ef18bffce73776789e6812a7059b4)_ _[and in pull request #1196](https://github.com/matter-labs/era-contracts/pull/1196)_ _at_

_[commit 875d0a5. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1196/commits/875d0a53447d261763204ce4b45e33583e78113d)_


_Prefixes are removed, length is encoded in the hash._

## **Medium Severity**

### **M-01 Missing Stack Overflow Check In** **`dupStackItem`**


In the <u><mark>`[EvmEmulatorFunctions](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul)`</mark></u> template, the <u><mark>`[dupStackItem](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L418)`</mark></u> function duplicates a

specific stack item by copying it and pushing it into the stack. However, it is not checked that

the stack will not overflow before duplicating the item. As a consequence, it is possible to

overflow beyond the dedicated stack's space.


Consider checking that there is available stack space before inserting another item via the

<mark>`dupStackItem`</mark> function.


**_Update:_** _[Resolved in pull request #1087](https://github.com/matter-labs/era-contracts/pull/1087)_ _[at commit ba50e19.](https://github.com/matter-labs/era-contracts/commit/ba50e1931cdafb29c0f9d817eb9445399cd5d12a)_

### **M-02 Incorrect Implementation of the** **checkMemIsAccessible Function**


[The implemented EVM emulator sets a bounded memory space, considering the maximum](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L94-L109)

possible memory expansion due to each block's gas limit. The <u><mark>`[checkMemIsAccessible](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L223)`</mark></u>


EVM Equivalence Audit − Medium Severity − 12


function is responsible for checking that a requested part of the memory, as defined by a

memory offset and the data size, is within these bounds. However, when performing the check

within <mark>`checkMemIsAccessible`</mark> <mark>,</mark> the offset is mistakenly not considered in relation to the

memory's starting slot. Thus, the check always underestimates the maximum memory slot

requested.


Consider adding <mark>`MEM_OFFSET`</mark> to the offset argument of the <mark>`checkMemIsAccessible`</mark>

function in order to properly check for potential out-of-bounds memory access.


**_Update:_** _[Resolved in pull request #1082](https://github.com/matter-labs/era-contracts/pull/1082)_ _[at commit 8e8323d. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/commit/8e8323de73e15d1c88a0b90d008a7c13528c4a29)_


_This issue has no real impact, as this check is intended to simplify out-of-gas errors_

_when trying to expand memory to too large values. Given the actual block gas limit, the_

_current implementation also works. However, the implementation has been fixed._

### **M-03 Callee Frame Charged With Address** **Decommitment Cost**


The EVM emulator adheres closely to the EVM gas cost specification to accurately simulate the

EVM environment. As a result, the gas costs during an emulated transaction are expected to

be overestimated. Even if the user is not actually charged the EVM gas costs, these costs <u>[cap](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L625)</u>

the gas passed to a nested call. When a call to a zkEVM contract is executed, there is an

[additional gas cost for the decommitment](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L793) of the called address. Currently, the decommitment

gas cost <u>[further limits](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L799)</u> the gas passed to the callee frame, even if it is not an emulated EVM

cost. As a result, the gas passed to the callee frame could be significantly underestimated,

potentially leading to out-of-gas errors.


In order to prevent unreasonable out-of-gas errors, consider excluding the decommitment gas

cost when calculating the gas passed to the zkEVM callee frame. Alternatively, consider giving

an extra gas stipend for this cost if it is expected to be charged within the callee frame.


**_Update:_** _[Resolved in pull request #1086](https://github.com/matter-labs/era-contracts/pull/1086)_ _[at commit b649f5f, pull request #1196](https://github.com/matter-labs/era-contracts/commit/b649f5f5cc0cba54479688d31e98d585542391d0)_ _at commit_

_<u>[3c77d4a. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1196/commits/3c77d4a015db6dd4e4aab6baa25a72f56ffa11ef)</u>_


_Explicit address decommitment cost has been removed. Additionally, extra stipend was_

_added, to cover call to Empty and DefaultAccount contracts._


EVM Equivalence Audit − Medium Severity − 13


### **M-04 Possible to Zero Out Stack, Bytecode, or** **Memory in an EVM Contract**

The EVM executes smart contracts by manipulating data in memory, stack, and storage. The

<mark>`extcodecopy`</mark> operation is typically used to load another contract’s bytecode into memory.

This process involves specifying an offset and a length, after which the code is copied and any

remaining space is filled with zeroes.


In the <u><mark>`[extcodecopy](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L452-L494)`</mark></u> <u>implementation</u> of the <mark>`EvmEmulator`</mark> contract, if the requested length

exceeds the actual code length of the target contract, the

<u><mark>`[$llvm_AlwaysInline_llvm$_memsetToZero](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1143-L1152)`</mark></u> <u>function</u> is called, which sets the remaining

memory to zero. Currently, the starting point of the zeroing process does not include <u>[the](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L489)</u>

<u><mark>`[MEM_OFFSET](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L489)`</mark></u> and only accounts for the <mark>`dstOffset`</mark> and <mark>`copiedLen`</mark> <mark>.</mark> As a result, it is

possible to target specific memory regions—such as system variables, stack values (if

<mark>`dstOffset`</mark> equals <mark>`STACK_OFFSET`</mark> <mark>)</mark>, contract memory areas, contract bytecode, or

previously returned data length—and overwrite them with zeroes under certain conditions.


Consider including the <mark>`MEM_OFFSET`</mark> when calculating the starting point for zeroing the

memory region. This ensures that system variables and other memory areas are not

unintentionally overwritten.


**_Update:_** _[Resolved in pull request #1115](https://github.com/matter-labs/era-contracts/pull/1115)_ _[at commit 37874c7.](https://github.com/matter-labs/era-contracts/commit/37874c76783aaab54dc28136c7090b09fc98a878)_

### **M-05 extcodecopy Opcode Behavior Diverges** **From EVM**


The <mark>`extcodecopy`</mark> opcode in the EVM is used to copy code from a given address to the

memory of the current context. An address in the EVM is represented as 20 bytes (160 bits). In

the current EVM Emulator implementation, the <u><mark>`[extcodecopy](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L452-L494)`</mark></u> <u>opcode</u> does not mask the

address before passing it to the <mark>`getRawCodeHash`</mark> function. While address masking is

performed elsewhere (e.g., within the <u><mark>`[$llvm_AlwaysInline_llvm$_warmAddress](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L504)`</mark></u>

<u>[function), it is not done in](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L504)</u> <mark>`getRawCodeHash`</mark> <mark>.</mark>


The <u><mark>`[getRawCodeHash function](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/AccountCodeStorage.sol#L87-L92)`</mark></u> of the <mark>`AccountCodeStorage`</mark> contract is implemented

in Solidity, where the compiler inserts argument validation checks to prevent invalid data from

being passed. If invalid data is detected, the function reverts with zero bytes. This causes an

unexpected state in the EVM emulator's <u><mark>`[fetchFromSystemContract](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L287-L290)`</mark></u> <u>function, ultimately</u>

terminating the EVM execution environment.


EVM Equivalence Audit − Medium Severity − 14


Consider applying address masking before invoking <mark>`getRawCodeHash`</mark> to ensure that all

addresses conform to the expected 160-bit format, as is done in the implementation of <u>[other](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L441)</u>

<u>[opcodes.](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L441)</u>


**_Update:_** _[Resolved in pull request #1116](https://github.com/matter-labs/era-contracts/pull/1116)_ _[at commit 6a76d76.](https://github.com/matter-labs/era-contracts/commit/6a76d761f07174fd5f3c62a34a6c72e34ac09480)_

### **M-06 Calldata is Accessible During EVM** **Contract Construction**


In the EVM, when a contract is created, the calldata is empty. As a result, <mark>`calldatasize`</mark> and

related opcodes return zero during the construction phase. In the current <u>[EVM emulator](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L339-L375)</u>

<u>[implementation, there is no check to determine whether the current frame is a constructor. This](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L339-L375)</u>

leads to non-empty calldata being returned during contract construction, causing a divergence

from standard EVM behavior.


Consider verifying the <mark>`isConstructing`</mark> flag in bytecode hash for the current account. If it

has been set, mimic the EVM behavior.


**_Update:_** _[Resolved in pull request #1160](https://github.com/matter-labs/era-contracts/pull/1160)_ _[at commit 684c072, pull request #1196](https://github.com/matter-labs/era-contracts/commit/684c072d0caea28a1f970d4d7ba98effa374f8c4)_ _at commit_

_<u>[16b76a2. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1196/commits/16b76a2073b4398e7ce08738c436c3be03fb1c43)</u>_


_Different opcode implementations were made for the corresponding cases._

### **M-07 calldataload / calldatacopy Behavior** **Diverges From EVM**


In the EVM, the <mark>`calldataload`</mark> and <mark>`calldatacopy`</mark> opcodes <u>[return zero bytes](https://www.evm.codes/?fork=cancun#37)</u> when

accessing an index that exceeds the calldata length, including extremely large indexes such as

the maximum value of a 256-bit unsigned integer. However, in EraVM, these opcodes trigger a

panic error if the index is greater than <mark>`2^32-33`</mark> <mark>,</mark> [as documented in the EraVM documentation.](https://docs.zksync.io/zksync-protocol/differences/evm-instructions#calldataload-calldatacopy)

This divergence may cause unexpected behavior in EVM-like environments that rely on the

standard EVM implementation.


The current implementation of <u><mark>`[calldataload](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L339-L375)`</mark></u> <u>and</u> <u><mark>`[calldatacopy](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L339-L375)`</mark></u> for the EVM emulator

does not account for EraVM's behavior. This could lead to inconsistencies in handling edge

cases.


In order to replicate EVM behavior, consider implementing a check for the accessed index in

the EVM emulator.


EVM Equivalence Audit − Medium Severity − 15


**_Update:_** _[Resolved in pull request #1097](https://github.com/matter-labs/era-contracts/pull/1097)_ _[at commit 12efa1c, pull request #1196](https://github.com/matter-labs/era-contracts/commit/12efa1c00fbfbd4de7b919438010f5af75750902)_ _at commit_

_<u>[16b76a2.](https://github.com/matter-labs/era-contracts/pull/1196/commits/16b76a2073b4398e7ce08738c436c3be03fb1c43)</u>_

### **M-08 Underestimated Gas Cost for MCOPY**


The <u><mark>`[MCOPY](https://www.evm.codes/?fork=cancun#5e)`</mark></u> <u>opcode</u> copies memory data from one memory area to another. The total gas cost

consists of two parts: a static part that charges 3 gas units independent of the size of the

copied data, and a dynamic part that charges extra gas units in case the memory expands

during this operation.


In the <mark>`EvmEmulatorLoops`</mark> template, the <u><mark>`[MCOPY](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L838)`</mark></u> <u>[implementation](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L838)</u> is missing the static gas

cost part, as it only charges the gas needed to expand the memory.


Consider always charging the static gas cost of the <mark>`MCOPY`</mark> operation to remain equivalent to

the corresponding EVM implementation.


**_Update:_** _[Resolved in pull request #1081](https://github.com/matter-labs/era-contracts/pull/1081)_ _[at commit 44bd426. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/commit/44bd426a0b5915da962519119185ded8c0277eee)_


_The missing static gas cost has been added._

### **M-09 Nonce Not Incremented When Deploying** **EVM Contracts at Existing Addresses**


In an EVM environment, when a contract creation opcode <mark>(</mark> <mark>`create`</mark> or <mark>`create2`</mark> <mark>)</mark> is executed,

the caller’s nonce <u>[should be incremented](https://github.com/ethereum/execution-specs/blob/1adcc1bfe774798bcacc685aebc17bd9935078c3/src/ethereum/cancun/vm/instructions/system.py#L106-L109)</u> - even if the contract cannot be deployed due to the

target address already having associated code or nonce — if other checks are satisfied.


In the current implementation of the EVM emulator, when a <mark>`create*`</mark> opcode is triggered and

the <u><mark>`[_executeCreate](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1007)`</mark></u> <u>function</u> calls <u><mark>`[precreateEvmAccountFromEmulator](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L223)`</mark></u> <mark>,</mark> the nonce is

temporarily incremented. If the subsequent <u>[nonce and code hash checks](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L244-L246)</u> fail, the call reverts,

rolling back the nonce increment. However, the callers frame execution continues, leaving the

caller account’s nonce unchanged, which differs from the standard EVM behavior. The same

applies to the <u><mark>`[create2EVM](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L205)`</mark></u> <u>function</u> of the <mark>`ContractDeployer`</mark> <mark>.</mark> If the constructor reverts

during deployment, the deployment nonce will remain unchanged, allowing the contract to be

deployed at the same address in the future.


Consider aligning the emulator’s behavior with the standard EVM by ensuring that the caller’s

nonce is incremented regardless of whether the target address already has associated code or

nonce.


EVM Equivalence Audit − Medium Severity − 16


**_Update:_** _[Resolved in pull request #1127](https://github.com/matter-labs/era-contracts/pull/1127)_ _[at commit ef80122. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/commit/ef8012290f0b04665edd002116e5443d33c0f247)_


_We changed the creation flow to match EVM._

### **M-10 EVM-to-EVM Contract Interaction Allows** **for Gas Griefing Attacks**


The EVM charges gas for executing operations, ensuring that transactions consume resources

proportionally to their complexity. When emulating these calls, a <u>[conversion](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L172-L176)</u> between native

gas units (ergs) and EVM gas is applied. The emulator aims to follow the EVM's behavior

closely, accounting for gas according to the EVM specification.


However, the EVM call may consume more ergs than the corresponding amount of EVM gas,

which is used to track execution costs at the EVM level. While the emulator aligns EVM gas

charges with the EVM's rules, underlying operations such as loading bytecode or running the

emulator itself also consume ergs that are not reflected in the EVM gas usage. This

discrepancy allows a caller to force a callee to spend more ergs than intended, creating a

situation where gas griefing attacks are possible. As a result, contracts cannot accurately

control or limit the total resources consumed during EVM-to-EVM calls, leading to potential

DoS, when the nested call aborts the EVM environment.


Consider keeping closer track of the actual ergs consumed compared to the EVM gas left

during EVM-to-EVM calls so that gas griefing attacks are controllable. For example, consider

calculating the actual ergs spent during an EVM call and adjust the EVM gas accordingly.

Another possible solution is to also limit the ergs passed to an EVM callee frame in accordance

to the call's gas limit.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_The current implementation guarantees compliance with EVM gas rules, the violation of_

_which can cause problems and create potential attack vectors. Additionally, passing the_

_entire native gas to the callee frame helps smooth out the discrepancy between EVM_

_and native gas. Since the entire EVM environment reverts in the event of an out-of-gas_

_error, gas estimation will, in most cases, return the amount of native gas required for the_

_transaction to execute correctly. At the same time, it's true that the current_

_implementation can break assumptions related to the_ _<mark>`try-catch`</mark>_ _pattern, particularly_

_if a fixed gas value is passed to the call. This should be clearly documented and_

_communicated to developers. For most use cases, the current design is the best_

_available option. Further optimizations of the emulator may reduce gas consumption and_

_simplify interactions with the EVM environment._


EVM Equivalence Audit − Medium Severity − 17


## **Low Severity**

### **L-01 Loose Stack Overflow Check**

In the <mark>`EvmEmulatorFunctions`</mark> template, the <u><mark>`[pushStackItem](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L454)`</mark></u> function pushes a new item

[into the stack. Prior to pushing the new item, it is ensured that the stack has not overflown](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L454) by

checking whether the current stack pointer is lower than the <mark>`BYTECODE_LEN_OFFSET`</mark> <mark>.</mark>


However, consider the case where the current stack pointer is pointing to the slot right before

the <mark>`BYTECODE_LEN_OFFSET`</mark> slot. Then, when calling <mark>`pushStackItem`</mark> <mark>,</mark> the aforementioned

overflow check will pass, thus allowing the new item to be inserted and the incremented stack

pointer to point to the <mark>`BYTECODE_LEN_OFFSET`</mark> slot. Even if, as per the current design, the

stack's head is not actually stored in the memory and so the <mark>`BYTECODE_LEN_OFFSET`</mark> is not

overwritten by this operation, the stack's head is typically out of the stack's space. A similar

check with the same impact is performed within the <u><mark>`[pushStackCheck](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L476)`</mark></u> function, with the

difference being that more than one new items are involved.


Consider making the stack overflow check stricter in both <mark>`pushStackItem`</mark> and

<mark>`pushStackCheck`</mark> functions. This is so that a new item is only allowed to be placed onto the

stack if there is available stack space for it.


**_Update:_** _[Resolved in pull request #1085](https://github.com/matter-labs/era-contracts/pull/1085)_ _[at commit 5db2a30. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/commit/5db2a306c2e8fbbb104fe09881e585ce5439d61b)_


_A stricter check has been implemented._

### **L-02 Reverting with Misleading Error in** **`EvmGasManager`**


In the <u><mark>`[$llvm_AlwaysInline_llvm$_onlyEvmSystemCall](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmGasManager.yul#L73-L77)`</mark></u> <u>function</u> of the

<mark>`EvmGasManager`</mark> contract, the <mark>`isSystemCall`</mark> flag determines whether the function is being

invoked as a system call. When this flag is set to 0, indicating that it is not a system call, the

contract reverts with the <mark>`CallerMustBeEvmContract`</mark> error. However, the expected

behavior is to revert with the <mark>`SystemCallFlagRequired`</mark> error, as implemented in <u>[other](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/abstract/SystemContractBase.sol#L23)</u>

<u>[contracts. This discrepancy could lead to confusion during debugging or when integrating with](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/abstract/SystemContractBase.sol#L23)</u>

the contract, as the error message does not align with the root cause of the failure.


Consider reverting with the <mark>`SystemCallFlagRequired`</mark> error to ensure clarity and

consistency across the codebase.


EVM Equivalence Audit − Low Severity − 18


**_Update:_** _[Resolved in pull request #1166](https://github.com/matter-labs/era-contracts/pull/1166)_ _[at commit 8349c91.](https://github.com/matter-labs/era-contracts/commit/8349c91f2ccf106900bf7ca5e8b7a2d36ca79db7)_

### **L-03 INVALID Opcode Behavior Divergence in** **EraVM<>EVM Interaction**


When the <u><mark>`[Invalid](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L1493)`</mark></u> <u>opcode</u> is executed in the EVM Emulator, it triggers the <u><mark>`[revertWithGas](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L149-L152)`</mark></u>

<u>[function, which stores the remaining gas value (0 in the case of an invalid opcode) in memory](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L149-L152)</u>

and reverts with a 32-byte value indicating the remaining gas. This behavior aligns with the

EVM<>EVM interaction, where the gas consumed by the <mark>`Invalid`</mark> opcode is burned and 0 is

returned as remaining gas. However, for EraVM<>EVM interactions, the behavior diverges. The

<u><mark>`[Invalid](https://docs.zksync.io/zk-stack/components/compiler/specification/instructions/evm/return#invalid)`</mark></u> <u>[opcode in EraVM](https://docs.zksync.io/zk-stack/components/compiler/specification/instructions/evm/return#invalid)</u> must mimic the behavior of <mark>`revert(0,0)`</mark> <mark>,</mark> but the emulator

produces <mark>`revert(0,32)`</mark> instead, exhibiting an inconsistency.


Consider maintaining consistency in opcode behavior across emulated environments during

cross-VM interactions. Alternatively, consider documenting the specific differences in behavior

for improved clarity.


**_Update:_** _[Resolved in pull request #1180](https://github.com/matter-labs/era-contracts/pull/1180)_ _[at commits 0397674, d8b49e5.](https://github.com/matter-labs/era-contracts/commit/0397674681f89c910dcc2f03e34d8bbfa4a316fb)_

### **L-04 Absence of EVM Contract Force** **Deployment Logic**


The <u><mark>`[forceDeployOnAddress](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L322)`</mark></u> <u>function</u> of the <mark>`ContractDeployer`</mark> contract enables the

forced deployment of contracts. However, it may not align with the construction of EVM-type

contracts. In typical contract deployment scenarios, different initialization procedures are

required based on the contract type, and EVM contracts rely on the

<mark>`_constructEVMContract`</mark> function instead of the <u><mark>`[_constructContract](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L516)`</mark></u> function used in

this context.


Consider updating the <mark>`forceDeployOnAddress`</mark> function to check for the contract type and

invoke the appropriate construction function.


**_Update:_** _[Resolved in pull request #1179](https://github.com/matter-labs/era-contracts/pull/1179)_ _[at commits 3f76fcc, 0f87cf9](https://github.com/matter-labs/era-contracts/pull/1179/commits/3f76fcc6c89753757d84a72049ec160029b5a0d2)_ _[and pull request #1196](https://github.com/matter-labs/era-contracts/pull/1196)_ _at_

_[commit 0d6fec7. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1196/commits/0d6fec79bbcd084a1ae70655fcf41535fdc2273f)_


_We added EVM force deployment functionality._


EVM Equivalence Audit − Low Severity − 19


### **L-05 Incorrect MAX_EVM_BYTECODE_LENGTH in** **Utils Library**

The maximum bytecode length for Ethereum contracts is 24,576 bytes, as defined by <u>[EIP-170.](https://eips.ethereum.org/EIPS/eip-170)</u>

Several components in the codebase rely on this length restriction for validation and

processing purposes.


In the current implementation, the <mark>`validateBytecodeAndChargeGas`</mark> function of the

<mark>`EVMEmulator`</mark> contract correctly enforces the <u>[24,576-byte](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L86)</u> limit as specified by EIP-170.

However, the <mark>`publishEVMBytecode`</mark> function of the <mark>`KnownCodesStorage`</mark> [contract calls](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/KnownCodesStorage.sol#L94)

the <u><mark>`[Utils.hashEVMBytecode](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/libraries/Utils.sol#L147)`</mark></u> <u>function, which references a</u> <mark>`MAX_EVM_BYTECODE_LENGTH`</mark>

constant that has been set to <mark>`(2 ** 16) - 1`</mark> (or 65,535). This inconsistency introduces a

mismatch between the actual EIP-170 constraint and the system's internal validation,

potentially leading to the deployment of the contract with a bigger length than allowed or with

invalid assumptions about related functionality.


Consider unifying the <mark>`MAX_EVM_BYTECODE_LENGTH`</mark> constant across the codebase to align

with the EIP-170 standard while keeping a small buffer for potential bytecode padding to

ensure consistent behavior.


**_Update:_** _[Resolved in pull request #1181. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1181)_


_This check is used to prevent overflow of 2 bytes used to encode published bytecode_

_length. Technically, it is allowed in EVM to have and call contracts bigger than 24,576_

_[bytes (example of corresponding test). In our current EVM emulator design, it is not](https://github.com/ethereum/tests/blob/develop/src/GeneralStateTestsFiller/stStaticCall/static_Call50000bytesContract50_1Filler.json)_

_possible to execute bytecodes exceeding max allowed length, so we added_

_corresponding check in the_ _<mark>`getDeployedBytecode`</mark>_ _function._

### **L-06 Incorrect Custom Error Revert in** **`EvmGasManager`**


The <u><mark>`[$llvm_AlwaysInline_llvm$_onlyEvmSystemCall](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmGasManager.yul#L69)`</mark></u> <u>function</u> of the

<mark>`EvmGasManager`</mark> contract is responsible for validating the current call. When certain

conditions are not met, the function reverts using <mark>`revert(0, 32)`</mark> <mark>.</mark> According to the

<u>[comments in the code, this revert is intended to represent the](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmGasManager.yul#L87-L89)</u>

<mark>`CallerMustBeEvmContract()`</mark> custom error. In the EVM, a revert triggered by a custom

error without arguments <u>[should produce](https://docs.soliditylang.org/en/v0.8.28/contracts.html#custom-errors)</u> an error payload of 4 bytes (the selector of the custom

error). However, the current implementation incorrectly reverts with 32 bytes.


EVM Equivalence Audit − Low Severity − 20


Consider modifying the revert logic to ensure that it reverts with only the 4-byte selector.


**_Update:_** _[Resolved in pull request #1166](https://github.com/matter-labs/era-contracts/pull/1166)_ _[at commit 8349c91.](https://github.com/matter-labs/era-contracts/commit/8349c91f2ccf106900bf7ca5e8b7a2d36ca79db7)_

### **L-07 EVM Emulator Uses call for isSlotWarm** **Function**


The <u><mark>`[isSlotWarm](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmGasManager.yul#L140-L158)`</mark></u> <u>function</u> of the <mark>`EvmGasManager`</mark> contract does not perform any state
modifying operations, such as <mark>`tstore`</mark> or <mark>`sstore`</mark> <mark>.</mark> This could logically classify it as a <mark>`view`</mark>

[function. However, the EVM Emulator employs a](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L513-L528) <u><mark>`[call](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L513-L528)`</mark></u> for this function, and the

[accompanying comment](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L517) incorrectly states that the <mark>`call`</mark> is necessary due to the use of the

<mark>`tstore`</mark> operation, which is not actually present in this function.


To increase protocol safety by preventing unintended state changes, consider replacing <mark>`call`</mark>

with <mark>`staticcall`</mark> for the <mark>`isSlotWarm`</mark> function.


**_Update:_** _[Resolved in pull request #1167](https://github.com/matter-labs/era-contracts/pull/1167)_ _[at commit f2677bf.](https://github.com/matter-labs/era-contracts/commit/f2677bf98a4e93d1ec5638c51294e08a7d19a73e)_

### **L-08 Behavior Divergence with EVM for Create*** **Opcodes**


According to the EVM specifications outlined in <u>[EIP-2929, during the execution of the Create/](https://eips.ethereum.org/EIPS/eip-2929)</u>

Create2 opcodes, the account being deployed must be warmed before performing checks and

[executing its initialization code, and it must stay warm](https://eips.ethereum.org/EIPS/eip-2929#storage-read-changes) afterward.


In the <u><mark>`[_executeCreate](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1007)`</mark></u> <u>function</u> of the <mark>`EvmEmulator`</mark> contract, if the

<u><mark>`[precreateEvmAccountFromEmulator](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1019-L1022)`</mark></u> <u>external call</u> [fails, the intended deployed account is](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1035)

<u>[never warmed. This diverges from EIP-2929, which mandates that the account be warmed](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1035)</u>

prior to any validation steps and remain so during and after the initialization code execution.

Similarly, during the creation of an EVM contract from the <u>[EraVM context, in the event of a](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/ContractDeployer.sol#L172)</u>

construction revert, the contract being constructed remains in a cold state. However, it <u>[was](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulator.template.yul#L83)</u>

<u>[warmed](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulator.template.yul#L83)</u> during the execution of EVM context and should remain warm.


In accordance with EIP-2929, consider warming the contract address before any validation

steps are performed.


**_Update:_** _Partially resolved in_ _<u>[pull request #1127](https://github.com/matter-labs/era-contracts/pull/1127/files)</u>_ _[at commit ef80122. The Matter Labs team](https://github.com/matter-labs/era-contracts/commit/ef8012290f0b04665edd002116e5443d33c0f247)_

_stated:_


EVM Equivalence Audit − Low Severity − 21


_Contract creation flow from the EVM emulator was changed to match EVM. Regarding_

_the creation of a EVM contract from the EraVM context, at the moment we do not plan_

_to make changes._

### **L-09 Unexpected Balance Increase for EVM** **Contracts Without Fallback/Receive Functions**


On Ethereum, there are scenarios where a contract’s balance can increase without triggering

its code, such as through <mark>`selfdestruct`</mark> or validator withdrawals using <u>[Eth1 withdrawal](https://eth2book.info/capella/part2/deposits-withdrawals/withdrawal-processing/#eth1-withdrawal-credentials)</u>

<u>[credentials. On ZKsync,](https://eth2book.info/capella/part2/deposits-withdrawals/withdrawal-processing/#eth1-withdrawal-credentials)</u> <mark>`selfdestruct`</mark> cannot be executed. However, an operator-specified

address can still receive funds directly—without invoking contract code—using the

<u><mark>`[directETHTransfer](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/bootloader/bootloader.yul#L1676)`</mark></u> <u>function</u> in the <mark>`Bootloader`</mark> <mark>,</mark> consistent with Ethereum’s behavior.


Another possibility is when a paymaster sends excess funds and receives some portion back

as a refund on the <u>[ensure payment](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/bootloader/bootloader.yul#L790-L793)</u> step, or receives a <u>[refund for an L2 transaction. If the](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/bootloader/bootloader.yul#L1669)</u>

paymaster is an EVM contract, its balance can increase without code execution, potentially

causing discrepancies in internal paymaster balance accounting.


Consider maintaining consistency with EVM or informing users about unexpected balance

increases, ensuring that users do not rely on code execution to detect changes in the

contract’s balance.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_This behavior should be reflected in the documentation._

### **L-10 Incorrect Gas Handling in delegatecall** **Implementation**


The EVM emulator implements the <u><mark>`[performDelegateCall](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L690)`</mark></u> <u>function, which allows one smart</u>

contract to execute code from another contract while maintaining the original contract's

storage.


The EVM emulator prematurely <u>[charges](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L705-L713)</u> gas for memory expansion and account access during

a <mark>`delegatecall`</mark> <mark>,</mark> without first verifying whether the target account type. This results in gas

charges even if the delegatecall <u>[does not proceed](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L716-L718)</u> due to the target being non-EVM.


Consider verifying the target account type before executing charging operations.


EVM Equivalence Audit − Low Severity − 22


**_Update:_** _[Resolved in pull request #1120](https://github.com/matter-labs/era-contracts/pull/1120/files)_ _[at commit 3299faa, pull request #1196](https://github.com/matter-labs/era-contracts/commit/3299faa649f389b6f3b9855b573e2654206f6c10)_ _at commit_

_<u>[0e0a7ac. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1196/commits/0e0a7ac244cafc4e76b9fccafe94efb1ced1c0cc)</u>_


_Delegatecall flow has been changed to better match EVM. Now delegatecalling the_

_EraVM contract looks to the user just like calling a contract that immediately reverts._

## **Notes & Additional** **Information**

### **N-01 Hardcoded Memory Offsets**


Memory slots 23-31 are reserved for cached fixed context values, such as

<mark>`block.timestamp`</mark> or the gas limit of the transaction. The offsets for each of the values are

<u>[hardcoded, which can be error-prone.](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L29-L62)</u>


In order to enforce consistency and avoid mistakes, consider chaining the offsets one after

another, as is done afterwards for subsequent sections in the memory layout.


**_Update:_** _[Resolved in pull request #1168](https://github.com/matter-labs/era-contracts/pull/1168)_ _[at commit 34918c3.](https://github.com/matter-labs/era-contracts/commit/34918c3163306b3f927be500622d25ccbc839e1e)_

### **N-02 Naming Suggestions**


In the <u><mark>`[EvmEmulatorFunctions](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul)`</mark></u> template, multiple opportunities for improved naming were

identified:













The return variable of the <u><mark>`[expandMemory2](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L213)`</mark></u> function is named after "maxExpand",

whereas the function returns the <u>[gas cost](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L182)</u> for the memory expansion.

The parameters of the <u><mark>`[checkMemIsAccessible](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L223)`</mark></u> function are named <mark>`index`</mark> and

<mark>`offset`</mark> <mark>,</mark> whereas all the call sites <u>[provide](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L286)</u> arguments named "offset" and "size",

respectively.

The <u><mark>`[UINT32_MAX](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L133)`</mark></u> function could be renamed to <mark>`MAX_UINT32`</mark> for consistency with the

rest of the code in the contract.

There is a typographical error in the <mark>`publishEvmBytecode`</mark> function of the

<mark>`KnownCodesStorage`</mark> [contract. The"vesionedBytecodeHash"](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/KnownCodesStorage.sol#L94) local variable should be

named "versionedBytecodeHash".


EVM Equivalence Audit − Notes & Additional Information − 23


Consider renaming the variables mentioned above for improved readability and clarity.


**_Update:_** _[Resolved in pull request #1169](https://github.com/matter-labs/era-contracts/pull/1169)_ _[at commit 7328b8c](https://github.com/matter-labs/era-contracts/commit/7328b8cfb5843ff364d68b22c5fd787f5f2538b6)_ _[and in pull request #1082](https://github.com/matter-labs/era-contracts/pull/1082)_ _at_

_[commit 8e8323d.](https://github.com/matter-labs/era-contracts/commit/8e8323de73e15d1c88a0b90d008a7c13528c4a29)_

### **N-03 Misleading Documentation**


Throughout the codebase, multiple instances of misleading documentation were identified:


In the <mark>`EvmEmulatorFunctions`</mark> template:









[In line 345, there is a factual mistake: "bits" should be "bytes". The comment should also](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L345)

clearly state that it is referring to the first 32 bytes _of the_ _<mark>`returndata`</mark>_ <mark>.</mark>


[In line 932, the comment suggests that all the returndata is skipped, whereas only the](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L932)

initial 32 bytes of the returned gas value are skipped.



Consider addressing the above instances of misleading documentation to improve the

readability of the codebase.


**_Update:_** _[Resolved in pull request #1170](https://github.com/matter-labs/era-contracts/pull/1170)_ _[at commit ba441ac.](https://github.com/matter-labs/era-contracts/commit/ba441accca5538799437a62dea0ca5b0161a8cc5)_

### **N-04 Gas Optimizations**


Throughout the codebase, multiple opportunities for gas optimization were identified:









There are several instances where a value is divided with a divisor raised to a power of 2

using the <mark>`div`</mark> opcode. Consider using the cheaper <mark>`shr`</mark> instead. For example,

<u><mark>`[div(value, 512)](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L196-L202)`</mark></u> could be <mark>`shr(9, value)`</mark> <mark>.</mark>

The implementation of the <mark>`CODECOPY`</mark> [opcode checks](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L410-L417) for out-of-bounds bytecode

access by comparing <mark>`sourceOffset`</mark> with <mark>`MEM_LEN_OFFSET`</mark> <mark>.</mark> Consider using the

ending slot of the stored bytecode to improve code clarity and save gas costs by using

the more efficient <u><mark>`[$llvm_AlwaysInline_llvm$_memsetToZero](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1143)`</mark></u> function for as

many bytes as possible instead of the costlier <u><mark>`[$llvm_AlwaysInline_llvm$_memcpy](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1127)`</mark></u>

function.



Consider adopting the above suggestions for optimized gas costs.


**_Update:_** _[Resolved in pull request #1171](https://github.com/matter-labs/era-contracts/pull/1171)_ _[at commits dbfa843, 3f5866d](https://github.com/matter-labs/era-contracts/commit/dbfa8431b28ad4d2fb4ee5539e63eaf68162267e)_ _[and pull request #1156](https://github.com/matter-labs/era-contracts/pull/1156)_

_[at commits c621387, 624bf1c.](https://github.com/matter-labs/era-contracts/commit/c6213875906001f0880618fb2d409c9fc1a4a19d)_


EVM Equivalence Audit − Notes & Additional Information − 24


### **N-05 Code Simplification**

Throughout the codebase, multiple opportunities for code simplification were identified:


<mark>`EvmEmulatorLoop.yul`</mark> <mark>:</mark>









The <u><mark>`[OP_PC](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L794-L795)`</mark></u> opcode implementation calculates the current program counter (pc) in

relation to <mark>`BYTECODE_OFFSET`</mark> <mark>.</mark> However, instead of immediately subtracting

<mark>`BYTECODE_OFFSET`</mark> from <mark>`ip`</mark> <mark>,</mark> <mark>`BYTECODE_LEN_OFFSET + 32`</mark> is used which equals

<mark>`BYTECODE_OFFSET`</mark> <mark>.</mark> Consider simplifying the code by using the <mark>`BYTECODE_OFFSET`</mark>

value.

All the <u>[instances of](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L866-L1152)</u> <u><mark>`[PUSHX](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L866-L1152)`</mark></u> have similar content. The code only differentiates in the X

value, which is the size of bytes to read from the bytecode and increase the <mark>`ip`</mark> with.

The content could be refactored into an <mark>`internal`</mark> function to avoid having the same

number duplicated and charging the same amount of gas.



<mark>`Executor.sol`</mark> <mark>:</mark>







In the <u><mark>`[batchMetaParameters](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L601)`</mark></u> function, the <mark>`s.l2DefaultAccountBytecodeHash`</mark>

and <mark>`s.l2EvmEmulatorBytecodeHash`</mark> state variables can be directly passed in the

encoding instead of unnecessarily assigning them to local variables first.



<mark>`Constants.sol`</mark> <mark>:</mark>







Consider listing the system contracts in an ordered way based on their address with

regard to <mark>`SYSTEM_CONTRACTS_OFFSET`</mark> for clarity. Specifically,

<u><mark>`[CODE_ORACLE_SYSTEM_CONTRACT](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/Constants.sol#L38)`</mark></u> and <u><mark>`[EVM_GAS_MANAGER](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/Constants.sol#L87)`</mark></u> should be listed after

<u><mark>`[PUBDATA_CHUNK_PUBLISHER](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/Constants.sol#L90)`</mark></u> <mark>.</mark>



Consider simplifying the code as suggested above in order to improve the overall readability

and clarity of the codebase.


**_Update:_** _[Resolved in pull request #1174](https://github.com/matter-labs/era-contracts/pull/1174)_ _[at commits 461e9c1, 405eff1, f3de6b3.](https://github.com/matter-labs/era-contracts/pull/1174/commits/461e9c125c2bfe656b1d937508deaab04d05a8b9)_

### **N-06 Unused Functions**


Having unused functions in the codebase can negatively affect code clarity and maintainability.

The <u><mark>`[MSG_VALUE_SIMULATOR_STIPEND_GAS](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L124)`</mark></u> <u>function</u> is not invoked anywhere in the

codebase, making its purpose unclear. Similarly, the <u><mark>`[pushStackItemWithoutCheck](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L470-L474)`</mark></u> and

<u><mark>`[pushStackCheck](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L482-L486)`</mark></u> functions are also never used.


EVM Equivalence Audit − Notes & Additional Information − 25


Consider removing any unused functions from the production code to improve code readability

and maintainability. Alternatively, if such functions serve a specific purpose, ensure that they

are used appropriately.


**_Update:_** _[Resolved in pull request #1172](https://github.com/matter-labs/era-contracts/pull/1172)_ _[and in pull request #1085](https://github.com/matter-labs/era-contracts/pull/1085)_ _[at commit 5db2a30.](https://github.com/matter-labs/era-contracts/commit/5db2a306c2e8fbbb104fe09881e585ce5439d61b)_

### **N-07 Redundant Logic in** **`_constructEVMContract`**


The <u><mark>`[_constructEVMContract](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L567)`</mark></u> <u>function</u> of the <mark>`ContractDeployer`</mark> contract includes a

call to the <u><mark>`[_storeConstructingByteCodeHashOnAddress](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L579-L583)`</mark></u> <u>function</u> using a dummy

bytecode hash. In this process, the <mark>`isConstructing`</mark> bit is already set to <mark>`true`</mark> in the

provided value. However, <u><mark>`[_storeConstructingByteCodeHashOnAddress](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L504)`</mark></u> <u>clears</u> the

<mark>`isConstructing`</mark> bit, sets it back again, and subsequently invokes the

<mark>`storeAccountConstructingCodeHash`</mark> function. This sequence involves unnecessary

steps, as bit manipulation is redundant when the <mark>`isConstructing`</mark> bit is already pre-set.


Consider calling the <mark>`storeAccountConstructingCodeHash`</mark> function directly with the

dummy bytecode hash. This avoids the redundant clearing and resetting of the

<mark>`isConstructing`</mark> bit, thereby streamlining the logic and reducing gas usage.


**_Update:_** _[Resolved in pull request #1173](https://github.com/matter-labs/era-contracts/pull/1173)_ _[at commit 5261075.](https://github.com/matter-labs/era-contracts/pull/1173/commits/5261075fd6e4ace745bbd002df427d5461878895)_

### **N-08 Repetitive Logic During EVM-to-EVM** **Contract Creation**


When an EVM contract deploys another EVM contract, the

<u><mark>`[precreateEvmAccountFromEmulator](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L223)`</mark></u> <u>function</u> is invoked. This function ensures that it is

allowed to deploy EVM contracts and that a contract with the same address has not been

deployed previously. Subsequently, the EVM emulator <u>calls</u> <u><mark>`[createEvmFromEmulator](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L256)`</mark></u> <mark>,</mark>

repeating <u>[the same checks, which consumes additional gas and unnecessarily increases the](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/ContractDeployer.sol#L433-L435)</u>

bytecode size of the <mark>`ContractDeployer`</mark> contract.


Consider streamlining the EVM-to-EVM contract deployment process to eliminate repeated

logic and reduce unnecessary gas usage.


**_Update:_** _[Resolved in pull request #1127](https://github.com/matter-labs/era-contracts/pull/1127)_ _[at commit 215aa6d.](https://github.com/matter-labs/era-contracts/commit/215aa6df76ce8e57a55690935952ae21cba67337)_


EVM Equivalence Audit − Notes & Additional Information − 26


### **N-09 Magic Numbers**

Throughout the codebase, multiple instances of magic numbers were identified:











In <u><mark>`[Utils.sol](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/libraries/Utils.sol#L182)`</mark></u> <mark>,</mark> the <mark>`0xff`</mark> number is used instead of the <u><mark>`[CREATE2_EVM_PREFIX](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/Constants.sol#L109)`</mark></u>

constant which is defined in <mark>`Constants.sol`</mark> but remains unused.

In the <u><mark>`[hashL2Bytecode](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/libraries/Utils.sol#L102)`</mark></u> function of <mark>`Utils.sol`</mark> <mark>,</mark> the upper length limit of an EraVm

bytecode is <u>[hardcoded, whereas the](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/libraries/Utils.sol#L113)</u> <u><mark>`[MAX_EVM_BYTECODE_LENGTH](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/libraries/Utils.sol#L138)`</mark></u> constant could be

used instead.

In <mark>`EvmEmulatorFunctions.template.yul`</mark> <mark>,</mark> [the 160-bit address mask](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L504) is used

multiple times. Consider making it a constant for improved clarity.



Consider using constant variables instead of magic numbers throughout the codebase for

enhanced clarity and readability.


**_Update:_** _[Resolved in pull request #1175](https://github.com/matter-labs/era-contracts/pull/1175)_ _[at commits c712ced, 4c73482](https://github.com/matter-labs/era-contracts/commit/c712cede4d872d948e049978c81164219443cac8)_ _[and 4b1fc30.](https://github.com/matter-labs/era-contracts/commit/4b1fc30990caf15b0b94c2311f38a572b2e345c7)_

### **N-10 Missing Documentation**


Throughout the codebase, multiple instances of missing documentation were identified:











In <mark>`EvmEmulatorFunctions.template.yul`</mark> <mark>,</mark> there is an <u>[empty memory slot](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L65-L70)</u> between

<mark>`LAST_RETURNDATA_SIZE_OFFSET`</mark> and <mark>`STACK_OFFSET`</mark> <mark>.</mark> Consider documenting that

the empty slot is used to denote an empty stack.

In <mark>`EvmGasManager.yul`</mark> <mark>,</mark> the

<u><mark>`[$llvm_AlwaysInline_llvm$__getRawSenderCodeHash](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmGasManager.yul#L53)`</mark></u> function uses a low-level

call with a function selector. Consider documenting the corresponding function's name.

In <mark>`EvmEmulatorFunctions.template.yul`</mark> <mark>,</mark> the <u><mark>`[copyRest](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1116-L1152)`</mark></u> <u><mark>,</mark></u> <u><mark>`[memCpy](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1116-L1152)`</mark></u> <u>, and</u>

<u><mark>`[memsetToZero](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1116-L1152)`</mark></u> helper functions use plenty of bitwise operations for efficiency.

Consider providing documentation regarding the implementation logic of these functions.



For improved code clarity and maintainability, consider providing documentation for all parts of

the codebase where the implementation logic is not high-level or straightforward enough.


**_Update:_** _[Resolved in pull request #1176](https://github.com/matter-labs/era-contracts/pull/1176)_ _[at commits 1d8f871, 20f37ff](https://github.com/matter-labs/era-contracts/commit/1d8f871d3003df09e40faee7a2c53cf51ff50430)_ _[and e24895c.](https://github.com/matter-labs/era-contracts/commit/e24895ce90b68ac37fe9c125dfd828bde6a6153c)_


EVM Equivalence Audit − Notes & Additional Information − 27


### **N-11 prevrandao Opcode Implementation** **Inefficiency**

According to the <u>[ZKsync documentation, the](https://docs.zksync.io/zksync-protocol/differences/evm-instructions#difficulty-prevrandao)</u> <mark>`prevrandao`</mark> value on the ZKsync network is

constant and set to <mark>`2500000000000000`</mark> <mark>.</mark> However, the <u>[current implementation](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L587-L595)</u> of the EVM

Emulator performs several additional operations to retrieve this value from the

<mark>`SystemContext`</mark> contract and then caches it in memory.


Consider pushing the constant value directly to the stack instead of making an external call to

the <u><mark>`[SystemContext](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/SystemContext.sol#L49)`</mark></u> <u>contract, provided there is no plan to introduce a configurable value for</u>

<mark>`prevrandao`</mark> <mark>.</mark> This would reduce the computational overhead and save ergs for users using

the EVM emulator.


**_Update:_** _[Resolved in pull request #1178](https://github.com/matter-labs/era-contracts/pull/1178)_ _[at commit 7f6e3f1.](https://github.com/matter-labs/era-contracts/commit/7f6e3f124338173dd37d9b54b6fa53d688d58092)_

### **N-12 Redundant Warming of EVM Account During** **Construction**


In the <mark>`EVMEmulator`</mark> contract, the account being constructed is explicitly warmed at the start

of the constructor execution using the <u><mark>`[$llvm_AlwaysInline_llvm$_warmAddress](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulator.template.yul#L83)`</mark></u>

<u>[function. However, this warming is unnecessary, as the account is warmed by other segments](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulator.template.yul#L83)</u>

of the code depending on the deployment context.


For deployment in the EraVM context, the <mark>`consumeEvmFrame`</mark> function is called after the

direct warming of the account, which also <u>[warms the caller](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/contracts/EvmGasManager.yul#L230)</u> (the constructed account in this

scenario). Similarly, for deployment in the EVM context, the

<mark>`$llvm_AlwaysInline_llvm$_warmAddress`</mark> function is invoked in the

<u><mark>`[_executeCreate](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L1035)`</mark></u> <u>function</u> before the deployment occurs. Thus, in all cases, the explicit

warming of the constructed account within the constructor is redundant.


Consider removing the redundant warming logic to avoid unnecessary duplication.


**_Update:_** _[Resolved in pull request #1177](https://github.com/matter-labs/era-contracts/pull/1177)_ _[at commit 65e8375.](https://github.com/matter-labs/era-contracts/pull/1177/commits/65e83759e96a2eddc06586a39222543a8b7b6819)_

### **N-13 Free Deployment Of Evm Contract**


It is possible to invoke the ContractDeployer's <mark>`createEVM`</mark> and <mark>`create2EVM`</mark> functions and

deploy contracts while consuming zero EVM gas.


EVM Equivalence Audit − Notes & Additional Information − 28


This may happen if the deployer provides any deployment code that begins with the <mark>`STOP`</mark>

[opcode, which consumes 0 gas. Furthermore, the caller can specify an erg amount for the call](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorLoop.template.yul#L15)

[that is less than the required overhead. This bypasses the](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L173) <u>[deployment checks](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulator.template.yul#L10-L22)</u> and allows the

contract deployment to proceed without consuming any EVM gas.


Consider reverting the execution frame in case the ergs passed for a contract construction call

is less than the required <u>[overhead of 2000 ergs, if this is intended to be an invariant for the](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L128)</u>

system.


**_Update:_** _Partially resolved in_ _<u>[pull request #1196](https://github.com/matter-labs/era-contracts/pull/1196)</u>_ _[at commit bbfd8e7. The Matter Labs team](https://github.com/matter-labs/era-contracts/pull/1196/commits/bbfd8e79ad52be67f9f08b8c312bdc3ab9d5eac4)_

_stated:_


_Now we charge 32,000 gas if EVM contract is created by EOA or EraVM contract. This_

_additional cost corresponds to the EVM behavior._

### **N-14 Stipend Value is Added Twice to the Call's** **Gas**


In the CALL implementation of the EVM Emulator, if the value is greater than zero, a stipend of

<u>[2300 EVM gas is applied. However, the same amount of native gas (ergs) is also added in the](https://github.com/matter-labs/era-contracts/blob/397092db593baa5003ec77ad420c50104bc02fe2/system-contracts/evm-emulator/EvmEmulatorFunctions.template.yul#L628-L630)</u>

<u>[MsgValueSimulator](https://github.com/matter-labs/era-contracts/blob/ed6f4d1f8fcde854e084cd1d237fd80698f2da19/system-contracts/contracts/MsgValueSimulator.sol#L79)</u> to the gas amount as stipend.


Consider verifying that the observed behavior aligns with the expected protocol behaviour. If it

does not, ensure proper gas accounting by adjusting or removing one of the gas stipends

accordingly.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_This is expected behavior._


EVM Equivalence Audit − Notes & Additional Information − 29


## **Conclusion**

The Evm Emulator contract has been introduced to the ZKsync network to support the

interpreted execution of EVM bytecode on top of EraVM. The emulator is designed to follow

the EVM execution environment rules as closely as possible. Perfect equivalence cannot be

achieved, since the actual execution environment is EraVM. However, EVM contracts should be

able to be deployed and executed with a seamless experience. The current implementation

follows the specification after the Cancun fork. To support the changes of any subsequent

upgrade forks, the emulator's code should be refactored.


The report highlights a number of issues, primarily concerning the functional correctness of

EVM bytecode execution, equivalence with the EVM specification, and opportunities to

improve code clarity and readability. Since the audited codebase operates at a very low level of

contract execution, further in-depth testing is highly advised.


The Matter Labs team provided us with documentation regarding the EVM emulator design and

has been very responsive throughout the audit duration.


EVM Equivalence Audit − Conclusion − 30


