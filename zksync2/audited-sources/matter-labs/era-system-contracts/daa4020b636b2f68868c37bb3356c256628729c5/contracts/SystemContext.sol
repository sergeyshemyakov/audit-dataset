// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {BOOTLOADER_FORMAL_ADDRESS} from "./Constants.sol";
import {ISystemContext} from "./interfaces/ISystemContext.sol";
import {ISystemContextDeprecated} from "./interfaces/ISystemContextDeprecated.sol";
import {SystemContractHelper} from "./libraries/SystemContractHelper.sol";

/**
 * @author Matter Labs
 * @notice Contract that stores some of the context variables, that may be either
 * block-scoped, tx-scoped or system-wide.
 */
contract SystemContext is ISystemContext, ISystemContextDeprecated {
    modifier onlyBootloader() {
        require(msg.sender == BOOTLOADER_FORMAL_ADDRESS);
        _;
    }

    /// @notice The chainId of the network. It is set at the genesis.
    uint256 public chainId;

    /// @notice The `tx.origin` in the current transaction.
    /// @dev It is updated before each transaction by the bootloader
    address public origin;

    /// @notice The `tx.gasPrice` in the current transaction.
    /// @dev It is updated before each transaction by the bootloader
    uint256 public gasPrice;

    /// @notice The current block's gasLimit.
    uint256 public blockGasLimit = type(uint32).max;

    /// @notice The `block.coinbase` in the current transaction.
    /// @dev For the support of coinbase, we will the bootloader formal address for now
    address public coinbase = BOOTLOADER_FORMAL_ADDRESS;

    /// @notice Formal `block.difficulty` parameter.
    uint256 public difficulty = 2500000000000000;

    /// @notice The `block.basefee`.
    /// @dev It is currently a constant.
    uint256 public baseFee;

    /// @notice The number and the timestamp of the current L1 batch stored packed.
    BlockInfo internal currentBatchInfo;

    /// @notice The hashes of batches.
    /// @dev It stores batch hashes for all previous batches.
    mapping(uint256 => bytes32) internal batchHash;

    /// @notice The number and the timestamp of the current L2 block.
    BlockInfo internal currentL2BlockInfo;

    /// @notice The hashes of L2 blocks.
    /// @dev It stores block hashes for previous L2 blocks. Note, that for some of the old L2 blocks
    /// we do not store the hashes, because the upgrade for storing those has been done only recently and
    /// EVM requires us to be able to provide only the latest 256 ones.
    /// @dev Hashes of the blocks older than the ones which are stored here can be calculated as _calculateLegacyL2BlockHash(blockNumber).
    mapping(uint256 => bytes32) internal l2BlockHash;

    /// @notice The rolling hash of the transactions in the current L2 block.
    bytes32 internal currentL2BlockTxsRollingHash;

    /// @notice Set the current tx origin.
    /// @param _newOrigin The new tx origin.
    function setTxOrigin(address _newOrigin) external onlyBootloader {
        origin = _newOrigin;
    }

    /// @notice Set the the current gas price.
    /// @param _gasPrice The new tx gasPrice.
    function setGasPrice(uint256 _gasPrice) external onlyBootloader {
        gasPrice = _gasPrice;
    }

    /// @notice The method that emulates `blockhash` opcode in EVM.
    /// @dev Just like the blockhash in the EVM, it returns bytes32(0), when
    /// when queried about hashes that are older than 256 blocks ago.
    /// @dev Since zksolc compiler calls this method to emulate `blockhash`,
    /// its signature can not be changed to `getL2BlockHashEVM`.
    /// @return hash The blockhash of the block with the given number.
    function getBlockHashEVM(uint256 _block) external view returns (bytes32 hash) {
        uint128 blockNumber = currentL2BlockInfo.number;

        if (blockNumber <= _block || blockNumber - _block > 256) {
            hash = bytes32(0);
        } else {
            hash = l2BlockHash[_block];
        }
    }

    /// @notice Returns the hash of the given batch.
    /// @param _batchNumber The number of the batch.
    /// @return hash The hash of the batch.
    function getBatchHash(uint256 _batchNumber) external view returns (bytes32 hash) {
        hash = batchHash[_batchNumber];
    }

    /// @notice Returns the current batch's number and timestamp.
    /// @return batchNumber and batchTimestamp tuple of the current block's number and the current block's timestamp
    function getBatchNumberAndTimestamp() public view returns (uint128 batchNumber, uint128 batchTimestamp) {
        BlockInfo memory batchInfo = currentBatchInfo;
        batchNumber = batchInfo.number;
        batchTimestamp = batchInfo.timestamp;
    }

    /// @notice Returns the current block's number and timestamp.
    /// @return blockNumber and blockTimestamp tuple of the current L2 block's number and the current block's timestamp
    function getL2BlockNumberAndTimestamp() public view returns (uint128 blockNumber, uint128 blockTimestamp) {
        BlockInfo memory blockInfo = currentL2BlockInfo;
        blockNumber = blockInfo.number;
        blockTimestamp = blockInfo.timestamp;
    }

    /// @notice Returns the current L2 block's number.
    /// @dev Since zksolc compiler calls this method to emulate `block.number`,
    /// its signature can not be changed to `getL2BlockNumber`.
    /// @return blockNumber The current L2 block's number.
    function getBlockNumber() public view returns (uint128) {
        return currentL2BlockInfo.number;
    }

    /// @notice Returns the current L2 block's timestamp.
    /// @dev Since zksolc compiler calls this method to emulate `block.timestamp`,
    /// its signature can not be changed to `getL2BlockTimestamp`.
    /// @return timestamp The current L2 block's timestamp.
    function getBlockTimestamp() public view returns (uint128) {
        return currentL2BlockInfo.timestamp;
    }

    /// @notice Calculates the hash of an L2 block.
    /// @param _blockNumber The number of the L2 block.
    /// @param _blockTimestamp The timestamp of the L2 block.
    /// @param _prevL2BlockHash The hash of the previous L2 block.
    /// @param _blockTxsRollingHash The rolling hash of the transactions in the L2 block.
    function _calculateL2BlockHash(
        uint128 _blockNumber,
        uint128 _blockTimestamp,
        bytes32 _prevL2BlockHash,
        bytes32 _blockTxsRollingHash
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(_blockNumber, _blockTimestamp, _prevL2BlockHash, _blockTxsRollingHash));
    }

    /// @notice Calculates the legacy block hash of L2 block, which were used before the upgrade where
    /// the advanced block hashes were introduced.
    /// @param _blockNumber The number of the L2 block.
    function _calculateLegacyL2BlockHash(uint128 _blockNumber) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(uint32(_blockNumber)));
    }

    /// @notice Performs the upgrade where we transition to the L2 miniblocks.
    /// @param _l2BlockNumber The number of the new L2 block.
    /// @param _expectedPrevL2BlockHash The expected hash of the previous L2 block.
    /// @param _isFirstInBatch Whether this method is called for the first time in the batch.
    function _upgradeL2Blocks(uint128 _l2BlockNumber, bytes32 _expectedPrevL2BlockHash, bool _isFirstInBatch)
        internal
    {
        require(_isFirstInBatch, "Upgrade transaction must be first");

        // This is how it will be commonly done in practice, but it will simplify some logic later
        require(_l2BlockNumber > 0, "Miniblock number is never expected to be zero");

        unchecked {
            uint256 firstBlockToSet = _l2BlockNumber > 256 ? _l2BlockNumber - 256 : 0;
            for (uint256 i = firstBlockToSet; i <= _l2BlockNumber - 1; i++) {
                // All the previous blocks had the following format of the hash:
                l2BlockHash[i] = _calculateLegacyL2BlockHash(uint128(i));
            }
        }

        require(l2BlockHash[_l2BlockNumber - 1] == _expectedPrevL2BlockHash, "The previous L2 block hash is incorrect");
    }

    /// @notice Sets the current block number and timestamp of the L2 block.
    /// @param _l2BlockNumber The number of the new L2 block.
    /// @param _l2BlockTimestamp The timestamp of the new L2 block.
    /// @param _prevL2BlockHash The hash of the previous L2 block.
    function _setNewL2BlockData(uint128 _l2BlockNumber, uint128 _l2BlockTimestamp, bytes32 _prevL2BlockHash) internal {
        // In the unsafe version we do not check that the block data is correct
        currentL2BlockInfo = BlockInfo({number: _l2BlockNumber, timestamp: _l2BlockTimestamp});

        // It is always assumed in production that _l2BlockNumber > 0
        l2BlockHash[_l2BlockNumber - 1] = _prevL2BlockHash;

        // Reseting the rolling hash
        currentL2BlockTxsRollingHash = bytes32(0);
    }

    /// @notice Sets the current block number and timestamp of the L2 block.
    /// @dev Called by the bootloader before each transaction. This is needed to ensure
    /// that the data about the block is consistent with the sequencer.
    /// @dev If the new block number is the same as the current one, we ensure that the block's data is
    /// consistent with the one in the current block.
    /// @dev If the new block number is greater than the current one by 1,
    /// then we ensure that timestamp has increased.
    /// @dev If the currently stored number is 0, we assume that it is the first upgrade transaction
    /// and so we will fill up the old data.
    /// @param _l2BlockNumber The number of the new L2 block.
    /// @param _l2BlockTimestamp The timestamp of the new L2 block.
    /// @param _expectedPrevL2BlockHash The expected hash of the previous L2 block.
    /// @param _isFirstInBatch Whether this method is called for the first time in the batch.
    function setL2Block(
        uint128 _l2BlockNumber,
        uint128 _l2BlockTimestamp,
        bytes32 _expectedPrevL2BlockHash,
        bool _isFirstInBatch
    ) external onlyBootloader {
        // We check that the timestamp of the L2 block is consistent with the timestamp of the batch.
        if (_isFirstInBatch) {
            uint128 currentBatchTimestamp = currentBatchInfo.timestamp;
            require(
                _l2BlockTimestamp >= currentBatchTimestamp,
                "The timestamp of the L2 block must be greater than or equal to the timestamp of the current batch"
            );
        }

        (uint128 currentL2BlockNumber, uint128 currentL2BlockTimestamp) = getL2BlockNumberAndTimestamp();

        if (currentL2BlockNumber == 0 && currentL2BlockTimestamp == 0) {
            // We need to perform an upgrade
            _upgradeL2Blocks(_l2BlockNumber, _expectedPrevL2BlockHash, _isFirstInBatch);

            _setNewL2BlockData(_l2BlockNumber, _l2BlockTimestamp, _expectedPrevL2BlockHash);
        } else if (currentL2BlockNumber == _l2BlockNumber) {
            require(!_isFirstInBatch, "Can not reuse L2 block number from the previous batch");
            require(currentL2BlockTimestamp == _l2BlockTimestamp, "The timestamp of the same L2 block must be same");
            require(
                _expectedPrevL2BlockHash == l2BlockHash[_l2BlockNumber - 1],
                "The previous hash of the same L2 block must be same"
            );
        } else if (currentL2BlockNumber + 1 == _l2BlockNumber) {
            // From the checks in _upgradeL2Blocks it is known that currentL2BlockNumber can not be 0
            bytes32 prevL2BlockHash = l2BlockHash[currentL2BlockNumber - 1];

            bytes32 pendingL2BlockHash = _calculateL2BlockHash(
                currentL2BlockNumber, currentL2BlockTimestamp, prevL2BlockHash, currentL2BlockTxsRollingHash
            );

            require(_expectedPrevL2BlockHash == pendingL2BlockHash, "The current L2 block hash is incorrect");
            require(
                _l2BlockTimestamp > currentL2BlockTimestamp,
                "The timestamp of the new L2 block must be greater than the timestamp of the previous L2 block"
            );

            // Since the new block is created, we'll clear out the rolling hash
            _setNewL2BlockData(_l2BlockNumber, _l2BlockTimestamp, _expectedPrevL2BlockHash);
        } else {
            revert("Invalid new L2 block number");
        }
    }

    /// @notice Publishes L2->L1 logs needed to verify the validity of this batch on L1.
    /// @dev Should be called at the end of the current batch.
    function publishBatchDataToL1() external onlyBootloader {
        (uint128 currentBatchNumber, uint128 currentBatchTimestamp) = getBatchNumberAndTimestamp();
        (, uint128 currentL2BlockTimestamp) = getL2BlockNumberAndTimestamp();

        // The structure of the "setNewBatch" implies that currentBatchNumber > 0, but we still double check it
        require(currentBatchNumber > 0, "The current batch number must be greater than 0");
        bytes32 prevBatchHash = batchHash[currentBatchNumber - 1];

        // In order to spend less pubdata, the packed version is published
        uint256 packedTimestamps = (uint256(currentBatchTimestamp) << 128) | currentL2BlockTimestamp;

        SystemContractHelper.toL1(false, bytes32(packedTimestamps), prevBatchHash);
    }

    /// @notice Appends the transaction hash to the rolling hash of the current L2 block.
    /// @param _txHash The hash of the transaction.
    function appendTransactionToCurrentL2Block(bytes32 _txHash) external onlyBootloader {
        currentL2BlockTxsRollingHash = keccak256(abi.encode(currentL2BlockTxsRollingHash, _txHash));
    }

    /// @notice Ensures that the timestamp of the batch is greater than the timestamp of the last L2 block.
    /// @param _newTimestamp The timestamp of the new batch.
    function _ensureBatchConsistentWithL2Block(uint128 _newTimestamp) internal view {
        uint128 currentBlockTimestamp = currentL2BlockInfo.timestamp;
        require(
            _newTimestamp >= currentBlockTimestamp,
            "The timestamp of the batch must be greater than the timestamp of the previous block"
        );
    }

    /// @notice Increments the current block number and sets the new timestamp
    /// @dev Called by the bootloader at the start of the block.
    /// @param _prevBatchHash The hash of the previous block.
    /// @param _newTimestamp The timestamp of the new block.
    /// @param _expectedNewNumber The new block's number
    /// @dev Whie _expectedNewNumber can be derived as prevBlockNumber + 1, we still
    /// manually supply it here for consistency checks.
    /// @dev The correctness of the _prevBatchHash and _newTimestamp should be enforced on L1.
    function setNewBatch(bytes32 _prevBatchHash, uint128 _newTimestamp, uint128 _expectedNewNumber, uint256 _baseFee)
        external
        onlyBootloader
    {
        (uint128 currentBatchNumber, uint128 currentBatchTimestamp) = getBatchNumberAndTimestamp();
        require(_newTimestamp > currentBatchTimestamp, "Timestamps should be incremental");
        require(currentBatchNumber + 1 == _expectedNewNumber, "The provided block number is not correct");

        _ensureBatchConsistentWithL2Block(_newTimestamp);

        batchHash[currentBatchNumber] = _prevBatchHash;

        // Setting new block number and timestamp
        BlockInfo memory newBlockInfo = BlockInfo({number: currentBatchNumber + 1, timestamp: _newTimestamp});

        currentBatchInfo = newBlockInfo;

        baseFee = _baseFee;
    }

    /// @notice A testing method that manually sets the current blocks' number and timestamp.
    /// @dev Should be used only for testing / ethCalls and should never be used in production.
    function unsafeOverrideBatch(uint256 _newTimestamp, uint256 _number, uint256 _baseFee) external onlyBootloader {
        BlockInfo memory newBlockInfo = BlockInfo({number: uint128(_number + 1), timestamp: uint128(_newTimestamp)});
        currentBatchInfo = newBlockInfo;

        baseFee = _baseFee;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPRECATED METHODS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the current batch's number and timestamp.
    /// @dev Deprecated in favor of getBatchNumberAndTimestamp.
    function currentBlockInfo() external view returns (uint256 blockInfo) {
        (uint128 blockNumber, uint128 blockTimestamp) = getBatchNumberAndTimestamp();
        blockInfo = uint256(blockNumber) << 128 | uint256(blockTimestamp);
    }

    /// @notice Returns the current batch's number and timestamp.
    /// @dev Deprecated in favor of getBatchNumberAndTimestamp.
    function getBlockNumberAndTimestamp() external view returns (uint256 blockNumber, uint256 blockTimestamp) {
        (blockNumber, blockTimestamp) = getBatchNumberAndTimestamp();
    }

    /// @notice Returns the hash of the given batch.
    /// @dev Deprecated in favor of getBatchHash.
    function blockHash(uint256 _blockNumber) external view returns (bytes32 hash) {
        hash = batchHash[_blockNumber];
    }
}
