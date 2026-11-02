// SPDX-License-Identifier: MIT
pragma solidity 0.8.32;

import {IAavePool} from "interfaces/IAavePool.sol";
import {IEntrypoint} from "interfaces/IEntrypoint.sol";
import {IPPRouter} from "interfaces/IPPRouter.sol";
import {IPPYieldToken} from "interfaces/IPPYieldToken.sol";
import {IPPYieldTokenZap} from "interfaces/IPPYieldTokenZap.sol";
import {IPoolVault} from "interfaces/IPoolVault.sol";
import {IPrivacyPoolRelay} from "interfaces/IPrivacyPoolRelay.sol";

import {FeeCalculator} from "abstracts/FeeCalculator.sol";
import {ProofLibV2} from "libraries/ProofLibV2.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";

/// @title PPRouter
/// @author 0xbow
/// @notice Combined privacy-pool yield router. On the way in, `depositExactShares` wraps
/// `underlying -> aToken -> pp-share` and shields the result in one tx, hitting the commitment's FIXED
/// share value exactly while letting the underlying spent float up to `maxUnderlyingIn` (rate drift
/// between proof-gen and execution; see {IPPRouter}). On the way out, `withdrawToUnderlying` is the
/// pool's transact `processor`: the vault pays it the withdrawn pp-shares, which it unwraps to the
/// underlying for the recipient (and the relay fee to the fee recipient) via the zap, in one atomic
/// call. Stateless except for ≤ 2 wei of aToken dust per deposit (supply rounding), swept lazily.
contract PPRouter is IPPRouter, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;
    using Address for address payable;
    using ProofLibV2 for ProofLibV2.DepositProof;
    using ProofLibV2 for ProofLibV2.TransactProof;

    /*///////////////////////////////////////////////////////////////
                          IMMUTABLES
    ///////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPPRouter
    IPPYieldToken public immutable VAULT;

    /// @inheritdoc IPPRouter
    /// @dev Retained but no longer used in logic — the Aave interaction (deposit and withdraw) now lives in
    ///      the zap. Full removal (to make the router fully protocol-agnostic) is tracked in BACKLOG.
    IAavePool public immutable POOL;

    /// @inheritdoc IPPRouter
    IERC20 public immutable UNDERLYING;

    /// @inheritdoc IPPRouter
    IERC20 public immutable A_TOKEN;

    /// @inheritdoc IPPRouter
    IEntrypoint public immutable ENTRYPOINT;

    /// @inheritdoc IPPRouter
    address public immutable DUST_RECIPIENT;

    /// @inheritdoc IPPRouter
    IPPYieldTokenZap public immutable ZAP;

    /// @inheritdoc IPPRouter
    IPoolVault public immutable POOL_VAULT;

    /*///////////////////////////////////////////////////////////////
                          CONSTRUCTOR
    ///////////////////////////////////////////////////////////////*/

    /// @param _vault The pp-share wrapper to shield into
    /// @param _pool The Aave v3 pool
    /// @param _underlying The underlying token supplied to Aave (e.g. USDC)
    /// @param _entrypoint The privacy-pool entrypoint
    /// @param _dustRecipient The fixed recipient of swept aToken dust
    /// @param _zap The zap that unwraps withdrawn pp-shares back to the underlying
    /// @param _poolVault The privacy-pool vault withdrawals are processed against
    constructor(
        IPPYieldToken _vault,
        IAavePool _pool,
        IERC20 _underlying,
        IEntrypoint _entrypoint,
        address _dustRecipient,
        IPPYieldTokenZap _zap,
        IPoolVault _poolVault
    ) {
        require(
            address(_vault) != address(0) && address(_pool) != address(0) && address(_underlying) != address(0)
                && address(_entrypoint) != address(0) && _dustRecipient != address(0) && address(_zap) != address(0)
                && address(_poolVault) != address(0),
            PPRouter_ZeroAddress()
        );
        // The zap must wrap this router's exact (vault, underlying) pair, else withdrawals would unwrap the
        // wrong asset. Cheap construction-time guard against a misconfigured deployment.
        require(
            address(_zap.VAULT()) == address(_vault) && address(_zap.UNDERLYING()) == address(_underlying),
            PPRouter_AssetMismatch(address(_zap.VAULT()))
        );
        VAULT = _vault;
        POOL = _pool;
        UNDERLYING = _underlying;
        ENTRYPOINT = _entrypoint;
        DUST_RECIPIENT = _dustRecipient;
        ZAP = _zap;
        POOL_VAULT = _poolVault;
        A_TOKEN = IERC20(_vault.asset());
    }

    /*///////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPPRouter
    function depositExactShares(
        ProofLibV2.DepositProof calldata _proof,
        IPoolVault.NoteData calldata _noteData,
        bytes calldata _aspCiphertext,
        uint256 _maxUnderlyingIn
    ) external nonReentrant returns (uint256 _underlyingIn) {
        address _asset = _proof.tokenId();
        require(_asset == address(VAULT), PPRouter_AssetMismatch(_asset));
        uint256 _value = _proof.value();
        require(_value != 0, PPRouter_ZeroValue());

        // `_underlyingIn` is the underlying to supply to mint EXACTLY `_total` pp-shares (`_total` = committed
        // value + vetting fee, which the entrypoint pulls). Both come from `_quote` so the quoted and executed
        // amounts cannot drift (`_asset == VAULT` by the check above, so `_quote`'s VAULT-based fee equals this
        // deposit's fee). The zap's previewMint/mint are atomic over the same totalAssets (the supply to the
        // zap does not touch the vault's balance), so the share math is exact.
        uint256 _total;
        (_underlyingIn, _total) = _quote(_value);
        require(_underlyingIn <= _maxUnderlyingIn, PPRouter_SlippageExceeded(_underlyingIn, _maxUnderlyingIn));

        // 1-2. Route the Aave supply + exact `mint` through the zap (the single Aave touch-point). The zap
        //      pulls `_underlyingIn` from this router, supplies it, and mints EXACTLY `_total` pp-shares back
        //      to this router; the defensive wrap check and the ≤ buffer-wei aToken dust both live in the zap
        //      (it forwards the dust here, swept later via `skim`). Driven off the zap's previewMint, never off
        //      this router's balanceOf, so any pre-existing dust float cannot skew the amount.
        UNDERLYING.safeTransferFrom(msg.sender, address(this), _underlyingIn);
        UNDERLYING.forceApprove(address(ZAP), _underlyingIn);
        uint256 _sharesBefore = IERC20(address(VAULT)).balanceOf(address(this));
        ZAP.buyFixedYieldToken(_total, address(this), _underlyingIn);

        // 3. Shield: the entrypoint pulls exactly `_total` pp-shares from this router and inserts the leaf
        //    for `_value`. The router's pp-share balance returns to baseline — no un-shielded share dust.
        IERC20(address(VAULT)).forceApprove(address(ENTRYPOINT), _total);
        ENTRYPOINT.deposit(_proof, _noteData, _aspCiphertext);
        // Defensive: the trusted entrypoint pulls exactly `_total`. Assert the pp-share balance returned to
        // baseline so a deviating entrypoint reverts (unwinding the lingering allowance) instead of silently
        // stranding the payer's shares. Tolerates any pre-existing balance, so it is not griefable.
        require(IERC20(address(VAULT)).balanceOf(address(this)) == _sharesBefore, PPRouter_SharesStranded());

        // Residual: ≤ SUPPLY_ROUNDING_BUFFER wei of aToken stays in the router, swept later via `skim`.
        emit Deposited({
            _payer: msg.sender,
            _asset: _asset,
            _value: _value,
            _underlyingIn: _underlyingIn,
            _total: _total
        });
    }

    /// @inheritdoc IPPRouter
    function withdrawToUnderlying(
        ProofLibV2.TransactProof calldata _proof,
        IPoolVault.TransactParams calldata _transactParams,
        IPoolVault.NoteData[] calldata _noteData,
        uint256 _minUnderlyingOut
    ) external payable nonReentrant returns (uint256 _underlyingToRecipient, uint256 _underlyingFee) {
        uint256 _sharesOut = _proof.amountOut();
        require(_sharesOut != 0, PPRouter_ZeroWithdrawal());
        // `tokenIdOut` is the asset the vault pays the processor; it must be this router's pp-share so the
        // zap can unwrap it. Also reverts cleanly if the proof targets a different pool asset.
        address _yieldAsset = _proof.tokenIdOut();
        require(_yieldAsset == address(VAULT), PPRouter_AssetMismatch(_yieldAsset));
        // The vault pays `amountOut` to `msg.sender == processor`; require that processor is this router so
        // the shares land here to be unwrapped (and so a caller cannot point the payout elsewhere).
        require(_transactParams.processor == address(this), PPRouter_InvalidProcessor());

        // Payout routing is bound into the proof `context`, so a submitting relayer cannot tamper with it.
        IPrivacyPoolRelay.PayoutRouting memory _payout =
            abi.decode(_transactParams.data, (IPrivacyPoolRelay.PayoutRouting));
        // Stricter than the canonical PrivacyPoolRelay by design (footgun removal, cf. INTL-14): a payout
        // committing `recipient == 0` would otherwise burn the unwrapped underlying and the native gas.
        require(_payout.recipient != address(0), PPRouter_ZeroRecipient());
        require(msg.value == _payout.nativeGas, PPRouter_NativeGasMismatch());
        // `maxRelayFee == 0` means "no cap" per IEntrypoint (0 = no maximum) — matches RelaySwaps/MockPool/SDK;
        // without the sentinel a 0-config would revert every nonzero relay fee on the yield route.
        uint256 _maxRelayFee = ENTRYPOINT.assets(_yieldAsset).maxRelayFee;
        require(_maxRelayFee == 0 || _payout.feeAmount <= _maxRelayFee, PPRouter_FeeExceedsMax());
        require(_sharesOut >= _payout.feeAmount, PPRouter_FeeExceedsWithdrawal());

        address _feeRecipient = _payout.feeRecipient != address(0) ? _payout.feeRecipient : msg.sender;
        // Only charge a fee leg that actually redeems to > 0 underlying. A dust fee (one that
        // `previewRedeem` rounds to 0 USDC) is waived to the recipient rather than reverting the whole
        // withdrawal on the vault's `PPYieldToken_ZeroAssets` guard — robust to ANY relayer fee policy
        // (flat / bps / zero / dust), so a withdrawal never depends on the fee config to avoid a revert.
        uint256 _payableFee =
            (_payout.feeAmount != 0 && VAULT.previewRedeem(_payout.feeAmount) != 0) ? _payout.feeAmount : 0;
        uint256 _recipientShares = _sharesOut - _payableFee;

        // Pull the withdrawn pp-shares out of the pool: the vault pays `_sharesOut` of `tokenIdOut` (== VAULT)
        // to the processor (this router). Defensive balance check (tolerant of any pre-existing dust).
        uint256 _sharesBefore = IERC20(address(VAULT)).balanceOf(address(this));
        POOL_VAULT.transact(_proof, _transactParams, _noteData);
        require(
            IERC20(address(VAULT)).balanceOf(address(this)) == _sharesBefore + _sharesOut, PPRouter_SharesNotReceived()
        );

        // Unwrap each leg pp-shares -> underlying via the zap — the only Aave touch-point on the way out, so
        // this router is protocol-agnostic. One approval covers both redeems (recipient share + fee share).
        IERC20(address(VAULT)).forceApprove(address(ZAP), _sharesOut);
        if (_recipientShares != 0) {
            _underlyingToRecipient = ZAP.redeemToUnderlying(_recipientShares, _payout.recipient);
        }
        require(
            _underlyingToRecipient >= _minUnderlyingOut,
            PPRouter_BelowMinUnderlying(_underlyingToRecipient, _minUnderlyingOut)
        );
        if (_payableFee != 0) {
            _underlyingFee = ZAP.redeemToUnderlying(_payableFee, _feeRecipient);
        }

        // Forward the submitter's native-gas funding to the recipient (mirrors PrivacyPoolRelay).
        if (msg.value != 0) {
            payable(_payout.recipient).sendValue(msg.value);
        }

        emit WithdrawnToUnderlying({
            _asset: _yieldAsset,
            _underlying: address(UNDERLYING),
            _recipient: _payout.recipient,
            _sharesOut: _sharesOut,
            _underlyingToRecipient: _underlyingToRecipient,
            _feeRecipient: _feeRecipient,
            _feeShares: _payableFee,
            _underlyingFee: _underlyingFee,
            _gasFunding: msg.value
        });
    }

    /// @inheritdoc IPPRouter
    function skim() external returns (uint256 _amount) {
        _amount = A_TOKEN.balanceOf(address(this));
        // Emit only on a real sweep: `skim` is permissionless, so a no-op must not spam `Skimmed`.
        if (_amount != 0) {
            A_TOKEN.safeTransfer(DUST_RECIPIENT, _amount);
            emit Skimmed(DUST_RECIPIENT, _amount);
        }
    }

    /*///////////////////////////////////////////////////////////////
                            VIEWS
    ///////////////////////////////////////////////////////////////*/

    /// @inheritdoc IPPRouter
    function quote(uint256 _value) external view returns (uint256 _underlyingNeeded, uint256 _total) {
        (_underlyingNeeded, _total) = _quote(_value);
    }

    /// @inheritdoc IPPRouter
    function quoteWithdraw(uint256 _shares) external view returns (uint256 _underlyingOut) {
        // aToken is ~1:1 with the underlying, so `previewRedeem` (shares -> aToken) is the underlying out.
        _underlyingOut = VAULT.previewRedeem(_shares);
    }

    /*///////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////////////*/

    /// @notice The underlying to supply and total pp-shares for a commitment of `_value`
    /// @dev Single source of truth for both `quote` and `depositExactShares`, so the quoted and executed
    ///      amounts are identical. The fee uses this router's `VAULT` config; the underlying math (the
    ///      `previewMint` + supply buffer) is delegated to the zap via `ZAP.quoteBuy`, which is the same
    ///      figure the zap pulls when it executes the exact mint.
    /// @param _value The committed share value
    /// @return _underlyingNeeded `ZAP.quoteBuy(value + fee)` — the underlying to supply
    /// @return _total `value + fee` (the pp-shares the entrypoint pulls)
    function _quote(uint256 _value) internal view returns (uint256 _underlyingNeeded, uint256 _total) {
        _total = _value + _fee(_value, address(VAULT));
        _underlyingNeeded = ZAP.quoteBuy(_total);
    }

    /// @notice The entrypoint vetting fee on a deposit of `_value`, via the shared `FeeCalculator`
    /// @param _value The committed deposit value
    /// @param _asset The pp-share asset (this router's vault)
    /// @return The vetting fee in pp-shares
    function _fee(uint256 _value, address _asset) internal view returns (uint256) {
        return FeeCalculator.calcFee(_value, ENTRYPOINT.assets(_asset).vettingFeeBPS);
    }
}
