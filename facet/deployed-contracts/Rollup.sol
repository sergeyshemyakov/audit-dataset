// SPDX-License-Identifier: Unknown
pragma solidity 0.8.24;

library SafeCastLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error Overflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*          UNSIGNED INTEGER SAFE CASTING OPERATIONS          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toUint8(uint256 x) internal pure returns (uint8) {
        if (x >= 1 << 8) {
            _revertOverflow();
        }
        return uint8(x);
    }

    function toUint16(uint256 x) internal pure returns (uint16) {
        if (x >= 1 << 16) {
            _revertOverflow();
        }
        return uint16(x);
    }

    function toUint24(uint256 x) internal pure returns (uint24) {
        if (x >= 1 << 24) {
            _revertOverflow();
        }
        return uint24(x);
    }

    function toUint32(uint256 x) internal pure returns (uint32) {
        if (x >= 1 << 32) {
            _revertOverflow();
        }
        return uint32(x);
    }

    function toUint40(uint256 x) internal pure returns (uint40) {
        if (x >= 1 << 40) {
            _revertOverflow();
        }
        return uint40(x);
    }

    function toUint48(uint256 x) internal pure returns (uint48) {
        if (x >= 1 << 48) {
            _revertOverflow();
        }
        return uint48(x);
    }

    function toUint56(uint256 x) internal pure returns (uint56) {
        if (x >= 1 << 56) {
            _revertOverflow();
        }
        return uint56(x);
    }

    function toUint64(uint256 x) internal pure returns (uint64) {
        if (x >= 1 << 64) {
            _revertOverflow();
        }
        return uint64(x);
    }

    function toUint72(uint256 x) internal pure returns (uint72) {
        if (x >= 1 << 72) {
            _revertOverflow();
        }
        return uint72(x);
    }

    function toUint80(uint256 x) internal pure returns (uint80) {
        if (x >= 1 << 80) {
            _revertOverflow();
        }
        return uint80(x);
    }

    function toUint88(uint256 x) internal pure returns (uint88) {
        if (x >= 1 << 88) {
            _revertOverflow();
        }
        return uint88(x);
    }

    function toUint96(uint256 x) internal pure returns (uint96) {
        if (x >= 1 << 96) {
            _revertOverflow();
        }
        return uint96(x);
    }

    function toUint104(uint256 x) internal pure returns (uint104) {
        if (x >= 1 << 104) {
            _revertOverflow();
        }
        return uint104(x);
    }

    function toUint112(uint256 x) internal pure returns (uint112) {
        if (x >= 1 << 112) {
            _revertOverflow();
        }
        return uint112(x);
    }

    function toUint120(uint256 x) internal pure returns (uint120) {
        if (x >= 1 << 120) {
            _revertOverflow();
        }
        return uint120(x);
    }

    function toUint128(uint256 x) internal pure returns (uint128) {
        if (x >= 1 << 128) {
            _revertOverflow();
        }
        return uint128(x);
    }

    function toUint136(uint256 x) internal pure returns (uint136) {
        if (x >= 1 << 136) {
            _revertOverflow();
        }
        return uint136(x);
    }

    function toUint144(uint256 x) internal pure returns (uint144) {
        if (x >= 1 << 144) {
            _revertOverflow();
        }
        return uint144(x);
    }

    function toUint152(uint256 x) internal pure returns (uint152) {
        if (x >= 1 << 152) {
            _revertOverflow();
        }
        return uint152(x);
    }

    function toUint160(uint256 x) internal pure returns (uint160) {
        if (x >= 1 << 160) {
            _revertOverflow();
        }
        return uint160(x);
    }

    function toUint168(uint256 x) internal pure returns (uint168) {
        if (x >= 1 << 168) {
            _revertOverflow();
        }
        return uint168(x);
    }

    function toUint176(uint256 x) internal pure returns (uint176) {
        if (x >= 1 << 176) {
            _revertOverflow();
        }
        return uint176(x);
    }

    function toUint184(uint256 x) internal pure returns (uint184) {
        if (x >= 1 << 184) {
            _revertOverflow();
        }
        return uint184(x);
    }

    function toUint192(uint256 x) internal pure returns (uint192) {
        if (x >= 1 << 192) {
            _revertOverflow();
        }
        return uint192(x);
    }

    function toUint200(uint256 x) internal pure returns (uint200) {
        if (x >= 1 << 200) {
            _revertOverflow();
        }
        return uint200(x);
    }

    function toUint208(uint256 x) internal pure returns (uint208) {
        if (x >= 1 << 208) {
            _revertOverflow();
        }
        return uint208(x);
    }

    function toUint216(uint256 x) internal pure returns (uint216) {
        if (x >= 1 << 216) {
            _revertOverflow();
        }
        return uint216(x);
    }

    function toUint224(uint256 x) internal pure returns (uint224) {
        if (x >= 1 << 224) {
            _revertOverflow();
        }
        return uint224(x);
    }

    function toUint232(uint256 x) internal pure returns (uint232) {
        if (x >= 1 << 232) {
            _revertOverflow();
        }
        return uint232(x);
    }

    function toUint240(uint256 x) internal pure returns (uint240) {
        if (x >= 1 << 240) {
            _revertOverflow();
        }
        return uint240(x);
    }

    function toUint248(uint256 x) internal pure returns (uint248) {
        if (x >= 1 << 248) {
            _revertOverflow();
        }
        return uint248(x);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*           SIGNED INTEGER SAFE CASTING OPERATIONS           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toInt8(int256 x) internal pure returns (int8) {
        int8 y = int8(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt16(int256 x) internal pure returns (int16) {
        int16 y = int16(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt24(int256 x) internal pure returns (int24) {
        int24 y = int24(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt32(int256 x) internal pure returns (int32) {
        int32 y = int32(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt40(int256 x) internal pure returns (int40) {
        int40 y = int40(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt48(int256 x) internal pure returns (int48) {
        int48 y = int48(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt56(int256 x) internal pure returns (int56) {
        int56 y = int56(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt64(int256 x) internal pure returns (int64) {
        int64 y = int64(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt72(int256 x) internal pure returns (int72) {
        int72 y = int72(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt80(int256 x) internal pure returns (int80) {
        int80 y = int80(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt88(int256 x) internal pure returns (int88) {
        int88 y = int88(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt96(int256 x) internal pure returns (int96) {
        int96 y = int96(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt104(int256 x) internal pure returns (int104) {
        int104 y = int104(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt112(int256 x) internal pure returns (int112) {
        int112 y = int112(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt120(int256 x) internal pure returns (int120) {
        int120 y = int120(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt128(int256 x) internal pure returns (int128) {
        int128 y = int128(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt136(int256 x) internal pure returns (int136) {
        int136 y = int136(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt144(int256 x) internal pure returns (int144) {
        int144 y = int144(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt152(int256 x) internal pure returns (int152) {
        int152 y = int152(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt160(int256 x) internal pure returns (int160) {
        int160 y = int160(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt168(int256 x) internal pure returns (int168) {
        int168 y = int168(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt176(int256 x) internal pure returns (int176) {
        int176 y = int176(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt184(int256 x) internal pure returns (int184) {
        int184 y = int184(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt192(int256 x) internal pure returns (int192) {
        int192 y = int192(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt200(int256 x) internal pure returns (int200) {
        int200 y = int200(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt208(int256 x) internal pure returns (int208) {
        int208 y = int208(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt216(int256 x) internal pure returns (int216) {
        int216 y = int216(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt224(int256 x) internal pure returns (int224) {
        int224 y = int224(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt232(int256 x) internal pure returns (int232) {
        int232 y = int232(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt240(int256 x) internal pure returns (int240) {
        int240 y = int240(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    function toInt248(int256 x) internal pure returns (int248) {
        int248 y = int248(x);
        if (x != y) {
            _revertOverflow();
        }
        return y;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*               OTHER SAFE CASTING OPERATIONS                */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toInt256(uint256 x) internal pure returns (int256) {
        if (x >= 1 << 255) {
            _revertOverflow();
        }
        return int256(x);
    }

    function toUint256(int256 x) internal pure returns (uint256) {
        if (x < 0) {
            _revertOverflow();
        }
        return uint256(x);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function _revertOverflow() private pure {
        /// @solidity memory-safe-assembly
        assembly {
            // Store the function selector of `Overflow()`.
            mstore(0x00, 0x35278d12)
            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

contract Rollup is Ownable, ReentrancyGuard {
    using SafeCastLib for uint256;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public immutable MAX_CHALLENGE_SECS;
    uint256 public immutable MAX_PROVE_SECS;
    uint256 public immutable CHALLENGER_BOND;
    uint256 public immutable PROPOSER_BOND;
    uint256 public immutable FALLBACK_TIMEOUT_SECS;
    uint256 public immutable PROPOSAL_INTERVAL;
    uint256 public immutable L2_START_TIMESTAMP;
    uint256 public immutable L2_BLOCK_TIME;

    ISP1Verifier public immutable VERIFIER;
    bytes32 public immutable ROLLUP_CONFIG_HASH;
    bytes32 public immutable AGG_VKEY;
    bytes32 public immutable RANGE_VKEY_COMMITMENT;

    string public constant version = "1.0.0";

    /*//////////////////////////////////////////////////////////////
                               ENUMS
    //////////////////////////////////////////////////////////////*/

    enum ResolutionStatus {
        IN_PROGRESS,
        DEFENDER_WINS,
        CHALLENGER_WINS
    }

    enum ProposalStatus {
        Unchallenged,
        Challenged,
        UnchallengedAndProven,
        ChallengedAndProven,
        Resolved
    }

    /*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/

    event ProposalSubmitted(
        uint256 indexed proposalId,
        uint256 indexed parentId,
        address indexed proposer,
        bytes32 root,
        uint256 l2BlockNumber
    );

    event ProposalChallenged(uint256 indexed proposalId, address indexed challenger);
    event ProposalProven(uint256 indexed proposalId, address indexed prover);
    event ProposalResolved(uint256 indexed proposalId, ResolutionStatus status);
    event AnchorUpdated(uint256 indexed proposalId, bytes32 root, uint256 l2BlockNumber);
    event ProposalClosed(uint256 indexed proposalId);
    event ProposerPermissionUpdated(address indexed proposer, bool allowed);
    event BlockProven(uint256 indexed l2BlockNumber, bytes32 root, address indexed prover);
    event L1BlockHashCheckpointed(uint256 indexed l1BlockNumber, bytes32 blockHash);

    /*//////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/

    error BadAuth();
    error IncorrectBondAmount();
    error AlreadyChallenged();
    error GameNotOver();
    error GameOver();
    error AlreadyResolved();
    error NoCredit();
    error TransferFailed();
    error InvalidParentGame();
    error BadCadence();
    error ParentGameNotResolved();
    error ProposingBackwards();
    error ProposingFutureBlock();
    error BlockAlreadyProven();
    error L1BlockHashNotAvailable();
    error L1BlockHashNotCheckpointed();
    error NoCanonicalProposal();
    error InvalidL2BlockNumber();

    /*//////////////////////////////////////////////////////////////
                               STRUCTS
    //////////////////////////////////////////////////////////////*/

    struct Proposal {
        bytes32 rootClaim;
        // packed slot
        address proposer;
        uint32 l2BlockNumber;
        uint32 parentIndex;
        uint32 deadline;
        uint32 resolvedAt;
        ProposalStatus proposalStatus;
        ResolutionStatus resolutionStatus;
        address challenger;
        address prover; // Who proved this specific proposal
    }

    // No struct needed - just store the prover address directly

    struct AggregationOutputs {
        bytes32 l1Head;
        bytes32 l2PreRoot;
        bytes32 claimRoot;
        uint256 claimBlockNum;
        bytes32 rollupConfigHash;
        bytes32 rangeVkeyCommitment;
        address proverAddress;
    }

    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/

    Proposal[] proposals; // index == proposalId

    mapping(address => uint256) public credit;

    mapping(address => bool) public whitelistedProposer;

    // The anchor tracks the latest accepted block
    uint256 public anchorL2BlockNumber;

    // Checkpointed L1 block hashes for proof verification
    mapping(uint256 => bytes32) public l1BlockHashes;

    // Maps L2 block number to the canonical proposal ID
    // 0 means no canonical proposal exists (uninitialized storage)
    // type(uint256).max means proposal 0 (genesis) is canonical
    uint256 private constant GENESIS_SENTINEL = type(uint256).max;
    mapping(uint256 => uint256) private _canonical;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        uint256 _challengeSecs,
        uint256 _proveSecs,
        uint256 _challengerBond,
        uint256 _proposerBond,
        uint256 _fallbackTimeout,
        uint256 _proposalInterval,
        bytes32 _startRoot,
        uint256 _startBlock,
        uint256 _l2StartTimestamp,
        uint256 _l2BlockTime,
        ISP1Verifier _verifier,
        bytes32 _rollupHash,
        bytes32 _aggVkey,
        bytes32 _rangeCommit
    ) {
        MAX_CHALLENGE_SECS = _challengeSecs;
        MAX_PROVE_SECS = _proveSecs;
        CHALLENGER_BOND = _challengerBond;
        PROPOSER_BOND = _proposerBond;
        FALLBACK_TIMEOUT_SECS = _fallbackTimeout;
        PROPOSAL_INTERVAL = _proposalInterval;
        L2_START_TIMESTAMP = _l2StartTimestamp;
        L2_BLOCK_TIME = _l2BlockTime;

        VERIFIER = _verifier;
        ROLLUP_CONFIG_HASH = _rollupHash;
        AGG_VKEY = _aggVkey;
        RANGE_VKEY_COMMITMENT = _rangeCommit;

        anchorL2BlockNumber = _startBlock;

        // Create genesis proposal representing the starting anchor
        Proposal memory genesis = Proposal({
            rootClaim: _startRoot,
            l2BlockNumber: _startBlock.toUint32(),
            parentIndex: 0,
            deadline: 0,
            proposer: address(0),
            challenger: address(0),
            resolvedAt: 0,
            proposalStatus: ProposalStatus.Resolved,
            resolutionStatus: ResolutionStatus.DEFENDER_WINS,
            prover: address(0)
        });

        proposals.push(genesis);

        _trySetCanonical(_startBlock, 0);
    }

    /*//////////////////////////////////////////////////////////////
                               ACTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Creates a proposal with validation common to both fault proofs and validity proofs
    /// @param root L2 output root being proposed
    /// @param l2BlockNumber L2 block number (must be parentBlock + PROPOSAL_INTERVAL)
    /// @param parentId Parent proposal ID (must be valid and not invalidated)
    /// @param proposer Proposer address (address(0) for validity proofs, actual address for fault proofs)
    /// @return proposalId ID of the created proposal
    function _createProposal(bytes32 root, uint256 l2BlockNumber, uint256 parentId, address proposer)
        internal
        returns (uint256 proposalId)
    {
        if (parentId >= proposals.length) {
            revert InvalidParentGame();
        }
        Proposal storage parent = proposals[parentId];

        if (l2BlockNumber <= anchorL2BlockNumber) {
            revert ProposingBackwards();
        }
        if (computeL2Timestamp(l2BlockNumber) >= block.timestamp) {
            revert ProposingFutureBlock();
        }

        if (_canonicalExistsFor(l2BlockNumber)) {
            revert BlockAlreadyProven();
        }

        // Proposals must follow the exact interval cadence from their parent
        if (l2BlockNumber != parent.l2BlockNumber + PROPOSAL_INTERVAL) {
            revert BadCadence();
        }

        // Cannot build on top of invalidated proposals
        if (parent.resolutionStatus == ResolutionStatus.CHALLENGER_WINS) {
            revert InvalidParentGame();
        }
        proposals.push();
        proposalId = proposals.length - 1;

        Proposal storage p = proposals[proposalId];
        p.rootClaim = root;
        p.l2BlockNumber = l2BlockNumber.toUint32();
        p.parentIndex = parentId.toUint32();
        p.deadline = (block.timestamp + MAX_CHALLENGE_SECS).toUint32();
        p.proposer = proposer;

        emit ProposalSubmitted(proposalId, parentId, proposer, root, l2BlockNumber);
    }

    /// @notice Submit a fault proof proposal that can be challenged
    /// @param root Output root claim for the L2 block
    /// @param l2BlockNumber L2 block number being proposed
    /// @param parentId Parent proposal to build upon
    /// @return proposalId ID of created proposal
    /// @dev Requires PROPOSER_BOND and proposer must be whitelisted or in fallback window
    function submitProposal(bytes32 root, uint256 l2BlockNumber, uint256 parentId)
        external
        payable
        returns (uint256 proposalId)
    {
        if (msg.value != PROPOSER_BOND) {
            revert IncorrectBondAmount();
        }

        // Authorization: whitelist OR 2-week fallback (censorship resistance)
        if (!isWhitelistedProposer(msg.sender) && !isInFallbackWindow(l2BlockNumber)) {
            revert BadAuth();
        }
        proposalId =
            _createProposal({root: root, l2BlockNumber: l2BlockNumber, parentId: parentId, proposer: msg.sender});
    }

    /// @notice Challenge a proposal claiming it has the wrong root
    /// @param id Proposal ID to challenge
    /// @dev Requires CHALLENGER_BOND, starts proof countdown
    function challengeProposal(uint256 id) external payable onlyIfGameNotOver(id) {
        if (msg.value != CHALLENGER_BOND) {
            revert IncorrectBondAmount();
        }

        Proposal storage p = proposals[id];
        if (p.proposalStatus != ProposalStatus.Unchallenged) {
            revert AlreadyChallenged();
        }

        p.challenger = msg.sender;
        p.proposalStatus = ProposalStatus.Challenged;
        p.deadline = (block.timestamp + MAX_PROVE_SECS).toUint32();

        emit ProposalChallenged(id, msg.sender);
    }

    /// @notice Submit a validity proof that bypasses the optimistic flow
    /// @param l2BlockNumber L2 block to prove (must be anchorBlock + PROPOSAL_INTERVAL)
    /// @param root Correct output root for this block
    /// @param l1BlockNumber L1 block used in proof (for L1 data availability)
    /// @param proof ZK proof of state transition from anchor to this block
    /// @dev Creates, proves, and resolves a proposal atomically. No bond required.
    function proveBlock(uint256 l2BlockNumber, bytes32 root, uint256 l1BlockNumber, bytes calldata proof) external {
        // Validity proofs must build directly on the anchor to ensure linear progression
        // Anchor always has a canonical (genesis at minimum)
        uint256 parentProposalId = anchorProposalId();

        // address(0) proposer indicates no bond was collected
        uint256 proposalId = _createProposal({
            root: root,
            l2BlockNumber: l2BlockNumber,
            parentId: parentProposalId,
            proposer: address(0)
        });

        proveProposal(proposalId, l1BlockNumber, proof);
        resolveProposal(proposalId);

        emit BlockProven(l2BlockNumber, root, msg.sender);
    }

    /// @notice Submit ZK proof defending a proposal
    /// @param id Proposal to prove
    /// @param l1BlockNumber L1 block for data availability context
    /// @param proof ZK proof of state transition from parent to this proposal
    /// @dev Parent must be valid for proof to be useful, but that's checked in resolution
    function proveProposal(uint256 id, uint256 l1BlockNumber, bytes calldata proof) public onlyIfGameNotOver(id) {
        Proposal storage p = proposals[id];

        bytes32 parentRoot = proposals[p.parentIndex].rootClaim;
        bytes32 l1BlockHash = getCheckpointedL1BlockHash(l1BlockNumber);
        AggregationOutputs memory pub = AggregationOutputs({
            l1Head: l1BlockHash,
            l2PreRoot: parentRoot,
            claimRoot: p.rootClaim,
            claimBlockNum: p.l2BlockNumber,
            rollupConfigHash: ROLLUP_CONFIG_HASH,
            rangeVkeyCommitment: RANGE_VKEY_COMMITMENT,
            proverAddress: msg.sender
        });

        VERIFIER.verifyProof(AGG_VKEY, abi.encode(pub), proof);

        p.prover = msg.sender;
        p.proposalStatus = (p.proposalStatus == ProposalStatus.Challenged)
            ? ProposalStatus.ChallengedAndProven
            : ProposalStatus.UnchallengedAndProven;

        emit ProposalProven(id, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyIfGameOver(uint256 proposalId) {
        if (!gameOver(proposalId)) {
            revert GameNotOver();
        }
        _;
    }

    modifier onlyIfGameNotOver(uint256 proposalId) {
        if (gameOver(proposalId)) {
            revert GameOver();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                          GAME STATE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Check if a proposal's game has ended (ready for resolution)
    /// @param proposalId Proposal to check
    /// @return True if deadline passed, proven locally, or canonical exists for block
    function gameOver(uint256 proposalId) public view returns (bool) {
        Proposal storage p = proposals[proposalId];
        return p.deadline < block.timestamp || p.prover != address(0) || _canonicalExistsFor(p.l2BlockNumber);
    }

    /// @notice Calculate how long ago an L2 block should have been created
    /// @param l2BlockNumber L2 block number
    /// @return Age in seconds since the block's expected timestamp
    function l2BlockAge(uint256 l2BlockNumber) public view returns (uint256) {
        return block.timestamp - computeL2Timestamp(l2BlockNumber);
    }

    /// @notice Returns the L2 timestamp corresponding to a given L2 block number.
    /// @notice Compute the expected timestamp for an L2 block
    /// @param _l2BlockNumber L2 block number
    /// @return Expected timestamp based on L2_BLOCK_TIME and genesis
    function computeL2Timestamp(uint256 _l2BlockNumber) public view returns (uint256) {
        if (_l2BlockNumber < proposals[0].l2BlockNumber) {
            revert InvalidL2BlockNumber();
        }

        return L2_START_TIMESTAMP + ((_l2BlockNumber - proposals[0].l2BlockNumber) * L2_BLOCK_TIME);
    }

    /// @notice Get L1 block hash from checkpoint or EVM history
    /// @param l1BlockNumber L1 block number
    /// @return l1BlockHash Block hash (reverts if too old and not checkpointed)
    function getCheckpointedL1BlockHash(uint256 l1BlockNumber) internal view returns (bytes32 l1BlockHash) {
        l1BlockHash = l1BlockHashes[l1BlockNumber];
        if (l1BlockHash == bytes32(0)) {
            revert L1BlockHashNotCheckpointed();
        }
    }

    /// @notice Resolve a proposal determining if defender or challenger wins
    /// @param id Proposal to resolve
    /// @dev Resolution hierarchy:
    /// @dev 1. Parent invalid → challenger wins (cascading invalidation)
    /// @dev 2. Conflicts with canonical → challenger wins (bulk invalidation)
    /// @dev 3. Has valid proof → defender wins
    /// @dev 4. Timeout: challenged → challenger wins, unchallenged → defender wins
    function resolveProposal(uint256 id) public onlyIfGameOver(id) {
        Proposal storage p = proposals[id];
        Proposal storage parent = proposals[p.parentIndex];

        if (parent.resolutionStatus == ResolutionStatus.IN_PROGRESS) {
            revert ParentGameNotResolved();
        }
        if (p.resolutionStatus != ResolutionStatus.IN_PROGRESS) {
            revert AlreadyResolved();
        }

        // Resolution hierarchy (order matters!)
        if (parent.resolutionStatus == ResolutionStatus.CHALLENGER_WINS) {
            p.resolutionStatus = ResolutionStatus.CHALLENGER_WINS;
        } else if (_proposalConflictsWithCanonical(p)) {
            p.resolutionStatus = ResolutionStatus.CHALLENGER_WINS;
        } else if (_getProposalProver(p) != address(0)) {
            p.resolutionStatus = ResolutionStatus.DEFENDER_WINS;
        } else if (p.proposalStatus == ProposalStatus.Challenged) {
            p.resolutionStatus = ResolutionStatus.CHALLENGER_WINS;
        } else {
            p.resolutionStatus = ResolutionStatus.DEFENDER_WINS;
        }

        if (p.resolutionStatus == ResolutionStatus.DEFENDER_WINS) {
            _trySetCanonical(p.l2BlockNumber, id);

            // Advance anchor only if this directly extends it
            if (p.l2BlockNumber == anchorL2BlockNumber + PROPOSAL_INTERVAL) {
                anchorL2BlockNumber = p.l2BlockNumber;
                emit AnchorUpdated(id, p.rootClaim, p.l2BlockNumber);
            }

            _pay(p.proposer, _proposerBond(p));
            _pay(_getProposalProver(p), _challengerBond(p));
        } else if (p.resolutionStatus == ResolutionStatus.CHALLENGER_WINS) {
            address recipient = p.challenger;
            if (recipient == address(0)) {
                // Bulk invalidation case: pay canonical prover who proved correct root
                // If no canonical exists yet, bond is burned (recipient remains address(0))
                if (_canonicalExistsFor(p.l2BlockNumber)) {
                    recipient = _getProposalProver(_canonicalProposalFor(p.l2BlockNumber));
                }
            }
            _pay(recipient, _totalBond(p));
        }

        p.proposalStatus = ProposalStatus.Resolved;
        p.resolvedAt = (block.timestamp).toUint32();
        emit ProposalResolved(id, p.resolutionStatus);
        emit ProposalClosed(id);
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL PAY-OUT HELPERS
    //////////////////////////////////////////////////////////////*/

    /// @dev Credits account
    function _pay(address to, uint256 amount) internal {
        if (to != address(0) && amount != 0) {
            credit[to] += amount;
        }
    }

    /// @dev Returns proposer bond amount (0 for validity proofs)
    function _proposerBond(Proposal storage p) internal view returns (uint256) {
        return p.proposer != address(0) ? PROPOSER_BOND : 0;
    }

    /// @dev Returns challenger bond amount (0 if unchallenged)
    function _challengerBond(Proposal storage p) internal view returns (uint256) {
        return p.challenger != address(0) ? CHALLENGER_BOND : 0;
    }

    /// @dev Total bonds at stake for this proposal
    function _totalBond(Proposal storage p) internal view returns (uint256) {
        return _proposerBond(p) + _challengerBond(p);
    }

    /// @dev Find who proved this proposal (considering canonical fallback)
    /// @return Prover address or address(0) if conflicts with canonical
    function _getProposalProver(Proposal storage p) internal view returns (address) {
        if (_proposalConflictsWithCanonical(p)) {
            return address(0);
        }

        // Prefer local prover, fall back to canonical proposal's prover
        if (p.prover != address(0)) {
            return p.prover;
        }

        if (_canonicalExistsFor(p.l2BlockNumber)) {
            Proposal storage canonical = _canonicalProposalFor(p.l2BlockNumber);
            return canonical.prover != address(0) ? canonical.prover : canonical.proposer;
        }

        return address(0);
    }

    /// @dev Check if proposal has wrong root compared to canonical
    function _proposalConflictsWithCanonical(Proposal storage p) internal view returns (bool) {
        return _canonicalExistsFor(p.l2BlockNumber) && _canonicalProposalFor(p.l2BlockNumber).rootClaim != p.rootClaim;
    }

    /*//////////////////////////////////////////////////////////////
                         CREDIT WITHDRAWAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Withdraw accumulated credit from bonds
    /// @param recipient Address to withdraw credit for
    /// @dev Uses pull pattern to prevent reentrancy
    function claimCredit(address recipient) public nonReentrant {
        uint256 amount = credit[recipient];
        if (amount == 0) {
            revert NoCredit();
        }

        credit[recipient] = 0;
        (bool ok,) = recipient.call{value: amount}("");
        if (!ok) {
            revert TransferFailed();
        }
    }

    /*//////////////////////////////////////////////////////////////
                    PERMISSIONS & AUTHORIZATION
    //////////////////////////////////////////////////////////////*/

    /// @notice Update proposer whitelist
    /// @param proposer Address to update
    /// @param allowed Whether address can propose
    function setProposer(address proposer, bool allowed) external onlyOwner {
        whitelistedProposer[proposer] = allowed;
        emit ProposerPermissionUpdated(proposer, allowed);
    }

    /// @notice Check if address can submit proposals
    /// @param proposer Address to check
    /// @return True if whitelisted or wildcard enabled
    function isWhitelistedProposer(address proposer) public view returns (bool) {
        return whitelistedProposer[proposer] || whitelistedProposer[address(0)];
    }

    /// @notice Check if fallback window is active (anyone can propose)
    /// @param l2BlockNumber Block to check
    /// @return True if block is old enough for fallback
    function isInFallbackWindow(uint256 l2BlockNumber) public view returns (bool) {
        return l2BlockAge(l2BlockNumber) > FALLBACK_TIMEOUT_SECS;
    }

    /// @notice Store L1 block hash for proofs requiring old blocks
    /// @param l1BlockNumber L1 block to checkpoint (must be recent)
    /// @dev Only needed for blocks older than 256 blocks
    function checkpointL1BlockHash(uint256 l1BlockNumber) external {
        bytes32 blockHash = blockhash(l1BlockNumber);
        if (blockHash == bytes32(0)) {
            revert L1BlockHashNotAvailable();
        }
        l1BlockHashes[l1BlockNumber] = blockHash;

        emit L1BlockHashCheckpointed(l1BlockNumber, blockHash);
    }

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the current anchor's output root
    /// @return Output root of the anchor block
    function anchorRoot() public view returns (bytes32) {
        // Anchor always has a canonical proposal (genesis at minimum)
        return _canonicalProposalFor(anchorL2BlockNumber).rootClaim;
    }

    /// @notice Get a single proposal
    /// @param id Proposal ID
    /// @return The proposal struct
    function getProposal(uint256 id) external view returns (Proposal memory) {
        return proposals[id];
    }

    /// @notice Get current anchor root and block number
    /// @return root Output root
    /// @return blockNumber L2 block number
    function getAnchorRoot() external view returns (bytes32, uint256) {
        return (anchorRoot(), anchorL2BlockNumber);
    }

    /// @notice Batch get proposals by IDs
    /// @param ids Array of proposal IDs
    /// @return out Array of proposals
    function getProposals(uint256[] calldata ids) external view returns (Proposal[] memory out) {
        out = new Proposal[](ids.length);
        for (uint256 i; i < ids.length; ++i) {
            out[i] = proposals[ids[i]];
        }
    }

    /// @notice Get most recent proposal IDs
    /// @param count Number of proposals to return
    /// @return ids Array of proposal IDs (newest first)
    function latestProposals(uint256 count) external view returns (uint256[] memory ids) {
        uint256 total = proposals.length;
        if (count > total) {
            count = total;
        }
        ids = new uint256[](count);
        for (uint256 i; i < count; ++i) {
            ids[i] = total - 1 - i;
        }
    }

    /// @notice Get total number of proposals
    /// @return Number of proposals created
    function getProposalsLength() external view returns (uint256) {
        return proposals.length;
    }

    /// @notice Check if proposal can be resolved
    /// @param proposalId Proposal to check
    /// @return True if game over and not yet resolved
    function isResolvable(uint256 proposalId) external view returns (bool) {
        if (proposalId >= proposals.length) {
            return false;
        }
        Proposal storage p = proposals[proposalId];
        return gameOver(proposalId) && p.resolutionStatus == ResolutionStatus.IN_PROGRESS;
    }

    /// @notice Check if proposal needs a proof
    /// @param proposalId Proposal to check
    /// @return True if challenged and deadline not passed
    function needsDefense(uint256 proposalId) external view returns (bool) {
        if (proposalId >= proposals.length) {
            return false;
        }
        return !gameOver(proposalId) && proposals[proposalId].proposalStatus == ProposalStatus.Challenged;
    }

    /// @notice Get the canonical proposal ID for the anchor block
    /// @return Proposal ID of current anchor
    function anchorProposalId() public view returns (uint256) {
        return canonicalProposalIdFor(anchorL2BlockNumber);
    }

    /*//////////////////////////////////////////////////////////////
                     CANONICAL PROPOSAL HELPERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Get the canonical proposal for an L2 block
    /// @param l2BlockNumber The L2 block number
    /// @return The canonical proposal, or empty proposal if none exists
    function canonicalProposalFor(uint256 l2BlockNumber) public view returns (Proposal memory) {
        if (!_canonicalExistsFor(l2BlockNumber)) {
            revert NoCanonicalProposal();
        }

        uint256 canonicalId = canonicalProposalIdFor(l2BlockNumber);
        return proposals[canonicalId];
    }

    /// @notice Get the canonical proposal ID for an L2 block
    /// @param l2BlockNumber The L2 block number
    /// @return The canonical proposal ID, or 0 if none exists
    function canonicalProposalIdFor(uint256 l2BlockNumber) public view returns (uint256) {
        if (!_canonicalExistsFor(l2BlockNumber)) {
            revert NoCanonicalProposal();
        }

        return _canonical[l2BlockNumber] == GENESIS_SENTINEL ? 0 : _canonical[l2BlockNumber];
    }

    function proposalIsCanonical(uint256 proposalId) public view returns (bool) {
        if (proposalId >= proposals.length) {
            return false;
        }
        Proposal storage p = proposals[proposalId];
        return _canonicalExistsFor(p.l2BlockNumber) && proposalId == canonicalProposalIdFor(p.l2BlockNumber);
    }

    /// @dev Get the canonical proposal storage reference (reverts if doesn't exist)
    function _canonicalProposalFor(uint256 l2BlockNumber) internal view returns (Proposal storage) {
        uint256 canonicalId = canonicalProposalIdFor(l2BlockNumber);

        return proposals[canonicalId];
    }

    /// @dev Check if a canonical proposal exists for an L2 block
    function _canonicalExistsFor(uint256 l2BlockNumber) internal view returns (bool) {
        return _canonical[l2BlockNumber] != 0;
    }

    /// @dev Try to set the canonical proposal for an L2 block (only sets if not already set)
    function _trySetCanonical(uint256 l2BlockNumber, uint256 proposalId) internal {
        if (!_canonicalExistsFor(l2BlockNumber)) {
            _canonical[l2BlockNumber] = proposalId == 0 ? GENESIS_SENTINEL : proposalId;
        }
    }
}
