// SPDX-License-Identifier: Unknown
pragma solidity 0.8.30;

interface IProtocolTreasury {
    error GateIsClosed(string reason);
    error ProposalIsAlive();
    error NoProposalToMark();

    event ProposalMarked(uint256 indexed proposalId);

    function markNext() external;
    function relay(address target, bytes calldata data, uint256 value) external returns (bytes memory);
    function getActivationTimestamp() external view returns (uint256);
    function owner() external view returns (address);
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

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface Governance is IGovernance {
    function proposalCount() external view returns (uint256);
    function getProposal(uint256 _proposalId) external view override(IGovernance) returns (Proposal memory);
    function getProposalState(uint256 _proposalId) external view override(IGovernance) returns (ProposalState);
}

type StakerVersion is uint256;

type MilestoneId is uint96;

enum MilestoneStatus {
    Pending,
    Failed,
    Succeeded
}

/**
 * @notice  The parameters for a lock
 *          The parameters used to derive the actual lock.
 *
 * @param   startTime The timestamp that the lock starts at (0 before this value)
 * @param   cliffDuration Time until the cliff is reached
 * @param   lockDuration Time until the lock is fully unlocked
 */
struct LockParams {
    uint256 startTime;
    uint256 cliffDuration;
    uint256 lockDuration;
}

interface IRegistry {
    event UpdatedRevoker(address revoker);
    event UpdatedRevokerOperator(address revokerOperator);
    event UpdatedExecuteAllowedAt(uint256 executeAllowedAt);
    event UpdatedUnlockStartTime(uint256 unlockStartTime);
    event StakerRegistered(StakerVersion version, address implementation);
    event MilestoneAdded(MilestoneId milestoneId);
    event MilestoneStatusUpdated(MilestoneId milestoneId, MilestoneStatus status);

    error InvalidExecuteAllowedAt(uint256 newExecuteAllowedAt, uint256 currentExecuteAllowedAt);
    error InvalidUnlockStartTime(uint256 newUnlockStartTime, uint256 currentUnlockStartTime);
    error InvalidUnlockDuration();
    error InvalidUnlockCliffDuration();
    error InvalidStakerImplementation(address implementation);

    error UnRegisteredStaker(StakerVersion version);
    error InvalidMilestoneId(MilestoneId milestoneId);
    error InvalidMilestoneStatus(MilestoneId milestoneId);

    function setRevoker(address _revoker) external;
    function setRevokerOperator(address _revokerOperator) external;
    function setExecuteAllowedAt(uint256 _executeAllowedAt) external;
    function setUnlockStartTime(uint256 _unlockStartTime) external;
    function registerStakerImplementation(address _implementation) external;
    function addMilestone() external returns (MilestoneId);
    function setMilestoneStatus(MilestoneId _milestoneId, MilestoneStatus _status) external;

    function getRevoker() external view returns (address);
    function getRevokerOperator() external view returns (address);
    function getExecuteAllowedAt() external view returns (uint256);
    function getUnlockStartTime() external view returns (uint256);
    function getGlobalLockParams() external view returns (LockParams memory);
    function getStakerImplementation(StakerVersion _version) external view returns (address);
    function getNextStakerVersion() external view returns (StakerVersion);
    function getMilestoneStatus(MilestoneId _milestoneId) external view returns (MilestoneStatus);
    function getNextMilestoneId() external view returns (MilestoneId);
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
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert Errors.InsufficientBalance(address(this).balance, amount);
        }

        (bool success, bytes memory returndata) = recipient.call{value: amount}("");
        if (!success) {
            _revert(returndata);
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {Errors.FailedCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert Errors.InsufficientBalance(address(this).balance, value);
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {Errors.FailedCall}) in case
     * of an unsuccessful call.
     */
    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata)
        internal
        view
        returns (bytes memory)
    {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {Errors.FailedCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {Errors.FailedCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly ("memory-safe") {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert Errors.FailedCall();
        }
    }
}

/**
 * @title   ProtocolTreasury
 * @author  Aztec Labs
 * @notice  A non-transferable date gated relayer that further restrict calls such that they can only be relayed if
 *          a specified atp-registry allows execution in the related ATP's.
 *
 *          Example usage is for ownership of contracts that becomes property of the governance at some point
 *          in the future when a group of ATP's can participate.
 *
 *          NOTE: because it is non-transferable it does not work well with governance upgrading itself before relays
 *          are allowed.
 *
 *          NOTE: governance can "DOS" this relayer temporarily by extending the delays of governance. This would
 *          temporarily impact the liveness, but as the delay configuration is bounded it cannot be forever.
 */
contract ProtocolTreasury is IProtocolTreasury {
    Governance public immutable GOVERNANCE;
    IRegistry public immutable ATP_REGISTRY;
    uint256 public immutable GATED_UNTIL;

    uint256 public markedProposalsCount;
    uint256 public blockOfLastMarkNext;

    constructor(address _governance, address _atpRegistry, uint256 _gatedUntil) {
        GOVERNANCE = Governance(_governance);
        ATP_REGISTRY = IRegistry(_atpRegistry);
        GATED_UNTIL = _gatedUntil;
    }

    /**
     * @notice  Marks the next proposal if "stable"
     *          Used to progress the list of proposals forward to satisfy checks in relay
     *
     * @dev     Reverts if there are no "unmarked" proposals
     * @dev     Reverts if the proposal is neither EXECUTED | EXPIRED | DROPPED | REJECTED
     *          Essentially, if the state can still change, it is seen as alive.
     */
    function markNext() external override(IProtocolTreasury) {
        uint256 proposalId = markedProposalsCount;
        require(proposalId < GOVERNANCE.proposalCount(), NoProposalToMark());
        ProposalState state = GOVERNANCE.getProposalState(proposalId);

        // state should be either Executed | Expired | Droppped | Reject
        // if that is not the case, it might still be an active proposal and should wait
        require(
            state == ProposalState.Executed || state == ProposalState.Expired || state == ProposalState.Dropped
                || state == ProposalState.Rejected,
            ProposalIsAlive()
        );

        markedProposalsCount++;
        blockOfLastMarkNext = block.number;

        emit ProposalMarked(proposalId);
    }

    /**
     * @notice  Relays the call and potentially transfer ether from self
     *
     * @dev     Reverts if caller is not owner
     * @dev     Reverts if called before GATED_UNTIL
     * @dev     Reverts if called after markNext in the same block
     * @dev     Reverts if the oldest unmarked proposal was created before treasury became active
     *
     * @param target - The address to call
     * @param data - The calldata for the call
     * @param value - The amount of ether (in wei) to forward
     *
     * @return The return value of the function call (as bytes)
     */
    function relay(address target, bytes calldata data, uint256 value)
        external
        override(IProtocolTreasury)
        returns (bytes memory)
    {
        require(msg.sender == address(GOVERNANCE), Ownable.OwnableUnauthorizedAccount(msg.sender));
        require(block.timestamp >= GATED_UNTIL, GateIsClosed("gated until not met"));

        // We do NOT allow `markNext()` to happen in the same block as `isOpen` because that could allow a
        // governance proposal to be marked during its execution. Which could be used to make `isOpen` pass
        // even though we are in the middle of an execution that was made BEFORE insiders could act.
        require(block.number > blockOfLastMarkNext, GateIsClosed("markNext called this block"));

        // The only way `governance` can make a `relay` call is through a proposal. If all proposals are marked
        // the all already have happened, and there is nothing to execute.
        // This is implicitly covered by the creation check, as non-existing proposals have creation time 0, which will
        // never be bigger than another uint.
        //
        // Since time always marches forward, if a proposal is made AFTER getActivationTimestamp, then so are
        // all proposals following it. This means that as soon as as `markedProposalsCount` will be the index of a
        // proposal that was created AFTER the getActivationTimestamp there are no need to mark any other proposals
        // as it will keep being true.
        require(
            GOVERNANCE.getProposal(markedProposalsCount).creation > Timestamp.wrap(getActivationTimestamp()),
            GateIsClosed("not activated yet")
        );

        // Using a mix of low-level calls and OZ lib to handle transfers to non-contracts and easily bubble up.
        require(value == 0 || address(this).balance >= value, Errors.InsufficientBalance(address(this).balance, value));
        (bool success, bytes memory returnData) = payable(target).call{value: value}(data);
        return Address.verifyCallResult(success, returnData);
    }

    /**
     * @notice Allows receiving ether
     */
    receive() external payable {}

    /**
     * @notice  The timestamp where the treasury becomes active
     *
     * @return  Timestamp where treasury can relay
     */
    function getActivationTimestamp() public view override(IProtocolTreasury) returns (uint256) {
        return ATP_REGISTRY.getExecuteAllowedAt() + 7 days;
    }

    /**
     * @notice  Returns the owner (governance)
     *
     * @dev     Exists to make the contract align better with other relayers
     *
     * @return  The address of the governance
     */
    function owner() external view override(IProtocolTreasury) returns (address) {
        return address(GOVERNANCE);
    }
}
