# ZKsync V29 Release Audit

Source: [https://www.openzeppelin.com/news/matterlabs-v.29-release-audit](https://www.openzeppelin.com/news/matterlabs-v.29-release-audit)

Summary

 

## Summary

**Type:** Layer 2 & Rollups **Timeline:** May 20, 2025 → June 26, 2025 **Languages:** Solidity, Yul **Findings**Total issues: 22 (22 resolved) Critical: 0 (0 resolved) · High: 3 (3 resolved) · Medium: 2 (2 resolved) · Low: 8 (8 resolved) **Notes & Additional Information**8 notes raised (8 resolved)

## Scope

OpenZeppelin conducted a differential audit of the matter-labs/era-contracts repository against the base commit [7278847](https://github.com/matter-labs/era-contracts/commit/7278847d818b86368b48f95ddf69382a796e9725). The audit was performed in two phases:

**Phase 1**: Reduced Interoperability feature at head commit [3092fc0](https://github.com/matter-labs/era-contracts/commit/3092fc0a0898af7da45c4c183db70801aa8f005a).

In scope were the following files:

```
 l1-contracts
  ├── contracts
  │   ├── bridgehub
  │   │   ├── IMessageRoot.sol
  │   │   ├── L2MessageVerification.sol
  │   │   └── MessageRoot.sol
  │   ├── common
  │   │   ├── Messaging.sol
  │   │   ├── interfaces
  │   │   │   └── IL2InteropRootStorage.sol
  │   │   └── libraries
  │   │       └── MessageHashing.sol
  │   └── state-transition
  │       ├── chain-deps
  │       │   └── facets
  │       │       ├── Executor.sol
  │       │       ├── Mailbox.sol
  │       │       └── MessageVerification.sol
  │       └── chain-interfaces
  │           ├── IExecutor.sol
  │           ├── IMailbox.sol
  │           ├── IMailboxImpl.sol
  │           └── IMessageVerification.sol
  system-contracts
  ├── bootloader
  │   └── bootloader.yul
  └── contracts
      └── L2InteropRootStorage.sol
```

**Phase 2**: Fast Finality feature and other smaller changes in several parts of the system at head commit [903cfed2](https://github.com/matter-labs/era-contracts/commit/903cfed2cc523bfae835c16c9e25c5c901727404).

In scope were the following files:

```
 l1-contracts
  ├── contracts
  │   ├── bridge
  │   │   └── L1BridgeContractErrors.sol
  │   ├── bridgehub
  │   │   ├── Bridgehub.sol
  │   │   ├── CTMDeploymentTracker.sol
  │   │   ├── ChainAssetHandler.sol
  │   │   ├── IBridgehub.sol
  │   │   ├── IChainAssetHandler.sol
  │   │   └── L1BridgehubErrors.sol
  │   ├── chain-registrar
  │   │   └── ChainRegistrar.sol
  │   ├── common
  │   │   ├── Config.sol
  │   │   ├── L1ContractErrors.sol
  │   │   ├── Messaging.sol
  │   │   ├── interfaces
  │   │   │   └── IL1Messenger.sol
  │   │   ├── l2-helpers
  │   │   │   ├── IL2ToL1Messenger.sol
  │   │   │   ├── L2ContractAddresses.sol
  │   │   │   ├── L2ContractHelper.sol
  │   │   │   └── SystemContractsCaller.sol
  │   │   └── libraries
  │   │       └── MessageHashing.sol
  │   ├── governance
  │   │   ├── PermanentRestriction.sol
  │   │   └── ServerNotifier.sol
  │   ├── state-transition
  │   │   ├── AccessControlEnumerablePerChainAddressUpgradeable.sol
  │   │   ├── ChainTypeManager.sol
  │   │   ├── IChainTypeManager.sol
  │   │   ├── IValidatorTimelock.sol
  │   │   ├── L1StateTransitionErrors.sol
  │   │   ├── ValidatorTimelock.sol
  │   │   ├── chain-deps
  │   │   │   ├── DiamondInit.sol
  │   │   │   ├── GatewayCTMDeployer.sol
  │   │   │   ├── ZKChainStorage.sol
  │   │   │   └── facets
  │   │   │       ├── Admin.sol
  │   │   │       ├── Executor.sol
  │   │   │       └── ZKChainBase.sol
  │   │   ├── chain-interfaces
  │   │   │   ├── IAdmin.sol
  │   │   │   ├── IDiamondInit.sol
  │   │   │   └── IExecutor.sol
  │   │   ├── l2-deps
  │   │   │   └── IL2GenesisUpgrade.sol
  │   │   ├── libraries
  │   │   │   └── BatchDecoder.sol
  │   │   └── verifiers
  │   │       ├── L1VerifierFflonk.sol
  │   │       └── L2VerifierPlonk.sol
  │   ├── transactionFilterer
  │   │   └── GatewayTransactionFilterer.sol
  │   └── upgrades
  │       ├── BaseZkSyncUpgrade.sol
  │       ├── BaseZkSyncUpgradeGenesis.sol
  │       ├── IL2V29Upgrade.sol
  │       ├── L1V29Upgrade.sol
  │       ├── UpgradeStageValidator.sol
  │       └── ZkSyncUpgradeErrors.sol
  system-contracts
  ├── bootloader
  │   └── bootloader.yul
  ├── contracts
  │   ├── Constants.sol
  │   ├── EvmEmulator.yul
  │   ├── EvmPredeploysManager.sol
  │   ├── L2GenesisForceDeploymentsHelper.sol
  │   ├── L2InteropRootStorage.sol
  │   ├── L2UpgradeUtils.sol
  │   ├── L2V29Upgrade.sol
  │   ├── PubdataChunkPublisher.sol
  │   ├── SystemContext.sol
  │   ├── SystemContractErrors.sol
  │   ├── interfaces
  │   │   ├── IBridgedStandardERC20.sol
  │   │   ├── IBridgehub.sol
  │   │   ├── IL2AssetRouter.sol
  │   │   ├── IL2GenesisUpgrade.sol
  │   │   ├── IL2NativeTokenVault.sol
  │   │   └── IPubdataChunkPublisher.sol
  │   └── precompiles
  │       ├── CodeOracle.yul
  │       ├── EcAdd.yul
  │       ├── EcMul.yul
  │       └── Modexp.yul
  └── evm-emulator
      ├── EvmEmulatorLoop.template.yul
      └── EvmEmulatorLoopUnusedOpcodes.template.yul
```

***Update**: During the fix review period the pull requests [#1538](https://github.com/matter-labs/era-contracts/pull/1538) and [#1540](https://github.com/matter-labs/era-contracts/pull/1540) have also been investigated. All of the reported issues have been fully resolved at commit [babbed5](https://github.com/matter-labs/era-contracts/commit/babbed59718a62198902c3f26456228bcb7ed1fa).*

## System Overview

### Reduced Interoperability Feature

Until now, L2 ZKChains were only able to communicate with their settlement layers. The Reduced Interoperability feature enables cross-chain plain message passing among the ZKChains which settle on Gateway. The developed mechanism sets the base for a future release of full interoperability features, where actual value transfer among the L2 ZKChains will be supported.

Reduced Interoperability can be seen as an automation mechanism where the commitments of the settled batches on Gateway are shared with and stored on all ZKChains. Thus, in order to prove on a ZKChain B that a specific transaction took place on a ZKChain A, a user should submit a valid Merkle Proof of the transaction log inclusion against the commitment of the settled batch containing the transaction.

A step-wise description of the basic flow of the new mechanism is given below:

- Each time a ZKChain settles on Gateway, its corresponding `chainTree` is updated by [appending the new batch leaf](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/MessageRoot.sol#L147). This results in a new `chainRoot` and so the corresponding leaf in the `sharedTree` changes, resulting in an [updated `sharedTree`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/MessageRoot.sol#L154) root.
- Each time a Gateway batch containing batch settlements is sealed, the last updated `sharedTree` root reflects all the settled ZKChain batches within that Gateway batch.
- This last updated `sharedTree` root within a Gateway batch [is an interop root](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/MessageRoot.sol#L163). An external node monitors the network for `NewInteropRoot` events and broadcasts the new interop root to all ZKChains that settle on Gateway.
- Upon running a new bootloader instance, the operator of each ZKChain is responsible for [feeding the bootloader memory](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L316-L355) with the newly broadcasted interop roots.
- As the bootloader runs, it [goes through the interop roots](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3060-L3132) and stores them in the ZKChain's `L2InteropRootStorage` contract.
- When the bootloader instance completes its execution, a corresponding ZKChain batch is prepared for settlement. The batch also contains [information about the stored interop roots](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L4451).
- When the batch is settled on Gateway, [it is checked](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L436) that all interop roots stored on the ZKChain are valid roots of `sharedTree` on Gateway. Otherwise, the batch is reverted.
- Once the batch is successfully settled, the inclusion of logs under the interop roots [can be proven](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/MessageVerification.sol#L18) on the ZKChain.

### Fast Finality Feature

The Fast Finality feature enables faster finality times for ZKChains that settle on Gateway. Nodes can monitor for pre-commitments on L1 instead of waiting for Gateway batch commitment, proving, and execution (which is gas-intensive for the operator to do too often) on L1. This allows third-party services, such as exchanges supporting ZKChains, to offer faster settlement leading to an improved user experience.

On-chain, this is achieved by "pre-committing" to L1 the ordering, content, and execution status of transactions processed on Gateway. Specifically, each transaction hash is appended, along with its execution status, [to a rolling hash](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L353-L376) and stored on L1 during pre-commitment. This rolling hash is then validated against the [rolling hash of Gateway transactions computed in the bootloader](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/system-contracts/bootloader/bootloader.yul#L807) during [batch commitment](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L93), reverting the commitment if the two do not match. Practically, this means that the consumers of these pre-commitments (e.g., exchanges) can rely on these Gateway transactions being executed later in the batch in a certain order and with a certain status. Otherwise, the chain would stall. Since Gateway transactions contain the commitment, proving, and execution of ZKChain batches, consumers can infer the state of these ZKChains.

In addition, the right to [revert committed batches and pre-commitments](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L216-L219) on Gateway will be transferred from the operator to the security council. This means that pre-commitments can only be reverted by the security council. More generally, a flexible mechanism to manage the different roles (pre-commit, commit, proof, execution, and revert) was introduced through the `ValidatorTimelock` contract.

## Security Model and Trust Assumptions

As noted earlier, the interop feature is currently reliant on ZKChain operators including the new interop root. However, it should be noted that because the trees are append-only, messages can only be censored by way of the operator refusing to sync any new root. Regarding pre-commitments, it is important for consumers to understand what they are and what are the provided guarantees.

Pre-commitments guarantee the order and execution status of Gateway transactions. While this guarantee is powerful, as these transactions are expected to be deterministic, the Gateway operator remains a source of non-determinism because of its ability to influence variables such as the block timestamp, the block number, the block hash, or the inclusion of interop roots. It is thus important for the pre-commitment consumers to ensure that all the transactions which are pre-committed are deterministic, even in the worst case of an adversarial operator. For example, a transaction executing a smart contract that executes a ZKChain batch only if the `block.timestamp` is even should not be relied upon because the timestamp can be later manipulated to fulfill the promise without executing the batch. Generally, the consumers of pre-commitments are recommended to ensure that all pre-committed transactions were sent by EOAs to whitelisted contracts (e.g., `Executor.sol`) to mitigate the risk of such scenarios from materializing.

*Note that it is always possible for the operator to submit random data as part of pre-commitments, which would force the intervention of the security council in order to revert those. All the data should thus always be validated to correspond to valid transactions. Additionally, pre-commitments can be invalidated by chain upgrades.*

The following trust assumptions were made during the audit:

- The owners of the involved contracts and the privileged actors of the [`ValidatorTimelock` contract](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L35-L62) will behave honestly.
- The security council will act in the best interest of the protocol and its users.
- The system upgrade will be executed correctly.

## High Severity

### Lack of Validation for `bootloader` Initialization Values

The bootloader uses multiple variables to track its progress when processing interop roots:

- `LAST_PROCESSED_BLOCK_NUMBER`
- `CURRENT_NUMBER_OF_ROOTS_IN_BLOCK`
- `CURRENT_INTEROP_ROOT`

However, these variables are not validated to be initialized to 0. This lack of validation makes it possible for the operator to deviate from the intended operation of the bootloader in various ways. For example, the operator could set `LAST_PROCESSED_BLOCK_NUMBER` or `CURRENT_NUMBER_OF_ROOTS_IN_BLOCK` to a non-zero value to [ignore some roots](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3076-L3079), or set `CURRENT_INTEROP_ROOT` to a very high value to create a buffer overflow and [read roots from beyond the array bounds](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3105). Such attacks could result in a range of outcomes, including the forgery of incorrect interop roots, which could lead to user funds being stolen by the operator.

Consider ensuring that these variables are initialized properly during the execution of the bootloader.

***Update:** Resolved in [pull request #1505](https://github.com/matter-labs/era-contracts/pull/1505) at commit [14571a2](https://github.com/matter-labs/era-contracts/tree/14571a21f3e4cf24e1ead7dbd3678cb03412cee7). All the variables are explicitly initialized to 0.*

### Operator Can Forge Arbitrary Interop Roots

Messages can be sent across ZKChains by calling the [`sendToL1`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/L1Messenger.sol#L120C14-L120C22) function of the `L1Messenger` contract. Such messages are aggregated in the [`L2_TO_L1_MERKLE_TREE`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/L1Messenger.sol#L295-L307) and sent to the settlement layer at the end of the execution of the [bootloader](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L4453) on a batch. The synchronization of the Merkle trees coming from different ZKChains sharing the same settlement layer can then be ensured by the operator of a ZKChain when executing the bootloader on a batch. The operator can add interop roots within the batch's data so that [they are stored](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3131) in the [`L2InteropRootStorage` contract](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/L2InteropRootStorage.sol) on the ZKChain.

To ensure that valid interop roots are synchronized, the stored roots are [compared against the roots stored on the settlement layer](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L457-L466) during settlement. Cross-chain messages can then be [proven](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/MessageVerification.sol#L18) on the destination ZKChain by providing a Merkle proof against an interop root. However, there is a flaw in the bootloader's memory management design making it possible for the operator to circumvent the interop root validation mechanism. Specifically, within the `bootloader` contract, the [loop setting the interop roots](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3103-L3132) and the [loop validating them](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3188-L3227) can iterate over different slices of the `INTEROP_ROOTS` array.

For example, a malicious operator could pass an interop root with a `sides` length of 0 as the first interop root and initialize `CURRENT_INTEROP_ROOT` to 1. The `setInteropRootForBlock` function would then iterate over the roots at [indexes [1:100]](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3103-L3132), while the validation loop would loop over [index [0] and exit early](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3199-L3203). The settlement would complete successfully as `dependencyRootsRollingHash` is 0 as if no new roots had been added. This design flaw allows the operator to forge arbitrary roots.

The core of the issue is that the domains of the loops in which interop roots are set and validated can be different. To address this issue, consider explicitly merging the aforementioned loops into a single loop to ensure that any interop root added is always validated.

***Update:** Resolved in [pull request #1521](https://github.com/matter-labs/era-contracts/pull/1521) at commit [2aae32a](https://github.com/matter-labs/era-contracts/tree/2aae32a28825f0ddc0489a0d968ad87777834a75). The rolling hash validated during settlement is now computed when setting the interop roots on L2.*

### Inconsistent Indexing of `interopRoots` in `bootloader::setInteropRootForBlock`

Within the `bootloader` contract, specifically in the [`setInteropRootForBlock`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3086) function, there is an inconsistency in the indexing methodology applied to `interopRoots`. The [`getNumberOfInteropRootInCurrentBlock`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3089) function is designed to return the total number of `interopRoots` for a given block. This value [appears to represent](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3101) the count of `interopRoots` included in the block, without any reference to the sequential order of roots being processed in the entire batch.

In contrast, [`nextInteropRootNumber`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3087) is utilized as an index that accounts for the sequential order of `interopRoots` within the entire batch. This discrepancy in indexing approaches—where one value represents an absolute count within a single block and the other signifies a sequential index across the entire batch—leads to a fundamental inconsistency. Comparing these two values directly [in the `for` loop condition](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3103) is illogical due to their differing contextual bases. This inconsistency could lead to only storing part of `interopRoots` [set in the `L2InteropRootStorage` contract](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3131).

To address this issue and ensure clarity and correctness in the processing of `interopRoots`, consider standardizing the indexing approach to consistently reflect either an absolute count within a block or a sequential index within the batch.

***Update:** Resolved in [pull request #1501](https://github.com/matter-labs/era-contracts/pull/1501) at commit [4852fe8](https://github.com/matter-labs/era-contracts/tree/4852fe8b9fa9d978583e49ffabddcccebb8db805). The loop now iterates over the correct range.*

## Medium Severity

### Risk of Inconsistencies from Duplicate Information in `bootloader`

When processing interop roots, the bootloader is responsible for iterating over several variables stored in its memory. During this process, the bootloader iterates through each transaction, fetches the associated block number, and retrieves the number of roots stored in [`INTEROP_BLOCKS`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3089). Then, the bootloader [reads that many elements from](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3103) the `INTEROP_ROOTS` array, which contains multiple fields per root: the processed block, the chain ID, the dependency block, the sides length, and the sides data.

However, when processing a root, the "processed block" associated with the current root is [compared to the current block and loop breaks early](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3118-L3121) if the processed block is above the current block. This situation should never occur, as it suggests that an incorrect number of roots was set in `INTEROP_BLOCKS`. This could allow the operator to set a very high processed block value and ignore some roots.

At a high level, this issue results from information being duplicated between the number of roots in a block and the block associated with each root. As such, consider either removing the duplicated information by only keeping the number of roots or reverting when an incorrect block number is encountered.

***Update:** Resolved in [pull request #1523](https://github.com/matter-labs/era-contracts/pull/1523) at commit [518305e](https://github.com/matter-labs/era-contracts/tree/518305e29ad744b8ea3359f91e7b2ecd0434b1ba). The bootloader will now revert if a root is encountered with an inconsistent block number.*

### Potential Security Flaws in Cross-Chain Message Verification Due to Inconsistent Entry Points

The [`MessageVerification`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/MessageVerification.sol) contract is designed to facilitate the verification of messages or logs from ZKChains, enhancing cross-chain communication capabilities. This contract is extended by the [`Mailbox`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol) facet on settlement layers and the [`L2MessageVerification`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/L2MessageVerification.sol) contract on ZKChains. The `Mailbox` facet already encapsulates the necessary functionality for message verification on settlement layers, rendering the proving functions of `MessageVerification` redundant in such contexts.

The redundancy becomes problematic when, due to a discrepancy in handling the `chainId` of the sending ZKChain, the proving functions within `MessageVerification` are invoked instead of those in `Mailbox` on a settlement layer. `Mailbox` [internally determines `chainId`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/Mailbox.sol#L81), ensuring consistency and security in message verification. Conversely, `MessageVerification` requires `chainId` [as an external argument](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/MessageVerification.sol#L19), opening the door to inconsistencies and incorrect parameter submissions. This discrepancy undermines the security and reliability of cross-chain message verification, as illustrated in the following scenarios:

#### Scenario 1

A message from ZKChainA is correctly proven within its Diamond proxy on Gateway, but using the `chainId` of ZKChainB. Despite the incorrect `chainId`, the proof succeeds due to accurate proof data and the non-reliance on the erroneous `chainId`.

#### Scenario 2

Proving a message from ZKChainA on L1 within the Diamond Proxy of ZKChainB also leads to a successful proof. This is because the `chainId` of ZKChainA is provided externally and the proof data is accurate, with the final batch root hash verification occurring on Gateway's Diamond Proxy, which does not differentiate between ZKChains settling on it.

Consider introducing additional validation logic to detect and reject proofs submitted with inconsistent parameters, especially focusing on scenarios where `chainId` could be misused. Specifically, consider always verifying that the ZKChain's `chainId` for which the message is proven is the expected one according to the context.

***Update:** Resolved in [pull request #1525](https://github.com/matter-labs/era-contracts/pull/1525) at commit [6f9abb0](https://github.com/matter-labs/era-contracts/tree/6f9abb0552640f891bcaa2ecfc84b363b733cc81). The `shared` functions used for message verification were marked as virtual in `MessageVerification`, and overridden by functions validating the `chainId` in `Mailbox`.*

## Low Severity

### Misleading Naming in Contract Variables and Events

In the `bootloader` and `MessageRoot` contracts, certain names do not accurately reflect the data they represent, leading to potential confusion.

In `bootloader.yul`, the [CURRENT\_NUMBER\_OF\_ROOTS\_IN\_BLOCK\_SLOT](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L316) and [CURRENT\_NUMBER\_OF\_ROOTS\_IN\_BLOCK\_BYTE](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L321) variables misleadingly suggest that they represent the number of roots, whereas they actually track the number of blocks processed. This discrepancy between the variable names and their actual purpose can lead to misunderstanding about the contract's functionality. Similarly, the [`INTEROP_BLOCKS_BEGIN_SLOT`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L338) and [`INTEROP_BLOCKS_BEGIN_BYTE`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L343) variables actually count the number of roots per block. Apart from this, the [`interopRootStartSlot`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3105) variable could be renamed to `interopRootStartByte` to maintain slot vs. byte naming consistency.

In `MessageRoot.sol`, [the `Preimage` event](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/MessageRoot.sol#L47), triggered upon the generation of a new `chainTree` root (`chainRoot`) and the corresponding update of its leaf in `sharedTree`, includes two parameters named `chainRoot` and `preimage`. However, the naming inaccurately implies a direct cryptographic relationship between the two parameters, which is not the case. Moreover, the event name and its parameters do not convey the full context needed to understand the update, as the `sharedTree` leaf's hash requires both the `chainRoot` and the `chainId` of the associated chain for complete clarity.

For `bootloader.yul`, consider renaming the identified variables to more accurately reflect their purpose. For `MessageRoot.sol`, consider renaming the `Preimage` event to better describe its meaning and the relationship between its parameters. These changes aim to enhance code readability and clarity.

***Update:** Resolved in [pull request #1506](https://github.com/matter-labs/era-contracts/pull/1506) at commit [7303766](https://github.com/matter-labs/era-contracts/tree/7303766a259fc9c180f3382cb26efd35c88c2115). All the points raised were addressed.*

### `INTEROP_ROOTS` Reading Is Vulnerable to Buffer Overflow

When setting new interop roots, the bootloader is designed to [read data](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3105-L3111) in the `INTEROP_ROOTS` array from index [`CURRENT_INTEROP_ROOT`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3087) to index [`CURRENT_INTEROP_ROOT + INTEROP_BLOCKS[CURRENT_NUMBER_OF_ROOTS_IN_BLOCK] - 2`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3103C54-L3103C82). However, the `INTEROP_ROOTS` array can hold up to [100 roots](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L125-L127). This indicates that these memory reads are vulnerable to buffer overflows. For example, if `CURRENT_INTEROP_ROOT` or `INTEROP_BLOCKS[i]` are too large, the bootloader would read from memory beyond the `INTEROP_ROOTS` array, which is the area storing the `COMPRESSED_BYTECODES`.

While the impact of such an overflow is unclear, consider nonetheless ensuring that the bootloader does not read roots from outside the array bounds to prevent any potential issues.

***Update:** Resolved in [pull request #1507](https://github.com/matter-labs/era-contracts/pull/1507) at commit [13140a1](https://github.com/matter-labs/era-contracts/tree/13140a1e6519e3eac864a637c291a5ada1cd5f15). The code now reverts on attempts to read from outside the interop roots memory buffer.*

### Unused and Redundant Code

This unused code increases the complexity of the codebase and poses a maintenance overhead, potentially obscuring the logic and functionality of the contracts.

Throughout the codebase, multiple instances of unused and redundant code were identified:

- In `bootloader.yul`, the [initial assignment of the `interopRootStartSlot` variable](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L3088) within the `setInteropRootForBlock` function is never utilized in subsequent operations.
- In `BridgeHub.sol`, the code related to pause functionality during upgrades is obsolete since the new [`ChainAssetHandler`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/ChainAssetHandler.sol) is responsible for it. Consider deprecating the associated [state variable](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/Bridgehub.sol#L101) and deleting the associated [modifier](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/Bridgehub.sol#L128-L133) and [functions](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/Bridgehub.sol#L865-L873).
- Despite the transition from a priority queue to a priority tree structure, several references to the outdated priority queue remain within the Diamond Proxy facets (`Admin.sol`, `Mailbox.sol`, `Getters.sol`, and `ZKChainBase.sol`). These references are misleading and do not reflect the current architecture, potentially leading to confusion and errors in understanding or extending the codebase.

Consider removing all instances of unnecessary code for enhanced code clarity and maintainability.

***Update:** Resolved in [pull request #1514](https://github.com/matter-labs/era-contracts/pull/1514/files#diff-f6e41516603d540ac4c1e49a20311568dfd13eed8f7b4622d576489c4d3eb5dc). The Matter Labs team stated:*

> We will deprecate the upgrade functionality in `BrigdeHub` in the next version, since we will still need to pause migration before the upgrade, do the upgrade, and then unpause it.

### Incorrect `INTEROP_ROOT_SLOT_SIZE` Return Value

In the `bootloader` contract, the storage of each `interopRoot` is designed to occupy [5 memory slots](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L381-L403), which include the block number for `interopRoot` processing, the chain ID, the dependency block, the sides length, and the sides. However, the `INTEROP_ROOT_SLOT_SIZE` function erroneously returns a value of 6 instead of 5.

This discrepancy does not currently affect the system's operations, as the extra, unutilized memory slot does not compromise memory consistency and is essentially ignored. Nonetheless, this misalignment between the intended and actual slot size allocation could lead to unnecessary memory fragmentation. More importantly, it introduces a potential source of errors for future development efforts, where the incorrect slot size assumption could lead to more significant issues.

Consider fixing the `INTEROP_ROOT_SLOT_SIZE` function to return the accurate number of slots an `interopRoot` actually occupies. This adjustment will help enhance code clarity and maintainability, reducing the risk of errors in subsequent development phases.

***Update:** Resolved in [pull request #1521](https://github.com/matter-labs/era-contracts/pull/1521) at commit [abacb3c](https://github.com/matter-labs/era-contracts/tree/abacb3c18fa63c5f394679d6b19c9995f1c7c0dc).*

### Inconsistency in `addInteropRoot` Function Argument Type

The [`addInteropRoot`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/L2InteropRootStorage.sol#L30) function of the `L2InteropRootStorage` contract is designed to accept a third argument as a [`bytes32` array](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/L2InteropRootStorage.sol#L33). However, in its corresponding interface definition, the third parameter is specified as a singular `bytes32` value instead of an array. While this interface is not currently utilized within the existing codebase, the presence of such a mismatch introduces a latent risk. This inconsistency between the contract implementation and its interface definition is inherently error-prone and could lead to integration issues or failures in future developments or updates.

To mitigate the risk of future errors and enhance code maintainability and clarity, consider aligning the `addInteropRoot` function's parameter type in both the contract implementation and its interface.

***Update:** Resolved in [pull request #1509](https://github.com/matter-labs/era-contracts/pull/1509/files) at commit [271380d](https://github.com/matter-labs/era-contracts/tree/271380d835b7044e3c8f031ced8b119d203aaa8c). The unused function was removed from the interface.*

### The Zero Leaf Can Be Verified on ZKChains

The verification of cross-chain messages on ZKChains is managed by the [`L2MessageVerification`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/L2MessageVerification.sol) contract. However, the `_proveL2LeafInclusion` function allows the [correct batch root](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/L2MessageVerification.sol#L29) to be zero when verifying a leaf. This allows for verifying that the leaf (`bytes32(0)`) was sent in a non-existent batch number by providing an empty log leaf proof with `finalProofNode = true`.

Consider validating that `correctBatchRoot` is non-zero when comparing it with the reconstructed root.

***Update:** Resolved in [pull request #1510](https://github.com/matter-labs/era-contracts/pull/1510) at commit [25c3046](https://github.com/matter-labs/era-contracts/tree/25c30466fba3e938ffa36608001292e7d83c02e5).*

### Extra `setInteropRootForBlock` Call at the End of `bootloader`

At the end of bootloader execution on a batch, the [`setInteropRootForBlock(MAXIMUM_L2_BLOCK_NUMBER())`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L4450) function is called. This call is documented as "setting all remaining interop roots, even the ones in the fictive block". However, following a discussion with the Matter Labs team, it was clarified that there should not be interop roots in virtual blocks.

Consider removing the aforementioned code to reduce the attack surface.

***Update:** Resolved in [pull request #1515](https://github.com/matter-labs/era-contracts/pull/1515) at commit [73be8f2](https://github.com/matter-labs/era-contracts/tree/73be8f2239b49d347be5af2c56bb1fa44c8d8ad4).*

### Interop Roots Can Be Set as `bytes32(0)` on ZKChains

The [`Executor`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L464C50-L464C89) and [`L2InteropRootStorage`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/L2InteropRootStorage.sol#L30-L49) contracts allow the operator to add dummy interop roots with the value `bytes32(0)` for any `blockOrBatchNumber` for which a root is not already defined. While this does not cause immediate security concerns, it represents a risky pattern and emits an [event](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/L2InteropRootStorage.sol#L48) that could be misleading.

Consider validating that interop roots added on ZKChains cannot be zero.

***Update:** Resolved in [pull request #1516](https://github.com/matter-labs/era-contracts/pull/1516) at commit [9beb04e](https://github.com/matter-labs/era-contracts/tree/9beb04e3fdc0acb2984d00281311aeee314fbe60). Checks were added on L1 and L2 to ensure the interop root is nonzero.*

## Notes & Additional Information

### Misleading Documentation and Comments

Misleading documentation or comments can confuse developers or lead to incorrect assumptions about the functionality of the code.

Throughout the codebase, multiple instances of misleading documentation or comments were identified:

In `bootloader.yul`:

- In lines [314 and 315](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L314-L315), the description of `CURRENT_NUMBER_OF_ROOTS_IN_BLOCK_SLOT` inaccurately suggests that it returns the number of `interopRoots` in a block. However, it provides the storage slot for the count of blocks processed so far. Similarly, the description for `CURRENT_NUMBER_OF_ROOTS_IN_BLOCK_BYTE` in line [320](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L320) follows the same misleading pattern.
- In lines [337](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L337) and [342](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L342), `INTEROP_BLOCKS_BEGIN_SLOT` and `INTEROP_BLOCKS_BEGIN_BYTE` are described as being the starting point at which `interopRoots` are stored, whereas they return the starting slot and byte, respectively, of `interopRoot` counts per block.

In `MessageHashing.sol`:

- The docstring above the [`getProofData`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/common/libraries/MessageHashing.sol#L98) function states that the function hashes the proof. However, the actual functionality involves parsing the proof and returning the final proof data, not hashing it.

In `IExecutor.sol`:

- The [`todo` comment](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-interfaces/IExecutor.sol#L75) for the `StoredBatchInfo` struct can be removed as the action item has already been implemented. Consider removing it.
- The descriptions of the offsets as being ["Equal to 4 (bytes for isService)"](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-interfaces/IExecutor.sol#L38C48-L38C80) are unclear. Consider replacing these with "Equal to 4 (bytes for `ShardId`, `isService`, and `txNumberInBatch`)" or something similar.

Consider revising the documentation to accurately reflect the functionality of each function and variable. Accurate documentation significantly improves the clarity and maintainability of the codebase.

***Update:** Resolved in [pull request #1511](https://github.com/matter-labs/era-contracts/pull/1511) at commit [678273e](https://github.com/matter-labs/era-contracts/tree/678273e0c1b4b4bf9f804f10d84c18683b2cc575). All the instances identified were addressed.*

### Code Quality Improvements

Throughout the codebase, multiple opportunities for code improvements were identified:

- The [`getChainRoot`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/MessageRoot.sol#L177-L179) function could validate that `_chainId` is registered before returning a root. Otherwise, an [underflow error](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/common/libraries/DynamicIncrementalMerkle.sol#L138C49-L138C71) would occur for unregistered chains.
- The arguments to the `MismatchNumberOfLayer1Txs` error are [inverted](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L433) compared to its definition.
- Some errors do not have the right signatures in their documentation: "[0x0214acb6](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/common/L1ContractErrors.sol#L161C4-L161C14)" should be "0x5f1aa154", "[0xcea34703](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/common/L1ContractErrors.sol#L179C4-L179C14)" should be "0x43e266b0", and "[0xd7a6b5e6](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/common/L1ContractErrors.sol#L287C4-L287C14)" should be "0x7774d2f9".
- The `SystemLogKey` is defined differently in [`Constants.sol`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/Constants.sol#L144-L156) compared to [`IExecutor.sol`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-interfaces/IExecutor.sol#L8-L21). Specifically, the `MESSAGE_ROOT_ROLLING_HASH_KEY` field is missing.
- In `MessageVerification.sol`, the [check](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/state-transition/chain-deps/facets/MessageVerification.sol#L75-L76) verifying the log hash against the default leaf hash within the `_proveL2LogInclusion` function should be moved into the `_proveL2LeafInclusion` function in order to be effective in all cases where a log is being proved.
- In `bootloader.yul`, consider defining a constant for the currently [hardcoded value](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L349) of the maximum number of processed blocks within a batch. This would help semantically distinguish it from the maximum number of `INTEROP_ROOTS` per batch, which carries [the same value](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L125-L126) at the moment.

Consider addressing the identified instances to improve the clarity and maintainability of the codebase.

***Update:** Resolved in [pull request #1517](https://github.com/matter-labs/era-contracts/pull/1517) at commit [5116186](https://github.com/matter-labs/era-contracts/tree/51161868c8e161622e367c4373a22f7d898d35e8) and [pull request #1522](https://github.com/matter-labs/era-contracts/pull/1522) at commit [4566b98](https://github.com/matter-labs/era-contracts/tree/4566b983fa1a5d62f905e836d7b7f8e03ea0c07e). All the points identified were addressed. Regarding the last point the number of transactions, which is an upper bound on the number of blocks in the batch, was used instead.*

### Gas Optimizations

Throughout the codebase, multiple opportunities for gas optimization were identified:

- In the [`addChainBatchRoot`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/MessageRoot.sol#L154) and [`updateFullTree`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/MessageRoot.sol#L188) functions, updates are done to the shared tree through functions that [return the new root](https://github.com/matter-labs/era-contracts/blob/3d9fd025516ddaa3e259d9e2e9d572620f05786b/l1-contracts/contracts/common/libraries/FullMerkle.sol#L73). This return value is ignored and `sharedTree.root()` is called instead to get the updated root. Consider using the returned value to save gas.
- In the `updateFullTree` function, the [`chainIndexToId[i]`](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/l1-contracts/contracts/bridgehub/MessageRoot.sol#L185C69-L185C86) value is read from a storage mapping twice and does not appear to be automatically cached by the compiler. Consider caching it manually in a local variable to save gas on each loop.

Consider implementing the aforementioned suggestions to improve the gas efficiency of the codebase.

***Update:** Resolved in [pull request #1512](https://github.com/matter-labs/era-contracts/pull/1512) at commit [081796d](https://github.com/matter-labs/era-contracts/tree/081796d9585e97ab8e024801f69b2301745977e0).*

### Typographical Errors

Throughout the codebase, multiple instances of typographical errors were identified:

- In [line 28](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/contracts/L2InteropRootStorage.sol#L28) of `L2InteropRootStorage.sol`, the NatSpec line starts with "//" instead of "///". Consider fixing it so that any tool relying on documentation parsing can successfully extract it.
- In [line 272](https://github.com/matter-labs/era-contracts/blob/3092fc0a0898af7da45c4c183db70801aa8f005a/system-contracts/bootloader/bootloader.yul#L272) of `bootloader.yul`, "The slot starting from the L2 block [...]" should be "The slot starting from which the L2 block [...]".

To improve the clarity and readability of the codebase, consider addressing the above-listed instances of typographical errors.

***Update:** Resolved in [pull request #1513](https://github.com/matter-labs/era-contracts/pull/1513) at commit [741eaf7](https://github.com/matter-labs/era-contracts/tree/741eaf7a3be543f4eaa0976df0f66202576a9fa3).*

### Code Quality Improvements (Phase 2)

Throughout the codebase, multiple opportunities for code improvement were identified:

- In the `ValidatorTimelock` contract and its interface, the [`hasRoleForChainId`](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L183C14-L183C31) function could be marked as `view`.
- In the `_calculatePrecommitmentRollingHash` function of the `Executor` contract, the [`assembly` block](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L354-L376) could be marked as `memory-safe` as it only accesses the scratch space and memory within the bounds of the `_packedTxPrecommitments` memory array.
- In the `bootloader` contract, the comment in [line 195](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/system-contracts/bootloader/bootloader.yul#L195) states that only L2 transactions are stored under the `CURRENT_L2_TX_HASHES` memory slot. However, this is not true since priority transactions [are also stored](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/system-contracts/bootloader/bootloader.yul#L1192) at this location in the current version of the code.
- In the `IValidatorTimelock.sol` interface, the [parameters](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/IValidatorTimelock.sol#L130-L133) of the `proveBatchesSharedBridge` function could be renamed to `_chainAddress`, `_processBatchFrom`, `_processBatchTo`, and `_proofData`, respectively, in order to be consistent with the [implementation](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L637-L642).
- In the `ValidatorTimelock` contract, the [`_l2BatchNumber`](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L218) parameter of the `revertBatchesSharedBridge` function could be renamed to `_newLastBatch`.
- In the `Executor` contract, some parameter types [[1]](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L382) [[2]](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L603) [[3]](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L638C21-L638C29) have been changed from `uint256` to `address`. However, the "// \_chainId" comments were not updated accordingly. In these comments, the parameters should be renamed to `_chainAddress`.
- In the `ValidatorTimelock` contract, some comments [[1]](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L207) [[2]](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L242) appear to have been [copy-pasted](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Executor.sol#L437) and, as a result, are irrelevant given the context. Consider removing these comments.
- References to "miniblock" [[1]](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-interfaces/IExecutor.sol#L134) [[2]](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-interfaces/IExecutor.sol#L236) could be renamed to "l2BlockNumber" or something similar to improve clarity and be consistent with the rest of the code.

Consider implementing the above-listed code quality improvement suggestions to enhance the clarity and maintainability of the codebase.

***Update:** Resolved in [pull request #1530](https://github.com/matter-labs/era-contracts/pull/1530) at commit [03031ec](https://github.com/matter-labs/era-contracts/tree/03031eccad28935036fc947b002a1a1f3ac3f89f). All the instances raised were addressed.*

### Inverted Error Arguments (Phase 2)

In the `ChainTypeManager` contract, the order of the arguments being supplied to the `OutdatedProtocolVersion` error appears to be [inverted](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L494) compared to the error's [definition](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/L1StateTransitionErrors.sol#L74).

Consider fixing the argument order of this instance of the `OutdatedProtocolVersion` error to improve code clarity and avoid confusion.

***Update:** Resolved in [pull request #1535](https://github.com/matter-labs/era-contracts/pull/1535) at commit [b6b26b3](https://github.com/matter-labs/era-contracts/tree/b6b26b3783f3b21a96fec9e30ffdff47c0770ce5).*

### Mismatch Between Interface and Implementation (Phase 2)

The `sendToL1` function of the `L1Messenger` contract defines the data location of the `bytes message` argument as [`calldata`](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/system-contracts/contracts/L1Messenger.sol#L120). However, the `IL2ToL1Messenger` sets the argument's location as [`memory`](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/common/l2-helpers/IL2ToL1Messenger.sol#L56).

Consider fixing the `IL2ToL1Messenger` interface so that the specified data location for the `sendToL1` function argument is consistent with its implementation.

***Update:** Resolved in [pull request #1536](https://github.com/matter-labs/era-contracts/pull/1536) at commit [c20b5f4](https://github.com/matter-labs/era-contracts/tree/c20b5f4c2c2007f1997307398aaa423e0f020c8e).*

### Typography Errors (Phase 2)

Throughout the codebase, multiple instances of typographical errors were identified:

- In [line 24](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/governance/ServerNotifier.sol#L24) of `ServerNotifier.sol`, "the chain initiating migration to the ZK gateway" should be "the chain initiating migration from the ZK gateway".
- In [line 2402](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/system-contracts/bootloader/bootloader.yul#L2402) of `bootloader.yul`, "The output has size of 32" should be "The output has size of 64".
- In [line 455](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/system-contracts/contracts/libraries/SystemContractHelper.sol#L455) of `SystemContractHelper.sol`, the word "validate" is missing from the comment.

To improve the clarity and readability of the codebase, consider addressing the above-listed instances of typographical errors.

***Update:** Resolved in [pull request #1537](https://github.com/matter-labs/era-contracts/pull/1537) at commit [a8e76e7](https://github.com/matter-labs/era-contracts/tree/a8e76e7f1702003a0dca028ee9117c8e226f9dd0).*

## Client Reported

### `IExecutor` Interface Change Prevents Chain Settlement

When upgrading a ZK Chain, the high-level execution path is as follows:

- The L1 contracts are upgraded during the call to [`ChainTypeManager.executeUpgrade`](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ChainTypeManager.sol#L341), which calls [`diamondCut`](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-deps/facets/Admin.sol#L231) on the ZK Chain's diamond proxy.
- This upgrades the facets (including the `Executor` contract), and then [delegate calls](https://github.com/matter-labs/era-contracts/blob/43c2dd5f263b964c232ef4359da4ba666fab3c6c/l1-contracts/contracts/state-transition/libraries/Diamond.sol#L307) to the `L1V29Upgrade` contract which optionally [reassigns the validator](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/upgrades/L1V29Upgrade.sol#L36-L41) on the ZK Chain's diamond proxy.
- Following this, the new validator can for example call `commitBatchesSharedBridge` to upgrade the ZK Chain's system contracts.

However, the `IExecutor` interface was [changed](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/chain-interfaces/IExecutor.sol#L156) in the codebase, while the [`ValidatorTimelock`](https://github.com/matter-labs/era-contracts/blob/903cfed2cc523bfae835c16c9e25c5c901727404/l1-contracts/contracts/state-transition/ValidatorTimelock.sol#L24) implementation sits behind a `TransparentUpgradeableProxy` and is upgraded independently from the above flow. Additionally, the `ValidatorTimelock` is shared between all the ZK Chains, which are not required to upgrade at the same time. Because the `ValidatorTimelock` would not be compatible with both old and new `IExecutor` interfaces, this means that it would no longer be able to call some functions (part of a now unsupported `IExecutor` interface) required to settle some ZK Chains.

***Update:** Resolved in [pull request #1571](https://github.com/matter-labs/era-contracts/pull/1571) at commit [ed3d351](https://github.com/matter-labs/era-contracts/tree/ed3d35194a8d7283807caeebadf86f32befc0b84). The `ChainTypeManager` contract now supports two versions of the `ValidatorTimelock`, which will be deployed separately. ZK Chains will change the supported validator when upgrading so as to support a `ValidatorTimelock` which is compatible with their `IExecutor` interface.*

## Conclusion

The changes under audit mainly introduce two new features: reduced interoperability, allowing for message passing between ZKChains settling on Gateway, and fast finality, allowing third-parties to verify the finality of ZKChain batches by monitoring pre-commitments on L1. Several other smaller code changes were also audited, mostly related to fixes and optimizations.

The main issues found were related to bootloader logic. Overall, the codebase was found to be well written and comprehensively documented. The Matter Labs team is appreciated for being highly responsive throughout the audit period, providing detailed explanations whenever needed along with valuable insights regarding the reasoning about certain design choices.

Ready to secure your code?

[Request an Audit →](https://www.openzeppelin.com/request?utm_campaign=Audit%20Reports%202024&utm_source=mybloglog&utm_medium=social&utm_term=CTARequestAudit&utm_content=AuditBlogPost)
