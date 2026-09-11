# **Solady**

### Tokens & Utils Selection

##### by Ackee Blockchain _`30.05.2023`_


## **Contents**

1. Document Revisions. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4


2. Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


2.1. Ackee Blockchain . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


2.2. Audit Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5


2.3. Finding classification. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7


2.4. Review team. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9


2.5. Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9


3. Executive Summary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10


Revision 1.0 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10


Revision 1.1. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 11


4. Summary of Findings . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 12


5. Report revision 1.0 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14


5.1. System Overview . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 14


5.2. Trust Model. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15


H1: ERC-1155 `_setApprovalForAll` emits incorrect owner . . . . . . . . . . . . . . . . . . 17


M1: ERC-1155 safe transfer re-entrancy . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 20


W1: ERC-1155 safe transfer hooks order inconsistency. . . . . . . . . . . . . . . . . . . 23


W2: EIP-712 parameters cannot be set. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 25


W3: ERC-20 mint to zero address. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 27


W4: Execution order of Yul arguments relied on . . . . . . . . . . . . . . . . . . . . . . . . . 28


I1: MerkleProofLib duplicated code . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 31


I2: Token revert checks order inconsistency . . . . . . . . . . . . . . . . . . . . . . . . . . . . 33


I3: Token approvals to self allowed . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 35


I4: Misleading comments referring to `delegatecall` . . . . . . . . . . . . . . . . . . . . . . 37


I5: Increase balance comment in burn function . . . . . . . . . . . . . . . . . . . . . . . . . 39


6. Report revision 1.1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 40


2 of 47


6.1. System Overview. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 40


Appendix A: How to cite . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 41


Appendix B: Glossary of terms . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 42


Appendix C: Woke outputs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 43


C.1. H1 proof of concept . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 43


C.2. <u>M1</u> proof of concept . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 43


3 of 47


## **1. Document Revisions**

<u>0.1</u> Draft report 30.05.2023


<u>1.0</u> Final report 30.05.2023


<u>1.1</u> Fix review 02.06.2023



4 of 47


## **2. Overview**

This document presents our findings in reviewed contracts.

#### **2.1. Ackee Blockchain**


<u>[Ackee Blockchain](https://github.com/ackee-blockchain)</u> is an auditing company based in Prague, Czech Republic,

specializing in audits and security assessments. Our mission is to build a

stronger blockchain community by sharing knowledge – we run free

[certification courses School of Solana, Summer School of Solidity](https://ackeeblockchain.com/school-of-solana) and teach

at the Czech Technical University in Prague. Ackee Blockchain is backed by

the largest VC fund focused on blockchain and DeFi in Europe, <u>[RockawayX.](https://rockawayx.com/)</u>


**RockawayX**


RockawayX is a digital asset venture capital firm supporting founders of

web3 companies since early stages. In addition to investing, RockawayX

provides liquidity to Defi protocols, runs blockchain infrastructure of nodes

[and RPCs, develops dashboards (observatory.zone) and tools for foundations](https://observatory.zone)

[to better decentralize their blockchains (stakebar.io, smartdelegation.app),](https://stakebar.io)

[funds smart contract audits (ackeeblockchain.com) and research in](https://ackeeblockchain.com)

[accelerating generation of zero knowledge proofs (maya-zk.com), and](https://maya-zk.com)

[organizes hackathons and conferences (gateway.events).](https://gateway.events)

#### **2.2. Audit Methodology**


1. **Technical specification/documentation** - a brief overview of the system is

requested from the client and the scope of the audit is defined.


2. **Tool-based analysis** - deep check with automated Solidity analysis tools

and <u>[Woke](https://github.com/Ackee-Blockchain/woke)</u> is performed.


3. **Manual code review** - the code is checked line by line for common

vulnerabilities, code duplication, best practices and the code architecture


5 of 47


is reviewed.


4. **Local deployment + hacking** - the contracts are deployed locally and we

try to attack the system and break it.


5. **Unit and fuzz testing** - run unit tests to ensure that the system works as

expected, potentially write missing unit or fuzz tests.


6 of 47


#### **2.3. Finding classification**

A _`Severity`_ rating of each finding is determined as a synthesis of two sub
ratings: _`Impact`_ and _`Likelihood`_ . It ranges from _`Informational`_ to _`Critical`_ .


If we have found a scenario in which an issue is exploitable, it will be assigned

an impact rating of _`High`_, _`Medium`_, or _`Low`_, based on the direness of the

consequences it has on the system. If we haven’t found a way, or the issue is

only exploitable given a change in configuration (such as deployment scripts,

compiler configuration, use of multi-signature wallets for owners, etc.) or

given a change in the codebase, then it will be assigned an impact rating of

_`Warning`_ or _`Info`_ .


_`Low`_ to _`High`_ impact issues also have a _`Likelihood`_, which measures the

probability of exploitability during runtime.


The full definitions are as follows:


**Severity**

```
                      Likelihood

```

**High** **Medium** **Low** **-**


**High** Critical High Medium       

**Medium** High Medium Medium      

```
Impact

```


**Low** Medium Medium Low 

**Warning** - - - Warning


**Info** - - - Info

```
     Table 1. Severity of findings

```

7 of 47


**Impact**


 - **High**  - Code that activates the issue will lead to undefined or catastrophic

consequences for the system.


 - **Medium**  - Code that activates the issue will result in consequences of

serious substance.


 - **Low**  - Code that activates the issue will have outcomes on the system that

are either recoverable or don’t jeopardize its regular functioning.


 - **Warning**  - The issue cannot be exploited given the current code and/or

configuration (such as deployment scripts, compiler configuration, use of

multi-signature wallets for owners, etc.), but could be a security

vulnerability if these were to change slightly. If we haven’t found a way to

exploit the issue given the time constraints, it might be marked as a

"Warning" or higher, based on our best estimate of whether it is currently

exploitable.


 - **Info**  - The issue is on the borderline between code quality and security.

Examples include insufficient logging for critical operations. Another

example is that the issue would be security-related if code or

configuration (see above) was to change.


**Likelihood**


 - **High**  - The issue is exploitable by virtually anyone under virtually any

circumstance.


 - **Medium**  - Exploiting the issue currently requires non-trivial preconditions.


 - **Low**  - Exploiting the issue requires strict preconditions.


8 of 47


#### **2.4. Review team**

**Member’s Name** **Position**


Michal Převrátil Lead Auditor


Lukáš Böhm Auditor


Jan Kalivoda Auditor


Josef Gattermayer, Ph.D. Audit Supervisor

#### **2.5. Disclaimer**


We’ve put our best effort to find all vulnerabilities in the system, however our

findings shouldn’t be considered as a complete list of all existing issues. The

statements made in this document should not be interpreted as investment

or legal advice, nor should its authors be held accountable for decisions made

based on them.


9 of 47


## **3. Executive Summary**

Solady is a library of gas-optimized Solidity code snippets. It is a collection of

contracts that can be used as building blocks for other contracts. The library

is intended to be used by developers who want to build their own contracts

and want to save gas by using already optimized code.

#### **Revision 1.0**


RockawayX engaged Ackee Blockchain to perform a security review of the

Solady protocol with a total time donation of 15 engineering days in a period

between May 15 and May 29, 2023 and the lead auditor was Michal Převrátil.


The audit has been performed on the commit <u>[e158762](https://github.com/Vectorized/solady/commit/e158762ba98db40a06411db7f80a54b93e951818)</u> and the scope was the

following:


 - tokens/ERC20.sol


 - tokens/ERC721.sol


 - tokens/ERC1155.sol


 - utils/SafeTransferLib.sol


 - utils/ERC1967Factory.sol


 - utils/SignatureCheckerLib.sol


 - utils/MerkleProofLib.sol


 - utils/EIP712.sol


We began our review by interacting with contracts using <u>[Woke](https://github.com/Ackee-Blockchain/woke)</u> testing

framework. We then prepared differential fuzzing tests in Python and started

fuzzing the contracts. In parallel, we performed a manual review of the

codebase. During the review, we paid special attention to:


10 of 47


 - ensuring upper bits of variables shorter than 256 bits are cleared when

necessary,


 - looking for any memory constraint violations, especially interactions with

the free memory pointer,


 - ensuring tokens and utility libraries are implemented with respect to

corresponding EIPs,


 - looking for common issues specific to inline assembly.


Our review resulted in 11 findings, ranging from Info to High severity. The most

severe one results in incorrect ownership data emitted in an event which can

lead to off-chain applications malfunction (see <u>H1).</u>


Ackee Blockchain recommends Solady:


 - pay special attention when copying existing code blocks from one file to

another to avoid introducing bugs,


 - reconsider if internal transfer and approval functions are necessary in

ERC721 and ERC1155 contracts as they may lead to misleading or incorrect

data being emitted as in <u>H1,</u>


 - fix the <u>M1</u> re-entrancy issue,


 - deeply look into reported warnings and informational findings.


See Revision 1.0 for the system overview of the codebase.

#### **Revision 1.1**


RockawayX engaged Ackee Blockchain to perform a fix review on the commit

<u>[37a79ce.](https://github.com/Vectorized/solady/commit/37a79cebb0f12472cc339a726d6f385ec534d056)</u>


The status of all reported issues was updated and can be found in the

findings table. Issues include client responses.


11 of 47


## **4. Summary of Findings**

The following table summarizes the findings we identified during our review.

Unless overridden for purposes of readability, each finding contains:


 - a _`Description`_,


 - an _`Exploit scenario`_,


 - a _`Recommendation`_ and if applicable


 - a _`Fix`_ .


There might often be multiple ways to solve or alleviate the issue, with

varying requirements regarding the necessary changes to the codebase. In

that case, we will try to enumerate them all, clarifying which solves the

underlying issue better (albeit possibly only with architectural changes) than

others.


**Severity** **Reported** **Status**



<u>H1: ERC-1155</u>

<u>`_setApprovalForAll`</u> <u>emits</u>

<u>incorrect owner</u>


<u>M1: ERC-1155 safe transfer</u>

<u>re-entrancy</u>


<u>W1: ERC-1155 safe transfer</u>

<u>hooks order inconsistency</u>


<u>W2: EIP-712 parameters</u>

<u>cannot be set</u>


<u>W3: ERC-20 mint to zero</u>

<u>address</u>



High <u>1.0</u> Fixed


Medium <u>1.0</u> Fixed


Warning <u>1.0</u> Fixed


Warning <u>1.0</u> Acknowledged


Warning <u>1.0</u> Acknowledged


12 of 47


<u>W4: Execution order of Yul</u>

<u>arguments relied on</u>


<u>I1: MerkleProofLib duplicated</u>

<u>code</u>


<u>I2: Token revert checks</u>

<u>order inconsistency</u>


<u>I3: Token approvals to self</u>

<u>allowed</u>


<u>I4: Misleading comments</u>

<u>referring to</u> <u>`delegatecall`</u>


<u>I5: Increase balance</u>

<u>comment in burn function</u>



**Severity** **Reported** **Status**


Warning <u>1.0</u> Acknowledged


Info <u>1.0</u> Acknowledged


Info <u>1.0</u> Fixed


Info <u>1.0</u> Acknowledged


Info <u>1.0</u> Fixed


Info <u>1.0</u> Fixed


```
Table 2. Table of Findings

```


13 of 47


## **5. Report revision 1.0**

#### **5.1. System Overview**

This section contains an outline of the audited contracts. Note that this is

meant for understandability purposes and does not replace project

documentation.


**Contracts**


Contracts we find important for better understanding are described in the

following section.


**ERC20**


The ERC20 abstract contract is a base contract for <u>[ERC-20](https://eips.ethereum.org/EIPS/eip-20)</u> token contracts

[implementing ERC-2612](https://eips.ethereum.org/EIPS/eip-2612) permit approvals.


**ERC721**


The ERC721 abstract contract is a base implementation of <u>[ERC-721](https://eips.ethereum.org/EIPS/eip-721)</u> token

contracts.


**ERC1155**


The ERC1155 abstract contract is a base implementation of <u>[ERC-1155](https://eips.ethereum.org/EIPS/eip-1155)</u> token

contracts.


**SafeTransferLib**


The SafeTransferLib is a library for safe ETH and <u>[ERC-20](https://eips.ethereum.org/EIPS/eip-20)</u> token transfers

gracefully handling missing function return values.


**ERC1967Factory**


The ERC1967Factory contract serves as a factory for deploying and managing


14 of 47


<u>[ERC-1967](https://eips.ethereum.org/EIPS/eip-1967)</u> proxy contracts.


**SignatureCheckerLib**


The SafeTransferLib library performs ECDSA and <u>[ERC-1271](https://eips.ethereum.org/EIPS/eip-1271)</u> signature

correctness checks.


**MerkleProofLib**


The MerkleProofLib library implements functions for verifying if a given leaf or

a set of leaves belongs to a Merkle tree, given its root hash and a Merkle

proof.


**EIP712**


The EIP712 abstract contract provides helper functions for building the <u>[EIP-](https://eips.ethereum.org/EIPS/eip-712)</u>

<u>[712](https://eips.ethereum.org/EIPS/eip-712)</u> domain separator and preparing the data for signing and verifying

signatures.


**Actors**


This part describes actors of the system, their roles, and permissions.


**Owner**


Depending on the final implementation of token contracts (ERC20, ERC721,

ERC1155) inheriting from abstract contracts provided in Solady, the token

contract owner can modify balances, including transferring tokens, minting,

and burning tokens. The token contract owner can also modify approvals and

allowances.

#### **5.2. Trust Model**


Users of tokens (ERC20, ERC721, ERC1155) have to trust the token contract

and its final implementation as the provided contracts are abstract, and the

logic may be changed due to inheritance. Token users must trust the


15 of 47


addresses they give approvals to and set allowances for.



16 of 47


#### **H1: ERC-1155 _setApprovalForAll emits incorrect** **owner**

```
High severity issue

```

Impact: High Likelihood: Medium


Target: tokens/ERC1155.sol Type: Logic error

```
Listing 1. Excerpt from ERC1155._setApprovalForAll

```

728 function _setApprovalForAll(address by, address operator, bool
isApproved) internal virtual {
729 /// @solidity memory-safe-assembly
730 assembly {
731 // Convert to 0 or 1.
732 isApproved := iszero(iszero(isApproved))
733 // Update the `isApproved` for (`by`, `operator`).
734 mstore(0x20, _ERC1155_MASTER_SLOT_SEED)
735 mstore(0x14, by)
736 mstore(0x00, operator)
737 sstore(keccak256(0x0c, 0x34), isApproved)
738 // Emit the {ApprovalForAll} event.
739 mstore(0x00, isApproved)
740 // forgefmt: disable-next-line
741 log3(0x00, 0x20, _APPROVAL_FOR_ALL_EVENT_SIGNATURE,
caller(), shr(96, shl(96, operator)))
742 }
743 }


Signature of the `ApprovalForAll` event:


event ApprovalForAll(address indexed _owner, address indexed _operator,
bool _approved);


**Description**


The contract `ERC1155` implements two variants of a `setApprovalForAll`


17 of 47


function. The first variant checks access controls and is public. The second

variant ( `_setApprovalForAll` ) does not check access controls and is internal.

The second variant accepts one additional argument, `by`, which is used to set

approval from any owner to any operator. The function emits the

`ApprovalForAll` event as required by <u>[EIP-1155](https://eips.ethereum.org/EIPS/eip-1155)</u> but uses `caller` ( `msg.sender` in

Solidity) as an address of the account that gives an approval (the owner).


Typically, the second (internal) variant will be used when the owner is not

equal to the function’s caller. This will result in incorrect data emitted in the

`ApprovalForAll` event, which can lead to incorrect behavior of off-chain

services relying on this event.


**Vulnerability scenario**


The contract owner calls the `_setApprovalForAll` function for a pre-defined

set of owners and operators. The function emits the `ApprovalForAll` event

with the owner set to the contract owner instead of the actual token’s

owner.


There is a proof of concept script in <u>[Woke](https://github.com/Ackee-Blockchain/woke)</u> development and testing

framework in Appendix C.


**Recommendation**


Use `shr(96, shl(96, by))` instead of `caller()` in the `log3` instruction emitting

the `ApprovalForAll` event.


**Solution (Revision 1.1)**


Fixed by replacing the original code using `caller()` as an owner of the

approval:

```
Listing 2. Excerpt from ERC1155._setApprovalForAll

```

<u>741</u> <u>log3(0x00,</u> <u>0x20,</u> <u>_APPROVAL_FOR_ALL_EVENT_SIGNATURE,</u>


18 of 47


caller(), shr(96, shl(96, operator)))


with the following code using the `by` argument as an owner of the approval:

```
Listing 3. Excerpt from ERC1155._setApprovalForAll

```

744 let m := shr(96, not(0))
745 log3(0x00, 0x20, _APPROVAL_FOR_ALL_EVENT_SIGNATURE, and(m,
by), and(m, operator))


<u>Go back to Findings Summary</u>


19 of 47


#### **M1: ERC-1155 safe transfer re-entrancy**

```
Medium severity issue

```

Impact: High Likelihood: Low


Target: tokens/ERC1155.sol Type: Re-entrancy

```
Listing 4. Excerpt from ERC1155._safeTransfer

```

827 if (_hasCode(to)) _checkOnERC1155Received(from, to, id, amount,
data);
828 if (_useAfterTokenTransfer()) {
829 _afterTokenTransfer(from, to, _single(id), _single(amount),
data);
830 }

```
Listing 5. Excerpt from ERC1155._safeBatchTransfer

```

943 if (_hasCode(to)) _checkOnERC1155BatchReceived(from, to, ids,
amounts, data);
944 if (_useAfterTokenTransfer()) {
945 _afterTokenTransfer(from, to, ids, amounts, data);
946 }


**Description**


The `_safeTransfer` and `_safeBatchTransfer` functions of the `ERC1155` contract

call post-transfer hooks in the reverse order compared to other transfer

functions implemented in the same contract. In the reversed order, the

external hook, `_checkOnERC1155Received` and `_checkOnERC1155BatchReceived`, is

called before the internal hook, `_afterTokenTransfer` . This allows for a re
entrancy attack with the following preconditions:


 - the contract inheriting from the `ERC1155` abstract contract uses one of the

`_safeTransfer` or `_safeBatchTransfer` functions with an untrusted `to`


20 of 47


address,


 - internal `_afterTokenTransfer` hook is used in the inheritor contract, and it

performs any state change,


 - the inheritor contract does not implement its own re-entrancy protection.


**Vulnerability scenario**


Alice uses the `ERC1155` abstract contract to implement her custom ERC-1155

token. The token has a `mint` function that limits the amount of tokens a single

address can hold. The verification logic is implemented in the `mint` function,

and the information about the amount of tokens held by an address

(together with other metadata) is stored in the `_afterTokenTransfer` hook.


Bob calls the `mint` function through his malicious contract that re-enters the

`mint` function from the `_checkOnERC1155Received` hook. Because the

`_afterTokenTransfer` hook is called after the `_checkOnERC1155Received` external

hook, Bob can bypass the verification logic and mint more tokens than

allowed.


There is a proof of concept script in <u>[Woke](https://github.com/Ackee-Blockchain/woke)</u> development and testing

framework in Appendix C.


**Recommendation**


Call the `_afterTokenTransfer` hook before `_checkOnERC1155Received` and

`_checkOnERC1155BatchReceived`, respectively.


**Solution (Revision 1.1)**


Fixed by calling the `_afterTokenTransfer` hook before `_checkOnERC1155Received`

and `_checkOnERC1155BatchReceived` in the `_safeTransfer` and `_safeBatchTransfer`

functions, respectively.


21 of 47


```
Listing 6. Excerpt from ERC1155._safeTransfer

```

831 if (_useAfterTokenTransfer()) {
832 _afterTokenTransfer(from, to, _single(id), _single(amount),
data);
833 }
834 if (_hasCode(to)) _checkOnERC1155Received(from, to, id, amount,
data);

```
Listing 7. Excerpt from ERC1155._safeBatchTransfer

```

947 if (_useAfterTokenTransfer()) {
948 _afterTokenTransfer(from, to, ids, amounts, data);
949 }
950 if (_hasCode(to)) _checkOnERC1155BatchReceived(from, to, ids,
amounts, data);


<u>Go back to Findings Summary</u>


22 of 47


#### **W1: ERC-1155 safe transfer hooks order** **inconsistency**

Impact: Warning Likelihood: N/A


Target: tokens/ERC1155.sol Type: Code quality

```
Listing 8. Excerpt from ERC1155._safeTransfer

```

827 if (_hasCode(to)) _checkOnERC1155Received(from, to, id, amount,
data);
828 if (_useAfterTokenTransfer()) {
829 _afterTokenTransfer(from, to, _single(id), _single(amount),
data);
830 }

```
Listing 9. Excerpt from ERC1155._safeBatchTransfer

```

943 if (_hasCode(to)) _checkOnERC1155BatchReceived(from, to, ids,
amounts, data);
944 if (_useAfterTokenTransfer()) {
945 _afterTokenTransfer(from, to, ids, amounts, data);
946 }


**Description**


The internal `_afterTokenTransfer` and external `_checkOnERC1155Received` (or

`_checkOnERC1155BatchReceived`, respectively) hooks are called in a different

order across all safe transfer functions in the ERC1155 contract. This

inconsistency can lead to unexpected behavior in an off-chain application in

a scenario where both the internal and external hooks emit an event, and the

off-chain application relies on the order of the events to be consistent.


**Recommendation**


Call the hook functions in the same order in all safe transfer functions in the


23 of 47


ERC1155 contract. It is strongly recommended to call the internal hook before

the external hook to fix the M1 issue.


**Solution (Revision 1.1)**


Fixed together with M1 by calling the `_afterTokenTransfer` hook before

`_checkOnERC1155Received` and `_checkOnERC1155BatchReceived` in all safe transfer

functions.

```
Listing 10. Excerpt from ERC1155._safeTransfer

```

831 if (_useAfterTokenTransfer()) {
832 _afterTokenTransfer(from, to, _single(id), _single(amount),
data);
833 }
834 if (_hasCode(to)) _checkOnERC1155Received(from, to, id, amount,
data);

```
Listing 11. Excerpt from ERC1155._safeBatchTransfer

```

947 if (_useAfterTokenTransfer()) {
948 _afterTokenTransfer(from, to, ids, amounts, data);
949 }
950 if (_hasCode(to)) _checkOnERC1155BatchReceived(from, to, ids,
amounts, data);


24 of 47


#### **W2: EIP-712 parameters cannot be set**

Impact: Warning Likelihood: N/A


Target: utils/EIP712.sol Type: Standards

deviation

```
Listing 12. Excerpt from EIP712._buildDomainSeparator

```

151 function _buildDomainSeparator() private view returns (bytes32
separator) {
152 bytes32 nameHash = _cachedNameHash;
153 bytes32 versionHash = _cachedVersionHash;
154 /// @solidity memory-safe-assembly
155 assembly {
156 let m := mload(0x40) // Load the free memory pointer.
157 mstore(m, _DOMAIN_TYPEHASH)
158 mstore(add(m, 0x20), nameHash)
159 mstore(add(m, 0x40), versionHash)
160 mstore(add(m, 0x60), chainid())
161 mstore(add(m, 0x80), address())
162 separator := keccak256(m, 0xa0)
163 }
164 }


**Description**


The EIP712 abstract contract implements data preparations for <u>[EIP-712](https://eips.ethereum.org/EIPS/eip-712)</u>

signing. However, the implementation has some limitations in contrast to the

EIP:


 - the address of the verifying contract cannot be set, i.e., the current

implementation assumes the verifying contract will be the same as the

contract producing the hash to be signed,


 - `salt`, which is an optional parameter serving as a domain separator of last

resort, cannot be set.


25 of 47


The current implementation does not allow inheriting the EIP712 contract and

overriding necessary functions to make both parameters ( `verifyingContract`

and `salt` ) configurable.


**Recommendation**


Reconsider making both parameters configurable directly in the abstract

contract.


**Solution (Revision 1.1)**


The Solady lead developer acknowledged the issue with the following

comment:


For aesthetics, simplicity and gas-savings, incorporating use of

`salt` into this implementation will be hard.


This is because the `_DOMAIN_TYPEHASH` constant depends on

whether `salt` is being used — due to the limitations of the

Solidity compiler, we cannot find a simple way that allows the

`_DOMAIN_TYPEHASH` to be conditionally evaluated on compile time

depending on the return value of a virtual `_salt` function.


As such, we will leave a comment on the limitations of this

implementation.


26 of 47


#### **W3: ERC-20 mint to zero address**

Impact: Warning Likelihood: N/A


Target: tokens/ERC20.sol Type: Data validation


**Description**


The ERC20 contract allows minting tokens to the zero address. This contrasts

with the OpenZeppelin implementation, where such behavior is not allowed.


**Recommendation**


Consider checking that the recipient of tokens is not the zero address in the

ERC20 `_mint` function.


**Solution (Revision 1.1)**


The Solady lead developer acknowledged the issue and added a note to the

code:

```
Listing 13. Excerpt from ERC20.sol

```

8 /// Note:
9 /// The ERC20 standard allows minting and transferring to and from the
zero address,
10 /// minting and transferring zero tokens, as well as self-approvals.
11 /// For performance, this implementation WILL NOT revert for such
actions.
12 /// Please add any checks with overrides if desired.
13 abstract contract ERC20 {


27 of 47


#### **W4: Execution order of Yul arguments relied on**

Impact: Warning Likelihood: N/A



Target: utils/SignatureCheckerLib.sol,

utils/SafeTransferLib.sol



Type: Undocumented

features

utilization


```
Listing 14. Excerpt from SignatureCheckerLib.isValidSignatureNow

```

88 isValid := and(
89 and(
90 // Whether the returndata is the magic value
`0x1626ba7e` (left-aligned).
91 eq(mload(0x00), f),
92 // Whether the returndata is exactly 0x20 bytes
(1 word) long.
93 eq(returndatasize(), 0x20)
94 ),
95 // Whether the staticcall does not revert.
96 // This must be placed at the end of the `and`
clause,
97 // as the arguments are evaluated from right to
left.
98 staticcall(
99 gas(), // Remaining gas.
100 signer, // The `signer` address.
101 m, // Offset of calldata in memory.
102 add(signatureLength, 0x64), // Length of
calldata in memory.
103 0x00, // Offset of returndata.
104 0x20 // Length of returndata to write.
105 )
106 )

```
Listing 15. Excerpt from SafeTransferLib.safeTransferFrom

```

164 if iszero(
165 and( // The arguments of `and` are evaluated from right
<u>to left.</u>


28 of 47


166 // Set success to whether the call reverted, if not
we check it either
167 // returned exactly 1 (can't just be non-zero
data), or had no return data.
168 or(eq(mload(0x00), 1), iszero(returndatasize())),
169 call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
170 )
171 ) {


**Description**


Solady relies on an undocumented behavior of the `solc` compiler that

arguments of Yul internal functions are evaluated from the last to the first.


In particular, this was observed in the case of Yul `and`, where the second

argument performs an external call and the first argument works with the

external call return data.


**Recommendation**


Consider rewriting the code to avoid relying on the execution order of Yul

arguments, as this behavior is not documented and may change in future

versions of the compiler.


**Solution (Revision 1.1)**


The Solady lead developer acknowledged the issue with the following

comment:


For efficiency, we avoid using temporary variables, as the

compiler is sometimes unable to optimize them away.


We expect any changes in how the arguments to be evaluated

to be a breaking change in solc.


29 of 47


We also test on every supported version of solc in our CI (from

v0.8.4 to the latest v0.8.x).


We have also added a warning to the README <u>[#447](https://github.com/Vectorized/solady/pull/447)</u>


30 of 47


#### **I1: MerkleProofLib duplicated code**

Impact: Info Likelihood: N/A


Target: utils/MerkleProofLib.sol Type: Code quality

```
Listing 16. Excerpt from MerkleProofLib.emptyProof

```

262 function emptyProof() internal pure returns (bytes32[] calldata
proof) {
263 /// @solidity memory-safe-assembly
264 assembly {
265 proof.length := 0
266 }
267 }

```
Listing 17. Excerpt from MerkleProofLib.emptyLeafs

```

270 function emptyLeafs() internal pure returns (bytes32[] calldata
leafs) {
271 /// @solidity memory-safe-assembly
272 assembly {
273 leafs.length := 0
274 }
275 }


**Description**


The MerkleProofLib library implements `emptyProof` and `emptyLeafs` helper

functions, both returning an empty `calldata` array of `bytes32` . The

functionality of both functions is the same, with names of functions and

variables being the only difference.


**Recommendation**


Consider merging the two functions into one with a more generic name, e.g.

`emptyBytes32Array` .


31 of 47


**Solution (Revision 1.1)**


The Solady lead developer acknowledged the issue with the following

comment:


The helper functions to return empty calldata arrays are

duplicated for semantic aesthetics.


They are provided to help avoid compiler warnings regarding

empty calldata arrays.


32 of 47


#### **I2: Token revert checks order inconsistency**

Impact: Info Likelihood: N/A



Target: tokens/ERC721.sol,

tokens/ERC1155.sol



Type: Code quality


```
Listing 18. Excerpt from ERC1155.safeTransferFrom

```

196 if iszero(eq(caller(), from)) {
197 mstore(0x00, caller())
198 if iszero(sload(keccak256(0x0c, 0x34))) {
199 mstore(0x00, 0x4b6e7f18) //
`NotOwnerNorApproved()`.
200 revert(0x1c, 0x04)
201 }
202 }
203 // Revert if `to` is the zero address.
204 if iszero(to) {
205 mstore(0x00, 0xea553b34) // `TransferToZeroAddress()`.
206 revert(0x1c, 0x04)
207 }

```
Listing 19. Excerpt from ERC1155.safeBatchTransferFrom

```

305 if iszero(to) {
306 mstore(0x00, 0xea553b34) // `TransferToZeroAddress()`.
307 revert(0x1c, 0x04)
308 }
309 // If the caller is not `from`, do the authorization check.
310 if iszero(eq(caller(), from)) {
311 mstore(0x00, caller())
312 if iszero(sload(keccak256(0x0c, 0x34))) {
313 mstore(0x00, 0x4b6e7f18) //
`NotOwnerNorApproved()`.
314 revert(0x1c, 0x04)
315 }
316 }


33 of 47


**Description**


Revert checks are performed in a different order across ERC1155 and ERC721

functions. This is an inconsistency.


**Recommendation**


Perform revert checks of the same type in the same order in the whole

project unless this can save a significant amount of gas.


**Solution (Revision 1.1)**


The revert checks order was made consistent across ERC1155 and ERC721

functions.


34 of 47


#### **I3: Token approvals to self allowed**

Impact: Info Likelihood: N/A



Target: tokens/ERC721.sol,

tokens/ERC1155.sol


**Description**



Type: Data validation



The ERC721 and ERC1155 contracts allow calling `approve` and `setApprovalForAll`

with `by` and `account` pointing to the same address, effectively giving approval

to self. This behavior is prohibited in the OpenZeppelin implementation.


**Recommendation**


Consider adding an extra check that the `by` address is different from the

`account` address in ERC721 and ERC1155 approval functions.


**Solution (Revision 1.1)**


The Solady lead developer acknowledged the issue and added notes to the

code:

```
Listing 20. Excerpt from ERC20.sol

```

8 /// Note:
9 /// The ERC20 standard allows minting and transferring to and from the
zero address,
10 /// minting and transferring zero tokens, as well as self-approvals.
11 /// For performance, this implementation WILL NOT revert for such
actions.
12 /// Please add any checks with overrides if desired.
13 abstract contract ERC20 {

```
Listing 21. Excerpt from ERC721.sol

```

8 /// Note:


35 of 47


9 /// The ERC721 standard allows for self-approvals.
10 /// For performance, this implementation WILL NOT revert for such
actions.
11 /// Please add any checks with overrides if desired.
12 abstract contract ERC721 {

```
Listing 22. Excerpt from ERC1155.sol

```

8 /// Note:
9 /// The ERC1155 standard allows for self-approvals.
10 /// For performance, this implementation WILL NOT revert for such
actions.
11 /// Please add any checks with overrides if desired.
12 abstract contract ERC1155 {



36 of 47


#### **I4: Misleading comments referring to**
###### **`delegatecall`**

Impact: Info Likelihood: N/A



Target: tokens/ERC721.sol,

tokens/ERC1155.sol



Type: Code quality


```
Listing 23. Excerpt from ERC721._checkOnERC721Received

```

856 // Revert if the call reverts.
857 if iszero(call(gas(), to, 0, add(m, 0x1c), add(n, 0xa4), m,
0x20)) {
858 if returndatasize() {
859 // Bubble up the revert if the delegatecall
reverts.
860 returndatacopy(0x00, 0x00, returndatasize())
861 revert(0x00, returndatasize())
862 }
863 mstore(m, 0)
864 }

```
Listing 24. Excerpt from ERC1155.safeTransferFrom

```

252 // Revert if the call reverts.
253 if iszero(call(gas(), to, 0, add(m, 0x1c), add(0xc4,
data.length), m, 0x20)) {
254 if returndatasize() {
255 // Bubble up the revert if the delegatecall
reverts.
256 returndatacopy(0x00, 0x00, returndatasize())
257 revert(0x00, returndatasize())
258 }
259 mstore(m, 0)
260 }


**Description**


In the ERC721 and ERC1155 contracts, multiple comments refer to


37 of 47


`delegatecall`, but there is no `delegatecall` instruction and the `call` instruction

is used instead.


**Recommendation**


Correct the comments to refer to the `call` instruction to avoid confusion.


**Solution (Revision 1.1)**


The comments were corrected to refer to the `call` instruction.


38 of 47


#### **I5: Increase balance comment in burn function**

Impact: Info Likelihood: N/A


Target: tokens/ERC1155.sol Type: Code quality

```
Listing 25. Excerpt from ERC1155._batchBurn

```

684 // Increase and store the updated balance of `to`.
685 {
686 mstore(0x00, mload(add(ids, i)))
687 let fromBalanceSlot := keccak256(0x00, 0x40)
688 let fromBalance := sload(fromBalanceSlot)
689 if gt(amount, fromBalance) {
690 mstore(0x00, 0xf4d678b8) //
`InsufficientBalance()`.
691 revert(0x1c, 0x04)
692 }
693 sstore(fromBalanceSlot, sub(fromBalance,
amount))
694 }


**Description**


In the `_batchBurn` function of the ERC1155 contract, there is a comment

describing an increase in balance, but the function decreases the balance.


**Recommendation**


To avoid confusion, replace `Increase` with `Decrease` in the comment.


**Solution (Revision 1.1)**


The comment was corrected.


39 of 47


## **6. Report revision 1.1**

#### **6.1. System Overview**

The most severe issues H1 and M1 were fixed by emitting correct data in the

`_setApprovalForAll` function and by calling ERC1155 hooks in the correct order

making the contract safe against reentrancy.


For info and warning findings that were acknowledged (not fixed), comments

were added to the codebase informing users about the potential issues and

limitations of the library.


40 of 47


## **Appendix A: How to cite**

Please cite this document as:


<u>[Ackee Blockchain, Solady: Tokens & Utils Selection, 30.05.2023.](https://github.com/ackee-blockchain)</u>


41 of 47


## **Appendix B: Glossary of terms**

The following terms might be used throughout the document:


**Superclass/Ancestor of C**


A contract that C inherits/derives from.


**Subclass/Child of C**


A contract that inherits/derives from C.


**Syntactic contract**


A Solidity contract. May have an inheritance chain, and may be deployed.


**Deployed contract**


An EVM account with non-zero code. If its source was written in Solidity, it

was created through at least one syntactic contract. If that contract had

superclasses (parents), it would be composed of multiple syntactic

contracts.


**Init/initialization function**


A non-constructor function that serves as an initializer. Often used in

upgradeable contracts.


**External entrypoint**


A `public` or `external` function.


**Public/Publicly-accessible function/entrypoint**


An `external` or `public` function that can be successfully executed by any

network account.


**Mutating function**


A non- `view` and non- `pure` function.


42 of 47


## **Appendix C: Woke outputs**

A part of the audit delivery is a test suite with unit and fuzz tests in <u>[Woke](https://github.com/Ackee-Blockchain/woke)</u>

development and testing framework. The following section shows proof of

concept code for the most severe issues H1 and M1.

#### **C.1. H1 proof of concept**


contract ERC1155Mock is ERC1155 {
function setApprovalForAllUnchecked(address by, address operator, bool
approved) external {
_setApprovalForAll(by, operator, approved);
}
}


@default_chain.connect()
def test_erc1155_events():
a = default_chain.accounts[0]
b = default_chain.accounts[1]
c = default_chain.accounts[2]
erc1155 = ERC1155Mock.deploy(True, from_=a)


tx = erc1155.setApprovalForAllUnchecked(a, b, True, from_=c)
assert tx.events == [ERC1155Mock.ApprovalForAll(a.address, b.address,
True)]
tx = erc1155.setApprovalForAllUnchecked(a, b, False, from_=c)
assert tx.events == [ERC1155Mock.ApprovalForAll(a.address, b.address,
False)]

#### **C.2. M1 proof of concept**


The victim contract:


contract ERC1155Mock is ERC1155 {
event BeforeTokenTransfer(address from, address to, uint256[] ids,
<u>uint256[]</u> <u>amounts,</u> <u>bytes</u> <u>data);</u>


43 of 47


event AfterTokenTransfer(address from, address to, uint256[] ids,
uint256[] amounts, bytes data);


bool immutable private _enableHooks;


constructor(bool enableHooks_) {
_enableHooks = enableHooks_;
}


function _useBeforeTokenTransfer() internal view override returns (
bool) {
return _enableHooks;
}


function _useAfterTokenTransfer() internal view override returns (bool)
{
return _enableHooks;
}


function _afterTokenTransfer(
address from,
address to,
uint256[] memory ids,
uint256[] memory amounts,
bytes memory data
) internal override {
emit AfterTokenTransfer(from, to, ids, amounts, data);
}


...
}


The attacker contract:


contract ERC1155ReentrancyAttacker {
function onERC1155Received(
address,
address,
uint256,
uint256,
<u>bytes</u> <u>calldata</u> <u>data</u>


44 of 47


) external returns(bytes4) {
if (data.length == 0)
ERC1155Mock(msg.sender).mint(address(this), 1024, 1,
hex <mark>"00112233")</mark> ;
return this.onERC1155Received.selector;
}


function onERC1155BatchReceived(
address,
address,
uint256[] calldata,
uint256[] calldata,
bytes calldata data
) external returns(bytes4) {
if (data.length == 0)
ERC1155Mock(msg.sender).mint(address(this), 1024, 1,
hex <mark>"00112233")</mark> ;
return this.onERC1155BatchReceived.selector;
}
}


@default_chain.connect()
def test_erc1155_reentrancy():
a = default_chain.accounts[0]


erc1155 = ERC1155Mock.deploy(True, from_=a)
attacker = ERC1155ReentrancyAttacker.deploy(from_=a)


erc1155.mint(a, 0, 1, <mark>b"",</mark> from_=a)


tx = erc1155.safeTransferUnchecked(Address.ZERO, a, attacker, 0, 1,
<mark>b"",</mark> from_=a)
assert tx.events == [
ERC1155Mock.BeforeTokenTransfer(a.address, attacker.address, [0],

[1], bytearray( <mark>b"")</mark> ),
ERC1155Mock.TransferSingle(a.address, a.address, attacker.address,
0, 1),


# re-entrant call to mint
ERC1155Mock.BeforeTokenTransfer(Address.ZERO, attacker.address,

[1024], [1], bytearray( <mark>b"\x00\x11\x22\x33"</mark> )),


45 of 47


ERC1155Mock.TransferSingle(attacker.address, Address.ZERO,
attacker.address, 1024, 1),
ERC1155Mock.AfterTokenTransfer(Address.ZERO, attacker.address,

[1024], [1], bytearray( <mark>b"\x00\x11\x22\x33"</mark> )),


ERC1155Mock.AfterTokenTransfer(a.address, attacker.address, [0], [
1], bytearray( <mark>b"")</mark> ),
]


46 of 47


# **Thank You**

### Ackee Blockchain a.s.

##### Prague, Czech Republic hello@ackeeblockchain.com h�ps://twi�er.com/AckeeBlockchain


