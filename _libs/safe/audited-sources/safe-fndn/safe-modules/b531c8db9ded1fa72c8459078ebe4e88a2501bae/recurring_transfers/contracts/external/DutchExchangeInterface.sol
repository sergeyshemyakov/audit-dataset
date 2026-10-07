pragma solidity ^0.5.0;

interface DutchExchange {
    function getPriceOfTokenInLastAuction(address token) external view returns (uint256 num, uint256 den);

    function getPriceInPastAuction(address token1, address token2, uint256 auctionIndex)
        external
        view
        returns (uint256 num, uint256 den);

    function getAuctionIndex(address token1, address token2) external view returns (uint256 index);
}
