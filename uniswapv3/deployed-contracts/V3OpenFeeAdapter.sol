// SPDX-License-Identifier: Unknown
pragma solidity 0.8.29;

/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    /// @notice Emitted when the owner of the factory is changed
    /// @param oldOwner The owner before the owner was changed
    /// @param newOwner The owner after the owner was changed
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when a pool is created
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param pool The address of the created pool
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    /// @notice Emitted when a new fee amount is enabled for pool creation via the factory
    /// @param fee The enabled fee, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks for pools created with the given fee
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    /// @notice Returns the current owner of the factory
    /// @dev Can be changed by the current owner via setOwner
    /// @return The address of the factory owner
    function owner() external view returns (address);

    /// @notice Returns the tick spacing for a given fee amount, if enabled, or 0 if not enabled
    /// @dev A fee amount can never be removed, so this value should be hard coded or cached in the calling context
    /// @param fee The enabled fee, denominated in hundredths of a bip. Returns 0 in case of unenabled fee
    /// @return The tick spacing
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The pool address
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    /// @notice Creates a pool for the given two tokens and fee
    /// @param tokenA One of the two tokens in the desired pool
    /// @param tokenB The other of the two tokens in the desired pool
    /// @param fee The desired fee for the pool
    /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    /// @return pool The address of the newly created pool
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    /// @notice Updates the owner of the factory
    /// @dev Must be called by the current owner
    /// @param _owner The new owner of the factory
    function setOwner(address _owner) external;

    /// @notice Enables a fee amount with the given tickSpacing
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6)
    /// @param tickSpacing The spacing between ticks to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

/// @title IV3OpenFeeAdapter
/// @notice Interface for a permissionless fee adapter that allows anyone to trigger fee updates
/// @dev This is a simplified version of IV3FeeAdapter that removes Merkle proof authorization.
///      Fee resolution uses a waterfall pattern: pool override → fee tier default → global
/// default.
///      Storage encoding: 0 = "not set" (continue waterfall), ZERO_FEE_SENTINEL = "explicitly zero"
interface IV3OpenFeeAdapter {
  /// @notice Thrown when trying to set a default fee for a non-enabled fee tier.
  error InvalidFeeTier();

  /// @notice Thrown when an unauthorized address attempts to call a restricted function
  error Unauthorized();

  /// @notice Thrown when trying to store a fee tier that is already stored.
  error TierAlreadyStored();

  /// @notice Thrown when trying to set an invalid fee value that doesn't meet protocol
  /// requirements.
  error InvalidFeeValue();

  /// @notice Emitted when a fee update is triggered for a pool
  /// @param caller The address that triggered the update
  /// @param pool The pool that was updated
  /// @param feeValue The new fee value applied
  event FeeUpdateTriggered(address indexed caller, address indexed pool, uint8 feeValue);

  /// @notice Emitted when the global default fee is updated
  /// @param feeValue The new global default fee value
  event DefaultFeeUpdated(uint8 feeValue);

  /// @notice Emitted when a fee tier default is updated
  /// @param feeTier The fee tier that was updated
  /// @param feeValue The new fee value for the tier
  event FeeTierDefaultUpdated(uint24 indexed feeTier, uint8 feeValue);

  /// @notice Emitted when a pool override is updated
  /// @param pool The pool that was updated
  /// @param feeValue The new fee value for the pool
  event PoolOverrideUpdated(address indexed pool, uint8 feeValue);

  /// @notice Emitted when a fee tier default is cleared (deleted from storage)
  /// @param feeTier The fee tier that was cleared
  event FeeTierDefaultCleared(uint24 indexed feeTier);

  /// @notice Emitted when a pool override is cleared (deleted from storage)
  /// @param pool The pool that was cleared
  event PoolOverrideCleared(address indexed pool);

  /// @notice Emitted when the fee setter is updated
  /// @param oldFeeSetter The previous fee setter address
  /// @param newFeeSetter The new fee setter address
  event FeeSetterUpdated(address indexed oldFeeSetter, address indexed newFeeSetter);

  /// @notice The input parameters for the collection.
  struct CollectParams {
    /// @param pool The pool to collect fees from.
    address pool;
    /// @param amount0Requested The amount of token0 to collect. If this is higher than the total
    /// collectable amount, it will collect all but 1 wei of the total token0 allotment.
    uint128 amount0Requested;
    /// @param amount1Requested The amount of token1 to collect. If this is higher than the total
    /// collectable amount, it will collect all but 1 wei of the total token1 allotment.
    uint128 amount1Requested;
  }

  /// @notice The returned amounts of token0 and token1 that are collected.
  struct Collected {
    /// @param amount0Collected The amount of token0 that is collected.
    uint128 amount0Collected;
    /// @param amount1Collected The amount of token1 that is collected.
    uint128 amount1Collected;
  }

  /// @notice The pair of tokens to trigger fees for.
  struct Pair {
    /// @param token0 The first token of the pair.
    address token0;
    /// @param token1 The second token of the pair.
    address token1;
  }

  /// @return The address where collected fees are sent.
  function TOKEN_JAR() external view returns (address);

  /// @return The Uniswap V3 Factory contract.
  function FACTORY() external view returns (IUniswapV3Factory);

  /// @return The authorized address to set fees-by-fee-tier
  function feeSetter() external view returns (address);

  /// @return The fee tiers enabled on the factory
  function feeTiers(uint256 i) external view returns (uint24);

  /// @notice Sentinel value stored to represent an explicit zero fee (disabled)
  /// @dev type(uint8).max because 0 in storage means "not set"
  function ZERO_FEE_SENTINEL() external view returns (uint8);

  /// @notice The global default fee applied when no tier or pool override is set
  /// @return The encoded global default fee value
  function defaultFee() external view returns (uint8);

  /// @notice Returns the fee tier default for a given fee tier
  /// @param feeTier The fee tier to query
  /// @return feeValue The encoded fee value for the tier (0 if not set)
  function feeTierDefaults(uint24 feeTier) external view returns (uint8 feeValue);

  /// @notice Returns the pool-specific override for a given pool
  /// @param pool The pool address to query
  /// @return feeValue The encoded fee value for the pool (0 if not set)
  function poolOverrides(address pool) external view returns (uint8 feeValue);

  /// @notice Legacy getter for backwards compatibility - returns effective fee for a tier
  /// @dev Applies waterfall resolution: fee tier default → global default.
  ///      Returns 0 only when neither level is configured.
  /// @param feeTier The fee tier to query
  /// @return defaultFeeValue The resolved fee value
  function defaultFees(uint24 feeTier) external view returns (uint8 defaultFeeValue);

  /// @notice Stores a fee tier.
  /// @param feeTier The fee tier to store.
  /// @dev Must be a fee tier that exists on the Uniswap V3 Factory.
  function storeFeeTier(uint24 feeTier) external;

  /// @notice Enables a new fee tier on the Uniswap V3 Factory.
  /// @dev Only callable by `owner`. Also updates the `feeTiers` array.
  /// @param newFeeTier The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6).
  /// @param tickSpacing The corresponding tick spacing for the new fee tier.
  function enableFeeAmount(uint24 newFeeTier, int24 tickSpacing) external;

  /// @notice Sets the owner of the Uniswap V3 Factory.
  /// @dev Only callable by `owner`
  /// @param newOwner The new owner of the Uniswap V3 Factory.
  function setFactoryOwner(address newOwner) external;

  /// @notice Collects protocol fees from the specified pools to the designated `TOKEN_JAR`
  /// @param collectParams Array of collection parameters for each pool.
  /// @return amountsCollected Array of collected amounts for each pool.
  function collect(CollectParams[] calldata collectParams)
    external
    returns (Collected[] memory amountsCollected);

  /// @notice Sets the global default fee value
  /// @dev Only callable by `feeSetter`. Used as fallback when no tier/pool override exists.
  /// @param feeValue The fee value (0 or in range [4,10] for each 4-bit component)
  function setDefaultFee(uint8 feeValue) external;

  /// @notice Sets the default fee for a specific fee tier
  /// @dev Only callable by `feeSetter`
  /// @param feeTier The fee tier to set the default for
  /// @param feeValue The fee value (0 or in range [4,10] for each 4-bit component)
  function setFeeTierDefault(uint24 feeTier, uint8 feeValue) external;

  /// @notice Sets a pool-specific fee override
  /// @dev Only callable by `feeSetter`. Takes precedence over tier and global defaults.
  /// @param pool The pool address to override
  /// @param feeValue The fee value (0 or in range [4,10] for each 4-bit component)
  function setPoolOverride(address pool, uint8 feeValue) external;

  /// @notice Clears the fee tier default, falling back to global default
  /// @dev Only callable by `feeSetter`
  /// @param feeTier The fee tier to clear
  function clearFeeTierDefault(uint24 feeTier) external;

  /// @notice Clears the pool override, falling back to tier/global defaults
  /// @dev Only callable by `feeSetter`
  /// @param pool The pool address to clear
  function clearPoolOverride(address pool) external;

  /// @notice Legacy function - sets fee tier default
  /// @dev Only callable by `feeSetter`. Kept for backwards compatibility.
  /// @param feeTier The fee tier, expressed in pips, to set the default fee for.
  /// @param defaultFeeValue The default fee value to set, expressed as the denominator on the
  /// inclusive interval [4, 10]. The fee value is packed (token1Fee << 4 | token0Fee)
  function setDefaultFeeByFeeTier(uint24 feeTier, uint8 defaultFeeValue) external;

  /// @notice Sets a new fee setter address.
  /// @dev Only callable by `owner`
  /// @param newFeeSetter The new address authorized to set fees.
  function setFeeSetter(address newFeeSetter) external;

  /// @notice Resolves the fee for a pool using waterfall: pool override → tier default → global
  /// @param pool The pool address to resolve fee for
  /// @return fee The resolved fee value (decoded)
  function getFee(address pool) external view returns (uint8 fee);

  /// @notice Triggers a fee update for a single pool. Permissionless.
  /// @param pool The pool address to update the fee for.
  function triggerFeeUpdate(address pool) external;

  /// @notice Triggers a fee update for one pair of tokens. Permissionless.
  /// @dev There may be multiple pools initialized from the given pair.
  /// @param token0 The first token of the pair.
  /// @param token1 The second token of the pair.
  function triggerFeeUpdate(address token0, address token1) external;

  /// @notice Triggers fee updates for multiple pairs of tokens. Permissionless.
  /// @param pairs The pairs of two tokens. There may be multiple pools initialized from the same
  /// pair.
  function batchTriggerFeeUpdate(Pair[] calldata pairs) external;

  /// @notice Triggers fee updates for multiple pools directly. Permissionless.
  /// @param pools The pool addresses to update the fees for.
  function batchTriggerFeeUpdateByPool(address[] calldata pools) external;
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

/// @title ArrayLib
/// @notice A utility library for working with uint24 arrays
/// @dev Provides helper functions for common array operations on uint24[] storage arrays
library ArrayLib {
  /// @notice Checks if a value exists in a uint24 array
  /// @dev Performs a linear search through the array to find the value
  /// @param array The storage array to search through
  /// @param value The uint24 value to search for
  /// @return True if the value exists in the array, false otherwise
  function includes(uint24[] storage array, uint24 value) internal view returns (bool) {
    uint256 length = array.length;
    for (uint256 i; i < length; i++) {
      if (array[i] == value) return true;
    }
    return false;
  }
}

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return _liquidity The amount of liquidity in the position,
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

/// @title V3OpenFeeAdapter
/// @notice A permissionless contract that allows anyone to trigger protocol fee updates for pools.
/// @dev This is a simplified version of V3FeeAdapter that removes Merkle proof authorization.
/// Fee updates are permissionless - anyone can call triggerFeeUpdate to apply the default fees
/// set by the feeSetter. This contract will be the set owner on the Uniswap V3 Factory.
///
/// Fee resolution uses a waterfall pattern: pool override → fee tier default → global default
///
/// Storage encoding:
/// - 0 in storage = "not set" (continue waterfall)
/// - ZERO_FEE_SENTINEL in storage = "explicitly set to zero" (fees disabled)
/// - Any other value = that actual fee
///
/// @custom:security-contact security@uniswap.org
contract V3OpenFeeAdapter is IV3OpenFeeAdapter, Owned {
  using ArrayLib for uint24[];

  /// @inheritdoc IV3OpenFeeAdapter
  /// @dev Safe to use max uint8 (255) as sentinel because V3 protocol fees pack two 4-bit values
  /// where each must be 0 or in range [4,10]. Max valid packed fee is (10 << 4) | 10 = 170 (0xAA).
  uint8 public constant ZERO_FEE_SENTINEL = type(uint8).max;

  /// @inheritdoc IV3OpenFeeAdapter
  IUniswapV3Factory public immutable FACTORY;
  /// @inheritdoc IV3OpenFeeAdapter
  address public immutable TOKEN_JAR;

  /// @inheritdoc IV3OpenFeeAdapter
  address public feeSetter;

  /// @inheritdoc IV3OpenFeeAdapter
  uint8 public defaultFee;

  /// @inheritdoc IV3OpenFeeAdapter
  mapping(uint24 feeTier => uint8 feeValue) public feeTierDefaults;

  /// @inheritdoc IV3OpenFeeAdapter
  mapping(address pool => uint8 feeValue) public poolOverrides;

  /// @return The fee tiers that are enabled on the factory. Iterable so that the protocol fee for
  /// pools of the same pair can be activated with the same call.
  /// @dev Returns four enabled fee tiers: 100, 500, 3000, 10000. May return more if more are
  /// enabled.
  uint24[] public feeTiers;

  /// @notice Ensures only the fee setter can call the setDefaultFeeByFeeTier function
  modifier onlyFeeSetter() {
    require(msg.sender == feeSetter, Unauthorized());
    _;
  }

  /// @dev At construction, the fee setter defaults to 0 and its on the owner to set.
  constructor(address _factory, address _tokenJar) Owned(msg.sender) {
    FACTORY = IUniswapV3Factory(_factory);
    TOKEN_JAR = _tokenJar;
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function storeFeeTier(uint24 feeTier) public {
    require(_feeTierExists(feeTier), InvalidFeeTier());
    require(!feeTiers.includes(feeTier), TierAlreadyStored());
    feeTiers.push(feeTier);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function enableFeeAmount(uint24 fee, int24 tickSpacing) external onlyOwner {
    FACTORY.enableFeeAmount(fee, tickSpacing);

    storeFeeTier(fee);
  }

  /// @notice Transfer ownership of the Uniswap V3 Factory to a new address
  /// @dev Only callable by the owner of this contract. This is a critical operation
  ///      as it transfers control of the V3 Factory
  /// @param newOwner The address that will become the new owner of the V3 Factory
  function setFactoryOwner(address newOwner) external onlyOwner {
    FACTORY.setOwner(newOwner);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function collect(CollectParams[] calldata collectParams)
    external
    returns (Collected[] memory amountsCollected)
  {
    amountsCollected = new Collected[](collectParams.length);
    for (uint256 i = 0; i < collectParams.length; i++) {
      CollectParams calldata params = collectParams[i];
      (uint128 amount0Collected, uint128 amount1Collected) = IUniswapV3PoolOwnerActions(params.pool)
        .collectProtocol(TOKEN_JAR, params.amount0Requested, params.amount1Requested);

      amountsCollected[i] =
        Collected({amount0Collected: amount0Collected, amount1Collected: amount1Collected});
    }
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function setDefaultFee(uint8 feeValue) external onlyFeeSetter {
    _validateFeeValue(feeValue);
    defaultFee = _encodeFee(feeValue);
    emit DefaultFeeUpdated(feeValue);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function setFeeTierDefault(uint24 feeTier, uint8 feeValue) external onlyFeeSetter {
    require(_feeTierExists(feeTier), InvalidFeeTier());
    _validateFeeValue(feeValue);
    feeTierDefaults[feeTier] = _encodeFee(feeValue);
    emit FeeTierDefaultUpdated(feeTier, feeValue);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function setPoolOverride(address pool, uint8 feeValue) external onlyFeeSetter {
    _validateFeeValue(feeValue);
    poolOverrides[pool] = _encodeFee(feeValue);
    emit PoolOverrideUpdated(pool, feeValue);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function clearFeeTierDefault(uint24 feeTier) external onlyFeeSetter {
    delete feeTierDefaults[feeTier];
    emit FeeTierDefaultCleared(feeTier);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function clearPoolOverride(address pool) external onlyFeeSetter {
    delete poolOverrides[pool];
    emit PoolOverrideCleared(pool);
  }

  /// @notice Legacy function for backwards compatibility
  /// @dev Renamed to setFeeTierDefault; this function is kept for existing integrations
  function setDefaultFeeByFeeTier(uint24 feeTier, uint8 defaultFeeValue) external onlyFeeSetter {
    require(_feeTierExists(feeTier), InvalidFeeTier());
    _validateFeeValue(defaultFeeValue);
    feeTierDefaults[feeTier] = _encodeFee(defaultFeeValue);
    emit FeeTierDefaultUpdated(feeTier, defaultFeeValue);
  }

  /// @notice Legacy getter for backwards compatibility
  /// @dev Applies waterfall resolution: fee tier default → global default.
  ///      Returns 0 only when neither a tier default nor a global default is configured.
  function defaultFees(uint24 feeTier) external view returns (uint8) {
    uint8 stored = feeTierDefaults[feeTier];
    if (stored != 0) return _decodeFee(stored);

    stored = defaultFee;
    if (stored != 0) return _decodeFee(stored);

    return 0;
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function setFeeSetter(address newFeeSetter) external onlyOwner {
    address oldFeeSetter = feeSetter;
    feeSetter = newFeeSetter;
    emit FeeSetterUpdated(oldFeeSetter, newFeeSetter);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function triggerFeeUpdate(address pool) external {
    _setProtocolFee(pool);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function triggerFeeUpdate(address token0, address token1) external {
    _setProtocolFeesForPair(token0, token1);
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function batchTriggerFeeUpdate(Pair[] calldata pairs) external {
    uint256 length = pairs.length;
    for (uint256 i; i < length;) {
      _setProtocolFeesForPair(pairs[i].token0, pairs[i].token1);
      unchecked {
        ++i;
      }
    }
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function batchTriggerFeeUpdateByPool(address[] calldata pools) external {
    uint256 length = pools.length;
    uint256 size;
    for (uint256 i; i < length;) {
      address pool = pools[i];
      assembly {
        size := extcodesize(pool)
      }
      if (size > 0) _setProtocolFee(pool);
      unchecked {
        ++i;
      }
    }
  }

  /// @notice Sets protocol fees for all existing pools of a token pair across all fee tiers
  /// @dev Iterates through all stored fee tiers and sets the protocol fee for each pool that exists
  /// @param token0 The first token of the pair
  /// @param token1 The second token of the pair
  function _setProtocolFeesForPair(address token0, address token1) internal {
    uint24 feeTier;
    address pool;
    uint256 length = feeTiers.length;
    for (uint256 i; i < length;) {
      feeTier = feeTiers[i];
      pool = FACTORY.getPool(token0, token1, feeTier);
      if (pool != address(0)) _setProtocolFee(pool);
      unchecked {
        ++i;
      }
    }
  }

  /// @inheritdoc IV3OpenFeeAdapter
  function getFee(address pool) public view returns (uint8 fee) {
    uint8 stored;

    // 1. Pool override (most specific)
    stored = poolOverrides[pool];
    if (stored != 0) return _decodeFee(stored);

    // 2. Fee tier default
    uint24 feeTier = IUniswapV3Pool(pool).fee();
    stored = feeTierDefaults[feeTier];
    if (stored != 0) return _decodeFee(stored);

    // 3. Global default
    stored = defaultFee;
    if (stored != 0) return _decodeFee(stored);

    // Nothing set → no protocol fee (fee defaults to 0)
  }

  /// @notice Sets the protocol fee for a specific pool using waterfall resolution
  /// @dev Only sets the fee for initialized pools (sqrtPriceX96 != 0).
  ///      Resolution order: pool override → fee tier default → global default
  /// @param pool The address of the Uniswap V3 pool
  function _setProtocolFee(address pool) internal {
    // Gas optimization: Check pool exists before expensive slot0 read
    uint256 size;
    assembly {
      size := extcodesize(pool)
    }
    if (size == 0) return;

    // Check if pool is initialized
    (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(pool).slot0();
    if (sqrtPriceX96 == 0) return; // Pool exists but not initialized, skip

    uint8 feeValue = getFee(pool);

    IUniswapV3PoolOwnerActions(pool).setFeeProtocol(feeValue % 16, feeValue >> 4);

    emit FeeUpdateTriggered(msg.sender, pool, feeValue);
  }

  /// @notice Checks if a fee tier exists in the Uniswap V3 Factory
  /// @dev Verifies existence by checking if the tick spacing for the fee tier is non-zero
  /// @param feeTier The fee tier to check
  /// @return True if the fee tier exists, false otherwise
  function _feeTierExists(uint24 feeTier) internal view returns (bool) {
    return FACTORY.feeAmountTickSpacing(feeTier) != 0;
  }

  /// @notice Validates that a fee value meets V3 protocol requirements
  /// @dev V3 fees are packed uint8 with two 4-bit values, each must be 0 or in range [4, 10]
  /// @param feeValue The fee value to validate
  function _validateFeeValue(uint8 feeValue) internal pure {
    // Extract the two 4-bit values
    uint8 feeProtocol0 = feeValue % 16;
    uint8 feeProtocol1 = feeValue >> 4;
    // Validate both values match pool requirements: must be 0 or in range [4, 10]
    require(
      (feeProtocol0 == 0 || (feeProtocol0 >= 4 && feeProtocol0 <= 10))
        && (feeProtocol1 == 0 || (feeProtocol1 >= 4 && feeProtocol1 <= 10)),
      InvalidFeeValue()
    );
  }

  /// @notice Encodes a fee for storage
  /// @dev Converts 0 to ZERO_FEE_SENTINEL so we can distinguish from "not set"
  /// @param feeValue The actual fee value
  /// @return The encoded value to store
  function _encodeFee(uint8 feeValue) internal pure returns (uint8) {
    return feeValue == 0 ? ZERO_FEE_SENTINEL : feeValue;
  }

  /// @notice Decodes a fee from storage
  /// @dev Converts ZERO_FEE_SENTINEL back to 0
  /// @param stored The value from storage
  /// @return The actual fee value
  function _decodeFee(uint8 stored) internal pure returns (uint8) {
    return stored == ZERO_FEE_SENTINEL ? 0 : stored;
  }
}