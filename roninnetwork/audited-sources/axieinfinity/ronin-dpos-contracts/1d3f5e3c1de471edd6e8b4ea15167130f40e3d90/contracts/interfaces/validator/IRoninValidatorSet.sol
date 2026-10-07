// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./ICandidateManager.sol";

import "./ICoinbaseExecution.sol";

import "./IEmergencyExit.sol";
import "./ISlashingExecution.sol";
import "./info-fragments/ICommonInfo.sol";

interface IRoninValidatorSet is
    ICandidateManager,
    ICommonInfo,
    ISlashingExecution,
    ICoinbaseExecution,
    IEmergencyExit
{}
