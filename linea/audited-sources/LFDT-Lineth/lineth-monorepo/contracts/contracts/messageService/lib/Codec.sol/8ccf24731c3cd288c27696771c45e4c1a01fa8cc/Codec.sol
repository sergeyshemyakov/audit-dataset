// SPDX-License-Identifier: OWNED BY ConsenSys Software Inc.
pragma solidity ^0.8.19;

/**
 * @title Decoding functions for message service anchoring and bytes slicing.
 * @author ConsenSys Software Inc.
 * @notice You can use this to slice bytes and extract anchoring hashes from calldata.
 *
 */
library CodecV2 {
    /**
     * @notice Decodes a collection of bytes32 (hashes) from the calldata of a transaction.
     * @dev Extracts and decodes skipping the function selector (selector is expected in the input).
     * @dev A check beforehand must be performed to confirm this is the correct type of transaction.
     * @param _calldataWithSelector The calldata for the transaction.
     * @return bytes32[] - array of message hashes.
     *
     */
    function _extractXDomainAddHashes(bytes memory _calldataWithSelector) internal pure returns (bytes32[] memory) {
        return abi.decode(_slice(_calldataWithSelector, 4, _calldataWithSelector.length - 4), (bytes32[]));
    }

    // Returns a slice of bytes. Taken from:
    // https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol
    function _slice(bytes memory _bytes, uint256 _start, uint256 _length)
        internal
        pure
        returns (bytes memory tempBytes)
    {
        if (_bytes.length < 4) {
            revert();
        }

        if (_bytes.length < _start + _length) {
            revert();
        }

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary.
                // because when slicing multiples of 32 bytes (lengthmod == 0).
                // the following copy loop was copying the origin's length.
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose.
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } { mstore(mc, mload(cc)) }

                mstore(tempBytes, _length)

                //update free-memory pointer.
                //allocating the array padded to 32 bytes like the compiler does now.
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array.
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return.
                //we need to do it because Solidity does not garbage collect.
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }
    }
}
