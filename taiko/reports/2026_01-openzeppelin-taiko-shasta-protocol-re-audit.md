### | security

# **Taiko Shasta** **Protocol Re Audit**

#### **January 19, 2026**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  6

L1 Core and Inbox 6

Proof Verification Architecture 7

L2 Anchor and Signal Service 7

Preconfirmation Whitelist 7


Security Model and Trust Assumptions _______________________________________________  8


Low Severity ____________________________________________________________________ 10

L-01 Misleading documentation 10

L-02 Imprecise Error 10

L-03 Incorrect Storage Gap 11


Notes & Additional Information ____________________________________________________ 11

N-01 Code Simplification 11

N-02 Code Consistency 11

N-03 Naming Suggestions 12


Conclusion ______________________________________________________________________ 13


Appendix _______________________________________________________________________ 14

Rollup Stages 14

Issue Classification 14


Taiko Shasta Protocol Re Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2 & Rollups


**Timeline** From 2025-12-15
To 2025-12-24


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


0 (0 resolved)



**Total Issues** 6 (5 resolved, 1 partially resolved)



**Low Severity Issues** 3 (3 resolved)



**Notes & Additional**
**Information**



3 (2 resolved, 1 partially resolved)



Taiko Shasta Protocol Re Audit − Summary − 3


## **Scope**

OpenZeppelin performed a diff audit of the <u>[taikoxyz/taiko-mono](https://github.com/taikoxyz/taiko-mono)</u> repository, <u>[comparing](https://github.com/taikoxyz/taiko-mono/compare/503445678a4bd875d761e56ba80a29a5b8e68d6e...430b33250093b653515af18677ad7fdc1de195c8)</u> the

[BASE commit 5034456](https://github.com/taikoxyz/taiko-mono/commit/503445678a4bd875d761e56ba80a29a5b8e68d6e) [with the HEAD commit 430b332. During the audit, the diff](https://github.com/taikoxyz/taiko-mono/commit/430b33250093b653515af18677ad7fdc1de195c8) <u>[comparing](https://github.com/taikoxyz/taiko-mono/compare/430b33250093b653515af18677ad7fdc1de195c8...18c7ab01bc74eea7071f964e8b7cd4bf288df6f6)</u>

[the BASE commit 430b332](https://github.com/taikoxyz/taiko-mono/commit/430b33250093b653515af18677ad7fdc1de195c8) [and HEAD commit 2ad7378](https://github.com/taikoxyz/taiko-mono/commit/2ad737834877ef0fd36f96437313d013db8954eb) was also added to the scope. The files

below are annotated with full (commit <u>[430b332), diff 1 (5034456...430b332), and diff 2](https://github.com/taikoxyz/taiko-mono/commit/430b33250093b653515af18677ad7fdc1de195c8)</u>

[(430b332...2ad7378) depending on when they were reviewed.](https://github.com/taikoxyz/taiko-mono/commit/430b33250093b653515af18677ad7fdc1de195c8)

```
packages/protocol/contracts
├── layer1
│  ├── core
│  │  ├── iface
│  │  │  ├── IBondManager.sol (diff 2)
│  │  │  ├── ICodec.sol (diff 1 & 2)
│  │  │  ├── IForcedInclusionStore.sol (diff 1)
│  │  │  ├── IInbox.sol (diff 1 & 2)
│  │  │  └── IProverWhitelist.sol (full)
│  │  ├── impl
│  │  │  ├── Codec.sol (full)
│  │  │  ├── Inbox.sol (full & diff 2)
│  │  │  ├── ProverWhitelist.sol (full)
│  │  └── libs
│  │    ├── LibBonds.sol (diff 2)
│  │    ├── LibBlobs.sol (diff 1)
│  │    ├── LibForcedInclusion.sol (diff 1)
│  │    ├── LibHashOptimized.sol (diff 1)
│  │    ├── LibInboxSetup.sol (full & diff 2)
│  │    ├── LibPackUnpack.sol (diff 1)
│  │    ├── LibProposeInputCodec.sol (diff 1)
│  │    ├── LibProposedEventCodec.sol (diff 1)
│  │    ├── LibProveInputCodec.sol (diff 1)
│  │    └── LibTransitionCodec.sol (full)
│  ├── mainnet
│  │  └── MainnetInbox.sol (diff 1 & 2)
│  ├── preconf
│  │  └── impl
│  │    └── PreconfWhitelist.sol (diff 1)
│  └── verifiers
│    ├── IProofVerifier.sol (diff 1)
│    ├── LibPublicInput.sol (diff 1)
│    ├── Risc0Verifier.sol (diff 1)
│    ├── SP1Verifier.sol (diff 1)
│    ├── SgxVerifier.sol (diff 1)
│    └── compose
│      └── ComposeVerifier.sol (diff 1)
├── layer2
│  └── core
│    ├── Anchor.sol (diff 1 & 2)

```

Taiko Shasta Protocol Re Audit − Scope − 4


```
│    ├── AnchorForkRouter.sol (diff 1)
│    ├── BondManager.sol (full)
│    ├── IBondManager.sol (diff 1)
│    └── IBondProcessor.sol (full)
└── shared
├── fork-router
│  └── ForkRouter.sol (diff 1)
└── signal
└── SignalService.sol (diff 1)

```


Taiko Shasta Protocol Re Audit − Scope − 5


## **System Overview**

The Taiko Shasta protocol is a "Based Rollup" architecture that leverages Ethereum (L1) for

sequencing and data availability while executing state transitions on a Layer 2 (L2) network.

The system is designed to be permissionless and decentralized, utilizing a multi-proof

mechanism that combines Trusted Execution Environments (SGX) and Zero-Knowledge Proofs

(ZK-SNARKs/STARKs) to verify L2 state transitions on L1.

### **L1 Core and Inbox**


The <mark>`Inbox`</mark> contract serves as the central entry point for the protocol on Layer 1. It acts as the

anchor for the L2 chain, managing the proposal of new blocks, the submission of validity

proofs, and the finalization of the chain state.













**Block Proposal** : <mark>`Inbox`</mark> accepts L2 block proposals, which include transaction data

blobs. It enforces sequencing rules and interacts with the <mark>`PreconfWhitelist`</mark> (via the

<mark>`IProposerChecker`</mark> interface) to validate authorized proposers during specific

windows.

**Proof Verification** : The contract coordinates the verification of state transitions. It

supports a modular verification architecture where different proof types (SGX, Risc0,

SP1) are routed to their respective verifiers.

**Bond Management** : Instead of a standalone manager, <mark>`Inbox`</mark> integrates <mark>`LibBonds`</mark> to

handle the economic security of the protocol. It manages Taiko Token (TKO) deposits,

withdrawals, and the slashing of liveness bonds for provers who fail to submit proofs

within the designated window.

**Forced Inclusions** : The system implements a censorship-resistance mechanism allowing

users to force transaction inclusion directly via L1 if L2 proposers are unresponsive.

<mark>`Inbox`</mark> queues these requests and enforces their processing.


Taiko Shasta Protocol Re Audit − System Overview − 6


### **Proof Verification Architecture**

The verification layer is modular, allowing for flexible security configurations. It consists of

specific verifier implementations and a composition layer.









**<mark>`ComposeVerifier`</mark>** <mark>:</mark> An abstract verifier that aggregates multiple sub-verifiers (e.g.,

requiring both an SGX proof and a ZK proof). It ensures that a state transition is

considered valid only if all required sub-verifiers approve it.

**Specific Verifiers** :




- **<mark>`SgxVerifier`</mark>** <mark>:</mark> Verifies signatures from attested SGX enclaves. It maintains a

registry of valid instances and handles the expiration of attestations to prevent

side-channel attacks.




- **<mark>`Risc0Verifier`</mark>** **&** **<mark>`SP1Verifier`</mark>** <mark>:</mark> These contracts verify ZK proofs generated



by the RISC Zero and SP1 zkVMs, respectively. They validate that the execution

trace matches the public inputs derived from <mark>`Inbox`</mark> <mark>'</mark> s state.

### **L2 Anchor and Signal Service**


On L2, the protocol maintains synchronization with L1 and facilitates cross-chain

communication.











**<mark>`Anchor`</mark>** <mark>:</mark> This contract is responsible for anchoring L1 block data onto L2. It validates

and stores L1 checkpoints (block hash, state root), providing the L2 chain with a trusted

view of the L1 state. It utilizes a "Golden Touch" address to ensure that only protocol
authorized transactions can update the anchor state.

**<mark>`SignalService`</mark>** <mark>:</mark> A general-purpose cross-chain messaging protocol. It allows

contracts on one layer to "send signals" (store data) and prove on the other layer that a

signal was sent. This underpins the bridge and other cross-chain applications.

**<mark>`ForkRouter`</mark>** <mark>:</mark> A utility framework used to manage protocol upgrades. It routes calls

between legacy and new implementations using <mark>`delegatecall`</mark> <mark>,</mark> allowing specific

functionalities (like the Anchor) to be upgraded while preserving storage layout

compatibility.


### **Preconfirmation Whitelist**

The <mark>`PreconfWhitelist`</mark> contract acts as a gatekeeper for block proposers. It manages a set

of active operators who are authorized to provide pre-confirmations. This contract determines


Taiko Shasta Protocol Re Audit − System Overview − 7


who is allowed to propose blocks to the Inbox during the exclusive submission window,

enabling a pre-confirmation layer before L1 sequencing.

## **Security Model and Trust** **Assumptions**


The Taiko Shasta protocol relies on the security of the underlying Ethereum L1 for data

availability and transaction ordering. The system's security model combines economic

incentives (bonds) with cryptographic and hardware-based proofs to ensure state validity.

While striving for decentralization, the current iteration relies on specific governance controls

and trusted hardware assumptions.


The critical trust assumptions and security model components are as follows:











**L1 Security** : The system assumes that Ethereum L1 is secure, censorship-resistant, and

that its history is immutable. L1 is the ultimate source of truth for the canonical L2 chain.

**Governance and Privileged Roles** :

  - **Owner/DAO** : The protocol includes an <mark>`Owner`</mark> role (a DAO or multi-sig) with the

power to upgrade contracts and update verifier configurations (e.g., adding trusted

SGX instances or ZK verification keys).

  - **Prover Whitelist** : If enabled, the system relies on a whitelist of authorized provers.

There is a fallback mechanism to allow permissionless proving if the whitelisted

provers colluding to censor or halt the chain.

  - **Preconf Operators** : The entities managed by the <mark>`PreconfWhitelist`</mark> are

trusted to provide fair pre-confirmations and not to abuse their exclusive proposal

windows.

**Verifier and Circuit Correctness** :

  - **Trusted Execution Environments (TEE)** : The <mark>`SgxVerifier`</mark> contract assumes

that Intel SGX hardware is secure and that the remote attestation process is not

compromised. It assumes the enclave code correctly implements the protocol

rules.

  - **Zero-Knowledge Circuits** : The <mark>`Risc0Verifier`</mark> and <mark>`SP1Verifier`</mark> contracts

assume that the underlying ZK circuits correctly constrain the state transition

function and that the verifier contracts correctly implement the verifier logic for the

respective proof systems.


Taiko Shasta Protocol Re Audit − Security Model and Trust Assumptions − 8


**Economic Security** :

  - **Bond Sufficiency** : It is assumed that the <mark>`minBond`</mark> and <mark>`livenessBond`</mark> values

are set sufficiently high to make spamming or griefing attacks economically

irrational for proposers and provers.

  - **Rational Actors** : The protocol assumes that provers and proposers are rational

actors motivated by profit (fees and rewards) and deterred by slashing penalties.

**Data Availability** : The system relies on Ethereum's EIP-4844 (blobs) for data availability.

It is assumed that blob data is available for a sufficient period to allow provers to derive

the chain state and generate proofs.

**Cross-Chain Integrity** :

  - The <mark>`Anchor`</mark> contract assumes the integrity of the data provided by the "Golden

Touch" transaction, which is generated by the protocol's node software.

  - The <mark>`SignalService`</mark> relies on the correctness of Merkle proofs to verify cross
chain messages, assuming that the root hash anchored on the destination chain is

correct.


Taiko Shasta Protocol Re Audit − Security Model and Trust Assumptions − 9


## **Low Severity**

### **L-01 Misleading documentation**

Throughout the codebase, multiple instances of misleading documentation were identified. For

instance, the <mark>`Derivation.md`</mark> description:












<u>[incorrectly states](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/docs/Derivation.md?plain=1#L231)</u> that <mark>`isForcedInclusion`</mark> should be <mark>`false`</mark> when discussing forced

inclusion sources

still <u>[refers](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/docs/Derivation.md?plain=1#L259)</u> to the obsolete "bond instruction" concept. It correctly describes the L1

behavior, but it is listed as a subsection under "Metadata Validation and Computation"

<u>[references](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/docs/Derivation.md?plain=1#L319)</u> a non-existent <mark>`ShastaAnchor`</mark> contract

<u>[omits](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/docs/Derivation.md?plain=1#L22)</u> the <mark>`parentProposalHash`</mark> and <mark>`endOfSubmissionWindowTimestamp`</mark> fields

from its proposal-level metadata tables, despite these being present in the on-chain

<u><mark>`[Proposal](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/iface/IInbox.sol#L68-L73)`</mark></u> <u>struct</u> and <u><mark>`[Proposed](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/iface/IInbox.sol#L191-L192)`</mark></u> <u>event.</u>



In addition, the <u><mark>`[Checkpoint](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/shared/signal/ICheckpointStore.sol#L12-L20)`</mark></u> <u>struct</u> fields are described as L2 data, but it is <u>[also used](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer2/core/Anchor.sol#L173)</u> for L1

checkpoints.


Lastly, the <mark>`minCheckpointDelay`</mark> is <u>[described as less than](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/iface/IInbox.sol#L47)</u> a "finalization grace period", but

it is <u>[configured](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/mainnet/MainnetInbox.sol#L53-L60)</u> to be larger than <mark>`maxProofSubmissionDelay`</mark> and it is not clear which other

variable the grace period refers to. Any such requirement should be enforced when <u>[validating](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/libs/LibInboxSetup.sol#L24)</u>

<u>[the configuration.](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/libs/LibInboxSetup.sol#L24)</u>


Consider updating the documentation accordingly.


**_Update:_** _[Resolved in pull request #21161.](https://github.com/taikoxyz/taiko-mono/pull/21161)_

### **L-02 Imprecise Error**


The <mark>`ProverWhitelistedAlready`</mark> error suggests the owner is attempting to whitelist a

whitelisted address. However, the error <u>[is also used](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/impl/ProverWhitelist.sol#L49)</u> when the owner attempts to remove an

address that is not yet whitelisted.


Consider updating the <mark>`ProverWhitelistedAlready`</mark> error to account for both cases.


**_Update:_** _[Resolved in pull request #21162. The team stated:](https://github.com/taikoxyz/taiko-mono/pull/21162)_


Taiko Shasta Protocol Re Audit − Low Severity − 10


_Implemented 2 different errors._

### **L-03 Incorrect Storage Gap**


The <mark>`Anchor`</mark> contract's <u>[state variables](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer2/core/Anchor.sol#L56-L69)</u> occupy 7 storage slots. However, the <u><mark>`[__gap](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer2/core/Anchor.sol#L71-L72)`</mark></u> <u>variable</u>

only pads this to 48 (instead of the standard 50).


Consider increasing the gap variable accordingly.


**_Update:_** _[Resolved in pull request #21163. The team stated:](https://github.com/taikoxyz/taiko-mono/pull/21163)_


_Updated the contract to use the remaining slots._

## **Notes & Additional** **Information**

### **N-01 Code Simplification**


The <u><mark>`[_getAvailableCapacity](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/impl/Inbox.sol#L722)`</mark></u> <u>function</u> is only ever used to <u>[check if there is any available](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/impl/Inbox.sol#L541)</u>

<u>[capacity.](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/impl/Inbox.sol#L541)</u>


Consider replacing the <mark>`_getAvailableCapacity`</mark> function with an <mark>`_isSpaceAvailable`</mark>

check that simply returns <mark>`_ringBufferSize > _nextProposalId -`</mark>

<mark>`_lastFinalizedProposalId`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #21166.](https://github.com/taikoxyz/taiko-mono/pull/21166)_

### **N-02 Code Consistency**


The <mark>`forcedInclusionDelay`</mark> field of the <mark>`Inbox`</mark> config struct is set to <mark>`384`</mark> instead of <mark>`384`</mark>

<mark>`seconds`</mark> <mark>.</mark> This is inconsistent with how other duration fields are set.


For consistency, consider specifying the <u>[forced inclusion delay](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/mainnet/MainnetInbox.sol#L57)</u> as <mark>`384 seconds`</mark> instead of

just <mark>`384`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #21164. The team stated:](https://github.com/taikoxyz/taiko-mono/pull/21164)_


Taiko Shasta Protocol Re Audit − Notes & Additional Information − 11


_Used explicit seconds as a unit._

### **N-03 Naming Suggestions**


Throughout the codebase, multiple opportunities for improve naming were identified:










<u><mark>`[lastProposalBlockId](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/impl/Inbox.sol#L215)`</mark></u> could be named <mark>`lastProposalL1BlockNumber`</mark> <mark>.</mark>

<u>[Some fields](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/contracts/layer1/core/iface/IInbox.sol#L91-L99)</u> in the <mark>`CoreState`</mark> struct refer to proposal finalization. However, finalization

is achieved with proving and is no longer an independent phase. Thus, the naming can

be adjusted to "proven" or similar.

<u><mark>`[PROPOSAL_MAX_BLOCKS](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/docs/Derivation.md#L356)`</mark></u> could be renamed to <mark>`DERIVATION_SOURCE_MAX_BLOCK`</mark> in

line with its <u>[actual usage.](https://github.com/taikoxyz/taiko-mono/blob/18c7ab01bc74eea7071f964e8b7cd4bf288df6f6/packages/protocol/docs/Derivation.md#L160)</u>



Consider implementing the above renaming suggestions to improve code clarity and

maintainability.


**_Update:_** _[Partially Resolved in pull request #21165. The Taiko team changed the wording of the](https://github.com/taikoxyz/taiko-mono/pull/21165)_

_documentation, while the code remains the same. The team stated:_


_Updated, but avoid doing ABI breaking changes._


Taiko Shasta Protocol Re Audit − Notes & Additional Information − 12


## **Conclusion**

This audit covered the Shasta protocol version of the Taiko Based Rollup in a 12-day

engagement. Overall, the codebase appears to be in good shape and demonstrates a robust

security posture. The findings are limited to low- and note-severity issues.


The Taiko team is commended for being very helpful and responsive throughout the

engagement, providing clear insights into the system's design and architecture.


Taiko Shasta Protocol Re Audit − Conclusion − 13


## **Appendix**

### **Rollup Stages**

[L2Beat includes a set of criteria](https://l2beat.com/stages) for classifying rollups into stages of maturity. The design of the

system naturally satisfies all Stage 0 criteria.


With respect to the Stage 1 criteria, the Taiko team intends to:










deploy the new inbox

configure it with a working Verifier contract

activate it

transfer ownership to the <mark>`TaikoDAOController`</mark>



Once this occurs, the only ways to make invalid L2 withdrawals will be to:








maliciously upgrade the inbox contract, or

change the verifier contract (or function image it verifies against).



This will require action from the <mark>`TaikoDAOController`</mark> contract, which meets all the Stage 1

requirements:








6 of 8 (75%) security council members are required to make an emergency proposal.

Regular proposals will take effect 7 days after they are passed.



The codebase currently utilizes a prover whitelist. However, **<u>[pull request #21146](https://github.com/taikoxyz/taiko-mono/pull/21146)</u>** **introduces a**

**permissionless fallback mechanism** . Thus, if whitelisted provers fail to prove a block within

the configured <mark>`permissionlessProvingDelay`</mark> (set to 72 hours), proving becomes open to

anyone. This ensures that whitelisted provers cannot halt the chain indefinitely. Since this 3
day delay is strictly shorter than the 7-day governance timelock, users retain the ability to exit

even in a censorship scenario, making the system compatible with Stage 1 requirements.

### **Issue Classification**


OpenZeppelin classifies smart contract vulnerabilities on a 5-level scale:








Critical

High



Taiko Shasta Protocol Re Audit − Appendix − 14


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

These issues are typically confined to a smaller subset of users' sensitive assets or might

involve deviations from the specified system design that, while not directly financial in nature,

compromise system integrity or user experience. The focus here is on issues that pose a real

but contained risk, warranting timely attention to prevent escalation.


**Low Severity**


Low-severity issues are those that have a low impact on the client's operations and/or

reputation. These issues may represent minor risks or inefficiencies to the client's specific

business model. They are identified as areas for improvement that, while not urgent, could

enhance the security and quality of the codebase if addressed.


Taiko Shasta Protocol Re Audit − Appendix − 15


**Notes & Additional Information Severity**


This category is reserved for issues that, despite having a minimal impact, are still important to

resolve. Addressing these issues contributes to the overall security posture and code quality

improvement but does not require immediate action. It reflects a commitment to maintaining

high standards and continuous improvement, even in areas that do not pose immediate risks.


Taiko Shasta Protocol Re Audit − Appendix − 16


