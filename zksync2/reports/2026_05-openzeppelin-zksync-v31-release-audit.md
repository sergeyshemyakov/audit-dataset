### | security

# **v.31 Interop Audit**

#### **May 15, 2026**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview ________________________________________________________________ 10

Interoperability Updates 10

Settlement and Migration Changes 11

Base Token Architecture Changes 11

Asset chainBalance Migration 11


Security Model and Trust Assumptions _____________________________________________ 12


Notes on the Test Suite ___________________________________________________________ 14

Considerations on Compromised Chains and Malicious Settlement Layers 14

Isolation vs Propagation of Failures 15

Cross-Chain Liveness Considerations 16


Medium Severity _________________________________________________________________ 18

M-01 Missing Pause Enforcement in L2AssetRouter.bridgehubDepositBaseToken 18


Low Severity ____________________________________________________________________ 18

L-01 Incorrect Length Validation in ERC-7930 Address Parsing 18

L-02 Missing Early Validation of ERC-7930 Bundle Addresses 19

L-03 Missing Validation of interopCallValue in Indirect Calls 20

L-04 Potential Double Accounting in Base Token Bridging Flow 21

L-05 Missing Timestamp Consistency Check in Committer.verifyBatchTimestamp 21

L-06 Overly Broad Access Control Permissions Across Multiple Contracts 22

L-07 Missing Input Validation 23

L-08 Asymmetric Base Token Supply Cap Between ZKOS and Non-ZKOS Chains 24


Notes & Additional Information ____________________________________________________ 25

N-01 Redundant Branching in InteropCenter._ensureCorrectTotalValue 25

N-02 Inconsistencies in Fee Price Adjustment Logic 26

N-03 InteropHandler Does Not Explicitly Inherit IERC7786Recipient 27

N-04 Missing Revert on Invalid BUNDLE_IDENTIFIER in Interop Message Handling 27

N-05 Ambiguous Accounting for Base Tokens in Asset Trackers 28

N-06 Inconsistent Restoration of pausedDepositsTimestamp Across Migration Flows 28

N-07 Missing Deposit Pause Validation on Receiving Settlement Layer 29

N-08 Hardcoded originChainId in Base Token Finalization May Be Misleading 30

N-09 Naming Inconsistencies 30


v.31 Interop Audit − Table of Contents − 2


N-10 Redundant Code and Minor Structural Improvements 31

N-11 Typographical Errors 32

N-12 Redundant Logic and Minor Code Simplifications 32

N-13 Misleading or Incomplete Comments 33

N-14 Missing Deadline Initialization Check in GovernanceUpgradeTimer 34

N-15 Unused Code 34


Client Reported __________________________________________________________________ 35

CR-01 Interop Bundles Can Be Claimed On Chains Settling On L1 35

CR-02 ProtocolUpgradeHandler cannot freeze chains under the ZKOS ChainTypeManager 36


Conclusion ______________________________________________________________________ 37


Appendix _______________________________________________________________________ 38

Issue Classification 38


v.31 Interop Audit − Table of Contents − 3


## **Summary**

**Type** L2, Interoperability


**Timeline** From 2026-03-26
To 2026-05-05


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



**Total Issues** 26 (24 resolved)



**Low Severity Issues** 8 (8 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



15 (13 resolved)


2 (2 resolved)


v.31 Interop Audit − Summary − 4


## **Scope**

OpenZeppelin performed a diff audit of the "matter-labs/era-contracts" repository with base

commit <u><mark>`[babbed5](https://github.com/matter-labs/era-contracts/commit/babbed59718a62198902c3f26456228bcb7ed1fa)`</mark></u> and head commit <u><mark>`[4271d0a](https://github.com/matter-labs/era-contracts/tree/4271d0a37d64c43697781fa272d53e6b9c9f401c)`</mark></u> <mark>.</mark>


In scope were the following files:

```
contracts
├── da-contracts/contracts
│  ├── BlobsL1DAValidatorZKsyncOS.sol
│  ├── CalldataDA.sol
│  ├── DAContractsErrors.sol
│  ├── EIP7702Checker.sol
│  ├── IEIP7702Checker.sol
│  └── RollupL1DAValidator.sol
├── l1-contracts/contracts
│  ├── bridge
│  │  ├── BridgeHelper.sol
│  │  ├── BridgedStandardERC20.sol
│  │  ├── L1BridgeContractErrors.sol
│  │  ├── L1ERC20Bridge.sol
│  │  ├── L1Nullifier.sol
│  │  ├── L2SharedBridgeLegacy.sol
│  │  ├── L2WrappedBaseToken.sol
│  │  ├── L2WrappedBaseTokenStore.sol
│  │  ├── UpgradeableBeaconDeployer.sol
│  │  ├── asset-router
│  │  │  ├── AssetRouterBase.sol
│  │  │  ├── IAssetRouterBase.sol
│  │  │  ├── IAssetRouterShared.sol
│  │  │  ├── IL1AssetRouter.sol
│  │  │  ├── IL2AssetRouter.sol
│  │  │  ├── L1AssetRouter.sol
│  │  │  └── L2AssetRouter.sol
│  │  ├── asset-tracker
│  │  │  ├── AssetTrackerBase.sol
│  │  │  ├── AssetTrackerErrors.sol
│  │  │  ├── GWAssetTracker.sol
│  │  │  ├── IAssetTrackerBase.sol
│  │  │  ├── IAssetTrackerDataEncoding.sol
│  │  │  ├── IGWAssetTracker.sol
│  │  │  ├── IL1AssetTracker.sol
│  │  │  ├── IL2AssetTracker.sol
│  │  │  ├── L1AssetTracker.sol
│  │  │  ├── L2AssetTracker.sol
│  │  │  └── LegacySharedBridgeAddresses.sol
│  │  ├── interfaces
│  │  │  ├── IL1AssetHandler.sol
│  │  │  ├── IL1CrossChainSender.sol

```

v.31 Interop Audit − Scope − 5


```
│  │  │  ├── IL1ERC20Bridge.sol
│  │  │  ├── IL1Nullifier.sol
│  │  │  ├── IL2CrossChainSender.sol
│  │  │  └── IL2WrappedBaseToken.sol
│  │  └── ntv
│  │    ├── IL1NativeTokenVault.sol
│  │    ├── IL2NativeTokenVault.sol
│  │    ├── INativeTokenVaultBase.sol
│  │    ├── L1NativeTokenVault.sol
│  │    ├── L2NativeTokenVault.sol
│  │    ├── L2NativeTokenVaultZKOS.sol
│  │    └── NativeTokenVaultBase.sol
│  ├── common
│  │  ├── Config.sol
│  │  ├── L1ContractErrors.sol
│  │  ├── MessageVerification.sol
│  │  ├── Messaging.sol
│  │  ├── interfaces
│  │  │  ├── IAccountCodeStorage.sol
│  │  │  ├── IL2ContractDeployer.sol
│  │  │  ├── IMessageVerification.sol
│  │  │  └── ISystemContext.sol
│  │  ├── l2-helpers
│  │  │  ├── IBaseToken.sol
│  │  │  ├── IL2ToL1Messenger.sol
│  │  │  ├── IL2ToL1MessengerEra.sol
│  │  │  ├── L2ContractAddresses.sol
│  │  │  ├── L2ContractHelper.sol
│  │  │  ├── L2ContractInterfaces.sol
│  │  │  └── SystemContractsCaller.sol
│  │  └── libraries
│  │    ├── DataEncoding.sol
│  │    ├── DynamicIncrementalMerkle.sol
│  │    ├── DynamicIncrementalMerkleMemory.sol
│  │    ├── FullMerkle.sol
│  │    ├── FullMerkleMemory.sol
│  │    ├── Merkle.sol
│  │    ├── MessageHashing.sol
│  │    ├── TransientPrimitives.sol
│  │    └── ZKSyncOSBytecodeInfo.sol
│  ├── core
│  │  ├── bridgehub
│  │  │  ├── BridgehubBase.sol
│  │  │  ├── IBridgehubBase.sol
│  │  │  ├── IL1Bridgehub.sol
│  │  │  ├── IL2Bridgehub.sol
│  │  │  ├── L1Bridgehub.sol
│  │  │  ├── L1BridgehubErrors.sol
│  │  │  └── L2Bridgehub.sol
│  │  ├── chain-asset-handler
│  │  │  ├── ChainAssetHandlerBase.sol
│  │  │  ├── IChainAssetHandler.sol
│  │  │  ├── IChainAssetHandlerShared.sol
│  │  │  ├── IL1ChainAssetHandler.sol
│  │  │  ├── IL2ChainAssetHandler.sol
│  │  │  ├── L1ChainAssetHandler.sol

```


v.31 Interop Audit − Scope − 6


```
│  │  │  └── L2ChainAssetHandler.sol
│  │  ├── chain-registration
│  │  │  ├── ChainRegistrationSender.sol
│  │  │  └── IChainRegistrationSender.sol
│  │  ├── ctm-deployment
│  │  │  ├── CTMDeploymentTracker.sol
│  │  │  └── ICTMDeploymentTracker.sol
│  │  └── message-root
│  │    ├── IL1MessageRoot.sol
│  │    ├── IMessageRoot.sol
│  │    ├── L1MessageRoot.sol
│  │    ├── L2MessageRoot.sol
│  │    └── MessageRootBase.sol
│  ├── governance
│  │  ├── ChainAdmin.sol
│  │  ├── Governance.sol
│  │  ├── IServerNotifier.sol
│  │  └── PermanentRestriction.sol
│  ├── interop
│  │  ├── AttributesDecoder.sol
│  │  ├── IERC7786Attributes.sol
│  │  ├── IERC7786GatewaySource.sol
│  │  ├── IERC7786Recipient.sol
│  │  ├── IInteropCenter.sol
│  │  ├── IInteropHandler.sol
│  │  ├── IL2InteropRootStorage.sol
│  │  ├── InteropCenter.sol
│  │  ├── InteropDataEncoding.sol
│  │  ├── InteropErrors.sol
│  │  ├── InteropHandler.sol
│  │  ├── L2InteropRootStorage.sol
│  │  └── L2MessageVerification.sol
│  ├── l2-system
│  │  ├── BaseTokenHolder.sol
│  │  ├── L2BaseTokenBase.sol
│  │  ├── era
│  │  │  ├── L2BaseTokenEra.sol
│  │  │  └── interfaces/IL2BaseTokenEra.sol
│  │  ├── interfaces
│  │  │  ├── IBaseTokenHolder.sol
│  │  │  └── IL2BaseTokenBase.sol
│  │  └── zksync-os
│  │    ├── L1MessageGasLib.sol
│  │    ├── L1MessengerZKOS.sol
│  │    ├── L2BaseTokenZKOS.sol
│  │    ├── SystemContext.sol
│  │    ├── ZKOSContractDeployer.sol
│  │    ├── ZKOSContractHelper.sol
│  │    ├── errors
│  │    │  └── ZKOSContractErrors.sol
│  │    └── interfaces
│  │      ├── IL2BaseTokenZKOS.sol
│  │      └── IZKOSContractDeployer.sol
│  ├── state-transition
│  │  ├── ChainTypeManagerBase.sol
│  │  ├── EraChainTypeManager.sol

```


v.31 Interop Audit − Scope − 7


```
│  │  ├── IChainTypeManager.sol
│  │  ├── L1StateTransitionErrors.sol
│  │  ├── ZKsyncOSChainTypeManager.sol
│  │  ├── chain-deps
│  │  │  ├── DiamondInit.sol
│  │  │  ├── StoredBatchHashing.sol
│  │  │  ├── ZKChainStorage.sol
│  │  │  ├── facets
│  │  │  │  ├── Admin.sol
│  │  │  │  ├── Committer.sol
│  │  │  │  ├── Executor.sol
│  │  │  │  ├── Getters.sol
│  │  │  │  ├── IDiamondCut.sol
│  │  │  │  ├── Mailbox.sol
│  │  │  │  ├── Migrator.sol
│  │  │  │  └── ZKChainBase.sol
│  │  │  └── gateway-ctm-deployer
│  │  │    ├── GatewayCTMDeployer.sol
│  │  │    ├── GatewayCTMDeployerCTM.sol
│  │  │    ├── GatewayCTMDeployerCTMBase.sol
│  │  │    ├── GatewayCTMDeployerCTMZKsyncOS.sol
│  │  │    ├── GatewayCTMDeployerDA.sol
│  │  │    ├── GatewayCTMDeployerProxyAdmin.sol
│  │  │    ├── GatewayCTMDeployerValidatorTimelock.sol
│  │  │    ├── GatewayCTMDeployerVerifiers.sol
│  │  │    └── GatewayCTMDeployerVerifiersZKsyncOS.sol
│  │  ├── chain-interfaces
│  │  ├── data-availability
│  │  ├── l2-deps
│  │  ├── libraries
│  │  └── validators
│  └── transactionFilterer
│    └── GatewayTransactionFilterer.sol
├── l2-contracts/contracts
│  └── ForceDeployUpgrader.sol
└── system-contracts
├── bootloader
│  └── bootloader.yul
└── contracts
├── BootloaderUtilities.sol
├── Compressor.sol
├── Constants.sol
├── ContractDeployer.sol
├── Contracts.sol
├── DefaultAccount.sol
├── L1Messenger.sol
├── SystemContext.sol
├── SystemContractErrors.sol
├── abstract/SystemContractBase.sol
├── interfaces/*
└── libraries/*

```

Subsequently we performed a diff audit of the "matter-labs/era-contracts" repository with base

commit <u><mark>`[babbed5](https://github.com/matter-labs/era-contracts/commit/babbed59718a62198902c3f26456228bcb7ed1fa)`</mark></u> and head commit <u><mark>`[dab8e51](https://github.com/matter-labs/era-contracts/commit/dab8e51e0d7fc35c3abe255ee0b4504a842edcce)`</mark></u> and also reviewed <u>[pull request #2182.](https://github.com/matter-labs/era-contracts/pull/2182)</u>


v.31 Interop Audit − Scope − 8


In scope were the following files:

```
contracts
├── l1-contracts/contracts/l2-upgrades
│  ├── L2ComplexUpgrader.sol
│  ├── L2GenesisForceDeploymentsHelper.sol
│  ├── L2GenesisUpgrade.sol
│  ├── L2V31Upgrade.sol
│  ├── SystemContractProxy.sol
│  ├── SystemContractProxyAdmin.sol
│  └── V31AcrossRecovery.sol
└── l1-contracts/contracts/upgrades
├── BaseZkSyncUpgrade.sol
├── BaseZkSyncUpgradeGenesis.sol
├── BytecodesSupplier.sol
├── EraSettlementLayerV31Upgrade.sol
├── GovernanceUpgradeTimer.sol
├── IL2V31Upgrade.sol
├── L1FixedForceDeploymentsHelper.sol
├── L1GenesisUpgrade.sol
├── L1ZKsyncOSV30Upgrade.sol
├── L2UpgradeTxLib.sol
├── UpgradeStageValidator.sol
├── ZKsyncOSSettlementLayerV31Upgrade.sol
└── ZkSyncUpgradeErrors.sol

```

We also reviewed <u>[pull request #36](https://github.com/zksync-association/zk-governance/pull/36)</u> [and pull request #38](https://github.com/zksync-association/zk-governance/pull/38) of the "zksync-association/zk
governance" repository.


v.31 Interop Audit − Scope − 9


## **System Overview**

In this audit, we reviewed the changes introduced in ZKsync v3.1, which significantly expand

interoperability capabilities, refine settlement-layer migration mechanics, and introduce

structural changes to base token accounting and batch settlement. Notably, these updates

enable permissionless execution of L1 -> L2 transactions, allowing ZKsync chains to achieve

Stage 1 L2 status. While these improvements increase protocol flexibility and decentralization,

they also introduce additional complexity in cross-chain execution and migration flows.

### **Interoperability Updates**


The <mark>`InteropCenter`</mark> contract now holds funds collected as interop call fees, which can be

claimed through a dedicated function by the coinbase address. This introduces a new balance
holding component within the interoperability layer.


Interop call recipients must implement a receiveMessage function and conform to the

<mark>`IERC7786Recipient`</mark> interface. Currently:








L2AssetRouter implements receiveMessage and receives interop calls for finalizeDeposit

InteropHandler also implements receiveMessage, but only for bundle-related operations

(unbundling, verification, execution)



Failed interop call refunds are not supported. Unlike failed L1 -> L2 transactions, which can be

proven and refunded, failed interop calls result in funds remaining locked on the sending chain,

where they are accounted for in the pendingChainBalance of the destination chain. This

introduces new considerations around liveness and operational recovery.


The <mark>`InteropHandler`</mark> has also been extended with a new <u><mark>`[unbundleBundle](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L160-L229)`</mark></u> function.

Compared to <u><mark>`[executeBundle](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L80-L143)`</mark></u> <mark>,</mark> this provides additional flexibility by allowing:









Partial execution of bundle contents

Multiple calls to process the same bundle incrementally

Verification of bundles prior to the first unbundling call


v.31 Interop Audit − System Overview − 10


### **Settlement and Migration Changes**

Two new Diamond Proxy facets were introduced:








<u><mark>`[Committer](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Committer.sol)`</mark></u> <mark>:</mark> Implements the precommit and commit stages of batch settlement

<u><mark>`[Migrator](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol)`</mark></u> : Provides preparation logic for settlement-layer migrations, including

pausing deposits to synchronize priority trees between settlement layers



Regarding chain migrations:










For the v3.1 upgrade, all chains initially settle on L1

After the upgrade, chains may migrate L1 -> Gateway

Chains may optionally migrate Gateway -> L1

After returning to L1, no further migrations are allowed



Limiting migrations to two rounds reduces the complexity of chain and asset balance migration

logic and simplifies reasoning about security guarantees.


Before migration, deposits on both settlement layers must be paused to synchronize their

priority operation trees. A subtle detail is that during L1 **_→_** Gateway migration, deposits on L1

are not automatically unpaused after a successful migration; <mark>`L1Nullifier`</mark> must be explicitly

called.

### **Base Token Architecture Changes**


The base token architecture has been refactored into:









<u><mark>`[BaseTokenHolder](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/BaseTokenHolder.sol)`</mark></u> <mark>:</mark> Holds base token liquidity used for cross-chain transactions

<u><mark>`[L2BaseTokenBase](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/L2BaseTokenBase.sol)`</mark></u> <mark>:</mark> Base token logic

<u><mark>`[L2BaseTokenEra](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/era/L2BaseTokenEra.sol)`</mark></u> <mark>:</mark> ZKsyncEra-specific base token implementation



Cross-chain minting behavior now differs depending on transaction type:








Interop transactions: <u><mark>`[BaseTokenHolder::give](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/BaseTokenHolder.sol#L106-L116)`</mark></u> is called by <mark>`InteropHandler`</mark>

L1 -> L2 transactions: <u><mark>`[L2BaseTokenEra::mint](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/era/L2BaseTokenEra.sol#L86-L97)`</mark></u> is called by the <mark>`bootloader`</mark>


### **Asset chainBalance Migration**

Asset <mark>`chainBalance`</mark> migration is now performed lazily rather than automatically.


v.31 Interop Audit − System Overview − 11


When a chain migrates to a new settlement layer:










Asset balances are not immediately migrated

The first interop or withdrawal transaction for an unmigrated asset will underflow and

revert

These reverting transactions signal that a chainBalance migration should be triggered

manually



If an asset receives funds through interop or L1 deposits before migration, its chainBalance

increases normally even if migration has not yet occurred.

## **Security Model and Trust** **Assumptions**


The system and its configuration are complex, involving the setting and updating of critical

parameters and, in certain cases, temporarily pausing parts of the protocol’s functionality.

While this upgrade enables ZKChains to activate the priority mode feature ( allowing users to

manually execute L1 -> L2 transactions ) and thereby represents a significant step toward

further decentralization, several privileged roles remain.


These roles, typically designated as owner, admin, or upgrader, and which are expected to

differ across chains and contracts, retain the ability to modify configuration parameters, pause

components, or otherwise affect core protocol behavior. They are also responsible for

executing proper operational procedures during events such as upgrades, migrations, and

emergency interventions.


As such, these roles were considered trusted entities within the scope of this audit. The

security and correct functioning of the system therefore depend, to some extent, on the proper,

timely, and honest operation of these privileged actors.


Below, we outline the actions expected to be executed correctly, which fall under these

security assumptions:







Across multiple contracts, the owner or admin roles have the ability to pause protocol

functionality and are expected to do so under specific operational circumstances:


  - The owner of a chain’s Diamond Proxy has the ability, and is expected, to pause

<u>[deposits](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol#L101)</u> before a settlement layer migration begins. A delay window exists


v.31 Interop Audit − Security Model and Trust Assumptions − 12


between initiating and applying the pause. However, in the current implementation

this delay is hardcoded to zero, resulting in the pause taking effect immediately.


This behavior does not impact chains planning to activate priority mode to achieve Stage

1 status, as pausing deposits for migration is not permitted for such chains.


However, a minor inconsistency may arise. An admin can first pause deposits and

subsequently set the <mark>`canBeActivated`</mark> flag for priority mode. While this does not

introduce a functional issue, since the flag is checked again when the migration actually

begins, preventing migration for chains with priority mode enabled, it may still lead to a

temporary state inconsistency from a view or monitoring perspective.


  - The <mark>`InteropCenter`</mark> [owner can pause](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L692) the sending of interoperability messages

and is expected to do so only when necessary. Even if paused indefinitely, users

may be unable to bridge assets to other chains, but can still withdraw their funds

to L1.


[◦ Owner entity of ChainAssetHandlerBase](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/chain-asset-handler/ChainAssetHandlerBase.sol#L385) has the ability to pause/unpause

migrations as well as the whole functionality of <mark>`ChainAssetHandler`</mark> <mark>.</mark>


  - Similarly, the owner of <mark>`L1Nullifier`</mark> <mark>,</mark> <mark>`AssetRouter`</mark> and <mark>`NativeTokenVault`</mark>

can pause their functionalities


The upgrader is responsible for setting critical system parameters ( primarily addresses

of dependent contracts ) during upgrades and contract reinitialization.


Contract owners are also responsible for setting and updating important parameters,

such as:

[◦ A chain's admin can set and update the fee parameters.](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L172)

  - The <mark>`BridgeHub`</mark> [admin can add or remove](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/bridgehub/L1Bridgehub.sol#L94-L100) chains from the list of whitelisted

settlement layers. Therefore, this role is trusted to whitelist only legitimate chains

that are not known to be compromised. Otherwise, chains that rely on this list

could be put at risk by trusting a malicious settlement layer. At present, however,

only L1 and the Gateway are whitelisted as settlement layers. This role is also

responsible for <u>[registering CTMs.](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/bridgehub/BridgehubBase.sol#L226-L251)</u>

In the L1 -> GW chain migration case, L1 is not automatically informed that the chain

migration has completed on GW. It is trusted that some entity will trigger

<mark>`L1Nullifier.bridgeConfirmTransferResult`</mark> <mark>,</mark> for both failed and successful

migrations, so that the L1 deposits can be unpaused.


v.31 Interop Audit − Security Model and Trust Assumptions − 13


## **Notes on the Test Suite**

The codebase was accompanied by an extensive test suite. One minor observation concerns a

testing pattern that caused some initial confusion. The protocol makes extensive use of cross
chain messages that are encoded on the source chain and decoded on the destination chain.

To quickly verify that encoding and decoding are handled consistently, for example, that both

sides us <mark>e</mark> <mark>`abi.encode/abi.decode`</mark> or <mark>`abi.encodePacked/abi.decodePacked`</mark> rather

than a mismatched pair, we looked to the tests as a reference. However, we observed that in

some cases, such as the <u>[test](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/test/foundry/l1/unit/concrete/Bridge/AssetTracker/GWAssetTracker.t.sol#L265-L276)</u> for <u><mark>`[GWAssetTracker::parseInteropCall](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/GWAssetTracker.sol#L805-L809)`</mark></u> <mark>,</mark> the test

manually constructs the expected encoded data inline rather than calling the actual encoding

function <u><mark>`[AssetRouterBase::getDepositCalldata](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L309)`</mark></u> and ignoring the selector's bytes.

This approach has two drawbacks. First, it is error-prone: a mismatch between the encoding

method used in the test and the one used in production code, for instance, using

<mark>`abi.encodePacked`</mark> on one side and <mark>`abi.decode`</mark> on the other, would go undetected.

Second, by not invoking the canonical encoding function in the decode test, it becomes harder

to trace encode/decode pairs across the codebase and confirm that they are symmetric.

### **Considerations on Compromised Chains and** **Malicious Settlement Layers**


As part of the materials provided to support our understanding of the protocol and its security

assumptions, the Matter Labs team shared research notes titled <u>[“Malicious Settlement Layer](https://www.notion.so/matterlabs/Research-malicious-settlement-layer-SL-2c4a48363f23808aa99ae8490dc12f51)</u>

<u>[(SL)”. These notes outline scenarios in which a ZKChain—whether acting as a settlement layer](https://www.notion.so/matterlabs/Research-malicious-settlement-layer-SL-2c4a48363f23808aa99ae8490dc12f51)</u>

or not—may become compromised, and analyze whether such compromises can affect other

chains in the ecosystem.


This section presents our interpretation of these assumptions and explains how we

incorporated them into our audit methodology. In particular, we describe the analytical model

we used to evaluate whether protocol features and cross-chain flows remain secure under the

presence of compromised chains or malicious settlement layers.


While our analysis did not uncover fundamentally new attack vectors beyond those described

in the provided notes, we identified a potential **cross-chain liveness failure scenario** . This

scenario appears to contradict the claim that a compromised non-settlement-layer chain

cannot affect the liveness of another chain, as it demonstrates conditions under which such an

impact may occur via interoperability mechanisms.


v.31 Interop Audit − Notes on the Test Suite − 14


At a high level, when a settlement layer is compromised, all chains settling on it are inherently

at risk, and mitigation options are limited. However, certain pieces of information propagated

across settlement layers—particularly during migration—can still be independently validated. In

one of our reported findings (see _L-07 Missing Input Validation_ ), we highlight a case where

additional verification could be introduced to improve robustness even under the assumption

of a compromised settlement layer.

### **Isolation vs Propagation of Failures**


The “Malicious Settlement Layer” notes analyze several failure scenarios, including

compromised operators, broken proof systems, malicious Chain Type Managers (CTMs), or

combinations thereof. These scenarios are evaluated based on whether their consequences

remain confined to the compromised chain or propagate to other chains.


The primary impact discussed in the notes is “stealing funds.” However, in the presence of

interoperability, this notion becomes more nuanced. To better reason about cross-chain

effects, we refine this concept and introduce a more general framework for analyzing whether

failures are **isolated** or **propagating** .


Consider two chains, **Chain A** and **Chain B**, both settling on the same settlement layer.

Suppose Chain A is fully compromised, including both its operator and proof system.


In this setting, Chain A can submit an interop message corresponding to a transaction that

never actually occurred. Since the proof system is compromised, this message is accepted as

valid. When processed on Chain B, it results in the minting of bridged tokens without a

corresponding burn on Chain A.


At first glance, this appears to create a cross-chain issue. However, the protocol’s accounting

model—specifically the GWAssetTracker—ensures that global balances remain consistent. The

malicious transaction decreases Chain A’s chainBalance and increases Chain B’s

chainBalance. As a result, Chain A is effectively spending its own balance, and no value is

created at the expense of other chains.


Thus, despite the malicious behavior, the consequences remain confined to Chain A.


To formalize this reasoning, we introduce the following abstraction:


We conceptually replace the compromised chain with an adversarial entity that can report

arbitrary state transitions to the settlement layer. This entity does not violate protocol rules

visible to other chains—it simply exercises its authority to declare state changes.


v.31 Interop Audit − Notes on the Test Suite − 15


We then evaluate whether the observed outcome can be reproduced through _legitimate_

_protocol interactions_ under this model.









If the same outcome can be achieved without violating protocol rules, the failure is

considered **isolated**, as the compromised chain is only exercising authority it effectively

already possesses.

If the outcome cannot be reproduced without violating protocol invariants or impacting

honest chains beyond expected behavior, the failure is considered **propagating**,

indicating a broader protocol-level issue.



This framework provides a principled way to reason about cross-chain security, focusing not

on individual attack scenarios but on whether a compromised chain can exceed its intended

authority.

### **Cross-Chain Liveness Considerations**


While the accounting model ensures isolation of value under compromise, liveness guarantees

may be more subtle.


Consider a scenario where a **non-settlement-layer Chain A** is compromised (including both its

operator and proof system). Under certain conditions, this compromised chain may affect the

liveness of another chain, **Chain B** :








Chain B’s base token is native to Chain A

Both chains share the same settlement layer (e.g., Gateway), enabling interoperability

between them



Under these assumptions, it holds that initially:








<u>[chainBalance[A][BASE] = uint256.max](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/L2AssetTracker.sol#L159)</u>

[on B: balanceOf(BASE_TOKEN_HOLDER)](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/era/L2BaseTokenEra.sol#L40) = <u>[INITIAL_BASE_TOKEN_HOLDER_BALANCE](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/common/Config.sol#L266)</u>

= <mark>`(2 ** 127 - 1) < uint256.max`</mark>



The detailed attack scenario is described as follows:



1.


2.


3.



Chain A submits a (fake) A->B interop TX transferring a huge BASE amount which would

drain chain B's <mark>`BaseTokenHolder`</mark> balance.

Since the proof system is compromised, A's batch containing the interop TX settles

successfully on GW, updating <mark>`sharedTree`</mark> to contain the new <mark>`chainRoot`</mark> of A,

which contains the interop TX. This produces <u>[a new interopRoot.](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/message-root/L2MessageRoot.sol#L105)</u>

B's operator <u>[includes](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/L2InteropRootStorage.sol#L41)</u> the new interopRoot in B's <mark>`L2InteropRootStorage`</mark>


v.31 Interop Audit − Notes on the Test Suite − 16


4.


5.


6.



Subsequently, on B, <mark>`InteropHandler`</mark> successfully <u>[verifies](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L330)</u> the proof of the interop

bundle containing A's interop TX.

<mark>`InteropHandler`</mark> proceeds with executing the TX, <u>minting</u> <u><mark>`[amount](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L296)`</mark></u> [and sending it to](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L299)

<u>[the recipient's address.](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L299)</u>

After this transfer, the <mark>`BaseTokenHolder`</mark> contract has no BASE balance, so further

[BASE minting on B will fail.](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/era/L2BaseTokenEra.sol#L93)



As a consequence, no more TXs can be processed on B, since the operator's fees <u>[cannot be](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/system-contracts/bootloader/bootloader.yul#L1010)</u>

<u>[minted.](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/system-contracts/bootloader/bootloader.yul#L1010)</u>


v.31 Interop Audit − Notes on the Test Suite − 17


## **Medium Severity**

### **M-01 Missing Pause Enforcement in** **`L2AssetRouter.bridgehubDepositBaseToken`**

The <u><mark>`[L2AssetRouter.bridgehubDepositBaseToken](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L263)`</mark></u> function is not protected by the

<mark>`whenNotPaused`</mark> modifier. Additionally, the internal function it invokes also lacks pause

enforcement.


As a result, cross-chain transaction requests can still be initiated even when the asset router is

in a paused state, bypassing the intended pause mechanism during emergency or

maintenance scenarios.


Consider ensuring that <mark>`bridgehubDepositBaseToken`</mark> is protected by the

<mark>`whenNotPaused`</mark> modifier to enforce consistent pause behavior across the contract.


**_Update:_** _[Resolved in pull request #2141. The team stated:](https://github.com/matter-labs/era-contracts/pull/2141)_


_For interop pausing on L2 is not ideal, since we don’t have access to the L2. Pausing on_

_GW is preferred._

## **Low Severity**

### **L-01 Incorrect Length Validation in ERC-7930** **Address Parsing**


In <mark>`draft-InteroperableAddress.sol`</mark> <mark>,</mark> the <mark>`tryParseV1Calldata`</mark> function is

responsible for validating calldata against the ERC-7930 format. However, toward the end of

[the function, an inequality check is used](https://github.com/matter-labs/era-contracts/blob/b76b8326fb601d22e0ca32d0453d496552bb242f/l1-contracts/contracts/vendor/draft-InteroperableAddress.sol#L111) where a strict equality check would be more

appropriate to enforce the exact expected structure. This may allow malformed inputs to pass

validation.


Additionally, in <mark>`InteropCenter.sol`</mark> <mark>,</mark> both <u><mark>`[_ensureEmptyChainReference](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L313)`</mark></u> and

<u><mark>`[_ensureEmptyAddress](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L326)`</mark></u> include a preliminary check that


v.31 Interop Audit − Medium Severity − 18


<mark>`_interoperableAddress.length >= 5`</mark> <mark>.</mark> [While stricter validation is performed later,](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/vendor/draft-InteroperableAddress.sol#L125)

making this check functionally redundant, it appears intended as an early rejection mechanism.

However, the minimum valid length for ERC-7930 addresses suggests that this condition

should instead be <mark>`_interoperableAddress.length >= 6`</mark> <mark>.</mark>


Consider replacing the inequality check in <mark>`tryParseV1Calldata`</mark> with a strict equality check

where appropriate to enforce correct calldata structure. Additionally, update the early length

checks in <mark>`InteropCenter`</mark> to reflect the correct minimum length, or remove them if they are

redundant with stricter downstream validation.


**_Update:_** _[Resolved in pull request #2142.](https://github.com/matter-labs/era-contracts/pull/2142)_

### **L-02 Missing Early Validation of ERC-7930 Bundle** **Addresses**


The <mark>`execution`</mark> and <mark>`unbundler`</mark> fields of the <u><mark>`[BundleAttributes](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/common/Messaging.sol#L201-L220)`</mark></u> struct are defined as

bytes rather than addresses because, as indicated in the comments, they are expected to

contain ERC-7930 addresses.


However, in <u><mark>`[parseAttributes](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L628-L645)`</mark></u> <mark>,</mark> these fields are <u>[simply decoded as bytes](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/AttributesDecoder.sol#L13-L14)</u> without verifying

that they conform to the expected ERC-7930 address format. The validation of this format is

only performed later in <u><mark>`[InteropHandler](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L168)`</mark></u> <mark>.</mark>


As a result, it is possible to submit a bundle containing invalid execution and unbundler

addresses. These malformed addresses will pass the initial parsing stage but will eventually

cause the bundle execution to fail on the destination chain. Since users are not refunded when

such transactions fail, this can lead to an unnecessary loss of funds and a degraded user

experience.


Consider validating the execution and unbundler fields during attribute parsing, rather than

deferring validation to <mark>`InteropHandler`</mark> <mark>.</mark> Rejecting malformed ERC-7930 addresses as early

as possible will prevent invalid bundles from progressing and avoid unnecessary execution

failures.


**_Update:_** _[Resolved in pull request #2143.](https://github.com/matter-labs/era-contracts/pull/2143)_


v.31 Interop Audit − Low Severity − 19


### **L-03 Missing Validation of interopCallValue in** **Indirect Calls**

Within <mark>`InteropCenter`</mark> <mark>,</mark> it is possible to specify a non-zero <u><mark>`[interopCallValue](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L525C45-L525C89)`</mark></u>

(representing the destination chain’s base token amount) in an indirect call request. However, in

practice, such requests are not supported by the NTV flow and will revert.


This behavior aligns with the intended design, where base token transfers should be performed

via direct calls rather than indirect ones. Despite this, there is no explicit validation in

<mark>`InteropCenter`</mark> enforcing that <mark>`interopCallValue == 0`</mark> for indirect calls.


Additionally, the <u><mark>`[parseAttributes](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L593)`</mark></u> logic does not prevent the simultaneous presence of

both <mark>`interopCallValue`</mark> and <mark>`indirectCallValue`</mark> <mark>,</mark> allowing malformed or unsupported

request configurations to pass initial validation.


A further edge case arises when considering custom <mark>`AssetHandler`</mark> implementations. A

custom handler could potentially process both base and non-base token transfers within a

single indirect call by consuming both <mark>`interopCallValue`</mark> and <mark>`indirectCallValue`</mark> <mark>.</mark> In

such a scenario, <mark>`interopCallValue`</mark> may be accounted for twice: once within the custom

handler logic (e.g., burn/lock) and again within <mark>`InteropCenter`</mark> via

<u><mark>`[totalBurnedCallsValue](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L441)`</mark></u> and <mark>`_ensureCorrectTotalValue`</mark> <mark>,</mark> leading to inconsistent

accounting.


No immediate impact is identified in the current implementation. However, the lack of explicit

validation introduces ambiguity, increases the risk of misconfiguration, and may lead to

incorrect accounting or double-counting in custom integrations.


Consider explicitly enforcing that <mark>`interopCallValue == 0`</mark> for indirect calls at the

validation layer. Additionally, ensure that mutually incompatible attributes (such as

<mark>`interopCallValue`</mark> and <mark>`indirectCallValue`</mark> <mark>)</mark> cannot coexist in the same request.


**_Update:_** _[Resolved in pull request #2144. The team stated:](https://github.com/matter-labs/era-contracts/pull/2144)_


_This issue is invalid as stated. InteropCenter intentionally supports generic indirect

calls, including carrying source-chain msg.value into_


_initiateIndirectCall and specifying destination-side base-token value via

interopCallValue. The limitation is only in the current standard bridge_


_implementation: L2AssetRouter/L2NativeTokenVault do not support non-zero

destination msg.value in that indirect flow. So this is not a protocol-level_


v.31 Interop Audit − Low Severity − 20


_bug in InteropCenter, but at most an implementation-specific limitation of the current_

_default IL2CrossChainSender path._

### **L-04 Potential Double Accounting in Base Token** **Bridging Flow**


In the <mark>`L2NativeTokenVault`</mark> contract, the <u><mark>`[_getTokenAndBridgeToChain](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/ntv/NativeTokenVaultBase.sol#L450-L485)`</mark></u> function

(inherited from <mark>`NativeTokenVaultBase`</mark> <mark>)</mark> first calls <u><mark>`[_handleBridgeToChain](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/ntv/NativeTokenVaultBase.sol#L461)`</mark></u> <mark>.</mark> This

function subsequently invokes <u><mark>`[L2AssetTracker::handleInitiateBridgingOnL2](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/L2AssetTracker.sol#L216-L223)`</mark></u> <mark>,</mark>

which decreases <mark>`chainBalance`</mark> and updates <mark>`interopInfo.totalWithdrawalsToL1`</mark> <mark>,</mark>

depending on the asset’s origin and the L2 settlement layer.


Returning to <mark>`_getTokenAndBridgeToChain`</mark> <mark>,</mark> in the scenario where the token is the base

token of the L2 and is bridged (i.e., not originating on the L2), execution reaches a branch

where <u><mark>`[BaseTokenHolder::burnAndStartBridging](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/ntv/NativeTokenVaultBase.sol#L463-L468)`</mark></u> is called. This function, in turn, calls

<u><mark>`[L2AssetTracker::handleInitiateBaseTokenBridgingOnL2](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/L2AssetTracker.sol#L267-L271)`</mark></u> <mark>,</mark> which risks performing

duplicate state updates to <mark>`interopInfo.totalWithdrawalsToL1`</mark> <mark>,</mark> since both

<mark>`handleInitiateBridgingOnL2`</mark> and <mark>`handleInitiateBaseTokenBridgingOnL2`</mark> make

the exact same call to <mark>`_handleInitiateBridgingOnL2Inner`</mark> <mark>.</mark>


Although this scenario does not currently occur in practice, since base token withdrawals do

not follow the <mark>`NativeTokenVault`</mark> flow, the design remains error-prone and could introduce

bugs in future logic updates or refactors.


To reduce this risk, consider avoiding the second call to

<mark>`handleInitiateBaseTokenBridgingOnL2`</mark> <mark>,</mark> ensuring that accounting updates occur only

once and preventing potential double-counting issues.


**_Update:_** _[Resolved in pull request #2163.](https://github.com/matter-labs/era-contracts/pull/2163)_

### **L-05 Missing Timestamp Consistency Check in** **`Committer.verifyBatchTimestamp`**


In the <u><mark>`[verifyBatchTimestamp](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Committer.sol#L568-L598)`</mark></u> function of the <mark>`Committer`</mark> facet, a <u>[comment](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Committer.sol#L586)</u> states that all

L2 blocks within a batch must have timestamps in the range <mark>`[batchTimestamp,`</mark>

<mark>`l2LastBlockTimestamp]`</mark> <mark>.</mark>


In particular, this implicitly requires that <mark>`batchTimestamp ≤ l2LastBlockTimestamp`</mark> <mark>.</mark>

However, this relationship is not explicitly validated in the current implementation. A batch


v.31 Interop Audit − Low Severity − 21


whose timestamps violate this constraint should never be accepted, as it represents a

malformed batch. The absence of this check also weakens the intended freshness guarantees.

Currently, the function verifies that:









<mark>`l2LastBlockTimestamp`</mark> is not too large, and


<mark>`batchTimestamp`</mark> is not too small



Given the expected ordering <mark>(</mark> <mark>`batchTimestamp ≤ l2LastBlockTimestamp`</mark> <mark>)</mark>, these

checks implicitly provide additional bounds in the opposite direction. Without explicitly

enforcing this relationship, however, malformed batches with inconsistent timestamps may still

pass validation.


Consider explicitly verifying that <mark>`batchTimestamp ≤ l2LastBlockTimestamp`</mark> <mark>.</mark> This

simple check would strengthen the validation logic and prevent malformed batches from being

accepted.


**_Update:_** _[Resolved in pull request #2147.](https://github.com/matter-labs/era-contracts/pull/2147)_

### **L-06 Overly Broad Access Control Permissions** **Across Multiple Contracts**


Several functions across the codebase implement access control checks that are broader than

necessary, allowing multiple callers despite being invoked by only a subset of those authorized

entities in practice.


The following instances were identified:











In <mark>`Mailbox.sol`</mark> <mark>,</mark> the <mark>`bridgehubRequestL2Transaction`</mark> [function permits calls](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L127)

from both <mark>`Bridgehub`</mark> and <mark>`InteropCenter`</mark> <mark>.</mark> In practice, this function is only invoked

by <mark>`Bridgehub`</mark> <mark>,</mark> while <mark>`InteropCenter`</mark> exclusively interacts with

<mark>`bridgehubRequestL2TransactionOnGateway`</mark> <mark>,</mark> making its access unnecessary.


In <mark>`MessageRootBase.sol`</mark> <mark>,</mark> the <u><mark>`[setMigratingChainBatchNumber](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/message-root/MessageRootBase.sol#L159)`</mark></u> function uses

the <mark>`onlyBridgehubOrChainAssetHandler`</mark> modifier, even though it is only ever

called by the <mark>`ChainAssetHandler`</mark> contract. Allowing <mark>`Bridgehub`</mark> access expands

permissions without functional justification.


In <mark>`BaseTokenHolder.sol`</mark> <mark>,</mark> the <u><mark>`[burnAndStartBridging](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/BaseTokenHolder.sol#L122)`</mark></u> function is protected by

the <mark>`onlyBridgingCaller`</mark> modifier, which permits access to <mark>`InteropHandler`</mark>


v.31 Interop Audit − Low Severity − 22


despite there being no observed execution path where <mark>`InteropHandler`</mark> invokes this

function.


In <mark>`L2BaseTokenEra.sol`</mark> <mark>,</mark> the <mark>`transferFromTo`</mark> function restricts access to a set of

predefined addresses, including <u><mark>`[L2BaseTokenHolder](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/era/L2BaseTokenEra.sol#L54)`</mark></u> <mark>.</mark> However, <mark>`BaseTokenHolder`</mark>

does not directly invoke this function, as calls are routed through the

<mark>`MsgValueSimulator`</mark> contract, making this permission appear unnecessary.



Although no immediate vulnerability arises from these misconfigurations, they violate the

principle of least privilege and increase the attack surface in the event of future changes,

integrations, or contract upgrades.


Consider removing unused authorized callers to tighten access control modifiers to include

only the contracts that are strictly required to call each function.


**_Update:_** _[Resolved in pull request #2148.](https://github.com/matter-labs/era-contracts/pull/2148)_

### **L-07 Missing Input Validation**


Across the codebase, there are instances where function inputs are expected to satisfy certain

properties, but these assumptions are not explicitly enforced. The following cases were

identified:









In InteropCenter, the <u><mark>`[forwardTransactionOnGatewayWithBalanceChange](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L567)`</mark></u>

[function overwrites](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropCenter.sol#L578) the <mark>`balanceChange.baseTokenAssetId`</mark> parameter with the

value stored within the Bridgehub contract, without checking that the provided value is

the expected one.


A chain that has been designated as a permanent rollup should not revert to a non
permanent state. In the Migrator facet, the <u><mark>`[forwardedBridgeMint](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol#L207-L289)`</mark></u> function does not

validate that, if <mark>`s.isPermanentRollup`</mark> is already set to true (i.e., the chain had

previously been marked as a permanent rollup before migrating back to Gateway and

now back to L1), the incoming <u><mark>`[_commitment.isPermanentRollup](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol#L227)`</mark></u> flag is also true.

The function should revert if these values do not match.


v.31 Interop Audit − Low Severity − 23


A mismatch between these two values would only be possible in the case of a malicious or

faulty settlement layer. However, since this is a straightforward validation, it is worth adding this

extra check to strengthen invariants.







In <u><mark>`[Mailbox::requestL2TransactionToGatewayMailboxWithBalanceChange](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L299-L305)`</mark></u> <mark>,</mark>

<mark>`_expirationTimestamp`</mark> is expected to always be 0, as noted in <u><mark>`[IMailboxImpl](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-interfaces/IMailboxImpl.sol#L88)`</mark></u> <mark>.</mark>

However, this is not enforced.



Since the parameter is only used when computing the <mark>`canonicalTxHash`</mark> <mark>,</mark> allowing non-zero

values introduces unnecessary flexibility and potential inconsistency. Enforcing

<mark>`_expirationTimestamp == 0`</mark> would align with the intended design and improve

determinism.







In the <mark>`getL2UpgradeTxData`</mark> of the <u><mark>`[EraSettlementLayerV31Upgrade](https://github.com/matter-labs/era-contracts/blob/dab8e51e0d7fc35c3abe255ee0b4504a842edcce/l1-contracts/contracts/upgrades/EraSettlementLayerV31Upgrade.sol#L20-L45)`</mark></u> and

<u><mark>`[ZKSyncOSSettlementLayerV31Upgrade](https://github.com/matter-labs/era-contracts/blob/dab8e51e0d7fc35c3abe255ee0b4504a842edcce/l1-contracts/contracts/upgrades/ZKsyncOSSettlementLayerV31Upgrade.sol#L19-L44)`</mark></u> contracts, consider checking that the

<mark>`_zksyncOS`</mark> input agrees with the type of the contract (zkos or not). Also, consider

checking that the selector of <mark>`_existingTxData`</mark> equals

<mark>`IComplexUpgrader.forceDeployAndUpgrade`</mark> <mark>.</mark>



Consider adding the suggested input validations to strengthen assumptions, improve

robustness, and enhance security.


**_Update:_** _[Resolved in pull request #2149.](https://github.com/matter-labs/era-contracts/pull/2149)_

### **L-08 Asymmetric Base Token Supply Cap** **Between ZKOS and Non-ZKOS Chains**


There is an asymmetry in the base token cap between ZKOS and non-ZKOS chains. In the

ZKOS case, the total supply is computed as:

```
zkosPreV31TotalSupply + (INITIAL_BASE_TOKEN_HOLDER_BALANCE L2_BASE_TOKEN_HOLDER_ADDR.balance)

```

while in the non-ZKOS case, it is computed as:

```
INITIAL_BASE_TOKEN_HOLDER_BALANCE eraAccountBalance[L2_BASE_TOKEN_HOLDER_ADDR]

```

Both formulas yield the correct actual total supply since, in the non-ZKOS case, the already

circulating total supply is deducted during initialization. However, the resulting caps differ

between the two cases: <mark>`zkosPreV31TotalSupply +`</mark>


v.31 Interop Audit − Low Severity − 24


<mark>`INITIAL_BASE_TOKEN_HOLDER_BALANCE`</mark> for ZKOS, versus

<mark>`INITIAL_BASE_TOKEN_HOLDER_BALANCE`</mark> for non-ZKOS.


Consider making the caps symmetric in both cases to preserve the principle that all chains

should behave consistently, regardless of whether they operate on top of ZKOS or not.


**_Update:_** _[Resolved in pull request #2187.](https://github.com/matter-labs/era-contracts/pull/2187)_

## **Notes & Additional** **Information**

### **N-01 Redundant Branching in** **`InteropCenter._ensureCorrectTotalValue`**


The <u><mark>`[_ensureCorrectTotalValue](https://github.com/matter-labs/era-contracts/blob/99c2004695fb95f522b9048da1e44b94f98f7922/l1-contracts/contracts/interop/InteropCenter.sol#L259)`</mark></u> function in <mark>`InteropCenter`</mark> handles

<mark>`_totalBurnedCallsValue`</mark> differently depending on whether the amount corresponds to

the chain’s base token.


This distinction appears to be based on the assumption that the chain’s base token must be

[handled directly](https://github.com/matter-labs/era-contracts/blob/99c2004695fb95f522b9048da1e44b94f98f7922/l1-contracts/contracts/interop/InteropCenter.sol#L274) through the base token contract, while non-base tokens must be handled

through <u><mark>`[AssetRouter.bridgehubDepositBaseToken](https://github.com/matter-labs/era-contracts/blob/99c2004695fb95f522b9048da1e44b94f98f7922/l1-contracts/contracts/interop/InteropCenter.sol#L278)`</mark></u> <mark>.</mark>


However, <mark>`bridgehubDepositBaseToken`</mark> <u>[already supports](https://github.com/matter-labs/era-contracts/blob/99c2004695fb95f522b9048da1e44b94f98f7922/l1-contracts/contracts/bridge/ntv/NativeTokenVaultBase.sol#L428)</u> the case where the destination

chain’s base token is equal to the current chain’s base token. As a result, the separate handling

in <mark>`_ensureCorrectTotalValue`</mark> is unnecessary and introduces avoidable complexity.


Consider simplifying <mark>`_ensureCorrectTotalValue`</mark> by removing the unnecessary distinction

and relying on the existing handling in <mark>`bridgehubDepositBaseToken`</mark> where appropriate.

This would reduce complexity and improve readability without changing behavior.


**_Update:_** _Acknowledged, will resolve._


v.31 Interop Audit − Notes & Additional Information − 25


### **N-02 Inconsistencies in Fee Price Adjustment** **Logic**

In the <mark>`Admin`</mark> facet, the access-controlled <u><mark>`[changeFeeParams](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L172)`</mark></u> and <u><mark>`[setTokenMultiplier](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L221)`</mark></u>

functions are used to update fee-related parameters on L1.


For chains that may activate Stage1 mode, such updates are expected to be constrained by

<mark>`_enforcePriceChangeBound`</mark> <mark>.</mark> While <mark>`changeFeeParams`</mark> [applies this bound conditionally](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L190)

only for chains that can activate Stage1 mode, <mark>`setTokenMultiplier`</mark> applies it

<u>[unconditionally. This creates inconsistent behavior between the two fee update paths and](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L228)</u>

unnecessarily restricts flexibility for chains that cannot activate Stage1 mode.


In addition, <u><mark>`[_enforcePriceChangeBound](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L259-L283)`</mark></u> ensures that fee updates remain within

predefined bounds relative to the previous price.


The upper bound is calculated as:

```
oldPrice * MAX_PRICE_CHANGE_NUMERATOR / MAX_PRICE_CHANGE_DENOMINATOR

```

With the current parameters (13/10), this is intended to allow up to a 30% increase. However,

due to Solidity’s integer division rounding down, the effective maximum increase is slightly

below 30%.


For the lower bound, the ratio is inverted:

```
oldPrice * MAX_PRICE_CHANGE_DENOMINATOR / MAX_PRICE_CHANGE_NUMERATOR

```

This results in a factor of 10/13, corresponding to a decrease of approximately 23.08%, not

30%. Rounding does not compensate for this difference, leading to an inherent asymmetry

between allowed increases and decreases. This may reduce flexibility when decreasing fees

and introduce unintuitive behavior.


Consider aligning the bounds to achieve symmetric behavior if that is the intended design.

Alternatively, explicitly document the asymmetry and its rationale to ensure correct

expectations and usage. Furthermore, consider applying <mark>`_enforcePriceChangeBound`</mark>

conditionally in <mark>`setTokenMultiplier`</mark> as well, to align its behavior with

<mark>`changeFeeParams`</mark> and preserve flexibility where Stage1 mode is not applicable.


**_Update:_** _[Resolved in pull request #2151.](https://github.com/matter-labs/era-contracts/pull/2151)_


v.31 Interop Audit − Notes & Additional Information − 26


### **N-03 InteropHandler Does Not Explicitly Inherit** **`IERC7786Recipient`**

The <u><mark>`[InteropHandler](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol)`</mark></u> contract is designed to receive ERC-7786 cross-chain messages and

already implements the <mark>`receiveMessage`</mark> function required by <mark>`IERC7786Recipient`</mark> <mark>.</mark>

However, it does not explicitly declare inheritance from the interface.


As a result, the contract is functionally compatible with the expected recipient flow, but it does

not formally advertise ERC-7786 recipient compliance at the type level. This may reduce clarity

and could affect integrations or tooling that rely on explicit interface inheritance rather than

function-level compatibility alone.


Consider explicitly inheriting <mark>`IERC7786Recipient`</mark> in <mark>`InteropHandler`</mark> to make

compliance with the expected recipient interface clear and intentional.


**_Update:_** _[Resolved in pull request #2152.](https://github.com/matter-labs/era-contracts/pull/2152)_

### **N-04 Missing Revert on Invalid** **BUNDLE_IDENTIFIER in Interop Message** **Handling**


In <mark>`GWAssetTracker`</mark> <mark>,</mark> the <mark>`_handleInteropCenterMessage`</mark> [function verifies](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/GWAssetTracker.sol#L498-L500) whether an

incoming interop message contains the expected <mark>`BUNDLE_IDENTIFIER`</mark> <mark>.</mark> However, the

function does not revert if the check fails.


The relevant comment in the code indicates that, starting from version 31, the failure of this

validation is expected to cause a transaction revert. The current implementation does not

enforce this behavior, resulting in a discrepancy between the code and the intended

specification.


Consider updating the implementation to revert the transaction when the

<mark>`BUNDLE_IDENTIFIER`</mark> check fails, ensuring alignment with the v.31 specification and

preventing the processing of invalid messages.


**_Update:_** _[Resolved in pull request #2153.](https://github.com/matter-labs/era-contracts/pull/2153)_


v.31 Interop Audit − Notes & Additional Information − 27


### **N-05 Ambiguous Accounting for Base Tokens in** **Asset Trackers**

For L2 chains settling on L1, the <mark>`L1AssetTracker`</mark> and <mark>`L2AssetTracker`</mark> contracts

[maintain accounting of funds deposited from](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/L1AssetTracker.sol#L235) [and withdrawn to](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/L2AssetTracker.sol#L244) L1. This accounting is used

during migration to another settlement layer (e.g., GW), where token balances must be

correctly <u>[transferred.](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/L1AssetTracker.sol#L533)</u>


The design assumes that the tracked L1 <mark>`chainBalance`</mark> may temporarily exceed the actual

migratable amount due to unclaimed failed deposits. However, the implementation does not

distinguish between base tokens and non-base tokens.


This distinction is relevant because failed L1 **_→_** L2 deposits behave differently for base tokens:

instead of being claimed on L1, they are automatically <u>[refunded](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/system-contracts/bootloader/bootloader.yul#L1229)</u> to the refundRecipient on L2.

As a result, the accounting model implicitly treats all tokens uniformly, despite differences in

their failure handling semantics.


No immediate impact is expected. However, the lack of differentiation introduces ambiguity in

accounting assumptions, making the system more error-prone and harder to reason about,

particularly during migrations.


Consider explicitly differentiating accounting logic between base and non-base tokens, or

clearly document the assumptions that justify treating them uniformly. This will improve

correctness guarantees and reduce the risk of accounting inconsistencies in future changes.


**_Update:_** _[Resolved in pull request #2154.](https://github.com/matter-labs/era-contracts/pull/2154)_

### **N-06 Inconsistent Restoration of** **pausedDepositsTimestamp Across Migration** **Flows**


Prior to initiating a chain migration, the

<mark>`Migrator.pauseDepositsBeforeInitiatingMigration`</mark> function is invoked to set the

<mark>`s.pausedDepositsTimestamp`</mark> state variable within the DP storage <u>[on both L1 and GW.](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol#L117-L120)</u>

This mechanism ensures deposits are paused consistently across domains during migration.


However, the restoration of this state variable post-migration is not handled symmetrically

across all migration scenarios.


v.31 Interop Audit − Notes & Additional Information − 28


Specifically, the internal function <mark>`_unpauseDeposits`</mark> <mark>,</mark> which resets

<mark>`s.pausedDepositsTimestamp`</mark> <mark>,</mark> is invoked in the following cases:











Within <u><mark>`[Migrator.forwardedBridgeMint](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol#L286)`</mark></u> <mark>,</mark> upon completion of the migration process

on the new SL.


Within <u><mark>`[Migrator.forwardedBridgeMintTransferResult](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol#L293)`</mark></u> <mark>,</mark> intended to be

executed on L1 following the completion of an L1 **_→_** GW migration (initiated via

<u><mark>`[L1Nullifier](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/L1Nullifier.sol#L291)`</mark></u> <mark>)</mark> .


Within the access-controlled <mark>`unpauseDeposits`</mark> function, which is restricted to

execution on GW.



In the case of a GW **_→_** L1 migration, none of the above execution paths result in

<mark>`_unpauseDeposits`</mark> being called on GW. As a result, <mark>`s.pausedDepositsTimestamp`</mark>

remains set on GW indefinitely after migration.


In the current system design, this inconsistency does not lead to immediate functional issues,

as a GW **_→_** L1 migration is terminal and no further migrations are expected.


However, this asymmetric state restoration introduces state inconsistency across chains, which

may complicate reasoning about system invariants and potentially lead to forward
compatibility risks, particularly if future versions support multiple migrations or bidirectional

migration cycles involving GW.


Consider ensuring that <mark>`_unpauseDeposits`</mark> is invoked on GW following a GW **_→_** L1

migration to restore <mark>`s.pausedDepositsTimestamp`</mark> consistently across all migration paths.


**_Update:_** _Acknowledged, will resolve._

### **N-07 Missing Deposit Pause Validation on** **Receiving Settlement Layer**


Chain migration requires deposits to be paused on both the source and destination settlement

layers to ensure consistency during the process.


In <mark>`Migrator.sol`</mark> <mark>,</mark> <mark>`forwardedBridgeBurn`</mark> <u>[validates that deposits are paused](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol#L167)</u> on the

settlement layer the chain is migrating from. However, <u><mark>`[forwardedBridgeMint](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-deps/facets/Migrator.sol#L207)`</mark></u> <mark>,</mark> which

executes on the receiving settlement layer, does not perform a similar check.


v.31 Interop Audit − Notes & Additional Information − 29


While this does not introduce a direct issue in the current implementation, it creates an

inconsistency in validation between the two migration steps and omits a useful sanity check.


Consider adding a deposit pause check in <mark>`forwardedBridgeMint`</mark> for consistency and

improved robustness.


**_Update:_** _[Resolved in pull request #2156.](https://github.com/matter-labs/era-contracts/pull/2156)_

### **N-08 Hardcoded originChainId in Base Token** **Finalization May Be Misleading**


In <mark>`L2AssetTracker.sol`</mark> <mark>,</mark> the <mark>`handleFinalizeBaseTokenBridgingOnL2`</mark> function is

invoked when a base token deposit is finalized. Since <mark>`L2AssetTracker`</mark> tracks

<mark>`chainBalance`</mark> only for native tokens of the chain, and base tokens are in principle bridged

assets, this function primarily handles forced asset migration and updates to

<mark>`totalSuccessfulDepositsFromL1`</mark> when applicable.


Within this flow, the internal <mark>`_handleFinalizeBridgingOnL2Inner`</mark> function is called with

a hardcoded originChainId set to <mark>`L1_CHAIN_ID`</mark> <mark>,</mark> regardless of the actual origin of the asset.


While this does not introduce a functional issue in the current design, the use of a hardcoded

value that may not reflect the true origin can be misleading and may reduce code clarity.


Consider documenting explicitly that <mark>`L1_CHAIN_ID`</mark> is used as a placeholder in this context

and does not necessarily reflect the actual origin of the asset. This will improve readability and

reduce the risk of incorrect assumptions in future modifications.


**_Update:_** _[Resolved in pull request #2157.](https://github.com/matter-labs/era-contracts/pull/2157)_

### **N-09 Naming Inconsistencies**


A few naming choices in the codebase appear outdated or imprecise relative to the current

architecture and upcoming functionality.







In <mark>`Mailbox.sol`</mark> <mark>,</mark>

<mark>`requestL2TransactionToGatewayMailboxWithBalanceChange`</mark> reverts with a

<u><mark>`[NotHyperchain](https://github.com/matter-labs/era-contracts/blob/84e5c59386b6b324d6547c9ad551e43f9a22fc93/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L296)`</mark></u> <u>error</u> when the caller is not the diamond proxy of the relevant chain.

The error name appears to follow older terminology and may no longer match the current

ZKChain naming convention.


v.31 Interop Audit − Notes & Additional Information − 30


In <mark>`AssetRouterBase`</mark> <mark>,</mark> the <mark>`_burn`</mark> function uses the variable name <u><mark>`[l1AssetHandler](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L255)`</mark></u>

for the handler associated with <mark>`assetId`</mark> <mark>.</mark> This name implies that the handler is always

an L1 contract, whereas starting from version 31, the same logic will also be used for

interop transactions, wherein the resolved handler may be an L2 asset handler.



Consider renaming these identifiers to better reflect current terminology and behavior.


**_Update:_** _[Resolved in pull request #2158.](https://github.com/matter-labs/era-contracts/pull/2158)_

### **N-10 Redundant Code and Minor Structural** **Improvements**


Multiple instances of unused variables, redundant imports, dead code, and suboptimal code

organization were identified across the codebase. While none of these introduce functional

issues, they increase complexity and reduce maintainability.


In <mark>`IAssetTrackerBase.sol`</mark> <mark>:</mark>







The <u><mark>`[INTEROP_BALANCE_CHANGE_VERSION](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/IAssetTrackerBase.sol#L7)`</mark></u> seems to be unused throughout the

codebase.



In <mark>`AssetTrackerBase.sol`</mark> <mark>:</mark>







The <u><mark>`[_sendL1ToGatewayMigrationDataToL1](https://github.com/matter-labs/era-contracts/blob/84e5c59386b6b324d6547c9ad551e43f9a22fc93/l1-contracts/contracts/bridge/asset-tracker/AssetTrackerBase.sol#L133)`</mark></u> internal function is only used within

the <mark>`L2AssetTracker`</mark> contract and thus could be moved to that contract instead of

having it in the base contract. Similarly, the <u><mark>`[_sendGatewayToL1MigrationDataToL1](https://github.com/matter-labs/era-contracts/blob/84e5c59386b6b324d6547c9ad551e43f9a22fc93/l1-contracts/contracts/bridge/asset-tracker/AssetTrackerBase.sol#L142)`</mark></u>

could be moved to the <mark>`GWAssetTracker`</mark> contract.



In <mark>`SystemContractBase.sol`</mark> <mark>:</mark>







The <u><mark>`[onlyCallFromBootloaderOrInteropHandler](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/system-contracts/contracts/abstract/SystemContractBase.sol#L74-L87)`</mark></u> <u>and</u>

<u><mark>`[onlyCallFromInteropCenterOrNTV](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/system-contracts/contracts/abstract/SystemContractBase.sol#L74-L87)`</mark></u> modifiers are not used throughout the

codebase.



In <mark>`ChainAssetHandlerBase.sol`</mark> <mark>:</mark>







In <mark>`_finalizeBridgeBurn`</mark> <mark>,</mark> <u><mark>`[_recordMigrationToSL](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/chain-asset-handler/ChainAssetHandlerBase.sol#L254)`</mark></u> is conditionally called only

when <mark>`block.chainId`</mark> equals L1, but this check is redundant since

<mark>`_recordMigrationToSL`</mark> is only implemented in <mark>`L1ChainAssetHandler`</mark> <mark>.</mark>



Consider removing unused constants, structs, or modifiers and eliminating redundant imports

and dead code. In addition, consider relocating functions to the contracts where they are


v.31 Interop Audit − Notes & Additional Information − 31


actually used. These changes will improve readability, reduce complexity, and strengthen long
term maintainability.


**_Update:_** _[Resolved in pull request #2159. The team stated:](https://github.com/matter-labs/era-contracts/pull/2159)_


_We considered removing the_ _<mark>`block.chainid == l1ChainId()`</mark>_ _guard around_

_<mark>`recordMigrationToSL`</mark>_ _<mark>.</mark>_ _While the L2 override is indeed a no-op, we decided to_

_leave the explicit check for clearness of intention._

### **N-11 Typographical Errors**


A few typos were identified in codebase comments. In particular:











In <mark>`Config.sol`</mark> <mark>,</mark> <u>["support"](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/common/Config.sol#L268)</u> should be "supported".


In the comment of <mark>`IAssetHandler::bridgeMint`</mark> <mark>,</mark> <u>["malicioud"](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/interfaces/IAssetHandler.sol#L29)</u> should be

"malicious".


In the comment describing the <mark>`L2ContractAddresses::`</mark>

<mark>`L2_COMPLEX_UPGRADER_ADDR`</mark> [constant, "upgragedes"](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/common/l2-helpers/L2ContractAddresses.sol#L74) should be "upgrades".



Consider fixing these typos to improve readability and maintain code quality.


**_Update:_** _[Resolved in pull request #2160.](https://github.com/matter-labs/era-contracts/pull/2160)_

### **N-12 Redundant Logic and Minor Code** **Simplifications**


Several instances of redundant logic and unnecessary branching were identified across the

codebase. While these do not introduce functional issues, they increase code complexity and

reduce readability.









In <u><mark>`[GWAssetTracker._handleAssetRouterMessageInner](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/GWAssetTracker.sol#L608)`</mark></u> <mark>,</mark> the call to

<u><mark>`[_decreaseChainBalance(_sourceChainId, _assetId, amount)](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-tracker/GWAssetTracker.sol#L629)`</mark></u> is executed

in both branches of the conditional logic. This operation can be moved outside the if-else

blocks to eliminate duplication.


In <u><mark>`[AssetRouterBase._getTransferData](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L182)`</mark></u> <mark>,</mark> the if-else statement checking the

encoding version is unnecessary, as version validation is already handled within


v.31 Interop Audit − Notes & Additional Information − 32


<u><mark>`[DataEncoding.decodeAssetRouterBridgehubDepositData](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/common/libraries/DataEncoding.sol#L77)`</mark></u> <mark>.</mark> The function can

therefore be simplified into a single-line return.


In <mark>`ChainAssetHandlerBase.bridgeMint`</mark> <mark>,</mark> the chain’s new migration number <u>[is](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/chain-asset-handler/ChainAssetHandlerBase.sol#L344)</u>

<u>[validated](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/chain-asset-handler/ChainAssetHandlerBase.sol#L344)</u> on L1 before calling <mark>`_recordMigrationFromSL`</mark> <mark>,</mark> [even though the same](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/chain-asset-handler/L1ChainAssetHandler.sol#L342)

<u>[validation is already performed within](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/chain-asset-handler/L1ChainAssetHandler.sol#L342)</u> <u><mark>`[_recordMigrationFromSL](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/chain-asset-handler/L1ChainAssetHandler.sol#L342)`</mark></u> <mark>,</mark> making the initial

check redundant.



Consider refactoring the identified sections to remove redundant checks and unnecessary

branching. Simplifying control flow will improve readability, reduce duplication, and lower the

risk of inconsistencies in future changes.


**_Update:_** _[Resolved in pull request #2161.](https://github.com/matter-labs/era-contracts/pull/2161)_

### **N-13 Misleading or Incomplete Comments**


A few instances of misleading or incomplete comments were identified in the codebase:















In <mark>`IMigrator.sol`</mark> <mark>,</mark> [the docstring](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/state-transition/chain-interfaces/IMigrator.sol#L22) for

<mark>`pauseDepositsBeforeInitiatingMigration`</mark> implies that the function is called

only for L1->GW migrations, while in fact, it must be called also for GW->L1 migrations.


Several <u>[comments](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L239)</u> in the <mark>`AssetRouter`</mark> contracts imply that they only support L1->L2

transactions, while with v.31 and onwards, they are also used for interop transactions

between ZKChains.


In <mark>`ChainAssetHandlerBase`</mark> <mark>,</mark> there is an <u>[incomplete comment](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/core/chain-asset-handler/ChainAssetHandlerBase.sol#L368)</u> inside <mark>`bridgeMint`</mark> <mark>.</mark>


Within <mark>`ZKOSContractDeployer`</mark> <mark>,</mark> [the comment](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/zksync-os/ZKOSContractDeployer.sol#L14) describing the

<mark>`onlyComplexUpgrader`</mark> modifier wrongly states that it ensures <mark>`NativeTokenVault`</mark>

is the caller.


[The docstrings](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/zksync-os/interfaces/IZKOSContractDeployer.sol#L13-L15) describing the parameters of <mark>`setBytecodeDetailsEVM`</mark> within

<mark>`IZKOSContractDeployer`</mark> are not clear. <mark>`_bytecodeHash`</mark> and

<mark>`_observableBytecodeHash`</mark> are described as "the hash of the bytecode" and "the

hash of the observable bytecode," while the latter should more accurately state "the

observable (keccak256) hash of the bytecode." Similar confusion exists in the

description of the <mark>`_bytecodeLength`</mark> parameter.


v.31 Interop Audit − Notes & Additional Information − 33


In the <mark>`fallback`</mark> of <mark>`L1MessengerZKOS`</mark> <mark>,</mark> a <u>[comment](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/zksync-os/L1MessengerZKOS.sol#L54-L55)</u> says that any ETH sent will be

intentionally burnt, while the opcode <mark>`invalid()`</mark> is used that burns all the forwarded

gas but reverts all other changes, including ETH sent with the transaction.


[The comment](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/bridge/ntv/L2NativeTokenVaultZKOS.sol#L18-L21) in <mark>`L2NativeTokenVaultZKOS::_deployBeaconProxy`</mark> falsely states

that the <mark>`ContractDeployer`</mark> system contract is used.


In <mark>`BaseZkSyncUpgradeGenesis::_setNewProtocolVersion`</mark> <mark>,</mark> in the comment

about the <u><mark>`[minorDelta](https://github.com/matter-labs/era-contracts/blob/dab8e51e0d7fc35c3abe255ee0b4504a842edcce/l1-contracts/contracts/upgrades/BaseZkSyncUpgradeGenesis.sol#L52-L54)`</mark></u> variable, the <mark>`>=`</mark> should be just `>` .



Consider updating these comments to improve clarity, accuracy, and overall readability.


**_Update:_** _[Resolved in pull request #2162.](https://github.com/matter-labs/era-contracts/pull/2162)_

### **N-14 Missing Deadline Initialization Check in** **`GovernanceUpgradeTimer`**


The <u><mark>`[checkDeadline](https://github.com/matter-labs/era-contracts/blob/dab8e51e0d7fc35c3abe255ee0b4504a842edcce/l1-contracts/contracts/upgrades/GovernanceUpgradeTimer.sol#L89-L93)`</mark></u> function in <mark>`GovernanceUpgradeTimer`</mark> does not verify that a

deadline has been set before evaluating it. If <mark>`checkDeadline`</mark> is called prior to a deadline

being initialized, the function will silently operate on a zero or default value, potentially allowing

the deadline check to pass unexpectedly.


Consider adding a sanity check at the beginning of <mark>`checkDeadline`</mark> that reverts if the

deadline has not yet been set.


**_Update:_** _[Resolved in pull request #2184.](https://github.com/matter-labs/era-contracts/pull/2184)_

### **N-15 Unused Code**


Two instances of unused code were identified within the zksync-os module. Dead code

increases the cognitive overhead of auditing and maintaining a codebase.











The <u><mark>`[ZKOSContractHelper](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/zksync-os/ZKOSContractHelper.sol)`</mark></u> contract contains only an <mark>`IBaseToken`</mark> interface

definition and does not appear to be imported or referenced anywhere in the codebase.


The <u><mark>`[L1MessengerSendFailed](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/l2-system/zksync-os/errors/ZKOSContractErrors.sol#L8)`</mark></u> custom error defined in <mark>`ZKOSContractErrors.sol`</mark>

is never referenced within the codebase.


In <mark>`BaseZkSyncUpgrade.sol`</mark> <mark>,</mark> the <u><mark>`[UpgradeInnerFailed](https://github.com/matter-labs/era-contracts/blob/dab8e51e0d7fc35c3abe255ee0b4504a842edcce/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L34)`</mark></u> error is unused.



Consider removing all instances of unused code for clarity and consistency.


v.31 Interop Audit − Notes & Additional Information − 34


**_Update:_** _[Resolved in pull request #2185.](https://github.com/matter-labs/era-contracts/pull/2185)_

## **Client Reported**

### **CR-01 Interop Bundles Can Be Claimed On** **Chains Settling On L1**


A valid interop bundle can be executed or unbundled on a destination chain where interop

claims should be disabled, because the gating check reads the wrong source of settlement
layer state.


Specifically, <mark>`InteropHandler`</mark> is intended to block interop claims while the destination chain

is settling directly on L1. The check is implemented in <u>[InteropHandler.executeBundle](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L83)</u> and

<u>[InteropHandler.unbundleBundle:](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/l1-contracts/contracts/interop/InteropHandler.sol#L163)</u>

```
require(L2_BRIDGEHUB.settlementLayer(block.chainid) != L1_CHAIN_ID,
CannotClaimInteropOnL1Settlement());

```

However, <mark>`L2_BRIDGEHUB.settlementLayer(block.chainid)`</mark> is not the current chain's

runtime settlement layer. <mark>`settlementLayer`</mark> is Bridgehub's registry state — it tracks

settlement-layer assignments for chains known to that Bridgehub, and is not guaranteed to

contain a correct entry for <mark>`block.chainid`</mark> <mark>o</mark> n the current L2. The runtime source of truth is

<u><mark>`[L2_SYSTEM_CONTEXT_SYSTEM_CONTRACT.currentSettlementLayerChainId()](https://github.com/matter-labs/era-contracts/blob/4271d0a37d64c43697781fa272d53e6b9c9f401c/system-contracts/contracts/SystemContext.sol#L108)`</mark></u> <mark>,</mark>

which is maintained by <mark>`SystemContext`</mark> <mark>.</mark>


On an L1-settled destination chain, <mark>`L2_BRIDGEHUB.settlementLayer(block.chainid)`</mark>

may be unset (i.e. 0). In this case, the check will proceed even though the chain is settling

directly on L1 — bypassing the invariant that interop claims may only happen while the chain

settles on Gateway.


In <mark>`InteropHandler.executeBundle`</mark> and <mark>`InteropHandler.unbundleBundle`</mark>

consider querying <mark>`SystemContext`</mark> about the chain's settlement layer instead of Bridgehub,

to ensure that only chains which settle on Gateway are involved in interop operations.


**_Update:_** _[Resolved in pull request #2188.](https://github.com/matter-labs/era-contracts/pull/2188)_


v.31 Interop Audit − Client Reported − 35


### **CR-02 ProtocolUpgradeHandler cannot freeze** **chains under the ZKOS ChainTypeManager**

<mark>`ProtocolUpgradeHandler`</mark> holds <u>a single</u> <u><mark>`[ChainTypeManager](https://github.com/zksync-association/zk-governance/blob/b1d1bdce1def3c036c06e449787a3763bf47e766/l1-contracts/src/ProtocolUpgradeHandler.sol#L75)`</mark></u> (CTM) reference, <u>[set once](https://github.com/zksync-association/zk-governance/blob/b1d1bdce1def3c036c06e449787a3763bf47e766/l1-contracts/src/ProtocolUpgradeHandler.sol#L136)</u>

at deployment as an immutable. This was sound while every ZK chain registered to a given

Bridgehub shared a single CTM, but with the introduction of ZKsync OS this is no longer the

case: Era chains and ZKsync OS chains live under different <mark>`ChainTypeManager`</mark> instances

while remaining under the same <mark>`Bridgehub`</mark> and the same <mark>`ProtocolUpgradeHandler`</mark> <mark>.</mark>

The <u><mark>`[freeze](https://github.com/zksync-association/zk-governance/blob/b1d1bdce1def3c036c06e449787a3763bf47e766/l1-contracts/src/ProtocolUpgradeHandler.sol#L406-L408)`</mark></u> / <u><mark>`[unfreeze](https://github.com/zksync-association/zk-governance/blob/b1d1bdce1def3c036c06e449787a3763bf47e766/l1-contracts/src/ProtocolUpgradeHandler.sol#L454-L455)`</mark></u> flows in <mark>`ProtocolUpgradeHandler`</mark> still assume one CTM and

therefore cannot reach chains owned by the other.


In essence, any chain whose <mark>`ChainTypeManager`</mark> is not the one stored in

<mark>`ProtocolUpgradeHandler,`</mark> the call to <mark>`freezeChain`</mark> <mark>/</mark> <mark>`unfreezeChain`</mark> will not

succeed since the CTM has no record of that chainId. This failure is invisible in the freeze paths

because the calls are wrapped in <u><mark>`[try { ... } catch {}](https://github.com/zksync-association/zk-governance/blob/b1d1bdce1def3c036c06e449787a3763bf47e766/l1-contracts/src/ProtocolUpgradeHandler.sol#L455)`</mark></u>, so the loops silently skip the

chains they cannot reach and <mark>`_freeze`</mark> / <mark>`_unfreeze`</mark> still emit <mark>`Freeze`</mark> / <mark>`Unfreeze`</mark> events

and complete successfully.


The consequence is a partial freeze: chains under the configured CTM are frozen, but chains

under the other CTM remain operational. This breaks the security guarantee the freeze

mechanism is meant to provide, since the Security Council can no longer halt the entire

protocol via <mark>`ProtocolUpgradeHandler`</mark> during an emergency.


**_Update:_** _[Resolved in pull request #42.](https://github.com/zksync-association/zk-governance/pull/42)_


v.31 Interop Audit − Client Reported − 36


## **Conclusion**

In this diff audit we reviewed a wide range of changes that have been introduced to the

protocol, including updates to interoperability features, the introduction of permissionless

execution of L1->L2 transactions to support Stage-1 L2 status for ZKChains, improvements to

chain migration between settlement layers, and more refined balance accounting during

migrations.


While the overall design is complex, the codebase was of very high quality, with thorough inline

documentation and an extensive test suite covering the new functionalities. The issues

identified during the audit were primarily related to edge cases in interoperability and migration

flows, rather than fundamental design flaws.


The Matter Labs team was highly responsive, knowledgeable, and collaborative throughout the

audit. They were readily available to answer questions and provide detailed explanations of

design decisions, which significantly contributed to the efficiency and depth of the review.


v.31 Interop Audit − Conclusion − 37


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


v.31 Interop Audit − Appendix − 38


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


v.31 Interop Audit − Appendix − 39


