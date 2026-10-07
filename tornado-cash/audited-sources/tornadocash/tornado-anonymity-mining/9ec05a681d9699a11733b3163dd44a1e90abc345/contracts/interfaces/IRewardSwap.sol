// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IRewardSwap {
    // prettier-ignore
    function swap(address recipient, uint256 amount) external;

    function setPoolWeight(uint256 newWeight) external;
}
