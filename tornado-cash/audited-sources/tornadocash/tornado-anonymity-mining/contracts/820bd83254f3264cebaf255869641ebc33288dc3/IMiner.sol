// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IMiner {
    function uploadDeposits(bytes32[] calldata _deposits) external;

    function uploadWithdrawals(bytes32[] calldata _withdrawals) external;
}
