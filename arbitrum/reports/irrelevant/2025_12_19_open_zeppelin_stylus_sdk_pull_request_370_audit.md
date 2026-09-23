### | security

# **Arbitrum Stylus** **SDK Pull Request** **#370 Audit**

#### **December 19, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4

usertrace 5

replay 5

debug_hook 5


High Severity ______________________________________________________________________  6

H-01 External Contract Replay Is Never Invoked 6


Low Severity ______________________________________________________________________  6

L-01 Potential Execution Failure on Windows 6


Notes & Additional Information ______________________________________________________  7

N-01 Inconsistent Error Handling 7

N-02 Unaddressed TODO Comments 7

N-03 Hardcoded Extension in Error Messages 8

N-04 Redundant Contract Library Maps 8

N-05 Unused stable_rust Flag 8

N-06 Misleading Errors 8


Conclusion ______________________________________________________________________ 10


Appendix _______________________________________________________________________ 11

Issue Classification 11


Arbitrum Stylus SDK Pull Request #370 Audit − Table of Contents − 2


## **Summary**

**Type** SDK


**Timeline** From 2025-12-11
To 2025-12-15


**Languages** Rust



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


1 (1 resolved)


0 (0 resolved)



**Total Issues** 8 (7 resolved)



**Low Severity Issues** 1 (0 resolved)



**Notes & Additional**
**Information**



6 (6 resolved)



Arbitrum Stylus SDK Pull Request #370 Audit − Summary − 3


## **Scope**

[OpenZeppelin audited the OffchainLabs/stylus-sdk-rs](https://github.com/OffchainLabs/stylus-sdk-rs) repository at commit <u>[8e2202c.](https://github.com/OffchainLabs/stylus-sdk-rs/commit/8e2202ce703f0e2e1c93161d82c0ac25a230ab17)</u>


The scope covered all the changes made in <u>[pull request #370](https://github.com/OffchainLabs/stylus-sdk-rs/pull/370)</u> that had been merged into the

main branch.


The following files were in scope:

```
├── cargo-stylus/src
│  ├── commands
│  │  ├── debug_hook.rs
│  │  ├── mod.rs
│  │  └── replay.rs
│  └── utils/hostio.rs
└── stylus-tools/src/core/tracing/mod.rs

```

Arbitrum Stylus SDK Pull Request #370 Audit − Scope − 4


# **System Overview**

<u>[Pull request #370](https://github.com/OffchainLabs/stylus-sdk-rs/pull/370)</u> adds the <mark>`usertrace`</mark> command and enhances the <mark>`replay`</mark> command with

debugger options.

### **`usertrace`**


The <mark>`usertrace`</mark> command is a debugging tool that allows developers to visualize the function

call hierarchy within their Stylus contracts for a given transaction using the <u><mark>`[stylusdb](https://github.com/walnuthq/stylusdb)`</mark></u>

debugger tool.

### **`replay`**


The <mark>`replay`</mark> command and the <mark>`hostio`</mark> module introduce logic for debugging interactions

between multiple contracts. Within <mark>`replay.rs`</mark> <mark>,</mark> when contract addresses are provided as

input to the CLI command, <mark>`ContractRegistry`</mark> uses helper functions from <mark>`hostio.rs`</mark> to

get the execution frame, after which it builds and loads the shared libraries. When an external

call is detected during the replay, <mark>`ContractRegistry`</mark> loads and executes the code for the

target contract, allowing for a continuous debugging session across all contracts involved in

the transaction.

### **`debug_hook`**


<mark>`debug_hook`</mark> defines a mechanism for the <mark>`cargo-stylus`</mark> tool to communicate with an

external debugger, such as <mark>`stylusdb`</mark> <mark>.</mark> The <mark>`DebuggerHook`</mark> trait is an interface that defines

a set of events that can occur during a transaction replay. <mark>`StylusDebuggerHook`</mark> is the

implementation of the <mark>`DebuggerHook`</mark> trait. It works by creating a Unix socket and listening

for a connection from the debugger. When an event occurs during the transaction replay (e.g.,

a call to another contract), <mark>`StylusDebuggerHook`</mark> sends a command over the socket to the

debugger. This allows the debugger to stay in sync with the execution flow.


System Overview − Scope − 5


## **High Severity**

### **H-01 External Contract Replay Is Never Invoked**

The <mark>`relay`</mark> command registers a <u><mark>`[ContractRegistry](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L480)`</mark></u> <u>instance</u> via

<u><mark>`[set_external_contract_access](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L578-L579)`</mark></u> and implements <mark>`ExternalContractAccess`</mark> to

delegate calls to other contracts during debugging.


However, <mark>`hostio`</mark> [only defines](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/utils/hostio.rs#L45-L48) <mark>`EXTERNAL_CONTRACT_ACCESS`</mark> <mark>.</mark> Functions such as

<u><mark>`[call_contract](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/utils/hostio.rs#L438-L446)`</mark></u> <mark>,</mark> <u><mark>`[delegate_call_contract](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/utils/hostio.rs#L488-L495)`</mark></u> <mark>,</mark> and <u><mark>`[static_call_contract](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/utils/hostio.rs#L535-L542)`</mark></u> only read

the input frame from the static trace via the <mark>`frame!`</mark> macro and do not check for or dispatch

to the registered <mark>`ExternalContractAccess`</mark> object. As a result, the <mark>`ContractRegistry`</mark>

registry is populated, but external calls are never dispatched to the loaded libraries. Hence,

calls to external contracts in <mark>`ContractRegistry`</mark> cannot be executed, making the multi
contract debugging feature non-functional.


Within the functions in <mark>`hostio`</mark> <mark>,</mark> consider checking the <mark>`is_in_external_contract`</mark> flag

and reading data from <mark>`EXTERNAL_CONTRACT_ACCESS`</mark> to properly debug external contract

calls.


**_Update:_** _[Resolved at commit 68f8ceb.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/382/commits/68f8ceb559901fbc677027d49489a5f9db104103)_

## **Low Severity**

### **L-01 Potential Execution Failure on Windows**


In the <mark>`stylus_tools::verification`</mark> module, the <u><mark>`[verify_os](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/stylus-tools/src/verification.rs#L9-L24)`</mark></u> <u>function</u> verifies that the

OS on which a command is being executed is supported. However, this function is left unused

throughout the codebase, leading to potential failures on Windows without the Windows

Subsystem for Linux. For instance, when initiating a new <u><mark>`[StylusDebuggerHook](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/debug_hook.rs#L44)`</mark></u> <u>struct, the</u>

<mark>`socket_path`</mark> <mark>'</mark> s format uses the Unix path syntax with a Unix-specific <mark>`tmp`</mark> folder. This could

lead to issues when creating a connection to the socket.


System Overview − High Severity − 6


Consider either implementing support for Windows throughout the codebase or implementing

the <mark>`verify_os`</mark> function to provide better error messaging for Windows users.


**_Update:_** _Acknowledged, not resolved. The Walnut team stated:_


Since Windows is staying out of focus for now for these features, we have addressed

this issue by adding a TODO marker in <mark>`debug_hook.rs`</mark> [on lines 49 to 52.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/382/commits/68f8ceb559901fbc677027d49489a5f9db104103#diff-8878fd6277243fd0bda7fdb6c55acfcb2462358d5af3bc7cca1c201293aee749R49-R52)

## **Notes & Additional** **Information**

### **N-01 Inconsistent Error Handling**


For most subcommands, the <mark>`exec`</mark> function handles results uniformly by returning a

<mark>`CargoStylusResult`</mark> <mark>.</mark> However, for the <u><mark>`[replay](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/mod.rs#L83)`</mark></u> and <u><mark>`[usertrace](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/mod.rs#L86)`</mark></u> commands, the <mark>`exec`</mark>

function returns a <mark>`eyre::Result<()>`</mark> <mark>.</mark> Within <mark>`mod.rs`</mark> <mark>,</mark> <mark>`.map_err(Into::into)`</mark> is used

to convert the <mark>`eyre::Error`</mark> into a <mark>`CargoStylusError`</mark> <mark>.</mark>


To improve the overall quality of the codebase, consider having consistent returns and error

handling in different command executions.


**_Update:_** _[Resolved at commit 68f8ceb.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/382/commits/68f8ceb559901fbc677027d49489a5f9db104103)_

### **N-02 Unaddressed TODO Comments**


The TODO comment in line 73 of <u><mark>`[debug_hook.rs](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/debug_hook.rs#L73)`</mark></u> mentions functionality that has not yet

been implemented. Another unaddressed TODO comment was identified in <u>[line 531 of](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L531)</u>

<u><mark>`[replay.rs](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L531)`</mark></u> <mark>.</mark>


Consider addressing TODO comments that point to important unimplemented functionality. For

other TODO comments, consider clearly linking them to their respective issue in the issues

backlog.


**_Update:_** _[Resolved at commit 68f8ceb.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/382/commits/68f8ceb559901fbc677027d49489a5f9db104103)_


System Overview − Notes & Additional Information − 7


### **N-03 Hardcoded Extension in Error Messages**

In the <mark>`cargo_stylus::commands::replay`</mark> module, the <mark>`.so`</mark> file extension is hardcoded

in the error messages in lines <u>[330, 336, 617, and](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L330)</u> <u>[623.](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L623)</u>


Consider replacing the <mark>`.so`</mark> file extension with the value of the <mark>`extension`</mark> variable to clarify

the error messages based on the operating system.


**_Update:_** _[Resolved at commit 68f8ceb.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/382/commits/68f8ceb559901fbc677027d49489a5f9db104103)_

### **N-04 Redundant Contract Library Maps**


<mark>`ContractRegistry`</mark> maintains <u><mark>`[libraries](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L82-L85)`</mark></u> <u>and</u> <u><mark>`[library_paths](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L82-L85)`</mark></u> <u>maps</u> in parallel, which

increases coordination risk and can cause them to diverge over time.


Consider merging these fields and updating call sites to read from the unified entry.


**_Update:_** _[Resolved at commit 68f8ceb.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/382/commits/68f8ceb559901fbc677027d49489a5f9db104103)_

### **N-05 Unused stable_rust Flag**


The <mark>`Args`</mark> struct in <mark>`replay.rs`</mark> and <mark>`usertrace.rs`</mark> defines a <mark>`stable_rust`</mark> [[1 2] flag.](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L29)

However, this flag is never used in the respective <mark>`exec`</mark> functions.


Consider either using or removing any unused flags to improve the clarity and maintainability of

the codebase.


**_Update:_** _[Resolved at commit 68f8ceb.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/382/commits/68f8ceb559901fbc677027d49489a5f9db104103)_

### **N-06 Misleading Errors**


Throughout the codebase, multiple instances of misleading errors were identified:







The replay flow builds a <mark>`ContractRegistry`</mark> instance and then requires the top-level

transaction's <mark>`to`</mark> address to have a corresponding source/library in the registry. If the

source is not found, the flow bails in <u>[line 544](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L544)</u> with the message “Use --contracts flag”.

When <mark>`--contracts`</mark> is already provided but does not include the main address, this

message is inaccurate and confusing. Consider improving the error by detecting whether

<mark>`--contracts`</mark> was supplied, including the missing address and the set of provided

addresses, and then suggesting a fix.


System Overview − Notes & Additional Information − 8


The error message in <u>[line 486](https://github.com/OffchainLabs/stylus-sdk-rs/blob/8e2202ce703f0e2e1c93161d82c0ac25a230ab17/cargo-stylus/src/commands/replay.rs#L486)</u> of the <mark>`replay.rs`</mark> wrongly suggests that the error was

thrown in the <mark>`trace`</mark> command.



Consider updating any misleading or incorrect error messages.


**_Update:_** _[Resolved at commit 68f8ceb.](https://github.com/OffchainLabs/stylus-sdk-rs/pull/382/commits/68f8ceb559901fbc677027d49489a5f9db104103)_


System Overview − Notes & Additional Information − 9


## **Conclusion**

<u>[Pull request 370](https://github.com/OffchainLabs/stylus-sdk-rs/pull/370)</u> adds the <mark>`usertrace`</mark> command and extends the <mark>`replay`</mark> command with

multi-contract debugging, aiming to give developers clearer end-to-end visibility into Stylus

transaction execution. Overall, the new tooling moves the system toward richer cross-contract

observability and debugger integration.


One high-severity issue was identified, which leaves the newly added multi-contract debugging

non-functional. The codebase otherwise shows solid integration with only a few remaining

issues that need to be addressed.


System Overview − Conclusion − 10


## **Appendix**

### **Issue Classification**

OpenZeppelin classifies smart contract vulnerabilities on a 5-level scale:











Critical

High

Medium

Low

Note/Information



**Critical Severity**


This classification is applied when the issue’s impact is catastrophic, threatening extensive

damage to the client's reputation and/or causing severe financial loss to the client or users.

The likelihood of exploitation can be high, warranting a swift response. Critical issues typically

involve significant risks such as the permanent loss or locking of a large volume of users'

sensitive assets or the failure of core system functionalities without viable mitigations. These

issues demand immediate attention due to their potential to compromise system integrity or

user trust significantly.


**High Severity**


These issues are characterized by the potential to substantially impact the client’s reputation

and/or result in considerable financial losses. The likelihood of exploitation is significant,

warranting a swift response. Such issues might include temporary loss or locking of a

significant number of users' sensitive assets or disruptions to critical system functionalities,

albeit with potential, yet limited, mitigations available. The emphasis is on the significant but

not always catastrophic effects on system operation or asset security, necessitating prompt

and effective remediation.


**Medium Severity**


Issues classified as being of medium severity can lead to a noticeable negative impact on the

client's reputation and/or moderate financial losses. Such issues, if left unattended, have a

moderate likelihood of being exploited or may cause unwanted side effects in the system.


System Overview − Appendix − 11


These issues are typically confined to a smaller subset of users' sensitive assets or might

involve deviations from the specified system design that, while not directly financial in nature,

compromise system integrity or user experience. The focus here is on issues that pose a real

but contained risk, warranting timely attention to prevent escalation.


**Low Severity**


Low-severity issues are those that have a low impact on the client's operations and/or

reputation. These issues may represent minor risks or inefficiencies to the client's specific

business model. They are identified as areas for improvement that, while not urgent, could

enhance the security and quality of the codebase if addressed.


**Notes & Additional Information Severity**


This category is reserved for issues that, despite having a minimal impact, are still important to

resolve. Addressing these issues contributes to the overall security posture and code quality

improvement but does not require immediate action. It reflects a commitment to maintaining

high standards and continuous improvement, even in areas that do not pose immediate risks.


System Overview − Appendix − 12


