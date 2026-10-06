// SPDX-License-Identifier: OWNED BY ConsenSys Software Inc.
pragma solidity ^0.8.19;

interface IZkEvmV2 {
    struct BlockData {
        bytes32 blockRootHash;
        uint32 l2BlockTimestamp;
        bytes[] transactions;
        bytes[] l2l1logs;
        uint16[] batchReceptionIndices;
    }

    /**
     * @dev Emitted when a L2 block has been finalized on L1
     */
    event BlockFinalized(uint256 indexed blockNumber, bytes32 stateRootHash);
    /**
     * @dev Emitted when a L2 blocks have been finalized on L1
     */
    event BlocksVerificationDone(uint256 indexed lastBlockFinalized, bytes32 startingRootHash, bytes32 finalRootHash);

    /**
     * @dev Thrown when l2 block timestamp is not correct
     */
    error BlockTimestampError();

    /**
     * @dev Thrown when the starting rootHash does not match the existing state
     */
    error StartingRootHashDoesNotMatch();

    /**
     * @dev Thrown when block contains zero transactions
     */
    error EmptyBlock();

    /**
     * @dev Thrown when zk proof is empty bytes
     */
    error ProofIsEmpty();

    /**
     * @dev Thrown when zk proof type is invalid
     */
    error InvalidProofType();

    /**
     * @dev Thrown when zk proof is invalid
     */
    error InvalidProof();

    /**
     * @notice Adds or updated the verifier contract address for a proof type
     * @dev DEFAULT_ADMIN_ROLE is required to execute
     * @param _newVerifierAddress The address for the verifier contract
     * @param _proofType The proof type being set/updated
     *
     */
    function setVerifierAddress(address _newVerifierAddress, uint256 _proofType) external;

    /**
     * @notice Finalizes blocks without using a proof
     * @dev DEFAULT_ADMIN_ROLE is required to execute
     * @param _calldata The full BlockData collection - block, transaction and log data
     *
     */
    function finalizeBlocksWithoutProof(BlockData[] calldata _calldata) external;

    /**
     * @notice Finalizes blocks without using a proof
     * @dev OPERATOR_ROLE is required to execute
     * @dev If the verifier based on proof type is not found, it defaults to the default verifier type
     * @param _calldata The full BlockData collection - block, transaction and log data
     * @param _proof The proof to verified with the proof type verifier contract
     * @param _proofType The proof type to determine which verifier contract to use
     * @param _parentStateRootHash The beginning roothash to start with
     *
     */
    function finalizeBlocks(
        BlockData[] calldata _calldata,
        bytes calldata _proof,
        uint256 _proofType,
        bytes32 _parentStateRootHash
    ) external;
}
