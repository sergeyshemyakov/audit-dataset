// SPDX-License-Identifier: Unknown
pragma solidity 0.8.24;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

/// @title IScrollChain
/// @notice The interface for ScrollChain.
interface IScrollChain {
    /**********
     * Events *
     **********/

    /// @notice Emitted when a new batch is committed.
    /// @param batchIndex The index of the batch.
    /// @param batchHash The hash of the batch.
    event CommitBatch(uint256 indexed batchIndex, bytes32 indexed batchHash);

    /// @notice revert a pending batch.
    /// @param batchIndex The index of the batch.
    /// @param batchHash The hash of the batch
    event RevertBatch(uint256 indexed batchIndex, bytes32 indexed batchHash);

    /// @notice revert a range of batches.
    /// @param startBatchIndex The start batch index of the range (inclusive).
    /// @param finishBatchIndex The finish batch index of the range (inclusive).
    event RevertBatch(uint256 indexed startBatchIndex, uint256 indexed finishBatchIndex);

    /// @notice Emitted when a batch is finalized.
    /// @param batchIndex The index of the batch.
    /// @param batchHash The hash of the batch
    /// @param stateRoot The state root on layer 2 after this batch.
    /// @param withdrawRoot The merkle root on layer2 after this batch.
    event FinalizeBatch(uint256 indexed batchIndex, bytes32 indexed batchHash, bytes32 stateRoot, bytes32 withdrawRoot);

    /// @notice Emitted when owner updates the status of sequencer.
    /// @param account The address of account updated.
    /// @param status The status of the account updated.
    event UpdateSequencer(address indexed account, bool status);

    /// @notice Emitted when owner updates the status of prover.
    /// @param account The address of account updated.
    /// @param status The status of the account updated.
    event UpdateProver(address indexed account, bool status);

    /// @notice Emitted when we enter or exit enforced batch mode.
    /// @param enabled True if we are entering enforced batch mode, false otherwise.
    /// @param lastCommittedBatchIndex The index of the last committed batch.
    event UpdateEnforcedBatchMode(bool enabled, uint256 lastCommittedBatchIndex);

    /*************************
     * Public View Functions *
     *************************/

    /// @return The latest finalized batch index.
    function lastFinalizedBatchIndex() external view returns (uint256);

    /// @param batchIndex The index of the batch.
    /// @return The batch hash of a committed batch.
    function committedBatches(uint256 batchIndex) external view returns (bytes32);

    /// @param batchIndex The index of the batch.
    /// @return The state root of a committed batch.
    function finalizedStateRoots(uint256 batchIndex) external view returns (bytes32);

    /// @param batchIndex The index of the batch.
    /// @return The message root of a committed batch.
    function withdrawRoots(uint256 batchIndex) external view returns (bytes32);

    /// @param batchIndex The index of the batch.
    /// @return Whether the batch is finalized by batch index.
    function isBatchFinalized(uint256 batchIndex) external view returns (bool);

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @notice Commit one or more batches after the EuclidV2 upgrade.
    /// @param version The version of the committed batches.
    /// @param parentBatchHash The hash of parent batch.
    /// @param lastBatchHash The hash of the last committed batch after this call.
    /// @dev The batch payload is stored in the blobs.
    function commitBatches(
        uint8 version,
        bytes32 parentBatchHash,
        bytes32 lastBatchHash
    ) external;

    /// @notice Revert pending batches.
    /// @dev one can only revert unfinalized batches.
    /// @param batchHeader The header of the last batch we want to keep.
    function revertBatch(bytes calldata batchHeader) external;

    /// @notice Finalize a list of committed batches (i.e. bundle) on layer 1 after the EuclidV2 upgrade.
    /// @param batchHeader The header of the last batch in this bundle.
    /// @param totalL1MessagesPoppedOverall The number of messages processed after this bundle.
    /// @param postStateRoot The state root after this bundle.
    /// @param withdrawRoot The withdraw trie root after this bundle.
    /// @param aggrProof The bundle proof for this bundle.
    /// @dev See `BatchHeaderV7Codec` for the batch header encoding.
    function finalizeBundlePostEuclidV2(
        bytes calldata batchHeader,
        uint256 totalL1MessagesPoppedOverall,
        bytes32 postStateRoot,
        bytes32 withdrawRoot,
        bytes calldata aggrProof
    ) external;

    /// @notice The struct for permissionless batch finalization.
    /// @param batchHeader The header of this batch.
    /// @param totalL1MessagesPoppedOverall The number of messages processed after this bundle.
    /// @param postStateRoot The state root after this batch.
    /// @param withdrawRoot The withdraw trie root after this batch.
    /// @param zkProof The bundle proof for this batch (single-batch bundle).
    /// @dev See `BatchHeaderV7Codec` for the batch header encoding.
    struct FinalizeStruct {
        bytes batchHeader;
        uint256 totalL1MessagesPoppedOverall;
        bytes32 postStateRoot;
        bytes32 withdrawRoot;
        bytes zkProof;
    }

    /// @notice Commit and finalize a batch in permissionless mode.
    /// @param version The version of current batch.
    /// @param parentBatchHash The hash of parent batch.
    /// @param finalizeStruct The data needed to finalize this batch.
    /// @dev The batch payload is stored in the blob.
    function commitAndFinalizeBatch(
        uint8 version,
        bytes32 parentBatchHash,
        FinalizeStruct calldata finalizeStruct
    ) external;
}

// solhint-disable no-inline-assembly

/// @dev Below is the encoding for `BatchHeader` V0, total 89 + ceil(l1MessagePopped / 256) * 32 bytes.
/// ```text
///   * Field                   Bytes       Type        Index   Comments
///   * version                 1           uint8       0       The batch version
///   * batchIndex              8           uint64      1       The index of the batch
///   * l1MessagePopped         8           uint64      9       Number of L1 messages popped in the batch
///   * totalL1MessagePopped    8           uint64      17      Number of total L1 messages popped after the batch
///   * dataHash                32          bytes32     25      The data hash of the batch
///   * parentBatchHash         32          bytes32     57      The parent batch hash
///   * skippedL1MessageBitmap  dynamic     uint256[]   89      A bitmap to indicate which L1 messages are skipped in the batch
/// ```
library BatchHeaderV0Codec {
    /// @dev Thrown when the length of batch header is smaller than 89
    error ErrorBatchHeaderV0LengthTooSmall();

    /// @dev Thrown when the length of skippedL1MessageBitmap is incorrect.
    error ErrorIncorrectBitmapLengthV0();

    /// @dev The length of fixed parts of the batch header.
    uint256 internal constant BATCH_HEADER_FIXED_LENGTH = 89;

    /// @notice Load batch header in calldata to memory.
    /// @param _batchHeader The encoded batch header bytes in calldata.
    /// @return batchPtr The start memory offset of the batch header in memory.
    /// @return length The length in bytes of the batch header.
    function loadAndValidate(bytes calldata _batchHeader) internal pure returns (uint256 batchPtr, uint256 length) {
        length = _batchHeader.length;
        if (length < BATCH_HEADER_FIXED_LENGTH) revert ErrorBatchHeaderV0LengthTooSmall();

        // copy batch header to memory.
        assembly {
            batchPtr := mload(0x40)
            calldatacopy(batchPtr, _batchHeader.offset, length)
            mstore(0x40, add(batchPtr, length))
        }

        // check batch header length
        uint256 _l1MessagePopped = getL1MessagePopped(batchPtr);

        unchecked {
            if (length != BATCH_HEADER_FIXED_LENGTH + ((_l1MessagePopped + 255) / 256) * 32) {
                revert ErrorIncorrectBitmapLengthV0();
            }
        }
    }

    /// @notice Get the version of the batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _version The version of the batch header.
    function getVersion(uint256 batchPtr) internal pure returns (uint256 _version) {
        assembly {
            _version := shr(248, mload(batchPtr))
        }
    }

    /// @notice Get the batch index of the batch.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _batchIndex The batch index of the batch.
    function getBatchIndex(uint256 batchPtr) internal pure returns (uint256 _batchIndex) {
        assembly {
            _batchIndex := shr(192, mload(add(batchPtr, 1)))
        }
    }

    /// @notice Get the number of L1 messages of the batch.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _l1MessagePopped The number of L1 messages of the batch.
    function getL1MessagePopped(uint256 batchPtr) internal pure returns (uint256 _l1MessagePopped) {
        assembly {
            _l1MessagePopped := shr(192, mload(add(batchPtr, 9)))
        }
    }

    /// @notice Get the number of L1 messages popped before this batch.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _totalL1MessagePopped The number of L1 messages popped before this batch.
    function getTotalL1MessagePopped(uint256 batchPtr) internal pure returns (uint256 _totalL1MessagePopped) {
        assembly {
            _totalL1MessagePopped := shr(192, mload(add(batchPtr, 17)))
        }
    }

    /// @notice Get the data hash of the batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _dataHash The data hash of the batch header.
    function getDataHash(uint256 batchPtr) internal pure returns (bytes32 _dataHash) {
        assembly {
            _dataHash := mload(add(batchPtr, 25))
        }
    }

    /// @notice Get the parent batch hash of the batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _parentBatchHash The parent batch hash of the batch header.
    function getParentBatchHash(uint256 batchPtr) internal pure returns (bytes32 _parentBatchHash) {
        assembly {
            _parentBatchHash := mload(add(batchPtr, 57))
        }
    }

    /// @notice Get the start memory offset for skipped L1 messages bitmap.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _bitmapPtr the start memory offset for skipped L1 messages bitmap.
    function getSkippedBitmapPtr(uint256 batchPtr) internal pure returns (uint256 _bitmapPtr) {
        assembly {
            _bitmapPtr := add(batchPtr, BATCH_HEADER_FIXED_LENGTH)
        }
    }

    /// @notice Get the skipped L1 messages bitmap.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param index The index of bitmap to load.
    /// @return _bitmap The bitmap from bits `index * 256` to `index * 256 + 255`.
    function getSkippedBitmap(uint256 batchPtr, uint256 index) internal pure returns (uint256 _bitmap) {
        assembly {
            batchPtr := add(batchPtr, BATCH_HEADER_FIXED_LENGTH)
            _bitmap := mload(add(batchPtr, mul(index, 32)))
        }
    }

    /// @notice Store the version of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _version The version of batch header.
    function storeVersion(uint256 batchPtr, uint256 _version) internal pure {
        assembly {
            mstore8(batchPtr, _version)
        }
    }

    /// @notice Store the batch index of batch header.
    /// @dev Because this function can overwrite the subsequent fields, it must be called before
    /// `storeL1MessagePopped`, `storeTotalL1MessagePopped`, and `storeDataHash`.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _batchIndex The batch index.
    function storeBatchIndex(uint256 batchPtr, uint256 _batchIndex) internal pure {
        assembly {
            mstore(add(batchPtr, 1), shl(192, _batchIndex))
        }
    }

    /// @notice Store the number of L1 messages popped in current batch to batch header.
    /// @dev Because this function can overwrite the subsequent fields, it must be called before
    /// `storeTotalL1MessagePopped` and `storeDataHash`.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _l1MessagePopped The number of L1 messages popped in current batch.
    function storeL1MessagePopped(uint256 batchPtr, uint256 _l1MessagePopped) internal pure {
        assembly {
            mstore(add(batchPtr, 9), shl(192, _l1MessagePopped))
        }
    }

    /// @notice Store the total number of L1 messages popped after current batch to batch header.
    /// @dev Because this function can overwrite the subsequent fields, it must be called before
    /// `storeDataHash`.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _totalL1MessagePopped The total number of L1 messages popped after current batch.
    function storeTotalL1MessagePopped(uint256 batchPtr, uint256 _totalL1MessagePopped) internal pure {
        assembly {
            mstore(add(batchPtr, 17), shl(192, _totalL1MessagePopped))
        }
    }

    /// @notice Store the data hash of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _dataHash The data hash.
    function storeDataHash(uint256 batchPtr, bytes32 _dataHash) internal pure {
        assembly {
            mstore(add(batchPtr, 25), _dataHash)
        }
    }

    /// @notice Store the parent batch hash of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _parentBatchHash The parent batch hash.
    function storeParentBatchHash(uint256 batchPtr, bytes32 _parentBatchHash) internal pure {
        assembly {
            mstore(add(batchPtr, 57), _parentBatchHash)
        }
    }

    /// @notice Store the skipped L1 message bitmap of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _skippedL1MessageBitmap The skipped L1 message bitmap.
    function storeSkippedBitmap(uint256 batchPtr, bytes calldata _skippedL1MessageBitmap) internal pure {
        assembly {
            calldatacopy(
                add(batchPtr, BATCH_HEADER_FIXED_LENGTH),
                _skippedL1MessageBitmap.offset,
                _skippedL1MessageBitmap.length
            )
        }
    }

    /// @notice Compute the batch hash.
    /// @dev Caller should make sure that the encoded batch header is correct.
    ///
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param length The length of the batch.
    /// @return _batchHash The hash of the corresponding batch.
    function computeBatchHash(uint256 batchPtr, uint256 length) internal pure returns (bytes32 _batchHash) {
        // in the current version, the hash is: keccak(BatchHeader without timestamp)
        assembly {
            _batchHash := keccak256(batchPtr, length)
        }
    }
}

/// @custom:deprecated This contract is no longer used in production.
interface IL1MessageQueueV1 {
    /**********
     * Events *
     **********/

    /// @notice Emitted when a new L1 => L2 transaction is appended to the queue.
    /// @param sender The address of account who initiates the transaction.
    /// @param target The address of account who will receive the transaction.
    /// @param value The value passed with the transaction.
    /// @param queueIndex The index of this transaction in the queue.
    /// @param gasLimit Gas limit required to complete the message relay on L2.
    /// @param data The calldata of the transaction.
    event QueueTransaction(
        address indexed sender,
        address indexed target,
        uint256 value,
        uint64 queueIndex,
        uint256 gasLimit,
        bytes data
    );

    /// @notice Emitted when some L1 => L2 transactions are included in L1.
    /// @param startIndex The start index of messages popped.
    /// @param count The number of messages popped.
    /// @param skippedBitmap A bitmap indicates whether a message is skipped.
    event DequeueTransaction(uint256 startIndex, uint256 count, uint256 skippedBitmap);

    /// @notice Emitted when dequeued transactions are reset.
    /// @param startIndex The start index of messages.
    event ResetDequeuedTransaction(uint256 startIndex);

    /// @notice Emitted when some L1 => L2 transactions are finalized in L1.
    /// @param finalizedIndex The last index of messages finalized.
    event FinalizedDequeuedTransaction(uint256 finalizedIndex);

    /// @notice Emitted when a message is dropped from L1.
    /// @param index The index of message dropped.
    event DropTransaction(uint256 index);

    /// @notice Emitted when owner updates gas oracle contract.
    /// @param _oldGasOracle The address of old gas oracle contract.
    /// @param _newGasOracle The address of new gas oracle contract.
    event UpdateGasOracle(address indexed _oldGasOracle, address indexed _newGasOracle);

    /// @notice Emitted when owner updates max gas limit.
    /// @param _oldMaxGasLimit The old max gas limit.
    /// @param _newMaxGasLimit The new max gas limit.
    event UpdateMaxGasLimit(uint256 _oldMaxGasLimit, uint256 _newMaxGasLimit);

    /**********
     * Errors *
     **********/

    /// @dev Thrown when the given address is `address(0)`.
    error ErrorZeroAddress();

    /*************************
     * Public View Functions *
     *************************/

    /// @notice The start index of all pending inclusion messages.
    /// @custom:deprecated Please use `IL1MessageQueueV2.pendingQueueIndex` instead.
    function pendingQueueIndex() external view returns (uint256);

    /// @notice The start index of all unfinalized messages.
    /// @dev All messages from `nextUnfinalizedQueueIndex` to `pendingQueueIndex-1` are committed but not finalized.
    /// @custom:deprecated Please use `IL1MessageQueueV2.nextUnfinalizedQueueIndex` instead.
    function nextUnfinalizedQueueIndex() external view returns (uint256);

    /// @notice Return the index of next appended message.
    /// @dev Also the total number of appended messages.
    /// @custom:deprecated Please use `IL1MessageQueueV2.nextCrossDomainMessageIndex` instead.
    function nextCrossDomainMessageIndex() external view returns (uint256);

    /// @notice Return the message of in `queueIndex`.
    /// @param queueIndex The index to query.
    /// @custom:deprecated Please use `IL1MessageQueueV2.getCrossDomainMessage` instead.
    function getCrossDomainMessage(uint256 queueIndex) external view returns (bytes32);

    /// @notice Return the amount of ETH should pay for cross domain message.
    /// @param gasLimit Gas limit required to complete the message relay on L2.
    /// @custom:deprecated Please use `IL1MessageQueueV2.estimateCrossDomainMessageFee` instead.
    function estimateCrossDomainMessageFee(uint256 gasLimit) external view returns (uint256);

    /// @notice Return the amount of intrinsic gas fee should pay for cross domain message.
    /// @param _calldata The calldata of L1-initiated transaction.
    /// @custom:deprecated Please use `IL1MessageQueueV2.calculateIntrinsicGasFee` instead.
    function calculateIntrinsicGasFee(bytes calldata _calldata) external view returns (uint256);

    /// @notice Return the hash of a L1 message.
    /// @param sender The address of sender.
    /// @param queueIndex The queue index of this message.
    /// @param value The amount of Ether transfer to target.
    /// @param target The address of target.
    /// @param gasLimit The gas limit provided.
    /// @param data The calldata passed to target address.
    /// @custom:deprecated Please use `IL1MessageQueueV2.computeTransactionHash` instead.
    function computeTransactionHash(
        address sender,
        uint256 queueIndex,
        uint256 value,
        address target,
        uint256 gasLimit,
        bytes calldata data
    ) external view returns (bytes32);

    /// @notice Return whether the message is skipped.
    /// @param queueIndex The queue index of the message to check.
    /// @custom:deprecated
    function isMessageSkipped(uint256 queueIndex) external view returns (bool);

    /// @notice Return whether the message is dropped.
    /// @param queueIndex The queue index of the message to check.
    /// @custom:deprecated
    function isMessageDropped(uint256 queueIndex) external view returns (bool);

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @notice Append a L1 to L2 message into this contract.
    /// @param target The address of target contract to call in L2.
    /// @param gasLimit The maximum gas should be used for relay this message in L2.
    /// @param data The calldata passed to target contract.
    /// @custom:deprecated Please use `IL1MessageQueueV2.appendCrossDomainMessage` instead.
    function appendCrossDomainMessage(
        address target,
        uint256 gasLimit,
        bytes calldata data
    ) external;

    /// @notice Append an enforced transaction to this contract.
    /// @dev The address of sender should be an EOA.
    /// @param sender The address of sender who will initiate this transaction in L2.
    /// @param target The address of target contract to call in L2.
    /// @param value The value passed
    /// @param gasLimit The maximum gas should be used for this transaction in L2.
    /// @param data The calldata passed to target contract.
    /// @custom:deprecated Please use `IL1MessageQueueV2.appendEnforcedTransaction` instead.
    function appendEnforcedTransaction(
        address sender,
        address target,
        uint256 value,
        uint256 gasLimit,
        bytes calldata data
    ) external;

    /// @notice Pop messages from queue.
    ///
    /// @dev We can pop at most 256 messages each time. And if the message is not skipped,
    ///      the corresponding entry will be cleared.
    ///
    /// @param startIndex The start index to pop.
    /// @param count The number of messages to pop.
    /// @param skippedBitmap A bitmap indicates whether a message is skipped.
    /// @custom:deprecated
    function popCrossDomainMessage(
        uint256 startIndex,
        uint256 count,
        uint256 skippedBitmap
    ) external;

    /// @notice Reset status of popped messages.
    ///
    /// @dev We can only reset unfinalized popped messages.
    ///
    /// @param startIndex The start index to reset.
    /// @custom:deprecated
    function resetPoppedCrossDomainMessage(uint256 startIndex) external;

    /// @notice Finalize status of popped messages.
    /// @param newFinalizedQueueIndexPlusOne The index of message to finalize plus one.
    /// @custom:deprecated
    function finalizePoppedCrossDomainMessage(uint256 newFinalizedQueueIndexPlusOne) external;

    /// @notice Drop a skipped message from the queue.
    /// @custom:deprecated
    function dropCrossDomainMessage(uint256 index) external;
}

interface IL1MessageQueueV2 {
    /**********
     * Events *
     **********/

    /// @notice Emitted when a new L1 => L2 transaction is appended to the queue.
    /// @param sender The address of the sender account on L2.
    /// @param target The address of the target account on L2.
    /// @param value The ETH value transferred to the target account on L2.
    /// @param queueIndex The index of this transaction in the message queue.
    /// @param gasLimit The gas limit used on L2.
    /// @param data The calldata passed to the target account on L2.
    event QueueTransaction(
        address indexed sender,
        address indexed target,
        uint256 value,
        uint64 queueIndex,
        uint256 gasLimit,
        bytes data
    );

    /// @notice Emitted when some L1 => L2 transactions are finalized on L1.
    /// @param finalizedIndex The index of the last message finalized.
    event FinalizedDequeuedTransaction(uint256 finalizedIndex);

    /*************************
     * Public View Functions *
     *************************/

    /// @notice Return the start index of all messages in this contract.
    function firstCrossDomainMessageIndex() external view returns (uint256);

    /// @notice Return the start index of all unfinalized messages.
    function nextUnfinalizedQueueIndex() external view returns (uint256);

    /// @notice Return the index to be used for the next message.
    /// @dev Also the total number of appended messages, including messages in `L1MessageQueueV1`.
    function nextCrossDomainMessageIndex() external view returns (uint256);

    /// @notice Return the message rolling hash of `queueIndex`.
    /// @param queueIndex The index to query.
    function getMessageRollingHash(uint256 queueIndex) external view returns (bytes32);

    /// @notice Return the message enqueue timestamp of `queueIndex`.
    /// @param queueIndex The index to query.
    function getMessageEnqueueTimestamp(uint256 queueIndex) external view returns (uint256);

    /// @notice Return the first unfinalized message enqueue timestamp.
    function getFirstUnfinalizedMessageEnqueueTime() external view returns (uint256);

    /// @notice Return the amount of ETH that should be paid for a cross-domain message.
    /// @param gasLimit The gas limit required to complete the message relay on L2.
    function estimateCrossDomainMessageFee(uint256 gasLimit) external view returns (uint256);

    /// @notice Return the estimated base fee on L2.
    function estimateL2BaseFee() external view returns (uint256);

    /// @notice Return the intrinsic gas required by the provided cross-domain message.
    /// @param data The calldata of the cross-domain message.
    function calculateIntrinsicGasFee(bytes calldata data) external view returns (uint256);

    /// @notice Compute the transaction hash of an L1 message.
    /// @param sender The address of the sender account.
    /// @param queueIndex The index of this transaction in the message queue.
    /// @param value The ETH value transferred to the target account.
    /// @param target The address of the target account.
    /// @param gasLimit The gas limit provided.
    /// @param data The calldata passed to the target account.
    function computeTransactionHash(
        address sender,
        uint256 queueIndex,
        uint256 value,
        address target,
        uint256 gasLimit,
        bytes calldata data
    ) external view returns (bytes32);

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @notice Append a L1 => L2 cross-domain message to the message queue.
    /// @param target The address of the target account on L2.
    /// @param gasLimit The gas limit used on L2.
    /// @param data The calldata passed to the target account on L2.
    /// @dev This function can only be called by `L1ScrollMessenger`.
    function appendCrossDomainMessage(
        address target,
        uint256 gasLimit,
        bytes calldata data
    ) external;

    /// @notice Append an enforced transaction to the message queue.
    /// @param sender The address of the sender account on L2.
    /// @param target The address of the target account on L2.
    /// @param value The ETH value transferred to the target account on L2.
    /// @param gasLimit The gas limit used on L2.
    /// @param data The calldata passed to the target account on L2.
    /// @dev This function can only be called by `EnforcedTxGateway`.
    function appendEnforcedTransaction(
        address sender,
        address target,
        uint256 value,
        uint256 gasLimit,
        bytes calldata data
    ) external;

    /// @notice Mark cross-domain messages as finalized.
    /// @param nextUnfinalizedQueueIndex The index of the first unfinalized message after this call.
    /// @dev This function can only be called by `ScrollChain`.
    function finalizePoppedCrossDomainMessage(uint256 nextUnfinalizedQueueIndex) external;
}

contract SystemConfig is OwnableUpgradeable {
    /**********
     * Events *
     **********/

    /// @notice Emitted when the message queue parameters are updated.
    /// @param oldParams The old parameters.
    /// @param newParams The new parameters.
    event MessageQueueParametersUpdated(MessageQueueParameters oldParams, MessageQueueParameters newParams);

    /// @notice Emitted when the enforced batch parameters are updated.
    /// @param oldParams The old parameters.
    /// @param newParams The new parameters.
    event EnforcedBatchParametersUpdated(EnforcedBatchParameters oldParams, EnforcedBatchParameters newParams);

    /// @notice Emitted when the signer is updated.
    /// @param oldSigner The old signer.
    /// @param newSigner The new signer.
    event SignerUpdated(address oldSigner, address newSigner);

    /***********
     * Structs *
     ***********/

    /// @notice Parameters for the message queue.
    /// @param maxGasLimit The maximum gas limit allowed for each L1 message.
    /// @param baseFeeOverhead The overhead used to calculate l2 base fee.
    /// @param baseFeeScalar The scalar used to calculate l2 base fee.
    /// @dev The compiler will pack this struct into single `bytes32`.
    struct MessageQueueParameters {
        uint32 maxGasLimit;
        uint112 baseFeeOverhead;
        uint112 baseFeeScalar;
    }

    /// @notice Parameters for the enforced batch mode.
    /// @param maxDelayEnterEnforcedMode If no batch has been finalized for `maxDelayEnterEnforcedMode`,
    ///        batch submission becomes permissionless. Anyone can submit a batch together with a proof.
    /// @param maxDelayMessageQueue If no message is included/finalized for `maxDelayMessageQueue`,
    ///        batch submission becomes permissionless. Anyone can submit a batch together with a proof.
    /// @dev The compiler will pack this struct into single `bytes32`.
    struct EnforcedBatchParameters {
        uint24 maxDelayEnterEnforcedMode;
        uint24 maxDelayMessageQueue;
    }

    /*********************
     * Storage Variables *
     *********************/

    /// @notice The parameters for the message queue.
    MessageQueueParameters public messageQueueParameters;

    /// @notice The parameters for the enforced batch mode.
    EnforcedBatchParameters public enforcedBatchParameters;

    /// @dev The address of the current authorized signer.
    address private currentSigner;

    /***************
     * Constructor *
     ***************/

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _owner,
        address _signer,
        MessageQueueParameters memory _messageQueueParameters,
        EnforcedBatchParameters memory _enforcedBatchParameters
    ) external initializer {
        __Ownable_init();
        transferOwnership(_owner);

        currentSigner = _signer;
        messageQueueParameters = _messageQueueParameters;
        enforcedBatchParameters = _enforcedBatchParameters;
    }

    /*************************
     * Public View Functions *
     *************************/

    /// @notice Return the current authorized signer.
    /// @return The authorized signer address.
    function getSigner() external view returns (address) {
        return currentSigner;
    }

    /************************
     * Restricted Functions *
     ************************/

    /// @notice Update the message queue parameters.
    /// @param _params The new message queue parameters.
    /// @dev Only the owner can call this function.
    function updateMessageQueueParameters(MessageQueueParameters memory _params) external onlyOwner {
        MessageQueueParameters memory oldParams = messageQueueParameters;
        messageQueueParameters = _params;
        emit MessageQueueParametersUpdated(oldParams, _params);
    }

    /// @notice Update the enforced batch parameters.
    /// @param _params The new enforced batch parameters.
    /// @dev Only the owner can call this function.
    function updateEnforcedBatchParameters(EnforcedBatchParameters memory _params) external onlyOwner {
        EnforcedBatchParameters memory oldParams = enforcedBatchParameters;
        enforcedBatchParameters = _params;
        emit EnforcedBatchParametersUpdated(oldParams, _params);
    }

    /// @notice Update the current signer.
    /// @param _newSigner The address of the new authorized signer.
    /// @dev Only the owner can call this function.
    function updateSigner(address _newSigner) external onlyOwner {
        address oldSigner = currentSigner;
        currentSigner = _newSigner;
        emit SignerUpdated(oldSigner, _newSigner);
    }
}

// solhint-disable no-inline-assembly

/// @dev Below is the encoding for `BatchHeader` V7, total 73 bytes.
/// ```text
///   * Field                   Bytes       Type        Index   Comments
///   * version                 1           uint8       0       The batch version
///   * batchIndex              8           uint64      1       The index of the batch
///   * blobVersionedHash       32          bytes32     9       The versioned hash of the blob with this batch’s data
///   * parentBatchHash         32          bytes32     41      The parent batch hash
/// ```
/// The codes for `version`, `batchIndex` and `computeBatchHash` are the same as `BatchHeaderV0Codec`.
/// However, we won't reuse the codes since they are very simple. Reusing the codes will introduce
/// extra code jump in solidity, which increase gas costs.
library BatchHeaderV7Codec {
    /// @dev Thrown when the length of batch header is not equal to 73.
    error ErrorBatchHeaderV7LengthMismatch();

    /// @dev The length of fixed parts of the batch header.
    uint256 internal constant BATCH_HEADER_FIXED_LENGTH = 73;

    /// @notice Allocate memory for batch header.
    function allocate() internal pure returns (uint256 batchPtr) {
        assembly {
            batchPtr := mload(0x40)
            // This is `BatchHeaderV7Codec.BATCH_HEADER_FIXED_LENGTH`, use `73` here to reduce code complexity.
            mstore(0x40, add(batchPtr, 73))
        }
    }

    /// @notice Load batch header in calldata to memory.
    /// @param _batchHeader The encoded batch header bytes in calldata.
    /// @return batchPtr The start memory offset of the batch header in memory.
    /// @return length The length in bytes of the batch header.
    function loadAndValidate(bytes calldata _batchHeader) internal pure returns (uint256 batchPtr, uint256 length) {
        length = _batchHeader.length;
        if (length != BATCH_HEADER_FIXED_LENGTH) {
            revert ErrorBatchHeaderV7LengthMismatch();
        }

        // copy batch header to memory.
        batchPtr = allocate();
        assembly {
            calldatacopy(batchPtr, _batchHeader.offset, length)
        }
    }

    /// @notice Get the blob versioned hash of the batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _blobVersionedHash The blob versioned hash of the batch header.
    function getBlobVersionedHash(uint256 batchPtr) internal pure returns (bytes32 _blobVersionedHash) {
        assembly {
            _blobVersionedHash := mload(add(batchPtr, 9))
        }
    }

    /// @notice Get the parent batch hash of the batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _parentBatchHash The parent batch hash of the batch header.
    function getParentBatchHash(uint256 batchPtr) internal pure returns (bytes32 _parentBatchHash) {
        assembly {
            _parentBatchHash := mload(add(batchPtr, 41))
        }
    }

    /// @notice Store the blob versioned hash of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _blobVersionedHash The versioned hash of the blob with this batch’s data.
    function storeBlobVersionedHash(uint256 batchPtr, bytes32 _blobVersionedHash) internal pure {
        assembly {
            mstore(add(batchPtr, 9), _blobVersionedHash)
        }
    }

    /// @notice Store the parent batch hash of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _parentBatchHash The parent batch hash.
    function storeParentBatchHash(uint256 batchPtr, bytes32 _parentBatchHash) internal pure {
        assembly {
            mstore(add(batchPtr, 41), _parentBatchHash)
        }
    }
}

/// @title IRollupVerifier
/// @notice The interface for rollup verifier.
interface IRollupVerifier {
    /// @notice Verify aggregate zk proof.
    /// @param batchIndex The batch index to verify.
    /// @param aggrProof The aggregated proof.
    /// @param publicInputHash The public input hash.
    function verifyAggregateProof(
        uint256 batchIndex,
        bytes calldata aggrProof,
        bytes32 publicInputHash
    ) external view;

    /// @notice Verify aggregate zk proof.
    /// @param version The version of verifier to use.
    /// @param batchIndex The batch index to verify.
    /// @param aggrProof The aggregated proof.
    /// @param publicInputHash The public input hash.
    function verifyAggregateProof(
        uint256 version,
        uint256 batchIndex,
        bytes calldata aggrProof,
        bytes32 publicInputHash
    ) external view;

    /// @notice Verify bundle zk proof.
    /// @param version The version of verifier to use.
    /// @param batchIndex The batch index used to select verifier.
    /// @param bundleProof The aggregated proof.
    /// @param publicInput The public input.
    function verifyBundleProof(
        uint256 version,
        uint256 batchIndex,
        bytes calldata bundleProof,
        bytes calldata publicInput
    ) external view;
}

// solhint-disable no-inline-assembly

/// @dev Below is the encoding for `BatchHeader` V1, total 121 + ceil(l1MessagePopped / 256) * 32 bytes.
/// ```text
///   * Field                   Bytes       Type        Index   Comments
///   * version                 1           uint8       0       The batch version
///   * batchIndex              8           uint64      1       The index of the batch
///   * l1MessagePopped         8           uint64      9       Number of L1 messages popped in the batch
///   * totalL1MessagePopped    8           uint64      17      Number of total L1 messages popped after the batch
///   * dataHash                32          bytes32     25      The data hash of the batch
///   * blobVersionedHash       32          bytes32     57      The versioned hash of the blob with this batch’s data
///   * parentBatchHash         32          bytes32     89      The parent batch hash
///   * skippedL1MessageBitmap  dynamic     uint256[]   121     A bitmap to indicate which L1 messages are skipped in the batch
/// ```
///
/// The codes for `version`, `batchIndex`, `l1MessagePopped`, `totalL1MessagePopped`, `dataHash` and `computeBatchHash`
/// are the same as `BatchHeaderV0Codec`. However, we won't reuse the codes in this library since they are very simple.
/// Reusing the codes will introduce extra code jump in solidity, which increase gas costs.
library BatchHeaderV1Codec {
    /// @dev Thrown when the length of batch header is smaller than 121.
    error ErrorBatchHeaderV1LengthTooSmall();

    /// @dev Thrown when the length of skippedL1MessageBitmap is incorrect.
    error ErrorIncorrectBitmapLengthV1();

    /// @dev The length of fixed parts of the batch header.
    uint256 internal constant BATCH_HEADER_FIXED_LENGTH = 121;

    /// @notice Load batch header in calldata to memory.
    /// @param _batchHeader The encoded batch header bytes in calldata.
    /// @return batchPtr The start memory offset of the batch header in memory.
    /// @return length The length in bytes of the batch header.
    function loadAndValidate(bytes calldata _batchHeader) internal pure returns (uint256 batchPtr, uint256 length) {
        length = _batchHeader.length;
        if (length < BATCH_HEADER_FIXED_LENGTH) revert ErrorBatchHeaderV1LengthTooSmall();

        // copy batch header to memory.
        assembly {
            batchPtr := mload(0x40)
            calldatacopy(batchPtr, _batchHeader.offset, length)
            mstore(0x40, add(batchPtr, length))
        }

        // check batch header length
        uint256 _l1MessagePopped = BatchHeaderV0Codec.getL1MessagePopped(batchPtr);

        unchecked {
            if (length != BATCH_HEADER_FIXED_LENGTH + ((_l1MessagePopped + 255) / 256) * 32)
                revert ErrorIncorrectBitmapLengthV1();
        }
    }

    /// @notice Get the blob versioned hash of the batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _blobVersionedHash The blob versioned hash of the batch header.
    function getBlobVersionedHash(uint256 batchPtr) internal pure returns (bytes32 _blobVersionedHash) {
        assembly {
            _blobVersionedHash := mload(add(batchPtr, 57))
        }
    }

    /// @notice Get the parent batch hash of the batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _parentBatchHash The parent batch hash of the batch header.
    function getParentBatchHash(uint256 batchPtr) internal pure returns (bytes32 _parentBatchHash) {
        assembly {
            _parentBatchHash := mload(add(batchPtr, 89))
        }
    }

    /// @notice Get the start memory offset for skipped L1 messages bitmap.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @return _bitmapPtr the start memory offset for skipped L1 messages bitmap.
    function getSkippedBitmapPtr(uint256 batchPtr) internal pure returns (uint256 _bitmapPtr) {
        assembly {
            _bitmapPtr := add(batchPtr, BATCH_HEADER_FIXED_LENGTH)
        }
    }

    /// @notice Get the skipped L1 messages bitmap.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param index The index of bitmap to load.
    /// @return _bitmap The bitmap from bits `index * 256` to `index * 256 + 255`.
    function getSkippedBitmap(uint256 batchPtr, uint256 index) internal pure returns (uint256 _bitmap) {
        assembly {
            batchPtr := add(batchPtr, BATCH_HEADER_FIXED_LENGTH)
            _bitmap := mload(add(batchPtr, mul(index, 32)))
        }
    }

    /// @notice Store the parent batch hash of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _blobVersionedHash The versioned hash of the blob with this batch’s data.
    function storeBlobVersionedHash(uint256 batchPtr, bytes32 _blobVersionedHash) internal pure {
        assembly {
            mstore(add(batchPtr, 57), _blobVersionedHash)
        }
    }

    /// @notice Store the parent batch hash of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _parentBatchHash The parent batch hash.
    function storeParentBatchHash(uint256 batchPtr, bytes32 _parentBatchHash) internal pure {
        assembly {
            mstore(add(batchPtr, 89), _parentBatchHash)
        }
    }

    /// @notice Store the skipped L1 message bitmap of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _skippedL1MessageBitmap The skipped L1 message bitmap.
    function storeSkippedBitmap(uint256 batchPtr, bytes calldata _skippedL1MessageBitmap) internal pure {
        assembly {
            calldatacopy(
                add(batchPtr, BATCH_HEADER_FIXED_LENGTH),
                _skippedL1MessageBitmap.offset,
                _skippedL1MessageBitmap.length
            )
        }
    }
}

// solhint-disable no-inline-assembly

/// @dev Below is the encoding for `BatchHeader` V3, total 193 bytes.
/// ```text
///   * Field                   Bytes       Type        Index   Comments
///   * version                 1           uint8       0       The batch version
///   * batchIndex              8           uint64      1       The index of the batch
///   * l1MessagePopped         8           uint64      9       Number of L1 messages popped in the batch
///   * totalL1MessagePopped    8           uint64      17      Number of total L1 messages popped after the batch
///   * dataHash                32          bytes32     25      The data hash of the batch
///   * blobVersionedHash       32          bytes32     57      The versioned hash of the blob with this batch’s data
///   * parentBatchHash         32          bytes32     89      The parent batch hash
///   * lastBlockTimestamp      8           uint64      121     A bitmap to indicate which L1 messages are skipped in the batch
///   * blobDataProof           64          bytes64     129     The blob data proof: z (32), y (32)
/// ```
/// The codes for `version`, `batchIndex`, `l1MessagePopped`, `totalL1MessagePopped`, `dataHash` and `computeBatchHash`
/// are the same as `BatchHeaderV0Codec`. The codes for `blobVersionedHash` and `parentBatchHash` are the same as
/// `BatchHeaderV1Codec`. However, we won't reuse the codes since they are very simple. Reusing the codes will introduce
/// extra code jump in solidity, which increase gas costs.
library BatchHeaderV3Codec {
    /// @dev Thrown when the length of batch header is not equal to 193.
    error ErrorBatchHeaderV3LengthMismatch();

    /// @dev The length of fixed parts of the batch header.
    uint256 internal constant BATCH_HEADER_FIXED_LENGTH = 193;

    /// @notice Allocate memory for batch header.
    function allocate() internal pure returns (uint256 batchPtr) {
        assembly {
            batchPtr := mload(0x40)
            // This is `BatchHeaderV3Codec.BATCH_HEADER_FIXED_LENGTH`, use `193` here to reduce code complexity.
            mstore(0x40, add(batchPtr, 193))
        }
    }

    /// @notice Load batch header in calldata to memory.
    /// @param _batchHeader The encoded batch header bytes in calldata.
    /// @return batchPtr The start memory offset of the batch header in memory.
    /// @return length The length in bytes of the batch header.
    function loadAndValidate(bytes calldata _batchHeader) internal pure returns (uint256 batchPtr, uint256 length) {
        length = _batchHeader.length;
        if (length != BATCH_HEADER_FIXED_LENGTH) {
            revert ErrorBatchHeaderV3LengthMismatch();
        }

        // copy batch header to memory.
        batchPtr = allocate();
        assembly {
            calldatacopy(batchPtr, _batchHeader.offset, length)
        }
    }

    /// @notice Store the last block timestamp of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param _lastBlockTimestamp The timestamp of the last block in this batch.
    function storeLastBlockTimestamp(uint256 batchPtr, uint256 _lastBlockTimestamp) internal pure {
        assembly {
            mstore(add(batchPtr, 121), shl(192, _lastBlockTimestamp))
        }
    }

    /// @notice Store the last block timestamp of batch header.
    /// @param batchPtr The start memory offset of the batch header in memory.
    /// @param blobDataProof The blob data proof: z (32), y (32)
    function storeBlobDataProof(uint256 batchPtr, bytes calldata blobDataProof) internal pure {
        assembly {
            // z and y is in the first 64 bytes of `blobDataProof`
            calldatacopy(add(batchPtr, 129), blobDataProof.offset, 64)
        }
    }
}

// solhint-disable no-inline-assembly
// solhint-disable reason-string

/// @title ScrollChain
/// @notice This contract maintains data for the Scroll rollup.
contract ScrollChain is OwnableUpgradeable, PausableUpgradeable, IScrollChain {
    /**********
     * Errors *
     **********/

    /// @dev Thrown when the given account is not EOA account.
    error ErrorAccountIsNotEOA();

    /// @dev Thrown when finalizing a verified batch.
    error ErrorBatchIsAlreadyVerified();

    /// @dev Thrown when committing empty batch (batch without chunks)
    error ErrorBatchIsEmpty();

    /// @dev Thrown when the caller is not prover.
    error ErrorCallerIsNotProver();

    /// @dev Thrown when the caller is not sequencer.
    error ErrorCallerIsNotSequencer();

    /// @dev Thrown when some fields are not zero in genesis batch.
    error ErrorGenesisBatchHasNonZeroField();

    /// @dev Thrown when importing genesis batch twice.
    error ErrorGenesisBatchImported();

    /// @dev Thrown when data hash in genesis batch is zero.
    error ErrorGenesisDataHashIsZero();

    /// @dev Thrown when the parent batch hash in genesis batch is zero.
    error ErrorGenesisParentBatchHashIsNonZero();

    /// @dev Thrown when the batch hash is incorrect.
    error ErrorIncorrectBatchHash();

    /// @dev Thrown when the batch version is incorrect.
    error ErrorIncorrectBatchVersion();

    /// @dev Thrown when reverting a finalized batch.
    error ErrorRevertFinalizedBatch();

    /// @dev Thrown when the given state root is zero.
    error ErrorStateRootIsZero();

    /// @dev Thrown when the given address is `address(0)`.
    error ErrorZeroAddress();

    /// @dev Thrown when we try to commit or finalize normal batch in enforced batch mode.
    error ErrorInEnforcedBatchMode();

    /// @dev Thrown when we try to commit enforced batch while not in enforced batch mode.
    error ErrorNotInEnforcedBatchMode();

    /// @dev Thrown when finalize v7 batches while some v1 messages still unfinalized.
    error ErrorNotAllV1MessagesAreFinalized();

    /// @dev Thrown when the committed batch hash doesn't match off-chain computed one.
    error InconsistentBatchHash(uint256 batchIndex, bytes32 expected, bytes32 actual);

    /// @dev Thrown when given batch is not committed before.
    error ErrorBatchNotCommitted();

    /// @dev Thrown when the function call is not the top-level call in the transaction.
    /// @dev This is checked so that indexers that need to decode calldata continue to work.
    error ErrorTopLevelCallRequired();

    /*************
     * Constants *
     *************/

    /// @dev offsets in miscData.flags
    uint256 private constant V1_MESSAGES_FINALIZED_OFFSET = 0;
    uint256 private constant ENFORCED_MODE_OFFSET = 1;

    /// @notice The chain id of the corresponding layer 2 chain.
    uint64 public immutable layer2ChainId;

    /// @notice The address of `L1MessageQueueV1`.
    address public immutable messageQueueV1;

    /// @notice The address of `L1MessageQueueV2`.
    address public immutable messageQueueV2;

    /// @notice The address of `MultipleVersionRollupVerifier`.
    address public immutable verifier;

    /// @notice The address of `SystemConfig`.
    address public immutable systemConfig;

    /***********
     * Structs *
     ***********/

    /// @param lastCommittedBatchIndex The index of the last committed batch.
    /// @param lastFinalizedBatchIndex The index of the last finalized batch.
    /// @param lastFinalizeTimestamp The timestamp of the last finalize transaction.
    /// @param flags Various flags for saving gas. It has 8 bits.
    ///        + bit 0 indicates whether all v1 messages are finalized, 1 means finalized and 0 means not.
    ///        + bit 1 indicates whether the enforced batch mode is enabled, 1 means enabled and 0 means disabled.
    /// @dev We use `32` bits for the timestamp, which works until `Feb 07 2106 06:28:15 GMT+0000`.
    struct ScrollChainMiscData {
        uint64 lastCommittedBatchIndex;
        uint64 lastFinalizedBatchIndex;
        uint32 lastFinalizeTimestamp;
        uint8 flags;
        uint88 reserved;
    }

    /*************
     * Variables *
     *************/

    /// @dev The maximum number of transactions allowed in each chunk.
    /// @custom:deprecated This is no longer used.
    uint256 private __maxNumTxInChunk;

    /// @dev The storage slot used as L1MessageQueue contract, which is deprecated now.
    /// @custom:deprecated This is no longer used.
    address private __messageQueue;

    /// @dev The storage slot used as RollupVerifier contract, which is deprecated now.
    /// @custom:deprecated This is no longer used.
    address private __verifier;

    /// @notice Whether an account is a sequencer.
    mapping(address => bool) public isSequencer;

    /// @notice Whether an account is a prover.
    mapping(address => bool) public isProver;

    /// @dev The storage slot used as `lastFinalizedBatchIndex`, which is deprecated now.
    /// @custom:deprecated This is no longer used.
    uint256 private __lastFinalizedBatchIndex;

    /// @inheritdoc IScrollChain
    /// @dev Starting from EuclidV2, this array is sparse: it only contains
    /// the last batch hash per commit transaction, and not intermediate ones.
    mapping(uint256 => bytes32) public override committedBatches;

    /// @inheritdoc IScrollChain
    /// @dev Starting from Darwin, this array is sparse: it only contains
    /// the last state root per finalized bundle, and not intermediate ones.
    mapping(uint256 => bytes32) public override finalizedStateRoots;

    /// @inheritdoc IScrollChain
    /// @dev Starting from Darwin, this array is sparse: it only contains
    /// the last withdraw root per finalized bundle, and not intermediate ones.
    mapping(uint256 => bytes32) public override withdrawRoots;

    /// @notice The index of first Euclid batch.
    uint256 public initialEuclidBatchIndex;

    /// @notice The misc data of ScrollChain.
    ScrollChainMiscData public miscData;

    /**********************
     * Function Modifiers *
     **********************/

    modifier OnlySequencer() {
        // @note In the decentralized mode, it should be only called by a list of validator.
        if (!isSequencer[_msgSender()]) revert ErrorCallerIsNotSequencer();
        _;
    }

    modifier OnlyProver() {
        if (!isProver[_msgSender()]) revert ErrorCallerIsNotProver();
        _;
    }

    modifier whenEnforcedBatchNotEnabled() {
        if (isEnforcedModeEnabled()) revert ErrorInEnforcedBatchMode();
        _;
    }

    modifier OnlyTopLevelCall() {
        // disallow contract accounts and delegated EOAs
        if (msg.sender != tx.origin || msg.sender.code.length != 0) {
            revert ErrorTopLevelCallRequired();
        }
        _;
    }

    /***************
     * Constructor *
     ***************/

    /// @notice Constructor for `ScrollChain` implementation contract.
    ///
    /// @param _chainId The chain id of L2.
    /// @param _messageQueueV1 The address of `L1MessageQueueV1`.
    /// @param _messageQueueV2 The address of `L1MessageQueueV2`.
    /// @param _verifier The address of `MultipleVersionRollupVerifier`.
    /// @param _systemConfig The address of `SystemConfig`.
    constructor(
        uint64 _chainId,
        address _messageQueueV1,
        address _messageQueueV2,
        address _verifier,
        address _systemConfig
    ) {
        if (
            _messageQueueV1 == address(0) ||
            _messageQueueV2 == address(0) ||
            _verifier == address(0) ||
            _systemConfig == address(0)
        ) {
            revert ErrorZeroAddress();
        }

        _disableInitializers();

        layer2ChainId = _chainId;
        messageQueueV1 = _messageQueueV1;
        messageQueueV2 = _messageQueueV2;
        verifier = _verifier;
        systemConfig = _systemConfig;
    }

    /// @notice Initialize the storage of ScrollChain.
    ///
    /// @dev The parameters `_messageQueue` and `_verifier` are no longer used.
    ///
    /// @param _messageQueue The address of `L1MessageQueue` contract.
    /// @param _verifier The address of zkevm verifier contract.
    /// @param _maxNumTxInChunk The maximum number of transactions allowed in each chunk.
    function initialize(
        address _messageQueue,
        address _verifier,
        uint256 _maxNumTxInChunk
    ) external initializer {
        OwnableUpgradeable.__Ownable_init();

        __maxNumTxInChunk = _maxNumTxInChunk;
        __verifier = _verifier;
        __messageQueue = _messageQueue;
    }

    function initializeV2() external reinitializer(2) {
        // binary search on lastCommittedBatchIndex
        uint256 index = __lastFinalizedBatchIndex;
        uint256 step = 1;
        unchecked {
            while (committedBatches[index + step] != bytes32(0)) {
                step <<= 1;
            }
            step >>= 1;
            while (step > 0) {
                if (committedBatches[index + step] != bytes32(0)) {
                    index += step;
                }
                step >>= 1;
            }
        }

        miscData = ScrollChainMiscData({
            lastCommittedBatchIndex: uint64(index),
            lastFinalizedBatchIndex: uint64(__lastFinalizedBatchIndex),
            lastFinalizeTimestamp: uint32(block.timestamp),
            flags: 0,
            reserved: 0
        });
    }

    /*************************
     * Public View Functions *
     *************************/

    /// @inheritdoc IScrollChain
    function isBatchFinalized(uint256 _batchIndex) external view override returns (bool) {
        return _batchIndex <= miscData.lastFinalizedBatchIndex;
    }

    /// @inheritdoc IScrollChain
    function lastFinalizedBatchIndex() external view returns (uint256) {
        return miscData.lastFinalizedBatchIndex;
    }

    /// @notice Return whether we are in enforced batch mode.
    function isEnforcedModeEnabled() public view returns (bool) {
        return _decodeBoolFromFlag(miscData.flags, ENFORCED_MODE_OFFSET);
    }

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @notice Import layer 2 genesis block
    /// @param _batchHeader The header of the genesis batch.
    /// @param _stateRoot The state root of the genesis block.
    function importGenesisBatch(bytes calldata _batchHeader, bytes32 _stateRoot) external {
        // check genesis batch header length
        if (_stateRoot == bytes32(0)) revert ErrorStateRootIsZero();

        // check whether the genesis batch is imported
        if (finalizedStateRoots[0] != bytes32(0)) revert ErrorGenesisBatchImported();

        (uint256 memPtr, bytes32 _batchHash, , ) = _loadBatchHeader(_batchHeader, 0);

        // check all fields except `dataHash` and `lastBlockHash` are zero
        unchecked {
            uint256 sum = BatchHeaderV0Codec.getVersion(memPtr) +
                BatchHeaderV0Codec.getBatchIndex(memPtr) +
                BatchHeaderV0Codec.getL1MessagePopped(memPtr) +
                BatchHeaderV0Codec.getTotalL1MessagePopped(memPtr);
            if (sum != 0) revert ErrorGenesisBatchHasNonZeroField();
        }
        if (BatchHeaderV0Codec.getDataHash(memPtr) == bytes32(0)) revert ErrorGenesisDataHashIsZero();
        if (BatchHeaderV0Codec.getParentBatchHash(memPtr) != bytes32(0)) revert ErrorGenesisParentBatchHashIsNonZero();

        committedBatches[0] = _batchHash;
        finalizedStateRoots[0] = _stateRoot;

        emit CommitBatch(0, _batchHash);
        emit FinalizeBatch(0, _batchHash, _stateRoot, bytes32(0));
    }

    /// @inheritdoc IScrollChain
    function commitBatches(
        uint8 version,
        bytes32 parentBatchHash,
        bytes32 lastBatchHash
    ) external override OnlySequencer whenNotPaused whenEnforcedBatchNotEnabled {
        _commitBatchesFromV7(version, parentBatchHash, lastBatchHash, false);
    }

    /// @inheritdoc IScrollChain
    /// @dev This function cannot revert V6 and V7 batches at the same time, so we will assume all batches are V7.
    /// If we need to revert V6 batches, we can downgrade the contract to the previous version and call this function.
    /// @dev During commit batch we only store the last batch hash into storage. As a result, we cannot revert intermediate batches.
    function revertBatch(bytes calldata batchHeader) external onlyOwner {
        uint256 lastBatchIndex = miscData.lastCommittedBatchIndex;
        (uint256 batchPtr, , uint256 startBatchIndex, ) = _loadBatchHeader(batchHeader, lastBatchIndex);
        // only revert v7 batches
        if (BatchHeaderV0Codec.getVersion(batchPtr) < 7) revert ErrorIncorrectBatchVersion();
        // check finalization
        if (startBatchIndex < miscData.lastFinalizedBatchIndex) revert ErrorRevertFinalizedBatch();

        // actual revert
        for (uint256 i = lastBatchIndex; i > startBatchIndex; --i) {
            bytes32 hash = committedBatches[i];
            if (hash != bytes32(0)) delete committedBatches[i];
        }
        emit RevertBatch(startBatchIndex + 1, lastBatchIndex);

        // update `lastCommittedBatchIndex`
        miscData.lastCommittedBatchIndex = uint64(startBatchIndex);
    }

    /// @inheritdoc IScrollChain
    function finalizeBundlePostEuclidV2(
        bytes calldata batchHeader,
        uint256 totalL1MessagesPoppedOverall,
        bytes32 postStateRoot,
        bytes32 withdrawRoot,
        bytes calldata aggrProof
    ) external override OnlyProver whenNotPaused whenEnforcedBatchNotEnabled {
        uint256 flags = miscData.flags;
        bool isV1MessageFinalized = _decodeBoolFromFlag(flags, V1_MESSAGES_FINALIZED_OFFSET);
        if (!isV1MessageFinalized) {
            if (
                IL1MessageQueueV1(messageQueueV1).nextUnfinalizedQueueIndex() !=
                IL1MessageQueueV2(messageQueueV2).firstCrossDomainMessageIndex()
            ) {
                revert ErrorNotAllV1MessagesAreFinalized();
            }
            miscData.flags = uint8(_insertBoolToFlag(flags, V1_MESSAGES_FINALIZED_OFFSET, true));
        }

        _finalizeBundlePostEuclidV2(batchHeader, totalL1MessagesPoppedOverall, postStateRoot, withdrawRoot, aggrProof);
    }

    /// @inheritdoc IScrollChain
    /// @dev We only consider batch version >= 7 here.
    function commitAndFinalizeBatch(
        uint8 version,
        bytes32 parentBatchHash,
        FinalizeStruct calldata finalizeStruct
    ) external OnlyTopLevelCall {
        ScrollChainMiscData memory cachedMiscData = miscData;
        if (!isEnforcedModeEnabled()) {
            (uint256 maxDelayEnterEnforcedMode, uint256 maxDelayMessageQueue) = SystemConfig(systemConfig)
                .enforcedBatchParameters();
            uint256 firstUnfinalizedMessageTime = IL1MessageQueueV2(messageQueueV2)
                .getFirstUnfinalizedMessageEnqueueTime();
            if (
                firstUnfinalizedMessageTime + maxDelayMessageQueue < block.timestamp ||
                cachedMiscData.lastFinalizeTimestamp + maxDelayEnterEnforcedMode < block.timestamp
            ) {
                if (cachedMiscData.lastFinalizedBatchIndex < cachedMiscData.lastCommittedBatchIndex) {
                    // be careful with the gas costs, maybe should call revertBatch first.
                    for (
                        uint256 i = cachedMiscData.lastCommittedBatchIndex;
                        i > cachedMiscData.lastFinalizedBatchIndex;
                        --i
                    ) {
                        bytes32 hash = committedBatches[i];
                        if (hash != bytes32(0)) delete committedBatches[i];
                    }
                    emit RevertBatch(
                        cachedMiscData.lastFinalizedBatchIndex + 1,
                        cachedMiscData.lastCommittedBatchIndex
                    );
                }
                // explicitly enable enforced batch mode
                cachedMiscData.flags = uint8(_insertBoolToFlag(cachedMiscData.flags, ENFORCED_MODE_OFFSET, true));
                // reset `lastCommittedBatchIndex`
                cachedMiscData.lastCommittedBatchIndex = uint64(cachedMiscData.lastFinalizedBatchIndex);
                miscData = cachedMiscData;
                emit UpdateEnforcedBatchMode(true, cachedMiscData.lastCommittedBatchIndex);
            } else {
                revert ErrorNotInEnforcedBatchMode();
            }
        }

        bytes32 batchHash = keccak256(finalizeStruct.batchHeader);
        _commitBatchesFromV7(version, parentBatchHash, batchHash, true);

        // finalize with zk proof
        _finalizeBundlePostEuclidV2(
            finalizeStruct.batchHeader,
            finalizeStruct.totalL1MessagesPoppedOverall,
            finalizeStruct.postStateRoot,
            finalizeStruct.withdrawRoot,
            finalizeStruct.zkProof
        );
    }

    /************************
     * Restricted Functions *
     ************************/

    /// @notice Add an account to the sequencer list.
    /// @param _account The address of account to add.
    function addSequencer(address _account) external onlyOwner {
        // @note Currently many external services rely on EOA sequencer to decode metadata directly from tx.calldata.
        // So we explicitly make sure the account is EOA.
        if (_account.code.length > 0) revert ErrorAccountIsNotEOA();

        isSequencer[_account] = true;

        emit UpdateSequencer(_account, true);
    }

    /// @notice Remove an account from the sequencer list.
    /// @param _account The address of account to remove.
    function removeSequencer(address _account) external onlyOwner {
        isSequencer[_account] = false;

        emit UpdateSequencer(_account, false);
    }

    /// @notice Add an account to the prover list.
    /// @param _account The address of account to add.
    function addProver(address _account) external onlyOwner {
        // @note Currently many external services rely on EOA prover to decode metadata directly from tx.calldata.
        // So we explicitly make sure the account is EOA.
        if (_account.code.length > 0) revert ErrorAccountIsNotEOA();
        isProver[_account] = true;

        emit UpdateProver(_account, true);
    }

    /// @notice Add an account from the prover list.
    /// @param _account The address of account to remove.
    function removeProver(address _account) external onlyOwner {
        isProver[_account] = false;

        emit UpdateProver(_account, false);
    }

    /// @notice Pause the contract
    /// @param _status The pause status to update.
    function setPause(bool _status) external onlyOwner {
        if (_status) {
            _pause();
        } else {
            _unpause();
        }
    }

    /// @notice Exit from enforced batch mode.
    function disableEnforcedBatchMode() external onlyOwner {
        miscData.flags = uint8(_insertBoolToFlag(miscData.flags, ENFORCED_MODE_OFFSET, false));
        emit UpdateEnforcedBatchMode(false, miscData.lastCommittedBatchIndex);
    }

    /**********************
     * Internal Functions *
     **********************/

    /// @dev Caller should make sure bit is smaller than 256.
    function _decodeBoolFromFlag(uint256 flag, uint256 bit) internal pure returns (bool) {
        return (flag >> bit) & 1 == 1;
    }

    /// @dev Caller should make sure bit is smaller than 256.
    function _insertBoolToFlag(
        uint256 flag,
        uint256 bit,
        bool value
    ) internal pure returns (uint256) {
        flag = flag ^ (flag & (1 << bit)); // reset value at bit
        if (value) {
            flag |= (1 << bit);
        }
        return flag;
    }

    /// @dev Internal function to do common actions before actual batch finalization.
    function _beforeFinalizeBatch(bytes calldata batchHeader, bytes32 postStateRoot)
        internal
        view
        returns (
            uint256 version,
            bytes32 batchHash,
            uint256 batchIndex,
            uint256 totalL1MessagesPoppedOverall,
            uint256 prevBatchIndex
        )
    {
        if (postStateRoot == bytes32(0)) revert ErrorStateRootIsZero();

        ScrollChainMiscData memory cachedMiscData = miscData;
        uint256 batchPtr;
        // compute pending batch hash and verify
        (batchPtr, batchHash, batchIndex, totalL1MessagesPoppedOverall) = _loadBatchHeader(
            batchHeader,
            cachedMiscData.lastCommittedBatchIndex
        );

        // make sure don't finalize batch multiple times
        prevBatchIndex = cachedMiscData.lastFinalizedBatchIndex;
        if (batchIndex <= prevBatchIndex) revert ErrorBatchIsAlreadyVerified();

        version = BatchHeaderV0Codec.getVersion(batchPtr);
    }

    /// @dev Internal function to do common actions after actual batch finalization.
    function _afterFinalizeBatch(
        uint256 batchIndex,
        bytes32 batchHash,
        uint256 totalL1MessagesPoppedOverall,
        bytes32 postStateRoot,
        bytes32 withdrawRoot,
        bool isV1
    ) internal {
        ScrollChainMiscData memory cachedMiscData = miscData;
        cachedMiscData.lastFinalizedBatchIndex = uint64(batchIndex);
        cachedMiscData.lastFinalizeTimestamp = uint32(block.timestamp);
        miscData = cachedMiscData;
        // @note we do not store intermediate finalized roots
        finalizedStateRoots[batchIndex] = postStateRoot;
        withdrawRoots[batchIndex] = withdrawRoot;

        // Pop finalized and non-skipped message from L1MessageQueue.
        _finalizePoppedL1Messages(totalL1MessagesPoppedOverall, isV1);

        emit FinalizeBatch(batchIndex, batchHash, postStateRoot, withdrawRoot);
    }

    /// @dev Internal function to get the blob versioned hash.
    /// @return _blobVersionedHash The retrieved blob versioned hash.
    function _getBlobVersionedHash(uint256 index) internal virtual returns (bytes32 _blobVersionedHash) {
        // Get blob's versioned hash
        assembly {
            _blobVersionedHash := blobhash(index)
        }
    }

    /// @dev Internal function to commit one ore more batches after the EuclidV2 upgrade.
    /// @param version The version of the batches (version >= 7).
    /// @param parentBatchHash The hash of parent batch.
    /// @param lastBatchHash The hash of the last committed batch after this call.
    /// @param onlyOne If true, we will only process the first blob.
    function _commitBatchesFromV7(
        uint8 version,
        bytes32 parentBatchHash,
        bytes32 lastBatchHash,
        bool onlyOne
    ) internal {
        if (version < 7) {
            // only accept version >= 7
            revert ErrorIncorrectBatchVersion();
        }

        uint256 lastCommittedBatchIndex = miscData.lastCommittedBatchIndex;
        if (parentBatchHash != committedBatches[lastCommittedBatchIndex]) revert ErrorIncorrectBatchHash();
        for (uint256 i = 0; ; i++) {
            bytes32 blobVersionedHash = _getBlobVersionedHash(i);
            if (blobVersionedHash == bytes32(0)) {
                if (i == 0) revert ErrorBatchIsEmpty();
                break;
            }

            lastCommittedBatchIndex += 1;
            // see comments in `src/libraries/codec/BatchHeaderV7Codec.sol` for encodings
            uint256 batchPtr = BatchHeaderV7Codec.allocate();
            BatchHeaderV0Codec.storeVersion(batchPtr, version);
            BatchHeaderV0Codec.storeBatchIndex(batchPtr, lastCommittedBatchIndex);
            BatchHeaderV7Codec.storeParentBatchHash(batchPtr, parentBatchHash);
            BatchHeaderV7Codec.storeBlobVersionedHash(batchPtr, blobVersionedHash);
            bytes32 batchHash = BatchHeaderV0Codec.computeBatchHash(
                batchPtr,
                BatchHeaderV7Codec.BATCH_HEADER_FIXED_LENGTH
            );
            emit CommitBatch(lastCommittedBatchIndex, batchHash);
            parentBatchHash = batchHash;
            if (onlyOne) break;
        }

        // Make sure that the batch hash matches the one computed by the batch committer off-chain.
        // This check can fail if:
        // 1. faulty batch producers commit a wrong batch or the local computation is wrong.
        // 2. unexpected `parentBatch` in case commit transactions get reordered
        // 3. two batch producers commit at the same time with the same `parentBatch`.
        if (parentBatchHash != lastBatchHash) {
            revert InconsistentBatchHash(lastCommittedBatchIndex, lastBatchHash, parentBatchHash);
        }
        // only store last batch hash in storage
        committedBatches[lastCommittedBatchIndex] = parentBatchHash;
        miscData.lastCommittedBatchIndex = uint64(lastCommittedBatchIndex);
    }

    /// @dev Internal function to finalize a bundle after the EuclidV2 upgrade.
    /// @param batchHeader The header of the last batch in this bundle.
    /// @param totalL1MessagesPoppedOverall The number of messages processed after this bundle.
    /// @param postStateRoot The state root after this bundle.
    /// @param withdrawRoot The withdraw trie root after this bundle.
    /// @param aggrProof The bundle proof for this bundle.
    function _finalizeBundlePostEuclidV2(
        bytes calldata batchHeader,
        uint256 totalL1MessagesPoppedOverall,
        bytes32 postStateRoot,
        bytes32 withdrawRoot,
        bytes calldata aggrProof
    ) internal {
        // actions before verification
        (uint256 version, bytes32 batchHash, uint256 batchIndex, , uint256 prevBatchIndex) = _beforeFinalizeBatch(
            batchHeader,
            postStateRoot
        );

        // L1 message hashes are chained,
        // this hash commits to the whole queue up to and including `totalL1MessagesPoppedOverall-1`
        bytes32 messageQueueHash = totalL1MessagesPoppedOverall == 0
            ? bytes32(0)
            : IL1MessageQueueV2(messageQueueV2).getMessageRollingHash(totalL1MessagesPoppedOverall - 1);

        bytes memory publicInputs = abi.encodePacked(
            layer2ChainId,
            messageQueueHash,
            uint32(batchIndex - prevBatchIndex), // numBatches
            finalizedStateRoots[prevBatchIndex], // _prevStateRoot
            committedBatches[prevBatchIndex], // _prevBatchHash
            postStateRoot,
            batchHash,
            withdrawRoot
        );

        // verify bundle, choose the correct verifier based on the last batch
        // our off-chain service will make sure all unfinalized batches have the same batch version.
        IRollupVerifier(verifier).verifyBundleProof(version, batchIndex, aggrProof, publicInputs);

        // actions after verification
        _afterFinalizeBatch(batchIndex, batchHash, totalL1MessagesPoppedOverall, postStateRoot, withdrawRoot, false);
    }

    /// @dev Internal function to load batch header from calldata to memory.
    /// @param _batchHeader The batch header in calldata.
    /// @param _lastCommittedBatchIndex The index of the last committed batch.
    /// @return batchPtr The start memory offset of loaded batch header.
    /// @return _batchHash The hash of the loaded batch header.
    /// @return _batchIndex The index of this batch.
    /// @return _totalL1MessagesPoppedOverall The number of L1 messages popped after this batch.
    /// @dev This function only works with batches whose hashes are stored in `committedBatches`.
    function _loadBatchHeader(bytes calldata _batchHeader, uint256 _lastCommittedBatchIndex)
        internal
        view
        virtual
        returns (
            uint256 batchPtr,
            bytes32 _batchHash,
            uint256 _batchIndex,
            uint256 _totalL1MessagesPoppedOverall
        )
    {
        // load version from batch header, it is always the first byte.
        uint256 version;
        assembly {
            version := shr(248, calldataload(_batchHeader.offset))
        }

        uint256 _length;
        if (version == 0) {
            (batchPtr, _length) = BatchHeaderV0Codec.loadAndValidate(_batchHeader);
        } else if (version <= 2) {
            (batchPtr, _length) = BatchHeaderV1Codec.loadAndValidate(_batchHeader);
        } else if (version <= 6) {
            (batchPtr, _length) = BatchHeaderV3Codec.loadAndValidate(_batchHeader);
        } else {
            (batchPtr, _length) = BatchHeaderV7Codec.loadAndValidate(_batchHeader);
        }

        // the code for compute batch hash is the same for V0~V6
        // also the `_batchIndex` and `_totalL1MessagesPoppedOverall`.
        _batchHash = BatchHeaderV0Codec.computeBatchHash(batchPtr, _length);
        _batchIndex = BatchHeaderV0Codec.getBatchIndex(batchPtr);
        // we don't have totalL1MessagesPoppedOverall in V7~
        if (version <= 6) {
            _totalL1MessagesPoppedOverall = BatchHeaderV0Codec.getTotalL1MessagePopped(batchPtr);
        }

        if (_batchIndex > _lastCommittedBatchIndex) revert ErrorBatchNotCommitted();

        // only check when genesis is imported
        if (committedBatches[_batchIndex] != _batchHash && finalizedStateRoots[0] != bytes32(0)) {
            revert ErrorIncorrectBatchHash();
        }
    }

    /// @param totalL1MessagesPoppedOverall The total number of L1 messages popped in all batches including current batch.
    function _finalizePoppedL1Messages(uint256 totalL1MessagesPoppedOverall, bool isV1) internal {
        if (totalL1MessagesPoppedOverall > 0) {
            if (isV1) {
                IL1MessageQueueV1(messageQueueV1).finalizePoppedCrossDomainMessage(totalL1MessagesPoppedOverall);
            } else {
                IL1MessageQueueV2(messageQueueV2).finalizePoppedCrossDomainMessage(totalL1MessagesPoppedOverall);
            }
        }
    }
}