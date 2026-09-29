### | security

# **ZKsync Era-** **contracts** **Precompile Audit**

#### **April 1, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Security Model and Trust Assumptions _______________________________________________  6


Medium Severity ___________________________________________________________________  7

M-01 Return Length of ‘EcPairing’ Does Not Match the Specifications 7


Low Severity ______________________________________________________________________  7

L-01 Hardcoded Modular Length Value in Return Statement 7


Notes & Additional Information ______________________________________________________  8

N-01 Gas Optimization 8

N-02 Missing or Misleading Documentation 8

N-03 Modexp Lacks an SPDX License Identifier 9


Recommendations _________________________________________________________________  9

Differential Fuzzing 9


Conclusion ______________________________________________________________________ 10


ZKsync Era-contracts Precompile Audit − Table of Contents − 2


## **Summary**

**Type** Precompile


**Timeline** From 2025-03-03
To 2025-03-11


**Languages** Yul, Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



**Total Issues** 5 (5 resolved)



**Low Severity Issues** 1 (1 resolved)



**Notes & Additional**
**Information**



3 (3 resolved)



ZKsync Era-contracts Precompile Audit − Summary − 3


## **Scope**

We audited the <u>[pull request #1259](https://github.com/matter-labs/era-contracts/pull/1259)</u> [of the matter-labs/era-contracts](https://github.com/matter-labs/era-contracts) repository at commit

<u>[886018a.](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/)</u>


In scope were the following files:

```
system-contracts
└── contracts
├── Constants.sol
└── precompiles
├── EcAdd.yul
├── EcMul.yul
├── EcPairing.yul
└── Modexp.yul

```

The audited precompiles are system contracts run by the ZKsync VM and only deal with

parsing the input parameters. The actual operations (see the "System Overview" section) are

executed in a separate part of the execution layer that is written in Rust and is part of the VM

itself. These components are out of scope and will be audited as part of a future audit.


ZKsync Era-contracts Precompile Audit − Scope − 4


## **System Overview**

The four Yul files listed in the "Scope" section implement system contracts within the ZKsync

VM that process the inputs and outputs for the following four operations: elliptic curve (EC)

point addition ( <mark>`EcAdd.yul`</mark> <mark>)</mark>, EC scalar multiplication ( <mark>`EcMul.yul`</mark> <mark>)</mark>, EC pairing

( <mark>`EcPairing.yul`</mark> <mark>)</mark>, and modular exponentiation ( <mark>`Modexp.yul`</mark> <mark>)</mark> . These contracts are

structured similarly and the main logic concerns the extraction of the respective inputs from the

calldata, storing them in the correct format in memory, and passing them as input to the

<mark>`precompileCall`</mark> function. This function executes a generic opcode instruction in the VM

that executes a precompile <mark>(</mark> <mark>`ECAdd`</mark> <mark>,</mark> <mark>`ECMul`</mark> <mark>,</mark> <mark>`ECPairing`</mark> <mark>,</mark> <mark>`Modexp`</mark> <mark>,</mark> among others) that is

determined based on the calling contract.


Internally, <mark>`precompileCall`</mark> calls the <mark>`verbatim_2i_1o`</mark> function, which is intercepted by

the VM to route the call to the execution layer. Specifically, the <u><mark>`[execute_precompile](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/mod.rs#L50)`</mark></u>

<u>[function](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/mod.rs#L50)</u> from the <mark>`zksync-protocol`</mark> codebase (out of scope as stated above) is called,

matching the call with its respective precompile implementation. Consequently,

<mark>`ecadd_function`</mark> <mark>,</mark> <mark>`ecmul_function`</mark> <mark>,</mark> <mark>`ecpairing_function`</mark> <mark>,</mark> or <mark>`modexp_function`</mark> is

triggered, respectively, performing the given operation and storing the result in memory. The

result is then read back in the corresponding Yul contract.


The changes to the <mark>`Constants.sol`</mark> file concern the addition of the address of the <mark>`Modexp`</mark>

system contract and the modification of some constants such as the number of blobs

supported when submitting data to the L1.


Below, we provide details regarding the four operations mentioned above, along with their

respective inputs and outputs as processed by the Yul contracts:









<mark>`EcAdd`</mark> <mark>:</mark> Addition of two EC points with coordinates in affine representation <mark>`(x1,y1)`</mark>

and <mark>`(x2,y2)`</mark> (four inputs), producing as a result a third point <mark>`(x3,y3)`</mark> (two outputs).

<mark>`EcMul`</mark> <mark>:</mark> Multiplication of an EC point <mark>`P = (x1,y1)`</mark> by a scalar `k` (three inputs),

producing as a result a third point <mark>`kP = (x2,y2)`</mark> (two outputs).




- <mark>`EcPairing`</mark> <mark>:</mark> Ate pairing check over the <mark>`alt_bn128`</mark> [curve following the EIP-197](https://eips.ethereum.org/EIPS/eip-197)
##### standard. In detail, the check verifies the equality e ( A 1, B 1) ∗ ⋯∗ e ( Ak, Bk ) = 1, where e : G 1 × G 2 ↦ GT is the bilinear pairing operation, G 1 and G 2 are the two source groups, GT is the target group, A 1, ⋯, Ak is a list of EC points in group k G 1 and B 1, ⋯, Bk is a list of EC points in group k G 2. The coordinates of each Ai point are elements of the field and so each Ai is defined with two field elements ( x, i y ) i . The



<mark>`EcPairing`</mark> <mark>:</mark> Ate pairing check over the <mark>`alt_bn128`</mark> [curve following the EIP-197](https://eips.ethereum.org/EIPS/eip-197)


##### standard. In detail, the check verifies the equality e ( A 1, B 1) ∗ ⋯∗ e ( Ak, Bk ) = 1,


##### where e : G 1 × G 2 ↦ GT is the bilinear pairing operation, G 1 and G 2 are the two source groups, GT is the target group, A 1, ⋯, Ak is a list of EC points in group k


##### and B 1, ⋯, Bk is a list of EC points in group k G 2. The coordinates of each Ai point are elements of the field and so each Ai is defined with two field elements ( x, i y ) i . The



ZKsync Era-contracts Precompile Audit − System Overview − 5


##### coordinates of each Bi point are elements of a quadratic extension of the field and so


##### coordinates of each Bi point are elements of a quadratic extension of the field and so each Bi is defined with four field elements ( xi 1, xi 2, yi 1, yi 2), where the two coordinates are represented with the pairs ( xi 1, xi 2) and ( yi 1, yi 2), respectively. For a single pairing ( k = 1), there are inputs representing the points 6 A and B together. In total, the contract takes 6 k field elements as input (representing the coordinates of all Ai and Bi


##### each Bi is defined with four field elements ( xi 1, xi 2, yi 1, yi 2), where the two coordinates


##### are represented with the pairs ( xi 1, xi 2) and ( yi 1, yi 2), respectively. For a single pairing


##### ( k = 1), there are inputs representing the points 6 A and B together. In total, the


##### contract takes 6 k field elements as input (representing the coordinates of all Ai and







points) and reads a single Boolean output, depending on whether the pairing equality

holds or not.

<mark>`Modexp`</mark> <mark>:</mark> Modular exponentiation operation <mark>`r = b^e mod m`</mark> with base `b`, exponent

`e`, and modulus `m` (three inputs), producing as a result a scalar `r` (one output).



As a final note, the reason for having dedicated contracts for the four operations listed above,

as opposed to re-using the existing EVM precompile implementations, is that the ZKsync VM

runs on an L2. The validity of its computation is proven by means of ZK proofs that are

submitted to the L1 for verification. This makes it necessary to have provable implementations

of all operations executed by the VM. That being said, the <mark>`EcAdd`</mark> <mark>,</mark> <mark>`EcMul`</mark> <mark>,</mark> <mark>`EcPairing`</mark>, and

<mark>`Modexp`</mark> contracts should be functionally as close as possible to their EVM precompile

counterparts ( <mark>`ecAdd`</mark> <mark>,</mark> <mark>`ecMul`</mark> <mark>,</mark> <mark>`ecPairing`</mark> <mark>,</mark> and <mark>`modexp`</mark> <mark>,</mark> respectively). Users should,

however, be aware of the following differences:










The gas cost of calling each precompile is different from its EVM counterpart.

The <mark>`Modexp`</mark> contract has a hardcoded limit on the lengths of the inputs (base,

exponent, and modulus) that is set to 32 bytes.

The gas paid for the execution of the <mark>`EcPairing`</mark> precompile is capped at <mark>`2^32 - 1`</mark> <mark>.</mark>


## **Security Model and Trust** **Assumptions**

During the audit, the following trust assumptions were made:









The gas costs for processing the four circuit precompiles accurately reflect the costs

incurred by the rollup's operators and nodes.

All four Yul contracts do not have a constructor, and it is assumed that these contracts

will be pre-deployed at the right addresses with the correct runtime bytecode.


ZKsync Era-contracts Precompile Audit − Security Model and Trust

Assumptions − 6


## **Medium Severity**

### **M-01 Return Length of ‘EcPairing’ Does Not** **Match the Specifications**

<u>[EIP-197](https://eips.ethereum.org/EIPS/eip-197)</u> introduces the <mark>`EcPairing`</mark> precompile on Ethereum and states that "The length of

the returned data is always exactly 32 bytes and encoded as a 32 byte big-endian number".

However, the <mark>`fallback`</mark> function of the <mark>`EcPairing`</mark> [contract returns 64 bytes.](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/EcPairing.yul#L122)


Consider returning only 32 bytes to avoid potential issues and more closely match the EVM's

specifications.


**_Update:_** _[Resolved in pull request #1373](https://github.com/matter-labs/era-contracts/pull/1373)_ _[at commit fab789f. The return value has been updated](https://github.com/matter-labs/era-contracts/commit/fab789ffd276411463a6aa4bdebfb74a072c84c2)_

_to 32 bytes._

## **Low Severity**

### **L-01 Hardcoded Modular Length Value in Return** **Statement**


The <mark>`modexp`</mark> precompile <u>[returns](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/Modexp.yul#L122)</u> the last <mark>`modLen`</mark> bytes of its first 32 bytes in memory.

However, "32" is hardcoded.


Consider replacing the hardcoded "32" with <mark>`MAX_MOD_BYTES_SUPPORTED()`</mark> to be

consistent with the rest of the code and avoid potential errors if these values are ever updated.


**_Update:_** _[Resolved in pull request #1370](https://github.com/matter-labs/era-contracts/pull/1370)_ _[at commit e29c2be.](https://github.com/matter-labs/era-contracts/commit/e29c2becf2572fa5e1498d7f691069d8ea9478f1)_


ZKsync Era-contracts Precompile Audit − Medium Severity − 7


## **Notes & Additional** **Information**

### **N-01 Gas Optimization**

Prior to any computation, the <mark>`ModExp`</mark> precompile <u>[cleans the first 3 words of memory.](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/Modexp.yul#L95-L98)</u>

However, this memory should already be initialized to zero by the EVM as the precompile is

only callable externally or by transactions.


Assuming that the above is also true on ZKsync, consider removing this check to save gas

when the precompile is called.


**_Update:_** _[Resolved in pull request #1369](https://github.com/matter-labs/era-contracts/pull/1369)_ _[at commit de48942.](https://github.com/matter-labs/era-contracts/commit/de4894240433dd10b4c1af7a08ea84b7fa573a34)_

### **N-02 Missing or Misleading Documentation**


Throughout the codebase, multiple instances where documentation could be improved were

identified:














[This comment](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/Modexp.yul#L119-L121) before the <mark>`return`</mark> statement of the <mark>`Modexp`</mark> precompile states that the

returned result is "assumed to be right-padded with zeros". However, the <mark>`sub(32,`</mark>

<mark>`modLen)`</mark> offset suggests that the value is left-padded/right-aligned.

The <u><mark>`[uint64_perPrecompileInterpreted](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/Modexp.yul#L48)`</mark></u> input to

<mark>`unsafePackPrecompileParams`</mark> [is left-aligned, in contrast to the other four input](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/Modexp.yul#L44-L47)

<u>[words. This is due to the](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/Modexp.yul#L44-L47)</u> <mark>`memoryPageToRead`</mark> and <mark>`memoryPageToWrite`</mark> arguments

being left as 0, which could be documented.

The gas costs for all four precompiles are computed with respect to a value <mark>`80_000`</mark>

[that is not documented: ECADD_GAS_COST, ECMUL_GAS_COST,](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/EcAdd.yul#L16)

<u>[ECPAIRING_PAIR_GAS_COST, MODEXP_GAS_COST.](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/EcPairing.yul#L22)</u>

[The distinction between EC pairing base](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/EcPairing.yul#L14) [and pair](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/EcPairing.yul#L21) gas cost is not clear.

There is a typo in the comment regarding the <u>[input length](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/EcPairing.yul#L101)</u> of the

<mark>`unsafePackPrecompileParams`</mark> call in <mark>`EcPairing.yul`</mark> <mark>:</mark> the second coordinate of

the first point should be <mark>`p_y`</mark> rather than <mark>`p_x`</mark> i.e., <mark>`(p_x, p_x, q_x_a, q_x_b,`</mark>

<mark>`q_y_a, q_y_b)`</mark> should be <mark>`(p_x, p_y, q_x_a, q_x_b, q_y_a, q_y_b)`</mark> <mark>.</mark>


ZKsync Era-contracts Precompile Audit − Notes & Additional Information − 8


Consider addressing the instances identified above to improve the readability and

maintainability of the codebase.


**_Update:_** _[Resolved in pull request #1371](https://github.com/matter-labs/era-contracts/pull/1371)_ _[at commits 3acee2f](https://github.com/matter-labs/era-contracts/commit/3acee2f862252d6a772d5e2dfc151b5a422e7d58)_ _[and 96d51e2.](https://github.com/matter-labs/era-contracts/commit/96d51e233928ad6cc83c9ea52b50c9a378ecf3eb)_

### **N-03 Modexp Lacks an SPDX License Identifier**


[The Modexp.yul](https://github.com/matter-labs/era-contracts/blob/886018aa81bc224b2721982ba9623e129b64b87c/system-contracts/contracts/precompiles/Modexp.yul#L1) file lacks an SPDX license identifier.


To be consistent with the other precompiles and follow <u>[best practices, consider adding an](https://docs.soliditylang.org/en/latest/layout-of-source-files.html#spdx-license-identifier)</u>

SPDX license identifier to <mark>`Modexp.yul`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #1372](https://github.com/matter-labs/era-contracts/pull/1372)_ _[at commit 553ea3a.](https://github.com/matter-labs/era-contracts/commit/553ea3a530ea99ed4dcac020c5e3109680e9ebba)_

## **Recommendations**

### **Differential Fuzzing**


It has been challenging to test the code comprehensively in an end-to-end manner due to its

use of a custom opcode called by a <mark>`verbatim`</mark> and its reliance on a node running the ZKsync

VM. As such, given the complexity of the implemented precompiles, we suggest differentially

fuzzing them against Ethereum's precompiles to identify and address any potential edge

cases.


ZKsync Era-contracts Precompile Audit − Recommendations − 9


## **Conclusion**

The changes under audit introduce precompiles for elliptic curve (EC) point addition, EC scalar

multiplication, EC pairing, and modular exponentiation as system contracts within the ZKsync

VM. The code in scope handles the parsing of the inputs from calldata and packs them in a

predefined format to be passed to the execution layer where the actual operation is performed.

As mentioned in the introduction, this last part is out of scope and will be part of a future audit.


The audit revealed no major issues. We identified a deviation from the specifications and

provided recommendations to improve the quality of the code. Overall, we found the

implementation to be sound and well-documented, though we recommend adding differential

tests against Ethereum's precompiles if possible. We thank the Matter Labs team for their

detailed responses to all our questions.


ZKsync Era-contracts Precompile Audit − Conclusion − 10


