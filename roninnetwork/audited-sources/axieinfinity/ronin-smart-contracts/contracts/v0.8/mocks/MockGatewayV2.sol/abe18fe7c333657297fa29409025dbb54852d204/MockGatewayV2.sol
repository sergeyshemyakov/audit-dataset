// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../extensions/GatewayV2.sol";

contract MockGatewayV2 is GatewayV2, Initializable {
  /**
   * @dev Initializes contract storage.
   */
  function initialize(
    uint256 _numerator,
    uint256 _denominator,
    IWeightedValidator _validatorContract
  ) external initializer {
    _setThreshold(_numerator, _denominator);
    _setValidatorContract(_validatorContract);
  }
}
