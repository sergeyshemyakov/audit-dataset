// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8;

import "./IDiamondCut.sol";
import "./IExecutor.sol";
import "./IGetters.sol";
import "./IGovernance.sol";
import "./IMailbox.sol";

interface IZkSync is IMailbox, IGovernance, IExecutor, IDiamondCut, IGetters {}
