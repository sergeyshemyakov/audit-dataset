// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {LegacyMessagePasser} from "../legacy/LegacyMessagePasser.sol";
import {Predeploys} from "../libraries/Predeploys.sol";
import {CommonTest} from "./CommonTest.t.sol";

contract LegacyMessagePasser_Test is CommonTest {
    LegacyMessagePasser messagePasser;

    function setUp() public virtual override {
        super.setUp();
        messagePasser = new LegacyMessagePasser();
    }

    function test_passMessageToL1_succeeds() external {
        vm.prank(alice);
        messagePasser.passMessageToL1(hex"ff");
        assert(messagePasser.sentMessages(keccak256(abi.encodePacked(hex"ff", alice))));
    }
}
