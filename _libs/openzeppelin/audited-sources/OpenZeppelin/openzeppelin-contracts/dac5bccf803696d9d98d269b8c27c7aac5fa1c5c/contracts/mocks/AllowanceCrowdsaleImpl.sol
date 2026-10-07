pragma solidity ^0.4.24;

import "../crowdsale/emission/AllowanceCrowdsale.sol";
import "../token/ERC20/IERC20.sol";

contract AllowanceCrowdsaleImpl is AllowanceCrowdsale {
    constructor(uint256 rate, address wallet, IERC20 token, address tokenWallet)
        public
        Crowdsale(rate, wallet, token)
        AllowanceCrowdsale(tokenWallet)
    {}
}
