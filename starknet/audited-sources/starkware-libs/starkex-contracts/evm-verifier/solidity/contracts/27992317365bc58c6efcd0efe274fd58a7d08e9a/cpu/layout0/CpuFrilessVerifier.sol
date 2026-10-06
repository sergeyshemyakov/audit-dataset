pragma solidity ^0.5.2;

import "../../MerkleStatementVerifier.sol";
import "./CpuVerifier.sol";
import "./FriStatementVerifier.sol";

contract CpuFrilessVerifier is CpuVerifier, MerkleStatementVerifier, FriStatementVerifier {
    constructor(
        address[] memory auxPolynomials,
        address oodsContract,
        address memoryPageFactRegistry_,
        address merkleStatementContractAddress,
        address friStatementContractAddress,
        uint256 numSecurityBits_,
        uint256 minProofOfWorkBits_
    )
        public
        MerkleStatementVerifier(merkleStatementContractAddress)
        FriStatementVerifier(friStatementContractAddress)
        CpuVerifier(auxPolynomials, oodsContract, memoryPageFactRegistry_, numSecurityBits_, minProofOfWorkBits_)
    {
        // solium-disable-previous-line no-empty-blocks
    }
}
