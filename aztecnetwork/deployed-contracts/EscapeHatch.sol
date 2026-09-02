// SPDX-License-Identifier: Unknown
pragma solidity 0.8.30;

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

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, provided the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 *
 * BitMaps pack 256 booleans across each bit of a single 256-bit slot of `uint256` type.
 * Hence booleans corresponding to 256 _sequential_ indices would only consume a single slot,
 * unlike the regular `bool` which would consume an entire slot for a single value.
 *
 * This results in gas savings in two ways:
 *
 * - Setting a zero value to non-zero only once every 256 times
 * - Accessing the same warm slot for every 256 _sequential_ indices
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 bucket => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(BitMap storage bitmap, uint256 index, bool value) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
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

// Struct to store configuration of an attester (checkpoint producer)
// Keep track of the actor who can initiate and control withdraws for the attester.
// Keep track of the public key in G1 of BN254 that has registered on the instance
struct AttesterConfig {
  G1Point publicKey;
  address withdrawer;
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

struct Ballot {
  uint256 yea;
  uint256 nay;
}

struct Proposal {
  ProposalConfiguration config;
  ProposalState cachedState;
  IPayload payload;
  address proposer;
  Timestamp creation;
  Ballot summedBallot;
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

/**
 * @title Errors Library
 * @author Aztec Labs
 * @notice Library that contains errors used throughout the Aztec governance
 * Errors are prefixed with the contract name to make it easy to identify where the error originated
 * when there are multiple contracts that could have thrown the error.
 */
library Errors {
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
    require(current >= amount, Errors.Governance__CheckpointedUintLib__InsufficientValue(msg.sender, current, amount));
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
    require(_time < Timestamp.wrap(block.timestamp), Errors.Governance__CheckpointedUintLib__NotInPast());
    return _self.upperLookupRecent(Timestamp.unwrap(_time).toUint32());
  }
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface Governance is IGovernance {
    function deposit(address _beneficiary, uint256 _amount) external override(IGovernance);
    function initiateWithdraw(address _to, uint256 _amount) external override(IGovernance) returns (uint256);
    function finalizeWithdraw(uint256 _withdrawalId) external override(IGovernance);
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
      powerAt >= powerUsed + _amount, Errors.Delegation__InsufficientPower(_delegatee, powerAt, powerUsed + _amount)
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
    require(isRollupRegistered(msg.sender), Errors.GSE__NotRollup(msg.sender));
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
    require(address(governance) == address(0), Errors.GSE__GovernanceAlreadySet());
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
    require(_rollup != address(0), Errors.GSE__InvalidRollupAddress(_rollup));
    require(!instances[_rollup].exists, Errors.GSE__RollupAlreadyRegistered(_rollup));
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
      require(isMsgSenderLatestRollup, Errors.GSE__NotLatestRollup(msg.sender));
    }

    // Ensure that we are not already attesting on the rollup
    require(!isRegistered(msg.sender, _attester), Errors.GSE__AlreadyRegistered(msg.sender, _attester));

    // Ensure that if we are the latest rollup, we are not already attesting on the bonus instance.
    if (isMsgSenderLatestRollup) {
      require(
        !isRegistered(BONUS_INSTANCE_ADDRESS, _attester),
        Errors.GSE__AlreadyRegistered(BONUS_INSTANCE_ADDRESS, _attester)
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
      instances[recipientInstance].attesters.add(_attester), Errors.GSE__AlreadyRegistered(recipientInstance, _attester)
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

    require(foundAttester, Errors.GSE__NothingToExit(_attester));

    uint256 balance = delegation.getBalanceOf(withdrawingInstance, _attester);
    require(balance >= _amount, Errors.GSE__InsufficientBalance(balance, _amount));

    // First assume we are only withdrawing the amount specified.
    uint256 amountWithdrawn = _amount;
    // If the balance after withdrawal is less than the ejection threshold,
    // we will remove the attester from the instance.
    bool isRemoved = balance - _amount < EJECTION_THRESHOLD;

    // Note that the current implementation of the rollup does not allow for partial withdrawals,
    // via `initiateWithdraw`, so a "normal" withdrawal will always remove the attester from the instance.
    // However, if the attester is slashed, we might just reduce the balance.
    if (isRemoved) {
      require(attesterRegistry.attesters.remove(_attester), Errors.GSE__FailedToRemove(_attester));
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
    require(isRollupRegistered(_instance), Errors.GSE__InstanceDoesNotExist(_instance));
    address withdrawer = configOf[_attester].withdrawer;
    require(msg.sender == withdrawer, Errors.GSE__NotWithdrawer(withdrawer, msg.sender));
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
    require(msg.sender == getLatestRollupAt(ts), Errors.GSE__NotLatestRollup(msg.sender));
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
      Errors.GSE__CannotChangePublicKeys(previouslyRegisteredPoint.x, previouslyRegisteredPoint.y)
    );

    // Make sure the incoming point has not been seen before
    // NOTE: we only need to check for the existence of Pk1, and not also for Pk2,
    // as the Pk2 will be constrained to have the same underlying secret key as part of the proofOfPossession,
    // so existence/correctness of Pk2 is implied by existence/correctness of Pk1.
    bytes32 hashedIncomingPoint = keccak256(abi.encodePacked(_publicKeyInG1.x, _publicKeyInG1.y));
    require((!ownedPKs[hashedIncomingPoint]), Errors.GSE__ProofOfPossessionAlreadySeen(hashedIncomingPoint));
    ownedPKs[hashedIncomingPoint] = true;

    // We validate the proof of possession using an external contract to limit gas potentially "sacrificed"
    // in case of failure.
    require(
      BN254_LIB_WRAPPER.proofOfPossession{
        gas: proofOfPossessionGasLimit
      }(_publicKeyInG1, _publicKeyInG2, _proofOfPossession),
      Errors.GSE__InvalidProofOfPossession()
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
      require(index < totalSize, Errors.GSE__OutOfBounds(index, totalSize));

      // since we have ensured that the index is not out of bounds, we can use the unsafe function in
      // `AddressSnapshotLib` to fetch if. We use the `recent` variant as we expect the attesters to
      // mainly be from recent history when fetched during tx execution.

      if (index < storeSize) {
        attesters[i] = instanceStore.attesters.unsafeGetRecentAddressFromIndexAtTimestamp(index, ts);
      } else if (isLatestRollup) {
        attesters[i] = bonusStore.attesters.unsafeGetRecentAddressFromIndexAtTimestamp(index - storeSize, ts);
      } else {
        revert Errors.GSE__FatalError("SHOULD NEVER HAPPEN");
      }
    }

    return attesters;
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

interface IStaking is IStakingCore {
  function getConfig(address _attester) external view returns (AttesterConfig memory);
  function getExit(address _attester) external view returns (Exit memory);
  function getAttesterAtIndex(uint256 _index) external view returns (address);
  function getSlasher() external view returns (address);
  function getPendingSlasher() external view returns (address slasher, Timestamp readyAt);
  function getLegacySlasher() external view returns (address slasher, Timestamp authorizedUntil);
  function getLocalEjectionThreshold() external view returns (uint256);
  function getSlasherExecutionDelay() external view returns (uint256);
  function getLegacySlasherDrainWindow() external view returns (uint256);
  function getStakingAsset() external view returns (IERC20);
  function getActivationThreshold() external view returns (uint256);
  function getEjectionThreshold() external view returns (uint256);
  function getExitDelay() external view returns (Timestamp);
  function getGSE() external view returns (GSE);
  function getAttesterView(address _attester) external view returns (AttesterView memory);
  function getStatus(address _attester) external view returns (Status_1);
  function getNextFlushableEpoch() external view returns (Epoch);
  function getEntryQueueLength() external view returns (uint256);
  function getEntryQueueAt(uint256 _index) external view returns (DepositArgs memory);
  function getAvailableValidatorFlushes() external view returns (uint256);
  function getIsBootstrapped() external view returns (bool);
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

struct CommitteeAttestations {
  // bitmap of which indices are signatures
  bytes signatureIndices;
  // tightly packed signatures and addresses
  bytes signaturesOrAddresses;
}

// Signature
struct Signature {
  uint8 v;
  bytes32 r;
  bytes32 s;
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

interface IHaveVersion {
  function getVersion() external view returns (uint256);
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

interface IInstance is IStaking, IValidatorSelection, IRollup {}

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
 * @title EscapeHatch
 * @author Aztec Labs
 *
 * @notice The escape hatch provides censorship resistance by allowing a designated proposer
 *         to bypass the committee and propose blocks during periodic "escape hatch" windows.
 *
 * @dev The escape hatch opens for ACTIVE_DURATION epochs every FREQUENCY epochs. A candidate is
 *      randomly selected from a bonded candidate set using snapshotted data to prevent bias.
 *
 *      Key security properties:
 *      - Candidates must post a significant bond (BOND_SIZE)
 *      - Candidates are punished if they fail to propose or prove (FAILED_HATCH_PUNISHMENT)
 *      - All exits incur a tax (WITHDRAWAL_TAX)
 *      - Candidate set is snapshotted before RANDAO to prevent manipulation
 *      - Candidate does NOT receive access to governance
 */
contract EscapeHatch is IEscapeHatch {
  using AddressSnapshotLib for SnapshottedAddressSet;
  using SafeERC20 for IERC20;
  using BitMaps for BitMaps.BitMap;
  using SafeCast for uint256;
  using SafeCast for uint128;

  // ============ Constants ============

  /// @notice Number of epochs to look back from the START of the hatch for stable candidate set
  uint256 public constant LAG_IN_EPOCHS_FOR_SET_SIZE = 2;

  /// @notice Number of epochs to look back from the START of the hatch for stable RANDAO
  uint256 public constant LAG_IN_EPOCHS_FOR_RANDAO = 1;

  // ============ Immutables ============

  // The rollup contract that the escape hatch belongs to
  IInstance internal immutable ROLLUP;

  // The lag defines how far in advance we pick the
  uint256 internal immutable LAG_IN_HATCHES;

  // The token used for candidate bonds
  IERC20 internal immutable BOND_TOKEN;

  // The required bond size for candidates
  uint96 internal immutable BOND_SIZE;

  // The tax applied when a candidate exits
  uint96 internal immutable WITHDRAWAL_TAX;

  // The punishment applied when a candidate fails to prove their proof submission
  uint96 internal immutable FAILED_HATCH_PUNISHMENT;

  // The frequency of escape hatches in epochs
  uint256 internal immutable FREQUENCY;

  // The duration of an escape hatch in epochs
  uint256 internal immutable ACTIVE_DURATION;

  // The additional exit delay after proposing in seconds
  uint256 internal immutable PROPOSING_EXIT_DELAY;

  // ============ Storage ============

  BitMaps.BitMap internal $isHatchPrepared;
  BitMaps.BitMap internal $isHatchValidated;
  SnapshottedAddressSet internal $activeCandidates;
  mapping(address candidate => CandidateInfo data) internal $candidateDatas;
  mapping(Hatch hatch => address proposer) internal $designatedProposer;

  constructor(
    address _rollup,
    address _bondToken,
    uint96 _bondSize,
    uint96 _withdrawalTax,
    uint96 _failedHatchPunishment,
    uint256 _frequency,
    uint256 _activeDuration,
    uint256 _lagInHatches,
    uint256 _proposingExitDelay
  ) {
    // Validate configuration
    // LAG_IN_EPOCHS_FOR_SET_SIZE must be greater than LAG_IN_EPOCHS_FOR_RANDAO
    // to prevent bias from set manipulation
    require(LAG_IN_EPOCHS_FOR_SET_SIZE > LAG_IN_EPOCHS_FOR_RANDAO, Errors_1.EscapeHatch__InvalidConfiguration());

    require(_lagInHatches >= 1, Errors_1.EscapeHatch__InvalidConfiguration());

    // ACTIVE_DURATION must be at least proofSubmissionEpochs + 1 to ensure
    // the proposer cannot be "rugged" by malicious committee.
    uint256 proofSubmissionEpochs = IInstance(_rollup).getProofSubmissionEpochs();
    require(_activeDuration >= proofSubmissionEpochs + 1, Errors_1.EscapeHatch__InvalidConfiguration());

    // FREQUENCY must be > LAG_IN_EPOCHS_FOR_SET_SIZE to ensure valid selection window.
    // Selection must happen in window [hatchTime(H), setSnapshotTime(H+1)).
    // With too large a lag `setSnapshotTime(H+1) < hatchTime(H)`
    require(_frequency > LAG_IN_EPOCHS_FOR_SET_SIZE, Errors_1.EscapeHatch__InvalidConfiguration());

    require(_frequency > _activeDuration, Errors_1.EscapeHatch__InvalidConfiguration());

    // BOND_SIZE must be non-zero to ensure "something at stake"
    require(_bondSize > 0, Errors_1.EscapeHatch__InvalidConfiguration());

    // FAILED_HATCH_PUNISHMENT must be <= BOND_SIZE to avoid underflow
    require(_failedHatchPunishment <= _bondSize, Errors_1.EscapeHatch__InvalidConfiguration());

    // WITHDRAWAL_TAX must be <= BOND_SIZE to ensure valid refund calculation
    require(_withdrawalTax <= _bondSize, Errors_1.EscapeHatch__InvalidConfiguration());

    require(_proposingExitDelay <= 30 days, Errors_1.EscapeHatch__InvalidConfiguration());

    ROLLUP = IInstance(_rollup);
    BOND_TOKEN = IERC20(_bondToken);
    BOND_SIZE = _bondSize;
    WITHDRAWAL_TAX = _withdrawalTax;
    FAILED_HATCH_PUNISHMENT = _failedHatchPunishment;
    FREQUENCY = _frequency;
    ACTIVE_DURATION = _activeDuration;
    LAG_IN_HATCHES = _lagInHatches;
    PROPOSING_EXIT_DELAY = _proposingExitDelay;
  }

  /**
   * @notice Join the escape hatch candidate set by depositing the required bond
   *
   * @dev Transfers BOND_SIZE tokens from the caller
   *
   * @custom:reverts EscapeHatch__HatchTooEarly if called during early period when exit would revert
   * @custom:reverts EscapeHatch__AlreadyInCandidateSet if caller is already in the candidate set
   * @custom:reverts EscapeHatch__InvalidStatus if caller has a non-NONE status
   */
  function joinCandidateSet() external override(IEscapeHatchCore) {
    // Ensure exit path is viable (reverts with EscapeHatch__HatchTooEarly during early period)
    getSetTimestamp(getCurrentHatch() + Hatch.wrap(LAG_IN_HATCHES));

    address candidate = msg.sender;

    require(!$activeCandidates.contains(candidate), Errors_1.EscapeHatch__AlreadyInCandidateSet(candidate));

    CandidateInfo storage data = $candidateDatas[candidate];
    require(data.status == Status.NONE, Errors_1.EscapeHatch__InvalidStatus(Status.NONE, data.status));

    $activeCandidates.add(candidate);

    data.status = Status.ACTIVE;
    data.amount = BOND_SIZE;

    BOND_TOKEN.safeTransferFrom(candidate, address(this), BOND_SIZE);

    emit CandidateJoined(candidate);
  }

  /**
   * @notice Initiate exit from the candidate set
   *
   * @dev The exit may be immediate or delayed depending on timing relative to next hatch.
   *
   *      Calls selectCandidates() first, which may select the caller as the designated
   *      proposer for an upcoming hatch. If the caller is selected, their status transitions
   *      to PROPOSING and they are removed from $activeCandidates, causing the subsequent
   *      checks to revert. This is intentional - a designated proposer cannot exit and must
   *      instead follow the PROPOSING -> validateProofSubmission -> EXITING -> leaveCandidateSet
   *      flow.
   *
   * @custom:reverts EscapeHatch__NotInCandidateSet if caller is not in the candidate set
   *                 (including when caller was just selected as proposer by selectCandidates)
   * @custom:reverts EscapeHatch__InvalidStatus if caller's status is not ACTIVE
   */
  function initiateExit() external override(IEscapeHatchCore) {
    // Prepare the current hatch. If this selects the caller as designated proposer, their
    // status becomes PROPOSING and they are removed from $activeCandidates. The requires
    // below will then revert, preventing a designated proposer from exiting.
    selectCandidates();

    address candidate = msg.sender;
    require($activeCandidates.contains(candidate), Errors_1.EscapeHatch__NotInCandidateSet(candidate));

    CandidateInfo storage data = $candidateDatas[candidate];
    require(data.status == Status.ACTIVE, Errors_1.EscapeHatch__InvalidStatus(Status.ACTIVE, data.status));

    $activeCandidates.remove(candidate);
    data.status = Status.EXITING;

    // Calculate exit time based on whether we're before or after the next freeze
    // If before the freeze we are free to leave, otherwise we will be in the snapshot
    // and will need to wait until we know we have not been chosen, or have the selection
    // update the exitableAt time.
    Hatch nextTargetHatch = getCurrentHatch() + Hatch.wrap(1 + LAG_IN_HATCHES);
    uint32 nextFreezeTs = getSetTimestamp(nextTargetHatch);

    if (block.timestamp < nextFreezeTs) {
      data.exitableAt = block.timestamp.toUint32();
    } else {
      data.exitableAt = getSetTimestamp(nextTargetHatch + Hatch.wrap(1));
    }

    emit CandidateExitInitiated(candidate, data.exitableAt);
  }

  /**
   * @notice Complete exit from the candidate set and reclaim bond minus tax
   *
   * @dev Only callable after exitableAt timestamp has passed
   *
   * @custom:reverts EscapeHatch__InvalidStatus if caller's status is not EXITING
   * @custom:reverts EscapeHatch__NotExitableYet if exitableAt has not been reached
   */
  function leaveCandidateSet() external override(IEscapeHatchCore) {
    address candidate = msg.sender;
    CandidateInfo storage data = $candidateDatas[candidate];

    require(data.status == Status.EXITING, Errors_1.EscapeHatch__InvalidStatus(Status.EXITING, data.status));

    require(block.timestamp >= data.exitableAt, Errors_1.EscapeHatch__NotExitableYet(data.exitableAt, block.timestamp));

    uint256 refund = uint256(data.amount);
    if (refund > WITHDRAWAL_TAX) {
      refund -= WITHDRAWAL_TAX;
    } else {
      refund = 0;
    }

    delete $candidateDatas[candidate];

    if (refund > 0) {
      BOND_TOKEN.safeTransfer(candidate, refund);
    }

    emit CandidateExited(candidate, refund);
  }

  /**
   * @notice Update the last submitted archive for a proposer during escape hatch
   *
   * @param _proposer The escape hatch proposer
   * @param _checkpointNumber The checkpoint number being proposed, safely downcasted to 32 bits
   * @param _archive The archive root of the proposed checkpoint
   *
   * @custom:reverts EscapeHatch__OnlyRollup if caller is not the Rollup contract
   */
  function updateSubmittedArchive(address _proposer, uint128 _checkpointNumber, bytes32 _archive)
    external
    override(IEscapeHatchCore)
  {
    require(msg.sender == address(ROLLUP), Errors_1.EscapeHatch__OnlyRollup(msg.sender, address(ROLLUP)));

    CandidateInfo storage data = $candidateDatas[_proposer];
    data.lastCheckpointNumber = _checkpointNumber.toUint32();
    data.lastSubmittedArchive = _archive;

    emit ArchiveUpdated(_proposer, _checkpointNumber, _archive);
  }

  /**
   * @notice Validate that the designated proposer fulfilled their duty
   *
   * @dev Checks that blocks were proposed and proven. Applies punishment if not.
   *      This is the ONLY way to transition from PROPOSING to EXITING.
   *
   * @param _hatch The hatch to validate
   *
   * @custom:reverts EscapeHatch__AlreadyValidated if the hatch has already been validated
   * @custom:reverts EscapeHatch__NoDesignatedProposer if no proposer was designated for the hatch
   * @custom:reverts EscapeHatch__InvalidStatus if proposer's status is not PROPOSING
   * @custom:reverts EscapeHatch__NotExitableYet if called before exitableAt timestamp
   */
  function validateProofSubmission(Hatch _hatch) external override(IEscapeHatchCore) {
    require(!$isHatchValidated.get(Hatch.unwrap(_hatch)), Errors_1.EscapeHatch__AlreadyValidated(_hatch));

    address proposer = $designatedProposer[_hatch];
    require(proposer != address(0), Errors_1.EscapeHatch__NoDesignatedProposer(_hatch));

    CandidateInfo storage data = $candidateDatas[proposer];
    require(data.status == Status.PROPOSING, Errors_1.EscapeHatch__InvalidStatus(Status.PROPOSING, data.status));

    require(block.timestamp >= data.exitableAt, Errors_1.EscapeHatch__NotExitableYet(data.exitableAt, block.timestamp));

    // Check if this contract was the active escape hatch for the entire active period.
    // If not, the proposer may have been unable to fulfill duties due to governance change.
    Epoch firstActiveEpoch = _getFirstEpoch(_hatch);
    bool wasActiveEntirePeriod = true;
    for (uint256 i = 0; i < ACTIVE_DURATION; i++) {
      Epoch epoch = firstActiveEpoch + Epoch.wrap(i);
      if (address(ROLLUP.getEscapeHatchForEpoch(epoch)) != address(this)) {
        wasActiveEntirePeriod = false;
        break;
      }
    }

    bool success = true;
    uint256 punishment = 0;

    if (!wasActiveEntirePeriod && data.lastCheckpointNumber == 0) {
      // Escape hatch was deactivated during the active window and proposer did nothing.
      // This is acceptable - they couldn't (or chose not to) propose during disruption.
      // Skip punishment, transition to EXITING.
    } else {
      // Normal validation: either was active the entire time, or proposer proposed something
      // (if they proposed, they're on the hook regardless of escape hatch changes,
      // since proofs go to the rollup directly and are unaffected by escape hatch changes).

      // 1. Something must have been proposed
      if (data.lastCheckpointNumber == 0) {
        success = false;
      }

      // 2. Proofs must have been submitted at least up to this checkpoint
      if (success && ROLLUP.getProvenCheckpointNumber() < data.lastCheckpointNumber) {
        success = false;
      }

      // 3. The checkpoint archive must still be in the chain (not pruned)
      if (success && ROLLUP.archiveAt(data.lastCheckpointNumber) != data.lastSubmittedArchive) {
        success = false;
      }

      if (!success) {
        punishment = FAILED_HATCH_PUNISHMENT;
        data.amount -= FAILED_HATCH_PUNISHMENT;
      }
    }

    data.status = Status.EXITING;
    data.lastCheckpointNumber = 0;
    data.lastSubmittedArchive = bytes32(0);

    $isHatchValidated.set(Hatch.unwrap(_hatch));

    emit ProofValidated(_hatch, proposer, success, punishment);
  }

  /**
   * @notice Check if an epoch is within an open escape hatch period
   *
   * @param _epoch The epoch to check
   *
   * @return isOpen True if the epoch is within the escape hatch active duration
   * @return proposer The designated proposer for this hatch (address(0) if none or not open)
   */
  function isHatchOpen(Epoch _epoch) external view override(IEscapeHatch) returns (bool isOpen, address proposer) {
    uint256 epochInHatch = Epoch.unwrap(_epoch) % FREQUENCY;
    if (epochInHatch >= ACTIVE_DURATION) {
      return (false, address(0));
    }

    Hatch hatch = _getHatch(_epoch);
    proposer = $designatedProposer[hatch];

    return (proposer != address(0), proposer);
  }

  /**
   * @notice Convert an epoch to its corresponding hatch number
   *
   * @param _epoch The epoch
   *
   * @return The hatch number
   */
  function getHatch(Epoch _epoch) external view override(IEscapeHatch) returns (Hatch) {
    return _getHatch(_epoch);
  }

  /**
   * @notice Get the first epoch of a hatch
   *
   * @param _hatch The hatch number
   *
   * @return The first epoch of the hatch
   */
  function getFirstEpoch(Hatch _hatch) external view override(IEscapeHatch) returns (Epoch) {
    return _getFirstEpoch(_hatch);
  }

  /**
   * @notice Get the designated proposer for a hatch
   *
   * @param _hatch The hatch number
   *
   * @return The designated proposer address (address(0) if none)
   */
  function getDesignatedProposer(Hatch _hatch) external view override(IEscapeHatch) returns (address) {
    return $designatedProposer[_hatch];
  }

  /**
   * @notice Check if a hatch has been prepared
   *
   * @param _hatch The hatch number
   *
   * @return True if the hatch has been prepared
   */
  function isHatchPrepared(Hatch _hatch) external view override(IEscapeHatch) returns (bool) {
    return $isHatchPrepared.get(Hatch.unwrap(_hatch));
  }

  /**
   * @notice Check if a hatch has been validated
   *
   * @param _hatch The hatch number
   *
   * @return True if the hatch has been validated
   */
  function isHatchValidated(Hatch _hatch) external view override(IEscapeHatch) returns (bool) {
    return $isHatchValidated.get(Hatch.unwrap(_hatch));
  }

  /**
   * @notice Get information about a candidate
   *
   * @param _candidate The candidate address
   *
   * @return The candidate's information
   */
  function getCandidateInfo(address _candidate) external view override(IEscapeHatch) returns (CandidateInfo memory) {
    return $candidateDatas[_candidate];
  }

  /**
   * @notice Get the current number of active candidates
   *
   * @return The number of candidates in the active set
   */
  function getCandidateCount() external view override(IEscapeHatch) returns (uint256) {
    return $activeCandidates.length();
  }

  /**
   * @notice Get the number of candidates in the snapshot for a target hatch
   *
   * @param _hatch The target hatch (the one being prepared/proposed for)
   *
   * @return The number of candidates in the snapshot for this hatch
   */
  function getCandidateCountForHatch(Hatch _hatch) external view override(IEscapeHatch) returns (uint256) {
    uint32 freezeTs = getSetTimestamp(_hatch);
    require(freezeTs < block.timestamp, Errors_1.EscapeHatch__SetUnstable(_hatch));
    return $activeCandidates.lengthAtTimestamp(freezeTs);
  }

  /**
   * @notice Get the candidate address at a given index in the current active set
   *
   * @param _index The index in the candidate set
   *
   * @return The candidate address at the given index
   */
  function getCandidateAtIndex(uint256 _index) external view override(IEscapeHatch) returns (address) {
    return $activeCandidates.at(_index);
  }

  /**
   * @notice Get the candidate address at a given index in the snapshot for a target hatch
   *
   * @param _index The index in the snapshot
   * @param _hatch The target hatch (the one being prepared/proposed for)
   *
   * @return The candidate address at the given index in the snapshot
   */
  function getCandidateAtIndexForHatch(uint256 _index, Hatch _hatch)
    external
    view
    override(IEscapeHatch)
    returns (address)
  {
    uint32 freezeTs = getSetTimestamp(_hatch);
    require(freezeTs < block.timestamp, Errors_1.EscapeHatch__SetUnstable(_hatch));
    return $activeCandidates.getAddressFromIndexAtTimestamp(_index, freezeTs);
  }

  /**
   * @notice Check if an address is in the candidate set
   *
   * @param _candidate The address to check
   *
   * @return True if the address is in the active candidate set
   */
  function isCandidate(address _candidate) external view override(IEscapeHatch) returns (bool) {
    return $activeCandidates.contains(_candidate);
  }

  /**
   * @notice Get the rollup contract address
   *
   * @return The rollup contract address
   */
  function getRollup() external view override(IEscapeHatch) returns (address) {
    return address(ROLLUP);
  }

  /**
   * @notice Get the bond token address
   *
   * @return The ERC20 token used for candidate bonds
   */
  function getBondToken() external view override(IEscapeHatch) returns (address) {
    return address(BOND_TOKEN);
  }

  /**
   * @notice Get the required bond size for candidates
   *
   * @return The amount of tokens required to join the candidate set
   */
  function getBondSize() external view override(IEscapeHatch) returns (uint96) {
    return BOND_SIZE;
  }

  /**
   * @notice Get the withdrawal tax applied when exiting
   *
   * @return The amount deducted from bond on exit
   */
  function getWithdrawalTax() external view override(IEscapeHatch) returns (uint96) {
    return WITHDRAWAL_TAX;
  }

  /**
   * @notice Get the punishment for failing to fulfill proposer duties
   *
   * @return The amount deducted from bond on failed hatch
   */
  function getFailedHatchPunishment() external view override(IEscapeHatch) returns (uint96) {
    return FAILED_HATCH_PUNISHMENT;
  }

  /**
   * @notice Get the frequency of escape hatches in epochs
   *
   * @return The number of epochs between escape hatch windows
   */
  function getFrequency() external view override(IEscapeHatch) returns (uint256) {
    return FREQUENCY;
  }

  /**
   * @notice Get the active duration of each escape hatch in epochs
   *
   * @return The number of epochs an escape hatch remains open
   */
  function getActiveDuration() external view override(IEscapeHatch) returns (uint256) {
    return ACTIVE_DURATION;
  }

  /**
   * @notice Get the lag in hatches for candidate selection
   *
   * @return The number of hatches ahead candidates are selected for
   */
  function getLagInHatches() external view override(IEscapeHatch) returns (uint256) {
    return LAG_IN_HATCHES;
  }

  /**
   * @notice Get the additional exit delay after proposing
   *
   * @return The additional seconds a proposer must wait after hatch ends before exiting
   */
  function getProposingExitDelay() external view override(IEscapeHatch) returns (uint256) {
    return PROPOSING_EXIT_DELAY;
  }

  /**
   * @notice Prepare the designated proposer for an upcoming escape hatch
   *
   * @dev Called permissionlessly to set up the next hatch. Uses snapshotted
   *      candidate set and RANDAO for unbiased selection.
   *
   * @custom:reverts EscapeHatch__SetUnstable if called before the freeze timestamp (defense in depth)
   */
  function selectCandidates() public override(IEscapeHatchCore) {
    // Don't select new candidates if this contract is no longer the active escape hatch.
    // We check the latest value rather than the epoch-stable one since we sample for the future,
    // so if the current differs, the future will as well.
    // Early return (not revert) is important because initiateExit() calls selectCandidates() internally.
    if (address(ROLLUP.getEscapeHatch()) != address(this)) {
      return;
    }

    Hatch currentHatch = getCurrentHatch();
    Hatch targetHatch = currentHatch + Hatch.wrap(LAG_IN_HATCHES);

    if ($isHatchPrepared.get(Hatch.unwrap(targetHatch))) {
      return;
    }

    $isHatchPrepared.set(Hatch.unwrap(targetHatch));

    // Get the freeze timestamp for this targetHatch (when candidate set was snapshotted)
    uint32 freezeTs = getSetTimestamp(targetHatch);
    // Defense in depth: ensure we're past the freeze timestamp
    require(freezeTs < block.timestamp, Errors_1.EscapeHatch__SetUnstable(targetHatch));

    uint256 setSize = $activeCandidates.lengthAtTimestamp(freezeTs);
    if (setSize == 0) {
      return;
    }

    // Prevent selection after the freeze timestamp for the NEXT potential sampling.
    // If we select after this timestamp, the selected candidate would still be in
    // the next snapshot, allowing potential re-selection with reduced bond.
    // We return early (no-op) rather than revert to allow initiateExit to proceed
    // even when we're past the selection window.
    uint32 nextFreezeTs = getSetTimestamp(targetHatch + Hatch.wrap(1));
    if (block.timestamp >= nextFreezeTs) {
      return;
    }

    // Get the seed timestamp and sample RANDAO
    uint32 seedTs = getSeedTimestamp(targetHatch);
    uint256 seed = ROLLUP.getSampleSeedAt(Timestamp.wrap(seedTs));
    uint256 index = uint256(keccak256(abi.encode(targetHatch, seed))) % setSize;
    address proposer = $activeCandidates.getAddressFromIndexAtTimestamp(index, freezeTs);

    $designatedProposer[targetHatch] = proposer;

    CandidateInfo storage data = $candidateDatas[proposer];

    // At snapshot time, the candidate must have been ACTIVE, but could have been changed to EXITING,
    // if the candidate called `initiateExit` after the freeze. In that case, skip removal as already
    // done. Any other status indicates a broken invariant and remove() will revert.
    if (data.status != Status.EXITING) {
      $activeCandidates.remove(proposer);
    }

    data.status = Status.PROPOSING;

    // exitableAt = end of hatch opening + proof submission window + proposing exit delay
    Epoch exitableEpoch =
    _getFirstEpoch(targetHatch) + Epoch.wrap(ACTIVE_DURATION) + Epoch.wrap(ROLLUP.getProofSubmissionEpochs());
    data.exitableAt = (Timestamp.unwrap(ROLLUP.getTimestampForEpoch(exitableEpoch)) + PROPOSING_EXIT_DELAY).toUint32();

    emit CandidateSelected(targetHatch, proposer);
  }

  /**
   * @notice Get the current hatch based on the current epoch
   *
   * @return The current hatch number
   */
  function getCurrentHatch() public view override(IEscapeHatch) returns (Hatch) {
    return _getHatch(ROLLUP.getCurrentEpoch());
  }

  /**
   * @notice Get the freeze timestamp for a target hatch's candidate snapshot
   *
   * @dev The snapshot taken at this timestamp determines who was eligible to be
   *      selected as proposer for this hatch.
   *
   * @param _hatch The target hatch (the one being prepared/proposed for)
   *
   * @return The timestamp at which the candidate set was frozen for this hatch
   */
  function getSetTimestamp(Hatch _hatch) public view override(IEscapeHatch) returns (uint32) {
    require(Hatch.unwrap(_hatch) >= LAG_IN_HATCHES, Errors_1.EscapeHatch__HatchTooEarly(_hatch));

    Epoch firstEpoch = _getFirstEpoch(_hatch - Hatch.wrap(LAG_IN_HATCHES));
    require(Epoch.unwrap(firstEpoch) >= LAG_IN_EPOCHS_FOR_SET_SIZE, Errors_1.EscapeHatch__HatchTooEarly(_hatch));

    Epoch freezeEpoch = firstEpoch - Epoch.wrap(LAG_IN_EPOCHS_FOR_SET_SIZE);
    return Timestamp.unwrap(ROLLUP.getTimestampForEpoch(freezeEpoch)).toUint32();
  }

  /**
   * @notice Get the seed timestamp for a target hatch's RANDAO sampling
   *
   * @dev This is after the freeze timestamp to prevent manipulation of the
   *      candidate set based on known RANDAO values.
   *
   * @param _hatch The target hatch (the one being prepared/proposed for)
   *
   * @return The timestamp at which the RANDAO seed is sampled for this hatch
   */
  function getSeedTimestamp(Hatch _hatch) public view override(IEscapeHatch) returns (uint32) {
    require(Hatch.unwrap(_hatch) >= LAG_IN_HATCHES, Errors_1.EscapeHatch__HatchTooEarly(_hatch));

    Hatch samplingHatch = _hatch - Hatch.wrap(LAG_IN_HATCHES);
    Epoch firstEpoch = _getFirstEpoch(samplingHatch);
    require(Epoch.unwrap(firstEpoch) >= LAG_IN_EPOCHS_FOR_RANDAO, Errors_1.EscapeHatch__HatchTooEarly(_hatch));

    Epoch seedEpoch = firstEpoch - Epoch.wrap(LAG_IN_EPOCHS_FOR_RANDAO);
    return Timestamp.unwrap(ROLLUP.getTimestampForEpoch(seedEpoch)).toUint32();
  }

  // ============ Internal Functions ============
  function _getHatch(Epoch _epoch) internal view returns (Hatch) {
    return Hatch.wrap(Epoch.unwrap(_epoch) / FREQUENCY);
  }

  function _getFirstEpoch(Hatch _hatch) internal view returns (Epoch) {
    return Epoch.wrap(Hatch.unwrap(_hatch) * FREQUENCY);
  }
}