// SPDX-License-Identifier: Unknown
pragma solidity 0.8.30;

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

interface IHaveVersion {
    function getVersion() external view returns (uint256);
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
 * @title RewardDistributor
 * @notice Holds ASSET and makes it claimable by the canonical rollup, with optional per-address earmarking.
 *
 * Any address may be specifically funded via `subsidizeAddress`. ASSETs transferred to this contract
 * directly (not via `subsidizeAddress`) form an implicit pool that is claimable only by the
 * presently canonical rollup, in addition to whatever has been earmarked to it.
 *
 * Rollups are not privileged at the bookkeeping layer: the only place the concept of "rollup"
 * enters is that the canonical rollup is the sole address with access to the implicit pool.
 * Earmarked balances are tracked per arbitrary address.
 *
 * Governance may recover all funds, earmarked or otherwise.
 *
 * NOTE: This is intended to be used with the $AZTEC token (0xa27ec0006e59f245217ff08cd52a7e8b169e62d2)
 * or at least a standard, ERC-20 token that does not have any fee-on-transfer or rebasing.
 */
contract RewardDistributor is IRewardDistributor {
    using SafeERC20 for IERC20;

    /// @notice The ERC-20 token distributed by this contract.
    IERC20 public immutable ASSET;
    /// @notice The registry consulted to resolve the canonical rollup and the governance owner.
    IRegistry public immutable REGISTRY;

    /// @notice Earmarked ASSET balance per recipient.
    /// @dev ASSET sent directly to this contract (not via `subsidizeAddress`) is *not* recorded
    ///      here; it forms the implicit pool available to the canonical rollup.
    mapping(address recipient => uint256 amount) public specificRecipientBalance;

    /// @notice The sum of `specificRecipientBalance` across all recipients.
    uint256 public totalEarmarkedBalance;

    /**
     * @notice Bind this distributor to a specific ASSET and registry.
     * @param _asset    The ERC-20 token this contract will hold and distribute.
     * @param _registry The registry used to look up the canonical rollup and governance owner.
     */
    constructor(IERC20 _asset, IRegistry _registry) {
        ASSET = _asset;
        REGISTRY = _registry;
    }

    /**
     * @notice Transfer funds from msg.sender and earmark them for `_recipient`.
     * @dev No validation is made that `_recipient` is a rollup or registered with the registry.
     *      This allows rollups that have not been registered yet to receive funds, or even a
     *      contract that is not a rollup at all to be funded through this contract. Rollups are
     *      not privileged here; the only place "rollup" matters is that the canonical rollup
     *      additionally has access to the implicit (un-earmarked) pool via `claim`.
     * @param _recipient The address to earmark claimable funds to. Must be non-zero.
     * @param _amount    The amount of ASSET to pull from msg.sender.
     */
    function subsidizeAddress(address _recipient, uint256 _amount) external override(IRewardDistributor) {
        require(_recipient != address(0), Errors.RewardDistributor__ZeroRollup());
        specificRecipientBalance[_recipient] += _amount;
        totalEarmarkedBalance += _amount;
        ASSET.safeTransferFrom(msg.sender, address(this), _amount);
        emit Subsidized(msg.sender, _recipient, _amount);
    }

    /**
     * @notice Claim funds available to the caller.
     * @dev When the caller is the canonical rollup it can draw from both the implicit pool
     *      (un-earmarked ASSET held by this contract) and any balance earmarked to it. For any
     *      other caller only its earmarked balance is available.
     * @param _to     The address that receives the transferred ASSET.
     * @param _amount The amount of ASSET to transfer.
     */
    function claim(address _to, uint256 _amount) external override(IRewardDistributor) {
        _transfer(msg.sender, _to, _amount);
    }

    /**
     * @notice Governance-only recovery of ASSET held by this contract.
     * @dev Same accounting rules as `claim`: when `_from` is the canonical rollup the implicit
     *      pool is drawn from first, otherwise only `_from`'s earmarked balance is available.
     *      The function selector differs from the pre-existing `recover(address,address,uint256)`
     *      only in parameter naming, so this signature is intentionally renamed to avoid silently
     *      hijacking call sites that targeted the older shape.
     * @param _from   The address whose accounting bucket the funds are drawn from.
     * @param _to     The recipient of the recovered ASSET.
     * @param _amount The amount of ASSET to transfer.
     */
    function recoverFrom(address _from, address _to, uint256 _amount) external override(IRewardDistributor) {
        address owner = Ownable(address(REGISTRY)).owner();
        require(msg.sender == owner, Errors.RewardDistributor__InvalidCaller(msg.sender, owner));
        _transfer(_from, _to, _amount);
    }

    /**
     * @notice Governance-only recovery of tokens other than ASSET that ended up in this contract.
     * @dev Refuses ASSET so the ASSET accounting (implicit pool + earmarked balances) cannot be
     *      bypassed. Use `recoverFrom` for ASSET.
     * @param _asset  The ERC-20 token to transfer; must not equal `ASSET`.
     * @param _to     The recipient of the transferred tokens.
     * @param _amount The amount to transfer.
     */
    function recoverWrongAsset(address _asset, address _to, uint256 _amount) external override(IRewardDistributor) {
        address owner = Ownable(address(REGISTRY)).owner();
        require(msg.sender == owner, Errors.RewardDistributor__InvalidCaller(msg.sender, owner));
        require(_asset != address(ASSET), Errors.RewardDistributor__WrongRecoverMechanism());
        IERC20(_asset).safeTransfer(_to, _amount);
    }

    /**
     * @notice Returns the ASSET amount that `_recipient` can currently `claim`.
     * @dev The canonical rollup sees the implicit pool plus its own earmarked balance; any other
     *      address sees only its earmarked balance.
     * @param _recipient The address to query the available balance for.
     * @return The amount of ASSET `_recipient` can claim right now.
     */
    function availableTo(address _recipient) public view override(IRewardDistributor) returns (uint256) {
        address canonical = canonicalRollup();
        uint256 claimableAsCanonical =
            _recipient == canonical ? ASSET.balanceOf(address(this)) - totalEarmarkedBalance : 0;
        return claimableAsCanonical + specificRecipientBalance[_recipient];
    }

    /**
     * @notice Returns the address currently registered as the canonical rollup in the registry.
     * @return The canonical rollup address; this is the only address with access to the implicit pool.
     */
    function canonicalRollup() public view override(IRewardDistributor) returns (address) {
        return address(REGISTRY.getCanonicalRollup());
    }

    /**
     * @notice Shared accounting path for `claim` and `recoverFrom`.
     * @dev When `_from` is the canonical rollup, the implicit (un-earmarked) pool is consumed
     *      first; any shortfall is drawn from `_from`'s earmarked balance. For non-canonical
     *      `_from`, only its earmarked balance is available.
     * @param _from   The accounting bucket to draw funds from.
     * @param _to     The recipient of the transferred ASSET.
     * @param _amount The amount of ASSET to transfer.
     */
    function _transfer(address _from, address _to, uint256 _amount) internal {
        address canonical = canonicalRollup();
        uint256 claimableAsCanonical = _from == canonical ? ASSET.balanceOf(address(this)) - totalEarmarkedBalance : 0;

        // This is the standard case, so avoid SLOAD if we can
        if (_amount <= claimableAsCanonical) {
            ASSET.safeTransfer(_to, _amount);
            emit Distributed(_from, _to, _amount, _amount, 0);
            return;
        }

        // Canonical balance couldn't cover the requested amount,
        // see if we can get there with funds earmarked for this address.
        uint256 earmarked = specificRecipientBalance[_from];
        uint256 totalAvailable = claimableAsCanonical + earmarked;
        require(totalAvailable >= _amount, Errors.RewardDistributor__InsufficientAvailable(_amount, totalAvailable));

        // Reduce this address's earmarked funds and totalEarmarkedBalance since we know we drew from it.
        // Effectively, we draw from the canonical/implicit pool first.
        uint256 earmarkedFundsUsed = _amount - claimableAsCanonical;
        specificRecipientBalance[_from] -= earmarkedFundsUsed;
        totalEarmarkedBalance -= earmarkedFundsUsed;
        ASSET.safeTransfer(_to, _amount);
        emit Distributed(_from, _to, _amount, claimableAsCanonical, earmarkedFundsUsed);
    }
}
