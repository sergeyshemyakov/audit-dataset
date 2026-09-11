# Audit source summary: uniswapv3

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Uniswap V3 Core Security Assessment

- Report: [audit.md](<reports/audit.md>)
- Auditor: Trail of Bits
- Date: 2021-03-12
- Description: Trail of Bits manual review, Echidna fuzzing, Manticore verification and Slither analysis of the Uniswap V3 core contracts (factory, pool, pool deployer and arithmetic/tick/position/oracle libraries) at commit 99223f3 of uniswap-v3-core. Ten findings were reported, including two High-severity issues (free swaps/token draining via an incorrect balance comparison, and missing contract existence check in TransferHelper).

### Repository: <a href="https://github.com/Uniswap/v3-core"><code>Uniswap/v3-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/v3-core/blob/99223f33fd69a9e024f00bd8eea17b029d3f8f2d/contracts/NoDelegateCall.sol"><code>99223f33fd69a9e024f00bd8eea17b029d3f8f2d</code></a> | March 1, 2021 | <code>contracts/NoDelegateCall.sol</code><br><code>contracts/UniswapV3Factory.sol</code><br><code>contracts/UniswapV3Pool.sol</code><br><code>contracts/UniswapV3PoolDeployer.sol</code><br><code>contracts/libraries/BitMath.sol</code><br><code>contracts/libraries/FullMath.sol</code><br><code>contracts/libraries/LiquidityMath.sol</code><br><code>contracts/libraries/LowGasSafeMath.sol</code><br><code>contracts/libraries/Oracle.sol</code><br><code>contracts/libraries/Position.sol</code><br><code>contracts/libraries/SafeCast.sol</code><br><code>contracts/libraries/SecondsOutside.sol</code><br><code>contracts/libraries/SqrtPriceMath.sol</code><br><code>contracts/libraries/SwapMath.sol</code><br><code>contracts/libraries/Tick.sol</code><br><code>contracts/libraries/TickBitmap.sol</code><br><code>contracts/libraries/TickMath.sol</code><br><code>contracts/libraries/TransferHelper.sol</code><br><code>contracts/libraries/UnsafeMath.sol</code> |

## ABDK Consulting Smart Contract Audit: Uniswap V3

- Report: [audit-2.md](<reports/audit-2.md>)
- Auditor: ABDK Consulting
- Date: 2021-03-23
- Description: ABDK Consulting code review of the Uniswap V3 core contracts, libraries and interfaces at tag v1.0.0-beta.3 of uniswap-v3-core, with fixes tracked to specific pull requests and commits. 159 findings were reported, none Major or Critical; two Moderate issues (one FullMath overflow, fixed) and the rest Minor.

### Repository: <a href="https://github.com/Uniswap/v3-core"><code>Uniswap/v3-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/v3-core/blob/v1.0.0-beta.3/contracts/NoDelegateCall.sol"><code>e8de69a550d579c475f52d59a6fb2f7ef9e7f364</code></a> (tag <code>v1.0.0-beta.3</code>) | February 23, 2021 | <code>contracts/NoDelegateCall.sol</code><br><code>contracts/UniswapV3Factory.sol</code><br><code>contracts/UniswapV3Pool.sol</code><br><code>contracts/UniswapV3PoolDeployer.sol</code><br><code>contracts/interfaces/IERC20Minimal.sol</code><br><code>contracts/interfaces/IUniswapV3Factory.sol</code><br><code>contracts/interfaces/IUniswapV3Pool.sol</code><br><code>contracts/interfaces/IUniswapV3PoolDeployer.sol</code><br><code>contracts/interfaces/callback/IUniswapV3FlashCallback.sol</code><br><code>contracts/interfaces/callback/IUniswapV3MintCallback.sol</code><br><code>contracts/interfaces/callback/IUniswapV3SwapCallback.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolActions.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolEvents.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolImmutables.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolState.sol</code><br><code>contracts/libraries/BitMath.sol</code><br><code>contracts/libraries/FixedPoint128.sol</code><br><code>contracts/libraries/FixedPoint96.sol</code><br><code>contracts/libraries/FullMath.sol</code><br><code>contracts/libraries/LiquidityMath.sol</code><br><code>contracts/libraries/LowGasSafeMath.sol</code><br><code>contracts/libraries/Oracle.sol</code><br><code>contracts/libraries/Position.sol</code><br><code>contracts/libraries/SafeCast.sol</code><br><code>contracts/libraries/SecondsOutside.sol</code><br><code>contracts/libraries/SqrtPriceMath.sol</code><br><code>contracts/libraries/SwapMath.sol</code><br><code>contracts/libraries/Tick.sol</code><br><code>contracts/libraries/TickBitmap.sol</code><br><code>contracts/libraries/TickMath.sol</code><br><code>contracts/libraries/TransferHelper.sol</code><br><code>contracts/libraries/UnsafeMath.sol</code> |
| <a href="https://github.com/Uniswap/v3-core/blob/fc783807986595e33cdfc6ac82479535a42b955b/contracts/libraries/FullMath.sol"><code>fc783807986595e33cdfc6ac82479535a42b955b</code></a> | March 5, 2021 | <code>contracts/libraries/FullMath.sol</code> |
| <a href="https://github.com/Uniswap/v3-core/blob/7445e61f17a7c1233bcabcdc920f0473793f6d78/contracts/interfaces/pool/IUniswapV3PoolEvents.sol"><code>7445e61f17a7c1233bcabcdc920f0473793f6d78</code></a> | March 16, 2021 | <code>contracts/interfaces/pool/IUniswapV3PoolEvents.sol</code><br><code>contracts/libraries/SqrtPriceMath.sol</code><br><code>contracts/libraries/SwapMath.sol</code> |
| <a href="https://github.com/Uniswap/v3-core/blob/c3e2b3c938f50892b413422901cdac99a27c43a2/contracts/interfaces/IUniswapV3Factory.sol"><code>c3e2b3c938f50892b413422901cdac99a27c43a2</code></a> | March 22, 2021 | <code>contracts/interfaces/IUniswapV3Factory.sol</code> |
| <a href="https://github.com/Uniswap/v3-core/blob/d6fe02aaa6b4e30e03b5a0efa51b200e3c7e6bdc/contracts/interfaces/IUniswapV3PoolDeployer.sol"><code>d6fe02aaa6b4e30e03b5a0efa51b200e3c7e6bdc</code></a> | March 22, 2021 | <code>contracts/interfaces/IUniswapV3PoolDeployer.sol</code><br><code>contracts/interfaces/callback/IUniswapV3FlashCallback.sol</code><br><code>contracts/interfaces/callback/IUniswapV3MintCallback.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolActions.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolState.sol</code><br><code>contracts/libraries/Oracle.sol</code><br><code>contracts/libraries/SecondsOutside.sol</code><br><code>contracts/libraries/SqrtPriceMath.sol</code><br><code>contracts/libraries/Tick.sol</code><br><code>contracts/libraries/TickMath.sol</code> |

## ABDK Consulting Smart Contract Audit: Uniswap V3 Peripheral, Part 1

- Report: [audit-3.md](<reports/audit-3.md>)
- Auditor: ABDK Consulting
- Date: 2021-05-04
- Description: ABDK Consulting review of the Uniswap V3 periphery contracts NonfungiblePositionManager.sol and SwapRouter.sol in uniswap-v3-periphery, with fixes applied in two named periphery commits. Two Critical findings (SwapRouter exact-input payer bug and NonfungiblePositionManager liquidity theft via unchecked decreaseLiquidity) were fixed, and one Major finding remained open.

### Repository: <a href="https://github.com/Uniswap/v3-periphery"><code>Uniswap/v3-periphery</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/v3-periphery/blob/8ad273f45cd42e04b5f8f15b6f4da57827122273/contracts/NonfungiblePositionManager.sol"><code>8ad273f45cd42e04b5f8f15b6f4da57827122273</code></a> | April 12, 2021 | <code>contracts/NonfungiblePositionManager.sol</code><br><code>contracts/SwapRouter.sol</code> |
| <a href="https://github.com/Uniswap/v3-periphery/blob/987842552ede76d428e60116672fb0ff67fe551e/contracts/NonfungiblePositionManager.sol"><code>987842552ede76d428e60116672fb0ff67fe551e</code></a> | April 14, 2021 | <code>contracts/NonfungiblePositionManager.sol</code> |
| <a href="https://github.com/Uniswap/v3-periphery/blob/2353765fe799b987ac5236971398fcb0be2bc5c0/contracts/SwapRouter.sol"><code>2353765fe799b987ac5236971398fcb0be2bc5c0</code></a> | April 14, 2021 | <code>contracts/SwapRouter.sol</code> |
