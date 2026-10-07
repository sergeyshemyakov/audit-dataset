// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IAdmin} from "./IAdmin.sol";
import {IExecutor} from "./IExecutor.sol";
import {IGetters} from "./IGetters.sol";
import {IMailbox} from "./IMailbox.sol";

interface IZkSync is IMailbox, IAdmin, IExecutor, IGetters {}
