### | security

# **ZKChain Release** **Candidate Audit**

#### **February 10, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  7

Priority Operations 7

Bridging Previously Unregistered Assets 7

Proof Validation 7

BaseToken and WETH 8

Legacy Handling 8


Security Model and Trust Assumptions _______________________________________________  8


Low Severity ______________________________________________________________________  9

L-01 Empty Proof Can Pass Validation on proveL2LeafInclusion 9

L-02 registerLegacyChain on BridgeHub Should Be OnlyL1 9

L-03 Misleading Documentation 9

L-04 Wrong Error Parameters Order 10


Notes & Additional Information ____________________________________________________ 11

N-01 Redundant Cast 11

N-02 Undocumented Constant 11

N-03 Typographical Errors 11

N-04 Code Duplication 11

N-05 Inconsistent Code Style 12

N-06 Unused Return Parameter 12

N-07 Duplicate Import 12

N-08 Unused Custom Errors 13

N-09 Naming Suggestions 14


Conclusion ______________________________________________________________________ 16


ZKChain Release Candidate Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2025-01-13
To 2025-02-05


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



**Total Issues** 13 (0 resolved)



**Low Severity Issues** 4 (0 resolved)



**Notes & Additional**
**Information**



9 (0 resolved)



ZKChain Release Candidate Audit − Summary − 3


## **Scope**

We conducted a diff audit of the <u>[matter-labs/era-contracts](https://github.com/matter-labs/era-contracts/)</u> repository, comparing the HEAD

[commit e3dd33c](https://github.com/matter-labs/era-contracts/tree/e3dd33ceee8f803510cbd0debb8ed55fef4007e8) [against the BASE commit 79215dc.](https://github.com/matter-labs/era-contracts/tree/79215dca77c2d75cf656c340cf18d9c74b54090d)


In scope were the following files:

```
da-contracts/contracts/
- CalldataDA.sol
- DAContractsErrors.sol
- RollupL1DAValidator.sol
l1-contracts/contracts/
bridge/
- BridgeHelper.sol
- L1ERC20Bridge.sol
- L1Nullifier.sol
- L2WrappedBaseToken.sol
- L2WrappedBaseTokenStore.sol
asset-router/
- AssetRouterBase.sol
- IAssetRouterBase.sol
- IL1AssetRouter.sol
- IL2AssetRouter.sol
- L1AssetRouter.sol
- L2AssetRouter.sol
interfaces/
- AssetHandlerModifiers.sol
- IAssetHandler.sol
- IL1SharedBridgeLegacy.sol
- IL2SharedBridgeLegacy.sol
ntv/
- IL1NativeTokenVault.sol
- INativeTokenVault.sol
- L1NativeTokenVault.sol
- L2NativeTokenVault.sol
- NativeTokenVault.sol
bridgehub/
- Bridgehub.sol
- CTMDeploymentTracker.sol
- IBridgehub.sol
- L1BridgehubErrors.sol
- MessageRoot.sol
common/
- L1ContractErrors.sol
- L2ContractAddresses.sol
libraries/
- DataEncoding.sol
- Merkle.sol
- UnsafeBytes.sol

```

ZKChain Release Candidate Audit − Scope − 4


```
- L2ContractHelper.sol
governance/
- IRestriction.sol
- L2AdminFactory.sol
- L2ProxyAdminDeployer.sol
- PermanentRestriction.sol
- TransitionaryOwner.sol
upgrades/
- BytecodesSupplier.sol
- GatewayUpgrade.sol
- IGatewayUpgrade.sol
- IL1GenesisUpgrade.sol
- L1GatewayBase.sol
- L1GenesisUpgrade.sol
- ZkSyncUpgradeErrors.sol
state-transition/
- ChainTypeManager.sol
- IChainTypeManager.sol
- L1StateTransitionErrors.sol
chain-deps/
- DiamondInit.sol
- ZKChainStorage.sol
facets/
- Admin.sol
- Executor.sol
- Getters.sol
- Mailbox.sol
- ZKChainBase.sol
chain-interfaces/
- IAdmin.sol
- IGetters.sol
data-availability/
- CalldataDA.sol
- CalldataDAGateway.sol
l2-deps/
- IL2GenesisUpgrade.sol
libraries/
- BatchDecoder.sol
- PriorityTree.sol
transactionFilterer/
- GatewayTransactionFilterer.sol
system-contracts/
bootloader/
- bootloader.yul
contracts/
- L2GatewayUpgradeHelper.sol
- L2GenesisUpgrade.sol
- MsgValueSimulator.sol
- SystemContext.sol
- SystemContractErrors.sol
- L2GatewayUpgrade.sol
interfaces/
- IL1Messenger.sol
- IL2GenesisUpgrade.sol
libraries/
- SystemContractHelper.sol

```


ZKChain Release Candidate Audit − Scope − 5


**_Update:_**


This report also covers changes introduced between HEAD commit <u>[e3dd33c](https://github.com/matter-labs/era-contracts/tree/e3dd33ceee8f803510cbd0debb8ed55fef4007e8)</u> against the BASE

[commit 91631aa, specifically the following changes:](https://github.com/matter-labs/era-contracts/tree/91631aa5acfcd044bd71d0b6cf362ee6064f8319)










<u>[Executor.sol](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol)</u> was updated to support off-chain components changes

<u>[L1GatewayBase.sol](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/L1GatewayBase.sol)</u> was updated to resolve an issue related to tokens' data fetching

<u>[IVerifier.sol](https://github.com/matter-labs/era-contracts/compare/91631aa5acfcd044bd71d0b6cf362ee6064f831..e3dd33ceee8f803510cbd0debb8ed55fef4007e8#)</u> was removed to reduce redundancy between l1- and l2- contracts folders

More explicit renaming of files, specifically in the <u>[state-transition folder](https://github.com/matter-labs/era-contracts/tree/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition)</u>



_Due to Low and Note severity issues identified during this audit, the Matter Labs team decided_

_to acknowledge all issues in this report and implement recommended changes as part of the_

_next release._


ZKChain Release Candidate Audit − Scope − 6


## **System Overview**

The introduced changes primarily include fixes, refactoring, and refinements based on

suggestions and findings from previous audits. Notable changes were made to the following

areas of the codebase:

### **Priority Operations**


When a chain switches from <mark>`priorityQueue`</mark> to <mark>`priorityTree`</mark> <mark>,</mark> a <u>[skipping mechanism](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/libraries/PriorityTree.sol#L94)</u> is

implemented to allow the last batch to be executed entirely as a priority queue and

automatically account for the unprocessed index on the priority tree before switching over.

When a chain is migrated from L1 to a settlement layer, the settlement layer priority queue will

be <u>[automatically deactivated](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/chain-deps/facets/ZKChainBase.sol#L80)</u> to ensure that all priority operations will be on the tree.

### **Bridging Previously Unregistered Assets**


When bridging previously unregistered assets, an <u>[automatic registration](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L156)</u> flow is set at the

<mark>`AssetRouter`</mark> to register the token with the chain's default

<mark>`AssetHandler`</mark> <mark>(</mark> <mark>`NativeTokenVault`</mark> <mark>)</mark> instead of reverting. This enhances the user

experience when it comes to bridging previously unregistered assets. Particular care is taken

for the L2 <mark>`NativeTokenVault`</mark> to account for previously bridged assets via legacy shared

bridges. To facilitate this, the <u><mark>`[bridgeBurnData](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/libraries/DataEncoding.sol#L29)`</mark></u> is updated with an extra <mark>`tokenAddress`</mark> for

both the registration and validation of the <mark>`assetId`</mark> <mark>.</mark>

### **Proof Validation**


The proof metadata uses <u>[an extra byte](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L136)</u> to indicate if it is the <mark>`finalProofNode`</mark> <mark>.</mark> This is to

distinguish from the case where only one batch has been executed and, thus, an empty proof

should be allowed. In order to accommodate this case, the empty proof check has also been

removed from the Merkle library.


ZKChain Release Candidate Audit − System Overview − 7


### **BaseToken and WETH**

The L1 and L2 <mark>`NativeTokenVault`</mark> <u>[will not accept any base token value](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L133)</u> during a

<mark>`bridgeMint`</mark> call despite it being a <mark>`payable`</mark> function. This restricts any attached <mark>`l2value`</mark>

to zero when bridging via BridgeHub's <mark>`requestL2TransactionTwoBridges`</mark> function.

<mark>`msg.value`</mark> is further restricted at places where it is not expected to be non-zero, such as

<mark>`_bridgeBurnBridgedToken`</mark> and <mark>`bridgeRecoverFailedTransfer`</mark> <mark>.</mark>


In addition, these restrictions make it impossible for a ZKChain to keep the default L1

<mark>`NativeTokenVault`</mark> while using a custom L2 <mark>`AssetHandler`</mark> which accepts non-zero

<mark>`msg.value`</mark> in <mark>`bridgeMint`</mark> and other functions. WETH is only allowed to be registered on

L1 <mark>`NativeTokenVault`</mark> so that it can receive previously bridged-out WETH.

### **Legacy Handling**


The special, backward-compatible handling of <mark>`amount`</mark> in the <u><mark>`[_bridgeBurnNativeToken](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L332)`</mark></u>

function of <mark>`NativeTokenVault`</mark> has been updated to ensure consistent transaction data

hash for successful recovery after failed transfers. Further <u>[restrictions](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/ntv/L2NativeTokenVault.sol#L87)</u> have also been placed

on the interfaces of legacy functions to only allow access for L1-originated tokens via legacy

bridges to Era chain.

## **Security Model and Trust** **Assumptions**


No notable changes have been made to privileged roles. However, the diamond proxy admin

functions have been further refined and are restricted to L1 only. For detailed trust assumptions

on privileged roles, we refer to our previous audit reports.


ZKChain Release Candidate Audit − Security Model and Trust Assumptions

                                                  - 8


## **Low Severity**

### **L-01 Empty Proof Can Pass Validation on** **`proveL2LeafInclusion`**

Due to the removal of the <mark>`pathLength`</mark> <u>[check, empty proofs can pass validation from the](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/libraries/Merkle.sol#L51)</u>

[external Mailbox.proveL2LeafInclusion](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L193) call with <mark>`_leaf`</mark> as the locally stored root for that

<mark>`_batchNumber`</mark> and <mark>`_proof`</mark> being empty.


During withdrawals from <mark>`L1Nullifier`</mark> <mark>,</mark> this will not pose a problem as one cannot specify

the <mark>`_leaf`</mark> directly since it is computed via the <u>[_proveL2LogInclusion](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L323)</u> function. However,

<mark>`proveL2LeafInclusion`</mark> is an <mark>`external`</mark> function and such behavior may affect unaware

integrators who may want to validate proofs using this function.


Consider adding extra documentation to warn about such behavior and emphasizing on

additional validation on the <mark>`_leaf`</mark> hash or the <mark>`_proof`</mark> length.

### **L-02 registerLegacyChain on BridgeHub** **Should Be OnlyL1**


The <u><mark>`[registerLegacyChain](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridgehub/Bridgehub.sol#L225)`</mark></u> function of the <mark>`BridgeHub`</mark> contract is intended to be called

only on L1. Consider restricting access to <mark>`registerLegacyChain`</mark> to <mark>`onlyL1`</mark> for improved

clarity of intention.

### **L-03 Misleading Documentation**


Throughout the codebase, multiple instances of misleading documentation were identified:









The comment for <u><mark>`[_getAbiParams](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/system-contracts/contracts/MsgValueSimulator.sol#L23-L25)`</mark></u> in <mark>`MsgValueSimulator.sol`</mark> switches the

definitions of the second and third ABI parameters that are returned from the function.

The second returned parameter is the one that defines whether the <mark>`systemCall`</mark> flag

should be used, and the third one should be the address to call.

[The comment](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/libraries/L2ContractHelper.sol#L187) in the <mark>`hashFactoryDeps`</mark> function of <mark>`L2ContractHelper.sol`</mark> states

that the resulting hashes are stored in the array sequentially "in bytes", whereas it should

more accurately say "in words".


ZKChain Release Candidate Audit − Low Severity − 9


[The comment](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L224) above the <mark>`_approveFundsToAssetRouter`</mark> function of

<mark>`L1ERC20Bridge.sol`</mark> states that funds are transferred to <mark>`native token vault`</mark>

whereas, in fact, they are transferred to <mark>`L1ERC20Bridge`</mark> <mark>.</mark>

The comment in the <mark>`finalizeWithdrawal`</mark> function of <mark>`L1ERC20Bridge.sol`</mark> refers

[to "shared bridge"](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L137) whereas it should refer to <mark>`L1Nullifier`</mark> instead.

The comment in <mark>`Mekle.sol`</mark> noting that the <u><mark>`[proofLength](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/libraries/Merkle.sol#L40)`</mark></u> <u>[is the height of the tree](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/libraries/Merkle.sol#L40)</u> is

misleading since this function is also used with proofs of length that are equal to the

height of the tree plus 1. This is because a chain's batch root also <u>[includes](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/system-contracts/contracts/L1Messenger.sol#L310)</u> the

aggregated root.

Since the Merkle proof length might be the height of the tree plus one (N + 1), <u><mark>`[index](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/libraries/Merkle.sol#L42)`</mark></u> is

no longer simply the leaf index in the tree in all cases. In particular, for the recursive L3 ->

L1 proof to work, the index for the <mark>`settlementLayer`</mark> leaf is of the <mark>`2^N, ...,`</mark>

<mark>`2^(N+1)-1`</mark> range to ensure the correct order of hashing the final two elements.

Consider documenting this special case for clarity.

In <mark>`DataEncoding.sol`</mark> <mark>,</mark> [the comment](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/libraries/DataEncoding.sol#L134) of the <mark>`encodeTxDataHash`</mark> function suggests

that <mark>`_transferData`</mark> only includes the deposit amount and the address of the L2

receiver, whereas it also includes the <mark>`maybeToken`</mark> address.

[The comment](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L125) for the <mark>`bridgeMint`</mark> function of the <mark>`NativeTokenVault`</mark> contract

refers to the legacy Shared Bridge.

[The comment](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L25) for the <mark>`ChainTypeManager`</mark> contract refers to the legacy "State

Transition Manager" naming.



Consider correcting any instances of misleading documentation to improve the clarity and

maintainability of the codebase.

### **L-04 Wrong Error Parameters Order**


In the <mark>`L1ContractsErrors`</mark> contract, the <u><mark>`[AssetIdMismatch](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L33)`</mark></u> custom error is defined with

its first parameter being the expected <mark>`assetId`</mark> value and the second parameter being the

actually provided one. However, the <mark>`_assetIdCheck`</mark> function of the <mark>`NativeTokenVault`</mark>

[contract throws](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L485) the <mark>`AssetIdMismatch`</mark> error due to the argument being provided in the

opposite order.


To avoid misleading errors from being thrown, consider fixing the order of the error parameters

in the <mark>`_assetIdCheck`</mark> function of <mark>`NativeTokenVault`</mark> <mark>.</mark>


ZKChain Release Candidate Audit − Low Severity − 10


## **Notes & Additional** **Information**

### **N-01 Redundant Cast**

In the <u><mark>`[_setAssetHandlerAddressThisChain](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/asset-router/AssetRouterBase.sol#L82)`</mark></u> function of <mark>`L1AssetRouterBase.sol`</mark> <mark>,</mark>

the <mark>`_nativeTokenVault`</mark> argument is unnecessarily cast to the <mark>`address`</mark> type.


Consider removing the redundant cast for improved code clarity.

### **N-02 Undocumented Constant**


The <u><mark>`[CREATE_PREFIX](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/libraries/L2ContractHelper.sol#L53)`</mark></u> <u>constant</u> value in the <mark>`L2ContractHelper`</mark> library is a random

<mark>`bytes32`</mark> value.


Consider documenting how this value was generated.

### **N-03 Typographical Errors**


Throughout the codebase, multiple instances of typographical errors were identified:












<mark>`IL2GenesisUpgrade`</mark> <mark>,</mark> line <u>[17: "THe" should be "The".](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/system-contracts/contracts/interfaces/IL2GenesisUpgrade.sol#L17)</u>

<mark>`L2AdminFactory.sol`</mark> <mark>,</mark> line <u>[63: "validateRestrctions" should be "validateRestrictions".](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/governance/L2AdminFactory.sol#L63)</u>

<mark>`L2NativeTokenVault.sol`</mark> <mark>,</mark> line <u>[235: there is an extra dot at the end of the sentence.](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/ntv/L2NativeTokenVault.sol#L235)</u>

<mark>`TransitionaryOwner.sol`</mark> <mark>,</mark> line <u>[11: "a" should be "as".](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/governance/TransitionaryOwner.sol#L11)</u>

<mark>`IGetters.sol`</mark> <mark>,</mark> line <u>[67: "transaction" should be "transactions".](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/chain-interfaces/IGetters.sol#L67)</u>

<mark>`PriorityTree.sol`</mark> <mark>,</mark> line <u>[74: "is ensures" should be "is ensured".](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/state-transition/libraries/PriorityTree.sol#L74)</u>



Consider fixing all typographical errors to improve the clarity and readability of the codebase.

### **N-04 Code Duplication**


In the <mark>`setNativeTokenVault`</mark> function of the <mark>`L1AssetRouter`</mark> contract, the <u><mark>`[assetId](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L127)`</mark></u> <u>of</u>

<u>[ETH is calculated. However, the](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L127)</u> <u><mark>`[ETH_TOKEN_ASSET_ID](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L43)`</mark></u> constant can be used instead to

avoid code duplication.


ZKChain Release Candidate Audit − Notes & Additional Information − 11


Consider using the <mark>`ETH_TOKEN_ASSET_ID`</mark> constant instead of recalculating the <mark>`assetId`</mark>

for ETH.

### **N-05 Inconsistent Code Style**


Throughout the codebase, multiple instances of inconsistent coding style were identified:









In <mark>`L2ContractAddresses.sol`</mark> <mark>,</mark> the <u><mark>`[SYSTEM_CONTRACTS_OFFSET](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L2ContractAddresses.sol#L76)`</mark></u> constant is used

[to define the address](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L2ContractAddresses.sol#L79-L82) of some system contracts. However, a number of other system

contracts' addresses are defined <u>[without using the offset value. Consider using the offset](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L2ContractAddresses.sol#L6-L36)</u>

constant for all system contracts' addresses definitions for consistency.

In <u><mark>`[L2ContractAddresses.sol](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L2ContractAddresses.sol#L60)`</mark></u> and <u><mark>`[L2ContractHelper.sol](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l2-contracts/contracts/L2ContractHelper.sol#L21)`</mark></u> <mark>,</mark> the

<mark>`IL2Messenger`</mark> interface and the <mark>`L2_MESSENGER`</mark> constant refer to the

<u><mark>`[L1Messenger](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/system-contracts/contracts/L1Messenger.sol)`</mark></u> system contract. Consider renaming to <mark>`IL1Messenger`</mark> and

<mark>`L1_MESSENGER`</mark> for consistency and clarity.



Consider maintaining a consistent code style throughout the codebase for improved code

clarity and readability.

### **N-06 Unused Return Parameter**


In <mark>`NativeTokenVault.sol`</mark> <mark>,</mark> the <u><mark>`[ensureTokenIsRegistered](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/ntv/NativeTokenVault.sol#L114)`</mark></u> function calls

<mark>`_registerToken`</mark> if the token is not already registered. However, the <mark>`newAssetId`</mark> return

variable of the <mark>`internal`</mark> function is ignored. In addition, in most of the cases where

<mark>`ensureTokenIsRegistered`</mark> is called, the token's <mark>`assetId`</mark> is either <u>[calculated](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/L1Nullifier.sol#L600-L601)</u> or

<u>[retrieved](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridge/L1Nullifier.sol#L600-L601)</u> from <mark>`NativeTokenVault`</mark> right afterwards.


Consider making <mark>`ensureTokenIsRegistered`</mark> return the token's <mark>`assetId`</mark> by using the

return parameter of <mark>`_registerToken`</mark> when the token is not already registered.

### **N-07 Duplicate Import**


Duplicate imports can negatively impact code clarity. In <mark>`BridgeHub.sol`</mark> <mark>,</mark> the

<u><mark>`[CTMNotRegistered](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridgehub/Bridgehub.sol#L25C101-L25C117)`</mark></u> custom error is imported twice.


Consider removing the duplicate import to improve code clarity and maintainability.


ZKChain Release Candidate Audit − Notes & Additional Information − 12


### **N-08 Unused Custom Errors**

Unused code can negatively impact code clarity. Throughout the codebase, multiple instances

of unused custom errors were identified:


<mark>`L1BridgehubErrors.sol`</mark> <mark>:</mark>









<u><mark>`[AssetIdAlreadyRegistered](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridgehub/L1BridgehubErrors.sol#L18)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[L1ContractsErrors.sol](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L35)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[ChainIdNotRegistered](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/bridgehub/L1BridgehubErrors.sol#L24)`</mark></u> <mark>:</mark> a similar error is defined in <u><mark>`[L1ContractsErrors.sol](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L65)`</mark></u> <mark>,</mark>

which is the only one used within the codebase.



<mark>`L1ContractsErrors.sol`</mark> <mark>:</mark>































<u><mark>`[InvalidPubDataHash](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L129)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[L1StateTransitionErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/da-contracts/contracts/DAContractsErrors.sol#L38)`</mark></u>

and <u><mark>`[DAContractsErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/da-contracts/contracts/DAContractsErrors.sol#L38)`</mark></u> <mark>,</mark> which are the only ones used within the codebase.

<u><mark>`[InvalidTxType](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L135)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L34)`</mark></u> <mark>,</mark> which is the

only one used within the codebase.

<u><mark>`[L2UpgradeNonceNotEqualToNewProtocolVersion](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L141)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L12)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[NewProtocolMajorVersionNotZero](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L165)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L18)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[PatchCantSetUpgradeTxn](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L199)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L10)`</mark></u> <mark>,</mark>

which is the only one used within the codebase.

<u><mark>`[PatchUpgradeCantSetBootloader](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L201)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L26)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[PatchUpgradeCantSetDefaultAccount](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L203)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L24)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[PreviousProtocolMajorVersionNotZero](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L207)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L16)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[PreviousUpgradeNotCleaned](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L209)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L30)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[PreviousUpgradeNotFinalized](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L211)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L28)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[ProtocolVersionMinorDeltaTooBig](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L221)`</mark></u> <mark>:</mark> the same error is defined in

<u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L20)`</mark></u> <mark>,</mark> which is the only one used within the codebase.

<u><mark>`[ProtocolVersionTooSmall](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L223)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[ZkSyncUpgradeErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L14)`</mark></u> <mark>,</mark>

which is the only one used within the codebase.

<u><mark>`[PubdataCommitmentsEmpty](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L225)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[DAContractsErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/da-contracts/contracts/DAContractsErrors.sol#L5)`</mark></u> <mark>,</mark>

which is the only one used within the codebase.


ZKChain Release Candidate Audit − Notes & Additional Information − 13


<u><mark>`[NotEnoughGas](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L183)`</mark></u> <mark>:</mark> never used within the codebase.



<mark>`L2ContractErrors.sol`</mark> <mark>:</mark>







<u><mark>`[WithdrawFailed](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l2-contracts/contracts/errors/L2ContractErrors.sol#L24)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[L1ContractsErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L291)`</mark></u> <mark>,</mark> which is the

only one used within the codebase.



<mark>`SystemContractsErrors.sol`</mark> <mark>:</mark>












<u><mark>`[HashMismatch](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/system-contracts/contracts/SystemContractErrors.sol#L38)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[L1ContractsErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L109)`</mark></u> <mark>,</mark> which is the only

one used within the codebase.

<u><mark>`[NonIncreasingTimestamp](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/system-contracts/contracts/SystemContractErrors.sol#L72)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[L1ContractsErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L177)`</mark></u> <mark>,</mark>

which is the only one used within the codebase.

<u><mark>`[NotEnoughGas](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L183)`</mark></u> <mark>:</mark> never used within the codebase.

<u><mark>`[TooMuchGas](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/system-contracts/contracts/SystemContractErrors.sol#L194)`</mark></u> <mark>:</mark> the same error is defined in <u><mark>`[L1ContractsErrors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L265)`</mark></u> <mark>,</mark> which is the only

one used within the codebase.



<mark>`ZkSyncUpgradeErrors.sol`</mark> <mark>:</mark>







<u><mark>`[ZeroAddress](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L38)`</mark></u> <mark>:</mark> never used within the codebase.



Consider removing or using any currently unused custom errors to improve the clarity and

maintainability of the codebase.

### **N-09 Naming Suggestions**


Throughout the codebase, multiple opportunities for improved contract and custom error

naming were identified:













The <mark>`AddressAlreadyUsed`</mark> and <mark>`AddressAlreadySet`</mark> <u>[errors](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L21-L23)</u> defined in

<mark>`L1ContractErrors.sol`</mark> are similar and can be merged together.

The <u><mark>`[L2GatewayUpgradeHelper](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/system-contracts/contracts/L2GatewayUpgradeHelper.sol#L20)`</mark></u> library is used as a helper contract during the genesis

upgrade for both Gateway and ZKChains. Consider renaming it to

<mark>`L2GenesisUpgradeHelper`</mark> for improved clarity.

The name of the <u><mark>`[L1GatewayBase](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/upgrades/L1GatewayBase.sol#L20)`</mark></u> abstract contract implies that it serves as a base

contract for Gateway. However, it is inherited by <mark>`GatewayUpgrade`</mark> and

<mark>`L1GenesisUpgrade`</mark> contracts, providing functionality to retrieve some necessary data

during the genesis upgrade process. Consider renaming <mark>`L1GatewayBase`</mark> to a name

that more accurately reflects its role.

The <u><mark>`[TokenNotLegacy](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L358)`</mark></u> and <u><mark>`[TokenIsNotLegacy](https://github.com/matter-labs/era-contracts/blob/e3dd33ceee8f803510cbd0debb8ed55fef4007e8/l1-contracts/contracts/common/L1ContractErrors.sol#L364)`</mark></u> errors defined in

<mark>`L1ContractErrors.sol`</mark> are similar and can be merged.


ZKChain Release Candidate Audit − Notes & Additional Information − 14


Consider renaming any contracts or custom errors whose current name does not clearly

indicate their functionality or usage.


ZKChain Release Candidate Audit − Notes & Additional Information − 15


## **Conclusion**

This diff audit mostly covers the fixes and code improvements that were made in response to

the findings and suggestions of previous audits. Several low- and note-severity issues have

been reported to improve the clarity of the codebase and facilitate future audits, integrations,

and development. The Matterlabs team has been responsive throughout the engagement,

providing useful explanations and insights whenever needed.


ZKChain Release Candidate Audit − Conclusion − 16


