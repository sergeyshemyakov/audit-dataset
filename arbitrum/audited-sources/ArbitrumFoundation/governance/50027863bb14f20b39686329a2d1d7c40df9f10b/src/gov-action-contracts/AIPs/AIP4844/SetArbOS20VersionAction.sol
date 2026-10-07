// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.16;

import "../../address-registries/L1AddressRegistry.sol";
import "../../arbos-upgrade/UpgradeArbOSVersionAction.sol";

/// @notice Sets the ArbOS version to 20. To be run on an arbitrum chain
/// @dev    Identical copies of this contract to be deployed on Arb One and Nova for ArbOS20 upgrades
contract SetArbOS20VersionAction is UpgradeArbOSVersionAction {
    constructor() UpgradeArbOSVersionAction(uint64(20), uint64(3 days)) {}
}
