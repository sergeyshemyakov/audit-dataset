// SPDX-License-Identifier: Unknown
pragma solidity 0.8.24;

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
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reinitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
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
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
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
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Pointer to storage slot. Allows integrators to override it with a custom storage location.
     *
     * NOTE: Consider following the ERC-7201 formula to derive storage locations.
     */
    function _initializableStorageSlot() internal pure virtual returns (bytes32) {
        return INITIALIZABLE_STORAGE;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        bytes32 slot = _initializableStorageSlot();
        assembly {
            $.slot := slot
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

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
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165Upgradeable is Initializable, IERC165 {
    function __ERC165_init() internal onlyInitializing {}

    function __ERC165_init_unchained() internal onlyInitializing {}
    /**
     * @dev See {IERC165-supportsInterface}.
     */

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Required interface of an ERC-721 compliant contract.
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
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC-721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC-721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

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
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/**
 * @dev Standard ERC-721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Minimal ERC-721 implementation that supports null address ownership.
 * Unlike standard ERC-721, tokens can be owned by address(0) and still exist.
 * This is required for Ethscriptions protocol compatibility.
 *
 * Simplifications from standard ERC-721:
 * - No safe transfer functionality (no onERC721Received checks)
 * - No approval functionality (approve, getApproved, setApprovalForAll removed)
 * - No tokenURI implementation (must be overridden by child)
 * - No burn function (transfer to address(0) instead)
 * - Keeps only core transfer and ownership logic
 */
abstract contract ERC721EthscriptionsUpgradeable is
    Initializable,
    ContextUpgradeable,
    ERC165Upgradeable,
    IERC721,
    IERC721Metadata,
    IERC721Errors
{
    // Errors for enumerable functionality
    error ERC721OutOfBoundsIndex(address owner, uint256 index);
    error ERC721EnumerableForbiddenBatchMint();

    /// @custom:storage-location erc7201:ethscriptions.storage.ERC721
    struct ERC721Storage {
        string _name;
        string _symbol;
        // Token owners (can be address(0) for null-owned tokens)
        mapping(uint256 tokenId => address) _owners;
        // Balance per address (including null address)
        mapping(address owner => uint256) _balances;
        // === Ethscriptions-specific storage ===
        // Explicit existence tracking (true = token exists)
        mapping(uint256 tokenId => bool) _existsFlag;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721.ethscriptions")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721StorageLocation = 0x03f081da1bf59345b57bd2323b19ea3e2315141ee27bd283a32089733412b400;

    function _getERC721Storage() private pure returns (ERC721Storage storage $) {
        assembly {
            $.slot := ERC721StorageLocation
        }
    }

    /// @custom:storage-location erc7201:openzeppelin.storage.ERC721Enumerable
    struct ERC721EnumerableStorage {
        mapping(address owner => mapping(uint256 index => uint256)) _ownedTokens;
        mapping(uint256 tokenId => uint256) _ownedTokensIndex;
        uint256[] _allTokens;
        mapping(uint256 tokenId => uint256) _allTokensIndex;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721Enumerable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721EnumerableStorageLocation =
        0x645e039705490088daad89bae25049a34f4a9072d398537b1ab2425f24cbed00;

    function _getERC721EnumerableStorage() internal pure returns (ERC721EnumerableStorage storage $) {
        assembly {
            $.slot := ERC721EnumerableStorageLocation
        }
    }

    /**
     * @dev Initializes the contract.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        ERC721Storage storage $ = _getERC721Storage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165Upgradeable, IERC165)
        returns (bool)
    {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     * Modified to support null address balance queries.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     * Must be overridden by child contract.
     */
    function name() public view virtual returns (string memory) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     * Must be overridden by child contract.
     */
    function symbol() public view virtual returns (string memory) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     * Must be overridden by child contract.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory);

    /// @dev Return token owned by `owner` at `index`.
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
        ERC721EnumerableStorage storage $ = _getERC721EnumerableStorage();
        if (index >= balanceOf(owner)) {
            revert ERC721OutOfBoundsIndex(owner, index);
        }
        return $._ownedTokens[owner][index];
    }

    /**
     * @dev Approval functions removed - not needed for Ethscriptions.
     * These can be added back in child contracts if needed.
     */
    function approve(address, uint256) public virtual {
        revert("Approvals not supported");
    }

    function getApproved(uint256 tokenId) public view virtual returns (address) {
        if (!_tokenExists(tokenId)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return address(0);
    }

    function setApprovalForAll(address, bool) public virtual {
        revert("Approvals not supported");
    }

    function isApprovedForAll(address, address) public view virtual returns (bool) {
        return false;
    }

    /**
     * @dev See {IERC721-transferFrom}.
     * Modified to allow transfers to address(0) (not burns, just transfers).
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        // Removed check for to == address(0) to allow null transfers
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev Safe transfer functions removed - not needed for Ethscriptions.
     */
    function safeTransferFrom(address, address, uint256) public virtual {
        revert("Safe transfers not supported");
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public virtual {
        revert("Safe transfers not supported");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist.
     * Modified to check existence flag instead of owner == address(0).
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._owners[tokenId]; // May be address(0) for null-owned
    }

    /**
     * @dev Simplified authorization - only owner can transfer.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        ERC721Storage storage $ = _getERC721Storage();

        if (!$._existsFlag[tokenId]) {
            revert ERC721NonexistentToken(tokenId);
        }

        // Only the owner can transfer (no approvals)
        // Since spender (msg.sender) can never be address(0), null-owned tokens are automatically protected
        if (owner != spender) {
            revert ERC721InsufficientApproval(spender, tokenId);
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`.
     * Modified to handle null address as a valid owner.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        ERC721Storage storage $ = _getERC721Storage();

        bool existed = $._existsFlag[tokenId];
        address from = _ownerOf(tokenId);

        // Perform authorization check if needed
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Handle transfer/mint - enumeration helpers handle balance updates
        if (existed) {
            // This is a transfer
            if (from != to) {
                // Remove from old owner (also decrements from's balance)
                _removeTokenFromOwnerEnumeration(from, tokenId);
                // Add to new owner (also increments to's balance)
                _addTokenToOwnerEnumeration(to, tokenId);
            }
        } else {
            // This is a mint
            $._existsFlag[tokenId] = true;

            // Allow derived contracts to adjust enumeration state for newly minted token
            _afterTokenMint(tokenId);

            // Add to owner enumeration (also increments balance)
            _addTokenToOwnerEnumeration(to, tokenId);
        }

        // Update owner and emit
        $._owners[tokenId] = to;
        emit Transfer(from, to, tokenId);

        return from;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     * Routes through _update to ensure consistent behavior.
     * Does not allow minting directly to address(0) - mint then transfer instead.
     */
    function _mint(address to, uint256 tokenId) internal {
        ERC721Storage storage $ = _getERC721Storage();

        // Check if token already exists
        if ($._existsFlag[tokenId]) {
            revert ERC721InvalidSender(address(0));
        }

        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }

        // Mint the token via _update
        _update(to, tokenId, address(0));
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     * Modified to allow transfers to address(0) (not burns).
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        address previousOwner = _update(to, tokenId, address(0));
        if (!_tokenExists(tokenId)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Modified to use existence flag instead of owner == address(0).
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        ERC721Storage storage $ = _getERC721Storage();
        if (!$._existsFlag[tokenId]) {
            revert ERC721NonexistentToken(tokenId);
        }
        return $._owners[tokenId]; // May be address(0) for null-owned
    }

    /**
     * @dev Returns whether `tokenId` exists.
     * Tokens start existing when they are minted (`_mint`).
     */
    function _tokenExists(uint256 tokenId) internal view returns (bool) {
        ERC721Storage storage $ = _getERC721Storage();
        return $._existsFlag[tokenId];
    }

    /**
     * @dev Sets the existence flag for a token. Used by child contracts for removal.
     */
    function _setTokenExists(uint256 tokenId, bool exists) internal {
        ERC721Storage storage $ = _getERC721Storage();

        // If removing a token, also remove from enumeration and update balance
        if (!exists && $._existsFlag[tokenId]) {
            address owner = $._owners[tokenId];

            _beforeTokenRemoval(tokenId, owner);

            // Remove from enumerations (balance is decremented inside _removeTokenFromOwnerEnumeration)
            _removeTokenFromOwnerEnumeration(owner, tokenId);

            // Clear owner storage for cleanliness
            delete $._owners[tokenId];
        }

        $._existsFlag[tokenId] = exists;
    }

    /**
     * @dev Override to forbid batch minting which would break enumeration.
     */
    function _increaseBalance(address account, uint128 amount) internal virtual {
        if (amount > 0) {
            revert ERC721EnumerableForbiddenBatchMint();
        }
        // Note: We don't have a parent _increaseBalance to call since we're not inheriting from ERC721Upgradeable
        // This function exists just to prevent batch minting attempts
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * Also increments the owner's balance.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        ERC721Storage storage $ = _getERC721Storage();
        ERC721EnumerableStorage storage $enum = _getERC721EnumerableStorage();

        // Use current balance as the index for the new token
        uint256 length = $._balances[to];
        $enum._ownedTokens[to][length] = tokenId;
        $enum._ownedTokensIndex[tokenId] = length;

        // Now increment the balance
        unchecked {
            $._balances[to] += 1;
        }
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures.
     * Also decrements the owner's balance.
     * Note that while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        ERC721Storage storage $ = _getERC721Storage();
        ERC721EnumerableStorage storage $enum = _getERC721EnumerableStorage();

        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        // First decrement the balance
        unchecked {
            $._balances[from] -= 1;
        }

        // Now use the updated balance as the last index
        uint256 lastTokenIndex = $._balances[from];
        uint256 tokenIndex = $enum._ownedTokensIndex[tokenId];

        mapping(uint256 index => uint256) storage _ownedTokensByOwner = $enum._ownedTokens[from];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokensByOwner[lastTokenIndex];

            _ownedTokensByOwner[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            $enum._ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete $enum._ownedTokensIndex[tokenId];
        delete _ownedTokensByOwner[lastTokenIndex];
    }

    /**
     * @dev Hook for derived contracts to react to token minting.
     */
    function _afterTokenMint(uint256) internal virtual {}

    /**
     * @dev Hook for derived contracts to react to token removal.
     */
    function _beforeTokenRemoval(uint256, address) internal virtual {}
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

/**
 * @dev Enumerable mixin for Ethscriptions-style collections where token IDs are
 * sequential, start at zero, and tokens are never burned.
 */
abstract contract ERC721EthscriptionsSequentialEnumerableUpgradeable is
    ERC721EthscriptionsUpgradeable,
    IERC721Enumerable
{
    /// @dev Raised when a mint attempts to skip or reuse a token ID.
    error ERC721SequentialEnumerableInvalidTokenId(uint256 expected, uint256 actual);
    /// @dev Raised if a contract attempts to remove a token from supply.
    error ERC721SequentialEnumerableTokenRemoval(uint256 tokenId);

    /// @custom:storage-location erc7201:ethscriptions.storage.ERC721SequentialEnumerable
    struct ERC721SequentialEnumerableStorage {
        uint256 _mintCount;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721SequentialEnumerableStorageLocation")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC721SequentialEnumerableStorageLocation =
        0x154e8d00bf5f00755eebdfa0d432d05cad242742a46a00bbdb15798f33342700;

    function _getERC721SequentialEnumerableStorage()
        private
        pure
        returns (ERC721SequentialEnumerableStorage storage $)
    {
        assembly {
            $.slot := ERC721SequentialEnumerableStorageLocation
        }
    }

    /// @inheritdoc ERC165Upgradeable
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721EthscriptionsUpgradeable, IERC165)
        returns (bool)
    {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IERC721Enumerable
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override(IERC721Enumerable, ERC721EthscriptionsUpgradeable)
        returns (uint256)
    {
        return super.tokenOfOwnerByIndex(owner, index);
    }

    /// @inheritdoc IERC721Enumerable
    function totalSupply() public view virtual override returns (uint256) {
        ERC721SequentialEnumerableStorage storage $ = _getERC721SequentialEnumerableStorage();
        return $._mintCount;
    }

    /// @inheritdoc IERC721Enumerable
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        if (index >= totalSupply()) {
            revert ERC721OutOfBoundsIndex(address(0), index);
        }
        return index;
    }

    function _afterTokenMint(uint256 tokenId) internal virtual override {
        ERC721SequentialEnumerableStorage storage $ = _getERC721SequentialEnumerableStorage();

        uint256 expectedId = $._mintCount;
        if (tokenId != expectedId) {
            revert ERC721SequentialEnumerableInvalidTokenId(expectedId, tokenId);
        }

        unchecked {
            $._mintCount = expectedId + 1;
        }
    }

    function _beforeTokenRemoval(uint256 tokenId, address) internal virtual override {
        revert ERC721SequentialEnumerableTokenRemoval(tokenId);
    }
}

/// @notice Library for byte related operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBytes.sol)
library LibBytes {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Goated bytes storage struct that totally MOGs, no cap, fr.
    /// Uses less gas and bytecode than Solidity's native bytes storage. It's meta af.
    /// Packs length with the first 31 bytes if <255 bytes, so it’s mad tight.
    struct BytesStorage {
        bytes32 _spacer;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the bytes.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  BYTE STORAGE OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sets the value of the bytes storage `$` to `s`.
    function set(BytesStorage storage $, bytes memory s) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(s)
            let packed := or(0xff, shl(8, n))
            for { let i := 0 } 1 {} {
                if iszero(gt(n, 0xfe)) {
                    i := 0x1f
                    packed := or(n, shl(8, mload(add(s, i))))
                    if iszero(gt(n, i)) { break }
                }
                let o := add(s, 0x20)
                mstore(0x00, $.slot)
                for { let p := keccak256(0x00, 0x20) } 1 {} {
                    sstore(add(p, shr(5, i)), mload(add(o, i)))
                    i := add(i, 0x20)
                    if iszero(lt(i, n)) { break }
                }
                break
            }
            sstore($.slot, packed)
        }
    }

    /// @dev Sets the value of the bytes storage `$` to `s`.
    function setCalldata(BytesStorage storage $, bytes calldata s) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let packed := or(0xff, shl(8, s.length))
            for { let i := 0 } 1 {} {
                if iszero(gt(s.length, 0xfe)) {
                    i := 0x1f
                    packed := or(s.length, shl(8, shr(8, calldataload(s.offset))))
                    if iszero(gt(s.length, i)) { break }
                }
                mstore(0x00, $.slot)
                for { let p := keccak256(0x00, 0x20) } 1 {} {
                    sstore(add(p, shr(5, i)), calldataload(add(s.offset, i)))
                    i := add(i, 0x20)
                    if iszero(lt(i, s.length)) { break }
                }
                break
            }
            sstore($.slot, packed)
        }
    }

    /// @dev Sets the value of the bytes storage `$` to the empty bytes.
    function clear(BytesStorage storage $) internal {
        delete $._spacer;
    }

    /// @dev Returns whether the value stored is `$` is the empty bytes "".
    function isEmpty(BytesStorage storage $) internal view returns (bool) {
        return uint256($._spacer) & 0xff == uint256(0);
    }

    /// @dev Returns the length of the value stored in `$`.
    function length(BytesStorage storage $) internal view returns (uint256 result) {
        result = uint256($._spacer);
        /// @solidity memory-safe-assembly
        assembly {
            let n := and(0xff, result)
            result := or(mul(shr(8, result), eq(0xff, n)), mul(n, iszero(eq(0xff, n))))
        }
    }

    /// @dev Returns the value stored in `$`.
    function get(BytesStorage storage $) internal view returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let o := add(result, 0x20)
            let packed := sload($.slot)
            let n := shr(8, packed)
            for { let i := 0 } 1 {} {
                if iszero(eq(or(packed, 0xff), packed)) {
                    mstore(o, packed)
                    n := and(0xff, packed)
                    i := 0x1f
                    if iszero(gt(n, i)) { break }
                }
                mstore(0x00, $.slot)
                for { let p := keccak256(0x00, 0x20) } 1 {} {
                    mstore(add(o, i), sload(add(p, shr(5, i))))
                    i := add(i, 0x20)
                    if iszero(lt(i, n)) { break }
                }
                break
            }
            mstore(result, n) // Store the length of the memory.
            mstore(add(o, n), 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(add(o, n), 0x20)) // Allocate memory.
        }
    }

    /// @dev Returns the uint8 at index `i`. If out-of-bounds, returns 0.
    function uint8At(BytesStorage storage $, uint256 i) internal view returns (uint8 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for { let packed := sload($.slot) } 1 {} {
                if iszero(eq(or(packed, 0xff), packed)) {
                    if iszero(gt(i, 0x1e)) {
                        result := byte(i, packed)
                        break
                    }
                    if iszero(gt(i, and(0xff, packed))) {
                        mstore(0x00, $.slot)
                        let j := sub(i, 0x1f)
                        result := byte(and(j, 0x1f), sload(add(keccak256(0x00, 0x20), shr(5, j))))
                    }
                    break
                }
                if iszero(gt(i, shr(8, packed))) {
                    mstore(0x00, $.slot)
                    result := byte(and(i, 0x1f), sload(add(keccak256(0x00, 0x20), shr(5, i))))
                }
                break
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      BYTES OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `subject` all occurrences of `needle` replaced with `replacement`.
    function replace(bytes memory subject, bytes memory needle, bytes memory replacement)
        internal
        pure
        returns (bytes memory result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let needleLen := mload(needle)
            let replacementLen := mload(replacement)
            let d := sub(result, subject) // Memory difference.
            let i := add(subject, 0x20) // Subject bytes pointer.
            mstore(0x00, add(i, mload(subject))) // End of subject.
            if iszero(gt(needleLen, mload(subject))) {
                let subjectSearchEnd := add(sub(mload(0x00), needleLen), 1)
                let h := 0 // The hash of `needle`.
                if iszero(lt(needleLen, 0x20)) { h := keccak256(add(needle, 0x20), needleLen) }
                let s := mload(add(needle, 0x20))
                for { let m := shl(3, sub(0x20, and(needleLen, 0x1f))) } 1 {} {
                    let t := mload(i)
                    // Whether the first `needleLen % 32` bytes of `subject` and `needle` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(i, needleLen), h)) {
                                mstore(add(i, d), t)
                                i := add(i, 1)
                                if iszero(lt(i, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        // Copy the `replacement` one word at a time.
                        for { let j := 0 } 1 {} {
                            mstore(add(add(i, d), j), mload(add(add(replacement, 0x20), j)))
                            j := add(j, 0x20)
                            if iszero(lt(j, replacementLen)) { break }
                        }
                        d := sub(add(d, replacementLen), needleLen)
                        if needleLen {
                            i := add(i, needleLen)
                            if iszero(lt(i, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    mstore(add(i, d), t)
                    i := add(i, 1)
                    if iszero(lt(i, subjectSearchEnd)) { break }
                }
            }
            let end := mload(0x00)
            let n := add(sub(d, add(result, 0x20)), end)
            // Copy the rest of the bytes one word at a time.
            for {} lt(i, end) { i := add(i, 0x20) } { mstore(add(i, d), mload(i)) }
            let o := add(i, d)
            mstore(o, 0) // Zeroize the slot after the bytes.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(bytes memory subject, bytes memory needle, uint256 from) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := not(0) // Initialize to `NOT_FOUND`.
            for { let subjectLen := mload(subject) } 1 {} {
                if iszero(mload(needle)) {
                    result := from
                    if iszero(gt(from, subjectLen)) { break }
                    result := subjectLen
                    break
                }
                let needleLen := mload(needle)
                let subjectStart := add(subject, 0x20)

                subject := add(subjectStart, from)
                let end := add(sub(add(subjectStart, subjectLen), needleLen), 1)
                let m := shl(3, sub(0x20, and(needleLen, 0x1f)))
                let s := mload(add(needle, 0x20))

                if iszero(and(lt(subject, end), lt(from, subjectLen))) { break }

                if iszero(lt(needleLen, 0x20)) {
                    for { let h := keccak256(add(needle, 0x20), needleLen) } 1 {} {
                        if iszero(shr(m, xor(mload(subject), s))) {
                            if eq(keccak256(subject, needleLen), h) {
                                result := sub(subject, subjectStart)
                                break
                            }
                        }
                        subject := add(subject, 1)
                        if iszero(lt(subject, end)) { break }
                    }
                    break
                }
                for {} 1 {} {
                    if iszero(shr(m, xor(mload(subject), s))) {
                        result := sub(subject, subjectStart)
                        break
                    }
                    subject := add(subject, 1)
                    if iszero(lt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right, starting from `from`. Optimized for byte needles.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOfByte(bytes memory subject, bytes1 needle, uint256 from) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := not(0) // Initialize to `NOT_FOUND`.
            if gt(mload(subject), from) {
                let start := add(subject, 0x20)
                let end := add(start, mload(subject))
                let m := div(not(0), 255) // `0x0101 ... `.
                let h := mul(byte(0, needle), m) // Replicating needle mask.
                m := not(shl(7, m)) // `0x7f7f ... `.
                for { let i := add(start, from) } 1 {} {
                    let c := xor(mload(i), h) // Load 32-byte chunk and xor with mask.
                    c := not(or(or(add(and(c, m), m), c), m)) // Each needle byte will be `0x80`.
                    if c {
                        c := and(not(shr(shl(3, sub(end, i)), not(0))), c) // Truncate bytes past the end.
                        if c {
                            let r := shl(7, lt(0x8421084210842108cc6318c6db6d54be, c)) // Save bytecode.
                            r := or(shl(6, lt(0xffffffffffffffff, shr(r, c))), r)
                            // forgefmt: disable-next-item
                            result := add(sub(i, start), shr(3, xor(byte(and(0x1f, shr(byte(24,
                                mul(0x02040810204081, shr(r, c))), 0x8421084210842108cc6318c6db6d54be)),
                                0xc0c8c8d0c8e8d0d8c8e8e0e8d0d8e0f0c8d0e8d0e0e0d8f0d0d0e0d8f8f8f8f8), r)))
                            break
                        }
                    }
                    i := add(i, 0x20)
                    if iszero(lt(i, end)) { break }
                }
            }
        }
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right. Optimized for byte needles.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOfByte(bytes memory subject, bytes1 needle) internal pure returns (uint256 result) {
        return indexOfByte(subject, needle, 0);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(bytes memory subject, bytes memory needle) internal pure returns (uint256) {
        return indexOf(subject, needle, 0);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(bytes memory subject, bytes memory needle, uint256 from)
        internal
        pure
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                result := not(0) // Initialize to `NOT_FOUND`.
                let needleLen := mload(needle)
                if gt(needleLen, mload(subject)) { break }
                let w := result

                let fromMax := sub(mload(subject), needleLen)
                if iszero(gt(fromMax, from)) { from := fromMax }

                let end := add(add(subject, 0x20), w)
                subject := add(add(subject, 0x20), from)
                if iszero(gt(subject, end)) { break }
                // As this function is not too often used,
                // we shall simply use keccak256 for smaller bytecode size.
                for { let h := keccak256(add(needle, 0x20), needleLen) } 1 {} {
                    if eq(keccak256(subject, needleLen), h) {
                        result := sub(subject, add(end, 1))
                        break
                    }
                    subject := add(subject, w) // `sub(subject, 1)`.
                    if iszero(gt(subject, end)) { break }
                }
                break
            }
        }
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(bytes memory subject, bytes memory needle) internal pure returns (uint256) {
        return lastIndexOf(subject, needle, type(uint256).max);
    }

    /// @dev Returns true if `needle` is found in `subject`, false otherwise.
    function contains(bytes memory subject, bytes memory needle) internal pure returns (bool) {
        return indexOf(subject, needle) != NOT_FOUND;
    }

    /// @dev Returns whether `subject` starts with `needle`.
    function startsWith(bytes memory subject, bytes memory needle) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(needle)
            // Just using keccak256 directly is actually cheaper.
            let t := eq(keccak256(add(subject, 0x20), n), keccak256(add(needle, 0x20), n))
            result := lt(gt(n, mload(subject)), t)
        }
    }

    /// @dev Returns whether `subject` ends with `needle`.
    function endsWith(bytes memory subject, bytes memory needle) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(needle)
            let notInRange := gt(n, mload(subject))
            // `subject + 0x20 + max(subject.length - needle.length, 0)`.
            let t := add(add(subject, 0x20), mul(iszero(notInRange), sub(mload(subject), n)))
            // Just using keccak256 directly is actually cheaper.
            result := gt(eq(keccak256(t, n), keccak256(add(needle, 0x20), n)), notInRange)
        }
    }

    /// @dev Returns `subject` repeated `times`.
    function repeat(bytes memory subject, uint256 times) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let l := mload(subject) // Subject length.
            if iszero(or(iszero(times), iszero(l))) {
                result := mload(0x40)
                subject := add(subject, 0x20)
                let o := add(result, 0x20)
                for {} 1 {} {
                    // Copy the `subject` one word at a time.
                    for { let j := 0 } 1 {} {
                        mstore(add(o, j), mload(add(subject, j)))
                        j := add(j, 0x20)
                        if iszero(lt(j, l)) { break }
                    }
                    o := add(o, l)
                    times := sub(times, 1)
                    if iszero(times) { break }
                }
                mstore(o, 0) // Zeroize the slot after the bytes.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
                mstore(result, sub(o, add(result, 0x20))) // Store the length.
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets.
    function slice(bytes memory subject, uint256 start, uint256 end) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let l := mload(subject) // Subject length.
            if iszero(gt(l, end)) { end := l }
            if iszero(gt(l, start)) { start := l }
            if lt(start, end) {
                result := mload(0x40)
                let n := sub(end, start)
                let i := add(subject, start)
                let w := not(0x1f)
                // Copy the `subject` one word at a time, backwards.
                for { let j := and(add(n, 0x1f), w) } 1 {} {
                    mstore(add(result, j), mload(add(i, j)))
                    j := add(j, w) // `sub(j, 0x20)`.
                    if iszero(j) { break }
                }
                let o := add(add(result, 0x20), n)
                mstore(o, 0) // Zeroize the slot after the bytes.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
                mstore(result, n) // Store the length.
            }
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the bytes.
    /// `start` is a byte offset.
    function slice(bytes memory subject, uint256 start) internal pure returns (bytes memory result) {
        result = slice(subject, start, type(uint256).max);
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets. Faster than Solidity's native slicing.
    function sliceCalldata(bytes calldata subject, uint256 start, uint256 end)
        internal
        pure
        returns (bytes calldata result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            end := xor(end, mul(xor(end, subject.length), lt(subject.length, end)))
            start := xor(start, mul(xor(start, subject.length), lt(subject.length, start)))
            result.offset := add(subject.offset, start)
            result.length := mul(lt(start, end), sub(end, start))
        }
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the bytes.
    /// `start` is a byte offset. Faster than Solidity's native slicing.
    function sliceCalldata(bytes calldata subject, uint256 start) internal pure returns (bytes calldata result) {
        /// @solidity memory-safe-assembly
        assembly {
            start := xor(start, mul(xor(start, subject.length), lt(subject.length, start)))
            result.offset := add(subject.offset, start)
            result.length := mul(lt(start, subject.length), sub(subject.length, start))
        }
    }

    /// @dev Reduces the size of `subject` to `n`.
    /// If `n` is greater than the size of `subject`, this will be a no-op.
    function truncate(bytes memory subject, uint256 n) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := subject
            mstore(mul(lt(n, mload(result)), result), n)
        }
    }

    /// @dev Returns a copy of `subject`, with the length reduced to `n`.
    /// If `n` is greater than the size of `subject`, this will be a no-op.
    function truncatedCalldata(bytes calldata subject, uint256 n) internal pure returns (bytes calldata result) {
        /// @solidity memory-safe-assembly
        assembly {
            result.offset := subject.offset
            result.length := xor(n, mul(xor(n, subject.length), lt(subject.length, n)))
        }
    }

    /// @dev Returns all the indices of `needle` in `subject`.
    /// The indices are byte offsets.
    function indicesOf(bytes memory subject, bytes memory needle) internal pure returns (uint256[] memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let searchLen := mload(needle)
            if iszero(gt(searchLen, mload(subject))) {
                result := mload(0x40)
                let i := add(subject, 0x20)
                let o := add(result, 0x20)
                let subjectSearchEnd := add(sub(add(i, mload(subject)), searchLen), 1)
                let h := 0 // The hash of `needle`.
                if iszero(lt(searchLen, 0x20)) { h := keccak256(add(needle, 0x20), searchLen) }
                let s := mload(add(needle, 0x20))
                for { let m := shl(3, sub(0x20, and(searchLen, 0x1f))) } 1 {} {
                    let t := mload(i)
                    // Whether the first `searchLen % 32` bytes of `subject` and `needle` matches.
                    if iszero(shr(m, xor(t, s))) {
                        if h {
                            if iszero(eq(keccak256(i, searchLen), h)) {
                                i := add(i, 1)
                                if iszero(lt(i, subjectSearchEnd)) { break }
                                continue
                            }
                        }
                        mstore(o, sub(i, add(subject, 0x20))) // Append to `result`.
                        o := add(o, 0x20)
                        i := add(i, searchLen) // Advance `i` by `searchLen`.
                        if searchLen {
                            if iszero(lt(i, subjectSearchEnd)) { break }
                            continue
                        }
                    }
                    i := add(i, 1)
                    if iszero(lt(i, subjectSearchEnd)) { break }
                }
                mstore(result, shr(5, sub(o, add(result, 0x20)))) // Store the length of `result`.
                // Allocate memory for result.
                // We allocate one more word, so this array can be recycled for {split}.
                mstore(0x40, add(o, 0x20))
            }
        }
    }

    /// @dev Returns an arrays of bytess based on the `delimiter` inside of the `subject` bytes.
    function split(bytes memory subject, bytes memory delimiter) internal pure returns (bytes[] memory result) {
        uint256[] memory indices = indicesOf(subject, delimiter);
        /// @solidity memory-safe-assembly
        assembly {
            let w := not(0x1f)
            let indexPtr := add(indices, 0x20)
            let indicesEnd := add(indexPtr, shl(5, add(mload(indices), 1)))
            mstore(add(indicesEnd, w), mload(subject))
            mstore(indices, add(mload(indices), 1))
            for { let prevIndex := 0 } 1 {} {
                let index := mload(indexPtr)
                mstore(indexPtr, 0x60)
                if iszero(eq(index, prevIndex)) {
                    let element := mload(0x40)
                    let l := sub(index, prevIndex)
                    mstore(element, l) // Store the length of the element.
                    // Copy the `subject` one word at a time, backwards.
                    for { let o := and(add(l, 0x1f), w) } 1 {} {
                        mstore(add(element, o), mload(add(add(subject, prevIndex), o)))
                        o := add(o, w) // `sub(o, 0x20)`.
                        if iszero(o) { break }
                    }
                    mstore(add(add(element, 0x20), l), 0) // Zeroize the slot after the bytes.
                    // Allocate memory for the length and the bytes, rounded up to a multiple of 32.
                    mstore(0x40, add(element, and(add(l, 0x3f), w)))
                    mstore(indexPtr, element) // Store the `element` into the array.
                }
                prevIndex := add(index, mload(delimiter))
                indexPtr := add(indexPtr, 0x20)
                if iszero(lt(indexPtr, indicesEnd)) { break }
            }
            result := indices
            if iszero(mload(delimiter)) {
                result := add(indices, 0x20)
                mstore(result, sub(mload(indices), 2))
            }
        }
    }

    /// @dev Returns a concatenated bytes of `a` and `b`.
    /// Cheaper than `bytes.concat()` and does not de-align the free memory pointer.
    function concat(bytes memory a, bytes memory b) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let w := not(0x1f)
            let aLen := mload(a)
            // Copy `a` one word at a time, backwards.
            for { let o := and(add(aLen, 0x20), w) } 1 {} {
                mstore(add(result, o), mload(add(a, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let bLen := mload(b)
            let output := add(result, aLen)
            // Copy `b` one word at a time, backwards.
            for { let o := and(add(bLen, 0x20), w) } 1 {} {
                mstore(add(output, o), mload(add(b, o)))
                o := add(o, w) // `sub(o, 0x20)`.
                if iszero(o) { break }
            }
            let totalLen := add(aLen, bLen)
            let last := add(add(result, 0x20), totalLen)
            mstore(last, 0) // Zeroize the slot after the bytes.
            mstore(result, totalLen) // Store the length.
            mstore(0x40, add(last, 0x20)) // Allocate memory.
        }
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(bytes memory a, bytes memory b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
        }
    }

    /// @dev Returns whether `a` equals `b`, where `b` is a null-terminated small bytes.
    function eqs(bytes memory a, bytes32 b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // These should be evaluated on compile time, as far as possible.
            let m := not(shl(7, div(not(iszero(b)), 255))) // `0x7f7f ...`.
            let x := not(or(m, or(b, add(m, and(b, m)))))
            let r := shl(7, iszero(iszero(shr(128, x))))
            r := or(r, shl(6, iszero(iszero(shr(64, shr(r, x))))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            result := gt(eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
                xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20)))))
        }
    }

    /// @dev Returns 0 if `a == b`, -1 if `a < b`, +1 if `a > b`.
    /// If `a` == b[:a.length]`, and `a.length < b.length`, returns -1.
    function cmp(bytes memory a, bytes memory b) internal pure returns (int256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let aLen := mload(a)
            let bLen := mload(b)
            let n := and(xor(aLen, mul(xor(aLen, bLen), lt(bLen, aLen))), not(0x1f))
            if n {
                for { let i := 0x20 } 1 {} {
                    let x := mload(add(a, i))
                    let y := mload(add(b, i))
                    if iszero(or(xor(x, y), eq(i, n))) {
                        i := add(i, 0x20)
                        continue
                    }
                    result := sub(gt(x, y), lt(x, y))
                    break
                }
            }
            // forgefmt: disable-next-item
            if iszero(result) {
                let l := 0x201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a090807060504030201
                let x := and(mload(add(add(a, 0x20), n)), shl(shl(3, byte(sub(aLen, n), l)), not(0)))
                let y := and(mload(add(add(b, 0x20), n)), shl(shl(3, byte(sub(bLen, n), l)), not(0)))
                result := sub(gt(x, y), lt(x, y))
                if iszero(result) { result := sub(gt(aLen, bLen), lt(aLen, bLen)) }
            }
        }
    }

    /// @dev Directly returns `a` without copying.
    function directReturn(bytes memory a) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            // Assumes that the bytes does not start from the scratch space.
            let retStart := sub(a, 0x20)
            let retUnpaddedSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the bytes is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retUnpaddedSize), 0)
            mstore(retStart, 0x20) // Store the return offset.
            // End the transaction, returning the bytes.
            return(retStart, and(not(0x1f), add(0x1f, retUnpaddedSize)))
        }
    }

    /// @dev Directly returns `a` with minimal copying.
    function directReturn(bytes[] memory a) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(a) // `a.length`.
            let o := add(a, 0x20) // Start of elements in `a`.
            let u := a // Highest memory slot.
            let w := not(0x1f)
            for { let i := 0 } iszero(eq(i, n)) { i := add(i, 1) } {
                let c := add(o, shl(5, i)) // Location of pointer to `a[i]`.
                let s := mload(c) // `a[i]`.
                let l := mload(s) // `a[i].length`.
                let r := and(l, 0x1f) // `a[i].length % 32`.
                let z := add(0x20, and(l, w)) // Offset of last word in `a[i]` from `s`.
                // If `s` comes before `o`, or `s` is not zero right padded.
                if iszero(lt(lt(s, o), or(iszero(r), iszero(shl(shl(3, r), mload(add(s, z))))))) {
                    let m := mload(0x40)
                    mstore(m, l) // Copy `a[i].length`.
                    for {} 1 {} {
                        mstore(add(m, z), mload(add(s, z))) // Copy `a[i]`, backwards.
                        z := add(z, w) // `sub(z, 0x20)`.
                        if iszero(z) { break }
                    }
                    let e := add(add(m, 0x20), l)
                    mstore(e, 0) // Zeroize the slot after the copied bytes.
                    mstore(0x40, add(e, 0x20)) // Allocate memory.
                    s := m
                }
                mstore(c, sub(s, o)) // Convert to calldata offset.
                let t := add(l, add(s, 0x20))
                if iszero(lt(t, u)) { u := t }
            }
            let retStart := add(a, w) // Assumes `a` doesn't start from scratch space.
            mstore(retStart, 0x20) // Store the return offset.
            return(retStart, add(0x40, sub(u, retStart))) // End the transaction.
        }
    }

    /// @dev Returns the word at `offset`, without any bounds checks.
    function load(bytes memory a, uint256 offset) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(add(add(a, 0x20), offset))
        }
    }

    /// @dev Returns the word at `offset`, without any bounds checks.
    function loadCalldata(bytes calldata a, uint256 offset) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := calldataload(add(a.offset, offset))
        }
    }

    /// @dev Returns a slice representing a static struct in the calldata. Performs bounds checks.
    function staticStructInCalldata(bytes calldata a, uint256 offset) internal pure returns (bytes calldata result) {
        /// @solidity memory-safe-assembly
        assembly {
            let l := sub(a.length, 0x20)
            result.offset := add(a.offset, offset)
            result.length := sub(a.length, offset)
            if or(shr(64, or(l, a.offset)), gt(offset, l)) { revert(l, 0x00) }
        }
    }

    /// @dev Returns a slice representing a dynamic struct in the calldata. Performs bounds checks.
    function dynamicStructInCalldata(bytes calldata a, uint256 offset) internal pure returns (bytes calldata result) {
        /// @solidity memory-safe-assembly
        assembly {
            let l := sub(a.length, 0x20)
            let s := calldataload(add(a.offset, offset)) // Relative offset of `result` from `a.offset`.
            result.offset := add(a.offset, s)
            result.length := sub(a.length, s)
            if or(shr(64, or(s, or(l, a.offset))), gt(offset, l)) { revert(l, 0x00) }
        }
    }

    /// @dev Returns bytes in calldata. Performs bounds checks.
    function bytesInCalldata(bytes calldata a, uint256 offset) internal pure returns (bytes calldata result) {
        /// @solidity memory-safe-assembly
        assembly {
            let l := sub(a.length, 0x20)
            let s := calldataload(add(a.offset, offset)) // Relative offset of `result` from `a.offset`.
            result.offset := add(add(a.offset, s), 0x20)
            result.length := calldataload(add(a.offset, s))
            // forgefmt: disable-next-item
            if or(shr(64, or(result.length, or(s, or(l, a.offset)))),
                or(gt(add(s, result.length), l), gt(offset, l))) { revert(l, 0x00) }
        }
    }

    /// @dev Checks if `x` is in `a`. Assumes `a` has been checked.
    function checkInCalldata(bytes calldata x, bytes calldata a) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            if or(
                or(lt(x.offset, a.offset), gt(add(x.offset, x.length), add(a.length, a.offset))),
                shr(64, or(x.length, x.offset))
            ) { revert(0x00, 0x00) }
        }
    }

    /// @dev Checks if `x` is in `a`. Assumes `a` has been checked.
    function checkInCalldata(bytes[] calldata x, bytes calldata a) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            let e := sub(add(a.length, a.offset), 0x20)
            if or(lt(x.offset, a.offset), shr(64, x.offset)) { revert(0x00, 0x00) }
            for { let i := 0 } iszero(eq(x.length, i)) { i := add(i, 1) } {
                let o := calldataload(add(x.offset, shl(5, i)))
                let t := add(o, x.offset)
                let l := calldataload(t)
                if or(shr(64, or(l, o)), gt(add(t, l), e)) { revert(0x00, 0x00) }
            }
        }
    }

    /// @dev Returns empty calldata bytes. For silencing the compiler.
    function emptyCalldata() internal pure returns (bytes calldata result) {
        /// @solidity memory-safe-assembly
        assembly {
            result.length := 0
        }
    }

    /// @dev Returns the most significant 20 bytes as an address.
    function msbToAddress(bytes32 x) internal pure returns (address) {
        return address(bytes20(x));
    }

    /// @dev Returns the least significant 20 bytes as an address.
    function lsbToAddress(bytes32 x) internal pure returns (address) {
        return address(uint160(uint256(x)));
    }
}

/// @notice Library for converting numbers into strings and other string operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibString.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/LibString.sol)
///
/// @dev Note:
/// For performance and bytecode compactness, most of the string operations are restricted to
/// byte strings (7-bit ASCII), except where otherwise specified.
/// Usage of byte string operations on charsets with runes spanning two or more bytes
/// can lead to undefined behavior.
library LibString {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Goated string storage struct that totally MOGs, no cap, fr.
    /// Uses less gas and bytecode than Solidity's native string storage. It's meta af.
    /// Packs length with the first 31 bytes if <255 bytes, so it’s mad tight.
    struct StringStorage {
        bytes32 _spacer;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The length of the output is too small to contain all the hex digits.
    error HexLengthInsufficient();

    /// @dev The length of the string is more than 32 bytes.
    error TooBigForSmallString();

    /// @dev The input string must be a 7-bit ASCII.
    error StringNot7BitASCII();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The constant returned when the `search` is not found in the string.
    uint256 internal constant NOT_FOUND = type(uint256).max;

    /// @dev Lookup for '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant ALPHANUMERIC_7_BIT_ASCII = 0x7fffffe07fffffe03ff000000000000;

    /// @dev Lookup for 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant LETTERS_7_BIT_ASCII = 0x7fffffe07fffffe0000000000000000;

    /// @dev Lookup for 'abcdefghijklmnopqrstuvwxyz'.
    uint128 internal constant LOWERCASE_7_BIT_ASCII = 0x7fffffe000000000000000000000000;

    /// @dev Lookup for 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    uint128 internal constant UPPERCASE_7_BIT_ASCII = 0x7fffffe0000000000000000;

    /// @dev Lookup for '0123456789'.
    uint128 internal constant DIGITS_7_BIT_ASCII = 0x3ff000000000000;

    /// @dev Lookup for '0123456789abcdefABCDEF'.
    uint128 internal constant HEXDIGITS_7_BIT_ASCII = 0x7e0000007e03ff000000000000;

    /// @dev Lookup for '01234567'.
    uint128 internal constant OCTDIGITS_7_BIT_ASCII = 0xff000000000000;

    /// @dev Lookup for '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c'.
    uint128 internal constant PRINTABLE_7_BIT_ASCII = 0x7fffffffffffffffffffffff00003e00;

    /// @dev Lookup for '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'.
    uint128 internal constant PUNCTUATION_7_BIT_ASCII = 0x78000001f8000001fc00fffe00000000;

    /// @dev Lookup for ' \t\n\r\x0b\x0c'.
    uint128 internal constant WHITESPACE_7_BIT_ASCII = 0x100003e00;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                 STRING STORAGE OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sets the value of the string storage `$` to `s`.
    function set(StringStorage storage $, string memory s) internal {
        LibBytes.set(bytesStorage($), bytes(s));
    }

    /// @dev Sets the value of the string storage `$` to `s`.
    function setCalldata(StringStorage storage $, string calldata s) internal {
        LibBytes.setCalldata(bytesStorage($), bytes(s));
    }

    /// @dev Sets the value of the string storage `$` to the empty string.
    function clear(StringStorage storage $) internal {
        delete $._spacer;
    }

    /// @dev Returns whether the value stored is `$` is the empty string "".
    function isEmpty(StringStorage storage $) internal view returns (bool) {
        return uint256($._spacer) & 0xff == uint256(0);
    }

    /// @dev Returns the length of the value stored in `$`.
    function length(StringStorage storage $) internal view returns (uint256) {
        return LibBytes.length(bytesStorage($));
    }

    /// @dev Returns the value stored in `$`.
    function get(StringStorage storage $) internal view returns (string memory) {
        return string(LibBytes.get(bytesStorage($)));
    }

    /// @dev Returns the uint8 at index `i`. If out-of-bounds, returns 0.
    function uint8At(StringStorage storage $, uint256 i) internal view returns (uint8) {
        return LibBytes.uint8At(bytesStorage($), i);
    }

    /// @dev Helper to cast `$` to a `BytesStorage`.
    function bytesStorage(StringStorage storage $) internal pure returns (LibBytes.BytesStorage storage casted) {
        /// @solidity memory-safe-assembly
        assembly {
            casted.slot := $.slot
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     DECIMAL OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(uint256 value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits.
            result := add(mload(0x40), 0x80)
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end of the memory to calculate the length later.
            let w := not(0) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                result := add(result, w) // `sub(result, 1)`.
                // Store the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(result, add(48, mod(temp, 10)))
                temp := div(temp, 10) // Keep dividing `temp` until zero.
                if iszero(temp) { break }
            }
            let n := sub(end, result)
            result := sub(result, 0x20) // Move the pointer 32 bytes back to make room for the length.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the base 10 decimal representation of `value`.
    function toString(int256 value) internal pure returns (string memory result) {
        if (value >= 0) {
            return toString(uint256(value));
        }
        unchecked {
            result = toString(~uint256(value) + 1);
        }
        /// @solidity memory-safe-assembly
        assembly {
            // We still have some spare memory space on the left,
            // as we have allocated 3 words (96 bytes) for up to 78 digits.
            let n := mload(result) // Load the string length.
            mstore(result, 0x2d) // Store the '-' character.
            result := sub(result, 1) // Move back the string pointer by a byte.
            mstore(result, add(n, 1)) // Update the string length.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   HEXADECIMAL OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `byteCount` bytes.
    /// The output is prefixed with "0x" encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `byteCount * 2 + 2` bytes.
    /// Reverts if `byteCount` is too small for the output to contain all the digits.
    function toHexString(uint256 value, uint256 byteCount) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value, byteCount);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`,
    /// left-padded to an input length of `byteCount` bytes.
    /// The output is not prefixed with "0x" and is encoded using 2 hexadecimal digits per byte,
    /// giving a total length of `byteCount * 2` bytes.
    /// Reverts if `byteCount` is too small for the output to contain all the digits.
    function toHexStringNoPrefix(uint256 value, uint256 byteCount) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, `byteCount * 2` bytes
            // for the digits, 0x02 bytes for the prefix, and 0x20 bytes for the length.
            // We add 0x20 to the total and round down to a multiple of 0x20.
            // (0x20 + 0x20 + 0x02 + 0x20) = 0x62.
            result := add(mload(0x40), and(add(shl(1, byteCount), 0x42), not(0x1f)))
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end to calculate the length later.
            // Store "0123456789abcdef" in scratch space.
            mstore(0x0f, 0x30313233343536373839616263646566)

            let start := sub(result, add(byteCount, byteCount))
            let w := not(1) // Tsk.
            let temp := value
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for {} 1 {} {
                result := add(result, w) // `sub(result, 2)`.
                mstore8(add(result, 1), mload(and(temp, 15)))
                mstore8(result, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(xor(result, start)) { break }
            }
            if temp {
                mstore(0x00, 0x2194895a) // `HexLengthInsufficient()`.
                revert(0x1c, 0x04)
            }
            let n := sub(end, result)
            result := sub(result, 0x20)
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2 + 2` bytes.
    function toHexString(uint256 value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x".
    /// The output excludes leading "0" from the `toHexString` output.
    /// `0x00: "0x0", 0x01: "0x1", 0x12: "0x12", 0x123: "0x123"`.
    function toMinimalHexString(uint256 value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(result, 0x20))), 0x30) // Whether leading zero is present.
            let n := add(mload(result), 2) // Compute the length.
            mstore(add(result, o), 0x3078) // Store the "0x" prefix, accounting for leading zero.
            result := sub(add(result, o), 2) // Move the pointer, accounting for leading zero.
            mstore(result, sub(n, o)) // Store the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output excludes leading "0" from the `toHexStringNoPrefix` output.
    /// `0x00: "0", 0x01: "1", 0x12: "12", 0x123: "123"`.
    function toMinimalHexStringNoPrefix(uint256 value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let o := eq(byte(0, mload(add(result, 0x20))), 0x30) // Whether leading zero is present.
            let n := mload(result) // Get the length.
            result := add(result, o) // Move the pointer, accounting for leading zero.
            mstore(result, sub(n, o)) // Store the length, accounting for leading zero.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    /// As address are 20 bytes long, the output will left-padded to have
    /// a length of `20 * 2` bytes.
    function toHexStringNoPrefix(uint256 value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x40 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x40) is 0xa0.
            result := add(mload(0x40), 0x80)
            mstore(0x40, add(result, 0x20)) // Allocate memory.
            mstore(result, 0) // Zeroize the slot after the string.

            let end := result // Cache the end to calculate the length later.
            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.

            let w := not(1) // Tsk.
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let temp := value } 1 {} {
                result := add(result, w) // `sub(result, 2)`.
                mstore8(add(result, 1), mload(and(temp, 15)))
                mstore8(result, mload(and(shr(4, temp), 15)))
                temp := shr(8, temp)
                if iszero(temp) { break }
            }
            let n := sub(end, result)
            result := sub(result, 0x20)
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x", encoded using 2 hexadecimal digits per byte,
    /// and the alphabets are capitalized conditionally according to
    /// https://eips.ethereum.org/EIPS/eip-55
    function toHexStringChecksummed(address value) internal pure returns (string memory result) {
        result = toHexString(value);
        /// @solidity memory-safe-assembly
        assembly {
            let mask := shl(6, div(not(0), 255)) // `0b010000000100000000 ...`
            let o := add(result, 0x22)
            let hashed := and(keccak256(o, 40), mul(34, mask)) // `0b10001000 ... `
            let t := shl(240, 136) // `0b10001000 << 240`
            for { let i := 0 } 1 {} {
                mstore(add(i, i), mul(t, byte(i, hashed)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
            mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))
            o := add(o, 0x20)
            mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is prefixed with "0x" and encoded using 2 hexadecimal digits per byte.
    function toHexString(address value) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(value);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hexadecimal representation of `value`.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(address value) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            // Allocate memory.
            // We need 0x20 bytes for the trailing zeros padding, 0x20 bytes for the length,
            // 0x02 bytes for the prefix, and 0x28 bytes for the digits.
            // The next multiple of 0x20 above (0x20 + 0x20 + 0x02 + 0x28) is 0x80.
            mstore(0x40, add(result, 0x80))
            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.

            result := add(result, 2)
            mstore(result, 40) // Store the length.
            let o := add(result, 0x20)
            mstore(add(o, 40), 0) // Zeroize the slot after the string.
            value := shl(96, value)
            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            for { let i := 0 } 1 {} {
                let p := add(o, add(i, i))
                let temp := byte(i, value)
                mstore8(add(p, 1), mload(and(temp, 15)))
                mstore8(p, mload(shr(4, temp)))
                i := add(i, 1)
                if eq(i, 20) { break }
            }
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexString(bytes memory raw) internal pure returns (string memory result) {
        result = toHexStringNoPrefix(raw);
        /// @solidity memory-safe-assembly
        assembly {
            let n := add(mload(result), 2) // Compute the length.
            mstore(result, 0x3078) // Store the "0x" prefix.
            result := sub(result, 2) // Move the pointer.
            mstore(result, n) // Store the length.
        }
    }

    /// @dev Returns the hex encoded string from the raw bytes.
    /// The output is encoded using 2 hexadecimal digits per byte.
    function toHexStringNoPrefix(bytes memory raw) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(raw)
            result := add(mload(0x40), 2) // Skip 2 bytes for the optional prefix.
            mstore(result, add(n, n)) // Store the length of the output.

            mstore(0x0f, 0x30313233343536373839616263646566) // Store the "0123456789abcdef" lookup.
            let o := add(result, 0x20)
            let end := add(raw, n)
            for {} iszero(eq(raw, end)) {} {
                raw := add(raw, 1)
                mstore8(add(o, 1), mload(and(mload(raw), 15)))
                mstore8(o, mload(and(shr(4, mload(raw)), 15)))
                o := add(o, 2)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RUNE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the number of UTF characters in the string.
    function runeCount(string memory s) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                mstore(0x00, div(not(0), 255))
                mstore(0x20, 0x0202020202020202020202020202020202020202020202020303030304040506)
                let o := add(s, 0x20)
                let end := add(o, mload(s))
                for { result := 1 } 1 { result := add(result, 1) } {
                    o := add(o, byte(0, mload(shr(250, mload(o)))))
                    if iszero(lt(o, end)) { break }
                }
            }
        }
    }

    /// @dev Returns if this string is a 7-bit ASCII string.
    /// (i.e. all characters codes are in [0..127])
    function is7BitASCII(string memory s) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            let mask := shl(7, div(not(0), 255))
            let n := mload(s)
            if n {
                let o := add(s, 0x20)
                let end := add(o, n)
                let last := mload(end)
                mstore(end, 0)
                for {} 1 {} {
                    if and(mask, mload(o)) {
                        result := 0
                        break
                    }
                    o := add(o, 0x20)
                    if iszero(lt(o, end)) { break }
                }
                mstore(end, last)
            }
        }
    }

    /// @dev Returns if this string is a 7-bit ASCII string,
    /// AND all characters are in the `allowed` lookup.
    /// Note: If `s` is empty, returns true regardless of `allowed`.
    function is7BitASCII(string memory s, uint128 allowed) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := 1
            if mload(s) {
                let allowed_ := shr(128, shl(128, allowed))
                let o := add(s, 0x20)
                for { let end := add(o, mload(s)) } 1 {} {
                    result := and(result, shr(byte(0, mload(o)), allowed_))
                    o := add(o, 1)
                    if iszero(and(result, lt(o, end))) { break }
                }
            }
        }
    }

    /// @dev Converts the bytes in the 7-bit ASCII string `s` to
    /// an allowed lookup for use in `is7BitASCII(s, allowed)`.
    /// To save runtime gas, you can cache the result in an immutable variable.
    function to7BitASCIIAllowedLookup(string memory s) internal pure returns (uint128 result) {
        /// @solidity memory-safe-assembly
        assembly {
            if mload(s) {
                let o := add(s, 0x20)
                for { let end := add(o, mload(s)) } 1 {} {
                    result := or(result, shl(byte(0, mload(o)), 1))
                    o := add(o, 1)
                    if iszero(lt(o, end)) { break }
                }
                if shr(128, result) {
                    mstore(0x00, 0xc9807e0d) // `StringNot7BitASCII()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   BYTE STRING OPERATIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // For performance and bytecode compactness, byte string operations are restricted
    // to 7-bit ASCII strings. All offsets are byte offsets, not UTF character offsets.
    // Usage of byte string operations on charsets with runes spanning two or more bytes
    // can lead to undefined behavior.

    /// @dev Returns `subject` all occurrences of `needle` replaced with `replacement`.
    function replace(string memory subject, string memory needle, string memory replacement)
        internal
        pure
        returns (string memory)
    {
        return string(LibBytes.replace(bytes(subject), bytes(needle), bytes(replacement)));
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(string memory subject, string memory needle, uint256 from) internal pure returns (uint256) {
        return LibBytes.indexOf(bytes(subject), bytes(needle), from);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from left to right.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function indexOf(string memory subject, string memory needle) internal pure returns (uint256) {
        return LibBytes.indexOf(bytes(subject), bytes(needle), 0);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left, starting from `from`.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(string memory subject, string memory needle, uint256 from) internal pure returns (uint256) {
        return LibBytes.lastIndexOf(bytes(subject), bytes(needle), from);
    }

    /// @dev Returns the byte index of the first location of `needle` in `subject`,
    /// needleing from right to left.
    /// Returns `NOT_FOUND` (i.e. `type(uint256).max`) if the `needle` is not found.
    function lastIndexOf(string memory subject, string memory needle) internal pure returns (uint256) {
        return LibBytes.lastIndexOf(bytes(subject), bytes(needle), type(uint256).max);
    }

    /// @dev Returns true if `needle` is found in `subject`, false otherwise.
    function contains(string memory subject, string memory needle) internal pure returns (bool) {
        return LibBytes.contains(bytes(subject), bytes(needle));
    }

    /// @dev Returns whether `subject` starts with `needle`.
    function startsWith(string memory subject, string memory needle) internal pure returns (bool) {
        return LibBytes.startsWith(bytes(subject), bytes(needle));
    }

    /// @dev Returns whether `subject` ends with `needle`.
    function endsWith(string memory subject, string memory needle) internal pure returns (bool) {
        return LibBytes.endsWith(bytes(subject), bytes(needle));
    }

    /// @dev Returns `subject` repeated `times`.
    function repeat(string memory subject, uint256 times) internal pure returns (string memory) {
        return string(LibBytes.repeat(bytes(subject), times));
    }

    /// @dev Returns a copy of `subject` sliced from `start` to `end` (exclusive).
    /// `start` and `end` are byte offsets.
    function slice(string memory subject, uint256 start, uint256 end) internal pure returns (string memory) {
        return string(LibBytes.slice(bytes(subject), start, end));
    }

    /// @dev Returns a copy of `subject` sliced from `start` to the end of the string.
    /// `start` is a byte offset.
    function slice(string memory subject, uint256 start) internal pure returns (string memory) {
        return string(LibBytes.slice(bytes(subject), start, type(uint256).max));
    }

    /// @dev Returns all the indices of `needle` in `subject`.
    /// The indices are byte offsets.
    function indicesOf(string memory subject, string memory needle) internal pure returns (uint256[] memory) {
        return LibBytes.indicesOf(bytes(subject), bytes(needle));
    }

    /// @dev Returns an arrays of strings based on the `delimiter` inside of the `subject` string.
    function split(string memory subject, string memory delimiter) internal pure returns (string[] memory result) {
        bytes[] memory a = LibBytes.split(bytes(subject), bytes(delimiter));
        /// @solidity memory-safe-assembly
        assembly {
            result := a
        }
    }

    /// @dev Returns a concatenated string of `a` and `b`.
    /// Cheaper than `string.concat()` and does not de-align the free memory pointer.
    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(LibBytes.concat(bytes(a), bytes(b)));
    }

    /// @dev Returns a copy of the string in either lowercase or UPPERCASE.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function toCase(string memory subject, bool toUpper) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let n := mload(subject)
            if n {
                result := mload(0x40)
                let o := add(result, 0x20)
                let d := sub(subject, result)
                let flags := shl(add(70, shl(5, toUpper)), 0x3ffffff)
                for { let end := add(o, n) } 1 {} {
                    let b := byte(0, mload(add(d, o)))
                    mstore8(o, xor(and(shr(b, flags), 0x20), b))
                    o := add(o, 1)
                    if eq(o, end) { break }
                }
                mstore(result, n) // Store the length.
                mstore(o, 0) // Zeroize the slot after the string.
                mstore(0x40, add(o, 0x20)) // Allocate memory.
            }
        }
    }

    /// @dev Returns a string from a small bytes32 string.
    /// `s` must be null-terminated, or behavior will be undefined.
    function fromSmallString(bytes32 s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let n := 0
            for {} byte(n, s) { n := add(n, 1) } {} // Scan for '\0'.
            mstore(result, n) // Store the length.
            let o := add(result, 0x20)
            mstore(o, s) // Store the bytes of the string.
            mstore(add(o, n), 0) // Zeroize the slot after the string.
            mstore(0x40, add(result, 0x40)) // Allocate memory.
        }
    }

    /// @dev Returns the small string, with all bytes after the first null byte zeroized.
    function normalizeSmallString(bytes32 s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} byte(result, s) { result := add(result, 1) } {} // Scan for '\0'.
            mstore(0x00, s)
            mstore(result, 0x00)
            result := mload(0x00)
        }
    }

    /// @dev Returns the string as a normalized null-terminated small string.
    function toSmallString(string memory s) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(s)
            if iszero(lt(result, 33)) {
                mstore(0x00, 0xec92f9a3) // `TooBigForSmallString()`.
                revert(0x1c, 0x04)
            }
            result := shl(shl(3, sub(32, result)), mload(add(s, result)))
        }
    }

    /// @dev Returns a lowercased copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function lower(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, false);
    }

    /// @dev Returns an UPPERCASED copy of the string.
    /// WARNING! This function is only compatible with 7-bit ASCII strings.
    function upper(string memory subject) internal pure returns (string memory result) {
        result = toCase(subject, true);
    }

    /// @dev Escapes the string to be used within HTML tags.
    function escapeHTML(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let end := add(s, mload(s))
            let o := add(result, 0x20)
            // Store the bytes of the packed offsets and strides into the scratch space.
            // `packed = (stride << 5) | offset`. Max offset is 20. Max stride is 6.
            mstore(0x1f, 0x900094)
            mstore(0x08, 0xc0000000a6ab)
            // Store "&quot;&amp;&#39;&lt;&gt;" into the scratch space.
            mstore(0x00, shl(64, 0x2671756f743b26616d703b262333393b266c743b2667743b))
            for {} iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // Not in `["\"","'","&","<",">"]`.
                if iszero(and(shl(c, 1), 0x500000c400000000)) {
                    mstore8(o, c)
                    o := add(o, 1)
                    continue
                }
                let t := shr(248, mload(c))
                mstore(o, mload(and(t, 0x1f)))
                o := add(o, shr(5, t))
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    /// If `addDoubleQuotes` is true, the result will be enclosed in double-quotes.
    function escapeJSON(string memory s, bool addDoubleQuotes) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            let o := add(result, 0x20)
            if addDoubleQuotes {
                mstore8(o, 34)
                o := add(1, o)
            }
            // Store "\\u0000" in scratch space.
            // Store "0123456789abcdef" in scratch space.
            // Also, store `{0x08:"b", 0x09:"t", 0x0a:"n", 0x0c:"f", 0x0d:"r"}`.
            // into the scratch space.
            mstore(0x15, 0x5c75303030303031323334353637383961626364656662746e006672)
            // Bitmask for detecting `["\"","\\"]`.
            let e := or(shl(0x22, 1), shl(0x5c, 1))
            for { let end := add(s, mload(s)) } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                if iszero(lt(c, 0x20)) {
                    if iszero(and(shl(c, 1), e)) {
                        // Not in `["\"","\\"]`.
                        mstore8(o, c)
                        o := add(o, 1)
                        continue
                    }
                    mstore8(o, 0x5c) // "\\".
                    mstore8(add(o, 1), c)
                    o := add(o, 2)
                    continue
                }
                if iszero(and(shl(c, 1), 0x3700)) {
                    // Not in `["\b","\t","\n","\f","\d"]`.
                    mstore8(0x1d, mload(shr(4, c))) // Hex value.
                    mstore8(0x1e, mload(and(c, 15))) // Hex value.
                    mstore(o, mload(0x19)) // "\\u00XX".
                    o := add(o, 6)
                    continue
                }
                mstore8(o, 0x5c) // "\\".
                mstore8(add(o, 1), mload(add(c, 8)))
                o := add(o, 2)
            }
            if addDoubleQuotes {
                mstore8(o, 34)
                o := add(1, o)
            }
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Escapes the string to be used within double-quotes in a JSON.
    function escapeJSON(string memory s) internal pure returns (string memory result) {
        result = escapeJSON(s, false);
    }

    /// @dev Encodes `s` so that it can be safely used in a URI,
    /// just like `encodeURIComponent` in JavaScript.
    /// See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
    /// See: https://datatracker.ietf.org/doc/html/rfc2396
    /// See: https://datatracker.ietf.org/doc/html/rfc3986
    function encodeURIComponent(string memory s) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40)
            // Store "0123456789ABCDEF" in scratch space.
            // Uppercased to be consistent with JavaScript's implementation.
            mstore(0x0f, 0x30313233343536373839414243444546)
            let o := add(result, 0x20)
            for { let end := add(s, mload(s)) } iszero(eq(s, end)) {} {
                s := add(s, 1)
                let c := and(mload(s), 0xff)
                // If not in `[0-9A-Z-a-z-_.!~*'()]`.
                if iszero(and(1, shr(c, 0x47fffffe87fffffe03ff678200000000))) {
                    mstore8(o, 0x25) // '%'.
                    mstore8(add(o, 1), mload(and(shr(4, c), 15)))
                    mstore8(add(o, 2), mload(and(c, 15)))
                    o := add(o, 3)
                    continue
                }
                mstore8(o, c)
                o := add(o, 1)
            }
            mstore(result, sub(o, add(result, 0x20))) // Store the length.
            mstore(o, 0) // Zeroize the slot after the string.
            mstore(0x40, add(o, 0x20)) // Allocate memory.
        }
    }

    /// @dev Returns whether `a` equals `b`.
    function eq(string memory a, string memory b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := eq(keccak256(add(a, 0x20), mload(a)), keccak256(add(b, 0x20), mload(b)))
        }
    }

    /// @dev Returns whether `a` equals `b`, where `b` is a null-terminated small string.
    function eqs(string memory a, bytes32 b) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // These should be evaluated on compile time, as far as possible.
            let m := not(shl(7, div(not(iszero(b)), 255))) // `0x7f7f ...`.
            let x := not(or(m, or(b, add(m, and(b, m)))))
            let r := shl(7, iszero(iszero(shr(128, x))))
            r := or(r, shl(6, iszero(iszero(shr(64, shr(r, x))))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            result := gt(eq(mload(a), add(iszero(x), xor(31, shr(3, r)))),
                xor(shr(add(8, r), b), shr(add(8, r), mload(add(a, 0x20)))))
        }
    }

    /// @dev Returns 0 if `a == b`, -1 if `a < b`, +1 if `a > b`.
    /// If `a` == b[:a.length]`, and `a.length < b.length`, returns -1.
    function cmp(string memory a, string memory b) internal pure returns (int256) {
        return LibBytes.cmp(bytes(a), bytes(b));
    }

    /// @dev Packs a single string with its length into a single word.
    /// Returns `bytes32(0)` if the length is zero or greater than 31.
    function packOne(string memory a) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // We don't need to zero right pad the string,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    // Load the length and the bytes.
                    mload(add(a, 0x1f)),
                    // `length != 0 && length < 32`. Abuses underflow.
                    // Assumes that the length is valid and within the block gas limit.
                    lt(sub(mload(a), 1), 0x1f)
                )
        }
    }

    /// @dev Unpacks a string packed using {packOne}.
    /// Returns the empty string if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packOne}, the output behavior is undefined.
    function unpackOne(bytes32 packed) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := mload(0x40) // Grab the free memory pointer.
            mstore(0x40, add(result, 0x40)) // Allocate 2 words (1 for the length, 1 for the bytes).
            mstore(result, 0) // Zeroize the length slot.
            mstore(add(result, 0x1f), packed) // Store the length and bytes.
            mstore(add(add(result, 0x20), mload(result)), 0) // Right pad with zeroes.
        }
    }

    /// @dev Packs two strings with their lengths into a single word.
    /// Returns `bytes32(0)` if combined length is zero or greater than 30.
    function packTwo(string memory a, string memory b) internal pure returns (bytes32 result) {
        /// @solidity memory-safe-assembly
        assembly {
            let aLen := mload(a)
            // We don't need to zero right pad the strings,
            // since this is our own custom non-standard packing scheme.
            result :=
                mul(
                    or( // Load the length and the bytes of `a` and `b`.
                    shl(shl(3, sub(0x1f, aLen)), mload(add(a, aLen))), mload(sub(add(b, 0x1e), aLen))),
                    // `totalLen != 0 && totalLen < 31`. Abuses underflow.
                    // Assumes that the lengths are valid and within the block gas limit.
                    lt(sub(add(aLen, mload(b)), 1), 0x1e)
                )
        }
    }

    /// @dev Unpacks strings packed using {packTwo}.
    /// Returns the empty strings if `packed` is `bytes32(0)`.
    /// If `packed` is not an output of {packTwo}, the output behavior is undefined.
    function unpackTwo(bytes32 packed) internal pure returns (string memory resultA, string memory resultB) {
        /// @solidity memory-safe-assembly
        assembly {
            resultA := mload(0x40) // Grab the free memory pointer.
            resultB := add(resultA, 0x40)
            // Allocate 2 words for each string (1 for the length, 1 for the byte). Total 4 words.
            mstore(0x40, add(resultB, 0x40))
            // Zeroize the length slots.
            mstore(resultA, 0)
            mstore(resultB, 0)
            // Store the lengths and bytes.
            mstore(add(resultA, 0x1f), packed)
            mstore(add(resultB, 0x1f), mload(add(add(resultA, 0x20), mload(resultA))))
            // Right pad with zeroes.
            mstore(add(add(resultA, 0x20), mload(resultA)), 0)
            mstore(add(add(resultB, 0x20), mload(resultB)), 0)
        }
    }

    /// @dev Directly returns `a` without copying.
    function directReturn(string memory a) internal pure {
        /// @solidity memory-safe-assembly
        assembly {
            // Assumes that the string does not start from the scratch space.
            let retStart := sub(a, 0x20)
            let retUnpaddedSize := add(mload(a), 0x40)
            // Right pad with zeroes. Just in case the string is produced
            // by a method that doesn't zero right pad.
            mstore(add(retStart, retUnpaddedSize), 0)
            mstore(retStart, 0x20) // Store the return offset.
            // End the transaction, returning the string.
            return(retStart, and(not(0x1f), add(0x1f, retUnpaddedSize)))
        }
    }
}

/// @title Constants
/// @notice Constants is a library for storing constants. Simple! Don't put everything in here, just
///         the stuff used in multiple contracts. Constants that only apply to a single contract
///         should be defined in that contract instead.
library Constants {
    /// @notice The storage slot that holds the address of a proxy implementation.
    /// @dev `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`
    bytes32 internal constant PROXY_IMPLEMENTATION_ADDRESS =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice The storage slot that holds the address of the owner.
    /// @dev `bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)`
    bytes32 internal constant PROXY_OWNER_ADDRESS = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /// @notice The address that represents the system caller responsible for L1 attributes transactions.
    address internal constant DEPOSITOR_ACCOUNT = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;

    /// @notice Storage slot for Initializable contract's initialized flag
    /// @dev This is the keccak256 of "eip1967.proxy.initialized" - 1
    bytes32 internal constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    uint256 internal constant historicalBackfillApproxDoneAt = 1764024440;
}

/// @title Predeploys
/// @notice Defines all predeploy addresses for the L2 chain
library Predeploys {
    // ============ OP Stack Predeploys ============

    /// @notice L1Block predeploy (stores L1 block information)
    address constant L1_BLOCK_ATTRIBUTES = 0x4200000000000000000000000000000000000015;

    /// @notice Depositor Account (system address that can make deposits)
    address constant DEPOSITOR_ACCOUNT = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;

    /// @notice L2ToL1MessagePasser predeploy (for L2->L1 messages)
    address constant L2_TO_L1_MESSAGE_PASSER = 0x4200000000000000000000000000000000000016;

    /// @notice ProxyAdmin predeploy (manages all proxy upgrades)
    address constant PROXY_ADMIN = 0x4200000000000000000000000000000000000018;

    address constant MultiCall3 = 0xcA11bde05977b3631167028862bE2a173976CA11;

    // ============ Ethscriptions System Predeploys ============
    // Using 0x3300… namespace for Ethscriptions contracts

    /// @notice Ethscriptions NFT contract
    /// @dev Moved to the 0x3300… namespace to align with other Ethscriptions predeploys
    address constant ETHSCRIPTIONS = 0x3300000000000000000000000000000000000001;

    /// @notice ERC20 fixed denomination manager for managed ERC-20 semantics
    address constant ERC20_FIXED_DENOMINATION_MANAGER = 0x3300000000000000000000000000000000000002;

    /// @notice EthscriptionsProver for L1 provability
    address constant ETHSCRIPTIONS_PROVER = 0x3300000000000000000000000000000000000003;

    /// @notice Implementation address for the ERC20 fixed denomination template (actual logic contract)
    address constant ERC20_FIXED_DENOMINATION_IMPLEMENTATION = 0xc0D3c0D3c0D3c0d3c0d3C0d3C0d3c0D3C0D30004;

    /// @notice Implementation address for the ERC721 Ethscriptions collection template (actual logic contract)
    address constant ERC721_ETHSCRIPTIONS_COLLECTION_IMPLEMENTATION = 0xc0d3C0d3c0D3c0d3C0D3C0D3c0D3C0D3c0d30005;

    /// @notice ERC721 Ethscriptions collection manager
    address constant ERC721_ETHSCRIPTIONS_COLLECTION_MANAGER = 0x3300000000000000000000000000000000000006;

    // ============ Helper Functions ============

    /// @notice Returns true if the address is an OP Stack predeploy (0x4200… namespace)
    function isOPPredeployNamespace(address _addr) internal pure returns (bool) {
        return uint160(_addr) >> 11 == uint160(0x4200000000000000000000000000000000000000) >> 11;
    }

    /// @notice Returns true if the address is an Ethscriptions predeploy (0x3300… namespace)
    function isEthscriptionsPredeployNamespace(address _addr) internal pure returns (bool) {
        return uint160(_addr) >> 11 == uint160(0x3300000000000000000000000000000000000000) >> 11;
    }

    /// @notice Returns true if the address is a recognized predeploy (OP or Ethscriptions)
    function isPredeployNamespace(address _addr) internal pure returns (bool) {
        return isOPPredeployNamespace(_addr) || isEthscriptionsPredeployNamespace(_addr);
    }

    /// @notice Converts a predeploy address to its code namespace equivalent
    function predeployToCodeNamespace(address _addr) internal pure returns (address) {
        require(
            isPredeployNamespace(_addr), "Predeploys: can only derive code-namespace address for predeploy addresses"
        );
        return address(
            uint160(uint256(uint160(_addr)) & 0xffff | uint256(uint160(0xc0D3C0d3C0d3C0D3c0d3C0d3c0D3C0d3c0d30000)))
        );
    }

    bytes internal constant MultiCall3Code =
        hex"6080604052600436106100f35760003560e01c80634d2301cc1161008a578063a8b0574e11610059578063a8b0574e1461025a578063bce38bd714610275578063c3077fa914610288578063ee82ac5e1461029b57600080fd5b80634d2301cc146101ec57806372425d9d1461022157806382ad56cb1461023457806386d516e81461024757600080fd5b80633408e470116100c65780633408e47014610191578063399542e9146101a45780633e64a696146101c657806342cbb15c146101d957600080fd5b80630f28c97d146100f8578063174dea711461011a578063252dba421461013a57806327e86d6e1461015b575b600080fd5b34801561010457600080fd5b50425b6040519081526020015b60405180910390f35b61012d610128366004610a85565b6102ba565b6040516101119190610bbe565b61014d610148366004610a85565b6104ef565b604051610111929190610bd8565b34801561016757600080fd5b50437fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0140610107565b34801561019d57600080fd5b5046610107565b6101b76101b2366004610c60565b610690565b60405161011193929190610cba565b3480156101d257600080fd5b5048610107565b3480156101e557600080fd5b5043610107565b3480156101f857600080fd5b50610107610207366004610ce2565b73ffffffffffffffffffffffffffffffffffffffff163190565b34801561022d57600080fd5b5044610107565b61012d610242366004610a85565b6106ab565b34801561025357600080fd5b5045610107565b34801561026657600080fd5b50604051418152602001610111565b61012d610283366004610c60565b61085a565b6101b7610296366004610a85565b610a1a565b3480156102a757600080fd5b506101076102b6366004610d18565b4090565b60606000828067ffffffffffffffff8111156102d8576102d8610d31565b60405190808252806020026020018201604052801561031e57816020015b6040805180820190915260008152606060208201528152602001906001900390816102f65790505b5092503660005b8281101561047757600085828151811061034157610341610d60565b6020026020010151905087878381811061035d5761035d610d60565b905060200281019061036f9190610d8f565b6040810135958601959093506103886020850185610ce2565b73ffffffffffffffffffffffffffffffffffffffff16816103ac6060870187610dcd565b6040516103ba929190610e32565b60006040518083038185875af1925050503d80600081146103f7576040519150601f19603f3d011682016040523d82523d6000602084013e6103fc565b606091505b50602080850191909152901515808452908501351761046d577f08c379a000000000000000000000000000000000000000000000000000000000600052602060045260176024527f4d756c746963616c6c333a2063616c6c206661696c656400000000000000000060445260846000fd5b5050600101610325565b508234146104e6576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601a60248201527f4d756c746963616c6c333a2076616c7565206d69736d6174636800000000000060448201526064015b60405180910390fd5b50505092915050565b436060828067ffffffffffffffff81111561050c5761050c610d31565b60405190808252806020026020018201604052801561053f57816020015b606081526020019060019003908161052a5790505b5091503660005b8281101561068657600087878381811061056257610562610d60565b90506020028101906105749190610e42565b92506105836020840184610ce2565b73ffffffffffffffffffffffffffffffffffffffff166105a66020850185610dcd565b6040516105b4929190610e32565b6000604051808303816000865af19150503d80600081146105f1576040519150601f19603f3d011682016040523d82523d6000602084013e6105f6565b606091505b5086848151811061060957610609610d60565b602090810291909101015290508061067d576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f4d756c746963616c6c333a2063616c6c206661696c656400000000000000000060448201526064016104dd565b50600101610546565b5050509250929050565b43804060606106a086868661085a565b905093509350939050565b6060818067ffffffffffffffff8111156106c7576106c7610d31565b60405190808252806020026020018201604052801561070d57816020015b6040805180820190915260008152606060208201528152602001906001900390816106e55790505b5091503660005b828110156104e657600084828151811061073057610730610d60565b6020026020010151905086868381811061074c5761074c610d60565b905060200281019061075e9190610e76565b925061076d6020840184610ce2565b73ffffffffffffffffffffffffffffffffffffffff166107906040850185610dcd565b60405161079e929190610e32565b6000604051808303816000865af19150503d80600081146107db576040519150601f19603f3d011682016040523d82523d6000602084013e6107e0565b606091505b506020808401919091529015158083529084013517610851577f08c379a000000000000000000000000000000000000000000000000000000000600052602060045260176024527f4d756c746963616c6c333a2063616c6c206661696c656400000000000000000060445260646000fd5b50600101610714565b6060818067ffffffffffffffff81111561087657610876610d31565b6040519080825280602002602001820160405280156108bc57816020015b6040805180820190915260008152606060208201528152602001906001900390816108945790505b5091503660005b82811015610a105760008482815181106108df576108df610d60565b602002602001015190508686838181106108fb576108fb610d60565b905060200281019061090d9190610e42565b925061091c6020840184610ce2565b73ffffffffffffffffffffffffffffffffffffffff1661093f6020850185610dcd565b60405161094d929190610e32565b6000604051808303816000865af19150503d806000811461098a576040519150601f19603f3d011682016040523d82523d6000602084013e61098f565b606091505b506020830152151581528715610a07578051610a07576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f4d756c746963616c6c333a2063616c6c206661696c656400000000000000000060448201526064016104dd565b506001016108c3565b5050509392505050565b6000806060610a2b60018686610690565b919790965090945092505050565b60008083601f840112610a4b57600080fd5b50813567ffffffffffffffff811115610a6357600080fd5b6020830191508360208260051b8501011115610a7e57600080fd5b9250929050565b60008060208385031215610a9857600080fd5b823567ffffffffffffffff811115610aaf57600080fd5b610abb85828601610a39565b90969095509350505050565b6000815180845260005b81811015610aed57602081850181015186830182015201610ad1565b81811115610aff576000602083870101525b50601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0169290920160200192915050565b600082825180855260208086019550808260051b84010181860160005b84811015610bb1578583037fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe001895281518051151584528401516040858501819052610b9d81860183610ac7565b9a86019a9450505090830190600101610b4f565b5090979650505050505050565b602081526000610bd16020830184610b32565b9392505050565b600060408201848352602060408185015281855180845260608601915060608160051b870101935082870160005b82811015610c52577fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa0888703018452610c40868351610ac7565b95509284019290840190600101610c06565b509398975050505050505050565b600080600060408486031215610c7557600080fd5b83358015158114610c8557600080fd5b9250602084013567ffffffffffffffff811115610ca157600080fd5b610cad86828701610a39565b9497909650939450505050565b838152826020820152606060408201526000610cd96060830184610b32565b95945050505050565b600060208284031215610cf457600080fd5b813573ffffffffffffffffffffffffffffffffffffffff81168114610bd157600080fd5b600060208284031215610d2a57600080fd5b5035919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b600082357fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff81833603018112610dc357600080fd5b9190910192915050565b60008083357fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1843603018112610e0257600080fd5b83018035915067ffffffffffffffff821115610e1d57600080fd5b602001915036819003821315610a7e57600080fd5b8183823760009101908152919050565b600082357fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc1833603018112610dc357600080fd5b600082357fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa1833603018112610dc357600080fdfea2646970667358221220bb2b5c71a328032f97c676ae39a1ec2148d3e5d6f73d95e9b17910152d61f16264736f6c634300080c0033";
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface L1Block {
    function DEPOSITOR_ACCOUNT() external pure returns (address addr_);
    function number() external view returns (uint64);
    function timestamp() external view returns (uint64);
    function hash() external view returns (bytes32);
}

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface EthscriptionsProver {
    function queueEthscription(bytes32 ethscriptionId) external;
    function flushAllProofs() external;
}

/// @title BytePackLib
/// @notice Library for packing small byte arrays (0-31 bytes) into a single bytes32 slot
/// @dev Uses a tag byte (length + 1) to distinguish packed data from regular addresses/data
library BytePackLib {
    error ContentTooLarge(uint256 size);
    error NotPackedData();

    /// @notice Pack bytes calldata up to 31 bytes into a bytes32
    /// @dev Calldata version for gas optimization when called with external data
    /// @param data The data to pack (must be <= 31 bytes)
    /// @return packed The packed bytes32 value
    function packCalldata(bytes calldata data) internal pure returns (bytes32 packed) {
        uint256 len = data.length;
        if (len >= 32) {
            revert ContentTooLarge(len);
        }

        assembly {
            // Pack: tag byte (len+1) | first 31 bytes of data
            packed :=
                or(
                    shl(248, add(len, 1)), // Tag in first byte
                    shr(8, calldataload(data.offset)) // Data in remaining 31 bytes
                )
        }
    }

    /// @notice Pack bytes memory up to 31 bytes into a bytes32
    /// @dev Memory version for when data is in memory
    /// @param data The data to pack (must be <= 31 bytes)
    /// @return packed The packed bytes32 value
    function pack(bytes memory data) internal pure returns (bytes32 packed) {
        uint256 len = data.length;
        if (len >= 32) {
            revert ContentTooLarge(len);
        }

        assembly {
            // Pack: tag byte (len+1) | first 31 bytes of data
            packed :=
                or(
                    shl(248, add(len, 1)), // Tag in first byte
                    shr(8, mload(add(data, 0x20))) // Data in remaining 31 bytes (skip length prefix)
                )
        }
    }

    /// @notice Unpack a bytes32 value into bytes
    /// @dev Extracts the data based on the tag byte (length + 1)
    /// @param packed The packed bytes32 value
    /// @return data The unpacked bytes data
    function unpack(bytes32 packed) internal pure returns (bytes memory data) {
        uint256 tag = uint8(uint256(packed >> 248));
        if (tag == 0 || tag > 32) {
            revert NotPackedData();
        }

        uint256 len = tag - 1;
        data = new bytes(len);

        if (len > 0) {
            assembly {
                // Store the data (shift left by 8 to remove tag byte)
                mstore(add(data, 0x20), shl(8, packed))
                // Note: No need to zero memory after the data since new bytes() already zeroes it
                // and we're only writing up to 31 bytes into a 32-byte word
            }
        }
    }

    /// @notice Check if a bytes32 value is packed data
    /// @dev Returns true if the first byte indicates packed data (tag between 1-32)
    /// @param value The bytes32 value to check
    /// @return True if the value is packed data, false otherwise
    function isPacked(bytes32 value) internal pure returns (bool) {
        // Packed data has a tag byte between 1-32 in the first byte
        uint256 tag = uint8(uint256(value >> 248));
        return tag > 0 && tag <= 32;
    }

    /// @notice Get the length of packed data without unpacking
    /// @dev Returns the length stored in the tag byte
    /// @param packed The packed bytes32 value
    /// @return The length of the packed data (0-31)
    function packedLength(bytes32 packed) internal pure returns (uint256) {
        uint256 tag = uint8(uint256(packed >> 248));
        if (tag == 0 || tag > 32) {
            revert NotPackedData();
        }
        return tag - 1;
    }
}

/// @notice Read and write to persistent storage at a fraction of the cost.
/// @notice Modified to support unlimited content size (up to 4GB) using PUSH4
/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/SSTORE2.sol)
library SSTORE2Unlimited {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Unable to deploy the storage contract.
    error DeploymentFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         WRITE LOGIC                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Writes `data` into the bytecode of a storage contract and returns its address.
    /// Uses a simpler approach with abi.encodePacked for clarity
    function write(bytes memory data) internal returns (address pointer) {
        // Prefix the bytecode with a STOP opcode to ensure it cannot be called.
        bytes memory runtimeCode = abi.encodePacked(hex"00", data);

        bytes memory creationCode = abi.encodePacked(
            //---------------------------------------------------------------------------------------------------------------//
            // Opcode  | Opcode + Arguments  | Description  | Stack View                                                     //
            //---------------------------------------------------------------------------------------------------------------//
            // 0x60    |  0x600B             | PUSH1 11     | codeOffset                                                     //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset                                                   //
            // 0x81    |  0x81               | DUP2         | codeOffset 0 codeOffset                                        //
            // 0x38    |  0x38               | CODESIZE     | codeSize codeOffset 0 codeOffset                               //
            // 0x03    |  0x03               | SUB          | (codeSize - codeOffset) 0 codeOffset                           //
            // 0x80    |  0x80               | DUP          | (codeSize - codeOffset) (codeSize - codeOffset) 0 codeOffset   //
            // 0x92    |  0x92               | SWAP3        | codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset)   //
            // 0x59    |  0x59               | MSIZE        | 0 codeOffset (codeSize - codeOffset) 0 (codeSize - codeOffset) //
            // 0x39    |  0x39               | CODECOPY     | 0 (codeSize - codeOffset)                                      //
            // 0xf3    |  0xf3               | RETURN       |                                                                //
            //---------------------------------------------------------------------------------------------------------------//
            hex"600B5981380380925939F3", // Returns all code in the contract except for the first 11 (0B in hex) bytes.
            runtimeCode // The bytecode we want the contract to have after deployment.
        );

        /// @solidity memory-safe-assembly
        assembly {
            // Deploy a new contract with the generated creation code.
            // We start 32 bytes into the code to avoid copying the byte length.
            pointer := create(0, add(creationCode, 32), mload(creationCode))

            if iszero(pointer) {
                mstore(0x00, 0x30116425) // `DeploymentFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         READ LOGIC                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The offset of the data in the bytecode (skipping the STOP opcode).
    uint256 private constant DATA_OFFSET = 1;

    /// @dev Reads all data from the storage contract, skipping the initial STOP opcode.
    function read(address pointer) internal view returns (bytes memory) {
        return readBytecode(pointer, DATA_OFFSET, pointer.code.length - DATA_OFFSET);
    }

    /// @dev Reads bytecode from a contract at a specific offset and size.
    function readBytecode(address pointer, uint256 start, uint256 size) private view returns (bytes memory data) {
        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            data := mload(0x40)

            // Update the free memory pointer to prevent overriding our data.
            // We use and(x, not(31)) as a cheaper equivalent to sub(x, mod(x, 32)).
            // Adding 31 to size and running the result through the logic above ensures
            // the memory pointer remains word-aligned, following the Solidity convention.
            mstore(0x40, add(data, and(add(add(size, 32), 31), not(31))))

            // Store the size of the data in the first 32 byte chunk of free memory.
            mstore(data, size)

            // Copy the code into memory right after the 32 bytes we used to store the size.
            extcodecopy(pointer, add(data, 32), start, size)
        }
    }
}

/// @title DedupedBlobStore
/// @notice Shared library for deduplicated blob storage using inline packing or SSTORE2
/// @dev Used by both content storage and metadata storage to eliminate code duplication
library DedupedBlobStore {
    /// @notice Store calldata blob with deduplication using keccak256
    /// @dev Uses keccak256 for dedup key, stores either packed (≤31 bytes) or SSTORE2 pointer
    /// @param data The calldata to store
    /// @param store The storage mapping (hash => ref)
    /// @return hash The keccak256 hash of the data (dedup key)
    /// @return ref The storage reference (packed or SSTORE2 pointer)
    function storeCalldata(bytes calldata data, mapping(bytes32 => bytes32) storage store)
        internal
        returns (bytes32 hash, bytes32 ref)
    {
        hash = keccak256(data);

        // Check if already stored
        bytes32 existing = store[hash];
        if (existing != bytes32(0)) {
            return (hash, existing);
        }

        // Store based on size - use calldata packing for efficiency
        ref = data.length <= 31 ? BytePackLib.packCalldata(data) : _deploySST0RE2Calldata(data);

        // Store the mapping: hash -> reference
        store[hash] = ref;
        return (hash, ref);
    }

    /// @notice Store memory blob with deduplication using keccak256
    /// @dev Uses keccak256 for dedup key, stores either packed (≤31 bytes) or SSTORE2 pointer
    /// @param data The memory data to store
    /// @param store The storage mapping (hash => ref)
    /// @return hash The keccak256 hash of the data (dedup key)
    /// @return ref The storage reference (packed or SSTORE2 pointer)
    function storeMemory(bytes memory data, mapping(bytes32 => bytes32) storage store)
        internal
        returns (bytes32 hash, bytes32 ref)
    {
        hash = keccak256(data);

        // Check if already stored
        bytes32 existing = store[hash];
        if (existing != bytes32(0)) {
            return (hash, existing);
        }

        // Store based on size - use memory packing
        ref = data.length <= 31 ? BytePackLib.pack(data) : _deploySST0RE2Memory(data);

        // Store the mapping: hash -> reference
        store[hash] = ref;
        return (hash, ref);
    }

    /// @notice Deploy SSTORE2 contract and return reference
    /// @param data The data to deploy (calldata or memory)
    /// @return ref The SSTORE2 pointer as bytes32
    function _deploySST0RE2Calldata(bytes calldata data) private returns (bytes32 ref) {
        address pointer = SSTORE2Unlimited.write(data);
        return bytes32(uint256(uint160(pointer)));
    }

    /// @notice Deploy SSTORE2 contract and return reference
    /// @param data The data to deploy (calldata or memory)
    /// @return ref The SSTORE2 pointer as bytes32
    function _deploySST0RE2Memory(bytes memory data) private returns (bytes32 ref) {
        address pointer = SSTORE2Unlimited.write(data);
        return bytes32(uint256(uint160(pointer)));
    }

    /// @notice Read blob from storage reference
    /// @dev Automatically detects packed vs SSTORE2 and retrieves accordingly
    /// @param ref The storage reference (packed or SSTORE2 pointer)
    /// @return data The retrieved blob
    function read(bytes32 ref) internal view returns (bytes memory) {
        // Check if it's inline packed content
        if (BytePackLib.isPacked(ref)) {
            return BytePackLib.unpack(ref);
        }

        // It's a pointer to SSTORE2 contract
        address pointer = address(uint160(uint256(ref)));
        return SSTORE2Unlimited.read(pointer);
    }

    /// @notice Read blob from storage reference and convert to string
    /// @dev Convenience wrapper to avoid repetitive string() casting
    /// @param ref The storage reference (packed or SSTORE2 pointer)
    /// @return str The retrieved data as string
    function readString(bytes32 ref) internal view returns (string memory) {
        return string(read(ref));
    }

    /// @notice Read blob from storage mapping by hash
    /// @dev Looks up reference in mapping, then reads
    /// @param hash The hash key
    /// @param store The storage mapping
    /// @return data The retrieved blob
    function readByHash(bytes32 hash, mapping(bytes32 => bytes32) storage store) internal view returns (bytes memory) {
        bytes32 ref = store[hash];
        return read(ref);
    }
}

/// @title MetaStoreLib
/// @notice Library for deduplicated storage of ethscription metadata (mimetype, protocol, operation)
/// @dev Encodes metadata as: mimetype\x00protocol\x00operation, stores once per unique combination
library MetaStoreLib {
    using LibBytes for bytes;

    /// @dev Null byte (0x00) used to separate metadata components
    /// @dev Safe to use as Ruby indexer strips all null bytes from input strings
    bytes1 constant SEPARATOR = 0x00;

    /// @dev Sentinel value for "text/plain" with no protocol (most common case)
    bytes32 constant EMPTY_REF = bytes32(0);

    // Custom errors
    error InvalidSeparatorInInput();
    error InvalidMetadataRef();
    error MetadataNotStored();
    error InvalidFormat();

    /// @notice Store metadata components (encode + deduplicate)
    /// @dev High-level API for callers - combines encode() and intern()
    /// @param mimetype MIME type string (preserve case for standards compliance)
    /// @param protocolName Protocol identifier (should already be normalized by Ruby)
    /// @param operation Operation to perform (should already be normalized by Ruby)
    /// @param metaStore Storage mapping for metadata blobs
    /// @return metaRef The metadata reference (bytes32(0), packed, or SSTORE2 pointer)
    function store(
        string memory mimetype,
        string memory protocolName,
        string memory operation,
        mapping(bytes32 => bytes32) storage metaStore
    ) internal returns (bytes32 metaRef) {
        bytes memory blob = encode(mimetype, protocolName, operation);
        return intern(blob, metaStore);
    }

    /// @notice Encode metadata components into a blob
    /// @dev Lower-level API - most callers should use store() instead
    /// @param mimetype MIME type string (not normalized - preserve case for standards compliance)
    /// @param protocolName Protocol identifier (should already be normalized by Ruby)
    /// @param operation Operation name (should already be normalized by Ruby)
    /// @return blob The encoded metadata blob (empty if all components empty/default)
    function encode(string memory mimetype, string memory protocolName, string memory operation)
        internal
        pure
        returns (bytes memory blob)
    {
        // Validate inputs don't contain separator
        if (_containsByte(bytes(mimetype), SEPARATOR)) {
            revert InvalidSeparatorInInput();
        }
        if (_containsByte(bytes(protocolName), SEPARATOR)) {
            revert InvalidSeparatorInInput();
        }
        if (_containsByte(bytes(operation), SEPARATOR)) {
            revert InvalidSeparatorInInput();
        }

        // Note: normalization (lowercase, trim) is handled by Ruby indexer before submission

        // Normalize "text/plain" to empty string (convention: empty = text/plain)
        if (keccak256(bytes(mimetype)) == keccak256(bytes("text/plain"))) {
            mimetype = "";
        }

        // Special case: empty mimetype + no protocol → empty blob (most common case!)
        if (bytes(mimetype).length == 0 && bytes(protocolName).length == 0 && bytes(operation).length == 0) {
            return bytes(""); // Will map to EMPTY_REF (bytes32(0))
        }

        // Always encode in same format: mimetype\x1Fprotocol\x1Foperation
        // Any component can be empty string
        return abi.encodePacked(mimetype, SEPARATOR, protocolName, SEPARATOR, operation);
    }

    /// @notice Decode a metadata reference into components
    /// @param metaRef The metadata reference (bytes32(0), packed, or SSTORE2 pointer)
    /// @return mimetype The MIME type
    /// @return protocolName The protocol identifier (normalized)
    /// @return operation The operation name (normalized)
    function decode(bytes32 metaRef)
        internal
        view
        returns (string memory mimetype, string memory protocolName, string memory operation)
    {
        bytes[] memory parts = _getParts(metaRef);
        return _partsToStrings(parts);
    }

    /// @notice Get only the mimetype from a metadata reference (gas-optimized)
    /// @param metaRef The metadata reference
    /// @return mimetype The MIME type
    function getMimetype(bytes32 metaRef) internal view returns (string memory mimetype) {
        bytes[] memory parts = _getParts(metaRef);

        // First part is always mimetype (empty = text/plain)
        string memory mime = string(parts[0]);
        return bytes(mime).length == 0 ? "text/plain" : mime;
    }

    /// @notice Get protocol information from a metadata reference
    /// @param metaRef The metadata reference
    /// @return protocolName The protocol identifier (normalized, empty if none)
    /// @return operation The operation name (normalized, empty if none)
    function getProtocol(bytes32 metaRef) internal view returns (string memory protocolName, string memory operation) {
        bytes[] memory parts = _getParts(metaRef);

        // parts[0] = mimetype, parts[1] = protocol, parts[2] = operation
        protocolName = string(parts[1]);
        operation = string(parts[2]);
        return (protocolName, operation);
    }

    /// @notice Intern a metadata blob (deduplicate and store)
    /// @dev Lower-level API - most callers should use store() instead
    /// @param blob The encoded metadata blob
    /// @param metaStore Storage mapping for metadata blobs
    /// @return metaRef The metadata reference (bytes32(0), packed, or SSTORE2 pointer)
    function intern(bytes memory blob, mapping(bytes32 => bytes32) storage metaStore)
        internal
        returns (bytes32 metaRef)
    {
        // Special case: empty blob = EMPTY_REF sentinel
        if (blob.length == 0) {
            return EMPTY_REF;
        }

        // Use shared deduplication logic with keccak256
        (, metaRef) = DedupedBlobStore.storeMemory(blob, metaStore);
        return metaRef;
    }

    // =============================================================
    //                     INTERNAL HELPERS
    // =============================================================

    /// @notice Retrieve a blob from storage
    /// @param metaRef The metadata reference
    /// @return blob The retrieved blob
    function _retrieve(bytes32 metaRef) private view returns (bytes memory blob) {
        if (metaRef == EMPTY_REF) {
            return bytes("");
        }

        // Use shared read logic
        return DedupedBlobStore.read(metaRef);
    }

    /// @notice Get parts array from metadata reference (single point for blob.length check)
    /// @param metaRef The metadata reference
    /// @return parts Array of 3 byte parts [mimetype, protocol, operation]
    function _getParts(bytes32 metaRef) private view returns (bytes[] memory parts) {
        bytes memory blob = _retrieve(metaRef);

        // Single check for empty blob (text/plain + no protocol case)
        if (blob.length == 0) {
            parts = new bytes[](3);
            parts[0] = bytes(""); // Empty = text/plain
            parts[1] = bytes(""); // No protocol
            parts[2] = bytes(""); // No operation
            return parts;
        }

        // Split keeping empty parts - always get 3 parts
        return _splitKeepEmpty(blob, SEPARATOR);
    }

    /// @notice Convert parts array to strings with text/plain default
    /// @param parts Array of 3 byte parts [mimetype, protocol, operation]
    /// @return mimetype The MIME type
    /// @return protocolName The protocol identifier
    /// @return operation The operation name
    function _partsToStrings(bytes[] memory parts)
        private
        pure
        returns (string memory mimetype, string memory protocolName, string memory operation)
    {
        // Extract mimetype (empty = text/plain)
        mimetype = string(parts[0]);
        if (bytes(mimetype).length == 0) {
            mimetype = "text/plain";
        }

        // Extract protocol and operation (may be empty)
        protocolName = string(parts[1]);
        operation = string(parts[2]);

        return (mimetype, protocolName, operation);
    }

    /// @notice Split a blob by single-byte delimiter, keeping empty parts
    /// @dev Enforces exactly 2 separators (3 parts): [mimetype, protocol, operation]
    /// @param subject The blob to split
    /// @param delim The single-byte delimiter
    /// @return out Array with exactly 3 parts (some may be empty)
    function _splitKeepEmpty(bytes memory subject, bytes1 delim) private pure returns (bytes[] memory out) {
        // Find first separator
        uint256 a = subject.indexOfByte(delim, 0);
        if (a == LibBytes.NOT_FOUND) {
            revert InvalidFormat();
        }

        // Find second separator
        uint256 b = subject.indexOfByte(delim, a + 1);
        if (b == LibBytes.NOT_FOUND) {
            revert InvalidFormat();
        }

        // Ensure no third separator (enforce format)
        if (subject.indexOfByte(delim, b + 1) != LibBytes.NOT_FOUND) {
            revert InvalidFormat();
        }

        out = new bytes[](3);
        out[0] = subject.slice(0, a); // mimetype (may be empty)
        out[1] = subject.slice(a + 1, b); // protocol (may be empty)
        out[2] = subject.slice(b + 1, subject.length); // operation (may be empty)
    }

    /// @notice Check if bytes contains a specific byte
    /// @dev Custom helper since LibBytes.contains requires bytes memory, not bytes1
    /// @param data The data to search
    /// @param target The byte to find
    /// @return True if found
    function _containsByte(bytes memory data, bytes1 target) private pure returns (bool) {
        return data.indexOfByte(target) != LibBytes.NOT_FOUND;
    }
}

/// @notice Library to encode strings in Base64.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Base64.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Base64.sol)
/// @author Modified from (https://github.com/Brechtpd/base64/blob/main/base64.sol) by Brecht Devos - <brecht@loopring.org>.
library Base64 {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    ENCODING / DECODING                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// See: https://datatracker.ietf.org/doc/html/rfc4648
    /// @param fileSafe  Whether to replace '+' with '-' and '/' with '_'.
    /// @param noPadding Whether to strip away the padding.
    function encode(bytes memory data, bool fileSafe, bool noPadding) internal pure returns (string memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let dataLength := mload(data)

            if dataLength {
                // Multiply by 4/3 rounded up.
                // The `shl(2, ...)` is equivalent to multiplying by 4.
                let encodedLength := shl(2, div(add(dataLength, 2), 3))

                // Set `result` to point to the start of the free memory.
                result := mload(0x40)

                // Store the table into the scratch space.
                // Offsetted by -1 byte so that the `mload` will load the character.
                // We will rewrite the free memory pointer at `0x40` later with
                // the allocated size.
                // The magic constant 0x0670 will turn "-_" into "+/".
                mstore(0x1f, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef")
                mstore(0x3f, xor("ghijklmnopqrstuvwxyz0123456789-_", mul(iszero(fileSafe), 0x0670)))

                // Skip the first slot, which stores the length.
                let ptr := add(result, 0x20)
                let end := add(ptr, encodedLength)

                let dataEnd := add(add(0x20, data), dataLength)
                let dataEndValue := mload(dataEnd) // Cache the value at the `dataEnd` slot.
                mstore(dataEnd, 0x00) // Zeroize the `dataEnd` slot to clear dirty bits.

                // Run over the input, 3 bytes at a time.
                for {} 1 {} {
                    data := add(data, 3) // Advance 3 bytes.
                    let input := mload(data)

                    // Write 4 bytes. Optimized for fewer stack operations.
                    mstore8(0, mload(and(shr(18, input), 0x3F)))
                    mstore8(1, mload(and(shr(12, input), 0x3F)))
                    mstore8(2, mload(and(shr(6, input), 0x3F)))
                    mstore8(3, mload(and(input, 0x3F)))
                    mstore(ptr, mload(0x00))

                    ptr := add(ptr, 4) // Advance 4 bytes.
                    if iszero(lt(ptr, end)) { break }
                }
                mstore(dataEnd, dataEndValue) // Restore the cached value at `dataEnd`.
                mstore(0x40, add(end, 0x20)) // Allocate the memory.
                // Equivalent to `o = [0, 2, 1][dataLength % 3]`.
                let o := div(2, mod(dataLength, 3))
                // Offset `ptr` and pad with '='. We can simply write over the end.
                mstore(sub(ptr, o), shl(240, 0x3d3d))
                // Set `o` to zero if there is padding.
                o := mul(iszero(iszero(noPadding)), o)
                mstore(sub(ptr, o), 0) // Zeroize the slot after the string.
                mstore(result, sub(encodedLength, o)) // Store the length.
            }
        }
    }

    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// Equivalent to `encode(data, false, false)`.
    function encode(bytes memory data) internal pure returns (string memory result) {
        result = encode(data, false, false);
    }

    /// @dev Encodes `data` using the base64 encoding described in RFC 4648.
    /// Equivalent to `encode(data, fileSafe, false)`.
    function encode(bytes memory data, bool fileSafe) internal pure returns (string memory result) {
        result = encode(data, fileSafe, false);
    }

    /// @dev Decodes base64 encoded `data`.
    ///
    /// Supports:
    /// - RFC 4648 (both standard and file-safe mode).
    /// - RFC 3501 (63: ',').
    ///
    /// Does not support:
    /// - Line breaks.
    ///
    /// Note: For performance reasons,
    /// this function will NOT revert on invalid `data` inputs.
    /// Outputs for invalid inputs will simply be undefined behaviour.
    /// It is the user's responsibility to ensure that the `data`
    /// is a valid base64 encoded string.
    function decode(string memory data) internal pure returns (bytes memory result) {
        /// @solidity memory-safe-assembly
        assembly {
            let dataLength := mload(data)

            if dataLength {
                let decodedLength := mul(shr(2, dataLength), 3)

                for {} 1 {} {
                    // If padded.
                    if iszero(and(dataLength, 3)) {
                        let t := xor(mload(add(data, dataLength)), 0x3d3d)
                        // forgefmt: disable-next-item
                        decodedLength := sub(
                            decodedLength,
                            add(iszero(byte(30, t)), iszero(byte(31, t)))
                        )
                        break
                    }
                    // If non-padded.
                    decodedLength := add(decodedLength, sub(and(dataLength, 3), 1))
                    break
                }
                result := mload(0x40)

                // Write the length of the bytes.
                mstore(result, decodedLength)

                // Skip the first slot, which stores the length.
                let ptr := add(result, 0x20)
                let end := add(ptr, decodedLength)

                // Load the table into the scratch space.
                // Constants are optimized for smaller bytecode with zero gas overhead.
                // `m` also doubles as the mask of the upper 6 bits.
                let m := 0xfc000000fc00686c7074787c8084888c9094989ca0a4a8acb0b4b8bcc0c4c8cc
                mstore(0x5b, m)
                mstore(0x3b, 0x04080c1014181c2024282c3034383c4044484c5054585c6064)
                mstore(0x1a, 0xf8fcf800fcd0d4d8dce0e4e8ecf0f4)

                for {} 1 {} {
                    // Read 4 bytes.
                    data := add(data, 4)
                    let input := mload(data)

                    // Write 3 bytes.
                    // forgefmt: disable-next-item
                    mstore(ptr, or(
                        and(m, mload(byte(28, input))),
                        shr(6, or(
                            and(m, mload(byte(29, input))),
                            shr(6, or(
                                and(m, mload(byte(30, input))),
                                shr(6, mload(byte(31, input)))
                            ))
                        ))
                    ))
                    ptr := add(ptr, 3)
                    if iszero(lt(ptr, end)) { break }
                }
                mstore(0x40, add(end, 0x20)) // Allocate the memory.
                mstore(end, 0) // Zeroize the slot after the bytes.
                mstore(0x60, 0) // Restore the zero slot.
            }
        }
    }
}

/// @title EthscriptionsRendererLib
/// @notice Library for rendering Ethscription metadata and media URIs
/// @dev Contains all token URI generation, media handling, and metadata formatting logic
library EthscriptionsRendererLib {
    using LibString for *;

    /// @notice Build attributes JSON array from ethscription data
    /// @param etsc Storage pointer to the ethscription
    /// @param ethscriptionId The ethscription ID (L1 tx hash)
    /// @param mimetype The MIME type string (decoded from metadata)
    /// @param protocolName The protocol name (empty if none)
    /// @param operation The operation name (empty if none)
    /// @return JSON string of attributes array
    function buildAttributes(
        Ethscriptions.EthscriptionStorage storage etsc,
        bytes32 ethscriptionId,
        string memory mimetype,
        string memory protocolName,
        string memory operation
    ) internal view returns (string memory) {
        // Build in chunks to avoid stack too deep
        string memory part1 = string.concat(
            '[{"trait_type":"Ethscription ID","value":"',
            uint256(ethscriptionId).toHexString(32),
            '"},{"trait_type":"Ethscription Number","display_type":"number","value":',
            etsc.ethscriptionNumber.toString(),
            '},{"trait_type":"Creator","value":"',
            etsc.creator.toHexString(),
            '"},{"trait_type":"Initial Owner","value":"',
            etsc.initialOwner.toHexString()
        );

        string memory part2 = string.concat(
            '"},{"trait_type":"Content Hash","value":"',
            uint256(etsc.contentHash).toHexString(32),
            '"},{"trait_type":"Content URI SHA","value":"',
            uint256(etsc.contentUriSha).toHexString(32),
            '"},{"trait_type":"MIME Type","value":"',
            mimetype.escapeJSON(),
            '"},{"trait_type":"ESIP-6","value":"',
            etsc.esip6 ? "true" : "false"
        );

        // Add protocol info if present
        string memory protocolAttrs = "";
        if (bytes(protocolName).length > 0) {
            protocolAttrs = string.concat('"},{"trait_type":"Protocol Name","value":"', protocolName.escapeJSON());
            if (bytes(operation).length > 0) {
                protocolAttrs = string.concat(
                    protocolAttrs, '"},{"trait_type":"Protocol Operation","value":"', operation.escapeJSON()
                );
            }
        }

        string memory part3 = string.concat(
            protocolAttrs,
            '"},{"trait_type":"L1 Block Number","display_type":"number","value":',
            uint256(etsc.l1BlockNumber).toString(),
            '},{"trait_type":"L2 Block Number","display_type":"number","value":',
            uint256(etsc.l2BlockNumber).toString(),
            '},{"trait_type":"Created At","display_type":"date","value":',
            etsc.createdAt.toString(),
            "}]"
        );

        return string.concat(part1, part2, part3);
    }

    /// @notice Generate the media URI for an ethscription
    /// @param mimetype The MIME type string
    /// @param content The content bytes
    /// @return mediaType Either "image" or "animation_url"
    /// @return mediaUri The data URI for the media
    function getMediaUri(string memory mimetype, bytes memory content)
        internal
        pure
        returns (string memory mediaType, string memory mediaUri)
    {
        if (mimetype.startsWith("image/")) {
            // Image content: wrap in SVG for pixel-perfect rendering
            string memory imageDataUri = constructDataURI(mimetype, content);
            string memory svg = wrapImageInSVG(imageDataUri);
            mediaUri = constructDataURI("image/svg+xml", bytes(svg));
            return ("image", mediaUri);
        } else {
            // Non-image content: use animation_url
            if (mimetype.startsWith("video/") || mimetype.startsWith("audio/") || mimetype.eq("text/html")) {
                // Video, audio, and HTML pass through directly as data URIs
                mediaUri = constructDataURI(mimetype, content);
            } else {
                // Everything else (text/plain, application/json, etc.) uses the HTML viewer
                mediaUri = createTextViewerDataURI(mimetype, content);
            }
            return ("animation_url", mediaUri);
        }
    }

    /// @notice Build complete token URI JSON
    /// @param etsc Storage pointer to the ethscription
    /// @param ethscriptionId The ethscription ID (L1 tx hash)
    /// @param mimetype The MIME type string (decoded from metadata)
    /// @param protocolName The protocol name (empty if none)
    /// @param operation The operation name (empty if none)
    /// @param content The content bytes
    /// @return The complete base64-encoded data URI
    function buildTokenURI(
        Ethscriptions.EthscriptionStorage storage etsc,
        bytes32 ethscriptionId,
        string memory mimetype,
        string memory protocolName,
        string memory operation,
        bytes memory content
    ) internal view returns (string memory) {
        // Get media URI
        (string memory mediaType, string memory mediaUri) = getMediaUri(mimetype, content);

        // Build attributes
        string memory attributes = buildAttributes(etsc, ethscriptionId, mimetype, protocolName, operation);

        // Build JSON
        string memory json = string.concat(
            '{"name":"Ethscription #',
            etsc.ethscriptionNumber.toString(),
            '","description":"Ethscription #',
            etsc.ethscriptionNumber.toString(),
            " created by ",
            etsc.creator.toHexString(),
            '","',
            mediaType,
            '":"',
            mediaUri,
            '","attributes":',
            attributes,
            "}"
        );

        return string.concat("data:application/json;base64,", Base64.encode(bytes(json)));
    }

    /// @notice Construct a base64-encoded data URI
    /// @param mimetype The MIME type
    /// @param content The content bytes
    /// @return The complete data URI
    function constructDataURI(string memory mimetype, bytes memory content) internal pure returns (string memory) {
        return string.concat("data:", mimetype.escapeJSON(), ";base64,", Base64.encode(content));
    }

    /// @notice Wrap an image in SVG for pixel-perfect rendering
    /// @param imageDataUri The image data URI to wrap
    /// @return The SVG markup
    function wrapImageInSVG(string memory imageDataUri) internal pure returns (string memory) {
        // SVG wrapper that enforces pixelated/nearest-neighbor scaling for pixel art
        return string.concat(
            '<svg width="1200" height="1200" viewBox="0 0 1200 1200" version="1.2" xmlns="http://www.w3.org/2000/svg" style="background-image:url(',
            imageDataUri,
            ');background-repeat:no-repeat;background-size:contain;background-position:center;image-rendering:-webkit-optimize-contrast;image-rendering:-moz-crisp-edges;image-rendering:pixelated;"></svg>'
        );
    }

    /// @notice Create an HTML viewer data URI for text content
    /// @param mimetype The MIME type of the content
    /// @param content The content bytes
    /// @return The HTML viewer data URI
    function createTextViewerDataURI(string memory mimetype, bytes memory content)
        internal
        pure
        returns (string memory)
    {
        // Base64 encode the content for embedding in HTML
        string memory encodedContent = Base64.encode(content);

        // Generate HTML with embedded content
        string memory html = generateTextViewerHTML(encodedContent, mimetype);

        // Return as base64-encoded HTML data URI
        return constructDataURI("text/html", bytes(html));
    }

    /// @notice Generate minimal HTML viewer for text content
    /// @param encodedPayload Base64-encoded content
    /// @param mimetype The MIME type
    /// @return The complete HTML string
    function generateTextViewerHTML(string memory encodedPayload, string memory mimetype)
        internal
        pure
        returns (string memory)
    {
        // Ultra-minimal HTML with inline styles optimized for iframe display
        return string.concat(
            '<!DOCTYPE html><html><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>',
            "<style>*{box-sizing:border-box;margin:0;padding:0;border:0}body{padding:6dvw;background:#0b0b0c;color:#f5f5f5;font-family:monospace;display:flex;justify-content:center;align-items:center;min-height:100dvh;overflow:hidden}",
            "pre{white-space:pre-wrap;word-break:break-word;overflow-wrap:anywhere;line-height:1.4;font-size:14px}</style></head>",
            '<body><pre id="o"></pre><script>',
            'const p="',
            encodedPayload,
            '";',
            'const m="',
            mimetype.escapeJSON(),
            '";',
            'function d(b){try{return decodeURIComponent(atob(b).split("").map(c=>"%"+("00"+c.charCodeAt(0).toString(16)).slice(-2)).join(""))}catch{return null}}',
            'const r=d(p);let t="";',
            "if(r!==null){t=r;try{const j=JSON.parse(r);t=JSON.stringify(j,null,2)}catch{}}",
            'else{t="data:"+m+";base64,"+p}',
            'document.getElementById("o").textContent=t||"(empty)";',
            "</script></body></html>"
        );
    }
}

/// @title IProtocolHandler
/// @notice Interface that all protocol handlers must implement
/// @dev Handlers process protocol-specific logic for Ethscriptions lifecycle events
interface IProtocolHandler {
    /// @notice Called when an Ethscription with this protocol is transferred
    /// @param ethscriptionId The Ethscription ID (L1 tx hash)
    /// @param from The address transferring the Ethscription
    /// @param to The address receiving the Ethscription
    function onTransfer(bytes32 ethscriptionId, address from, address to) external;

    /// @notice Returns human-readable protocol name
    /// @return The protocol name (e.g., "erc-20-fixed-denomination", "erc-721-ethscriptions-collection")
    function protocolName() external pure returns (string memory);
}

/// @title Ethscriptions ERC-721 Contract
/// @notice Mints Ethscriptions as ERC-721 tokens based on L1 transaction data
/// @dev Uses ethscription number as token ID and name, while transaction hash remains the primary identifier for function calls
contract Ethscriptions is ERC721EthscriptionsSequentialEnumerableUpgradeable {
    using LibString for *;

    // =============================================================
    //                          STRUCTS
    // =============================================================

    /// @notice Internal storage struct for ethscriptions (optimized for storage)
    struct EthscriptionStorage {
        // Full slots
        bytes32 contentUriSha; // sha256 of content URI (for protocol uniqueness check)
        bytes32 contentHash; // keccak256 of content (for deduplication)
        bytes32 l1BlockHash;
        // Packed slot (32 bytes)
        address creator;
        uint48 createdAt;
        uint48 l1BlockNumber;
        // Metadata reference (replaces dynamic mimetype string)
        bytes32 metaRef; // Reference to deduplicated metadata (mimetype, protocol, operation)
        // Packed slot (27 bytes used, 5 free)
        address initialOwner;
        uint48 ethscriptionNumber;
        bool esip6;
        // Packed slot (26 bytes used, 6 free)
        address previousOwner;
        uint48 l2BlockNumber;
    }

    struct ProtocolParams {
        string protocolName; // Protocol identifier (e.g., "erc-20-fixed-denomination", "erc-721-ethscriptions-collection", etc.)
        string operation; // Operation to perform (e.g., "mint", "deploy", "create_collection", etc.)
        bytes data; // ABI-encoded parameters specific to the protocol/operation
    }

    struct CreateEthscriptionParams {
        bytes32 ethscriptionId;
        bytes32 contentUriSha; // sha256 of content URI (for protocol uniqueness)
        address initialOwner;
        bytes content; // Raw decoded bytes (not Base64)
        string mimetype;
        bool esip6;
        ProtocolParams protocolParams; // Protocol operation data (optional)
    }

    /// @notice Paginated result for batch queries
    struct PaginatedEthscriptionsResponse {
        Ethscription[] items;
        uint256 total; // total items available (totalSupply or balanceOf(owner))
        uint256 start; // start index used for this page
        uint256 limit; // effective limit used for this page (after clamping)
        uint256 nextStart; // next page start index (end of this page)
        bool hasMore; // true if nextStart < total
    }

    /// @notice Complete denormalized ethscription data for external/off-chain consumption
    /// @dev Includes all EthscriptionStorage fields plus owner and content
    struct Ethscription {
        // Identity
        bytes32 ethscriptionId; // L1 tx hash (the key)
        uint256 ethscriptionNumber; // Token ID
        // Core metadata
        bytes32 contentUriSha; // sha256 of content URI (protocol)
        bytes32 contentHash; // keccak256 of content
        string mimetype;
        bytes content; // Full content bytes (empty when includeContent=false)
        // Ownership
        address currentOwner; // Current owner from ERC721 storage
        address creator;
        address initialOwner;
        address previousOwner;
        // Block/time data
        bytes32 l1BlockHash;
        uint256 l1BlockNumber;
        uint256 l2BlockNumber;
        uint256 createdAt;
        // Protocol
        bool esip6;
        string protocolName; // Protocol identifier (empty if none)
        string operation; // Operation name (empty if none)
    }

    // =============================================================
    //                     CONSTANTS & IMMUTABLES
    // =============================================================

    /// @dev L1Block predeploy for getting L1 block info
    L1Block constant l1Block = L1Block(Predeploys.L1_BLOCK_ATTRIBUTES);

    /// @dev Ethscriptions Prover contract (pre-deployed at known address)
    EthscriptionsProver public constant prover = EthscriptionsProver(Predeploys.ETHSCRIPTIONS_PROVER);

    // =============================================================
    //                         PAGINATION CONSTANTS
    // =============================================================

    /// @dev Maximum page sizes for pagination helpers
    uint256 private constant MAX_PAGE_WITH_CONTENT = 20;
    uint256 private constant MAX_PAGE_WITHOUT_CONTENT = 50;

    // =============================================================
    //                      STATE VARIABLES
    // =============================================================

    /// @dev Ethscription ID (L1 tx hash) => Ethscription data
    mapping(bytes32 => EthscriptionStorage) internal ethscriptions;

    /// @dev Content hash (keccak256) => packed content (for <32 bytes) or SSTORE2 pointer (for >=32 bytes)
    mapping(bytes32 => bytes32) internal contentStorage;

    /// @dev Metadata blob hash (keccak256) => packed metadata or SSTORE2 pointer (for deduplicated metadata storage)
    mapping(bytes32 => bytes32) internal metadataStorage;

    /// @dev Content URI hash => first ethscription tx hash that used it (for protocol uniqueness check)
    /// @dev bytes32(0) means unused, non-zero means the content URI has been used
    mapping(bytes32 => bytes32) public firstEthscriptionByContentUri;

    /// @dev Mapping from token ID (ethscription number) to ethscription ID (L1 tx hash)
    mapping(uint256 => bytes32) public tokenIdToEthscriptionId;

    /// @dev Protocol registry - maps protocol names to handler addresses
    mapping(string => address) public protocolHandlers;

    /// @dev Array of genesis ethscription transaction hashes that need events emitted
    /// @notice This array is populated during genesis and cleared (by popping) when events are emitted
    bytes32[] internal pendingGenesisEvents;

    // =============================================================
    //                      CUSTOM ERRORS
    // =============================================================

    error DuplicateContentUri();
    error InvalidCreator();
    error EthscriptionAlreadyExists();
    error EthscriptionDoesNotExist();
    error OnlyDepositor();
    error InvalidHandler();
    error ProtocolAlreadyRegistered();
    error PreviousOwnerMismatch();
    error NoSuccessfulTransfers();
    error TokenDoesNotExist();
    error InvalidPaginationLimit();

    // =============================================================
    //                          EVENTS
    // =============================================================

    /// @notice Emitted when a new ethscription is created
    event EthscriptionCreated(
        bytes32 indexed ethscriptionId,
        address indexed creator,
        address indexed initialOwner,
        bytes32 contentUriSha,
        bytes32 contentHash,
        uint256 ethscriptionNumber
    );

    /// @notice Emitted when an ethscription is transferred (Ethscriptions protocol semantics)
    /// @dev This event matches the Ethscriptions protocol transfer semantics where 'from' is the initiator
    /// For creations, this shows transfer from creator to initial owner (not from address(0))
    event EthscriptionTransferred(
        bytes32 indexed ethscriptionId, address indexed from, address indexed to, uint256 ethscriptionNumber
    );

    /// @notice Emitted when a protocol handler is registered
    event ProtocolRegistered(string indexed protocol, address indexed handler);

    /// @notice Emitted when a protocol handler operation fails but ethscription continues
    event ProtocolHandlerFailed(bytes32 indexed ethscriptionId, string protocol, bytes revertData);

    /// @notice Emitted when a protocol handler operation succeeds
    event ProtocolHandlerSuccess(bytes32 indexed ethscriptionId, string protocol, bytes returnData);

    // =============================================================
    //                         MODIFIERS
    // =============================================================

    /// @notice Modifier to emit pending genesis events on first real creation
    modifier emitGenesisEvents() {
        _emitPendingGenesisEvents();
        _;
    }

    /// @notice Resolve and validate an ethscription (by ID) or revert
    function _getEthscriptionOrRevert(bytes32 ethscriptionId)
        internal
        view
        returns (EthscriptionStorage storage ethscription)
    {
        if (!_ethscriptionExists(ethscriptionId)) {
            revert EthscriptionDoesNotExist();
        }
        ethscription = ethscriptions[ethscriptionId];
    }

    /// @notice Resolve and validate an ethscription (by tokenId) or revert
    function _getEthscriptionOrRevert(uint256 tokenId)
        internal
        view
        returns (EthscriptionStorage storage ethscription)
    {
        bytes32 id = tokenIdToEthscriptionId[tokenId];
        ethscription = _getEthscriptionOrRevert(id);
    }

    // =============================================================
    //                    ADMIN/SETUP FUNCTIONS
    // =============================================================

    /// @notice Register a protocol handler
    /// @param protocol The protocol identifier (e.g., "erc-20-fixed-denomination", "erc-721-ethscriptions-collection")
    /// @param handler The address of the handler contract
    /// @dev Only callable by the depositor address (used during genesis setup)
    /// @dev Protocol names should already be normalized (lowercase) by the caller
    function registerProtocol(string calldata protocol, address handler) external {
        if (msg.sender != Predeploys.DEPOSITOR_ACCOUNT) {
            revert OnlyDepositor();
        }
        if (handler == address(0)) {
            revert InvalidHandler();
        }
        if (protocolHandlers[protocol] != address(0)) {
            revert ProtocolAlreadyRegistered();
        }

        protocolHandlers[protocol] = handler;

        emit ProtocolRegistered(protocol, handler);
    }

    // =============================================================
    //                    CORE EXTERNAL FUNCTIONS
    // =============================================================

    /// @notice Create (mint) a new ethscription token
    /// @dev Called via system transaction with msg.sender spoofed as the actual creator
    /// @param params Struct containing all ethscription creation parameters
    function createEthscription(CreateEthscriptionParams calldata params)
        external
        emitGenesisEvents
        returns (uint256 tokenId)
    {
        address creator = msg.sender;

        if (creator == address(0)) {
            revert InvalidCreator();
        }
        if (_ethscriptionExists(params.ethscriptionId)) {
            revert EthscriptionAlreadyExists();
        }

        bool contentUriAlreadySeen = firstEthscriptionByContentUri[params.contentUriSha] != bytes32(0);

        if (contentUriAlreadySeen) {
            if (!params.esip6) {
                revert DuplicateContentUri();
            }
        } else {
            firstEthscriptionByContentUri[params.contentUriSha] = params.ethscriptionId;
        }

        // Store content and get content hash (keccak256 of raw bytes)
        bytes32 contentHash = _storeContent(params.content);

        // Store metadata (mimetype, protocol, operation)
        bytes32 metaRef = MetaStoreLib.store(
            params.mimetype, params.protocolParams.protocolName, params.protocolParams.operation, metadataStorage
        );

        ethscriptions[params.ethscriptionId] = EthscriptionStorage({
            contentUriSha: params.contentUriSha,
            contentHash: contentHash,
            l1BlockHash: l1Block.hash(),
            creator: creator,
            createdAt: uint48(block.timestamp),
            l1BlockNumber: uint48(l1Block.number()),
            metaRef: metaRef,
            initialOwner: params.initialOwner,
            ethscriptionNumber: uint48(totalSupply()),
            esip6: params.esip6,
            previousOwner: creator,
            l2BlockNumber: uint48(block.number)
        });

        // Use ethscription number as token ID
        tokenId = totalSupply();

        // Store the mapping from token ID to ethscription ID
        tokenIdToEthscriptionId[tokenId] = params.ethscriptionId;

        // Mint to initial owner (if address(0), mint to creator then transfer)
        if (params.initialOwner == address(0)) {
            _mint(creator, tokenId);
            _transfer(creator, address(0), tokenId);
        } else {
            _mint(params.initialOwner, tokenId);
        }

        emit EthscriptionCreated(
            params.ethscriptionId, creator, params.initialOwner, params.contentUriSha, contentHash, tokenId
        );

        // Handle protocol operations (if any)
        _callProtocolOperation(params.ethscriptionId, params.protocolParams);
    }

    /// @notice Transfer an ethscription
    /// @dev Called via system transaction with msg.sender spoofed as 'from'
    /// @param to The recipient address (can be address(0) for burning)
    /// @param ethscriptionId The ethscription to transfer (used to find token ID)
    function transferEthscription(address to, bytes32 ethscriptionId) external {
        // Load and validate
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);
        uint256 tokenId = ethscription.ethscriptionNumber;
        // Standard ERC721 transfer will handle authorization
        transferFrom(msg.sender, to, tokenId);
    }

    /// @notice Transfer an ethscription with previous owner validation (ESIP-2)
    /// @dev Called via system transaction with msg.sender spoofed as 'from'
    /// @param to The recipient address (can be address(0) for burning)
    /// @param ethscriptionId The ethscription to transfer
    /// @param previousOwner The required previous owner for validation
    function transferEthscriptionForPreviousOwner(address to, bytes32 ethscriptionId, address previousOwner) external {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);

        // Verify the previous owner matches
        if (ethscription.previousOwner != previousOwner) {
            revert PreviousOwnerMismatch();
        }

        // Use transferFrom which now handles burns when to == address(0)
        transferFrom(msg.sender, to, ethscription.ethscriptionNumber);
    }

    /// @notice Transfer multiple ethscriptions to a single recipient
    /// @dev Continues transferring even if individual transfers fail due to wrong ownership
    /// @param ethscriptionIds Array of ethscription IDs to transfer
    /// @param to The recipient address (can be address(0) for burning)
    /// @return successCount Number of successful transfers
    function transferEthscriptions(address to, bytes32[] calldata ethscriptionIds)
        external
        returns (uint256 successCount)
    {
        for (uint256 i = 0; i < ethscriptionIds.length; i++) {
            // Get the ethscription to find its token ID
            if (!_ethscriptionExists(ethscriptionIds[i])) {
                continue;
            } // Skip non-existent ethscriptions
            EthscriptionStorage storage ethscription = ethscriptions[ethscriptionIds[i]];

            uint256 tokenId = ethscription.ethscriptionNumber;

            // Check if sender owns this token before attempting transfer
            // This prevents reverts and allows us to continue
            if (_ownerOf(tokenId) == msg.sender) {
                // Perform the transfer directly using internal _update
                _update(to, tokenId, msg.sender);
                successCount++;
            }
            // If sender doesn't own the token, just continue to next one
        }

        if (successCount == 0) {
            revert NoSuccessfulTransfers();
        }
    }

    // =============================================================
    //                      VIEW FUNCTIONS
    // =============================================================

    // ---------------------- Token Metadata ----------------------

    function name() public pure override returns (string memory) {
        return "Ethscriptions";
    }

    function symbol() public pure override returns (string memory) {
        return "ETHSCRIPTIONS";
    }

    // ---------------------- Token URI & Media ----------------------

    /// @notice Returns the full data URI for a token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // Find the ethscription for this token ID (ethscription number)
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(tokenId);
        bytes32 id = tokenIdToEthscriptionId[tokenId];

        // Get content
        bytes memory content = _getEthscriptionContent(id);

        // Decode metadata from reference
        (string memory mimetype, string memory protocolName, string memory operation) =
            MetaStoreLib.decode(ethscription.metaRef);

        // Build complete token URI using the library
        return EthscriptionsRendererLib.buildTokenURI(ethscription, id, mimetype, protocolName, operation, content);
    }

    /// @notice Get the media URI for an ethscription (image or animation_url)
    /// @param ethscriptionId The ethscription ID (L1 tx hash) of the ethscription
    /// @return mediaType Either "image" or "animation_url"
    /// @return mediaUri The data URI for the media
    function getMediaUri(bytes32 ethscriptionId)
        external
        view
        returns (string memory mediaType, string memory mediaUri)
    {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);
        bytes memory content = _getEthscriptionContent(ethscriptionId);

        // Decode mimetype from metadata reference
        string memory mimetype = MetaStoreLib.getMimetype(ethscription.metaRef);

        return EthscriptionsRendererLib.getMediaUri(mimetype, content);
    }

    // -------------------- Data Retrieval --------------------

    /// @notice Internal helper to build complete ethscription data
    /// @param ethscriptionId The ethscription ID
    /// @param includeContent Whether to include content bytes
    /// @return complete The complete ethscription data
    function _buildEthscription(bytes32 ethscriptionId, bool includeContent)
        internal
        view
        returns (Ethscription memory)
    {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);

        // Decode metadata from reference
        (string memory mimetype, string memory protocolName, string memory operation) =
            MetaStoreLib.decode(ethscription.metaRef);

        return Ethscription({
            // Identity
            ethscriptionId: ethscriptionId,
            ethscriptionNumber: uint256(ethscription.ethscriptionNumber),
            // Core metadata
            contentUriSha: ethscription.contentUriSha,
            contentHash: ethscription.contentHash,
            mimetype: mimetype,
            content: includeContent ? _getEthscriptionContent(ethscriptionId) : bytes(""),
            // Ownership
            currentOwner: _ownerOf(uint256(ethscription.ethscriptionNumber)),
            creator: ethscription.creator,
            initialOwner: ethscription.initialOwner,
            previousOwner: ethscription.previousOwner,
            // Block/time data
            l1BlockHash: ethscription.l1BlockHash,
            l1BlockNumber: uint256(ethscription.l1BlockNumber),
            l2BlockNumber: uint256(ethscription.l2BlockNumber),
            createdAt: uint256(ethscription.createdAt),
            // Protocol
            esip6: ethscription.esip6,
            protocolName: protocolName,
            operation: operation
        });
    }

    /// @notice Get complete ethscription data (includes content by default)
    /// @param ethscriptionId The ethscription ID to look up
    /// @return The complete ethscription data with content
    function getEthscription(bytes32 ethscriptionId) external view returns (Ethscription memory) {
        return _buildEthscription(ethscriptionId, true);
    }

    /// @notice Get complete ethscription data with option to exclude content
    /// @param ethscriptionId The ethscription ID to look up
    /// @param includeContent Whether to include content (false for gas efficiency)
    /// @return The complete ethscription data
    function getEthscription(bytes32 ethscriptionId, bool includeContent) external view returns (Ethscription memory) {
        return _buildEthscription(ethscriptionId, includeContent);
    }

    /// @notice Get complete ethscription data by tokenId (includes content by default)
    /// @param tokenId The token ID to look up
    /// @return The complete ethscription data with content
    function getEthscription(uint256 tokenId) external view returns (Ethscription memory) {
        bytes32 ethscriptionId = tokenIdToEthscriptionId[tokenId];
        // _buildEthscription calls _getEthscriptionOrRevert which handles existence check
        return _buildEthscription(ethscriptionId, true);
    }

    /// @notice Get complete ethscription data by tokenId with option to exclude content
    /// @param tokenId The token ID to look up
    /// @param includeContent Whether to include content (false for gas efficiency)
    /// @return The complete ethscription data
    function getEthscription(uint256 tokenId, bool includeContent) external view returns (Ethscription memory) {
        bytes32 ethscriptionId = tokenIdToEthscriptionId[tokenId];
        // _buildEthscription calls _getEthscriptionOrRevert which handles existence check
        return _buildEthscription(ethscriptionId, includeContent);
    }

    /// @notice Paginate all ethscriptions by global tokenId range
    /// @param start Starting tokenId (inclusive)
    /// @param limit Maximum number of items to return (clamped by includeContent)
    /// @param includeContent Whether to include content bytes in the returned structs
    /// @return page Paginated result containing items and metadata
    function getEthscriptions(uint256 start, uint256 limit, bool includeContent)
        external
        view
        returns (PaginatedEthscriptionsResponse memory page)
    {
        return _createPaginatedEthscriptionsResponse({
            byOwner: false,
            owner: address(0),
            start: start,
            limit: limit,
            includeContent: includeContent
        });
    }

    /// @notice Overload with includeContent defaulting to true
    function getEthscriptions(uint256 start, uint256 limit)
        external
        view
        returns (PaginatedEthscriptionsResponse memory)
    {
        return _createPaginatedEthscriptionsResponse({
            byOwner: false,
            owner: address(0),
            start: start,
            limit: limit,
            includeContent: true
        });
    }

    /// @notice Paginate ethscriptions owned by a specific address
    /// @param owner The owner address to filter by
    /// @param start Start index within the owner's token set (inclusive)
    /// @param limit Maximum number of items to return (clamped by includeContent)
    /// @param includeContent Whether to include content bytes in the returned structs
    /// @return page Paginated result containing items and metadata
    function getOwnerEthscriptions(address owner, uint256 start, uint256 limit, bool includeContent)
        external
        view
        returns (PaginatedEthscriptionsResponse memory page)
    {
        return _createPaginatedEthscriptionsResponse({
            byOwner: true,
            owner: owner,
            start: start,
            limit: limit,
            includeContent: includeContent
        });
    }

    /// @notice Overload with includeContent defaulting to true
    function getOwnerEthscriptions(address owner, uint256 start, uint256 limit)
        external
        view
        returns (PaginatedEthscriptionsResponse memory)
    {
        return _createPaginatedEthscriptionsResponse({
            byOwner: true,
            owner: owner,
            start: start,
            limit: limit,
            includeContent: true
        });
    }

    /// @notice Internal generic paginator shared by global and owner-scoped pagination
    function _createPaginatedEthscriptionsResponse(
        bool byOwner,
        address owner,
        uint256 start,
        uint256 limit,
        bool includeContent
    ) internal view returns (PaginatedEthscriptionsResponse memory page) {
        if (limit == 0) {
            revert InvalidPaginationLimit();
        }

        uint256 totalCount = byOwner ? balanceOf(owner) : totalSupply();
        page.total = totalCount;
        page.start = start;

        uint256 maxPerPage = includeContent ? MAX_PAGE_WITH_CONTENT : MAX_PAGE_WITHOUT_CONTENT;
        uint256 effectiveLimit = limit > maxPerPage ? maxPerPage : limit;

        uint256 endExclusive = start >= totalCount ? start : start + effectiveLimit;
        if (endExclusive > totalCount) {
            endExclusive = totalCount;
        }
        uint256 resultsCount = start >= totalCount ? 0 : (endExclusive - start);

        Ethscription[] memory items = new Ethscription[](resultsCount);
        for (uint256 index = 0; index < resultsCount;) {
            uint256 tokenId = byOwner ? tokenOfOwnerByIndex(owner, start + index) : (start + index);
            bytes32 id = tokenIdToEthscriptionId[tokenId];
            items[index] = _buildEthscription(id, includeContent);
            unchecked {
                ++index;
            }
        }

        page.items = items;
        // `limit` reflects the effective (clamped) page size requested,
        // while the actual number of returned items is `items.length`.
        page.limit = effectiveLimit;
        page.nextStart = start + resultsCount;
        page.hasMore = page.nextStart < totalCount;
    }

    // -------------------- Internal helper for content retrieval --------------------

    /// @notice Internal: Get content for an ethscription
    /// @dev Kept as internal for tokenURI and other internal uses
    function _getEthscriptionContent(bytes32 ethscriptionId) internal view returns (bytes memory) {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);
        // Use shared retrieval logic
        return DedupedBlobStore.readByHash(ethscription.contentHash, contentStorage);
    }

    // ---------------- Ownership & Existence Checks ----------------

    /// @notice Check if an ethscription exists
    /// @param ethscriptionId The ethscription ID to check
    /// @return true if the ethscription exists
    function exists(bytes32 ethscriptionId) external view returns (bool) {
        return _ethscriptionExists(ethscriptionId);
    }

    function exists(uint256 tokenId) external view returns (bool) {
        return _ethscriptionExists(tokenIdToEthscriptionId[tokenId]);
    }

    /// @notice Get owner of an ethscription by transaction hash
    /// @dev Overload of ownerOf that accepts transaction hash instead of token ID
    function ownerOf(bytes32 ethscriptionId) external view returns (address) {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);
        uint256 tokenId = ethscription.ethscriptionNumber;

        return ownerOf(tokenId);
    }

    /// @notice Get the token ID (ethscription number) for a given transaction hash
    /// @param ethscriptionId The ethscription ID to look up
    /// @return The token ID (ethscription number)
    function getTokenId(bytes32 ethscriptionId) external view returns (uint256) {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);
        return ethscription.ethscriptionNumber;
    }

    /// @notice Get the ethscription ID (bytes32) for a given tokenId
    /// @dev Reverts if tokenId does not exist
    function getEthscriptionId(uint256 tokenId) external view returns (bytes32) {
        bytes32 id = tokenIdToEthscriptionId[tokenId];
        if (!_ethscriptionExists(id)) {
            revert TokenDoesNotExist();
        }
        return id;
    }

    // -------------------- Metadata Helpers --------------------

    /// @notice Get the MIME type of an ethscription
    /// @param ethscriptionId The ethscription ID to query
    /// @return mimetype The MIME type string
    function getMimetype(bytes32 ethscriptionId) external view returns (string memory) {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);
        return MetaStoreLib.getMimetype(ethscription.metaRef);
    }

    /// @notice Get the protocol information for an ethscription
    /// @param ethscriptionId The ethscription ID to query
    /// @return protocolName The protocol identifier (empty if none)
    /// @return operation The operation name (empty if none)
    function getProtocol(bytes32 ethscriptionId)
        external
        view
        returns (string memory protocolName, string memory operation)
    {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);
        return MetaStoreLib.getProtocol(ethscription.metaRef);
    }

    /// @notice Get complete metadata for an ethscription
    /// @param ethscriptionId The ethscription ID to query
    /// @return mimetype The MIME type
    /// @return protocolName The protocol identifier (empty if none)
    /// @return operation The operation name (empty if none)
    function getMetadata(bytes32 ethscriptionId)
        external
        view
        returns (string memory mimetype, string memory protocolName, string memory operation)
    {
        EthscriptionStorage storage ethscription = _getEthscriptionOrRevert(ethscriptionId);
        return MetaStoreLib.decode(ethscription.metaRef);
    }

    // =============================================================
    //                   INTERNAL FUNCTIONS
    // =============================================================

    /// @dev Override _update to track previous owner and handle token transfers
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address from) {
        // Find the ethscription ID for this token ID (ethscription number)
        bytes32 id = tokenIdToEthscriptionId[tokenId];
        EthscriptionStorage storage ethscription = ethscriptions[id];

        // Call parent implementation first to handle the actual update
        from = super._update(to, tokenId, auth);

        if (from == address(0)) {
            // Mint: emit once when minted directly to initial owner
            if (to == ethscription.initialOwner) {
                emit EthscriptionTransferred(id, ethscription.creator, to, tokenId);
            }
            // no previousOwner update or tokenManager call on mint
        } else {
            // Transfers (including creator -> address(0))
            emit EthscriptionTransferred(id, from, to, tokenId);
            ethscription.previousOwner = from;

            // Notify protocol handler about the transfer if this ethscription has a protocol
            _notifyProtocolTransfer(id, from, to);
        }

        // Queue ethscription for batch proving at block boundary once proving is live
        _queueForProving(id);
    }

    /// @notice Check if an ethscription exists
    /// @dev An ethscription exists if it has been created (has a creator set)
    /// @param ethscriptionId The ethscription ID to check
    /// @return True if the ethscription exists
    function _ethscriptionExists(bytes32 ethscriptionId) internal view returns (bool) {
        // Check if this ethscription has been created
        // We can't use _tokenExists here because we need the tokenId first
        // Instead, check if creator is set (ethscriptions are never created with zero creator)
        return ethscriptions[ethscriptionId].creator != address(0);
    }

    /// @notice Internal helper to store content and return its hash
    /// @param content The raw content bytes to store
    /// @return contentHash The keccak256 hash of the content
    function _storeContent(bytes calldata content) internal returns (bytes32 contentHash) {
        // Use shared deduplication logic with keccak256
        (contentHash,) = DedupedBlobStore.storeCalldata(content, contentStorage);
        return contentHash;
    }

    function _queueForProving(bytes32 ethscriptionId) internal {
        if (block.timestamp >= Constants.historicalBackfillApproxDoneAt) {
            prover.queueEthscription(ethscriptionId);
        }
    }

    /// @notice Call a protocol handler operation during ethscription creation
    /// @param ethscriptionId The ethscription ID (L1 tx hash)
    /// @param protocolParams The protocol parameters struct
    function _callProtocolOperation(bytes32 ethscriptionId, ProtocolParams calldata protocolParams) internal {
        // Skip if no protocol specified
        if (bytes(protocolParams.protocolName).length == 0) {
            return;
        }

        address handler = protocolHandlers[protocolParams.protocolName];

        // Skip if no handler is registered
        if (handler == address(0)) {
            return;
        }

        // Encode the function call with operation name
        bytes memory callData = abi.encodeWithSignature(
            string.concat("op_", protocolParams.operation, "(bytes32,bytes)"), ethscriptionId, protocolParams.data
        );

        // Call the handler - failures don't revert ethscription creation
        (bool success, bytes memory returnData) = handler.call(callData);

        if (!success) {
            emit ProtocolHandlerFailed(ethscriptionId, protocolParams.protocolName, returnData);
        } else {
            emit ProtocolHandlerSuccess(ethscriptionId, protocolParams.protocolName, returnData);
        }
    }

    /// @notice Notify protocol handler about an ethscription transfer
    /// @param ethscriptionId The ethscription ID (L1 tx hash)
    /// @param from The address transferring from
    /// @param to The address transferring to
    function _notifyProtocolTransfer(bytes32 ethscriptionId, address from, address to) internal {
        // Get protocol from metadata
        EthscriptionStorage storage etsc = ethscriptions[ethscriptionId];
        (string memory protocolName,) = MetaStoreLib.getProtocol(etsc.metaRef);

        // Skip if no protocol assigned
        if (bytes(protocolName).length == 0) {
            return;
        }

        // Protocol names are stored normalized (lowercase)
        address handler = protocolHandlers[protocolName];

        // Skip if no handler is registered
        if (handler == address(0)) {
            return;
        }

        // Use try/catch for cleaner error handling
        try IProtocolHandler(handler).onTransfer(ethscriptionId, from, to) {
            // onTransfer doesn't return data, so pass empty bytes
            emit ProtocolHandlerSuccess(ethscriptionId, protocolName, "");
        } catch (bytes memory revertData) {
            emit ProtocolHandlerFailed(ethscriptionId, protocolName, revertData);
        }
    }

    // =============================================================
    //                    PRIVATE FUNCTIONS
    // =============================================================

    /// @notice Emit all pending genesis events
    /// @dev Emits events in chronological order then clears the array
    function _emitPendingGenesisEvents() private {
        // Store the length before we start popping
        uint256 count = pendingGenesisEvents.length;

        // Emit events in the order they were created (FIFO)
        for (uint256 i = 0; i < count; i++) {
            bytes32 ethscriptionId = pendingGenesisEvents[i];

            // Get the ethscription data
            EthscriptionStorage storage ethscription = ethscriptions[ethscriptionId];
            uint256 tokenId = ethscription.ethscriptionNumber;

            // Emit events in the same order as live mints:
            // 1. Transfer (mint), 2. EthscriptionTransferred, 3. EthscriptionCreated

            if (ethscription.initialOwner == address(0)) {
                // Token was minted to creator then burned
                // First emit mint to creator
                emit Transfer(address(0), ethscription.creator, tokenId);
                // Then emit burn from creator to null address
                emit Transfer(ethscription.creator, address(0), tokenId);
                // Emit Ethscriptions transfer event for the burn
                emit EthscriptionTransferred(
                    ethscriptionId, ethscription.creator, address(0), ethscription.ethscriptionNumber
                );
            } else {
                // Token was minted directly to initial owner
                emit Transfer(address(0), ethscription.initialOwner, tokenId);
                // Emit Ethscriptions transfer event
                emit EthscriptionTransferred(
                    ethscriptionId, ethscription.creator, ethscription.initialOwner, ethscription.ethscriptionNumber
                );
            }

            // Finally emit the creation event (matching the order of live mints)
            emit EthscriptionCreated(
                ethscriptionId,
                ethscription.creator,
                ethscription.initialOwner,
                ethscription.contentUriSha,
                ethscription.contentHash,
                ethscription.ethscriptionNumber
            );
        }

        // Pop the array until it's empty
        while (pendingGenesisEvents.length > 0) {
            pendingGenesisEvents.pop();
        }
    }
}
