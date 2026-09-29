### | security

# **ZKsync Protocol** **Precompiles** **Implementation** **Audit**

#### **April 10, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5

Circuit Builder Trait 5

Precompiles 6


Security Model and Trust Assumptions _______________________________________________  7


Medium Severity ___________________________________________________________________  8

M-01 Memory Access Without Explicit Bounds Checks 8


Low Severity ______________________________________________________________________  9

L-01 Excessive Code Duplication in Precompile Modules 9

L-02 Insufficient and Inconsistent Documentation 9

L-03 modexp Lacks Optimizations for Trivial Cases 10

L-04 Inefficient Subgroup Check in BN254 G2 11

L-05 Lack of Robust Error Handling in execute_precompile Memory Reads 11


Notes & Additional Information ____________________________________________________ 13

N-01 Absence of Automated Linting May Lead to Code Quality Issues 13

N-02 Presence of dbg! Macros in ecadd Module 13

N-03 Unclear Generic const Parameter 14

N-04 Incomplete and Incorrect Test Cases 14

N-05 Typographical Error 15


Conclusion ______________________________________________________________________ 16


ZKsync Protocol Precompiles Implementation Audit − Table of Contents − 2


## **Summary**

**Type** Precompile


**Timeline** From 2025-03-13
To 2025-03-20


**Languages** Rust



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



**Total Issues** 11 (5 resolved, 1 partially resolved)



**Low Severity Issues** 5 (2 resolved)



**Notes & Additional**
**Information**



5 (2 resolved, 1 partially resolved)



ZKsync Protocol Precompiles Implementation Audit − Summary − 3


## **Scope**

We audited the <u>[matter-labs/zksync-protocol](https://github.com/matter-labs/zksync-protocol/)</u> repository at commit <u>[97162cc.](https://github.com/matter-labs/zksync-protocol/tree/97162ccf21bb80be6f543307d93588f290720fc0/)</u>


In scope were the following files:

```
./crates/zk_evm_abstractions/src/precompiles/
├── ecadd.rs
├── ecmul.rs
├── ecpairing.rs
└── modexp.rs
./crates/circuit_definitions/src/circuit_definitions/base_layer
├── ecadd.rs
├── ecmul.rs
├── ecpairing.rs
└── modexp.rs
./crates/zkevm_circuits/src/modexp/
├── implementation/
│ └── u256.rs
├── input.rs
└── mod.rs

```

ZKsync Protocol Precompiles Implementation Audit − Scope − 4


## **System Overview**

The project implements Ethereum precompile operations in a zkEVM context. Ethereum

precompiles are special contracts with predefined addresses that implement cryptographically

expensive operations. The system provides both computational implementations and zero
knowledge circuit implementations for these operations.


The codebase follows a modular architecture, with a common interface

( <mark>`PrecompilesProcessor`</mark> <mark>)</mark> for executing precompile operations and specific

implementations for each operation, alongside a modular exponentiation circuit

implementation. Each precompile is implemented with:



1.

2.

3.



A core algorithm that performs the actual computation.

Memory interaction logic to interface with the VM.

Zero-knowledge circuit definitions for generating proofs.



Under this audit’s scope, <mark>`zkevm_circuits/src/modexp/`</mark> includes <mark>`u256.rs`</mark> <mark>,</mark> which

handles the main <mark>`modexp_32_32_32`</mark> function for <mark>`UInt256`</mark> modular exponentiation,

<mark>`input.rs`</mark> <mark>,</mark> which sets up <mark>`ModexpCircuitFSMInputOutput`</mark> to manage queues and

witnesses, and <mark>`mod.rs`</mark> <mark>,</mark> which runs the circuit using <mark>`modexp_function_entry_point`</mark> <mark>,</mark>

meeting the zero-knowledge requirements.

### **Circuit Builder Trait**


The project implements the <mark>`CircuitBuilder`</mark> trait for each precompile operation, which

defines the circuit's geometry, lookup parameters, and gate configurations. This trait is

responsible for setting up the constraint system for zero-knowledge proofs, ensuring that each

operation can be efficiently verified.


The circuits use various specialized gates, including boolean constraints, reduction gates, and

selection gates, to optimize the proof generation and verification process. They also leverage

lookup tables for common operations to reduce constraint complexity.


ZKsync Protocol Precompiles Implementation Audit − System Overview − 5


### **Precompiles**

**ModExp**


The Modular Exponentiation precompile computes <mark>`b^e mod m`</mark> for large integers, a

fundamental operation in many cryptographic protocols. The implementation uses a square
and-multiply algorithm, processing the exponent bit by bit. The circuit handles special cases

such as zero modulus and implements optimizations for common input patterns.


**ECAdd**


The Elliptic Curve Addition precompile adds two points on the BN254 elliptic curve. BN254 is

used extensively in pairing-based cryptography and zero-knowledge applications. The

implementation validates that the input points lie on the curve and handles edge cases,

including the point at infinity.


**ECMul**


The Elliptic Curve Multiplication precompile multiplies a point on the BN254 curve by a scalar

value. The implementation includes optimizations for handling large scalars, including

reduction modulo the group order. It correctly handles edge cases such as multiplication by the

group order resulting in the point at infinity.


**ECPairing**


The Elliptic Curve Pairing precompile performs pairing checks on the BN254 curve, a critical

operation for verifying various zero-knowledge proofs and other cryptographic protocols. This

is the most complex of the precompiles, supporting multiple input pairs and validating that

points lie in the correct subgroup of the curve.


ZKsync Protocol Precompiles Implementation Audit − System Overview − 6


## **Security Model and Trust** **Assumptions**

During the audit, the following trust assumptions were made:



1.


2.


3.


4.


5.



**Boojum Constraint System Framework** : It is assumed that the underlying constraint

system framework used to build the circuits is sound and correctly implements the

necessary cryptographic protocols.

**VM Runtime Environment** : The zkEVM execution environment invoking these

precompiles was not audited, and its correct handling of returned status flags and

corresponding outputs is assumed. Specifically, the VM is assumed to correctly

distinguish success and failure scenarios via explicit status flags returned by the

precompiles, even when success cases may produce results that visually resemble error

conditions (e.g., point at infinity <mark>`[1, 0, 0]`</mark> vs. an explicit error <mark>`[0, 0, 0]`</mark> <mark>)</mark> . Failure

of the VM to properly interpret these status flags could lead to incorrect or insecure

operations.

**Memory Management System** : While we reviewed the memory interaction code, the

underlying memory system implementation was out of scope and is assumed to work

correctly.

**Gas Metering** : The correctness of gas cost calculations and metering for these

operations were not verified and are assumed to be correct.

**ModExp Test Coverage** : The test cases in <mark>`modexp_32-32-32_tests.json`</mark> and

<mark>`modmul_32-32_tests.json`</mark> are assumed to be properly structured.


ZKsync Protocol Precompiles Implementation Audit − Security Model and

Trust Assumptions − 7


## **Medium Severity**

### **M-01 Memory Access Without Explicit Bounds** **Checks**

In precompile implementations <mark>(</mark> <mark>`ecadd.rs`</mark> <mark>,</mark> <mark>`ecmul.rs`</mark> <mark>,</mark> <mark>`ecpairing.rs`</mark> <mark>,</mark> and <mark>`modexp.rs`</mark> <mark>)</mark>,

the <mark>`execute_precompile`</mark> methods increment memory indices

( <mark>`current_read_location.index`</mark> and <mark>`write_location.index`</mark> <mark>)</mark> without explicit

arithmetic checks for overflow or boundary validation. For example, in <u><mark>`[ecadd.rs](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/ecadd.rs)`</mark></u> <mark>,</mark> multiple

reads <mark>(</mark> <mark>`x1`</mark> <mark>,</mark> <mark>`y1`</mark> <mark>,</mark> <mark>`x2`</mark> <mark>,</mark> <mark>`y2`</mark> <mark>)</mark> and writes <mark>(</mark> <mark>`status`</mark> <mark>,</mark> `x`, `y` ) increment offsets directly, implicitly

assuming that the provided offsets <mark>(</mark> <mark>`params.input_memory_offset`</mark> and

<mark>`params.output_memory_offset`</mark> <mark>)</mark> are safe and within the valid range.


If an arithmetic overflow were to occur due to large offsets, memory reads could unintentionally

reference incorrect indices or wrap around to unintended positions within a memory page. This

could result in using unintended data in computations, leading to incorrect or unpredictable

execution states. Similarly, arithmetic overflow during memory writes could lead to data being

written into incorrect or unintended memory locations.


To address this issue, consider following these recommendations:








Introduce explicit arithmetic checks using checked arithmetic ( _e.g._ <mark>`checked_add`</mark> <mark>)</mark> .

Implement an explicit error state in output memory (e.g., setting a status indicator to

<mark>`U256::zero()`</mark> <mark>)</mark> when an arithmetic overflow or bounds violation is detected.



**_Update:_** _Resolved, not an issue. The Matter Labs team stated:_


_This check is handled on the circuit level._


ZKsync Protocol Precompiles Implementation Audit − Medium Severity − 8


## **Low Severity**

### **L-01 Excessive Code Duplication in Precompile** **Modules**

The codebase exhibits significant code duplication across precompile modules, particularly in

<mark>`MemoryQuery`</mark> execution. Each module redundantly defines logic for:









Manually incrementing memory index locations.

Constructing nearly identical read/write queries.

Structuring conditional branches identically for success and failure handling.



This redundancy increases maintenance overhead, introduces a higher risk of inconsistencies,

and complicates global improvements or bug fixes.


To improve maintainability and consistency, consider one of the following approaches:









**Extract Common Logic:** Move repetitive memory operations into shared helper

functions.

**Leverage Code Generation:** Employ macro-based or procedural macro solutions to

enforce uniformity in repetitive patterns.



Refactoring the code in this way will enhance readability, reduce duplication, and streamline

future modifications.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We would like to postpone this issue._

### **L-02 Insufficient and Inconsistent** **Documentation**


While some functions contain minimal inline comments (e.g., <u><mark>`[ecpairing_inner](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/ecpairing.rs#L286)`</mark></u> and

<u><mark>`[modexp_inner](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/modexp.rs#L135)`</mark></u> <mark>)</mark>, many critical sections, particularly within the circuit builder implementations,

lack sufficient explanations. The absence of consistent documentation makes it difficult to

understand the design rationale and expected behavior of key components.


There is also no comprehensive module- or architecture-level documentation, which can hinder

new contributors from grasping how different precompile functions—such as elliptic curve


ZKsync Protocol Precompiles Implementation Audit − Low Severity − 9


addition, multiplication, pairing, and modular exponentiation—interact with the corresponding

circuit synthesis components.


Furthermore, complex operations like elliptic curve arithmetic and modular exponentiation have

sparse inline comments. The existing documentation does not provide enough detail on edge

cases, error handling, or performance trade-offs, making it harder to ensure correctness and

efficiency.


To address these issues, consider doing the following:













Adopt a standardized documentation style, following Rustdoc conventions, to ensure

that all public modules, functions, and data structures include clear descriptions of their

purpose, parameters, expected outputs, and possible error conditions.

Develop a high-level architectural overview, either as a separate document or as an

introductory module comment, to illustrate the overall design of the precompile and

circuit builder components. Including diagrams or flowcharts would help contributors

understand component interactions.

Improve inline documentation for cryptographic functions by adding explanations of

algorithm choices, assumptions, and potential pitfalls. References to relevant standards

(e.g., EIP specifications) could further clarify the implementation.

Utilize Rustdoc to automate documentation generation and publication, ensuring up-to
date and easily accessible references for the team and community.



Improving documentation will enhance code maintainability, facilitate onboarding for new

developers, and ensure that the cryptographic components are well understood by all

contributors.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We would like to postpone this issue._

### **L-03 modexp Lacks Optimizations for Trivial** **Cases**


The <u><mark>`[modexp_inner](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/modexp.rs#L135C8-L135C20)`</mark></u> function uses a fixed 256-bit square-and-multiply algorithm for modular

exponentiation without optimization for trivial cases. While it handles a modulus of zero

efficiently (as per <u>[EIP-198), other trivial inputs incur unnecessary computational overhead:](https://eips.ethereum.org/EIPS/eip-198)</u>








**Exponent (** **`e`** **) = 0** : The result is trivially:

`1` if <mark>`m > 1`</mark>


ZKsync Protocol Precompiles Implementation Audit − Low Severity − 10


`0` if <mark>`m = 1`</mark>

**Exponent (** **`e`** **) = 1** : The result simplifies directly to <mark>`b mod m`</mark> <mark>.</mark>

**Base (** **`b`** **) = 0 or 1** : These yield simple results directly without further computation.



Currently, the implementation unnecessarily processes all 256 exponent bits even for these

trivial scenarios.


Consider implementing fast-path checks for <mark>`e ∈ {0, 1}`</mark> and <mark>`b ∈ {0, 1}`</mark> prior to entering

the main exponentiation loop. These enhancements would significantly improve performance in

trivial scenarios while maintaining optimal zero-knowledge circuit efficiency.


**_Update:_** _[Resolved in pull request #148.](https://github.com/matter-labs/zksync-protocol/pull/148)_

### **L-04 Inefficient Subgroup Check in BN254 G2**


In <u><mark>`[ec_pairing.rs](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/ecpairing.rs#L303)`</mark></u> <mark>,</mark> subgroup membership for point $P$ is currently verified using a full 254
bit scalar multiplication, which is computationally expensive.


In a precompile setting, this inefficiency increases gas costs due to excessive elliptic curve

additions. Consider optimizing with either of the following:


**Frobenius Endomorphism**


##### Use ψ ( P ) = [6 x ²] P for efficient verification, where x = 4965661367192848881 [6 x ²] a 65-bit scalar. Since the Frobenius map ψ on F p 2 is nearly free (just a conjugation), this


##### Use ψ ( P ) = [6 x ²] P for efficient verification, where x = 4965661367192848881, making


##### ] a 65-bit scalar. Since the Frobenius map ψ on F p 2 is nearly free (just a conjugation), this



check confirms membership at a much lower cost.


**Cofactor Multiplication**


Instead of multiplying by the full group order **r** (a 254-bit scalar), use the smaller **cofactor h** for

faster verification, reducing scalar multiplications and improving performance.


**_Update:_** _[Resolved in pull request #148.](https://github.com/matter-labs/zksync-protocol/pull/148)_

### **L-05 Lack of Robust Error Handling in** **execute_precompile Memory Reads**


The <mark>`execute_precompile`</mark> method does not adequately handle memory read failures,

leading to silent failures where invalid inputs are misinterpreted as valid elliptic curve points.

[Specifically, when memory reads fail without triggering exceptions (returning zeros instead), the](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm/src/reference_impls/memory.rs#L110-L115)


ZKsync Protocol Precompiles Implementation Audit − Low Severity − 11


code incorrectly treats these as legitimate <mark>`(0,0)`</mark> points, which represent the point at infinity

in elliptic curve cryptography.


If a memory read fails and returns <mark>`(0,0)`</mark> <mark>,</mark> the system does not differentiate between a

legitimate input and a failure-induced default. This introduces several security risks:













**Silent Failure:** The system does not raise an error even if the user did not provide a valid

elliptic curve point. Instead, it performs an operation that may seem correct but is

semantically incorrect due to hidden errors.

**Ambiguity in Input Handling:** The system assumes that <mark>`(0,0)`</mark> is always a deliberate

input, failing to distinguish it from memory read failures.

**Attack Vector for Cryptographic Manipulation:** An attacker could exploit this behavior

by crafting inputs that force <mark>`(0,0)`</mark> as an operand (manipulating input offsets or

memory pages to areas they know will return zeros rather than fail outright), effectively

bypassing part of an elliptic curve operation.

**Protocol Inconsistencies:** If the precompile is used in a higher-level protocol, operations

that should fail may silently produce seemingly valid results, breaking security

assumptions.



To prevent these issues, the implementation should:



1.


2.


3.



**Explicitly verify memory read success** before using the values in cryptographic

computations. If <mark>`execute_partial_query`</mark> does not provide a failure indicator,

additional validation should be implemented.

**Differentiate between intentional** **<mark>`(0,0)`</mark>** **inputs and memory failure-induced defaults**

by introducing explicit error checks.

**Enforce memory access validation** before performing elliptic curve operations to ensure

that out-of-bounds or corrupted reads do not lead to incorrect cryptographic behavior.



**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_We do believe it is not an issue, and the reason for this is the context in which code is_

_used. Crypto precompiles can be called only via precompile_call opcode on EraVM. The_

_way VM handles precompile_call - it checks that address of contract that calls_

_precompile_call is 0x01 then the ecrecover circuit is executed under the hood if the_

_contract address is 0x02 it will do sha logic, if the contract address is 0x08 then it does_

_ecpairing logic. But also note, that 0x08 has predeployed bytecode of https://_

_github.com/matter-labs/era-contracts/blob/draft-v28/system-contracts/contracts/_

_precompiles/EcPairing.yul#L134. Which means the circuit logic which you reviewed will_

_be only executed with a constraints on which EcPairing contract living (with all of_

_memory invariants and etc)._


ZKsync Protocol Precompiles Implementation Audit − Low Severity − 12


## **Notes & Additional** **Information**

### **N-01 Absence of Automated Linting May Lead to** **Code Quality Issues**

The codebase exhibits several suboptimal practices, such as unnecessary <mark>`let`</mark> bindings,

length comparisons to zero, equality checks against <mark>`false`</mark> <mark>,</mark> and many more (there are 1103

warnings in total for the whole codebase) that can be caught by <mark>`cargo clippy`</mark> <mark>,</mark> the official

Rust linter.


Without this linter, the project may suffer from:









Increased code complexity and reduced readability.

Higher risk of performance inefficiencies and runtime errors.

Difficulty maintaining consistency and quality standards.



Consider using <mark>`cargo clippy`</mark> in the development workflow, as it can help identify and

address these issues early. Possible integration strategies include:










**CI/CD Enforcement** : Add a step in the CI/CD pipeline to fail builds on clippy warnings.

**IDE Support** : Configure IDE plugins such as rust-analyzer or JetBrains Rust to enable

real-time linting feedback.

**Git Hooks** : Implement a pre-commit hook to prevent commits with lint errors.



These measures will enhance code quality, streamline reviews, and enforce best practices

across the codebase.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We would like to postpone this issue._

### **N-02 Presence of dbg! Macros in ecadd Module**


The <mark>`ecadd`</mark> module contains instances of the <u><mark>`[dbg!](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/ecadd.rs#L283-L286)`</mark></u> <u>macro, which is typically used for</u>

temporary debugging during development. However, leaving <mark>`dbg!`</mark> macros in production code

is not advisable as they print directly to <mark>`stderr`</mark> <mark>,</mark> leading to cluttered logs and potential


ZKsync Protocol Precompiles Implementation Audit − Notes & Additional

Information − 13


exposure of internal state. Additionally, <mark>`dbg!`</mark> is not optimized for performance and lacks

configurability for different logging levels.


Consider removing <mark>`dbg!`</mark> macros from the <mark>`ecadd`</mark> module. If logging is necessary, a

structured logging or tracing library such as <mark>`tracing`</mark> or a similar logging crate should be

used instead. These alternatives offer configurable log levels, structured outputs, and better

performance management.


**_Update:_** _[Resolved in pull request #148.](https://github.com/matter-labs/zksync-protocol/pull/148)_

### **N-03 Unclear Generic const Parameter**


The <mark>`const`</mark> generic parameter `B` used in all the unit structs for each precompile lacks clarity,

making the code less readable and harder to maintain. Without a descriptive name or proper

documentation, it is difficult for developers to understand its purpose and impact.


Consider renaming `B` to a more descriptive identifier, such as <mark>`ENABLE_WITNESS`</mark> <mark>,</mark> or adding

documentation to clarify its role.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We would like to postpone this issue._

### **N-04 Incomplete and Incorrect Test Cases**


Throughout the codebase, multiple instances of incomplete and/or incorrect test cases were

identified:


**Incomplete Coverage**











<u><mark>`[test()](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/modexp.rs#L215)`</mark></u> in <mark>`modexp.rs`</mark> calls <mark>`modexp_inner(5, 0, 1)`</mark> but lacks an assertion that

<mark>`result == U256::one()`</mark> <mark>,</mark> reducing effectiveness.


Precompile test suites for <mark>`ecadd.rs`</mark> <mark>,</mark> <mark>`ecmul.rs`</mark> <mark>,</mark> <mark>`ecpairing.rs`</mark> <mark>,</mark> <mark>`ecpairing.rs`</mark> <mark>,</mark>

and <mark>`modexp.rs`</mark> lack edge case coverage, particularly for invalid field elements and

modulus overflows.


Ensure compliance with relevant EIPs for these precompiles.


ZKsync Protocol Precompiles Implementation Audit − Notes & Additional

Information − 14


**Incorrect Implementation**







<u><mark>`[test_ecadd_inner_invalid_x2y2](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/ecadd.rs#L478-L479)`</mark></u> in <mark>`ecadd.rs`</mark> parses hex values <mark>`x1`</mark> and <mark>`y1`</mark>

using base-10 instead of base-16, leading to incorrect validation.



Weak test coverage may result in undetected failures, especially in cryptographic operations,

whereas incorrect parsing could introduce false positives/negatives, obscuring real issues.


Consider improving test cases by adding edge cases, invalid inputs, and boundary conditions,

fixing radix parsing in <mark>`test_ecadd_inner_invalid_x2y2`</mark> for correctness, and verifying

precompile behavior against the relevant EIPs (EIP-196/197/198/2565).


**_Update:_** _Partially resolved. Edge case coverage has been addressed in_ _<u>[precompiles.rs.](https://github.com/matter-labs/zksync-protocol/blob/feature/ec_precompiles/crates/zkevm_test_harness/src/tests/complex_tests/precompiles.rs)</u>_

_However,_ _<mark>`test_ecadd_inner_invalid_x2y2`</mark>_ _in_ _<mark>`ecadd.rs`</mark>_ _still parses hex values using_

_base-10 instead of base-16, and_ _<mark>`test()`</mark>_ _in_ _<mark>`modexp.rs`</mark>_ _continues to lack an assertion_

_verifying that_ _<mark>`result == U256::one()`</mark>_ _for_ _<mark>`modexp_inner(5, 0, 1)`</mark>_ _<mark>,</mark>_ _reducing test_

_effectiveness._

### **N-05 Typographical Error**


Typographical errors can negatively affect the clarity and maintainability of the codebase.


[The comment in line 356](https://github.com/matter-labs/zksync-protocol/blob/97162ccf21bb80be6f543307d93588f290720fc0/crates/zk_evm_abstractions/src/precompiles/ecpairing.rs#L356-L357) of <mark>`ecpairing.rs`</mark> currently references EIP-192, which is incorrect.


Consider updating the aforementioned comment to refer to <u>[EIP-197.](https://eips.ethereum.org/EIPS/eip-197)</u>


**_Update:_** _[Resolved in pull request #148.](https://github.com/matter-labs/zksync-protocol/pull/148)_


ZKsync Protocol Precompiles Implementation Audit − Notes & Additional

Information − 15


## **Conclusion**

This audit covered the implementation of Ethereum precompile operations in a zkEVM context,

specifically focusing on the ModExp, ECAdd, ECMul, and ECPairing operations. It also covered

implementation and tests for the ModExp circuit. The review encompassed both the

computational implementations of these operations and their corresponding zero-knowledge

circuit constructions. The assessment focused on the correctness of algorithm

implementations, input validation, edge case handling, and the proper translation of

computational logic into circuit constraints.


During the audit, one critical-severity issue was identified, where memory read failures in

<mark>`execute_precompile`</mark> could be silently interpreted as valid <mark>`(0,0)`</mark> points, creating

vulnerabilities. In addition, several issues pertaining to optimization and best practices were

identified that, while not immediately threatening to system security, could impact

performance, maintainability, and gas efficiency.


Overall, the codebase demonstrates a good implementation of complex cryptographic

operations with appropriate attention to security concerns. The modular architecture and

consistent interface design reflect good engineering principles. Nevertheless, there is room for

improvement in areas such as code efficiency and documentation completeness.


ZKsync Protocol Precompiles Implementation Audit − Conclusion − 16


