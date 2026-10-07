// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./IAdmin.sol";
import "./IExecutor.sol";
import "./IGetters.sol";
import "./IMailbox.sol";

interface IZkSync is IMailbox, IAdmin, IExecutor, IGetters {}
