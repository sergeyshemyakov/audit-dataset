// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {L2Log, L2Message} from "../Storage.sol";

/// @dev The enum that represents the transaction execution status
/// @param Failure The transaction execution failed
/// @param Success The transaction execution succeeded
enum TxStatus {
    Failure,
    Success
}

interface IMailbox {
    /// @dev Structure that includes all fields of the L2 transaction
    /// @dev The hash of this structure is the "canonical L2 transaction hash" and can be used as a unique identifier of a tx
    /// @param txType The tx type number, depending on which the L2 transaction can be interpreted differently
    /// @param from The sender's address. `uint256` type for possible address format changes and maintaining backward compatibility
    /// @param to The recipient's address. `uint256` type for possible address format changes and maintaining backward compatibility
    /// @param ergsLimit Ergs limit on L2 transaction. Analog to the `gasLimit` on an L1 transactions
    /// @param ergsPerPubdataByteLimit Maximum number of ergs that will cost one byte of pubdata (every piece of data that will be stored on L1 as calldata)
    /// @param maxFeePerErg The absolute maximum sender willing to pay per unit of ergs to get the transaction included in a block. Analog to the EIP-1559 `maxFeePerGas` on an L1 transactions
    /// @param maxPriorityFeePerErg The additional fee that is paid directly to the validator to incentivize them to include the transaction in a block. Analog to the EIP-1559 `maxPriorityFeePerGas` on an L1 transactions
    /// @param paymaster The address of the EIP-4337 paymaster, that will pay fees for the transaction. `uint256` type for possible address format changes and maintaining backward compatibility
    /// @param nonce The nonce of the transaction. For L1->L2 transactions it is the priority operation Id.
    /// @param value The value to pass with the transaction
    /// @param reserved The fixed-length fields for usage in a future extension of transaction formats
    /// @param data The calldata that is transmitted for the transaction call
    /// @param signature An abstract set of bytes that are used for transaction authorization
    /// @param factoryDeps The set of L2 bytecode hashes whose preimages were shown on L1
    /// @param paymasterInput The arbitrary-length data that is used as a calldata to the paymaster pre-call
    /// @param reservedDynamic The arbitrary-length field for usage in a future extension of transaction formats
    struct L2CanonicalTransaction {
        uint256 txType;
        uint256 from;
        uint256 to;
        uint256 ergsLimit;
        uint256 ergsPerPubdataByteLimit;
        uint256 maxFeePerErg;
        uint256 maxPriorityFeePerErg;
        uint256 paymaster;
        uint256 nonce;
        uint256 value;
        // In the future, we might want to add some
        // new fields to the struct. The `txData` struct
        // is to be passed to account and any changes to its structure
        // would mean a breaking change to these accounts. To prevent this,
        // we should keep some fields as "reserved".
        // It is also recommended that their length is fixed, since
        // it would allow easier proof integration (in case we will need
        // some special circuit for preprocessing transactions).
        uint256[4] reserved;
        bytes data;
        bytes signature;
        uint256[] factoryDeps;
        bytes paymasterInput;
        // Reserved dynamic type for the future use-case. Using it should be avoided,
        // But it is still here, just in case we want to enable some additional functionality.
        bytes reservedDynamic;
    }

    function proveL2MessageInclusion(
        uint256 _blockNumber,
        uint256 _index,
        L2Message calldata _message,
        bytes32[] calldata _proof
    ) external view returns (bool);

    function proveL2LogInclusion(uint256 _blockNumber, uint256 _index, L2Log memory _log, bytes32[] calldata _proof)
        external
        view
        returns (bool);

    function proveL1ToL2TransactionStatus(
        bytes32 _l2TxHash,
        uint256 _l2BlockNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBlock,
        bytes32[] calldata _merkleProof,
        TxStatus _status
    ) external view returns (bool);

    function serializeL2Transaction(
        uint256 _txId,
        uint256 _l2Value,
        address _sender,
        address _contractAddressL2,
        bytes calldata _calldata,
        uint256 _ergsLimit,
        uint256 _ergsPerPubdataByteLimit,
        bytes[] calldata _factoryDeps,
        uint256 _toMint,
        address _refundRecipient
    ) external pure returns (L2CanonicalTransaction memory);

    function finalizeEthWithdrawal(
        address _l1WithdrawReceiver,
        uint256 _amount,
        uint256 _l2BlockNumber,
        uint256 _l2MessageIndex,
        uint16 _l2TxNumberInBlock,
        bytes32[] calldata _merkleProof
    ) external;

    function requestL2Transaction(
        address _contractL2,
        uint256 _l2Value,
        bytes calldata _calldata,
        uint256 _ergsLimit,
        uint256 _ergsPerPubdataByteLimit,
        bytes[] calldata _factoryDeps
    ) external payable returns (bytes32 canonicalTxHash);

    function l2TransactionBaseCost(uint256 _gasPrice, uint256 _ergsLimit, uint256 _ergsPerPubdataByteLimit)
        external
        view
        returns (uint256);

    /// @notice New priority request event. Emitted when a request is placed into the priority queue
    /// @param txId Serial number of the priority operation
    /// @param txHash keccak256 hash of encoded transaction representation
    /// @param expirationTimestamp Timestamp up to which priority request should be processed
    /// @param transaction The whole transaction structure that is requested to be executed on L2
    /// @param factoryDeps An array of bytecodes that were shown in the L1 public data. Will be marked as known bytecodes in L2
    event NewPriorityRequest(
        uint256 txId,
        bytes32 txHash,
        uint64 expirationTimestamp,
        L2CanonicalTransaction transaction,
        bytes[] factoryDeps
    );

    /// @notice Emitted when the withdrawal is finalized on L1 and funds are released.
    /// @param to The address to which the funds were sent
    /// @param amount The amount of funds that were sent
    event EthWithdrawalFinalized(address indexed to, uint256 amount);
}
