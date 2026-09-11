//SPDX-License-Identifier: GPL
pragma solidity ^0.8.7;

/* solhint-disable no-inline-assembly */

import "../interfaces/IAccount.sol";
import "./EIP4337Manager.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/handler/DefaultCallbackHandler.sol";

contract EIP4337Fallback is DefaultCallbackHandler, IAccount {
    address public immutable eip4337manager;

    constructor(address _eip4337manager) {
        eip4337manager = _eip4337manager;
    }

    /**
     * handler is called from the Safe. delegate actual work to EIP4337Manager
     */
    function validateUserOp(UserOperation calldata, bytes32, address, uint256)
        external
        override
        returns (uint256 sigTimeRange)
    {
        //delegate entire msg.data (including the appended "msg.sender") to the EIP4337Manager
        // will work only for GnosisSafe contracts
        GnosisSafe safe = GnosisSafe(payable(msg.sender));
        (bool success, bytes memory ret) =
            safe.execTransactionFromModuleReturnData(eip4337manager, 0, msg.data, Enum.Operation.DelegateCall);
        if (!success) {
            assembly {
                revert(add(ret, 32), mload(ret))
            }
        }
        return 0;
    }
}
