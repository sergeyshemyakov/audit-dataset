// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./MerkleTreeWithHistory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnableMerkleTree is Ownable, MerkleTreeWithHistory {
    constructor(uint32 _treeLevels, IHasher _hasher) public MerkleTreeWithHistory(_treeLevels, _hasher) {}

    function insert(bytes32 leaf) external onlyOwner returns (uint32 index) {
        return _insert(leaf);
    }

    function bulkInsert(bytes32[] calldata leaves) external onlyOwner {
        _bulkInsert(leaves);
    }
}
