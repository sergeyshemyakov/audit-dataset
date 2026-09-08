// SPDX-License-Identifier: Unknown
pragma solidity 0.8.24;

// src/KailuaLib.sol
// Copyright 2024, 2025 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/// @notice Denotes the proven status of the game
/// @custom:value NONE indicates that no proof has been submitted yet.
enum ProofStatus {
    NONE,
    FAULT,
    VALIDITY
}

interface IKailuaTreasury {
    /// @notice Emitted when the participation bond is updated
    /// @param amount The new required bond amount
    event BondUpdated(uint256 amount);

    /// @notice Returns the game index at which proposer was proven faulty
    function eliminationRound(address proposer) external view returns (uint256);

    /// @notice Returns the proposer of a game
    function proposerOf(address game) external view returns (address);

    /// @notice Eliminates a child's proposer and allocates their bond to the prover
    function eliminate(address child, address prover) external;

    /// @notice Returns true iff a proposal is currently being submitted
    function isProposing() external view returns (bool);

    /// @notice Returns the last resolved proposal contract address
    function lastResolved() external view returns (address);

    /// @notice Updates the last resolved contract address to that of the caller
    function updateLastResolved() external;

    /// @notice Returns the collateral required to submit proposals
    function participationBond() external view returns (uint256);

    /// @notice Returns the prover's number of shares in elimination rewards
    function ELIMINATION_SPLIT_PROVER_NUM() external view returns (uint256);

    /// @notice Returns the total number of shares for elimination rewards
    function ELIMINATION_SPLIT_DENOM() external view returns (uint256);
}

/// @title LibTimestamp
/// @notice This library contains helper functions for working with the `Timestamp` type.
library LibTimestamp {
    /// @notice Get the value of a `Timestamp` type in the form of the underlying uint64.
    /// @param _timestamp The `Timestamp` type to get the value of.
    /// @return timestamp_ The value of the `Timestamp` type as a uint64 type.
    function raw(Timestamp _timestamp) internal pure returns (uint64 timestamp_) {
        assembly {
            timestamp_ := _timestamp
        }
    }
}

using LibTimestamp for Timestamp global;

/// @notice A dedicated timestamp type.
type Timestamp is uint64;

interface IKailuaTournament {
    /// @notice Emitted when a proof is submitted.
    /// @param signature The proposal signature
    /// @param status The proven status
    event Proven(bytes32 indexed signature, ProofStatus indexed status);

    /// @notice Returns the KailuaTreasury of this tournament
    function KAILUA_TREASURY() external view returns (IKailuaTreasury);
    /// @notice The timestamp of when the first proof for a proposal signature was made
    function provenAt(bytes32) external view returns (Timestamp);
    /// @notice Returns the hash of the output claim and all blob hashes associated with this proposal
    function signature() external view returns (bytes32);
    /// @notice Returns whether a child can be considered valid
    function isViableSignature(bytes32 childSignature) external view returns (bool);
    /// @notice Returns the signature of the child proven valid
    function validChildSignature() external view returns (bytes32);
}

// lib/optimism/packages/contracts-bedrock/lib/solady/src/utils/Clone.sol

/// @notice Class with helper read functions for clone with immutable args.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Clone.sol)
/// @author Adapted from clones with immutable args by zefram.eth, Saw-mon & Natalie
/// (https://github.com/Saw-mon-and-Natalie/clones-with-immutable-args)
abstract contract Clone {
    /// @dev Reads all of the immutable args.
    function _getArgBytes() internal pure returns (bytes memory arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := mload(0x40)
            let length := sub(calldatasize(), add(2, offset)) // 2 bytes are used for the length.
            mstore(arg, length) // Store the length.
            calldatacopy(add(arg, 0x20), offset, length)
            let o := add(add(arg, 0x20), length)
            mstore(o, 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Reads an immutable arg with type bytes.
    function _getArgBytes(uint256 argOffset, uint256 length) internal pure returns (bytes memory arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := mload(0x40)
            mstore(arg, length) // Store the length.
            calldatacopy(add(arg, 0x20), add(offset, argOffset), length)
            let o := add(add(arg, 0x20), length)
            mstore(o, 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(o, 0x20)) // Allocate the memory.
        }
    }

    /// @dev Reads an immutable arg with type address.
    function _getArgAddress(uint256 argOffset) internal pure returns (address arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(96, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads a uint256 array stored in the immutable args.
    function _getArgUint256Array(uint256 argOffset, uint256 length) internal pure returns (uint256[] memory arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := mload(0x40)
            mstore(arg, length) // Store the length.
            calldatacopy(add(arg, 0x20), add(offset, argOffset), shl(5, length))
            mstore(0x40, add(add(arg, 0x20), shl(5, length))) // Allocate the memory.
        }
    }

    /// @dev Reads a bytes32 array stored in the immutable args.
    function _getArgBytes32Array(uint256 argOffset, uint256 length) internal pure returns (bytes32[] memory arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := mload(0x40)
            mstore(arg, length) // Store the length.
            calldatacopy(add(arg, 0x20), add(offset, argOffset), shl(5, length))
            mstore(0x40, add(add(arg, 0x20), shl(5, length))) // Allocate the memory.
        }
    }

    /// @dev Reads an immutable arg with type bytes32.
    function _getArgBytes32(uint256 argOffset) internal pure returns (bytes32 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @dev Reads an immutable arg with type uint256.
    function _getArgUint256(uint256 argOffset) internal pure returns (uint256 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }

    /// @dev Reads an immutable arg with type uint248.
    function _getArgUint248(uint256 argOffset) internal pure returns (uint248 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(8, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint240.
    function _getArgUint240(uint256 argOffset) internal pure returns (uint240 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(16, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint232.
    function _getArgUint232(uint256 argOffset) internal pure returns (uint232 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(24, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint224.
    function _getArgUint224(uint256 argOffset) internal pure returns (uint224 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(0x20, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint216.
    function _getArgUint216(uint256 argOffset) internal pure returns (uint216 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(40, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint208.
    function _getArgUint208(uint256 argOffset) internal pure returns (uint208 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(48, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint200.
    function _getArgUint200(uint256 argOffset) internal pure returns (uint200 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(56, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint192.
    function _getArgUint192(uint256 argOffset) internal pure returns (uint192 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(64, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint184.
    function _getArgUint184(uint256 argOffset) internal pure returns (uint184 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(72, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint176.
    function _getArgUint176(uint256 argOffset) internal pure returns (uint176 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(80, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint168.
    function _getArgUint168(uint256 argOffset) internal pure returns (uint168 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(88, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint160.
    function _getArgUint160(uint256 argOffset) internal pure returns (uint160 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(96, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint152.
    function _getArgUint152(uint256 argOffset) internal pure returns (uint152 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(104, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint144.
    function _getArgUint144(uint256 argOffset) internal pure returns (uint144 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(112, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint136.
    function _getArgUint136(uint256 argOffset) internal pure returns (uint136 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(120, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint128.
    function _getArgUint128(uint256 argOffset) internal pure returns (uint128 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(128, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint120.
    function _getArgUint120(uint256 argOffset) internal pure returns (uint120 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(136, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint112.
    function _getArgUint112(uint256 argOffset) internal pure returns (uint112 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(144, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint104.
    function _getArgUint104(uint256 argOffset) internal pure returns (uint104 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(152, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint96.
    function _getArgUint96(uint256 argOffset) internal pure returns (uint96 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(160, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint88.
    function _getArgUint88(uint256 argOffset) internal pure returns (uint88 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(168, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint80.
    function _getArgUint80(uint256 argOffset) internal pure returns (uint80 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(176, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint72.
    function _getArgUint72(uint256 argOffset) internal pure returns (uint72 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(184, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint64.
    function _getArgUint64(uint256 argOffset) internal pure returns (uint64 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(192, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint56.
    function _getArgUint56(uint256 argOffset) internal pure returns (uint56 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(200, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint48.
    function _getArgUint48(uint256 argOffset) internal pure returns (uint48 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(208, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint40.
    function _getArgUint40(uint256 argOffset) internal pure returns (uint40 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(216, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint32.
    function _getArgUint32(uint256 argOffset) internal pure returns (uint32 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(224, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint24.
    function _getArgUint24(uint256 argOffset) internal pure returns (uint24 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(232, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint16.
    function _getArgUint16(uint256 argOffset) internal pure returns (uint16 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(240, calldataload(add(offset, argOffset)))
        }
    }

    /// @dev Reads an immutable arg with type uint8.
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        /// @solidity memory-safe-assembly
        assembly {
            arg := shr(248, calldataload(add(offset, argOffset)))
        }
    }

    /// @return offset The offset of the packed immutable args in calldata.
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        /// @solidity memory-safe-assembly
        assembly {
            offset := sub(calldatasize(), shr(240, calldataload(sub(calldatasize(), 2))))
        }
    }
}

// lib/optimism/packages/contracts-bedrock/interfaces/dispute/IInitializable.sol

interface IInitializable {
    function initialize() external payable;
}

// lib/optimism/packages/contracts-bedrock/src/dispute/lib/Types.sol

// Libraries

/// @notice The current status of the dispute game.
enum GameStatus {
    // The game is currently in progress, and has not been resolved.
    IN_PROGRESS,
    // The game has concluded, and the `rootClaim` was challenged successfully.
    CHALLENGER_WINS,
    // The game has concluded, and the `rootClaim` could not be contested.
    DEFENDER_WINS
}

/// @title LibGameType
/// @notice This library contains helper functions for working with the `GameType` type.
library LibGameType {
    /// @notice Get the value of a `GameType` type in the form of the underlying uint32.
    /// @param _gametype The `GameType` type to get the value of.
    /// @return gametype_ The value of the `GameType` type as a uint32 type.
    function raw(GameType _gametype) internal pure returns (uint32 gametype_) {
        assembly {
            gametype_ := _gametype
        }
    }
}

using LibGameType for GameType global;

/// @notice A `GameType` represents the type of game being played.
type GameType is uint32;

/// @title LibPosition
/// @notice This library contains helper functions for working with the `Position` type.
library LibPosition {
    /// @notice the `MAX_POSITION_BITLEN` is the number of bits that the `Position` type, and the implementation of
    ///         its behavior within this library, can safely support.
    uint8 internal constant MAX_POSITION_BITLEN = 126;

    /// @notice Computes a generalized index (2^{depth} + indexAtDepth).
    /// @param _depth The depth of the position.
    /// @param _indexAtDepth The index at the depth of the position.
    /// @return position_ The computed generalized index.
    function wrap(uint8 _depth, uint128 _indexAtDepth) internal pure returns (Position position_) {
        assembly {
            // gindex = 2^{_depth} + _indexAtDepth
            position_ := add(shl(_depth, 1), _indexAtDepth)
        }
    }

    /// @notice Pulls the `depth` out of a `Position` type.
    /// @param _position The generalized index to get the `depth` of.
    /// @return depth_ The `depth` of the `position` gindex.
    /// @custom:attribution Solady <https://github.com/Vectorized/Solady>
    function depth(Position _position) internal pure returns (uint8 depth_) {
        // Return the most significant bit offset, which signifies the depth of the gindex.
        assembly {
            depth_ := or(depth_, shl(6, lt(0xffffffffffffffff, shr(depth_, _position))))
            depth_ := or(depth_, shl(5, lt(0xffffffff, shr(depth_, _position))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            _position := shr(depth_, _position)
            _position := or(_position, shr(1, _position))
            _position := or(_position, shr(2, _position))
            _position := or(_position, shr(4, _position))
            _position := or(_position, shr(8, _position))
            _position := or(_position, shr(16, _position))

            depth_ :=
                or(
                    depth_,
                    byte(
                        shr(251, mul(_position, shl(224, 0x07c4acdd))),
                        0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f
                    )
                )
        }
    }

    /// @notice Pulls the `indexAtDepth` out of a `Position` type.
    ///         The `indexAtDepth` is the left/right index of a position at a specific depth within
    ///         the binary tree, starting from index 0. For example, at gindex 2, the `depth` = 1
    ///         and the `indexAtDepth` = 0.
    /// @param _position The generalized index to get the `indexAtDepth` of.
    /// @return indexAtDepth_ The `indexAtDepth` of the `position` gindex.
    function indexAtDepth(Position _position) internal pure returns (uint128 indexAtDepth_) {
        // Return bits p_{msb-1}...p_{0}. This effectively pulls the 2^{depth} out of the gindex,
        // leaving only the `indexAtDepth`.
        uint256 msb = depth(_position);
        assembly {
            indexAtDepth_ := sub(_position, shl(msb, 1))
        }
    }

    /// @notice Get the left child of `_position`.
    /// @param _position The position to get the left position of.
    /// @return left_ The position to the left of `position`.
    function left(Position _position) internal pure returns (Position left_) {
        assembly {
            left_ := shl(1, _position)
        }
    }

    /// @notice Get the right child of `_position`
    /// @param _position The position to get the right position of.
    /// @return right_ The position to the right of `position`.
    function right(Position _position) internal pure returns (Position right_) {
        assembly {
            right_ := or(1, shl(1, _position))
        }
    }

    /// @notice Get the parent position of `_position`.
    /// @param _position The position to get the parent position of.
    /// @return parent_ The parent position of `position`.
    function parent(Position _position) internal pure returns (Position parent_) {
        assembly {
            parent_ := shr(1, _position)
        }
    }

    /// @notice Get the deepest, right most gindex relative to the `position`. This is equivalent to
    ///         calling `right` on a position until the maximum depth is reached.
    /// @param _position The position to get the relative deepest, right most gindex of.
    /// @param _maxDepth The maximum depth of the game.
    /// @return rightIndex_ The deepest, right most gindex relative to the `position`.
    function rightIndex(Position _position, uint256 _maxDepth) internal pure returns (Position rightIndex_) {
        uint256 msb = depth(_position);
        assembly {
            let remaining := sub(_maxDepth, msb)
            rightIndex_ := or(shl(remaining, _position), sub(shl(remaining, 1), 1))
        }
    }

    /// @notice Get the deepest, right most trace index relative to the `position`. This is
    ///         equivalent to calling `right` on a position until the maximum depth is reached and
    ///         then finding its index at depth.
    /// @param _position The position to get the relative trace index of.
    /// @param _maxDepth The maximum depth of the game.
    /// @return traceIndex_ The trace index relative to the `position`.
    function traceIndex(Position _position, uint256 _maxDepth) internal pure returns (uint256 traceIndex_) {
        uint256 msb = depth(_position);
        assembly {
            let remaining := sub(_maxDepth, msb)
            traceIndex_ := sub(or(shl(remaining, _position), sub(shl(remaining, 1), 1)), shl(_maxDepth, 1))
        }
    }

    /// @notice Gets the position of the highest ancestor of `_position` that commits to the same
    ///         trace index.
    /// @param _position The position to get the highest ancestor of.
    /// @return ancestor_ The highest ancestor of `position` that commits to the same trace index.
    function traceAncestor(Position _position) internal pure returns (Position ancestor_) {
        // Create a field with only the lowest unset bit of `_position` set.
        Position lsb;
        assembly {
            lsb := and(not(_position), add(_position, 1))
        }
        // Find the index of the lowest unset bit within the field.
        uint256 msb = depth(lsb);
        // The highest ancestor that commits to the same trace index is the original position
        // shifted right by the index of the lowest unset bit.
        assembly {
            let a := shr(msb, _position)
            // Bound the ancestor to the minimum gindex, 1.
            ancestor_ := or(a, iszero(a))
        }
    }

    /// @notice Gets the position of the highest ancestor of `_position` that commits to the same
    ///         trace index, while still being below `_upperBoundExclusive`.
    /// @param _position The position to get the highest ancestor of.
    /// @param _upperBoundExclusive The exclusive upper depth bound, used to inform where to stop in order
    ///                             to not escape a sub-tree.
    /// @return ancestor_ The highest ancestor of `position` that commits to the same trace index.
    function traceAncestorBounded(Position _position, uint256 _upperBoundExclusive)
        internal
        pure
        returns (Position ancestor_)
    {
        // This function only works for positions that are below the upper bound.
        if (_position.depth() <= _upperBoundExclusive) {
            assembly {
                // Revert with `ClaimAboveSplit()`
                mstore(0x00, 0xb34b5c22)
                revert(0x1C, 0x04)
            }
        }

        // Grab the global trace ancestor.
        ancestor_ = traceAncestor(_position);

        // If the ancestor is above or at the upper bound, shift it to be below the upper bound.
        // This should be a special case that only covers positions that commit to the final leaf
        // in a sub-tree.
        if (ancestor_.depth() <= _upperBoundExclusive) {
            ancestor_ = ancestor_.rightIndex(_upperBoundExclusive + 1);
        }
    }

    /// @notice Get the move position of `_position`, which is the left child of:
    ///         1. `_position` if `_isAttack` is true.
    ///         2. `_position | 1` if `_isAttack` is false.
    /// @param _position The position to get the relative attack/defense position of.
    /// @param _isAttack Whether or not the move is an attack move.
    /// @return move_ The move position relative to `position`.
    function move(Position _position, bool _isAttack) internal pure returns (Position move_) {
        assembly {
            move_ := shl(1, or(iszero(_isAttack), _position))
        }
    }

    /// @notice Get the value of a `Position` type in the form of the underlying uint128.
    /// @param _position The position to get the value of.
    /// @return raw_ The value of the `position` as a uint128 type.
    function raw(Position _position) internal pure returns (uint128 raw_) {
        assembly {
            raw_ := _position
        }
    }
}

// lib/optimism/packages/contracts-bedrock/src/dispute/lib/LibPosition.sol

using LibPosition for Position global;

/// @notice A `Position` represents a position of a claim within the game tree.
/// @dev This is represented as a "generalized index" where the high-order bit
/// is the level in the tree and the remaining bits is a unique bit pattern, allowing
/// a unique identifier for each node in the tree. Mathematically, it is calculated
/// as 2^{depth} + indexAtDepth.
type Position is uint128;

/// @title LibHash
/// @notice This library contains helper functions for working with the `Hash` type.
library LibHash {
    /// @notice Get the value of a `Hash` type in the form of the underlying bytes32.
    /// @param _hash The `Hash` type to get the value of.
    /// @return hash_ The value of the `Hash` type as a bytes32 type.
    function raw(Hash _hash) internal pure returns (bytes32 hash_) {
        assembly {
            hash_ := _hash
        }
    }
}

using LibHash for Hash global;

/// @notice A custom type for a generic hash.
type Hash is bytes32;

/// @title LibClaim
/// @notice This library contains helper functions for working with the `Claim` type.
library LibClaim {
    /// @notice Get the value of a `Claim` type in the form of the underlying bytes32.
    /// @param _claim The `Claim` type to get the value of.
    /// @return claim_ The value of the `Claim` type as a bytes32 type.
    function raw(Claim _claim) internal pure returns (bytes32 claim_) {
        assembly {
            claim_ := _claim
        }
    }

    /// @notice Hashes a claim and a position together.
    /// @param _claim A Claim type.
    /// @param _position The position of `claim`.
    /// @param _challengeIndex The index of the claim being moved against.
    /// @return claimHash_ A hash of abi.encodePacked(claim, position|challengeIndex);
    function hashClaimPos(Claim _claim, Position _position, uint256 _challengeIndex)
        internal
        pure
        returns (Hash claimHash_)
    {
        assembly {
            mstore(0x00, _claim)
            mstore(0x20, or(shl(128, _position), and(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, _challengeIndex)))
            claimHash_ := keccak256(0x00, 0x40)
        }
    }
}

// lib/optimism/packages/contracts-bedrock/src/dispute/lib/LibUDT.sol

// Libraries

using LibClaim for Claim global;

/// @notice A claim represents an MPT root representing the state of the fault proof program.
type Claim is bytes32;

// lib/optimism/packages/contracts-bedrock/interfaces/dispute/IDisputeGame.sol

interface IDisputeGame is IInitializable {
    event Resolved(GameStatus indexed status);

    function createdAt() external view returns (Timestamp);
    function resolvedAt() external view returns (Timestamp);
    function status() external view returns (GameStatus);
    function gameType() external view returns (GameType gameType_);
    function gameCreator() external pure returns (address creator_);
    function rootClaim() external pure returns (Claim rootClaim_);
    function l1Head() external pure returns (Hash l1Head_);
    function l2SequenceNumber() external pure returns (uint256 l2SequenceNumber_);
    function extraData() external pure returns (bytes memory extraData_);
    function resolve() external returns (GameStatus status_);
    function gameData() external view returns (GameType gameType_, Claim rootClaim_, bytes memory extraData_);
    function wasRespectedGameTypeWhenCreated() external view returns (bool);
}

// lib/optimism/packages/contracts-bedrock/interfaces/universal/ISemver.sol

/// @title ISemver
/// @notice ISemver is a simple contract for ensuring that contracts are
///         versioned using semantic versioning.
interface ISemver {
    /// @notice Getter for the semantic version of the contract. This is not
    ///         meant to be used onchain but instead meant to be used by offchain
    ///         tooling.
    /// @return Semver contract version as a string.
    function version() external view returns (string memory);
}

/// @title LibDuration
/// @notice This library contains helper functions for working with the `Duration` type.
library LibDuration {
    /// @notice Get the value of a `Duration` type in the form of the underlying uint64.
    /// @param _duration The `Duration` type to get the value of.
    /// @return duration_ The value of the `Duration` type as a uint64 type.
    function raw(Duration _duration) internal pure returns (uint64 duration_) {
        assembly {
            duration_ := _duration
        }
    }
}

using LibDuration for Duration global;

/// @notice A dedicated duration type.
/// @dev Unit: seconds
type Duration is uint64;

/// @notice Thrown when a supplied bond is not equal to the required bond amount to cover the cost of the interaction.
error IncorrectBondAmount();

// 0xa506d334
/// @notice Thrown when a resolution is attempted for an unproven claim
error NotProven();

/// @notice Thrown when a credit claim is attempted for a value of 0.
error NoCreditToClaim();

// 0x8b1dfa22
/// @notice Thrown when eliminating an already removed child
error AlreadyEliminated();

/// @notice Thrown when the transfer of credit to a recipient account reverts.
error BondTransferFailed();

library KailuaPayLib {
    /// @notice Transfers ETH from the contract's balance to the recipient
    function pay(uint256 amount, address recipient) internal {
        (bool success,) = recipient.call{value: amount}(hex"");
        if (!success) {
            revert BondTransferFailed();
        }
    }
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface KailuaVerifier is ISemver {
    function faultProofPermitBeneficiary(IKailuaTournament proposalParent, bytes32 proposalSignature)
        external
        view
        returns (address);
    function verify(
        address payoutRecipient,
        bytes32 preconditionHash,
        bytes32 l1Head,
        bytes32 agreedL2OutputRoot,
        bytes32 claimedL2OutputRoot,
        uint64 claimedL2BlockNumber,
        bytes calldata encodedSeal
    ) external view;
}

// lib/optimism/packages/contracts-bedrock/interfaces/universal/IOwnable.sol

/// @title IOwnable
/// @notice Interface for Ownable.
interface IOwnable {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);
    function renounceOwnership() external;
    function transferOwnership(address newOwner) external; // nosemgrep

    function __constructor__() external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/legacy/IAddressManager.sol

/// @title IAddressManager
/// @notice Interface for the AddressManager contract.
interface IAddressManager is IOwnable {
    event AddressSet(string indexed name, address newAddress, address oldAddress);

    function getAddress(string memory _name) external view returns (address);
    function setAddress(string memory _name, address _address) external;

    function __constructor__() external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/universal/IProxyAdmin.sol

interface IProxyAdmin {
    enum ProxyType {
        ERC1967,
        CHUGSPLASH,
        RESOLVED
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function addressManager() external view returns (IAddressManager);
    function changeProxyAdmin(address payable _proxy, address _newAdmin) external;
    function getProxyAdmin(address payable _proxy) external view returns (address);
    function getProxyImplementation(address _proxy) external view returns (address);
    function implementationName(address) external view returns (string memory);
    function isUpgrading() external view returns (bool);
    function owner() external view returns (address);
    function proxyType(address) external view returns (ProxyType);
    function renounceOwnership() external;
    function setAddress(string memory _name, address _address) external;
    function setAddressManager(IAddressManager _address) external;
    function setImplementationName(address _address, string memory _name) external;
    function setProxyType(address _address, ProxyType _type) external;
    function setUpgrading(bool _upgrading) external;
    function transferOwnership(address newOwner) external; // nosemgrep
    function upgrade(address payable _proxy, address _implementation) external;
    function upgradeAndCall(address payable _proxy, address _implementation, bytes memory _data) external payable;

    function __constructor__(address _owner) external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/L1/IProxyAdminOwnedBase.sol

interface IProxyAdminOwnedBase {
    error ProxyAdminOwnedBase_NotSharedProxyAdminOwner();
    error ProxyAdminOwnedBase_NotProxyAdminOwner();
    error ProxyAdminOwnedBase_NotProxyAdmin();
    error ProxyAdminOwnedBase_NotProxyAdminOrProxyAdminOwner();
    error ProxyAdminOwnedBase_ProxyAdminNotFound();
    error ProxyAdminOwnedBase_NotResolvedDelegateProxy();

    function proxyAdmin() external view returns (IProxyAdmin);
    function proxyAdminOwner() external view returns (address);
}

/// @title LibClock
/// @notice This library contains helper functions for working with the `Clock` type.
library LibClock {
    /// @notice Packs a `Duration` and `Timestamp` into a `Clock` type.
    /// @param _duration The `Duration` to pack into the `Clock` type.
    /// @param _timestamp The `Timestamp` to pack into the `Clock` type.
    /// @return clock_ The `Clock` containing the `_duration` and `_timestamp`.
    function wrap(Duration _duration, Timestamp _timestamp) internal pure returns (Clock clock_) {
        assembly {
            clock_ := or(shl(0x40, _duration), _timestamp)
        }
    }

    /// @notice Pull the `Duration` out of a `Clock` type.
    /// @param _clock The `Clock` type to pull the `Duration` out of.
    /// @return duration_ The `Duration` pulled out of `_clock`.
    function duration(Clock _clock) internal pure returns (Duration duration_) {
        // Shift the high-order 64 bits into the low-order 64 bits, leaving only the `duration`.
        assembly {
            duration_ := shr(0x40, _clock)
        }
    }

    /// @notice Pull the `Timestamp` out of a `Clock` type.
    /// @param _clock The `Clock` type to pull the `Timestamp` out of.
    /// @return timestamp_ The `Timestamp` pulled out of `_clock`.
    function timestamp(Clock _clock) internal pure returns (Timestamp timestamp_) {
        // Clean the high-order 192 bits by shifting the clock left and then right again, leaving
        // only the `timestamp`.
        assembly {
            timestamp_ := shr(0xC0, shl(0xC0, _clock))
        }
    }

    /// @notice Get the value of a `Clock` type in the form of the underlying uint128.
    /// @param _clock The `Clock` type to get the value of.
    /// @return clock_ The value of the `Clock` type as a uint128 type.
    function raw(Clock _clock) internal pure returns (uint128 clock_) {
        assembly {
            clock_ := _clock
        }
    }
}

using LibClock for Clock global;

/// @notice A `Clock` represents a packed `Duration` and `Timestamp`
/// @dev The packed layout of this type is as follows:
/// ┌────────────┬────────────────┐
/// │    Bits    │     Value      │
/// ├────────────┼────────────────┤
/// │ [0, 64)    │ Duration       │
/// │ [64, 128)  │ Timestamp      │
/// └────────────┴────────────────┘
type Clock is uint128;

// lib/optimism/packages/contracts-bedrock/lib/lib-keccak/contracts/lib/LibKeccak.sol

/// @title LibKeccak
/// @notice An EVM implementation of the Keccak-f[1600] permutation.
/// @author clabby <https://github.com/clabby>
/// @custom:attribution geohot <https://github.com/geohot>
library LibKeccak {
    /// @notice The block size of the Keccak-f[1600] permutation, 1088 bits (136 bytes).
    uint256 internal constant BLOCK_SIZE_BYTES = 136;

    /// @notice The round constants for the keccak256 hash function. Packed in memory for efficient reading during the
    ///         permutation.
    bytes internal constant ROUND_CONSTANTS = abi.encode(
        0x00000000000000010000000000008082800000000000808a8000000080008000, // r1,r2,r3,r4
        0x000000000000808b000000008000000180000000800080818000000000008009, // r5,r6,r7,r8
        0x000000000000008a00000000000000880000000080008009000000008000000a, // r9,r10,r11,r12
        0x000000008000808b800000000000008b80000000000080898000000000008003, // r13,r14,r15,r16
        0x80000000000080028000000000000080000000000000800a800000008000000a, // r17,r18,r19,r20
        0x8000000080008081800000000000808000000000800000018000000080008008 // r21,r22,r23,r24
    );

    /// @notice A mask for 64-bit values.
    uint64 private constant U64_MASK = 0xFFFFFFFFFFFFFFFF;

    /// @notice The 5x5 state matrix for the keccak-f[1600] permutation.
    struct StateMatrix {
        uint64[25] state;
    }

    /// @notice Performs the Keccak-f[1600] permutation on the given 5x5 state matrix.
    function permutation(StateMatrix memory _stateMatrix) internal pure {
        // Pull the round constants into memory to avoid reallocation in the unrolled permutation loop.
        bytes memory roundConstants = ROUND_CONSTANTS;

        assembly {
            // Add 32 to the state matrix pointer to skip the data location field.
            let stateMatrixPtr := add(_stateMatrix, 0x20)
            let rcPtr := add(roundConstants, 0x20)

            // set a state element in the passed `StateMatrix` struct memory ptr.
            function setStateElem(ptr, idx, data) {
                mstore(add(ptr, shl(0x05, idx)), and(data, U64_MASK))
            }

            // fetch a state element from the passed `StateMatrix` struct memory ptr.
            function stateElem(ptr, idx) -> elem {
                elem := mload(add(ptr, shl(0x05, idx)))
            }

            // 64 bit logical shift
            function shl64(a, b) -> val {
                val := and(shl(a, b), U64_MASK)
            }

            // Performs an indivudual rho + pi computation, to be used in the full `thetaRhoPi` chain.
            function rhoPi(ptr, destIdx, srcIdx, fact, dt) {
                let xs1 := xor(stateElem(ptr, srcIdx), dt)
                let res := xor(shl(fact, xs1), shr(sub(64, fact), xs1))
                setStateElem(ptr, destIdx, res)
            }

            // xor a column in the state matrix
            function xorColumn(ptr, col) -> val {
                val :=
                    xor(
                        xor(xor(stateElem(ptr, col), stateElem(ptr, add(col, 5))), stateElem(ptr, add(col, 10))),
                        xor(stateElem(ptr, add(col, 15)), stateElem(ptr, add(col, 20)))
                    )
            }

            // Performs the `theta`, `rho`, and `pi` steps of the Keccak-f[1600] permutation on
            // the passed `StateMatrix` struct memory ptr.
            function thetaRhoPi(ptr) {
                // Theta
                let C0 := xorColumn(ptr, 0)
                let C1 := xorColumn(ptr, 1)
                let C2 := xorColumn(ptr, 2)
                let C3 := xorColumn(ptr, 3)
                let C4 := xorColumn(ptr, 4)
                let D0 := xor(xor(shl64(1, C1), shr(63, C1)), C4)
                let D1 := xor(xor(shl64(1, C2), shr(63, C2)), C0)
                let D2 := xor(xor(shl64(1, C3), shr(63, C3)), C1)
                let D3 := xor(xor(shl64(1, C4), shr(63, C4)), C2)
                let D4 := xor(xor(shl64(1, C0), shr(63, C0)), C3)

                let xs1 := xor(stateElem(ptr, 1), D1)
                let A1 := xor(shl(1, xs1), shr(63, xs1))

                let _ptr := ptr
                setStateElem(_ptr, 0, xor(stateElem(_ptr, 0), D0))
                rhoPi(_ptr, 1, 6, 44, D1)
                rhoPi(_ptr, 6, 9, 20, D4)
                rhoPi(_ptr, 9, 22, 61, D2)
                rhoPi(_ptr, 22, 14, 39, D4)
                rhoPi(_ptr, 14, 20, 18, D0)
                rhoPi(_ptr, 20, 2, 62, D2)
                rhoPi(_ptr, 2, 12, 43, D2)
                rhoPi(_ptr, 12, 13, 25, D3)
                rhoPi(_ptr, 13, 19, 8, D4)
                rhoPi(_ptr, 19, 23, 56, D3)
                rhoPi(_ptr, 23, 15, 41, D0)
                rhoPi(_ptr, 15, 4, 27, D4)
                rhoPi(_ptr, 4, 24, 14, D4)
                rhoPi(_ptr, 24, 21, 2, D1)
                rhoPi(_ptr, 21, 8, 55, D3)
                rhoPi(_ptr, 8, 16, 45, D1)
                rhoPi(_ptr, 16, 5, 36, D0)
                rhoPi(_ptr, 5, 3, 28, D3)
                rhoPi(_ptr, 3, 18, 21, D3)
                rhoPi(_ptr, 18, 17, 15, D2)
                rhoPi(_ptr, 17, 11, 10, D1)
                rhoPi(_ptr, 11, 7, 6, D2)
                rhoPi(_ptr, 7, 10, 3, D0)
                setStateElem(_ptr, 10, A1)
            }

            // Inner `chi` function, unrolled in `chi` for performance.
            function innerChi(ptr, start) {
                let A0 := stateElem(ptr, start)
                let A1 := stateElem(ptr, add(start, 1))
                let A2 := stateElem(ptr, add(start, 2))
                let A3 := stateElem(ptr, add(start, 3))
                let A4 := stateElem(ptr, add(start, 4))

                setStateElem(ptr, start, xor(A0, and(not(A1), A2)))
                setStateElem(ptr, add(start, 1), xor(A1, and(not(A2), A3)))
                setStateElem(ptr, add(start, 2), xor(A2, and(not(A3), A4)))
                setStateElem(ptr, add(start, 3), xor(A3, and(not(A4), A0)))
                setStateElem(ptr, add(start, 4), xor(A4, and(not(A0), A1)))
            }

            // Performs the `chi` step of the Keccak-f[1600] permutation on the passed `StateMatrix` struct memory ptr
            function chi(ptr) {
                innerChi(ptr, 0)
                innerChi(ptr, 5)
                innerChi(ptr, 10)
                innerChi(ptr, 15)
                innerChi(ptr, 20)
            }

            // Perform the full Keccak-f[1600] permutation on a `StateMatrix` struct memory ptr for a given round.
            function permute(ptr, roundsPtr, round) {
                // Theta, Rho, Pi, Chi
                thetaRhoPi(ptr)
                chi(ptr)
                // Iota
                let roundConst := shr(192, mload(add(roundsPtr, shl(0x03, round))))
                setStateElem(ptr, 0, xor(stateElem(ptr, 0), roundConst))
            }

            // Unroll the permutation loop.
            permute(stateMatrixPtr, rcPtr, 0)
            permute(stateMatrixPtr, rcPtr, 1)
            permute(stateMatrixPtr, rcPtr, 2)
            permute(stateMatrixPtr, rcPtr, 3)
            permute(stateMatrixPtr, rcPtr, 4)
            permute(stateMatrixPtr, rcPtr, 5)
            permute(stateMatrixPtr, rcPtr, 6)
            permute(stateMatrixPtr, rcPtr, 7)
            permute(stateMatrixPtr, rcPtr, 8)
            permute(stateMatrixPtr, rcPtr, 9)
            permute(stateMatrixPtr, rcPtr, 10)
            permute(stateMatrixPtr, rcPtr, 11)
            permute(stateMatrixPtr, rcPtr, 12)
            permute(stateMatrixPtr, rcPtr, 13)
            permute(stateMatrixPtr, rcPtr, 14)
            permute(stateMatrixPtr, rcPtr, 15)
            permute(stateMatrixPtr, rcPtr, 16)
            permute(stateMatrixPtr, rcPtr, 17)
            permute(stateMatrixPtr, rcPtr, 18)
            permute(stateMatrixPtr, rcPtr, 19)
            permute(stateMatrixPtr, rcPtr, 20)
            permute(stateMatrixPtr, rcPtr, 21)
            permute(stateMatrixPtr, rcPtr, 22)
            permute(stateMatrixPtr, rcPtr, 23)
        }
    }

    /// @notice Absorb a fixed-sized block into the sponge.
    function absorb(StateMatrix memory _stateMatrix, bytes memory _input) internal pure {
        assembly {
            // The input must be 1088 bits long.
            if iszero(eq(mload(_input), BLOCK_SIZE_BYTES)) { revert(0, 0) }

            let dataPtr := add(_input, 0x20)
            let statePtr := add(_stateMatrix, 0x20)

            // set a state element in the passed `StateMatrix` struct memory ptr.
            function setStateElem(ptr, idx, data) {
                mstore(add(ptr, shl(0x05, idx)), and(data, U64_MASK))
            }

            // fetch a state element from the passed `StateMatrix` struct memory ptr.
            function stateElem(ptr, idx) -> elem {
                elem := mload(add(ptr, shl(0x05, idx)))
            }

            // Inner sha3 absorb XOR function
            function absorbInner(stateMatrixPtr, inputPtr, idx) {
                let boWord := mload(add(inputPtr, shl(3, idx)))

                let res :=
                    or(
                        or(
                            or(shl(56, byte(7, boWord)), shl(48, byte(6, boWord))),
                            or(shl(40, byte(5, boWord)), shl(32, byte(4, boWord)))
                        ),
                        or(
                            or(shl(24, byte(3, boWord)), shl(16, byte(2, boWord))),
                            or(shl(8, byte(1, boWord)), byte(0, boWord))
                        )
                    )
                setStateElem(stateMatrixPtr, idx, xor(stateElem(stateMatrixPtr, idx), res))
            }

            // Unroll the input XOR loop.
            absorbInner(statePtr, dataPtr, 0)
            absorbInner(statePtr, dataPtr, 1)
            absorbInner(statePtr, dataPtr, 2)
            absorbInner(statePtr, dataPtr, 3)
            absorbInner(statePtr, dataPtr, 4)
            absorbInner(statePtr, dataPtr, 5)
            absorbInner(statePtr, dataPtr, 6)
            absorbInner(statePtr, dataPtr, 7)
            absorbInner(statePtr, dataPtr, 8)
            absorbInner(statePtr, dataPtr, 9)
            absorbInner(statePtr, dataPtr, 10)
            absorbInner(statePtr, dataPtr, 11)
            absorbInner(statePtr, dataPtr, 12)
            absorbInner(statePtr, dataPtr, 13)
            absorbInner(statePtr, dataPtr, 14)
            absorbInner(statePtr, dataPtr, 15)
            absorbInner(statePtr, dataPtr, 16)
        }
    }

    /// @notice Squeezes the final keccak256 digest from the passed `StateMatrix`.
    function squeeze(StateMatrix memory _stateMatrix) internal pure returns (bytes32 hash_) {
        assembly {
            // 64 bit logical shift
            function shl64(a, b) -> val {
                val := and(shl(a, b), U64_MASK)
            }

            // convert a big endian 64-bit value to a little endian 64-bit value.
            function toLE(beVal) -> leVal {
                beVal := or(and(shl64(8, beVal), 0xFF00FF00FF00FF00), and(shr(8, beVal), 0x00FF00FF00FF00FF))
                beVal := or(and(shl64(16, beVal), 0xFFFF0000FFFF0000), and(shr(16, beVal), 0x0000FFFF0000FFFF))
                leVal := or(shl64(32, beVal), shr(32, beVal))
            }

            // fetch a state element from the passed `StateMatrix` struct memory ptr.
            function stateElem(ptr, idx) -> elem {
                elem := mload(add(ptr, shl(0x05, idx)))
            }

            let stateMatrixPtr := add(_stateMatrix, 0x20)
            hash_ :=
                or(
                    or(shl(192, toLE(stateElem(stateMatrixPtr, 0))), shl(128, toLE(stateElem(stateMatrixPtr, 1)))),
                    or(shl(64, toLE(stateElem(stateMatrixPtr, 2))), toLE(stateElem(stateMatrixPtr, 3)))
                )
        }
    }

    /// @notice Pads input data to an even multiple of the Keccak-f[1600] permutation block size, 1088 bits (136 bytes).
    function pad(bytes calldata _data) internal pure returns (bytes memory padded_) {
        assembly {
            padded_ := mload(0x40)

            // Grab the original length of `_data`
            let len := _data.length

            let dataPtr := add(padded_, 0x20)
            let endPtr := add(dataPtr, len)

            // Copy the data into memory.
            calldatacopy(dataPtr, _data.offset, len)

            let modBlockSize := mod(len, BLOCK_SIZE_BYTES)
            switch modBlockSize
            case false {
                // Clean the full padding block. It is possible that this memory is dirty, since solidity sometimes does
                // not update the free memory pointer when allocating memory, for example with external calls. To do
                // this, we read out-of-bounds from the calldata, which will always return 0 bytes.
                calldatacopy(endPtr, calldatasize(), BLOCK_SIZE_BYTES)

                // If the input is a perfect multiple of the block size, then we add a full extra block of padding.
                mstore8(endPtr, 0x01)
                mstore8(sub(add(endPtr, BLOCK_SIZE_BYTES), 0x01), 0x80)

                // Update the length of the data to include the padding.
                mstore(padded_, add(len, BLOCK_SIZE_BYTES))
            }
            default {
                // If the input is not a perfect multiple of the block size, then we add a partial block of padding.
                // This should entail a set bit after the input, followed by as many zero bits as necessary to fill
                // the block, followed by a single 1 bit in the lowest-order bit of the final block.

                let remaining := sub(BLOCK_SIZE_BYTES, modBlockSize)
                let newLen := add(len, remaining)
                let paddedEndPtr := add(dataPtr, newLen)

                // Clean the remainder to ensure that the intermediate data between the padding bits is 0. It is
                // possible that this memory is dirty, since solidity sometimes does not update the free memory pointer
                // when allocating memory, for example with external calls. To do this, we read out-of-bounds from the
                // calldata, which will always return 0 bytes.
                let partialRemainder := sub(paddedEndPtr, endPtr)
                calldatacopy(endPtr, calldatasize(), partialRemainder)

                // Store the padding bits.
                mstore8(sub(paddedEndPtr, 0x01), 0x80)
                mstore8(endPtr, or(byte(0x00, mload(endPtr)), 0x01))

                // Update the length of the data to include the padding. The length should be a multiple of the
                // block size after this.
                mstore(padded_, newLen)
            }

            // Update the free memory pointer.
            mstore(0x40, add(padded_, and(add(mload(padded_), 0x3F), not(0x1F))))
        }
    }

    /// @notice Pads input data to an even multiple of the Keccak-f[1600] permutation block size, 1088 bits (136 bytes).
    function padMemory(bytes memory _data) internal pure returns (bytes memory padded_) {
        assembly {
            padded_ := mload(0x40)

            // Grab the original length of `_data`
            let len := mload(_data)

            let dataPtr := add(padded_, 0x20)
            let endPtr := add(dataPtr, len)

            // Copy the data.
            let originalDataPtr := add(_data, 0x20)
            for { let i := 0x00 } lt(i, len) { i := add(i, 0x20) } {
                mstore(add(dataPtr, i), mload(add(originalDataPtr, i)))
            }

            let modBlockSize := mod(len, BLOCK_SIZE_BYTES)
            switch modBlockSize
            case false {
                // Clean the full padding block. It is possible that this memory is dirty, since solidity sometimes does
                // not update the free memory pointer when allocating memory, for example with external calls. To do
                // this, we read out-of-bounds from the calldata, which will always return 0 bytes.
                calldatacopy(endPtr, calldatasize(), BLOCK_SIZE_BYTES)

                // If the input is a perfect multiple of the block size, then we add a full extra block of padding.
                mstore8(sub(add(endPtr, BLOCK_SIZE_BYTES), 0x01), 0x80)
                mstore8(endPtr, 0x01)

                // Update the length of the data to include the padding.
                mstore(padded_, add(len, BLOCK_SIZE_BYTES))
            }
            default {
                // If the input is not a perfect multiple of the block size, then we add a partial block of padding.
                // This should entail a set bit after the input, followed by as many zero bits as necessary to fill
                // the block, followed by a single 1 bit in the lowest-order bit of the final block.

                let remaining := sub(BLOCK_SIZE_BYTES, modBlockSize)
                let newLen := add(len, remaining)
                let paddedEndPtr := add(dataPtr, newLen)

                // Clean the remainder to ensure that the intermediate data between the padding bits is 0. It is
                // possible that this memory is dirty, since solidity sometimes does not update the free memory pointer
                // when allocating memory, for example with external calls. To do this, we read out-of-bounds from the
                // calldata, which will always return 0 bytes.
                let partialRemainder := sub(paddedEndPtr, endPtr)
                calldatacopy(endPtr, calldatasize(), partialRemainder)

                // Store the padding bits.
                mstore8(sub(paddedEndPtr, 0x01), 0x80)
                mstore8(endPtr, or(byte(0x00, mload(endPtr)), 0x01))

                // Update the length of the data to include the padding. The length should be a multiple of the
                // block size after this.
                mstore(padded_, newLen)
            }

            // Update the free memory pointer.
            mstore(0x40, add(padded_, and(add(mload(padded_), 0x3F), not(0x1F))))
        }
    }
}

/// @notice LPP metadata UDT extension functions.
library LPPMetadataLib {
    uint256 private constant U64_MASK = 0xFFFFFFFFFFFFFFFF;
    uint256 private constant U32_MASK = 0xFFFFFFFF;

    function setTimestamp(LPPMetaData _self, uint64 _timestamp) internal pure returns (LPPMetaData self_) {
        assembly {
            self_ := or(shl(192, _timestamp), and(_self, not(shl(192, U64_MASK))))
        }
    }

    function setPartOffset(LPPMetaData _self, uint32 _partOffset) internal pure returns (LPPMetaData self_) {
        assembly {
            self_ := or(shl(160, _partOffset), and(_self, not(shl(160, U32_MASK))))
        }
    }

    function setClaimedSize(LPPMetaData _self, uint32 _claimedSize) internal pure returns (LPPMetaData self_) {
        assembly {
            self_ := or(shl(128, _claimedSize), and(_self, not(shl(128, U32_MASK))))
        }
    }

    function setBlocksProcessed(LPPMetaData _self, uint32 _blocksProcessed) internal pure returns (LPPMetaData self_) {
        assembly {
            self_ := or(shl(96, _blocksProcessed), and(_self, not(shl(96, U32_MASK))))
        }
    }

    function setBytesProcessed(LPPMetaData _self, uint32 _bytesProcessed) internal pure returns (LPPMetaData self_) {
        assembly {
            self_ := or(shl(64, _bytesProcessed), and(_self, not(shl(64, U32_MASK))))
        }
    }

    function setCountered(LPPMetaData _self, bool _countered) internal pure returns (LPPMetaData self_) {
        assembly {
            self_ := or(_countered, and(_self, not(U64_MASK)))
        }
    }

    function timestamp(LPPMetaData _self) internal pure returns (uint64 timestamp_) {
        assembly {
            timestamp_ := shr(192, _self)
        }
    }

    function partOffset(LPPMetaData _self) internal pure returns (uint64 partOffset_) {
        assembly {
            partOffset_ := and(shr(160, _self), U32_MASK)
        }
    }

    function claimedSize(LPPMetaData _self) internal pure returns (uint32 claimedSize_) {
        assembly {
            claimedSize_ := and(shr(128, _self), U32_MASK)
        }
    }

    function blocksProcessed(LPPMetaData _self) internal pure returns (uint32 blocksProcessed_) {
        assembly {
            blocksProcessed_ := and(shr(96, _self), U32_MASK)
        }
    }

    function bytesProcessed(LPPMetaData _self) internal pure returns (uint32 bytesProcessed_) {
        assembly {
            bytesProcessed_ := and(shr(64, _self), U32_MASK)
        }
    }

    function countered(LPPMetaData _self) internal pure returns (bool countered_) {
        assembly {
            countered_ := and(_self, U64_MASK)
        }
    }
}

// lib/optimism/packages/contracts-bedrock/src/cannon/libraries/CannonTypes.sol

using LPPMetadataLib for LPPMetaData global;

/// @notice Packed LPP metadata.
/// ┌─────────────┬────────────────────────────────────────────┐
/// │ Bit Offsets │                Description                 │
/// ├─────────────┼────────────────────────────────────────────┤
/// │ [0, 64)     │ Timestamp (Finalized - All data available) │
/// │ [64, 96)    │ Part Offset                                │
/// │ [96, 128)   │ Claimed Size                               │
/// │ [128, 160)  │ Blocks Processed (Inclusive of Padding)    │
/// │ [160, 192)  │ Bytes Processed (Non-inclusive of Padding) │
/// │ [192, 256)  │ Countered                                  │
/// └─────────────┴────────────────────────────────────────────┘
type LPPMetaData is bytes32;

// lib/optimism/packages/contracts-bedrock/interfaces/cannon/IPreimageOracle.sol

interface IPreimageOracle {
    struct Leaf {
        bytes input;
        uint256 index;
        bytes32 stateCommitment;
    }

    error ActiveProposal();
    error AlreadyFinalized();
    error AlreadyInitialized();
    error BadProposal();
    error BondTransferFailed();
    error InsufficientBond();
    error InvalidInputSize();
    error InvalidPreimage();
    error InvalidProof();
    error NotEOA();
    error NotInitialized();
    error PartOffsetOOB();
    error PostStateMatches();
    error StatesNotContiguous();
    error TreeSizeOverflow();
    error WrongStartingBlock();

    function KECCAK_TREE_DEPTH() external view returns (uint256);
    function MAX_LEAF_COUNT() external view returns (uint256);
    function MIN_BOND_SIZE() external view returns (uint256);
    function PRECOMPILE_CALL_RESERVED_GAS() external view returns (uint256);
    function addLeavesLPP(
        uint256 _uuid,
        uint256 _inputStartBlock,
        bytes memory _input,
        bytes32[] memory _stateCommitments,
        bool _finalize
    ) external;
    function challengeFirstLPP(
        address _claimant,
        uint256 _uuid,
        Leaf memory _postState,
        bytes32[] memory _postStateProof
    ) external;
    function challengeLPP(
        address _claimant,
        uint256 _uuid,
        LibKeccak.StateMatrix memory _stateMatrix,
        Leaf memory _preState,
        bytes32[] memory _preStateProof,
        Leaf memory _postState,
        bytes32[] memory _postStateProof
    ) external;
    function challengePeriod() external view returns (uint256 challengePeriod_);
    function getTreeRootLPP(address _owner, uint256 _uuid) external view returns (bytes32 treeRoot_);
    function initLPP(uint256 _uuid, uint32 _partOffset, uint32 _claimedSize) external payable;
    function loadBlobPreimagePart(
        uint256 _z,
        uint256 _y,
        bytes memory _commitment,
        bytes memory _proof,
        uint256 _partOffset
    ) external;
    function loadKeccak256PreimagePart(uint256 _partOffset, bytes memory _preimage) external;
    function loadLocalData(uint256 _ident, bytes32 _localContext, bytes32 _word, uint256 _size, uint256 _partOffset)
        external
        returns (bytes32 key_);
    function loadPrecompilePreimagePart(
        uint256 _partOffset,
        address _precompile,
        uint64 _requiredGas,
        bytes memory _input
    ) external;
    function loadSha256PreimagePart(uint256 _partOffset, bytes memory _preimage) external;
    function minProposalSize() external view returns (uint256 minProposalSize_);
    function preimageLengths(bytes32) external view returns (uint256);
    function preimagePartOk(bytes32, uint256) external view returns (bool);
    function preimageParts(bytes32, uint256) external view returns (bytes32);
    function proposalBlocks(address, uint256, uint256) external view returns (uint64);
    function proposalBlocksLen(address _claimant, uint256 _uuid) external view returns (uint256 len_);
    function proposalBonds(address, uint256) external view returns (uint256);
    function proposalBranches(address, uint256, uint256) external view returns (bytes32);
    function proposalCount() external view returns (uint256 count_);
    function proposalMetadata(address, uint256) external view returns (LPPMetaData);
    function proposalParts(address, uint256) external view returns (bytes32);
    function proposals(uint256) external view returns (address claimant, uint256 uuid); // nosemgrep:
        // sol-style-return-arg-fmt
    function readPreimage(bytes32 _key, uint256 _offset) external view returns (bytes32 dat_, uint256 datLen_);
    function squeezeLPP(
        address _claimant,
        uint256 _uuid,
        LibKeccak.StateMatrix memory _stateMatrix,
        Leaf memory _preState,
        bytes32[] memory _preStateProof,
        Leaf memory _postState,
        bytes32[] memory _postStateProof
    ) external;
    function version() external view returns (string memory);
    function zeroHashes(uint256) external view returns (bytes32);

    function __constructor__(uint256 _minProposalSize, uint256 _challengePeriod) external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/dispute/IBigStepper.sol

/// @title IBigStepper
/// @notice Describes a state machine that can perform a single instruction step, provided a prestate and an optional
///         proof.
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠶⢅⠒⢄⢔⣶⡦⣤⡤⠄⣀⠀⠀⠀⠀⠀⠀⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠨⡏⠀⠀⠈⠢⣙⢯⣄⠀⢨⠯⡺⡘⢄⠀⠀⠀⠀⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣶⡆⠀⠀⠀⠀⠈⠓⠬⡒⠡⣀⢙⡜⡀⠓⠄⠀⠀⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡷⠿⣧⣀⡀⠀⠀⠀⠀⠀⠀⠉⠣⣞⠩⠥⠀⠼⢄⠀⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠉⢹⣶⠒⠒⠂⠈⠉⠁⠘⡆⠀⣿⣿⠫⡄⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢶⣤⣀⡀⠀⠀⢸⡿⠀⠀⠀⠀⠀⢀⠞⠀⠀⢡⢨⢀⡄⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡒⣿⢿⡤⠝⡣⠉⠁⠚⠛⠀⠤⠤⣄⡰⠁⠀⠀⠀⠉⠙⢸⠀⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⢯⡌⡿⡇⠘⡷⠀⠁⠀⠀⢀⣰⠢⠲⠛⣈⣸⠦⠤⠶⠴⢬⣐⣊⡂⠀
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⡪⡗⢫⠞⠀⠆⣀⠻⠤⠴⠐⠚⣉⢀⠦⠂⠋⠁⠀⠁⠀⠀⠀⠀⢋⠉⠇⠀
/// ⠀⠀⠀⠀⣀⡤⠐⠒⠘⡹⠉⢸⠇⠸⠀⠀⠀⠀⣀⣤⠴⠚⠉⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠼⠀⣾⠀
/// ⠀⠀⠀⡰⠀⠉⠉⠀⠁⠀⠀⠈⢇⠈⠒⠒⠘⠈⢀⢡⡂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⢸⡄
/// ⠀⠀⠸⣿⣆⠤⢀⡀⠀⠀⠀⠀⢘⡌⠀⠀⣀⣀⣀⡈⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⢸⡇
/// ⠀⠀⢸⣀⠀⠉⠒⠐⠛⠋⠭⠭⠍⠉⠛⠒⠒⠒⠀⠒⠚⠛⠛⠛⠩⠭⠭⠭⠭⠤⠤⠤⠤⠤⠭⠭⠉⠓⡆
/// ⠀⠀⠘⠿⣷⣶⣤⣤⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇
/// ⠀⠀⠀⠀⠀⠉⠙⠛⠛⠻⠿⢿⣿⣿⣷⣶⣶⣶⣤⣤⣀⣁⣛⣃⣒⠿⠿⠿⠤⠠⠄⠤⠤⢤⣛⣓⣂⣻⡇
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠙⠛⠻⠿⠿⠿⢿⣿⣿⣿⣷⣶⣶⣾⣿⣿⣿⣿⠿⠟⠁
/// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀
interface IBigStepper {
    /// @notice Performs the state transition from a given prestate and returns the hash of the post state witness.
    /// @param _stateData The raw opaque prestate data.
    /// @param _proof Opaque proof data, can be used to prove things about the prestate in relation to the state of the
    ///               interface's implementation.
    /// @param _localContext The local key context for the preimage oracle. Optional, can be set as a constant if the
    ///                      implementation only requires one set of local keys.
    /// @return postState_ The hash of the post state witness after the state transition.
    function step(bytes calldata _stateData, bytes calldata _proof, bytes32 _localContext)
        external
        returns (bytes32 postState_);

    /// @notice Returns the preimage oracle used by the state machine.
    function oracle() external view returns (IPreimageOracle oracle_);
}

// lib/optimism/packages/contracts-bedrock/interfaces/L1/IResourceMetering.sol

interface IResourceMetering {
    struct ResourceParams {
        uint128 prevBaseFee;
        uint64 prevBoughtGas;
        uint64 prevBlockNum;
    }

    struct ResourceConfig {
        uint32 maxResourceLimit;
        uint8 elasticityMultiplier;
        uint8 baseFeeMaxChangeDenominator;
        uint32 minimumBaseFee;
        uint32 systemTxMaxGas;
        uint128 maximumBaseFee;
    }

    error OutOfGas();

    event Initialized(uint8 version);

    function params() external view returns (uint128 prevBaseFee, uint64 prevBoughtGas, uint64 prevBlockNum); // nosemgrep

    function __constructor__() external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/L1/ISuperchainConfig.sol

interface ISuperchainConfig is IProxyAdminOwnedBase {
    enum UpdateType {
        GUARDIAN
    }

    event ConfigUpdate(UpdateType indexed updateType, bytes data);
    event Initialized(uint8 version);
    event Paused(address identifier);
    event Unpaused(address identifier);

    error SuperchainConfig_OnlyGuardian();
    error SuperchainConfig_AlreadyPaused(address identifier);
    error SuperchainConfig_NotAlreadyPaused(address identifier);
    error ReinitializableBase_ZeroInitVersion();

    function guardian() external view returns (address);
    function initialize(address _guardian) external;
    function pause(address _identifier) external;
    function unpause(address _identifier) external;
    function pausable(address _identifier) external view returns (bool);
    function paused() external view returns (bool);
    function paused(address _identifier) external view returns (bool);
    function expiration(address _identifier) external view returns (uint256);
    function extend(address _identifier) external;
    function version() external view returns (string memory);
    function pauseTimestamps(address) external view returns (uint256);
    function pauseExpiry() external view returns (uint256);
    function initVersion() external view returns (uint8);

    function __constructor__() external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/L1/ISystemConfig.sol

interface ISystemConfig is IProxyAdminOwnedBase {
    enum UpdateType {
        BATCHER,
        FEE_SCALARS,
        GAS_LIMIT,
        UNSAFE_BLOCK_SIGNER,
        EIP_1559_PARAMS,
        OPERATOR_FEE_PARAMS,
        MIN_BASE_FEE,
        DA_FOOTPRINT_GAS_SCALAR
    }

    struct Addresses {
        address l1CrossDomainMessenger;
        address l1ERC721Bridge;
        address l1StandardBridge;
        address optimismPortal;
        address optimismMintableERC20Factory;
    }

    error ReinitializableBase_ZeroInitVersion();
    error SystemConfig_InvalidFeatureState();

    event ConfigUpdate(uint256 indexed version, UpdateType indexed updateType, bytes data);
    event FeatureSet(bytes32 indexed feature, bool indexed enabled);
    event Initialized(uint8 version);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function BATCH_INBOX_SLOT() external view returns (bytes32);
    function L1_CROSS_DOMAIN_MESSENGER_SLOT() external view returns (bytes32);
    function L1_ERC_721_BRIDGE_SLOT() external view returns (bytes32);
    function L1_STANDARD_BRIDGE_SLOT() external view returns (bytes32);
    function OPTIMISM_MINTABLE_ERC20_FACTORY_SLOT() external view returns (bytes32);
    function OPTIMISM_PORTAL_SLOT() external view returns (bytes32);
    function START_BLOCK_SLOT() external view returns (bytes32);
    function UNSAFE_BLOCK_SIGNER_SLOT() external view returns (bytes32);
    function VERSION() external view returns (uint256);
    function basefeeScalar() external view returns (uint32);
    function batchInbox() external view returns (address addr_);
    function batcherHash() external view returns (bytes32);
    function blobbasefeeScalar() external view returns (uint32);
    function disputeGameFactory() external view returns (address addr_);
    function gasLimit() external view returns (uint64);
    function eip1559Denominator() external view returns (uint32);
    function eip1559Elasticity() external view returns (uint32);
    function getAddresses() external view returns (Addresses memory);
    function initialize(
        address _owner,
        uint32 _basefeeScalar,
        uint32 _blobbasefeeScalar,
        bytes32 _batcherHash,
        uint64 _gasLimit,
        address _unsafeBlockSigner,
        IResourceMetering.ResourceConfig memory _config,
        address _batchInbox,
        Addresses memory _addresses,
        uint256 _l2ChainId,
        ISuperchainConfig _superchainConfig
    ) external;
    function initVersion() external view returns (uint8);
    function l1CrossDomainMessenger() external view returns (address addr_);
    function l1ERC721Bridge() external view returns (address addr_);
    function l1StandardBridge() external view returns (address addr_);
    function l2ChainId() external view returns (uint256);
    function maximumGasLimit() external pure returns (uint64);
    function minimumGasLimit() external view returns (uint64);
    function operatorFeeConstant() external view returns (uint64);
    function operatorFeeScalar() external view returns (uint32);
    function minBaseFee() external view returns (uint64);
    function daFootprintGasScalar() external view returns (uint16);
    function optimismMintableERC20Factory() external view returns (address addr_);
    function optimismPortal() external view returns (address addr_);
    function overhead() external view returns (uint256);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function resourceConfig() external view returns (IResourceMetering.ResourceConfig memory);
    function scalar() external view returns (uint256);
    function setBatcherHash(bytes32 _batcherHash) external;
    function setGasConfig(uint256 _overhead, uint256 _scalar) external;
    function setGasConfigEcotone(uint32 _basefeeScalar, uint32 _blobbasefeeScalar) external;
    function setGasLimit(uint64 _gasLimit) external;
    function setOperatorFeeScalars(uint32 _operatorFeeScalar, uint64 _operatorFeeConstant) external;
    function setUnsafeBlockSigner(address _unsafeBlockSigner) external;
    function setEIP1559Params(uint32 _denominator, uint32 _elasticity) external;
    function setMinBaseFee(uint64 _minBaseFee) external;
    function setDAFootprintGasScalar(uint16 _daFootprintGasScalar) external;
    function startBlock() external view returns (uint256 startBlock_);
    function transferOwnership(address newOwner) external; // nosemgrep
    function unsafeBlockSigner() external view returns (address addr_);
    function version() external pure returns (string memory);
    function paused() external view returns (bool);
    function superchainConfig() external view returns (ISuperchainConfig);
    function guardian() external view returns (address);
    function setFeature(bytes32 _feature, bool _enabled) external;
    function isFeatureEnabled(bytes32) external view returns (bool);

    function __constructor__() external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/dispute/IDelayedWETH.sol

interface IDelayedWETH is IProxyAdminOwnedBase {
    error ReinitializableBase_ZeroInitVersion();

    struct WithdrawalRequest {
        uint256 amount;
        uint256 timestamp;
    }

    event Initialized(uint8 version);

    fallback() external payable;
    receive() external payable;

    function initVersion() external view returns (uint8);
    function systemConfig() external view returns (ISystemConfig);
    function delay() external view returns (uint256);
    function hold(address _guy) external;
    function hold(address _guy, uint256 _wad) external;
    function initialize(ISystemConfig _systemConfig) external;
    function recover(uint256 _wad) external;
    function unlock(address _guy, uint256 _wad) external;
    function withdraw(address _guy, uint256 _wad) external;
    function withdrawals(address, address) external view returns (uint256 amount, uint256 timestamp);
    function version() external view returns (string memory);
    function withdraw(uint256 _wad) external;

    event Approval(address indexed src, address indexed guy, uint256 wad);

    event Transfer(address indexed src, address indexed dst, uint256 wad);

    event Deposit(address indexed dst, uint256 wad);

    event Withdrawal(address indexed src, uint256 wad);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address src) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function deposit() external payable;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(address src, address dst, uint256 wad) external returns (bool);

    function config() external view returns (ISuperchainConfig);

    function __constructor__(uint256 _delay) external;
}

/// @notice The game's bond distribution type. Games are expected to start in the `UNDECIDED`
///         state, and then choose either `NORMAL` or `REFUND`.
enum BondDistributionMode {
    // Bond distribution strategy has not been chosen.
    UNDECIDED,
    // Bonds should be distributed as normal.
    NORMAL,
    // Bonds should be refunded to claimants.
    REFUND
}

// lib/optimism/packages/contracts-bedrock/src/libraries/Types.sol

/// @title Types
/// @notice Contains various types used throughout the Optimism contract system.
library Types {
    /// @notice OutputProposal represents a commitment to the L2 state. The timestamp is the L1
    ///         timestamp that the output root is posted. This timestamp is used to verify that the
    ///         finalization period has passed since the output root was submitted.
    /// @custom:field outputRoot    Hash of the L2 output.
    /// @custom:field timestamp     Timestamp of the L1 block that the output root was submitted in.
    /// @custom:field l2BlockNumber L2 block number that the output corresponds to.
    struct OutputProposal {
        bytes32 outputRoot;
        uint128 timestamp;
        uint128 l2BlockNumber;
    }

    /// @notice Struct representing the elements that are hashed together to generate an output root
    ///         which itself represents a snapshot of the L2 state.
    /// @custom:field version                  Version of the output root.
    /// @custom:field stateRoot                Root of the state trie at the block of this output.
    /// @custom:field messagePasserStorageRoot Root of the message passer storage trie.
    /// @custom:field latestBlockhash          Hash of the block this output was generated from.
    struct OutputRootProof {
        bytes32 version;
        bytes32 stateRoot;
        bytes32 messagePasserStorageRoot;
        bytes32 latestBlockhash;
    }

    /// @notice Struct representing an output root with a chain id.
    /// @custom:field chainId The chain ID of the L2 chain that the output root commits to.
    /// @custom:field root    The output root.
    struct OutputRootWithChainId {
        uint256 chainId;
        bytes32 root;
    }

    /// @notice Struct representing a super root proof.
    /// @custom:field version     The version of the super root proof.
    /// @custom:field timestamp   The timestamp of the super root proof.
    /// @custom:field outputRoots The output roots that are included in the super root proof.
    struct SuperRootProof {
        bytes1 version;
        uint64 timestamp;
        OutputRootWithChainId[] outputRoots;
    }

    /// @notice Struct representing a deposit transaction (L1 => L2 transaction) created by an end
    ///         user (as opposed to a system deposit transaction generated by the system).
    /// @custom:field from        Address of the sender of the transaction.
    /// @custom:field to          Address of the recipient of the transaction.
    /// @custom:field isCreation  True if the transaction is a contract creation.
    /// @custom:field value       Value to send to the recipient.
    /// @custom:field mint        Amount of ETH to mint.
    /// @custom:field gasLimit    Gas limit of the transaction.
    /// @custom:field data        Data of the transaction.
    /// @custom:field l1BlockHash Hash of the block the transaction was submitted in.
    /// @custom:field logIndex    Index of the log in the block the transaction was submitted in.
    struct UserDepositTransaction {
        address from;
        address to;
        bool isCreation;
        uint256 value;
        uint256 mint;
        uint64 gasLimit;
        bytes data;
        bytes32 l1BlockHash;
        uint256 logIndex;
    }

    /// @notice Struct representing a withdrawal transaction.
    /// @custom:field nonce    Nonce of the withdrawal transaction
    /// @custom:field sender   Address of the sender of the transaction.
    /// @custom:field target   Address of the recipient of the transaction.
    /// @custom:field value    Value to send to the recipient.
    /// @custom:field gasLimit Gas limit of the transaction.
    /// @custom:field data     Data of the transaction.
    struct WithdrawalTransaction {
        uint256 nonce;
        address sender;
        address target;
        uint256 value;
        uint256 gasLimit;
        bytes data;
    }

    /// @notice Enum representing where the FeeVault withdraws funds to.
    /// @custom:value L1 FeeVault withdraws funds to L1.
    /// @custom:value L2 FeeVault withdraws funds to L2.
    enum WithdrawalNetwork {
        L1,
        L2
    }
}

// lib/optimism/packages/contracts-bedrock/interfaces/dispute/IFaultDisputeGame.sol

interface IFaultDisputeGame is IDisputeGame {
    struct ClaimData {
        uint32 parentIndex;
        address counteredBy;
        address claimant;
        uint128 bond;
        Claim claim;
        Position position;
        Clock clock;
    }

    struct ResolutionCheckpoint {
        bool initialCheckpointComplete;
        uint32 subgameIndex;
        Position leftmostPosition;
        address counteredBy;
    }

    struct GameConstructorParams {
        GameType gameType;
        Claim absolutePrestate;
        uint256 maxGameDepth;
        uint256 splitDepth;
        Duration clockExtension;
        Duration maxClockDuration;
        IBigStepper vm;
        IDelayedWETH weth;
        IAnchorStateRegistry anchorStateRegistry;
        uint256 l2ChainId;
    }

    error AlreadyInitialized();
    error AnchorRootNotFound();
    error BadExtraData();
    error BlockNumberMatches();
    error BondTransferFailed();
    error CannotDefendRootClaim();
    error ClaimAboveSplit();
    error ClaimAlreadyExists();
    error ClaimAlreadyResolved();
    error ClockNotExpired();
    error ClockTimeExceeded();
    error ContentLengthMismatch();
    error DuplicateStep();
    error EmptyItem();
    error GameDepthExceeded();
    error GameNotInProgress();
    error IncorrectBondAmount();
    error InvalidChallengePeriod();
    error InvalidClockExtension();
    error InvalidDataRemainder();
    error InvalidDisputedClaimIndex();
    error InvalidHeader();
    error InvalidHeaderRLP();
    error InvalidLocalIdent();
    error InvalidOutputRootProof();
    error InvalidParent();
    error InvalidPrestate();
    error InvalidSplitDepth();
    error L2BlockNumberChallenged();
    error MaxDepthTooLarge();
    error NoCreditToClaim();
    error OutOfOrderResolution();
    error UnexpectedList();
    error UnexpectedRootClaim(Claim rootClaim);
    error UnexpectedString();
    error ValidStep();
    error InvalidBondDistributionMode();
    error GameNotFinalized();
    error GameNotResolved();
    error ReservedGameType();
    error GamePaused();

    event Move(uint256 indexed parentIndex, Claim indexed claim, address indexed claimant);
    event GameClosed(BondDistributionMode bondDistributionMode);

    function absolutePrestate() external view returns (Claim absolutePrestate_);
    function addLocalData(uint256 _ident, uint256 _execLeafIdx, uint256 _partOffset) external;
    function anchorStateRegistry() external view returns (IAnchorStateRegistry registry_);
    function attack(Claim _disputed, uint256 _parentIndex, Claim _claim) external payable;
    function bondDistributionMode() external view returns (BondDistributionMode);
    function challengeRootL2Block(Types.OutputRootProof memory _outputRootProof, bytes memory _headerRLP) external;
    function claimCredit(address _recipient) external;
    function claimData(uint256)
        external
        view // nosemgrep
        returns (
            uint32 parentIndex,
            address counteredBy,
            address claimant,
            uint128 bond,
            Claim claim,
            Position position,
            Clock clock
        );
    function claimDataLen() external view returns (uint256 len_);
    function claims(Hash) external view returns (bool);
    function clockExtension() external view returns (Duration clockExtension_);
    function closeGame() external;
    function credit(address _recipient) external view returns (uint256 credit_);
    function defend(Claim _disputed, uint256 _parentIndex, Claim _claim) external payable;
    function getChallengerDuration(uint256 _claimIndex) external view returns (Duration duration_);
    function getNumToResolve(uint256 _claimIndex) external view returns (uint256 numRemainingChildren_);
    function getRequiredBond(Position _position) external view returns (uint256 requiredBond_);
    function hasUnlockedCredit(address) external view returns (bool);
    function l2BlockNumber() external pure returns (uint256 l2BlockNumber_);
    function l2BlockNumberChallenged() external view returns (bool);
    function l2BlockNumberChallenger() external view returns (address);
    function l2ChainId() external view returns (uint256 l2ChainId_);
    function maxClockDuration() external view returns (Duration maxClockDuration_);
    function maxGameDepth() external view returns (uint256 maxGameDepth_);
    function move(Claim _disputed, uint256 _challengeIndex, Claim _claim, bool _isAttack) external payable;
    function normalModeCredit(address) external view returns (uint256);
    function refundModeCredit(address) external view returns (uint256);
    function resolutionCheckpoints(uint256)
        external
        view
        returns (bool initialCheckpointComplete, uint32 subgameIndex, Position leftmostPosition, address counteredBy); // nosemgrep
    function resolveClaim(uint256 _claimIndex, uint256 _numToResolve) external;
    function resolvedSubgames(uint256) external view returns (bool);
    function splitDepth() external view returns (uint256 splitDepth_);
    function startingBlockNumber() external view returns (uint256 startingBlockNumber_);
    function startingOutputRoot() external view returns (Hash root, uint256 l2SequenceNumber); // nosemgrep
    function startingRootHash() external view returns (Hash startingRootHash_);
    function step(uint256 _claimIndex, bool _isAttack, bytes memory _stateData, bytes memory _proof) external;
    function subgames(uint256, uint256) external view returns (uint256);
    function version() external pure returns (string memory);
    function vm() external view returns (IBigStepper vm_);
    function wasRespectedGameTypeWhenCreated() external view returns (bool);
    function weth() external view returns (IDelayedWETH weth_);

    function __constructor__(GameConstructorParams memory _params) external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/universal/IReinitializableBase.sol

interface IReinitializableBase {
    error ReinitializableBase_ZeroInitVersion();

    function initVersion() external view returns (uint8);

    // ReinitializerBase is abstract, so it has no constructor in its interface.
    function __constructor__() external;
}

/// @title LibGameId
/// @notice Utility functions for packing and unpacking GameIds.
library LibGameId {
    /// @notice Packs values into a 32 byte GameId type.
    /// @param _gameType The game type.
    /// @param _timestamp The timestamp of the game's creation.
    /// @param _gameProxy The game proxy address.
    /// @return gameId_ The packed GameId.
    function pack(GameType _gameType, Timestamp _timestamp, address _gameProxy)
        internal
        pure
        returns (GameId gameId_)
    {
        assembly {
            gameId_ := or(or(shl(224, _gameType), shl(160, _timestamp)), _gameProxy)
        }
    }

    /// @notice Unpacks values from a 32 byte GameId type.
    /// @param _gameId The packed GameId.
    /// @return gameType_ The game type.
    /// @return timestamp_ The timestamp of the game's creation.
    /// @return gameProxy_ The game proxy address.
    function unpack(GameId _gameId)
        internal
        pure
        returns (GameType gameType_, Timestamp timestamp_, address gameProxy_)
    {
        assembly {
            gameType_ := shr(224, _gameId)
            timestamp_ := and(shr(160, _gameId), 0xFFFFFFFFFFFFFFFF)
            gameProxy_ := and(_gameId, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }
    }
}

using LibGameId for GameId global;

/// @notice A `GameId` represents a packed 4 byte game ID, a 8 byte timestamp, and a 20 byte address.
/// @dev The packed layout of this type is as follows:
/// ┌───────────┬───────────┐
/// │   Bits    │   Value   │
/// ├───────────┼───────────┤
/// │ [0, 32)   │ Game Type │
/// │ [32, 96)  │ Timestamp │
/// │ [96, 256) │ Address   │
/// └───────────┴───────────┘
type GameId is bytes32;

// lib/optimism/packages/contracts-bedrock/interfaces/dispute/IDisputeGameFactory.sol

interface IDisputeGameFactory is IProxyAdminOwnedBase, IReinitializableBase {
    struct GameSearchResult {
        uint256 index;
        GameId metadata;
        Timestamp timestamp;
        Claim rootClaim;
        bytes extraData;
    }

    error GameAlreadyExists(Hash uuid);
    error IncorrectBondAmount();
    error NoImplementation(GameType gameType);

    event DisputeGameCreated(address indexed disputeProxy, GameType indexed gameType, Claim indexed rootClaim);
    event ImplementationSet(address indexed impl, GameType indexed gameType);
    event ImplementationArgsSet(GameType indexed gameType, bytes args);
    event InitBondUpdated(GameType indexed gameType, uint256 indexed newBond);
    event Initialized(uint8 version);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function create(GameType _gameType, Claim _rootClaim, bytes memory _extraData)
        external
        payable
        returns (IDisputeGame proxy_);
    function findLatestGames(GameType _gameType, uint256 _start, uint256 _n)
        external
        view
        returns (GameSearchResult[] memory games_);
    function gameAtIndex(uint256 _index)
        external
        view
        returns (GameType gameType_, Timestamp timestamp_, IDisputeGame proxy_);
    function gameCount() external view returns (uint256 gameCount_);
    function gameArgs(GameType) external view returns (bytes memory);
    function gameImpls(GameType) external view returns (IDisputeGame);
    function games(GameType _gameType, Claim _rootClaim, bytes memory _extraData)
        external
        view
        returns (IDisputeGame proxy_, Timestamp timestamp_);
    function getGameUUID(GameType _gameType, Claim _rootClaim, bytes memory _extraData)
        external
        pure
        returns (Hash uuid_);
    function initBonds(GameType) external view returns (uint256);
    function initialize(address _owner) external;
    function owner() external view returns (address);
    function renounceOwnership() external;
    function setImplementation(GameType _gameType, IDisputeGame _impl) external;
    function setImplementation(GameType _gameType, IDisputeGame _impl, bytes calldata _args) external;
    function setInitBond(GameType _gameType, uint256 _initBond) external;
    function transferOwnership(address newOwner) external; // nosemgrep
    function version() external view returns (string memory);

    function __constructor__() external;
}

/// @notice Represents an L2 root and the L2 sequence number at which it was generated.
/// @custom:field root The output root.
/// @custom:field l2SequenceNumber The L2 Sequence Number ( e.g. block number / timestamp) at which the root was
/// generated.
struct Proposal {
    Hash root;
    uint256 l2SequenceNumber;
}

// lib/optimism/packages/contracts-bedrock/interfaces/dispute/IAnchorStateRegistry.sol

interface IAnchorStateRegistry is IProxyAdminOwnedBase {
    error AnchorStateRegistry_InvalidAnchorGame();
    error AnchorStateRegistry_Unauthorized();
    error ReinitializableBase_ZeroInitVersion();

    event AnchorUpdated(IFaultDisputeGame indexed game);
    event DisputeGameBlacklisted(IDisputeGame indexed disputeGame);
    event Initialized(uint8 version);
    event RespectedGameTypeSet(GameType gameType);
    event RetirementTimestampSet(uint256 timestamp);

    function initVersion() external view returns (uint8);
    function anchorGame() external view returns (IFaultDisputeGame);
    function anchors(GameType) external view returns (Hash, uint256);
    function blacklistDisputeGame(IDisputeGame _disputeGame) external;
    function disputeGameBlacklist(IDisputeGame) external view returns (bool);
    function getAnchorRoot() external view returns (Hash, uint256);
    function disputeGameFinalityDelaySeconds() external view returns (uint256);
    function disputeGameFactory() external view returns (IDisputeGameFactory);
    function initialize(
        ISystemConfig _systemConfig,
        IDisputeGameFactory _disputeGameFactory,
        Proposal memory _startingAnchorRoot,
        GameType _startingRespectedGameType
    ) external;
    function isGameBlacklisted(IDisputeGame _game) external view returns (bool);
    function isGameProper(IDisputeGame _game) external view returns (bool);
    function isGameRegistered(IDisputeGame _game) external view returns (bool);
    function isGameResolved(IDisputeGame _game) external view returns (bool);
    function isGameRespected(IDisputeGame _game) external view returns (bool);
    function isGameRetired(IDisputeGame _game) external view returns (bool);
    function isGameFinalized(IDisputeGame _game) external view returns (bool);
    function isGameClaimValid(IDisputeGame _game) external view returns (bool);
    function paused() external view returns (bool);
    function respectedGameType() external view returns (GameType);
    function retirementTimestamp() external view returns (uint64);
    function setAnchorState(IDisputeGame _game) external;
    function setRespectedGameType(GameType _gameType) external;
    function systemConfig() external view returns (ISystemConfig);
    function updateRetirementTimestamp() external;
    function version() external view returns (string memory);
    function superchainConfig() external view returns (ISuperchainConfig);

    function __constructor__(uint256 _disputeGameFinalityDelaySeconds) external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/L1/IETHLockbox.sol

interface IETHLockbox is IProxyAdminOwnedBase, ISemver, IReinitializableBase {
    error ETHLockbox_Unauthorized();
    error ETHLockbox_Paused();
    error ETHLockbox_InsufficientBalance();
    error ETHLockbox_NoWithdrawalTransactions();
    error ETHLockbox_DifferentSuperchainConfig();

    event Initialized(uint8 version);
    event ETHLocked(IOptimismPortal2 indexed portal, uint256 amount);
    event ETHUnlocked(IOptimismPortal2 indexed portal, uint256 amount);
    event PortalAuthorized(IOptimismPortal2 indexed portal);
    event LockboxAuthorized(IETHLockbox indexed lockbox);
    event LiquidityMigrated(IETHLockbox indexed lockbox, uint256 amount);
    event LiquidityReceived(IETHLockbox indexed lockbox, uint256 amount);

    function initialize(ISystemConfig _systemConfig, IOptimismPortal2[] calldata _portals) external;
    function systemConfig() external view returns (ISystemConfig);
    function paused() external view returns (bool);
    function authorizedPortals(IOptimismPortal2) external view returns (bool);
    function authorizedLockboxes(IETHLockbox) external view returns (bool);
    function receiveLiquidity() external payable;
    function lockETH() external payable;
    function unlockETH(uint256 _value) external;
    function authorizePortal(IOptimismPortal2 _portal) external;
    function authorizeLockbox(IETHLockbox _lockbox) external;
    function migrateLiquidity(IETHLockbox _lockbox) external;
    function superchainConfig() external view returns (ISuperchainConfig);

    function __constructor__() external;
}

// lib/optimism/packages/contracts-bedrock/interfaces/L1/IOptimismPortal2.sol

interface IOptimismPortal2 is IProxyAdminOwnedBase {
    error ContentLengthMismatch();
    error EmptyItem();
    error InvalidDataRemainder();
    error InvalidHeader();
    error ReinitializableBase_ZeroInitVersion();
    error OptimismPortal_AlreadyFinalized();
    error OptimismPortal_BadTarget();
    error OptimismPortal_CallPaused();
    error OptimismPortal_CalldataTooLarge();
    error OptimismPortal_GasEstimation();
    error OptimismPortal_GasLimitTooLow();
    error OptimismPortal_ImproperDisputeGame();
    error OptimismPortal_InvalidDisputeGame();
    error OptimismPortal_InvalidMerkleProof();
    error OptimismPortal_InvalidOutputRootProof();
    error OptimismPortal_InvalidProofTimestamp();
    error OptimismPortal_InvalidRootClaim();
    error OptimismPortal_NoReentrancy();
    error OptimismPortal_ProofNotOldEnough();
    error OptimismPortal_Unproven();
    error OptimismPortal_InvalidLockboxState();
    error OutOfGas();
    error UnexpectedList();
    error UnexpectedString();

    event Initialized(uint8 version);
    event TransactionDeposited(address indexed from, address indexed to, uint256 indexed version, bytes opaqueData);
    event WithdrawalFinalized(bytes32 indexed withdrawalHash, bool success);
    event WithdrawalProven(bytes32 indexed withdrawalHash, address indexed from, address indexed to);
    event WithdrawalProvenExtension1(bytes32 indexed withdrawalHash, address indexed proofSubmitter);

    receive() external payable;

    function anchorStateRegistry() external view returns (IAnchorStateRegistry);
    function ethLockbox() external view returns (IETHLockbox);
    function checkWithdrawal(bytes32 _withdrawalHash, address _proofSubmitter) external view;
    function depositTransaction(address _to, uint256 _value, uint64 _gasLimit, bool _isCreation, bytes memory _data)
        external
        payable;
    function disputeGameBlacklist(IDisputeGame _disputeGame) external view returns (bool);
    function disputeGameFactory() external view returns (IDisputeGameFactory);
    function disputeGameFinalityDelaySeconds() external view returns (uint256);
    function donateETH() external payable;
    function superchainConfig() external view returns (ISuperchainConfig);
    function finalizeWithdrawalTransaction(Types.WithdrawalTransaction memory _tx) external;
    function finalizeWithdrawalTransactionExternalProof(Types.WithdrawalTransaction memory _tx, address _proofSubmitter)
        external;
    function finalizedWithdrawals(bytes32) external view returns (bool);
    function guardian() external view returns (address);
    function initialize(ISystemConfig _systemConfig, IAnchorStateRegistry _anchorStateRegistry) external;
    function initVersion() external view returns (uint8);
    function l2Sender() external view returns (address);
    function minimumGasLimit(uint64 _byteCount) external pure returns (uint64);
    function numProofSubmitters(bytes32 _withdrawalHash) external view returns (uint256);
    function params() external view returns (uint128 prevBaseFee, uint64 prevBoughtGas, uint64 prevBlockNum); // nosemgrep
    function paused() external view returns (bool);
    function proofMaturityDelaySeconds() external view returns (uint256);
    function proofSubmitters(bytes32, uint256) external view returns (address);
    function proveWithdrawalTransaction(
        Types.WithdrawalTransaction memory _tx,
        uint256 _disputeGameIndex,
        Types.OutputRootProof memory _outputRootProof,
        bytes[] memory _withdrawalProof
    ) external;
    function provenWithdrawals(bytes32, address)
        external
        view
        returns (IDisputeGame disputeGameProxy, uint64 timestamp);
    function respectedGameType() external view returns (GameType);
    function respectedGameTypeUpdatedAt() external view returns (uint64);
    function systemConfig() external view returns (ISystemConfig);
    function version() external pure returns (string memory);

    function __constructor__(uint256 _proofMaturityDelaySeconds) external;
}

library KailuaKZGLib {
    /// @notice The KZG commitment version
    bytes32 internal constant KZG_COMMITMENT_VERSION =
        bytes32(0x0100000000000000000000000000000000000000000000000000000000000000);

    /// @notice The modular exponentiation precompile
    address internal constant MOD_EXP = address(0x05);

    /// @notice The point evaluation precompile
    address internal constant KZG = address(0x0a);

    /// @notice The expected result from the point evaluation precompile
    bytes32 internal constant KZG_RESULT = keccak256(abi.encodePacked(FIELD_ELEMENTS_PER_BLOB, BLS_MODULUS));

    /// @notice Scalar field modulus of BLS12-381
    uint256 internal constant BLS_MODULUS =
        52435875175126190479447740508185965837690552500527637822603658699938581184513;

    /// @notice The base root of unity for indexing blob field elements
    uint256 internal constant ROOT_OF_UNITY =
        39033254847818212395286706435128746857159659164139250548781411570340225835782;

    /// @notice The po2 for the number of field elements in a single blob
    uint256 internal constant FIELD_ELEMENTS_PER_BLOB_PO2 = 12;

    /// @notice The number of field elements in a single blob
    uint256 internal constant FIELD_ELEMENTS_PER_BLOB = uint64(1 << FIELD_ELEMENTS_PER_BLOB_PO2);

    /// @notice The index of the blob containing the FE at the provided offset
    function blobIndex(uint256 outputOffset) internal pure returns (uint256 index) {
        index = outputOffset / FIELD_ELEMENTS_PER_BLOB;
    }

    /// @notice The index of the FE at the provided offset in the blob that contains it
    function fieldElementIndex(uint256 outputOffset) internal pure returns (uint32 position) {
        position = uint32(outputOffset % FIELD_ELEMENTS_PER_BLOB);
    }

    /// @notice The versioned KZG hash of the provided blob commitment
    function versionedKZGHash(bytes calldata blobCommitment) internal pure returns (bytes32 hash) {
        require(blobCommitment.length == 48);
        hash = ((sha256(blobCommitment) << 8) >> 8) | KZG_COMMITMENT_VERSION;
    }

    /// @notice The mapped FE corresponding to the input hash
    function hashToFe(bytes32 hash) internal pure returns (uint256 fe) {
        fe = uint256(hash) % BLS_MODULUS;
    }

    /// @notice Returns true iff the proof shows that the FE is part of the blob at the provided position
    function verifyKZGBlobProof(
        bytes32 versionedBlobHash,
        uint32 index,
        uint256 value,
        bytes calldata blobCommitment,
        bytes calldata proof
    ) internal view returns (bool success) {
        uint256 rootOfUnity = modExp(reverseBits(index));
        // Byte range	Name	        Description
        // [0:32]	    versioned_hash	Reference to a blob in the execution layer.
        // [32:64]	    x	            x-coordinate at which the blob is being evaluated.
        // [64:96]	    y	            y-coordinate at which the blob is being evaluated.
        // [96:144]	    commitment	    Commitment to the blob being evaluated.
        // [144:192]	proof	        Proof associated with the commitment.
        bytes memory kzgCallData = abi.encodePacked(versionedBlobHash, rootOfUnity, value, blobCommitment, proof);
        // The precompile will reject non-canonical field elements (i.e. value must be less than BLS_MODULUS).
        (bool _success, bytes memory kzgResult) = KZG.staticcall(kzgCallData);
        // Validate the precompile response
        require(keccak256(kzgResult) == KZG_RESULT);
        // Return the result
        success = _success;
    }

    /// @notice Calls the modular exponentiation precompile with a fixed base and modulus
    function modExp(uint256 exponent) internal view returns (uint256 result) {
        bytes memory modExpData =
            abi.encodePacked(uint256(32), uint256(32), uint256(32), ROOT_OF_UNITY, exponent, BLS_MODULUS);
        (bool success, bytes memory mexpResult) = MOD_EXP.staticcall(modExpData);
        require(success);
        result = uint256(bytes32(mexpResult));
    }

    /// @notice Reverses the bits of the input index
    function reverseBits(uint32 index) internal pure returns (uint256 result) {
        for (uint256 i = 0; i < FIELD_ELEMENTS_PER_BLOB_PO2; i++) {
            result <<= 1;
            result |= ((1 << i) & index) >> i;
        }
    }
}

////////////////////////////////////////////////////////////////
//                 `FaultDisputeGame` Errors                  //
////////////////////////////////////////////////////////////////

/// @notice Thrown when a dispute game has already been initialized.
error AlreadyInitialized();

// 0xd36871fd
/// @notice Thrown when a blacklisted address attempts to interact with the game.
error Blacklisted(address source, address expected);

// 0x9d3e7d24
/// @notice Thrown when a child from an unknown source appends itself to a tournament
error UnknownGame();

/// @notice Thrown when a step is attempted above the maximum game depth.
error InvalidParent();

/// @notice Thrown when resolving a claim that has already been resolved.
error ClaimAlreadyResolved();

// 0x2c06a364
/// @notice Thrown when a proof is submitted for an already proven game
error AlreadyProven();

/// @notice Thrown when the game is not yet resolved.
error GameNotResolved();

// 0xf2a87d5e
/// @notice Thrown when pruning is attempted with no children
error NotProposed();

/// @notice Thrown when an action that requires the game to be `IN_PROGRESS` is invoked when
///         the game is not in progress.
error GameNotInProgress();

/// @notice Thrown when a disputed claim does not match its index in the game.
error InvalidDisputedClaimIndex();

// 0x7412124e
/// @notice Thrown when proving is attempted with two agreeing outputs
error NoConflict();

// src/KailuaTournament.sol
// Copyright 2024, 2025 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/// @notice Thrown when a proposal contains invalid trailing data
error InvalidDataRemainder();

abstract contract KailuaTournament is IKailuaTournament, Clone, IDisputeGame {
    // ------------------------------
    // Immutable configuration
    // ------------------------------

    /// @notice The Kailua Treasury Implementation contract address
    IKailuaTreasury public immutable KAILUA_TREASURY;

    /// @notice The Kailua Verifier contract
    KailuaVerifier public immutable KAILUA_VERIFIER;

    /// @notice The number of outputs a proposal must publish
    uint64 public immutable PROPOSAL_OUTPUT_COUNT;

    /// @notice The number of blocks each output must cover
    uint64 public immutable OUTPUT_BLOCK_SPAN;

    /// @notice The number of blobs a claim must provide
    uint64 public immutable PROPOSAL_BLOBS;

    /// @notice The game type ID
    GameType public immutable GAME_TYPE;

    /// @notice The OptimismPortal2 instance
    IOptimismPortal2 public immutable OPTIMISM_PORTAL;

    /// @notice The DisputeGameFactory instance
    IDisputeGameFactory public immutable DISPUTE_GAME_FACTORY;

    constructor(
        IKailuaTreasury _kailuaTreasury,
        KailuaVerifier _kailuaVerifier,
        uint64 _proposalOutputCount,
        uint64 _outputBlockSpan,
        GameType _gameType,
        IOptimismPortal2 _optimismPortal
    ) {
        KAILUA_TREASURY = _kailuaTreasury;
        KAILUA_VERIFIER = _kailuaVerifier;
        PROPOSAL_OUTPUT_COUNT = _proposalOutputCount;
        OUTPUT_BLOCK_SPAN = _outputBlockSpan;
        // discard published root commitment in calldata
        _proposalOutputCount--;
        PROPOSAL_BLOBS = (_proposalOutputCount / uint64(KailuaKZGLib.FIELD_ELEMENTS_PER_BLOB))
            + ((_proposalOutputCount % uint64(KailuaKZGLib.FIELD_ELEMENTS_PER_BLOB)) == 0 ? 0 : 1);
        GAME_TYPE = _gameType;
        OPTIMISM_PORTAL = _optimismPortal;
        DISPUTE_GAME_FACTORY = OPTIMISM_PORTAL.disputeGameFactory();
    }

    function initializeInternal() internal {
        // INVARIANT: The game must not have already been initialized.
        if (createdAt.raw() > 0) {
            revert AlreadyInitialized();
        }

        // Allow only the treasury to create new games
        if (gameCreator() != address(KAILUA_TREASURY)) {
            revert Blacklisted(gameCreator(), address(KAILUA_TREASURY));
        }

        // Set the game's starting timestamp
        createdAt = Timestamp.wrap(uint64(block.timestamp));

        // Set the game's index in the factory
        gameIndex = DISPUTE_GAME_FACTORY.gameCount();

        // Read respected status
        wasRespectedGameTypeWhenCreated = OPTIMISM_PORTAL.respectedGameType().raw() == GAME_TYPE.raw();
    }

    // ------------------------------
    // Game State
    // ------------------------------

    /// @notice The blob hashes used to create the game
    Hash[] public proposalBlobHashes;

    /// @notice The game's index in the factory
    uint256 public gameIndex;

    /// @notice The address of the prover of a proposal signature
    mapping(bytes32 => address) public prover;

    /// @notice The timestamp of when the first proof for a proposal signature was made
    mapping(bytes32 => Timestamp) public provenAt;

    /// @notice The current proof status of a proposal signature
    mapping(bytes32 => ProofStatus) public proofStatus;

    /// @notice The proposals extending this proposal
    KailuaTournament[] public children;

    /// @notice The first surviving contender
    uint64 public contenderIndex;

    /// @notice Duplicates of the last surviving contender proposal
    uint64[] public contenderDuplicates;

    /// @notice The next unprocessed opponent
    uint64 public opponentIndex;

    /// @notice The signature of the child accepted through a validity proof
    bytes32 public validChildSignature;

    /// @notice Returns the hash of the output claim and all blob hashes associated with this proposal
    function signature() public view returns (bytes32 signature_) {
        // note: the absence of the l1Head in the signature implies that
        // proofs will eventually demonstrate derivation
        signature_ = sha256(abi.encodePacked(rootClaim().raw(), proposalBlobHashes));
    }

    /// @notice Returns whether a child can be considered valid
    function isViableSignature(bytes32 childSignature) public view returns (bool isViableSignature_) {
        if (validChildSignature != 0) {
            isViableSignature_ = childSignature == validChildSignature;
        } else {
            isViableSignature_ = proofStatus[childSignature] != ProofStatus.FAULT;
        }
    }

    /// @notice Returns the address of the prover of the specified signature or the prover of the valid signature
    function getPayoutRecipient(bytes32 childSignature) internal view returns (address payoutRecipient) {
        // The successful exclusive permit owner receives the payout.
        payoutRecipient = KAILUA_VERIFIER.faultProofPermitBeneficiary(IKailuaTournament(this), childSignature);
        // If none exists, then the successful fault prover is the recipient.
        if (payoutRecipient == address(0x0)) {
            payoutRecipient = prover[childSignature];
        }
        // Otherwise, the successful validity prover receives the payout.
        if (payoutRecipient == address(0x0)) {
            payoutRecipient = prover[validChildSignature];
        }
        // Otherwise the child signature is viable and there is no recipient.
    }

    /// @notice Returns true iff the child proposal was eliminated
    function isChildEliminated(KailuaTournament child) internal view returns (bool) {
        address _proposer = KAILUA_TREASURY.proposerOf(address(child));
        uint256 eliminationRound = KAILUA_TREASURY.eliminationRound(_proposer);
        if (eliminationRound == 0 || eliminationRound > child.gameIndex()) {
            // This proposer has not been eliminated as of their proposal at gameIndex
            return false;
        }
        return true;
    }

    /// @notice Returns the number of children
    function childCount() external view returns (uint256 count_) {
        count_ = children.length;
    }

    /// @notice Registers a new proposal that extends this one
    function appendChild() external {
        // INVARIANT: The calling contract is a newly deployed contract by the dispute game factory
        if (!KAILUA_TREASURY.isProposing()) {
            revert UnknownGame();
        }

        // INVARIANT: The calling KailuaGame contract is not referring to itself as a parent
        if (msg.sender == address(this)) {
            revert InvalidParent();
        }

        // INVARIANT: No longer accept proposals after resolution
        if (contenderIndex < children.length && children[contenderIndex].status() == GameStatus.DEFENDER_WINS) {
            revert ClaimAlreadyResolved();
        }

        // Append new child to children list
        children.push(KailuaTournament(msg.sender));
    }

    /// @notice Returns the amount of time left for challenges as of the input timestamp.
    function getChallengerDuration(uint256 asOfTimestamp) public view virtual returns (Duration duration_);

    /// @notice Returns the earliest time at which this proposal could have been created
    function minCreationTime() public view virtual returns (Timestamp minCreationTime_);

    /// @notice Returns the parent game contract.
    function parentGame() public view virtual returns (KailuaTournament parentGame_);

    /// @notice Returns the proposer address
    function proposer() public view returns (address proposer_) {
        proposer_ = KAILUA_TREASURY.proposerOf(address(this));
    }

    /// @notice Verifies that an intermediate output was part of the proposal
    function verifyIntermediateOutput(
        uint64 outputNumber,
        uint256 outputFe,
        bytes calldata blobCommitment,
        bytes calldata kzgProof
    ) external virtual returns (bool success);

    /// @notice Updates the provability of a child signature if not already set
    function updateProofStatus(address payoutRecipient, bytes32 childSignature, ProofStatus outcome) internal {
        // INVARIANT: Proofs can only be submitted once
        if (proofStatus[childSignature] != ProofStatus.NONE) {
            revert AlreadyProven();
        }

        // Update proof status
        proofStatus[childSignature] = outcome;

        // Announce proof status
        emit Proven(childSignature, outcome);

        // Set the game's prover address
        prover[childSignature] = payoutRecipient;

        // Set the game's proving timestamp
        provenAt[childSignature] = Timestamp.wrap(uint64(block.timestamp));
    }

    // ------------------------------
    // IDisputeGame implementation
    // ------------------------------

    /// @inheritdoc IDisputeGame
    Timestamp public createdAt;

    /// @inheritdoc IDisputeGame
    Timestamp public resolvedAt;

    /// @inheritdoc IDisputeGame
    GameStatus public status;

    /// @inheritdoc IDisputeGame
    function gameType() external view returns (GameType gameType_) {
        gameType_ = GAME_TYPE;
    }

    /// @inheritdoc IDisputeGame
    function gameCreator() public pure returns (address creator_) {
        creator_ = _getArgAddress(0x00);
    }

    /// @inheritdoc IDisputeGame
    function rootClaim() public pure returns (Claim rootClaim_) {
        rootClaim_ = Claim.wrap(_getArgBytes32(0x14));
    }

    /// @inheritdoc IDisputeGame
    function l1Head() public pure returns (Hash l1Head_) {
        l1Head_ = Hash.wrap(_getArgBytes32(0x34));
    }

    /// @notice The l2BlockNumber of the claim's output root.
    function l2BlockNumber() public pure returns (uint256 l2BlockNumber_) {
        l2BlockNumber_ = uint256(_getArgUint64(0x54));
    }

    /// @inheritdoc IDisputeGame
    function l2SequenceNumber() public pure returns (uint256 l2SequenceNumber_) {
        l2SequenceNumber_ = l2BlockNumber();
    }

    /// @inheritdoc IDisputeGame
    function gameData() external view returns (GameType gameType_, Claim rootClaim_, bytes memory extraData_) {
        gameType_ = GAME_TYPE;
        rootClaim_ = this.rootClaim();
        extraData_ = this.extraData();
    }

    /// @notice True iff the Kailua GameType was respected by OptimismPortal at time of creation
    bool public wasRespectedGameTypeWhenCreated;

    /// @notice This is a workaround for withdrawal compatibility under op-contracts v5.0.0
    function anchorStateRegistry() external view returns (address registry_) {
        registry_ = msg.sender;
    }

    // ------------------------------
    // Tournament
    // ------------------------------

    /// @notice Eliminates children until at least one remains
    function pruneChildren(uint256 stepLimit) external returns (KailuaTournament) {
        // INVARIANT: Only finalized proposals may prune tournaments
        if (status != GameStatus.DEFENDER_WINS) {
            revert GameNotResolved();
        }

        // INVARIANT: No tournament to play without at least one child
        if (children.length == 0) {
            revert NotProposed();
        }

        // Resume from prior surviving contender
        uint64 u = contenderIndex;
        // Resume from prior unprocessed opponent
        uint64 v = opponentIndex;
        // Abort if out of bounds
        if (u == children.length) {
            return KailuaTournament(address(0x0));
        }
        // Advance v if needed
        if (v <= u) {
            // INVARIANT: contenderDuplicates is empty
            v = u + 1;
        }

        // Note: u < children.length
        // Fetch contender details
        KailuaTournament contender = children[u];
        bytes32 contenderSignature = contender.signature();

        // Ensure survivor decision finality after resolution
        if (contender.status() == GameStatus.DEFENDER_WINS) {
            return contender;
        }

        // If the contender is invalid then we eliminate it and find the next viable contender using the opponent
        // pointer. This search could terminate early if the elimination limit is reached.
        // If the contender is valid and its proposer is not eliminated, this is skipped.
        if (!isViableSignature(contenderSignature) || isChildEliminated(contender)) {
            // INVARIANT: If branch entered through isChildEliminated condition, contenderDuplicates is empty

            // Eliminate duplicates
            address payoutRecipient = getPayoutRecipient(contenderSignature);
            for (uint256 i = contenderDuplicates.length; i > 0 && stepLimit > 0; (i--, stepLimit--)) {
                KailuaTournament duplicate = children[contenderDuplicates[i - 1]];
                if (!isChildEliminated(duplicate)) {
                    KAILUA_TREASURY.eliminate(address(duplicate), payoutRecipient);
                }
                contenderDuplicates.pop();
            }

            // Abort if elimination allowance exhausted before eliminating all duplicate contenders
            if (stepLimit == 0) {
                return KailuaTournament(address(0x0));
            }

            // Eliminate contender
            if (!isChildEliminated(contender)) {
                KAILUA_TREASURY.eliminate(address(contender), payoutRecipient);
            }
            stepLimit--;

            // Find next viable contender
            // INVARIANT: v > max(u, contenderDuplicates);
            u = v;
            for (; u < children.length && stepLimit > 0; (u++, stepLimit--)) {
                // Skip if previously eliminated
                contender = children[u];
                if (isChildEliminated(contender)) {
                    continue;
                }
                // Eliminate if faulty
                contenderSignature = contender.signature();
                if (!isViableSignature(contenderSignature)) {
                    // eliminate the unviable contender
                    KAILUA_TREASURY.eliminate(address(contender), getPayoutRecipient(contenderSignature));
                    continue;
                }
                // Select u as next viable contender
                break;
            }
            // Store contender
            contenderIndex = u;
            // Select the next possible opponent
            v = u + 1;
        }

        // Eliminate faulty opponents if we've landed on a viable contender
        if (u < children.length && isViableSignature(children[u].signature())) {
            // Iterate over opponents to eliminate them
            for (; v < children.length && stepLimit > 0; (v++, stepLimit--)) {
                KailuaTournament opponent = children[v];
                // If the contender hasn't been challenged for as long as the timeout, declare them winner
                if (contender.getChallengerDuration(opponent.createdAt().raw()).raw() == 0) {
                    // Note: This implies eliminationLimit > 0
                    break;
                }
                // If the opponent proposer is eliminated, skip
                if (isChildEliminated(opponent)) {
                    continue;
                }
                // Append contender duplicate
                bytes32 opponentSignature = opponent.signature();
                if (opponentSignature == contenderSignature) {
                    contenderDuplicates.push(v);
                    continue;
                }
                // If there is insufficient proof data, abort
                // Validity: The contender is the proven child, the opponent must be incorrect
                // Fault: The contender is not proven faulty, the opponent may (not) be.
                if (isViableSignature(opponentSignature)) {
                    revert NotProven();
                }
                // eliminate the opponent with the unviable proposal
                KAILUA_TREASURY.eliminate(address(opponent), getPayoutRecipient(opponentSignature));
            }

            // INVARIANT: v > u && contender == children[u]
            // Record incremental opponent elimination progress
            opponentIndex = v;

            // Return the sole survivor if no more matches can be played
            if (v == children.length || stepLimit > 0) {
                return contender;
            }
        }

        // No survivor yet
        return KailuaTournament(address(0x0));
    }

    // ------------------------------
    // Validity proving
    // ------------------------------

    /// @notice Returns the hash of all blob hashes associated with this proposal
    function blobsHash() public view returns (bytes32 blobsHash_) {
        blobsHash_ = sha256(abi.encodePacked(proposalBlobHashes));
    }

    /// @notice Proves that a proposal is valid
    function proveValidity(address payoutRecipient, address l1HeadSource, uint64 childIndex, bytes calldata encodedSeal)
        external
    {
        KailuaTournament childContract = children[childIndex];
        // INVARIANT: Can only prove validity of unresolved proposals
        if (childContract.status() != GameStatus.IN_PROGRESS) {
            revert GameNotInProgress();
        }

        // Store validity proof data (deleted on revert)
        validChildSignature = childContract.signature();

        // INVARIANT: No longer accept proofs after resolution
        if (contenderIndex < children.length && children[contenderIndex].status() == GameStatus.DEFENDER_WINS) {
            revert ClaimAlreadyResolved();
        }

        // Calculate the expected precondition hash if blob data is necessary for proposal
        bytes32 preconditionHash = bytes32(0x0);
        if (PROPOSAL_OUTPUT_COUNT > 1) {
            preconditionHash = sha256(
                abi.encodePacked(
                    uint64(l2BlockNumber()),
                    uint64(PROPOSAL_OUTPUT_COUNT),
                    uint64(OUTPUT_BLOCK_SPAN),
                    childContract.blobsHash()
                )
            );
        }

        // update proof status
        prove(
            l1HeadSource,
            payoutRecipient,
            preconditionHash,
            rootClaim().raw(),
            childContract.rootClaim().raw(),
            PROPOSAL_OUTPUT_COUNT,
            encodedSeal,
            validChildSignature,
            ProofStatus.VALIDITY
        );
    }

    // ------------------------------
    // Fault proving
    // ------------------------------

    /// @notice Proves that a proposal committed to an incorrect transition
    function proveOutputFault(
        // [ payoutRecipient, l1HeadSource ]
        address[2] calldata prHs,
        // [ childIndex, outputOffset ]
        uint64[2] calldata co,
        bytes calldata encodedSeal,
        // [ acceptedOutputHash, computedOutputHash ]
        bytes32[2] memory ac,
        uint256 proposedOutputFe,
        bytes[][2] calldata kzgCommitmentsProofs
    ) external {
        KailuaTournament childContract = children[co[0]];
        // INVARIANT: Proofs cannot be submitted unless the child is playing.
        if (childContract.status() != GameStatus.IN_PROGRESS) {
            revert GameNotInProgress();
        }

        // INVARIANT: No longer accept proofs after resolution
        if (contenderIndex < children.length && children[contenderIndex].status() == GameStatus.DEFENDER_WINS) {
            revert ClaimAlreadyResolved();
        }

        // INVARIANT: Proofs can only pertain to intermediate outputs
        if (co[1] >= PROPOSAL_OUTPUT_COUNT) {
            revert InvalidDisputedClaimIndex();
        }

        // Validate the common output root.
        if (co[1] == 0) {
            // Note: acceptedOutputHash cannot be a reduced fe because the comparison below will fail
            // The safe output is the parent game's output when proving the first output
            require(ac[0] == rootClaim().raw(), "bad acceptedOutput");
        } else {
            // Note: acceptedOutputHash cannot be a reduced fe because the journal would not be provable
            // Prove common output publication
            require(
                childContract.verifyIntermediateOutput(
                    co[1] - 1, KailuaKZGLib.hashToFe(ac[0]), kzgCommitmentsProofs[0][0], kzgCommitmentsProofs[1][0]
                ),
                "bad acceptedOutput kzg"
            );
        }

        // Validate the claimed output root.
        if (co[1] == PROPOSAL_OUTPUT_COUNT - 1) {
            // INVARIANT: Proofs can only show disparities
            if (ac[1] == childContract.rootClaim().raw()) {
                revert NoConflict();
            }
        } else {
            // Note: proposedOutputFe must be a canonical point or point eval precompile call will fail
            // Prove divergent output publication
            require(
                childContract.verifyIntermediateOutput(
                    co[1],
                    proposedOutputFe,
                    kzgCommitmentsProofs[0][kzgCommitmentsProofs[0].length - 1],
                    kzgCommitmentsProofs[1][kzgCommitmentsProofs[1].length - 1]
                ),
                "bad proposedOutput kzg"
            );
            // INVARIANT: Proofs can only show disparities
            if (KailuaKZGLib.hashToFe(ac[1]) == proposedOutputFe) {
                revert NoConflict();
            }
        }

        // update proof status
        prove(
            prHs[1],
            prHs[0],
            bytes32(0),
            ac[0],
            ac[1],
            co[1] + 1,
            encodedSeal,
            childContract.signature(),
            ProofStatus.FAULT
        );
    }

    /// @notice Proves that a proposal contains invalid intermediate data
    function proveTrailFault(
        address payoutRecipient,
        uint64[2] calldata co,
        uint256 proposedOutputFe,
        bytes calldata blobCommitment,
        bytes calldata kzgProof
    ) external {
        KailuaTournament childContract = children[co[0]];
        // INVARIANT: Proofs cannot be submitted unless the children are playing.
        if (childContract.status() != GameStatus.IN_PROGRESS) {
            revert GameNotInProgress();
        }

        // INVARIANT: No longer accept proofs after resolution
        if (contenderIndex < children.length && children[contenderIndex].status() == GameStatus.DEFENDER_WINS) {
            revert ClaimAlreadyResolved();
        }

        // INVARIANT: Proofs can only pertain to trail data
        if (co[1] < PROPOSAL_OUTPUT_COUNT) {
            revert InvalidDisputedClaimIndex();
        }

        // We expect all trail data to be zeroed
        if (proposedOutputFe == 0) {
            revert NoConflict();
        }

        // Because the root claim is considered the last published output, we shift the provided  output offset down by
        // one to correctly point to the target trailing zero output
        // INVARIANT: The divergence occurs in the last blob
        uint64 feOffset = co[1] - 1;
        if (KailuaKZGLib.blobIndex(feOffset) != PROPOSAL_BLOBS - 1) {
            revert InvalidDataRemainder();
        }

        // Validate the claimed output root publications
        // Note: proposedOutputFe must be a canonical field element or point eval precompile call will fail
        require(
            childContract.verifyIntermediateOutput(feOffset, proposedOutputFe, blobCommitment, kzgProof),
            "bad proposedOutput kzg"
        );

        // Update dispute status based on trailing data
        updateProofStatus(payoutRecipient, childContract.signature(), ProofStatus.FAULT);
    }

    // ------------------------------
    // ZK Proving
    // ------------------------------

    /// @notice Verifies a ZK proof and updates the proof status according to the provided outcome if the proof is valid
    function prove(
        address l1HeadSource,
        address payoutRecipient,
        bytes32 preconditionHash,
        bytes32 acceptedOutputHash,
        bytes32 computedOutputHash,
        uint64 outputCount,
        bytes calldata encodedSeal,
        bytes32 childSignature,
        ProofStatus outcome
    ) internal {
        // Validate the l1Head source
        if (KAILUA_TREASURY.proposerOf(l1HeadSource) == address(0x0)) {
            revert UnknownGame();
        }

        // Revert on proof verification failure
        KAILUA_VERIFIER.verify(
            // The address of the recipient of the payout for this proof
            payoutRecipient,
            // The blob equivalence precondition hash
            preconditionHash,
            // The L1 head hash containing the safe L2 chain data that may reproduce the L2 head hash.
            KailuaTournament(l1HeadSource).l1Head().raw(),
            // The accepted output
            acceptedOutputHash,
            // The proposed output
            computedOutputHash,
            // The claim block number
            uint64(l2BlockNumber() + outputCount * OUTPUT_BLOCK_SPAN),
            // The cryptographic proof
            encodedSeal
        );

        // Mark the child as proven
        updateProofStatus(payoutRecipient, childSignature, outcome);
    }
}

/// @notice Thrown when the `extraData` passed to the CWIA proxy is of improper length, or contains invalid information.
error BadExtraData();

/// @notice Thrown when the root claim has an unexpected VM status.
///         Some games can only start with a root-claim with a specific status.
/// @param rootClaim is the claim that was unexpected.
error UnexpectedRootClaim(Claim rootClaim);

// 0xeaa0996e
/// @notice Occurs when the anchored game block number is different
/// @param anchored The L2 block number of the anchored game
/// @param initialized This game's l2 block number
error BlockNumberMismatch(uint256 anchored, uint256 initialized);

// 0x428e0b92
/// @notice Thrown when a non-factory owner calls an owner-only function.
error NotFactoryOwner();

////////////////////////////////////////////////////////////////
//              `PermissionedDisputeGame` Errors              //
////////////////////////////////////////////////////////////////

/// @notice Thrown when an unauthorized address attempts to interact with the game.
error BadAuth();

// 0x627fad6e
/// @notice Occurs when a proposer attempts to extend the chain before the vanguard
/// @param parentGame The address of the parent proposal being extended
error VanguardError(address parentGame);

// src/KailuaTreasury.sol
// Copyright 2024, 2025 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
contract KailuaTreasury is KailuaTournament, IKailuaTreasury {
    /// @notice Semantic version.
    /// @custom:semver 1.2.0
    string public constant version = "1.2.0";

    // ------------------------------
    // Immutable configuration
    // ------------------------------

    /// @notice The initial root claim for the deployment
    Claim public immutable ROOT_CLAIM;

    /// @notice The L2 block number of the initial root claim for the deployment
    uint64 public immutable L2_BLOCK_NUMBER;

    constructor(
        KailuaVerifier _kailuaVerifier,
        uint64 _proposalOutputCount,
        uint64 _outputBlockSpan,
        GameType _gameType,
        IOptimismPortal2 _optimismPortal,
        Claim _rootClaim,
        uint64 _l2BlockNumber
    )
        KailuaTournament(
            KailuaTreasury(this),
            _kailuaVerifier,
            _proposalOutputCount,
            _outputBlockSpan,
            _gameType,
            _optimismPortal
        )
    {
        ROOT_CLAIM = _rootClaim;
        L2_BLOCK_NUMBER = _l2BlockNumber;
    }

    // ------------------------------
    // IInitializable implementation
    // ------------------------------

    function initialize() external payable override {
        super.initializeInternal();

        // Revert if the calldata size is not the expected length.
        //
        // This is to prevent adding extra or omitting bytes from to `extraData` that result in a different game UUID
        // in the factory, but are not used by the game, which would allow for multiple dispute games for the same
        // output proposal to be created.
        //
        // Expected length: 0x76
        // - 0x04 selector                      0x00 0x04
        // - 0x14 creator address               0x04 0x18
        // - 0x20 root claim                    0x18 0x38
        // - 0x20 l1 head                       0x38 0x58
        // - 0x1c extraData:                    0x58 0x74
        //      + 0x08 l2BlockNumber            0x58 0x60
        //      + 0x14 kailuaTreasuryAddress    0x60 0x74
        // - 0x02 CWIA bytes                    0x74 0x76
        if (msg.data.length != 0x76) {
            revert BadExtraData();
        }

        // Accept only the initialized root claim
        if (rootClaim().raw() != ROOT_CLAIM.raw()) {
            revert UnexpectedRootClaim(rootClaim());
        }

        // Accept only the initialized l2 block number
        if (l2BlockNumber() != L2_BLOCK_NUMBER) {
            revert BlockNumberMismatch(l2BlockNumber(), L2_BLOCK_NUMBER);
        }

        // Accept only the address of the deployment treasury
        if (treasuryAddress() != address(KAILUA_TREASURY)) {
            revert BadExtraData();
        }
    }

    /// @notice Returns the treasury address used in initialization
    function treasuryAddress() public pure returns (address treasuryAddress_) {
        treasuryAddress_ = _getArgAddress(0x5c);
    }

    // ------------------------------
    // IDisputeGame implementation
    // ------------------------------

    /// @inheritdoc IDisputeGame
    function extraData() external pure returns (bytes memory extraData_) {
        // The extra data starts at the second word within the cwia calldata and
        // is 32 bytes long.
        extraData_ = _getArgBytes(0x54, 0x1c);
    }

    /// @inheritdoc IDisputeGame
    function resolve() external onlyFactoryOwner returns (GameStatus status_) {
        // INVARIANT: Resolution cannot occur unless the game is currently in progress.
        if (status != GameStatus.IN_PROGRESS) {
            revert GameNotInProgress();
        }

        // Update the status and emit the resolved event, note that we're performing a storage update here.
        emit Resolved(status = status_ = GameStatus.DEFENDER_WINS);

        // Mark resolution timestamp
        resolvedAt = Timestamp.wrap(uint64(block.timestamp));

        // Update lastResolved
        KAILUA_TREASURY.updateLastResolved();
    }

    // ------------------------------
    // Fault proving
    // ------------------------------

    /// @inheritdoc KailuaTournament
    function verifyIntermediateOutput(uint64, uint256, bytes calldata, bytes calldata)
        external
        pure
        override
        returns (bool success)
    {
        // No known blobs to reference
    }

    /// @inheritdoc KailuaTournament
    function getChallengerDuration(uint256) public pure override returns (Duration duration_) {
        // No challenge period
    }

    /// @inheritdoc KailuaTournament
    function minCreationTime() public view override returns (Timestamp minCreationTime_) {
        minCreationTime_ = createdAt;
    }

    /// @inheritdoc KailuaTournament
    function parentGame() public view override returns (KailuaTournament parentGame_) {
        parentGame_ = this;
    }

    // ------------------------------
    // IKailuaTreasury implementation
    // ------------------------------

    /// @inheritdoc IKailuaTreasury
    mapping(address => uint256) public eliminationRound;

    /// @inheritdoc IKailuaTreasury
    mapping(address => address) public proposerOf;

    /// @inheritdoc IKailuaTreasury
    function eliminate(address _child, address prover) external {
        KailuaTournament child = KailuaTournament(_child);

        // INVARIANT: Only the child's parent may call this
        KailuaTournament parent = child.parentGame();
        if (msg.sender != address(parent)) {
            revert Blacklisted(msg.sender, address(parent));
        }

        // INVARIANT: Only known proposals may be eliminated
        address eliminated = proposerOf[address(child)];
        if (eliminated == address(0x0)) {
            revert NotProposed();
        }

        // INVARIANT: Cannot double-eliminate players
        if (eliminationRound[eliminated] > 0) {
            revert AlreadyEliminated();
        }

        // Record elimination round
        eliminationRound[eliminated] = child.gameIndex();

        uint256 bond = paidBonds[eliminated];
        paidBonds[eliminated] = 0;

        // Split the slashed bond into prover / winner / burn.
        uint256 proverShare = (bond * ELIMINATION_SPLIT_PROVER_NUM) / ELIMINATION_SPLIT_DENOM;
        uint256 winnerShare = (bond * ELIMINATION_SPLIT_WINNER_NUM) / ELIMINATION_SPLIT_DENOM;
        uint256 burnShare = bond - proverShare - winnerShare;

        eliminationRewards[prover] += proverShare;
        winnerSharesByParent[parent] += winnerShare;
        // Burn by sending it to the zero address.
        // The zero address has no code, so this external call cannot reenter.
        KailuaPayLib.pay(burnShare, address(0));
    }

    /// @inheritdoc IKailuaTreasury
    bool public isProposing;

    /// @inheritdoc IKailuaTreasury
    address public lastResolved;

    /// @inheritdoc IKailuaTreasury
    function updateLastResolved() external {
        address proposer = proposerOf[msg.sender];

        // INVARIANT: Only known proposal contracts may call this function
        if (proposer == address(0x0)) {
            revert NotProposed();
        }

        KailuaTournament parent = KailuaTournament(msg.sender).parentGame();
        eliminationRewards[proposer] += winnerSharesByParent[parent];
        winnerSharesByParent[parent] = 0;

        lastResolved = msg.sender;
    }

    // ------------------------------
    // Treasury
    // ------------------------------

    /// @notice Fixed split of a slashed participation bond between prover, winner, and burn.
    uint256 public constant ELIMINATION_SPLIT_DENOM = 3;
    uint256 public constant ELIMINATION_SPLIT_PROVER_NUM = 1;
    uint256 public constant ELIMINATION_SPLIT_WINNER_NUM = 1;

    /// @notice The locked collateral required for proposal submission
    uint256 public participationBond;

    /// @notice The locked collateral still paid by proposers for participation
    mapping(address => uint256) public paidBonds;

    /// @notice The total share of elimination bonds accumulated for the eventual tournament winner.
    /// @dev Keyed by the parent game (tournament) contract.
    mapping(KailuaTournament => uint256) private winnerSharesByParent;

    /// @notice The unpaid rewards from eliminated invalid proposals
    mapping(address => uint256) public eliminationRewards;

    /// @notice The last proposal made by each proposer
    mapping(address => KailuaTournament) public lastProposal;

    /// @notice The leading proposer that can extend the proposal tree
    address public vanguard;

    /// @notice The duration for which the vanguard may lead
    Duration public vanguardAdvantage;

    /// @notice Boolean flag to prevent re-entrant calls
    bool internal isLocked;

    modifier nonReentrant() {
        require(!isLocked);
        isLocked = true;
        _;
        isLocked = false;
    }

    modifier onlyFactoryOwner() {
        if (msg.sender != DISPUTE_GAME_FACTORY.owner()) {
            revert NotFactoryOwner();
        }
        _;
    }

    /// @notice Pays the elimination rewards the sender has accrued
    function claimEliminationRewards() public nonReentrant {
        uint256 payout = eliminationRewards[msg.sender];
        eliminationRewards[msg.sender] = 0;

        if (payout > 0) {
            KailuaPayLib.pay(payout, msg.sender);
        }
    }

    /// @notice Pays the proposer back its bond
    function claimProposerBond() public nonReentrant {
        // INVARIANT: Can only claim back bond if not eliminated
        if (eliminationRound[msg.sender] != 0) {
            revert AlreadyEliminated();
        }

        // INVARIANT: Can only claim bond back if no pending proposals are left
        KailuaTournament previousGame = lastProposal[msg.sender];
        if (address(previousGame) != address(0x0)) {
            KailuaTournament lastTournament = previousGame.parentGame();
            if (lastTournament.children(lastTournament.contenderIndex()).status() != GameStatus.DEFENDER_WINS) {
                revert GameNotResolved();
            }
        }

        uint256 payout = paidBonds[msg.sender];
        // INVARIANT: Can only claim bond if it is paid
        if (payout == 0) {
            revert NoCreditToClaim();
        }

        // Pay out and clear bond
        paidBonds[msg.sender] = 0;
        KailuaPayLib.pay(payout, msg.sender);
    }

    /// @notice Updates the required bond for new proposals
    function setParticipationBond(uint256 amount) external onlyFactoryOwner {
        participationBond = amount;
        emit BondUpdated(amount);
    }

    /// @notice Updates the vanguard address and advantage duration
    function assignVanguard(address _vanguard, Duration _vanguardAdvantage) external onlyFactoryOwner {
        vanguard = _vanguard;
        vanguardAdvantage = _vanguardAdvantage;
    }

    /// @notice Checks the proposer's bonded amount and creates a new proposal through the factory
    function propose(Claim _rootClaim, bytes calldata _extraData)
        external
        payable
        returns (KailuaTournament tournament)
    {
        // Check proposer honesty
        if (eliminationRound[msg.sender] > 0) {
            revert BadAuth();
        }
        // Update proposer bond
        if (msg.value > 0) {
            paidBonds[msg.sender] += msg.value;
        }
        // Check proposer bond
        if (paidBonds[msg.sender] < participationBond) {
            revert IncorrectBondAmount();
        }
        // Create proposal
        isProposing = true;
        tournament = KailuaTournament(address(DISPUTE_GAME_FACTORY.create(GAME_TYPE, _rootClaim, _extraData)));
        isProposing = false;
        // Check proposal progression
        KailuaTournament previousGame = lastProposal[msg.sender];
        if (address(previousGame) != address(0x0)) {
            // INVARIANT: Proposers may only extend the proposal set incrementally
            if (previousGame.l2BlockNumber() >= tournament.l2BlockNumber()) {
                revert BlockNumberMismatch(previousGame.l2BlockNumber(), tournament.l2BlockNumber());
            }
        }
        // Check whether the proposer must follow a vanguard if one is set
        if (vanguard != address(0x0) && vanguard != msg.sender) {
            // The proposer may only counter the vanguard during the advantage time
            KailuaTournament proposalParent = tournament.parentGame();
            if (proposalParent.childCount() == 1) {
                // Count the advantage clock since proposal was possible
                uint64 elapsedAdvantage = uint64(block.timestamp - tournament.minCreationTime().raw());
                if (elapsedAdvantage < vanguardAdvantage.raw()) {
                    revert VanguardError(address(proposalParent));
                }
            }
        }
        // Record proposer
        proposerOf[address(tournament)] = msg.sender;
        // Record proposal
        lastProposal[msg.sender] = tournament;
    }
}
