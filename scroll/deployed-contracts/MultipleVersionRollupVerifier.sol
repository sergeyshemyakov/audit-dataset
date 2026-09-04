// SPDX-License-Identifier: Unknown
pragma solidity 0.8.24;

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

interface IZkEvmVerifierV1 {
    /// @notice Verify aggregate zk proof.
    /// @param aggrProof The aggregated proof.
    /// @param publicInputHash The public input hash.
    function verify(bytes calldata aggrProof, bytes32 publicInputHash) external view;
}

interface IZkEvmVerifierV2 {
    /// @notice Verify bundle zk proof.
    /// @param bundleProof The bundle recursion proof.
    /// @param publicInput The public input.
    function verify(bytes calldata bundleProof, bytes calldata publicInput) external view;
}

/// @title MultipleVersionRollupVerifier
/// @notice Verifies aggregate zk proofs using the appropriate verifier.
contract MultipleVersionRollupVerifier is IRollupVerifier, Ownable {
    /**********
     * Events *
     **********/

    /// @notice Emitted when the address of verifier is updated.
    /// @param version The version of the verifier.
    /// @param startBatchIndex The start batch index when the verifier will be used.
    /// @param verifier The address of new verifier.
    event UpdateVerifier(uint256 version, uint256 startBatchIndex, address verifier);

    /**********
     * Errors *
     **********/

    /// @dev Thrown when the given address is `address(0)`.
    error ErrorZeroAddress();

    /// @dev Thrown when the given start batch index is smaller than `latestVerifier.startBatchIndex`.
    error ErrorStartBatchIndexTooSmall();

    /***********
     * Structs *
     ***********/

    struct Verifier {
        // The start batch index for the verifier.
        uint64 startBatchIndex;
        // The address of zkevm verifier.
        address verifier;
    }

    /*************
     * Variables *
     *************/

    /// @notice Mapping from verifier version to the list of legacy zkevm verifiers.
    /// The verifiers are sorted by batchIndex in increasing order.
    mapping(uint256 => Verifier[]) public legacyVerifiers;

    /// @notice Mapping from verifier version to the latest used zkevm verifier.
    mapping(uint256 => Verifier) public latestVerifier;

    /***************
     * Constructor *
     ***************/

    constructor(uint256[] memory _versions, address[] memory _verifiers) {
        for (uint256 i = 0; i < _versions.length; i++) {
            if (_verifiers[i] == address(0)) revert ErrorZeroAddress();
            latestVerifier[_versions[i]].verifier = _verifiers[i];

            emit UpdateVerifier(_versions[i], 0, _verifiers[i]);
        }
    }

    /*************************
     * Public View Functions *
     *************************/

    /// @notice Return the number of legacy verifiers.
    /// @param _version The version of legacy verifiers.
    /// @return The number of legacy verifiers.
    function legacyVerifiersLength(uint256 _version) external view returns (uint256) {
        return legacyVerifiers[_version].length;
    }

    /// @notice Compute the verifier should be used for specific batch.
    /// @param _version The version of verifier to query.
    /// @param _batchIndex The batch index to query.
    /// @return The address of verifier.
    function getVerifier(uint256 _version, uint256 _batchIndex) public view returns (address) {
        // Normally, we will use the latest verifier.
        Verifier memory _verifier = latestVerifier[_version];

        if (_verifier.startBatchIndex > _batchIndex) {
            uint256 _length = legacyVerifiers[_version].length;
            // In most case, only last few verifier will be used by `ScrollChain`.
            // So, we use linear search instead of binary search.
            unchecked {
                for (uint256 i = _length; i > 0; --i) {
                    _verifier = legacyVerifiers[_version][i - 1];
                    if (_verifier.startBatchIndex <= _batchIndex) break;
                }
            }
        }

        return _verifier.verifier;
    }

    /*****************************
     * Public Mutating Functions *
     *****************************/

    /// @inheritdoc IRollupVerifier
    function verifyAggregateProof(
        uint256 _batchIndex,
        bytes calldata _aggrProof,
        bytes32 _publicInputHash
    ) external view override {
        address _verifier = getVerifier(0, _batchIndex);

        IZkEvmVerifierV1(_verifier).verify(_aggrProof, _publicInputHash);
    }

    /// @inheritdoc IRollupVerifier
    function verifyAggregateProof(
        uint256 _version,
        uint256 _batchIndex,
        bytes calldata _aggrProof,
        bytes32 _publicInputHash
    ) external view override {
        address _verifier = getVerifier(_version, _batchIndex);

        IZkEvmVerifierV1(_verifier).verify(_aggrProof, _publicInputHash);
    }

    /// @inheritdoc IRollupVerifier
    function verifyBundleProof(
        uint256 _version,
        uint256 _batchIndex,
        bytes calldata _bundleProof,
        bytes calldata _publicInput
    ) external view override {
        address _verifier = getVerifier(_version, _batchIndex);

        IZkEvmVerifierV2(_verifier).verify(_bundleProof, _publicInput);
    }

    /************************
     * Restricted Functions *
     ************************/

    /// @notice Update the address of zkevm verifier.
    /// @param _version The version of the verifier.
    /// @param _startBatchIndex The start batch index when the verifier will be used.
    /// @param _verifier The address of new verifier.
    function updateVerifier(
        uint256 _version,
        uint64 _startBatchIndex,
        address _verifier
    ) external onlyOwner {
        // We are using version to decide the verifier to use and also this function is
        // controlled by 7 days TimeLock. It is hard to predict `lastFinalizedBatchIndex` after 7 days.
        // So we decide to remove this check to make verifier updating more easier.
        // if (_startBatchIndex <= IScrollChain(scrollChain).lastFinalizedBatchIndex())
        //    revert ErrorStartBatchIndexFinalized();

        Verifier memory _latestVerifier = latestVerifier[_version];
        if (_startBatchIndex < _latestVerifier.startBatchIndex) revert ErrorStartBatchIndexTooSmall();
        if (_verifier == address(0)) revert ErrorZeroAddress();

        if (_latestVerifier.startBatchIndex < _startBatchIndex) {
            // don't push when it is the first update of the version.
            if (_latestVerifier.verifier != address(0)) {
                legacyVerifiers[_version].push(_latestVerifier);
            }
            _latestVerifier.startBatchIndex = _startBatchIndex;
        }
        _latestVerifier.verifier = _verifier;

        latestVerifier[_version] = _latestVerifier;

        emit UpdateVerifier(_version, _startBatchIndex, _verifier);
    }
}