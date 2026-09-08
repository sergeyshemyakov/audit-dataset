// SPDX-License-Identifier: Unknown
pragma solidity 0.8.29;

// NOTE(l2beat): This is an interface, generated from the contract source code.
interface ERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

/// @title Resource Manager Interface
/// @notice The interface for managing the resource token and its threshold value
interface IResourceManager {
    /// @notice Thrown when an unauthorized address attempts to call a restricted function
    error Unauthorized();

    /// @notice The resource token required by parent IReleaser
    function RESOURCE() external view returns (ERC20);

    /// @notice The recipient of the `RESOURCE` tokens
    function RESOURCE_RECIPIENT() external view returns (address);

    /// @notice The minimum threshold of `RESOURCE` tokens required to perform a release
    function threshold() external view returns (uint256);

    /// @notice The address authorized to set the `threshold` value
    function thresholdSetter() external view returns (address);

    /// @notice Set the address authorized to set the `threshold` value
    /// @dev only callable by `owner`
    function setThresholdSetter(address newThresholdSetter) external;

    /// @notice Set the minimum threshold of `RESOURCE` tokens required to perform a release
    /// @dev only callable by `thresholdSetter`
    /// the `thresholdSetter` should take explicit care when updating the threshold
    /// * lowering the threshold may create instantaneous value leakage
    /// * front-running a release with an increased threshold may cause economic loss
    /// to the releaser/searcher
    function setThreshold(uint256 newThreshold) external;
}

/// @title Nonce Interface
interface INonce {
    /// @notice Thrown when a user-provided nonce is not equal to the contract's nonce
    error InvalidNonce();

    /// @return The contract's nonce
    function nonce() external view returns (uint256);
}

function greaterThan(Currency currency, Currency other) pure returns (bool) {
    return Currency.unwrap(currency) > Currency.unwrap(other);
}

function lessThan(Currency currency, Currency other) pure returns (bool) {
    return Currency.unwrap(currency) < Currency.unwrap(other);
}

function greaterThanOrEqualTo(Currency currency, Currency other) pure returns (bool) {
    return Currency.unwrap(currency) >= Currency.unwrap(other);
}

function equals(Currency currency, Currency other) pure returns (bool) {
    return Currency.unwrap(currency) == Currency.unwrap(other);
}

using {greaterThan as >, lessThan as <, greaterThanOrEqualTo as >=, equals as ==} for Currency global;

/// @title Library for reverting with custom errors efficiently
/// @notice Contains functions for reverting with custom errors with different argument types efficiently
/// @dev To use this library, declare `using CustomRevert for bytes4;` and replace `revert CustomError()` with
/// `CustomError.selector.revertWith()`
/// @dev The functions may tamper with the free memory pointer but it is fine since the call context is exited immediately
library CustomRevert {
    /// @dev ERC-7751 error for wrapping bubbled up reverts
    error WrappedError(address target, bytes4 selector, bytes reason, bytes details);

    /// @dev Reverts with the selector of a custom error in the scratch space
    function revertWith(bytes4 selector) internal pure {
        assembly ("memory-safe") {
            mstore(0, selector)
            revert(0, 0x04)
        }
    }

    /// @dev Reverts with a custom error with an address argument in the scratch space
    function revertWith(bytes4 selector, address addr) internal pure {
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, and(addr, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with an int24 argument in the scratch space
    function revertWith(bytes4 selector, int24 value) internal pure {
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, signextend(2, value))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with a uint160 argument in the scratch space
    function revertWith(bytes4 selector, uint160 value) internal pure {
        assembly ("memory-safe") {
            mstore(0, selector)
            mstore(0x04, and(value, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(0, 0x24)
        }
    }

    /// @dev Reverts with a custom error with two int24 arguments
    function revertWith(bytes4 selector, int24 value1, int24 value2) internal pure {
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), signextend(2, value1))
            mstore(add(fmp, 0x24), signextend(2, value2))
            revert(fmp, 0x44)
        }
    }

    /// @dev Reverts with a custom error with two uint160 arguments
    function revertWith(bytes4 selector, uint160 value1, uint160 value2) internal pure {
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), and(value1, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(fmp, 0x24), and(value2, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(fmp, 0x44)
        }
    }

    /// @dev Reverts with a custom error with two address arguments
    function revertWith(bytes4 selector, address value1, address value2) internal pure {
        assembly ("memory-safe") {
            let fmp := mload(0x40)
            mstore(fmp, selector)
            mstore(add(fmp, 0x04), and(value1, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(fmp, 0x24), and(value2, 0xffffffffffffffffffffffffffffffffffffffff))
            revert(fmp, 0x44)
        }
    }

    /// @notice bubble up the revert message returned by a call and revert with a wrapped ERC-7751 error
    /// @dev this method can be vulnerable to revert data bombs
    function bubbleUpAndRevertWith(
        address revertingContract,
        bytes4 revertingFunctionSelector,
        bytes4 additionalContext
    ) internal pure {
        bytes4 wrappedErrorSelector = WrappedError.selector;
        assembly ("memory-safe") {
            // Ensure the size of the revert data is a multiple of 32 bytes
            let encodedDataSize := mul(div(add(returndatasize(), 31), 32), 32)

            let fmp := mload(0x40)

            // Encode wrapped error selector, address, function selector, offset, additional context, size, revert reason
            mstore(fmp, wrappedErrorSelector)
            mstore(add(fmp, 0x04), and(revertingContract, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(
                add(fmp, 0x24),
                and(revertingFunctionSelector, 0xffffffff00000000000000000000000000000000000000000000000000000000)
            )
            // offset revert reason
            mstore(add(fmp, 0x44), 0x80)
            // offset additional context
            mstore(add(fmp, 0x64), add(0xa0, encodedDataSize))
            // size revert reason
            mstore(add(fmp, 0x84), returndatasize())
            // revert reason
            returndatacopy(add(fmp, 0xa4), 0, returndatasize())
            // size additional context
            mstore(add(fmp, add(0xa4, encodedDataSize)), 0x04)
            // additional context
            mstore(
                add(fmp, add(0xc4, encodedDataSize)),
                and(additionalContext, 0xffffffff00000000000000000000000000000000000000000000000000000000)
            )
            revert(fmp, add(0xe4, encodedDataSize))
        }
    }
}

/// @title Minimal ERC20 interface for Uniswap
/// @notice Contains a subset of the full ERC20 interface that is used in Uniswap V3
interface IERC20Minimal {
    /// @notice Returns an account's balance in the token
    /// @param account The account for which to look up the number of tokens it has, i.e. its balance
    /// @return The number of tokens held by the account
    function balanceOf(address account) external view returns (uint256);

    /// @notice Transfers the amount of token from the `msg.sender` to the recipient
    /// @param recipient The account that will receive the amount transferred
    /// @param amount The number of tokens to send from the sender to the recipient
    /// @return Returns true for a successful transfer, false for an unsuccessful transfer
    function transfer(address recipient, uint256 amount) external returns (bool);

    /// @notice Returns the current allowance given to a spender by an owner
    /// @param owner The account of the token owner
    /// @param spender The account of the token spender
    /// @return The current allowance granted by `owner` to `spender`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets the allowance of a spender from the `msg.sender` to the value `amount`
    /// @param spender The account which will be allowed to spend a given amount of the owners tokens
    /// @param amount The amount of tokens allowed to be used by `spender`
    /// @return Returns true for a successful approval, false for unsuccessful
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Transfers `amount` tokens from `sender` to `recipient` up to the allowance given to the `msg.sender`
    /// @param sender The account from which the transfer will be initiated
    /// @param recipient The recipient of the transfer
    /// @param amount The amount of the transfer
    /// @return Returns true for a successful transfer, false for unsuccessful
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /// @notice Event emitted when tokens are transferred from one address to another, either via `#transfer` or `#transferFrom`.
    /// @param from The account from which the tokens were sent, i.e. the balance decreased
    /// @param to The account to which the tokens were sent, i.e. the balance increased
    /// @param value The amount of tokens that were transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Event emitted when the approval amount for the spender of a given owner's tokens changes.
    /// @param owner The account that approved spending of its tokens
    /// @param spender The account for which the spending allowance was modified
    /// @param value The new allowance from the owner to the spender
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// @title CurrencyLibrary
/// @dev This library allows for transferring and holding native tokens and ERC20 tokens
library CurrencyLibrary {
    /// @notice Additional context for ERC-7751 wrapped error when a native transfer fails
    error NativeTransferFailed();

    /// @notice Additional context for ERC-7751 wrapped error when an ERC20 transfer fails
    error ERC20TransferFailed();

    /// @notice A constant to represent the native currency
    Currency public constant ADDRESS_ZERO = Currency.wrap(address(0));

    function transfer(Currency currency, address to, uint256 amount) internal {
        // altered from https://github.com/transmissions11/solmate/blob/44a9963d4c78111f77caa0e65d677b8b46d6f2e6/src/utils/SafeTransferLib.sol
        // modified custom error selectors

        bool success;
        if (currency.isAddressZero()) {
            assembly ("memory-safe") {
                // Transfer the ETH and revert if it fails.
                success := call(gas(), to, amount, 0, 0, 0, 0)
            }
            // revert with NativeTransferFailed, containing the bubbled up error as an argument
            if (!success) {
                CustomRevert.bubbleUpAndRevertWith(to, bytes4(0), NativeTransferFailed.selector);
            }
        } else {
            assembly ("memory-safe") {
                // Get a pointer to some free memory.
                let fmp := mload(0x40)

                // Write the abi-encoded calldata into memory, beginning with the function selector.
                mstore(fmp, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                mstore(add(fmp, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
                mstore(add(fmp, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

                success :=
                    and(
                        // Set success to whether the call reverted, if not we check it either
                        // returned exactly 1 (can't just be non-zero data), or had no return data.
                        or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                        // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                        // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                        // Counterintuitively, this call must be positioned second to the or() call in the
                        // surrounding and() call or else returndatasize() will be zero during the computation.
                        call(gas(), currency, 0, fmp, 68, 0, 32)
                    )

                // Now clean the memory we used
                mstore(fmp, 0) // 4 byte `selector` and 28 bytes of `to` were stored here
                mstore(add(fmp, 0x20), 0) // 4 bytes of `to` and 28 bytes of `amount` were stored here
                mstore(add(fmp, 0x40), 0) // 4 bytes of `amount` were stored here
            }
            // revert with ERC20TransferFailed, containing the bubbled up error as an argument
            if (!success) {
                CustomRevert.bubbleUpAndRevertWith(
                    Currency.unwrap(currency), IERC20Minimal.transfer.selector, ERC20TransferFailed.selector
                );
            }
        }
    }

    function balanceOfSelf(Currency currency) internal view returns (uint256) {
        if (currency.isAddressZero()) {
            return address(this).balance;
        } else {
            return IERC20Minimal(Currency.unwrap(currency)).balanceOf(address(this));
        }
    }

    function balanceOf(Currency currency, address owner) internal view returns (uint256) {
        if (currency.isAddressZero()) {
            return owner.balance;
        } else {
            return IERC20Minimal(Currency.unwrap(currency)).balanceOf(owner);
        }
    }

    function isAddressZero(Currency currency) internal pure returns (bool) {
        return Currency.unwrap(currency) == Currency.unwrap(ADDRESS_ZERO);
    }

    function toId(Currency currency) internal pure returns (uint256) {
        return uint160(Currency.unwrap(currency));
    }

    // If the upper 12 bytes are non-zero, they will be zero-ed out
    // Therefore, fromId() and toId() are not inverses of each other
    function fromId(uint256 id) internal pure returns (Currency) {
        return Currency.wrap(address(uint160(id)));
    }
}

using CurrencyLibrary for Currency global;

type Currency is address;

/// @title Token Jar Interface
/// @notice The interface for releasing assets from the contract
interface ITokenJar {
    /// @notice Thrown when an unauthorized address attempts to call a restricted function
    error Unauthorized();

    /// @return Address of the current IReleaser
    /// @dev The releaser has exclusive access to the `release()` function
    function releaser() external view returns (address);

    /// @notice Set the address of the IReleaser contract
    /// @dev only callabe by `owner`
    function setReleaser(address _releaser) external;

    /// @notice Release assets to a specified recipient
    /// @dev only callable by `releaser`
    function release(Currency[] calldata assets, address recipient) external;
}

interface IReleaser is IResourceManager, INonce {
    /// @notice Thrown when attempting to release too many assets at once
    error TooManyAssets();

    event Released(uint256 indexed nonce, address indexed recipient, Currency[] assets);

    /// @return Address of the Token Jar contract that will release the assets
    function TOKEN_JAR() external view returns (ITokenJar);

    /// @notice Releases assets to a specified recipient if the resource threshold is met
    /// @param _nonce The nonce for the release, must equal to the contract nonce otherwise revert
    /// @param assets The list of assets (addresses) to release, which may have length limits
    /// Native tokens (Ether) are represented as the zero address
    /// @param recipient The address to receive the released assets, paid out by Token Jar
    function release(uint256 _nonce, Currency[] calldata assets, address recipient) external;
}

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

/// @title ResourceManager
/// @notice A contract that holds immutable state for the resource token and the resource recipient
/// address. It also maintains logic for managing the threshold of the resource token.
abstract contract ResourceManager is IResourceManager, Owned {
    /// @inheritdoc IResourceManager
    uint256 public threshold;

    /// @inheritdoc IResourceManager
    address public thresholdSetter;

    /// @inheritdoc IResourceManager
    ERC20 public immutable RESOURCE;

    /// @inheritdoc IResourceManager
    address public immutable RESOURCE_RECIPIENT;

    /// @notice Ensures only the threshold setter can call the setThreshold function
    modifier onlyThresholdSetter() {
        require(msg.sender == thresholdSetter, Unauthorized());
        _;
    }

    /// @dev At construction the thresholdSetter defaults to 0 and its on the owner to set.
    constructor(address _resource, uint256 _threshold, address _owner, address _recipient) Owned(_owner) {
        RESOURCE = ERC20(_resource);
        RESOURCE_RECIPIENT = _recipient;
        threshold = _threshold;
    }

    /// @inheritdoc IResourceManager
    function setThresholdSetter(address _thresholdSetter) external onlyOwner {
        thresholdSetter = _thresholdSetter;
    }

    /// @inheritdoc IResourceManager
    function setThreshold(uint256 _threshold) external onlyThresholdSetter {
        threshold = _threshold;
    }
}

/// @title Nonce
/// @notice An abstract contract that provides nonce validation for transaction ordering protection
/// @dev Implements sequential nonce validation to prevent front-running and ensure searchers
///      can guarantee their transaction order when claiming available tokens
abstract contract Nonce is INonce {
    /// @inheritdoc INonce
    uint256 public nonce;

    /// @notice Validates and increments the nonce for transaction ordering protection
    /// @dev Ensures transactions are processed in the expected order, preventing front-running
    ///      when searchers submit burns to claim available tokens. The nonce guarantees that
    ///      if a searcher sees tokens available at a specific nonce, they can claim them
    ///      without another transaction landing first. Reverts with InvalidNonce if the
    ///      provided nonce doesn't match the current contract nonce.
    /// @param _nonce The expected current nonce value
    modifier handleNonce(uint256 _nonce) {
        require(_nonce == nonce, InvalidNonce());
        unchecked {
            ++nonce;
        }
        _;
    }
}

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(ERC20 token, address from, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            success := call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)

            // Set success to whether the call reverted, if not we check it either
            // returned exactly 1 (can't just be non-zero data), or had no return data and token has code.
            if and(iszero(and(eq(mload(0), 1), gt(returndatasize(), 31))), success) {
                success := iszero(or(iszero(extcodesize(token)), returndatasize()))
            }
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(ERC20 token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            success := call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)

            // Set success to whether the call reverted, if not we check it either
            // returned exactly 1 (can't just be non-zero data), or had no return data and token has code.
            if and(iszero(and(eq(mload(0), 1), gt(returndatasize(), 31))), success) {
                success := iszero(or(iszero(extcodesize(token)), returndatasize()))
            }
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(ERC20 token, address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
            // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
            success := call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)

            // Set success to whether the call reverted, if not we check it either
            // returned exactly 1 (can't just be non-zero data), or had no return data and token has code.
            if and(iszero(and(eq(mload(0), 1), gt(returndatasize(), 31))), success) {
                success := iszero(or(iszero(extcodesize(token)), returndatasize()))
            }
        }

        require(success, "APPROVE_FAILED");
    }
}

/// @title ExchangeReleaser
/// @notice A contract that releases assets from the TokenJar in exchange for transferring a
/// threshold amount of a resource token
/// @dev Inherits from ResourceManager for resource transferring functionality and Nonce for replay
/// protection
/// @dev Note there are some MEV and efficiency considerations around the release length and
/// threshold. If many assets are collected in the token jar, some may never reach a value high
/// enough to be released. Larger release lengths can mitigate this at the cost of higher gas and
/// searching complexity. Sharp price changes relative to the RESOURCE or large deposits into
/// TokenJar can also cause the exchange to be extra profitable for the release caller. Future
/// versions may consider dynamic thresholds or other MEV minimizing auction techniques
/// @custom:security-contact security@uniswap.org
abstract contract ExchangeReleaser is IReleaser, ResourceManager, Nonce {
    using SafeTransferLib for ERC20;

    /// @notice Maximum number of different assets that can be released in a single call
    uint256 public constant MAX_RELEASE_LENGTH = 20;

    /// @inheritdoc IReleaser
    ITokenJar public immutable TOKEN_JAR;

    /// @notice Creates a new ExchangeReleaser instance
    /// @param _resource The address of the resource token that must be transferred
    /// @param _threshold The minimum amount of resource tokens that must be transferred
    /// @param _tokenJar The address of the TokenJar contract holding the assets
    /// @param _recipient The address that will receive the resource tokens
    constructor(address _resource, uint256 _threshold, address _tokenJar, address _recipient)
        ResourceManager(_resource, _threshold, msg.sender, _recipient)
    {
        TOKEN_JAR = ITokenJar(payable(_tokenJar));
    }

    /// @inheritdoc IReleaser
    function release(uint256 _nonce, Currency[] calldata assets, address recipient) external handleNonce(_nonce) {
        require(assets.length <= MAX_RELEASE_LENGTH, TooManyAssets());
        RESOURCE.safeTransferFrom(msg.sender, RESOURCE_RECIPIENT, threshold);
        TOKEN_JAR.release(assets, recipient);
        emit Released(_nonce, recipient, assets);

        _afterRelease(assets, recipient);
    }

    /// @notice Internal function to handle any post transfer actions
    /// e.g. bridge calls or notifications
    function _afterRelease(Currency[] calldata assets, address recipient) internal virtual {
        // by default do nothing after release
    }
}

/// @title Firepit
/// @notice An ExchangeReleaser with recipient set to the burn address address(0xdead)
contract Firepit is ExchangeReleaser {
    constructor(address _resource, uint256 _threshold, address _tokenJar)
        ExchangeReleaser(_resource, _threshold, _tokenJar, address(0xdead))
    {}
}
