### | security

# **Scroll Layer 1** **Audit**

#### **July 18, 2023**

This security assessment was prepared by
OpenZeppelin.


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  7

Architecture 7

Rollup and Bridging 7

State of Refunds 8


Trust Assumptions _________________________________________________________________  8


Privileged Roles ___________________________________________________________________  9


High Severity ____________________________________________________________________ 11

H-01 Incorrect Batch Hashes Due to Memory Corruption 11

H-02 Non-Standard RLP Encoding of Integer Zero 12

H-03 Incorrect Depth Calculation for Extension Nodes Allows Denial-of-Service 12

H-04 Withdraw Root Can Be Set Up as a Rug Pull 13

H-05 Users Can Lose Refund by Default 14

H-06 Lack of Refunds 15

H-07 L2 Standard ERC-20 Token Metadata Can Be Set Arbitrarily 16


Medium Severity _________________________________________________________________ 17

M-01 Enforced Transactions Signed Off-Chain Are Likely to Fail 17

M-02 Lack of Upgradeability Storage Gaps 18

M-03 WithdrawTrieVerifier Proves Intermediate Nodes 18


Low Severity ____________________________________________________________________ 19

L-01 Batch Reverting Can Pause Finalization 19

L-02 Initialization Not Disabled for Implementation Contracts 19

L-03 Code Redundancy 20

L-04 Lost Funds in Messenger Contracts 21

L-05 Outdated OpenZeppelin Library Version 21

L-06 Missing and Misleading Documentation 21

L-07 Lack of Logs on Sensitive Actions 23

L-08 Batch Events Lack Information 23

L-09 User Can Derive Call to Be on Behalf of the L1ScrollMessenger 23

L-10 Unpinned Compiler Version 24


Scroll Layer 1 Audit − Table of Contents − 2


Notes & Additional Information ____________________________________________________ 25

N-01 Constant Not Using UPPER_CASE Format 25

N-02 Error-Prone Call Encoding 25

N-03 Events Should Emit Old and New Value 26

N-04 Events Split Between Contracts and Interfaces 26

N-05 Gas Optimizations 26

N-06 Inconsistent Integer Base in Inline Assembly 27

N-07 Lack of Indexed Event Parameters 28

N-08 Multiple Event Emissions Can Confuse Off-Chain Clients 28

N-09 No Function to Remove a Custom Setting 28

N-10 SimpleGasOracle Is Not Used 29

N-11 Token Counterpart Address in WETH Gateway Can Be Misleading 29

N-12 Typographical Errors 30

N-13 Unintuitive Bitmap Ordering and Type for Skipped Messages 30

N-14 WETH Is Passed as a Parameter 31

N-15 Unused Imports 31

N-16 Unused Named Return Variable 32

N-17 Use Custom Errors 32

N-18 Variable Name Inconsistency 32


Client Reported  __________________________________________________________________ 33

CR-01 Missing Chain ID Allows Reuse of Proofs 33


Recommendations _______________________________________________________________ 34

ERC-20 Factory Design 34

ERC-165 Support 34

Testing Coverage 35

Monitoring Recommendations 35


Conclusion  ______________________________________________________________________ 38


Scroll Layer 1 Audit − Table of Contents − 3


## **Summary**

Type ZK Rollup


Timeline From 2023-05-15
To 2023-06-23


Languages Solidity



Critical Severity
Issues


High Severity
Issues


Medium Severity
Issues



0 (0 resolved)


7 (5 resolved, 1 partially resolved)


3 (3 resolved)



Total Issues 39 (16 resolved, 1 partially resolved)



Low Severity Issues 10 (7 resolved)



Notes & Additional
Information


Client Reported
Issues



18 (0 resolved)


1 (1 resolved)


Scroll Layer 1 Audit − Summary − 4


## **Scope**

We audited the `scroll-tech/scroll` repository at the <u>[3bc8a3f](https://github.com/scroll-tech/scroll/tree/3bc8a3f5c6ac816ddffadca41024331dcf4d3064)</u> commit of the `develop`

branch.


In scope were the following contracts:

```
contracts/src
├── External.sol
├── L1
│  ├── IL1ScrollMessenger.sol
│  ├── L1ScrollMessenger.sol
│  ├── gateways
│  │  ├── EnforcedTxGateway.sol
│  │  ├── L1CustomERC20Gateway.sol
│  │  ├── L1ERC1155Gateway.sol
│  │  ├── L1ERC20Gateway.sol
│  │  ├── L1ERC721Gateway.sol
│  │  ├── L1ETHGateway.sol
│  │  ├── L1GatewayRouter.sol
│  │  ├── L1StandardERC20Gateway.sol
│  │  └── L1WETHGateway.sol
│  └── rollup
│    ├── IL1MessageQueue.sol
│    ├── IL2GasPriceOracle.sol
│    ├── IScrollChain.sol
│    ├── L1MessageQueue.sol
│    ├── L2GasPriceOracle.sol
│    └── ScrollChain.sol
├── L2
│  └── gateways
│    ├── IL2ERC1155Gateway.sol
│    ├── IL2ERC20Gateway.sol
│    ├── IL2ERC721Gateway.sol
│    ├── IL2ETHGateway.sol
│    └── IL2GatewayRouter.sol
├── interfaces
│  ├── IERC20Metadata.sol
│  └── IWETH.sol
└── libraries
├── FeeVault.sol
├── IScrollMessenger.sol
├── ScrollMessengerBase.sol
├── callbacks
│  ├── IERC677Receiver.sol
│  └── IScrollGatewayCallback.sol
├── codec
│  ├── BatchHeaderV0Codec.sol
│  └── ChunkCodec.sol

```

Scroll Layer 1 Audit − Scope − 5


```
├── common
│  ├── AddressAliasHelper.sol
│  └── IWhitelist.sol
├── constants
│  └── ScrollConstants.sol
├── gateway
│  ├── IScrollGateway.sol
│  └── ScrollGatewayBase.sol
├── oracle
│  ├── IGasOracle.sol
│  └── SimpleGasOracle.sol
├── token
│  ├── IScrollERC1155.sol
│  ├── IScrollERC20.sol
│  ├── IScrollERC20Upgradeable.sol
│  ├── IScrollERC721.sol
│  ├── IScrollStandardERC20Factory.sol
│  ├── ScrollStandardERC20.sol
│  └── ScrollStandardERC20Factory.sol
└── verifier
├── IRollupVerifier.sol
├── PatriciaMerkleTrieVerifier.sol
└── WithdrawTrieVerifier.sol

```

Scroll's architecture and code structure draw inspiration from other Layer 2 solutions like

Arbitrum and Optimism, particularly in the design of their gateways, predeploys, and

messaging contracts. Notably, a lot of code structure from Arbitrum's gateways and the

`AddressAliasHelper.sol` contract are reused with minor modifications.


The primary focus of this audit was on the Scroll Rollup and Bridge Contracts. In this audit, we

aimed to verify the correctness and security of the contracts, focusing on aspects like block

finalization, message passing, and the process of depositing and withdrawing into/from the

rollup.


**_Update:_** _It is important to note that the_ _`develop`_ _branch changed the codebase between the_

_audit's start and the fix review. Hence, we only reviewed the fixes in their respective context and_

_cannot guarantee other implications that were introduced in the meantime._


Scroll Layer 1 Audit − Scope − 6


## **System Overview**

Scroll is an EVM-equivalent zk-Rollup designed to be a scaling solution for Ethereum. It

achieves this by interpreting EVM bytecode directly at the bytecode level, following a similar

path to projects like Polygon zkEVM and ConsenSys' Linea.


This report presents our findings and recommendations for the Scroll zk-Rollup protocol. In the

following sections, we will discuss these aspects in detail. We urge the Scroll team to consider

these findings in their ongoing efforts to provide a secure and efficient Layer 2 solution for

Ethereum.

### **Architecture**


The system's architecture is split into three main components:


   - Scroll Node: This constructs Layer 2 (L2) blocks from user transactions, commits these

transactions to the Ethereum base layer, and handles message passing between L1 and

L2.

   - Roller Network: This component is responsible for generating the zkEVM validity proofs,

which are used to prove that transactions are executed correctly.

   - Rollup and Bridge contracts: These contracts provide data availability for Scroll

transactions, verify zkEVM validity proofs, and allow users to move assets between

Ethereum and Scroll. Users can pass arbitrary messages between L1 and L2, and can

bridge assets in either direction thanks to the Gateway contracts.

### **Rollup and Bridging**


The Scroll system connects to Ethereum primarily through its Rollup and Messenger contracts.

The Rollup contract is responsible for receiving L2 state roots and blocks from the Sequencer,

and finalizing blocks on Scroll once their validity is established.


The Messenger contracts enable users to pass arbitrary messages between L1 and L2, as well

as bridge assets in both directions. The gateway contracts make use of the messages to

operate on the appropriate layer.


Scroll Layer 1 Audit − System Overview − 7


The standard ERC-20 token bridge automatically deploys tokens on L2, using a standardized

token implementation. There is also a custom token bridge which enables users to deploy their

L1 token on L2 for more sophisticated cases. In such scenarios, the Scroll team would need to

manually set the mapping for these tokens. This could potentially lead to double-minting on L2

(two tokens being created, one through each method). To prevent such a scenario, it is

recommended to use the GatewayRouter, which will route the token to the correct gateway.

### **State of Refunds**


When communicating/bridging from L1 to L2, values are handled in two ways on the L1 side:


1. If a token is bridged, the token will be held by the gateway contract. If ETH is transferred,

the value is kept in the L1 messenger contract. In the case of WETH, the assets will be

first unwrapped to ETH and forwarded to be held by the L1 messenger contract.

2. The user has to specify a gas limit that will be used for the L2 transaction. The relayer

accounts for this gas limit through a fee that is deducted on the L1 call.


In the audited version of the protocol there is no refund mechanism for (1) if the L1 initialized

message is not provable (or censored) and hence not executed and skipped from the L1

message queue. There is no refund either when a transaction is provable but reverts on L2.

This means assets can potentially get stuck in the Gateway or L1 messenger contracts.

Regarding (2), any gas limit in excess of the required amount is paid as an extra fee into the fee

vault. It is therefore crucial for users to make their best estimations through the l2geth API. For

technical details please see _<u>Lack of Refunds</u>_ <u>.</u>

## **Trust Assumptions**


During the course of the audit, several assumptions about the Scroll protocol were considered

to be inherently trusted. These assumptions and the context surrounding them include:


  - EVM node and relayer implementation: It is assumed that the EVM node

implementation will work as described in the <u>[Scroll documentation, particularly the](https://guide.scroll.io/developers/ethereum-and-alpha-testnet-differences)</u>

opcodes and their expected behavior. The relayer implementation is trusted to act in the

best interest of the users.

   - Censoring: The protocol is centralized as is, as the sequencer has the ability to censor

L2 messages and transactions. L1 to L2 messages are appended into a message queue

that is checked against when finalizing, but the sequencer can currently choose to skip


Scroll Layer 1 Audit − Trust Assumptions − 8


any message from this queue during finalization. This allows the chain to finalize even if a

message is not provable. Therefore, it is worth noting that L1 to L2 messages from the

`L1ScrollMessenger` or `EnforcedTxGateway` can be ignored and skipped. There

are plans to remove this message-skipping mechanism post-mainnet launch once the

prover is more capable.

  - No escape hatch: The Scroll protocol does not feature an escape hatch mechanism.

This, combined with the potential for transaction censorship by the relayer, introduces a

trust assumption in the protocol. In the event of the network going offline, users would

not be able to recover their funds.

## **Privileged Roles**


Certain privileged roles within the Scroll protocol were identified during the audit. These roles

possess special permissions that could potentially impact the system's operation:


   - Proxy Admins: Most of the contracts are upgradeable. Hence, most of the logic can be

changed by the proxy admin. The following contracts are upgradeable:

    - The gateway contracts




- `L1MessageQueue`

- `L1ScrollMessenger`

- `L2GasPriceOracle`

- `ScrollChain`

- `SimpleGasOracle`




- Implementation Owners: Most contracts are also ownable. The following actions

describe what the owner can do in each contract.




- `L1ScrollMessenger` : Pause relaying of L2 to L1 messages and L1 to L2

message requests.




- `EnforcedTxGateway` : Pause L1 to L2 transaction requests and change the fee

vault.




- `L1{CustomERC20|ERC721|ERC1155}Gateway` : Change the token mapping of

which L1 token is bridged to which L2 token.




- `L1GatewayRouter` : Set the respective gateway for ETH, custom ERC-20s and

default ERC-20s.




- `L1MessageQueue` : Update the maximum allowed gas limit for L2 transactions,

the gas price oracle to calculate the L2 fee and the `EnforcedTxGateway`

address that may append unaliased messages into the queue.


Scroll Layer 1 Audit − Privileged Roles − 9


- `L2GasPriceOracle` : Set the whitelist contract address that defines who may

change gas-related settings.




- `ScrollChain` : Revert previously committed batches that haven't been finalized



yet, set addresses as sequencers, change the verifier, and update the maximum

amount of L2 transactions that are allowed in a chunk (bundle of blocks).

- `FeeVault` : Change the messenger address that is used to withdraw the funds

from L2 to L1, the recipient address of the collected fees, and update the minimum

amount of funds to withdraw.




- `ScrollMessengerBase` : Change the fee vault address which collects fees for

message relaying.




- `SimpleGasOracle` : Update the default and a custom per-sender fee

configuration.




- `ScrollStandardERC20Factory` : Use the factory to deploy another instance of



a standard ERC-20 token on L2.

   - Sequencer: The sequencer role can interact with the `ScrollChain` contract to commit

to new batches that bundle multiple L2 blocks in chunks that can then be finalized along

with a proof.

   - Whitelist: Accounts can be whitelisted to change the L2 base fee on L1 as well as the

intrinsic gas parameters.


Each of these roles presents a unique set of permissions within the Scroll protocol. The

potential implications of these permissions warrant further consideration and mitigation to

ensure the system’s security and robustness.


Scroll Layer 1 Audit − Privileged Roles − 10


## **High Severity**

### **H-01 Incorrect Batch Hashes Due to Memory** **Corruption**

When committing a new batch, the `ScrollChain` contract calls the <u>`[_commitChunk](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L394)`</u>

function to compute a hash for each chunk in the batch. This hash includes the block contexts,

as well as L1 and L2 transaction hashes that are part of this chunk. The `_commitChunk`

function does this by getting the free memory pointer, storing everything it needs contiguously

starting there, and then getting the free memory pointer again to <u>[compute the keccak256 hash](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L468)</u>

<u>[of this section of memory.](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L468)</u>

```
+----------------------+---------------------------+---------------------------+
|  block contexts  |    L1 msg hashes    |    L2 msg hashes    |
| (58 bytes per block) | (32 bytes per L1 message) | (32 bytes per L2 message) |
+----------------------+---------------------------+---------------------------+
^                                       ^
free memory pointer (read from 0x40)                   dataPtr

```

Importantly, the function relies on the free memory pointer pointing to the same memory

location to be able to <u>[fetch the initial location](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L467)</u> from which to start computing the hash.

However, when <u>[fetching the L1 message hashes, the code does an external call to](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L426)</u>

<u>`[getCrossDomainMessage](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#LL507C63-L507C63)`</u> which stores its return value in memory. This causes the free

memory pointer to be shifted by a word to the right for each L1 message being processed.

This means that the chunk hashes are incomplete and the commitment would not include parts

of the information needed as soon as a block contains L1 transactions.


The resulting batch would thus have an incorrect hash. The network would not be able to

finalize when there are L1 transactions in a batch because the hash would not match with the

proof based on the zkEVM circuits.


Consider limiting the inline assembly usage to be less error-prone for memory corruption

issues. Otherwise, make sure to keep track of the right pointer to begin the hashing. Further,

ensure that these endpoints and any changes to them are fully end-to-end tested.


**_Update:_** _Resolved in_ _<u>[pull request #546](https://github.com/scroll-tech/scroll/pull/546)</u>_ _at commit_ _<u>[9606c61.](https://github.com/scroll-tech/scroll/pull/546/commits/9606c61f5e70d46fae9e4024b574790bc14ff671)</u>_


Scroll Layer 1 Audit − High Severity − 11


### **H-02 Non-Standard RLP Encoding of Integer Zero**

In the `L1MessageQueue`, the <u>`[computeTransactionHash](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L109)`</u> <u>function</u> implements the

<u>[EIP-2718 standard. Here, the transaction type of](https://eips.ethereum.org/EIPS/eip-2718)</u> `0x7E` is concatenated with the RLP-encoded

transaction values and hashed.


There is an issue in the inline <u>`[store_uint](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L142)`</u> <u>[assembly function](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L142)</u> which gives the non-standard

encoding for the integer value zero. While the standard foresees that zero is encoded as

`0x80`, the implementation encodes it as `0x00` . Hence, this leads to a non-standard encoding

and therefore different hash. Given the `uint256` type, `_queueIndex`, `_value`, and

`_gasLimit` are affected. While the `_queueIndex` will only be zero for the first ever

message, `_value` is going to be zero for the vast majority of L1 message requests, because

the `L1ScrollMessenger` uses the `appendCrossDomainMessage` function, <u>[calling](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L251)</u>

<u>`[_queueTransaction](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L251)`</u> <u>with zero</u> and then computing the transaction hash with `_value` zero.


During the committing of batches, hashes of the message queue <u>[become part of the](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L507)</u>

<u>[commitment](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L507)</u> that will be proven during finalization. Considering the non-standard L1

transaction hashes, this commitment is expected to not align with the proof coming from the

zk-circuit, hence making the first and majority of L1 messages impossible to finalize.


Consider patching the `store_uint` function to catch this zero-integer edge case and achieve

a standard encoding.


**_Update:_** _Resolved in_ _<u>[pull request #558](https://github.com/scroll-tech/scroll/pull/558)</u>_ _at commit_ _<u>[869111b.](https://github.com/scroll-tech/scroll/pull/558/commits/869111b04ee45976273aa5656e95eb639a9f05cf)</u>_

### **H-03 Incorrect Depth Calculation for Extension** **Nodes Allows Denial-of-Service**


The <u>`[PatriciaMerkleTrieVerifier](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol)`</u> <u>library</u> is used by the `L2ScrollMessenger` contract

to prove that the `L1ScrollMessenger` has <u>[sent an L1 message](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/L2ScrollMessenger.sol#L120)</u> or <u>[executed an L2 message.](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/L2ScrollMessenger.sol#L155)</u>

Further, this functionality enables the user to <u>[retry an L1 sent message on L2](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/L2ScrollMessenger.sol#L228)</u> in case of

insufficient gas. Therefore, users can call the <u>RPC method</u> <u>`[eth_getProof](https://eips.ethereum.org/EIPS/eip-1186)`</u> on an Ethereum

node and submit the obtained proof to the `L2ScrollMessenger` contract to replay their

message if there was <u>[at least one failed attempt to relay the message. Since the proof](https://github.com/scroll-tech/scroll/blob/2a745ad7a9a2d8570432003ed570eaed1544394a/contracts/src/L2/L2ScrollMessenger.sol#L242)</u>

verification is based on the world state and account storage trie, the proof consists of an

account and storage proof.


During verification, the `PatriciaMerkleTrieVerifier` library walks down the inclusion

proof to verify that <u>[hashes match as expected. However, when encountering an extension node](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L378)</u>

in the account or storage proof, the library <u>[incorrectly computes the depth](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L394)</u> by adding the length


Scroll Layer 1 Audit − High Severity − 12


in bytes to the depth, instead of the number of nibbles (half-bytes), as well as not accounting

for the <u>[path length parity.](https://ethereum.org/en/developers/docs/data-structures-and-encoding/patricia-merkle-trie/#specification)</u>


For example, if the extension node `['13 f4 a7', next_hash]` was encountered, the 1

would indicate that it is an extension node with an odd path length. The correct path length to

be added to the depth would be 5, but the library incorrectly adds 3 to the depth by getting the

<u>[length in bytes. More concretely, due to an extension node in the account proof, it is](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L393)</u>

impossible to prove that the storage slot `0` of address

`0x0068cf6ef4fdf5a95d0e2546dab76f679969f3f5` contains the value 2 on the

Ethereum mainnet.


This error leads to valid proofs not being accepted by the `PatriciaMerkleTrieVerifier`

library. Since only the storage for the `L1ScrollMessenger` contract address <u>[is checked, a](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/L2ScrollMessenger.sol#L141)</u>

present extension node in the proof for this account would fail all verifications. An attacker can

take advantage of this by brute-forcing an address on L1 via `CREATE2` that has a hash

collision in the first nibbles with the <u>hash of the</u> <u>`[L1ScrollMessenger](https://github.com/scroll-tech/scroll/blob/fb443822978768f7df278d9ee5fdf8a82c6c6707/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L432)`</u> <u>address. Hence, an</u>

extension node is forced to appear in the state trie, thereby preventing any message to be

replayed on L2 - a denial-of-service attack - potentially locking users' funds until the contract is

upgraded.


Consider fixing the length calculation for extension nodes to accept valid proofs. It is advised

to test the library and integration more thoroughly, for instance with a differential fuzzing

approach and integration tests.


**_Update:_** _Resolved in_ _<u>[pull request #617](https://github.com/scroll-tech/scroll/pull/617)</u>_ _at commit_ _<u>[a8832bf.](https://github.com/scroll-tech/scroll/pull/617/commits/a8832bfb68a1e2c4a6b1b5d881cac34cb398830d)</u>_

### **H-04 Withdraw Root Can Be Set Up as a Rug Pull**


In the `ScrollChain` contract, the `importGenesisBatch` function allows anyone to set up

the first finalized batch on L1. This includes the <u>`[withdrawRoot](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L146)`</u> <u>[hash of the first batch. For L2](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L146)</u>

to L1 communication, L2 transactions are relayed through the `L1ScrollMessenger`

contract. To verify that a message was indeed initiated on L2, a provided Merkle proof needs to

result in the `withdrawRoot` that was given in the genesis block or during the finalization of

consecutive batches. Since the genesis block is finalized without any zk-proof, the

`withdrawRoot` can be set up arbitrarily.


These circumstances can potentially be used to set up a rug pull. The

<u>`[_xDomainCalldataHash](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L134)`</u> which is based on the relayed message data can be precalculated

to <u>[send any amount of ETH to any address. By setting up that hash as the genesis block](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L155)</u>

`withdrawRoot`, it would also be the <u>`[_messageRoot](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L140)`</u> in the respective relay message call.


Scroll Layer 1 Audit − High Severity − 13


Then, with a proof of length zero, the <u>[hashes match](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/WithdrawTrieVerifier.sol#L27)</u> and the <u>[Merkle proof requirement](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L142)</u> passes,

thereby stealing the users' deposited funds.


Since the `importGenesisBatch` function is unprotected this could be set up by anyone,

although it is unlikely to be unnoticed that the genesis block was initialized by an outside actor.

But this could also just lead to a malicious actor setting up the chain with erroneous

parameters and the Scroll team having to redeploy the proxy contract that delegates into the

`ScrollChain` contract implementation.


Consider removing the `_withdrawRoot` parameter of the `importGenesisBatch` function

and instead hardcoding its genesis block value to zero. Further, consider protecting the

function to only be called by the owner.


**_Update:_** _Partially resolved in_ _<u>[pull request #558](https://github.com/scroll-tech/scroll/pull/558)</u>_ _at commit_ _<u>[b82dab5. The](https://github.com/scroll-tech/scroll/pull/558/commits/b82dab5da35b863c2c95f892d9b3dc05d7cfc147)</u>_ _`_withdrawRoot`_ _is_

_removed as a parameter and unset, but the function is still callable by anyone. The Scroll team_

_stated:_


_It is only called once during initialization, it should not be a problem to be callable by_

_anyone._

### **H-05 Users Can Lose Refund by Default**


In the `L1ScrollMessenger`, the `sendMessage` functions allow a user to initiate a

transaction on L2 from L1. There are two `sendMessage` implementations, with and without a

refund address parameter. For the function without the parameter, the refund address of the

internal `_sendMessage` call is <u>defined as</u> <u>`[tx.origin](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L106)`</u> .


This poses a risk of loss of funds for smart contract wallets. More concretely, with account

abstraction gradually emerging, this default refund recipient would end up being the

<u>`[UserOperations](https://eips.ethereum.org/EIPS/eip-4337#definitions)`</u> <u>bundler. Hence, while a user might think to receive the refund themselves,</u>

they end up losing their excessive funds.


Further, all of the gateways make use of this particular `sendMessage` function with the default

`tx.origin` refund address. Hence, a high percentage of users with smart contract wallets

may lose some ETH during bridging.


Consider defaulting the refund address in the `L1ScrollMessenger` contract to

`msg.sender` . In the gateway contracts, consider using the `sendMessage` function with the

definable refund recipient that is then set to `msg.sender` .


**_Update:_** _Resolved in_ _<u>[pull request #605](https://github.com/scroll-tech/scroll/pull/605)</u>_ _at commit_ _<u>[76d4230.](https://github.com/scroll-tech/scroll/pull/605/commits/76d4230571da5909499ace4c7bc90ad31a721325)</u>_


Scroll Layer 1 Audit − High Severity − 14


### **H-06 Lack of Refunds**

The protocol allows users to bridge their ERC-20, ERC-721, ERC-1155, WETH,

and ETH assets to the L2 rollup and back. If the target address is a contract, a callback is

executed during the bridging transaction. For example, when calling the `deposit{ERC20|`

`ETH}AndCall` function on the gateway contracts (for <u>[ETH, ERC-20s and WETH), the](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ETHGateway.sol#L55)</u>

<u>`[onScrollGatewayCallback](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L97)`</u> call is made to the target contract as the last step of the

bridging process. The same happens on the `withdraw{ERC20|ETH}AndCall` function.

Such callbacks are also standardly triggered on the `safeTransferFrom` function for

<u>[ERC-721](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC721Gateway.sol#L96-L127)</u> and <u>[ERC-1155](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L112)</u> tokens, which respectively call <u>`[onERC721Received](https://eips.ethereum.org/EIPS/eip-721#specification)`</u> and

<u>`[onERC1155Received](https://eips.ethereum.org/EIPS/eip-1155#specification)`</u> on the target contract.


However, because bridging transactions are not atomic, it is possible for the first half of the

transaction to be successful while the second half fails. This can happen when withdrawing/

depositing if the external call for the callback on the target contract reverts, for instance, when

a user is trying to bridge ETH through the `L{1|2}ETHGateway` but the target contract reverts

when calling `onScrollGatewayCallback` . Under such circumstances, users' funds are

stuck in the gateways or messenger, as there is no mechanism for them to recover their assets.

As mentioned above, the same could happen for the other assets.


It is worth noting that a reverting L2 transaction does not prevent the block from being finalized

on L1. Moreover, if the L2 transaction from an L1 deposit is not provable it has to be <u>[skipped](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L157)</u>

<u>[from the L1 message queue for finalization. However, the prior asset deposit into the L1](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L157)</u>

gateway or messenger would currently not be refunded to the user.


Further, when messaging from L1 to L2 (including bridging assets), users have to provide a <u>[gas](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L237)</u>

<u>[limit](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L237)</u> that will be used for the L2 transaction. The relayer accounts for this by deducting a <u>[fee](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L2GasPriceOracle.sol#L97)</u>

<u>[based on the gas limit](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L2GasPriceOracle.sol#L97)</u> from the `msg.value` when queuing the transaction on L1. Users

expecting this functionality to behave <u>[similarly to Ethereum](https://ethereum.org/en/developers/docs/gas/#what-is-gas-limit)</u> could set a high gas limit to ensure

the success of their transaction while being refunded for unused gas. However, any excessive

gas results in a fee overpayment that goes towards Scroll's fee vault, and is not refunded on

L2.


To avoid funds being lost when bridging, consider adding a way for users to be refunded when

the bridging transaction cannot be completed (for example when the transaction reverts or is

skipped), and when the gas limit exceeds the gas effectively consumed.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


Scroll Layer 1 Audit − High Severity − 15


_We currently will not support refunds on failed messages._

### **H-07 L2 Standard ERC-20 Token Metadata Can** **Be Set Arbitrarily**


When an ERC-20 is first deposited on L2 through the standard ERC-20 gateway contract, the

<u>[contract fetches](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L150)</u> the symbol, name and decimals of the ERC-20 token. These are <u>[ABI encoded](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L153)</u>

alongside the `_data` passed by the user, and the message is forwarded to the L2. On the L2

side, as this token is seen for the first time, the metadata is <u>[decoded from the data. A](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/gateways/L2StandardERC20Gateway.sol#L162)</u> <u>[call to](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/gateways/L2StandardERC20Gateway.sol#L161)</u>

<u>the</u> <u>`[ScrollStandardERC20Factory](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/gateways/L2StandardERC20Gateway.sol#L161)`</u> is then made and a clone of the

`ScrollStandardERC20` contract is deployed and <u>[initialized](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/gateways/L2StandardERC20Gateway.sol#L166)</u> with the symbol, name and

decimals.


However, an attacker can use the lack of atomicity when bridging to set arbitrary metadata

when an ERC-20 is bridged to L2 for the first time. An example of this would involve two

transactions:


1. The attacker first calls the <u>[deposit](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L114)</u> function to deposit a new ERC-20 token with a very

low `_gasLimit` parameter. Because the ERC-20 address is not yet in `tokenMapping`,

the contract fetches its <u>[metadata](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L150)</u> information and <u>[encodes](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L153)</u> it alongside the `_data`

parameter. The token is then added to the `tokenMapping`, the message is relayed and

reverts on L2 with an out-of-gas exception.

2. The attacker then calls the <u>[deposit](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L114)</u> function again with a `_data` parameter containing an

<u>[ABI encoding of arbitrary metadata. Because the](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L153)</u> `tokenMapping` now contains the

ERC-20 address, the call would be directly transmitted to L2 without fetching the

ERC-20 metadata. As it is the first time the L2 sees this token, a

`ScrollStandardERC20` clone is deployed with symbol, name and decimals decoded

from the `_data` parameter set by the attacker.


The token contract would thus have its metadata set by the attacker. Additionally, this contract

and the factory are <u>[immutable, and the address to which a clone is deployed is deterministic](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20.sol#L15)</u>

meaning it cannot be redeployed easily. This would be complex to fix in practice. In terms of

impact, it would be very confusing for users, having to deal with tokens with different metadata

in the UIs depending on whether the token is on L1 or L2, and could be used to intentionally

grief specific projects.


Consider not updating `tokenMapping[_token]` on the first partially successful L1 deposit,

but only when a token is successfully withdrawn from L2 in the <u>`[finalizeWithdrawERC20](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L88)`</u>

<u>[function. This strikes a good balance by ensuring that tokens can be deployed even if a first](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L88)</u>


Scroll Layer 1 Audit − High Severity − 16


transaction fails on L2, as the metadata would be sent again, while avoiding wasting gas by

querying this information on each deposit forever.


**_Update:_** _Resolved in_ _<u>[pull request #606](https://github.com/scroll-tech/scroll/pull/606)</u>_ _at commit_ _<u>[2f76991.](https://github.com/scroll-tech/scroll/pull/606/commits/2f76991ddbddcf92bef5fbd0103124e6636c6f2c)</u>_

## **Medium Severity**

### **M-01 Enforced Transactions Signed Off-Chain** **Are Likely to Fail**


The `EnforcedTxGateway` contract allows users to sign a transaction hash that authorizes an

L1 to L2 transaction. During the verification of the signature, the <u>[signed hash is computed](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/EnforcedTxGateway.sol#L86)</u>

given the `sendTransaction` function parameters, except for the `_queueIndex` value,

which is fetched as the supposedly following index from the message queue.


Timing this queue index during signing becomes challenging considering the following

scenario:


1. User A signs the transaction off-chain for index `i` .

2. User B queues a transaction unrelated to A, thereby incrementing the queue index to

`i+1` .

3. User C tries to submit user A's transaction, which reverts due to the mismatching queue

indices.


Depending on the activity of the messenger contract and the delay between users A and C, it

is likely that this call reverts.


Consider repurposing the queue index to a `nonce` that is signed as part of the transaction

hash by taking it as an additional function parameter. The replayability must therefore be

prevented by keeping track of used transaction hashes in a mapping. Also, consider adding an

expiration timestamp and chain id to the message such that signed messages are not

indefinitely valid and are chain dependent. Otherwise, a signature can be reused for a rollup

that follows the same message format and is signed by the same user. It's important to note

that the transaction hash should not be constructed over the signature when an OpenZeppelin

library version lower than 4.7.3 is used, due to a <u>[signature malleability issue.](https://github.com/OpenZeppelin/openzeppelin-contracts/security/advisories/GHSA-4h98-2769-gh6h)</u>


**_Update:_** _Resolved in_ _<u>[pull request #620](https://github.com/scroll-tech/scroll/pull/620)</u>_ _at commit_ _<u>[af8a4c9. The data is now signed using the](https://github.com/scroll-tech/scroll/pull/620/commits/af8a4c9ac808bf70e27c4d3ef4ede18ede565075)</u>_

_EIP-712 standard. Expiration and replayability were addressed by adding a deadline and nonce._


Scroll Layer 1 Audit − Medium Severity − 17


### **M-02 Lack of Upgradeability Storage Gaps**

Throughout the codebase, these base contracts are inherited into upgradeable contracts:








```
ScrollMessengerBase
ScrollGatewayBase
L1ERC20Gateway

```


If storage variables are added to these base contracts without accounting for a storage gap

towards the child contracts, a storage collision may cause contracts to malfunction and

compromise other functionalities.


Consider adding a <u>[gap variable](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps)</u> to future-proof base contract storage changes and be safe

against storage collisions.


**_Update:_** _Resolved in_ _<u>[pull request #618](https://github.com/scroll-tech/scroll/pull/618)</u>_ _at commit_ _<u>[2395883.](https://github.com/scroll-tech/scroll/pull/618/commits/23958838c51170ca7e680ff405f3c68dfee4e7b9)</u>_

### **M-03 WithdrawTrieVerifier Proves** **Intermediate Nodes**


The <u>`[WithdrawTrieVerifier](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/WithdrawTrieVerifier.sol)`</u> <u>library</u> is a Merkle trie verifier. It implements a function to

check that a message hash along with a Merkle proof hashes to the given root. This root hash

is acquired by consecutively hashing the provided message hash with the hashes from the

proof. However, since the length of the proof is not checked, the following problem arises.


The initially provided message hash can be hashed with the first hash of the proof, thereby

giving an intermediate node of the trie. This can then be used with a shortened proof to pass

the verification, which may lead to replayability. While the forgeability of an intermediate node

was not identified as an issue for this <u>[library's usage, it is still an issue for the stand-alone](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L142)</u>

library.


Consider adding a length check of the proof to prevent the verification of intermediate nodes

with a shortened proof.


**_Update:_** _Resolved in_ _<u>[pull request #619](https://github.com/scroll-tech/scroll/pull/619)</u>_ _at commit_ _<u>[22b30ba. The issue was not addressed in the](https://github.com/scroll-tech/scroll/pull/619/commits/22b30bac6d6611c585d16a56bf8682c0b094cabe)</u>_

_code, but the limitations and how the library should be used were added to the NatSpec of the_

_function._


Scroll Layer 1 Audit − Medium Severity − 18


## **Low Severity**

### **L-01 Batch Reverting Can Pause Finalization**

The `ScrollChain` contract allows `sequencer` s to <u>[commit new batches](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L153)</u> of L2 blocks on L1.

It also allows the `owner` of the contract to <u>revert a</u> <u>`[_count](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L247)`</u> <u>[amount of unfinalized batches.](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L247)</u>


However, as the `_count` parameter can be less than the number of remaining unfinalized

batches, the `owner` can create gaps in the array of batches. With consecutive batches being

committed, this gap can be filled until the first old batch. For instance:

```
1. [ b0 b1 b2 b3 b4 b5 ] initial batches
2. [ b0 b1 b2  0  0 b5 ] owner reverted index 3, count 2
3. [ b0 b1 b2 b3' b4' b5 ] sequencer commits new batches

```

This creates two problems:


1. The `b5` batch cannot be overwritten with `b5'` because the <u>[batch index's hash value is](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L185)</u>

<u>[non-zero.](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L185)</u>

2. The `b5` batch cannot be finalized because it is likely that the <u>[finalized state root of its](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L292)</u>

<u>[parent batch does not match.](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L292)</u>


Hence, this will lead to downtime in block finalization until the `b5` block is reverted.


In order to prevent the creation of gaps and having the `owner` manually intervene multiple

times to fix the chain, consider checking that the `batch index + count` batch is indeed

the latest committed batch to be reverted, for instance by checking that the next

`committedBatches` value is zero. Otherwise, consider using an array type and popping

elements from the end, as long as the finalized batches are left untouched.


**_Update:_** _Resolved in_ _<u>[pull request #634](https://github.com/scroll-tech/scroll/pull/634)</u>_ _at commit_ _<u>[c7de22d.](https://github.com/scroll-tech/scroll/pull/634/commits/c7de22d1c1f628ed742c8c53217a17a269518354)</u>_

### **L-02 Initialization Not Disabled for** **Implementation Contracts**


Throughout the codebase, implementation contracts are used behind proxies for

upgradeability. Hence, many contracts have an `initialize` function that sets up the proxy.

It is a good practice to not leave implementation contracts uninitialized. Hence, consider


Scroll Layer 1 Audit − Low Severity − 19


calling the <u>`[_disableInitializers](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/proxy/utils/Initializable.sol#L145)`</u> <u>function</u> of the inherited `Initializable` contract in

the `constructor` to prevent the initialization of the implementation contract.


**_Update:_** _Resolved in_ _<u>[pull request #639](https://github.com/scroll-tech/scroll/pull/639)</u>_ _at commit_ _<u>[d1b7719.](https://github.com/scroll-tech/scroll/pull/639/commits/d1b77199a9306a051569c69ff8f55a4f48cc2f1e)</u>_

### **L-03 Code Redundancy**


Throughout the codebase, there are multiple instances of code redundancy, which is error
prone and hinders the codebase's readability:


   - The <u>`[L1ScrollMessenger](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L56-L68)`</u> and <u>`[ScrollGatewayBase](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L38-L50)`</u> contracts implement a

`nonReentrant` modifier. Instead, consider utilizing the

<u>`[ReentrancyGuardUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.9/contracts/security/ReentrancyGuardUpgradeable.sol)`</u> <u>contract</u> of the OpenZeppelin library which is a

dependency in use. The same holds for the <u>`[OwnableBase](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/common/OwnableBase.sol)`</u> <u>contract</u> and

OpenZeppelin's <u>`[Ownable](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/merge/release-v4.9/contracts/access/Ownable.sol)`</u> <u>contract. The reimplementation of such safety mechanisms is</u>

generally discouraged. In both cases, make sure to initialize the contracts properly if they

are used for upgradeable contracts.

   - The <u>`[IERC20Metadata](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/interfaces/IERC20Metadata.sol#L5)`</u> <u>interface</u> could also be used from the <u>[OpenZeppelin library.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/extensions/IERC20Metadata.sol)</u>

   - The <u>`[IScrollERC20](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/IScrollERC20.sol#L11)`</u> and <u>`[IScrollERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/IScrollERC20Upgradeable.sol#L11)`</u> interfaces are the same

interface - consider removing one of them.

   - The <u>`[isContract](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20.sol#L74)`</u> <u>function</u> of the `ScrollStandardERC20` contract could also be

realized with `address.code.length > 0` . For better gas efficiency, it is

recommended to use this with a Solidity version higher than 0.8.1.

   - The <u>`[L1ScrollMessenger](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L221)`</u> and <u>`[L2ScrollMessenger](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/L2ScrollMessenger.sol#L259)`</u> both implement the

`setPause` function but inherit from <u>`[ScrollMessengerBase](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/gateway/ScrollGatewayBase.sol)`</u> . Consider moving the

`setPause` function to the base contract.

   - The <u>`[onlyMessenger](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L52)`</u> <u>modifier</u> of the `ScrollGatewayBase` contract is unused.

Consider removing it.


Consider applying these code changes to improve the quality of the codebase. Make sure to

have all of these changes tested with an extensive test suite.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_This will be fixed later if we have more bandwidth._


Scroll Layer 1 Audit − Low Severity − 20


### **L-04 Lost Funds in Messenger Contracts**

The `ScrollMessengerBase` contract has a <u>`[receive](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/ScrollMessengerBase.sol#L56)`</u> <u>function</u> that does not have any code

implemented. There is no use case for the messenger contracts to receive any ETH outside of

the payable functions. Instead, users might accidentally send ETH to it. Hence, consider

removing the `receive` function.


**_Update:_** _Resolved in_ _<u>[pull request #637](https://github.com/scroll-tech/scroll/pull/637)</u>_ _at commit_ _<u>[c89704c. The](https://github.com/scroll-tech/scroll/pull/637/commits/c89704c5713f31083ba8f709bd74053e92d71708)</u>_ _`receive`_ _function is needed_

_to provide an equal balance in the messenger contracts after initialization of the rollup. A_

_restriction was added to only be callable by the contract owner._

### **L-05 Outdated OpenZeppelin Library Version**


The <u>[OpenZeppelin library version in use](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/package.json#L56-L59)</u> is `^4.5.0` and `^4.5.2` for the upgradeable

contracts, while the <u>[current release version](https://github.com/OpenZeppelin/openzeppelin-contracts/releases)</u> is `4.9.2` . Consider updating the dependency to

be safe against any bugs that were patched in the meantime. Make sure to have an extensive

test suite testing the integration of the library modules, as some changes may break the

existing functionality.


**_Update:_** _Resolved in_ _<u>[pull request #622](https://github.com/scroll-tech/scroll/pull/622)</u>_ _at commit_ _<u>[6a01399.](https://github.com/scroll-tech/scroll/pull/622/commits/6a01399ad6544ed37261bf7bb7c6ae45390e0275)</u>_

### **L-06 Missing and Misleading Documentation**


Throughout the codebase, there are various instances of misleading documentation:


   - The `burn` function of the <u>`[IScrollERC20](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/IScrollERC20.sol#L36)`</u> and <u>`[IScrollERC20Upgradeable](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/IScrollERC20Upgradeable.sol#L36)`</u>

interface defines the `_amount` parameter as the "token to mint" although it should say

burn.

  - The comment in the `L1CustomERC20Gateway` contract saying that <u>[the message is](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L142)</u>

<u>passed to</u> <u>`[L2StandardERC20Gateway](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L142)`</u> should be about `L2CustomERC20Gateway` .

   - The NatSpec comments "Update layer 2 to layer 2" of the <u>`[L1ERC1155Gateway](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L138)`</u> and

<u>`[L1ERC721Gateway](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC721Gateway.sol#L133)`</u> should be "Update layer 1 to layer 2".

   - The `UpdateTokenMapping` event of the `L1ERC1155Gateway` contract <u>[documents](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L29)</u>

<u>[the L1 token twice, while the second one should be the L2 token.](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L29)</u>

   - The `L1ETHGateway` contract <u>[mentions](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ETHGateway.sol#L16)</u> that "The deposited ETH tokens are held in this

gateway", however, ETH is actually forwarded to the `L1ScrollMessenger` contract.

   - The revert string of <u>["only EOA"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L264)</u> in the `L1MessageQueue` contract is not accurate for the

check it performs, because contract accounts fulfill this condition during the construction

time.


Scroll Layer 1 Audit − Low Severity − 21


   - In the `IL2ETHGateway` the `gasLimit` parameter of the <u>[withdraw functions](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/gateways/IL2ETHGateway.sol#L28-L53)</u> is said to

be optional, while the same parameter in the ERC-20, ERC-721, and ERC-1155

corresponding interfaces is said to be unused. Looking into <u>[the relayer code, the](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/bridge/watcher/l2_watcher.go#L353-L362)</u>

parameter is indeed unused. Hence, consider correcting the ETH gateway

documentation.

   - In the `PatriciaMerkleTrieVerifier` library, the comment <u>["calldata offset | value](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L234)</u>

<u>[length"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L234)</u> should be reversed to "value length | calldata offset" as correctly pointed out in

the <u>[comments above.](https://github.com/scroll-tech/scroll/blob/646ecb0124020e27cb261100d0dfa0e9e7513730/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L202)</u>

   - In the `ScrollChain` contract, <u>["lastBlockHash"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#LL133C52-L133C65)</u> should be "parentBatchHash" to be

consistent.

   - In the `ScrollChain` contract the comment "see the encoding in comments of

`commitBatch` " on lines <u>[63](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/IScrollChain.sol#L63)</u> and <u>[68](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/IScrollChain.sol#L68)</u> should refer to <u>`[BatchHeaderV0Codec](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/codec/BatchHeaderV0Codec.sol)`</u> instead.

   - A comment in the `ScrollChain` contract says <u>["check genesis batch header length",](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L125)</u>

although the following line of code checks that the `_stateRoot` function parameter is

non-zero.

   - In the `L2GasPriceOracle` contract, the `setL2BaseFee` function is commented as

<u>["Allows the owner to modify the l2 base fee", although the function is callable by](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L2GasPriceOracle.sol#L128)</u>

whitelisted accounts which is a separate role from the owner.

   - The <u>`[ScrollMessengerBase](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/ScrollMessengerBase.sol#L64)`</u> and <u>`[L1ScrollMessenger](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L76)`</u> contracts' NatSpec

suggests that the fee vault is a custom contract on L1, while it is actually an EOA or

multisig. Consider clarifying this in the documentation.

   - The `L1ScrollMessenger` contract documents that it can "drop expired message due

to sequencer problems", while neither that functionality nor timestamps are

implemented.


Besides correcting the above documentation errors, consider thoroughly documenting all

functions (and their parameters) that are part of any contract's public API. Functions

implementing sensitive functionality, even if not public, should be clearly documented as well.

The following instances are concrete examples of missing documentation:


   - In the `ChunkCodec` library, L2 transactions are <u>[encoded as part of the chunks and](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/codec/ChunkCodec.sol#LL14C9-L14C23)</u>

<u>added as</u> <u>`[bytes](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/codec/ChunkCodec.sol#LL14C9-L14C23)`</u> <u>at the end. However, the encoding of</u> `l2Transactions` is not

documented, except for a <u>[comment](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/codec/ChunkCodec.sol#L114)</u> indicating that the first 4 bytes of each transaction

are its length. Consider documenting it.

   - The <u>`[_gasLimit](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/oracle/IGasOracle.sol#L14)`</u> <u>parameter</u> of the `IGasOracle.estimateMessageFee` function is

not documented.

   - The purpose of <u>`[External.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/External.sol#L7)`</u> should be documented.


When writing docstrings, consider following the <u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/develop/natspec-format.html)</u>

(NatSpec).


Scroll Layer 1 Audit − Low Severity − 22


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_This will be fixed later if we have more bandwidth._

### **L-07 Lack of Logs on Sensitive Actions**


In the <u>`[FeeVault](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/FeeVault.sol#L97-L111)`</u> <u>contract, the</u> `owner` role can change the minimum value to withdraw, the

`recipient`, and `messenger` address. However, none of the functions emit an event.

Although these functions will not interfere with users' actions, it could be useful to log the

changes for debugging unexpected behaviors or potential hacks.


Moreover, the <u>`[DeployToken](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/IScrollStandardERC20Factory.sol#L6)`</u> <u>event</u> is defined in the `IScrollStandardERC20Factory`

interface but it is never emitted in the <u>`[deployL2Token](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20Factory.sol#L35-L39)`</u> <u>function</u> of the

`ScrollStandardERC20Factory` contract.


Consider adding events to such functions.


**_Update:_** _Resolved in_ _<u>[pull request #623](https://github.com/scroll-tech/scroll/pull/623)</u>_ _at commit_ _<u>[baa48b7.](https://github.com/scroll-tech/scroll/pull/623/commits/baa48b7018b2b4ca4ec39a94bbdfae82fabf74f5)</u>_

### **L-08 Batch Events Lack Information**


The `CommitBatch`, `RevertBatch`, and `FinalizeBatch` events of the <u>`[IScrollChain](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/IScrollChain.sol#L10-L22)`</u>

<u>[interface](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/IScrollChain.sol#L10-L22)</u> give crucial updates about the state of L2 finalization on L1. However, while the

<u>`[ScrollChain](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/IScrollChain.sol#L28-L42)`</u> <u>`[view](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/IScrollChain.sol#L28-L42)`</u> <u>functions</u> work by querying the `batchIndex`, the events do not emit

the `batchIndex` information.


Consider emitting the indexed `batchIndex` together with the hash per event to help facilitate

querying important information.


**_Update:_** _Resolved in_ _<u>[pull request #624](https://github.com/scroll-tech/scroll/pull/624)</u>_ _at commit_ _<u>[7e8bf3a.](https://github.com/scroll-tech/scroll/pull/624/commits/7e8bf3a7c49c4aa355a3060c3e11020e505badc8)</u>_

### **L-09 User Can Derive Call to Be on Behalf of the** **`L1ScrollMessenger`**


The <u>`[L1ScrollMessenger](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L28)`</u> <u>contract</u> enables users to <u>[send messages](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L100-L118)</u> to L2. To pay for the

fees or any value sent with the message, ETH is provided along with the call. Because the

<u>[restriction](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L249)</u> only asserts that the value needed is less than or equal to the one sent, the protocol

<u>[refunds any overpayment to the](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L271)</u> <u>`[_refundAddress](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L271)`</u> <u>address.</u>


Scroll Layer 1 Audit − Low Severity − 23


However, the `_refundAddress` address does not have any restrictions. As there are

currently many access-controlled functionalities which only allow the `L1ScrollMessenger`

contract to interact with them (e.g., <u>[[1]](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L243)</u> and <u>[[2]), a malicious user might take advantage of the](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/gateway/ScrollGatewayBase.sol#L52)</u>

refund process to execute access-controlled functionalities in their `receive` functions. When

relaying a message from L2 to L1, a <u>[few checks](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L148-L149)</u> are done to prevent this type of attack.


Even though currently there are no implementations at risk, it is always important to reduce the

attack surface for future versions of this upgradeable contract. Hence, consider restricting the

`_refundAddress` to addresses that do not allow the `L1ScrollMessenger` contract to

execute access-controlled functionalities.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_We do not think this needs to be fixed at the moment._

### **L-10 Unpinned Compiler Version**


Valid compiler versions are set via the `pragma solidity` tag at the top of Solidity files. Most

of the codebase provides <u>`[pragma solidity ^0.8.0](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L3)`</u> as the compiler pragma. This pragma

requires the compiler used to be at least 0.8.0 and lower than 0.9.0.


Since the compiler is not pinned to a specific version, it is possible that tests will target a

different version than the one deployed, rendering the test suite inadequate. It also allows new,

unreleased compilers to be valid. Although unlikely, new compilers may not support all the

code written for current compilers.


Compiler bugs are most commonly found within one to two versions of their introduction. This

means the safest, most up-to-date compiler version is a few versions behind the latest unless

the code is affected by a bug that was recently fixed. For example, Solidity version 0.8.13 was

found to suffer from <u>[a bug](https://blog.soliditylang.org/2022/06/15/inline-assembly-memory-side-effects-bug/)</u> where under certain conditions some assembly instructions are

ignored by the compiler. While the codebase in its current state does not seem to be affected

by this specific bug, pinning the version reduces the odds of such vulnerabilities affecting it in

the future.


Moreover, the <u>`[RollupVerifier](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/RollupVerifier.sol#L2)`</u> <u>library</u> makes use of a different pragma ( `>=0.4.16`

`<0.9.0` ), which is inconsistent with the one used in the rest of the codebase.


To ensure the released version matches the tested version, consider pining the Solidity

compiler of the entire codebase to a specific version, preferably slightly behind the most up-to
date version (currently 0.8.20).


Scroll Layer 1 Audit − Low Severity − 24


**_Update:_** _Resolved in_ _<u>[pull request #636](https://github.com/scroll-tech/scroll/pull/636)</u>_ _at commit_ _<u>[6d88f92. The Scroll team stated:](https://github.com/scroll-tech/scroll/pull/636/commits/6d88f92931dd55cc6b9230f0f433f5686b6fce85)</u>_


_The version of all deployable contracts is pinned with_ _`=0.8.16`_ _. For interfaces,_

_libraries, and abstract contracts,_ _`^0.8.16`_ _is used._

## **Notes & Additional** **Information**

### **N-01 Constant Not Using UPPER_CASE Format**


In <u>`[AddressAliasHelper.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/common/AddressAliasHelper.sol)`</u>, the <u>`[offset](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/common/AddressAliasHelper.sol#L6)`</u> <u>[constant](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/common/AddressAliasHelper.sol#L6)</u> is not declared using `UPPER_CASE`

format.


According to the <u>[Solidity Style Guide, constants should be named with all capital letters with](https://docs.soliditylang.org/en/v0.8.20/style-guide.html#constants)</u>

underscores separating words. For better readability, consider following this convention.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-02 Error-Prone Call Encoding**


Throughout the codebase, calls are either encoded with `abi.encodeWithSignature` or

`abi.encodeWithSelector`, both of which are prone to type or typo errors. Instead,

consider using the <u>`[abi.encodeCall](https://docs.soliditylang.org/en/v0.8.20/cheatsheet.html#abi-encoding-and-decoding-functions)`</u> <u>function</u> that protects against both mistakes. When

making this change, use Solidity version 0.8.13 or higher, due to a <u>[bug encoding literals.](https://blog.soliditylang.org/2022/03/16/encodecall-bug/)</u>


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._


Scroll Layer 1 Audit − Notes & Additional Information − 25


### **N-03 Events Should Emit Old and New Value**

There are events in the codebase that would benefit from emitting old and new values for the

sake of traceability:


   - The events in the <u>`[IL1GatewayRouter](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/IL1GatewayRouter.sol)`</u> and <u>`[IL2GatewayRouter](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/gateways/IL2GatewayRouter.sol#L8)`</u> interfaces.


   - The `UpdateTokenMapping` events in the L1 and L2 gateway contracts for the address

of the counterpart token.


   - The <u>`[L2BaseFeeUpdated](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L2GasPriceOracle.sol#L23)`</u> <u>event</u> of the `L2GasPriceOracle` contract for the

`l2BaseFee` value.


Consider emitting the respective old values to enable traceability for off-chain applications and

facilitate monitoring rules for suspicious activity.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-04 Events Split Between Contracts and** **Interfaces**


Throughout the codebase, events are placed in both contracts and interfaces. With the current

pattern, events on authorized actions are placed in the contracts while user-relevant events are

placed in the interfaces, negatively impacting the codebase's readability. Consider moving the

events from the contracts to their respective interfaces. Furthermore, to facilitate monitoring

capabilities (which rely on checking events) it is easier to compile the interfaces and obtain

their ABI when they are all located in one place.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-05 Gas Optimizations**


There are a few instances in the codebase where gas consumption can be reduced. For

instance:


   - In `ScrollChain.sol`, the <u>`[lastFinalizedBatchIndex](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L305)`</u> <u>check</u> can be moved up to

fail early.


Scroll Layer 1 Audit − Notes & Additional Information − 26


- Consider using the `delete` keyword instead of overwriting variables to their default.

  - In `ScrollChain.sol` <u>`[committedBatches](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L260)`</u> is overwritten.

  - In `L1MessageQueue.sol` <u>`[messageQueue](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L286)`</u> is overwritten.




- Consider using `++i` instead of `i++` for `for` loop increments.




- During the initialization of the `L1ScrollMessenger` contract, the



`xDomainMessageSender` variable is set <u>[a second time](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L92)</u> after the <u>`[_initialize](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/ScrollMessengerBase.sol#L49)`</u>

<u>[function](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/ScrollMessengerBase.sol#L49)</u> of the base contract

   - In the `L1ScrollMessenger` the `relayMessageWithProof` function <u>[keeps track of](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L166-L167)</u>

<u>[all relay message calls](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L166-L167)</u> by bundling the information into an id and setting it in a mapping.

This seems to be obsolete code and an unnecessary storage write.

   - Consider bumping the Solidity version to at least 0.8.1 where `address.code.length`

is used, to not copy the code into memory. For more information see the <u>[release](https://blog.soliditylang.org/2021/01/27/solidity-0.8.1-release-announcement/#code-length-shortcut)</u>

<u>[announcement.](https://blog.soliditylang.org/2021/01/27/solidity-0.8.1-release-announcement/#code-length-shortcut)</u>

   - The double hashing of the `_l1Token` address in the <u>`[_getSalt](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20Factory.sol#L41)`</u> and

<u>`[getL2ERC20Address](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1StandardERC20Gateway.sol#L75)`</u> function is unnecessary since `_gateway` / `counterpart` and

`_l1Token` are both fixed-size values that cannot result in a hash collision for different

values.

   - In `EnforcedTxGateway`, the `messageQueue` storage variable is read onto the stack

to save gas, but then again <u>[read from storage](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/EnforcedTxGateway.sol#L85)</u> a second time.


Consider making the above changes to reduce gas consumption.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-06 Inconsistent Integer Base in Inline Assembly**


The codebase makes use of inline assembly for multiple features. When performing these

calculations, a decimal and hexadecimal integer base is used interchangeably. Mostly as `32`

and `0x20` to calculate word offsets in memory. Consider sticking to one integer base to ease

readability and prevent calculation errors.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._


Scroll Layer 1 Audit − Notes & Additional Information − 27


### **N-07 Lack of Indexed Event Parameters**

Throughout the codebase, several events do not have their parameters indexed. For instance:


   - The <u>`[UpdateFeeVault](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/EnforcedTxGateway.sol#L20)`</u> event

   - The `UpdateTokenMapping` events <u>[[1]](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC1155Gateway.sol#L30)</u> <u>[[2]](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC721Gateway.sol#L30)</u> <u>[[3]](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L31)</u>

   - The events in <u>`[L1MessageQueue](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L20-L33)`</u>

   - The events in <u>`[L2GasPriceOracle](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L2GasPriceOracle.sol#L16-L30)`</u>

   - The <u>`[UpdateVerifier](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L30)`</u> event

   - The <u>`[Withdrawal](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/FeeVault.sol#L40)`</u> event

   - The <u>`[UpdateFeeVault](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/ScrollMessengerBase.sol#L18)`</u> event


Consider <u>[indexing event parameters](https://docs.soliditylang.org/en/v0.8.20/contracts.html#events)</u> to improve the ability of off-chain services to search and

filter for specific events.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-08 Multiple Event Emissions Can Confuse Off-** **Chain Clients**


Throughout the codebase, there are multiple `onlyOwner` -protected functions that set

sensitive addresses or values. When passing the same address or value as the one the variable

currently has, the triggered event will suggest that the variable has changed its value, creating

confusion for off-chain clients potentially reacting to it.


Consider validating the current setting in storage before setting the variable with the passed

value and emitting the event.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-09 No Function to Remove a Custom Setting**


In the `SimpleGasOracle` contract, message fees are estimated based on a fee

configuration. This configuration can be set by the owner for default values but also <u>[per sender](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/oracle/SimpleGasOracle.sol#L92)</u>

<u>[for a custom configuration. However, there is no functionality to return from a custom](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/oracle/SimpleGasOracle.sol#L92)</u>

configuration to the default one. While the custom configuration could be changed to match


Scroll Layer 1 Audit − Notes & Additional Information − 28


the default, it would not change along with it. Consider being more flexible and future-proof by

adding a `removeCustomFeeConfig` function instead of having to implement this through a

more gas-consuming contract upgrade.


Further, in the `L1{CustomERC20|ERC721|ERC1155}Gateway`, the owner can update the

token mapping of L1 to L2 contracts. However, this mapping is not resettable back to address

zero to <u>[prevent depositing](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L121-L122)</u> or <u>[withdrawing](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1CustomERC20Gateway.sol#L82-L83)</u> such tokens in cases of deprecation or scams. As

such, consider allowing the mapping to be set to zero.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-10 SimpleGasOracle Is Not Used**


The <u>`[SimpleGasOracle](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/oracle/SimpleGasOracle.sol)`</u> <u>contract</u> does not find any utility in the rest of the codebase and

appears to be obsolete. Consider removing it.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be deleted later on._

### **N-11 Token Counterpart Address in WETH** **Gateway Can Be Misleading**


[To align with the inherited L1 and L2 ERC-20 gateway interfaces, the WETH gateways ([1], [2])](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1WETHGateway.sol#L69)

implement functions to fetch the L1 and L2 token counterparts as `getL1ERC20Address` and

`getL2ERC20Address` . But, since the WETH gateway only interacts with one token on each

layer, these functions just return the hardcoded address regardless of what token is queried

through the function parameter.


This could cause confusion since only one L1 WETH token maps the L2 token and vice versa.

However, the function could suggest that other tokens also fulfill this mapping.


Even though the protocol expects users to interact with the gateways by calling the

`L1GatewayRouter` contract, it is possible for users to bypass this contract and reduce the

gas cost. For that reason, consider returning the zero address if the queried token does not

match the WETH token of the respective layer.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


Scroll Layer 1 Audit − Notes & Additional Information − 29


_This is not a priority at the time. It will be addressed later on._

### **N-12 Typographical Errors**


Throughout the codebase there are multiple instances of typographical errors:


   - <u>["called by a list of validator"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#LL77C18-L77C92)</u> should be "called by a list of validators".

  - "choosen" <u>[[1]](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L372)</u> <u>[[2]](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L412)</u> should be "chosen".

   - <u>["return true is"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L2/L2ScrollMessenger.sol#L119)</u> should be "return true if"

   - "The the" <u>[[1]](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/docs/TokenBridge.md?plain=1#L37)</u> <u>[[2]](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/codec/BatchHeaderV0Codec.sol#L69)</u> should be "The".

   - <u>["Return the message of in](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/IL1MessageQueue.sol#L43)</u> <u>`[queueIndex](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/IL1MessageQueue.sol#L43)`</u> <u>"</u> should be "Return the message at

`queueIndex`.

   - <u>"All deposited Ether (including</u> <u>`[WETH](https://github.com/scroll-tech/scroll/blob/f414523045310d8ed5975013342e1d6eb9b5266b/contracts/src/L1/L1ScrollMessenger.sol#L26)`</u> <u>[deposited throng](https://github.com/scroll-tech/scroll/blob/f414523045310d8ed5975013342e1d6eb9b5266b/contracts/src/L1/L1ScrollMessenger.sol#L26)</u> <u>`[L1WETHGateway](https://github.com/scroll-tech/scroll/blob/f414523045310d8ed5975013342e1d6eb9b5266b/contracts/src/L1/L1ScrollMessenger.sol#L26)`</u> <u>) will locked in</u>

<u>[this contract."](https://github.com/scroll-tech/scroll/blob/f414523045310d8ed5975013342e1d6eb9b5266b/contracts/src/L1/L1ScrollMessenger.sol#L26)</u> should be "through" and "will be locked".

   - "transfered" should be "transferred" (throughout the whole codebase).

   - <u>["recieve"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1ERC20Gateway.sol#L51)</u> should be "receive".

   - <u>["addess"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1GatewayRouter.sol#L27)</u> should be "address".

   - <u>["malicous"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L492)</u> should be "malicious".

   - <u>["continous"](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/verifier/PatriciaMerkleTrieVerifier.sol#L202)</u> should be "continuous".


Consider fixing these and any other typographical errors to improve the readability of the

codebase.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-13 Unintuitive Bitmap Ordering and Type for** **Skipped Messages**


In the `ScrollChain` contract, as a new batch is committed, L1 messages can be skipped

from being included in the batch. The indication of whether a message should be skipped or

not is realized through a bitmap of type `bytes` . However, the dynamic bytes type is expected

to have a <u>[length of](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/codec/BatchHeaderV0Codec.sol#L36)</u> <u>`[k](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/codec/BatchHeaderV0Codec.sol#L36)`</u> <u>words. Thus, a</u> `bytes32[]` array would be a more suitable type for this

parameter.


Further, while the `bytes` value is processed <u>[from left to right](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L502)</u> as words, the bits are processed

<u>[from right to left, giving an unintuitive ordering of skipped messages.](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L505)</u>


Scroll Layer 1 Audit − Notes & Additional Information − 30


Consider sticking to a dynamic bytes value of arbitrary length that is processed from left to

right, or changing the type to a `bytes32` array.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-14 WETH Is Passed as a Parameter**


The WETH address is being passed as a parameter in the <u>`[constructor](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1WETHGateway.sol#L43)`</u> of the

`L1WETHGateway` contract. However, as the address could be considered a constant in the

ecosystem, consider hard-coding the address with a constant variable in the implementation to

decrease the likelihood of errors when deploying the contract.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-15 Unused Imports**


Throughout the codebase, there are imports that are unused and could be removed. For

instance:


   - Import <u>`[ProxyAdmin](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/External.sol#L5)`</u> of <u>`[External.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/External.sol)`</u>

   - Import <u>`[TransparentUpgradeableProxy](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/External.sol#L6)`</u> of <u>`[External.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/External.sol)`</u>

   - Import <u>`[AddressAliasHelper](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L13)`</u> of <u>`[L1ScrollMessenger.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol)`</u>

   - Import <u>`[IL2GatewayRouter](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1GatewayRouter.sol#L7)`</u> of <u>`[L1GatewayRouter.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1GatewayRouter.sol)`</u>

   - Import <u>`[IScrollGateway](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1GatewayRouter.sol#L8)`</u> of <u>`[L1GatewayRouter.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1GatewayRouter.sol)`</u>

   - Import <u>`[IL1ScrollMessenger](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1GatewayRouter.sol#L9)`</u> of <u>`[L1GatewayRouter.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/gateways/L1GatewayRouter.sol)`</u>


Consider removing unused imports to improve the overall clarity and readability of the

codebase.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._


Scroll Layer 1 Audit − Notes & Additional Information − 31


### **N-16 Unused Named Return Variable**

Named return variables are a way to declare variables that are meant to be used within a

function's body for the purpose of being returned as the function's output. They are an

alternative to explicit in-line `return` statements.


In <u>`[ScrollStandardERC20.sol](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20.sol)`</u>, there are two instances of unused named return variables:


   - The <u>`[success](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20.sol#L57)`</u> return variable in the `transferAndCall` function

   - The <u>`[hasCode](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20.sol#L74)`</u> return variable in the `isContract` function


Consider using or removing any unused named return variables. Moreover, consider keeping a

consistent style throughout the codebase regarding the usage of named return variables.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-17 Use Custom Errors**


Throughout the codebase, the code makes use of <u>`[require](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L139)`</u> <u>[statements with error strings](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L139)</u> to

describe the reasons for reverting.


However, since Solidity version 0.8.4, <u>[custom errors](https://blog.soliditylang.org/2021/04/21/custom-errors/)</u> provide a cleaner and more <u>[cost-efficient](https://blog.openzeppelin.com/defining-industry-standards-for-custom-error-messages-to-improve-the-web3-developer-experience)</u>

way to explain to users why an operation failed versus using `require` and `revert`

statements with custom error strings.


For better conciseness, consistency, and gas savings, consider replacing hard-coded

`require` and `revert` messages with custom errors.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

### **N-18 Variable Name Inconsistency**


Throughout the codebase, some variables referring to the same matter have different names.

For instance, the `ScrollChain` contract address in the `L1ScrollMessenger` contract is

named <u>`[rollup](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/L1ScrollMessenger.sol#L43)`</u>, while in the `L1MessageQueue` contract, it is <u>`[scrollChain](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/L1MessageQueue.sol#L43)`</u> .


Scroll Layer 1 Audit − Notes & Additional Information − 32


For better readability, consider giving variables the same name if they refer to the same

contract.


**_Update_** _: Acknowledged, will resolve. The Scroll team stated:_


_This is not a priority at the time. It will be addressed later on._

## **Client Reported**

### **CR-01 Missing Chain ID Allows Reuse of Proofs**


In the `ScrollChain` contract, during the finalization of a batch, <u>[the proof is checked against](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L297-L301)</u>

<u>[a hash](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/L1/rollup/ScrollChain.sol#L297-L301)</u> over:


   - The previous state root of the L2 chain

   - The post-state root of the L2 chain

   - The withdraw root for L2 to L1 messaging

   - The data hash of the batch summarizing the batch's chunks of blocks and transactions


Similar conditions could be met in the case of the Scroll rollup being cloned or forked, although

the proof was only meant for one particular chain. Hence, that proof can potentially be reused.


**_Update_** _: Resolved. The Scroll team fixed this bug at commit_ _<u>[55f5857](https://github.com/scroll-tech/scroll/pull/517/commits/55f5857aebf1ae0453d3f45a71fb9c4125877e93)</u>_ _of_ _<u>[PR#517](https://github.com/scroll-tech/scroll/pull/517)</u>_ _by adding the_

_L2 chain ID to the hashed parameters that the proof is checking against._


Scroll Layer 1 Audit − Client Reported − 33


## **Recommendations**

### **ERC-20 Factory Design**

Tokens can be bridged in a custom and standard way. For the latter, the

<u>`[ScrollStandardERC20](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20.sol)`</u> is the default implementation that will represent the L1 token on L2.

This is realized with the <u>`[Clones](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/proxy/Clones.sol)`</u> <u>library</u> and the <u>[EIP-1167](https://eips.ethereum.org/EIPS/eip-1167)</u> standard. It works by deploying a

minimal proxy that delegates its calls into the token implementation and that is initialized as the

token instance.


These standard tokens are not upgradeable, which comes with a trade-off. On the one hand, it

is more secure since the logic can not be changed. On the other hand, it is less future-proof

meaning that standards like ERC-677 - which is not a finalized EIP - might at some point be

overruled by a new standard that finds mass adoption.


An alternative future-proof factory design would be the <u>[Beacon proxy pattern. In a similar](https://docs.openzeppelin.com/contracts/4.x/api/proxy#beacon)</u>

approach, the `BeaconProxy` will be the token instance, but then fetches the implementation

contract to delegate into from a single `UpgradeableBeacon` contract. This enables

upgrading all tokens in one transaction.


Regarding the security implications of upgradeable contracts, it is crucial to have the

`UpgradeableBeacon` secured through a timelock, multisig, and cold wallets.


**_Update:_** _Acknowledged. The Scroll team stated:_


_For safety concerns, we prefer the contract to be non-upgradeable._

### **ERC-165 Support**


While most of the codebase includes custom contracts which do not implement a specific

standard, the <u>`[ScrollStandardERC20](https://github.com/scroll-tech/scroll/blob/3bc8a3f5c6ac816ddffadca41024331dcf4d3064/contracts/src/libraries/token/ScrollStandardERC20.sol)`</u> <u>contract</u> is implementing the ERC-20 and ERC-677

standards. As such, it makes sense to also add ERC-165 support to it to enable other parties

to identify its interface and the standard it implements.


**_Update:_** _Acknowledged. The Scroll team stated:_


_Makes sense, we will support it if we have time._


Scroll Layer 1 Audit − Recommendations − 34


### **Testing Coverage**

Due to the complex nature of the system, we believe this audit would have benefitted from

more complete testing coverage.


While insufficient testing is not necessarily a vulnerability, it implies a high probability of

additional hidden vulnerabilities and bugs. Given the complexity of this codebase and the

numerous interrelated risk factors, this probability is further increased. Testing provides a full

implicit specification along with the expected behaviors of the codebase, which is especially

important when adding novel functionalities. A lack thereof increases the chances that

correctness issues will be missed. It also results in more effort to establish basic correctness

and increases the effort spent exploring edge cases, thereby increasing the chances of missing

complex issues.


Moreover, the lack of repeated automated testing of the full specification increases the

chances of introducing breaking changes and new vulnerabilities. This applies to both

previously audited code and future changes to current code. This is particularly true in this

project due to the pace, extent, and complexity of ongoing and planned changes across all

parts of the stack (L1, L2, relayer, and zkEVM). Under-specified interfaces and assumptions

increase the risk of subtle integration issues, which testing could reduce by enforcing an

exhaustive specification.


We recommend implementing a comprehensive multi-level test suite consisting of contract
level tests with more than 90% coverage, per-layer deployment and integration tests that test

the deployment scripts as well as the system as a whole, per-layer fork tests for planned

upgrades and cross-chain full integration tests of the entire system. Crucially, the test suite

should be documented in a way so that a reviewer can set up and run all these test layers

independently from the development team. Some existing examples of such setups can be

suggested for use as reference in a follow-up conversation. Implementing such a test suite

should be a very high priority to ensure the system's robustness and reduce the risk of

vulnerabilities and bugs.


**_Update:_** _Acknowledged. The Scroll team stated:_


_More tests will be added later._

### **Monitoring Recommendations**


While audits help in identifying code-level issues in the current implementation and potentially

the code deployed in production, the Scroll team is encouraged to consider incorporating


Scroll Layer 1 Audit − Recommendations − 35


monitoring activities in the production environment. Ongoing monitoring of deployed contracts

helps identify potential threats and issues affecting production environments. With the goal of

providing a complete security assessment, the monitoring recommendations section raises

several actions addressing trust assumptions and out-of-scope components that can benefit

from on-chain monitoring.


Governance


Critical: There are several important contracts that use the Proxy Pattern and can be arbitrarily

upgraded by the proxy owner. Consider monitoring for upgrade events on at least the following

contracts:







```
ScrollChain
L1ScrollMessenger

```



  - Gateway contracts


Access Control


Critical: `Ownable` allows implementing access control to prevent unauthorized parties making

unintended changes, but it is important to monitor for events where the owner changes.

Consider monitoring for the `OwnershipTransferred` event on all ownable contracts such

as `ScrollChain` and `L1MessageQueue` .


Technical


High: The rollup contract contains sensitive functions that should be called only by the owner.

Consider monitoring if any of the following events are emitted.








```
UpdateSequencer
UpdateProver
UpdateVerifier

```


Medium: The `L1ScrollMessenger` contract includes a mechanism for pausing in case of an

incident. Consider monitoring for the `Paused` since an unexpected pause may cause a

disruption in the system.


Financial


Medium: Consider monitoring the size, cadence and token type of bridge transfers during

normal operations to establish a baseline of healthy properties. Any large deviation, or

unexpectedly large withdrawals may indicate unusual behavior of the contracts or an ongoing

attack.


Scroll Layer 1 Audit − Recommendations − 36


**_Update:_** _Acknowledged. The Scroll team stated:_


_It is on our roadmap. We will have one before mainnet launch._


Scroll Layer 1 Audit − Recommendations − 37


## **Conclusion**

This five-and-a-half-week audit had a somewhat challenging start due to scope changes, but it

ultimately progressed smoothly and benefitted greatly from valuable insights provided by the

Scroll team. The code is overall well documented which makes it easy to reason about. The

architecture of the contracts is sound and inspired by other protocols.


In this report, we uncovered a few issues that indicate that the correctness of the protocol

needs to be tested more thoroughly. This, together with the lack of refund mechanisms,

suggests that the protocol is not yet ready for production. We recommend a more extensive

test suite and another audit after the refund features have been implemented. Having said that,

we see the great efforts by the Scroll team to realize this and launch the system responsibly.


Scroll Layer 1 Audit − Conclusion − 38


