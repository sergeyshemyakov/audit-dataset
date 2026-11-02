// SPDX-License-Identifier: MIT
pragma solidity 0.8.32;

import {ProofLibV2} from "main_contracts_libs/ProofLibV2.sol";

/// @title IPool
/// @notice Minimal interface for PoolVault.transact()
interface IPool {
    struct TransactParams {
        address processor;
        bytes data;
    }

    struct NoteData {
        bytes32 hint;
        bytes data;
    }

    function transact(
        ProofLibV2.TransactProof calldata _proof,
        TransactParams calldata _transactParams,
        NoteData[] calldata _noteData
    ) external;
}

/// @title IEntrypoint
/// @notice Minimal interface for Entrypoint asset config lookup
interface IEntrypoint {
    struct AssetConfig {
        bool enabled;
        uint256 minAmount;
        uint256 vettingFeeBPS;
        uint256 maxRelayFee;
    }

    function assets(address _asset) external view returns (AssetConfig memory);
}

/// @title IRelaySwaps
/// @notice Interface for RelaySwaps — houses the proof-bound SwapRouting struct
///   and describes the contract's external surface (execute, router allowlist).
interface IRelaySwaps {
    /*///////////////////////////////////////////////////////////////
                              STRUCTS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Routing config — ABI-encoded into TransactParams.data,
    ///   committed in the ZK proof via context hash. Relayer cannot modify any field.
    /// @dev For same-chain swap: recipient receives output via LiFi, nativeGas forwarded,
    ///   minOutputAmount enforced via recipient balance delta.
    ///   recipient = address(0) means no source-chain recipient — reshield (LiFi deposits
    ///   via contractCalls) or cross-chain swap (output delivered on destination chain).
    ///   In that mode nativeGas and minOutputAmount MUST be 0 (enforced); output delivery
    ///   is verified elsewhere (Entrypoint.deposit revert / LiFi destination executor).
    ///   swapTarget is proof-bound — allows different DEX aggregators/Diamond versions.
    ///   swapCalldata is the full LiFi calldata, committed via the proof context hash.
    struct SwapRouting {
        address swapTarget;
        address approvalAddress;
        address outputToken;
        address recipient;
        address feeRecipient;
        address fallbackAddress;
        address dustRecipient;
        uint256 feeAmount;
        uint256 minOutputAmount;
        uint256 nativeGas;
        // --- B2: self-funded bridge msg.value (Mainnet-destination reshield). See
        //   RelaySwaps.sol for full semantics. swapValue == 0 => B2 path skipped. ---
        uint256 swapValue;
        uint256 gasSwapMaxInput;
        bytes gasSwapCalldata;
        bytes swapCalldata;
    }

    /*///////////////////////////////////////////////////////////////
                              ERRORS
    ///////////////////////////////////////////////////////////////*/

    error RelaySwaps_ZeroPool();
    error RelaySwaps_ZeroEntrypoint();
    error RelaySwaps_ZeroSwapTarget();
    error RelaySwaps_ZeroApprovalAddress();
    error RelaySwaps_InvalidSwapTarget();
    error RelaySwaps_InvalidApprovalAddress();
    error RelaySwaps_ZeroWithdrawal();
    error RelaySwaps_ZeroFeeRecipient();
    error RelaySwaps_ZeroDustRecipient();
    error RelaySwaps_SwapFailed();
    error RelaySwaps_InsufficientOutput();
    error RelaySwaps_FeeExceedsMax();
    error RelaySwaps_FeeExceedsWithdrawal();
    error RelaySwaps_NativeGasMismatch();
    error RelaySwaps_NativeGasWithoutRecipient();
    error RelaySwaps_MinOutputWithoutRecipient();
    error RelaySwaps_RenounceDisabled();
    error RelaySwaps_GasSwapInsufficient();
    error RelaySwaps_GasSwapNativeInput();

    /*///////////////////////////////////////////////////////////////
                              EVENTS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Emitted on successful execute
    event Executed(
        address indexed inputToken,
        address indexed outputToken,
        uint256 inputAmount,
        address feeRecipient,
        uint256 feeAmount
    );

    event RouterAdded(address indexed _routerAddress);
    event RouterRemoved(address indexed _routerAddress);

    /*///////////////////////////////////////////////////////////////
                              FUNCTIONS
    ///////////////////////////////////////////////////////////////*/

    /// @notice Native ETH sentinel (same as Constants.NATIVE_ASSET)
    function NATIVE_ASSET() external view returns (address);

    /// @notice Pool contract (PoolVault — exposes transact())
    function POOL() external view returns (IPool);

    /// @notice Entrypoint contract — for maxRelayFee lookup
    function ENTRYPOINT() external view returns (IEntrypoint);

    /// @notice Whether a swap/approval target is on the vetted router allowlist
    function approvedRouters(address _routerAddress) external view returns (bool);

    /// @notice adds a contract to the list of allowed routers
    /// @param _routerAddress address of the whitelisted contract.
    function approveRouter(address _routerAddress) external;

    /// @notice removes a contract from the list of allowed routers
    /// @param _routerAddress address of the contract to be removed from accepted list.
    function removeRouter(address _routerAddress) external;

    /// @notice Unified withdraw + swap. Pulls tokens via POOL.transact(), forwards to LiFi.
    /// @param _proof The transact proof (pubSignals[5][0] = amountOut, [6][0] = tokenIdOut)
    /// @param _transactParams Transact params with processor = address(this), data = abi.encode(SwapRouting)
    /// @param _noteData Per-output discovery data
    function execute(
        ProofLibV2.TransactProof calldata _proof,
        IPool.TransactParams calldata _transactParams,
        IPool.NoteData[] calldata _noteData
    ) external payable;
}
