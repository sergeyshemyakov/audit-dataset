// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IVerifier {
    function verifyProof(bytes calldata proof, uint256[4] calldata input) external view returns (bool);

    function verifyProof(bytes calldata proof, uint256[8] calldata input) external view returns (bool);

    function verifyProof(bytes calldata proof, uint256[12] calldata input) external view returns (bool);
}
