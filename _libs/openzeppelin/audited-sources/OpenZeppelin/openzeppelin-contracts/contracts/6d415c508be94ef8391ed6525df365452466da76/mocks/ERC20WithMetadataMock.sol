pragma solidity ^0.4.24;

import "../drafts/ERC1046/TokenMetadata.sol";
import "../token/ERC20/ERC20.sol";

contract ERC20WithMetadataMock is ERC20, ERC20WithMetadata {
    constructor(string tokenURI) public ERC20WithMetadata(tokenURI) {}
}
