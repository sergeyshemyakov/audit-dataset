// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Migration} from "../Migration.s.sol";
import {ISharedArgument} from "../interfaces/ISharedArgument.sol";
import {Contract} from "../utils/Contract.sol";
import {MainchainGatewayV3} from "@ronin/contracts/mainchain/MainchainGatewayV3.sol";

contract MainchainGatewayV3Deploy is Migration {
    function run() public virtual returns (MainchainGatewayV3) {
        return MainchainGatewayV3(_deployProxy(Contract.MainchainGatewayV3.key(), EMPTY_ARGS));
    }
}
