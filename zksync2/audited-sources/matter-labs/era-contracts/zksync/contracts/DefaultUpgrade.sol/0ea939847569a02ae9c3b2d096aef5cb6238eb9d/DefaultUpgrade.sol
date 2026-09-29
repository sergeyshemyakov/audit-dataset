// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import {DEPLOYER_SYSTEM_CONTRACT, IContractDeployer} from "./L2ContractHelper.sol";

/// @notice The default contract to be used as an implementation of the ComplexUpgrader.
contract DefaultUpgrade {
    /// @notice A function that performs force deploy
    /// @param _forceDeployments The force deployments to perform.
    function forceDeploy(IContractDeployer.ForceDeployment[] calldata _forceDeployments) external {
        IContractDeployer(DEPLOYER_SYSTEM_CONTRACT).forceDeployOnAddresses(_forceDeployments);
    }
}
