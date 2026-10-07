// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import {ETH_TOKEN_SYSTEM_CONTRACT, MSG_VALUE_SIMULATOR_IS_SYSTEM_BIT} from "./Constants.sol";
import {ISystemContract, SystemContractHelper} from "./libraries/SystemContractHelper.sol";

/**
 * @author Matter Labs
 * @notice The contract responsible for simulating transactions with `msg.value` inside zkEVM.
 * @dev It accepts value and whether the call should be system in the first extraAbi param and
 * the address to call in the second extraAbi param, transfers the funds and uses `mimicCall` to continue the
 * call with the same msg.sender.
 */
contract MsgValueSimulator is ISystemContract {
    /// @notice Extract value, isSystemCall and to from the extraAbi params.
    /// @dev The contract accepts value, the callee and whether the call should a system one via its ABI params.
    /// @dev The first ABI param contains the value in the [0..127] bits. The 128th contains
    /// the flag whether or not the call should be a system one.
    /// The second ABI params contains the callee.
    function _getAbiParams() internal view returns (uint128 value, bool isSystemCall, address to) {
        uint256 valueAndIsSystem = SystemContractHelper.getExtraAbiData1();

        value = uint128(valueAndIsSystem & (MSG_VALUE_SIMULATOR_IS_SYSTEM_BIT - 1));
        isSystemCall = (valueAndIsSystem & (MSG_VALUE_SIMULATOR_IS_SYSTEM_BIT) != 0);

        uint256 addressAsUint = SystemContractHelper.getExtraAbiData2();

        to = address(uint160(addressAsUint));
    }

    fallback(bytes calldata _data) external payable onlySystemCall returns (bytes memory) {
        (uint128 value, bool isSystemCall, address to) = _getAbiParams();

        if (value != 0) {
            ETH_TOKEN_SYSTEM_CONTRACT.transferFromTo(msg.sender, to, value);
        }

        // For the next call this `msg.value` will be used.
        SystemContractHelper.setValueForNextFarCall(value);

        return SystemContractHelper.mimicCall(to, msg.sender, _data, false, isSystemCall);
    }
}
