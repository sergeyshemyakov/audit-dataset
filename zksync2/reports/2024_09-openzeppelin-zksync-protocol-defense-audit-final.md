### | security

# **Protocol Defense** **Audit**

#### **September 9, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  8

Introduction 8


Low Severity ______________________________________________________________________  9

L-01 Misleading Errors 9

L-02 Inconsistent Input Validation 10

L-03 getAllHyperchains Function Reverts Due to Invalid Key Access 10


Notes & Additional Information ____________________________________________________ 11

N-01 Standardize Custom Error for Consistency 11

N-02 Typographical Errors 11

N-03 Duplicate Error Import 12

N-04 Risk with Floating Pragma and Yul Optimizer Bug 12

N-05 Unused Errors 12

N-06 Improved Organization of Error Files 13

N-07 Naming Issues 13

N-08 Unnamed Error Parameters 14

N-09 Misleading Use of "I" Prefix in Abstract Contract 14

N-10 Unused Enum 14

N-11 File and Contract Names Mismatch 15

N-12 Misplaced Error Declarations 15

N-13 Unused Named Return Variable 16

N-14 Constants Not Using UPPER_CASE Format 16

N-15 Unnecessary Casts 16

N-16 Risk of Disabling Valid Warnings 17

N-17 Unjustified Use of solhint-disable Comments 17

N-18 Inconsistent Application of Solhint Rule gas-length-in-loops 18

N-19 Duplicate Code 18

N-20 Overly Exposed State Variable 19

N-21 Inconsistent Initialization of Local Variables 19

N-22 Todo Comments in the Code 20

N-23 Misleading Documentation 20

N-24 Lack of Indexed Event Parameters 21


Conclusion ______________________________________________________________________ 22


Protocol Defense Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2024-06-10
To 2024-06-21


**Languages** Solidity & Yul



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


0 (0 resolved)



**Total Issues** 27 (20 resolved, 3 partially resolved)



**Low Severity Issues** 3 (2 resolved, 1 partially resolved)



**Notes & Additional**
**Information**



24 (18 resolved, 2 partially resolved)



Protocol Defense Audit − Summary − 3


## **Scope**

We audited <u>[Pull Request #524](https://github.com/matter-labs/era-contracts/pull/524)</u> of the <u>[matter-labs/era-contracts](https://github.com/matter-labs/era-contracts)</u> repository at commit <u>[1957571.](https://github.com/matter-labs/era-contracts/tree/19575710034b16994932a1f055371fccaaaebf6f)</u>


In scope were the following files:

```
.
├── gas-bound-caller
│  └── contracts
│    ├── GasBoundCallerErrors.sol
│    └── GasBoundCaller.sol
├── l1-contracts
│  └── contracts
│    ├── bridge
│    │  ├── interfaces
│    │  │  ├── IL1ERC20Bridge.sol
│    │  │  ├── IL1SharedBridge.sol
│    │  │  ├── IL2Bridge.sol
│    │  │  └── IWETH9.sol
│    │  ├── L1ERC20Bridge.sol
│    │  └── L1SharedBridge.sol
│    ├── bridgehub
│    │  ├── Bridgehub.sol
│    │  └── IBridgehub.sol
│    ├── common
│    │  ├── Config.sol
│    │  ├── Dependencies.sol
│    │  ├── interfaces
│    │  │  └── IL2ContractDeployer.sol
│    │  ├── L1ContractErrors.sol
│    │  ├── L2ContractAddresses.sol
│    │  ├── libraries
│    │  │  ├── L2ContractHelper.sol
│    │  │  ├── SemVer.sol
│    │  │  ├── UncheckedMath.sol
│    │  │  └── UnsafeBytes.sol
│    │  ├── Messaging.sol
│    │  └── ReentrancyGuard.sol
│    ├── governance
│    │  ├── Governance.sol
│    │  └── IGovernance.sol
│    ├── state-transition
│    │  ├── chain-deps
│    │  │  ├── DiamondInit.sol
│    │  │  ├── DiamondProxy.sol
│    │  │  ├── facets
│    │  │  │  ├── Admin.sol
│    │  │  │  ├── Executor.sol
│    │  │  │  ├── Getters.sol

```

Protocol Defense Audit − Scope − 4


```
│    │  │  │  ├── Mailbox.sol
│    │  │  │  └── ZkSyncHyperchainBase.sol
│    │  │  └── ZkSyncHyperchainStorage.sol
│    │  ├── chain-interfaces
│    │  │  ├── IAdmin.sol
│    │  │  ├── IDiamondInit.sol
│    │  │  ├── IExecutor.sol
│    │  │  ├── IGetters.sol
│    │  │  ├── ILegacyGetters.sol
│    │  │  ├── IMailbox.sol
│    │  │  ├── ITransactionFilterer.sol
│    │  │  ├── IVerifier.sol
│    │  │  ├── IZkSyncHyperchainBase.sol
│    │  │  └── IZkSyncHyperchain.sol
│    │  ├── IStateTransitionManager.sol
│    │  ├── l2-deps
│    │  │  └── ISystemContext.sol
│    │  ├── libraries
│    │  │  ├── Diamond.sol
│    │  │  ├── LibMap.sol
│    │  │  ├── Merkle.sol
│    │  │  ├── PriorityQueue.sol
│    │  │  └── TransactionValidator.sol
│    │  ├── StateTransitionManager.sol
│    │  ├── ValidatorTimelock.sol
│    │  └── Verifier.sol
│    ├── upgrades
│    │  ├── BaseZkSyncUpgradeGenesis.sol
│    │  ├── BaseZkSyncUpgrade.sol
│    │  ├── UpgradeHyperchains.sol
│    │  ├── Upgrade_v1_4_1.sol
│    │  └── ZkSyncUpgradeErrors.sol
│    └── vendor
│      └── AddressAliasHelper.sol
├── l2-contracts
│  └── contracts
│    ├── bridge
│    │  ├── interfaces
│    │  │  ├── IL1ERC20Bridge.sol
│    │  │  ├── IL1SharedBridge.sol
│    │  │  ├── IL2SharedBridge.sol
│    │  │  ├── IL2StandardToken.sol
│    │  │  └── IL2WrappedBaseToken.sol
│    │  ├── L2SharedBridge.sol
│    │  ├── L2StandardERC20.sol
│    │  └── L2WrappedBaseToken.sol
│    ├── Dependencies.sol
│    ├── errors
│    │  └── L2ContractErrors.sol
│    ├── interfaces
│    │  ├── IPaymasterFlow.sol
│    │  └── IPaymaster.sol
│    ├── L2ContractHelper.sol
│    ├── SystemContractsCaller.sol
│    ├── TestnetPaymaster.sol
│    └── vendor

```


Protocol Defense Audit − Scope − 5


```
│      └── AddressAliasHelper.sol
└── system-contracts
├── bootloader
│  └── bootloader.yul
└── contracts
├── AccountCodeStorage.sol
├── BootloaderUtilities.sol
├── ComplexUpgrader.sol
├── Compressor.sol
├── Constants.sol
├── ContractDeployer.sol
├── DefaultAccount.sol
├── ImmutableSimulator.sol
├── interfaces
│  ├── IAccountCodeStorage.sol
│  ├── IAccount.sol
│  ├── IBaseToken.sol
│  ├── IBootloaderUtilities.sol
│  ├── IComplexUpgrader.sol
│  ├── ICompressor.sol
│  ├── IContractDeployer.sol
│  ├── IImmutableSimulator.sol
│  ├── IKnownCodesStorage.sol
│  ├── IL1Messenger.sol
│  ├── IL2StandardToken.sol
│  ├── IMailbox.sol
│  ├── INonceHolder.sol
│  ├── IPaymasterFlow.sol
│  ├── IPaymaster.sol
│  ├── IPubdataChunkPublisher.sol
│  ├── ISystemContextDeprecated.sol
│  ├── ISystemContext.sol
│  └── ISystemContract.sol
├── KnownCodesStorage.sol
├── L1Messenger.sol
├── L2BaseToken.sol
├── libraries
│  ├── EfficientCall.sol
│  ├── RLPEncoder.sol
│  ├── SystemContractHelper.sol
│  ├── SystemContractsCaller.sol
│  ├── TransactionHelper.sol
│  ├── UnsafeBytesCalldata.sol
│  └── Utils.sol
├── MsgValueSimulator.sol
├── NonceHolder.sol
├── PubdataChunkPublisher.sol
├── SystemContext.sol
└── SystemContractErrors.sol

```

In addition, we diff-audited the <u>[matter-labs/era-contracts](https://github.com/matter-labs/era-contracts)</u> repository at HEAD commit <u>[874bc6b](https://github.com/matter-labs/era-contracts/tree/874bc6ba940de9d37b474d1e3dda2fe4e869dfbe)</u>

against the BASE commit <u>[7ccade5. The diff-audit covered the following changes](https://github.com/matter-labs/era-contracts/tree/7ccade5560864d1253412cc57b9e160d893cfc68)</u>


  - Updating “zkSync” to “ZKsync”


Protocol Defense Audit − Scope − 6


  - Code clean-up and formatting

  - Removal of <mark>`upgradeSystemContextIfNeeded`</mark> function in <mark>`bootloader.yul`</mark> <mark>.</mark>


All resolutions and the final state of the audited codebase mentioned in this report are

contained at commit <u>[874bc6b.](https://github.com/matter-labs/era-contracts/tree/874bc6ba940de9d37b474d1e3dda2fe4e869dfbe)</u>


Protocol Defense Audit − Scope − 7


## **System Overview**

### **Introduction**

The era-contracts repository is under continuous development and strives to be at the forefront

of quality, maintainability, and readability. By constantly adopting the best practices, the goal is

to make the code more scalable and robust.


This audit primarily focuses on reviewing the following updates to the codebase:


   - Replacing string-based reverts with custom errors.

   - Adding stricter <mark>`solhint`</mark> rules

   - Adding support for version 5 of the OpenZeppelin library.

   - Utilizing floating pragmas for interfaces and libraries.

  - Implementing minor gas optimization changes.


Given the extensive list of the in-scope files, this audit is only a diff audit, primarily focusing on

the changes made rather than the entire files.


Protocol Defense Audit − System Overview − 8


## **Low Severity**

### **L-01 Misleading Errors**

Throughout the codebase, some errors are misleading or do not provide enough information

about the root cause:


   - The <u><mark>`[ValueMismatch(uint256 expected, uint256 actual)](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L9)`</mark></u> custom error is not

suitable for use in scenarios where a token transfer does not transfer the exact specified

amount due to fees or other non-standard transfer logic. For instance, in the <u><mark>`[deposit](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L147)`</mark></u>

function of the <mark>`L1ERC20Bridge`</mark> contract, the error message does not provide relevant

information for the end user as the user is not aware of the internal <mark>`amount`</mark> variable.

This lack of clarity may lead users to retry the transaction with the other amount shown

in the error instead of using a different token. A similar issue occurs in the

<u><mark>`[bridgehubDepositBaseToken](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/bridge/L1SharedBridge.sol#L240)`</mark></u> function of the <mark>`L1SharedBridge`</mark> contract. As such,

consider changing the error message to clearer alternatives like

<u><mark>`[TokenNotSupported(address token)](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L25)`</mark></u> or <mark>`TokensWithFeesNotSupported()`</mark> <mark>.</mark>

The former is already included in <mark>`L1ContractErrors.sol`</mark> while the latter provides

more information to the end user and is cheaper as it does not have parameters.


   - The <u><mark>`[unfreezeDiamond](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L171)`</mark></u> <u>function</u> reverts with the <u><mark>`[DiamondAlreadyFrozen](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L176)`</mark></u> error

when the diamond is not frozen. Consider adding a new error (e.g.,

<mark>`DiamondNotFrozen`</mark> <mark>)</mark> to clearly demonstrate the actual issue.


   - Within the <u><mark>`[Compressor](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/Compressor.sol)`</mark></u> contract, the <u><mark>`[ValuesNotEqual](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/SystemContractErrors.sol#L18)`</mark></u> error does not specify what

values are being compared, making debugging difficult due to the lack of context. This

error is used in multiple places for different types of comparisons (e.g., initial writes,

enum indices, and final values), making it hard to trace the specific issue when the error

is thrown. Consider creating specific errors for each type of value mismatch or include

additional parameters that provide relevant context such as which part of the process

failed.


   - The <u><mark>`[DictionaryLengthNotFourTimesSmallerThanEncoded](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/Compressor.sol#L57)`</mark></u> error does not

accurately describe the condition being checked. The actual condition being checked is

whether the dictionary length divided by 8 is greater than the encoded data length

divided by 2. The error message should be more descriptive and precise to reflect this

condition accurately.


Protocol Defense Audit − Low Severity − 9


**_Update:_** _Resolved in_ _<u>[pull request #569](https://github.com/matter-labs/era-contracts/pull/569)</u>_ _at commit_ _<u>[815b737.](https://github.com/matter-labs/era-contracts/pull/569/commits/815b737eb45b088c68b199d1113c548959ac8641)</u>_

### **L-02 Inconsistent Input Validation**


Throughout the codebase, several inconsistencies in input validations were found. The

following is a non-extensive listing of instances that serve as a reference.


For example, in <mark>`UpgradeHyperchains`</mark> <mark>,</mark> the <u><mark>`[upgrade](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/upgrades/UpgradeHyperchains.sol#L16)`</mark></u> <u>function</u> validates the values of the

<mark>`chainId`</mark> <mark>,</mark> the <mark>`bridgehubAddress`</mark> <mark>,</mark> the <mark>`stateTransitionManager`</mark> <mark>,</mark> and the

<mark>`sharedBridgeAddress`</mark> parameters. However, the <u><mark>`[chainAdmin](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/upgrades/UpgradeHyperchains.sol#L22)`</mark></u> and

<u><mark>`[validatorTimelock](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/upgrades/UpgradeHyperchains.sol#L23)`</mark></u> inputs lack validation, allowing to migrate the Era-blockchain to the

hyperchain ecosystem without setting a valid admin or timelock validator. This could impact

the finalization of transactions and disable all critical guarded functions for the admin if invalid

values are passed to the <mark>`upgrade`</mark> function.


Moreover, in the <u><mark>`[AdminFacet](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol)`</mark></u> <u>contract, the following inputs are not validated in their</u>

respective functions:


   - The <u><mark>`[_stateTransitionManager](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L82)`</mark></u> input is not validated in the

<u><mark>`[setStateTransitionManager](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L81)`</mark></u> <u>function.</u>

   - The <u><mark>`[_newPendingAdmin](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L28)`</mark></u> input is not validated in the <u><mark>`[setPendingAdmin](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L24)`</mark></u> <u>function.</u>

   - The <u><mark>`[_validator](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L50)`</mark></u> input is not validated in the <u><mark>`[setValidator](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L49)`</mark></u> <u>function.</u>


The aforementioned instances illustrate inconsistencies in input validation when changing key

ecosystem values. In favor of standardization, consider revisiting the input validation for all

functions that modify fundamental values and try to adopt a consistent validation scheme.


**_Update:_** _Partially resolved in_ _<u>[pull request #570](https://github.com/matter-labs/era-contracts/pull/570)</u>_ _at commit_ _<u>[f5ad651. The Matter Labs team](https://github.com/matter-labs/era-contracts/pull/570/commits/f5ad6517a960e3623f6daba23e6d7e8ab1d50cf7)</u>_

_stated:_


_Given that these are only callable by the owner of the contract and used in scripts/tests_

_we are less concerned with validation on the inputs for the additional cost._

### **L-03 getAllHyperchains Function Reverts Due** **to Invalid Key Access**


Recent changes to the <u><mark>`[getAllHyperchains](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L105)`</mark></u> function have introduced an issue where the

function attempts to retrieve values from the <mark>`hyperchainMap`</mark> using indices rather than valid

chain IDs. The previous implementation used <mark>`hyperchainMap.get(keys[i])`</mark> <mark>,</mark> where


Protocol Defense Audit − Low Severity − 10


<mark>`keys[i]`</mark> are valid chain IDs. However, the new implementation uses

<mark>`hyperchainMap.get(i)`</mark> <mark>,</mark> which refers to the loop counter. Since `i` may not correspond to

a valid chain ID, the function may revert when accessing invalid keys such as chain ID 0 or 2.

This results in the <mark>`getAllHyperchains`</mark> function reverting for all calls, rendering it unusable.


Consider reverting to the previous implementation which ensures that only valid chain IDs from

the <mark>`keys`</mark> array are used to access the <mark>`hyperchainMap`</mark> <mark>.</mark> This will ensure that only valid chain

IDs are used and prevent the function from reverting.


**_Update:_** _Resolved in_ _<u>[pull request #571](https://github.com/matter-labs/era-contracts/pull/571)</u>_ _at commit_ _<u>[7a7174e.](https://github.com/matter-labs/era-contracts/pull/571/commits/7a7174e6f0f268075d538e5b70d6da05ed69442c)</u>_

## **Notes & Additional** **Information**

### **N-01 Standardize Custom Error for Consistency**


The contracts currently use multiple custom errors for the same underlying errors, resulting in

inconsistency and potential confusion. Some examples are:












<u><mark>`[InvalidCaller](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l2-contracts/contracts/errors/L2ContractErrors.sol#L6)`</mark></u> and <u><mark>`[Unauthorized](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L5)`</mark></u>

<u><mark>`[EmptyAddress](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l2-contracts/contracts/errors/L2ContractErrors.sol#L16)`</mark></u> and <u><mark>`[ZeroAddress](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L13)`</mark></u>

<u><mark>`[WithdrawFailed](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L43)`</mark></u> and <u><mark>`[WithdrawalFailed](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L199)`</mark></u>

<u><mark>`[ValuesNotEqual](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/SystemContractErrors.sol#L18)`</mark></u> and <u><mark>`[ValueMismatch](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L9)`</mark></u>

<u><mark>`[ProtocolVersionShouldBeGreater](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol#L6)`</mark></u> and <u><mark>`[ProtocolVersionTooSmall](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L273)`</mark></u>

<mark>`OnlyEraSupported`</mark> <u>[[1]](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L48)</u> <u>[[2]](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L228)</u> and <u><mark>`[LegacyMethodIsSupportedOnlyForEra](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L205)`</mark></u>



To enhance standardization and clarity, consider selecting and consistently using the error

names that best reflect the error cause. This will help improve code readability and

maintenance.


**_Update:_** _Resolved in_ _<u>[pull request #572](https://github.com/matter-labs/era-contracts/pull/572)</u>_ _at commit_ _<u>[96a53cc.](https://github.com/matter-labs/era-contracts/pull/572/commits/96a53cc31d88cee18249e28f5477a832d2e5d2a4)</u>_

### **N-02 Typographical Errors**


The following typographical errors were identified in the codebase:







<u><mark>`[ShareadBridgeValueNotSet](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L41)`</mark></u> should be <mark>`SharedBridgeValueNotSet`</mark>


Protocol Defense Audit − Notes & Additional Information − 11


<u><mark>`[_oldprotocolVersionDeadline](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/IStateTransitionManager.sol#L121)`</mark></u> should be <mark>`_oldProtocolVersionDeadline`</mark>




   - <u>[encure](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L364)</u> should be incur.


Consider fixing the aforementioned typographical errors in order to improve the readability of

the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #573](https://github.com/matter-labs/era-contracts/pull/573)</u>_ _at commit_ _<u>[1934420.](https://github.com/matter-labs/era-contracts/pull/573/commits/19344203d9fb81649b98ba26bb5feba5c20f7dc1)</u>_

### **N-03 Duplicate Error Import**


The <mark>`L1SharedBridge`</mark> contract currently imports the <u><mark>`[WithdrawalFailed](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/bridge/L1SharedBridge.sol#L25)`</mark></u> error twice. This

redundancy can lead to confusion and maintainability issues.


Consider removing one of the import statements to enhance code clarity and maintainability.


**_Update:_** _Resolved in_ _<u>[pull request #572](https://github.com/matter-labs/era-contracts/pull/572)</u>_ _at commit_ _<u>[96a53cc.](https://github.com/matter-labs/era-contracts/pull/572/commits/96a53cc31d88cee18249e28f5477a832d2e5d2a4)</u>_

### **N-04 Risk with Floating Pragma and Yul** **Optimizer Bug**


The audited refactor introduced the use of a floating pragma with a minimum version

requirement of <mark>`0.8.20`</mark> for all interfaces and libraries. This change potentially exposes users

to a <u>[known bug](https://soliditylang.org/blog/2023/07/19/full-inliner-non-expression-split-argument-evaluation-order-bug/)</u> in the Yul optimizer, specifically related to the <mark>`FullInliner`</mark> step when using

a custom optimizer step sequence.


Although the likelihood of encountering this bug is low, it can alter the behavior of contracts by

reordering function call arguments with side effects. To prevent this issue, consider updating

the floating pragma to start from Solidity version <mark>`0.8.21`</mark> instead of <mark>`0.8.20`</mark> or include a

disclaimer to inform users about the potential risk.


**_Update:_** _Resolved in_ _<u>[pull request #574](https://github.com/matter-labs/era-contracts/pull/574)</u>_ _at commit_ _<u>[e3423ed.](https://github.com/matter-labs/era-contracts/pull/574/commits/e3423ed405e5dadbca1f0558c130b5c38e635424)</u>_

### **N-05 Unused Errors**


Throughout the codebase, there are a few instances of unused errors:









<u><mark>`[ProtocolVersionTooBig](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L275)`</mark></u> in <mark>`L1ContractErrors.sol`</mark>

<u><mark>`[EncodingLengthMismatch](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/SystemContractErrors.sol#L14)`</mark></u> in <mark>`SystemContractErrors.sol`</mark>

<u><mark>`[InvalidData](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/SystemContractErrors.sol#L84)`</mark></u> in <mark>`SystemContractErrors.sol`</mark>


Protocol Defense Audit − Notes & Additional Information − 12


To improve the codebase's overall clarity, intentionality, and readability, consider removing any

currently unused errors.


**_Update:_** _Resolved in_ _<u>[pull request #575](https://github.com/matter-labs/era-contracts/pull/575)</u>_ _at commit_ _<u>[dff8431.](https://github.com/matter-labs/era-contracts/pull/575/commits/dff843168a95e3456c39fd17fc365868aea394b4)</u>_

### **N-06 Improved Organization of Error Files**


Maintaining a clear and organized structure for error files is crucial for enhancing maintainability

and readability. Currently, the errors within these files lack any consistent organization, making

it difficult to identify and manage duplicate or unused errors.


Consider ordering errors alphabetically or grouping them by category. This approach will

facilitate easier navigation and management of the error files, helping developers identify and

resolve issues quickly.


**_Update:_** _Resolved in_ _<u>[pull request #576](https://github.com/matter-labs/era-contracts/pull/576)</u>_ _at commit_ _<u>[a165cb2.](https://github.com/matter-labs/era-contracts/pull/576/commits/a165cb285353d87ff2b423f087fb85214f0f80d6)</u>_

### **N-07 Naming Issues**


Throughout the codebase, several error declarations could be renamed to better reflect their

purpose:




- <u><mark>`[OperationShouldBeReady](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L67)`</mark></u> can be renamed to <mark>`OperationMustBeReady`</mark> <mark>.</mark>

- <u><mark>`[OperationShouldBePending](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L69)`</mark></u> can be renamed to <mark>`OperationMustBePending`</mark> <mark>.</mark>

- <u><mark>`[PubdataAllowanceAndGasLeftLessThanPubdataGasAndOverhead](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/gas-bound-caller/contracts/GasBoundCallerErrors.sol#L8)`</mark></u> can be

renamed to <mark>`NotEnoughGasForPubdata`</mark> <mark>.</mark>




- <u><mark>`[RevertedBatchBeforeNewBatch](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L557)`</mark></u> can be renamed to

<mark>`RevertedBatchNotAfterNewLastBatch`</mark> <mark>.</mark>

- <u><mark>`[VerifyProofCommittedVerifiedMismatch](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L511)`</mark></u> can be renamed to

<mark>`VerifiedBatchesExceedsCommittedBatches`</mark> <mark>.</mark>

- <u><mark>`[PubdataPerBatchIsLessThanTxn](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L77)`</mark></u> could be renamed to

<mark>`PriorityTxPubdataExceedsMaxPubDataPerBatch`</mark> <mark>.</mark>

- <u><mark>`[MaxGasLessThanGasLeft](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/gas-bound-caller/contracts/GasBoundCallerErrors.sol#L6)`</mark></u> can be renamed to <mark>`InsufficientGasProvided`</mark> <mark>.</mark> The



error declaration could benefit from two parameters for additional information like

<mark>`uint256 requiredGas`</mark> and <mark>`uint256 providedGas`</mark> <mark>.</mark>


Consider addressing these naming issues to improve the readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #577](https://github.com/matter-labs/era-contracts/pull/577)</u>_ _at commit_ _<u>[39d8e3c.](https://github.com/matter-labs/era-contracts/pull/577/commits/39d8e3cf14112dacbbcfb55c238a66aca5be6785)</u>_


Protocol Defense Audit − Notes & Additional Information − 13


### **N-08 Unnamed Error Parameters**

Throughout the codebase, there are multiple error declarations with unnamed parameters:









```
LogAlreadyProcessed(uint8)
InvalidCaller(address)
UnimplementedMessage(string)
PointEvalCallFailed(bytes)

```


Instead of just specifying the type, including a descriptive name for each parameter makes the

purpose of the error more clear and the code more self-documenting. Consider naming

parameters within error declarations to significantly enhance code readability and

maintainability.


**_Update:_** _Resolved in_ _<u>[pull request #578](https://github.com/matter-labs/era-contracts/pull/578)</u>_ _at commit_ _<u>[1d0c4bb.](https://github.com/matter-labs/era-contracts/pull/578/commits/1d0c4bb9d48405794494481b590b5f06f98cd400)</u>_

### **N-09 Misleading Use of "I" Prefix in Abstract** **Contract**


Using the "I" prefix for abstract contracts is generally not recommended as it is conventionally

reserved for interfaces. Mixing this convention could lead to confusion. The file name

<u><mark>`[ISystemContract](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/interfaces/ISystemContract.sol)`</mark></u> uses this prefix even though it is an abstract contract.


Consider renaming this contract to avoid confusion. For example, use

<mark>`SystemContractBase`</mark> or a similar name which indicates that it is an abstract contract rather

than an interface.


**_Update:_** _Resolved in_ _<u>[pull request #579](https://github.com/matter-labs/era-contracts/pull/579)</u>_ _at commit_ _<u>[2ff66f9](https://github.com/matter-labs/era-contracts/pull/579/commits/2ff66f9d9a3d9b9ea069a7e788c3055dc4545bbf)</u>_

### **N-10 Unused Enum**


The <u><mark>`[Global](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/libraries/SystemContractHelper.sol#L25-L31)`</mark></u> <u>enum</u> in <mark>`SystemContractHelper.sol`</mark> is unused.


To improve the overall readability of the codebase, consider either using or removing any

currently unused enums.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We decided to keep for now until we can be sure that this isn't used anywhere in our_

_ecosystem._


Protocol Defense Audit − Notes & Additional Information − 14


### **N-11 File and Contract Names Mismatch**

Throughout the codebase, there are multiple file names containing contracts with different

names:


   - The <u><mark>`[Admin.sol](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol)`</mark></u> <u>fle namei</u> does not match the <mark>`AdminFacet`</mark> contract name.

   - The <u><mark>`[Executor.sol](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol)`</mark></u> <u>fle namei</u> does not match the <mark>`ExecutorFacet`</mark> contract name.

   - The <u><mark>`[Getters.sol](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Getters.sol)`</mark></u> <u>fle namei</u> does not match the <mark>`GettersFacet`</mark> contract name.

   - The <u><mark>`[Mailbox.sol](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol)`</mark></u> <u>fle namei</u> does not match the <mark>`MailboxFacet`</mark> contract name.


To make the codebase easier to understand for developers and reviewers, consider renaming

the files to match the contract names.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_This is to make sure that we know these contracts are used within our DiamondProxy_

_and not standalone._

### **N-12 Misplaced Error Declarations**


The following <u>[list of errors](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/L1ContractErrors.sol#L266-L285)</u> should be declared in <u><mark>`[ZkSyncUpgradeErrors.sol](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/upgrades/ZkSyncUpgradeErrors.sol)`</mark></u> <mark>:</mark>















```
PatchCantSetUpgradeTxn
L2UpgradeNonceNotEqualToNewProtocolVersion
L2BytecodeHashMismatch
ProtocolVersionTooSmall
ProtocolVersionTooBig
PreviousProtocolMajorVersionNotZero
NewProtocolMajorVersionNotZero
ProtocolVersionMinorDeltaTooBig
PatchUpgradeCantSetDefaultAccount
PatchUpgradeCantSetBootloader

```


To improve standardization and clarity, consider declaring errors in their designated file.


**_Update:_** _Resolved in_ _<u>[pull request #580](https://github.com/matter-labs/era-contracts/pull/580)</u>_ _at commit_ _<u>[9ec05f3.](https://github.com/matter-labs/era-contracts/pull/580/commits/9ec05f38b8f7de15dbad06c98fefcdc0ac3ce830)</u>_


Protocol Defense Audit − Notes & Additional Information − 15


### **N-13 Unused Named Return Variable**

Named return variables are a way to declare variables that are meant to be used within a

function's body for the purpose of being returned as that function's output. They are an

alternative to explicit in-line <mark>`return`</mark> statements.


In <mark>`TestnetPaymaster.sol`</mark> <mark>,</mark> the <u><mark>`[context](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l2-contracts/contracts/TestnetPaymaster.sol#L19)`</mark></u> <u>[return variable](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l2-contracts/contracts/TestnetPaymaster.sol#L19)</u> for the

<mark>`validateAndPayForPaymasterTransaction`</mark> function is unused.


Consider either using or removing any unused named return variables.


**_Update:_** _Resolved in_ _<u>[pull request #581](https://github.com/matter-labs/era-contracts/pull/581)</u>_ _at commit_ _<u>[8c5758c.](https://github.com/matter-labs/era-contracts/pull/581/commits/8c5758c7a3dde18aa55dfc8c8e0e6596ef941736)</u>_

### **N-14 Constants Not Using UPPER_CASE Format**


Throughout the codebase, there are constants that have not been declared using the

<mark>`UPPER_CASE`</mark> format:


   - The <mark>`offset`</mark> constant declared on <u>[line 22](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/vendor/AddressAliasHelper.sol#L22)</u> in <mark>`AddressAliasHelper.sol`</mark> <mark>(</mark> <mark>`l1-`</mark>

<mark>`contracts`</mark> directory)

   - The <mark>`offset`</mark> constant declared on <u>[line 22](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l2-contracts/contracts/vendor/AddressAliasHelper.sol#L22)</u> in <mark>`AddressAliasHelper.sol`</mark> <mark>(</mark> <mark>`l2-`</mark>

<mark>`contracts`</mark> directory)


According to the <u>[Solidity Style Guide, constants should be named in all capital letters with](https://docs.soliditylang.org/en/latest/style-guide.html#constants)</u>

underscores separating words. For better code readability, consider following this convention.


**_Update:_** _Acknowledged, not resolved. The Matter Labs team stated:_


_We decided to leave this as is for the time being and will do a deeper dive on potential_

_implications when changing it._

### **N-15 Unnecessary Casts**


Throughout the codebase, there are instances of unnecessary casts:


   - The <u><mark>`[uint256(protocolVersion)](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L428)`</mark></u> <u>cast</u> in the <mark>`StateTransitionManager`</mark>

contract.

   - The <u><mark>`[bytes32(storedBatchZero)](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L433)`</mark></u> <u>cast</u> in the <mark>`StateTransitionManager`</mark>

contract.


Protocol Defense Audit − Notes & Additional Information − 16


   - The <u><mark>`[uint32(Utils.safeCastToU32(data.length))](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l2-contracts/contracts/SystemContractsCaller.sol#L51)`</mark></u> <u>cast</u> in the

<mark>`SystemContractsCaller`</mark> contract.

   - The <u><mark>`[uint32(Utils.safeCastToU32(data.length))](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/libraries/SystemContractsCaller.sol#L83)`</mark></u> <u>cast</u> in the

<mark>`SystemContractsCaller`</mark> contract.


To improve the overall clarity, intent, and readability of the codebase, consider removing

unnecessary casts.


**_Update:_** _Resolved in_ _<u>[pull request #582](https://github.com/matter-labs/era-contracts/pull/582)</u>_ _at commit_ _<u>[a0d9e9a.](https://github.com/matter-labs/era-contracts/pull/582/commits/a0d9e9a344c883bf3f5e43cfc6e2c46ac7d75c6e)</u>_

### **N-16 Risk of Disabling Valid Warnings**


Solhint and Slither offer developers the flexibility to enforce the rules or detectors they find

valuable. Even when rules are generally followed, it is common to use the <mark>`disable-next-`</mark>

<mark>`line`</mark> comment to disable a rule for a specific line when necessary. However, an issue arises

when two such comments are used consecutively, one for each tool. In this situation, the first

comment does not affect the intended line if it is immediately followed by the other tool's

comment.


To circumvent this issue within the codebase, the <mark>`solhint-disable`</mark> is used for Solhint and

<mark>`slither-disable-next-line`</mark> for Slither. The problem with this approach is that

<mark>`solhint-disable`</mark> disables the targeted rule for the rest of the file, potentially ignoring

legitimate warnings in the subsequent lines rather than just the specific instance.


Examples of this misuse include:


   - <u>[line 303](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L303)</u> in <mark>`Mailbox.sol`</mark>

   - <u>[line 54](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/vendor/AddressAliasHelper.sol#L54)</u> in <mark>`AddressAliasHelper.sol`</mark>


Consider using <mark>`solhint-disable-line`</mark> directly on the target line or disable the rules for a

group of lines as documented in the <u>[Solhint guidelines. This method prevents unintentional](https://protofire.github.io/solhint/#configure-the-linter-with-comments)</u>

suppression of valid warnings and maintains code quality.


**_Update:_** _Resolved in_ _<u>[pull request #583](https://github.com/matter-labs/era-contracts/pull/583)</u>_ _at commit_ _<u>[d05d292.](https://github.com/matter-labs/era-contracts/pull/583/commits/d05d292e2ef81894ef051a6c085ee452eefa8017)</u>_

### **N-17 Unjustified Use of solhint-disable** **Comments**


Multiple instances of <mark>`solhint-disable`</mark> comments are present in the code without proper

justification. This practice can give the impression that there is no intention to address the


Protocol Defense Audit − Notes & Additional Information − 17


underlying warnings, which may lead to reduced code quality and maintainability. Examples

include:


   - <u>[Line 167](https://github.com/matter-labs/era-contracts/blob/994897b14eb1d8e77c809da2db3379e7b58125b5/l1-contracts/contracts/bridge/L1ERC20Bridge.sol#L167)</u> of <mark>`L1ERC20Bridge.sol`</mark>

   - <u>[Line 308](https://github.com/matter-labs/era-contracts/blob/994897b14eb1d8e77c809da2db3379e7b58125b5/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L308)</u> of <mark>`Executor.sol`</mark>

   - <u>[Line 3](https://github.com/matter-labs/era-contracts/blob/994897b14eb1d8e77c809da2db3379e7b58125b5/l2-contracts/contracts/SystemContractsCaller.sol#L3)</u> of <mark>`SystemContractsCaller.sol`</mark>

   - <u>[Line 56](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/system-contracts/contracts/libraries/SystemContractHelper.sol#L56)</u> of <mark>`SystemContractHelper.sol`</mark>


Consider adding comments to explain the rationale for disabling the rules or. Alternatively, fix

the warnings to follow best practices.


**_Update:_** _Partially resolved in_ _<u>[pull request #585](https://github.com/matter-labs/era-contracts/pull/585)</u>_ _at commit_ _<u>[433be7e.](https://github.com/matter-labs/era-contracts/pull/585/commits/433be7e62973fd2a99bc17ffa19d4338326768b6)</u>_

### **N-18 Inconsistent Application of Solhint Rule** **`gas-length-in-loops`**


The use of the <mark>`solhint-disable`</mark> statement for the <mark>`gas-length-in-loops`</mark> rule appears

to be applied arbitrarily across the codebase. For instance, in the <mark>`Executor`</mark> contract, <u>[some](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L181)</u>

<mark>`for`</mark> loops cache the length of arrays to optimize gas usage, while <u>[others](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L338)</u> use the <mark>`solhint-`</mark>

<mark>`disable`</mark> statement without clear justification, such as avoiding a "stack too deep" error. This

inconsistency may lead to unnecessary gas consumption and reduce the clarity of the code.


For consistency and gas savings, consider caching the length of arrays in all <mark>`for`</mark> loops. If

there are specific reasons for not caching the length, such as the "stack too deep" error, inline

comments should be added to explain these exceptions.


**_Update:_** _Resolved in_ _<u>[pull request #584](https://github.com/matter-labs/era-contracts/pull/584)</u>_ _at commit_ _<u>[0b7c75f.](https://github.com/matter-labs/era-contracts/pull/584/commits/0b7c75ff69a2f5040f0576965f5acbc1a9ec23b4)</u>_

### **N-19 Duplicate Code**


In <mark>`Executor.sol`</mark> <mark>,</mark> the computation on <u>[line 75](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L75)</u> is unnecessarily repeated on <u>[line 78. This may](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L78)</u>

lead to unnecessary gas consumption and reduce code clarity.


Rather than duplicating code, consider caching the values of complex computation in a

variable and using it whenever the duplicated value is required.


**_Update:_** _Resolved in_ _<u>[pull request #586](https://github.com/matter-labs/era-contracts/pull/586)</u>_ _at commit_ _<u>[245d985.](https://github.com/matter-labs/era-contracts/pull/586/commits/245d985fe7eb19b7b3c01f06d2e147c87782adc7)</u>_


Protocol Defense Audit − Notes & Additional Information − 18


### **N-20 Overly Exposed State Variable**

In <mark>`StateTransitionManager`</mark> <mark>,</mark> the state variable <u><mark>`[protocolVersion](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L54)`</mark></u> <mark>'</mark> s visibility is set to

<mark>`public`</mark> <mark>.</mark> The <mark>`protocolVersion`</mark> represents a packed semantic version. The

<u><mark>`[getSemverProtocolVersion](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/StateTransitionManager.sol#L99)`</mark></u> function gives access to human-readable version. Having

two separate endpoints to retrieve the version with different formatting could be confusing. In

addition, the following constant state variables are only used in the contracts they are declared

in. For instance:


   - The <u><mark>`[EMPTY_STRING_KECCAK](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/AccountCodeStorage.sol#L24)`</mark></u> <u>constant</u> in the <mark>`AccountCodeStorage`</mark> contract

   - The <u><mark>`[GAS_TO_PASS](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/MsgValueSimulator.sol#L37)`</mark></u> <u>constant</u> in the <mark>`MsgValueSimulator`</mark> contract

   - The <u><mark>`[MSG_VALUE_SIMULATOR_STIPEND_GAS](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/contracts/MsgValueSimulator.sol#L42)`</mark></u> <u>constant</u> in the <mark>`MsgValueSimulator`</mark>

contract


To better convey the intended use of functions and state variables to potentially realize some

additional gas savings, consider restricting the aforementioned state variables to private.


**_Update:_** _Partially resolved in_ _<u>[pull request #587](https://github.com/matter-labs/era-contracts/pull/587)</u>_ _at commit_ _<u>[bd3504a.](https://github.com/matter-labs/era-contracts/pull/587/commits/bd3504a65509719457231b46c99adc921787f85e)</u>_

### **N-21 Inconsistent Initialization of Local Variables**


Throughout the codebase, some local variables are implicitly initialized to their default value.

For instance:


   - The <u><mark>`[processedLogs](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L180)`</mark></u> local variable in <mark>`Executor.sol`</mark>

   - The <u><mark>`[reconstructedChainedLogsHash](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/system-contracts/contracts/L1Messenger.sol#L212)`</mark></u> local variable in <mark>`L1Messenger.sol`</mark>

   - The <u><mark>`[reconstructedChainedMessagesHash](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/system-contracts/contracts/L1Messenger.sol#L241)`</mark></u> local variable in <mark>`L1Messenger.sol`</mark>

   - The <u><mark>`[reconstructedChainedL1BytecodesRevealDataHash](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/system-contracts/contracts/L1Messenger.sol#L258)`</mark></u> local variable in
```
   L1Messenger.sol

```

In other instances, local variables have been explicitly initialized to their default values. For

instance:


   - The <u><mark>`[versionedHashIndex](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L719)`</mark></u> <u>variable</u> in <mark>`Executor.sol`</mark>

   - The <u><mark>`[calldataPtr](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/system-contracts/contracts/L1Messenger.sol#L198)`</mark></u> <u>variable</u> in <mark>`L1Messenger.sol`</mark>

   - The <u><mark>`[costForPubdata](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/l1-contracts/contracts/state-transition/libraries/TransactionValidator.sol#L124)`</mark></u> <u>variable</u> in <mark>`TransactionValidator.sol`</mark>


To improve the overall clarity, intent, consistency, and readability of the codebase, consider

explicitly initializing all local variables.


**_Update:_** _Resolved in_ _<u>[pull request #588](https://github.com/matter-labs/era-contracts/pull/588)</u>_ _at commit_ _<u>[f69ae9c.](https://github.com/matter-labs/era-contracts/pull/588/commits/f69ae9ce3f208939521fc5e5096d689cd008cff2)</u>_


Protocol Defense Audit − Notes & Additional Information − 19


### **N-22 Todo Comments in the Code**

During development, having well-described TODO comments will make the process of tracking

and solving them easier. Without this information, these comments might age and important

information for the security of the system might be forgotten by the time it is released to

production. These comments should be tracked in the project's issue backlog and resolved

before the system is deployed.


Throughout the codebase, multiple instances of TODO comments were found:


   - The <mark>`TODO`</mark> comment in <u>[line 21](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/l1-contracts/contracts/common/Config.sol#L21)</u> of <mark>`Config.sol`</mark> <mark>.</mark>

   - The <mark>`TODO`</mark> comment in <u>[line 361](https://github.com/matter-labs/era-contracts/blob/1561905dc18043e6f002b3d87f960f6b33fbe84b/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L361)</u> of <mark>`Mailbox.sol`</mark> <mark>.</mark>


Consider removing all instances of TODO comments and instead tracking them in the issues

backlog. Alternatively, consider linking each inline TODO to the corresponding issues backlog

entry.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_We have tags to our internal task tracker to show we're planning on fixing the todo's._

### **N-23 Misleading Documentation**


Throughout the codebase, there are multiple instances of misleading documentation:


   - This <u>[comment](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/ReentrancyGuard.sol#L78)</u> should be placed between <u>[lines 81 and 82.](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/common/ReentrancyGuard.sol#L81-L82)</u>

   - There is a missing word between <u>["that the" and "is not overriden".](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol#L304)</u>

   - The <u>[comment](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/upgrades/BaseZkSyncUpgradeGenesis.sol#L23)</u> in <mark>`BaseZkSyncUpgradeGenesis.sol`</mark> describes the difference from

<u><mark>`[BaseZkSyncUpgrade.sol](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/upgrades/BaseZkSyncUpgrade.sol)`</mark></u> <mark>.</mark> The following comparison change <mark>`> to >=`</mark> should be

changed to <mark>`<= to <`</mark> <mark>.</mark>

  - The comments about the <u><mark>`[MAX_ALLOWED_FAIR_PUBDATA_PRICE](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/bootloader/bootloader.yul#L15)`</mark></u> and

<u><mark>`[MAX_ALLOWED_FAIR_L2_GAS_PRICE](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/system-contracts/bootloader/bootloader.yul#L20)`</mark></u> are incorrect. The values are in wei, not in gwei.

Additionally, providing more context on why <mark>`2^64 - 1`</mark> was chosen would be

beneficial.


Consider correcting the documentation to align with the code's behavior. This will help improve

the clarity and readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #589](https://github.com/matter-labs/era-contracts/pull/589)</u>_ _at commit_ _<u>[a6d48f4.](https://github.com/matter-labs/era-contracts/pull/589/commits/a6d48f4a017cd1a231b6015bf081f30553072ee8)</u>_


Protocol Defense Audit − Notes & Additional Information − 20


### **N-24 Lack of Indexed Event Parameters**

<u>[Indexing event parameters](https://docs.soliditylang.org/en/v0.8.24/contracts.html#events)</u> facilitates the task of off-chain services searching and filtering for

specific events. In particular, the <u><mark>`[NewPriorityRequest](https://github.com/matter-labs/era-contracts/blob/19575710034b16994932a1f055371fccaaaebf6f/l1-contracts/contracts/state-transition/chain-interfaces/IMailbox.sol#L123-L129)`</mark></u> <u>event</u> may benefit from the addition

of the <mark>`indexed`</mark> keyword to the <mark>`txId`</mark> and <mark>`txHash`</mark> parameters.


Consider indexing these event parameters to avoid hindering off-chain services from searching

and filtering for specific events.


**_Update:_** _Resolved in_ _<u>[pull request #590](https://github.com/matter-labs/era-contracts/pull/590)</u>_ _at commit_ _<u>[ea7cd15.](https://github.com/matter-labs/era-contracts/pull/590/commits/ea7cd159f36af6aeeaf45328216ddfae1c7327a5)</u>_


Protocol Defense Audit − Notes & Additional Information − 21


## **Conclusion**

The era-contracts repository continues to evolve, focusing on quality, maintainability, and

scalability by adopting best practices. This audit reviewed updates such as replacing string
based reverts with custom errors, adding stricter solhint rules, supporting version 5 of the

OpenZeppelin library, utilizing floating pragmas for interfaces and libraries, and implementing

minor gas optimizations.


The audit yielded three low-severity issues along with several recommendations for code

improvement. The changes to the codebase were well-written, straightforward to follow, and

well-documented. The Matter Labs team was very responsive throughout the engagement and

answered all our questions.


Protocol Defense Audit − Conclusion − 22


