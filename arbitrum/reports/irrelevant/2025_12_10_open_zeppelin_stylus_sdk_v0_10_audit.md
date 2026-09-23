### | security

# **Arbitrum Stylus** **SDK v0.10 Audit**

#### **December 10, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  6

Stylus SDK 6

Cargo Stylus 6


Security Model and Trust Assumptions _______________________________________________  7


Critical Severity ____________________________________________________________________  8

C-01 Contracts Can Never Be Verified 8


High Severity ______________________________________________________________________  8

H-01 get-initcode Command is Non-Functional 8

H-02 Check and Deploy Ignores --features Flag Producing Incorrect Bytecode 9

H-03 required_slots Undercounts After Packed Bytes Followed By a Multi-Word Field 9


Medium Severity _________________________________________________________________ 10

M-01 hash_project Function Returns Default Hash, Undermining Build Integrity 10

M-02 Docker Helpers Skip Exit-Status Checks 11

M-03 Unaddressed todo!() Instances 11

M-04 Project Hash Is Stripped During Wasm Processing 12

M-05 Inflexible Deployment Prelude Can Lead to Unverifiable Contracts 12

M-06 Verification Failure Due to Bytecode Mismatch Silently Returns Success 13

M-07 Missing Transaction Receipt Status Validation in Cache and Activation Operations 13

M-08 Reproducible Verify Omits --deployment-tx Flag Causing CLI Parse Failure 14

M-09 account_code Returns Box Pointer Size Instead of Actual Code Length 14

M-10 Overload Disambiguation Suffixes Can Collide with User-Defined Function Names 15

M-11 run_reproducible Panics on Local Crates 15

M-12 Missing Contract Selection Propagation in Reproducible Verification 16

M-13 C Router Ignores Fallback/Receive Payability Semantics 16

M-14 C Bindings Can Be Generated With Invalid Header 17

M-15 Negative Mapping Keys Can Derive Incompatible Solidity Slots 18

M-16 Zero-Sized Structs and Arrays in Storage Cause Layout Misalignment 18

M-17 Arguments of Tuple Type Render Incorrect Function Selectors and ABI 19

M-18 Multiple Mutating Call Accessors Can Exist Simultaneously 20

M-19 BuildArgs Does Not Consider source_files_for_project_hash 21


Arbitrum Stylus SDK v0.10 Audit − Table of Contents − 2


Low Severity ____________________________________________________________________ 22

L-01 Missing Cap on data_fee_bump_percent in Activation Contract 22

L-02 Insufficient and Inconsistent In-line Documentation 22

L-03 Misleading Error Message 23

L-04 Incomplete Deprecated Network Check 23

L-05 Improper Handling of Missing Docker Base Image During Reproducible Build 23

L-06 Unused Code 24

L-07 Prelude Mismatch Is Never Detected During Failed Verification 25

L-08 Incorrect Output In Cache Status Reporting 26

L-09 Unbounded Ancestor Search For rust-toolchain.toml Can Lead to Incorrect Toolchain Usage 26

L-10 Unpinned Docker Base Image Tag Undermines Reproducibility 27

L-11 Vulnerable Dependencies 27

L-12 Unchecked Type During ABI Decoding 28

L-13 Unsanitized Function Identifiers Can Break Interoperability 28

L-14 Architecture Dependent Key Encoding Can Cause Discrepancies 29

L-15 Non-Literal Fixed-Size Arrays Can Cause Selector Mismatches 29

L-16 Raw Actions Default to Copying Unbounded Return Data 30

L-17 Replay Command is Broken on Windows 31


Notes & Additional Information ____________________________________________________ 31

N-01 Typographical Errors 31

N-02 Silent Overflow in Gas Cost Estimation Returns Zero 32

N-03 Incorrect Assignment of WASM Lengths in Verification Failure 32

N-04 Inconsistent Logging Pattern 33

N-05 Lack of Explicit Check 33

N-06 Formatting Issues 33

N-07 Unnecessary Flags for Special Function Names 34

N-08 Inconsistent Function Availability 35

N-09 Unused WASM Build 35

N-10 Unused stable_rust Flag 35


Conclusion ______________________________________________________________________ 37


Arbitrum Stylus SDK v0.10 Audit − Table of Contents − 3


## **Summary**

**Type** SDK


**Timeline** From 2025-10-20
To 2025-11-07
From 2025-11-24
To 2025-11-28


**Languages** Rust



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



1 (1 resolved)


3 (3 resolved)


19 (3 resolved, 1 partially resolved)



**Total Issues** 50 (7 resolved, 2 partially resolved)



**Low Severity Issues** 17 (0 resolved, 1 partially resolved)



**Notes & Additional**
**Information**



10 (0 resolved)



Arbitrum Stylus SDK v0.10 Audit − Summary − 4


## **Scope**

[OpenZeppelin audited the OffchainLabs/stylus-sdk-rs](https://github.com/OffchainLabs/stylus-sdk-rs) library at commit <u>[4003c3f](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71)</u> (v0.10-rc.1).

[This is a follow-up to the v0.9.0 release, focusing on the refactors and newly added features.](https://github.com/OffchainLabs/stylus-sdk-rs/releases/tag/v0.9.0)


In scope are all the changes made in the following directories:

```
├── cargo-stylus/**/*.rs
├── stylus-tools/**/*.rs
├── stylus-core/src/**/*.rs
├── stylus-proc/src/**/*.rs
└── stylus-sdk/src/**/*.rs

```

Subsequently, a diff audit was performed between commit <u>[c79fa8b](https://github.com/OffchainLabs/stylus-sdk-rs/tree/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3)</u> [and commit 4003c3f. For](https://github.com/OpenZeppelin/rust-contracts-stylus/tree/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71)

this audit, the scope was expanded to include <mark>`cargo-stylus/**/*.rs`</mark> and <mark>`stylus-`</mark>

<mark>`tools/**/*.rs`</mark> as well.


Arbitrum Stylus SDK v0.10 Audit − Scope − 5


## **System Overview**

### **Stylus SDK**

The changes under review introduce a series of improvements, including breaking changes,

new features, and important bug fixes that expand the library's scope and usability.


A refactor of the Stylus SDK included the unification of host interactions through a single <mark>`VM`</mark>

struct delegating to an updated <mark>`Host`</mark> trait, eliminating global helpers. Cross-contract calls

and deployments were overhauled with a type safe <mark>`Call`</mark> builder alongside standalone

functions. ABI generation was modernized with the addition of <mark>`SELECTOR_ABI`</mark> encodings

and <mark>`abi_encode_return`</mark> methods to fix selector mismatches and tuple encoding issues,

and ensure precise Solidity alignment. A high-level event emission helper was added to

existing low-level logging functionality.


Storage types now expose <mark>`HostAccess`</mark> implementations and correct borrow lifetimes, with

vectors and maps receiving safety cleanups and more clear mutability rules. Explicit wrapping

and checking arithmetic helper functions were added, and ABI encoding has been aligned with

the <mark>`AbiType`</mark> interface which replaced old SolType based paths, standardizing how return

data is produced.


The procedural macros have been updated to reflect these structural changes, including

macros generating method selectors, ABI encoders/decoders, and purity metadata using the

SDK’s own <mark>`AbiType`</mark> abstraction instead of SolType-based helpers. Generated entry points

now operate through the <mark>`VM`</mark> object, aligning with the refactored host interactions model

throughout the codebase.

### **Cargo Stylus**


The codebase has been restructured from a monolithic repository into a modular architecture

with two main components: <mark>`cargo-stylus`</mark> (CLI interface and command parsing) and

<mark>`stylus-tools`</mark> (core functionality for building, deploying, and managing contracts). The CLI

now supports Cargo workspaces, allowing developers to build and deploy multiple contracts

within a single workspace structure, with contracts marked by a <mark>`Stylus.toml`</mark> configuration

file that will support per-contract and workspace-wide configuration options.


Arbitrum Stylus SDK v0.10 Audit − System Overview − 6


The <mark>`deploy`</mark> command has been significantly enhanced: it now supports contracts with

constructors, including <mark>`payable`</mark> constructors, via <mark>`--constructor-args`</mark> and <mark>`--`</mark>

<mark>`constructor-value`</mark> flags. Deployment now uses a unified <mark>`StylusDeployer`</mark> contract that

handles deployment, activation, and constructor initialization. The <mark>`verify`</mark> command now

explicitly supports Docker-based reproducible builds, ensuring local builds match deployed

bytecode. While this improves verification reliability, it introduces Docker as a dependency and

requires a review of the Docker image management, build reproducibility, and potential supply

chain risks.

## **Security Model and Trust** **Assumptions**


The system now assumes that any provided <mark>`Host`</mark> implementation is correct and that callers

will enforce their own contract-level invariants when using low-level call or deployment APIs.


The SDK defines no privileged roles. As such, trust assumptions must be designed at the

application layer.


Arbitrum Stylus SDK v0.10 Audit − Security Model and Trust Assumptions −

7


## **Critical Severity**

### **C-01 Contracts Can Never Be Verified**

The <mark>`verify`</mark> [function determines whether a deployment transaction includes a constructor](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L30)

<u>[call](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L30)</u> by decoding the transaction input via <mark>`deployCall::abi_decode`</mark> <mark>,</mark> expecting the

<u><mark>`[deploy](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/deployment/deployer.rs#L28)`</mark></u> <u>selector</u> as the first four bytes. However, this approach only works for contracts

deployed through the <u>[Stylus deployer contract, which wraps constructor calls.](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/deployment/deployer.rs#L21)</u>


Contracts without constructors can be deployed directly using a standard <u><mark>`[CREATE](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/deployment/mod.rs#L190)`</mark></u> <u>call, in</u>

which case the transaction input will not follow the expected ABI format. As a result,

<mark>`abi_decode`</mark> will always for such deployments. Even when a constructor is detected,

verification will still fail because <mark>`verify_constructor_deployment`</mark> is currently

<u>[unimplemented. In practice, this means that the](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L81)</u> <mark>`verify`</mark> function fails for all deployment

types, both with and without constructors.


Consider refactoring the verification logic to correctly handle contracts that do and do not use

Stylus constructors for deployments.


**_Update:_** _[Resolved at commit cc54d33.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/cc54d33834fee0308380881b930b5eeca62befa2)_

## **High Severity**

### **H-01 get-initcode Command is Non-Functional**


The <mark>`cargo stylus get-initcode`</mark> command is intended to generate and print the initcode

for a contract. However, it is currently non-functional. The command's <mark>`exec`</mark> function in

<mark>`get_initcode.rs`</mark> <u>[panics](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/get_initcode.rs#L26)</u> when the <mark>`--output`</mark> flag is omitted. The documented behavior is

[to default to stdout, but the implementation contains a](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/get_initcode.rs#L14) <u><mark>`[todo!()](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/get_initcode.rs#L26)`</mark></u> macro in the <mark>`None`</mark> branch.


The execution then proceeds to <u>[call](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/initcode.rs#L28)</u> the <mark>`ops::write_initcode`</mark> function, with or without the

<mark>`output`</mark> argument. This underlying function, which is responsible for building the WASM,

compressing it, and generating the initcode, has its entire implementation <u>[commented out.](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/initcode.rs#L9-L20)</u>


Arbitrum Stylus SDK v0.10 Audit − Critical Severity − 8


As a result, even if the command were to execute, it would perform no action and simply return

<u><mark>`[Ok(())](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/initcode.rs#L21)`</mark></u> <mark>,</mark> producing an empty output. These two issues make the <mark>`get-initcode`</mark> command

unusable. Users attempting to use it will either encounter a panic (if no <mark>`--output`</mark> is specified)

or get an empty file, contrary to the feature's purpose.


Within <mark>`initcode.rs`</mark> <mark>,</mark> consider implementing logic to correctly build, compress, and write the

initcode. In addition, consider replacing <mark>`todo!()`</mark> in <mark>`get_initcode.rs`</mark> with logic that uses

<mark>`std::io::stdout()`</mark> as the writer when the <mark>`--output`</mark> flag is not provided.


**_Update:_** _[Resolved at commit 4b70765.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/4b70765b7417294e6cae294d96d6cdd80b50399b)_

### **H-02 Check and Deploy Ignores --features Flag** **Producing Incorrect Bytecode**


The <mark>`deploy`</mark> subcommand constructs its configuration via <u><mark>`[DeployArgs::config](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/deploy.rs#L78-L89)`</mark></u> <mark>,</mark> which

takes a <mark>`CheckArgs`</mark> and discards <mark>`BuildArgs`</mark> <mark>.</mark> <mark>`CheckArgs::config`</mark> returns a

<mark>`CheckConfig`</mark> with a <u>default</u> <u><mark>`[BuildConfig](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/common_args.rs#L133-L139)`</mark></u> <mark>,</mark> leaving the features list empty. At the same

time, <u><mark>`[CheckConfig](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/check.rs#L22-L27)`</mark></u> includes a <mark>`build`</mark> field consumed by <mark>`check_contract`</mark> and

<u><mark>`[build_contract](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/build/mod.rs#L54-L62)`</mark></u> <mark>,</mark> which is used, for example, in <mark>`cargo stylus check`</mark> <mark>.</mark> However, the

check command is built from <u><mark>`[ActivationArgs](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/check.rs#L42-L47)`</mark></u> only, resulting in the same default build

config. As a result, deployment and check builds ignore CLI features and produce default
feature bytecode. This leads to incorrectly deployed bytecode for contracts that are expected

to be deployed or checked with any features turned on.


Consider threading <mark>`BuildArgs.features`</mark> into <mark>`CheckConfig.build`</mark> for the build step

during deployment and contract checking.


**_Update:_** _[Resolved at commit 8534421.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/8534421056eb3eeafcdb342f5d69279448238c89)_

### **H-03 required_slots Undercounts After Packed** **Bytes Followed By a Multi-Word Field**


The <mark>`#[storage]`</mark> macro computes storage layout via two divergent paths:









<u><mark>`[init](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-proc/src/macros/storage.rs#L361-L372)`</mark></u> <mark>:</mark> When placing a multi-word field (e.g., <mark>`StorageArray`</mark> <mark>)</mark>, it first aligns to a new

slot if the remaining intra-slot space cannot fit the field’s byte-sized header, and then

reserves the field’s full slot count.

<u><mark>`[size](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-proc/src/macros/storage.rs#L393-L401])`</mark></u> <mark>:</mark> For multi-word fields, it skips this pre-alignment check, directly adding the field’s

slot count to the total without accounting for partial intra-slot space.


Arbitrum Stylus SDK v0.10 Audit − High Severity − 9


This mismatch causes <mark>`REQUIRED_SLOTS`</mark> to undercount slots when a small "packed" field

(e.g., <mark>`StorageBool`</mark> <mark>)</mark> precedes a multi-word field. In nested layouts, parent structs will then

rely on the undercounted slot count of child structs, placing subsequent fields one slot too

early. This creates slot overlap and persistent storage corruption.


Consider modifying the compile-time <mark>`size`</mark> logic to mirror the runtime <mark>`init`</mark> logic for multi
word fields. Specifically, the branch that handles multi-word fields should first perform the

same byte-packing alignment check that the runtime does, advancing to a new slot if the

field's header does not fit in the remaining space. This alignment should be checked before

adding the field’s full slot count, which will ensure that the calculated <mark>`REQUIRED_SLOTS`</mark>

constant accurately matches the actual storage slots consumed at runtime.


**_Update:_** _[Resolved at commit 646c545.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/646c54545b26521cdeab041fdfbf8afc17be99a0)_

## **Medium Severity**

### **M-01 hash_project Function Returns Default** **Hash, Undermining Build Integrity**


The <mark>`hash_project`</mark> function, responsible for generating a unique hash representing a

project's source code, is currently incomplete. Instead of computing a hash based on the

project’s actual source files and configuration, it returns a <u>[default hash. This value is used by](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/project/hash.rs#L19)</u>

downstream processes, including the <mark>`cargo stylus check`</mark> and <mark>`cargo stylus verify`</mark>

commands, which relies on the <mark>`ProjectHash`</mark> for build reproducibility, source code

verification, and artifact integrity. The resulting hash is embedded into the compiled WASM

binary as a custom section named <mark>`project_hash`</mark> <mark>.</mark> Since <mark>`hash_project`</mark> does not perform

real hashing, every project produces the same hash, regardless of its content.


The <mark>`cargo stylus check`</mark> command builds the WASM and calls the

<mark>`process_wasm_file`</mark> function, which embeds the <mark>`project_hash`</mark> into the binary. When

run without a specified WASM file, it <u>[calls](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/check.rs#L56)</u> the <mark>`hash_project`</mark> function and receives a default

hash. When run with <mark>`--wasm-file`</mark> <mark>,</mark> it <u>[explicitly](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/check.rs#L56)</u> uses <mark>`ProjectHash::default()`</mark> <mark>,</mark> also

resulting in a default hash. In both cases, the checked artifact is stamped with an incorrect,

non-unique hash. This undermines the integrity of the check command and the validation

pipeline.


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 10


Consider implementing proper hashing in <mark>`hash_project`</mark> to compute a deterministic hash of

all relevant project sources, configuration files, and dependencies.


**_Update:_** _[Resolved at commit 5e6cfa3.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/5e6cfa379d80083e1327199a7391f3ccad36a527)_

### **M-02 Docker Helpers Skip Exit-Status Checks**


The <u><mark>`[wait()](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/utils/docker/cmd.rs#L27)`</mark></u> and <u><mark>`[run()](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/utils/docker/cmd.rs#L91-L95)`</mark></u> functions in <mark>`docker/cmd.rs`</mark> treat any <mark>`wait()`</mark> return as a

success, unless there is an OS-level spawn or wait error (e.g., docker is not running). These

function do not check the child process’s exit code. As a result, docker commands that fail

within the child process (for instance, exit code 1) are still reported as <mark>`Ok(())`</mark>, causing the

downstream processes, such as reproducible build and verification, to appear successful even

when the underlying Docker invocation failed.


Consider checking the <mark>`ExitStatus`</mark> of the child process, and in case of failure, returning a

relevant error message.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We have not encountered any issues with this due to our limited and consistent use of

docker commands. We have noted this suggestion if we rework our docker usage and

wish to add the extra sanity checks.

### **M-03 Unaddressed todo!() Instances**


In addition to the existing <mark>`todo!()`</mark> placeholders that leave the initcode and verification

features incomplete, there are several other parts of the codebase where <mark>`todo!()`</mark> is used in

place of the expected implementation:










In <u><mark>`[abi.rs](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/reflection/abi.rs#L10)`</mark></u>

In <mark>`solc.rs`</mark> <mark>,</mark> <u>[here](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/utils/solc.rs#L11)</u> [and here](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/utils/solc.rs#L15)

In <u><mark>`[frame.rs](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/stylus-tools/src/core/tracing/frame.rs#L359)`</mark></u>

In <u><mark>`[git.rs](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/stylus-tools/src/utils/git.rs#L24)`</mark></u>



Consider replacing all instances of <mark>`todo()!`</mark> with the appropriate implementation to avoid

unexpected panic scenarios during normal usage of the CLI tool.


**_Update:_** _Partially resolved in_ _<u>[PR 372](https://github.com/OffchainLabs/stylus-sdk-rs/pull/372)</u>_ _[and at commit 347439d.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/347439d74e04547fc752733b3565a06eb11ef7b9)_ There remains an unaddressed

<mark>`todo!()`</mark> in <mark>`frame.rs`</mark> <mark>.</mark>


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 11


### **M-04 Project Hash Is Stripped During Wasm** **Processing**

In the <mark>`process_wasm_file`</mark> function, which is used during contract checking and

[deployment, the project hash is added as a custom section](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/wasm.rs#L30) to the WASM binary for use in

reproducible build verification. However, all custom sections, including this project hash, are

later <u>[removed](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/utils/wasm.rs#L91)</u> by the <mark>`strip_user_metadata`</mark> function. As a result, the project hash

metadata is never actually included in the deployed bytecode, potentially weakening the

verification process. Any future verification feature relying on the embedded project hash will

not work with contracts deployed using the current cargo stylus workflow.


Consider adding logic to detect the project hash section and skip removing it in the

<mark>`strip_user_metadata`</mark> function.


**_Update:_** _[Resolved at commit cae943d.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/cae943dcb0f4cc4bdf68317689a4a446ee9789a5)_

### **M-05 Inflexible Deployment Prelude Can Lead to** **Unverifiable Contracts**


[The deployment prelude](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/deployment/prelude.rs#L19) is currently hardcoded, making it inflexible for verifying contracts that

may have been deployed with a different prelude. Since <mark>`verify`</mark> [checks the deploy](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L39)

<u>[transaction calldata](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L39)</u> against locally built WASM from the current SDK, this can fail for contracts

that were deployed using older versions of <mark>`cargo stylus`</mark> [that appended a hash after the](https://github.com/OffchainLabs/cargo-stylus/blob/884f8d8282d5383fc296adc2c488c40bb36f1a01/check/src/deploy.rs#L249-L250)

<u>[version. It is also possible that future versions may change the version byte or modify the](https://github.com/OffchainLabs/cargo-stylus/blob/884f8d8282d5383fc296adc2c488c40bb36f1a01/check/src/deploy.rs#L249-L250)</u>

existing prelude.


Consider refactoring verification to remain flexible with older or updated versions of the

deployment prelude.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Having the required static prelude is necessary for our current verification strategy. So

far we have not been made aware of any desire for custom contract preludes, but we

can explore that if a use-case is brought to our attention.


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 12


### **M-06 Verification Failure Due to Bytecode** **Mismatch Silently Returns Success**

The <mark>`verify`</mark> function calls <u><mark>`[verify_create_deployment](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L43)`</mark></u> <mark>,</mark> when the contract being verified

does not have a constructor, which returns

<mark>`VerificationStatus::Failure(VerificationFailure)`</mark> in case of a mismatch

between the deployed and locally built codes. However, this is not propagated as an error and

<mark>`verify`</mark> function returns <mark>`Ok(())`</mark> <mark>,</mark> mapping to exit code 0. Hence, any attempted verification

that fails due to bytecode mismatch will report no error, which can lead to users believing that

their contract was successfully verified.


Consider explicitly handling <mark>`VerificationStatus`</mark> in the CLI: print details on <mark>`Failure`</mark> and

return a non-zero exit status so that mismatches can be properly detected and handled.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Currently investigating.

### **M-07 Missing Transaction Receipt Status** **Validation in Cache and Activation Operations**


The <u><mark>`[place_bid](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/cache.rs#L75)`</mark></u> and <u><mark>`[activate_contract](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/activation.rs#L82)`</mark></u> functions fail to validate transaction receipt

status after sending on-chain transactions, resulting in false success reporting when

transactions revert. Both functions call <mark>`.get_receipt().await?`</mark> without subsequently

checking <mark>`receipt.status()`</mark> <mark>,</mark> unlike the correctly implemented

<u><mark>`[DeploymentRequest::exec](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/deployment/mod.rs#L104-L106)`</mark></u> which explicitly validates status and returns

<mark>`DeploymentError::Reverted`</mark> on failure. While pre-execution simulations using <mark>`.call()`</mark>

provide some protection, they cannot guarantee transaction success due to state changes

between simulation and execution. This can lead users to believe that operations succeeded

when they consumed gas without achieving the intended state change, and may result in

repeated failed attempts without proper error feedback.


Consider checking status receipts and handling errors on failure.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We have currently not encountered any issues without the additional checks, but we

have made a note to ensure error handling is more robust in the future.


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 13


### **M-08 Reproducible Verify Omits --deployment-** **tx Flag Causing CLI Parse Failure**

The <mark>`verify`</mark> command in reproducible mode (default) constructs invalid <u>[CLI arguments](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/verify.rs#L46-L48)</u> when

passing transaction hashes to the Docker container, causing verification to fail silently. The

verify command only accepts <mark>`--deployment-tx`</mark> as a named flag, causing clap to reject the

hash as an unexpected positional argument. This results in immediate command-line parsing

failure inside the Docker container. Due to a separate bug where <mark>`wait()`</mark> succeeds, but the

exit status is never checked, this parsing failure returns <mark>`Ok(())`</mark> to the caller, making the

verification command appear successful when it actually failed. Users running <mark>`cargo stylus`</mark>

<mark>`verify`</mark> without <mark>`--no-verify`</mark> (the default path for reproducible verification) do not receive

any error feedback and incorrectly believe their deployed contracts have been verified,

potentially leading to unverified contracts being used in production.


Consider adding the expected CLI arguments using <mark>`cli_args.push(String::from("--`</mark>

<mark>`deployment-tx"))`</mark> before pushing the hash value, and separately checking

<mark>`status.success()`</mark> after <mark>`wait()`</mark> in the Docker run function.


**_Update:_** _[Resolved at commit d59a5c0.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/d59a5c012531332b591329c4d73a139c8041dabc)_

### **M-09 account_code Returns Box Pointer Size** **Instead of Actual Code Length**


The <u><mark>`[account_code](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/utils/hostio.rs#L199)`</mark></u> function copies the returned code bytes with the two-argument <mark>`copy!`</mark>

macro, which computes the copy length as <mark>`mem::size_of_val(&src)`</mark> <mark>.</mark> Since <mark>`code`</mark> is a

<mark>`Box<[u8]>`</mark> <mark>,</mark> this copies only the boxed fat-pointer size (typically two words) while the

function reports <mark>`code.len()`</mark> as the number of bytes written. The result is truncated writes

and inconsistent return lengths. This behavior corrupts local replay/debugging: consumers

trust the returned length and read uninitialized memory beyond what was actually written.

Other paths correctly use the three-argument form with the real length (for instance,

<u><mark>`[read_return_data](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/utils/hostio.rs#L822)`</mark></u> uses <mark>`copy!(data, dest, data.len())`</mark> <mark>)</mark> .


Consider switching <mark>`account_code`</mark> to copy <mark>`code.len()`</mark> bytes (the three-argument <mark>`copy!`</mark>

form), or refactor the macro to reject unsized sources for the two-argument variant. This will

ensure that the number of bytes written matches the returned length and preserve replay

correctness.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 14


We are exploring the proposed solution here to avoid making a change which fails to

consider all aspects of the current funcitonality.

### **M-10 Overload Disambiguation Suffixes Can** **Collide with User-Defined Function Names**


The <mark>`c_gen`</mark> function in <mark>`codegen.rs`</mark> resolves function overloads by <u>[appending](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L67-L74)</u> numeric

suffixes (e.g., _1, _2) to create unique C identifiers. However, this mechanism can lead to a

name collision if a user defines a distinct function with a name that matches a generated

suffixed name, for instance, defining functions <mark>`f()`</mark> and <mark>`f(uint)`</mark> alongside a separate

function named <mark>`f_1()`</mark> results in duplicate <mark>`SELECTOR_f_1`</mark> macros and multiple router

branches comparing against the same selector.


Consequently, this may cause compile-time errors due to macro redefinition. If the compilation

succeeds by accepting the last macro definition as the correct one, it may lead to incorrect

[function routing](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L105-L110) at runtime, where calls intended for one function are dispatched to another,

potentially causing inconsistent payability checks and unexpected behavior.


Consider enforcing global uniqueness of generated C identifiers by reserving the numeric suffix

space such as mangling literal names that end with a numeric suffix or by adopting a

disambiguation scheme that cannot collide, such as hashing full function signatures. In

addition, consider introducing static assertions or generator-time errors when a collision is

detected to prevent the generation of ambiguous routers.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Generation of C bindings for Stylus should be revisited at a later release. These

suggestions will be taken into consideration at that time.

### **M-11 run_reproducible Panics on Local Crates**


The <mark>`run_reproducible`</mark> function in <mark>`reproducible.rs`</mark> <u>[utilizes](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/build/reproducible.rs#L28-L33)</u>

<mark>`package.source.unwrap().repr`</mark> to construct the host path for Docker bind mounts. For

local crates, <mark>`package.source`</mark> is <mark>`None`</mark> <mark>,</mark> as these crates are sourced directly from the local

filesystem and not from an external registry or git repository. When the code attempts to call

<mark>`.unwrap()`</mark> on this <mark>`None`</mark> value, it triggers a panic, causing the <mark>`cargo stylus`</mark> process to

crash immediately.


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 15


Consider using <mark>`package.manifest_path.parent()`</mark> as the host path for handling cases

such as the aforementioned.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We are exploring the proposed solution here to avoid making a change which fails to

consider all aspects of the current funcitonality.

### **M-12 Missing Contract Selection Propagation in** **Reproducible Verification**


When performing contract verification with the reproducible Docker container, the <mark>`--`</mark>

<mark>`contract`</mark> selection is not forwarded to the inner CLI invocation. <mark>`cargo stylus verify`</mark>

spawns a reproducible containerized run when verification is enabled. The <u>[argument list](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/verify.rs#L46-L48)</u> is built

as ['verify', '--no-verify'] and only the raw transaction hash is appended. The <mark>`--contract`</mark>

selections are not propagated.


Consequently, inside the container, the CLI recomputes the contract set using

<mark>`ProjectArgs::contracts()`</mark> <mark>,</mark> [which defaults](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/common_args.rs#L178-L186) to <mark>`workspace.default_contracts()`</mark>

when no <mark>`--contract`</mark> is provided. In multi-contract workspaces, this can lead to the

verification of additional or unintended contracts within the container, resulting in misleading

verification outcomes and wasted CI time.


Consider forwarding every user selection that affects contract resolution into the reproducible

invocation. For example, include a <mark>`--contract <pkg>`</mark> flag per selected package in the

<mark>`cli_args`</mark> that are passed to the container, and ensure that the inner CLI receives the exact

same contract set. Adding tests that assert the inner/outer selections match would further

reduce regression risk.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Currently investigating.

### **M-13 C Router Ignores Fallback/Receive** **Payability Semantics**


The C router generated by <u><mark>`[c_gen](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L16)`</mark></u> <u>function</u> dispatches short calldata and unknown selectors

to a default handler, forwarding <mark>`msg.value`</mark> and without any awareness of ABI fallback/

receive entries. Specifically, the router template retrieves <mark>`msg_value`</mark> and, if <mark>`len < 4`</mark> <mark>,</mark> it


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 16


returns <u><mark>`[default_func](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L244-L249)`</mark></u> <mark>.</mark> However, on selector mismatch, it falls through to <u><mark>`[default_func](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L254-L257)`</mark></u>

again. In contrast, for matched functions the generator emits a non- <u><mark>`[payable](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L106-L108)`</mark></u> <u>guard</u> that

reverts on non-zero value. The generator only <u>[iterates](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L56-L59)</u> <mark>`abi.functions()`</mark> and does not

account for ABI fallback or receive entries, nor does it synthesize dedicated handlers.


As a result, when a contract’s ABI expects a revert for non <mark>-</mark> <mark>`payable`</mark> fallback/receive, the

generated router may accept value and invoke <mark>`default_func`</mark> instead. This diverges from

EVM payability semantics and can lead to silent ETH acceptance in projects that rely on the

generator’s default path without adding explicit guards in <mark>`default_func`</mark> <mark>.</mark>


Consider extending the generator to handle fallback vs receive semantics explicitly and to

enforce a <mark>`value == 0`</mark> check on the default dispatch path when the ABI indicates non
<mark>`payable`</mark> <mark>.</mark> Alternatively, consider synthesizing distinct receive and fallback stubs based on

ABI metadata and insert reverts for unsupported paths. If it is intended to keep a generic

<mark>`default_func`</mark> <mark>,</mark> consider emitting a generated check that reverts on a non-zero value unless

the contract declares a <mark>`payable`</mark> fallback.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Generation of C bindings for Stylus should be revisited at a later release. These

suggestions will be taken into consideration at that time.

### **M-14 C Bindings Can Be Generated With Invalid** **Header**


The C header generator constructs a preprocessor guard using a <mark>`unique_identifier`</mark>

formed by capitalizing and concatenating the Solidity file name and contract name, with no

[character filtering. This occurs when building the identiferi](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L199-L205) and emitting it into <mark>`#ifndef`</mark> <mark>/</mark>

<mark>`#define`</mark> <mark>/</mark> <mark>`#endif`</mark> <u>[lines. Since the Solidity file name is sourced from the](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L206-L226)</u> <u>JSON</u> <u><mark>`[contracts](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L31-L40)`</mark></u>,

it commonly contains characters such as `/` and `.` that are not valid in C identifiers. As a

result, generated headers may fail to preprocess or compile due to an invalid macro name in

<mark>`#ifndef`</mark> <mark>.</mark>


Consider sanitizing the header guard to <mark>`[A-Z0-9_]`</mark> <mark>,</mark> for example, by mapping invalid

characters to `_` and validating that input keys match expected patterns before generation.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Generation of C bindings for Stylus should be revisited at a later release. These

suggestions will be taken into consideration at that time.


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 17


### **M-15 Negative Mapping Keys Can Derive** **Incompatible Solidity Slots**

In <mark>`storage_sdk::storage`</mark> <mark>,</mark> <mark>`StorageMap<K,V>`</mark> derives element slots as

<mark>`keccak256(h(key) || root)`</mark> <mark>,</mark> where `h` is a function that is applied to the key depending

on its type:









For value types, h pads the value to 32 bytes in the same way as when storing the value

in memory.

For strings and byte arrays, <mark>`h(k)`</mark> is just the unpadded data.



[The SDK encodes signed keys](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/storage/map.rs#L186-L191) by left‑padding with zeros. Primitive signed integers follow the

[same pattern via an unsigned cast in impl_key!. This produces a 32‑byte, zero‑extended](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/storage/map.rs#L246-L263)

representation for negative values with bit‑width < 256.


For Solidity storage compatibility, signed integers must be sign‑extended to 32 bytes in the

preimage. For example, <mark>`int8(-1)`</mark> should hash <mark>`0xff..ff || slot`</mark> <mark>.</mark> However, but the

current SDK encodes <mark>`0x00..00ff || slot`</mark> <mark>,</mark> yielding a different hash. This causes

cross‑language storage divergence for negative keys and can break migrations or

multi‑language access patterns and external tooling relying on the Solidity layout. Within the

SDK, reads/writes remain self‑consistent, but interop with Solidity will target different slots.


[Following the Solidity encoding specifications, consider sign‑extending signed keys that hold](https://docs.soliditylang.org/en/v0.8.30/abi-spec.html#formal-specification-of-the-encoding)

less than 256 bits to 32 bytes before hashing to match Solidity’s storage encoding. Doing so

will avoid discrepancies between the storage layouts of both languages.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We currently attempt to be as close as possible to Solidity storage, but there are

instances where we are comfortable diverging. The case reported here will be

investigated and either documented as different, or changed. The biggest consideration

on our side is the avoid making a breaking change from stylus -> stylus which would

harm upgradability.

### **M-16 Zero-Sized Structs and Arrays in Storage** **Cause Layout Misalignment**


Within the <u><mark>`[stylus_proc::macros::storage](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/storage/mod.rs)`</mark></u> module, the logic for calculating

<mark>`REQUIRED_SLOTS`</mark> incorrectly handles zero-sized types, causing them to occupy one full

storage slot.


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 18


This issue manifests in two related ways:









**Unit/Empty Structs** : The storage macro computes <mark>`REQUIRED_SLOTS = 1`</mark> for empty

structs. In the parent’s <mark>`init`</mark> and <mark>`size`</mark> logic, this empty child causes a slot bump and

resets packing space.

**Zero-Length Arrays** : The <mark>`StorageArray<T, 0>`</mark> struct correctly defines

<mark>`REQUIRED_SLOTS`</mark> as 0, but inherits the 32-byte <mark>`SLOT_BYTES`</mark> default. The storage

macro's packing logic subtracts these 32 bytes when <mark>`REQUIRED_SLOTS == 0`</mark> <mark>,</mark> which

is visible in the macro’s initializer and sizer.



As a result, both zero-length <mark>`StorageArray<T, 0>`</mark> and empty structs consume 32 bytes in

their parent struct, creating a layout hole and shifting subsequent fields by one slot. This

breaks Solidity compatibility, diverges from expectations when mirroring Solidity layouts, and

can silently corrupt storage.


The empty slot is never accessed, yet the physical span of the parent increases, which can

desynchronize Stylus and Solidity storage roots and break upgrades. For example, when

upgrading a proxy contract's implementation from Stylus to Solidity, developers must take into

account empty fields, replacing them with 32-byte dummy fields to avoid storage

misalignment.


Consider disallowing empty storage fields and rejecting zero-length fixed arrays at parse time.

This would resolve the ambiguity, as these types do not hold any information and cause

confusion. This change guarantees that the required slots are accurately computed at compile
time to reflect the runtime storage layout and restores compatibility with Solidity, allowing

developers to migrate between languages and integrate proxy contracts without facing

unexpected issues.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Usage of these patterns is not supported. We will be updating our documentation to

reflect this, and implemented proper error reporting at a later date.

### **M-17 Arguments of Tuple Type Render Incorrect** **Function Selectors and ABI**


Within the <mark>`stylus_proc::types`</mark> module, the <mark>`sol_interface`</mark> pipeline converts Solidity

types to a pair of Rust and Solidity representations. The problem arises when function

arguments are of the Rust tuple type, leading to incorrectly generated function selectors and

ABIs. For single-element tuples, <mark>`SolidityTypeInfo::from`</mark> has a special case that returns


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 19


the inner type entirely. As a result, the stored <mark>`sol_type`</mark> for a parameter declared as a single
element tuple holds the inner type without parentheses. The selector preimage is then

constructed from <mark>`sol_type.to_string()`</mark> <mark>,</mark> making the function signature indistinguishable

from one declared with a bare inner type parameter and computing an incorrect selector.


For empty and multi-element tuples, another issue arises. The function selectors are exported

semantically correct as tuples. However, this syntax is then rendered directly into the exported

Solidity interface. This makes it impossible for Solidity contracts to use the exported interface

since it will fail to compile. The current handling of tuple types in function arguments is

inconsistent and incorrect, leading to ABI- and selector-generation issues. Single-element

tuples are improperly unwrapped, causing selector collisions, while empty and multi-element

tuples are rendered with syntax that is not valid in Solidity.


Consider resolving these discrepancies to ensure the SDK generates correct function selectors

and produces a Solidity-compatible ABI that can be compiled and used for cross-language

interoperability.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Generation of Export ABI for Stylus should be revisited at a later release. These

suggestions will be taken into consideration at that time.

### **M-18 Multiple Mutating Call Accessors Can Exist** **Simultaneously**


The <mark>`stylus_core::calls`</mark> module offers a high-level, type-safe builder for configuring calls

to external contracts. The central <mark>`Call`</mark> struct uses constant generics and configuration

methods to define a call's parameters. The main <mark>`Call`</mark> struct uses const generics and builder

methods to set a call's parameters. The <mark>`StaticCallContext`</mark> <mark>,</mark> <mark>`NonPayableCallContext`</mark> <mark>,</mark>

and <mark>`MutatingCallContext`</mark> traits then use this configuration to provide compile-time safety.


Within the <mark>`stylus_core::calls`</mark> module, <mark>`MutatingCallContext`</mark> is intended to enforce

that external calls only occur while a unique <mark>`&mut TopLevelStorage`</mark> borrow is active,

preventing reentrancy attacks. However, the mutating call types both immediately <u>[discard the](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-core/src/calls/mod.rs#L96-L112)</u>

<u>[borrow](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-core/src/calls/mod.rs#L96-L112)</u> within their constructors. As a result, the <mark>`Call`</mark> object then carries no lifetime which

ties it to the storage reference. Since <mark>`Call`</mark> also derives <mark>`Clone`</mark> <mark>,</mark> user code can create a

mutating context once and continue to use it even after obtaining a live <mark>`StorageGuardMut`</mark>

to a storage slot. An external call can then execute even with an outstanding mutable guard - if

the callee reenters then it may acquire another guard to the same slot through safe APIs,

breaking the intended aliasing barrier.


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 20


Consider threading a lifetime from <mark>`&mut TopLevelStorage`</mark> into the mutating call context so

that its use is statically restricted to the borrow window. Alternatively, consider redesigning the

API so that external calls require fresh evidence of an active borrow at each call site.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We are investigating this as a potential bypass of the reentrancy guarantees, however

since all calls in the safe interface will appropriately flush cache, this may not be an

issue.

### **M-19 BuildArgs Does Not Consider** **`source_files_for_project_hash`**


The <u><mark>`[BuildArgs](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/common_args.rs#L107)`</mark></u> <u>struct</u> in <mark>`common_args.rs`</mark> defines a command-line flag <mark>`--source-`</mark>

<mark>`files-for-project-hash`</mark> <mark>.</mark> This <u>[flag](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/common_args.rs#L118)</u> is intended to allow users to specify which source files

should be included when calculating the <mark>`project_hash`</mark> for reproducible builds and

verification.


However, the implementation of the <u><mark>`[config()](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/common_args.rs#L122-L127)`</mark></u> <u>function</u> for <mark>`BuildArgs`</mark> ignores this flag. It

only forwards the <mark>`--features`</mark> flag and returns a <mark>`BuildConfig`</mark> with default values for all

other fields. Moreover, the <mark>`source_files_for_project_hash`</mark> flag should be a part of the

<u><mark>`[ProjectArgs](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/common_args.rs#L173)`</mark></u> <u>struct</u> to align with the <u><mark>`[source_file_patterns](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/stylus-tools/src/core/project/mod.rs#L19)`</mark></u> <u>flag</u> in the

<mark>`ProjectConfig`</mark> struct.


Consider moving the <mark>`source_files_for_project_hash`</mark> flag from <mark>`BuildArgs`</mark> to

<mark>`ProjectArgs`</mark> and updating the <mark>`ProjectArgs::config()`</mark> function to use this flag to

populate the <mark>`source_file_patterns`</mark> field of the <mark>`ProjectConfig`</mark> struct.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Currently investigating, fix will be submitted as part of cargo-stylus fix/review.


Arbitrum Stylus SDK v0.10 Audit − Medium Severity − 21


## **Low Severity**

### **L-01 Missing Cap on data_fee_bump_percent in** **Activation Contract**

The <u><mark>`[activate_contract](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/activation.rs#L67)`</mark></u> function allows for adjusting the activation data fee through the

<u><mark>`[data_fee_bump_percent](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/activation.rs#L29)`</mark></u> parameter of the <mark>`ActivationConfig`</mark> struct. During the

<mark>`estimate_gas`</mark> function call, this <mark>`data_fee_bump_percent`</mark> [defaults to 20%. While this](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/activation.rs#L35)

mechanism provides flexibility in accounting for network conditions and gas fees, the lack of a

cap on the <mark>`data_fee_bump_percent`</mark> parameter introduces risk. A user could mistakenly

input an excessively high value, resulting in an inflated data fee. This could lead to unusually

high transaction costs, depleting funds, and potential transaction failures due to insufficient

balance.


Consider implementing a cap on the <mark>`data_fee_bump_percent`</mark> <mark>.</mark> This will allow the system

to maintain flexibility in adjusting for network conditions while preventing extreme user errors

that could negatively impact transaction costs.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **L-02 Insufficient and Inconsistent In-line** **Documentation**


The codebase lacks proper in-line documentation, which hinders the readability and

maintenance of the codebase. Additionally, there are instances where the documentation is

[informal, such as in lines 52-53](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/codegen.rs#L52-L53) of <mark>`codegen.rs`</mark> <mark>.</mark>


Consider adding standardized, descriptive in-line comments, as per the Rustdoc convention,

throughout the codebase. Doing so will improve code readability and consistency across

modules.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 22


### **L-03 Misleading Error Message**

<u>[This error message](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/network.rs#L8)</u> in the <mark>`network.rs`</mark> contract suggests the user to downgrade to cargo

stylus version 0.2.1 in order to connect to the <u>[deprecated Stylus testnet. However, this](https://docs.arbitrum.io/build-decentralized-apps/public-chains)</u>

guidance is outdated, as the referenced testnet is no longer supported. Encouraging users to

downgrade introduces confusion and may lead them to use obsolete tooling that is

incompatible with current network environments.


Consider updating the error message to only indicate the fact that the reference testnet is

deprecated.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **L-04 Incomplete Deprecated Network Check**


The <u><mark>`[check_endpoint](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/network.rs#L12)`</mark></u> function in <mark>`network.rs`</mark> is intended to prevent users from interacting

with deprecated testnets. However, its implementation is incomplete as it only checks for the

<u>[Stylus testnet network](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/network.rs#L13)</u> and not for the Arbitrum Goerli testnet. As such, if a user attempts to

use a deprecated but unblocked endpoint like Arbitrum Goerli, the <mark>`check_endpoint`</mark> guard

will pass. The tool will then fail at a later stage when trying to establish a provider connection.

This results in a poor user experience.


Consider adding a robust check in the <mark>`check_endpoint`</mark> function to include a

comprehensive list of known deprecated endpoints, allowing the user to fail early with a clear

error message.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **L-05 Improper Handling of Missing Docker Base** **Image During Reproducible Build**


[During the Docker image lookup, the code attempts to build a local image derived from a base](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/utils/docker/cmd.rs#L49-L54)

image hosted on Docker Hub. When the <mark>`cargo_stylus_version`</mark> parameter is not explicitly


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 23


provided, the <u>code falls back to</u> <u><mark>`[env!("CARGO_PKG_VERSION")](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/build/reproducible.rs#L25)`</mark></u> <mark>,</mark> which is embedded at

compile time. For example, release candidates like v0.10.0-rc.1 results in attempting to pull

offchainlabs/cargo-stylus-base:0.10.0-rc.1 as the base image.


The issue is that the code does not validate whether this base image actually exists on Docker

Hub before attempting to build. When the specified version has not been published to Docker

Hub, the command does not return a result, but completes successfully with <mark>`output.status`</mark>

<mark>`= 0`</mark> <mark>.</mark> The codebase does contain a check via <mark>`image_exists()`</mark> to determine if the image is

already cached locally, but there is no corresponding check to verify that the remote base

image exists on Docker Hub before attempting the build. This causes the build to fail late in the

process with an unclear error message instead of failing early with a helpful explanation.


Consider adding validation to check whether the base image exists on Docker Hub before

attempting to build. Alternatively, consider providing a fallback mechanism to use the latest

stable version when the requested version is unavailable.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **L-06 Unused Code**


Throughout the codebase, multiple instances of unused code were identified:















The <u><mark>`[ArbAddressTable](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/precompiles.rs#L41C1-L49C32)`</mark></u> <u><mark>,</mark></u> <u><mark>`[ArbAggregator](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/precompiles.rs#L41C1-L49C32)`</mark></u> <u><mark>,</mark></u> <u><mark>`[ArbGasInfo](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/precompiles.rs#L41C1-L49C32)`</mark></u> <u><mark>,</mark></u> <u><mark>`[ArbInfo](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/precompiles.rs#L41C1-L49C32)`</mark></u> <u><mark>,</mark></u>

<u><mark>`[ArbRetryableTx](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/precompiles.rs#L41C1-L49C32)`</mark></u> <u>[and](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/precompiles.rs#L41C1-L49C32)</u> <u><mark>`[ArbSys](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/precompiles.rs#L41C1-L49C32)`</mark></u> <u>precompiles</u> are unused. Consider removing them, as

well as the accompanying interfaces to them.

The <u><mark>`[check_workspace](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/check.rs#L17)`</mark></u> function is currently not being used for any command

associated with <mark>`cargo stylus`</mark> and does not appear to be used anywhere in the

codebase.

The <mark>`codegen.rs`</mark> <u>[contract](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/codegen.rs)</u> contains only copyrights and licensing information. There is

no relevant lines of code, the contract is unused during the <mark>`codegen`</mark> command

execution and should be removed from the codebase.

The <u><mark>`[check](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/message.rs#L22)`</mark></u> function of <mark>`ProcessOutput`</mark> is unused, consider removing the entire

implementation of this struct.

The <u><mark>`[deploy](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/cargo_stylus.rs#L72-L82)`</mark></u> <u>function</u> in <mark>`cargo_stylus.rs`</mark> currently constructs <mark>`deploy_args`</mark> by

pushing <mark>`--private-key`</mark> and the raw private key value, and subsequently calls the

<mark>`call_deploy`</mark> function. This <mark>`call_deploy`</mark> function constructs and run another

"cargo stylus-beta deploy..." command where the <mark>`args`</mark> are consumed, thereby,


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 24


exposing this private key to sub-processes. While it is unused, its implementation can

result in exposure of private-keys if developers use it or copy/integrate it in downstream

code.

The deploy command defines a <mark>`constructor_signature`</mark> flag but does not use it in

[configuration or deployment. The flag is parsed in the CLI (argument definition) yet is not](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/deploy.rs#L51-L53)

forwarded into <mark>`DeploymentConfig`</mark> <u>[(construction,](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/deploy.rs#L79-L89)</u> <u><mark>`[DeployArgs::config](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/common_args.rs#L145-L169)`</mark></u> <mark>)</mark> . In the

core, deployment unconditionally calls <u><mark>`[get_constructor_signature](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/deployment/mod.rs#L186-L190)`</mark></u> and selects

the path based on that result.

The <mark>`ops`</mark> [module publicly re-exports](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/mod.rs#L4-L12) <u><mark>`[verify](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/mod.rs#L4-L12)`</mark></u> <mark>,</mark> but the implementation is a stub that

ignores its inputs and returns <mark>`Ok(())`</mark> <mark>.</mark> As such, it should be removed.



Consider removing all instances of unused code to improve the clarity and maintainability of

the codebase.


**_Update:_** _Partially resolved in_ _<u>[PR 372.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/372)</u>_ _<mark>`ProcessOutput::check`</mark>_ _<mark>,</mark>_ _<mark>`ops::check_workspace`</mark>_ _<mark>,</mark>_

_the_ _<mark>`constructor_signature`</mark>_ _CLI flag, and_ _<mark>`ops::verify`</mark>_ _are still present and unused/_

_misleading, and the Arb* precompile bindings remain unused internally._

### **L-07 Prelude Mismatch Is Never Detected During** **Failed Verification**


The <u><mark>`[verify_create_deployment](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L47)`</mark></u> function compares the calldata from a <u>[contract](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L39)</u>

<u>[deployment transaction](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L39)</u> [with the compressed WASM built locally](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L38) for a contract. If they do not

match, the prelude parts are first compared to detect a mismatch. However, the <mark>`tx_prelude`</mark>

and <mark>`build_prelude`</mark> are both <u>[assigned the same value, which always results in](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L55-L56)</u> <mark>`None`</mark> being

returned in the <u><mark>`[prelude_mismatch](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L69)`</mark></u> part of the returned <mark>`VerificationFailure`</mark> error.

This can cause confusion by hiding the true nature of failed verifications due to mismatched

preludes.


Consider assigning the correct <mark>`deployment_data.prelude()`</mark> to the <mark>`build_prelude`</mark>

variable.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 25


### **L-08 Incorrect Output In Cache Status Reporting**

The <u><mark>`[status](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/cache.rs#L32)`</mark></u> function of <mark>`cache.rs`</mark> reports the minimum bids for different contract sizes

along with the current cache and queue sizes by calling the <u><mark>`[CacheManager](https://github.com/OffchainLabs/nitro-contracts/blob/main/src/chain/CacheManager.sol)`</mark></u> contract. It

includes a check to determine whether the cache is at capacity by comparing <u><mark>`[queue_size <](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/cache.rs#L65)`</mark></u>

<u><mark>`[cache_size](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/cache.rs#L65)`</mark></u> <mark>,</mark> and if this condition is true, it informs the user that bids of 0 are accepted.


However, this is misleading since it does not account for the size of the contract for which a

bid is to be placed. <mark>`CacheManager`</mark> [only accepts a bid of 0 when the queue size + size of the](https://github.com/OffchainLabs/nitro-contracts/blob/main/src/chain/CacheManager.sol#L143-L145)

<u>[contract](https://github.com/OffchainLabs/nitro-contracts/blob/main/src/chain/CacheManager.sol#L143-L145)</u> is less than the cache size. Since the <mark>`status`</mark> function performs the check without

including the contract size, users may be led to believe that a bid of 0 will be sufficient to

cache their contract. This also conflicts with what is reported by <u><mark>`[suggest_bid](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/cache.rs#L89)`</mark></u> <mark>.</mark>


Consider including the contract size in the capacity check or simply removing <u>[this part](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/cache.rs#L65-L69)</u> entirely

in favor of <mark>`suggest_bid`</mark> to avoid confusion and potentially insufficient bids being placed.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **L-09 Unbounded Ancestor Search For rust-** **toolchain.toml Can Lead to Incorrect** **Toolchain Usage**


The <u><mark>`[find_toolchain_file](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/utils/toolchain.rs#L44)`</mark></u> walks parent directories to locate <mark>`rust-toolchain.toml`</mark>

without any boundary checking, continuing until either finding the file or reaching the filesystem

root. This unbounded search allows toolchain configuration from arbitrary ancestor directories,

including system-wide locations or directories outside the project workspace. This can cause

packages to inadvertently inherit toolchain settings from parent workspaces or sibling projects

rather than using their intended configuration. In particular, this can affect reproducible builds,

as the function may use a different <mark>`rust-toolchain.toml`</mark> than the project developer

intended, leading to builds with incorrect Rust versions and non-reproducible artifacts.


Consider bounding the search to stop at the workspace root (obtainable from

<mark>`cargo_metadata`</mark> <mark>)</mark> or, at minimum, the repository root. Doing so will prevent toolchain

inheritance from outside the project's control.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 26


The search for rust-toolchain.toml is intended to mimic the rest of the Rust tooling.

### **L-10 Unpinned Docker Base Image Tag** **Undermines Reproducibility**


The reproducible build workflow generates a Dockerfile that <u>[references](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/build/reproducible.rs#L46-L56)</u> the offchainlabs/cargo
stylus-base image using a <mark>`cargo_stylus_version`</mark> version tag instead of an immutable

content digest ( <mark>`@sha256:...`</mark> <mark>)</mark> . Since Docker image tags can be re-targeted to different

image contents at any time, this approach allows the referenced base image to change

independently of the codebase.


If the base image tag is updated or maliciously re-targeted, subsequent reproducible builds

may pull a different, potentially untrusted base image, breaking build determinism and

undermining the reproducibility guarantee. It also introduces a potential supply-chain risk, as a

compromised base image could execute arbitrary code within the container, which has write

access to the user's project directory via a bind mount.


Consider pinning the base image to a specific content digest ( <mark>`FROM repo@sha256:...`</mark> <mark>)</mark> or

verifying the pulled image’s digest against a known trusted value before building and running. If

dynamic tag resolution is required, consider resolving the tag to a digest once via a trusted

channel and embedding that digest into the generated Dockerfile.


In addition, consider limiting runtime privileges (for example, disabling host networking or using

read-only mounts) to reduce potential impact if the base image is compromised. If pinning or

verification cannot be implemented, consider clearly documenting this behavior to inform users

of the associated reproducibility and security implications.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **L-11 Vulnerable Dependencies**


Running cargo audit revealed two known vulnerabilities, <u>[alloy-dyn-abi 1.3.1](https://rustsec.org/advisories/RUSTSEC-2025-0073)</u> [and tokio-tar 0.3.1,](https://rustsec.org/advisories/RUSTSEC-2025-0111)

in the transitive dependencies used by <mark>`stylus-tools`</mark> <mark>.</mark>


Consider upgrading them to their latest, non-vulnerable versions. Alternatively, consider

refactoring or removing the affected code to eliminate reliance on vulnerable crates.


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 27


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We will be assessing our dependencies, and bumping the version of several crates

(including these) before release.

### **L-12 Unchecked Type During ABI Decoding**


Throughout the codebase, multiple instances of the <mark>`SolType::abi_decode_params`</mark>

function being used to decode parameters were identified:









[Lines 138, 355, 369, and](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-proc/src/macros/sol_interface.rs#L138) <u>[383](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-proc/src/macros/sol_interface.rs#L383)</u> in <mark>`stylus-proc::macros::sol_interace`</mark>

[Lines 571](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-proc/src/macros/public/types.rs#L571) [and 680](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-proc/src/macros/public/types.rs#L680) in <mark>`stylus-proc::macros::public::types`</mark>

<u>[Line 212](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/abi/mod.rs#L213)</u> in <mark>`stylus_sdk::abi`</mark>



Consider using the more secure <mark>`SolType::abi_decode_params_validate`</mark> function to

ensure correct decoding.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **L-13 Unsanitized Function Identifiers Can Break** **Interoperability**


The Stylus framework includes mechanisms for exporting a contract's ABI. This is handled by

the Stylus SDK, which generates a Solidity-compatible output that can be imported into

Solidity to interact with the Stylus contract. Therefore, the exported ABI must adhere to Solidity

rules to guarantee compatibility. The <u><mark>`[is_sol_keyword](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-core/src/sol.rs#L10)`</mark></u> <u>function</u> in <mark>`stylus_core::sol`</mark>

helps detect such keywords, allowing to sanitize or to reject them. For example, Solidity

keywords used as names in function parameters are prepended with an underscore using the

<u><mark>`[underscore_if_sol](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/abi/export/mod.rs#L119)`</mark></u> <u>function. However, function names face no restrictions. For instance,</u>

function names can be named after Solidity keywords. This is problematic when importing the

export ABI to a Solidity file, preventing the contract from compiling.


Consider rejecting function names that match any Solidity keyword to avoid breaking

interoperability.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 28


Usage of these patterns is not supported. We will be updating our documentation to

reflect this, and implemented proper error reporting at a later date.

### **L-14 Architecture Dependent Key Encoding Can** **Cause Discrepancies**


In the <mark>`stylus_sdk::storage`</mark> module, the macro <u><mark>`[impl_key](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/storage/map.rs#L246-L268)`</mark></u> includes <mark>`usize`</mark> and <mark>`isize`</mark>

as valid keys for mappings. Since <mark>`usize`</mark> and <mark>`isize`</mark> are pointer‑sized, the representable

range of these keys can differ across targets. For instance, tests commonly run natively,

possibly on 64-bit architecture, while deployment targets the 32-bit <mark>`wasm32-unknown-`</mark>

<mark>`unknown`</mark> architecture.


Using <mark>`usize`</mark> or <mark>`isize`</mark> as mapping keys can therefore derive different slots for the same key

between local tests and on‑chain execution, especially for values outside the 32‑bit range. This

risks silent state divergence, mismatched reads, or collisions when large keys are truncated on

<mark>`wasm32`</mark> <mark>.</mark>


Consider disallowing target-dependent types as storage keys, providing a robust and

deterministic code execution across targets.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We have currently not encountered any issues with the current types, but we have

made a note to ensure consistent cross-platform behavior in the future.

### **L-15 Non-Literal Fixed-Size Arrays Can Cause** **Selector Mismatches**


Within the <mark>`stylus_proc::types`</mark> module, the <mark>`sol_interface`</mark> maps <mark>`syn`</mark> Solidity types

to Alloy <mark>`SolType`</mark> using <mark>`SolidityTypeInfo`</mark> <mark>.</mark> For <u>[arrays, the code branches on](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-proc/src/types.rs#L121-L129)</u>

<mark>`TypeArray::size()`</mark> <mark>.</mark> If <mark>`size()`</mark> is <mark>`Some`</mark> <mark>,</mark> a <mark>`FixedArray`</mark> is generated. Otherwise, a

dynamic array is returned. Non-literal constant expressions such as <mark>`1+2`</mark> are not recognized

by <mark>`size()`</mark> <mark>,</mark> causing fixed arrays to be treated as dynamic.


This results in both ABI and selector mismatches for declarations using constant-expression

sizes. A declaration like <mark>`uint256[1+2]`</mark> is rendered as <mark>`uint256[]`</mark> in the selector preimage

and as a dynamic array in the generated client, diverging from Solidity’s canonical type

<mark>`uint256[3]`</mark> <mark>.</mark> Calls using the generated client could revert due to selector mismatches or

target a different overload.


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 29


Consider evaluating constant expressions for fixed array sizes in <mark>`sol_interface`</mark> before

emitting types and selector strings, or rejecting non-literal sizes with a clear error.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Usage of these patterns is not currently supported. We will be updating our

documentation to reflect this, and implemented proper error reporting or constant

evaluation (if possible) at a later date.

### **L-16 Raw Actions Default to Copying Unbounded** **Return Data**


The Stylus SDK offers mechanisms for performing raw calls and deployments within its

<u><mark>`[RawCall](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/raw.rs)`</mark></u> and <u><mark>`[RawDeploy](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/deploy/raw.rs)`</mark></u> modules. These modules offer a powerful API for developers to

initiate calls or deployments with an interface to granularly configure the action.


For instance, a caller can define the salt and the cache policy for a <mark>`RawDeploy`</mark> action, as well

as call kind, value, gas, return data offset and size, and cache policy for a <mark>`RawCall`</mark> action. In

the case of <mark>`RawDelpoy`</mark> <mark>,</mark> the <u><mark>`[deploy](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/deploy/raw.rs#L106-L109)`</mark></u> <u>function</u> will either return the deployed contract's

address or attempt to copy the full return data if the deployment fails. Similarly, in <mark>`RawCall`</mark> <mark>,</mark>

the <u><mark>`[call](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/raw.rs#L215)`</mark></u> <u>[function](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/raw.rs#L215)</u> will <u>[copy the full return data by default. For example, a malicious callee can](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/raw.rs#L76)</u>

return a very large buffer, forcing the caller to copy the entire return data and allocate enough

memory to decode it, which can trigger linear memory growth charges or out-of-memory traps.


Although the return data size to copy is configurable in <mark>`RawCall`</mark> <mark>,</mark> it is not the case for

<mark>`RawDeploy`</mark> <mark>.</mark> In both cases, however, the default behavior is to copy the full data, even though

the user does not intend to do so, adding unnecessary gas costs to the operation.

Furthermore, the generated client methods by the <mark>`sol_interface`</mark> macro rely on the <u>[safe](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/mod.rs#L30-L81)</u>

<u>[wrappers around the](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/mod.rs#L30-L81)</u> <u><mark>`[RawCall](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/mod.rs#L30-L81)`</mark></u> <u>module, performing a call, and decoding the returned bytes.</u>

However, users might not always want to copy the full return data or decode the returned data.

In such a case, users must reimplement the calls to external contract functions to avoid extra

costs.


Consider defaulting the size of the data to copy to 0, making the user opt-in to copy the return

data when there is a need to decode the return parameters or propagate errors. Alternatively,

consider adding a configuration to <mark>`RawDeploy`</mark> to limit or skip return data, similar to its

<mark>`RawCall`</mark> counterpart configuration. In addition, consider enabling granular control over return

data handling for generated client methods.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Arbitrum Stylus SDK v0.10 Audit − Low Severity − 30


We have not currently requested any additional features to the "raw" level API. If users

want more control, they can use hostios directly to avoid uneccisary copies or other

operations.

### **L-17 Replay Command is Broken on Windows**


The replay command's implementation for spawning a debugger process differs between Unix

and Windows. However, it is non-functional on Windows. On Unix systems, the code uses

<u><mark>`[cmd.exec()](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/commands/replay.rs#L96-L97)`</mark></u> <mark>,</mark> so control only returns and hits the <mark>`bail!`</mark> if <mark>`exec`</mark> fails. However, on

Windows, the code uses <u><mark>`[cmd.status()](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/commands/replay.rs#L98-L99)`</mark></u> <mark>,</mark> which always returns after the debugger exits.

Therefore, the subsequent <mark>`bail!("failed to exec …")`</mark> runs on every successful replay

and terminates cargo-stylus with an error.


Consider updating the Windows path to exit with the debugger’s status instead of bailing.


**_Update:_** _Acknowledged, not resolved._

## **Notes & Additional** **Information**

### **N-01 Typographical Errors**


Throughout the codebase, multiple instances of typographical errors were identified:











[In line 10](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/cargo_stylus.rs#L10) of <mark>`cargo_stylus.rs`</mark> <mark>,</mark> "deployement" should be "deployment"

[In line 4](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/activation.rs#L4) of <mark>`activation.rs`</mark> <mark>,</mark> "acitvation" should be "activation"

[In line 11](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/cache/suggest_bid.rs#L11) of <mark>`suggest_bid.rs`</mark> <mark>,</mark> "bid for in the cache manager" should be "bid for the

cache manager"

[In line 163](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/tracing/mod.rs#L163) of <mark>`mod.rs`</mark> <mark>,</mark> "Divegence" should be "Divergence"



Consider correcting all instances of typographical errors in order to improve the clarity and

readability of the codebase.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Noted for fix in a future release.


Arbitrum Stylus SDK v0.10 Audit − Notes & Additional Information − 31


### **N-02 Silent Overflow in Gas Cost Estimation** **Returns Zero**

The <u><mark>`[print_gas_estimate function](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/ops/activate.rs#L39)`</mark></u> uses

<mark>`gas_price.checked_mul(gas.into()).unwrap_or_default()`</mark> to calculate

transaction costs, which silently returns zero on arithmetic overflow instead of propagating an

error. This causes the CLI to display "0 ETH" for <u>[deployment](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/deployment/mod.rs#L236)</u> and activation cost estimates

when overflow occurs, potentially misleading users into believing transactions are free when

they may actually be prohibitively expensive. While unlikely under normal conditions given

<mark>`u128`</mark> capacity, extreme gas prices during network stress could trigger this behavior.


Consider returning an error on overflow instead of defaulting to zero.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **N-03 Incorrect Assignment of WASM Lengths in** **Verification Failure**


When a contract verification fails, the WASM lengths from the contract creation calldata and

locally built contract are reported in the <u>[error message. However, their assignment appears to](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L68-L71)</u>

be <u>[swapped: the](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/verification.rs#L66-L67)</u> <mark>`calldata`</mark> should be used for <mark>`tx_wasm_length`</mark> and <mark>`deployment_data`</mark>

for <mark>`build_wasm_length`</mark> <mark>.</mark> This mismatch reduces the accuracy of the reported error and can

cause confusion during debugging of the source of failure.


Consider correcting the aforementioned variable assignments. In addition, consider renaming

the arguments to <mark>`verify_create_deployment`</mark> <mark>.</mark> Doing so will ensure that the argument

names accurately correspond to the source of the supplied codes.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.


Arbitrum Stylus SDK v0.10 Audit − Notes & Additional Information − 32


### **N-04 Inconsistent Logging Pattern**

Throughout the codebase, multiple instances of inconsistent logging methods were identified.

These include <u><mark>`[println](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/cargo-stylus/src/commands/replay.rs#L76)`</mark></u> <mark>,</mark> <u><mark>`[debug](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/cache.rs#L78-L82)`</mark></u> <mark>,</mark> <u><mark>`[info](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/cache.rs#L65)`</mark></u> <mark>,</mark> and <u><mark>`[greyln](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/build/reproducible.rs#L20-L23)`</mark></u> <mark>.</mark>


To improve code clarity, debugging, and maintainability, consider adopting a consistent

approach towards logging patterns.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Stylus-tools is at its first release stage. We are taking all input into consideration to

improve the APIs for future releases.

### **N-05 Lack of Explicit Check**


The <mark>`cache_manager_address`</mark> function in <mark>`cache.rs`</mark> <u>[queries](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/cache.rs#L46)</u> the <mark>`ARB_WASM_CACHE`</mark>

precompile to retrieve a list of cache manager addresses. However, it assumes that the list will

always contain a single entry. It then <u>[pops](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-tools/src/core/cache.rs#L47)</u> and returns the last element as the cache manager

address. While this aligns with the current Arbitrum network architecture, which supports only

one cache manager, this assumption may not hold in the future. If multiple cache managers are

introduced, the current logic could lead to incorrect address selection or unexpected behavior.


Consider including an explicit check ensuring that only one address is returned. In addition,

clearly document this architectural assumption to justify why the last address in the list is

treated as the valid one.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


The cache manager currently will only ever return one value at a time. If there is ever a

time in the future where we change this functionality, we will require a cargo-stylus

update in order to take advantage of it.

### **N-06 Formatting Issues**


Throughout the codebase, multiple instances of formatting issues were identified:







In <u><mark>`[stylus_sdk::call](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/mod.rs#L30-L81)`</mark></u> <mark>,</mark> the <mark>`static_call`</mark> <mark>,</mark> <mark>`delegatecall`</mark> <mark>,</mark> and <mark>`call`</mark> functions

can be refactored to configure the call using <mark>`flush_storage_cache`</mark> or

<mark>`clear_storage_cache`</mark> instead of calling <mark>`host.flush_cache`</mark> manually.


Arbitrum Stylus SDK v0.10 Audit − Notes & Additional Information − 33


When exporting ABIs, there is <u>[no empty line between two interfaces. Consider adding an](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-proc/src/macros/public/types.rs#L448-L449)</u>

empty line to improve readability when exported to Solidity.



Consider addressing the above-listed formatting issues to improve the clarity and

maintainability of the codebase.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


Noted for fix in a future release.

### **N-07 Unnecessary Flags for Special Function** **Names**


The Stylus SDK currently requires explicit attributes to designate special functions, such as

<mark>`constructor`</mark> (or <mark>`stylus_constructor`</mark> <mark>)</mark>, <mark>`fallback`</mark> <mark>,</mark> and <mark>`receive`</mark> <mark>.</mark> The compiler also

enforces a naming convention, for example, requiring the <mark>`#[fallback]`</mark> attribute to be used

exclusively on a function named <mark>`fallback`</mark> <mark>.</mark>


This creates a redundancy where the function's role is declared twice: once by the

<mark>`#[fallback]`</mark> attribute and again by the <mark>`fn fallback`</mark> name. This adds unnecessary

complexity to the SDK and contract code, as the function's name alone could be used to

detect its special purpose. Moreover, the logic for the special functions attributes is

asymmetric. As mentioned above, functions with a reserved name such as <mark>`fallback`</mark> are

required to be flagged with the <mark>`#[fallback]`</mark> attribute. However, the <mark>`#[fallback]`</mark>

attribute can be used on functions with any other name.


Consider refactoring the SDKs' logic, relying solely on name-based detection for special

functions. This change would streamline the SDK, remove superfluous attributes, and simplify

the contract writing experience for developers.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We have opted to avoid strictly "name-based" detection of special methods as explicity

is better than implicit for readability and obvious behavior. The checks for the names are

simply to avoid writing of contracts which use these names outside of their intended

purpose.


Arbitrum Stylus SDK v0.10 Audit − Notes & Additional Information − 34


### **N-08 Inconsistent Function Availability**

The <mark>`RawCall`</mark> and <mark>`RawDeploy`</mark> structs offer many functions to configure a call or a

deployment. For instance, the <mark>`flush_storage_cache`</mark> and <mark>`clear_storage_cache`</mark>

[functions [1]](https://github.com/OffchainLabs/stylus-sdk-rs/blob/4003c3ff0ccf3710afb99ae9237c85f3d48dbc71/stylus-sdk/src/call/raw.rs#L155-L165) allow for configuring the cache policy invoked during the call or deployment.


These functions are crucial in reentrant mode to properly handle the cache before invoking

external code. Therefore, in <mark>`RawDeploy`</mark> <mark>,</mark> both functions only exist in reentrant mode.

However, in <mark>`RawCall`</mark> <mark>,</mark> these functions are always available, allowing users to define a custom

cache policy which can be unnecessarily invoked before calling an external contract,

potentially increasing execution cost.


Consider aligning the availability of <mark>`RawCall`</mark> cache configurations to match the <mark>`RawDeploy`</mark>

counterparts, avoiding unnecessary function calls.


**_Update:_** _Acknowledged, not resolved. The Offchain Labs team stated:_


We have opted to avoid strictly "name-based" detection of special methods as explicity

is better than implicit for readability and obvious behavior. The checks for the names are

simply to avoid writing of contracts which use these names outside of their intended

purpose.

### **N-09 Unused WASM Build**


The <mark>`exec`</mark> [function invokes](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/commands/replay.rs#L112) the normal Stylus WASM build, but the returned artifact and path

are not referenced afterward. The command then proceeds to <u>[call](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/commands/replay.rs#L114)</u> the

<mark>`build_shared_library`</mark> function that builds a host-native shared library <mark>(</mark> <mark>`.so`</mark> or <mark>`.dylib`</mark> ),

and then loads <mark>`user_entrypoint`</mark> from that native library. No code reads the WASM after

this point. As such, while the WASM build can be useful for failing early if the contract no

longer compiles to WASM, functionally, it is not required for the debugger flow.


To optimize the <mark>`replay`</mark> command, consider removing the wasm building process.


**_Update:_** _Acknowledged, not resolved._

### **N-10 Unused stable_rust Flag**


The <mark>`Args`</mark> struct in <mark>`replay.rs`</mark> defines a <u><mark>`[stable_rust](https://github.com/OffchainLabs/stylus-sdk-rs/blob/c79fa8b8d6a82fd8b290cb5ba6f505a78eedd7b3/cargo-stylus/src/commands/replay.rs#L26)`</mark></u> flag. However, this flag is never

used in the <mark>`exec`</mark> function.


Arbitrum Stylus SDK v0.10 Audit − Notes & Additional Information − 35


Consider removing any unused flags to improve the clarity and maintainability of the codebase.


**_Update:_** _Acknowledged, not resolved._


Arbitrum Stylus SDK v0.10 Audit − Notes & Additional Information − 36


## **Conclusion**

The Stylus SDK, core, and procedural macro crates have been refactored to include all <mark>`Host`</mark>

interactions behind a single VM. In addition, cross-contracts calls and deployments have been

rebuilt around a more explicit <mark>`Call`</mark> builder, while ABI generation has been upgraded to rely on

unified AbiType encoders aligning Rust and Solidity semantics.


Storage types now expose clearer borrowing behavior, and procedural macros have been

updated accordingly to generate selectors, encoders, and entry points that operate

consistently in the new <mark>`VM`</mark> model. <mark>`cargo-stylus`</mark> has been reorganized into a modular

structure with enhanced workspace support, improved deploy flows, and reproducible Docker
based verification.


The audit identified a critical-severity issue alongside several high- and medium-severity

issues. These issues pertained to the CLI tool as well as the SDK, like call-context gating,

selector construction, and storage-layout interoperability. Apart from these, a number of low
severity findings were also reported that centered on developer ergonomics and predictable

behavior across targets.


Numerous security issues were uncovered related to Stylus CLI tool, along with several

incomplete features. As such, the Arbitrum team is strongly advised to consider conducting

further audits on the CLI portion of the codebase once all features have been implemented and

thoroughly reviewed.


Overall, the codebase shows structural improvements and clearer abstractions compared to

prior versions. Continued periodic reviews are recommended as Stylus matures and these

refactors propagate into downstream workflows.


Arbitrum Stylus SDK v0.10 Audit − Conclusion − 37


