// SPDX-License-Identifier: Unknown
pragma solidity 0.8.15;

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
    )
        external;
    function challengeFirstLPP(
        address _claimant,
        uint256 _uuid,
        Leaf memory _postState,
        bytes32[] memory _postStateProof
    )
        external;
    function challengeLPP(
        address _claimant,
        uint256 _uuid,
        LibKeccak.StateMatrix memory _stateMatrix,
        Leaf memory _preState,
        bytes32[] memory _preStateProof,
        Leaf memory _postState,
        bytes32[] memory _postStateProof
    )
        external;
    function challengePeriod() external view returns (uint256 challengePeriod_);
    function getTreeRootLPP(address _owner, uint256 _uuid) external view returns (bytes32 treeRoot_);
    function initLPP(uint256 _uuid, uint32 _partOffset, uint32 _claimedSize) external payable;
    function loadBlobPreimagePart(
        uint256 _z,
        uint256 _y,
        bytes memory _commitment,
        bytes memory _proof,
        uint256 _partOffset
    )
        external;
    function loadKeccak256PreimagePart(uint256 _partOffset, bytes memory _preimage) external;
    function loadLocalData(
        uint256 _ident,
        bytes32 _localContext,
        bytes32 _word,
        uint256 _size,
        uint256 _partOffset
    )
        external
        returns (bytes32 key_);
    function loadPrecompilePreimagePart(
        uint256 _partOffset,
        address _precompile,
        uint64 _requiredGas,
        bytes memory _input
    )
        external;
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
    )
        external;
    function version() external view returns (string memory);
    function zeroHashes(uint256) external view returns (bytes32);

    function __constructor__(uint256 _minProposalSize, uint256 _challengePeriod) external;
}

/// @notice Thrown when the state version set is not supported.
error UnsupportedStateVersion();

/// @notice Thrown when the value of the exited boolean is not 0 or 1.
error InvalidExitedValue();

library MIPS64State {
    struct CpuScalars {
        uint64 pc;
        uint64 nextPC;
        uint64 lo;
        uint64 hi;
    }

    struct Features {
        bool supportWorkingSysGetRandom;
    }

    function assertExitedIsValid(uint32 _exited) internal pure {
        if (_exited > 1) {
            revert InvalidExitedValue();
        }
    }

    function featuresForVersion(uint256 _version) internal pure returns (Features memory features_) {
        if (_version >= 8) {
            features_.supportWorkingSysGetRandom = true;
        }
    }
}

library MIPS64Arch {
    uint64 internal constant WORD_SIZE = 64;
    uint64 internal constant WORD_SIZE_BYTES = 8;
    uint64 internal constant EXT_MASK = 0x7;
    uint64 internal constant ADDRESS_MASK = 0xFFFFFFFFFFFFFFF8;
}

/// @notice Thrown when reading an invalid memory
error InvalidMemoryProof();

library MIPS64Memory {
    uint64 internal constant EXT_MASK = 0x7;
    uint64 internal constant MEM_PROOF_LEAF_COUNT = 60;
    uint256 internal constant U64_MASK = 0xFFFFFFFFFFFFFFFF;

    /// @notice Reads a 64-bit word from memory.
    /// @param _memRoot The current memory root
    /// @param _addr The address to read from.
    /// @param _proofOffset The offset of the memory proof in calldata.
    /// @return out_ The hashed MIPS state.
    function readMem(bytes32 _memRoot, uint64 _addr, uint256 _proofOffset) internal pure returns (uint64 out_) {
        bool valid;
        (out_, valid) = readMemUnchecked(_memRoot, _addr, _proofOffset);
        if (!valid) {
            revert InvalidMemoryProof();
        }
    }

    /// @notice Reads a 64-bit word from memory.
    /// @param _memRoot The current memory root
    /// @param _addr The address to read from.
    /// @param _proofOffset The offset of the memory proof in calldata.
    /// @return out_ The hashed MIPS state.
    ///         valid_ Whether the proof is valid.
    function readMemUnchecked(
        bytes32 _memRoot,
        uint64 _addr,
        uint256 _proofOffset
    )
        internal
        pure
        returns (uint64 out_, bool valid_)
    {
        unchecked {
            validateMemoryProofAvailability(_proofOffset);
            assembly {
                // Validate the address alignment.
                if and(_addr, EXT_MASK) {
                    // revert InvalidAddress();
                    let ptr := mload(0x40)
                    mstore(ptr, shl(224, 0xe6c4247b))
                    revert(ptr, 0x4)
                }

                // Load the leaf value.
                let leaf := calldataload(_proofOffset)
                _proofOffset := add(_proofOffset, 32)

                // Convenience function to hash two nodes together in scratch space.
                function hashPair(a, b) -> h {
                    mstore(0, a)
                    mstore(32, b)
                    h := keccak256(0, 64)
                }

                // Start with the leaf node.
                // Work back up by combining with siblings, to reconstruct the root.
                let path := shr(5, _addr)
                let node := leaf
                let end := sub(MEM_PROOF_LEAF_COUNT, 1)
                for { let i := 0 } lt(i, end) { i := add(i, 1) } {
                    let sibling := calldataload(_proofOffset)
                    _proofOffset := add(_proofOffset, 32)
                    switch and(shr(i, path), 1)
                    case 0 { node := hashPair(node, sibling) }
                    case 1 { node := hashPair(sibling, node) }
                }

                // Verify the root matches.
                valid_ := eq(node, _memRoot)
                if valid_ {
                    // Bits to shift = (32 - 8 - (addr % 32)) * 8
                    let shamt := shl(3, sub(sub(32, 8), and(_addr, 31)))
                    out_ := and(shr(shamt, leaf), U64_MASK)
                }
            }
        }
    }

    /// @notice Writes a 64-bit word to memory.
    ///         This function first overwrites the part of the leaf.
    ///         Then it recomputes the memory merkle root.
    /// @param _addr The address to write to.
    /// @param _proofOffset The offset of the memory proof in calldata.
    /// @param _val The value to write.
    /// @return newMemRoot_ The new memory root after modification
    function writeMem(uint64 _addr, uint256 _proofOffset, uint64 _val) internal pure returns (bytes32 newMemRoot_) {
        unchecked {
            validateMemoryProofAvailability(_proofOffset);
            assembly {
                // Validate the address alignment.
                if and(_addr, EXT_MASK) {
                    // revert InvalidAddress();
                    let ptr := mload(0x40)
                    mstore(ptr, shl(224, 0xe6c4247b))
                    revert(ptr, 0x4)
                }

                // Load the leaf value.
                let leaf := calldataload(_proofOffset)
                let shamt := shl(3, sub(sub(32, 8), and(_addr, 31)))

                // Mask out 8 bytes, and OR in the value
                leaf := or(and(leaf, not(shl(shamt, U64_MASK))), shl(shamt, _val))
                _proofOffset := add(_proofOffset, 32)

                // Convenience function to hash two nodes together in scratch space.
                function hashPair(a, b) -> h {
                    mstore(0, a)
                    mstore(32, b)
                    h := keccak256(0, 64)
                }

                // Start with the leaf node.
                // Work back up by combining with siblings, to reconstruct the root.
                let path := shr(5, _addr)
                let node := leaf
                let end := sub(MEM_PROOF_LEAF_COUNT, 1)
                for { let i := 0 } lt(i, end) { i := add(i, 1) } {
                    let sibling := calldataload(_proofOffset)
                    _proofOffset := add(_proofOffset, 32)
                    switch and(shr(i, path), 1)
                    case 0 { node := hashPair(node, sibling) }
                    case 1 { node := hashPair(sibling, node) }
                }

                newMemRoot_ := node
            }
            return newMemRoot_;
        }
    }

    /// @notice Verifies a memory proof.
    /// @param _memRoot The expected memory root
    /// @param _addr The _addr proven.
    /// @param _proofOffset The offset of the memory proof in calldata.
    /// @return valid_ True iff it is a valid proof.
    function isValidProof(bytes32 _memRoot, uint64 _addr, uint256 _proofOffset) internal pure returns (bool valid_) {
        (, valid_) = readMemUnchecked(_memRoot, _addr, _proofOffset);
    }

    /// @notice Computes the offset of a memory proof in the calldata.
    /// @param _proofDataOffset The offset of the set of all memory proof data within calldata (proof.offset)
    ///     Equal to the offset of the first memory proof (at _proofIndex 0).
    /// @param _proofIndex The index of the proof in the calldata.
    /// @return offset_ The offset of the memory proof at the given _proofIndex in the calldata.
    function memoryProofOffset(uint256 _proofDataOffset, uint8 _proofIndex) internal pure returns (uint256 offset_) {
        unchecked {
            // A proof of 64-bit memory, with 32-byte leaf values, is (64-5)=59 bytes32 entries.
            // And the leaf value itself needs to be encoded as well: (59 + 1) = 60 bytes32 entries.
            offset_ = _proofDataOffset + (uint256(_proofIndex) * (MEM_PROOF_LEAF_COUNT * 32));
            return offset_;
        }
    }

    /// @notice Validates that enough calldata is available to hold a full memory proof at the given offset
    /// @param _proofStartOffset The index of the first byte of the target memory proof in calldata
    function validateMemoryProofAvailability(uint256 _proofStartOffset) internal pure {
        unchecked {
            uint256 s = 0;
            assembly {
                s := calldatasize()
            }
            // A memory proof consists of MEM_PROOF_LEAF_COUNT bytes32 values - verify we have enough calldata
            require(
                s >= (_proofStartOffset + MEM_PROOF_LEAF_COUNT * 32),
                "MIPS64Memory: check that there is enough calldata"
            );
        }
    }
}

/// @title PreimageKeyLib
/// @notice Shared utilities for localizing local keys in the preimage oracle.
library PreimageKeyLib {
    /// @notice Generates a context-specific local key for the given local data identifier.
    /// @dev See `localize` for a description of the localization operation.
    /// @param _ident The identifier of the local data. [0, 32) bytes in size.
    /// @param _localContext The local context for the key.
    /// @return key_ The context-specific local key.
    function localizeIdent(uint256 _ident, bytes32 _localContext) internal view returns (bytes32 key_) {
        assembly {
            // Set the type byte in the given identifier to `1` (Local). We only care about
            // the [1, 32) bytes in this value.
            key_ := or(shl(248, 1), and(_ident, not(shl(248, 0xFF))))
        }
        // Localize the key with the given local context.
        key_ = localize(key_, _localContext);
    }

    /// @notice Localizes a given local data key for the caller's context.
    /// @dev The localization operation is defined as:
    ///      localize(k) = H(k .. sender .. local_context) & ~(0xFF << 248) | (0x01 << 248)
    ///      where H is the Keccak-256 hash function.
    /// @param _key The local data key to localize.
    /// @param _localContext The local context for the key.
    /// @return localizedKey_ The localized local data key.
    function localize(bytes32 _key, bytes32 _localContext) internal view returns (bytes32 localizedKey_) {
        assembly {
            // Grab the current free memory pointer to restore later.
            let ptr := mload(0x40)
            // Store the local data key and caller next to each other in memory for hashing.
            mstore(0, _key)
            mstore(0x20, caller())
            mstore(0x40, _localContext)
            // Localize the key with the above `localize` operation.
            localizedKey_ := or(and(keccak256(0, 0x60), not(shl(248, 0xFF))), shl(248, 1))
            // Restore the free memory pointer.
            mstore(0x40, ptr)
        }
    }

    /// @notice Computes and returns the key for a global keccak pre-image.
    /// @param _preimage The pre-image.
    /// @return key_ The pre-image key.
    function keccak256PreimageKey(bytes memory _preimage) internal pure returns (bytes32 key_) {
        assembly {
            // Grab the size of the `_preimage`
            let size := mload(_preimage)

            // Compute the pre-image keccak256 hash (aka the pre-image key)
            let h := keccak256(add(_preimage, 0x20), size)

            // Mask out prefix byte, replace with type 2 byte
            key_ := or(and(h, not(shl(248, 0xFF))), shl(248, 2))
        }
    }
}

library MIPS64Syscalls {
    struct SysReadParams {
        /// @param _a0 The file descriptor.
        uint64 a0;
        /// @param _a1 The memory location where data should be read to.
        uint64 a1;
        /// @param _a2 The number of bytes to read from the file
        uint64 a2;
        /// @param _preimageKey The key of the preimage to read.
        bytes32 preimageKey;
        /// @param _preimageOffset The offset of the preimage to read.
        uint64 preimageOffset;
        /// @param _localContext The local context for the preimage key.
        bytes32 localContext;
        /// @param _oracle The address of the preimage oracle.
        IPreimageOracle oracle;
        /// @param _proofOffset The offset of the memory proof in calldata.
        uint256 proofOffset;
        /// @param _memRoot The current memory root.
        bytes32 memRoot;
    }

    /// @custom:field _a0 The file descriptor.
    /// @custom:field _a1 The memory address to read from.
    /// @custom:field _a2 The number of bytes to read.
    /// @custom:field _preimageKey The current preimaageKey.
    /// @custom:field _preimageOffset The current preimageOffset.
    /// @custom:field _proofOffset The offset of the memory proof in calldata.
    /// @custom:field _memRoot The current memory root.
    struct SysWriteParams {
        uint64 _a0;
        uint64 _a1;
        uint64 _a2;
        bytes32 _preimageKey;
        uint64 _preimageOffset;
        uint256 _proofOffset;
        bytes32 _memRoot;
    }

    uint64 internal constant U64_MASK = 0xFFffFFffFFffFFff;
    uint64 internal constant PAGE_ADDR_MASK = 4095;
    uint64 internal constant PAGE_SIZE = 4096;

    uint32 internal constant SYS_MMAP = 5009;
    uint32 internal constant SYS_MPROTECT = 5010;
    uint32 internal constant SYS_BRK = 5012;
    uint32 internal constant SYS_CLONE = 5055;
    uint32 internal constant SYS_EXIT_GROUP = 5205;
    uint32 internal constant SYS_READ = 5000;
    uint32 internal constant SYS_WRITE = 5001;
    uint32 internal constant SYS_FCNTL = 5070;
    uint32 internal constant SYS_EXIT = 5058;
    uint32 internal constant SYS_SCHED_YIELD = 5023;
    uint32 internal constant SYS_GETTID = 5178;
    uint32 internal constant SYS_FUTEX = 5194;
    uint32 internal constant SYS_OPEN = 5002;
    uint32 internal constant SYS_NANOSLEEP = 5034;
    uint32 internal constant SYS_CLOCKGETTIME = 5222;
    uint32 internal constant SYS_GETPID = 5038;
    uint32 internal constant SYS_GETRANDOM = 5313;
    // no-op syscalls
    uint32 internal constant SYS_MUNMAP = 5011;
    uint32 internal constant SYS_GETAFFINITY = 5196;
    uint32 internal constant SYS_MADVISE = 5027;
    uint32 internal constant SYS_RTSIGPROCMASK = 5014;
    uint32 internal constant SYS_SIGALTSTACK = 5129;
    uint32 internal constant SYS_RTSIGACTION = 5013;
    uint32 internal constant SYS_PRLIMIT64 = 5297;
    uint32 internal constant SYS_CLOSE = 5003;
    uint32 internal constant SYS_PREAD64 = 5016;
    uint32 internal constant SYS_STAT = 5004;
    uint32 internal constant SYS_FSTAT = 5005;
    //uint32 internal constant SYS_FSTAT64 = 0xFFFFFFFF;  // UndefinedSysNr - not supported by MIPS64
    uint32 internal constant SYS_OPENAT = 5247;
    uint32 internal constant SYS_READLINK = 5087;
    uint32 internal constant SYS_READLINKAT = 5257;
    uint32 internal constant SYS_IOCTL = 5015;
    uint32 internal constant SYS_EPOLLCREATE1 = 5285;
    uint32 internal constant SYS_PIPE2 = 5287;
    uint32 internal constant SYS_EPOLLCTL = 5208;
    uint32 internal constant SYS_EPOLLPWAIT = 5272;
    uint32 internal constant SYS_UNAME = 5061;
    //uint32 internal constant SYS_STAT64 = 0xFFFFFFFF;  // UndefinedSysNr - not supported by MIPS64
    uint32 internal constant SYS_GETUID = 5100;
    uint32 internal constant SYS_GETGID = 5102;
    //uint32 internal constant SYS_LLSEEK = 0xFFFFFFFF;  // UndefinedSysNr - not supported by MIPS64
    uint32 internal constant SYS_MINCORE = 5026;
    uint32 internal constant SYS_TGKILL = 5225;
    uint32 internal constant SYS_GETRLIMIT = 5095;
    uint32 internal constant SYS_LSEEK = 5008;
    uint32 internal constant SYS_EVENTFD2 = 5284;
    // profiling-related syscalls - ignored
    uint32 internal constant SYS_SETITIMER = 5036;
    uint32 internal constant SYS_TIMERCREATE = 5216;
    uint32 internal constant SYS_TIMERSETTIME = 5217;
    uint32 internal constant SYS_TIMERDELETE = 5220;

    uint32 internal constant FD_STDIN = 0;
    uint32 internal constant FD_STDOUT = 1;
    uint32 internal constant FD_STDERR = 2;
    uint32 internal constant FD_HINT_READ = 3;
    uint32 internal constant FD_HINT_WRITE = 4;
    uint32 internal constant FD_PREIMAGE_READ = 5;
    uint32 internal constant FD_PREIMAGE_WRITE = 6;
    uint64 internal constant FD_EVENTFD = 100;

    uint64 internal constant SYS_ERROR_SIGNAL = U64_MASK;
    uint64 internal constant EBADF = 0x9;
    uint64 internal constant EINVAL = 0x16;
    uint64 internal constant EAGAIN = 0xb;
    uint64 internal constant ETIMEDOUT = 0x91;

    uint64 internal constant FUTEX_WAIT_PRIVATE = 128;
    uint64 internal constant FUTEX_WAKE_PRIVATE = 129;

    uint64 internal constant SCHED_QUANTUM = 100_000;
    uint64 internal constant HZ = 10_000_000;
    uint64 internal constant CLOCK_GETTIME_REALTIME_FLAG = 0;
    uint64 internal constant CLOCK_GETTIME_MONOTONIC_FLAG = 1;
    /// @notice Start of the data segment.
    uint64 internal constant PROGRAM_BREAK = 0x00_00_40_00_00_00_00_00;
    uint64 internal constant HEAP_END = 0x00_00_60_00_00_00_00_00;

    // SYS_CLONE flags
    uint64 internal constant CLONE_VM = 0x100;
    uint64 internal constant CLONE_FS = 0x200;
    uint64 internal constant CLONE_FILES = 0x400;
    uint64 internal constant CLONE_SIGHAND = 0x800;
    uint64 internal constant CLONE_PTRACE = 0x2000;
    uint64 internal constant CLONE_VFORK = 0x4000;
    uint64 internal constant CLONE_PARENT = 0x8000;
    uint64 internal constant CLONE_THREAD = 0x10000;
    uint64 internal constant CLONE_NEWNS = 0x20000;
    uint64 internal constant CLONE_SYSVSEM = 0x40000;
    uint64 internal constant CLONE_SETTLS = 0x80000;
    uint64 internal constant CLONE_PARENTSETTID = 0x100000;
    uint64 internal constant CLONE_CHILDCLEARTID = 0x200000;
    uint64 internal constant CLONE_UNTRACED = 0x800000;
    uint64 internal constant CLONE_CHILDSETTID = 0x1000000;
    uint64 internal constant CLONE_STOPPED = 0x2000000;
    uint64 internal constant CLONE_NEWUTS = 0x4000000;
    uint64 internal constant CLONE_NEWIPC = 0x8000000;
    uint64 internal constant VALID_SYS_CLONE_FLAGS =
        CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_SYSVSEM | CLONE_THREAD;

    // eventfd flags
    // From:
    // https://github.com/golang/go/blob/7a2cfb70b01f069c2125adcf7126d7f3376cb8b7/src/internal/runtime/syscall/defs_linux_mips64x.go#L18-L18
    uint64 internal constant EFD_NONBLOCK = 0x80;

    // FYI: https://en.wikibooks.org/wiki/MIPS_Assembly/Register_File
    //      https://refspecs.linuxfoundation.org/elf/mipsabi.pdf
    uint32 internal constant REG_V0 = 2;
    uint32 internal constant REG_A0 = 4;
    uint32 internal constant REG_A1 = 5;
    uint32 internal constant REG_A2 = 6;
    uint32 internal constant REG_A3 = 7;

    // FYI: https://web.archive.org/web/20231223163047/https://www.linux-mips.org/wiki/Syscall
    uint32 internal constant REG_SYSCALL_NUM = REG_V0;
    uint32 internal constant REG_SYSCALL_ERRNO = REG_A3;
    uint32 internal constant REG_SYSCALL_RET1 = REG_V0;
    uint32 internal constant REG_SYSCALL_PARAM1 = REG_A0;
    uint32 internal constant REG_SYSCALL_PARAM2 = REG_A1;
    uint32 internal constant REG_SYSCALL_PARAM3 = REG_A2;

    // Constants copied from MIPS64Arch for use in Yul
    uint64 internal constant WORD_SIZE_BYTES = 8;
    uint64 internal constant EXT_MASK = 0x7;

    /// @notice Extract syscall num and arguments from registers.
    /// @param _registers The cpu registers.
    /// @return sysCallNum_ The syscall number.
    /// @return a0_ The first argument available to the syscall operation.
    /// @return a1_ The second argument available to the syscall operation.
    /// @return a2_ The third argument available to the syscall operation.
    function getSyscallArgs(uint64[32] memory _registers)
        internal
        pure
        returns (uint64 sysCallNum_, uint64 a0_, uint64 a1_, uint64 a2_)
    {
        unchecked {
            sysCallNum_ = _registers[REG_SYSCALL_NUM];

            a0_ = _registers[REG_SYSCALL_PARAM1];
            a1_ = _registers[REG_SYSCALL_PARAM2];
            a2_ = _registers[REG_SYSCALL_PARAM3];

            return (sysCallNum_, a0_, a1_, a2_);
        }
    }

    /// @notice Like a Linux mmap syscall. Allocates a page from the heap.
    /// @param _a0 The address for the new mapping
    /// @param _a1 The size of the new mapping
    /// @param _heap The current value of the heap pointer
    /// @return v0_ The address of the new mapping or error code on error
    /// @return v1_ 0 if there is no error, non-zero on error
    /// @return newHeap_ The new value for the heap, may be unchanged
    function handleSysMmap(
        uint64 _a0,
        uint64 _a1,
        uint64 _heap
    )
        internal
        pure
        returns (uint64 v0_, uint64 v1_, uint64 newHeap_)
    {
        unchecked {
            v1_ = uint64(0);
            newHeap_ = _heap;

            uint64 sz = _a1;
            if (sz & PAGE_ADDR_MASK != 0) {
                // adjust size to align with page size
                sz += PAGE_SIZE - (sz & PAGE_ADDR_MASK);
            }
            if (_a0 == 0) {
                v0_ = _heap;
                newHeap_ += sz;
                // Fail if new heap exceeds memory limit, newHeap overflows to low memory, or sz overflows
                if (newHeap_ > HEAP_END || newHeap_ < _heap || sz < _a1) {
                    v0_ = EINVAL;
                    v1_ = SYS_ERROR_SIGNAL;
                    return (v0_, v1_, _heap);
                }
            } else {
                v0_ = _a0;
            }

            return (v0_, v1_, newHeap_);
        }
    }

    /// @notice Like a Linux read syscall. Splits unaligned reads into aligned reads.
    ///         Args are provided as a struct to reduce stack pressure.
    /// @return v0_ The number of bytes read, error code on error.
    /// @return v1_ 0 if there is no error, non-zero on error
    /// @return newPreimageOffset_ The new value for the preimage offset.
    /// @return newMemRoot_ The new memory root.
    function handleSysRead(SysReadParams memory _args)
        internal
        view
        returns (
            uint64 v0_,
            uint64 v1_,
            uint64 newPreimageOffset_,
            bytes32 newMemRoot_,
            bool memUpdated_,
            uint64 memAddr_
        )
    {
        unchecked {
            v0_ = uint64(0);
            v1_ = uint64(0);
            newMemRoot_ = _args.memRoot;
            newPreimageOffset_ = _args.preimageOffset;
            memUpdated_ = false;
            memAddr_ = 0;

            // args: _a0 = fd, _a1 = addr, _a2 = count
            // returns: v0_ = read, v1_ = err code
            if (_args.a0 == FD_STDIN) {
                // Leave v0_ and v1_ zero: read nothing, no error
            }
            // pre-image oracle read
            else if (_args.a0 == FD_PREIMAGE_READ) {
                uint64 effAddr = _args.a1 & MIPS64Arch.ADDRESS_MASK;
                // verify proof is correct, and get the existing memory.
                // mask the addr to align it to 4 bytes
                uint64 mem = MIPS64Memory.readMem(_args.memRoot, effAddr, _args.proofOffset);
                // If the preimage key is a local key, localize it in the context of the caller.
                if (uint8(_args.preimageKey[0]) == 1) {
                    _args.preimageKey = PreimageKeyLib.localize(_args.preimageKey, _args.localContext);
                }
                (bytes32 dat, uint256 datLen) = _args.oracle.readPreimage(_args.preimageKey, _args.preimageOffset);

                // Transform data for writing to memory
                // We use assembly for more precise ops, and no var count limit
                uint64 a1 = _args.a1;
                uint64 a2 = _args.a2;
                assembly {
                    let alignment := and(a1, EXT_MASK) // the read might not start at an aligned address
                    let space := sub(WORD_SIZE_BYTES, alignment) // remaining space in memory word
                    if lt(space, datLen) { datLen := space } // if less space than data, shorten data
                    if lt(a2, datLen) { datLen := a2 } // if requested to read less, read less
                    dat := shr(sub(256, mul(datLen, 8)), dat) // right-align data
                    // position data to insert into memory word
                    dat := shl(mul(sub(sub(WORD_SIZE_BYTES, datLen), alignment), 8), dat)
                    // mask all bytes after start
                    let mask := sub(shl(mul(sub(WORD_SIZE_BYTES, alignment), 8), 1), 1)
                    // mask of all bytes
                    let suffixMask := sub(shl(mul(sub(sub(WORD_SIZE_BYTES, alignment), datLen), 8), 1), 1)
                    // starting from end, maybe none
                    mask := and(mask, not(suffixMask)) // reduce mask to just cover the data we insert
                    mem := or(and(mem, not(mask)), dat) // clear masked part of original memory, and insert data
                }

                // Write memory back
                newMemRoot_ = MIPS64Memory.writeMem(effAddr, _args.proofOffset, mem);
                memUpdated_ = true;
                memAddr_ = effAddr;
                newPreimageOffset_ += uint64(datLen);
                v0_ = uint64(datLen);
            }
            // hint response
            else if (_args.a0 == FD_HINT_READ) {
                // Don't read into memory, just say we read it all
                // The result is ignored anyway
                v0_ = _args.a2;
            } else if (_args.a0 == FD_EVENTFD) {
                // Always act in non blocking mode as if the counter has not been signalled
                v0_ = EAGAIN;
                v1_ = SYS_ERROR_SIGNAL;
            } else {
                v0_ = EBADF;
                v1_ = SYS_ERROR_SIGNAL;
            }

            return (v0_, v1_, newPreimageOffset_, newMemRoot_, memUpdated_, memAddr_);
        }
    }

    /// @notice Like a Linux write syscall. Splits unaligned writes into aligned writes.
    /// @return v0_ The number of bytes written, or error code on error.
    /// @return v1_ 0 if there is no error, non-zero on error
    /// @return newPreimageKey_ The new preimageKey.
    /// @return newPreimageOffset_ The new preimageOffset.
    function handleSysWrite(SysWriteParams memory _args)
        internal
        pure
        returns (uint64 v0_, uint64 v1_, bytes32 newPreimageKey_, uint64 newPreimageOffset_)
    {
        unchecked {
            // args: _a0 = fd, _a1 = addr, _a2 = count
            // returns: v0_ = written, v1_ = err code
            v0_ = uint64(0);
            v1_ = uint64(0);
            newPreimageKey_ = _args._preimageKey;
            newPreimageOffset_ = _args._preimageOffset;

            if (_args._a0 == FD_STDOUT || _args._a0 == FD_STDERR || _args._a0 == FD_HINT_WRITE) {
                v0_ = _args._a2; // tell program we have written everything
            }
            // pre-image oracle
            else if (_args._a0 == FD_PREIMAGE_WRITE) {
                // mask the addr to align it to 4 bytes
                uint64 mem = MIPS64Memory.readMem(_args._memRoot, _args._a1 & MIPS64Arch.ADDRESS_MASK, _args._proofOffset);
                bytes32 key = _args._preimageKey;

                // Construct pre-image key from memory
                // We use assembly for more precise ops, and no var count limit
                uint64 _a1 = _args._a1;
                uint64 _a2 = _args._a2;
                assembly {
                    let alignment := and(_a1, EXT_MASK) // the read might not start at an aligned address
                    let space := sub(WORD_SIZE_BYTES, alignment) // remaining space in memory word
                    if lt(space, _a2) { _a2 := space } // if less space than data, shorten data
                    key := shl(mul(_a2, 8), key) // shift key, make space for new info
                    let mask := sub(shl(mul(_a2, 8), 1), 1) // mask for extracting value from memory
                    mem := and(shr(mul(sub(space, _a2), 8), mem), mask) // align value to right, mask it
                    key := or(key, mem) // insert into key
                }
                _args._a2 = _a2;

                // Write pre-image key to oracle
                newPreimageKey_ = key;
                newPreimageOffset_ = 0; // reset offset, to read new pre-image data from the start
                v0_ = _args._a2;
            } else if (_args._a0 == FD_EVENTFD) {
                // Always report that the write could not be completed
                // This acts as if the counter has already reached the maximum value
                v0_ = EAGAIN;
                v1_ = SYS_ERROR_SIGNAL;
            } else {
                v0_ = EBADF;
                v1_ = SYS_ERROR_SIGNAL;
            }

            return (v0_, v1_, newPreimageKey_, newPreimageOffset_);
        }
    }

    /// @notice Like Linux fcntl (file control) syscall, but only supports minimal file-descriptor control commands, to
    /// retrieve the file-descriptor R/W flags.
    /// @param _a0 The file descriptor.
    /// @param _a1 The control command.
    /// @param v0_ The file status flag (only supported commands are F_GETFD and F_GETFL), or error code on error.
    /// @param v1_ 0 if there is no error, non-zero on error
    function handleSysFcntl(uint64 _a0, uint64 _a1) internal pure returns (uint64 v0_, uint64 v1_) {
        unchecked {
            v0_ = uint64(0);
            v1_ = uint64(0);

            // args: _a0 = fd, _a1 = cmd
            if (_a1 == 1) {
                // F_GETFD: get file descriptor flags
                if (
                    _a0 == FD_STDIN || _a0 == FD_STDOUT || _a0 == FD_STDERR || _a0 == FD_PREIMAGE_READ
                        || _a0 == FD_HINT_READ || _a0 == FD_PREIMAGE_WRITE || _a0 == FD_HINT_WRITE
                ) {
                    v0_ = 0; // No flags set
                } else {
                    v0_ = EBADF;
                    v1_ = SYS_ERROR_SIGNAL;
                }
            } else if (_a1 == 3) {
                // F_GETFL: get file status flags
                if (_a0 == FD_STDIN || _a0 == FD_PREIMAGE_READ || _a0 == FD_HINT_READ) {
                    v0_ = 0; // O_RDONLY
                } else if (_a0 == FD_STDOUT || _a0 == FD_STDERR || _a0 == FD_PREIMAGE_WRITE || _a0 == FD_HINT_WRITE) {
                    v0_ = 1; // O_WRONLY
                } else {
                    v0_ = EBADF;
                    v1_ = SYS_ERROR_SIGNAL;
                }
            } else {
                v0_ = EINVAL; // cmd not recognized by this kernel
                v1_ = SYS_ERROR_SIGNAL;
            }

            return (v0_, v1_);
        }
    }

    function handleSyscallUpdates(
        MIPS64State.CpuScalars memory _cpu,
        uint64[32] memory _registers,
        uint64 _v0,
        uint64 _v1
    )
        internal
        pure
    {
        unchecked {
            // Write the results back to the state registers
            _registers[REG_SYSCALL_RET1] = _v0;
            _registers[REG_SYSCALL_ERRNO] = _v1;

            // Update the PC and nextPC
            _cpu.pc = _cpu.nextPC;
            _cpu.nextPC = _cpu.nextPC + 4;
        }
    }
}

library MIPS64Instructions {
    uint32 internal constant OP_LOAD_LINKED = 0x30;
    uint32 internal constant OP_STORE_CONDITIONAL = 0x38;
    uint32 internal constant OP_LOAD_LINKED64 = 0x34;
    uint32 internal constant OP_STORE_CONDITIONAL64 = 0x3C;
    uint32 internal constant OP_LOAD_DOUBLE_LEFT = 0x1A;
    uint32 internal constant OP_LOAD_DOUBLE_RIGHT = 0x1B;
    uint32 internal constant REG_RA = 31;
    uint64 internal constant U64_MASK = 0xFFFFFFFFFFFFFFFF;
    uint32 internal constant U32_MASK = 0xFFffFFff;

    error InvalidPC();

    struct CoreStepLogicParams {
        /// @param opcode The opcode value parsed from insn.
        MIPS64State.CpuScalars cpu;
        /// @param registers The CPU registers.
        uint64[32] registers;
        /// @param memRoot The current merkle root of the memory.
        bytes32 memRoot;
        /// @param memProofOffset The offset in calldata specify where the memory merkle proof is located.
        uint256 memProofOffset;
        /// @param insn The current MIPS instruction at the pc.
        uint32 insn;
        /// @param cpu The CPU scalar fields.
        uint32 opcode;
        /// @param fun The function value parsed from insn.
        uint32 fun;
    }

    struct ExecuteMipsInstructionParams {
        /// @param insn The current MIPS instruction at the pc.
        uint32 insn;
        /// @param opcode The opcode value parsed from insn.
        uint32 opcode;
        /// @param fun The function value parsed from insn.
        uint32 fun;
        /// @param rs The source register 1 value.
        uint64 rs;
        /// @param rt The source register 2 value.
        uint64 rt;
        /// @param mem The value fetched from memory for the current instruction.
        uint64 mem;
    }

    /// @param _pc The program counter.
    /// @param _memRoot The current memory root.
    /// @param _insnProofOffset The calldata offset of the memory proof for the current instruction.
    /// @return insn_ The current 32-bit instruction at the pc.
    /// @return opcode_ The opcode value parsed from insn_.
    /// @return fun_ The function value parsed from insn_.
    function getInstructionDetails(
        uint64 _pc,
        bytes32 _memRoot,
        uint256 _insnProofOffset
    )
        internal
        pure
        returns (uint32 insn_, uint32 opcode_, uint32 fun_)
    {
        unchecked {
            if (_pc & 0x3 != 0) {
                revert InvalidPC();
            }
            uint64 word = MIPS64Memory.readMem(_memRoot, _pc & MIPS64Arch.ADDRESS_MASK, _insnProofOffset);
            insn_ = uint32(selectSubWord(_pc, word, 4, false));
            opcode_ = insn_ >> 26; // First 6-bits
            fun_ = insn_ & 0x3f; // Last 6-bits

            return (insn_, opcode_, fun_);
        }
    }

    /// @notice Execute core MIPS step logic.
    /// @return newMemRoot_ The updated merkle root of memory after any modifications, may be unchanged.
    /// @return memUpdated_ True if memory was modified.
    /// @return effMemAddr_ Holds the effective address that was updated if memUpdated_ is true.
    function execMipsCoreStepLogic(CoreStepLogicParams memory _args)
        internal
        pure
        returns (bytes32 newMemRoot_, bool memUpdated_, uint64 effMemAddr_)
    {
        unchecked {
            newMemRoot_ = _args.memRoot;
            memUpdated_ = false;
            effMemAddr_ = 0;

            // j-type j/jal
            if (_args.opcode == 2 || _args.opcode == 3) {
                // Take top 4 bits of the next PC (its 256 MB region), and concatenate with the 26-bit offset
                uint64 target = (_args.cpu.nextPC & signExtend(0xF0000000, 32)) | uint64((_args.insn & 0x03FFFFFF) << 2);
                handleJump(_args, _args.opcode == 2 ? 0 : REG_RA, target);
                return (newMemRoot_, memUpdated_, effMemAddr_);
            }

            // register fetch
            uint64 rs = 0; // source register 1 value
            uint64 rt = 0; // source register 2 / temp value
            uint64 rtReg = uint64((_args.insn >> 16) & 0x1F);

            // R-type or I-type (stores rt)
            rs = _args.registers[(_args.insn >> 21) & 0x1F];
            uint64 rdReg = rtReg;

            // 64-bit opcodes lwu, ldl, ldr
            if (_args.opcode == 0x27 || _args.opcode == 0x1A || _args.opcode == 0x1B) {
                rt = _args.registers[rtReg];
                rdReg = rtReg;
            } else if (_args.opcode == 0 || _args.opcode == 0x1c) {
                // R-type (stores rd)
                rt = _args.registers[rtReg];
                rdReg = uint64((_args.insn >> 11) & 0x1F);
            } else if (_args.opcode < 0x20) {
                // rt is SignExtImm
                // don't sign extend for andi, ori, xori
                if (_args.opcode == 0xC || _args.opcode == 0xD || _args.opcode == 0xe) {
                    // ZeroExtImm
                    rt = uint64(_args.insn & 0xFFFF);
                } else {
                    // SignExtImm
                    rt = signExtendImmediate(_args.insn);
                }
            } else if (_args.opcode >= 0x28 || _args.opcode == 0x22 || _args.opcode == 0x26) {
                // store rt value with store
                rt = _args.registers[rtReg];

                // store actual rt with lwl and lwr
                rdReg = rtReg;
            }

            if ((_args.opcode >= 4 && _args.opcode < 8) || _args.opcode == 1) {
                handleBranch({
                    _cpu: _args.cpu,
                    _registers: _args.registers,
                    _opcode: _args.opcode,
                    _insn: _args.insn,
                    _rtReg: rtReg,
                    _rs: rs
                });
                return (newMemRoot_, memUpdated_, effMemAddr_);
            }

            uint64 storeAddr = U64_MASK;
            // memory fetch (all I-type)
            // we do the load for stores also
            uint64 mem = 0;
            if (_args.opcode >= 0x20 || _args.opcode == OP_LOAD_DOUBLE_LEFT || _args.opcode == OP_LOAD_DOUBLE_RIGHT) {
                // M[R[rs]+SignExtImm]
                rs += signExtendImmediate(_args.insn);
                uint64 addr = rs & MIPS64Arch.ADDRESS_MASK;
                mem = MIPS64Memory.readMem(_args.memRoot, addr, _args.memProofOffset);
                if (_args.opcode >= 0x28) {
                    // store for 32-bit
                    // for 64-bit: ld (0x37) is the only non-store opcode >= 0x28
                    if (_args.opcode != 0x37) {
                        // store
                        storeAddr = addr;
                        // store opcodes don't write back to a register
                        rdReg = 0;
                    }
                }
            }

            // ALU
            // Note: swr outputs more than 8 bytes without the u64_mask
            ExecuteMipsInstructionParams memory params = ExecuteMipsInstructionParams({
                insn: _args.insn,
                opcode: _args.opcode,
                fun: _args.fun,
                rs: rs,
                rt: rt,
                mem: mem
            });
            uint64 val = executeMipsInstruction(params) & U64_MASK;

            uint64 funSel = 0x20;
            if (_args.opcode == 0 && _args.fun >= 8 && _args.fun < funSel) {
                if (_args.fun == 8 || _args.fun == 9) {
                    // jr/jalr
                    handleJump(_args, _args.fun == 8 ? 0 : rdReg, rs);
                    return (newMemRoot_, memUpdated_, effMemAddr_);
                }

                if (_args.fun == 0xa) {
                    // movz
                    handleRd(_args.cpu, _args.registers, rdReg, rs, rt == 0);
                    return (newMemRoot_, memUpdated_, effMemAddr_);
                }
                if (_args.fun == 0xb) {
                    // movn
                    handleRd(_args.cpu, _args.registers, rdReg, rs, rt != 0);
                    return (newMemRoot_, memUpdated_, effMemAddr_);
                }

                // lo and hi registers
                // can write back
                if (_args.fun >= 0x10 && _args.fun < funSel) {
                    handleHiLo({
                        _cpu: _args.cpu,
                        _registers: _args.registers,
                        _fun: _args.fun,
                        _rs: rs,
                        _rt: rt,
                        _storeReg: rdReg
                    });
                    return (newMemRoot_, memUpdated_, effMemAddr_);
                }
            }

            // write memory
            if (storeAddr != U64_MASK) {
                newMemRoot_ = MIPS64Memory.writeMem(storeAddr, _args.memProofOffset, val);
                memUpdated_ = true;
                effMemAddr_ = storeAddr;
            }

            // write back the value to destination register
            handleRd(_args.cpu, _args.registers, rdReg, val, true);

            return (newMemRoot_, memUpdated_, effMemAddr_);
        }
    }

    function signExtendImmediate(uint32 _insn) internal pure returns (uint64 offset_) {
        unchecked {
            return signExtend(_insn & 0xFFFF, 16);
        }
    }

    /// @notice Execute an instruction.
    function executeMipsInstruction(ExecuteMipsInstructionParams memory _args) internal pure returns (uint64 out_) {
        uint32 insn = _args.insn;
        uint32 opcode = _args.opcode;
        uint32 fun = _args.fun;
        uint64 rs = _args.rs;
        uint64 rt = _args.rt;
        uint64 mem = _args.mem;
        unchecked {
            if (opcode == 0 || (opcode >= 8 && opcode < 0xF) || opcode == 0x18 || opcode == 0x19) {
                assembly {
                    // transform ArithLogI to SPECIAL
                    switch opcode
                    // addi
                    case 0x8 { fun := 0x20 }
                    // addiu
                    case 0x9 { fun := 0x21 }
                    // stli
                    case 0xA { fun := 0x2A }
                    // sltiu
                    case 0xB { fun := 0x2B }
                    // andi
                    case 0xC { fun := 0x24 }
                    // ori
                    case 0xD { fun := 0x25 }
                    // xori
                    case 0xE { fun := 0x26 }
                    // daddi
                    case 0x18 { fun := 0x2C }
                    // daddiu
                    case 0x19 { fun := 0x2D }
                }

                // sll
                if (fun == 0x00) {
                    uint32 shiftAmt = (insn >> 6) & 0x1F;
                    return signExtend((rt << shiftAmt) & U32_MASK, 32);
                }
                // srl
                else if (fun == 0x02) {
                    return signExtend((rt & U32_MASK) >> ((insn >> 6) & 0x1F), 32);
                }
                // sra
                else if (fun == 0x03) {
                    uint32 shamt = (insn >> 6) & 0x1F;
                    return signExtend((rt & U32_MASK) >> shamt, 32 - shamt);
                }
                // sllv
                else if (fun == 0x04) {
                    uint64 shiftAmt = rs & 0x1F;
                    return signExtend((rt << shiftAmt) & U32_MASK, 32);
                }
                // srlv
                else if (fun == 0x6) {
                    return signExtend((rt & U32_MASK) >> (rs & 0x1F), 32);
                }
                // srav
                else if (fun == 0x07) {
                    // shamt here is different than the typical shamt which comes from the
                    // instruction itself, here it comes from the rs register
                    uint64 shamt = rs & 0x1F;
                    return signExtend((rt & U32_MASK) >> shamt, 32 - shamt);
                }
                // functs in range [0x8, 0x1b] are handled specially by other functions
                // Explicitly enumerate each funct in range to reduce code diff against Go Vm
                // jr
                else if (fun == 0x08) {
                    return rs;
                }
                // jalr
                else if (fun == 0x09) {
                    return rs;
                }
                // movz
                else if (fun == 0x0a) {
                    return rs;
                }
                // movn
                else if (fun == 0x0b) {
                    return rs;
                }
                // syscall
                else if (fun == 0x0c) {
                    return rs;
                }
                // 0x0d - break not supported
                // sync
                else if (fun == 0x0f) {
                    return rs;
                }
                // mfhi
                else if (fun == 0x10) {
                    return rs;
                }
                // mthi
                else if (fun == 0x11) {
                    return rs;
                }
                // mflo
                else if (fun == 0x12) {
                    return rs;
                }
                // mtlo
                else if (fun == 0x13) {
                    return rs;
                }
                // dsllv
                else if (fun == 0x14) {
                    return rt;
                }
                // dsrlv
                else if (fun == 0x16) {
                    return rt;
                }
                // dsrav
                else if (fun == 0x17) {
                    return rt;
                }
                // mult
                else if (fun == 0x18) {
                    return rs;
                }
                // multu
                else if (fun == 0x19) {
                    return rs;
                }
                // div
                else if (fun == 0x1a) {
                    return rs;
                }
                // divu
                else if (fun == 0x1b) {
                    return rs;
                }
                // dmult
                else if (fun == 0x1c) {
                    return rs;
                }
                // dmultu
                else if (fun == 0x1d) {
                    return rs;
                }
                // ddiv
                else if (fun == 0x1e) {
                    return rs;
                }
                // ddivu
                else if (fun == 0x1f) {
                    return rs;
                }
                // The rest includes transformed R-type arith imm instructions
                // add
                else if (fun == 0x20) {
                    return signExtend(uint64(uint32(rs) + uint32(rt)), 32);
                }
                // addu
                else if (fun == 0x21) {
                    return signExtend(uint64(uint32(rs) + uint32(rt)), 32);
                }
                // sub
                else if (fun == 0x22) {
                    return signExtend(uint64(uint32(rs) - uint32(rt)), 32);
                }
                // subu
                else if (fun == 0x23) {
                    return signExtend(uint64(uint32(rs) - uint32(rt)), 32);
                }
                // and
                else if (fun == 0x24) {
                    return (rs & rt);
                }
                // or
                else if (fun == 0x25) {
                    return (rs | rt);
                }
                // xor
                else if (fun == 0x26) {
                    return (rs ^ rt);
                }
                // nor
                else if (fun == 0x27) {
                    return ~(rs | rt);
                }
                // slti
                else if (fun == 0x2a) {
                    return int64(rs) < int64(rt) ? 1 : 0;
                }
                // sltiu
                else if (fun == 0x2b) {
                    return rs < rt ? 1 : 0;
                }
                // dadd
                else if (fun == 0x2c) {
                    return (rs + rt);
                }
                // daddu
                else if (fun == 0x2d) {
                    return (rs + rt);
                }
                // dsub
                else if (fun == 0x2e) {
                    return (rs - rt);
                }
                // dsubu
                else if (fun == 0x2f) {
                    return (rs - rt);
                }
                // dsll
                else if (fun == 0x38) {
                    return rt << ((insn >> 6) & 0x1f);
                }
                // dsrl
                else if (fun == 0x3A) {
                    return rt >> ((insn >> 6) & 0x1f);
                }
                // dsra
                else if (fun == 0x3B) {
                    return uint64(int64(rt) >> ((insn >> 6) & 0x1f));
                }
                // dsll32
                else if (fun == 0x3c) {
                    return rt << (((insn >> 6) & 0x1f) + 32);
                }
                // dsrl32
                else if (fun == 0x3e) {
                    return rt >> (((insn >> 6) & 0x1f) + 32);
                }
                // dsra32
                else if (fun == 0x3f) {
                    return uint64(int64(rt) >> (((insn >> 6) & 0x1f) + 32));
                } else {
                    revert("MIPS64: invalid instruction");
                }
            } else {
                // SPECIAL2
                if (opcode == 0x1C) {
                    // mul
                    if (fun == 0x2) {
                        return signExtend(uint32(int32(uint32(rs)) * int32(uint32(rt))), 32);
                    }
                    // clz, clo
                    else if (fun == 0x20 || fun == 0x21) {
                        if (fun == 0x20) {
                            rs = ~rs;
                        }
                        uint32 i = 0;
                        while (rs & 0x80000000 != 0) {
                            i++;
                            rs <<= 1;
                        }
                        return i;
                    }
                    // dclz, dclo
                    else if (fun == 0x24 || fun == 0x25) {
                        if (fun == 0x24) {
                            rs = ~rs;
                        }
                        uint32 i = 0;
                        while (rs & 0x80000000_00000000 != 0) {
                            i++;
                            rs <<= 1;
                        }
                        return i;
                    }
                }
                // lui
                else if (opcode == 0x0F) {
                    return signExtend(rt << 16, 32);
                }
                // lb
                else if (opcode == 0x20) {
                    return selectSubWord(rs, mem, 1, true);
                }
                // lh
                else if (opcode == 0x21) {
                    return selectSubWord(rs, mem, 2, true);
                }
                // lwl
                else if (opcode == 0x22) {
                    uint32 w = uint32(selectSubWord(rs, mem, 4, false));
                    uint32 val = w << uint32((rs & 3) * 8);
                    uint64 mask = uint64(U32_MASK << uint32((rs & 3) * 8));
                    return signExtend(((rt & ~mask) | uint64(val)) & U32_MASK, 32);
                }
                // lw
                else if (opcode == 0x23) {
                    return selectSubWord(rs, mem, 4, true);
                }
                // lbu
                else if (opcode == 0x24) {
                    return selectSubWord(rs, mem, 1, false);
                }
                //  lhu
                else if (opcode == 0x25) {
                    return selectSubWord(rs, mem, 2, false);
                }
                //  lwr
                else if (opcode == 0x26) {
                    uint32 w = uint32(selectSubWord(rs, mem, 4, false));
                    uint32 val = w >> (24 - (rs & 3) * 8);
                    uint32 mask = U32_MASK >> (24 - (rs & 3) * 8);
                    uint64 lwrResult = (uint32(rt) & ~mask) | val;
                    if (rs & 3 == 3) {
                        // loaded bit 31
                        return signExtend(uint64(lwrResult), 32);
                    } else {
                        // NOTE: cannon64 implementation specific: We leave the upper word untouched
                        uint64 rtMask = 0xFF_FF_FF_FF_00_00_00_00;
                        return ((rt & rtMask) | uint64(lwrResult));
                    }
                }
                //  sb
                else if (opcode == 0x28) {
                    return updateSubWord(rs, mem, 1, rt);
                }
                //  sh
                else if (opcode == 0x29) {
                    return updateSubWord(rs, mem, 2, rt);
                }
                //  swl
                else if (opcode == 0x2a) {
                    uint64 sr = (rs & 3) << 3;
                    uint64 val = ((rt & U32_MASK) >> sr) << (32 - ((rs & 0x4) << 3));
                    uint64 mask = (uint64(U32_MASK) >> sr) << (32 - ((rs & 0x4) << 3));
                    return (mem & ~mask) | val;
                }
                //  sw
                else if (opcode == 0x2b) {
                    return updateSubWord(rs, mem, 4, rt);
                }
                //  swr
                else if (opcode == 0x2e) {
                    uint32 w = uint32(selectSubWord(rs, mem, 4, false));
                    uint64 val = rt << (24 - (rs & 3) * 8);
                    uint64 mask = U32_MASK << uint32(24 - (rs & 3) * 8);
                    uint64 swrResult = (w & ~mask) | uint32(val);
                    return updateSubWord(rs, mem, 4, swrResult);
                }
                // MIPS64
                //  ldl
                else if (opcode == 0x1a) {
                    uint64 sl = (rs & 0x7) << 3;
                    uint64 val = mem << sl;
                    uint64 mask = U64_MASK << sl;
                    return (val | (rt & ~mask));
                }
                //  ldr
                else if (opcode == 0x1b) {
                    uint64 sr = 56 - ((rs & 0x7) << 3);
                    uint64 val = mem >> sr;
                    uint64 mask = U64_MASK << (64 - sr);
                    return (val | (rt & mask));
                }
                //  lwu
                else if (opcode == 0x27) {
                    return ((mem >> (32 - ((rs & 0x4) << 3))) & U32_MASK);
                }
                //  sdl
                else if (opcode == 0x2c) {
                    uint64 sr = (rs & 0x7) << 3;
                    uint64 val = rt >> sr;
                    uint64 mask = U64_MASK >> sr;
                    return (val | (mem & ~mask));
                }
                //  sdr
                else if (opcode == 0x2d) {
                    uint64 sl = 56 - ((rs & 0x7) << 3);
                    uint64 val = rt << sl;
                    uint64 mask = U64_MASK << sl;
                    return (val | (mem & ~mask));
                }
                //  ld
                else if (opcode == 0x37) {
                    return mem;
                }
                //  sd
                else if (opcode == 0x3F) {
                    return rt;
                } else {
                    revert("MIPS64: invalid instruction");
                }
            }
            revert("MIPS64: invalid instruction");
        }
    }

    /// @notice Extends the value leftwards with its most significant bit (sign extension).
    function signExtend(uint64 _dat, uint64 _idx) internal pure returns (uint64 out_) {
        unchecked {
            bool isSigned = (_dat >> (_idx - 1)) & 1 != 0;
            uint256 signed = ((1 << (MIPS64Arch.WORD_SIZE - _idx)) - 1) << _idx;
            uint256 mask = (1 << _idx) - 1;
            return uint64(_dat & mask | (isSigned ? signed : 0));
        }
    }

    /// @notice Handles a branch instruction, updating the MIPS state PC where needed.
    /// @param _cpu Holds the state of cpu scalars pc, nextPC, hi, lo.
    /// @param _registers Holds the current state of the cpu registers.
    /// @param _opcode The opcode of the branch instruction.
    /// @param _insn The instruction to be executed.
    /// @param _rtReg The register to be used for the branch.
    /// @param _rs The register to be compared with the branch register.
    function handleBranch(
        MIPS64State.CpuScalars memory _cpu,
        uint64[32] memory _registers,
        uint32 _opcode,
        uint32 _insn,
        uint64 _rtReg,
        uint64 _rs
    )
        internal
        pure
    {
        unchecked {
            bool shouldBranch = false;

            if (_cpu.nextPC != _cpu.pc + 4) {
                revert("MIPS64: branch in delay slot");
            }

            // beq/bne: Branch on equal / not equal
            if (_opcode == 4 || _opcode == 5) {
                uint64 rt = _registers[_rtReg];
                shouldBranch = (_rs == rt && _opcode == 4) || (_rs != rt && _opcode == 5);
            }
            // blez: Branches if instruction is less than or equal to zero
            else if (_opcode == 6) {
                shouldBranch = int64(_rs) <= 0;
            }
            // bgtz: Branches if instruction is greater than zero
            else if (_opcode == 7) {
                shouldBranch = int64(_rs) > 0;
            }
            // bltz/bgez: Branch on less than zero / greater than or equal to zero
            else if (_opcode == 1) {
                // regimm
                uint32 rtv = ((_insn >> 16) & 0x1F);
                if (rtv == 0) {
                    shouldBranch = int64(_rs) < 0;
                }
                // bltzal
                if (rtv == 0x10) {
                    shouldBranch = int64(_rs) < 0;
                    _registers[REG_RA] = _cpu.pc + 8; // always set regardless of branch taken
                }
                if (rtv == 1) {
                    shouldBranch = int64(_rs) >= 0;
                }
                // bgezal (i.e. bal mnemonic)
                if (rtv == 0x11) {
                    shouldBranch = int64(_rs) >= 0;
                    _registers[REG_RA] = _cpu.pc + 8; // always set regardless of branch taken
                }
            }

            // Update the state's previous PC
            uint64 prevPC = _cpu.pc;

            // Execute the delay slot first
            _cpu.pc = _cpu.nextPC;

            // If we should branch, update the PC to the branch target
            // Otherwise, proceed to the next instruction
            if (shouldBranch) {
                _cpu.nextPC = prevPC + 4 + (signExtend(_insn & 0xFFFF, 16) << 2);
            } else {
                _cpu.nextPC = _cpu.nextPC + 4;
            }
        }
    }

    /// @notice Handles HI and LO register instructions. It also additionally handles doubleword variable shift
    /// operations
    /// @param _cpu Holds the state of cpu scalars pc, nextPC, hi, lo.
    /// @param _registers Holds the current state of the cpu registers.
    /// @param _fun The function code of the instruction.
    /// @param _rs The value of the RS register.
    /// @param _rt The value of the RT register.
    /// @param _storeReg The register to store the result in.
    function handleHiLo(
        MIPS64State.CpuScalars memory _cpu,
        uint64[32] memory _registers,
        uint32 _fun,
        uint64 _rs,
        uint64 _rt,
        uint64 _storeReg
    )
        internal
        pure
    {
        unchecked {
            uint64 val = 0;

            // mfhi: Move the contents of the HI register into the destination
            if (_fun == 0x10) {
                val = _cpu.hi;
            }
            // mthi: Move the contents of the source into the HI register
            else if (_fun == 0x11) {
                _cpu.hi = _rs;
            }
            // mflo: Move the contents of the LO register into the destination
            else if (_fun == 0x12) {
                val = _cpu.lo;
            }
            // mtlo: Move the contents of the source into the LO register
            else if (_fun == 0x13) {
                _cpu.lo = _rs;
            }
            // mult: Multiplies `rs` by `rt` and stores the result in HI and LO registers
            else if (_fun == 0x18) {
                uint64 acc = uint64(int64(int32(uint32(_rs))) * int64(int32(uint32(_rt))));
                _cpu.hi = signExtend(uint64(acc >> 32), 32);
                _cpu.lo = signExtend(uint64(uint32(acc)), 32);
            }
            // multu: Unsigned multiplies `rs` by `rt` and stores the result in HI and LO registers
            else if (_fun == 0x19) {
                uint64 acc = uint64(uint32(_rs)) * uint64(uint32(_rt));
                _cpu.hi = signExtend(uint64(acc >> 32), 32);
                _cpu.lo = signExtend(uint64(uint32(acc)), 32);
            }
            // div: Divides `rs` by `rt`.
            // Stores the quotient in LO
            // And the remainder in HI
            else if (_fun == 0x1a) {
                if (uint32(_rt) == 0) {
                    revert("MIPS64: division by zero");
                }
                _cpu.hi = signExtend(uint32(int32(uint32(_rs)) % int32(uint32(_rt))), 32);
                _cpu.lo = signExtend(uint32(int32(uint32(_rs)) / int32(uint32(_rt))), 32);
            }
            // divu: Unsigned divides `rs` by `rt`.
            // Stores the quotient in LO
            // And the remainder in HI
            else if (_fun == 0x1b) {
                if (uint32(_rt) == 0) {
                    revert("MIPS64: division by zero");
                }
                _cpu.hi = signExtend(uint64(uint32(_rs) % uint32(_rt)), 32);
                _cpu.lo = signExtend(uint64(uint32(_rs) / uint32(_rt)), 32);
            }
            // dsllv
            else if (_fun == 0x14) {
                val = _rt << (_rs & 0x3F);
            }
            // dsrlv
            else if (_fun == 0x16) {
                val = _rt >> (_rs & 0x3F);
            }
            // dsrav
            else if (_fun == 0x17) {
                val = uint64(int64(_rt) >> (_rs & 0x3F));
            }
            // dmult
            else if (_fun == 0x1c) {
                int128 res = int128(int64(_rs)) * int128(int64(_rt));
                _cpu.hi = uint64(int64(res >> 64));
                _cpu.lo = uint64(uint128(res) & U64_MASK);
            }
            // dmultu
            else if (_fun == 0x1d) {
                uint128 res = uint128(_rs) * uint128(_rt);
                _cpu.hi = uint64(res >> 64);
                _cpu.lo = uint64(res);
            }
            // ddiv
            else if (_fun == 0x1e) {
                if (_rt == 0) {
                    revert("MIPS64: division by zero");
                }
                _cpu.hi = uint64(int64(_rs) % int64(_rt));
                _cpu.lo = uint64(int64(_rs) / int64(_rt));
            }
            // ddivu
            else if (_fun == 0x1f) {
                if (_rt == 0) {
                    revert("MIPS64: division by zero");
                }
                _cpu.hi = _rs % _rt;
                _cpu.lo = _rs / _rt;
            }

            // Store the result in the destination register, if applicable
            if (_storeReg != 0) {
                _registers[_storeReg] = val;
            }

            // Update the PC
            _cpu.pc = _cpu.nextPC;
            _cpu.nextPC = _cpu.nextPC + 4;
        }
    }

    /// @notice Handles a jump instruction, updating the MIPS state PC where needed.
    /// @dev The _cpuAndRegisters is stored in memory to avoid stack limit issues.
    /// @param _cpuAndRegisters Holds the state of cpu scalars (pc, nextPC, hi, lo) and the current state of the cpu
    /// registers.
    /// @param _linkReg The register to store the link to the instruction after the delay slot instruction.
    /// @param _dest The destination to jump to.
    function handleJump(CoreStepLogicParams memory _cpuAndRegisters, uint64 _linkReg, uint64 _dest) internal pure {
        unchecked {
            if (_cpuAndRegisters.cpu.nextPC != _cpuAndRegisters.cpu.pc + 4) {
                revert("MIPS64: jump in delay slot");
            }

            // Update the next PC to the jump destination.
            uint64 prevPC = _cpuAndRegisters.cpu.pc;
            _cpuAndRegisters.cpu.pc = _cpuAndRegisters.cpu.nextPC;
            _cpuAndRegisters.cpu.nextPC = _dest;

            // Update the link-register to the instruction after the delay slot instruction.
            if (_linkReg != 0) {
                _cpuAndRegisters.registers[_linkReg] = prevPC + 8;
            }
        }
    }

    /// @notice Handles a storing a value into a register.
    /// @param _cpu Holds the state of cpu scalars pc, nextPC, hi, lo.
    /// @param _registers Holds the current state of the cpu registers.
    /// @param _storeReg The register to store the value into.
    /// @param _val The value to store.
    /// @param _conditional Whether or not the store is conditional.
    function handleRd(
        MIPS64State.CpuScalars memory _cpu,
        uint64[32] memory _registers,
        uint64 _storeReg,
        uint64 _val,
        bool _conditional
    )
        internal
        pure
    {
        unchecked {
            // The destination register must be valid.
            require(_storeReg < 32, "MIPS64: valid register");

            // Never write to reg 0, and it can be conditional (movz, movn).
            if (_storeReg != 0 && _conditional) {
                _registers[_storeReg] = _val;
            }

            // Update the PC.
            _cpu.pc = _cpu.nextPC;
            _cpu.nextPC = _cpu.nextPC + 4;
        }
    }

    /// @notice Selects a subword of byteLength size contained in memWord based on the low-order bits of vaddr
    /// @param _vaddr The virtual address of the the subword.
    /// @param _memWord The full word to select a subword from.
    /// @param _byteLength The size of the subword.
    /// @param _signExtend Whether to sign extend the selected subwrod.
    function selectSubWord(
        uint64 _vaddr,
        uint64 _memWord,
        uint64 _byteLength,
        bool _signExtend
    )
        internal
        pure
        returns (uint64 retval_)
    {
        (uint64 dataMask, uint64 bitOffset, uint64 bitLength) = calculateSubWordMaskAndOffset(_vaddr, _byteLength);
        retval_ = (_memWord >> bitOffset) & dataMask;
        if (_signExtend) {
            retval_ = signExtend(retval_, bitLength);
        }
        return retval_;
    }

    /// @notice Returns a word that has been updated by the specified subword at bit positions determined by the virtual
    /// address
    /// @param _vaddr The virtual address of the subword.
    /// @param _memWord The full word to update.
    /// @param _byteLength The size of the subword.
    /// @param _value The subword that updates _memWord.
    function updateSubWord(
        uint64 _vaddr,
        uint64 _memWord,
        uint64 _byteLength,
        uint64 _value
    )
        internal
        pure
        returns (uint64 word_)
    {
        (uint64 dataMask, uint64 bitOffset,) = calculateSubWordMaskAndOffset(_vaddr, _byteLength);
        uint64 subWordValue = dataMask & _value;
        uint64 memUpdateMask = dataMask << bitOffset;
        return subWordValue << bitOffset | (~memUpdateMask) & _memWord;
    }

    function calculateSubWordMaskAndOffset(
        uint64 _vaddr,
        uint64 _byteLength
    )
        internal
        pure
        returns (uint64 dataMask_, uint64 bitOffset_, uint64 bitLength_)
    {
        uint64 bitLength = _byteLength << 3;
        uint64 dataMask = ~uint64(0) >> (MIPS64Arch.WORD_SIZE - bitLength);

        // Figure out sub-word index based on the low-order bits in vaddr
        uint64 byteIndexMask = _vaddr & MIPS64Arch.EXT_MASK & ~(_byteLength - 1);
        uint64 maxByteShift = MIPS64Arch.WORD_SIZE_BYTES - _byteLength;
        uint64 byteIndex = _vaddr & byteIndexMask;
        uint64 bitOffset = (maxByteShift - byteIndex) << 3;

        return (dataMask, bitOffset, bitLength);
    }
}

/// @notice Thrown when an RMW instruction is expected, but a different instruction is provided.
error InvalidRMWInstruction();

/// @title LibVMStatus
/// @notice This library contains helper functions for working with the `VMStatus` type.
library LibVMStatus {
    /// @notice Get the value of a `VMStatus` type in the form of the underlying uint8.
    /// @param _vmstatus The `VMStatus` type to get the value of.
    /// @return vmstatus_ The value of the `VMStatus` type as a uint8 type.
    function raw(VMStatus _vmstatus) internal pure returns (uint8 vmstatus_) {
        assembly {
            vmstatus_ := _vmstatus
        }
    }
}

using LibVMStatus for VMStatus global;

/// @notice A `VMStatus` represents the status of a VM execution.
type VMStatus is uint8;

/// @title VMStatuses
/// @notice Named type aliases for the various valid VM status bytes.
library VMStatuses {
    /// @notice The VM has executed successfully and the outcome is valid.
    VMStatus internal constant VALID = VMStatus.wrap(0);

    /// @notice The VM has executed successfully and the outcome is invalid.
    VMStatus internal constant INVALID = VMStatus.wrap(1);

    /// @notice The VM has paniced.
    VMStatus internal constant PANIC = VMStatus.wrap(2);

    /// @notice The VM execution is still in progress.
    VMStatus internal constant UNFINISHED = VMStatus.wrap(3);
}

/// @notice Thrown when the second memory location is invalid
error InvalidSecondMemoryProof();

/// @title MIPS64
/// @notice The MIPS64 contract emulates a single MIPS instruction.
///         It differs from MIPS.sol in that it supports MIPS64 instructions and multi-tasking.
contract MIPS64 is ISemver {
    /// @notice The thread context.
    ///         Total state size: 8 + 1 + 1 + 8 + 8 + 8 + 8 + 32 * 8 = 298 bytes
    struct ThreadState {
        // metadata
        uint64 threadID;
        uint8 exitCode;
        bool exited;
        // state
        uint64 pc;
        uint64 nextPC;
        uint64 lo;
        uint64 hi;
        uint64[32] registers;
    }

    uint32 internal constant PACKED_THREAD_STATE_SIZE = 298;

    uint8 internal constant LL_STATUS_NONE = 0;
    uint8 internal constant LL_STATUS_ACTIVE_32_BIT = 0x1;
    uint8 internal constant LL_STATUS_ACTIVE_64_BIT = 0x2;

    /// @notice Stores the VM state.
    ///         Total state size: 32 + 32 + 8 + 8 + 1 + 8 + 8 + 1 + 1 + 8 + 8 + 1 + 32 + 32 + 8 = 188 bytes
    ///         If nextPC != pc + 4, then the VM is executing a branch/jump delay slot.
    struct State {
        bytes32 memRoot;
        bytes32 preimageKey;
        uint64 preimageOffset;
        uint64 heap;
        uint8 llReservationStatus;
        uint64 llAddress;
        uint64 llOwnerThread;
        uint8 exitCode;
        bool exited;
        uint64 step;
        uint64 stepsSinceLastContextSwitch;
        bool traverseRight;
        bytes32 leftThreadStack;
        bytes32 rightThreadStack;
        uint64 nextThreadID;
    }

    /// @notice The semantic version of the MIPS64 contract.
    /// @custom:semver 1.9.0
    string public constant version = "1.9.0";

    /// @notice The preimage oracle contract.
    IPreimageOracle internal immutable ORACLE;

    /// @notice The state version implemented. This identifies the specific state transition rules applied.
    uint256 internal immutable STATE_VERSION;

    // The offset of the start of proof calldata (_threadWitness.offset) in the step() function
    uint256 internal constant THREAD_PROOF_OFFSET = 356;

    // The offset of the start of proof calldata (_memProof.offset) in the step() function
    uint256 internal constant MEM_PROOF_OFFSET = THREAD_PROOF_OFFSET + PACKED_THREAD_STATE_SIZE + 32;

    // The empty thread root - keccak256(bytes32(0) ++ bytes32(0))
    bytes32 internal constant EMPTY_THREAD_ROOT = hex"ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5";

    // State memory offset allocated during step
    uint256 internal constant STATE_MEM_OFFSET = 0x80;

    // ThreadState memory offset allocated during step
    uint256 internal constant TC_MEM_OFFSET = 0x260;

    /// @param _oracle The address of the preimage oracle contract.
    constructor(IPreimageOracle _oracle, uint256 _stateVersion) {
        // Supports VersionMultiThreaded64_v4 (7) and VersionMultiThreaded64_v5 (8)
        if (_stateVersion != 7 && _stateVersion != 8) {
            revert UnsupportedStateVersion();
        }
        ORACLE = _oracle;
        STATE_VERSION = _stateVersion;
    }

    /// @notice Getter for the pre-image oracle contract.
    /// @return oracle_ The IPreimageOracle contract.
    function oracle() external view returns (IPreimageOracle oracle_) {
        oracle_ = ORACLE;
    }

    /// @notice Getter for the state version.
    /// @return stateVersion_ The state version implemented by this contract.
    function stateVersion() external view returns (uint256 stateVersion_) {
        stateVersion_ = STATE_VERSION;
    }

    /// @notice Executes a single step of the multi-threaded vm.
    ///         Will revert if any required input state is missing.
    /// @param _stateData The encoded state witness data.
    /// @param _proof The encoded proof data: <<thread_context, inner_root>, <memory proof>.
    ///               Contains the thread context witness and the memory proof data for leaves within the MIPS VM's
    /// memory.
    ///               The thread context witness is a packed tuple of the thread context and the immediate inner root of
    /// the current thread stack.
    /// @param _localContext The local key context for the preimage oracle. Optional, can be set as a constant
    ///                      if the caller only requires one set of local keys.
    /// @return postState_ The hash of the post state witness after the state transition.
    function step(
        bytes calldata _stateData,
        bytes calldata _proof,
        bytes32 _localContext
    )
        public
        returns (bytes32 postState_)
    {
        postState_ = doStep(_stateData, _proof, _localContext);
        assertPostStateChecks();
    }

    function assertPostStateChecks() internal pure {
        State memory state;
        assembly {
            state := STATE_MEM_OFFSET
        }

        bytes32 activeStack = state.traverseRight ? state.rightThreadStack : state.leftThreadStack;
        if (activeStack == EMPTY_THREAD_ROOT) {
            revert("MIPS64: post-state active thread stack is empty");
        }
    }

    function doStep(
        bytes calldata _stateData,
        bytes calldata _proof,
        bytes32 _localContext
    )
        internal
        returns (bytes32)
    {
        unchecked {
            State memory state;
            ThreadState memory thread;
            uint32 exited;
            assembly {
                if iszero(eq(state, STATE_MEM_OFFSET)) {
                    // expected state mem offset check
                    revert(0, 0)
                }
                if iszero(eq(thread, TC_MEM_OFFSET)) {
                    // expected thread mem offset check
                    // STATE_MEM_OFFSET = 0x80 = 128
                    // 32 bytes per state field = 32 * 15 = 480
                    // TC_MEM_OFFSET = 480 + 128 = 608 = 0x260
                    revert(0, 0)
                }
                if iszero(eq(mload(0x40), shl(5, 59))) {
                    // 4 + 15 state slots + 40 thread slots = 59 expected memory check
                    revert(0, 0)
                }
                if iszero(eq(_stateData.offset, 132)) {
                    // 32*4+4=132 expected state data offset
                    revert(0, 0)
                }
                if iszero(eq(_proof.offset, THREAD_PROOF_OFFSET)) {
                    // _stateData.offset = 132
                    // stateData.length = ceil(stateSize / 32) * 32 = 6 * 32 = 192
                    // _proof size prefix = 32
                    // expected thread proof offset equals the sum of the above is 356
                    revert(0, 0)
                }

                function putField(callOffset, memOffset, size) -> callOffsetOut, memOffsetOut {
                    // calldata is packed, thus starting left-aligned, shift-right to pad and right-align
                    let w := shr(shl(3, sub(32, size)), calldataload(callOffset))
                    mstore(memOffset, w)
                    callOffsetOut := add(callOffset, size)
                    memOffsetOut := add(memOffset, 32)
                }

                // Unpack state from calldata into memory
                let c := _stateData.offset // calldata offset
                let m := STATE_MEM_OFFSET // mem offset
                c, m := putField(c, m, 32) // memRoot
                c, m := putField(c, m, 32) // preimageKey
                c, m := putField(c, m, 8) // preimageOffset
                c, m := putField(c, m, 8) // heap
                c, m := putField(c, m, 1) // llReservationStatus
                c, m := putField(c, m, 8) // llAddress
                c, m := putField(c, m, 8) // llOwnerThread
                c, m := putField(c, m, 1) // exitCode
                c, m := putField(c, m, 1) // exited
                exited := mload(sub(m, 32))
                c, m := putField(c, m, 8) // step
                c, m := putField(c, m, 8) // stepsSinceLastContextSwitch
                c, m := putField(c, m, 1) // traverseRight
                c, m := putField(c, m, 32) // leftThreadStack
                c, m := putField(c, m, 32) // rightThreadStack
                c, m := putField(c, m, 8) // nextThreadID
            }
            MIPS64State.assertExitedIsValid(exited);

            if (state.exited) {
                // thread state is unchanged
                return outputState();
            }

            if (
                (state.leftThreadStack == EMPTY_THREAD_ROOT && !state.traverseRight)
                    || (state.rightThreadStack == EMPTY_THREAD_ROOT && state.traverseRight)
            ) {
                revert("MIPS64: active thread stack is empty");
            }

            state.step += 1;

            setThreadStateFromCalldata(thread);
            validateCalldataThreadWitness(state, thread);

            if (thread.exited) {
                popThread(state);
                return outputState();
            }

            if (state.stepsSinceLastContextSwitch >= MIPS64Syscalls.SCHED_QUANTUM) {
                preemptThread(state, thread);
                return outputState();
            }
            state.stepsSinceLastContextSwitch += 1;

            // instruction fetch
            uint256 insnProofOffset = MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 0);
            (uint32 insn, uint32 opcode, uint32 fun) =
                MIPS64Instructions.getInstructionDetails(thread.pc, state.memRoot, insnProofOffset);

            // Handle syscall separately
            // syscall (can read and write)
            if (opcode == 0 && fun == 0xC) {
                return handleSyscall(_localContext);
            }

            // Handle RMW (read-modify-write) ops
            if (opcode == MIPS64Instructions.OP_LOAD_LINKED || opcode == MIPS64Instructions.OP_STORE_CONDITIONAL) {
                return handleRMWOps(state, thread, insn, opcode);
            }
            if (opcode == MIPS64Instructions.OP_LOAD_LINKED64 || opcode == MIPS64Instructions.OP_STORE_CONDITIONAL64) {
                return handleRMWOps(state, thread, insn, opcode);
            }

            // Exec the rest of the step logic
            MIPS64State.CpuScalars memory cpu = getCpuScalars(thread);
            MIPS64Instructions.CoreStepLogicParams memory coreStepArgs = MIPS64Instructions.CoreStepLogicParams({
                cpu: cpu,
                registers: thread.registers,
                memRoot: state.memRoot,
                memProofOffset: MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 1),
                insn: insn,
                opcode: opcode,
                fun: fun
            });
            bool memUpdated;
            uint64 effMemAddr;
            (state.memRoot, memUpdated, effMemAddr) = MIPS64Instructions.execMipsCoreStepLogic(coreStepArgs);
            setStateCpuScalars(thread, cpu);
            updateCurrentThreadRoot();
            if (memUpdated) {
                handleMemoryUpdate(state, effMemAddr);
            }

            return outputState();
        }
    }

    function handleMemoryUpdate(State memory _state, uint64 _effMemAddr) internal pure {
        if (_effMemAddr == (MIPS64Arch.ADDRESS_MASK & _state.llAddress)) {
            // Reserved address was modified, clear the reservation
            clearLLMemoryReservation(_state);
        }
    }

    function clearLLMemoryReservation(State memory _state) internal pure {
        _state.llReservationStatus = LL_STATUS_NONE;
        _state.llAddress = 0;
        _state.llOwnerThread = 0;
    }

    function handleRMWOps(
        State memory _state,
        ThreadState memory _thread,
        uint32 _insn,
        uint32 _opcode
    )
        internal
        returns (bytes32)
    {
        unchecked {
            uint64 base = _thread.registers[(_insn >> 21) & 0x1F];
            uint32 rtReg = (_insn >> 16) & 0x1F;
            uint64 addr = base + MIPS64Instructions.signExtendImmediate(_insn);

            // Determine some opcode-specific parameters
            uint8 targetStatus = LL_STATUS_ACTIVE_32_BIT;
            uint64 byteLength = 4;
            if (_opcode == MIPS64Instructions.OP_LOAD_LINKED64 || _opcode == MIPS64Instructions.OP_STORE_CONDITIONAL64) {
                // Use 64-bit params
                targetStatus = LL_STATUS_ACTIVE_64_BIT;
                byteLength = 8;
            }

            uint64 retVal = 0;
            uint64 threadId = _thread.threadID;
            if (_opcode == MIPS64Instructions.OP_LOAD_LINKED || _opcode == MIPS64Instructions.OP_LOAD_LINKED64) {
                retVal = loadSubWord(_state, addr, byteLength, true);

                _state.llReservationStatus = targetStatus;
                _state.llAddress = addr;
                _state.llOwnerThread = threadId;
            } else if (_opcode == MIPS64Instructions.OP_STORE_CONDITIONAL || _opcode == MIPS64Instructions.OP_STORE_CONDITIONAL64) {
                // Check if our memory reservation is still intact
                if (
                    _state.llReservationStatus == targetStatus && _state.llOwnerThread == threadId
                        && _state.llAddress == addr
                ) {
                    // Complete atomic update: set memory and return 1 for success
                    clearLLMemoryReservation(_state);

                    uint64 val = _thread.registers[rtReg];
                    storeSubWord(_state, addr, byteLength, val);

                    retVal = 1;
                } else {
                    // Atomic update failed, return 0 for failure
                    retVal = 0;
                }
            } else {
                revert InvalidRMWInstruction();
            }

            MIPS64State.CpuScalars memory cpu = getCpuScalars(_thread);
            MIPS64Instructions.handleRd(cpu, _thread.registers, rtReg, retVal, true);
            setStateCpuScalars(_thread, cpu);
            updateCurrentThreadRoot();

            return outputState();
        }
    }

    /// @notice Loads a subword of byteLength size contained from memory based on the low-order bits of vaddr
    /// @param _vaddr The virtual address of the the subword.
    /// @param _byteLength The size of the subword.
    /// @param _signExtend Whether to sign extend the selected subwrod.
    function loadSubWord(
        State memory _state,
        uint64 _vaddr,
        uint64 _byteLength,
        bool _signExtend
    )
        internal
        pure
        returns (uint64 val_)
    {
        uint64 effAddr = _vaddr & MIPS64Arch.ADDRESS_MASK;
        uint256 memProofOffset = MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 1);
        uint64 mem = MIPS64Memory.readMem(_state.memRoot, effAddr, memProofOffset);
        val_ = MIPS64Instructions.selectSubWord(_vaddr, mem, _byteLength, _signExtend);
    }

    /// @notice Stores a word that has been updated by the specified subword at bit positions determined by the virtual
    /// address
    /// @param _vaddr The virtual address of the subword.
    /// @param _byteLength The size of the subword.
    /// @param _value The subword that updates _memWord.
    function storeSubWord(State memory _state, uint64 _vaddr, uint64 _byteLength, uint64 _value) internal pure {
        uint64 effAddr = _vaddr & MIPS64Arch.ADDRESS_MASK;
        uint256 memProofOffset = MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 1);
        uint64 mem = MIPS64Memory.readMem(_state.memRoot, effAddr, memProofOffset);

        uint64 newMemVal = MIPS64Instructions.updateSubWord(_vaddr, mem, _byteLength, _value);
        _state.memRoot = MIPS64Memory.writeMem(effAddr, memProofOffset, newMemVal);
    }

    function handleSyscall(bytes32 _localContext) internal returns (bytes32 out_) {
        unchecked {
            // Load state from memory offsets to reduce stack pressure
            State memory state;
            ThreadState memory thread;
            assembly {
                state := STATE_MEM_OFFSET
                thread := TC_MEM_OFFSET
            }

            // Load the syscall numbers and args from the registers
            (uint64 syscall_no, uint64 a0, uint64 a1, uint64 a2) = MIPS64Syscalls.getSyscallArgs(thread.registers);
            // Syscalls that are unimplemented but known return with v0=0 and v1=0
            uint64 v0 = 0;
            uint64 v1 = 0;

            if (syscall_no == MIPS64Syscalls.SYS_MMAP) {
                (v0, v1, state.heap) = MIPS64Syscalls.handleSysMmap(a0, a1, state.heap);
            } else if (syscall_no == MIPS64Syscalls.SYS_BRK) {
                // brk: Returns a fixed address for the program break at 0x40000000
                v0 = MIPS64Syscalls.PROGRAM_BREAK;
            } else if (syscall_no == MIPS64Syscalls.SYS_CLONE) {
                if (MIPS64Syscalls.VALID_SYS_CLONE_FLAGS != a0) {
                    state.exited = true;
                    state.exitCode = VMStatuses.PANIC.raw();
                    return outputState();
                }
                v0 = state.nextThreadID;
                v1 = 0;
                ThreadState memory newThread;
                newThread.threadID = state.nextThreadID;
                newThread.exitCode = 0;
                newThread.exited = false;
                newThread.pc = thread.nextPC;
                newThread.nextPC = thread.nextPC + 4;
                newThread.lo = thread.lo;
                newThread.hi = thread.hi;
                for (uint256 i; i < 32; i++) {
                    newThread.registers[i] = thread.registers[i];
                }
                newThread.registers[29] = a1; // set stack pointer
                // the child will perceive a 0 value as returned value instead, and no error
                newThread.registers[2] = 0;
                newThread.registers[7] = 0;
                state.nextThreadID++;

                // Preempt this thread for the new one. But not before updating PCs
                MIPS64State.CpuScalars memory cpu0 = getCpuScalars(thread);
                MIPS64Syscalls.handleSyscallUpdates(cpu0, thread.registers, v0, v1);
                setStateCpuScalars(thread, cpu0);
                updateCurrentThreadRoot();
                pushThread(state, newThread);
                return outputState();
            } else if (syscall_no == MIPS64Syscalls.SYS_EXIT_GROUP) {
                // exit group: Sets the Exited and ExitCode states to true and argument 0.
                state.exited = true;
                state.exitCode = uint8(a0);
                updateCurrentThreadRoot();
                return outputState();
            } else if (syscall_no == MIPS64Syscalls.SYS_READ) {
                MIPS64Syscalls.SysReadParams memory args = MIPS64Syscalls.SysReadParams({
                    a0: a0,
                    a1: a1,
                    a2: a2,
                    preimageKey: state.preimageKey,
                    preimageOffset: state.preimageOffset,
                    localContext: _localContext,
                    oracle: ORACLE,
                    proofOffset: MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 1),
                    memRoot: state.memRoot
                });
                // Encapsulate execution to avoid stack-too-deep error
                (v0, v1) = execSysRead(state, args);
            } else if (syscall_no == MIPS64Syscalls.SYS_WRITE) {
                MIPS64Syscalls.SysWriteParams memory args = MIPS64Syscalls.SysWriteParams({
                    _a0: a0,
                    _a1: a1,
                    _a2: a2,
                    _preimageKey: state.preimageKey,
                    _preimageOffset: state.preimageOffset,
                    _proofOffset: MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 1),
                    _memRoot: state.memRoot
                });
                (v0, v1, state.preimageKey, state.preimageOffset) = MIPS64Syscalls.handleSysWrite(args);
            } else if (syscall_no == MIPS64Syscalls.SYS_FCNTL) {
                (v0, v1) = MIPS64Syscalls.handleSysFcntl(a0, a1);
            } else if (syscall_no == MIPS64Syscalls.SYS_GETTID) {
                v0 = thread.threadID;
                v1 = 0;
            } else if (syscall_no == MIPS64Syscalls.SYS_EXIT) {
                thread.exited = true;
                thread.exitCode = uint8(a0);
                if (lastThreadRemaining(state)) {
                    state.exited = true;
                    state.exitCode = uint8(a0);
                }
                updateCurrentThreadRoot();
                return outputState();
            } else if (syscall_no == MIPS64Syscalls.SYS_FUTEX) {
                // args: a0 = addr, a1 = op, a2 = val, a3 = timeout
                // Futex value is 32-bit, so clear the lower 2 bits to get an effective address targeting a 4-byte value
                uint64 effFutexAddr = a0 & 0xFFFFFFFFFFFFFFFC;
                if (a1 == MIPS64Syscalls.FUTEX_WAIT_PRIVATE) {
                    uint32 futexVal = getFutexValue(effFutexAddr);
                    uint32 targetVal = uint32(a2);
                    if (futexVal != targetVal) {
                        v0 = MIPS64Syscalls.EAGAIN;
                        v1 = MIPS64Syscalls.SYS_ERROR_SIGNAL;
                    } else {
                        return syscallYield(state, thread);
                    }
                } else if (a1 == MIPS64Syscalls.FUTEX_WAKE_PRIVATE) {
                    return syscallYield(state, thread);
                } else {
                    v0 = MIPS64Syscalls.EINVAL;
                    v1 = MIPS64Syscalls.SYS_ERROR_SIGNAL;
                }
            } else if (syscall_no == MIPS64Syscalls.SYS_SCHED_YIELD || syscall_no == MIPS64Syscalls.SYS_NANOSLEEP) {
                return syscallYield(state, thread);
            } else if (syscall_no == MIPS64Syscalls.SYS_OPEN) {
                v0 = MIPS64Syscalls.EBADF;
                v1 = MIPS64Syscalls.SYS_ERROR_SIGNAL;
            } else if (syscall_no == MIPS64Syscalls.SYS_CLOCKGETTIME) {
                if (a0 == MIPS64Syscalls.CLOCK_GETTIME_REALTIME_FLAG || a0 == MIPS64Syscalls.CLOCK_GETTIME_MONOTONIC_FLAG) {
                    v0 = 0;
                    v1 = 0;
                    uint64 secs = 0;
                    uint64 nsecs = 0;
                    if (a0 == MIPS64Syscalls.CLOCK_GETTIME_MONOTONIC_FLAG) {
                        secs = uint64(state.step / MIPS64Syscalls.HZ);
                        nsecs = uint64((state.step % MIPS64Syscalls.HZ) * (1_000_000_000 / MIPS64Syscalls.HZ));
                    }
                    uint64 effAddr = a1 & MIPS64Arch.ADDRESS_MASK;
                    // First verify the effAddr path
                    if (
                        !MIPS64Memory.isValidProof(
                            state.memRoot, effAddr, MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 1)
                        )
                    ) {
                        revert InvalidMemoryProof();
                    }
                    // Recompute the new root after updating effAddr
                    state.memRoot =
                        MIPS64Memory.writeMem(effAddr, MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 1), secs);
                    handleMemoryUpdate(state, effAddr);
                    // Verify the second memory proof against the newly computed root
                    if (
                        !MIPS64Memory.isValidProof(
                            state.memRoot, effAddr + 8, MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 2)
                        )
                    ) {
                        revert InvalidSecondMemoryProof();
                    }
                    state.memRoot =
                        MIPS64Memory.writeMem(effAddr + 8, MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 2), nsecs);
                    handleMemoryUpdate(state, effAddr + 8);
                } else {
                    v0 = MIPS64Syscalls.EINVAL;
                    v1 = MIPS64Syscalls.SYS_ERROR_SIGNAL;
                }
            } else if (syscall_no == MIPS64Syscalls.SYS_GETPID) {
                v0 = 0;
                v1 = 0;
            } else if (syscall_no == MIPS64Syscalls.SYS_GETRANDOM) {
                if (MIPS64State.featuresForVersion(STATE_VERSION).supportWorkingSysGetRandom) {
                    (v0, v1, state.memRoot) = syscallGetRandom(state, a0, a1);
                }
                // Otherwise, ignored (noop)
            } else if (syscall_no == MIPS64Syscalls.SYS_MUNMAP) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_MPROTECT) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_GETAFFINITY) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_MADVISE) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_RTSIGPROCMASK) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_SIGALTSTACK) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_RTSIGACTION) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_PRLIMIT64) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_CLOSE) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_PREAD64) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_STAT) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_FSTAT) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_OPENAT) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_READLINK) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_READLINKAT) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_IOCTL) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_EPOLLCREATE1) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_PIPE2) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_EPOLLCTL) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_EPOLLPWAIT) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_UNAME) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_GETUID) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_GETGID) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_MINCORE) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_TGKILL) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_SETITIMER) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_TIMERCREATE) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_TIMERSETTIME) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_TIMERDELETE) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_GETRLIMIT) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_LSEEK) {
                // ignored
            } else if (syscall_no == MIPS64Syscalls.SYS_EVENTFD2) {
                // a0 = initial value, a1 = flags
                // Validate flags
                if (a1 & MIPS64Syscalls.EFD_NONBLOCK == 0) {
                    // The non-block flag was not set, but we only support non-block requests, so error
                    v0 = MIPS64Syscalls.EINVAL;
                    v1 = MIPS64Syscalls.SYS_ERROR_SIGNAL;
                } else {
                    v0 = MIPS64Syscalls.FD_EVENTFD;
                }
            } else {
                revert("MIPS64: unimplemented syscall");
            }

            MIPS64State.CpuScalars memory cpu = getCpuScalars(thread);
            MIPS64Syscalls.handleSyscallUpdates(cpu, thread.registers, v0, v1);
            setStateCpuScalars(thread, cpu);

            updateCurrentThreadRoot();
            out_ = outputState();
        }
    }

    function syscallGetRandom(
        State memory _state,
        uint64 _a0,
        uint64 _a1
    )
        internal
        pure
        returns (uint64 v0_, uint64 v1_, bytes32 memRoot_)
    {
        uint64 effAddr = _a0 & MIPS64Arch.ADDRESS_MASK;
        uint256 memProofOffset = MIPS64Memory.memoryProofOffset(MEM_PROOF_OFFSET, 1);
        uint64 memVal = MIPS64Memory.readMem(_state.memRoot, effAddr, memProofOffset);

        // Generate some pseudorandom data
        uint64 randomWord = splitmix64(_state.step);

        // Calculate number of bytes to write
        uint64 targetByteIndex = _a0 - effAddr;
        uint64 maxBytes = MIPS64Arch.WORD_SIZE_BYTES - targetByteIndex;
        uint64 byteCount = _a1;
        if (maxBytes < byteCount) {
            byteCount = maxBytes;
        }

        // Write random data into target memory location
        uint64 randDataMask = uint64((1 << (byteCount * 8)) - 1);
        // Shift left to align with index 0, then shift right to target correct index
        randDataMask <<= (MIPS64Arch.WORD_SIZE_BYTES - byteCount) * 8;
        randDataMask >>= targetByteIndex * 8;
        uint64 newMemVal = (memVal & ~randDataMask) | (randomWord & randDataMask);

        memRoot_ = MIPS64Memory.writeMem(effAddr, memProofOffset, newMemVal);
        handleMemoryUpdate(_state, effAddr);

        v0_ = byteCount;
        v1_ = 0;
    }

    // splitmix64 generates a pseudorandom 64-bit value.
    // See canonical implementation: https://prng.di.unimi.it/splitmix64.c
    function splitmix64(uint64 _seed) internal pure returns (uint64) {
        unchecked {
            uint64 z = _seed + 0x9e3779b97f4a7c15;
            z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
            z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
            return z ^ (z >> 31);
        }
    }

    function syscallYield(State memory _state, ThreadState memory _thread) internal returns (bytes32 out_) {
        uint64 v0 = 0;
        uint64 v1 = 0;
        MIPS64State.CpuScalars memory cpu = getCpuScalars(_thread);
        MIPS64Syscalls.handleSyscallUpdates(cpu, _thread.registers, v0, v1);
        setStateCpuScalars(_thread, cpu);
        preemptThread(_state, _thread);

        return outputState();
    }

    function execSysRead(
        State memory _state,
        MIPS64Syscalls.SysReadParams memory _args
    )
        internal
        view
        returns (uint64 v0_, uint64 v1_)
    {
        bool memUpdated;
        uint64 memAddr;
        (v0_, v1_, _state.preimageOffset, _state.memRoot, memUpdated, memAddr) = MIPS64Syscalls.handleSysRead(_args);
        if (memUpdated) {
            handleMemoryUpdate(_state, memAddr);
        }
    }

    /// @notice Computes the hash of the MIPS state.
    /// @return out_ The hashed MIPS state.
    function outputState() internal returns (bytes32 out_) {
        uint32 exited;
        assembly {
            // copies 'size' bytes, right-aligned in word at 'from', to 'to', incl. trailing data
            function copyMem(from, to, size) -> fromOut, toOut {
                mstore(to, mload(add(from, sub(32, size))))
                fromOut := add(from, 32)
                toOut := add(to, size)
            }

            // From points to the MIPS State
            let from := STATE_MEM_OFFSET

            // Copy to the free memory pointer
            let start := mload(0x40)
            let to := start

            // Copy state to free memory
            from, to := copyMem(from, to, 32) // memRoot
            from, to := copyMem(from, to, 32) // preimageKey
            from, to := copyMem(from, to, 8) // preimageOffset
            from, to := copyMem(from, to, 8) // heap
            from, to := copyMem(from, to, 1) // llReservationStatus
            from, to := copyMem(from, to, 8) // llAddress
            from, to := copyMem(from, to, 8) // llOwnerThread
            let exitCode := mload(from)
            from, to := copyMem(from, to, 1) // exitCode
            exited := mload(from)
            from, to := copyMem(from, to, 1) // exited
            from, to := copyMem(from, to, 8) // step
            from, to := copyMem(from, to, 8) // stepsSinceLastContextSwitch
            from, to := copyMem(from, to, 1) // traverseRight
            from, to := copyMem(from, to, 32) // leftThreadStack
            from, to := copyMem(from, to, 32) // rightThreadStack
            from, to := copyMem(from, to, 8) // nextThreadID

            // Clean up end of memory
            mstore(to, 0)

            // Log the resulting MIPS state, for debugging
            log0(start, sub(to, start))

            // Determine the VM status
            let status := 0
            switch exited
            case 1 {
                switch exitCode
                // VMStatusValid
                case 0 { status := 0 }
                // VMStatusInvalid
                case 1 { status := 1 }
                // VMStatusPanic
                default { status := 2 }
            }
            // VMStatusUnfinished
            default { status := 3 }

            // Compute the hash of the resulting MIPS state and set the status byte
            out_ := keccak256(start, sub(to, start))
            out_ := or(and(not(shl(248, 0xFF)), out_), shl(248, status))
        }

        MIPS64State.assertExitedIsValid(exited);
    }

    /// @notice Updates the current thread stack root via inner thread root in calldata
    function updateCurrentThreadRoot() internal pure {
        State memory state;
        ThreadState memory thread;
        assembly {
            state := STATE_MEM_OFFSET
            thread := TC_MEM_OFFSET
        }
        bytes32 updatedRoot = computeThreadRoot(loadCalldataInnerThreadRoot(), thread);
        if (state.traverseRight) {
            state.rightThreadStack = updatedRoot;
        } else {
            state.leftThreadStack = updatedRoot;
        }
    }

    /// @notice Preempts the current thread for another and updates the VM state.
    ///         It reads the inner thread root from calldata to update the current thread stack root.
    function preemptThread(
        State memory _state,
        ThreadState memory _thread
    )
        internal
        pure
        returns (bool changedDirections_)
    {
        // pop thread from the current stack and push to the other stack
        if (_state.traverseRight) {
            require(_state.rightThreadStack != EMPTY_THREAD_ROOT, "MIPS64: empty right thread stack");
            _state.rightThreadStack = loadCalldataInnerThreadRoot();
            _state.leftThreadStack = computeThreadRoot(_state.leftThreadStack, _thread);
        } else {
            require(_state.leftThreadStack != EMPTY_THREAD_ROOT, "MIPS64: empty left thread stack");
            _state.leftThreadStack = loadCalldataInnerThreadRoot();
            _state.rightThreadStack = computeThreadRoot(_state.rightThreadStack, _thread);
        }
        bytes32 current = _state.traverseRight ? _state.rightThreadStack : _state.leftThreadStack;
        if (current == EMPTY_THREAD_ROOT) {
            _state.traverseRight = !_state.traverseRight;
            changedDirections_ = true;
        }
        _state.stepsSinceLastContextSwitch = 0;
    }

    /// @notice Pushes a thread to the current thread stack.
    function pushThread(State memory _state, ThreadState memory _thread) internal pure {
        if (_state.traverseRight) {
            _state.rightThreadStack = computeThreadRoot(_state.rightThreadStack, _thread);
        } else {
            _state.leftThreadStack = computeThreadRoot(_state.leftThreadStack, _thread);
        }
        _state.stepsSinceLastContextSwitch = 0;
    }

    /// @notice Removes the current thread from the stack.
    function popThread(State memory _state) internal pure {
        if (_state.traverseRight) {
            _state.rightThreadStack = loadCalldataInnerThreadRoot();
        } else {
            _state.leftThreadStack = loadCalldataInnerThreadRoot();
        }
        bytes32 current = _state.traverseRight ? _state.rightThreadStack : _state.leftThreadStack;
        if (current == EMPTY_THREAD_ROOT) {
            _state.traverseRight = !_state.traverseRight;
        }
        _state.stepsSinceLastContextSwitch = 0;
    }

    /// @notice Returns true if the number of threads is 1
    function lastThreadRemaining(State memory _state) internal pure returns (bool out_) {
        bytes32 inactiveStack = _state.traverseRight ? _state.leftThreadStack : _state.rightThreadStack;
        bool currentStackIsAlmostEmpty = loadCalldataInnerThreadRoot() == EMPTY_THREAD_ROOT;
        return inactiveStack == EMPTY_THREAD_ROOT && currentStackIsAlmostEmpty;
    }

    function computeThreadRoot(bytes32 _currentRoot, ThreadState memory _thread) internal pure returns (bytes32 out_) {
        // w_i = hash(w_0 ++ hash(thread))
        bytes32 threadRoot = outputThreadState(_thread);
        out_ = keccak256(abi.encodePacked(_currentRoot, threadRoot));
    }

    function outputThreadState(ThreadState memory _thread) internal pure returns (bytes32 out_) {
        assembly {
            // copies 'size' bytes, right-aligned in word at 'from', to 'to', incl. trailing data
            function copyMem(from, to, size) -> fromOut, toOut {
                mstore(to, mload(add(from, sub(32, size))))
                fromOut := add(from, 32)
                toOut := add(to, size)
            }

            // From points to the ThreadState
            let from := _thread

            // Copy to the free memory pointer
            let start := mload(0x40)
            let to := start

            // Copy state to free memory
            from, to := copyMem(from, to, 8) // threadID
            from, to := copyMem(from, to, 1) // exitCode
            from, to := copyMem(from, to, 1) // exited
            from, to := copyMem(from, to, 8) // pc
            from, to := copyMem(from, to, 8) // nextPC
            from, to := copyMem(from, to, 8) // lo
            from, to := copyMem(from, to, 8) // hi
            from := mload(from) // offset to registers
            // Copy registers
            for { let i := 0 } lt(i, 32) { i := add(i, 1) } { from, to := copyMem(from, to, 8) }

            // Clean up end of memory
            mstore(to, 0)

            // Compute the hash of the resulting ThreadState
            out_ := keccak256(start, sub(to, start))
        }
    }

    function getCpuScalars(ThreadState memory _tc) internal pure returns (MIPS64State.CpuScalars memory cpu_) {
        cpu_ = MIPS64State.CpuScalars({ pc: _tc.pc, nextPC: _tc.nextPC, lo: _tc.lo, hi: _tc.hi });
    }

    function setStateCpuScalars(ThreadState memory _tc, MIPS64State.CpuScalars memory _cpu) internal pure {
        _tc.pc = _cpu.pc;
        _tc.nextPC = _cpu.nextPC;
        _tc.lo = _cpu.lo;
        _tc.hi = _cpu.hi;
    }

    /// @notice Validates the thread witness in calldata against the current thread.
    function validateCalldataThreadWitness(State memory _state, ThreadState memory _thread) internal pure {
        bytes32 witnessRoot = computeThreadRoot(loadCalldataInnerThreadRoot(), _thread);
        bytes32 expectedRoot = _state.traverseRight ? _state.rightThreadStack : _state.leftThreadStack;
        require(expectedRoot == witnessRoot, "MIPS64: invalid thread witness");
    }

    /// @notice Sets the thread context from calldata.
    function setThreadStateFromCalldata(ThreadState memory _thread) internal pure {
        uint256 s = 0;
        assembly {
            s := calldatasize()
        }
        // verify we have enough calldata
        require(
            s >= (THREAD_PROOF_OFFSET + PACKED_THREAD_STATE_SIZE), "MIPS64: insufficient calldata for thread witness"
        );

        unchecked {
            assembly {
                function putField(callOffset, memOffset, size) -> callOffsetOut, memOffsetOut {
                    // calldata is packed, thus starting left-aligned, shift-right to pad and right-align
                    let w := shr(shl(3, sub(32, size)), calldataload(callOffset))
                    mstore(memOffset, w)
                    callOffsetOut := add(callOffset, size)
                    memOffsetOut := add(memOffset, 32)
                }

                let c := THREAD_PROOF_OFFSET
                let m := _thread
                c, m := putField(c, m, 8) // threadID
                c, m := putField(c, m, 1) // exitCode
                c, m := putField(c, m, 1) // exited
                c, m := putField(c, m, 8) // pc
                c, m := putField(c, m, 8) // nextPC
                c, m := putField(c, m, 8) // lo
                c, m := putField(c, m, 8) // hi
                m := mload(m) // offset to registers
                // Unpack register calldata into memory
                for { let i := 0 } lt(i, 32) { i := add(i, 1) } { c, m := putField(c, m, 8) }
            }
        }
    }

    /// @notice Loads the inner root for the current thread hash onion from calldata.
    function loadCalldataInnerThreadRoot() internal pure returns (bytes32 innerThreadRoot_) {
        uint256 s = 0;
        assembly {
            s := calldatasize()
            innerThreadRoot_ := calldataload(add(THREAD_PROOF_OFFSET, PACKED_THREAD_STATE_SIZE))
        }
        // verify we have enough calldata
        require(
            s >= (THREAD_PROOF_OFFSET + (PACKED_THREAD_STATE_SIZE + 32)),
            "MIPS64: insufficient calldata for thread witness"
        );
    }

    /// @notice Loads a 32-bit futex value at _vAddr
    function getFutexValue(uint64 _vAddr) internal pure returns (uint32 out_) {
        State memory state;
        assembly {
            state := STATE_MEM_OFFSET
        }

        uint64 subword = loadSubWord(state, _vAddr, 4, false);
        return uint32(subword);
    }
}