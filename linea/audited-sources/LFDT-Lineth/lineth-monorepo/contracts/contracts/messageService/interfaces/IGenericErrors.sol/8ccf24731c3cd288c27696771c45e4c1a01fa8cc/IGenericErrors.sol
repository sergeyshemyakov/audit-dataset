// SPDX-License-Identifier: OWNED BY ConsenSys Software Inc.
pragma solidity ^0.8.19;

interface IGenericErrors {
    /**
     * @dev Thrown when a parameter is the zero address.
     */
    error ZeroAddressNotAllowed();
}
