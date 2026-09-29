### | security

# **ZKsync OS Audit**

#### **September 2, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


Audit Scope _______________________________________________________________________  6


Approach _________________________________________________________________________  6


System Overview __________________________________________________________________  8

Bootloader 9

System 10

System Hooks 10

Execution Environment (EE) Framework 11

EVM Execution Environment 12

Oracle Provider 12

ZKsync OS Runner 13

Forward System 13


Critical Severity __________________________________________________________________ 14

C-01 Transaction Routing to Unsupported Execution Environment 14

C-02 Return Data Buffer May Be Drained 14

C-03 usize Arithmetic Can Lead to Non-Determinism and Panics 16


High Severity ____________________________________________________________________ 17

H-01 Legacy Transactions May Be DoSed by Appended Access Lists 17


Medium Severity _________________________________________________________________ 18

M-01 Improper Accounting for Transaction and Block Gas Limits 18

M-02 Missing Getter Functions in L2 Base Token Contract 19

M-03 Discrepancy With EVM in Return Data Handling During Contract Deployments 19


Low Severity ____________________________________________________________________ 20

L-01 Inconsistent Dirty Bits Check on L1 Receiver Address 20

L-02 Native Gas Cost Anomaly for PUSH Opcodes 20

L-03 Discrepancy in Call-Stack Handling and Error Ordering in external_call_before_vm 21

L-04 Inconsistent Contract Detection 22

L-05 Inconsistency in Contract Deployment with Respect to EVM 22

L-06 Double Return Data Allocation for Precompiles 23

L-07 Inconsistency in coinbase Rewards Handling with Respect to EVM 23

L-08 Out of Sync Transaction Counters 23


ZKsync OS Audit − Table of Contents − 2


L-09 Misusage of the Result Type 24


Notes & Additional Information ____________________________________________________ 25

N-01 Discrepancy Between Code and Comment Description 25

N-02 Naming Suggestions 25

N-03 Unused Enum Variants in ExitCode 26

N-04 Typographical Errors 26

N-05 Usage of Unstable Features 26

N-06 Inconsistent Initialization of Zero-Value Ergs 27


Recommendations _______________________________________________________________ 27

Phase 1 27

Arithmetic on usize Can Lead to Halting Block Finalization 28

Inconsistent System Configuration and Compilation Flags 28

Discrepancy to EVM 29

Magic Values 30

Usage of unwrap, expect, and panic! 30

Documentation 30

Unresolved TODOs 31

Platform-Independent Bounds for Resource Parameters 31


Conclusion ______________________________________________________________________ 32


ZKsync OS Audit − Table of Contents − 3


## **Summary**

**Timeline** From 2025-06-09
To 2025-06-20


**Languages** Rust



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



3 (3 resolved)


1 (1 resolved)


3 (1 resolved)



**Total Issues** 22 (16 resolved, 1 partially resolved) -->



**Low Severity Issues** 9 (8 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



6 (3 resolved, 1 partially resolved)


0 (0 resolved)


ZKsync OS Audit − Summary − 4


## **Scope**

[In the first part of the engagement, we performed an assessment of the matter-labs/zksync-os](https://github.com/matter-labs/zksync-os)

repository at the <u>[96d9d37](https://github.com/matter-labs/zksync-os/tree/96d9d3701a5f5b7c47b42337ff4e70db2bd04223)</u> commit.


In scope were the Rust files under the following directories:

```
.
├── basic_bootloader
│  └── src
│    └── bootloader
│      ├── account_models
│      └── transaction
├── basic_system
│  └── src
│    ├── system_functions
│    └── system_implementation
│      ├── flat_storage_model
│      ├── memory
│      └── system
└── system_hooks
└── src

```

The files <mark>`abstract_account.rs`</mark> and <mark>`contract.rs`</mark> under <mark>`basic_bootloader/src/`</mark>

<mark>`bootloader/account_models`</mark> were left out of scope because account abstraction is not

yet supported.


[In the second part, we performed an assessment of the matter-labs/zksync-os](https://github.com/matter-labs/zksync-os) repository at

[the 0563213](https://github.com/matter-labs/zksync-os/commit/0563213f89cc5401e6cf19dd7a13e72bd633d30f) commit.


In scope were the Rust files under the following directories:

```
.
evm_interpreter
└── src
└── instructions
zk_ee
├── src
│  ├── common_structs
│  │  └── history_map
│  ├── common_traits
│  ├── kv_markers
│  ├── memory
│  ├── oracle
│  ├── reference_implementations

```

ZKsync OS Audit − Scope − 5


```
│  ├── system
│  │  ├── errors
│  │  └── execution_environment
│  ├── system_io_oracle
│  ├── types_config
│  └── utils
│    └── convenience
zksync_os_runner
└── src
oracle_provider
└── src
forward_system
└── src
├── run
└── system

## **Audit Scope**

```

[The audit was performed on the matter-labs/zksync-os](https://github.com/matter-labs/zksync-os) repository at the <u>[5e69d44](https://github.com/matter-labs/zksync-os/commit/5e69d4483243bb0d166b7e2137fa54a8bb05925a)</u> commit. The

scope encompasses both scopes of the first and second part of the assessment listed above.

## **Approach**


Due to the significant size of the codebase, the engagement was divided into 3 phases. In the

first two phases, a security assessment was conducted on separate scopes, in which the

primary goal was to become familiar with the overall architecture and identify critical

components of the ZKsync OS codebase, laying the ground for phase 3, in which an audit was

be conducted on both the scopes from the initial assessments.


The assessments focus on understanding the technology stack and overall system

architecture, emphasizing critical security areas to identify high-level design flaws, structural

weaknesses, and inherited vulnerabilities. The objective is to evaluate the protocol’s overall

security posture and provide actionable recommendations to mitigate identified risks.


In the first phase, our assessment covered three foundational components:









The **Bootloader**, which orchestrates how transactions are analyzed and dispatched.


The **System** module, which provides execution environments with access to storage,

memory, and oracles.


ZKsync OS Audit − Audit Scope − 6


**System hooks**, the framework for executing precompiles and other ZKsync-specific

contracts.



This second phase focused on several key components of the ZKsync OS:















The general **Execution Environment (EE) Framework**, which defines the core structure

for all execution environments.


The **EVM Execution Environment**, which is ZKsync's specific implementation of the

EVM.


The **Oracle Provider**, the component that supplies data during execution.


The **ZKsync OS Runner**, which executes the ZKsync OS in a simulator for proof

generation.


The **Forwarder System**, the module executes ZKsync OS in execution mode.


ZKsync OS Audit − Approach − 7


## **System Overview**

ZKsync OS is the core execution framework of the ZKsync network. It also generates zero
knowledge proofs attesting to the correctness of these state transitions, enabling secure and

scalable settlement on Ethereum. Its primary function is to run batches of transactions and

calculate the new state of the blockchain as a whole. The system takes in transactions and

initial data and produces a new state for the entire network.


The system was designed to fulfill the following goals:











**Ethereum Compatibility:** It must be <u>[type 2 fully Ethereum Virtual Machine (EVM)](https://vitalik.eth.limo/general/2022/08/04/zkevm.html#type-2-fully-evm-equivalent)</u>

<u>[equivalent.](https://vitalik.eth.limo/general/2022/08/04/zkevm.html#type-2-fully-evm-equivalent)</u> This is a flagship feature as it allows developers to seamlessly bring their

existing Ethereum applications into ZKsync.


**High Performance:** It will offer high transaction throughput, making extremely low

transaction fees a possibility.


**Customizability:** The architecture is modular, i.e., it can be easily configured and

extended. This allows it to support different virtual machines, e.g., backwards

compatibility with EraVM or Wasm VM to allow for smart contracts beyond Solidity.

However, in the current version, only the EVM is supported, while the infrastructure to

support more VMs is already implemented.



ZKsync OS operates in two modes:



1.


2.



**Forward Mode:** It is the live run mode used by the network sequencer, the component

responsible for ordering transactions. It is performance-optimized for high-throughput

processing.


**Proof Mode:** The proof mode is used to generate proofs that all transactions were

processed correctly. The resulting proof is subsequently published to a settlement layer,

such as Ethereum, to finalize the transactions and inherit its security guarantees.



To cover the cost of these two modes, ZKsync OS implements a dual resource accounting

mechanism. It distinguishes between the computational cost of running a transaction (what

users pay for in gas) and the cost of generating its proof. By recording both, the system

ensures that its economic model is sustainable and accurately reflects the resources used.


ZKsync OS Audit − System Overview − 8


### **Bootloader**

The Bootloader is the orchestration component of all operations in ZKsync OS. It initializes the

system and manages the entire life cycle of a block, starting from processing the first

transaction to finishing the content of the block.


The bootloader's main responsibility is to execute a loop that processes a transaction at a

time:



1.

2.

3.



It begins by initializing the system and reading the new block context.

It then reads, verifies, and executes each transaction sequentially.

After processing all transactions, it finishes the block by generating a block header that

contains the result of the execution.



**Transaction Processing**


The main function of the bootloader is to handle transactions. It is handled slightly differently

for normal Layer 2 transactions and for those transactions that have been transferred from

Layer 1.











**Validation:** The bootloader validates a series of conditions before executing any code. It

checks the transaction nonce, verifies the sender’s signature, and checks the sender’s

account has enough funds to cover the maximum possible cost of the transaction. A

critical part of this step is also verifying that the transaction can pay for its share of

pubdata - data that must be published to the settlement layer to guarantee data

availability.

**Execution:** Once a transaction has been correctly validated, the bootloader will proceed

to run it through the <mark>`runner`</mark> component. The <mark>`runner`</mark> is a coordinator that manages

the call stack and transfers requests to the appropriate execution environment. This

design enables complex interactions, such as a contract in one environment calling

another contract in a different one.

**Refunding:** After execution, the bootloader ensures that any remaining balance from the

pre-paid fee is refunded to the user.



The system is designed for broad compatibility. The bootloader supports various types of

transactions, including legacy Ethereum transactions, EIP-1559 transactions, native ZKsync

EIP-712 transactions, and L1 -> L2 messages initiated from the Ethereum mainnet. L1 -> L2

transactions are given special priority, as they are already considered secure by L1 and do not

need to follow the standard validation procedure.


ZKsync OS Audit − System Overview − 9


### **System**

The System serves as the intermediary between high-level transaction execution and low-level

resource management. The System is modularly structured to support two principal operation

modes: a "forward running" mode used by the sequencer, and a "proving" mode used to

generate validity proofs.


It is passed to each Execution Environment and provides them with access to three important

modules: I/O, Memory, and Oracles. Note that Oracles are discussed in the <u>designated section</u>

in detail in Phase 2 of the assessment.











**I/O:** The I/O Subsystem offers an abstraction of all interaction with the state of the

blockchain. It is a key-value store where data is read by address and key. The minimum

implementation involves a main persistent storage along with several temporary storages

for things like logs and events, which are flushed after every transaction.

**Memory Subsystem:** This subsystem provides a memory per execution environment.

This guarantees that when a contract is executing, it has its own memory area that

cannot be accessed or touched by other contracts. When an execution frame finishes,

data that needs to be returned is copied to another specialized area so that it can be

protected from being overwritten.

**Oracles:** Oracles are the interface through which the system accesses outside

information and will be discussed in detail in Phase 2 of the assessment. Note that the

system employs two different oracles, depending on if the system is running in proving

mode or execution mode. In proving mode, the system does have the responsibility of

verifying the data it obtains. For instance, bytecode received from an oracle is re-hashed

and verified before being used in the proving environment.


### **System Hooks**

System hooks are a unique type of function with pre-specified system addresses. When a call

is invoked on such an address, ZKsync OS intercepts it and executes a native, hard-coded

function instead of EVM bytecode. It plays a dual role:







**Using Precompiles:** Most popular cryptographic functions (like <mark>`ecrecover`</mark> <mark>,</mark> <mark>`sha256`</mark> <mark>,</mark>

etc.) are expensive to perform computationally within a virtual machine. System hooks

enable highly optimized, native implementations of these operations which are far less

expensive and quicker to execute. As a compatibility measure with Ethereum, these

precompile hooks are installed at the same locations they exist in the EVM.


ZKsync OS Audit − System Overview − 10


**System Contracts:** Specialized contracts that carry out fundamental protocol operations.

Some examples are:




     - **L1 Messenger:** A specific hook that enables contracts to securely message back

to the Layer 1 settlement layer.

     - **L2 Base Token:** A hook that contains functionality for the native ZKsync token, like

withdrawals.

     - **Contract Deployer:** A one-time hook that can only be called by a special system

address, deployable to any address. This is intended to be used in governance
approved protocol upgrades.


A rough visualization of a transaction's lifecycle can be seen in the image below:

### **Execution Environment (EE) Framework**


The Execution Environment (EE) Framework is the abstraction framework of ZKsync OS for

supporting multiple virtual machines within a single system. The EE Framework makes ZkSync

capable of having distinct execution environments like EVM, EraVM, and WebAssembly

supported uniformly with the same interface.


ZKsync OS Audit − System Overview − 11


The EE model provides a standard interface that each execution environment must implement,

launch parameters, preemption points, and continuation procedures. Each EE operates with an

execution loop until a preemption point (external call, deployment, or termination), returns

control to the bootloader, and resumes after the bootloader has handled the request.


The architecture supports call modifiers (static, delegate, constructor), resource handling with

variable gas conversion ratios per EE, and deployment preparation with address derivation.

### **EVM Execution Environment**


The EVM Execution Environment provides full native EVM equivalence in ZKsync OS, with a

complete EVM interpreter implemented that maintains compatibility with existing Ethereum

tooling and contracts.


The EVM interpreter is organized in the <mark>`evm_interpreter`</mark> crate and provides a complete

EVM implementation including stack-based execution, memory management, and full opcode

support. The interpreter is implemented as a component of ZkSync's dual resource accounting

system, billing both EVM gas (translated into ergs) and native resources for proof expenses.


This Ethereum compatibility enables live Ethereum contracts to run unchanged, supporting the

developer experience, and testing using the Ethereum Foundation test suite for complete

compatibility testing.


However, several known divergences from Ethereum remain:













Additional **pubdata** fees that may impact keyless transactions.


Deployments by contract don't fail even when the target address contains some pre
existing storage (in situations with a zero nonce and zero code).


Nonces are represented as a 32-bit integer, which breaks the larger nonce constraint as

defined by **EIP-2681** .


The **DIFFICULTY** opcode ( **PREVRANDAO** ) is unsupported and returns a faked value of 0.


### **Oracle Provider**

Oracle Provider is the bridge between ZKsync OS execution and RISC-V proving environment

that provides non-deterministic input by injecting external information into the proving system

with deterministic execution.


ZKsync OS Audit − System Overview − 12


Oracle provider provides two major components: <mark>`ZkEENonDeterminismSource`</mark> to process

query processors and <mark>`BasicZkEEOracleWrapper`</mark> for adapting ZKsync OS oracles to the

non-determinism system. The system uses a query-response scheme where the RISC-V

environment writes the query arguments and reads responses through dedicated Control and

Status Registers (CSR).


The oracle provider governs different kinds of requests like transaction history, storage reads,

and block data.

### **ZKsync OS Runner**


The ZKsync OS Runner is the interface to the RISC-V simulator that executes ZKsync OS

binaries for proof generation as well as testing purposes, serving as the go-between between

compiled ZKsync OS Runner binary and the RISC-V runtime.


The runner loads ZKsync OS RISC-V binaries and executes them with provided non
determinism sources. It utilizes a specified register convention where the final 256-bit output is

stored in RISC-V CSRs and made available as public input for zero-knowledge proofs.

### **Forward System**


The Forward System utilizes the "forward running mode" of ZKsync OS, which is the runtime

environment utilized by the sequencer for live execution of transactions. The forward system

provides real-world implementations for executing ZKsync OS in sequencer mode using the

normal system allocator and live oracle implementations.


The forward system uses batch execution by <mark>`run_batch`</mark> in executing several transactions

and transaction simulation by <mark>`simulate_tx`</mark> in single transaction simulation used

by <mark>`eth_call`</mark> and <mark>`eth_estimateGas`</mark> RPC calls. The system is made consistent with the

proving environment through the usage of the same bootloader core logic while providing

optimized resource management during live execution.


ZKsync OS Audit − System Overview − 13


## **Critical Severity**

### **C-01 Transaction Routing to Unsupported** **Execution Environment**

During transaction processing, whenever the target address is

<u><mark>`[SPECIAL_ADDRESS_TO_WASM_DEPLOY](https://github.com/matter-labs/zksync-os/blob/main/basic_bootloader/src/bootloader/constants.rs#L5)`</mark></u> <mark>,</mark> the transaction will be processed as a deployment

to the Wasm execution environment.


In the <u><mark>`[bootloader::account_model::eoa](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/account_models/eoa.rs#L191-L197)`</mark></u> <u>module, the</u> <mark>`to_ee_type`</mark> variable is either

assigned the values <mark>`ExecutionEnvironmentType::EVM`</mark> <mark>,</mark>

<mark>`ExecutionEnvironmentType::IWasm`</mark> <mark>,</mark> or <mark>`None`</mark> <mark>.</mark> In case the transaction's target address

is <mark>`SPECIAL_ADDRESS_TO_WASM_DEPLOY`</mark> <mark>,</mark> the value of <mark>`to_ee_type`</mark> is set to

<mark>`ExecutionEnvironmentType::IWasm`</mark> <mark>.</mark> Subsequently, the <mark>`execute`</mark> function will call

<u><mark>`[process_deployment](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/account_models/eoa.rs#L205-L215)`</mark></u> with the detected <mark>`to_ee_type`</mark> <mark>,</mark> which will <u>[revert with an internal](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/account_models/eoa.rs#L569-L574)</u>

<u>[error](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/account_models/eoa.rs#L569-L574)</u> since the <mark>`IWasm`</mark> execution environment is not supported yet. This will end up returning

an error from <mark>`run_prepared`</mark> <mark>,</mark> which will cause a <mark>`panic`</mark> [in both the forwarder](https://github.com/matter-labs/zksync-os/blob/53456cbe3f3d90315b506338510cefa019ff8999/forward_system/src/system/bootloader.rs#L20-L22) [and prover](https://github.com/matter-labs/zksync-os/blob/53456cbe3f3d90315b506338510cefa019ff8999/proof_running_system/src/system/bootloader.rs#L180-L183)

invocations.


Consequently, this can cause the sequencer to crash, forcing a system restart. Moreover, this

attack can be executed deliberately often, potentially cause a DoS, and slowing down the

network's execution.


Consider temporarily disabling all logic related to Wasm deployments until the feature is fully

supported to prevent this DoS vector. This includes removing the check that identifies

transactions targeting <mark>`SPECIAL_ADDRESS_TO_WASM_DEPLOY`</mark> <mark>,</mark> as well as the corresponding

<u>[logic that charges intrinsic gas](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/account_models/eoa.rs#L485-L486)</u> for such deployment transactions.


**_Update:_** _[Resolved in pull request #151](https://github.com/matter-labs/zksync-os/pull/151)_ _[at commit 2b49475](https://github.com/matter-labs/zksync-os/pull/151/commits/2b49475dcedec842517a1c68e444df07d4f22fc2)_ _[and in pull request #214](https://github.com/matter-labs/zksync-os/pull/214)_ _at commit_

_<u>[b3d55d3.](https://github.com/matter-labs/zksync-os/pull/214/commits/b3d55d31ee3c2d0c09ff53c60c92cccb840720d4)</u>_

### **C-02 Return Data Buffer May Be Drained**


The return data space of smart contracts is represented through the <u><mark>`[return_data](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L186-L195)`</mark></u> <u>buffer of</u>

<u>[128 MB, preallocated before the transactions execution starts. Whenever any data is returned](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L186-L195)</u>

[from external calls during a transaction, it is copied to that buffer](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L370-L388) and the space available for


ZKsync OS Audit − Critical Severity − 14


future return data <u>[shrinks. In case when there is not enough space in the remaining part of the](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L188-L189)</u>

return data buffer, the code <u>[panics. A similar mechanism is used for precompiles execution,](https://doc.rust-lang.org/src/core/slice/mod.rs.html#1994)</u>

where the remaining data buffer part <u>[is also split. In this case, however, if there is not enough](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/precompiles.rs#L70)</u>

[space for the return data, an undefined behaviour](https://doc.rust-lang.org/src/core/slice/mod.rs.html#2092-2094) would happen in the

<u><mark>`[split_at_mut_unchecked](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/memory/slice_vec.rs#L22)`</mark></u> <u>call.</u>


This could be exploited by an attacker, who deploys and executes a smart contract, which

performs many external calls, each of which heavily use the return data, until the return data

buffer is drained. This could be achieved either by repeatedly calling a user-space program, or

the Identity precompile. In the first case, the cost of returning `x` 32-byte words involves a

memory expansion, hence requires at least <mark>`3x + x^2/512`</mark> gas per call, and the second

method requires <mark>`~3x`</mark> gas per call. Both options theoretically require paying at least 3 gas per

return data 32-byte word, although due to the redundant, <u>[second return data allocation for](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L578)</u>

<u>[precompiles, described in more detail another issue in this report, this cost is reduced to only](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L578)</u>

half of this value.


As such, the attack draining the entire return data buffer could be executed by using <mark>`~3 * 4`</mark>

<mark>`194 304 / 2 < 6.5M`</mark> gas (or <mark>`< 13M`</mark> gas assuming that the double-allocation issue

referenced above is fixed), which is below the target transaction gas limit of 18M. As a

consequence, because <mark>`panic`</mark> occurs, it will not be possible to process such a transaction,

which in case of <mark>`L1->L2`</mark> transaction would stop all subsequent <mark>`L1->L2`</mark> transactions from

executing.


Consider setting a hard gas limit on both L2 and <mark>`L1->L2`</mark> transactions and increasing the

space allocated for the return data buffer, so that the described attack is no longer possible

with the new limits. Furthermore, consider using the <u><mark>`[split_at_mut_checked](https://doc.rust-lang.org/src/core/slice/mod.rs.html#2217)`</mark></u> function

instead of the unsafe <mark>`split_at_mut`</mark> and <mark>`split_at_mut_unchecked`</mark> alternatives and

handling the <mark>`None`</mark> value returned in order to prevent panics in the bootloader.


**_Update:_** _[Resolved in pull request #218](https://github.com/matter-labs/zksync-os/pull/218)_ _[at commit 3cd893a](https://github.com/matter-labs/zksync-os/pull/218/commits/3cd893a437acb462666b910807244ecedd9be7ef)_ _[and in pull request #257](https://github.com/matter-labs/zksync-os/pull/257)_ _at commit_

_<u>[9afe7dc. The Matter Labs team stated:](https://github.com/matter-labs/zksync-os/pull/257/commits/9afe7dc18ae157cc09fa56dfef8b46cd62e2c54f)</u>_


_We ended up using a different approach: We incremented the returndata buffer to 256_

_MB, this should be enough for worst-case up to ~18M gas. However, we decided not to_

_implement a per-tx max gas limit, as this will be a divergence from EVM (for now). This_

_also puts a limit on L1 transactions, as pointed out. Instead, we decided to handle the_

_out of return memory error as a fatal error (same handling as out of native resource). We_

_believe this state is only reachable by contracts crafted to exploit this, so we accept this_

_formal divergence (which should not be observable in normal usage). As a reminder,_

_when such fatal error is reached at any point of a transaction's execution, the error is_


ZKsync OS Audit − Critical Severity − 15


_bubbled up to the top-level and the tx execution is reverted (notice, we do not revert the_

_fee payment, to prevent DDoS)._

### **C-03 usize Arithmetic Can Lead to Non-** **Determinism and Panics**


Throughout the codebase, there are several places where the <mark>`usize`</mark> type is used. Since the

size of this type is architecture-dependent, the usage of it could cause discrepancies in how

the code is executed in different environments or could result in panic. The relevant instances

are enumerated below: - The <u><mark>`[l2_base_token_hook_inner](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l2_base_token.rs#L106)`</mark></u> <u>function</u> uses the <u><mark>`[try_into](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l2_base_token.rs#L202)`</mark></u>

<u>[function](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l2_base_token.rs#L202)</u> to coerce <mark>`message_offset`</mark> into <mark>`usize`</mark> <mark>.</mark> On 64-bit targets, this admits any value up

to <mark>`2^64 − 1`</mark> <mark>,</mark> but on 32-bit targets values greater than <mark>`2^32 − 1`</mark> fail the conversion. This

results in a discrepancy in the code behaviour on 64-bit and 32-bit target, where the execution

continues and results in an error <u>[later on](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l2_base_token.rs#L217-L221)</u> on the former and results in an <u>[earlier error](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l2_base_token.rs#L204-L206)</u> in the

latter. - A similar problem is present within the <mark>`system_hooks`</mark> <mark>,</mark> where dynamic <mark>`bytes`</mark> <mark>-</mark>

parameters parsing is done using <mark>`usize`</mark> types. In this case, when handling the

<mark>`sendToL1(bytes)`</mark> function, the <u><mark>`[length](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l1_messenger.rs#L186-L187)`</mark></u> <mark>,</mark> extracted from the calldata could be set to a

value close to the <mark>`u32::MAX`</mark> [and the subsequent addition](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l1_messenger.rs#L198) will pass on the sequencer (64-bit

[target) and fail for passing short calldata, whereas the same operation will](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l1_messenger.rs#L206-L210) <u>[revert earlier](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l1_messenger.rs#L201-L203)</u> on the

prover (32-bit target). Similar problems may appear for other places in the code where checked

arithmetic is used for the <mark>`usize`</mark> type. - When beginning a new transaction, the bootloader

calls the <u><mark>`[try_begin_next_tx](https://github.com/matter-labs/zksync-os/blob/28a31ec5cea049de54611a979e77617dc54e52a9/basic_bootloader/src/bootloader/mod.rs#L220)`</mark></u> <u>function. This function processes incoming transactions</u> <u>[by](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L244)</u>

<u>[rounding](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L244)</u> the reported byte length up to a machine word boundary <mark>(</mark> <mark>`USIZE_SIZE`</mark> <mark>)</mark> and then

<u>[trying to iterate over the transaction content. However, on 32-bit targets, where](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L256-L260)</u> <mark>`USIZE_SIZE`</mark>

<mark>`== 4`</mark> <mark>,</mark> computing <mark>`next_tx_len_bytes.next_multiple_of(USIZE_SIZE)`</mark> can overflow

<mark>`usize`</mark> for very large inputs, with size close to <mark>`u32::MAX`</mark> <mark>.</mark> In release builds, this overflow

wraps to 0, so <mark>`next_tx_len_usize_words`</mark> becomes 0 while the iterator over the actual

content is non-empty. As an overflow does not happen on 64-bit target, this causes a

discrepancy in how the transaction data is processed on different targets. Furthermore,

processing transactions with the size exceeding the length of the allocated buffer <u>[may result in](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L245-L247)</u>

<u>[a panic](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L245-L247)</u> as the <mark>`try_begin_next_tx`</mark> [function is expected to succeed.](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L217-L219)


For long-term stability, consider avoiding architecture-dependent types like <mark>`usize`</mark> for

arithmetic. Refactoring to use fixed-size integers (e.g., <mark>`u32`</mark> or <mark>`u64`</mark> <mark>)</mark> will ensure consistent and

predictable results across all environments. Furthermore, consider explicitly rejecting

[transactions with a content bigger than the maximum allowed size of](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/constants.rs#L10) <u><mark>`[~8](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/constants.rs#L10)`</mark></u> <u>MB</u> in order to

prevent potential discrepancies in code execution resulting from <mark>`usize`</mark> arithmetic and panics

in the bootloader.


ZKsync OS Audit − Critical Severity − 16


**_Update:_** _[Resolved in pull request #197](https://github.com/matter-labs/zksync-os/pull/197)_ _[at commit fabf065](https://github.com/matter-labs/zksync-os/pull/197/commits/fabf065056130968213ba1ace2c38d2f5f1e84e1)_ _[and in pull request #215](https://github.com/matter-labs/zksync-os/pull/215)_ _at commit_

_<u>[80876b3.](https://github.com/matter-labs/zksync-os/pull/215/commits/80876b3cf23ed437f0fc05591fe13d7ad40f7c55)</u>_

## **High Severity**

### **H-01 Legacy Transactions May Be DoSed by** **Appended Access Lists**


[The EVM Cancun specification mentiones several available transaction types. While the](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/transactions.py#L112-L115)

EIP-4844 ( <mark>`BlobTransaction`</mark> <mark>)</mark> type is deliberately <u>[not supported in ZKSync OS at the](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/transaction/mod.rs#L90-L101)</u>

<u>[moment, there is a discrepancy between how the](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/transaction/mod.rs#L90-L101)</u> <mark>`LegacyTransaction`</mark> type is handled in

both environments.


Specifically, in the EVM Cancun, the access lists <u>[are not supported](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/fork.py#L754-L760)</u> in this type of transaction,

[but they are still processed in ZKSync OS](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/process_transaction.rs#L525) as the same logic <u>[will be applied to them as for other](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/process_transaction.rs#L80-L85)</u>

<u>[L2 transactions. This results in a discrepancy in how legacy transactions are executed on](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/process_transaction.rs#L80-L85)</u>

Ethereum and on ZKSync OS that can lead to two different consequences.


The first one allows users to benefit from access lists, while <u>[not paying the native fee](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/transaction/mod.rs#L481)</u> for their

length in hash calculation. This could be achieved by sending a legacy transaction, but still

including an access list in it.


The second consequence also follows from the fact that access lists are not included in a

legacy transactions' hashes, which are then used for verifying transactions' signatures. This

allows an attacker, who intercepts a valid legacy transaction without access list, to append an

arbitrary access list to it and this transaction would still be considered valid, as the data to be

signed did not change, since it does not take into account an access list. However, the access

list would still be processed, which would cause a victim to lose gas. This could be used to

cause any legacy transaction to revert with OOG by spending almost the entire available gas,

so that the transaction would still be executed, but would quickly revert, causing a victim to

lose funds.


Consider rejecting any legacy transaction that contains an access list, to avoid allowing

attackers from manipulating legacy transactions as well as aligning with the EVM Cancun

specification.


**_Update:_** _[Resolved in pull request #154](https://github.com/matter-labs/zksync-os/pull/154)_ _[at commit 1a60d90.](https://github.com/matter-labs/zksync-os/pull/154/commits/1a60d90e3c92df361415d7c6493a6a7ea5e8cdfe)_


ZKsync OS Audit − High Severity − 17


## **Medium Severity**

### **M-01 Improper Accounting for Transaction and** **Block Gas Limits**

When processing an L2 transaction, it is ensured that <u><mark>`[block_gas_limit <=](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/process_transaction.rs#L445)`</mark></u>

<u><mark>`[MAX_BLOCK_GAS_LIMIT](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/process_transaction.rs#L445)`</mark></u> and that <u><mark>`[tx_gas_limit <= block_gas_limit](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/process_transaction.rs#L451)`</mark></u> <mark>.</mark> For L1 to L2

transactions, the current gas limit per transaction is set to <u><mark>`[72_000_000](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/common/Config.sol#L101-L102)`</mark></u> and is only checked

in L1 contracts.


However, both checks do not take into account used gas in a block. Moreover, there is no

check in the <mark>`bootloader`</mark> that ensures that <mark>`block_gas_limit`</mark> is not exceeded when

adding all used gas of a block's transactions together. Currently, it is only documented that the

<u>sum of</u> <u><mark>`[gas_used](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L349-L350)`</mark></u> <u>[in a block should not be](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L349-L350)</u> <u>`[0](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L349-L350)`</u> .


[Following the Cancun specs, a transaction's gas limit must not exceed the available gas in a](https://github.com/ethereum/execution-specs/blob/07e08b99d8238a253f85d98b477648acc076d007/src/ethereum/cancun/fork.py#L417-L421)

<u>[block, which is calculated by subtracting the gas used from the gas limit of a block.](https://github.com/ethereum/execution-specs/blob/07e08b99d8238a253f85d98b477648acc076d007/src/ethereum/cancun/fork.py#L417-L421)</u>

Additionally, the <u>[gas used in a block must not exceed the block's gas limit.](https://github.com/ethereum/execution-specs/blob/07e08b99d8238a253f85d98b477648acc076d007/src/ethereum/cancun/fork.py#L331-L332)</u>


This improper gas accounting can allow the executor to include blocks with an arbitrary

number of transactions that violate the block's gas limit.


To ensure compatibility with Cancun specs, consider accounting for used gas during

transactions and ensuring that the transaction gas limit does not exceed the remaining gas in a

block, as well as ensuring that the sum of all transaction gas used does not exceed a block's

gas limit. Alternatively, since the accounting for used gas is a known <mark>`TODO`</mark>, consider

[expanding the comment on line 349, highlighting the missing check while only allowing for one](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L349)

transaction per block until the <mark>`TODO`</mark> is resolved which will ensure that the gas used is less

than or equal to <mark>`MAX_BLOCK_GAS_LIMIT`</mark> <mark>.</mark>


Additionally, consider reducing the transaction's gas limit for L1 to L2 transactions. This will

prevent users from initiating transactions that are deemed valid by L1 contracts, but will fail to

execute on ZKsync OS.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_[The pull request #191 enforces block limits, making transactions that overflow them (in](https://github.com/matter-labs/zksync-os/pull/191)_

_this case, block gas limit) invalid. The sequencer will remove it from the final block._


ZKsync OS Audit − Medium Severity − 18


_Block gas usage calculation has also been implemented. For L1 transactions, we're_

_considering reducing the limit on L1._

### **M-02 Missing Getter Functions in L2 Base Token** **Contract**


The L2 Base Token was originally <u>[implemented](https://github.com/matter-labs/era-contracts/blob/43c2dd5f263b964c232ef4359da4ba666fab3c6c/system-contracts/contracts/L2BaseToken.sol#L19)</u> in Solidity and has since been migrated to the

ZKsync OS environment using Rust off-chain implementation as <u>[a hook. In the original](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l2_base_token.rs#L15)</u>

implementation, several functions—such as withdrawals, <u><mark>`[balanceOf](https://github.com/matter-labs/era-contracts/blob/43c2dd5f263b964c232ef4359da4ba666fab3c6c/system-contracts/contracts/L2BaseToken.sol#L60)`</mark></u> <mark>,</mark> and the auto
generated <u><mark>`[totalSupply](https://github.com/matter-labs/era-contracts/blob/43c2dd5f263b964c232ef4359da4ba666fab3c6c/system-contracts/contracts/L2BaseToken.sol#L24)`</mark></u> <mark>—</mark> were available. These functions are commonly used by external

contracts and interfaces to interact with and retrieve information from the token contract. In the

current Rust implementation, some of these getter functions are missing, which may lead to

inconsistencies when existing or new contracts attempt to interact with the L2 Base Token.


The absence of expected functions like <mark>`balanceOf`</mark> and <mark>`totalSupply`</mark> in the Rust

implementation may result in broken functionality for contracts or services that rely on them.

These omissions can cause integration failures or runtime errors during execution, especially in

systems expecting behavior consistent with ERC-20-like tokens.


Consider implementing all public functions from the previous Solidity-based L2 Base Token,

including getters like <mark>`balanceOf`</mark> and <mark>`totalSupply`</mark> <mark>,</mark> to ensure backwards compatibility and

consistent behavior across environments.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We are not convinced that this is an issue. This release targets EVM equivalence, and_

_the base token doesn't need to be ERC-20 compliant (like ETH on L1). This system hook_

_is only providing withdrawal functionality. We'll include other methods for backwards_

_compatibility when we migrate ZKsync Era._

### **M-03 Discrepancy With EVM in Return Data** **Handling During Contract Deployments**


[The EVM specification mandates that when a contract deployment failed because of incorrect](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/vm/interpreter.py#L192-L197)

<u>[first byte of code or too long code, the return data should be cleared.](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/vm/interpreter.py#L192-L197)</u>


[However, on ZKsync OS, in such a case, the return data, containing the contract's code is not](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/interpreter.rs#L384-L387)

<u>[cleared, then saved as the return data from deployment](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/interpreter.rs#L384-L387)</u> [and finally propagated to the calling](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/ee_trait_impl.rs#L260)

<u>[contract. It could cause unexpected behaviour on the calling contract's side, which could](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/ee_trait_impl.rs#L260)</u>


ZKsync OS Audit − Medium Severity − 19


expect an error information, but would instead receive a huge return data, which would trigger

costly memory expansion and could result in OOG errors.


For example, in case of the OpenZeppelin's <u><mark>`[Create2](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/3790c59623e99cb0272ddf84e6a17a5979d06b35/contracts/utils/Create2.sol#L17)`</mark></u> <u>library, this behaviour could cause an</u>

unexpected revert <u>[when copying the revert message](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/3790c59623e99cb0272ddf84e6a17a5979d06b35/contracts/utils/Create2.sol#L49)</u> from the <mark>`create2`</mark> call.


Consider following the EVM specification and clearing the contract's code from return data in

case where an error happens during the validation of the code to be deployed.


**_Update:_** _[Resolved in pull request #226](https://github.com/matter-labs/zksync-os/pull/226)_ _[at commit d8a3733.](https://github.com/matter-labs/zksync-os/pull/226/commits/d8a37337772e71eb714e424c912c01e1f7dab519)_

## **Low Severity**

### **L-01 Inconsistent Dirty Bits Check on L1 Receiver** **Address**


In <mark>`l2_base_token`</mark> <mark>,</mark> the <u><mark>`[WITHDRAW_SELECTOR](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l2_base_token.rs#L171-L175)`</mark></u> path validates that the L1 receiver address

has no dirty bits, while the <mark>`WITHDRAW_WITH_MESSAGE_SELECTOR`</mark> path omits this check and

<u>[slices 20 bytes](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/l2_base_token.rs#L273)</u> directly; in Solidity this would revert on dirty bits, leading to inconsistent

behavior between the two paths.


Consider aligning the address validation with Solidity by enforcing the dirty-bit check for

addresses uniformly across both withdraw paths so non-zero upper bytes cause a revert.


**_Update:_** _[Resolved in pull request #192](https://github.com/matter-labs/zksync-os/pull/192)_ _[at commit b184113.](https://github.com/matter-labs/zksync-os/pull/192/commits/b18411347ae42c892065492e127bb83b825c86d1)_

### **L-02 Native Gas Cost Anomaly for PUSH Opcodes**


The native gas costs for the <mark>`PUSH`</mark> family of opcodes are expected to be monotonic. This

means the cost to push N+1 bytes to the stack should be greater than or equal to the cost of

pushing N bytes. The defined constants for native gas costs violate this expectation.

Specifically, <u><mark>`[PUSH15_NATIVE_COST](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/native_resource_constants.rs#L109)`</mark></u> <u>is 240, while</u> <u><mark>`[PUSH16_NATIVE_COST](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/native_resource_constants.rs#L110)`</mark></u> <u>is only 210. This</u>

makes it cheaper to push 16 bytes than it is to push 15 bytes.


Consider reviewing and correcting the entire <mark>`PUSH<N>_NATIVE_COST`</mark> table to ensure the

values increase monotonically.


**_Update:_** _[Resolved in pull request #228](https://github.com/matter-labs/zksync-os/pull/228)_ _[at commit 511b5df.](https://github.com/matter-labs/zksync-os/pull/228/commits/511b5df8b3bce2ae8511c57dfc9b9979a3ff84e0)_


ZKsync OS Audit − Low Severity − 20


### **L-03 Discrepancy in Call-Stack Handling and** **Error Ordering in external_call_before_vm**

[In EVM Cancun, an external call first verifies that the current depth does not exceed 1 024](https://github.com/ethereum/execution-specs/blob/c612d3d3adf57d8d082d3d206622c356d6e664a0/src/ethereum/cancun/vm/interpreter.py#L216-L217C15)

before attempting any state-changing action such as transferring value; if the limit is exceeded

the call fails immediately and no Ether moves. The ZKsync OS implementation diverges: within

<u><mark>`[external_call_before_vm](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L413)`</mark></u> <mark>,</mark> value <u>[is transferred](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L424-L433)</u> before the depth check, and the early-exit

branch for externally owned accounts (EOAs) returns success without ever evaluating

<mark>`self.callstack_height > 1024`</mark> <mark>.</mark>


Because of this ordering, a call that is already deeper than 1 024 frames but targets an EOA

will still move funds and be reported as successful, whereas the EVM would fail with

<mark>`StackDepthLimitError`</mark> and revert the transfer. For non-EOA targets the function instead

returns <mark>`OutOfNativeResources`</mark> after the premature transfer, creating a second kind of

mismatch with EVM behaviour.


While it is not possible to exploit the issue with the current configuration, this may change with

a chain upgrade, potentially making the issue exploitable.


Consider reordering the logic so that every outbound call—regardless of target type—checks

<mark>`self.callstack_height`</mark> before any value transfer and before the EOA early-return,

thereby matching EVM semantics and producing consistent error codes.


**_Update:_** _[Resolved in pull request #184. The Matter Labs team stated:](https://github.com/matter-labs/zksync-os/pull/184)_


_[This has been fixed in pull request #184. This is a big simplification of the runner, but the](https://github.com/matter-labs/zksync-os/pull/184)_

_relevant change for this issue is that now this check is performed more consistently and_

_in the right order. Now this checks are part of the EVM_ _<mark>`before_executing_frame`</mark>_

_function, which is also called when in NoEE (call to EOA), as EVM is the "default"_

_behaviour for EOA._


_The OpenZeppelin team stated:_


_Although the issue is no longer part of the codebase due to the changes in the linked_

_pull request, we do not consider the changes in this pull request as part of the final_

_audited commit due to significant changes, including out-of-scope changes._


ZKsync OS Audit − Low Severity − 21


### **L-04 Inconsistent Contract Detection**

The <u><mark>`[is_contract](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/io.rs#L190-L194)`</mark></u> <u>function</u> considers an address a contract if either <mark>`unpadded_code_len`</mark>

or <mark>`artifacts_len`</mark> is greater than zero, while <u><mark>`[is_eoa](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L288)`</mark></u> <u>fagl</u> checks only for zero bytecode

length.


Consider unifying the logic for contract detection to avoid inconsistent behavior across the

system.


**_Update:_** _[Resolved in pull request #184. The Matter Labs team stated:](https://github.com/matter-labs/zksync-os/pull/184)_


_[This is no longer a problem. Pull request #184 introduced a simplification of the runner.](https://github.com/matter-labs/zksync-os/pull/184)_

_The PR is quite large, but you can see that the function_

_<mark>`call_execute_callee_frame`</mark>_ _will now do an early return on NoEE._


_The OpenZeppelin team stated:_


_Although the issue is no longer part of the codebase due to the changes in the linked_

_pull request, we do not consider the changes in this pull request as part of the final_

_audited commit due to significant changes, including out-of-scope changes._

### **L-05 Inconsistency in Contract Deployment with** **Respect to EVM**


The EVM specification for the Cancun fork mandates that in case when insufficient amount of

gas has been provided for contract deployment, the transaction <u>[should be rejected during the](https://github.com/ethereum/execution-specs/blob/e3eb03b9e9685d7ee94460a89075e04200ac50fb/src/ethereum/cancun/transactions.py#L456-L458)</u>

<u>[validation phase. The required amount of gas includes](https://github.com/ethereum/execution-specs/blob/e3eb03b9e9685d7ee94460a89075e04200ac50fb/src/ethereum/cancun/transactions.py#L456-L458)</u> <u>[both the base creation cost and the init](https://github.com/ethereum/execution-specs/blob/e3eb03b9e9685d7ee94460a89075e04200ac50fb/src/ethereum/cancun/transactions.py#L500)</u>

<u>[code cost.](https://github.com/ethereum/execution-specs/blob/e3eb03b9e9685d7ee94460a89075e04200ac50fb/src/ethereum/cancun/transactions.py#L500)</u>


[However, on ZKsync OS, only the init code cost is taken into account](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/account_models/eoa.rs#L488-L495) during the validation

phase and the base creation cost is charged later on, <u>[in the execution phase. As a result, a](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/account_models/eoa.rs#L543-L545)</u>

transaction providing insufficient gas to cover the base creation cost, would be rejected on

Ethereum during the validation phase, but would be processed and reverted during the

execution phase on ZKsync OS.


Consider including the base creation cost in the transaction validation phase in order to

maintain compatibility with EVM specification.


**_Update:_** _[Resolved in pull request #196](https://github.com/matter-labs/zksync-os/pull/196)_ _[at commit 56e4446.](https://github.com/matter-labs/zksync-os/pull/196/commits/56e44465cc244ae0b60e4f37614c4963188c0e3b)_


ZKsync OS Audit − Low Severity − 22


### **L-06 Double Return Data Allocation for** **Precompiles**

[Whenever external calls to precompiles complete, the return data is copied](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L578) to the return data

buffer, <u>[allocated before the transactions execute.](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L189-L190)</u>


However, during the actual call to precompiles, the return data is <u>[already copied](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/precompiles.rs#L66-L70)</u> to the return

data buffer, hence the <u>[subsequent return buffer allocation](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L578)</u> is not necessary.


Consider removing redundant return data allocation for the precompiles.


**_Update:_** _[Resolved in pull request #193](https://github.com/matter-labs/zksync-os/pull/193)_ _[at commit efeaf3a.](https://github.com/matter-labs/zksync-os/pull/193/commits/efeaf3a31aadc8756a7711ac04dfdd5487efe86d)_

### **L-07 Inconsistency in coinbase Rewards** **Handling with Respect to EVM**


According to the EVM specifications, whenever a contract is created and <mark>`selfdestruct`</mark> <mark>e</mark> d

in the same transaction, the contract is not immediately deleted, but marked for deletion which

[actually happens at the end of the transaction. The deletion of an account involves the removal](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/fork.py#L804-L805)

<u>[of its storage and setting it to](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/state.py#L227-L228)</u> <u><mark>`[None](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/state.py#L227-L228)`</mark></u> <mark>.</mark> The latter operation effectively removes the entire

balance of an account.


The accounts deletion happens at the very end of the transaction, notably, <u>[after the transaction](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/fork.py#L797-L805)</u>

<u>[reward is transferred to the](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/fork.py#L797-L805)</u> <u><mark>`[coinbase](https://github.com/ethereum/execution-specs/blob/974b01ac695f9e16b05844d1d3272255298c036e/src/ethereum/cancun/fork.py#L797-L805)`</mark></u> <u>address. It means that if a contract, which is created</u>

and deleted in the same transaction is set as the <mark>`coinbase`</mark> address, the reward received to

that address is permanently burnt.


However, on ZKsync OS, the actual reward transfer happens <u>[after deletion of accounts. It](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L306-L337)</u>

means that the reward is never burnt and the contract which was destructed is initialised once

again at the end of transaction processing.


Consider performing accounts deletion after processing the <mark>`coinbase`</mark> rewards, or

documenting the current design choice of processing it before transferring the reward.


**_Update:_** _[Resolved in pull request #229](https://github.com/matter-labs/zksync-os/pull/229)_ _[at commit 4a885c7.](https://github.com/matter-labs/zksync-os/pull/229/commits/4a885c7fdb4a5d4a8d7dbdd3bc674ae7f41c9d74)_

### **L-08 Out of Sync Transaction Counters**


The system's current approach to tracking transaction numbers within a block is inconsistent

across different components. The primary transaction counter within the <mark>`io_subsystem`</mark> is


ZKsync OS Audit − Low Severity − 23


incremented at the <u>[completion of a transaction, which correctly starts the numbering at](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_system/src/system_implementation/system/io_subsystem.rs#L736)</u> <u>[index](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_system/src/system_implementation/system/io_subsystem.rs#L717)</u>

<u>[zero. However, internal data caches, particularly storage and account caches, use their own](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_system/src/system_implementation/system/io_subsystem.rs#L717)</u>

separate counters that are instead incremented at the beginning of a new transaction <u>[[1] [2].](https://github.com/matter-labs/zksync-os/blob/28a31ec5cea049de54611a979e77617dc54e52a9/basic_system/src/system_implementation/flat_storage_model/storage_cache.rs#L153)</u>


This discrepancy results in different parts of the system holding different values for the

"current" transaction number, which can lead to confusion and is a source of potential bugs.


To improve clarity and reliability, consider adopting a single, uniform method for counting

transactions, centralizing this logic within the <mark>`io_subsystem`</mark> <mark>,</mark> or adopting the same counting

logic throughout the system.


**_Update:_** _[Resolved in pull request #231](https://github.com/matter-labs/zksync-os/pull/231)_ _[at commit 474c6ff. The Matter Labs team stated:](https://github.com/matter-labs/zksync-os/pull/231/commits/474c6ff5df0a2622583d190b4fa887ceb2f2840b)_


_Acknowledged, we went for the simpler option (being consistent in when we update_

_these counters). We'll probably unify the counter in a later release._

### **L-09 Misusage of the Result Type**


The <u><mark>`[result](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/interpreter.rs#L181)`</mark></u> <u>variable</u> in the EVM interpreter is inferred to the standard <mark>`Result<(),`</mark>

<mark>`ExitCode>`</mark> type. This type can be misleading, as not all <mark>`Exitcode`</mark> <mark>s</mark> are errors. The issue

arises because the <mark>`Result`</mark> type implies that the <mark>`ExitCode`</mark> variant is always an error,

although it is used for all exit reasons, <u>[including success conditions. This ambiguity introduces](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/lib.rs#L331-L336)</u>

the risk that future maintainers might use the `?` operator on this value, causing a success state

to be incorrectly propagated as a critical failure.


Consider replacing the standard <mark>`Result<(), ExitCode>`</mark> with the <mark>`Option<ExitCode>`</mark>

type. Alternatively, consider using a custom <mark>`enum`</mark> <mark>,</mark> for example, <mark>`EVMInterpreterResult`</mark> <mark>.</mark>

This would force the caller to use a <mark>`match`</mark> statement to handle the different exit conditions

explicitly, preventing confusion between success and error states and ensuring the `?` operator

cannot be misused.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We agreed to restructure this return type for the next version._


ZKsync OS Audit − Low Severity − 24


## **Notes & Additional** **Information**

### **N-01 Discrepancy Between Code and Comment** **Description**

The <u><mark>`[flush_tx](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L206)`</mark></u> <u>function</u> is used to finish the current transaction execution. According to the

<u>[function's comment, it should also return execution stats. However, in case of success, the](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L205)</u>

function always returns <mark>`Ok(0)`</mark> <mark>.</mark>


Consider returning transaction stats instead of <mark>`Ok(0)`</mark> to match the code functionality to the

comment.


**_Update:_** _[Resolved in pull request #237](https://github.com/matter-labs/zksync-os/pull/237)_ _[at commit 4bc28c4.](https://github.com/matter-labs/zksync-os/pull/237/commits/4bc28c49170a1299ebfcc1ba609cd312a4ea7d6d)_

### **N-02 Naming Suggestions**


Throughout the codebase, some instances were identified that could benefit from renaming:












<u><mark>`[start_global_frame](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L178)`</mark></u> can be renamed to <mark>`start_frame`</mark> <mark>,</mark> since the

<mark>`start_global_frame`</mark> is used more than once throughout a transaction, whereas the

name gives the impression that a frame is started once in a transaction. Consequently,

<u><mark>`[finish_global_frame](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/mod.rs#L189)`</mark></u> can be renamed to <mark>`finish_frame`</mark> to match its counterpart.

<u><mark>`[tx](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/errors.rs#L59)`</mark></u> can be renamed to <mark>`expected`</mark> or <mark>`expected_from`</mark> <mark>.</mark>

<u><mark>`[io](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_system/src/system_implementation/system/io_subsystem.rs#L359)`</mark></u> can be renamed to <mark>`storage`</mark> <mark>.</mark>

<u><mark>`[diff](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/resources.rs#L112)`</mark></u> can be renamed to <mark>`abs_diff`</mark> <mark>,</mark> making the intention of the function clearer.

<u><mark>`[BasicBootloaderForwardSimulationConfig](https://github.com/matter-labs/zksync-os/blob/c03f26ebbad86f4f567850d256e4783496e58fb5/basic_bootloader/src/bootloader/config.rs#L17)`</mark></u> can be renamed to

<mark>`BasicBootloaderForwardConfig`</mark> <mark>.</mark>



Consider renaming the instances mentioned above for improved readability and clarity.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_This one I don't think we'll apply. I personally don't think these renamings improve_

_readability much, we'll improve in-code documentation for that._


ZKsync OS Audit − Notes & Additional Information − 25


### **N-03 Unused Enum Variants in ExitCode**

In the <u><mark>`[ExitCode](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/lib.rs#L330)`</mark></u> <u>enum, which defines possible outcomes from the EVM interpreter, several</u>

variants are declared but not used within the codebase. These include <mark>`OutOfFund`</mark> <mark>,</mark>

<mark>`CallTooDeep`</mark> <mark>,</mark> and <mark>`FatalExternalError`</mark> <mark>.</mark>


Consider removing the unused variants from the <mark>`ExitCode`</mark> enum if they are not required, or

implementing their usage if they represent valid and necessary interpreter states.


**_Update:_** _[Resolved in pull request #212](https://github.com/matter-labs/zksync-os/pull/212)_ _[at commit 6f1f08d.](https://github.com/matter-labs/zksync-os/pull/212/commits/6f1f08d72af6368a0d5d95966f3aa779b4240771)_

### **N-04 Typographical Errors**


The following is a list of identified typographical errors throughout the codebase:
















<u>["Our"](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L439)</u> should be "Out".

<u>["3th"](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_system/src/system_implementation/flat_storage_model/account_cache_entry.rs#L26)</u> should be "3rd".

<u><mark>`[in_constructor](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_system/src/system_implementation/flat_storage_model/account_cache.rs#L906)`</mark></u> should be <mark>`is_constructor`</mark> <mark>.</mark>

<u>["beoynd"](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_system/src/system_implementation/flat_storage_model/preimage_cache.rs#L177)</u> should be "beyond".

<u>["rocessed"](https://github.com/matter-labs/zksync-os/blob/b1046d382d9d0de71ecf34d25be53da3bec695fc/basic_system/src/system_implementation/system/public_input.rs#L131)</u> should be "processed".

<u>["in"](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/base_system_functions.rs#L63)</u> should be "In".

<u><mark>`["STORE"](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/evm_interpreter/src/opcodes.rs#L283)`</mark></u> should be <mark>`"TSTORE"`</mark> <mark>.</mark>

<u>["Cleae"](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_system/src/system_implementation/flat_storage_model/storage_cache.rs#L312)</u> should be "Clear".

<u>["caller"](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/runner.rs#L650)</u> should be "callee". Alternatively, "to" should be "from".

<u>["that does not that"](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/zk_ee/src/system/io.rs#L126)</u> should be "that does not track".



Consider fixing the instances listed above in order to improve the clarity of the codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #237](https://github.com/matter-labs/zksync-os/pull/237)</u>_ _[at commit 501efd1.](https://github.com/matter-labs/zksync-os/pull/237/commits/501efd19fa20e212edb5b5445cb2b4544c652620)_

### **N-05 Usage of Unstable Features**


In Rust, unstable features are experimental APIs that are only available on the nightly compiler

and are subject to change or removal without notice. They are typically used for testing and

development of new language capabilities before stabilization. Using these features in

production code can lead to maintenance challenges, as future compiler updates may break

the build or alter behavior.


In the codebase, several function calls rely on unstable features: - In the <mark>`HooksStorage`</mark>

implementation block, the <mark>`new_in`</mark> function calls <u><mark>`[BTreeMap::new_in](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/system_hooks/src/lib.rs#L93)`</mark></u> <mark>,</mark> which is unstable. 

ZKsync OS Audit − Notes & Additional Information − 26


In the <mark>`BasicBootloader`</mark> implementation block, the <mark>`run_prepared`</mark> [function calls](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L188-L190)

<u><mark>`[Box::new_uninit_slice_in](https://github.com/matter-labs/zksync-os/blob/5e69d4483243bb0d166b7e2137fa54a8bb05925a/basic_bootloader/src/bootloader/mod.rs#L188-L190)`</mark></u> <mark>,</mark> which is unstable.


Consider replacing these unstable feature calls with stable alternatives or refactoring the

implementation to avoid nightly-only APIs. If the functionality is essential and no stable API is

available, evaluate whether enabling the relevant feature gates is acceptable for your project’s

stability requirements, and document this decision clearly for future maintainers.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We'll stick to allocator API, precise version of compiler will be documented and a_

_reproducibility pipeline will be available._

### **N-06 Inconsistent Initialization of Zero-Value** **`Ergs`**


Throughout the codebase, many instances inconsistently create zero-value <mark>`Ergs`</mark> objects,

using both <mark>`Ergs::empty()`</mark> and <mark>`Ergs(0)`</mark> interchangeably.


Consider standardizing on the <mark>`Ergs::empty()`</mark> constructor for all zero-value initializations.

This would improve code consistency and align with existing patterns already used for similar

types, such as <mark>`Native::empty`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #237](https://github.com/matter-labs/zksync-os/pull/237)_ _[at commit e0cb133.](https://github.com/matter-labs/zksync-os/pull/237/commits/e0cb13394985032e282cb6d17835261c512daf0e)_

## **Recommendations**

### **Phase 1**


This section outlines key recommendations based on our initial security assessment of the

codebase.


While the codebase includes numerous tests, helpful overview documentation, and a generally

well-organized structure, it still presents several quality concerns that could impact security,

readability, and maintainability. As this is a high-level assessment rather than an exhaustive

audit, the following points are intended to provide actionable advice for enhancing the

system's security and code quality.


ZKsync OS Audit − Recommendations − 27


### **Arithmetic on usize Can Lead to Halting Block** **Finalization**

The ZKsync OS system is designed to run on different architectures: the executor typically runs

on a 64-bit machine, while the prover is designed for a 32-bit environment. In Rust, the data

type <mark>`usize`</mark> represents memory-sized integers. This means <mark>`usize`</mark> is 64 bits on a 64-bit

machine and 32 bits on a 32-bit machine.


Using a platform-dependent type like <mark>`usize`</mark> for deterministic arithmetic can lead to

divergence between executor and prover since each is running on a different architecture. A

calculation that uses checked arithmetics on <mark>`usize`</mark> can pass on the 64-bit executor but fail

on the 32-bit prover. On the other hand, if an unchecked arithmetic operation overflows on the

32-bit prover, it does not necessarily overflow on the executor. When this happens, the

executor will consider a block valid, but the prover will be unable to generate a proof for it,

effectively halting the finalization of blocks on L1.


Consider replacing <mark>`usize`</mark> with fixed-size integer types to ensure that all calculations produce

the same result regardless of the underlying architecture, preventing divergences between the

executor and the prover.

### **Inconsistent System Configuration and** **Compilation Flags**


ZKsync OS must support different behaviors for its two primary environments: the live

execution mode and the proving mode. This is currently managed using conditional

compilation flags that include or exclude code based on the target architecture. The method

for detecting the target environment is inconsistent across the codebase. Different modules

use different flags, leading to a confusing and error-prone setup. For example:











<u><mark>`[cycle_marker](https://github.com/matter-labs/zksync-os/blob/96d9d3701a5f5b7c47b42337ff4e70db2bd04223/cycle_marker/src/lib.rs#L55-L68)`</mark></u> uses <mark>`#[cfg(target_arch =`</mark>

<mark>`"riscv32")]`</mark> and <mark>`#[cfg(not(target_arch = "riscv32"))]`</mark> <mark>.</mark>

<u><mark>`[crypto::ark_ff_delegation::biginteger](https://github.com/matter-labs/zksync-os/blob/96d9d3701a5f5b7c47b42337ff4e70db2bd04223/crypto/src/ark_ff_delegation/biginteger/mod.rs#L437-L446)`</mark></u> uses <mark>`#[cfg(target_arch =`</mark>

<mark>`"x86_64")]`</mark> and <mark>`#[cfg(not(target_arch = "x86_64"))]`</mark> <mark>.</mark>

In <mark>`basic_bootloader::bootloader`</mark> [on lines 102 to 126](https://github.com/matter-labs/zksync-os/blob/96d9d3701a5f5b7c47b42337ff4e70db2bd04223/basic_bootloader/src/bootloader/mod.rs#L102-L126) we

use <mark>`#[cfg(target_pointer_width =`</mark>

<mark>`"32")]`</mark> and <mark>`#[cfg(target_pointer_width = "64")]`</mark> to detect the architecture,

and we check for a third option to fail compiling if <u>[none of the architectures was](https://github.com/matter-labs/zksync-os/blob/96d9d3701a5f5b7c47b42337ff4e70db2bd04223/basic_bootloader/src/bootloader/mod.rs#L122-L125)</u>

<u>[detected. This behavior is not consistent, as seen in another function.](https://github.com/matter-labs/zksync-os/blob/96d9d3701a5f5b7c47b42337ff4e70db2bd04223/basic_bootloader/src/bootloader/mod.rs#L122-L125)</u>


ZKsync OS Audit − Recommendations − 28


<u><mark>`[basic_bootloader::bootloader::result_keeper](https://github.com/matter-labs/zksync-os/blob/OZ-audit-part-1/basic_bootloader/src/bootloader/result_keeper.rs)`</mark></u> uses different

implementations for <mark>`ResultKeeperExt`</mark> <mark>,</mark> relying on the developer to use the correct

implementation.



Furthermore, the <mark>`BasicBootloaderForwardSimulationConfig`</mark> struct has the same

configuration values as <mark>`BasicBootloaderProvingExecutionConfig`</mark> which might be

confusing without further documentation. Although the current system is assumed to have the

Account Abstraction feature disabled, there is no implementation for

<mark>`BasicBootloaderExecutionConfig`</mark> where the <mark>`AA_ENABLED`</mark> field is set to <mark>`false`</mark> .


Additionally, the <mark>`FlatTreeWithAccountsUnderHashesStorageModel`</mark> struct includes a

<u><mark>`[PROOF_ENV](https://github.com/matter-labs/zksync-os/blob/96d9d3701a5f5b7c47b42337ff4e70db2bd04223/basic_system/src/system_implementation/flat_storage_model/mod.rs#L66)`</mark></u> <u>field</u> which is a boolean type, used to define whether the system is in proof mode

or not.


This ad-hoc approach increases the risk of misconfiguration where, for example, a developer

might add a new feature for one environment but forget to provide the alternative

implementation for the other.


Standardize the approach for managing environment-specific configurations. A single, unified

feature flag, such as <mark>`#[cfg(feature = "executor|prover")]`</mark> <mark>,</mark> should be used

consistently across the entire project to distinguish between the execution and proving

environments. Additionally, review configuration structs to ensure their names accurately reflect

their function and that all necessary permutations are available when needed.

### **Discrepancy to EVM**


In standard Ethereum (EVM), the <mark>`coinbase`</mark> address receives its fees immediately after each

transaction is successfully processed within a block. In ZKsync OS, however, all transaction

fees are first collected in a temporary <mark>`BOOTLOADER_FORMAL_ADDRESS`</mark> <mark>.</mark> The funds

accumulate there for the duration of the block processing and are only transferred to the final

<mark>`coinbase`</mark> address in a single transaction at the very end of the block. While this is done to

maintain compatibility with ZKsync Era's Account Abstraction, it represents a deviation from

the EVM's execution model.


To better align with EVM equivalence, consider modifying the fee distribution logic to transfer

fees to the <mark>`coinbase`</mark> address after each individual transaction. Alternatively, the divergence

from the EVM standard should be clearly documented for developers and users of the system.


ZKsync OS Audit − Recommendations − 29


### **Magic Values**

[The usage of undocumented magic values](https://github.com/matter-labs/zksync-os/blob/96d9d3701a5f5b7c47b42337ff4e70db2bd04223/basic_system/src/system_implementation/system/io_subsystem.rs#L301-L306) in the codebase can be confusing for readers.

Consider documenting the meaning of these values and how they were calculated or defined

to enhance readability.

### **Usage of unwrap, expect, and panic!**


In Rust, methods like <mark>`.unwrap()`</mark> <mark>,</mark> <mark>`.expect()`</mark> <mark>,</mark> and the <mark>`panic!`</mark> macro are designed to halt

execution immediately when an unexpected state is reached. This is an unrecoverable error

that will crash the running program. The codebase contains numerous occurrences of

<mark>`.unwrap()`</mark> <mark>,</mark> <mark>`.expect()`</mark> <mark>,</mark> and <mark>`panic!`</mark> <mark>.</mark> While these are appropriate for tests or truly

unrecoverable situations, their use in transaction processing logic is dangerous. A specially

crafted transaction that triggers a panic could crash the entire sequencer or prover, causing a

denial-of-service vulnerability where no new blocks can be processed.


Consider refactoring the codebase to eliminate panics from all core transaction processing and

state transition paths. Errors should be propagated and handled gracefully, allowing a

transaction to fail and its state changes to be reverted without crashing the entire system.

### **Documentation**


The project includes high-level design <u>[documentation](https://github.com/matter-labs/zksync-os/tree/96d9d3701a5f5b7c47b42337ff4e70db2bd04223/docs)</u> that are helpful for gaining a general

understanding of the system. However, secure and maintainable code also relies on detailed

inline documentation that explains complex logic at the implementation level.


Most components, complex algorithms, and low-level modules within the codebase lack

sufficient inline documentation. For instance, design decisions that deviate from standard EVM

must be documented where they are implemented. This lack of context makes the code more

difficult to review, harder for new developers to contribute to safely, and increases the risk of

introducing bugs during future modifications.


While extensive documentation for a codebase of this size is a significant undertaking,

consider prioritizing efforts on public entry-point functions for all critical modules to improve

clarity, maintainability, and security.


ZKsync OS Audit − Recommendations − 30


### **Unresolved TODOs**

While some TODOs highlight missing features which can be changed or added later, others

present potential risks, as they may lead to misuse, errors, or vulnerabilities if not properly

addressed.


Consider addressing critical TODOs to prevent the system from failing.

# **Phase 2**


The second phase of the assessment focused on critical execution and proving components of

ZKsync OS, including the Execution Environment framework, the EVM interpreter, the Oracle

Provider, the ZKsync OS Runner, and the Forward System. Several recommendations made in

Phase 1 - such as improvements to input validation, clarifying assumptions around invariants,

and enhancing documentation for unsafe code - remain relevant in this phase as well. Below,

we outline a new recommendation, while also noting that previously suggested improvements

continue to apply.

### **Platform-Independent Bounds for Resource** **Parameters**


As noted in Phase 1, values of type <mark>`usize`</mark> must be carefully handled when casting to <mark>`u32`</mark> <mark>,</mark>

particularly across the architecture boundary between the 64-bit forward system and the 32-bit

prover.


For example, in the oracle provider code, <u><mark>`[new_iterator.len()](https://github.com/matter-labs/zksync-os/blob/eab1b1fb7df47cc9b8bfc8bebdcbb84665d170ce/oracle_provider/src/lib.rs#L79)`</mark></u> returns a <mark>`usize`</mark> and may

exceed the 32-bit limit. Casting without a bound check risks truncation on 64-bit platforms,

potentially leading to inconsistent witness generation or prover/verifier desynchronization.

Similarly, the prover uses <mark>`usize`</mark> for cycle tracking but is constrained by a 32-bit architecture.

Without an explicit cap, long-running execution paths could exceed the prover's limits (e.g.,

<mark>`2^32 - 1`</mark> <mark>)</mark>, leading to overflows or invalid proofs.


Consider adding explicit bounds before downcasting or relying on architecture-constrained

values to ensure deterministic behavior across both execution and proving environments.


Phase 2 − Recommendations − 31


## **Conclusion**

ZKsync OS represents a significant evolution of ZKsync's core execution framework, designed

to replace the network's current version. This next-generation system introduces a more

unified architecture by migrating key components, such as the <u>[bootloader](https://github.com/matter-labs/era-contracts/blob/3d9fd025516ddaa3e259d9e2e9d572620f05786b/system-contracts/bootloader/bootloader.yul)</u> [and precompiled](https://github.com/matter-labs/era-contracts/blob/3d9fd025516ddaa3e259d9e2e9d572620f05786b/system-contracts/contracts/precompiles)

<u>[contracts, from Yul-Assembly to a more maintainable and testable Rust codebase. The most](https://github.com/matter-labs/era-contracts/blob/3d9fd025516ddaa3e259d9e2e9d572620f05786b/system-contracts/contracts/precompiles)</u>

notable architectural improvement is its modular support for multiple Execution Environments

(EEs). This design not only preserves compatibility with the existing EraVM but also paves the

way for full EVM equivalence and the future integration of a WasmVM, enabling smart contracts

to be written in a variety of programming languages.


Both the first and the second phase of this multi-phased engagement revealed a solid and

well-considered system design. Our recommendations focus on further enhancing code quality

and formalizing system configurations to ensure predictable behavior and improve the

development experience.


During the final audit several medium, high, and critical issues were identified and further

recommendations were provided for improvement.


We thank the Matter Labs team for their collaboration and responsiveness throughout this

engagement, which was supported by clear and adequate documentation.


Phase 2 − Conclusion − 32


