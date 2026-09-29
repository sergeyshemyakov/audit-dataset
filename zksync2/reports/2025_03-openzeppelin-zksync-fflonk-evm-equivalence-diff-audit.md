### | security

# **FFLONK and EVM** **Equivalence Diff** **Audit**

#### **March 4, 2025**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  7

EVM Equivalence 7

Verifiers 7


Security Model and Trust Assumptions _______________________________________________  7


Medium Severity ___________________________________________________________________  8

M-01 Bytecode Hash Restoration Failure with forcedSload for EVM Contracts 8


Low Severity ______________________________________________________________________  9

L-01 Ambiguity in Verification Key Hash Retrieval in DualVerifier 9

L-02 Lack of Validation of l2EvmEmulatorBytecodeHash in DiamondInit 9


Notes & Additional Information ____________________________________________________ 10

N-01 TestnetVerifier Can Be Deployed on ZK Gateway 10

N-02 Gas Inefficiency in _extractProof 10

N-03 Inconsistent or Incomplete Documentation Across the Codebase 11


Conclusion ______________________________________________________________________ 12


FFLONK and EVM Equivalence Diff Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2025-01-30
To 2025-02-11


**Languages** Solidity
Yul



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



**Total Issues** 6 (5 resolved)



**Low Severity Issues** 2 (2 resolved)



**Notes & Additional**
**Information**



3 (2 resolved)



FFLONK and EVM Equivalence Diff Audit − Summary − 3


## **Scope**

We conducted a diff audit of the <u>[matter-labs/era-contracts](https://github.com/matter-labs/era-contracts/)</u> repository by comparing the HEAD

[commit 5731979](https://github.com/matter-labs/era-contracts/tree/5731979de1e1a81483503f4f580d2ae96bdaeb95) against the base commits listed in the scope tree for each file. We also

conducted a full audit of files marked with the <mark>`full`</mark> label in the scope tree.


In scope were the following files:

```
.
├── l1-contracts
│  ├── contracts
│  │  ├── common
│  │  │  ├── Config.sol (`fe838fc`)
│  │  │  ├── L1ContractErrors.sol (`d7fabf85`)
│  │  │  └── interfaces
│  │  │    └── IL2ContractDeployer.sol (`fe838fc`)
│  │  ├── governance
│  │  │  ├── ChainAdmin.sol (`21ac083`)
│  │  │  └── IChainAdmin.sol (`21ac083`)
│  │  ├── upgrades
│  │  │  ├── ZkSyncUpgradeErrors.sol (`8217496`)
│  │  │  ├── L1GenesisUpgrade.sol (`8217496`)
│  │  │  └── BaseZkSyncUpgrade.sol (`0778e18`)
│  │  └── state-transition
│  │    ├── chain-deps
│  │    │  ├── DiamondInit.sol (`79215dc`)
│  │    │  ├── GatewayCTMDeployer.sol (`21ac083`)
│  │    │  ├── ZKChainStorage.sol (`79215dc`)
│  │    │  └── facets
│  │    │    ├── Admin.sol (`79215dc`)
│  │    │    ├── Executor.sol (`79215dc`)
│  │    │    ├── Getters.sol (`79215dc`)
│  │    │    ├── Mailbox.sol (`79215dc`)
│  │    │    └── ZKChainBase.sol (`79215dc`)
│  │    ├── chain-interfaces
│  │    │  ├── IAdmin.sol (`79215dc`)
│  │    │  ├── IDiamondInit.sol (`7827bf3`)
│  │    │  ├── IGetters.sol (`0778e18`)
│  │    │  ├── IMailbox.sol (`fe838fc`)
│  │    │  ├── IVerifier.sol (`37719a9`)
│  │    │  └── IVerifierV2.sol (`37719a9`)
│  │    └── verifiers
│  │      ├── DualVerifier.sol (`858da06`)
│  │      ├── VerifierFflonk.sol (`703acc1`)
│  │      └── VerifierPlonk.sol (`49868af`)
├── l2-contracts
│  └── contracts
│   ├── chain-interfaces

```

FFLONK and EVM Equivalence Diff Audit − Scope − 4


```
│   │  ├── IVerifier.sol (`37719a9`)
│   │  └── IVerifierV2.sol (`37719a9`)
│   ├── errors
│   │  └── L2ContractErrors.sol (`37719a9`)
│   ├── interfaces
│   │  └── IConsensusRegistry.sol (`00ddc06`)
│   └── verifiers
│     ├── DualVerifier.sol (`37719a9`)
│     ├── VerifierFflonk.sol (`37719a9`)
│     └── VerifierPlonk.sol (`37719a9`)
└── system-contracts
├── bootloader
│  └── bootloader.yul (`0778e18`)
├── contracts
│  ├── AccountCodeStorage.sol (`0778e18`)
│  ├── BootloaderUtilities.sol (`0778e18`)
│  ├── Constants.sol (`0778e18`)
│  ├── ContractDeployer.sol (`0778e18`)
│  ├── DefaultAccount.sol (`0778e18`)
│  ├── EvmEmulator.yul (`bbfd8e7`)
│  ├── EvmEmulator.yul.llvm.options (`0778e18`)
│  ├── EvmGasManager.yul (`66c8e51`)
│  ├── EvmPredeploysManager.sol (full)
│  ├── KnownCodesStorage.sol (`7328b8c`)
│  ├── L2BaseToken.sol (`0778e18`)
│  ├── SystemContext.sol (`79215dc`)
│  ├── SystemContractErrors.sol (`79215dc`)
│  ├── abstract
│  │  └── SystemContractBase.sol (`0778e18`)
│  ├── interfaces
│  │  ├── IAccountCodeStorage.sol (`213f990`)
│  │  ├── IBaseToken.sol (`0778e18`)
│  │  ├── IContractDeployer.sol (`0778e18`)
│  │  └── IKnownCodesStorage.sol (`0778e18`)
│  ├── libraries
│  │  ├── SystemContractHelper.sol (`79215dc`)
│  │  ├── TransactionHelper.sol (`0778e18`)
│  │  └── Utils.sol (`816c358`)
│  └── precompiles
│    ├── CodeOracle.yul (`875d0a5`)
│    └── Identity.yul (full)
└── evm-emulator
├── EvmEmulator.template.yul (`bbfd8e79`)
├── EvmEmulatorFunctions.template.yul (`a9eb273`)
├── EvmEmulatorLoop.template.yul (`16b76a2`)
├── EvmEmulatorLoopUnusedOpcodes.template.yul (`df1c554`)
└── calldata-opcodes
├── ConstructorScope.template.yul (`684c072`)
└── RuntimeScope.template.yul (`16b76a2`)

```

**_Update:_** _All resolutions and the final state of the audited codebase mentioned in this report are_

_[contained at commit f1cae64, including two the new contracts added as part of the fix review](https://github.com/matter-labs/era-contracts/commit/f1cae6423440204e19a174f599c81d5c858194c2)_

_<mark>`EvmHashesStorage.sol`</mark>_ _and_ _<mark>`IEvmHashesStorage.sol`</mark>_ _<mark>.</mark>_ _This commit also covers the_

_<mark>`ChainRegistrar.sol`</mark>_ _contract, which was out of scope for this audit. The Matter Labs team_


FFLONK and EVM Equivalence Diff Audit − Scope − 5


_noted that this contract is a draft of the technical contract that is planned to be used to collect_

_data in the future for new chains registrations. As such, this contract does not present any_

_security risks._


FFLONK and EVM Equivalence Diff Audit − Scope − 6


## **System Overview**

The changes include code adjustments to support the EVM Emulator and Dual Verifier, as well

as various fixes, refactoring, and refinements. Key updates were made in the following areas of

the codebase:

### **EVM Equivalence**











**<mark>`Identity`</mark>** **Precompile** : An <mark>`Identity`</mark> precompile has been added to ZKsync to

maintain EVM equivalence. Some EVM contracts rely on this precompile to efficiently

copy large chunks of memory.

**<mark>`EvmPredeploysManager`</mark>** <mark>:</mark> The <mark>`EvmPredeploysManager`</mark> was introduced to

streamline the deployment of frequently used EVM contracts, providing a better

developer experience on ZKsync.

**Core Contract Updates** : Several core contracts were modified to safely enable EVM

emulation within the system, ensuring clear and reliable operations.


### **Verifiers**

Minor changes were made to verifier logic, including updates to verification key hashes and

gas optimizations.

## **Security Model and Trust** **Assumptions**


No notable changes were made to privileged roles. However, the diamond proxy admin can

now enable the EVM Emulator—restricted from Layer 1. For detailed information on trust

assumptions and privileged roles, please refer to previous audit reports.


FFLONK and EVM Equivalence Diff Audit − System Overview − 7


## **Medium Severity**

### **M-01 Bytecode Hash Restoration Failure with** **forcedSload for EVM Contracts**

The <u><mark>`[forcedSload](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/libraries/SystemContractHelper.sol#L448)`</mark></u> <u>function</u> of the <mark>`SystemContractHelper`</mark> library is intended to let

system contracts read the storage slot of any account. This is achieved by forcibly deploying a

special <u><mark>`[SLOAD](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/SloadContract.sol#L10)`</mark></u> <u>[contract](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/SloadContract.sol#L10)</u> at the target address, invoking its <mark>`sload`</mark> function, and then restoring

the previous contract hash with another forced deployment. These deployments are not meant

to invoke a constructor, as the <u><mark>`[callConstructor](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/libraries/SystemContractHelper.sol#L423)`</mark></u> <u>fagl</u> is set to <mark>`false`</mark> <mark>.</mark>


When <mark>`forcedSload`</mark> is called for an EVM contract, it does not restore the correct bytecode

hash for that account, disrupting the contract’s operability. This occurs because during the

EVM force deployment logic, the <mark>`_constructEVMContract`</mark> [function initially sets a](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/ContractDeployer.sol#L568-L573)

<u>[placeholder bytecode hash](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/ContractDeployer.sol#L568-L573)</u> indicating an EVM constructing contract, which contradicts the

[intended behavior of avoiding constructor calls. Since the](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/libraries/SystemContractHelper.sol#L423) <u><mark>`[_deployment.input](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/libraries/SystemContractHelper.sol#L425)`</mark></u> <u>parameter</u> in

<mark>`forcedSload`</mark> is empty, the EVM emulator interprets the constructor logic for an empty

[constructor code, returning an empty actual EVM bytecode, causing a mismatch](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/ContractDeployer.sol#L581-L607) in both the

versioned bytecode hash and the final EVM bytecode hash. Consequently, the bytecode hash

after the forced call differs from the original, breaking the functionality of any deployed EVM

contract.


Consider disallowing the <mark>`forcedSload`</mark> call for EVM emulated contracts or documenting that

this function should never be called for them.


**_Update:_** _[Resolved in pull request #1255. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1255)_


_We added a way to perform forced deployments of EVM contracts without constructor_

_calls._


FFLONK and EVM Equivalence Diff Audit − Medium Severity − 8


## **Low Severity**

### **L-01 Ambiguity in Verification Key Hash Retrieval** **in DualVerifier**

There are two functions for retrieving the verification key hash in <mark>`DualVerifier`</mark> <mark>:</mark>

<u><mark>`[verificationKeyHash](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/l1-contracts/contracts/state-transition/verifiers/DualVerifier.sol#L64)`</mark></u> and <u><mark>`[verificationKeyHash(uint256)](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/l1-contracts/contracts/state-transition/verifiers/DualVerifier.sol#L70)`</mark></u> <mark>.</mark> The first function

returns the PLONK verification key hash by default, but the contract also supports FFLONK,

which can lead to uncertainty about which verification key is actually being used.


Consider updating the function names or adding explicit references to each verifier type to

ensure that the correct verification key is always retrieved.


**_Update:_** _[Resolved in pull request #1273. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1273)_


_This function is used to keep backward compatibility with older Verifier implementations._

_We added comments to reduce uncertainty._

### **L-02 Lack of Validation of** **l2EvmEmulatorBytecodeHash in DiamondInit**


The <mark>`DiamondInit`</mark> contract initializes various parameters, including

<mark>`_initializeData.l2EvmEmulatorBytecodeHash`</mark> <mark>,</mark> which is intended to represent the

bytecode hash of an EVM emulator. In the <u><mark>`[initialize](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/l1-contracts/contracts/state-transition/chain-deps/DiamondInit.sol#L26)`</mark></u> <u>function, there is no validation for</u>

<mark>`_initializeData.l2EvmEmulatorBytecodeHash`</mark> before it is stored, which may allow

incorrect values to be accepted.


Consider validating the <mark>`l2EvmEmulatorBytecodeHash`</mark> parameter as well as other

parameters passed to the <mark>`initialize`</mark> function, similar to the validation performed for

`baseTokenAssetId'.


**_Update:_** _[Resolved in pull request #1276. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1276)_


_We added validation for hashes._


FFLONK and EVM Equivalence Diff Audit − Low Severity − 9


## **Notes & Additional** **Information**

### **N-01 TestnetVerifier Can Be Deployed on ZK** **Gateway**

In the constructor of <u><mark>`[TestnetVerifier](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/l2-contracts/contracts/verifiers/TestnetVerifier.sol#L17)`</mark></u> <mark>,</mark> there is a check to prevent deployment on

Ethereum mainnet. However, no such restriction exists for ZK Gateway. Since

<mark>`TestnetVerifier`</mark> is used in both L1 and Gateway contracts, this omission may result in the

unintended use of a testnet verifier on the Gateway.


Consider adding a check to ensure that <mark>`TestnetVerifier`</mark> is not deployed on Gateway.


**_Update:_** _Acknowledged, will resolve. The Matter Labs team stated:_


_The most sense would be to add a check here that does not allow it to be deployed on_

_Gateway. This can be done after Gateway is launched._

### **N-02 Gas Inefficiency in _extractProof**


The <u><mark>`[_extractProof](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/l1-contracts/contracts/state-transition/verifiers/DualVerifier.sol#L86)`</mark></u> <u>function</u> of the <mark>`DualVerifier`</mark> contract has been designed to retrieve

proof elements from the <mark>`_proof`</mark> calldata array for the subsequent call to a verifier. In its

current implementation, <mark>`_extractProof`</mark> loops over the <mark>`_proof`</mark> array to copy all elements

after the first into the <mark>`result`</mark> memory array. While straightforward, this approach is gas
inefficient because it incurs costs proportional to the array length. Since <mark>`_proof`</mark> is stored in

calldata, the <mark>`calldatacopy`</mark> opcode in an assembly block can be used instead, reducing gas

usage by roughly 13 times for a 24-element FFLONK proof.


Consider using <mark>`calldatacopy`</mark> in an assembly block for <mark>`_proof`</mark> array copying from the first

element to the <mark>`result`</mark> array to reduce gas consumption.


**_Update:_** _[Resolved in pull request #1274. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1274)_


_This optimization is less effective when using verifier on Gateway. The issue was fixed._


FFLONK and EVM Equivalence Diff Audit − Notes & Additional Information −

10


### **N-03 Inconsistent or Incomplete Documentation** **Across the Codebase**

Throughout the codebase, multiple instances of inconsistent or incomplete documentation

were identified:















The <mark>`SystemContext`</mark> contract includes a <mark>`coinbase`</mark> variable that is intended to

represent the block proposer's address. Commit <u>[b494799](https://github.com/matter-labs/era-contracts/commit/b494799666aa64778c6c3b53182963c3e642ec5b#diff-e2860f6e8f573cfb6869eb4c8d5adecaf8e6bd9a51ec56bfff6d883ca63322fdL45)</u> removed the important

docstring associated with the <mark>`coinbase`</mark> variable. This removal may lead to confusion

about the variable’s usage, especially since the EVM Emulator still does not support

dynamic modifications to the coinbase variable.


In <u><mark>`[VerifierFflonk](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/l1-contracts/contracts/state-transition/verifiers/VerifierFflonk.sol#L1586-L1587)`</mark></u> <mark>,</mark> a misleading docstring states that the values are stored starting

from the initial free memory pointer <mark>`0x80`</mark> <mark>,</mark> whereas the correct value is <mark>`0x00`</mark> <mark>.</mark>


In the <mark>`verify`</mark> function of <mark>`DualVerifier`</mark> there is an <u>[obsolete comment](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/l1-contracts/contracts/state-transition/verifiers/DualVerifier.sol#L50)</u> stating that

"the first element of <mark>`_recursiveAggregationInput`</mark> determines the verifier type

(either FFLONK or PLONK)". This reflects an older version of code, since in the latest

version, the verifier type is stored in the first element of the proof <mark>`_proof[0]`</mark> <mark>.</mark>


The newly added input <u><mark>`[_callConstructor](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/ContractDeployer.sol#L438)`</mark></u> to <mark>`_performDeployOnAddress`</mark> is not

[documented in the function docstrings.](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/ContractDeployer.sol#L428-L432)


The docstring description to <u><mark>`[precreateEvmAccountFromEmulator](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/ContractDeployer.sol#L218C14-L218C45)`</mark></u> can be improved

[as the function does not only check if the contract can be deployed but also returns its](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/ContractDeployer.sol#L236)

<u>[deployment address.](https://github.com/matter-labs/era-contracts/blob/5731979de1e1a81483503f4f580d2ae96bdaeb95/system-contracts/contracts/ContractDeployer.sol#L236)</u>



Consider thoroughly documenting all functions and their parameters that are part of a

contract's public API, and then updating the documentation to reflect the latest changes in

functionality.


**_Update:_** _[Resolved in pull request #1257, pull request #1275. The Matter Labs team stated:](https://github.com/matter-labs/era-contracts/pull/1257)_


_1. Coinbase should not be changed during the transaction (as expected from block-_

_scope params). But its value isn't hardcoded in the EVM emulator, so it retrieves it from_

_<mark>`SystemContext`</mark>_ _contract._

_[2. EVM emulator-related comments are addressed in PR #1257.](https://github.com/matter-labs/era-contracts/pull/1257)_

_[3. Verifiers-related comments are addressed in PR #1275.](https://github.com/matter-labs/era-contracts/pull/1275)_


FFLONK and EVM Equivalence Diff Audit − Notes & Additional Information −

11


## **Conclusion**

This system upgrade introduced changes to two sets of contracts that were previously audited

by OpenZeppelin: **Dual Verifier** and **EVM Equivalence** .


The Dual Verifier functionality supports a second verifier FFLONK, alongside the original

PLONK, serving as a transitional step toward full FFLONK adoption. The latest changes include

storing the verifier type flag into the proof, updating the verification key and other constants

(e.g., offsets), and adapting the L1 dual verifier contracts for L2. In this part of the scope, we

reported one low-severity vulnerability stemming from ambiguity in the verification key hash

retrieval.


The EVM Equivalence part focuses on an EVM emulator contract that supports the execution

of EVM bytecode within EraVM. These changes affect multiple contracts and were introduced

to incorporate EVM equivalence functionality into the next ZKsync release. We reported a

medium-severity vulnerability stemming from a bytecode hash restoration failure in EVM

contracts.


Apart from the changes mentioned above, multiple other contracts were also diff-audited as

they were affected by updates for the next release. We thank the Matter Labs team for their

responsiveness and for promptly addressing any questions that arose in the course of the

audit.


FFLONK and EVM Equivalence Diff Audit − Conclusion − 12


