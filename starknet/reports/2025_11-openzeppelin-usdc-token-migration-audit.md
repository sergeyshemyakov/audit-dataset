### | security

# **USDC Token** **Migration Audit**

#### **November 28, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5


Security Model and Trust Assumptions _______________________________________________  5

Privileged Roles 6


Notes & Additional Information ______________________________________________________  7

N-01 allow_swap_to_legacy Is Overloaded 7

N-02 Lack of Indexed Event Parameters 7

N-03 Missing Documentation 8

N-04 Unnecessary Balance Checks 8

N-05 utils.cairo Is Empty and Unused 9


Conclusion ______________________________________________________________________ 10


Appendix _______________________________________________________________________ 11

Issue Classification 11


USDC Token Migration Audit − Table of Contents − 2


## **Summary**

**Type** DeFi


**Timeline** From 2025-11-11
To 2025-11-12


**Languages** Cairo



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


0 (0 resolved)



**Total Issues** 5 (4 resolved)



**Low Severity Issues** 0 (0 resolved)



**Notes & Additional**
**Information**



5 (4 resolved)



USDC Token Migration Audit − Summary − 3


## **Scope**

[OpenZeppelin audited the starkware-libs/usdc-migration](https://github.com/starkware-libs/usdc-migration) repository at commit <u>[de1489d.](https://github.com/starkware-libs/usdc-migration/tree/de1489d6a76966e25a99d46993f183c440080319)</u>


In scope were the following files:

```
packages/token_migration/src/
├── errors.cairo
├── events.cairo
├── interface.cairo
├── lib.cairo
├── starkgate_interface.cairo
├── token_migration.cairo
└── utils.cairo

```

USDC Token Migration Audit − Scope − 4


## **System Overview**

The token migration contract has been designed to facilitate an upgrade of the USDC token

that is widely used on Starknet. The USDC.e token is currently being used on Starknet, and it

represents USDC that exists on Ethereum but has been locked and bridged to Starknet.


[With the introduction of Circle's CCTP V2, USDC will no longer need to be bridged from](https://www.circle.com/blog/cctp-v2-the-future-of-cross-chain)

Ethereum. Instead, Circle will implement minting and burning of USDC on all CCTP-V2-enabled

chains. This will allow them to facilitate cross-chain transfers of assets, with no lock-up

required. Within the context of these contracts, USDC.e is known as the "legacy" token, while

the new CCTP-V2-enabled USDC is known as the "native" token. The native USDC token is

meant to eventually replace the legacy token. To support this, the migration contract has been

created.


This migration contract will allow users to send legacy USDC to it and receive native USDC in

an equal amount. This contract has a switchable "reverse swap" capability, which allows users

to swap from the native USDC back to the legacy one. The reverse swap can be enabled or

disabled by the migration contract owner. The migration contract also maintains a "legacy

buffer", which is a certain amount of legacy tokens that are kept in the migration contract.

When this buffer is exceeded by at least one "batch size", a "batch" of legacy USDC is sent

back across the token bridge to Ethereum, to a trusted L1 recipient contract.

## **Security Model and Trust** **Assumptions**


The following trust assumptions were identified during the audit:









It is assumed that the StarkGate bridge is operated correctly and that the migration

contract will only be deployed with the correct addresses for legacy and native USDC

tokens, as well as the correct L1 address being set for <mark>`l1_recipient`</mark> <mark>.</mark>

It is assumed that the <mark>`owner`</mark> is a trusted entity controlled by Starkware, and the private

keys associated with it are securely stored.


USDC Token Migration Audit − System Overview − 5


It is assumed that all code outside the scope of this audit behaves as documented. This

includes the StarkGate token bridge, the Staknet sequencer, and any contracts deployed

on Ethereum.


### **Privileged Roles**

The <mark>`owner`</mark> of the migration contract can control:














upgrades to the migration contract

all tokens that get transferred to the migration contract

whether reverse swaps are enabled or disabled

the size and number of batches for the legacy buffer, determining how many tokens

remain on StarkNet, and when they are bridged to Ethereum

the <mark>`l1_recipient`</mark> which receives the legacy tokens that are transferred back to

Ethereum from StarkNet

the <mark>`token_supplier`</mark> which provides either legacy or new tokens during migration


USDC Token Migration Audit − Security Model and Trust Assumptions − 6


## **Notes & Additional** **Information**

### **N-01 allow_swap_to_legacy Is Overloaded**

The <mark>`allow_swap_to_legacy`</mark> identifier is both a <u>[storage variable](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/token_migration.cairo#L62)</u> [and a function name. The](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/token_migration.cairo#L195)

function allows for the setting of the storage value with the same name.


To disambiguate the two and to follow the pattern of function names beginning with <mark>`set...`</mark> <mark>,</mark>

consider renaming <u>the</u> <u><mark>`[allow_swap_to_legacy](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/token_migration.cairo#L195)`</mark></u> <u>function</u> to

<mark>`set_allow_swap_to_legacy`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #114](https://github.com/starkware-libs/usdc-migration/pull/114)_ _[at commit 13bdbf0.](https://github.com/starkware-libs/usdc-migration/commit/13bdbf0c2ad87efecda6b931b7642d82a99b0fe3)_

### **N-02 Lack of Indexed Event Parameters**


In <mark>`events.cairo`</mark> <mark>,</mark> multiple instances of events without indexed parameters were identified:











The <u><mark>`[L1RecipientVerified](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L15-L18)`</mark></u> event

The <u><mark>`[TokenSupplierSet](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L20-L23)`</mark></u> event

The <u><mark>`[LegacyBufferSet](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L25-L29)`</mark></u> event

The <u><mark>`[BatchSizeSet](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L31-L35)`</mark></u> event

The <u><mark>`[SendToL1Failed](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L37-L40)`</mark></u> event



Consider indexing event parameters using <mark>`#[key]`</mark> to improve the ability of off-chain services

to search and filter for specific events.


**_Update:_** _Acknowledge, not resolved. The Starkware team stated:_


_This is intentional. We don't expect any benefit from the events being indexed, and the_

_presentation in the block explorer is worse, so we prefer them not being indexed._


USDC Token Migration Audit − Notes & Additional Information − 7


### **N-03 Missing Documentation**

Throughout the codebase, multiple instances of missing documentation were identified:













In <mark>`token_migration.cairo`</mark> <mark>,</mark> the <u><mark>`[upgrade](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/token_migration.cairo#L116)`</mark></u> function

In <mark>`events.cairo`</mark> <mark>,</mark> the <u><mark>`[TokenMigrated](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L5)`</mark></u> event

In <mark>`events.cairo`</mark> <mark>,</mark> the <u><mark>`[L1RecipientVerified](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L16)`</mark></u> event

In <mark>`events.cairo`</mark> <mark>,</mark> the <u><mark>`[TokenSupplierSet](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L21)`</mark></u> event

In <mark>`events.cairo`</mark> <mark>,</mark> the <u><mark>`[LegacyBufferSet](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L26)`</mark></u> event

In <mark>`events.cairo`</mark> <mark>,</mark> the <u><mark>`[BatchSizeSet](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L32)`</mark></u> event

In <mark>`events.cairo`</mark> <mark>,</mark> the <u><mark>`[SendToL1Failed](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/events.cairo#L38)`</mark></u> event



Consider thoroughly documenting all functions and events, including their parameters and

return values, that form part of a contract’s public API.


**_Update:_** _[Resolved in pull request #116](https://github.com/starkware-libs/usdc-migration/pull/116)_ _[at commit c9970e7.](https://github.com/starkware-libs/usdc-migration/commit/c9970e7a6e09d2beb7ffc2f4df4c508179ae48f2)_

### **N-04 Unnecessary Balance Checks**


When executing the internal <u><mark>`[swap](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/token_migration.cairo#L213)`</mark></u> [function, balance checks](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/token_migration.cairo#L223-L235) are performed for both the user

executing the swap and the token supplier. However, these are unnecessary because, if the

migrator tries to transfer more funds than held by the sender, the token implementation will

make the transaction revert. Furthermore, since this migrator is designed exclusively for

USDC.e and USDC, the behavior of the tokens is predictable and will revert unless the exact

amount of tokens is successfully transferred. Hence, these are superfluous checks that only

increase gas costs.


Consider removing the aforementioned balance checks. Alternatively, if the token migration

contract is intended to ever be used with tokens that may charge fees or not revert upon failing

transfers, consider keeping the checks in place and reflecting in the documentation the fact

that the token migration contract is designed for general purposes (rather than just for USDC).


**_Update:_** _[Resolved in pull request #115](https://github.com/starkware-libs/usdc-migration/pull/115)_ _[at commit 36a5d2a. Documentation comments were](https://github.com/starkware-libs/usdc-migration/commit/36a5d2a4c4bb21cbb0bdc679922037c0ba90f3e5)_

_added instead of changing or removing balance checks._


_The balance check are to stay. We added comments letting the reader better understand_

_why._


USDC Token Migration Audit − Notes & Additional Information − 8


### **N-05 utils.cairo Is Empty and Unused**

The <u><mark>`[utils.cairo](https://github.com/starkware-libs/usdc-migration/blob/de1489d6a76966e25a99d46993f183c440080319/packages/token_migration/src/utils.cairo)`</mark></u> file is empty and is unused within the codebase.


Consider removing <mark>`utils.cairo`</mark> to improve the clarity and maintainability of the code

repository.


**_Update:_** _[Resolved in pull request #113](https://github.com/starkware-libs/usdc-migration/pull/113)_ _[at commit c73cf0e.](https://github.com/starkware-libs/usdc-migration/commit/c73cf0eca16528e365b99a06659deda2810b9667)_


USDC Token Migration Audit − Notes & Additional Information − 9


## **Conclusion**

The code under review comprises a token migration contract that is meant to aid Starknet

users in migrating their USDC.e (legacy token) tokens to USDC (native token) without having to

withdraw them on L1 themselves.


Overall, only a few issues were identified in this short engagement, with no critical- or high
severity issues reported. A few recommendations were also made to improve code quality and

encourage thoughtful management of the contract once it goes live. The auditors were pleased

to see a thoroughly documented and concisely designed codebase.


Beyond the recommendations made here, the Starkware team is encouraged to monitor the

migration contract closely and implement plans to "shut down" the contract quickly if

suspicious behavior is detected. Shutdown can be achieved by setting the <mark>`token_supplier`</mark>

value to `0` . In addition, all transfers of tokens out of the migration contract should be

monitored, and a corresponding, equal transfer of tokens into the migration contract should be

ensured. Apart from this, it should be ensured that all batch transfers arrive on L1 correctly,

and that the buffer is not exceeded by more than one batch size.


The Starknet team is appreciated for being highly responsive to the questions posed by the

audit team and sharing comprehensive documentation about the project.


USDC Token Migration Audit − Conclusion − 10


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


USDC Token Migration Audit − Appendix − 11


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


USDC Token Migration Audit − Appendix − 12


