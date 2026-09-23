### | security

# **Stylus Rust SDK** **Audit**

#### **September 5, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  7

Stylus SDK for Rust 7


Procedural Macros _________________________________________________________________  8

entrypoint 8

external 8

sol_interface 8

solidity_storage 9

sol_storage 9

derive_solidity_error 9

derive_erase 9


Core Modules ___________________________________________________________________ 10

abi 10

call 10

deploy 10

storage 11

hostio 11


Mini Allocator ___________________________________________________________________ 12


Examples _______________________________________________________________________ 12


Trust Assumptions _______________________________________________________________ 12


Critical Severity __________________________________________________________________ 14

C-01 Storage Layout is Inconsistent with Solidity 14

C-02 Lack of Selector Collision Check in External Macro 15


High Severity ____________________________________________________________________ 16

H-01 Potential Misuse of sol_interface Macro 16

H-02 Custom Selectors Could Facilitate Proxy Selector Clashing Attack 16


Medium Severity _________________________________________________________________ 17

M-01 Function Overriding Does Not Enforce Mutability Rules 17

M-02 Multiple Interface Definitions in sol_interface Block Repeat Functions 18

M-03 Contracts Without at Least One Return Type Fail to Compile With export-abi Feature 18


Stylus Rust SDK Audit − Table of Contents − 2


M-04 Unnecessary and Problematic Storage Types in Stylus 19

M-05 Inefficient Storage of Strings and Bytes 19

M-06 Verification Challenges in Contracts May Facilitate Scams 20

M-07 Insufficient Test Coverage 20

M-08 Missing receive and fallback Functions 21

M-09 Solidity Interfaces in Stylus Might Mislead Users into Thinking They Match Solidity’s Features 21

M-10 Potential Misuse of Purity Attributes 22


Low Severity ____________________________________________________________________ 22

L-01 Unclear Documentation Concerning Call 22

L-02 Unclear Usage and Documentation For Storage Context During Calls 23

L-03 Misleading Documentation 24

L-04 Information Leakage in WASM Build 24

L-05 Inefficient Allocator Fallback in Stylus Contracts 24

L-06 Macro Implementations Missing Proper Docstrings 25

L-07 Misleading Methods in RawDeploy 25

L-08 Potential Misuse of #[borrow] Attribute in Storage Fields 26

L-09 Deprecate constant State Mutability in sol_interface Macro 26

L-10 sol_interface Improper Handling of Function Visibility 27

L-11 sol_interface Lacks Support for Struct and Enum Types 27

L-12 sol_storage! Macro Does Not Support Private State Variables 27


Notes & Additional Information ____________________________________________________ 28

N-01 Naming Issues 28

N-02 wee_alloc Crate is Unmaintained and Vulnerable 29

N-03 Unstable License URL Reference 29

N-04 Limited Functionality in sol_storage Macro 29

N-05 Lack of Length Accessor for Fixed-Size Arrays 30

N-06 Unresolved Link to EagerStorage 30

N-07 Typographical Errors 31

N-08 External Macro Attribute Handling Inconsistency 31

N-09 Outdated Copyright Year 31

N-10 Todo Comments in the Code 32


Conclusion ______________________________________________________________________ 33


Stylus Rust SDK Audit − Table of Contents − 3


## **Summary**

**Type** Smart Contract Language


**Timeline** From 2024-07-08
To 2024-08-09


**Languages** Rust



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



2 (1 resolved, 1 partially resolved)


2 (2 resolved)


10 (7 resolved)



**Total Issues** 36 (27 resolved, 1 partially resolved)



**Low Severity Issues** 12 (8 resolved)



**Notes & Additional**
**Information**



10 (9 resolved)



Stylus Rust SDK Audit − Summary − 4


## **Scope**

We audited the <u>[OffchainLabs/stylus-sdk-rs](https://github.com/OffchainLabs/stylus-sdk-rs)</u> repository at commit <u>[62bd831.](https://github.com/OffchainLabs/stylus-sdk-rs/tree/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06)</u>


In scope were the following files:

```
stylus-proc
└── src
├── calls
│  └── mod.rs
├── lib.rs
├── methods
│  ├── entrypoint.rs
│  ├── error.rs
│  ├── external.rs
│  └── mod.rs
├── storage
│  ├── mod.rs
│  └── proc.rs
└── types.rs
stylus-sdk
└── src
├── abi
│  ├── bytes.rs
│  ├── const_string.rs
│  ├── export
│  │  ├── internal.rs
│  │  └── mod.rs
│  ├── impls.rs
│  ├── internal.rs
│  └── mod.rs
├── block.rs
├── call
│  ├── context.rs
│  ├── error.rs
│  ├── mod.rs
│  ├── raw.rs
│  ├── traits.rs
│  └── transfer.rs
├── contract.rs
├── crypto.rs
├── debug.rs
├── deploy
│  ├── mod.rs
│  └── raw.rs
├── evm.rs
├── hostio.rs
├── lib.rs
├── msg.rs

```

Stylus Rust SDK Audit − Scope − 5


```
├── prelude.rs
├── storage
│  ├── array.rs
│  ├── bytes.rs
│  ├── map.rs
│  ├── mod.rs
│  ├── traits.rs
│  └── vec.rs
├── tx.rs
├── types.rs
└── util.rs
examples
├── erc20
│  └── src
│    ├── erc20.rs
│    ├── lib.rs
│    └── main.rs
├── erc721
│  └── src
│    ├── erc721.rs
│    ├── lib.rs
│    └── main.rs
└── single_call
└── src
├── lib.rs
└── main.rs
mini-alloc
├── src
│  ├── imp.rs
│  └── lib.rs
└── tests
└── misc.rs

```


Stylus Rust SDK Audit − Scope − 6


## **System Overview**

Arbitrum Stylus introduces a paradigm shift in smart contract development by enabling

programs to be compiled to WebAssembly (WASM) and deployed on-chain, seamlessly

coexisting with traditional smart contracts written in common EVM languages like Solidity. This

language-agnostic approach opens up new possibilities for developers, enabling them to use

their preferred programming languages while maintaining full ABI compatibility with the

Ethereum ecosystem.


One of the most remarkable aspects of Stylus programs is their exceptional performance and

cost-effectiveness. These programs are orders of magnitude cheaper and faster to execute

than traditional EVM-based smart contracts while also being fully EVM compatible. This

breakthrough enables Stylus programs to interact seamlessly with existing Ethereum smart

contracts, creating a bridge between the efficiency of WASM and the established Ethereum

ecosystem.

### **Stylus SDK for Rust**


This powerful toolkit enables developers to write programs for Arbitrum chains in Rust. Rust's

combination of performance, safety, and modern features makes it ideal for developing robust

and efficient smart contracts. The Stylus SDK for Rust provides a comprehensive set of tools

and abstractions that simplify the process of creating Stylus programs. It offers a familiar

development experience for Rust programmers while integrating seamlessly with the Arbitrum

ecosystem. Some of the features available in the SDK include:


   - Generic, storage-backed Rust types for programming Solidity-equivalent smart contracts

with optimal storage caching.

   - Simple macros for writing language-agnostic methods and entry points.

   - Automatic export of Solidity interfaces for interoperability across programming

languages.

   - Powerful primitive types backed by the feature-rich Alloy.


Stylus Rust SDK Audit − System Overview − 7


## **Procedural Macros**

The Stylus Rust SDK leverages several powerful procedural macros to streamline smart

contract development and ensure seamless integration with the EVM ecosystem. These

macros automate complex tasks such as trait implementation, method exposure, storage

management, and inter-contract communication, allowing developers to write idiomatic Rust

code while maintaining full compatibility with contracts made with EVM-compatible languages.

### **`entrypoint`**


This macro defines the entry point for Stylus execution. It implements the <mark>`TopLevelStorage`</mark>

trait and is typically used to annotate the top-level storage struct. This macro sets up the

necessary boilerplate for handling incoming calls, parsing calldata, and serializing results. It

also manages reentrancy protection, integrating with the Stylus VM's execution model.

### **`external`**


This macro is used to make methods "external" so that they can be called by other contracts.

It implements the <mark>`Router`</mark> trait for the annotated <mark>`impl`</mark> block. The macro handles the

complexities of ABI encoding and decoding, method selector generation, and integration with

the Stylus VM's calling conventions. It also manages purity annotations <mark>(</mark> <mark>`pure`</mark>, <mark>`view`</mark> <mark>,</mark>

<mark>`payable`</mark> <mark>)</mark> and can infer these based on the method signature if not explicitly specified. This

macro can have the <mark>`#[inherit]`</mark> attribute to implement inheritance-like behavior, allowing a

contract to include methods from parent contracts.

### **`sol_interface`**


It transforms Solidity interface definitions into Rust structs and methods, enabling seamless

interaction with other contracts. The macro handles method generation, type conversion,

function selector calculation, and call context management. It supports various call types

<mark>(</mark> <mark>`pure`</mark> <mark>,</mark> <mark>`view`</mark> <mark>,</mark> and <mark>`payable`</mark> <mark>)</mark> and accommodates reentrancy concerns. By automating the

creation of ABI-compatible Rust code, it simplifies cross-contract communication while

maintaining type safety and idiomatic Rust practices. This macro acts as a translator, enabling

Rust contracts to integrate with the broader EVM ecosystem.


Stylus Rust SDK Audit − Procedural Macros − 8


### **`solidity_storage`**

This attribute macro is applied to Rust structs to enable their use in persistent storage within a

smart contract. Each field in the struct must implement the <mark>`StorageType`</mark> trait which ensures

EVM storage model compatibility. Applying this macro allows developers to define storage

layouts directly in Rust, with the fields mapping to the corresponding storage slots in the EVM.

This macro ensures that the storage layout of the Rust structs aligns with that of Solidity,

facilitating seamless upgrades and interactions with existing Solidity contracts. It supports

nested structs and various storage types like <mark>`StorageAddress`</mark> <mark>,</mark> <mark>`StorageBool`</mark> <mark>,</mark> and

custom types implementing <mark>`StorageType`</mark> <mark>.</mark>

### **`sol_storage`**


This macro enables the definition of Rust structs using Solidity-like syntax. It ensures that the

storage layout of these structs is identical to their Solidity counterparts. This macro simplifies

the transition from Solidity to Rust by allowing developers to reuse their Solidity type

definitions directly in Rust, maintaining compatibility with existing storage layouts. This macro

uses <mark>`solidity_storage`</mark> macro under the hood.

### **`derive_solidity_error`**


This macro allows Rust enums to be used for error handling in contract methods. It enables

enums to be automatically converted into Solidity-compatible error messages that can be

returned by smart contract functions. Under the hood, the macro works by implementing

<mark>`From<YOUR_ERROR>`</mark> for <mark>`Vec<u8>`</mark> along with printing code for <mark>`export-abi`</mark> .

### **`derive_erase`**


This macro automatically implements the <mark>`Erase`</mark> trait for a struct. It generates an <mark>`erase()`</mark>

method that calls <mark>`erase()`</mark> on each of the struct's fields. This allows for easy clearing of

complex storage structures in Arbitrum Stylus smart contracts, ensuring that all fields are

properly erased without manual implementation. The macro cannot implement Erase for types

that do not support it, such as mappings.


Stylus Rust SDK Audit − Procedural Macros − 9


## **Core Modules**

The following modules are contained within the <mark>`stylus-sdk`</mark> folder to facilitate smart

contract development and interaction with the Stylus WASM module:

### **`abi`**


The <mark>`abi`</mark> module provides functionality for encoding and decoding data according to the

Ethereum Application Binary Interface (ABI) specification. It enables a two-way mapping

between Solidity and Rust types, allowing for interoperability between Rust and Solidity

contracts. The module supports encoding function calls into byte arrays and decoding contract

responses back into Rust types. The <mark>`abi`</mark> module also includes utilities to generate method

selectors and export Solidity interfaces, treating <mark>`Vec<u8>`</mark> as <mark>`uint8[]`</mark> in Solidity and using

the <mark>`Bytes`</mark> type for Solidity <mark>`bytes`</mark> <mark>.</mark> This functionality is essential for communication between

Rust-based smart contracts and those written in Solidity.

### **`call`**


The <mark>`call`</mark> module manages interactions with external contracts by handling the execution

context and providing mechanisms for standard and raw contract calls. It allows developers to

specify gas limits and call values, and access contract storage. The module includes caching

strategies to optimize repeated state access and features for safe execution during re-entrant

calls. By managing these aspects, the <mark>`call`</mark> module enables Rust-based contracts to interact

with Ethereum contracts, facilitating contract communication and data exchange.

### **`deploy`**


The <mark>`deploy`</mark> module facilitates the deployment of contracts on the Arbitrum network. It

includes functionalities for both standard and raw deployments, offering flexibility and control

over the deployment process. The <mark>`raw.rs`</mark> file provides lower-level deployment functions,

allowing for more granular control and potentially unsafe operations. This module supports

setting deployment parameters, handling the deployment process, and ensuring correct

contract initialization.


Stylus Rust SDK Audit − Core Modules − 10


### **`storage`**

The <mark>`storage`</mark> module provides a comprehensive framework for managing smart contract

storage, featuring abstractions for common data structures like arrays, bytes, maps, and

vectors. It supports both basic and complex storage operations through a set of defined traits,

ensuring proper data handling and access. The module allows developers to define custom

storage logic by implementing the <mark>`StorageType`</mark> trait, enabling more advanced data

manipulation while providing persistent storage access in the Rust-based contracts. Stylus

contracts run on a virtual machine that shares the same EVM State Trie, allowing access to

Ethereum's key-value storage. The module provides types and traits for safe storage access

using Rust's borrow checker, preventing unsafe aliasing of storage.

### **`hostio`**


The <mark>`hostio`</mark> module facilitates interactions between Rust-based smart contracts and the host

environment on the Arbitrum blockchain. It provides a set of functions for managing contract

state, executing calls, and handling I/O operations via a foreign-function interface to the Stylus

WASM VM which ultimately communicates with the core blockchain. The <mark>`wrap_hostio`</mark>

macro is a key component of this module, designed to simplify and streamline the process of

defining host functions. It wraps low-level host operations in Rust-safe abstractions,

automatically generating bindings to interact with the blockchain. Several single-file modules in

the Stylus SDK provide typical blockchain interactions extensively using the <mark>`wrap_hostio`</mark>

module, such as:




- **<mark>`block`</mark>** <mark>:</mark> Provides access to Ethereum block information, including properties like the

block number, timestamp, and miner details. It serves as an interface for retrieving data

about the current or past blocks on the blockchain.




- **<mark>`contract`</mark>** <mark>:</mark> Facilitates interactions with other contracts, enabling function calls and

access to contract metadata. It allows contracts to perform operations such as balance

checks and contract code retrieval.




- **<mark>`crypto`</mark>** <mark>:</mark> Offers cryptographic functions and utilities, such as hashing algorithms and

signature verification.




- **<mark>`evm`</mark>** <mark>:</mark> Interfaces with the EVM, managing execution resources and logging. It includes

utilities to query remaining gas and ink (Stylus-specific compute units), emit logs both in

raw and alloy-typed forms, and manage memory growth.




- **<mark>`msg`</mark>** <mark>:</mark> Handles message-passing operations, providing information about the current

transaction, such as the sender, value, and gas. It allows contracts to interact with

transaction data and control flow.


Stylus Rust SDK Audit − Core Modules − 11


- **<mark>`tx`</mark>** <mark>:</mark> Provides transaction-related functionality, including accessing transaction details



like gas price and origin. It enables contracts to work with transaction-specific data and

execute transaction-based logic.

## **Mini Allocator**


This allocator is key to the Stylus ecosystem, optimized for wasm32 targets like Arbitrum

Stylus. It uses a minimal bump allocator strategy, prioritizing simplicity and efficiency. Notably,

mini-alloc never deallocates memory, which is ideal for scenarios with tight binary size

constraints where it is acceptable to leak all allocations. This design choice enhances

performance, aligning with Stylus' focus on optimizing for blockchain environments where

traditional memory management can add unnecessary overhead.

## **Examples**


The Arbitrum Stylus SDK repository contains three example crates of common smart contract

designs: <mark>`erc20`</mark> <mark>,</mark> <mark>`erc721`</mark> <mark>,</mark> and <mark>`single_call`</mark> <mark>.</mark>




- **<mark>`erc20`</mark>** <mark>:</mark> Demonstrates an ERC-20 token contract with functionalities like minting,

transferring, and checking balances. It includes methods for token transfers and

managing allowances.




- **<mark>`erc721`</mark>** <mark>:</mark> Illustrates an ERC-721 NFT contract implementation, covering minting,

transferring, and querying ownership of unique tokens. It also handles token metadata

and ensures compatibility with the ERC-721 standard.




- **<mark>`single_cal`</mark>** <mark>:</mark> Showcases a simple contract for making a single call to another contract,



demonstrating inter-contract communication within the Arbitrum environment using the

Stylus SDK.

## **Trust Assumptions**


    - **SDK Integrity** : It is assumed that the Stylus SDK itself is free from malicious code, such

as backdoors or other vulnerabilities that could circumvent the behavior of the underlying


Stylus Rust SDK Audit − Mini Allocator − 12


blockchain. The SDK is expected to function as described in its documentation, ensuring

that developers can rely on its behavior as intended.

- **WASM VM and Stylus Module Compliance** : It is assumed that the WASM VM and

Stylus module strictly follow the consensus rules as outlined by the core EVM part of

Arbitrum. This ensures that the execution within the Stylus environment is consistent with

the broader consensus rules governing the Arbitrum network, maintaining the integrity

and reliability of smart contract execution.

- **Third-Party Dependencies** : Any third-party libraries or dependencies integrated with the

Stylus SDK are trusted to be secure and regularly updated to mitigate known

vulnerabilities.

- **Smart Contract Interfaces** : It is assumed that the ABIs generated by the Stylus SDK for

contracts are correct and that smart contracts behave in an expected manner, similar to

Solidity contracts. This means that from an external perspective, the contracts should

exhibit predictable and standard behavior, ensuring compatibility and reliability for the

users interacting with them.


Stylus Rust SDK Audit − Trust Assumptions − 13


## **Critical Severity**

### **C-01 Storage Layout is Inconsistent with Solidity**

The <u>[documentation](https://docs.arbitrum.io/stylus/reference/rust-sdk-guide#sol_storage)</u> asserts that struct fields in Stylus will map to the same storage slots as in

EVM programming languages and that the layout will be identical to <u>[Solidity’s. This suggests](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html)</u>

that upgrading from Solidity to Rust should not cause misalignment in storage slots, thereby

implying an easy transfer of type definitions.


However, Stylus does not handle inherited storage in the same manner as Solidity. For

example, consider the following Solidity code:

```
contract Parent {
  bool a = true;
  bool b = true;
}
contract Child is Parent {
  bool c = true;
  bool d = true;
}

```

In this case, storage slot 0 contains <mark>`0x01010101`</mark> <mark>.</mark> In contrast, the equivalent Stylus code

uses a <mark>`borrow`</mark> clause that uses a new storage slot and does not pack the state variables,

which results in a different storage layout:

```
// Snippet of parent.rs
sol_storage! {
  pub struct Parent {
     bool a;
     bool b;
  }
}

// Snippet of lib.rs
sol_storage! {
  #[entrypoint]
  struct Child {
     #[borrow]
     Parent parent;
     bool c;
     bool d;
  }
}

#[external]

```

Stylus Rust SDK Audit − Critical Severity − 14


```
#[inherit(Parent)]
impl Child {
// ...
}

```

Given the same value set, this results in <mark>`0x0101`</mark> being in slot 0 and <mark>`0x0101`</mark> being in slot 1.


This discrepancy is critical for projects using proxy patterns that are migrating from Solidity to

Stylus as it could lead to storage layout misalignment, potentially overwriting state variables.


Consider refactoring the <u><mark>`[solidity_storage](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/storage/mod.rs#L12)`</mark></u> <u>macro</u> to mirror Solidity's behavior.

Alternatively, consider updating the documentation to accurately reflect the current behavior

and avoid misleading developers.


**_Update:_** _Resolved at commits_ _<u>[a99d8c5](https://github.com/OffchainLabs/stylus-sdk-rs/commit/a99d8c5abed54dfdba8e91c9cc9c5c024dd76495)</u>_ _and_ _<u>[6e3a62e. Inline documentation has been added to](https://github.com/OffchainLabs/arbitrum-docs/commit/6e3a62ea291c3e9e47ef3c1d4f3e5a065ad7f997)</u>_

_highlight the discrepancy with Solidity storage layout._

### **C-02 Lack of Selector Collision Check in External** **Macro**


One of the functions of the <u>[external](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs)</u> macro is to automate the exposure of Rust functions within

a Stylus smart contract as Ethereum-compatible methods. To achieve this, it analyzes an

implementation block, processes each method to generate its selectors, and then uses these

selectors to route incoming calls to the appropriate Rust functions.


However, the macro does not validate the uniqueness of these selectors. This oversight can

lead to selector collisions, resulting in methods becoming unreachable. In addition, developers

can manually set a custom selector for a function using <mark>`#[selector(id =`</mark>

<mark>`<NUMBER_THAT_GENERATES_THE_COLLISION>)]`</mark> <mark>,</mark> potentially duplicating existing selectors

intentionally or unintentionally. This vulnerability can be exploited to create malicious contracts,

such as honeypots, wherein methods are intentionally made unreachable.


Consider implementing a validation mechanism within this macro to ensure that all selectors

are unique, preventing selector collisions and enhancing contract reliability and security. One

approach could be to add a <mark>`#[deny(unreachable_patterns)]`</mark> statement on the <u><mark>`[route](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L274)`</mark></u>

function to prevent unreachable methods.


**_Update:_** _Partially resolved at commits_ _<u>[a78decd](https://github.com/OffchainLabs/stylus-sdk-rs/commit/a78decd745e2580f57de5cc38bec093842e51e92)</u>_ _and_ _<u>[0d50c1d. The suggested solution of using](https://github.com/OffchainLabs/stylus-sdk-rs/commit/0d50c1daf06ff2175d8a58dd4ec91799defb890b)</u>_

_<mark>`#[deny(unreachable_patterns)]`</mark>_ _is insufficient, as it only checks for unreachable_

_patterns within the specific match statement where it is applied. It does not account for_

_selector collisions with functions from inherited contracts, allowing these conflicts to go_


Stylus Rust SDK Audit − Critical Severity − 15


_undetected. Offchain Labs has added inline documentation to highlight this potential issue, and_

_warnings will also be included on the documentation website. The Offchain Labs team is_

_exploring alternative approaches to implementing inheritance for Stylus._

## **High Severity**

### **H-01 Potential Misuse of sol_interface Macro**


The <u><mark>`[sol_interface](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L13)`</mark></u> macro allows developers to seamlessly call Solidity contracts from

Stylus smart contracts using their native interfaces. However, this macro can be easily

manipulated to mislead users about the actual state mutability of functions. For example, a

malicious user could capitalize the first letter of the <mark>`view`</mark> or <mark>`pure`</mark> keywords, use

homoglyphs, or employ other tricks to deceive users into believing that a function is non
mutating even though the macro treats that function as state-changing. This <u>[fallback to treating](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L70)</u>

<u>[the function as state-changing](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L70)</u> occurs if no valid mutability keyword is detected, thereby

opening the doors to unintentional errors and hard-to-detect scams.


To mitigate this issue, consider implementing stricter validation within the macro to ensure that

only the correct mutability keywords are permitted. This will help prevent both intentional

misuse and accidental errors, enhancing the overall security and reliability of the macro.


**_Update:_** _Resolved at commit_ _<u>[a474666.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/a4746667bb62023019a37647bff907d297063514)</u>_

### **H-02 Custom Selectors Could Facilitate Proxy** **Selector Clashing Attack**


Stylus allows developers to modify the selector for a given function using the <mark>`selector`</mark>

attribute, which can accept either a <u><mark>`[string name](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L58)`</mark></u> or a <u><mark>`[u32 ID](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L57)`</mark></u> <mark>.</mark> This feature facilitates

changing the name of a function while maintaining the same selector, simulating Solidity

overloading capabilities and enabling the creation of language-agnostic contract standards.


However, providing an <mark>`ID`</mark> may result in a function selector that exists in both an

implementation contract and its proxy contract. Thus, a user may call a proxy contract function

with a selector matching the intended implementation contract function instead, causing

unintended code execution and precluding the user from accessing the functionality of the

implementation contract. This scenario can occur if an <mark>`ID`</mark> integer is defined in such a way


Stylus Rust SDK Audit − High Severity − 16


that, when converted to hex, it matches the function selector in the other contract, whether it is

the implementation or the proxy.


This vulnerability enables malicious projects to create hard-to-detect backdoors. In contrast to

Stylus, Solidity requires finding function signatures with matching selectors before exploiting

this vulnerability, which is not trivial. Even if such function signatures are found, they are likely

to raise red flags due to nonsensical names in the codebase. In Stylus, this attack is harder to

execute when the <mark>`name`</mark> option is used instead of <mark>`ID`</mark> which makes such scams easier to

detect.


Custom selectors can also confuse third-party monitoring or indexing services that use

function selectors to identify specific functions. These services may rely on standard selectors,

which are part of the standards or belong to community databases such as the <u>[4byte directory.](https://www.4byte.directory/)</u>

If contracts use custom selectors, these services may fail to recognize and monitor

transactions, leading to errors.


Given these risks, reconsider the <mark>`ID`</mark> option and consider accepting only the <mark>`name`</mark> instead. If

the benefits of custom selectors do not outweigh the risks, consider removing them entirely.


**_Update:_** _Resolved at commit_ _<u>[795d376.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/795d376e2179b079008073d4e19799299a066d57)</u>_

## **Medium Severity**

### **M-01 Function Overriding Does Not Enforce** **Mutability Rules**


In Stylus, when an inheriting contract overrides a base function in its parent, there are no

checks to enforce any mutability rules. For example:


   - A function that does not modify the state in the parent (e.g., a <mark>`view`</mark> function) can be

overridden by one that does so in the child.

   - A function marked <mark>`payable`</mark> in the parent can be overridden by a non-payable function

in the child, causing the child function to revert upon receiving ETH.


From a developer standpoint, this can lead to unexpected behavior and error-prone contract

development since this does not match the rules enforced in <u>[Solidity, which mandate stricter](https://docs.soliditylang.org/en/v0.8.26/contracts.html#function-overriding)</u>

mutability enforcement. To align with Solidity's mutability rules and avoid unexpected behavior,


Stylus Rust SDK Audit − Medium Severity − 17


consider refactoring the logic in the <u><mark>`[external](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L19)`</mark></u> <u>macro</u> by implementing checks on the

mutability attributes in parent functions.


**_Update:_** _Resolved at commit_ _<u>[1984d8a.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/1984d8ad04322d4f77250905338c3fbd3333191c)</u>_

### **M-02 Multiple Interface Definitions in** **sol_interface Block Repeat Functions**


If two or more interface definitions are present in the same <mark>`sol_interface!`</mark> block,

subsequent interfaces will be expanded to include method definitions from the previous ones.

For example:

```
sol_interface! {
  interface IService {
     function makePayment(address user) payable returns (string);
     function getConstant() pure returns (bytes32);
  }
  interface ITree {}
}

```

The expanded Rust interface for <mark>`ITree`</mark> will include <mark>`make_payment`</mark> and <mark>`get_constant`</mark>,

allowing calls to <mark>`ITree.make_payment`</mark> <mark>,</mark> for example, in the contract logic. This could allow

malicious developers to hide the interface of <mark>`ITree`</mark> <mark>,</mark> including functions from previous

interface definitions that could then be called on subsequent ones. Moreover, if <mark>`ITree`</mark>

includes its own legitimate definition of <mark>`makePayment`</mark> <mark>,</mark> the code will fail to compile because

the implementation block will include two function definitions of the same name.


Consider modifying the <u><mark>`[sol_interface](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L13)`</mark></u> macro by moving the <u><mark>`[method_impls](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L27)`</mark></u> declaration

inside the <u>first</u> <u><mark>`[for](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L29)`</mark></u> <u>loop</u> so that it does not retain tokens from the previous methods during

iteration.


**_Update:_** _Resolved at commit_ _<u>[a64c058.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/a64c058dd2b30868e50044e780f8daa818430512)</u>_

### **M-03 Contracts Without at Least One Return** **Type Fail to Compile With export-abi Feature**


The <mark>`export-abi`</mark> feature can be used in the Stylus SDK to generate a Solidity ABI for Stylus

contracts using the <mark>`cargo stylus export-abi`</mark> command within the contract crate. With

this feature, the <u>[return statement](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L295)</u> is skipped in the <mark>`[#external]`</mark> macro so that the <u><mark>`[fmt_abi](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L345)`</mark></u>

can be added to the returned <mark>`router`</mark> implementation. However, if the contract does not


Stylus Rust SDK Audit − Medium Severity − 18


contain at least one function with an explicit return type (e.g., <mark>`U256`</mark> <mark>)</mark>, the code will fail to

compile due to an error in the <u><mark>`[type_decls](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L308-L315)`</mark></u> token stream which is expanded in <u><mark>`[fmt_abi](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L355)`</mark></u> <mark>.</mark>

This occurs when there are no return types because <u><mark>`[types](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L355)`</mark></u> is an empty array and

<mark>`type_decls`</mark> attempts to loop over <mark>`[].iter()`</mark> <mark>.</mark> Since the compiler cannot infer the

expected type from an empty iterator, attempting to access fields like <mark>`id`</mark> on an unknown type

<mark>(</mark> <mark>`&_`</mark> <mark>)</mark> leads to errors.


Consider including <mark>`type_decls`</mark> within the <mark>`fmt_abi`</mark> generation process only when at least

one type is available.


**_Update:_** _Resolved at commit_ _<u>[31995da.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/31995daf5eb4cb5fc7d053447c2a1f800938dab7)</u>_

### **M-04 Unnecessary and Problematic Storage** **Types in Stylus**


The Stylus language supports storage types such as <u><mark>`[StorageU1](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/mod.rs#L115)`</mark></u> <u>[and](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/mod.rs#L115)</u> <u><mark>`[StorageI1](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/mod.rs#L115)`</mark></u> <mark>,</mark> which are

not present in Solidity. These types do not provide any clear benefits within the SDK and fail to

work properly with arrays and vectors. The <mark>`density`</mark> function, heavily utilized with arrays and

vectors, triggers a division-by-zero error when interacting with these storage types. In addition,

types like <u><mark>`[StorageBlockHash](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/mod.rs#L588)`</mark></u> and <u><mark>`[StorageBlockNumber](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/mod.rs#L514)`</mark></u> also lack clear utility.


Consider providing detailed explanations of the use cases and relevance of these storage

types. If their benefits cannot be demonstrated, it is advisable to remove them to avoid

confusion and potential interoperability errors.


**_Update:_** _Resolved at commit_ _<u>[3f511fa.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/3f511fae9cedc5581150f3b0187ab23f6fc21a0d)</u>_

### **M-05 Inefficient Storage of Strings and Bytes**


Stylus allows for the use of both strings and dynamically-sized bytes in contract storage.

However, the current implementation is notably inefficient for such types. Specifically, the

functions for setting (e.g., <u><mark>`[extend](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/bytes.rs#L248)`</mark></u> <mark>)</mark> and retrieving (e.g., <u><mark>`[get_bytes](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/bytes.rs#L198)`</mark></u> <mark>)</mark> strings or dynamic bytes

operate byte-by-byte, which results in a high number of <mark>`SLOAD`</mark> and <mark>`SSTORE`</mark> operations. This

inefficiency is especially noticeable with longer strings or byte arrays, leading to significantly

increased gas costs.


Consider refactoring storage operations for strings and dynamic bytes to optimize gas usage.

Possible approaches include pre-allocating storage space when appropriate; writing data in

full, 32-byte words where possible; and minimizing the number of storage operations.


Stylus Rust SDK Audit − Medium Severity − 19


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Work is ongoing for this issue but needs some additional testing.

### **M-06 Verification Challenges in Contracts May** **Facilitate Scams**


The Stylus SDK allows developers to create smart contracts for Arbitrum chains using the Rust

programming language which is then compiled to WASM and deployed alongside Solidity

contracts. However, the final WASM output is influenced by several factors, including the Rust

version, enabled features, dependencies, and more. These variations make the build process

nearly non-deterministic across different operating systems and architectures. This non
determinism complicates contract verification, which is crucial for establishing trust and

reliability in the contract. Without consistent build outputs, it becomes challenging to ensure

that the deployed WASM accurately reflects the intended contract's code. A malicious actor

could exploit this by altering the SDK to compile WASM files that do not function as expected,

even if the smart contract code appears to be secure.


Consider standardizing the build process by specifying and enforcing clear guidelines and

issuing notifications to developers early in the development cycle (instead of doing it post
deployment). This will streamline contract verification and enhance user trust in the contract's

integrity.


**_Update:_** _Resolved at commit_ _<u>[be51b58. The fix has been made on the](https://github.com/OffchainLabs/cargo-stylus/commit/be51b58b5ec182906d21fc7c17be64e0848add62)</u>_ _<mark>`cargo-stylus`</mark>_

_repository._

### **M-07 Insufficient Test Coverage**


The workspace currently contains only a limited number of unit tests for the <u><mark>`[abi](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/abi/mod.rs)`</mark></u> module and

the <u><mark>`[mini-alloc](https://github.com/OffchainLabs/stylus-sdk-rs/tree/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/mini-alloc)`</mark></u> crate. The remainder of the codebase lacks unit tests entirely along with any

integration tests. This limited test coverage may lead to undetected issues and hinder the

verification of code functionality across various modules.


Consider adding a robust test suite that includes comprehensive unit and integration tests for

all modules. This will help ensure proper interaction between different parts of the system.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus Rust SDK Audit − Medium Severity − 20


We are currently working on adding a full suite of unit tests for the SDK as well as other

[items outlined in issue #148.](https://github.com/OffchainLabs/stylus-sdk-rs/issues/148)

### **M-08 Missing receive and fallback Functions**


The absence of <mark>`receive`</mark> and <mark>`fallback`</mark> functions in Stylus, a language designed to be

interoperable with Solidity, can have several significant implications. In Solidity, the <mark>`receive`</mark>

function handles direct transfers of ETH to a contract. Without this function, contracts cannot

accept plain ETH transfers, thereby limiting ETH transfers to those including data which

triggers a specific function call. For example, contracts like <u><mark>`[PaymentSplitter](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/finance/PaymentSplitter.sol)`</mark></u> will only work

for externally owned accounts (EOAs) due to the lack of a <mark>`receive`</mark> function. In addition,

many proxy patterns rely on the <mark>`fallback`</mark> function to forward calls to another contract.

Without a <mark>`fallback`</mark> function, implementing upgradable contracts or beacon proxy patterns

becomes much more complex, requiring alternative mechanisms to delegate calls to other

contracts.


Consider implementing <mark>`receive`</mark> and <mark>`fallback`</mark> functions to ensure full compatibility with

Solidity contracts. Doing this will help increase code flexibility and support different proxy

patterns.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Implementation underway. Needs further testing. Progress can be tracked on issue

[#150.](https://github.com/OffchainLabs/stylus-sdk-rs/issues/150)

### **M-09 Solidity Interfaces in Stylus Might Mislead** **Users into Thinking They Match Solidity’s** **Features**


The <u><mark>`[sol_interface](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L13)`</mark></u> macro in Stylus smart contracts allows developers to nearly copy and

paste Solidity interfaces for seamless contract interactions. However, the current

implementation has some potential pitfalls. While it permits elements such as interface

inheritance, events, and errors within the interfaces, these are silently ignored, with only the

functions being processed. This behavior can lead to confusion and errors, as the contract

compiles without issue despite these unsupported elements.


To address this issue, consider documenting the <mark>`sol_interface`</mark> macro's current limitations

to set appropriate user expectations and implementing checks to revert when unsupported


Stylus Rust SDK Audit − Medium Severity − 21


syntax is detected. If feasible, consider including these additional features in future updates as

it could enhance the overall code functionality.


**_Update:_** _Resolved at commits_ _<u>[821b7f6](https://github.com/OffchainLabs/stylus-sdk-rs/commit/821b7f68147b4b3621be6dba846dd6928c3b432d)</u>_ _and_ _<u>[be6306c.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/be6306c6587f24869606beabbeec5fd40fa97b90)</u>_

### **M-10 Potential Misuse of Purity Attributes**


In Stylus, contract methods can be marked with attributes such as <mark>`#[view]`</mark> <mark>,</mark> <mark>`#[write]`</mark> <mark>,</mark>

and <mark>`#[pure]`</mark> to explicitly define how they interact with the contract state. However, there are

two ways malicious users can mislead users or third-party services regarding these attributes:


   - Malicious users can use colons in the attribute names, like <mark>`#[::pure]`</mark> <mark>,</mark>

<mark>`#[stylus::view]`</mark> <mark>,</mark> or any other name with colons, to <u>[bypass the checks](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L36)</u> enforced by

the <mark>`external`</mark> macro. This allows them to misrepresent the function’s intention.

   - Functions that do not modify the state, such as <mark>`#[pure]`</mark> and <mark>`#[view]`</mark> methods, can

be incorrectly marked with the <mark>`#[write]`</mark> attribute without even requiring colons. The

<u>[inline documentation](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/lib.rs#L419-L421)</u> of the macro contains this information, but it should be fixed.


To prevent these issues, consider adding proper validations to the <mark>`external`</mark> macro to

enforce correct usage of these attributes.


**_Update:_** _Resolved at commit_ _<u>[d44d94f. The Offchain Labs team removed the mutability](https://github.com/OffchainLabs/stylus-sdk-rs/commit/d44d94f069631e6d01a36989fa2aa59f04886cd5)</u>_

_specifiers (except_ _<mark>`#[payable]`</mark>_ _<mark>)</mark>_ _, as they can be inferred from the_ _<mark>`&self`</mark>_ _<mark>/</mark>_ _<mark>`&mut self`</mark>_ _or the_

_absence of_ _<mark>`self`</mark>_ _<mark>.</mark>_ _This change simplifies the code by leveraging Rust's syntax. Since methods_

_using_ _<mark>`&self`</mark>_ _or those without_ _<mark>`self`</mark>_ _can still modify the state of other contracts—or even their_

_own state if reentrancy is enabled—through external calls, the team has thoroughly_

_documented this behavior in the codebase to inform users._

## **Low Severity**

### **L-01 Unclear Documentation Concerning Call**


There are several instances in the documentation and code comments that are unclear or

contradictory with respect to the difference between <mark>`Call::new`</mark> and <mark>`Call:new_in`</mark> <mark>.</mark> For

example, <mark>`Call::new`</mark> is given as a <u>[simple example](https://docs.arbitrum.io/stylus/reference/rust-sdk-guide#configuring-gas-and-value-with-call)</u> to show how to configure gas and value.

However, <mark>`new`</mark> is only available with the <u>[reentrant flag enabled. The reasoning behind this is](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/call/context.rs#L164-L205)</u>


Stylus Rust SDK Audit − Low Severity − 22


unclear since <u>[this comment](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/call/context.rs#L22)</u> says that <mark>`new_in`</mark> should be used for re-entrant calls. Other

confusing comments in the documentation include:


[Note too that Call::new_in should be used instead of Call::new since the former](https://docs.rs/stylus-sdk/latest/stylus_sdk/call/struct.Call.html#method.new_in)

provides access to storage. Code that previously compiled with reentrancy disabled

may require modification in order to type-check. This is done to ensure storage

changes are persisted and that the storage cache is properly managed before calls.


Consider clearly documenting the difference between <mark>`Call::new`</mark> and <mark>`Call::new_in`</mark> <mark>,</mark> and

what storage access patterns they represent, and modify code comments accordingly.


**_Update:_** _Resolved at commit_ _<u>[ba3472f.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/ba3472f498eb797d67c5fac25eaa816704b0da5b)</u>_

### **L-02 Unclear Usage and Documentation For** **Storage Context During Calls**


To set up a calling context with <mark>`Call::new_in`</mark> <mark>,</mark> the <u><mark>`[storage](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/call/context.rs#L60)`</mark></u> <u>argument</u> must implement

<mark>`TopLevelStorage`</mark> <mark>.</mark> The usual pattern to create this implementation is to use the

<mark>`entrypoint`</mark> macro, but this is not always desired if there are multiple contracts within a

crate. Without <mark>`TopLevelStorage`</mark> <mark>,</mark> <mark>`&self`</mark> and <mark>`&mut self`</mark> are no longer available, and

cumbersome workarounds are required, such as adding an empty implementation for

<mark>`TopLevelStorage`</mark> <mark>.</mark> For example:

```
unsafe impl TopLevelStorage for Contract {}

```

Furthermore, it is unclear what the purpose of the <mark>`storage`</mark> argument is when using

<mark>`Call::new_in`</mark> since the <u><mark>`[call](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/call/mod.rs#L84)`</mark></u> <u>[function](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/call/mod.rs#L84)</u> never actually uses this attribute of the call context.


Consider updating the code comments and documentation to clearly describe the purpose of

the <mark>`storage`</mark> argument. In addition, consider alternative implementations of the

<mark>`Call::new_in`</mark> function to accommodate contracts that do not implement the

<mark>`TopLevelStorage`</mark> trait.


**_Update:_** _Resolved at commit_ _<u>[ba3472f.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/ba3472f498eb797d67c5fac25eaa816704b0da5b)</u>_


Stylus Rust SDK Audit − Low Severity − 23


### **L-03 Misleading Documentation**

Throughout the codebase, multiple instances of inaccurate or misleading documentation were

identified:


   - The inline documentation for the <u><mark>`[set](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/mod.rs#L526)`</mark></u> function in <mark>`StorageBlockNumber`</mark> is identical to

that of the <u><mark>`[get](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/mod.rs#L521)`</mark></u> method, causing confusion about their distinct functionalities.

   - The documentation for the <u><mark>`[raw_log](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/evm.rs#L27)`</mark></u> function advises users to prefer the alloy-typed

<mark>`raw_log`</mark> <mark>,</mark> but it should actually recommend using the <u><mark>`[log](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/evm.rs#L39)`</mark></u> function instead.


Consider correcting the documentation to align with the code's behavior. This will help improve

the clarity and readability of the codebase.


**_Update:_** _Resolved at commit_ _<u>[dc1e9c5.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/dc1e9c5cfa758e495e062515cd52d18867188b9e)</u>_

### **L-04 Information Leakage in WASM Build**


The WASM output of a Stylus contract includes sensitive metadata, such as the username of

the individual who compiled the contract and partial paths from the home directory. Although

this information does not pose a direct security risk, it can be leveraged by attackers for social

engineering or other targeted attacks.


Consider removing or obfuscating such information from production builds to maintain privacy

and reduce the potential attack surface. Stripping metadata from the WASM output can help

mitigate these risks without impacting the functionality of the deployed contract.


**_Update:_** _Resolved at commit_ _<u>[00abf34. The fix has been made on the](https://github.com/OffchainLabs/cargo-stylus/pull/81/commits/00abf34d5e1767b275aa66482b26f766a8c7ed85)</u>_ _<mark>`cargo-stylus`</mark>_

_repository._

### **L-05 Inefficient Allocator Fallback in Stylus** **Contracts**


In Stylus contracts, the <u><mark>`[mini-alloc](https://github.com/OffchainLabs/stylus-sdk-rs/tree/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/mini-alloc)`</mark></u> allocator module from the SDK is intended to be the

standard allocator due to its performance. This module is included in every example and

default template provided by the SDK, ensuring that developers are guided towards using the

most efficient option. However, the declaration of the global allocator, which specifies the use

of <mark>`mini-alloc`</mark> <mark>,</mark> can be removed inadvertently. If this happens, the contract defaults to using

the allocator from the standard library, which is significantly less efficient. Consequently,

contracts deployed using this allocator will be very gas-inefficient.


Stylus Rust SDK Audit − Low Severity − 24


Consider enforcing <mark>`mini-alloc`</mark> as the default allocator across all Stylus contracts. Changes

to the allocator should only be permitted through a deliberate and evident action to avoid

unintentional fallback to the less-efficient standard library allocator.


**_Update:_** _Resolved at commit_ _<u>[2354799.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/235479905d5c1b3dbc1fe3cd807be70ae39795dc)</u>_

### **L-06 Macro Implementations Missing Proper** **Docstrings**


In the <mark>`stylus-proc`</mark> folder, the files that hold the implementations for each macro are

missing proper docstrings.


Given the complexity and length of the code, consider adding detailed docstrings. This will

make it easier for readers and developers to better understand the inner workings of the

codebase while improving the overall code maintainability as well.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We are looking to refactor our procedural macro implementations to make them more

easily testable and easier to understand. This will include better internal documentation

[of their implementations. Progress may be tracked on issue #151](https://github.com/OffchainLabs/stylus-sdk-rs/issues/151)

### **L-07 Misleading Methods in RawDeploy**


The <u><mark>`[limit_revert_data](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/deploy/raw.rs#L52)`</mark></u> and <u><mark>`[skip_revert_data](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/deploy/raw.rs#L60)`</mark></u> methods set the <mark>`offset`</mark> and <mark>`size`</mark>

fields of the <mark>`RawDeploy`</mark> instance. However, these fields are never used in the <u><mark>`[deploy](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/deploy/raw.rs#L92)`</mark></u>

function, rendering these methods redundant. This issue is significant because it misleads

developers into believing that they can control the amount of revert data returned, whereas, in

reality, these methods have no impact on the deployment's outcome.


Consider removing these methods and fields or modifying the <mark>`deploy`</mark> function to utilize these

fields.


**_Update:_** _Resolved at commit_ _<u>[6e21166.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/6e211663f3caf121f7c4c101476fc74128c5f61d)</u>_


Stylus Rust SDK Audit − Low Severity − 25


### **L-08 Potential Misuse of #[borrow] Attribute in** **Storage Fields**

The <u><mark>`[#[borrow]](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/storage/mod.rs#L30-L55)`</mark></u> attribute is used on storage fields to implement the <mark>`Borrow`</mark> and

<mark>`BorrowMut`</mark> traits for specific types, facilitating inheritance in Stylus contracts. However, its

application can extend to state variables that do not represent the storage of the parent

contract, leading to issues.


The primary concern is the incorrect semantic meaning when <mark>`#[borrow]`</mark> is used on simple

types. This attribute is designed for complex types that represent a subset of the contract's

storage, not for individual storage slots. Such usage misrepresents the attribute's purpose,

misleading developers about the storage layout or contract composition. Furthermore, it

generates additional trait implementations that are unnecessary for simple storage types,

causing unnecessary code bloat and potentially increasing the contract size without any

benefit.


Consider allowing the use of the <mark>`#[borrow]`</mark> attribute exclusively for fields that genuinely

represent a subset of a contract's storage. This ensures accurate semantic representation

while avoiding misleading code and unnecessary trait implementations.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Work is ongoing on this issue, and we are searching for a solution that works in Rust.

[Progress may be tracked on issue #149](https://github.com/OffchainLabs/stylus-sdk-rs/issues/149)

### **L-09 Deprecate constant State Mutability in** **sol_interface Macro**


The <mark>`sol_interface`</mark> macro currently allows users to define Solidity interfaces with methods

marked as <u><mark>`[constant](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L59)`</mark></u> for state mutability. However, starting from Solidity version 0.5.0, the

<mark>`constant`</mark> keyword for functions is <u>[no longer supported](https://docs.soliditylang.org/en/latest/050-breaking-changes.html#syntax)</u> and has been replaced by <mark>`view`</mark> and

<mark>`pure`</mark> <mark>.</mark> While the macro internally converts functions with the <mark>`constant`</mark> keyword to <mark>`pure`</mark>,

retaining the <mark>`constant`</mark> keyword can be misleading.


To align with the later Solidity versions and avoid incorrect mutability assumptions, consider

updating the <mark>`sol_interface`</mark> macro to disallow the use of the <mark>`constant`</mark> keyword for

function state mutability. This change will help ensure compatibility with modern Solidity

versions and enhance code correctness.


**_Update:_** _Resolved at commit_ _<u>[e173182.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/e173182762799ecdb713bc0308bc8f358f7bbe05)</u>_


Stylus Rust SDK Audit − Low Severity − 26


### **L-10 sol_interface Improper Handling of** **Function Visibility**

In Solidity, it is mandatory to specify the visibility of a function within an <u>[interface, and it should](https://docs.soliditylang.org/en/v0.8.26/contracts.html#interfaces)</u>

always be <mark>`external`</mark> <mark>.</mark> The <u><mark>`[sol_interface](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L13)`</mark></u> macro in Stylus, which processes these Solidity

interfaces, currently allows users to include methods with incorrect visibility attributes, such as

<mark>`public`</mark> <mark>,</mark> or omit the visibility attribute altogether. This non-compliance with Solidity standards

could lead to confusion among developers.


Consider adding validation to ensure that the <mark>`external`</mark> keyword is present in function

definitions. This would align with Solidity's interface requirements and prevent potential

misunderstanding.


**_Update:_** _Resolved at commit_ _<u>[2330ac7.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/2330ac73d84088f84c608fea7fbec142010a3478)</u>_

### **L-11 sol_interface Lacks Support for Struct** **and Enum Types**


The <u><mark>`[sol_interface](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/calls/mod.rs#L13)`</mark></u> macro is designed to enable developers to seamlessly call Solidity

contracts from Stylus smart contracts using their native interfaces. However, it currently does

not support struct and enum types, which are commonly used in Solidity. This limitation forces

developers to use less readable workarounds, potentially leading to accidental errors and

reduced code maintainability.


Consider implementing support for structs and enums. This would significantly enhance

developer experience and ensure full compatibility with Solidity interfaces.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Work has begun on struct support in <mark>`sol_interface!`</mark> <mark>.</mark> More testing is required for

release, and enums should be implemented as well. Progress may be tracked on issue

[#74.](https://github.com/OffchainLabs/stylus-sdk-rs/issues/74)

### **L-12 sol_storage! Macro Does Not Support** **Private State Variables**


Private state variables help enforce encapsulation by restricting direct access, ensuring that

variables are only modified through controlled functions. This approach minimizes the attack

surface and prevents unintended side effects or inconsistencies.


Stylus Rust SDK Audit − Low Severity − 27


Currently, when using the <u><mark>`[sol_storage!](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/storage/mod.rs#L170)`</mark></u> macro, state variables cannot be set as private,

allowing child contracts to access and modify these variables directly. Developers must instead

use the <u><mark>`[#[solidity_storage]](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/storage/mod.rs#L12)`</mark></u> macro, which supports private state variables.


To maintain consistency with <mark>`#[solidity_storage]`</mark> <mark>,</mark> consider enhancing the

<mark>`sol_storage!`</mark> macro to support private state variables. Alternatively, this limitation should

be clearly documented in the official documentation.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We will consider private state variables for the <mark>`sol_storage!`</mark> macro as part of the

[work for N-04, tracked by issue #147.](https://github.com/OffchainLabs/stylus-sdk-rs/issues/147)

## **Notes & Additional** **Information**

### **N-01 Naming Issues**


Throughout the codebase, multiple instances of elements that could be renamed to better

reflect their purpose were identified:


   - The <u><mark>`[topics](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/evm.rs#L21)`</mark></u> parameter in the <mark>`emit_log`</mark> function should be renamed to

<mark>`number_topics`</mark> to better reflect the nature of the value it represents.

   - The <u><mark>`[#[external]](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/lib.rs#L541)`</mark></u> macro, which allows methods to be callable by other methods

within the contract or external accounts, should be renamed to <mark>`#[public]`</mark> <mark>.</mark> The

current name might be confused with Solidity's <mark>`external`</mark> visibility, which implies that

the function cannot be called from within the contract.

   - The <u><mark>`[#[solidity_storage]](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/lib.rs#L67)`</mark></u> macro should be renamed to

<mark>`#[persistent_storage]`</mark> <mark>,</mark> <mark>`#[storage]`</mark> <mark>,</mark> or <mark>`#[state]`</mark> <mark>.</mark> Instead, the wrapper

macro currently named <u><mark>`[sol_storage](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/lib.rs#L110)`</mark></u> should adopt the name <mark>`solidity_storage`</mark> <mark>,</mark>

as it relates more to Solidity's syntax.

   - The <u><mark>`[types](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/types.rs)`</mark></u> module name suggests the existence of multiple types. However, if only

<mark>`Address`</mark> is defined, the module should be renamed to <mark>`AddressType`</mark> <mark>.</mark> Alternatively, if

additional common types are expected to be added, consider specifying these to avoid

confusion.


Consider addressing these naming issues to improve the readability of the codebase.


Stylus Rust SDK Audit − Notes & Additional Information − 28


**_Update:_** _Resolved at commit_ _<u>[8d1699f. The Offchain Labs team decided to keep both the](https://github.com/OffchainLabs/stylus-sdk-rs/commit/8d1699fa66aa879446852a827388a10f788b5321)</u>_

_<mark>`sol_storage!`</mark>_ _macro and the_ _<mark>`types`</mark>_ _module with the same name. The former aligns with_

_the_ _<mark>`sol!`</mark>_ _macro from_ _<u>[alloy, while the latter will include additional types in an upcoming](https://github.com/alloy-rs)</u>_

_release._

### **N-02 wee_alloc Crate is Unmaintained and** **Vulnerable**


The <mark>`wee_alloc`</mark> crate, a minimal allocator for WebAssembly, is no longer actively maintained,

with the last release being over three years ago. Moreover, two of its maintainers have

indicated that they do not plan to continue supporting the crate. As a result, several open

issues, <u>[including memory leaks, remain unresolved.](https://github.com/rustwasm/wee_alloc/issues/106)</u>


Even though the crate is not currently used for <mark>`wasm32`</mark> targets, consider switching to a more

actively maintained and safer alternative such as <u><mark>`[lol_alloc](https://crates.io/crates/lol_alloc)`</mark></u> or the default Rust standard

allocator.


**_Update:_** _Resolved at commit_ _<u>[80bfcba.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/80bfcba978b5633d21bf0eb263b818097047973b)</u>_

### **N-03 Unstable License URL Reference**


The license URL comment at the top of nearly every file in the scope points to a specific

branch <mark>(</mark> <mark>`stylus`</mark> <mark>)</mark> in the GitHub repository. This branch is not the main branch and may

change or be deleted in the future. If the branch name changes or the license is relocated, the

current URL references will become invalid, leading to broken links.


Consider updating the license URL to point to a more stable reference, such as a specific

commit or tag. Alternatively, consider including a note that the branch name may change.

These measures will help ensure that the URL remains functional over time.


**_Update:_** _Resolved at commit_ _<u>[0a0ace1.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/0a0ace1c2f1a6fe372b54f43bd61fd3d79e69352)</u>_

### **N-04 Limited Functionality in sol_storage** **Macro**


The <u><mark>`[sol_storage](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/storage/mod.rs#L170)`</mark></u> macro currently allows users to define state variables in a Solidity-like

syntax within their smart contracts. However, it does not fully replicate Solidity's syntax,

notably lacking support for specifying visibility, as well as defining constants and immutables.


Stylus Rust SDK Audit − Notes & Additional Information − 29


This limitation prevents things like the automatic generation of getters using the <mark>`public`</mark>

keyword and makes it difficult to define constants and immutables as seamlessly as in Solidity.


Consider extending the functionality of the <mark>`sol_storage`</mark> macro to support these features.

Utilizing the <mark>`syn_solidity`</mark> crate could facilitate this enhancement by providing a more

comprehensive parsing and handling of Solidity-like syntax.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We are considering these additional features for the <mark>`sol_storage!`</mark> macro. Progress

[can be tracked in issue #147.](https://github.com/OffchainLabs/stylus-sdk-rs/issues/147)

### **N-05 Lack of Length Accessor for Fixed-Size** **Arrays**


In Solidity, both fixed-size and dynamic arrays support the <mark>`.length`</mark> property, allowing

developers to easily determine the size of an array. However, in Stylus, there is no built-in

method to access the length of <u>[fxed-size arraysi](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/array.rs)</u> <u>. This functionality is available only for dynamic</u>

arrays (referred to as vectors in Stylus). This absence of a length accessor for fixed-size arrays

may lead to inconsistencies and additional complexity in array management.


Consider implementing a built-in method to access the length of fixed-size arrays in Stylus,

similar to the <mark>`.length`</mark> property in Solidity. This enhancement would simplify array handling

and reduce the risk of errors.


**_Update:_** _Resolved at commit_ _<u>[8ab7650.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/8ab76505ccb996e22443b42b45b61526598bac62)</u>_

### **N-06 Unresolved Link to EagerStorage**


The link to <u><mark>`[super::EagerStorage](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/storage/traits.rs#L179)`</mark></u> in <mark>`traits.rs`</mark> is broken as no item named

<mark>`EagerStorage`</mark> exists in the <mark>`storage`</mark> module.


Consider updating or removing the broken link to ensure accurate documentation and avoid

confusion for developers.


**_Update:_** _Resolved at commit_ _<u>[9b221c8.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/9b221c88fa077f49c08ca657a420c917330a71e4)</u>_


Stylus Rust SDK Audit − Notes & Additional Information − 30


### **N-07 Typographical Errors**

Throughout the codebase, multiple instances of typographical errors were identified:








<u><mark>`[inheritence](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L260)`</mark></u> should be <mark>`inheritance`</mark> <mark>.</mark>

<u><mark>`[occured](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-sdk/src/hostio.rs#L75)`</mark></u> should be <mark>`occurred`</mark> <mark>.</mark>



Consider fixing the aforementioned typographical errors in order to improve the readability of

the codebase.


**_Update:_** _Resolved at commit_ _<u>[5052d30.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/5052d308f98525a32b06319b1f47f4ab296ef6f1)</u>_

### **N-08 External Macro Attribute Handling** **Inconsistency**


[The external macro currently accepts attributes](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L19) that are not utilized in its implementation. This

can lead to confusion, especially in comparison to the entrypoint macro which <u>[throws an error](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/entrypoint.rs#L13-L15)</u>

if it receives any attributes.


To ensure consistency and reduce potential confusion, consider adding validation to the

external macro implementation to reject any attributes.


**_Update:_** _Resolved at commit_ _<u>[a1267bf.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/a1267bfe56bbe7953728047082491fb4582d41c8)</u>_

### **N-09 Outdated Copyright Year**


Outdated copyright years may not reflect recent modifications or ongoing development.

Several files within the codebase have outdated copyright years, including the <u>[license](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/licenses/COPYRIGHT.md)</u> file.

Other examples include:








```
tx.rs
lib.rs
block.rs

```


Consider updating all outdated copyrights to signal active maintenance and attention to detail.


**_Update:_** _Resolved at commit_ _<u>[d57458d.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/d57458d237d1558d6205fa864a50c4bb88b14ebd)</u>_


Stylus Rust SDK Audit − Notes & Additional Information − 31


### **N-10 Todo Comments in the Code**

During development, having well-described TODO comments will make the process of tracking

and solving them easier. Without this information, these comments might age and important

information for the security of the system might be forgotten by the time it is released to

production. These comments should be tracked in the project's issue backlog and resolved

before the system is deployed.


Throughout the codebase, multiple instances of TODO comments were identified:


   - <u>[Line 31](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L31)</u> and <u>[Line 270](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/methods/external.rs#L270)</u> of <mark>`external.rs`</mark>

   - <u>[Line 279](https://github.com/OffchainLabs/stylus-sdk-rs/blob/62bd8318c7f3ab5be954cbc264f85bf2ba3f4b06/stylus-proc/src/storage/proc.rs#L279)</u> of <mark>`proc.rs`</mark>


Consider removing all instances of TODO comments and instead tracking them in the issues

backlog. Alternatively, consider linking each inline TODO comment to the corresponding issues

backlog entry.


**_Update:_** _Resolved at commit_ _<u>[73dbc1c.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/73dbc1ca1d86becaca76236689e7488de98b512f)</u>_


Stylus Rust SDK Audit − Notes & Additional Information − 32


## **Conclusion**

The Stylus SDK allows smart contract developers to build applications for the Arbitrum

ecosystem using the Rust language. These Stylus programs are compiled to WebAssembly

(WASM) and can be deployed on-chain to run alongside Solidity smart contracts. This

innovative approach aims to combine the efficiency of WASM execution with the robustness of

programming in Rust, all the while maintaining compatibility with the Ethereum Virtual Machine.


During the security audit of the Stylus SDK, we discovered numerous security issues and also

made extensive recommendations for the improvement of the overall design. The project is

clearly still under development, having several features that are either non-functional or contain

bugs. However, the development team showed a strong commitment to addressing these

concerns and we encourage them to continue their efforts. Once all the identified issues are

resolved, further improvements are made, and the project reaches a more mature stage, we

strongly recommend the team to consider conducting a follow-up audit to ensure

comprehensive security.


Despite the current challenges, we see great potential in the Stylus SDK. We look forward to

seeing how the project evolves, particularly as the team addresses the identified issues and

continues to refine the SDK. We believe that further development of the Stylus SDK could

introduce exciting new possibilities to the Arbitrum ecosystem and the broader world of smart

contract development.


Stylus Rust SDK Audit − Conclusion − 33


