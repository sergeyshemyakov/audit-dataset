// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import {BOOTLOADER_FORMAL_ADDRESS, DEPLOYER_SYSTEM_CONTRACT, MSG_VALUE_SYSTEM_CONTRACT} from "./Constants.sol";
import {IEthToken} from "./interfaces/IEthToken.sol";
import {SystemContractHelper} from "./libraries/SystemContractHelper.sol";

/**
 * @author Matter Labs
 * @notice Native ETH contract.
 * @dev It does NOT provide interfaces for personal interaction with tokens like `transfer`, `approve`, and `transferFrom`.
 * Instead, this contract is used by `MsgValueSimulator` and `ContractDeployer` system contracts
 * to perform the balance changes while simulating the `msg.value` Ethereum behavior.
 */
contract L2EthToken is IEthToken {
    /// @notice The balances of the users.
    mapping(address => uint256) public override balanceOf;

    /// @notice The total amount of tokens that have been minted.
    uint256 public override totalSupply;

    /// NOTE: The deprecated from the previous upgrade storage variable.
    // TODO: Remove this variable with the new upgrade.
    address __DEPRECATED_l2Bridge = address(0);

    modifier onlyBootloader() {
        require(msg.sender == BOOTLOADER_FORMAL_ADDRESS, "Callable only by the bootloader");
        _;
    }

    /// @notice Transfer tokens from one address to another.
    /// @param _from The address to transfer the ETH from.
    /// @param _to The address to transfer the ETH to.
    /// @param _amount The amount of ETH in wei being transferred.
    /// @dev This function can be called only by trusted system contracts.
    /// @dev This function also emits "Transfer" event, which might be removed
    /// later on.
    function transferFromTo(address _from, address _to, uint256 _amount) external override {
        require(
            msg.sender == MSG_VALUE_SYSTEM_CONTRACT || msg.sender == address(DEPLOYER_SYSTEM_CONTRACT)
                || msg.sender == BOOTLOADER_FORMAL_ADDRESS,
            "Only system contracts with special access can call this method"
        );

        // We rely on the compiler "Checked Arithmetic" to revert if the user does not have enough balance.
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);
    }

    /// @notice Increase the total supply of tokens and balance of the receiver.
    /// @dev This method is only callable by the L2 ETH bridge.
    /// @param _account The address which to mint the funds to.
    /// @param _amount The amount of ETH in wei to be minted.
    function mint(address _account, uint256 _amount) external override onlyBootloader {
        totalSupply += _amount;
        balanceOf[_account] += _amount;
        emit Mint(_account, _amount);
    }

    /// @notice Initiate the ETH withdrawal, funds will be available to claim on L1 `finalizeWithdrawal` method.
    /// @param _l1Receiver The address on L1 to receive the funds.
    function withdraw(address _l1Receiver) external payable override {
        uint256 amount = msg.value;

        // Silent burning of the ether
        unchecked {
            balanceOf[address(this)] -= amount;
            totalSupply -= amount;
        }

        // Send the L2 log, a user could use it as proof of the withdrawal
        SystemContractHelper.toL1(true, bytes32(uint256(uint160(_l1Receiver))), bytes32(amount));

        emit Withdrawal(_l1Receiver, amount);
    }

    /// @dev This method has not been stabilized and might be
    /// removed later on.
    function name() external pure override returns (string memory) {
        return "Ether";
    }

    /// @dev This method has not been stabilized and might be
    /// removed later on.
    function symbol() external pure override returns (string memory) {
        return "ETH";
    }

    /// @dev This method has not been stabilized and might be
    /// removed later on.
    function decimals() external pure override returns (uint8) {
        return 18;
    }
}
