pragma solidity ^0.4.24;

import "../drafts/SignatureBouncer.sol";
import "./SignerRoleMock.sol";

contract SignatureBouncerMock is SignatureBouncer, SignerRoleMock {
    function checkValidSignature(address account, bytes signature) public view returns (bool) {
        return _isValidSignature(account, signature);
    }

    function onlyWithValidSignature(bytes signature) public view onlyValidSignature(signature) {}

    function checkValidSignatureAndMethod(address account, bytes signature) public view returns (bool) {
        return _isValidSignatureAndMethod(account, signature);
    }

    function onlyWithValidSignatureAndMethod(bytes signature) public view onlyValidSignatureAndMethod(signature) {}

    function checkValidSignatureAndData(address account, bytes, uint256, bytes signature) public view returns (bool) {
        return _isValidSignatureAndData(account, signature);
    }

    function onlyWithValidSignatureAndData(uint256, bytes signature) public view onlyValidSignatureAndData(signature) {}

    function theWrongMethod(bytes) public pure {}

    function tooShortMsgData() public view onlyValidSignatureAndData("") {}
}
