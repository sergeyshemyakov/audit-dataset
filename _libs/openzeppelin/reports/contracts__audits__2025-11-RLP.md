### | security

# **OIF Broadcaster** **Audit**

#### **November 26, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  6

ERC-7888 Implementation 6

RLP Library Implementation 6

BroadcasterOracle for the OIF Protocol 7


Security Model and Trust Assumptions _______________________________________________  7

ERC-7888 7

RLP Library 8

BroadcasterOracle and Route Constraints 8

Privileged Roles 8


High Severity ____________________________________________________________________ 10

H-01 Prover Copies Cannot Be Updated 10


Medium Severity _________________________________________________________________ 10

M-01 Potential for Arbitrary Application in Message Verification 10


Low Severity ____________________________________________________________________ 11

L-01 Missing Version Validation 11

L-02 Lack of Validation for Payload Length 11

L-03 RLP Address Encoding Allows Leading Zero Bytes 11

L-04 RLP Address Decoding Allows Only Fixed Address Lengths 12

L-05 Stuck Oracle Verifications for Migrated Chains 13


Notes & Additional Information ____________________________________________________ 14

N-01 Gas Optimization 14

N-02 Incomplete Docstrings 14

N-03 Floating Pragma 15

N-04 Missing Docstrings 15

N-05 Use Custom Errors 16

N-06 Inconsistent Use of Returns in Functions 16

N-07 Ambiguous Documentation Of bytes[] Encoding 16

N-08 Unreachable Checks 17

N-09 Misleading Documentation 17

N-10 Non-Canonical Long-string Decoding Acceptance 18

N-11 Inconsistent Integer Base in Inline Assembly When Setting RLP Prefixes 18


OIF Broadcaster Audit − Table of Contents − 2


Conclusion ______________________________________________________________________ 19


OIF Broadcaster Audit − Table of Contents − 3


## **Summary**

**Type** Library


**Timeline** From 2025-10-27
To 2025-10-31


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


1 (1 resolved)


1 (0 resolved)



**Total Issues** 18 (12 resolved, 1 partially resolved)



**Low Severity Issues** 5 (2 resolved)



**Notes & Additional**
**Information**



11 (9 resolved, 1 partially resolved)



OIF Broadcaster Audit − Summary − 4


## **Scope**

OpenZeppelin audited 3 different scopes.


[The first one was the openintentsframework/broadcaster](https://github.com/openintentsframework/broadcaster) repository at commit <u>[3522b4c.](https://github.com/openintentsframework/broadcaster/commit/3522b4c7c958ce254497b879cc1f6106131c7e3e)</u>


In scope were the following files:

```
contracts
├── interfaces
│  ├── IBlockHashProver.sol
│  ├── IBlockHashProverPointer.sol
│  ├── IBroadcaster.sol
│  └── IReceiver.sol
├── libraries
│  └── ProverUtils.sol
├── BlockHashProverPointer.sol
├── Broadcaster.sol
└── Receiver.sol

```

[The second one was the OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) repository at commit <u>[d9f966f.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/d9f966fc3f7c4eec7f565c2442cc64481e7fb499)</u>


In scope were the following files:

```
contracts
└── utils
└── RLP.sol

```

The third one was the <u>[openintentsframework/oif-contracts](https://github.com/openintentsframework/oif-contracts)</u> repository at commit <u>[acc7f9c.](https://github.com/openintentsframework/oif-contracts/tree/acc7f9ca32ccd9e133f00c644251d7ff976edb24)</u>


In scope were the following files:

```
src
└── integrations
└── oracles
└── broadcaster
└── BroadcasterOracle.sol

```

OIF Broadcaster Audit − Scope − 5


## **System Overview**

The present audit encompasses three distinct scopes focusing on foundational components

for cross-chain interoperability and data validation within the Open Intents Framework (OIF)

ecosystem. Together, these scopes aim to provide reliable message verification, standardized

data encoding, and secure broadcasting mechanisms across heterogeneous blockchain

environments.

### **ERC-7888 Implementation**


The first scope centers on the ERC-7888 standard, which defines a generalized framework for

cross-chain message verification. This implementation introduces three core contracts

<mark>`Broadcaster`</mark> <mark>,</mark> <mark>`Receiver`</mark> <mark>,</mark> and <mark>`BlockHashProverPointer`</mark> alongside a supporting

library, <mark>`ProverUtils`</mark> <mark>.</mark>


<mark>`Broadcaster`</mark> contracts are responsible for emitting verifiable messages on the source chain,

anchoring communication between related blockchain networks. On the other hand,

<mark>`Receiver`</mark> contracts facilitate message ingestion on the destination chain, ensuring that only

verified and finalized data originating from trusted sources are processed.


<mark>`BlockHashProverPointer`</mark> provides a flexible referencing mechanism that links to specific

<mark>`BlockHashProver`</mark> implementations. These provers serve as the cryptographic bridge

between chains by verifying account data and storage slots within state roots and storage

Merkle Patricia tries.


By modularizing verification logic, ERC-7888 enables adaptable cross-chain communication

that can evolve alongside chain upgrades or alternative verification mechanisms while

maintaining strong guarantees of authenticity and consistency.

### **RLP Library Implementation**


The second scope involves the development of a dedicated RLP (Recursive Length Prefix)

library to handle data serialization and deserialization in accordance with Ethereum’s canonical

encoding format. The library provides efficient methods for encoding structured data into RLP

format and decoding RLP-encoded payloads back into their constituent elements. Correct RLP


OIF Broadcaster Audit − System Overview − 6


implementation is critical for interoperability, as it ensures deterministic data interpretation

across systems and contracts relying on Ethereum-compatible encoding.

### **BroadcasterOracle for the OIF Protocol**


The third scope focuses on the implementation of a <mark>`BroadcasterOracle`</mark> contract,

designed for the Open Intents Framework (OIF), a modular, intent-based cross-chain protocol.

The OIF enables users to define and execute complex cross-chain intents, supporting

customizable asset delivery and validation conditions that can be fulfilled permissionlessly by

open solvers.


Operating as a component of OIF’s smart contract layer, the <mark>`BroadcasterOracle`</mark> contract

establishes reliable communication between broadcasted messages and on-chain verifiers. It

aligns with OIF’s output-input separation model, allowing independent asset collection and

delivery flows, such as Output First and Input Second, via resource locks or escrow

mechanisms. Through this architecture, <mark>`BroadcasterOracle`</mark> contributes to a

permissionless, extensible settlement infrastructure capable of supporting hybrid and cross
chain financial workflows.

## **Security Model and Trust** **Assumptions**


Each scope introduces unique trust assumptions and operational constraints that collectively

define the system’s security model.

### **ERC-7888**









**Pointer Ownership and Upgrades** : The <mark>`BlockHashProverPointer`</mark> contract relies on

its owner to correctly update references to valid <mark>`BlockHashProver`</mark> implementations.

A malicious or negligent owner could either DoS the system or facilitate forged

messages by redirecting the pointer to a fraudulent prover.


**Chain Consistency** : When updating to a new <mark>`BlockHashProver`</mark> <mark>,</mark> the home and target

chain must remain identical to the previous configuration. This is a property that cannot

be programmatically verified.


OIF Broadcaster Audit − Security Model and Trust Assumptions − 7


**Chain Upgrades** : Protocol security depends on stable chain storage structures. If a

chain upgrade modifies where block hashes are stored (e.g., repurposing mappings on a

parent chain), older <mark>`BlockHashProvers`</mark> might yield invalid or stale block hashes,

potentially allowing receivers to ingest forged data.


**Message Guarantees** : The ERC ensures that messages can be read (given finalization),

but not that they will be read. Since finalization occurs sequentially across chains,

message availability depends on cumulative finalization time along the route.


### **RLP Library**

The main risk associated with the RLP library concerns boolean decoding semantics.

Decoding a boolean as an integer introduces a potential mismatch with single-byte encoding

expectations. This can lead to inconsistent interpretations in downstream logic where a

boolean value’s binary length carries semantic importance.

### **BroadcasterOracle and Route Constraints**









In the <mark>`BroadcasterOracle`</mark> implementation, the owner holds the ability to set the

broadcaster ID across destination chains. Once a route is constrained, it cannot be

updated. Consequently, if a chain later changes its settlement layer and requires a

different route to reach the broadcaster, the route becomes irreversibly bricked,

preventing further message propagation and effectively locking communication for that

chain.


Applications built on top are assumed to implement the corresponding checks to prevent

double spending, multiple cross-chain verification, etc.


### **Privileged Roles**

Throughout the system, the following privileged roles have been identified:







**<mark>`BlockHashProverPointer`</mark>** **Owner** : Maintains administrative control over prover

references. Responsible for ensuring that updates to the pointer reference valid and

compatible <mark>`BlockHashProver`</mark> implementations. Failure to manage this correctly can

result in message forgery or DoS conditions.


OIF Broadcaster Audit − Security Model and Trust Assumptions − 8


**<mark>`BroadcasterOracle`</mark>** **Owner** : Holds the authority to configure broadcaster IDs and

define message routes across destination chains. This role must be exercised with

caution, as constrained routes are immutable, and improper configuration can

permanently disrupt inter-chain connectivity.


**Receiver Callers** : Although not privileged in the administrative sense, <mark>`Receiver`</mark> callers

bear the responsibility of selectively reading valid messages, as ERC-7888 does not

enforce message liveness or delivery guarantees.



Together, these roles and assumptions define the operational security model for the audited

components, emphasizing cautious upgrade practices, responsible ownership, and alignment

between protocol-level guarantees and system-level integrity.


OIF Broadcaster Audit − Security Model and Trust Assumptions − 9


## **High Severity**

### **H-01 Prover Copies Cannot Be Updated**

The <u><mark>`[updateBlockHashProverCopy](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/Receiver.sol#L43-L66)`</mark></u> function allows for updating the address of a copy of a

remote chain prover to a new version within the local chain. Before updating the

implementation, this function ensures that the version of the prover at the new address is

greater than the version of the prover at the old address.


However, an issue arises because the <mark>`_blockHashProverCopies`</mark> mapping is initialized to

the zero address. As a result, any attempt to update a prover copy reverts when calling the

<mark>`version`</mark> getter on the zero address, causing the update to be blocked. This limitation

prevents the receiver contract from correctly verifying messages from chains that involve

multiple routes.


Consider performing the version check only when an implementation address for a copy has

been set.


**_Update:_** _[Resolved at pull request #29](https://github.com/openintentsframework/broadcaster/pull/29)_ _[at commit b66e918.](https://github.com/openintentsframework/broadcaster/pull/29/commits/b66e918e3c6f451553293d3edb9dd58a9b5a7073#diff-776091b07a33e3f8c1ce0a26a43ef84f670f2babb7f5c1fa6e9ec728b32fcf85)_

## **Medium Severity**

### **M-01 Potential for Arbitrary Application in** **Message Verification**


When a proof of filled payloads is submitted, the <u><mark>`[source](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L108)`</mark></u> refers to the address of the

application that has attested to the data. However, the broadcast message <u>[lacks any](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L144-L152)</u>

<u>[information about the application. Consequently, when a user verifies the message on another](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L144-L152)</u>

[chain, they may provide an arbitrary application within](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L82-L83) <u><mark>`[messageData](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L82-L83)`</mark></u> <mark>.</mark> Since the message

[does not contain any information to identify the application, this arbitrary value is used directly](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L96)

<u>in the</u> <u><mark>`[_attestations](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L96)`</mark></u> <u>[mapping without validation.](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L96)</u>


Consider adding the <mark>`application`</mark> information into the message hash so that it can be

validated during message verification.


OIF Broadcaster Audit − High Severity − 10


**_Update:_** _Acknowledged, will resolve. Drafted fix in_ _<u>[pull request #160](https://github.com/openintentsframework/oif-contracts/pull/160)</u>_ _[at commit 1872a01.](https://github.com/openintentsframework/oif-contracts/pull/160/commits/1872a01dbc501696734d176319bf483a2eeb4942)_

## **Low Severity**

### **L-01 Missing Version Validation**


When <mark>`BlockHashProverPointer`</mark> sets the implementation address for the first time, <u>[it does](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/BlockHashProverPointer.sol#L34-L35)</u>

<u>[not perform any validation at all. However, all subsequent implementation changes validate](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/BlockHashProverPointer.sol#L34-L35)</u>

<u>that the new</u> <u><mark>`[version](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/BlockHashProverPointer.sol#L28-L33)`</mark></u> <u>[keeps increasing compared to the old one. If the initial implementation](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/BlockHashProverPointer.sol#L28-L33)</u>

does not support the <mark>`version`</mark> function, the pointer will not be able to set a new address

again. This is because the check for the increasing version will fail when it attempts to call the

<mark>`version`</mark> method on the old implementation.


Consider checking that the initial implementation supports the <mark>`version`</mark> method.


**_Update:_** _[Resolved at pull request #38](https://github.com/openintentsframework/broadcaster/pull/38)_ _[at commit 807810f.](https://github.com/openintentsframework/broadcaster/pull/38/commits/807810f6b8a2bdfc380f9c0d0ee0fdbcc6b858b8)_

### **L-02 Lack of Validation for Payload Length**


Currently, there is <u>[no limit on the number of payloads](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L107-L116)</u> that can be submitted to

<mark>`BroadcasterOracle`</mark> <mark>.</mark> However, during the message verification process, the system

<u>[extracts the length of the array of payloads](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L82-L83)</u> [using only 2 bytes of data. As a result, if the](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/libs/MessageEncodingLib.sol#L61)

number of payloads submitted to the oracle exceeds the limit that can be represented by 2

bytes, the message will not be verifiable on the destination chain.


Consider limiting the amount of payloads allowed on the <mark>`submit`</mark> function.


**_Update:_** _[Resolved at pull request #159](https://github.com/openintentsframework/oif-contracts/pull/159)_ _[at commit fb9575a.](https://github.com/openintentsframework/oif-contracts/pull/159/commits/fb9575a12838116642c4ade6cfe5fbee12f068b9)_

### **L-03 RLP Address Encoding Allows Leading Zero** **Bytes**


The <mark>`RLP`</mark> library currently <u>[encodes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d9f966fc3f7c4eec7f565c2442cc64481e7fb499/contracts/utils/RLP.sol#L123-L130)</u> an <mark>`address`</mark> as a 20-byte array. This representation can

contain leading zero bytes.


This is not necessarily a problem in itself. However, the <u>[Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)</u> states the

following:


OIF Broadcaster Audit − Low Severity − 11


When interpreting RLP data, if an expected fragment is decoded as a scalar and

leading zeroes are found in the byte sequence, clients are required to consider it non
canonical and treat it in the same manner as otherwise invalid RLP data, dismissing it

completely.


This ambiguity could cause implementations that treat the <mark>`address`</mark> as a scalar value to fail

when decoding RLP data containing an <mark>`address`</mark> with a leading zero.


To obtain better compatibility and alignment with the specification, consider treating the

<mark>`address`</mark> as a scalar value and encoding it using its <mark>`uint256`</mark> representation. In this case,

any leading zeroes will not be included in the encoded byte array.


**_Update:_** _Acknowledged, not resolved. The team stated:_


After some reviewing, the conclusion is that encoding without the leading zeros would

not be consistent with the current ethereum ecosystem. If someone wants to encode an

Address without the leading zeros, they can manually do the casting to uint256 and

then call the corresponding encode function. However this should not be the default

encoding.

### **L-04 RLP Address Decoding Allows Only Fixed** **Address Lengths**


The <mark>`RLP`</mark> library's <mark>`address`</mark> decoding function currently only allows encoded addresses with

lengths of 1 byte (for <mark>`address(0)`</mark> to <mark>`address(127)`</mark> <mark>)</mark> or 21 bytes (a <mark>`0x94`</mark> prefix followed

by 20 bytes of the <mark>`address`</mark> <mark>)</mark> .


This is not necessarily a problem in itself. However, this strict check means the implementation

does not treat the <mark>`address`</mark> as a scalar. The <u>[Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)</u> states:


When interpreting RLP data, if an expected fragment is decoded as a scalar and

leading zeroes are found in the byte sequence, clients are required to consider it non
canonical and treat it in the same manner as otherwise invalid RLP data, dismissing it

completely.


This ambiguity could cause the decoder to fail when processing addresses encoded as scalar

values by other implementations, which might omit leading zeros and thus have different

lengths.


To obtain better compatibility and alignment with the specification, consider treating the

<mark>`address`</mark> as a scalar value and decoding it using its <mark>`uint256`</mark> representation. In this case,


OIF Broadcaster Audit − Low Severity − 12


the implementation will support the decoding of addresses expressed as scalars with an

arbitrary length, and the length check could be simplified to <mark>`length <= 21`</mark> <mark>.</mark>


**_Update:_** _Acknowledged, not resolved. The team stated:_


After some reviewing, the conclusion is that encoding without the leading zeros would

not be consistent with the current ethereum ecosystem. If someone wants to encode an

Address without the leading zeros, they can manually do the casting to uint256 and

then call the corresponding encode function. However this should not be the default

encoding.

### **L-05 Stuck Oracle Verifications for Migrated** **Chains**


The owner of the <mark>`BroadcasterOracle`</mark> contract is responsible for setting the

<mark>`broadcasterId`</mark> [for a specific chain. This setting is immutable, meaning, it cannot be](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/oracles/ChainMap.sol#L39-L59)

changed after it is initially set.


This immutability is problematic given the possibility that L2s may change their settlement

layer. For example, the <u>[migration of the settlement layer of ZKchains from Ethereum to the](https://docs.zksync.io/zksync-protocol/gateway)</u>

<u>[Gateway](https://docs.zksync.io/zksync-protocol/gateway)</u> illustrates this scenario. When an L2 changes its parent chain, the route to verify

messages adds a new pointer. This will cause the <mark>`broadcasterId`</mark> accumulator to change.

Therefore, if the mapping is not updatable, the new accumulator will not match the stored

<mark>`broadcasterId`</mark> <mark>,</mark> which would halt oracle verifications for that chain.


Consider adding a mechanism to update the <mark>`broadcasterId`</mark> for a chain in the event it

changes its parent chain.


**_Update:_** _Acknowledged, not resolved. The team stated:_


The team understands the issue but it is a design choice to have the setting the

<mark>`broadcasterId`</mark> for a specific chain immutable. The idea is to have the least trust

requirements possible on the oracle. In this case, although we need an owner to update

the mapping, in order to decrease the trust assumptions, we believe it's better to not

allow for updates on it, so users and solvers are sure that the oracle won't change. We

also believe that a chain changing its parent chain is probably a rare event and, if that

happens, we could always deploy a new oracle.


OIF Broadcaster Audit − Low Severity − 13


## **Notes & Additional** **Information**

### **N-01 Gas Optimization**

Within the <mark>`BlockHashProverPointer`</mark> contract, in the <u><mark>`[setImplementationAddress](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/BlockHashProverPointer.sol#L27-L36)`</mark></u>

function, the <mark>`_implementationAddress`</mark> storage variable is fetched twice within the same

scope. This results in an unnecessary <mark>`sload`</mark> operation.


Consider caching <mark>`_implementationAddress`</mark> to avoid the extra storage read.


**_Update:_** _[Resolved at pull request #38](https://github.com/openintentsframework/broadcaster/pull/38)_ _[at commit 807810f.](https://github.com/openintentsframework/broadcaster/pull/38/commits/807810f6b8a2bdfc380f9c0d0ee0fdbcc6b858b8)_

### **N-02 Incomplete Docstrings**


Throughout the codebase, multiple instances of incomplete docstrings were identified:













In <mark>`BlockHashProverPointer.sol`</mark> <mark>,</mark> the <u><mark>`[implementationCodeHash](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/BlockHashProverPointer.sol#L23-L25)`</mark></u> function has

no documentation for the returned value.

In <mark>`Broadcaster.sol`</mark> <mark>,</mark> the <u><mark>`[hasBroadcasted](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/Broadcaster.sol#L29-L31)`</mark></u> function has no documentation for

parameters.

In <mark>`Receiver.sol`</mark> <mark>,</mark> the <u><mark>`[blockHashProverCopy](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/Receiver.sol#L70-L72)`</mark></u> function has no documentation for

the parameter nor for the returned value.

In <mark>`IReceiver.sol`</mark> <mark>,</mark> the <u><mark>`[blockHashProverCopy](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/interfaces/IReceiver.sol#L49)`</mark></u> function has no documentation for

the <mark>`bhpPointerId`</mark> parameter nor the returned value. Even though the interface has

been extracted directly from the EIP specification, it is highly recommended to add this

documentation.



Consider thoroughly documenting all functions/events (and their parameters or return values)

that are part of a contract's public API. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _[Resolved in pull request #39](https://github.com/openintentsframework/broadcaster/pull/39)_ _[at commit 2d7bf91.](https://github.com/openintentsframework/broadcaster/pull/39/commits/2d7bf91045c16ea10812ebe29c938283f8f2a54b)_


OIF Broadcaster Audit − Notes & Additional Information − 14


### **N-03 Floating Pragma**

Pragma directives should be fixed to clearly identify the Solidity version with which the

contracts will be compiled.


Throughout the codebase, multiple instances of floating pragma directives were identified:











<mark>`BlockHashProverPointer.sol`</mark> has the <u><mark>`[solidity ^0.8.27](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/BlockHashProverPointer.sol#L2)`</mark></u> floating pragma

directive.

<mark>`Broadcaster.sol`</mark> has the <u><mark>`[solidity ^0.8.27](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/Broadcaster.sol#L2)`</mark></u> floating pragma directive.

<mark>`Receiver.sol`</mark> has the <u><mark>`[solidity ^0.8.27](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/Receiver.sol#L2)`</mark></u> floating pragma directive.

<mark>`BroadcasterOracle.sol`</mark> has the <u><mark>`[solidity ^0.8.26](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L2)`</mark></u> floating pragma directive.



Consider using fixed pragma directives.


**_Update:_** _[Partially Resolved in pull request #40](https://github.com/openintentsframework/broadcaster/pull/40)_ _[in commit f811731.](https://github.com/openintentsframework/broadcaster/pull/40/commits/f8117318b1efe378dfa19898a97f2b09e98aaa0d)_

### **N-04 Missing Docstrings**


Throughout the codebase, multiple instances of missing docstrings were identified:














In <mark>`BlockHashProverPointer.sol`</mark> <mark>,</mark> the <u><mark>`[BlockHashProverPointer](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/BlockHashProverPointer.sol#L11-L41)`</mark></u> contract

In <mark>`BlockHashProverPointer.sol`</mark> <mark>,</mark> the <u><mark>`[implementationAddress](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/BlockHashProverPointer.sol#L18-L20)`</mark></u> function

In <mark>`BlockHashProverPointer.sol`</mark> <mark>,</mark> the <u><mark>`[setImplementationAddress](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/BlockHashProverPointer.sol#L27-L36)`</mark></u> function

In <mark>`Broadcaster.sol`</mark> <mark>,</mark> the <u><mark>`[Broadcaster](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/Broadcaster.sol#L8-L47)`</mark></u> contract

In <mark>`Broadcaster.sol`</mark> <mark>,</mark> the <u><mark>`[broadcastMessage](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/Broadcaster.sol#L11-L26)`</mark></u> function

In <mark>`Receiver.sol`</mark> <mark>,</mark> the <u><mark>`[Receiver](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/Receiver.sol#L9-L116)`</mark></u> contract

In <mark>`Receiver.sol`</mark> <mark>,</mark> the <u><mark>`[verifyBroadcastMessage](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/Receiver.sol#L21-L41)`</mark></u> function

In <mark>`Receiver.sol`</mark> <mark>,</mark> the <u><mark>`[updateBlockHashProverCopy](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/src/contracts/Receiver.sol#L43-L66)`</mark></u> function



Consider thoroughly documenting all functions (and their parameters) that are part of any

contract's public API. Functions implementing sensitive functionality, even if not public, should

[be clearly documented as well. When writing docstrings, consider following the Ethereum](https://solidity.readthedocs.io/en/latest/natspec-format.html)

<u>[Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _[Resolved in pull request #41](https://github.com/openintentsframework/broadcaster/pull/41)_ _[at commits 141e3da](https://github.com/openintentsframework/broadcaster/pull/41/commits/141e3dad2e11845b4477d4a941a9564d04b18b77)_ _[and 411487c.](https://github.com/openintentsframework/broadcaster/pull/41/commits/411487ca85d32ed31e61382e3dafe3f5f742c28d)_


OIF Broadcaster Audit − Notes & Additional Information − 15


### **N-05 Use Custom Errors**

Since Solidity version <mark>`0.8.4`</mark> <mark>,</mark> custom errors provide a cleaner and more cost-efficient way to

explain to users why an operation failed.


Multiple instances of <mark>`revert`</mark> and/or <mark>`require`</mark> messages were found within

<mark>`ProverUtils.sol`</mark> and <mark>`RLP`</mark> <mark>:</mark>











In <mark>`ProverUtils`</mark> <mark>,</mark> the <u><mark>`[require(blockHash == keccak256(rlpBlockHeader),](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/libraries/ProverUtils.sol#L70)`</mark></u>

<u><mark>`["Block hash does not match")](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/libraries/ProverUtils.sol#L70)`</mark></u> statement

In <mark>`ProverUtils`</mark> <mark>,</mark> the <u><mark>`[require(accountExists, "Account does not exist")](https://github.com/openintentsframework/broadcaster/blob/3522b4c7c958ce254497b879cc1f6106131c7e3e/./src/contracts/libraries/ProverUtils.sol#L116)`</mark></u>

statement

In <mark>`RLP`</mark> <mark>,</mark> the <u><mark>`[require(bytes1(item.load(0)) != 0x00)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d9f966fc3f7c4eec7f565c2442cc64481e7fb499/contracts/utils/RLP.sol#L371)`</mark></u> statement



For conciseness and gas savings, consider replacing <mark>`require`</mark> and <mark>`revert`</mark> messages with

custom errors.


**_Update:_** _[Resolved in pull request #42](https://github.com/openintentsframework/broadcaster/pull/42)_ _[at commit 720d8a1.](https://github.com/openintentsframework/broadcaster/pull/42/commits/720d8a1e52e21c75952631659ef2281768fc772c)_

### **N-06 Inconsistent Use of Returns in Functions**


Throughout the codebase, multiple instances of inconsistent returned values were identified:











In <mark>`BroadcasterOracle.sol`</mark> <mark>,</mark> the <u><mark>`[_hashPayloadHashes](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L125)`</mark></u> function's named return

value

In <mark>`BroadcasterOracle.sol`</mark> <mark>,</mark> the <u><mark>`[_getMessage](https://github.com/openintentsframework/oif-contracts/blob/acc7f9ca32ccd9e133f00c644251d7ff976edb24/src/integrations/oracles/broadcaster/BroadcasterOracle.sol#L146)`</mark></u> function's named return value

In <mark>`RLP.sol`</mark> <mark>,</mark> the <u><mark>`[encode(Encoder memory self)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d9f966fc3f7c4eec7f565c2442cc64481e7fb499/contracts/utils/RLP.sol#L174-L176)`</mark></u> function's named return value

In <mark>`RLP.sol`</mark> <mark>,</mark> the <u><mark>`[_decodeLength](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d9f966fc3f7c4eec7f565c2442cc64481e7fb499/contracts/utils/RLP.sol#L329)`</mark></u> function's named return value



Consider removing the redundant <mark>`return`</mark> statement in functions with named returns to

improve code clarity and maintainability.


**_Update:_** _[Resolved in pull request #161](https://github.com/openintentsframework/oif-contracts/pull/161)_ _[in commit cd44a53](https://github.com/openintentsframework/oif-contracts/pull/161/commits/cd44a53a420d2a7d2280216b914b9680d12952d9)_ _[and in pull request #6106](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6106)_ _in commit_

_<u>[47c8048.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6106/commits/47c804874940c7b8864d7728865b88dbd0f80323)</u>_

### **N-07 Ambiguous Documentation Of bytes[]** **Encoding**


The <mark>`RLP`</mark> library provides an <u><mark>`[encode](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d9f966fc3f7c4eec7f565c2442cc64481e7fb499/contracts/utils/RLP.sol#L169-L171)`</mark></u> <u>function for</u> <u><mark>`[bytes[]](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d9f966fc3f7c4eec7f565c2442cc64481e7fb499/contracts/utils/RLP.sol#L169-L171)`</mark></u> <u><mark>-</mark></u> <u>type values. The implementation</u>

simply concatenates the byte arrays provided in the input. However, this implementation can


OIF Broadcaster Audit − Notes & Additional Information − 16


be misleading. A naive interpretation may suggest that the function encodes an array of raw

byte strings. This method would cause information about the length of each individual byte

array to be lost. According to the <u>[Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)</u> specification, an array is encoded as the

concatenation of the encoding of its items. The <mark>`encode(bytes[] memory input)`</mark> function

actually expects a list of already encoded items. This requires users to first call

<mark>`encode(string memory input)`</mark> (or a similar <mark>`encode`</mark> function) on each item before

passing the resulting array to <mark>`encode(bytes[] memory input)`</mark> <mark>.</mark>


Consider improving the docstrings for the <mark>`encode(bytes[] memory input)`</mark> function. The

documentation should clearly state that the function expects an array of already encoded byte

strings, not raw strings, to prevent potential misuse and confusion.


**_Update:_** _[Resolved in pull request #6106](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6106)_ _[in commit 78f643d.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6106/commits/78f643d19e8c8551534c84b5b550ef9dcfd9f062)_

### **N-08 Unreachable Checks**


Within the <u><mark>`[_decodeLength](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d9f966fc3f7c4eec7f565c2442cc64481e7fb499/contracts/utils/RLP.sol#L327-L379)`</mark></u> function of the <mark>`RLP`</mark> library, there are multiple unreachable

<mark>`bytes1(item.load(0)) != 0x00`</mark> checks. The first byte of the item corresponds to the

RLP prefix. In cases where this byte is <mark>`0x00`</mark> <mark>,</mark> the execution flow would have already branched

in the first two <mark>`if`</mark> statements of the function ( <mark>`prefix < LONG_OFFSET`</mark> and <mark>`prefix <`</mark>

<mark>`SHORT_OFFSET`</mark> <mark>)</mark>, so this check can never be reached.


Consider modifying the check to inspect the second element (index `1` ) instead of the first

(index `0` ). This will correctly verify that the big-endian expression of the data's length is non
zero.


**_Update:_** _[Resolved in pull request #6051](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6051)_ _[in commits d3c84f5](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6051/commits/d3c84f5b05993cfb5b630b69f4fe8bea9a8d31ac)_ _[and 3e96235.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6051/commits/3e962351be968d527ec27b860595a1a710449a73)_

### **N-09 Misleading Documentation**


In the <mark>`RLP`</mark> contract, a comment within the <u><mark>`[readBytes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/d9f966fc3f7c4eec7f565c2442cc64481e7fb499/contracts/utils/RLP.sol#L242)`</mark></u> <u>function</u> states that "Length is

checked by <mark>{</mark> <mark>`toBytes`</mark> <mark>}</mark> ". However, this is misleading. The length check is not performed

directly by the <mark>`toBytes`</mark> function, but rather by the <mark>`slice`</mark> function, which <mark>`toBytes`</mark> calls.


Consider updating the comment to accurately reflect the fact that the <mark>`slice`</mark> function

performs the length check.


**_Update:_** _[Resolved in pull request #6106](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6106)_ _[in commit 55b33a0.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6106/commits/55b33a00291fa1686d1a12c81c9298b38cade88b)_


OIF Broadcaster Audit − Notes & Additional Information − 17


### **N-10 Non-Canonical Long-string Decoding** **Acceptance**

The <mark>`RLP`</mark> library's decoding function for long strings accepts length specifications that contain

leading zero bytes. However, these encodings are considered non-canonical. This behavior

diverges from other well-known RLP implementations, such as Go-ethereum (geth), which do

not accept them. This discrepancy could lead to interoperability issues where data is

considered valid by this library but invalid by other standard Ethereum clients.


Consider reverting when these non-canonical encodings are provided to align with standard

RLP implementation behavior.


**_Update:_** _Acknowledged, not resolved. The team stated:_


As mentioned in L-03 and L-04, in order to be consistent with other libraries in the

ecosystem (such as ethers.js), we chose to accept non canonical encodings with

leading zeros.

### **N-11 Inconsistent Integer Base in Inline Assembly** **When Setting RLP Prefixes**


In the <mark>`RLP.sol`</mark> library, RLP prefix assignments are performed using inline assembly. The

integer base for these assignments is inconsistent. Both decimal and hexadecimal notations

are used interchangeably across the library. The following instances of hexadecimal bases

have been identified:







```
mstore(result, 0x01)
mstore(result, 0x15)

```


Consider consistently using the decimal integer base to improve code clarity.


**_Update:_** _[Resolved in pull request #6106](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6106)_ _[in commit 61b695f.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6106/commits/61b695f673dceeafad843dc834593b701d4827bf)_


OIF Broadcaster Audit − Notes & Additional Information − 18


## **Conclusion**

The present Open Intents Framework (OIF) audit covered three foundational components

designed to enable secure, standardized, and permissionless cross-chain interoperability: the

ERC-7888 implementation, the RLP Library, and the <mark>`BroadcasterOracle`</mark> contract. The

ERC-7888 contracts establish a modular verification framework for authentic cross-chain

messaging. The RLP Library ensures efficient and deterministic data encoding consistent with

Ethereum’s canonical format, while the <mark>`BroadcasterOracle`</mark> contract integrates message

broadcasting and verification within OIF’s intent-based protocol, supporting complex multi
chain settlement flows through modular execution models.


During the audit, one high-severity issue was identified in the <mark>`Receiver`</mark> contract, impacting

multi-route message verification, along with a medium-severity issue related to application

validation within the <mark>`BroadcasterOracle`</mark> <mark>.</mark> In addition, several trust assumptions and

opportunities for improving code clarity, maintainability, and overall consistency were noted,

accompanied by recommendations to strengthen validation boundaries and reduce reliance on

trusted components. Overall, the codebase was found to be well-structured, modular, and

clearly documented, enhancing auditability and integration across OIF’s cross-chain

ecosystem.


The OIF team demonstrated strong technical proficiency and responsiveness throughout the

review process. Their willingness to provide detailed explanations, clarify architectural

decisions, and collaborate on issue resolution greatly contributed to the effectiveness of the

assessment and reflected a clear commitment to delivering a robust and extensible

interoperability framework.


OIF Broadcaster Audit − Conclusion − 19


