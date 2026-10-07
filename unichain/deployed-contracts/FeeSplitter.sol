// SPDX-License-Identifier: Unknown
pragma solidity 0.8.26;

library SafeCall {
    /// @notice Performs a low level call without copying any returndata.
    /// @dev Passes no calldata to the call context.
    /// @param _target   Address to call
    /// @param _gas      Amount of gas to pass to the call
    /// @param _value    Amount of value to pass to the call
    function send(address _target, uint256 _gas, uint256 _value) internal returns (bool success_) {
        assembly {
            success_ :=
                call(
                    _gas, // gas
                    _target, // recipient
                    _value, // ether value
                    0, // inloc
                    0, // inlen
                    0, // outloc
                    0 // outlen
                )
        }
    }

    /// @notice Perform a low level call with all gas without copying any returndata
    /// @param _target   Address to call
    /// @param _value    Amount of value to pass to the call
    function send(address _target, uint256 _value) internal returns (bool success_) {
        success_ = send(_target, gasleft(), _value);
    }

    /// @notice Perform a low level call without copying any returndata
    /// @param _target   Address to call
    /// @param _gas      Amount of gas to pass to the call
    /// @param _value    Amount of value to pass to the call
    /// @param _calldata Calldata to pass to the call
    function call(address _target, uint256 _gas, uint256 _value, bytes memory _calldata)
        internal
        returns (bool success_)
    {
        assembly {
            success_ :=
                call(
                    _gas, // gas
                    _target, // recipient
                    _value, // ether value
                    add(_calldata, 32), // inloc
                    mload(_calldata), // inlen
                    0, // outloc
                    0 // outlen
                )
        }
    }

    /// @notice Perform a low level call without copying any returndata
    /// @param _target   Address to call
    /// @param _value    Amount of value to pass to the call
    /// @param _calldata Calldata to pass to the call
    function call(address _target, uint256 _value, bytes memory _calldata) internal returns (bool success_) {
        success_ = call({_target: _target, _gas: gasleft(), _value: _value, _calldata: _calldata});
    }

    /// @notice Perform a low level call without copying any returndata
    /// @param _target   Address to call
    /// @param _calldata Calldata to pass to the call
    function call(address _target, bytes memory _calldata) internal returns (bool success_) {
        success_ = call({_target: _target, _gas: gasleft(), _value: 0, _calldata: _calldata});
    }

    /// @notice Helper function to determine if there is sufficient gas remaining within the context
    ///         to guarantee that the minimum gas requirement for a call will be met as well as
    ///         optionally reserving a specified amount of gas for after the call has concluded.
    /// @param _minGas      The minimum amount of gas that may be passed to the target context.
    /// @param _reservedGas Optional amount of gas to reserve for the caller after the execution
    ///                     of the target context.
    /// @return `true` if there is enough gas remaining to safely supply `_minGas` to the target
    ///         context as well as reserve `_reservedGas` for the caller after the execution of
    ///         the target context.
    /// @dev !!!!! FOOTGUN ALERT !!!!!
    ///      1.) The 40_000 base buffer is to account for the worst case of the dynamic cost of the
    ///          `CALL` opcode's `address_access_cost`, `positive_value_cost`, and
    ///          `value_to_empty_account_cost` factors with an added buffer of 5,700 gas. It is
    ///          still possible to self-rekt by initiating a withdrawal with a minimum gas limit
    ///          that does not account for the `memory_expansion_cost` & `code_execution_cost`
    ///          factors of the dynamic cost of the `CALL` opcode.
    ///      2.) This function should *directly* precede the external call if possible. There is an
    ///          added buffer to account for gas consumed between this check and the call, but it
    ///          is only 5,700 gas.
    ///      3.) Because EIP-150 ensures that a maximum of 63/64ths of the remaining gas in the call
    ///          frame may be passed to a subcontext, we need to ensure that the gas will not be
    ///          truncated.
    ///      4.) Use wisely. This function is not a silver bullet.
    function hasMinGas(uint256 _minGas, uint256 _reservedGas) internal view returns (bool) {
        bool _hasMinGas;
        assembly {
            // Equation: gas × 63 ≥ minGas × 64 + 63(40_000 + reservedGas)
            _hasMinGas := iszero(lt(mul(gas(), 63), add(mul(_minGas, 64), mul(add(40000, _reservedGas), 63))))
        }
        return _hasMinGas;
    }

    /// @notice Perform a low level call without copying any returndata. This function
    ///         will revert if the call cannot be performed with the specified minimum
    ///         gas.
    /// @param _target   Address to call
    /// @param _minGas   The minimum amount of gas that may be passed to the call
    /// @param _value    Amount of value to pass to the call
    /// @param _calldata Calldata to pass to the call
    function callWithMinGas(address _target, uint256 _minGas, uint256 _value, bytes memory _calldata)
        internal
        returns (bool)
    {
        bool _success;
        bool _hasMinGas = hasMinGas(_minGas, 0);
        assembly {
            // Assertion: gasleft() >= (_minGas * 64) / 63 + 40_000
            if iszero(_hasMinGas) {
                // Store the "Error(string)" selector in scratch space.
                mstore(0, 0x08c379a0)
                // Store the pointer to the string length in scratch space.
                mstore(32, 32)
                // Store the string.
                //
                // SAFETY:
                // - We pad the beginning of the string with two zero bytes as well as the
                // length (24) to ensure that we override the free memory pointer at offset
                // 0x40. This is necessary because the free memory pointer is likely to
                // be greater than 1 byte when this function is called, but it is incredibly
                // unlikely that it will be greater than 3 bytes. As for the data within
                // 0x60, it is ensured that it is 0 due to 0x60 being the zero offset.
                // - It's fine to clobber the free memory pointer, we're reverting.
                mstore(88, 0x0000185361666543616c6c3a204e6f7420656e6f75676820676173)

                // Revert with 'Error("SafeCall: Not enough gas")'
                revert(28, 100)
            }

            // The call will be supplied at least ((_minGas * 64) / 63) gas due to the
            // above assertion. This ensures that, in all circumstances (except for when the
            // `_minGas` does not account for the `memory_expansion_cost` and `code_execution_cost`
            // factors of the dynamic cost of the `CALL` opcode), the call will receive at least
            // the minimum amount of gas specified.
            _success :=
                call(
                    gas(), // gas
                    _target, // recipient
                    _value, // ether value
                    add(_calldata, 32), // inloc
                    mload(_calldata), // inlen
                    0x00, // outloc
                    0x00 // outlen
                )
        }
        return _success;
    }
}

library Predeploys {
    /// @notice Number of predeploy-namespace addresses reserved for protocol usage.
    uint256 internal constant PREDEPLOY_COUNT = 2048;

    /// @custom:legacy
    /// @notice Address of the LegacyMessagePasser predeploy. Deprecate. Use the updated
    ///         L2ToL1MessagePasser contract instead.
    address internal constant LEGACY_MESSAGE_PASSER = 0x4200000000000000000000000000000000000000;

    /// @custom:legacy
    /// @notice Address of the L1MessageSender predeploy. Deprecated. Use L2CrossDomainMessenger
    ///         or access tx.origin (or msg.sender) in a L1 to L2 transaction instead.
    ///         Not embedded into new OP-Stack chains.
    address internal constant L1_MESSAGE_SENDER = 0x4200000000000000000000000000000000000001;

    /// @custom:legacy
    /// @notice Address of the DeployerWhitelist predeploy. No longer active.
    address internal constant DEPLOYER_WHITELIST = 0x4200000000000000000000000000000000000002;

    /// @notice Address of the canonical WETH contract.
    address internal constant WETH = 0x4200000000000000000000000000000000000006;

    /// @notice Address of the L2CrossDomainMessenger predeploy.
    address internal constant L2_CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000007;

    /// @notice Address of the GasPriceOracle predeploy. Includes fee information
    ///         and helpers for computing the L1 portion of the transaction fee.
    address internal constant GAS_PRICE_ORACLE = 0x420000000000000000000000000000000000000F;

    /// @notice Address of the L2StandardBridge predeploy.
    address internal constant L2_STANDARD_BRIDGE = 0x4200000000000000000000000000000000000010;

    //// @notice Address of the SequencerFeeWallet predeploy.
    address internal constant SEQUENCER_FEE_WALLET = 0x4200000000000000000000000000000000000011;

    /// @notice Address of the OptimismMintableERC20Factory predeploy.
    address internal constant OPTIMISM_MINTABLE_ERC20_FACTORY = 0x4200000000000000000000000000000000000012;

    /// @custom:legacy
    /// @notice Address of the L1BlockNumber predeploy. Deprecated. Use the L1Block predeploy
    ///         instead, which exposes more information about the L1 state.
    address internal constant L1_BLOCK_NUMBER = 0x4200000000000000000000000000000000000013;

    /// @notice Address of the L2ERC721Bridge predeploy.
    address internal constant L2_ERC721_BRIDGE = 0x4200000000000000000000000000000000000014;

    /// @notice Address of the L1Block predeploy.
    address internal constant L1_BLOCK_ATTRIBUTES = 0x4200000000000000000000000000000000000015;

    /// @notice Address of the L2ToL1MessagePasser predeploy.
    address internal constant L2_TO_L1_MESSAGE_PASSER = 0x4200000000000000000000000000000000000016;

    /// @notice Address of the OptimismMintableERC721Factory predeploy.
    address internal constant OPTIMISM_MINTABLE_ERC721_FACTORY = 0x4200000000000000000000000000000000000017;

    /// @notice Address of the ProxyAdmin predeploy.
    address internal constant PROXY_ADMIN = 0x4200000000000000000000000000000000000018;

    /// @notice Address of the BaseFeeVault predeploy.
    address internal constant BASE_FEE_VAULT = 0x4200000000000000000000000000000000000019;

    /// @notice Address of the L1FeeVault predeploy.
    address internal constant L1_FEE_VAULT = 0x420000000000000000000000000000000000001A;

    /// @notice Address of the SchemaRegistry predeploy.
    address internal constant SCHEMA_REGISTRY = 0x4200000000000000000000000000000000000020;

    /// @notice Address of the EAS predeploy.
    address internal constant EAS = 0x4200000000000000000000000000000000000021;

    /// @notice Address of the GovernanceToken predeploy.
    address internal constant GOVERNANCE_TOKEN = 0x4200000000000000000000000000000000000042;

    /// @custom:legacy
    /// @notice Address of the LegacyERC20ETH predeploy. Deprecated. Balances are migrated to the
    ///         state trie as of the Bedrock upgrade. Contract has been locked and write functions
    ///         can no longer be accessed.
    address internal constant LEGACY_ERC20_ETH = 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;

    /// @notice Address of the CrossL2Inbox predeploy.
    address internal constant CROSS_L2_INBOX = 0x4200000000000000000000000000000000000022;

    /// @notice Address of the L2ToL2CrossDomainMessenger predeploy.
    address internal constant L2_TO_L2_CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000023;

    /// @notice Address of the SuperchainWETH predeploy.
    address internal constant SUPERCHAIN_WETH = 0x4200000000000000000000000000000000000024;

    /// @notice Address of the ETHLiquidity predeploy.
    address internal constant ETH_LIQUIDITY = 0x4200000000000000000000000000000000000025;

    /// @notice Address of the OptimismSuperchainERC20Factory predeploy.
    address internal constant OPTIMISM_SUPERCHAIN_ERC20_FACTORY = 0x4200000000000000000000000000000000000026;

    /// @notice Address of the OptimismSuperchainERC20Beacon predeploy.
    address internal constant OPTIMISM_SUPERCHAIN_ERC20_BEACON = 0x4200000000000000000000000000000000000027;

    // TODO: Precalculate the address of the implementation contract
    /// @notice Arbitrary address of the OptimismSuperchainERC20 implementation contract.
    address internal constant OPTIMISM_SUPERCHAIN_ERC20 = 0xB9415c6cA93bdC545D4c5177512FCC22EFa38F28;

    /// @notice Address of the SuperchainTokenBridge predeploy.
    address internal constant SUPERCHAIN_TOKEN_BRIDGE = 0x4200000000000000000000000000000000000028;

    /// @notice Returns the name of the predeploy at the given address.
    function getName(address _addr) internal pure returns (string memory out_) {
        require(isPredeployNamespace(_addr), "Predeploys: address must be a predeploy");
        if (_addr == LEGACY_MESSAGE_PASSER) {
            return "LegacyMessagePasser";
        }
        if (_addr == L1_MESSAGE_SENDER) {
            return "L1MessageSender";
        }
        if (_addr == DEPLOYER_WHITELIST) {
            return "DeployerWhitelist";
        }
        if (_addr == WETH) {
            return "WETH";
        }
        if (_addr == L2_CROSS_DOMAIN_MESSENGER) {
            return "L2CrossDomainMessenger";
        }
        if (_addr == GAS_PRICE_ORACLE) {
            return "GasPriceOracle";
        }
        if (_addr == L2_STANDARD_BRIDGE) {
            return "L2StandardBridge";
        }
        if (_addr == SEQUENCER_FEE_WALLET) {
            return "SequencerFeeVault";
        }
        if (_addr == OPTIMISM_MINTABLE_ERC20_FACTORY) {
            return "OptimismMintableERC20Factory";
        }
        if (_addr == L1_BLOCK_NUMBER) {
            return "L1BlockNumber";
        }
        if (_addr == L2_ERC721_BRIDGE) {
            return "L2ERC721Bridge";
        }
        if (_addr == L1_BLOCK_ATTRIBUTES) {
            return "L1Block";
        }
        if (_addr == L2_TO_L1_MESSAGE_PASSER) {
            return "L2ToL1MessagePasser";
        }
        if (_addr == OPTIMISM_MINTABLE_ERC721_FACTORY) {
            return "OptimismMintableERC721Factory";
        }
        if (_addr == PROXY_ADMIN) {
            return "ProxyAdmin";
        }
        if (_addr == BASE_FEE_VAULT) {
            return "BaseFeeVault";
        }
        if (_addr == L1_FEE_VAULT) {
            return "L1FeeVault";
        }
        if (_addr == SCHEMA_REGISTRY) {
            return "SchemaRegistry";
        }
        if (_addr == EAS) {
            return "EAS";
        }
        if (_addr == GOVERNANCE_TOKEN) {
            return "GovernanceToken";
        }
        if (_addr == LEGACY_ERC20_ETH) {
            return "LegacyERC20ETH";
        }
        if (_addr == CROSS_L2_INBOX) {
            return "CrossL2Inbox";
        }
        if (_addr == L2_TO_L2_CROSS_DOMAIN_MESSENGER) {
            return "L2ToL2CrossDomainMessenger";
        }
        if (_addr == SUPERCHAIN_WETH) {
            return "SuperchainWETH";
        }
        if (_addr == ETH_LIQUIDITY) {
            return "ETHLiquidity";
        }
        if (_addr == OPTIMISM_SUPERCHAIN_ERC20_FACTORY) {
            return "OptimismSuperchainERC20Factory";
        }
        if (_addr == OPTIMISM_SUPERCHAIN_ERC20_BEACON) {
            return "OptimismSuperchainERC20Beacon";
        }
        if (_addr == SUPERCHAIN_TOKEN_BRIDGE) {
            return "SuperchainTokenBridge";
        }
        revert("Predeploys: unnamed predeploy");
    }

    /// @notice Returns true if the predeploy is not proxied.
    function notProxied(address _addr) internal pure returns (bool) {
        return _addr == GOVERNANCE_TOKEN || _addr == WETH;
    }

    /// @notice Returns true if the address is a defined predeploy that is embedded into new OP-Stack chains.
    function isSupportedPredeploy(address _addr, bool _useInterop) internal pure returns (bool) {
        return _addr == LEGACY_MESSAGE_PASSER || _addr == DEPLOYER_WHITELIST || _addr == WETH
            || _addr == L2_CROSS_DOMAIN_MESSENGER || _addr == GAS_PRICE_ORACLE || _addr == L2_STANDARD_BRIDGE
            || _addr == SEQUENCER_FEE_WALLET || _addr == OPTIMISM_MINTABLE_ERC20_FACTORY || _addr == L1_BLOCK_NUMBER
            || _addr == L2_ERC721_BRIDGE || _addr == L1_BLOCK_ATTRIBUTES || _addr == L2_TO_L1_MESSAGE_PASSER
            || _addr == OPTIMISM_MINTABLE_ERC721_FACTORY || _addr == PROXY_ADMIN || _addr == BASE_FEE_VAULT
            || _addr == L1_FEE_VAULT || _addr == SCHEMA_REGISTRY || _addr == EAS || _addr == GOVERNANCE_TOKEN
            || (_useInterop && _addr == CROSS_L2_INBOX) || (_useInterop && _addr == L2_TO_L2_CROSS_DOMAIN_MESSENGER)
            || (_useInterop && _addr == SUPERCHAIN_WETH) || (_useInterop && _addr == ETH_LIQUIDITY)
            || (_useInterop && _addr == OPTIMISM_SUPERCHAIN_ERC20_FACTORY)
            || (_useInterop && _addr == OPTIMISM_SUPERCHAIN_ERC20_BEACON)
            || (_useInterop && _addr == SUPERCHAIN_TOKEN_BRIDGE);
    }

    function isPredeployNamespace(address _addr) internal pure returns (bool) {
        return uint160(_addr) >> 11 == uint160(0x4200000000000000000000000000000000000000) >> 11;
    }

    /// @notice Function to compute the expected address of the predeploy implementation
    ///         in the genesis state.
    function predeployToCodeNamespace(address _addr) internal pure returns (address) {
        require(
            isPredeployNamespace(_addr), "Predeploys: can only derive code-namespace address for predeploy addresses"
        );
        return address(
            uint160(uint256(uint160(_addr)) & 0xffff | uint256(uint160(0xc0D3C0d3C0d3C0D3c0d3C0d3c0D3C0d3c0d30000)))
        );
    }
}

interface IFeeSplitter {
    /// @notice Emitted when `distributeFees` is called and no fees are collected
    event NoFeesCollected();

    /// @notice Emitted when `distributeFees` is called and fees are distributed
    /// @param optimismShare The amount of fees sent to Optimism
    /// @param l1Fees The amount of fees sent to L1 distributor
    /// @param netShare The amount of fees sent to the net fee distributor
    event FeesDistributed(uint256 optimismShare, uint256 l1Fees, uint256 netShare);

    /// @notice Thrown when an address provided in the constructor is zero
    error AddressZero();

    /// @notice Thrown when a transfer fails
    error TransferFailed();

    /// @notice Thrown an address other than the fee splitter tries to withdraw fees from vaults
    error Locked();

    /// @notice Thrown when an address that is not a vault tries to deposit fees
    error OnlyVaults();

    /// @notice Thrown when a fee vault is configured to withdraw to L2
    error MustWithdrawToL2();

    /// @notice Thrown when a fee vault is not configured to withdraw to the fee splitter
    error MustWithdrawToFeeSplitter();

    /// @notice Distributes the fees collected from the fee vaults to their respective destinations
    /// @return feesDistributed Whether any fees were distributed
    function distributeFees() external returns (bool feesDistributed);
}

contract FeeSplitter is IFeeSplitter {
    // bytes32(uint256(keccak256('lock')) - 1);
    bytes32 private constant LOCK_STORAGE_SLOT = 0x6168652c307c1e813ca11cfb3a601f1cf3b22452021a5052d8b05f1f1f8a3e91;
    // bytes32(uint256(keccak256('net.revenue')) - 1);
    bytes32 private constant NET_REVENUE_STORAGE_SLOT =
        0x784be9e5da62c580888dd777e3d4e36ef68053ef5af2fc8f65c4050e4729e434;

    uint32 internal constant BASIS_POINT_SCALE = 1000;
    uint32 internal constant NET_REVENUE_SHARE = 150;
    uint32 internal constant GROSS_REVENUE_SHARE = 25;

    /// @dev The address of the Optimism wallet that will receive Optimism's revenue share.
    address public immutable OPTIMISM_WALLET;

    /// @dev The address of the Rewards Distributor that will receive a share of fees;
    address public immutable NET_FEE_RECIPIENT;

    /// @dev The address of the L1 wallet that will receive the OP chain runner's share of fees.
    address public immutable L1_FEE_RECIPIENT;

    /// @dev Constructor for the FeeSplitter contract which validates and sets immutable variables.
    /// @param optimismWallet The address which receives Optimism's revenue share.
    /// @param l1FeeRecipient The address which receives the L1 fee share.
    /// @param netFeeRecipient The address which receives the net fee share.
    constructor(address optimismWallet, address l1FeeRecipient, address netFeeRecipient) {
        if (optimismWallet == address(0) || netFeeRecipient == address(0) || l1FeeRecipient == address(0)) {
            revert AddressZero();
        }
        OPTIMISM_WALLET = optimismWallet;
        NET_FEE_RECIPIENT = netFeeRecipient;
        L1_FEE_RECIPIENT = l1FeeRecipient;
    }

    /// @inheritdoc IFeeSplitter
    function distributeFees() external virtual returns (bool feesDistributed) {
        if (
            Predeploys.SEQUENCER_FEE_WALLET.balance < IFeeVault(Predeploys.SEQUENCER_FEE_WALLET).minWithdrawalAmount()
                || Predeploys.BASE_FEE_VAULT.balance < IFeeVault(Predeploys.BASE_FEE_VAULT).minWithdrawalAmount()
                || Predeploys.L1_FEE_VAULT.balance < IFeeVault(Predeploys.L1_FEE_VAULT).minWithdrawalAmount()
        ) {
            // only collect fees if all fee vaults can be withdrawn from to guarantee accurate accounting of optimism revenue share
            emit NoFeesCollected();
            return false;
        }

        // unlock
        assembly ("memory-safe") {
            tstore(LOCK_STORAGE_SLOT, 1)
        }
        _feeVaultWithdrawal(Predeploys.SEQUENCER_FEE_WALLET);
        _feeVaultWithdrawal(Predeploys.BASE_FEE_VAULT);
        _feeVaultWithdrawal(Predeploys.L1_FEE_VAULT);

        // lock
        assembly ("memory-safe") {
            tstore(LOCK_STORAGE_SLOT, 0)
        }

        uint256 netFeeRevenue;
        uint256 grossFeeRevenue = address(this).balance;

        assembly ("memory-safe") {
            netFeeRevenue := tload(NET_REVENUE_STORAGE_SLOT)
            tstore(NET_REVENUE_STORAGE_SLOT, 0)
        }

        /// @audit gas savings if min withdrawal amount is set to 0
        if (grossFeeRevenue == 0) {
            emit NoFeesCollected();
            return false;
        }

        uint256 netRevenueShare = netFeeRevenue * NET_REVENUE_SHARE / BASIS_POINT_SCALE;
        uint256 grossRevenueShare = grossFeeRevenue * GROSS_REVENUE_SHARE / BASIS_POINT_SCALE;

        uint256 optimismRevenueShare;
        uint256 l1Fee;
        uint256 remainingNetRevenue;
        if (grossRevenueShare > netRevenueShare) {
            // if the gross revenue share is greater than the net revenue share, 2.5% of the gross revenue is sent to optimism
            // the remaining 97.5% of the L1 fees are sent to L1
            // the remaining 97.5% of the net fees are sent to the net fee recipient
            optimismRevenueShare = grossRevenueShare;
            l1Fee = (grossFeeRevenue - netFeeRevenue) * (BASIS_POINT_SCALE - GROSS_REVENUE_SHARE) / BASIS_POINT_SCALE;
            remainingNetRevenue = netFeeRevenue * (BASIS_POINT_SCALE - GROSS_REVENUE_SHARE) / BASIS_POINT_SCALE;
        } else {
            // if the net revenue share is greater than the gross revenue share, 15% of the net revenue is sent to optimism
            // the entire amount of L1 fees are sent to L1
            // the remaining 85% of the net fees are sent to the net fee recipient
            optimismRevenueShare = netRevenueShare;
            l1Fee = grossFeeRevenue - netFeeRevenue;
            remainingNetRevenue = netFeeRevenue - optimismRevenueShare;
        }

        if (!SafeCall.send(OPTIMISM_WALLET, gasleft(), optimismRevenueShare)) {
            revert TransferFailed();
        }

        if (!SafeCall.send(L1_FEE_RECIPIENT, gasleft(), l1Fee)) {
            revert TransferFailed();
        }

        if (!SafeCall.send(NET_FEE_RECIPIENT, gasleft(), remainingNetRevenue)) {
            revert TransferFailed();
        }

        emit FeesDistributed(optimismRevenueShare, l1Fee, remainingNetRevenue);
        return true;
    }

    /// @dev Receives ETH fees withdrawn from L2 FeeVaults and stores the net revenue in transient storage.
    /// @dev Will revert if ETH is not sent from L2 FeeVaults.
    /// @dev anyone can call the withdraw function on the vaults, the lock ensures that a withdrawal is only successful if the fee splitter is withdrawing the fees to ensure accurate accounting
    receive() external payable virtual {
        uint256 unlocked;
        assembly ("memory-safe") {
            unlocked := tload(LOCK_STORAGE_SLOT)
        }
        if (unlocked == 0) {
            revert Locked();
        }

        // TODO: explore whether the withdraw function can return a value indicating the amount of fees withdrawn
        if (msg.sender == Predeploys.SEQUENCER_FEE_WALLET || msg.sender == Predeploys.BASE_FEE_VAULT) {
            uint256 amount = msg.value;
            // combine the fees from the sequencer and base FeeVaults as net revenue
            assembly ("memory-safe") {
                tstore(NET_REVENUE_STORAGE_SLOT, add(tload(NET_REVENUE_STORAGE_SLOT), amount))
            }
        } else if (msg.sender == Predeploys.L1_FEE_VAULT) {
            // L1 Fee can be retrieved by subtracting the net fee revenue from address(this).balance
            // any dust not distributed in previous distributions is allocated towards L1 fee revenue automatically
        } else {
            revert OnlyVaults();
        }
    }

    function _feeVaultWithdrawal(address _feeVault) internal {
        if (IFeeVault(_feeVault).withdrawalNetwork() != IFeeVault.WithdrawalNetwork.L2) {
            revert MustWithdrawToL2();
        }
        if (IFeeVault(_feeVault).recipient() != address(this)) {
            revert MustWithdrawToFeeSplitter();
        }
        IFeeVault(_feeVault).withdraw();
    }
}
