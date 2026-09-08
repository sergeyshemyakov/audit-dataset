// SPDX-License-Identifier: Unknown
pragma solidity 0.8.15;

enum GameStatus {
    // The game is currently in progress, and has not been resolved.
    IN_PROGRESS,
    // The game has concluded, and the `rootClaim` was challenged successfully.
    CHALLENGER_WINS,
    // The game has concluded, and the `rootClaim` could not be contested.
    DEFENDER_WINS
}

type Claim is bytes32;

type GameType is uint32;

type Hash is bytes32;

struct Proposal {
    Hash root;
    uint256 l2SequenceNumber;
}

interface ISemver {
    /// @notice Getter for the semantic version of the contract. This is not
    ///         meant to be used onchain but instead meant to be used by offchain
    ///         tooling.
    /// @return Semver contract version as a string.
    function version() external view returns (string memory);
}

abstract contract ReinitializableBase {
    /// @notice Thrown when the initialization version is zero.
    error ReinitializableBase_ZeroInitVersion();

    /// @notice Current initialization version.
    uint8 internal immutable INIT_VERSION;

    /// @param _initVersion Current initialization version.
    constructor(uint8 _initVersion) {
        // Sanity check, we should never have a zero init version.
        if (_initVersion == 0) {
            revert ReinitializableBase_ZeroInitVersion();
        }
        INIT_VERSION = _initVersion;
    }

    /// @notice Getter for the current initialization version.
    /// @return The current initialization version.
    function initVersion() public view returns (uint8) {
        return INIT_VERSION;
    }
}

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

library Storage {
    /// @notice Returns an address stored in an arbitrary storage slot.
    ///         These storage slots decouple the storage layout from
    ///         solc's automation.
    /// @param _slot The storage slot to retrieve the address from.
    function getAddress(bytes32 _slot) internal view returns (address addr_) {
        assembly {
            addr_ := sload(_slot)
        }
    }

    /// @notice Stores an address in an arbitrary storage slot, `_slot`.
    /// @param _slot The storage slot to store the address in.
    /// @param _address The protocol version to store
    /// @dev WARNING! This function must be used cautiously, as it allows for overwriting addresses
    ///      in arbitrary storage slots.
    function setAddress(bytes32 _slot, address _address) internal {
        assembly {
            sstore(_slot, _address)
        }
    }

    /// @notice Returns a uint256 stored in an arbitrary storage slot.
    ///         These storage slots decouple the storage layout from
    ///         solc's automation.
    /// @param _slot The storage slot to retrieve the address from.
    function getUint(bytes32 _slot) internal view returns (uint256 value_) {
        assembly {
            value_ := sload(_slot)
        }
    }

    /// @notice Stores a value in an arbitrary storage slot, `_slot`.
    /// @param _slot The storage slot to store the address in.
    /// @param _value The protocol version to store
    /// @dev WARNING! This function must be used cautiously, as it allows for overwriting values
    ///      in arbitrary storage slots.
    function setUint(bytes32 _slot, uint256 _value) internal {
        assembly {
            sstore(_slot, _value)
        }
    }

    /// @notice Returns a bytes32 stored in an arbitrary storage slot.
    ///         These storage slots decouple the storage layout from
    ///         solc's automation.
    /// @param _slot The storage slot to retrieve the address from.
    function getBytes32(bytes32 _slot) internal view returns (bytes32 value_) {
        assembly {
            value_ := sload(_slot)
        }
    }

    /// @notice Stores a bytes32 value in an arbitrary storage slot, `_slot`.
    /// @param _slot The storage slot to store the address in.
    /// @param _value The bytes32 value to store.
    /// @dev WARNING! This function must be used cautiously, as it allows for overwriting values
    ///      in arbitrary storage slots.
    function setBytes32(bytes32 _slot, bytes32 _value) internal {
        assembly {
            sstore(_slot, _value)
        }
    }

    /// @notice Stores a bool value in an arbitrary storage slot, `_slot`.
    /// @param _slot The storage slot to store the bool in.
    /// @param _value The bool value to store
    /// @dev WARNING! This function must be used cautiously, as it allows for overwriting values
    ///      in arbitrary storage slots.
    function setBool(bytes32 _slot, bool _value) internal {
        assembly {
            sstore(_slot, _value)
        }
    }

    /// @notice Returns a bool stored in an arbitrary storage slot.
    /// @param _slot The storage slot to retrieve the bool from.
    function getBool(bytes32 _slot) internal view returns (bool value_) {
        assembly {
            value_ := sload(_slot)
        }
    }
}

library Constants {
    /// @notice Special address to be used as the tx origin for gas estimation calls in the
    ///         OptimismPortal and CrossDomainMessenger calls. You only need to use this address if
    ///         the minimum gas limit specified by the user is not actually enough to execute the
    ///         given message and you're attempting to estimate the actual necessary gas limit. We
    ///         use address(1) because it's the ecrecover precompile and therefore guaranteed to
    ///         never have any code on any EVM chain.
    address internal constant ESTIMATION_ADDRESS = address(1);

    /// @notice Value used for the L2 sender storage slot in both the OptimismPortal and the
    ///         CrossDomainMessenger contracts before an actual sender is set. This value is
    ///         non-zero to reduce the gas cost of message passing transactions.
    address internal constant DEFAULT_L2_SENDER = 0x000000000000000000000000000000000000dEaD;

    /// @notice The storage slot that holds the address of a proxy implementation.
    /// @dev `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`
    bytes32 internal constant PROXY_IMPLEMENTATION_ADDRESS =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice The storage slot that holds the address of the owner.
    /// @dev `bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)`
    bytes32 internal constant PROXY_OWNER_ADDRESS = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /// @notice The address that represents ether when dealing with ERC20 token addresses.
    address internal constant ETHER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice The address that represents the system caller responsible for L1 attributes
    ///         transactions.
    address internal constant DEPOSITOR_ACCOUNT = 0xDeaDDEaDDeAdDeAdDEAdDEaddeAddEAdDEAd0001;

    /// @notice Returns the default values for the ResourceConfig. These are the recommended values
    ///         for a production network.
    function DEFAULT_RESOURCE_CONFIG() internal pure returns (IResourceMetering.ResourceConfig memory) {
        IResourceMetering.ResourceConfig memory config = IResourceMetering.ResourceConfig({
            maxResourceLimit: 20_000_000,
            elasticityMultiplier: 10,
            baseFeeMaxChangeDenominator: 8,
            minimumBaseFee: 1 gwei,
            systemTxMaxGas: 1_000_000,
            maximumBaseFee: type(uint128).max
        });
        return config;
    }
}

abstract contract ProxyAdminOwnedBase {
    /// @notice Thrown when the ProxyAdmin owner of the current contract is not the same as the
    ///         ProxyAdmin owner of the other Proxy address provided.
    error ProxyAdminOwnedBase_NotSharedProxyAdminOwner();

    /// @notice Thrown when the caller is not the ProxyAdmin owner.
    error ProxyAdminOwnedBase_NotProxyAdminOwner();

    /// @notice Thrown when the caller is not the ProxyAdmin.
    error ProxyAdminOwnedBase_NotProxyAdmin();

    /// @notice Thrown when the caller is not the ProxyAdmin owner or the ProxyAdmin.
    error ProxyAdminOwnedBase_NotProxyAdminOrProxyAdminOwner();

    /// @notice Thrown when the ProxyAdmin owner of the current contract is not found.
    error ProxyAdminOwnedBase_ProxyAdminNotFound();

    /// @notice Thrown when the current contract is not a ResolvedDelegateProxy.
    error ProxyAdminOwnedBase_NotResolvedDelegateProxy();

    /// @notice Getter for the owner of the ProxyAdmin.
    function proxyAdminOwner() public view returns (address) {
        return proxyAdmin().owner();
    }

    /// @notice Getter for the ProxyAdmin contract that owns this Proxy contract.
    function proxyAdmin() public view returns (IProxyAdmin) {
        // First check for a non-zero address in the reserved slot.
        address proxyAdminAddress = Storage.getAddress(Constants.PROXY_OWNER_ADDRESS);
        if (proxyAdminAddress != address(0)) {
            return IProxyAdmin(proxyAdminAddress);
        }

        // Otherwise, we'll try to read the AddressManager slot.
        // First we make sure this is almost certainly a ResolvedDelegateProxy. We only have a
        // single ResolvedDelegateProxy and it's for the L1CrossDomainMessenger, so we'll check
        // that the storage slot for the mapping at slot 0 returns the string
        // "OVM_L1CrossDomainMessenger". We need to use Solidity's rules for how strings are stored
        // in storage slots to do this.
        if (
            Storage.getBytes32(keccak256(abi.encode(address(this), uint256(0))))
                != bytes32(
                    uint256(bytes32("OVM_L1CrossDomainMessenger")) | uint256(bytes("OVM_L1CrossDomainMessenger").length * 2)
                )
        ) {
            revert ProxyAdminOwnedBase_NotResolvedDelegateProxy();
        }

        // Ok, now we'll try to read the AddressManager slot.
        address addressManagerAddress = Storage.getAddress(keccak256(abi.encode(address(this), uint256(1))));
        if (addressManagerAddress != address(0)) {
            return IProxyAdmin(IAddressManager(addressManagerAddress).owner());
        }

        // We should revert here, we couldn't find a non-zero owner address.
        revert ProxyAdminOwnedBase_ProxyAdminNotFound();
    }

    /// @notice Reverts if the ProxyAdmin owner of the current contract is not the same as the
    ///         ProxyAdmin owner of the other Proxy address provided. Useful asserting that both
    ///         the current contract and the other Proxy share the same security model.+
    function _assertSharedProxyAdminOwner(address _proxy) internal view {
        if (proxyAdminOwner() != ProxyAdminOwnedBase(_proxy).proxyAdminOwner()) {
            revert ProxyAdminOwnedBase_NotSharedProxyAdminOwner();
        }
    }

    /// @notice Reverts if the caller is not the ProxyAdmin owner.
    function _assertOnlyProxyAdminOwner() internal view {
        if (proxyAdminOwner() != msg.sender) {
            revert ProxyAdminOwnedBase_NotProxyAdminOwner();
        }
    }

    /// @notice Reverts if the caller is not the ProxyAdmin.
    function _assertOnlyProxyAdmin() internal view {
        if (address(proxyAdmin()) != msg.sender) {
            revert ProxyAdminOwnedBase_NotProxyAdmin();
        }
    }

    function _assertOnlyProxyAdminOrProxyAdminOwner() internal view {
        if (address(proxyAdmin()) != msg.sender && proxyAdminOwner() != msg.sender) {
            revert ProxyAdminOwnedBase_NotProxyAdminOrProxyAdminOwner();
        }
    }
}

contract AnchorStateRegistry is ProxyAdminOwnedBase, Initializable, ReinitializableBase, ISemver {
    /// @notice Semantic version.
    /// @custom:semver 3.5.0
    string public constant version = "3.5.0";

    /// @notice The dispute game finality delay in seconds.
    uint256 internal immutable DISPUTE_GAME_FINALITY_DELAY_SECONDS;

    /// @notice Address of the SystemConfig contract.
    ISystemConfig public systemConfig;

    /// @notice Address of the DisputeGameFactory contract.
    IDisputeGameFactory public disputeGameFactory;

    /// @notice The game whose claim is currently being used as the anchor state.
    IFaultDisputeGame public anchorGame;

    /// @notice The starting anchor root.
    Proposal internal startingAnchorRoot;

    /// @notice Mapping of blacklisted dispute games.
    mapping(IDisputeGame => bool) public disputeGameBlacklist;

    /// @notice The respected game type.
    GameType public respectedGameType;

    /// @notice The retirement timestamp. All games created before or at this timestamp are
    ///         considered retired and are therefore not valid games. Retirement is used as a
    ///         blanket invalidation mechanism if games resolve incorrectly.
    uint64 public retirementTimestamp;

    /// @notice Emitted when an anchor state is updated.
    /// @param game Game that was used as the new anchor game.
    event AnchorUpdated(IFaultDisputeGame indexed game);

    /// @notice Emitted when the respected game type is set.
    /// @param gameType The new respected game type.
    event RespectedGameTypeSet(GameType gameType);

    /// @notice Emitted when the retirement timestamp is set.
    /// @param timestamp The new retirement timestamp.
    event RetirementTimestampSet(uint256 timestamp);

    /// @notice Emitted when a dispute game is blacklisted.
    /// @param disputeGame The dispute game that was blacklisted.
    event DisputeGameBlacklisted(IDisputeGame indexed disputeGame);

    /// @notice Thrown when an invalid anchor game is provided.
    error AnchorStateRegistry_InvalidAnchorGame();

    /// @notice Thrown when an unauthorized caller attempts to set the anchor state.
    error AnchorStateRegistry_Unauthorized();

    /// @param _disputeGameFinalityDelaySeconds The dispute game finality delay in seconds.
    constructor(uint256 _disputeGameFinalityDelaySeconds) ReinitializableBase(1) {
        DISPUTE_GAME_FINALITY_DELAY_SECONDS = _disputeGameFinalityDelaySeconds;
        _disableInitializers();
    }

    /// @notice Initializes the contract.
    /// @param _systemConfig The address of the SystemConfig contract.
    /// @param _disputeGameFactory The address of the DisputeGameFactory contract.
    /// @param _startingAnchorRoot The starting anchor root.
    function initialize(
        ISystemConfig _systemConfig,
        IDisputeGameFactory _disputeGameFactory,
        Proposal memory _startingAnchorRoot,
        GameType _startingRespectedGameType
    ) external reinitializer(initVersion()) {
        // Initialization transactions must come from the ProxyAdmin or its owner.
        _assertOnlyProxyAdminOrProxyAdminOwner();

        // Now perform initialization logic.
        systemConfig = _systemConfig;
        disputeGameFactory = _disputeGameFactory;
        startingAnchorRoot = _startingAnchorRoot;
        respectedGameType = _startingRespectedGameType;
        retirementTimestamp = uint64(block.timestamp);
    }

    /// @notice Returns whether the contract is paused.
    function paused() public view returns (bool) {
        return systemConfig.paused();
    }

    /// @notice Returns the SuperchainConfig contract.
    /// @return ISuperchainConfig The SuperchainConfig contract.
    function superchainConfig() public view returns (ISuperchainConfig) {
        return systemConfig.superchainConfig();
    }

    /// @notice Returns the dispute game finality delay in seconds.
    function disputeGameFinalityDelaySeconds() external view returns (uint256) {
        return DISPUTE_GAME_FINALITY_DELAY_SECONDS;
    }

    /// @notice Allows the Guardian to set the respected game type.
    /// @param _gameType The new respected game type.
    function setRespectedGameType(GameType _gameType) external {
        // Only the Guardian can set the respected game type.
        _assertOnlyGuardian();

        // Set the respected game type.
        respectedGameType = _gameType;
        emit RespectedGameTypeSet(_gameType);
    }

    /// @notice Allows the Guardian to update the retirement timestamp.
    function updateRetirementTimestamp() external {
        // Only the Guardian can update the retirement timestamp.
        _assertOnlyGuardian();

        // Update the retirement timestamp.
        retirementTimestamp = uint64(block.timestamp);
        emit RetirementTimestampSet(block.timestamp);
    }

    /// @notice Allows the Guardian to blacklist a dispute game.
    /// @param _disputeGame Dispute game to blacklist.
    function blacklistDisputeGame(IDisputeGame _disputeGame) external {
        // Only the Guardian can blacklist a dispute game.
        _assertOnlyGuardian();

        // Blacklist the dispute game.
        disputeGameBlacklist[_disputeGame] = true;
        emit DisputeGameBlacklisted(_disputeGame);
    }

    /// @custom:legacy
    /// @notice Returns the anchor root. Note that this is a legacy deprecated function and will
    ///         be removed in a future release. Use getAnchorRoot() instead. Anchor roots are no
    ///         longer stored per game type, so this function will return the same root for all
    ///         game types.
    function anchors(GameType /* unused */ ) external view returns (Hash, uint256) {
        return getAnchorRoot();
    }

    /// @notice Returns the current anchor root.
    /// @return The anchor root.
    function getAnchorRoot() public view returns (Hash, uint256) {
        // Return the starting anchor root if there is no anchor game.
        if (address(anchorGame) == address(0)) {
            return (startingAnchorRoot.root, startingAnchorRoot.l2SequenceNumber);
        }

        // Otherwise, return the anchor root.
        return (Hash.wrap(anchorGame.rootClaim().raw()), anchorGame.l2SequenceNumber());
    }

    /// @notice Determines whether a game is registered by checking that it was created by the
    ///         DisputeGameFactory and that it uses this AnchorStateRegistry.
    /// @param _game The game to check.
    /// @return Whether the game is registered.
    function isGameRegistered(IDisputeGame _game) public view returns (bool) {
        // Grab the game and game data.
        (GameType gameType, Claim rootClaim, bytes memory extraData) = _game.gameData();

        // Grab the verified address of the game based on the game data.
        (IDisputeGame factoryRegisteredGame,) =
            disputeGameFactory.games({_gameType: gameType, _rootClaim: rootClaim, _extraData: extraData});

        // Grab the AnchorStateRegistry from the game. Awkward type conversion here but
        // IDisputeGame probably needs to have this function eventually anyway.
        address asr = address(IFaultDisputeGame(address(_game)).anchorStateRegistry());

        // Return whether the game is factory registered and uses this AnchorStateRegistry. We
        // check for both of these conditions because the game could be using a different
        // AnchorStateRegistry if the registry was updated at some point. We mitigate the risks of
        // an outdated AnchorStateRegistry by invalidating all previous games in the initializer of
        // this contract, but an explicit check avoids potential footguns in the future.
        return address(factoryRegisteredGame) == address(_game) && asr == address(this);
    }

    /// @notice Determines whether a game is of a respected game type.
    /// @param _game The game to check.
    /// @return Whether the game is of a respected game type.
    function isGameRespected(IDisputeGame _game) public view returns (bool) {
        // We don't do a try/catch here for legacy games because by the time this code is live on
        // mainnet, users won't be using legacy games anymore. Avoiding the try/catch simplifies
        // the logic.
        return _game.wasRespectedGameTypeWhenCreated();
    }

    /// @notice Determines whether a game is blacklisted.
    /// @param _game The game to check.
    /// @return Whether the game is blacklisted.
    function isGameBlacklisted(IDisputeGame _game) public view returns (bool) {
        return disputeGameBlacklist[_game];
    }

    /// @notice Determines whether a game is retired.
    /// @param _game The game to check.
    /// @return Whether the game is retired.
    function isGameRetired(IDisputeGame _game) public view returns (bool) {
        // Must be created after the retirementTimestamp. Note that this means all games created in
        // the same block as the retirementTimestamp are considered retired.
        return _game.createdAt().raw() <= retirementTimestamp;
    }

    /// @notice Returns whether a game is resolved.
    /// @param _game The game to check.
    /// @return Whether the game is resolved.
    function isGameResolved(IDisputeGame _game) public view returns (bool) {
        return _game.resolvedAt().raw() != 0
            && (_game.status() == GameStatus.DEFENDER_WINS || _game.status() == GameStatus.CHALLENGER_WINS);
    }

    /// @notice **READ THIS FUNCTION DOCUMENTATION CAREFULLY.**
    ///         Determines whether a game resolved properly and the game was not subject to any
    ///         invalidation conditions. The root claim of a proper game IS NOT guaranteed to be
    ///         valid. The root claim of a proper game CAN BE incorrect and still be a proper game.
    ///         DO NOT USE THIS FUNCTION ALONE TO DETERMINE IF A ROOT CLAIM IS VALID.
    /// @dev Note that isGameProper previously checked that the game type was equal to the
    ///      respected game type. However, it should be noted that it is possible for a game other
    ///      than the respected game type to resolve without being invalidated. Since isGameProper
    ///      exists to determine if a game has (or has not) been invalidated, we now allow any game
    ///      type to be considered a proper game. We enforce checks on the game type in
    ///      isGameClaimValid().
    /// @param _game The game to check.
    /// @return Whether the game is a proper game.
    function isGameProper(IDisputeGame _game) public view returns (bool) {
        // Must be registered in the DisputeGameFactory.
        if (!isGameRegistered(_game)) {
            return false;
        }

        // Must not be blacklisted.
        if (isGameBlacklisted(_game)) {
            return false;
        }

        // Must be created at or after the retirement timestamp.
        if (isGameRetired(_game)) {
            return false;
        }

        // Must not be paused, temporarily causes game to be considered improper.
        if (paused()) {
            return false;
        }

        return true;
    }

    /// @notice Returns whether a game is finalized.
    /// @param _game The game to check.
    /// @return Whether the game is finalized.
    function isGameFinalized(IDisputeGame _game) public view returns (bool) {
        // Game must be resolved.
        if (!isGameResolved(_game)) {
            return false;
        }

        // Game must be beyond the "airgap period" - time since resolution must be at least
        // "dispute game finality delay" seconds in the past.
        if (block.timestamp - _game.resolvedAt().raw() <= DISPUTE_GAME_FINALITY_DELAY_SECONDS) {
            return false;
        }

        return true;
    }

    /// @notice Returns whether a game's root claim is valid.
    /// @param _game The game to check.
    /// @return Whether the game's root claim is valid.
    function isGameClaimValid(IDisputeGame _game) public view returns (bool) {
        // Game must be a proper game.
        if (!isGameProper(_game)) {
            return false;
        }

        // Must be respected.
        if (!isGameRespected(_game)) {
            return false;
        }

        // Game must be finalized.
        if (!isGameFinalized(_game)) {
            return false;
        }

        // Game must be resolved in favor of the defender.
        if (_game.status() != GameStatus.DEFENDER_WINS) {
            return false;
        }

        return true;
    }

    /// @notice Updates the anchor game.
    /// @param _game New candidate anchor game.
    function setAnchorState(IDisputeGame _game) public {
        // Convert game to FaultDisputeGame.
        // We can't use FaultDisputeGame in the interface because this function is called from the
        // FaultDisputeGame contract which can't import IFaultDisputeGame by convention. We should
        // likely introduce a new interface (e.g., StateDisputeGame) that can act as a more useful
        // version of IDisputeGame in the future.
        IFaultDisputeGame game = IFaultDisputeGame(address(_game));

        // Check if the candidate game claim is valid.
        if (!isGameClaimValid(game)) {
            revert AnchorStateRegistry_InvalidAnchorGame();
        }

        // Must be newer than the current anchor game.
        (, uint256 anchorL2BlockNumber) = getAnchorRoot();
        if (game.l2SequenceNumber() <= anchorL2BlockNumber) {
            revert AnchorStateRegistry_InvalidAnchorGame();
        }

        // Update the anchor game.
        anchorGame = game;
        emit AnchorUpdated(game);
    }

    /// @notice Asserts that the caller is the Guardian.
    function _assertOnlyGuardian() internal view {
        if (msg.sender != systemConfig.guardian()) {
            revert AnchorStateRegistry_Unauthorized();
        }
    }
}
