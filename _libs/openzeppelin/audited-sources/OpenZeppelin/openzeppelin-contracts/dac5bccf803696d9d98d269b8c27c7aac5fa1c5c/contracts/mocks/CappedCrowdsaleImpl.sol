pragma solidity ^0.4.24;

import "../crowdsale/validation/CappedCrowdsale.sol";
import "../token/ERC20/IERC20.sol";

contract CappedCrowdsaleImpl is CappedCrowdsale {
    constructor(uint256 rate, address wallet, IERC20 token, uint256 cap)
        public
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(cap)
    {}
}
