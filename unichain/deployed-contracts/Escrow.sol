// SPDX-License-Identifier: Unknown
pragma solidity 0.8.21;

contract Escrow {
    // --- storage variables ---

    mapping(address => uint256) public wards;

    // --- events ---

    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Approve(address indexed token, address indexed spender, uint256 value);

    // --- modifiers ---

    modifier auth() {
        require(wards[msg.sender] == 1, "Escrow/not-authorized");
        _;
    }

    // --- constructor ---

    constructor() {
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    // --- administration ---

    function rely(address usr) external auth {
        wards[usr] = 1;
        emit Rely(usr);
    }

    function deny(address usr) external auth {
        wards[usr] = 0;
        emit Deny(usr);
    }

    // --- approve ---

    function approve(address token, address spender, uint256 value) external auth {
        GemLike(token).approve(spender, value);
        emit Approve(token, spender, value);
    }
}
