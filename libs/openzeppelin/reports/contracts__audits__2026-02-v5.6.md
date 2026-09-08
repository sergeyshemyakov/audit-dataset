### | security

# **OpenZeppelin** **Contracts v5.6** **Audit**

#### **February 27, 2026**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  9

Bug Fixes and Standards Compliance 9

Breaking Changes and Deprecations 9

Cross-Chain Additions 10

Cryptography, Signers, and Low-Level Utilities 10


Security Model and Trust Assumptions _____________________________________________ 11


Medium Severity _________________________________________________________________ 12

M-01 Memory Aliasing for Single-Byte Inputs 12

M-02 receiveId Check Causes Accidental DoS/Incompatibility With Empty receiveId Gateways 12


Low Severity ____________________________________________________________________ 13

L-01 Unexpected Revert in WebAuthn._validateChallenge 13

L-02 Bypassing WebAuthn-Specific Validations in SignerWebAuthn._rawSignatureValidation 13

L-03 Possible Permanent Message Loss in ERC7786Recipient._processMessage 14

L-04 Missing Bounds Check in Accumulators.flatten 14

L-05 Incomplete Documentation 15

L-06 tryParseV1 Does Not Reject Input With Both Empty chainReference and Address, Violating ERC-7930 16

L-07 Incorrect Documentation 17

L-08 Inaccurate Error Message When Traversing Empty Branch Slot 19

L-09 TrieProof Rejects Valid Merkle-Patricia Proofs With Inline Extension Leaf Nodes 19

L-10 Incorrect Lower-bound Validity Check in getValidationData 20


Notes & Additional Information ____________________________________________________ 21

N-01 Missing Bound Check for Long-Form Length-of-Length 21

N-02 Redundant item.length() Call in RLP Encoding 22

N-03 escapeJSON Does Not Escape Raw Control Characters Like NULL Byte 22

N-04 Inconsistent Use of Decimal vs Hexadecimal Notation for Slice Offsets 23

N-05 setFreeMemoryPointer Should Follow the Unsafe Naming Convention to Reflect Potential Memory Corruption 23


Client Reported __________________________________________________________________ 24

CR-01 uint8 Wraparound In tryParseV1 And tryParseV1Calldata Causes Incorrect Slice Bounds 24


Conclusion ______________________________________________________________________ 26


OpenZeppelin Contracts v5.6 Audit − Table of Contents − 2


Appendix _______________________________________________________________________ 27

Issue Classification 27


OpenZeppelin Contracts v5.6 Audit − Table of Contents − 3


## **Summary**

**Type** Library


**Timeline** From 2026-01-26
To 2026-02-05


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


2 (2 resolved)



**Total Issues** 18 (14 resolved, 2 partially resolved)



**Low Severity Issues** 10 (7 resolved, 2 partially resolved)



**Notes & Additional**
**Information**



5 (4 resolved)



OpenZeppelin Contracts v5.6 Audit − Summary − 4


## **Scope**

OpenZeppelin performed a diff audit of the <u>[OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/)</u> library between release

[v5.4.0 at commit c64a1ed](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/c64a1edb67b6e3f4a15cca8909c9482ad33a02b0) (tag <mark>`v5.4.0`</mark> <mark>)</mark> and release candidate v5.6.0-rc.1 at commit <u>[68e4095](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/68e4095c1de9853ae264852178c4466a3046323e)</u>

(tag <mark>`v5.6.0-rc.1`</mark> <mark>)</mark> .


In scope were the following files:

```
contracts/
├── access/
│  ├── AccessControl.sol
│  ├── extensions/
│  │  ├── AccessControlDefaultAdminRules.sol
│  │  ├── AccessControlEnumerable.sol
│  │  └── IAccessControlDefaultAdminRules.sol
│  └── manager/
│    ├── AccessManager.sol
│    └── IAccessManager.sol
├── account/
│  ├── Account.sol
│  ├── extensions/
│  │  ├── draft-AccountERC7579.sol
│  │  ├── draft-AccountERC7579Hooked.sol
│  │  └── draft-ERC7821.sol
│  └── utils/
│    ├── EIP7702Utils.sol
│    ├── draft-ERC4337Utils.sol
│    └── draft-ERC7579Utils.sol
├── crosschain/
│  ├── CrosschainLinked.sol
│  ├── ERC7786Recipient.sol
│  └── bridges/
│    ├── BridgeERC20.sol
│    ├── BridgeERC20Core.sol
│    └── BridgeERC7802.sol
├── finance/
│  └── VestingWallet.sol
├── governance/
│  ├── Governor.sol
│  ├── IGovernor.sol
│  ├── TimelockController.sol
│  ├── extensions/
│  │  ├── GovernorProposalGuardian.sol
│  │  ├── GovernorStorage.sol
│  │  ├── GovernorSuperQuorum.sol
│  │  ├── GovernorTimelockCompound.sol
│  │  ├── GovernorTimelockControl.sol
│  │  ├── GovernorVotesQuorumFraction.sol

```

OpenZeppelin Contracts v5.6 Audit − Scope − 5


```
│  │  └── GovernorVotesSuperQuorumFraction.sol
│  └── utils/
│    ├── IVotes.sol
│    ├── Votes.sol
│    └── VotesExtended.sol
├── interfaces/
│  ├── IERC3156FlashLender.sol
│  ├── IERC4626.sol
│  ├── IERC6909.sol
│  ├── IERC7751.sol
│  ├── draft-IERC4337.sol
│  ├── draft-IERC6093.sol
│  ├── draft-IERC7579.sol
│  ├── draft-IERC7786.sol
│  └── draft-IERC7802.sol
├── metatx/
│  ├── ERC2771Context.sol
│  └── ERC2771Forwarder.sol
├── proxy/
│  ├── Clones.sol
│  ├── Proxy.sol
│  ├── ERC1967/
│  │  ├── ERC1967Proxy.sol
│  │  └── ERC1967Utils.sol
│  ├── transparent/
│  │  └── TransparentUpgradeableProxy.sol
│  └── utils/
│    └── UUPSUpgradeable.sol
├── token/
│  ├── ERC20/
│  │  ├── ERC20.sol
│  │  ├── extensions/
│  │  │  ├── ERC20Crosschain.sol
│  │  │  ├── ERC20FlashMint.sol
│  │  │  ├── ERC20Permit.sol
│  │  │  ├── ERC20Votes.sol
│  │  │  ├── ERC20Wrapper.sol
│  │  │  ├── ERC4626.sol
│  │  │  └── IERC20Permit.sol
│  │  └── utils/
│  │    └── SafeERC20.sol
│  ├── ERC721/
│  │  ├── ERC721.sol
│  │  ├── extensions/
│  │  │  ├── ERC721Burnable.sol
│  │  │  ├── ERC721Consecutive.sol
│  │  │  ├── ERC721Enumerable.sol
│  │  │  ├── ERC721Pausable.sol
│  │  │  ├── ERC721Royalty.sol
│  │  │  ├── ERC721URIStorage.sol
│  │  │  ├── ERC721Votes.sol
│  │  │  └── ERC721Wrapper.sol
│  │  └── utils/
│  │    ├── ERC721Holder.sol
│  │    └── ERC721Utils.sol
│  ├── ERC1155/

```


OpenZeppelin Contracts v5.6 Audit − Scope − 6


```
│  │  ├── ERC1155.sol
│  │  ├── extensions/
│  │  │  ├── ERC1155Burnable.sol
│  │  │  ├── ERC1155Pausable.sol
│  │  │  ├── ERC1155Supply.sol
│  │  │  └── ERC1155URIStorage.sol
│  │  └── utils/
│  │    └── ERC1155Holder.sol
│  └── ERC6909/
│    ├── ERC6909.sol
│    └── extensions/
│      ├── ERC6909ContentURI.sol
│      ├── ERC6909Metadata.sol
│      └── ERC6909TokenSupply.sol
└── utils/
├── Address.sol
├── Arrays.sol
├── Base58.sol
├── Base64.sol
├── Blockhash.sol
├── Bytes.sol
├── Create2.sol
├── LowLevelCall.sol
├── Memory.sol
├── Multicall.sol
├── RLP.sol
├── ReentrancyGuard.sol
├── ReentrancyGuardTransient.sol
├── RelayedCall.sol
├── ShortStrings.sol
├── SlotDerivation.sol
├── Strings.sol
├── draft-InteroperableAddress.sol
├── cryptography/
│  ├── ECDSA.sol
│  ├── EIP712.sol
│  ├── MerkleProof.sol
│  ├── MessageHashUtils.sol
│  ├── SignatureChecker.sol
│  ├── TrieProof.sol
│  ├── WebAuthn.sol
│  ├── draft-ERC7739Utils.sol
│  ├── signers/
│  │  ├── MultiSignerERC7913.sol
│  │  ├── SignerECDSA.sol
│  │  ├── SignerEIP7702.sol
│  │  ├── SignerWebAuthn.sol
│  │  └── draft-ERC7739.sol
│  └── verifiers/
│    ├── ERC7913P256Verifier.sol
│    ├── ERC7913RSAVerifier.sol
│    └── ERC7913WebAuthnVerifier.sol
├── introspection/
│  └── ERC165Checker.sol
├── math/
│  ├── Math.sol

```


OpenZeppelin Contracts v5.6 Audit − Scope − 7


```
│  └── SafeCast.sol
├── structs/
│  ├── Accumulators.sol
│  ├── Checkpoints.sol
│  ├── CircularBuffer.sol
│  ├── DoubleEndedQueue.sol
│  ├── EnumerableMap.sol
│  ├── EnumerableSet.sol
│  ├── Heap.sol
│  └── MerkleTree.sol
└── types/
└── Time.sol

```


OpenZeppelin Contracts v5.6 Audit − Scope − 8


## **System Overview**

The diff from v5.4.0 to v5.6.0-rc.1 is a wide-ranging update spanning two release cycles (v5.5

and v5.6). It includes standards compliance fixes, several breaking API updates, new

cryptographic and cross-chain primitives, and numerous gas optimizations. The changes

smooth out rough edges in existing abstractions while adding building blocks for account

systems, signature verification, trie proof verification, and message-based interoperability.


The changes can be grouped into the following categories:

### **Bug Fixes and Standards Compliance**


This update includes targeted fixes that reduce unexpected reverts and improve standards
facing behavior. **ERC-7579 module introspection** now avoids reverting on malformed context

in fallback modules and returns <mark>`false`</mark> instead, improving compliance and tooling

compatibility. **ERC-165 checking** was corrected so <mark>`supportsERC165`</mark> returns <mark>`false`</mark> if a

target reverts during the <mark>`supportsInterface(0xffffffff)`</mark> probe. **SignatureChecker**

fixes an invalid length check. **Base64** fixes <mark>`InvalidBase64Char`</mark> argument encoding at

certain positions. **ERC-4626** computes <mark>`maxWithdraw`</mark> using <mark>`maxRedeem`</mark> and

<mark>`previewRedeem`</mark> so that changes to the preview functions affect the max functions.

### **Breaking Changes and Deprecations**


Several changes affect overrides, imports, and runtime semantics:














**ERC-1155** batch transfers with exactly one id/value no longer call

<mark>`onERC1155Received`</mark> <mark>.</mark> Instead, <mark>`onERC1155BatchReceived`</mark> is called.

**ERC-721 and ERC-1155** prevent setting an operator for <mark>`address(0)`</mark> (in ERC-721, this

could lead to obfuscated mint permission).

**ERC1967Proxy** and **TransparentUpgradeableProxy** mandate initialization during

construction, reverting with <mark>`ERC1967ProxyUninitialized`</mark> otherwise.

**Account** <mark>`_validateUserOp`</mark> now takes an explicit <mark>`signature`</mark> argument.

**ERC-4337** support is bumped to **Entrypoint v0.9**, with paymaster signature parsing and

timestamp/block number-based validity ranges.


OpenZeppelin Contracts v5.6 Audit − System Overview − 9


**ERC-7579** fallback module install/uninstall requires at least 4 bytes of (de)init data.

Uninstall is forced when <mark>`onUninstall`</mark> reverts.

**ECDSA** malleability protection has been partly deprecated.

<mark>`Initializable`</mark> and <mark>`UUPSUpgradeable`</mark> are no longer transpiled.

Various import path changes (ERC-6909 finalized, <mark>`SignerERC7702`</mark> renamed to

<mark>`SignerEIP7702`</mark> <mark>)</mark> and a minimum pragma bump to 0.8.24.


### **Cross-Chain Additions**

New cross-chain building blocks have been introduced: a generic **ERC-7786 recipient** base

contract, draft **ERC-7786 interfaces**, and an **ERC-7930 interoperable address** library. On top

of these, an ERC-7786-based cross-chain bridging infrastructure has been added:













**<mark>`CrosschainLinked`</mark>** <mark>:</mark> A helper contract that maintains a registry of <mark>`Links`</mark> specifying

the address of an ERC-7786 gateway and a counterpart on the target chain using the

<mark>`InteroperableAddress`</mark> format.

**<mark>`BridgeERC20Core`</mark>** <mark>:</mark> It extends <mark>`CrosschainLinked`</mark> to facilitate cross-chain ERC-20

transfers, using <mark>`virtual`</mark> functions <mark>`_onSend`</mark> and <mark>`_onReceive`</mark> to handle burning/

minting or locking/releasing.

**<mark>`BridgeERC20`</mark>** <mark>:</mark> A lock/release bridge implementation.

**<mark>`BridgeERC7802`</mark>** <mark>:</mark> A cross-chain burn/mint bridge for ERC-7802 tokens.

**<mark>`ERC20Crosschain`</mark>** <mark>:</mark> An ERC-20 extension that embeds an ERC-7786 based cross
chain bridge directly in the token contract.


### **Cryptography, Signers, and Low-Level Utilities**

A substantial expansion has been made to cryptography and performance-oriented utilities.

**WebAuthn/P256** support includes a WebAuthn verification library, **<mark>`SignerWebAuthn`</mark>** (which

validates WebAuthn authentication assertions, falling back to P256 signature validation when

WebAuthn validation fails), and **<mark>`ERC7913WebAuthnVerifier`</mark>** (a stateless ERC-7913

signature verifier supporting WebAuthn authentication assertions using P256 public keys). A

**TrieProof** library for Ethereum Merkle Patricia Trie proof verification and an **RLP** library for

encoding and decoding data in Ethereum's Recursive Length Prefix format are introduced.


**Dynamic domain separator hash** generation based on ERC-5267 has also been added.

Several new low-level utilities have been introduced— **Memory** (slices/pointers), **Accumulators**

(linked-list construction in memory with O(1) insertions and O(n) flattening), **LowLevelCall**, and

**RelayedCall** —along with extensions to Bytes, Arrays, and existing data structures. Many of


OpenZeppelin Contracts v5.6 Audit − System Overview − 10


these involve inline assembly and are sensitive to boundary conditions and encoding

correctness.

## **Security Model and Trust** **Assumptions**


Auditing libraries requires a shift in focus due to their composability within blockchain

protocols. While the scope of an audit is typically limited to the code itself, the scope expands

when it comes to libraries because of their potential internal and external integrations. Libraries

act as foundational components for many protocols. This means that their security is

influenced not just by their internal robustness, but also by how they are utilized by integrators.

As a result, ensuring a library's security involves reviewing the code as well as anticipating its

various use cases and integration scenarios.


In addition to the above, the complexity grows because, while a library must accommodate a

wide range of potential use cases, the responsibility for secure implementation often falls on

developers who integrate it into their projects. These developers must carefully review the

<u>[security considerations](https://docs.openzeppelin.com/contracts/5.x/extending-contracts#security)</u> when extending contracts from the library. A library's security risks can

multiply depending on how well developers understand and utilize its contracts. Therefore,

extra care is necessary to identify and address all potential threats, both direct and indirect, or

to document them so that developers are fully aware of the associated security risks.


OpenZeppelin Contracts v5.6 Audit − Security Model and Trust Assumptions

                                                - 11


## **Medium Severity**

### **M-01 Memory Aliasing for Single-Byte Inputs**

The <u><mark>`[encode](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L209-L211)`</mark></u> and <u><mark>`[readList](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L349)`</mark></u> functions return the input directly without copying when the

input is a single byte with value less than 128. In this case, the returned bytes memory shares

the same memory location as the input. Any subsequent modification to the input will also

modify the **encoded** result, and vice versa.


Protocols using this library for security-sensitive operations such as transaction encoding,

Merkle proofs, or cross-chain messaging may experience silent data corruption if the input is

modified after encoding. The affected edge case covers common values including small

nonces, chain IDs under 128, and boolean representations. Since no error is produced, such

corruption would be difficult to diagnose in production.


Consider always returning a copy for single-byte inputs to ensure consistency with the rest of

the function's behavior and prevent unexpected memory aliasing.


**_Update:_** _[Resolved in pull request #6342](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6342)_ _[at commit c2e62b4. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/c2e62b4441368ce76074c7ace401d111a21b9d75)_


_The aliasing issue was fixed for_ _<mark>`encode`</mark>_ _and now single-byte inputs below 128 are no_

_longer returned as-is. Instead, a fresh_ _<mark>`bytes memory`</mark>_ _is returned so the result is_

_independent of the input._


_In the case of_ _<mark>`readList`</mark>_ _we didn’t change it because it returns a_ _<mark>`Memory.Slice[]`</mark>_

_and we consider_ _<mark>`Slices`</mark>_ _to be read-only objects. Returning newly allocated bytes_

_would change the API and semantics (copies instead of read) and isn’t consistent with_

_the current design. Instead, it was noted in both_ _<mark>`readList`</mark>_ _and_ _<mark>`decodeList`</mark>_ _<mark>.</mark>_ _Callers_

_that need independent data can copy from the slice themselves._

### **M-02 receiveId Check Causes Accidental DoS/** **Incompatibility With Empty receiveId** **Gateways**


<u><mark>`[ERC7786Recipient](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/crosschain/ERC7786Recipient.sol#L44)`</mark></u> implements replay protection keyed by (gateway, <mark>`receiveId`</mark> <mark>)</mark> using a

bitmap. This means that if an authorized gateway delivers more than one message with


OpenZeppelin Contracts v5.6 Audit − Medium Severity − 12


<mark>`receiveId == bytes32(0)`</mark> <mark>,</mark> the first message succeeds and all subsequent messages

revert, regardless of sender/payload.


However, <u>[EIP-7786](https://eips.ethereum.org/EIPS/eip-7786)</u> allows <mark>`receiveId`</mark> to be “empty” (in addition to being unique per

gateway). This creates an interoperability risk where a compliant gateway that uses “empty”

IDs (or uses zero as a sentinel) can unintentionally DoS delivery to an otherwise compliant

recipient. A gateway that repeatedly uses <mark>`receiveId == 0x0`</mark> can cause permanent

message delivery failure after the first message.


Consider updating the <mark>`receiveId`</mark> check to allow the delivery of empty <mark>`receiveId`</mark>

messages.


**_Update:_** _[Resolved in pull request #6346](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6346)_ _[at commit 157b001.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/157b0019b6a848599915991a680b7fff25373a3a)_

## **Low Severity**

### **L-01 Unexpected Revert in** **`WebAuthn._validateChallenge`**


<u><mark>`[_validateChallenge](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L151-L163)`</mark></u> is <u>[expected](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L155)</u> to return <mark>`true`</mark> <mark>/</mark> <mark>`false`</mark> <mark>.</mark> However, it may revert instead if

[the addition](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L159) before <mark>`slice()`</mark> overflows when <mark>`challengeIndex`</mark> is close to <mark>`max`</mark> . The noted

discrepancy becomes an issue if the caller expects <mark>`false`</mark> on invalid input instead of a revert.

For instance, <mark>`ERC7913WebAuthnVerifier.verify`</mark> is expected to <u>return</u> <u><mark>`[(bytes4)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/verifiers/ERC7913WebAuthnVerifier.sol#L25)`</mark></u> <mark>.</mark>

However, it may revert if <u><mark>`[WebAuthn.verify](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L89)`</mark></u> <mark>,</mark> which calls <u><mark>`[_validateChallenge](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L103)`</mark></u> <mark>,</mark> reverts.


Consider ensuring consistent behavior by <mark>`_validateChallenge`</mark> and its callers on failure.


**_Update:_** _[Resolved in pull request #6329.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6329)_

### **L-02 Bypassing WebAuthn - Specific Validations in** **`SignerWebAuthn._rawSignatureValidation`**


In <u><mark>`[SignerWebAuthn._rawSignatureValidation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/signers/SignerWebAuthn.sol#L39-L50)`</mark></u> <mark>,</mark> if <u><mark>`[WebAuthn](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/signers/SignerWebAuthn.sol#L46)`</mark></u> <u>verification</u> returns

<mark>`false`</mark> <mark>,</mark> [the contract falls back](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/signers/SignerWebAuthn.sol#L48) to raw P256 signature verification as also mentioned in the

<u>[comments. This allows for bypassing](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/signers/SignerWebAuthn.sol#L35-L37)</u> <mark>`WebAuthn`</mark> <mark>-</mark> specific validations such as UV. For instance,

an attacker may have a valid P256 signature but no valid <mark>`WebAuthn`</mark> <mark>.</mark>


OpenZeppelin Contracts v5.6 Audit − Low Severity − 13


Consider keeping the <mark>`WebAuthn`</mark> and raw P256 validations independent. Alternatively,

consider documenting the justification of this behavior.


**_Update:_** _[Resolved in pull request #6337.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6337)_

### **L-03 Possible Permanent Message Loss in** **`ERC7786Recipient._processMessage`**


In <mark>`ERC7786Recipient.receiveMessage`</mark> <mark>,</mark> the <mark>`received`</mark> [flag is set](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/crosschain/ERC7786Recipient.sol#L47) before

<u><mark>`[_processMessage](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/crosschain/ERC7786Recipient.sol#L49)`</mark></u> <mark>.</mark> That is fine if <mark>`_processMessage`</mark> reverts on failure. However, if

<mark>`_processMessage`</mark> does not revert on failure (e.g., silently exists without actually processing

the message), then the message can be permanently lost (i.e., never processed).


Consider explicitly documenting that <mark>`_processMessage`</mark> should revert on failure.


**_Update:_** _[Resolved in pull request #6330.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6330)_

### **L-04 Missing Bounds Check in** **`Accumulators.flatten`**


<u><mark>`[Accumulators.flatten](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/structs/Accumulators.sol#L95)`</mark></u> transforms all <u>[Accumulator](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/structs/Accumulators.sol#L38-L41)</u> entries into a single bytes buffer.

However it does not perform any bounds check (i.e. any <mark>`data.asSlice`</mark> length in <u><mark>`[push](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/structs/Accumulators.sol#L57)`</mark></u> and

<u><mark>`[shift](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/structs/Accumulators.sol#L77)`</mark></u> can be passed). This may cause <mark>`flatten`</mark> to throw an out of bounds (OoB) revert.


Consider imposing checks on the slices lengths to prevent an OoB revert or at least

documenting this behavior.


**_Update:_** _[Resolved in pull request #6302. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6302)_


_We’re including a new_ _<mark>`isReserved(Slice)`</mark>_ _function that checks whether the_ _<mark>`Slice`</mark>_

_provided as argument starts and ends before the current free memory pointer. This_

_function is now used in_ _<mark>`push`</mark>_ _and_ _<mark>`shift`</mark>_ _to validate bounds._


OpenZeppelin Contracts v5.6 Audit − Low Severity − 14


### **L-05 Incomplete Documentation**

Throughout the codebase, multiple opportunities for improving the documentation were

identified.





















In <mark>`RelayedCall`</mark> <mark>,</mark> <mark>`getRelayer`</mark> <u>[uses](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RelayedCall.sol#L76)</u> the <mark>`push0`</mark> [instruction, which is a new](https://eips.ethereum.org/EIPS/eip-3855)

<u>[instruction. Consider documenting that the library should be used on chains that support](https://eips.ethereum.org/EIPS/eip-3855)</u>

<mark>`push0`</mark> <mark>.</mark>

In <mark>`WebAuthn`</mark> <mark>,</mark> [the following three checks](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L22-L30) are not implemented, since they are

responsibility of the authenticator and do not have on-chain use cases: <u>[origin validation,](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L22)</u>

<u>[RP ID hash validation, and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L25)</u> <u>[signature counter. Consider stating this explicitly in the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/WebAuthn.sol#L28)</u>

documentation.

The <mark>`draft-InteroperableAddress`</mark> library's <u><mark>`[tryParseV1](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/draft-InteroperableAddress.sol#L95)`</mark></u> (and derived

<u><mark>`[tryParseEvmV1](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/draft-InteroperableAddress.sol#L172)`</mark></u> <mark>)</mark> accepts inputs that contain a valid ERC-7930 v1 encoding followed

by arbitrary trailing bytes. Consider documenting this behavior explicitly (i.e., that parsing

does not enforce canonical length / does not reject extra bytes), since multiple distinct

byte strings can decode to the same semantic target and callers may assume the input

bytes are a unique/canonical identifier.

In <mark>`RLP`</mark> <mark>,</mark> the <u><mark>`[readAddress](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L288-L292)`</mark></u> <u>function</u> accepts inputs with length 1 or 21 bytes. However,

<u><mark>`[encode(address)](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L159-L166)`</mark></u> always produces 21 bytes regardless of the address value. This

creates an asymmetry where <mark>`encode(readAddress(data))`</mark> may produce different

bytes than the original data for non-canonical inputs. Consider adding documentation

explaining the encoding/decoding asymmetry and the rationale for accepting non
canonical inputs during decoding.

In <mark>`TrieProof`</mark> <mark>,</mark> the use of the word "prefix" <u>[here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L154)</u> is correct, but it is too easy to be

confused with the prefix that is prepended to the nibble sequence and determines even

[or odd length and extension versus branch node (as in this](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L162) usage, which occurs 8 lines

later).

In the <mark>`Memory`</mark> library, the documentation does not explain what a <mark>`Slice`</mark> is: namely,

that its leftmost 128 bits store the length and its rightmost 128 bits stores the offset

(address in memory) measured in bytes.

In <mark>`Accumulators`</mark> <mark>,</mark> the documentation does not explicitly mention that the free memory

pointer after accumulation and flattening may not be 32-byte aligned. This is not

necessarily a problem, but should be documented in case the developer requires 32
byte alignment.

In <mark>`ERC1155`</mark> <mark>,</mark> since the requirements have been updated, the documentation <u>[listing them](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/dde766bd542e4a1695fe8e4a07dc03b77305f367/contracts/token/ERC1155/ERC1155.sol#L379)</u>

should also include the added requirement that <mark>`owner`</mark> cannot be the zero address.



Consider addressing all the noted instances of incomplete/improvable documentation.


OpenZeppelin Contracts v5.6 Audit − Low Severity − 15


**_Update:_** _[Partially Resolved in pull request #6330. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6330)_


_We implemented the suggested documentation changes except in these cases:_


_-_ **_RLP:_** _The possibility that_ _<mark>`encode(readAddress(data))`</mark>_ _differs from the original_

_bytes for non-canonical inputs is a consequence of accepting multiple encodings for the_

_same value (as already documented for_ _<mark>`readAddress`</mark>_ _and_ _<mark>`readUint256`</mark>_ _<mark>)</mark>_ _. We_

_consider round-trip byte equality to be an implicit property of any permissive encoder/_

_decoder and have not added specific documentation for it._


_-_ **_Memory:_** _We intentionally do not document how the_ _<mark>`Slice`</mark>_ _type is represented in_

_memory (e.g. layout of length and offset). The library is designed to be used only via its_

_public API, and we prefer that users do not depend on or manipulate those internals._


_-_ **_Accumulators:_** _Solidity does not in general guarantee that the free memory pointer_

_remains 32-byte aligned after operations. We do not treat the pos_ _<mark>t</mark>_ _<mark>`flatten`</mark>_ _FMP as a_

_special case of the Accumulators library and have not documented alignment in this_

_context._

### **L-06 tryParseV1 Does Not Reject Input With** **Both Empty chainReference and Address,** **Violating ERC-7930**


According to ERC-7930, an interoperable address MUST have at least one of

<mark>`chainReference`</mark> or address be non-empty. The specification states: "AddressLength MUST

NOT be zero if ChainReferenceLength is also zero."


The <mark>`formatV1`</mark> function correctly <u>[enforces](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/draft-InteroperableAddress.sol#L32)</u> this requirement by reverting with

<mark>`InteroperableAddressEmptyReferenceAndAddress`</mark> when both fields are empty.

However, <u><mark>`[tryParseV1](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/draft-InteroperableAddress.sol#L91-L116)`</mark></u> and <u><mark>`[tryParseV1Calldata](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/draft-InteroperableAddress.sol#L118-L142)`</mark></u> do not validate this constraint. They

successfully parse and return <mark>`success=true`</mark> for input where both

<mark>`chainReferenceLength`</mark> and <mark>`addrLength`</mark> are zero.


This creates an asymmetry where <mark>`formatV1`</mark> rejects empty reference combined with empty

address, but <mark>`tryParseV1`</mark> accepts it as valid. A contract relying on <mark>`tryParseV1`</mark> returning

<mark>`success=true`</mark> as proof of ERC-7930 compliance would incorrectly accept malformed input

that violates the standard.


Consider adding validation in <mark>`tryParseV1`</mark> and <mark>`tryParseV1Calldata`</mark> after parsing both

lengths to return failure when both are zero.


OpenZeppelin Contracts v5.6 Audit − Low Severity − 16


**_Update:_** _[Resolved in pull request #6331.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6331)_

### **L-07 Incorrect Documentation**


Throughout the codebase, multiple instances of incorrect documentation were identified:













Wrong <u>[comment](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/introspection/ERC165Checker.sol#L124)</u> for <mark>`_trySupportsInterface`</mark> <mark>:</mark> _"_ _<mark>`supported`</mark>_ _<mark>:</mark>_ _true if the call_

_succeeded AND returned data indicating the interface is supported"_ . The <mark>`supported`</mark>

value is <u>[independent](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/introspection/ERC165Checker.sol#L136)</u> of the <u><mark>`[success](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/introspection/ERC165Checker.sol#L135)`</mark></u> of the call. They are <u>[checked together](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/introspection/ERC165Checker.sol#L113)</u> by the

caller.

In the <mark>`Bytes`</mark> and <mark>`Arrays`</mark> libraries:

  - The documentation for <mark>`splice`</mark> in the <mark>`Bytes`</mark> and <mark>`Arrays`</mark> libraries <u>[states](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Arrays.sol#L468-L473)</u> that it

"replicates the behavior of JavaScript's <mark>`Array.splice`</mark> <mark>"</mark> . However, the function's

behavior is fundamentally different from JavaScript's <mark>`splice`</mark> . The current

NatSpec describes the operation as: _"Moves the content of_ _<mark>`array`</mark>_ _, from_ _<mark>`start`</mark>_

_(included) to the end of_ _<mark>`array`</mark>_ _to the start of that array"_ . This description omits

the fact that the array is shrunk. For instance, splicing the array <mark>`[A, B, C, D,`</mark>

<mark>`E, F]`</mark> at <mark>`[C, D]`</mark> yields <mark>`[C, D]`</mark> <mark>,</mark> while one may wrongfully expect <mark>`[C, D, C,`</mark>

<mark>`D, E, F]`</mark> based on the documentation. Consider updating the documentation to

clearly describe that the function keeps a specified range and shrinks the array to

that range. The effect can be more succinctly stated as "overwrites <mark>`array`</mark> with

<mark>`array[start..end]`</mark> <mark>"</mark> or similar.

[◦ The comment "allocate and copy"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Bytes.sol#L166) within <mark>`Bytes.replace`</mark> <u>[and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Arrays.sol#L538)</u>

<u><mark>`[Arrays.replace](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Arrays.sol#L538)`</mark></u> is misleading because no memory allocation occurs in this

function. Consider revising this comment to reflect that this function overwrites

<mark>`buffer`</mark> using <mark>`mcopy`</mark> <mark>.</mark>

In <mark>`TrieProof`</mark> <mark>:</mark>

  - The documentation refers to nodes as either large or small (see <u>[1, 2), while the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L126)</u>

code refers to nodes as either large or _short_ . Ideally, within the code, the nodes

should be named either long/short or large/small.

  - <u>[This comment](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L216-L217)</u> is misleading: in trie proof verification, a 32-byte nodeId is assumed

to be a hash (nodes exactly 32 bytes in length are also hashed).

  - <u>[Lines 25 and 27](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L25-L28)</u> use AsciiDoc-style link syntax <mark>(</mark> <mark>`URL[link text]`</mark> <mark>)</mark> which

NatSpec does not support. The <mark>`[link text]`</mark> suffix won't render as a clickable

link and will display literally as part of the URL. Consider using plain URLs instead.

In <mark>`LowLevelCall`</mark> <mark>,</mark> <u>[this comment](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/LowLevelCall.sol#L58)</u> states that <mark>`staticcallReturn64Bytes`</mark> is useful

for functions that return a tuple of single-word values. However, the length of this tuple is

always 2, so "ordered pair" would be more precise.


OpenZeppelin Contracts v5.6 Audit − Low Severity − 17


In the <mark>`Memory`</mark> library, there are discrepancies between names in the documentation

versus in the code. On lines <u>[77](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Memory.sol#L77)</u> [and 83, the comment refers to the beginning of the bytes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Memory.sol#L83)

array as <mark>`start`</mark> while the code refers to the same thing as <mark>`offset`</mark> <mark>.</mark> On line 83, the

comment refers to the length of the byte array as <mark>`length`</mark> while the code refers to it as

<mark>`len`</mark> <mark>.</mark>

In <mark>`ERC2771Forwarder`</mark> <mark>,</mark> since <mark>`tryRecover`</mark> was replaced with

<mark>`tryRecoverCalldata`</mark> [in the code, the documentation](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/dde766bd542e4a1695fe8e4a07dc03b77305f367/contracts/metatx/ERC2771Forwarder.sol#L217) should update "ECDSA
tryRecover" to "ECDSA-tryRecoverCalldata".

The following typographical errors were also identified:




      - In <mark>`Accumulators`</mark> <mark>,</mark> the word <u>["not"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/structs/Accumulators.sol#L36)</u> should be capitalized.

      - In <mark>`Arrays`</mark> <mark>,</mark> <u>["i.e."](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Arrays.sol#L584)</u> should be "e.g."

      - In <mark>`RLP`</mark> <mark>,</mark> <u>["cannot de"](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L55)</u> should be "cannot be".

      - In <mark>`RLP`</mark> <mark>,</mark> the following brace references <u>[1, 2, 3](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L171)</u> are malformed and the "-" should be

removed.

      - In <mark>`RLP`</mark> <mark>,</mark> [the second backtick](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L421) is missing before "length".


Consider addressing all the noted instances of incorrect documentation to improve the clarity

and maintainability of the codebase.


**_Update:_** _[Partially Resolved in pull request #6330. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6330)_


_The incorrect documentation instances have been addressed with the following_

_exceptions:_


_- In_ _<mark>`TrieProof`</mark>_ _:_


_[- This comment in the internal](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L216-L217)_ _<mark>`_getNodeId`</mark>_ _function is kept. We consider it’s worth_

_documenting the behavior of the function when a slice input of length 32 is provided._

_Especially since there’s no dedicated error. In practice, nodes should be <32 bytes or_

_>=33 bytes._


_- In_ _<mark>`LowLevelCall`</mark>_ _we’re keeping the use of “tuple“ to match how Solidity refers to_

_multi-value returns like_ _<mark>`(bytes32, bytes32)`</mark>_ _. There is no separate “pair” type or_

_term; “tuple” is the standard word for “multiple values with a fixed order.”_


_- AsciiDoc syntax is kept to match our documentation engine_


OpenZeppelin Contracts v5.6 Audit − Low Severity − 18


### **L-08 Inaccurate Error Message When Traversing** **Empty Branch Slot**

When traversing a branch node where the target child slot is empty (indicating the key does not

exist in the trie), the function returns <u><mark>`[INVALID_SHORT_NODE](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L127-L128)`</mark></u> or <u><mark>`[INVALID_LARGE_NODE](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L123-L124)`</mark></u>

instead of a more descriptive error.


In RLP encoding, empty branch slots are represented as 0x80 (the RLP empty string), which is

1 byte, not 0 bytes. When <mark>`_getNodeId`</mark> <u>[is called](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L140)</u> is called with this 1-byte slice, it returns

<mark>`nodeIdLength = 1`</mark> <mark>.</mark> On the next iteration, validation fails due to length mismatch: - If next

proof element ≥ 32 bytes: <mark>`currentNodeIdLength != 32`</mark> (1 ≠ 32) **_→_**

<mark>`INVALID_LARGE_NODE`</mark> - If next proof element < 32 bytes: <mark>`currentNodeIdLength !=`</mark>

<mark>`encoded.length`</mark> (1 ≠ len) **_→_** <mark>`INVALID_SHORT_NODE`</mark>


These errors suggest that the proof encoding or hashing is incorrect, whereas the actual issue

is that the key does not exist in the trie.


Consider checking for the RLP empty string <mark>`0x80`</mark> before calling <mark>`_getNodeId`</mark> and return a

dedicated error such as <mark>`KEY_NOT_IN_TRIE`</mark> or <mark>`EMPTY_BRANCH_SLOT`</mark> <mark>.</mark> This would align with

how other "key not found" scenarios are handled (e.g.,

<mark>`MISMATCH_LEAF_PATH_KEY_REMAINDER`</mark> <mark>,</mark> <mark>`INVALID_PATH_REMAINDER`</mark> <mark>)</mark> .


**_Update:_** _[Resolved in pull request #6330. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6330)_


_We documented the empty-branch-slot case in the same NOTE as the 32-byte case in_

_<mark>`_getNodeId`</mark>_ _because both lead to INVALID_LARGE_NODE / INVALID_SHORT_NODE_

_for a different underlying reason. We did not add a dedicated error (e.g._

_KEY_NOT_IN_TRIE) so we avoid an extra check and keep the happy path cheaper; the_

_comment explains how to interpret the existing errors._

### **L-09 TrieProof Rejects Valid Merkle-Patricia** **Proofs With Inline Extension Leaf Nodes**


<u><mark>`[tryTraverse](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/cryptography/TrieProof.sol#L191)`</mark></u> fails to verify valid Ethereum Merkle-Patricia trie proofs when an extension

node references an inline (non-hashed) child node. In these cases, traversal reaches the end of

the provided proof without returning a value and incorrectly reports

<mark>`ProofError.INVALID_PROOF`</mark> <mark>.</mark> This behavior is incompatible with the Ethereum MPT

specification and with proofs returned by standard clients.


OpenZeppelin Contracts v5.6 Audit − Low Severity − 19


This causes false negatives during proof verification: valid proofs may be rejected even though

they correctly prove inclusion against the provided root. While this does not introduce a

security vulnerability (invalid proofs are not accepted), it may lead to:









incompatibility with standard Ethereum proofs

failed verification for otherwise correct transactions, receipts, accounts, or storage slots

operational issues for protocols relying on <mark>`TrieProof`</mark> for on-chain verification



Consider modifying <mark>`TrieProof.tryTraverse`</mark> to correctly handle extension nodes that

reference inline (non-hashed) child nodes. By doing so, traversal can continue without

exhausting the proof.


**_Update:_** _[Resolved in pull request #6351.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6351)_

### **L-10 Incorrect Lower-bound Validity Check in** **`getValidationData`**


<u><mark>`[getValidationData](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/account/utils/draft-ERC4337Utils.sol#L169)`</mark></u> incorrectly marks a <mark>`UserOperation`</mark> as out of time range when

<mark>`current == validAfter`</mark> <mark>,</mark> [contradicting the validity semantics defined in EIP-4337, which](https://eips.ethereum.org/EIPS/eip-4337)

specify that a <mark>`UserOperation`</mark> is valid starting at <mark>`validAfter`</mark> <mark>.</mark> This results in a one-unit

(timestamp or block) false-negative validity window.


The function determines whether the current timestamp or block number is within the validity

window encoded in <mark>`validationData`</mark> <mark>.</mark> The lower-bound check uses <mark>`current <=`</mark>

<mark>`validAfter`</mark> which causes <mark>`outOfTimeRange`</mark> to be true when <mark>`current ==`</mark>

<mark>`validAfter`</mark> <mark>.</mark> However, according to EIP-4337, <mark>`validAfter`</mark> is inclusive, meaning the

operation must be considered valid starting at that exact timestamp or block.


Consider updating the lower-bound check to respect the inclusive semantics defined by

EIP-4337.


**_Update:_** _Acknowledged, not resolved. The team stated:_


_Our logic is intentional: it matches the canonical EntryPoint, which uses_

_<mark>`block.timestamp <= data.validAfter`</mark>_ _and_ _<mark>`block.number <=`</mark>_

_<mark>`validAfterBlock`</mark>_ _<mark>.</mark>_ _We keep this behavior so our utils stay consistent with the_

_reference implementation. If the ERC or EntryPoint change, we can revisit._


OpenZeppelin Contracts v5.6 Audit − Low Severity − 20


## **Notes & Additional** **Information**

### **N-01 Missing Bound Check for Long-Form Length-** **of-Length**

The RLP encoder implementation does not enforce the RLP specification’s implicit bound that

the length-of-length ( <mark>`lenOfLen`</mark> <mark>)</mark> used in long-form encoding must be ≤ 8 bytes (i.e., payload

length must be <mark>`< 2**64`</mark> <mark>)</mark> . For <mark>`lengths ≥ 2**64`</mark> <mark>,</mark> the computed prefix byte overflows the

valid RLP prefix ranges and can wrap into a different item class (e.g., bytes encoding

producing a list prefix), resulting in malformed / type-confused encoding.


<u>[RLP long-form](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L244-L246)</u> encoding reserves a single prefix byte to encode both the item type and the

number of bytes used to represent the payload length:

##### • Long bytes prefix range: 0xB8..0xBF -> lenlength ∈[1..8] • Long list prefix range: 0xF8..0xFF -> lenlength ∈[1..8]


If <mark>`lenlength > 8`</mark> <mark>,</mark> the computed prefix exits these ranges:


**Bytes case (** **<mark>`offset = 0x80`</mark>** **<mark>)</mark>**







For <mark>`length >= 2**64, lenlength = 9`</mark> and <mark>`prefix = 0xB7 + 9 = 0xC0`</mark>

0xC0 is the short-list base prefix, meaning a long-bytes encoding could be

misinterpreted as a list.



**List case (** **<mark>`offset = 0xC0`</mark>** **<mark>)</mark>**







For <mark>`lenlength = 9`</mark> <mark>:</mark> <mark>`prefix = 0xF7 + 9 = 0x100`</mark>



Since the implementation writes the prefix with <mark>`mstore8`</mark> <mark>,</mark> this value truncates to <mark>`0x00`</mark> <mark>,</mark>

producing an invalid/nonsensical RLP prefix. This issue is not currently exploitable on the EVM,

because constructing/copying a bytes payload of size <mark>`≥ 2**64`</mark> is infeasible, and the encoder

will run out-of-gas before returning any output.


If the encoder were used in an environment where extremely large payload lengths are possible

(or if the implementation were refactored to avoid copying full payloads), it could produce

malformed encoding with incorrect type prefixes.


OpenZeppelin Contracts v5.6 Audit − Notes & Additional Information − 21


Consider checking that the length to encode is bound to <mark>`2**64 - 1`</mark> <mark>.</mark>


**_Update:_** _Acknowledged, not resolved. The team stated:_


_On the EVM the scenario is unreachable: either the ABI decoder runs out of gas when_

_copying calldata, or, with an assembly-forged large buffer, execution reverts (e.g. OOG)_

_on the first use of the length before the encoder runs. We are not adding a length bound_

_check._

### **N-02 Redundant item.length() Call in RLP** **Encoding**


In the <mark>`_decodeLength`</mark> function, <mark>`item.length()`</mark> is <u>[called again](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L460)</u> in the short list case

despite having already <u>[stored](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/RLP.sol#L425)</u> this value in <mark>`itemLength`</mark> at the beginning of the function. The

Slice length extraction involves bit-masking operations that are repeated unnecessarily,

resulting in a gas inefficiency.


Consider reusing the existing <mark>`itemLength`</mark> variable instead of calling <mark>`item.length()`</mark>

again.


**_Update:_** _[Resolved in pull request #6330.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6330)_

### **N-03 escapeJSON Does Not Escape Raw Control** **Characters Like NULL Byte**


The <u><mark>`[escapeJSON](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Strings.sol#L455-L494)`</mark></u> <u>function</u> escapes backslashes (which covers unicode escape sequences

like <mark>`\uXXXX`</mark> <mark>)</mark>, double quotes, and specific control characters <mark>(</mark> <mark>`\b`</mark> <mark>,</mark> <mark>`\t`</mark>, <mark>`\n`</mark> <mark>,</mark> <mark>`\f`</mark>, <mark>`\r`</mark> <mark>)</mark> .

However, it does not escape raw control characters in the range U+0000 to U+001F that are

not in the explicit list.


For example, the NULL byte (0x00) is not escaped and will be left as-is in the output.

According to RFC-4627 Section 2.5, all characters from U+0000 to U+001F must be escaped

in JSON strings. Given that <mark>`escapeJSON`</mark> is designed for NFT metadata that gets rendered by

marketplaces in browsers, unescaped control characters could potentially cause parsing

issues or unexpected behavior in downstream consumers.


Consider escaping all control characters in the range U+0000 to U+001F, or document that

only specific control characters are escaped and that callers should sanitize input if full RFC

compliance is required.


OpenZeppelin Contracts v5.6 Audit − Notes & Additional Information − 22


**_Update:_** _[Resolved in pull request #6344.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6344)_

### **N-04 Inconsistent Use of Decimal vs** **Hexadecimal Notation for Slice Offsets**


The account utilities use inconsistent notation for slice offsets when extracting addresses and

other fixed-size data. For the same concept (address = 20 bytes), different files use different

notation:








<mark>`ERC7579Utils.sol`</mark> <u>[uses](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/account/utils/draft-ERC7579Utils.sol#L149)</u> hexadecimal: <mark>`executionCalldata[0x00:0x14]`</mark>

<mark>`AccountERC7579.sol`</mark> <u>[uses](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/account/extensions/draft-AccountERC7579.sol#L394)</u> decimal: <mark>`signature[20:]`</mark>



In addition, <mark>`ERC7579Utils.sol`</mark> <u>[mixes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/account/utils/draft-ERC7579Utils.sol#L166)</u> notation within the same expression, using decimal

for the start index and hexadecimal for the end index: <mark>`executionCalldata[0:0x14]`</mark> <mark>.</mark>


Consider adopting a consistent notation convention across the codebase.


**_Update:_** _[Resolved in pull request #6345. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6345)_


_In ERC7579Utils we use hex slice bounds (e.g. 0x14, 0x34) so offsets align with EVM_

_word size (0x20) and are easy to read. In AccountERC7579 we use decimal for the_

_signature (e.g. signature[20:]) because “20” clearly means “after the 20-byte address.”_


_So 4 and 20 are kept in decimal where they denote selector/address size; hex is used_

_where we’re counting memory/word layout._


_[Other numeric literals follow our GUIDELINES.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/a0eb08bfc4e61b8d0cc5ea99cea3e2101b97dcb9/GUIDELINES.md)_

### **N-05 setFreeMemoryPointer Should Follow the** **Unsafe Naming Convention to Reflect Potential** **Memory Corruption**


In the <mark>`Memory`</mark> library, the <u><mark>`[setFreeMemoryPointer](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/68e4095c1de9853ae264852178c4466a3046323e/contracts/utils/Memory.sol#L35-L39)`</mark></u> <u>function</u> sets the free memory pointer,

located at byte offset <mark>`0x40`</mark> in memory, to an arbitrary user-supplied <mark>`Pointer`</mark> (alias for

<mark>`bytes32`</mark> <mark>)</mark> value. The assembly block is annotated as <mark>`memory-safe`</mark> <mark>,</mark> which is a semantic

promise that all memory-safety invariants are preserved, including that the free memory pointer


OpenZeppelin Contracts v5.6 Audit − Notes & Additional Information − 23


always points to unallocated memory. Since the function accepts an arbitrary value, this

invariant is not enforced and depends entirely on the caller:









Setting FMP to <mark>`0x00`</mark> would cause subsequent allocations to overwrite scratch space,

the FMP itself, and the zero slot.

Setting FMP backwards would cause subsequent allocations to overwrite previously

allocated data.



[While the library's documentation states that the user should conform to Solidity's memory-](https://docs.soliditylang.org/en/v0.8.20/assembly.html#memory-safety)

<u>[safety guidelines](https://docs.soliditylang.org/en/v0.8.20/assembly.html#memory-safety)</u> and the <mark>`setFreeMemoryPointer`</mark> NatSpec warns that everything after the

pointer may be overwritten, the function name does not signal the danger level to callers. The

function's philosophy is to give users raw access without restrictions, but since there is no

runtime enforcement that the supplied value conforms to memory-safety invariants, the

<mark>`memory-safe`</mark> annotation on the inner assembly block becomes a promise the function

cannot guarantee on its own.


Consider renaming the function to <mark>`unsafeSetFreeMemoryPointer`</mark> to align with

OpenZeppelin's naming convention for functions that can produce unsafe outcomes if misused

(e.g., <mark>`unsafeAccess`</mark> in <mark>`Arrays.sol`</mark> <mark>)</mark> . This makes the risk explicit at the call site without

adding runtime overhead. Moreover, consider reinforcing the warning at the NatSpec level with

explicit constraints (e.g., the pointer must be <mark>`>= 0x80`</mark> and must not point backwards into

already-allocated memory).


**_Update:_** _[Resolved in pull request #6348. The team stated:](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6348)_


_The setter is renamed to_ _<mark>`unsafeSetFreeMemoryPointer`</mark>_ _to match our convention_

_for unsafe helpers (e.g._ _<mark>`unsafeAccess`</mark>_ _<mark>)</mark>_ _, and we’ve removed_ _<mark>`asPointerasBytes32`</mark>_

_so callers must use the UDVT directly and can’t create pointers from arbitrary values._

_The NatSpec already states the FMP must not be set below_ _<mark>`0x80`</mark>_ _._

## **Client Reported**

### **CR-01 uint8 Wraparound In tryParseV1 And** **tryParseV1Calldata Causes Incorrect Slice** **Bounds**


<mark>`tryParseV1`</mark> <mark>,</mark> <mark>`parseV1`</mark> <mark>,</mark> <mark>`tryParseV1Calldata`</mark> and <mark>`parseV1Calldata`</mark> can return a

corrupted empty <mark>`addr`</mark> <mark>.</mark> The root cause is that <mark>`chainReferenceLength`</mark> and <mark>`addrLength`</mark>


OpenZeppelin Contracts v5.6 Audit − Client Reported − 24


were declared as <mark>`uint8`</mark> (see <mark>`tryParseV`</mark> <u>[1](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/draft-InteroperableAddress.sol#L107)</u> [and 2, and](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/draft-InteroperableAddress.sol#L112) <mark>`tryParseV1Calldata`</mark> <u>[1](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/draft-InteroperableAddress.sol#L135)</u> [and 2).](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/draft-InteroperableAddress.sol#L140)

Inside the unchecked block, Solidity infers arithmetic involving these variables as <mark>`uint8`</mark> 
width, so <u>[the expression](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/draft-InteroperableAddress.sol#L115)</u> <mark>`0x06 + chainReferenceLength + addrLength`</mark> wraps modulo

256 when the sum exceeds 255. This caused the <mark>`addr`</mark> slice bounds to be computed from the

wrapped value, returning empty bytes for <mark>`addr`</mark> with no revert and <mark>`success = true`</mark> <mark>.</mark> The

issue occurs when any call to <mark>`parseV1`</mark> / <mark>`tryParseV1`</mark> (and their <mark>`calldata`</mark> variants) where

<mark>`chainReference.length + addr.length > 249`</mark> <mark>.</mark>


**_Update:_** _[Resolved in pull request #6372.](https://github.com/OpenZeppelin/openzeppelin-contracts/pull/6372)_


OpenZeppelin Contracts v5.6 Audit − Client Reported − 25


## **Conclusion**

Overall, the v5.6 changeset was found to be of high quality, well documented, and consistent

with secure development best practices. The findings are mostly of low- or note-severity, and

center on clarity and edge-case hardening in newly added utilities, Merkle-Patricia trie, and

encoders/decoders—particularly RLP (memory aliasing behavior, non-canonical encodings,

missing error parameters, <mark>`encode(bytes[])`</mark> concatenation semantics), Base64

(documentation mismatch regarding revert behavior), and <mark>`InteroperableAddress`</mark> (parsing

functions accepting inputs that violate ERC-7930 when both <mark>`chainReference`</mark> and address

are empty, trailing bytes acceptance). Additional observations include minor documentation

improvements, standardizing hex-style patterns across account utilities, <mark>`escapeJSON`</mark> not

escaping all RFC-required control characters, enforcing non-user-provided keys in

Checkpoints, and missing length/bounds checks (e.g., <mark>`Accumulators.flatten`</mark> <mark>,</mark>

<mark>`WebAuthn._validateChallenge`</mark> <mark>)</mark> .


The medium-severity issues identified include an interoperability/DoS risk in

<mark>`ERC7786Recipient`</mark> where replay protection keyed by <mark>`(gateway, receiveId)`</mark> can

permanently block message delivery if a compliant gateway represents an "empty"

<mark>`receiveId`</mark> as <mark>`bytes32(0)`</mark> <mark>,</mark> and memory aliasing in RLP single-byte encoding where

returned bytes share memory with the input, potentially causing silent data corruption in

security-sensitive operations. Related low- and note-severity observations highlight that cross
chain and WebAuthn integrations are sensitive to threat-model and integration choices (replay/

reentrancy assumptions, potential message loss around <mark>`_processMessage`</mark> <mark>,</mark> and validation

bypass/fallback behaviors).


The final state of the audited codebase, including all implemented resolutions, is reflected in

[commit 5fd1781.](https://github.com/OpenZeppelin/openzeppelin-contracts/commit/5fd1781b1454fd1ef8e722282f86f9293cacf256)


Collaborating with the OpenZeppelin Contracts team has been a pleasure, as always. The

Contracts team is commended for the good work, and thanks are extended to them for

promptly and diligently answering our numerous technical questions in great detail and

engaging in follow-up discussions.


OpenZeppelin Contracts v5.6 Audit − Conclusion − 26


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


OpenZeppelin Contracts v5.6 Audit − Appendix − 27


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


OpenZeppelin Contracts v5.6 Audit − Appendix − 28


