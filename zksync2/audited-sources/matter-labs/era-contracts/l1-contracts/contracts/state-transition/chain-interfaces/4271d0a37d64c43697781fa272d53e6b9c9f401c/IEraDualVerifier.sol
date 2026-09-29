// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {IVerifier} from "./IVerifier.sol";
import {IVerifierV2} from "./IVerifierV2.sol";

/// @notice Interface for EraDualVerifier sub-verifier getters
interface IEraDualVerifier {
    function FFLONK_VERIFIER() external view returns (IVerifierV2);
    function PLONK_VERIFIER() external view returns (IVerifier);
}
