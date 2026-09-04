// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGateway {
  function withdrawTokenFor(
    uint256 _withdrawalId,
    address _user,
    address _token,
    uint256 _amount,
    bytes memory _signatures
  ) external;
}

interface IGatewayV2 {
  function receiveEther() external payable;
}

interface IPausableAdmin {
  function pauseGateway() external;

  function unpauseGateway() external;

  function changeAdmin(address _newAdmin) external;
}

contract BridgeMigration is Ownable {
  IGateway public gateway;
  IPausableAdmin public pausableAdmin;
  address public weth;

  constructor(
    IGateway _gateway,
    IPausableAdmin _pausableAdmin,
    address _weth
  ) {
    gateway = _gateway;
    pausableAdmin = _pausableAdmin;
    weth = _weth;
  }

  fallback() external payable {}

  receive() external payable {}

  function pauseGateway() external onlyOwner {
    pausableAdmin.pauseGateway();
  }

  function unpauseGateway() external onlyOwner {
    pausableAdmin.unpauseGateway();
  }

  function changePausableAdmin(address _newAdmin) external onlyOwner {
    pausableAdmin.changeAdmin(_newAdmin);
  }

  function migrateAndTransfer(
    uint256[] calldata _withdrawalIds,
    address[] calldata _tokens,
    uint256[] calldata _amounts,
    bytes[] calldata _signatures,
    IGatewayV2 _gatewayV2
  ) external onlyOwner {
    require(
      _withdrawalIds.length > 0 &&
        _withdrawalIds.length == _tokens.length &&
        _withdrawalIds.length == _amounts.length &&
        _withdrawalIds.length == _signatures.length,
      "BridgeMigration: invalid array length"
    );

    pausableAdmin.pauseGateway();
    for (uint256 _i; _i < _withdrawalIds.length; _i++) {
      gateway.withdrawTokenFor(_withdrawalIds[_i], address(this), _tokens[_i], _amounts[_i], _signatures[_i]);
    }
    pausableAdmin.unpauseGateway();

    for (uint256 _i; _i < _tokens.length; _i++) {
      if (_tokens[_i] == weth) {
        _gatewayV2.receiveEther{ value: _amounts[_i] }();
      } else {
        IERC20(_tokens[_i]).transfer(address(_gatewayV2), _amounts[_i]);
      }
    }
  }
}
