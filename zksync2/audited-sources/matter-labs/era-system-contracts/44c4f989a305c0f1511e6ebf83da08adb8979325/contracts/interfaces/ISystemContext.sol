// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @author Matter Labs
 * @notice Contract that stores some of the context variables, that may be either
 * block-scoped, tx-scoped or system-wide.
 */
interface ISystemContext {
    struct BlockInfo {
        uint128 timestamp;
        uint128 number;
    }

    function chainId() external view returns (uint256);

    function origin() external view returns (address);

    function gasPrice() external view returns (uint256);

    function blockGasLimit() external view returns (uint256);

    function coinbase() external view returns (address);

    function difficulty() external view returns (uint256);

    function baseFee() external view returns (uint256);

    function getBlockHashEVM(uint256 _block) external view returns (bytes32);

    function getBatchHash(uint256 _batchNumber) external view returns (bytes32 hash);

    function getBlockNumber() external view returns (uint128);

    function getBlockTimestamp() external view returns (uint128);

    function getBatchNumberAndTimestamp() external view returns (uint128 blockNumber, uint128 blockTimestamp);

    function getL2BlockNumberAndTimestamp() external view returns (uint128 blockNumber, uint128 blockTimestamp);
}
