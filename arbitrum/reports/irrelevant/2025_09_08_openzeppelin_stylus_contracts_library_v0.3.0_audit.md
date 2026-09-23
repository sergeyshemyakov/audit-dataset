### | security

# **Stylus Contracts** **Library v0.3.0** **Audit**

#### **September 8, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Security Model and Trust Assumptions _______________________________________________  5


High Severity ______________________________________________________________________  7

H-01 Incorrect Bandersnatch and Jubjub Curve Parameters 7


Medium Severity ___________________________________________________________________  8

M-01 Inadequate Byte Padding in ruint to Uint Conversion 8

M-02 Incorrect Limb Number Check in into_u128 8

M-03 Zeroization of ExpandedSecretKey Is Incomplete 9

M-04 Potential Signature Malleability in p256_verify Precompile Wrapper 9


Low Severity ____________________________________________________________________ 10

L-01 Incorrectly Indexed Parameters in AdminChanged Event 10

L-02 Incorrect Transformation for Projective Points with Zero z-coordinate in normalize_batch 10

L-03 Insufficient Solution for the Immutable Implementation Address in UUPS 11

L-04 allowance Function Returns Zero for Non-Existent Tokens or Contracts with Fallbacks 12

L-05 *_relaxed Functions Behave Differently From the Solidity Library 12


Notes & Additional Information ____________________________________________________ 13

N-01 Panic When Converting Projective with a Zero z-coordinate to Affine 13

N-02 Unimplemented values Function with start and end Parameters 14

N-03 Inconsistent Use of Public Key in EdDSA 14

N-04 Missing Checks for Equality of Scalar and WideScalar in EdDSA 14

N-05 Missing Gas Consumption Warning for Enumerable Functions 15

N-06 Typographical Error in EdDSA Error Message 15

N-07 Missing Validation on MSB of y in CompressedPointY 15


Conclusion ______________________________________________________________________ 17


Stylus Contracts Library v0.3.0 Audit − Table of Contents − 2


## **Summary**

**Type** Library


**Timeline** From 2025-08-11
To 2025-08-29


**Languages** Rust



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


1 (1 resolved)


4 (4 resolved)



**Total Issues** 17 (17 resolved)



**Low Severity Issues** 5 (5 resolved)



**Notes & Additional**
**Information**



7 (7 resolved)



Stylus Contracts Library v0.3.0 Audit − Summary − 3


## **Scope**

[OpenZeppelin audited the OpenZeppelin/rust-contracts-stylus](https://github.com/OpenZeppelin/rust-contracts-stylus) library at commit <u>[231d4f1](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf)</u>

( <mark>`v0.3.0-rc.1`</mark> <mark>)</mark> [. This is a follow-up audit after the v0.2.0 audit, focusing on the refactors and](https://blog.openzeppelin.com/stylus-contracts-library-v0.2.0-audit)

newly added features.


In scope are all the changes made in the following directories:

```
├── contracts/**/*.rs
├── contracts-proc/src/**/*.rs
└── lib/crypto/src/**/*.rs

```

The pull requests containing the in-scope changes are listed <u>[here.](https://github.com/orgs/OpenZeppelin/projects/35/views/9)</u>


Stylus Contracts Library v0.3.0 Audit − Scope − 4


## **System Overview**

The changes under review introduce a series of improvements, including breaking changes,

new features, and important bug fixes that expand the library's scope and usability.


On the contracts side, the library adds support for <mark>`ERC721Holder`</mark> and <mark>`ERC1155Holder`</mark> <mark>,</mark>

enabling safer and more standardized handling of token transfers in Stylus-based applications.

The release also introduces native support for the UUPS upgradability pattern, aligning the

library with widely adopted upgrade standards and making proxy-based upgrade flows more

flexible. Furthermore, the update extends the <mark>`EnumerableSet`</mark> utility with generic type

support, allowing developers to work with sets of more complex data types beyond basic

primitives.


On the cryptography side, the library adds a precompile wrapper for <mark>`secp256r1`</mark> (P-256)

signature verification, leveraging Arbitrum’s native precompile to enable efficient and gas
optimized verification of modern authentication schemes such as passkeys. Complementing

this, the update also introduces support for <mark>`Ed25519`</mark> (EdDSA) signatures, broadening the

available cryptographic primitives for Stylus contracts.


Additionally, the release enhances interoperability between Solidity-style unsigned integers and

Rust primitive integers by introducing conversion functions that explicitly handle 64-bit and

128-bit integer sizes, thereby improving low-level arithmetic compatibility. The addition of more

documentation and tests further enhances the library's robustness.


Overall, these updates make the OpenZeppelin Stylus library significantly more robust, feature
complete, and aligned with modern Ethereum and Arbitrum standards. The codebase appears

to be well-documented, with all the changes organized neatly.

## **Security Model and Trust** **Assumptions**


This audit assumes that the Stylus SDK and all third-party dependencies used by the audited

library are secure and behave as documented. Users of the audited library are assumed to


Stylus Contracts Library v0.3.0 Audit − System Overview − 5


strictly follow the API descriptions, warnings, and examples to avoid potential errors.

Especially, the following assumptions apply:









Users of the UUPS proxy will adhere to the upgrade guidelines, properly initializing the

proxy and incrementing the version number in new implementations.

The signing functions of <mark>`Ed25519`</mark> signatures should only be used in an off-chain

environment, with the <mark>`ExpandedSecretKey`</mark> data kept confidential.


Stylus Contracts Library v0.3.0 Audit − Security Model and Trust

Assumptions − 6


## **High Severity**

### **H-01 Incorrect Bandersnatch and Jubjub Curve** **Parameters**

The <u><mark>`[bandersnatch.rs](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/instance/bandersnatch.rs)`</mark></u> file defines the Bandersnatch elliptic curve parameters, but several

constants do not match the standard specification from the <u>[referenced paper.](vscode-file://vscode-app/usr/share/code/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html)</u>


For example, the generator point coordinates <u><mark>`[G_GENERATOR_X](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/instance/bandersnatch.rs#L15-L16)`</mark></u> <u>[and](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/instance/bandersnatch.rs#L15-L16)</u> <u><mark>`[G_GENERATOR_Y](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/instance/bandersnatch.rs#L15-L16)`</mark></u> do not

match the standard subgroup generator. The current values are:

```
x = 19232933407424889111104940496320988988172100217998297030544530116054238325480
y = 17060630597514316424753713474449400526842970574619404045211133826199305117375

```

However, the standard values are:

```
x = 0x29c132cc2c0b34c5743711777bbe42f32b79c022ad998465e1e71866a252ae18
y = 0x2a6c669eda123e0f157d8b50badcd586358cad81eee464605e3167b6cc974166

```

In addition, there are internal inconsistencies among the defined values. For example, the

<u><mark>`[COFACTOR](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/instance/bandersnatch.rs#L46)`</mark></u> is correctly set to 4, but the cofactor inverse <u><mark>`[COFACTOR_INV](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/instance/bandersnatch.rs#L47)`</mark></u> appears to be

incorrect, since:

```
4 * 9820571595336158597396451345284868594481866920080427688839802480047265754601 ≠ 1 mod
r
r = 13108968793781547619861935127046491459309155893440570251786403306729687672801

```

The correct inverse should be

<mark>`9831726595336160714896451345284868594481866920080427688839802480047265754601`</mark> <mark>.</mark>


A similar issue also exists in the <u><mark>`[jubjub.rs](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/instance/jubjub.rs)`</mark></u> file. For example, the scalar field modulus

( <mark>`Fr::MODULUS`</mark> <mark>)</mark> is set to

<mark>`723700557733226221397318656304299424085711635937990760600195093828545425857`</mark> <mark>,</mark>

which is not the standard prime subgroup order.


Consider revising these parameters to be consistent and meet the standard specification.


**_Update:_** _[Resolved in pull #809](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/809)_ _[and merged at commit 7c7fda9. The team corrected the](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/7c7fda95a6b4f670662f19d3ff404be05388c46a)_

_parameters and added more test cases._


Stylus Contracts Library v0.3.0 Audit − High Severity − 7


## **Medium Severity**

### **M-01 Inadequate Byte Padding in ruint to Uint** **Conversion**

The <u><mark>`[From<ruint::Uint<B, L>> for Uint<L>](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L606-L611)`</mark></u> implementation contains a potential

unexpected panic due to insufficient byte padding during type conversion. The conversion

process involves two steps:



1.

2.



Converting <u><mark>`[ruint::Uint<B, L>](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L606-L611)`</mark></u> to little-endian bytes via <u><mark>`[to_le_bytes_vec()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L608)`</mark></u>

Creating a new <u><mark>`[Uint<L>](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L606-L611)`</mark></u> from those bytes using <u><mark>`[from_bytes_le()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L609)`</mark></u>



While <u><mark>`[ruint::Uint<B, L>](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L606-L611)`</mark></u> **allows** <mark>`B <= L*64`</mark> (ensuring all bits can fit within the limbs),

the <u><mark>`[to_le_bytes_vec()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L608)`</mark></u> function returns exactly <mark>`ruint::Uint::BYTES`</mark> bytes. However,

<u><mark>`[from_bytes_le()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L609)`</mark></u> expects **exactly** <mark>`Uint::BYTES`</mark> bytes and will panic if the byte count

does not match, even with enough space (limbs) to hold the bits. For example, the

<u><mark>`[to_le_bytes_vec](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L608)`</mark></u> function produces a 200-byte vector for <u><mark>`[ruint::Uint<200, 4>](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L606-L611)`</mark></u> <mark>,</mark> but

<u><mark>`[Uint<4>::from_bytes_le()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L609)`</mark></u> expects 256 bytes, causing a panic despite having sufficient

limb capacity.


Consider padding the bytes returned from <u><mark>`[to_le_bytes_vec](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L608)`</mark></u> if they are shorter than <mark>`L*64`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull #808](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/808)_ _[and merged at commit a53fac4.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/a53fac40ec1da3e114400284c7e4b247de0b0f6e)_

### **M-02 Incorrect Limb Number Check in** **`into_u128`**


The <u><mark>`[into_u128](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/arithmetic/uint.rs#L572)`</mark></u> method requires access to two limbs <mark>(</mark> <mark>`self.limbs[0]`</mark> and

<mark>`self.limbs[1]`</mark> <mark>)</mark> to construct a <mark>`u128`</mark> value, but only checks that <mark>`N >= 1`</mark> . This allows the

method to be called on <mark>`U64`</mark> types, which will panic when attempting to access the non
existent second limb, causing an index-out-of-bounds panic. In addition, converting an

unsigned integer with 64 bits to a <mark>`u128`</mark> value should be allowed and should always succeed.


Consider revising the logic in the <mark>`into_u128`</mark> method to only access <mark>`limbs[1]`</mark> if the <mark>`Uint`</mark>

variable has more than or equal to 2 limbs. For the <mark>`U64`</mark> type, the highest 64 bits of <mark>`u128`</mark>

should be set to zero.


**_Update:_** _[Resolved in pull #815](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/815)_ _[and merged at commit 7777e3d.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/7777e3df5ac43a4f7d927bed7177c4971cf47e77)_


Stylus Contracts Library v0.3.0 Audit − Medium Severity − 8


### **M-03 Zeroization of ExpandedSecretKey Is** **Incomplete**

The <u><mark>`[ExpandedSecretKey](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L86)`</mark></u> struct in <u><mark>`[eddsa.rs](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L1)`</mark></u> holds secret material (the signing scalar and

the hash prefix). It is intended to be zeroized on drop via the <mark>`zeroize`</mark> crate:


Instances of this secret are automatically overwritten with zeroes when they fall out of

scope.


However, the current design is ineffective: the type is marked <mark>`Copy`</mark> <mark>,</mark> which is not allowed for

types with destructors, so a custom <mark>`Drop`</mark> (or <mark>`Zeroize`</mark> <mark>/</mark> <mark>`ZeroizeOnDrop`</mark> <mark>)</mark> cannot be used.

Moreover, implementing the <mark>`ZeroizeOnDrop`</mark> trait alone does nothing without deriving

<mark>`Zeroize`</mark> and enabling the drop hook. As a result, no on-drop zeroization occurs, and secrets

can remain in memory. The code also risks the silent duplication of secrets due to <mark>`Copy`</mark> .


In contrast, <u><mark>`[ed25519-dalek](https://github.com/dalek-cryptography/curve25519-dalek/blob/c3f91f762042debf7c516c21ad9b9a2a9f4ef3b8/ed25519-dalek/src/hazmat.rs)`</mark></u> uses a destructor drop to ensure proper zeroization.


Consider removing <mark>`Copy`</mark> and using <mark>`Zeroize`</mark> and <mark>`ZeroizeOnDrop`</mark> with the derive macro.


**_Update:_** _[Resolved in pull #831](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/831)_ _[and merged at commit aafb627.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/aafb62751f4323a6f367a3af975d967b82407c69)_

### **M-04 Potential Signature Malleability in** **p256_verify Precompile Wrapper**


The spec of the <mark>`P256VERIFY`</mark> EVM precompile requires <u>[two checks to be implemented:](https://github.com/ethereum/RIPs/blob/master/RIPS/rip-7212.md#required-checks-in-verification)</u>









Verify that the `r` and `s` values are in <mark>`(0, n)`</mark> (exclusive) where `n` is the order of

the subgroup.

Verify that the point formed by <mark>`(x, y)`</mark> is on the curve and that both `x` and `y`

are in <mark>`[0, p)`</mark> (inclusive 0, exclusive p) where `p` is the prime field modulus. Note

that many implementations use <mark>`(0, 0)`</mark> as the reference point at infinity, which

is not on the curve and should therefore be rejected.



Notably, the spec does not enforce low- `s` values for ECDSA signatures on secp256r1,

allowing malleability where <mark>`(r, s)`</mark> and <mark>`(r, n - s)`</mark> are both valid.


The <u><mark>`[p256_verify](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/utils/precompiles/p256_verify.rs#L22)`</mark></u> function is a thin wrapper around the precompile and does not enforce

low- `s` normalization either. This can lead to practical issues such as replay or duplicate

processing in systems relying on signature uniqueness (e.g., nonce-based flows), potentially

enabling unauthorized actions or other unexpected results.


Stylus Contracts Library v0.3.0 Audit − Medium Severity − 9


Consider adding a check ( <mark>`s <= n/2`</mark> <mark>)</mark> before invoking the precompile, as is done in the

Solidity <u>[library.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d183d9b07a6cb0772ff52aa4e3e40165e99d6359/contracts/utils/cryptography/P256.sol#L91)</u>


**_Update:_** _[Resolved in pull #825](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/825)_ _[and merged at commit 7c04df8.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/7c04df852c9cf45774ce9778ff9878f726f0c4c8)_

## **Low Severity**

### **L-01 Incorrectly Indexed Parameters in** **AdminChanged Event**


According to the <u>[EIP-1967, changes to the admin slot should be notified by the](https://eips.ethereum.org/EIPS/eip-1967)</u>

<mark>`AdminChanged`</mark> event, which is defined as:

```
event AdminChanged(address previousAdmin, address newAdmin);

```

Both the <mark>`previousAdmin`</mark> and <mark>`newAdmin`</mark> parameters are not marked as <mark>`indexed`</mark>, which

means that they will be stored in the log data field and not as separate topics. The <u><mark>`[IERC1967](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/448538259f1feeb24f3e3201115d70818ba876cb/contracts/interfaces/IERC1967.sol#L18)`</mark></u>

<u>[interface](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/448538259f1feeb24f3e3201115d70818ba876cb/contracts/interfaces/IERC1967.sol#L18)</u> from the OpenZeppelin Contracts library follows this standard.


However, in the Stylus <u>[ERC-1967](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/proxy/erc1967/mod.rs#L33)</u> <u><mark>`[mod.rs](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/proxy/erc1967/mod.rs#L33)`</mark></u> file, both parameters have been marked as

<mark>`indexed`</mark> <mark>,</mark> which means that they will be stored as separate topics. While this does not pose a

direct security threat, the inconsistent logging behavior may cause issues for users, particularly

off-chain entities that parse emitted logs.


Consider removing the <mark>`indexed`</mark> keyword to ensure consistency with the standard.


**_Update:_** _[Resolved in pull #794](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/794)_ _[and merged at commit f3bb0e4.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/f3bb0e481412c4ce5d3b2b83180313526bbb55a3)_

### **L-02 Incorrect Transformation for Projective** **Points with Zero z-coordinate in** **`normalize_batch`**


The <u><mark>`[normalize_batch](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/projective.rs#L208)`</mark></u> function normalizes multiple curve points to their affine

representations with the <mark>`(x, y, t, z) -> (x/z, y/z, t/z, 1)`</mark> conversion. To get

inversion <mark>`1/z`</mark> value, it first calls the <u><mark>`[batch_inversion](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/mod.rs#L253)`</mark></u> function, which leaves zero `z`

elements unchanged, so any <mark>`g.z == 0`</mark> in the input remains zero after inversion.


Stylus Contracts Library v0.3.0 Audit − Low Severity − 10


During the affine transformation step later, the code checks <mark>`g.is_zero()`</mark> to decide whether

to return <mark>`Affine::zero()`</mark> <mark>.</mark> However, since <mark>`g.is_zero()`</mark> returns false when <mark>`g.z == 0`</mark>

for the Twisted Edwards curve, the code proceeds to compute <mark>`x = g.x * z`</mark> and <mark>`y = g.y`</mark>

<mark>`* z`</mark> <mark>,</mark> which results in <mark>`(0, 0)`</mark> for the affine point. This is not a valid affine representation and

may lead to incorrect results in downstream cryptographic operations.


Consider updating the affine transformation logic in <mark>`normalize_batch`</mark> to check for

<mark>`g.z.is_zero()`</mark> situations.


**_Update:_** _[Resolved in pull #817](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/817)_ _[and merged at commit bb3720a.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/bb3720a6a3382adb94bfab34d3eb1b8effc014f6)_

### **L-03 Insufficient Solution for the Immutable** **Implementation Address in UUPS**


[The standard UUPS upgradability pattern in Solidity](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/005c9c9fa76a803c07f843fb4780e78b954b37af/contracts/proxy/utils/UUPSUpgradeable.sol#L21) uses an immutable variable to store the

implementation’s (i.e., the logic contract's) deployed address. In <u><mark>`[_checkProxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/005c9c9fa76a803c07f843fb4780e78b954b37af/contracts/proxy/utils/UUPSUpgradeable.sol#L98)`</mark></u> <mark>,</mark> this

immutable value is compared with the implementation address stored in the proxy to

determine whether the current implementation is correct.


Since Stylus cannot handle immutable variables, there is no way to embed a variable into the

implementation’s code at deploy time. The current workaround in <u><mark>`[only_proxy](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/proxy/utils/uups_upgradeable.rs#L237)`</mark></u> is to save the

implementation address directly in the Proxy’s storage and use it for comparison with the

current contract address. However, this solution is insufficient: by storing the address directly

in the Proxy’s storage and comparing it against the Proxy’s own storage, it defeats the purpose

of the check. This could lead to issues, such as failing to detect whether the current call is

using the correct implementation.


Consider improving the <mark>`only_proxy`</mark> design by taking the following measures:










Introduce a variable <mark>`logic_flag`</mark> in the implementation’s storage to indicate that the

current storage belongs to the implementation, while leaving the Proxy’s storage

uninitialized for this variable. This variable is checked to ensure the context is in a

delegate call.

Check that the ERC-1967 slot is not empty to ensure that it is a 1967 proxy.

Maintain a <mark>`version_number`</mark> variable both in the Proxy’s storage and in the

implementation code ( <mark>`const`</mark> <mark>,</mark> i.e., not in the implementation’s storage). Keeping these

values in sync allows for comparing the implementation code and the Proxy’s storage to

verify that the current version is correct.



**_Update:_** _[Resolved in pull #810](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/810)_ _[and merged at commit 4c8275a.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/4c8275a1fc995054021855076ed3421cdbb15e4f)_


Stylus Contracts Library v0.3.0 Audit − Low Severity − 11


### **L-04 allowance Function Returns Zero for Non-** **Existent Tokens or Contracts with Fallbacks**

The <mark>`allowance`</mark> function is called by <u><mark>`[safe_increase_allowance](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/token/erc20/utils/safe_erc20.rs#L410)`</mark></u> and

<u><mark>`[safe_decrease_allowance](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/token/erc20/utils/safe_erc20.rs#L423)`</mark></u> to read the current allowance of the <mark>`spender`</mark> <mark>.</mark> [In pull request](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/765/files)

<u>[#765, the](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/765/files)</u> <mark>`Address::has_code(&token)`</mark> check in <mark>`allowance`</mark> was removed <u>[with a](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/765/files#r2250692824)</u>

<u>[comment:](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/765/files#r2250692824)</u>


[There's no code check in Solidity. In case of no code, a 0 (zero) is expected as the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/c64a1edb67b6e3f4a15cca8909c9482ad33a02b0/contracts/token/ERC20/utils/SafeERC20.sol#L69)

result


For reference, the Solidity code is <mark>`token.allowance(address(this),`</mark>

<mark>`spender)`</mark> <mark>.</mark>


However, the Solidity compiler performs an existence check before making any high-level calls,

and reverts if the check fails. Such calls also revert if the return data cannot be decoded as

<mark>`uint256`</mark> <mark>.</mark> By contrast, the Stylus implementation decodes empty return data as zero via

<mark>`U256::from_be_slice(&result)`</mark> <mark>.</mark> This creates two inconsistencies with the Solidity

library:









When <mark>`token`</mark> is set to a non-existent address, the Solidity call reverts, while Stylus

returns `0` .

When <mark>`token`</mark> is set to a non-ERC-20 contract that has a fallback function, the Solidity

call reverts, while Stylus returns `0` .



Consider updating <mark>`allowance`</mark> to first check whether <mark>`token`</mark> exists and requires exactly 32

bytes of return data ( <mark>`U256`</mark> <mark>)</mark> .


**_Update:_** _[Resolved in pull #833](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/833)_ _[and merged at commit 0015161. The team added a check to](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/0015161cd508949a5912d9c800f9d10c6ae82466)_

_ensure the_ _<mark>`token`</mark>_ _contract exists and replaced the_ _<mark>`RawCall`</mark>_ _with a high-level call._

### **L-05 *_relaxed Functions Behave Differently** **From the Solidity Library**


The <u><mark>`[transfer_and_call_relaxed](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/token/erc20/utils/safe_erc20.rs#L462)`</mark></u> <mark>,</mark> <u><mark>`[transfer_from_and_call_relaxed](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/token/erc20/utils/safe_erc20.rs#L482)`</mark></u> <mark>,</mark> and

<u><mark>`[approve_and_call_relaxed](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/token/erc20/utils/safe_erc20.rs#L504)`</mark></u> functions invoke the <u><mark>`[call_optional_return](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/token/erc20/utils/safe_erc20.rs#L540)`</mark></u> helper to

call the corresponding function on the <mark>`token`</mark> contract. This helper succeeds if the return data

decodes to <mark>`true`</mark> <mark>,</mark> or if the return data is empty and the <mark>`token`</mark> address has code.


Stylus Contracts Library v0.3.0 Audit − Low Severity − 12


However, this differs from the OpenZeppelin Solidity library, where the corresponding functions

are invoked via high-level calls (e.g., <u><mark>`[token.transferAndCall](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/2ea54a192da8ed7c6d8b02e1da28abd1c4126446/contracts/token/ERC20/utils/SafeERC20.sol#L122)`</mark></u> <mark>)</mark> . In particular, if <mark>`token`</mark> is

mistakenly set to a non-token contract that has a fallback function, the Solidity version reverts

because no boolean return value is provided, while the Stylus <mark>`*_relaxed`</mark> versions succeed.


Consider aligning the Stylus <mark>`*_relaxed`</mark> functions with the Solidity behavior by requiring that

the <mark>`token`</mark> contract exists and that the call returns data decoded to <mark>`true`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull #837](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/837)_ _[and merged at commit 1389d05. The team adds checks to](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/1389d05acf53060400db73bdf0568f943977f562)_

_ensure contracts exist and uses high-level calls._

## **Notes & Additional** **Information**

### **N-01 Panic When Converting Projective with a** **Zero z-coordinate to Affine**


The implementation of <u><mark>`[From<Projective<P>> for Affine<P>](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/affine.rs#L231)`</mark></u> in <u><mark>`[affine.rs](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/affine.rs)`</mark></u> attempts

to convert a projective point to its affine representation by inverting the `z` coordinate. The logic

first checks if the point is the identity ( <u><mark>`[is_zero()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/projective.rs#L131)`</mark></u> <mark>)</mark> and then checks if `z` is one (already

normalized). If it is not, then the logic proceeds to invert `z` . However, for the twisted Edwards

curve, <mark>`is_zero()`</mark> will return <mark>`false`</mark> for a point with a z-coordinate that is 0. After this, the

code assumes the following:


Z is nonzero, so it must have inverse in a field


Then, the code attempts to compute <u><mark>`[p.z.inverse().unwrap()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/curve/te/affine.rs#L242)`</mark></u> <mark>.</mark> Since the inverse of zero

does not exist, this will cause a panic at runtime.


While projective points over Edward’s curves cannot receive Z coordinate as zero during

computations, consider adding an explicit error panic message when <mark>`p.z.is_zero()`</mark> <mark>,</mark> and

revise the comment to make it clear about the panic situation.


**_Update:_** _[Resolved in pull #816](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/816)_ _[and merged at commit ba3da10.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/ba3da105271a71664bd124c70fc2d22385296f5a)_


Stylus Contracts Library v0.3.0 Audit − Notes & Additional Information − 13


### **N-02 Unimplemented values Function with** **start and end Parameters**

[The enumerable set module](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/utils/structs/enumerable_set/mod.rs) does not implement the <mark>`values`</mark> function with <mark>`start`</mark> and <mark>`end`</mark>

parameters. Such a function could reduce gas consumption or mitigate out-of-gas scenarios

when processing large sets.


Consider implementing the <mark>`values`</mark> [function to match the Solidity version](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/448538259f1feeb24f3e3201115d70818ba876cb/contracts/utils/structs/EnumerableSet.sol#L294) of the contract.


**_Update:_** _[Resolved in pull #827](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/827)_ _[and merged at commit 9167016.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/9167016c5bbba0f990feee55cd00a56447dbb4bc)_

### **N-03 Inconsistent Use of Public Key in EdDSA**


In the <mark>`compute_R`</mark> [EdDSA function, the public key is used](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L371) as <mark>`self.point`</mark> even though it

was <u>[stored](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L358)</u> earlier in `A` .


For clarity, consider consistently using `A` as the public key, which is also in accordance with

[the formula](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L370) notation.


**_Update:_** _[Resolved in pull #830](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/830)_ _[and merged at commit 09a048c.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/09a048c7a3725c6654a456bac776d946c7d79965)_

### **N-04 Missing Checks for Equality of Scalar and** **WideScalar in EdDSA**


In the EdDSA implementation, it is critical that during the signing process, the <u><mark>`[Scalar](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L211)`</mark></u> and

<u><mark>`[WideScalar](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L214)`</mark></u> types both reduce their input (the scalar `r` coming from the hash of the prefix

and the message) modulo the scalar field <u><mark>`[MODULUS](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L43)`</mark></u> of the curve. This requirement is currently

satisfied: the implementation correctly reduces values by the scalar field order of Curve25519.


However, a future refactor or upgrade could accidentally introduce a mismatch (i.e., a situation

in which the reduction modulus of <mark>`Scalar`</mark> differs from the reduction modulus of

<mark>`WideScalar`</mark> <mark>)</mark> .


Consider adding an explicit compile-time assertion (e.g., <mark>`assert!`</mark>

<mark>`(Curve25519FrParam::MODULUS == Curve25519Fr512Param::MODULUS)`</mark> <mark>)</mark> to

guarantee that both parameter sets always share the same modulus.


**_Update:_** _[Resolved in pull #834](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/834)_ _[and merged at commit d1f074d. Instead of adding an assertion,](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/d1f074d8acf4efed3b2362e46bb742b564e2679b)_

_the team ensures the_ _<mark>`GENERATOR`</mark>_ _and_ _<mark>`MODULUS`</mark>_ _parameters are the same between curve_

_ed25519 with_ _<mark>`512-bit`</mark>_ _inner integer size and_ _<mark>`256-bit`</mark>_ _size._


Stylus Contracts Library v0.3.0 Audit − Notes & Additional Information − 14


### **N-05 Missing Gas Consumption Warning for** **Enumerable Functions**

The <u><mark>`[clear](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/utils/structs/enumerable_set/mod.rs#L103)`</mark></u> <mark>,</mark> <u><mark>`[values](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/utils/structs/enumerable_set/mod.rs#L157)`</mark></u> <mark>,</mark> and <u><mark>`[get_role_members](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/contracts/src/access/control/extensions/enumerable.rs#L87)`</mark></u> functions iterate over or return all elements

in a set, potentially incurring significant gas costs when the set contains a large number of

elements. This could result in unexpectedly high gas consumption or even a denial-of-service

situation. For reference, the <u>[Solidity version](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/448538259f1feeb24f3e3201115d70818ba876cb/contracts/utils/structs/EnumerableSet.sol)</u> by OpenZeppelin contains relevant comments

about the possibly expensive operations.


Consider incorporating warning documentation for these functions to alert developers

regarding the potential risks.


**_Update:_** _[Resolved in pull #832](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/832)_ _[and merged at commit dc58c6e.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/dc58c6e2366e60aeb1379468a511d9433d5b627c)_

### **N-06 Typographical Error in EdDSA Error** **Message**


[This error message](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L262) in the EdDSA implementation uses an incorrect unit <mark>`bit`</mark> :


.expect("Y coordinate should be of 32 **bit** ").


Since the length of the Y coordinate is 32 **bytes**, consider updating the error message to "Y

coordinate should be 32 bytes" in order to avoid confusion and accurately reflect the expected

size.


**_Update:_** _[Resolved in pull #826](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/826)_ _[and merged at commit b1b0a0c.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/b1b0a0c71f73d2b863594cee7554669f17a9d0db)_

### **N-07 Missing Validation on MSB of y in** **`CompressedPointY`**


In the compressed Edwards-Y encoding, the most significant bit (MSB) is reserved for the x

“sign” (parity), while the lower 255 bits hold y. The current code <u>[uses XOR to set this bit](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/231d4f1ac576c0bb7f513e9a6b6c1dbddcbb75bf/lib/crypto/src/eddsa.rs#L265)</u>

( <mark>`s[31] ^= (is_odd as u8) << 7`</mark> <mark>)</mark>, which depends on y’s MSB being zero. Given the

existing type checks in <mark>`Affine`</mark> <mark>/</mark> <mark>`Projective`</mark> which ensure that points are on-curve and in

the prime-order subgroup, y’s MSB should always be zero, making the current XOR safe.


To further harden the code and fail fast on invalid inputs, consider adding an <mark>`assert!(s[31]`</mark>

<mark>`>> 7 == 0)`</mark> check before the XOR. This preserves correctness for valid inputs and surfaces

malformed points early without requiring a behavioral change to the encoding logic.


Stylus Contracts Library v0.3.0 Audit − Notes & Additional Information − 15


**_Update:_** _[Resolved in pull #835](https://github.com/OpenZeppelin/rust-contracts-stylus/pull/835)_ _[and merged at commit 72f042e. The team added a compile-](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/72f042e261f7fcc146fcef178de65fca2faa0f09)_

_time check to ensure the_ _<mark>`MODULUS`</mark>_ _has a spare bit, which means the Y coordinate will also_

_have a spare bit._


Stylus Contracts Library v0.3.0 Audit − Notes & Additional Information − 16


## **Conclusion**

The Stylus library has been upgraded with support for <mark>`ERC721Holder`</mark> and

<mark>`ERC1155Holder`</mark> <mark>,</mark> improving token-transfer handling, alongside native UUPS upgradability for

flexible proxy upgrades and generic type support in the <mark>`EnumerableSet`</mark> contract for more

data structures. The Crypto Library has been expanded with a precompile wrapper for

<mark>`secp256r1`</mark> signature verification and <mark>`Ed25519`</mark> signature support, enabling efficient and

modern authentication. Additional integer conversion functions for Solidity-style and Rust

integers enhance interoperability. Supported by improved documentation and tests, the library

maintains a clean, well-organized codebase.


The audit identified one high-severity issue, four medium-severity issues, and some low
severity issues. During the audit, the development team was proactive, promptly addressing

any questions posed by the audit team. To ensure ongoing security and functionality, regular

audits are recommended with future updates, fostering continued growth in the Arbitrum Stylus

ecosystem.


Stylus Contracts Library v0.3.0 Audit − Conclusion − 17


