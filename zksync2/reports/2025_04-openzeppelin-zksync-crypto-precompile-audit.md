### | security

# **ZKsync Crypto** **Precompile Audit**

#### **April 3, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Security Model and Privileged Roles _________________________________________________  5


High Severity ______________________________________________________________________  7

H-01 Incorrect Implementation of pow_u32 Exponentiation for Even Exponent 7

H-02 Missing Subgroup Check for G2 Points 7

H-03 Unimplemented allocate_constant Causes Panic in fq2.rs 7

H-04 Lack of Zero Check in Inverse Computation for Tower Extensions 8

H-05 Incorrect Computation of NEGATIVE_ONE Constant in fq.rs 8


Medium Severity ___________________________________________________________________  9

M-01 Converting a potentially 512-bit number to a 256-bit number, causing panic 9


Low Severity ______________________________________________________________________  9

L-01 Silent Debug Assertions utils.rs Under Release Mode 9

L-02 Redundant Computation in Line Coefficients and Point Operations 10


Notes & Additional Information ____________________________________________________ 10

N-01 Incorrect Comments and Typos in Codebase 10


Recommendations _______________________________________________________________ 11

Optimization of the Function decompress in algebraic_torus.rs 11


Conclusion ______________________________________________________________________ 13


ZKsync Crypto Precompile Audit − Table of Contents − 2


## **Summary**

**Type** Precompile


**Timeline** From 2025-02-25
To 2025-03-12


**Languages** Rust



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


5 (5 resolved)


1 (1 resolved)



**Total Issues** 9 (8 resolved)



**Low Severity Issues** 2 (2 resolved)



**Notes & Additional**
**Information**



1 (0 resolved)



ZKsync Crypto Precompile Audit − Summary − 3


## **Scope**

We audited <u>[pull request #77](https://github.com/matter-labs/zksync-crypto/pull/77)</u> [of the matter-labs/zksync-crypto](https://github.com/matter-labs/zksync-crypto) repository at commit <u>[ccf5fa3.](https://github.com/matter-labs/zksync-crypto/commit/ccf5fa30ee2c94b594126d7b4b75770cafbbab21)</u>


In scope were the following files:

```
crates
└── boojum
└── src
└── gadgets
├── curves
│  ├── sw_projective
│  │  └── mod.rs
│  ├── zeroable_affine
│  │  └── mod.rs
├── non_native_field
│  ├── implementations
│  │  ├── impl_traits.rs
│  │  ├── implementation_u16.rs
│  │  └── mod.rs
│  └── traits
│    └── mod.rs
├── tower_extension
│  ├── algebraic_torus.rs
│  ├── fq12.rs
│  ├── fq2.rs
│  ├── fq6.rs
│  ├── mod.rs
│  └── params
│    ├── bn256.rs
│    └── mod.rs
├── traits
│  ├── hardexp_compatible.rs
│  └── mod.rs
├── u256
│  └── mod.rs
└── u512
└── mod.rs
└── pairing
└── src
└── bn256
├── ec.rs
└── mod.rs
└── pairing_certificate.rs

```

ZKsync Crypto Precompile Audit − Scope − 4


## **System Overview**

The code under review is part of the <mark>`pairing`</mark> and <mark>`boojum`</mark> crates within Matter Labs’

<mark>`zksync-crypto`</mark> repository, a cryptographic library that supports ZKsync—a layer-2 scaling

solution for Ethereum. These crates implement elliptic curve pairings using the BN256 curve,

also known as alt_bn128 or BN254 in different contexts. They enable zk-SNARKs, a zero
knowledge proof critical for ZKsync, enhancing Ethereum transaction scaling securely and

efficiently.


The <mark>`pairing`</mark> crate, located in <mark>`crates/pairing/src/bn256`</mark> <mark>,</mark> handles BN256 curve

arithmetic through files like <mark>`ec.rs`</mark> and <mark>`mod.rs`</mark> <mark>.</mark> It computes pairings natively on the host

system, supporting ZKsync’s rollup proofs and signature verification outside arithmetic circuits.

The audited code in the <mark>`pairing`</mark> crate employs precomputed line functions for the Miller

loop, a key step in pairing computation, to enhance performance for zk-SNARK verification.

This approach improves efficiency by reducing the computational cost of pairing operations.


The <mark>`boojum`</mark> crate is located in <mark>`crates/boojum/src`</mark> <mark>.</mark> It focuses on circuit-based BN256

operations, including affine and projective curve arithmetic in <mark>`gadgets/curves`</mark> <mark>,</mark> tower field

extensions in files under <mark>`gadgets/tower_extension`</mark> and <mark>`algebraic_torus.rs`</mark> <mark>,</mark> and

non-native field arithmetic in <mark>`gadgets/non_native_field`</mark> <mark>.</mark> This crate encodes pairing

computations as arithmetic circuits, enabling ZKsync’s prover to generate zk-SNARK proofs.

The audited enhancements optimize these circuits with techniques like algebraic torus

arithmetic, reducing the complexity and cost of proof generation.

## **Security Model and** **Privileged Roles**


This audit targeted the files listed above (in <mark>`crates/pairing/src/bn256`</mark> and <mark>`crates/`</mark>

<mark>`boojum/src`</mark> <mark>)</mark>, which have dependencies that are outside the scope of this audit. While we

reviewed the dependencies, unchanged parts outside this scope cannot be reliably deemed to

be correct.


ZKsync Crypto Precompile Audit − System Overview − 5


The <mark>`pairing`</mark> crate assumes a secure native environment, trusting precomputed Miller loop

functions for rollup proofs and signatures. The <mark>`boojum`</mark> crate uses arithmetic circuits,

assuming a trusted prover-verifier setup where the prover accesses witness data but ensures

verifiable zero-knowledge proofs. Both crates trust the hardness of pairings on BN256 curves,

with no additional roles beyond standard cryptographic assumptions (e.g., honest

computation).


[However, with the advancement of tower field sieve techniques, the effective security of BN256](https://eprint.iacr.org/2015/1027.pdf)

(due to these advances) is reduced to approximately 100 bits. Thus, although unbroken in

practice, BN254 is unsuitable for future use due to this weakness.


ZKsync Crypto Precompile Audit − Security Model and Privileged Roles − 6


## **High Severity**

### **H-01 Incorrect Implementation of pow_u32** **Exponentiation for Even Exponent**

In <u><mark>`[algebraic_torus.rs](https://github.com/matter-labs/zksync-crypto/blob/feature/ec_precompiles/crates/boojum/src/gadgets/tower_extension/algebraic_torus.rs#L187)`</mark></u> <mark>,</mark> the <mark>`pow_u32<CS, S: AsRef<[u64]>>(&mut self, cs:`</mark>


##### S = 2 k



_<u>γ</u>_
##### _k_
_g_


##### &mut CS, exponent: S) function, when S = 2 k, outputs incorrectly for all as a result γ k

_g_



of starting with <mark>`Self::zero`</mark> and a static <mark>`base`</mark> <mark>.</mark> This error persists in all the cases where $S$

is even, breaking the exponentiation in those instances. If used in pairing computations, this

could lead to incorrect pairing evaluations, potentially allowing false zk-proofs.


Consider precomputing using the first bit, and then starting from the second bit, updating

<mark>`base`</mark> in each iteration.


**_Update:_** _[Resolved in PR #87](https://github.com/matter-labs/zksync-crypto/pull/87)_ _[at commit 65c890d.](https://github.com/matter-labs/zksync-crypto/commit/65c890d3d1b8a90242822757484c8511ab9427a0)_

### **H-02 Missing Subgroup Check for G2 Points**


In <u><mark>`[pairing_certificate.rs](https://github.com/matter-labs/zksync-crypto/blob/feature/ec_precompiles/crates/pairing/src/bn256/pairing_certificate.rs)`</mark></u> <mark>,</mark> points in G2 are used in pairing operations without explicit
##### verification that they belong to the correct prime-order subgroup. If a point ( x, y ) does not lie

in this subgroup, the pairing computation may yield incorrect results, potentially compromising

the validity of proofs.

##### Consider implementing a subgroup validation check by ensuring that [ r ] P = O, where ( r ) is

the prime order of the subgroup and ( O ) is the identity element. A faster way to enforce this is

to check the conditions of Proposition 3 in <u>[this](https://eprint.iacr.org/2022/352.pdf)</u> paper.


**_Update:_** _Resolved. This is not an issue. The Matter Labs team clarified that subgroup checks_

_are enforced on the circuit level and since this code is only used for witness generation, the_

_witness generation process itself does not enforce subgroup checks._

### **H-03 Unimplemented allocate_constant** **Causes Panic in fq2.rs**


The function <u><mark>`[allocate_constant](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/boojum/src/gadgets/traits/allocatable.rs#L14)`</mark></u> in the <mark>`CSAllocatable`</mark> trait is unimplemented.


ZKsync Crypto Precompile Audit − High Severity − 7


This results in a panic when <mark>`allocate_constant`</mark> is called to allocate constants for <u><mark>`[fq2](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/boojum/src/gadgets/tower_extension/fq2.rs#L342)`</mark></u> <mark>,</mark>

and the proof generation won't complete.


Consider overriding <mark>`allocate_constant`</mark> in <mark>`fq2.rs`</mark> by wrapping inner constant

allocations appropriately, or implementing this function.


**_Update:_** _[Resolved in pull request #88](https://github.com/matter-labs/zksync-crypto/pull/88)_ _[at commit 09cbca4.](https://github.com/matter-labs/zksync-crypto/commit/09cbca4a2626039d2a63f968bf2e0290455da076)_

### **H-04 Lack of Zero Check in Inverse Computation** **for Tower Extensions**


[The inverse functions in fq2.rs, fq6.rs, and](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/boojum/src/gadgets/tower_extension/fq2.rs#L203) <u>[fq12.rs](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/boojum/src/gadgets/tower_extension/fq12.rs#L372)</u> do not currently verify whether the element

is zero before computing the inverse.


This may lead to undefined behaviour when attempting to invert a zero element.


Consider adding a check for a zero element in the respective field and include error

management to return an error when the element is zero.


**_Update:_** _[Resolved in pull request #89](https://github.com/matter-labs/zksync-crypto/pull/89)_ _[at commit 15b2ca0.](https://github.com/matter-labs/zksync-crypto/commit/15b2ca0dfffce2f32957b907e86323ae179a0a73)_

### **H-05 Incorrect Computation of NEGATIVE_ONE** **Constant in fq.rs**


In the <mark>`fq.rs`</mark> file, the constant <u><mark>`[NEGATIVE_ONE](https://github.com/matter-labs/zksync-crypto/blob/3b518637a3a36a0e9e7a294e308b5675f85b15cd/crates/pairing/src/bn256/fq.rs#L200)`</mark></u> <mark>,</mark> which is supposed to represent (−((2256)
##### mod q ) mod q ), is incorrectly computed.


This constant is used in the field extension definitions and may cause errors in field extension

and arithmetic operations involving it, leading to incorrect results.


Consider correcting <mark>`NEGATIVE_ONE`</mark> to its correct value: <mark>`['0x68c3488912edefaa',`</mark>

<mark>`'0x8d087f6872aabf4f', '0x51e1a24709081231', '0x2259d6b14729c0fa']`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #90](https://github.com/matter-labs/zksync-crypto/pull/90)_ _[at commit 729cf0a.](https://github.com/matter-labs/zksync-crypto/commit/729cf0a95fbfa935006e13d475cc186a973e44d2)_


ZKsync Crypto Precompile Audit − High Severity − 8


## **Medium Severity**

### **M-01 Converting a potentially 512-bit number to** **a 256-bit number, causing panic**

In <u><mark>`[crates/boojum/src/gadgets/u256/mod.rs](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/boojum/src/gadgets/u256/mod.rs#L391)`</mark></u> <mark>,</mark> line 391 has the code:

```
let q: U256 = q.try_into().unwrap();

##### Here, q equals ⌊ ab ⌋, where and are 256-bit numbers. Since a b q can be up to 512 bits, the
```

_m_

conversion to <mark>`U256`</mark> may fail. If it does, <mark>`unwrap()`</mark> causes the <mark>`modmul`</mark> function to panic,

disrupting the proof flow.


Consider using <mark>`U512`</mark> for `q` or adding error handling to avoid panics.


**_Update:_** _[Resolved in pull request #92.](https://github.com/matter-labs/zksync-crypto/pull/92)_

## **Low Severity**

### **L-01 Silent Debug Assertions utils.rs Under** **Release Mode**


In the file <u><mark>`[utils.rs](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/boojum/src/gadgets/non_native_field/implementations/utils.rs#L)`</mark></u> <mark>,</mark> line 8, the function contains several debug assertions (e.g.,

<mark>`debug_assert!`</mark> <mark>)</mark> . These assertions are disabled when the code is compiled in release mode,

a standard Rust behaviour. As a result, conditions checked by these assertions are not verified

during production execution, potentially allowing errors to go unnoticed in the <mark>`boojum`</mark> crate.


In a cryptographic proofs, where arithmetic correctness is critical for proof generation and

verification, silent failures could lead to invalid proofs or performance issues.


Consider replacing <mark>`debug_assert!`</mark> with <mark>`assert!`</mark> in release mode.


**_Update:_** _[Resolved in pull request #94.](https://github.com/matter-labs/zksync-crypto/pull/94)_


ZKsync Crypto Precompile Audit − Medium Severity − 9


### **L-02 Redundant Computation in Line Coefficients** **and Point Operations**

In the current implementation of line function computations in <u><mark>`[pairing_certificate.rs](https://github.com/matter-labs/zksync-crypto/blob/feature/ec_precompiles/crates/pairing/src/bn256/pairing_certificate.rs)`</mark></u> <mark>,</mark>

the slope <mark>`alpha`</mark> is computed separately in the <u><mark>`[line_double](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/pairing/src/bn256/pairing_certificate.rs#L63-L64)`</mark></u> and <u><mark>`[line_add](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/pairing/src/bn256/pairing_certificate.rs#L72-L73)`</mark></u> functions.

Simultaneously, point operations like <mark>`t.double()`</mark> and <mark>`t.add_assign_mixed()`</mark>

recompute <mark>`alpha`</mark> <mark>,</mark> rather than reusing the value.


This results in redundant field arithmetic operations, reducing the computational efficiency of

pairings and proof verification.


Consider integrating the computation of <mark>`alpha`</mark> and <mark>`mu`</mark> directly into the point operations to

minimize repeated calculations and enable the reuse of intermediate results.


**_Update:_** _[Resolved in pull request #93.](https://github.com/matter-labs/zksync-crypto/pull/93)_

## **Notes & Additional** **Information**

### **N-01 Incorrect Comments and Typos in** **Codebase**


Throughout the codebase, we identified the following typos and incorrect comments that

should be addressed:



1.


2.


3.



**In** **<u><mark>`[fq.rs](https://github.com/matter-labs/zksync-crypto/blob/3b518637a3a36a0e9e7a294e308b5675f85b15cd/crates/pairing/src/bn256/fq.rs)`</mark></u>** <mark>,</mark> line 103 incorrectly states <mark>`Fq2(u + 1)**(((2q^0) - 2) / 3)`</mark> <mark>.</mark> The

correct expression should be <mark>`Fq2(u + 9)**(((2q^0) - 2) / 3)`</mark> <mark>.</mark> This correction

also applies to the following lines: **103, 108, 113, 118, 123, 128, 137, 142, 147, 152, 157,**

**162, 167, 172, 177, 182, 187, and 192** .


**In** **<u><mark>`[sw_projective/mod.rs](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/boojum/src/gadgets/curves/sw_projective/mod.rs)`</mark></u>** <mark>,</mark> the comment at line 213 should be corrected to: <mark>`// y3`</mark>
```
= y3 + t0

```

**In** **<u><mark>`[ec.rs](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/pairing/src/bn256/ec.rs)`</mark></u>** <mark>,</mark> line 592 should be updated to: <mark>`unimplemented!("on curve check is`</mark>
```
not implemented for BN-256 projective")

```

ZKsync Crypto Precompile Audit − Notes & Additional Information − 10


4.



**In** **<u><mark>`[pairing_certificate.rs](https://github.com/matter-labs/zksync-crypto/blob/ccf5fa30ee2c94b594126d7b4b75770cafbbab21/crates/pairing/src/bn256/pairing_certificate.rs)`</mark></u>** <mark>,</mark> to clarify the comment at line 118, it should be

changed to: <mark>`// and compute c0 = 1, c3 = - lambda * p.x / p.y =`</mark>
```
lambda * x', c4 = - mu / p.y = mu * y'

```


Consider applying these corrections to help improve code readability and prevent future

confusion, especially for the developers working on cryptographic functions and the BN-256

curve.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated that they would like to_

_postpone the fix and incorporate it into the upcoming improvements._

## **Recommendations**

### **Optimization of the Function decompress in** **`algebraic_torus.rs`**


[In file algebraic_torus.rs, the function](https://github.com/matter-labs/zksync-crypto/blob/feature/ec_precompiles/crates/boojum/src/gadgets/tower_extension/algebraic_torus.rs#L187) <mark>`decompress`</mark> can be optimized based on the following

observation:


Given that

##### g + w g 2 + ( u + 9) 2 g = + w, g − w g 2 −( u + 9) g 2 −( u + 9) and noting that d = u + 9 is a constant that is already precomputed, the expression can be

further simplified to

##### 1 + 2 D −1( d + gw ), where, D = g 2 − d is the denominator.


This approach reduces constraints and computational overhead by leveraging the special

structure of the expression, minimizing multiplications and redundant operations. As a result, it

improves the efficiency of pairing computations and proof verification.


**Implementation Steps**


##### 1. Import the precomputed constant d = u + 9 as a constant in F p 2


##### Import the precomputed constant d = u + 9 as a constant in


##### 2. Compute D = g 2 − d (one squaring and one subtraction in F p 6


##### Compute D = g 2 − d (one squaring and one subtraction in F p 6 .


##### 3. Compute D −1 (one inversion in F p 6


##### Compute D −1 (one inversion in F p 6 ).



ZKsync Crypto Precompile Audit − Recommendations − 11


##### 4. Compute 2 D −1 (one doubling in F p 6


##### Compute 2 D −1 (one doubling in F p 6 ).



5. Add 1 in F _p_ 2



Add 1 in F _p_ 2 .



ZKsync Crypto Precompile Audit − Recommendations − 12


## **Conclusion**

The audited code provides a cryptographic library for native pairing-based signature

generation, constrained cryptographic operations using non-native field arithmetic, and circuits

supporting field extensions.


During the audit, several high-severity issues were identified. In addition, the audit identified

few improvement areas, particularly in testing, error handling, and documentation. A more

thorough unit testing suite would help ensure that all operations are sound, edge cases are

properly handled, and any silent or unimplemented errors are identified. While some errors,

such as division by zero, are implicitly managed by the circuit, explicitly documenting these

cases would improve clarity and robustness. Additional documentation could also clarify the

rationale behind certain design choices, particularly the complex overflow tracking and

reduction/normalization scheme used to simulate non-native field arithmetic in-circuit. While

not immediately threatening to system security, addressing these aspects would enhance the

reliability and maintainability of the protocol.


Despite these findings, communication with the team was notably fast and friendly and we

appreciate the collaboration with the Matter Labs team on this project.


ZKsync Crypto Precompile Audit − Conclusion − 13


