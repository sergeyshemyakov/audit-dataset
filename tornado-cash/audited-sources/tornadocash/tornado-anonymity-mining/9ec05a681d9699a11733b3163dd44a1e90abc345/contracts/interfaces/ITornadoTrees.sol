// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ITornadoTrees {
    function registerNewDeposit(address instanse, bytes32 commitment) external;

    function registerNewWithdrawal(address instanse, bytes32 nullifier) external;
}
