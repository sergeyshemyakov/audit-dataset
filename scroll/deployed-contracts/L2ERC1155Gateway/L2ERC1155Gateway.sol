// SPDX-License-Identifier: Unknown
pragma solidity .8.16;

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
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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

interface IScrollGateway {
    /**********
     * Errors *
     **********/

    /// @dev Thrown when the given address is `address(0)`.
    error ErrorZeroAddress();

    /// @dev Thrown when the caller is not corresponding `L1ScrollMessenger` or `L2ScrollMessenger`.
    error ErrorCallerIsNotMessenger();

    /// @dev Thrown when the cross chain sender is not the counterpart gateway contract.
    error ErrorCallerIsNotCounterpartGateway();

    /// @dev Thrown when ScrollMessenger is not dropping message.
    error ErrorNotInDropMessageContext();

    /*************************
     * Public View Functions *
     *************************/

    /// @notice The address of corresponding L1/L2 Gateway contract.
    function counterpart() external view returns (address);

    /// @notice The address of L1GatewayRouter/L2GatewayRouter contract.
    function router() external view returns (address);

    /// @notice The address of corresponding L1ScrollMessenger/L2ScrollMessenger contract.
    function messenger() external view returns (address);
}

interface IScrollMessenger {
    /**********
     * Events *
     **********/

    /// @notice Emitted when a cross domain message is sent.
    /// @param sender The address of the sender who initiates the message.
    /// @param target The address of target contract to call.
    /// @param value The amount of value passed to the target contract.
    /// @param messageNonce The nonce of the message.
    /// @param gasLimit The optional gas limit passed to L1 or L2.
    /// @param message The calldata passed to the target contract.
    event SentMessage(
        address indexed sender,
        address indexed target,
        uint256 value,
        uint256 messageNonce,
        uint256 gasLimit,
        bytes message
    );

    /// @notice Emitted when a cross domain message is relayed successfully.
    /// @param messageHash The hash of the message.
    event RelayedMessage(bytes32 indexed messageHash);

    /// @notice Emitted when a cross domain message is failed to relay.
    /// @param messageHash The hash of the message.
    event FailedRelayedMessage(bytes32 indexed messageHash);

    /**********
     * Errors *
     **********/

    /// @dev Thrown when the given address is `address(0)`.
    error ErrorZeroAddress();

    /*************************
     * Public View Functions *
     *************************/

    /// @notice Return the sender of a cross domain message.
    function xDomainMessageSender() external view returns (address);

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @notice Send cross chain message from L1 to L2 or L2 to L1.
    /// @param target The address of account who receive the message.
    /// @param value The amount of ether passed when call target contract.
    /// @param message The content of the message.
    /// @param gasLimit Gas limit required to complete the message relay on corresponding chain.
    function sendMessage(
        address target,
        uint256 value,
        bytes calldata message,
        uint256 gasLimit
    ) external payable;

    /// @notice Send cross chain message from L1 to L2 or L2 to L1.
    /// @param target The address of account who receive the message.
    /// @param value The amount of ether passed when call target contract.
    /// @param message The content of the message.
    /// @param gasLimit Gas limit required to complete the message relay on corresponding chain.
    /// @param refundAddress The address of account who will receive the refunded fee.
    function sendMessage(
        address target,
        uint256 value,
        bytes calldata message,
        uint256 gasLimit,
        address refundAddress
    ) external payable;
}

library ScrollConstants {
    /// @notice The address of default cross chain message sender.
    address internal constant DEFAULT_XDOMAIN_MESSAGE_SENDER = address(1);

    /// @notice The address for dropping message.
    /// @dev The first 20 bytes of keccak("drop")
    address internal constant DROP_XDOMAIN_MESSAGE_SENDER = 0x6f297C61B5C92eF107fFD30CD56AFFE5A273e841;
}

interface IScrollGatewayCallback {
    function onScrollGatewayCallback(bytes memory data) external;
}

/// @title ScrollGatewayBase
/// @notice The `ScrollGatewayBase` is a base contract for gateway contracts used in both in L1 and L2.
abstract contract ScrollGatewayBase is ReentrancyGuardUpgradeable, OwnableUpgradeable, IScrollGateway {
    /*************
     * Constants *
     *************/

    /// @inheritdoc IScrollGateway
    address public immutable override counterpart;

    /// @inheritdoc IScrollGateway
    address public immutable override router;

    /// @inheritdoc IScrollGateway
    address public immutable override messenger;

    /*************
     * Variables *
     *************/

    /// @dev The storage slot used as counterpart gateway contract, which is deprecated now.
    address private __counterpart;

    /// @dev The storage slot used as gateway router contract, which is deprecated now.
    address private __router;

    /// @dev The storage slot used as scroll messenger contract, which is deprecated now.
    address private __messenger;

    /// @dev The storage slot used as token rate limiter contract, which is deprecated now.
    address private __rateLimiter;

    /// @dev The storage slots for future usage.
    uint256[46] private __gap;

    /**********************
     * Function Modifiers *
     **********************/

    modifier onlyCallByCounterpart() {
        // check caller is messenger
        if (_msgSender() != messenger) {
            revert ErrorCallerIsNotMessenger();
        }

        // check cross domain caller is counterpart gateway
        if (counterpart != IScrollMessenger(messenger).xDomainMessageSender()) {
            revert ErrorCallerIsNotCounterpartGateway();
        }
        _;
    }

    modifier onlyInDropContext() {
        // check caller is messenger
        if (_msgSender() != messenger) {
            revert ErrorCallerIsNotMessenger();
        }

        // check we are dropping message in ScrollMessenger.
        if (ScrollConstants.DROP_XDOMAIN_MESSAGE_SENDER != IScrollMessenger(messenger).xDomainMessageSender()) {
            revert ErrorNotInDropMessageContext();
        }
        _;
    }

    /***************
     * Constructor *
     ***************/

    constructor(
        address _counterpart,
        address _router,
        address _messenger
    ) {
        if (_counterpart == address(0) || _messenger == address(0)) {
            revert ErrorZeroAddress();
        }

        counterpart = _counterpart;
        router = _router;
        messenger = _messenger;
    }

    function _initialize(
        address,
        address,
        address
    ) internal {
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        OwnableUpgradeable.__Ownable_init();
    }

    /**********************
     * Internal Functions *
     **********************/

    /// @dev Internal function to forward calldata to target contract.
    /// @param _to The address of contract to call.
    /// @param _data The calldata passed to the contract.
    function _doCallback(address _to, bytes memory _data) internal {
        if (_data.length > 0 && _to.code.length > 0) {
            IScrollGatewayCallback(_to).onScrollGatewayCallback(_data);
        }
    }
}

/// @title The interface for the ERC1155 cross chain gateway on layer 2.
interface IL2ERC1155Gateway {
    /**********
     * Events *
     **********/

    /// @notice Emitted when the ERC1155 NFT is transfered to recipient on layer 2.
    /// @param l1Token The address of ERC1155 NFT on layer 1.
    /// @param l2Token The address of ERC1155 NFT on layer 2.
    /// @param from The address of sender on layer 1.
    /// @param to The address of recipient on layer 2.
    /// @param tokenId The token id of the ERC1155 NFT deposited on layer 1.
    /// @param amount The amount of token deposited.
    event FinalizeDepositERC1155(
        address indexed l1Token,
        address indexed l2Token,
        address indexed from,
        address to,
        uint256 tokenId,
        uint256 amount
    );

    /// @notice Emitted when the ERC1155 NFT is batch transfered to recipient on layer 2.
    /// @param l1Token The address of ERC1155 NFT on layer 1.
    /// @param l2Token The address of ERC1155 NFT on layer 2.
    /// @param from The address of sender on layer 1.
    /// @param to The address of recipient on layer 2.
    /// @param tokenIds The list of token ids of the ERC1155 NFT deposited on layer 1.
    /// @param amounts The list of corresponding amounts deposited.
    event FinalizeBatchDepositERC1155(
        address indexed l1Token,
        address indexed l2Token,
        address indexed from,
        address to,
        uint256[] tokenIds,
        uint256[] amounts
    );

    /// @notice Emitted when the ERC1155 NFT is transfered to gateway on layer 2.
    /// @param l1Token The address of ERC1155 NFT on layer 1.
    /// @param l2Token The address of ERC1155 NFT on layer 2.
    /// @param from The address of sender on layer 2.
    /// @param to The address of recipient on layer 1.
    /// @param tokenId The token id of the ERC1155 NFT to withdraw on layer 2.
    /// @param amount The amount of token to withdraw.
    event WithdrawERC1155(
        address indexed l1Token,
        address indexed l2Token,
        address indexed from,
        address to,
        uint256 tokenId,
        uint256 amount
    );

    /// @notice Emitted when the ERC1155 NFT is batch transfered to gateway on layer 2.
    /// @param l1Token The address of ERC1155 NFT on layer 1.
    /// @param l2Token The address of ERC1155 NFT on layer 2.
    /// @param from The address of sender on layer 2.
    /// @param to The address of recipient on layer 1.
    /// @param tokenIds The list of token ids of the ERC1155 NFT to withdraw on layer 2.
    /// @param amounts The list of corresponding amounts to withdraw.
    event BatchWithdrawERC1155(
        address indexed l1Token,
        address indexed l2Token,
        address indexed from,
        address to,
        uint256[] tokenIds,
        uint256[] amounts
    );

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @notice Withdraw some ERC1155 NFT to caller's account on layer 1.
    /// @param token The address of ERC1155 NFT on layer 2.
    /// @param tokenId The token id to withdraw.
    /// @param amount The amount of token to withdraw.
    /// @param gasLimit Unused, but included for potential forward compatibility considerations.
    function withdrawERC1155(
        address token,
        uint256 tokenId,
        uint256 amount,
        uint256 gasLimit
    ) external payable;

    /// @notice Withdraw some ERC1155 NFT to caller's account on layer 1.
    /// @param token The address of ERC1155 NFT on layer 2.
    /// @param to The address of recipient on layer 1.
    /// @param tokenId The token id to withdraw.
    /// @param amount The amount of token to withdraw.
    /// @param gasLimit Unused, but included for potential forward compatibility considerations.
    function withdrawERC1155(
        address token,
        address to,
        uint256 tokenId,
        uint256 amount,
        uint256 gasLimit
    ) external payable;

    /// @notice Batch withdraw a list of ERC1155 NFT to caller's account on layer 1.
    /// @param token The address of ERC1155 NFT on layer 2.
    /// @param tokenIds The list of token ids to withdraw.
    /// @param amounts The list of corresponding amounts to withdraw.
    /// @param gasLimit Unused, but included for potential forward compatibility considerations.
    function batchWithdrawERC1155(
        address token,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        uint256 gasLimit
    ) external payable;

    /// @notice Batch withdraw a list of ERC1155 NFT to caller's account on layer 1.
    /// @param token The address of ERC1155 NFT on layer 2.
    /// @param to The address of recipient on layer 1.
    /// @param tokenIds The list of token ids to withdraw.
    /// @param amounts The list of corresponding amounts to withdraw.
    /// @param gasLimit Unused, but included for potential forward compatibility considerations.
    function batchWithdrawERC1155(
        address token,
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        uint256 gasLimit
    ) external payable;

    /// @notice Complete ERC1155 deposit from layer 1 to layer 2 and send NFT to recipient's account on layer 2.
    /// @dev Requirements:
    ///  - The function should only be called by L2ScrollMessenger.
    ///  - The function should also only be called by L1ERC1155Gateway on layer 1.
    /// @param l1Token The address of corresponding layer 1 token.
    /// @param l2Token The address of corresponding layer 2 token.
    /// @param from The address of account who deposits the token on layer 1.
    /// @param to The address of recipient on layer 2 to receive the token.
    /// @param tokenId The token id to deposit.
    /// @param amount The amount of token to deposit.
    function finalizeDepositERC1155(
        address l1Token,
        address l2Token,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) external;

    /// @notice Complete ERC1155 deposit from layer 1 to layer 2 and send NFT to recipient's account on layer 2.
    /// @dev Requirements:
    ///  - The function should only be called by L2ScrollMessenger.
    ///  - The function should also only be called by L1ERC1155Gateway on layer 1.
    /// @param l1Token The address of corresponding layer 1 token.
    /// @param l2Token The address of corresponding layer 2 token.
    /// @param from The address of account who deposits the token on layer 1.
    /// @param to The address of recipient on layer 2 to receive the token.
    /// @param tokenIds The list of token ids to deposit.
    /// @param amounts The list of corresponding amounts to deposit.
    function finalizeBatchDepositERC1155(
        address l1Token,
        address l2Token,
        address from,
        address to,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) external;
}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
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
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// Functions needed on top of the ERC1155 standard to be compliant with the Scroll bridge
interface IScrollERC1155Extension {
    /// @notice Return the address of Gateway the token belongs to.
    function gateway() external view returns (address);

    /// @notice Return the address of counterpart token.
    function counterpart() external view returns (address);

    /// @notice Mint some token to recipient's account.
    /// @dev Gateway Utilities, only gateway contract can call
    /// @param _to The address of recipient.
    /// @param _tokenId The token id to mint.
    /// @param _amount The amount of token to mint.
    /// @param _data The data passed to recipient
    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        bytes memory _data
    ) external;

    /// @notice Burn some token from account.
    /// @dev Gateway Utilities, only gateway contract can call
    /// @param _from The address of account to burn token.
    /// @param _tokenId The token id to burn.
    /// @param _amount The amount of token to burn.
    function burn(
        address _from,
        uint256 _tokenId,
        uint256 _amount
    ) external;

    /// @notice Batch mint some token to recipient's account.
    /// @dev Gateway Utilities, only gateway contract can call
    /// @param _to The address of recipient.
    /// @param _tokenIds The token id to mint.
    /// @param _amounts The list of corresponding amount of token to mint.
    /// @param _data The data passed to recipient
    function batchMint(
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external;

    /// @notice Batch burn some token from account.
    /// @dev Gateway Utilities, only gateway contract can call
    /// @param _from The address of account to burn token.
    /// @param _tokenIds The list of token ids to burn.
    /// @param _amounts The list of corresponding amount of token to burn.
    function batchBurn(
        address _from,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) external;
}

// The recommended ERC1155 implementation for bridge token.
// deployed in L2 when original token is on L1
// deployed in L1 when original token is on L2
interface IScrollERC1155 is IERC1155, IScrollERC1155Extension {

}

/// @title The interface for the ERC1155 cross chain gateway on layer 1.
interface IL1ERC1155Gateway {
    /**********
     * Events *
     **********/

    /// @notice Emitted when the ERC1155 NFT is transfered to recipient on layer 1.
    /// @param _l1Token The address of ERC1155 NFT on layer 1.
    /// @param _l2Token The address of ERC1155 NFT on layer 2.
    /// @param _from The address of sender on layer 2.
    /// @param _to The address of recipient on layer 1.
    /// @param _tokenId The token id of the ERC1155 NFT to withdraw from layer 2.
    /// @param _amount The number of token to withdraw from layer 2.
    event FinalizeWithdrawERC1155(
        address indexed _l1Token,
        address indexed _l2Token,
        address indexed _from,
        address _to,
        uint256 _tokenId,
        uint256 _amount
    );

    /// @notice Emitted when the ERC1155 NFT is batch transfered to recipient on layer 1.
    /// @param _l1Token The address of ERC1155 NFT on layer 1.
    /// @param _l2Token The address of ERC1155 NFT on layer 2.
    /// @param _from The address of sender on layer 2.
    /// @param _to The address of recipient on layer 1.
    /// @param _tokenIds The list of token ids of the ERC1155 NFT to withdraw from layer 2.
    /// @param _amounts The list of corresponding number of token to withdraw from layer 2.
    event FinalizeBatchWithdrawERC1155(
        address indexed _l1Token,
        address indexed _l2Token,
        address indexed _from,
        address _to,
        uint256[] _tokenIds,
        uint256[] _amounts
    );

    /// @notice Emitted when the ERC1155 NFT is deposited to gateway on layer 1.
    /// @param _l1Token The address of ERC1155 NFT on layer 1.
    /// @param _l2Token The address of ERC1155 NFT on layer 2.
    /// @param _from The address of sender on layer 1.
    /// @param _to The address of recipient on layer 2.
    /// @param _tokenId The token id of the ERC1155 NFT to deposit on layer 1.
    /// @param _amount The number of token to deposit on layer 1.
    event DepositERC1155(
        address indexed _l1Token,
        address indexed _l2Token,
        address indexed _from,
        address _to,
        uint256 _tokenId,
        uint256 _amount
    );

    /// @notice Emitted when the ERC1155 NFT is batch deposited to gateway on layer 1.
    /// @param _l1Token The address of ERC1155 NFT on layer 1.
    /// @param _l2Token The address of ERC1155 NFT on layer 2.
    /// @param _from The address of sender on layer 1.
    /// @param _to The address of recipient on layer 2.
    /// @param _tokenIds The list of token ids of the ERC1155 NFT to deposit on layer 1.
    /// @param _amounts The list of corresponding number of token to deposit on layer 1.
    event BatchDepositERC1155(
        address indexed _l1Token,
        address indexed _l2Token,
        address indexed _from,
        address _to,
        uint256[] _tokenIds,
        uint256[] _amounts
    );

    /// @notice Emitted when some ERC1155 token is refunded.
    /// @param token The address of the token in L1.
    /// @param recipient The address of receiver in L1.
    /// @param tokenId The id of token refunded.
    /// @param amount The amount of token refunded.
    event RefundERC1155(address indexed token, address indexed recipient, uint256 tokenId, uint256 amount);

    /// @notice Emitted when some ERC1155 token is refunded.
    /// @param token The address of the token in L1.
    /// @param recipient The address of receiver in L1.
    /// @param tokenIds The list of ids of token refunded.
    /// @param amounts The list of amount of token refunded.
    event BatchRefundERC1155(address indexed token, address indexed recipient, uint256[] tokenIds, uint256[] amounts);

    /*************************
     * Public View Functions *
     *************************/

    /// @notice Deposit some ERC1155 NFT to caller's account on layer 2.
    /// @param _token The address of ERC1155 NFT on layer 1.
    /// @param _tokenId The token id to deposit.
    /// @param _amount The amount of token to deposit.
    /// @param _gasLimit Estimated gas limit required to complete the deposit on layer 2.
    function depositERC1155(
        address _token,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;

    /// @notice Deposit some ERC1155 NFT to a recipient's account on layer 2.
    /// @param _token The address of ERC1155 NFT on layer 1.
    /// @param _to The address of recipient on layer 2.
    /// @param _tokenId The token id to deposit.
    /// @param _amount The amount of token to deposit.
    /// @param _gasLimit Estimated gas limit required to complete the deposit on layer 2.
    function depositERC1155(
        address _token,
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable;

    /// @notice Deposit a list of some ERC1155 NFT to caller's account on layer 2.
    /// @param _token The address of ERC1155 NFT on layer 1.
    /// @param _tokenIds The list of token ids to deposit.
    /// @param _amounts The list of corresponding number of token to deposit.
    /// @param _gasLimit Estimated gas limit required to complete the deposit on layer 2.
    function batchDepositERC1155(
        address _token,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        uint256 _gasLimit
    ) external payable;

    /// @notice Deposit a list of some ERC1155 NFT to a recipient's account on layer 2.
    /// @param _token The address of ERC1155 NFT on layer 1.
    /// @param _to The address of recipient on layer 2.
    /// @param _tokenIds The list of token ids to deposit.
    /// @param _amounts The list of corresponding number of token to deposit.
    /// @param _gasLimit Estimated gas limit required to complete the deposit on layer 2.
    function batchDepositERC1155(
        address _token,
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        uint256 _gasLimit
    ) external payable;

    /// @notice Complete ERC1155 withdraw from layer 2 to layer 1 and send fund to recipient's account on layer 1.
    ///      The function should only be called by L1ScrollMessenger.
    ///      The function should also only be called by L2ERC1155Gateway on layer 2.
    /// @param _l1Token The address of corresponding layer 1 token.
    /// @param _l2Token The address of corresponding layer 2 token.
    /// @param _from The address of account who withdraw the token on layer 2.
    /// @param _to The address of recipient on layer 1 to receive the token.
    /// @param _tokenId The token id to withdraw.
    /// @param _amount The amount of token to withdraw.
    function finalizeWithdrawERC1155(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) external;

    /// @notice Complete ERC1155 batch withdraw from layer 2 to layer 1 and send fund to recipient's account on layer 1.
    ///      The function should only be called by L1ScrollMessenger.
    ///      The function should also only be called by L2ERC1155Gateway on layer 2.
    /// @param _l1Token The address of corresponding layer 1 token.
    /// @param _l2Token The address of corresponding layer 2 token.
    /// @param _from The address of account who withdraw the token on layer 2.
    /// @param _to The address of recipient on layer 1 to receive the token.
    /// @param _tokenIds The list of token ids to withdraw.
    /// @param _amounts The list of corresponding number of token to withdraw.
    function finalizeBatchWithdrawERC1155(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) external;
}

interface IL2ScrollMessenger is IScrollMessenger {
    /**********
     * Events *
     **********/

    /// @notice Emitted when the maximum number of times each message can fail in L2 is updated.
    /// @param oldMaxFailedExecutionTimes The old maximum number of times each message can fail in L2.
    /// @param newMaxFailedExecutionTimes The new maximum number of times each message can fail in L2.
    event UpdateMaxFailedExecutionTimes(uint256 oldMaxFailedExecutionTimes, uint256 newMaxFailedExecutionTimes);

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @notice execute L1 => L2 message
    /// @dev Make sure this is only called by privileged accounts.
    /// @param from The address of the sender of the message.
    /// @param to The address of the recipient of the message.
    /// @param value The msg.value passed to the message call.
    /// @param nonce The nonce of the message to avoid replay attack.
    /// @param message The content of the message.
    function relayMessage(
        address from,
        address to,
        uint256 value,
        uint256 nonce,
        bytes calldata message
    ) external;
}

/// @title L2ERC1155Gateway
/// @notice The `L2ERC1155Gateway` is used to withdraw ERC1155 compatible NFTs on layer 2 and
/// finalize deposit the NFTs from layer 1.
/// @dev The withdrawn NFTs tokens will be burned directly. On finalizing deposit, the corresponding
/// NFT will be minted and transfered to the recipient.
///
/// This will be changed if we have more specific scenarios.
contract L2ERC1155Gateway is ERC1155HolderUpgradeable, ScrollGatewayBase, IL2ERC1155Gateway {
    /**********
     * Events *
     **********/

    /// @notice Emitted when token mapping for ERC1155 token is updated.
    /// @param l2Token The address of corresponding ERC1155 token in layer 2.
    /// @param oldL1Token The address of the old corresponding ERC1155 token in layer 1.
    /// @param newL1Token The address of the new corresponding ERC1155 token in layer 1.
    event UpdateTokenMapping(address indexed l2Token, address indexed oldL1Token, address indexed newL1Token);

    /*************
     * Variables *
     *************/

    /// @notice Mapping from layer 2 token address to layer 1 token address for ERC1155 NFT.
    // solhint-disable-next-line var-name-mixedcase
    mapping(address => address) public tokenMapping;

    /***************
     * Constructor *
     ***************/

    /// @notice Constructor for `L2ERC1155Gateway` implementation contract.
    ///
    /// @param _counterpart The address of `L1ERC1155Gateway` contract in L1.
    /// @param _messenger The address of `L2ScrollMessenger` contract in L2.
    constructor(address _counterpart, address _messenger) ScrollGatewayBase(_counterpart, address(0), _messenger) {
        _disableInitializers();
    }

    /// @notice Initialize the storage of `L2ERC1155Gateway`.
    ///
    /// @dev The parameters `_counterpart` and `_messenger` are no longer used.
    ///
    /// @param _counterpart The address of `L1ERC1155Gateway` contract in L1.
    /// @param _messenger The address of `L2ScrollMessenger` contract in L2.
    function initialize(address _counterpart, address _messenger) external initializer {
        ERC1155HolderUpgradeable.__ERC1155Holder_init();
        ERC1155ReceiverUpgradeable.__ERC1155Receiver_init();

        ScrollGatewayBase._initialize(_counterpart, address(0), _messenger);
    }

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @inheritdoc IL2ERC1155Gateway
    function withdrawERC1155(
        address _token,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable override {
        _withdrawERC1155(_token, _msgSender(), _tokenId, _amount, _gasLimit);
    }

    /// @inheritdoc IL2ERC1155Gateway
    function withdrawERC1155(
        address _token,
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _gasLimit
    ) external payable override {
        _withdrawERC1155(_token, _to, _tokenId, _amount, _gasLimit);
    }

    /// @inheritdoc IL2ERC1155Gateway
    function batchWithdrawERC1155(
        address _token,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        uint256 _gasLimit
    ) external payable override {
        _batchWithdrawERC1155(_token, _msgSender(), _tokenIds, _amounts, _gasLimit);
    }

    /// @inheritdoc IL2ERC1155Gateway
    function batchWithdrawERC1155(
        address _token,
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        uint256 _gasLimit
    ) external payable override {
        _batchWithdrawERC1155(_token, _to, _tokenIds, _amounts, _gasLimit);
    }

    /// @inheritdoc IL2ERC1155Gateway
    function finalizeDepositERC1155(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) external virtual onlyCallByCounterpart nonReentrant {
        require(_l1Token != address(0), "token address cannot be 0");
        require(_l1Token == tokenMapping[_l2Token], "l2 token mismatch");

        IScrollERC1155(_l2Token).mint(_to, _tokenId, _amount, "");

        emit FinalizeDepositERC1155(_l1Token, _l2Token, _from, _to, _tokenId, _amount);
    }

    /// @inheritdoc IL2ERC1155Gateway
    function finalizeBatchDepositERC1155(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) external virtual onlyCallByCounterpart nonReentrant {
        require(_l1Token != address(0), "token address cannot be 0");
        require(_l1Token == tokenMapping[_l2Token], "l2 token mismatch");

        IScrollERC1155(_l2Token).batchMint(_to, _tokenIds, _amounts, "");

        emit FinalizeBatchDepositERC1155(_l1Token, _l2Token, _from, _to, _tokenIds, _amounts);
    }

    /************************
     * Restricted Functions *
     ************************/

    /// @notice Update layer 2 to layer 1 token mapping.
    /// @param _l2Token The address of corresponding ERC1155 token on layer 2.
    /// @param _l1Token The address of ERC1155 token on layer 1.
    function updateTokenMapping(address _l2Token, address _l1Token) external onlyOwner {
        require(_l1Token != address(0), "token address cannot be 0");

        address _oldL1Token = tokenMapping[_l2Token];
        tokenMapping[_l2Token] = _l1Token;

        emit UpdateTokenMapping(_l2Token, _oldL1Token, _l1Token);
    }

    /**********************
     * Internal Functions *
     **********************/

    /// @dev Internal function to withdraw ERC1155 NFT to layer 2.
    /// @param _token The address of ERC1155 NFT on layer 1.
    /// @param _to The address of recipient on layer 2.
    /// @param _tokenId The token id to withdraw.
    /// @param _amount The amount of token to withdraw.
    /// @param _gasLimit Estimated gas limit required to complete the withdraw on layer 2.
    function _withdrawERC1155(
        address _token,
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _gasLimit
    ) internal virtual nonReentrant {
        require(_amount > 0, "withdraw zero amount");

        address _l1Token = tokenMapping[_token];
        require(_l1Token != address(0), "no corresponding l1 token");

        address _sender = _msgSender();

        // 1. burn token
        IScrollERC1155(_token).burn(_sender, _tokenId, _amount);

        // 2. Generate message passed to L1ERC1155Gateway.
        bytes memory _message = abi.encodeCall(
            IL1ERC1155Gateway.finalizeWithdrawERC1155,
            (_l1Token, _token, _sender, _to, _tokenId, _amount)
        );

        // 3. Send message to L2ScrollMessenger.
        IL2ScrollMessenger(messenger).sendMessage{value: msg.value}(counterpart, 0, _message, _gasLimit);

        emit WithdrawERC1155(_l1Token, _token, _sender, _to, _tokenId, _amount);
    }

    /// @dev Internal function to batch withdraw ERC1155 NFT to layer 2.
    /// @param _token The address of ERC1155 NFT on layer 1.
    /// @param _to The address of recipient on layer 2.
    /// @param _tokenIds The list of token ids to withdraw.
    /// @param _amounts The list of corresponding number of token to withdraw.
    /// @param _gasLimit Estimated gas limit required to complete the withdraw on layer 1.
    function _batchWithdrawERC1155(
        address _token,
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        uint256 _gasLimit
    ) internal virtual nonReentrant {
        require(_tokenIds.length > 0, "no token to withdraw");
        require(_tokenIds.length == _amounts.length, "length mismatch");

        for (uint256 i = 0; i < _amounts.length; i++) {
            require(_amounts[i] > 0, "withdraw zero amount");
        }

        address _l1Token = tokenMapping[_token];
        require(_l1Token != address(0), "no corresponding l1 token");

        address _sender = _msgSender();

        // 1. transfer token to this contract
        IScrollERC1155(_token).batchBurn(_sender, _tokenIds, _amounts);

        // 2. Generate message passed to L1ERC1155Gateway.
        bytes memory _message = abi.encodeCall(
            IL1ERC1155Gateway.finalizeBatchWithdrawERC1155,
            (_l1Token, _token, _sender, _to, _tokenIds, _amounts)
        );

        // 3. Send message to L2ScrollMessenger.
        IL2ScrollMessenger(messenger).sendMessage{value: msg.value}(counterpart, 0, _message, _gasLimit);

        emit BatchWithdrawERC1155(_l1Token, _token, _sender, _to, _tokenIds, _amounts);
    }
}