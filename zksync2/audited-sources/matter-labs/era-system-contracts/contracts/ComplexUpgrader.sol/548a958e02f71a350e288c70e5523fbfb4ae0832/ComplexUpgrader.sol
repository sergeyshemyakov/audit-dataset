// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {FORCE_DEPLOYER} from "./Constants.sol";

/**
 * @author Matter Labs
 * @notice Upgrader which should be used to perform complex multistep upgrades on L2. In case some custom logic for an upgrade is needed
 * this logic should be deployed into the user space and then this contract will delegatecall to the deployed contract.
 */
contract ComplexUpgrader {
    function upgrade(address _delegateTo, bytes calldata _calldata) external payable {
        require(msg.sender == FORCE_DEPLOYER, "Can only be called by FORCE_DEPLOYER");

        (bool success, bytes memory returnData) = _delegateTo.delegatecall(_calldata);
        assembly {
            if iszero(success) { revert(add(returnData, 0x20), mload(returnData)) }
        }
    }
}
