# Audit source summary: uniswapv3

Generated from [audit-summary.json](audit-summary.json). Do not edit manually.
Commit dates use Git committer timestamps (UTC).

## Uniswap V3 Core Security Assessment

- Report: [audit.md](<reports/audit.md>)
- Auditor: Trail of Bits
- Date: 2021-03-12
- Description: Security assessment of the Uniswap V3 core contracts and whitepaper at commit 99223f3, covering the arithmetic libraries, the factory, and the pool&#x27;s initialization, mint, burn, flash, and swap logic. Manual review was combined with Echidna, Manticore, and Slither testing.

### Repository: <a href="https://github.com/Uniswap/uniswap-v3-core"><code>Uniswap/uniswap-v3-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/uniswap-v3-core/blob/99223f33fd69a9e024f00bd8eea17b029d3f8f2d/contracts/libraries/BitMath.sol"><code>99223f33fd69a9e024f00bd8eea17b029d3f8f2d</code></a> | March 1, 2021 | <code>contracts/libraries/BitMath.sol</code><br><code>contracts/libraries/FullMath.sol</code><br><code>contracts/libraries/UnsafeMath.sol</code><br><code>contracts/libraries/SafeCast.sol</code><br><code>contracts/libraries/LowGasSafeMath.sol</code><br><code>contracts/libraries/LiquidityMath.sol</code><br><code>contracts/libraries/Tick.sol</code><br><code>contracts/libraries/Position.sol</code><br><code>contracts/NoDelegateCall.sol</code><br><code>contracts/UniswapV3Factory.sol</code><br><code>contracts/UniswapV3PoolDeployer.sol</code><br><code>contracts/libraries/TransferHelper.sol</code><br><code>contracts/libraries/TickMath.sol</code><br><code>contracts/libraries/TickBitmap.sol</code><br><code>contracts/libraries/SqrtPriceMath.sol</code><br><code>contracts/libraries/SwapMath.sol</code><br><code>contracts/libraries/Oracle.sol</code><br><code>contracts/libraries/SecondsOutside.sol</code><br><code>contracts/UniswapV3Pool.sol</code> |

## Uniswap Review

- Report: [audit-2.md](<reports/audit-2.md>)
- Auditor: ABDK Consulting
- Date: 2021-03-23
- Description: Line-by-line review of the Uniswap V3 core contracts, interfaces, and math libraries at commit e8de69a5. The audit focused on arithmetic and protocol-logic correctness and reported no critical bugs.

### Repository: <a href="https://github.com/Uniswap/uniswap-v3-core"><code>Uniswap/uniswap-v3-core</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/uniswap-v3-core/tree/v1.0.0-beta.3"><code>e8de69a550d579c475f52d59a6fb2f7ef9e7f364</code></a> (tag <code>v1.0.0-beta.3</code>) | February 23, 2021 | <code>contracts/interfaces/callback/IUniswapV3FlashCallback.sol</code><br><code>contracts/interfaces/callback/IUniswapV3MintCallback.sol</code><br><code>contracts/interfaces/callback/IUniswapV3SwapCallback.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolActions.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolEvents.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolImmutables.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol</code><br><code>contracts/interfaces/pool/IUniswapV3PoolState.sol</code><br><code>contracts/interfaces/IERC20Minimal.sol</code><br><code>contracts/interfaces/IUniswapV3Factory.sol</code><br><code>contracts/interfaces/IUniswapV3Pool.sol</code><br><code>contracts/interfaces/IUniswapV3PoolDeployer.sol</code><br><code>contracts/libraries/BitMath.sol</code><br><code>contracts/libraries/FixedPoint128.sol</code><br><code>contracts/libraries/FixedPoint96.sol</code><br><code>contracts/libraries/FullMath.sol</code><br><code>contracts/libraries/LiquidityMath.sol</code><br><code>contracts/libraries/LowGasSafeMath.sol</code><br><code>contracts/libraries/Oracle.sol</code><br><code>contracts/libraries/Position.sol</code><br><code>contracts/libraries/SafeCast.sol</code><br><code>contracts/libraries/SecondsOutside.sol</code><br><code>contracts/libraries/SqrtPriceMath.sol</code><br><code>contracts/libraries/SwapMath.sol</code><br><code>contracts/libraries/Tick.sol</code><br><code>contracts/libraries/TickBitmap.sol</code><br><code>contracts/libraries/TickMath.sol</code><br><code>contracts/libraries/TransferHelper.sol</code><br><code>contracts/libraries/UnsafeMath.sol</code><br><code>contracts/NoDelegateCall.sol</code><br><code>contracts/UniswapV3Factory.sol</code><br><code>contracts/UniswapV3Pool.sol</code><br><code>contracts/UniswapV3PoolDeployer.sol</code> |

## Uniswap V3 Peripheral Part 1 Review

- Report: [audit-3.md](<reports/audit-3.md>)
- Auditor: ABDK Consulting
- Date: 2021-04-26
- Description: Line-by-line review of the Uniswap V3 periphery contracts NonfungiblePositionManager and SwapRouter, together with a follow-up review of the fixes. Two critical bugs and one major flaw were reported and later fixed.

### Repository: <a href="https://github.com/Uniswap/uniswap-v3-periphery"><code>Uniswap/uniswap-v3-periphery</code></a>

| Revision | Commit date | Audited files or directories |
| --- | --- | --- |
| <a href="https://github.com/Uniswap/uniswap-v3-periphery/commit/8ad273f45cd42e04b5f8f15b6f4da57827122273"><code>8ad273f45cd42e04b5f8f15b6f4da57827122273</code></a> | April 12, 2021 | <code>contracts/NonfungiblePositionManager.sol</code><br><code>contracts/SwapRouter.sol</code> |
| <a href="https://github.com/Uniswap/uniswap-v3-periphery/commit/987842552ede76d428e60116672fb0ff67fe551e"><code>987842552ede76d428e60116672fb0ff67fe551e</code></a> | April 14, 2021 | <code>contracts/NonfungiblePositionManager.sol</code> |
| <a href="https://github.com/Uniswap/uniswap-v3-periphery/commit/2353765fe799b987ac5236971398fcb0be2bc5c0"><code>2353765fe799b987ac5236971398fcb0be2bc5c0</code></a> | April 14, 2021 | <code>contracts/SwapRouter.sol</code> |
