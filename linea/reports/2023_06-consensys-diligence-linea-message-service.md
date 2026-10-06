# Linea Message Service

Source: [https://diligence.security/audits/2023/06/linea-message-service/](https://diligence.security/audits/2023/06/linea-message-service/)

|  |  |
| --- | --- |
| Date | June 2023 |
| Auditors | Rai Yang, Tejaswa Rastogi |
| Download | JSON  CSV |

## 1 Executive Summary

This report presents the results of our engagement with **Linea** to review **Linea Message Service**.

The review was conducted over 3 weeks, from **June 5 2023** to **June 23 2023**, by
**Rai Yang** and **Tejaswa Rastogi**. A total of 2x15 person-days were spent.

## 2 Scope

Our review focused on the commit hash [8ccf24731c3cd288c27696771c45e4c1a01fa8cc](https://github.com/ConsenSys/zkevm-monorepo/commit/8ccf24731c3cd288c27696771c45e4c1a01fa8cc). The list of files in scope can be found in the [Appendix](#appendix---files-in-scope).

### 2.1 Objectives

Together with the **Linea** team, we identified the following priorities for our review:

1. Correctness of the implementation, consistent with the [intended functionality](https://docs.google.com/document/d/17pG8daAU00b2zZdoXXnG1jrRwCg8Py6dXJZDMYki3-M/edit#heading=h.xqwxf7c9akj7) and without unintended edge cases.
2. Identify known vulnerabilities particular to smart contract systems, as outlined in our [Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/), and the [Smart Contract Weakness Classification Registry](https://swcregistry.io/).

## 3 Security Specification

This section describes, **from a security perspective**, the expected behavior of the system under audit. It is not a substitute for documentation. The purpose of this section is to identify specific security properties that were validated by the audit team.

### 3.1 Actors

The relevant actors are listed below with their respective abilities:

- Coordinator: Relaying L1 messages to L2
- Sequencer: Sequencing L2 transactions, creating L2 blocks and proofs and submiting them to L1
- User: Dapps using the message service on L1 and L2
- Prover: Prove the correctness of the L2 block data(transactions) and state submitted by the sequencer
- Postman: Linea’s off-chain message delivery service or third-party service delivering the messages to claim the delivery fee. Each postman is not dependent on each other to function. There is the possibility of third-party postmen being unavailable.
- Service Admin: A Linea/ConsenSys controlled multisig wallet that initiates contract upgrades or performs contract functions such as pausing or setting withdrawal limits.

### 3.2 Trust Model

In any system, it’s important to identify what trust is expected/required between various actors. For this audit, we established the following trust model:

- The single coordinator relays L1 messages to L2 correctly and timely and does not censor L1 messages
- The single sequencer sequences the L2 transaction correctly, does not censor L2 messages and submits the blocks and proof to L1 timely
- The Postman delivers the messages to the destination layer correctly and rationaly based on the fee and gas cost of delivering the message
- Service Admin performes the service management properly and upgrades the contracts correctly and securely
- The verifier verifies the proof correctly

### 3.3 Security Properties

The following is a non-exhaustive list of security properties that were verified in this audit:

- A message is uniquely identified preventing it being executed twice
- A smart-contract mechanism on the receiving layer provides a way to prove which account was the origin sender of the call on the origin layer.
- To avoid issues with chain reorganisations, the cross-chain message validity reference updates on the destination layer takes place once the message is final on the origin layer. This prevents delivery by any entity early as the verification will fail, and will make sure the message is valid for delivery.cross-chain message validity reference updates
- Minimum service protection fee when sending on the L2 Linea message service to avoid a denial of service scenario due to its lower gas cost.
- A service admin sets the service protection fee on L2 Linea
- Any signing keys (e.g. the Sequencer and postman) needs to be secured properly.
- Reentrancy on message delivery is not supported to prevent double delivery. However a dispatch message request can be triggered as part of a delivery message action.
- A service admin can set a cap on L2->L1 daily withdrawal amount.
- An emergency mechanism exists to block message service transactions (sending on one layer and receiving on the other).

## 4 Findings

Each issue has an assigned severity:

- Critical issues are directly exploitable security vulnerabilities that need to be fixed.
- Major issues are security vulnerabilities that may not be directly exploitable or may require certain conditions in order to be exploited. All major issues should be addressed.
- Medium issues are objective in nature but are not security vulnerabilities. These should be addressed unless there is a clear reason not to.
- Minor issues are subjective in nature. They are typically suggestions around best practices or readability. Code maintainers should use their own judgment as to whether to address such issues.
- Issues without a severity are general recommendations or optional improvements. They are not related to security or correctness and may be addressed at the discretion of the maintainer.

[### 4.1 Heavy Blocks May Affect Block Finalization, if the Gas Requirement Exceeds Block Gas Limit Major](#heavy-blocks-may-affect-block-finalization-if-the-gas-requirement-exceeds-block-gas-limit)

#### Description

The `sequencer` takes care of finalizing blocks by submitting proof, blocks’ data, proof type, and parent state root hash. The team mentions that the blocks are finalized every 12s, and under general scenarios, the system will work fine. However, in cases where there are blocks containing lots of transactions and event logs, the function may require gas more than the block gas limit. As a consequence, it may affect block finalization or lead to a potential DoS.

#### Examples

**contracts/contracts/ZkEvmV2.sol:L110-L115**

```
function finalizeBlocks(
  BlockData[] calldata _blocksData,
  bytes calldata _proof,
  uint256 _proofType,
  bytes32 _parentStateRootHash
)
```

#### Recommendation

We advise the team to benchmark the cost associated per block for the finalization and how many blocks can be finalized in one rollup and add the limits accordingly for the prover/sequencer.

[### 4.2 Postman Can Incorrectly Deliver a Message While Still Collecting the Fees Major](#postman-can-incorrectly-deliver-a-message-while-still-collecting-the-fees)

#### Description

The message service allows cross chain message delivery, where the user can define the parameters of the message as:

**from**: Sender of the message
**_to**: Receiver of the message
**_fee**: The fees, the sender wants to pay to the postman to deliver the message
**valueSent**: The value in the native currency of the chain to be sent with the message
**messageNumber**: Nonce value which increments for every message
**_calldata**: Calldata for the message to be executed on the destination chain

The postman estimates the gas before claiming/delivering the message on the destination chain, thus avoiding scenarios where the fees sent are less than the cost of claiming the message.

However, there is nothing that restricts the postman from sending the gas equal to the fees paid by the user. Although it contributes to the MEV, where the postman can select the messages with higher fees first and deliver them prior to others, it also opens up an opportunity where the postman can deliver a message incorrectly while still claiming the fees.

One such scenario is, where the low-level call to target `_to` makes another sub-call to another address, let’s say `x`. Let’s assume, the `_to` address doesn’t check, whether the call to address `x` was successful or not. Now, if the postman supplies a gas, which makes the top-level call succeed, but the low-level call to `x` fails silently, the postman will still be retrieving the fees of claiming the message, even though the message was not correctly delivered.

#### Examples

**contracts/contracts/messageService/l1/L1MessageService.sol:L125-L135**

```
(bool success, bytes memory returnData) = _to.call{ value: _value }(_calldata);
if (!success) {
  if (returnData.length > 0) {
    assembly {
      let data_size := mload(returnData)
      revert(add(32, returnData), data_size)
    }
  } else {
    revert MessageSendingFailed(_to);
  }
}
```

**contracts/contracts/messageService/l2/L2MessageService.sol:L150-L160**

```
(bool success, bytes memory returnData) = _to.call{ value: _value }(_calldata);
if (!success) {
  if (returnData.length > 0) {
    assembly {
      let data_size := mload(returnData)
      revert(add(32, returnData), data_size)
    }
  } else {
    revert MessageSendingFailed(_to);
  }
}
```

#### Recommendation

Another parameter can be added to the message construct giving the user the option to define the amount of gas required to complete a transaction entirely. Also, a check can be added while claiming the message, to make sure the gas supplied by the postman is sufficient enough compared to the gas defined/demanded by the user. The cases, where the user can demand a huge amount of gas, can be simply avoided by doing the gas estimation, and if the demanded gas is more than the supplied fees, the postman will simply opt not to deliver the message

[### 4.3 User’s Funds Would Stuck if the Message Claim Failed on the Destination Layer Major](#users-funds-would-stuck-if-the-message-claim-failed-on-the-destination-layer)

#### Description

When claiming the message on the destination layer, if the message failed to execute with various reasons (e.g. wrong target contract address, wrong contract logic, out of gas, malicious contract), the Ether sent with `sendMessage` on the original layer will be stuck, although the message can be retried later by the Postman or the user (could fail again)

#### Examples

**contracts/contracts/messageService/l1/L1MessageService.sol:L81-L84**

```
uint256 messageNumber = nextMessageNumber;
uint256 valueSent = msg.value - _fee;

bytes32 messageHash = keccak256(abi.encode(msg.sender, _to, _fee, valueSent, messageNumber, _calldata));
```

**contracts/contracts/messageService/l2/L2MessageService.sol:L150-L160**

```
(bool success, bytes memory returnData) = _to.call{ value: _value }(_calldata);
if (!success) {
  if (returnData.length > 0) {
    assembly {
      let data_size := mload(returnData)
      revert(add(32, returnData), data_size)
    }
  } else {
    revert MessageSendingFailed(_to);
  }
}
```

**contracts/contracts/messageService/l1/L1MessageService.sol:L125-L135**

```
(bool success, bytes memory returnData) = _to.call{ value: _value }(_calldata);
if (!success) {
  if (returnData.length > 0) {
    assembly {
      let data_size := mload(returnData)
      revert(add(32, returnData), data_size)
    }
  } else {
    revert MessageSendingFailed(_to);
  }
}
```

#### Recommendation

Add refund mechanism to refund users funds if the message failed to deliver on the destination layer

[### 4.4 Front Running finalizeBlocks When Sequencers Are Decentralized Major](#front-running-finalizeblocks-when-sequencers-are-decentralized)

#### Description

When sequencer is decentralized in the future, one sequencer could front run another sequencer’s `finalizeBlocks` transaction, without doing the actual proving and sequencing, and steal the reward for sequencing if there is one. Once the frontrunner’s finalizeBlocks is executed, the original sequencer’s transaction would fail as `currentL2BlockNumber` would increment by one and state root hash won’t match, as a result the original sequencer’s sequencing and proving work will be wasted.

#### Examples

**contracts/contracts/ZkEvmV2.sol:L110-L126**

```
function finalizeBlocks(
  BlockData[] calldata _blocksData,
  bytes calldata _proof,
  uint256 _proofType,
  bytes32 _parentStateRootHash
)
  external
  whenTypeNotPaused(PROVING_SYSTEM_PAUSE_TYPE)
  whenTypeNotPaused(GENERAL_PAUSE_TYPE)
  onlyRole(OPERATOR_ROLE)
{
  if (stateRootHashes[currentL2BlockNumber] != _parentStateRootHash) {
    revert StartingRootHashDoesNotMatch();
  }

  _finalizeBlocks(_blocksData, _proof, _proofType, _parentStateRootHash, true);
}
```

#### Recommendation

Add the sequencer’s address as one parameters in `_finalizeBlocks` function, and include the sequencer’s address in the public input hash of the proof in verification function `_verifyProof`.

```
function _finalizeBlocks(
   BlockData[] calldata _blocksData,
   bytes memory _proof,
   uint256 _proofType,
   bytes32 _parentStateRootHash,
   bool _shouldProve,
   address _sequencer
 )
```

```
_verifyProof(
        uint256(
          keccak256(
            abi.encode(
              keccak256(abi.encodePacked(blockHashes)),
              firstBlockNumber,
              keccak256(abi.encodePacked(timestampHashes)),
              keccak256(abi.encodePacked(hashOfRootHashes)),
              keccak256(abi.encodePacked(_sequencer)
            )
          )
        ) % MODULO_R,
        _proofType,
        _proof,
        _parentStateRootHash
      );
```

[### 4.5 User Funds Would Stuck if the Single Coordinator Is Offline or Censoring Messages Major](#user-funds-would-stuck-if-the-single-coordinator-is-offline-or-censoring-messages)

#### Description

When user sends message from L1 to L2, the coordinator needs to post the messages to L2, this happens in the anchoring message(`addL1L2MessageHashes`) on L2, then the user or Postman can claim the message on L2.
since there is only a single coordinator, if the coordinator is down or censoring messages sent from L1 to L2, users funds can stuck in L1, until the coordinator come back online or stops censoring the message, as there is no message cancel feature or message expire feature. Although the operator can pause message sending on L1 once the coordinator is down, but if the message is sent and not posted to L2 before the pause it will still stuck.

#### Examples

**contracts/contracts/messageService/l1/L1MessageService.sol:L81-L84**

```
uint256 messageNumber = nextMessageNumber;
uint256 valueSent = msg.value - _fee;

bytes32 messageHash = keccak256(abi.encode(msg.sender, _to, _fee, valueSent, messageNumber, _calldata));
```

**contracts/contracts/messageService/l2/L2MessageManager.sol:L42-L60**

```
function addL1L2MessageHashes(bytes32[] calldata _messageHashes) external onlyRole(L1_L2_MESSAGE_SETTER_ROLE) {
  uint256 messageHashesLength = _messageHashes.length;

  if (messageHashesLength > 100) {
    revert MessageHashesListLengthHigherThanOneHundred(messageHashesLength);
  }

  for (uint256 i; i < messageHashesLength; ) {
    bytes32 messageHash = _messageHashes[i];
    if (inboxL1L2MessageStatus[messageHash] == INBOX_STATUS_UNKNOWN) {
      inboxL1L2MessageStatus[messageHash] = INBOX_STATUS_RECEIVED;
    }
    unchecked {
      i++;
    }
  }

  emit L1L2MessageHashesAddedToInbox(_messageHashes);
}
```

#### Recommendation

Decentralize coordinator and sequencer or enable user cancel or drop the message if message deadline has expired.

[### 4.6 Changing Verifier Address Doesn’t Emit Event Major](#changing-verifier-address-doesnt-emit-event)

#### Description

In function `setVerifierAddress`, after the verifier address is changed, there is no event emitted, which means if the operator (security council) changes the verifier to a buggy verifier, or if the security council is compromised, the attacker can change the verifier to a malicious one, the unsuspecting user would still use the service, potentially lose funds due to the fraud transactions would be verified.

#### Examples

**contracts/contracts/ZkEvmV2.sol:L83-L88**

```
function setVerifierAddress(address _newVerifierAddress, uint256 _proofType) external onlyRole(DEFAULT_ADMIN_ROLE) {
  if (_newVerifierAddress == address(0)) {
    revert ZeroAddressNotAllowed();
  }
  verifiers[_proofType] = _newVerifierAddress;
}
```

#### Recommendation

Emits event after changing verifier address including old verifier address, new verifier address and the caller account

[### 4.7 L2 Blocks With Incorrect Timestamp Could Be Finalized Medium](#l2-blocks-with-incorrect-timestamp-could-be-finalized)

#### Description

In `_finalizeBlocks` of `ZkEvmV2`, the current block timestamp `blockInfo.l2BlockTimestamp` should be greater or equal than the last L2 block timestamp and less or equal than the L1 block timestamp when `_finalizeBlocks` is executed. However the first check is missing, blocks with incorrect timestamp could be finalized, causing unintended system behavior

#### Examples

**contracts/contracts/ZkEvmV2.sol:L158-L160**

```
if (blockInfo.l2BlockTimestamp >= block.timestamp) {
  revert BlockTimestampError();
}
```

#### Recommendation

Add the missing timestamp check

[### 4.8 Rate Limiting Affecting the Usability and User’s Funds Safety Medium](#rate-limiting-affecting-the-usability-and-users-funds-safety)

#### Description

In `claimMessage` of `L1MessageService` and `sendMessage` function of `L1MessageService` contract, function `_addUsedAmount` is used to rate limit the Ether amount (1000 Eth) sent from L2 to L1 in a time period (24 hours), this is problematic, usually user sends the funds to L1 when they need to exit from L2 to L1 especially when some security issues happened affecting their funds safety on L2, if there is a limit, the limit can be reached quickly by some whale sending large amount of Ether to L1, while other users cannot withdraw their funds to L1, putting their funds at risk. In addition, the limit can only be set and changed by the security council and security council can also pause message service at any time, blocking user withdraw funds from L2, this makes the L2->L1 message service more centralized.

#### Examples

**contracts/contracts/messageService/l1/L1MessageService.sol:L121**

```
_addUsedAmount(_fee + _value);
```

**contracts/contracts/messageService/l2/L2MessageService.sol:L108**

```
_addUsedAmount(msg.value);
```

**contracts/contracts/messageService/lib/RateLimiter.sol:L53-L69**

```
function _addUsedAmount(uint256 _usedAmount) internal {
  uint256 currentPeriodAmountTemp;

  if (currentPeriodEnd < block.timestamp) {
    // Update period before proceeding
    currentPeriodEnd = block.timestamp + periodInSeconds;
    currentPeriodAmountTemp = _usedAmount;
  } else {
    currentPeriodAmountTemp = currentPeriodAmountInWei + _usedAmount;
  }

  if (currentPeriodAmountTemp > limitInWei) {
    revert RateLimitExceeded();
  }

  currentPeriodAmountInWei = currentPeriodAmountTemp;
}
```

#### Recommendation

Remove rate limiting for L2->L1 message service

[### 4.9 Front Running claimMessage on L1 and L2 Medium](#front-running-claimmessage-on-l1-and-l2)

#### Description

The front-runner on L1 or L2 can front run the `claimMessage` transaction, as long as the `fee` is greater than the gas cost of the claiming the message and `feeRecipient` is not set, consequently the fee will be transferred to the `message.sender`(the front runner) once the message is claimed. As a result, postman would lose the incentive to deliver(claim) the message on the destination layer.

#### Examples

**contracts/contracts/messageService/l1/L1MessageService.sol:L137-L142**

```
if (_fee > 0) {
  address feeReceiver = _feeRecipient == address(0) ? msg.sender : _feeRecipient;
  (bool feePaymentSuccess, ) = feeReceiver.call{ value: _fee }("");
  if (!feePaymentSuccess) {
    revert FeePaymentFailed(feeReceiver);
  }
```

**contracts/contracts/messageService/l2/L2MessageService.sol:L162-L168**

```
if (_fee > 0) {
  address feeReceiver = _feeRecipient == address(0) ? msg.sender : _feeRecipient;
  (bool feePaymentSuccess, ) = feeReceiver.call{ value: _fee }("");
  if (!feePaymentSuccess) {
    revert FeePaymentFailed(feeReceiver);
  }
}
```

#### Recommendation

There are a few protections against front running including flashbots service. Another option to mitigate front running is to avoid using msg.sender and have user use the signed `claimMessage` transaction by the Postman to claim the message on the destination layer

[### 4.10 Contracts Not Well Designed for Upgrades Medium](#contracts-not-well-designed-for-upgrades)

#### Description

1. **Inconsistent Storage Layout**

The Contracts introduce some buffer space in the storage layout to cope with the scenarios where new storage variables can be added if a need exists to upgrade the contracts to a newer version. This helps in reducing the chances of potential storage collisions.
However, the storage layout concerning the buffer space is inconsistent, and multiple variations have been observed.

- `PauseManager`, `RateLimitter`, and `MessageServiceBase` adds a buffer space of 10, contrary to other contracts which define the space as 50.

**contracts/contracts/messageService/lib/PauseManager.sol:L22**

```
uint256[10] private _gap;
```

**contracts/contracts/messageService/lib/RateLimiter.sol:L26**

```
uint256[10] private _gap;
```

**contracts/contracts/messageService/MessageServiceBase.sol:L14**

```
uint256[10] private __base_gap;
```

- `L2MessageService` defines the buffer space prior to its existing storage variables.

**contracts/contracts/messageService/l2/L2MessageService.sol:L16**

```
uint256[50] private __gap_L2MessageService;
```

If there exists a need to inherit from this contract in the future, the derived contract has to define the buffer space first, similar to `L2MessageService`. If it doesn’t, `L2MessageService` can’t have more storage variables. If it adds them, it will collide with the derived contract’s storage slots.

**2. `RateLimiter` and `MessageServiceBase` initializes values without the modifier `onlyInitializing`**

**contracts/contracts/messageService/lib/RateLimiter.sol:L33**

```
function __RateLimiter_init(uint256 _periodInSeconds, uint256 _limitInWei) internal {
```

**contracts/contracts/messageService/MessageServiceBase.sol:L65**

```
function _init_MessageServiceBase(address _messageService, address _remoteSender) internal {
```

The modifier `onlyInitializing` makes sure that the function should only be invoked by a function marked as `initializer`. However, it is absent here, which means these are normal internal functions that can be utilized in any other function, thus opening opportunities for errors.

#### Recommendation

1. Define a consistent storage layout. Consider a positive number `n` for the number of buffer space slots, such that, it is equal to any arbitrary number `d - No. of occupied storage slots`. For instance, if the arbitrary number is 50, and the contract has 20 occupied storage slots, the buffer space can be 50-20 = 30. It will maintain a consistent storage layout throughout the inheritance hierarchy.
2. Follow a consistent approach to defining buffer space. Currently, all the contracts, define the buffer space after their occupied storage slots, so it should be maintained in the `L2MessageService` as well.
3. Define functions `__RateLimiter_init` and `_init_MessageServiceBase` as `onlyInitializing`.

[### 4.11 Potential Code Corrections Minor](#potential-code-corrections)

#### Description

1. Function `_updateL1L2MessageStatusToReceived` and `addL1L2MessageHashes` allows status update for already received/sent/claimed messages.

**contracts/contracts/messageService/l1/L1MessageManager.sol:L76-L97**

```
function _updateL1L2MessageStatusToReceived(bytes32[] memory _messageHashes) internal {
  uint256 messageHashArrayLength = _messageHashes.length;

  for (uint256 i; i < messageHashArrayLength; ) {
    bytes32 messageHash = _messageHashes[i];
    uint256 existingStatus = outboxL1L2MessageStatus[messageHash];

    if (existingStatus == INBOX_STATUS_UNKNOWN) {
      revert L1L2MessageNotSent(messageHash);
    }

    if (existingStatus != OUTBOX_STATUS_RECEIVED) {
      outboxL1L2MessageStatus[messageHash] = OUTBOX_STATUS_RECEIVED;
    }

    unchecked {
      i++;
    }
  }

  emit L1L2MessagesReceivedOnL2(_messageHashes);
}
```

**contracts/contracts/messageService/l2/L2MessageManager.sol:L42-L59**

```
function addL1L2MessageHashes(bytes32[] calldata _messageHashes) external onlyRole(L1_L2_MESSAGE_SETTER_ROLE) {
  uint256 messageHashesLength = _messageHashes.length;

  if (messageHashesLength > 100) {
    revert MessageHashesListLengthHigherThanOneHundred(messageHashesLength);
  }

  for (uint256 i; i < messageHashesLength; ) {
    bytes32 messageHash = _messageHashes[i];
    if (inboxL1L2MessageStatus[messageHash] == INBOX_STATUS_UNKNOWN) {
      inboxL1L2MessageStatus[messageHash] = INBOX_STATUS_RECEIVED;
    }
    unchecked {
      i++;
    }
  }

  emit L1L2MessageHashesAddedToInbox(_messageHashes);
```

It may trigger false alarms, as they will still be a part of `L1L2MessagesReceivedOnL2` and `L1L2MessageHashesAddedToInbox`.

2. `_updateL1L2MessageStatusToReceived` checks the status of L1->L2 messages as:

**contracts/contracts/messageService/l1/L1MessageManager.sol:L83-L85**

```
if (existingStatus == INBOX_STATUS_UNKNOWN) {
  revert L1L2MessageNotSent(messageHash);
}
```

However, the status is need to be checked with `OUTBOX_STATUS_UNKNOWN` instead of `INBOX_STATUS_UNKNOWN` as it is an outbox message. This creates a hindrance in the code readability and should be fixed.

3. Array `timestampHashes` stores `l2BlockTimestamp` as integers, contrary to the hashes that the variable name states.

**contracts/contracts/ZkEvmV2.sol:L172**

```
timestampHashes[i] = blockInfo.l2BlockTimestamp;
```

4. Unused error declaration

**contracts/contracts/messageService/lib/TransactionDecoder.sol:L21-L24**

```
 * dev Thrown when the decoding action is invalid.
 */

error InvalidAction();
```

TransactionDecoder defines an error as `InvalidAction` which is supposed to be thrown when the decoding action is invalid, as stated in NATSPEC comment. However, it is currently unutilized.

#### Recommendation

1. Only update the status for sent messages in `_updateL1L2MessageStatusToReceived`, and unknown messages in `addL1L2MessageHashes` and revert otherwise, to avoid off-chain accounting errors.
2. Check the status of L1->L2 sent message with `OUTBOX_STATUS_UNKNOWN` to increase code readability.
3. Either store timestamp hashes in the variable `timestampHashes` or update the variable name likewise.
4. Remove the error declaration if it is not serving any purpose.

[### 4.12 TransactionDecoder Does Not Account for the Missing Elements While Decoding a Transaction Minor](#transactiondecoder-does-not-account-for-the-missing-elements-while-decoding-a-transaction)

#### Description

The library tries to decode calldata from different transaction types, by jumping to the position of calldata element in the rlp encoding. These positions are:

- EIP1559: 8
- EIP2930: 7
- Legacy: 6

#### Examples

**contracts/contracts/messageService/lib/TransactionDecoder.sol:L69**

```
data = it._skipTo(8)._toBytes();
```

**contracts/contracts/messageService/lib/TransactionDecoder.sol:L83**

```
data = it._skipTo(7)._toBytes();
```

**contracts/contracts/messageService/lib/TransactionDecoder.sol:L97**

```
data = it._skipTo(6)._toBytes();
```

However, the decoder doesn’t check whether the required element is there or not in the encoding provided.

The decoder uses the library RLPReader to skip to the desired element in encoding. However, it doesn’t revert in case there are not enough elements to skip to, and will simply return byte `0x00`, while still completing unnecessary iterations.

**contracts/contracts/messageService/lib/Rlp.sol:L54-L71**

```
function _skipTo(Iterator memory _self, uint256 _skipToNum) internal pure returns (RLPItem memory item) {
  uint256 ptr = _self.nextPtr;
  uint256 itemLength = _itemLength(ptr);
  _self.nextPtr = ptr + itemLength;

  for (uint256 i; i < _skipToNum - 1; ) {
    ptr = _self.nextPtr;
    itemLength = _itemLength(ptr);
    _self.nextPtr = ptr + itemLength;

    unchecked {
      i++;
    }
  }

  item.len = itemLength;
  item.memPtr = ptr;
}
```

Although it doesn’t impose any security issue, as `ZkEvmV2` tries to decode an array of bytes32 hashes from the rlp encoded transaction. However, it may still lead to errors in other use cases if not handled correctly.

**contracts/contracts/ZkEvmV2.sol:L222**

```
CodecV2._extractXDomainAddHashes(TransactionDecoder.decodeTransaction(_transactions[_batchReceptionIndices[i]]))
```

#### Recommendation

rlp library should revert if there are not enough elements to skip to in the encoding.

[### 4.13 Incomplete Message State Check When Claiming Messages on L1 and L2 Minor](#incomplete-message-state-check-when-claiming-messages-on-l1-and-l2)

#### Description

When claiming message on L1 orL2, `_updateL2L1MessageStatusToClaimed` and `_updateL1L2MessageStatusToClaimed` are called to update the message status, however the message state check only checks status `INBOX_STATUS_RECEIVED` and is missing status `INBOX_STATUS_UNKNOWN`, which means the message is not picked up by the coordinator or the message is not sent on L1 or L2 and should be reverted. As a result, the claiming message could be reverted with a incorrect reason.

#### Examples

**contracts/contracts/messageService/l1/L1MessageManager.sol:L52-L60**

```
function _updateL2L1MessageStatusToClaimed(bytes32 _messageHash) internal {
  if (inboxL2L1MessageStatus[_messageHash] != INBOX_STATUS_RECEIVED) {
    revert MessageAlreadyClaimed();
  }

  delete inboxL2L1MessageStatus[_messageHash];

  emit L2L1MessageClaimed(_messageHash);
}
```

**contracts/contracts/messageService/l2/L2MessageManager.sol:L66-L75**

```
  function _updateL1L2MessageStatusToClaimed(bytes32 _messageHash) internal {
    if (inboxL1L2MessageStatus[_messageHash] != INBOX_STATUS_RECEIVED) {
      revert MessageAlreadyClaimed();
    }

    inboxL1L2MessageStatus[_messageHash] = INBOX_STATUS_CLAIMED;

    emit L1L2MessageClaimed(_messageHash);
  }
}
```

#### Recommendation

Add the missing status check and relevant revert reason for status `INBOX_STATUS_UNKNOWN`

[### 4.14 Events Which May Trigger False Alarms Minor](#events-which-may-trigger-false-alarms)

#### Description

**1- `PauseManager` allows `PAUSE_MANAGER_ROLE` to pause/unpause a type as:**

**contracts/contracts/bridge/lib/PauseManager.sol:L60-L63**

```
function pauseByType(bytes32 _pauseType) external onlyRole(PAUSE_MANAGER_ROLE) {
  pauseTypeStatuses[_pauseType] = true;
  emit Paused(_msgSender(), _pauseType);
}
```

**contracts/contracts/bridge/lib/PauseManager.sol:L70-L73**

```
function unPauseByType(bytes32 _pauseType) external onlyRole(PAUSE_MANAGER_ROLE) {
  pauseTypeStatuses[_pauseType] = false;
  emit UnPaused(_msgSender(), _pauseType);
}
```

However, the functions don’t check whether the given `_pauseType` has already been paused/unpaused or not and emits an event every time called. This may trigger false alarms for off-chain monitoring tools and may cause unnecessary panic.

**2 - `RateLimitter` allows resetting the limit and used amount as:**

**contracts/contracts/messageService/lib/RateLimiter.sol:L78-L89**

```
function resetRateLimitAmount(uint256 _amount) external onlyRole(RATE_LIMIT_SETTER_ROLE) {
  bool amountUsedLoweredToLimit;

  if (_amount < currentPeriodAmountInWei) {
    currentPeriodAmountInWei = _amount;
    amountUsedLoweredToLimit = true;
  }

  limitInWei = _amount;

  emit LimitAmountChange(_msgSender(), _amount, amountUsedLoweredToLimit);
}
```

**contracts/contracts/messageService/lib/RateLimiter.sol:L96-L100**

```
function resetAmountUsedInPeriod() external onlyRole(RATE_LIMIT_SETTER_ROLE) {
  currentPeriodAmountInWei = 0;

  emit AmountUsedInPeriodReset(_msgSender());
}
```

However, it doesn’t account for the scenarios where the function can be called after the current period ends and before a new period gets started. As the `currentPeriodAmountInWei` will still be holding the used amount of the last period, if the `RATE_LIMIT_SETTER_ROLE` tries to reset the limit with the lower value than the used amount, the function will emit the same event `LimitAmountChange` with the flag `amountUsedLoweredToLimit`.

Adding to it, the function will make `currentPeriodAmountInWei` = `limitInWei`, which means no more amount can be added as the used amount until the used amount is manually reset to 0, which points out to the fact that the used amount should be automatically reset, once the current period ends. Although it is handled automatically in function `_addUsedAmount`, however, if the new period has not yet started, it is supposed to be done in a 2-step approach i.e., first, reset the used amount and then the limit. It can be simplified by checking for the current period in the `resetRateLimitAmount` function itself.

The same goes for the scenario where the used amount is reset after the current period ends. It will emit the same event as `AmountUsedInPeriodReset`

These can create unnecessary confusion, as the events emitted don’t consider the abovementioned scenarios.

#### Recommendation

1. Consider adding checks to make sure already paused/unpaused types don’t emit respective events.
2. Consider emitting different events, or adding a flag in the events, that makes it easy to differentiate whether the limit and used amount are reset in the current period or after it has ended.
3. Reset `currentPeriodAmountInWei` in function `resetRateLimitAmount` itself if the current period has ended.

[### 4.15 PauseManager - Unnecessary Explicit Initialization of Values](#pausemanager---unnecessary-explicit-initialization-of-values)

#### Description

`__PauseManager_init` explicitly initializes, defined types with the default boolean value `false`, which is unnecessary and can be removed.

**contracts/contracts/bridge/lib/PauseManager.sol:L49-L53**

```
function __PauseManager_init() internal onlyInitializing {
  pauseTypeStatuses[L1_L2_PAUSE_TYPE] = false;
  pauseTypeStatuses[L2_L1_PAUSE_TYPE] = false;
  pauseTypeStatuses[PROVING_SYSTEM_PAUSE_TYPE] = false;
}
```

[### 4.16 CodecV2 - Code Optimization](#codecv2---code-optimization)

#### Description

The library provides a simple utility function to decode an array of bytes32 hashes from calldata of a transaction as:

**contracts/contracts/messageService/lib/Codec.sol:L17-L19**

```
function _extractXDomainAddHashes(bytes memory _calldataWithSelector) internal pure returns (bytes32[] memory) {
  return abi.decode(_slice(_calldataWithSelector, 4, _calldataWithSelector.length - 4), (bytes32[]));
}
```

which involves slicing down the memory array to get the desired length. However, the process can be simplified by switching `_calldataWithSelector` from **memory** to **calldata**, as solidity provides the index range access feature for calldata arrays.

#### Recommendation

The code can be simplified to increase code readability and decrease gas cost as:

```
  function _extractXDomainAddHashes(bytes calldata _calldataWithSelector) internal pure returns (bytes32[] memory) {
    return abi.decode(_calldataWithSelector[4:],(bytes32[]));
  }
```

**Update**:
Since switching from `memory` to `calldata` may require making the library external and also `ZkEvmV2` to make an external call to the library. The optimization will increase the gas cost instead of reducing it.

**contracts/contracts/ZkEvmV2.sol:L221-L223**

```
_updateL1L2MessageStatusToReceived(
  CodecV2._extractXDomainAddHashes(TransactionDecoder.decodeTransaction(_transactions[_batchReceptionIndices[i]]))
);
```

A better approach could be to recraft the memory array skipping the 4 bytes selector as:

```
function _extractXDomainAddHashes(bytes memory _calldataWithSelector) internal pure returns (bytes32[] memory) {
    assembly{
      let len:=sub(mload(_calldataWithSelector),4)
      _calldataWithSelector:=add(_calldataWithSelector,0x4)
      mstore(_calldataWithSelector, len)
    }
    
    return abi.decode(_calldataWithSelector, (bytes32[]));
```

## Appendix 1 - Files in Scope

This audit covered the following files:

| File | SHA-1 hash |
| --- | --- |
|  |  |
| contracts/contracts/messageService/interfaces/IGenericErrors.sol | `cfeb7443de6a640484d9b5a630ddc0a4d7ae7e1c` |
| contracts/contracts/messageService/interfaces/IL1MessageManager.sol | `c114d8066d491714d48060a53b6de99e6f41f522` |
| contracts/contracts/messageService/interfaces/IL2MessageManager.sol | `31792d19357a1f5bf768d692b68d21c7fd39e743` |
| contracts/contracts/messageService/interfaces/IMessageService.sol | `9c992a5921ba6df8092a3fa58db5a244d87e50fa` |
| contracts/contracts/messageService/interfaces/IPauseManager.sol | `ddbf64704f1747711aa6c09c8e5d6c391f80fbc3` |
| contracts/contracts/messageService/interfaces/IPlonkVerifier.sol | `83d863eccc5bae64d5a9b96a5a34e875b5b8da9f` |
| contracts/contracts/messageService/interfaces/IRateLimiter.sol | `6fc294bae9422a8ecc05fc8b6a04bdce3eed2bef` |
| contracts/contracts/messageService/l1/L1MessageManager.sol | `18dc4478c71fffd7a897a5903b583f5bc16892d8` |
| contracts/contracts/messageService/l1/L1MessageService.sol | `ed299266790f20e41defdbfb26eed977371bf3fa` |
| contracts/contracts/messageService/l2/L2MessageManager.sol | `4eb1bb6bb3440f87d2658bcce7eba05dabafe683` |
| contracts/contracts/messageService/l2/L2MessageService.sol | `9e0b837d8c648e7bed67da5e97864c83a52e4ed1` |
| contracts/contracts/messageService/lib/Codec.sol | `bd03d636aa0312d2d76657ac737d69324532d35f` |
| contracts/contracts/messageService/lib/PauseManager.sol | `1df5d668b441d604fe6bc304f0aaf2e476b7ebfa` |
| contracts/contracts/messageService/lib/RateLimiter.sol | `efd6b6f0ed97a7511832ca5d64585c0525be49a2` |
| contracts/contracts/messageService/lib/Rlp.sol | `f51f7adeb8a55f6e51b3bfd06c67e6d324247fba` |
| contracts/contracts/messageService/lib/TimeLock.sol | `bbbef8a649a0db8a5bf34f8e6c37c8cdeef0ade1` |
| contracts/contracts/messageService/lib/TransactionDecoder.sol | `0c9d0706d26aae5f5e9d01516493fddfeac9fef0` |
| contracts/contracts/messageService/MessageServiceBase.sol | `860159508dfd123a8833529e06f172e27f7104cb` |
| contracts/contracts/IZkEvmV2.sol | `4ab8de980ee93782cfce709b2d8bd5d15d287313` |
| contracts/contracts/ZkEvmV2.sol | `318b61de3f4d412a1c8c65f96cef0c64416cbde4` |
| contracts/contracts/ZkEvmV202.sol | `c294d9f6e89eabbf96c0e003eedf882d21a61906` |

## Appendix 2 - Disclosure

ConsenSys Diligence (“CD”) typically receives compensation from one or more clients (the “Clients”) for performing the analysis contained in these reports (the “Reports”). The Reports may be distributed through other means, including via ConsenSys publications and other distributions.

The Reports are not an endorsement or indictment of any particular project or team, and the Reports do not guarantee the security of any particular project. This Report does not consider, and should not be interpreted as considering or having any bearing on, the potential economics of a token, token sale or any other product, service or other asset. Cryptographic tokens are emergent technologies and carry with them high levels of technical risk and uncertainty. No Report provides any warranty or representation to any Third-Party in any respect, including regarding the bugfree nature of code, the business model or proprietors of any such business model, and the legal compliance of any such business. No third party should rely on the Reports in any way, including for the purpose of making any decisions to buy or sell any token, product, service or other asset. Specifically, for the avoidance of doubt, this Report does not constitute investment advice, is not intended to be relied upon as investment advice, is not an endorsement of this project or team, and it is not a guarantee as to the absolute security of the project. CD owes no duty to any Third-Party by virtue of publishing these Reports.

PURPOSE OF REPORTS The Reports and the analysis described therein are created solely for Clients and published with their consent. The scope of our review is limited to a review of code and only the code we note as being within the scope of our review within this report. Any Solidity code itself presents unique and unquantifiable risks as the Solidity language itself remains under development and is subject to unknown risks and flaws. The review does not extend to the compiler layer, or any other areas beyond specified code that could present security risks. Cryptographic tokens are emergent technologies and carry with them high levels of technical risk and uncertainty. In some instances, we may perform penetration testing or infrastructure assessments depending on the scope of the particular engagement.

CD makes the Reports available to parties other than the Clients (i.e., “third parties”) – on its website. CD hopes that by making these analyses publicly available, it can help the blockchain ecosystem develop technical best practices in this rapidly evolving area of innovation.

LINKS TO OTHER WEB SITES FROM THIS WEB SITE You may, through hypertext or other computer links, gain access to web sites operated by persons other than ConsenSys and CD. Such hyperlinks are provided for your reference and convenience only, and are the exclusive responsibility of such web sites’ owners. You agree that ConsenSys and CD are not responsible for the content or operation of such Web sites, and that ConsenSys and CD shall have no liability to you or any other person or entity for the use of third party Web sites. Except as described below, a hyperlink from this web Site to another web site does not imply or mean that ConsenSys and CD endorses the content on that Web site or the operator or operations of that site. You are solely responsible for determining the extent to which you may use any content at any other web sites to which you link from the Reports. ConsenSys and CD assumes no responsibility for the use of third party software on the Web Site and shall have no liability whatsoever to any person or entity for the accuracy or completeness of any outcome generated by such software.

TIMELINESS OF CONTENT The content contained in the Reports is current as of the date appearing on the Report and is subject to change without notice. Unless indicated otherwise, by ConsenSys and CD.
