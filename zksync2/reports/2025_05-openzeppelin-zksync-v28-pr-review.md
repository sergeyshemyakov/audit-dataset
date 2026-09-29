### | security

# **Pull Request** **#1436 Review**

#### **May 2, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


Overview _________________________________________________________________________  4


Reported Issue ____________________________________________________________________  4

Withdrawing A Chain Back To L1 May Fail 4


Issue and Fix Analysis ______________________________________________________________  5

Upgrade Process 5

Backward-Compatibility Issue 5


Conclusion - Fix Review ____________________________________________________________  8


Pull Request #1436 Review − Table of Contents − 2


## **Summary**

**Type** Cross-Chain


**Timeline** From 2025-04-28
To 2025-04-29


**Languages** Solidity



Pull Request #1436 Review − Summary − 3


## **Scope**

[OpenZeppelin audited pull request #1436](https://github.com/matter-labs/era-contracts/pull/1436) [of the matter-labs/era-contracts/](https://github.com/matter-labs/era-contracts/) repository.


In scope were the following files:

```
era-contracts/l1-contracts/contracts/upgrades/
- BaseZkSyncUpgrade.sol
- BaseZkSyncUpgradeGenesis.sol
- ZkSyncUpgradeErrors.sol

## **Overview**

```

On April 28th, the Matter Labs team informed OpenZeppelin about a potential vulnerability in

the code that handles ZKChain migration between settlement layers. Subsequently, a 2-day

review of <u>[pull request #1436](https://github.com/matter-labs/era-contracts/pull/1436)</u> was conducted to validate the correctness and security outlook of

the fix that had been implemented to address this issue. The review team confirmed that <u>[pull](https://github.com/matter-labs/era-contracts/pull/1436)</u>

<u>[request #1436](https://github.com/matter-labs/era-contracts/pull/1436)</u> had correctly fixed the identified issue.

## **Reported Issue**


The Matter Labs team described the issue in the following manner:

### **Withdrawing A Chain Back To L1 May Fail**


_We generally expect that once a chain migrates to Gateway, it will still have to maintain_

_the two diamond proxies: on GW and on L1. If a chain is migrated back to L1 at some_

_[point, it would require to have the same protocol version in both places (on GW and on](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L317)_

_L1). But when our chain migrates away from L1, its upgrade data is written in the data to_

_[be moved to GW, while it is preserved on L1. So when we will try to upgrade the L1](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L421-L422)_

_[diamond proxy of the migrated chain, a revert will happen since laying one upgrade](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L287-L296)_


Pull Request #1436 Review − Scope − 4


_transaction on top of another is prevented. Consequently, if a chain with upgrade data_

_migrates on top of GW and after that another upgrade happens, there is no way to_

_return to L1._


_We believe that it is secure to keep_ _<mark>`AdminFacet`</mark>_ _as is, and we should modify_

_<mark>`DefaultUpgrade`</mark>_ _so that if the chain is not on settlement layer then nothing related to_

_upgrade transactions should be enforced._

## **Issue and Fix Analysis**

### **Upgrade Process**


In order to understand the reported issue, it is worth describing some key points of the typical

procedure that is followed when upgrading L2 system contracts. Hence, let us assume that L1

is the only Settlement Layer (SL).


When a protocol upgrade is performed on a chain, it is important to ensure that the protocol

version on both L2 and L1 remains the same. So, when an <u>[upgrade](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L68)</u> takes place on L1, it must

be ensured that the same upgrade also takes place on L2. For this reason, upon an upgrade on

L1, the transaction hash of the protocol upgrade is <u>[stored](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L231)</u> in the chain's Diamond Proxy (DP)

storage. Afterward, it is expected that the L2 upgrade TX <u>[will be processed](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L302-L308)</u> in the upcoming

submitted batch. During this processing, it is <u>[checked](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L246)</u> that the stored upgrade hash equals the

cross-chain transaction's log.

### **Backward-Compatibility Issue**


With the introduction of the Gateway (GW), it is now possible to migrate a chain's SL between

L1 and GW. Regarding the upgrade process described above, this means that, at any given

time, the currently "active" SL will be processing the L2 batches and will, thus, be enforcing the

protocol version synchronization upon upgrades. However, note that in order to migrate a chain

to an SL, it is <u>[required](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L317-L318)</u> that its protocol version is up-to-date. This means that an "inactive" SL

still needs to be upgraded to ensure that the chain is able to migrate back if needed.


Now, let us consider the following scenario which would make it impossible to upgrade the

inactive SL and, therefore, result in an inability to migrate the chain back.


Pull Request #1436 Review − Issue and Fix Analysis − 5


Consider a chain that settles on L1 and is upgraded at some point. Now, consider the specific

point in time at which the L1 upgrade had been performed. The upgrade data has been stored

in the chain's L1 DP while the L2 batch containing the L2 upgrade TX has been committed on

L1 but has not yet been finalized. At this point, the chain is migrated to GW along with all of its

DP data, including the upgrade data.


Note that the chain had been migrated before the upgrade TX was finalized on L1. This means

that the stored data which denotes a pending state on the L2 upgrade <u>[will remain uncleared on](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L512-L514)</u>

<u>[L1](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L512-L514)</u> even if the corresponding batch has been finalized on GW. As a consequence, it will be

<u>[impossible](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L287-L296)</u> to perform another upgrade on L1. So, in case another upgrade is performed on the

GW, the chain <u>[will not be able to migrate back](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L317)</u> to L1 because of the outdated protocol version.


The above scenario is the issue described by the Matter Labs. Note that this is only one of the

possible scenarios that culminate in failing chain migration. Another possible scenario is

upgrading a migrated chain more than once, but not being able to upgrade the "inactive" SL

more than once because of the pending L2 batch processing. It should also be noted that the

issue may apply to any SL from which a chain has migrated.


The review team estimates this issue to be of medium severity because it may disable an SL if

specific upgrade actions take place without any funds being at risk (at least not immediately).


Pull Request #1436 Review − Issue and Fix Analysis − 6


Pull Request #1436 Review − Issue and Fix Analysis − 7


## **Conclusion - Fix Review**

Pull request #1436 addresses the issue by updating the upgrade-related code so that <u>[no](https://github.com/matter-labs/era-contracts/blob/3611880d183ae2cc4654ec39ee016f649d4ef674/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L105-L106)</u>

<u>[further actions are required](https://github.com/matter-labs/era-contracts/blob/3611880d183ae2cc4654ec39ee016f649d4ef674/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L105-L106)</u> when the upgrade is performed on an inactive SL. The standard

process whereby the consistency of the upgrade transaction hash is verified through the

chain's batch commitment still takes place on the active SL.


The current solution, as embodied by pull request #1436, assumes that for the upgrades in the

inactive SL, the consistency of the upgrade transaction and data are guaranteed by the CTM's

<u>[owner](https://github.com/matter-labs/era-contracts/blob/8222265420f362c853da7160769620d9fed7f834/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L237-L242)</u> who is responsible for performing the upgrades. This trust assumption is reasonable

considering that governance is the CTM's owner. However, extra caution is required to ensure

the correctness of the data provided by governance. The fix also ensures that a genesis

upgrade is <u>[only possible](https://github.com/matter-labs/era-contracts/blob/3611880d183ae2cc4654ec39ee016f649d4ef674/l1-contracts/contracts/upgrades/BaseZkSyncUpgradeGenesis.sol#L57-L58)</u> on the active SL.


Pull Request #1436 Review − Conclusion - Fix Review − 8


