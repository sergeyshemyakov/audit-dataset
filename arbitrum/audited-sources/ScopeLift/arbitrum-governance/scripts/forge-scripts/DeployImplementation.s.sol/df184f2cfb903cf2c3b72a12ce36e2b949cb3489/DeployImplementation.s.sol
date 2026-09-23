// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.16;

import {Script} from "forge-std/Script.sol";
import {L2ArbitrumGovernorV2} from "src/L2ArbitrumGovernorV2.sol";

/// @notice Deploy script for the underlying implementation that will be used by both Governor proxies
contract DeployImplementation is Script {
    function run() public returns (L2ArbitrumGovernorV2 _implementation) {
        vm.startBroadcast();
        _implementation = new L2ArbitrumGovernorV2();
        vm.stopBroadcast();
    }
}
