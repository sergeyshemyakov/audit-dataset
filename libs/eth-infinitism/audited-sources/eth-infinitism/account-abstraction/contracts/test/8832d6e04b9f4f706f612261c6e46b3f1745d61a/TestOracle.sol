// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "../samples/DepositPaymaster.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestOracle is IOracle {
    function getTokenToEthOutputPrice(uint256 ethOutput) external pure override returns (uint256 tokenInput) {
        return ethOutput * 2;
    }
}
