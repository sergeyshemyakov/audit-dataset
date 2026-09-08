// SPDX-License-Identifier: Unknown
pragma solidity 0.8.23;

interface IBridgeManagerEvents {
    /**
     * @dev Emitted when new bridge operators are added.
     */
    event BridgeOperatorsAdded(bool[] statuses, uint96[] voteWeights, address[] governors, address[] bridgeOperators);

    /**
     * @dev Emitted when a bridge operator is failed to add.
     */
    event BridgeOperatorAddingFailed(address indexed operator);

    /**
     * @dev Emitted when bridge operators are removed.
     */
    event BridgeOperatorsRemoved(bool[] statuses, address[] bridgeOperators);

    /**
     * @dev Emitted when a bridge operator is failed to remove.
     */
    event BridgeOperatorRemovingFailed(address indexed operator);

    /**
     * @dev Emitted when a bridge operator is updated.
     */
    event BridgeOperatorUpdated(
        address indexed governor, address indexed fromBridgeOperator, address indexed toBridgeOperator
    );

    /**
     * @dev Emitted when the minimum number of required governors is updated.
     */
    event MinRequiredGovernorUpdated(uint256 min);
}

/**
 * @title IBridgeManager
 * @dev The interface for managing bridge operators.
 */
interface IBridgeManager is IBridgeManagerEvents {
    /// @notice Error indicating that cannot find the querying operator
    error ErrOperatorNotFound(address operator);
    /// @notice Error indicating that cannot find the querying governor
    error ErrGovernorNotFound(address governor);
    /// @notice Error indicating that the msg.sender is not match the required governor
    error ErrGovernorNotMatch(address required, address sender);
    /// @notice Error indicating that the governors list will go below minimum number of required governor.
    error ErrBelowMinRequiredGovernors();
    /// @notice Common invalid input error
    error ErrInvalidInput();

    /**
     * @dev The domain separator used for computing hash digests in the contract.
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /**
     * @dev Returns the total number of bridge operators.
     * @return The total number of bridge operators.
     */
    function totalBridgeOperator() external view returns (uint256);

    /**
     * @dev Checks if the given address is a bridge operator.
     * @param addr The address to check.
     * @return A boolean indicating whether the address is a bridge operator.
     */
    function isBridgeOperator(address addr) external view returns (bool);

    /**
     * @dev Retrieves the full information of all registered bridge operators.
     *
     * This external function allows external callers to obtain the full information of all the registered bridge operators.
     * The returned arrays include the addresses of governors, bridge operators, and their corresponding vote weights.
     *
     * @return governors An array of addresses representing the governors of each bridge operator.
     * @return bridgeOperators An array of addresses representing the registered bridge operators.
     * @return weights An array of uint256 values representing the vote weights of each bridge operator.
     *
     * Note: The length of each array will be the same, and the order of elements corresponds to the same bridge operator.
     *
     * Example Usage:
     * ```
     * (address[] memory governors, address[] memory bridgeOperators, uint256[] memory weights) = getFullBridgeOperatorInfos();
     * for (uint256 i = 0; i < bridgeOperators.length; i++) {
     *     // Access individual information for each bridge operator.
     *     address governor = governors[i];
     *     address bridgeOperator = bridgeOperators[i];
     *     uint256 weight = weights[i];
     *     // ... (Process or use the information as required) ...
     * }
     * ```
     *
     */
    function getFullBridgeOperatorInfos()
        external
        view
        returns (address[] memory governors, address[] memory bridgeOperators, uint96[] memory weights);

    /**
     * @dev Returns total weights of the governor list.
     */
    function sumGovernorsWeight(address[] calldata governors) external view returns (uint256 sum);

    /**
     * @dev Returns total weights.
     */
    function getTotalWeight() external view returns (uint256);

    /**
     * @dev Returns an array of all bridge operators.
     * @return An array containing the addresses of all bridge operators.
     */
    function getBridgeOperators() external view returns (address[] memory);

    /**
     * @dev Returns the corresponding `operator` of a `governor`.
     */
    function getOperatorOf(address governor) external view returns (address operator);

    /**
     * @dev Returns the corresponding `governor` of a `operator`.
     */
    function getGovernorOf(address operator) external view returns (address governor);

    /**
     * @dev External function to retrieve the vote weight of a specific governor.
     * @param governor The address of the governor to get the vote weight for.
     * @return voteWeight The vote weight of the specified governor.
     */
    function getGovernorWeight(address governor) external view returns (uint96);

    /**
     * @dev External function to retrieve the vote weight of a specific bridge operator.
     * @param bridgeOperator The address of the bridge operator to get the vote weight for.
     * @return weight The vote weight of the specified bridge operator.
     */
    function getBridgeOperatorWeight(address bridgeOperator) external view returns (uint96 weight);

    /**
     * @dev Returns the weights of a list of governor addresses.
     */
    function getGovernorWeights(address[] calldata governors) external view returns (uint96[] memory weights);

    /**
     * @dev Returns an array of all governors.
     * @return An array containing the addresses of all governors.
     */
    function getGovernors() external view returns (address[] memory);

    /**
     * @dev Adds multiple bridge operators.
     * @param governors An array of addresses of hot/cold wallets for bridge operator to update their node address.
     * @param bridgeOperators An array of addresses representing the bridge operators to add.
     */
    function addBridgeOperators(
        uint96[] calldata voteWeights,
        address[] calldata governors,
        address[] calldata bridgeOperators
    ) external;

    /**
     * @dev Removes multiple bridge operators.
     * @param bridgeOperators An array of addresses representing the bridge operators to remove.
     */
    function removeBridgeOperators(address[] calldata bridgeOperators) external;

    /**
     * @dev Self-call to update the minimum required governor.
     * @param min The minimum number, this must not less than 3.
     */
    function setMinRequiredGovernor(uint256 min) external;
}

interface IQuorum {
    /// @dev Emitted when the threshold is updated
    event ThresholdUpdated(
        uint256 indexed nonce,
        uint256 indexed numerator,
        uint256 indexed denominator,
        uint256 previousNumerator,
        uint256 previousDenominator
    );

    /**
     * @dev Returns the threshold.
     */
    function getThreshold() external view returns (uint256 _num, uint256 _denom);

    /**
     * @dev Checks whether the `_voteWeight` passes the threshold.
     */
    function checkThreshold(uint256 _voteWeight) external view returns (bool);

    /**
     * @dev Returns the minimum vote weight to pass the threshold.
     */
    function minimumVoteWeight() external view returns (uint256);

    /**
     * @dev Sets the threshold.
     *
     * Requirements:
     * - The method caller is admin.
     *
     * Emits the `ThresholdUpdated` event.
     *
     */
    function setThreshold(uint256 numerator, uint256 denominator) external;
}

library AddressArrayUtils {
    /**
     * @dev Error thrown when a duplicated element is detected in an array.
     * @param msgSig The function signature that invoke the error.
     */
    error ErrDuplicated(bytes4 msgSig);

    /**
     * @dev Returns whether or not there's a duplicate. Runs in O(n^2).
     * @param A Array to search
     * @return Returns true if duplicate, false otherwise
     */
    function hasDuplicate(address[] memory A) internal pure returns (bool) {
        if (A.length == 0) {
            return false;
        }
        unchecked {
            for (uint256 i = 0; i < A.length - 1; i++) {
                for (uint256 j = i + 1; j < A.length; j++) {
                    if (A[i] == A[j]) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /**
     * @dev Returns whether two arrays of addresses are equal or not.
     */
    function isEqual(address[] memory _this, address[] memory _other) internal pure returns (bool yes_) {
        // Hashing two arrays and compare their hash
        assembly {
            let _thisHash := keccak256(add(_this, 32), mul(mload(_this), 32))
            let _otherHash := keccak256(add(_other, 32), mul(mload(_other), 32))
            yes_ := eq(_thisHash, _otherHash)
        }
    }

    /**
     * @dev Return the concatenated array from a and b.
     */
    function extend(address[] memory a, address[] memory b) internal pure returns (address[] memory c) {
        uint256 lengthA = a.length;
        uint256 lengthB = b.length;
        unchecked {
            c = new address[](lengthA + lengthB);
        }
        uint256 i;
        for (; i < lengthA;) {
            c[i] = a[i];
            unchecked {
                ++i;
            }
        }
        for (uint256 j; j < lengthB;) {
            c[i] = b[j];
            unchecked {
                ++i;
                ++j;
            }
        }
    }
}

/**
 * @dev Error indicating that a function can only be called by the contract itself.
 * @param msgSig The function signature (bytes4) that can only be called by the contract itself.
 */
error ErrOnlySelfCall(bytes4 msgSig);

/**
 * @dev Error of set to non-contract.
 */
error ErrZeroCodeContract(address addr);

/**
 * @dev Error indicating that given address is null when it should not.
 */
error ErrZeroAddress(bytes4 msgSig);

/**
 * @dev Error thrown when an address is expected to be an already created externally owned account (EOA).
 * This error indicates that the provided address is invalid for certain contract operations that require already created EOA.
 */
error ErrAddressIsNotCreatedEOA(address addr, bytes32 codehash);

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
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
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

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value: amount}("");
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
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage)
        internal
        returns (bytes memory)
    {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage)
        internal
        returns (bytes memory)
    {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage)
        internal
        view
        returns (bytes memory)
    {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage)
        internal
        returns (bytes memory)
    {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage)
        internal
        pure
        returns (bytes memory)
    {
        if (success) {
            return returndata;
        } else {
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
}

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
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
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()), "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(address _logic, address admin_, bytes memory _data) payable ERC1967Proxy(_logic, _data) {
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

contract TransparentUpgradeableProxyV2 is TransparentUpgradeableProxy {
    constructor(address _logic, address admin_, bytes memory _data)
        payable
        TransparentUpgradeableProxy(_logic, admin_, _data)
    {}

    /**
     * @dev Calls a function from the current implementation as specified by `_data`, which should be an encoded function call.
     *
     * Requirements:
     * - Only the admin can call this function.
     *
     * Note: The proxy admin is not allowed to interact with the proxy logic through the fallback function to avoid
     * triggering some unexpected logic. This is to allow the administrator to explicitly call the proxy, please consider
     * reviewing the encoded data `_data` and the method which is called before using this.
     *
     */
    function functionDelegateCall(bytes memory _data) public payable ifAdmin {
        address _addr = _implementation();
        assembly {
            let _result := delegatecall(gas(), _addr, add(_data, 32), mload(_data), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch _result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

/**
 * @dev The error indicating an unsupported interface.
 * @param interfaceId The bytes4 interface identifier that is not supported.
 * @param addr The address where the unsupported interface was encountered.
 */
error ErrUnsupportedInterface(bytes4 interfaceId, address addr);

abstract contract IdentityGuard {
    using AddressArrayUtils for address[];

    /// @dev value is equal to keccak256(abi.encode())
    /// @dev see: https://eips.ethereum.org/EIPS/eip-1052
    bytes32 internal constant CREATED_ACCOUNT_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    /**
     * @dev Modifier to restrict functions to only be called by this contract.
     * @dev Reverts if the caller is not this contract.
     */
    modifier onlySelfCall() virtual {
        _requireSelfCall();
        _;
    }

    /**
     * @dev Modifier to ensure that the elements in the `arr` array are non-duplicates.
     * It calls the internal `_checkDuplicate` function to perform the duplicate check.
     *
     * Requirements:
     * - The elements in the `arr` array must not contain any duplicates.
     */
    modifier nonDuplicate(address[] memory arr) virtual {
        _requireNonDuplicate(arr);
        _;
    }

    /**
     * @dev Internal method to check the method caller.
     * @dev Reverts if the method caller is not this contract.
     */
    function _requireSelfCall() internal view virtual {
        if (msg.sender != address(this)) {
            revert ErrOnlySelfCall(msg.sig);
        }
    }

    /**
     * @dev Internal function to check if a contract address has code.
     * @param addr The address of the contract to check.
     * @dev Throws an error if the contract address has no code.
     */
    function _requireHasCode(address addr) internal view {
        if (addr.code.length == 0) {
            revert ErrZeroCodeContract(addr);
        }
    }

    /**
     * @dev Checks if an address is zero and reverts if it is.
     * @param addr The address to check.
     */
    function _requireNonZeroAddress(address addr) internal pure {
        if (addr == address(0)) {
            revert ErrZeroAddress(msg.sig);
        }
    }

    /**
     * @dev Check if arr is empty and revert if it is.
     * Checks if an array contains any duplicate addresses and reverts if duplicates are found.
     * @param arr The array of addresses to check.
     */
    function _requireNonDuplicate(address[] memory arr) internal pure {
        if (arr.hasDuplicate()) {
            revert AddressArrayUtils.ErrDuplicated(msg.sig);
        }
    }

    /**
     * @dev Internal function to require that the provided address is a created externally owned account (EOA).
     * This internal function is used to ensure that the provided address is a valid externally owned account (EOA).
     * It checks the codehash of the address against a predefined constant to confirm that the address is a created EOA.
     * @notice This method only works with non-state EOA accounts
     */
    function _requireCreatedEOA(address addr) internal view {
        _requireNonZeroAddress(addr);
        bytes32 codehash = addr.codehash;
        if (codehash != CREATED_ACCOUNT_HASH) {
            revert ErrAddressIsNotCreatedEOA(addr, codehash);
        }
    }

    /**
     * @dev Internal function to require that the specified contract supports the given interface. This method handle in
     * both case that the callee is either or not the proxy admin of the caller. If the contract does not support the
     * interface `interfaceId` or EIP165, a revert with the corresponding error message is triggered.
     *
     * @param contractAddr The address of the contract to check for interface support.
     * @param interfaceId The interface ID to check for support.
     */
    function _requireSupportsInterface(address contractAddr, bytes4 interfaceId) internal view {
        bytes memory supportsInterfaceParams = abi.encodeCall(IERC165.supportsInterface, (interfaceId));
        (bool success, bytes memory returnOrRevertData) = contractAddr.staticcall(supportsInterfaceParams);
        if (!success) {
            (success, returnOrRevertData) = contractAddr.staticcall(
                abi.encodeCall(TransparentUpgradeableProxyV2.functionDelegateCall, (supportsInterfaceParams))
            );
            if (!success) {
                revert ErrUnsupportedInterface(interfaceId, contractAddr);
            }
        }
        if (!abi.decode(returnOrRevertData, (bool))) {
            revert ErrUnsupportedInterface(interfaceId, contractAddr);
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
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

enum RoleAccess {
    UNKNOWN, // 0
    ADMIN, // 1
    COINBASE, // 2
    GOVERNOR, // 3
    CANDIDATE_ADMIN, // 4
    WITHDRAWAL_MIGRATOR, // 5
    __DEPRECATED_BRIDGE_OPERATOR, // 6
    BLOCK_PRODUCER, // 7
    VALIDATOR_CANDIDATE, // 8
    CONSENSUS, // 9
    TREASURY // 10

}

/**
 * @dev Error indicating that the caller is unauthorized to perform a specific function.
 * @param msgSig The function signature (bytes4) that the caller is unauthorized to perform.
 * @param expectedRole The role required to perform the function.
 */
error ErrUnauthorized(bytes4 msgSig, RoleAccess expectedRole);

abstract contract HasProxyAdmin {
    // bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier onlyProxyAdmin() {
        _requireProxyAdmin();
        _;
    }

    /**
     * @dev Returns proxy admin.
     */
    function _getProxyAdmin() internal view virtual returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _requireProxyAdmin() internal view {
        if (msg.sender != _getProxyAdmin()) {
            revert ErrUnauthorized(msg.sig, RoleAccess.ADMIN);
        }
    }
}

enum ContractType {
    UNKNOWN, // 0
    PAUSE_ENFORCER, // 1
    BRIDGE, // 2
    BRIDGE_TRACKING, // 3
    GOVERNANCE_ADMIN, // 4
    MAINTENANCE, // 5
    SLASH_INDICATOR, // 6
    STAKING_VESTING, // 7
    VALIDATOR, // 8
    STAKING, // 9
    RONIN_TRUSTED_ORGANIZATION, // 10
    BRIDGE_MANAGER, // 11
    BRIDGE_SLASH, // 12
    BRIDGE_REWARD, // 13
    FAST_FINALITY_TRACKING, // 14
    PROFILE // 15

}

interface IHasContracts {
    /// @dev Error of invalid role.
    error ErrContractTypeNotFound(ContractType contractType);

    /// @dev Emitted when a contract is updated.
    event ContractUpdated(ContractType indexed contractType, address indexed addr);

    /**
     * @dev Returns the address of a contract with a specific role.
     * Throws an error if no contract is set for the specified role.
     *
     * @param contractType The role of the contract to retrieve.
     * @return contract_ The address of the contract with the specified role.
     */
    function getContract(ContractType contractType) external view returns (address contract_);

    /**
     * @dev Sets the address of a contract with a specific role.
     * Emits the event {ContractUpdated}.
     * @param contractType The role of the contract to set.
     * @param addr The address of the contract to set.
     */
    function setContract(ContractType contractType, address addr) external;
}

/**
 * @dev Error indicating that the caller is unauthorized to perform a specific function.
 * @param msgSig The function signature (bytes4).
 * @param expectedContractType The contract type required to perform the function.
 * @param actual The actual address that called to the function.
 */
error ErrUnexpectedInternalCall(bytes4 msgSig, ContractType expectedContractType, address actual);

/**
 * @title HasContracts
 * @dev A contract that provides functionality to manage multiple contracts with different roles.
 */
abstract contract HasContracts is HasProxyAdmin, IHasContracts, IdentityGuard {
    /// @dev value is equal to keccak256("@ronin.dpos.collections.HasContracts.slot") - 1
    bytes32 private constant _STORAGE_SLOT = 0xdea3103d22025c269050bea94c0c84688877f12fa22b7e6d2d5d78a9a49aa1cb;

    /**
     * @dev Modifier to restrict access to functions only to contracts with a specific role.
     * @param contractType The contract type that allowed to call
     */
    modifier onlyContract(ContractType contractType) virtual {
        _requireContract(contractType);
        _;
    }

    /**
     * @inheritdoc IHasContracts
     */
    function setContract(ContractType contractType, address addr) external virtual onlyProxyAdmin {
        _requireHasCode(addr);
        _setContract(contractType, addr);
    }

    /**
     * @inheritdoc IHasContracts
     */
    function getContract(ContractType contractType) public view returns (address contract_) {
        contract_ = _getContractMap()[uint8(contractType)];
        if (contract_ == address(0)) {
            revert ErrContractTypeNotFound(contractType);
        }
    }

    /**
     * @dev Internal function to set the address of a contract with a specific role.
     * @param contractType The contract type of the contract to set.
     * @param addr The address of the contract to set.
     */
    function _setContract(ContractType contractType, address addr) internal virtual {
        _getContractMap()[uint8(contractType)] = addr;
        emit ContractUpdated(contractType, addr);
    }

    /**
     * @dev Internal function to access the mapping of contract addresses with roles.
     * @return contracts_ The mapping of contract addresses with roles.
     */
    function _getContractMap() private pure returns (mapping(uint8 => address) storage contracts_) {
        assembly {
            contracts_.slot := _STORAGE_SLOT
        }
    }

    /**
     * @dev Internal function to check if the calling contract has a specific role.
     * @param contractType The contract type that the calling contract must have.
     * @dev Throws an error if the calling contract does not have the specified role.
     */
    function _requireContract(ContractType contractType) private view {
        if (msg.sender != getContract(contractType)) {
            revert ErrUnexpectedInternalCall(msg.sig, contractType, msg.sender);
        }
    }
}

/**
 * @dev Error indicating that the provided threshold is invalid for a specific function signature.
 * @param msgSig The function signature (bytes4) that the invalid threshold applies to.
 */
error ErrInvalidThreshold(bytes4 msgSig);

abstract contract BridgeManagerQuorum is IQuorum, IdentityGuard, Initializable, HasContracts {
    struct BridgeManagerQuorumStorage {
        uint256 _nonce;
        uint256 _numerator;
        uint256 _denominator;
    }

    // keccak256(abi.encode(uint256(keccak256("ronin.storage.BridgeManagerQuorumStorage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant $$_BridgeManagerQuorumStorage =
        0xf3019750f3837257cd40d215c9cc111e92586d2855a1e7e25d959613ed013f00;

    function __BridgeManagerQuorum_init_unchained(uint256 num, uint256 denom) internal onlyInitializing {
        BridgeManagerQuorumStorage storage $ = _getBridgeManagerQuorumStorage();
        $._nonce = 1;

        _setThreshold(num, denom);
    }

    function _getBridgeManagerQuorumStorage() private pure returns (BridgeManagerQuorumStorage storage $) {
        assembly {
            $.slot := $$_BridgeManagerQuorumStorage
        }
    }

    /**
     * @inheritdoc IQuorum
     */
    function setThreshold(uint256 num, uint256 denom) external override onlyProxyAdmin {
        _setThreshold(num, denom);
    }

    /**
     * @inheritdoc IQuorum
     */
    function getThreshold() public view virtual returns (uint256 num, uint256 denom) {
        BridgeManagerQuorumStorage storage $ = _getBridgeManagerQuorumStorage();
        return ($._numerator, $._denominator);
    }

    /**
     * @inheritdoc IQuorum
     */
    function checkThreshold(uint256 voteWeight) external view virtual returns (bool) {
        BridgeManagerQuorumStorage storage $ = _getBridgeManagerQuorumStorage();

        return voteWeight * $._denominator >= $._numerator * _totalWeight();
    }

    /**
     * @dev Sets threshold and returns the old one.
     *
     * Emits the `ThresholdUpdated` event.
     *
     */
    function _setThreshold(uint256 num, uint256 denom) internal virtual {
        if (num > denom || denom <= 1) {
            revert ErrInvalidThreshold(msg.sig);
        }

        BridgeManagerQuorumStorage storage $ = _getBridgeManagerQuorumStorage();

        uint256 prevNum = $._numerator;
        uint256 prevDenom = $._denominator;

        $._numerator = num;
        $._denominator = denom;

        emit ThresholdUpdated($._nonce++, num, denom, prevNum, prevDenom);
    }

    function _totalWeight() internal view virtual returns (uint256);
}

interface IBridgeManagerCallbackRegister {
    error ErrExistOneInternalCallFailed(address sender, bytes4 msgSig, bytes callData);

    event CallbackRegistered(address, bool);
    /**
     * @dev Emitted when the contract notifies multiple registers with statuses and return data.
     */
    event Notified(bytes callData, address[] registers, bool[] statuses, bytes[] returnDatas);

    /**
     * @dev Retrieves the addresses of registered callbacks.
     * @return registers An array containing the addresses of registered callbacks.
     */
    function getCallbackRegisters() external view returns (address[] memory registers);

    /**
     * @dev Registers multiple callbacks with the bridge.
     * @param registers The array of callback addresses to register.
     */
    function registerCallbacks(address[] calldata registers) external;

    /**
     * @dev Unregisters multiple callbacks from the bridge.
     * @param registers The array of callback addresses to unregister.
     */
    function unregisterCallbacks(address[] calldata registers) external;
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

/**
 * @title IBridgeManagerCallback
 * @dev Interface for the callback functions to be implemented by the Bridge Manager contract.
 */
interface IBridgeManagerCallback is IERC165 {
    /**
     * @dev Handles the event when bridge operators are added.
     * @param bridgeOperators The addresses of the bridge operators.
     * @param addeds The corresponding boolean values indicating whether the operators were added or not.
     * @return selector The selector of the function being called.
     */
    function onBridgeOperatorsAdded(address[] memory bridgeOperators, uint96[] calldata weights, bool[] memory addeds)
        external
        returns (bytes4 selector);

    /**
     * @dev Handles the event when bridge operators are removed.
     * @param bridgeOperators The addresses of the bridge operators.
     * @param removeds The corresponding boolean values indicating whether the operators were removed or not.
     * @return selector The selector of the function being called.
     */
    function onBridgeOperatorsRemoved(address[] memory bridgeOperators, bool[] memory removeds)
        external
        returns (bytes4 selector);
}

/**
 * @title BridgeManagerCallbackRegister
 * @dev A contract that manages callback registrations and execution for a bridge.
 */
abstract contract BridgeManagerCallbackRegister is
    IBridgeManagerCallbackRegister,
    IdentityGuard,
    Initializable,
    HasContracts
{
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @dev Storage slot for the address set of callback registers.
     * @dev Value is equal to keccak256("@ronin.dpos.gateway.BridgeAdmin.callbackRegisters.slot") - 1.
     */
    bytes32 private constant CALLBACK_REGISTERS_SLOT =
        0x5da136eb38f8d8e354915fc8a767c0dc81d49de5fb65d5477122a82ddd976240;

    function __BridgeManagerCallbackRegister_init_unchained(address[] memory callbackRegisters)
        internal
        onlyInitializing
    {
        _registerCallbacks(callbackRegisters);
    }

    /**
     * @inheritdoc IBridgeManagerCallbackRegister
     */
    function registerCallbacks(address[] calldata registers) external onlyProxyAdmin {
        _registerCallbacks(registers);
    }

    /**
     * @inheritdoc IBridgeManagerCallbackRegister
     */
    function unregisterCallbacks(address[] calldata registers) external onlyProxyAdmin nonDuplicate(registers) {
        EnumerableSet.AddressSet storage _callbackRegisters = _getCallbackRegisters();

        for (uint256 i; i < registers.length; i++) {
            _callbackRegisters.remove(registers[i]);
        }
    }

    /**
     * @inheritdoc IBridgeManagerCallbackRegister
     */
    function getCallbackRegisters() external view returns (address[] memory registers) {
        registers = _getCallbackRegisters().values();
    }

    /**
     * @dev Internal function to register multiple callbacks with the bridge.
     * @param registers The array of callback addresses to register.
     */
    function _registerCallbacks(address[] memory registers) internal nonDuplicate(registers) {
        EnumerableSet.AddressSet storage _callbackRegisters = _getCallbackRegisters();
        address register;
        bool regSuccess;

        for (uint256 i; i < registers.length; i++) {
            register = registers[i];

            _requireHasCode(register);
            _requireSupportsInterface(register, type(IBridgeManagerCallback).interfaceId);

            regSuccess = _callbackRegisters.add(register);

            emit CallbackRegistered(register, regSuccess);
        }
    }

    /**
     * @dev Same as {_notifyRegistersUnsafe} but revert when there at least one failed internal call.
     */
    function _notifyRegisters(bytes4 callbackFnSig, bytes memory inputs) internal {
        if (!_notifyRegistersUnsafe(callbackFnSig, inputs)) {
            revert ErrExistOneInternalCallFailed(msg.sender, callbackFnSig, inputs);
        }
    }

    /**
     * @dev Internal function to notify all registered callbacks with the provided function signature and data.
     * @param callbackFnSig The function signature of the callback method.
     * @param inputs The data to pass to the callback method.
     * @return allSuccess Return true if all internal calls are success
     */
    function _notifyRegistersUnsafe(bytes4 callbackFnSig, bytes memory inputs) internal returns (bool allSuccess) {
        allSuccess = true;

        address[] memory registers = _getCallbackRegisters().values();
        uint256 length = registers.length;
        if (length == 0) {
            return allSuccess;
        }

        bool[] memory successes = new bool[](length);
        bytes[] memory returnDatas = new bytes[](length);
        bytes memory callData = abi.encodePacked(callbackFnSig, inputs);
        bytes memory proxyCallData = abi.encodeCall(TransparentUpgradeableProxyV2.functionDelegateCall, (callData));

        for (uint256 i; i < length; i++) {
            // First, attempt to call normally
            (successes[i], returnDatas[i]) = registers[i].call(callData);

            // If cannot call normally, attempt to call as the recipient is the proxy, and this caller is its admin.
            if (!successes[i]) {
                (successes[i], returnDatas[i]) = registers[i].call(proxyCallData);
                allSuccess = allSuccess && successes[i];
            }
        }

        emit Notified(callData, registers, successes, returnDatas);
    }

    /**
     * @dev Internal function to retrieve the address set of callback registers.
     * @return callbackRegisters The storage reference to the callback registers.
     */
    function _getCallbackRegisters() internal pure returns (EnumerableSet.AddressSet storage callbackRegisters) {
        assembly ("memory-safe") {
            callbackRegisters.slot := CALLBACK_REGISTERS_SLOT
        }
    }
}

/**
 * @dev Error indicating a mismatch in the length of input parameters or arrays for a specific function.
 * @param msgSig The function signature (bytes4) that has a length mismatch.
 */
error ErrLengthMismatch(bytes4 msgSig);

/**
 * @dev Error indicating that a vote weight is invalid for a specific function signature.
 * @param msgSig The function signature (bytes4) that encountered an invalid vote weight.
 */
error ErrInvalidVoteWeight(bytes4 msgSig);

abstract contract BridgeManager is IBridgeManager, BridgeManagerQuorum, BridgeManagerCallbackRegister {
    using AddressArrayUtils for address[];

    struct BridgeManagerStorage {
        /// @notice List of the governors.
        /// @dev We do not use EnumerableSet here to maintain identical order of `governors` and `operators`. If `.contains` is needed, use the corresponding weight mapping.
        address[] _governors;
        address[] _operators;
        /// @dev Mapping from address to the governor weight
        mapping(address governor => uint96 weight) _governorWeight;
        /// @dev Mapping from address to the operator weight. This must always be identical `_governorWeight`.
        mapping(address operator => uint96 weight) _operatorWeight;
        /// @dev Total weight of all governors / operators.
        uint256 _totalWeight;
        /// @dev The minimum number of governors that must exist in the contract, to avoid the contract become non-accessible.
        uint256 _minRequiredGovernor;
    }

    // keccak256(abi.encode(uint256(keccak256("ronin.storage.BridgeManagerStorageLocation")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant $$_BridgeManagerStorageLocation =
        0xc648703095712c0419b6431ae642c061f0a105ac2d7c3d9604061ef4ebc38300;

    /**
     * @inheritdoc IBridgeManager
     */
    bytes32 public DOMAIN_SEPARATOR;

    modifier onlyGovernor() virtual {
        _requireGovernor(msg.sender);
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function __BridgeManager_init(
        uint256 num,
        uint256 denom,
        uint256 roninChainId,
        address bridgeContract,
        address[] memory callbackRegisters,
        address[] memory bridgeOperators,
        address[] memory governors,
        uint96[] memory voteWeights
    ) internal onlyInitializing {
        __BridgeManagerQuorum_init_unchained(num, denom);
        __BridgeManagerCallbackRegister_init_unchained(callbackRegisters);
        __BridgeManager_init_unchained(roninChainId, bridgeContract, bridgeOperators, governors, voteWeights);
    }

    function __BridgeManager_init_unchained(
        uint256 roninChainId,
        address bridgeContract,
        address[] memory bridgeOperators,
        address[] memory governors,
        uint96[] memory voteWeights
    ) internal onlyInitializing {
        _setContract(ContractType.BRIDGE, bridgeContract);

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,bytes32 salt)"),
                keccak256("BridgeManager"), // name hash
                keccak256("3"), // version hash
                keccak256(abi.encode("BRIDGE_MANAGER", roninChainId)) // salt
            )
        );

        _addBridgeOperators(voteWeights, governors, bridgeOperators);
        _setMinRequiredGovernor(3);
    }

    function _getBridgeManagerStorage() private pure returns (BridgeManagerStorage storage $) {
        assembly {
            $.slot := $$_BridgeManagerStorageLocation
        }
    }

    // ===================== CONFIG ========================

    /**
     * @inheritdoc IHasContracts
     */
    function setContract(ContractType contractType, address addr) external override onlyProxyAdmin {
        _requireHasCode(addr);
        _setContract(contractType, addr);
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function setMinRequiredGovernor(uint256 min) external override onlyProxyAdmin {
        _setMinRequiredGovernor(min);
    }

    function _setMinRequiredGovernor(uint256 min) internal {
        if (min < 3) {
            revert ErrInvalidInput();
        }
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();
        $._minRequiredGovernor = min;
        emit MinRequiredGovernorUpdated(min);
    }

    /**
     * @dev Internal function to require that the caller has governor role access.
     */
    function _requireGovernor(address addr) internal view {
        if (_getGovernorWeight(addr) == 0) {
            revert ErrUnauthorized(msg.sig, RoleAccess.GOVERNOR);
        }
    }

    // ===================== WEIGHTS METHOD ========================

    /**
     * @inheritdoc IBridgeManager
     */
    function getTotalWeight() public view returns (uint256) {
        return _totalWeight();
    }

    function _totalWeight() internal view override returns (uint256) {
        return _getBridgeManagerStorage()._totalWeight;
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function getGovernorWeights(address[] calldata governors) external view returns (uint96[] memory weights) {
        weights = _getGovernorWeights(governors);
    }

    /**
     * @dev Internal function to get the vote weights of a given array of governors.
     */
    function _getGovernorWeights(address[] memory governors) internal view returns (uint96[] memory weights) {
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();
        weights = new uint96[](governors.length);

        for (uint256 i; i < governors.length; i++) {
            weights[i] = $._governorWeight[governors[i]];
        }
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function getGovernorWeight(address governor) external view returns (uint96 weight) {
        weight = _getGovernorWeight(governor);
    }

    /**
     * @dev Internal function to retrieve the vote weight of a specific governor.
     */
    function _getGovernorWeight(address governor) internal view returns (uint96) {
        return _getBridgeManagerStorage()._governorWeight[governor];
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function sumGovernorsWeight(address[] calldata governors)
        external
        view
        nonDuplicate(governors)
        returns (uint256 sum)
    {
        sum = _sumGovernorsWeight(governors);
    }

    /**
     * @dev Internal function to calculate the sum of vote weights for a given array of governors.
     * @param governors The non-duplicated input.
     */
    function _sumGovernorsWeight(address[] memory governors)
        internal
        view
        nonDuplicate(governors)
        returns (uint256 sum)
    {
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();

        for (uint256 i; i < governors.length; i++) {
            sum += $._governorWeight[governors[i]];
        }
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function getBridgeOperatorWeight(address bridgeOperator) external view returns (uint96 weight) {
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();

        return $._operatorWeight[bridgeOperator];
    }

    /**
     * @inheritdoc IQuorum
     */
    function minimumVoteWeight() public view virtual returns (uint256) {
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();

        (uint256 numerator, uint256 denominator) = getThreshold();
        return (numerator * $._totalWeight + denominator - 1) / denominator;
    }

    // ===================== MANAGER CRUD ========================

    /**
     * @inheritdoc IBridgeManager
     */
    function addBridgeOperators(
        uint96[] calldata voteWeights,
        address[] calldata governors,
        address[] calldata bridgeOperators
    ) external onlyProxyAdmin {
        _addBridgeOperators(voteWeights, governors, bridgeOperators);
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function removeBridgeOperators(address[] calldata bridgeOperators) external onlyProxyAdmin {
        _removeBridgeOperators(bridgeOperators);
    }

    /**
     * @dev Internal function to add bridge operators.
     *
     * This function adds the specified `bridgeOperators` to the bridge operator set and establishes the associated mappings.
     *
     * Requirements:
     * - The caller must have the necessary permission to add bridge operators.
     * - The lengths of `voteWeights`, `governors`, and `bridgeOperators` arrays must be equal.
     *
     * @return addeds An array of boolean values indicating whether each bridge operator was successfully added.
     */
    function _addBridgeOperators(
        uint96[] memory voteWeights,
        address[] memory newGovernors,
        address[] memory newOperators
    ) internal nonDuplicate(newGovernors.extend(newOperators)) returns (bool[] memory addeds) {
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();

        uint256 length = newOperators.length;
        if (!(length == voteWeights.length && length == newGovernors.length)) {
            revert ErrLengthMismatch(msg.sig);
        }
        addeds = new bool[](length);

        // simply skip add operations if inputs are empty.
        if (length == 0) {
            return addeds;
        }

        address iGovernor;
        address iOperator;
        uint96 iVoteWeight;
        uint256 accumulatedWeight;

        for (uint256 i; i < length; i++) {
            iGovernor = newGovernors[i];
            iOperator = newOperators[i];
            iVoteWeight = voteWeights[i];

            // Check non-zero inputs
            _requireNonZeroAddress(iGovernor);
            _requireNonZeroAddress(iOperator);
            if (iVoteWeight == 0) {
                revert ErrInvalidVoteWeight(msg.sig);
            }

            // Check not yet added operators
            addeds[i] = (
                $._governorWeight[iGovernor] + $._governorWeight[iOperator] + $._operatorWeight[iOperator]
                    + $._operatorWeight[iGovernor]
            ) == 0;

            // Only add the valid operator
            if (addeds[i]) {
                // Add governor to list, update governor weight
                $._governors.push(iGovernor);
                $._governorWeight[iGovernor] = iVoteWeight;

                // Add operator to list, update governor weight
                $._operators.push(iOperator);
                $._operatorWeight[iOperator] = iVoteWeight;

                accumulatedWeight += iVoteWeight;
            }
        }

        $._totalWeight += accumulatedWeight;

        _notifyRegisters(
            IBridgeManagerCallback.onBridgeOperatorsAdded.selector, abi.encode(newOperators, voteWeights, addeds)
        );

        emit BridgeOperatorsAdded(addeds, voteWeights, newGovernors, newOperators);
    }

    /**
     * @dev Internal function to remove bridge operators.
     *
     * This function removes the specified `bridgeOperators` from the bridge operator set and related mappings.
     *
     * Requirements:
     * - The caller must have the necessary permission to remove bridge operators.
     *
     * @param removingOperators An array of addresses representing the bridge operators to be removed.
     * @return removeds An array of boolean values indicating whether each bridge operator was successfully removed.
     */
    function _removeBridgeOperators(address[] memory removingOperators)
        internal
        nonDuplicate(removingOperators)
        returns (bool[] memory removeds)
    {
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();

        uint256 length = removingOperators.length;
        removeds = new bool[](length);

        // simply skip remove operations if inputs are empty.
        if (length == 0) {
            return removeds;
        }
        if ($._governors.length - length < $._minRequiredGovernor) {
            revert ErrBelowMinRequiredGovernors();
        }

        address iGovernor;
        address iOperator;
        uint256 accumulatedWeight;
        uint256 idx;

        for (uint256 i; i < length; i++) {
            iOperator = removingOperators[i];

            // Check non-zero inputs
            (iGovernor, idx) = _getGovernorOf(iOperator);
            _requireNonZeroAddress(iGovernor);
            _requireNonZeroAddress(iOperator);

            // Check existing operators
            removeds[i] = $._governorWeight[iGovernor] > 0 && $._operatorWeight[iOperator] > 0;

            // Only remove the valid operator
            if (removeds[i]) {
                uint256 removingVoteWeight = $._governorWeight[iGovernor];

                // Remove governor from list, update governor weight
                uint256 lastIdx = $._governors.length - 1;
                $._governors[idx] = $._governors[lastIdx];
                $._governors.pop();
                delete $._governorWeight[iGovernor];

                // Remove operator from list, update operator weight
                $._operators[idx] = $._operators[lastIdx];
                $._operators.pop();
                delete $._operatorWeight[iOperator];

                accumulatedWeight += removingVoteWeight;
            }
        }

        $._totalWeight -= accumulatedWeight;

        _notifyRegisters(
            IBridgeManagerCallback.onBridgeOperatorsRemoved.selector, abi.encode(removingOperators, removeds)
        );

        emit BridgeOperatorsRemoved(removeds, removingOperators);
    }

    function _findInArray(address[] storage $_array, address addr) internal view returns (bool found, uint256 idx) {
        for (uint256 i; i < $_array.length; i++) {
            if (addr == $_array[i]) {
                return (true, i);
            }
        }

        return (false, type(uint256).max);
    }

    // ================= MANAGER VIEW METHODS =============

    /**
     * @inheritdoc IBridgeManager
     */
    function totalBridgeOperator() external view returns (uint256) {
        return _getBridgeManagerStorage()._operators.length;
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function isBridgeOperator(address addr) external view returns (bool) {
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();
        return $._operatorWeight[addr] > 0;
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function getBridgeOperators() external view returns (address[] memory) {
        return _getBridgeManagerStorage()._operators;
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function getGovernors() external view returns (address[] memory) {
        return _getBridgeManagerStorage()._governors;
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function getOperatorOf(address governor) external view returns (address operator) {
        (bool found, uint256 idx) = _findInArray(_getBridgeManagerStorage()._governors, governor);
        if (!found) {
            revert ErrGovernorNotFound(governor);
        }

        return _getBridgeManagerStorage()._operators[idx];
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function getGovernorOf(address operator) external view returns (address governor) {
        (governor,) = _getGovernorOf(operator);
    }

    function _getGovernorOf(address operator) internal view returns (address governor, uint256 idx) {
        (bool found, uint256 foundId) = _findInArray(_getBridgeManagerStorage()._operators, operator);
        if (!found) {
            revert ErrOperatorNotFound(operator);
        }

        return (_getBridgeManagerStorage()._governors[foundId], foundId);
    }

    /**
     * @inheritdoc IBridgeManager
     */
    function getFullBridgeOperatorInfos()
        external
        view
        returns (address[] memory governors, address[] memory bridgeOperators, uint96[] memory weights)
    {
        BridgeManagerStorage storage $ = _getBridgeManagerStorage();

        governors = $._governors;
        bridgeOperators = $._operators;
        weights = _getGovernorWeights(governors);
    }
}

interface SignatureConsumer {
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}

interface VoteStatusConsumer {
    enum VoteStatus {
        Pending,
        Approved,
        Executed,
        Rejected,
        Expired
    }
}

interface ChainTypeConsumer {
    enum ChainType {
        RoninChain,
        Mainchain
    }
}

/**
 * @dev Error indicating that the chain ID is invalid.
 * @param msgSig The function signature (bytes4) of the operation that encountered an invalid chain ID.
 * @param actual Current chain ID that executing function.
 * @param expected Expected chain ID required for the tx to success.
 */
error ErrInvalidChainId(bytes4 msgSig, uint256 actual, uint256 expected);

library Proposal {
    /**
     * @dev Error thrown when there is insufficient gas to execute a function.
     */
    error ErrInsufficientGas(bytes32 proposalHash);

    /**
     * @dev Error thrown when an invalid expiry timestamp is provided.
     */
    error ErrInvalidExpiryTimestamp();

    /**
     * @dev Error thrown when the proposal reverts when execute the internal call no. `callIndex` with revert message is `revertMsg`.
     */
    error ErrLooseProposalInternallyRevert(uint256 callIndex, bytes revertMsg);

    struct ProposalDetail {
        // Nonce to make sure proposals are executed in order
        uint256 nonce;
        // Value 0: all chain should run this proposal
        // Other values: only specific chain has to execute
        uint256 chainId;
        uint256 expiryTimestamp;
        // The address that execute the proposal after the proposal passes.
        // Leave this address as address(0) to auto-execute by the last valid vote.
        address executor;
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        uint256[] gasAmounts;
    }

    // keccak256("ProposalDetail(uint256 nonce,uint256 chainId,uint256 expiryTimestamp,address executor,address[] targets,uint256[] values,bytes[] calldatas,uint256[] gasAmounts)");
    bytes32 internal constant TYPE_HASH = 0x1b59eeec7c321899dc1e7a5b3d876c9a445dffc6d2f96ba842d7489908fdee12;

    /**
     * @dev Validates the proposal.
     */
    function validate(ProposalDetail memory proposal, uint256 maxExpiryDuration) internal view {
        if (
            !(
                proposal.targets.length > 0 && proposal.targets.length == proposal.values.length
                    && proposal.targets.length == proposal.calldatas.length
                    && proposal.targets.length == proposal.gasAmounts.length
            )
        ) {
            revert ErrLengthMismatch(msg.sig);
        }

        if (proposal.expiryTimestamp > block.timestamp + maxExpiryDuration) {
            revert ErrInvalidExpiryTimestamp();
        }
    }

    /**
     * @dev Returns struct hash of the proposal.
     */
    function hash(ProposalDetail memory proposal) internal pure returns (bytes32 digest_) {
        uint256[] memory values = proposal.values;
        address[] memory targets = proposal.targets;
        bytes32[] memory calldataHashList = new bytes32[](proposal.calldatas.length);
        uint256[] memory gasAmounts = proposal.gasAmounts;

        for (uint256 i; i < calldataHashList.length; ++i) {
            calldataHashList[i] = keccak256(proposal.calldatas[i]);
        }

        // return
        //   keccak256(
        //     abi.encode(
        //       TYPE_HASH,
        //       proposal.nonce,
        //       proposal.chainId,
        //       proposal.expiryTimestamp
        //       proposal.executor
        //       targetsHash,
        //       valuesHash,
        //       calldatasHash,
        //       gasAmountsHash
        //     )
        //   );
        // /
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, TYPE_HASH)
            mstore(add(ptr, 0x20), mload(proposal)) // proposal.nonce
            mstore(add(ptr, 0x40), mload(add(proposal, 0x20))) // proposal.chainId
            mstore(add(ptr, 0x60), mload(add(proposal, 0x40))) // proposal.expiryTimestamp
            mstore(add(ptr, 0x80), mload(add(proposal, 0x60))) // proposal.executor

            let arrayHashed
            arrayHashed := keccak256(add(targets, 32), mul(mload(targets), 32)) // targetsHash
            mstore(add(ptr, 0xa0), arrayHashed)
            arrayHashed := keccak256(add(values, 32), mul(mload(values), 32)) // valuesHash
            mstore(add(ptr, 0xc0), arrayHashed)
            arrayHashed := keccak256(add(calldataHashList, 32), mul(mload(calldataHashList), 32)) // calldatasHash
            mstore(add(ptr, 0xe0), arrayHashed)
            arrayHashed := keccak256(add(gasAmounts, 32), mul(mload(gasAmounts), 32)) // gasAmountsHash
            mstore(add(ptr, 0x100), arrayHashed)
            digest_ := keccak256(ptr, 0x120)
        }
    }

    /**
     * @dev Returns whether the proposal is auto-executed on the last valid vote.
     */
    function isAutoExecute(ProposalDetail memory proposal) internal pure returns (bool) {
        return proposal.executor == address(0);
    }

    /**
     * @dev Returns whether the proposal is executable for the current chain.
     *
     * @notice Does not check whether the call result is successful or not. Please use `execute` instead.
     *
     */
    function executable(ProposalDetail memory proposal) internal view returns (bool result) {
        return proposal.chainId == 0 || proposal.chainId == block.chainid;
    }

    /**
     * @dev Executes the proposal.
     */
    function execute(ProposalDetail memory proposal)
        internal
        returns (bool[] memory successCalls, bytes[] memory returnDatas)
    {
        if (!executable(proposal)) {
            revert ErrInvalidChainId(msg.sig, proposal.chainId, block.chainid);
        }

        successCalls = new bool[](proposal.targets.length);
        returnDatas = new bytes[](proposal.targets.length);
        for (uint256 i = 0; i < proposal.targets.length; ++i) {
            if (gasleft() <= proposal.gasAmounts[i]) {
                revert ErrInsufficientGas(hash(proposal));
            }

            (successCalls[i], returnDatas[i]) =
                proposal.targets[i].call{value: proposal.values[i], gas: proposal.gasAmounts[i]}(proposal.calldatas[i]);

            if (!successCalls[i]) {
                revert ErrLooseProposalInternallyRevert(i, returnDatas[i]);
            }
        }
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

library Ballot {
    using ECDSA for bytes32;

    enum VoteType {
        For,
        Against
    }

    // keccak256("Ballot(bytes32 proposalHash,uint8 support)");
    bytes32 private constant BALLOT_TYPEHASH = 0xd900570327c4c0df8dd6bdd522b7da7e39145dd049d2fd4602276adcd511e3c2;

    function hash(bytes32 _proposalHash, VoteType _support) internal pure returns (bytes32 digest) {
        // return keccak256(abi.encode(BALLOT_TYPEHASH, _proposalHash, _support));
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, BALLOT_TYPEHASH)
            mstore(add(ptr, 0x20), _proposalHash)
            mstore(add(ptr, 0x40), _support)
            digest := keccak256(ptr, 0x60)
        }
    }
}

/**
 * @dev Error indicating that the proposal nonce is invalid.
 * @param msgSig The function signature (bytes4) of the operation that encountered an invalid proposal nonce.
 */
error ErrInvalidProposalNonce(bytes4 msgSig);

/**
 * @dev Error indicating that a voter has already voted.
 * @param voter The address of the voter who has already voted.
 */
error ErrAlreadyVoted(address voter);

/**
 * @dev Error indicating that a vote type is not supported.
 * @param msgSig The function signature (bytes4) of the operation that encountered an unsupported vote type.
 */
error ErrUnsupportedVoteType(bytes4 msgSig);

/**
 * @dev Error thrown when an invalid proposal is encountered.
 * @param actual The actual value of the proposal.
 * @param expected The expected value of the proposal.
 */
error ErrInvalidProposal(bytes32 actual, bytes32 expected);

/**
 * @dev Error of proposal is not approved for executing.
 */
error ErrProposalNotApproved();

/**
 * @dev Error of the caller is not the specified executor.
 */
error ErrInvalidExecutor();

abstract contract CoreGovernance is Initializable, SignatureConsumer, VoteStatusConsumer, ChainTypeConsumer {
    using Proposal for Proposal.ProposalDetail;

    /**
     * @dev Error thrown when attempting to interact with a finalized vote.
     */
    error ErrVoteIsFinalized();

    /**
     * @dev Error thrown when the current proposal is not completed.
     */
    error ErrCurrentProposalIsNotCompleted();

    struct ProposalVote {
        VoteStatus status;
        bytes32 hash;
        uint256 againstVoteWeight; // Total weight of against votes
        uint256 forVoteWeight; // Total weight of for votes
        address[] forVoteds; // Array of addresses voting for
        address[] againstVoteds; // Array of addresses voting against
        uint256 expiryTimestamp;
        mapping(address => Signature) sig;
        mapping(address => bool) voted;
    }

    /// @dev Emitted when a proposal is created
    event ProposalCreated(
        uint256 indexed chainId,
        uint256 indexed round,
        bytes32 indexed proposalHash,
        Proposal.ProposalDetail proposal,
        address creator
    );
    /// @dev Emitted when the proposal is voted
    event ProposalVoted(bytes32 indexed proposalHash, address indexed voter, Ballot.VoteType support, uint256 weight);
    /// @dev Emitted when the proposal is approved
    event ProposalApproved(bytes32 indexed proposalHash);
    /// @dev Emitted when the vote is reject
    event ProposalRejected(bytes32 indexed proposalHash);
    /// @dev Emitted when the vote is expired
    event ProposalExpired(bytes32 indexed proposalHash);
    /// @dev Emitted when the proposal is executed
    event ProposalExecuted(bytes32 indexed proposalHash, bool[] successCalls, bytes[] returnDatas);
    /// @dev Emitted when the proposal expiry duration is changed.
    event ProposalExpiryDurationChanged(uint256 indexed duration);

    /// @dev Mapping from chain id => vote round
    /// @notice chain id = 0 for global proposal
    mapping(uint256 => uint256) public round;
    /// @dev Mapping from chain id => vote round => proposal vote
    mapping(uint256 => mapping(uint256 => ProposalVote)) public vote;

    uint256 internal _proposalExpiryDuration;

    function __CoreGovernance_init(uint256 expiryDuration) internal onlyInitializing {
        __CoreGovernance_init_unchained(expiryDuration);
    }

    function __CoreGovernance_init_unchained(uint256 expiryDuration) internal onlyInitializing {
        _setProposalExpiryDuration(expiryDuration);
    }

    /**
     * @dev Creates new voting round by calculating the `_round` number of chain `_chainId`.
     * Increases the `_round` number if the previous one is not expired. Delete the previous proposal
     * if it is expired and not increase the `_round`.
     */
    function _createVotingRound(uint256 _chainId) internal returns (uint256 _round) {
        _round = round[_chainId];
        // Skip checking for the first ever round
        if (_round == 0) {
            _round = round[_chainId] = 1;
        } else {
            ProposalVote storage _latestProposalVote = vote[_chainId][_round];
            bool _isExpired = _tryDeleteExpiredVotingRound(_latestProposalVote);
            // Skip increasing round number if the latest round is expired, allow the vote to be overridden
            if (!_isExpired) {
                if (_latestProposalVote.status == VoteStatus.Pending) {
                    revert ErrCurrentProposalIsNotCompleted();
                }
                unchecked {
                    _round = ++round[_chainId];
                }
            }
        }
    }

    /**
     * @dev Saves new round voting for the proposal `_proposalHash` of chain `_chainId`.
     */
    function _saveVotingRound(ProposalVote storage _vote, bytes32 _proposalHash, uint256 _expiryTimestamp) internal {
        _vote.hash = _proposalHash;
        _vote.expiryTimestamp = _expiryTimestamp;
    }

    /**
     * @dev Proposes proposal struct.
     *
     * Requirements:
     * - The chain id is not equal to 0.
     * - The proposal nonce is equal to the new round.
     *
     * Emits the `ProposalCreated` event.
     *
     */
    function _proposeProposalStruct(Proposal.ProposalDetail memory proposal, address creator)
        internal
        virtual
        returns (uint256 round_)
    {
        uint256 chainId = proposal.chainId;
        if (chainId == 0) {
            revert ErrInvalidChainId(msg.sig, 0, block.chainid);
        }
        proposal.validate(_proposalExpiryDuration);

        bytes32 proposalHash = proposal.hash();
        round_ = _createVotingRound(chainId);
        _saveVotingRound(vote[chainId][round_], proposalHash, proposal.expiryTimestamp);
        if (round_ != proposal.nonce) {
            revert ErrInvalidProposalNonce(msg.sig);
        }
        emit ProposalCreated(chainId, round_, proposalHash, proposal, creator);
    }

    /**
     * @dev Casts vote for the proposal with data and returns whether the voting is done.
     *
     * Requirements:
     * - The proposal nonce is equal to the round.
     * - The vote is not finalized.
     * - The voter has not voted for the round.
     *
     * Emits the `ProposalVoted` event. Emits the `ProposalApproved`, `ProposalExecuted` or `ProposalRejected` once the
     * proposal is approved, executed or rejected.
     *
     */
    function _castVote(
        Proposal.ProposalDetail memory proposal,
        Ballot.VoteType support,
        uint256 minimumForVoteWeight,
        uint256 minimumAgainstVoteWeight,
        address voter,
        Signature memory signature,
        uint256 voterWeight
    ) internal virtual returns (bool done) {
        uint256 chainId = proposal.chainId;
        uint256 round_ = proposal.nonce;
        ProposalVote storage _vote = vote[chainId][round_];

        if (_tryDeleteExpiredVotingRound(_vote)) {
            return true;
        }

        if (round[proposal.chainId] != round_) {
            revert ErrInvalidProposalNonce(msg.sig);
        }
        if (_vote.status != VoteStatus.Pending) {
            revert ErrVoteIsFinalized();
        }
        if (_voted(_vote, voter)) {
            revert ErrAlreadyVoted(voter);
        }

        _vote.voted[voter] = true;
        // Stores the signature if it is not empty
        if (signature.r > 0 || signature.s > 0 || signature.v > 0) {
            _vote.sig[voter] = signature;
        }
        emit ProposalVoted(_vote.hash, voter, support, voterWeight);

        uint256 _forVoteWeight;
        uint256 _againstVoteWeight;
        if (support == Ballot.VoteType.For) {
            _vote.forVoteds.push(voter);
            _forVoteWeight = _vote.forVoteWeight += voterWeight;
        } else if (support == Ballot.VoteType.Against) {
            _vote.againstVoteds.push(voter);
            _againstVoteWeight = _vote.againstVoteWeight += voterWeight;
        } else {
            revert ErrUnsupportedVoteType(msg.sig);
        }

        if (_forVoteWeight >= minimumForVoteWeight) {
            done = true;
            _vote.status = VoteStatus.Approved;
            emit ProposalApproved(_vote.hash);
            if (proposal.isAutoExecute()) {
                _tryExecute(_vote, proposal);
            }
        } else if (_againstVoteWeight >= minimumAgainstVoteWeight) {
            done = true;
            _vote.status = VoteStatus.Rejected;
            emit ProposalRejected(_vote.hash);
        }
    }

    /**
     * @dev The specified executor executes the proposal on an approved proposal.
     */
    function _executeWithCaller(Proposal.ProposalDetail memory proposal, address caller) internal {
        bytes32 proposalHash = proposal.hash();
        ProposalVote storage _vote = vote[proposal.chainId][proposal.nonce];

        if (_vote.hash != proposalHash) {
            revert ErrInvalidProposal(proposalHash, _vote.hash);
        }

        if (_vote.status != VoteStatus.Approved) {
            revert ErrProposalNotApproved();
        }
        if (caller != proposal.executor) {
            revert ErrInvalidExecutor();
        }

        _tryExecute(_vote, proposal);
    }

    /**
     * @dev When the contract is on Ronin chain, checks whether the proposal is expired and delete it if is expired.
     *
     * Emits the event `ProposalExpired` if the vote is expired.
     *
     * Note: This function assumes the vote `_proposalVote` is already created, consider verifying the vote's existence
     * before or it will emit an unexpected event of `ProposalExpired`.
     */
    function _tryDeleteExpiredVotingRound(ProposalVote storage proposalVote) internal returns (bool isExpired) {
        isExpired = _getChainType() == ChainType.RoninChain && proposalVote.status == VoteStatus.Pending
            && proposalVote.expiryTimestamp <= block.timestamp;

        if (isExpired) {
            emit ProposalExpired(proposalVote.hash);

            for (uint256 _i; _i < proposalVote.forVoteds.length;) {
                delete proposalVote.voted[proposalVote.forVoteds[_i]];
                delete proposalVote.sig[proposalVote.forVoteds[_i]];

                unchecked {
                    ++_i;
                }
            }
            for (uint256 _i; _i < proposalVote.againstVoteds.length;) {
                delete proposalVote.voted[proposalVote.againstVoteds[_i]];
                delete proposalVote.sig[proposalVote.againstVoteds[_i]];

                unchecked {
                    ++_i;
                }
            }
            delete proposalVote.status;
            delete proposalVote.hash;
            delete proposalVote.againstVoteWeight;
            delete proposalVote.forVoteWeight;
            delete proposalVote.forVoteds;
            delete proposalVote.againstVoteds;
            delete proposalVote.expiryTimestamp;
        }
    }

    /**
     * @dev Executes the proposal and update the vote status once the proposal is executable.
     */
    function _tryExecute(ProposalVote storage vote_, Proposal.ProposalDetail memory proposal) internal {
        if (proposal.executable()) {
            vote_.status = VoteStatus.Executed;
            (bool[] memory _successCalls, bytes[] memory _returnDatas) = proposal.execute();
            emit ProposalExecuted(vote_.hash, _successCalls, _returnDatas);
        }
    }

    /**
     * @dev Sets the expiry duration for a new proposal.
     */
    function _setProposalExpiryDuration(uint256 expiryDuration) internal {
        _proposalExpiryDuration = expiryDuration;
        emit ProposalExpiryDurationChanged(expiryDuration);
    }

    /**
     * @dev Returns whether the voter casted for the proposal.
     */
    function _voted(ProposalVote storage vote_, address voter) internal view returns (bool) {
        return vote_.voted[voter];
    }

    /**
     * @dev Returns total weight from validators.
     */
    function _getTotalWeight() internal view virtual returns (uint256);

    /**
     * @dev Returns minimum vote to pass a proposal.
     */
    function _getMinimumVoteWeight() internal view virtual returns (uint256);

    /**
     * @dev Returns current context is running on whether Ronin chain or on mainchain.
     */
    function _getChainType() internal view virtual returns (ChainType);
}

library GlobalProposal {
    /**
     * @dev Error thrown when attempting to interact with an unsupported target.
     */
    error ErrUnsupportedTarget(bytes32 proposalHash, uint256 targetNumber);

    enum TargetOption {
        BridgeManager, // 0
        GatewayContract, // 1
        BridgeReward, // 2
        BridgeSlash, // 3
        BridgeTracking, // 4
        PauseEnforcer // 5

    }

    struct GlobalProposalDetail {
        // Nonce to make sure proposals are executed in order
        uint256 nonce;
        uint256 expiryTimestamp;
        address executor;
        TargetOption[] targetOptions;
        uint256[] values;
        bytes[] calldatas;
        uint256[] gasAmounts;
    }

    // keccak256("GlobalProposalDetail(uint256 nonce,uint256 expiryTimestamp,address executor,uint8[] targetOptions,uint256[] values,bytes[] calldatas,uint256[] gasAmounts)");
    bytes32 internal constant TYPE_HASH = 0xde480f0c53a3651c08fbab1dffbc45fe574f31188827fe52cb9035da9fe57e4a;

    /**
     * @dev Returns struct hash of the proposal.
     */
    function hash(GlobalProposalDetail memory self) internal pure returns (bytes32 digest_) {
        uint256[] memory values = self.values;
        TargetOption[] memory targets = self.targetOptions;
        bytes32[] memory calldataHashList = new bytes32[](self.calldatas.length);
        uint256[] memory gasAmounts = self.gasAmounts;

        for (uint256 i; i < calldataHashList.length;) {
            calldataHashList[i] = keccak256(self.calldatas[i]);

            unchecked {
                ++i;
            }
        }

        /*
     * return
     *   keccak256(
     *     abi.encode(
     *       TYPE_HASH,
     *       proposal.nonce,
     *       proposal.expiryTimestamp,
     *       proposal.executor,
     *       targetsHash,
     *       valuesHash,
     *       calldatasHash,
     *       gasAmountsHash
     *     )
     *   );
     */
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, TYPE_HASH)
            mstore(add(ptr, 0x20), mload(self)) // proposal.nonce
            mstore(add(ptr, 0x40), mload(add(self, 0x20))) // proposal.expiryTimestamp
            mstore(add(ptr, 0x60), mload(add(self, 0x40))) // proposal.executor

            let arrayHashed
            arrayHashed := keccak256(add(targets, 32), mul(mload(targets), 32)) // targetsHash
            mstore(add(ptr, 0x80), arrayHashed)
            arrayHashed := keccak256(add(values, 32), mul(mload(values), 32)) // valuesHash
            mstore(add(ptr, 0xa0), arrayHashed)
            arrayHashed := keccak256(add(calldataHashList, 32), mul(mload(calldataHashList), 32)) // calldatasHash
            mstore(add(ptr, 0xc0), arrayHashed)
            arrayHashed := keccak256(add(gasAmounts, 32), mul(mload(gasAmounts), 32)) // gasAmountsHash
            mstore(add(ptr, 0xe0), arrayHashed)
            digest_ := keccak256(ptr, 0x100)
        }
    }

    /**
     * @dev Converts into the normal proposal.
     */
    function intoProposalDetail(GlobalProposalDetail memory self, address[] memory targets)
        internal
        pure
        returns (Proposal.ProposalDetail memory detail_)
    {
        detail_.nonce = self.nonce;
        detail_.chainId = 0;
        detail_.expiryTimestamp = self.expiryTimestamp;
        detail_.executor = self.executor;

        detail_.targets = new address[](self.targetOptions.length);
        detail_.values = self.values;
        detail_.calldatas = self.calldatas;
        detail_.gasAmounts = self.gasAmounts;

        for (uint256 i; i < self.targetOptions.length; ++i) {
            detail_.targets[i] = targets[i];
        }
    }
}

/**
 * @dev Error indicating that an order is invalid.
 * @param msgSig The function signature (bytes4) of the operation that encountered an invalid order.
 */
error ErrInvalidOrder(bytes4 msgSig);

/**
 * @dev Error indicating that a relay call has failed.
 * @param msgSig The function signature (bytes4) of the relay call that failed.
 */
error ErrRelayFailed(bytes4 msgSig);

abstract contract CommonGovernanceRelay is CoreGovernance {
    using Proposal for Proposal.ProposalDetail;
    using GlobalProposal for GlobalProposal.GlobalProposalDetail;

    /**
     * @dev Relays votes by signatures.
     *
     * @notice Does not store the voter signature into storage.
     *
     */
    function _relayVotesBySignatures(
        Proposal.ProposalDetail memory _proposal,
        Ballot.VoteType[] calldata _supports,
        Signature[] calldata _signatures,
        bytes32 proposalHash
    ) internal {
        if (!(_supports.length > 0 && _supports.length == _signatures.length)) {
            revert ErrLengthMismatch(msg.sig);
        }

        bytes32 _forDigest =
            ECDSA.toTypedDataHash(_proposalDomainSeparator(), Ballot.hash(proposalHash, Ballot.VoteType.For));
        bytes32 _againstDigest =
            ECDSA.toTypedDataHash(_proposalDomainSeparator(), Ballot.hash(proposalHash, Ballot.VoteType.Against));

        address[] memory _forVoteSigners = new address[](_signatures.length);
        address[] memory _againstVoteSigners = new address[](_signatures.length);

        {
            uint256 _forVoteCount;
            uint256 _againstVoteCount;

            {
                address _signer;
                address _lastSigner;
                Ballot.VoteType _support;
                Signature calldata _sig;

                for (uint256 _i; _i < _signatures.length;) {
                    _sig = _signatures[_i];
                    _support = _supports[_i];

                    if (_support == Ballot.VoteType.For) {
                        _signer = ECDSA.recover(_forDigest, _sig.v, _sig.r, _sig.s);
                        _forVoteSigners[_forVoteCount++] = _signer;
                    } else if (_support == Ballot.VoteType.Against) {
                        _signer = ECDSA.recover(_againstDigest, _sig.v, _sig.r, _sig.s);
                        _againstVoteSigners[_againstVoteCount++] = _signer;
                    } else {
                        revert ErrUnsupportedVoteType(msg.sig);
                    }

                    if (_lastSigner >= _signer) {
                        revert ErrInvalidOrder(msg.sig);
                    }
                    _lastSigner = _signer;

                    unchecked {
                        ++_i;
                    }
                }
            }

            assembly {
                mstore(_forVoteSigners, _forVoteCount)
                mstore(_againstVoteSigners, _againstVoteCount)
            }
        }

        ProposalVote storage _vote = vote[_proposal.chainId][_proposal.nonce];
        uint256 _minimumForVoteWeight = _getMinimumVoteWeight();
        uint256 _totalForVoteWeight = _sumWeight(_forVoteSigners);
        if (_totalForVoteWeight >= _minimumForVoteWeight) {
            if (_totalForVoteWeight == 0) {
                revert ErrInvalidVoteWeight(msg.sig);
            }
            _vote.status = VoteStatus.Approved;
            emit ProposalApproved(_vote.hash);
            _tryExecute(_vote, _proposal);
            return;
        }

        uint256 _minimumAgainstVoteWeight = _getTotalWeight() - _minimumForVoteWeight + 1;
        uint256 _totalAgainstVoteWeight = _sumWeight(_againstVoteSigners);
        if (_totalAgainstVoteWeight >= _minimumAgainstVoteWeight) {
            if (_totalAgainstVoteWeight == 0) {
                revert ErrInvalidVoteWeight(msg.sig);
            }
            _vote.status = VoteStatus.Rejected;
            emit ProposalRejected(_vote.hash);
            return;
        }

        revert ErrRelayFailed(msg.sig);
    }

    /**
     * @dev Returns the weight of the governor list.
     */
    function _sumWeight(address[] memory _governors) internal view virtual returns (uint256);

    function _proposalDomainSeparator() internal view virtual returns (bytes32);
}

abstract contract GovernanceRelay is CoreGovernance, CommonGovernanceRelay {
    using Proposal for Proposal.ProposalDetail;
    using GlobalProposal for GlobalProposal.GlobalProposalDetail;

    /**
     * @dev Relays voted proposal.
     *
     * Requirements:
     * - The relay proposal is finalized.
     *
     */
    function _relayProposal(
        Proposal.ProposalDetail calldata _proposal,
        Ballot.VoteType[] calldata _supports,
        Signature[] calldata _signatures,
        address _creator
    ) internal {
        _proposeProposalStruct(_proposal, _creator);
        _relayVotesBySignatures(_proposal, _supports, _signatures, _proposal.hash());
    }
}

/**
 * @dev Error indicating that arguments are invalid.
 */
error ErrInvalidArguments(bytes4 msgSig);

abstract contract GlobalCoreGovernance is CoreGovernance {
    using Proposal for Proposal.ProposalDetail;
    using GlobalProposal for GlobalProposal.GlobalProposalDetail;

    mapping(GlobalProposal.TargetOption => address) internal _targetOptionsMap;

    /// @dev Emitted when a proposal is created
    event GlobalProposalCreated(
        uint256 indexed round,
        bytes32 indexed proposalHash,
        Proposal.ProposalDetail proposal,
        bytes32 globalProposalHash,
        GlobalProposal.GlobalProposalDetail globalProposal,
        address creator
    );

    /// @dev Emitted when the target options are updated
    event TargetOptionUpdated(GlobalProposal.TargetOption indexed targetOption, address indexed addr);

    function __GlobalCoreGovernance_init(GlobalProposal.TargetOption[] memory targetOptions, address[] memory addrs)
        internal
        onlyInitializing
    {
        __GlobalCoreGovernance_init_unchained(targetOptions, addrs);
    }

    function __GlobalCoreGovernance_init_unchained(
        GlobalProposal.TargetOption[] memory targetOptions,
        address[] memory addrs
    ) internal onlyInitializing {
        _updateTargetOption(GlobalProposal.TargetOption.BridgeManager, address(this));
        _updateManyTargetOption(targetOptions, addrs);
    }

    /**
     * @dev Proposes for a global proposal.
     *
     * Emits the `GlobalProposalCreated` event.
     *
     */
    function _proposeGlobal(
        uint256 expiryTimestamp,
        GlobalProposal.TargetOption[] calldata targetOptions,
        address executor,
        uint256[] memory values,
        bytes[] memory calldatas,
        uint256[] memory gasAmounts,
        address creator
    ) internal virtual {
        uint256 round_ = _createVotingRound(0);
        GlobalProposal.GlobalProposalDetail memory globalProposal = GlobalProposal.GlobalProposalDetail(
            round_, expiryTimestamp, executor, targetOptions, values, calldatas, gasAmounts
        );
        Proposal.ProposalDetail memory proposal =
            globalProposal.intoProposalDetail(_resolveTargets({targetOptions: targetOptions, strict: true}));
        proposal.validate(_proposalExpiryDuration);

        bytes32 proposalHash = proposal.hash();
        _saveVotingRound(vote[0][round_], proposalHash, expiryTimestamp);
        emit GlobalProposalCreated(round_, proposalHash, proposal, globalProposal.hash(), globalProposal, creator);
    }

    /**
     * @dev Proposes global proposal struct.
     *
     * Requirements:
     * - The proposal nonce is equal to the new round.
     *
     * Emits the `GlobalProposalCreated` event.
     *
     */
    function _proposeGlobalStruct(GlobalProposal.GlobalProposalDetail memory globalProposal, address creator)
        internal
        virtual
        returns (Proposal.ProposalDetail memory proposal)
    {
        proposal = globalProposal.intoProposalDetail(
            _resolveTargets({targetOptions: globalProposal.targetOptions, strict: true})
        );
        proposal.validate(_proposalExpiryDuration);

        bytes32 proposalHash = proposal.hash();
        uint256 round_ = _createVotingRound(0);
        _saveVotingRound(vote[0][round_], proposalHash, globalProposal.expiryTimestamp);

        if (round_ != proposal.nonce) {
            revert ErrInvalidProposalNonce(msg.sig);
        }
        emit GlobalProposalCreated(round_, proposalHash, proposal, globalProposal.hash(), globalProposal, creator);
    }

    /**
     * @dev Returns corresponding address of target options. Return address(0) on non-existent target.
     */
    function resolveTargets(GlobalProposal.TargetOption[] calldata targetOptions)
        external
        view
        returns (address[] memory targets)
    {
        return _resolveTargets({targetOptions: targetOptions, strict: false});
    }

    /**
     * @dev Internal helper of {resolveTargets}.
     *
     * @param strict When the param is set to `true`, revert on non-existent target.
     */
    function _resolveTargets(GlobalProposal.TargetOption[] memory targetOptions, bool strict)
        internal
        view
        returns (address[] memory targets)
    {
        targets = new address[](targetOptions.length);

        for (uint256 i; i < targetOptions.length; ++i) {
            targets[i] = _targetOptionsMap[targetOptions[i]];
            if (strict && targets[i] == address(0)) {
                revert ErrInvalidArguments(msg.sig);
            }
        }
    }

    /**
     * @dev Updates list of `targetOptions` to `targets`.
     *
     * Requirement:
     * - Only allow self-call through proposal.
     *
     */
    function updateManyTargetOption(GlobalProposal.TargetOption[] memory targetOptions, address[] memory targets)
        external
    {
        // HACK: Cannot reuse the existing library due to too deep stack
        if (msg.sender != address(this)) {
            revert ErrOnlySelfCall(msg.sig);
        }
        _updateManyTargetOption(targetOptions, targets);
    }

    /**
     * @dev Updates list of `targetOptions` to `targets`.
     */
    function _updateManyTargetOption(GlobalProposal.TargetOption[] memory targetOptions, address[] memory targets)
        internal
    {
        for (uint256 i; i < targetOptions.length; ++i) {
            if (targets[i] == address(this)) {
                revert ErrInvalidArguments(msg.sig);
            }
            _updateTargetOption(targetOptions[i], targets[i]);
        }
    }

    /**
     * @dev Updates `targetOption` to `target`.
     *
     * Requirement:
     * - Emit a `TargetOptionUpdated` event.
     */
    function _updateTargetOption(GlobalProposal.TargetOption targetOption, address target) internal {
        _targetOptionsMap[targetOption] = target;
        emit TargetOptionUpdated(targetOption, target);
    }
}

abstract contract GlobalGovernanceRelay is CommonGovernanceRelay, GlobalCoreGovernance {
    using GlobalProposal for GlobalProposal.GlobalProposalDetail;

    /**
     * @dev Returns whether the voter `_voter` casted vote for the proposal.
     */
    function globalProposalRelayed(uint256 _round) external view returns (bool) {
        return vote[0][_round].status != VoteStatus.Pending;
    }

    /**
     * @dev Relays voted global proposal.
     *
     * Requirements:
     * - The relay proposal is finalized.
     *
     */
    function _relayGlobalProposal(
        GlobalProposal.GlobalProposalDetail calldata globalProposal,
        Ballot.VoteType[] calldata supports_,
        Signature[] calldata signatures,
        address creator
    ) internal {
        Proposal.ProposalDetail memory _proposal = _proposeGlobalStruct(globalProposal, creator);
        _relayVotesBySignatures(_proposal, supports_, signatures, globalProposal.hash());
    }
}

/**
 * @dev Error of the `caller` to relay is not the specified `executor`.
 */
error ErrNonExecutorCannotRelay(address executor, address caller);

contract MainchainBridgeManager is BridgeManager, GovernanceRelay, GlobalGovernanceRelay {
    uint256 private constant DEFAULT_EXPIRY_DURATION = 1 << 255;

    function initialize(
        uint256 num,
        uint256 denom,
        uint256 roninChainId,
        address bridgeContract,
        address[] memory callbackRegisters,
        address[] memory bridgeOperators,
        address[] memory governors,
        uint96[] memory voteWeights,
        GlobalProposal.TargetOption[] memory targetOptions,
        address[] memory targets
    ) external initializer {
        __CoreGovernance_init(DEFAULT_EXPIRY_DURATION);
        __GlobalCoreGovernance_init(targetOptions, targets);
        __BridgeManager_init(
            num, denom, roninChainId, bridgeContract, callbackRegisters, bridgeOperators, governors, voteWeights
        );
    }

    /**
     * @dev See `GovernanceRelay-_relayProposal`.
     *
     * Requirements:
     * - The method caller is governor.
     */
    function relayProposal(
        Proposal.ProposalDetail calldata proposal,
        Ballot.VoteType[] calldata supports_,
        Signature[] calldata signatures
    ) external onlyGovernor {
        _requireExecutor(proposal.executor, msg.sender);
        _relayProposal(proposal, supports_, signatures, msg.sender);
    }

    /**
     * @dev See `GovernanceRelay-_relayGlobalProposal`.
     *
     *  Requirements:
     * - The method caller is governor.
     */
    function relayGlobalProposal(
        GlobalProposal.GlobalProposalDetail calldata globalProposal,
        Ballot.VoteType[] calldata supports_,
        Signature[] calldata signatures
    ) external onlyGovernor {
        _requireExecutor(globalProposal.executor, msg.sender);
        _relayGlobalProposal({
            globalProposal: globalProposal,
            supports_: supports_,
            signatures: signatures,
            creator: msg.sender
        });
    }

    function _requireExecutor(address executor, address caller) internal pure {
        if (executor != address(0) && caller != executor) {
            revert ErrNonExecutorCannotRelay(executor, caller);
        }
    }

    /**
     * @dev Internal function to retrieve the minimum vote weight required for governance actions.
     * @return minimumVoteWeight The minimum vote weight required for governance actions.
     */
    function _getMinimumVoteWeight() internal view override returns (uint256) {
        return minimumVoteWeight();
    }

    /**
     * @dev Returns the expiry duration for a new proposal.
     */
    function getProposalExpiryDuration() external view returns (uint256) {
        return _proposalExpiryDuration;
    }

    /**
     * @dev Internal function to retrieve the total weights of all governors.
     * @return totalWeights The total weights of all governors combined.
     */
    function _getTotalWeight() internal view override returns (uint256) {
        return getTotalWeight();
    }

    /**
     * @dev Internal function to calculate the sum of weights for a given array of governors.
     * @param governors An array containing the addresses of governors to calculate the sum of weights.
     * @return sumWeights The sum of weights for the provided governors.
     */
    function _sumWeight(address[] memory governors) internal view override returns (uint256) {
        return _sumGovernorsWeight(governors);
    }

    /**
     * @dev Internal function to retrieve the chain type of the contract.
     * @return chainType The chain type, indicating the type of the chain the contract operates on (e.g., Mainchain).
     */
    function _getChainType() internal pure override returns (ChainType) {
        return ChainType.Mainchain;
    }

    function _proposalDomainSeparator() internal view override returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
}
