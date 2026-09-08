// SPDX-License-Identifier: Unknown
pragma solidity 0.8.30;

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

/**
 * @title Hash library
 * @author Aztec Labs
 * @notice Library that contains helper functions to compute hashes for data structures and convert to field elements
 * Using sha256 as the hash function since it hits a good balance between gas cost and circuit size.
 */
library Hash {
    /**
     * @notice Computes the sha256 hash of the L1 to L2 message and converts it to a field element
     * @param _message - The L1 to L2 message to hash
     * @return The hash of the provided message as a field element
     */
    function sha256ToField(DataStructures.L1ToL2Msg memory _message) internal pure returns (bytes32) {
        return sha256ToField(
            abi.encode(_message.sender, _message.recipient, _message.content, _message.secretHash, _message.index)
        );
    }

    /**
     * @notice Computes the sha256 hash of the L2 to L1 message and converts it to a field element
     * @param _message - The L2 to L1 message to hash
     * @return The hash of the provided message as a field element
     */
    function sha256ToField(DataStructures.L2ToL1Msg memory _message) internal pure returns (bytes32) {
        return sha256ToField(
            abi.encodePacked(
                _message.sender.actor,
                _message.sender.version,
                _message.recipient.actor,
                _message.recipient.chainId,
                _message.content
            )
        );
    }

    /**
     * @notice Computes the sha256 hash of the provided data and converts it to a field element
     * @dev Truncating one byte to convert the hash to a field element. We prepend a byte rather than cast
     * bytes31(bytes32) to match Noir's to_be_bytes.
     * @param _data - The bytes to hash
     * @return The hash of the provided data as a field element
     */
    function sha256ToField(bytes memory _data) internal pure returns (bytes32) {
        return bytes32(bytes.concat(new bytes(1), bytes31(sha256(_data))));
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

// File-level integer literal so it can be used as a fixed-size array length (Solidity rejects
// dotted library-member access in array-length positions). MUST equal
// `Constants.MAX_CHECKPOINTS_PER_EPOCH`; the Outbox constructor enforces this at deploy time.
uint256 constant MAX_CHECKPOINTS_PER_EPOCH = 32;

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
    function depositToAztecPublic(bytes32 _to, uint256 _amount, bytes32 _secretHash)
        external
        returns (bytes32, uint256);

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
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 implicitAmountUsed,
        uint256 earmarkedAmountUsed
    );

    function claim(address _to, uint256 _amount) external;
    function recoverFrom(address _from, address _to, uint256 _amount) external;
    function recoverWrongAsset(address _asset, address _to, uint256 _amount) external;
    function subsidizeAddress(address _recipient, uint256 _amount) external;
    function canonicalRollup() external view returns (address);
    function availableTo(address _recipient) external view returns (uint256);
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

    function validateBlobs(bytes calldata _blobsInputs)
        external
        view
        returns (bytes32[] memory, bytes32, bytes[] memory);

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

/**
 * @title Merkle Library
 * @author Aztec Labs
 * @notice Library that contains functions useful when interacting with Merkle Trees
 */
library MerkleLib {
    /**
     * @notice Verifies the membership of a leaf and path against an expected root.
     * @dev In the case of a mismatched root, and subsequent inability to verify membership, this function throws.
     * @param _path - The sibling path of the message as a leaf, used to prove message inclusion
     * @param _leaf - The hash of the message we are trying to prove inclusion for
     * @param _index - The index of the message inside the L2 to L1 message tree
     * @param _expectedRoot - The expected root to check the validity of the message and sibling path with.
     * @notice -
     * E.g. A sibling path for a leaf at index 3 (L) in a tree of depth 3 (between 5 and 8 leafs) consists of the 3
     * elements denoted as *'s
     * d0:                                            [ root ]
     * d1:                      [ ]                                               [*]
     * d2:         [*]                      [ ]                       [ ]                     [ ]
     * d3:   [ ]         [ ]          [*]         [L]           [ ]         [ ]          [ ]        [ ].
     * And the elements would be ordered as: [ d3_index_2, d2_index_0, d1_index_1 ].
     */
    function verifyMembership(bytes32[] calldata _path, bytes32 _leaf, uint256 _index, bytes32 _expectedRoot)
        internal
        pure
    {
        bytes32 subtreeRoot = _leaf;
        /// @notice - We use the indexAtHeight to see whether our child of the next subtree is at the left or the right side
        uint256 indexAtHeight = _index;

        for (uint256 height = 0; height < _path.length; height++) {
            /// @notice - This affects the way we concatenate our two children to then hash and calculate the root, as any odd
            /// indexes (index bit-masked with least significant bit) are right-sided children.
            bool isRight = (indexAtHeight & 1) == 1;

            subtreeRoot = isRight
                ? Hash.sha256ToField(bytes.concat(_path[height], subtreeRoot))
                : Hash.sha256ToField(bytes.concat(subtreeRoot, _path[height]));
            /// @notice - We divide by two here to get the index of the parent of the current subtreeRoot in its own layer
            indexAtHeight >>= 1;
        }

        // Security: Ensure the index doesn't have bits set beyond the tree height
        // This prevents replay attacks where an attacker could use index 8 with path length 2 to walk the same path as
        // index 0.
        require(indexAtHeight == 0, Errors.MerkleLib__InvalidIndexForPathLength());
        require(subtreeRoot == _expectedRoot, Errors.MerkleLib__InvalidRoot(_expectedRoot, subtreeRoot, _leaf, _index));
    }
}

/**
 * @title Outbox
 * @author Aztec Labs
 * @notice Lives on L1 and is used to consume L2 -> L1 messages. Messages are inserted by the Rollup
 * and will be consumed by the portal contracts.
 *
 * @dev Each epoch may accumulate multiple message roots when `insert` is called more than once
 * (e.g. when a partial epoch proof is followed by an extending proof). Roots are keyed by the
 * number of checkpoints proven in that epoch (`numCheckpointsInEpoch`, in [1, MAX_CHECKPOINTS_PER_EPOCH]),
 * so an off-chain consumer can map their L2 transaction's position-within-epoch directly to the
 * smallest proof that covers it without needing to recover that count from chain history.
 *
 * The nullifier bitmap is shared across every root of the same epoch, so a message consumed against
 * one root cannot be replayed against another root of the same epoch.
 *
 * Messages are tracked using unique leaf IDs computed from their position in the epoch's tree structure.
 * This design ensures that when longer epoch proofs are submitted (proving more checkpoints), messages
 * from earlier checkpoints retain their consumed status because their leaf IDs remain stable.
 *
 * @dev The Outbox does not (and cannot) verify on chain that a given message has the same leaf id
 * across two different roots of the same epoch. Leaf-id stability across extending partial-epoch
 * proofs is a property the rollup's proving system is expected to uphold (each checkpoint's subtree
 * is built only from its own messages, and the epoch tree is padded to a fixed size, so positions
 * of already-included messages are preserved when more checkpoints are added). A buggy or malicious
 * rollup that submitted two proofs for the same epoch where the same message lived at different
 * positions would, on the Outbox side, produce two different leaf ids on the shared bitmap and
 * therefore allow that message to be consumed twice. This is the same trust boundary the Outbox
 * has always had with the rollup; AZIP-14 does not extend it.
 *
 * For detailed information about the tree structure and leaf ID computation, see:
 * yarn-project/stdlib/src/messaging/l2_to_l1_membership.ts
 */
contract Outbox is IOutbox {
    using Hash for DataStructures.L2ToL1Msg;
    using BitMaps for BitMaps.BitMap;

    struct EpochData {
        // Slot `i` holds the epoch-tree out-hash root for `numCheckpointsInEpoch = i + 1` (i.e. the
        // proof that covered the first `i + 1` checkpoints of this epoch). Unset slots read as zero.
        // The array is sized at MAX_CHECKPOINTS_PER_EPOCH because that is the maximum number of
        // checkpoints the rollup ever proves in a single epoch.
        bytes32[MAX_CHECKPOINTS_PER_EPOCH_1] roots;
        // Bitmap tracking which messages (by leaf ID) have been consumed within this epoch.
        // The bitmap is shared across every root of the epoch: a message consumed against one
        // root cannot be replayed against another root for the same epoch.
        // Leaf IDs are stable across different epoch proof lengths, ensuring consumed
        // messages remain marked as consumed when longer proofs are submitted.
        BitMaps.BitMap nullified;
    }

    IRollup public immutable ROLLUP;
    uint256 public immutable VERSION;
    mapping(Epoch epoch => EpochData epochData) internal epochs;

    constructor(address _rollup, uint256 _version) {
        // Keep the file-level literal in lockstep with the generated constant. If this ever fires,
        // update MAX_CHECKPOINTS_PER_EPOCH at the top of this file (and IOutbox.sol).
        require(
            MAX_CHECKPOINTS_PER_EPOCH_1 == Constants.MAX_CHECKPOINTS_PER_EPOCH,
            Errors.Outbox__InvalidNumCheckpointsInEpoch(MAX_CHECKPOINTS_PER_EPOCH_1)
        );

        ROLLUP = IRollup(_rollup);
        VERSION = _version;
    }

    /**
     * @notice Inserts the root of a merkle tree containing all of the L2 to L1 messages in an epoch
     *
     * @dev Only callable by the rollup contract
     * @dev Emits `RootAdded` upon inserting the root successfully
     *
     * @dev `_numCheckpointsInEpoch` identifies which partial-proof depth this root corresponds to:
     * the rollup proved the first `_numCheckpointsInEpoch` checkpoints of `_epoch`. A subsequent
     * insert for the same epoch with a larger `_numCheckpointsInEpoch` adds a new entry without
     * disturbing earlier ones, so users with witnesses built against an earlier partial proof can
     * still consume them.
     *
     * @param _epoch - The epoch in which the L2 to L1 messages reside
     * @param _numCheckpointsInEpoch - The number of checkpoints the inserting proof covered in this
     * epoch. Must be in [1, MAX_CHECKPOINTS_PER_EPOCH]. Values outside that range will revert.
     * @param _root - The merkle root of the tree where all the L2 to L1 messages are leaves
     */
    function insert(Epoch _epoch, uint256 _numCheckpointsInEpoch, bytes32 _root) external override(IOutbox) {
        require(msg.sender == address(ROLLUP), Errors.Outbox__Unauthorized());
        require(
            _numCheckpointsInEpoch >= 1 && _numCheckpointsInEpoch <= MAX_CHECKPOINTS_PER_EPOCH_1,
            Errors.Outbox__InvalidNumCheckpointsInEpoch(_numCheckpointsInEpoch)
        );

        epochs[_epoch].roots[_numCheckpointsInEpoch - 1] = _root;

        emit RootAdded(_epoch, _numCheckpointsInEpoch, _root);
    }

    /**
     * @notice Consumes an entry from the Outbox
     *
     * @dev Only useable by portals / recipients of messages
     * @dev Emits `MessageConsumed` when consuming messages
     *
     * @param _message - The L2 to L1 message
     * @param _epoch - The epoch that contains the message we want to consume
     * @param _numCheckpointsInEpoch - The number of checkpoints in the partial proof whose root this
     * consume verifies against. The caller's witness `_path` must have been built against the epoch
     * tree padded to that number of real checkpoints.
     * @param _leafIndex - The index at the level in the wonky tree where the message is located
     * @param _path - The sibling path used to prove inclusion of the message, the _path length depends
     * on the location of the L2 to L1 message in the wonky tree.
     */
    function consume(
        DataStructures.L2ToL1Msg calldata _message,
        Epoch _epoch,
        uint256 _numCheckpointsInEpoch,
        uint256 _leafIndex,
        bytes32[] calldata _path
    ) external override(IOutbox) {
        require(_path.length < 256, Errors.Outbox__PathTooLong());
        require(_leafIndex < (1 << _path.length), Errors.Outbox__LeafIndexOutOfBounds(_leafIndex, _path.length));
        require(_message.sender.version == VERSION, Errors.Outbox__VersionMismatch(_message.sender.version, VERSION));

        require(
            msg.sender == _message.recipient.actor,
            Errors.Outbox__InvalidRecipient(_message.recipient.actor, msg.sender)
        );

        require(block.chainid == _message.recipient.chainId, Errors.Outbox__InvalidChainId());

        require(
            _numCheckpointsInEpoch >= 1 && _numCheckpointsInEpoch <= MAX_CHECKPOINTS_PER_EPOCH_1,
            Errors.Outbox__NothingToConsumeAtEpoch(_epoch)
        );

        EpochData storage epochData = epochs[_epoch];
        bytes32 root = epochData.roots[_numCheckpointsInEpoch - 1];

        // A zero root means no proof was ever inserted for this `_numCheckpointsInEpoch`.
        require(root != bytes32(0), Errors.Outbox__NothingToConsumeAtEpoch(_epoch));

        // Compute the unique leaf ID for this message.
        uint256 leafId = (1 << _path.length) + _leafIndex;

        require(!epochData.nullified.get(leafId), Errors.Outbox__AlreadyNullified(_epoch, leafId));

        bytes32 messageHash = _message.sha256ToField();

        MerkleLib.verifyMembership(_path, messageHash, _leafIndex, root);

        epochData.nullified.set(leafId);

        emit MessageConsumed(_epoch, root, messageHash, leafId, _numCheckpointsInEpoch);
    }

    /**
     * @notice Checks to see if an L2 to L1 message in a specific epoch has been consumed
     *
     * @dev - This function does not throw. Out-of-bounds access is considered valid, but will always return false
     *
     * @param _epoch - The epoch that contains the message we want to check
     * @param _leafId - The unique id of the message leaf
     *
     * @return bool - True if the message has been consumed, false otherwise
     */
    function hasMessageBeenConsumedAtEpoch(Epoch _epoch, uint256 _leafId)
        external
        view
        override(IOutbox)
        returns (bool)
    {
        return epochs[_epoch].nullified.get(_leafId);
    }

    /**
     * @notice  Fetch the root data for a given epoch and partial-proof depth
     *          Returns 0 if no proof has been inserted at that depth (or if the depth is out of range)
     *
     * @param _epoch - The epoch to fetch the root data for
     * @param _numCheckpointsInEpoch - The number of checkpoints in the partial proof whose root to fetch
     *
     * @return bytes32 - The root of the merkle tree containing the L2 to L1 messages
     */
    function getRootData(Epoch _epoch, uint256 _numCheckpointsInEpoch)
        external
        view
        override(IOutbox)
        returns (bytes32)
    {
        if (_numCheckpointsInEpoch == 0 || _numCheckpointsInEpoch > MAX_CHECKPOINTS_PER_EPOCH_1) {
            return bytes32(0);
        }
        return epochs[_epoch].roots[_numCheckpointsInEpoch - 1];
    }

    /**
     * @notice  Fetch every root stored for a given epoch. The returned array has
     *          MAX_CHECKPOINTS_PER_EPOCH entries; slot `i` holds the root for
     *          `numCheckpointsInEpoch = i + 1`, or zero if no proof of that depth has been inserted.
     *
     * @param _epoch - The epoch to fetch the roots for
     *
     * @return bytes32[] - The roots stored for this epoch.
     */
    function getRoots(Epoch _epoch)
        external
        view
        override(IOutbox)
        returns (bytes32[MAX_CHECKPOINTS_PER_EPOCH_1] memory)
    {
        return epochs[_epoch].roots;
    }
}
