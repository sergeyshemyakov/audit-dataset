// SPDX-License-Identifier: Unknown
pragma solidity 0.8.30;

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
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data)
        external
        returns (bool);

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
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
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
    function transferFromAndCallRelaxed(IERC1363 token, address from, address to, uint256 value, bytes memory data)
        internal
    {
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

type CompressedTimestamp is uint32;

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

type CompressedBallot is uint256;

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
     * @dev Return the 512-bit addition of two uint256.
     *
     * The result is stored in two 256 variables such that sum = high * 2²⁵⁶ + low.
     */
    function add512(uint256 a, uint256 b) internal pure returns (uint256 high, uint256 low) {
        assembly ("memory-safe") {
            low := add(a, b)
            high := lt(low, a)
        }
    }

    /**
     * @dev Return the 512-bit multiplication of two uint256.
     *
     * The result is stored in two 256 variables such that product = high * 2²⁵⁶ + low.
     */
    function mul512(uint256 a, uint256 b) internal pure returns (uint256 high, uint256 low) {
        // 512-bit multiply [high low] = x * y. Compute the product mod 2²⁵⁶ and mod 2²⁵⁶ - 1, then use
        // the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = high * 2²⁵⁶ + low.
        assembly ("memory-safe") {
            let mm := mulmod(a, b, not(0))
            low := mul(a, b)
            high := sub(sub(mm, low), lt(mm, low))
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, with a success flag (no overflow).
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            success = c >= a;
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with a success flag (no overflow).
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a - b;
            success = c <= a;
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with a success flag (no overflow).
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a * b;
            assembly ("memory-safe") {
                // Only true when the multiplication doesn't overflow
                // (c / a == b) || (a == 0)
                success := or(eq(div(c, a), b), iszero(a))
            }
            // equivalent to: success ? c : 0
            result = c * SafeCast.toUint(success);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a success flag (no division by zero).
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            success = b > 0;
            assembly ("memory-safe") {
                // The `DIV` opcode returns zero when the denominator is 0.
                result := div(a, b)
            }
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a success flag (no division by zero).
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            success = b > 0;
            assembly ("memory-safe") {
                // The `MOD` opcode returns zero when the denominator is 0.
                result := mod(a, b)
            }
        }
    }

    /**
     * @dev Unsigned saturating addition, bounds to `2²⁵⁶ - 1` instead of overflowing.
     */
    function saturatingAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        (bool success, uint256 result) = tryAdd(a, b);
        return ternary(success, result, type(uint256).max);
    }

    /**
     * @dev Unsigned saturating subtraction, bounds to zero instead of overflowing.
     */
    function saturatingSub(uint256 a, uint256 b) internal pure returns (uint256) {
        (, uint256 result) = trySub(a, b);
        return result;
    }

    /**
     * @dev Unsigned saturating multiplication, bounds to `2²⁵⁶ - 1` instead of overflowing.
     */
    function saturatingMul(uint256 a, uint256 b) internal pure returns (uint256) {
        (bool success, uint256 result) = tryMul(a, b);
        return ternary(success, result, type(uint256).max);
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
            (uint256 high, uint256 low) = mul512(x, y);

            // Handle non-overflow cases, 256 by 256 division.
            if (high == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return low / denominator;
            }

            // Make sure the result is less than 2²⁵⁶. Also prevents denominator == 0.
            if (denominator <= high) {
                Panic.panic(ternary(denominator == 0, Panic.DIVISION_BY_ZERO, Panic.UNDER_OVERFLOW));
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [high low].
            uint256 remainder;
            assembly ("memory-safe") {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                high := sub(high, gt(remainder, low))
                low := sub(low, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly ("memory-safe") {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [high low] by twos.
                low := div(low, twos)

                // Flip twos such that it is 2²⁵⁶ / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from high into low.
            low |= high * twos;

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
            // less than 2²⁵⁶, this is the final result. We don't need to compute the high bits of the result and high
            // is no longer required.
            result = low * inverse;
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
     * @dev Calculates floor(x * y >> n) with full precision. Throws if result overflows a uint256.
     */
    function mulShr(uint256 x, uint256 y, uint8 n) internal pure returns (uint256 result) {
        unchecked {
            (uint256 high, uint256 low) = mul512(x, y);
            if (high >= 1 << n) {
                Panic.panic(Panic.UNDER_OVERFLOW);
            }
            return (high << (256 - n)) | (low >> n);
        }
    }

    /**
     * @dev Calculates x * y >> n with full precision, following the selected rounding direction.
     */
    function mulShr(uint256 x, uint256 y, uint8 n, Rounding rounding) internal pure returns (uint256) {
        return mulShr(x, y, n) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, 1 << n) > 0);
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
            if (n == 0) {
                return 0;
            }

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

            if (gcd != 1) {
                return 0;
            } // No inverse exists.
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
        if (m == 0) {
            return (false, 0);
        }
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
    function tryModExp(bytes memory b, bytes memory e, bytes memory m)
        internal
        view
        returns (bool success, bytes memory result)
    {
        if (_zeroBytes(m)) {
            return (false, new bytes(0));
        }

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
    function log256(uint256 x) internal pure returns (uint256 r) {
        // If value has upper 128 bits set, log2 result is at least 128
        r = SafeCast.toUint(x > 0xffffffffffffffffffffffffffffffff) << 7;
        // If upper 64 bits of 128-bit half set, add 64 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffffffffffff) << 6;
        // If upper 32 bits of 64-bit half set, add 32 to result
        r |= SafeCast.toUint((x >> r) > 0xffffffff) << 5;
        // If upper 16 bits of 32-bit half set, add 16 to result
        r |= SafeCast.toUint((x >> r) > 0xffff) << 4;
        // Add 1 if upper 8 bits of 16-bit half set, and divide accumulated result by 8
        return (r >> 3) | SafeCast.toUint((x >> r) > 0xff);
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
    function push(Trace224 storage self, uint32 key, uint224 value)
        internal
        returns (uint224 oldValue, uint224 newValue)
    {
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
     * @dev Returns the number of checkpoints.
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
    function _insert(Checkpoint224[] storage self, uint32 key, uint224 value)
        private
        returns (uint224 oldValue, uint224 newValue)
    {
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
    function _upperBinaryLookup(Checkpoint224[] storage self, uint32 key, uint256 low, uint256 high)
        private
        view
        returns (uint256)
    {
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
    function _lowerBinaryLookup(Checkpoint224[] storage self, uint32 key, uint256 low, uint256 high)
        private
        view
        returns (uint256)
    {
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
    function _unsafeAccess(Checkpoint224[] storage self, uint256 pos)
        private
        pure
        returns (Checkpoint224 storage result)
    {
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
    function push(Trace208 storage self, uint48 key, uint208 value)
        internal
        returns (uint208 oldValue, uint208 newValue)
    {
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
     * @dev Returns the number of checkpoints.
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
    function _insert(Checkpoint208[] storage self, uint48 key, uint208 value)
        private
        returns (uint208 oldValue, uint208 newValue)
    {
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
    function _upperBinaryLookup(Checkpoint208[] storage self, uint48 key, uint256 low, uint256 high)
        private
        view
        returns (uint256)
    {
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
    function _lowerBinaryLookup(Checkpoint208[] storage self, uint48 key, uint256 low, uint256 high)
        private
        view
        returns (uint256)
    {
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
    function _unsafeAccess(Checkpoint208[] storage self, uint256 pos)
        private
        pure
        returns (Checkpoint208 storage result)
    {
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
    function push(Trace160 storage self, uint96 key, uint160 value)
        internal
        returns (uint160 oldValue, uint160 newValue)
    {
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
     * @dev Returns the number of checkpoints.
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
    function _insert(Checkpoint160[] storage self, uint96 key, uint160 value)
        private
        returns (uint160 oldValue, uint160 newValue)
    {
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
    function _upperBinaryLookup(Checkpoint160[] storage self, uint96 key, uint256 low, uint256 high)
        private
        view
        returns (uint256)
    {
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
    function _lowerBinaryLookup(Checkpoint160[] storage self, uint96 key, uint256 low, uint256 high)
        private
        view
        returns (uint256)
    {
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
    function _unsafeAccess(Checkpoint160[] storage self, uint256 pos)
        private
        pure
        returns (Checkpoint160 storage result)
    {
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
        require(
            current >= amount, Errors.Governance__CheckpointedUintLib__InsufficientValue(msg.sender, current, amount)
        );
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

library ConfigurationLib {
    using CompressedTimeMath for CompressedTimestamp;

    uint256 internal constant QUORUM_LOWER = 1;
    uint256 internal constant QUORUM_UPPER = 1e18;

    uint256 internal constant REQUIRED_YEA_MARGIN_UPPER = 1e18;

    uint256 internal constant VOTES_LOWER = 1;
    uint256 internal constant VOTES_UPPER = type(uint96).max; // Maximum for compressed storage (uint96)

    uint256 internal constant LOCK_AMOUNT_LOWER = 2;
    uint256 internal constant LOCK_AMOUNT_UPPER = type(uint96).max; // Maximum for compressed storage (uint96)

    Timestamp internal constant TIME_LOWER = Timestamp.wrap(60);
    Timestamp internal constant TIME_UPPER = Timestamp.wrap(90 * 24 * 3600);

    /**
     * @notice The delay after which a withdrawal can be finalized.
     * @dev This applies to the "normal" withdrawal, not one induced by proposeWithLock.
     * @dev Making the delay equal to the voting duration + execution delay + a "small buffer"
     * ensures that if you were able to vote on a proposal, someone may execute it before you can exit.
     *
     * The "small buffer" is somewhat arbitrarily set to the votingDelay / 5.
     */
    function getWithdrawalDelay(CompressedConfiguration storage _self) internal view returns (Timestamp) {
        Timestamp votingDelay = _self.votingDelay.decompress();
        Timestamp votingDuration = _self.votingDuration.decompress();
        Timestamp executionDelay = _self.executionDelay.decompress();

        return Timestamp.wrap(Timestamp.unwrap(votingDelay) / 5) + votingDuration + executionDelay;
    }

    /**
     * @notice
     * @dev     We specify `memory` here since it is called on outside import for validation
     *          before writing it to state.
     */
    function assertValid(Configuration memory _self) internal pure {
        require(_self.quorum >= QUORUM_LOWER, Errors.Governance__ConfigurationLib__QuorumTooSmall());
        require(_self.quorum <= QUORUM_UPPER, Errors.Governance__ConfigurationLib__QuorumTooBig());

        require(
            _self.requiredYeaMargin <= REQUIRED_YEA_MARGIN_UPPER,
            Errors.Governance__ConfigurationLib__RequiredYeaMarginTooBig()
        );

        require(_self.minimumVotes >= VOTES_LOWER, Errors.Governance__ConfigurationLib__InvalidMinimumVotes());
        require(_self.minimumVotes <= VOTES_UPPER, Errors.Governance__ConfigurationLib__InvalidMinimumVotes());

        require(
            _self.proposeConfig.lockAmount >= LOCK_AMOUNT_LOWER,
            Errors.Governance__ConfigurationLib__LockAmountTooSmall()
        );
        require(
            _self.proposeConfig.lockAmount <= LOCK_AMOUNT_UPPER, Errors.Governance__ConfigurationLib__LockAmountTooBig()
        );

        // Beyond checking the bounds like this, it might be useful to ensure that the value is larger than the withdrawal
        // delay. this, can be useful if one want to ensure that the "locker" cannot himself vote in the proposal, but as
        // it is unclear if this is a useful property, it is not enforced.
        require(
            _self.proposeConfig.lockDelay >= TIME_LOWER, Errors.Governance__ConfigurationLib__TimeTooSmall("LockDelay")
        );
        require(
            _self.proposeConfig.lockDelay <= Timestamp.wrap(type(uint32).max),
            Errors.Governance__ConfigurationLib__TimeTooBig("LockDelay")
        );

        require(_self.votingDelay >= TIME_LOWER, Errors.Governance__ConfigurationLib__TimeTooSmall("VotingDelay"));
        require(_self.votingDelay <= TIME_UPPER, Errors.Governance__ConfigurationLib__TimeTooBig("VotingDelay"));

        require(_self.votingDuration >= TIME_LOWER, Errors.Governance__ConfigurationLib__TimeTooSmall("VotingDuration"));
        require(_self.votingDuration <= TIME_UPPER, Errors.Governance__ConfigurationLib__TimeTooBig("VotingDuration"));

        require(_self.executionDelay >= TIME_LOWER, Errors.Governance__ConfigurationLib__TimeTooSmall("ExecutionDelay"));
        require(_self.executionDelay <= TIME_UPPER, Errors.Governance__ConfigurationLib__TimeTooBig("ExecutionDelay"));

        require(_self.gracePeriod >= TIME_LOWER, Errors.Governance__ConfigurationLib__TimeTooSmall("GracePeriod"));
        require(_self.gracePeriod <= TIME_UPPER, Errors.Governance__ConfigurationLib__TimeTooBig("GracePeriod"));
    }
}

library CompressedConfigurationLib {
    using SafeCast for uint256;
    using CompressedTimeMath for Timestamp;
    using CompressedTimeMath for CompressedTimestamp;

    /**
     * @notice Get the propose configuration directly from storage
     * @param _compressed Storage pointer to compressed configuration
     * @return The propose configuration
     */
    function getProposeConfig(CompressedConfiguration storage _compressed)
        internal
        view
        returns (ProposeWithLockConfiguration memory)
    {
        return ProposeWithLockConfiguration({
            lockDelay: _compressed.lockDelay.decompress(),
            lockAmount: _compressed.lockAmount
        });
    }

    /**
     * @notice Compress a Configuration struct into CompressedConfiguration
     * @param _config The uncompressed configuration
     * @return The compressed configuration
     * @dev Values that exceed the compressed type limits will cause a revert.
     *      This is intentional to prevent storing invalid configurations.
     */
    function compress(Configuration memory _config) internal pure returns (CompressedConfiguration memory) {
        // Validate that amounts fit in their compressed types
        require(_config.proposeConfig.lockAmount <= type(uint96).max, "lockAmount exceeds uint96");
        require(_config.minimumVotes <= type(uint96).max, "minimumVotes exceeds uint96");
        require(_config.quorum <= type(uint64).max, "quorum exceeds uint64");
        require(_config.requiredYeaMargin <= type(uint64).max, "requiredYeaMargin exceeds uint64");

        return CompressedConfiguration({
            votingDelay: _config.votingDelay.compress(),
            votingDuration: _config.votingDuration.compress(),
            executionDelay: _config.executionDelay.compress(),
            gracePeriod: _config.gracePeriod.compress(),
            quorum: _config.quorum.toUint64(),
            requiredYeaMargin: _config.requiredYeaMargin.toUint64(),
            minimumVotes: _config.minimumVotes.toUint96(),
            lockAmount: _config.proposeConfig.lockAmount.toUint96(),
            lockDelay: _config.proposeConfig.lockDelay.compress()
        });
    }

    /**
     * @notice Decompress a CompressedConfiguration into Configuration
     * @param _compressed The compressed configuration
     * @return The uncompressed configuration
     */
    function decompress(CompressedConfiguration memory _compressed) internal pure returns (Configuration memory) {
        return Configuration({
            proposeConfig: ProposeWithLockConfiguration({
                lockDelay: _compressed.lockDelay.decompress(),
                lockAmount: _compressed.lockAmount
            }),
            votingDelay: _compressed.votingDelay.decompress(),
            votingDuration: _compressed.votingDuration.decompress(),
            executionDelay: _compressed.executionDelay.decompress(),
            gracePeriod: _compressed.gracePeriod.decompress(),
            quorum: _compressed.quorum,
            requiredYeaMargin: _compressed.requiredYeaMargin,
            minimumVotes: _compressed.minimumVotes
        });
    }
}

/**
 * @dev a whitelist, controlling who may have power in the governance contract.
 * That is, an address must be an approved beneficiary to receive power via `deposit`.
 *
 * The caveat is that the owner of the contract may open the floodgates, allowing all addresses to hold power.
 * This is currently a "one-way-valve", since if it were reopened after being shut,
 * the contract is in an odd state where entities are holding power, but not allowed to receive more;
 * the whitelist is enabled, but does not reflect the functional entities in the system.
 * As an aside, it is unlikely that in the event Governance were opened up to all addresses,
 * those same addresses would subsequently vote to close it again.
 *
 * In practice, it is expected that the only authorized beneficiary will be the GSE.
 * This is because all rollup instances deposit their stake into the GSE, which in turn deposits it into the governance
 * contract. In turn, it is the GSE that votes on proposals.
 */
struct DepositControl {
    mapping(address beneficiary => bool allowed) isAllowed;
    bool allBeneficiariesAllowed;
}

/**
 * @title Governance
 * @author Aztec Labs
 * @notice A contract that implements governance logic for proposal creation, voting, and execution.
 *         Uses a snapshot-based voting model with partial vote support to enable aggregated voting.
 *
 *         Partial vote support: Allows voters to split their voting power across multiple proposals
 *         or options, rather than using all their votes on a single choice.
 *
 *         Aggregated voting: The contract collects and sums votes from multiple sources or over time,
 *         combining them to determine the final outcome of each proposal.
 *
 * @dev KEY CONCEPTS:
 *
 * **Power**: Funds received via `deposit` are held by Governance and tracked 1:1 as "power" for the beneficiary.
 *
 * **Proposals**: Payloads containing actions to be executed by governance (excluding calls to the governance ASSET).
 *
 * **Deposit Control**: A whitelist system controlling who can hold power in governance.
 * - Initially restricted to approved beneficiaries (expected to be only the GSE)
 * - Can be opened to all addresses via `openFloodgates` (one-way valve)
 * - The GSE aggregates stake from all rollup instances and votes on their behalf
 *
 * **Voting Power**: Based on checkpointed deposit history, calculated per proposal.
 *
 * @dev PROPOSAL LIFECYCLE: (see `getProposalState` for details)
 *
 * The current state of a proposal may be retrieved via `getProposalState`.
 *
 * 1. **Pending** (creation → creation + votingDelay)
 *    - Proposal exists but voting hasn't started
 *    - Power snapshot taken at end of this phase
 *
 * 2. **Active** (pendingThrough + 1 → pendingThrough + votingDuration)
 *    - Voting open using power from snapshot
 *    - Multiple partial votes allowed per user
 *
 * 3. **Vote Evaluation** → Rejected if criteria not met:
 *    - Minimum quorum (% of total power)
 *    - Required yea margin (yea votes minus nay votes)
 *
 * 4. **Queued** (activeThrough + 1 → activeThrough + executionDelay)
 *    - Timelock period before execution
 *
 * 5. **Executable** (queuedThrough + 1 → queuedThrough + gracePeriod)
 *    - Anyone can execute during this window
 *
 * 6. **Other States**:
 *    - Executed: Successfully completed
 *    - Expired: Execution window passed
 *    - Rejected: Failed voting criteria
 *    - Droppable: Proposer changed
 *    - Dropped: Proposal dropped via `dropProposal`
 *
 * @dev USER FLOW:
 *
 * 1. **Deposit**: Transfer ASSET to governance for voting power
 *    - Only whitelisted beneficiaries can hold power
 *    - Power is checkpointed for historical lookups
 *
 * 2. **Vote**: Use power from proposal's snapshot timestamp
 *    - Support partial voting (multiple votes allowed, both yea and nay)
 *    - A user's total votes may not exceed their power snapshot for the proposal
 *
 * 3. **Withdraw**: Two-step process with delay
 *    - Initiate: Reduce power
 *    - Finalize: Transfer funds after delay expires
 *    - Standard delay: votingDelay/5 + votingDuration + executionDelay
 *
 * @dev PROPOSAL CREATION:
 *
 * - **Standard**: `governanceProposer` calls `propose`
 * - **Emergency**: Anyone with sufficient power calls `proposeWithLock`
 *   - Requires withdrawing `lockAmount` of power with a finalization delay of `lockDelay`
 *   - Proposal proposer becomes governance itself (cannot be dropped)
 *
 * @dev CONFIGURATION:
 * All timing parameters are controlled by the governance configuration:
 * - votingDelay: Buffer before voting opens
 * - votingDuration: Voting period length
 * - executionDelay: Timelock after voting before the proposal may be executed
 * - gracePeriod: Execution window
 * - minimumVotes: Absolute minimum voting power in system
 * - quorum: Minimum acceptable participation as a percentage of total power
 * - requiredYeaMargin: Required difference between yea and nay votes as a percentage of the votes cast
 * - lockAmount: The amount of power to withdraw when `proposeWithLock` is called
 * - lockDelay: The delay before a withdrawal created by `proposeWithLock` is finalized
 */
contract Governance is IGovernance {
    using SafeERC20 for IERC20;
    using ProposalLib for CompressedProposal;
    using CheckpointedUintLib for Checkpoints.Trace224;
    using ConfigurationLib for Configuration;
    using ConfigurationLib for CompressedConfiguration;
    using CompressedConfigurationLib for CompressedConfiguration;
    using CompressedProposalLib for CompressedProposal;
    using BallotLib for CompressedBallot;

    IERC20 public immutable ASSET;

    /**
     * @dev The address that is allowed to `propose` new proposals.
     *
     * This address can only be updated by the governance itself through a proposal.
     */
    address public governanceProposer;

    /**
     * @dev The whitelist of beneficiaries that are allowed to hold power via `deposit`,
     * and the flag to allow all beneficiaries to hold power.
     */
    DepositControl internal depositControl;

    /**
     * @dev The proposals that have been made.
     *
     * The proposal ID is the current count of proposals (see `proposalCount`).
     * New proposals are created by calling `_propose`, via `propose` or `proposeWithLock`.
     * The storage of a proposal may be modified by calling `vote`, `execute`, or `dropProposal`.
     */
    mapping(uint256 proposalId => CompressedProposal proposal) internal proposals;

    /**
     * @dev The ballots that have been cast for each proposal.
     *
     * `CompressedBallot`s contain a compressed `yea` and `nay` count (uint128 each packed into uint256),
     * which are the number of votes for and against the proposal.
     * `ballots` is only updated during `vote`.
     */
    mapping(uint256 proposalId => mapping(address user => CompressedBallot ballot)) internal ballots;

    /**
     * @dev Checkpointed deposit amounts for an address.
     *
     * `users` is only updated during `deposit`, `initiateWithdraw`, and `proposeWithLock`.
     */
    mapping(address userAddress => Checkpoints.Trace224 user) internal users;

    /**
     * @dev Withdrawals that have been initiated.
     *
     * `withdrawals` is only updated during `initiateWithdraw`, `proposeWithLock`, and `finalizeWithdraw`.
     */
    mapping(uint256 withdrawalId => Withdrawal withdrawal) internal withdrawals;

    /**
     * @dev The configuration of the governance contract.
     *
     * `configuration` is set in the constructor, and is only updated during `updateConfiguration`,
     * which must be done via a proposal.
     */
    CompressedConfiguration internal configuration;

    /**
     * @dev The total power of the governance contract.
     *
     * `total` is only updated during `deposit`, `initiateWithdraw`, and `proposeWithLock`.
     */
    Checkpoints.Trace224 internal total;

    /**
     * @dev The count of proposals that have been made.
     *
     * `proposalCount` is only updated during `_propose`.
     */
    uint256 public proposalCount;

    /**
     * @dev The count of withdrawals that have been initiated.
     *
     * `withdrawalCount` is only updated during `initiateWithdraw` and `proposeWithLock`.
     */
    uint256 public withdrawalCount;

    /**
     * @dev Modifier to ensure that the caller is the governance contract itself.
     *
     * The caller will only be the governance itself if executed via a proposal.
     */
    modifier onlySelf() {
        require(msg.sender == address(this), Errors.Governance__CallerNotSelf(msg.sender, address(this)));
        _;
    }

    /**
     * @dev Modifier to ensure that the beneficiary is allowed to hold power in Governance.
     */
    modifier isDepositAllowed(address _beneficiary) {
        require(msg.sender != address(this), Errors.Governance__CallerCannotBeSelf());
        require(
            depositControl.allBeneficiariesAllowed || depositControl.isAllowed[_beneficiary],
            Errors.Governance__DepositNotAllowed()
        );

        _;
    }

    /**
     * @dev the initial _beneficiary is expected to be the GSE or address(0) for anyone
     */
    constructor(IERC20 _asset, address _governanceProposer, address _beneficiary, Configuration memory _configuration) {
        ASSET = _asset;
        governanceProposer = _governanceProposer;

        _configuration.assertValid();
        configuration = CompressedConfigurationLib.compress(_configuration);

        if (_beneficiary == address(0)) {
            depositControl.allBeneficiariesAllowed = true;
            emit FloodGatesOpened();
        } else {
            depositControl.allBeneficiariesAllowed = false;
            depositControl.isAllowed[_beneficiary] = true;
            emit BeneficiaryAdded(_beneficiary);
        }
    }

    /**
     * @notice Add a beneficiary to the whitelist.
     * @dev The beneficiary may hold power in the governance contract after this call.
     * only callable by the governance contract itself.
     *
     * @param _beneficiary The address to add to the whitelist.
     */
    function addBeneficiary(address _beneficiary) external override(IGovernance) onlySelf {
        depositControl.isAllowed[_beneficiary] = true;
        emit BeneficiaryAdded(_beneficiary);
    }

    /**
     * @notice Allow all addresses to hold power in the governance contract.
     * @dev This is a one-way valve.
     * only callable by the governance contract itself.
     */
    function openFloodgates() external override(IGovernance) onlySelf {
        depositControl.allBeneficiariesAllowed = true;
        emit FloodGatesOpened();
    }

    /**
     * @notice Update the governance proposer.
     * @dev The governance proposer is the address that is allowed to use `propose`.
     *
     * @dev only callable by the governance contract itself.
     *
     * @dev causes all proposals proposed by the previous governance proposer to be `Droppable`.
     *
     * @dev prevents the governance proposer from being set to the governance contract itself.
     *
     * @param _governanceProposer The new governance proposer.
     */
    function updateGovernanceProposer(address _governanceProposer) external override(IGovernance) onlySelf {
        require(_governanceProposer != address(this), Errors.Governance__GovernanceProposerCannotBeSelf());
        governanceProposer = _governanceProposer;
        emit GovernanceProposerUpdated(_governanceProposer);
    }

    /**
     * @notice Update the governance configuration.
     * only callable by the governance contract itself.
     *
     * @dev all existing proposals will use the configuration they were created with.
     */
    function updateConfiguration(Configuration memory _configuration) external override(IGovernance) onlySelf {
        // This following MUST revert if the configuration is invalid
        _configuration.assertValid();

        configuration = CompressedConfigurationLib.compress(_configuration);

        emit ConfigurationUpdated(Timestamp.wrap(block.timestamp));
    }

    /**
     * @notice Deposit funds into the governance contract, transferring ASSET from msg.sender to the governance contract,
     * increasing the power 1:1 of the beneficiary within the governance contract.
     *
     * @dev The beneficiary must be allowed to hold power in the governance contract,
     * according to `depositControl`.
     *
     * Increments the checkpointed power of the specified beneficiary, and the total power of the governance contract.
     *
     * Note that anyone may deposit funds into the governance contract, and the only restriction is that
     * the beneficiary must be allowed to hold power in the governance contract, according to `depositControl`.
     *
     * It is worth pointing out that someone could attempt to spam the deposit function, and increase the cost to vote
     * as a result of creating many checkpoints. In reality though, as the checkpoints are using time as a key it would
     * take ~36 years of continuous spamming to increase the cost to vote by ~66K gas with 12 second block times.
     *
     * @param _beneficiary The beneficiary to increase the power of.
     * @param _amount The amount of funds to deposit, which is converted to power 1:1.
     */
    function deposit(address _beneficiary, uint256 _amount)
        external
        override(IGovernance)
        isDepositAllowed(_beneficiary)
    {
        ASSET.safeTransferFrom(msg.sender, address(this), _amount);
        users[_beneficiary].add(_amount);
        total.add(_amount);

        emit Deposit(msg.sender, _beneficiary, _amount);
    }

    /**
     * @notice Initiate a withdrawal of funds from the governance contract,
     * decreasing the power of the beneficiary within the governance contract.
     *
     * @dev the withdraw may be finalized by anyone after configuration.getWithdrawalDelay() has passed.
     *
     * @param _to The address that will receive the funds when the withdrawal is finalized.
     * @param _amount The amount of power to reduce, and thus funds to withdraw.
     * @return The id of the withdrawal, passed to `finalizeWithdraw`.
     */
    function initiateWithdraw(address _to, uint256 _amount) external override(IGovernance) returns (uint256) {
        return _initiateWithdraw(msg.sender, _to, _amount, configuration.getWithdrawalDelay());
    }

    /**
     * @notice Finalize a withdrawal of funds from the governance contract,
     * transferring ASSET from the governance contract to the recipient specified in the withdrawal.
     *
     * @dev The withdrawal must not have been claimed, and the delay specified on the withdrawal must have passed.
     *
     * @param _withdrawalId The id of the withdrawal to finalize.
     */
    function finalizeWithdraw(uint256 _withdrawalId) external override(IGovernance) {
        Withdrawal storage withdrawal = withdrawals[_withdrawalId];
        // This is a sanity check, the `recipient` will only be zero for a non-existent withdrawal, so this avoids
        // `finalize`ing non-existent withdrawals. Note, that `_initiateWithdraw` will fail if `_to` is `address(0)`
        require(withdrawal.recipient != address(0), Errors.Governance__WithdrawalNotInitiated());
        require(!withdrawal.claimed, Errors.Governance__WithdrawalAlreadyClaimed());
        require(
            Timestamp.wrap(block.timestamp) >= withdrawal.unlocksAt,
            Errors.Governance__WithdrawalNotUnlockedYet(Timestamp.wrap(block.timestamp), withdrawal.unlocksAt)
        );
        withdrawal.claimed = true;

        emit WithdrawFinalized(_withdrawalId);

        ASSET.safeTransfer(withdrawal.recipient, withdrawal.amount);
    }

    /**
     * @notice Propose a new proposal as the governanceProposer
     *
     * @dev the state of the proposal may be retrieved via `getProposalState`.
     *
     * Note that the `proposer` of the proposal is the *current* governanceProposer; if the governanceProposer
     * no longer matches the one stored in the proposal, the state of the proposal will be `Droppable`.
     *
     * @param _proposal The IPayload address, which is a contract that contains the proposed actions to be executed by the
     * governance.
     * @return The id of the proposal.
     */
    function propose(IPayload _proposal) external override(IGovernance) returns (uint256) {
        require(
            msg.sender == governanceProposer,
            Errors.Governance__CallerNotGovernanceProposer(msg.sender, governanceProposer)
        );
        return _propose(_proposal, governanceProposer);
    }

    /**
     * @notice Propose a new proposal by withdrawing an existing amount of power from Governance with a longer delay.
     *
     * @dev proposals made in this way are identical to those made by the governanceProposer, with the exception
     * that the "proposer" stored in the proposal is the address of the governance contract itself,
     * which means it will not transition to a "Droppable" state if the governanceProposer changes.
     *
     * @dev this is intended to only be used in an emergency, where the governanceProposer is compromised.
     *
     * @dev We don't actually need to check available power here, since if the msg.sender does not have
     * sufficient balance, the `_initiateWithdraw` would revert with an underflow.
     *
     * @param _proposal The IPayload address, which is a contract that contains the proposed actions to be executed by
     * the governance.
     * @param _to The address that will receive the withdrawn funds when the withdrawal is finalized (see
     * `finalizeWithdraw`)
     * @return The id of the proposal
     */
    function proposeWithLock(IPayload _proposal, address _to) external override(IGovernance) returns (uint256) {
        ProposeWithLockConfiguration memory proposeConfig = configuration.getProposeConfig();
        _initiateWithdraw(msg.sender, _to, proposeConfig.lockAmount, proposeConfig.lockDelay);
        return _propose(_proposal, address(this));
    }

    /**
     * @notice Vote on a proposal.
     * @dev The proposal must be `Active` to vote on it.
     *
     * NOTE: The amount of power to vote is equal to the power of msg.sender at the time
     * just before the proposal became active.
     *
     * The same caller (e.g. the GSE) may `vote` multiple times, voting different ways,
     * so long as their total votes are less than or equal to their available power;
     * each vote is tracked per proposal, per caller within the `ballots` mapping.
     *
     * We keep track of the total yea and nay votes as a `summedBallot` on the proposal in storage.
     *
     * @param _proposalId The id of the proposal to vote on.
     * @param _amount The amount of power to vote with, which must be less than the available power.
     * @param _support The support of the vote.
     */
    function vote(uint256 _proposalId, uint256 _amount, bool _support) external override(IGovernance) {
        ProposalState state = getProposalState(_proposalId);
        require(state == ProposalState.Active, Errors.Governance__ProposalNotActive());

        // Compute the power at the time the proposals goes from pending to active.
        // This is the last second before active, and NOT the first second active, because it would then be possible to
        // alter the power while the proposal is active since all txs in a block have the same timestamp.
        uint256 userPower = users[msg.sender].valueAt(proposals[_proposalId].pendingThrough());

        CompressedBallot userBallot = ballots[_proposalId][msg.sender];

        uint256 availablePower = userPower - (userBallot.getNay() + userBallot.getYea());
        require(_amount <= availablePower, Errors.Governance__InsufficientPower(msg.sender, availablePower, _amount));

        CompressedProposal storage proposal = proposals[_proposalId];
        if (_support) {
            ballots[_proposalId][msg.sender] = userBallot.addYea(_amount);
            proposal.addYea(_amount);
        } else {
            ballots[_proposalId][msg.sender] = userBallot.addNay(_amount);
            proposal.addNay(_amount);
        }

        emit VoteCast(_proposalId, msg.sender, _support, _amount);
    }

    /**
     * @notice Execute a proposal.
     * @dev The proposal must be `Executable` to execute it.
     * If it is, we mark the proposal as `Executed` and execute the actions,
     * simply looping through and calling them.
     *
     * As far as the individual calls, there are 2 safety measures:
     *  - The call cannot target the ASSET which underlies the governance contract
     *  - The call must succeed
     *
     * @param _proposalId The id of the proposal to execute.
     */
    function execute(uint256 _proposalId) external override(IGovernance) {
        ProposalState state = getProposalState(_proposalId);
        require(state == ProposalState.Executable, Errors.Governance__ProposalNotExecutable());

        CompressedProposal storage proposal = proposals[_proposalId];
        proposal.cachedState = ProposalState.Executed;

        IPayload.Action[] memory actions = proposal.payload.getActions();

        for (uint256 i = 0; i < actions.length; i++) {
            require(actions[i].target != address(ASSET), Errors.Governance__CannotCallAsset());
            // We allow calls to EOAs. If you really want be my guest.
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = actions[i].target.call(actions[i].data);
            require(success, Errors.Governance__CallFailed(actions[i].target));
        }

        emit ProposalExecuted(_proposalId);
    }

    /**
     * @notice Update a proposal to be `Dropped`.
     * @dev The proposal must be `Droppable` to mark it permanently as `Dropped`.
     * See `getProposalState` for more details.
     *
     * @param _proposalId The id of the proposal to mark as `Dropped`.
     */
    function dropProposal(uint256 _proposalId) external override(IGovernance) {
        CompressedProposal storage self = proposals[_proposalId];
        require(self.cachedState != ProposalState.Dropped, Errors.Governance__ProposalAlreadyDropped());
        require(getProposalState(_proposalId) == ProposalState.Droppable, Errors.Governance__ProposalCannotBeDropped());

        self.cachedState = ProposalState.Dropped;

        emit ProposalDropped(_proposalId);
    }

    /**
     * @notice Get the power of an address at a given timestamp.
     *
     * @param _owner The address to get the power of.
     * @param _ts The timestamp to get the power at.
     * @return The power of the address at the given timestamp.
     */
    function powerAt(address _owner, Timestamp _ts) external view override(IGovernance) returns (uint256) {
        return users[_owner].valueAt(_ts);
    }

    /**
     * @notice Get the power of an address at the current block timestamp.
     *
     * Note that `powerNow` with the current block timestamp is NOT STABLE.
     *
     *  For example, imagine a transaction that performs the following:
     *  1. deposit
     *  2. powerNow
     *  3. deposit
     *  4. powerNow
     *
     *  The powerNow at 4 will be different from the powerNow at 2.
     *
     * @param _owner The address to get the power of.
     * @return The power of the address at the current block timestamp.
     */
    function powerNow(address _owner) external view override(IGovernance) returns (uint256) {
        return users[_owner].valueNow();
    }

    /**
     * @notice Get the total power in Governance at a given timestamp.
     *
     * @param _ts The timestamp to get the power at.
     * @return The total power at the given timestamp.
     */
    function totalPowerAt(Timestamp _ts) external view override(IGovernance) returns (uint256) {
        return total.valueAt(_ts);
    }

    /**
     * @notice Get the total power in Governance at the current block timestamp.
     * Note that `powerNow` with the current block timestamp is NOT STABLE.
     *
     * @return The total power at the current block timestamp.
     */
    function totalPowerNow() external view override(IGovernance) returns (uint256) {
        return total.valueNow();
    }

    /**
     * @notice Check if an address is permitted to hold power in Governance.
     *
     * @param _beneficiary The address to check.
     * @return True if the address is permitted to hold power in Governance.
     */
    function isPermittedInGovernance(address _beneficiary) external view override(IGovernance) returns (bool) {
        return depositControl.isAllowed[_beneficiary];
    }

    /**
     * @notice Check if everyone is permitted to hold power in Governance.
     *
     * @return True if everyone is permitted to hold power in Governance.
     */
    function isAllBeneficiariesAllowed() external view override(IGovernance) returns (bool) {
        return depositControl.allBeneficiariesAllowed;
    }

    function getConfiguration() external view override(IGovernance) returns (Configuration memory) {
        return configuration.decompress();
    }

    /**
     * @notice Get a proposal by its id.
     *
     * @dev   Will return default values (0) for non-existing proposals
     *
     * @param _proposalId The id of the proposal to get.
     * @return The proposal.
     */
    function getProposal(uint256 _proposalId) external view override(IGovernance) returns (Proposal memory) {
        return proposals[_proposalId].decompress();
    }

    /**
     * @notice Get a withdrawal by its id.
     *
     * @dev   Will return default values (0) for non-existing withdrawals
     *
     * @param _withdrawalId The id of the withdrawal to get.
     * @return The withdrawal.
     */
    function getWithdrawal(uint256 _withdrawalId) external view override(IGovernance) returns (Withdrawal memory) {
        return withdrawals[_withdrawalId];
    }

    /**
     * @notice Get a user's ballot for a specific proposal.
     *
     * @dev Returns the uncompressed Ballot struct for external callers.
     *
     * @param _proposalId The id of the proposal.
     * @param _user The address of the user.
     * @return The user's ballot with yea and nay votes.
     */
    function getBallot(uint256 _proposalId, address _user)
        external
        view
        override(IGovernance)
        returns (Ballot memory)
    {
        return ballots[_proposalId][_user].decompress();
    }

    /**
     * @notice Get the state of a proposal in the governance system
     *
     * @dev Determine the current state of a proposal based on timestamps, vote results, and governance configuration.
     *
     * @dev NB: the state returned here is LOGICAL, and is the "true state" of the proposal:
     * it need not match the state of the proposal in storage, which is effectively just a cache.
     *
     *  Flow Logic:
     *  1. Check if proposal exists (revert if not)
     *  2. If the cached state of the proposal is "stable" (Executed/Dropped), return that state
     *  3. Check if governance proposer changed (→ Droppable, unless proposed via lock)
     *  4. Time-based state transitions:
     *   - currentTime ≤ pendingThrough() → Pending
     *   - currentTime ≤ activeThrough() → Active
     *   - Vote tabulation check → Rejected if not accepted
     *   - currentTime ≤ queuedThrough() → Queued
     *   - currentTime ≤ executableThrough() → Executable
     *   - Otherwise → Expired
     *
     * @dev State Descriptions:
     *      - Pending: Proposal created but voting hasn't started yet
     *      - Active: Voting is currently open
     *      - Rejected: Voting closed but proposal didn't meet acceptance criteria
     *      - Queued: Proposal accepted and waiting for execution window
     *      - Executable: Proposal can be executed
     *      - Expired: Execution window has passed
     *      - Droppable: Proposer changed
     *      - Dropped: Proposal dropped by calling `dropProposal`
     *      - Executed: Proposal has been successfully executed
     *
     * @dev edge case: it is possible that a proposal be "Droppable" according to the logic here,
     * but no one called `dropProposal`, and then be in a different state later.
     * This can happen if, for whatever reason, the governance proposer stored by this contract changes
     * from the one the proposal is made via, (which would cause this function to return `Droppable`),
     * but then a separate proposal is executed which restores the original governance proposer.
     * So, `Dropped` is permanent, but `Droppable` is not.
     *
     * @param _proposalId The ID of the proposal to check
     * @return The current state of the proposal
     */
    function getProposalState(uint256 _proposalId) public view override(IGovernance) returns (ProposalState) {
        require(_proposalId < proposalCount, Errors.Governance__ProposalDoesNotExists(_proposalId));

        CompressedProposal storage self = proposals[_proposalId];

        // A proposal's state is "stable" after `execute` or `dropProposal` has been called on it.
        // In this case, the state of the proposal as returned by `getProposalState` is the same as the cached state,
        // and the state will not change.
        if (self.cachedState == ProposalState.Executed || self.cachedState == ProposalState.Dropped) {
            return self.cachedState;
        }

        // If the governanceProposer has changed, and the proposal did not come through `proposeWithLock`,
        // the state of the proposal is `Droppable`.
        if (governanceProposer != self.proposer && address(this) != self.proposer) {
            return ProposalState.Droppable;
        }

        Timestamp currentTime = Timestamp.wrap(block.timestamp);

        if (currentTime <= self.pendingThrough()) {
            return ProposalState.Pending;
        }

        if (currentTime <= self.activeThrough()) {
            return ProposalState.Active;
        }

        uint256 totalPower = total.valueAt(self.pendingThrough());
        (VoteTabulationReturn vtr,) = self.voteTabulation(totalPower);
        if (vtr != VoteTabulationReturn.Accepted) {
            return ProposalState.Rejected;
        }

        if (currentTime <= self.queuedThrough()) {
            return ProposalState.Queued;
        }

        if (currentTime <= self.executableThrough()) {
            return ProposalState.Executable;
        }

        return ProposalState.Expired;
    }

    /**
     * @dev reduce the user's power, the total power, and insert a new withdrawal.
     *
     *  The reason for a configurable delay is that `proposeWithLock` creates a withdrawal,
     *  which has a (presumably) very long delay, whereas `initiateWithdraw` has a much shorter delay.
     *
     * @param _from The address to reduce the power of.
     * @param _to The address to send the funds to.
     * @param _amount The amount of power to reduce, and thus funds to withdraw.
     * @param _delay The delay before the funds can be withdrawn.
     * @return The id of the withdrawal.
     */
    function _initiateWithdraw(address _from, address _to, uint256 _amount, Timestamp _delay)
        internal
        returns (uint256)
    {
        require(_to != address(0), Errors.Governance__CannotWithdrawToAddressZero());
        users[_from].sub(_amount);
        total.sub(_amount);

        uint256 withdrawalId = withdrawalCount++;

        withdrawals[withdrawalId] = Withdrawal({
            amount: _amount,
            unlocksAt: Timestamp.wrap(block.timestamp) + _delay,
            recipient: _to,
            claimed: false
        });

        emit WithdrawInitiated(withdrawalId, _to, _amount);

        return withdrawalId;
    }

    /**
     * @dev create a new proposal. In it we store:
     *
     *  - a copy of the current governance configuration, effectively "freezing" the config for the proposal.
     *      This is done to ensure that in progress proposals that alter the delays etc won't take effect on existing
     *      proposals.
     *  - the summed ballots
     *  - the proposer, which can be:
     *    - the current governanceProposer (which can be updated on the Governance contract), if created via `propose`
     *    - the governance contract itself, if created via `proposeWithLock`
     *
     * @param _proposal The proposal to propose.
     * @param _proposer The address that is proposing the proposal.
     * @return The id of the proposal, which is one less than the current count of proposals.
     */
    function _propose(IPayload _proposal, address _proposer) internal returns (uint256) {
        uint256 proposalId = proposalCount++;

        proposals[proposalId] =
            CompressedProposalLib.create(_proposer, _proposal, Timestamp.wrap(block.timestamp), configuration);

        emit Proposed(proposalId, address(_proposal));

        return proposalId;
    }
}
