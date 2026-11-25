// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    event Transfer(address indexed src, address indexed dst, uint256 wad);

    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function approve(address guy, uint256 wad) external returns (bool);

    function transferFrom(address src, address dst, uint256 wad) external returns (bool);

    function withdraw(uint256 _wad) external;

    function balanceOf(address) external view returns (uint256);
}
