// SPDX-License-Identifier: Unknown
pragma solidity 0.8.30;

interface IERC5267 {
    /**
     * @dev MAY be emitted to signal that the domain could have changed.
     */
    event EIP712DomainChanged();

    /**
     * @dev returns the fields and values that describe the domain separator used by this contract for EIP-712
     * signature.
     */
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}

// | string  | 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA   |
// | length  | 0x                                                              BB |
type ShortString is bytes32;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}

/**
 * @dev This library provides functions to convert short memory strings
 * into a `ShortString` type that can be used as an immutable variable.
 *
 * Strings of arbitrary length can be optimized using this library if
 * they are short enough (up to 31 bytes) by packing them with their
 * length (1 byte) in a single EVM word (32 bytes). Additionally, a
 * fallback mechanism can be used for every other case.
 *
 * Usage example:
 *
 * ```solidity
 * contract Named {
 *     using ShortStrings for *;
 *
 *     ShortString private immutable _name;
 *     string private _nameFallback;
 *
 *     constructor(string memory contractName) {
 *         _name = contractName.toShortStringWithFallback(_nameFallback);
 *     }
 *
 *     function name() external view returns (string memory) {
 *         return _name.toStringWithFallback(_nameFallback);
 *     }
 * }
 * ```
 */
library ShortStrings {
    // Used as an identifier for strings longer than 31 bytes.
    bytes32 private constant FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;

    error StringTooLong(string str);
    error InvalidShortString();

    /**
     * @dev Encode a string of at most 31 chars into a `ShortString`.
     *
     * This will trigger a `StringTooLong` error is the input string is too long.
     */
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }

    /**
     * @dev Decode a `ShortString` back to a "normal" string.
     */
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        // using `new string(len)` would work locally but is not memory safe.
        string memory str = new string(32);
        assembly ("memory-safe") {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }

    /**
     * @dev Return the length of a `ShortString`.
     */
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }

    /**
     * @dev Encode a string into a `ShortString`, or write it to storage if it is too long.
     */
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(FALLBACK_SENTINEL);
        }
    }

    /**
     * @dev Decode a string that was encoded to `ShortString` or written to storage using {setWithFallback}.
     */
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }

    /**
     * @dev Return the length of a string that was encoded to `ShortString` or written to storage using
     * {setWithFallback}.
     *
     * WARNING: This will return the "byte length" of the string. This may not reflect the actual length in terms of
     * actual characters as the UTF-8 encoding of a single character can span over multiple bytes.
     */
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}

/**
 * @dev Wrappers over Solidity's uintXX/intXX/bool casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeCast {
    /**
     * @dev Value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);

    /**
     * @dev An int value doesn't fit in an uint of `bits` size.
     */
    error SafeCastOverflowedIntToUint(int256 value);

    /**
     * @dev Value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);

    /**
     * @dev An uint value doesn't fit in an int of `bits` size.
     */
    error SafeCastOverflowedUintToInt(uint256 value);

    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }

    /**
     * @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
     */
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly ("memory-safe") {
            u := iszero(iszero(b))
        }
    }
}

/**
 * @dev Helper library for emitting standardized panic codes.
 *
 * ```solidity
 * contract Example {
 *      using Panic for uint256;
 *
 *      // Use any of the declared internal constants
 *      function foo() { Panic.GENERIC.panic(); }
 *
 *      // Alternatively
 *      function foo() { Panic.panic(Panic.GENERIC); }
 * }
 * ```
 *
 * Follows the list from https://github.com/ethereum/solidity/blob/v0.8.24/libsolutil/ErrorCodes.h[libsolutil].
 *
 * _Available since v5.1._
 */
// slither-disable-next-line unused-state
library Panic {
    /// @dev generic / unspecified error
    uint256 internal constant GENERIC = 0x00;
    /// @dev used by the assert() builtin
    uint256 internal constant ASSERT = 0x01;
    /// @dev arithmetic underflow or overflow
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    /// @dev division or modulo by zero
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    /// @dev enum conversion error
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    /// @dev invalid encoding in storage
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    /// @dev empty array pop
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    /// @dev array out of bounds access
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    /// @dev resource error (too large allocation or too large array)
    uint256 internal constant RESOURCE_ERROR = 0x41;
    /// @dev calling invalid internal function
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;

    /// @dev Reverts with a panic code. Recommended to use with
    /// the internal constants with predefined codes.
    function panic(uint256 code) internal pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
    }
}

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * SafeCast.toUint(condition));
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return ternary(a < b, a, b);
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }

        // The following calculation ensures accurate ceiling division without overflow.
        // Since a is non-zero, (a - 1) / b will not overflow.
        // The largest possible result occurs when (a - 1) / b is type(uint256).max,
        // but the largest value we can obtain is type(uint256).max - 1, which happens
        // when a = type(uint256).max and b = 1.
        unchecked {
            return SafeCast.toUint(a > 0) * ((a - 1) / b + 1);
        }
    }

    /**
     * @dev Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     *
     * Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
            // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2²⁵⁶ + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= prod1) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2²⁵⁶. Now that denominator is an odd number, it has an inverse modulo 2²⁵⁶ such
            // that denominator * inv ≡ 1 mod 2²⁵⁶. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv ≡ 1 mod 2⁴.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2¹⁶
            inverse *= 2 - denominator * inverse; // inverse mod 2³²
            inverse *= 2 - denominator * inverse; // inverse mod 2⁶⁴
            inverse *= 2 - denominator * inverse; // inverse mod 2¹²⁸
            inverse *= 2 - denominator * inverse; // inverse mod 2²⁵⁶

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2²⁵⁶. Since the preconditions guarantee that the outcome is
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @dev Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }

    /**
     * @dev Calculate the modular multiplicative inverse of a number in Z/nZ.
     *
     * If n is a prime, then Z/nZ is a field. In that case all elements are inversible, except 0.
     * If n is not a prime, then Z/nZ is not a field, and some elements might not be inversible.
     *
     * If the input value is not inversible, 0 is returned.
     *
     * NOTE: If you know for sure that n is (big) a prime, it may be cheaper to use Fermat's little theorem and get the
     * inverse using `Math.modExp(a, n - 2, n)`. See {invModPrime}.
     */
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            // The inverse modulo is calculated using the Extended Euclidean Algorithm (iterative version)
            // Used to compute integers x and y such that: ax + ny = gcd(a, n).
            // When the gcd is 1, then the inverse of a modulo n exists and it's x.
            // ax + ny = 1
            // ax = 1 + (-y)n
            // ax ≡ 1 (mod n) # x is the inverse of a modulo n

            // If the remainder is 0 the gcd is n right away.
            uint256 remainder = a % n;
            uint256 gcd = n;

            // Therefore the initial coefficients are:
            // ax + ny = gcd(a, n) = n
            // 0a + 1n = n
            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (
                    // The old remainder is the next gcd to try.
                    remainder,
                    // Compute the next remainder.
                    // Can't overflow given that (a % gcd) * (gcd // (a % gcd)) <= gcd
                    // where gcd is at most n (capped to type(uint256).max)
                    gcd - remainder * quotient
                );

                (x, y) = (
                    // Increment the coefficient of a.
                    y,
                    // Decrement the coefficient of n.
                    // Can overflow, but the result is casted to uint256 so that the
                    // next value of y is "wrapped around" to a value between 0 and n - 1.
                    x - y * int256(quotient)
                );
            }

            if (gcd != 1) return 0; // No inverse exists.
            return ternary(x < 0, n - uint256(-x), uint256(x)); // Wrap the result if it's negative.
        }
    }

    /**
     * @dev Variant of {invMod}. More efficient, but only works if `p` is known to be a prime greater than `2`.
     *
     * From https://en.wikipedia.org/wiki/Fermat%27s_little_theorem[Fermat's little theorem], we know that if p is
     * prime, then `a**(p-1) ≡ 1 mod p`. As a consequence, we have `a * a**(p-2) ≡ 1 mod p`, which means that
     * `a**(p-2)` is the modular multiplicative inverse of a in Fp.
     *
     * NOTE: this function does NOT check that `p` is a prime greater than `2`.
     */
    function invModPrime(uint256 a, uint256 p) internal view returns (uint256) {
        unchecked {
            return Math.modExp(a, p - 2, p);
        }
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m)
     *
     * Requirements:
     * - modulus can't be zero
     * - underlying staticcall to precompile must succeed
     *
     * IMPORTANT: The result is only valid if the underlying call succeeds. When using this function, make
     * sure the chain you're using it on supports the precompiled contract for modular exponentiation
     * at address 0x05 as specified in https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise,
     * the underlying function will succeed given the lack of a revert, but the result may be incorrectly
     * interpreted as 0.
     */
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Returns the modular exponentiation of the specified base, exponent and modulus (b ** e % m).
     * It includes a success flag indicating if the operation succeeded. Operation will be marked as failed if trying
     * to operate modulo 0 or if the underlying precompile reverted.
     *
     * IMPORTANT: The result is only valid if the success flag is true. When using this function, make sure the chain
     * you're using it on supports the precompiled contract for modular exponentiation at address 0x05 as specified in
     * https://eips.ethereum.org/EIPS/eip-198[EIP-198]. Otherwise, the underlying function will succeed given the lack
     * of a revert, but the result may be incorrectly interpreted as 0.
     */
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            // | Offset    | Content    | Content (Hex)                                                      |
            // |-----------|------------|--------------------------------------------------------------------|
            // | 0x00:0x1f | size of b  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x20:0x3f | size of e  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x40:0x5f | size of m  | 0x0000000000000000000000000000000000000000000000000000000000000020 |
            // | 0x60:0x7f | value of b | 0x<.............................................................b> |
            // | 0x80:0x9f | value of e | 0x<.............................................................e> |
            // | 0xa0:0xbf | value of m | 0x<.............................................................m> |
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)

            // Given the result < m, it's guaranteed to fit in 32 bytes,
            // so we can use the memory scratch space located at offset 0.
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }

    /**
     * @dev Variant of {modExp} that supports inputs of arbitrary length.
     */
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }

    /**
     * @dev Variant of {tryModExp} that supports inputs of arbitrary length.
     */
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));

        uint256 mLen = m.length;

        // Encode call args in result and move the free memory pointer
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);

        assembly ("memory-safe") {
            let dataPtr := add(result, 0x20)
            // Write result on top of args to avoid allocating extra memory.
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            // Overwrite the length.
            // result.length > returndatasize() is guaranteed because returndatasize() == m.length
            mstore(result, mLen)
            // Set the memory pointer after the returned data.
            mstore(0x40, add(dataPtr, mLen))
        }
    }

    /**
     * @dev Returns whether the provided byte array is zero.
     */
    function _zeroBytes(bytes memory byteArray) private pure returns (bool) {
        for (uint256 i = 0; i < byteArray.length; ++i) {
            if (byteArray[i] != 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * This method is based on Newton's method for computing square roots; the algorithm is restricted to only
     * using integer operations.
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            // Take care of easy edge cases when a == 0 or a == 1
            if (a <= 1) {
                return a;
            }

            // In this function, we use Newton's method to get a root of `f(x) := x² - a`. It involves building a
            // sequence x_n that converges toward sqrt(a). For each iteration x_n, we also define the error between
            // the current value as `ε_n = | x_n - sqrt(a) |`.
            //
            // For our first estimation, we consider `e` the smallest power of 2 which is bigger than the square root
            // of the target. (i.e. `2**(e-1) ≤ sqrt(a) < 2**e`). We know that `e ≤ 128` because `(2¹²⁸)² = 2²⁵⁶` is
            // bigger than any uint256.
            //
            // By noticing that
            // `2**(e-1) ≤ sqrt(a) < 2**e → (2**(e-1))² ≤ a < (2**e)² → 2**(2*e-2) ≤ a < 2**(2*e)`
            // we can deduce that `e - 1` is `log2(a) / 2`. We can thus compute `x_n = 2**(e-1)` using a method similar
            // to the msb function.
            uint256 aa = a;
            uint256 xn = 1;

            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }

            // We now have x_n such that `x_n = 2**(e-1) ≤ sqrt(a) < 2**e = 2 * x_n`. This implies ε_n ≤ 2**(e-1).
            //
            // We can refine our estimation by noticing that the middle of that interval minimizes the error.
            // If we move x_n to equal 2**(e-1) + 2**(e-2), then we reduce the error to ε_n ≤ 2**(e-2).
            // This is going to be our x_0 (and ε_0)
            xn = (3 * xn) >> 1; // ε_0 := | x_0 - sqrt(a) | ≤ 2**(e-2)

            // From here, Newton's method give us:
            // x_{n+1} = (x_n + a / x_n) / 2
            //
            // One should note that:
            // x_{n+1}² - a = ((x_n + a / x_n) / 2)² - a
            //              = ((x_n² + a) / (2 * x_n))² - a
            //              = (x_n⁴ + 2 * a * x_n² + a²) / (4 * x_n²) - a
            //              = (x_n⁴ + 2 * a * x_n² + a² - 4 * a * x_n²) / (4 * x_n²)
            //              = (x_n⁴ - 2 * a * x_n² + a²) / (4 * x_n²)
            //              = (x_n² - a)² / (2 * x_n)²
            //              = ((x_n² - a) / (2 * x_n))²
            //              ≥ 0
            // Which proves that for all n ≥ 1, sqrt(a) ≤ x_n
            //
            // This gives us the proof of quadratic convergence of the sequence:
            // ε_{n+1} = | x_{n+1} - sqrt(a) |
            //         = | (x_n + a / x_n) / 2 - sqrt(a) |
            //         = | (x_n² + a - 2*x_n*sqrt(a)) / (2 * x_n) |
            //         = | (x_n - sqrt(a))² / (2 * x_n) |
            //         = | ε_n² / (2 * x_n) |
            //         = ε_n² / | (2 * x_n) |
            //
            // For the first iteration, we have a special case where x_0 is known:
            // ε_1 = ε_0² / | (2 * x_0) |
            //     ≤ (2**(e-2))² / (2 * (2**(e-1) + 2**(e-2)))
            //     ≤ 2**(2*e-4) / (3 * 2**(e-1))
            //     ≤ 2**(e-3) / 3
            //     ≤ 2**(e-3-log2(3))
            //     ≤ 2**(e-4.5)
            //
            // For the following iterations, we use the fact that, 2**(e-1) ≤ sqrt(a) ≤ x_n:
            // ε_{n+1} = ε_n² / | (2 * x_n) |
            //         ≤ (2**(e-k))² / (2 * 2**(e-1))
            //         ≤ 2**(2*e-2*k) / 2**e
            //         ≤ 2**(e-2*k)
            xn = (xn + a / xn) >> 1; // ε_1 := | x_1 - sqrt(a) | ≤ 2**(e-4.5)  -- special case, see above
            xn = (xn + a / xn) >> 1; // ε_2 := | x_2 - sqrt(a) | ≤ 2**(e-9)    -- general case with k = 4.5
            xn = (xn + a / xn) >> 1; // ε_3 := | x_3 - sqrt(a) | ≤ 2**(e-18)   -- general case with k = 9
            xn = (xn + a / xn) >> 1; // ε_4 := | x_4 - sqrt(a) | ≤ 2**(e-36)   -- general case with k = 18
            xn = (xn + a / xn) >> 1; // ε_5 := | x_5 - sqrt(a) | ≤ 2**(e-72)   -- general case with k = 36
            xn = (xn + a / xn) >> 1; // ε_6 := | x_6 - sqrt(a) | ≤ 2**(e-144)  -- general case with k = 72

            // Because e ≤ 128 (as discussed during the first estimation phase), we know have reached a precision
            // ε_6 ≤ 2**(e-144) < 1. Given we're operating on integers, then we can ensure that xn is now either
            // sqrt(a) or sqrt(a) + 1.
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }

    /**
     * @dev Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 x) internal pure returns (uint256 r) {
        // If value has upper 128 bits set, log2 result is at least 128
        r = SafeCast.toUint(x > 0xffffffffffffffffffffffffffffffff) << 7;
        // If upper 64 bits of 128-bit half set, add 64 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffffffffffff) << 6;
        // If upper 32 bits of 64-bit half set, add 32 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffff) << 5;
        // If upper 16 bits of 32-bit half set, add 16 to result
        r |= SafeCast.toUint((x >> r) > 0xffff) << 4;
        // If upper 8 bits of 16-bit half set, add 8 to result
        r |= SafeCast.toUint((x >> r) > 0xff) << 3;
        // If upper 4 bits of 8-bit half set, add 4 to result
        r |= SafeCast.toUint((x >> r) > 0xf) << 2;

        // Shifts value right by the current result and use it as an index into this lookup table:
        //
        // | x (4 bits) |  index  | table[index] = MSB position |
        // |------------|---------|-----------------------------|
        // |    0000    |    0    |        table[0] = 0         |
        // |    0001    |    1    |        table[1] = 0         |
        // |    0010    |    2    |        table[2] = 1         |
        // |    0011    |    3    |        table[3] = 1         |
        // |    0100    |    4    |        table[4] = 2         |
        // |    0101    |    5    |        table[5] = 2         |
        // |    0110    |    6    |        table[6] = 2         |
        // |    0111    |    7    |        table[7] = 2         |
        // |    1000    |    8    |        table[8] = 3         |
        // |    1001    |    9    |        table[9] = 3         |
        // |    1010    |   10    |        table[10] = 3        |
        // |    1011    |   11    |        table[11] = 3        |
        // |    1100    |   12    |        table[12] = 3        |
        // |    1101    |   13    |        table[13] = 3        |
        // |    1110    |   14    |        table[14] = 3        |
        // |    1111    |   15    |        table[15] = 3        |
        //
        // The lookup table is represented as a 32-byte value with the MSB positions for 0-15 in the last 16 bytes.
        assembly ("memory-safe") {
            r := or(r, byte(shr(r, x), 0x0000010102020202030303030303030300000000000000000000000000000000))
        }
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 isGt;
        unchecked {
            isGt = SafeCast.toUint(value > (1 << 128) - 1);
            value >>= isGt * 128;
            result += isGt * 16;

            isGt = SafeCast.toUint(value > (1 << 64) - 1);
            value >>= isGt * 64;
            result += isGt * 8;

            isGt = SafeCast.toUint(value > (1 << 32) - 1);
            value >>= isGt * 32;
            result += isGt * 4;

            isGt = SafeCast.toUint(value > (1 << 16) - 1);
            value >>= isGt * 16;
            result += isGt * 2;

            result += SafeCast.toUint(value > (1 << 8) - 1);
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Branchless ternary evaluation for `a ? b : c`. Gas costs are constant.
     *
     * IMPORTANT: This function may reduce bytecode size and consume less gas when used standalone.
     * However, the compiler may optimize Solidity ternary operations (i.e. `a ? b : c`) to only compute
     * one branch when needed, making this function more expensive.
     */
    function ternary(bool condition, int256 a, int256 b) internal pure returns (int256) {
        unchecked {
            // branchless ternary works because:
            // b ^ (a ^ b) == a
            // b ^ 0 == b
            return b ^ ((a ^ b) * int256(SafeCast.toUint(condition)));
        }
    }

    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a > b, a, b);
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return ternary(a < b, a, b);
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // Formula from the "Bit Twiddling Hacks" by Sean Eron Anderson.
            // Since `n` is a signed integer, the generated bytecode will use the SAR opcode to perform the right shift,
            // taking advantage of the most significant (or "sign" bit) in two's complement representation.
            // This opcode adds new most significant bits set to the value of the previous most significant bit. As a result,
            // the mask will either be `bytes32(0)` (if n is positive) or `~bytes32(0)` (if n is negative).
            int256 mask = n >> 255;

            // A `bytes32(0)` mask leaves the input unchanged, while a `~bytes32(0)` mask complements it.
            return uint256((n + mask) ^ mask);
        }
    }
}

/**
 * @dev String operations.
 */
library Strings {
    using SafeCast for *;

    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev The string being parsed contains characters that are not in scope of the given base.
     */
    error StringsInvalidChar();

    /**
     * @dev The string being parsed is not a properly formatted address.
     */
    error StringsInvalidAddressFormat();

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly ("memory-safe") {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its checksummed ASCII `string` hexadecimal
     * representation, according to EIP-55.
     */
    function toChecksumHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = bytes(toHexString(addr));

        // hash the hex part of buffer (skip length + 2 bytes, length 40)
        uint256 hashValue;
        assembly ("memory-safe") {
            hashValue := shr(96, keccak256(add(buffer, 0x22), 40))
        }

        for (uint256 i = 41; i > 1; --i) {
            // possible values for buffer[i] are 48 (0) to 57 (9) and 97 (a) to 102 (f)
            if (hashValue & 0xf > 7 && uint8(buffer[i]) > 96) {
                // case shift by xoring with 0x20
                buffer[i] ^= 0x20;
            }
            hashValue >>= 4;
        }
        return string(buffer);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }

    /**
     * @dev Parse a decimal string and returns the value as a `uint256`.
     *
     * Requirements:
     * - The string must be formatted as `[0-9]*`
     * - The result must fit into an `uint256` type
     */
    function parseUint(string memory input) internal pure returns (uint256) {
        return parseUint(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseUint} that parses a substring of `input` located between position `begin` (included) and
     * `end` (excluded).
     *
     * Requirements:
     * - The substring must be formatted as `[0-9]*`
     * - The result must fit into an `uint256` type
     */
    function parseUint(string memory input, uint256 begin, uint256 end) internal pure returns (uint256) {
        (bool success, uint256 value) = tryParseUint(input, begin, end);
        if (!success) revert StringsInvalidChar();
        return value;
    }

    /**
     * @dev Variant of {parseUint-string} that returns false if the parsing fails because of an invalid character.
     *
     * NOTE: This function will revert if the result does not fit in a `uint256`.
     */
    function tryParseUint(string memory input) internal pure returns (bool success, uint256 value) {
        return tryParseUint(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseUint-string-uint256-uint256} that returns false if the parsing fails because of an invalid
     * character.
     *
     * NOTE: This function will revert if the result does not fit in a `uint256`.
     */
    function tryParseUint(
        string memory input,
        uint256 begin,
        uint256 end
    ) internal pure returns (bool success, uint256 value) {
        bytes memory buffer = bytes(input);

        uint256 result = 0;
        for (uint256 i = begin; i < end; ++i) {
            uint8 chr = _tryParseChr(bytes1(_unsafeReadBytesOffset(buffer, i)));
            if (chr > 9) return (false, 0);
            result *= 10;
            result += chr;
        }
        return (true, result);
    }

    /**
     * @dev Parse a decimal string and returns the value as a `int256`.
     *
     * Requirements:
     * - The string must be formatted as `[-+]?[0-9]*`
     * - The result must fit in an `int256` type.
     */
    function parseInt(string memory input) internal pure returns (int256) {
        return parseInt(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseInt-string} that parses a substring of `input` located between position `begin` (included) and
     * `end` (excluded).
     *
     * Requirements:
     * - The substring must be formatted as `[-+]?[0-9]*`
     * - The result must fit in an `int256` type.
     */
    function parseInt(string memory input, uint256 begin, uint256 end) internal pure returns (int256) {
        (bool success, int256 value) = tryParseInt(input, begin, end);
        if (!success) revert StringsInvalidChar();
        return value;
    }

    /**
     * @dev Variant of {parseInt-string} that returns false if the parsing fails because of an invalid character or if
     * the result does not fit in a `int256`.
     *
     * NOTE: This function will revert if the absolute value of the result does not fit in a `uint256`.
     */
    function tryParseInt(string memory input) internal pure returns (bool success, int256 value) {
        return tryParseInt(input, 0, bytes(input).length);
    }

    uint256 private constant ABS_MIN_INT256 = 2 ** 255;

    /**
     * @dev Variant of {parseInt-string-uint256-uint256} that returns false if the parsing fails because of an invalid
     * character or if the result does not fit in a `int256`.
     *
     * NOTE: This function will revert if the absolute value of the result does not fit in a `uint256`.
     */
    function tryParseInt(
        string memory input,
        uint256 begin,
        uint256 end
    ) internal pure returns (bool success, int256 value) {
        bytes memory buffer = bytes(input);

        // Check presence of a negative sign.
        bytes1 sign = bytes1(_unsafeReadBytesOffset(buffer, begin));
        bool positiveSign = sign == bytes1("+");
        bool negativeSign = sign == bytes1("-");
        uint256 offset = (positiveSign || negativeSign).toUint();

        (bool absSuccess, uint256 absValue) = tryParseUint(input, begin + offset, end);

        if (absSuccess && absValue < ABS_MIN_INT256) {
            return (true, negativeSign ? -int256(absValue) : int256(absValue));
        } else if (absSuccess && negativeSign && absValue == ABS_MIN_INT256) {
            return (true, type(int256).min);
        } else return (false, 0);
    }

    /**
     * @dev Parse a hexadecimal string (with or without "0x" prefix), and returns the value as a `uint256`.
     *
     * Requirements:
     * - The string must be formatted as `(0x)?[0-9a-fA-F]*`
     * - The result must fit in an `uint256` type.
     */
    function parseHexUint(string memory input) internal pure returns (uint256) {
        return parseHexUint(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseHexUint} that parses a substring of `input` located between position `begin` (included) and
     * `end` (excluded).
     *
     * Requirements:
     * - The substring must be formatted as `(0x)?[0-9a-fA-F]*`
     * - The result must fit in an `uint256` type.
     */
    function parseHexUint(string memory input, uint256 begin, uint256 end) internal pure returns (uint256) {
        (bool success, uint256 value) = tryParseHexUint(input, begin, end);
        if (!success) revert StringsInvalidChar();
        return value;
    }

    /**
     * @dev Variant of {parseHexUint-string} that returns false if the parsing fails because of an invalid character.
     *
     * NOTE: This function will revert if the result does not fit in a `uint256`.
     */
    function tryParseHexUint(string memory input) internal pure returns (bool success, uint256 value) {
        return tryParseHexUint(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseHexUint-string-uint256-uint256} that returns false if the parsing fails because of an
     * invalid character.
     *
     * NOTE: This function will revert if the result does not fit in a `uint256`.
     */
    function tryParseHexUint(
        string memory input,
        uint256 begin,
        uint256 end
    ) internal pure returns (bool success, uint256 value) {
        bytes memory buffer = bytes(input);

        // skip 0x prefix if present
        bool hasPrefix = bytes2(_unsafeReadBytesOffset(buffer, begin)) == bytes2("0x");
        uint256 offset = hasPrefix.toUint() * 2;

        uint256 result = 0;
        for (uint256 i = begin + offset; i < end; ++i) {
            uint8 chr = _tryParseChr(bytes1(_unsafeReadBytesOffset(buffer, i)));
            if (chr > 15) return (false, 0);
            result *= 16;
            unchecked {
                // Multiplying by 16 is equivalent to a shift of 4 bits (with additional overflow check).
                // This guaratees that adding a value < 16 will not cause an overflow, hence the unchecked.
                result += chr;
            }
        }
        return (true, result);
    }

    /**
     * @dev Parse a hexadecimal string (with or without "0x" prefix), and returns the value as an `address`.
     *
     * Requirements:
     * - The string must be formatted as `(0x)?[0-9a-fA-F]{40}`
     */
    function parseAddress(string memory input) internal pure returns (address) {
        return parseAddress(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseAddress} that parses a substring of `input` located between position `begin` (included) and
     * `end` (excluded).
     *
     * Requirements:
     * - The substring must be formatted as `(0x)?[0-9a-fA-F]{40}`
     */
    function parseAddress(string memory input, uint256 begin, uint256 end) internal pure returns (address) {
        (bool success, address value) = tryParseAddress(input, begin, end);
        if (!success) revert StringsInvalidAddressFormat();
        return value;
    }

    /**
     * @dev Variant of {parseAddress-string} that returns false if the parsing fails because the input is not a properly
     * formatted address. See {parseAddress} requirements.
     */
    function tryParseAddress(string memory input) internal pure returns (bool success, address value) {
        return tryParseAddress(input, 0, bytes(input).length);
    }

    /**
     * @dev Variant of {parseAddress-string-uint256-uint256} that returns false if the parsing fails because input is not a properly
     * formatted address. See {parseAddress} requirements.
     */
    function tryParseAddress(
        string memory input,
        uint256 begin,
        uint256 end
    ) internal pure returns (bool success, address value) {
        // check that input is the correct length
        bool hasPrefix = bytes2(_unsafeReadBytesOffset(bytes(input), begin)) == bytes2("0x");
        uint256 expectedLength = 40 + hasPrefix.toUint() * 2;

        if (end - begin == expectedLength) {
            // length guarantees that this does not overflow, and value is at most type(uint160).max
            (bool s, uint256 v) = tryParseHexUint(input, begin, end);
            return (s, address(uint160(v)));
        } else {
            return (false, address(0));
        }
    }

    function _tryParseChr(bytes1 chr) private pure returns (uint8) {
        uint8 value = uint8(chr);

        // Try to parse `chr`:
        // - Case 1: [0-9]
        // - Case 2: [a-f]
        // - Case 3: [A-F]
        // - otherwise not supported
        unchecked {
            if (value > 47 && value < 58) value -= 48;
            else if (value > 96 && value < 103) value -= 87;
            else if (value > 64 && value < 71) value -= 55;
            else return type(uint8).max;
        }

        return value;
    }

    /**
     * @dev Reads a bytes32 from a bytes array without bounds checking.
     *
     * NOTE: making this function internal would mean it could be used with memory unsafe offset, and marking the
     * assembly block as such would prevent some optimizations.
     */
    function _unsafeReadBytesOffset(bytes memory buffer, uint256 offset) private pure returns (bytes32 value) {
        // This is not memory safe in the general case, but all calls to this private function are within bounds.
        assembly ("memory-safe") {
            value := mload(add(buffer, add(0x20, offset)))
        }
    }
}

/**
 * @dev Signature message hash utilities for producing digests to be consumed by {ECDSA} recovery or signing.
 *
 * The library provides methods for generating a hash of a message that conforms to the
 * https://eips.ethereum.org/EIPS/eip-191[ERC-191] and https://eips.ethereum.org/EIPS/eip-712[EIP 712]
 * specifications.
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing a bytes32 `messageHash` with
     * `"\x19Ethereum Signed Message:\n32"` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * NOTE: The `messageHash` parameter is intended to be the result of hashing a raw message with
     * keccak256, although any bytes32 value can be safely used because the final digest will
     * be re-hashed.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
            mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
            digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
        }
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x45` (`personal_sign` messages).
     *
     * The digest is calculated by prefixing an arbitrary `message` with
     * `"\x19Ethereum Signed Message:\n" + len(message)` and hashing the result. It corresponds with the
     * hash signed when using the https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`] JSON-RPC method.
     *
     * See {ECDSA-recover}.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return
            keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }

    /**
     * @dev Returns the keccak256 digest of an ERC-191 signed data with version
     * `0x00` (data with intended validator).
     *
     * The digest is calculated by prefixing an arbitrary `data` with `"\x19\x00"` and the intended
     * `validator` address. Then hashing the result.
     *
     * See {ECDSA-recover}.
     */
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(hex"19_00", validator, data));
    }

    /**
     * @dev Returns the keccak256 digest of an EIP-712 typed data (ERC-191 version `0x01`).
     *
     * The digest is calculated from a `domainSeparator` and a `structHash`, by prefixing them with
     * `\x19\x01` and hashing the result. It corresponds to the hash signed by the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`] JSON-RPC method as part of EIP-712.
     *
     * See {ECDSA-recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, hex"19_01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            digest := keccak256(ptr, 0x42)
        }
    }
}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP-712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
 * encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
 * does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
 * produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP-712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
 * separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
 * separator from the immutable values, which is cheaper than accessing a cached version in cold storage.
 *
 * @custom:oz-upgrades-unsafe-allow state-variable-immutable
 */
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;

    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;

    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP-712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));

        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev See {IERC-5267}.
     */
    function eip712Domain()
        public
        view
        virtual
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", // 01111
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }

    /**
     * @dev The name parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _name which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Name() internal view returns (string memory) {
        return _name.toStringWithFallback(_nameFallback);
    }

    /**
     * @dev The version parameter for the EIP712 domain.
     *
     * NOTE: By default this function reads _version which is an immutable value.
     * It only reads from storage if necessary (in case the value is too large to fit in a ShortString).
     */
    // solhint-disable-next-line func-name-mixedcase
    function _EIP712Version() internal view returns (string memory) {
        return _version.toStringWithFallback(_versionFallback);
    }
}

interface IPayload {
  struct Action {
    address target;
    bytes data;
  }

  /**
   * @notice  A URI that can be used to refer to where a non-coder human readable description
   *          of the payload can be found.
   *
   * @dev     Not used in the contracts, so could be any string really
   *
   * @return - Ideally a useful URI for the payload description
   */
  function getURI() external view returns (string memory);

  function getActions() external view returns (Action[] memory);
}

/**
 * @dev Collection of common custom errors used in multiple contracts
 *
 * IMPORTANT: Backwards compatibility is not guaranteed in future versions of the library.
 * It is recommended to avoid relying on the error API for critical functionality.
 *
 * _Available since v5.1._
 */
library Errors {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error InsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedCall();

    /**
     * @dev The deployment failed.
     */
    error FailedDeployment();

    /**
     * @dev A necessary precompile is missing.
     */
    error MissingPrecompile(address);
}

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev There's no code to deploy.
     */
    error Create2EmptyBytecode();

    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }
        if (bytecode.length == 0) {
            revert Create2EmptyBytecode();
        }
        assembly ("memory-safe") {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
            // if no address was created, and returndata is not empty, bubble revert
            if and(iszero(addr), not(iszero(returndatasize()))) {
                let p := mload(0x40)
                returndatacopy(p, 0, returndatasize())
                revert(p, returndatasize())
            }
        }
        if (addr == address(0)) {
            revert Errors.FailedDeployment();
        }
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address addr) {
        assembly ("memory-safe") {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := and(keccak256(start, 85), 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }
}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[ERC-1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 */
library Clones {
    error CloneArgumentsTooLong();

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        return clone(implementation, 0);
    }

    /**
     * @dev Same as {xref-Clones-clone-address-}[clone], but with a `value` parameter to send native currency
     * to the new contract.
     *
     * NOTE: Using a non-zero value at creation will require the contract using this function (e.g. a factory)
     * to always have enough balance for new deployments. Consider exposing this function under a payable method.
     */
    function clone(address implementation, uint256 value) internal returns (address instance) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        assembly ("memory-safe") {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(value, 0x09, 0x37)
        }
        if (instance == address(0)) {
            revert Errors.FailedDeployment();
        }
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        return cloneDeterministic(implementation, salt, 0);
    }

    /**
     * @dev Same as {xref-Clones-cloneDeterministic-address-bytes32-}[cloneDeterministic], but with
     * a `value` parameter to send native currency to the new contract.
     *
     * NOTE: Using a non-zero value at creation will require the contract using this function (e.g. a factory)
     * to always have enough balance for new deployments. Consider exposing this function under a payable method.
     */
    function cloneDeterministic(
        address implementation,
        bytes32 salt,
        uint256 value
    ) internal returns (address instance) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        assembly ("memory-safe") {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(value, 0x09, 0x37, salt)
        }
        if (instance == address(0)) {
            revert Errors.FailedDeployment();
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := and(keccak256(add(ptr, 0x43), 0x55), 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behavior of `implementation` with custom
     * immutable arguments. These are provided through `args` and cannot be changed after deployment. To
     * access the arguments within the implementation, use {fetchCloneArgs}.
     *
     * This function uses the create opcode, which should never revert.
     */
    function cloneWithImmutableArgs(address implementation, bytes memory args) internal returns (address instance) {
        return cloneWithImmutableArgs(implementation, args, 0);
    }

    /**
     * @dev Same as {xref-Clones-cloneWithImmutableArgs-address-bytes-}[cloneWithImmutableArgs], but with a `value`
     * parameter to send native currency to the new contract.
     *
     * NOTE: Using a non-zero value at creation will require the contract using this function (e.g. a factory)
     * to always have enough balance for new deployments. Consider exposing this function under a payable method.
     */
    function cloneWithImmutableArgs(
        address implementation,
        bytes memory args,
        uint256 value
    ) internal returns (address instance) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        bytes memory bytecode = _cloneCodeWithImmutableArgs(implementation, args);
        assembly ("memory-safe") {
            instance := create(value, add(bytecode, 0x20), mload(bytecode))
        }
        if (instance == address(0)) {
            revert Errors.FailedDeployment();
        }
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation` with custom
     * immutable arguments. These are provided through `args` and cannot be changed after deployment. To
     * access the arguments within the implementation, use {fetchCloneArgs}.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy the clone. Using the same
     * `implementation` and `salt` multiple time will revert, since the clones cannot be deployed twice at the same
     * address.
     */
    function cloneDeterministicWithImmutableArgs(
        address implementation,
        bytes memory args,
        bytes32 salt
    ) internal returns (address instance) {
        return cloneDeterministicWithImmutableArgs(implementation, args, salt, 0);
    }

    /**
     * @dev Same as {xref-Clones-cloneDeterministicWithImmutableArgs-address-bytes-bytes32-}[cloneDeterministicWithImmutableArgs],
     * but with a `value` parameter to send native currency to the new contract.
     *
     * NOTE: Using a non-zero value at creation will require the contract using this function (e.g. a factory)
     * to always have enough balance for new deployments. Consider exposing this function under a payable method.
     */
    function cloneDeterministicWithImmutableArgs(
        address implementation,
        bytes memory args,
        bytes32 salt,
        uint256 value
    ) internal returns (address instance) {
        bytes memory bytecode = _cloneCodeWithImmutableArgs(implementation, args);
        return Create2.deploy(value, salt, bytecode);
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministicWithImmutableArgs}.
     */
    function predictDeterministicAddressWithImmutableArgs(
        address implementation,
        bytes memory args,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes memory bytecode = _cloneCodeWithImmutableArgs(implementation, args);
        return Create2.computeAddress(salt, keccak256(bytecode), deployer);
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministicWithImmutableArgs}.
     */
    function predictDeterministicAddressWithImmutableArgs(
        address implementation,
        bytes memory args,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddressWithImmutableArgs(implementation, args, salt, address(this));
    }

    /**
     * @dev Get the immutable args attached to a clone.
     *
     * - If `instance` is a clone that was deployed using `clone` or `cloneDeterministic`, this
     *   function will return an empty array.
     * - If `instance` is a clone that was deployed using `cloneWithImmutableArgs` or
     *   `cloneDeterministicWithImmutableArgs`, this function will return the args array used at
     *   creation.
     * - If `instance` is NOT a clone deployed using this library, the behavior is undefined. This
     *   function should only be used to check addresses that are known to be clones.
     */
    function fetchCloneArgs(address instance) internal view returns (bytes memory) {
        bytes memory result = new bytes(instance.code.length - 0x2d); // revert if length is too short
        assembly ("memory-safe") {
            extcodecopy(instance, add(result, 0x20), 0x2d, mload(result))
        }
        return result;
    }

    /**
     * @dev Helper that prepares the initcode of the proxy with immutable args.
     *
     * An assembly variant of this function requires copying the `args` array, which can be efficiently done using
     * `mcopy`. Unfortunately, that opcode is not available before cancun. A pure solidity implementation using
     * abi.encodePacked is more expensive but also more portable and easier to review.
     *
     * NOTE: https://eips.ethereum.org/EIPS/eip-170[EIP-170] limits the length of the contract code to 24576 bytes.
     * With the proxy code taking 45 bytes, that limits the length of the immutable args to 24531 bytes.
     */
    function _cloneCodeWithImmutableArgs(
        address implementation,
        bytes memory args
    ) private pure returns (bytes memory) {
        if (args.length > 0x5fd3) revert CloneArgumentsTooLong();
        return
            abi.encodePacked(
                hex"61",
                uint16(args.length + 0x2d),
                hex"3d81600a3d39f3363d3d373d3d3d363d73",
                implementation,
                hex"5af43d82803e903d91602b57fd5bf3",
                args
            );
    }
}

struct G1Point {
  uint256 x;
  uint256 y;
}

struct G2Point {
  uint256 x0;
  uint256 x1;
  uint256 y0;
  uint256 y1;
}

/**
 * If the number of validators in the rollup is 0, and the number of validators in the queue is less than
 * `bootstrapValidatorSetSize`, then `getEntryQueueFlushSize` will return 0.
 *
 * If the number of validators in the rollup is 0, and the number of validators in the queue is greater than or equal to
 * `bootstrapValidatorSetSize`, then `getEntryQueueFlushSize` will return `bootstrapFlushSize`.
 *
 * If the number of validators in the rollup is greater than 0 and less than `bootstrapValidatorSetSize`, then
 * `getEntryQueueFlushSize` will return `bootstrapFlushSize`.
 *
 * If the number of validators in the rollup is greater than or equal to `bootstrapValidatorSetSize`, then
 * `getEntryQueueFlushSize` will return Max( `normalFlushSizeMin`, `activeAttesterCount` / `normalFlushSizeQuotient`).
 *
 * NOTE: If the normalFlushSizeMin is 0 and the validator set is empty, above will return max(0, 0) and it won't be
 * possible to add validators. This can close the queue even if there are members in the validator set if a very high
 * `normalFlushSizeQuotient` is used.
 *
 * NOTE: We will NEVER flush more than `maxQueueFlushSize` validators: it is applied as a Max at the end of every
 * calculation.
 * This can be used to prevent a situation where flushing the queue would exceed the block gas limit.
 */
struct StakingQueueConfig {
  uint256 bootstrapValidatorSetSize;
  uint256 bootstrapFlushSize;
  uint256 normalFlushSizeMin;
  uint256 normalFlushSizeQuotient;
  uint256 maxQueueFlushSize;
}

interface IStakingCore {
  event SlasherUpdated(address indexed oldSlasher, address indexed newSlasher);
  event PendingSlasherQueued(address indexed slasher, uint256 readyAt);
  event PendingSlasherCancelled(address indexed slasher);
  event LegacySlasherAuthorized(address indexed legacySlasher, uint256 authorizedUntil);
  event ValidatorQueued(address indexed attester, address indexed withdrawer);
  event Deposit(
    address indexed attester,
    address indexed withdrawer,
    G1Point publicKeyInG1,
    G2Point publicKeyInG2,
    G1Point proofOfPossession,
    uint256 amount
  );
  event FailedDeposit(
    address indexed attester,
    address indexed withdrawer,
    G1Point publicKeyInG1,
    G2Point publicKeyInG2,
    G1Point proofOfPossession
  );
  event WithdrawInitiated(address indexed attester, address indexed recipient, uint256 amount);
  event WithdrawFinalized(address indexed attester, address indexed recipient, uint256 amount);
  event Slashed(address indexed attester, uint256 amount);
  event StakingQueueConfigUpdated(StakingQueueConfig config);

  function queueSetSlasher(address _slasher) external;
  function cancelSetSlasher() external;
  function finalizeSetSlasher() external;
  function deposit(
    address _attester,
    address _withdrawer,
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession,
    bool _moveWithLatestRollup
  ) external;
  function flushEntryQueue() external;
  function flushEntryQueue(uint256 _toAdd) external;
  function initiateWithdraw(address _attester, address _recipient) external returns (bool);
  function finalizeWithdraw(address _attester) external;
  function slash(address _attester, uint256 _amount) external returns (bool);
  function vote(uint256 _proposalId) external;
  function updateStakingQueueConfig(StakingQueueConfig memory _config) external;

  function getEntryQueueFlushSize() external view returns (uint256);
  function getActiveAttesterCount() external view returns (uint256);
}

/**
 * @notice Cloneable SlashPayload implementation that fetches arguments from immutable storage
 * @dev This contract is deployed once as an implementation and then cloned for each slash payload
 * Using EIP-1167 minimal proxy pattern with immutable arguments to save gas on deployment
 * @dev This contract can be further optimized by NOT storing the actions as immutables, and instead
 * store them in transient storage in the main contract, and just storing the round number here. Then,
 * when actions are requested, we just call back into the proposer and return them. Note that we cannot
 * just compute them on the fly on the proposer, since we need the committees to be provided as calldata.
 */
contract SlashPayloadCloneable is IPayload {
  using Clones for address;

  /**
   * @notice Get the actions to execute for this slash payload
   * @return actions Array of actions to slash validators
   */
  function getActions() external view override(IPayload) returns (IPayload.Action[] memory actions) {
    (address validatorSelection, address[] memory validators, uint96[] memory amounts) = _getImmutableArgs();

    actions = new IPayload.Action[](validators.length);

    for (uint256 i = 0; i < validators.length; i++) {
      actions[i] = IPayload.Action({
        target: validatorSelection, data: abi.encodeWithSelector(IStakingCore.slash.selector, validators[i], amounts[i])
      });
    }
  }

  /**
   * @notice Get the URI for this payload
   * @return The URI string
   */
  function getURI() external pure override(IPayload) returns (string memory) {
    return "SlashPayload";
  }

  /**
   * @notice Decode the immutable arguments stored in the clone's bytecode
   * @return validatorSelection The address of the validator selection contract
   * @return validators Array of validator addresses to slash
   * @return amounts Array of amounts to slash for each validator
   */
  function _getImmutableArgs()
    private
    view
    returns (address validatorSelection, address[] memory validators, uint96[] memory amounts)
  {
    // Fetch immutable args from clone's bytecode
    bytes memory args = Clones.fetchCloneArgs(address(this));

    // Decode the arguments
    // Layout: [validatorSelection(20 bytes)][arrayLength(32 bytes)][validators+amounts array data]
    assembly {
      // Read validator selection address (first 20 bytes)
      validatorSelection := shr(96, mload(add(args, 0x20)))

      // Read array length (next 32 bytes after the address)
      let arrayLen := mload(add(args, 0x34))

      // Allocate memory for validators array
      validators := mload(0x40)
      mstore(validators, arrayLen)
      let validatorsData := add(validators, 0x20)

      // Allocate memory for amounts array
      amounts := add(validatorsData, mul(arrayLen, 0x20))
      mstore(amounts, arrayLen)
      let amountsData := add(amounts, 0x20)

      // Update free memory pointer
      mstore(0x40, add(amountsData, mul(arrayLen, 0x20)))

      // Copy validator addresses and amounts
      let srcPtr := add(args, 0x54) // Start after validatorSelection + arrayLength

      for { let i := 0 } lt(i, arrayLen) { i := add(i, 1) } {
        // Read validator address (20 bytes)
        let validator := shr(96, mload(srcPtr))
        mstore(add(validatorsData, mul(i, 0x20)), validator)
        srcPtr := add(srcPtr, 0x14)

        // Read amount (12 bytes for uint96)
        let amount := shr(160, mload(srcPtr))
        mstore(add(amountsData, mul(i, 0x20)), amount)
        srcPtr := add(srcPtr, 0x0c)
      }
    }
  }
}

// Signature
struct Signature {
  uint8 v;
  bytes32 r;
  bytes32 s;
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    /**
     * @dev The signature derives the `address(0)`.
     */
    error ECDSAInvalidSignature();

    /**
     * @dev The signature has an invalid length.
     */
    error ECDSAInvalidSignatureLength(uint256 length);

    /**
     * @dev The signature has an S value that is in the upper half order.
     */
    error ECDSAInvalidSignatureS(bytes32 s);

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not
     * return address(0) without also returning an error description. Errors are documented using an enum (error type)
     * and a bytes32 providing additional information about the error.
     *
     * If no error is returned, then the address can be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function tryRecover(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly ("memory-safe") {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[ERC-2098 short signatures]
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        unchecked {
            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
            // We do not check for an overflow here since the shift operation results in 0 or 1.
            uint8 v = uint8((uint256(vs) >> 255) + 27);
            return tryRecover(hash, v, r, s);
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address recovered, RecoverError err, bytes32 errArg) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS, s);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature, bytes32(0));
        }

        return (signer, RecoverError.NoError, bytes32(0));
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);
        _throwError(error, errorArg);
        return recovered;
    }

    /**
     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.
     */
    function _throwError(RecoverError error, bytes32 errorArg) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSAInvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSAInvalidSignatureLength(uint256(errorArg));
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSAInvalidSignatureS(errorArg);
        }
    }
}

error SignatureLib__InvalidSignature(address, address);

library SignatureLib {
  /**
   * @notice Verifies a signature, throws if the signature is invalid or empty
   *
   * @param _signature - The signature to verify
   * @param _signer - The expected signer of the signature
   * @param _digest - The digest that was signed
   */
  function verify(Signature memory _signature, address _signer, bytes32 _digest) internal pure returns (bool) {
    address recovered = ECDSA.recover(_digest, _signature.v, _signature.r, _signature.s);
    require(_signer == recovered, SignatureLib__InvalidSignature(_signer, recovered));
    return true;
  }

  function isEmpty(Signature memory _signature) internal pure returns (bool) {
    return _signature.v == 0;
  }
}

function addTimestamp(Timestamp _a, Timestamp _b) pure returns (Timestamp) {
  return Timestamp.wrap(Timestamp.unwrap(_a) + Timestamp.unwrap(_b));
}

function subTimestamp(Timestamp _a, Timestamp _b) pure returns (Timestamp) {
  return Timestamp.wrap(Timestamp.unwrap(_a) - Timestamp.unwrap(_b));
}

function ltTimestamp(Timestamp _a, Timestamp _b) pure returns (bool) {
  return Timestamp.unwrap(_a) < Timestamp.unwrap(_b);
}

function gtTimestamp(Timestamp _a, Timestamp _b) pure returns (bool) {
  return Timestamp.unwrap(_a) > Timestamp.unwrap(_b);
}

function lteTimestamp(Timestamp _a, Timestamp _b) pure returns (bool) {
  return Timestamp.unwrap(_a) <= Timestamp.unwrap(_b);
}

function gteTimestamp(Timestamp _a, Timestamp _b) pure returns (bool) {
  return Timestamp.unwrap(_a) >= Timestamp.unwrap(_b);
}

function neqTimestamp(Timestamp _a, Timestamp _b) pure returns (bool) {
  return Timestamp.unwrap(_a) != Timestamp.unwrap(_b);
}

function eqTimestamp(Timestamp _a, Timestamp _b) pure returns (bool) {
  return Timestamp.unwrap(_a) == Timestamp.unwrap(_b);
}

using {
  addTimestamp as +,
  subTimestamp as -,
  ltTimestamp as <,
  gtTimestamp as >,
  lteTimestamp as <=,
  gteTimestamp as >=,
  neqTimestamp as !=,
  eqTimestamp as ==
} for Timestamp global;

type Timestamp is uint256;

type CompressedTimestamp is uint32;

function eqSlot(Slot _a, Slot _b) pure returns (bool) {
  return Slot.unwrap(_a) == Slot.unwrap(_b);
}

function neqSlot(Slot _a, Slot _b) pure returns (bool) {
  return Slot.unwrap(_a) != Slot.unwrap(_b);
}

function gteSlot(Slot _a, Slot _b) pure returns (bool) {
  return Slot.unwrap(_a) >= Slot.unwrap(_b);
}

function gtSlot(Slot _a, Slot _b) pure returns (bool) {
  return Slot.unwrap(_a) > Slot.unwrap(_b);
}

function lteSlot(Slot _a, Slot _b) pure returns (bool) {
  return Slot.unwrap(_a) <= Slot.unwrap(_b);
}

function ltSlot(Slot _a, Slot _b) pure returns (bool) {
  return Slot.unwrap(_a) < Slot.unwrap(_b);
}

// Slot

function addSlot(Slot _a, Slot _b) pure returns (Slot) {
  return Slot.wrap(Slot.unwrap(_a) + Slot.unwrap(_b));
}

function subSlot(Slot _a, Slot _b) pure returns (Slot) {
  return Slot.wrap(Slot.unwrap(_a) - Slot.unwrap(_b));
}

using {
  eqSlot as ==,
  neqSlot as !=,
  gteSlot as >=,
  gtSlot as >,
  lteSlot as <=,
  ltSlot as <,
  addSlot as +,
  subSlot as -
} for Slot global;

type Slot is uint256;

type CompressedSlot is uint32;

function addEpoch(Epoch _a, Epoch _b) pure returns (Epoch) {
  return Epoch.wrap(Epoch.unwrap(_a) + Epoch.unwrap(_b));
}

function subEpoch(Epoch _a, Epoch _b) pure returns (Epoch) {
  return Epoch.wrap(Epoch.unwrap(_a) - Epoch.unwrap(_b));
}

// Epoch

function eqEpoch(Epoch _a, Epoch _b) pure returns (bool) {
  return Epoch.unwrap(_a) == Epoch.unwrap(_b);
}

function neqEpoch(Epoch _a, Epoch _b) pure returns (bool) {
  return Epoch.unwrap(_a) != Epoch.unwrap(_b);
}

function gteEpoch(Epoch _a, Epoch _b) pure returns (bool) {
  return Epoch.unwrap(_a) >= Epoch.unwrap(_b);
}

function gtEpoch(Epoch _a, Epoch _b) pure returns (bool) {
  return Epoch.unwrap(_a) > Epoch.unwrap(_b);
}

function lteEpoch(Epoch _a, Epoch _b) pure returns (bool) {
  return Epoch.unwrap(_a) <= Epoch.unwrap(_b);
}

function ltEpoch(Epoch _a, Epoch _b) pure returns (bool) {
  return Epoch.unwrap(_a) < Epoch.unwrap(_b);
}

using {
  addEpoch as +,
  subEpoch as -,
  eqEpoch as ==,
  neqEpoch as !=,
  gteEpoch as >=,
  gtEpoch as >,
  lteEpoch as <=,
  ltEpoch as <
} for Epoch global;

type Epoch is uint256;

type CompressedEpoch is uint32;

library CompressedTimeMath {
  function compress(Timestamp _timestamp) internal pure returns (CompressedTimestamp) {
    return CompressedTimestamp.wrap(SafeCast.toUint32(Timestamp.unwrap(_timestamp)));
  }

  function compress(Slot _slot) internal pure returns (CompressedSlot) {
    return CompressedSlot.wrap(SafeCast.toUint32(Slot.unwrap(_slot)));
  }

  function compress(Epoch _epoch) internal pure returns (CompressedEpoch) {
    return CompressedEpoch.wrap(SafeCast.toUint32(Epoch.unwrap(_epoch)));
  }

  function decompress(CompressedTimestamp _ts) internal pure returns (Timestamp) {
    return Timestamp.wrap(uint256(CompressedTimestamp.unwrap(_ts)));
  }

  function decompress(CompressedSlot _slot) internal pure returns (Slot) {
    return Slot.wrap(uint256(CompressedSlot.unwrap(_slot)));
  }

  function decompress(CompressedEpoch _epoch) internal pure returns (Epoch) {
    return Epoch.wrap(uint256(CompressedEpoch.unwrap(_epoch)));
  }
}

function addSlashRound(SlashRound _a, SlashRound _b) pure returns (SlashRound) {
  return SlashRound.wrap(SlashRound.unwrap(_a) + SlashRound.unwrap(_b));
}

function subSlashRound(SlashRound _a, SlashRound _b) pure returns (SlashRound) {
  return SlashRound.wrap(SlashRound.unwrap(_a) - SlashRound.unwrap(_b));
}

function eqSlashRound(SlashRound _a, SlashRound _b) pure returns (bool) {
  return SlashRound.unwrap(_a) == SlashRound.unwrap(_b);
}

function neqSlashRound(SlashRound _a, SlashRound _b) pure returns (bool) {
  return SlashRound.unwrap(_a) != SlashRound.unwrap(_b);
}

function ltSlashRound(SlashRound _a, SlashRound _b) pure returns (bool) {
  return SlashRound.unwrap(_a) < SlashRound.unwrap(_b);
}

function lteSlashRound(SlashRound _a, SlashRound _b) pure returns (bool) {
  return SlashRound.unwrap(_a) <= SlashRound.unwrap(_b);
}

function gtSlashRound(SlashRound _a, SlashRound _b) pure returns (bool) {
  return SlashRound.unwrap(_a) > SlashRound.unwrap(_b);
}

function gteSlashRound(SlashRound _a, SlashRound _b) pure returns (bool) {
  return SlashRound.unwrap(_a) >= SlashRound.unwrap(_b);
}

using {
  addSlashRound as +,
  subSlashRound as -,
  eqSlashRound as ==,
  neqSlashRound as !=,
  ltSlashRound as <,
  lteSlashRound as <=,
  gtSlashRound as >,
  gteSlashRound as >=
} for SlashRound global;

type SlashRound is uint256;

type CompressedSlashRound is uint32;

library CompressedSlashRoundMath {
  function compress(SlashRound _round) internal pure returns (CompressedSlashRound) {
    return CompressedSlashRound.wrap(SafeCast.toUint32(SlashRound.unwrap(_round)));
  }

  function decompress(CompressedSlashRound _round) internal pure returns (SlashRound) {
    return SlashRound.wrap(uint256(CompressedSlashRound.unwrap(_round)));
  }
}

/**
 * @title Status
 *
 * @notice The status of an escape hatch candidate
 *
 * @param NONE - The candidate has never joined or has fully exited
 * @param ACTIVE - The candidate is in the active set and may be selected
 * @param PROPOSING - The candidate has been selected as designated proposer for a hatch
 * @param EXITING - The candidate is exiting and waiting for the exit delay to pass
 */
enum Status {
  NONE,
  ACTIVE,
  PROPOSING,
  EXITING
}

function addHatch(Hatch _a, Hatch _b) pure returns (Hatch) {
  return Hatch.wrap(Hatch.unwrap(_a) + Hatch.unwrap(_b));
}

function subHatch(Hatch _a, Hatch _b) pure returns (Hatch) {
  return Hatch.wrap(Hatch.unwrap(_a) - Hatch.unwrap(_b));
}

using {addHatch as +, subHatch as -} for Hatch global;

/**
 * @title Hatch
 *
 * @notice A time unit representing a potential escape hatch opening.
 *         Similar to Epoch, but at a coarser granularity.
 */
type Hatch is uint256;

/**
 * @title Errors Library
 * @author Aztec Labs
 * @notice Library that contains errors used throughout the Aztec protocol
 * Errors are prefixed with the contract name to make it easy to identify where the error originated
 * when there are multiple contracts that could have thrown the error.
 *
 * Sigs are provided for easy reference, but don't trust; verify! run `forge inspect
 * src/core/libraries/Errors.sol:Errors errors`
 */
library Errors_1 {
  // DEVNET related
  error DevNet__NoPruningAllowed(); // 0x6984c590
  error DevNet__InvalidProposer(address expected, address actual); // 0x11e6e6f7

  // Inbox
  error Inbox__Unauthorized(); // 0xe5336a6b
  error Inbox__ActorTooLarge(bytes32 actor); // 0xa776a06e
  error Inbox__VersionMismatch(uint256 expected, uint256 actual); // 0x47452014
  error Inbox__ContentTooLarge(bytes32 content); // 0x47452014
  error Inbox__SecretHashTooLarge(bytes32 secretHash); // 0xecde7e2c
  error Inbox__MustBuildBeforeConsume(); // 0xc4901999

  // Outbox
  error Outbox__Unauthorized(); // 0x2c9490c2
  error Outbox__InvalidChainId(); // 0x577ec7c4
  error Outbox__VersionMismatch(uint256 expected, uint256 actual);
  error Outbox__NothingToConsume(bytes32 messageHash); // 0xfb4fb506
  error Outbox__IncompatibleEntryArguments(
    bytes32 messageHash,
    uint64 storedFee,
    uint64 feePassed,
    uint32 storedVersion,
    uint32 versionPassed,
    uint32 storedDeadline,
    uint32 deadlinePassed
  ); // 0x5e789f34
  error Outbox__InvalidRecipient(address expected, address actual); // 0x57aad581
  error Outbox__AlreadyNullified(Epoch epoch, uint256 leafIndex); // 0xfd71c2d4
  error Outbox__NothingToConsumeAtEpoch(Epoch epoch); // 0x5e3d32ce
  error Outbox__PathTooLong();
  error Outbox__LeafIndexOutOfBounds(uint256 leafIndex, uint256 pathLength);
  error Outbox__InvalidNumCheckpointsInEpoch(uint256 numCheckpointsInEpoch);

  // Rollup
  error Rollup__InsufficientBondAmount(uint256 minimum, uint256 provided); // 0xa165f276
  error Rollup__InsufficientFundsInEscrow(uint256 required, uint256 available); // 0xa165f276
  error Rollup__InvalidArchive(bytes32 expected, bytes32 actual); // 0xb682a40e
  error Rollup__InvalidCheckpointHeader(bytes32 expected, bytes32 actual);
  error Rollup__InvalidCheckpointHeaderCount(uint256 expected, uint256 actual);
  error Rollup__InvalidCheckpointNumber(uint256 expected, uint256 actual); // 0xd1ba9bfa
  error Rollup__InvalidInHash(bytes32 expected, bytes32 actual); // 0xcd6f4233
  error Rollup__InvalidOutHash(bytes32 expected, bytes32 actual); // 0x8eb39062
  error Rollup__InvalidPreviousArchive(bytes32 expected, bytes32 actual); // 0xb682a40e
  error Rollup__InvalidProof(); // 0xa5b2ba17
  error Rollup__InvalidProposedArchive(bytes32 expected, bytes32 actual); // 0x32532e73
  error Rollup__InvalidTimestamp(Timestamp expected, Timestamp actual); // 0x3132e895
  error Rollup__InvalidAttestations();
  error Rollup__AttestationsAreValid();
  error Rollup__InvalidAttestationIndex();
  error Rollup__CheckpointAlreadyProven();
  error Rollup__CheckpointNotInPendingChain();
  error Rollup__InvalidBlobHash(bytes32 expected, bytes32 actual); // 0x13031e6a
  error Rollup__InvalidBlobProof(bytes32 blobHash); // 0x5ca17bef
  error Rollup__NoEpochToProve(); // 0xcbaa3951
  error Rollup__NonSequentialProving(); // 0x1e5be132
  error Rollup__NothingToPrune(); // 0x850defd3
  error Rollup__SlotAlreadyInChain(Slot lastSlot, Slot proposedSlot); // 0x83510bd0
  error Rollup__TimestampInFuture(Timestamp max, Timestamp actual); // 0x89f30690
  error Rollup__TimestampTooOld(); // 0x72ed9c81
  error Rollup__TryingToProveNonExistingCheckpoint(); // 0xdd65748c
  error Rollup__UnavailableTxs(bytes32 txsHash); // 0x414906c3
  error Rollup__NonZeroDaFee(); // 0xd9c75f52
  error Rollup__InvalidBasisPointFee(uint256 basisPointFee); // 0x4292d136
  error Rollup__InvalidManaMinFee(uint256 expected, uint256 actual); // 0x73b6d896
  error Rollup__StartAndEndNotSameEpoch(Epoch start, Epoch end); // 0xb64ec33e
  error Rollup__StartIsNotFirstCheckpointOfEpoch(); // 0x19ceb206
  error Rollup__StartIsNotBuildingOnProven(); // 0x4a59f42e
  error Rollup__TooManyCheckpointsInEpoch(uint256 expected, uint256 actual); // 0xdf838503
  error Rollup__NotPastDeadline(Epoch deadline, Epoch currentEpoch);
  error Rollup__PastDeadline(Epoch deadline, Epoch currentEpoch);
  error Rollup__ProverHaveAlreadySubmitted(address prover, Epoch epoch);
  error Rollup__InvalidManaTarget(uint256 minimum, uint256 provided);
  error Rollup__ManaLimitExceeded();
  error Rollup__InvalidFirstEpochProof();
  error Rollup__InvalidCoinbase();
  error Rollup__UnavailableTempCheckpointLog(
    uint256 checkpointNumber, uint256 pendingCheckpointNumber, uint256 upperLimit
  );
  error Rollup__NoBlobsInCheckpoint();
  error Rollup__CannotInvalidateEscapeHatch();
  error Rollup__InvalidEscapeHatchProposer(address expected, address actual);
  error Rollup__FieldElementOutOfRange(bytes32 value);

  // EscapeHatch
  error EscapeHatch__AlreadyInCandidateSet(address candidate);
  error EscapeHatch__NotInCandidateSet(address candidate);
  error EscapeHatch__InvalidStatus(Status expected, Status actual);
  error EscapeHatch__NotExitableYet(uint256 exitableAt, uint256 currentTime);
  error EscapeHatch__OnlyRollup(address caller, address rollup);
  error EscapeHatch__NoDesignatedProposer(Hatch hatch);
  error EscapeHatch__InvalidConfiguration();
  error EscapeHatch__SetUnstable(Hatch hatch);
  error EscapeHatch__AlreadyValidated(Hatch hatch);
  error EscapeHatch__HatchTooEarly(Hatch hatch);

  // ProposedHeaderLib
  error HeaderLib__InvalidHeaderSize(uint256 expected, uint256 actual); // 0xf3ccb247
  error HeaderLib__InvalidSlotNumber(Slot expected, Slot actual); // 0x09ba91ff

  // MerkleLib
  error MerkleLib__InvalidRoot(bytes32 expected, bytes32 actual, bytes32 leaf, uint256 leafIndex); // 0x5f216bf1
  error MerkleLib__InvalidIndexForPathLength();

  // SampleLib
  error SampleLib__IndexOutOfBounds(uint256 requested, uint256 bound); // 0xa12fc559
  error SampleLib__SampleLargerThanIndex(uint256 sample, uint256 index); // 0xa11b0f79

  // Sequencer Selection (ValidatorSelection)
  error ValidatorSelection__EpochNotSetup(); // 0x10816cae
  error ValidatorSelection__InvalidProposer(address expected, address actual); // 0xa8843a68
  error ValidatorSelection__MissingProposerSignature(address proposer, uint256 index);
  error ValidatorSelection__InvalidDeposit(address attester, address proposer); // 0x533169bd
  error ValidatorSelection__InsufficientAttestations(uint256 minimumNeeded, uint256 provided); // 0xaf47297f
  error ValidatorSelection__InvalidCommitteeCommitment(bytes32 reconstructed, bytes32 expected); // 0xca8d5954
  error ValidatorSelection__InsufficientValidatorSetSize(uint256 actual, uint256 expected); // 0xf4f28e99
  error ValidatorSelection__ProposerIndexTooLarge(uint256 index);
  error ValidatorSelection__EpochNotStable(uint256 queriedEpoch, uint32 currentTimestamp);
  error ValidatorSelection__InvalidLagInEpochs(uint256 lagInEpochsForValidatorSet, uint256 lagInEpochsForRandao);
  error ValidatorSelection__EscapeHatchAlreadySet();
  error ValidatorSelection__EscapeHatchCannotBeZero();
  error ValidatorSelection__EscapeHatchRollupMismatch(address expected, address actual);

  // Staking
  error Staking__AlreadyQueued(address _attester);
  error Staking__QueueEmpty();
  error Staking__DepositOutOfGas();
  error Staking__AlreadyActive(address attester); // 0x5e206fa4
  error Staking__QueueAlreadyFlushed(Epoch epoch); // 0x21148c78
  error Staking__AlreadyRegistered(address instance, address attester);
  error Staking__CannotSlashExitedStake(address); // 0x45bf4940
  error Staking__FailedToRemove(address); // 0xa7d7baab
  error Staking__InvalidDeposit(address attester, address proposer); // 0xf33fe8c6
  error Staking__InvalidRecipient(address); // 0x7e2f7f1c
  error Staking__InsufficientStake(uint256, uint256); // 0x903aee24
  error Staking__NoOneToSlash(address); // 0x7e2f7f1c
  error Staking__NotExiting(address); // 0xef566ee0
  error Staking__InitiateWithdrawNeeded(address);
  error Staking__NotSlasher(address, address); // 0x23a6f432
  error Staking__NotWithdrawer(address, address); // 0x8e668e5d
  error Staking__NothingToExit(address); // 0xd2aac9b6
  error Staking__WithdrawalNotUnlockedYet(Timestamp, Timestamp); // 0x88e1826c
  error Staking__WithdrawFailed(address); // 0x377422c1
  error Staking__OutOfBounds(uint256, uint256); // 0x4bea6597
  error Staking__NotRollup(address); // 0xf5509eb3
  error Staking__RollupAlreadyRegistered(address); // 0x108a39c8
  error Staking__InvalidRollupAddress(address); // 0xd876720e
  error Staking__NotCanonical(address); // 0x6244212e
  error Staking__InstanceDoesNotExist(address);
  error Staking__InsufficientPower(uint256, uint256);
  error Staking__AlreadyExiting(address);
  error Staking__FatalError(string);
  error Staking__NotOurProposal(uint256, address, address);
  error Staking__IncorrectGovProposer(uint256);
  error Staking__GovernanceAlreadySet();
  error Staking__InsufficientBootstrapValidators(uint256 queueSize, uint256 bootstrapFlushSize);
  error Staking__InvalidStakingQueueConfig();
  error Staking__InvalidNormalFlushSizeQuotient();
  error Staking__InvalidMaxQueueFlushSize();
  error Staking__InvalidBootstrapFlushSize();
  error Staking__BootstrapFlushSizeAboveMax(uint256 bootstrapFlushSize, uint256 maxQueueFlushSize);
  error Staking__ExitDelayAboveSlasherDelay(uint256 exitDelaySeconds, uint256 slasherExecutionDelay);
  error Staking__SlasherProposerNotInitialized(address slasher);
  error Staking__NoPendingSlasher();
  error Staking__SlasherNotReady(Timestamp readyAt);

  // Fee Juice Portal
  error FeeJuicePortal__AlreadyInitialized(); // 0xc7a172fe
  error FeeJuicePortal__InvalidInitialization(); // 0xfd9b3208
  error FeeJuicePortal__Unauthorized(); // 0x67e3691e

  // Proof Commitment Escrow
  error ProofCommitmentEscrow__InsufficientBalance(uint256 balance, uint256 requested); // 0x09b8b789
  error ProofCommitmentEscrow__NotOwner(address caller); // 0x2ac332c1
  error ProofCommitmentEscrow__WithdrawRequestNotReady(uint256 current, Timestamp readyAt); // 0xb32ab8a7

  // FeeLib
  error FeeLib__InvalidFeeAssetPriceModifier(); // 0xf2fb32ad
  error FeeLib__AlreadyPreheated();
  error FeeLib__InvalidManaTarget(uint256 minimum, uint256 provided);
  error FeeLib__InvalidManaLimit(uint256 maximum, uint256 provided);
  error FeeLib__InvalidInitialEthPerFeeAsset(uint256 provided, uint256 minimum, uint256 maximum);
  error FeeLib__ProvingCostBelowFloor(uint256 provided, uint256 minimum);
  error FeeLib__ProvingCostAboveCeiling(uint256 provided, uint256 maximum);
  error FeeLib__ProvingCostCooldown(uint256 nextAllowed);
  error FeeLib__ProvingCostStepExceeded(uint256 current, uint256 requested);

  // SignatureLib (duplicated)
  error SignatureLib__InvalidSignature(address, address); // 0xd9cbae6c

  error AttestationLib__InvalidDataSize(uint256, uint256);
  error AttestationLib__SignatureIndicesSizeMismatch(uint256, uint256);
  error AttestationLib__SignaturesOrAddressesSizeMismatch(uint256, uint256);
  error AttestationLib__SignersSizeMismatch(uint256, uint256);
  error AttestationLib__NotASignatureAtIndex(uint256 index);
  error AttestationLib__NotAnAddressAtIndex(uint256 index);

  // RewardBooster
  error RewardBooster__OnlyRollup(address caller);
  error RewardBooster__InvalidConfig();

  error RewardLib__InvalidSequencerBps();
  error RewardLib__ZeroShares(address prover);

  // SlashingProposer
  error SlashingProposer__InvalidSignature();
  error SlashingProposer__InvalidVoteLength(uint256 expected, uint256 actual);
  error SlashingProposer__RoundAlreadyExecuted(SlashRound round);
  error SlashingProposer__InvalidNumberOfCommittees(uint256 expected, uint256 actual);
  error SlashingProposer__RoundNotComplete(SlashRound round);
  error SlashingProposer__InvalidCommitteeSize(uint256 expected, uint256 actual);
  error SlashingProposer__InvalidCommitteeCommitment();
  error SlashingProposer__InvalidQuorumAndRoundSize(uint256 quorum, uint256 roundSize);
  error SlashingProposer__QuorumMustBeGreaterThanZero();
  error SlashingProposer__InvalidSlashAmounts(uint256[3] slashAmounts);
  error SlashingProposer__LifetimeMustBeGreaterThanExecutionDelay(uint256 lifetime, uint256 executionDelay);
  error SlashingProposer__LifetimeMustBeLessThanRoundabout(uint256 lifetime, uint256 roundabout);
  error SlashingProposer__RoundSizeInEpochsMustBeGreaterThanZero(uint256 roundSizeInEpochs);
  error SlashingProposer__RoundSizeTooLarge(uint256 roundSize, uint256 maxRoundSize);
  error SlashingProposer__CommitteeSizeMustBeGreaterThanZero(uint256 committeeSize);
  error SlashingProposer__SlashAmountTooLarge();
  error SlashingProposer__VoteAlreadyCastInCurrentSlot(Slot slot);
  error SlashingProposer__RoundOutOfRange(SlashRound round, SlashRound currentRound);
  error SlashingProposer__RoundSizeMustBeMultipleOfEpochDuration(uint256 roundSize, uint256 epochDuration);
  error SlashingProposer__VotingNotOpen(SlashRound currentRound);
  error SlashingProposer__SlashOffsetMustBeGreaterThanZero(uint256 slashOffset);
  error SlashingProposer__InvalidEpochIndex(uint256 epochIndex, uint256 roundSizeInEpochs);
  error SlashingProposer__VoteSizeTooBig(uint256 voteSize, uint256 maxSize);
  error SlashingProposer__VotesMustBeMultipleOf4(uint256 votes);
  error SlashingProposer__SlashAmountMustBeGtZero(string info);

  // SlashPayloadLib
  error SlashPayload_ArraySizeMismatch(uint256 expected, uint256 actual);

  // OpenZeppelin dependencies

  // ECDSA
  error ECDSAInvalidSignature();
  error ECDSAInvalidSignatureLength(uint256 length);
  error ECDSAInvalidSignatureS(bytes32 s);

  // Ownable
  error OwnableUnauthorizedAccount(address account);
  error OwnableInvalidOwner(address owner);

  // Checkpoints
  error CheckpointUnorderedInsertion();

  // ERC20
  error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
  error ERC20InvalidSender(address sender);
  error ERC20InvalidReceiver(address receiver);
  error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
  error ERC20InvalidApprover(address approver);
  error ERC20InvalidSpender(address spender);

  // SafeCast
  error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);
  error SafeCastOverflowedIntToUint(int256 value);
  error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);
  error SafeCastOverflowedUintToInt(uint256 value);
}

/**
 * @title SlashPayloadLib
 * @author Aztec Labs
 * @notice Library for encoding immutable arguments for SlashPayloadCloneable contracts
 * @dev Provides utilities for encoding validator addresses and amounts into a format
 *      suitable for use with EIP-1167 minimal proxy clones with immutable arguments
 */
library SlashPayloadLib {
  /**
   * @notice Encode immutable arguments for SlashPayloadCloneable clones
   * @dev Encodes data in the format expected by SlashPayloadCloneable._getImmutableArgs()
   *      Layout: [validatorSelection(20 bytes)][arrayLength(32 bytes)][validators+amounts array data]
   *      Each validator entry: [address(20 bytes)][amount(12 bytes for uint96)]
   * @param _validatorSelection Address of the validator selection contract
   * @param _validators Array of validator addresses to slash
   * @param _amounts Array of amounts to slash for each validator (uint96 values)
   * @return Encoded arguments for use with cloneDeterministicWithImmutableArgs
   */
  function encodeImmutableArgs(address _validatorSelection, address[] memory _validators, uint96[] memory _amounts)
    internal
    pure
    returns (bytes memory)
  {
    require(
      _validators.length == _amounts.length, Errors_1.SlashPayload_ArraySizeMismatch(_validators.length, _amounts.length)
    );

    // Calculate total size: 20 bytes (address) + 32 bytes (length) + (20 + 12) * length
    uint256 dataSize = 52 + 32 * _validators.length;
    bytes memory data = new bytes(dataSize);

    assembly {
      let ptr := add(data, 0x20)

      // Store validator selection address (20 bytes)
      // Shift left by 96 bits (12 bytes) to align to the left of the 32-byte slot
      mstore(ptr, shl(96, _validatorSelection))
      ptr := add(ptr, 0x14) // Move 20 bytes forward

      // Store array length (32 bytes)
      mstore(ptr, mload(_validators))
      ptr := add(ptr, 0x20) // Move 32 bytes forward

      // Store validators and amounts
      let len := mload(_validators)
      let validatorsPtr := add(_validators, 0x20)
      let amountsPtr := add(_amounts, 0x20)

      for { let i := 0 } lt(i, len) { i := add(i, 1) } {
        // Store validator address (20 bytes)
        // Shift left by 96 bits to align to the left of the 32-byte slot
        mstore(ptr, shl(96, mload(add(validatorsPtr, mul(i, 0x20)))))
        ptr := add(ptr, 0x14) // Move 20 bytes forward

        // Store amount (12 bytes for uint96)
        // Shift left by 160 bits (20 bytes) to align to the left of the remaining space
        mstore(ptr, shl(160, mload(add(amountsPtr, mul(i, 0x20)))))
        ptr := add(ptr, 0x0c) // Move 12 bytes forward
      }
    }

    return data;
  }
}

interface ISlasher {
  event VetoedPayload(address indexed payload);
  event SlashingDisabled(uint256 disabledUntil);

  function slash(IPayload _payload) external returns (bool);
  function vetoPayload(IPayload _payload) external returns (bool);
  function setSlashingEnabled(bool _enabled) external;
  function isSlashingEnabled() external view returns (bool);
}

interface IValidatorSelectionCore {
  event EscapeHatchSet(address escapeHatch);

  function setupEpoch() external;
  function checkpointRandao() external;
  function setEscapeHatch(address _escapeHatch) external;
}

interface IEmperor {
  // Not view because it might rely on transient storage.
  // Calls are essentially trusted
  function getCurrentProposer() external returns (address);

  function getCurrentSlot() external view returns (Slot);
}

interface IEscapeHatchCore {
  event CandidateJoined(address indexed candidate);
  event CandidateExitInitiated(address indexed candidate, uint256 exitableAt);
  event CandidateExited(address indexed candidate, uint256 amountReturned);
  event CandidateSelected(Hatch indexed hatch, address indexed candidate);
  event ArchiveUpdated(address indexed proposer, uint128 checkpointNumber, bytes32 archive);
  event ProofValidated(Hatch indexed hatch, address indexed proposer, bool success, uint256 punishment);

  function joinCandidateSet() external;
  function initiateExit() external;
  function leaveCandidateSet() external;
  function selectCandidates() external;
  function updateSubmittedArchive(address _proposer, uint128 _checkpointNumber, bytes32 _archive) external;
  function validateProofSubmission(Hatch _hatch) external;
}

/**
 * @title CandidateInfo
 *
 * @notice Information about an escape hatch candidate
 */
struct CandidateInfo {
  Status status;
  uint96 amount;
  uint32 exitableAt;
  uint32 lastCheckpointNumber;
  bytes32 lastSubmittedArchive;
}

interface IEscapeHatch is IEscapeHatchCore {
  function isHatchOpen(Epoch _epoch) external view returns (bool isOpen, address proposer);
  function getCurrentHatch() external view returns (Hatch);
  function getHatch(Epoch _epoch) external view returns (Hatch);
  function getFirstEpoch(Hatch _hatch) external view returns (Epoch);
  function getDesignatedProposer(Hatch _hatch) external view returns (address);
  function isHatchPrepared(Hatch _hatch) external view returns (bool);
  function isHatchValidated(Hatch _hatch) external view returns (bool);
  function getCandidateInfo(address _candidate) external view returns (CandidateInfo memory);
  function getCandidateCount() external view returns (uint256);
  function getCandidateCountForHatch(Hatch _hatch) external view returns (uint256);
  function getCandidateAtIndex(uint256 _index) external view returns (address);
  function getCandidateAtIndexForHatch(uint256 _index, Hatch _hatch) external view returns (address);
  function isCandidate(address _candidate) external view returns (bool);
  function getSetTimestamp(Hatch _hatch) external view returns (uint32);
  function getSeedTimestamp(Hatch _hatch) external view returns (uint32);
  function getRollup() external view returns (address);
  function getBondToken() external view returns (address);
  function getBondSize() external view returns (uint96);
  function getWithdrawalTax() external view returns (uint96);
  function getFailedHatchPunishment() external view returns (uint96);
  function getFrequency() external view returns (uint256);
  function getActiveDuration() external view returns (uint256);
  function getLagInHatches() external view returns (uint256);
  function getProposingExitDelay() external view returns (uint256);
}

interface IValidatorSelection is IValidatorSelectionCore, IEmperor {
  function getProposerAt(Timestamp _ts) external returns (address);

  // Non view as uses transient storage
  function getCurrentEpochCommittee() external returns (address[] memory);
  function getCommitteeAt(Timestamp _ts) external returns (address[] memory);
  function getCommitteeCommitmentAt(Timestamp _ts) external returns (bytes32, uint256);
  function getEpochCommittee(Epoch _epoch) external returns (address[] memory);
  function getEpochCommitteeCommitment(Epoch _epoch) external returns (bytes32, uint256);

  // Stable
  function getCurrentEpoch() external view returns (Epoch);

  // Consider removing below this point
  function getTimestampForSlot(Slot _slotNumber) external view returns (Timestamp);
  function getTimestampForEpoch(Epoch _epoch) external view returns (Timestamp);

  function getSampleSeedAt(Timestamp _ts) external view returns (uint256);
  function getSamplingSizeAt(Timestamp _ts) external view returns (uint256);
  function getLagInEpochsForValidatorSet() external view returns (uint256);
  function getLagInEpochsForRandao() external view returns (uint256);
  function getCurrentSampleSeed() external view returns (uint256);

  function getEpochAt(Timestamp _ts) external view returns (Epoch);
  function getSlotAt(Timestamp _ts) external view returns (Slot);
  function getEpochAtSlot(Slot _slotNumber) external view returns (Epoch);

  function getGenesisTime() external view returns (Timestamp);
  function getSlotDuration() external view returns (uint256);
  function getEpochDuration() external view returns (uint256);
  function getTargetCommitteeSize() external view returns (uint256);

  function getEscapeHatch() external view returns (IEscapeHatch);
  function getEscapeHatchForEpoch(Epoch _epoch) external view returns (IEscapeHatch);
}

/**
 * @title SlashingProposer
 * @author Aztec Labs
 * @notice Slashing proposer that aggregates validator votes to determine which validators should be
 * slashed
 *
 * @dev This contract implements a voting-based slashing mechanism where checkpoint proposers signal their intent to
 *      slash validators from past epochs. The system operates in rounds, with each round corresponding to a time period
 *      where votes are collected from proposers to determine which validators should be slashed.
 *
 *      Key concepts:
 *      - Rounds: Time periods during which votes are collected (measured in slots, multiple of epochs)
 *      - Voting: Checkpoint proposers submit encoded votes indicating which validators to slash and by how much
 *      - Quorum: Minimum number of votes required in a round to trigger slashing of a specific validator
 *      - Execution Delay: Time that must pass after a round ends before its slashing can be executed (allows vetoing)
 *      - Slash Offset: How many rounds in the past to look when determining which validators to slash
 *
 *      How the system works:
 *      1. Time is divided into rounds (ROUND_SIZE slots each).
 *      2. During each round, checkpoint proposers can submit votes indicating which validators from the epochs that
 *         span SLASH_OFFSET_IN_ROUNDS rounds ago should be slashed.
 *      3. Votes are encoded as bytes where each 2-bit pair represents the slash amount (0-3 slash units) for
 *         the corresponding validator slashed in the round.
 *      4. After a round ends, there is an execution delay period for review so the VETOER in the Slasher can veto the
 *         expected payload address if needed.
 *      5. Once the delay passes, anyone can call executeRound() to tally votes and execute slashing.
 *      6. Validators that reach the quorum threshold are slashed by the specified amount. We consider a vote for
 *         slashing N units as also a vote for slashing N-1, N-2, ..., 1 units. We slash for the largest amount that
 *         reaches quorum.
 *
 *      About SLASH_OFFSET_IN_ROUNDS:
 *      - This offset gives us time to detect an offense and then vote on it in a later
 *        round. For instance, a `DATA_WITHHOLDING` offense for slot S is only triggered after
 *        `DATA_WITHHOLDING_TOLERANCE_SLOTS` slots. Consider:
 *        - Slot S publishes a checkpoint
 *        - At slot S + tolerance, observers find missing data and want to slash the attesters
 *        - Voting on that slash needs to happen in a round that starts after detection
 *      - In terms of voting, this parameter means that in round R we are voting for the committee of epochs starting
 *        from (R - SLASH_OFFSET_IN_ROUNDS) * ROUND_SIZE_IN_EPOCHS.
 *      - For example, with SLASH_OFFSET_IN_ROUNDS=2, ROUND_SIZE=10, and EPOCH_DURATION=2
 *        - In round 4, we are voting for the committee of epochs starting from (4 - 2) * 10 = 20 (i.e., epochs 20-29)
 *
 *      Considerations:
 *      - Only the designated proposer for each slot can submit votes
 *      - Votes are signed using EIP-712
 *      - Votes include slot numbers to prevent replay attacks
 *      - Committee commitments are verified against onchain data
 *      - Rounds have a lifetime limit
 *      - Uses circular storage to limit memory usage while maintaining recent round data
 *
 *      Integration with Aztec system:
 *      - Connects to the main Rollup contract (INSTANCE) to get proposer information and committee data
 *      - Uses the Slasher contract to execute actual slashing operations
 *      - Coordinates with validator selection of the Rollup instance to identify which validators should be slashed
 *      - Supports the Rollup's security model by enabling punishment of misbehaving validators
 *
 *      Parameters and configuration:
 *      - QUORUM: Minimum votes needed to slash a validator
 *      - ROUND_SIZE: Number of slots per voting round
 *      - EXECUTION_DELAY_IN_ROUNDS: Rounds to wait before allowing execution
 *      - LIFETIME_IN_ROUNDS: Maximum age of rounds that can still be executed
 *      - SLASH_OFFSET_IN_ROUNDS: How far back to look for validators to slash
 *      - SLASH_AMOUNT_SMALL/MEDIUM/LARGE: Specific amounts for each slash unit level
 *      - COMMITTEE_SIZE: Number of validators per committee
 */
contract SlashingProposer is EIP712 {
  using SignatureLib for Signature;
  using CompressedTimeMath for CompressedSlot;
  using CompressedTimeMath for Slot;
  using CompressedSlashRoundMath for CompressedSlashRound;
  using CompressedSlashRoundMath for SlashRound;
  using Clones for address;
  using SlashPayloadLib for address[];

  /**
   * @notice Contains metadata about a slashing round stored in uncompressed format
   * @dev Used for in-memory operations and as the return type for getRoundData()
   * @param roundNumber The actual round number (used to detect stale data in circular storage)
   * @param voteCount Number of votes collected in this round so far
   * @param lastVoteSlot The most recent slot in which a vote was cast for this round
   * @param executed Whether this round has been executed and slashing has occurred
   */
  struct RoundData {
    SlashRound roundNumber;
    uint256 voteCount;
    Slot lastVoteSlot;
    bool executed;
  }

  /**
   * @notice Compressed version of RoundData optimized for storage efficiency (fits in 32 bytes)
   * @dev Used in the circular storage buffer to minimize gas costs for storage operations
   * @param roundNumber Compressed round number for staleness detection
   * @param lastVoteSlot Compressed slot number of the last vote
   * @param voteCount Number of votes (max 65535, must fit MAX_ROUND_SIZE constraint)
   * @param executed Whether this round has been executed
   */
  struct CompressedRoundData {
    CompressedSlashRound roundNumber;
    CompressedSlot lastVoteSlot;
    uint16 voteCount;
    bool executed;
  }

  /**
   * @notice Contains all vote data for a single round
   * @dev Stores up to MAX_ROUND_SIZE votes as fixed-size arrays. Each vote encodes slash amounts
   *      for all validators in the round using 2 bits per validator.
   * @param votes Array of encoded vote data, one entry per proposer vote in the round
   *         Each vote is stored as fixed-size bytes32 chunks, to avoid the overhead of an extra SLOAD/SSTORE operation
   *         just to load/write the length of the array, which we already know.
   *         Vote size = COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS / 4 bytes
   *         Number of bytes32 slots needed = ceil(voteSize / 32)
   *         Note that we check the vote size in the constructor to avoid issues
   */
  struct RoundVotes {
    bytes32[4][1024] votes; // Assuming max 4 slots (128 bytes) per vote
  }

  /**
   * @notice Represents a slashing action to be executed against a specific validator
   * @dev Used to package slashing decisions for execution by the Slasher contract
   * @param validator The address of the validator to be slashed
   * @param slashAmount The amount of stake to slash from the validator (in wei)
   */
  struct SlashAction {
    address validator;
    uint256 slashAmount;
  }

  /**
   * @notice EIP-712 type hash for the Vote struct used in signature verification
   * @dev Defines the structure: Vote(bytes votes,uint256 slot) for EIP-712 signing
   */
  bytes32 public constant VOTE_TYPEHASH = keccak256("Vote(bytes votes,uint256 slot)");

  /**
   * @notice Size of the circular storage buffer for round data
   * @dev Determines how many recent rounds can be kept in storage simultaneously.
   *      Older rounds are overwritten as new rounds are created. Must be larger than
   *      LIFETIME_IN_ROUNDS to prevent data corruption.
   */
  uint256 public constant ROUNDABOUT_SIZE = 128;

  /**
   * @notice Maximum number of votes that can be cast in a single round
   * @dev Hard limit to prevent excessive gas usage and storage requirements.
   *      Also serves as the maximum number of slots per round.
   */
  uint256 public constant MAX_ROUND_SIZE = 1024;

  /**
   * @notice Address of the main rollup contract that this slashing proposer integrates with
   * @dev Used to query current proposers, committee data, and slot information
   */
  address public immutable INSTANCE;

  /**
   * @notice The slasher contract that executes actual slashing operations
   * @dev Receives SlashPayload contracts from this proposer to perform validator punishment
   */
  ISlasher public immutable SLASHER;

  /**
   * @notice The implementation contract for SlashPayload clones
   * @dev Single instance deployed once and used as template for all slash payload clones
   */
  address public immutable SLASH_PAYLOAD_IMPLEMENTATION;

  /**
   * @notice Base amount of stake to slash per slashing unit (in wei)
   * @dev Validators can be voted to be slashed by 1-3 units, multiplied by this base amount
   * @notice Small slash amount for 1 unit votes (in wei)
   */
  uint256 public immutable SLASH_AMOUNT_SMALL;

  /**
   * @notice Medium slash amount for 2 unit votes (in wei)
   */
  uint256 public immutable SLASH_AMOUNT_MEDIUM;

  /**
   * @notice Large slash amount for 3 unit votes (in wei)
   */
  uint256 public immutable SLASH_AMOUNT_LARGE;

  /**
   * @notice Minimum number of votes required to slash a validator
   * @dev Must be greater than ROUND_SIZE/2 to ensure majority agreement
   */
  uint256 public immutable QUORUM;

  /**
   * @notice Number of slots per slashing round
   * @dev Determines the duration of voting periods and must be a multiple of epoch duration
   */
  uint256 public immutable ROUND_SIZE;

  /**
   * @notice Number of validators per committee
   * @dev Used to determine vote encoding length and validator indexing
   */
  uint256 public immutable COMMITTEE_SIZE;

  /**
   * @notice Number of epochs per slashing round
   * @dev Calculated as ROUND_SIZE / epoch duration, determines how many committees are voted on per round
   */
  uint256 public immutable ROUND_SIZE_IN_EPOCHS;

  /**
   * @notice Maximum age in rounds for which a round can still be executed
   * @dev Prevents execution of very old rounds that may no longer be relevant
   */
  uint256 public immutable LIFETIME_IN_ROUNDS;

  /**
   * @notice Number of rounds to wait after a round ends before it can be executed
   * @dev Provides time for review and potential challenges before slashing occurs
   */
  uint256 public immutable EXECUTION_DELAY_IN_ROUNDS;

  /**
   * @notice How many rounds in the past to look when determining which validators to slash
   * @dev During round N, we cannot slash the validators from the epochs of the same round, since the round is not over,
   * and besides we would be asking the current validators to vote to slash themselves. So during round N we look at the
   * epochs spanned during round N - SLASH_OFFSET_IN_ROUNDS. This offset means that the epochs we slash are complete,
   * and also gives nodes time to detect any misbehavior (eg slashing for prunes requires the proof submission window to
   * pass).
   */
  uint256 public immutable SLASH_OFFSET_IN_ROUNDS;

  // Circular mappings of round number to round data and votes
  CompressedRoundData[ROUNDABOUT_SIZE] private roundDatas;
  RoundVotes[ROUNDABOUT_SIZE] private roundVotes;

  /**
   * @notice Emitted when a proposer casts a vote in a slashing round
   * @param round The round number in which the vote was cast
   * @param proposer The address of the proposer who cast the vote
   */
  event VoteCast(SlashRound indexed round, Slot indexed slot, address indexed proposer);

  /**
   * @notice Emitted when a slashing round is executed and validators are slashed
   * @param round The round number that was executed
   * @param slashCount The number of validators that were slashed in this round
   */
  event RoundExecuted(SlashRound indexed round, uint256 slashCount);

  /**
   * @notice Initializes the SlashingProposer with configuration parameters
   * @dev Sets up all the voting and slashing parameters and validates their correctness.
   *      The constructor enforces several important invariants to ensure the system operates correctly.
   *
   * @param _instance The address of the rollup contract that this slashing proposer will interact with
   * @param _slasher The slasher contract that will execute the actual slashing operations
   * @param _quorum The minimum number of votes required to slash a validator (must be > ROUND_SIZE/2 and <= ROUND_SIZE)
   * @param _roundSize The number of slots in each voting round (must be > 1 and < MAX_ROUND_SIZE)
   * @param _lifetimeInRounds The maximum age in rounds for which a round can still be executed (must be >
   * _executionDelayInRounds and < ROUNDABOUT_SIZE)
   * @param _executionDelayInRounds The number of rounds to wait after a round ends before it can be executed (provides
   * time for review)
   * @param _slashAmounts Array of 3 slash amounts [small, medium, large] for 1, 2, 3 unit votes (all must be > 0)
   * @param _committeeSize The number of validators in each committee (must be > 0)
   * @param _epochDuration The number of slots in each epoch (used to calculate ROUND_SIZE_IN_EPOCHS)
   * @param _slashOffsetInRounds How many rounds in the past to look when determining which validators to slash (must be
   * > 0)
   */
  constructor(
    address _instance,
    ISlasher _slasher,
    uint256 _quorum,
    uint256 _roundSize,
    uint256 _lifetimeInRounds,
    uint256 _executionDelayInRounds,
    uint256[3] memory _slashAmounts,
    uint256 _committeeSize,
    uint256 _epochDuration,
    uint256 _slashOffsetInRounds
  ) EIP712("SlashingProposer", "1") {
    INSTANCE = _instance;
    SLASHER = _slasher;
    SLASH_AMOUNT_SMALL = _slashAmounts[0];
    SLASH_AMOUNT_MEDIUM = _slashAmounts[1];
    SLASH_AMOUNT_LARGE = _slashAmounts[2];
    QUORUM = _quorum;
    ROUND_SIZE = _roundSize;
    ROUND_SIZE_IN_EPOCHS = _roundSize / _epochDuration;
    COMMITTEE_SIZE = _committeeSize;
    LIFETIME_IN_ROUNDS = _lifetimeInRounds;
    EXECUTION_DELAY_IN_ROUNDS = _executionDelayInRounds;
    SLASH_OFFSET_IN_ROUNDS = _slashOffsetInRounds;

    // Deploy the SlashPayloadCloneable implementation contract once
    SLASH_PAYLOAD_IMPLEMENTATION = address(new SlashPayloadCloneable{salt: bytes32(bytes20(uint160(address(this))))}());

    require(
      SLASH_OFFSET_IN_ROUNDS > 0, Errors_1.SlashingProposer__SlashOffsetMustBeGreaterThanZero(SLASH_OFFSET_IN_ROUNDS)
    );
    require(
      ROUND_SIZE_IN_EPOCHS * _epochDuration == ROUND_SIZE,
      Errors_1.SlashingProposer__RoundSizeMustBeMultipleOfEpochDuration(ROUND_SIZE, _epochDuration)
    );
    require(QUORUM > 0, Errors_1.SlashingProposer__QuorumMustBeGreaterThanZero());
    require(ROUND_SIZE > 1, Errors_1.SlashingProposer__InvalidQuorumAndRoundSize(QUORUM, ROUND_SIZE));
    require(QUORUM > ROUND_SIZE / 2, Errors_1.SlashingProposer__InvalidQuorumAndRoundSize(QUORUM, ROUND_SIZE));
    require(QUORUM <= ROUND_SIZE, Errors_1.SlashingProposer__InvalidQuorumAndRoundSize(QUORUM, ROUND_SIZE));
    require(_slashAmounts[0] <= _slashAmounts[1], Errors_1.SlashingProposer__InvalidSlashAmounts(_slashAmounts));
    require(_slashAmounts[1] <= _slashAmounts[2], Errors_1.SlashingProposer__InvalidSlashAmounts(_slashAmounts));
    require(
      LIFETIME_IN_ROUNDS > EXECUTION_DELAY_IN_ROUNDS,
      Errors_1.SlashingProposer__LifetimeMustBeGreaterThanExecutionDelay(LIFETIME_IN_ROUNDS, EXECUTION_DELAY_IN_ROUNDS)
    );
    require(
      LIFETIME_IN_ROUNDS < ROUNDABOUT_SIZE,
      Errors_1.SlashingProposer__LifetimeMustBeLessThanRoundabout(LIFETIME_IN_ROUNDS, ROUNDABOUT_SIZE)
    );
    require(
      ROUND_SIZE_IN_EPOCHS > 0, Errors_1.SlashingProposer__RoundSizeInEpochsMustBeGreaterThanZero(ROUND_SIZE_IN_EPOCHS)
    );
    require(ROUND_SIZE <= MAX_ROUND_SIZE, Errors_1.SlashingProposer__RoundSizeTooLarge(ROUND_SIZE, MAX_ROUND_SIZE));
    require(COMMITTEE_SIZE > 0, Errors_1.SlashingProposer__CommitteeSizeMustBeGreaterThanZero(COMMITTEE_SIZE));

    // Validate that vote size doesn't exceed our fixed 4 bytes32 allocation
    // Each vote requires COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS / 4 bytes
    // We have allocated 4 bytes32 slots = 128 bytes maximum
    uint256 voteSize = COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS / 4;
    require(voteSize <= 128, Errors_1.SlashingProposer__VoteSizeTooBig(voteSize, 128));

    require(
      COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS % 4 == 0,
      Errors_1.SlashingProposer__VotesMustBeMultipleOf4(COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS)
    );

    // Defense in depth: the ordering constraints (small <= medium <= large) above mean that
    // if medium or large is zero, small must also be zero, so the small check would fire first.
    // We keep all three checks explicitly for clarity and to guard against future refactors
    // that might remove or reorder the sorting constraints.
    require(SLASH_AMOUNT_SMALL > 0, Errors_1.SlashingProposer__SlashAmountMustBeGtZero("small"));
    require(SLASH_AMOUNT_MEDIUM > 0, Errors_1.SlashingProposer__SlashAmountMustBeGtZero("medium"));
    require(SLASH_AMOUNT_LARGE > 0, Errors_1.SlashingProposer__SlashAmountMustBeGtZero("large"));
  }

  /**
   * @notice Submit a vote for slashing validators from SLASH_OFFSET_IN_ROUNDS rounds ago
   * @dev Only the current checkpoint proposer can submit votes, enforced via EIP-712 signature verification.
   *      Each byte in the votes encodes slash amounts for 4 validators using 2 bits each (0-3 units each).
   *      The vote includes the current slot number to prevent replay attacks.
   *
   * @param _votes Encoded voting data where each byte represents slash amounts for 4 validators.
   *               Bits 0-1 for first validator, bits 2-3 for second, bits 4-5 for third, bits 6-7 for fourth.
   *               Length must equal (COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS) / 4 bytes.
   * @param _sig EIP-712 signature from the current proposer proving authorization to vote.
   *             Signature covers the vote data and current slot number.
   *
   * Emits:
   * - VoteCast: When the vote is successfully recorded
   *
   * Reverts with:
   * - SlashingProposer__VotingNotOpen: If current round is less than SLASH_OFFSET_IN_ROUNDS
   * - SlashingProposer__InvalidSignature: If signature verification fails
   * - SlashingProposer__InvalidVoteLength: If vote data length is incorrect
   * - SlashingProposer__VoteAlreadyCastInCurrentSlot: If proposer already voted in this slot
   */
  function vote(bytes calldata _votes, Signature calldata _sig) external {
    Slot slot = _getCurrentSlot();
    SlashRound round = _computeRound(slot);

    // We vote for slashing validators for epochs from SLASH_OFFSET_IN_ROUNDS ago, so in early rounds there is no one to
    // be slashed.
    require(round >= SlashRound.wrap(SLASH_OFFSET_IN_ROUNDS), Errors_1.SlashingProposer__VotingNotOpen(round));

    // Get the current proposer from the rollup - only they can submit votes
    address proposer = _getCurrentProposer();

    // Verify EIP-712 signature (which includes slot to prevent replay attacks)
    bytes32 digest = getVoteSignatureDigest(_votes, slot);
    require(_sig.verify(proposer, digest), Errors_1.SlashingProposer__InvalidSignature());

    // Each byte encodes 4 validators (2 bits each), so each validator is represented as 2 bits in the byte array.
    uint256 expectedLength = COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS / 4;
    require(_votes.length == expectedLength, Errors_1.SlashingProposer__InvalidVoteLength(expectedLength, _votes.length));

    // Get the round data for the current round
    RoundData memory roundData = _getRoundData(round, round);

    // Check if a vote has already been cast in the current slot
    require(roundData.lastVoteSlot < slot, Errors_1.SlashingProposer__VoteAlreadyCastInCurrentSlot(slot));

    // Store the vote for this round
    uint256 voteCount = roundData.voteCount;
    _storeVoteData(round, voteCount, _votes);

    // Increment the vote count for this round (all other fields remain unchanged)
    _setRoundData(round, slot, voteCount + 1, roundData.executed);

    emit VoteCast(round, slot, proposer);
  }

  /**
   * @notice Execute the slashing round by tallying votes and executing slashes for validators that reached quorum
   * @dev Can be called by anyone once a round has passed its execution delay but is still within its lifetime.
   *      The function tallies all votes cast during the round, identifies validators that reached the quorum threshold,
   *      and executes slashing by deploying a SlashPayload contract and calling the Slasher.
   *
   * @param _round The round number to execute (must be ready for execution based on timing constraints)
   * @param _committees Array of validator committees slashed for each epoch in the round being executed.
   *                   Must contain exactly ROUND_SIZE_IN_EPOCHS committees. Only committees with slashed
   *                   validators will have their commitments verified against onchain data.
   *
   * Emits:
   * - RoundExecuted: When the round execution completes, regardless of whether any slashing occurred
   *
   * Reverts with:
   * - SlashingProposer__RoundAlreadyExecuted: If the round has already been executed
   * - SlashingProposer__RoundNotComplete: If the round is not yet ready for execution or has expired
   * - SlashingProposer__InvalidCommitteeCommitment: If any committee commitment doesn't match onchain data
   * - SlashingProposer__InvalidNumberOfCommittees: If the number of committees doesn't match
   * ROUND_SIZE_IN_EPOCHS
   */
  function executeRound(SlashRound _round, address[][] calldata _committees) external {
    // Get round data to check if already executed
    SlashRound currentRound = getCurrentRound();
    RoundData memory roundData = _getRoundData(_round, currentRound);
    require(!roundData.executed, Errors_1.SlashingProposer__RoundAlreadyExecuted(_round));

    // Ensure enough time has passed (execution delay) but not too much (lifetime)
    require(_isRoundReadyToExecute(_round, currentRound), Errors_1.SlashingProposer__RoundNotComplete(_round));

    // Get the slash actions by tallying votes and which committees have slashes
    (SlashAction[] memory actions, bool[] memory committeesWithSlashes) = _tally(roundData, _committees);

    // Only verify committees that have slashed validators
    unchecked {
      uint256 length = committeesWithSlashes.length;
      for (uint256 i; i < length; ++i) {
        if (!committeesWithSlashes[i]) {
          continue;
        }

        // Check committee commitments against the stored onchain data
        bytes32 commitment = _computeCommitteeCommitment(_committees[i]);
        Epoch epochNumber = getSlashTargetEpoch(_round, i);
        require(
          commitment == _getCommitteeCommitment(epochNumber), Errors_1.SlashingProposer__InvalidCommitteeCommitment()
        );
      }
    }

    // Mark round as executed to prevent re-execution
    // We set this flag before actually slashing to avoid re-entrancy issues
    _setRoundData(
      _round,
      roundData.lastVoteSlot,
      roundData.voteCount,
      /*executed=*/
      true
    );

    // Execute slashes if any were determined
    if (actions.length > 0) {
      // Deploy payload contract and execute slashes
      IPayload slashPayload = _deploySlashPayload(_round, actions);
      SLASHER.slash(slashPayload);
    }

    emit RoundExecuted(_round, actions.length);
  }

  /**
   * @notice Load committees for all epochs to be potentially slashed in a round from the rollup instance
   * @dev This is an expensive call. It is not marked as view since `getEpochCommittee` may modify rollup state.
   *      If `getEpochCommittee` throws (eg committee not yet formed), an empty committee is returned for that epoch.
   * @param _round The round number to load committees for
   * @return committees Array of committees, one for each epoch in the round (may contain empty arrays for early epochs)
   */
  function getSlashTargetCommittees(SlashRound _round) external returns (address[][] memory committees) {
    committees = new address[][](ROUND_SIZE_IN_EPOCHS);

    IValidatorSelection rollup = IValidatorSelection(INSTANCE);
    unchecked {
      for (uint256 epochIndex; epochIndex < ROUND_SIZE_IN_EPOCHS; ++epochIndex) {
        Epoch epoch = getSlashTargetEpoch(_round, epochIndex);
        try rollup.getEpochCommittee(epoch) returns (address[] memory committee) {
          committees[epochIndex] = committee;
        } catch {
          committees[epochIndex] = new address[](0);
        }
      }
    }

    return committees;
  }

  /**
   * @notice Get the tally results for a specific round, showing which validators would be slashed
   * @dev This function is intended for offchain querying and analysis of voting results.
   *      It uses transient storage when calling getEpochCommittee on the rollup contract.
   *      Returns the same slash actions that would be executed if executeRound() were called for this round.
   *
   * @param _round The round number to analyze and return tally results for
   * @param _committees The list of committees to consider for the tally (get them via `getSlashTargetCommittees`)
   * @return actions Array of SlashAction structs containing validator addresses and slash amounts
   *                for all validators that reached the quorum threshold in this round
   */
  function getTally(SlashRound _round, address[][] calldata _committees) external view returns (SlashAction[] memory) {
    // Get the round data for the specified round
    RoundData memory roundData = _getRoundData(_round, getCurrentRound());

    // Tally votes and return slash actions
    (SlashAction[] memory actions,) = _tally(roundData, _committees);
    return actions;
  }

  /**
   * @notice Get the deterministic address where a slash payload would be deployed for given actions
   * @dev Uses CREATE2 to predict the deployment address based on the round number and slash actions.
   *      Returns zero address if no actions are provided. The address is deterministic and will be
   *      the same across multiple calls with identical parameters.
   *
   * @param _round The round number that will be mixed into the CREATE2 salt
   * @param _actions Array of SlashAction structs containing validator addresses and slash amounts
   * @return The predicted deployment address of the SlashPayload contract, or zero address if no actions
   */
  function getPayloadAddress(SlashRound _round, SlashAction[] memory _actions) external view returns (address) {
    // Return zero address if no actions
    if (_actions.length == 0) {
      return address(0);
    }
    (,,, address predictedAddress) = _preparePayloadDataAndAddress(_round, _actions);
    return predictedAddress;
  }

  /**
   * @notice Get information about a specific slashing round's status and voting data
   * @param _round The round number to retrieve information for
   * @return isExecuted True if the round has already been executed and slashing has occurred
   * @return voteCount The total number of votes that have been cast in this round by proposers
   */
  function getRound(SlashRound _round) external view returns (bool isExecuted, uint256 voteCount) {
    // Load round data from the circular storage
    RoundData memory roundData = _getRoundData(_round, getCurrentRound());
    return (roundData.executed, roundData.voteCount);
  }

  /**
   * @notice Check if a specific slashing round is ready for execution
   * @param _round The round number to check
   * @param _slot The slot number at which to evaluate readiness (typically current or slot)
   */
  function isRoundReadyToExecute(SlashRound _round, Slot _slot) external view returns (bool) {
    SlashRound currentRound = _computeRound(_slot);
    return _isRoundReadyToExecute(_round, currentRound);
  }

  /**
   * @notice Get the votes for a specific `_round` at a specific `_index`
   * @param _round The round number to retrieve votes for
   * @param _index The index to retrieve votes for
   * @return The votes retrieved
   */
  function getVotes(SlashRound _round, uint256 _index) external view returns (bytes memory) {
    uint256 expectedLength = COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS / 4;

    // _getRoundData reverts if _round is out of the roundabout range and
    // returns empty metadata if this circular slot still contains round data
    // from an older round number.
    SlashRound currentRound = getCurrentRound();
    RoundData memory roundData = _getRoundData(_round, currentRound);

    // Vote storage is not cleared when a circular slot is reused. If this
    // round has fewer votes than a previous one that shared the same slot,
    // indices >= voteCount would otherwise return stale vote bytes.
    if (_index >= roundData.voteCount) {
      return new bytes(expectedLength);
    }

    bytes32[4] storage voteSlots = _getRoundVotes(_round).votes[_index];
    return _loadVoteDataFromStorage(voteSlots, expectedLength);
  }

  /**
   * @notice Get the current round number based on the current slot from the rollup
   * @dev Calculates the current round by dividing the current slot number by ROUND_SIZE.
   *      This determines which voting round is currently active.
   * @return The current SlashRound number
   */
  function getCurrentRound() public view returns (SlashRound) {
    // Get current slot from the rollup instance
    IValidatorSelection rollup = IValidatorSelection(INSTANCE);
    Slot currentSlot = rollup.getCurrentSlot();
    // Divide slot by round size to get round number
    return SlashRound.wrap(Slot.unwrap(currentSlot) / ROUND_SIZE);
  }

  /**
   * @notice Get the epoch number that will be slashed during a specific round at a given epoch index
   * @dev Calculates which epoch's validators are being voted on for slashing in a given round.
   *      The epoch is determined by looking back SLASH_OFFSET_IN_ROUNDS rounds from the voting round
   *      and then adding the epoch index within that round.
   *
   * @param _round The round number during which voting is taking place
   * @param _epochIndex The index of the epoch within the round (must be 0 to ROUND_SIZE_IN_EPOCHS-1)
   * @return epochNumber The epoch number whose validators will be considered for slashing
   *
   * Reverts with:
   * - SlashingProposer__VotingNotOpen: If the round is less than SLASH_OFFSET_IN_ROUNDS
   */
  function getSlashTargetEpoch(SlashRound _round, uint256 _epochIndex) public view returns (Epoch epochNumber) {
    require(_round >= SlashRound.wrap(SLASH_OFFSET_IN_ROUNDS), Errors_1.SlashingProposer__VotingNotOpen(_round));
    require(
      _epochIndex < ROUND_SIZE_IN_EPOCHS, Errors_1.SlashingProposer__InvalidEpochIndex(_epochIndex, ROUND_SIZE_IN_EPOCHS)
    );
    return Epoch.wrap((SlashRound.unwrap(_round) - SLASH_OFFSET_IN_ROUNDS) * ROUND_SIZE_IN_EPOCHS + _epochIndex);
  }

  /**
   * @notice Generate the EIP-712 signature digest for a vote to prevent replay attacks
   * @dev Creates a typed data hash according to EIP-712 standard that includes both the vote data
   *      and the slot number. The slot number inclusion prevents votes from being replayed in
   *      different slots, ensuring each vote is tied to a specific time.
   *
   * @param _votes The encoded vote data that will be signed by the proposer
   * @param _slot The slot number when the vote is being cast (prevents replay attacks)
   * @return The EIP-712 compliant signature digest that should be signed by the proposer
   */
  function getVoteSignatureDigest(bytes calldata _votes, Slot _slot) public view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(VOTE_TYPEHASH, keccak256(_votes), Slot.unwrap(_slot))));
  }

  /**
   * @notice Get the address of the validator who is authorized to propose in the current slot
   * @dev Queries the rollup contract to determine which validator has proposing rights.
   *      This is used to verify that vote signatures come from the authorized proposer.
   * @return The address of the current slot's designated proposer
   */
  function _getCurrentProposer() internal returns (address) {
    // Query the rollup for who is allowed to propose in the current slot
    IValidatorSelection rollup = IValidatorSelection(INSTANCE);
    return rollup.getCurrentProposer();
  }

  /**
   * @notice Get the committee commitment from the Rollup.
   * @param _epoch The epoch number
   */
  function _getCommitteeCommitment(Epoch _epoch) internal returns (bytes32) {
    IValidatorSelection rollup = IValidatorSelection(INSTANCE);
    (bytes32 commitment,) = rollup.getEpochCommitteeCommitment(_epoch);
    return commitment;
  }

  /**
   * @notice Deploy a slash payload contract with the given actions
   * @dev Deploys a SlashPayload contract using CREATE2 for deterministic addresses
   * @param _round The round number (mixed into the salt)
   * @param _actions Array of slash actions to encode in the payload
   */
  function _deploySlashPayload(SlashRound _round, SlashAction[] memory _actions) internal returns (IPayload) {
    // Prepare arrays for the SlashPayload constructor and get the predicted address
    (address[] memory validators, uint96[] memory amounts, bytes32 salt, address predictedAddress) =
      _preparePayloadDataAndAddress(_round, _actions);
    // Return existing payload if already deployed
    if (predictedAddress.code.length > 0) {
      return IPayload(predictedAddress);
    }

    // Deploy clone of SlashPayload using EIP-1167 minimal proxy with immutable args
    // Encode the immutable arguments for the clone
    bytes memory immutableArgs = SlashPayloadLib.encodeImmutableArgs(INSTANCE, validators, amounts);

    // Deploy the clone with deterministic address
    address clone = Clones.cloneDeterministicWithImmutableArgs(SLASH_PAYLOAD_IMPLEMENTATION, immutableArgs, salt);

    return IPayload(clone);
  }

  /**
   * @notice Store vote data in fixed-size format
   * @param roundNumber The round to store the vote for
   * @param voteIndex The index of the vote within the round
   * @param voteData The vote data to store
   */
  function _storeVoteData(SlashRound roundNumber, uint256 voteIndex, bytes calldata voteData) internal {
    bytes32[4] storage voteSlots = _getRoundVotes(roundNumber).votes[voteIndex];
    uint256 dataLength = voteData.length;

    // Ensure we don't exceed maximum size
    require(dataLength <= 128, Errors_1.SlashingProposer__VoteSizeTooBig(dataLength, 128));

    unchecked {
      assembly {
        let offset := voteData.offset

        // Store chunk 0 (bytes 0-31)
        if dataLength {
          let chunk := calldataload(offset)
          // For partial chunks, we need to keep data left-aligned in the slot
          // No masking needed since unused bytes are already zero in calldata
          sstore(voteSlots.slot, chunk)
        }

        // Store chunk 1 (bytes 32-63)
        if gt(dataLength, 32) {
          let chunk := calldataload(add(offset, 32))
          sstore(add(voteSlots.slot, 1), chunk)
        }

        // Store chunk 2 (bytes 64-95)
        if gt(dataLength, 64) {
          let chunk := calldataload(add(offset, 64))
          sstore(add(voteSlots.slot, 2), chunk)
        }

        // Store chunk 3 (bytes 96-127)
        if gt(dataLength, 96) {
          let chunk := calldataload(add(offset, 96))
          sstore(add(voteSlots.slot, 3), chunk)
        }
      }
    }
  }

  /**
   * @notice Set round data in the circular storage
   * This function DOES NOT check for round validity or range within the roundabout
   * @param roundNumber The round number to set
   * @param lastVoteSlot The last slot for which a vote was received
   * @param voteCount The number of votes collected so far in this round
   * @param executed Whether this round has been executed
   * @dev This is an internal function that should only be called after verifying the round is valid and within range
   * @dev It updates the round data in the circular storage buffer
   */
  function _setRoundData(SlashRound roundNumber, Slot lastVoteSlot, uint256 voteCount, bool executed) internal {
    roundDatas[SlashRound.unwrap(roundNumber) % ROUNDABOUT_SIZE] = CompressedRoundData({
      roundNumber: roundNumber.compress(),
      lastVoteSlot: lastVoteSlot.compress(),
      voteCount: SafeCast.toUint16(voteCount), // Ensure voteCount fits in uint16
      executed: executed
    });
  }

  /**
   * @notice Tally votes for a specific round and return the slash actions to execute
   * @param _roundData The round data containing votes to tally
   * @param _committees The committees for each epoch in the round
   * @return slashActions Array of slash actions that reached quorum
   * @return committeesWithSlashes Boolean array indicating which committees have at least one slashed validator
   */
  function _tally(RoundData memory _roundData, address[][] calldata _committees)
    internal
    view
    returns (SlashAction[] memory slashActions, bool[] memory committeesWithSlashes)
  {
    // Must have one committee per epoch in the round
    require(
      _committees.length == ROUND_SIZE_IN_EPOCHS,
      Errors_1.SlashingProposer__InvalidNumberOfCommittees(ROUND_SIZE_IN_EPOCHS, _committees.length)
    );

    uint256 voteCount = _roundData.voteCount;

    // No votes cast, return empty array
    if (voteCount == 0) {
      return (new SlashAction[](0), new bool[](ROUND_SIZE_IN_EPOCHS));
    }

    // Pre-calculate total validators to optimize memory allocation
    uint256 totalValidators = COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS;

    // Create a voting tally array where each uint256 packs all vote counts for a validator
    // Layout: [0-63: votes for 1 unit][64-127: votes for 2 units][128-191: votes for 3 units][192-255: unused]
    // Each 64-bit segment can store up to 2^64-1 votes
    // Overflow protection: With MAX_ROUND_SIZE=1024, maximum possible votes per validator is 1024,
    // which is well below 2^64-1, preventing any overflow in the packed counters
    uint256[] memory tallyMatrix = new uint256[](totalValidators);

    // Process all votes cast during this round to populate the tally matrix
    _processVotes(_roundData, tallyMatrix, voteCount);

    // Determine which validators reached quorum and return slash actions, applying escape hatch at tally time
    bool[] memory escapeHatchEpochs = _getEscapeHatchEpochFlags(_roundData.roundNumber);
    return _determineSlashActions(tallyMatrix, _committees, totalValidators, escapeHatchEpochs);
  }

  /**
   * @notice Process all votes and populate the tally matrix
   */
  function _processVotes(RoundData memory _roundData, uint256[] memory tallyMatrix, uint256 voteCount) internal view {
    SlashRound roundNumber = _roundData.roundNumber;
    uint256 voteLength = COMMITTEE_SIZE * ROUND_SIZE_IN_EPOCHS / 4;

    // Cache the RoundVotes storage reference to avoid repeated calls
    RoundVotes storage targetRoundVotes = _getRoundVotes(roundNumber);

    unchecked {
      for (uint256 i; i < voteCount; ++i) {
        // Load the i-th votes from this round from storage into memory
        bytes memory currentVote = _loadVoteDataFromStorage(targetRoundVotes.votes[i], voteLength);

        // Process votes 32 bytes at a time
        uint256 j;
        for (; j + 31 < voteLength; j += 32) {
          // Process 32 bytes at once (128 validators)
          _process32BytesVotes(tallyMatrix, currentVote, j);
        }

        // Process remaining bytes one at a time (inlined)
        for (; j < voteLength; ++j) {
          uint256 baseIndex = j << 2; // j * 4 using bit shift
          uint8 currentByte;

          assembly {
            currentByte := byte(0, mload(add(add(currentVote, 0x20), j)))
          }

          // Next byte if this one is empty
          if (currentByte == 0) continue;

          // Extract 2 bits for each of the 4 validators in this byte,
          // and increment vote count for the given slash amount
          // Extract validator 0 vote: bits 0-1 (mask with 0x03 = 0b00000011)
          uint8 validatorSlash0 = currentByte & 0x03;
          if (validatorSlash0 != 0) {
            // Increment vote count at position (slashAmount-1) * 64 bits in packed uint256
            // Layout: [0-63: votes for 1 unit][64-127: votes for 2 units][128-191: votes for 3 units]
            tallyMatrix[baseIndex] += uint256(1) << ((validatorSlash0 - 1) << 6);
          }

          // Extract validator 1 vote: bits 2-3 (shift right 2, then mask with 0x03)
          uint8 validatorSlash1 = (currentByte >> 2) & 0x03;
          if (validatorSlash1 != 0) {
            tallyMatrix[baseIndex + 1] += uint256(1) << ((validatorSlash1 - 1) << 6);
          }

          // Extract validator 2 vote: bits 4-5 (shift right 4, then mask with 0x03)
          uint8 validatorSlash2 = (currentByte >> 4) & 0x03;
          if (validatorSlash2 != 0) {
            tallyMatrix[baseIndex + 2] += uint256(1) << ((validatorSlash2 - 1) << 6);
          }

          // Extract validator 3 vote: bits 6-7 (shift right 6, no mask needed as top 2 bits)
          uint8 validatorSlash3 = currentByte >> 6;
          if (validatorSlash3 != 0) {
            tallyMatrix[baseIndex + 3] += uint256(1) << ((validatorSlash3 - 1) << 6);
          }
        }
      }
    }
  }

  /**
   * @notice Determine which validators reached quorum and should be slashed
   */
  function _determineSlashActions(
    uint256[] memory tallyMatrix,
    address[][] calldata _committees,
    uint256 totalValidators,
    bool[] memory escapeHatchEpochs
  ) internal view returns (SlashAction[] memory actions, bool[] memory committeesWithSlashes) {
    actions = new SlashAction[](totalValidators);
    uint256 actionCount;
    committeesWithSlashes = new bool[](ROUND_SIZE_IN_EPOCHS);

    unchecked {
      for (uint256 i; i < totalValidators; ++i) {
        uint256 epochIndex = i / COMMITTEE_SIZE;

        // Skip validators that belong to escape-hatch epochs
        if (escapeHatchEpochs[epochIndex]) {
          continue;
        }
        uint256 packedVotes = tallyMatrix[i];

        // Skip if no votes for this validator
        if (packedVotes == 0) continue;

        uint256 voteCountForValidator;

        // Check slash amounts from highest (3 units) to lowest (1 unit)
        // Cumulative voting: votes for N units also count for N-1, N-2, etc.
        for (uint256 j = 3; j > 0;) {
          // Extract vote count for this slash amount from packed data
          // Shift right by (slashAmount-1) * 64 bits, then mask to get 64-bit segment
          // Layout: [0-63: votes for 1 unit][64-127: votes for 2 units][128-191: votes for 3 units]
          uint256 votesForAmount = (packedVotes >> ((j - 1) << 6)) & 0xFFFFFFFFFFFFFFFF;
          voteCountForValidator += votesForAmount;

          // Check if this slash amount has reached quorum
          if (voteCountForValidator >= QUORUM) {
            // Convert units to actual slash amount
            uint256 slashAmount;
            if (j == 1) {
              slashAmount = SLASH_AMOUNT_SMALL;
            } else if (j == 2) {
              slashAmount = SLASH_AMOUNT_MEDIUM;
            } else if (j == 3) {
              slashAmount = SLASH_AMOUNT_LARGE;
            }

            // Record the slashing action
            actions[actionCount] =
              SlashAction({validator: _committees[epochIndex][i % COMMITTEE_SIZE], slashAmount: slashAmount});
            ++actionCount;

            // Mark this committee as having at least one slashed validator
            committeesWithSlashes[epochIndex] = true;

            // Only slash each validator once at the highest amount that reached quorum
            break;
          }

          --j;
        }
      }
    }

    // Resize actions array to the actual number of actions using assembly
    assembly {
      mstore(actions, actionCount)
    }

    return (actions, committeesWithSlashes);
  }

  /**
   * @notice Load vote data from fixed-size format (optimized with unrolled loop)
   * @param voteSlots The storage reference to the vote slots
   * @param expectedLength The expected length of the vote data
   * @return voteData The reconstructed vote data as bytes
   */
  function _loadVoteDataFromStorage(bytes32[4] storage voteSlots, uint256 expectedLength)
    internal
    view
    returns (bytes memory voteData)
  {
    // Allocate memory for full chunks
    // This avoids complex masking by over-allocating slightly
    voteData = new bytes(4 * 32);

    unchecked {
      // Load full chunks without masking
      assembly {
        let dataPtr := add(voteData, 0x20)

        // Chunk 0 (bytes 0-31)
        if expectedLength {
          let chunk := sload(voteSlots.slot)
          mstore(dataPtr, chunk)
        }

        // Chunk 1 (bytes 32-63)
        if gt(expectedLength, 32) {
          let chunk := sload(add(voteSlots.slot, 1))
          mstore(add(dataPtr, 32), chunk)
        }

        // Chunk 2 (bytes 64-95)
        if gt(expectedLength, 64) {
          let chunk := sload(add(voteSlots.slot, 2))
          mstore(add(dataPtr, 64), chunk)
        }

        // Chunk 3 (bytes 96-127)
        if gt(expectedLength, 96) {
          let chunk := sload(add(voteSlots.slot, 3))
          mstore(add(dataPtr, 96), chunk)
        }

        // Adjust the array length to the expected length
        // This ensures the bytes array reports the correct length
        // even though we allocated extra memory
        mstore(voteData, expectedLength)
      }
    }
  }

  /**
   * @notice Get the current slot number from the rollup contract
   * @dev Retrieves the current time-based slot number which determines the active round and proposer.
   * @return The current Slot number
   */
  function _getCurrentSlot() internal view returns (Slot) {
    IValidatorSelection rollup = IValidatorSelection(INSTANCE);
    return rollup.getCurrentSlot();
  }

  /**
   * @notice Determine which epochs targeted by a round are in escape-hatch mode
   * @param _round The round number to check for
   * @return escapeHatchEpochs A bool array for escape hatch status of the epochs in the round
   */
  function _getEscapeHatchEpochFlags(SlashRound _round) internal view returns (bool[] memory escapeHatchEpochs) {
    escapeHatchEpochs = new bool[](ROUND_SIZE_IN_EPOCHS);

    for (uint256 epochIndex; epochIndex < ROUND_SIZE_IN_EPOCHS; epochIndex++) {
      Epoch epoch = getSlashTargetEpoch(_round, epochIndex);
      IEscapeHatch escapeHatch = IValidatorSelection(INSTANCE).getEscapeHatchForEpoch(epoch);
      if (address(escapeHatch) == address(0)) {
        continue;
      }
      (bool isOpen,) = escapeHatch.isHatchOpen(epoch);
      escapeHatchEpochs[epochIndex] = isOpen;
    }
  }

  /**
   * @notice Check if a round is ready for execution based on timing constraints
   * @dev A round is ready for execution when:
   *      1. Enough time has passed (current round > round + execution delay)
   *      2. Not too much time has passed (current round <= round + lifetime)
   *      This ensures there's time for review before execution while preventing stale executions.
   *
   * @param _round The round number to check readiness for
   * @param _currentRound The current round number for comparison
   * @return True if the round is ready for execution, false otherwise
   */
  function _isRoundReadyToExecute(SlashRound _round, SlashRound _currentRound) internal view returns (bool) {
    // Round must have passed execution delay but not exceeded lifetime
    // This gives time for review before execution and prevents stale executions
    return SlashRound.unwrap(_currentRound) > SlashRound.unwrap(_round) + EXECUTION_DELAY_IN_ROUNDS
      && SlashRound.unwrap(_currentRound) <= SlashRound.unwrap(_round) + LIFETIME_IN_ROUNDS;
  }

  /**
   * @notice Internal function to prepare payload data and compute address from slash actions
   * @param _round The round number (mixed into the salt)
   * @param _actions Array of slash actions
   * @return validators Array of validator addresses
   * @return amounts Array of slash amounts as uint96
   * @return salt The computed salt for CREATE2 deployment
   * @return predictedAddress The predicted address where the payload would be deployed
   */
  function _preparePayloadDataAndAddress(SlashRound _round, SlashAction[] memory _actions)
    internal
    view
    returns (address[] memory validators, uint96[] memory amounts, bytes32 salt, address predictedAddress)
  {
    uint256 actionCount = _actions.length;
    validators = new address[](actionCount);
    amounts = new uint96[](actionCount);

    // Extract validators and amounts from actions
    unchecked {
      for (uint256 i; i < actionCount; ++i) {
        validators[i] = _actions[i].validator;
        // Convert uint256 to uint96, checking for overflow
        require(_actions[i].slashAmount <= type(uint96).max, Errors_1.SlashingProposer__SlashAmountTooLarge());
        amounts[i] = uint96(_actions[i].slashAmount);
      }
    }

    // Compute salt for CREATE2 deployment, including round number
    salt = keccak256(abi.encodePacked(SlashRound.unwrap(_round), validators, amounts));

    // Compute predicted address using clone deterministic address prediction
    bytes memory immutableArgs = SlashPayloadLib.encodeImmutableArgs(INSTANCE, validators, amounts);
    predictedAddress = Clones.predictDeterministicAddressWithImmutableArgs(
      SLASH_PAYLOAD_IMPLEMENTATION, immutableArgs, salt, address(this)
    );

    return (validators, amounts, salt, predictedAddress);
  }

  /**
   * @notice Returns a storage reference to the round votes for a specific round from the circular storage buffer
   * @dev Uses modulo arithmetic to map round numbers to storage slots in the circular buffer.
   *      IMPORTANT: This function DOES NOT validate that the round is within the valid range or that
   *      the data hasn't been overwritten by newer rounds. Always call getRoundData() first to ensure
   *      the round data is valid before using this function.
   *
   * @param _round The round number to get votes for
   * @return A storage reference to the RoundVotes struct containing the vote data for this round
   */
  function _getRoundVotes(SlashRound _round) internal view returns (RoundVotes storage) {
    // Map round number to circular storage index using modulo
    // This allows reuse of storage slots as older rounds become irrelevant
    return roundVotes[SlashRound.unwrap(_round) % ROUNDABOUT_SIZE];
  }

  /**
   * @notice Get round data for a specific round, loading from circular storage and decompressing it
   * @param _round The round number to retrieve data for
   * @param _currentRound The current round number, so we dont try loading data outside the valid roundabout range.
   * Required as a parameter to avoid having to recompute it on every call to this function.
   * @return RoundData struct containing the round's data
   */
  function _getRoundData(SlashRound _round, SlashRound _currentRound) internal view returns (RoundData memory) {
    // Check if the requested round is within the valid roundabout range
    if (
      SlashRound.unwrap(_round) > SlashRound.unwrap(_currentRound)
        || SlashRound.unwrap(_round) + ROUNDABOUT_SIZE <= SlashRound.unwrap(_currentRound)
    ) {
      revert Errors_1.SlashingProposer__RoundOutOfRange((_round), (_currentRound));
    }

    // Load round data from the circular storage into memory in a single SLOAD
    CompressedRoundData memory roundData = roundDatas[SlashRound.unwrap(_round) % ROUNDABOUT_SIZE];

    // If we find in storage round data for an older round since we've gone around the roundabout, return an empty one
    if (roundData.roundNumber.decompress() != _round) {
      return RoundData({roundNumber: _round, lastVoteSlot: Slot.wrap(0), voteCount: 0, executed: false});
    }

    return RoundData({
      roundNumber: _round,
      lastVoteSlot: roundData.lastVoteSlot.decompress(),
      voteCount: roundData.voteCount,
      executed: roundData.executed
    });
  }

  /**
   * @notice Computes the round at the given slot
   * @param _slot - The slot to compute round for
   * @return The round number
   */
  function _computeRound(Slot _slot) internal view returns (SlashRound) {
    return SlashRound.wrap(Slot.unwrap(_slot) / ROUND_SIZE);
  }

  /**
   * @notice Process 32 bytes of vote data at once
   * @dev Processes a full word for maximum efficiency with early exit for zero words
   */
  function _process32BytesVotes(uint256[] memory tallyMatrix, bytes memory currentVote, uint256 startJ) internal pure {
    unchecked {
      // Load 32 bytes as a single word
      uint256 word;
      assembly {
        word := mload(add(add(currentVote, 0x20), startJ))
      }

      // Early exit if entire word is zero (no votes)
      if (word == 0) return;

      // Process the 32-byte word byte by byte, maintaining big-endian order
      uint256 baseIndex = startJ << 2; // Convert byte index to validator index: startJ * 4

      for (uint256 i; i < 32; ++i) {
        // Early exit if remaining word is zero
        if (word == 0) break;

        // Extract most significant byte from word (big-endian order)
        // Shift right 248 bits (31 bytes) to get the leftmost byte
        uint8 currentByte = uint8(word >> 248);

        // Shift word left by 8 bits for next iteration, removing processed byte
        word <<= 8;

        if (currentByte != 0) {
          uint256 idx = baseIndex + (i << 2); // Convert byte index to validator index: baseIndex + i * 4

          // Extract validator 0 vote: bits 0-1 (mask with 0x03 = 0b00000011)
          uint8 v0 = currentByte & 0x03;
          if (v0 != 0) tallyMatrix[idx] += uint256(1) << ((v0 - 1) << 6);

          // Extract validator 1 vote: bits 2-3 (shift right 2, then mask with 0x03)
          uint8 v1 = (currentByte >> 2) & 0x03;
          if (v1 != 0) tallyMatrix[idx + 1] += uint256(1) << ((v1 - 1) << 6);

          // Extract validator 2 vote: bits 4-5 (shift right 4, then mask with 0x03)
          uint8 v2 = (currentByte >> 4) & 0x03;
          if (v2 != 0) tallyMatrix[idx + 2] += uint256(1) << ((v2 - 1) << 6);

          // Extract validator 3 vote: bits 6-7 (shift right 6, no mask needed)
          uint8 v3 = currentByte >> 6;
          if (v3 != 0) tallyMatrix[idx + 3] += uint256(1) << ((v3 - 1) << 6);
        }
      }
    }
  }

  /**
   * @notice Reconstruct committee commitment from addresses
   */
  function _computeCommitteeCommitment(address[] calldata _committee) internal pure returns (bytes32) {
    // Hash the committee addresses to create a commitment for verification
    // Duplicated from ValidatorSelectionLib.sol
    return keccak256(abi.encode(_committee));
  }
}