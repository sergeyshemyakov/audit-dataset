# **Linea Mixed Upgrade Audit Report**

[Prepared by Cyfrin](https://cyfrin.io)


Version 2.0


**Lead Auditors**


[Dacian](https://x.com/DevDacian)


[Stalin](https://x.com/0xStalin)


March 27, 2026


## **Contents**

**1** **About Cyfrin** **2**


**2** **Disclaimer** **2**


**3** **Risk Classification** **2**


**4** **Protocol Summary** **2**


**5** **Audit Scope** **2**


**6** **Executive Summary** **3**


**7** **Findings** **13**
7.1 Critical Risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 13
7.1.1 After the upgrade permissionless attacker can fully drain the L1 `TokenBridge` of `ERC20` tokens
currently valued around $29M USD . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 13
7.2 Low Risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 15
7.2.1 `SECURITY_COUNCIL_ROLE` unpausing a type leads to automatically marking as expired any
other pause types, whether they were enacted by the `SECURITY_COUNCIL_ROLE` or not . . . . 15
7.3 Informational . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 16
7.3.1 `LineaRollup,` `LivenessRecovery::renounceRole` prevents liveness recovery operator
from renouncing all roles . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 16
7.3.2 `LivenessRecovery::setLivenessRecoveryOperator` will emit misleading event when role is
not granted . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 16
7.3.3 Inconsistent handling of update/set transactions which don't actually change values . . . . . 16
7.3.4 Not emitting event to log the version's change when reinitializing the `LineaRollup` contract . 18
7.3.5 Missing `onlyInitializing` modifier on initialization functions for abstract contracts . . . . . 18
7.3.6 Consider wiping slot 177 on Linea `L2MessageService` after upgrade . . . . . . . . . . . . . . 18


1


## **1 About Cyfrin**

Cyfrin is a Web3 security company dedicated to bringing industry-leading protection and education to our partners
and their projects. Our goal is to create a safe, reliable, and transparent environment for everyone in Web3 and
DeFi. [Learn more about us at cyfrin.io.](https://cyfrin.io)

## **2 Disclaimer**


The Cyfrin team makes every effort to find as many vulnerabilities in the code as possible in the given time but holds
no responsibility for the findings in this document. A security audit by the team does not endorse the underlying
business or product. The audit was time-boxed and the review of the code was solely on the security aspects of
the solidity implementation of the contracts.

## **3 Risk Classification**


**Impact:** **High** **Impact:** **Medium** **Impact:** **Low**


**Likelihood:** **High** Critical High Medium


**Likelihood:** **Medium** High Medium Low


**Likelihood:** **Low** Medium Low Low

## **4 Protocol Summary**


[Linea is a Type 2 zkEVM L2 rollup with full EVM equivalence which aims to provide the "Ethereum experience" at](https://www.youtube.com/watch?v=aSvg89p68HA&t=1585s)
scale and has been previously audited by Cyfrin.

## **5 Audit Scope**


This was an incremental audit focused on the following mix of changes:


   - [dynamic chain variables](https://github.com/Consensys/linea-monorepo/commit/9366e3f67b3355d8aac475ff49ae9b83d0bb67fa)


   - [contracts folder restructuring](https://github.com/Consensys/linea-monorepo/commit/e66abc64fd833b4904279e4a784d38255bfae0ab)


   - [data modularization](https://github.com/Consensys/linea-monorepo/commit/a89790d5ed3e1632219e5150134f0bcb8e6cf63d)


   - [transient storage](https://github.com/Consensys/linea-monorepo/commit/0c8bee77311c694ba9c8643356f9703b9c88394b)


The audit scope was limited to:

```
1) changes merged from deleted branch `feat/996-dynamic-chain-variables`

// changes to `finalizeBlocks`, `_computePublicInput`
contracts/src/rollup/LineaRollupBase.sol
// move of `_verifyProof` into `LineaRollupBase.sol`
contracts/src/rollup/ZkEvmV2.sol
// added `constructor` and `_computeChainConfigurationHash`
contracts/src/verifiers/PlonkVerifierForDataAggregation.sol

2) changes merged from deleted branch `contract-folder-restructure`

// refactor to inherit from new file `TokenBridgeBase.sol`
// removal of `setRemoteTokenBridge`, field added to initialization data
// and `__TokenBridge_init` now calls `_setRemoteSender`

```

2


```
contracts/src/bridging/token/TokenBridge.sol
contracts/src/bridging/token/TokenBridgeBase.sol
contracts/src/security/reentrancy/TransientStorageReentrancyGuardUpgradeable.sol

// remove usage of `TransientStorageHelpers` instead using
// new `transient` keyword variable
contracts/src/messaging/l1/v1/L1MessageManagerV1.sol
contracts/src/messaging/l1/L1MessageService.sol

// use `TransientStorageReentrancyGuardUpgradeable` instead of `ReentrancyGuardUpgradeable`
// and use `TRANSIENT_MESSAGE_SENDER` plus deprecate `_messageSender`
contracts/src/messaging/l2/v1/L2MessageServiceV1.sol

// refactor to inherit from new file `L2MessageServiceBase.sol`
contracts/src/messaging/l2/L2MessageService.sol
contracts/src/messaging/l2/L2MessageServiceBase.sol

// security council pausing see new `SECURITY_COUNCIL_ROLE`, `PAUSE_DURATION`,
// `COOLDOWN_DURATION`, `pauseExpiryTimestamp`, `unPauseByExpiredType`
// deprecated `pauseTypeStatuses_DEPRECATED`
contracts/src/security/pausing/PauseManager.sol

3) data modularization changes related to https://github.com/Consensys/linea-monorepo/pull/1743/files

// refactored from L1MessageServiceBase
contracts/src/messaging/l1/v1/ClaimMessageV1.sol

// now inherits from LivenessRecovery, Eip4844BlobAcceptor, ClaimMessageV1
// changes/additions initialize, reinitializeV8, renounceRole
contracts/src/rollup/LineaRollup.sol

// new PROXY_ADMIN_SLOT, remove SHNARF_EXISTS_DEFAULT_VALUE, SIX_MONTHS_IN_SECONDS
// blobShnarfExists -> _blobShnarfExists made internal
// new livenessRecoveryOperator, shnarfProvider
// changes to __LineaRollup_init, moved bunch of stuff to other files
contracts/src/rollup/LineaRollupBase.sol

// new files mostly containing stuff from move LineaRollupBase with slight tweaks
contracts/src/rollup/LivenessRecovery.sol
contracts/src/rollup/Validium.sol
contracts/src/rollup/dataAvailability/CalldataBlobAcceptor.sol
contracts/src/rollup/dataAvailability/Eip4844BlobAcceptor.sol
contracts/src/rollup/dataAvailability/LocalShnarfProvider.sol
contracts/src/rollup/dataAvailability/ShnarfDataAcceptor.sol
contracts/src/rollup/dataAvailability/ShnarfDataAcceptorBase.sol

## **6 Executive Summary**

```

Over the course of 5 days, the Cyfrin team conducted an audit on the Linea [Mixed](https://github.com/Consensys/linea-monorepo.git) Upgrade smart contracts
[provided by Linea.](https://linea.build) In this period, a total of 8 issues were found.


The findings consist of 1 Critical and 1 Low severity issue with the remainder being informational.


**TokenBridge Storage Upgrade**


Using `forge` `inspect` `-R` `"@openzeppelin/=contracts/node_modules/@openzeppelin/"` `--hardhat`
`TokenBridge` `storageLayout` on both the new and old contracts to carefully examine their exact storage layout,
accounting for the fix in C-1:

```
 NEW TokenBridge Layout | Type | Slot | Offset | Bytes
----------------------------------|-----------------------------------------|------|--------|-----
```

3


```
# identical
 _initialized | uint8 | 0 | 0 | 1
 _initializing | bool | 0 | 1 | 1

# overwrites `_status`,
# upgrade will wipe slot 1 clean
 __gap_ReentrancyGuardUpgradeable | uint256[50] | 1 | 0 | 1600

# identical
 __gap | uint256[50] | 51 | 0 | 1600
 __gap | uint256[50] | 101 | 0 | 1600
 _roles | mapping(bytes32 => struct ACU.RoleData) | 151 | 0 | 32
 __gap | uint256[49] | 152 | 0 | 1568
 messageService | contract IMessageService | 201 | 0 | 20
 remoteSender | address | 202 | 0 | 20
 __base_gap | uint256[10] | 203 | 0 | 320
 pauseTypeStatuses_DEPRECATED | mapping(bytes32 => bool) | 213 | 0 | 32
 _pauseTypeStatusesBitMap | uint256 | 214 | 0 | 32
 _pauseTypeRoles | mapping(enum IPM.PauseType => bytes32) | 215 | 0 | 32
 _unPauseTypeRoles | mapping(enum IPM.PauseType => bytes32) | 216 | 0 | 32
 pauseExpiryTimestamp | uint256 | 217 | 0 | 32
 __gap | uint256[6] | 218 | 0 | 192
 __gap_39 | uint256[39] | 224 | 0 | 1248
 tokenBeacon | address | 263 | 0 | 20
 nativeToBridgedToken | m(uint256 => m(address => address)) | 264 | 0 | 32
 bridgedToNativeToken | mapping(address => address) | 265 | 0 | 32
 sourceChainId | uint256 | 266 | 0 | 32
 targetChainId | uint256 | 267 | 0 | 32
 __gap | uint256[50] | 268 | 0 | 1600

 OLD TokenBridge Layout | Type | Slot | Offset | Bytes
----------------------------------|-----------------------------------------|------|--------|-----# identical
 _initialized | uint8 | 0 | 0 | 1
 _initializing | bool | 0 | 1 | 1

# repurposed as gap, wiped
 _status | uint256 | 1 | 0 | 32

# identical
 __gap | uint256[50] | 51 | 0 | 1600
 __gap | uint256[50] | 101 | 0 | 1600
 _roles | mapping(bytes32 => struct ACU.RoleData) | 151 | 0 | 32
 __gap | uint256[49] | 152 | 0 | 1568
 messageService | contract IMessageService | 201 | 0 | 20
 remoteSender | address | 202 | 0 | 20
 __base_gap | uint256[10] | 203 | 0 | 320
 pauseTypeStatuses_DEPRECATED | mapping(bytes32 => bool) | 213 | 0 | 32
 _pauseTypeStatusesBitMap | uint256 | 214 | 0 | 32
 _pauseTypeRoles | mapping(enum IPM.PauseType => bytes32) | 215 | 0 | 32
 _unPauseTypeRoles | mapping(enum IPM.PauseType => bytes32) | 216 | 0 | 32
 pauseExpiryTimestamp | uint256 | 217 | 0 | 32
 __gap | uint256[6] | 218 | 0 | 192
 __gap_39 | uint256[39] | 224 | 0 | 1248
 tokenBeacon | address | 263 | 0 | 20
 nativeToBridgedToken | m(uint256 => m(address => address)) | 264 | 0 | 32
 bridgedToNativeToken | mapping(address => address) | 265 | 0 | 32
 sourceChainId | uint256 | 266 | 0 | 32
 targetChainId | uint256 | 267 | 0 | 32
 __gap | uint256[50] | 268 | 0 | 1600

```

**LineaRollup Storage Upgrade**


4


Using `forge` `inspect` `-R` `"@openzeppelin/=contracts/node_modules/@openzeppelin/"` `--hardhat`
`--evm-version` `cancun` `LineaRollup` `storageLayout` on both the new and old contracts to carefully examine
their exact storage layout:

```
 NEW LineaRollup Layout | Type | Slot | Offset | Bytes
-------------------------------------------|-----------------------------------|------|--------|-----# identical
 _initialized | uint8 | 0 | 0 | 1
 _initializing | bool | 0 | 1 | 1
 __gap | uint256[50] | 1 | 0 | 1600
 __gap | uint256[50] | 51 | 0 | 1600
 _roles | m(bytes32 => struct ACU.RoleData) | 101 | 0 | 32
 __gap | uint256[49] | 102 | 0 | 1568
 periodInSeconds | uint256 | 151 | 0 | 32
 limitInWei | uint256 | 152 | 0 | 32
 currentPeriodEnd | uint256 | 153 | 0 | 32
 currentPeriodAmountInWei | uint256 | 154 | 0 | 32
 __gap | uint256[10] | 155 | 0 | 320
 outboxL1L2MessageStatus | m(bytes32 => uint256) | 165 | 0 | 32
 inboxL2L1MessageStatus | m(bytes32 => uint256) | 166 | 0 | 32
 __gap_ReentrancyGuardUpgradeable | uint256[50] | 167 | 0 | 1600
 pauseTypeStatuses_DEPRECATED | m(bytes32 => bool) | 217 | 0 | 32
 _pauseTypeStatusesBitMap | uint256 | 218 | 0 | 32
 _pauseTypeRoles | m(enum IPM.PauseType => bytes32) | 219 | 0 | 32
 _unPauseTypeRoles | m(enum IPM.PauseType => bytes32) | 220 | 0 | 32
 pauseExpiryTimestamp | uint256 | 221 | 0 | 32
 __gap | uint256[6] | 222 | 0 | 192
 nextMessageNumber | uint256 | 228 | 0 | 32
 _messageSender_DEPRECATED | address | 229 | 0 | 20
 __gap | uint256[50] | 230 | 0 | 1600
 currentTimestamp_DEPRECATED | uint256 | 280 | 0 | 32
 currentL2BlockNumber | uint256 | 281 | 0 | 32
 stateRootHashes | mapping(uint256 => bytes32) | 282 | 0 | 32
 verifiers | mapping(uint256 => address) | 283 | 0 | 32
 __gap | uint256[50] | 284 | 0 | 1600
 rollingHashes | mapping(uint256 => bytes32) | 334 | 0 | 32
 _messageClaimedBitMap | struct BitMaps.BitMap | 335 | 0 | 32
 l2MerkleRootsDepths | mapping(bytes32 => uint256) | 336 | 0 | 32
 __gap_L1MessageManager | uint256[50] | 337 | 0 | 1600
 systemMigrationBlock | uint256 | 387 | 0 | 32
 __gap_L1MessageService | uint256[50] | 388 | 0 | 1600
 dataFinalStateRootHashes_DEPRECATED | mapping(bytes32 => bytes32) | 438 | 0 | 32
 dataParents_DEPRECATED | mapping(bytes32 => bytes32) | 439 | 0 | 32
 dataShnarfHashes_DEPRECATED | mapping(bytes32 => bytes32) | 440 | 0 | 32
 dataStartingBlock_DEPRECATED | mapping(bytes32 => uint256) | 441 | 0 | 32
 dataEndingBlock_DEPRECATED | mapping(bytes32 => uint256) | 442 | 0 | 32
 currentL2StoredL1MessageNumber_DEPRECATED | uint256 | 443 | 0 | 32
 currentL2StoredL1RollingHash_DEPRECATED | bytes32 | 444 | 0 | 32
 currentFinalizedShnarf | bytes32 | 445 | 0 | 32
 _blobShnarfExists | mapping(bytes32 => uint256) | 446 | 0 | 32
 currentFinalizedState | bytes32 | 447 | 0 | 32

# renamed from `fallbackOperator`
 livenessRecoveryOperator | address | 448 | 0 | 20

# new, previously gap
 shnarfProvider | contract IProvideShnarf | 449 | 0 | 20
 __gap_LineaRollup | uint256[50] | 450 | 0 | 1600
 __gap_LivenessRecoveryOperator | uint256[50] | 500 | 0 | 1600

 OLD LineaRollup Layout | Type | Slot | Offset | Bytes
-------------------------------------------|-----------------------------------|------|--------|-----# identical

```

5


```
 _initialized | uint8 | 0 | 0 | 1
 _initializing | bool | 0 | 1 | 1
 __gap | uint256[50] | 1 | 0 | 1600
 __gap | uint256[50] | 51 | 0 | 1600
 _roles | m(bytes32 => struct ACU.RoleData) | 101 | 0 | 32
 __gap | uint256[49] | 102 | 0 | 1568
 periodInSeconds | uint256 | 151 | 0 | 32
 limitInWei | uint256 | 152 | 0 | 32
 currentPeriodEnd | uint256 | 153 | 0 | 32
 currentPeriodAmountInWei | uint256 | 154 | 0 | 32
 __gap | uint256[10] | 155 | 0 | 320
 outboxL1L2MessageStatus | m(bytes32 => uint256) | 165 | 0 | 32
 inboxL2L1MessageStatus | m(bytes32 => uint256) | 166 | 0 | 32
 __gap_ReentrancyGuardUpgradeable | uint256[50] | 167 | 0 | 1600
 pauseTypeStatuses_DEPRECATED | m(bytes32 => bool) | 217 | 0 | 32
 _pauseTypeStatusesBitMap | uint256 | 218 | 0 | 32
 _pauseTypeRoles | m(enum IPM.PauseType => bytes32) | 219 | 0 | 32
 _unPauseTypeRoles | m(enum IPM.PauseType => bytes32) | 220 | 0 | 32
 pauseExpiryTimestamp | uint256 | 221 | 0 | 32
 __gap | uint256[6] | 222 | 0 | 192
 nextMessageNumber | uint256 | 228 | 0 | 32
 _messageSender_DEPRECATED | address | 229 | 0 | 20
 __gap | uint256[50] | 230 | 0 | 1600
 currentTimestamp_DEPRECATED | uint256 | 280 | 0 | 32
 currentL2BlockNumber | uint256 | 281 | 0 | 32
 stateRootHashes | mapping(uint256 => bytes32) | 282 | 0 | 32
 verifiers | mapping(uint256 => address) | 283 | 0 | 32
 __gap | uint256[50] | 284 | 0 | 1600
 rollingHashes | mapping(uint256 => bytes32) | 334 | 0 | 32
 _messageClaimedBitMap | struct BitMaps.BitMap | 335 | 0 | 32
 l2MerkleRootsDepths | mapping(bytes32 => uint256) | 336 | 0 | 32
 __gap_L1MessageManager | uint256[50] | 337 | 0 | 1600
 systemMigrationBlock | uint256 | 387 | 0 | 32
 __gap_L1MessageService | uint256[50] | 388 | 0 | 1600
 dataFinalStateRootHashes_DEPRECATED | mapping(bytes32 => bytes32) | 438 | 0 | 32
 dataParents_DEPRECATED | mapping(bytes32 => bytes32) | 439 | 0 | 32
 dataShnarfHashes_DEPRECATED | mapping(bytes32 => bytes32) | 440 | 0 | 32
 dataStartingBlock_DEPRECATED | mapping(bytes32 => uint256) | 441 | 0 | 32
 dataEndingBlock_DEPRECATED | mapping(bytes32 => uint256) | 442 | 0 | 32
 currentL2StoredL1MessageNumber_DEPRECATED | uint256 | 443 | 0 | 32
 currentL2StoredL1RollingHash_DEPRECATED | bytes32 | 444 | 0 | 32
 currentFinalizedShnarf | bytes32 | 445 | 0 | 32
 _blobShnarfExists | mapping(bytes32 => uint256) | 446 | 0 | 32
 currentFinalizedState | bytes32 | 447 | 0 | 32

# renamed to `livenessRecoveryOperator`
 fallbackOperator | address | 448 | 0 | 20

# 449 - used for new `shnarfProvider`
 __gap_LineaRollup | uint256[50] | 449 | 0 | 1600

```

**L2MessageService Storage Upgrade**


Using `forge` `inspect` `-R` `"@openzeppelin/=contracts/node_modules/@openzeppelin/"` `--hardhat`
`L2MessageService` `storageLayout` on both the new and old contracts to carefully examine their exact storage
layout:

```
 NEW L2MessageService Layout | Type | Slot | Offset | Bytes
----------------------------------|-----------------------------------------|------|--------|-----# identical
 _initialized | uint8 | 0 | 0 | 1
 _initializing | bool | 0 | 1 | 1
 __gap | uint256[50] | 1 | 0 | 1600

```

6


```
 __gap | uint256[50] | 51 | 0 | 1600
 _roles | mapping(bytes32 => struct ACU.RoleData) | 101 | 0 | 32
 __gap | uint256[49] | 102 | 0 | 1568
 periodInSeconds | uint256 | 151 | 0 | 32
 limitInWei | uint256 | 152 | 0 | 32
 currentPeriodEnd | uint256 | 153 | 0 | 32
 currentPeriodAmountInWei | uint256 | 154 | 0 | 32
 __gap | uint256[10] | 155 | 0 | 320
 pauseTypeStatuses_DEPRECATED | mapping(bytes32 => bool) | 165 | 0 | 32
 _pauseTypeStatusesBitMap | uint256 | 166 | 0 | 32
 _pauseTypeRoles | mapping(enum IPM.PauseType => bytes32) | 167 | 0 | 32
 _unPauseTypeRoles | mapping(enum IPM.PauseType => bytes32) | 168 | 0 | 32
 pauseExpiryTimestamp | uint256 | 169 | 0 | 32
 __gap | uint256[6] | 170 | 0 | 192
 inboxL1L2MessageStatus | mapping(bytes32 => uint256) | 176 | 0 | 32

# overwrites `_status`,
# upgrade will wipe slot 177 clean
 __gap_ReentrancyGuardUpgradeable | uint256[50] | 177 | 0 | 1600

# identical
 __gap_L2MessageServiceV1 | uint256[50] | 227 | 0 | 1600

# renamed
 _messageSender_DEPRECATED | address | 277 | 0 | 20

# identical
 nextMessageNumber | uint256 | 278 | 0 | 32
 minimumFeeInWei | uint256 | 279 | 0 | 32
 lastAnchoredL1MessageNumber | uint256 | 280 | 0 | 32
 l1RollingHashes | mapping(uint256 => bytes32) | 281 | 0 | 32
 __gap_L2MessageManager | uint256[50] | 282 | 0 | 1600
 __gap_L2MessageService | uint256[50] | 332 | 0 | 1600
 __gap_L2MessageService | uint256[50] | 382 | 0 | 1600

 OLD L2MessageService Layout | Type | Slot | Offset | Bytes
----------------------------------|-----------------------------------------|------|--------|-----# identical
 _initialized | uint8 | 0 | 0 | 1
 _initializing | bool | 0 | 1 | 1
 __gap | uint256[50] | 1 | 0 | 1600
 __gap | uint256[50] | 51 | 0 | 1600
 _roles | mapping(bytes32 => struct ACU.RoleData) | 101 | 0 | 32
 __gap | uint256[49] | 102 | 0 | 1568
 periodInSeconds | uint256 | 151 | 0 | 32
 limitInWei | uint256 | 152 | 0 | 32
 currentPeriodEnd | uint256 | 153 | 0 | 32
 currentPeriodAmountInWei | uint256 | 154 | 0 | 32
 __gap | uint256[10] | 155 | 0 | 320
 pauseTypeStatuses_DEPRECATED | mapping(bytes32 => bool) | 165 | 0 | 32
 _pauseTypeStatusesBitMap | uint256 | 166 | 0 | 32
 _pauseTypeRoles | mapping(enum IPM.PauseType => bytes32) | 167 | 0 | 32
 _unPauseTypeRoles | mapping(enum IPM.PauseType => bytes32) | 168 | 0 | 32
 pauseExpiryTimestamp | uint256 | 169 | 0 | 32
 __gap | uint256[6] | 170 | 0 | 192
 inboxL1L2MessageStatus | mapping(bytes32 => uint256) | 176 | 0 | 32

# overwritten by `__gap_ReentrancyGuardUpgradeable`
 _status | uint256 | 177 | 0 | 32
 __gap | uint256[49] | 178 | 0 | 1568

# identical
 __gap_L2MessageServiceV1 | uint256[50] | 227 | 0 | 1600

```

7


```
# renamed to `_messageSender_DEPRECATED`
 _messageSender | address | 277 | 0 | 20

# identical
 nextMessageNumber | uint256 | 278 | 0 | 32
 minimumFeeInWei | uint256 | 279 | 0 | 32
 lastAnchoredL1MessageNumber | uint256 | 280 | 0 | 32
 l1RollingHashes | mapping(uint256 => bytes32) | 281 | 0 | 32
 __gap_L2MessageManager | uint256[50] | 282 | 0 | 1600
 __gap_L2MessageService | uint256[50] | 332 | 0 | 1600
 __gap_L2MessageService | uint256[50] | 382 | 0 | 1600

```

**Merged To Main**


The new functionality containing mitigations from our audit was merged to `main` branch in [PR2007](https://github.com/Consensys/linea-monorepo/pull/2007) and commit
[5074237.](https://github.com/Consensys/linea-monorepo/commit/5074237b71b9b799e9b1ef68ae2b902e20dd9b13)


**Deployment Bytecode Verification**


After an additional audit by another provider, the resulting code was subsequently deployed on-chain to:


   - LineaRollup: 0xE68697690E8ff196A6aBB3E1385156D87Df85332


   - L1 TokenBridge: 0xF0e003F0dE2d583Ae28FA8cBF66aa096CdAce3ff


   - L2MessageService: 0x9976fD7edDb78156a002DE74c9158E884702273d


   - L2 TokenBridge: 0x4a496167F187A97379e763f693A499cE1182848b


At commit [698d8830c,](https://github.com/Consensys/linea-monorepo/commit/698d8830c359b698ceee510f0d2beedebac9f7fe) Cyfrin verified that the locally compiled bytecode matched both the expected bytecode in
the repository and the deployed bytecode on-chain. We used the following reproducible process to do this.


1) prepare the repo:

```
gh repo clone Consensys/linea-monorepo
cd linea-monorepo
git checkout 698d8830c359b698ceee510f0d2beedebac9f7fe
pnpm install --ignore-scripts // to get around an error related to better-sqlite3
cd node_modules/.pnpm/c-kzg@4.1.0/node_modules/c-kzg && npx node-gyp rebuild // rebuild c-kzg native
```

,! `bindings`
```
cd contracts
npx hardhat test

```

2) [diff the locally compiled bytecode against the expected:](https://github.com/Consensys/linea-monorepo/tree/698d8830c359b698ceee510f0d2beedebac9f7fe/contracts/deployments/bytecode/2026-02-17)

```
linea-monorepo/contracts$ diff build/src/rollup/LineaRollup.sol/LineaRollup.json
```

,! `deployments/bytecode/2026-02-17/LineaRollup.json`

```
linea-monorepo/contracts$ diff build/src/messaging/l2/L2MessageService.sol/L2MessageService.json
```

,! `deployments/bytecode/2026-02-17/L2MessageService.json`

```
linea-monorepo/contracts$ diff build/src/bridging/token/TokenBridge.sol/TokenBridge.json
```

,! `deployments/bytecode/2026-02-17/TokenBridge.json`


3) prepare the helper programs:


To extract deployment bytecode use this python program `extract_deployed_bytecode.py` :

```
import sys
import os
import requests

if len(sys.argv) != 4:
  print("Usage: python3 extract_deployed_bytecode.py <env_var_for_rpc_url> <address> <output_path>")
  sys.exit(1)

```

8


```
env_var = sys.argv[1]
address = sys.argv[2]
output_path = sys.argv[3]

rpc_url = os.environ.get(env_var)
if not rpc_url:
  print(f"Error: Environment variable '{env_var}' is not set.")
  sys.exit(1)

data = {
  "jsonrpc": "2.0",
  "method": "eth_getCode",
  "params": [address, "latest"],
  "id": 1
}

response = requests.post(rpc_url, json=data)
if response.status_code == 200:
  result = response.json()
  if "result" in result:
     bytecode = result["result"]
     with open(output_path, "w") as f:
       f.write(bytecode)
     print(f"Deployed bytecode saved to {output_path}")
  else:
     print("Error: No bytecode found in response")
else:
  print(f"Error: RPC request failed with status {response.status_code}")

```

To compare locally compiled bytecode against deployed bytecode ignoring differences in metadata & immutable
positions, use this python program `compare_bytecodes.py` :

```
import sys
import json
import os

def strip_metadata(bytecode: bytes) -> bytes:
  if len(bytecode) < 2:
     return bytecode
  cbor_len = (bytecode[-2] << 8) | bytecode[-1]
  if cbor_len <= 0 or cbor_len + 2 > len(bytecode):
     return bytecode
  potential_cbor = bytecode[-cbor_len - 2 : -2]
  if potential_cbor[0] not in (0xa1, 0xa2):
     return bytecode
  return bytecode[:-cbor_len - 2]

if len(sys.argv) != 3:
  print("Usage: python3 compare_bytecodes.py <artifact_json_path> <deployed_bytecode_path>")
  sys.exit(1)

artifact_path = sys.argv[1]
deployed_path = sys.argv[2]

try:
  with open(artifact_path, "r") as f:
     data = json.load(f)

  deployed_bytecode_section = data.get("deployedBytecode")
  if isinstance(deployed_bytecode_section, str):
     local_hex = deployed_bytecode_section
  elif isinstance(deployed_bytecode_section, dict):

```

9


```
  local_hex = deployed_bytecode_section.get("object")
else:
  print("Error: 'deployedBytecode' not found or invalid in artifact.")
  sys.exit(1)

if not local_hex:
  print("Error: No bytecode found in artifact.")
  sys.exit(1)

if local_hex.startswith("0x"):
  local_hex = local_hex[2:]

local_bytes = bytes.fromhex(local_hex)

with open(deployed_path, "r") as f:
  deployed_hex = f.read().strip()

if deployed_hex.startswith("0x"):
  deployed_hex = deployed_hex[2:]

deployed_bytes = bytes.fromhex(deployed_hex)

local_bytes = strip_metadata(local_bytes)
deployed_bytes = strip_metadata(deployed_bytes)

if len(local_bytes) != len(deployed_bytes):
  print(f"Error: Bytecode lengths differ after stripping metadata: local {len(local_bytes)} vs
```

,! `deployed` `{len(deployed_bytes)}")`
```
  sys.exit(1)

mismatch = False
assumed_immutable_positions = []
for i in range(len(local_bytes)):
  if local_bytes[i] == 0 and deployed_bytes[i] != 0:
    assumed_immutable_positions.append(i)
    continue
  if local_bytes[i] != deployed_bytes[i]:
    print(f"Mismatch at position {i}: local 0x{local_bytes[i]:02x} vs deployed
```

,! `0x{deployed_bytes[i]:02x}")`
```
    mismatch = True

if mismatch:
  print("Bytecodes do NOT match (differences outside assumed immutable positions).")
else:
  print("Bytecodes match, ignoring differences in assumed immutable positions.")

if assumed_immutable_positions:
  print("\nAssumed immutable positions where local=0x00 and deployed !=0x00:")
  groups = []
  start = assumed_immutable_positions[0]
  prev = assumed_immutable_positions[0]
  for pos in assumed_immutable_positions[1:]:
    if pos == prev + 1:
      prev = pos
    else:
      groups.append((start, prev))
      start = pos
      prev = pos
  groups.append((start, prev))
  for s, e in groups:
    length = e - s + 1
    local_val = local_bytes[s:s+length].hex()
    deployed_val = deployed_bytes[s:s+length].hex()

```

10


```
      print(f" Range {s}-{e} (length {length}): local {local_val} vs deployed {deployed_val}")

except FileNotFoundError as e:
  print(f"Error: File not found - {e}")
  sys.exit(1)
except json.JSONDecodeError:
  print(f"Error: Invalid JSON in artifact file '{artifact_path}'.")
  sys.exit(1)
except ValueError as e:
  print(f"Error: Invalid hex in bytecode - {e}")
  sys.exit(1)
except Exception as e:
  print(f"Unexpected error: {str(e)}")
  sys.exit(1)

```

4) verify `LineaRollup` deployed bytecode using:


  - `python3` `extract_deployed_bytecode.py` `ETH_RPC_URL` `0xE68697690E8ff196A6aBB3E1385156D87Df85332`
`deployments/bytecode/2026-02-17/LineaRollup.mainnet.txt` to extract mainnet deployed bytecode


  - `python3` `compare_bytecodes.py` `build/src/rollup/LineaRollup.sol/LineaRollup.json`
`deployments/bytecode/2026-02-17/LineaRollup.mainnet.txt` to verify both match - succeeds


5) verify `L1` `TokenBridge` deployed bytecode using:


  - `python3` `extract_deployed_bytecode.py` `ETH_RPC_URL` `0xF0e003F0dE2d583Ae28FA8cBF66aa096CdAce3ff`
`deployments/bytecode/2026-02-17/TokenBridge.L1.mainnet.txt` to extract mainnet deployed bytecode


  - `python3` `compare_bytecodes.py` `build/src/bridging/token/TokenBridge.sol/TokenBridge.json`
`deployments/bytecode/2026-02-17/TokenBridge.L1.mainnet.txt` to verify both match - succeeds


6) verify `L2MessageService` deployed bytecode using:


  - `python3` `extract_deployed_bytecode.py` `LINEA_RPC_URL` `0x9976fD7edDb78156a002DE74c9158E884702273d`
`deployments/bytecode/2026-02-17/L2MessageService.mainnet.txt` to extract Linea mainnet deployed
bytecode (public RPC: `https://rpc.linea.build` )


  - `python3` `compare_bytecodes.py` `build/src/messaging/l2/L2MessageService.sol/L2MessageService.json`
`deployments/bytecode/2026-02-17/L2MessageService.mainnet.txt` to verify both match - succeeds


7) verify `L2` `TokenBridge` deployed bytecode using:


  - `python3` `extract_deployed_bytecode.py` `LINEA_RPC_URL` `0x4a496167F187A97379e763f693A499cE1182848b`
`deployments/bytecode/2026-02-17/TokenBridge.L2.mainnet.txt` to extract Linea mainnet deployed
bytecode (public RPC: `https://rpc.linea.build` )


  - `python3` `compare_bytecodes.py` `build/src/bridging/token/TokenBridge.sol/TokenBridge.json`
`deployments/bytecode/2026-02-17/TokenBridge.L2.mainnet.txt` to verify both match - succeeds


**Summary**


Project Name Linea Mixed Upgrade


Repository [linea-monorepo](https://github.com/Consensys/linea-monorepo.git)


Commit [78f9d1fa3ccc. . .](https://github.com/Consensys/linea-monorepo/blob/78f9d1fa3ccc9dc33e446c39e95641033c8fb9cc)


Fix Commit [c374a2c9f3a6. . .](https://github.com/Consensys/linea-monorepo/blob/c374a2c9f3a6b3d74d5ddf73e8cdbccbea987fa9)


Audit Timeline Jan 5th - Jan 9th, 2026


Methods Manual Review


11


**Issues Found**


Critical Risk 1


High Risk 0


Medium Risk 0


Low Risk 1


Informational 6


Gas Optimizations 0


Total Issues 8


**Summary of Findings**


[C-1] After the upgrade permissionless attacker can fully drain the L1 `Token-`
`Bridge` of `ERC20` tokens currently valued around 29MUSD


[L-1] `SECURITY_COUNCIL_ROLE` unpausing a type leads to automatically marking as expired any other pause types, whether they were enacted by the `SE-`
`CURITY_COUNCIL_ROLE` or not


[I-1] `LineaRollup,` `LivenessRecovery::renounceRole` prevents liveness recovery operator from renouncing all roles


[I-2] `LivenessRecovery::setLivenessRecoveryOperator` will emit misleading event when role is not granted


[I-3] Inconsistent handling of update/set transactions which don’t actually
change values


[I-4] Not emitting event to log the version’s change when reinitializing the `Lin-`
`eaRollup` contract


[I-5] Missing `onlyInitializing` modifier on initialization functions for abstract
contracts



Resolved


Resolved


Acknowledged


Resolved


Acknowledged


Resolved


Resolved




[I-6] Consider wiping slot 177 on Linea `L2MessageService` after upgrade Resolved


12


## **7 Findings**

**7.1** **Critical Risk**


**7.1.1** **After** **the** **upgrade** **permissionless** **attacker** **can** **fully** **drain** **the** **L1** `TokenBridge` **of** `ERC20` **tokens** **cur-**
**rently valued around $29M USD**


**Description:** Using `forge` `inspect` `-R` `"@openzeppelin/=contracts/node_modules/@openzeppelin/"`
`--hardhat` `TokenBridge` `storageLayout` on both the new and old `TokenBridge` contracts to carefully examine
their exact storage layout showed that:


   - slot 0 which used to be initialization slot becomes a gap


   - slot 50 which used to be a gap becomes the new initialization slot


**Impact:** Immediately following the upgrade, the `TokenBridge` contract will believe it is not initialized allowing a
permissionless attacker to initialize it. An attacker can weaponize this to completely drain the L1 `TokenBridge`
[contract of ERC20 tokens which at the time of this audit are valued around $29M USD.](https://etherscan.io/address/0x051F1D88f0aF5763fB888eC4378b4D8B29ea3319)


**Proof of Concept:** Immediately following the upgrade:


1. Attacker calls `TokenBridge::initialize` to set themselves as default admin


2. Attacker calls `TokenBridge::grantRole(SET_MESSAGE_SERVICE_ROLE,` `attacker)` to give themselves permission to set messaging service address


3. Attacker deploys a malicious messaging service contract such as:

```
contract MaliciousMessageService {
  address public targetRemoteSender;

  constructor(address _remoteSender) {
     targetRemoteSender = _remoteSender;
  }

  // Spoofs the remoteSender check
  function sender() external view returns (address) {
     return targetRemoteSender;
  }

  // Calls TokenBridge as msg.sender to pass onlyMessagingService
  function drain(
     ITokenBridge bridge,
     address token,
     uint256 amount,
     address recipient,
     uint256 chainId
  ) external {
     bridge.completeBridging(token, amount, recipient, chainId, "");
  }
}

```

4. Attacker sets it by calling `TokenBridge::setMessageService(maliciousMessageService)`


5. Attacker calls the `drain` function on their malicious messaging service for every token locked in the L1
```
   TokenBridge

```

6. `TokenBridge::_completeBridging` calls `IERC20Upgradeable(_nativeToken).safeTransfer(_recipi-`
`ent,` `_amount)` to send the attacker the locked tokens


This attack can be executed atomically and via a private mempool such as flashbots (to prevent front-running)
making it unstoppable and completely draining the L1 `TokenBridge` .


**Recommended** **Mitigation:** `TokenBridgeBase` should inherit from `Initializable` . In an older version `Token-`
`Bridge` inherited from `Initializable` but this was later changed to inherit from OZ `ReentrancyGuardUpgradeable`,


13


which itself inherits from `Initializable` so everything was still OK.


[The bug appears to have been introduced on Nov 7th 2025 in commit 0c8bee7 which swapped out OZ](https://github.com/Consensys/linea-monorepo/commit/0c8bee77311c694ba9c8643356f9703b9c88394b#diff-aff2d4ab7e0847d160464ca3171cd9a427be1e9503a4feffaaa6207fc83237efL31-R31) `Reentran-`
`cyGuardUpgradeable` for the new custom `TransientStorageReentrancyGuardUpgradeable` . This new contract
doesn't inherit from `Initializable` which changed the `TokenBridge` inheritance hierarchy and hence storage
slots.


**Linea:** [Fixed in commit 4882f33.](https://github.com/Consensys/linea-monorepo/pull/2007/commits/4882f33de707085f01e54c89d090c6fba76f33a4)


**Cyfrin:** Verified; the fix results in the initialization slot being preserved at slot 0. Slot 1 which used to be `_status`
now becomes a gap and using `cast` `storage` `0x051F1D88f0aF5763fB888eC4378b4D8B29ea3319` `1` shows that on
Mainnet L1 `TokenBridge`, slot 1 (currently `_status` ) is already set to 1. Consider using a `reinitializer` to wipe
slot 1 "clean" as it becomes a gap.


**Linea:** [Added the wiping of slot 1 in commit d99f590.](https://github.com/Consensys/linea-monorepo/pull/2007/commits/d99f5906ec95102cdc67fb27039b26d15ef52a1e)


14


**7.2** **Low Risk**


**7.2.1** `SECURITY_COUNCIL_ROLE` **unpausing a type leads to automatically marking as expired any other pause**
**types, whether they were enacted by the** `SECURITY_COUNCIL_ROLE` **or not**


**Description:** `PauseManager` enables the handling of the pausing/unpausing of different `PauseTypes`, targeting
specific system functionalities (as well as a `GENERAL` pause). There are two main types of pausers:


1. Pausers with the `SECURITY_COUNCIL_ROLE`


2. Pausers without the `SECURITY_COUNCIL_ROLE`


The main difference between the two is that pausers with `SECURITY_COUNCIL_ROLE` can pause without cooldown
or expiry restrictions, and when they unpause, the `pauseExpiryTimestamp` is reset to enable non- `SECURITY_-`
`COUNCIL_ROLE` pausing.


There is an edge case that allows for immediately unpause of any active pause after the `SECURITY_COUNCIL_ROLE`
unpauses one type. Whether the `SECURITY_COUNCIL_ROLE` unpauses a pause enacted by themselves or by a
non- `SECURITY_COUNCIL_ROLE`, the result is the same; any other active pause can be immediately unpaused.


**Impact:** When the `SECURITY_COUNCIL_ROLE` unpauses a type, all the other active pause types will be immediately
marked as expired, regardless of whether they were enacted by the `SECURITY_COUNCIL_ROLE` or a `non-SECURITY_-`
`COUNCIL_ROLE` account.


**Proof of Concept:** Add the next PoC to `PauseManager.ts` :

```
  it.only("Non-SECURITY_COUNCIL_ROLE pause L1_L2_PAUSE_TYPE -> SECURITY_COUNCIL_ROLE pause

```


,!


,!


```
 GENERAL_PAUSE_TYPE -> SECURITY_COUNCIL_ROLE unpause L1_L2_PAUSE_TYPE => GENERAL_PAUSE can be
 unpaused even though it had not been actually unpaused", async () => {
await pauseByType(L1_L2_PAUSE_TYPE);
await pauseByType(GENERAL_PAUSE_TYPE, securityCouncil);
await unPauseByType(L1_L2_PAUSE_TYPE, securityCouncil);
//@audit-info => GENERAL_PAUSE can be immediately unpaused even though it had not been actually

```


,! _`unpaused`_
```
    await unPauseByExpiredType(GENERAL_PAUSE_TYPE, nonManager);
    expect(await pauseManager.isPaused(GENERAL_PAUSE_TYPE)).to.be.false;
    expect(await pauseManager.isPaused(L1_L2_PAUSE_TYPE)).to.be.false;
  });

```

**Recommended** **Mitigation:** Consider not resetting the `pauseExpiryTimestamp` below the `block.timestamp`, potentially add 1 hour cooldown period from the current `block.timestamp`, this will prevent immediately marking
other pauses as expired.


Alternatively, consider adding a bool flag to `unpauseByType` flag that can allow the `SECURITY_COUNCIL_ROLE` to
select dynamically whether they want to reset the `pauseExpiryTimestamp` or not.


   - A more elaborate alternative would be to track the active pauses and reset the `pauseExpiryTimestamp` only
when the last active pause is unpaused by the `SECURITY_COUNCIL_ROLE` .


**Linea:** [Fixed in PR 2335.](https://github.com/Consensys/linea-monorepo/pull/2335/changes)


**Cyfrin:** Verified. Pause expirations are now tracked per pause type. Non-SecurityCouncil can't pause a pause
type already paused by the SecurityCouncil, but the SecurityCouncil can pause a pause type already paused by
a non-SecurityCouncil. Pauses enacted by the SecurityCouncil can only be unpaused by them. Unpausing a type
only resets the expiry timestamp for that specific type.


15


**7.3** **Informational**


**7.3.1** `LineaRollup,` `LivenessRecovery::renounceRole` **prevents liveness recovery operator from renounc-**
**ing all roles**


**Description:** The intention appears to be that the liveness recovery operator shouldn't be able to
renounce the `OPERATOR_ROLE` they are granted, however `LivenessRecovery::renounceRole` called by
`LineaRollup::renounceRole` prevents the liveness recovery operator from renouncing _all_ roles:

```
function renounceRole(bytes32 _role, address _account) public virtual override {
 // @audit only checks address, not role being renounced
 if (_account == livenessRecoveryOperator) {
  revert OnlyNonLivenessRecoveryOperator();
 }

 super.renounceRole(_role, _account);
}

```

**Impact:** If the liveness recovery operator has other legitimate roles they wish to renounce, they will be unable to
do so.


**Recommended Mitigation:** `LivenessRecovery::renounceRole` should only revert if `OPERATOR_ROLE` is being renounced:

```
function renounceRole(bytes32 _role, address _account) public virtual override {
- if (_account == livenessRecoveryOperator) {
+ if (_account == livenessRecoveryOperator && _role == OPERATOR_ROLE) {
  revert OnlyNonLivenessRecoveryOperator();
 }
 super.renounceRole(_role, _account);
}

```

**Linea:** Acknowledged; the liveness operator role should never and would never be granted anything other than
the operator role.


**7.3.2** `LivenessRecovery::setLivenessRecoveryOperator` **will** **emit** **misleading** **event** **when** **role** **is** **not**
**granted**


**Description:** `LivenessRecovery::setLivenessRecoveryOperator` can be called multiple times as long as the
first two preconditions are met.


However if `OPERATOR_ROLE` has already been granted to `livenessRecoveryOperator` then `AccessControlUp-`
`gradeable::_grantRole` [returns](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/AccessControlUpgradeable.sol#L205-L211) `false` .


But the boolean return value of `_grantRole` is not checked so the misleading event will still be emitted.


**Recommended Mitigation:** Only emit the event if `_grantRole` returned true:

```
- _grantRole(OPERATOR_ROLE, livenessRecoveryOperatorAddress);
+ if(_grantRole(OPERATOR_ROLE, livenessRecoveryOperatorAddress))
  emit LivenessRecoveryOperatorRoleGranted(msg.sender, livenessRecoveryOperatorAddress);

```

**Linea:** [Fixed in commit 66050d2.](https://github.com/Consensys/linea-monorepo/pull/2007/commits/66050d2689a6b817b29f2de6b0a3fda2c69c42d9)


**Cyfrin:** Verified.


**7.3.3** **Inconsistent handling of update/set transactions which don't actually change values**


**Description:** `PauseManager::updatePauseTypeRole` reverts if the previous and new roles are identical, and only
writes to storage and emits an event if the value was actually changed:

```
function updatePauseTypeRole(
 PauseType _pauseType,

```

16


```
 bytes32 _newRole
) external onlyUsedPausedTypes(_pauseType) onlyRole(SECURITY_COUNCIL_ROLE) {
 bytes32 previousRole = _pauseTypeRoles[_pauseType];
 if (previousRole == _newRole) {
  revert RolesNotDifferent();
 }

 _pauseTypeRoles[_pauseType] = _newRole;
 emit PauseTypeRoleUpdated(_pauseType, _newRole, previousRole);
}

```

In contrast the following places don't revert on "no change" transactions, writing to storage and emitting events
even if no change occurred:


   - `LineaRollupBase::setVerifierAddress`

```
function setVerifierAddress(address _newVerifierAddress, uint256 _proofType) external
```

,! `onlyRole(VERIFIER_SETTER_ROLE)` `{`
```
  if (_newVerifierAddress == address(0)) {
    revert ZeroAddressNotAllowed();
  }
  // no revert if _newVerifierAddress == verifiers[_proofType]
  emit VerifierAddressChanged(_newVerifierAddress, _proofType, msg.sender, verifiers[_proofType]);
  verifiers[_proofType] = _newVerifierAddress;
}

```

   - `LineaRollupBase::unsetVerifierAddress`

```
function unsetVerifierAddress(uint256 _proofType) external onlyRole(VERIFIER_UNSETTER_ROLE) {
  // no revert if verifiers[_proofType] == address(0)
  emit VerifierAddressChanged(address(0), _proofType, msg.sender, verifiers[_proofType]);
  delete verifiers[_proofType];
}

```

   - `L2MessageServiceV1::setMinimumFee`

```
function setMinimumFee(uint256 _feeInWei) external onlyRole(MINIMUM_FEE_SETTER_ROLE) {
  // no revert if _feeInWei == previousMinimumFee
  uint256 previousMinimumFee = minimumFeeInWei;
  minimumFeeInWei = _feeInWei;
  emit MinimumFeeChanged(previousMinimumFee, _feeInWei, msg.sender);
}

```

   - `TokenBridgeBase::setMessageService`

```
function setMessageService(address _messageService) external ... {
  // no revert if _messageService == oldMessageService
  address oldMessageService = address(messageService);
  messageService = IMessageService(_messageService);
  emit MessageServiceUpdated(_messageService, oldMessageService, msg.sender);
}

```

   - `RateLimiter::resetAmountUsedInPeriod`

```
function resetAmountUsedInPeriod() external onlyRole(USED_RATE_LIMIT_RESETTER_ROLE) {
  // no revert if currentPeriodAmountInWei == 0
  currentPeriodAmountInWei = 0;
  emit AmountUsedInPeriodReset(_msgSender());
}

```

**Recommended** **Mitigation:** This can be acknowledged or behavior can be harmonized if there is no specific
reasons for one function to differ in behavior from others.


17


**Linea:** Acknowledged.


**7.3.4** **Not emitting event to log the version's change when reinitializing the** `LineaRollup` **contract**


**Description:** When `LineaRollup` gets upgraded, `[LineaRollup::reinitializeV8](https://github.com/Consensys/linea-monorepo/blob/main/contracts/src/rollup/LineaRollup.sol#L52-L67)` is called to reinitialize permissions, roles, set the `shnarfProvider`, and bump up the `initialized` version, but `LineaRollupVersionChanged`
event is not emitted to log the version's change.


**Recommended** **Mitigation:** Emit the event `LineaRollupVersionChanged` with the respective `previousVersion`
and `newVersion` for the `LineaRollup` .


**Linea:** [Fixed in PR2020.](https://github.com/Consensys/linea-monorepo/pull/2020)


**Cyfrin:** Verified.


**7.3.5** **Missing** `onlyInitializing` **modifier on initialization functions for abstract contracts**


**Description:** The `onlyInitializing` modifier is the established standard for protecting internal initialization functions in abstract contracts against unintended calls post-initialization. These new initialization functions introduced
here do not include this modifier, which deviates from common security patterns:


   - `L2MessageServiceBase::__L2MessageService_init`


   - `LineaRollupBase::__LineaRollup_init`


   - `TokenBridgeBase::__TokenBridge_init`


**Recommended Mitigation:** Consider adding the `onlyInitializing` modifier to those functions.


**Linea:** [Fixed in commits 802cf72, 2d63895.](https://github.com/Consensys/linea-monorepo/pull/2007/commits/802cf7239754526861e1e8777380619e8bc39cf2)


**Cyfrin:** Verified.


**7.3.6** **Consider wiping slot 177 on Linea** `L2MessageService` **after upgrade**


**Description:** After the upgrade, `L2MessageService` repurposes slot 177 for `__gap_ReentrancyGuardUpgradeable`
but previously this was used for `_status` .


Using `cast` `storage` `0x508Ca82Df566dCD1B0DE8296e70a96332cD644ec` `177` `--rpc-url` `https://rpc.linea.build`
shows that slot 177 has a value of 1, so ideally this would be wiped to clean it when changing the usage of this
slot into a gap.


**Linea:** [Fixed in commit c462da0.](https://github.com/Consensys/linea-monorepo/pull/2007/commits/c462da0574f4f60667c3c357a2be61443fc0ab7a)


**Cyfrin:** Verified.


18


