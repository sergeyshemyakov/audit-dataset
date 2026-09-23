### | security

# **Stylus Contracts** **Library v0.2.0** **Audit**

#### **June 17, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  8

Crypto Library 8

Contract Library 8


Security Model and Trust Assumptions _______________________________________________  9


High Severity ____________________________________________________________________ 10

H-01 Limb Shift Overflow in shr_assign and shl_assign 10


Medium Severity _________________________________________________________________ 10

M-01 Potential Underflow in ct_rem Function 10

M-02 Customer Selectors in Trait With interface_id Attribute Are Not Checked in Implementation 11


Low Severity ____________________________________________________________________ 11

L-01 Verification Functions for Custom Hashing in Merkle Trees Assume Commutative Hashing 11

L-02 Inconsistent Data Types for carry and borrow Parameters 12

L-03 Encoding Ambiguity in ct_num_bits Function 12

L-04 Absence of Overflow Check in from_str_hex Function 13

L-05 Underlying Decimals in Erc20Wrapper Can Be Set Incorrectly 13

L-06 State Mutability Can Be Restricted in IErc4626 13

L-07 Custom Selectors in Trait With interface_id Allows Unreachable Patterns 14

L-08 Missing Trait Components in Generated Code From interface_id Macro 14

L-09 Potential Vulnerability in Big Integer Library to Timing Side-Channel Attacks 15


Notes & Additional Information ____________________________________________________ 15

N-01 Consistent Application of the #[must_use] Attribute in Merkle Proof Verification Functions 15

N-02 Redundant Attribute in the adc Function 16

N-03 Absence of #[inline(always)] Attributes in Certain Methods 16

N-04 Incorrect Comment in PartialEq Implementation for Projective Points 16

N-05 Source Code Attribution Concerns 17

N-06 Documentation Enhancements 17

N-07 Inconsistent Behavior of Shift Overflow Compared to Rust Native Integer Types 18

N-08 Misleading Documentation 18

N-09 Typographical Errors 18

N-10 Insufficient Unit Test Coverage 19


Stylus Contracts Library v0.2.0 Audit − Table of Contents − 2


Recommendations _______________________________________________________________ 19

Recommendations 19


Conclusion ______________________________________________________________________ 20


Stylus Contracts Library v0.2.0 Audit − Table of Contents − 3


## **Summary**

**Type**



Languages



**Timeline** From 2025-04-22 to 2025-05-14
(crypto library) and 2025-05-26 to **Total Issues** 22 (20 resolved)
2025-06-06 (contracts library)



**Critical Severity**
**Issues**



0 (0 resolved)



**High Severity**
**Issues**


**Medium Severity**
**Issues**



1 (1 resolved)


2 (1 resolved)



**Low Severity Issues** 9 (9 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



10 (9 resolved)


0 (0 resolved)



Stylus Contracts Library v0.2.0 Audit − Summary − 4


## **Scope**

We audited the <u>[OpenZeppelin/rust-contracts-stylus](https://github.com/OpenZeppelin/rust-contracts-stylus)</u> repository in two parts.


The first part was the crypto library. We audited the library at the <u>[a67ab70](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25)</u> commit from

[2025-04-22 to 2025-05-09. Then, we audited the 2350766](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/2350766c0c03527aedea04e2bffb8f1eb2d01aeb) commit, which introduced the

<mark>`pedersen`</mark> directory below, from 2025-05-12 to 2025-05-14.

```
lib/crypto/src
├── arithmetic
│  ├── limb.rs
│  ├── mod.rs
│  └── uint.rs
├── bits.rs
├── const_helpers.rs
├── curve
│  ├── helpers.rs
│  ├── mod.rs
│  └── sw
│    ├── affine.rs
│    ├── mod.rs
│    └── projective.rs
├── field
│  ├── fp.rs
│  ├── group.rs
│  ├── instance.rs
│  ├── mod.rs
│  └── prime.rs
├── hash.rs
├── keccak.rs
├── lib.rs
├── merkle.rs
├── pedersen
│  ├── instance
│  │  ├── mod.rs
│  │  └── starknet.rs
│  ├── mod.rs
│  └── params.rs
├── poseidon2
│  ├── instance
│  │  ├── babybear.rs
│  │  ├── bls12.rs
│  │  ├── bn256.rs
│  │  ├── goldilocks.rs
│  │  ├── mod.rs
│  │  ├── pallas.rs
│  │  └── vesta.rs
│  ├── mod.rs

```

Stylus Contracts Library v0.2.0 Audit − Scope − 5


```
│  └── params.rs
└── test_helpers.rs

```

The second part was the contracts library, which we audited at the <u>[5ed33dd](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48)</u> commit. The

following files were in scope:

```
contracts/src
├── access
│  ├── control.rs
│  ├── mod.rs
│  ├── ownable.rs
│  └── ownable_two_step.rs
├── finance
│  ├── mod.rs
│  └── vesting_wallet.rs
├── lib.rs
├── token
│  ├── common
│  │  ├── erc2981.rs
│  │  └── mod.rs
│  ├── erc1155
│  │  ├── extensions
│  │  │  ├── burnable.rs
│  │  │  ├── metadata_uri.rs
│  │  │  ├── mod.rs
│  │  │  ├── supply.rs
│  │  │  └── uri_storage.rs
│  │  ├── mod.rs
│  │  └── receiver.rs
│  ├── erc20
│  │  ├── extensions
│  │  │  ├── burnable.rs
│  │  │  ├── capped.rs
│  │  │  ├── erc4626.rs
│  │  │  ├── flash_mint.rs
│  │  │  ├── metadata.rs
│  │  │  ├── mod.rs
│  │  │  ├── permit.rs
│  │  │  └── wrapper.rs
│  │  ├── interface.rs
│  │  ├── mod.rs
│  │  └── utils
│  │    ├── mod.rs
│  │    └── safe_erc20.rs
│  ├── erc721
│  │  ├── extensions
│  │  │  ├── burnable.rs
│  │  │  ├── consecutive.rs
│  │  │  ├── enumerable.rs
│  │  │  ├── metadata.rs
│  │  │  ├── mod.rs
│  │  │  ├── uri_storage.rs
│  │  │  └── wrapper.rs
│  │  ├── interface.rs
│  │  ├── mod.rs

```

Stylus Contracts Library v0.2.0 Audit − Scope − 6


```
│  │  └── receiver.rs
│  └── mod.rs
└── utils
├── cryptography
│  ├── ecdsa.rs
│  ├── eip712.rs
│  └── mod.rs
├── introspection
│  ├── erc165.rs
│  └── mod.rs
├── math
│  ├── alloy.rs
│  ├── mod.rs
│  └── storage
│    ├── checked.rs
│    ├── mod.rs
│    └── unchecked.rs
├── metadata.rs
├── mod.rs
├── nonces.rs
├── pausable.rs
└── structs
├── bitmap.rs
├── checkpoints
│  ├── generic_size.rs
│  └── mod.rs
└── mod.rs

contracts-proc/src
├── interface_id.rs
└── lib.rs

```


Stylus Contracts Library v0.2.0 Audit − Scope − 7


## **System Overview**

### **Crypto Library**

The Crypto Library consists of six major areas: the arithmetic folder, the curve folder, the field

folder, the poseidon2 folder, the pedersen folder, and other modules in the root folder such as

<mark>`hash.rs`</mark> <mark>,</mark> <mark>`keccark.rs`</mark> <mark>,</mark> <mark>`merkle.rs`</mark> <mark>,</mark> <mark>`bits.rs`</mark> <mark>,</mark> etc.


The <mark>`hash`</mark> module implements a generic hash function that supports larger and more secure

outputs than the hasher in the core library, which only supports <mark>`u64`</mark> outputs. The <mark>`merkle`</mark>

module offers functions to verify Merkle proofs.


The arithmetic module supports big integer operations by providing safe, efficient, and portable

arithmetic on the underlying 64-bit chunks ("limbs") that make up large numbers.


The curve module defines the core traits and helpers needed to implement and use elliptic

curves, supporting both affine and projective representations, efficient group operations, and

batch field inversions. It serves as the foundation for higher-level cryptographic operations on

elliptic curves.


The field module lays the foundation for finite field arithmetic, providing traits, implementations,

and utilities for safe, efficient, and generic field operations—essential for cryptographic and

algebraic computations.


The Poseidon2 module provides a fast and flexible implementation of the Poseidon2 hash

function. The Pedersen module provides a fast implementation of the Pedersen hash function

compatible with Starknet. They are suitable for modern cryptographic applications, especially

in zero-knowledge and blockchain contexts.

### **Contract Library**


The Stylus Smart Contracts Library has been extensively updated to align with the latest Stylus

SDK conventions and to provide a broader suite of token utilities.


Constructors are now explicitly defined with the <mark>`#[constructor]`</mark> attribute and deployed

atomically, ensuring that contract initialization cannot be skipped or manipulated. Error

handling has been standardized using associated types, and all events now derive <mark>`Debug`</mark> for


Stylus Contracts Library v0.2.0 Audit − System Overview − 8


easier on-chain log inspection and off-chain debugging. The inheritance pattern has shifted

toward the SDK’s trait-based approach using the <mark>`#[implements(...)]`</mark> macro for trait
based inheritance.


On the feature side, the library introduces comprehensive support for multiple token standards:














ERC-1155 now includes burnable extensions, metadata URI management, and supply

controls.

ERC-4626 vault functionality allows ERC-20 tokens to be wrapped into yield-bearing

vaults.

Flash-minting capabilities for ERC-20.

A <mark>`SafeERC20`</mark> wrapper.

A vesting wallet implementation.

Several additional utilities.



The contract implementations closely follow the OpenZeppelin contracts library for Solidity due

to its robust design, maximizing compatibility and consistency. ERC-165 is fully implemented

across all contracts, so interface detection is reliable and consistent via

<mark>`supports_interface`</mark> <mark>.</mark>


A new procedural macro was also introduced to generate an <mark>`interface_id`</mark> function for

traits and handle custom selectors within those traits. Together, these enhancements improve

both the expressiveness and safety of the library while preserving a clear, standardized design.

## **Security Model and Trust** **Assumptions**











The crypto library's <u>[Poseidon2 implementation](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L1)</u> [matches the test vectors](https://github.com/HorizenLabs/poseidon2/blob/055bde3f4782731ba5f5ce5888a440a94327eaf3/plain_implementations/src/poseidon2/poseidon2.rs#L276-L614) of the reference

implementation.

It is assumed that the Stylus SDK and all third-party dependencies used by the

Contracts for Stylus library are secure, free from malicious code (such as backdoors),

and behave as documented.

Motsu, OpenZeppelin’s internal testing utility for Stylus contracts, functions as intended,

contains no critical bugs, and provides reliable coverage for the library’s unit tests.


Stylus Contracts Library v0.2.0 Audit − Security Model and Trust

Assumptions − 9


## **High Severity**

### **H-01 Limb Shift Overflow in shr_assign and** **`shl_assign`**

The <u><mark>`[shr_assign](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/2350766c0c03527aedea04e2bffb8f1eb2d01aeb/lib/crypto/src/arithmetic/uint.rs#L655)`</mark></u> and <u><mark>`[shl_assign](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/2350766c0c03527aedea04e2bffb8f1eb2d01aeb/lib/crypto/src/arithmetic/uint.rs#L696)`</mark></u> functions implement the shift-and-assign operators

( <mark>`<<=`</mark> and <mark>`>>=`</mark> <mark>)</mark> for the <mark>`Uint<N>`</mark> type, which represents a multi-limb unsigned integer with `N`

limbs. However, a shift overflow occurs <u>[[1] [2]](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/2350766c0c03527aedea04e2bffb8f1eb2d01aeb/lib/crypto/src/arithmetic/uint.rs#L675)</u> when the <mark>`limb_shift`</mark> value is zero. In debug

mode, this results in a runtime panic with the error message <mark>`attempt to shift left`</mark>

<mark>`with overflow`</mark> <mark>.</mark> In release mode, the shift value is masked, producing incorrect results.

Consider revising the code to address this issue before the overflow occurs.


**_Update:_** _[Resolved in pull #658](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/658)_ _[at commit c38b883. The team uses](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/c38b883d9a3b34890e560806e3d06e458f6501a1)_ _<mark>`checked_shl`</mark>_ _to mitigate_

_overflow situations._

## **Medium Severity**

### **M-01 Potential Underflow in ct_rem Function**


The <u><mark>`[ct_rem](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L848)`</mark></u> function computes the remainder of a division operation. However, the

calculation of <mark>`index`</mark> may result in an underflow if <u><mark>`[self.ct_num_bits()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L854)`</mark></u> <u>returns zero. This</u>

issue arises when the dividend <mark>(</mark> <mark>`self`</mark> <mark>)</mark> is zero, as <mark>`ct_num_bits`</mark> returns zero for a zero value.

Subtracting one from zero in an unsigned integer <mark>(</mark> <mark>`usize`</mark> <mark>)</mark> causes an underflow, wrapping

around to <mark>`usize::MAX`</mark> in release mode and leading to incorrect results for this function. It is

advisable to return zero directly when the dividend is zero.


**_Update:_** _[Resolved in pull #667](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/667/files)_ _[at commit 36ab98e.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/36ab98e84b7eb35bd5b295b13bcb006cb2cfc4de)_


Stylus Contracts Library v0.2.0 Audit − High Severity − 10


### **M-02 Customer Selectors in Trait With** **interface_id Attribute Are Not Checked in** **Implementation**

The <mark>`#[interface_id]`</mark> attribute is implemented as a <u>[procedural macro](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L15)</u> that can be added to

a trait. This macro re-generates the trait source code with the addition of an <mark>`interface_id`</mark>

function to produce its <u>[ERC-165 identiferi](https://eips.ethereum.org/EIPS/eip-165)</u> <u>.</u>


[The macro consumes any](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L28-L29) <u><mark>`[#[selector]](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L28-L29)`</mark></u> attributes within the trait, allowing them to exist in

traits. Within the Stylus SDK, the <mark>`#[selector]`</mark> attribute may only exist within <mark>`#[public]`</mark>

blocks and does not provide logic for the macro within traits. However, there is no mechanism

in place to enforce that trait implementations match the interface of traits with custom

selectors.


As a consequence, developers must remember to add any custom selectors in trait

implementations to correctly support the interface identifier, and there are no checks to ensure

this. As a result, the ABI for a particular implementation may not match its trait, violating

assumed invariants within Rust and potentially leading to failed contract integrations.


Consider refactoring the implementation of the <mark>`interface_id`</mark> macro to verify compatibility

in custom selectors with respective trait implementations.


**_Update:_** _Acknowledged, will resolve. The Contracts for Stylus team stated:_


_We have recommended the Stylus SDK team to include the_ _<mark>`#[interface_id]`</mark>_

_functionality and the option to retrieve selectors of each method and auto-implement_

_each router function to build inheritance this way (Doing so would allow compile-time_

_checks on custom selector differences between traits and implementation). We will work_

_with the team to add this functionality in future iterations._

## **Low Severity**

### **L-01 Verification Functions for Custom Hashing in** **Merkle Trees Assume Commutative Hashing**


[The functions verify_with_builder](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/merkle.rs#L178) [and verify_multi_proof_with_builder](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/merkle.rs#L257) serve as verifiers for

Merkle trees with custom hashing functions. However, these functions reconstruct the Merkle


Stylus Contracts Library v0.2.0 Audit − Low Severity − 11


root in a commutative manner, which assumes that all custom hashing algorithms employ

commutative hashing. Although commutative hashing is common practice, this assumption

cannot be guaranteed for all custom hashing processes.


Consider updating the documentation to specify that the Merkle tree hashing process must be

constructed commutatively when using custom hashing algorithms.


**_Update:_** _[Resolved in pull #674](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/674/files)_ _[at commit 6f75f80.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/6f75f80ca00fe768bc53aafc7772c9b6ec526afb)_

### **L-02 Inconsistent Data Types for carry and** **borrow Parameters**


The arithmetic carry (for addition) and borrow (for subtraction) parameters are defined as the

<mark>`Limb`</mark> type in the <u><mark>`[adc](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs#L87)`</mark></u> and <u><mark>`[sbb](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs#L108)`</mark></u> functions, but as the <mark>`bool`</mark> type in the <u><mark>`[adc_assign](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs#L98)`</mark></u> and

<u><mark>`[sbb_assign](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs#L122)`</mark></u> functions. These parameters are currently expected to hold only the values `0` or

`1`, as required by the functions that utilize them. However, unintended behavior may arise if a

function erroneously passes a carry or borrow parameter with a value greater than 1.


[For example, the overflow protection mechanism](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs#L113) will fail if <mark>`a = 0`</mark> <mark>,</mark> <mark>`b = u64::MAX`</mark> <mark>,</mark> and

<mark>`borrow = 2`</mark> in the <mark>`sbb`</mark> function. Consider adopting the <mark>`bool`</mark> type exclusively for carry and

borrow parameters, casting them to <mark>`Limb`</mark> during calculations as necessary.


**_Update:_** _[Resolved in pull #675](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/675/files)_ _[at commit cde91fc.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/cde91fc96590df2248eb719828a9f2613ec360b0)_

### **L-03 Encoding Ambiguity in ct_num_bits** **Function**


According to the comment of the <u><mark>`[ct_num_bits](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L189)`</mark></u> function, it returns the minimum number of

bits required to encode a given number. Currently, it returns `0` for the number `0` . However, in

practical encoding scenarios, a minimum of **one bit** is necessary to represent any number,

including `0` . Returning `0` bits for the number `0` may introduce ambiguity or errors in systems

that expect at least one bit to represent valid numbers. Consider revising the function to ensure

it returns at least one bit for all inputs.


**_Update:_** _[Resolved in pull #681](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/681/files)_ _[at commit e36c292.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/e36c29291f83f50de65ad365363ee687b90a761e)_


Stylus Contracts Library v0.2.0 Audit − Low Severity − 12


### **L-04 Absence of Overflow Check in** **from_str_hex Function**

The <u><mark>`[from_str_hex](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L745)`</mark></u> function does not include an overflow check when parsing hexadecimal

strings into a <mark>`Uint<LIMBS>`</mark> type. This omission may result in an unexpected index out-of
bounds panic if the input string represents a number exceeding the capacity of the

<mark>`Uint<LIMBS>`</mark> type. In contrast, the <mark>`from_str_radix`</mark> [function incorporates an overflow](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L722)

<u>[check](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L722)</u> within the <u><mark>`[ct_add](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L393)`</mark></u> function, ensuring that overflow conditions are explicitly detected

and trigger a panic with a clear error message.


Consider implementing an overflow check in the <mark>`from_str_hex`</mark> function to enhance its

robustness.


**_Update:_** _[Resolved in pull #673](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/673/files)_ _[at comit a988e2b.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/a988e2bdd9f1e86b9dd8fcf8a5bc77c3b6ef16e6)_

### **L-05 Underlying Decimals in Erc20Wrapper Can** **Be Set Incorrectly**


The <mark>`Erc20Wrapper`</mark> [contracts set the underlying token address](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts/src/token/erc20/extensions/wrapper.rs#L313) during construction but do

not set the <u><mark>`[underlying_decimals](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts/src/token/erc20/extensions/wrapper.rs#L119)`</mark></u> storage field from the decimals of the underlying token.

[The underlying decimals must then be set manually, which can lead to critical errors in token](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/examples/erc20-wrapper/src/lib.rs#L32)

functionality if the decimals are set incorrectly. Consider assigning the

<mark>`underlying_decimals`</mark> field in the constructor using the <mark>`decimals`</mark> of the underlying

token, or including checks to ensure the assigned values are equal.


**_Update:_** _[Resolved in pull request #699](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/699)_ _[at commit add8075.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/add8075907ef95e57ef0dd1e04c275fb31abc504)_

### **L-06 State Mutability Can Be Restricted in** **IErc4626**


The <mark>`IErc4626`</mark> trait currently marks several methods with <u><mark>`[&mut self](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts/src/token/erc20/extensions/erc4626.rs#L229)`</mark></u> even though they only

need to read contract storage, such as <mark>`total_assets`</mark> <mark>,</mark> <mark>`convert_to_shares`</mark> <mark>,</mark>

<mark>`convert_to_assets`</mark> <mark>,</mark> etc.


By requiring <mark>`&mut self`</mark> on methods that are conceptually read-only, the trait allows

implementations to introduce unintended or malicious state changes. This is because a

developer could override a “read-only” function and write to storage. To preserve expected


Stylus Contracts Library v0.2.0 Audit − Low Severity − 13


invariants and prevent misuse, consider changing the signature of any <mark>`IErc4626`</mark> method that

does not modify state to take <mark>`&self`</mark> rather than <mark>`&mut self`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #698](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/698)_ _[at commit 33b15ed.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/33b15eda8e25dd4aa6c720eac62a31b4c18f31ed)_

### **L-07 Custom Selectors in Trait With** **interface_id Allows Unreachable Patterns**


The <mark>`#[interface_id]`</mark> attribute enables custom selectors to be added to function

signatures in traits via the <u><mark>`[#[selector]](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L28-L29)`</mark></u> attribute. This mirrors the functionality available for

functions within <mark>`#[public]`</mark> implementation blocks in the Stylus SDK. Code that includes

functions with identical selectors in <mark>`#[public]`</mark> blocks yields an unreachable pattern error;

however, this enforcement is not present in traits with the <mark>`#[interface_id]`</mark> <mark>.</mark> Consequently,

it is possible to define traits with the <mark>`#[interface_id]`</mark> attribute that can never be

implemented. To maintain expected programming invariants and reduce developer errors,

consider prohibiting the creation of traits that have duplicate function selectors.


**_Update:_** _[Resolved in pull request #702](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/702)_ _[at commit b68f7ae.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/b68f7aeb8bd1131c103097487fe354cd945841f8)_

### **L-08 Missing Trait Components in Generated** **Code From interface_id Macro**


The <u><mark>`[#[interface_id]](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L15)`</mark></u> macro processes a trait by adding an <mark>`interface_id`</mark> function to

the trait's <u>[re-generated code, maintaining the original content apart from this intentional](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L77-L92)</u>

addition. However, two critical components are omitted:



1.



**Generic bounds are missing:**



The <u><mark>`[ty_generics](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L65)`</mark></u> variable expands only to the generic type name without including bounds.

For example, a trait like <mark>`trait Foo<T: U>`</mark> would expand to <mark>`trait Foo<T>`</mark> <mark>.</mark> This omission

can allow implementers to create contracts with generic types that do not respect the specified

bounds, potentially violating intended invariants.



1.



**<mark>`unsafe`</mark>** **qualifier is lost:**



Rust allows traits to be declared with the <mark>`unsafe`</mark> qualifier, indicating that implementations

may require the use of unsafe features. The loss of this keyword can silently weaken the safety

guarantees intended by the <mark>`unsafe trait`</mark> <mark>,</mark> allowing implementations to compile without the

necessary flag.


Stylus Contracts Library v0.2.0 Audit − Low Severity − 14


When re-generating a trait in the <mark>`interface_id`</mark> macro, it is advisable to include all

declaration components, ensuring that the output precisely replicates the source trait. This

practice prevents implementers from bypassing generic bounds or omitting critical

annotations, thereby preserving both type safety and intended invariants.


**_Update:_** _[Resolved in pull request #705](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/705)_ _[at commit 184bf10.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/184bf10591029b4fc71b3a2e516450031dd4f7c6)_

### **L-09 Potential Vulnerability in Big Integer Library** **to Timing Side-Channel Attacks**


[Certain functions like ct_ge(), ct_gt(), and](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L105) <u>[cmp()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L546C8-L546C11)</u> in the big integer cryptographic library utilize

early returns when comparing values. The use of early returns does not ensure constant-time

execution across all inputs, potentially exposing the library to timing side-channel attacks.

When the input values contain sensitive information, such attacks could enable an attacker to

analyze the execution time to infer details about those values.


Consider accumulating the result and returning it at the end of the loop or using bitwise

operations to ensure constant-time execution.


**_Update:_** _[Resolved in pull #700](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/700)_ _[at commit 7ae1021. The fix reversed the comparison sequence](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/7ae10219469d934998f882aa8a06a0c517f7e1f7)_

_and made the execution time constant._

## **Notes & Additional** **Information**

### **N-01 Consistent Application of the #[must_use]** **Attribute in Merkle Proof Verification Functions**


The <mark>`#[must_use]`</mark> attribute enables developers to annotate a function, ensuring its result is

not ignored. In the Merkle module, the verification function <u><mark>`[verify](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/merkle.rs#L59)`</mark></u> for a single leaf is

annotated with the <mark>`#[must_use]`</mark> attribute. However, the verification function

<u><mark>`[verify_multi_proof](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/merkle.rs#L128)`</mark></u> for multiple leaves lacks this annotation, potentially leading to

inconsistent usage.


Stylus Contracts Library v0.2.0 Audit − Notes & Additional Information − 15


Consider applying the <mark>`#[must_use]`</mark> attribute consistently to both functions or documenting

the difference.


**_Update:_** _[Resolved in pull #708](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/708)_ _[at commit a15df81.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/a15df81a30c6d8f335068082831b53eb76850768)_

### **N-02 Redundant Attribute in the adc Function**


The <u><mark>`[adc](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs#L86)`</mark></u> <u>[function](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs#L86)</u> includes a function-level attribute,

<mark>`#[allow(clippy::cast_possible_truncation)]`</mark> <mark>.</mark> However, a file-level attribute at the

<u>[top of the file](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs#L5)</u> already applies this setting across the entire file, rendering the function-level

attribute redundant. It is recommended to remove the function-level attribute from the <mark>`adc`</mark>

function to enhance code clarity and maintainability.


**_Update:_** _[Resolved in pull #706](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/706)_ _[at commit 19974a9.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/19974a99892a5152656c55b7a2862f1342d48d83)_

### **N-03 Absence of #[inline(always)] Attributes** **in Certain Methods**


Several <mark>`Uint`</mark> methods, including <u><mark>`[ct_lt](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L152)`</mark></u> <mark>,</mark> <u><mark>`[ct_is_zero](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L167)`</mark></u> <mark>,</mark> and <u><mark>`[ct_eq](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L173)`</mark></u> <mark>,</mark> lack the

<mark>`#[inline(always)]`</mark> attribute, in contrast to similar methods such as <u><mark>`[ct_ge](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L105)`</mark></u> <mark>,</mark> <u><mark>`[ct_gt](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L121)`</mark></u>, and

<u><mark>`[ct_le](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/uint.rs#L137)`</mark></u> <mark>.</mark> These methods are likely employed in performance-critical contexts. Applying the

<mark>`#[inline(always)]`</mark> attribute would ensure consistent inlining behavior, minimize function

call overhead, and enhance performance. Consider adding the <mark>`#[inline(always)]`</mark>

attribute to these methods.


**_Update:_** _[Resolved in pull #707](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/707)_ _[at commit 80402e2.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/80402e2a7d220ca0ecfb72b41e1fdc257410dce9)_

### **N-04 Incorrect Comment in PartialEq** **Implementation for Projective Points**


[The comment](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/curve/sw/projective.rs#L69) for the <mark>`PartialEq`</mark> implementation of <mark>`Projective`</mark> points states that points

<mark>`(X, Y, Z)`</mark> and <mark>`(X', Y', Z')`</mark> are equal when <mark>`(X * Z^2) = (X' * Z'^2)`</mark> and <mark>`(Y *`</mark>

<mark>`Z^3) = (Y' * Z'^3)`</mark> <mark>.</mark> However, the implementation verifies

<mark>`(X * Z'^2) = (X' * Z^2)`</mark> and <mark>`(Y * Z'^3) = (Y' * Z^3)`</mark> <mark>,</mark> which is correct. The

comment is inaccurate because it fails to reflect the correct order of operations in the

implementation. Consider revising the comment.


**_Update:_** _[Resolved in pull #711](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/711)_ _[at commit 12adbbc.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/12adbbcad1c48a7f007725e5e6d9f920f8f06a5d)_


Stylus Contracts Library v0.2.0 Audit − Notes & Additional Information − 16


### **N-05 Source Code Attribution Concerns**

Certain components of the library, such as the curve module, which incorporates code derived

from <u>[algebra/ec, and the field module, which utilizes code from](https://github.com/arkworks-rs/algebra/blob/master/ec/src/models/short_weierstrass/affine.rs#L220)</u> <u>[algebra/ff, include portions of](https://github.com/arkworks-rs/algebra/tree/master/ff/src/fields/models/fp)</u>

code from external codebases without proper attribution. It is recommended to include

references to the original codebases within the code comments to ensure proper attribution.


**_Update:_** _[Resolved at pull #712](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/712)_ _[at commit eaa0ba2.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/eaa0ba2af0677ed7121184f5f79a7dbb736581f9)_

### **N-06 Documentation Enhancements**


Two opportunities for enhancing documentation were identified within the codebase:







[The absorb function enforces](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L95) that the mode is set to <mark>`Absorbing`</mark> <mark>.</mark> However, the

<u>[squeeze function](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L165)</u> permits the mode to remain <mark>`Absorbing`</mark> <mark>,</mark> without a reciprocal check

to ensure the mode is <mark>`Squeezing`</mark> <mark>.</mark> This behavior is correct, as the function should

remain in <mark>`Squeezing`</mark> mode until reinitialized.



To enhance clarity, consider adding a comment to the <u>[absorb function:](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L95)</u> _"Transitions from_

_Absorbing to Squeezing mode are unidirectional."_ This comment emphasizes that once in

<mark>`Squeezing`</mark> mode, returning to <mark>`Absorbing`</mark> mode is not possible, thereby justifying the <u>[if-](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L96-L98)</u>

<u>[condition. Similarly, consider adding a comment to the](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L96-L98)</u> <u>[squeeze function:](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L164)</u> _"When invoked from_

_Absorbing mode, this function triggers a permutation and transitions to Squeezing mode."_







The Poseidon2 implementation forms part of a low-level library, providing foundational

components for constructing a complete hash function. Consequently, high-level

functionalities, such as padding, domain separation, and absorb/squeeze transitions, are

the responsibility of the library user.



To clarify this, consider amending the documentation with a statement such as: _"This interface_

_does not implement padding or domain separation. Users are responsible for padding inputs,_

_prepending domain separation tags, and managing absorb/squeeze transitions."_


Consider implementing the recommended documentation enhancements to improve clarity

and usability.


**_Update:_** _[Resolved in pull #710](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/710/files)_ _[at commit eb72ebc.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/eb72ebc1df99a19cfe5c3c2f18beaad8f0d840f7)_


Stylus Contracts Library v0.2.0 Audit − Notes & Additional Information − 17


### **N-07 Inconsistent Behavior of Shift Overflow** **Compared to Rust Native Integer Types**

As specified in Rust <u>[RFC 560, for a type of width](https://rust-lang.github.io/rfcs/0560-integer-overflow.html#arithmetic-operations-with-error-conditions)</u> `N` (for example, <mark>`u32`</mark> where <mark>`N = 32`</mark> ), if the

right-hand operand (shift amount) is greater than or equal to `N`, it is masked to

<mark>`shift_amount % N`</mark> <mark>.</mark> This ensures the effective shift amount remains within the valid range.

For example:









Shifting <mark>`1u32 << 32`</mark> is equivalent to <mark>`1u32 << 0`</mark> (since <mark>`32 % 32 = 0`</mark> ), resulting in

`1` .


Shifting <mark>`1u32 << 33`</mark> is equivalent to <mark>`1u32 << 1`</mark> (since <mark>`33 % 32 = 1`</mark> ), resulting in

`2` .



However, the implementation of the <u><mark>`[shr_assign](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/2350766c0c03527aedea04e2bffb8f1eb2d01aeb/lib/crypto/src/arithmetic/uint.rs#L655)`</mark></u> and <u><mark>`[shl_assign](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/2350766c0c03527aedea04e2bffb8f1eb2d01aeb/lib/crypto/src/arithmetic/uint.rs#L696)`</mark></u> functions returns <mark>`Zero`</mark>

for overflow shifts. This behavior is inconsistent with the default operation of native integer shift

operations in Rust. Consider aligning the implementation with Rust's native behavior to ensure

consistency and predictability.


**_Update:_** _[Resolved in pull #658](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/658)_ _[at commit c38b883. The shift operation will revert for shift](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/c38b883d9a3b34890e560806e3d06e458f6501a1)_

_overflow._

### **N-08 Misleading Documentation**


The <mark>`#[interface_id]`</mark> [procedural macro is described as adding an associated constant [1,](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L75-L76)

<u>[2], but it is actually added as a](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L14)</u> <u>[function. Consider correcting this comment to reflect accurate](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts-proc/src/interface_id.rs#L84)</u>

behavior.


**_Update:_** _[Resolved partially in pull request #705](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/705)_ _[at commit 184bf10](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/184bf10591029b4fc71b3a2e516450031dd4f7c6)_ _[and partially in pull request](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/702)_

_<u>[#702](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/702)</u>_ _[at commit b68f7ae.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/b68f7aeb8bd1131c103097487fe354cd945841f8)_

### **N-09 Typographical Errors**


Throughout the codebase, the following typographical errors were identified:









The variable <mark>"</mark> <u><mark>`[underline_token](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts/src/token/erc20/extensions/wrapper.rs#L347)`</mark></u> <mark>"</mark> should be renamed to <mark>"</mark> <mark>`underlying_token`</mark> <mark>.</mark> "


The test " <u><mark>`[prevents_non_onwers_from_transferring](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts/src/access/ownable.rs#L271)`</mark></u> <mark>"</mark> should be renamed to

"prevents_non_owners_from_transferring."


Stylus Contracts Library v0.2.0 Audit − Notes & Additional Information − 18


[In line 111](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/5ed33dd88c3d74a0d0ec6cc0ff53f55a36a74c48/contracts/src/access/control.rs#L111) of <mark>`contracts/src/access/control.rs`</mark> <mark>,</mark> the comment should say, "The

caller of a function..."



Consider correcting these errors and any others within the codebase to improve overall clarity.


**_Update:_** _[Resolved in pull request #709](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/709)_ _[at commit 917b9e2.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/917b9e2723623d870da3f4fe7df2c905670bebdc)_

### **N-10 Insufficient Unit Test Coverage**


Certain parts of the codebase lack adequate unit tests. For example, the crypto arithmetic

<u>[limb.rs](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/arithmetic/limb.rs)</u> module does not exercise all of its functions. Consider increasing test coverage to

ensure correctness across edge cases.


**_Update:_** _Acknowledged, will resolve. The team stated:_


_We will improve test coverage both on crypto and contracts part this during our_

_Milestone 3._

## **Recommendations**

### **Recommendations**









**Check for Poseidon2 S-box Invertibility** : Add a check <mark>`gcd(P::D, F::MODULUS - 1)`</mark>

<mark>`== 1`</mark> in the <u><mark>`[new()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L46)`</mark></u> function to ensure the invertibility of the S-box mapping

<mark>`f(x)=x^D`</mark> <mark>.</mark>


**Enforce Even Number of Full Rounds and Minimal Number of Rounds in Poseidon2** :

According to the <u>[Poseidon2 paper, the total number of full rounds must be an even](https://eprint.iacr.org/2023/323)</u>

number. The current implementation <u>[assumes](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/a67ab7068ac94a5a1ad48ae632050c8d28f9ab25/lib/crypto/src/poseidon2/mod.rs#L68)</u> this condition is met. Consider adding a

check to ensure that this requirement is enforced. Also, a <u>[minimal number of rounds](https://extgit.isec.tugraz.at/krypto/hadeshash/-/blob/b5434fd2b2785926dd1dd386efbef167da57c064/code/calc_round_numbers.py)</u>

must be done to achieve the required security parameter.


Stylus Contracts Library v0.2.0 Audit − Recommendations − 19


## **Conclusion**

The Contracts for Stylus library has been upgraded to leverage the latest Stylus SDK and now

offers a richer, more user-friendly feature set. Notably, it adds a fully integrated ERC-4626 vault

for ERC-20 tokens—an essential building block for DeFi applications—and expands ERC-1155

support with burnable extensions, metadata URI management, and supply controls,

addressing growing NFT use cases. These enhancements significantly broaden the library’s

applicability and demonstrate a clear, well-organized code structure.


The Crypto Library offers a comprehensive suite of cryptographic utilities across six modules,

designed for secure and efficient blockchain applications. It features a generic hash module for

producing larger-size outputs, a merkle module for efficient Merkle proof verification, and an

arithmetic module for safe big integer operations. Additionally, the curve module enables

elliptic curve operations with affine and projective representations, while the field module

supports finite field arithmetic computations. The Poseidon2 and Pedersen modules provide

fast, blockchain-optimized hash functions, tailored for zero-knowledge proofs.


The audit identified one high-severity issue and two medium-severity issues, along with several

low-severity findings and general notes across the contracts and crypto library scopes. To

maintain robust security and feature integrity, regular audits are strongly recommended

whenever major library updates are introduced. Continued development and iteration will

further strengthen the library's utility and contribution to the Arbitrum Stylus ecosystem.


Stylus Contracts Library v0.2.0 Audit − Conclusion − 20


