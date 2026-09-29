### | security

# **ZKsync: ZKChain** **and Gateway** **Upgrade Audit**

#### **October 24, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  8

ZKChain Migration 8

Multichain Operation Access Control 9

ZKsync Era Legacy Support 9

Contract Renaming 10


Security Model and Trust Assumptions _____________________________________________ 10

Privileged Roles 10


High Severity ____________________________________________________________________ 11

H-01 Inconsistent assetId Calculation Upon Bridging 11

H-02 Legacy ERC-20 Token Bridging Request Double Amount 11

H-03 Incorrect l2tol1Message Decoding With New Message Format 12

H-04 Incorrect Chain Balance Accounting For Bridged Token 12

H-05 Zero Chain Balance Increase for Bridged Native Tokens 13


Medium Severity _________________________________________________________________ 13

M-01 Inconsistent ctmAssetId Across Chains 13

M-02 Priority Tree Check Fails When Migrating Back to L1 14

M-03 Chain Migration Cannot Be Reattempted After Failure 14

M-04 Transition From baseToken to baseTokenAssetId Will Fail 15

M-05 Missing Initialization 15


Low Severity ____________________________________________________________________ 16

L-01 Naming Suggestions 16

L-02 Redundant Code 17

L-03 Unreliable L2 Token Address From Zero Address AssetId 17

L-04 Pausable Methods Are Not Exposed 18

L-05 Outdated References 18

L-06 Misleading Documentation 19

L-07 The onlyAssetRouterCounterpartOrSelf Modifier Allows Chain IDs Other Than L1_CHAIN_ID 21

L-08 Indirect BridgeHub Calls Via ChainTypeManager 21

L-09 Unconventional Proof Length 21


Notes & Additional Information ____________________________________________________ 22

N-01 Todo Comments in the Code 22


ZKsync: ZKChain and Gateway Upgrade Audit − Table of Contents − 2


N-02 Typographical Errors 23

N-03 Multiple Contracts With the Same Name 23

N-04 Duplicated Code 24

N-05 Variables Could Be immutable 24

N-06 Unused Error 25

N-07 Duplicate Imports 25


Conclusion ______________________________________________________________________ 27


ZKsync: ZKChain and Gateway Upgrade Audit − Table of Contents − 3


## **Summary**

**Type** Layer 2


**Timeline** From 2024-09-16
To 2024-10-09


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


5 (5 resolved)


5 (5 resolved)



**Total Issues** 26 (24 resolved)



**Low Severity Issues** 9 (8 resolved)



**Notes & Additional**
**Information**



7 (6 resolved)



ZKsync: ZKChain and Gateway Upgrade Audit − Summary − 4


## **Scope**

We diff-audited the <u>[matter-labs/era-contracts](https://github.com/matter-labs/era-contracts/)</u> repository with head commit <u>[ef318e21](https://github.com/matter-labs/era-contracts/commit/ef318e21)</u> against

base commit <u>[9615d90, which constitutes the changes, at the time of writing, introduced in](https://github.com/matter-labs/era-contracts/commit/9615d90)</u> <u>[pull](https://github.com/matter-labs/era-contracts/pull/793/files)</u>

<u>[request 793. A few files have been fully audited, either because of the significance of changes](https://github.com/matter-labs/era-contracts/pull/793/files)</u>

or because they were new files. The fully audited files will be noted in the following list with an

asterisk (*).


In scope were the following files related to asset bridging, and migration of ZKChains and data

availability modules:

```
da-contracts/contracts/
├── CalldataDA.sol
├── DAContractsErrors.sol *
├── IL1DAValidator.sol
├── RollupL1DAValidator.sol
└── ValidiumL1DAValidator.sol
l1-contracts/contracts
├── bridge
│  ├── BridgeHelper.sol
│  ├── BridgedStandardERC20.sol
│  ├── L1ERC20Bridge.sol
│  ├── L1Nullifier.sol *
│  ├── L2SharedBridgeLegacy.sol
│  ├── L2WrappedBaseToken.sol
│  ├── asset-router
│  │  ├── AssetRouterBase.sol *
│  │  ├── IAssetRouterBase.sol
│  │  ├── IL1AssetRouter.sol
│  │  ├── IL2AssetRouter.sol
│  │  ├── L1AssetRouter.sol *
│  │  └── L2AssetRouter.sol *
│  ├── interfaces
│  │  ├── IAssetHandler.sol *
│  │  ├── IBridgedStandardToken.sol
│  │  ├── IL1AssetDeploymentTracker.sol *
│  │  ├── IL1AssetHandler.sol
│  │  ├── IL1BaseTokenAssetHandler.sol *
│  │  ├── IL1ERC20Bridge.sol
│  │  ├── IL1Nullifier.sol *
│  │  ├── IL1SharedBridgeLegacy.sol *
│  │  ├── IL2SharedBridgeLegacy.sol
│  │  ├── IL2SharedBridgeLegacyFunctions.sol
│  │  └── IL2WrappedBaseToken.sol
│  └── ntv
│    ├── IL1NativeTokenVault.sol
│    ├── IL2NativeTokenVault.sol

```

ZKsync: ZKChain and Gateway Upgrade Audit − Scope − 5


```
│    ├── INativeTokenVault.sol *
│    ├── L1NativeTokenVault.sol *
│    ├── L2NativeTokenVault.sol *
│    └── NativeTokenVault.sol *
├── bridgehub
│  ├── Bridgehub.sol
│  ├── CTMDeploymentTracker.sol
│  ├── IBridgehub.sol
│  ├── ICTMDeploymentTracker.sol
│  ├── IMessageRoot.sol
│  └── MessageRoot.sol
└── state-transition
├── ChainTypeManager.sol
├── IChainTypeManager.sol
├── ValidatorTimelock.sol
├── chain-deps
│  ├── DiamondInit.sol
│  ├── ZKChainStorage.sol
│  └── facets
│    ├── Admin.sol
│    ├── Executor.sol
│    ├── Getters.sol
│    ├── Mailbox.sol
│    └── ZKChainBase.sol
├── chain-interfaces
│  ├── IAdmin.sol
│  ├── IDiamondInit.sol
│  ├── IExecutor.sol
│  ├── IGetters.sol
│  ├── IL1DAValidator.sol
│  ├── ILegacyGetters.sol
│  ├── IMailbox.sol
│  ├── IVerifier.sol
│  ├── IZKChain.sol
│  └── IZKChainBase.sol
├── data-availability
│  ├── CalldataDA.sol
│  ├── CalldataDAGateway.sol *
│  └── RelayedSLDAValidator.sol
├── l2-deps
│  ├── IL2GenesisUpgrade.sol
│  └── ISystemContext.sol
└── libraries
├── BatchDecoder.sol *
└── PriorityTree.sol
l2-contracts/contracts
├── data-availability
│  ├── DAErrors.sol
│  ├── RollupL2DAValidator.sol
│  ├── StateDiffL2DAValidator.sol
│  └── ValidiumL2DAValidator.sol
├── interfaces
│  └── IL2DAValidator.sol
└── verifier
└── chain-interfaces
└── IVerifier.sol

```


ZKsync: ZKChain and Gateway Upgrade Audit − Scope − 6


```
system-contracts/contracts/interfaces
├── IBridgehub.sol *
├── IL2DAValidator.sol
└── IL2GenesisUpgrade.sol

```

**_Update:_** _We also audited_ _<u>[pull request 939](https://github.com/matter-labs/era-contracts/pull/939)</u>_ _and_ _<u>[pull request 948](https://github.com/matter-labs/era-contracts/pull/948)</u>_ _which contain the migration_

_from_ _<mark>`require`</mark>_ _and_ _<mark>`revert`</mark>_ _statements to custom errors throughout the codebase._


ZKsync: ZKChain and Gateway Upgrade Audit − Scope − 7


## **System Overview**

The changeset introduces significant updates to ZKChain migration and settlement on non-L1

layers and the coordination infrastructure for message passing and token bridging. We provide

a more detailed description below.

### **ZKChain Migration**


Every new ZKChain is initiated on L1 after which it can be migrated to any whitelisted

Settlement Layer (SL). Currently, the only whitelisted SLs are L1 and Gateway. Thus, ZKChains

can essentially migrate from L1 to Gateway and back to L1.


The migration path follows the custom asset bridging framework via the <mark>`ChainTypeManager`</mark>

(CTM). Similar to ZKChains, CTMs are initially registered on L1 and can only be registered to

another SL via a cross-chain transaction afterwards. CTM registrations on L1 are initiated <u>[by](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L248)</u>

<u>the owner of the</u> <u><mark>`[Bridgehub](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L248)`</mark></u> <u>contract</u> and only completed <u>[by the owner of the](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/CTMDeploymentTracker.sol#L61)</u>

<u><mark>`[CTMDeploymentTracker](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/CTMDeploymentTracker.sol#L61)`</mark></u> <u>contract. Each CTM is associated with an</u> <mark>`assetId`</mark> <mark>,</mark> just like how

the common tokens are tracked in the system.


CTMs handle the basic functionality for a ZKChain's migration. As such, in order to migrate a

ZKChain, its associated SL CTM should be deployed and registered on the destination

<mark>`Bridgehub`</mark> <mark>.</mark> In essence, <mark>`Bridgehub`</mark> is the asset handler of the CTM assets, just like

<mark>`NativeTokenVault`</mark> is for common assets. For this reason, when a CTM is registered on an

SL, it is necessary to also assign the local <mark>`bridgehub`</mark> contract as its asset handler. Both

CTM and common assets share the same asset router contracts.


In light of the above, the complete flow to successfully migrate a ZKChain from L1 to Gateway

would require the following cross-chain actions:


1. <u>[Deploy an L2 CTM and register it](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L322)</u> in the destination SL <mark>`BridgeHub`</mark> <mark>.</mark>

2. Assign that <u>[CTM's asset handler address](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L94)</u> to be <mark>`Bridgehub`</mark> on SL.

3. Migrate the ZKChain. The migration itself ensures that the ZKChain's <u>[L1 Diamond and](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L680)</u>

<u>[helper contracts are updated properly](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L680)</u> and an L2 Diamond <u>[is deployed and properly](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L721)</u>

<u>[configured as well.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L721)</u>


ZKsync: ZKChain and Gateway Upgrade Audit − System Overview − 8


Once the migration is complete, the ZKChain's batches are committed, proved, and executed

on the Gateway. The Gateway itself is responsible for handling the published data of all of its

settled ZKChains and settling them altogether on L1.


To migrate back from Gateway to L1, the ZKChain admin initiates a withdrawal request from

the Gateway's <u><mark>`[L2AssetRouter](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L136)`</mark></u> <u>contract, setting the</u> <mark>`assetId`</mark> parameter equal to the

<mark>`ctmAssetId`</mark> for the CTM associated with the migrated zkChain. The final cross-chain

message can be used to call <u><mark>`[finalizeDeposit](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L113)`</mark></u> on L1's <mark>`AssetRouter`</mark> contract and

complete the migration by updating the ZKChain's Diamond Proxy and the rest of the helper

contracts.


A recovery mechanism has also been implemented in case a ZKChain migration fails.

### **Multichain Operation Access Control**


Since a ZKChain is not restricted to being settled on Ethereum, the same state transition

contracts, including the <mark>`ChainTypeManager`</mark> and the diamond proxy (with all its facets) can

be deployed on any legitimate SL, including L1 and the Gateway. Furthermore, communication

contracts such as the <mark>`Bridgehub`</mark> are deployed on all layers, including non-settlement L2s.


As such, some functions are restricted by the layer the contract is deployed on. Additional

modifiers such as <mark>`onlyL1`</mark> <mark>,</mark> <mark>`chainOnCurrentBridgehub`</mark> <mark>,</mark> and

<mark>`onlySettlementLayerRelayedSender`</mark> are used to reflect this. Moreover, further access

control is added on key communication functions within a layer, for example,

<mark>`onlyBridgehub`</mark> <mark>,</mark> <mark>`onlyChain`</mark> <mark>,</mark> <mark>`onlyAssetRouter`</mark> <mark>,</mark> <mark>`onlyNativeTokenVault`</mark> or

between layers, such as <mark>`onlyAssetRouterCounterpart`</mark> <mark>.</mark>

### **ZKsync Era Legacy Support**


To fit into the custom asset bridging (CAB) framework via the <mark>`bridgeBurn`</mark> and <mark>`bridgeMint`</mark>

functions on the default asset handler, the legacy bridging for ZKsync Era on

<mark>`L1ERC20Bridge`</mark> and <mark>`L2SharedBridgeLegacy`</mark> are re-routed to their respective asset

router contracts.


ZKsync: ZKChain and Gateway Upgrade Audit − System Overview − 9


### **Contract Renaming**

Since the last audited version of the codebase, some contracts have been renamed and/or

organized differently:


   - The <mark>`StateTransitionManager`</mark> has been renamed to <mark>`ChainTypeManager`</mark> <mark>.</mark>

   - The <mark>`L1SharedBridge`</mark> logic has been split into two separate contracts:

<mark>`L1AssetRouter`</mark> and <mark>`L1Nullifier`</mark> <mark>.</mark>

   - The <mark>`L2SharedBridge`</mark> has been renamed to <mark>`L2AssetRouter`</mark> <mark>.</mark>

## **Security Model and Trust** **Assumptions**

### **Privileged Roles**


In relation to the changeset, the following privileged roles can perform critical functionality:


   - The owner of coordinating contracts such as <mark>`CTMDeploymentTracker`</mark> <mark>,</mark> <mark>`Bridgehub`</mark> <mark>,</mark>

<mark>`L1AssetRouter`</mark> <mark>,</mark> <mark>`L1NativeTokenVault`</mark> <mark>,</mark> <mark>`L2AssetRouter`</mark> <mark>,</mark> and

<mark>`L2NativeTokenVault`</mark> <mark>,</mark> can pause/unpause and upgrade the contract logic.

   - The owners of the <mark>`BridgeHub`</mark> and <mark>`CTMDeploymentTracker`</mark> L1 contracts can

register new CTM assets.

   - The owner of the <mark>`Bridgehub`</mark> contract on L1 can add or remove an SL from the

whitelist.

   - The admin of each ZKChain can initiate and finalize chain migration.


We assume that the accounts in charge of the above actions always act in the intended way.

Hence, any attacks or vulnerabilities targeting this part of the system were not considered

throughout this audit.


ZKsync: ZKChain and Gateway Upgrade Audit − Security Model and Trust

Assumptions − 10


## **High Severity**

### **H-01 Inconsistent assetId Calculation Upon** **Bridging**

In the <mark>`_assetIdCheck`</mark> function of the <mark>`NativeTokenVault`</mark> contract, the

<u><mark>`[_originChainId](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L379)`</mark></u> used to compute the expected <mark>`assetId`</mark> is not referring to the chain

where to token is native to. Instead, it refers to the chain where the token has been bridged

from. In fact, the actual native chain of the token is retrieved later on in the execution flow,

<u>[upon initializing the bridged token contract.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L421)</u>


This breaks the assumption that each token has the same <mark>`assetId`</mark> across chains, potentially

resulting in failed bridging transactions. This does not affect tokens that originate from an L2

and are then bridged to L1 as the <mark>`assetId`</mark> is coincidentally correctly calculated because the

original <mark>`chainId`</mark> is the same as the chain where it is coming from. However, it impacts the

bridging of bridged tokens, i.e., a bridged token on L1 cannot be bridged correctly to another

L2, where the incoming <mark>`chainId`</mark> is different from the origin <mark>`chainId`</mark> <mark>.</mark> A use case of this

would be bridging a token native to ZKsync Era first to L1 and then to the Gateway.


Consider retrieving the actual origin chain of the bridged token to compute its expected

<mark>`assetId`</mark> upon bridging.


**_Update:_** _Resolved in_ _<u>[pull request #894.](https://github.com/matter-labs/era-contracts/pull/894/files)</u>_

### **H-02 Legacy ERC-20 Token Bridging Request** **Double Amount**


When bridging ERC-20 tokens which are native to L1 via the legacy

<u><mark>`[L1ERC20Bridge.deposit](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L176)`</mark></u> <mark>,</mark> a user is required to deposit twice the requested amount in the

following order.


   - First, one <u>[transfers the requested amount to](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L191)</u> <u><mark>`[L1AssetRouter](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L191)`</mark></u> <mark>.</mark>


   - Then, in <mark>`L1AssetRouter.sol`</mark> <mark>,</mark> the tokens from the original caller are <u>[burned.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L483)</u>

Specifically, <u>[the original caller](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/L1NativeTokenVault.sol#L140)</u> needs to <u>[transfer](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L385)</u> the same amount to


ZKsync: ZKChain and Gateway Upgrade Audit − High Severity − 11


<mark>`L1NativeTokenVault`</mark> if there is enough allowance. If <mark>`L1AssetRouter`</mark> is not

granted enough allowance, the transfer happens <u>[later.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L265)</u>


To ensure that the correct amount is transferred for bridging, consider removing the first token

transfer to <mark>`L1AssetRouter`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #895.](https://github.com/matter-labs/era-contracts/pull/895)</u>_

### **H-03 Incorrect l2tol1Message Decoding With** **New Message Format**


When a user initiates a withdrawal on <mark>`L2AssetRouter.withdraw`</mark> using the new message

format, the <u>[message](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L163C1-L163C83)</u> is <u>[encoded](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L185)</u> with function signature

<mark>`IAssetRouterBase.finalizeDeposit.selector`</mark> <mark>,</mark> <mark>`_assetId`</mark> <mark>,</mark> and

<mark>`_l1bridgeMintData`</mark> <mark>.</mark> Then, on L1, the user finalizes the deposit on <mark>`L1Nullifier`</mark> <mark>,</mark> and

the <mark>`l2toL1Message`</mark> <u>[is decoded](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L412)</u> to get the <mark>`_assetId`</mark> and <mark>`transferData`</mark> via

<u>[_parseL2WithdrawalMessage.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L500)</u>


However, the message decoding for the <mark>`finalizeDeposit`</mark> function selector accounts for <u>[an](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L604)</u>

<u>[extra 32 bytes](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L604)</u> for <mark>`originChainId`</mark> which are not present when the message is packed on

<mark>`L2AssetRouter`</mark> <mark>.</mark> Thus, the decoded <mark>`transferData`</mark> will not be correct, resulting in failed

execution on L1. This impacts all token bridging from L2 to L1 using the new withdraw

message format.


Consider correctly decoding the <mark>`12ToL1Message`</mark> to allow successful token withdrawal on

L1.


**_Update:_** _Resolved in_ _<u>[pull request #896.](https://github.com/matter-labs/era-contracts/pull/896)</u>_

### **H-04 Incorrect Chain Balance Accounting For** **Bridged Token**


When an amount of an L2-native token is bridged in from an L2 origin chain to L1,

<mark>`L1NativeTokenVault`</mark> decreases the origin chain's balance through

<u><mark>`[_bridgeMintBridgedToken](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L137)`</mark></u> <mark>.</mark> However, when the token is bridged out of L1, the receiving

chain's balance is not accordingly increased in <u><mark>`[_bridgeBurnBridgedToken](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L185)`</mark></u> <mark>.</mark> This

inconsistency can result in failed bridging transactions back to L1 due to underflow when

attempting to decrease a chain's balance.


ZKsync: ZKChain and Gateway Upgrade Audit − High Severity − 12


Consider increasing the receiving chain's balance within <mark>`_bridgeBurnBridgedToken`</mark> to

ensure proper accounting consistency.


**_Update:_** _Resolved in_ _<u>[pull request #897.](https://github.com/matter-labs/era-contracts/pull/897)</u>_

### **H-05 Zero Chain Balance Increase for Bridged** **Native Tokens**


In the <u><mark>`[_bridgeBurnNativeToken](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L234)`</mark></u> function of the <mark>`NativeTokenVault`</mark> contract, the token

balance increase of the destination ZKChain that accepts the deposit is a no-op. More

specifically, the balance increase action <u>[is performed before the](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L262-L263)</u> <u><mark>`[amount](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L262-L263)`</mark></u> <u>assignment</u> resulting

in the balance not being updated. As a consequence, a subsequent transaction to bridge back

the deposited token funds will fail due to an <u>[underflow error.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L151)</u>


Consider changing the order of these two instructions so that the balances are properly

updated.


**_Update:_** _Resolved in_ _<u>[pull request #898.](https://github.com/matter-labs/era-contracts/pull/898)</u>_

## **Medium Severity**

### **M-01 Inconsistent ctmAssetId Across Chains**


The <u>[ctmAssetId](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L428)</u> function computes the <mark>`assetId`</mark> for a given <mark>`_ctmAddress`</mark> by encoding it

with the <mark>`L1_CHAIN_ID`</mark> and <mark>`l1CtmDeployer`</mark> on the Bridgehub contract deployed on all

chains. Thus, on an L2 chain, the returned <mark>`ctmAssetId`</mark> from <u><mark>`[ctmAssetIdFromChainId](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L420)`</mark></u> is

computed from an <mark>`l2ctmAddress`</mark> because of the value of

<u><mark>`[chainTypeManager[_chainId]](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L425C27-L425C43)`</mark></u> <mark>.</mark> As a result, the returned <mark>`ctmAssetId`</mark> based on the

<mark>`l2ctmAddress`</mark> will be different from the ctm asset ID that has been migrated over from an

<mark>`l1ctmAddress`</mark> <mark>.</mark>


This has implications for the validation of the <mark>`ctmAssetId`</mark> during chain migration from the

Gateway back to L1. When migrating from L1 to the Gateway, the chain type manager of the

<u>[migrated chain](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L728)</u> will be an <mark>`l2ctmAddress`</mark> <u>[set](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L733)</u> via <mark>`bridgeMint`</mark> on the Gateway Bridgehub.

However, when the chain intends to migrate back to L1, the Gateway

<mark>`Bridgehub.bridgeBurn`</mark> is called with <mark>`_assetID`</mark> being the <mark>`l1ctmAssetId`</mark>, causing <u>[this](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L690)</u>

<u>[check](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L690)</u> to fail because <mark>`ctmAssetIdFromChainId`</mark> <u>[computes](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L421C30-L421C46)</u> from the <mark>`l2ctmAddress`</mark> on


ZKsync: ZKChain and Gateway Upgrade Audit − Medium Severity − 13


Gateway and will not return the same asset ID as the <mark>`l1ctmAddress`</mark> asset ID. Note that a

correctly returned <mark>`l2ctmAssetId`</mark> will not allow this check to pass either. The migrating

<mark>`l1ctmAssetId`</mark> needs to be validated differently.


Consider correcting the returned CTM address to ensure the consistency of asset IDs across

chains and validating them accordingly.


**_Update:_** _Resolved in_ _<u>[pull request #899.](https://github.com/matter-labs/era-contracts/pull/899)</u>_

### **M-02 Priority Tree Check Fails When Migrating** **Back to L1**


When a ZKChain migrates back from the Gateway to L1, the Bridgehub forwards it to the

ZKChain's existing <u><mark>`[AdminFacet.forwardedBridgeMint](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L313)`</mark></u> function. After this, the priority

tree on L1 will be re-initiated by the Gateway priority tree commitment.


When an L2 transaction is requested, a <u><mark>`[PriorityOp](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L485)`</mark></u> <u>is written</u> in the L1 Diamond Proxy

before the transaction is forwarded to the Gateway. However, it is never processed because

<mark>`executeBatch`</mark> only happens on the settlement chain (i.e., the Gateway after migration). Only

when <u>[processing batches](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L419)</u> can one increase the <u>[unprocessed index of the tree. Hence, the L1](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/libraries/PriorityTree.sol#L79)</u>

<mark>`priorityTree.unprocessedIndex`</mark> will not increase while the chain is settled elsewhere.

For this reason, when the chain migrates back to L1, the <u>[re-initiating check](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L323)</u> should be

<mark>`_tree.unprocessedIndex <= _commitment.unprocessedIndex`</mark> instead of <u>[the other](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/libraries/PriorityTree.sol#L103)</u>

<u>[way around. Furthermore, the L1 priority](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/libraries/PriorityTree.sol#L103)</u> <mark>`tree.unprocessedIndex`</mark> is not updated from the

commitment, resulting in wrong values when calling <u>[functions](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/libraries/PriorityTree.sol#L32)</u> such as

<mark>`getFirstUnprocessedPriorityTx`</mark> and <mark>`getSize`</mark> <mark>.</mark>


Consider checking that the <mark>`unprocessedIndex`</mark> in the L1 priority tree is less than the

commitment from the Gateway, while updating the <mark>`tree.unprocessedIndex`</mark> from the

commitment when migrating back to L1.


**_Update:_** _Resolved in_ _<u>[pull request #900.](https://github.com/matter-labs/era-contracts/pull/900)</u>_

### **M-03 Chain Migration Cannot Be Reattempted** **After Failure**


In the case of a failed chain migration, the <u><mark>`[settlementLayer](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L692)`</mark></u> is set to a new chain ID in the

<mark>`bridgeBurn`</mark> function on the old chain, but the <mark>`bridgeMint`</mark> function is not successfully

executed on the new chain. In this case, one can call the <u><mark>`[bridgeRecoverFailedTransfer](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L293)`</mark></u>


ZKsync: ZKChain and Gateway Upgrade Audit − Medium Severity − 14


function of the <mark>`L1Nullifier`</mark> contract in order to reset the <mark>`settlementLayer`</mark> chainId on

L1 <mark>`Bridgehub`</mark> back to its previous value.


However, within the <mark>`BridgeHub`</mark> contract, instead of being set back to <mark>`block.chainId`</mark> <mark>,</mark> the

settlement layer is <u>[deleted. This prevents further migration attempts because of a requirement](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L765)</u>

for the <mark>`settlementLayer`</mark> value in the <u><mark>`[bridgeBurn](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L691)`</mark></u> function.


Consider resetting the <mark>`settlementLayer`</mark> back to <mark>`block.chainid`</mark> rather than deleting it.


**_Update:_** _Resolved in_ _<u>[pull request #918.](https://github.com/matter-labs/era-contracts/pull/918)</u>_

### **M-04 Transition From baseToken to** **baseTokenAssetId Will Fail**


The <u><mark>`[setLegacyBaseTokenAssetId](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L218)`</mark></u> <u>function</u> of the <mark>`BridgeHub`</mark> contract is supposed to

set the base token's <mark>`assetId`</mark> for every ZKChain that is already registered, essentially

facilitating the transition from the legacy <u><mark>`[baseToken](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L63)`</mark></u> mapping to the <u><mark>`[baseTokenAssetId](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L80)`</mark></u>

mapping.


However, the function <u>[is mistakenly a no-op](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L219-L220)</u> in case <mark>`baseTokenAssetId[_chainId]`</mark> is

unassigned, whereas this should be required for the function to proceed. As a result, assigning

an asset ID to the base tokens of already registered chains fails.


Consider fixing the <mark>`setLegacyBaseTokenAssetId`</mark> function so that, instead of performing a

no-op, it requires the base token being set to not already be initialized.


**_Update:_** _Resolved in_ _<u>[pull request #901.](https://github.com/matter-labs/era-contracts/pull/901)</u>_

### **M-05 Missing Initialization**


The <u>[L2AssetRouter](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L27)</u> does not have an <mark>`initialize`</mark> function despite its parent contract

<u>[AssetRouterBase](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L24)</u> being initializable, ownable, and upgradeable. As such, the <mark>`owner`</mark> is not

initialized resulting in the <mark>`onlyOnwner`</mark> <u>[pause/unpause](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L157-L162)</u> functionality to not work. Similarly, the

<u>[L2NativeTokenVault](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/L2NativeTokenVault.sol#L31)</u> is missing an <mark>`initialize`</mark> function despite it inheriting from

<u>[NativeTokenVault](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L30)</u> which is initializable, ownable, and upgradeable.


Note that since the aforementioned contracts use <u>[the upgradeable version](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L30C73-L30C117)</u> of the Ownable and

Pausable OpenZeppelin libraries, initialization is only possible through a function decorated

with the <mark>`initializer`</mark> modifier.


ZKsync: ZKChain and Gateway Upgrade Audit − Medium Severity − 15


Consider adding an <mark>`initialize`</mark> function to initialize all state variables in the proxy.

Alternatively, consider clearly documenting whether these contracts are meant for direct

deployment without proxy.


**_Update:_** _Resolved in commit_ _<u>[7206350](https://github.com/matter-labs/era-contracts/pull/672/commits/7206350a0ffd9f2de0ecd38e7f9e2cd711a5dd81#diff-d2615448517f84f9c2cc9245624f9b016ab4bc6121812de6366626b5b4f48818)</u>_ _and_ _<u>[pull request #902. The contracts will be deployed](https://github.com/matter-labs/era-contracts/pull/902)</u>_

_directly and the owner will be set during construction._

## **Low Severity**

### **L-01 Naming Suggestions**


Throughout the codebase, multiple instances of misleading naming were identified:


   - The <u><mark>`[setAssetHandlerAddress](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L300)`</mark></u> function in <mark>`Bridgehub.sol`</mark> suggests that

<mark>`Bridgehub`</mark> is the asset router for the CTM asset which serves chain migration

purposes. However, <mark>`Bridgehub`</mark> itself is the asset handler, not the asset router. Since

this function only updates the <mark>`ctmAssetIdToAddress`</mark> state variable, consider

renaming it so that its name clearly reflects its purpose.

   - In the <u>[setAssetHandlerAddress](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L300)</u> function in <mark>`BridgeHub.sol`</mark> <mark>,</mark> consider renaming the

<u><mark>`[assetInfo](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L321)`</mark></u> variable to <mark>`ctmAssetId`</mark> to be consistent with the rest of the codebase.

   - In the <u>[setAssetHandlerAddress](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L89)</u> function of the <mark>`L2AssetRouter`</mark> contract, the

<u><mark>`[_assetAddress](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L92)`</mark></u> parameter name is misleading. Consider renaming it to

<mark>`_assetHandlerAddress`</mark> <mark>.</mark>

   - In the <mark>`calculateCreate2TokenAddress`</mark> function of the <mark>`L1NativeTokenVault`</mark>

contract, the <u><mark>`[l1Token](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/L1NativeTokenVault.sol#L194)`</mark></u> argument is actually an L2 token address. Consider renaming it

to <mark>`_l2Token`</mark> <mark>.</mark>







<u><mark>`[BridgeMintData](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/common/libraries/DataEncoding.sol#L23)`</mark></u> is used to mint bridged tokens on both L1 and L2 chains. However,



the names of its parameters do not reflect the bi-directional encoding. For example,

<u>[_l2Receiver](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L595)</u> is in fact an L1 receiver when bridging is from L2. Consider differentiating the

direction by non-specific references such as <mark>`_remoteReceiver`</mark> to represent the

receiver address on another chain. Similarly, <u>[_l1Token](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L284)</u> can be simply called <mark>`_token`</mark>

when referring to this chain and <mark>`_remoteToken`</mark> when referring to the receiving or

incoming chain.


Consider adopting the above naming suggestions to improve the clarity and readability of the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #903.](https://github.com/matter-labs/era-contracts/pull/903)</u>_


ZKsync: ZKChain and Gateway Upgrade Audit − Low Severity − 16


### **L-02 Redundant Code**

Throughout the codebase, multiple instances of redundant code were identified:


   - In the <mark>`Bridgehub`</mark> contract <mark>,</mark> <u><mark>`[whitelistedSettlementLayers](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L157)`</mark></u> is set to <mark>`true`</mark> for

<mark>`L1_CHAIN_ID`</mark> during the construction of the implementation contract. However, it is

only necessary to be set in the <u><mark>`[initialize](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L166C9-L166C36)`</mark></u> <u>function.</u>

   - In the <u><mark>`[L1NativeTokenVault](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/L1NativeTokenVault.sol#L38)`</mark></u> and <u><mark>`[ValidatorTimelock](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L56)`</mark></u> contracts, the immutable

<mark>`ERA_CHAIN_ID`</mark> state variable is defined and initialized but is never used.

   - The <u><mark>`[encodeNTVAssetId(uint256 _chainId, bytes32 _assetData)](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/common/libraries/DataEncoding.sol#L82)`</mark></u> function

of the <mark>`EncodingData`</mark> library is not used within the codebase.

   - In the <mark>`setAssetDeploymentTracker`</mark> function of the <mark>`L1AssetRouter`</mark> contract,

<mark>`block.chainId`</mark> <u>[is redundantly cast](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L145)</u> to <mark>`uint256`</mark> <mark>.</mark>

   - In the <mark>`IAssetRouterBase`</mark> interface, the <u><mark>`[BridgehubWithdrawalInitiated](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/IAssetRouterBase.sol#L35)`</mark></u> <u>event</u>

is not used anywhere in the entire codebase.

   - In <u><mark>`[IAssetHandler.sol](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/interfaces/IAssetHandler.sol#L11)`</mark></u> <mark>,</mark> <u><mark>`[IChainTypeManager.sol](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/IChainTypeManager.sol#L159)`</mark></u> <mark>,</mark> and <u><mark>`[IAdmin.sol](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-interfaces/IAdmin.sol#L131)`</mark></u>, the

<mark>`BridgeInitialize`</mark> event remains unused.

   - In <mark>`L1ERC20Bridge`</mark> <mark>,</mark> the <u><mark>`[isWithdrawalFinalized](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L42-L43)`</mark></u> mapping is never assigned and

<u>[the code](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L134-L135)</u> where it is used is essentially a no-op. Consider marking the mapping as

deprecated and removing the unused code for improved code clarity.

   - In <mark>`L1Nullifier.sol`</mark> <mark>,</mark> the <u><mark>`[onlyBridgeHubOrEra](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L126)`</mark></u> and

<u><mark>`[onlyAssetRouterOrErc20Bridge](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L142)`</mark></u> modifiers are not used anywhere within the

contract.

   - The <u><mark>`[onlyBaseTokenBridge](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/ZKChainBase.sol#L65)`</mark></u> modifier defined in <mark>`ZKChainBase.sol`</mark> is never used in

the codebase.

   - The <u><mark>`[onlyChainCTM](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L110-L115)`</mark></u> modifier in <mark>`Bridgehub.sol`</mark> is never used within the codebase.

   - The <u><mark>`[onlyValidatorOrChainTypeManager](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/ZKChainBase.sol#L58-L63)`</mark></u> modifier in <mark>`ZKChainBase.sol`</mark> is never

used within the codebase.


Consider removing any redundant or unused code throughout the codebase for enhanced

code clarity and readability.


**_Update:_** _Resolved in_ _<u>[pull request #904.](https://github.com/matter-labs/era-contracts/pull/904)</u>_

### **L-03 Unreliable L2 Token Address From Zero** **Address AssetId**


In the <mark>`L2NativeTokenVault`</mark> contract, anyone can call <u><mark>`[setLegacyTokenAssetId](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/L2NativeTokenVault.sol#L87)`</mark></u> with

any <mark>`_l2TokenAddress`</mark> <mark>.</mark> For a non-existent <mark>`_l2TokenAddress`</mark> <mark>,</mark> the value returned by


ZKsync: ZKChain and Gateway Upgrade Audit − Low Severity − 17


<mark>`L2_LEGACY_SHARED_BRIDGE.l1TokenAddress(_l2TokenAddress)`</mark> would be the zero

address. This can be used to form a non-zero asset ID and set its <mark>`tokenAddress`</mark> to be an

arbitrary <mark>`l2TokenAddress`</mark> repeatedly. This results in an unreliable returned <u>[l2TokenAddress](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/L2NativeTokenVault.sol#L226)</u>

for that zero-address asset ID for third-party integrations.


Consider reverting a call to <mark>`setLegacyTokenAssetId`</mark> that attempts to set a non-existent

<mark>`_l2TokenAddress`</mark> <mark>.</mark> This will ensure consistent return value for all asset IDs.


**_Update:_** _Resolved in_ _<u>[pull request #905.](https://github.com/matter-labs/era-contracts/pull/905)</u>_

### **L-04 Pausable Methods Are Not Exposed**


If a contract inherits pausable contracts, the <mark>`_pause`</mark> and <mark>`_unpause`</mark> internal functions

should be exposed using public/external functions. However, <u><mark>`[CTMDeploymentTracker](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/CTMDeploymentTracker.sol#L21-L147)`</mark></u> is a

pausable contract that does not expose the internal pausable functions. The

<mark>`whenNotPaused`</mark> modifier is not used either.


To ensure the intended pausable functionality of the contracts, consider exposing <mark>`_pause`</mark>

and <mark>`_unpause`</mark> functions through public or external functions. Alternatively, consider removing

the pausable functionality if not intended.


**_Update:_** _Resolved in_ _<u>[pull request #906. The](https://github.com/matter-labs/era-contracts/pull/906)</u>_ _<mark>`CTMDeployerTracker`</mark>_ _does not inherit the_

_<mark>`PausableUpgradeable`</mark>_ _library anymore._

### **L-05 Outdated References**


Throughout the codebase, multiple instances of docstrings and variable/function names

referring to legacy identifiers were identified:


References to "state transition manager":








<mark>`Bridgehub.sol`</mark> <mark>,</mark> line <u>[246: "State transition" should be](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L246)</u> <mark>`chainTypeManager`</mark> <mark>.</mark>

<mark>`Bridgehub.sol`</mark> <mark>,</mark> line <u>[260: "State transition" should be](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L260)</u> <mark>`chainTypeManager`</mark> <mark>.</mark>



References to "shared bridge":









<mark>`Bridgehub.sol`</mark> <mark>,</mark> line <u>[49: "shared Bridge" should be "asset router".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L49)</u>

<mark>`Bridgehub.sol`</mark> <mark>,</mark> line <u>[440: "Shared Bridge" should be "asset router".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L440)</u>

<mark>`CTMDeploymentTracker.sol`</mark> <mark>,</mark> line <u>[50:](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/CTMDeploymentTracker.sol#L50)</u> <mark>`_sharedBridge`</mark> should be

<mark>`l1AssetRouter`</mark> (also in the function's parameter).


ZKsync: ZKChain and Gateway Upgrade Audit − Low Severity − 18


<mark>`Bridgehub.sol`</mark> <mark>,</mark> line <u>[888: The](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L888)</u> <mark>`sharedBridge`</mark> function is defined in a section



<u>[denoting legacy functions. However, it is used by the](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L879)</u> <u><mark>`[ChainTypeManager](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L495)`</mark></u> contract to

retrieve the asset router contract address. Therefore, neither its call site nor the returned

data are related to legacy functionality.


Consider updating all references to legacy names when the corresponding functionality is non
legacy. This will help enhance the clarity and readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #907.](https://github.com/matter-labs/era-contracts/pull/907)</u>_

### **L-06 Misleading Documentation**


Throughout the codebase, multiple instances of misleading documentation were identified:


<mark>`ChainTypeManager.sol`</mark> <mark>:</mark>


   - Line <u>[445: does not describe the code below it.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L445)</u>


   - Line <u>[362: does not describe the code below it.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L362)</u>


<mark>`DataEncoding.sol`</mark> <mark>:</mark>


   - Line <u>[86: does not match the implementation. "assetData" should be "tokenAddress".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/common/libraries/DataEncoding.sol#L86)</u>


<mark>`L1AssetRouter.sol`</mark> <mark>:</mark>


   - <u>[Line 160: the comment states that the caller is not subject to access control because](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L160)</u>

<mark>`msg.sender`</mark> is encoded in the <mark>`assetId`</mark> <mark>.</mark> However, <mark>`assetId`</mark> remains unused within

the call to the <u><mark>`[bridgeCheckCounterpartAddress](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L172C69-L172C98)`</mark></u> function, while the original caller

is actually <u>[access-controlled.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/CTMDeploymentTracker.sol#L114)</u>


<mark>`NativeTokenVault.sol`</mark> <mark>:</mark>


   - Line <u>[49:](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L49)</u> <mark>`tokenAddress`</mark> should be <mark>`originChainId`</mark> <mark>.</mark>

   - Line <u>[163:](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L163)</u> <mark>`bridgeBurn`</mark> returns calldata that is used not just for L2->L1 messages but

also for L1->L2 messages.


<mark>`L2AssetRouter.sol`</mark> <mark>:</mark>


   - Line <u>[128: the](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L128)</u> <mark>`LEGACY FUNCTIONS`</mark> comment is placed earlier than the <u>[actual starting](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L188)</u>

<u>[point](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L188)</u> of the legacy functions in the contract.

   - Line <u>[133: the comment mistakenly states that this](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L133)</u> <mark>`withdraw`</mark> function is legacy.


ZKsync: ZKChain and Gateway Upgrade Audit − Low Severity − 19


<mark>`L1Nullifier.sol`</mark> <mark>:</mark>


   - Line <u>[270: the comment states that the internal](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L270)</u> <mark>`_encodeTxDataHash`</mark> function is called

but such a function does not exist. Instead, the <mark>`DataEncoding`</mark> library is called.

   - Line <u>[411:](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L411)</u> <mark>`_verifyWithdrawal`</mark> handles all withdrawal cases instead of only the

"special case from ZKsync Era that were initiated before the Shared Bridge".


<mark>`BridgeHub.sol`</mark> <mark>:</mark>


   - Line <u>[30:](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L30)</u> <mark>`Bridgehub`</mark> is currently the primary entry point only for L1->L2 communication,

not L2->L1 communication.


<mark>`IAssetHandler.sol`</mark> <mark>:</mark>


   - Line <u>[30:](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/interfaces/IAssetHandler.sol#L30)</u> <mark>`bridgeBurn`</mark> returns calldata that is used not only for L2->L1 messages but

also for L1->L2 messages.


<mark>`CTMDeploymentTracker.sol`</mark> <mark>:</mark>


   - Line <u>[25: "Bridgehub" should be "L1AssetRouter".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/CTMDeploymentTracker.sol#L25)</u>


<mark>`Admin.sol`</mark> <mark>:</mark>


   - Line <u>[344: the caller is checked to be the](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L344)</u> <u>[chain admin.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L356)</u>


<mark>`L2ContractAddresses.sol`</mark> <mark>:</mark>


   - Line <u>[41: "L2<>L2" should be L1->L2 since L2<>L2 communication is not yet supported.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/common/L2ContractAddresses.sol#L41)</u>


<mark>`MessageRoot.sol`</mark> <mark>:</mark>


   - Line <u>[24: "chain tree" should be "shared tree".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/MessageRoot.sol#L24)</u>


<mark>`FullMerkle.sol`</mark> <mark>:</mark>


   - Line <u>[23: "Bytes32Pushtree" should be "FullTree".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/common/libraries/FullMerkle.sol#L23)</u>

   - Line <u>[26: the function does not "reset the tree from blank state" as it merely pushes](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/common/libraries/FullMerkle.sol#L26)</u>

another zero to the existing tree.


<mark>`BridgeHelper.sol`</mark> <mark>:</mark>


   - Line <u>[14: the library not only works with L2 contracts on L1 but also with](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/BridgeHelper.sol#L14)</u> <u>[native tokens](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L279)</u> on

both L1 and L2.


ZKsync: ZKChain and Gateway Upgrade Audit − Low Severity − 20


Consider providing clear documentation within the codebase for enhanced readability and

maintainability.


**_Update:_** _Resolved in_ _<u>[pull request #908.](https://github.com/matter-labs/era-contracts/pull/908)</u>_

### **L-07 The onlyAssetRouterCounterpartOrSelf** **Modifier Allows Chain IDs Other Than** **`L1_CHAIN_ID`**


The <u><mark>`[onlyAssetRouterCounterpartOrSelf](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L51)`</mark></u> modifier checks whether the caller is the

counterpart (i.e. <mark>`l1AssetRouter`</mark> address) or self only when the chain ID i <mark>s</mark> <mark>`L1_CHAIN_ID`</mark> <mark>.</mark>

Since only L2 to L1 communication is supported at the moment, this modifier functions

correctly. However, it will not perform the check correctly if other non-L1 chain IDs are

activated in the future.


To prevent potential future misuse, consider explicitly handling other chain IDs in this modifier.


**_Update:_** _Resolved in_ _<u>[pull request #909.](https://github.com/matter-labs/era-contracts/pull/909)</u>_

### **L-08 Indirect BridgeHub Calls Via** **`ChainTypeManager`**


The <u><mark>`[chainTypeManager](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L44)`</mark></u> variable in <mark>`ValidatorTimelock`</mark> can be replaced by

<mark>`Bridgehub`</mark> as it is only used to get the <u>[chain admin](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L66)</u> or <u>[chain address](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L186)</u> indirectly from the

<mark>`Bridgehub`</mark> since these calls route to <mark>`Bridgehub`</mark> via the <u><mark>`[getZKChain](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L101)`</mark></u> function.


To avoid unnecessary complexity, consider using <mark>`Bridgehub`</mark> directly.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_Due to the upgrade process, we need the_ _<mark>`ValidatorTimelock`</mark>_ _contract to work_

_even before_ _<mark>`Bridgehub`</mark>_ _is upgraded. This means that we should call the_

_<mark>`getZKChain`</mark>_ _function on the CTM, as it works before and after the upgrade._

### **L-09 Unconventional Proof Length**


To prove that a leaf belongs to a Merkle Tree, usually, a proof of length equal to the height of

the tree is needed to reconstruct the tree root. This is <u>[noted](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/common/libraries/Merkle.sol#L41)</u> in the <mark>`Merkle.sol`</mark> library.


ZKsync: ZKChain and Gateway Upgrade Audit − Low Severity − 21


However, in order to prove the leaf inclusion of an L2 message, the <u><mark>`[logLeafProofLen](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L220C49-L220C64)`</mark></u> is not

the tree height, but is the tree height + 1. This is because <u>[the aggregated root hash](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/system-contracts/contracts/L1Messenger.sol#L309)</u> needs to be

provided additionally at the end in order to hash to the stored <u><mark>`[s.l2LogsRootHashes](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L393)`</mark></u> value.

Similarly, the <u><mark>`[batchLeafProofLen](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L248)`</mark></u> needs to be the chainId's tree height + 1 for settlements

done on the Gateway. This discrepancy on the proof aggregation mechanism can be remarked

upon for clarity.


Consider adding more docstrings pertaining to the <u><mark>`[_proof](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L207)`</mark></u> content and explicitly note the

proof length and the discrency from the <mark>`Merkle.sol`</mark> library's advice note.


**_Update:_** _Resolved in_ _<u>[pull request #910.](https://github.com/matter-labs/era-contracts/pull/910)</u>_

## **Notes & Additional** **Information**

### **N-01 Todo Comments in the Code**


During development, having well-described TODO/Fixme comments makes the process of

tracking and solving them easier. However, if left unattended, these comments might age and

important information for the security of the system might be forgotten by the time it is

released to production. As such, all TODO/Fixme comments should be tracked in the project's

issue backlog and resolved before the system is deployed.


Throughout the codebase, multiple instances of unaddressed TODO/Fixme comments were

identified:


   - The <mark>`Todo`</mark> comment in <u>line 39 of</u> <u><mark>`[IAssetRouterBase.sol](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/IAssetRouterBase.sol#L39)`</mark></u>

   - The <mark>`ToDo`</mark> comment in <u>line 112 of</u> <u><mark>`[AssetRouterBase.sol](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L112)`</mark></u>


Consider removing all instances of TODO/Fixme comments and instead tracking them in the

issues backlog. Alternatively, consider linking each inline TODO/Fixme to the corresponding

issues backlog entry.


**_Update:_** _Resolved in_ _<u>[pull request #911.](https://github.com/matter-labs/era-contracts/pull/911)</u>_


ZKsync: ZKChain and Gateway Upgrade Audit − Notes & Additional

Information − 22


### **N-02 Typographical Errors**

Throughout the codebase, multiple instances of typographical errors were identified.




- <mark>`DataEncoding.sol`</mark> <mark>,</mark> <u>[lines 74-75:](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/common/libraries/DataEncoding.sol#L74-L75)</u> <mark>`_tokenAaddress`</mark> should be <mark>`_tokenAddress`</mark> .

- <mark>`L1AssetRouter.sol`</mark> <mark>,</mark> <u>[line 113: the comment has been mistakenly copied from](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L113)</u> <u>[line](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L124)</u>

<u>[124.](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L124)</u>




- <mark>`IL2AssetRouter.sol`</mark> <mark>,</mark> <u>[line 21: "assedAddress" should be "assetHandlerAddress".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/IL2AssetRouter.sol#L21)</u>

- <mark>`IL1DAValidator.sol`</mark> <mark>,</mark> <u>[line 26:](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-interfaces/IL1DAValidator.sol#L26)</u> <mark>`_chainId`</mark> should be <mark>`_batchNumber`</mark> <mark>.</mark>

- <mark>`CalldataDAGateway.sol`</mark> <mark>,</mark> <u>[line 9: "process" should be "processing".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/data-availability/CalldataDAGateway.sol#L9)</u>

- <mark>`PriorityTree.sol`</mark> <mark>,</mark> lines <u>[30](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/libraries/PriorityTree.sol#L30)</u> and <u>[41: "queue" should be "tree".](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/libraries/PriorityTree.sol#L41)</u>



Consider fixing the aforementioned typographical errors to improve the clarity and readability

of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #912. All instances of typographical errors have been fixed.](https://github.com/matter-labs/era-contracts/pull/912)</u>_

### **N-03 Multiple Contracts With the Same Name**


Throughout the codebase, multiple instances of contracts and interfaces with identical names

were identified:


   - The <u><mark>`[CalldataDA](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/da-contracts/contracts/CalldataDA.sol)`</mark></u> <u>contract</u> in <mark>`da-contracts/contracts`</mark>

   - The <u><mark>`[CalldataDA](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/data-availability/CalldataDA.sol)`</mark></u> <u>contract</u> in <mark>`l1-contracts/contracts/state-transition/`</mark>
```
   data-availability
```

   - The <u><mark>`[IBridgehub](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/system-contracts/contracts/interfaces/IBridgehub.sol)`</mark></u> <u>interface</u> in <mark>`system-contracts/contracts/interfaces`</mark>

   - The <u><mark>`[IBridgehub](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/IBridgehub.sol)`</mark></u> <u>interface</u> in <mark>`l1-contracts/contracts/bridgehub`</mark>

   - The <u><mark>`[IL1DAValidator](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/da-contracts/contracts/IL1DAValidator.sol)`</mark></u> <u>interface</u> in <mark>`da-contracts/contracts`</mark>

   - The <u><mark>`[IL1DAValidator](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-interfaces/IL1DAValidator.sol)`</mark></u> <u>interface</u> in <mark>`l1-contracts/contracts/state-`</mark>
```
   transition/chain-interfaces
```

   - The <u><mark>`[IL2DAValidator](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l2-contracts/contracts/interfaces/IL2DAValidator.sol)`</mark></u> <u>interface</u> in <mark>`l2-contracts/contracts/interfaces`</mark>

   - The <u><mark>`[IL2DAValidator](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/system-contracts/contracts/interfaces/IL2DAValidator.sol)`</mark></u> <u>interface</u> in <mark>`system-contracts/contracts/interfaces`</mark>

   - The <u><mark>`[IL2GenesisUpgrade](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/system-contracts/contracts/interfaces/IL2GenesisUpgrade.sol)`</mark></u> <u>interface</u> in <mark>`system-contracts/contracts/`</mark>
```
   interfaces
```

   - The <u><mark>`[IL2GenesisUpgrade](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/l2-deps/IL2GenesisUpgrade.sol)`</mark></u> <u>interface</u> in <mark>`l1-contracts/contracts/state-`</mark>
```
   transition/l2-deps
```

   - The <u><mark>`[IVerifier](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-interfaces/IVerifier.sol)`</mark></u> <u>interface</u> in <mark>`l1-contracts/contracts/state-transition/`</mark>
```
   chain-interfaces
```

   - The <u><mark>`[IVerifier](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l2-contracts/contracts/verifier/chain-interfaces/IVerifier.sol)`</mark></u> <u>interface</u> in <mark>`l2-contracts/contracts/verifier/chain-`</mark>
```
   interfaces

```

ZKsync: ZKChain and Gateway Upgrade Audit − Notes & Additional

Information − 23


Consider naming all contracts uniquely to avoid unexpected behavior and improve the overall

clarity and readability of the codebase.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_This is unfortunately the case due to compilation issues. We use two separate_

_compilers, one for EVM the other for zkEVM i.e. EraVM. Some contracts can only be_

_compiled with one of the compilers. Some other contracts are deployed on L1, some on_

_L2, some on both (i.e. Bridgehub). These interfaces/contracts share names because_

_they are the same, they are just in different locations due to these complications._

### **N-04 Duplicated Code**


In the <mark>`L1Nullifier`</mark> contract, the <mark>`nullifyChainBalanceByNTV`</mark> function only allows calls

made <u>by the</u> <u><mark>`[L1NativeTokenVault](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L208)`</mark></u> contract. However, the <u><mark>`[onlyL1NTV](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L118)`</mark></u> modifier is already

supposed to handle this kind of access control.


Consider decorating the <mark>`nullifyChainBalanceByNTV`</mark> function with the <mark>`onlyL1NTV`</mark>

modifier to avoid code duplication.


**_Update:_** _Resolved in_ _<u>[pull request #913.](https://github.com/matter-labs/era-contracts/pull/913)</u>_

### **N-05 Variables Could Be immutable**


If a variable is only ever assigned a value from within the <mark>`constructor`</mark> of a contract or

during compile time, then it could be declared as <mark>`immutable`</mark> <mark>.</mark>


Throughout the codebase, multiple instances of variables that could be <mark>`immutable`</mark> were

identified:


   - The <u><mark>`[l1AssetRouter](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L35)`</mark></u> <u>state variable</u> in <mark>`L2AssetRouter.sol`</mark>

   - The <u><mark>`[l2TokenProxyBytecodeHash](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/ntv/L2NativeTokenVault.sol#L37)`</mark></u> <u>state variable</u> in <mark>`L2NativeTokenVault.sol`</mark>


To better convey the intended use of variables and to potentially save gas, consider adding the

<mark>`immutable`</mark> keyword to variables that are only set in the constructor.


**_Update:_** _Resolved in_ _<u>[pull request #914. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/914)</u>_


_On L2, immutables are more expensive at the moment, but were added for readability._


ZKsync: ZKChain and Gateway Upgrade Audit − Notes & Additional

Information − 24


### **N-06 Unused Error**

Unused code can reduce code clarity and make it difficult to reason about the implemented

logic. In <mark>`DAContractsErrors.sol`</mark> <mark>,</mark> the <u><mark>`[PubdataCommitmentsTooBig](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/da-contracts/contracts/DAContractsErrors.sol#L7)`</mark></u> <u>error</u> is unused.


To improve the overall clarity and readability of the codebase, consider either using or

removing any currently unused errors.


**_Update:_** _Resolved in_ _<u>[pull request #915. All unused errors have been removed.](https://github.com/matter-labs/era-contracts/pull/915)</u>_

### **N-07 Duplicate Imports**


Throughout the codebase, multiple instances of duplicate imports were identified:




- <u><mark>`[import {MigrationPaused, AssetIdAlreadyRegistered,](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L26)`</mark></u>
```
 ChainAlreadyLive, ChainNotLegacy, CTMNotRegistered,
 ChainIdNotRegistered, AssetHandlerNotRegistered,
 ZKChainLimitReached, CTMAlreadyRegistered, CTMNotRegistered,
 ZeroChainId, ChainIdTooBig, BridgeHubAlreadyRegistered,
 AddressTooLow, MsgValueMismatch, ZeroAddress, Unauthorized,
 SharedBridgeNotSet, WrongMagicValue, ChainIdAlreadyExists,
 ChainIdMismatch, ChainIdCantBeCurrentChain, EmptyAssetId,
 AssetIdNotSupported, IncorrectBridgeHubAddress} from "../common/
```

<u><mark>`[L1ContractErrors.sol";](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridgehub/Bridgehub.sol#L26)`</mark></u> imports duplicated alias <mark>`CTMNotRegistered`</mark> in

<mark>`Bridgehub.sol`</mark> <mark>.</mark>




- <u><mark>`[import {DataEncoding} from "../common/libraries/](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L33)`</mark></u>

<u><mark>`[DataEncoding.sol";](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L33)`</mark></u> is duplicated in <mark>`L1Nullifier.sol`</mark> <mark>.</mark>




- <u><mark>`[import {Unauthorized, SharedBridgeKey, DepositExists,](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L34)`</mark></u>


```
 AddressAlreadySet, InvalidProof, DepositDoesNotExist,
 SharedBridgeValueNotSet, WithdrawalAlreadyFinalized,
 L2WithdrawalMessageWrongLength, InvalidSelector,
 SharedBridgeValueNotSet, ZeroAddress} from "../common/
```

<u><mark>`[L1ContractErrors.sol";](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/bridge/L1Nullifier.sol#L34)`</mark></u> imports duplicated alias <mark>`SharedBridgeValueNotSet`</mark>

in <mark>`L1Nullifier.sol`</mark> <mark>.</mark>

- <u><mark>`[import {IChainTypeManager} from "../../IChainTypeManager.sol";](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L10)`</mark></u> is

duplicated in <mark>`Mailbox.sol`</mark> <mark>.</mark>




- <u><mark>`[import {IBridgehub} from "../../../bridgehub/IBridgehub.sol";](https://github.com/matter-labs/era-contracts/blob/ef318e21bc38841d3905b090bc558662b57eacab/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L11)`</mark></u> is

duplicated in <mark>`Mailbox.sol`</mark> <mark>.</mark>


ZKsync: ZKChain and Gateway Upgrade Audit − Notes & Additional

Information − 25


Consider removing duplicate imports to improve the overall clarity and readability of the

codebase.


**_Update:_** _Resolved in_ _<u>[pull request #916. All duplicate imports have been removed.](https://github.com/matter-labs/era-contracts/pull/916)</u>_


ZKsync: ZKChain and Gateway Upgrade Audit − Notes & Additional

Information − 26


## **Conclusion**

The audited codebase updates key bridging functionalities with added access control for multi
layer deployment. Within this asset bridging framework, ZKChain migration between L1 and

Gateway is supported and settlement on Gateway is considered. Given the complexity and the

backward compatibility requirement, we recommend more integration tests covering chain

migration from L1 to Gateway and back to L1 to further improve the robustness of the

mechanism. We deeply appreciate the Matter Labs team for their generous support throughout

the audit which greatly aided our understanding of the system.


ZKsync: ZKChain and Gateway Upgrade Audit − Conclusion − 27


