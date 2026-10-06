### | security

# **Taiko Ontake** **Fork Audit**

#### **November 13, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5

Code Complexity 5


Security Model and Trust Assumptions _______________________________________________  6

Integration With the Protocol 6


Medium Severity ___________________________________________________________________  7

M-01 Inconsistent Use of State Roots 7

M-02 Batch Proofs Cannot Be Composed 7

M-03 Cannot Send Tip for Batch Proposals 8


Low Severity ______________________________________________________________________  8

L-01 Incorrect Error 8

L-02 Incorrect Fork Check 8

L-03 Lack of Event Emission 9

L-04 Incomplete Docstrings 9

L-05 Misleading Inline Documentation 10

L-06 Missing Docstrings 10

L-07 Inconsistency Between lastUnpausedAt Variables 11


Notes & Additional Information ____________________________________________________ 11

N-01 Leftover Code In Comments 11

N-02 Unused Errors 12

N-03 Use of Magic Numbers 12

N-04 Incomplete Genesis Block 12

N-05 Unusable ETH Withdrawal Functionality 13

N-06 Incomplete Resizing 13

N-07 Typographical Errors 13

N-08 Naming Suggestions 13

N-09 Code Simplifications 14


Recommendations _______________________________________________________________ 14

Test Suite Could Be Improved 14


Conclusion ______________________________________________________________________ 16


Taiko Ontake Fork Audit − Table of Contents − 2


## **Summary**

**Type** Rollup


**Timeline** From 2024-09-30
To 2024-10-18


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


3 (3 resolved)



**Total Issues** 19 (19 resolved)



**Low Severity Issues** 7 (7 resolved)



**Notes & Additional**
**Information**



9 (9 resolved)



Taiko Ontake Fork Audit − Summary − 3


## **Scope**

We audited the <u>[taikoxyz/taiko-mono-oz-audit](https://github.com/taikoxyz/taiko-mono-oz-audit)</u> repository at commit <u>[fd1c039.](https://github.com/taikoxyz/taiko-mono-oz-audit/tree/fd1c0391045b51b41eba45f2fcdff24fc4d2346e)</u>


In scope were the following files. For files marked with _(diff)_, we only reviewed the changes

made since the previous audit commit <u>[b47fc34.](https://github.com/taikoxyz/taiko-mono-oz-audit/tree/b47fc34cb0e7fe9b7ebd9416b3051a067483b860)</u>

```
contracts
├── layer1
│  ├── based
│  │  ├── LibBonds.sol
│  │  ├── LibData.sol
│  │  ├── LibProposing.sol (diff)
│  │  ├── LibProving.sol (diff)
│  │  ├── LibUtils.sol (diff)
│  │  ├── LibVerifying.sol (diff)
│  │  ├── TaikoData.sol (diff)
│  │  └── TaikoL1.sol (diff)
│  └── verifiers
│    └── compose
│      ├── ComposeVerifier.sol
│      ├── TeeAnyVerifier.sol
│      ├── ZkAndTeeVerifier.sol
│      └── ZkAnyVerifier.sol
└── layer2
└── based
├── Lib1559Math.sol (diff)
└── TaikoL2.sol (diff)

```

Taiko Ontake Fork Audit − Scope − 4


## **System Overview**

The Taiko protocol has already been described in our <u>[previous audit report. This audit focussed](https://blog.openzeppelin.com/taiko-protocol-audit)</u>

on the features introduced by the Ontake fork.


The main changes introduced are aimed at supporting preconfirmations, where L1 proposers

make off-chain commitments to the transactions they will include in their block. This is

achieved by requiring L1 proposers to register and lock the stake before they are allowed to

propose blocks. Their stake will be slashed if they fail to honor the preconfirmations, and

affected users may be compensated. Since not all L1 proposers will register, the L1 contracts

cannot advance every block. Instead, the next proposer in the schedule will be responsible for

issuing off-chain preconfirmations throughout all intermediate blocks. The proposers can also

delegate their preconfirmation ability to a dedicated preconfer service, which helps limit the

frequency of transitions between preconfers.


The registry, preconfer, and schedule logic features were not reviewed within this audit.

However, the main protocol was updated to support multi-block proposals as well as an ability

to prove multiple blocks, either with multiple proofs or a single batch proof. The codebase also

introduces a <mark>`ComposeVerifier`</mark> framework, which provides a flexible way to describe a

proof as a combination of subproofs. For example, the <mark>`TeeAnyVerifier`</mark> will accept one of

two different TEE proofs, the <mark>`ZkAnyVerifier`</mark> will accept one of two different ZK proofs, and

the <mark>`ZkAndTeeVerifier`</mark> requires both a TEE and a ZK proof. All verifiers also support a

single batch proof for multiple blocks.


Lastly, the L2 gas mechanism is now described using issuance per second, rather than per

block. This means that it is not affected by the frequency of blocks or variance in block time. It

is also possible to change the gas target on any anchor transaction.

### **Code Complexity**


The codebase has become more complex because it covers the transition to the Ontake fork.

There are several updates to the internal data structures, and the codebase converts or

chooses between them, depending on whether the relevant block should use the old or new

structure. Moreover, it also handles proving blocks that were proposed using a previous

version of the codebase, where some fields were assigned differently. Once the transition is

complete, a future update to reduce the branching would be recommended.


Taiko Ontake Fork Audit − System Overview − 5


## **Security Model and Trust** **Assumptions**

The main change to the security model relates to the preconfirmation registry and look-ahead

schedule, which are still being designed and were not reviewed in this audit.


One minor update is that when <mark>`ComposeVerifier`</mark> contracts are in use, the owner of the

<mark>`AddressManager`</mark> contract will set the relevant sub-verifier contracts. As with all the address

resolutions, users rely on them being set correctly and safely. This includes ensuring that only

trusted verifiers are registered and that there are no duplicates across any of the sub-verifiers

or that the same proof could be used repeatedly.

### **Integration With the Protocol**


One potentially unexpected behavior is that for simplicity, validity bonds are either taken

entirely from previous TKO deposits or are transferred entirely on demand. This means that

even if a deposit partially covers the required bond, users must have and approve sufficient

tokens for the whole bond. Of course, they can also top up the deposit beforehand, if desired.


Taiko Ontake Fork Audit − Security Model and Trust Assumptions − 6


## **Medium Severity**

### **M-01 Inconsistent Use of State Roots**

When proving a block, the <u>[state root is only saved on "sync blocks"](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L264-L266)</u> (currently configured to

every 16th block). All other blocks treat the state root as zero. However, the state root <u>[is](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L414)</u>

<u>[emitted](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L414)</u> as part of the event. If another prover attempts to dispute the state root (with the same

block hash), the code will <u>[interpret them as agreeing with the original transition. This also](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L371)</u>

means that verifiers <u>[may reject transitions](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L362-L364)</u> based on an unused state root. Moreover, all <u>[getters](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L200-L256)</u>

<u>[that return a state root](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L200-L256)</u> may unexpectedly return zero for non-sync blocks.


In the interest of maximum safety, we believe that verifiers should still consider the state root

for all blocks. However, for predictability and code clarity, consider treating state roots for non
sync blocks as zero consistently throughout the codebase. This would involve:


   - setting them to zero in the emitted events.

  - removing them from the <u><mark>`[sameTransition](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L371)`</mark></u> calculation.

   - documenting that they are intentionally set to zero in all the getters.


**_Update:_** _Resolved in_ _<u>[pull request #18303.](https://github.com/taikoxyz/taiko-mono/pull/18303)</u>_

### **M-02 Batch Proofs Cannot Be Composed**


The <mark>`verifyProof`</mark> function of the <mark>`ComposeVerifier`</mark> contract <u>[uses the](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L47)</u>

<u><mark>`[onlyAuthorizedCaller](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L47)`</mark></u> modifier, which allows descendant contracts to <u>[introduce](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/TeeAnyVerifier.sol#L15)</u>

<u>[additional authorized callers. However, the](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/TeeAnyVerifier.sol#L15)</u> <mark>`verifyBatchProof`</mark> function <u>[must be called by](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L81)</u>

<u>the</u> <u><mark>`[TaikoL1](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L81)`</mark></u> <u>contract. This means that the</u> <mark>`verifyBatchProof`</mark> function of the

<u><mark>`[ZkAndTeeVerifier](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ZkAndTeeVerifier.sol#L9)`</mark></u> is not authorized to <u>[invoke the sub-verifiers](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L103)</u> and is therefore non
functional.


Consider using the <mark>`onlyAuthorizedCaller`</mark> modifier in both of the aforementioned cases.


**_Update:_** _Resolved in_ _<u>[pull request #18302.](https://github.com/taikoxyz/taiko-mono/pull/18302)</u>_


Taiko Ontake Fork Audit − Medium Severity − 7


### **M-03 Cannot Send Tip for Batch Proposals**

When proposing a block, the caller can <u>[send a tip](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L317)</u> to the L1 <mark>`coinbase`</mark> address as an

incentive to include the transaction. However, the <mark>`proposeBlocks`</mark> function <u>[executes the](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L93)</u>

<u>[same line multiple times. This means that the contract attempts to tip](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L93)</u> <mark>`msg.value`</mark> for every

proposal. Since the extra funds would be taken from the <mark>`TaikoL1`</mark> contract, this could be

used to steal any available ETH. Fortunately, the <mark>`TaikoL1`</mark> contract is not expected to hold

ETH. Nevertheless, this means that if a tip is provided, the <mark>`proposeBlocks`</mark> function will

revert when processing the second block.


Consider ensuring that the tip is only sent when processing the first block in a batch.


**_Update:_** _Resolved at commit_ _<u>[ce76e66. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/pull/18150/commits/ce76e66f8751629d5267ccf9f8e3317a24e881d3)</u>_


_In the_ _<mark>`ontake_cleanup2`</mark>_ _branch, the tip payment code has been removed and_

_<mark>`proposeBlock`</mark>_ _(v1), the only payable function, is also removed._

## **Low Severity**

### **L-01 Incorrect Error**


The <mark>`verifyBatchProof`</mark> function <u>reverts with</u> <u><mark>`[CV_DUPLICATE_SUBPROOF](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L90)`</mark></u> when the

subproof specifies a zero verifier. This is incorrect because duplicate subproofs are prevented

by <u>[clearing valid verifiers](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L97)</u> once they are used, which would cause duplicates to <u>[trigger](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L101)</u> the

<mark>`CV_SUB_VERIFIER_NOT_FOUND`</mark> error.


Consider using the <mark>`CV_INVALID_SUB_VERIFIER`</mark> error for consistency with the <u>[equivalent](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L56)</u>

<u>[check](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/verifiers/compose/ComposeVerifier.sol#L56)</u> in the <mark>`verifyProof`</mark> function.


**_Update:_** _Resolved in_ _<u>[pull request #18305.](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_

### **L-02 Incorrect Fork Check**


The <mark>`proposeBlock`</mark> function is <u>[expected to be disabled](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L81)</u> after the Ontake fork. This check

does not work correctly because the <mark>`metaV1_`</mark> [return parameter is zero after the fork, so the](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L286)

condition actually requires 0 to be less than the <mark>`ontakeForkHeight`</mark> <mark>.</mark> This means that

<mark>`proposeBlock`</mark> will behave like <u>the</u> <u><mark>`[proposeBlockV2](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L85)`</mark></u> <u>function, except it will return an</u>


Taiko Ontake Fork Audit − Low Severity − 8


empty <mark>`meta_`</mark> parameter. In practice, if the <mark>`_params`</mark> buffer is encoded using the original

layout, then it would <u>[fail to decode correctly.](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L161)</u>


Consider using the <mark>`BlockMetadataV2`</mark> return parameter to retrieve the actual block ID.


**_Update:_** _Resolved in_ _<u>[pull request #18227](https://github.com/taikoxyz/taiko-mono/pull/18227)</u>_

### **L-03 Lack of Event Emission**


Events are a crucial mechanism for tracking and monitoring contract activity. Throughout the

codebase, instances of events not being emitted after sensitive actions were identified. For

example, other than the standard token transfer events, the <mark>`TaikoL1`</mark> contract does not emit

any specific events when <u>[depositing and withdrawing bonds.](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L165-L172)</u>


Consider emitting events after sensitive changes occur. This would help improve contract

monitoring and allow for early identification and resolution of potential issues.


**_Update:_** _Resolved in_ _<u>[pull request #18305](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_ _and_ _<u>[pull request #18443.](https://github.com/taikoxyz/taiko-mono/pull/18443)</u>_

### **L-04 Incomplete Docstrings**


Throughout the codebase, multiple instances of incomplete docstrings were identified:


   - None of the parameters in the <u><mark>`[verifyBlocks](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibVerifying.sol#L37-L189)`</mark></u> function are documented.

   - The <mark>`_user`</mark> parameter in the <u><mark>`[bondBalanceOf](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L176-L178)`</mark></u> function is not documented.

   - The <mark>`_config`</mark> parameter in the <u><mark>`[init](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L53)`</mark></u> function is not documented.

   - The <mark>`verifiedAt_`</mark> return value in the <u><mark>`[getBlockInfo](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L123)`</mark></u> function is not documented.


Consider thoroughly documenting all functions/events (and their parameters or return values)

that are part of a contract's public API. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #18320.](https://github.com/taikoxyz/taiko-mono/pull/18320/files)</u>_


Taiko Ontake Fork Audit − Low Severity − 9


### **L-05 Misleading Inline Documentation**

Throughout the codebase, multiple instances of potentially misleading inline documentation

were identified:


   - The <mark>`proveBlock`</mark> <mark>`_input`</mark> parameter comment <u>[describes the pre-fork structure. After](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L194)</u>

the fork, it should start with a <mark>`BlockMetadataV2`</mark> object.

   - The <u>first</u> <u><mark>`[getTransition](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L145)`</mark></u> <u>function comment</u> incorrectly mentions the <mark>`parentHash`</mark> <mark>.</mark>

   - The <u><mark>`[chain_pauser](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L298)`</mark></u> comment should refer to the chain watchdog.

   - An <u>[inline comment](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L290-L293)</u> within the <mark>`_proveBlock`</mark> function claims that a new transition will

have a transition ID of zero but it will be set to the <u>block's</u> <u><mark>`[nextTransitionId](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L512)`</mark></u> <mark>,</mark> which

is <u>[at least 1.](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L298)</u>

   - The <u><mark>`[TransitionState](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L148)`</mark></u> <u>comment</u> claims that slot 6 occupies 90 bits, but it uses 88.

   - The <u><mark>`[shouldVerifyBlocks](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L239-L241)`</mark></u> <u>code comment</u> states that verification will be performed on

blocks 3 and 7 for a segment of size 8, but it will be on blocks 0 and 4.


Clear inline documentation is fundamental for outlining the intention behind a piece of code.

Mismatches between the inline documentation and the implementation can lead to serious

misconceptions about how the system is expected to behave. Consider clarifying the

referenced inline documentation to avoid confusion for developers, users, and auditors alike.


**_Update:_** _Resolved in_ _<u>[pull request #18320.](https://github.com/taikoxyz/taiko-mono/pull/18320/files#)</u>_

### **L-06 Missing Docstrings**


Throughout the codebase, multiple instances of missing docstrings were identified:


   - In <mark>`Lib1559Math.sol`</mark> <mark>,</mark> the <u><mark>`[MAX_EXP_INPUT](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer2/based/Lib1559Math.sol#L15)`</mark></u> <u>state variable</u>

   - In <mark>`TaikoL1.sol`</mark> <mark>,</mark> the <u><mark>`[init2](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L59-L65)`</mark></u> <u>function</u>

   - In <mark>`TaikoL1.sol`</mark> <mark>,</mark> the <u><mark>`[proposeBlockV2](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L85-L98)`</mark></u> <u>function</u>

   - In <mark>`TaikoL2.sol`</mark> <mark>,</mark> the <u><mark>`[parentTimestamp](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer2/based/TaikoL2.sol#L44)`</mark></u> <u>state variable</u>

   - In <mark>`TaikoL2.sol`</mark> <mark>,</mark> the <u><mark>`[parentGasTarget](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer2/based/TaikoL2.sol#L45)`</mark></u> <u>state variable</u>

   - In <mark>`TaikoL2.sol`</mark> <mark>,</mark> the <u><mark>`[anchorV2](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer2/based/TaikoL2.sol#L163-L231)`</mark></u> <u>function</u>

   - In <mark>`TaikoL2.sol`</mark> <mark>,</mark> the <u><mark>`[ontakeForkHeight](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer2/based/TaikoL2.sol#L316-L318)`</mark></u> <u>function</u>


Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not public, should

be clearly documented as well. When writing docstrings, consider following the <u>[Ethereum](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u>

<u>[Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


Taiko Ontake Fork Audit − Low Severity − 10


**_Update:_** _Resolved in_ _<u>[pull request #18320.](https://github.com/taikoxyz/taiko-mono/pull/18320/files)</u>_

### **L-07 Inconsistency Between lastUnpausedAt** **Variables**


The <mark>`EssentialContract`</mark> contract, inherited by several of the contracts in the protocol such

as the <mark>`TaikoL1`</mark> contract, declares a global <u><mark>`[lastUnpausedAt](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/shared/common/EssentialContract.sol#L17)`</mark></u> <u>variable. This variable is used</u>

to update the timestamp when the <u>[contract has been unpaused. The](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/shared/common/EssentialContract.sol#L136)</u> <mark>`TaikoL1`</mark> contract

implements a similar variable inside the <u><mark>`[state.slotB](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L220)`</mark></u> <u>struct</u> which is also updated with the

same <u>[unpausing action.](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L273)</u>


However, this latest variable is also updated when <u>[unpausing the proving mechanism, while the](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L123)</u>

one from the <mark>`EssentialContract`</mark> contract is not. This means that both variables will go out

of sync under such an action. This could mislead anyone attempting to calculate <u>[when the](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L223)</u>

<u>[proving window is, because they might get different outcomes depending on which](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L223)</u>

<mark>`lastUnpausedAt`</mark> variable they checked. Moreover, it is worth noting that the

<mark>`EssentialContract`</mark> version remains unused within the codebase.


In order to improve the readability of the code, remove inconsistencies, and prevent erroneous

calculations, consider unifying them under a single variable, updating both in all corresponding

cases or renaming one to make it clear they have different functions.


**_Update:_** _Resolved in_ _<u>[pull request #18276.](https://github.com/taikoxyz/taiko-mono/pull/18276)</u>_

## **Notes & Additional** **Information**

### **N-01 Leftover Code In Comments**


Leftover code present in comments can negatively impact code clarity and maintainability. In

<u>[line 443](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L443)</u> of <mark>`LibProving.sol`</mark> <mark>,</mark> there is a comment containing unused code.


Consider removing the aforementioned instance of unused code or documenting its function.


**_Update:_** _Resolved in_ _<u>[pull request #18305.](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_


Taiko Ontake Fork Audit − Notes & Additional Information − 11


### **N-02 Unused Errors**

Throughout the codebase, multiple instances of unused errors were identified:


   - Within the <mark>`LibProposing`</mark> library, the <u><mark>`[L1_LIVENESS_BOND_NOT_RECEIVED](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e//packages/protocol/contracts/layer1/based/LibProposing.sol#L59)`</mark></u> <u>error</u>

   - Within the <mark>`LibVerifying`</mark> library, the <u><mark>`[L1_INVALID_CONFIG](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibVerifying.sol#L32)`</mark></u> and <u><mark>`[L1_TOO_LATE](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibVerifying.sol#L34)`</mark></u>

errors

   - Within the <mark>`LibUtils`</mark> library, the <u><mark>`[L1_BLOCK_MISMATCH](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L44)`</mark></u> <u>error</u>

   - Within the <mark>`TaikoL1`</mark> contract, the <u><mark>`[L1_INVALID_PARAMS](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoL1.sol#L28)`</mark></u> <u>error</u>


Consider either using or removing the aforementioned instances of unused errors.


**_Update:_** _Resolved in_ _<u>[pull request #18305.](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_

### **N-03 Use of Magic Numbers**


Throughout the codebase, multiple instances of unexplained magic numbers being used were

identified.


   - In the <mark>`LibProposing`</mark> library, the <u>[number 12](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L211)</u>

   - In the <mark>`LibUtils`</mark> library, the <u>[factor 60](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L223)</u>


To improve code clarity and readability, consider using named constants instead of magic

numbers.


**_Update:_** _Resolved in_ _<u>[pull request #18305.](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_

### **N-04 Incomplete Genesis Block**


The genesis block <u>defaults to a zero</u> <u><mark>`[proposedIn](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L67-L71)`</mark></u> <u>feldi</u> <u>. This makes sense after the fork, since</u>

there is no corresponding L1 anchor block. However, if it is set before the fork, it should <u>[be the](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L180)</u>

<u>[L1 proposal block number.](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L180)</u>


For consistency with the <u><mark>`[proposedAt](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibUtils.sol#L69)`</mark></u> <u>feldi</u> <u>, consider changing the value of the</u> <mark>`proposedIn`</mark>

field to be the current L1 block.


**_Update:_** _Resolved in_ _<u>[pull request #18312.](https://github.com/taikoxyz/taiko-mono/pull/18312)</u>_


Taiko Ontake Fork Audit − Notes & Additional Information − 12


### **N-05 Unusable ETH Withdrawal Functionality**

The <mark>`TaikoL2`</mark> contract <u>[contains a mechanism](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer2/based/TaikoL2.sol#L247)</u> for a privileged address to withdraw ETH.

However, there is no straightforward mechanism to send ETH to this contract.


Consider documenting the aforementioned fact in the function comments.


**_Update:_** _Resolved in_ _<u>[pull request #18305. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_


_We added a comment in this PR. The TaikoL2 address is also used as L2 base fee_

_recipient, that's why it will receive ETH._

### **N-06 Incomplete Resizing**


The <mark>`transitionId`</mark> indices <u>[have been resized to](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L228)</u> <u><mark>`[uint24](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L228)`</mark></u> <mark>.</mark> However, the <mark>`transitions`</mark>

mapping <u>still uses</u> <u><mark>`[uint32](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L232)`</mark></u> <mark>.</mark>


Consider resizing the <mark>`transitions`</mark> mapping as well.


**_Update:_** _Resolved in_ _<u>[pull request #18305.](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_

### **N-07 Typographical Errors**


Throughout the codebase, multiple instances of typographical errors were identified:


[• In two instances (1](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L178) and <u>[2), "an" should be "will".](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/TaikoData.sol#L182)</u>

   - <u>[This comment](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e//packages/protocol/contracts/layer1/based/LibProposing.sol#L236-L238)</u> misspells "executed", "deterministically", and "referring".

   - <u>[In this comment, "fist" should be "first"](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L599)</u>


To improve code readability, consider correcting any typographical errors in the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #18305.](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_

### **N-08 Naming Suggestions**


Inconsistent naming can lead to confusion in understanding the code.


For consistency with the <u><mark>`[blockParamsV1ToV2](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibData.sol#L15)`</mark></u> <u>function</u> and standard camel-case,

considering capitalizing the word "to" in the <u>[other conversion functions.](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibData.sol#L32-L115)</u>


Consider applying the above renaming suggestion to improve code clarity and readability.


Taiko Ontake Fork Audit − Notes & Additional Information − 13


**_Update:_** _Resolved in_ _<u>[pull request #18305.](https://github.com/taikoxyz/taiko-mono/pull/18305)</u>_

### **N-09 Code Simplifications**


Throughout the codebase, multiple opportunities for code simplification were identified:


   - In the <mark>`_proposeBlock`</mark> function, the <mark>`local.params`</mark> object has <u>[a zero](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibData.sol#L24-L25)</u>

<u><mark>`[anchorBlockId](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibData.sol#L24-L25)`</mark></u> <u>and</u> <u><mark>`[timestamp](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibData.sol#L24-L25)`</mark></u> for pre-fork blocks. This means that the first part of

the condition, the <u><mark>`[postFork](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L181-L187)`</mark></u> <u>fagl</u> <u>, is redundant when setting default values.</u>

   - <u>This</u> <u><mark>`[unchecked](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L231)`</mark></u> <u>block</u> does not wrap any math operations and can be removed.

   - Since <mark>`local.params.timestamp`</mark> is <u>[set to the L1 block timestamp](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L186)</u> before the fork, it

covers <u>[both conditions](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProposing.sol#L295)</u> when setting the block's <mark>`proposedAt`</mark> field.

   - This <u>[conditional statement](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibProving.sol#L647)</u> is unnecessary because the computation returns zero when

<mark>`_amount`</mark> is zero.

   - <u>This</u> <u><mark>`[else](https://github.com/taikoxyz/taiko-mono-oz-audit/blob/fd1c0391045b51b41eba45f2fcdff24fc4d2346e/packages/protocol/contracts/layer1/based/LibVerifying.sol#L102-L114)`</mark></u> <u>block</u> is redundant because the <mark>`if`</mark> case breaks out of the loop.


To improve code maintainability and clarity, consider implementing the aforementioned

simplification suggestions.


**_Update:_** _Resolved in_ _<u>[pull request #18308.](https://github.com/taikoxyz/taiko-mono/pull/18308)</u>_

## **Recommendations**

### **Test Suite Could Be Improved**


Some opportunities for improving the test suite were identified during the audit. In particular,

while the test suite has both positive and negative cases for testing code behavior along with

the restrictions that the codebase imposes, there are no fuzzing scenarios in assets such as

the <mark>`Lib1559Math`</mark> library to validate and find edge cases in the implementation. Nor are there

invariant tests to find possible inconsistencies by randomizing both inputs and execution

paths.


Consider adding fuzzing scenarios in places where data is being calculated/wrapped/encoded/

decoded to validate the limitations and find edge cases. In addition, consider implementing an

invariant suite focused primarily on non-admin functionalities to find complex exploit paths with

randomized data, along with creating a multi-level suite that validates the integration of the

different layers during this fork. Such a test suite should consist of contract-level tests with


Taiko Ontake Fork Audit − Recommendations − 14


95%-100% coverage, per chain / layer deployment and integration tests that test the

deployment scripts as well as the system as a whole, along with per chain / layer fork tests for

planned upgrades. Crucially, the test suite should be documented in such a way that a

reviewer can set up and run all these test layers independently of the development team.


**_Update:_** _The Taiko team added some additional test in the_ _<u>[pull request #18338](https://github.com/taikoxyz/taiko-mono/pull/18338)</u>_ _and_ _<u>[pull request](https://github.com/taikoxyz/taiko-mono/pull/18475)</u>_

_<u>[#18475. In addition, the Taiko team noted that additional tests will be added later.](https://github.com/taikoxyz/taiko-mono/pull/18475)</u>_


Taiko Ontake Fork Audit − Recommendations − 15


## **Conclusion**

The audited codebase contains changes made to the Taiko rollup protocol, aiming at adding

support for a new mechanism called preconfirmations. Overall, we found the codebase to be

well-written. However, it was relatively complex due to the fork event and there still being two

different ways of handling the flow of the blocks. Docstrings are mostly present in the

codebase, but we recommend having additional external documentation about any design

considerations being taken for the dynamic of the preconfers, the registry, and fork events,

along with any implications for the codebase. We would also recommend adding more tests to

ensure a smooth transition over the fork. Throughout our audit, the Taiko team was responsive

and receptive to feedback, providing up-to-date information and specifications of other

modules that could contribute to the audit context.


Taiko Ontake Fork Audit − Conclusion − 16


