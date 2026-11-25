// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./ICreditScore.sol";
import "./ISlashBridgeOperator.sol";
import "./ISlashBridgeVoting.sol";
import "./ISlashDoubleSign.sol";

import "./ISlashUnavailability.sol";

interface ISlashIndicator is
    ISlashDoubleSign,
    ISlashBridgeVoting,
    ISlashBridgeOperator,
    ISlashUnavailability,
    ICreditScore
{}
