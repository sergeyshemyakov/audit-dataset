### | security

# **ZKChain:** **Upgrades and** **Libraries Diff** **Audit**

#### **October 28, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  6

Genesis Upgrade 6

ZKsync Era Gateway Upgrade 6

Gateway Transaction Filterer 6


Security Model and Trust Assumptions _______________________________________________  7

Privileged Roles 7


Medium Severity ___________________________________________________________________  8

M-01 GatewayUpgrade Caller Validation Fails 8


Low Severity ______________________________________________________________________  8

L-01 Unnecessary Initializable Inheritance in GatewayUpgrade 8

L-02 Unnecessary Legacy Check For Chain Migration 9

L-03 The Name L2Messenger Is Misleading 9

L-04 Missing or Incomplete Docstrings 10

L-05 Unused Code 11


Notes & Additional Information ____________________________________________________ 12

N-01 TODO Comments in the Code 12

N-02 Legacy Naming 12

N-03 Unnecessary Code 12

N-04 Unsafe ABI Encoding 13

N-05 Unnecessary Cast 13

N-06 Typographical Errors 13

N-07 Misleading Documentation 14


Conclusion ______________________________________________________________________ 15


ZKChain: Upgrades and Libraries Diff Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2024-10-14
To 2024-10-23


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



**Total Issues** 13 (12 resolved)



**Low Severity Issues** 5 (4 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



7 (7 resolved)


0 (0 resolved)



ZKChain: Upgrades and Libraries Diff Audit − Summary − 3


## **Scope**

We audited <u>[pull request #793](https://github.com/matter-labs/era-contracts/pull/793)</u> of the <u>[matter-labs/era-contracts](https://github.com/matter-labs/era-contracts)</u> repository at commit <u>[8208402.](https://github.com/matter-labs/era-contracts/pull/793/commits/82084025addb869fed85b10e627aa4754cc6b9c0)</u>


From the list below, the files that were newly added were audited fully while the rest was only

audited as a diff against commit <u>[9615d90:](https://github.com/matter-labs/era-contracts/commit/9615d90)</u>

```
l1-contracts/contracts
├── common
|  ├── Config.sol
|  ├── L2ContractAddresses.sol
|  ├── L1ContractErrors.sol
|  ├── interfaces
|  │  └── IL2ContractDeployer.sol
|  ├── libraries
|  |  ├── DataEncoding.sol
|  |  ├── DynamicIncrementalMerkle.sol
|  |  ├── L2ContractHelper.sol
|  |  ├── Merkle.sol
|  |  ├── SystemContractsCaller.sol
|  |  └── UnsafeBytes.sol
├── upgrades
|  ├── BaseZkSyncUpgrade.sol
|  ├── BaseZkSyncUpgradeGenesis.sol
|  ├── IL1GenesisUpgrade.sol
|  ├── L1GenesisUpgrade.sol
|  ├── IGatewayUpgrade.sol
|  └── GatewayUpgrade.sol
├── vendor
|  └── AddressAliasHelper.sol
└── transactionFilterer
└── GatewayTransactionFilterer.sol

l2-contracts/contracts
├── L2ContractHelper.sol
└── errors
└── L2ContractErrors.sol

system-contracts
├── bootloader
|  └── bootloader.yul
└── contracts
├── Constants.sol
├── L1Messenger.sol
├── L2GenesisUpgrade.sol
├── PubdataChunkPublisher.sol
├── SystemContractErrors.sol
├── interfaces
│  └── IMessageRoot.sol

```

ZKChain: Upgrades and Libraries Diff Audit − Scope − 4


```
└── libraries
└── SystemContractHelper.sol

```


ZKChain: Upgrades and Libraries Diff Audit − Scope − 5


## **System Overview**

The changeset under review mainly consists of updates in service of the newly implemented

custom bridging framework and chain migration to the Gateway. Due to the newly set bridging

mechanism with <mark>`L2NativeTokenVault`</mark> and <mark>`L2AssetRouter`</mark> <mark>,</mark> some L2 system

functionalities are included in the <mark>`l1-contracts`</mark> libraries to facilitate testing as well as L2

force deployment during the genesis upgrade.


A <mark>`GatewayUpgrade`</mark> contract is newly developed to upgrade the ZKsync Era chain to be part

of the ZKChain ecosystem contracts. Furthermore, a newly added

<mark>`GatewayTransactionFilterer`</mark> contract for the L1 Gateway Mailbox imposes restrictions

of bridging to the Gateway to only chain migration purposes. We elaborate below on these

aspects.

### **Genesis Upgrade**


When creating a new chain via L1's Bridgehub, the <mark>`L1GenesisUpgrade`</mark> is delegate called

from the newly deployed chain's Diamond Proxy to initiate protocol upgrade with an

<mark>`L2GenesisUpgrade`</mark> transaction to force deploy and initiate the corresponding

<mark>`L2BridgeHub`</mark> <mark>,</mark> <mark>`L2AssetRouter`</mark> <mark>,</mark> <mark>`L2NativeTokenVault`</mark> as well as <mark>`L2MessageRoot`</mark> <mark>.</mark>

### **ZKsync Era Gateway Upgrade**


The <u><mark>`[GatewayUpgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L23)`</mark></u> <u>contract</u> is used to migrate ZKsync Era to be part of the ZKChain

ecosystem contracts by initializing its <u><mark>`[baseTokenAssetId](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L41C9-L42C69)`</mark></u> <u>[and the](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L41C9-L42C69)</u> <u><mark>`[priorityTree](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L41C9-L42C69)`</mark></u> on L1.

Additionally, it facilitates the force deployment of the L2 bridging contracts, such as

<mark>`L2AssetRouter`</mark> <mark>,</mark> with Era-specific constructor arguments.

### **Gateway Transaction Filterer**


The <u><mark>`[GatewayTransactionFilterer](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/transactionFilterer/GatewayTransactionFilterer.sol)`</mark></u> <u>contract</u> is meant to be deployed on L1 and attached

to the Gateway's diamond proxy. It filters out all bridging transactions via <mark>`L1AssetRouter`</mark>

that are not for chain migration purposes. This will not block any relayed bridging transactions

for chains that settle on the Gateway.


ZKChain: Upgrades and Libraries Diff Audit − System Overview − 6


## **Security Model and Trust** **Assumptions**

### **Privileged Roles**

In relation to the changeset, the following privileged roles can perform critical functionality:


   - The owner of the <mark>`GatewayTransactionFilterer`</mark> contract can <u>[add or remove](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/transactionFilterer/GatewayTransactionFilterer.sol#L51C5-L69C6)</u>

<u>[addresses](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/transactionFilterer/GatewayTransactionFilterer.sol#L51C5-L69C6)</u> from the set allowed to send transactions to the Gateway chain.

   - The <u><mark>`[proposedUpgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L35)`</mark></u> <u>L2 transaction</u> passed to the <u><mark>`[GatewayUpgrade.upgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L35)`</mark></u>

<u>[function](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L35)</u> comes from the usual upgrade process and hence, it is constructed off-chain

with force deployment data. The governance is trusted to thoroughly verify the

<mark>`ProposedUpgrade`</mark> data before approving it.


We assume that the accounts in charge of the above actions always act in the intended way.

Hence, any attacks or vulnerabilities targeting this part of the system were not considered

throughout this audit.


ZKChain: Upgrades and Libraries Diff Audit − Security Model and Trust

Assumptions − 7


## **Medium Severity**

### **M-01 GatewayUpgrade Caller Validation Fails**

The <mark>`GatewayUpgrade`</mark> contract is designed to facilitate the migration of the ZKsync Era chain

to be part of the ZKchain ecosystem contracts. The upgrade transaction will revert <u>[when](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L63)</u>

<u>[validating the caller, as the](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L63)</u> <mark>`msg.sender`</mark> can not be the chain's diamond proxy contract. The

upgrade goes through the <u><mark>`[AdminFacet](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L167C5-L192C6)`</mark></u> <u>[upgrade functions](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L167C5-L192C6)</u> and thus the <mark>`msg.sender`</mark> is

either the <mark>`chainAdmin`</mark> or the <mark>`ChainTypeManager`</mark> contract.


Since the <mark>`GatewayUpgrade`</mark> is just the logic contract being delegate called by the diamond

proxy, it is not necessary to have access control on this contract. Consider removing the afore
mentioned check, as the upgrade functions of the <mark>`AdminFacet`</mark> have already implemented

the necessary access control restrictions.


**_Update:_** _Resolved in_ _<u>[pull request #981.](https://github.com/matter-labs/era-contracts/pull/981)</u>_

## **Low Severity**

### **L-01 Unnecessary Initializable Inheritance in** **`GatewayUpgrade`**


The <mark>`GatewayUpgrade`</mark> contract contains the logic for migrating the ZKsync Era chain to be

part of the ZKchain ecosystem. Since <mark>`GatewayUpgrade`</mark> is only used as a logic contract

called through <mark>`delegateCall`</mark> and requires no initialization, there is no need to inherit the

<u><mark>`[Initializable](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L23)`</mark></u> <u>contract.</u>


To reduce gas costs and remove any potential confusions when reading the contract, consider

removing the <mark>`Initializable`</mark> inheritance.


**_Update:_** _Resolved in_ _<u>[pull request #983.](https://github.com/matter-labs/era-contracts/pull/983)</u>_


ZKChain: Upgrades and Libraries Diff Audit − Medium Severity − 8


### **L-02 Unnecessary Legacy Check For Chain** **Migration**

The <mark>`GatewayTransactionFilterer`</mark> contract is designed to filter transactions directed

towards the gateway. Specifically, when the transaction sender is identified as

<mark>`L1_ASSET_ROUTER`</mark> <mark>,</mark> the contract restricts allowed calls exclusively to those with

<mark>`finalizeDeposit`</mark> signatures. Among these, only transactions related to chain migration are

permitted.


However, it is not necessary to check the <u>[IL2Bridge.finalizeDeposit](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/transactionFilterer/GatewayTransactionFilterer.sol#L87)</u> decoding for two reasons:


1. The encoding associated with this function is different from the <u>[legacy interface](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/bridge/asset-router/L2AssetRouter.sol#L205)</u> utilized

by the L2AssetRouter. Consequently, the <mark>`finalizeDeposit`</mark> function, as referenced,

does not actually exist within the current framework.


2. It is not possible to encode a chain migration transaction with <u><mark>`[L1AssetRouter](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L428C9-L440C10)`</mark></u> <u>legacy</u>

<u>[calldata encoding. This is because a](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L428C9-L440C10)</u> <mark>`ctmAssetId`</mark> will invariably have its

<u><mark>`[tokenAddress](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/bridge/asset-router/L1AssetRouter.sol#L424)`</mark></u> set to zero on <mark>`L1NativeTokenVault`</mark> <mark>,</mark> therefore always leading to the

encoding inside the <mark>`if`</mark> block.


Consider filtering out the legacy encoding by removing the check against

<u>[IL2Bridge.finalizeDeposit.selector.](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/transactionFilterer/GatewayTransactionFilterer.sol#L87)</u>


**_Update:_** _Resolved in_ _<u>[pull request #1000.](https://github.com/matter-labs/era-contracts/pull/1000/files)</u>_

### **L-03 The Name L2Messenger Is Misleading**


There are many L2 system contract addresses defined inside the

<mark>`L2ContractAddresses.sol`</mark> file, each referring to a system contract force deployed on the

zkEVM. In particular, on the <mark>`0x8008`</mark> address there is contract <u><mark>`[L1Messenger](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/L1Messenger.sol#L28)`</mark></u> <mark>,</mark> responsible for

passing messages and logs from L2 to L1.


It is confusing when the <u><mark>`[L2_MESSENGER](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L2ContractAddresses.sol#L82C23-L82C35)`</mark></u> is in fact referring to the <mark>`L1Messenger`</mark> <mark>,</mark> whose

address is defined earlier as <u><mark>`[L2_TO_L1_MESSENGER_SYSTEM_CONTRACT_ADDR](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L2ContractAddresses.sol#L24)`</mark></u> <mark>.</mark> In the event

of further L2<>L2 communication, there could be a future <mark>`L2Messenger`</mark> as distinguished

from <mark>`L1Messenger`</mark> on the system contract.


In addition, the interface <u><mark>`[IL2Messenger](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L2ContractAddresses.sol#L60-L65)`</mark></u> is the same as <u><mark>`[IL1Messenger](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/interfaces/IL1Messenger.sol#L9)`</mark></u> <mark>.</mark> The instance

where <u><mark>`[L2_MESSENGER](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/libraries/L2ContractHelper.sol#L56)`</mark></u> is used can be replaced by existing <mark>`IL1Messenger`</mark> instead.


ZKChain: Upgrades and Libraries Diff Audit − Low Severity − 9


When referring to the <mark>`L1Messenger`</mark> system contract, consider using the already existing

code such as <mark>`IL1Messenger(L2_TO_L1_MESSENGER_SYSTEM_CONTRACT_ADDR)`</mark> <mark>,</mark> instead

of <mark>`L2_MESSENGER`</mark> and <mark>`IL2Messenger`</mark> <mark>.</mark>


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_Acknowledged. We use different names depending on the context (L2 or L1 contracts)._

_We will add this change to one of the next refactoring releases._

### **L-04 Missing or Incomplete Docstrings**


Throughout the codebase, multiple instances of missing or incomplete docstrings were

identified. For instance,


   - In <mark>`IL1GenesisUpgrade.sol`</mark> <mark>,</mark> the <mark>`_zkChain`</mark> <mark>,</mark> <mark>`_l2Transaction`</mark> <mark>,</mark>

<mark>`_protocolVersion`</mark> and <mark>`_factoryDeps`</mark> parameters of the <u><mark>`[GenesisUpgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/IL1GenesisUpgrade.sol#L9-L14)`</mark></u>

event are not documented.

   - In <mark>`IL2ContractDeployer.sol`</mark> <mark>,</mark> the <mark>`_deployParams`</mark> parameter of the

<u><mark>`[forceDeployOnAddresses](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/interfaces/IL2ContractDeployer.sol#L25)`</mark></u> function is not documented.

   - In <mark>`L1GenesisUpgrade.sol`</mark> <mark>,</mark> the <mark>`_l1GenesisUpgrade`</mark> <mark>,</mark> <mark>`_chainId`</mark>,

<mark>`_protocolVersion`</mark> <mark>,</mark> <mark>`_l1CtmDeployerAddress`</mark> <mark>,</mark> <mark>`_forceDeploymentsData`</mark> and

<mark>`_factoryDeps`</mark> parameters of the <u><mark>`[genesisUpgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/L1GenesisUpgrade.sol#L25-L97)`</mark></u> function are not documented.

   - In <mark>`L1Messenger.sol`</mark> <mark>,</mark> the <mark>`_l2DAValidator`</mark> parameter of the

<u><mark>`[publishPubdataAndClearState](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/L1Messenger.sol#L197-L346)`</mark></u> function is not documented.

   - In <mark>`GatewayUpgrade.sol`</mark> <mark>,</mark> the <u><mark>`[THIS_ADDRESS](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L27)`</mark></u> <u>state variable</u> is not documented.

   - In <mark>`IGatewayUpgrade.sol`</mark> <mark>,</mark> the <u><mark>`[IGatewayUpgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/IGatewayUpgrade.sol#L7-L9)`</mark></u> <u>interface</u> is not documented.

   - In <mark>`IGatewayUpgrade.sol`</mark> <mark>,</mark> the <u><mark>`[upgradeExternal](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/IGatewayUpgrade.sol#L8)`</mark></u> <u>function</u> is not documented.

   - In <mark>`IL1GenesisUpgrade.sol`</mark> <mark>,</mark> the <u><mark>`[IL1GenesisUpgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/IL1GenesisUpgrade.sol#L7-L24)`</mark></u> <u>interface</u> is not

documented.

   - In <mark>`IL1GenesisUpgrade.sol`</mark> <mark>,</mark> the <u><mark>`[genesisUpgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/IL1GenesisUpgrade.sol#L16-L23)`</mark></u> <u>function</u> is not documented.

   - In <mark>`IMessageRoot.sol`</mark> <mark>,</mark> the <u><mark>`[IMessageRoot](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/interfaces/IMessageRoot.sol#L5-L7)`</mark></u> <u>interface</u> is not documented.

   - In <mark>`IMessageRoot.sol`</mark> <mark>,</mark> the <u><mark>`[getAggregatedRoot](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/interfaces/IMessageRoot.sol#L6)`</mark></u> <u>function</u> is not documented.

   - In <mark>`L2ContractHelper.sol`</mark> <mark>,</mark> the <u><mark>`[getNewAddressCreate2](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l2-contracts/contracts/L2ContractHelper.sol#L58-L63)`</mark></u> <u>function</u> is not

documented.

   - In <mark>`L2ContractHelper.sol`</mark> <mark>,</mark> the <u><mark>`[verifyCompressedStateDiffs](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l2-contracts/contracts/L2ContractHelper.sol#L85-L90)`</mark></u> <u>function</u> is not

documented.

   - In <mark>`L2GenesisUpgrade.sol`</mark> <mark>,</mark> the <u><mark>`[genesisUpgrade](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/L2GenesisUpgrade.sol#L15-L51)`</mark></u> <u>function</u> is not documented.


ZKChain: Upgrades and Libraries Diff Audit − Low Severity − 10


Additionally, because some upgrade functions do not have a standard invocation flow and are

often a chain of <mark>`delegatecall`</mark> <mark>,</mark> it would greatly improve the understanding and clarity of

code for both auditors and developers if the invocation paths would be indicated directly in the

documentation of each function.


**_Update:_** _Resolved in_ _<u>[pull request #999.](https://github.com/matter-labs/era-contracts/pull/999)</u>_

### **L-05 Unused Code**


Throughout the codebase there are several parts which are unused:


   - The <u><mark>`[InsufficientAllowance](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L1ContractErrors.sol#L142)`</mark></u> <mark>,</mark> <u><mark>`[InvalidInput](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L1ContractErrors.sol#L158)`</mark></u> <mark>,</mark> <u><mark>`[PubdataIsEmpty](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L1ContractErrors.sol#L392)`</mark></u> <mark>,</mark>

<u><mark>`[UnimplementedMessage](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L1ContractErrors.sol#L362)`</mark></u> and <u><mark>`[UnsupportedPaymasterFlow](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L1ContractErrors.sol#L368)`</mark></u> errors of the

<mark>`L1ContractErrors.sol`</mark> file.


   - The <u><mark>`[AddressMismatch](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l2-contracts/contracts/errors/L2ContractErrors.sol#L6)`</mark></u> <mark>,</mark> <u><mark>`[AssetIdMismatch](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l2-contracts/contracts/errors/L2ContractErrors.sol#L7)`</mark></u> <mark>,</mark> <u><mark>`[DeployFailed](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l2-contracts/contracts/errors/L2ContractErrors.sol#L11)`</mark></u> <mark>,</mark> <u><mark>`[EmptyBytes32](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l2-contracts/contracts/errors/L2ContractErrors.sol#L15)`</mark></u> <mark>,</mark>

<u><mark>`[InvalidCaller](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l2-contracts/contracts/errors/L2ContractErrors.sol#L21)`</mark></u> <mark>,</mark> <u><mark>`[NonSequentialVersion](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l2-contracts/contracts/errors/L2ContractErrors.sol#L25)`</mark></u> <mark>,</mark> <u><mark>`[UnimplementedMessage](https://github.com/matter-labs/era-contracts/blob/d158962664aa1e6eaf583964ee6cf99eb4e9ac47/l2-contracts/contracts/errors/L2ContractErrors.sol#L31)`</mark></u> errors of

the <mark>`L2ContractErrors.sol`</mark> file.


   - The <u><mark>`[readUint128](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/libraries/UnsafeBytes.sol#L33)`</mark></u> <u>function.</u>


   - The <u><mark>`[PubdataChunkPublisher](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/PubdataChunkPublisher.sol#L14)`</mark></u> <u>contract</u> does not use functionality inherited from the

<mark>`SystemContractBase`</mark> contract, and hence does not require this inheritance.


To make the code easier to read and save some gas costs at deployment time, consider

removing the above mentioned instances of unused code.


**_Update:_** _Resolved in_ _<u>[pull request #995.](https://github.com/matter-labs/era-contracts/pull/995)</u>_


ZKChain: Upgrades and Libraries Diff Audit − Low Severity − 11


## **Notes & Additional** **Information**

### **N-01 TODO Comments in the Code**

Throughout the codebase, multiple instances of TODO/Fixme comments were found. For

instance:


   - The <mark>`TODO`</mark> comment in <u>line 21 of</u> <u><mark>`[Config.sol](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/Config.sol#L21)`</mark></u> <mark>.</mark>

   - The <mark>`todo`</mark> comment in <u>line 128 of</u> <u><mark>`[DataEncoding.sol](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/libraries/DataEncoding.sol#L128)`</mark></u> <mark>.</mark>


Consider removing all instances of TODO/Fixme comments and instead tracking them in the

issues backlog. Alternatively, consider linking each inline TODO/Fixme to the corresponding

issues backlog entry.


**_Update:_** _Resolved in_ _<u>[pull request #994. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/994)</u>_


_We removed_ _<mark>`todo`</mark>_ _from DataEncoding, the_ _<mark>`todo`</mark>_ _in Config.sol is linked to SMA-184._

### **N-02 Legacy Naming**


An instance of legacy naming is identified below:


   - <u>[stmAddress](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/transactionFilterer/GatewayTransactionFilterer.sol#L93)</u> should be "ctmAddress".


Consider updating it for consistency and clarity.


**_Update:_** _Resolved in_ _<u>[pull request #991.](https://github.com/matter-labs/era-contracts/pull/991)</u>_

### **N-03 Unnecessary Code**


There are several instances where code is duplicated and therefore unnecessary:


   - The <u><mark>`[DEPLOYER_SYSTEM_CONTRACT](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L2ContractAddresses.sol#L79)`</mark></u> <u>address</u> is the same as

<u><mark>`[L2_FORCE_DEPLOYER_ADDR](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L2ContractAddresses.sol#L12)`</mark></u> <mark>,</mark> consider removing one of them.


   - The <u><mark>`[IL2ContractDeployer](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/interfaces/IL2ContractDeployer.sol)`</mark></u> file can be deleted as the same interface but with a

different name <mark>`IContractDeployer`</mark> exists within <u><mark>`[L2ContractHelper](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/libraries/L2ContractHelper.sol#L15)`</mark></u> <mark>.</mark>


ZKChain: Upgrades and Libraries Diff Audit − Notes & Additional Information

                                                - 12


**_Update:_** _Resolved in_ _<u>[pull request #990.](https://github.com/matter-labs/era-contracts/pull/990)</u>_

### **N-04 Unsafe ABI Encoding**


It is not an uncommon practice to use <mark>`abi.encodeWithSignature`</mark> or

<mark>`abi.encodeWithSelector`</mark> to generate calldata for a low-level call. However, the first

option is not typo-safe and the second option is not type-safe. The result is that both of these

methods are error-prone and should be considered unsafe.


The use of <u><mark>`[abi.encodeWithSelector](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L53)`</mark></u> within <u><mark>`[GatewayUpgrade.sol](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol)`</mark></u> is unsafe.


Consider replacing all the occurrences of unsafe ABI encodings with <mark>`abi.encodeCall`</mark> which

checks whether the supplied values actually match the types expected by the called function

and also avoids errors caused by typos.


**_Update:_** _Resolved in_ _<u>[pull request #989.](https://github.com/matter-labs/era-contracts/pull/989)</u>_

### **N-05 Unnecessary Cast**


Within the <mark>`SystemContractsCaller`</mark> contract, the

<u><mark>`[uint32(Utils.safeCastToU32(data.length))](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/libraries/SystemContractsCaller.sol#L51)`</mark></u> cast is unnecessary. Consider removing

it.


**_Update:_** _Resolved in_ _<u>[pull request #988.](https://github.com/matter-labs/era-contracts/pull/988)</u>_

### **N-06 Typographical Errors**


Consider correcting the following typographical errors in the codebase:




- <u><mark>`[asse3t](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/L2ContractAddresses.sol#L72)`</mark></u> should be <mark>`asset`</mark> <mark>.</mark>

- <u><mark>`[L2_BRIDDGE_HUB](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/Constants.sol#L77)`</mark></u> should be <mark>`L2_BRIDGE_HUB`</mark> and all instances of imported use in

the <u>[L2GenesisUpgrade.sol](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/L2GenesisUpgrade.sol#L5C60-L5C74)</u> contract.




- <u><mark>`[Progapatate](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/system-contracts/contracts/L2GenesisUpgrade.sol#L44)`</mark></u> should be <mark>`Propagate`</mark> <mark>.</mark>



**_Update:_** _Resolved in_ _<u>[pull request #987.](https://github.com/matter-labs/era-contracts/pull/987)</u>_


ZKChain: Upgrades and Libraries Diff Audit − Notes & Additional Information

                                                - 13


### **N-07 Misleading Documentation**

Below are two instances of misleading documentation:


  - The comment on top of the <u><mark>`[decodeTokenData](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/common/libraries/DataEncoding.sol#L123)`</mark></u> <u>function</u> mentions that the encoding of

<mark>`_tokenData`</mark> contains the asset deployment tracker, which is not the case as it is

encoded from the name, symbol and decimals with or without a chainId. Consider

removing it.

   - The use of <u><mark>`[upgrade proxy](https://github.com/matter-labs/era-contracts/blob/82084025addb869fed85b10e627aa4754cc6b9c0/l1-contracts/contracts/upgrades/GatewayUpgrade.sol#L33)`</mark></u> <u>naming</u> causes confusion as the upgrade functions are

meant to be invoked via the <mark>`Admin`</mark> facet of the chain's diamond proxy. Consider

removing references to <mark>`upgrade proxy`</mark> for clarity.


**_Update:_** _Resolved in_ _<u>[pull request #986.](https://github.com/matter-labs/era-contracts/pull/986)</u>_


ZKChain: Upgrades and Libraries Diff Audit − Notes & Additional Information

                                                - 14


## **Conclusion**

The changeset updates some library files and upgrade contracts in service of the newly

implemented custom bridging framework and chain migration to the Gateway. We appreciate

the Matter Labs team for their kind support during the audit particularly showing us the off
chain upgrade mechanism.


ZKChain: Upgrades and Libraries Diff Audit − Conclusion − 15


