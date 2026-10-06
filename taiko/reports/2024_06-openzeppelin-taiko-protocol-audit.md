### | security

# **Taiko Protocol** **Audit**

#### **June 19, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  5


Scope ____________________________________________________________________________  6

Phases 1 and 2 6

Phase 3 8


System Overview __________________________________________________________________  9

TaikoL1 9

Overview of Multi-Proofs System 10

TaikoL2 11

Cross-Chain Communication 11

Vaults 12

Quota Manager 12

Governance 13

Management of Special Roles 13

EssentialContract 14

Taiko Grants 14


Privileged Roles _________________________________________________________________ 15


Security Model and Trust Assumptions _____________________________________________ 16


Critical Severity __________________________________________________________________ 18

C-01 Vulnerability in Block Proposal Function Allows Token Theft - Phase 1 18

C-02 Bridge Signals Can Be Forged to Drain the Protocol - Phase 3 19


High Severity ____________________________________________________________________ 20

H-01 Initialization Script of TaikoL2 Allows Reinitialization of the Rollup - Phase 1 20

H-02 Incorrect Basefee Calculation on Taiko Rollups - Phase 1 21

H-03 Block Submission Susceptible to DOS - Phase 1 23


Medium Severity _________________________________________________________________ 25

M-01 The Guardian Cannot Re-Prove Invalid Transitions - Phase 1 25

M-02 Governor Proposal Creation Is Vulnerable to Front Running in OpenZeppelin Contracts - Phase 1 25

M-03 Design Flaw in Bridge Contract Suspension Mechanism - Phase 1 26

M-04 Incomplete Role Renunciation in TaikoTimelockController Deployment - Phase 2 27

M-05 Some ERC-20 and ERC-721 Tokens Can Not Be Bridged - Phase 2 27

M-06 Cross-Chain Owner Cannot Call Privileged Functions - Phase 2 28

M-07 Security of ‘SignalService’ Network Is No Higher Than Its Weakest Node - Phase 2 28

M-08 Quota Manager Can Cause Recalled Funds to Be Stuck - Phase 3 30


Taiko Protocol Audit − Table of Contents − 2


M-09 Reached Quota Can Cause Loss of Fee - Phase 3 31


Low Severity ____________________________________________________________________ 32

L-01 Assigned Prover Signature Is Underspecified - Phase 1 32

L-02 The Snapshooter Cannot Take Snapshots of the Taiko Token - Phase 1 32

L-03 Inefficient Feature Inclusion in EssentialContract - Phase 1 33

L-04 L2 Block Difficulty Is Susceptible to Manipulation - Phase 1 34

L-05 Uncontrolled Gas Consumption When Sending ETH in Cross-Chain Messages - Phase 1 35

L-06 Honest Provers Can Lose Money - Phase 1 35

L-07 Duplicated USDC Bridging - Phase 2 36

L-08 ERC20Airdrop Claims Can Be DOSed - Phase 2 37

L-09 TimelockTokenPool Signatures Can Be Replayed - Phase 2 37

L-10 evaluatePoint Precompile Calls Revert - Phase 2 38

L-11 Vaults Are Not ERC-165 Compliant - Phase 2 39

L-12 Token Migrations Can Cause Losses - Phase 2 39

L-13 Unexpected Features in BridgedERC20 Tokens - Phase 2 40

L-14 Banned Addresses Could Be Called By Cross-Chain Messages - Phase 2 41

L-15 Some Bridged Messages Can Not Be Refunded - Phase 2 41

L-16 ‘DelegateOwner’ Does Not Check for Contract Existence - Phase 3 42

L-17 Storage Collision in Bridge Contract - Phase 3 42

L-18 Inexplicit Revert - Phase 3 43

L-19 Unrestricted Receive Function - Phase 3 43

L-20 Lack of Constraints During Migration - Phase 3 44

L-21 Incorrect Calldata Gas Accounting in Message Processing - Phase 3 44

L-22 Message Processors Can Control Gas and Fee Consumption - Phase 3 45

L-23 Inaccurate Gas Limit on Message Invocation - Phase 3 46


Notes & Additional Information ____________________________________________________ 48

N-01 Inconsistent Use of Named Returns - Phase 1 48

N-02 Lack of Indexed Event Parameters - Phase 1 48

N-03 Signatures Do Not Use EIP-712 - Phase 1 49

N-04 Gas Optimization - Phase 1 49

N-05 Inefficient Bridge Message Handling - Phase 1 50

N-06 Code Quality and Readability Suggestions - Phase 1 51

N-07 Missing or Misleading Documentation - Phase 1 52

N-08 Typographical Errors - Phase 1 53

N-09 Changing Governor Parameters Requires an Upgrade - Phase 1 53

N-10 Unused Named Return Variables - Phase 1 54

N-11 The TimelockTokenPool May Not Be Compatible With ERC-4337 - Phase 2 54

N-12 Typographical Errors - Phase 2 55

N-13 Gas Optimizations - Phase 2 55

N-14 Missing or Misleading Documentation - Phase 2 56

N-15 Lack of Indexed Event Parameters - Phase 2 56

N-16 Code Quality and Readability Suggestions - Phase 2 57

N-17 BridgedERC1155 Does Not Return Correct URI - Phase 2 58

N-18 Gas Optimizations - Phase 3 58

N-19 Code Quality and Readability Suggestions - Phase 3 59

N-20 Typographical Error - Phase 3 59


Taiko Protocol Audit − Table of Contents − 3


N-21 Naming Suggestion - Phase 3 60

N-22 License Incompatibility in LibBytes - Phase 3 60

N-23 Missing and Misleading Documentation - Phase 3 60


Client Reported __________________________________________________________________ 61

CR-01 Incorrect Deletion During Migration in ‘ERC20Vault’ 61

CR-02 Static Calls to ‘proveSignalReceived’ Revert on State Caching 62


Conclusion ______________________________________________________________________ 63


Taiko Protocol Audit − Table of Contents − 4


## **Summary**

**Type** Rollup



**Total Issues** 62 (47 resolved, 8 partially resolved)



**Timeline**



**(Phase 1)** From 2024-03-04


To 2024-04-05


**(Phase 2)** From 2024-04-08


To 2024-05-03


**(Phase 3)** From 2024-05-13


To 2024-05-28



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



2 (2 resolved)


3 (2 resolved, 1 partially resolved)


9 (8 resolved)



**Low Severity Issues** 23 (19 resolved, 2 partially resolved)



**Notes & Additional**
**Information**



23 (14 resolved, 5 partially resolved)


Taiko Protocol Audit − Summary − 5



**Languages** Solidity


## **Scope**

The audit took place in three phases.

### **Phases 1 and 2**


During the first two phases, we audited the <u>[taikoxyz/taiko-mono](https://github.com/taikoxyz/taiko-mono)</u> repository at commit <u>[b47fc34.](https://github.com/taikoxyz/taiko-mono/tree/b47fc34cb0e7fe9b7ebd9416b3051a067483b860)</u>


In scope were the following files:

```
└── packages
└── protocol
└── contracts
├── bridge
│  ├── Bridge.sol
│  └── IBridge.sol
├── common
│  ├── AddressManager.sol
│  ├── AddressResolver.sol
│  ├── EssentialContract.sol
│  ├── IAddressManager.sol
│  └── IAddressResolver.sol
├── L1
│  ├── ITaikoL1.sol
│  ├── TaikoData.sol
│  ├── TaikoErrors.sol
│  ├── TaikoEvents.sol
│  ├── TaikoL1.sol
│  ├── TaikoToken.sol
│  ├── gov
│  │  ├── TaikoGovernor.sol
│  │  └── TaikoTimelockController.sol
│  ├── hooks
│  │  ├── AssignmentHook.sol
│  │  └── IHook.sol
│  ├── libs
│  │  ├── LibDepositing.sol
│  │  ├── LibProposing.sol
│  │  ├── LibProving.sol
│  │  ├── LibUtils.sol
│  │  └── LibVerifying.sol
│  ├── provers
│  │  ├── GuardianProver.sol
│  │  └── Guardians.sol
│  ├── tiers
│  │  ├── DevnetTierProvider.sol
│  │  ├── ITierProvider.sol

```

Taiko Protocol Audit − Scope − 6


```
│  │  ├── MainnetTierProvider.sol
│  │  └── TestnetTierProvider.sol
├── L2
│  ├── CrossChainOwned.sol
│  ├── Lib1559Math.sol
│  ├── TaikoL2.sol
│  └── TaikoL2EIP1559Configurable.sol
├── libs
│  ├── Lib4844.sol
│  ├── LibAddress.sol
│  ├── LibMath.sol
│  └── LibTrieProof.sol
├── signal
│  ├── ISignalService.sol
│  ├── LibSignals.sol
│  └── SignalService.sol
├── team
│  ├── TimelockTokenPool.sol
│  └── airdrop
│    ├── ERC20Airdrop.sol
│    └── MerkleClaimable.sol
├── thirdparty
│  ├── nomad-xyz
│  │  └── ExcessivelySafeCall.sol
│  ├── optimism
│  │  ├── Bytes.sol
│  │  ├── rlp
│  │  │  ├── RLPReader.sol
│  │  │  └── RLPWriter.sol
│  │  └── trie
│  │    ├── MerkleTrie.sol
│  │    └── SecureMerkleTrie.sol
│  └── solmate
│    └── LibFixedPointMath.sol
├── tokenvault
│  ├── BaseNFTVault.sol
│  ├── BaseVault.sol
│  ├── BridgedERC1155.sol
│  ├── BridgedERC20.sol
│  ├── BridgedERC20Base.sol
│  ├── BridgedERC721.sol
│  ├── ERC1155Vault.sol
│  ├── ERC20Vault.sol
│  ├── ERC721Vault.sol
│  ├── IBridgedERC20.sol
│  ├── LibBridgedToken.sol
│  └── adapters
│    └── USDCAdapter.sol
└── verifiers
├── GuardianVerifier.sol
├── IVerifier.sol
└── SgxVerifier.sol

```


Taiko Protocol Audit − Scope − 7


### **Phase 3**

During the third phase, we audited the <u>[taikoxyz/taiko-mono](https://github.com/taikoxyz/taiko-mono)</u> repository at commit <u>[dd8725f.](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>


In scope were the following files:

```
└── packages
└── protocol
└── contracts
├── L2
│  └── DelegateOwner.sol
├── bridge
│  ├── Bridge.sol
│  └── QuotaManager.sol
├── tko
│  └── BridgedTaikoToken.sol
└── tokenvault
├── BridgedERC20.sol
└── ERC20Vault.sol

```

Taiko Protocol Audit − Scope − 8


## **System Overview**

Taiko is a rollup that posts its data to Ethereum and relies on Ethereum smart contracts to store

its state and validate state transitions. The validity of these state transitions is enforced through

a tier and contestation system, where higher proof tiers can be used to contest a transition

with a lower tier. In addition, sequencing transactions and building L2 blocks is permissionless.

This means that L1 validators effectively choose which blocks are proposed as well as the

order of L2 transactions, making Taiko a based rollup.


We will describe the system below assuming only Ethereum L1 and a single Taiko L2 for

simplicity, but we note that the codebase was built to be extendable to additional rollups,

including on higher layers.

### **`TaikoL1`**


The <mark>`TaikoL1`</mark> contract is the core of the Taiko protocol, providing functionalities for

proposing, proving, and verifying L2 blocks. As noted above, it was designed to operate on L1

but can be adapted for deployment on other layers, enabling the creation of additional layers

like L3s. Central to its operations, <mark>`TaikoL1`</mark> manages the entire life cycle of L2 blocks. The

cycle includes:


**Block Proposal**


Block proposers select transactions from the Taiko L2 mempool to form a block, incentivized

by L2 transaction tips and potential MEV. The proposer then submits these transactions in

blobs or calldata to the <mark>`TaikoL1`</mark> contract. This submission also includes additional details

such as the assigned prover, a list of addresses (called "hooks") called during submission and

some additional data sent to the hooks. The <mark>`AssignmentHook`</mark> is one such hook which is

deployed by the Taiko team, allowing third-party provers to express their consent through a

signature and receiving some fees paid by the proposer as compensation. Provers are tasked

with computing the proofs required to prove transitions associated with blocks, which is

expected to require significant computing power and custom infrastructure. In exchange for

their monopoly over proving a block for a limited amount of time, assigned provers have to

provide some Taiko (TKO) tokens which are held by the <mark>`TaikoL1`</mark> contract, called a "liveness

bond". This bond is returned if the prover proves the correct transition in the imparted time.


Taiko Protocol Audit − System Overview − 9


**Block Proving**


As mentioned above, the assigned prover must send a proof to validate the block transition

within a designated time window. If the prover fails to do so, their liveness bond will be given

as an incentive for another provers to prove the block. If the prover submits the proof on time,

it enters a cooldown period during which it can be contested by others. Contestants are not

required to provide any proof but must pay a "contestation bond" in TKO tokens. If a proof is

contested, a higher-tier proof is required to resolve the dispute before the associated block can

be verified.


**Block Verification**


After the cooldown period has passed, a block can no longer be contested and is assumed to

be valid. While a new block is being proposed, previous ones are verified once their cooldown

period is over. After this process, the L2 state is finalized and can be used to facilitate the

bridging process between L1 and L2.

### **Overview of Multi-Proofs System**


As cryptographic methods are continually evolving and carry inherent risks, Taiko has adopted

a multi-tiered approach to proofs. The first tier is SGX proofs, the second tier requires both

SGX and ZK proofs, and the last tier requires proofs provided by a whitelisted set of guardians.

This tiered system, combined with economic incentives, aims to make all of Taiko's state

transitions as sound as zk proofs. This is because zk provers are incentivized to contest any

invalid SGX proof. At the same time, as SGX proofs are cheaper to compute than zk proofs,

block submission and transaction fees paid by users are expected to be cheaper on average

than pure zk rollups. This tier system mitigates risks associated with potential vulnerabilities in

proof systems and allows for configurational flexibility that can evolve into a standard zk-rollup

over time.


**Prover Economics**


To sustain a pool of zk provers, Taiko has implemented a system whereby a minimum proof tier

is randomly assigned to each new block, thus incentivizing zk provers to monitor and prove L2

blocks. In addition, provers are incentivized through bonds to contest invalid proofs.


**Guardian Provers**


As the multi-proofs system gets battle-tested during the first phase of the protocol's life, the

guardian provers act as a fallback against unforeseen bugs within the proving systems. They


Taiko Protocol Audit − System Overview − 10


have the power to prove arbitrary state transitions in any block. These guardian provers

operate externally to the main protocol and can be removed from the multi-tier proving setup.

As the system evolves and other provers demonstrate reliability, the necessity for these

guardian provers should diminish over time.

### **`TaikoL2`**


The <mark>`TaikoL2`</mark> contract is one of the main components of the Taiko rollup and is part of the

contracts that are going to be deployed on the L2 side. This contract has two core

functionalities.


Firstly, it facilitates cross-layer communication by "anchoring" the L1 state root onto L2. This

functionality enables users on L2 to demonstrate that a specific message was sent on L1 by

leveraging the anchored L1 state root along with a Merkle proof.


Secondly, it incorporates a slightly modified version of the exponential EIP-1559 mechanism to

manage L2 gas pricing. EIP-1559 is known for its dynamic fee computation which adjusts the

base fees based on network congestion, thus stabilizing congestion and transaction fees. In

<mark>`TaikoL2`</mark> <mark>,</mark> some parameters of this base fee calculation are configurable by the Taiko DAO. A

fixed amount of L2 gas is made available per L1 block.


During phases 1 and 2, the <mark>`TaikoL2`</mark> contract inherited from the <mark>`CrossChainOwned`</mark>

contract to enable certain functions to be executed from L1 through a cross-chain interaction.

This was simplified in phase 3 by making the <mark>`DelegateOwner`</mark> the owner of all the L2

contracts. This <mark>`DelegateOwner`</mark> contract is operated by an owner on L1 through cross-chain

messages, allowing it to call other contracts in the name of the <mark>`DelegateOwner`</mark> <mark>.</mark> In practice,

this allows the L1 DAO to effectively act as the owner of the L2 contracts.

### **Cross-Chain Communication**


At the core of cross-chain communication is the <mark>`SignalService`</mark> contract. This contract

stores as parts of its state the signals that are used to communicate across chains. There are

two main types of signals: signals sent by contracts to communicate with a different chain,

such as the <mark>`Bridge`</mark> contract, and signals sent by the <mark>`SignalService`</mark> contract itself to

indicate that the state/storage root for another chain has been synchronized with this chain.

These synchronization operations happen, for example, during L2 block verification on L1, or in

the anchor transaction at the beginning of new blocks on L2.


Taiko Protocol Audit − System Overview − 11


Once a state root for a chain has been synchronized on another chain, a Merkle proof can be

done against this state root to prove that a certain signal was sent on the source chain. Such

proofs can also use multiple "hops": for example, a user could prove that a signal was sent on

L3 if the state of the L3 was synchronized to L2 and the L2 state was synchronized to L1. This

could be used to execute an L3 -> L1 message in one L1 transaction using two hops. This

proving mechanism underlies Taiko cross-chain communication.


The <mark>`SignalService`</mark> can be used by other contracts such as the <mark>`Bridge`</mark> contract to

handle cross-chain communication. Messages can be sent to the <mark>`Bridge`</mark> contract on the

source chain, and then processed on the target chain once the state has been synchronized. A

fee can be associated with a message to incentivize third-party actors to process it, or some

parameters can be set on the message so that it can only be processed by a specific address.

Messages can be used to call contracts and can be retried if they fail. When retrying a failed

message, its status can be updated so that it can no longer be retried and the sender on the

source chain can receive a refund.

### **Vaults**


There are three types of vaults: The <mark>`ERC20Vault`</mark> <mark>,</mark> the <mark>`ERC721Vault`</mark> <mark>,</mark> and the

<mark>`ERC1155Vault`</mark> <mark>.</mark> As their names suggest, each of these is responsible for handling a certain

type of asset. These vaults use the <mark>`Bridge`</mark> contract mentioned above to send messages to a

vault on another chain and hold all the sent assets. When a token is sent for the first time

across the chain, a new bridged contract (e.g., <mark>`BridgedERC20`</mark> <mark>)</mark> is deployed on the target

chain to represent it. A migration can be triggered by the owner of a vault to change the

contract associated with a certain bridged asset. When a migration is triggered, the previous

asset is blocked from being transferred through the vault and users have to migrate to the new

asset. As part of phases 1 and 2, a special contract called <mark>`USDCAdapter`</mark> was designed to

handle the migration from the initial USDC <mark>`BridgedERC20`</mark> representation to a native USDC

contract on Taiko. This adapter was removed in phase 3 as the <mark>`mint`</mark> and <mark>`burn`</mark> functions of

<mark>`IBridgedERC20`</mark> interface were changed to match USDC's. Other custom native tokens

being deployed to L2 may still require adapters.

### **Quota Manager**


The <mark>`QuotaManager`</mark> contract was added to the codebase as part of phase 3 following the

auditors' advice during previous phases. The contract allows the owner to define quotas

(spending limits) which are intended to be set up for ERC-20 tokens and ETH. All quotas are

recovering over the same quota period. The <mark>`Bridge`</mark> and <mark>`ERC20Vault`</mark> consume these


Taiko Protocol Audit − System Overview − 12


quotas when forwarding assets, with the <mark>`QuotaManager`</mark> tracking the available quota and

preventing limits from being exceeded. These rate limits are expected to be relaxed as the

protocol matures.

### **Governance**


During phase 1 and 2, the contracts in the codebase were intended to be owned by the

<mark>`TaikoTimelockController`</mark> contract. This contract sat between the <mark>`TaikoGovernor`</mark>

contract, which inherits from OpenZeppelin's <u><mark>`[Governor](https://docs.openzeppelin.com/contracts/4.x/api/governance#governor)`</mark></u> <mark>,</mark> and the owned contracts. The

<mark>`TaikoGovernor`</mark> contract was intended to be used by the DAO composed of <mark>`TaikoToken`</mark>

holders to vote on proposals, which would then be executed on-chain through the

<mark>`TaikoTimelockController`</mark> contract, adding a delay for users in case of a malicious action

by governance. The DAO and the timelock delay could be circumvented by an address set

during initialization of the <mark>`TaikoTimelockController`</mark> contract (e.g., a security council).


As part of phase 3, these contracts were removed and L1 contracts are now owned directly by

the DAO. L2 contracts are owned by the <mark>`DelegateOwner`</mark> contract which is operated by the

L1 DAO by sending L1->L2 messages.

### **Management of Special Roles**


The <mark>`AddressManager`</mark> and <mark>`AddressResolver`</mark> contracts are central to the operations of

the Taiko ecosystem. The <mark>`AddressManager`</mark> contract allows the contract's owner, in practice

the Taiko DAO, to define and update the address associated with a unique chain ID and name

pair through the <mark>`setAddress`</mark> method. This configuration allows any contract inheriting from

the <mark>`EssentialContract`</mark> - which itself inherits from the <mark>`AddressResolver`</mark> - to perform

name-to-address lookups. Such functionality is important for ensuring that contracts can

reliably utilize the same designated addresses within their operational logic.


The <mark>`AddressResolver`</mark> contract enables straightforward address retrieval from the

<mark>`AddressManager`</mark> contract. This separation of concerns simplifies address resolution and

enhances the system's flexibility in managing addresses, ensuring that any address change

affects all the contracts simultaneously by maintaining a unique source of truth per layer.


Taiko Protocol Audit − System Overview − 13


### **`EssentialContract`**

<mark>`EssentialContract`</mark> serves as a foundational component in the Taiko system, with all the

Taiko contracts inheriting from it. This abstract contract incorporates several key features:


    - **Owner Management** : Utilizing the <mark>`Ownable2StepUpgradeable`</mark> contract,

<mark>`EssentialContract`</mark> provides a basic access control mechanism, where an account

(an owner) can be granted exclusive access to specific functions. Importantly, ownership

can be transferred through a two-step transaction process, enhancing security by

reducing risks associated with single-transaction ownership transfers.

    - **Upgradability** : Through inheritance from <mark>`UUPSUpgradeable`</mark> <mark>,</mark> the contract supports the

UUPS proxy pattern.

    - **Pausing Mechanism** : The contract grants the owner the power to pause and unpause

the execution of the functions that use pausing modifiers.

    - **Reentrancy Protection** : The inclusion of a <mark>`nonReentrant`</mark> modifier prevents reentrancy

attacks.







**<mark>`AddressManager`</mark>** **Access** : <mark>`EssentialContract`</mark> optionally enables the

<mark>`AddressResolver`</mark> <mark>,</mark> allowing child contracts to query and use resolved addresses



dynamically within their functional logic. This capability is enhanced with the

<mark>`onlyFromOwnerOrNamed`</mark> modifier, restricting the execution of certain functions to

either the owner or specific named addresses within the <mark>`AddressManager`</mark> <mark>.</mark>

### **Taiko Grants**


The <mark>`TimelockTokenPool`</mark> was a contract within the Taiko ecosystem that was audited in

phases 1 and 2. It was designed for managing the distribution and lifecycle of TKO tokens to

various stakeholders such as investors, team members, advisors, and grant program grantees.


The contract delineates a three-stage lifecycle for token management:


1. **Allocated** : Tokens are granted for specific roles or individuals but remain under the

control of the shared vault.

2. **Granted, Owned, and Locked** : At this stage, tokens are officially owned by the

recipients but are locked according to predefined conditions.

3. **Granted, Owned, and Unlocked** : In the final phase, the tokens transition from being

locked to fully unlocked based on the terms set out at the time of the grant. Once

unlocked, the recipients can withdraw all their assets.


The contract includes functionality to void conditional allocations by invoking the <mark>`void()`</mark>

method. However, once tokens are granted and owned, the terms of the ownership and unlock


Taiko Protocol Audit − System Overview − 14


schedules are immutable, ensuring clarity and fairness in the distribution process. To

accommodate different groups of recipients, the contract can be deployed in multiple

instances.

## **Privileged Roles**


Multiple privileged roles can interact with the system:


  - Guardians: Guardians are managed by the <mark>`GuardianProver`</mark> contract. They monitor

block proposals and can execute arbitrary L2 state transitions for proposed blocks.

   - Owner: All the contracts have an owner who can pause functionality in some contracts,

call privileged functions, and upgrade the implementation.




- <mark>`proposer`</mark> <mark>:</mark> If the <mark>`proposer`</mark> role is given to any contract through the address manager,

this address is the only one that can propose a block. The owner of the

<mark>`AddressManager`</mark> contract can grant this role.




- <mark>`proposer_one`</mark> <mark>:</mark> Similar to the <mark>`proposer`</mark> role above, an address with this role is the

only address which can propose the first block. This role is also granted by the owner of

the <mark>`AddressManager`</mark> contract.




- <mark>`TIMELOCK_ADMIN_ROLE`</mark> <mark>:</mark> Any address given this role in the

<mark>`TaikoTimelockController`</mark> contract can execute transactions instantly and

circumvent the timelock delay. Note that the <mark>`TaikoTimelockController`</mark> contract

was expected to be given ownership role of the other contracts, giving the

<mark>`TIMELOCK_ADMIN_ROLE`</mark> effective ownership of the other contracts. As mentioned

above, this role and the <mark>`TaikoTimelockController`</mark> contract were removed in phase

3.




- <mark>`bridge_watchdog`</mark> <mark>:</mark> In phases 1 and 2, addresses with this role could prevent the

processing of some messages on the <mark>`Bridge`</mark> contracts, as well as prevent some

addresses from being called by messages. In phase 3, this role can pause the <mark>`Bridge`</mark>

contract but cannot unpause it.




- <mark>`bridge_pauser`</mark> <mark>:</mark> Addresses with this role can pause the bridge, preventing users from

sending or processing messages.




- <mark>`chain_pauser`</mark> <mark>/</mark> <mark>`chain_watchdog`</mark> <mark>:</mark> In phases 1 and 2, addresses with this role could

pause the <mark>`TaikoL1`</mark> contract, stopping the proposal and proving of L2 blocks as well as

direct deposit of ETH to L2. The role was replaced by the <mark>`chain_watchdog`</mark> in phase 3,

which can pause the <mark>`TaikoL1`</mark> and the <mark>`Bridge`</mark> contracts.


Taiko Protocol Audit − Privileged Roles − 15


- <mark>`snapshooter`</mark> <mark>:</mark> Any address with this role could trigger snapshots on the

<mark>`TaikoToken`</mark> <mark>.</mark> This role was removed in phase 3 of the audit.

- <mark>`withdrawer`</mark> <mark>:</mark> Addresses with this role can sweep any token sent to the <mark>`TaikoL2`</mark>

contract. Note that the <mark>`TaikoL2`</mark> contract is not intended to hold the user's funds.




- <mark>`rollup_watchdog`</mark> <mark>:</mark> The rollup watchdog can remove instances from the SGX verifier



contract to stop previously trusted SGX instances from being able to submit SGX proofs.

This role was replaced by the <mark>`sgx_watchdog`</mark> role in phase 3.


Each of these roles presents a unique set of permissions in the Taiko protocol.

## **Security Model and Trust** **Assumptions**


There are several trust assumptions for users of the protocol:


   - All of the addresses with the roles mentioned above can impact users in different ways

and some, if compromised, could freeze or steal users' funds.

   - The nature of the cross-chain communication protocol used by Taiko assumes that all

the nodes in the network composed of the different Taiko-connected chains are honest.

If a chain is compromised and can pass arbitrary signals, including arbitrary state roots

for another chain, assets held by the vaults could be stolen. It is important for users to

monitor which chains are added to this network, and to understand the implications of

connecting to another chain.

   - Because all the contracts rely on the address resolver and manager contracts to

authenticate each other, it is important that they stay synchronized and share the same

address manager across the different contracts on a chain. Loss of synchronization

could have unexpected effects, including loss of user funds.

   - All of the contracts inherit from <mark>`EssentialContract`</mark> and can thus be paused and

upgraded by the owner. We assume this role is given to the DAO.

   - All the tokens deployed to L2 have pausability and upgradability. In phases 1 and 2 of

this audit, such tokens had snapshot and voting capabilities as well. Users should be

aware of this fact as it could impact how tokens can be used on L2.

   - While the Taiko L2 is Ethereum equivalent, some things are different than on L1. For

example, there is no guarantee as to the time between L2 blocks and the difficulty

opcode is computed differently. Developers are assumed to be aware of these

differences when deploying to Taiko so they can ensure their contracts remain secure.


Taiko Protocol Audit − Security Model and Trust Assumptions − 16


   - The genesis state root is assumed to not include any backdoor.

   - A quorum of guardians can execute arbitrary state transitions on the rollup. If enough

guardians are compromised or dishonest, this may result in a loss of funds for users.

   - The destination owner of a cross-chain message is assumed to be able to receive funds

and to be an address controlled by message senders. Users should understand that

wrongly setting this address could result in loss of funds.

   - It is assumed that when the <mark>`ERC20Vault`</mark> owner changes the bridged token contract of

a canonical token, the new bridged token matches the previous version in name, symbol,

and decimals, and is fully operable as intended by the <mark>`ERC20Vault`</mark> <mark>.</mark> Furthermore, the

owner is expected to do so only after all the users have migrated to the latest contract

before the change.

   - It is assumed that if a bridged token migration happens from or towards a token which

does not support the <mark>`IBridgedERC20Migratable`</mark> interface, the Taiko DAO would do

their diligence to ensure that no user funds are lost.

   - It is assumed that the quotas of the <mark>`QuotaManager`</mark> are only increased over time, as a

decrease can interfere with ongoing asset bridging.

   - The soundness of the state transition proofs associated with blocks relies on the

assumption that third party provers are incentivized to contest invalid state transitions.

This incentivization in practice depends on the relative prices of the Taiko token and of

proving a block. It is possible for the price of the Taiko token to be too low to incentivize

third party contesters to contest an invalid state transitions. It is assumed that if such a

situation was judged likely, the Taiko DAO would step in to increase the liveness and

contest bonds.


The above security considerations and trust assumptions are inherent to the design of the

codebase. Thus, we assume in the report below that the aforementioned actors are not

compromised and behave honestly.


Taiko Protocol Audit − Security Model and Trust Assumptions − 17


## **Critical Severity**

### **C-01 Vulnerability in Block Proposal Function** **Allows Token Theft - Phase 1**

The <u><mark>`[proposeBlock](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoL1.sol#L55)`</mark></u> function is designed to enable the proposing of L2 blocks to an L1 chain,

requiring proposers to indicate a prover responsible for proving the block. The process needs

proposers to provide a signature that verifies the prover's agreement to specific terms, such as

fee costs, block metadata hash, and the token used for fee payment. Anyone can be a prover

as long as they can execute the necessary computations for proving the L2 block and have

250 TKO or more tokens that could ensure their commitment to proving blocks within a certain

timeframe.


A security flaw is present within the <u><mark>`[AssignmentHook](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/hooks/AssignmentHook.sol#L62)`</mark></u> <u><mark>'</mark></u> <u>s</u> <u><mark>`[onBlockProposed](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/hooks/AssignmentHook.sol#L62)`</mark></u> <u>method. This</u>

method, which is executed during the block proposal transaction, manages the transfer of fees

from the proposer to the prover. If the transaction involves fee payment in a non-ETH token,

the contract utilizes the <u><mark>`[safeTransferFrom](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/hooks/AssignmentHook.sol#L114)`</mark></u> method to facilitate the fee transfer from the

Coinbase address to the prover's address. However, a malicious proposer can set the

Coinbase address to be a user's address that has previously granted an ERC-20 token

allowance to the <mark>`TaikoL1`</mark> contract (usually a prover's address as they could set the

maximum allowance on its TKO tokens to participate as a prover). By doing so, the proposer

can specify the fee amount to be equivalent to the entire token allowance, choose that token

for the payment of the fees, and assign a controlled prover to be the one that receives the

tokens.


Consider adjusting the fee payment logic to ensure that the Coinbase address is not used

when transferring the fees. In addition, consider using an address that correctly represents the

<mark>`proposeBlock`</mark> caller, preventing unauthorized redirection of ERC-20 token allowances.


**_Update:_** _Resolved in_ _<u>[pull request #16327](https://github.com/taikoxyz/taiko-mono/pull/16327)</u>_ _at commit_ _<u>[7423ffa. A new variable was added to track](https://github.com/taikoxyz/taiko-mono/commit/7423ffa2fb2c5df870be9f1f2cab23c3409e5046)</u>_

_the block proposer, who now pays the fees._


Taiko Protocol Audit − Critical Severity − 18


### **C-02 Bridge Signals Can Be Forged to Drain the** **Protocol - Phase 3**

Cross-chain messages can be sent by calling the <mark>`sendMessage`</mark> function on the <mark>`Bridge`</mark>

contract. This function in turn calls <mark>`sendSignal`</mark> on the <mark>`SignalService`</mark> contract <u>[with the](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L162)</u>

<u>[hash of the sent message. When a message is processed on the destination chain,](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L162)</u>

<mark>`_message.value + _message.fee`</mark> is checked <u>[not to exceed the current quota. If it](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L247)</u>

exceeds the quota, the message's status is set to <mark>`RETRIABLE`</mark> and can be re-executed later.

Otherwise, the message is <u>[validated](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L253)</u> not to call forbidden addresses and to match

<mark>`onMessageInvocation`</mark> <mark>'</mark> s function selector, after which the <u>[external call is made to the](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L264)</u>

<u>[destination address.](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L264)</u>


However, the <u>[checks](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L639-L645)</u> constraining the target of the message or the function selector are

consequently not applied when a message is retried. Assuming an ETH quota on L1, an

attacker can thus perform the following actions to invoke any message on L2:


1. <u>[Send a message](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L126)</u> on L2 that will exceed the available L1 ETH quota, targeting the

<mark>`SignalService`</mark> to call <mark>`sendSignal`</mark> <mark>.</mark> The sent signal must be the hash of the crafted

message, which the attacker will process on L2 in step 5.

2. The attacker attempts to process this message on L1, but as the <u>[message exceeds the](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L213)</u>

<u>[quota, it would be directly set to](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L213)</u> <mark>`RETRIABLE`</mark> without validating its target or the function

selector.

3. This message can then be retried and will make the <mark>`Bridge`</mark> contract <u>[invoke the call](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L325)</u> to

<mark>`sendSignal`</mark> <mark>.</mark> Note that <mark>`sendSignal`</mark> is non-payable, so the message in step 1 would

need to have a value of zero but a fee in excess of the available L1 ETH quota.

4. The L1 signal will be synchronized with L2 through normal protocol operation.

5. The attacker can <u>[process](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L213)</u> the crafted message.


Sending arbitrary messages from the <mark>`Bridge`</mark> is a powerful attack vector as it also allows

spoofing any address through the <u><mark>`[Bridge](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L487)`</mark></u> <u>context. This makes it possible to forward arbitrary</u>

amounts of <u>[ETH](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/IBridge.sol#L51)</u> or mint any <u>[ERC-20, ERC-721, or](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L279-L280)</u> <u>[ERC-1155](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/tokenvault/ERC1155Vault.sol#L104-L105)</u> token on the L2. These tokens

can then be bridged back to drain user assets from the <mark>`Bridge`</mark> and vault contracts on L1,

subject to quotas per amount of time given by the <mark>`QuotaManager`</mark> <mark>.</mark> Furthermore, by spoofing

the <u><mark>`[realOwner](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L80-L84)`</mark></u> <u>[of the](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L80-L84)</u> <u><mark>`[DelegateOwner](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L80-L84)`</mark></u> contract, a backdoor can be installed that will be

exploited at a later point in time.


Note that we assumed above for simplicity, but without loss of generality, that there were only

two layers. This is because the exploit can occur between any two layers where one layer has

an ETH quota defined.


Taiko Protocol Audit − Critical Severity − 19


Consider <u>[validating](https://github.com/taikoxyz/taiko-mono/blob/b90b932f29e6a933625d973bc32c2f0a1c6908e4/packages/protocol/contracts/bridge/Bridge.sol#L253C17-L253C43)</u> that messages are not calling arbitrary functions or forbidden addresses

before setting their status to <mark>`RETRIABLE`</mark> or when retrying the message.


**_Update:_** _Resolved in_ _<u>[pull request #17411](https://github.com/taikoxyz/taiko-mono/pull/17411)</u>_ _at commit_ _<u>[304aec2. The invocation target and](https://github.com/taikoxyz/taiko-mono/commit/304aec216b605e597b2d11201665adba20a35c2f)</u>_

_function signature are now also checked in the_ _<mark>`retryMessage`</mark>_ _function. However, the fix_

_introduced a double spending attack vector of the fee that was addressed in_ _<u>[pull request](https://github.com/taikoxyz/taiko-mono/pull/17446)</u>_

_<u>[#17446](https://github.com/taikoxyz/taiko-mono/pull/17446)</u>_ _at commit_ _<u>[891967d.](https://github.com/taikoxyz/taiko-mono/pull/17446/commits/891967dc1505ed0d332fdc408402029f0a6ff1ff)</u>_

## **High Severity**

### **H-01 Initialization Script of TaikoL2 Allows** **Reinitialization of the Rollup - Phase 1**


The <mark>`TaikoL2`</mark> contract is intended to be initialized by a <u>[script](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/utils/generate_genesis/taikoL2.ts#L499-L516)</u> setting the state variables in the

genesis state root directly instead of calling the <u><mark>`[init](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L71-L98)`</mark></u> function. However, this script does not

initialize the <mark>`_initialized`</mark> variable to `1` on the rollup contract. This means that <mark>`init`</mark>

could be called after deployment during the first block by a malicious actor to set itself as the

owner of <mark>`TaikoL2`</mark> or change the address manager, giving it control of critical functions.


Once granted the owner role, a malicious actor could, for example, <u>[withdraw any token](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L163-L178)</u> sent to

the <mark>`TaikoL2`</mark> contract, or change the base fee of the rollup at will by <u>[manipulating the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2EIP1559Configurable.sol#L25-L40)</u>

<u>[configuration. An example of malicious usage of this privilege could be to include one](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2EIP1559Configurable.sol#L25-L40)</u>

transaction setting the base fee to 1 wei at the beginning of its blocks before resetting it to a

very high level at the end, allowing this user to have a monopoly over L2 transaction inclusion

by pricing out all the other block proposers as well as circumventing any gas limit.


Consider modifying the genesis script to initialize all the variables of the <mark>`TaikoL2`</mark> contract

correctly, as well as adding a test scenario to ensure the storage layouts of the L2 contracts

initialized by calling <mark>`init`</mark> are the same as the ones obtained by running the initialization

script. This would also be useful for rollup users to be able to reproduce the genesis state root

and ensure that no backdoor was included in the initial state.


Note that the initialization script is out of the scope of this engagement.


**_Update:_** _Resolved in_ _<u>[pull request #16543](https://github.com/taikoxyz/taiko-mono/pull/16543)</u>_ _at commit_ _<u>[37fa853. The deployment script was](https://github.com/taikoxyz/taiko-mono/commit/37fa853bd4d560a8ef0301437303f35f0d0c4c92)</u>_

_modified to initialize those variables._


Taiko Protocol Audit − High Severity − 20


### **H-02 Incorrect Basefee Calculation on Taiko** **Rollups - Phase 1**

On a Taiko rollup, the basefee at block `n` is computed as <mark>`b(n) = b0 * 1/TA *`</mark>

<mark>`exp(gas_excess / TA)`</mark> <mark>,</mark> where <mark>`b0 = 1`</mark> <mark>,</mark> `T` the gas target is <mark>`60`</mark> million gas and `A` is the

adjustment factor set to `8` . This formula is <u>[explained](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/docs/eip1559_on_l2.md)</u> as originating from the research around

making EIP-1559 more like an <u>[AMM curve. However, the formula used does not match the](https://ethresear.ch/t/make-eip-1559-more-like-an-amm-curve/9082)</u>

AMM formula, in which <mark>`basefee`</mark> would be computed as <mark>`(eth_qty(excess_gas_issued`</mark>

<mark>`+ gas_in_block) - eth_qty(excess_gas_issued)) / gas_in_block`</mark> <mark>.</mark> The base

fee is actually computed as the derivative of the AMM curve at the last <mark>`gas_excess`</mark> reached

in the previous transaction. This makes the computation closer to <u>[exponential EIP-1559,](https://dankradfeist.de/ethereum/2022/03/16/exponential-eip1559.html)</u>

except the formula to compute the base fee is multiplied by a factor <mark>`1 / TA`</mark> .


There are multiple issues with the EIP-1559 implementation:


1. The <mark>`lastSyncedBlock`</mark> state variable is <u>[updated every 6 blocks, but the new issuance](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L145-L152)</u>

of gas every L2 block is computed as <mark>`(_l1BlockId - lastSyncedBlock) *`</mark>

<mark>`gasTargetPerL1Block`</mark> <mark>.</mark> This means that there will be significantly more L2 gas

issuance than expected due to the fact that <mark>`lastSyncedBlock`</mark> is not updated every

L1 block. For example, let us assume that <mark>`lastSyncedBlock = 1000`</mark> and the current

L1 block number is <mark>`1002`</mark> <mark>.</mark> Let us now assume that we want to anchor any number of

new L2 blocks. The new issuance of L2 gas for such a block would be <mark>`(_l1BlockId -`</mark>
```
   lastSyncedBlock) * gasTargetPerL1Block = 2 * gasTargetPerL1Block =
```

<mark>`120`</mark> million, which is higher than the block gas limit. This would result in the base fee

<u>[staying at 1](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L296)</u> wei no matter how many L2 blocks are created, or how full they are. In

practice, this would mean that no base fee is collected at all, and we expect the system

to revert to a first-price auction mechanism for the pricing of its gas. Additionally, this

means that there is no limit to the amount of L2 blocks which can be proposed or to the

gas which can be consumed per unit of time. As long as the compensation earned from

tips by block proposers is enough to pay for the proposal of new blocks, blocks could be

proposed without any limit on network congestion. This could also have unexpected

consequences related to the size of the ring buffers, as well as the equilibrium between

the proving and proposing of blocks. Consider issuing new L2 gas only on new L1

blocks.


2. The issuance of new L2 gas is currently done every 6 L1 blocks, and could be done

every L1 block as recommended in 1). However, issuing gas in one chunk every >= 4 L2

blocks runs counter to one of the goals of EIP-1559, which is to act as a gas smoothing

mechanism. This creates undesirable spikes in the base fee, where the next L2 block

anchored following an L1 block is significantly cheaper than the following blocks.


Taiko Protocol Audit − High Severity − 21


Consider smoothing the L2 gas issuance over multiple blocks (e.g., by accumulating the

L2 gas issuance in a storage variable and spreading it over 4 L2 blocks). The figures

given below as examples assume that new gas issuance occurs every 4 L2 blocks and

compare issuing gas in one chunk with issuing it over 4 L2 blocks. The demand for block

space is modeled as being infinite below 10 gwei and 0 above.


3. As mentioned above, the current implementation of EIP-1559 is similar to an exponential

1559 where <mark>`b0 = 1/TA = 2.08e-9`</mark> <mark>.</mark> Since <mark>`b0`</mark> is the minimum value that the base fee


Taiko Protocol Audit − High Severity − 22


can take, its minimum value should be the minimum possible base fee (i.e., 1 wei instead

of 2.08e-9 wei which is <u>[scaled up to 1 wei). This would avoid having to compensate for](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L296)</u>

the low <mark>`b0`</mark> by adjusting the excess gas in the exponential upward, which reduces the

range before the input to the exponential gets <u>[too big](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/Lib1559Math.sol#L42-L44)</u> and loses some precision.

Consider removing the division by <mark>`T * A`</mark> and setting <mark>`b0`</mark> to 1 wei as done in Ethereum

(see <u>[[1]](https://github.com/ethereum/go-ethereum/blob/master/consensus/misc/eip4844/eip4844.go#L79-L81)</u> <u>[[2]).](https://eips.ethereum.org/EIPS/eip-4844)</u>


Consider addressing the above issues to improve the gas pricing mechanism on L2. In

addition, consider adding documentation around the gas logic as well as the lack of

constraints on L2 block times.


**_Update:_** _Partially resolved at commit_ _<u>[a981ccd. All the points in the issue except the second one](https://github.com/taikoxyz/taiko-mono/commit/a981ccdadc90d48b41f72945e0d27c84f1bd5ce2)</u>_

_were addressed. The Taiko team stated:_


_Regarding the base-fee smoothing concept, we've already implemented and tested it,_

_confirming its functionality. However, we've decided to first deploy a simpler version in_

_production to assess its behaviors before integrating the base-fee smoothing feature._

_This decision aligns with potential future changes, including possibly eliminating the_

_anchor transaction framework in favor of handling all anchor-related logic (including_

_EIP1559 calculation) on the client-side and in the prover, to simplify the protocol further._

### **H-03 Block Submission Susceptible to DOS -** **Phase 1**


When proposing a new block, the block is added to a ring buffer. If too many blocks have been

proposed since the last verified one (i.e., if the ring buffer is close to being "filled") additional

block proposals <u>[revert. This mechanism is there to avoid erasing blocks that have been](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L98-L100)</u>

proposed but not yet verified from the buffer. Once a block has been proposed, it can be

proven. Assuming block proposals are uniform over L1 blocks, 99.9% of them will require to be

proven with at least an <u>[SGX proof](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L207-L209)</u> on mainnet. Once proven and after a cooldown period of <u>[1](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L26)</u>

<u>[day](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L26)</u> has passed, a block can then be <u>[verified. During this cooldown period, block proofs can](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L151-L158)</u>

be contested. For SGX-proven blocks, contesting with a proof of the same tier <u>[does not require](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/verifiers/SgxVerifier.sol#L148)</u>

<u>[a valid proof](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/verifiers/SgxVerifier.sol#L148)</u> and resets the <u>[timestamp](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L264)</u> associated with the transaction. Doing so thus resets

the cooling period before the contested block can be <u>[verified.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L151-L158)</u>


However, this makes it possible for a malicious user to DoS block submission by sequentially

contesting blocks with SGX proof as their cooldown period expires. For example, let us


Taiko Protocol Audit − High Severity − 23


assume that 42 blocks have been proposed and proven using SGX, but have not yet been

verified. A malicious user can proceed as follows:


   - Contest the first block with an SGX proof, which requires paying a <u>[contest bond](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L241-L242)</u> of <u>[500](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L25)</u>

<u>[TKO tokens. Note that such a contest](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L25)</u> <u>[does not require a valid SGX proof. This stops the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/verifiers/SgxVerifier.sol#L148)</u>

block verification process during the cooldown period of 24 hours, but blocks continue

being proposed and accumulated to the ring buffer. Assuming a new L2 block is

proposed every <u>[3 seconds, the proposed block ring buffer gets filled up to ~1/42 of its](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoL1.sol#L193-L194)</u>

size during the cooldown.

   - After the 24-hour cooldown window for the first block has elapsed, the malicious user

can then contest the second block in the same way. This again costs 500 TKO tokens

and freezes block verification for 24 hours, during which blocks continue being proposed

and accumulated in the buffer.

   - The malicious user proceeds as above and continues contesting blocks sequentially as

the cooldown periods expire.


At the end of this process, the ring buffer is now filled and proposing new blocks is <u>[impossible.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L98-L100)</u>

The malicious user can continue this process, paying 500 TKO tokens for each additional day

of DoS.


We note that this attack is easy to detect and that it is possible for the guardians to prove the

affected transitions with the highest tier to reduce the cooldown window for verification to <u>[one](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L48)</u>

<u>[hour, increasing the cost of such an attack. The total cost without guardian intervention is](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L48)</u>

around <mark>`42 * 500 = 21000`</mark> TKO tokens, and the highest possible cost assuming guardian

intervention is around <mark>`42 * 500 * 24`</mark> = 504,000 TKO tokens, which is high but not

unreasonable for a motivated attacker. Effective intervention entails guardians being on the

lookout and sending at least five approval transactions on L1 every hour, which is error-prone

and costly. The impact of any error in this process could also be dramatic as guardians cannot

re-prove invalid transitions (see <u>M-01).</u>


The impact of stopping the rollup block proposals is unknown. For example, it could be

increased by DeFi activity emerging on Taiko as lending markets would not be able to process

oracle price updates, which could provide an incentive to a malicious actor to pause the rollup.

In any case, user funds would be stuck.


Consider preventing the contestation of transitions once the cooldown window has expired.

Alternatively, consider monitoring for such situations and adapting the <mark>`contestBond`</mark> or the

<mark>`cooldownWindow`</mark> to make such attacks uneconomical.


**_Update:_** _Resolved in_ _<u>[pull request #16543](https://github.com/taikoxyz/taiko-mono/pull/16543)</u>_ _at commit_ _<u>[37fa853. Transitions can no longer be](https://github.com/taikoxyz/taiko-mono/commit/37fa853bd4d560a8ef0301437303f35f0d0c4c92)</u>_

_contested after the cooldown window has expired, except if a higher level proof is provided._


Taiko Protocol Audit − High Severity − 24


## **Medium Severity**

### **M-01 The Guardian Cannot Re-Prove Invalid** **Transitions - Phase 1**

The highest proof tier is the guardian tier, allowing a <u>[guardian address](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/verifiers/GuardianVerifier.sol#L31-L33)</u> controlled by the

security council to effectively prove any state transition. Should the guardian make a mistake,

the intention of the code is for the guardian to be able to <u>[re-prove a different transition.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L222)</u>

However, when re-proving a different transition for the highest tier, a check is made to ensure

that the <mark>`contestBond`</mark> of the transition is <u>[equal to 0. This check makes any attempt to re-](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L224C48-L224C67)</u>

prove a transition revert, as the <mark>`contestBond`</mark> would have been set to 1 in the <u>[previous](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L389)</u>

<u>[transition proof.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L389)</u>


This revert makes it impossible for anyone to correct an invalid transition when proven once by

the guardian. If such an occurrence were to happen, the only practical solution would be to

upgrade the implementation before the 1-hour cooling window expires to avoid the invalid

transition being verified.


Consider replacing this check by <mark>`ts.contestBond == 1`</mark> <mark>,</mark> as well as adding a

corresponding unit test of the ability for the guardian to re-prove transitions to the test suite.


**_Update:_** _Resolved in_ _<u>[pull request #16543](https://github.com/taikoxyz/taiko-mono/pull/16543)</u>_ _at commit_ _<u>[37fa853.](https://github.com/taikoxyz/taiko-mono/commit/37fa853bd4d560a8ef0301437303f35f0d0c4c92)</u>_

### **M-02 Governor Proposal Creation Is Vulnerable** **to Front Running in OpenZeppelin Contracts -** **Phase 1**


The Taiko governance employs the <u><mark>`[GovernorCompatibilityBravoUpgradeable](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/gov/TaikoGovernor.sol#L5-L6)`</mark></u> contract

from OpenZeppelin version <u>[4.8.2](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/package.json#L38-L39)</u> which is susceptible to a <u>[front running attack. By front](https://github.com/OpenZeppelin/openzeppelin-contracts/security/advisories/GHSA-5h3x-9wvq-w4m2)</u>

running the creation of a proposal, an attacker can take control as the proposer and have the

option to cancel it. This vulnerability can be leveraged to indefinitely prevent the submission of

legitimate proposals, posing a significant risk to the governance process.


Consider updating the OpenZeppelin contracts library to version <u>[4.9.1](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.9.1)</u> or later as these

versions contain the patch for this issue. This will enhance the security and integrity of the

governor proposal mechanism.


Taiko Protocol Audit − Medium Severity − 25


**_Update:_** _Resolved in_ _<u>[pull request #16360](https://github.com/taikoxyz/taiko-mono/pull/16360)</u>_ _at commit_ _<u>[2a0fe95. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/commit/2a0fe9526718bdf799874c7f2b0968f3dda7b6f2)</u>_


_Thank you for reporting this bug. We have upgraded @openzeppelin library to "4.9.6"._

### **M-03 Design Flaw in Bridge Contract Suspension** **Mechanism - Phase 1**


The Bridge contract implements a <u><mark>`[suspendMessages](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L82)`</mark></u> function that can be invoked by either

the owner or a designated watchdog. This function is intended to suspend or unsuspend a

message invocation by updating the <mark>`receivedAt`</mark> field within the message's proof receipt.

Specifically, suspending a message sets this field to the maximum possible value for a

<mark>`uint64`</mark> <mark>,</mark> whereas unsuspending it assigns the current timestamp. This approach introduces a

vulnerability as the <mark>`receivedAt`</mark> field also serves to indicate whether a message has been

proven, with any value greater than zero being interpreted as such. Consequently, the ability to

suspend or unsuspend unproven messages inadvertently marks them as proven due to the

non-zero <mark>`receivedAt`</mark> value.


One significant implication of this flaw is the potential exploitation by the owner or watchdog.

By unsuspending a message and manipulating its data or value to match the bridge's balance

or vaults' tokens balances, they could trigger the <u><mark>`[recallMessage](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L155)`</mark></u> method, effectively

draining all assets from the bridge and the vaults. On a Taiko rollup, the attack can be executed

immediately as there is no invocation delay, and for Ethereum, the attacker needs to wait only

one hour. This could be even more problematic if the attacker does it with a bridged token on

L2, as they could mint an infinite amount of tokens and affect Dapps deployed on the L2.


To mitigate this risk, consider introducing a separate dedicated field within the proof's receipt

structure explicitly for saving the value prior to the suspension. Alternatively, to efficiently

manage the <mark>`receivedAt`</mark> timestamp during suspension and unsuspension events, you can

consider adopting a reversible computation method (e.g., implementing

<mark>`receivedAt = 2 ** 64 - 1 - receivedAt`</mark> offers a pragmatic approach). This method

ensures that upon suspension or unsuspension, the <mark>`receivedAt`</mark> value is transformed in a

manner that allows for the original timestamp to be recovered through the same operation.


**_Update:_** _Resolved in_ _<u>[pull request #16545](https://github.com/taikoxyz/taiko-mono/pull/16545)</u>_ _at commit_ _<u>[c879124. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/commit/c8791241e190b884e1ab008ede0d6455f2c708b2)</u>_


_Thank you for identifying this issue. We've implemented a fix to ensure that even if the_

_bridge_watchdog behaves maliciously, it cannot falsely mark a message as received_

_without proper verification of its delivery._


Taiko Protocol Audit − Medium Severity − 26


### **M-04 Incomplete Role Renunciation in** **TaikoTimelockController Deployment - Phase** **2**

The deployment script <u><mark>`[DeployOnL1](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/script/DeployOnL1.s.sol#L38)`</mark></u> is used by the Taiko team to set up the contracts on the

L1 chain. This includes the <mark>`TaikoTimelockController`</mark> <mark>,</mark> which serves as the owner of the

other contracts. An oversight occurs during the deployment process: the

<mark>`TIMELOCK_ADMIN_ROLE`</mark> <mark>,</mark> which can bypass the timelock delay, is not renounced by the

deployer post-deployment.


Initially, the deployment script sets the <u>[zero address](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/script/DeployOnL1.s.sol#L180C65-L180C75)</u> as the owner in the <mark>`init`</mark> function, but

the actual owner defaults to <u><mark>`[msg.sender](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/common/EssentialContract.sol#L110)`</mark></u> <mark>,</mark> who also receives the <u><mark>`[TIMELOCK_ADMIN_ROLE](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/gov/TaikoTimelockController.sol#L18)`</mark></u> <mark>.</mark>

Although the script revokes the rest of the roles from <mark>`msg.sender`</mark> <u>[after the deployment, the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/script/DeployOnL1.s.sol#L158-L160)</u>

admin role is not revoked. There is a <u>[revoke call](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/script/DeployOnL1.s.sol#L157)</u> targeting <mark>`address(this)`</mark> <mark>,</mark> but this contract

was never assigned the <mark>`TIMELOCK_ADMIN_ROLE`</mark> <mark>.</mark> This means that <mark>`msg.sender`</mark> is still an

admin of the timelock after deployment.


To mitigate this risk and enhance transparency, consider incorporating a <mark>`renounceRole`</mark> call

at the end of the deployment script, allowing the deployer to explicitly renounce the

<mark>`TIMELOCK_ADMIN_ROLE`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #16751](https://github.com/taikoxyz/taiko-mono/pull/16751)</u>_ _at commit_ _<u>[abd18e8.](https://github.com/taikoxyz/taiko-mono/tree/abd18e83fe6dfec9e53753d2607af845925e9928)</u>_

### **M-05 Some ERC-20 and ERC-721 Tokens Can Not** **Be Bridged - Phase 2**


ERC-20 tokens can be bridged through the <u><mark>`[ERC20Vault](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol)`</mark></u> contract by calling the <u><mark>`[sendToken](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L207)`</mark></u>

function. If the token is canonical to this side of the bridge, its <u>[metadata is fetched](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L365-L371)</u> and

transmitted to the other side. This metadata is fetched through external static calls. The same

is done for <u>[ERC-721 tokens.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC721Vault.sol#L203-L208)</u>


However, metadata are defined as optional in the <u>[ERC-20](https://eips.ethereum.org/EIPS/eip-20#name)</u> and <u>[ERC-721](https://eips.ethereum.org/EIPS/eip-721#specification)</u> standards.

Additionally, some tokens such as <u><mark>`[MKR](https://etherscan.io/address/0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2#readContract)`</mark></u> do not respect the standard and return their name and

symbol as a <mark>`bytes32`</mark> instead of a <mark>`string`</mark> <mark>.</mark> The current implementation would revert and

prevent such ERC-20 and ERC-721 tokens from being bridged. Moreover, tokens with empty

<mark>`symbol`</mark> and <mark>`name`</mark> are <u>[permitted](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L369-L370)</u> to bridge, but the deployment of the <mark>`BridgedERC20`</mark>

contract would <u>[fail](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20.sol#L65)</u> on the other side of the bridge and the message would have to be recalled.


Taiko Protocol Audit − Medium Severity − 27


Consider enclosing the calls to fetch the metadata in <mark>`try/catch`</mark> blocks or turning them into

low-level calls, and assigning a default value on failure. Additionally, consider adding support

for <mark>`bytes32`</mark> decoding, and assigning a default value on invalid or empty decodings.

Examples of such decoding functions can be found <u>[here](https://github.com/0xPolygonHermez/zkevm-contracts/blob/main/contracts/PolygonZkEVMBridge.sol#L835-L860)</u> and <u>[here.](https://github.com/OffchainLabs/token-bridge-contracts/blob/b3894ecc8b6185b2d505c71c9a7851725f53df15/contracts/tokenbridge/arbitrum/StandardArbERC20.sol#L50-L61)</u>


**_Update:_** _Resolved at commit_ _<u>[dd8725f. The](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_ _<mark>`symbol`</mark>_ _and_ _<mark>`name`</mark>_ _can now be_ _<mark>`bytes32`</mark>_ _, and_

_they are assigned default values if they do not exist. The_ _<mark>`BridgedERC20`</mark>_ _deployments no_

_longer revert if these properties are empty._

### **M-06 Cross-Chain Owner Cannot Call Privileged** **Functions - Phase 2**


The <u><mark>`[CrossChainOwned](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L14)`</mark></u> abstract contract can be inherited to allow an owner on a different

chain to execute privileged actions on the child contract. For example, the <u><mark>`[TaikoL2](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L21)`</mark></u> contract

inherits from <mark>`CrossChainOwned`</mark> <mark>.</mark> When a <mark>`CrossChainOwned`</mark> contract is called by the

bridge, the cross-chain sender and the original chain are <u>[validated to correspond to the cross-](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L45-L48)</u>

<u>[chain owner, after which an](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L45-L48)</u> <u>[external call](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L50)</u> is made to itself.


However, it is impossible for a cross-chain owner to use this mechanism to call functions

protected by <u><mark>`[onlyOwner](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2EIP1559Configurable.sol#L31)`</mark></u> on <mark>`TaikoL2`</mark> <mark>.</mark> This is because the <mark>`_owner`</mark> variable of the contract

has to match the <u>[address of the cross-chain owner, but the cross-chain owner calling the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L46C47-L46C66)</u>

contract results in the contract calling itself with an <u>[external call. This means that calls to any](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L50)</u>

function protected by <mark>`onlyOwner`</mark> would revert as the <mark>`msg.sender`</mark> would be

<mark>`address(this)`</mark> and not the cross-chain owner. This makes it impossible for the cross-chain

owner to call functions protected by <mark>`onlyOwner`</mark> on the <mark>`TaikoL2`</mark> contract, such as

<u><mark>`[withdraw](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L168)`</mark></u> or <u><mark>`[setConfigAndExcess](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2EIP1559Configurable.sol#L31)`</mark></u> <mark>.</mark>


Consider allowing the cross-chain owner to call privileged functions.


**_Update:_** _Resolved at commit_ _<u>[37fa853. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/commit/37fa853bd4d560a8ef0301437303f35f0d0c4c92#diff-7e648bef3a82cd6a4c5cf63b69fcff267ee72356cb05f42ca4acccc5e3026c5c)</u>_


_Cross-Chain owner got removed (or reworked) and the new is "DelegateOwner", which_

_will have the same role, to act like the owner essentially, for contracts deployed on L2._

### **M-07 Security of ‘SignalService’ Network Is No** **Higher Than Its Weakest Node - Phase 2**


The <mark>`SignalService`</mark> contract handles cross-chain communications. Sending a cross-chain

message sets a <u>[storage slot](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L266)</u> in the local <mark>`SignalService`</mark> <mark>,</mark> and the state of a chain can be


Taiko Protocol Audit − Medium Severity − 28


synchronized to another chain by calling the <u><mark>`[syncChainData](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L68-L79)`</mark></u> function. This state

synchronization is for example done during <u>[L2 block verification](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L219)</u> on L1 or in the <u>[anchor](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L148-L150)</u>

transaction at the beginning of new blocks on L2. Once synchronized, this allows the

destination chain to prove that a signal has been sent from the source chain by doing a Merkle

proof against this chain's state. These proofs are also allowed to be recursive by allowing for

multiple "hops", meaning that L3 -> L1 communication can be done in a single call by proving

that the L3 state was stored to L2 and that the L2 state was stored to L1. To save gas in future

calls, the intermediate states can be <u>[cached locally](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L122)</u> when such a proof is done.


This design effectively creates a network of interconnected chains, where each one is trusted

and can communicate with any other. However, in practice, it is likely different chains will have

very different trust and security assumptions.


For example, there could be two Taiko L2s on top of Ethereum: A canonical one and another

one (called "friendly fork") originally vetted by the canonical Taiko DAO. A Taiko L3 could then

settle to this friendly fork and have their <mark>`SignalService`</mark> be connected to the L3, for

example by social engineering and/or by promising them financial incentives (eg. using their

token as gas, etc.). While the canonical Taiko L2 is owned by the canonical chain's DAO, the

Taiko L3 could be owned by a multisig for security purposes. In such a situation, this multisig

which has not been vetted by the canonical Taiko L2 community could steal assets from the

canonical rollup. Note that direct malicious hop proofs are impossible since the <u>[address](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L117)</u>

<u>resolution of</u> <u><mark>`[SignalService](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L117)`</mark></u> does offer some protection: the L3 address can not be

resolved without the canonical DAO's agreement. However, this protection is insufficient, and

here is how such an attack could be done:


1. The compromised multisig uses the L3 to <u>[synchronize](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L68)</u> an invalid state root from the

friendly fork. This invalid state root contains a malicious message from the friendly fork's

L2 vault to the L1 vault asking for a withdrawal of all the assets in the L1 vault, including

those belonging to the canonical chain.

2. The L3 state root is synchronized to the friendly fork.



3. <mark>`proveSignalReceived`</mark> is called on the friendly fork, with a hop proof that the

malicious message was signaled in the friendly fork's invalid state root, which was

signaled in the L3 state root, which was synchronized to the friendly fork in step 2). Note

that this is possible as multi-hop proofs are allowed to have the same <mark>`chainId`</mark> multiple

times, and the first hop is allowed to have the <mark>`chainId`</mark> of the current chain. The goal of

this step is to cause the malicious friendly fork's state root to be <u>[cached and signaled](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L271-L296)</u> by

the friendly fork itself.

4. The friendly fork's state root is synchronized to the L1.



5. <mark>`processMessage`</mark> is called on the L1 vault with a proof that the malicious message

belongs to the invalid L2 state which was signaled as part of the L2 state, which was


Taiko Protocol Audit − Medium Severity − 29


itself synchronized in step 4). This could for example be used to drain all the assets from

the L1 vaults.


The current design is dangerous as the security of all the rollups in the network depends on its

weakest node: No matter how decentralized the canonical rollup gets, if any centralized chain's

<mark>`SignalService`</mark> is added to the network by anyone else, this centralized actor has the

power to drain the other rollup's assets.


This concern with the current design could be alleviated in multiple ways, for example:


  - Hop proofs should be prevented from containing the same <mark>`chainId`</mark> multiple times.

   - A specification should be written detailing what trust and security assumptions are

required for a new chain to be added to the network and ratified by the DAO as well as

any chain added to the network. Any new chain added to the network would need to be

approved by the canonical DAO, and any violation of these conditions would result in

expulsion from the network.

  - The caching mechanism could be deactivated.

   - If there is no use case for it, <mark>`proveSignalReceived`</mark> could revert if <u><mark>`[_chainId](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L84C16-L84C24)`</mark></u> is the

same as <mark>`block.chainid`</mark> as done in <u>[intermediary hops.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L114-L116)</u>


**_Update:_** _Resolved at commit_ _<u>[dd8725f. Different hops can no longer have the same](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_ _<mark>`chainid`</mark>_ _<mark>,</mark>_

_and the first hop can no longer use the current chain's_ _<mark>`block.chainid`</mark>_ _<mark>.</mark>_

### **M-08 Quota Manager Can Cause Recalled Funds** **to Be Stuck - Phase 3**


ETH and ERC-20 tokens can be sent through the <u><mark>`[ERC20Vault](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L223)`</mark></u> and <u><mark>`[Bridge](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L126)`</mark></u> contracts,

respectively. When funds are sent from these contracts to the users, <u><mark>`[consumeQuota](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/QuotaManager.sol#L60)`</mark></u> is called

on the <mark>`QuotaManager`</mark> contract.


However, the quota is not checked when sending funds from the users to the contracts. This

makes it possible for a user to send funds, mark the message as failed on the destination

chain, but not be able to recall their message and claim their funds back on the source chain

<u>[[1]](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L190)</u> <u>[[2]](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L347)</u> if the amount exceeds the maximum quota. Hence, these funds would be stuck until the

quota is increased or removed.


Consider validating during message sending that the funds sent are lower than the current

quota to avoid issues when recalling messages.


Taiko Protocol Audit − Medium Severity − 30


**_Update:_** _Acknowledged, not resolved. The likelihood of this issue justifies not introducing_

_additional code changes. However, assets that have a quota are recommended to be monitored_

_to check for the scenario depicted above. The Taiko team stated:_


_Quota only applies to tje ERC20 vault and we believe for ETH and tokens whose quota_

_is configured to be non-zero (USDC, USDT, TKO), it is very unlikely the claiming will fail_

_thus the message be marked as failed on the destination chain._

### **M-09 Reached Quota Can Cause Loss of Fee -** **Phase 3**


The <mark>`Bridge`</mark> contract calls <u><mark>`[consumeQuota](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L624C41-L624C53)`</mark></u> on the <mark>`QuotaManager`</mark> contract when sending

ETH. This notably happens during <u>[message processing. If the message is processed by its](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L247)</u>

<mark>`destOwner`</mark> and the maximum quota is reached, the message is set to <u>[retriable. The message](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L248-L250)</u>

can then either be retried or set as <u>[failed](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L339)</u> and recalled on the source chain. However,

<mark>`message.fee`</mark> is lost in such a situation as it is not refunded to the <mark>`msg.sender`</mark> <mark>.</mark>


Consider adding a condition to return the fee to the <mark>`destOwner`</mark> if the fee is non-zero and

does not exceed the available quota. In case <mark>`message.fee`</mark> exceeds the available quota,

consider reverting to protect users from losing their fee. Note that this would mean any

message with a fee exceeding the quota would be stuck until the quota is raised. In addition,

and to mitigate such issues, consider having the same quotas on L1 and L2, and validating

when sending a message that the value sent (inclusive of the fee) does not exceed the quota.

As quotas are only expected to increase over time, it would then be possible to simply revert

when processing a message which exceeds the quota.


**_Update:_** _Resolved in_ _<u>[pull request #17411](https://github.com/taikoxyz/taiko-mono/pull/17411)</u>_ _by refunding the value and fee in the_

_<mark>`retryMessage`</mark>_ _function. However, this fix was followed-up with_ _<u>[pull request #17446, where](https://github.com/taikoxyz/taiko-mono/pull/17446)</u>_

_<mark>`processMessage`</mark>_ _reverts when the quota is reached or (a part of) the fee is refunded. If the_

_message goes into retriable state and is unable to be invoked, the value is also refunded._


Taiko Protocol Audit − Medium Severity − 31


## **Low Severity**

### **L-01 Assigned Prover Signature Is Underspecified** **- Phase 1**

The <mark>`AssignmentHook`</mark> contract is a canonical hook that can be used by proposers during

block proposals. The proposer sends to the hook a signature that was given by a prover that

contains <u>[information](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/hooks/AssignmentHook.sol#L146-L161)</u> about the proving fees as well as the proposed block. This, for example,

protects provers against being paid a smaller fee to prove a bigger block than agreed upon.

These signatures can either come from EOAs or contracts using <u>[EIP-1271 signatures.](https://eips.ethereum.org/EIPS/eip-1271)</u>


However, the current signature scheme does not include the assigned prover address, which

allows for signatures to be valid across several smart wallets sharing an owner. Let us assume,

for example, that Alice owns two smart wallets, `A` and `B`, and expects the assigned prover to

be wallet `A` . Then, wallet `B` can be used as the assigned prover, since the signature would

indeed originate from Alice and does not constrain it to being used only with wallet `A` . While

already done by some smart contract wallets, consider including the user address - in this case

the assigned prover address - in the signature to avoid potential issues. An example of such a

vulnerability, allowing signature replay across smart wallets can be found <u>[here.](https://mirror.xyz/curiousapple.eth/pFqAdW2LiJ-6S4sg_u1z08k4vK6BCJ33LcyXpnNb8yU)</u>


Furthermore, there is no way for a prover to cut an exclusive deal with a block proposer. While

the data signed includes the <mark>`metaHash`</mark> and thus the <mark>`block.coinbase`</mark> address, the block

could be proposed by a different address than the one designated as <mark>`block.coinbase`</mark> <mark>.</mark>

Provers may want to have a simple mechanism to prove any block proposed by a designated

address.


Consider including the assigned prover in the <mark>`AssignmentHook`</mark> signed data to avoid

potential issues with smart wallets. Additionally, consider including the address of the block

proposer in the data signed by the provers.


**_Update:_** _Resolved in_ _<u>[pull request #16665](https://github.com/taikoxyz/taiko-mono/pull/16665)</u>_ _at commit_ _<u>[2b27477.](https://github.com/taikoxyz/taiko-mono/commit/2b27477ec0f9e5f0e0326d302531f93ff2c65de3)</u>_

### **L-02 The Snapshooter Cannot Take Snapshots of** **the Taiko Token - Phase 1**


The <u>[Taiko token, designed with snapshot capabilities through inheritance from the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoToken.sol)</u>

<mark>`ERC20SnapshotUpgradeable`</mark> contract of the OpenZeppelin library, has an initialization flaw.


Taiko Protocol Audit − Low Severity − 32


This token uses a <u><mark>`[snapshot](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoToken.sol#L52)`</mark></u> method, designed to give both the token's owner and a

designated snapshooter the ability to take snapshots. However, an initialization error within the

<mark>`EssentialContract`</mark> - a contract defining the <mark>`onlyFromOwnerOrNamed`</mark> modifier to

ensure exclusive access for the owner and snapshooter to a method — affects the

functionality.


Specifically, the <mark>`EssentialContract`</mark> attempts to manage its initialization through two

distinct versions of the <u><mark>`[__Essential_init](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/common/EssentialContract.sol#L95-L112)`</mark></u> initializer. The first variant establishes ownership

and sets the paused state to <mark>`false`</mark> <mark>,</mark> whereas the second variant, in addition to executing the

tasks of the first, sets the <mark>`addressManager`</mark> for the resolver. The issue arises from the fact

that the <mark>`TaikoToken`</mark> contract uses the former variant, which neglects defining the

<mark>`addressManager`</mark> <mark>,</mark> thereby making resolutions of the snapshooter's address return the zero

address. This oversight blocks the snapshooter from performing their intended role, as the

absence of a valid <mark>`addressManager`</mark> setting cannot be rectified post-initialization, forcing a

contract upgrade for resolution.


Consider using the <mark>`__Essential_init`</mark> initializer that properly incorporates the

<mark>`addressManager`</mark> <mark>.</mark> This change ensures the system's architecture aligns with its designed

capabilities, enabling the snapshooter to fulfill their role in snapshot management.


**_Update:_** _Resolved in_ _<u>[pull request #16394](https://github.com/taikoxyz/taiko-mono/pull/16394)</u>_ _at commit_ _<u>[c64ec19.](https://github.com/taikoxyz/taiko-mono/commit/c64ec193c95113a4c33692289e23e8d9fa864073)</u>_

### **L-03 Inefficient Feature Inclusion in** **EssentialContract - Phase 1**


The <u><mark>`[EssentialContract](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/common/EssentialContract.sol)`</mark></u> serves a critical role across various contracts in the protocol by

inheriting features such as pausability, reentrancy protection, and access to an address

manager. However, not all inheriting contracts fully utilize these features. This design does not

align with the Solid Principle of single responsibility which advocates for a system design that

promotes separation of concerns for efficiency and reduced error likelihood.


To enhance modularity and adherence to the single responsibility principle, consider splitting

the <mark>`EssentialContract`</mark> into distinct contracts by responsibility. This approach enables

contracts to only inherit the necessary features, thereby streamlining the codebase and

minimizing unnecessary complexity.


**_Update:_** _Acknowledged, not resolved. The Taiko team stated:_


_Thank you for your feedback. We have decided not to adopt the suggested approach,_

_as we believe the associated risks are minimal and manageable._


Taiko Protocol Audit − Low Severity − 33


### **L-04 L2 Block Difficulty Is Susceptible to** **Manipulation - Phase 1**

When proposing an L2 block on L1, the <mark>`difficulty`</mark> associated with the block is <u>[computed](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L204)</u>

as the hash of <mark>`(block.prevrandao, numBlocks, block.number)`</mark> <mark>.</mark> This difficulty is

used to compute the <u>[minimum tier](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L207-L209)</u> associated with proving the block and is also used on L2 as

the value returned when calling <mark>`block.prevrandao`</mark> <mark>.</mark> Block proposers can propose multiple

blocks in one transaction <u>[using blobs.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L182)</u>


However, the <mark>`difficulty`</mark> can be biased by the proposer by proposing multiple blocks. For

example, this means that proposers can predict before the block proposal if proving the block

will require a zk proof or an SGX proof. If the cost difference between zk and SGX proving

warrants it, block proposers could in the same transaction submit multiple empty blocks, and

include L2 transactions only when the difficulty is such that an SGX proof is required,

effectively only using SGX to prove non-empty blocks and partially avoiding the minimum tier

mechanism.


Similarly, depending on how the <mark>`block.prevrandao`</mark> is used by contract developers on L2,

this could incentivize block proposers to bias the difficulty at the time of L2 transaction

inclusion. While each L1 validator can have one bit of influence over <mark>`block.prevrandao`</mark> on

L1, the ability to atomically propose multiple L2 blocks and choose in which to include L2

transactions give them more control over the L2 <mark>`block.prevrandao`</mark> than may be assumed

by application developers.


Consider monitoring proposers for abuses of their privilege when proposing multiple blocks

and choosing where to include transactions. In practice, the profitability of such strategies will

depend on the fixed costs in gas associated with block proposals compared to the cost of zk

proofs. If this issue was observed in practice, potential solutions could include the use of a

VRF oracle, or disabling the ability for proposers to propose multiple blocks in one transaction.

No matter which option is chosen, consider documenting any control block proposers may

have over <mark>`block.prevrandao`</mark> on L2, as this is important for application developers.


**_Update:_** _Acknowledged, not resolved. The Taiko team stated:_


_Internally we have been back and forth regarding how to decide a block's min tier. There_

_is no perfect solution without major protocol design changes. The current decision is_

_that we keep this part of the code as-is, at least for now._


Taiko Protocol Audit − Low Severity − 34


### **L-05 Uncontrolled Gas Consumption When** **Sending ETH in Cross-Chain Messages - Phase 1**

Cross-chain messages can be sent through the <mark>`Bridge`</mark> contract by calling the

<u><mark>`[sendMessage](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L115)`</mark></u> function on one side and <u><mark>`[processMessage](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L217)`</mark></u> on the other. Messages can

include a <u>[fee](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/IBridge.sol#L38-L39)</u> to incentivize relayers to process messages automatically on the destination

chain. As the gas limit is specified in the message, relayers can simulate in advance to know if

processing a message is profitable.


However, when sending the funds to the target address on the destination chain, all the gas is

forwarded. This is because calling <u><mark>`[sendEther](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/LibAddress.sol#L43)`</mark></u> on an address without specifying a gas

amount forwards all the gas. In practice, this would make it harder for relayers to estimate the

gas costs associated with processing a message.


Consider only passing a fixed amount of gas when forwarding the refund to the refund address

to make it easier for relayers to estimate the maximum amount of gas consumed when

processing a message.


**_Update:_** _Resolved in_ _<u>[pull request #16666](https://github.com/taikoxyz/taiko-mono/pull/16666)</u>_ _at commit_ _<u>[4909782.](https://github.com/taikoxyz/taiko-mono/commit/4909782194ae025ff78438126c1e595f404e16a9)</u>_

### **L-06 Honest Provers Can Lose Money - Phase 1**


When proposing a block, a prover is <u>[assigned](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L225)</u> to prove it. This assigned prover is the <u>[only one](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L419-L421)</u>

who can prove the first transition of this block for the duration of the proving window, in

exchange for <u>[providing a liveness bond. This liveness bond can be](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/hooks/AssignmentHook.sol#L102)</u> <u>[lost](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L184-L186)</u> if the proven state

transition is later proven invalid by a higher level proof, but is returned if the transaction was

<u>[not contested.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L184C21-L184C52)</u>


However, it is possible for an honest prover to lose TKO tokens when assigned to a block if

another malicious actor is ready to lose more. For example, let us name Henry an honest

prover, Mallory a malicious user, and look at the following sequence of events:


1. Henry is assigned to prove a block, and sends <u>[250 TKO](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoL1.sol#L207)</u> as liveness bond to the

<mark>`TaikoL1`</mark> contract. He correctly proves the state transition with an SGX proof, providing

another <u>[250 TKO](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L24)</u> as validity bond.

2. Mallory contests the state transition, providing <u>[500 TKO](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L25)</u> as contest bond to the

<mark>`TaikoL1`</mark> contract.

3. In the same transaction, Mallory re-proves the block and confirms Henry's transition

using a zk proof. In doing so, Henry earns <u><mark>`[1/4 * contestBond = 125](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L366-L367)`</mark></u> TKO, and


Taiko Protocol Audit − Low Severity − 35


gets his original validity bond of 250 TKO back. Mallory gets <mark>`1/4 * contestBond =`</mark>

<mark>`125`</mark> TKO as she is the new prover. She provides a new validity bond of <u>[500 TKO.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L35)</u>

4. The block is verified, and Mallory as the final prover gets back half of the liveness bond

as well as her validity bond, <mark>`1/2*250 + 500 = 625`</mark> TKO in total.


As a result of the above, Henry has lost his initial liveness bond but got 1/4th of the contest

bond, a net loss of <mark>`125`</mark> TKO. Mallory has lost 3/4th of her contest bond but got back half of

the liveness bond, a net loss of <mark>`250`</mark> TKO.


While Mallory lost more than Henry, Henry was honest but still lost money. If Mallory is

malicious, has a lot of TKO tokens and wants to establish herself as the sole prover of Taiko

blocks, she could for example systematically contest any SGX transition on a block she is not

an assigned prover of, in order to disincentivize anyone but herself to prove blocks. This could

be used in an attempt to get a monopoly on block proving. Alternatively, she could attempt to

contest any SGX proof in order to disincentivize blocks from being proven at all.


Note that the scenario above can be mitigated if Henry initially provides a zk proof, as the

guardian has the option of <u>[returning the liveness bond](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L189-L199)</u> to the assigned prover when resolving a

contest. Such a defense strategy however would only work for zk proofs and would require

constant interventions from the guardian.


Consider adding a mechanism to return the liveness bond to the assigned prover in scenarios

where a block has been contested but the assigned prover's proposed transition was valid.


**_Update:_** _Resolved at commit_ _<u>[dd8725f. The liveness bond is now returned directly to the](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_

_assigned prover when the block is proven within the proving window, or if the guardian_

_intervenes and decides to return the liveness bond._

### **L-07 Duplicated USDC Bridging - Phase 2**


The <u><mark>`[sendToken](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L207)`</mark></u> function can be called to bridge an ERC-20 token, represented as another

token on the destination chain. Initially, native USDC on Ethereum L1 will be <u>[represented as a](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L407-L433)</u>

<u>[BridgedERC20](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L407-L433)</u> on Taiko L2s. Later, if a native USDC is deployed on a Taiko L2, it is possible to

migrate to this native USDC version by <u>[migrating](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L148C14-L148C32)</u> the <mark>`BridgedERC20`</mark> version of USDC

through a <u><mark>`[USDCAdapter](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/adapters/USDCAdapter.sol#L28-L50)`</mark></u> contract.


However, this configuration by default makes it possible to bridge USDC from L2 to L1 in two

different ways. The first one is to bridge the <mark>`USDCAdapter`</mark> <mark>,</mark> which after the migration would

bridge to the native USDC on L1. The second way is to bridge the new native USDC on Taiko

L2 directly as it is a <u>[canonical token, which would thus bridge to a newly deployed](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L363-L380)</u>


Taiko Protocol Audit − Low Severity − 36


<mark>`BridgedERC20`</mark> on L1. This dual-path approach risks confusing users and fragmenting USDC

liquidity across Taiko's rollup ecosystem.


Consider keeping only one way to bridge USDC after the migration. This could be achieved by

<u>[blacklisting](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L52)</u> bridging native Taiko USDC token directly to force users to bridge through the

<mark>`USDCAdapter`</mark> <mark>.</mark>


**_Update:_** _Resolved at commit_ _<u>[dd8725f. USDC and](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_ _<mark>`BridgedERC20`</mark>_ _tokens now use a common_

_interface, so the_ _<mark>`USDCAdapter`</mark>_ _was removed._

### **L-08 ERC20Airdrop Claims Can Be DOSed -** **Phase 2**


The <mark>`ERC20Airdrop`</mark> contract allows users to <u>[claim tokens](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/ERC20Airdrop.sol#L50-L72)</u> by providing a Merkle proof of their

airdrop. To do so, users can call the <u><mark>`[claimAndDelegate](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/ERC20Airdrop.sol#L50C14-L50C30)`</mark></u> function and have to provide

airdrop information as well as a signature to <u>[delegate their tokens.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/ERC20Airdrop.sol#L71)</u>


However, the transaction calling <mark>`claimAndDelegate`</mark> is susceptible to a frontrunning attack

where an adversary could independently use the user's signature with the <mark>`ERC20Votes`</mark>

token. This action consumes the nonce and causes the user's original transaction to revert,

thereby blocking them from claiming their tokens.


Consider making it possible for users to claim without delegating, for example by adding a

second function or by wrapping the <mark>`delegateBySig`</mark> in a <mark>`try/catch`</mark> clause.


**_Update:_** _Resolved in_ _<u>[pull request #16738. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/pull/16738)</u>_


_Removed the delegation part._

### **L-09 TimelockTokenPool Signatures Can Be** **Replayed - Phase 2**


The <u><mark>`[TimelockTokenPool](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L25)`</mark></u> contract will be deployed multiple times to <u>[allocate grants to](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L20-L24)</u>

<u>[investors, team members and other grantees. The status of granted tokens goes from locked](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L20-L24)</u>

to owned to unlocked <u>[over time. Once unlocked, the amount can be claimed by calling the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L245-L265)</u>

<u><mark>`[withdraw](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L161-L173)`</mark></u> function. <u>[One](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L168)</u> of the two <mark>`withdraw`</mark> functions takes as arguments a destination

address and a signature. The signed data is validated to correspond to
```
keccak256(abi.encodePacked("Withdraw unlocked Taiko token to: ",
```

<u><mark>`[_to))](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L170C24-L170C94)`</mark></u> <mark>.</mark>


Taiko Protocol Audit − Low Severity − 37


However, such signatures can be replayed to claim tokens for anyone else at any time, causing

multiple potential issues. For example, tokens claimed for investors or team members could

cause unexpected and increased tax obligations. Additionally, since claiming tokens has a

fixed <u>[cost](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L198)</u> per claimed token, this could be used to force the recipient to lose money if the price

of the claimed tokens is lower than the cost paid. Note that since the <mark>`TimelockTokenPool`</mark>

contract will be deployed <u>[multiple times](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L20C22-L20C41)</u> on one chain, signatures could be replayed across

several of these contracts if they share a common grantee address. If the timelock is intended

to be deployed across multiple chains, signatures could also in theory be replayed across

chains.


Consider preventing signature replay across time, for example by adding a nonce. Additionally,

consider adding the contract address to the signed data to avoid signature replay across

multiple instances of the <mark>`TimelockTokenPool`</mark> contract, as well as adding the <mark>`chainid`</mark> if it

is intended to be deployed across multiple chains. If the data is intended to be signed through

third-party frontends, <u>[EIP-712](https://eips.ethereum.org/EIPS/eip-712)</u> could also be integrated.


**_Update:_** _Resolved in_ _<u>[pull request #16934. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/pull/16934)</u>_


_Ackowledged and removing the whole contract. The new ones are under_

_supplementary-contracts package (in the repo) so not part of protocol anymore._

_Unlocking is simplified and no signature based withdrawals._

### **L-10 evaluatePoint Precompile Calls Revert -** **Phase 2**


The <u><mark>`[evaluatePoint](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/Lib4844.sol#L30C14-L30C27)`</mark></u> function is used to validate that the opening of a KZG Commitment

(corresponding to a blob in practice) at a point `x` is equal to the purported `y` by calling

Ethereum's <u>[point evaluation precompile. This precompile expects its commitment and proof](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/Lib4844.sol#L43-L45)</u>

arguments to be <u>[48 bytes each.](https://www.evm.codes/precompiled#0x0a?fork=cancun)</u>


However, the <mark>`_commitment`</mark> and <mark>`_pointProof`</mark> arguments are of type <mark>`bytes1[48]`</mark>, and

passed by calling <u><mark>`[abi.encodePacked](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/Lib4844.sol#L44)`</mark></u> <mark>.</mark> The packed encoding of a <mark>`bytes1[48]`</mark> is done in
place without the length but with each element <u>[padded to 32 bytes. This means that the](https://docs.soliditylang.org/en/v0.8.24/abi-spec.html#abi-packed-mode)</u>

commitment and proof arguments sent to the precompile are <mark>`32 * 48 = 1536`</mark> instead of 48

bytes long, and thus the first padded 3 bytes of the commitment are erroneously interpreted as

representing both the commitment and the proof. Because these are padded and mostly 0s,

they are unlikely to correspond to a valid commitment/proof pair.


In practice, this means that any normal call to the point evaluation precompile would revert.

Additionally, gas could be <u>[saved](https://docs.soliditylang.org/en/v0.8.24/types.html#bytes-and-string-as-arrays)</u> by changing the type of these <u>[arguments](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/Lib4844.sol#L34-L35)</u> to <mark>`bytes`</mark> and


Taiko Protocol Audit − Low Severity − 38


validating their length separately. We note that while the <mark>`Lib4844`</mark> library is in the scope of

this audit, it is not currently used by the contracts in scope.


Consider changing the <mark>`_commitment`</mark> and <mark>`_pointProof`</mark> arguments to be of type <mark>`bytes`</mark> .

Additionally, if the <mark>`Lib4844`</mark> is intended to be used in practice, consider adding tests targeting

this library.


**_Update:_** _Resolved in_ _<u>[pull request #16969. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/pull/16969)</u>_


_This file has been deleted._

### **L-11 Vaults Are Not ERC-165 Compliant - Phase 2**


Token vaults inherit from the <u><mark>`[BaseVault](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BaseVault.sol#L12)`</mark></u> contract. This contract implements the <mark>`IERC165`</mark>

interface and exposes the <u><mark>`[supportsInterface](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BaseVault.sol#L39-L41)`</mark></u> function.


However, ERC-165 <u>[states](https://eips.ethereum.org/EIPS/eip-165#how-a-contract-will-publish-the-interfaces-it-implements)</u> that ERC_165 compliant interfaces have to return <mark>`true`</mark> when

<mark>`interfaceID`</mark> is <mark>`0x01ffc9a7`</mark> (the EIP-165 interface ID). Following the steps from <u>[ERC-165](https://eips.ethereum.org/EIPS/eip-165#how-to-detect-if-a-contract-implements-erc-165)</u>

to detect if the vaults implement ERC-165 would thus return false.


Consider adding the ERC-165 interface ID to the supported interfaces.


**_Update:_** _Resolved in_ _<u>[pull request #16935.](https://github.com/taikoxyz/taiko-mono/pull/16935)</u>_

### **L-12 Token Migrations Can Cause Losses - Phase** **2**


Tokens inheriting from the <u><mark>`[BridgedERC20Base](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol)`</mark></u> contract can be <u>[migrated](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L43)</u> by the owner or by

calling the <u><mark>`[changeMigrationStatus](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L36)`</mark></u> function of the <mark>`ERC20Vault`</mark> <mark>.</mark> If a migration is

triggered, token owners can <u>[burn](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L76-L82)</u> their tokens to mint the same amount of tokens on the new

contract. If the migration is triggered by the bridge, old tokens are <u>[added to a blacklist](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L181)</u> and

have to be migrated before being able to bridge.


However, there are multiple migration scenarios that could cause accidental user losses:


   - If a new migration is triggered before some users have migrated from a previous

migration, then these users would effectively lose their tokens as they would <u>[no longer](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L61-L63)</u>

<u>[be able to call](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L61-L63)</u> <u><mark>`[mint()](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L61-L63)`</mark></u> on the new contract nor bridge their tokens.

   - If a <u>[migration](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L43)</u> is triggered by the owner instead of the <mark>`ERC20Vault`</mark> <mark>,</mark> the vault would no

longer be able to call <mark>`burn`</mark> or <mark>`mint`</mark> on the migrated token. This would prevent users


Taiko Protocol Audit − Low Severity − 39


from bridging and could cause losses as the new migrated token would not be bridging

to the same contract when <u>[bridging through the vault.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L207)</u>

   - If a migration happens to a token that doesn't implement the <mark>`IBridgedERC20`</mark>

interface, user losses could happen as well.


If such concerns are shared, consider addressing the above instances to protect users' funds

from errors during migrations. Potential solutions include adding a delay to migrations during

which no new migration can be done, preventing the owner from calling

<mark>`changeMigrationStatus`</mark> <mark>,</mark> and validating that the new token implements the

<mark>`IBridgedERC20`</mark> using <u>[ERC-165](https://eips.ethereum.org/EIPS/eip-165)</u> during migrations.


**_Update:_** _Resolved at commit_ _<u>[dd8725f. A minimal delay of 90 days between migrations was](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_

_added to give users time to migrate. Additionally, the owner is now prevented from triggering_

_migrations. We note that the new token is not enforced to support_

_<mark>`IBridgedERC20Migratable`</mark>_ _<mark>,</mark>_ _as this would prevent migrating from a bridged token to a_

_canonical implementation on Taiko. Migration of such token would have to be handled by the_

_DAO to avoid loss of funds._

### **L-13 Unexpected Features in BridgedERC20** **Tokens - Phase 2**


When an ERC20 token is bridged from a source chain to a destination chain via the

<u><mark>`[ERC20Vault](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC1155Vault.sol)`</mark></u> <mark>,</mark> it results in the creation of a <u><mark>`[BridgedERC20](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20.sol)`</mark></u> token. The <mark>`BridgedERC20`</mark>

implementation currently includes extra functionalities such as voting, snapshot capabilities,

upgradability, and pausability, which may not be present in the original canonical token. This

discrepancy could lead to confusion as users might not expect these additional features in the

bridged token representation.


To address this issue, consider adopting a simpler <mark>`BridgedERC20`</mark> implementation that

retains only the essential features of an ERC20 token or to clearly documenting the additional

functionalities. Clear documentation will ensure that users are fully informed about the

capabilities of the bridged tokens, preventing any potential misunderstanding.


**_Update:_** _Partially resolved in_ _<u>[pull request #16950. The](https://github.com/taikoxyz/taiko-mono/pull/16950)</u>_ _<mark>`BridgedERC20`</mark>_ _token contract no_

_longer offers the vote/checkpoint feature. Remaining features like upgradability and pausability_

_should be thoroughly documented, both within the contract itself and in external resources._


Taiko Protocol Audit − Low Severity − 40


### **L-14 Banned Addresses Could Be Called By** **Cross-Chain Messages - Phase 2**

The status of messages sent to addresses in the <mark>`addressBanned`</mark> mapping of the <mark>`Bridge`</mark>

contract is <u>set to</u> <u><mark>`[DONE](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L269-L277)`</mark></u> <mark>.</mark> Otherwise, the message can be retried if it fails.


However, the check for banned addresses is not made when <u>[retrying](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L330-L335)</u> a message. This makes it

theoretically possible for a message to call a newly banned address if its status was set to

<mark>`RETRIABLE`</mark> before the address got added to the <mark>`addressBanned`</mark> mapping. This could for

example be exploited if future deployment addresses are predictable and the code is open

source, by calling such functions before the contract is deployed and its address is banned.

This would set up dormant messages which can be processed later.


Consider checking the target of messages in the <mark>`retryMessage`</mark> function to avoid potential

issues.


**_Update:_** _Resolved in pull request_ _<u>[#16394](https://github.com/taikoxyz/taiko-mono/pull/16604)</u>_ _at commit_ _<u>[a6470a1. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/pull/16604/commits/a6470a1d1729759e6d2bfc564f9ec3cb3957d3ca)</u>_


_Not only because of this but also to avoid confusing, we removed the banning address_

_feature completely._

### **L-15 Some Bridged Messages Can Not Be** **Refunded - Phase 2**


When <u>[processing](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L217)</u> a message on its destination chain's <mark>`Bridge`</mark> contract, a refund can be

emitted if the target address was <u>["banned". This refund is always](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L269-L277)</u> <u>[sent](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L294-L300)</u> to the <mark>`refundTo`</mark> or the

<mark>`destOwner`</mark> address, even if this refund is 0. If the refund is unsuccessful, the call to

<mark>`processMessage`</mark> <u>[reverts. Otherwise, if the refund and the message call were successful, the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/LibAddress.sol#L36)</u>

status of the message is set to <u><mark>`[DONE](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L283)`</mark></u> or <u><mark>`[RETRIABLE](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L285)`</mark></u> <mark>.</mark> A message with the <mark>`RETRIABLE`</mark> status

can then be retried and its status set to <u><mark>`[FAILED](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L334)`</mark></u> if desired. This allows for the message to be

<u>[recalled](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L178-L181)</u> on the source chain so its original sender can be <u>[refunded.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L195-L207)</u>


However, this makes it possible for messages whose <mark>`refundTo`</mark> or <mark>`destOwner`</mark> address do

not accept ETH to always revert when processed on the destination chain, making the

message not recallable. As such messages can never be recalled, the sender would have lost

funds. Note that because the refund is always sent even with a value of 0, this could happen

even if the destination address is not <u>[banned. This could for example happen if](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L275)</u> <mark>`refundTo`</mark> is

a contract without a <mark>`receive`</mark> or a <mark>`fallback`</mark> function.


Taiko Protocol Audit − Low Severity − 41


Consider not calling <mark>`sendEther`</mark> when the refund sent is 0. This would prevent the above

from occurring except when the target address is banned, in addition to saving gas.

Alternatively and to account for this last case if desired, consider setting the status of

messages targeting banned addressed to <mark>`FAILED`</mark> instead of <mark>`DONE`</mark> <mark>.</mark> This would allow

removing the concept of refunds entirely, simplifying the code, and allowing for these

messages to be recalled by their original sender.


**_Update:_** _Partially resolved at commit_ _<u>[dd8725f. The ban of addresses was removed, and](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_

_message processing now uses_ _<mark>`sendEtherAndVerify`</mark>_ _which does not trigger an external call_

_if the value sent is 0. We note that it is however still possible for funds to get stuck if the_

_<mark>`destOwner`</mark>_ _is a contract without payable_ _<mark>`fallback`</mark>_ _and_ _<mark>`receive`</mark>_ _functions._

### **L-16 ‘DelegateOwner’ Does Not Check for** **Contract Existence - Phase 3**


The <u><mark>`[DelegateOwner](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol)`</mark></u> contract is intended to be deployed on L2 and set as the owner of all

the other L2 contracts. The DAO on L1 can <u>[then call it through the](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L75-L85)</u> <u><mark>`[Bridge](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L75-L85)`</mark></u> <u>contract</u> to

execute arbitrary calls in its name. This could, for example, be used by the DAO to execute

privileged functions on L2 from L1. Calls from the <mark>`DelegateOwner`</mark> can be either <u>[low-level](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L109-L111)</u>

<u>[calls or delegate calls](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L109-L111)</u> based on an <u>[input parameter.](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L109C47-L109C66)</u>


However, low-level calls in Solidity do not check for contract existence. Such calls could thus

be considered <u>[successful](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L113-L114)</u> if the contract called has not been deployed yet, resulting in silent

failures.


Consider validating the contract's existence if the given <u><mark>`[call.txdata](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L111C52-L111C63)`</mark></u> is non-empty.


**_Update:_** _Resolved in_ _<u>[pull request #17328](https://github.com/taikoxyz/taiko-mono/pull/17328)</u>_ _at commit_ _<u>[39505e5](https://github.com/taikoxyz/taiko-mono/pull/17328/commits/39505e5caedd74ae5291711c3708c10c8db2b5e4)</u>_ _and_ _<u>[pull request #17480](https://github.com/taikoxyz/taiko-mono/pull/17480)</u>_ _at_

_commit_ _<u>[60d5d22.](https://github.com/taikoxyz/taiko-mono/pull/17480/commits/60d5d2233077162f8a26ba691524c5a64c61475f)</u>_

### **L-17 Storage Collision in Bridge Contract - Phase** **3**


The <mark>`Bridge`</mark> implementation was upgraded. The previous implementation stored

<u><mark>`[nextMessageId](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L31)`</mark></u> <u>as a</u> <u><mark>`[uint128](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L31)`</mark></u> in storage slot 251. The new implementation stores two

<mark>`uint64`</mark> values instead, <u><mark>`[__reserved1](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L61-L62)`</mark></u> <u>[and](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L61-L62)</u> <u><mark>`[nextMessageId](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L61-L62)`</mark></u> <mark>,</mark> declared in that order.


However, this creates a storage conflict as packed storage slots are filled right to left and

lower-order aligned. This means that a <mark>`nextMessageId`</mark> with value 10 in the old version


Taiko Protocol Audit − Low Severity − 42


would upgrade to a <mark>`__reserved1`</mark> of 10 and a <mark>`nextMessageId`</mark> of 0. While <mark>`__reserved1`</mark>

is set back to 0 in the <u><mark>`[init2](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L118-L123)`</mark></u> function, the <mark>`nextMessageId`</mark> would restart from 0. We note

that because the <mark>`Bridge`</mark> contract is disabled on the mainnet, it is impossible for users to

increment <mark>`nextMessageId`</mark> <mark>.</mark> It is thus unlikely to cause issues in practice.


Consider validating that <mark>`nextMessageId`</mark> was not incremented before upgrading the contract

to avoid loss of funds.


**_Update:_** _Resolved. The Taiko team stated:_


_This issue affects the testnet since the previous version of the code was deployed._

_Fortunately, no one exploited this bug to manipulate the bridge and steal testnet tokens._


_We now have a script to automatically verify that storage layouts are compatible with the_

_previous version. On the testnet, we will avoid upgrades that could cause these kinds of_

_issues._

### **L-18 Inexplicit Revert - Phase 3**


When a token is bridged through the <mark>`ERC20Vault`</mark> contract, the destination chain message

value is derived as <u><mark>`[msg.value - _op.fee](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L245)`</mark></u> <mark>.</mark> However, this can lead to an underflow revert if

the provided fee exceeds the message value.


Consider checking the values beforehand, as done in the <u><mark>`[Bridge](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L150)`</mark></u> <u>contract.</u>


**_Update:_** _Resolved in_ _<u>[pull request #17329](https://github.com/taikoxyz/taiko-mono/pull/17329)</u>_ _at commit_ _<u>[f8042a2.](https://github.com/taikoxyz/taiko-mono/commit/f8042a262b69f39037ec4357b72473be1d3106ce)</u>_

### **L-19 Unrestricted Receive Function - Phase 3**


The <mark>`Bridge`</mark> contract implements a <u><mark>`[receive](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L109)`</mark></u> <u>function</u> that allows anyone to send ETH to the

contract. This might be necessary during setup to meet the amount of ETH that was minted in

the genesis state on L2 and is in circulation on the rollup. However, for users interacting with

the bridge, it can be a pitfall to accidentally get their funds locked.


Consider restricting the <mark>`receive`</mark> function to the owner role, or finding another way to balance

these amounts between L1 and L2.


**_Update:_** _Resolved in_ _<u>[pull request #17330](https://github.com/taikoxyz/taiko-mono/pull/17330)</u>_ _at commit_ _<u>[4ef2847. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/commit/4ef28475dfc61d6a6c877f5d4e2ddee4932d0726)</u>_


_Currently our approach is to remove the receive, but only after the genesis, once we_

_seeded the initial liquidity._


Taiko Protocol Audit − Low Severity − 43


### **L-20 Lack of Constraints During Migration -** **Phase 3**

The <u><mark>`[changeBridgedToken](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L160C14-L160C32)`</mark></u> function of the <mark>`ERC20Vault`</mark> contract can be called to change

the representation of a canonical token on the current chain. While the function can only be

called by its owner, consider adding the following validations to reduce the risk of error:


   - A validation that <mark>`ctoken.addr != 0`</mark> and <mark>`_ctoken.chainid != block.chainid`</mark> <mark>.</mark>

   - If desired, a check could be added that the <mark>`_btokenNew`</mark> address has code. This would

constrain new canonical token deployments to always happen before migrations, but

would reduce the risk of error.


**_Update:_** _Resolved in_ _<u>[pull request #17333](https://github.com/taikoxyz/taiko-mono/pull/17333)</u>_ _at commit_ _<u>[8d14e84.](https://github.com/taikoxyz/taiko-mono/commit/8d14e84e8a9be6816042f04f4f725a1d4ede65fc)</u>_

### **L-21 Incorrect Calldata Gas Accounting in** **Message Processing - Phase 3**


The <u>[minimum gas limit set for a message](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L448)</u> accounts for the calldata costs of an encoded

<u><mark>`[Message](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/IBridge.sol#L24)`</mark></u> <u>struct</u> when processing the message. This is done by adding

<mark>`(message.data.length + 256) / 16`</mark> <u>[to a flat gas reserve.](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L452C34-L452C65)</u>


The following issues were identified:


   - The computation of gas cost per calldata byte is done by dividing, although it should be

multiplying by 16.

  - The word length accounted for the encoded <mark>`Message`</mark> struct is 7 words plus the

dynamic data length, while additionally overcharging one word to account for the

rounded up dynamic size. The actual encoding of the Message struct requires 13 words

plus the dynamic data length, while the dynamic length can be rounded up to a multiple

of 32. Hence, the bytes length formula should be <mark>`13 * 32 + ((dataLength + 31)`</mark>

<mark>`/ 32) * 32`</mark> <mark>.</mark>

   - The calldata cost is not accounted for in the <u>[gas charged when calculating the fee,](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L279-L280)</u>

although it is at the expense of the processor. This is due to <mark>`gasCharged`</mark> only

accounting for the gas consumption between the <u>two calls to</u> <u><mark>`[gasleft()](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L279)`</mark></u> <mark>,</mark> which does

not include the gas costs associated with encoding <u><mark>`[_message](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L214)`</mark></u> in the transaction

calldata.


Consider correcting the minimal gas and fee calculations to reflect more accurate costs.


Taiko Protocol Audit − Low Severity − 44


**_Update:_** _Resolved in_ _<u>[pull request #17284](https://github.com/taikoxyz/taiko-mono/pull/17284)</u>_ _at commit_ _<u>[1a5b040](https://github.com/taikoxyz/taiko-mono/pull/17284/commits/1a5b040229b58ed5e6a4ad5349e248d6ce797b24)</u>_ _and_ _<u>[pull request #17529](https://github.com/taikoxyz/taiko-mono/pull/17529)</u>_ _at_

_commit_ _<u>[8c91db2.](https://github.com/taikoxyz/taiko-mono/pull/17529/commits/8c91db27b57fe2178b710162334f841bde55fbef)</u>_

### **L-22 Message Processors Can Control Gas and** **Fee Consumption - Phase 3**


The <u><mark>`[Bridge](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L17)`</mark></u> contract allows users to send cross-chain messages between chains connected

by a <mark>`SignalService`</mark> <mark>.</mark> When <u>[sending](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L126)</u> a cross-chain message, users can input a <u>[gas limit and](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/IBridge.sol#L34-L36)</u>

<u>[a fee](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/IBridge.sol#L34-L36)</u> associated with the message. If the gas limit is non-zero, third party message processors

can call <u><mark>`[processMessage](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L213)`</mark></u> on the destination chain to process the message in exchange for <u>[a](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L278-L287)</u>

<u>[part of the fee](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L278-L287)</u> depending on the consumed amount of gas.


In pseudocode, and assuming no precision issues, a message processor is paid:

```
min(
msg.fee,
gasCharged * msg.fee / msg.gasLimit,
gasCharged * (msg.fee / msg.gasLimit + block.basefee) / 2
)

```

A rational, profit-maximizing message processor will want to minimize their expense

<mark>(</mark> <mark>`block.basefee * gasCharged`</mark> <mark>)</mark> while maximizing their revenue <mark>(</mark> <mark>`msg.fee /`</mark>

<mark>`msg.gasLimit * gasCharged`</mark> <mark>)</mark> . Assuming a rational message processor, messages will

only be processed if the profits are positive, i.e., if <mark>`msg.fee / msg.gasLimit`</mark> is greater

than <mark>`block.basefee`</mark> (the third <mark>`min`</mark> case). However, as this profit scales with the gas

charged, the processor can make the processing message transaction more gas expensive to

get the maximum profit by extracting the full <mark>`msg.fee`</mark> as revenue.


To control how much gas is charged, the message processor can add an arbitrary number of

zero bytes at the end of the encoding of the <mark>`HopProof[]`</mark> in <u><mark>`[_proof](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L215)`</mark></u> <mark>.</mark> These excess bytes

will be ignored during <u>[abi decoding](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/signal/SignalService.sol#L313)</u> but will consume unnecessary gas by expanding memory

at the expense of the original message sender.


Because each zero byte of calldata costs 4 gas to the message processor and the memory

expansion happens in the proxy contract as well, such attacks can only be profitable if

<mark>`message.gasLimit`</mark> and/or <mark>`message.fee`</mark> are very high. A <u>[proof of concept](https://gist.github.com/0xmp/4d7f142df3259bd08cbf0545f4846e89)</u> shows that this

exploit requires rather extreme conditions which are unlikely to occur in practice.


If such attacks are a concern, consider adding a validation that <mark>`proof.length`</mark> has a <u>[size](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L243)</u> in

bytes below a certain threshold (e.g., 200,000). The quadratic part of the memory expansion


Taiko Protocol Audit − Low Severity − 45


costs only matters here for very high <mark>`proof.length`</mark> <mark>.</mark> Alternatively, consider removing the

manual decoding of <u><mark>`[hopProofs](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/signal/SignalService.sol#L313)`</mark></u> and replacing it with a <mark>`HopProof[] calldata`</mark> argument.


**_Update:_** _Resolved in_ _<u>[pull request #17429](https://github.com/taikoxyz/taiko-mono/pull/17429)</u>_ _at commit_ _<u>[2fd442a.](https://github.com/taikoxyz/taiko-mono/pull/17429/commits/2fd442a2fe06c35227f6163bf901e909015968cf)</u>_

### **L-23 Inaccurate Gas Limit on Message Invocation** **- Phase 3**


Users can send cross-chain messages by calling <u><mark>`[sendMessage](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L126C14-L126C25)`</mark></u> on the <mark>`Bridge`</mark> contract. An

optional gas limit can be defined for this message. In that case, if a user wants their message

to be <u>[executed with at least](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L488)</u> <u>`[A](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L488)`</u> <u>gas,</u> <mark>`message.gasLimit`</mark> has to be at least <mark>`A + minGas`</mark>,

where <mark>`minGas`</mark> depends on the <u>[message length plus a fat gas amountl](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L452)</u> <u>.</u>


When a message is processed by a third party, the gas remaining before invoking the user's

message is validated to be <u>[greater than](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L611-L613)</u> <mark>`64 / 63 * A`</mark> <mark>.</mark> This is because of <u>[EIP-150, which](https://eips.ethereum.org/EIPS/eip-150)</u>

silently caps the amount of gas sent in external calls to <mark>`63 / 64 * gasleft()`</mark> <mark>.</mark> If such a

check were not present, it would be possible for the gas to be capped by EIP-150, executing

the call with less than `A` gas.


However, while the intention was correct, a gas limit of `A` is not guaranteed. This is due to the

gas expenses that accumulate between the <u>[EIP-150 check](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L611-L613)</u> and the actual <u>[message execution](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L488)</u>

<u>[on the target:](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L488)</u>


  - Memory expansion costs

  - Account access

   - Transfers

  - Opcode costs


Because <mark>`1 / 64 * gasleft()`</mark> has to be enough to execute the <u>[rest of the](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L265-L296)</u>

<u><mark>`[processMessage](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L265-L296)`</mark></u> <u>function</u> without running out of gas, a gas limit below `A` on the target is

only possible for high gas limits. This <u>[proof of concept](https://gist.github.com/0xmp/4da10ab59c04f71cdb9557ff320f9fc2)</u> shows the issue in practice.


Consider addressing the above to build a more predictable bridge for users and projects

sending cross-chain messages. What follows is an example of how this could be achieved.


The goal of the computation is to ensure that EIP-150 does not silently cap the amount of gas

sent with the external call to be less than `A` . We note:




- <mark>`memory_cost`</mark> <mark>:</mark> the amount of gas needed to expand the memory when storing the

inputs and outputs of the external call.


Taiko Protocol Audit − Low Severity − 46


- <mark>`access_gas_cost`</mark> <mark>:</mark> the gas cost of accessing the <mark>`message.to`</mark> account. This

currently corresponds to 2600 gas if the account is cold, and 100 otherwise.




- <mark>`transfer_gas_cost`</mark> <mark>:</mark> the cost of transferring a non-zero <mark>`msg.value`</mark> <mark>.</mark> This cost is

currently 9000 gas but provides a 2300 gas stipend to the called contract.




- <mark>`create_gas_cost`</mark> <mark>:</mark> the cost of creating a new account, currently 25000 gas. This only



applies if <mark>`message.value != 0`</mark> <mark>,</mark> <mark>`message.to.nounce == 0`</mark> <mark>,</mark> <mark>`message.to.code`</mark>

<mark>`== b""`</mark> <mark>,</mark> and <mark>`message.to.balance == 0`</mark> <mark>.</mark> Since <mark>`message.to`</mark> is <u>[checked to have](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L645)</u>

<u>[code, this cost can be ignored here.](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L645)</u>


Thus, we want to check that the following:

```
63 / 64 * (gasleft() - memory_cost - access_gas_cost - transfer_gas_cost)

```

is at least as much as `A` <u>[(reference implementation). The sum of](https://github.com/ethereum/execution-specs/blob/master/src/ethereum/cancun/vm/gas.py#L230)</u> <mark>`access_gas_cost`</mark> and

<mark>`transfer_gas_cost`</mark> can be upper-bounded with <mark>`2_600 + 9_000 - 2_300 = 9_300`</mark> <mark>.</mark>

The <u><mark>`[memory_cost](https://github.com/ethereum/execution-specs/blob/master/src/ethereum/cancun/vm/gas.py#L128)`</mark></u> is cumbersome to compute in practice, but by estimating the costs

through tests, we can upper-bound the cost of memory expansion for up to <mark>`10_000`</mark> bytes of

<mark>`message.data`</mark> in the context of the call with the formula <mark>`1_200 + 3 *`</mark>

<mark>`message.data.length / 32`</mark> <mark>.</mark>


As such, it would be possible to validate that the call will have enough gas by checking the

following condition right before the external call is made:

```
63 * gasleft() >= 64 * A + 63 * (9_300 + 1_200 + 3 * message.data.length / 32) +
small_buffer

```

This would be accurate for messages with up to <mark>`10_000`</mark> bytes of <mark>`message.data`</mark> <mark>.</mark> Any

message above this limit could be required to have a gas limit of zero which would force it to

be <u>[processed by its](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L233-L235)</u> <u><mark>`[destOwner](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L233-L235)`</mark></u> <mark>.</mark> A similar approach, without a constraint on the data size,

has been adopted by <u>[Optimism](https://github.com/ethereum-optimism/optimism/blob/8dd18f0efd9719762961897bf93ef1dd8ce702a7/packages/contracts-bedrock/src/libraries/SafeCall.sol#L51-L81)</u> and can be used as inspiration.


**_Update:_** _Resolved in_ _<u>[pull request #17529](https://github.com/taikoxyz/taiko-mono/pull/17529)</u>_ _at commit_ _<u>[a937ec5. After further discussions with the](https://github.com/taikoxyz/taiko-mono/tree/a937ec5d7bbb42721caf9702141164c72cd92c34)</u>_

_audit team, the fix implemented follows an alternative, more efficient approach than the one_

_suggested in the issue._


Taiko Protocol Audit − Low Severity − 47


## **Notes & Additional** **Information**

### **N-01 Inconsistent Use of Named Returns - Phase** **1**

Throughout the codebase, there are multiple instances where contracts have inconsistent

usage of named returns in their functions:


   - In the <u><mark>`[Bridge](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L16-L593)`</mark></u> <u>contract</u>

   - In the <u><mark>`[DevnetTierProvider](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/DevnetTierProvider.sol#L10-L57)`</mark></u> <u>contract</u>

   - In the <u><mark>`[MainnetTierProvider](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L10-L71)`</mark></u> <u>contract</u>

   - In the <u><mark>`[TaikoL1](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoL1.sol#L22-L227)`</mark></u> <u>contract</u>

   - In the <u><mark>`[TaikoL2](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L21-L298)`</mark></u> <u>contract</u>

   - In the <u><mark>`[TestnetTierProvider](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/TestnetTierProvider.sol#L10-L72)`</mark></u> <u>contract</u>

   - In the <u><mark>`[ERC1155Vault](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC1155Vault.sol#L29-L322)`</mark></u> <u>contract</u>

   - In the <u><mark>`[ERC20Vault](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L18-L434)`</mark></u> <u>contract</u>

   - In the <u><mark>`[ERC721Vault](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC721Vault.sol#L16-L258)`</mark></u> <u>contract</u>

   - In the <u><mark>`[SgxVerifier](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/verifiers/SgxVerifier.sol#L19-L239)`</mark></u> <u>contract</u>

   - In the <u><mark>`[SignalService](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L14-L313)`</mark></u> <u>contract</u>

   - In the <u><mark>`[TimelockTokenPool](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L25-L281)`</mark></u> <u>contract</u>


Consider being consistent with the use of named returns throughout the codebase.


**_Update:_** _Acknowledged, not resolved. The Taiko team stated:_


_Decided not to proceed with a fix._

### **N-02 Lack of Indexed Event Parameters - Phase 1**


Throughout the codebase, several events could benefit from having indexed parameters:


   - The <u><mark>`[GuardiansUpdated](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/Guardians.sol#L37)`</mark></u> <u>event</u> of <mark>`Guardians.sol`</mark> could index the <mark>`version`</mark>

parameter.

   - The <u><mark>`[MessageSuspended](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/IBridge.sol#L97)`</mark></u> <u>event</u> of <mark>`IBridge.sol`</mark> could index the <mark>`msgHash`</mark> to be

consistent with the other events defined above.

   - The <u><mark>`[Anchored](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L57)`</mark></u> <u>event</u> of <mark>`TaikoL2.sol`</mark> could index the <mark>`parentHash`</mark> .


Taiko Protocol Audit − Notes & Additional Information − 48


   - The <u><mark>`[MigrationStatusChanged](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L21)`</mark></u> <u>event</u> of <mark>`BridgedERC20Base.sol`</mark> could index

both the <mark>`addr`</mark> and the <mark>`inbound`</mark> parameters.

   - The <u><mark>`[Withdrawn](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/ERC20Airdrop2.sol#L35)`</mark></u> <u>event</u> of <mark>`ERC20Airdrop2.sol`</mark> could index the <mark>`user`</mark> parameter.

   - The <u><mark>`[SignalSent](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L49)`</mark></u> <u>event</u> of <mark>`ISignalService.sol`</mark> could index the <mark>`app`</mark> and the

<mark>`signal`</mark> parameters.

   - The <u><mark>`[Claimed](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/MerkleClaimable.sol#L27)`</mark></u> <u>event</u> of <mark>`MerkleClaimable.sol`</mark> could index the <mark>`hash`</mark> .

   - The <u><mark>`[BlobCached](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L41)`</mark></u> <u>event</u> could index the <mark>`blobHash`</mark> parameter.


To improve the ability of off-chain services to search and filter for specific events, consider

indexing the event parameters identified above.


**_Update:_** _Acknowledged, not resolved. The Taiko team stated:_


_We decided not to add additional indexes as most of these events are not used directly_

_by end users._

### **N-03 Signatures Do Not Use EIP-712 - Phase 1**


The <mark>`AssignmentHook`</mark> is a canonical hook using signatures to validate that the prover agreed

to prove a certain block in exchange for a certain amount of fees. These signatures can be

from EOAs or from smart contracts using EIP-1271. However, the signed data does not respect

<u>[EIP-712. Depending on how the prover is expected to sign this data (e.g., through a third-party](https://eips.ethereum.org/EIPS/eip-712)</u>

frontend) it could be beneficial to use a standard supported by the service providers such as

wallets, etc.


Consider formatting the signed data according to EIP-712.


**_Update:_** _Acknowledged, not resolved. The Taiko team stated:_


_We decided not to proceed with this as Assignments are signed by provers in the_

_backend._

### **N-04 Gas Optimization - Phase 1**


The following opportunities for gas optimizations were found:


   - The <u><mark>`[EssentialContract](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/common/EssentialContract.sol)`</mark></u> contract packs two variables, <mark>`__reentry`</mark> and

<mark>`__paused`</mark> <mark>,</mark> as two <mark>`uint8`</mark> values in one storage slot. However, by default, these

variables are neither read nor written at the same time. Consider changing them to be

<mark>`uint256`</mark> to <u>[save gas.](https://docs.soliditylang.org/en/v0.8.24/internals/layout_in_storage.html#layout-of-state-variables-in-storage)</u>


Taiko Protocol Audit − Notes & Additional Information − 49


- Resolved names such as "proposer", "tier_provider", and "taiko_token", domain

separators such as <u>["PROVER_ASSIGNMENT"](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/hooks/AssignmentHook.sol#L148C17-L148C37)</u> or <u>["SIGNAL", and verifier names such as](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L203C43-L203C51)</u>

<u><mark>`["tier_sgx"](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/tiers/MainnetTierProvider.sol#L23)`</mark></u> could be <mark>`constant bytes32`</mark> contract variables.

- During during block verification, the <u><mark>`[tko](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L188C17-L188C78)`</mark></u> <u>[token address](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L188C17-L188C78)</u> could be cached, similar to the

<u>[tier provider.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L148-L150)</u>

- In the <mark>`GuardianProver`</mark> contract:

   - The <u><mark>`[Approved](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/Guardians.sol#L121)`</mark></u> and the <u><mark>`[GuardianApproval](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/GuardianProver.sol#L54)`</mark></u> events are always emitted

consecutively and have some duplicate information. Consider only emitting one.

   - The indexation of the guardian could use the loop iterator <mark>`i + 1`</mark> instead of

<u><mark>`[guardians.length](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/Guardians.sol#L88C37-L88C53)`</mark></u> to avoid reading from storage in the loop.

   - The <u><mark>`[minGuardians](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/Guardians.sol#L135C30-L135C42)`</mark></u> storage variable read in the <mark>`for`</mark> loop during approvals

could be cached to memory, similar to <u><mark>`[guardians.length](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/Guardians.sol#L131C35-L131C51)`</mark></u> <mark>.</mark>

   - The <u><mark>`[address[] memory _newGuardians](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/Guardians.sol#L54)`</mark></u> <u>argument could be stored in calldata</u>

to avoid copying the array to memory.




- In the <u><mark>`[sendEther](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/LibAddress.sol#L22-L37)`</mark></u> function, no returned value is necessary and the allocation of <u>[64](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/LibAddress.sol#L31)</u>



<u>[bytes](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/libs/LibAddress.sol#L31)</u> of memory could be avoided.

   - In the <mark>`anchor`</mark> function, the <mark>`blockhash(parentId)`</mark> and the state variable

<mark>`gasExcess`</mark> could be cached to memory to save gas during the <u><mark>`[Anchored](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L157)`</mark></u> <u>event</u>

<u>[emission.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L157)</u>

   - In the <u><mark>`[onBlockProposed](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/hooks/IHook.sol#L13-L16)`</mark></u> <u>function of hooks, the</u> <mark>`_blk`</mark> <mark>,</mark> <mark>`_meta`</mark> and <mark>`_data`</mark>

arguments could be in calldata rather than memory by default to save gas.


Consider updating the identified instances to save gas during the operation/deployment of the

protocol.


**_Update:_** _Partially resolved at commit_ _<u>[84f06f3. All items except items one and four were](https://github.com/taikoxyz/taiko-mono/commit/84f06f34199db2fdf49dcb0fd3e055827c29a15a)</u>_

_addressed._

### **N-05 Inefficient Bridge Message Handling - Phase** **1**


When a message has been processed before and the message call has failed, bridge users are

currently forced to retry a message invocation on the destination chain to transition its status to

<mark>`FAILED`</mark> <mark>.</mark> This is the case even in situations where it is known in advance that

<u><mark>`[_invokeMessageCall](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L477)`</mark></u> will again not be successful. This status transition is necessary for

users to invoke the recall function to recover their funds on the source chain.


Consider adding a way for users to directly transition a message's status from <mark>`RETRIABLE`</mark> to

<mark>`FAILED`</mark> without having to retry executing the message call. This would reduce gas


Taiko Protocol Audit − Notes & Additional Information − 50


consumption for affected users and enhance their overall user experience by streamlining the

process.


**_Update:_** _Resolved in_ _<u>[pull request #16669](https://github.com/taikoxyz/taiko-mono/pull/16669)</u>_ _at commit_ _<u>[dce651e.](https://github.com/taikoxyz/taiko-mono/commit/dce651e2647013b0d13d7947e0fd0115f38fe639)</u>_

### **N-06 Code Quality and Readability Suggestions -** **Phase 1**


The following opportunities to improve the quality of the codebase were identified:


   - The <u><mark>`[graffiti](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoData.sol#L117)`</mark></u> component of the <mark>`Transition`</mark> struct is unused and could be

removed to save gas. Alternatively, consider documenting its use.

   - The <u><mark>`[TransitionState](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoData.sol#L122C12-L122C27)`</mark></u> struct could be renamed to <mark>`StateTransition`</mark> <mark>.</mark>

   - The <u><mark>`[_createTransition](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L269)`</mark></u> function could be renamed (e.g., to

" <mark>`_fetchOrCreateTransition`</mark> <mark>"</mark> ) as it does not always create a new transition.

   - The config validity check for the <mark>`blockMaxProposals`</mark> parameter could check that

" <mark>`blockMaxProposals <= 1`</mark> <mark>"</mark> instead of <u><mark>`[== 1](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L248)`</mark></u> <mark>.</mark>




- <u><mark>`[_operationId](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/Guardians.sol#L111C30-L111C42)`</mark></u> could be renamed to <mark>`_blockId`</mark> for consistency and clarity. Similarly,

the <u><mark>`[proofSubmitted](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/provers/Guardians.sol#L42-L43)`</mark></u> event argument could be renamed to <mark>`minGuardiansReached`</mark>

as the <mark>`Guardians`</mark> contract has no context on a proof.




   - The <u><mark>`[init](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/gov/TaikoTimelockController.sol#L18)`</mark></u> <u>[function](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/gov/TaikoTimelockController.sol#L18)</u> of the <mark>`TaikoTimelockController`</mark> does not grant the

<mark>`PROPOSER_ROLE`</mark> nor the <mark>`EXECUTOR_ROLE`</mark> to the <mark>`TaikoGovernor`</mark> contract. While

the <mark>`TIMELOCK_ADMIN_ROLE`</mark> is granted to the owner, meaning that it could grant these

roles separately, it would be clearer and simpler if these were granted during initialization.

Consider passing the address of the <mark>`TaikoGovernor`</mark> to grant these roles during

initialization. Alternatively, consider documenting that these roles are to be granted

separately.

   - The <u><mark>`[_genesisBlockHash](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L69C24-L69C41)`</mark></u> could be checked to be nonzero during initialization to

ensure the following transitions can be <u>[proven.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L105)</u>

   - The <u><mark>`[L1_TOO_MANY_TIERS](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoErrors.sol#L36)`</mark></u> error is unused and could be removed.

   - The <u><mark>`[AM_INVALID_PARAMS](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/common/AddressManager.sol#L25C11-L25C28)`</mark></u> and <u><mark>`[AM_UNSUPPORTED](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/common/AddressManager.sol#L26C11-L26C25)`</mark></u> error names are vague and could

be changed to be more accurate (e.g., to <mark>"</mark> <mark>`AM_ADDRESS_ALREADY_SET`</mark> <mark>"</mark> and

" <mark>`AM_PAUSE_UNSUPPORTED`</mark> <mark>"</mark>, respectively).


Consider addressing the above instances to improve the clarity and safety of the codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #16667](https://github.com/taikoxyz/taiko-mono/pull/16667)</u>_ _at commit_ _<u>[250ad7d. All the issues were](https://github.com/taikoxyz/taiko-mono/commit/250ad7d67280bfdaf08963cb489b07210faa7364)</u>_

_addressed except for the second point. Note: The TaikoTimelockController was removed in pull_

_<u>[request #16933.](https://github.com/taikoxyz/taiko-mono/pull/16933)</u>_


Taiko Protocol Audit − Notes & Additional Information − 51


### **N-07 Missing or Misleading Documentation -** **Phase 1**

The following opportunities to improve the clarity of the documentation were found:


   - The structs defined in the <u><mark>`[TaikoData](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoData.sol#L63-L195)`</mark></u> library would benefit from some added

documentation on what the different fields represent.

   - The <mark>`EthDeposit`</mark> struct is incorrectly documented as <u>[using 1 slot](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoData.sol#L149)</u> but actually uses 2

slots as it is 40 bytes long.




- <mark>`meta.coinbase`</mark> is <u>[documented](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/hooks/AssignmentHook.sol#L75)</u> as being the L2 block proposer, but it is only chosen

by the block proposer.

- In the <mark>`proveBlock`</mark> function, a comment mentions that if the transition does not exist

the <mark>`tid`</mark> will be <u>[set to 0. However, it is set to 1 in practice.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L128C71-L128C80)</u>

- A conditional branch for the <mark>`TIER_OP`</mark> tier is <u>[present in the code](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L178-L183)</u> but could be

documented as only being used for testnet.

- The contest bond is documented as being <u>[burned](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L241-L242)</u> from the prover, but it is only

transferred and can in fact be regained if the transition is <u>[proven to be invalid.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L371)</u>

- The <mark>`_overrideWithHigherProof`</mark> function would benefit from better documentation

overall (e.g., when <u><mark>`[ts.contester == 0](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L373-L378)`</mark></u> for the first transition, there is technically no

existing contest but the code still uses this branch).

- The NatSpec around the <mark>`getBasefee`</mark> function indicates that the function can be used

to <u>["get the basefee and gas excess [...]". However, the function only returns the base](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L180C17-L180C48)</u>

fee.

- The NatSpec around the <mark>`__ctx`</mark> variable in the <mark>`Bridge`</mark> contract indicates that it <u>[fits in](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L37)</u>

<u>[3 slots, whereas it only occupies 2.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L37)</u>

- The NatSpec around the <u><mark>`[proveMessageReceived](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L374)`</mark></u> function is incorrect as it was

duplicated from the function above it.

- The NatSpec around the <mark>`getInvocationDelays`</mark> function has an extra "and" in the

phrase <u>["a message can be executed since and the time it was received".](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L414)</u>

- The <u><mark>`[processDeposits](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibDepositing.sol#L67)`</mark></u> function could use some additional documentation (e.g.,

around the fee logic).

- The <mark>`Message`</mark> struct in the <u><mark>`[IBridge](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/IBridge.sol#L17-L46)`</mark></u> <u>interface</u> could document that the <mark>`gasLimit`</mark> of

a message can be set to 0 so that only the <mark>`destOwner`</mark> can process the message on

the destination chain. Additionally, the <mark>`gasLimit`</mark> could be documented as not being

respected on <u>[message retries](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L331)</u> or when <u>[processed by the owner.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L280)</u>

- A <u>[comment around the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L278)</u> <u><mark>`[gasLimit](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L278)`</mark></u> is reversed, as the remaining gas is used if called by

the owner.


Taiko Protocol Audit − Notes & Additional Information − 52


Consider addressing the above instances to improve the clarity and readability of the

codebase.


**_Update:_** _Partially resolved in_ _<u>[pull request #16681](https://github.com/taikoxyz/taiko-mono/pull/16681)</u>_ _at commit_ _<u>[f31a6ac. All the mentioned](https://github.com/taikoxyz/taiko-mono/commit/f31a6ac0be129fb001dc651a1b95046452cf5696)</u>_

_instances were fixed except for item 8 in the list. Note that the fifth item was resolved separately_

_in commit_ _<u>[2c63cb0.](https://github.com/taikoxyz/taiko-mono/commit/2c63cb0c796495948f1dd887662044397394d852)</u>_

### **N-08 Typographical Errors - Phase 1**


The following typographical errors were identified in the codebase:









<u><mark>`[isAssignedPover](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L416C14-L416C29)`</mark></u> should be <mark>`isAssignedProver`</mark> <mark>.</mark>

<u><mark>`[deleys](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L443C50-L443C56)`</mark></u> should be <mark>`delays`</mark> <mark>.</mark>

<u><mark>`[Indenitifer](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L116C25-L116C36)`</mark></u> should be <mark>`Identifier`</mark> <mark>.</mark>




- <u>["send"](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L249C78-L249C82)</u> should be "sent".

- <u>["choose use"](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProposing.sol#L252C36-L252C46)</u> should be "choose to use".







<u><mark>`[tran](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibProving.sol#L312C51-L312C57)`</mark></u> should be <mark>`transitions`</mark> <mark>.</mark>



Consider addressing the above instances to improve the quality of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #16667](https://github.com/taikoxyz/taiko-mono/pull/16667)</u>_ _at commit_ _<u>[250ad7d.](https://github.com/taikoxyz/taiko-mono/commit/250ad7d67280bfdaf08963cb489b07210faa7364)</u>_

### **N-09 Changing Governor Parameters Requires** **an Upgrade - Phase 1**


The <mark>`TaikoGovernor`</mark> contract is intended to be set as the proposer and executor of the

<mark>`TaikoTimelock`</mark> contract, which will be set as the owner of the other deployed contracts.

Parameters of the <mark>`TaikoGovernor`</mark> contracts include the <mark>`votingDelay`</mark> <mark>,</mark> the

<mark>`votingPeriod`</mark> <mark>,</mark> and the <mark>`proposalThreshold`</mark> <mark>.</mark>


These parameters are <u>[hardcoded in the contract](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/gov/TaikoGovernor.sol#L111-L125)</u> and would require a contract upgrade if there

was a need to update them.


If such flexibility is desired, consider inheriting from <u><mark>`[GovernorSettingsUpgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/release-v4.8/contracts/governance/extensions/GovernorSettingsUpgradeable.sol)`</mark></u> to

allow for these parameters to be changed by governance without having to upgrade the

contract.


**_Update:_** _Resolved in_ _<u>[pull request #16687](https://github.com/taikoxyz/taiko-mono/pull/16687)</u>_ _at commit_ _<u>[eba82ba.](https://github.com/taikoxyz/taiko-mono/commit/eba82bad1075afc695f3203304160f26e42627a9)</u>_


Taiko Protocol Audit − Notes & Additional Information − 53


### **N-10 Unused Named Return Variables - Phase 1**

Named return variables are a way to declare variables that are meant to be used within a

function's body for the purpose of being returned as that function's output. They are an

alternative to explicit in-line <mark>`return`</mark> statements.


In the codebase, there are instances of unused named return variables:


   - The <u><mark>`[invocationDelay_](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L421)`</mark></u> <u>return variable</u> in the <mark>`getInvocationDelays`</mark> function in
```
   Bridge.sol
```

   - The <u><mark>`[invocationExtraDelay_](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L421)`</mark></u> <u>return variable</u> in the <mark>`getInvocationDelays`</mark>

function in <mark>`Bridge.sol`</mark>


Consider either using or removing any unused named return variables.


**_Update:_** _Resolved in pull request_ _<u>[#16600](https://github.com/taikoxyz/taiko-mono/pull/16600)</u>_ _at commit_ _<u>[f6efe97.](https://github.com/taikoxyz/taiko-mono/commit/f6efe975274cd95e33f98de6c6e5d7fc39d21966)</u>_

### **N-11 The TimelockTokenPool May Not Be** **Compatible With ERC-4337 - Phase 2**


<u>[ERC-4337](https://eips.ethereum.org/EIPS/eip-4337)</u> is a standard that allows smart contracts to behave like user accounts. Under the

EIP there will be ERC-4337 smart contract accounts in addition to Externally Owned Accounts

(EOA). The former account type is incompatible with some code, such as <mark>`tx.origin`</mark> or

<mark>`ecrecover`</mark> <mark>.</mark>


The <u><mark>`[TimelockTokenPool](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol)`</mark></u> uses <u><mark>`[ecrecover](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L171)`</mark></u> for the withdrawal of the grant, which could be

inconvenient for smart wallets and multisigs.


If smart wallet support is desired, consider using <u>[EIP-1271](https://eips.ethereum.org/EIPS/eip-1271)</u> to allow smart contract accounts to

verify signatures instead of <mark>`ecrecover`</mark> <mark>.</mark> This could for example by achieved by using the

<u><mark>`[SignatureChecker](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.2/contracts/utils/cryptography/SignatureChecker.sol)`</mark></u> library instead of <u><mark>`[ECDSA](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.2/contracts/utils/cryptography/ECDSA.sol)`</mark></u> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #16934. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/pull/16934)</u>_


_Removed (underway) the TimelockTokenPool, and the new one (under supplementary-_

_contracts) will always be EOAs._


Taiko Protocol Audit − Notes & Additional Information − 54


### **N-12 Typographical Errors - Phase 2**

The following typographical errors were identified in the codebase:


   - "authrized" <u>[[1]](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L53C16-L53C25)</u> <u>[[2]](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L54C49-L54C58)</u> should be "authorized"

   - "Indenitifer" <u>[[1]](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L116C25-L116C36)</u> <u>[[2]](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L132C25-L132C36)</u> should be "Identifier"

   - <u>["converison"](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/thirdparty/solmate/LibFixedPointMath.sol#L72)</u> should be "conversion"


Consider correcting the above instances to improve the quality of the codebase.


**_Update:_** _Resolved in the following commits:_ _<u>[810e723, 0eec494](https://github.com/taikoxyz/taiko-mono/pull/16438/commits/810e723f2831ca2d16683c2a2fbe32a73bf72309)</u>_ _and_ _<u>[1b9ba53.](https://github.com/taikoxyz/taiko-mono/pull/16667/commits/1b9ba532b34b6cd234b6d641c0ec955240caa246#diff-68ead14394db50eabf1a8caf1d53e16da1de07e25b2ac2f816d1a066b3ccdddf)</u>_

### **N-13 Gas Optimizations - Phase 2**


The following opportunities for gas optimizations were found:


  - When <u>[emitting](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L63)</u> the <mark>`MigratedTo`</mark> event, the <mark>`msg.sender`</mark> could be used in place of the

<mark>`migratingAddress`</mark> variable to save gas.

   - The <u><mark>`[isClaimed](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/MerkleClaimable.sol#L12)`</mark></u> mapping in the <mark>`MerkleClaimable`</mark> contract could be made more

efficient. Consider using a BitMaps instead, for example see Uniswap's

<u><mark>`[MerkleDistributor](https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol#L18C41-L18C54)`</mark></u> <mark>.</mark>

   - The <mark>`ERC1155Vault`</mark> contract could call the <mark>`_burnBatch`</mark> (for example by

implementing a public <mark>`burnBatch`</mark> function in <mark>`BridgedERC1155`</mark> <mark>)</mark> and

<mark>`safeBatchTransferFrom`</mark> functions of ERC-1155 instead of the <u><mark>`[burn](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC1155Vault.sol#L252)`</mark></u> and

<u><mark>`[safeTransferFrom](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC1155Vault.sol#L270)`</mark></u> functions. This would reduce the number of external calls and

reduce gas costs.


Consider updating the identified instances to save gas during the operation/deployment of the

protocol.


**_Update:_** _Partially resolved at commit_ _<u>[dd8725f. All the items were resolved except the second](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_

_one. The Taiko team stated:_


_As the claiming will be done on our L2, gas cost shall not be an issue, and would want_

_to avoid such changes as the infrastructure (for claiming and putting together off-chain_

_data) is already in place._


Taiko Protocol Audit − Notes & Additional Information − 55


### **N-14 Missing or Misleading Documentation -** **Phase 2**

The following opportunities to improve the clarity of the documentation were found:


   - The <mark>`CrossChainOwned`</mark> abstract contract allows an <u>["owner to be a local address or](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L9-L10)</u>

<u>[one that lives on another chain". However, during initialization the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L9-L10)</u> <mark>`_ownerChainId`</mark> is

checked to be <u>[different](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/CrossChainOwned.sol#L70C35-L70C65)</u> from <mark>`block.chainid`</mark> <mark>,</mark> and it is used to synchronize the state

root with <u>[another chain. It is thus unclear which value to give](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L149C17-L149C29)</u> <mark>`_ownerChainId`</mark> if the

owner is "local".

   - The <mark>`BridgeTransferOp`</mark> struct is <u>[documented](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BaseNFTVault.sol#L22-L44)</u> in the <mark>`BaseNFTVault`</mark> contract but

not in the <u><mark>`[ERC20Vault](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L31-L42)`</mark></u> <mark>.</mark> Consider adding this documentation.

  - The NatSpec around <mark>`blockSyncThreshold`</mark> says that <u>["a value of zero disables](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoData.sol#L57-L58)</u>

<u>[syncing", but this is](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/TaikoData.sol#L57-L58)</u> <u>[not the case. Consider removing this comment.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L1/libs/LibVerifying.sol#L238-L242)</u>

  - The phrase <u>["uniquely from chainId, kind, and data"](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L99)</u> above <mark>`isChainDataSynced`</mark> was

copied from above and should be removed.

  - The documentation around the <mark>`sendSignal`</mark> function explains that it <u>["sets the storage](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L56C44-L56C85)</u>

<u>[slot to a value of 1", however in practice the storage slot is set to](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L56C44-L56C85)</u> <u><mark>`[signal](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L64)`</mark></u> .

   - The <mark>`getMyGrantSummary`</mark> function computes the cost to withdraw a token grant.

Because the grant amount is <u>[divided](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L197-L198)</u> by <mark>`1e18`</mark> before being multiplied by the cost, it is

possible for the <mark>`costToWithdraw`</mark> to be off by one token over the lifetime of the grant.

Consider documenting this to make it clear to readers. Besides, the arguments and

return values of the <mark>`getMyGrantSummary`</mark> function are not documented.


Consider addressing the above instances to improve the clarity of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #17483. The](https://github.com/taikoxyz/taiko-mono/pull/17483)</u>_ _<mark>`CrossChainOwned`</mark>_ _and_

_<mark>`TimelockTokenPool`</mark>_ _contracts have been removed, so the first and last items no longer_

_apply._

### **N-15 Lack of Indexed Event Parameters - Phase 2**


Multiple events could benefit from having indexed parameters:


   - The <mark>`InstanceAdded`</mark> event could index its <u><mark>`[replaced](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/verifiers/SgxVerifier.sol#L66C63-L66C71)`</mark></u> parameter.

   - The <mark>`Withdrawn`</mark> event could index its <u><mark>`[to](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L99)`</mark></u> parameter.


To improve the ability of off-chain services to search and filter for specific events, consider

indexing the event parameters identified above.


Taiko Protocol Audit − Notes & Additional Information − 56


**_Update:_** _Resolved in_ _<u>[pull request #16949. The Taiko team stated:](https://github.com/taikoxyz/taiko-mono/pull/16949)</u>_


_TimneLockTokenPool is deleted, but the other one is a good spot._

### **N-16 Code Quality and Readability Suggestions -** **Phase 2**


The following opportunities to improve the codebase were identified:


   - The <u><mark>`[SafeCast](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L4)`</mark></u> import in the <mark>`SignalService`</mark> contract is unused and could be

removed.

   - The <u><mark>`[Strings](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20.sol#L5)`</mark></u> import in the <mark>`BridgedERC20`</mark> contract is unused and could be removed.

   - The <u><mark>`[customConfig](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2EIP1559Configurable.sol#L11)`</mark></u> state variable in the <mark>`TaikoL2EIP1559Configurable`</mark> contract

is not used. Additionally, it is not <u>[initialized alongside the other variables. Consider](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/L2/TaikoL2.sol#L71-L98)</u>

removing it or initializing it during initialization.

   - The initializer <u><mark>`[__Essential_init](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/common/EssentialContract.sol#L109)`</mark></u> is not protected by a <mark>`onlyInitializing`</mark>

modifier. Consider adding one for consistency.

   - The <u><mark>`[__gap](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/TimelockTokenPool.sol#L82)`</mark></u> variable of the <mark>`TimelockTokenPool`</mark> contract is defined as a

<mark>`uint128[]`</mark> <mark>,</mark> which is error-prone. Consider changing it to be a <mark>`uint256[]`</mark> for

consistency and safety.

  - The same <u><mark>`[MigratedTo](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L27)`</mark></u> event is used in two different contexts: when <u>[migrating from,](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L80)</u>

and when <u>[migrating to. Consider emitting the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC20Base.sol#L63)</u> <mark>`migratingInbound`</mark> variable as part of

the <mark>`MigratedTo`</mark> event to differentiate these two situations.

   - The <u><mark>`[MessageRetried](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L336)`</mark></u> event could include the new status of the message.

   - The <u><mark>`[EssentialContract](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/common/EssentialContract.sol#L10)`</mark></u> could have a public <mark>`__reentry`</mark> getter. This could be

useful for integrations wanting to avoid potential read-only reentrancies when reading

from the state of the protocol.

   - The <mark>`BaseVault`</mark> contract could <u>[support](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BaseVault.sol#L36-L41)</u> the <mark>`IMessageInvocable`</mark> ERC-165 interface

id.

   - The deployment of bridged token contracts by vaults <u>[[1]](https://github.com/taikoxyz/taiko-mono/blob/e992ec902583c9f726bf915c6fd7b00289977460/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L422)</u> <u>[[2]](https://github.com/taikoxyz/taiko-mono/blob/e992ec902583c9f726bf915c6fd7b00289977460/packages/protocol/contracts/tokenvault/ERC721Vault.sol#L252)</u> <u>[[3]](https://github.com/taikoxyz/taiko-mono/blob/e992ec902583c9f726bf915c6fd7b00289977460/packages/protocol/contracts/tokenvault/ERC1155Vault.sol#L315)</u> currently uses <mark>`CREATE`</mark> <mark>.</mark> If

desired, it could use <mark>`CREATE2`</mark> with a salt depending on <mark>`ctoken.addr`</mark> and

<mark>`ctoken.chainId`</mark> for example. This would make the deployment address of bridged

tokens standardized and predictable.

   - The <u><mark>`[validSender(address _app)](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L35C14-L35C25)`</mark></u> modifier validates the <mark>`_app`</mark> address is nonzero,

and could thus be renamed to "nonZeroApp" for <u>[consistency](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L40C14-L40C26)</u> and clarity.




- <mark>`MerkleClaimable`</mark> is an abstract contract allowing an owner to <u>[set a Merkle root](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/MerkleClaimable.sol#L53)</u>

against which proofs can be submitted during claims. The ability for an owner to <u>[set a](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/MerkleClaimable.sol#L45)</u>


Taiko Protocol Audit − Notes & Additional Information − 57


<u>[new Merkle root](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/team/airdrop/MerkleClaimable.sol#L45)</u> even as an airdrop is already happening should be prevented or

documented to minimize the risk of error and user loss.

- Consider <u>[crediting](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/thirdparty/optimism/rlp/RLPReader.sol#L4-L8)</u> Optimism explicitly in the NatSpec for the <u><mark>`[RLPWriter](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/libraries/rlp/RLPWriter.sol)`</mark></u> and

<u><mark>`[RLPReader](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/libraries/rlp/RLPReader.sol)`</mark></u> libraries. This would make it easier to review and diff against their version,

in addition to crediting them for the libraries.




- <u><mark>`[msg.sender](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC1155Vault.sol#L271C31-L271C41)`</mark></u> could be replaced by <mark>`user`</mark> in the <mark>`_handleMessage`</mark> function for clarity



and <u>[consistency.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC1155Vault.sol#L252C52-L252C57)</u>


Consider addressing the above instances to make the code clearer and safer.


**_Update:_** _Partially resolved at commit_ _<u>[dd8725f. All the items listed were addressed except for](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_

_the tenth and twelfth ones._

### **N-17 BridgedERC1155 Does Not Return Correct** **URI - Phase 2**


The <u><mark>`[BridgedERC1155](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/BridgedERC1155.sol#L14)`</mark></u> token currently does not override the <mark>`uri`</mark> method to return URIs

specific to each token ID. As it stands, the method returns a uniform URI regardless of the

input token ID, leading to a bad user experience.


Consider overriding the <mark>`uri`</mark> method such that it dynamically generates or retrieves URIs

based on the token ID provided. Implementing this change will align the token functionality

with typical expectations for ERC1155 tokens and enhance user experience.


**_Update:_** _Acknowledged, not resolved. The Taiko team stated:_


_It was a design choice picked by Daniel and Brecht. So basically to give a signal, that_

_this particular NFT is a bridged one, and the source could be find here and there (with_

_.buildURI())_

### **N-18 Gas Optimizations - Phase 3**


The following opportunities for gas optimizations were identified:


   - The <mark>`tokenQuota[_token].quota`</mark> storage variable is read twice in the

<u><mark>`[updateQuota](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/QuotaManager.sol#L52)`</mark></u> <u>function. Instead, it could be stored as an</u> <mark>`oldQuota`</mark> stack variable to

save gas.

   - The <u><mark>`[_transferTokens](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L329)`</mark></u> <u>function</u> first forwards the tokens that are sent to the

destination chain or recalled on the source chain and then checks the available quota in


Taiko Protocol Audit − Notes & Additional Information − 58


the <u><mark>`[QuotaManager](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/QuotaManager.sol#L60)`</mark></u> <mark>.</mark> Assuming that the call more likely fails at the quota check, it would

be cheaper to check the available quota first and thereby fail early.


Consider applying the changes above to make the code a little bit more gas efficient.


**_Update:_** _Resolved in_ _<u>[pull request #17483](https://github.com/taikoxyz/taiko-mono/pull/17483)</u>_ _at commit_ _<u>[09e5508.](https://github.com/taikoxyz/taiko-mono/pull/17483/commits/09e55081e4b2c0f2e690613edc8f61034b75661a)</u>_

### **N-19 Code Quality and Readability Suggestions -** **Phase 3**


The following opportunities to improve the codebase were identified:


   - The <u><mark>`[DO_TARGET_CALL_REVERTED](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L46C11-L46C34)`</mark></u> error is unused and could be removed.

   - The <mark>`BTOKEN_INVALID_TO_ADDR`</mark> errors <u>[[1]](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/BridgedERC20.sol#L58)</u> <u>[[2]](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/BridgedERC721.sol#L28)</u> <u>[[3]](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/BridgedERC1155.sol#L34)</u> are unused and could be removed.

   - The <mark>`fee`</mark> calculation in <u>[line 284](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L284)</u> of <mark>`Bridge.sol`</mark> is calculated based on <mark>`baseFee`</mark>,

<mark>`maxFee`</mark> <mark>,</mark> and <mark>`_message.fee`</mark> <mark>.</mark> The resulting minimal fee is determined through the in
place comparison between <mark>`baseFee`</mark> and <mark>`maxFee`</mark> <mark>,</mark> which harms readability. Instead,

consider chaining two <mark>`.min()`</mark> expressions to simplify the code. For example:
```
   uint256 fee = _message.fee // the fee is at most as provided
   .min(maxFee) // the capped fee if baseFee >= maxFee .min((maxFee +
   baseFee) >> 1); // the capped fee if maxFee > baseFee, the profit
   is halved
```

   - The <u><mark>`[TokenSent](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L255-L264)`</mark></u> event could include <mark>`ctoken.chainid`</mark> as canonical tokens are

uniquely identified by the combination of their address and their source chain.


Consider applying the above changes to improve the clarity of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #17483](https://github.com/taikoxyz/taiko-mono/pull/17483)</u>_ _at commit_ _<u>[119ffd6](https://github.com/taikoxyz/taiko-mono/pull/17483/commits/119ffd615e38494151276749149f3668a8f6fbf2)</u>_ _and_ _<u>[pull request #17502](https://github.com/taikoxyz/taiko-mono/pull/17502)</u>_ _at commit_

_<u>[9dd90cc.](https://github.com/taikoxyz/taiko-mono/pull/17502/commits/9dd90cc5bd226e00a84dcc9208afcc7ac706464c)</u>_

### **N-20 Typographical Error - Phase 3**


A typographical error was identified in <mark>`Bridge.sol`</mark> <mark>.</mark> "Owner" has been incorrectly written as

<u>["Owenr".](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L460)</u>


Consider fixing the error to improve the readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #17303](https://github.com/taikoxyz/taiko-mono/pull/17303)</u>_ _at commit_ _<u>[b63c2c1.](https://github.com/taikoxyz/taiko-mono/pull/17303/commits/b63c2c1dcf613194035a30186e5e2c945e06a590)</u>_


Taiko Protocol Audit − Notes & Additional Information − 59


### **N-21 Naming Suggestion - Phase 3**

In the <mark>`ERC20Vault`</mark> <mark>,</mark> the <u><mark>`[btokenBlacklist](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L54)`</mark></u> mapping keeps track of token contracts that

have been replaced. Consider renaming the mapping to <mark>`btokenBlocklist`</mark> or

<mark>`btokenDenylist`</mark> <mark>,</mark> using a more neutral wording.


**_Update:_** _Resolved in_ _<u>[pull request #17331](https://github.com/taikoxyz/taiko-mono/pull/17331/files)</u>_ _at commit_ _<u>[8495f04.](https://github.com/taikoxyz/taiko-mono/pull/17331/commits/8495f0421730a0eb3d3f63425f73245707ab13a1)</u>_

### **N-22 License Incompatibility in LibBytes - Phase** **3**


The <u><mark>`[toString](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/libs/LibBytes.sol#L11)`</mark></u> function is used to decode abi encoded <mark>`bytes32`</mark> or <mark>`string`</mark> data into a

string. This function is taken from <u>[another codebase](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/libs/LibBytes.sol#L7-L8)</u> which is licensed under <u>[AGPL-3.0.](https://github.com/0xPolygonHermez/zkevm-contracts/blob/main/contracts/PolygonZkEVMBridge.sol#L1C29-L1C37)</u>


However, the current codebase is licensed under MIT, which is incompatible with code licensed

under AGPL-3.0.


Consider using an MIT-licensed alternative to avoid such an issue (e.g., <u><mark>`[BoringERC20](https://github.com/clober-dex/core/blob/main/contracts/utils/BoringERC20.sol#L17-L33)`</mark></u> <mark>)</mark> .


**_Update:_** _Resolved in_ _<u>[pull request #17504](https://github.com/taikoxyz/taiko-mono/pull/17504)</u>_ _at commit_ _<u>[8b6c137.](https://github.com/taikoxyz/taiko-mono/pull/17504/commits/8b6c13704a7afdd640e2ed2672c069eba12caab5)</u>_

### **N-23 Missing and Misleading Documentation -** **Phase 3**


Several instances where some documentation was missing or misleading were found:


  - When processing a message through the bridge, the message's target and data are

checked. While the <u>[accompanying comment](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L254)</u> says "Handle special addresses that don't

require actual invocation", the message is simply rejected if the <u>[invocation conditions](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L639-L645)</u> are

not satisfied, some of which are not related to the target address. Consider clarifying the

comment with the intention of the check.

   - The <u>[comment about reentrancy](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/L2/DelegateOwner.sol#L73)</u> for the <mark>`DelegateOwner`</mark> <mark>'</mark> s <mark>`onMessageInvocation`</mark>

function is outdated as the function is not intended to be reentered any more and is

protected from reentrancy through the <u><mark>`[Bridge](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L219)`</mark></u> <u>contract.</u>

   - The <u>[comment](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/IBridgedERC20.sol#L6-L8)</u> above the <mark>`IBridgedERC20`</mark> interface may be outdated as USDC

specifically no longer requires an intermediary adapter contract. Other tokens may

require one still.

   - The <mark>`_quota`</mark> parameter of the <mark>`updateQuota`</mark> function is described as <u>["The new daily](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/QuotaManager.sol#L51)</u>

<u>[quota", whereas the quota is measured by the](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/QuotaManager.sol#L51)</u> <u><mark>`[quotaPeriod](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/QuotaManager.sol#L22)`</mark></u> <mark>.</mark>


Taiko Protocol Audit − Notes & Additional Information − 60


   - The <u>[fee calculation](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L278-L286)</u> of the <mark>`processMessage`</mark> function is overall not documented. This

makes it more difficult to reason about how the fee is constructed. Consider adding

comments to each step of the calculation to explain why it is necessary.

   - The <u>[documentation](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/tokenvault/IBridgedERC20.sol#L6-L8)</u> around the <mark>`IBridgedERC20`</mark> interface could add a list of

specifications canonical tokens should respect. For example, the code assumes calls to

<mark>`burn`</mark> or <mark>`mint`</mark> to increase/decrease the balance by exactly the amount given as

argument. Tokens with fees on <mark>`burn`</mark> <mark>/</mark> <mark>`mint`</mark> <mark>,</mark> or taking <mark>`type(uint256)`</mark> to mean the

balance of the sender, are not supported. Similarly, a bridged token should have the

same name, symbol, and decimals as its canonical version if these are implemented.

This list of specifications could be built up over time to reduce the risk of error with such

tokens. An example of supported token specifications can be found <u>[here.](https://github.com/morpho-org/morpho-blue/blob/acf96da5bfdcb0a2ce55debc9a2fc01d99ac8ce8/src/interfaces/IMorpho.sol#L105-L114)</u>

   - The <u>[comment](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L210-L212)</u> about the amount of gas which should be associated with a transaction

calling <mark>`processMessage`</mark> is misleading. The gas sent with a transaction can in fact be

smaller than

<mark>`(message.gasLimit - GAS_RESERVE) * 64 / 63 + GAS_RESERVE`</mark> if the

invoked call uses way less gas than specified in the message's gas limit. Additionally, the

calculation is not fully accurate as it neglects the message data length that is accounted

for in the <u><mark>`[getMessageMinGasLimit](https://github.com/taikoxyz/taiko-mono/blob/dd8725f8d27f835102fa3c5a013003090268357d/packages/protocol/contracts/bridge/Bridge.sol#L452)`</mark></u> <u>function. In addition to correcting the calculation,</u>

consider rewording the comment as a recommendation, for example, as follows: "To

ensure successful execution, we recommend this transaction's gas limit not to be

smaller than: [...]".


Consider addressing the instances identified above to improve the clarity and readability of the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #17483](https://github.com/taikoxyz/taiko-mono/pull/17483)</u>_ _and_ _<u>[pull request #17546](https://github.com/taikoxyz/taiko-mono/pull/17546)</u>_ _at commit_ _<u>[7fa3b55.](https://github.com/taikoxyz/taiko-mono/blob/7fa3b55cc9322d79850bdbfb31def9c0501cf647)</u>_

## **Client Reported**

### **CR-01 Incorrect Deletion During Migration in** **‘ERC20Vault’**


The <u><mark>`[changeBridgedToken](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L148C14-L148C32)`</mark></u> function can be called by the owner of an <mark>`ERC20Vault`</mark>

contract to migrate a bridged token to another contract.


However, during this migration, a <mark>`bridgedToCanonical`</mark> mapping slot is <u>[deleted](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L180)</u> for the new

token address instead of the old token. The old token is still correctly <u>[blacklisted, meaning that](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/tokenvault/ERC20Vault.sol#L181)</u>


Taiko Protocol Audit − Client Reported − 61


it can no longer be bridged, but the mapping should be cleared correctly to make the code

clearer and save gas.


**_Update:_** _Resolved at commit_ _<u>[42c279f.](https://github.com/taikoxyz/taiko-mono/commit/42c279f0c8d884e6c3f76a2750d72a856ea6fc70)</u>_

### **CR-02 Static Calls to ‘proveSignalReceived’** **Revert on State Caching**


The <u><mark>`[proveSignalReceived](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/ISignalService.sol#L84-L90)`</mark></u> <u>function</u> in the <mark>`ISignalService`</mark> interface is <u>[called in the](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L591)</u>

<u><mark>`[_proveSignalReceived](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/bridge/Bridge.sol#L591)`</mark></u> <u>function</u> in the <mark>`Bridge`</mark> contract using a <mark>`staticcall`</mark> . However,

a static call will revert if the data is <u>[cached.](https://github.com/taikoxyz/taiko-mono/blob/b47fc34cb0e7fe9b7ebd9416b3051a067483b860/packages/protocol/contracts/signal/SignalService.sol#L122)</u>


**_Update:_** _Resolved at commit_ _<u>[dd8725f. The static call was removed, and two functions were](https://github.com/taikoxyz/taiko-mono/tree/dd8725f8d27f835102fa3c5a013003090268357d)</u>_

_made available in_ _<mark>`SignalService`</mark>_ _<mark>:</mark>_ _a view function without caching, and a separate function_

_with caching._


Taiko Protocol Audit − Client Reported − 62


## **Conclusion**

The audited codebase contains contracts composing the Taiko rollup, including the rollup

contracts themselves, the cross-chain messaging component, the governance system, and the

grants contracts.


Overall, we found the codebase to be well-written. Docstrings are present in the code but we

would recommend having additional external documentation about any design considerations

that could impact users, developers, or block proposers. This includes, for example, the

economics of block proposal as well as the differences compared to Ethereum such as

unconstrained block times, gas pricing logic, and the difficulty computation. We would also

recommend formalizing the roles of the DAO and the security council, and the rules for other

chains to connect to Taiko's signal service. Throughout our audit, the Taiko team was

responsive and receptive to feedback.


Taiko Protocol Audit − Conclusion − 63


