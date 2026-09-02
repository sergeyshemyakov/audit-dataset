// SPDX-License-Identifier: Unknown
pragma solidity 0.8.27;

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
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This extension of the {Ownable} contract includes a two-step mechanism to transfer
 * ownership, where the new owner must call {acceptOwnership} in order to replace the
 * old one. This can help prevent common mistakes, such as transfers of ownership to
 * incorrect accounts, or to contracts that are unable to interact with the
 * permission system.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     *
     * Setting `newOwner` to the zero address is allowed; this can be used to cancel an initiated ownership transfer.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
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

interface IBaseStaker {
    function initialize(address _atp) external;

    function getATP() external view returns (address);
    function getOperator() external view returns (address);
    function getImplementation() external view returns (address);
}

/**
 * @dev ERC-1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC-1967 implementation slot:
 * ```solidity
 * contract ERC1967 {
 *     // Define the slot. Alternatively, use the SlotDerivation library to derive the slot.
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(newImplementation.code.length > 0);
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * TIP: Consider using this library along with {SlotDerivation}.
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct Int256Slot {
        int256 value;
    }

    struct StringSlot {
        string value;
    }

    struct BytesSlot {
        bytes value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `Int256Slot` with member `value` located at `slot`.
     */
    function getInt256Slot(bytes32 slot) internal pure returns (Int256Slot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns a `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.
     */
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }

    /**
     * @dev Returns a `BytesSlot` with member `value` located at `slot`.
     */
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.
     */
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly ("memory-safe") {
            r.slot := store.slot
        }
    }
}

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 */
interface IERC1967 {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
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
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
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
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {UpgradeableBeacon} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

/**
 * @dev This library provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[ERC-1967] slots.
 */
library ERC1967Utils {
    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev The `implementation` of the proxy is invalid.
     */
    error ERC1967InvalidImplementation(address implementation);

    /**
     * @dev The `admin` of the proxy is invalid.
     */
    error ERC1967InvalidAdmin(address admin);

    /**
     * @dev The `beacon` of the proxy is invalid.
     */
    error ERC1967InvalidBeacon(address beacon);

    /**
     * @dev An upgrade function sees `msg.value > 0` that may be lost.
     */
    error ERC1967NonPayable();

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the ERC-1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(newImplementation);
        }
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Performs implementation upgrade with additional setup call if data is nonempty.
     * This function is payable only if the setup call is performed, otherwise `msg.value` is rejected
     * to avoid stuck value in the contract.
     *
     * Emits an {IERC1967-Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) internal {
        _setImplementation(newImplementation);
        emit IERC1967.Upgraded(newImplementation);

        if (data.length > 0) {
            Address.functionDelegateCall(newImplementation, data);
        } else {
            _checkNonPayable();
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by ERC-1967) using
     * the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the ERC-1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        if (newAdmin == address(0)) {
            revert ERC1967InvalidAdmin(address(0));
        }
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {IERC1967-AdminChanged} event.
     */
    function changeAdmin(address newAdmin) internal {
        emit IERC1967.AdminChanged(getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is the keccak-256 hash of "eip1967.proxy.beacon" subtracted by 1.
     */
    // solhint-disable-next-line private-vars-leading-underscore
    bytes32 internal constant BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the ERC-1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        if (newBeacon.code.length == 0) {
            revert ERC1967InvalidBeacon(newBeacon);
        }

        StorageSlot.getAddressSlot(BEACON_SLOT).value = newBeacon;

        address beaconImplementation = IBeacon(newBeacon).implementation();
        if (beaconImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(beaconImplementation);
        }
    }

    /**
     * @dev Change the beacon and trigger a setup call if data is nonempty.
     * This function is payable only if the setup call is performed, otherwise `msg.value` is rejected
     * to avoid stuck value in the contract.
     *
     * Emits an {IERC1967-BeaconUpgraded} event.
     *
     * CAUTION: Invoking this function has no effect on an instance of {BeaconProxy} since v5, since
     * it uses an immutable beacon without looking at the value of the ERC-1967 beacon slot for
     * efficiency.
     */
    function upgradeBeaconToAndCall(address newBeacon, bytes memory data) internal {
        _setBeacon(newBeacon);
        emit IERC1967.BeaconUpgraded(newBeacon);

        if (data.length > 0) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        } else {
            _checkNonPayable();
        }
    }

    /**
     * @dev Reverts if `msg.value` is not zero. It can be used to avoid `msg.value` stuck in the contract
     * if an upgrade doesn't perform an initialization call.
     */
    function _checkNonPayable() private {
        if (msg.value > 0) {
            revert ERC1967NonPayable();
        }
    }
}

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 */
abstract contract UUPSUpgradeable is IERC1822Proxiable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private immutable __self = address(this);

    /**
     * @dev The version of the upgrade interface of the contract. If this getter is missing, both `upgradeTo(address)`
     * and `upgradeToAndCall(address,bytes)` are present, and `upgradeTo` must be used if no function should be called,
     * while `upgradeToAndCall` will invoke the `receive` function if the second argument is the empty byte string.
     * If the getter returns `"5.0.0"`, only `upgradeToAndCall(address,bytes)` is present, and the second argument must
     * be the empty byte string if no function should be called, making it impossible to invoke the `receive` function
     * during an upgrade.
     */
    string public constant UPGRADE_INTERFACE_VERSION = "5.0.0";

    /**
     * @dev The call is from an unauthorized context.
     */
    error UUPSUnauthorizedCallContext();

    /**
     * @dev The storage `slot` is unsupported as a UUID.
     */
    error UUPSUnsupportedProxiableUUID(bytes32 slot);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC-1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC-1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        _checkProxy();
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        _checkNotDelegated();
        _;
    }

    /**
     * @dev Implementation of the ERC-1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual notDelegated returns (bytes32) {
        return ERC1967Utils.IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     *
     * @custom:oz-upgrades-unsafe-allow-reachable delegatecall
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data);
    }

    /**
     * @dev Reverts if the execution is not performed via delegatecall or the execution
     * context is not of a proxy with an ERC-1967 compliant implementation pointing to self.
     * See {_onlyProxy}.
     */
    function _checkProxy() internal view virtual {
        if (
            address(this) == __self || // Must be called through delegatecall
            ERC1967Utils.getImplementation() != __self // Must be called through an active proxy
        ) {
            revert UUPSUnauthorizedCallContext();
        }
    }

    /**
     * @dev Reverts if the execution is performed via delegatecall.
     * See {notDelegated}.
     */
    function _checkNotDelegated() internal view virtual {
        if (address(this) != __self) {
            // Must not be called through delegatecall
            revert UUPSUnauthorizedCallContext();
        }
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev Performs an implementation upgrade with a security check for UUPS proxies, and additional setup call.
     *
     * As a security check, {proxiableUUID} is invoked in the new implementation, and the return value
     * is expected to be the implementation slot in ERC-1967.
     *
     * Emits an {IERC1967-Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data) private {
        try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
            if (slot != ERC1967Utils.IMPLEMENTATION_SLOT) {
                revert UUPSUnsupportedProxiableUUID(slot);
            }
            ERC1967Utils.upgradeToAndCall(newImplementation, data);
        } catch {
            // The implementation is not UUPS
            revert ERC1967Utils.ERC1967InvalidImplementation(newImplementation);
        }
    }
}

/**
 * @notice  The lock struct
 * @param   startTime The timestamp that the lock starts at (0 before this value)
 * @param   cliff The timestamp of the cliff of the lock (0 before this value, >= startTime)
 * @param   endTime The timestamp that the lock ends at, >= cliff
 * @param   allocation The amount of tokens that are locked
 */
struct Lock {
    uint256 startTime;
    uint256 cliff;
    uint256 endTime;
    uint256 allocation;
}

interface IATPCore {
    event StakerInitialized(IBaseStaker staker);
    event StakerUpgraded(StakerVersion version);
    event StakerOperatorUpdated(address operator);
    event Claimed(uint256 amount);
    event ApprovedStaker(uint256 allowance);
    event Rescued(address asset, address to, uint256 amount);
    event Revoked(uint256 amount);

    error AlreadyInitialized();
    error InvalidBeneficiary(address beneficiary);
    error NotBeneficiary(address caller, address beneficiary);
    error LockHasEnded();
    error InvalidTokenAddress(address token);
    error InvalidRegistry(address registry);
    error AllocationMustBeGreaterThanZero();
    error InvalidAsset(address asset);
    error ExecutionNotAllowedYet(uint256 timestamp, uint256 executeAllowedAt);
    error NotRevokable();
    error NotRevoker(address caller, address revoker);
    error NoClaimable();
    error LockDurationMustBeGTZero(string variant);
    error InvalidUpgrade();

    function upgradeStaker(StakerVersion _version) external;
    function approveStaker(uint256 _allowance) external;
    function updateStakerOperator(address _operator) external;
    function claim() external returns (uint256);
    function rescueFunds(address _asset, address _to) external;
    function revoke() external returns (uint256);
    function getClaimable() external view returns (uint256);
    function getGlobalLock() external view returns (Lock memory);
    function getBeneficiary() external view returns (address);
    function getOperator() external view returns (address);
}

contract BaseStaker is IBaseStaker, UUPSUpgradeable {
    address internal atp;

    error AlreadyInitialized();
    error ZeroATP();
    error NotATP(address caller, address atp);
    error NotOperator(address caller, address operator);
    error UnSupportedOperation();

    modifier onlyOperator() {
        address operator = getOperator();
        require(msg.sender == operator, NotOperator(msg.sender, operator));
        _;
    }

    modifier onlyATP() {
        require(msg.sender == address(atp), NotATP(msg.sender, address(atp)));
        _;
    }

    constructor() {
        atp = address(0xdead);
    }

    function initialize(address _atp) external virtual override(IBaseStaker) {
        require(address(_atp) != address(0), ZeroATP());
        require(address(atp) == address(0), AlreadyInitialized());

        atp = _atp;
    }

    function getATP() external view virtual override(IBaseStaker) returns (address) {
        return atp;
    }

    function getImplementation() external view virtual override(IBaseStaker) returns (address) {
        return ERC1967Utils.getImplementation();
    }

    function getOperator() public view virtual override(IBaseStaker) returns (address) {
        return IATPCore(atp).getOperator();
    }

    function _authorizeUpgrade(address _newImplementation) internal virtual override(UUPSUpgradeable) onlyATP {}
}

contract Registry is Ownable2Step, IRegistry {
    uint256 internal immutable UNLOCK_CLIFF_DURATION;
    uint256 internal immutable UNLOCK_LOCK_DURATION;

    // @note An initial value set to be the unix timestamp of 1st of January 2027
    uint256 internal unlockStartTime = 1798761600;
    uint256 internal executeAllowedAt = 1798761600;
    address internal revoker;
    address internal revokerOperator;

    StakerVersion internal nextStakerVersion;
    mapping(StakerVersion version => address implementation) internal stakerImplementations;

    MilestoneId internal nextMilestoneId;
    mapping(MilestoneId milestoneId => MilestoneStatus status) internal milestones;

    constructor(address __owner, uint256 _unlockCliffDuration, uint256 _unlockLockDuration) Ownable(__owner) {
        require(_unlockLockDuration > 0, InvalidUnlockDuration());
        require(_unlockLockDuration >= _unlockCliffDuration, InvalidUnlockCliffDuration());

        UNLOCK_CLIFF_DURATION = _unlockCliffDuration;
        UNLOCK_LOCK_DURATION = _unlockLockDuration;

        // @note Register the base staker implementation
        stakerImplementations[StakerVersion.wrap(0)] = address(new BaseStaker());
        nextStakerVersion = StakerVersion.wrap(1);
    }

    /**
     * @notice  Add a new milestone
     *
     * @dev Only callable by the owner
     *
     * @return  The milestone id
     */
    function addMilestone() external override(IRegistry) onlyOwner returns (MilestoneId) {
        MilestoneId milestoneId = nextMilestoneId;
        nextMilestoneId = MilestoneId.wrap(MilestoneId.unwrap(nextMilestoneId) + 1);
        milestones[milestoneId] = MilestoneStatus.Pending; // To be explicit

        emit MilestoneAdded(milestoneId);
        return milestoneId;
    }

    function setMilestoneStatus(MilestoneId _milestoneId, MilestoneStatus _status)
        external
        override(IRegistry)
        onlyOwner
    {
        require(getMilestoneStatus(_milestoneId) == MilestoneStatus.Pending, InvalidMilestoneStatus(_milestoneId));
        require(_status != MilestoneStatus.Pending, InvalidMilestoneStatus(_milestoneId));
        milestones[_milestoneId] = _status;

        emit MilestoneStatusUpdated(_milestoneId, _status);
    }

    /**
     * @notice  Register a new staker implementation
     *
     * @dev Only callable by the owner
     *
     * @param _implementation   The address of the staker implementation
     */
    function registerStakerImplementation(address _implementation) external override(IRegistry) onlyOwner {
        require(
            UUPSUpgradeable(_implementation).proxiableUUID() == ERC1967Utils.IMPLEMENTATION_SLOT,
            InvalidStakerImplementation(_implementation)
        );

        StakerVersion version = nextStakerVersion;
        nextStakerVersion = StakerVersion.wrap(StakerVersion.unwrap(nextStakerVersion) + 1);
        stakerImplementations[version] = _implementation;

        emit StakerRegistered(version, _implementation);
    }

    /**
     * @notice  Set the revoker address
     *
     * @dev Only callable by the owner
     *
     * @param _revoker   The address of the revoker
     */
    function setRevoker(address _revoker) external override(IRegistry) onlyOwner {
        revoker = _revoker;
        emit UpdatedRevoker(_revoker);
    }

    function setRevokerOperator(address _revokerOperator) external override(IRegistry) onlyOwner {
        revokerOperator = _revokerOperator;
        emit UpdatedRevokerOperator(_revokerOperator);
    }

    /**
     * @notice  Set the execute allowed at timestamp
     *          Can only be decreased to avoid unintentional updates and give some guarantees to LATP beneficiaries
     *
     * @dev Only callable by the owner
     *
     * @param _executeAllowedAt   The timestamp of when the execute is allowed
     */
    function setExecuteAllowedAt(uint256 _executeAllowedAt) external override(IRegistry) onlyOwner {
        require(_executeAllowedAt < executeAllowedAt, InvalidExecuteAllowedAt(_executeAllowedAt, executeAllowedAt));
        executeAllowedAt = _executeAllowedAt;
        emit UpdatedExecuteAllowedAt(_executeAllowedAt);
    }

    /**
     * @notice  Set the unlock start time
     *          Can only be decreased to avoid unintentional updates and give some guarantees to LATP beneficiaries
     *
     * @dev Only callable by the owner
     *
     * @param _unlockStartTime   The timestamp of when the unlock starts
     */
    function setUnlockStartTime(uint256 _unlockStartTime) external override(IRegistry) onlyOwner {
        require(_unlockStartTime < unlockStartTime, InvalidUnlockStartTime(_unlockStartTime, unlockStartTime));
        unlockStartTime = _unlockStartTime;
        emit UpdatedUnlockStartTime(_unlockStartTime);
    }

    /**
     * @notice  Get the revoker address
     *
     * @return  The address of the revoker
     */
    function getRevoker() external view override(IRegistry) returns (address) {
        return revoker;
    }

    function getRevokerOperator() external view override(IRegistry) returns (address) {
        return revokerOperator;
    }

    /**
     * @notice  Get the execute allowed at timestamp
     *
     * @return  The timestamp of when the execute is allowed
     */
    function getExecuteAllowedAt() external view override(IRegistry) returns (uint256) {
        return executeAllowedAt;
    }

    /**
     * @notice  Get the unlock start time
     *
     * @return  The timestamp of when the unlock starts
     */
    function getUnlockStartTime() external view override(IRegistry) returns (uint256) {
        return unlockStartTime;
    }

    /**
     * @notice  Get the lock params for the global unlocking schedule
     *
     * @return  The global lock params
     */
    function getGlobalLockParams() external view override(IRegistry) returns (LockParams memory) {
        return LockParams({
            startTime: unlockStartTime,
            cliffDuration: UNLOCK_CLIFF_DURATION,
            lockDuration: UNLOCK_LOCK_DURATION
        });
    }

    /**
     * @notice  Get the implementation for a given staker version
     *
     * @param   _version   The version of the staker
     *
     * @return  The implementation for the given staker version
     */
    function getStakerImplementation(StakerVersion _version) external view override(IRegistry) returns (address) {
        require(StakerVersion.unwrap(_version) < StakerVersion.unwrap(nextStakerVersion), UnRegisteredStaker(_version));
        return stakerImplementations[_version];
    }

    /**
     * @notice  Get the next staker version
     *
     * @return  The next staker version
     */
    function getNextStakerVersion() external view override(IRegistry) returns (StakerVersion) {
        return nextStakerVersion;
    }

    function getNextMilestoneId() external view override(IRegistry) returns (MilestoneId) {
        return nextMilestoneId;
    }

    function getMilestoneStatus(MilestoneId _milestoneId) public view override(IRegistry) returns (MilestoneStatus) {
        require(
            MilestoneId.unwrap(_milestoneId) < MilestoneId.unwrap(nextMilestoneId), InvalidMilestoneId(_milestoneId)
        );
        return milestones[_milestoneId];
    }
}