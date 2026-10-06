// SPDX-License-Identifier: OWNED BY ConsenSys Software Inc.
pragma solidity ^0.8.19;

import "./ZkEvmV2.sol";

/**
 * @title Contract to reinitialize cross-chain messaging on L1 and rollup proving.
 * @author ConsenSys Software Inc.
 */
contract ZkEvmV202 is ZkEvmV2 {
    /*
    * @notice Reinitializes zkEvm and underlying service dependencies.
    * @param _initialStateRootHash The initial hash at migration used for proof verification.
    * @param _initialL2BlockNumber The initial block number at migration.
    **/
    function initializeV2(uint256 _initialL2BlockNumber, bytes32 _initialStateRootHash) public reinitializer(2) {
        currentL2BlockNumber = _initialL2BlockNumber;
        stateRootHashes[_initialL2BlockNumber] = _initialStateRootHash;
    }
}
