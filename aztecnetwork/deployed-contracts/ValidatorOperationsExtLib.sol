// SPDX-License-Identifier: Unknown
pragma solidity 0.8.30;

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

struct TimeStorage {
  uint128 genesisTime;
  uint32 slotDuration; // Number of seconds in a slot
  uint32 epochDuration; // Number of slots in an epoch
  /**
   * @notice Number of epochs after the end of a given epoch that proofs are still accepted. For example, a value of 1
   * means that after epoch n ends, the proofs must land *before* epoch n+1 ends. A value of 0 would mean that the
   * proofs for epoch n must land while the epoch is ongoing.
   */
  uint32 proofSubmissionEpochs;
}

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

library TimeLib {
  using SafeCast for uint256;

  bytes32 private constant TIME_STORAGE_POSITION = keccak256("aztec.time.storage");

  function initialize(
    uint256 _genesisTime,
    uint256 _slotDuration,
    uint256 _epochDuration,
    uint256 _proofSubmissionEpochs
  ) internal {
    TimeStorage storage store = getStorage();
    store.genesisTime = _genesisTime.toUint128();
    store.slotDuration = _slotDuration.toUint32();
    store.epochDuration = _epochDuration.toUint32();
    store.proofSubmissionEpochs = _proofSubmissionEpochs.toUint32();
  }

  function toTimestamp(Slot _a) internal view returns (Timestamp) {
    TimeStorage storage store = getStorage();
    return Timestamp.wrap(store.genesisTime) + Timestamp.wrap(Slot.unwrap(_a) * store.slotDuration);
  }

  function slotFromTimestamp(Timestamp _a) internal view returns (Slot) {
    TimeStorage storage store = getStorage();
    return Slot.wrap((Timestamp.unwrap(_a) - store.genesisTime) / store.slotDuration);
  }

  function toSlots(Epoch _a) internal view returns (Slot) {
    return Slot.wrap(Epoch.unwrap(_a) * getStorage().epochDuration);
  }

  function toTimestamp(Epoch _a) internal view returns (Timestamp) {
    return toTimestamp(toSlots(_a));
  }

  /**
   * @notice An epoch deadline is the epoch at which:
   *         - proofs are no longer accepted
   *         - which we may prune if no proof has landed
   *         - rewards may be claimed
   *
   * @param _a - The epoch to compute the deadline for
   *
   * @return The computed epoch
   */
  function toDeadlineEpoch(Epoch _a) internal view returns (Epoch) {
    TimeStorage storage store = getStorage();
    // We add one to the proof submission epochs to account for the current epoch.
    // This is because toSlots will return the first slot of the epoch, and in the event
    // that proofSubmissionEpochs is 0, we would wait until the end of the current epoch.
    return _a + Epoch.wrap(store.proofSubmissionEpochs + 1);
  }

  /**
   * @notice Calculates the maximum number of checkpoints that can be pruned from the pending chain
   * @dev The maximum prunable checkpoints is determined by:
   *      - epochDuration: number of slots in an epoch
   *      - proofSubmissionEpochs: number of epochs allowed for proof submission
   *
   *      The formula is: epochDuration * (proofSubmissionEpochs + 1)
   *
   *      The +1 accounts for checkpoints in the current epoch, ensuring they are included
   *      in the prunable window along with checkpoints from previous epochs within the
   *      proof submission window.
   *
   *      This value is used to:
   *      1. Size the circular storage buffer (roundaboutSize = maxPrunableCheckpoints + 1)
   *      2. Determine when checkpoints become stale and can be overwritten
   *
   * @return The maximum number of checkpoints that can be pruned.
   */
  function maxPrunableCheckpoints() internal view returns (uint256) {
    TimeStorage storage store = getStorage();
    return uint256(store.epochDuration) * (uint256(store.proofSubmissionEpochs) + 1);
  }

  /**
   * @notice Checks if proofs are being accepted for epoch _a during epoch _b
   *
   * @param _a - The epoch that may be accepting proofs
   * @param _b - The epoch we would like to submit the proof for
   *
   * @return True if proofs would be accepted for epoch _a during epoch _b
   */
  function isAcceptingProofsAtEpoch(Epoch _a, Epoch _b) internal view returns (bool) {
    return _b < toDeadlineEpoch(_a);
  }

  function epochFromTimestamp(Timestamp _a) internal view returns (Epoch) {
    TimeStorage storage store = getStorage();

    return Epoch.wrap((Timestamp.unwrap(_a) - store.genesisTime) / (store.epochDuration * store.slotDuration));
  }

  function epochFromSlot(Slot _a) internal view returns (Epoch) {
    return Epoch.wrap(Slot.unwrap(_a) / getStorage().epochDuration);
  }

  function getEpochDurationInSeconds() internal view returns (uint256) {
    TimeStorage storage store = getStorage();
    return store.epochDuration * store.slotDuration;
  }

  function getStorage() internal pure returns (TimeStorage storage storageStruct) {
    bytes32 position = TIME_STORAGE_POSITION;
    assembly {
      storageStruct.slot := position
    }
  }
}

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
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
 * @notice A struct containing the arguments needed for GSE.deposit(...) function
 * @dev Used to store validator information in the entry queue before they are processed
 */
struct DepositArgs {
  address attester;
  address withdrawer;
  G1Point publicKeyInG1;
  G2Point publicKeyInG2;
  G1Point proofOfPossession;
  bool moveWithLatestRollup;
}

/**
 * @notice A queue data structure for managing validator deposits
 * @dev Implements a FIFO queue using a mapping and two pointers
 * @param validators Mapping from queue index to validator deposit arguments
 * @param first Index of the first element in the queue (head)
 * @param last Index of the next available slot in the queue (tail)
 */
struct StakingQueue {
  mapping(uint256 index => DepositArgs validator) validators;
  uint128 first;
  uint128 last;
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
library Errors {
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

library StakingQueueLib {
  function init(StakingQueue storage self) internal {
    self.first = 1;
    self.last = 1;
  }

  function enqueue(
    StakingQueue storage self,
    address _attester,
    address _withdrawer,
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession,
    bool _moveWithLatestRollup
  ) internal returns (uint256) {
    uint128 queueLocation = self.last;

    self.validators[queueLocation] = DepositArgs({
      attester: _attester,
      withdrawer: _withdrawer,
      publicKeyInG1: _publicKeyInG1,
      publicKeyInG2: _publicKeyInG2,
      proofOfPossession: _proofOfPossession,
      moveWithLatestRollup: _moveWithLatestRollup
    });
    self.last = queueLocation + 1;

    return queueLocation;
  }

  function dequeue(StakingQueue storage self) internal returns (DepositArgs memory validator) {
    require(self.last > self.first, Errors.Staking__QueueEmpty());

    validator = self.validators[self.first];

    self.first += 1;
  }

  function length(StakingQueue storage self) internal view returns (uint256 len) {
    len = self.last - self.first;
  }

  function at(StakingQueue storage self, uint256 index) internal view returns (DepositArgs memory validator) {
    validator = self.validators[self.first + index];
  }
}

type CompressedTimestamp is uint32;

type CompressedSlot is uint32;

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

type CompressedBallot is uint256;

struct Ballot {
  uint256 yea;
  uint256 nay;
}

library BallotLib {
  using SafeCast for uint256;

  uint256 internal constant YEA_MASK = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 internal constant NAY_MASK = 0xffffffffffffffffffffffffffffffff;

  function getYea(CompressedBallot _compressedBallot) internal pure returns (uint256) {
    return CompressedBallot.unwrap(_compressedBallot) >> 128;
  }

  function getNay(CompressedBallot _compressedBallot) internal pure returns (uint256) {
    return CompressedBallot.unwrap(_compressedBallot) & NAY_MASK;
  }

  function updateYea(CompressedBallot _compressedBallot, uint256 _yea) internal pure returns (CompressedBallot) {
    uint256 value = CompressedBallot.unwrap(_compressedBallot) & ~YEA_MASK;
    return CompressedBallot.wrap(value | (_yea << 128));
  }

  function updateNay(CompressedBallot _compressedBallot, uint256 _nay) internal pure returns (CompressedBallot) {
    uint256 value = CompressedBallot.unwrap(_compressedBallot) & ~NAY_MASK;
    return CompressedBallot.wrap(value | _nay);
  }

  function addYea(CompressedBallot _compressedBallot, uint256 _amount) internal pure returns (CompressedBallot) {
    uint256 currentYea = getYea(_compressedBallot);
    uint256 newYea = currentYea + _amount;
    return updateYea(_compressedBallot, newYea.toUint128());
  }

  function addNay(CompressedBallot _compressedBallot, uint256 _amount) internal pure returns (CompressedBallot) {
    uint256 currentNay = getNay(_compressedBallot);
    uint256 newNay = currentNay + _amount;
    return updateNay(_compressedBallot, newNay.toUint128());
  }

  function compress(Ballot memory _ballot) internal pure returns (CompressedBallot) {
    // We are doing cast to uint128 but inside a uint256 to not wreck the shifting.
    uint256 yea = _ballot.yea.toUint128();
    uint256 nay = _ballot.nay.toUint128();
    return CompressedBallot.wrap((yea << 128) | nay);
  }

  function decompress(CompressedBallot _compressedBallot) internal pure returns (Ballot memory) {
    return Ballot({yea: getYea(_compressedBallot), nay: getNay(_compressedBallot)});
  }
}

// @notice if this changes, please update the enum in governance.ts
enum ProposalState {
  Pending,
  Active,
  Queued,
  Executable,
  Rejected,
  Executed,
  Droppable,
  Dropped,
  Expired
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
 * @title CompressedProposal
 * @notice Compressed storage representation of governance proposals
 * @dev Packs proposal data with embedded config values into 4 storage slots:
 *      Slot 1: proposer (160) + minimumVotes (96) = 256 bits
 *      Slot 2: cachedState (8) + creation (32) + timing fields (32*4) + quorum (64) = 232 bits
 *      Slot 3: summedBallot (256 bits as CompressedBallot)
 *      Slot 4: payload (160) + requiredYeaMargin (64) = 224 bits
 *
 * This packing reduces storage from ~10 slots to 4 slots by embedding config values
 * directly instead of storing the entire configuration struct.
 */
struct CompressedProposal {
  // Slot 1: Core Identity (256 bits)
  address proposer; // 160 bits
  uint96 minimumVotes; // 96 bits - from config
    // Slot 2: Timing (232 bits used, 24 bits padding)
  ProposalState cachedState; // 8 bits
  CompressedTimestamp creation; // 32 bits
  CompressedTimestamp votingDelay; // 32 bits - from config
  CompressedTimestamp votingDuration; // 32 bits - from config
  CompressedTimestamp executionDelay; // 32 bits - from config
  CompressedTimestamp gracePeriod; // 32 bits - from config
  uint64 quorum; // 64 bits - from config
    // Slot 3: Votes (256 bits)
  CompressedBallot summedBallot; // 256 bits (128 yea + 128 nay)
    // Slot 4: References (224 bits used, 32 bits padding)
  IPayload payload; // 160 bits
  uint64 requiredYeaMargin; // 64 bits - from config
}

/**
 * @title CompressedConfiguration
 * @notice Compressed storage representation of governance configuration
 * @dev Packs configuration into minimal storage slots:
 *      Slot 1: Timing & percentages - votingDelay (32), votingDuration (32), executionDelay (32), gracePeriod (32),
 * quorum (64), requiredYeaMargin (64)
 *      Slot 2: Amounts & proposeConfig - minimumVotes (96), lockAmount (96), lockDelay (32), unused (32)
 *
 * This packing reduces storage from ~8 slots to 2 slots.
 * All timestamps use CompressedTimestamp (uint32, valid until year 2106).
 * Percentages (quorum, requiredYeaMargin) use uint64 (max 1e18).
 * Amounts use uint96 for realistic token amounts.
 * ProposeConfig fields are kept together in Slot 2.
 */
struct CompressedConfiguration {
  // Slot 1: Timing and percentages - 32*4 + 64*2 = 256 bits
  CompressedTimestamp votingDelay;
  CompressedTimestamp votingDuration;
  CompressedTimestamp executionDelay;
  CompressedTimestamp gracePeriod;
  uint64 quorum;
  uint64 requiredYeaMargin;
  // Slot 2: Amounts and proposeConfig - 96 + 96 + 32 = 224 bits (32 bits unused)
  uint96 minimumVotes;
  uint96 lockAmount;
  CompressedTimestamp lockDelay;
}

// Configuration for proposals - same as Configuration but without proposeConfig
// since proposeConfig is only used for proposeWithLock, not for the proposal itself
struct ProposalConfiguration {
  Timestamp votingDelay;
  Timestamp votingDuration;
  Timestamp executionDelay;
  Timestamp gracePeriod;
  uint256 quorum;
  uint256 requiredYeaMargin;
  uint256 minimumVotes;
}

struct Proposal {
  ProposalConfiguration config;
  ProposalState cachedState;
  IPayload payload;
  address proposer;
  Timestamp creation;
  Ballot summedBallot;
}

library CompressedProposalLib {
  using SafeCast for uint256;
  using CompressedTimeMath for Timestamp;
  using CompressedTimeMath for CompressedTimestamp;
  using BallotLib for CompressedBallot;

  /**
   * @notice Add yea votes to the proposal
   * @param _compressed Storage pointer to compressed proposal
   * @param _amount The amount of yea votes to add
   */
  function addYea(CompressedProposal storage _compressed, uint256 _amount) internal {
    _compressed.summedBallot = _compressed.summedBallot.addYea(_amount);
  }

  /**
   * @notice Add nay votes to the proposal
   * @param _compressed Storage pointer to compressed proposal
   * @param _amount The amount of nay votes to add
   */
  function addNay(CompressedProposal storage _compressed, uint256 _amount) internal {
    _compressed.summedBallot = _compressed.summedBallot.addNay(_amount);
  }

  /**
   * @notice Get yea and nay votes
   * @param _compressed Storage pointer to compressed proposal
   * @return yea The yea votes
   * @return nay The nay votes
   */
  function getVotes(CompressedProposal storage _compressed) internal view returns (uint256 yea, uint256 nay) {
    yea = _compressed.summedBallot.getYea();
    nay = _compressed.summedBallot.getNay();
  }

  /**
   * @notice Create a compressed proposal from uncompressed data and config
   * @param _proposer The proposal creator
   * @param _payload The payload to execute
   * @param _creation The creation timestamp
   * @param _config The compressed configuration to embed
   * @return The compressed proposal
   */
  function create(address _proposer, IPayload _payload, Timestamp _creation, CompressedConfiguration memory _config)
    internal
    pure
    returns (CompressedProposal memory)
  {
    return CompressedProposal({
      proposer: _proposer,
      minimumVotes: _config.minimumVotes,
      cachedState: ProposalState.Pending,
      creation: _creation.compress(),
      votingDelay: _config.votingDelay,
      votingDuration: _config.votingDuration,
      executionDelay: _config.executionDelay,
      gracePeriod: _config.gracePeriod,
      quorum: _config.quorum,
      summedBallot: CompressedBallot.wrap(0),
      payload: _payload,
      requiredYeaMargin: _config.requiredYeaMargin
    });
  }

  /**
   * @notice Compress an uncompressed Proposal into a CompressedProposal
   * @param _proposal The uncompressed proposal to compress
   * @return The compressed proposal
   */
  function compress(Proposal memory _proposal) internal pure returns (CompressedProposal memory) {
    return CompressedProposal({
      proposer: _proposal.proposer,
      minimumVotes: _proposal.config.minimumVotes.toUint96(),
      cachedState: _proposal.cachedState,
      creation: _proposal.creation.compress(),
      votingDelay: _proposal.config.votingDelay.compress(),
      votingDuration: _proposal.config.votingDuration.compress(),
      executionDelay: _proposal.config.executionDelay.compress(),
      gracePeriod: _proposal.config.gracePeriod.compress(),
      quorum: _proposal.config.quorum.toUint64(),
      summedBallot: BallotLib.compress(_proposal.summedBallot),
      payload: _proposal.payload,
      requiredYeaMargin: _proposal.config.requiredYeaMargin.toUint64()
    });
  }

  /**
   * @notice Decompress a CompressedProposal into a standard Proposal
   * @param _compressed The compressed proposal
   * @return The uncompressed proposal
   */
  function decompress(CompressedProposal memory _compressed) internal pure returns (Proposal memory) {
    return Proposal({
      config: ProposalConfiguration({
        votingDelay: _compressed.votingDelay.decompress(),
        votingDuration: _compressed.votingDuration.decompress(),
        executionDelay: _compressed.executionDelay.decompress(),
        gracePeriod: _compressed.gracePeriod.decompress(),
        quorum: _compressed.quorum,
        requiredYeaMargin: _compressed.requiredYeaMargin,
        minimumVotes: _compressed.minimumVotes
      }),
      cachedState: _compressed.cachedState,
      payload: _compressed.payload,
      proposer: _compressed.proposer,
      creation: _compressed.creation.decompress(),
      summedBallot: _compressed.summedBallot.decompress()
    });
  }
}

enum VoteTabulationReturn {
  Accepted,
  Rejected,
  Invalid
}

enum VoteTabulationInfo {
  TotalPowerLtMinimum,
  VotesNeededEqZero,
  VotesNeededGtTotalPower,
  VotesCastLtVotesNeeded,
  YeaLimitEqZero,
  YeaLimitGtVotesCast,
  YeaLimitEqVotesCast,
  YeaVotesEqVotesCast,
  YeaVotesLeYeaLimit,
  YeaVotesGtYeaLimit
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
 * @notice  Library for governance proposal evaluation and lifecycle management
 *
 *          This library implements the core vote tabulation logic, and has helpers for getting timestamps
 *          for the proposal lifecycle.
 *
 * @dev     VOTING MECHANICS:
 *
 *          The voting system uses three key parameters that interact to determine proposal outcomes:
 *
 *          1. **minimumVotes**: Absolute minimum voting power required in the system
 *             - Prevents proposals when total power is too low for meaningful governance
 *             - Must be > 0 and <= totalPower for valid proposals
 *
 *          2. **quorum**: Percentage of total power that must participate (in 1e18 precision)
 *             - votesNeeded = ceil(totalPower * quorum / 1e18)
 *             - Ensures sufficient community participation before decisions are made
 *             - Example: 30% quorum (0.3e18) with 1000 total power requires ≥300 votes
 *
 *          3. **requiredYeaMargin**: the required minimum difference between the percentage of yea votes,
 *                                    and the percentage of nay votes, in 1e18 precision
 *             - requiredYeaVotesFraction = ceil((1e18 + requiredYeaMargin) / 2)
 *             - requiredYeaVotes = ceil(votesCast * requiredYeaVotesFraction / 1e18)
 *             - Yea votes must be > requiredYeaVotes to pass (strict inequality to avoid ties)
 *             - Example: 20% requiredYeaMargin (0.2e18) means yea needs >60% of cast votes
 *             - Example: 0% requiredYeaMargin means yea needs >50% of cast votes
 *
 *             To see why this is the case, let `y` be the percentage of yea votes,
 *             and `n` be the percentage of nay votes, and `m` be the requiredYeaMargin.
 *
 *             The condition for the proposal to pass is `y - n > m`.
 *             Thus, `y > m + n`, which is equivalent to `y > m + (1 - y)` => `2y > m + 1` => `y > (m + 1) / 2`.
 *
 *          These parameters are included on the proposal itself, which are copied from Governance at the
 *          time the proposal is created.
 *
 * @dev     EXAMPLE SCENARIO:
 *          - Total power: 1000 tokens
 *          - Minimum votes: 100 tokens
 *          - Quorum: 40% (0.4e18)
 *          - Required yea margin: 10% (0.1e18)
 *
 *          For a proposal to pass:
 *          1. Total power (1000) must be ≥ minimum votes (100) ✓
 *          2. Votes needed = ceil(1000 * 0.4) = 400 votes minimum
 *          3. If 500 votes cast (300 yea, 200 nay):
 *             - Quorum met: 500 ≥ 400 ✓
 *             - Required yea votes = ceil(500 * ceil(1.1e18/2) / 1e18) = ceil(500 * 0.55) = 275
 *             - Proposal passes: 300 yea > 275 required yea votes ✓
 *
 * @dev     ROUNDING STRATEGY:
 *          All calculations use ceiling rounding to ensure the protocol is never "underpaid"
 *          in terms of required votes. This prevents edge cases where fractional vote
 *          requirements could round down to zero or insufficient thresholds.
 *
 * @dev     PROPOSAL LIFECYCLE:
 *          The library also manages proposal timing through four phases:
 *          1. Pending: creation → creation + votingDelay
 *          2. Active: pending end → pending end + votingDuration
 *          3. Queued: active end → active end + executionDelay
 *          4. Executable: queued end → queued end + gracePeriod
 */
library ProposalLib {
  using CompressedTimeMath for CompressedTimestamp;
  using CompressedProposalLib for CompressedProposal;
  /**
   * @notice Tabulate the votes for a proposal.
   * @dev This function is used to determine if a proposal has met the acceptance criteria.
   *
   * @param _self The proposal to tabulate the votes for.
   * @param _totalPower The total power (in Governance) at proposal.pendingThrough().
   * @return The vote tabulation result, and additional information.
   */

  function voteTabulation(CompressedProposal storage _self, uint256 _totalPower)
    internal
    view
    returns (VoteTabulationReturn, VoteTabulationInfo)
  {
    if (_totalPower < _self.minimumVotes) {
      return (VoteTabulationReturn.Rejected, VoteTabulationInfo.TotalPowerLtMinimum);
    }

    uint256 votesNeeded = Math.mulDiv(_totalPower, _self.quorum, 1e18, Math.Rounding.Ceil);
    if (votesNeeded == 0) {
      return (VoteTabulationReturn.Invalid, VoteTabulationInfo.VotesNeededEqZero);
    }
    if (votesNeeded > _totalPower) {
      return (VoteTabulationReturn.Invalid, VoteTabulationInfo.VotesNeededGtTotalPower);
    }

    (uint256 yea, uint256 nay) = _self.getVotes();
    uint256 votesCast = nay + yea;
    if (votesCast < votesNeeded) {
      return (VoteTabulationReturn.Rejected, VoteTabulationInfo.VotesCastLtVotesNeeded);
    }

    // Edge case where all the votes are yea, no need to compute requiredApprovalVotes.
    // ConfigurationLib enforces that requiredYeaMargin is <= 1e18,
    // i.e. we cannot require more votes to be yes than total votes.
    if (yea == votesCast) {
      return (VoteTabulationReturn.Accepted, VoteTabulationInfo.YeaVotesEqVotesCast);
    }

    uint256 requiredApprovalVotesFraction = Math.ceilDiv(1e18 + _self.requiredYeaMargin, 2);
    uint256 requiredApprovalVotes = Math.mulDiv(votesCast, requiredApprovalVotesFraction, 1e18, Math.Rounding.Ceil);

    /*if (requiredApprovalVotes == 0) {
      // It should be impossible to hit this case as `requiredApprovalVotesFraction` cannot be 0,
      // and due to rounding up, only way to hit this would be if `votesCast = 0`,
      // which is already handled as `votesCast >= votesNeeded` and `votesNeeded > 0`.
      return (VoteTabulationReturn.Invalid, VoteTabulationInfo.YeaLimitEqZero);
    }*/
    if (requiredApprovalVotes > votesCast) {
      return (VoteTabulationReturn.Invalid, VoteTabulationInfo.YeaLimitGtVotesCast);
    }

    // We want to see that there are MORE votes on yea than needed
    // We explicitly need MORE to ensure we don't "tie".
    // If we need as many yea as there are votes, we know it is impossible already.
    // due to the check earlier, that summedBallot.yea == votesCast.
    if (yea <= requiredApprovalVotes) {
      return (VoteTabulationReturn.Rejected, VoteTabulationInfo.YeaVotesLeYeaLimit);
    }

    return (VoteTabulationReturn.Accepted, VoteTabulationInfo.YeaVotesGtYeaLimit);
  }

  /**
   * @notice Get when the pending phase ends
   * @param _compressed Storage pointer to compressed proposal
   * @return The timestamp when pending phase ends
   */
  function pendingThrough(CompressedProposal storage _compressed) internal view returns (Timestamp) {
    return _compressed.creation.decompress() + _compressed.votingDelay.decompress();
  }

  /**
   * @notice Get when the active phase ends
   * @param _compressed Storage pointer to compressed proposal
   * @return The timestamp when active phase ends
   */
  function activeThrough(CompressedProposal storage _compressed) internal view returns (Timestamp) {
    return pendingThrough(_compressed) + _compressed.votingDuration.decompress();
  }

  /**
   * @notice Get when the queued phase ends
   * @param _compressed Storage pointer to compressed proposal
   * @return The timestamp when queued phase ends
   */
  function queuedThrough(CompressedProposal storage _compressed) internal view returns (Timestamp) {
    return activeThrough(_compressed) + _compressed.executionDelay.decompress();
  }

  /**
   * @notice Get when the executable phase ends
   * @param _compressed Storage pointer to compressed proposal
   * @return The timestamp when executable phase ends
   */
  function executableThrough(CompressedProposal storage _compressed) internal view returns (Timestamp) {
    return queuedThrough(_compressed) + _compressed.gracePeriod.decompress();
  }
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

type CompressedStakingQueueConfig is uint256;

library StakingQueueConfigLib {
  using SafeCast for uint256;

  uint256 private constant MASK_32BIT = 0xFFFFFFFF;

  function compress(StakingQueueConfig memory _config) internal pure returns (CompressedStakingQueueConfig) {
    uint256 value = 0;
    value |= uint256(_config.maxQueueFlushSize.toUint32());
    value |= uint256(_config.normalFlushSizeQuotient.toUint32()) << 32;
    value |= uint256(_config.normalFlushSizeMin.toUint32()) << 64;
    value |= uint256(_config.bootstrapFlushSize.toUint32()) << 96;
    value |= uint256(_config.bootstrapValidatorSetSize.toUint32()) << 128;

    return CompressedStakingQueueConfig.wrap(value);
  }

  function decompress(CompressedStakingQueueConfig _compressedConfig)
    internal
    pure
    returns (StakingQueueConfig memory)
  {
    uint256 value = CompressedStakingQueueConfig.unwrap(_compressedConfig);

    return StakingQueueConfig({
      bootstrapValidatorSetSize: (value >> 128) & MASK_32BIT,
      bootstrapFlushSize: (value >> 96) & MASK_32BIT,
      normalFlushSizeMin: (value >> 64) & MASK_32BIT,
      normalFlushSizeQuotient: (value >> 32) & MASK_32BIT,
      maxQueueFlushSize: value & MASK_32BIT
    });
  }
}

struct ProposeWithLockConfiguration {
  Timestamp lockDelay;
  uint256 lockAmount;
}

struct Configuration {
  ProposeWithLockConfiguration proposeConfig;
  Timestamp votingDelay;
  Timestamp votingDuration;
  Timestamp executionDelay;
  Timestamp gracePeriod;
  uint256 quorum;
  uint256 requiredYeaMargin;
  uint256 minimumVotes;
}

struct Withdrawal {
  uint256 amount;
  Timestamp unlocksAt;
  address recipient;
  bool claimed;
}

interface IGovernance {
  event BeneficiaryAdded(address beneficiary);
  event FloodGatesOpened();

  event Proposed(uint256 indexed proposalId, address indexed proposal);
  event VoteCast(uint256 indexed proposalId, address indexed voter, bool support, uint256 amount);
  event ProposalExecuted(uint256 indexed proposalId);
  event ProposalDropped(uint256 indexed proposalId);
  event GovernanceProposerUpdated(address indexed governanceProposer);
  event ConfigurationUpdated(Timestamp indexed time);

  event Deposit(address indexed depositor, address indexed onBehalfOf, uint256 amount);
  event WithdrawInitiated(uint256 indexed withdrawalId, address indexed recipient, uint256 amount);
  event WithdrawFinalized(uint256 indexed withdrawalId);

  function addBeneficiary(address _beneficiary) external;
  function openFloodgates() external;

  function updateGovernanceProposer(address _governanceProposer) external;
  function updateConfiguration(Configuration memory _configuration) external;
  function deposit(address _onBehalfOf, uint256 _amount) external;
  function initiateWithdraw(address _to, uint256 _amount) external returns (uint256);
  function finalizeWithdraw(uint256 _withdrawalId) external;
  function propose(IPayload _proposal) external returns (uint256);
  function proposeWithLock(IPayload _proposal, address _to) external returns (uint256);
  function vote(uint256 _proposalId, uint256 _amount, bool _support) external;
  function execute(uint256 _proposalId) external;
  function dropProposal(uint256 _proposalId) external;

  function isPermittedInGovernance(address _caller) external view returns (bool);
  function isAllBeneficiariesAllowed() external view returns (bool);

  function powerAt(address _owner, Timestamp _ts) external view returns (uint256);
  function powerNow(address _owner) external view returns (uint256);
  function totalPowerAt(Timestamp _ts) external view returns (uint256);
  function totalPowerNow() external view returns (uint256);
  function getProposalState(uint256 _proposalId) external view returns (ProposalState);
  function getConfiguration() external view returns (Configuration memory);
  function getProposal(uint256 _proposalId) external view returns (Proposal memory);
  function getWithdrawal(uint256 _withdrawalId) external view returns (Withdrawal memory);
  function getBallot(uint256 _proposalId, address _user) external view returns (Ballot memory);
}

/**
 * @dev This library defines the `Trace*` struct, for checkpointing values as they change at different points in
 * time, and later looking up past values by block number. See {Votes} as an example.
 *
 * To create a history of checkpoints define a variable type `Checkpoints.Trace*` in your contract, and store a new
 * checkpoint for the current transaction block using the {push} function.
 */
library Checkpoints {
    /**
     * @dev A value was attempted to be inserted on a past checkpoint.
     */
    error CheckpointUnorderedInsertion();

    struct Trace224 {
        Checkpoint224[] _checkpoints;
    }

    struct Checkpoint224 {
        uint32 _key;
        uint224 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace224 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint32).max` key set will disable the
     * library.
     */
    function push(
        Trace224 storage self,
        uint32 key,
        uint224 value
    ) internal returns (uint224 oldValue, uint224 newValue) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace224 storage self, uint32 key) internal view returns (uint224) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace224 storage self) internal view returns (uint224) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace224 storage self) internal view returns (bool exists, uint32 _key, uint224 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint224 storage ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace224 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace224 storage self, uint32 pos) internal view returns (Checkpoint224 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(
        Checkpoint224[] storage self,
        uint32 key,
        uint224 value
    ) private returns (uint224 oldValue, uint224 newValue) {
        uint256 pos = self.length;

        if (pos > 0) {
            Checkpoint224 storage last = _unsafeAccess(self, pos - 1);
            uint32 lastKey = last._key;
            uint224 lastValue = last._value;

            // Checkpoint keys must be non-decreasing.
            if (lastKey > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (lastKey == key) {
                last._value = value;
            } else {
                self.push(Checkpoint224({_key: key, _value: value}));
            }
            return (lastValue, value);
        } else {
            self.push(Checkpoint224({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key strictly bigger than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key greater or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint224[] storage self,
        uint32 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint224[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint224 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace208 {
        Checkpoint208[] _checkpoints;
    }

    struct Checkpoint208 {
        uint48 _key;
        uint208 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace208 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint48).max` key set will disable the
     * library.
     */
    function push(
        Trace208 storage self,
        uint48 key,
        uint208 value
    ) internal returns (uint208 oldValue, uint208 newValue) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace208 storage self, uint48 key) internal view returns (uint208) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace208 storage self) internal view returns (uint208) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace208 storage self) internal view returns (bool exists, uint48 _key, uint208 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint208 storage ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace208 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace208 storage self, uint32 pos) internal view returns (Checkpoint208 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(
        Checkpoint208[] storage self,
        uint48 key,
        uint208 value
    ) private returns (uint208 oldValue, uint208 newValue) {
        uint256 pos = self.length;

        if (pos > 0) {
            Checkpoint208 storage last = _unsafeAccess(self, pos - 1);
            uint48 lastKey = last._key;
            uint208 lastValue = last._value;

            // Checkpoint keys must be non-decreasing.
            if (lastKey > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (lastKey == key) {
                last._value = value;
            } else {
                self.push(Checkpoint208({_key: key, _value: value}));
            }
            return (lastValue, value);
        } else {
            self.push(Checkpoint208({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key strictly bigger than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint208[] storage self,
        uint48 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key greater or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint208[] storage self,
        uint48 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint208[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint208 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }

    struct Trace160 {
        Checkpoint160[] _checkpoints;
    }

    struct Checkpoint160 {
        uint96 _key;
        uint160 _value;
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into a Trace160 so that it is stored as the checkpoint.
     *
     * Returns previous value and new value.
     *
     * IMPORTANT: Never accept `key` as a user input, since an arbitrary `type(uint96).max` key set will disable the
     * library.
     */
    function push(
        Trace160 storage self,
        uint96 key,
        uint160 value
    ) internal returns (uint160 oldValue, uint160 newValue) {
        return _insert(self._checkpoints, key, value);
    }

    /**
     * @dev Returns the value in the first (oldest) checkpoint with key greater or equal than the search key, or zero if
     * there is none.
     */
    function lowerLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _lowerBinaryLookup(self._checkpoints, key, 0, len);
        return pos == len ? 0 : _unsafeAccess(self._checkpoints, pos)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     */
    function upperLookup(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;
        uint256 pos = _upperBinaryLookup(self._checkpoints, key, 0, len);
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the last (most recent) checkpoint with key lower or equal than the search key, or zero
     * if there is none.
     *
     * NOTE: This is a variant of {upperLookup} that is optimised to find "recent" checkpoint (checkpoints with high
     * keys).
     */
    function upperLookupRecent(Trace160 storage self, uint96 key) internal view returns (uint160) {
        uint256 len = self._checkpoints.length;

        uint256 low = 0;
        uint256 high = len;

        if (len > 5) {
            uint256 mid = len - Math.sqrt(len);
            if (key < _unsafeAccess(self._checkpoints, mid)._key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        uint256 pos = _upperBinaryLookup(self._checkpoints, key, low, high);

        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns the value in the most recent checkpoint, or zero if there are no checkpoints.
     */
    function latest(Trace160 storage self) internal view returns (uint160) {
        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : _unsafeAccess(self._checkpoints, pos - 1)._value;
    }

    /**
     * @dev Returns whether there is a checkpoint in the structure (i.e. it is not empty), and if so the key and value
     * in the most recent checkpoint.
     */
    function latestCheckpoint(Trace160 storage self) internal view returns (bool exists, uint96 _key, uint160 _value) {
        uint256 pos = self._checkpoints.length;
        if (pos == 0) {
            return (false, 0, 0);
        } else {
            Checkpoint160 storage ckpt = _unsafeAccess(self._checkpoints, pos - 1);
            return (true, ckpt._key, ckpt._value);
        }
    }

    /**
     * @dev Returns the number of checkpoint.
     */
    function length(Trace160 storage self) internal view returns (uint256) {
        return self._checkpoints.length;
    }

    /**
     * @dev Returns checkpoint at given position.
     */
    function at(Trace160 storage self, uint32 pos) internal view returns (Checkpoint160 memory) {
        return self._checkpoints[pos];
    }

    /**
     * @dev Pushes a (`key`, `value`) pair into an ordered list of checkpoints, either by inserting a new checkpoint,
     * or by updating the last one.
     */
    function _insert(
        Checkpoint160[] storage self,
        uint96 key,
        uint160 value
    ) private returns (uint160 oldValue, uint160 newValue) {
        uint256 pos = self.length;

        if (pos > 0) {
            Checkpoint160 storage last = _unsafeAccess(self, pos - 1);
            uint96 lastKey = last._key;
            uint160 lastValue = last._value;

            // Checkpoint keys must be non-decreasing.
            if (lastKey > key) {
                revert CheckpointUnorderedInsertion();
            }

            // Update or push new checkpoint
            if (lastKey == key) {
                last._value = value;
            } else {
                self.push(Checkpoint160({_key: key, _value: value}));
            }
            return (lastValue, value);
        } else {
            self.push(Checkpoint160({_key: key, _value: value}));
            return (0, value);
        }
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key strictly bigger than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _upperBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key > key) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high;
    }

    /**
     * @dev Return the index of the first (oldest) checkpoint with key greater or equal than the search key, or `high`
     * if there is none. `low` and `high` define a section where to do the search, with inclusive `low` and exclusive
     * `high`.
     *
     * WARNING: `high` should not be greater than the array's length.
     */
    function _lowerBinaryLookup(
        Checkpoint160[] storage self,
        uint96 key,
        uint256 low,
        uint256 high
    ) private view returns (uint256) {
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(self, mid)._key < key) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return high;
    }

    /**
     * @dev Access an element of the array without performing bounds check. The position is assumed to be within bounds.
     */
    function _unsafeAccess(
        Checkpoint160[] storage self,
        uint256 pos
    ) private pure returns (Checkpoint160 storage result) {
        assembly {
            mstore(0, self.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }
}

/**
 * @title Errors Library
 * @author Aztec Labs
 * @notice Library that contains errors used throughout the Aztec governance
 * Errors are prefixed with the contract name to make it easy to identify where the error originated
 * when there are multiple contracts that could have thrown the error.
 */
library Errors_1 {
  error Governance__CallerNotGovernanceProposer(address caller, address governanceProposer);
  error Governance__GovernanceProposerCannotBeSelf();
  error Governance__CallerNotSelf(address caller, address self);
  error Governance__CallerCannotBeSelf();
  error Governance__InsufficientPower(address voter, uint256 have, uint256 required);
  error Governance__CannotWithdrawToAddressZero();
  error Governance__WithdrawalNotInitiated();
  error Governance__WithdrawalAlreadyClaimed();
  error Governance__WithdrawalNotUnlockedYet(Timestamp currentTime, Timestamp unlocksAt);
  error Governance__ProposalNotActive();
  error Governance__ProposalNotExecutable();
  error Governance__CannotCallAsset();
  error Governance__CallFailed(address target);
  error Governance__ProposalDoesNotExists(uint256 proposalId);
  error Governance__ProposalAlreadyDropped();
  error Governance__ProposalCannotBeDropped();
  error Governance__DepositNotAllowed();

  error Governance__CheckpointedUintLib__InsufficientValue(address owner, uint256 have, uint256 required);
  error Governance__CheckpointedUintLib__NotInPast();

  error Governance__ConfigurationLib__InvalidMinimumVotes();
  error Governance__ConfigurationLib__LockAmountTooSmall();
  error Governance__ConfigurationLib__LockAmountTooBig();
  error Governance__ConfigurationLib__QuorumTooSmall();
  error Governance__ConfigurationLib__QuorumTooBig();
  error Governance__ConfigurationLib__RequiredYeaMarginTooBig();
  error Governance__ConfigurationLib__TimeTooSmall(string name);
  error Governance__ConfigurationLib__TimeTooBig(string name);

  error EmpireBase__FailedToSubmitRoundWinner(IPayload payload);
  error EmpireBase__InstanceHaveNoCode(address instance);
  error EmpireBase__InsufficientSignals(uint256 signalsCast, uint256 signalsNeeded);
  error EmpireBase__InvalidQuorumAndRoundSize(uint256 quorumSize, uint256 roundSize);
  error EmpireBase__QuorumCannotBeLargerThanRoundSize(uint256 quorumSize, uint256 roundSize);
  error EmpireBase__InvalidLifetimeAndExecutionDelay(uint256 lifetimeInRounds, uint256 executionDelayInRounds);
  error EmpireBase__OnlyProposerCanSignal(address caller, address proposer);
  error EmpireBase__PayloadAlreadySubmitted(uint256 roundNumber);
  error EmpireBase__PayloadCannotBeAddressZero();
  error EmpireBase__RoundTooOld(uint256 roundNumber, uint256 currentRoundNumber);
  error EmpireBase__RoundTooNew(uint256 roundNumber, uint256 currentRoundNumber);
  error EmpireBase__SignalAlreadyCastForSlot(Slot slot);
  error GovernanceProposer__GSEPayloadInvalid();

  error CoinIssuer__InsufficientMintAvailable(uint256 available, uint256 needed); // 0xa1cc8799
  error CoinIssuer__InvalidConfiguration();

  error Registry__RollupAlreadyRegistered(address rollup); // 0x3c34eabf
  error Registry__RollupNotRegistered(uint256 version);
  error Registry__NoRollupsRegistered();

  error RewardDistributor__InvalidCaller(address caller, address canonical); // 0xb95e39f6
  error RewardDistributor__InsufficientAvailable(uint256 requested, uint256 available);
  error RewardDistributor__ZeroRollup();
  error RewardDistributor__WrongRecoverMechanism();

  error GSE__NotRollup(address);
  error GSE__GovernanceAlreadySet();
  error GSE__InvalidRollupAddress(address);
  error GSE__RollupAlreadyRegistered(address);
  error GSE__NotLatestRollup(address);
  error GSE__AlreadyRegistered(address, address);
  error GSE__NothingToExit(address);
  error GSE__InsufficientBalance(uint256, uint256);
  error GSE__FailedToRemove(address);
  error GSE__InstanceDoesNotExist(address);
  error GSE__NotWithdrawer(address, address);
  error GSE__OutOfBounds(uint256, uint256);
  error GSE__FatalError(string);
  error GSE__InvalidProofOfPossession();
  error GSE__CannotChangePublicKeys(uint256 existingPk1x, uint256 existingPk1y);
  error GSE__ProofOfPossessionAlreadySeen(bytes32 hashedPK1);

  error Delegation__InsufficientPower(address, uint256, uint256);
}

/**
 * @title CheckpointedUintLib
 * @notice  Library for managing Trace224 using a timestamp as key,
 *          Provides helper functions to `add` to or `sub` from the current value.
 */
library CheckpointedUintLib {
  using Checkpoints for Checkpoints.Trace224;
  using SafeCast for uint256;

  /**
   * @notice  Add `_amount` to the current value
   *
   * @dev   The amounts are cast to uint224 before storing such that the (key: value) fits in a single slot
   *
   * @param _self - The Trace224 to add to
   * @param _amount - The amount to add
   *
   * @return - The current value and the new value
   */
  function add(Checkpoints.Trace224 storage _self, uint256 _amount) internal returns (uint256, uint256) {
    uint224 current = _self.latest();
    if (_amount == 0) {
      return (current, current);
    }
    uint224 amount = _amount.toUint224();
    _self.push(block.timestamp.toUint32(), current + amount);
    return (current, current + amount);
  }

  /**
   * @notice  Subtract `_amount` from the current value
   *
   * @param _self - The Trace224 to subtract from
   * @param _amount - The amount to subtract
   * @return - The current value and the new value
   */
  function sub(Checkpoints.Trace224 storage _self, uint256 _amount) internal returns (uint256, uint256) {
    uint224 current = _self.latest();
    if (_amount == 0) {
      return (current, current);
    }
    uint224 amount = _amount.toUint224();
    require(current >= amount, Errors_1.Governance__CheckpointedUintLib__InsufficientValue(msg.sender, current, amount));
    _self.push(block.timestamp.toUint32(), current - amount);
    return (current, current - amount);
  }

  /**
   * @notice  Get the current value
   *
   * @param _self - The Trace224 to get the value of
   * @return - The current value
   */
  function valueNow(Checkpoints.Trace224 storage _self) internal view returns (uint256) {
    return _self.latest();
  }

  /**
   * @notice  Get the value at a given timestamp
   *          The timestamp MUST be in the past to guarantee it is stable
   *
   * @dev     Uses `upperLookupRecent` instead of just `upperLookup` as it will most
   *          likely be a recent value when looked up as part of governance.
   *
   * @param _self - The Trace224 to get the value of
   * @param _time - The timestamp to get the value at
   * @return - The value at the given timestamp
   */
  function valueAt(Checkpoints.Trace224 storage _self, Timestamp _time) internal view returns (uint256) {
    require(_time < Timestamp.wrap(block.timestamp), Errors_1.Governance__CheckpointedUintLib__NotInPast());
    return _self.upperLookupRecent(Timestamp.unwrap(_time).toUint32());
  }
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface Governance is IGovernance {
    function governanceProposer() external view returns (address);
    function deposit(address _beneficiary, uint256 _amount) external override(IGovernance);
    function initiateWithdraw(address _to, uint256 _amount) external override(IGovernance) returns (uint256);
    function finalizeWithdraw(uint256 _withdrawalId) external override(IGovernance);
    function propose(IPayload _proposal) external override(IGovernance) returns (uint256);
    function proposeWithLock(IPayload _proposal, address _to) external override(IGovernance) returns (uint256);
    function vote(uint256 _proposalId, uint256 _amount, bool _support) external override(IGovernance);
    function getConfiguration() external view override(IGovernance) returns (Configuration memory);
    function getProposal(uint256 _proposalId) external view override(IGovernance) returns (Proposal memory);
    function getWithdrawal(uint256 _withdrawalId) external view override(IGovernance) returns (Withdrawal memory);
}

interface IGSECore {
  event Deposit(address indexed instance, address indexed attester, address withdrawer);

  function setGovernance(Governance _governance) external;
  function setProofOfPossessionGasLimit(uint64 _proofOfPossessionGasLimit) external;
  function addRollup(address _rollup) external;
  function deposit(
    address _attester,
    address _withdrawer,
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession,
    bool _moveWithLatestRollup
  ) external;
  function withdraw(address _attester, uint256 _amount) external returns (uint256, bool, uint256);
  function delegate(address _instance, address _attester, address _delegatee) external;
  function vote(uint256 _proposalId, uint256 _amount, bool _support) external;
  function voteWithBonus(uint256 _proposalId, uint256 _amount, bool _support) external;
  function finalizeWithdraw(uint256 _withdrawalId) external;
  function proposeWithLock(IPayload _proposal, address _to) external returns (uint256);

  function isRegistered(address _instance, address _attester) external view returns (bool);
  function isRollupRegistered(address _instance) external view returns (bool);
  function getLatestRollup() external view returns (address);
  function getLatestRollupAt(Timestamp _timestamp) external view returns (address);
  function getGovernance() external view returns (Governance);
}

// Struct to store configuration of an attester (checkpoint producer)
// Keep track of the actor who can initiate and control withdraws for the attester.
// Keep track of the public key in G1 of BN254 that has registered on the instance
struct AttesterConfig {
  G1Point publicKey;
  address withdrawer;
}

interface IGSE is IGSECore {
  function getRegistrationDigest(G1Point memory _publicKey) external view returns (G1Point memory);
  function getDelegatee(address _instance, address _attester) external view returns (address);
  function getVotingPower(address _attester) external view returns (uint256);
  function getVotingPowerAt(address _attester, Timestamp _timestamp) external view returns (uint256);

  function getWithdrawer(address _attester) external view returns (address);
  function balanceOf(address _instance, address _attester) external view returns (uint256);
  function effectiveBalanceOf(address _instance, address _attester) external view returns (uint256);
  function supplyOf(address _instance) external view returns (uint256);
  function totalSupply() external view returns (uint256);
  function getConfig(address _attester) external view returns (AttesterConfig memory);
  function getAttesterCountAtTime(address _instance, Timestamp _timestamp) external view returns (uint256);

  function getAttestersFromIndicesAtTime(address _instance, Timestamp _timestamp, uint256[] memory _indices)
    external
    view
    returns (address[] memory);
  function getG1PublicKeysFromAddresses(address[] memory _attesters) external view returns (G1Point[] memory);
  function getAttesterFromIndexAtTime(address _instance, uint256 _index, Timestamp _timestamp)
    external
    view
    returns (address);
  function getPowerUsed(address _delegatee, uint256 _proposalId) external view returns (uint256);
  function getBonusInstanceAddress() external view returns (address);
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IBn254LibWrapper {
  function proofOfPossession(
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession
  ) external view returns (bool);

  function g1ToDigestPoint(G1Point memory pk1) external view returns (G1Point memory);
}

/**
 * Credit:
 * Primary inspiration from https://hackmd.io/7B4nfNShSY2Cjln-9ViQrA, which points out the
 * optimization of linking/using a G1 and G2 key and provides an implementation for
 * the hashToPoint and sqrt functions.
 */

/**
 * Library for registering public keys and computing BLS signatures over the BN254 curve.
 * The BN254 curve has been chosen over the BLS12-381 curve for gas efficiency, and
 * because the Aztec rollup's security is already reliant on BN254.
 */
library BN254Lib {
  /**
   * We use uint256[2] for G1 points and uint256[4] for G2 points.
   * For G1 points, the expected order is (x, y).
   * For G2 points, the expected order is (x_imaginary, x_real, y_imaginary, y_real)
   * Using structs would be more readable, but it would be more expensive to use them, particularly
   * when aggregating the public keys, since we need to convert to uint256[2] and uint256[4] anyway.
   */
  // See bn254_registration.test.ts and BLSKey.t.sol for tests which validate these constants.
  uint256 public constant BASE_FIELD_ORDER =
    21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583;

  uint256 public constant GROUP_ORDER =
    21_888_242_871_839_275_222_246_405_745_257_275_088_548_364_400_416_034_343_698_204_186_575_808_495_617;

  bytes32 public constant STAKING_DOMAIN_SEPARATOR = bytes32("AZTEC_BLS_POP_BN254_V1");

  error AddPointFail();
  error MulPointFail();
  error GammaZero();
  error SqrtFail();
  error PairingFail();
  error NoPointFound();
  error InfinityNotAllowed();

  /**
   * @notice Prove possession of a secret for a point in G1 and G2.
   *
   * Ultimately, we want to check:
   * - That the caller knows the secret key of pk2 (to prevent rogue-key attacks)
   * - That pk1 and pk2 have the same secret key (as an optimization)
   *
   * Registering two public keys is an optimization: It means we can do G1-only operations
   * at the time of verifying a signature, which is much cheaper than G2 operations.
   *
   * In this function, we check:
   * e(signature + gamma * pk1, -G2) * e(hashToPoint(pk1) + gamma * G1, pk2) == 1
   *
   * Which is effectively a check that:
   * e(signature, G2) == e(hashToPoint(pk1), pk2) // a BLS signature over msg = pk1, to prove knowledge of the sk.
   * e(pk1, G2) == e(G1, pk2) // a demonstration that pk1 and pk2 have the same sk.
   *
   * @param pk1 The G1 point of the BLS public key (x, y coordinates)
   * @param pk2 The G2 point of the BLS public key (x_1, x_0, y_1, y_0 coordinates)
   * @param signature The G1 point that acts as a proof of possession of the private keys corresponding to pk1 and pk2
   */
  function proofOfPossession(G1Point memory pk1, G2Point memory pk2, G1Point memory signature)
    internal
    view
    returns (bool)
  {
    // Ensure that provided points are not infinity
    require(!isZero(pk1), InfinityNotAllowed());
    require(!isZero(pk2), InfinityNotAllowed());
    require(!isZero(signature), InfinityNotAllowed());

    // Compute the point "digest" of the pk1 that sigma is a signature over
    G1Point memory pk1DigestPoint = g1ToDigestPoint(pk1);

    // Random challenge:
    // gamma = keccak(pk1, pk2, signature) mod |Fr|
    uint256 gamma = gammaOf(pk1, pk2, signature);
    require(gamma != 0, GammaZero());

    // Build G1 L = signature + gamma * pk1
    G1Point memory left = g1Add(signature, g1Mul(pk1, gamma));

    // Build G1 R = pk1DigestPoint + gamma * G1
    G1Point memory right = g1Add(pk1DigestPoint, g1Mul(g1Generator(), gamma));

    // Pairing: e(L, -G2) * e(R, pk2) == 1
    return bn254Pairing(left, g2NegatedGenerator(), right, pk2);
  }

  /// @notice Convert a G1 point (public key) to the digest point that must be signed to prove possession.
  /// @dev exposed as public to allow clients not to have implemented the hashToPoint function.
  function g1ToDigestPoint(G1Point memory pk1) internal view returns (G1Point memory) {
    bytes memory pk1Bytes = abi.encodePacked(pk1.x, pk1.y);
    return hashToPoint(STAKING_DOMAIN_SEPARATOR, pk1Bytes);
  }

  /// @dev Add two points on BN254 G1 (affine coords).
  ///      Reverts if the inputs are not on‐curve.
  function g1Add(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory output) {
    uint256[4] memory input;
    input[0] = p1.x;
    input[1] = p1.y;
    input[2] = p2.x;
    input[3] = p2.y;

    bool success;
    assembly {
      // call(gas, to, value, in, insize, out, outsize)
      // STATICCALL is 40 gas vs 700 gas for CALL
      success := staticcall(
        sub(gas(), 2000),
        0x06, // precompile address
        input,
        0x80, // input size = 4 × 32 bytes
        output,
        0x40 // output size = 2 × 32 bytes
      )
    }

    if (!success) revert AddPointFail();
    return output;
  }

  /// @dev Multiply a point by a scalar (little‑endian 256‑bit integer).
  ///      Reverts if the point is not on‐curve or the scalar ≥ p.
  function g1Mul(G1Point memory p, uint256 s) internal view returns (G1Point memory output) {
    uint256[3] memory input;
    input[0] = p.x;
    input[1] = p.y;
    input[2] = s;

    bool success;
    assembly {
      success := staticcall(
        sub(gas(), 2000),
        0x07, // precompile address
        input,
        0x60, // input size = 3 × 32 bytes
        output,
        0x40 // output size = 2 × 32 bytes
      )
    }
    if (!success) revert MulPointFail();
    return output;
  }

  function bn254Pairing(G1Point memory g1a, G2Point memory g2a, G1Point memory g1b, G2Point memory g2b)
    internal
    view
    returns (bool)
  {
    uint256[12] memory input;

    input[0] = g1a.x;
    input[1] = g1a.y;
    input[2] = g2a.x1;
    input[3] = g2a.x0;
    input[4] = g2a.y1;
    input[5] = g2a.y0;

    input[6] = g1b.x;
    input[7] = g1b.y;
    input[8] = g2b.x1;
    input[9] = g2b.x0;
    input[10] = g2b.y1;
    input[11] = g2b.y0;

    uint256[1] memory result;
    bool didCallSucceed;
    assembly {
      didCallSucceed := staticcall(
        sub(gas(), 2000),
        8,
        input,
        0x180, // input size = 12 * 32 bytes
        result,
        0x20 // output size = 32 bytes
      )
    }
    require(didCallSucceed, PairingFail());
    return result[0] == 1;
  }

  // The hash to point is based on the "mapToPoint" function in https://www.iacr.org/archive/asiacrypt2001/22480516.pdf
  function hashToPoint(bytes32 domain, bytes memory message) internal view returns (G1Point memory output) {
    bool found = false;
    uint256 attempts = 0;
    while (true) {
      uint256 x = uint256(keccak256(abi.encode(domain, message, attempts)));
      attempts++;

      if (x >= BASE_FIELD_ORDER) {
        continue;
      }

      uint256 y = mulmod(x, x, BASE_FIELD_ORDER);
      y = mulmod(y, x, BASE_FIELD_ORDER);
      y = addmod(y, 3, BASE_FIELD_ORDER);
      (y, found) = sqrt(y);
      if (found) {
        uint256 y0 = y;
        uint256 y1 = BASE_FIELD_ORDER - y;

        // Ensure that y1 > y0, flip em if necessary
        if (y0 > y1) {
          (y0, y1) = (y1, y0);
        }

        uint256 b = uint256(keccak256(abi.encode(domain, message, type(uint256).max)));
        if (b & 1 == 0) {
          output = G1Point({x: x, y: y0});
        } else {
          output = G1Point({x: x, y: y1});
        }

        break;
      }
    }
    require(found, NoPointFound());
    return output;
  }

  function sqrt(uint256 xx) internal view returns (uint256 x, bool hasRoot) {
    bool callSuccess;
    assembly {
      let freeMem := mload(0x40)
      mstore(freeMem, 0x20)
      mstore(add(freeMem, 0x20), 0x20)
      mstore(add(freeMem, 0x40), 0x20)
      mstore(add(freeMem, 0x60), xx)
      // (N + 1) / 4 = 0xc19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52
      mstore(add(freeMem, 0x80), 0xc19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52)
      // N = BASE_FIELD_ORDER
      mstore(add(freeMem, 0xA0), BASE_FIELD_ORDER)
      callSuccess := staticcall(sub(gas(), 2000), 5, freeMem, 0xC0, freeMem, 0x20)
      x := mload(freeMem)
      hasRoot := eq(xx, mulmod(x, x, BASE_FIELD_ORDER))
    }
    require(callSuccess, SqrtFail());
  }

  /// @notice γ = keccak(PK1, PK2, σ_init) mod Fr
  function gammaOf(G1Point memory pk1, G2Point memory pk2, G1Point memory sigmaInit) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(pk1.x, pk1.y, pk2.x0, pk2.x1, pk2.y0, pk2.y1, sigmaInit.x, sigmaInit.y)))
      % GROUP_ORDER;
  }

  function g1Negate(G1Point memory p) internal pure returns (G1Point memory) {
    if (p.x == 0 && p.y == 0) {
      // Point at infinity remains unchanged
      return p;
    }

    // For a point (x, y), its negation is (x, -y mod p)
    // Since we're working in the field Fp, -y mod p = p - y
    return G1Point({x: p.x, y: BASE_FIELD_ORDER - p.y});
  }

  function g1Zero() internal pure returns (G1Point memory) {
    return G1Point({x: 0, y: 0});
  }

  function isZero(G1Point memory p) internal pure returns (bool) {
    return p.x == 0 && p.y == 0;
  }

  function g1Generator() internal pure returns (G1Point memory) {
    return G1Point({x: 1, y: 2});
  }

  function g2Zero() internal pure returns (G2Point memory) {
    return G2Point({x0: 0, x1: 0, y0: 0, y1: 0});
  }

  function isZero(G2Point memory p) internal pure returns (bool) {
    return p.x0 == 0 && p.x1 == 0 && p.y0 == 0 && p.y1 == 0;
  }

  function g2NegatedGenerator() internal pure returns (G2Point memory) {
    return G2Point({
      x0: 10_857_046_999_023_057_135_944_570_762_232_829_481_370_756_359_578_518_086_990_519_993_285_655_852_781,
      x1: 11_559_732_032_986_387_107_991_004_021_392_285_783_925_812_861_821_192_530_917_403_151_452_391_805_634,
      y0: 13_392_588_948_715_843_804_641_432_497_768_002_650_278_120_570_034_223_513_918_757_245_338_268_106_653,
      y1: 17_805_874_995_975_841_540_914_202_342_111_839_520_379_459_829_704_422_454_583_296_818_431_106_115_052
    });
  }
}

contract Bn254LibWrapper is IBn254LibWrapper {
  function proofOfPossession(
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession
  ) external view override(IBn254LibWrapper) returns (bool) {
    return BN254Lib.proofOfPossession(_publicKeyInG1, _publicKeyInG2, _proofOfPossession);
  }

  function g1ToDigestPoint(G1Point memory pk1) external view override(IBn254LibWrapper) returns (G1Point memory) {
    return BN254Lib.g1ToDigestPoint(pk1);
  }
}

struct Index {
  bool exists;
  uint224 index;
}

/**
 * @notice Structure to store a set of addresses with their historical snapshots
 * @param size The timestamped history of the number of addresses in the set
 * @param indexToAddressHistory Mapping of index to array of timestamped address history
 * @param addressToCurrentIndex Mapping of address to its current index in the set
 */
struct SnapshottedAddressSet {
  // This size must also be snapshotted
  Checkpoints.Trace224 size;
  // For each index, store the timestamped history of addresses
  mapping(uint256 index => Checkpoints.Trace224) indexToAddressHistory;
  // For each address, store its current index in the set
  mapping(address addr => Index index) addressToCurrentIndex;
}

error AddressSnapshotLib__CannotAddAddressZero();

// AddressSnapshotLib
error AddressSnapshotLib__IndexOutOfBounds(uint256 index, uint256 size);

/**
 * @title AddressSnapshotLib
 * @notice A library for managing a set of addresses with historical snapshots
 * @dev This library provides functionality similar to EnumerableSet but can track addresses across time
 *      and allows querying the state of addresses at any point in time. This is used to track the
 *      list of stakers on a particular rollup instance in the GSE throughout time.
 *
 * The SnapshottedAddressSet is maintained such that the you can take a timestamp, and from it:
 * 1. Get the `size` of the set at that timestamp
 * 2. Query the first `size` indices in `indexToAddressHistory` at that timestamp to get a set of addresses of size
 * `size`
 */
library AddressSnapshotLib {
  using SafeCast for *;
  using Checkpoints for Checkpoints.Trace224;

  /**
   * @notice Adds a validator to the set
   * @param _self The storage reference to the set
   * @param _address The address to add
   * @return bool True if the address was added, false if it was already present
   */
  function add(SnapshottedAddressSet storage _self, address _address) internal returns (bool) {
    require(_address != address(0), AddressSnapshotLib__CannotAddAddressZero());
    // Prevent against double insertion
    if (_self.addressToCurrentIndex[_address].exists) {
      return false;
    }

    uint224 index = _self.size.latest();
    _self.addressToCurrentIndex[_address] = Index({exists: true, index: index});

    uint32 key = block.timestamp.toUint32();

    _self.indexToAddressHistory[index].push(key, uint160(_address).toUint224());
    _self.size.push(key, (index + 1).toUint224());

    return true;
  }

  /**
   * @notice Removes a address from the set by address
   *
   * @param _self The storage reference to the set
   * @param _address The address of the address to remove
   * @return bool True if the address was removed, false if it wasn't found
   */
  function remove(SnapshottedAddressSet storage _self, address _address) internal returns (bool) {
    Index memory index = _self.addressToCurrentIndex[_address];
    if (!index.exists) {
      return false;
    }

    return _remove(_self, index.index, _address);
  }

  /**
   * @notice Removes a validator from the set by index
   * @param _self The storage reference to the set
   * @param _index The index of the validator to remove
   * @return bool True if the validator was removed, reverts otherwise
   */
  function remove(SnapshottedAddressSet storage _self, uint224 _index) internal returns (bool) {
    address _address = address(_self.indexToAddressHistory[_index].latest().toUint160());
    return _remove(_self, _index, _address);
  }

  /**
   * @notice Removes a validator from the set
   * @param _self The storage reference to the set
   * @param _index The index of the validator to remove
   * @param _address The address to remove
   * @return bool True if the validator was removed, reverts otherwise
   */
  function _remove(SnapshottedAddressSet storage _self, uint224 _index, address _address) internal returns (bool) {
    uint224 currentSize = _self.size.latest();
    if (_index >= currentSize) {
      revert AddressSnapshotLib__IndexOutOfBounds(_index, currentSize);
    }

    // Mark the address to remove as not existing
    _self.addressToCurrentIndex[_address] = Index({exists: false, index: 0});

    // Now we need to update the indexToAddressHistory.
    // Suppose the current size is 3, and we are removing Bob from index 1, and Charlie is at index 2.
    // We effectively push Charlie into the snapshot at index 1,
    // then update Charlie in addressToCurrentIndex to reflect the new index of 1.

    uint224 lastIndex = currentSize - 1;
    uint32 key = block.timestamp.toUint32();

    // If not removing the last item, swap the value of the last item into the `_index` to remove
    if (lastIndex != _index) {
      address lastValidator = address(_self.indexToAddressHistory[lastIndex].latest().toUint160());

      _self.addressToCurrentIndex[lastValidator] = Index({exists: true, index: _index.toUint224()});
      _self.indexToAddressHistory[_index].push(key, uint160(lastValidator).toUint224());
    }

    // Then "pop" the last index by setting the value to `address(0)`
    _self.indexToAddressHistory[lastIndex].push(key, uint224(0));

    // Finally, we update the size to reflect the new size of the set.
    _self.size.push(key, (lastIndex).toUint224());
    return true;
  }

  /**
   * @notice Gets the current address at a specific index at the time right now
   * @param _self The storage reference to the set
   * @param _index The index to query
   * @return address The current address at the given index
   */
  function at(SnapshottedAddressSet storage _self, uint256 _index) internal view returns (address) {
    return getAddressFromIndexAtTimestamp(_self, _index, block.timestamp.toUint32());
  }

  /**
   * @notice Gets the address at a specific index and timestamp
   * @param _self The storage reference to the set
   * @param _index The index to query
   * @param _timestamp The timestamp to query
   * @return address The address at the given index and timestamp
   */
  function getAddressFromIndexAtTimestamp(SnapshottedAddressSet storage _self, uint256 _index, uint32 _timestamp)
    internal
    view
    returns (address)
  {
    uint256 size = lengthAtTimestamp(_self, _timestamp);
    require(_index < size, AddressSnapshotLib__IndexOutOfBounds(_index, size));

    // Since the _index is less than the size, we know that the address at _index
    // exists at/before _timestamp.
    uint224 addr = _self.indexToAddressHistory[_index].upperLookup(_timestamp);
    return address(addr.toUint160());
  }

  /**
   * @notice Gets the address at a specific index and timestamp
   *
   * @dev     The caller MUST have ensure that `_index` < `size`
   *          at the `_timestamp` provided.
   * @dev     Primed for recent checkpoints in the address history.
   *
   * @param _self The storage reference to the set
   * @param _index The index to query
   * @param _timestamp The timestamp to query
   * @return address The address at the given index and timestamp
   */
  function unsafeGetRecentAddressFromIndexAtTimestamp(
    SnapshottedAddressSet storage _self,
    uint256 _index,
    uint32 _timestamp
  ) internal view returns (address) {
    uint224 addr = _self.indexToAddressHistory[_index].upperLookupRecent(_timestamp);
    return address(addr.toUint160());
  }

  /**
   * @notice Gets the current size of the set
   * @param _self The storage reference to the set
   * @return uint256 The number of addresses in the set
   */
  function length(SnapshottedAddressSet storage _self) internal view returns (uint256) {
    return lengthAtTimestamp(_self, block.timestamp.toUint32());
  }

  /**
   * @notice Gets the size of the set at a specific timestamp
   * @param _self The storage reference to the set
   * @param _timestamp The timestamp to query
   * @return uint256 The number of addresses in the set at the given timestamp
   *
   * @dev Note, the values returned from this function are in flux if the timestamp is in the future.
   */
  function lengthAtTimestamp(SnapshottedAddressSet storage _self, uint32 _timestamp) internal view returns (uint256) {
    return _self.size.upperLookup(_timestamp);
  }

  /**
   * @notice Gets all current addresses in the set
   *
   * @dev This function is only used in tests.
   *
   * @param _self The storage reference to the set
   * @return address[] Array of all current addresses in the set
   */
  function values(SnapshottedAddressSet storage _self) internal view returns (address[] memory) {
    return valuesAtTimestamp(_self, block.timestamp.toUint32());
  }

  /**
   * @notice Gets all addresses in the set at a specific timestamp
   *
   * @dev This function is only used in tests.
   *
   * @param _self The storage reference to the set
   * @param _timestamp The timestamp to query
   * @return address[] Array of all addresses in the set at the given timestamp
   *
   * @dev Note, the values returned from this function are in flux if the timestamp is in the future.
   *
   */
  function valuesAtTimestamp(SnapshottedAddressSet storage _self, uint32 _timestamp)
    internal
    view
    returns (address[] memory)
  {
    uint256 size = lengthAtTimestamp(_self, _timestamp);
    address[] memory vals = new address[](size);
    for (uint256 i; i < size;) {
      vals[i] = getAddressFromIndexAtTimestamp(_self, i, _timestamp);

      unchecked {
        ++i;
      }
    }
    return vals;
  }

  function contains(SnapshottedAddressSet storage _self, address _address) internal view returns (bool) {
    return _self.addressToCurrentIndex[_address].exists;
  }
}

// A struct storing balance and delegatee for an attester
struct DepositPosition {
  uint256 balance;
  address delegatee;
}

// A struct storing all the positions for an instance along with a supply
struct DepositLedger {
  mapping(address attester => DepositPosition position) positions;
  Checkpoints.Trace224 supply;
}

// A struct storing the voting power used for each proposal for a delegatee
// as well as their checkpointed voting power
struct VotingAccount {
  mapping(uint256 proposalId => uint256 powerUsed) powerUsed;
  Checkpoints.Trace224 votingPower;
}

// A struct storing the ledgers for the individual rollup instances, the voting
// account for delegatees and the total supply.
struct DepositAndDelegationAccounting {
  mapping(address instance => DepositLedger ledger) ledgers;
  mapping(address delegatee => VotingAccount votingAccount) votingAccounts;
  Checkpoints.Trace224 supply;
}

// This library have a lot of overlap with `Votes.sol` from Openzeppelin,
// It mainly differs as it is a library to allow us having many accountings in the same contract
// the unit of time and allowing multiple uses of power.
library DepositDelegationLib {
  using CheckpointedUintLib for Checkpoints.Trace224;

  event DelegateChanged(address indexed attester, address oldDelegatee, address newDelegatee);
  event DelegateVotesChanged(address indexed delegatee, uint256 oldValue, uint256 newValue);

  /**
   * @notice Increase the balance of an `_attester` on `_instance` by `_amount`,
   *         increases the voting power of the delegatee equally.
   *
   * @param _self The DepositAndDelegationAccounting struct to modify in storage
   * @param _instance The instance that the attester is on
   * @param _attester The attester to increase the balance of
   * @param _amount The amount to increase by
   */
  function increaseBalance(
    DepositAndDelegationAccounting storage _self,
    address _instance,
    address _attester,
    uint256 _amount
  ) internal {
    if (_amount == 0) {
      return;
    }

    DepositLedger storage instance = _self.ledgers[_instance];

    instance.positions[_attester].balance += _amount;
    moveVotingPower(_self, address(0), instance.positions[_attester].delegatee, _amount);

    instance.supply.add(_amount);
    _self.supply.add(_amount);
  }

  /**
   * @notice Decrease the balance of an `_attester` on `_instance` by `_amount`,
   *         decrease the voting power of the delegatee equally
   *
   * @param _self The DepositAndDelegationAccounting struct to modify in storage
   * @param _instance The instance that the attester is on
   * @param _attester The attester to decrease the balance of
   * @param _amount The amount to decrease by
   */
  function decreaseBalance(
    DepositAndDelegationAccounting storage _self,
    address _instance,
    address _attester,
    uint256 _amount
  ) internal {
    if (_amount == 0) {
      return;
    }

    DepositLedger storage instance = _self.ledgers[_instance];

    instance.positions[_attester].balance -= _amount;
    moveVotingPower(_self, instance.positions[_attester].delegatee, address(0), _amount);

    instance.supply.sub(_amount);
    _self.supply.sub(_amount);
  }

  /**
   * @notice    Use `_amount` of `_delegatee`'s voting power on `_proposalId`
   *            The `_delegatee`'s voting power based on the snapshot at `_timestamp`
   *
   * @dev       If different timestamps are passed, it can cause mismatch in the amount of
   *            power that can be voted with, so it is very important that it is stable for
   *            a given `_proposalId`
   *
   * @param _self       - The DelegationDate struct to modify in storage
   * @param _delegatee  - The delegatee using their power
   * @param _proposalId - The id to use for accounting
   * @param _timestamp  - The timestamp for voting power of the specific `_proposalId`
   * @param _amount     - The amount of power to use
   */
  function usePower(
    DepositAndDelegationAccounting storage _self,
    address _delegatee,
    uint256 _proposalId,
    Timestamp _timestamp,
    uint256 _amount
  ) internal {
    uint256 powerAt = getVotingPowerAt(_self, _delegatee, _timestamp);
    uint256 powerUsed = getPowerUsed(_self, _delegatee, _proposalId);

    require(
      powerAt >= powerUsed + _amount, Errors_1.Delegation__InsufficientPower(_delegatee, powerAt, powerUsed + _amount)
    );

    _self.votingAccounts[_delegatee].powerUsed[_proposalId] += _amount;
  }

  /**
   * @notice Delegate the voting power of an `_attester` on a specific `_instance` to a `_delegatee`
   *
   * @param _self The DepositAndDelegationAccounting struct to modify in storage
   * @param _instance The instance the attester is on
   * @param _attester The attester to delegate the voting power of
   * @param _delegatee The delegatee to delegate the voting power to
   */
  function delegate(
    DepositAndDelegationAccounting storage _self,
    address _instance,
    address _attester,
    address _delegatee
  ) internal {
    address oldDelegate = getDelegatee(_self, _instance, _attester);
    if (oldDelegate == _delegatee) {
      return;
    }
    _self.ledgers[_instance].positions[_attester].delegatee = _delegatee;
    emit DelegateChanged(_attester, oldDelegate, _delegatee);

    moveVotingPower(_self, oldDelegate, _delegatee, getBalanceOf(_self, _instance, _attester));
  }

  /**
   * @notice Convenience function to remove delegation from `_attester` at `_instance`
   *
   * @dev Similar as calling `delegate` with `_delegatee = address(0)`
   *
   * @param _self The DepositAndDelegationAccounting struct to modify in storage
   * @param _instance The instance that the attester is on
   * @param _attester The attester to undelegate the voting power of
   */
  function undelegate(DepositAndDelegationAccounting storage _self, address _instance, address _attester) internal {
    delegate(_self, _instance, _attester, address(0));
  }

  /**
   * @notice Get the balance of an `_attester` on `_instance`
   *
   * @param _self The DepositAndDelegationAccounting struct to read from
   * @param _instance The instance that the attester is on
   * @param _attester The attester to get the balance of
   *
   * @return The balance of the attester
   */
  function getBalanceOf(DepositAndDelegationAccounting storage _self, address _instance, address _attester)
    internal
    view
    returns (uint256)
  {
    return _self.ledgers[_instance].positions[_attester].balance;
  }

  /**
   * @notice Get the supply of an `_instance`
   *
   * @param _self The DepositAndDelegationAccounting struct to read from
   * @param _instance The instance to get the supply of
   *
   * @return The supply of the instance
   */
  function getSupplyOf(DepositAndDelegationAccounting storage _self, address _instance)
    internal
    view
    returns (uint256)
  {
    return _self.ledgers[_instance].supply.valueNow();
  }

  /**
   * @notice Get the total supply of all instances
   *
   * @param _self The DepositAndDelegationAccounting struct to read from
   *
   * @return The total supply of all instances
   */
  function getSupply(DepositAndDelegationAccounting storage _self) internal view returns (uint256) {
    return _self.supply.valueNow();
  }

  /**
   * @notice Get the delegatee of an `_attester` on `_instance`
   *
   * @param _self The DepositAndDelegationAccounting struct to read from
   * @param _instance The instance that the attester is on
   * @param _attester The attester to get the delegatee of
   *
   * @return The delegatee of the attester
   */
  function getDelegatee(DepositAndDelegationAccounting storage _self, address _instance, address _attester)
    internal
    view
    returns (address)
  {
    return _self.ledgers[_instance].positions[_attester].delegatee;
  }

  /**
   * @notice Get the voting power of a `_delegatee`
   *
   * @param _self The DepositAndDelegationAccounting struct to read from
   * @param _delegatee The delegatee to get the voting power of
   *
   * @return The voting power of the delegatee
   */
  function getVotingPower(DepositAndDelegationAccounting storage _self, address _delegatee)
    internal
    view
    returns (uint256)
  {
    return _self.votingAccounts[_delegatee].votingPower.valueNow();
  }

  /**
   * @notice Get the voting power of a `_delegatee` at a specific `_timestamp`
   *
   * @param _self The DepositAndDelegationAccounting struct to read from
   * @param _delegatee The delegatee to get the voting power of
   * @param _timestamp The timestamp to get the voting power at
   *
   * @return The voting power of the delegatee at the specific `_timestamp`
   */
  function getVotingPowerAt(DepositAndDelegationAccounting storage _self, address _delegatee, Timestamp _timestamp)
    internal
    view
    returns (uint256)
  {
    return _self.votingAccounts[_delegatee].votingPower.valueAt(_timestamp);
  }

  /**
   * @notice Get the power used by a `_delegatee` on a specific `_proposalId`
   *
   * @param _self The DepositAndDelegationAccounting struct to read from
   * @param _delegatee The delegatee to get the power used by
   * @param _proposalId The proposal to get the power used on
   *
   * @return The voting power used by the `_delegatee` at `_proposalId`
   */
  function getPowerUsed(DepositAndDelegationAccounting storage _self, address _delegatee, uint256 _proposalId)
    internal
    view
    returns (uint256)
  {
    return _self.votingAccounts[_delegatee].powerUsed[_proposalId];
  }

  /**
   * @notice Move `_amount` of voting power from the delegatee of `_from` to the delegatee of `_to`
   *
   * @dev If the `_from` is `address(0)` the decrease is skipped, and it is effectively a mint
   * @dev If the `_to` is `address(0)` the increase is skipped, and it is effectively a burn
   *
   * @param _self The DepositAndDelegationAccounting struct to modify in storage
   * @param _from The address to move the voting power from
   * @param _to The address to move the voting power to
   * @param _amount The amount of voting power to move
   */
  function moveVotingPower(DepositAndDelegationAccounting storage _self, address _from, address _to, uint256 _amount)
    private
  {
    if (_from == _to || _amount == 0) {
      return;
    }

    if (_from != address(0)) {
      (uint256 oldValue, uint256 newValue) = _self.votingAccounts[_from].votingPower.sub(_amount);
      emit DelegateVotesChanged(_from, oldValue, newValue);
    }

    if (_to != address(0)) {
      (uint256 oldValue, uint256 newValue) = _self.votingAccounts[_to].votingPower.add(_amount);
      emit DelegateVotesChanged(_to, oldValue, newValue);
    }
  }
}

// Struct to track the attesters (checkpoint producers) on a particular rollup instance
// throughout time, along with each attester's current config.
// Finally a flag to track if the instance exists.
struct InstanceAttesterRegistry {
  SnapshottedAddressSet attesters;
  bool exists;
}

/**
 * @title GSECore
 * @author Aztec Labs
 * @notice The core Governance Staking Escrow contract that handles the deposits of attesters on rollup instances.
 *         It is responsible for:
 *         - depositing/withdrawing attesters on rollup instances
 *         - providing rollup instances with historical views of their attesters
 *         - allowing depositors to delegate their voting power
 *         - allowing delegatees to vote at governance
 *         - maintaining a set of "bonus" attesters which are always deposited on behalf of the latest rollup
 *
 * NB: The "bonus" attesters are thus automatically "moved along" whenever the latest rollup changes.
 * That is, at the point of the rollup getting added, the bonus is immediately available.
 * This allows the latest rollup to start with a set of attesters, rather than requiring them to exit
 * the old rollup and deposit in the new one.
 *
 * NB: The "latest" rollup in this contract does not technically need to be the "canonical" rollup
 * according to the Registry, but in practice, it will be unless the new rollup does not use the GSE.
 * Proposals which add rollups that DO want to use the GSE MUST call addRollup to both the Registry and the GSE.
 * See RegisterNewRollupVersionPayload.sol for an example.
 *
 * NB: The "owner" of the GSE is intended to be the Governance contract, but there is a circular
 * dependency in that we also want the GSE to be registered as the first beneficiary of the governance
 * contract so that we don't need to go through a governance proposal to add it. To that end,
 * this contract's view of `governance` needs to be set. So the current flow is to deploy the GSE with the owner
 * set to the deployer, then deploy Governance, passing the GSE as the initial/sole authorized beneficiary,
 * then have the deployer `setGovernance`, and then `transferOwnership` to Governance.
 */
contract GSECore is IGSECore, Ownable {
  using AddressSnapshotLib for SnapshottedAddressSet;
  using SafeCast for uint256;
  using SafeCast for uint224;
  using Checkpoints for Checkpoints.Trace224;
  using DepositDelegationLib for DepositAndDelegationAccounting;
  using SafeERC20 for IERC20;

  /**
   * Create a special "bonus" address for use by the latest rollup.
   * This is a convenience mechanism to allow attesters to always be staked on the latest rollup.
   *
   * As far as terminology, the GSE tracks deposits and voting/delegation data for "instances",
   * and an "instance" is either the address of a "true" rollup contract which was added via `addRollup`,
   * or (ONLY IN THIS CONTRACT) this special "bonus" address, which has its own accounting.
   *
   * NB: in every other context, "instance" refers broadly to a specific instance of an aztec rollup contract
   * (possibly inclusive of its family of related contracts e.g. Inbox, Outbox, etc.)
   *
   * Thus, this bonus address appears in `delegation` and `instances`, and from the perspective of the GSE,
   * it is an instance (though it can never be in the list of rollups).
   *
   * Lower in the code, we use "rollup" if we know we're talking about a rollup (often msg.sender),
   * and "instance" if we are talking about about either a rollup instance or the bonus instance.
   *
   * The latest rollup according to `rollups` may use the attesters and voting power
   * from the BONUS_INSTANCE_ADDRESS as a "bonus" to their own.
   *
   * One invariant of the GSE is that the attesters available to any rollup instance must form a set.
   * i.e. there must be no duplicates.
   *
   * Thus, for the latest rollup, there are two "buckets" of attesters available:
   * - the attesters that are associated with the rollup's address
   * - the attesters that are associated with the BONUS_INSTANCE_ADDRESS
   *
   * The GSE ensures that:
   * - each bucket individually is a set
   * - when you add these two buckets together, it is a set.
   *
   * For a rollup that is no longer the latest, the attesters available to it are the attesters that are
   * associated with the rollup's address. In effect, when a rollup goes from being the latest to not being
   * the latest, it loses all attesters that were associated with the bonus instance.
   *
   * In this way, the "effective" attesters/balance/etc for a rollup (at a point in time) is:
   * - the rollup's bucket and the bonus bucket if the rollup was the latest at that point in time
   * - only the rollup's bucket if the rollup was not the latest at that point in time
   *
   * Note further, that operations like deposit and withdraw are initiated by a rollup,
   * but the "affected instance" address will be either the rollup's address or the BONUS_INSTANCE_ADDRESS;
   * we will typically need to look at both instances to know what to do.
   *
   * NB: in a large way, the BONUS_INSTANCE_ADDRESS is the entire point of the GSE,
   * otherwise the rollups would've managed their own attesters/delegation/etc.
   */
  address public constant BONUS_INSTANCE_ADDRESS = address(uint160(uint256(keccak256("bonus-instance"))));

  // External wrapper of the BN254 library to more easily allow gas limits.
  Bn254LibWrapper internal immutable BN254_LIB_WRAPPER = new Bn254LibWrapper();

  // The amount of ASSET needed to add an attester to the set
  uint256 public immutable ACTIVATION_THRESHOLD;

  // The amount of ASSET needed to keep an attester in the set, if the attester balance fall below this threshold
  // the attester will be ejected from the set.
  uint256 public immutable EJECTION_THRESHOLD;

  // The asset used for sybil resistance and power in governance. Must match the ASSET in `Governance` to work as
  // intended.
  IERC20 public immutable ASSET;

  // The GSE's history of rollups.
  Checkpoints.Trace224 internal rollups;
  // Mapping from instance address to its historical attester information.
  mapping(address instanceAddress => InstanceAttesterRegistry instance) internal instances;

  // Global attester information
  mapping(address attester => AttesterConfig config) internal configOf;
  // Mapping from the hashed public key in G1 of BN254 to the keys are registered.
  mapping(bytes32 hashedPK1 => bool isRegistered) public ownedPKs;

  /**
   * Contains state for:
   * checkpointed total supply
   * instance => {
   *   checkpointed supply
   *   attester => { balance, delegatee }
   * }
   * delegatee => {
   *   checkpointed voting power
   *   proposal ID => { power used }
   * }
   */
  DepositAndDelegationAccounting internal delegation;
  Governance internal governance;

  // Gas limit for proof of possession validation.
  //
  // Must exceed the happy path gas consumption to ensure deposits succeed.
  // Acts as a cap on unhappy path gas usage to prevent excessive consumption.
  //
  // - Happy path average: 150K gas
  // - Buffer for loop: 50K gas
  // - Buffer for opcode cost changes: 50K gas
  //
  // WARNING: If set below happy path requirements, all deposits will fail.
  // Governance can adjust this value via proposal.
  uint64 public proofOfPossessionGasLimit = 250_000;

  /**
   * @dev enforces that the caller is a registered rollup.
   */
  modifier onlyRollup() {
    require(isRollupRegistered(msg.sender), Errors_1.GSE__NotRollup(msg.sender));
    _;
  }

  /**
   * @param __owner - The owner of the GSE.
   *                  Initially a deployer to allow adding an initial rollup, then handed over to governance.
   * @param _asset - The ERC20 token asset used in governance and for sybil resistance.
   *                 This token is deposited by attesters to gain voting power in governance
   *                 (ratio of voting power to staked amount is 1:1).
   * @param _activationThreshold - The amount of asset required to deposit an attester on the rollup.
   * @param _ejectionThreshold - The minimum amount of asset required to be in the set to be considered an attester.
   *                        If the balance falls below this threshold, the attester is ejected from the set.
   */
  constructor(address __owner, IERC20 _asset, uint256 _activationThreshold, uint256 _ejectionThreshold)
    Ownable(__owner)
  {
    ASSET = _asset;
    ACTIVATION_THRESHOLD = _activationThreshold;
    EJECTION_THRESHOLD = _ejectionThreshold;
    instances[BONUS_INSTANCE_ADDRESS].exists = true;
  }

  function setGovernance(Governance _governance) external override(IGSECore) onlyOwner {
    require(address(governance) == address(0), Errors_1.GSE__GovernanceAlreadySet());
    governance = _governance;
  }

  function setProofOfPossessionGasLimit(uint64 _proofOfPossessionGasLimit) external override(IGSECore) onlyOwner {
    proofOfPossessionGasLimit = _proofOfPossessionGasLimit;
  }

  /**
   * @notice  Adds another rollup to the instances, which is the new latest rollup.
   *          Only callable by the owner (usually governance) and only when the rollup is not already in the set
   *
   * @dev rollups only have access to the "bonus instance" while they are the most recent rollup.
   *
   * @dev The GSE only supports adding rollups, not removing them. If a rollup becomes compromised, governance can
   * simply add a new rollup and the bonus instance mechanism ensures a smooth transition by allowing the new rollup
   * to immediately inherit attesters.
   *
   * @dev Beware that multiple calls to `addRollup` at the same `block.timestamp` will override each other and only
   * the last will be in the `rollups`.
   *
   * @param _rollup - The address of the rollup to add
   */
  function addRollup(address _rollup) external override(IGSECore) onlyOwner {
    require(_rollup != address(0), Errors_1.GSE__InvalidRollupAddress(_rollup));
    require(!instances[_rollup].exists, Errors_1.GSE__RollupAlreadyRegistered(_rollup));
    instances[_rollup].exists = true;
    rollups.push(block.timestamp.toUint32(), uint224(uint160(_rollup)));
  }

  /**
   * @notice Deposits a new attester
   *
   * @dev msg.sender must be a registered rollup.
   *
   * @dev Transfers ASSET from msg.sender to the GSE, and then into Governance.
   *
   * @dev if _moveWithLatestRollup is true, then msg.sender must be the latest rollup.
   *
   * @dev An attester configuration is registered globally to avoid BLS troubles when moving stake.
   *
   * Suppose the registered rollups are A, then B, then C, so C's effective attesters are
   * those associated with C and the bonus address.
   *
   * Alice may come along now and deposit on A or B, with _moveWithLatestRollup=false in either case.
   *
   * For depositing into C, she can deposit *either* with _moveWithLatestRollup = true OR false.
   * If she deposits with _moveWithLatestRollup = false, then she is associated with C's address.
   * If she deposits with _moveWithLatestRollup = true, then she is associated with the bonus address.
   *
   * Suppose she deposits with _moveWithLatestRollup = true, and a new rollup D is added to the rollups.
   * Then her stake moves to D, and she is in the effective attesters of D.
   *
   * @param _attester     - The attester address on behalf of which the deposit is made.
   * @param _withdrawer   - Address which the user wish to use to initiate a withdraw for the `_attester` and
   *                        to update delegation with. The withdrawals are enforced by the rollup to which it is
   *                        controlled, so it is practically a value for the rollup to use, meaning dishonest rollup
   *                        can reject withdrawal attempts.
   * @param _publicKeyInG1 - BLS public key for the attester in G1
   * @param _publicKeyInG2 - BLS public key for the attester in G2
   * @param _proofOfPossession - A proof of possessions for the private key corresponding _publicKey in G1 and G2
   * @param _moveWithLatestRollup - Whether to deposit into the specific instance, or the bonus instance
   */
  function deposit(
    address _attester,
    address _withdrawer,
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession,
    bool _moveWithLatestRollup
  ) external override(IGSECore) onlyRollup {
    bool isMsgSenderLatestRollup = getLatestRollup() == msg.sender;

    // If _moveWithLatestRollup is true, then msg.sender must be the latest rollup.
    if (_moveWithLatestRollup) {
      require(isMsgSenderLatestRollup, Errors_1.GSE__NotLatestRollup(msg.sender));
    }

    // Ensure that we are not already attesting on the rollup
    require(!isRegistered(msg.sender, _attester), Errors_1.GSE__AlreadyRegistered(msg.sender, _attester));

    // Ensure that if we are the latest rollup, we are not already attesting on the bonus instance.
    if (isMsgSenderLatestRollup) {
      require(
        !isRegistered(BONUS_INSTANCE_ADDRESS, _attester),
        Errors_1.GSE__AlreadyRegistered(BONUS_INSTANCE_ADDRESS, _attester)
      );
    }

    // Set the recipient instance address, i.e. the one that will receive the attester.
    // From above, we know that if we are here, and _moveWithLatestRollup is true,
    // then msg.sender is the latest instance,
    // but the user is targeting the bonus address.
    // Otherwise, we use the msg.sender, which we know is a registered rollup
    // thanks to the modifier.
    address recipientInstance = _moveWithLatestRollup ? BONUS_INSTANCE_ADDRESS : msg.sender;

    // Add the attester to the instance's checkpointed set of attesters.
    require(
      instances[recipientInstance].attesters.add(_attester), Errors_1.GSE__AlreadyRegistered(recipientInstance, _attester)
    );

    _checkProofOfPossession(_attester, _publicKeyInG1, _publicKeyInG2, _proofOfPossession);

    // This is the ONLY place where we set the configuration for an attester.
    // This means that their withdrawer and public keys are set once, globally.
    // If they exit, they must re-deposit with a new key.
    configOf[_attester] = AttesterConfig({withdrawer: _withdrawer, publicKey: _publicKeyInG1});

    delegation.delegate(recipientInstance, _attester, recipientInstance);
    delegation.increaseBalance(recipientInstance, _attester, ACTIVATION_THRESHOLD);

    ASSET.safeTransferFrom(msg.sender, address(this), ACTIVATION_THRESHOLD);

    Governance gov = getGovernance();
    ASSET.approve(address(gov), ACTIVATION_THRESHOLD);
    gov.deposit(address(this), ACTIVATION_THRESHOLD);

    emit Deposit(recipientInstance, _attester, _withdrawer);
  }

  /**
   * @notice  Withdraws at least the amount specified.
   *          If the leftover balance is less than the minimum deposit, the entire balance is withdrawn.
   *
   * @dev     To be used by a rollup to withdraw funds from the GSE. For example if slashing or
   *          just withdrawing events happen, a rollup can use this function to withdraw the funds.
   *          It looks in both the rollup instance and the bonus address for the attester.
   *
   * @dev     Note that all funds are returned to the rollup, so for slashing the rollup itself must
   *          address the problem of "what to do" with the funds. And it must look at the returned amount
   *          withdrawn and the bool.
   *
   * @param _attester - The attester to withdraw from.
   * @param _amount   - The amount of staking asset to withdraw. Has 1:1 ratio with voting power.
   *
   * @return The actual amount withdrawn.
   * @return True if attester is removed from set, false otherwise
   * @return The id of the withdrawal at the governance
   */
  function withdraw(address _attester, uint256 _amount)
    external
    override(IGSECore)
    onlyRollup
    returns (uint256, bool, uint256)
  {
    // We need to figure out where the attester is effectively located
    // we start by looking at the instance that is withdrawing the attester
    address withdrawingInstance = msg.sender;
    InstanceAttesterRegistry storage attesterRegistry = instances[msg.sender];
    bool foundAttester = attesterRegistry.attesters.contains(_attester);

    // If we haven't found the attester in the rollup instance, and we are latest rollup, go look in the "bonus"
    // instance.
    if (
      !foundAttester && getLatestRollup() == msg.sender
        && instances[BONUS_INSTANCE_ADDRESS].attesters.contains(_attester)
    ) {
      withdrawingInstance = BONUS_INSTANCE_ADDRESS;
      attesterRegistry = instances[BONUS_INSTANCE_ADDRESS];
      foundAttester = true;
    }

    require(foundAttester, Errors_1.GSE__NothingToExit(_attester));

    uint256 balance = delegation.getBalanceOf(withdrawingInstance, _attester);
    require(balance >= _amount, Errors_1.GSE__InsufficientBalance(balance, _amount));

    // First assume we are only withdrawing the amount specified.
    uint256 amountWithdrawn = _amount;
    // If the balance after withdrawal is less than the ejection threshold,
    // we will remove the attester from the instance.
    bool isRemoved = balance - _amount < EJECTION_THRESHOLD;

    // Note that the current implementation of the rollup does not allow for partial withdrawals,
    // via `initiateWithdraw`, so a "normal" withdrawal will always remove the attester from the instance.
    // However, if the attester is slashed, we might just reduce the balance.
    if (isRemoved) {
      require(attesterRegistry.attesters.remove(_attester), Errors_1.GSE__FailedToRemove(_attester));
      amountWithdrawn = balance;

      // When removing the user, remove the delegating as well.
      delegation.undelegate(withdrawingInstance, _attester);

      // NOTE
      // We intentionally did not remove the attester config.
      // Attester config is set ONCE when the attester is first seen by the GSE,
      // and is shared across all instances.
    }

    // Decrease the balance of the attester in the instance.
    // Move voting power from the attester's delegatee to address(0) (unless the delegatee is already address(0))
    // Reduce the supply of the instance and the total supply.
    delegation.decreaseBalance(withdrawingInstance, _attester, amountWithdrawn);

    // The withdrawal contains a pending amount that may be claimed using the withdrawal ID when a delay enforced by
    // the Governance contract has passed.
    // Note that the rollup is the one that receives the funds when the withdrawal is claimed.
    uint256 withdrawalId = getGovernance().initiateWithdraw(msg.sender, amountWithdrawn);

    return (amountWithdrawn, isRemoved, withdrawalId);
  }

  /**
   * @notice  A helper function to make it easy for users of the GSE to finalize
   *          a pending exit in the governance.
   *
   *          Kept in here since it is already connected to Governance:
   *          we don't want the rollup to have to deal with links to gov etc.
   *
   * @dev     Will be a no operation if the withdrawal is already collected.
   *
   * @param _withdrawalId - The id of the withdrawal
   */
  function finalizeWithdraw(uint256 _withdrawalId) external override(IGSECore) {
    Governance gov = getGovernance();
    if (!gov.getWithdrawal(_withdrawalId).claimed) {
      gov.finalizeWithdraw(_withdrawalId);
    }
  }

  /**
   * @notice Make a proposal to Governance via `Governance.proposeWithLock`
   *
   * @dev It is required to expose this on the GSE, since it is assumed that only the GSE can hold
   * power in Governance (see the comment at the top of Governance.sol).
   *
   * @dev Transfers governance's configured `lockAmount` of ASSET from msg.sender to the GSE,
   * and then into Governance.
   *
   * @dev Immediately creates a withdrawal from Governance for the `lockAmount`.
   *
   * @dev The delay until the withdrawal may be finalized is equal to the current `lockDelay` in Governance.
   *
   * @param _payload - The IPayload address, which is a contract that contains the proposed actions to be executed by
   * the governance.
   * @param _to - The address that will receive the withdrawn funds when the withdrawal is finalized (see
   * `finalizeWithdraw`)
   *
   * @return The id of the proposal
   */
  function proposeWithLock(IPayload _payload, address _to) external override(IGSECore) returns (uint256) {
    Governance gov = getGovernance();
    uint256 amount = gov.getConfiguration().proposeConfig.lockAmount;

    ASSET.safeTransferFrom(msg.sender, address(this), amount);
    ASSET.approve(address(gov), amount);

    gov.deposit(address(this), amount);

    return gov.proposeWithLock(_payload, _to);
  }

  /**
   * @notice  Delegates the voting power of `_attester` at `_instance` to `_delegatee`
   *
   *          Only callable by the `withdrawer` for the given `_attester` at the given
   *          `_instance`. This is to ensure that the depositor in poor mans delegation;
   *          listing another entity as the `attester`, still controls his voting power,
   *          even if someone else is running the node. Separately, it makes it simpler
   *          to use cold-storage for more impactful actions.
   *
   * @dev The delegatee may use this voting power to vote on proposals in Governance.
   *
   * Note that voting power for a delegatee is timestamped. The delegatee must have this
   * power before a proposal becomes "active" in order to use it.
   * See `Governance.getProposalState` for more details.
   *
   * @param _instance   - The address of the rollup instance (or bonus instance address)
   *                      to which the `_attester` deposit is pledged.
   * @param _attester   - The address of the attester to delegate on behalf of
   * @param _delegatee  - The delegatee that should receive the power
   */
  function delegate(address _instance, address _attester, address _delegatee) external override(IGSECore) {
    require(isRollupRegistered(_instance), Errors_1.GSE__InstanceDoesNotExist(_instance));
    address withdrawer = configOf[_attester].withdrawer;
    require(msg.sender == withdrawer, Errors_1.GSE__NotWithdrawer(withdrawer, msg.sender));
    delegation.delegate(_instance, _attester, _delegatee);
  }

  /**
   * @notice  Votes at the governance using the power delegated to `msg.sender`
   *
   * @param _proposalId - The id of the proposal in the governance to vote on
   * @param _amount     - The amount of voting power to use in the vote
   *                      In the gov, it is possible to do a vote with partial power
   * @param _support    - True if supporting the proposal, false otherwise.
   */
  function vote(uint256 _proposalId, uint256 _amount, bool _support) external override(IGSECore) {
    _vote(msg.sender, _proposalId, _amount, _support);
  }

  /**
   * @notice  Votes at the governance using the power delegated to the bonus instance.
   *          Only callable by the rollup that was the latest rollup at the time of the proposal.
   *
   * @param _proposalId - The id of the proposal in the governance to vote on
   * @param _amount     - The amount of voting power to use in the vote
   *                      In the gov, it is possible to do a vote with partial power
   */
  function voteWithBonus(uint256 _proposalId, uint256 _amount, bool _support) external override(IGSECore) {
    Timestamp ts = _pendingThrough(_proposalId);
    require(msg.sender == getLatestRollupAt(ts), Errors_1.GSE__NotLatestRollup(msg.sender));
    _vote(BONUS_INSTANCE_ADDRESS, _proposalId, _amount, _support);
  }

  function isRollupRegistered(address _instance) public view override(IGSECore) returns (bool) {
    return instances[_instance].exists;
  }

  /**
   * @notice  Lookup if the `_attester` is in the `_instance` attester set
   *
   * @param _instance   - The instance to look at
   * @param _attester   - The attester to lookup
   *
   * @return  True if the `_attester` is in the set of `_instance`, false otherwise
   */
  function isRegistered(address _instance, address _attester) public view override(IGSECore) returns (bool) {
    return instances[_instance].attesters.contains(_attester);
  }

  /**
   * @notice  Get the address of latest instance
   *
   * @return  The address of the latest instance
   */
  function getLatestRollup() public view override(IGSECore) returns (address) {
    return address(rollups.latest().toUint160());
  }

  /**
   * @notice  Get the address of the instance that was latest at time `_timestamp`
   *
   * @param _timestamp  - The timestamp to lookup
   *
   * @return  The address of the latest instance at the time of lookup
   */
  function getLatestRollupAt(Timestamp _timestamp) public view override(IGSECore) returns (address) {
    return address(rollups.upperLookup(Timestamp.unwrap(_timestamp).toUint32()).toUint160());
  }

  function getGovernance() public view override(IGSECore) returns (Governance) {
    return governance;
  }

  /**
   * @notice  Inner logic for the vote
   *
   * @dev     Fetches the timestamp where proposal becomes active, and use it for the voting power
   *          of the `_voter`
   *
   * @param _voter      - The voter
   * @param _proposalId - The proposal to vote on
   * @param _amount     - The amount of power to use
   * @param _support    - True to support the proposal, false otherwise
   */
  function _vote(address _voter, uint256 _proposalId, uint256 _amount, bool _support) internal {
    Timestamp ts = _pendingThrough(_proposalId);
    // Mark the power as spent within our delegation accounting.
    delegation.usePower(_voter, _proposalId, ts, _amount);
    // Vote on the proposal
    getGovernance().vote(_proposalId, _amount, _support);
  }

  function _checkProofOfPossession(
    address _attester,
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession
  ) internal virtual {
    // Make sure the attester has not registered before
    G1Point memory previouslyRegisteredPoint = configOf[_attester].publicKey;
    require(
      (previouslyRegisteredPoint.x == 0 && previouslyRegisteredPoint.y == 0),
      Errors_1.GSE__CannotChangePublicKeys(previouslyRegisteredPoint.x, previouslyRegisteredPoint.y)
    );

    // Make sure the incoming point has not been seen before
    // NOTE: we only need to check for the existence of Pk1, and not also for Pk2,
    // as the Pk2 will be constrained to have the same underlying secret key as part of the proofOfPossession,
    // so existence/correctness of Pk2 is implied by existence/correctness of Pk1.
    bytes32 hashedIncomingPoint = keccak256(abi.encodePacked(_publicKeyInG1.x, _publicKeyInG1.y));
    require((!ownedPKs[hashedIncomingPoint]), Errors_1.GSE__ProofOfPossessionAlreadySeen(hashedIncomingPoint));
    ownedPKs[hashedIncomingPoint] = true;

    // We validate the proof of possession using an external contract to limit gas potentially "sacrificed"
    // in case of failure.
    require(
      BN254_LIB_WRAPPER.proofOfPossession{
        gas: proofOfPossessionGasLimit
      }(_publicKeyInG1, _publicKeyInG2, _proofOfPossession),
      Errors_1.GSE__InvalidProofOfPossession()
    );
  }

  function _pendingThrough(uint256 _proposalId) internal view returns (Timestamp) {
    // Directly compute pendingThrough for memory proposal
    Proposal memory proposal = getGovernance().getProposal(_proposalId);
    return proposal.creation + proposal.config.votingDelay;
  }
}

contract GSE is IGSE, GSECore {
  using AddressSnapshotLib for SnapshottedAddressSet;
  using SafeCast for uint256;
  using SafeCast for uint224;
  using Checkpoints for Checkpoints.Trace224;
  using DepositDelegationLib for DepositAndDelegationAccounting;

  constructor(address __owner, IERC20 _asset, uint256 _activationThreshold, uint256 _ejectionThreshold)
    GSECore(__owner, _asset, _activationThreshold, _ejectionThreshold)
  {}

  /**
   * @notice  Get the registration digest of a public key
   *          by hashing the the public key to a point on the curve which may subsequently
   *          be signed by the corresponding private key.
   *
   * @param _publicKey - The public key to get the registration digest of
   *
   * @return The registration digest of the public key. Sign and submit as a proof of possession.
   */
  function getRegistrationDigest(G1Point memory _publicKey) external view override(IGSE) returns (G1Point memory) {
    return BN254_LIB_WRAPPER.g1ToDigestPoint(_publicKey);
  }

  function getConfig(address _attester) external view override(IGSE) returns (AttesterConfig memory) {
    return configOf[_attester];
  }

  function getWithdrawer(address _attester) external view override(IGSE) returns (address withdrawer) {
    AttesterConfig memory config = configOf[_attester];

    return config.withdrawer;
  }

  function balanceOf(address _instance, address _attester) external view override(IGSE) returns (uint256) {
    return delegation.getBalanceOf(_instance, _attester);
  }

  /**
   * @notice  Get the effective balance of the attester at the instance.
   *
   *          The effective balance is the balance of the attester at the specific instance or at the bonus if the
   *          instance is the latest rollup and he was not at the specific. We can do this as an `or` since the
   *          attester may only be active at one of them.
   *
   * @param _instance   - The instance to look at
   * @param _attester   - The attester to look at
   *
   * @return The effective balance of the attester at the instance
   */
  function effectiveBalanceOf(address _instance, address _attester) external view override(IGSE) returns (uint256) {
    uint256 balance = delegation.getBalanceOf(_instance, _attester);
    if (balance == 0 && getLatestRollup() == _instance) {
      return delegation.getBalanceOf(BONUS_INSTANCE_ADDRESS, _attester);
    }
    return balance;
  }

  function supplyOf(address _instance) external view override(IGSE) returns (uint256) {
    return delegation.getSupplyOf(_instance);
  }

  function totalSupply() external view override(IGSE) returns (uint256) {
    return delegation.getSupply();
  }

  function getDelegatee(address _instance, address _attester) external view override(IGSE) returns (address) {
    return delegation.getDelegatee(_instance, _attester);
  }

  function getVotingPower(address _delegatee) external view override(IGSE) returns (uint256) {
    return delegation.getVotingPower(_delegatee);
  }

  function getAttestersFromIndicesAtTime(address _instance, Timestamp _timestamp, uint256[] memory _indices)
    external
    view
    override(IGSE)
    returns (address[] memory)
  {
    return _getAddressFromIndicesAtTimestamp(_instance, _indices, _timestamp);
  }

  /**
   * @notice  Get the G1 public keys of the attesters
   *
   * NOTE: this function does NOT check if the attesters are CURRENTLY ACTIVE.
   *
   * @param _attesters  - The attesters to lookup
   *
   * @return The G1 public keys of the attesters
   */
  function getG1PublicKeysFromAddresses(address[] memory _attesters)
    external
    view
    override(IGSE)
    returns (G1Point[] memory)
  {
    G1Point[] memory keys = new G1Point[](_attesters.length);
    for (uint256 i = 0; i < _attesters.length; i++) {
      keys[i] = configOf[_attesters[i]].publicKey;
    }

    return keys;
  }

  function getAttesterFromIndexAtTime(address _instance, uint256 _index, Timestamp _timestamp)
    external
    view
    override(IGSE)
    returns (address)
  {
    uint256[] memory indices = new uint256[](1);
    indices[0] = _index;
    return _getAddressFromIndicesAtTimestamp(_instance, indices, _timestamp)[0];
  }

  function getPowerUsed(address _delegatee, uint256 _proposalId) external view override(IGSE) returns (uint256) {
    return delegation.getPowerUsed(_delegatee, _proposalId);
  }

  function getBonusInstanceAddress() external pure override(IGSE) returns (address) {
    return BONUS_INSTANCE_ADDRESS;
  }

  function getVotingPowerAt(address _delegatee, Timestamp _timestamp) public view override(IGSE) returns (uint256) {
    return delegation.getVotingPowerAt(_delegatee, _timestamp);
  }

  /**
   * @notice  Get the number of effective attesters at the instance at the time of `_timestamp`
   *          (including the bonus instance)
   *
   * @param _instance   - The instance to look at
   * @param _timestamp  - The timestamp to lookup
   *
   * @return The number of effective attesters at the instance at the time of `_timestamp`
   */
  function getAttesterCountAtTime(address _instance, Timestamp _timestamp)
    public
    view
    override(IGSE)
    returns (uint256)
  {
    InstanceAttesterRegistry storage store = instances[_instance];
    uint32 timestamp = Timestamp.unwrap(_timestamp).toUint32();

    uint256 count = store.attesters.lengthAtTimestamp(timestamp);
    if (getLatestRollupAt(_timestamp) == _instance) {
      count += instances[BONUS_INSTANCE_ADDRESS].attesters.lengthAtTimestamp(timestamp);
    }

    return count;
  }

  /**
   * @notice  Get the addresses of the attesters at the instance at the time of `_timestamp`
   *
   * @dev
   *
   * @param _instance   - The instance to look at
   * @param _indices    - The indices of the attesters to lookup
   * @param _timestamp  - The timestamp to lookup
   *
   * @return The addresses of the attesters at the instance at the time of `_timestamp`
   */
  function _getAddressFromIndicesAtTimestamp(address _instance, uint256[] memory _indices, Timestamp _timestamp)
    internal
    view
    returns (address[] memory)
  {
    address[] memory attesters = new address[](_indices.length);

    // Note: This function could get called where _instance is the bonus instance.
    // This is okay, because we know that in this case, `isLatestRollup` will be false.
    // So we won't double count.
    InstanceAttesterRegistry storage instanceStore = instances[_instance];
    InstanceAttesterRegistry storage bonusStore = instances[BONUS_INSTANCE_ADDRESS];
    bool isLatestRollup = getLatestRollupAt(_timestamp) == _instance;

    uint32 ts = Timestamp.unwrap(_timestamp).toUint32();

    // The effective size of the set will be the size of the instance attesters, plus the size of the bonus attesters
    // if the instance is the latest rollup. This will effectively work as one long list with [...instance, ...bonus]
    uint256 storeSize = instanceStore.attesters.lengthAtTimestamp(ts);
    uint256 canonicalSize = isLatestRollup ? bonusStore.attesters.lengthAtTimestamp(ts) : 0;
    uint256 totalSize = storeSize + canonicalSize;

    // We loop through the indices, and for each index we get the attester from the instance or bonus instance
    // depending on value in the collective list [...instance, ...bonus]
    for (uint256 i = 0; i < _indices.length; i++) {
      uint256 index = _indices[i];
      require(index < totalSize, Errors_1.GSE__OutOfBounds(index, totalSize));

      // since we have ensured that the index is not out of bounds, we can use the unsafe function in
      // `AddressSnapshotLib` to fetch if. We use the `recent` variant as we expect the attesters to
      // mainly be from recent history when fetched during tx execution.

      if (index < storeSize) {
        attesters[i] = instanceStore.attesters.unsafeGetRecentAddressFromIndexAtTimestamp(index, ts);
      } else if (isLatestRollup) {
        attesters[i] = bonusStore.attesters.unsafeGetRecentAddressFromIndexAtTimestamp(index - storeSize, ts);
      } else {
        revert Errors_1.GSE__FatalError("SHOULD NEVER HAPPEN");
      }
    }

    return attesters;
  }
}

/**
 * @notice Represents a validator's exit from the staking system
 * @dev Used to track withdrawal details and timing for validators leaving the system.
 *      The exit can be created in two scenarios:
 *      1. Voluntary withdrawal: Validator calls initiateWithdraw() -> recipientOrWithdrawer is the final recipient
 *      2. Slashing-induced exit: Validator gets slashed -> recipientOrWithdrawer is the withdrawer who must later
 *         call initiateWithdraw() to specify a recipient
 *
 *      The recipientOrWithdrawer field serves dual purposes:
 *      - When isRecipient=true: This address will receive the withdrawn funds
 *      - When isRecipient=false: This address (the withdrawer) can call initiateWithdraw() to set a recipient
 *
 *      Workflow for slashing-induced exits:
 *      1. Slashing occurs -> Exit created with recipientOrWithdrawer=withdrawer, isRecipient=false
 *      2. Withdrawer calls initiateWithdraw() -> Updates to recipientOrWithdrawer=recipient, isRecipient=true
 *      3. After delay period -> finalizeWithdraw() can transfer funds to the recipient
 * @param withdrawalId Unique identifier for this withdrawal from the GSE contract
 * @param amount The amount of stake being withdrawn
 * @param exitableAt Timestamp when the stake becomes withdrawable after delay period
 * @param recipientOrWithdrawer Address that can either receive funds (if isRecipient) or initiate withdrawal (if
 * !isRecipient)
 * @param isRecipient True if recipientOrWithdrawer is the recipient, false if it's the withdrawer
 * @param exists True if this exit record exists, false if not yet created
 */
struct Exit {
  uint256 withdrawalId;
  uint256 amount;
  Timestamp exitableAt;
  address recipientOrWithdrawer;
  bool isRecipient;
  bool exists;
}

struct StakingStorage {
  IERC20 stakingAsset;
  address slasher;
  uint96 localEjectionThreshold;
  address pendingSlasher;
  CompressedTimestamp pendingSlasherReadyAt;
  GSE gse;
  CompressedTimestamp exitDelay;
  mapping(address attester => Exit) exits;
  CompressedStakingQueueConfig queueConfig;
  StakingQueue entryQueue;
  CompressedEpoch nextFlushableEpoch;
  uint32 availableValidatorFlushes;
  bool isBootstrapped;
  // Outgoing slasher that finalizeSetSlasher has rotated off the active slot. Retains
  // authority to call {slash} until `legacySlasherAuthorizedUntil` so that slashing rounds
  // which already reached quorum before the rotation can still execute after the new
  // slasher takes over.
  address legacySlasher;
  CompressedTimestamp legacySlasherAuthorizedUntil;
}

interface ISlasher {
  event VetoedPayload(address indexed payload);
  event SlashingDisabled(uint256 disabledUntil);

  function slash(IPayload _payload) external returns (bool);
  function vetoPayload(IPayload _payload) external returns (bool);
  function setSlashingEnabled(bool _enabled) external;
  function isSlashingEnabled() external view returns (bool);
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface Slasher is ISlasher {
    function PROPOSER() external view returns (address);
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

// Signature
struct Signature {
  uint8 v;
  bytes32 r;
  bytes32 s;
}

interface IEmpire {
  event SignalCast(IPayload indexed payload, uint256 indexed round, address indexed signaler);
  event PayloadSubmittable(IPayload indexed payload, uint256 indexed round);
  event PayloadSubmitted(IPayload indexed payload, uint256 indexed round);

  function signal(IPayload _payload) external returns (bool);
  function signalWithSig(IPayload _payload, Signature memory _sig) external returns (bool);

  function submitRoundWinner(uint256 _roundNumber) external returns (bool);
  function signalCount(address _instance, uint256 _round, IPayload _payload) external view returns (uint256);
  function computeRound(Slot _slot) external view returns (uint256);
  function getInstance() external view returns (address);
}

interface IGovernanceProposer is IEmpire {
  function getProposalProposer(uint256 _proposalId) external view returns (address);
  function getGovernance() external view returns (address);
}

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

struct CompressedRoundAccounting {
  CompressedSlot lastSignalSlot;
  IPayload payloadWithMostSignals;
  bool executed;
  mapping(IPayload payload => uint256 count) signalCount;
}

interface IEmperor {
  // Not view because it might rely on transient storage.
  // Calls are essentially trusted
  function getCurrentProposer() external returns (address);

  function getCurrentSlot() external view returns (Slot);
}

struct RoundAccounting {
  Slot lastSignalSlot;
  IPayload payloadWithMostSignals;
  bool executed;
}

/**
 * @title EmpireBase
 * @author Aztec Labs
 * @notice Abstract base contract for a round-based signaling system where designated entities
 *         signal support for payloads before they are submitted elsewhere.
 *         Works with an IEmperor (i.e. a Rollup) contract to determine the entity that may signal for a given slot.
 *
 * @dev PURPOSE:
 * This contract allows validators to signal their support for payloads.
 *
 * The GovernanceProposer extends this contract to signal support for payloads before they are submitted to the main
 * Governance contract, resulting in a two-stage governance process:
 * 1. Signal gathering (GovernanceProposer contract) - validators indicate support
 * 2. Formal governance (Governance contract) - actual voting and execution
 *
 * @dev KEY CONCEPTS:
 * **Payload**: A contract with a list of actions (contract calls) to perform.
 *
 * **Rounds**: Time is divided into rounds of ROUND_SIZE slots. Payloads compete for support
 * within a round.
 *
 * **Instances**: Refers to an instance of the rollup contract, which in this case is exposed via a simplified IEmperor
 * interface.
 * This contract only needs the instance to determine the current slot (to compute the round), and the current
 * checkpoint proposer.
 *
 * **Signalers**: Each slot has a designated signaler (determined by IEmperor).
 * Only the current slot's signaler can signal support, either directly or via signature.
 * In the current implementation, the entity that may propose a checkpoint (i.e. the "proposer") is the signaler.
 *
 * **Signaling**
 * - One signal per slot (enforced by tracking lastSignalSlot)
 * - Signals accumulate for payloads within a round
 * - First payload to reach QUORUM_SIZE becomes submittable
 *
 * **Submission**
 * - Payloads can be submitted after their round ends with `submitRoundWinner(uint256 _roundNumber)`
 * - Round winner must have received at least QUORUM_SIZE signals
 * - Submission window: LIFETIME_IN_ROUNDS (5 rounds)
 * - Each round's leading payload can only be submitted once
 * - `_handleRoundWinner(IPayload _payload)` on the implementing contract is called to handle the winner
 *
 * @dev SYSTEM PARAMETERS:
 * - QUORUM_SIZE: Minimum signals needed for submission
 * - ROUND_SIZE: Slots per round
 * - Constraint: QUORUM_SIZE > ROUND_SIZE/2 and QUORUM_SIZE ≤ ROUND_SIZE
 * Note that it it possible to have QUORUM_SIZE = 1 for ROUND_SIZE = 1, which effectively give all the
 * power to the first signal.
 *
 * @dev SIGNALING METHODS:
 * 1. Direct signal: Current signaler calls `signal()`
 * 2. Delegated signal: Anyone submits with signaler's signature via `signalWithSig()`
 *    - Uses EIP-712 for signature verification
 *    - Includes slot and instance to prevent replay attacks
 *
 * @dev ABSTRACT FUNCTIONS:
 * Implementing contracts must provide:
 * - `getInstance()`: Returns the IEmperor instance for slot/signaler info
 * - `_handleRoundWinner(IPayload _payload)`: Called during `submitRoundWinner`
 *
 * Note this contract can support multiple instances/rollups. This is because the instance is retrieved dynamically from
 * the
 * underlying implementation. For example, when the GovernanceProposer is used, the instance is the canonical rollup,
 * which will change whenever there is a new canonical rollup.
 *
 * This also means that if the new canonical rollup does not support the IEmperor interface, this contract will not
 * work,
 * and a different implementation will need to be specified as part of the payload which deploys the new canonical
 * instance.
 */
abstract contract EmpireBase is EIP712, IEmpire {
  using SignatureLib for Signature;
  using CompressedTimeMath for Slot;
  using CompressedTimeMath for CompressedSlot;

  // EIP-712 type hash for the Signal struct
  bytes32 public constant SIGNAL_TYPEHASH = keccak256("Signal(address payload,uint256 slot,address instance)");

  // The number of signals needed for a payload to be considered submittable.
  uint256 public immutable QUORUM_SIZE;
  // The number of slots per round.
  uint256 public immutable ROUND_SIZE;
  // The number of rounds that a round winner may be submitted for, after it have passed.
  uint256 public immutable LIFETIME_IN_ROUNDS;
  // The number of rounds that must elapse before a round winner may be submitted.
  uint256 public immutable EXECUTION_DELAY_IN_ROUNDS;

  // Mapping of instance to round number to round accounting.
  mapping(address instance => mapping(uint256 roundNumber => CompressedRoundAccounting)) internal rounds;

  constructor(uint256 _quorumSize, uint256 _roundSize, uint256 _lifetimeInRounds, uint256 _executionDelayInRounds)
    EIP712("EmpireBase", "1")
  {
    QUORUM_SIZE = _quorumSize;
    ROUND_SIZE = _roundSize;
    LIFETIME_IN_ROUNDS = _lifetimeInRounds;
    EXECUTION_DELAY_IN_ROUNDS = _executionDelayInRounds;

    require(QUORUM_SIZE > ROUND_SIZE / 2, Errors_1.EmpireBase__InvalidQuorumAndRoundSize(QUORUM_SIZE, ROUND_SIZE));
    require(QUORUM_SIZE <= ROUND_SIZE, Errors_1.EmpireBase__QuorumCannotBeLargerThanRoundSize(QUORUM_SIZE, ROUND_SIZE));

    require(
      LIFETIME_IN_ROUNDS > EXECUTION_DELAY_IN_ROUNDS,
      Errors_1.EmpireBase__InvalidLifetimeAndExecutionDelay(LIFETIME_IN_ROUNDS, EXECUTION_DELAY_IN_ROUNDS)
    );
  }

  /**
   * @notice Signal support for a payload
   *
   * @dev this only works if msg.sender is the current signaler
   *
   * @param _payload - The address of the IPayload to signal support for
   *
   * @return True if executed successfully, false otherwise
   */
  function signal(IPayload _payload) external override(IEmpire) returns (bool) {
    return _internalSignal(_payload, Signature({v: 0, r: bytes32(0), s: bytes32(0)}));
  }

  /**
   * @notice Signal support for a payload with a signature from the current signaler
   *
   * @param _payload - The payload to signal support for
   * @param _sig - A signature from the signaler
   *
   * @return True if executed successfully, false otherwise
   */
  function signalWithSig(IPayload _payload, Signature memory _sig) external override(IEmpire) returns (bool) {
    return _internalSignal(_payload, _sig);
  }

  /**
   * @notice  Submit the round winner to the implementation's `_handleRoundWinner` function
   *
   * @dev calls `_handleRoundWinner` on the implementing contract with the winning payload, if applicable.
   *
   * @param _roundNumber - The round number to execute
   *
   * @return True if executed successfully, false otherwise
   */
  function submitRoundWinner(uint256 _roundNumber) external override(IEmpire) returns (bool) {
    // Need to ensure that the round is not active.
    address instance = getInstance();
    require(instance.code.length > 0, Errors_1.EmpireBase__InstanceHaveNoCode(instance));

    IEmperor selection = IEmperor(instance);
    Slot currentSlot = selection.getCurrentSlot();

    uint256 currentRound = computeRound(currentSlot);

    require(
      currentRound > _roundNumber + EXECUTION_DELAY_IN_ROUNDS,
      Errors_1.EmpireBase__RoundTooNew(_roundNumber, currentRound)
    );

    require(
      currentRound <= _roundNumber + LIFETIME_IN_ROUNDS, Errors_1.EmpireBase__RoundTooOld(_roundNumber, currentRound)
    );

    CompressedRoundAccounting storage round = rounds[instance][_roundNumber];
    require(!round.executed, Errors_1.EmpireBase__PayloadAlreadySubmitted(_roundNumber));

    // If the payload with the most signals is address(0) there are nothing to execute and it is a no-op.
    // This will be the case if no signals have been cast during a round, or if people have simple signalled
    // for nothing to happen (the same as not signalling).
    require(round.payloadWithMostSignals != IPayload(address(0)), Errors_1.EmpireBase__PayloadCannotBeAddressZero());
    uint256 signalsCast = round.signalCount[round.payloadWithMostSignals];
    require(signalsCast >= QUORUM_SIZE, Errors_1.EmpireBase__InsufficientSignals(signalsCast, QUORUM_SIZE));

    round.executed = true;

    emit PayloadSubmitted(round.payloadWithMostSignals, _roundNumber);

    require(
      _handleRoundWinner(round.payloadWithMostSignals),
      Errors_1.EmpireBase__FailedToSubmitRoundWinner(round.payloadWithMostSignals)
    );
    return true;
  }

  /**
   * @notice  Fetch the signal count for a specific payload in a specific round on a specific instance
   *
   * @param _instance - The address of the instance
   * @param _round - The round to lookup
   * @param _payload - The payload to lookup
   *
   * @return The number of signals
   */
  function signalCount(address _instance, uint256 _round, IPayload _payload)
    external
    view
    override(IEmpire)
    returns (uint256)
  {
    return rounds[_instance][_round].signalCount[_payload];
  }

  /**
   * @notice  Computes the round at the current slot
   *
   * @return The round number
   */
  function getCurrentRound() external view returns (uint256) {
    IEmperor selection = IEmperor(getInstance());
    Slot currentSlot = selection.getCurrentSlot();
    return computeRound(currentSlot);
  }

  function getRoundData(address _instance, uint256 _round) external view returns (RoundAccounting memory) {
    CompressedRoundAccounting storage compressedRound = rounds[_instance][_round];
    return RoundAccounting({
      lastSignalSlot: compressedRound.lastSignalSlot.decompress(),
      payloadWithMostSignals: compressedRound.payloadWithMostSignals,
      executed: compressedRound.executed
    });
  }

  /**
   * @notice Computes the round at the given slot
   *
   * @param _slot - The slot to compute round for
   *
   * @return The round number
   */
  function computeRound(Slot _slot) public view override(IEmpire) returns (uint256) {
    return Slot.unwrap(_slot) / ROUND_SIZE;
  }

  function getSignalSignatureDigest(IPayload _payload, Slot _slot) public view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(SIGNAL_TYPEHASH, _payload, _slot, getInstance())));
  }

  // Virtual functions
  function getInstance() public view virtual override(IEmpire) returns (address);
  function _handleRoundWinner(IPayload _payload) internal virtual returns (bool);

  function _internalSignal(IPayload _payload, Signature memory _sig) internal returns (bool) {
    address instance = getInstance();
    require(instance.code.length > 0, Errors_1.EmpireBase__InstanceHaveNoCode(instance));

    IEmperor selection = IEmperor(instance);
    Slot currentSlot = selection.getCurrentSlot();

    uint256 roundNumber = computeRound(currentSlot);

    CompressedRoundAccounting storage round = rounds[instance][roundNumber];

    // Ensure that time have progressed since the last slot. If not, the current proposer might send multiple signals
    require(currentSlot > round.lastSignalSlot.decompress(), Errors_1.EmpireBase__SignalAlreadyCastForSlot(currentSlot));
    round.lastSignalSlot = currentSlot.compress();

    address signaler = selection.getCurrentProposer();

    if (_sig.isEmpty()) {
      require(msg.sender == signaler, Errors_1.EmpireBase__OnlyProposerCanSignal(msg.sender, signaler));
    } else {
      bytes32 digest = getSignalSignatureDigest(_payload, currentSlot);

      // _sig.verify will throw if invalid, it is more my sanity that I am doing this for.
      require(_sig.verify(signaler, digest), Errors_1.EmpireBase__OnlyProposerCanSignal(msg.sender, signaler));
    }

    round.signalCount[_payload] += 1;

    if (
      round.payloadWithMostSignals != _payload
        && round.signalCount[_payload] > round.signalCount[round.payloadWithMostSignals]
    ) {
      round.payloadWithMostSignals = _payload;
    }

    emit SignalCast(_payload, roundNumber, signaler);

    if (round.signalCount[_payload] == QUORUM_SIZE) {
      emit PayloadSubmittable(_payload, roundNumber);
    }

    return true;
  }
}

interface IProposerPayload is IPayload {
  function getOriginalPayload() external view returns (IPayload);

  function amIValid() external view returns (bool);
}

interface IHaveVersion {
  function getVersion() external view returns (uint256);
}

interface IRewardDistributor {
  /// @notice Emitted when a funder earmarks ASSET for a specific recipient via `subsidizeAddress`.
  event Subsidized(address indexed funder, address indexed recipient, uint256 amount);

  /// @notice Emitted whenever `claim` or `recoverFrom` debits the distributor.
  /// @dev `implicitAmountUsed` is the share drawn from the canonical-rollup implicit pool,
  ///      `earmarkedAmountUsed` is the share drawn from `from`'s earmarked balance, and the two
  ///      always sum to `amount`. Lets a log-only indexer reconstruct bucket-by-bucket history
  ///      without polling storage at every block.
  event Distributed(
    address indexed from, address indexed to, uint256 amount, uint256 implicitAmountUsed, uint256 earmarkedAmountUsed
  );

  function claim(address _to, uint256 _amount) external;
  function recoverFrom(address _from, address _to, uint256 _amount) external;
  function recoverWrongAsset(address _asset, address _to, uint256 _amount) external;
  function subsidizeAddress(address _recipient, uint256 _amount) external;
  function canonicalRollup() external view returns (address);
  function availableTo(address _recipient) external view returns (uint256);
}

interface IRegistry {
  event CanonicalRollupUpdated(address indexed instance, uint256 indexed version);
  event RewardDistributorUpdated(address indexed rewardDistributor);

  function addRollup(IHaveVersion _rollup) external;
  function updateRewardDistributor(address _rewardDistributor) external;

  // docs:start:registry_get_canonical_rollup
  function getCanonicalRollup() external view returns (IHaveVersion);
  // docs:end:registry_get_canonical_rollup

  // docs:start:registry_get_rollup
  function getRollup(uint256 _chainId) external view returns (IHaveVersion);
  // docs:end:registry_get_rollup

  // docs:start:registry_number_of_versions
  function numberOfVersions() external view returns (uint256);
  // docs:end:registry_number_of_versions

  function getGovernance() external view returns (address);

  function getRewardDistributor() external view returns (IRewardDistributor);

  function getVersion(uint256 _index) external view returns (uint256);
}

/**
 * @title   GSEPayload
 *
 * @notice  This contract is used by the GovernanceProposer to enforce checks on an existing payload.
 *
 * In the GovernanceProposer, support for payloads may be signalled by the current checkpoint proposer of the
 * current canonical rollup according to the Registry. Once a payload receives enough support,
 * it may be submitted by the GovernanceProposer.
 *
 * Instead of proposing the original payload to Governance, the GovernanceProposer creates a new GSEPayload,
 * referencing the original payload. It is this new GSEPayload which is proposed via Governance.propose.
 * If/when the GSE payload is executed, Governance calls `getActions`, which copies the actions of the original
 * payload, and appends a call to `amIValid` to it.
 *
 * NB `amIValid` will fail if the 2/3 of the total stake is not "following latest", irrespective
 * of what the original proposal does.
 * Note that the GSE is used to perform these checks, hence the name.
 * Note this check is skipped if the canonical rollup does not match the latest to avoid livelock cases.
 *
 * For example, if the original proposal is just to update a configuration parameter, but in the meantime
 * half of the stake has exited the latest rollup in the GSE, `amIValid` will fail.
 *
 * In such an event, your recourse is either:
 * - wait for the latest rollup to have at least 2/3 of the total stake
 * - `GSE.proposeWithLock`, which bypasses the GovernanceProposer
 */
contract GSEPayload is IProposerPayload {
  IPayload public immutable ORIGINAL;
  IGSE public immutable GSE;
  IRegistry public immutable REGISTRY;

  constructor(IPayload _originalPayloadProposal, IGSE _gse, IRegistry _registry) {
    ORIGINAL = _originalPayloadProposal;
    GSE = _gse;
    REGISTRY = _registry;
  }

  function getOriginalPayload() external view override(IProposerPayload) returns (IPayload) {
    return ORIGINAL;
  }

  function getURI() external view override(IPayload) returns (string memory) {
    return ORIGINAL.getURI();
  }

  /**
   * @notice called by the Governance contract when executing the proposal.
   *
   * Note that this contract simply appends a call to `amIValid` to the original actions.
   */
  function getActions() external view override(IPayload) returns (IPayload.Action[] memory) {
    IPayload.Action[] memory originalActions = ORIGINAL.getActions();
    IPayload.Action[] memory actions = new IPayload.Action[](originalActions.length + 1);

    for (uint256 i = 0; i < originalActions.length; i++) {
      actions[i] = originalActions[i];
    }

    actions[originalActions.length] =
      IPayload.Action({target: address(this), data: abi.encodeWithSelector(GSEPayload.amIValid.selector)});

    return actions;
  }

  /**
   * @notice Validates that the proposal maintains governance system integrity by ensuring
   *         sufficient stake remains on the active rollup after execution.
   *
   * The validation passes when EITHER:
   * 1. The latest rollup (plus bonus instance) has >2/3 of total stake, OR
   * 2. A Registry/GSE mismatch is detected (fail-open to prevent governance livelock)
   *
   * @dev Beware that the >2/3 support means that 1/3 of the stake can be used to reject proposals.
   *
   * @dev The "bonus instance" is a special GSE mechanism where attesters automatically
   *      follow the latest rollup without re-depositing. Their stake counts toward
   *      the latest rollup's total for this validation.
   *
   * @dev LIVELOCK PREVENTION: When canonical != latest, we intentionally return true
   *      to bypass validation. This mismatch typically indicates the GovernanceProposer
   *      is still pointing to a stale GSE contract after a rollup upgrade.
   *
   *      Why this creates a livelock:
   *      - The stale GSE tracks an outdated rollup as "latest"
   *      - The Registry correctly identifies the new rollup as canonical
   *      - Economic incentives drive attesters to follow the canonical (where rewards are)
   *      - The stale GSE's "latest" gradually bleeds stake as rational actors exit
   *      - While theoretically possible to maintain >2/3 stake, it becomes increasingly
   *        unlikely as only inattentive or non-reward-seeking attesters remain
   *      - Proposals keep failing validation, creating a probabilistic livelock where
   *        progress is technically possible but economically improbable
   *
   *      By returning true, we provide an escape hatch that allows governance to
   *      continue functioning despite the misconfiguration, enabling corrective
   *      proposals to update the GovernanceProposer's GSE reference.
   *
   * @dev This function executes as the final action of the proposal (see getActions).
   *      It either reverts with an error (proposal invalid) or returns true (proposal valid).
   *      The boolean return value is effectively ceremonial - only the revert matters.
   *
   * @return Always returns true if the proposal is valid; reverts otherwise
   */
  function amIValid() external view override(IProposerPayload) returns (bool) {
    address canonicalRollup = address(REGISTRY.getCanonicalRollup());
    address latestRollup = GSE.getLatestRollup();

    // Bypass validation on mismatch to prevent economically-driven livelock
    // In theory, >2/3 stake could remain on the stale rollup, but economic
    // incentives make this highly unlikely
    if (canonicalRollup != latestRollup) {
      return true;
    }

    // Standard validation: ensure >2/3 of stake remains with the latest rollup
    uint256 totalSupply = GSE.totalSupply();
    address bonusInstance = GSE.getBonusInstanceAddress();
    uint256 effectiveSupplyOfLatestRollup = GSE.supplyOf(latestRollup) + GSE.supplyOf(bonusInstance);

    require(effectiveSupplyOfLatestRollup > totalSupply * 2 / 3, Errors_1.GovernanceProposer__GSEPayloadInvalid());
    return true;
  }
}

/**
 * @title GovernanceProposer
 * An implementation of EmpireBase, used to propose payloads to governance from sequencers on the canonical rollup.
 *
 * Note: any payload which passes through this contract will have a call to GSEPayload.amIValid appended to the
 * list of actions before it is proposed to Governance.
 * This will cause the proposal to revert if >2/3 of all stake in the GSE are not staked on the latest rollup after
 * the *original* payload is executed by Governance. Unless the latest and canonical rollup diverge, as that indicates
 * a misconfiguration issue (see GSEPayload for more details).
 */
contract GovernanceProposer is IGovernanceProposer, EmpireBase {
  IRegistry public immutable REGISTRY;
  IGSE public immutable GSE;

  /**
   * @dev Mapping of proposal ID to the proposer address.
   * This allows instances to see if they were the proposer of a proposal
   * after the payload is `propose`ed to Governance.
   * Instances that *did* propose a proposal are willing to vote on it in Governance.
   * See `StakingLib.vote` for more details.
   */
  mapping(uint256 proposalId => address proposer) internal proposalProposer;

  /**
   * @notice Constructor for the GovernanceProposer contract.
   *
   * @dev The _executionDelayInRounds are set to 0, as there already is a delay in the governance contract.
   *      If this was not the case, the delay could be applied here.
   *
   * @param _registry The registry contract address.
   * @param _gse The GSE contract address.
   * @param _quorumSize The number of signals needed in a round for a payload to pass.
   * @param _roundSize The number of signals that can be cast in a round.
   */
  constructor(IRegistry _registry, IGSE _gse, uint256 _quorumSize, uint256 _roundSize)
    EmpireBase(_quorumSize, _roundSize, 5, 0)
  {
    REGISTRY = _registry;
    GSE = _gse;
  }

  function getProposalProposer(uint256 _proposalId) external view override(IGovernanceProposer) returns (address) {
    return proposalProposer[_proposalId];
  }

  /**
   * @dev Returns the address of the Governance contract, i.e. the contract at which
   * we will `propose` a winning proposal.
   */
  function getGovernance() public view override(IGovernanceProposer) returns (address) {
    return REGISTRY.getGovernance();
  }

  /**
   * @dev A hook used by the EmpireBase to determine who is the current checkpoint builder (checkpoint "proposer"),
   * and thus may signal.
   *
   * This contract only respects the canonical rollup.
   */
  function getInstance() public view override(EmpireBase, IEmpire) returns (address) {
    return address(REGISTRY.getCanonicalRollup());
  }

  /**
   * @dev Called by the EmpireBase contract in `submitRoundWinner`, which asserts that the payload
   * has enough support to be proposed to Governance.
   *
   * Note that it wraps the original payload in a GSEPayload before pushing into the Governance contract.
   *
   * This creates additional checks, namely that *after* the original payload is executed,
   * the canonical rollup (both the instance and the "magical address") has at least 2/3 of the total stake.
   *
   * @param _payload The payload to propose to the governance contract.
   * @return true if the proposal was proposed successfully, reverts otherwise.
   */
  function _handleRoundWinner(IPayload _payload) internal override(EmpireBase) returns (bool) {
    GSEPayload extendedPayload = new GSEPayload(_payload, GSE, REGISTRY);
    uint256 proposalId = IGovernance(getGovernance()).propose(IPayload(address(extendedPayload)));
    proposalProposer[proposalId] = getInstance();
    return true;
  }
}

// None -> Does not exist in our setup
// Validating -> Participating as validator
// Zombie -> Not participating as validator, but have funds in setup,
//     hit if slashes and going below the minimum
// Exiting -> In the process of exiting the system
enum Status_1 {
  NONE,
  VALIDATING,
  ZOMBIE,
  EXITING
}

struct AttesterView {
  Status_1 status;
  uint256 effectiveBalance;
  Exit exit;
  AttesterConfig config;
}

library StakingLib {
  using SafeCast for uint256;
  using SafeERC20 for IERC20;
  using StakingQueueLib for StakingQueue;
  using ProposalLib for Proposal;
  using StakingQueueConfigLib for CompressedStakingQueueConfig;
  using StakingQueueConfigLib for StakingQueueConfig;
  using CompressedTimeMath for CompressedTimestamp;
  using CompressedTimeMath for Timestamp;
  using CompressedTimeMath for CompressedEpoch;
  using CompressedTimeMath for Epoch;

  bytes32 private constant STAKING_SLOT = keccak256("aztec.core.staking.storage");

  /// @notice Delay between queuing a slasher replacement and being able to finalize it.
  uint256 internal constant SLASHER_EXECUTION_DELAY = 60 days;
  /// @notice After {finalizeSetSlasher} swaps the active slasher, the outgoing slasher retains
  ///         the right to call {slash} for this long. The window is sized to comfortably cover
  ///         any reasonable SlashingProposer lifetime: at the default config a round's full
  ///         vote -> execution lifetime fits inside a few hours, so 30 days is generous.
  ///         Rollups configured with multi-week round lifetimes should raise this -- the value
  ///         is the only knob bounding how long an in-flight slash can drain through the old
  ///         proposer after rotation.
  uint256 internal constant LEGACY_SLASHER_DRAIN_WINDOW = 30 days;

  function initialize(
    IERC20 _stakingAsset,
    GSE _gse,
    Timestamp _exitDelay,
    address _slasher,
    StakingQueueConfig memory _config,
    uint256 _localEjectionThreshold
  ) internal {
    StakingStorage storage store = getStorage();
    store.stakingAsset = _stakingAsset;
    store.gse = _gse;
    store.exitDelay = _exitDelay.compress();
    store.slasher = _slasher;
    store.queueConfig = _config.compress();
    store.entryQueue.init();
    store.localEjectionThreshold = _localEjectionThreshold.toUint96();
  }

  function queueSetSlasher(address _slasher) internal {
    StakingStorage storage store = getStorage();

    // `Slasher.initializeProposer` is permissionless while `PROPOSER` is unset. Queuing a
    // not-yet-initialized Slasher would let anyone claim the proposer role during the 60-day
    // delay and gain arbitrary slash-payload authority once `finalizeSetSlasher` lands. Require
    // the proposer to already be wired so the queued replacement is not capturable.
    require(Slasher(_slasher).PROPOSER() != address(0), Errors.Staking__SlasherProposerNotInitialized(_slasher));

    Timestamp readyAt = Timestamp.wrap(block.timestamp + SLASHER_EXECUTION_DELAY);
    store.pendingSlasher = _slasher;
    store.pendingSlasherReadyAt = readyAt.compress();

    emit IStakingCore.PendingSlasherQueued(_slasher, Timestamp.unwrap(readyAt));
  }

  function cancelSetSlasher() internal {
    StakingStorage storage store = getStorage();

    require(CompressedTimestamp.unwrap(store.pendingSlasherReadyAt) != 0, Errors.Staking__NoPendingSlasher());

    address cancelled = store.pendingSlasher;
    store.pendingSlasher = address(0);
    store.pendingSlasherReadyAt = CompressedTimestamp.wrap(0);

    emit IStakingCore.PendingSlasherCancelled(cancelled);
  }

  function finalizeSetSlasher() internal {
    StakingStorage storage store = getStorage();

    require(CompressedTimestamp.unwrap(store.pendingSlasherReadyAt) != 0, Errors.Staking__NoPendingSlasher());
    Timestamp readyAt = store.pendingSlasherReadyAt.decompress();
    require(Timestamp.wrap(block.timestamp) >= readyAt, Errors.Staking__SlasherNotReady(readyAt));

    address newSlasher = store.pendingSlasher;
    // Defense in depth against state queued before the queueSetSlasher guard existed, and
    // against a replacement whose proposer somehow regressed to zero after queueing.
    require(Slasher(newSlasher).PROPOSER() != address(0), Errors.Staking__SlasherProposerNotInitialized(newSlasher));

    address oldSlasher = store.slasher;
    // Park the outgoing slasher in the legacy slot with a drain window so quorum-backed rounds
    // already accumulated on the old SlashingProposer can still execute against the rollup
    // through the old slasher. Without this, a committee just before a queued slasher takes over
    // gets a "free round" to do what they like. Any prior legacy auth window is overwritten -- only
    // one rotation can be in flight at a time, and the most recent rotation defines the
    // currently-relevant outgoing slasher.
    Timestamp drainUntil = Timestamp.wrap(block.timestamp + LEGACY_SLASHER_DRAIN_WINDOW);
    store.legacySlasher = oldSlasher;
    store.legacySlasherAuthorizedUntil = drainUntil.compress();

    store.slasher = newSlasher;
    store.pendingSlasher = address(0);
    store.pendingSlasherReadyAt = CompressedTimestamp.wrap(0);

    emit IStakingCore.SlasherUpdated(oldSlasher, newSlasher);
    emit IStakingCore.LegacySlasherAuthorized(oldSlasher, Timestamp.unwrap(drainUntil));
  }

  /**
   * @notice Vote on a governance proposal with the rollup's voting power
   * @dev Only votes if:
   *      1. This rollup is the current canonical instance according to governance proposer
   *      2. This rollup was canonical when the proposal was created
   *      3. The proposal was created by the governance proposer
   * @param _proposalId The ID of the proposal to vote on
   */
  function vote(uint256 _proposalId) internal {
    StakingStorage storage store = getStorage();
    Governance gov = store.gse.getGovernance();

    GovernanceProposer govProposer = GovernanceProposer(gov.governanceProposer());
    // We only vote if we are the canonical instance
    require(address(this) == govProposer.getInstance(), Errors.Staking__NotCanonical(address(this)));
    address proposalProposer = govProposer.getProposalProposer(_proposalId);
    // We only vote if we were canonical when the proposal was created
    require(
      address(this) == proposalProposer, Errors.Staking__NotOurProposal(_proposalId, address(this), proposalProposer)
    );
    // We only vote if the proposal was created by the governance proposer
    Proposal memory proposal = gov.getProposal(_proposalId);
    require(proposal.proposer == address(govProposer), Errors.Staking__IncorrectGovProposer(_proposalId));

    Timestamp ts = proposal.creation + proposal.config.votingDelay;

    // Cast votes with all our power
    uint256 vp = store.gse.getVotingPowerAt(address(this), ts);
    store.gse.vote(_proposalId, vp, true);

    // If we are the canonical at the time of the proposal we also cast those votes.
    if (store.gse.getLatestRollupAt(ts) == address(this)) {
      address bonusInstance = store.gse.getBonusInstanceAddress();
      vp = store.gse.getVotingPowerAt(bonusInstance, ts);
      store.gse.voteWithBonus(_proposalId, vp, true);
    }
  }

  /**
   * @notice Completes a validator's withdrawal after the exit delay period
   * @param _attester The address of the validator completing withdrawal
   * @dev Reverts if the attester has no valid exit request (Staking__NotExiting) or if the exit delay period has not
   * elapsed (Staking__WithdrawalNotUnlockedYet)
   */
  function finalizeWithdraw(address _attester) internal {
    StakingStorage storage store = getStorage();
    // We load it into memory to cache it, as we will delete it before we use it.
    Exit memory exit = store.exits[_attester];
    require(exit.exists, Errors.Staking__NotExiting(_attester));
    require(exit.isRecipient, Errors.Staking__InitiateWithdrawNeeded(_attester));
    require(
      exit.exitableAt <= Timestamp.wrap(block.timestamp),
      Errors.Staking__WithdrawalNotUnlockedYet(Timestamp.wrap(block.timestamp), exit.exitableAt)
    );

    delete store.exits[_attester];

    store.gse.finalizeWithdraw(exit.withdrawalId);
    store.stakingAsset.safeTransfer(exit.recipientOrWithdrawer, exit.amount);

    emit IStakingCore.WithdrawFinalized(_attester, exit.recipientOrWithdrawer, exit.amount);
  }

  function trySlash(address _attester, uint256 _amount) internal returns (bool) {
    if (!isSlashable(_attester)) {
      return false;
    }
    slash(_attester, _amount);
    return true;
  }

  /**
   * @notice Slashes a validator's stake as punishment for misbehavior
   * @dev Only callable by the authorized slasher contract. Handles slashing for both exiting and active validators.
   *      For exiting validators, reduces their exit amount. For active validators, the balance will be reduced and
   *      an exit will be created if the remaining stake falls below the ejection threshold.
   * @param _attester The address of the validator to slash
   * @param _amount The amount of stake to slash
   */
  function slash(address _attester, uint256 _amount) internal {
    StakingStorage storage store = getStorage();
    require(_isAuthorizedSlasher(store, msg.sender), Errors.Staking__NotSlasher(store.slasher, msg.sender));

    Exit storage exit = store.exits[_attester];

    if (exit.exists) {
      require(exit.exitableAt > Timestamp.wrap(block.timestamp), Errors.Staking__CannotSlashExitedStake(_attester));

      // If the slash amount is greater than the exit amount, bound it to the exit amount
      uint256 slashAmount = Math.min(_amount, exit.amount);

      if (exit.amount == slashAmount) {
        // If we slash the entire thing, nuke it entirely
        delete store.exits[_attester];
      } else {
        exit.amount -= slashAmount;
      }

      emit IStakingCore.Slashed(_attester, slashAmount);
    } else {
      // Get the effective balance of the attester
      uint256 effectiveBalance = store.gse.effectiveBalanceOf(address(this), _attester);
      require(effectiveBalance > 0, Errors.Staking__NoOneToSlash(_attester));

      address withdrawer = store.gse.getWithdrawer(_attester);

      // If the slash amount is greater than the effective balance, bound it to the effective balance
      uint256 slashAmount = Math.min(_amount, effectiveBalance);
      // The `localEjectionThreshold` might be stricter (larger) than the global (gse ejection threshold)
      uint256 toWithdraw =
        effectiveBalance - slashAmount < store.localEjectionThreshold ? effectiveBalance : slashAmount;

      (uint256 amountWithdrawn, bool isRemoved, uint256 withdrawalId) = store.gse.withdraw(_attester, toWithdraw);

      // The slashed amount remains in the contract permanently, effectively burning those tokens.
      uint256 toUser = amountWithdrawn - slashAmount;
      if (isRemoved && toUser > 0) {
        // Only if we remove the attester AND there is something left will we create an exit
        store.exits[_attester] = Exit({
          withdrawalId: withdrawalId,
          amount: toUser,
          exitableAt: Timestamp.wrap(block.timestamp) + store.exitDelay.decompress(),
          recipientOrWithdrawer: withdrawer,
          isRecipient: false,
          exists: true
        });
      }

      emit IStakingCore.Slashed(_attester, slashAmount);
    }
  }

  /**
   * @notice Deposits stake to add a new validator to the entry queue
   * @dev Transfers stake from the caller and adds the validator to the entry queue.
   *      The validator must not already be exiting. The attester and withdrawer addresses
   *      must be non-zero. The stake amount is fixed at the activation threshold.
   *      The validator will be processed from the queue in a future flushEntryQueue call.
   *
   * @param _attester The address that will act as the validator (sign attestations)
   * @param _withdrawer The address that can withdraw the stake
   * @param _publicKeyInG1 The G1 point for the BLS public key (used for efficient signature verification in GSE)
   * @param _publicKeyInG2 The G2 point for the BLS public key (used for BLS aggregation and pairing operations in GSE)
   * @param _proofOfPossession The proof of possession to show that the keys in G1 and G2 share the same secret key
   * @param _moveWithLatestRollup Whether to automatically stake on a new rollup instance after an upgrade
   */
  function deposit(
    address _attester,
    address _withdrawer,
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession,
    bool _moveWithLatestRollup
  ) internal {
    require(
      _attester != address(0) && _withdrawer != address(0), Errors.Staking__InvalidDeposit(_attester, _withdrawer)
    );
    StakingStorage storage store = getStorage();
    // We don't allow deposits, if we are currently exiting.
    require(!store.exits[_attester].exists, Errors.Staking__AlreadyExiting(_attester));
    uint256 amount = store.gse.ACTIVATION_THRESHOLD();

    store.stakingAsset.safeTransferFrom(msg.sender, address(this), amount);
    store.entryQueue
      .enqueue(_attester, _withdrawer, _publicKeyInG1, _publicKeyInG2, _proofOfPossession, _moveWithLatestRollup);
    emit IStakingCore.ValidatorQueued(_attester, _withdrawer);
  }

  function updateAndGetAvailableFlushes() internal returns (uint256) {
    (uint256 flushes, Epoch currentEpoch, bool shouldUpdateState) = _calculateAvailableFlushes();

    if (shouldUpdateState) {
      StakingStorage storage store = getStorage();
      store.nextFlushableEpoch = (currentEpoch + Epoch.wrap(1)).compress();
      store.availableValidatorFlushes = flushes.toUint32();
    }

    return flushes;
  }

  /**
   * @notice Processes the validator entry queue to add new validators to the active set
   * @dev Processes up to min(maxAddableValidators, _toAdd) entries from the queue,
   *      attempting to deposit each validator into the Governance Staking Escrow (GSE).
   *
   *      For each validator:
   *      - Dequeues their entry from the queue
   *      - Attempts to deposit them into the GSE contract
   *      - On success: emits Deposit event
   *      - On failure: refunds their stake and emits FailedDeposit event
   *
   *      The function will revert if:
   *      - A deposit fails due to out of gas (to prevent queue draining attacks)
   *
   *      The function approves the GSE contract to spend the total stake amount needed for all deposits,
   *      then revokes the approval after processing is complete.
   *      It also updates the available validator flushes
   *
   * @param _toAdd - The max number the caller will try to add
   */
  function flushEntryQueue(uint256 _toAdd) internal {
    uint256 maxAddableValidators = updateAndGetAvailableFlushes();

    if (maxAddableValidators == 0) {
      return;
    }

    StakingStorage storage store = getStorage();

    uint256 queueLength = store.entryQueue.length();
    uint256 numToDequeue = Math.min(Math.min(maxAddableValidators, queueLength), _toAdd);

    if (numToDequeue == 0) {
      return;
    }

    // Approve the GSE to spend the total stake amount needed for all deposits.
    uint256 amount = store.gse.ACTIVATION_THRESHOLD();
    store.stakingAsset.approve(address(store.gse), amount * numToDequeue);
    uint256 depositCount = 0;
    for (uint256 i = 0; i < numToDequeue; i++) {
      DepositArgs memory args = store.entryQueue.dequeue();
      (bool success, bytes memory data) = address(store.gse)
        .call(
          abi.encodeWithSelector(
            IGSECore.deposit.selector,
            args.attester,
            args.withdrawer,
            args.publicKeyInG1,
            args.publicKeyInG2,
            args.proofOfPossession,
            args.moveWithLatestRollup
          )
        );
      if (success) {
        depositCount++;
        emit IStakingCore.Deposit(
          args.attester, args.withdrawer, args.publicKeyInG1, args.publicKeyInG2, args.proofOfPossession, amount
        );
      } else {
        // If the deposit fails, we need to handle two cases:
        // 1. Normal failure (data.length > 0): We return the funds to the withdrawer and continue processing
        //    the queue. This prevents a single failed deposit from blocking the entire queue.
        // 2. Out of gas failure (data.length == 0): We revert the entire transaction. This prevents an attack
        //    where someone could drain the queue without making any deposits.
        //    We can safely assume data.length == 0 means out of gas since we only call trusted GSE contract.
        require(data.length > 0, Errors.Staking__DepositOutOfGas());
        store.stakingAsset.safeTransfer(args.withdrawer, amount);
        emit IStakingCore.FailedDeposit(
          args.attester, args.withdrawer, args.publicKeyInG1, args.publicKeyInG2, args.proofOfPossession
        );
      }
    }
    store.stakingAsset.approve(address(store.gse), 0);

    store.availableValidatorFlushes -= depositCount.toUint32();

    // If we have reached the bootstrap size, mark it as bootstrapped such that we don't re-enter it.
    if (
      !store.isBootstrapped
        && getAttesterCountAtTime(Timestamp.wrap(block.timestamp))
          >= store.queueConfig.decompress().bootstrapValidatorSetSize
    ) {
      store.isBootstrapped = true;
    }
  }

  /**
   * @notice Initiates withdrawal of a validator's stake
   * @dev Can be called by the registered withdrawer to start the exit process for a validator.
   *      Handles two cases:
   *      1. If an exit already exists (e.g. from slashing):
   *         - Only allows updating recipient if caller is withdrawer
   *         - Does not update the exit delay timer
   *      2. If no exit exists:
   *         - Requires validator has non-zero balance
   *         - Only allows registered withdrawer to initiate
   *         - Withdraws stake from GSE contract
   *         - Creates new exit with delay timer
   * @param _attester The validator address to withdraw stake for
   * @param _recipient The address that will receive the withdrawn stake
   * @return True if withdrawal was successfully initiated
   */
  function initiateWithdraw(address _attester, address _recipient) internal returns (bool) {
    require(_recipient != address(0), Errors.Staking__InvalidRecipient(_recipient));
    StakingStorage storage store = getStorage();

    if (store.exits[_attester].exists) {
      // If there is already an exit, we either started it and should revert
      // or it is because of a slash and we should update the recipient
      // Still only if we are the withdrawer
      // We DO NOT update the exitableAt
      require(!store.exits[_attester].isRecipient, Errors.Staking__NothingToExit(_attester));
      require(
        store.exits[_attester].recipientOrWithdrawer == msg.sender,
        Errors.Staking__NotWithdrawer(store.exits[_attester].recipientOrWithdrawer, msg.sender)
      );
      store.exits[_attester].recipientOrWithdrawer = _recipient;
      store.exits[_attester].isRecipient = true;

      emit IStakingCore.WithdrawInitiated(_attester, _recipient, store.exits[_attester].amount);
    } else {
      uint256 effectiveBalance = store.gse.effectiveBalanceOf(address(this), _attester);
      require(effectiveBalance > 0, Errors.Staking__NothingToExit(_attester));

      address withdrawer = store.gse.getWithdrawer(_attester);
      require(msg.sender == withdrawer, Errors.Staking__NotWithdrawer(withdrawer, msg.sender));

      (uint256 actualAmount, bool removed, uint256 withdrawalId) = store.gse.withdraw(_attester, effectiveBalance);
      require(removed, Errors.Staking__WithdrawFailed(_attester));

      store.exits[_attester] = Exit({
        withdrawalId: withdrawalId,
        amount: actualAmount,
        exitableAt: Timestamp.wrap(block.timestamp) + store.exitDelay.decompress(),
        recipientOrWithdrawer: _recipient,
        isRecipient: true,
        exists: true
      });
      emit IStakingCore.WithdrawInitiated(_attester, _recipient, actualAmount);
    }

    return true;
  }

  function updateStakingQueueConfig(StakingQueueConfig memory _config) internal {
    assertValidQueueConfig(_config);
    getStorage().queueConfig = _config.compress();
    emit IStakingCore.StakingQueueConfigUpdated(_config);
  }

  function getNextFlushableEpoch() internal view returns (Epoch) {
    return getStorage().nextFlushableEpoch.decompress();
  }

  function getEntryQueueLength() internal view returns (uint256) {
    return getStorage().entryQueue.length();
  }

  function isSlashable(address _attester) internal view returns (bool) {
    StakingStorage storage store = getStorage();
    Exit storage exit = store.exits[_attester];

    if (exit.exists) {
      return exit.exitableAt > Timestamp.wrap(block.timestamp);
    }

    uint256 effectiveBalance = store.gse.effectiveBalanceOf(address(this), _attester);
    return effectiveBalance > 0;
  }

  function getAttesterCountAtTime(Timestamp _timestamp) internal view returns (uint256) {
    return getStorage().gse.getAttesterCountAtTime(address(this), _timestamp);
  }

  function getAttesterAtIndex(uint256 _index) internal view returns (address) {
    return getStorage().gse.getAttesterFromIndexAtTime(address(this), _index, Timestamp.wrap(block.timestamp));
  }

  function getEntryQueueAt(uint256 _index) internal view returns (DepositArgs memory) {
    return getStorage().entryQueue.at(_index);
  }

  function getAttesterFromIndexAtTime(uint256 _index, Timestamp _timestamp) internal view returns (address) {
    return getStorage().gse.getAttesterFromIndexAtTime(address(this), _index, _timestamp);
  }

  function getAttestersFromIndicesAtTime(Timestamp _timestamp, uint256[] memory _indices)
    internal
    view
    returns (address[] memory)
  {
    return getStorage().gse.getAttestersFromIndicesAtTime(address(this), _timestamp, _indices);
  }

  function getExit(address _attester) internal view returns (Exit memory) {
    return getStorage().exits[_attester];
  }

  function getConfig(address _attester) internal view returns (AttesterConfig memory) {
    return getStorage().gse.getConfig(_attester);
  }

  function getAttesterView(address _attester) internal view returns (AttesterView memory) {
    return AttesterView({
      status: getStatus(_attester),
      effectiveBalance: getStorage().gse.effectiveBalanceOf(address(this), _attester),
      exit: getExit(_attester),
      config: getConfig(_attester)
    });
  }

  function getStatus(address _attester) internal view returns (Status_1) {
    Exit memory exit = getExit(_attester);
    uint256 effectiveBalance = getStorage().gse.effectiveBalanceOf(address(this), _attester);

    Status_1 status;
    if (exit.exists) {
      status = exit.isRecipient ? Status_1.EXITING : Status_1.ZOMBIE;
    } else {
      status = effectiveBalance > 0 ? Status_1.VALIDATING : Status_1.NONE;
    }

    return status;
  }

  /**
   * @notice Determines the maximum number of validators that could be flushed from the entry queue if there were
   * an unlimited number of validators in the queue - this function provides a theoretical limit.
   * @dev Implements three-phase validator set management to control initial validator onboarding (called floodgates):
   *      1. Bootstrap phase: When no active validators exist, the queue must grow to the bootstrap validator set size
   *         constant from config before any validators can be flushed. This creates an initial "floodgate" that
   *         prevents small numbers of validators from activating before reaching the desired bootstrap size.
   *      2. Growth phase: Once the bootstrap size is reached, allows a large fixed batch size (bootstrapFlushSize) to
   *         be flushed at once. This enables the initial large cohort of validators to activate together.
   *      3. Normal phase: After the initial bootstrap and growth phases, returns a number proportional to the current
   *         set size for conservative steady-state growth, unless constrained by configuration (`normalFlushSizeMin`).
   *
   *      The normal-phase result is clamped to `maxQueueFlushSize` at runtime; the
   *      bootstrap-phase value is bounded by the same cap at config-acceptance time inside
   *      {assertValidQueueConfig}, so every phase respects the cap.
   *
   *      The motivation for floodgates is that the whole system starts producing checkpoints with what is considered
   *      a sufficiently decentralized set of validators.
   *
   *      Note that Governance has the ability to close the validator set for this instance by setting
   *      `normalFlushSizeMin` to zero and `normalFlushSizeQuotient` to a very high value. If this is done, this
   *      function will always return zero and no new validator can enter.
   *
   * @param _activeAttesterCount - The number of active attesters
   * @return - The maximum number of validators that could be flushed from the entry queue.
   */
  function getEntryQueueFlushSize(uint256 _activeAttesterCount) internal view returns (uint256) {
    StakingStorage storage store = getStorage();
    StakingQueueConfig memory config = store.queueConfig.decompress();

    uint256 queueSize = store.entryQueue.length();

    // Only if there is bootstrap values configured will we look into bootstrap or growth phases.
    if (config.bootstrapValidatorSetSize > 0 && !store.isBootstrapped) {
      // If bootstrap:
      if (_activeAttesterCount == 0 && queueSize < config.bootstrapValidatorSetSize) {
        return 0;
      }

      // If growth:
      if (_activeAttesterCount < config.bootstrapValidatorSetSize) {
        return config.bootstrapFlushSize;
      }
    }

    // If normal:
    return Math.min(
      Math.max(_activeAttesterCount / config.normalFlushSizeQuotient, config.normalFlushSizeMin),
      config.maxQueueFlushSize
    );
  }

  function getAvailableValidatorFlushes() internal view returns (uint256) {
    (uint256 flushes,,) = _calculateAvailableFlushes();
    return flushes;
  }

  function getCachedAvailableValidatorFlushes() internal view returns (uint256) {
    return getStorage().availableValidatorFlushes;
  }

  /// @notice Enforces invariants on a {StakingQueueConfig}.
  ///         - `normalFlushSizeMin > 0`: a zero floor can close the queue on a running rollup.
  ///         - `normalFlushSizeQuotient > 0`: {getEntryQueueFlushSize} divides by this field.
  ///         - `maxQueueFlushSize > 0`: a zero cap leaves the normal-phase queue impossible to
  ///           drain (the `Math.min(..., 0)` clamp pins every flush at zero), trapping queued
  ///           validator stake.
  ///         - `bootstrapFlushSize > 0` whenever `bootstrapValidatorSetSize > 0`: a zero
  ///           bootstrap flush size traps queued validators during bootstrap growth because the
  ///           bootstrap branch returns `bootstrapFlushSize` directly.
  ///         - `bootstrapFlushSize <= maxQueueFlushSize`: keeps {getEntryQueueFlushSize}'s
  ///           bootstrap-phase return inside the same cap that bounds the normal phase, so the
  ///           cap holds across every phase as documented.
  /// @param _config The queue config to validate; reverts when any of the above is violated.
  function assertValidQueueConfig(StakingQueueConfig memory _config) internal pure {
    require(_config.normalFlushSizeMin > 0, Errors.Staking__InvalidStakingQueueConfig());
    require(_config.normalFlushSizeQuotient > 0, Errors.Staking__InvalidNormalFlushSizeQuotient());
    require(_config.maxQueueFlushSize > 0, Errors.Staking__InvalidMaxQueueFlushSize());
    require(
      _config.bootstrapValidatorSetSize == 0 || _config.bootstrapFlushSize > 0,
      Errors.Staking__InvalidBootstrapFlushSize()
    );
    require(
      _config.bootstrapFlushSize <= _config.maxQueueFlushSize,
      Errors.Staking__BootstrapFlushSizeAboveMax(_config.bootstrapFlushSize, _config.maxQueueFlushSize)
    );
  }

  function getStorage() internal pure returns (StakingStorage storage storageStruct) {
    bytes32 position = STAKING_SLOT;
    assembly {
      storageStruct.slot := position
    }
  }

  /// @notice Whether `_caller` can call {slash}.
  /// @dev The active slasher always qualifies. The legacy slasher qualifies only while its
  ///      drain window is still open, so quorum-backed rounds queued before a rotation can
  ///      still execute against the rollup even though the active slasher has moved on.
  function _isAuthorizedSlasher(StakingStorage storage _store, address _caller) private view returns (bool) {
    if (_caller == _store.slasher) {
      return true;
    }
    address legacy = _store.legacySlasher;
    if (legacy == address(0) || _caller != legacy) {
      return false;
    }
    return Timestamp.wrap(block.timestamp) <= _store.legacySlasherAuthorizedUntil.decompress();
  }

  function _calculateAvailableFlushes()
    private
    view
    returns (uint256 flushes, Epoch currentEpoch, bool shouldUpdateState)
  {
    StakingStorage storage store = getStorage();
    currentEpoch = TimeLib.epochFromTimestamp(Timestamp.wrap(block.timestamp));

    if (store.nextFlushableEpoch.decompress() > currentEpoch) {
      return (store.availableValidatorFlushes, currentEpoch, false);
    }

    uint256 activeAttesterCount = getAttesterCountAtTime(Timestamp.wrap(block.timestamp));
    uint256 newFlushes = getEntryQueueFlushSize(activeAttesterCount);

    return (newFlushes, currentEpoch, true);
  }
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly ("memory-safe") {
            result := store
        }

        return result;
    }
}

/**
 * @dev Library for reading and writing value-types to specific transient storage slots.
 *
 * Transient slots are often used to store temporary values that are removed after the current transaction.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 *  * Example reading and writing values using transient storage:
 * ```solidity
 * contract Lock {
 *     using TransientSlot for *;
 *
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _LOCK_SLOT = 0xf4678858b2b588224636b8522b729e7722d32fc491da849ed75b3fdf3c84f542;
 *
 *     modifier locked() {
 *         require(!_LOCK_SLOT.asBoolean().tload());
 *
 *         _LOCK_SLOT.asBoolean().tstore(true);
 *         _;
 *         _LOCK_SLOT.asBoolean().tstore(false);
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library TransientSlot {
    /**
     * @dev UDVT that represent a slot holding a address.
     */
    type AddressSlot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a AddressSlot.
     */
    function asAddress(bytes32 slot) internal pure returns (AddressSlot) {
        return AddressSlot.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bool.
     */
    type BooleanSlot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a BooleanSlot.
     */
    function asBoolean(bytes32 slot) internal pure returns (BooleanSlot) {
        return BooleanSlot.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a bytes32.
     */
    type Bytes32Slot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Bytes32Slot.
     */
    function asBytes32(bytes32 slot) internal pure returns (Bytes32Slot) {
        return Bytes32Slot.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a uint256.
     */
    type Uint256Slot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Uint256Slot.
     */
    function asUint256(bytes32 slot) internal pure returns (Uint256Slot) {
        return Uint256Slot.wrap(slot);
    }

    /**
     * @dev UDVT that represent a slot holding a int256.
     */
    type Int256Slot is bytes32;

    /**
     * @dev Cast an arbitrary slot to a Int256Slot.
     */
    function asInt256(bytes32 slot) internal pure returns (Int256Slot) {
        return Int256Slot.wrap(slot);
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(AddressSlot slot) internal view returns (address value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(AddressSlot slot, address value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(BooleanSlot slot) internal view returns (bool value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(BooleanSlot slot, bool value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Bytes32Slot slot) internal view returns (bytes32 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Bytes32Slot slot, bytes32 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Uint256Slot slot) internal view returns (uint256 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Uint256Slot slot, uint256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /**
     * @dev Load the value held at location `slot` in transient storage.
     */
    function tload(Int256Slot slot) internal view returns (int256 value) {
        assembly ("memory-safe") {
            value := tload(slot)
        }
    }

    /**
     * @dev Store `value` at location `slot` in transient storage.
     */
    function tstore(Int256Slot slot, int256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }
}

/**
 * @dev Library for computing storage (and transient storage) locations from namespaces and deriving slots
 * corresponding to standard patterns. The derivation method for array and mapping matches the storage layout used by
 * the solidity language / compiler.
 *
 * See https://docs.soliditylang.org/en/v0.8.20/internals/layout_in_storage.html#mappings-and-dynamic-arrays[Solidity docs for mappings and dynamic arrays.].
 *
 * Example usage:
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using StorageSlot for bytes32;
 *     using SlotDerivation for bytes32;
 *
 *     // Declare a namespace
 *     string private constant _NAMESPACE = "<namespace>" // eg. OpenZeppelin.Slot
 *
 *     function setValueInNamespace(uint256 key, address newValue) internal {
 *         _NAMESPACE.erc7201Slot().deriveMapping(key).getAddressSlot().value = newValue;
 *     }
 *
 *     function getValueInNamespace(uint256 key) internal view returns (address) {
 *         return _NAMESPACE.erc7201Slot().deriveMapping(key).getAddressSlot().value;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {StorageSlot}.
 *
 * NOTE: This library provides a way to manipulate storage locations in a non-standard way. Tooling for checking
 * upgrade safety will ignore the slots accessed through this library.
 *
 * _Available since v5.1._
 */
library SlotDerivation {
    /**
     * @dev Derive an ERC-7201 slot from a string (namespace).
     */
    function erc7201Slot(string memory namespace) internal pure returns (bytes32 slot) {
        assembly ("memory-safe") {
            mstore(0x00, sub(keccak256(add(namespace, 0x20), mload(namespace)), 1))
            slot := and(keccak256(0x00, 0x20), not(0xff))
        }
    }

    /**
     * @dev Add an offset to a slot to get the n-th element of a structure or an array.
     */
    function offset(bytes32 slot, uint256 pos) internal pure returns (bytes32 result) {
        unchecked {
            return bytes32(uint256(slot) + pos);
        }
    }

    /**
     * @dev Derive the location of the first element in an array from the slot where the length is stored.
     */
    function deriveArray(bytes32 slot) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, slot)
            result := keccak256(0x00, 0x20)
        }
    }

    /**
     * @dev Derive the location of a mapping element from the key.
     */
    function deriveMapping(bytes32 slot, address key) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, and(key, shr(96, not(0))))
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    /**
     * @dev Derive the location of a mapping element from the key.
     */
    function deriveMapping(bytes32 slot, bool key) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, iszero(iszero(key)))
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    /**
     * @dev Derive the location of a mapping element from the key.
     */
    function deriveMapping(bytes32 slot, bytes32 key) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, key)
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    /**
     * @dev Derive the location of a mapping element from the key.
     */
    function deriveMapping(bytes32 slot, uint256 key) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, key)
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    /**
     * @dev Derive the location of a mapping element from the key.
     */
    function deriveMapping(bytes32 slot, int256 key) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            mstore(0x00, key)
            mstore(0x20, slot)
            result := keccak256(0x00, 0x40)
        }
    }

    /**
     * @dev Derive the location of a mapping element from the key.
     */
    function deriveMapping(bytes32 slot, string memory key) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            let length := mload(key)
            let begin := add(key, 0x20)
            let end := add(begin, length)
            let cache := mload(end)
            mstore(end, slot)
            result := keccak256(begin, add(length, 0x20))
            mstore(end, cache)
        }
    }

    /**
     * @dev Derive the location of a mapping element from the key.
     */
    function deriveMapping(bytes32 slot, bytes memory key) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            let length := mload(key)
            let begin := add(key, 0x20)
            let end := add(begin, length)
            let cache := mload(end)
            mstore(end, slot)
            result := keccak256(begin, add(length, 0x20))
            mstore(end, cache)
        }
    }
}

struct CommitteeAttestations {
  // bitmap of which indices are signatures
  bytes signatureIndices;
  // tightly packed signatures and addresses
  bytes signaturesOrAddresses;
}

library CoordinationSignatureLib {
  bytes32 internal constant DOMAIN_TYPEHASH =
    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
  bytes32 internal constant NAME_HASH = keccak256("Aztec Rollup");
  bytes32 internal constant VERSION_HASH = keccak256("1");

  bytes32 internal constant BLOCK_PROPOSAL_TYPEHASH = keccak256("BlockProposal(bytes32 payloadHash)");
  bytes32 internal constant CHECKPOINT_PROPOSAL_TYPEHASH = keccak256("CheckpointProposal(bytes32 payloadHash)");
  bytes32 internal constant CHECKPOINT_ATTESTATION_TYPEHASH = keccak256("CheckpointAttestation(bytes32 payloadHash)");
  bytes32 internal constant ATTESTATIONS_AND_SIGNERS_TYPEHASH =
    keccak256("AttestationsAndSigners(bytes32 payloadHash)");

  function domainSeparator() internal view returns (bytes32) {
    return domainSeparator(address(this));
  }

  function domainSeparator(address _verifyingContract) internal view returns (bytes32) {
    return keccak256(abi.encode(DOMAIN_TYPEHASH, NAME_HASH, VERSION_HASH, block.chainid, _verifyingContract));
  }

  function toTypedDataHash(bytes32 _structHash) internal view returns (bytes32) {
    return toTypedDataHash(_structHash, address(this));
  }

  function toTypedDataHash(bytes32 _structHash, address _verifyingContract) internal view returns (bytes32) {
    return keccak256(abi.encodePacked(hex"1901", domainSeparator(_verifyingContract), _structHash));
  }

  function blockProposalDigest(bytes32 _payloadHash) internal view returns (bytes32) {
    return blockProposalDigest(_payloadHash, address(this));
  }

  function blockProposalDigest(bytes32 _payloadHash, address _verifyingContract) internal view returns (bytes32) {
    return toTypedDataHash(keccak256(abi.encode(BLOCK_PROPOSAL_TYPEHASH, _payloadHash)), _verifyingContract);
  }

  function checkpointProposalDigest(bytes32 _payloadHash) internal view returns (bytes32) {
    return checkpointProposalDigest(_payloadHash, address(this));
  }

  function checkpointProposalDigest(bytes32 _payloadHash, address _verifyingContract) internal view returns (bytes32) {
    return toTypedDataHash(keccak256(abi.encode(CHECKPOINT_PROPOSAL_TYPEHASH, _payloadHash)), _verifyingContract);
  }

  function checkpointAttestationDigest(bytes32 _payloadHash) internal view returns (bytes32) {
    return checkpointAttestationDigest(_payloadHash, address(this));
  }

  function checkpointAttestationDigest(bytes32 _payloadHash, address _verifyingContract)
    internal
    view
    returns (bytes32)
  {
    return toTypedDataHash(keccak256(abi.encode(CHECKPOINT_ATTESTATION_TYPEHASH, _payloadHash)), _verifyingContract);
  }

  function attestationsAndSignersDigest(bytes32 _payloadHash) internal view returns (bytes32) {
    return attestationsAndSignersDigest(_payloadHash, address(this));
  }

  function attestationsAndSignersDigest(bytes32 _payloadHash, address _verifyingContract)
    internal
    view
    returns (bytes32)
  {
    return toTypedDataHash(keccak256(abi.encode(ATTESTATIONS_AND_SIGNERS_TYPEHASH, _payloadHash)), _verifyingContract);
  }
}

uint256 constant SIGNATURE_LENGTH = 65;

uint256 constant ADDRESS_LENGTH = 20;

library AttestationLib {
  using SignatureLib for Signature;

  function getAttestationsAndSignersDigest(CommitteeAttestations memory _attestations, address[] memory _signers)
    internal
    view
    returns (bytes32)
  {
    return getAttestationsAndSignersDigest(_attestations, _signers, address(this));
  }

  function getAttestationsAndSignersDigest(
    CommitteeAttestations memory _attestations,
    address[] memory _signers,
    address _verifyingContract
  ) internal view returns (bytes32) {
    return CoordinationSignatureLib.attestationsAndSignersDigest(
      keccak256(abi.encode(_attestations, _signers)), _verifyingContract
    );
  }

  /**
   * @notice Checks if the given CommitteeAttestations is empty
   *          Wll return true if either component is empty as they are needed together.
   * @param _attestations - The committee attestations
   * @return True if the committee attestations are empty, false otherwise
   */
  function isEmpty(CommitteeAttestations memory _attestations) internal pure returns (bool) {
    return _attestations.signatureIndices.length == 0 || _attestations.signaturesOrAddresses.length == 0;
  }

  /**
   * @notice Checks if the given index in the CommitteeAttestations is a signature
   * @param _attestations - The committee attestations
   * @param _index - The index to check
   * @return True if the index is a signature, false otherwise
   *
   * @dev The signatureIndices is a bitmap of which indices are signatures.
   * The index is a signature if the bit at the index is 1.
   * The index is an address if the bit at the index is 0.
   *
   * See its use over in ValidatorSelectionLib.sol
   */
  function isSignature(CommitteeAttestations memory _attestations, uint256 _index) internal pure returns (bool) {
    uint256 byteIndex = _index / 8;
    uint256 shift = 7 - (_index % 8);
    return (uint8(_attestations.signatureIndices[byteIndex]) >> shift) & 1 == 1;
  }

  /**
   * @notice Gets the signature at the given index
   * @param _attestations - The committee attestations
   * @param _index - The index of the signature to get
   */
  function getSignature(CommitteeAttestations memory _attestations, uint256 _index)
    internal
    pure
    returns (Signature memory)
  {
    bytes memory signaturesOrAddresses = _attestations.signaturesOrAddresses;
    require(isSignature(_attestations, _index), Errors.AttestationLib__NotASignatureAtIndex(_index));

    uint256 dataPtr;
    assembly {
      // Skip length
      dataPtr := add(signaturesOrAddresses, 0x20)
    }

    // Move to the start of the signature
    for (uint256 i = 0; i < _index; ++i) {
      dataPtr += isSignature(_attestations, i) ? SIGNATURE_LENGTH : ADDRESS_LENGTH;
    }

    uint8 v;
    bytes32 r;
    bytes32 s;

    assembly {
      v := byte(0, mload(dataPtr))
      dataPtr := add(dataPtr, 1)
      r := mload(dataPtr)
      dataPtr := add(dataPtr, 32)
      s := mload(dataPtr)
    }
    return Signature({v: v, r: r, s: s});
  }

  /**
   * @notice Gets the address at the given index
   * @param _attestations - The committee attestations
   * @param _index - The index of the address to get
   */
  function getAddress(CommitteeAttestations memory _attestations, uint256 _index) internal pure returns (address) {
    bytes memory signaturesOrAddresses = _attestations.signaturesOrAddresses;
    require(!isSignature(_attestations, _index), Errors.AttestationLib__NotAnAddressAtIndex(_index));

    uint256 dataPtr;
    assembly {
      // Skip length
      dataPtr := add(signaturesOrAddresses, 0x20)
    }

    // Move to the start of the signature
    for (uint256 i = 0; i < _index; ++i) {
      dataPtr += isSignature(_attestations, i) ? SIGNATURE_LENGTH : ADDRESS_LENGTH;
    }

    address addr;
    assembly {
      addr := shr(96, mload(dataPtr))
    }

    return addr;
  }

  /**
   * Recovers the committee from the addresses in the attestations and signers.
   *
   * @custom:reverts SignatureIndicesSizeMismatch if the signature indices have a wrong size
   * @custom:reverts OutOfBounds throws if reading data beyond the `_attestations`
   * @custom:reverts SignaturesOrAddressesSizeMismatch if the signatures or addresses object has wrong size
   *
   * @param _attestations - The committee attestations
   * @param _signers The addresses of the committee members that signed the attestations. Provided in order to not have
   * to recover them from their attestations' signatures (and hence save gas). The addresses of the non-signing
   * committee members are directly included in the attestations.
   * @param _length - The number of addresses to return, should match the number of committee members
   * @return The addresses of the committee members.
   */
  function reconstructCommitteeFromSigners(
    CommitteeAttestations memory _attestations,
    address[] memory _signers,
    uint256 _length
  ) internal pure returns (address[] memory) {
    uint256 bitmapBytes = (_length + 7) / 8; // Round up to nearest byte
    require(
      bitmapBytes == _attestations.signatureIndices.length,
      Errors.AttestationLib__SignatureIndicesSizeMismatch(bitmapBytes, _attestations.signatureIndices.length)
    );

    // To get a ref that we can easily use with the assembly down below.
    bytes memory signaturesOrAddresses = _attestations.signaturesOrAddresses;
    address[] memory addresses = new address[](_length);

    uint256 signersIndex;
    uint256 dataPtr;
    uint256 currentByte;
    uint256 bitMask;

    assembly {
      // Skip length
      dataPtr := add(signaturesOrAddresses, 0x20)
    }
    uint256 offset = dataPtr;

    for (uint256 i = 0; i < _length; ++i) {
      // Load new byte every 8 iterations
      if (i % 8 == 0) {
        uint256 byteIndex = i / 8;
        currentByte = uint8(_attestations.signatureIndices[byteIndex]);
        bitMask = 128; // 0b10000000
      }

      bool isSignatureFlag = (currentByte & bitMask) != 0;
      bitMask >>= 1;

      if (isSignatureFlag) {
        dataPtr += SIGNATURE_LENGTH;
        addresses[i] = _signers[signersIndex];
        signersIndex++;
      } else {
        address addr;
        assembly {
          addr := shr(96, mload(dataPtr))
          dataPtr := add(dataPtr, 20)
        }
        addresses[i] = addr;
      }
    }

    // Ensure that the size of data provided actually matches what we expect
    uint256 sizeOfSignaturesAndAddresses =
      (signersIndex * SIGNATURE_LENGTH) + ((_length - signersIndex) * ADDRESS_LENGTH);
    require(
      sizeOfSignaturesAndAddresses == _attestations.signaturesOrAddresses.length,
      Errors.AttestationLib__SignaturesOrAddressesSizeMismatch(
        sizeOfSignaturesAndAddresses, _attestations.signaturesOrAddresses.length
      )
    );
    require(signersIndex == _signers.length, Errors.AttestationLib__SignersSizeMismatch(signersIndex, _signers.length));

    // Ensure that the reads were within the boundaries of the data, and that we have read all the data.
    // This check is an extra precaution. There are two cases, we we would end up with an invalid
    // read, and both should be covered by the above checks.
    // 1. If trying to read beyond the expected data, the bitmap must have more ones than signatures,
    // but this will make the the `sizeOfSignaturesAndAddresses` larger than passed data.
    // 2. If trying to read less than expected data, the bitmap must have fewer ones than signatures,
    // but this will make the the `sizeOfSignaturesAndAddresses` smaller than passed data.
    uint256 upperLimit = offset + _attestations.signaturesOrAddresses.length;
    require(dataPtr == upperLimit, Errors.AttestationLib__InvalidDataSize(dataPtr - offset, upperLimit - offset));

    return addresses;
  }
}

struct ValidatorSelectionStorage {
  // A mapping to snapshots of the validator set
  mapping(Epoch => bytes32 committeeCommitment) committeeCommitments;
  // Checkpointed map of epoch -> randao value
  Checkpoints.Trace224 randaos;
  // The following 3 uint32s pack into a single slot (12 bytes)
  uint32 targetCommitteeSize;
  uint32 lagInEpochsForValidatorSet;
  uint32 lagInEpochsForRandao;
  // Checkpointed escape hatch addresses (key = timestamp, value = address as uint160)
  Checkpoints.Trace160 escapeHatchCheckpoints;
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

type CompressedChainTips is uint256;

// We are using a type instead of a struct as we don't want to throw away a full 8 bits
// for the bool.
/*struct CompressedFeeHeader {
  uint1 preHeat;
  uint63 proverCost; Max value: 9.2233720369E18
  uint64 congestionCost;
  uint48 ethPerFeeAsset;
  uint48 excessMana;
  uint32 manaUsed;
}*/
type CompressedFeeHeader is uint256;

struct CompressedTempCheckpointLog {
  bytes32 headerHash;
  bytes32 blobCommitmentsHash;
  bytes32 outHash;
  bytes32 attestationsHash;
  bytes32 payloadDigest;
  CompressedSlot slotNumber;
  CompressedFeeHeader feeHeader;
}

/**
 * @title Data Structures Library
 * @author Aztec Labs
 * @notice Library that contains data structures used throughout the Aztec protocol
 */
library DataStructures {
  // docs:start:l1_actor
  /**
   * @notice Actor on L1.
   * @param actor - The address of the actor
   * @param chainId - The chainId of the actor
   */
  struct L1Actor {
    address actor;
    uint256 chainId;
  }

  // docs:end:l1_actor

  // docs:start:l2_actor
  /**
   * @notice Actor on L2.
   * @param actor - The aztec address of the actor
   * @param version - Ahe Aztec instance the actor is on
   */
  struct L2Actor {
    bytes32 actor;
    uint256 version;
  }

  // docs:end:l2_actor

  // docs:start:l1_to_l2_msg
  /**
   * @notice Struct containing a message from L1 to L2
   * @param sender - The sender of the message
   * @param recipient - The recipient of the message
   * @param content - The content of the message (application specific) padded to bytes32 or hashed if larger.
   * @param secretHash - The secret hash of the message (make it possible to hide when a specific message is consumed on
   * L2).
   * @param index - Global leaf index on the L1 to L2 messages tree.
   */
  struct L1ToL2Msg {
    L1Actor sender;
    L2Actor recipient;
    bytes32 content;
    bytes32 secretHash;
    uint256 index;
  }

  // docs:end:l1_to_l2_msg

  // docs:start:l2_to_l1_msg
  /**
   * @notice Struct containing a message from L2 to L1
   * @param sender - The sender of the message
   * @param recipient - The recipient of the message
   * @param content - The content of the message (application specific) padded to bytes32 or hashed if larger.
   * @dev Not to be confused with L2ToL1Message in Noir circuits
   */
  struct L2ToL1Msg {
    DataStructures.L2Actor sender;
    DataStructures.L1Actor recipient;
    bytes32 content;
  }
  // docs:end:l2_to_l1_msg
}

/**
 * @title Inbox
 * @author Aztec Labs
 * @notice Lives on L1 and is used to pass messages into the rollup from L1.
 */
interface IInbox {
  struct InboxState {
    // Rolling hash of all messages inserted into the inbox.
    // Used by clients to check for consistency.
    bytes16 rollingHash;
    // This value is not used much by the contract, but it is useful for synching the node faster
    // as it can more easily figure out if it can just skip looking for events for a time period.
    uint64 totalMessagesInserted;
    // Number of a tree which is currently being filled
    uint64 inProgress;
  }

  /**
   * @notice Emitted when a message is sent
   * @param checkpointNumber - The checkpoint number in which the message is included
   * @param index - The index of the message in the L1 to L2 messages tree
   * @param hash - The hash of the message
   * @param rollingHash - The rolling hash of all messages inserted into the inbox
   */
  event MessageSent(uint256 indexed checkpointNumber, uint256 index, bytes32 indexed hash, bytes16 rollingHash);

  // docs:start:send_l1_to_l2_message
  /**
   * @notice Inserts a new message into the Inbox
   * @dev Emits `MessageSent` with data for easy access by the sequencer
   * @param _recipient - The recipient of the message
   * @param _content - The content of the message (application specific)
   * @param _secretHash - The secret hash of the message (make it possible to hide when a specific message is consumed
   * on L2)
   * @return The key of the message in the set and its leaf index in the tree
   */
  function sendL2Message(DataStructures.L2Actor memory _recipient, bytes32 _content, bytes32 _secretHash)
    external
    returns (bytes32, uint256);
  // docs:end:send_l1_to_l2_message

  // docs:start:consume
  /**
   * @notice Consumes the current tree, and starts a new one if needed
   * @dev Only callable by the rollup contract
   * @dev In the first iteration we return empty tree root because first checkpoint's messages tree is always
   * empty because there has to be a 1 checkpoint lag to prevent sequencer DOS attacks
   *
   * @param _toConsume - The checkpoint number to consume
   *
   * @return The root of the consumed tree
   */
  function consume(uint256 _toConsume) external returns (bytes32);
  // docs:end:consume

  function getFeeAssetPortal() external view returns (address);

  function getRoot(uint256 _checkpointNumber) external view returns (bytes32);

  function getState() external view returns (InboxState memory);

  function getTotalMessagesInserted() external view returns (uint64);

  function getInProgress() external view returns (uint64);
}

type Bps is uint32;

/// @notice The post-deployment-mutable subset of {RewardConfig}.
/// @dev `rewardDistributor` and `booster` are deliberately *not* in this struct: they are
///      set once at construction and immutable thereafter.
struct MutableRewardConfig {
  Bps sequencerBps;
  uint96 checkpointReward;
}

function addEthValue(EthValue _a, EthValue _b) pure returns (EthValue) {
  return EthValue.wrap(EthValue.unwrap(_a) + EthValue.unwrap(_b));
}

function subEthValue(EthValue _a, EthValue _b) pure returns (EthValue) {
  return EthValue.wrap(EthValue.unwrap(_a) - EthValue.unwrap(_b));
}

using {addEthValue as +, subEthValue as -} for EthValue global;

// Represents a value denominated in ETH (wei).
type EthValue is uint256;

struct OracleInput {
  int256 feeAssetPriceModifier;
}

struct GasFees {
  uint128 feePerDaGas;
  uint128 feePerL2Gas;
}

struct ProposedHeader {
  bytes32 lastArchiveRoot;
  bytes32 blockHeadersHash;
  bytes32 blobsHash;
  bytes32 inHash;
  bytes32 outHash;
  Slot slotNumber;
  Timestamp timestamp;
  address coinbase;
  bytes32 feeRecipient;
  GasFees gasFees;
  uint256 totalManaUsed;
  uint256 accumulatedFees;
}

struct ProposeArgs {
  bytes32 archive;
  OracleInput oracleInput;
  ProposedHeader header;
}

struct PublicInputArgs {
  bytes32 previousArchive;
  bytes32 endArchive;
  bytes32 outHash;
  address proverId;
}

struct SubmitEpochRootProofArgs {
  uint256 start; // inclusive
  uint256 end; // inclusive
  PublicInputArgs args;
  ProposedHeader[] headers; // Must match what was proposed by the committee
  CommitteeAttestations attestations; // attestations for the last checkpoint in epoch
  bytes blobInputs;
  bytes proof;
}

interface IRollupCore {
  event CheckpointProposed(
    uint256 indexed checkpointNumber,
    bytes32 indexed archive,
    bytes32[] versionedBlobHashes,
    bytes32 payloadDigest,
    bytes32 attestationsHash
  );
  event L2ProofVerified(uint256 indexed checkpointNumber, address indexed proverId);
  event CheckpointInvalidated(uint256 indexed checkpointNumber);
  event RewardConfigUpdated(MutableRewardConfig rewardConfig);
  event ManaTargetUpdated(uint256 indexed manaTarget);
  event PrunedPending(uint256 provenCheckpointNumber, uint256 pendingCheckpointNumber);

  function claimSequencerRewards(address _recipient) external returns (uint256);
  function claimProverRewards(address _recipient, Epoch[] memory _epochs) external returns (uint256);

  function prune() external;
  function updateL1GasFeeOracle() external;

  function setProvingCostPerMana(EthValue _provingCostPerMana) external;

  function propose(
    ProposeArgs calldata _args,
    CommitteeAttestations memory _attestations,
    address[] memory _signers,
    Signature memory _attestationsAndSignersSignature,
    bytes calldata _blobInput
  ) external;

  function submitEpochRootProof(SubmitEpochRootProofArgs calldata _args) external;

  function invalidateBadAttestation(
    uint256 _checkpointNumber,
    CommitteeAttestations memory _attestations,
    address[] memory _committee,
    uint256 _invalidIndex
  ) external;

  function invalidateInsufficientAttestations(
    uint256 _checkpointNumber,
    CommitteeAttestations memory _attestations,
    address[] memory _committee
  ) external;

  function setRewardConfig(MutableRewardConfig memory _config) external;
  function updateManaTarget(uint256 _manaTarget) external;

  // solhint-disable-next-line func-name-mixedcase
  function L1_BLOCK_AT_GENESIS() external view returns (uint256);
}

/**
 * @notice Struct for storing flags for checkpoint header validation
 * @param ignoreDA - True will ignore DA check, otherwise checks
 */
struct CheckpointHeaderValidationFlags {
  bool ignoreDA;
}

struct ChainTips {
  uint256 pending;
  uint256 proven;
}

struct ManaMinFeeComponents {
  uint256 congestionCost;
  uint256 congestionMultiplier;
  uint256 sequencerCost;
  uint256 proverCost;
}

struct L1FeeData {
  uint256 baseFee;
  uint256 blobFee;
}

/*
 * ETH per fee asset price with 1e12 precision.
 * Higher stored value = more expensive fee asset (more ETH needed per 1 fee asset).
 * actual_eth_per_fee_asset = stored_value / ETH_PER_FEE_ASSET_PRECISION (decimals)
 *
 * We use 1e12 precision because:
 * 1. The value must fit in 48 bits when compressed in FeeHeader (max ~2.8e14)
 * 2. Higher precision allows representing very low prices (down to 1e-10 ETH)
 * 3. Reduces rounding errors during ETH <-> FeeAsset conversions
 *
 * See FeeLib.sol for the MIN/MAX bounds and detailed documentation.
 */
type EthPerFeeAssetE12 is uint256;

struct FeeHeader {
  uint256 excessMana;
  uint256 manaUsed;
  uint256 ethPerFeeAsset;
  uint256 congestionCost;
  uint256 proverCost;
}

/**
 * @notice Struct for storing checkpoint data, set in proposal.
 * @param archive - Archive tree root of the checkpoint
 * @param headerHash - Hash of the proposed checkpoint header
 * @param blobCommitmentsHash - H(...H(H(commitment_0), commitment_1).... commitment_n) - used to validate we are using
 * the same blob commitments on L1 and in the rollup circuit
 * @param attestationsHash - Hash of the attestations for this checkpoint
 * @param payloadDigest - Digest of the proposal payload that was attested to
 * @param slotNumber - This checkpoint's slot
 */
struct CheckpointLog {
  bytes32 archive;
  bytes32 headerHash;
  bytes32 blobCommitmentsHash;
  bytes32 outHash;
  bytes32 attestationsHash;
  bytes32 payloadDigest;
  Slot slotNumber;
  FeeHeader feeHeader;
}

// Represents a value denominated in the fee asset (e.g., AZTEC token).
type FeeAssetValue is uint256;

// File-level integer literal so it can be used as a fixed-size array length. MUST equal
// `Constants.MAX_CHECKPOINTS_PER_EPOCH`; the Outbox constructor enforces this at deploy time.
uint256 constant MAX_CHECKPOINTS_PER_EPOCH = 32;

/**
 * @title IOutbox
 * @author Aztec Labs
 * @notice Lives on L1 and is used to consume L2 -> L1 messages. Messages are inserted by the Rollup
 * and will be consumed by the portal contracts.
 */
interface IOutbox {
  event RootAdded(Epoch indexed epoch, uint256 indexed numCheckpointsInEpoch, bytes32 root);
  event MessageConsumed(
    Epoch indexed epoch,
    bytes32 indexed root,
    bytes32 indexed messageHash,
    uint256 leafId,
    uint256 numCheckpointsInEpoch
  );

  // docs:start:outbox_insert
  /**
   * @notice Inserts the root of a merkle tree containing all of the L2 to L1 messages in an epoch
   *         after a proof covering the first `_numCheckpointsInEpoch` checkpoints of that epoch lands.
   * @dev Only callable by the rollup contract
   * @dev Emits `RootAdded` upon inserting the root successfully
   * @dev Successive inserts for the same epoch with larger `_numCheckpointsInEpoch` values do not
   * disturb earlier entries, so users with witnesses built against an earlier partial proof can still
   * consume them.
   * @param _epoch - The epoch in which the L2 to L1 messages reside
   * @param _numCheckpointsInEpoch - The number of checkpoints the inserting proof covered in this
   * epoch. Must be in [1, MAX_CHECKPOINTS_PER_EPOCH].
   * @param _root - The merkle root of the tree where all the L2 to L1 messages are leaves
   */
  function insert(Epoch _epoch, uint256 _numCheckpointsInEpoch, bytes32 _root) external;
  // docs:end:outbox_insert

  // docs:start:outbox_consume
  /**
   * @notice Consumes an entry from the Outbox
   * @dev Only useable by portals / recipients of messages
   * @dev Emits `MessageConsumed` when consuming messages
   * @param _message - The L2 to L1 message
   * @param _epoch - The epoch that contains the message we want to consume
   * @param _numCheckpointsInEpoch - The number of checkpoints in the partial proof whose root this
   * consume verifies against. The caller's witness path must have been built against the epoch tree
   * padded to that number of real checkpoints.
   * @param _leafIndex - The index at the level in the epoch message tree where the message is located
   * @param _path - The sibling path used to prove inclusion of the message, the _path length depends
   * on the location of the L2 to L1 message in the epoch message tree.
   */
  function consume(
    DataStructures.L2ToL1Msg calldata _message,
    Epoch _epoch,
    uint256 _numCheckpointsInEpoch,
    uint256 _leafIndex,
    bytes32[] calldata _path
  ) external;
  // docs:end:outbox_consume

  // docs:start:outbox_has_message_been_consumed_at_epoch_and_index
  /**
   * @notice Checks to see if an L2 to L1 message in a specific epoch has been consumed
   * @dev - This function does not throw. Out-of-bounds access is considered valid, but will always return false
   * @param _epoch - The epoch that contains the message we want to check
   * @param _leafId - The unique id of the message leaf
   */
  function hasMessageBeenConsumedAtEpoch(Epoch _epoch, uint256 _leafId) external view returns (bool);
  // docs:end:outbox_has_message_been_consumed_at_epoch_and_index

  /**
   * @notice  Fetch the root data for a given epoch and partial-proof depth.
   *          Returns 0 if no proof has been inserted at that depth.
   *
   * @param _epoch - The epoch to fetch the root data for
   * @param _numCheckpointsInEpoch - The number of checkpoints in the partial proof whose root to fetch
   *
   * @return bytes32 - The root of the merkle tree containing the L2 to L1 messages
   */
  function getRootData(Epoch _epoch, uint256 _numCheckpointsInEpoch) external view returns (bytes32);

  /**
   * @notice  Fetch every root stored for a given epoch. The returned array has
   *          MAX_CHECKPOINTS_PER_EPOCH entries; slot `i` holds the root for
   *          `numCheckpointsInEpoch = i + 1`, or zero if no proof of that depth has been inserted.
   *
   * @param _epoch - The epoch to fetch the roots for
   *
   * @return bytes32[] - The roots stored for this epoch.
   */
  function getRoots(Epoch _epoch) external view returns (bytes32[MAX_CHECKPOINTS_PER_EPOCH] memory);
}

interface IVerifier {
  function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool);
}

interface IBoosterCore {
  function updateAndGetShares(address _prover) external returns (uint256);
  function getSharesFor(address _prover) external view returns (uint256);
}

struct RewardConfig {
  IRewardDistributor rewardDistributor;
  Bps sequencerBps;
  IBoosterCore booster;
  uint96 checkpointReward;
}

interface IRollup is IRollupCore, IHaveVersion {
  function validateHeaderWithAttestations(
    ProposedHeader calldata _header,
    CommitteeAttestations memory _attestations,
    address[] memory _signers,
    Signature memory _attestationsAndSignersSignature,
    bytes32 _digest,
    bytes32 _blobsHash,
    CheckpointHeaderValidationFlags memory _flags
  ) external;

  function canProposeAtTime(Timestamp _ts, bytes32 _archive, address _who) external returns (Slot, uint256);

  function getTips() external view returns (ChainTips memory);

  function status(uint256 _myHeaderCheckpointNumber)
    external
    view
    returns (
      uint256 provenCheckpointNumber,
      bytes32 provenArchive,
      uint256 pendingCheckpointNumber,
      bytes32 pendingArchive,
      bytes32 archiveOfMyCheckpoint,
      Epoch provenEpochNumber
    );

  function getEpochProofPublicInputs(
    uint256 _start,
    uint256 _end,
    PublicInputArgs calldata _args,
    ProposedHeader[] calldata _headers,
    bytes calldata _blobPublicInputs
  ) external view returns (bytes32[] memory);

  function validateBlobs(bytes calldata _blobsInputs) external view returns (bytes32[] memory, bytes32, bytes[] memory);

  function getManaMinFeeComponentsAt(Timestamp _timestamp, bool _inFeeAsset)
    external
    view
    returns (ManaMinFeeComponents memory);
  function getManaMinFeeAt(Timestamp _timestamp, bool _inFeeAsset) external view returns (uint256);
  function getL1FeesAt(Timestamp _timestamp) external view returns (L1FeeData memory);
  function getEthPerFeeAsset() external view returns (EthPerFeeAssetE12);

  function getEpochForCheckpoint(uint256 _checkpointNumber) external view returns (Epoch);
  function canPruneAtTime(Timestamp _ts) external view returns (bool);

  function archive() external view returns (bytes32);
  function archiveAt(uint256 _checkpointNumber) external view returns (bytes32);
  function getProvenCheckpointNumber() external view returns (uint256);
  function getPendingCheckpointNumber() external view returns (uint256);
  function getCheckpoint(uint256 _checkpointNumber) external view returns (CheckpointLog memory);
  function getFeeHeader(uint256 _checkpointNumber) external view returns (FeeHeader memory);
  function getBlobCommitmentsHash(uint256 _checkpointNumber) external view returns (bytes32);
  function getCurrentBlobCommitmentsHash() external view returns (bytes32);

  function getSharesFor(address _prover) external view returns (uint256);
  function getSequencerRewards(address _sequencer) external view returns (uint256);
  function getCollectiveProverRewardsForEpoch(Epoch _epoch) external view returns (uint256);
  function getSpecificProverRewardsForEpoch(Epoch _epoch, address _prover) external view returns (uint256);
  function getHasSubmitted(Epoch _epoch, uint256 _length, address _prover) external view returns (bool);
  function getHasClaimed(address _prover, Epoch _epoch) external view returns (bool);

  function getProofSubmissionEpochs() external view returns (uint256);
  function getManaTarget() external view returns (uint256);
  function getManaLimit() external view returns (uint256);
  function getProvingCostPerManaInEth() external view returns (EthValue);

  function getProvingCostPerManaInFeeAsset() external view returns (FeeAssetValue);

  function getFeeAsset() external view returns (IERC20);
  function getFeeAssetPortal() external view returns (IFeeJuicePortal);
  function getRewardDistributor() external view returns (IRewardDistributor);
  function getBurnAddress() external view returns (address);

  function getInbox() external view returns (IInbox);
  function getOutbox() external view returns (IOutbox);

  function getVkTreeRoot() external view returns (bytes32);
  function getProtocolContractsHash() external view returns (bytes32);
  function getEpochProofVerifier() external view returns (IVerifier);

  function getRewardConfig() external view returns (RewardConfig memory);
  function getCheckpointReward() external view returns (uint256);
}

interface IFeeJuicePortal {
  event DepositToAztecPublic(bytes32 indexed to, uint256 amount, bytes32 secretHash, bytes32 key, uint256 index);
  event FeesDistributed(address indexed to, uint256 amount);

  function distributeFees(address _to, uint256 _amount) external;
  function depositToAztecPublic(bytes32 _to, uint256 _amount, bytes32 _secretHash) external returns (bytes32, uint256);

  // solhint-disable-next-line func-name-mixedcase
  function UNDERLYING() external view returns (IERC20);
  // solhint-disable-next-line func-name-mixedcase
  function L2_TOKEN_ADDRESS() external view returns (bytes32);
  // solhint-disable-next-line func-name-mixedcase
  function VERSION() external view returns (uint256);
  // solhint-disable-next-line func-name-mixedcase
  function INBOX() external view returns (IInbox);
  // solhint-disable-next-line func-name-mixedcase
  function ROLLUP() external view returns (IRollup);
}

struct RollupConfig {
  bytes32 vkTreeRoot;
  bytes32 protocolContractsHash;
  uint32 version;
  IERC20 feeAsset;
  IFeeJuicePortal feeAssetPortal;
  IVerifier epochProofVerifier;
  IInbox inbox;
  IOutbox outbox;
}

struct RollupStore {
  CompressedChainTips tips; // put first such that the struct slot structure is easy to follow for cheatcodes
  mapping(uint256 checkpointNumber => bytes32 archive) archives;
  // The following represents a circular buffer. Key is `checkpointNumber % size`.
  mapping(uint256 circularIndex => CompressedTempCheckpointLog temp) tempCheckpointLogs;
  RollupConfig config;
}

library ChainTipsLib {
  using SafeCast for uint256;

  uint256 internal constant PENDING_CHECKPOINT_NUMBER_MASK =
    0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 internal constant PROVEN_CHECKPOINT_NUMBER_MASK = 0xffffffffffffffffffffffffffffffff;

  function getPending(CompressedChainTips _compressedChainTips) internal pure returns (uint256) {
    return CompressedChainTips.unwrap(_compressedChainTips) >> 128;
  }

  function getProven(CompressedChainTips _compressedChainTips) internal pure returns (uint256) {
    return CompressedChainTips.unwrap(_compressedChainTips) & PROVEN_CHECKPOINT_NUMBER_MASK;
  }

  function updatePending(CompressedChainTips _compressedChainTips, uint256 _pendingCheckpointNumber)
    internal
    pure
    returns (CompressedChainTips)
  {
    uint256 value = CompressedChainTips.unwrap(_compressedChainTips) & ~PENDING_CHECKPOINT_NUMBER_MASK;
    return CompressedChainTips.wrap(value | (uint256(_pendingCheckpointNumber.toUint128()) << 128));
  }

  function updateProven(CompressedChainTips _compressedChainTips, uint256 _provenCheckpointNumber)
    internal
    pure
    returns (CompressedChainTips)
  {
    uint256 value = CompressedChainTips.unwrap(_compressedChainTips) & ~PROVEN_CHECKPOINT_NUMBER_MASK;
    return CompressedChainTips.wrap(value | _provenCheckpointNumber.toUint128());
  }

  function compress(ChainTips memory _chainTips) internal pure returns (CompressedChainTips) {
    // We are doing cast to uint128 but inside a uint256 to not wreck the shifting.
    uint256 pending = _chainTips.pending.toUint128();
    uint256 proven = _chainTips.proven.toUint128();
    return CompressedChainTips.wrap((pending << 128) | proven);
  }

  function decompress(CompressedChainTips _compressedChainTips) internal pure returns (ChainTips memory) {
    return ChainTips({pending: getPending(_compressedChainTips), proven: getProven(_compressedChainTips)});
  }
}

library FeeHeaderLib {
  using SafeCast for uint256;

  uint256 internal constant MASK_32_BITS = 0xFFFFFFFF;
  uint256 internal constant MASK_48_BITS = 0xFFFFFFFFFFFF;
  uint256 internal constant MASK_63_BITS = 0x7FFFFFFFFFFFFFFF;
  uint256 internal constant MASK_64_BITS = 0xFFFFFFFFFFFFFFFF;

  function getManaUsed(CompressedFeeHeader _compressedFeeHeader) internal pure returns (uint256) {
    return CompressedFeeHeader.unwrap(_compressedFeeHeader) & MASK_32_BITS;
  }

  function getExcessMana(CompressedFeeHeader _compressedFeeHeader) internal pure returns (uint256) {
    return (CompressedFeeHeader.unwrap(_compressedFeeHeader) >> 32) & MASK_48_BITS;
  }

  function getEthPerFeeAsset(CompressedFeeHeader _compressedFeeHeader) internal pure returns (uint256) {
    return (CompressedFeeHeader.unwrap(_compressedFeeHeader) >> 80) & MASK_48_BITS;
  }

  function getCongestionCost(CompressedFeeHeader _compressedFeeHeader) internal pure returns (uint256) {
    return (CompressedFeeHeader.unwrap(_compressedFeeHeader) >> 128) & MASK_64_BITS;
  }

  function getProverCost(CompressedFeeHeader _compressedFeeHeader) internal pure returns (uint256) {
    // The prover cost is only 63 bits so use mask to remove first bit
    return (CompressedFeeHeader.unwrap(_compressedFeeHeader) >> 192) & MASK_63_BITS;
  }

  function compress(FeeHeader memory _feeHeader) internal pure returns (CompressedFeeHeader) {
    uint256 value = 0;
    value |= uint256(_feeHeader.manaUsed.toUint32());
    // Cap excessMana to uint48 max to prevent overflow during compression.
    value |= Math.min(_feeHeader.excessMana, MASK_48_BITS) << 32;
    value |= uint256(_feeHeader.ethPerFeeAsset.toUint48()) << 80;
    // Cap congestionCost to uint64 max to prevent overflow during compression.
    // The uncapped value is still used for fee validation; this only affects storage.
    value |= Math.min(_feeHeader.congestionCost, MASK_64_BITS) << 128;
    // Cap proverCost to uint63 max to prevent overflow during compression.
    value |= Math.min(_feeHeader.proverCost, MASK_63_BITS) << 192;

    // Preheat
    value |= 1 << 255;

    return CompressedFeeHeader.wrap(value);
  }

  function decompress(CompressedFeeHeader _compressedFeeHeader) internal pure returns (FeeHeader memory) {
    uint256 value = CompressedFeeHeader.unwrap(_compressedFeeHeader);

    uint256 manaUsed = value & MASK_32_BITS;
    value >>= 32;
    uint256 excessMana = value & MASK_48_BITS;
    value >>= 48;
    uint256 ethPerFeeAsset = value & MASK_48_BITS;
    value >>= 48;
    uint256 congestionCost = value & MASK_64_BITS;
    value >>= 64;
    uint256 proverCost = value & MASK_63_BITS;

    return FeeHeader({
      manaUsed: uint256(manaUsed),
      excessMana: uint256(excessMana),
      ethPerFeeAsset: uint256(ethPerFeeAsset),
      congestionCost: uint256(congestionCost),
      proverCost: uint256(proverCost)
    });
  }
}

struct TempCheckpointLog {
  bytes32 headerHash;
  bytes32 blobCommitmentsHash;
  bytes32 outHash;
  bytes32 attestationsHash;
  bytes32 payloadDigest;
  Slot slotNumber;
  FeeHeader feeHeader;
}

library CompressedTempCheckpointLogLib {
  using CompressedTimeMath for Slot;
  using CompressedTimeMath for CompressedSlot;
  using FeeHeaderLib for FeeHeader;
  using FeeHeaderLib for CompressedFeeHeader;

  function compress(TempCheckpointLog memory _checkpoint) internal pure returns (CompressedTempCheckpointLog memory) {
    return CompressedTempCheckpointLog({
      headerHash: _checkpoint.headerHash,
      blobCommitmentsHash: _checkpoint.blobCommitmentsHash,
      outHash: _checkpoint.outHash,
      attestationsHash: _checkpoint.attestationsHash,
      payloadDigest: _checkpoint.payloadDigest,
      slotNumber: _checkpoint.slotNumber.compress(),
      feeHeader: _checkpoint.feeHeader.compress()
    });
  }

  function decompress(CompressedTempCheckpointLog memory _compressedCheckpoint)
    internal
    pure
    returns (TempCheckpointLog memory)
  {
    return TempCheckpointLog({
      headerHash: _compressedCheckpoint.headerHash,
      blobCommitmentsHash: _compressedCheckpoint.blobCommitmentsHash,
      outHash: _compressedCheckpoint.outHash,
      attestationsHash: _compressedCheckpoint.attestationsHash,
      payloadDigest: _compressedCheckpoint.payloadDigest,
      slotNumber: _compressedCheckpoint.slotNumber.decompress(),
      feeHeader: _compressedCheckpoint.feeHeader.decompress()
    });
  }
}

struct GenesisState {
  bytes32 vkTreeRoot;
  bytes32 protocolContractsHash;
  bytes32 genesisArchiveRoot;
}

/**
 * @title Constants Library
 * @author Aztec Labs
 * @notice Library that contains constants used throughout the Aztec protocol
 */
library Constants {
  // Prime field modulus
  uint256 internal constant P =
    21_888_242_871_839_275_222_246_405_745_257_275_088_548_364_400_416_034_343_698_204_186_575_808_495_617;

  uint256 internal constant MAX_FIELD_VALUE =
    21_888_242_871_839_275_222_246_405_745_257_275_088_548_364_400_416_034_343_698_204_186_575_808_495_616;
  uint256 internal constant L1_TO_L2_MSG_SUBTREE_HEIGHT = 10;
  uint256 internal constant MAX_L2_TO_L1_MSGS_PER_TX = 8;
  uint256 internal constant INITIAL_CHECKPOINT_NUMBER = 1;
  uint256 internal constant MAX_CHECKPOINTS_PER_EPOCH = 32;
  uint256 internal constant GENESIS_ARCHIVE_ROOT =
    10_619_256_997_260_439_436_842_531_499_967_995_403_253_967_496_480_475_679_746_178_797_053_672_406_517;
  uint256 internal constant EMPTY_EPOCH_OUT_HASH =
    355_785_372_471_781_095_838_790_036_702_437_931_769_306_153_278_986_832_745_847_530_947_941_691_539;
  uint256 internal constant FEE_JUICE_ADDRESS = 3;
  uint256 internal constant BLS12_POINT_COMPRESSED_BYTES = 48;
  uint256 internal constant ROOT_ROLLUP_PUBLIC_INPUTS_LENGTH = 111;
  uint256 internal constant NUM_MSGS_PER_BASE_PARITY = 256;
  uint256 internal constant NUM_BASE_PARITY_PER_ROOT_PARITY = 4;
}

/**
 * @title FieldLib
 * @author Aztec Labs
 * @notice Helpers for validating that values stored on L1 are valid BN254 scalar field elements.
 * @dev Off-chain components decode several L1 storage slots into `Fr`. A value `>=` the field modulus throws on
 *      conversion and would brick honest archivers' L1 sync, so such values are rejected at write time.
 */
library FieldLib {
  /// @notice Reverts with `Rollup__FieldElementOutOfRange` unless `_value` is a valid field element (`< Constants.P`).
  function requireValidFieldElement(bytes32 _value) internal pure {
    require(uint256(_value) < Constants.P, Errors.Rollup__FieldElementOutOfRange(_value));
  }
}

/**
 * @title STFLib - State Transition Function Library
 * @author Aztec Labs
 * @notice Core library responsible for managing the rollup state transition function and checkpoint storage.
 *
 * @dev This library implements the essential state management functionality for the Aztec rollup, including:
 *      - Archive root storage indexed by checkpoint number for permanent state history
 *      - Circular storage for temporary checkpoint logs
 *      - Checkpoint pruning mechanism to remove unproven checkpoints after proof submission window expires
 *      - Namespaced storage pattern following EIP-7201 for secure storage isolation
 *
 *      Storage Architecture:
 *      - Uses EIP-7201 namespaced storage
 *      - Archives mapping: permanent storage of proven checkpoint archive roots
 *      - TempCheckpointLogs: circular buffer storing temporary checkpoint data (gets overwritten after N checkpoints)
 *      - Tips: tracks both pending (latest proposed) and proven (latest with valid proof) checkpoint numbers
 *
 *      Circular Storage ("Roundabout") Pattern:
 *      - The temporary checkpoint logs use a circular storage pattern where checkpoints are stored at index
 *        (checkpointNumber % roundaboutSize).
 *        This reuses storage slots for old checkpoints that have been proven or pruned.
 *        The roundabout size is calculated as maxPrunableCheckpoints() + 1 to ensure at least the last proven
 *        checkpoint remains accessible even after pruning operations. This saves gas costs by minimizing storage writes
 *         to fresh slots.
 *
 *      Pruning Mechanism:
 *      - Checkpoints become eligible for pruning when their proof submission window expires. The proof submission
 *        window is defined as a configurable number of epochs after the epoch containing the checkpoint.
 *        When pruning occurs, all unproven checkpoints are removed from the pending chain, and the chain
 *        resumes from the last proven checkpoint.
 *      - Rationale for pruning is that an epoch may contain a checkpoint that provers cannot prove. Pruning allows us
 *        to trade a large reorg for chain liveness, by removing potential unprovable checkpoints so we can continue.
 *      - A prover may not be able to prove a checkpoint if the transaction data for that checkpoint is not available.
 *        Transaction data is NOT posted to DA since transactions (along with their Chonk proofs) are big, and it would
 *        be too costly to submit everything to checkpoints. So we count on the committee to attest to the availability
 *        of that data, but if for some reason the data does not reach provers via p2p, then provers will not be able to
 *        prove.
 *
 *      Security Considerations:
 *      - Archive roots provide immutable history of proven state transitions
 *      - Circular storage saves gas while maintaining necessary data
 *      - Proof submission windows ensure liveness by preventing indefinite stalling
 *      - EIP-7201 namespaced storage prevents accidental storage collisions with other contracts
 *
 * @dev TempCheckpointLog Structure
 *
 *      The TempCheckpointLog struct represents temporary checkpoint data stored in the circular buffer
 *      until checkpoints overwritten. It contains:
 *
 *      Fields:
 *      - headerHash: Hash of the complete checkpoint header containing all checkpoint metadata
 *      - blobCommitmentsHash: Hash of all blob commitments used for data availability verification
 *      - attestationsHash: Hash of committee member attestations validating the checkpoint
 *      - payloadDigest: Digest of the proposal payload that committee members attested to
 *      - slotNumber: The specific slot when this checkpoint was proposed (determines epoch assignment)
 *      - feeHeader: Compressed fee information including base fees and mana pricing
 *
 *      Storage Optimization:
 *      The struct is stored in compressed format (CompressedTempCheckpointLog) to minimize gas costs.
 *      Compression primarily affects the slotNumber (reduced from 256-bit to smaller representation)
 *      and feeHeader (packed fee components). Other fields remain as 32-byte hashes.
 */
library STFLib {
  using TimeLib for Slot;
  using TimeLib for Epoch;
  using TimeLib for Timestamp;
  using CompressedTimeMath for CompressedSlot;
  using ChainTipsLib for CompressedChainTips;
  using CompressedTempCheckpointLogLib for CompressedTempCheckpointLog;
  using CompressedTempCheckpointLogLib for TempCheckpointLog;
  using CompressedTimeMath for Slot;
  using CompressedTimeMath for CompressedSlot;
  using FeeHeaderLib for CompressedFeeHeader;

  // @note  This is also used in the cheatcodes, so if updating, please also update the cheatcode.
  bytes32 private constant STF_STORAGE_POSITION = keccak256("aztec.stf.storage");

  /**
   * @notice Initializes the rollup state with genesis configuration
   * @dev Sets up the initial state of the rollup including verification keys and the genesis archive root.
   *      This function should only be called once during rollup deployment.
   *
   * @param _genesisState The initial state configuration containing:
   *        - vkTreeRoot: Root of the verification key tree for circuit verification
   *        - protocolContractsHash: Root containing protocol contract addresses and configurations
   *        - genesisArchiveRoot: Initial archive root representing the genesis state
   */
  function initialize(GenesisState memory _genesisState) internal {
    RollupStore storage rollupStore = STFLib.getStorage();

    rollupStore.config.vkTreeRoot = _genesisState.vkTreeRoot;
    rollupStore.config.protocolContractsHash = _genesisState.protocolContractsHash;

    // The genesis archive root is decoded as an Fr off chain and propagates into the first header's lastArchiveRoot,
    // so it must be a valid field element.
    FieldLib.requireValidFieldElement(_genesisState.genesisArchiveRoot);
    rollupStore.archives[0] = _genesisState.genesisArchiveRoot;
  }

  /**
   * @notice Writes the genesis fee header at checkpoint 0
   * @dev This sets the initial ethPerFeeAsset value that will be used as the starting point
   *      for the fee asset price oracle. Must be called during rollup initialization.
   * @param _initialEthPerFeeAsset The initial ETH per fee asset price (with 1e12 precision)
   */
  function writeGenesisFeeHeader(uint256 _initialEthPerFeeAsset) internal {
    RollupStore storage rollupStore = STFLib.getStorage();
    // Write to checkpoint 0's slot in the circular buffer
    rollupStore.tempCheckpointLogs[0] = TempCheckpointLog({
        headerHash: bytes32(0),
        blobCommitmentsHash: bytes32(0),
        outHash: bytes32(0),
        attestationsHash: bytes32(0),
        payloadDigest: bytes32(0),
        slotNumber: Slot.wrap(0),
        feeHeader: FeeHeader({
          excessMana: 0, manaUsed: 0, ethPerFeeAsset: _initialEthPerFeeAsset, congestionCost: 0, proverCost: 0
        })
      }).compress();
  }

  /**
   * @notice Stores a temporary checkpoint log in the circular storage buffer
   * @dev Compresses and stores checkpoint data at the appropriate index in the circular buffer.
   *      The storage index is calculated as (pending checkpoint % roundaboutSize) to implement
   *      the circular storage pattern.
   *      Don't need to check if storage is stale as always writing to freshest.
   *
   * @param _tempCheckpointLog The temporary checkpoint log containing header hash, attestations,
   *        blob commitments, payload digest, slot number, and fee information
   */
  function addTempCheckpointLog(TempCheckpointLog memory _tempCheckpointLog) internal {
    uint256 checkpointNumber = STFLib.getStorage().tips.getPending();
    uint256 size = roundaboutSize();
    getStorage().tempCheckpointLogs[checkpointNumber % size] = _tempCheckpointLog.compress();
  }

  /**
   * @notice Removes unproven checkpoints from the pending chain when proof submission window expires
   * @dev This function implements the pruning mechanism that maintains rollup liveness by removing
   *      checkpoints that cannot be proven within the configured time window. When called:
   *
   *      1. Identifies the gap between pending and proven checkpoint numbers
   *      2. Resets the pending chain tip to match the last proven checkpoint
   *      3. Effectively removes all unproven checkpoints from the pending chain
   *
   *      The pruning does not delete checkpoint data from storage but makes it inaccessible by
   *      updating the chain tips.
   *
   *      Pruning should only occur when the proof submission window has expired for pending
   *      checkpoints, which is validated by the calling function (typically through canPruneAtTime).
   *
   *      Emits PrunedPending event with the proven and previously pending checkpoint numbers.
   */
  function prune() internal {
    RollupStore storage rollupStore = STFLib.getStorage();
    CompressedChainTips tips = rollupStore.tips;
    uint256 pending = tips.getPending();

    // @note  We are not deleting the checkpoints, but we are "winding back" the pendingTip to the last checkpoint that
    //        was proven.
    //        We can do because any new checkpoint proposed will overwrite a previous checkpoint in the checkpoint log,
    //        so no values should "survive".
    //        People must therefore read the chain using the pendingTip as a boundary.
    uint256 proven = tips.getProven();
    rollupStore.tips = tips.updatePending(proven);

    emit IRollupCore.PrunedPending(proven, pending);
  }

  /**
   * @notice Calculates the size of the circular storage buffer for temporary checkpoint logs
   * @dev The roundabout size determines how many checkpoints can be stored in the circular buffer
   *      before older entries are overwritten. The size is calculated as:
   *
   *      roundaboutSize = maxPrunableCheckpoints() + 1
   *
   *      Where maxPrunableCheckpoints() = epochDuration * (proofSubmissionEpochs + 1)
   *
   *      This ensures that:
   *      - All checkpoints within the proof submission window remain accessible
   *      - At least the last proven checkpoint is available as a trusted anchor
   *
   * @return The number of slots in the circular storage buffer
   */
  function roundaboutSize() internal view returns (uint256) {
    // Must be ensured to contain at least the last proven checkpoint even after a prune.
    return TimeLib.maxPrunableCheckpoints() + 1;
  }

  /**
   * @notice Returns a storage reference to a compressed temporary checkpoint log
   * @dev Provides direct access to the compressed checkpoint log in storage without decompression.
   *      Reverts if the checkpoint number is stale (no longer accessible in circular storage) or if
   *      the checkpoint have not happened yet.
   *
   * @dev A temporary checkpoint log is stale if it can no longer be accessed in the circular storage buffer.
   *      The staleness is determined by the relationship between the checkpoint number, current pending
   *      checkpoint, and the buffer size.
   *
   *      Example with roundabout size 5 and pending checkpoint 7:
   *      Circular buffer state: [checkpoint5, checkpoint6, checkpoint7, checkpoint3, checkpoint4]
   *
   *      A checkpoint is available if:
   *      - checkpointNumber <= pending  (it is not in the future)
   *      - pending < checkpointNumber + size (the override is in the future)
   *      Together as a span:
   *      - checkpointNumber <= pending < checkpointNumber + size
   *
   *      For example, checkpoint 2 is unavailable since the override has happened:
   *      - 2 <= 7 (true) && 7 < 2 + 5 (false)
   *      But checkpoint 3 is available as it in the past, but not overridden yet
   *      - 3 <= 7 (true) && 7 < 3 + 5 (true)
   *
   *      This ensures that only checkpoints within the current "window" of the circular buffer
   *      are considered valid and accessible.
   *
   * @param _checkpointNumber The checkpoint number to get the storage reference for
   * @return A storage reference to the compressed temporary checkpoint log
   */
  function getStorageTempCheckpointLog(uint256 _checkpointNumber)
    internal
    view
    returns (CompressedTempCheckpointLog storage)
  {
    uint256 pending = getStorage().tips.getPending();
    uint256 size = roundaboutSize();

    uint256 upperLimit = _checkpointNumber + size;
    bool available = _checkpointNumber <= pending && pending < upperLimit;
    require(available, Errors.Rollup__UnavailableTempCheckpointLog(_checkpointNumber, pending, upperLimit));

    return getStorage().tempCheckpointLogs[_checkpointNumber % size];
  }

  /**
   * @notice Retrieves and decompresses a temporary checkpoint log from circular storage
   * @dev Fetches the compressed checkpoint log from the circular buffer and decompresses it.
   *      Reverts if the checkpoint number is stale and no longer accessible.
   * @param _checkpointNumber The checkpoint number to retrieve the log for
   * @return The decompressed temporary checkpoint log containing all checkpoint metadata
   */
  function getTempCheckpointLog(uint256 _checkpointNumber) internal view returns (TempCheckpointLog memory) {
    return getStorageTempCheckpointLog(_checkpointNumber).decompress();
  }

  /**
   * @notice Retrieves the header hash for a specific checkpoint number
   * @dev Gas-efficient accessor that returns only the header hash without decompressing
   *      the entire checkpoint log. Reverts if the checkpoint number is stale.
   * @param _checkpointNumber The checkpoint number to get the header hash for
   * @return The header hash of the specified checkpoint
   */
  function getHeaderHash(uint256 _checkpointNumber) internal view returns (bytes32) {
    return getStorageTempCheckpointLog(_checkpointNumber).headerHash;
  }

  /**
   * @notice Retrieves the compressed fee header for a specific checkpoint number
   * @dev Returns the fee information including base fee components and mana costs.
   *      The data remains in compressed format for gas efficiency. Reverts if the checkpoint is stale.
   * @param _checkpointNumber The checkpoint number to get the fee header for
   * @return The compressed fee header containing fee-related data
   */
  function getFeeHeader(uint256 _checkpointNumber) internal view returns (CompressedFeeHeader) {
    return getStorageTempCheckpointLog(_checkpointNumber).feeHeader;
  }

  /**
   * @notice Retrieves the blob commitments hash for a specific checkpoint number
   * @dev Returns the hash of all blob commitments for the checkpoint, used for data availability
   *      verification. Reverts if the checkpoint number is stale.
   * @param _checkpointNumber The checkpoint number to get the blob commitments hash for
   * @return The hash of blob commitments for the specified checkpoint
   */
  function getBlobCommitmentsHash(uint256 _checkpointNumber) internal view returns (bytes32) {
    return getStorageTempCheckpointLog(_checkpointNumber).blobCommitmentsHash;
  }

  /**
   * @notice Retrieves the slot number for a specific checkpoint number
   * @dev Returns the decompressed slot number indicating when the checkpoint was proposed.
   *      Reverts if the checkpoint number is stale.
   * @param _checkpointNumber The checkpoint number to get the slot number for
   * @return The slot number when the checkpoint was proposed
   */
  function getSlotNumber(uint256 _checkpointNumber) internal view returns (Slot) {
    return getStorageTempCheckpointLog(_checkpointNumber).slotNumber.decompress();
  }

  /**
   * @notice Gets the effective pending checkpoint number based on pruning eligibility
   * @dev Returns either the pending checkpoint number or proven checkpoint number depending on
   *      whether pruning is allowed at the given timestamp. This is used to determine
   *      the effective chain tip for operations that should respect pruning windows.
   *
   *      If pruning is allowed: returns proven checkpoint number (chain should be pruned)
   *      If pruning is not allowed: returns pending checkpoint number (normal operation)
   * @param _timestamp The timestamp to evaluate pruning eligibility against
   * @return The effective checkpoint number that should be considered as the chain tip
   */
  function getEffectivePendingCheckpointNumber(Timestamp _timestamp) internal view returns (uint256) {
    RollupStore storage rollupStore = STFLib.getStorage();
    CompressedChainTips tips = rollupStore.tips;
    return STFLib.canPruneAtTime(_timestamp) ? tips.getProven() : tips.getPending();
  }

  /**
   * @notice Determines which epoch a checkpoint belongs to
   * @dev Calculates the epoch for a given checkpoint number by retrieving the checkpoint's slot
   *      and converting it to an epoch. Reverts if the checkpoint number exceeds the pending tip.
   * @param _checkpointNumber The checkpoint number to get the epoch for
   * @return The epoch containing the specified checkpoint
   */
  function getEpochForCheckpoint(uint256 _checkpointNumber) internal view returns (Epoch) {
    RollupStore storage rollupStore = STFLib.getStorage();
    require(
      _checkpointNumber <= rollupStore.tips.getPending(),
      Errors.Rollup__InvalidCheckpointNumber(rollupStore.tips.getPending(), _checkpointNumber)
    );
    return getSlotNumber(_checkpointNumber).epochFromSlot();
  }

  /**
   * @notice Determines if the chain can be pruned at a given timestamp
   * @dev Checks whether the proof submission window has expired for the oldest pending checkpoints.
   *      Pruning is allowed when:
   *
   *      1. There are unproven checkpoints (pending > proven)
   *      2. The oldest pending epoch is no longer accepting proofs at the epoch at _ts
   *
   *      The proof submission window is defined by the aztecProofSubmissionEpochs configuration,
   *      which specifies how many epochs after an epoch ends that proofs are still accepted.
   *
   *      Example timeline:
   *      - Checkpoint proposed in epoch N
   *      - Proof submission window = 1 epochs
   *      - Proof deadline epoch = N + Proof submission window + 1
   *          The deadline is the point in time where it is no longer acceptable, (if you touch the line you die)
   *      - If epoch(_ts) >= epoch N + Proof submission window + 1, pruning is allowed
   *
   *      This mechanism ensures rollup liveness by preventing indefinite stalling on unprovable checkpoints (e.g due to
   *      the committee failing to disseminate the data) while providing sufficient time for proof generation and
   *      submission.
   *
   * @param _ts The current timestamp to check against
   * @return True if pruning is allowed at the given timestamp, false otherwise
   */
  function canPruneAtTime(Timestamp _ts) internal view returns (bool) {
    RollupStore storage rollupStore = STFLib.getStorage();

    CompressedChainTips tips = rollupStore.tips;

    if (tips.getPending() == tips.getProven()) {
      return false;
    }

    Epoch oldestPendingEpoch = getEpochForCheckpoint(tips.getProven() + 1);
    Epoch currentEpoch = _ts.epochFromTimestamp();

    return !oldestPendingEpoch.isAcceptingProofsAtEpoch(currentEpoch);
  }

  /**
   * @notice Retrieves the namespaced storage for the STFLib using EIP-7201 pattern
   * @dev Uses inline assembly to access storage at a specific slot calculated from the
   *      keccak256 hash of "aztec.stf.storage". This ensures storage isolation and
   *      prevents collisions with other contracts or libraries.
   *
   *      The storage contains:
   *      - Chain tips (pending and proven checkpoint numbers)
   *      - Archives mapping (permanent checkpoint archive storage)
   *      - TempCheckpointLogs mapping (circular buffer for temporary checkpoint data)
   *      - Rollup configuration
   * @return storageStruct A storage pointer to the RollupStore struct
   */
  function getStorage() internal pure returns (RollupStore storage storageStruct) {
    bytes32 position = STF_STORAGE_POSITION;
    assembly {
      storageStruct.slot := position
    }
  }
}

/**
 * @title   SampleLib
 * @author  Anaxandridas II
 * @notice  A tiny library to draw committee indices using a sample without replacement algorithm.
 */
library SampleLib {
  using SlotDerivation for string;
  using SlotDerivation for bytes32;
  using TransientSlot for *;

  // Namespace for transient storage keys used within this library
  string private constant OVERRIDE_NAMESPACE = "Aztec.SampleLib.Override";

  /**
   * Compute Committee
   *
   * @param _committeeSize - The size of the committee
   * @param _indexCount - The total number of indices
   * @param _seed - The seed to use for shuffling
   *
   * @dev assumption, _committeeSize <= _indexCount
   *
   * @return indices - The indices of the committee
   */
  function computeCommittee(uint256 _committeeSize, uint256 _indexCount, uint256 _seed)
    internal
    returns (uint256[] memory)
  {
    require(_committeeSize <= _indexCount, Errors.SampleLib__SampleLargerThanIndex(_committeeSize, _indexCount));

    if (_committeeSize == 0) {
      return new uint256[](0);
    }

    uint256[] memory sampledIndices = new uint256[](_committeeSize);

    uint256 upperLimit = _indexCount - 1;

    for (uint256 index = 0; index < _committeeSize; index++) {
      uint256 sampledIndex = computeSampleIndex(index, upperLimit + 1, _seed);

      // Get index, or its swapped override
      sampledIndices[index] = getValue(sampledIndex);
      if (upperLimit > 0) {
        // Swap with the last index
        setOverrideValue(sampledIndex, getValue(upperLimit));
        // Decrement the upper limit
        upperLimit--;
      }
    }

    // Clear transient storage.
    // Note that we are clearing the `sampleIndices` and do not keep track of a separate list of
    // `sampleIndex` values that were written to. The reasoning is that we only overwrite values for
    // duplicate cases, so `sampleIndices` is a superset of the `sampleIndex` values that have been drawn
    // (to account for duplicates). Therefore, clearing `sampleIndices` clears everything.
    // Due to the cost of `tstore` and `tload` operations, it is cheaper to overwrite all values
    // rather than checking if there is anything to override.
    for (uint256 i = 0; i < _committeeSize; i++) {
      setOverrideValue(sampledIndices[i], 0);
    }

    return sampledIndices;
  }

  function setOverrideValue(uint256 _index, uint256 _value) internal {
    OVERRIDE_NAMESPACE.erc7201Slot().deriveMapping(_index).asUint256().tstore(_value);
  }

  function getValue(uint256 _index) internal view returns (uint256) {
    uint256 overrideValue = getOverrideValue(_index);
    if (overrideValue != 0) {
      return overrideValue;
    }

    return _index;
  }

  function getOverrideValue(uint256 _index) internal view returns (uint256) {
    return OVERRIDE_NAMESPACE.erc7201Slot().deriveMapping(_index).asUint256().tload();
  }

  /**
   * @notice  Compute the sample index for a given index, seed and index count.
   *
   * @param _index - The index to shuffle
   * @param _indexCount - The total number of indices
   * @param _seed - The seed to use for shuffling
   *
   * @return shuffledIndex - The shuffled index
   */
  function computeSampleIndex(uint256 _index, uint256 _indexCount, uint256 _seed) internal pure returns (uint256) {
    // Cannot modulo by 0 and if 1, then only acceptable value is 0
    if (_indexCount <= 1) {
      return 0;
    }

    return uint256(keccak256(abi.encodePacked(_seed, _index))) % _indexCount;
  }
}

/**
 * @title ValidatorSelectionLib
 * @author Aztec Labs
 * @notice Core library responsible for validator selection, committee management, and proposer verification in the
 * Aztec rollup.
 *
 * @dev This library implements the validator selection system:
 *      - Epoch-based committee sampling
 *      - Slot-based proposer selection within committee members
 *      - Signature verification for checkpoint proposals and attestations
 *      - Committee commitment validation and caching mechanisms
 *      - Randomness seed management for unpredictable but deterministic selection
 *
 *      Key Components:
 *
 *      1. Committee Selection:
 *         - At the start of each epoch, a committee is sampled from the active validator set
 *         - Committee size is configurable at deployment (targetCommitteeSize), and must be met
 *         - Selection uses cryptographic randomness (prevrandao + epoch)
 *         - Committee remains stable throughout the entire epoch for consistency
 *         - Committee commitment is stored onchain and validated against reconstructed committees
 *
 *      2. Proposer Selection:
 *         - For each slot within an epoch, one committee member is selected as the proposer (this may change)
 *         - Selection is deterministic based on epoch, slot, and the epoch's sample seed
 *         - Proposers have exclusive rights to propose checkpoints during their assigned slot
 *         - Proposer verification ensures only the correct validator can submit checkpoints
 *
 *      3. Attestation System:
 *         - Committee members attest to checkpoints by providing signatures
 *         - Attestations serve dual purpose: data availability and state validation
 *         - Checkpoints require >2/3 committee signatures to be considered valid
 *         - Signatures are verified against expected committee members using ECDSA recovery
 *         - Mixed signature/address format allows optimization (addresses included only for non-signing members,
 *           addresses for signing members can be recovered from the signatures and hence are not needed for DA
 *           purposes)
 *         - Signature verification is delayed until proof submission to save gas
 *
 *      4. Seed Management:
 *         - Sample seeds determine committee and proposer selection for each epoch
 *         - Seeds use prevrandao from L1 blocks combined with epoch number for unpredictability
 *         - Prevrandao are set 2 epochs in advance to prevent last-minute manipulation and provide L1-reorg resistance
 *         - First two epochs use randao values (type(uint224).max) for bootstrap (this results in the committee
 *           being predictable in the first 2 epochs which is considered acceptable when bootstrapping the network)
 *
 *      5. Caching and Optimization:
 *         - Transient storage caches proposer computations within the same transaction
 *           - This is used when signaling for a governance or slashing payload after a checkpoint proposal
 *         - Committee commitments are stored to avoid recomputation during verification
 *         - Validator indices are sampled once and reused for address resolution
 *
 *      Integration with Rollup System:
 *      - Called from RollupCore.setupEpoch() to initialize epoch committees
 *      - Used in ProposeLib.propose() for proposer verification during checkpoint submission
 *      - Integrates with StakingLib to resolve validator addresses from staking indices
 *      - Works with InvalidateLib for committee verification during invalidation
 *
 *      Security Model:
 *      - Randomness comes from L1 prevrandao
 *      - Committee selection happens before epoch start, preventing manipulation
 *      - Signature verification ensures only legitimate committee members can attest
 *      - Committee commitments prevent committee substitution attacks
 *      - Two-epoch delay in seed setting prevents last-minute influence and provides L1-reorg resistance
 *
 *      Time-based Architecture:
 *      - Epochs define committee boundaries (committee stable within epoch)
 *      - Slots define proposer assignments (one proposer per slot)
 *      - Sampling uses a lagging time for the epoch to ensure validator set stability
 *      - Validator set snapshots taken at deterministic timestamps for consistency
 *      - Getters for an epoch committee throw if queried in a non-stable epoch (as in an epoch that may still change
 *        its committee since it's in the future)
 */
library ValidatorSelectionLib {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SignatureLib for Signature;
  using TimeLib for Timestamp;
  using TimeLib for Epoch;
  using TimeLib for Slot;
  using Checkpoints for Checkpoints.Trace224;
  using Checkpoints for Checkpoints.Trace160;
  using SafeCast for *;
  using TransientSlot for *;
  using SlotDerivation for string;
  using SlotDerivation for bytes32;
  using AttestationLib for CommitteeAttestations;

  /**
   * @dev Stack struct used in verifyAttestations to avoid stack too deep errors
   *      Used when reconstructing the committee commitment from the attestations
   * @param index Working index for iteration (unused in current implementation)
   * @param needed Number of signatures required (2/3 + 1 of committee size)
   * @param signaturesRecovered Number of valid signatures found
   * @param reconstructedCommittee Array of committee member addresses reconstructed from attestations
   */
  struct VerifyStack {
    uint256 index;
    uint256 needed;
    uint256 signaturesRecovered;
    address[] reconstructedCommittee;
  }

  bytes32 private constant VALIDATOR_SELECTION_STORAGE_POSITION = keccak256("aztec.validator_selection.storage");
  // Namespace for cached proposer computations
  string private constant PROPOSER_NAMESPACE = "aztec.validator_selection.transient.proposer";

  /**
   * @notice Initializes the validator selection system with target committee size
   * @dev It is HIGHLY recommended to use lagInEpochsForValidatorSet > lagInEpochsForRandao, to avoid sequencer bias
   *      but we allow them being equal because it makes test networks faster to kick off.
   * @dev Sets up the initial configuration and bootstrap seeds for the first two epochs.
   *      The first two epochs use maximum seed values for startup.
   * @param _targetCommitteeSize The desired number of validators in each epoch's committee
   */
  function initialize(uint256 _targetCommitteeSize, uint256 _lagInEpochsForValidatorSet, uint256 _lagInEpochsForRandao)
    internal
  {
    require(
      _lagInEpochsForValidatorSet >= _lagInEpochsForRandao,
      Errors.ValidatorSelection__InvalidLagInEpochs(_lagInEpochsForValidatorSet, _lagInEpochsForRandao)
    );
    ValidatorSelectionStorage storage store = getStorage();
    store.targetCommitteeSize = _targetCommitteeSize.toUint32();
    store.lagInEpochsForValidatorSet = _lagInEpochsForValidatorSet.toUint32();
    store.lagInEpochsForRandao = _lagInEpochsForRandao.toUint32();

    checkpointRandao(Epoch.wrap(0));
  }

  /**
   * @notice Sets the escape hatch contract address. One-shot: can only be called once per rollup.
   * @dev Only callable through RollupCore.setEscapeHatch (owner-gated). Once set, the rollup's
   *      escape hatch is immutable for the life of the rollup -- there is no replacement path.
   *      Callers who want no escape hatch should simply never call this function.
   * @param _escapeHatch The address of the EscapeHatch contract (must be non-zero)
   */
  function setEscapeHatch(address _escapeHatch) internal {
    require(_escapeHatch != address(0), Errors.ValidatorSelection__EscapeHatchCannotBeZero());

    // The registration is one-shot and ungoverned after setup, and an open escape hatch can act
    // as an alternate proposal route (ProposeLib.propose authorizes the registered escape
    // hatch's designated proposer during escape-hatch epochs). Pointing at a stranger contract
    // -- including a hatch wired to a different rollup -- would create a permanent foreign
    // proposal authority that cannot be replaced. Require the hatch to point back here.
    address hatchRollup = IEscapeHatch(_escapeHatch).getRollup();
    require(
      hatchRollup == address(this), Errors.ValidatorSelection__EscapeHatchRollupMismatch(address(this), hatchRollup)
    );

    ValidatorSelectionStorage storage store = getStorage();
    require(store.escapeHatchCheckpoints.length() == 0, Errors.ValidatorSelection__EscapeHatchAlreadySet());

    // Key the checkpoint to the START of the next epoch so the registration never affects
    // the current epoch. This prevents a same-block action from retroactively classifying
    // an in-flight epoch as an escape-hatch epoch.
    Epoch nextEpoch = Timestamp.wrap(block.timestamp).epochFromTimestamp() + Epoch.wrap(1);
    uint96 nextEpochTs = uint96(Timestamp.unwrap(nextEpoch.toTimestamp()));
    store.escapeHatchCheckpoints.push(nextEpochTs, uint160(_escapeHatch));
  }

  /**
   * @notice Performs epoch setup by sampling the committee and setting future seeds
   * @dev This function handles the epoch transition by:
   *      1. Retrieving the sample seed for the current epoch
   *      2. Setting the sample seed for the next epoch (if not already set)
   *      3. Sampling and storing the committee for the current epoch (if not already done)
   *
   *      This setup ensures that each epoch has a stable committee and that future epochs
   *      have their randomness seeds prepared in advance.
   * @param _epochNumber The epoch number to set up
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function setupEpoch(Epoch _epochNumber) internal {
    ValidatorSelectionStorage storage store = getStorage();

    bytes32 committeeCommitment = store.committeeCommitments[_epochNumber];
    if (committeeCommitment != bytes32(0)) {
      // We already have the commitment stored for the epoch meaning the epoch has already been setup.
      return;
    }

    //################ Seeds ################
    // Get the sample seed for this current epoch.
    uint256 sampleSeed = getSampleSeed(_epochNumber);

    // Checkpoint randao for future sampling if required
    // function handles the case where it is already set
    checkpointRandao(_epochNumber);

    //################ Committee ################
    // If the committee is not set for this epoch, we need to sample it
    address[] memory committee = sampleValidators(_epochNumber, sampleSeed);
    store.committeeCommitments[_epochNumber] = computeCommitteeCommitment(committee);
  }

  /**
   * @notice Verifies that the checkpoint proposal has been signed by the correct proposer
   * @dev Validates proposer eligibility and signature for checkpoint proposals by:
   *      1. Attempting to load cached proposer from transient storage
   *      2. If not cached, reconstructing committee from attestations and verifying against stored commitment
   *      3. Computing proposer index using epoch, slot, and sample seed
   *      4. Verifying the proposer has provided a valid signature in the attestations
   *
   *      The attestation is checked by reconstructing the committee commitment from the attestations and signers,
   *      and then ensuring it matches the stored commitment for the epoch.
   *
   *      Uses transient storage caching to avoid recomputation within the same transaction. (This caching mechanism is
   *      commonly used when a proposer signals in governance and submits a proposal within the same transaction - then
   *      `getProposerAt` function is called).
   * @param _slot The slot of the checkpoint being proposed
   * @param _epochNumber The epoch number of the checkpoint
   * @param _attestations The committee attestations for the checkpoint proposal
   * @param _signers The addresses of the committee members that signed the attestations. Provided in order to not have
   * to recover them from their attestations' signatures (and hence save gas). The addresses of the non-signing
   * committee members are directly included in the attestations.
   * @param _digest The digest of the checkpoint being proposed
   * @param _updateCache Flag to identify that the proposer should be written to transient cache.
   * @custom:reverts Errors.ValidatorSelection__InvalidCommitteeCommitment if reconstructed committee doesn't match
   * stored commitment
   * @custom:reverts Errors.ValidatorSelection__MissingProposerSignature if proposer hasn't signed their attestation
   * @custom:reverts SignatureLib verification errors if proposer signature is invalid
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function verifyProposer(
    Slot _slot,
    Epoch _epochNumber,
    CommitteeAttestations memory _attestations,
    address[] memory _signers,
    bytes32 _digest,
    Signature memory _attestationsAndSignersSignature,
    bool _updateCache
  ) internal {
    uint256 proposerIndex;
    address proposer;

    {
      // Load the committee commitment for the epoch
      (bytes32 committeeCommitment, uint256 committeeSize) = getCommitteeCommitmentAt(_epochNumber);

      // If the rollup is *deployed* with a target committee size of 0, we skip the validation.
      // Note: This generally only happens in test setups; In production, the target committee is non-zero,
      // and one can see in `sampleValidators` that we will revert if the target committee size is not met.
      if (committeeSize == 0) {
        return;
      }

      // Reconstruct the committee from the attestations and signers
      address[] memory committee = _attestations.reconstructCommitteeFromSigners(_signers, committeeSize);

      // Check reconstructed committee commitment matches the expected one for the epoch
      bytes32 reconstructedCommitment = computeCommitteeCommitment(committee);
      if (reconstructedCommitment != committeeCommitment) {
        revert Errors.ValidatorSelection__InvalidCommitteeCommitment(reconstructedCommitment, committeeCommitment);
      }

      // Get the proposer from the committee based on the epoch, slot, and sample seed
      uint256 sampleSeed = getSampleSeed(_epochNumber);
      proposerIndex = computeProposerIndex(_epochNumber, _slot, sampleSeed, committeeSize);
      proposer = committee[proposerIndex];
    }

    // We check that the proposer agrees with the proposal by checking that he attested to it. If we fail to get
    // the proposer's attestation signature or if we fail to verify it, we revert.
    bool hasProposerSignature = _attestations.isSignature(proposerIndex);
    if (!hasProposerSignature) {
      revert Errors.ValidatorSelection__MissingProposerSignature(proposer, proposerIndex);
    }

    // Check if the signature is correct
    Signature memory signature = _attestations.getSignature(proposerIndex);
    SignatureLib.verify(signature, proposer, _digest);

    // Check that the proposer have signed the `_attestations|_signers` data such that invalid `_attestations|_signers`
    // data can be attributed to the `proposer` specifically.
    bytes32 attestationsAndSignersDigest = _attestations.getAttestationsAndSignersDigest(_signers);
    SignatureLib.verify(_attestationsAndSignersSignature, proposer, attestationsAndSignersDigest);

    if (_updateCache) {
      setCachedProposer(_slot, proposer, proposerIndex);
    }
  }

  /**
   * @notice Verifies committee attestations meet the required threshold and signature validity
   * @dev Performs attestation validation by:
   *      1. Retrieving stored committee commitment and target committee size
   *      2. Computing proposer index for signature verification optimization
   *      3. Extracting and verifying signatures from packed attestation data
   *      4. Reconstructing committee addresses from signatures and provided addresses
   *      5. Validating reconstructed committee matches stored commitment
   *      6. Ensuring at least 2/3 + 1 committee members provided signatures
   *
   *      Each committee attestation is either their:
   *      - Signature (65 bytes: v, r, s) for attestation
   *      - Address (20 bytes) for non-signing members
   *
   *      Note that providing the addresses of non-signing members allows for reconstructing the committee commitment
   *      directly from calldata.
   *
   *      Skips validation entirely if target committee size is 0 (test configurations).
   * @param _epochNumber The epoch of the checkpoint
   * @param _attestations The packed signatures and addresses of committee members
   * @param _digest The digest of the checkpoint that attestations are signed over
   * @custom:reverts Errors.ValidatorSelection__InsufficientAttestations if less than 2/3 + 1 signatures provided
   * @custom:reverts Errors.ValidatorSelection__InvalidCommitteeCommitment if reconstructed committee doesn't match
   * stored commitment
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function verifyAttestations(Epoch _epochNumber, CommitteeAttestations memory _attestations, bytes32 _digest)
    internal
  {
    (bytes32 committeeCommitment, uint256 targetCommitteeSize) = getCommitteeCommitmentAt(_epochNumber);

    // If the rollup is *deployed* with a target committee size of 0, we skip the validation.
    // Note: This generally only happens in test setups; In production, the target committee is non-zero,
    // and one can see in `sampleValidators` that we will revert if the target committee size is not met.
    if (targetCommitteeSize == 0) {
      return;
    }

    VerifyStack memory stack = VerifyStack({
      needed: (targetCommitteeSize << 1) / 3 + 1, // targetCommitteeSize * 2 / 3 + 1, but cheaper
      index: 0,
      signaturesRecovered: 0,
      reconstructedCommittee: new address[](targetCommitteeSize)
    });

    bytes memory signaturesOrAddresses = _attestations.signaturesOrAddresses;
    uint256 dataPtr;
    assembly {
      dataPtr := add(signaturesOrAddresses, 0x20) // Skip length, cache pointer
    }

    unchecked {
      for (uint256 i = 0; i < targetCommitteeSize; ++i) {
        bool isSignature = _attestations.isSignature(i);

        if (isSignature) {
          uint8 v;
          bytes32 r;
          bytes32 s;

          assembly {
            v := byte(0, mload(dataPtr))
            dataPtr := add(dataPtr, 1)
            r := mload(dataPtr)
            dataPtr := add(dataPtr, 32)
            s := mload(dataPtr)
            dataPtr := add(dataPtr, 32)
          }

          ++stack.signaturesRecovered;
          stack.reconstructedCommittee[i] = ECDSA.recover(_digest, v, r, s);
        } else {
          address addr;
          assembly {
            addr := shr(96, mload(dataPtr))
            dataPtr := add(dataPtr, 20)
          }
          stack.reconstructedCommittee[i] = addr;
        }
      }
    }

    require(
      stack.signaturesRecovered >= stack.needed,
      Errors.ValidatorSelection__InsufficientAttestations(stack.needed, stack.signaturesRecovered)
    );

    // Check the committee commitment
    bytes32 reconstructedCommitment = computeCommitteeCommitment(stack.reconstructedCommittee);
    if (reconstructedCommitment != committeeCommitment) {
      revert Errors.ValidatorSelection__InvalidCommitteeCommitment(reconstructedCommitment, committeeCommitment);
    }
  }

  /**
   * @notice Caches proposer information in transient storage for the current transaction
   * @dev Uses EIP-1153 transient storage to cache proposer data, avoiding recomputation within the same transaction.
   *      Packs proposer address (160 bits) and index (96 bits) into a single 32-byte slot for efficiency.
   * @param _slot The slot to cache the proposer for
   * @param _proposer The proposer's address
   * @param _proposerIndex The proposer's index within the committee
   * @custom:reverts Errors.ValidatorSelection__ProposerIndexTooLarge if proposer index exceeds uint96 max
   */
  function setCachedProposer(Slot _slot, address _proposer, uint256 _proposerIndex) internal {
    require(_proposerIndex <= type(uint96).max, Errors.ValidatorSelection__ProposerIndexTooLarge(_proposerIndex));
    bytes32 packed = bytes32(uint256(uint160(_proposer))) | (bytes32(_proposerIndex) << 160);
    PROPOSER_NAMESPACE.erc7201Slot().deriveMapping(Slot.unwrap(_slot)).asBytes32().tstore(packed);
  }

  /**
   * @notice Gets the proposer for a specific slot, using cache or computing if necessary
   * @dev First checks transient storage cache, then computes proposer if not cached.
   *      Computation involves sampling validator indices and selecting based on slot.
   * @param _slot The slot to get the proposer for
   * @return proposer The address of the proposer for the slot
   * @return proposerIndex The index of the proposer within the committee, zero address and index if committee size is
   * 0 (ie test configuration).
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function getProposerAt(Slot _slot) internal returns (address, uint256) {
    (address cachedProposer, uint256 cachedProposerIndex) = getCachedProposer(_slot);
    if (cachedProposer != address(0)) {
      return (cachedProposer, cachedProposerIndex);
    }

    Epoch epochNumber = _slot.epochFromSlot();

    uint256 sampleSeed = getSampleSeed(epochNumber);
    (uint32 ts, uint256[] memory indices) = sampleValidatorsIndices(epochNumber, sampleSeed);
    uint256 committeeSize = indices.length;
    if (committeeSize == 0) {
      return (address(0), 0);
    }
    uint256 proposerIndex = computeProposerIndex(epochNumber, _slot, sampleSeed, committeeSize);
    return (StakingLib.getAttesterFromIndexAtTime(indices[proposerIndex], Timestamp.wrap(ts)), proposerIndex);
  }

  /**
   * @notice Samples validator addresses for a specific epoch using cryptographic randomness
   * @dev Samples validator indices first, then resolves to addresses at the appropriate timestamp.
   *      Only used internally for epoch setup - should never be called for past or distant future epochs.
   * @param _epoch The epoch to sample validators for
   * @param _seed The cryptographic seed for sampling randomness
   * @return The array of validator addresses selected for the committee
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function sampleValidators(Epoch _epoch, uint256 _seed) internal returns (address[] memory) {
    (uint32 ts, uint256[] memory indices) = sampleValidatorsIndices(_epoch, _seed);
    return StakingLib.getAttestersFromIndicesAtTime(Timestamp.wrap(ts), indices);
  }

  /**
   * @notice Gets the committee addresses for a specific epoch
   * @dev Retrieves the sample seed for the epoch and uses it to sample the validator committee.
   *      This function will trigger committee sampling if not already done for the epoch.
   * @param _epochNumber The epoch to get the committee for
   * @return The array of committee member addresses for the epoch
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function getCommitteeAt(Epoch _epochNumber) internal returns (address[] memory) {
    uint256 seed = getSampleSeed(_epochNumber);
    return sampleValidators(_epochNumber, seed);
  }

  /**
   * @notice Gets the committee commitment and size for an epoch
   * @dev Retrieves the stored committee commitment, or computes it if not yet stored.
   *      The commitment is a keccak256 hash of the committee member addresses array.
   * @param _epochNumber The epoch to get the committee commitment for
   * @return committeeCommitment The keccak256 hash of the committee member addresses
   * @return committeeSize The target committee size (same for all epochs)
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function getCommitteeCommitmentAt(Epoch _epochNumber)
    internal
    returns (bytes32 committeeCommitment, uint256 committeeSize)
  {
    ValidatorSelectionStorage storage store = getStorage();

    committeeCommitment = store.committeeCommitments[_epochNumber];
    if (committeeCommitment == 0) {
      // This is an edge case that can happen if `setupEpoch` has not been called (see documentation of
      // `RollupCore.setupEpoch` for details), so we compute the commitment again to guarantee that we get a real value.
      committeeCommitment = computeCommitteeCommitment(sampleValidators(_epochNumber, getSampleSeed(_epochNumber)));
    }

    return (committeeCommitment, store.targetCommitteeSize);
  }

  /**
   * @notice Checkpoints randao value for future usage
   * @dev Checks if already stored before storing the randao value.
   * @param _epoch The current epoch
   */
  function checkpointRandao(Epoch _epoch) internal {
    ValidatorSelectionStorage storage store = getStorage();

    // Check if the latest checkpoint is for the next epoch
    // It should be impossible that zero epoch snapshots exist, as in the genesis state we push the first values
    // into the store
    (, uint32 mostRecentTs,) = store.randaos.latestCheckpoint();
    uint32 ts = Timestamp.unwrap(_epoch.toTimestamp()).toUint32();

    // If the most recently stored epoch is less than the epoch we are querying, then we need to store randao for
    // later use. We truncate to save storage costs.
    if (mostRecentTs < ts) {
      store.randaos.push(ts, uint224(block.prevrandao));
    }
  }

  /**
   * @notice Validates if a specific validator can propose a checkpoint at a given time and chain state
   * @dev Performs comprehensive validation including:
   *      - Slot timing (must be after the last checkpoint's slot)
   *      - Archive consistency (must build on current chain tip)
   *      - Proposer authorization (must be the designated proposer for the slot)
   * @param _ts The timestamp of the proposed checkpoint
   * @param _archive The archive root the checkpoint claims to build on
   * @param _who The address attempting to propose the checkpoint
   * @return slot The slot number derived from the timestamp
   * @return checkpointNumber The next checkpoint number that will be assigned
   * @custom:reverts Errors.Rollup__SlotAlreadyInChain if trying to propose for a past slot
   * @custom:reverts Errors.Rollup__InvalidArchive if archive doesn't match current chain tip
   * @custom:reverts Errors.ValidatorSelection__InvalidProposer if _who is not the designated proposer
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function canProposeAtTime(Timestamp _ts, bytes32 _archive, address _who) internal returns (Slot, uint256) {
    Slot slot = _ts.slotFromTimestamp();
    RollupStore storage rollupStore = STFLib.getStorage();

    // Pending chain tip
    uint256 pendingCheckpointNumber = STFLib.getEffectivePendingCheckpointNumber(_ts);

    Slot lastSlot = STFLib.getSlotNumber(pendingCheckpointNumber);

    require(slot > lastSlot, Errors.Rollup__SlotAlreadyInChain(lastSlot, slot));

    // Make sure that the proposer is up to date and on the right chain (ie no reorgs)
    bytes32 tipArchive = rollupStore.archives[pendingCheckpointNumber];
    require(tipArchive == _archive, Errors.Rollup__InvalidArchive(tipArchive, _archive));

    (address proposer,) = getProposerAt(slot);
    require(proposer == _who, Errors.ValidatorSelection__InvalidProposer(proposer, _who));

    return (slot, pendingCheckpointNumber + 1);
  }

  /**
   * @notice Retrieves cached proposer information from transient storage
   * @dev Reads packed proposer data (address + index) from EIP-1153 transient storage.
   *      Returns zero values if no proposer is cached for the slot.
   * @param _slot The slot to check for cached proposer
   * @return proposer The cached proposer address (address(0) if not cached)
   * @return proposerIndex The cached proposer index (0 if not cached)
   */
  function getCachedProposer(Slot _slot) internal view returns (address proposer, uint256 proposerIndex) {
    bytes32 packed = PROPOSER_NAMESPACE.erc7201Slot().deriveMapping(Slot.unwrap(_slot)).asBytes32().tload();
    // Extract address from lower 160 bits
    proposer = address(uint160(uint256(packed)));
    // Extract uint96 from upper 96 bits
    proposerIndex = uint256(packed >> 160);
  }

  /**
   * @notice Gets the cryptographic sample seed for a stable epoch
   * @dev Retrieves the randao from the checkpointed randaos mapping using upperLookup.
   *      Then computes the sample seed using keccak256(epoch, randao)
   * @param _epoch The epoch to get the sample seed for
   * @return The sample seed used for validator selection randomness
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function getSampleSeed(Epoch _epoch) internal view returns (uint256) {
    ValidatorSelectionStorage storage store = getStorage();
    uint32 ts = stableEpochToRandaoSampleTime(_epoch);
    return uint256(keccak256(abi.encode(_epoch, store.randaos.upperLookup(ts))));
  }

  /**
   * @notice Gets the sampling size (attester count) for a stable epoch
   * @dev Retrieves the number of attesters at the sampling time for the epoch.
   * @param _epoch The epoch to get the sampling size for
   * @return The number of attesters available at the epoch's sampling time
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function getSamplingSize(Epoch _epoch) internal view returns (uint256) {
    uint32 ts = stableEpochToValidatorSetSampleTime(_epoch);
    return StakingLib.getAttesterCountAtTime(Timestamp.wrap(ts));
  }

  function getLagInEpochsForValidatorSet() internal view returns (uint256) {
    return getStorage().lagInEpochsForValidatorSet;
  }

  function getLagInEpochsForRandao() internal view returns (uint256) {
    return getStorage().lagInEpochsForRandao;
  }

  /**
   * @notice Gets the current escape hatch contract (latest checkpoint)
   * @dev Returns the most recently configured escape hatch, or a zero-address IEscapeHatch if none set
   * @return The escape hatch contract interface
   */
  function getEscapeHatch() internal view returns (IEscapeHatch) {
    return IEscapeHatch(address(getStorage().escapeHatchCheckpoints.latest()));
  }

  /**
   * @notice Gets the escape hatch contract that was active at the start of a given epoch
   * @dev Uses `upperLookupRecent` to find the most recent checkpoint with key <= epoch start timestamp.
   *      Changes pushed with `block.timestamp` during epoch N take effect for epoch N+1 (since epoch
   *      N+1's start timestamp > the push timestamp > epoch N's start timestamp), providing implicit
   *      epoch-boundary activation.
   * @param _epoch The epoch to look up the escape hatch for
   * @return The escape hatch contract interface that was active at the start of the epoch
   */
  function getEscapeHatchForEpoch(Epoch _epoch) internal view returns (IEscapeHatch) {
    uint96 ts = uint96(Timestamp.unwrap(TimeLib.toTimestamp(_epoch)));
    return IEscapeHatch(address(getStorage().escapeHatchCheckpoints.upperLookupRecent(ts)));
  }

  /**
   * @notice Gets the validator selection storage struct using EIP-7201 namespaced storage
   * @dev Uses assembly to access storage at the predetermined slot to avoid collisions.
   * @return storageStruct The validator selection storage struct
   */
  function getStorage() internal pure returns (ValidatorSelectionStorage storage storageStruct) {
    bytes32 position = VALIDATOR_SELECTION_STORAGE_POSITION;
    assembly {
      storageStruct.slot := position
    }
  }

  /**
   * @notice Computes the committee index of the proposer for a specific slot
   * @dev Uses keccak256 hash of epoch, slot, and seed to deterministically select a committee member.
   *      The result is modulo committee size to ensure valid index.
   *      The result being modulo biased is not a problem here as the validators in the committee were chosen randomly
   *      and are not ordered.
   * @param _epoch The epoch containing the slot
   * @param _slot The specific slot to compute proposer for
   * @param _seed The epoch's sample seed for randomness
   * @param _size The size of the committee
   * @return The index (0 to _size-1) of the committee member who should propose for this slot
   */
  function computeProposerIndex(Epoch _epoch, Slot _slot, uint256 _seed, uint256 _size)
    internal
    pure
    returns (uint256)
  {
    return uint256(keccak256(abi.encode(_epoch, _slot, _seed))) % _size;
  }

  /**
   * @notice Samples validator indices for a specific epoch using cryptographic randomness
   * @dev Determines sample timestamp, gets validator set size, and uses SampleLib to select committee indices.
   *      Validates that enough validators are available to meet target committee size.
   * @param _epoch The epoch to sample validators for
   * @param _seed The cryptographic seed for sampling randomness
   * @return sampleTime The timestamp used for validator set sampling
   * @return indices Array of validator indices selected for the committee
   * @custom:reverts Errors.ValidatorSelection__InsufficientValidatorSetSize if not enough validators available
   */
  function sampleValidatorsIndices(Epoch _epoch, uint256 _seed) private returns (uint32, uint256[] memory) {
    ValidatorSelectionStorage storage store = getStorage();
    uint32 ts = stableEpochToValidatorSetSampleTime(_epoch);
    uint256 validatorSetSize = StakingLib.getAttesterCountAtTime(Timestamp.wrap(ts));
    uint256 targetCommitteeSize = store.targetCommitteeSize;

    require(
      validatorSetSize >= targetCommitteeSize,
      Errors.ValidatorSelection__InsufficientValidatorSetSize(validatorSetSize, targetCommitteeSize)
    );

    if (targetCommitteeSize == 0) {
      return (ts, new uint256[](0));
    }

    return (ts, SampleLib.computeCommittee(targetCommitteeSize, validatorSetSize, _seed));
  }

  /**
   * @notice Converts a stable epoch number to the timestamp used for validator set sampling
   * @dev Calculates the sampling timestamp by:
   *      1. Taking the epoch start timestamp
   *      2. Subtracting `lagInEpochsForRandao` full epoch duration to ensure stability
   *
   *      This ensures validator set sampling uses stable historical data that won't be
   *      affected by last-minute changes or L1 reorgs during synchronization.
   *
   *      We consider an epoch to be stable when its committee cannot change.
   * @param _epoch The epoch to calculate sampling time for
   * @return The Unix timestamp (uint32) to use for validator set sampling
   * @custom:reverts Errors.ValidatorSelection__EpochNotStable if the requested epoch is not stable
   */
  function stableEpochToRandaoSampleTime(Epoch _epoch) private view returns (uint32) {
    uint32 sub = getStorage().lagInEpochsForRandao * TimeLib.getEpochDurationInSeconds().toUint32();
    uint32 ts = Timestamp.unwrap(_epoch.toTimestamp()).toUint32() - sub;
    require(
      ts <= block.timestamp,
      Errors.ValidatorSelection__EpochNotStable(uint256(Epoch.unwrap(_epoch)), uint32(block.timestamp))
    );
    return ts;
  }

  function stableEpochToValidatorSetSampleTime(Epoch _epoch) private view returns (uint32) {
    uint32 sub = getStorage().lagInEpochsForValidatorSet * TimeLib.getEpochDurationInSeconds().toUint32();
    uint32 ts = Timestamp.unwrap(_epoch.toTimestamp()).toUint32() - sub;
    require(
      ts <= block.timestamp,
      Errors.ValidatorSelection__EpochNotStable(uint256(Epoch.unwrap(_epoch)), uint32(block.timestamp))
    );
    return ts;
  }

  /**
   * @notice Computes the keccak256 commitment hash for a committee member array
   * @dev Creates a cryptographic commitment to the committee composition that can be verified later.
   *      Used to prevent committee substitution attacks during attestation verification.
   * @param _committee The array of committee member addresses
   * @return The keccak256 hash of the ABI-encoded committee array
   */
  function computeCommitteeCommitment(address[] memory _committee) private pure returns (bytes32) {
    return keccak256(abi.encode(_committee));
  }
}

/**
 * @title InvalidateLib
 * @author Aztec Labs
 * @notice Library responsible for handling the invalidation of checkpoints with incorrect attestations in the Aztec
 * rollup.
 *
 * @dev This library implements the invalidation mechanism that allows anyone to remove invalid checkpoints from the
 *      pending chain. An invalid checkpoint is one without proper attestations.
 *
 *      The invalidation system addresses two main types of attestation failures:
 *      1. Bad attestation signatures: When committee members provide invalid signatures
 *      2. Insufficient attestations: When a checkpoint doesn't meet the required >2/3 committee threshold
 *
 *      Key invariants:
 *      - Only pending (unproven) checkpoints can be invalidated
 *      - Checkpoint must exist in the pending chain (between proven tip and pending tip)
 *      - Invalid checkpoints and all subsequent checkpoints are removed from the pending chain
 *
 *      Security model:
 *      - Anyone can call invalidation functions (permissionless)
 *      - No economic incentive (rebate) is provided for calling these functions
 *      - Expected to be called by next proposer, then committee members, then any validator as fallback
 *      - Invalidation reverts the pending chain tip to the checkpoint immediately before the invalid one
 *
 *      Integration with the rollup system:
 *      - Works with STFLib for storage access and chain state management
 *      - Uses ValidatorSelectionLib to verify committee commitments
 *      - Validates against TempCheckpointLog storage for checkpoint metadata
 *      - Emits CheckpointInvalidated events via IRollupCore interface
 *
 *      This invalidation mechanism ensures that even though attestations are not fully validated onchain
 *      during checkpoint proposal (to save gas), invalid attestations can be challenged and removed after the fact,
 *      maintaining the security of the rollup while optimizing for efficient checkpoint production.
 *
 *      Note that attestations are validated during the proof submission, but not at every propose call.
 */
library InvalidateLib {
  using TimeLib for Timestamp;
  using TimeLib for Slot;
  using TimeLib for Epoch;
  using ChainTipsLib for CompressedChainTips;
  using AttestationLib for CommitteeAttestations;
  using CompressedTimeMath for CompressedSlot;

  /**
   * @notice Invalidates a checkpoint containing an invalid attestation
   * @dev Anyone can call this function to remove checkpoints with invalid attestations.
   *
   *      There are two cases where an individual attestation might be invalid:
   *      1. The attestation is a signature that does not recover to the address from the committee
   *      2. The attestation is an address, that does not match the address from the committee
   *
   *      Upon successful validation of the invalid attestation, the checkpoint and all subsequent pending
   *      checkpoints are removed from the chain by resetting the pending tip to the previous valid checkpoint.
   *
   *      No economic rebate is provided for calling this function.
   *
   * @param _checkpointNumber The checkpoint number to invalidate (must be in pending chain)
   * @param _attestations The attestations that were submitted with the checkpoint (must match stored hash)
   * @param _committee The committee members for the checkpoint's epoch (must match stored computed commitment)
   * @param _invalidIndex The index in the committee/attestations array of the invalid attestation
   *
   * @custom:reverts Errors.Rollup__CheckpointNotInPendingChain If checkpoint number is beyond pending tip
   * @custom:reverts Errors.Rollup__CheckpointAlreadyProven If checkpoint number is already proven
   * @custom:reverts Errors.Rollup__InvalidAttestations If provided attestations don't match stored hash
   * @custom:reverts Errors.ValidatorSelection__InvalidCommitteeCommitment If committee doesn't match stored commitment
   * @custom:reverts Rollup__InvalidAttestationIndex if the _invalidIndex is beyond the committee
   * @custom:reverts Errors.Rollup__AttestationsAreValid If the attestation at invalidIndex is actually valid
   */
  function invalidateBadAttestation(
    uint256 _checkpointNumber,
    CommitteeAttestations memory _attestations,
    address[] memory _committee,
    uint256 _invalidIndex
  ) internal {
    (bytes32 digest, uint256 committeeSize) = _validateInvalidationInputs(_checkpointNumber, _attestations, _committee);
    require(_invalidIndex < committeeSize, Errors.Rollup__InvalidAttestationIndex());

    address recovered;

    // Verify that the attestation at invalidIndex does not match the the expected attestation
    // i.e., either recover the address directly from the attestations if no signature
    // or recover the address from the signature if there is a signature.
    // Then take the recovered address and check it against the committee
    if (!_attestations.isSignature(_invalidIndex)) {
      recovered = _attestations.getAddress(_invalidIndex);
    } else {
      Signature memory signature = _attestations.getSignature(_invalidIndex);
      // We use `tryRecover` instead of `recover` since we want improper signatures to return `address(0)` rather than
      // revert. Since `address(0)` is not allowed as an attester, this will cause the recovered address to not match
      // the committee data.
      (recovered,,) = ECDSA.tryRecover(digest, signature.v, signature.r, signature.s);
    }

    require(recovered != _committee[_invalidIndex], Errors.Rollup__AttestationsAreValid());

    _invalidateCheckpoint(_checkpointNumber);
  }

  /**
   * @notice Invalidates a checkpoint that doesn't meet the required >2/3 committee attestation threshold
   * @dev Anyone can call this function to remove checkpoints with insufficient valid attestations.
   *
   *      The function counts the number of signature attestations (as opposed to address attestations) and
   *      compares against the required threshold of (committeeSize * 2 / 3) + 1. If insufficient signatures
   *      are present, the checkpoint and all subsequent pending checkpoints are removed from the chain.
   *
   *      No economic rebate is provided for calling this function.
   *
   * @param _checkpointNumber The checkpoint number to invalidate (must be in pending chain)
   * @param _attestations The attestations that were submitted with the checkpoint (must match stored hash)
   * @param _committee The committee members for the checkpoint's epoch (must match stored commitment)
   *
   * @custom:reverts Errors.Rollup__CheckpointNotInPendingChain If checkpoint number is beyond pending tip
   * @custom:reverts Errors.Rollup__CheckpointAlreadyProven If checkpoint number is already proven
   * @custom:reverts Errors.Rollup__InvalidAttestations If provided attestations don't match stored hash
   * @custom:reverts Errors.ValidatorSelection__InvalidCommitteeCommitment If committee doesn't match stored commitment
   * @custom:reverts Errors.ValidatorSelection__InsufficientAttestations If the attestations actually meet the threshold
   */
  function invalidateInsufficientAttestations(
    uint256 _checkpointNumber,
    CommitteeAttestations memory _attestations,
    address[] memory _committee
  ) internal {
    (, uint256 committeeSize) = _validateInvalidationInputs(_checkpointNumber, _attestations, _committee);

    uint256 signatureCount = 0;
    for (uint256 i = 0; i < committeeSize; ++i) {
      if (_attestations.isSignature(i)) {
        signatureCount++;
      }
    }

    // Calculate required threshold (2/3 + 1)
    uint256 requiredSignatures = (committeeSize << 1) / 3 + 1; // committeeSize * 2 / 3 + 1

    // Ensure the number of valid signatures is actually insufficient
    require(
      signatureCount < requiredSignatures,
      Errors.ValidatorSelection__InsufficientAttestations(requiredSignatures, signatureCount)
    );

    _invalidateCheckpoint(_checkpointNumber);
  }

  /**
   * @notice Common validation logic shared by all invalidation functions
   * @dev Performs validation checks to ensure invalidation calls are legitimate and target valid checkpoints.
   *      This function establishes the foundation for all invalidation operations by verifying:
   *
   *      1. Checkpoint existence and state: The target checkpoint must be in the pending chain (after the proven tip
   *         but not beyond the pending tip). Proven checkpoints cannot be invalidated as they are final.
   *
   *      2. Attestation integrity: The provided attestations must exactly match the hash stored when the
   *         checkpoint was originally proposed. This prevents manipulation of attestation data.
   *
   *      3. Committee authenticity: The provided committee addresses must match the commitment stored for
   *         the checkpoint's epoch. This ensures invalidation is based on the actual committee that should have
   *         attested to the checkpoint.
   *
   *      4. Signature context: Computes the digest that committee members were expected to sign, enabling
   *         proper signature verification in calling functions.
   *
   * @param _checkpointNumber The checkpoint number being validated for invalidation
   * @param _attestations The attestations provided for validation
   * @param _committee The committee members for the checkpoint's epoch
   * @return digest The payload digest that committee members signed
   * @return committeeSize The number of committee members for the epoch
   *
   * @custom:reverts Errors.Rollup__CheckpointNotInPendingChain If checkpoint is beyond the current pending tip
   * @custom:reverts Errors.Rollup__CheckpointAlreadyProven If checkpoint has already been proven and is final
   * @custom:reverts Errors.Rollup__InvalidAttestations If attestations hash doesn't match stored value
   * @custom:reverts Errors.ValidatorSelection__InvalidCommitteeCommitment If committee hash doesn't match stored
   * commitment
   */
  function _validateInvalidationInputs(
    uint256 _checkpointNumber,
    CommitteeAttestations memory _attestations,
    address[] memory _committee
  ) private returns (bytes32, uint256) {
    RollupStore storage rollupStore = STFLib.getStorage();

    // Checkpoint must be in the pending chain
    require(_checkpointNumber <= rollupStore.tips.getPending(), Errors.Rollup__CheckpointNotInPendingChain());

    // But not yet proven
    require(_checkpointNumber > rollupStore.tips.getProven(), Errors.Rollup__CheckpointAlreadyProven());

    // Get the stored checkpoint data
    CompressedTempCheckpointLog storage checkpointLog = STFLib.getStorageTempCheckpointLog(_checkpointNumber);

    // Verify that the provided attestations match the stored hash
    bytes32 providedAttestationsHash = keccak256(abi.encode(_attestations));
    require(providedAttestationsHash == checkpointLog.attestationsHash, Errors.Rollup__InvalidAttestations());

    // Get the epoch for the checkpoint's slot to verify committee
    Epoch epoch = checkpointLog.slotNumber.decompress().epochFromSlot();

    // Check if this is an escape hatch epoch - escape hatch checkpoints cannot be invalidated
    // since they have no committee attestations by design.
    // Uses epoch-stable lookup so invalidation rules use the escape hatch that was
    // active when the epoch started, not whatever is currently configured.
    {
      IEscapeHatch escapeHatch = ValidatorSelectionLib.getEscapeHatchForEpoch(epoch);
      if (address(escapeHatch) != address(0)) {
        (bool isOpen,) = escapeHatch.isHatchOpen(epoch);
        require(!isOpen, Errors.Rollup__CannotInvalidateEscapeHatch());
      }
    }

    // Get and verify the committee commitment
    (bytes32 committeeCommitment, uint256 committeeSize) = ValidatorSelectionLib.getCommitteeCommitmentAt(epoch);
    bytes32 providedCommitteeCommitment = keccak256(abi.encode(_committee));
    require(
      committeeCommitment == providedCommitteeCommitment,
      Errors.ValidatorSelection__InvalidCommitteeCommitment(providedCommitteeCommitment, committeeCommitment)
    );

    // Get the digest of the payload that was signed by the committee
    bytes32 digest = checkpointLog.payloadDigest;

    return (digest, committeeSize);
  }

  /**
   * @notice Helper that invalidates a checkpoint by rolling back the pending chain to the previous valid checkpoint
   * @dev This function implements the core invalidation logic by updating the chain tips to remove
   *      the invalid checkpoint and all subsequent checkpoints from the pending chain. The rollback is atomic
   *      and immediately takes effect, preventing any further operations on the invalidated checkpoints.
   *
   *      The invalidation works by:
   *      1. Setting the pending checkpoint number to (_checkpointNumber - 1)
   *      2. Emitting a CheckpointInvalidated event for external observers
   *
   *      This approach ensures that when the next valid checkpoint is proposed, it will build on the
   *      last remaining valid checkpoint, effectively removing the invalid checkpoint and any checkpoints that
   *      were built on top of it.
   *
   *      Note: This function does not clean up the storage for invalidated checkpoints (archive roots,
   *      temp checkpoint logs, etc.) as they may be overwritten by future valid checkpoints at the same numbers.
   *
   * @param _checkpointNumber The checkpoint number to invalidate
   */
  function _invalidateCheckpoint(uint256 _checkpointNumber) private {
    RollupStore storage rollupStore = STFLib.getStorage();
    rollupStore.tips = rollupStore.tips.updatePending(_checkpointNumber - 1);
    emit IRollupCore.CheckpointInvalidated(_checkpointNumber);
  }
}

/**
 * @title ValidatorOperationsExtLib - External Rollup Library (Validator and Staking Functions)
 * @author Aztec Labs
 * @notice External library containing staking-related functions for the Rollup contract to avoid exceeding max contract
 * size.
 *
 * @dev This library serves as an external library for the Rollup contract, splitting off staking-related
 *      functionality to keep the main contract within the maximum contract size limit. The library contains
 *      external functions primarily focused on:
 *      - Validator staking operations (deposit, withdraw, queue management)
 *      - Validator selection and committee setup
 *      - Checkpoint attestation invalidation
 *      - Slashing mechanism integration
 *      - Epoch and proposer management
 */
library ValidatorOperationsExtLib {
  using TimeLib for Timestamp;

  function queueSetSlasher(address _slasher) external {
    StakingLib.queueSetSlasher(_slasher);
  }

  function cancelSetSlasher() external {
    StakingLib.cancelSetSlasher();
  }

  function finalizeSetSlasher() external {
    StakingLib.finalizeSetSlasher();
  }

  function vote(uint256 _proposalId) external {
    StakingLib.vote(_proposalId);
  }

  function deposit(
    address _attester,
    address _withdrawer,
    G1Point memory _publicKeyInG1,
    G2Point memory _publicKeyInG2,
    G1Point memory _proofOfPossession,
    bool _moveWithLatestRollup
  ) external {
    StakingLib.deposit(
      _attester, _withdrawer, _publicKeyInG1, _publicKeyInG2, _proofOfPossession, _moveWithLatestRollup
    );
  }

  function flushEntryQueue(uint256 _toAdd) external {
    StakingLib.flushEntryQueue(_toAdd);
  }

  function initiateWithdraw(address _attester, address _recipient) external returns (bool) {
    return StakingLib.initiateWithdraw(_attester, _recipient);
  }

  function finalizeWithdraw(address _attester) external {
    StakingLib.finalizeWithdraw(_attester);
  }

  function initializeValidatorSelection(
    uint256 _targetCommitteeSize,
    uint256 _lagInEpochsForValidatorSet,
    uint256 _lagInEpochsForRandao
  ) external {
    ValidatorSelectionLib.initialize(_targetCommitteeSize, _lagInEpochsForValidatorSet, _lagInEpochsForRandao);
  }

  function setupEpoch() external {
    Epoch currentEpoch = Timestamp.wrap(block.timestamp).epochFromTimestamp();
    ValidatorSelectionLib.setupEpoch(currentEpoch);
  }

  function checkpointRandao() external {
    Epoch currentEpoch = Timestamp.wrap(block.timestamp).epochFromTimestamp();
    ValidatorSelectionLib.checkpointRandao(currentEpoch);
  }

  function updateStakingQueueConfig(StakingQueueConfig memory _config) external {
    StakingLib.updateStakingQueueConfig(_config);
  }

  function setEscapeHatch(address _escapeHatch) external {
    ValidatorSelectionLib.setEscapeHatch(_escapeHatch);
  }

  function invalidateBadAttestation(
    uint256 _checkpointNumber,
    CommitteeAttestations memory _attestations,
    address[] memory _committee,
    uint256 _invalidIndex
  ) external {
    InvalidateLib.invalidateBadAttestation(_checkpointNumber, _attestations, _committee, _invalidIndex);
  }

  function invalidateInsufficientAttestations(
    uint256 _checkpointNumber,
    CommitteeAttestations memory _attestations,
    address[] memory _committee
  ) external {
    InvalidateLib.invalidateInsufficientAttestations(_checkpointNumber, _attestations, _committee);
  }

  function slash(address _attester, uint256 _amount) external returns (bool) {
    return StakingLib.trySlash(_attester, _amount);
  }

  function canProposeAtTime(Timestamp _ts, bytes32 _archive, address _who) external returns (Slot, uint256) {
    return ValidatorSelectionLib.canProposeAtTime(_ts, _archive, _who);
  }

  function getCommitteeAt(Epoch _epoch) external returns (address[] memory) {
    return ValidatorSelectionLib.getCommitteeAt(_epoch);
  }

  function getProposerAt(Slot _slot) external returns (address proposer) {
    (proposer,) = ValidatorSelectionLib.getProposerAt(_slot);
  }

  function getCommitteeCommitmentAt(Epoch _epoch) external returns (bytes32, uint256) {
    return ValidatorSelectionLib.getCommitteeCommitmentAt(_epoch);
  }

  function getSampleSeedAt(Epoch _epoch) external view returns (uint256) {
    return ValidatorSelectionLib.getSampleSeed(_epoch);
  }

  function getSamplingSizeAt(Epoch _epoch) external view returns (uint256) {
    return ValidatorSelectionLib.getSamplingSize(_epoch);
  }

  function getLagInEpochsForValidatorSet() external view returns (uint256) {
    return ValidatorSelectionLib.getLagInEpochsForValidatorSet();
  }

  function getLagInEpochsForRandao() external view returns (uint256) {
    return ValidatorSelectionLib.getLagInEpochsForRandao();
  }

  function getEscapeHatch() external view returns (IEscapeHatch) {
    return ValidatorSelectionLib.getEscapeHatch();
  }

  function getEscapeHatchForEpoch(Epoch _epoch) external view returns (IEscapeHatch) {
    return ValidatorSelectionLib.getEscapeHatchForEpoch(_epoch);
  }

  function getTargetCommitteeSize() external view returns (uint256) {
    return ValidatorSelectionLib.getStorage().targetCommitteeSize;
  }

  function getEntryQueueFlushSize() external view returns (uint256) {
    uint256 activeAttesterCount = StakingLib.getAttesterCountAtTime(Timestamp.wrap(block.timestamp));
    return StakingLib.getEntryQueueFlushSize(activeAttesterCount);
  }

  function getAvailableValidatorFlushes() external view returns (uint256) {
    return StakingLib.getAvailableValidatorFlushes();
  }

  // View wrappers - delegated from Rollup.sol to avoid inlining StakingLib into Rollup bytecode

  function getAttesterView(address _attester) external view returns (AttesterView memory) {
    return StakingLib.getAttesterView(_attester);
  }

  function getStatus(address _attester) external view returns (Status_1) {
    return StakingLib.getStatus(_attester);
  }

  function getConfig(address _attester) external view returns (AttesterConfig memory) {
    return StakingLib.getConfig(_attester);
  }

  function getExit(address _attester) external view returns (Exit memory) {
    return StakingLib.getExit(_attester);
  }

  function getAttesterAtIndex(uint256 _index) external view returns (address) {
    return StakingLib.getAttesterAtIndex(_index);
  }

  function getEntryQueueAt(uint256 _index) external view returns (DepositArgs memory) {
    return StakingLib.getEntryQueueAt(_index);
  }

  function getNextFlushableEpoch() external view returns (Epoch) {
    return StakingLib.getNextFlushableEpoch();
  }

  function getEntryQueueLength() external view returns (uint256) {
    return StakingLib.getEntryQueueLength();
  }
}