// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IDiamondCut.sol";
import "./IExecutor.sol";
import "./IGetters.sol";
import "./IGovernance.sol";
import "./IMailbox.sol";

interface IZkSync is IMailbox, IGovernance, IExecutor, IDiamondCut, IGetters {}
