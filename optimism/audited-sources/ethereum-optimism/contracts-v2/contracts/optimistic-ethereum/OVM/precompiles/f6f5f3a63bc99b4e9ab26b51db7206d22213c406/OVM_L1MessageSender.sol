// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/* Interface Imports */

import {iOVM_ExecutionManager} from "../../iOVM/execution/iOVM_ExecutionManager.sol";
import {iOVM_L1MessageSender} from "../../iOVM/precompiles/iOVM_L1MessageSender.sol";

/**
 * @title OVM_L1MessageSender
 * @dev L2 CONTRACT (NOT COMPILED)
 */
contract OVM_L1MessageSender is iOVM_L1MessageSender {
    /**
     *
     * Public Functions *
     *
     */

    /**
     * @return _l1MessageSender L1 message sender address (msg.sender).
     */
    function getL1MessageSender() public view override returns (address _l1MessageSender) {
        return iOVM_ExecutionManager(msg.sender).ovmL1TXORIGIN();
    }
}
