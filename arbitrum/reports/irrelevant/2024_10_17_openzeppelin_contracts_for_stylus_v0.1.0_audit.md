### | security

# **Contracts for** **Stylus Audit**

#### **October 17, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  6

Stylus and Rust SDK 6

OpenZeppelin Contracts for Stylus 6

Main Modules 6

Limitations of the SDK 7


Trust Assumptions _________________________________________________________________  8


Medium Severity ___________________________________________________________________  9

M-01 ERC-721 Does Not Support ERC-165 9


Low Severity ______________________________________________________________________  9

L-01 Incomplete Implementation for checkpoints.rs 9

L-02 Inconsistent Implementations in ERC-721 Extension 10

L-03 Missing Checks in ERC-20 Implementation 10

L-04 Public Exposure of pause and unpause Functions 11

L-05 Inconsistent Function Visibility in Burnable Extension 11

L-06 Inconsistent Implementation Styles 12


Notes & Additional Information ____________________________________________________ 12

N-01 Unaddressed TODOs and FIXMEs 12

N-02 Inconsistent Error Types 13

N-03 Unnecessary Swap Operation 13

N-04 Misleading Reference to Modifiers in Pausable Module 13

N-05 Unused Error Message 14


Conclusion ______________________________________________________________________ 15


Contracts for Stylus Audit − Table of Contents − 2


## **Summary**

**Type** Smart Contract Library


**Timeline** From 2024-08-26
To 2024-10-01


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



**Total Issues** 12 (9 resolved)



**Low Severity Issues** 6 (4 resolved)



**Notes & Additional**
**Information**



5 (4 resolved)



Contracts for Stylus Audit − Summary − 3


## **Scope**

We audited the <u>[OpenZeppelin/rust-contracts-stylus](https://github.com/OpenZeppelin/rust-contracts-stylus)</u> repository at commit <u>[42c859f.](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/42c859f37d7332fbd78a216a283064a5227f9c68)</u>


In scope were the following files:

```
contracts/src
├── access
│  ├── control.rs
│  ├── mod.rs
│  └── ownable.rs
├── lib.rs
├── token
│  ├── erc20
│  │  ├── extensions
│  │  │  ├── burnable.rs
│  │  │  ├── capped.rs
│  │  │  ├── metadata.rs
│  │  │  ├── mod.rs
│  │  │  └── permit.rs
│  │  └── mod.rs
│  ├── erc721
│  │  ├── extensions
│  │  │  ├── burnable.rs
│  │  │  ├── consecutive.rs
│  │  │  ├── enumerable.rs
│  │  │  ├── metadata.rs
│  │  │  ├── mod.rs
│  │  │  └── uri_storage.rs
│  │  └── mod.rs
│  └── mod.rs
└── utils
├── cryptography
│  ├── ecdsa.rs
│  ├── eip712.rs
│  └── mod.rs
├── math
│  ├── alloy.rs
│  ├── mod.rs
│  └── storage.rs
├── metadata.rs
├── mod.rs
├── nonces.rs
├── pausable.rs
└── structs
├── bitmap.rs
├── checkpoints.rs
└── mod.rs
lib/crypto

```

Contracts for Stylus Audit − Scope − 4


```
└── src
├── hash.rs
├── keccak.rs
├── lib.rs
└── merkle.rs

```


Contracts for Stylus Audit − Scope − 5


## **System Overview**

### **Stylus and Rust SDK**

Stylus is an upgrade to Arbitrum Nitro that introduces a second, coequal virtual machine to the

EVM. This allows EVM contracts to function as they do on Ethereum within the first VM, while

the second VM executes Stylus contracts that use WebAssembly (WASM) instead of EVM

bytecode. The WASM code is written in Rust using the Arbitrum Stylus Rust SDK, which is built

on top of <u>[Alloy, a collection of crates designed to empower the Rust Ethereum ecosystem. By](https://www.paradigm.xyz/2023/06/alloy)</u>

leveraging the same <u>[Rust primitives for Ethereum types, the Stylus SDK remains compatible](https://docs.rs/alloy-primitives/latest/alloy_primitives/)</u>

with existing Rust libraries.

### **OpenZeppelin Contracts for Stylus**


The Contracts for Stylus library, the subject of the present audit, has been designed to provide

a foundation for smart contract development on Arbitrum Stylus, closely following the design

and practices of the <u><mark>`[openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)`</mark></u> library for Solidity. It builds upon the Stylus

SDK which is written in Rust. While the initial implementation of the Contracts for Stylus library

is intended to be a port of the Solidity library and not stray too far from the heavily audited

business logic therein, current limitations of the Stylus SDK require some workarounds and

custom features in order to provide the intended functionality. This is primarily due to the fact

that the SDK, and Arbitrum Stylus in general, is still in early stages of development, and the

Contracts for Stylus library team continues to work closely with developers from Arbitrum

Stylus in order to advance both codebases in parallel.

### **Main Modules**


The following are the main modules of the Contracts for Stylus library.


**Access**


This module includes functionality for ownership and role-based access control. The <mark>`Ownable`</mark>

trait allows a contract to designate a single owner with privileged actions, while

<mark>`AccessControl`</mark> enables the creation of multiple roles with specific permissions (e.g., minting


Contracts for Stylus Audit − System Overview − 6


or burning tokens). This allows for flexible and granular access management, enhancing

security and composability across contracts.


**Token**


Provides the implementation for the ERC-20 and ERC-721 token standards along with various

extensions. Extensions for ERC-20 such as Burnable, Capped, Pausable, and Permit add

advanced functionality like destroying tokens, enforcing supply limits, pausing transfers, or

allowing gasless approvals (EIP-2612). Extensions for ERC-721 include Burnable, Enumerable,

and Consecutive. The Enumerable extension allows for enumeration of all the token IDs in the

contract as well as all the token IDs owned by each account. On the other hand, the

Consecutive extension is useful for efficiently minting multiple tokens in a single transaction.


**Crypto**


The Crypto module provides cryptographic utilities commonly used in blockchain

environments, including functionality for verifying Merkle proofs. It allows developers to verify

whether an element is part of a Merkle tree using the <mark>`verify`</mark> and <mark>`verify_multi_proof`</mark>

functions. These functions leverage the Keccak256 hashing algorithm by default but can be

customized to use generic hashing algorithms through <mark>`verify_with_builder`</mark> <mark>.</mark> This makes

the module versatile for use in whitelisting and other proof-based applications.

### **Limitations of the SDK**


The Stylus SDK presents several challenges that complicate replicating OpenZeppelin’s

Solidity libraries. These include:


**Lack of Constructors**


OpenZeppelin developed <u>[Koba](https://github.com/OpenZeppelin/koba)</u> to allow Stylus contracts to be deployed with input, mimicking

constructor behavior. However, development is still in early stages and not all functionality is

currently available, such as checking the <mark>`code.length`</mark> of the current contract to determine if

it is at the deployment stage.


**Lack of Modifiers**


Since there is no modifier support, the only solution for contracts such as <mark>`Ownable`</mark> is to

define two functions, one to be called at the beginning of execution and one to be called at the

end, which is an error-prone pattern when compared to Solidity.


Contracts for Stylus Audit − System Overview − 7


**Limited Inheritance**


Since inheritance is not available, certain workarounds are required in the library to override

internal functions. For example, <mark>`consecutive.rs`</mark> has to re-implement many functions of the

base <mark>`ERC721`</mark> in order to add additional logic, which leads to code duplication.

## **Trust Assumptions**


It is assumed that the Stylus SDK and other third-party dependencies integrated with the

Contracts for Stylus library are trusted to be secure and behave in an expected manner, and to

be free from malicious code such as backdoors or other vulnerabilities. In addition, several

tools are closely integrated within the Contracts for Stylus library that were developed by

OpenZeppelin to provide additional custom functionality. <u>[Koba](https://github.com/OpenZeppelin/koba)</u> was developed to provide

constructor support, while <u>[Motsu](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/main/lib/motsu)</u> and the <u>[E2E Testing Crate](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/main/lib/e2e)</u> were developed to add unit and

integration tests, respectively, to the Stylus development workflow. These crates are out-of
scope for the current audit and have not yet undergone an audit at this time.


Contracts for Stylus Audit − Trust Assumptions − 8


## **Medium Severity**

### **M-01 ERC-721 Does Not Support ERC-165**

The <u>[ERC721](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721)</u> implementation does not support ERC-165, which is <u>[required by the interface,](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0d2d72a1d875bc7c7bb0b37103fe487f82b2a4c6/contracts/token/ERC721/IERC721.sol#L11)</u>

and popular marketplaces such as OpenSea and Rarible call <mark>`supportsInterface`</mark> on any

NFTs they interact with. If an ERC-721 implementation does not implement ERC-165, other

contracts, dApps, or marketplaces will not be able to easily verify whether the contract

supports the ERC-721 interface. This means that platforms or third parties that rely on

ERC-165 to check for compliance will not recognize the contract as an ERC-721 token. As a

result, the NFT contract may face limited interoperability and integration issues with external

systems that expect proper ERC-165 implementation.


Consider adding support for ERC-165 to ensure compatibility with marketplaces and third
party systems.


**_Update:_** _Resolved at commit_ _<u>[4106d03, ERC-165 support was added.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/4106d032b06178429d8d548118f31572b0d3313f)</u>_

## **Low Severity**

### **L-01 Incomplete Implementation for** **`checkpoints.rs`**


The <u><mark>`[checkpoints.rs](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/utils/structs/checkpoints.rs)`</mark></u> file in the Stylus library only includes an implementation for the

<mark>`uint160`</mark> type. It lacks implementations for the <mark>`uint208`</mark> and <mark>`uint224`</mark> types, which are

part of the <u>[Solidity library. A](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/structs/Checkpoints.sol)</u> <u>[TODO comment on line 17](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/utils/structs/checkpoints.rs#L17)</u> indicates that this is intended to be

addressed in the future.


Consider adding implementations for the missing types to ensure consistency with the Solidity

library.


**_Update:_** _Resolved at commit_ _<u>[3b560b3.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/3b560b3a409caeb274fa638b7565da4930079c28)</u>_


Contracts for Stylus Audit − Medium Severity − 9


### **L-02 Inconsistent Implementations in ERC-721** **Extension**

The Stylus library ERC-721 extensions are not consistent with the respective functionality of

the Solidity library.


These inconsistencies were identified:


   - In the <u>[uri_storage extension, the](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721/extensions/uri_storage.rs)</u> <mark>`token_uri()`</mark> function directly returns the value from

storage but omits key checks:


     - It does not verify whether the token exists, which is handled in the <u>[Solidity](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0d2d72a1d875bc7c7bb0b37103fe487f82b2a4c6/contracts/token/ERC721/extensions/ERC721URIStorage.sol#L35)</u>

<u>[implementation.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0d2d72a1d875bc7c7bb0b37103fe487f82b2a4c6/contracts/token/ERC721/extensions/ERC721URIStorage.sol#L35)</u>

      - It does not handle base URI concatenation like the Solidity version. Instead, it

directly retrieves and returns the stored token URI without constructing the full

URI.




- There is a mismatch in the implementation of <mark>`ERC721Metadata`</mark> <mark>:</mark>




- The Rust implementation exposes the <u><mark>`[base_uri](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721/extensions/metadata.rs#L57)`</mark></u> function. In the Solidity version,

<u>URIs are only accessible by token ID</u> when the token exists. Not exposing

<mark>`baseURI`</mark> is generally advisable, as revealing it prematurely can leak sensitive NFT

data before minting. This can enable advanced users to time their minting to

acquire more desirable NFTs.




     - The Rust version lacks the <mark>`tokenURI`</mark> function by default, which may cause

integration issues.


Consider aligning these implementations with the Solidity library to ensure consistency and

mitigate potential risks.


**_Update:_** _Resolved at commit_ _<u>[47d2d9c.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/47d2d9c0d8b436cf13da94bfeb2a397c04f507d2)</u>_

### **L-03 Missing Checks in ERC-20 Implementation**


Some validation checks are missing in the current ERC-20 implementation when compared to

the Solidity library:


   - In <mark>`mod.rs`</mark> <mark>,</mark> the <u><mark>`[_approve()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/mod.rs#L308)`</mark></u> function checks the spender's address but does not

verify that the owner's address is not zero, unlike in the <u>[Solidity library.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/dbb6104ce834628e473d2173bbc9d47f81a9eec3/contracts/token/ERC20/ERC20.sol#L285-L290)</u>


Contracts for Stylus Audit − Low Severity − 10


   - The <u><mark>`[_spend_allowance()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/mod.rs#L520)`</mark></u> function directly sets the allowance in storage without

calling the internal <mark>`_approve()`</mark> function, as is done in the <u>[Solidity version. This](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/dbb6104ce834628e473d2173bbc9d47f81a9eec3/contracts/token/ERC20/ERC20.sol#L312)</u>

bypasses the address validation checks (owner and spender) that <mark>`_approve()`</mark>

provides.


   - The <u><mark>`[transfer_from()](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/mod.rs#L276)`</mark></u> function currently calls <mark>`_spend_allowance()`</mark> before

<mark>`_transfer()`</mark> <mark>,</mark> where the latter includes non-zero address checks for both the sender

and recipient. However, these checks should be performed prior to updating the

allowance, as is done in the <u>[Solidity implementation, to prevent unnecessary storage](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/dbb6104ce834628e473d2173bbc9d47f81a9eec3/contracts/token/ERC20/ERC20.sol#L284-L315)</u>

writes in the event of a revert.


Consider adding the aforementioned missing checks to improve the security of the library.


**_Update:_** _Resolved at commit_ _<u>[59dafb4.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/59dafb4849cbd93e11fe15923c80f18f6835fd46)</u>_

### **L-04 Public Exposure of pause and unpause** **Functions**


The <mark>`pausable.rs`</mark> contract exposes the <u><mark>`[pause](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/utils/pausable.rs#L81)`</mark></u> and <u><mark>`[unpause](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/utils/pausable.rs#L98)`</mark></u> functions as part of a

<mark>`#[public]`</mark> implementation block. This design automatically makes these functions available

in any inheriting contract's public ABI, without any access control restrictions. In the Solidity

version of the <u><mark>`[Pausable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/Pausable.sol)`</mark></u> contract, the corresponding functions are marked as <mark>`internal`</mark> <mark>.</mark>

This forces developers to explicitly declare <mark>`external`</mark> or <mark>`public`</mark> functions that interact with

<mark>`pause`</mark> and <mark>`unpause`</mark> <mark>,</mark> and ensures that proper access control measures are applied.


Consider placing the <mark>`pause`</mark> and <mark>`unpause`</mark> functions in a non-public implementation block,

preventing their exposure via the ABI by default. This will enforce explicit access control,

reducing the risk of unintended function access.


**_Update:_** _Resolved at commit_ _<u>[af826da.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/af826dadb78aec70deb6ed9371dae54f12af5c20)</u>_

### **L-05 Inconsistent Function Visibility in Burnable** **Extension**


The <u>[ERC-20 burnable extension](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/extensions/burnable.rs)</u> implementation does not mark the public <mark>`burn`</mark> and

<mark>`burn_from`</mark> functions as <mark>`external`</mark> <mark>,</mark> and developers will have to implement these by

themselves. A similar issue is also found in the <u>[burnable extension for ERC-721. Although the](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721/extensions/burnable.rs)</u>

documentation clearly states this, these design patterns are inconsistent with other extensions

of the library.


Contracts for Stylus Audit − Low Severity − 11


In order to avoid confusion and make the library easy to use, consider using a consistent

design pattern for the different extensions.


**_Update:_** _Acknowledged, not fixed due to the Stylus SDK restriction of only allowing one_

_<mark>`#[public]`</mark>_ _attribute declaration per crate._

### **L-06 Inconsistent Implementation Styles**


Throughout the codebase, multiple inconsistencies were identified in the implementation style,

mostly related to limitations around inheritance. For example, the <u>[ERC721Consecutive](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721/extensions/consecutive.rs)</u> and

<u>[ERC20Permit](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/extensions/permit.rs)</u> contracts include an <mark>`erc721`</mark> or <mark>`erc20`</mark> element in a struct, respectively, and

functions are called on that element when possible, but this forces the library to re-implement

many functions from the base contract leading to code duplication. On another hand, the

<u>[ERC20Capped](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/extensions/capped.rs)</u> seems somewhat incomplete compared to the Solidity library and would

require the user to implement the capping logic. This mixed design style could be confusing

and error-prone for developers using the library.


Consider adopting a consistent style for the codebase implementation or heavily document the

different reasons for the decisions to help guide users adopt the best developer practices

when using the library.


**_Update:_** _Acknowledged, not fixed due to Rust-based contract designs for Stylus not being_

_compatible with Solidity-style inheritance patterns._

## **Notes & Additional** **Information**

### **N-01 Unaddressed TODOs and FIXMEs**


Throughout the codebase, multiple instances of TODO and FIXME comments were identified:


   - <u>[line59](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/extensions/metadata.rs#L59)</u> of ERC-20 extension <mark>`metadata.rs`</mark>

   - <u>[line73](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/extensions/metadata.rs#L73)</u> of ERC-20 extension <mark>`metadata.rs`</mark>

   - <u>[line11](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721/extensions/enumerable.rs#L11)</u> of ERC-721 extension <mark>`enumerable.rs`</mark>

   - <u>[line71](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721/extensions/enumerable.rs#L71)</u> of ERC-721 extension <mark>`enumerable.rs`</mark>

   - <u>[line486](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721/mod.rs#L486)</u> of ERC-721 extension <mark>`mod.rs`</mark>


Contracts for Stylus Audit − Notes & Additional Information − 12


   - <u>[line665](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc721/mod.rs#L665)</u> of ERC-721 extension <mark>`mod.rs`</mark>


During development, having well-described TODO or FIXME comments will make the process

of tracking and resolving them easier. Without this information, these comments might age and

important information for the security of the system might be forgotten by the time it is

released to production. As such, consider removing all instances of TODO or FIXME comments

and instead tracking them in the issues backlog. Alternatively, consider linking each inline

TODO or FIXME to a corresponding backlog issue.


**_Update:_** _Resolved at commit_ _<u>[997fcc0.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/997fcc0108f6e388d19a4422b07892a64e94c2d8)</u>_

### **N-02 Inconsistent Error Types**


Throughout the codebase, there are some extensions that use associated error types to allow

users the flexibility to assign a generic <mark>`Vec`</mark> as an error type and encode any error that is

needed (or not return an error at all), while others do not use this error style. For example, in

the <u>[IERC20 trait of the ERC20 implementation.](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/token/erc20/mod.rs#L116)</u>


Consider using a consistent error style to avoid confusion and improve code clarity.


**_Update:_** _Acknowledged, will standardize errors in a future release._

### **N-03 Unnecessary Swap Operation**


The <mark>`commutative_hash_pair`</mark> function in <mark>`hash.rs`</mark> performs a comparison of `a` and `b`

values, <u>[swapping](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/lib/crypto/src/hash.rs#L151)</u> them if <mark>`a > b`</mark> <mark>.</mark> However, it would be more efficient and readable to simply

reverse the order of arguments in the call to <u><mark>`[hash_pair](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/lib/crypto/src/hash.rs#L154)`</mark></u> if the comparison is true.


To improve code readability, consider modifying the <mark>`commutative_hash_pair`</mark> function to

implement the aforementioned optimization.


**_Update:_** _Resolved at commit_ _<u>[7c84e68.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/7c84e6851914464734e6fb0f5cde5837c691b2f4)</u>_

### **N-04 Misleading Reference to Modifiers in** **Pausable Module**


The Pausable module makes reference to <u>[modifersi](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/dce09d3504c1e68d30c02bd5f1d0644ca430040a/contracts/src/utils/pausable.rs#L11)</u> before the <u><mark>`[when_not_paused](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/dce09d3504c1e68d30c02bd5f1d0644ca430040a/contracts/src/utils/pausable.rs#L107)`</mark></u> and

<u><mark>`[when_paused](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/dce09d3504c1e68d30c02bd5f1d0644ca430040a/contracts/src/utils/pausable.rs#L125)`</mark></u> functions, but true modifiers are not supported by the Stylus SDK. Consider


Contracts for Stylus Audit − Notes & Additional Information − 13


changing the wording of these comments and any others in the codebase to ensure that there

are references to features that are unique to Solidity.


**_Update:_** _Resolved at commit_ _<u>[c056473.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/c056473b85fe506f763063a08d48692c5ce2d130)</u>_

### **N-05 Unused Error Message**


The ECDSA library does not utilize the <u><mark>`[ECDSAInvalidSignatureLength](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/utils/cryptography/ecdsa.rs#L38)`</mark></u> error. According to

the Solidity library, the concatenation of `v`, `r`, and `s` must have a valid signature length of 65

bytes, otherwise, an <u>[error is returned. However, this validation is not necessary in the Stylus](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/cryptography/ECDSA.sol#L71)</u>

contract implementation since the parameters are provided as <u>[fixed-length types. Consider](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/utils/cryptography/ecdsa.rs#L138-L140)</u>

removing this error definition to avoid confusion. In addition, consider correcting the misplaced

comment referencing this error in <u>[line 189.](https://github.com/OpenZeppelin/rust-contracts-stylus/blob/42c859f37d7332fbd78a216a283064a5227f9c68/contracts/src/utils/cryptography/ecdsa.rs#L189)</u>


**_Update:_** _Resolved at commit_ _<u>[6eeb15c.](https://github.com/OpenZeppelin/rust-contracts-stylus/commit/6eeb15ca9c1460b00b0ef769a4d27682404b8d31)</u>_


Contracts for Stylus Audit − Notes & Additional Information − 14


## **Conclusion**

The Contracts for Stylus library marks a significant step toward the maturation and adoption of

Arbitrum Stylus as a smart contract language. For developers familiar with Solidity and the

OpenZeppelin libraries but less experienced with Rust, this library provides an accessible

onboarding path to Rust-based contract development while maintaining a secure level of

abstraction over the Stylus SDK. During the security audit, several issues were identified, and

we provided recommendations primarily focused on missing features and inefficient

implementation patterns caused by SDK limitations. Since the library mirrors much of the

Solidity implementation, these suggestions are in line with the evolving nature of both the

library and the SDK.


Throughout the audit, we closely collaborated with the Contracts For Stylus team and

anticipate significant developments as both the library and the SDK mature. To ensure ongoing

security and functionality, we strongly recommend continuous audits as major updates occur.

We are excited to see the project evolve, expand its scope, and contribute to the growing

Arbitrum Stylus ecosystem.


Contracts for Stylus Audit − Conclusion − 15


