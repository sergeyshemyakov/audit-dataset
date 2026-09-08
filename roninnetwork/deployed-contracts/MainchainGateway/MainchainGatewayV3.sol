// SPDX-License-Identifier: Unknown
pragma solidity 0.8.27;

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
abstract contract Pausable is Context {
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
    constructor() {
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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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
        address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

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

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
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
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data)
        external
        returns (bytes4);

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
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155).interfaceId || interfaceId == type(IERC1155MetadataURI).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
        public
        virtual
        override
    {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
        internal
        virtual
    {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        virtual
    {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

enum TokenStandard {
    ERC20,
    ERC721,
    ERC1155
}

abstract contract FunctionRestrictable {
    /// @custom:storage-location erc7201:ronin.bridge.FunctionRestrictable
    struct FunctionalRestrictableStorage {
        mapping(bytes4 fnSig => uint8 bitmap) _enumBitmap;
    }

    /// @dev Emit when a function is paused.
    event Restricted(address indexed by, bytes4 indexed fnSig, uint8 enumBitmap);
    /// @dev Emit when a function is unpaused.
    event UnRestricted(address indexed by, bytes4 indexed fnSig);

    /// @dev Error when the function is restricted for specific standard.
    error ErrRestricted(bytes4 fnSig, TokenStandard standard);

    /**
     * @dev Modifier to check if the caller is authorized.
     */
    modifier onlyAuth() {
        _requireAuth();
        _;
    }

    /**
     * @dev Restrict a specific function with standard bitmap.
     *
     * Requirement:
     * - The caller must be authorized.
     *
     * Emits a {Restricted} event if `enumBitmap` is not 0.
     * Emits a {UnRestricted} event if `enumBitmap` is 0.
     *
     * +-------------------------+---------+------------+------------+------------+------------+------------+---------+--------+-------+
     * |          Case           | Decimal | Unused Bit | Unused Bit | Unused Bit | Unused Bit | Unused Bit | ERC1155 | ERC721 | ERC20 |
     * +-------------------------+---------+------------+------------+------------+------------+------------+---------+--------+-------+
     * | Allow All               |       0 |          0 |          0 |          0 |          0 |          0 |       0 |      0 |     0 |
     * | Forbid ERC20            |       1 |          0 |          0 |          0 |          0 |          0 |       0 |      0 |     1 |
     * | Forbid ERC721           |       2 |          0 |          0 |          0 |          0 |          0 |       0 |      1 |     0 |
     * | Forbid ERC20 && ERC721  |       3 |          0 |          0 |          0 |          0 |          0 |       0 |      1 |     1 |
     * | Forbid ERC1155 && ERC20 |       5 |          0 |          0 |          0 |          0 |          0 |       1 |      0 |     1 |
     * | Forbid All              |     255 |          1 |          1 |          1 |          1 |          1 |       1 |      1 |     1 |
     * | Forbid All              |       7 |          0 |          0 |          0 |          0 |          0 |       1 |      1 |     1 |
     * +-------------------------+---------+------------+------------+------------+------------+------------+---------+--------+-------+
     *
     * @param fnSig The function signature to restrict.
     * @param enumBitmap The bitmap of the standard to restrict.
     */
    function restrict(bytes4 fnSig, uint8 enumBitmap) external onlyAuth {
        _restrict(fnSig, enumBitmap);
    }

    /**
     * @dev Check if the function is restricted for specific standard.
     *
     * @param fnSig The function signature to check.
     * @param standard The standard to check.
     * @return yes True if the function is restricted for the specific standard.
     */
    function restricted(bytes4 fnSig, TokenStandard standard) public view returns (bool yes) {
        yes = _getFunctionalRestrictable()._enumBitmap[fnSig] & _toBitmap(standard) != 0;
    }

    /**
     * @dev Restrict a specific function with standard bitmap.
     */
    function _restrict(bytes4 fnSig, uint8 enumBitmap) internal {
        _getFunctionalRestrictable()._enumBitmap[fnSig] = enumBitmap;

        if (enumBitmap == 0) {
            emit UnRestricted(msg.sender, fnSig);
        } else {
            emit Restricted(msg.sender, fnSig, enumBitmap);
        }
    }

    /**
     * @dev Validate the caller is authorized.
     */
    function _requireAuth() internal virtual;

    /**
     * @dev Require the function with specific `msg.sig` is not restricted for the specific standard.
     */
    function _requireNotRestricted(TokenStandard standard) internal view {
        require(!restricted(msg.sig, standard), ErrRestricted(msg.sig, standard));
    }

    /**
     * @dev Convert the TokenStandard to bitmap.
     */
    function _toBitmap(TokenStandard standard) internal pure returns (uint8) {
        return uint8(1 << uint8(standard));
    }

    /**
     * @dev Returns the storage pointer of the FunctionalRestrictableStorage struct.
     */
    function _getFunctionalRestrictable() private pure returns (FunctionalRestrictableStorage storage $) {
        // value is equal to keccak256(abi.encode(uint256(keccak256("ronin.bridge.FunctionRestrictable")) - 1)) &
        // ~bytes32(uint256(0xff))
        bytes32 storageLoc = 0xa7959878b25ffc8190f7b5440888c97e9a819bbb4963604c213ae021e3145700;

        assembly ("memory-safe") {
            $.slot := storageLoc
        }
    }
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

/**
 * @dev Error indicating that the provided threshold is invalid for a specific function signature.
 * @param msgSig The function signature (bytes4) that the invalid threshold applies to.
 */
error ErrInvalidThreshold(bytes4 msgSig);

abstract contract GatewayV3 is HasProxyAdmin, Pausable, FunctionRestrictable, IQuorum {
    /**
     * @dev Error indicating that `_minimumVoteWeight` is returning 0.
     */
    error ErrNullMinVoteWeightProvided(bytes4 msgSig);

    uint256 internal _num;
    uint256 internal _denom;

    address private ______deprecated;
    uint256 public nonce;

    address public emergencyPauser;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private ______gap;

    /**
     * @dev Grant emergency pauser role for `_addr`.
     */
    function setEmergencyPauser(address _addr) external onlyProxyAdmin {
        emergencyPauser = _addr;
    }

    /**
     * @inheritdoc IQuorum
     */
    function getThreshold() external view virtual returns (uint256 num_, uint256 denom_) {
        return (_num, _denom);
    }

    /**
     * @inheritdoc IQuorum
     */
    function checkThreshold(uint256 _voteWeight) external view virtual returns (bool) {
        return _voteWeight * _denom >= _num * _getTotalWeight();
    }

    /**
     * @inheritdoc IQuorum
     */
    function setThreshold(uint256 _numerator, uint256 _denominator) external virtual onlyProxyAdmin {
        return _setThreshold(_numerator, _denominator);
    }

    /**
     * @dev Triggers paused state.
     */
    function pause() external {
        _requireAuth();
        _pause();
    }

    /**
     * @dev Triggers unpaused state.
     */
    function unpause() external {
        _requireAuth();
        _unpause();
    }

    /**
     * @inheritdoc IQuorum
     */
    function minimumVoteWeight() public view virtual returns (uint256) {
        return _minimumVoteWeight(_getTotalWeight());
    }

    /**
     * @dev Sets threshold and returns the old one.
     *
     * Emits the `ThresholdUpdated` event.
     *
     */
    function _setThreshold(uint256 num, uint256 denom) internal virtual {
        if (num > denom || denom == 0 || num == 0) {
            revert ErrInvalidThreshold(msg.sig);
        }

        uint256 prevNum = _num;
        uint256 prevDenom = _denom;

        _num = num;
        _denom = denom;

        unchecked {
            emit ThresholdUpdated(nonce++, num, denom, prevNum, prevDenom);
        }
    }

    /**
     * @dev Returns minimum vote weight.
     */
    function _minimumVoteWeight(uint256 _totalWeight) internal view virtual returns (uint256 minVoteWeight) {
        minVoteWeight = (_num * _totalWeight + _denom - 1) / _denom;
        if (minVoteWeight == 0) {
            revert ErrNullMinVoteWeightProvided(msg.sig);
        }
    }

    /**
     * @dev Internal method to check method caller.
     *
     * Requirements:
     *
     * - The method caller must be admin or pauser.
     *
     */
    function _requireAuth() internal view override {
        if (!(msg.sender == _getProxyAdmin() || msg.sender == emergencyPauser)) {
            revert ErrUnauthorized(msg.sig, RoleAccess.ADMIN);
        }
    }

    /**
     * @dev Returns the total weight.
     */
    function _getTotalWeight() internal view virtual returns (uint256);
}

/**
 * @dev Error indicating that an array is empty when it should contain elements.
 */
error ErrEmptyArray();

/**
 * @dev Error indicating a mismatch in the length of input parameters or arrays for a specific function.
 * @param msgSig The function signature (bytes4) that has a length mismatch.
 */
error ErrLengthMismatch(bytes4 msgSig);

abstract contract WithdrawalLimitation is GatewayV3 {
    /// @dev Error of invalid percentage.
    error ErrInvalidPercentage();
    /// @dev Error thrown when the high-tier vote weight threshold is `0`.
    error ErrNullHighTierVoteWeightProvided(bytes4 msgSig);

    /// @dev Emitted when the high-tier vote weight threshold is updated
    event HighTierVoteWeightThresholdUpdated(
        uint256 indexed nonce,
        uint256 indexed numerator,
        uint256 indexed denominator,
        uint256 previousNumerator,
        uint256 previousDenominator
    );
    /// @dev Emitted when the thresholds for high-tier withdrawals that requires high-tier vote weights are updated
    event HighTierThresholdsUpdated(address[] tokens, uint256[] thresholds);
    /// @dev Emitted when the thresholds for locked withdrawals are updated
    event LockedThresholdsUpdated(address[] tokens, uint256[] thresholds);
    /// @dev Emitted when the fee percentages to unlock withdraw are updated
    event UnlockFeePercentagesUpdated(address[] tokens, uint256[] percentages);
    /// @dev Emitted when the daily limit thresholds are updated
    event DailyWithdrawalLimitsUpdated(address[] tokens, uint256[] limits);

    uint256 public constant _MAX_PERCENTAGE = 1_000_000;

    uint256 internal _highTierVWNum;
    uint256 internal _highTierVWDenom;

    /// @dev Mapping from mainchain token => the amount thresholds for high-tier withdrawals that requires high-tier vote weights
    mapping(address => uint256) public highTierThreshold;
    /// @dev Mapping from mainchain token => the amount thresholds to lock withdrawal
    mapping(address => uint256) public lockedThreshold;
    /// @dev Mapping from mainchain token => unlock fee percentages for unlocker
    /// @notice Values 0-1,000,000 map to 0%-100%
    mapping(address => uint256) public unlockFeePercentages;
    /// @dev Mapping from mainchain token => daily limit amount for withdrawal
    mapping(address => uint256) public dailyWithdrawalLimit;
    /// @dev Mapping from token address => today withdrawal amount
    mapping(address => uint256) public lastSyncedWithdrawal;
    /// @dev Mapping from token address => last date synced to record the `lastSyncedWithdrawal`
    mapping(address => uint256) public lastDateSynced;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[50] private ______gap;

    /**
     * @dev Override `GatewayV3-setThreshold`.
     *
     * Requirements:
     * - The high-tier vote weight threshold must equal to or larger than the normal threshold.
     *
     */
    function setThreshold(uint256 num, uint256 denom) external virtual override onlyProxyAdmin {
        _setThreshold(num, denom);
        _verifyThresholds();
    }

    /**
     * @dev Returns the high-tier vote weight threshold.
     */
    function getHighTierVoteWeightThreshold() external view virtual returns (uint256, uint256) {
        return (_highTierVWNum, _highTierVWDenom);
    }

    /**
     * @dev Checks whether the `_voteWeight` passes the high-tier vote weight threshold.
     */
    function checkHighTierVoteWeightThreshold(uint256 _voteWeight) external view virtual returns (bool) {
        return _voteWeight * _highTierVWDenom >= _highTierVWNum * _getTotalWeight();
    }

    /**
     * @dev Sets high-tier vote weight threshold and returns the old one.
     *
     * Requirements:
     * - The method caller is admin.
     * - The high-tier vote weight threshold must equal to or larger than the normal threshold.
     *
     * Emits the `HighTierVoteWeightThresholdUpdated` event.
     *
     */
    function setHighTierVoteWeightThreshold(uint256 _numerator, uint256 _denominator)
        external
        virtual
        onlyProxyAdmin
        returns (uint256 _previousNum, uint256 _previousDenom)
    {
        (_previousNum, _previousDenom) = _setHighTierVoteWeightThreshold(_numerator, _denominator);
        _verifyThresholds();
    }

    /**
     * @dev Sets the thresholds for high-tier withdrawals that requires high-tier vote weights.
     *
     * Requirements:
     * - The method caller is admin.
     * - The arrays have the same length and its length larger than 0.
     *
     * Emits the `HighTierThresholdsUpdated` event.
     *
     */
    function setHighTierThresholds(address[] calldata _tokens, uint256[] calldata _thresholds)
        external
        virtual
        onlyProxyAdmin
    {
        if (_tokens.length == 0) {
            revert ErrEmptyArray();
        }
        _setHighTierThresholds(_tokens, _thresholds);
    }

    /**
     * @dev Sets the amount thresholds to lock withdrawal.
     *
     * Requirements:
     * - The method caller is admin.
     * - The arrays have the same length and its length larger than 0.
     *
     * Emits the `LockedThresholdsUpdated` event.
     *
     */
    function setLockedThresholds(address[] calldata _tokens, uint256[] calldata _thresholds)
        external
        virtual
        onlyProxyAdmin
    {
        if (_tokens.length == 0) {
            revert ErrEmptyArray();
        }
        _setLockedThresholds(_tokens, _thresholds);
    }

    /**
     * @dev Sets fee percentages to unlock withdrawal.
     *
     * Requirements:
     * - The method caller is admin.
     * - The arrays have the same length and its length larger than 0.
     *
     * Emits the `UnlockFeePercentagesUpdated` event.
     *
     */
    function setUnlockFeePercentages(address[] calldata _tokens, uint256[] calldata _percentages)
        external
        virtual
        onlyProxyAdmin
    {
        if (_tokens.length == 0) {
            revert ErrEmptyArray();
        }
        _setUnlockFeePercentages(_tokens, _percentages);
    }

    /**
     * @dev Sets daily limit amounts for the withdrawals.
     *
     * Requirements:
     * - The method caller is admin.
     * - The arrays have the same length and its length larger than 0.
     *
     * Emits the `DailyWithdrawalLimitsUpdated` event.
     *
     */
    function setDailyWithdrawalLimits(address[] calldata _tokens, uint256[] calldata _limits)
        external
        virtual
        onlyProxyAdmin
    {
        if (_tokens.length == 0) {
            revert ErrEmptyArray();
        }
        _setDailyWithdrawalLimits(_tokens, _limits);
    }

    /**
     * @dev Checks whether the withdrawal reaches the limitation.
     */
    function reachedWithdrawalLimit(address _token, uint256 _quantity) external view virtual returns (bool) {
        return _reachedWithdrawalLimit(_token, _quantity);
    }

    /**
     * @dev Sets high-tier vote weight threshold and returns the old one.
     *
     * Emits the `HighTierVoteWeightThresholdUpdated` event.
     *
     */
    function _setHighTierVoteWeightThreshold(uint256 _numerator, uint256 _denominator)
        internal
        returns (uint256 _previousNum, uint256 _previousDenom)
    {
        if (_numerator > _denominator || _numerator == 0 || _denominator == 0) {
            revert ErrInvalidThreshold(msg.sig);
        }

        _previousNum = _highTierVWNum;
        _previousDenom = _highTierVWDenom;
        _highTierVWNum = _numerator;
        _highTierVWDenom = _denominator;

        unchecked {
            emit HighTierVoteWeightThresholdUpdated(nonce++, _numerator, _denominator, _previousNum, _previousDenom);
        }
    }

    /**
     * @dev Sets the thresholds for high-tier withdrawals that requires high-tier vote weights.
     *
     * Requirements:
     * - The array lengths are equal.
     *
     * Emits the `HighTierThresholdsUpdated` event.
     *
     */
    function _setHighTierThresholds(address[] calldata _tokens, uint256[] calldata _thresholds) internal virtual {
        if (_tokens.length != _thresholds.length) {
            revert ErrLengthMismatch(msg.sig);
        }

        for (uint256 _i; _i < _tokens.length;) {
            highTierThreshold[_tokens[_i]] = _thresholds[_i];

            unchecked {
                ++_i;
            }
        }
        emit HighTierThresholdsUpdated(_tokens, _thresholds);
    }

    /**
     * @dev Sets the amount thresholds to lock withdrawal.
     *
     * Requirements:
     * - The array lengths are equal.
     *
     * Emits the `LockedThresholdsUpdated` event.
     *
     */
    function _setLockedThresholds(address[] calldata _tokens, uint256[] calldata _thresholds) internal virtual {
        if (_tokens.length != _thresholds.length) {
            revert ErrLengthMismatch(msg.sig);
        }

        for (uint256 _i; _i < _tokens.length;) {
            lockedThreshold[_tokens[_i]] = _thresholds[_i];

            unchecked {
                ++_i;
            }
        }
        emit LockedThresholdsUpdated(_tokens, _thresholds);
    }

    /**
     * @dev Sets fee percentages to unlock withdrawal.
     *
     * Requirements:
     * - The array lengths are equal.
     * - The percentage is equal to or less than 100_000.
     *
     * Emits the `UnlockFeePercentagesUpdated` event.
     *
     */
    function _setUnlockFeePercentages(address[] calldata _tokens, uint256[] calldata _percentages) internal virtual {
        if (_tokens.length != _percentages.length) {
            revert ErrLengthMismatch(msg.sig);
        }

        for (uint256 _i; _i < _tokens.length;) {
            if (_percentages[_i] > _MAX_PERCENTAGE) {
                revert ErrInvalidPercentage();
            }

            unlockFeePercentages[_tokens[_i]] = _percentages[_i];

            unchecked {
                ++_i;
            }
        }
        emit UnlockFeePercentagesUpdated(_tokens, _percentages);
    }

    /**
     * @dev Sets daily limit amounts for the withdrawals.
     *
     * Requirements:
     * - The array lengths are equal.
     *
     * Emits the `DailyWithdrawalLimitsUpdated` event.
     *
     */
    function _setDailyWithdrawalLimits(address[] calldata _tokens, uint256[] calldata _limits) internal virtual {
        if (_tokens.length != _limits.length) {
            revert ErrLengthMismatch(msg.sig);
        }

        for (uint256 _i; _i < _tokens.length;) {
            dailyWithdrawalLimit[_tokens[_i]] = _limits[_i];

            unchecked {
                ++_i;
            }
        }
        emit DailyWithdrawalLimitsUpdated(_tokens, _limits);
    }

    /**
     * @dev Checks whether the withdrawal reaches the daily limitation.
     *
     * Requirements:
     * - The daily withdrawal threshold should not apply for locked withdrawals.
     *
     */
    function _reachedWithdrawalLimit(address _token, uint256 _quantity) internal view virtual returns (bool) {
        if (_lockedWithdrawalRequest(_token, _quantity)) {
            return false;
        }

        uint256 _currentDate = block.timestamp / 1 days;
        if (_currentDate > lastDateSynced[_token]) {
            return dailyWithdrawalLimit[_token] <= _quantity;
        } else {
            return dailyWithdrawalLimit[_token] <= lastSyncedWithdrawal[_token] + _quantity;
        }
    }

    /**
     * @dev Record withdrawal token.
     */
    function _recordWithdrawal(address _token, uint256 _quantity) internal virtual {
        uint256 _currentDate = block.timestamp / 1 days;
        if (_currentDate > lastDateSynced[_token]) {
            lastDateSynced[_token] = _currentDate;
            lastSyncedWithdrawal[_token] = _quantity;
        } else {
            lastSyncedWithdrawal[_token] += _quantity;
        }
    }

    /**
     * @dev Returns whether the withdrawal request is locked or not.
     */
    function _lockedWithdrawalRequest(address _token, uint256 _quantity) internal view virtual returns (bool) {
        return lockedThreshold[_token] <= _quantity;
    }

    /**
     * @dev Computes fee percentage.
     */
    function _computeFeePercentage(uint256 _amount, uint256 _percentage) internal view virtual returns (uint256) {
        return (_amount * _percentage) / _MAX_PERCENTAGE;
    }

    /**
     * @dev Returns high-tier vote weight.
     */
    function _highTierVoteWeight(uint256 _totalWeight) internal view virtual returns (uint256 highTierVW) {
        highTierVW = (_highTierVWNum * _totalWeight + _highTierVWDenom - 1) / _highTierVWDenom;
        if (highTierVW == 0) {
            revert ErrNullHighTierVoteWeightProvided(msg.sig);
        }
    }

    /**
     * @dev Validates whether the high-tier vote weight threshold is larger than the normal threshold.
     */
    function _verifyThresholds() internal view {
        if (_num * _highTierVWDenom > _highTierVWNum * _denom) {
            revert ErrInvalidThreshold(msg.sig);
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

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
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
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
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
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes memory)
        public
        virtual
        override
        returns (bytes4)
    {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory)
        public
        virtual
        override
        returns (bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }
}

interface SignatureConsumer {
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}

interface MappedTokenConsumer {
    struct MappedToken {
        TokenStandard erc;
        address tokenAddr;
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

struct TokenOwner {
    address addr;
    address tokenAddr;
    uint256 chainId;
}

library LibTokenOwner {
    // keccak256("TokenOwner(address addr,address tokenAddr,uint256 chainId)");
    bytes32 public constant OWNER_TYPE_HASH = 0x353bdd8d69b9e3185b3972e08b03845c0c14a21a390215302776a7a34b0e8764;

    /**
     * @dev Returns ownership struct hash.
     */
    function hash(TokenOwner memory owner) internal pure returns (bytes32 digest) {
        // keccak256(abi.encode(OWNER_TYPE_HASH, owner.addr, owner.tokenAddr, owner.chainId))
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, OWNER_TYPE_HASH)
            mstore(add(ptr, 0x20), mload(owner)) // owner.addr
            mstore(add(ptr, 0x40), mload(add(owner, 0x20))) // owner.tokenAddr
            mstore(add(ptr, 0x60), mload(add(owner, 0x40))) // owner.chainId
            digest := keccak256(ptr, 0x80)
        }
    }
}

struct TokenInfo {
    TokenStandard erc;
    // For ERC20:  the id must be 0 and the quantity is larger than 0.
    // For ERC721: the quantity must be 0.
    uint256 id;
    uint256 quantity;
}

/// @dev Error indicating that the provided information is invalid.
error ErrInvalidInfo();

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @dev Error indicating that an unsupported standard is encountered.
error ErrUnsupportedStandard();

/**
 * @dev Error indicating that the `handleAssetIn` has failed.
 * @param tokenInfo Info of the token including ERC standard, id or quantity.
 * @param from Owner of the token value.
 * @param to Receiver of the token value.
 * @param token Address of the token.
 */
error ErrTokenCouldNotTransferFrom(TokenInfo tokenInfo, address from, address to, address token);

interface IWETH {
    event Transfer(address indexed src, address indexed dst, uint256 wad);

    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function approve(address guy, uint256 wad) external returns (bool);

    function transferFrom(address src, address dst, uint256 wad) external returns (bool);

    function withdraw(uint256 _wad) external;

    function balanceOf(address) external view returns (uint256);
}

/// @dev Error indicating that the minting of ERC20 tokens has failed.
error ErrERC20MintingFailed();

/// @dev Error indicating that the minting of ERC721 tokens has failed.
error ErrERC721MintingFailed();

/// @dev Error indicating that the mint of ERC1155 tokens has failed.
error ErrERC1155MintingFailed();

/**
 * @dev Error indicating that the `transfer` has failed.
 * @param tokenInfo Info of the token including ERC standard, id or quantity.
 * @param to Receiver of the token value.
 * @param token Address of the token.
 */
error ErrTokenCouldNotTransfer(TokenInfo tokenInfo, address to, address token);

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(address account, uint256 id, uint256 value) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}

/**
 * @dev ERC1155 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Pausable is ERC1155, Pausable {
    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}

/**
 * @dev {ERC1155} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 *
 * _Deprecated in favor of https://wizard.openzeppelin.com/[Contracts Wizard]._
 */
contract ERC1155PresetMinterPauser is Context, AccessControlEnumerable, ERC1155Burnable, ERC1155Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `PAUSER_ROLE` to the account that
     * deploys the contract.
     */
    constructor(string memory uri) ERC1155(uri) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 id, uint256 amount, bytes memory data) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mint(to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Pausable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}

library LibTokenInfo {
    /**
     *
     *        HASH
     *
     */

    // keccak256("TokenInfo(uint8 erc,uint256 id,uint256 quantity)");
    bytes32 public constant INFO_TYPE_HASH_SINGLE = 0x1e2b74b2a792d5c0f0b6e59b037fa9d43d84fbb759337f0112fcc15ca414fc8d;

    /**
     * @dev Returns token info struct hash.
     */
    function hash(TokenInfo memory self) internal pure returns (bytes32 digest) {
        // keccak256(abi.encode(INFO_TYPE_HASH_SINGLE, info.erc, info.id, info.quantity))
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, INFO_TYPE_HASH_SINGLE)
            mstore(add(ptr, 0x20), mload(self)) // info.erc
            mstore(add(ptr, 0x40), mload(add(self, 0x20))) // info.id
            mstore(add(ptr, 0x60), mload(add(self, 0x40))) // info.quantity
            digest := keccak256(ptr, 0x80)
        }
    }

    /**
     *
     *         VALIDATE
     *
     */

    /**
     * @dev Validates the token info.
     */
    function validate(TokenInfo memory self) internal pure {
        if (!(_checkERC20(self) || _checkERC721(self) || _checkERC1155(self))) {
            revert ErrInvalidInfo();
        }
    }

    function _checkERC20(TokenInfo memory self) private pure returns (bool) {
        return (self.erc == TokenStandard.ERC20 && self.quantity > 0 && self.id == 0);
    }

    function _checkERC721(TokenInfo memory self) private pure returns (bool) {
        return (self.erc == TokenStandard.ERC721 && self.quantity == 0);
    }

    function _checkERC1155(TokenInfo memory self) private pure returns (bool res) {
        // Only validate the quantity, because id of ERC-1155 can be 0.
        return (self.erc == TokenStandard.ERC1155 && self.quantity > 0);
    }

    /**
     *
     *       TRANSFER IN/OUT METHOD
     *
     */

    /**
     * @dev Transfer asset in.
     *
     * Requirements:
     * - The `_from` address must approve for the contract using this library.
     *
     */
    function handleAssetIn(TokenInfo memory self, address from, address token) internal {
        bool success;
        bytes memory data;
        if (self.erc == TokenStandard.ERC20) {
            (success, data) =
                token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, address(this), self.quantity));
            success = success && (data.length == 0 || abi.decode(data, (bool)));
        } else if (self.erc == TokenStandard.ERC721) {
            success = _tryTransferFromERC721(token, from, address(this), self.id);
        } else if (self.erc == TokenStandard.ERC1155) {
            success = _tryTransferFromERC1155(token, from, address(this), self.id, self.quantity);
        } else {
            revert ErrUnsupportedStandard();
        }

        if (!success) {
            revert ErrTokenCouldNotTransferFrom(self, from, address(this), token);
        }
    }

    /**
     * @dev Tries transfer assets out, or mint the assets if cannot transfer.
     *
     * @notice Prioritizes transfer native token if the token is wrapped.
     *
     */
    function handleAssetOut(TokenInfo memory self, address payable to, address token, IWETH wrappedNativeToken)
        internal
    {
        if (token == address(wrappedNativeToken)) {
            // Try sending the native token before transferring the wrapped token
            if (!to.send(self.quantity)) {
                wrappedNativeToken.deposit{value: self.quantity}();
                _transferTokenOut(self, to, token);
            }

            return;
        }

        if (self.erc == TokenStandard.ERC20) {
            uint256 balance = IERC20(token).balanceOf(address(this));
            if (balance < self.quantity) {
                if (!_tryMintERC20(token, address(this), self.quantity - balance)) {
                    revert ErrERC20MintingFailed();
                }
            }

            _transferTokenOut(self, to, token);
            return;
        }

        if (self.erc == TokenStandard.ERC721) {
            if (!_tryTransferOutOrMintERC721(token, to, self.id)) {
                revert ErrERC721MintingFailed();
            }
            return;
        }

        if (self.erc == TokenStandard.ERC1155) {
            if (!_tryTransferOutOrMintERC1155(token, to, self.id, self.quantity)) {
                revert ErrERC1155MintingFailed();
            }
            return;
        }

        revert ErrUnsupportedStandard();
    }

    /**
     *
     *      TRANSFER HELPERS
     *
     */

    /**
     * @dev Transfer assets from current address to `_to` address.
     */
    function _transferTokenOut(TokenInfo memory self, address to, address token) private {
        bool success;
        if (self.erc == TokenStandard.ERC20) {
            success = _tryTransferERC20(token, to, self.quantity);
        } else if (self.erc == TokenStandard.ERC721) {
            success = _tryTransferFromERC721(token, address(this), to, self.id);
        } else {
            revert ErrUnsupportedStandard();
        }

        if (!success) {
            revert ErrTokenCouldNotTransfer(self, to, token);
        }
    }

    /**
     *      TRANSFER ERC-20
     */

    /**
     * @dev Transfers ERC20 token and returns the result.
     */
    function _tryTransferERC20(address token, address to, uint256 quantity) private returns (bool success) {
        bytes memory data;
        (success, data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, quantity));
        success = success && (data.length == 0 || abi.decode(data, (bool)));
    }

    /**
     * @dev Mints ERC20 token and returns the result.
     */
    function _tryMintERC20(address token, address to, uint256 quantity) private returns (bool success) {
        // bytes4(keccak256("mint(address,uint256)"))
        (success,) = token.call(abi.encodeWithSelector(0x40c10f19, to, quantity));
    }

    /**
     *      TRANSFER ERC-721
     */

    /**
     * @dev Transfers the ERC721 token out. If the transfer failed, mints the ERC721.
     * @return success Returns `false` if both transfer and mint are failed.
     */
    function _tryTransferOutOrMintERC721(address token, address to, uint256 id) private returns (bool success) {
        success = _tryTransferFromERC721(token, address(this), to, id);
        if (!success) {
            return _tryMintERC721(token, to, id);
        }
    }

    /**
     * @dev Transfers ERC721 token and returns the result.
     */
    function _tryTransferFromERC721(address token, address from, address to, uint256 id)
        private
        returns (bool success)
    {
        (success,) = token.call(abi.encodeWithSelector(IERC721.transferFrom.selector, from, to, id));
    }

    /**
     * @dev Mints ERC721 token and returns the result.
     */
    function _tryMintERC721(address token, address to, uint256 id) private returns (bool success) {
        // bytes4(keccak256("mint(address,uint256)"))
        (success,) = token.call(abi.encodeWithSelector(0x40c10f19, to, id));
    }

    /**
     *      TRANSFER ERC-1155
     */

    /**
     * @dev Transfers the ERC1155 token out. If the transfer failed, mints the ERC11555.
     * @return success Returns `false` if both transfer and mint are failed.
     */
    function _tryTransferOutOrMintERC1155(address token, address to, uint256 id, uint256 amount)
        private
        returns (bool success)
    {
        success = _tryTransferFromERC1155(token, address(this), to, id, amount);
        if (!success) {
            return _tryMintERC1155(token, to, id, amount);
        }
    }

    /**
     * @dev Transfers ERC1155 token and returns the result.
     */
    function _tryTransferFromERC1155(address token, address from, address to, uint256 id, uint256 amount)
        private
        returns (bool success)
    {
        (success,) = token.call(abi.encodeCall(IERC1155.safeTransferFrom, (from, to, id, amount, new bytes(0))));
    }

    /**
     * @dev Mints ERC1155 token and returns the result.
     */
    function _tryMintERC1155(address token, address to, uint256 id, uint256 amount) private returns (bool success) {
        (success,) = token.call(abi.encodeCall(ERC1155PresetMinterPauser.mint, (to, id, amount, new bytes(0))));
    }
}

library Transfer {
    using ECDSA for bytes32;
    using LibTokenOwner for TokenOwner;
    using LibTokenInfo for TokenInfo;

    enum Kind {
        Deposit,
        Withdrawal
    }

    struct Request {
        // For deposit request: Recipient address on Ronin network
        // For withdrawal request: Recipient address on mainchain network
        address recipientAddr;
        // Token address to deposit/withdraw
        // Value 0: native token
        address tokenAddr;
        TokenInfo info;
    }

    /**
     * @dev Converts the transfer request into the deposit receipt.
     */
    function into_deposit_receipt(
        Request memory _request,
        address _requester,
        uint256 _id,
        address _roninTokenAddr,
        uint256 _roninChainId
    ) internal view returns (Receipt memory _receipt) {
        _receipt.id = _id;
        _receipt.kind = Kind.Deposit;
        _receipt.mainchain.addr = _requester;
        _receipt.mainchain.tokenAddr = _request.tokenAddr;
        _receipt.mainchain.chainId = block.chainid;
        _receipt.ronin.addr = _request.recipientAddr;
        _receipt.ronin.tokenAddr = _roninTokenAddr;
        _receipt.ronin.chainId = _roninChainId;
        _receipt.info = _request.info;
    }

    /**
     * @dev Converts the transfer request into the withdrawal receipt.
     */
    function into_withdrawal_receipt(
        Request memory _request,
        address _requester,
        uint256 _id,
        address _mainchainTokenAddr,
        uint256 _mainchainId
    ) internal view returns (Receipt memory _receipt) {
        _receipt.id = _id;
        _receipt.kind = Kind.Withdrawal;
        _receipt.ronin.addr = _requester;
        _receipt.ronin.tokenAddr = _request.tokenAddr;
        _receipt.ronin.chainId = block.chainid;
        _receipt.mainchain.addr = _request.recipientAddr;
        _receipt.mainchain.tokenAddr = _mainchainTokenAddr;
        _receipt.mainchain.chainId = _mainchainId;
        _receipt.info = _request.info;
    }

    struct Receipt {
        uint256 id;
        Kind kind;
        TokenOwner mainchain;
        TokenOwner ronin;
        TokenInfo info;
    }

    // keccak256("Receipt(uint256 id,uint8 kind,TokenOwner mainchain,TokenOwner ronin,TokenInfo info)TokenInfo(uint8 erc,uint256 id,uint256 quantity)TokenOwner(address addr,address tokenAddr,uint256 chainId)");
    bytes32 public constant TYPE_HASH = 0xb9d1fe7c9deeec5dc90a2f47ff1684239519f2545b2228d3d91fb27df3189eea;

    /**
     * @dev Returns token info struct hash.
     */
    function hash(Receipt memory _receipt) internal pure returns (bytes32 digest) {
        bytes32 hashedReceiptMainchain = _receipt.mainchain.hash();
        bytes32 hashedReceiptRonin = _receipt.ronin.hash();
        bytes32 hashedReceiptInfo = _receipt.info.hash();

        /*
     * return
     *   keccak256(
     *     abi.encode(
     *       TYPE_HASH,
     *       _receipt.id,
     *       _receipt.kind,
     *       Token.hash(_receipt.mainchain),
     *       Token.hash(_receipt.ronin),
     *       Token.hash(_receipt.info)
     *     )
     *   );
     */
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, TYPE_HASH)
            mstore(add(ptr, 0x20), mload(_receipt)) // _receipt.id
            mstore(add(ptr, 0x40), mload(add(_receipt, 0x20))) // _receipt.kind
            mstore(add(ptr, 0x60), hashedReceiptMainchain)
            mstore(add(ptr, 0x80), hashedReceiptRonin)
            mstore(add(ptr, 0xa0), hashedReceiptInfo)
            digest := keccak256(ptr, 0xc0)
        }
    }

    /**
     * @dev Returns the receipt digest.
     */
    function receiptDigest(bytes32 _domainSeparator, bytes32 _receiptHash) internal pure returns (bytes32) {
        return _domainSeparator.toTypedDataHash(_receiptHash);
    }
}

interface IMainchainGatewayV3 is SignatureConsumer, MappedTokenConsumer {
    /**
     * @dev Error indicating that a query was made for an approved withdrawal.
     */
    error ErrQueryForApprovedWithdrawal();

    /**
     * @dev Error indicating that the daily withdrawal limit has been reached.
     */
    error ErrReachedDailyWithdrawalLimit();

    /**
     * @dev Error indicating that a query was made for a processed withdrawal.
     */
    error ErrQueryForProcessedWithdrawal();

    /**
     * @dev Error indicating that a query was made for insufficient vote weight.
     */
    error ErrQueryForInsufficientVoteWeight();

    /**
     * @dev Error indicating that the recovered signer from the signature has invalid vote weight.
     */
    error ErrInvalidSigner(address signer, uint256 weight, Signature sig);

    /**
     * @dev Error indicating that the total weight provided is null.
     */
    error ErrNullTotalWeightProvided(bytes4 msgSig);

    /// @dev Emitted when the deposit is requested
    event DepositRequested(bytes32 receiptHash, Transfer.Receipt receipt);
    /// @dev Emitted when the assets are withdrawn
    event Withdrew(bytes32 receiptHash, Transfer.Receipt receipt);
    /// @dev Emitted when the tokens are mapped
    event TokenMapped(address[] mainchainTokens, address[] roninTokens, TokenStandard[] standards);
    /// @dev Emitted when the wrapped native token contract is updated
    event WrappedNativeTokenContractUpdated(IWETH weth);
    /// @dev Emitted when the withdrawal is locked
    event WithdrawalLocked(bytes32 receiptHash, Transfer.Receipt receipt);
    /// @dev Emitted when the withdrawal is unlocked
    event WithdrawalUnlocked(bytes32 receiptHash, Transfer.Receipt receipt);

    /**
     * @dev Returns the WETH address.
     */
    function wrappedNativeToken() external view returns (IWETH);

    /**
     * @dev Returns the domain separator.
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /**
     * @dev Returns deposit count.
     */
    function depositCount() external view returns (uint256);

    /**
     * @dev Sets the wrapped native token contract.
     *
     * Requirements:
     * - The method caller is admin.
     *
     * Emits the `WrappedNativeTokenContractUpdated` event.
     *
     */
    function setWrappedNativeTokenContract(IWETH _wrappedToken) external;

    /**
     * @dev Returns whether the withdrawal is locked.
     */
    function withdrawalLocked(uint256 withdrawalId) external view returns (bool);

    /**
     * @dev Returns the withdrawal hash.
     */
    function withdrawalHash(uint256 withdrawalId) external view returns (bytes32);

    /**
     * @dev Locks the assets and request deposit.
     */
    function requestDepositFor(Transfer.Request calldata _request) external payable;

    /**
     * @dev Withdraws based on the receipt and the validator signatures.
     * Returns whether the withdrawal is locked.
     *
     * Emits the `Withdrew` once the assets are released.
     *
     */
    function submitWithdrawal(Transfer.Receipt memory _receipt, Signature[] memory _signatures)
        external
        returns (bool _locked);

    /**
     * @dev Approves a specific withdrawal.
     *
     * Requirements:
     * - The method caller is a validator.
     *
     * Emits the `Withdrew` once the assets are released.
     *
     */
    function unlockWithdrawal(Transfer.Receipt calldata _receipt) external;

    /**
     * @dev Maps mainchain tokens to Ronin network.
     *
     * Requirement:
     * - The method caller is admin.
     * - The arrays have the same length and its length larger than 0.
     *
     * Emits the `TokenMapped` event.
     *
     */
    function mapTokens(
        address[] calldata _mainchainTokens,
        address[] calldata _roninTokens,
        TokenStandard[] calldata _standards
    ) external;

    /**
     * @dev Maps mainchain tokens to Ronin network and sets thresholds.
     *
     * Requirement:
     * - The method caller is admin.
     * - The arrays have the same length and its length larger than 0.
     *
     * Emits the `TokenMapped` event.
     *
     */
    function mapTokensAndThresholds(
        address[] calldata _mainchainTokens,
        address[] calldata _roninTokens,
        TokenStandard[] calldata _standards,
        uint256[][4] calldata _thresholds
    ) external;

    /**
     * @dev Returns token address on Ronin network.
     * Note: Reverts for unsupported token.
     */
    function getRoninToken(address _mainchainToken) external view returns (MappedToken memory _token);
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

interface ICCIPLiquidityContainer {
    function provideLiquidity(uint64 remoteChainSelector, uint256 amount) external;

    function provideLiquidity(uint256 amount) external;

    function provideSiloedLiquidity(uint64 remoteChainSelector, uint256 amount) external;
}

abstract contract AssetMigration is HasProxyAdmin, Pausable, AccessControlEnumerable {
    /// @dev Error when the token is not whitelisted before
    error ErrNotWhitelistedToken(address token);
    /// @dev Error when the native token is whitelisted instead of the wrapped token
    error ErrWhitelistWrappedTokenInstead();

    /// @dev The native token indicator address
    address internal constant _NATIVE_TOKEN_INDICATOR = address(0);
    /// @dev The migrator role
    bytes32 internal constant _MIGRATOR_ROLE = keccak256("MIGRATOR_ROLE");

    /// @custom:storage-location erc7201:ronin.bridge.AssetMigration
    struct AssetMigrationStorage {
        // Whitelisted addresses
        mapping(address token => WhitelistInfo wlInfo) _wlInfo;
    }

    struct WhitelistInfo {
        // CCIP Pool address
        address _recipient;
        // Remote chain selector
        // If zero, will interact `_recipient` via ICCIPLiquidityContainer.provideLiquidity(uint256)
        uint64 _remoteChainSelector;
    }

    /// @dev Emitted when recipients are whitelisted.
    event WhitelistUpdated(address indexed by, address[] tokens, address[] recipients, uint64[] remoteChainSelectors);

    /**
     * @dev Modifier to check if `a` and `b` have the same length and are not empty.
     */
    modifier validInput(uint256[] memory a, uint256[] memory b) {
        _requireValidInput(a, b);
        _;
    }

    /**
     * @dev Returns the wrapped native token.
     * - For `MainchainGatewayV3`, it MUST return the WETH token.
     */
    function wrappedNativeToken() external view virtual returns (IWETH) {
        revert("Not implemented");
    }

    /**
     * @dev Migrates the given tokens to the specified addresses.
     *
     * When the token is the native (i.e RON or ETH), it will be wrapped (i.e WRON, WETH).
     *
     * Requirements:
     * - The caller must be the migrator.
     * - The length of the arrays must be the same.
     * - The length of the arrays must not be zero.
     */
    function migrateERC20(address[] calldata tokens, uint256[] calldata amounts)
        external
        whenNotPaused
        onlyRole(_MIGRATOR_ROLE)
        validInput(_toUint256s(tokens), amounts)
    {
        uint256 length = amounts.length;
        IERC20 token;

        for (uint256 i; i < length; ++i) {
            token = IERC20(tokens[i]);

            if (address(token) == address(_NATIVE_TOKEN_INDICATOR)) {
                token = _wrap(amounts[i]);
            }

            address recipient = _getRecipient(address(token));
            uint64 remoteChainSelector = _getRemoteChainSelector(address(token));

            // Approve specific allowance to the Chainlink Pool
            token.approve(recipient, amounts[i]);

            // This should revert if the pool did not accept the tokens
            if (remoteChainSelector == 0) {
                ICCIPLiquidityContainer(recipient).provideLiquidity(amounts[i]);
            } else {
                try ICCIPLiquidityContainer(recipient).provideSiloedLiquidity(remoteChainSelector, amounts[i]) {
                    // Do nothing
                } catch {
                    ICCIPLiquidityContainer(recipient).provideLiquidity(remoteChainSelector, amounts[i]);
                }
            }
        }
    }

    /**
     * @dev Whitelists the recipients for the given tokens, with targeted remote chain selector.
     *
     * Requirements:
     * - Must go through proposal via `BridgeManager`.
     * - The length of the arrays must be the same.
     */
    function whitelist(address[] calldata tokens, address[] calldata recipients, uint64[] calldata remoteChainSelectors)
        external
        whenNotPaused
        onlyProxyAdmin
    {
        _whitelist(tokens, recipients, remoteChainSelectors);
    }

    /**
     * @dev Get all whitelisted addresses for the given tokens.
     */
    function getWhitelistedAddresses(address[] calldata tokens)
        external
        view
        returns (address[] memory whitelisteds, uint64[] memory remoteChainSelectors)
    {
        AssetMigrationStorage storage $ = _getAssetMigration();

        uint256 length = tokens.length;
        whitelisteds = new address[](length);
        remoteChainSelectors = new uint64[](length);

        for (uint256 i; i < length; ++i) {
            WhitelistInfo storage $wlInfo = $._wlInfo[tokens[i]];

            whitelisteds[i] = $wlInfo._recipient;
            remoteChainSelectors[i] = $wlInfo._remoteChainSelector;
        }
    }

    /**
     * @dev Returns the pointer of the AssetMigrationStorage struct.
     */
    function _getAssetMigration() private pure returns (AssetMigrationStorage storage $) {
        // value is equal to keccak256(abi.encode(uint256(keccak256("ronin.bridge.AssetMigration")) - 1)) &
        // ~bytes32(uint256(0xff))
        bytes32 storageLoc = 0x06e9d321f1aa72738d882c53ba334d30578ba3db2fbd2df66a07059b7abc9900;

        assembly ("memory-safe") {
            $.slot := storageLoc
        }
    }

    /**
     * @dev Converts the native token to its wrapped version.
     */
    function _wrap(uint256 amount) internal returns (IERC20) {
        IWETH w = this.wrappedNativeToken();
        w.deposit{value: amount}();

        return IERC20(address(w));
    }

    /**
     * @dev Sets the whitelist status of the recipients.
     * This function does not revert when the recipient is already whitelisted or not.
     * if `recipient` is zero address, it will remove the whitelist status.
     */
    function _whitelist(
        address[] calldata tokens,
        address[] calldata recipients,
        uint64[] calldata remoteChainSelectors
    )
        internal
        validInput(_toUint256s(recipients), _toUint256s(tokens))
        validInput(_toUint256s(recipients), _toUint256s(remoteChainSelectors))
    {
        AssetMigrationStorage storage $ = _getAssetMigration();
        uint256 length = recipients.length;

        for (uint256 i; i < length; ++i) {
            require(tokens[i] != _NATIVE_TOKEN_INDICATOR, ErrWhitelistWrappedTokenInstead());

            WhitelistInfo storage $wlInfo = $._wlInfo[tokens[i]];
            $wlInfo._recipient = recipients[i];
            $wlInfo._remoteChainSelector = remoteChainSelectors[i];
        }

        emit WhitelistUpdated(msg.sender, tokens, recipients, remoteChainSelectors);
    }

    /**
     * @dev Throws if the recipient is not whitelisted.
     * Returns the recipient address.
     */
    function _getRecipient(address token) internal view returns (address recipient) {
        recipient = _getAssetMigration()._wlInfo[token]._recipient;
        require(recipient != address(0x0), ErrNotWhitelistedToken(token));
    }

    /**
     * @dev Returns the remote chain selector.
     */
    function _getRemoteChainSelector(address token) internal view returns (uint64 remoteChainSelector) {
        remoteChainSelector = _getAssetMigration()._wlInfo[token]._remoteChainSelector;
    }

    /**
     * @dev Throws if `a` and `b` have different lengths or are empty.
     */
    function _requireValidInput(uint256[] memory a, uint256[] memory b) internal pure {
        require(a.length != 0, ErrEmptyArray());
        require(a.length == b.length, ErrLengthMismatch(msg.sig));
    }

    /**
     * @dev Converts the address array to uint256 array.
     */
    function _toUint256s(address[] memory a) internal pure returns (uint256[] memory b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    /**
     * @dev Converts the uint64 array to uint256 array.
     */
    function _toUint256s(uint64[] memory a) internal pure returns (uint256[] memory b) {
        assembly ("memory-safe") {
            b := a
        }
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
 * @dev Error indicating that a receipt is invalid.
 */
error ErrInvalidReceipt();

/**
 * @dev Error indicating that a token is not supported.
 */
error ErrUnsupportedToken();

/**
 * @dev Error indicating that a receipt kind is invalid.
 */
error ErrInvalidReceiptKind();

/**
 * @dev Error indicating that the chain ID is invalid.
 * @param msgSig The function signature (bytes4) of the operation that encountered an invalid chain ID.
 * @param actual Current chain ID that executing function.
 * @param expected Expected chain ID required for the tx to success.
 */
error ErrInvalidChainId(bytes4 msgSig, uint256 actual, uint256 expected);

/**
 * @dev Error indicating that an order is invalid.
 * @param msgSig The function signature (bytes4) of the operation that encountered an invalid order.
 */
error ErrInvalidOrder(bytes4 msgSig);

/**
 * @dev Error indicating that a request is invalid.
 */
error ErrInvalidRequest();

/**
 * @dev Error indicating that a token standard is invalid.
 */
error ErrInvalidTokenStandard();

contract MainchainGatewayV3 is
    WithdrawalLimitation,
    Initializable,
    AccessControlEnumerable,
    ERC1155Holder,
    IMainchainGatewayV3,
    HasContracts,
    AssetMigration,
    IBridgeManagerCallback
{
    using LibTokenInfo for TokenInfo;
    using Transfer for Transfer.Request;
    using Transfer for Transfer.Receipt;

    /// @dev Withdrawal unlocker role hash
    bytes32 public constant WITHDRAWAL_UNLOCKER_ROLE = keccak256("WITHDRAWAL_UNLOCKER_ROLE");

    /// @dev Wrapped native token address
    IWETH public override(AssetMigration, IMainchainGatewayV3) wrappedNativeToken;
    /// @dev Ronin network id
    uint256 public roninChainId;
    /// @dev Total deposit
    uint256 public depositCount;
    /// @dev Domain separator
    bytes32 internal _domainSeparator;
    /// @dev Mapping from mainchain token => token address on Ronin network
    mapping(address => MappedToken) internal _roninToken;
    /// @dev Mapping from withdrawal id => withdrawal hash
    mapping(uint256 => bytes32) public withdrawalHash;
    /// @dev Mapping from withdrawal id => locked
    mapping(uint256 => bool) public withdrawalLocked;

    /// @custom:deprecated Previously `_bridgeOperatorAddedBlock` (mapping(address => uint256))
    uint256 private ______deprecatedBridgeOperatorAddedBlock;
    /// @custom:deprecated Previously `_bridgeOperators` (uint256[])
    uint256 private ______deprecatedBridgeOperators;

    uint96 internal _totalOperatorWeight;
    mapping(address operator => uint96 weight) internal _operatorWeight;
    /// @custom:deprecated Previously `_wethUnwrapper` (address)
    uint256 private ______deprecatedWethUnwrapper;

    constructor() {
        _disableInitializers();
    }

    receive() external payable {
        _fallback();
    }

    function initializeV5(
        address migrator,
        address newEmergencyPauser,
        address[] calldata tokens,
        address[] calldata recipients,
        uint64[] calldata remoteChainSelectors
    ) external reinitializer(5) {
        _grantRole(_MIGRATOR_ROLE, migrator);

        uint8 forbidAllIndicator = type(uint8).max;

        _restrict(this.requestDepositFor.selector, forbidAllIndicator);
        _restrict(this.submitWithdrawal.selector, forbidAllIndicator);

        if (tokens.length != 0 || recipients.length != 0 || remoteChainSelectors.length != 0) {
            _whitelist(tokens, recipients, remoteChainSelectors);
        }
        emergencyPauser = newEmergencyPauser;
    }

    /**
     * @dev Grant or revoke permission to transfer NFTs on behalf of the bridge.
     * Requirements:
     * - The method caller is admin or already have migrator role.
     */
    function bulkSetApprovalForAll(address[] calldata nfts, address[] calldata operators, bool[] calldata approveds)
        external
    {
        if (msg.sender != _getProxyAdmin()) {
            _checkRole(_MIGRATOR_ROLE);
        }
        if (nfts.length != operators.length || nfts.length != approveds.length) {
            revert ErrLengthMismatch(msg.sig);
        }

        for (uint256 i; i < nfts.length; ++i) {
            IERC721(nfts[i]).setApprovalForAll(operators[i], approveds[i]);
        }
    }

    /**
     * @inheritdoc IMainchainGatewayV3
     */
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparator;
    }

    /**
     * @inheritdoc IMainchainGatewayV3
     */
    function setWrappedNativeTokenContract(IWETH _wrappedToken) external virtual onlyProxyAdmin {
        _setWrappedNativeTokenContract(_wrappedToken);
    }

    /**
     * @inheritdoc IMainchainGatewayV3
     */
    function requestDepositFor(Transfer.Request calldata _request) external payable virtual whenNotPaused {
        _requestDepositFor(_request, msg.sender);
    }

    /**
     * @inheritdoc IMainchainGatewayV3
     */
    function submitWithdrawal(Transfer.Receipt calldata _receipt, Signature[] calldata _signatures)
        external
        virtual
        whenNotPaused
        returns (bool _locked)
    {
        return _submitWithdrawal(_receipt, _signatures);
    }

    /**
     * @inheritdoc IMainchainGatewayV3
     */
    function unlockWithdrawal(Transfer.Receipt calldata receipt) external onlyRole(WITHDRAWAL_UNLOCKER_ROLE) {
        bytes32 _receiptHash = receipt.hash();
        if (withdrawalHash[receipt.id] != receipt.hash()) {
            revert ErrInvalidReceipt();
        }
        if (!withdrawalLocked[receipt.id]) {
            revert ErrQueryForApprovedWithdrawal();
        }
        delete withdrawalLocked[receipt.id];
        emit WithdrawalUnlocked(_receiptHash, receipt);

        address token = receipt.mainchain.tokenAddr;
        if (receipt.info.erc == TokenStandard.ERC20) {
            TokenInfo memory feeInfo = receipt.info;
            feeInfo.quantity = _computeFeePercentage(receipt.info.quantity, unlockFeePercentages[token]);
            TokenInfo memory withdrawInfo = receipt.info;
            withdrawInfo.quantity = receipt.info.quantity - feeInfo.quantity;

            feeInfo.handleAssetOut(payable(msg.sender), token, wrappedNativeToken);
            withdrawInfo.handleAssetOut(payable(receipt.mainchain.addr), token, wrappedNativeToken);
        } else {
            receipt.info.handleAssetOut(payable(receipt.mainchain.addr), token, wrappedNativeToken);
        }

        emit Withdrew(_receiptHash, receipt);
    }

    /**
     * @inheritdoc IMainchainGatewayV3
     */
    function mapTokens(
        address[] calldata _mainchainTokens,
        address[] calldata _roninTokens,
        TokenStandard[] calldata _standards
    ) external virtual onlyProxyAdmin {
        if (_mainchainTokens.length == 0) {
            revert ErrEmptyArray();
        }
        _mapTokens(_mainchainTokens, _roninTokens, _standards);
    }

    /**
     * @inheritdoc IMainchainGatewayV3
     */
    function mapTokensAndThresholds(
        address[] calldata _mainchainTokens,
        address[] calldata _roninTokens,
        TokenStandard[] calldata _standards,
        // _thresholds[0]: highTierThreshold
        // _thresholds[1]: lockedThreshold
        // _thresholds[2]: unlockFeePercentages
        // _thresholds[3]: dailyWithdrawalLimit
        uint256[][4] calldata _thresholds
    ) external virtual onlyProxyAdmin {
        if (_mainchainTokens.length == 0) {
            revert ErrEmptyArray();
        }
        _mapTokens(_mainchainTokens, _roninTokens, _standards);
        _setHighTierThresholds(_mainchainTokens, _thresholds[0]);
        _setLockedThresholds(_mainchainTokens, _thresholds[1]);
        _setUnlockFeePercentages(_mainchainTokens, _thresholds[2]);
        _setDailyWithdrawalLimits(_mainchainTokens, _thresholds[3]);
    }

    /**
     * @inheritdoc IMainchainGatewayV3
     */
    function getRoninToken(address mainchainToken) public view returns (MappedToken memory token) {
        token = _roninToken[mainchainToken];
        if (token.tokenAddr == address(0)) {
            revert ErrUnsupportedToken();
        }
    }

    /**
     * @dev Maps mainchain tokens to Ronin network.
     *
     * Requirement:
     * - The arrays have the same length.
     *
     * Emits the `TokenMapped` event.
     *
     */
    function _mapTokens(
        address[] calldata mainchainTokens,
        address[] calldata roninTokens,
        TokenStandard[] calldata standards
    ) internal virtual {
        if (!(mainchainTokens.length == roninTokens.length && mainchainTokens.length == standards.length)) {
            revert ErrLengthMismatch(msg.sig);
        }

        for (uint256 i; i < mainchainTokens.length; ++i) {
            _roninToken[mainchainTokens[i]].tokenAddr = roninTokens[i];
            _roninToken[mainchainTokens[i]].erc = standards[i];
        }

        emit TokenMapped(mainchainTokens, roninTokens, standards);
    }

    /**
     * @dev Submits withdrawal receipt.
     *
     * Requirements:
     * - The receipt kind is withdrawal.
     * - The receipt is to withdraw on this chain.
     * - The receipt is not used to withdraw before.
     * - The withdrawal is not reached the limit threshold.
     * - The signer weight total is larger than or equal to the minimum threshold.
     * - The signature signers are in order.
     *
     * Emits the `Withdrew` once the assets are released.
     *
     */
    function _submitWithdrawal(Transfer.Receipt calldata receipt, Signature[] memory signatures)
        internal
        virtual
        returns (bool locked)
    {
        uint256 id = receipt.id;
        uint256 quantity = receipt.info.quantity;
        address tokenAddr = receipt.mainchain.tokenAddr;

        receipt.info.validate();
        _requireNotRestricted(receipt.info.erc);
        if (receipt.kind != Transfer.Kind.Withdrawal) {
            revert ErrInvalidReceiptKind();
        }

        if (receipt.mainchain.chainId != block.chainid) {
            revert ErrInvalidChainId(msg.sig, receipt.mainchain.chainId, block.chainid);
        }

        MappedToken memory token = getRoninToken(receipt.mainchain.tokenAddr);

        if (
            !(
                token.erc == receipt.info.erc && token.tokenAddr == receipt.ronin.tokenAddr
                    && receipt.ronin.chainId == roninChainId
            )
        ) {
            revert ErrInvalidReceipt();
        }

        if (withdrawalHash[id] != 0) {
            revert ErrQueryForProcessedWithdrawal();
        }

        if (!(receipt.info.erc == TokenStandard.ERC721 || !_reachedWithdrawalLimit(tokenAddr, quantity))) {
            revert ErrReachedDailyWithdrawalLimit();
        }

        bytes32 receiptHash = receipt.hash();
        bytes32 receiptDigest = Transfer.receiptDigest(_domainSeparator, receiptHash);

        uint256 minimumWeight;
        (minimumWeight, locked) = _computeMinVoteWeight(receipt.info.erc, tokenAddr, quantity);

        {
            bool passed;
            address signer;
            address lastSigner;
            Signature memory sig;
            uint256 accumWeight;
            for (uint256 i; i < signatures.length; i++) {
                sig = signatures[i];
                signer = ECDSA.recover({hash: receiptDigest, v: sig.v, r: sig.r, s: sig.s});
                if (lastSigner >= signer) {
                    revert ErrInvalidOrder(msg.sig);
                }

                lastSigner = signer;

                uint256 w = _getWeight(signer);
                if (w == 0) {
                    revert ErrInvalidSigner(signer, w, sig);
                }

                accumWeight += w;
                if (accumWeight >= minimumWeight) {
                    passed = true;
                    break;
                }
            }

            if (!passed) {
                revert ErrQueryForInsufficientVoteWeight();
            }
            withdrawalHash[id] = receiptHash;
        }

        if (locked) {
            withdrawalLocked[id] = true;
            emit WithdrawalLocked(receiptHash, receipt);
            return locked;
        }

        _recordWithdrawal(tokenAddr, quantity);
        receipt.info.handleAssetOut(payable(receipt.mainchain.addr), tokenAddr, wrappedNativeToken);
        emit Withdrew(receiptHash, receipt);
    }

    /**
     * @dev Requests deposit made by `_requester` address.
     *
     * Requirements:
     * - The token info is valid.
     * - The `msg.value` is 0 while depositing ERC20 token.
     * - The `msg.value` is equal to deposit quantity while depositing native token.
     *
     * Emits the `DepositRequested` event.
     *
     */
    function _requestDepositFor(Transfer.Request memory _request, address _requester) internal virtual {
        MappedToken memory _token;
        address mainchainWeth = address(wrappedNativeToken);

        _request.info.validate();
        _requireNotRestricted(_request.info.erc);
        if (_request.tokenAddr == address(0)) {
            if (_request.info.quantity != msg.value) {
                revert ErrInvalidRequest();
            }

            _token = getRoninToken(mainchainWeth);
            if (_token.erc != _request.info.erc) {
                revert ErrInvalidTokenStandard();
            }

            _request.tokenAddr = mainchainWeth;
        } else {
            if (msg.value != 0) {
                revert ErrInvalidRequest();
            }

            _token = getRoninToken(_request.tokenAddr);
            if (_token.erc != _request.info.erc) {
                revert ErrInvalidTokenStandard();
            }

            _request.info.handleAssetIn(_requester, _request.tokenAddr);

            /**
             * Withdraw if token is WETH
             *
             * `IWETH.withdraw` only sends 2300 gas, which might be insufficient when recipient is a proxy, in this case, gateway proxy.
             * However, the storage accesses of proxy relating variables on Shanghai hardfork are warm-access, only requires additional 100*2 gas. So it should be safe,
             * no need to go via a mediator of WETH unwrapper.
             */
            if (mainchainWeth == _request.tokenAddr) {
                IWETH(mainchainWeth).withdraw(_request.info.quantity);
            }
        }

        uint256 _depositId = depositCount++;
        Transfer.Receipt memory _receipt =
            _request.into_deposit_receipt(_requester, _depositId, _token.tokenAddr, roninChainId);

        emit DepositRequested(_receipt.hash(), _receipt);
    }

    /**
     * @dev Returns the minimum vote weight for the token.
     */
    function _computeMinVoteWeight(TokenStandard _erc, address _token, uint256 _quantity)
        internal
        virtual
        returns (uint256 _weight, bool _locked)
    {
        uint256 _totalWeight = _getTotalWeight();
        _weight = _minimumVoteWeight(_totalWeight);
        if (_erc == TokenStandard.ERC20) {
            if (highTierThreshold[_token] <= _quantity) {
                _weight = _highTierVoteWeight(_totalWeight);
            }
            _locked = _lockedWithdrawalRequest(_token, _quantity);
        }
    }

    /**
     * @dev Update domain separator.
     */
    function _updateDomainSeparator() internal {
        /*
     * _domainSeparator = keccak256(
     *   abi.encode(
     *     keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
     *     keccak256("MainchainGatewayV2"),
     *     keccak256("2"),
     *     block.chainid,
     *     address(this)
     *   )
     * );
     */
        assembly {
            let ptr := mload(0x40)
            // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
            mstore(ptr, 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f)
            // keccak256("MainchainGatewayV2")
            mstore(add(ptr, 0x20), 0x159f52c1e3a2b6a6aad3950adf713516211484e0516dad685ea662a094b7c43b)
            // keccak256("2")
            mstore(add(ptr, 0x40), 0xad7c5bef027816a800da1736444fb58a807ef4c9603b7848673f7e3a68eb14a5)
            mstore(add(ptr, 0x60), chainid())
            mstore(add(ptr, 0x80), address())
            sstore(_domainSeparator.slot, keccak256(ptr, 0xa0))
        }
    }

    /**
     * @dev Sets the WETH contract.
     *
     * Emits the `WrappedNativeTokenContractUpdated` event.
     *
     */
    function _setWrappedNativeTokenContract(IWETH _wrappedToken) internal {
        wrappedNativeToken = _wrappedToken;
        emit WrappedNativeTokenContractUpdated(_wrappedToken);
    }

    /**
     * @dev Receives ETH from WETH or revert if sender is not WETH.
     */
    function _fallback() internal virtual {
        if (msg.sender != address(wrappedNativeToken)) {
            revert ErrInvalidRequest();
        }
    }

    /**
     * @inheritdoc GatewayV3
     */
    function _getTotalWeight() internal view override returns (uint256 totalWeight) {
        totalWeight = _totalOperatorWeight;
        if (totalWeight == 0) {
            revert ErrNullTotalWeightProvided(msg.sig);
        }
    }

    /**
     * @dev Returns the weight of an address.
     */
    function _getWeight(address addr) internal view returns (uint256) {
        return _operatorWeight[addr];
    }

    ///////////////////////////////////////////////
    //                CALLBACKS
    ///////////////////////////////////////////////

    /**
     * @inheritdoc IBridgeManagerCallback
     */
    function onBridgeOperatorsAdded(address[] calldata operators, uint96[] calldata weights, bool[] memory addeds)
        external
        onlyContract(ContractType.BRIDGE_MANAGER)
        returns (bytes4)
    {
        uint256 length = operators.length;
        if (length != addeds.length || length != weights.length) {
            revert ErrLengthMismatch(msg.sig);
        }
        if (length == 0) {
            return IBridgeManagerCallback.onBridgeOperatorsAdded.selector;
        }

        for (uint256 i; i < length; ++i) {
            unchecked {
                if (addeds[i]) {
                    _totalOperatorWeight += weights[i];
                    _operatorWeight[operators[i]] = weights[i];
                }
            }
        }

        return IBridgeManagerCallback.onBridgeOperatorsAdded.selector;
    }

    /**
     * @inheritdoc IBridgeManagerCallback
     */
    function onBridgeOperatorsRemoved(address[] calldata operators, bool[] calldata removeds)
        external
        onlyContract(ContractType.BRIDGE_MANAGER)
        returns (bytes4)
    {
        uint256 length = operators.length;
        if (length != removeds.length) {
            revert ErrLengthMismatch(msg.sig);
        }
        if (length == 0) {
            return IBridgeManagerCallback.onBridgeOperatorsRemoved.selector;
        }

        uint96 totalRemovingWeight;
        for (uint256 i; i < length; ++i) {
            unchecked {
                if (removeds[i]) {
                    totalRemovingWeight += _operatorWeight[operators[i]];
                    delete _operatorWeight[operators[i]];
                }
            }
        }

        _totalOperatorWeight -= totalRemovingWeight;

        return IBridgeManagerCallback.onBridgeOperatorsRemoved.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlEnumerable, IERC165, ERC1155Receiver)
        returns (bool)
    {
        return interfaceId == type(IMainchainGatewayV3).interfaceId
            || interfaceId == type(IBridgeManagerCallback).interfaceId || super.supportsInterface(interfaceId);
    }
}
